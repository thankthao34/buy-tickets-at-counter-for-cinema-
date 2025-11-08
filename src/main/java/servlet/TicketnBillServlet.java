package servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import DAO.OfflineBillDao;
import DAO.ScheduleDao;
import DAO.SeatScheduleDao;
import model.OfflineBill;
import model.Schedule;
import model.SeatSchedule;
import model.Ticket;
import model.TicketClerk;
import model.User;

@WebServlet(name = "TicketnBillServlet", urlPatterns = {"/ticketnBill"})
public class TicketnBillServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// Show summary page (TicketnBill.jsp). Accept selectedSeatId[] and scheduleId via GET or use session.
		String scheduleIdParam = req.getParameter("scheduleId");
		String[] selected = req.getParameterValues("selectedSeatId[]");

        HttpSession session = req.getSession();

        List<SeatSchedule> selectedSeats = (List<SeatSchedule>) session.getAttribute("selectedSeats");
        Schedule schedule = (Schedule) session.getAttribute("currentSchedule");

        if (selected != null && selected.length > 0) {
            // fetch selected seats and store entities in session
            SeatScheduleDao ssDao = new SeatScheduleDao();
            selectedSeats = new ArrayList<>();
            for (String s : selected) {
                try {
                    int id = Integer.parseInt(s);
                    SeatSchedule ss = ssDao.findById(id);
                    if (ss != null) selectedSeats.add(ss);
                } catch (Exception ex) {
                    // ignore parse errors
                }
            }
            session.setAttribute("selectedSeats", selectedSeats);
        }

        if ((schedule == null || schedule.getId() == 0) && scheduleIdParam != null) {
            try {
                int sid = Integer.parseInt(scheduleIdParam);
                ScheduleDao sdao = new ScheduleDao();
                schedule = sdao.getById(sid);
                session.setAttribute("currentSchedule", schedule);
            } catch (Exception ex) { /* ignore */ }
        }

        // compute cartTotal if not present
        Double cartTotal = (Double) session.getAttribute("cartTotal");
        if (cartTotal == null) cartTotal = 0.0;
        if (selectedSeats != null && !selectedSeats.isEmpty()) {
            cartTotal = 0.0;
            for (SeatSchedule ss : selectedSeats) {
                double multiplier = 1.0;
                if (ss.getSeat() != null) multiplier = ss.getSeat().getPriceMultiplier();
                if (schedule != null) cartTotal += schedule.getBasePrice() * multiplier;
            }
            session.setAttribute("cartTotal", cartTotal);
        }

        // forward to JSP for review/print
        req.getRequestDispatcher("/WEB-INF/TicketClerk/TicketnBill.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Simplified box-office flow: when staff confirms (presses In), save directly (saveOfflineBill locks seats and saves atomically)

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<SeatSchedule> selectedSeats = (List<SeatSchedule>) session.getAttribute("selectedSeats");
        Schedule schedule = (Schedule) session.getAttribute("currentSchedule");
        User user = (User) session.getAttribute("user");

        if (selectedSeats == null || selectedSeats.isEmpty() || schedule == null || user == null) {
            // missing data -> back to seat map
            session.removeAttribute("selectedSeats");
            // session.removeAttribute("selectedSeatIds");
            session.setAttribute("cartTotal", 0.0);
            resp.sendRedirect(req.getContextPath() + "/searchMovie");
            return;
        }

        // selectedSeats must be present in session (set by doGet). If missing, treat as invalid and redirect.
        if (selectedSeats == null || selectedSeats.isEmpty()) {
            session.removeAttribute("selectedSeats");
            session.setAttribute("cartTotal", 0.0);
            resp.sendRedirect(req.getContextPath() + "/searchMovie");
            return;
        }

        // build ticket list
        List<Ticket> tickets = new ArrayList<>();
        for (SeatSchedule ss : selectedSeats) {
            Ticket t = new Ticket();
            double multiplier = 1.0;
            if (ss.getSeat() != null) multiplier = ss.getSeat().getPriceMultiplier();
            float price = (float) (schedule.getBasePrice() * multiplier);
            t.setPrice(price);
            t.setSeatSchedule(ss);
            tickets.add(t);
        }

    // 1) Check availability of selected seats before attempting to save
    SeatScheduleDao ssDaoCheck = new SeatScheduleDao();
    // boolean allAvailable = ssDaoCheck.checkSeatSchedule(selectedIds);
    List<Integer> idsToCheck = new ArrayList<>();
    for (SeatSchedule sss : selectedSeats) idsToCheck.add(sss.getId());
    boolean allAvailable = ssDaoCheck.checkSeatSchedule(idsToCheck);
        if (!allAvailable) {
            // some seats are no longer available -> clear selection and redirect to seatmap for reselect
            session.removeAttribute("selectedSeats");
            // session.removeAttribute("selectedSeatIds");
            session.setAttribute("cartTotal", 0.0);
            session.setAttribute("bookingError", "Một hoặc nhiều ghế của bạn đã bị đặt. Vui lòng chọn lại.");
            resp.sendRedirect(req.getContextPath() + "/seatmap?scheduleId=" + schedule.getId());
            return;
        }

        // 2) All seats available -> prepare OfflineBill and save using OfflineBillDao.saveOfflineBill(OfflineBill)
        OfflineBill offline = new OfflineBill();
        TicketClerk clerk = new TicketClerk();
        clerk.setId(user.getId());
        offline.setTicketClerk(clerk);
        offline.setTickets(tickets);
        Object cartObj = session.getAttribute("cartTotal");
        float totalPrice = 0f;
        if (cartObj instanceof Number) totalPrice = ((Number) cartObj).floatValue();
        offline.setTotalPrice(totalPrice);

        OfflineBillDao offDao = new OfflineBillDao();
        int billId = offDao.saveOfflineBill(offline);
        if (billId == -1) {
            // failure when saving
            session.removeAttribute("selectedSeats");
            // session.removeAttribute("selectedSeatIds");
            session.setAttribute("cartTotal", 0.0);
            session.setAttribute("bookingError", "Lưu hóa đơn không thành công. Vui lòng thử lại.");
            resp.sendRedirect(req.getContextPath() + "/seatmap?scheduleId=" + schedule.getId());
            return;
        }

        // success: clear selection and forward to JSP to show success
    session.removeAttribute("selectedSeats");
    // session.removeAttribute("selectedSeatIds");
        session.setAttribute("cartTotal", 0.0);
        session.setAttribute("lastBillId", billId);
        req.setAttribute("finalizeSuccess", true);
        req.setAttribute("billId", billId);
        req.getRequestDispatcher("/WEB-INF/TicketClerk/TicketnBill.jsp").forward(req, resp);
    }
}
