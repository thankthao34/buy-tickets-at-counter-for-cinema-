<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Movie" %>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tìm kiếm phim - Hệ thống Cinema</title>

    <!-- Tải fonts Inter và Poppins -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">

    <!-- CSS đã được lồng trực tiếp vào đây -->
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
            padding: var(--spacing-md) var(--spacing-xl);
            background-color: var(--color-bg); /* Nền trắng đục */
            transition: padding var(--transition-duration) ease, 
                        box-shadow var(--transition-duration) ease,
                        background-color var(--transition-duration) ease;
        }

        /* Trạng thái header khi cuộn */
        .main-header.scrolled {
            padding: var(--spacing-md) var(--spacing-xl);
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
            /* Frosted translucent panel like MainSeller */
            background-color: rgba(255,255,255,0.06);
            border-radius: var(--radius-lg);
            padding: calc(var(--spacing-lg) + 8px) calc(var(--spacing-lg) + 8px);
            box-shadow: 0 12px 30px rgba(2,6,23,0.45);
            margin: calc(var(--spacing-md) / 2) 0;
            border: 1px solid rgba(255,255,255,0.06);
            backdrop-filter: blur(10px) saturate(120%);
            -webkit-backdrop-filter: blur(10px) saturate(120%);
            color: #ffffff; /* white text inside content area (header stays as is) */
        }

        /* Use centralized title sizing */
        .card-title {
            color: #ffffff;
            font-size: 1.7rem;
            font-weight: 700;
            margin-bottom: var(--spacing-md);
            position: relative;
            padding-bottom: var(--spacing-sm);
            text-align: center;
        }

        /* --- Grid Nút Bấm (Copy từ trang main, sẽ bị ẩn) --- */
        .action-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: var(--spacing-md);
            margin-top: var(--spacing-lg);
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
        .btn-secondary:hover {
             background-color: #fcfaff;
        }

        /* --- [MỚI] Thanh Tìm Kiếm --- */
        .search-form {
            display: flex;
            gap: var(--spacing-md);
            margin-bottom: var(--spacing-lg);
        }

        .search-form input[type="text"] {
            flex-grow: 1;
            height: 48px;
            padding: 0 var(--spacing-md);
            border-radius: 12px;
            border: 2px solid #D1D5DB; /* Viền xám nhạt */
            font-family: var(--font-primary);
            font-size: 1rem;
            transition: all var(--transition-duration) ease;
        }

        .search-form input[type="text"]:focus {
            outline: none;
            border-color: var(--color-primary);
            box-shadow: var(--shadow-focus);
        }
        
        .search-form .btn {
            flex-shrink: 0; /* Không co nút */
        }

        /* --- [MỚI] Lưới Phim --- */
        .movies-grid {
            display: grid;
            /* Denser grid for compact list */
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 12px; /* tighter gap */
            margin-top: 12px;
        }

        .movie-card {
            background-color: transparent; /* let frosted card show through */
            border-radius: 12px;
            box-shadow: none;
            overflow: hidden; /* Giữ ảnh bo góc */
            transition: all var(--transition-duration) ease;
            border: 1px solid rgba(255,255,255,0.03);
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
        }
        
        .movie-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-medium);
        }

        .movie-card .poster {
            width: 100%;
            aspect-ratio: 2 / 3;
            max-height: 200px; /* slightly smaller posters */
            background-color: rgba(255,255,255,0.04); /* placeholder shade */
            overflow: hidden;
        }

        .movie-card .poster img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }
        
        .movie-card .movie-info {
            padding: 6px 8px; /* compact padding */
        }

        .movie-card .movie-info h3 {
            font-size: 0.98rem;
            font-weight: 650;
            margin-bottom: 4px;
            /* Chống tràn tiêu đề dài */
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .movie-card .movie-info h3 a {
            color: #ffffff; /* title links white */
            text-decoration: none;
        }
        .movie-card .movie-info h3 a:hover {
            color: var(--color-accent);
        }

        .movie-card .movie-info p {
            font-size: 0.82rem;
            color: rgba(255,255,255,0.88); /* white-ish metadata */
            margin-bottom: 4px;
            line-height: 1.2;
        }
        
        /* [MỚI] Trạng thái rỗng */
        .empty-state {
            padding: var(--spacing-lg);
            text-align: center;
            color: #6B7280;
            font-size: 1.1rem;
            background-color: #F9FAFB;
            border-radius: var(--radius-lg);
        }

        /* --- [MỚI] Các style component được kéo từ CSS CŨ --- */
        /* --- Được thêm vào để các trang khác (schedule, seatmap) không bị vỡ --- */

        /* Lịch chiếu (Showtimes) */
        .showtimes-grid{
            display:flex;
            flex-wrap:wrap;
            gap:10px;
            align-items:center;
            margin-top:var(--spacing-md);
        }
        .showtime-box{
            width:90px;
            min-height: 60px; /* Dùng min-height thay vì height */
            padding: var(--spacing-sm);
            border-radius: 12px; /* Đồng bộ bo góc */
            border: 1px solid #e5e7eb; /* Viền xám nhạt */
            background: #f9fafb; /* Nền sáng */
            cursor:pointer;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            display:flex;
            flex-direction:column;
            align-items:center;
            justify-content:center;
            transition: all var(--transition-duration) ease;
        }
        .showtime-box .time{
            font-weight:700;
            color: var(--color-primary); /* Dùng màu chính */
            font-size: 1rem;
        }
        .showtime-box:hover{
            transform:translateY(-3px);
            box-shadow: var(--shadow-medium);
            border-color: var(--color-primary);
        }
        /* Style cho giá (nếu có) */
        .showtime-box .price-short { 
            font-size:12px; 
            color:var(--system-accent); 
            margin-top:6px; 
            font-weight:800 
        }

        /* Modal (Hộp thoại) */
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


        /* Sơ đồ ghế (Seat Map) */
        .seat-map{
            display:flex;
            gap: var(--spacing-lg);
            align-items:flex-start;
        }
        .seat-area{
            flex:1;
        }
        .seat-canvas{
            padding: var(--spacing-md);
            border-radius: var(--radius-lg);
            background: #f9fafb; /* Nền xám nhạt cho khu vực ghế */
            box-shadow: inset 0 2px 4px 0 rgba(0,0,0,0.05);
        }
        .seat-grid{
            border-collapse:collapse;
            width:100%;
        }
        .seat-grid th,.seat-grid td{
            padding: var(--spacing-xs);
            text-align:center;
        }
        .seat{
            display:inline-block;
            width:42px;
            height:42px;
            line-height:42px;
            border-radius: 8px; /* Bo góc ghế */
            border: 1px solid #d1d5db;
            background: #f3f4f6; /* Nền ghế mặc định (chưa chọn) */
            color:#222;
            cursor:pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 100ms ease;
        }
        .seat.available{
            background: #D1FAE5; /* Xanh lá nhạt */
            border-color:#065F46;
            color:#065F46;
        }
        .seat.booked{
            background: #FEE2E2; /* Đỏ nhạt */
            border-color:#991B1B;
            color:#991B1B;
            cursor:not-allowed;
        }
        .seat.blocked{
            background: #e5e7eb;
            border-color:#9ca3af;
            color:#6b7280;
            cursor:not-allowed;
        }
        .seat.selected{
            background: var(--color-primary); /* Xanh đậm (màu chính) */
            color: var(--color-bg);
            border-color: var(--color-primary);
            transform: scale(1.05);
        }
        .seat input[type=checkbox]{
            display:none;
        }
        .legend{
            display:flex;
            flex-wrap: wrap;
            gap: var(--spacing-md);
            margin-top: var(--spacing-md);
            font-size:14px;
            color: var(--color-text);
        }
        .legend .box{
            width:18px;
            height:18px;
            display:inline-block;
            border-radius:4px;
            margin-right: var(--spacing-sm);
            vertical-align: middle;
        }
        .seat-summary{
            min-width:260px;
            padding: var(--spacing-md);
            border-radius: var(--radius-lg);
            background: var(--color-bg); /* Nền tóm tắt là trắng */
            box-shadow: var(--shadow-soft);
        }
        .seat-summary h3{
            margin-top:0;
            color: var(--color-primary);
        }
        .seat-list{
            list-style:none;
            padding:0;
            margin:0;
        }
        .seat-list li{
            margin: var(--spacing-sm) 0;
            font-size: 0.95rem;
        }

        /* Thông báo (Alerts) */
        .alert{
            padding: var(--spacing-md);
            border-radius: 12px;
            margin: var(--spacing-md) 0;
        }
        .alert.error{
            background:#FEE2E2;
            color:#991B1B;
            border:1px solid #FCA5A5;
        }
        .alert.success{
            background:#D1FAE5;
            color:#065F46;
            border:1px solid #6EE7B7;
        }


        /* --- Responsive (Mobile) --- */
        @media (max-width: 768px) {
            .main-header {
                padding: var(--spacing-md) var(--spacing-lg);
            }

            .main-header.scrolled { padding: var(--spacing-sm) var(--spacing-lg); }
            
            .header-logo { font-size: 1.7rem; }
            .header-user {
                font-size: 0.85rem;
            }

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

            .action-grid {
                grid-template-columns: 1fr;
                gap: var(--spacing-md);
            }

            /* [MỚI] Responsive cho thanh tìm kiếm */
            .search-form {
                flex-direction: column;
            }
            
            /* [MỚI] Responsive cho lưới phim */
            .movies-grid {
                /* Giảm kích thước min trên mobile */
                grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); /* <-- Đã giảm từ 150px */
                gap: var(--spacing-md);
            }
            
            .movie-card .movie-info {
                padding: var(--spacing-sm);
            }
            
            .movie-card .movie-info h3 {
                font-size: 1rem;
            }

            /* [MỚI] Responsive cho Sơ đồ ghế */
            .seat-map{
                flex-direction:column;
            }
            .seat-summary {
                min-width: 100%;
            }
            .seat {
                width: 32px;
                height: 32px;
                line-height: 32px;
                font-size: 0.8rem;
            }

            /* [MỚI] Responsive cho Modal */
            @media (max-width:640px){ 
                .modal-row{flex-direction:column} 
            }
        }
    </style>
</head>
<body>

    <%
        // Scriptlet kiểm tra xác thực người dùng
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp");
            return;
        }
        // Scriptlet lấy dữ liệu phim
        List<Movie> movies = (List<Movie>) request.getAttribute("movies");
        if (movies == null) movies = new java.util.ArrayList<>();
        String keyword = request.getParameter("keyword");
    %>

    <!-- Header Cố Định (Tái sử dụng từ MainSeller.jsp) -->
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
            
            <h1 class="card-title">Danh sách phim</h1>

            <!-- Thanh tìm kiếm -->
            <form action="<%=request.getContextPath()%>/searchMovie" method="get" class="search-form">
                <input type="text" name="keyword" placeholder="Nhập tên phim" value="<%= (keyword!=null)?keyword:"" %>" />
                <button class="btn btn-primary" type="submit">Tìm kiếm</button>
            </form>

            <!-- Lưới hiển thị phim -->
            <section class="movie-list">
                <% if (movies.isEmpty()) { %>
                    <!-- Trạng thái rỗng -->
                    <div class="empty-state">Không có phim phù hợp.</div>
                <% } else { %>
                    <!-- Lưới phim -->
                    <div class="movies-grid">
                    <% for (Movie m : movies) { %>
                        <div class="movie-card">
                            <div class="poster">
                                <%
                                    // Logic xử lý poster y hệt file gốc
                                    String posterValue = m.getPoster();
                                    String imgSrcFinal;
                                    if (posterValue != null && (posterValue.startsWith("http://") || posterValue.startsWith("https://"))) {
                                        imgSrcFinal = posterValue.trim();
                                    } else {
                                        String p = posterValue != null ? posterValue.trim() : "";
                                        if (!p.startsWith("/")) p = "/" + p;
                                        imgSrcFinal = request.getContextPath() + p;
                                    }
                                %>
                                <a href="<%=request.getContextPath()%>/schedule?movieId=<%=m.getId()%>">
                                    <img src="<%= imgSrcFinal %>" alt="poster" onerror="this.onerror=null;this.src='<%=request.getContextPath()%>/assets/img/logo.jpg'" />
                                </a>
                            </div>
                            <div class="movie-info">
                                <h3>
                                    <a class="movie-link" href="<%=request.getContextPath()%>/schedule?movieId=<%=m.getId()%>">
                                        <%= m.getName() %>
                                    </a>
                                </h3>
                                <p>Thể loại: <%= m.getCategory() %></p>
                                <p>Trạng thái: <%= m.getActive() == 1 ? "Đang chiếu" : "Ngưng chiếu" %></p>
                            </div>
                        </div>
                    <% } %>
                    </div>
                <% } %>
            </section>
        </div>
    </main>

    <script>
        // JavaScript cho hiệu ứng cuộn của Header
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