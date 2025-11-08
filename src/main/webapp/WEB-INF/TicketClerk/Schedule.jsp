<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Movie" %>
<%@ page import="model.User" %>
<%@ page import="model.Schedule" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chọn lịch chiếu - Hệ thống Cinema</title>

    <!-- Tải fonts Inter và Poppins -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">

    <!-- CSS đã được lồng trực tiếp vào đây (Bao gồm tất cả các style cần thiết) -->
    <style>
        /* --- CSS Variables --- */
        :root {
            --font-primary: 'Inter', 'Poppins', sans-serif;
            --color-primary: #2F3C7E;
            --color-accent: #FBEAEB;
            --color-text: #0F172A;
            --color-bg: #FFFFFF;
            
            /* [THÊM] Biến accent từ CSS cũ để hỗ trợ modal/component cũ */
            --system-accent: var(--color-primary); 

            --spacing-xs: 4px;
            --spacing-sm: 8px;
            --spacing-md: 16px;
            --spacing-lg: 24px;
            --spacing-xl: 32px;

            --radius-lg: 20px;

            --shadow-soft: 0 10px 25px -5px rgba(0, 0, 0, 0.07), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            --shadow-medium: 0 4px 10px rgba(0, 0, 0, 0.1);
            --shadow-focus: 0 0 0 3px rgba(47, 60, 126, 0.3); /* Viền focus */

            --transition-duration: 200ms;
        }

        /* --- Global Reset & Base --- */
        *,
        *::before,
        *::after {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html, body {
            height: 100%;
        }

        body {
            font-family: var(--font-primary);
            background-color: var(--color-text); /* Nền dự phòng nếu ảnh không tải */
            color: var(--color-text);
            line-height: 1.6;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* --- Lớp phủ và Ảnh nền --- */
        body::before {
            content: '';
            position: fixed; /* Dùng fixed để lớp phủ che toàn bộ viewport */
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: url('<%=request.getContextPath()%>/assets/img/BG.png');
            background-size: cover;
            background-position: center;
            background-attachment: fixed; /* Giữ nền cố định khi cuộn */
            z-index: -2;
        }

        body::after {
            content: '';
            position: fixed; /* Lớp phủ cũng cần fixed */
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.4); /* Lớp phủ đen mờ 40% */
            z-index: -1;
        }


        /* --- Header --- */
        .main-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 100;
            display: grid; /* Thay đổi từ flex sang grid */
            grid-template-columns: 1fr auto 1fr; /* Tạo 3 cột (trái, giữa, phải) */
            align-items: center;
            /* Reduced vertical padding to make header thinner while keeping full width */
            padding: var(--spacing-md) var(--spacing-xl);
            background-color: var(--color-bg); /* Nền trắng đục */
            transition: padding var(--transition-duration) ease, 
                        box-shadow var(--transition-duration) ease,
                        background-color var(--transition-duration) ease;
        }

        /* Trạng thái header khi cuộn */
        .main-header.scrolled {
            /* Slightly smaller when scrolled */
            padding: var(--spacing-sm) var(--spacing-xl);
            box-shadow: var(--shadow-medium);
            background-color: var(--color-bg); /* Vẫn là nền trắng đục */
        }

        .header-logo {
            font-size: 1.7rem;
            font-weight: 700;
            color: var(--color-primary);
            text-decoration: none;
            grid-column: 2 / 3; /* Đặt logo vào cột giữa */
            justify-self: center; /* Căn giữa trong cột */
        }

        .header-user {
            font-size: 0.95rem;
            color: var(--color-text);
            grid-column: 3 / 4; /* Đặt user vào cột phải */
            justify-self: end; /* Căn lề phải trong cột */
            display: flex;
            align-items: center;
        }

        .header-user span {
            font-weight: 600;
        }

        /* --- Kiểu cho Form Đăng xuất --- */
        .logout-form {
            display: inline;
            margin: 0;
            padding: 0;
        }

        .logout-button {
            background: none;
            border: none;
            padding: 0;
            margin: 0;
            font: inherit;
            cursor: pointer;
            color: var(--color-primary);
            text-decoration: none;
            font-weight: 600;
            margin-left: var(--spacing-sm);
        }
        .logout-button:hover {
            text-decoration: underline;
        }


        /* --- Main Content --- */
        .main-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column; /* Cho phép nội dung phát triển theo chiều dọc */
            align-items: center;
            justify-content: flex-start; /* Bắt đầu từ trên xuống */
            width: 100%;
            padding: var(--spacing-xl);
            padding-top: 120px;
            padding-bottom: 60px;
        }

        .content-card {
            width: 100%;
            max-width: 1100px;
            /* Milky frosted panel */
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

        /* Title centralized in shared stylesheet; keep fallback here for safety */
        .card-title {
            color: #ffffff;
            font-size: 1.7rem; /* unified desktop size */
            font-weight: 700;
            margin-bottom: var(--spacing-lg);
            position: relative;
            padding-bottom: var(--spacing-sm);
            text-align: center;
        }
        
        /* [MỚI] Thêm Subtitle cho tên phim */
        .card-subtitle {
            text-align: center;
            font-size: 1.5rem;
            font-weight: 600;
            color: #ffffff; /* Movie name in white */
            margin-top: calc(-1 * var(--spacing-lg)); /* Kéo lên gần title */
            margin-bottom: var(--spacing-lg);
        }

        /* Modal movie title color */
        #modalMovieTitle {
            color: #ffffff;
            margin: 0 0 8px 0;
            font-size: 1.25rem;
            font-weight: 700;
        }

        /* --- Kiểu Nút Bấm (Button) --- */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            height: 48px;
            padding: 0 var(--spacing-lg);
            border-radius: 12px;
            font-weight: 600;
            font-size: 1rem;
            text-decoration: none;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all var(--transition-duration) ease;
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
            outline: none;
            box-shadow: var(--shadow-focus);
        }
        
        /* --- [MỚI] Bố cục chi tiết lịch chiếu --- */
        .schedule-details-grid {
            display: grid;
            grid-template-columns: 250px 1fr; /* Cột poster | Cột thông tin */
            gap: var(--spacing-xl);
        }

        .poster-column img {
            width: 100%;
            border-radius: 12px;
            box-shadow: var(--shadow-medium);
            max-height: 260px; /* slightly smaller poster for denser layout */
            object-fit: cover;
        }
        
        .movie-meta-details {
            margin-top: 8px;
            font-size: 0.88rem;
            color: rgba(255,255,255,0.9); /* white-ish for dark bg */
            line-height: 1.25;
        }
        .movie-meta-details p {
            margin-bottom: 4px;
        }
        .movie-meta-details strong {
            color: #ffffff;
            font-weight: 600;
        }

        .info-column {
            display: flex;
            flex-direction: column;
        }

        .movie-description {
            font-size: 0.92rem;
            line-height: 1.28; /* tighter lines */
            color: rgba(255,255,255,0.94);
            margin-bottom: 12px;
            max-height: 110px; /* Giảm chiều cao để gọn hơn */
            overflow-y: auto; /* Thêm thanh cuộn nếu mô tả quá dài */
        }
        
        .showtime-section-title {
            font-size: 1.15rem;
            font-weight: 600;
            color: #ffffff; /* title white */
            margin-bottom: 10px;
            padding-bottom: 6px;
            /* remove pink divider and use subtle translucent divider */
            border-bottom: 2px solid rgba(255,255,255,0.04);
        }

        /* Trạng thái rỗng (Copy từ SearchMovie) */
        .empty-state {
            padding: var(--spacing-lg);
            text-align: center;
            color: rgba(255,255,255,0.9);
            font-size: 1.05rem;
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            border: 1px solid rgba(255,255,255,0.04);
            border-radius: var(--radius-lg);
        }

        /* --- Lịch chiếu (Showtimes) --- */
        /* Style này đã có từ SearchMovie.jsp, chỉ cần đảm bảo nó ở đây */
        .showtimes-grid{
            display:flex;
            flex-wrap:wrap;
            gap:8px; /* tighter */
            align-items:center;
            margin-top:12px;
        }
        .showtime-box{
            width:80px;
            min-height: 48px; /* compact */
            padding: 6px 8px;
            border-radius: 10px; /* slightly smaller radius */
            border: 1px solid rgba(255,255,255,0.04);
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            cursor:pointer;
            box-shadow: 0 6px 12px rgba(2,6,23,0.12);
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:center;
            transition: all var(--transition-duration) ease;
        }
        .showtime-box .time{
            font-weight:700;
            color: #ffffff; /* white time */
            font-size: 0.95rem;
        }
        .showtime-box:hover{
            transform:translateY(-3px);
            box-shadow: 0 12px 28px rgba(2,6,23,0.2);
            border-color: rgba(255,255,255,0.12);
        }
        /* Disabled / past showtime */
        .showtime-box.disabled {
            opacity: 0.45;
            cursor: default;
            filter: grayscale(60%);
            pointer-events: none;
            transform: none;
            box-shadow: none;
            border-color: rgba(255,255,255,0.04);
        }
        .showtime-box .price-short { 
            font-size:11px; 
            color: rgba(255,255,255,0.9); 
            margin-top:4px; 
            font-weight:800; 
        }

        /* Modal (Hộp thoại) */
        /* Style này đã có từ SearchMovie.jsp */
        .modal-overlay { 
            position:fixed; 
            inset:0; 
            display:none; /* Sẽ được bật bằng JS */
            align-items:center; 
            justify-content:center; 
            background:rgba(0,0,0,0.6); /* Tăng độ mờ */
            z-index: 9999; 
            backdrop-filter: blur(4px);
            -webkit-backdrop-filter: blur(4px);
        }
        .modal-box{
            background: var(--color-bg);
            border-radius: var(--radius-lg); /* Đồng bộ bo góc */
            max-width:720px;
            width:92%;
            padding: var(--spacing-lg);
            box-shadow: 0 20px 60px rgba(2,6,23,0.25);
            position:relative;
            color: var(--color-text); /* Dùng màu text mới */
        }
        .modal-box h2{
            margin:0 0 var(--spacing-md) 0;
            color:var(--system-accent);
            text-align:center;
            font-size: 1.5rem;
        }
        .modal-row { display:flex; gap:12px; }
        .modal-small-meta { font-size:12px; color:#888; margin:0 0 6px 0; }
        .modal-close { 
            position:absolute; 
            right: 16px; 
            top: 12px; 
            background:transparent;
            border:0;
            font-size:26px;
            cursor:pointer;
            color:#777;
            line-height: 1;
        }
        .modal-confirm{
            /* Dùng lại style .btn */
            display:inline-block; 
            padding:10px 18px; 
            border-radius: 12px; 
            background: var(--color-primary);
            color: var(--color-bg); 
            text-decoration:none;
            font-weight:700;
            border: 0;
            cursor: pointer;
            transition: all var(--transition-duration) ease;
        }
        .modal-confirm:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        /* Sơ đồ ghế (Seat Map) - Vẫn giữ lại cho trang seatmap */
        .seat-map{ display:flex; gap: var(--spacing-lg); align-items:flex-start; }
        .seat-area{ flex:1; }
        .seat-canvas{ padding: var(--spacing-md); border-radius: var(--radius-lg); background: #f9fafb; box-shadow: inset 0 2px 4px 0 rgba(0,0,0,0.05); }
        .seat-grid{ border-collapse:collapse; width:100%; }
        .seat-grid th,.seat-grid td{ padding: var(--spacing-xs); text-align:center; }
        .seat{ display:inline-block; width:42px; height:42px; line-height:42px; border-radius: 8px; border: 1px solid #d1d5db; background: #f3f4f6; color:#222; cursor:pointer; font-weight: 600; font-size: 0.9rem; transition: all 100ms ease; }
        .seat.available{ background: #D1FAE5; border-color:#065F46; color:#065F46; }
        .seat.booked{ background: #FEE2E2; border-color:#991B1B; color:#991B1B; cursor:not-allowed; }
        .seat.blocked{ background: #e5e7eb; border-color:#9ca3af; color:#6b7280; cursor:not-allowed; }
        .seat.selected{ background: var(--color-primary); color: var(--color-bg); border-color: var(--color-primary); transform: scale(1.05); }
        .seat input[type=checkbox]{ display:none; }
        .legend{ display:flex; flex-wrap: wrap; gap: var(--spacing-md); margin-top: var(--spacing-md); font-size:14px; color: var(--color-text); }
        .legend .box{ width:18px; height:18px; display:inline-block; border-radius:4px; margin-right: var(--spacing-sm); vertical-align: middle; }
        .seat-summary{ min-width:260px; padding: var(--spacing-md); border-radius: var(--radius-lg); background: var(--color-bg); box-shadow: var(--shadow-soft); }
        .seat-summary h3{ margin-top:0; color: var(--color-primary); }
        .seat-list{ list-style:none; padding:0; margin:0; }
        .seat-list li{ margin: var(--spacing-sm) 0; font-size: 0.95rem; }

        /* Thông báo (Alerts) - Vẫn giữ lại */
        .alert{ padding: var(--spacing-md); border-radius: 12px; margin: var(--spacing-md) 0; }
        .alert.error{ background:#FEE2E2; color:#991B1B; border:1px solid #FCA5A5; }
        .alert.success{ background:#D1FAE5; color:#065F46; border:1px solid #6EE7B7; }


        /* --- Responsive (Mobile) --- */
        @media (max-width: 768px) {
            .main-header { padding: var(--spacing-md) var(--spacing-lg); }
            .main-header.scrolled { padding: var(--spacing-sm) var(--spacing-lg); }
            .header-logo { font-size: 1.7rem; }
            .header-user { font-size: 0.85rem; }

            .main-content {
                padding: var(--spacing-lg);
                padding-top: 100px;
                align-items: flex-start;
            }

            .content-card {
                padding: var(--spacing-lg) var(--spacing-md);
                box-shadow: 0 4px 10px -5px rgba(0, 0, 0, 0.05); 
            }

            .card-title { font-size: 1.4rem; }
            .card-subtitle { font-size: 1.1rem; margin-top: -12px; }

            /* [MỚI] Responsive cho chi tiết lịch chiếu */
            .schedule-details-grid {
                grid-template-columns: 1fr; /* 1 cột */
                gap: var(--spacing-lg);
            }
            .poster-column {
                max-width: 250px; /* Giới hạn chiều rộng poster trên mobile */
                margin: 0 auto; /* Căn giữa */
            }

            /* Responsive cho Sơ đồ ghế */
            .seat-map{ flex-direction:column; }
            .seat-summary { min-width: 100%; }
            .seat { width: 32px; height: 32px; line-height: 32px; font-size: 0.8rem; }

            /* Responsive cho Modal */
            @media (max-width:640px){ 
                .modal-row{flex-direction:column} 
            }
        }
    </style>
</head>
<body>

    <%
        // --- Scriptlet Khai báo ---
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        
        Movie movie = (Movie) request.getAttribute("movie");
        List<Schedule> schedules = (List<Schedule>) request.getAttribute("schedules");
        if (schedules == null) schedules = new ArrayList<>();

        // --- Scriptlet Xử lý logic ---
        // (Di chuyển logic vào đây để HTML gọn gàng hơn)
        
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
        String todayStr = df.format(cal.getTime());
        SimpleDateFormat dfOnly = new SimpleDateFormat("dd/MM/yyyy");
        
        List<Schedule> todayList = new ArrayList<Schedule>();
        for (Schedule s : schedules) {
            if (s == null || s.getDate() == null) continue;
            String sd = dfOnly.format(s.getDate());
            if (sd.equals(todayStr)) todayList.add(s);
        }

        // Xử lý Poster URL
        String posterValue = (movie!=null)? movie.getPoster() : null;
        String imgSrcFinal = request.getContextPath() + "/assets/img/logo.jpg"; // Default
        if (posterValue != null) {
            posterValue = posterValue.trim();
            if (posterValue.startsWith("http://") || posterValue.startsWith("https://")) {
                imgSrcFinal = posterValue;
            } else {
                String p = posterValue;
                if (!p.startsWith("/")) p = "/" + p;
                imgSrcFinal = request.getContextPath() + p;
            }
        }
    %>

    <!-- Header Cố Định (Đã thống nhất) -->
    <header class="main-header" id="mainHeader">
        <a href="<%=request.getContextPath()%>/mainSeller" class="header-logo">
            Hệ thống Cinema
        </a>
        <div class="header-user">
            Xin chào, <span><%= user.getUsername() %></span>
            <form action="<%=request.getContextPath()%>/login" method="post" class="logout-form">
                <button type="submit" class="logout-button">Đăng xuất</button>
            </form>
        </div>
    </header>

    <!-- Nội dung chính -->
    <main class="main-content">
        
        <!-- Card Chức Năng -->
        <div class="content-card">
            
            <h1 class="card-title">Chọn lịch chiếu</h1>
            <h2 class="card-subtitle"><%= (movie!=null) ? movie.getName() : "(Phim)" %></h2>

            <!-- [MỚI] Bố cục lưới cho chi tiết -->
            <div class="schedule-details-grid">
                
                <!-- Cột Poster -->
                <div class="poster-column">
                    <img src="<%=imgSrcFinal%>" alt="poster" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/img/logo.jpg'" />
                    <div class="movie-meta-details">
                        <p>Thể loại: <strong><%= (movie!=null?movie.getCategory():"-") %></strong></p>
                        <p>Trạng thái: <strong><%= (movie!=null && movie.getActive()==1) ? "Đang chiếu" : "Ngưng chiếu" %></strong></p>
                    </div>
                </div>

                <!-- Cột Thông tin & Lịch chiếu -->
                <div class="info-column">
                    <p class="movie-description">
                        <%= (movie!=null && movie.getDescription()!=null) ? movie.getDescription() : "(Không có mô tả)" %>
                    </p>
                    
                    <h3 class="showtime-section-title">Suất chiếu hôm nay — <%= todayStr %></h3>

                    <% if (todayList.isEmpty()) { %>
                        <div class="empty-state">Hôm nay chưa có suất chiếu.</div>
                    <% } else { %>
                        <div class="showtimes-grid">
                            <% 
                                // Vòng lặp
                                for (Schedule s2 : todayList) {
                                            SimpleDateFormat tf = new SimpleDateFormat("HH:mm");
                                            String timeOnly = s2.getStartTime() != null ? tf.format(s2.getStartTime()) : "--:--";
                                            String endOnly = s2.getEndTime() != null ? tf.format(s2.getEndTime()) : "--:--";
                                            long shortP = Math.round((s2.getBasePrice() / 1000.0));
                                            String shortPrice = shortP + "K";
                                            String priceFull = String.format("%,.0f", s2.getBasePrice());
                                            String idStr = String.valueOf(s2.getId());
                                            String roomName = (s2.getRoom() != null && s2.getRoom().getName() != null) ? s2.getRoom().getName() : "(không rõ)";
                                            String roomDesc = (s2.getRoom() != null && s2.getRoom().getDescription() != null) ? s2.getRoom().getDescription() : "";
                                            String roomEsc = roomName.replace("'","\\'");
                                            String roomDescEsc = roomDesc.replace("'","\\'");
                                            // Determine if this showtime is already in the past (for today)
                                            java.util.Calendar nowCal = java.util.Calendar.getInstance();
                                            java.util.Calendar sc = java.util.Calendar.getInstance();
                                            if (s2.getDate() != null) sc.setTime(s2.getDate());
                                            if (s2.getStartTime() != null) {
                                                java.util.Calendar st = java.util.Calendar.getInstance();
                                                st.setTime(s2.getStartTime());
                                                sc.set(java.util.Calendar.HOUR_OF_DAY, st.get(java.util.Calendar.HOUR_OF_DAY));
                                                sc.set(java.util.Calendar.MINUTE, st.get(java.util.Calendar.MINUTE));
                                                sc.set(java.util.Calendar.SECOND, st.get(java.util.Calendar.SECOND));
                                            }
                                            boolean isPast = sc.getTime().before(nowCal.getTime());
                                    %>
                                            <% if (!isPast) { %>
                                            <button type="button" class="showtime-box" title="<%= timeOnly %> — <%= priceFull %> VND" aria-label="Suất <%= timeOnly %>, giá <%= priceFull %> VND, phòng <%= roomEsc %>" onclick="openScheduleModal('<%=idStr%>','<%=roomEsc%>','<%= (s2.getDate()!=null?dfOnly.format(s2.getDate()):'-') %>','<%=timeOnly%>','<%=endOnly%>','<%=shortPrice%>','<%=roomDescEsc%>')">
                                                <div class="time"><%= timeOnly %></div>
                                                <div class="price-short"><%= shortPrice %></div>
                                            </button>
                                            <% } else { %>
                                            <button type="button" class="showtime-box disabled" title="Suất đã bắt đầu" aria-label="Suất đã bắt đầu" disabled>
                                                <div class="time"><%= timeOnly %></div>
                                                <div class="price-short"><%= shortPrice %></div>
                                            </button>
                                            <% } %>
                                    <% } %>
                        </div>
                    <% } %>
                </div>

            </div> <!-- end .schedule-details-grid -->
            
        </div> <!-- end .content-card -->
    </main>

    <!-- Modal (Hộp thoại xác nhận) -->
    <!-- (HTML Này được giữ nguyên từ file gốc của bạn, nhưng sẽ được style bằng CSS mới) -->
    <div id="scheduleModal" class="modal-overlay" aria-hidden="true" style="display: none;">
        <div class="modal-box" role="dialog" aria-modal="true">
            <button class="modal-close" onclick="closeScheduleModal()" aria-label="Đóng">&times;</button>
            <h2 id="modalMovieTitle"><%= (movie!=null) ? movie.getName() : "Thông tin suất chiếu" %></h2>
            <div class="modal-row">
                <div style="flex:1;min-width:160px">
                    <p class="modal-small-meta">Phòng chiếu</p>
                    <p id="modalRoom" style="font-weight:700;margin:6px 0;">-</p>
                    <p id="modalRoomDesc" class="modal-small-meta" style="margin:6px 0;color:#666">&nbsp;</p>
                </div>
                <div style="flex:1;min-width:120px;text-align:center">
                    <p class="modal-small-meta">Ngày chiếu</p>
                    <p id="modalDate" style="font-weight:700;margin:6px 0;">-</p>
                </div>
                <div style="flex:1;min-width:180px;text-align:center">
                    <p class="modal-small-meta">Giờ</p>
                    <p id="modalTimeRange" style="font-weight:700;margin:6px 0;">-</p>
                    <p id="modalPriceShort" class="modal-small-meta" style="margin:6px 0;color:#666">&nbsp;</p>
                </div>
            </div>
            <div style="text-align:center;margin-top:18px">
                <a id="modalConfirm" class="modal-confirm" href="#">ĐỒNG Ý</a>
            </div>
        </div>
    </div>

    <!-- JavaScript cho Header Scroll -->
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
    
    <!-- JavaScript cho Modal (Giữ nguyên từ file gốc) -->
    <script>
        function openScheduleModal(id, room, dateStr, startTime, endTime, shortPrice, roomDesc) {
            document.getElementById('modalRoom').innerText = room;
            document.getElementById('modalRoomDesc').innerText = roomDesc || '';
            document.getElementById('modalDate').innerText = dateStr;
            document.getElementById('modalTimeRange').innerText = startTime + ' — ' + endTime;
            document.getElementById('modalPriceShort').innerText = shortPrice ? shortPrice : '';
            var confirm = document.getElementById('modalConfirm');
            confirm.href = '<%=request.getContextPath()%>/seatmap?scheduleId=' + encodeURIComponent(id);
            document.getElementById('scheduleModal').style.display = 'flex';
            document.getElementById('scheduleModal').setAttribute('aria-hidden','false');
        }
        function closeScheduleModal() {
            document.getElementById('scheduleModal').style.display = 'none';
            document.getElementById('scheduleModal').setAttribute('aria-hidden','true');
        }
        document.addEventListener('keydown', function(e){ if(e.key === 'Escape') closeScheduleModal(); });
    </script>

</body>
</html>