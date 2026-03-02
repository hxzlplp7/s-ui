# 参与贡献 S-UI

感谢你对 S-UI 的关注与贡献。本指南说明如何搭建开发环境、遵循项目约定并提交变更。你的贡献会让 **multi-inbound-per-user（单用户多入站）** 及整个项目变得更好。

## 目录

- [行为准则](#行为准则)
- [开发环境搭建](#开发环境搭建)
- [编码规范与风格指南](#编码规范与风格指南)
- [测试](#测试)
- [需要帮助的功能方向](#需要帮助的功能方向)
- [Pull Request 流程](#pull-request-流程)
- [在你的仓库中启用本指南](#在你的仓库中启用本指南)
- [报告 Bug 与功能请求](#报告-bug-与功能请求)

---

## 行为准则

与维护者和其他贡献者交流时，请保持尊重、建设性。本项目用于个人学习与交流，请合法、负责地使用。

---

## 开发环境搭建

### 前置要求

- **Go**：1.25 或更高（准确版本见 `go.mod`）。
- **Git**：用于克隆仓库和子模块。
- **C 编译器**：CGO 需要（如 `gcc`，Alpine 下可用 `musl-dev`）。
- **Node.js**（可选）：仅在你要开发或重建前端时需要。仓库也可使用预编译前端资源运行。

### 克隆与子模块

```bash
git clone https://github.com/alireza0/s-ui
cd s-ui
git submodule update --init --recursive
```

**frontend** 位于子模块中。如果你只开发后端，可直接使用现有 `web/html` 内容，或先构建一次前端（见下文）。

### 仅后端开发（最快路径）

1. 使用脚本构建并运行（构建后端，使用 debug + 本地 DB 运行）：

   ```bash
   ./runSUI.sh
   ```

   该脚本会执行 `./build.sh`，然后运行 `SUI_DB_FOLDER="db" SUI_DEBUG=true ./sui`。

2. 或手动构建：

   ```bash
   ./build.sh
   SUI_DB_FOLDER=db SUI_DEBUG=true ./sui
   ```

   默认面板地址：**http://localhost:2095/app/**（用户名 `admin`，密码 `admin`，生产环境请务必修改）。

### 全栈开发（后端 + 前端）

1. **前端**（子模块中的独立仓库）：

   ```bash
   cd frontend
   npm install
   npm run build
   cd ..
   ```

2. **替换 Web 静态资源并构建后端**：

   ```bash
   mkdir -p web/html
   rm -rf web/html/*
   cp -R frontend/dist/* web/html/
   go build -ldflags "-w -s" -tags "with_quic,with_grpc,with_utls,with_acme,with_gvisor" -o sui main.go
   ```

3. 运行：

   ```bash
   SUI_DB_FOLDER=db SUI_DEBUG=true ./sui
   ```

### Build Tags

后端完整功能构建使用以下 tags：

- `with_quic`、`with_grpc`、`with_utls`、`with_acme`、`with_gvisor`

若你希望本地行为与发布版本一致，请使用同样的 tags 构建。

### 环境变量（开发）

| 变量 | 说明 | 示例 |
|----------------|--------------------------------|-----------|
| `SUI_DB_FOLDER`| SQLite DB 文件目录 | `db` |
| `SUI_DEBUG` | 启用调试模式 | `true` |
| `SUI_LOG_LEVEL`| 日志级别 | `debug` |
| `SUI_BIN_FOLDER` | 可执行文件目录 | `bin` |

### Docker（可选）

```bash
git clone https://github.com/alireza0/s-ui
cd s-ui
git submodule update --init --recursive
docker build -t s-ui .
# 或: docker compose up -d
```

---

## 编码规范与风格指南

### 通用

- 编写清晰、可维护的代码，优先小而专注的函数和包。
- 为不直观逻辑和公开 API 添加必要注释。
- 显式处理错误；除非有意为之，不要忽略 `err`。

### Go 风格

- 遵循 **标准 Go 风格** 与 **[Effective Go](https://go.dev/doc/effective_go)**。
- 提交前运行 **gofmt**（或 **goimports**）：

  ```bash
  gofmt -w .
  # 或: goimports -w .
  ```

- 非导出名称使用 **camelCase**，导出名称使用 **PascalCase**。
- 包名保持简短小写（如 `api`、`service`、`util`）。
- import 分组顺序：标准库、第三方库、项目内包（与现有文件保持一致）。

### 项目结构约定

- **`api/`**：HTTP 处理器与 API 路由（如 `apiHandler.go`、`apiV2Handler.go`）。
- **`service/`**：业务逻辑与面板/核心操作。
- **`database/model/`**：GORM 模型与数据库实体。
- **`util/`**：共享工具（如链接/订阅转换、JSON 相关）。
- **`core/`**：sing-box 集成与核心运行时。
- **`sub/`**：订阅（link/json）处理。

新增功能时，请按层放置代码（handler → service → model/util），避免循环依赖。

### 命名与模式

- Handler：后缀 `Handler`（如 `APIHandler`、`APIv2Handler`）。
- Service：后缀 `Service` 或按包名命名（如 `ApiService`、`LinkService`）。
- Model：结构体命名清晰，JSON/gorm tag 合理（参考 `database/model/`）。

---

## 测试

### 当前状态

- 项目目前尚无正式测试套件（仓库中暂无 `*_test.go`）。
- CI 当前主要关注 **构建**（如 `release.yml`），而非自动化测试。

### 你现在可以做的

1. **构建验证**：提交 PR 前先确认项目可构建：

   ```bash
   go build -ldflags "-w -s" -tags "with_quic,with_grpc,with_utls,with_acme,with_gvisor" -o sui main.go
   ```

2. **手动测试**：用 `./runSUI.sh` 运行，重点测试你改动的模块（面板、API、订阅等）。

3. **未来测试建设**：非常欢迎补充 **单元测试**（如 `util/`、`service/`、API handlers）和 **集成测试**。建议优先使用标准库 `testing` 与表驱动测试。

### 运行 Linter（可选）

```bash
go vet ./...
# 可选: staticcheck, golangci-lint 等
```

---

## 需要帮助的功能方向

社区贡献在以下方向尤其有价值。可查看 [Issues](https://github.com/alireza0/s-ui/issues) 了解当前任务与想法。

### 高价值方向

- **单用户多入站**：S-UI 的核心差异化能力，欢迎改进 UX、文档与稳定性。
- **API（v1 / v2）**：完善性、一致性和文档（见 [API Documentation](https://github.com/alireza0/s-ui/wiki/API-Documentation)）。
- **订阅服务**：链接转换、JSON 订阅与信息端点（`sub/`、`util/`）。
- **测试**：关键路径上的单元测试与集成测试。
- **文档**：用户文档、API 示例和贡献文档（如本文件）。
- **平台支持**：macOS 仍为实验性支持；欢迎改进 Windows 和 Linux（见 `windows/` 与 `.github/workflows/`）。

### 如何寻找任务

- **Good first issue**：优先找带 `good first issue` 或 `help wanted` 标签的问题。
- **功能请求**：使用 [feature request 模板](.github/ISSUE_TEMPLATE/feature_request.md)。
- **Bug**：使用 [bug report 模板](.github/ISSUE_TEMPLATE/bug_report.md)。

若你计划开发较大功能，建议先开 issue 讨论方案，避免重复劳动。

---

## Pull Request 流程

1. **Fork 并创建分支**

   - 在 GitHub 上 fork 本仓库。
   - 从 `main` 创建分支，例如：`git checkout -b fix/issue-123` 或 `feature/sub-improvements`。

2. **完成改动**

   - 遵循 [编码规范](#编码规范与风格指南)。
   - 运行 `gofmt` 并确保项目可构建（见 [测试](#测试)）。
   - 保持提交聚焦，commit message 清晰（如“修复 VMess 链接转换”“为 outJson 添加测试”）。

3. **推送并创建 PR**

   - 推送分支并向 `main` 发起 Pull Request。
   - 在 PR 描述中说明：
     - PR 解决的问题或新增能力。
     - 你修改了什么，以及如何验证。
   - 关联相关 issue（如 `Fixes #123`）。

4. **评审与 CI**

   - 维护者会进行代码评审，CI（如构建流程）需要通过。
   - 请在同一分支继续提交以响应评审意见。

5. **合并**

   - 审核通过且 CI 绿灯后，维护者会合并 PR。感谢你的贡献！

### PR 建议

- 优先提交 **小而可评审** 的 PR；大功能尽量拆分成多个逻辑步骤。
- 避免夹带无关改动（如纯格式化或与功能无关的重构）。
- 提交前保持分支与 `main` 同步（按项目偏好选择 rebase 或 merge）。

---

## 在你的仓库中启用本指南

如果你维护 fork 或自己的仓库，并希望贡献指南可见且链接正确：

1. **将 `CONTRIBUTING.md` 放在仓库根目录**  
   GitHub 会自动识别根目录的 `CONTRIBUTING.md`（或 `CONTRIBUTING`）。当用户创建 issue 或 PR 时，GitHub 会展示该文档链接。社区资料页也会将其用于 “Contributing” 部分。

2. **从 README 链接**  
   在主 `README.md` 中加入一行简短说明，方便新贡献者第一时间看到，例如：
   ```markdown
   **想参与贡献？** 请查看 [CONTRIBUTING.md](CONTRIBUTING.md)，其中包含开发环境、编码规范与 PR 流程。
   ```

3. **可选：检查 GitHub “Contributing” 入口**  
   在仓库 **Settings → General → Features** 中确认启用了 “Issues”（可选启用 “Discussions”）。只要文件在根目录，创建 issue/PR 时就会显示 `CONTRIBUTING.md` 链接，无需额外配置。

4. **Fork 场景**  
   若你 fork 了 S-UI，`CONTRIBUTING.md` 已包含在仓库中。若希望指南指向你自己的仓库，请将本文中的克隆地址与仓库名替换为你的信息。

---

## 报告 Bug 与功能请求

- **Bug**：使用 [bug report 模板](.github/ISSUE_TEMPLATE/bug_report.md)，请包含版本、操作系统、复现步骤、期望行为与实际行为。
- **功能请求**：使用 [feature request 模板](.github/ISSUE_TEMPLATE/feature_request.md)，说明使用场景，并尽量给出实现思路。
- **问题咨询**：使用 [question 模板](.github/ISSUE_TEMPLATE/question-template.md)，或在启用讨论区时使用 Discussions。

---

感谢你帮助 S-UI 持续成长。你的贡献让更多用户能够在生产环境采用 S-UI，并受益于其单用户多入站设计。
