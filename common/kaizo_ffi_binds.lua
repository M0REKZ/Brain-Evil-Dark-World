-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

local ffi = require "ffi"
local glfw = ffi.os == 'Windows' and ffi.load( 'glfw3' ) or ffi.C

ffi.cdef [[
        enum {
            GLFW_CURSOR = 0x00033001,
            GLFW_CURSOR_NORMAL = 0x00034001,
            GLFW_CURSOR_HIDDEN = 0x00034002,
            GLFW_CURSOR_DISABLED = 0x00034003,
            GLFW_ARROW_CURSOR = 0x00036001,
            GLFW_IBEAM_CURSOR = 0x00036002,
            GLFW_CROSSHAIR_CURSOR = 0x00036003,
            GLFW_HAND_CURSOR = 0x00036004,
            GLFW_HRESIZE_CURSOR = 0x00036005,
            GLFW_VRESIZE_CURSOR = 0x00036006
        };
        typedef struct GLFWwindow GLFWwindow;
        typedef struct GLFWmonitor GLFWmonitor;
        typedef struct GLFWvidmode GLFWvidmode;
        GLFWwindow * os_get_glfw_window(void);
        void glfwSetInputMode(GLFWwindow* window, int mode, int value);
        GLFWmonitor * glfwGetPrimaryMonitor(void);
        GLFWmonitor ** glfwGetMonitors(int *count);
        void glfwGetMonitorWorkarea(GLFWmonitor *monitor, int *xpos, int *ypos, int *width, int *height);
        const GLFWvidmode * glfwGetVideoMode(GLFWmonitor *monitor);
        void glfwGetWindowPos(GLFWwindow *window, int *xpos, int *ypos);
        void glfwGetWindowSize(GLFWwindow *window, int *width, int *height);
        void glfwSetWindowSize(GLFWwindow *window, int width, int height);
        void glfwSetWindowMonitor(GLFWwindow * window, GLFWmonitor * monitor, int xpos, int ypos, int width, int height, int refreshRate);
        void glfwMaximizeWindow(GLFWwindow * window);
        void glfwRestoreWindow(GLFWwindow * window);
    ]]


function SetMouseGrabbed(enable)
    -- grab mouse, must replace with setMouseGrabbed in 0.19.0 later
    glfw.glfwSetInputMode(ffi.C.os_get_glfw_window(), ffi.C.GLFW_CURSOR, enable and ffi.C.GLFW_CURSOR_DISABLED or ffi.C.GLFW_CURSOR_NORMAL)
end

function SetFullscreen()
    KaizoSaveHandler.config.fullscreen = true
    if ffi.os == 'Windows' then --on windows set fullscreen freezes the game
        glfw.glfwMaximizeWindow(ffi.C.os_get_glfw_window())
    else
        local monitor_rectangle = ffi.new("int[4]")
        local monitor = glfw.glfwGetPrimaryMonitor()
        glfw.glfwGetMonitorWorkarea(monitor, monitor_rectangle, monitor_rectangle + 1, monitor_rectangle + 2, monitor_rectangle + 3)
        glfw.glfwSetWindowMonitor(ffi.C.os_get_glfw_window(), monitor, monitor_rectangle[0], monitor_rectangle[1], monitor_rectangle[2], monitor_rectangle[3], -1)
    end
end

function SetWindowed()
    KaizoSaveHandler.config.fullscreen = false
    if ffi.os == 'Windows' then --on windows set fullscreen freezes the game
        glfw.glfwRestoreWindow(ffi.C.os_get_glfw_window())
    else
        local window = ffi.C.os_get_glfw_window()
        glfw.glfwSetWindowMonitor(window, nil, 0, 0, 512, 256+128, -1)
    end
end

function GetMonitorArea()
    local monitor_rectangle = ffi.new("int[4]")
    local monitor = glfw.glfwGetPrimaryMonitor()
    glfw.glfwGetMonitorWorkarea(monitor, monitor_rectangle, monitor_rectangle + 1, monitor_rectangle + 2, monitor_rectangle + 3)
    return monitor_rectangle[0], monitor_rectangle[1], monitor_rectangle[2], monitor_rectangle[3]
end
