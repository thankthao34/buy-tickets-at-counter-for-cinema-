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
    
    <!-- Lồng CSS vào HTML (Sao chép 100% từ Seatmap.jsp + Thêm style mới) -->
    <style>
        /* --- CSS Variables (Từ Schedule.jsp) --- */
        :root {
            --font-primary: 'Inter', 'Poppins', sans-serif;
            --color-primary: #2F3C7E;
            --color-accent: #FBEAEB;
            --color-text: #0F172A;
            --color-bg: #FFFFFF;
            
            --system-accent: var(--color-primary); 
            
            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 16px;
            --spacing-lg: 24px;
            --spacing-xl: 32px;

            --radius-lg: 20px;

            --shadow-soft: 0 10px 25px -5px rgba(0, 0, 0, 0.07), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            --shadow-medium: 0 4px 10px rgba(0, 0, 0, 0.1);
            --shadow-focus: 0 0 0 3px rgba(47, 60, 126, 0.3);

            --transition-duration: 200ms;
        }

        /* --- Global Reset & Base (Từ Schedule.jsp) --- */
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        html, body { height: 100%; }
        body {
            font-family: var(--font-primary);
            background-color: var(--color-text);
            color: var(--color-text);
            line-height: 1.6;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* --- Lớp phủ và Ảnh nền (Từ Schedule.jsp) --- */
        body::before {
            content: '';
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background-image: url('<%=request.getContextPath()%>/assets/img/BG.png');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            z-index: -2;
        }
        body::after {
            content: '';
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: -1;
        }

        /* --- Header (Từ Schedule.jsp) --- */
        .main-header {
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 100;
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
            padding: var(--spacing-md) var(--spacing-xl);
            background-color: var(--color-bg);
            transition: padding var(--transition-duration) ease, 
                        box-shadow var(--transition-duration) ease,
                        background-color var(--transition-duration) ease;
        }
            .main-header.scrolled { padding: var(--spacing-sm) var(--spacing-xl); box-shadow: var(--shadow-medium); }
        .header-logo {
            font-size: 1.7rem;
            font-weight: 700;
            color: var(--color-primary);
            text-decoration: none;
            grid-column: 2 / 3;
            justify-self: center;
        }
        .header-user {
            font-size: 0.95rem;
            color: var(--color-text);
            grid-column: 3 / 4;
            justify-self: end;
            display: flex;
            align-items: center;
        }
        .header-user span { font-weight: 600; }
        .logout-form { display: inline; margin: 0; padding: 0; }
        .logout-button {
            background: none; border: none; padding: 0; margin: 0;
            font: inherit; cursor: pointer; color: var(--color-primary);
            text-decoration: none; font-weight: 600;
            margin-left: var(--spacing-sm);
        }
        .logout-button:hover { text-decoration: underline; }

        /* --- Main Content (Từ Schedule.jsp) --- */
        .main-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            width: 100%;
            padding: var(--spacing-xl);
            padding-top: 120px;
            padding-bottom: 60px; /* Bỏ padding-bottom cho footer dính */
        }
        
        /* Card kính mờ (Từ Schedule.jsp) */
        .content-card {
            width: 100%;
            max-width: 1100px; /* [THAY ĐỔI] Giảm độ rộng cho trang tóm tắt */
            background-color: rgba(255,255,255,0.12);
            border-radius: var(--radius-lg);
            padding: calc(var(--spacing-lg) + 8px) calc(var(--spacing-lg) + 8px);
            box-shadow: 0 14px 36px rgba(2,6,23,0.55);
            margin: calc(var(--spacing-md) / 2) 0;
            border: 1px solid rgba(255,255,255,0.08);
            backdrop-filter: blur(12px) saturate(120%);
            -webkit-backdrop-filter: blur(12px) saturate(120%);
            color: #ffffff;
        }

        /* Unified page title sizing */
        .card-title {
            color: #ffffff;
            font-size: 1.7rem;
            font-weight: 700;
            margin-bottom: var(--spacing-lg);
            position: relative;
            padding-bottom: var(--spacing-sm);
            text-align: center;
        }
        /* .card-subtitle (Không dùng) */

        /* --- Nút bấm (Từ Schedule.jsp) --- */
        .btn {
            display: inline-flex; align-items: center; justify-content: center;
            height: 48px; padding: 0 var(--spacing-lg);
            border-radius: 12px; font-weight: 600; font-size: 1rem;
            text-decoration: none; border: 2px solid transparent;
            cursor: pointer; transition: all var(--transition-duration) ease;
        }
        .btn-primary {
            background-color: var(--color-primary);
            color: var(--color-bg);
            border-color: var(--color-primary);
        }
        .btn-secondary {
            background-color: var(--color-bg);
            color: var(--color-primary);
            border-color: var(--color-primary);
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }
        .btn:focus-visible {
            outline: none; box-shadow: var(--shadow-focus);
        }
        
        /* [THÊM] Các style nút từ Seatmap.jsp */
        .btn-secondary.ghost {
            background: transparent;
            color: #ffffff;
            border-color: #ffffff;
        }
        .btn-secondary.ghost:hover {
            background: rgba(255,255,255,0.1);
            color: #ffffff;
        }
        /* Ensure continue/primary actions use site primary color */
        .btn-primary.continue {
            background-color: var(--color-primary);
            border-color: var(--color-primary);
            color: var(--color-bg);
        }
        .btn-primary.continue:hover {
            filter: brightness(0.92);
        }

        /* --- [MỚI] Style cho trang Tổng hợp --- */
        .summary-grid {
            display: grid;
            grid-template-columns: 2fr 1fr; /* 2 cột: Chi tiết | Tổng tiền */
            gap: var(--spacing-xl);
        }
        
        .summary-details h3,
        .summary-action h3 {
            font-family: "Poppins", var(--font-primary);
            color: #ffffff;
            font-size: 1.25rem; /* 20px */
            margin-bottom: var(--spacing-sm);
            border-bottom: 2px solid rgba(255,255,255,0.1);
            padding-bottom: var(--spacing-base);
        }
        
        .summary-details p {
            font-size: 1rem;
            color: rgba(255,255,255,0.9);
            margin-bottom: var(--spacing-sm);
        }
        .summary-details p strong { color: #ffffff; }

        .summary-details h4 {
            font-size: 1rem;
            color: #ffffff;
            margin-top: var(--spacing-lg);
            margin-bottom: var(--spacing-sm);
        }

        .bill-seat-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: var(--spacing-sm);
        }
        .bill-seat-list li {
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 8px;
            padding: var(--spacing-sm) var(--spacing-md);
            font-weight: 600;
        }
        
        .summary-action {
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            border: 1px solid rgba(255,255,255,0.04);
            border-radius: 12px;
            padding: var(--spacing-lg);
            align-self: flex-start; /* Dính lên trên */
        }
        
        .total-price-display {
            font-size: 2.5rem; /* 40px */
            font-weight: 700;
            color: #ffffff;
            text-align: center;
            margin: var(--spacing-md) 0 var(--spacing-lg) 0;
        }

        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-md);
            margin-top: var(--spacing-lg);
        }
        .action-buttons .btn,
        .action-buttons form {
            width: 100%;
            margin: 0;
        }
        .action-buttons .btn {
            width: 100%; /* Nút chiếm 100% */
        }

        /* --- Alert (Thông báo) --- */
        /* Style này đã có trong CSS của Schedule/Seatmap nhưng ta định nghĩa lại */
        .alert{
            padding: var(--spacing-md);
            border-radius: 12px;
            font-weight: 600;
            margin: var(--spacing-lg) 0 0 0;
            text-align: center;
        }
        /* Lỗi (Nền trắng, chữ đỏ) */
        .alert.error { 
            background: #FEE2E2; 
            color: #991B1B; 
            border: 1px solid #FCA5A5; 
        }
        /* Thành công (Nền trắng, chữ xanh) */
        .alert.success { 
            background: #D1FAE5; 
            color: #065F46; 
            border: 1px solid #6EE7B7; 
        }

        /* --- Responsive (Di động) --- */
        @media (max-width: 768px) {
            .main-header { padding: var(--spacing-md) var(--spacing-lg); }
            .main-header.scrolled { padding: var(--spacing-sm) var(--spacing-lg); }
            .header-logo { font-size: 1.7rem; }
            .header-user { font-size: 0.85rem; }

            .main-content {
                padding: var(--spacing-lg);
                padding-top: 100px;
            }

            .content-card {
                padding: var(--spacing-lg) var(--spacing-md);
            }

            .card-title { font-size: 1.4rem; }

            /* [MỚI] Responsive cho trang tổng hợp */
            .summary-grid {
                grid-template-columns: 1fr; /* 1 cột */
            }
            .summary-action {
                margin-top: var(--spacing-lg);
            }
            .total-price-display {
                font-size: 2rem;
            }
        }
    </style>
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