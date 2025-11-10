<%@ page import="java.sql.*" %>
<% 
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/BuyMe", "root", "Linuxfs123!");
    Statement st = con.createStatement();
    ResultSet rs = st.executeQuery("SELECT * FROM admin WHERE admin_name='" + username + "' AND admin_password='" + password + "'");
    if (rs.next()) {
        session.setAttribute("user", username);
        out.println("welcome " + username);
        out.println("<a href='logout.jsp'>Log out</a>");
    } else {
        out.println("Invalid password <a href='login.jsp'>try again</a>");
    }

%>