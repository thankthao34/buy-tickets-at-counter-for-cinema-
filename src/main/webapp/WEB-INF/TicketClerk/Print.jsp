<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="model.OfflineBill" %>
<%@ page import="model.Ticket" %>
<%@ page import="model.TicketClerk" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    OfflineBill bill = (OfflineBill) request.getAttribute("offlineBill");
    if (bill == null) {
        response.sendRedirect(request.getContextPath() + "/ticketnBill");
        return;
    }
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    // create a single reusable reference to the first ticket to avoid duplicate local variable declarations
    model.Ticket first = null;
    if (bill.getTickets() != null && !bill.getTickets().isEmpty()) {
        first = bill.getTickets().get(0);
    }
    // precompute display values to avoid nested scriptlets in the HTML
        String movieName = "-";
        String dateStr = "-";
        String startTimeStr = "--:--";
        String endTimeStr = "--:--";
        String roomName = "-";
        if (first != null && first.getSeatSchedule() != null && first.getSeatSchedule().getSchedule() != null) {
            if (first.getSeatSchedule().getSchedule().getMovie() != null && first.getSeatSchedule().getSchedule().getMovie().getName() != null) {
                movieName = first.getSeatSchedule().getSchedule().getMovie().getName();
            }
            java.util.Date sd = first.getSeatSchedule().getSchedule().getDate();
            if (sd != null) {
                java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("dd/MM/yyyy");
                dateStr = df.format(sd);
            }
            if (first.getSeatSchedule().getSchedule().getStartTime() != null) startTimeStr = first.getSeatSchedule().getSchedule().getStartTime().toString();
            if (first.getSeatSchedule().getSchedule().getEndTime() != null) endTimeStr = first.getSeatSchedule().getSchedule().getEndTime().toString();
            if (first.getSeatSchedule().getSchedule().getRoom() != null && first.getSeatSchedule().getSchedule().getRoom().getName() != null) {
                roomName = first.getSeatSchedule().getSchedule().getRoom().getName();
            }
        }
        // points conversion: 1 point = 1000 VND
        float points = bill.getPointEx();
        float pointsVnd = points * 1000f;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hóa đơn - <%= bill.getId() %></title>
    <style>
        :root{ --accent:#2F3C7E; --muted:#666; --paper:#ffffff; }
        body{ font-family: 'Segoe UI', Roboto, Arial, sans-serif; background: #f3f4f6; padding: 24px; color:#111 }
        .invoice{ max-width:920px; margin:0 auto; background:var(--paper); border-radius:8px; box-shadow:0 6px 22px rgba(15,23,42,0.08); overflow:hidden }
        .invoice-header{ display:flex; justify-content:space-between; align-items:flex-start; padding:20px 28px; background:linear-gradient(90deg, rgba(47,60,126,0.04), rgba(47,60,126,0.01)); }
        .brand{ font-weight:700; color:var(--accent); font-size:1.25rem }
        .meta{ text-align:right; color:var(--muted) }
        .meta .big{ font-weight:700; color:#111; font-size:1.05rem }
        .body{ padding:20px 28px }
        .section{ margin-bottom:16px }
        .section h4{ margin:0 0 8px 0; font-size:0.95rem; color:var(--accent) }
        .grid{ display:flex; gap:12px; flex-wrap:wrap }
        .chip{ background:#fff; padding:10px 12px; border-radius:8px; border:1px solid #eee; min-width:200px }
        table{ width:100%; border-collapse:collapse; margin-top:8px }
        th, td{ padding:10px 12px; border-bottom:1px dashed #e6e6e6; text-align:left }
        th{ background:#fff; color:#111; font-weight:700 }
        tbody tr:nth-child(odd){ background: rgba(47,60,126,0.02) }
        .right{ text-align:right }
        .total-row td{ border-top:2px solid #ddd; font-weight:700 }
        .note{ color:var(--muted); font-size:0.9rem }
        .actions{ padding:16px 28px; display:flex; justify-content:space-between; align-items:center; gap:12px; background:#fff }
        .btn{ display:inline-block; padding:10px 16px; border-radius:8px; text-decoration:none; cursor:pointer; border:none }
        .btn-print{ background:var(--accent); color:#fff }
        .btn-back{ background:transparent; color:var(--accent); border:1px solid rgba(47,60,126,0.12); padding:9px 14px }
        @media print{ body{ background:#fff } .actions{ display:none } .invoice{ box-shadow:none; border:none } }
    </style>
</head>
<body>
    <div class="invoice">
        <div class="invoice-header">
            <div>
                <div class="brand">HỆ THỐNG CINEMA</div>
                <div class="note">HÓA ĐƠN BÁN VÉ (OFFLINE)</div>
            </div>
            <div class="meta">
                <div>Mã hóa đơn: <span class="big"><%= bill.getId() %></span></div>
                <div>Thời gian: <strong><%= bill.getCreateDate()!=null? bill.getCreateDate().format(dtf) : "-" %></strong></div>
            </div>
        </div>

        <div class="body">
            <div class="section">
                <h4>Nhân viên thực hiện</h4>
                <div class="chip"><%
                    TicketClerk tc = bill.getTicketClerk();
                    if (tc != null) {
                %>
                    <strong><%= tc.getFullName()!=null? tc.getFullName() : ("ID:"+tc.getId()) %></strong>
                    <div class="note">Mã NV: <%= tc.getCode()!=null? tc.getCode() : (tc.getId()>0? "ID:"+tc.getId(): "-") %></div>
                <% } else { %>
                    -
                <% } %>
                </div>
            </div>

            <div class="section">
                <h4>Thông tin phim / suất / phòng</h4>
                <div class="grid">
                    <div class="chip">
                        <div class="note">Phim</div>
                        <div><strong><%= movieName %></strong></div>
                    </div>

                    <div class="chip">
                        <div class="note">Suất (ngày & thời gian)</div>
                        <div>
                            <strong><%= dateStr %></strong> — <span class="note"><%= startTimeStr %> đến <%= endTimeStr %></span>
                        </div>
                    </div>

                    <div class="chip">
                        <div class="note">Phòng</div>
                        <div><strong><%= roomName %></strong></div>
                    </div>
                </div>
            </div>

            <div class="section">
                <h4>Chi tiết vé</h4>
                <table>
                    <thead>
                        <tr>
                            <th>Ghế</th>
                            <th>Loại ghế</th>
                            <th class="right">Giá (VND)</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (bill.getTickets()!=null && !bill.getTickets().isEmpty()) {
                        for (Ticket t : bill.getTickets()) {
                            String seatName = "-";
                            String seatType = "-";
                            if (t.getSeatSchedule()!=null && t.getSeatSchedule().getSeat()!=null) {
                                if (t.getSeatSchedule().getSeat().getName()!=null) seatName = t.getSeatSchedule().getSeat().getName();
                                float mul = t.getSeatSchedule().getSeat().getPriceMultiplier();
                                String desc = t.getSeatSchedule().getSeat().getDescription();
                                seatType = desc.trim();
                            }
                    %>
                        <tr>
                            <td><%= seatName %></td>
                            <td><%= seatType %></td>
                            <td class="right"><%= String.format("%,.0f", t.getPrice()) %> <small class="note">(đã bao gồm thuế)</small></td>
                        </tr>
                    <%  }
                    } else { %>
                        <tr><td colspan="3">Không có vé</td></tr>
                    <% } %>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="2">Điểm quy đổi: <strong><%= String.format("%,.0f", points) %></strong> (1 đ = 1.000 VND) — Giá trị quy đổi: <strong><%= String.format("%,.0f", pointsVnd) %> VND</strong></td>
                            <td class="right">&nbsp;</td>
                        </tr>
                        <tr class="total-row">
                            <td colspan="2">TỔNG</td>
                            <td class="right"><%= String.format("%,.0f", bill.getTotalPrice()) %> VND</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
            
        </div>

        <div class="actions">
            <div class="note">In để cung cấp cho khách hàng.</div>
            <div>
                <button class="btn btn-print" onclick="window.print();">In hóa đơn</button>
            </div>
        </div>
    </div>
</body>
</html>
