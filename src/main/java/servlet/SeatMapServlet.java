package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import DAO.ScheduleDao;
import DAO.SeatScheduleDao;
import model.Schedule;
import model.SeatSchedule;

@WebServlet(name = "SeatMapServlet", urlPatterns = {"/seatmap"})
public class SeatMapServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sid = request.getParameter("scheduleId");
        if (sid == null) {
            response.sendRedirect(request.getContextPath() + "/SearchMovie");
            return;
        }

        int scheduleId;
        try {
            scheduleId = Integer.parseInt(sid);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/SearchMovie");
            return;
        }

        // parse optional allowedRange param of the form "min-max"
        String allowedRange = request.getParameter("allowedRange");
        Integer allowedMin = null, allowedMax = null;
        if (allowedRange != null && allowedRange.contains("-")) {
            try {
                String[] parts = allowedRange.split("-", 2);
                allowedMin = Integer.parseInt(parts[0].trim());
                allowedMax = Integer.parseInt(parts[1].trim());
            } catch (Exception ex) {
                allowedMin = null;
                allowedMax = null;
            }
        }

        SeatScheduleDao ssDao = new SeatScheduleDao();
        List<SeatSchedule> seats = ssDao.findSeatSchedule(scheduleId); // returns all seats with status (0 booked, 1 available)

        ScheduleDao schDao = new ScheduleDao();
        Schedule schedule = schDao.getById(scheduleId);

        // lưu thông tin lịch chiếu vào session cho các bước sau
        request.getSession().setAttribute("currentSchedule", schedule);

        // movie is stored in session by upstream flows; set it on the request for the JSP
        request.setAttribute("movie", request.getSession().getAttribute("currentMovie"));

        request.setAttribute("seats", seats);
        request.setAttribute("schedule", schedule);
        if (allowedMin != null && allowedMax != null) {
            request.setAttribute("allowedMin", allowedMin);
            request.setAttribute("allowedMax", allowedMax);
            request.setAttribute("allowedRange", allowedMin + "-" + allowedMax);
        }

        request.getRequestDispatcher("/WEB-INF/TicketClerk/SeatMap.jsp").forward(request, response);
    }

}
