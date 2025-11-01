# Prompt: Tùy chỉnh Việc triển khai GitHub Spec Kit

**Mục tiêu:** Cập nhật Spec Kit để hỗ trợ phân nhánh và tổ chức spec dựa trên thư mục/tiền tố linh hoạt.

**Bối cảnh:** Spec Kit mặc định tạo các tính năng dưới dạng `specs/001-feature-name` trên các nhánh `001-feature-name`. Tùy chỉnh này thêm tổ chức thư mục và xác thực tiền tố đồng thời loại bỏ đặt tên ngữ nghĩa khỏi nhánh/thư mục.

---

## 1. Tham số Tùy chỉnh

| Khóa | Giá trị | Mô tả |
| :--- | :--- | :--- |
| `[prefix-list]` | [`aa`, `bbb`, `cccc`] | Các tiền tố được phép để xác thực |
| `[default-folder]` | `features` | Thư mục mặc định khi không được chỉ định |
| `[main-branch]` | `master` | Nhánh cơ sở cho tất cả các tính năng |
| `[specs-root]` | `.specify` | Thư mục gốc cho tất cả các spec |

---

## 2. Thay đổi Định dạng Lệnh

### Hành vi Spec Kit Mặc định:
```bash
/speckit.specify "Build photo album app"
# Tạo: nhánh "001-photo-albums", spec tại "specs/001-photo-albums/"
```

### Hành vi Tùy chỉnh Mới:

**Định dạng:** `/speckit.specify [folder]/[prefix]-### "description"` hoặc `/speckit.specify [prefix]-### "description"`

**Ví dụ:**
```bash
# Với thư mục tùy chỉnh
/speckit.specify hotfix/aa-123 "Fix critical bug"
# → nhánh: hotfix/aa-123
# → spec: .specify/hotfix/aa-123/

# Sử dụng thư mục mặc định
/speckit.specify aa-456 "New feature"
# → nhánh: features/aa-456
# → spec: .specify/features/aa-456/

# Tiền tố khác
/speckit.specify bbb-789 "Another task"
# → nhánh: features/bbb-789
# → spec: .specify/features/bbb-789/
```

**Quy tắc:**
- `[folder]/` là tùy chọn. Nếu bỏ qua, sử dụng `[default-folder]`
- `[prefix]` phải nằm trong `[prefix-list]` (phân biệt chữ hoa/thường)
- `###` là bất kỳ số nguyên dương nào (1+ chữ số, không giới hạn)
- Không có tên ngữ nghĩa trong nhánh/thư mục (chỉ `[folder]/[prefix]-###`)
- Nhánh cơ sở luôn là `[main-branch]`

**Xác thực:**
- Xác thực định dạng: `^([a-z]+/)?([a-z]+)-([0-9]+)$`
- Trích xuất thư mục (hoặc sử dụng mặc định), tiền tố, số
- Xác minh tiền tố trong `[prefix-list]`
- Lỗi nếu không hợp lệ: liệt kê các tiền tố được phép

---

## 3. Phạm vi Triển khai

### Tập lệnh Cốt lõi - TẤT CẢ CÁC TỆP BASH PHẢI ĐƯỢC CẬP NHẬT (`.specify/scripts/bash/`):

**QUAN TRỌNG:** Xem lại và cập nhật TẤT CẢ các tập lệnh bash bên dưới. Mỗi tập lệnh có thể tham chiếu đến định dạng cũ.

1. **`create-new-feature.sh`** (CHÍNH)
   - Phân tích cú pháp định dạng `[folder]/[prefix]-###` (trích xuất thư mục, tiền tố, số)
   - Xác thực tiền tố với `[prefix-list]`
   - Tạo nhánh: `[folder]/[prefix]-###` từ `[main-branch]`
   - Tạo thư mục spec: `[specs-root]/[folder]/[prefix]-###/`
   - Cập nhật tất cả các phép gán biến và xây dựng đường dẫn

2. **`common.sh`**
   - Cập nhật các hàm trợ giúp để giải quyết tên nhánh
   - Cập nhật các hàm trợ giúp để giải quyết đường dẫn spec
   - Cập nhật bất kỳ hàm nào phân tích hoặc xây dựng định danh tính năng

3. **`setup-plan.sh`**
   - Cập nhật độ phân giải đường dẫn tệp spec để xử lý `[specs-root]/[folder]/[prefix]-###/`
   - Cập nhật bất kỳ logic phân tích tên tính năng nào

4. **`check-prerequisites.sh`**
   - Cập nhật các mẫu xác thực tên nhánh
   - Cập nhật các kiểm tra cấu trúc thư mục

5. **`update-agent-context.sh`**
   - Cập nhật các tham chiếu đường dẫn tệp
   - Cập nhật các ví dụ lệnh và tham chiếu tài liệu

### Mẫu (`.specify/templates/`):
- Cập nhật tất cả các tệp `*-template.md`: loại bỏ tham chiếu đến đặt tên ngữ nghĩa, cập nhật ví dụ đường dẫn

### Lệnh Agent (cập nhật ví dụ sử dụng trong tất cả):
- **`.agents/commands/speckit.*.md`**
- **`.claude/commands/speckit.*.md`**
- **`.codex/prompts/speckit.*.md`**
- **`.gemini/commands/speckit.*.toml`**
- **`.github/prompts/speckit.*.prompt.md`**
- **`.cursor/commands/speckit.*.md`**

**Tiêu điểm:** Các tệp `speckit.specify.*` cần thay đổi nhiều nhất (cú pháp lệnh). Những tệp khác chỉ cần cập nhật ví dụ.