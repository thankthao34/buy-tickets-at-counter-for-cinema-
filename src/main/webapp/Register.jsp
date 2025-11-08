<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // preserve UTF-8
    request.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta http-equiv="Content-Language" content="vi" />
    <title>Đăng ký - Hệ thống Cinema</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- Tải fonts (Giống các trang khác) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    
    <!-- Lồng CSS vào HTML (Sao chép 100% từ Seatmap.jsp + Thêm style cho form) -->
    <style>
        /* --- CSS Variables (Từ Seatmap.jsp) --- */
        :root {
            --font-primary: 'Inter', 'Poppins', sans-serif;
            --color-primary: #2F3C7E;
            --color-accent: #FBEAEB;
            --color-text: #0F172A;
            --color-bg: #FFFFFF;
            --color-danger: #e11d48;
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

        /* --- Global Reset & Base (Từ Seatmap.jsp) --- */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; }
        body {
            font-family: var(--font-primary);
            background-color: var(--color-text);
            color: var(--color-text);
            line-height: 1.55;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* --- Lớp phủ và Ảnh nền (Từ Seatmap.jsp) --- */
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

        /* --- Header (Từ Seatmap.jsp) --- */
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

        /* --- Main Content (Từ Seatmap.jsp) --- */
        .main-content {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start; /* Dính lên trên */
            width: 100%;
            padding: var(--spacing-lg);
            padding-top: 100px;
            padding-bottom: 60px; /* Thêm padding đáy */
        }
        
        /* Card kính mờ (Từ Seatmap.jsp) */
        .content-card {
            width: 100%;
            max-width: 900px; /* Card vừa phải cho form */
            background-color: rgba(255,255,255,0.12);
            border-radius: var(--radius-lg);
            padding: var(--spacing-lg);
            box-shadow: 0 14px 36px rgba(2,6,23,0.55);
            margin: 0;
            border: 1px solid rgba(255,255,255,0.08);
            backdrop-filter: blur(12px) saturate(120%);
            -webkit-backdrop-filter: blur(12px) saturate(120%);
            color: #ffffff;
        }

        /* Tiêu đề (Từ Seatmap.jsp) */
        .card-title {
            color: #ffffff;
            font-size: 1.7rem;
            font-weight: 700;
            margin-bottom: var(--spacing-lg); /* Tăng margin đáy */
            position: relative;
            padding-bottom: 0;
            text-align: center;
        }

        /* --- Nút bấm (Từ Seatmap.jsp) --- */
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
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }
        .btn:focus-visible {
            outline: none; box-shadow: var(--shadow-focus);
        }
        
        /* --- Style cho Form Đăng ký (2 Cột) --- */
        
        .register-grid {
            display: grid;
            grid-template-columns: 1fr 1fr; /* 2 cột */
            gap: var(--spacing-md) var(--spacing-lg); /* 16px dọc, 24px ngang */
            align-items: start; 
        }
        
        .form-row.full-width {
            grid-column: 1 / -1; 
        }
        
        .form-row {
            display: flex;
            flex-direction: column;
            gap: var(--spacing-xs); /* 4px giữa label và input */
        }
        
        .form-row label {
            font-size: 0.9rem;
            font-weight: 600;
            color: rgba(255, 255, 255, 0.9);
            margin-bottom: 2px;
        }
        
        /* Style cho inputs trên nền kính mờ */
        .form-row input[type="text"],
        .form-row input[type="email"],
        .form-row input[type="password"],
        .form-row input[type="date"],
        .form-row select {
            width: 100%;
            padding: 12px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.2); /* Viền trắng mờ */
            background: rgba(255, 255, 255, 0.1); /* Nền trắng mờ */
            color: #ffffff; /* Chữ trắng */
            font-size: 1rem;
            font-family: var(--font-primary);
        }
        
        /* Dropdown <option> cần nền trắng chữ đen */
        .form-row select option {
            color: var(--color-text); 
            background: var(--color-bg);
        }
        
        .form-row input::placeholder {
            color: rgba(255, 255, 255, 0.7);
        }

        .form-row input:focus,
        .form-row select:focus {
             outline: none;
             border-color: rgba(255, 255, 255, 0.5);
             box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.2);
        }

        /* Nút hiện/ẩn mật khẩu */
        .password-wrapper {
            position: relative;
        }
        .password-wrapper .toggle-visibility {
            position: absolute;
            right: 8px;
            top: 50%;
            transform: translateY(-50%);
            background: transparent;
            border: none;
            color: rgba(255,255,255,0.7);
            cursor: pointer;
            padding: 6px;
            font-family: var(--font-primary);
            font-size: 0.9rem;
        }
        .password-wrapper .toggle-visibility:hover {
            color: #ffffff;
        }
        
        /* Ghi chú & Lỗi (Style lại cho nền mờ) */
        .field-note { 
            font-size: 12px; 
            color: rgba(255, 255, 255, 0.75); 
        }
        .field-error { 
            font-size: 13px; 
            color: #FFB3B3; /* Đỏ nhạt (Hồng) */
            display: none; 
            font-weight: 600;
        }
        .password-hints { 
            font-size: 13px; 
            color: rgba(255, 255, 255, 0.9); 
        }
        .password-hints ul {
            margin: 6px 0 0 16px;
            padding: 0;
            display: flex;
            flex-direction: column; 
        }
        .password-hints li {
            list-style: none;
        }
        .password-hints li.valid { 
            color: #bfecc8; /* Xanh lá nhạt */
            text-decoration: line-through;
        }
        .password-hints li.invalid { 
            color: #ffb3b3; /* Đỏ nhạt (Hồng) */
        }
        .tooltip-note { 
            font-size: 12px; 
            color: rgba(255, 255, 255, 0.85); 
            font-weight: 400;
            margin-left: 8px; 
        }
        /* Toggle visibility button (eye icon) */
        .toggle-visibility{position:absolute;right:8px;top:50%;transform:translateY(-50%);background:transparent;border:0;padding:6px;display:inline-flex;align-items:center;justify-content:center;cursor:pointer;color:inherit}
        .toggle-visibility svg{width:18px;height:18px}
        
        /* Nút Submit */
        .btn-submit {
            min-width: 140px;
        }
        button[disabled] {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        /* [SỬA LỖI] Bố cục hàng cuối (checkbox và nút) */
        .actions-row {
            display: flex;
            flex-wrap: wrap; /* Cho phép xuống hàng trên mobile */
            align-items: center;
            justify-content: space-between;
            gap: var(--spacing-md);
            color: rgba(255,255,255,0.9);
            grid-column: 1 / -1; /* Kéo dài 2 cột */
            margin-top: var(--spacing-sm); /* Thêm margin top */
        }
        .actions-row .agree-group {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
        }
        .actions-row input[type="checkbox"] {
            width: 16px;
            height: 16px;
            accent-color: var(--color-primary);
        }
        .actions-row label {
            font-size: 1rem;
            font-weight: 400;
            color: rgba(255,255,255,0.9);
            margin-bottom: 0; /* Ghi đè margin */
        }
        .actions-row label a {
            color: #FFFFFF;
            font-weight: 600;
        }
        
        /* [THAY ĐỔI] Nhóm bên phải (Nút + Link) */
        .actions-right-group {
            display: flex;
            align-items: center;
            gap: var(--spacing-lg);
            flex-wrap: wrap; /* Cho phép xuống hàng nếu không đủ chỗ */
        }
        
        /* Link đăng nhập */
        .login-link {
            /* Bỏ margin-top */
            text-align: center;
            color: rgba(255,255,255,0.8);
            font-size: 0.95rem;
        }
        .login-link a {
            color: #ffffff;
            font-weight: 600;
            text-decoration: none;
        }
        .login-link a:hover { text-decoration: underline; }
        
        /* Thông báo (Alerts) (Style lại cho nền mờ) */
        .alert{
            padding: var(--spacing-md);
            border-radius: 12px;
            font-weight: 600;
            margin-bottom: var(--spacing-lg);
            color: var(--color-text); /* Chữ đen/đậm */
        }
        .alert.error { 
            background: #FEE2E2; 
            color: #991B1B; 
            border: 1px solid #FCA5A5; 
        }
        .alert.success { 
            background: #D1FAE5; 
            color: #065F46; 
            border: 1px solid #6EE7B7; 
        }

        /* --- Responsive (Di động) --- */
        @media (max-width: 768px) {
            .main-content {
                padding: var(--spacing-sm);
                padding-top: 80px;
                padding-bottom: var(--spacing-lg);
            }
            .content-card {
                padding: var(--spacing-md);
            }
            .card-title { font-size: 1.25rem; }
            
            .header-logo { grid-column: 1 / 2; justify-self: start; font-size: 1.1rem; }
            .header-user { font-size: 0.8rem; }
            
            /* [MỚI] Responsive cho form đăng ký */
            .register-grid {
                grid-template-columns: 1fr; /* 1 cột trên mobile */
            }
            
            /* [MỚI] Responsive cho hàng cuối (checkbox/nút) */
            .actions-row {
                flex-direction: column;
                align-items: stretch; /* Kéo dài 100% */
                gap: var(--spacing-md);
            }
            .actions-right-group {
                flex-direction: column;
                align-items: stretch;
                gap: var(--spacing-md);
            }
            .actions-row .btn-submit {
                width: 100%; /* Nút 100% */
            }
            .login-link {
                margin-top: 0;
            }
        }
    </style>
</head>
<body>

    <!-- Header (Giống các trang khác) -->
    <header class="main-header" id="mainHeader">
        <a href="<%=request.getContextPath()%>/MainSeller.jsp" class="header-logo">
            Hệ thống Cinema
        </a>
        <!-- Không có user, ẩn phần user đi -->
    </header>

    <!-- Nội dung chính -->
    <main class="main-content">
        
        <!-- Card kính mờ -->
        <div class="content-card">
            
            <h1 class="card-title">Đăng ký thành viên</h1>

            <!-- Hiển thị lỗi/thành công (Từ code gốc) -->
            <div>
                <% String error = (String) request.getAttribute("error"); %>
                <% String success = (String) request.getAttribute("success"); %>
                <% if (error != null) { %>
                    <div class="alert error"><%= error %></div>
                <% } %>
                <% if (success != null) { %>
                    <div id="register-success" class="alert success"><%= success %></div>
                <% } %>
            </div>

            <!-- Form Đăng Ký (Sắp xếp lại) -->
            <form id="register-form" class="register-form" method="post" action="<%=request.getContextPath()%>/register">
                
                <div class="register-grid">
                    
                    <!-- Hàng 1 -->
                    <div class="form-row">
                        <label for="fullName">Họ tên</label>
                        <input id="fullName" type="text" name="fullName" value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>" required />
                    </div>
                    <div class="form-row">
                        <label for="username">Tên đăng nhập</label>
                        <input id="username" type="text" name="username" value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>" required />
                    </div>

                    <!-- Hàng 2 -->
                    <div class="form-row">
                        <label for="birthday">Ngày sinh</label>
                        <input id="birthday" type="date" name="birthday" value="<%= request.getAttribute("birthday") != null ? request.getAttribute("birthday") : "" %>" required />
                        <div id="birthday-error" class="field-error"></div>
                    </div>
                    <div class="form-row">
                        <label for="gender">Giới tính</label>
                        <select id="gender" name="gender" required>
                            <option value="">--Chọn--</option>
                            <option value="MALE" <%= "MALE".equals(request.getAttribute("gender"))?"selected":"" %>>Nam</option>
                            <option value="FEMALE" <%= "FEMALE".equals(request.getAttribute("gender"))?"selected":"" %>>Nữ</option>
                            <option value="OTHER" <%= "OTHER".equals(request.getAttribute("gender"))?"selected":"" %>>Khác</option>
                        </select>
                    </div>
                    
                    <!-- Hàng 3 -->
                    <div class="form-row">
                        <label for="phone">Số điện thoại</label>
                        <input id="phone" type="text" name="phone" value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>" required />
                        <div id="phone-error" class="field-error"></div>
                        <div class="field-note">Ví dụ: 0901234567</div>
                    </div>
                    <div class="form-row">
                        <label for="email">Email</label>
                        <input id="email" type="email" name="email" value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required />
                        <div id="email-error" class="field-error"></div>
                    </div>
                    
                    <!-- Hàng 4 (Mật khẩu & Xác nhận) -->
                    <div class="form-row">
                        <label for="password">Mật khẩu</label>
                        <div class="password-wrapper">
                            <input id="password" type="password" name="password" required />
                            <button type="button" class="toggle-visibility" aria-label="Hiển thị mật khẩu" onclick="toggleVisibility('password', this)">
                                <svg class="eye-open" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#ffffff" stroke-width="1.2"/></svg>
                                <svg class="eye-closed" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:none"><path d="M17.94 17.94A10.94 10.94 0 0112 19c-6 0-10-7-10-7a20.27 20.27 0 013.59-4.14" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><path d="M1 1l22 22" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                            </button>
                        </div>
                    </div>
                    <div class="form-row">
                        <label for="confirm">Xác nhận mật khẩu</label>
                        <div class="password-wrapper">
                            <input id="confirm" type="password" name="confirm" required />
                            <button type="button" class="toggle-visibility" aria-label="Hiển thị mật khẩu xác nhận" onclick="toggleVisibility('confirm', this)">
                                <svg class="eye-open" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#ffffff" stroke-width="1.2"/></svg>
                                <svg class="eye-closed" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:none"><path d="M17.94 17.94A10.94 10.94 0 0112 19c-6 0-10-7-10-7a20.27 20.27 0 013.59-4.14" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><path d="M1 1l22 22" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                            </button>
                        </div>
                        <div id="confirm-error" class="field-error"></div>
                    </div>

                    <!-- Hàng 5 (Gợi ý mật khẩu - 1 cột) -->
                    <div class="form-row full-width">
                        <div id="password-hints" class="password-hints">
                            <ul>
                                <li id="ph-length" class="invalid">Ít nhất 8 ký tự</li>
                                <li id="ph-upper" class="invalid">Ít nhất 1 chữ hoa (A-Z)</li>
                                <li id="ph-lower" class="invalid">Ít nhất 1 chữ thường (a-z)</li>
                                <li id="ph-digit" class="invalid">Ít nhất 1 chữ số (0-9)</li>
                            </ul>
                        </div>
                    </div>
                
                    <!-- [THAY ĐỔI] Hàng 6: Checkbox, Nút, Link (cùng 1 hàng) -->
                    <div class="form-row full-width actions-row">
                        
                        <!-- Nhóm 1: Checkbox -->
                        <div class="agree-group">
                            <input id="agree" type="checkbox" name="agree" value="1" />
                            <label for="agree">Tôi đồng ý với <a href="<%=request.getContextPath()%>/assets/quydinh.pdf" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation();">điều khoản</a></label>
                        </div>
                        
                        <!-- Nhóm 2: Nút và Link -->
                        <div class="actions-right-group">
                            <div class="login-link">
                                Đã có tài khoản? <a href="<%=request.getContextPath()%>/login">Đăng nhập</a>
                            </div>
                            <div>
                                <button id="register-btn" type="submit" class="btn btn-primary btn-submit" disabled>Đăng ký</button>
                            </div>
                        </div>
                        
                    </div>
                    
                </div> <!-- end .register-grid -->
            </form>
            
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
    
    <!-- JavaScript Validation (Giữ nguyên từ code gốc, đã chỉnh sửa 1 chút) -->
    <script>
        // Nếu đăng ký thành công, chuyển hướng về login
        (function maybeRedirect(){
            var success = document.getElementById('register-success');
            if(success){
                setTimeout(function(){ window.location = '<%=request.getContextPath()%>/login'; }, 2000);
            }
        })();

        // Logic Validation (IIFE)
        (function(){
            var birthdayInput = document.getElementById('birthday');
            var birthdayError = document.getElementById('birthday-error');
            var registerBtn = document.getElementById('register-btn');
            var emailInput = document.getElementById('email');
            var emailError = document.getElementById('email-error');
            var phoneInput = document.getElementById('phone');
            var phoneError = document.getElementById('phone-error');
            var passwordInput = document.getElementById('password');
            var confirmInput = document.getElementById('confirm');
            var confirmError = document.getElementById('confirm-error');
            var phLength = document.getElementById('ph-length');
            var phUpper = document.getElementById('ph-upper');
            var phLower = document.getElementById('ph-lower');
            var phDigit = document.getElementById('ph-digit');
            var agreeCheckbox = document.getElementById('agree');
            var form = document.getElementById('register-form');

            function setFieldError(elem, msg){
                if(!elem) return;
                elem.style.display = msg ? 'block' : 'none';
                elem.textContent = msg || '';
            }

            function validateBirthday(){
                var v = birthdayInput.value;
                if(!v){ setFieldError(birthdayError,'Vui lòng nhập ngày sinh.'); return false; }
                var parts = v.split('-');
                if(parts.length !== 3){ setFieldError(birthdayError,'Định dạng ngày không hợp lệ.'); return false; }
                var y = parseInt(parts[0],10);
                var m = parseInt(parts[1],10)-1;
                var d = parseInt(parts[2],10);
                var bd = new Date(y,m,d);
                if(isNaN(bd.getTime())){ setFieldError(birthdayError,'Ngày sinh không hợp lệ.'); return false; }
                var today = new Date();
                var age = today.getFullYear() - bd.getFullYear();
                var m_diff = today.getMonth() - bd.getMonth();
                if (m_diff < 0 || (m_diff === 0 && today.getDate() < bd.getDate())) {
                    age--;
                }
                if(age < 13){ setFieldError(birthdayError,'Bạn phải từ 13 tuổi trở lên để đăng ký.'); return false; }
                setFieldError(birthdayError,''); return true;
            }

            function validateEmail(){
                var v = emailInput.value.trim();
                if(!v){ setFieldError(emailError,'Vui lòng nhập email.'); return false; }
                var re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if(!re.test(v)){ setFieldError(emailError,'Email không hợp lệ.'); return false; }
                setFieldError(emailError,''); return true;
            }

            function validatePhone(){
                var v = phoneInput.value.trim();
                if(!v){ setFieldError(phoneError,'Vui lòng nhập số điện thoại.'); return false; }
                var digits = v.replace(/[^0-9]/g, '');
                if(digits.length < 9 || digits.length > 13){ setFieldError(phoneError,'Số điện thoại không hợp lệ (9-13 chữ số).'); return false; }
                setFieldError(phoneError,''); return true;
            }

            function validatePassword(){
                var v = passwordInput.value || '';
                var okLen = v.length >= 8;
                var okUpper = /[A-Z]/.test(v);
                var okLower = /[a-z]/.test(v);
                var okDigit = /[0-9]/.test(v);
                
                // [THAY ĐỔI] Dùng class thay vì style
                phLength.className = okLen ? 'valid' : 'invalid';
                phUpper.className = okUpper ? 'valid' : 'invalid';
                phLower.className = okLower ? 'valid' : 'invalid';
                phDigit.className = okDigit ? 'valid' : 'invalid';
                
                return okLen && okUpper && okLower && okDigit;
            }

            function validateConfirm(){
                if(confirmInput.value !== passwordInput.value){ setFieldError(confirmError,'Mật khẩu xác nhận không khớp.'); return false; }
                setFieldError(confirmError,''); return true;
            }

            function validateAgree(){
                return agreeCheckbox.checked;
            }

            function validateAll(){
                // Chạy tất cả validation để hiển thị lỗi (nếu có)
                const b = validateBirthday();
                const e = validateEmail();
                const p = validatePhone();
                const pw = validatePassword();
                const c = validateConfirm();
                const a = validateAgree();
                
                var allValid = b && e && p && pw && c && a;
                registerBtn.disabled = !allValid;
                return allValid;
            }

            // Gắn sự kiện
            birthdayInput.addEventListener('change', validateAll);
            birthdayInput.addEventListener('blur', validateAll);
            emailInput.addEventListener('input', validateAll);
            phoneInput.addEventListener('input', validateAll);
            passwordInput.addEventListener('input', validateAll);
            confirmInput.addEventListener('input', validateAll);
            agreeCheckbox.addEventListener('change', validateAll);

            form.addEventListener('submit', function(e){
                if(!validateAll()){
                    e.preventDefault();
                    // Tự động focus vào trường lỗi đầu tiên
                    if(!validateBirthday()) { birthdayInput.focus(); }
                    else if(!validateEmail()) { emailInput.focus(); }
                    else if(!validatePhone()) { phoneInput.focus(); }
                    else if(!validatePassword()) { passwordInput.focus(); }
                    else if(!validateConfirm()) { confirmInput.focus(); }
                }
            });
            
            // Chạy lần đầu khi tải trang (nếu có giá trị cũ)
            validateAll();
        })();

        // Toggle visibility helper (using inline SVG icons)
        function toggleVisibility(fieldId, btn) {
            var f = document.getElementById(fieldId);
            if (!f) return;
            var openIcon = btn.querySelector('.eye-open');
            var closedIcon = btn.querySelector('.eye-closed');
            if (f.type === 'password') {
                f.type = 'text';
                if (openIcon) openIcon.style.display = 'none';
                if (closedIcon) closedIcon.style.display = 'inline-block';
            } else {
                f.type = 'password';
                if (openIcon) openIcon.style.display = 'inline-block';
                if (closedIcon) closedIcon.style.display = 'none';
            }
            f.focus();
        }
    </script>
</body>
</html>