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
    
    <!-- External stylesheet for Register page -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/register.css" />
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

            <form id="register-form" class="register-form" method="post" action="<%=request.getContextPath()%>/register">
                
                <div class="register-grid">
                    
                    <!-- Hàng 1 -->
                    <div class="form-row">
                        <label for="fullName">Họ tên*</label>
                        <input id="fullName" type="text" name="fullName" value="<%= request.getAttribute("fullName") != null ? request.getAttribute("fullName") : "" %>" required />
                    </div>
                    <div class="form-row">
                        <label for="username">Tên đăng nhập*</label>
                        <input id="username" type="text" name="username" value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>" required />
                    </div>

                    <!-- Hàng 2 -->
                    <div class="form-row">
                        <label for="birthday">Ngày sinh*</label>
                        <input id="birthday" type="date" name="birthday" value="<%= request.getAttribute("birthday") != null ? request.getAttribute("birthday") : "" %>" required />
                        <div id="birthday-error" class="field-error"></div>
                    </div>
                    <div class="form-row">
                        <label for="gender">Giới tính*</label>
                        <select id="gender" name="gender" required>
                            <option value="">--Chọn--</option>
                            <option value="MALE" <%= "MALE".equals(request.getAttribute("gender"))?"selected":"" %>>Nam</option>
                            <option value="FEMALE" <%= "FEMALE".equals(request.getAttribute("gender"))?"selected":"" %>>Nữ</option>
                            <option value="OTHER" <%= "OTHER".equals(request.getAttribute("gender"))?"selected":"" %>>Khác</option>
                        </select>
                    </div>
                    
                    <!-- Hàng 3 -->
                    <div class="form-row">
                        <label for="phone">Số điện thoại*</label>
                        <input id="phone" type="text" name="phone" value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>" required />
                        <div id="phone-error" class="field-error"></div>
                        <div class="field-note">Ví dụ: 0901234567</div>
                    </div>
                    <div class="form-row">
                        <label for="email">Email*</label>
                        <input id="email" type="email" name="email" value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required />
                        <div id="email-error" class="field-error"></div>
                    </div>
                    
                    <!-- Hàng 4 (Mật khẩu & Xác nhận) -->
                    <div class="form-row">
                        <label for="password">Mật khẩu*</label>
                        <div class="password-wrapper">
                            <input id="password" type="password" name="password" required />
                            <button type="button" class="toggle-visibility" aria-label="Hiển thị mật khẩu" onclick="toggleVisibility('password', this)">
                                <svg class="eye-open" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#ffffff" stroke-width="1.2"/></svg>
                                <svg class="eye-closed" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:none"><path d="M17.94 17.94A10.94 10.94 0 0112 19c-6 0-10-7-10-7a20.27 20.27 0 013.59-4.14" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><path d="M1 1l22 22" stroke="#ffffff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                            </button>
                        </div>
                    </div>
                    <div class="form-row">
                        <label for="confirm">Xác nhận mật khẩu*</label>
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
        // Nếu đăng ký thành công và có mã thành viên, show popup rồi redirect về Trang chủ
        (function maybeRedirect(){
            var memberCode = '<%= request.getAttribute("memberCode") != null ? request.getAttribute("memberCode") : "" %>';
            var success = document.getElementById('register-success');
            if (memberCode && memberCode.length > 0) {
                // show popup with the member code and then redirect to login
                try {
                    alert('Đăng ký thành viên thành công. Mã thành viên của bạn là: ' + memberCode);
                } catch (e) {}
                window.location = '<%=request.getContextPath()%>/login';
                return;
            }
            // fallback: existing behavior - on generic success redirect to login after short delay
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