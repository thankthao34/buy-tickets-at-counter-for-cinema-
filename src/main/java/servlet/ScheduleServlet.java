package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import DAO.MovieDao;
import DAO.ScheduleDao;
import model.Movie;
import model.Schedule;

@WebServlet(name = "ScheduleServlet", urlPatterns = {"/schedule"})
public class ScheduleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String movieIdParam = req.getParameter("movieId");
        if (movieIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/searchMovie");
            return;
        }

        int movieId;
        try {
            movieId = Integer.parseInt(movieIdParam);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/searchMovie");
            return;
        }

        // Nếu có tham số date (yyyy-MM-dd) -> lấy lịch cho ngày đó, ngược lại lấy hôm nay
        String dateParam = req.getParameter("date");
        java.sql.Date sqlDate = null;
        try {
            if (dateParam != null && !dateParam.isEmpty()) {
                // expects format yyyy-MM-dd
                sqlDate = java.sql.Date.valueOf(dateParam);
            }
        } catch (Exception ex) {
            sqlDate = null; // fall back to today
        }
        if (sqlDate == null) {
            java.util.Date today = new java.util.Date();
            sqlDate = new java.sql.Date(today.getTime());
        }

        ScheduleDao sdao = new ScheduleDao();
        List<Schedule> schedules = sdao.findByMovie(movieId, sqlDate);

        // expose the selected date back to JSP in yyyy-MM-dd and dd/MM/yyyy formats
        req.setAttribute("selectedDateParam", sqlDate.toString()); // yyyy-MM-dd
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
        req.setAttribute("selectedDateDisplay", sdf.format(new java.util.Date(sqlDate.getTime())));


        MovieDao mdao = new MovieDao();
        Movie movie = mdao.getById(movieId);

    // Lưu thông tin phim vào session
    req.getSession().setAttribute("currentMovie", movie);

    req.setAttribute("movie", movie);
        req.setAttribute("schedules", schedules);
        req.getRequestDispatcher("/WEB-INF/TicketClerk/Schedule.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }

}
