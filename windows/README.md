# Windows 文件

该目录包含 S-UI 在 Windows 平台的所有专用文件。

## 文件列表

- **s-ui-windows.xml**：Windows 服务配置
- **install-windows.bat**：安装脚本
- **s-ui-windows.bat**：控制面板脚本
- **uninstall-windows.bat**：卸载脚本
- **build-windows.bat**：适用于 CMD 的简易构建脚本
- **build-windows.ps1**：适用于 PowerShell 的高级构建脚本

## 使用方法

在 Windows 安装 S-UI：
1. 以管理员身份运行 `install-windows.bat`
2. 按安装向导完成安装
3. 使用 `s-ui-windows.bat` 进行管理

从源码构建：
- CMD：`build-windows.bat`
- PowerShell：`.\build-windows.ps1`
