package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.dao.*;
import model.Device;

import java.util.List;
import jakarta.servlet.RequestDispatcher;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/DeviceServlet")
public class DeviceListServlet extends HttpServlet {
    private DeviceDAO deviceDAO;

    public void init() {
        try {
            DBConnector dbConnector = new DBConnector();
            Connection connection = dbConnector.openConnection();
            deviceDAO = new DeviceDAO(connection);
        } catch (ClassNotFoundException | SQLException e) {
            Logger.getLogger(DeviceListServlet.class.getName()).log(Level.SEVERE, "Database connection error", e);
            throw new RuntimeException("Failed to initialize database connection", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Handle edit request
            if (request.getParameter("editId") != null) {
                int deviceId = Integer.parseInt(request.getParameter("editId"));
                Device deviceToEdit = deviceDAO.getDeviceById(deviceId);
                request.setAttribute("deviceToEdit", deviceToEdit);
            }

            // Handle search or get all devices
            if ("search".equals(request.getParameter("action"))) {
                String name = request.getParameter("searchName");
                String type = request.getParameter("searchType");
                List<Device> devices = deviceDAO.searchDevices(name, type);
                request.setAttribute("deviceList", devices);
            } else {
                List<Device> devices = deviceDAO.getAllDevices();
                request.setAttribute("deviceList", devices);
            }

            // Get unique device types for filter dropdown
            Set<String> deviceTypes = new HashSet<>();
            for (Device device : deviceDAO.getAllDevices()) {
                deviceTypes.add(device.getType());
            }
            request.setAttribute("deviceTypes", deviceTypes);

            RequestDispatcher dispatcher = request.getRequestDispatcher("main_dashboard.jsp");
            dispatcher.forward(request, response);
        } catch (SQLException e) {
            Logger.getLogger(DeviceListServlet.class.getName()).log(Level.SEVERE, "Error fetching devices", e);
            request.setAttribute("errorMessage", "Unable to fetch device list. Please try again later.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
            dispatcher.forward(request, response);
        } catch (NumberFormatException e) {
            Logger.getLogger(DeviceListServlet.class.getName()).log(Level.SEVERE, "Invalid device ID", e);
            request.setAttribute("errorMessage", "Invalid device ID.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
            dispatcher.forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        try {
            switch (action) {
                case "add":
                    Device newDevice = new Device(
                            0,
                            request.getParameter("name"),
                            request.getParameter("type"),
                            Double.parseDouble(request.getParameter("price")),
                            Integer.parseInt(request.getParameter("stock")));
                    deviceDAO.addDevice(newDevice);
                    break;

                case "update":
                    Device updatedDevice = new Device(
                            Integer.parseInt(request.getParameter("deviceId")),
                            request.getParameter("name"),
                            request.getParameter("type"),
                            Double.parseDouble(request.getParameter("price")),
                            Integer.parseInt(request.getParameter("stock")));
                    deviceDAO.updateDevice(updatedDevice);
                    break;

                case "delete":
                    int deviceId = Integer.parseInt(request.getParameter("deviceId"));
                    deviceDAO.deleteDevice(deviceId);
                    break;
            }

            response.sendRedirect("DeviceServlet");
        } catch (SQLException e) {
            Logger.getLogger(DeviceListServlet.class.getName()).log(Level.SEVERE, "Error performing device operation",
                    e);
            request.setAttribute("errorMessage", "Operation failed. Please try again.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
            dispatcher.forward(request, response);
        } catch (NumberFormatException e) {
            Logger.getLogger(DeviceListServlet.class.getName()).log(Level.SEVERE, "Invalid number format", e);
            request.setAttribute("errorMessage", "Invalid input format. Please check your values.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("error.jsp");
            dispatcher.forward(request, response);
        }
    }
}