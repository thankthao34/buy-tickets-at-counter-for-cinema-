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

    /**
     * 12) CustomerDao gọi phương thức saveCustomer (Customer customer) thực hiện lưu thông tin khách vào csdl.
     * Returns true on success, false otherwise.
     */
    public boolean saveCustomer(Customer customer) {
        try {
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
                return false;
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
                return false;
            }

            // Insert into tblCustomer (link table)
            String sql2 = "INSERT INTO tblCustomer (tbluserId) VALUES (?)";
            PreparedStatement ps2 = connection.prepareStatement(sql2);
            ps2.setInt(1, id);
            ps2.executeUpdate();
            ps2.close();

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
