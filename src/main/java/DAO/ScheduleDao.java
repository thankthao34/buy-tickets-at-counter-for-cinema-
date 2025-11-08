package DAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.Movie;
import model.Room;
import model.Schedule;

/**
 *
 * @author Admin
 */
public class ScheduleDao extends DAO {
	public ScheduleDao() {
		super();
	}

	public List<Schedule> findByMovie(int movieId, java.sql.Date day) {
		List<Schedule> list = new ArrayList<>();
	String sql = "SELECT s.*, r.id AS roomId, r.name AS roomName, r.capacity AS roomCapacity, r.description AS roomDescription "
		+ "FROM tblSchedule s JOIN tblRoom r ON s.tblRoomid = r.id "
		+ "WHERE s.tblMovieid = ? AND s.date = ? ORDER BY s.startTime";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setInt(1, movieId);
			ps.setDate(2, day);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					Schedule sch = new Schedule();
					sch.setId(rs.getInt("id"));
					Movie m = new Movie();
					m.setId(movieId);
					sch.setMovie(m);
					sch.setDate(new java.util.Date(rs.getDate("date").getTime()));
					sch.setStartTime(rs.getTime("startTime"));
					sch.setEndTime(rs.getTime("endTime"));
					Room room = new Room();
					room.setId(rs.getInt("roomId"));
					room.setName(rs.getString("roomName"));
					room.setCapacity(rs.getInt("roomCapacity"));
					room.setDescription(rs.getString("roomDescription"));
					sch.setRoom(room);
					sch.setBasePrice(rs.getFloat("basePrice"));
					list.add(sch);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	public Schedule getById(int id) {
		String sql = "SELECT s.*, r.id AS roomId, r.name AS roomName, r.capacity AS roomCapacity, r.description AS roomDescription, m.id AS movieId, m.name AS movieName, m.poster AS moviePoster "
				+ "FROM tblSchedule s "
				+ "LEFT JOIN tblRoom r ON s.tblRoomid = r.id "
				+ "LEFT JOIN tblMovie m ON s.tblMovieid = m.id "
				+ "WHERE s.id = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setInt(1, id);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					// schedule
					Schedule sch = new Schedule();
					sch.setId(rs.getInt("id"));
					sch.setBasePrice(rs.getFloat("basePrice"));
					sch.setStartTime(rs.getTime("startTime"));
					sch.setEndTime(rs.getTime("endTime"));
					java.sql.Date d = rs.getDate("date");
					if (d != null) sch.setDate(new java.util.Date(d.getTime()));

					// room
					int roomId = rs.getInt("roomId");
					if (!rs.wasNull()) {
						Room room = new Room();
						room.setId(roomId);
						room.setName(rs.getString("roomName"));
						room.setCapacity(rs.getInt("roomCapacity"));
						room.setDescription(rs.getString("roomDescription"));
						sch.setRoom(room);
					}

					// movie 
					int movieId = rs.getInt("movieId");
					if (!rs.wasNull()) {
						Movie mv = new Movie();
						mv.setId(movieId);
						mv.setName(rs.getString("movieName"));
						mv.setPoster(rs.getString("moviePoster"));
						sch.setMovie(mv);
					}

					return sch;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
}