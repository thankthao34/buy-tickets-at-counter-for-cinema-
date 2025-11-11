<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.SeatSchedule" %>
<%@ page import="model.User" %>
<%@ page import="model.Movie" %>
<%@ page import="model.Schedule" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // --- Lấy dữ liệu (Logic JSP) ---
    User user = (User) session.getAttribute("user");
    if (user == null) { 
        response.sendRedirect(request.getContextPath()+"/Login.jsp"); 
        return; 
    }

    Movie movie = (Movie) session.getAttribute("currentMovie");
    Schedule schedule = (Schedule) session.getAttribute("currentSchedule");
    List<SeatSchedule> seats = (List<SeatSchedule>) session.getAttribute("selectedSeats");
    Double total = (Double) session.getAttribute("cartTotal");
    if (seats == null) seats = new java.util.ArrayList<>();
    if (total == null) total = 0.0;
    
    // --- Lấy Lỗi/Thành công (Logic JSP) ---
    String bookingError = (String) session.getAttribute("bookingError");
    if (bookingError != null) {
        session.removeAttribute("bookingError");
    }
    Boolean finalizeSuccess = (Boolean) request.getAttribute("finalizeSuccess");

    // --- Prepare display time/date (use schedule.date if present, otherwise today's date) ---
    String showDateStr = new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
    String timeStr = "--:--";
    if (schedule != null) {
        // use schedule.startTime for time if available
        if (schedule.getStartTime() != null) {
            timeStr = new SimpleDateFormat("HH:mm").format(schedule.getStartTime());
        }
        // use schedule.date for the date display if available
        if (schedule.getDate() != null) {
            showDateStr = new SimpleDateFormat("dd/MM/yyyy").format(schedule.getDate());
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng hợp đơn hàng - Hệ thống Cinema</title>
    
    <!-- Tải fonts Inter và Poppins -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    
    <!-- External stylesheet for TicketnBill page -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/ticketnbill.css" />
    <!-- Provide background image path to external CSS via CSS variable -->
    <style> :root { --bg-image: url('<%=request.getContextPath()%>/assets/img/BG.png'); } </style>
</head>
<body>

    <!-- Header (Giống các trang khác) -->
    <header class="main-header" id="mainHeader">
        <a href="<%=request.getContextPath()%>/mainSeller" class="header-logo">
            Hệ thống Cinema
        </a>
        <div class="header-user">
            <span>Xin chào, <strong><%= user.getUsername() %></strong></span>
            <form action="<%=request.getContextPath()%>/login" method="post" class="logout-form">
                <button class="logout-button" type="submit">Đăng xuất</button>
            </form>
        </div>
    </header>

    <!-- Nội dung chính -->
    <main class="main-content">
        
        <!-- Card kính mờ -->
        <div class="content-card">
            
            <h1 class="card-title">Tổng hợp đơn hàng</h1>

            <!-- Lưới 2 cột -->
            <div class="summary-grid">

                <!-- Cột 1: Chi tiết -->
                <div class="summary-details">
                    <h3>Chi tiết vé</h3>
                    <p><strong>Phim:</strong> <%= movie != null ? movie.getName() : "-" %></p>
                    <p><strong>Suất:</strong> <%= timeStr %>, <%= showDateStr %></p>
                    <p><strong>Phòng:</strong> <%= schedule!=null && schedule.getRoom()!=null ? schedule.getRoom().getName() : "-" %></p>

                    <h4>Ghế đã chọn (<%= seats.size() %>)</h4>
                    <ul class="bill-seat-list">
                        <% for (SeatSchedule ss : seats) { %>
                            <li><%= ss.getSeat()!=null ? ss.getSeat().getName() : ("#"+ss.getId()) %> - <%= String.format("%,.0f", (schedule!=null? schedule.getBasePrice()* (ss.getSeat()!=null? ss.getSeat().getPriceMultiplier():1.0) : 0)) %> VND</li>
                        <% } %>
                    </ul>
                </div>

                <!-- Cột 2: Tổng tiền và Hành động -->
                <aside class="summary-action">
                    <h3>Tổng cộng</h3>
                    <div class="total-price-display">
                        <%= String.format("%,.0f", total) %> VND
                    </div>

                    <%-- Kiểm tra lỗi (Nền trắng, chữ đỏ) --%>
                    <% if (bookingError != null) { %>
                        <div class="alert error" style="margin-top: 0; margin-bottom: var(--spacing-md); background: #FEE2E2; color: #991B1B;">
                            <%= bookingError %>
                        </div>
                    <% } %>

                    <%-- Kiểm tra thành công --%>
                    <% if (finalizeSuccess != null && finalizeSuccess) { %>
                        <div class="alert success" style="margin-top: 0; background: #D1FAE5; color: #065F46;">
                            Lưu hóa đơn thành công. <br> Mã hóa đơn: <strong><%= request.getAttribute("billId") %></strong>
                        </div>
                        <div class="action-buttons">
                            <a class="btn btn-primary continue" href="<%=request.getContextPath()%>/searchMovie">Trở về Trang bán vé</a>
                            <%-- Print button opens printable invoice in new tab --%>
                            <a class="btn btn-secondary" target="_blank" href="<%=request.getContextPath()%>/print?billId=<%= request.getAttribute("billId") %>">In hóa đơn</a>
                        </div>
                    <% } else { %>
                        <%-- Nút hành động --%>
                        <div class="action-buttons">
                            <form action="<%=request.getContextPath()%>/ticketnBill" method="post">
                                <button class="btn btn-primary continue" type="submit">Xác nhận và lập hóa đơn</button>
                            </form>
                            
                            <form action="<%=request.getContextPath()%>/seatmap" method="get">
                                <input type="hidden" name="scheduleId" value="<%= schedule != null ? schedule.getId() : "" %>" />
                                <button class="btn btn-secondary ghost" type="submit">Quay lại chọn ghế</button>
                            </form>
                        </div>
                    <% } %>

                </aside>

            </div> <!-- end .summary-grid -->
            
        </div> <!-- end .content-card -->
    </main>

    <!-- JavaScript cho Header Scroll (Giống các trang khác) -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const header = document.getElementById('mainHeader');
            if (header) {
                window.addEventListener('scroll', () => {
                    if (window.scrollY > 30) {
                        header.classList.add('scrolled');
                    } else {
                        header.classList.remove('scrolled');
                    }
                });
            }
        });
    </script>

</body>
</html>