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

    <!-- Styles moved to external file to keep JSP clean -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/schedule.css">
    <!-- Provide background image via CSS variable so external CSS can use it -->
    <style>
        :root { --bg-image: url('<%=request.getContextPath()%>/assets/img/BG.png'); }
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
            
            <!-- Back button + title row -->
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                <a href="<%=request.getContextPath()%>/searchMovie" class="btn btn-secondary" style="height:40px;padding:8px 12px;font-size:0.95rem;">&larr; Quay lại</a>
                <div style="flex:1;text-align:center">
                    <h1 class="card-title" style="margin:0">Chọn lịch chiếu</h1>
                    <h2 class="card-subtitle" style="margin-top:6px"><%= (movie!=null) ? movie.getName() : "(Phim)" %></h2>
                </div>
                <div style="width:86px;">&nbsp;</div>
            </div>

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
                    
                    <%-- Tabbed date selector: today / tomorrow / day-after --%>
                    <%
                        // selectedDateParam provided by ScheduleServlet in yyyy-MM-dd format
                        String selectedDateParam = (String) request.getAttribute("selectedDateParam");
                        String selectedDateDisplay = (String) request.getAttribute("selectedDateDisplay");
                        java.util.Calendar calTab = java.util.Calendar.getInstance();
                        java.text.SimpleDateFormat sdfParam = new java.text.SimpleDateFormat("yyyy-MM-dd");
                        java.text.SimpleDateFormat sdfDisplay = new java.text.SimpleDateFormat("dd/MM/yyyy");
                        String d0 = sdfParam.format(calTab.getTime());
                        String d0disp = sdfDisplay.format(calTab.getTime());
                        calTab.add(java.util.Calendar.DATE, 1);
                        String d1 = sdfParam.format(calTab.getTime());
                        String d1disp = sdfDisplay.format(calTab.getTime());
                        calTab.add(java.util.Calendar.DATE, 1);
                        String d2 = sdfParam.format(calTab.getTime());
                        String d2disp = sdfDisplay.format(calTab.getTime());
                        if (selectedDateParam == null) selectedDateParam = d0; // default to today
                        if (selectedDateDisplay == null) {
                            try {
                                java.util.Date dd = java.sql.Date.valueOf(selectedDateParam);
                                selectedDateDisplay = sdfDisplay.format(dd);
                            } catch (Exception ex) {
                                selectedDateDisplay = d0disp;
                            }
                        }
                        int movieIdForLink = movie != null ? movie.getId() : -1;
                    %>

                    <div style="display:flex;gap:12px;align-items:center;margin-bottom:12px;">
                        <a class="date-tab <%= selectedDateParam.equals(d0) ? "active" : "" %>" href="<%=request.getContextPath()%>/schedule?movieId=<%=movieIdForLink%>&date=<%=d0%>" style="text-decoration:none;">
                            <% String d0short = d0disp != null && d0disp.length()>=5 ? d0disp.substring(0,5) : d0disp; %>
                            <% String d0day = d0short != null && d0short.length()>=2 ? d0short.substring(0,2) : ""; %>
                            <% String d0month = d0short != null && d0short.length()>=5 ? d0short.substring(3,5) : ""; %>
                            <div class="date-top"><span class="day-big"><%= d0day %></span><span class="day-small">/<%= d0month %></span></div>
                            <div class="day-label">Hôm nay</div>
                        </a>
                        <a class="date-tab <%= selectedDateParam.equals(d1) ? "active" : "" %>" href="<%=request.getContextPath()%>/schedule?movieId=<%=movieIdForLink%>&date=<%=d1%>" style="text-decoration:none;">
                            <% String d1short = d1disp != null && d1disp.length()>=5 ? d1disp.substring(0,5) : d1disp; %>
                            <% String d1day = d1short != null && d1short.length()>=2 ? d1short.substring(0,2) : ""; %>
                            <% String d1month = d1short != null && d1short.length()>=5 ? d1short.substring(3,5) : ""; %>
                            <div class="date-top"><span class="day-big"><%= d1day %></span><span class="day-small">/<%= d1month %></span></div>
                            <div class="day-label">Ngày mai</div>
                        </a>
                        <a class="date-tab <%= selectedDateParam.equals(d2) ? "active" : "" %>" href="<%=request.getContextPath()%>/schedule?movieId=<%=movieIdForLink%>&date=<%=d2%>" style="text-decoration:none;">
                            <% String d2short = d2disp != null && d2disp.length()>=5 ? d2disp.substring(0,5) : d2disp; %>
                            <% String d2day = d2short != null && d2short.length()>=2 ? d2short.substring(0,2) : ""; %>
                            <% String d2month = d2short != null && d2short.length()>=5 ? d2short.substring(3,5) : ""; %>
                            <div class="date-top"><span class="day-big"><%= d2day %></span><span class="day-small">/<%= d2month %></span></div>
                            <div class="day-label">Ngày kia</div>
                        </a>
                        <div style="margin-left:auto;color:rgba(255,255,255,0.9);font-weight:600">Suất chiếu — <%= selectedDateDisplay %></div>
                    </div>

                    <% if (schedules == null || schedules.isEmpty()) { %>
                        <div class="empty-state">Không có suất chiếu cho ngày này.</div>
                    <% } else { %>
                        <div class="showtimes-grid">
                            <%
                                // render schedules passed by servlet (already filtered for selected date)
                                for (Schedule s2 : schedules) {
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