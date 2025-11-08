<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Chính - Hệ thống Cinema</title>

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
            /* QUAN TRỌNG: Đường dẫn ảnh này cần phải đúng từ gốc của webapp.
              Nếu CSS ở ngoài, nó là '../img/BG.png'.
              Nếu CSS ở trong JSP, nó phải là đường dẫn tuyệt đối hoặc
              được giải quyết bằng JSTL/EL.
              Tôi sẽ tạm dùng đường dẫn tuyệt đối từ context path.
            */
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
            /* smaller header height */
            padding: var(--spacing-md) var(--spacing-xl);
            
            /* Glassmorphism -- ĐÃ BỎ BLUR VÀ LỚP TRONG SUỐT */
            background-color: var(--color-bg); /* Chuyển sang nền trắng đục */
            /* backdrop-filter: blur(6px); -- ĐÃ BỎ */
            /* -webkit-backdrop-filter: blur(6px); -- ĐÃ BỎ */
            
            transition: padding var(--transition-duration) ease, 
                        box-shadow var(--transition-duration) ease,
                        background-color var(--transition-duration) ease;
        }

        /* Trạng thái header khi cuộn */
        .main-header.scrolled {
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
            /* Reset kiểu của button để giống link */
            background: none;
            border: none;
            padding: 0;
            margin: 0;
            font: inherit; /* Lấy font từ .header-user */
            cursor: pointer;
            
            /* Áp dụng kiểu link */
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
            flex-grow: 1; /* Đẩy nội dung xuống (thay cho footer) */
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: var(--spacing-xl);
            /* Thêm padding top để không bị header che */
            padding-top: 120px; /* (Chiều cao header ~80px + khoảng đệm) */
            padding-bottom: 60px;
        }

        .content-card {
            width: 100%;
            max-width: 1100px;
            /* Frosted translucent panel */
            background-color: rgba(255, 255, 255, 0.06);
            border-radius: var(--radius-lg);
            padding: var(--spacing-xl) var(--spacing-xl); /* 32px */
            box-shadow: var(--shadow-soft);
            margin: var(--spacing-md) 0;
            border: 1px solid rgba(255,255,255,0.06);
            backdrop-filter: blur(10px) saturate(120%);
            -webkit-backdrop-filter: blur(10px) saturate(120%);
            color: #ffffff; /* force white text inside content (header excluded) */
        }

        /* Centralized title sizing */
        .card-title {
            color: #ffffff;
            font-size: 1.7rem; /* unified desktop size */
            font-weight: 700;
            margin-bottom: var(--spacing-lg);
            position: relative;
            padding-bottom: var(--spacing-sm);
            text-align: center;
        }

        /* --- Grid Nút Bấm --- */
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
            height: 48px; /* Đảm bảo vùng chạm > 44px */
            padding: 0 var(--spacing-lg);
            border-radius: 12px; /* Bo góc 12px */
            font-weight: 600;
            font-size: 1rem;
            text-decoration: none;
            border: 2px solid transparent;
            cursor: pointer;
            transition: all var(--transition-duration) ease;
        }

        /* Nút chính */
        .btn-primary {
            background-color: var(--color-primary);
            color: var(--color-bg);
            border-color: var(--color-primary);
        }

        /* Nút phụ */
        .btn-secondary {
            background-color: var(--color-bg);
            color: var(--color-primary);
            border-color: var(--color-primary);
        }

        /* Hiệu ứng Hover (cho cả 2 nút) */
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }

        /* Hỗ trợ Accessibility (Focus) */
        .btn:focus-visible {
            outline: none;
            box-shadow: var(--shadow-focus);
        }

        /* Nút phụ khi hover */
        .btn-secondary:hover {
             background-color: #fcfaff; /* Sáng lên 1 chút */
        }


        /* --- Responsive (Mobile) --- */
        @media (max-width: 768px) {
            .main-header {
                padding: var(--spacing-md) var(--spacing-lg);
            }

            .main-header.scrolled {
                padding: var(--spacing-sm) var(--spacing-lg);
            }
            
            .header-logo { font-size: 1.7rem; }
            .header-user {
                font-size: 0.85rem;
            }

            .main-content {
                padding: var(--spacing-lg);
                padding-top: 100px; /* Header mobile nhỏ hơn */
                align-items: flex-start; /* Gắn card lên trên trên mobile */
            }

            .content-card {
                padding: var(--spacing-lg) var(--spacing-md); /* 24px 16px */
                box-shadow: 0 4px 10px -5px rgba(0, 0, 0, 0.05); 
            }

            .card-title {
                font-size: 1.25rem; /* ~20px */
            }

            .action-grid {
                /* Rơi xuống 1 cột */
                grid-template-columns: 1fr;
                gap: var(--spacing-md);
            }
        }
    </style>
</head>
<body>

    <%
        // Scriptlet kiểm tra xác thực người dùng
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/Login.jsp"); // Chuyển hướng về Login.jsp
            return;
        }
    %>

    <!-- Header Cố Định -->
    <header class="main-header" id="mainHeader">
        <a href="<%=request.getContextPath()%>/mainSeller" class="header-logo">
            Hệ thống Cinema
        </a>
        <div class="header-user">
            <!-- Hiển thị tên người dùng động -->
            Xin chào, <span><%= user.getUsername() %></span>
            
            <!-- Form Đăng xuất (đã được style) -->
            <form action="<%=request.getContextPath()%>/login" method="post" class="logout-form">
                <button type="submit" class="logout-button">Đăng xuất</button>
            </form>
        </div>
    </header>

    <!-- Nội dung chính -->
    <main class="main-content">
        
        <!-- Card Chức Năng -->
        <div class="content-card">
            
            <h1 class="card-title">Chức năng chính</h1>

            <p>Vui lòng chọn một hành động để tiếp tục.</p>

            <div class="action-grid">
                <!-- Nút 1: Xuất thẻ thành viên -->
                <a href="<%=request.getContextPath()%>/customer" class="btn btn-primary">
                    Xuất thẻ thành viên
                </a>
                
                <!-- Nút 2: Bán vé tại quầy (với link động từ JSP) -->
                <a href="<%=request.getContextPath()%>/searchMovie" class="btn btn-secondary">
                    Bán vé tại quầy
                </a>
            </div>

        </div>

    </main>

    <!-- Footer đã được gỡ bỏ để khớp với file JSP gốc của bạn -->

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