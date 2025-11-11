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

    <!-- External CSS for MainSeller page -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/mainseller.css" />
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