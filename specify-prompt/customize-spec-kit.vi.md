# Prompt: Tùy chỉnh Việc triển khai GitHub Spec Kit

**Mục tiêu:** Cập nhật cấu hình Spec Kit hiện có để tuân theo một cấu trúc phân nhánh và thư mục mới, được tiêu chuẩn hóa. Prompt này sẽ đóng vai trò là một hướng dẫn có thể tái sử dụng cho quá trình tùy chỉnh này.

**Bối cảnh:** Hành vi mặc định của Spec Kit để tạo các tính năng mới (ví dụ: `specs/123-feature-name`) cần được thay thế bằng một định dạng tùy chỉnh. Điều này bao gồm việc sửa đổi các tập lệnh shell, mẫu và định nghĩa lệnh cho các AI agent khác nhau (`Claude`, `Gemini`).

---

## 1. Tham số Tùy chỉnh

Các cặp khóa-giá trị sau đây xác định cấu trúc mới. Tất cả các tập lệnh và mẫu phải được cập nhật để sử dụng các giá trị này.

| Khóa | Giá trị | Mô tả |
| :--- | :--- | :--- |
| `[prefix]` | `aa` | Tiền tố cho các số ticket/issue. |
| `[branch-folder]` | `features` | Thư mục nhánh git cho các nhánh tính năng mới. |
| `[main-branch]` | `master` | Nhánh chính mà từ đó các nhánh mới được tạo. |
| `[folder-specs]` | `.specify/features`| Thư mục nơi các thư mục spec sẽ được tạo. |

---

## 2. Yêu cầu Cốt lõi

### 2.1. Chiến lược Phân nhánh

- **Định dạng Nhánh:** Các nhánh tính năng mới phải tuân theo mẫu: `[branch-folder]/[prefix]-###`.
  - *Ví dụ:* `features/aa-123` (no description and no --short-name in branch name)
- **Nhánh Cơ sở:** Tất cả các nhánh tính năng mới phải được tạo từ `[main-branch]` (`master`).

### 2.2. Cấu trúc Thư mục Đặc tả (Specification)

- **Thư mục Spec:** Khi một spec mới được tạo, thư mục của nó phải được tạo tại: `[folder-specs]/[prefix]-###`.
  - *Ví dụ:* `.specify/features/aa-123` (no description and no --short-name in folder name)

### 2.3. Sử dụng Lệnh & Xác thực

- **Lệnh Chính:** Lệnh chính để tạo một spec mới phải là: `/speckit.specify [prefix]-### [description]`.
  - *Ví dụ:* `/speckit.specify aa-123 "Triển khai luồng đăng nhập mới"`
- **Xác thực Đầu vào:** Tập lệnh cho `/speckit.specify` phải xác thực rằng đối số đầu tiên khớp với định dạng `[prefix]-###`. Nếu đối số bị thiếu hoặc không hợp lệ, tập lệnh sẽ thoát và hiển thị một thông báo lỗi đầy đủ thông tin cho người dùng.
- **Tính nhất quán:** Tất cả các lệnh `/speckit.*` khác phải được cập nhật để nhất quán với quy ước đặt tên và thư mục mới này.

---

## 3. Danh sách kiểm tra sửa đổi tệp

Các tệp sau phải được cập nhật để triển khai các thay đổi được mô tả ở trên.

### 3.1. `.specify` Scripts & Templates

-   **Scripts:** `.specify/scripts/bash/`
    -   [ ] `check-prerequisites.sh`: Cập nhật mọi kiểm tra liên quan đến đặt tên nhánh hoặc thư mục.
    -   [ ] `common.sh`: Cập nhật các hàm trợ giúp, đặc biệt là những hàm giải quyết tên nhánh hoặc đường dẫn spec.
    -   [ ] `create-new-feature.sh`: Đây là tệp cốt lõi. Sửa đổi nó để xử lý định dạng nhánh mới (`[branch-folder]/[prefix]-###`), nhánh cơ sở (`[main-branch]`) và tạo thư mục spec (`[folder-specs]/[prefix]-###`). Thực hiện xác thực đối số ở đây.
    -   [ ] `setup-plan.sh`: Đảm bảo tập lệnh này định vị chính xác các tệp spec trong cấu trúc thư mục mới.
    -   [ ] `update-agent-context.sh`: Cập nhật để phản ánh các đường dẫn tệp và cấu trúc lệnh mới.

-   **Templates:** `.specify/templates/`
    -   [ ] `agent-file-template.md`: Cập nhật mọi văn bản giữ chỗ đề cập đến định dạng nhánh/thư mục cũ.
    -   [ ] `checklist-template.md`: Cập nhật để phản ánh quy trình mới.
    -   [ ] `plan-template.md`: Đảm bảo các đường dẫn và lệnh được đề cập trong mẫu là chính xác.
    -   [ ] `spec-template.md`: Cập nhật mọi tham chiếu đến tên hoặc đường dẫn tính năng.
    -   [ ] `tasks-template.md`: Cập nhật mọi tham chiếu đến tên hoặc đường dẫn tính năng.

### 3.2. `.claude` Agent Commands

-   **Commands:** `.claude/commands/`
    -   [ ] `speckit.analyze.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.checklist.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.clarify.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.constitution.md`: Xem lại mọi đường dẫn hoặc lệnh được mã hóa cứng.
    -   [ ] `speckit.implement.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.plan.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.specify.md`: Cập nhật định nghĩa lệnh chính, mô tả và ví dụ để khớp với định dạng mới.
    -   [ ] `speckit.tasks.md`: Cập nhật cách sử dụng lệnh và ví dụ.

### 3.3. `.gemini` Agent Commands

-   **Commands:** `.gemini/commands/`
    -   [ ] `speckit.analyze.toml`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.checklist.toml`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.clarify.toml`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.constitution.toml`: Xem lại mọi đường dẫn hoặc lệnh được mã hóa cứng.
    -   [ ] `speckit.implement.toml`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.plan.toml`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.specify.toml`: Cập nhật định nghĩa lệnh chính, mô tả và ví dụ để khớp với định dạng mới.
    -   [ ] `speckit.tasks.toml`: Cập nhật cách sử dụng lệnh và ví dụ.

### 3.4. `.github` Agent Prompts

-   **Prompts:** `.github/prompts/`
    -   [ ] `speckit.analyze.prompt.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.checklist.prompt.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.clarify.prompt.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.constitution.prompt.md`: Xem lại mọi đường dẫn hoặc lệnh được mã hóa cứng.
    -   [ ] `speckit.implement.prompt.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.plan.prompt.md`: Cập nhật cách sử dụng lệnh và ví dụ.
    -   [ ] `speckit.specify.prompt.md`: Cập nhật định nghĩa lệnh chính, mô tả và ví dụ để khớp với định dạng mới.
    -   [ ] `speckit.tasks.prompt.md`: Cập nhật cách sử dụng lệnh và ví dụ.
