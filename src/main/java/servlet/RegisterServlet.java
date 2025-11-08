package servlet;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import DAO.CustomerDao;
import model.Customer;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 2) Login.jsp gọi lớp RegisterServlet.
        // 3) RegisterServlet gọi sang trang Register.jsp
        req.getRequestDispatcher("/Register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 7) RegisterServlet gọi phương thức doPost().
        req.setCharacterEncoding("UTF-8");
        String fullName = req.getParameter("fullName");
        String birthdayStr = req.getParameter("birthday");
        String gender = req.getParameter("gender");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm");
        String agree = req.getParameter("agree");

        // Basic validation
        String error = null;
        if (fullName == null || fullName.trim().isEmpty()
                || birthdayStr == null || birthdayStr.trim().isEmpty()
                || gender == null || gender.trim().isEmpty()
                || phone == null || phone.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || confirm == null || confirm.trim().isEmpty()) {
            error = "Vui lòng nhập đầy đủ thông tin.";
        } else if (!password.equals(confirm)) {
            error = "Mật khẩu và xác nhận mật khẩu không khớp.";
        } else if (agree == null) {
            error = "Bạn phải đồng ý với điều khoản.";
        }
        // Kiểm tra độ tuổi: phải >= 13
        java.util.Date parsedBirthday = null;
        if (error == null) {
            try {
                SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
                fmt.setLenient(false);
                parsedBirthday = fmt.parse(birthdayStr);
                // compute age
                java.util.Calendar birth = java.util.Calendar.getInstance();
                birth.setTime(parsedBirthday);
                java.util.Calendar today = java.util.Calendar.getInstance();
                int age = today.get(java.util.Calendar.YEAR) - birth.get(java.util.Calendar.YEAR);
                // If birthday hasn't occurred yet this year, subtract one
                int todayDayOfYear = today.get(java.util.Calendar.DAY_OF_YEAR);
                int birthDayOfYear = birth.get(java.util.Calendar.DAY_OF_YEAR);
                if (todayDayOfYear < birthDayOfYear) {
                    age--;
                }
                if (age < 13) {
                    error = "Bạn phải từ 13 tuổi trở lên để đăng ký.";
                }
            } catch (ParseException e) {
                error = "Ngày sinh không hợp lệ.";
            }
        }

        if (error != null) {
            req.setAttribute("error", error);
            // preserve form values
            req.setAttribute("fullName", fullName);
            req.setAttribute("birthday", birthdayStr);
            req.setAttribute("gender", gender);
            req.setAttribute("phone", phone);
            req.setAttribute("email", email);
            req.setAttribute("username", username);
            req.getRequestDispatcher("/Register.jsp").forward(req, resp);
            return;
        }

        // 8) phương thức doPost() gọi Customer để đóng gói thông tin thực thể.
        Customer customer = new Customer();
        customer.setFullName(fullName);
        // Use parsedBirthday from earlier validation (guaranteed non-null here)
        customer.setBirthday(parsedBirthday);
        customer.setGender(gender);
        customer.setPhone(phone);
        customer.setEmail(email);
        customer.setUsername(username);
        customer.setPassword(password);
        customer.setRole("CUSTOMER");

        // 11) doPost() gọi CustomerDao
        CustomerDao dao = new CustomerDao();
        boolean saved = dao.saveCustomer(customer);

        if (saved) {
            // 14) RegisterServlet trả về cho Register.jsp
            req.setAttribute("success", "Đăng ký thành công. Bạn sẽ được chuyển đến trang đăng nhập...");
            // For user experience, forward to Register.jsp where page will redirect to login
            req.getRequestDispatcher("/Register.jsp").forward(req, resp);
        } else {
            req.setAttribute("error", "Đăng ký thất bại, vui lòng thử lại (username/email có thể đã tồn tại).\n");
            req.getRequestDispatcher("/Register.jsp").forward(req, resp);
        }
    }
}
