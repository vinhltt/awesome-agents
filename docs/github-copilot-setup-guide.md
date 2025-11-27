# GitHub Copilot Setup Guide for Awesome-Agents

Hướng dẫn cài đặt **Spec Kit** template vào dự án của bạn để sử dụng với GitHub Copilot.

> **Awesome-agents** là template chứa Spec Kit framework. Cài đặt bằng cách copy các thư mục `.specify/`, `.github/agents/`, `.github/prompts/` vào dự án của bạn.

## Yêu cầu

- VS Code với GitHub Copilot extension đã cài đặt
- GitHub Copilot Chat (phiên bản hỗ trợ Agents & Prompts)
- Git đã được cài đặt và cấu hình
- Bash shell (macOS/Linux) hoặc Git Bash/WSL (Windows)

## Cấu trúc Template

Các thư mục cần copy từ `awesome-agents/` vào dự án:

```
your-project/                 # Dự án của bạn
├── .github/                  # ← Copy từ awesome-agents/.github/
│   ├── agents/               # Agent definitions
│   │   └── IT-comtor.agent.md
│   └── prompts/              # Prompt files (Spec Kit commands)
│       ├── speckit.specify.prompt.md
│       ├── speckit.clarify.prompt.md
│       ├── speckit.plan.prompt.md
│       ├── speckit.tasks.prompt.md
│       ├── speckit.implement.prompt.md
│       ├── speckit.checklist.prompt.md
│       ├── speckit.analyze.prompt.md
│       ├── speckit.constitution.prompt.md
│       └── speckit.status.prompt.md
└── .specify/                 # ← Copy từ awesome-agents/.specify/
    ├── .speckit.env.template # Template cấu hình
    ├── .speckit.env          # File cấu hình (tạo từ template)
    ├── templates/            # Reusable templates
    ├── scripts/bash/         # Automation scripts
    └── memory/               # Workflow state
```

## Cài đặt

Giả sử bạn đã có thư mục `awesome-agents/` (clone hoặc download).

```bash
# Trong thư mục dự án của bạn
cd your-project

# 1. Copy .specify framework
cp -r awesome-agents/.specify .specify

# 2. Tạo file cấu hình từ template
cp .specify/.speckit.env.template .specify/.speckit.env
# Chỉnh sửa .specify/.speckit.env theo dự án (xem phần "Cấu hình .speckit.env" bên dưới)

# 3. Copy agents và prompts cho GitHub Copilot
mkdir -p .github/agents .github/prompts
cp awesome-agents/.github/agents/*.md .github/agents/
cp awesome-agents/.github/prompts/*.md .github/prompts/
```

## Cấu hình VS Code

### 1. Cài đặt Extensions cần thiết

Mở VS Code và cài đặt:
- `GitHub.copilot` - GitHub Copilot
- `GitHub.copilot-chat` - GitHub Copilot Chat

### 2. Không cần cấu hình thêm

GitHub Copilot **tự động phát hiện** các files trong:
- `.github/agents/*.agent.md` → Agents
- `.github/prompts/*.prompt.md` → Prompts

Chỉ cần đặt files đúng vị trí, reload VS Code là xong.

## Xác nhận cài đặt

### Kiểm tra cấu trúc thư mục

```bash
# Xác nhận agents đã được cài đặt
ls -la .github/agents/
# Output: *.agent.md files

# Xác nhận prompts đã được cài đặt
ls -la .github/prompts/
# Output: *.prompt.md files
```

### Kiểm tra trong VS Code

1. Mở VS Code trong dự án
2. Mở Copilot Chat (`Ctrl+Shift+I` hoặc `Cmd+Shift+I`)
3. Click vào dropdown **Agent mode** (góc trên chat) - Nên thấy các agents được liệt kê
4. Gõ `/` trong chat - Nên thấy các prompts được liệt kê

## Sử dụng

### Sử dụng Agents

1. Mở Copilot Chat
2. Click vào dropdown **Agent mode** (hoặc icon người) ở góc trên
3. Chọn agent muốn sử dụng (ví dụ: `IT-comtor`)
4. Nhập câu hỏi/yêu cầu và gửi

**Lưu ý**: Không thể gọi agent bằng cú pháp `@agent-name` như Claude Code. Phải chọn từ dropdown.

### Sử dụng Spec Kit Prompts

Spec Kit cung cấp workflow 8 bước để phát triển tính năng:

```bash
# 1. Tạo specification cho tính năng
/speckit.specify aa-001 "Implement user authentication"

# 2. Làm rõ yêu cầu (nếu cần)
/speckit.clarify

# 3. Tạo kế hoạch triển khai
/speckit.plan

# 4. Chia nhỏ thành các task
/speckit.tasks

# 5. Hướng dẫn triển khai từng bước
/speckit.implement

# 6. Kiểm tra chất lượng
/speckit.checklist

# 7. Phân tích và tối ưu specification
/speckit.analyze

# 8. Xem trạng thái tiến độ
/speckit.status
```

### Các Prompts khác

```bash
# Unit Test workflow
/ut.specify     # Tạo spec cho unit test
/ut.plan        # Lập kế hoạch test
/ut.generate    # Sinh test cases
/ut.run         # Chạy tests
/ut.review      # Review kết quả test
/ut.analyze     # Phân tích coverage
/ut.clarify     # Làm rõ test requirements
```

## Tùy chỉnh

### Cấu hình `.speckit.env` (Quan trọng)

File `.speckit.env` chứa các thiết lập chính cho Spec Kit workflow. Copy template và chỉnh sửa:

```bash
# Copy template
cp .specify/.speckit.env.template .specify/.speckit.env

# Hoặc copy example
cp .specify/.speckit.env.example .specify/.speckit.env
```

**Các biến cấu hình chính:**

| Biến | Mô tả | Mặc định |
|------|-------|----------|
| `SPECKIT_PREFIX_LIST` | Danh sách prefix cho ticket (phân cách bằng dấu phẩy) | `"aa"` |
| `SPECKIT_DEFAULT_FOLDER` | Thư mục mặc định cho features | `"features"` |
| `SPECKIT_MAIN_BRANCH` | Branch chính (base branch) | `"master"` |
| `SPECKIT_SPECS_ROOT` | Thư mục gốc chứa specs | `".specify"` |
| `SPECKIT_TICKET_FORMAT` | Regex validate ticket ID | `"^([a-zA-Z]+/)?([a-zA-Z]+)-([0-9]+)$"` |

**Ví dụ cấu hình:**

```bash
# Ví dụ 1: Dự án đơn giản với prefix "aa"
SPECKIT_PREFIX_LIST="aa"
SPECKIT_DEFAULT_FOLDER="features"
SPECKIT_MAIN_BRANCH="master"

# Ví dụ 2: Nhiều prefix (aa, AL, PROJ)
SPECKIT_PREFIX_LIST="aa,AL,PROJ"
SPECKIT_DEFAULT_FOLDER="features"
SPECKIT_MAIN_BRANCH="main"

# Ví dụ 3: Chấp nhận mọi prefix (wildcard)
SPECKIT_PREFIX_LIST="*"
```

**Cấu hình nâng cao (tùy chọn):**

```bash
# Validation hook script
SPECKIT_VALIDATION_HOOK=".specify/scripts/hooks/validate-ticket.sh"

# Hook timeout (giây)
SPECKIT_HOOK_TIMEOUT="30"

# Hành vi khi hook fail: "exit" (dừng) hoặc "warn" (cảnh báo)
SPECKIT_HOOK_FAIL_BEHAVIOR="exit"

# Debug mode
SPECKIT_DEBUG="true"
```

### Thay đổi Ticket Format

Mặc định: `aa-###` (ví dụ: `aa-001`, `aa-123`)

Chỉnh sửa trong `.specify/.speckit.env`:
```bash
# Thay đổi prefix
SPECKIT_PREFIX_LIST="MYPROJ,FEAT"

# Thay đổi regex format (nếu cần)
SPECKIT_TICKET_FORMAT="^([a-zA-Z0-9]+/)?([a-zA-Z]+)-([0-9]+)$"
```

### Thêm Agent mới

1. Tạo file `.github/agents/your-agent.agent.md`:

```markdown
---
description: 'Mô tả agent của bạn'
tools: ['edit', 'search', 'new', 'runCommands']
---

Nội dung hướng dẫn cho agent...
```

### Thêm Prompt mới

1. Tạo file `.github/prompts/your-prompt.prompt.md`:

```markdown
---
description: Mô tả prompt của bạn
---

## User Input

```text
$ARGUMENTS
```

## Instructions

Nội dung hướng dẫn...
```

## Troubleshooting

### Agents/Prompts không hiển thị

1. Đảm bảo files có extension đúng (`.agent.md`, `.prompt.md`)
2. Kiểm tra cấu trúc thư mục: `.github/agents/`, `.github/prompts/`
3. Reload VS Code (`Ctrl+Shift+P` → "Developer: Reload Window")
4. Đảm bảo GitHub Copilot Chat extension đã được cập nhật

### Script lỗi quyền truy cập

```bash
# Cấp quyền thực thi cho scripts
chmod +x .specify/scripts/bash/*.sh
```

### Git không nhận diện thư mục

```bash
# Khởi tạo git nếu chưa có
git init

# Hoặc script sẽ hoạt động với fallback mode (sử dụng .specify markers)
```

## Cập nhật

Khi có phiên bản mới của awesome-agents, copy lại các thư mục:

```bash
# Cập nhật prompts và agents
cp awesome-agents/.github/agents/*.md .github/agents/
cp awesome-agents/.github/prompts/*.md .github/prompts/

# Cập nhật .specify (cẩn thận không ghi đè .speckit.env đã cấu hình)
cp -r awesome-agents/.specify/templates .specify/
cp -r awesome-agents/.specify/scripts .specify/
```

## Tài liệu tham khảo

- [README chính](../README.md)
- [Codebase Summary](codebase-summary.md)
- [Code Standards](code-standards.md)
- [System Architecture](system-architecture.md)

---

**Phiên bản**: 1.0.0
**Cập nhật lần cuối**: 2025-11-27
