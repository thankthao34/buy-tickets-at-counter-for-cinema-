package model;

public class Employee extends User {
    private String position;
    private float salary;

    public Employee() {
        super();
    }

    public Employee(int id, String fullName, java.util.Date birthday, String gender, String phone, String email, String username, String password, String role, String position, float salary) {
        super(id, fullName, birthday, gender, phone, email, username, password, role);
        this.position = position;
        this.salary = salary;
    }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    public float getSalary() { return salary; }
    public void setSalary(float salary) { this.salary = salary; }
}
