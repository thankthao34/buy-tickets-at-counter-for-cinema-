package model;

public class Customer extends User {
    public Customer() {
        super();
    }
    public Customer(int id, String fullName, java.util.Date birthday, String gender, String phone, String email, String username, String password, String role) {
        super(id, fullName, birthday, gender, phone, email, username, password, role);
    }
}
