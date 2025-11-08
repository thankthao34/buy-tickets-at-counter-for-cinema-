/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import model.Movie;
import model.OfflineBill;
import model.Room;
import model.Schedule;
import model.Seat;
import model.SeatSchedule;
import model.Ticket;
import model.TicketClerk;

/**
 *
 * @author Admin
 */
public class OfflineBillDao extends DAO {

    public OfflineBillDao() {
        super();
    }

    public OfflineBill getOfflineBill(int billId) {
        if (billId <= 0) return null;
        Connection conn = this.connection;
        if (conn == null) return null;
        try {
            // 1) Get bill + offline + clerk info
            String qBill = "SELECT b.id AS billId, b.pointEx, b.createDate, b.total_price, ob.tblTicketClerkid, u.fullName AS clerkName "
                    + "FROM tblBill b "
                    + "JOIN tblOfflineBill ob ON b.id = ob.tblBillid "
                    + "LEFT JOIN tblTicketClerk tc ON ob.tblTicketClerkid = tc.tblUserid "
                    + "LEFT JOIN tblUser u ON tc.tblUserid = u.id "
                    + "WHERE b.id = ?";
            OfflineBill result = null;
            try (PreparedStatement ps = conn.prepareStatement(qBill)) {
                ps.setInt(1, billId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result = new OfflineBill();
                        result.setId(rs.getInt("billId"));
                        result.setPointEx(rs.getFloat("pointEx"));
                        Timestamp ts = rs.getTimestamp("createDate");
                        if (ts != null) result.setCreateDate(ts.toLocalDateTime());
                        result.setTotalPrice(rs.getFloat("total_price"));
                        int clerkId = rs.getInt("tblTicketClerkid");
                        String clerkName = rs.getString("clerkName");
                        if (clerkId > 0) {
                            TicketClerk tc = new TicketClerk();
                            tc.setId(clerkId);
                            tc.setFullName(clerkName);
                            result.setTicketClerk(tc);
                        }
                    }
                }
            }

            if (result == null) return null; // not found

            // 2) Get tickets and related seat/schedule/movie/room
        String qTickets = "SELECT t.id AS ticketId, t.price AS ticketPrice, ss.id AS ssId, s.id AS seatId, s.name AS seatName, s.description AS seatDescription, s.priceMultiplier, "
                    + "sch.id AS scheduleId, sch.date AS scheduleDate, sch.startTime AS startTime, sch.endTime AS endTime, "
                    + "r.id AS roomId, r.name AS roomName, m.id AS movieId, m.name AS movieName "
                    + "FROM tblTicket t "
                    + "JOIN tblSeatSchedule ss ON t.tblSeatScheduleid = ss.id "
                    + "JOIN tblSeat s ON ss.tblSeatid = s.id "
                    + "JOIN tblSchedule sch ON ss.tblScheduleid = sch.id "
                    + "JOIN tblRoom r ON sch.tblRoomid = r.id "
                    + "JOIN tblMovie m ON sch.tblMovieid = m.id "
                    + "WHERE t.tblBillid = ?";

            try (PreparedStatement ps2 = conn.prepareStatement(qTickets)) {
                ps2.setInt(1, billId);
                try (ResultSet rs2 = ps2.executeQuery()) {
                    List<Ticket> tickets = new ArrayList<>();
                    while (rs2.next()) {
                        Ticket t = new Ticket();
                        t.setId(rs2.getInt("ticketId"));
                        t.setPrice(rs2.getFloat("ticketPrice"));

                        Seat seat = new Seat();
                        seat.setId(rs2.getInt("seatId"));
                        seat.setName(rs2.getString("seatName"));
                        seat.setDescription(rs2.getString("seatDescription"));
                        seat.setPriceMultiplier(rs2.getFloat("priceMultiplier"));

                        Room room = new Room();
                        room.setId(rs2.getInt("roomId"));
                        room.setName(rs2.getString("roomName"));

                        Movie movie = new Movie();
                        movie.setId(rs2.getInt("movieId"));
                        movie.setName(rs2.getString("movieName"));

                        Schedule sch = new Schedule();
                        sch.setId(rs2.getInt("scheduleId"));
                        java.sql.Date schedDate = rs2.getDate("scheduleDate");
                        if (schedDate != null) sch.setDate(new java.util.Date(schedDate.getTime()));
                        java.sql.Time st = rs2.getTime("startTime");
                        if (st != null) sch.setStartTime(st);
                        java.sql.Time et = rs2.getTime("endTime");
                        if (et != null) sch.setEndTime(et);
                        sch.setRoom(room);
                        sch.setMovie(movie);

                        SeatSchedule ss = new SeatSchedule();
                        ss.setId(rs2.getInt("ssId"));
                        ss.setSeat(seat);
                        ss.setSchedule(sch);

                        t.setSeatSchedule(ss);
                        tickets.add(t);
                    }
                    result.setTickets(tickets);
                }
            }

            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    public int saveOfflineBill(OfflineBill offlineBill) {
        if (offlineBill == null || offlineBill.getTickets() == null) return -1;
        List<Ticket> tickets = offlineBill.getTickets();
        int clerkId = 0;
        if (offlineBill.getTicketClerk() != null) clerkId = offlineBill.getTicketClerk().getId();

        Connection conn = this.connection;
        if (conn == null) return -1;
        try {
            conn.setAutoCommit(false);

            // 1) update seat statuses to booked (status = 0) only if they are currently 1
            String updateSeatSql = "UPDATE tblSeatSchedule SET status = 0 WHERE id = ? AND status = 1";
            try (PreparedStatement psUpdateSeat = conn.prepareStatement(updateSeatSql)) {
                for (Ticket t : tickets) {
                    int ssId = t.getSeatSchedule().getId();
                    psUpdateSeat.setInt(1, ssId);
                    int updated = psUpdateSeat.executeUpdate();
                    if (updated == 0) {
                        conn.rollback();
                        return -1; // seat already taken
                    }
                }
            }

            // 2) Insert into tblBill
            String insertBillSql = "INSERT INTO tblBill (pointEx, tblCustomerid, total_price) VALUES (?, ?, ?)";
            float totalPrice = 0f;
            for (Ticket t : tickets) totalPrice += t.getPrice();
            int billId = -1;
            try (PreparedStatement psBill = conn.prepareStatement(insertBillSql, Statement.RETURN_GENERATED_KEYS)) {
                psBill.setFloat(1, offlineBill.getPointEx());
                if (offlineBill.getCustomer() != null) psBill.setInt(2, offlineBill.getCustomer().getId()); else psBill.setNull(2, java.sql.Types.INTEGER);
                psBill.setFloat(3, totalPrice);
                psBill.executeUpdate();
                try (ResultSet keys = psBill.getGeneratedKeys()) {
                    if (keys.next()) billId = keys.getInt(1);
                    else { conn.rollback(); return -1; }
                }
            }

            // 3) Insert into tblOfflineBill
            String insertOfflineSql = "INSERT INTO tblOfflineBill (tblBillid, tblTicketClerkid) VALUES (?, ?)";
            try (PreparedStatement psOff = conn.prepareStatement(insertOfflineSql)) {
                psOff.setInt(1, billId);
                psOff.setInt(2, clerkId);
                psOff.executeUpdate();
            }

            // 4) Insert tickets
            String insertTicketSql = "INSERT INTO tblTicket (price, tblBillid, tblSeatScheduleid) VALUES (?, ?, ?)";
            try (PreparedStatement psTick = conn.prepareStatement(insertTicketSql)) {
                for (Ticket t : tickets) {
                    psTick.setFloat(1, t.getPrice());
                    psTick.setInt(2, billId);
                    psTick.setInt(3, t.getSeatSchedule().getId());
                    psTick.executeUpdate();
                }
            }

            conn.commit();
            return billId;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            return -1;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) { e.printStackTrace(); }
        }
    }

}