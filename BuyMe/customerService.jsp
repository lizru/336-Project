<%@ page import="java.sql.*" %>
<%
String role = (String)session.getAttribute("role");
Integer userId = (Integer)session.getAttribute("user_id");
Integer repId = (Integer)session.getAttribute("rep_id");

if (role == null) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Service</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">

<% if ("user".equals(role)) { %>
    <h2>Customer Service - Ask a Question</h2>
    
    <h3>Submit New Question</h3>
    <form method="POST">
        <input type="hidden" name="action" value="post">
        Title: <input type="text" name="title" size="50" required><br><br>
        Question: <br>
        <textarea name="question_text" rows="5" cols="60" required></textarea><br><br>
        <input type="submit" value="Submit Question">
    </form>
    
    <hr>
    <h3>My Questions</h3>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        PreparedStatement ps = con.prepareStatement(
            "SELECT q.question_id, q.title, q.question_text, q.date_posted, q.status, " +
            "r.reply_text, r.date_replied, cr.rep_name " +
            "FROM question q " +
            "LEFT JOIN reply r ON q.question_id = r.question_id " +
            "LEFT JOIN customer_representative cr ON r.rep_id = cr.rep_id " +
            "WHERE q.user_id = ? ORDER BY q.date_posted DESC"
        );
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            out.println("<div style='border:1px solid #ccc; padding:10px; margin:10px 0;'>");
            out.println("<h4>" + rs.getString("title") + "</h4>");
            out.println("<p><strong>Asked:</strong> " + rs.getTimestamp("date_posted") + " | <strong>Status:</strong> " + rs.getString("status") + "</p>");
            out.println("<p>" + rs.getString("question_text") + "</p>");
            if (rs.getString("reply_text") != null) {
                out.println("<hr><p><strong>Reply from " + rs.getString("rep_name") + ":</strong></p>");
                out.println("<p>" + rs.getString("reply_text") + "</p>");
                out.println("<p><em>" + rs.getTimestamp("date_replied") + "</em></p>");
            }
            out.println("</div>");
        }
        con.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
    %>

<% } else if ("rep".equals(role)) { %>
    <h2>Customer Service - Manage Questions</h2>
    <a href="repDashboard.jsp">Back to Dashboard</a>
    
    <h3>All User Questions</h3>
    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery(
            "SELECT q.question_id, q.title, q.question_text, q.date_posted, q.status, " +
            "u.username, q.user_id FROM question q JOIN user u ON q.user_id = u.user_id " +
            "ORDER BY q.date_posted DESC"
        );
        
        while (rs.next()) {
            int questionId = rs.getInt("question_id");
            out.println("<div style='border:1px solid #ccc; padding:10px; margin:10px 0;'>");
            out.println("<h4>" + rs.getString("title") + "</h4>");
            out.println("<p><strong>From:</strong> " + rs.getString("username") + " | <strong>Asked:</strong> " + rs.getTimestamp("date_posted") + " | <strong>Status:</strong> " + rs.getString("status") + "</p>");
            out.println("<p>" + rs.getString("question_text") + "</p>");
            
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT r.reply_text, r.date_replied, cr.rep_name FROM reply r " +
                "JOIN customer_representative cr ON r.rep_id = cr.rep_id WHERE r.question_id = ?"
            );
            ps2.setInt(1, questionId);
            ResultSet rs2 = ps2.executeQuery();
            
            if (rs2.next()) {
                out.println("<hr><p><strong>Reply from " + rs2.getString("rep_name") + ":</strong></p>");
                out.println("<p>" + rs2.getString("reply_text") + "</p>");
                out.println("<p><em>" + rs2.getTimestamp("date_replied") + "</em></p>");
            } else {
                out.println("<hr><form method='POST'>");
                out.println("<input type='hidden' name='action' value='reply'>");
                out.println("<input type='hidden' name='question_id' value='" + questionId + "'>");
                out.println("<textarea name='reply_text' rows='4' cols='60' required></textarea><br>");
                out.println("<input type='submit' value='Send Reply'>");
                out.println("</form>");
            }
            out.println("</div>");
        }
        con.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
    %>
<% } %>

<%
//  POST requests
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String action = request.getParameter("action");
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
        
        if ("post".equals(action) && userId != null) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO question (user_id, title, question_text, date_posted, status) VALUES (?, ?, ?, NOW(), 'open')"
            );
            ps.setInt(1, userId);
            ps.setString(2, request.getParameter("title"));
            ps.setString(3, request.getParameter("question_text"));
            ps.executeUpdate();
            out.println("<p style='color:green;'>Question submitted!</p>");
            
        } else if ("reply".equals(action) && repId != null) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO reply (question_id, rep_id, reply_text, date_replied) VALUES (?, ?, ?, NOW())"
            );
            ps.setInt(1, Integer.parseInt(request.getParameter("question_id")));
            ps.setInt(2, repId);
            ps.setString(3, request.getParameter("reply_text"));
            ps.executeUpdate();
            
            PreparedStatement ps2 = con.prepareStatement("UPDATE question SET status = 'answered' WHERE question_id = ?");
            ps2.setInt(1, Integer.parseInt(request.getParameter("question_id")));
            ps2.executeUpdate();
            
            out.println("<p style='color:green;'>Reply sent!</p>");
        }
        con.close();
        response.sendRedirect("customerService.jsp");
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
}
%>
</div>
</body>
</html>

</body>
</html>
