<!DOCTYPE html>
<html>
    <head>
        <title>BuyMe - Login</title>
        <link rel="stylesheet" href="css/style.css">
    </head>
    <body>
        <div class="container login-container">
            <h2>Welcome to BuyMe</h2>
            <form action="checkLoginDetails.jsp" method="POST">
                <label for="username">Username:</label>
                <input type="text" name="username" id="username" required/> <br/>
                <label for="password">Password:</label>
                <input type="password" name="password" id="password" required/> <br/>
                <input type="submit" value="Login"/>
            </form>
        </div>
    </body>
</html>