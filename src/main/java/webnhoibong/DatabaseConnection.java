/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package webnhoibong;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author hathuu24
 */
public class DatabaseConnection {
    private static final String URL =
        "jdbc:mysql://127.0.0.1:3306/nhoibong"
        + "?useUnicode=true&characterEncoding=UTF-8"
        + "&serverTimezone=Asia/Ho_Chi_Minh"
        + "&useSSL=false&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASS = "1234"; 

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                "Thiếu driver MySQL (mysql-connector-j). Hãy thêm JAR vào WEB-INF/lib hoặc Maven dependency.", e);
        } catch (SQLException e) {
            throw new RuntimeException("Không kết nối được MySQL: " + e.getMessage(), e);
        }
    }
}
