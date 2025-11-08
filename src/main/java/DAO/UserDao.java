/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import model.User;

/**
 * User DAO - provides user-related DB operations
 */
public class UserDao extends DAO {

	public UserDao() {
		super();
	}

	public User checkLogin(String username, String password) {
		String sql = "SELECT * FROM tblUser WHERE username = ? AND password = ?";
		try (PreparedStatement ps = connection.prepareStatement(sql)) {
			ps.setString(1, username);
			ps.setString(2, password);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					User u = new User();
					u.setId(rs.getInt("id"));
					u.setFullName(rs.getString("fullName"));
					Date bd = rs.getDate("birthday");
					if (bd != null) u.setBirthday(new java.util.Date(bd.getTime()));
					u.setGender(rs.getString("gender"));
					u.setPhone(rs.getString("phone"));
					u.setEmail(rs.getString("email"));
					u.setUsername(rs.getString("username"));
					u.setPassword(rs.getString("password"));
					u.setRole(rs.getString("role"));
					return u;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

}
