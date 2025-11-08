package model;

public class TicketClerk extends User {
    private String code;
    private float kpi;

    public TicketClerk() {
        super();
    }

    public TicketClerk(int id, String fullName, java.util.Date birthday, String gender, String phone, String email, String username, String password, String role, String code, float kpi) {
        super(id, fullName, birthday, gender, phone, email, username, password, role);
        this.code = code;
        this.kpi = kpi;
    }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public float getKpi() { return kpi; }
    public void setKpi(float kpi) { this.kpi = kpi; }
}
