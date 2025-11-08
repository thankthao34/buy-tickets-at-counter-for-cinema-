package DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import model.TicketClerk;

public class DAO {
    protected Connection connection;

    public DAO() {
        try {
            // Thay đổi thông tin kết nối CSDL của bạn ở đây
            String dbUrl = "jdbc:mysql://localhost:3306/cinema_db"; // Thay 'Pttkcinema' bằng tên database của bạn
            String dbUser = "root";
            String dbPassword = "131280"; // Thay bằng mật khẩu của bạn
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Cannot connect to the database");
        }
    }
}