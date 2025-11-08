package servlet;

import DAO.OfflineBillDao;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.OfflineBill;

@WebServlet(name = "PrintServlet", urlPatterns = {"/print"})
public class PrintServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String billIdParam = req.getParameter("billId");
        HttpSession session = req.getSession(false);
        int billId = -1;
        if (billIdParam != null) {
            try { billId = Integer.parseInt(billIdParam); } catch (Exception e) { billId = -1; }
        }
        // fallback to session lastBillId if not provided
        if ((billId <= 0) && session != null) {
            Object last = session.getAttribute("lastBillId");
            if (last instanceof Number) billId = ((Number) last).intValue();
        }

        if (billId <= 0) {
            // nothing to print
            req.getSession().setAttribute("bookingError", "Không tìm thấy mã hóa đơn để in.");
            resp.sendRedirect(req.getContextPath() + "/ticketnBill");
            return;
        }

        OfflineBillDao dao = new OfflineBillDao();
        OfflineBill offline = dao.getOfflineBill(billId);
        if (offline == null) {
            req.getSession().setAttribute("bookingError", "Không tìm thấy hóa đơn hoặc lỗi truy vấn.");
            resp.sendRedirect(req.getContextPath() + "/ticketnBill");
            return;
        }

        req.setAttribute("offlineBill", offline);
        req.getRequestDispatcher("/WEB-INF/TicketClerk/Print.jsp").forward(req, resp);
    }
}

