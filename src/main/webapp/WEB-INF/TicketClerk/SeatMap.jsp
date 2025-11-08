<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.TreeMap" %>
<%@ page import="model.SeatSchedule" %>
<%@ page import="model.Schedule" %>
<%@ page import="model.Movie" %>
<%@ page import="model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // --- Lấy dữ liệu (Logic JSP) ---
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/Login.jsp");
        return;
    }

    List seats = (List) request.getAttribute("seats");
    Schedule schedule = (Schedule) request.getAttribute("schedule");
    Movie movie = (Movie) request.getAttribute("movie");
    if (movie == null && schedule != null && schedule.getMovie() != null) {
        movie = schedule.getMovie();
    }
    Integer allowedMin = (Integer) request.getAttribute("allowedMin");
    Integer allowedMax = (Integer) request.getAttribute("allowedMax");

    // --- Xây dựng lưới ghế (Logic JSP) ---
    Map<String, Map<Integer, SeatSchedule>> grid = new TreeMap<>();
    int maxCol = 0;
    if (seats != null) {
        for (Object o : seats) {
            SeatSchedule ss = (SeatSchedule) o;
            String name = (ss.getSeat() != null && ss.getSeat().getName() != null) ? ss.getSeat().getName().trim() : "";
            
            String row = "";
            String colStr = "";
            for (int i = 0; i < name.length(); i++) {
                char c = name.charAt(i);
                if (Character.isDigit(c)) colStr += c; else row += Character.toUpperCase(c);
            }
            
            int col = 0;
            try { col = Integer.parseInt(colStr); } catch (Exception ex) { col = 0; }
            if (col > maxCol) maxCol = col;
            
            Map<Integer, SeatSchedule> rowMap = grid.get(row);
            if (rowMap == null) { rowMap = new TreeMap<>(); grid.put(row, rowMap); }
            rowMap.put(col, ss);
        }
    }
    
    // --- Lấy lỗi (Logic JSP) ---
    String bookingError = (String) session.getAttribute("bookingError");
    if (bookingError != null) {
        session.removeAttribute("bookingError");
    }
    
    // --- Tính giá vé (Logic JSP) ---
    double basePrice = (schedule != null) ? schedule.getBasePrice() : 0;
    double vipPrice = basePrice * 1.2; // Giả sử ghế VIP là 1.2
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn ghế - <%= movie != null ? movie.getName() : "Phim" %></title>
    
    <!-- Tải fonts Inter và Poppins -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    
    <!-- Lồng CSS vào HTML (Từ Schedule.jsp VÀ Seatmap.jsp) -->
    <style>
        /* --- CSS Variables (Từ Schedule.jsp) --- */
        :root {
            --font-primary: 'Inter', 'Poppins', sans-serif;
            --color-primary: #2F3C7E;
            --color-accent: #FBEAEB;
            --color-text: #0F172A;
            --color-bg: #FFFFFF;
            
            /* [MỚI] Thêm màu cho ghế VIP (Vàng Gold) - Sẽ không dùng cho ghế trống */
            /* --color-vip: #D4AF37; */ 
            --color-danger: #e11d48; /* Màu đỏ cho ghế đã đặt */

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
            line-height: 1.55; /* Siết dòng */
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

        /* --- Header (Từ Schedule.jsp - Đã siết) --- */
        .main-header {
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 100;
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
            padding: var(--spacing-md) var(--spacing-xl); /* Siết */
            background-color: var(--color-bg);
            transition: padding var(--transition-duration) ease, 
                        box-shadow var(--transition-duration) ease,
                        background-color var(--transition-duration) ease;
        }
        .main-header.scrolled {
            padding: var(--spacing-sm) var(--spacing-xl); /* Siết */
            box-shadow: var(--shadow-medium);
        }
        .header-logo {
            font-size: 1.25rem;
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

        /* --- Main Content (Từ Schedule.jsp - Đã siết) --- */
        .main-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            width: 100%;
            padding: var(--spacing-lg); /* Siết */
            padding-top: 100px; /* Siết */
            padding-bottom: 140px; /* Chỗ cho sticky footer */
        }
        
        /* Card kính mờ (Từ Schedule.jsp) */
        .content-card {
            width: 100%;
            max-width: 1440px; /* Rộng cho sơ đồ ghế */
            background-color: rgba(255,255,255,0.12);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg); /* Siết */
            box-shadow: 0 14px 36px rgba(2,6,23,0.55);
            margin: 0;
            border: 1px solid rgba(255,255,255,0.08);
            backdrop-filter: blur(12px) saturate(120%);
            -webkit-backdrop-filter: blur(12px) saturate(120%);
            color: #ffffff;
        }

        /* Tiêu đề (Từ Schedule.jsp - Đã siết) */
        .card-title {
            color: #ffffff;
            font-size: 1.5rem; /* Siết */
            font-weight: 700;
            margin-bottom: var(--spacing-xs); /* Siết */
            position: relative;
            padding-bottom: 0;
            text-align: center;
        }
        .card-subtitle {
            text-align: center;
            font-size: 1.1rem; /* Siết */
            font-weight: 600;
            color: #ffffff;
            margin-top: 0;
            margin-bottom: var(--spacing-lg); /* Siết */
        }

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
        
        /* --- Style cho Sơ đồ ghế (Đã chỉnh sửa) --- */
        .seatmap-layout {
            display: flex;
            flex-wrap: wrap;
            gap: var(--spacing-lg);
        }
        .seat-area {
            flex: 3;
            min-width: 400px;
            overflow-x: auto;
            
            /* Nền trắng cho khu vực chọn ghế */
            background: #ffffff;
            color: var(--color-text);
            padding: var(--spacing-md); /* Siết */
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(2,6,23,0.35);
        }
        .seat-summary {
            flex: 1;
            min-width: 280px;
            /* Nền mờ cho tóm tắt */
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            border: 1px solid rgba(255,255,255,0.04);
            border-radius: 12px;
            padding: var(--spacing-md);
            align-self: flex-start;
        }
        .seat-summary h3 {
            color: #ffffff;
            font-size: 1.1rem; /* Siết */
            margin-bottom: var(--spacing-sm);
            border-bottom: 2px solid rgba(255,255,255,0.1);
            padding-bottom: var(--spacing-sm); /* Siết */
        }
        .seat-summary p {
            font-size: 0.9rem; /* Siết */
            color: rgba(255,255,255,0.9);
            margin-bottom: var(--spacing-xs); /* Siết */
        }
        .seat-summary p strong { color: #ffffff; }
        .seat-summary hr {
            border: 0; height: 1px;
            background-color: rgba(255,255,255,0.1);
            margin: var(--spacing-sm) 0;
        }
        .seat-list { list-style: none; max-height: 200px; overflow-y: auto; }
        .seat-list li {
            font-size: 0.9rem; /* Siết */
            font-weight: 600;
            color: #ffffff;
            margin-bottom: var(--spacing-xs); /* Siết */
        }
        .seat-list li:empty { display: none; }
        .seat-list-placeholder {
            font-size: 0.9rem; /* Siết */
            color: rgba(255,255,255,0.7);
        }

        /* Sơ đồ ghế */
        .seat-screen {
            width: 100%;
            padding: 8px 0;
            margin-bottom: 10px;
            text-align: center;
            font-weight: 600; font-size: 14px;
            color: var(--color-text);
            border: 1px solid rgba(15,23,42,0.08);
            border-radius: 6px;
        }
        .seat-grid-container { text-align: center; }
        .seat-grid { border-collapse: collapse; display: inline-block; }
        .seat-grid th, .seat-grid td {
            text-align: center; vertical-align: middle;
            font-weight: 600;
            color: var(--color-text);
            width: 44px; height: 44px;
            padding: 2px;
        }
        .seat-grid th { font-size: 12px; }

        /* Icon Ghế (SVG) */
        .seat { display: inline-block; cursor: pointer; border: none; background: none; padding: 0; transition: transform 100ms ease; }
        .seat svg { width: 36px; height: 36px; transition: fill 200ms ease; }
        
        /* --- [THAY ĐỔI] Màu ghế (VIP) --- */
        /* Cả ghế thường và ghế VIP (available) đều là màu xám */
        .seat.available svg { 
            fill: #6b7280; /* Thường: Xám */
        }
        .seat.available:hover svg { 
            fill: #374151; 
        }
        
        /* Bỏ class .vip riêng cho màu vàng */
        /* .seat.available.vip svg { fill: var(--color-vip); } */
        /* .seat.available.vip:hover svg { fill: #b8860b; } */
        
        .seat.booked svg, .seat:disabled svg {
            fill: var(--color-danger); opacity: 0.9; cursor: not-allowed;
        }
        .seat.blocked svg, .seat:disabled.blocked svg {
            fill: #78909c; opacity: 0.7; cursor: not-allowed;
        }
        .seat.selected svg {
            fill: var(--color-primary); /* Đang chọn: Xanh */
        }
        .seat-checkbox { display: none; }

        /* Chú thích */
        .seat-legend {
            display: flex; flex-wrap: wrap; justify-content: center;
            gap: var(--spacing-md); margin-top: var(--spacing-lg);
            font-size: 12px;
            color: var(--color-text);
        }
        .seat-legend .item { display: flex; align-items: center; gap: var(--spacing-sm); }
        .seat-legend .box { width: 20px; height: 20px; border-radius: 4px; }
        .seat-legend .box svg { width: 100%; height: 100%; }

        /* Chú thích giá */
        .price-legend {
            text-align: center;
            margin-top: var(--spacing-md);
            font-size: 0.85rem;
            color: #4b5563; /* Xám đậm trên nền trắng */
        }
        .price-legend span {
            margin: 0 var(--spacing-sm);
            font-weight: 600;
        }

        /* --- Thanh Footer Cố định (WOW) --- */
        .sticky-footer-bar {
            position: fixed;
            bottom: 0; left: 0; right: 0;
            z-index: 40;
            /* Kính mờ */
            background-color: rgba(0,0,0,0.4);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            padding: var(--spacing-md) var(--spacing-lg);
            box-shadow: 0 -5px 20px rgba(0, 0, 0, 0.2);
            border-top: 1px solid rgba(255,255,255,0.1);
        }
        .footer-content {
            display: flex; align-items: center; justify-content: space-between;
            max-width: 1440px; margin: 0 auto;
        }
        .footer-right { display: flex; align-items: center; gap: var(--spacing-lg); }
        .footer-total { text-align: right; }
        .footer-total .label {
            font-size: 14px;
            color: rgba(255,255,255,0.8);
        }
        .footer-total .price {
            font-size: 20px; font-weight: 700;
            color: #ffffff;
        }
        .btn-secondary.ghost {
            background: transparent;
            color: #ffffff;
            border-color: #ffffff;
        }
        .btn-secondary.ghost:hover {
            background: rgba(255,255,255,0.1);
            color: #ffffff;
        }
        .btn-primary.continue {
            background-color: var(--color-primary); /* use site primary (#2F3C7E) */
            border-color: var(--color-primary);
        }
        .btn-primary.continue:hover {
            filter: brightness(0.95);
        }

        /* Membership input (refined) */
        .member-input-group { margin-top: 12px; }
        .member-input-group label { display:block; font-size:0.9rem; color: rgba(255,255,255,0.9); margin-bottom:6px; font-weight:600; }
        .member-input-group .member-row { display:flex; gap:8px; align-items:center; }
        .member-input-group input[type="text"] {
            flex: 1;
            padding: 10px 12px;
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.08);
            background: rgba(255,255,255,0.03);
            color: #ffffff;
            font-size: 0.95rem;
            box-shadow: inset 0 1px 2px rgba(0,0,0,0.25);
        }
        .member-input-group input[type="text"]::placeholder { color: rgba(255,255,255,0.55); }
        .member-input-group input[type="text"]:focus { outline: none; box-shadow: 0 0 0 3px rgba(47,60,126,0.12); border-color: var(--color-primary); }
        .member-input-group small { display:block; margin-top:6px; color: rgba(255,255,255,0.65); font-size: 0.8rem; }

        /* Confirm button (small, subtle) */
        .btn-confirm {
            background-color: transparent;
            border: 1px solid rgba(255,255,255,0.12);
            color: #ffffff;
            padding: 6px 10px;
            border-radius: 8px;
            height: 36px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            min-width: 72px;
        }
        .btn-confirm.member-saved {
            background-color: var(--color-primary);
            border-color: var(--color-primary);
            color: #ffffff;
        }
        .btn-confirm:hover { filter: brightness(0.95); }

        /* Thông báo lỗi */
        .alert {
            padding: var(--spacing-md); border-radius: 12px;
            font-weight: 600; margin-bottom: var(--spacing-lg);
            color: var(--color-text); /* Chữ đen/đậm */
        }
        .alert.error { 
            background: #FEE2E2; 
            color: #991B1B; 
            border: 1px solid #FCA5A5; 
        }

        /* --- Responsive (Di động) --- */
        @media (max-width: 768px) {
            .main-content {
                padding: var(--spacing-sm); /* Siết */
                padding-top: 80px; /* Siết */
                padding-bottom: 160px; /* Tăng chỗ cho footer mobile */
            }
            .content-card {
                padding: var(--spacing-md); /* Siết */
            }
            .card-title { font-size: 1.1rem; } /* Siết */
            .card-subtitle { font-size: 0.9rem; } /* Siết */
            
            .header-logo { grid-column: 1 / 2; justify-self: start; font-size: 1.1rem; }
            .header-user { font-size: 0.8rem; }

            .seatmap-layout { flex-direction: column; }
            .seat-area { min-width: 100%; }
            .seat-summary { min-width: 100%; order: -1; } /* Đẩy tóm tắt lên đầu */
            .seat-grid th, .seat-grid td { width: 36px; height: 36px; }
            .seat svg { width: 30px; height: 30px; }
            
            .sticky-footer-bar { padding: var(--spacing-sm); }
            .footer-content {
                flex-direction: column; align-items: stretch;
                gap: var(--spacing-sm); /* Siết */
            }
            .footer-total { display: flex; justify-content: space-between; align-items: center; }
            .footer-total .label { font-size: 12px; }
            .footer-total .price { font-size: 16px; }
            .footer-right { gap: var(--spacing-sm); justify-content: space-between; }
            .btn-continue-form { flex: 1; display: flex; }
            .btn-continue-form .btn { width: 100%; }
        }
    </style>
</head>
<body>

    <!-- Header (Giống Schedule.jsp) -->
    <header class="main-header" id="mainHeader">
        <a href="<%=request.getContextPath()%>/MainSeller.jsp" class="header-logo">
            Hệ thống Cinema
        </a>
        <div class="header-user">
            <span>Xin chào, <strong><%= user.getUsername() %></strong></span>
            <form action="<%=request.getContextPath()%>/logout" method="post" class="logout-form">
                <button class="logout-button" type="submit">Đăng xuất</button>
            </form>
        </div>
    </header>

    <!-- Nội dung chính -->
    <main class="main-content">
        
        <!-- Card kính mờ (Wrapper) -->
        <div class="content-card">
            
            <!-- Tiêu đề (Style của Schedule.jsp) -->
            <h1 class="card-title">Chọn ghế</h1>
            <h2 class="card-subtitle">
                <%= movie != null ? movie.getName() : "(Phim)" %> | 
                <%= (schedule != null && schedule.getRoom() != null) ? schedule.getRoom().getName() : "Phòng" %> | 
                <%= (schedule != null && schedule.getStartTime() != null) ? new SimpleDateFormat("HH:mm").format(schedule.getStartTime()) : "--:--" %>
            </h2>

            <!-- Thông báo lỗi (nếu có) -->
            <% if (bookingError != null) { %>
                <div class="alert error">
                    <strong>Lỗi:</strong> <%= bookingError %>
                </div>
            <% } %>
            
            <div id="selectionError" class="alert error" style="display:none;">
                Vui lòng chọn ít nhất một ghế trước khi tiếp tục.
            </div>

            <!-- Bố cục Sơ đồ ghế (Nội dung của Seatmap.jsp) -->
            <div class="seatmap-layout">

                <!-- 1. Sơ đồ ghế (Bên trái) -->
                <div class="seat-area">
                    <div class="seat-screen">MÀN HÌNH</div>
                    
                    <div class="seat-grid-container">
                        <table class="seat-grid">
                            <thead>
                                <tr>
                                    <th></th>
                                    <% for (int c = 1; c <= maxCol; c++) { %>
                                        <th><%= c %></th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (Map.Entry<String, Map<Integer, SeatSchedule>> r : grid.entrySet()) {
                                    String row = r.getKey(); 
                            %>
                                <tr>
                                    <td><%= row %></td>
                                    <% for (int c = 1; c <= maxCol; c++) {
                                            SeatSchedule ss = r.getValue().get(c);
                                            if (ss == null) { 
                                    %>
                                        <td></td> <!-- Ô trống -->
                                    <%      } else {
                                                boolean booked = (ss.getStatus() == 0);
                                                boolean blocked = false;
                                                if (allowedMin != null && allowedMax != null) {
                                                    int id = ss.getId();
                                                    if (id < allowedMin || id > allowedMax) blocked = true;
                                                }
                                                
                                                boolean isVip = (ss.getSeat() != null && ss.getSeat().getPriceMultiplier() > 1.0);
                                                double price = 0.0;
                                                if (schedule != null && ss.getSeat() != null) {
                                                    price = schedule.getBasePrice() * ss.getSeat().getPriceMultiplier();
                                                }
                                                
                                                String cssClass = "seat";
                                                if (booked) cssClass += " booked";
                                                else if (blocked) cssClass += " blocked";
                                                else cssClass += " available";
                                                
                                                // Không thêm class "vip" nữa, vì màu đã giống nhau
                                                
                                    %>
                                    <td>
                                        <label class="<%= cssClass %>" data-id="<%= ss.getId() %>">
                                            <input 
                                                type="checkbox" 
                                                class="seat-checkbox" 
                                                name="selectedSeatId[]" 
                                                value="<%= ss.getId() %>" 
                                                <%= (booked || blocked) ? "disabled" : "" %> 
                                                data-name="<%= ss.getSeat().getName() %>" 
                                                data-price="<%= price %>">
                                            
                                            <!-- [LOGIC MỚI] Chọn SVG dựa trên isVip -->
                                            <% if (isVip) { %>
                                                <!-- Icon Ghế VIP (Ghế bành) -->
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                                    <path d="M7 13c1.65 0 3-1.35 3-3s-1.35-3-3-3-3 1.35-3 3 1.35 3 3 3zm10 0c1.65 0 3-1.35 3-3s-1.35-3-3-3-3 1.35-3 3 1.35 3 3 3zM21 11c0-2.76-2.24-5-5-5H8c-2.76 0-5 2.24-5 5v7h2v-3h14v3h2v-7zM7 9c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm10 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1z"/>
                                                </svg>
                                            <% } else { %>
                                                <!-- Icon Ghế Thường -->
                                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                                                    <path d="M4 18v3h3v-3h10v3h3v-3h-1V10c0-1.1-.9-2-2-2H6c-1.1 0-2 .9-2 2v8H2v-8c0-2.76 2.24-5 5-5h10c2.76 0 5 2.24 5 5v8h-2Z"/>
                                                </svg>
                                            <% } %>
                                        </label>
                                    </td>
                                    <% } } %>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>

                    <!-- [THAY ĐỔI] Chú thích (với 2 icon SVG) -->
                    <div class="seat-legend">
                        <div class="item">
                            <span class="box">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#6b7280"><path d="M4 18v3h3v-3h10v3h3v-3h-1V10c0-1.1-.9-2-2-2H6c-1.1 0-2 .9-2 2v8H2v-8c0-2.76 2.24-5 5-5h10c2.76 0 5 2.24 5 5v8h-2Z"/></svg>
                            </span> Thường
                        </div>
                        <div class="item">
                            <span class="box">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#6b7280"><path d="M7 13c1.65 0 3-1.35 3-3s-1.35-3-3-3-3 1.35-3 3 1.35 3 3 3zm10 0c1.65 0 3-1.35 3-3s-1.35-3-3-3-3 1.35-3 3 1.35 3 3 3zM21 11c0-2.76-2.24-5-5-5H8c-2.76 0-5 2.24-5 5v7h2v-3h14v3h2v-7zM7 9c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm10 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1z"/></svg>
                            </span> VIP
                        </div>
                        <div class="item">
                            <span class="box">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="var(--color-danger)" style="opacity: 0.9;"><path d="M4 18v3h3v-3h10v3h3v-3h-1V10c0-1.1-.9-2-2-2H6c-1.1 0-2 .9-2 2v8H2v-8c0-2.76 2.24-5 5-5h10c2.76 0 5 2.24 5 5v8h-2Z"/></svg>
                            </span> Đã đặt
                        </div>
                        <div class="item">
                            <span class="box">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="var(--color-primary)"><path d="M4 18v3h3v-3h10v3h3v-3h-1V10c0-1.1-.9-2-2-2H6c-1.1 0-2 .9-2 2v8H2v-8c0-2.76 2.24-5 5-5h10c2.76 0 5 2.24 5 5v8h-2Z"/></svg>
                            </span> Đang chọn
                        </div>
                    </div>
                    
                    <!-- Chú thích giá -->
                    <div class="price-legend">
                        <span>Ghế Thường: <strong><%= String.format("%,.0f", basePrice) %> VND</strong></span> |
                        <span>Ghế VIP: <strong><%= String.format("%,.0f", vipPrice) %> VND</strong></span>
                    </div>
                </div>

                <!-- 2. Tóm tắt (Bên phải) -->
                <aside class="seat-summary">
                    <h3>Tóm tắt giao dịch</h3>
                    <p><strong>Phim:</strong> <%= movie != null ? movie.getName() : "-" %></p>
                    <p><strong>Suất:</strong> <%= schedule != null && schedule.getStartTime()!=null ? new SimpleDateFormat("HH:mm").format(schedule.getStartTime()) : "-" %></p>
                    <p><strong>Phòng:</strong> <%= schedule!=null && schedule.getRoom()!=null ? schedule.getRoom().getName() : "-" %></p>
                    <hr />
                    <h4>Ghế đang chọn</h4>
                    <ul id="selectedList" class="seat-list">
                        <li id="selectedListPlaceholder" class="seat-list-placeholder">Chưa chọn ghế nào</li>
                    </ul>
                    <hr />
                    <div style="display:flex; justify-content: space-between; align-items: baseline;">
                        <span style="font-weight: 600; color: #ffffff;">Tổng cộng</span>
                        <span id="totalPriceSummary" style="font-size: 18px; font-weight: 700; color: #ffffff;">0 VND</span>
                    </div>
                    <hr />
                    <!-- Membership code (UI + confirm button) -->
                    <div class="member-input-group">
                        <label for="memberCode">Mã thẻ thành viên</label>
                        <div class="member-row">
                            <input type="text" id="memberCode" name="memberCode" placeholder="Nhập mã (tùy chọn)" aria-label="Mã thẻ thành viên" />
                            <button type="button" id="memberConfirmBtn" class="btn btn-confirm">Xác nhận</button>
                        </div>
                        <small id="memberConfirmStatus"></small>
                    </div>
                </aside>
            </div>
            
        </div> <!-- end .content-card -->
    </main>

    <!-- Footer Cố định (WOW + Kính mờ) -->
    <footer class="sticky-footer-bar">
        <div class="footer-content">
            <div class="footer-left">
                <a href="<%=request.getContextPath()%>/schedule?movieId=<%= movie != null ? movie.getId() : (schedule!=null && schedule.getMovie()!=null ? schedule.getMovie().getId() : "") %>" class="btn btn-secondary ghost">
                    &larr; Quay lại
                </a>
            </div>
            <div class="footer-right">
                <div class="footer-total">
                    <div class="label">TỔNG TIỀN</div>
                    <div class="price" id="totalPriceFooter">0 VND</div>
                </div>
                
                <form id="bookForm" action="<%=request.getContextPath()%>/ticketnBill" method="get" class="btn-continue-form">
                    <input type="hidden" name="scheduleId" value="<%= schedule != null ? schedule.getId() : "" %>">
                    <div id="hiddenInputs"></div> 
                    <button type="submit" class="btn btn-primary continue">Tiếp tục</button>
                </form>
            </div>
        </div>
    </footer>

    <!-- JavaScript (Từ Seatmap.jsp) -->
    <script>
        const checkboxes = Array.from(document.querySelectorAll('.seat-checkbox'));
        const selectedList = document.getElementById('selectedList');
        const selectedListPlaceholder = document.getElementById('selectedListPlaceholder');
        const totalPriceSummaryEl = document.getElementById('totalPriceSummary');
        const totalPriceFooterEl = document.getElementById('totalPriceFooter');
        const hiddenInputs = document.getElementById('hiddenInputs');
        const selectionError = document.getElementById('selectionError');

        function formatPrice(value) {
            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND', minimumFractionDigits: 0 }).format(value);
        }

        function updateUI() {
            selectedList.innerHTML = '';
            hiddenInputs.innerHTML = '';
            let total = 0;
            let count = 0;

            checkboxes.forEach(cb => {
                const label = cb.closest('label');
                if (!label) return;

                if (cb.checked && !cb.disabled) {
                    label.classList.add('selected');
                    const price = parseFloat(cb.dataset.price) || 0;
                    total += price;
                    count++;

                    const li = document.createElement('li');
                    li.textContent = cb.dataset.name + ' (' + formatPrice(price) + ')';
                    selectedList.appendChild(li);

                    const h = document.createElement('input'); 
                    h.type = 'hidden'; 
                    h.name = 'selectedSeatId[]';
                    h.value = cb.value; 
                    hiddenInputs.appendChild(h);
                } else {
                    label.classList.remove('selected');
                }
            });

            if (count > 0) {
                if (selectedListPlaceholder) selectedListPlaceholder.style.display = 'none';
            } else {
                if (selectedListPlaceholder) selectedListPlaceholder.style.display = 'block';
            }

            totalPriceSummaryEl.textContent = formatPrice(total);
            totalPriceFooterEl.textContent = formatPrice(total);

            if (selectionError) {
                if (count > 0) selectionError.style.display = 'none';
            }
        }

        checkboxes.forEach(cb => {
            cb.addEventListener('change', updateUI);
        });
        
        document.addEventListener('DOMContentLoaded', () => {
            updateUI(); // Cập nhật UI khi tải trang

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

            const seatArea = document.querySelector('.seat-area');
            if (seatArea) {
                seatArea.addEventListener('wheel', function (e) {
                    if (seatArea.scrollWidth > seatArea.clientWidth) {
                        e.preventDefault();
                        seatArea.scrollLeft += e.deltaY;
                    }
                }, { passive: false });
            }

            const bookForm = document.getElementById('bookForm');
            if (bookForm) {
                bookForm.addEventListener('submit', function (e) {
                    const selectedCount = document.querySelectorAll('.seat-checkbox:checked').length;
                    if (selectedCount === 0) {
                        e.preventDefault();
                        if (selectionError) {
                            selectionError.style.display = 'block';
                            try { selectionError.scrollIntoView({ behavior: 'smooth', block: 'center' }); } catch (er) {}
                        }
                    }
                });
            }

            // Membership confirm button behavior
            const memberConfirmBtn = document.getElementById('memberConfirmBtn');
            const memberCodeInput = document.getElementById('memberCode');
            const memberStatus = document.getElementById('memberConfirmStatus');
            // create or update hidden input for member code directly under the form (not inside hiddenInputs)
            function setMemberHidden(value) {
                if (!bookForm) return;
                let existing = document.getElementById('memberCodeHidden');
                if (value && value.trim() !== '') {
                    if (!existing) {
                        existing = document.createElement('input');
                        existing.type = 'hidden';
                        existing.id = 'memberCodeHidden';
                        existing.name = 'memberCode';
                        bookForm.appendChild(existing);
                    }
                    existing.value = value.trim();
                } else {
                    if (existing) existing.remove();
                }
            }

            if (memberConfirmBtn && memberCodeInput) {
                memberConfirmBtn.addEventListener('click', function () {
                    const v = memberCodeInput.value || '';
                    if (v.trim() === '') {
                        // show error
                        if (memberStatus) {
                            memberStatus.textContent = 'Vui lòng nhập mã thẻ hoặc bỏ qua.';
                            memberStatus.className = 'member-confirm-error';
                        }
                        setMemberHidden('');
                        // remove saved visual state
                        memberConfirmBtn.classList.remove('member-saved');
                        return;
                    }
                    // set hidden input on the form so it is submitted and not cleared by updateUI
                    setMemberHidden(v);
                    if (memberStatus) {
                        memberStatus.textContent = 'Mã đã lưu cho giao dịch.';
                        memberStatus.className = 'member-confirm-ok';
                    }
                    // visually mark the button as saved (small filled primary)
                    memberConfirmBtn.classList.add('member-saved');
                });
            }
        });
    </script>

</body>
</html>