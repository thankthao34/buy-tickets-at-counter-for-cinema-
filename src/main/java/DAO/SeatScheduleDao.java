package DAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import model.Schedule;
import model.Seat;
import model.SeatSchedule;

/**
 *
 * @author Admin
 */
public class SeatScheduleDao extends DAO {
    public SeatScheduleDao() {
        super();
    }

    public List<SeatSchedule> findSeatSchedule(int scheduleId) {
        List<SeatSchedule> list = new ArrayList<>();
        String sql = "SELECT ss.*, s.id AS seatId, s.name AS seatName, s.position AS seatPos, s.priceMultiplier "
                + "FROM tblSeatSchedule ss JOIN tblSeat s ON ss.tblSeatid = s.id "
                + "WHERE ss.tblScheduleid = ? ORDER BY s.name";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, scheduleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SeatSchedule ss = new SeatSchedule();
                    ss.setId(rs.getInt("id"));
                    Seat seat = new Seat();
                    seat.setId(rs.getInt("seatId"));
                    seat.setName(rs.getString("seatName"));
                    seat.setPosition(rs.getString("seatPos"));
                    seat.setPriceMultiplier(rs.getFloat("priceMultiplier"));
                    ss.setSeat(seat);
                    Schedule sch = new Schedule();
                    sch.setId(scheduleId);
                    ss.setSchedule(sch);
                    ss.setStatus(rs.getInt("status"));
                    list.add(ss);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public SeatSchedule findById(int id) {
        String sql = "SELECT ss.*, s.id AS seatId, s.name AS seatName, s.position AS seatPos, s.priceMultiplier, ss.tblScheduleid "
                + "FROM tblSeatSchedule ss JOIN tblSeat s ON ss.tblSeatid = s.id WHERE ss.id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SeatSchedule ss = new SeatSchedule();
                    ss.setId(rs.getInt("id"));
                    model.Seat seat = new model.Seat();
                    seat.setId(rs.getInt("seatId"));
                    seat.setName(rs.getString("seatName"));
                    seat.setPosition(rs.getString("seatPos"));
                    seat.setPriceMultiplier(rs.getFloat("priceMultiplier"));
                    ss.setSeat(seat);
                    model.Schedule sch = new model.Schedule();
                    sch.setId(rs.getInt("tblScheduleid"));
                    ss.setSchedule(sch);
                    ss.setStatus(rs.getInt("status"));
                    return ss;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean checkSeatSchedule(java.util.List<Integer> ids) {
        if (ids == null || ids.isEmpty()) return false;
        // build SQL with IN clause
        StringBuilder sb = new StringBuilder();
        sb.append("SELECT id, status FROM tblSeatSchedule WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) { if (i > 0) sb.append(','); sb.append('?'); }
        sb.append(')');
        String sql = sb.toString();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int idx = 1;
            for (Integer id : ids) ps.setInt(idx++, id);
            try (ResultSet rs = ps.executeQuery()) {
                java.util.Set<Integer> found = new java.util.HashSet<>();
                while (rs.next()) {
                    int id = rs.getInt("id");
                    int status = rs.getInt("status");
                    found.add(id);
                    if (status != 1) return false; // not available
                }
                // ensure all ids were present
                return found.size() == ids.size();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}