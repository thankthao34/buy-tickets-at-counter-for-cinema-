package DAO;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;

import model.Customer;

public class CustomerDao extends DAO {

    public CustomerDao() {
        super();
    }

    public String saveCustomer(Customer customer) {
        try {
            boolean previousAutoCommit = connection.getAutoCommit();
            try {
                connection.setAutoCommit(false);
            } catch (Exception ignore) {}
            // Insert into tblUser
            String sql = "INSERT INTO tblUser (fullName, birthday, gender, phone, email, username, password, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, customer.getFullName());
            if (customer.getBirthday() != null) {
                ps.setDate(2, new java.sql.Date(customer.getBirthday().getTime()));
            } else {
                ps.setNull(2, Types.DATE);
            }
            ps.setString(3, customer.getGender());
            ps.setString(4, customer.getPhone());
            ps.setString(5, customer.getEmail());
            ps.setString(6, customer.getUsername());
            ps.setString(7, customer.getPassword());
            ps.setString(8, customer.getRole());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                return null;
            }

            // get generated id
            ResultSet rs = ps.getGeneratedKeys();
            int id = -1;
            if (rs.next()) {
                id = rs.getInt(1);
            }
            rs.close();
            ps.close();

            if (id == -1) {
                return null;
            }

            // Insert into tblCustomer (link table)
            String sql2 = "INSERT INTO tblCustomer (tbluserId) VALUES (?)";
            PreparedStatement ps2 = connection.prepareStatement(sql2);
            ps2.setInt(1, id);
            ps2.executeUpdate();
            ps2.close();

            java.util.Random rnd = new java.util.Random();
            String cardNumber = null;
            boolean inserted = false;
            int attempts = 0;
            while (!inserted && attempts < 6) {
                attempts++;
                long num = Math.abs(rnd.nextLong()) % 10000000000L; // 0 .. 10^10-1
                cardNumber = String.format("%010d", num);
                try {
                    String sql3 = "INSERT INTO tblMembershipCard (cardNumber, tblCustomer_tblUserid) VALUES (?, ?)";
                    PreparedStatement ps3 = connection.prepareStatement(sql3);
                    ps3.setString(1, cardNumber);
                    ps3.setInt(2, id);
                    ps3.executeUpdate();
                    ps3.close();
                    inserted = true;
                } catch (java.sql.SQLException ex) {
                    String state = ex.getSQLState();
                    int err = ex.getErrorCode();

                    System.err.println("Membership card insert failed (attempt " + attempts + "): " + ex.getMessage());
                    try { Thread.sleep(30); } catch (InterruptedException ie) { }
                }
            }

            if (!inserted) {
                return null;
            }

            try {
                connection.commit();
            } catch (Exception commitEx) { System.err.println("Commit failed: " + commitEx.getMessage()); }
            try { connection.setAutoCommit(previousAutoCommit); } catch (Exception ignore) {}
            return cardNumber;
        } catch (Exception e) {
            e.printStackTrace();
            try { connection.rollback(); } catch (Exception rb) {}
            try { connection.setAutoCommit(true); } catch (Exception ignore) {}
            return null;
        }
    }
}
