<%@ page import="java.sql.*" %>
<%
if (!"rep".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage User Accounts</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2>Manage User Accounts</h2>
    <a href="repDashboard.jsp">Back to Dashboard</a>
    
    <h3>Search User</h3>
    <form method="GET">
        User ID: <input type="number" name="user_id" required>
        <input type="submit" value="Search">
    </form>
    
    <%
    String userIdParam = request.getParameter("user_id");
    String action = request.getParameter("action");
    
    // Display user info for editing
    if (userIdParam != null && action == null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
            
            PreparedStatement ps = con.prepareStatement("SELECT * FROM user WHERE user_id = ?");
            ps.setInt(1, Integer.parseInt(userIdParam));
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                out.println("<hr><h3>Edit User Information</h3>");
                out.println("<form method='POST'>");
                out.println("<input type='hidden' name='action' value='edit'>");
                out.println("<input type='hidden' name='user_id' value='" + rs.getInt("user_id") + "'>");
                out.println("Username: <input type='text' name='username' value='" + rs.getString("username") + "' required><br><br>");
                out.println("Email: <input type='text' name='email' value='" + rs.getString("email") + "' required><br><br>");
                out.println("Full Name: <input type='text' name='full_name' value='" + (rs.getString("full_name") != null ? rs.getString("full_name") : "") + "'><br><br>");
                out.println("Address: <input type='text' name='address' value='" + (rs.getString("address") != null ? rs.getString("address") : "") + "'><br><br>");
                out.println("Phone: <input type='text' name='phone_num' value='" + (rs.getString("phone_num") != null ? rs.getString("phone_num") : "") + "' maxlength='10'><br><br>");
                out.println("<input type='submit' value='Update User'>");
                out.println("</form>");
                
                out.println("<hr><h3>Delete User</h3>");
                out.println("<div style='border:2px solid red; padding:10px;'>");
                out.println("<p style='color:red;'><strong>WARNING: This will permanently delete the user and all related data!</strong></p>");
                out.println("<form method='POST'>");
                out.println("<input type='hidden' name='action' value='delete'>");
                out.println("<input type='hidden' name='user_id' value='" + rs.getInt("user_id") + "'>");
                out.println("<input type='submit' value='DELETE USER' style='background:red; color:white;'>");
                out.println("</form>");
                out.println("</div>");
            } else {
                out.println("<p style='color:red;'>User not found!</p>");
            }
            con.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        }
    }
    
    // POST requests
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        action = request.getParameter("action");
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
            
            if ("edit".equals(action)) {
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE user SET username=?, email=?, full_name=?, address=?, phone_num=? WHERE user_id=?"
                );
                ps.setString(1, request.getParameter("username"));
                ps.setString(2, request.getParameter("email"));
                ps.setString(3, request.getParameter("full_name"));
                ps.setString(4, request.getParameter("address"));
                ps.setString(5, request.getParameter("phone_num"));
                ps.setInt(6, Integer.parseInt(request.getParameter("user_id")));
                ps.executeUpdate();
                
                out.println("<p style='color:green;'>User updated successfully!</p>");
                
            } else if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("user_id"));
                
                Statement st = con.createStatement();
                st.executeUpdate("DELETE FROM alert WHERE user_id = " + userId);
                st.executeUpdate("DELETE FROM bid WHERE user_id = " + userId);
                st.executeUpdate("DELETE FROM assists WHERE user_id = " + userId);
                st.executeUpdate("DELETE FROM buys WHERE user_id = " + userId);
                st.executeUpdate("DELETE FROM sells WHERE user_id = " + userId);
                st.executeUpdate("DELETE FROM reply WHERE question_id IN (SELECT question_id FROM question WHERE user_id = " + userId + ")");
                st.executeUpdate("DELETE FROM question WHERE user_id = " + userId);
                st.executeUpdate("DELETE FROM user WHERE user_id = " + userId);
                
                out.println("<p style='color:green;'>User deleted successfully!</p>");
            }
            
            con.close();
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
