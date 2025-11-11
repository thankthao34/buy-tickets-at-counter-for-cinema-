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
    
    <!-- Styles moved to external file to keep JSP clean -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/seatmap.css">
    <!-- Set background image path via CSS variable so external CSS can use it -->
    <style>
        :root { --bg-image: url('<%=request.getContextPath()%>/assets/img/BG.png'); }
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