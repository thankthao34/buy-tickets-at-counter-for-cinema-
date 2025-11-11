package servlet;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import DAO.MovieDao;
import model.Movie;

@WebServlet(name = "SearchMovieServlet", urlPatterns = {"/searchMovie"})
public class SearchMovieServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        MovieDao dao = new MovieDao();
        List<Movie> movies;
        if (keyword != null && !keyword.trim().isEmpty()) {
            movies = dao.searchByKeyword(keyword.trim());
            req.setAttribute("keyword", keyword.trim());
        } else {
            movies = dao.getAllMovies();
        }

        req.setAttribute("movies", movies);
        req.getRequestDispatcher("/WEB-INF/TicketClerk/SearchMovie.jsp").forward(req, resp);
    }


}
