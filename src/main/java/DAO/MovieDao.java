package DAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.Movie;


public class MovieDao extends DAO {

	public MovieDao() {
		super();
	}
	//lấy hết các phim đang chiếu để hiện lên màn
	public List<Movie> getAllMovies() {
		List<Movie> list = new ArrayList<>();
		String sql = "SELECT * FROM tblMovie where active = 1";
		try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Movie m = new Movie();
				m.setId(rs.getInt("id"));
				m.setCategory(rs.getString("category"));
				m.setDescription(rs.getString("description"));
				m.setPoster(rs.getString("poster"));
				m.setName(rs.getString("name"));
				m.setActive(rs.getInt("active"));
				list.add(m);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public List<Movie> searchByKeyword(String keyword) {
		List<Movie> list = new ArrayList<>();
		String sql = "SELECT * FROM tblMovie WHERE name LIKE ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setString(1, "%" + keyword + "%");
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					Movie m = new Movie();
					m.setId(rs.getInt("id"));
					m.setCategory(rs.getString("category"));
					m.setDescription(rs.getString("description"));
					m.setPoster(rs.getString("poster"));
					m.setName(rs.getString("name"));
					m.setActive(rs.getInt("active"));
					list.add(m);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public Movie getById(int id) {
		String sql = "SELECT * FROM tblMovie WHERE id = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setInt(1, id);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					Movie m = new Movie();
					m.setId(rs.getInt("id"));
					m.setCategory(rs.getString("category"));
					m.setDescription(rs.getString("description"));
					m.setPoster(rs.getString("poster"));
					m.setName(rs.getString("name"));
					m.setActive(rs.getInt("active"));
					return m;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

}