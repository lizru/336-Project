<%@ page import="java.sql.*" %>
<% 
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
    Statement st = con.createStatement();
    
    // Check admin table
    ResultSet rs = st.executeQuery("SELECT * FROM admin WHERE admin_name='" + username + "' AND admin_password='" + password + "'");
    if (rs.next()) {
        session.setAttribute("user", username);
        session.setAttribute("role", "admin");
        out.println("<script>alert('Login successful');</script>");
        response.sendRedirect("admin.jsp");
        return;
    }
    rs.close();
    
    // Check user table
    rs = st.executeQuery("SELECT * FROM user WHERE username='" + username + "' AND user_password='" + password + "'");
    if (rs.next()) {
        String userRole = rs.getString("user_role");
        session.setAttribute("user", username);
        session.setAttribute("role", userRole);
        out.println("<script>alert('Login successful');</script>");
        response.sendRedirect("success.jsp");
        return;
    }
    rs.close();
    st.close();
    con.close();
    
    out.println("<script>alert('Invalid username or password'); window.location='login.jsp';</script>");
%>