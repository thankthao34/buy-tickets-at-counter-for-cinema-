package servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import model.User;

@WebServlet(name = "MainSellerServlet", urlPatterns = {"/mainSeller"})
public class MainSellerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/Login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/Login.jsp");
            return;
        }

        // ensure session defaults exist
        if (session.getAttribute("currentMovie") == null) session.setAttribute("currentMovie", null);
        if (session.getAttribute("currentSchedule") == null) session.setAttribute("currentSchedule", null);
        if (session.getAttribute("selectedSeats") == null) session.setAttribute("selectedSeats", new java.util.ArrayList<>());
        if (session.getAttribute("cartTotal") == null) session.setAttribute("cartTotal", 0.0);

        req.getRequestDispatcher("/WEB-INF/TicketClerk/MainSeller.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
