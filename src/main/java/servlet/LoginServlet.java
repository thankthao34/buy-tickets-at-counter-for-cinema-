package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import DAO.UserDao;
import model.User;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // If user already logged in, redirect to mainSeller so URL stays clean
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/mainSeller");
            return;
        }

        // Show login page on GET
        req.getRequestDispatcher("/Login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Handle login submission via POST to avoid leaking credentials in URL
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập tên đăng nhập và mật khẩu.");
            req.getRequestDispatcher("/Login.jsp").forward(req, resp);
            return;
        }

        UserDao dao = new UserDao();
        User u = dao.checkLogin(username, password);

        if (u != null && u.getRole() != null && "SELLER".equalsIgnoreCase(u.getRole())) {
            HttpSession session = req.getSession(true);
            session.setAttribute("user", u);
            session.setAttribute("currentMovie", null);
            session.setAttribute("currentSchedule", null);
            session.setAttribute("selectedSeats", new java.util.ArrayList<model.SeatSchedule>());
            session.setAttribute("cartTotal", 0.0);

            // Redirect after successful POST (Post-Redirect-Get) so browser shows clean URL
            resp.sendRedirect(req.getContextPath() + "/mainSeller");
            return;
        }

        // failed login
        req.setAttribute("error", "Sai tên đăng nhập/mật khẩu hoặc bạn không có quyền SELLER.");
        req.getRequestDispatcher("/Login.jsp").forward(req, resp);
    }
}
