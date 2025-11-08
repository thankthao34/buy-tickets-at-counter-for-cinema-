<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
	<meta charset="UTF-8" />
	<meta http-equiv="Content-Language" content="vi" />
	<title>Đăng nhập</title>
	<link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/style.css" />
	<!-- Load same fonts as other pages to ensure consistent typography -->
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/login.css" />
	<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
	<div class="login-page" style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:32px;">
		<div class="login-card">
			<header class="login-header">
				<div class="logo" aria-hidden="true">
					<!-- optional logo could go here -->
				</div>
				<h1>Hệ thống rạp chiếu phim</h1>
			</header>

			<div class="login-body">
				<h2 class="form-title">Đăng nhập thành viên</h2>

				<form method="post" action="<%=request.getContextPath()%>/login" class="login-form" novalidate>
					<div class="input-with-icon">
						<!-- user icon -->
						<span class="icon-left" aria-hidden="true">
							<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 12c2.761 0 5-2.239 5-5s-2.239-5-5-5-5 2.239-5 5 2.239 5 5 5z" stroke="#6b6b6b" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><path d="M20 21v-1c0-2.761-4.477-5-8-5s-8 2.239-8 5v1" stroke="#6b6b6b" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
						</span>
						<input type="text" id="username" name="username" placeholder="Tên đăng nhập" required />
					</div>

					<div class="input-with-icon">
						<!-- lock icon -->
						<span class="icon-left" aria-hidden="true">
							<svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="11" width="18" height="10" rx="2" stroke="#6b6b6b" stroke-width="1.2"/><path d="M7 11V8a5 5 0 0110 0v3" stroke="#6b6b6b" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
						</span>
						<input type="password" id="password" name="password" placeholder="Mật khẩu" required />
						<button type="button" class="icon-right" aria-label="Hiển thị mật khẩu" onclick="togglePassword()">
							<svg id="eye-open" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z" stroke="#6b6b6b" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="#6b6b6b" stroke-width="1.2"/></svg>
							<svg id="eye-closed" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="display:none"><path d="M17.94 17.94A10.94 10.94 0 0112 19c-6 0-10-7-10-7a20.27 20.27 0 013.59-4.14" stroke="#6b6b6b" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/><path d="M1 1l22 22" stroke="#6b6b6b" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
						</button>
					</div>

					<div class="form-row" style="display:flex;align-items:center;justify-content:space-between;margin-top:4px;">
						<label class="remember">
							<input type="checkbox" name="remember" value="1" /> Ghi nhớ tôi
						</label>
						<div>
							<button type="submit" class="btn login-primary">Đăng nhập</button>
						</div>
					</div>
				</form>

					<div class="login-links" style="margin-top:18px;text-align:center;">
					<div style="color:rgba(255,255,255,0.85);margin-bottom:8px;">Chưa có tài khoản? <a href="<%=request.getContextPath()%>/register" class="link-register">Đăng ký ngay</a></div>
				</div>

				<div class="login-error" style="margin-top:12px;">
					<% String error = (String) request.getAttribute("error"); if (error != null) { %>
						<div class="alert error"><%= error %></div>
					<% } %>
				</div>
			</div>
		</div>
	</div>

	<script>
		function togglePassword(){
			var pw = document.getElementById('password');
			var openIcon = document.getElementById('eye-open');
			var closedIcon = document.getElementById('eye-closed');
			if(pw.type === 'password'){
				pw.type = 'text';
				if(openIcon) openIcon.style.display = 'none';
				if(closedIcon) closedIcon.style.display = 'inline-block';
			} else {
				pw.type = 'password';
				if(openIcon) openIcon.style.display = 'inline-block';
				if(closedIcon) closedIcon.style.display = 'none';
			}
		}
	</script>
</body>
</html>
