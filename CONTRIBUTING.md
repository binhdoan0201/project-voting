CONTRIBUTING — Dự án Bầu Cử Blockchain (Team 15 người)
Tài liệu chuẩn để cả team dùng chung. Đọc trước khi viết dòng code đầu tiên hoặc commit đầu tiên.

Phần 1 — Phân công 5 nhóm
flowchart LR
    N1[Nhóm 1-2<br/>Viết contract] --> N3[Nhóm 3<br/>Test, bắt bug]
    N3 -->|báo bug ngược| N1
    N3 -->|contract ổn định| N4[Nhóm 4<br/>Demo/Slide]
    N1 -.song song suốt quá trình.-> N5[Nhóm 5<br/>Docs/Quản lý]
    N4 -.song song suốt quá trình.-> N5
Nhóm 1 — Core Contract (3 người)
Vai trò	Việc cụ thể	File phụ trách
Người A	Viết VotingCore.sol, ghép các module lại	contracts/VotingCore.sol
Người B	Viết CandidateManager.sol	contracts/CandidateManager.sol
Người C	Viết ElectionScheduler.sol	contracts/ElectionScheduler.sol
Nhóm 2 — Registry & Tích hợp (3 người)
Vai trò	Việc cụ thể	File phụ trách
Người D	Viết VoterRegistry.sol	contracts/VoterRegistry.sol
Người E	Viết batchRegisterVoters, tối ưu gas	contracts/VoterRegistry.sol
Người F	Ghép toàn bộ module, test compile tổng	contracts/VotingCore.sol
Nhóm 3 — Test/QA (3 người)
Vai trò	Việc cụ thể
Người G	Test nhóm hàm admin (addCandidate, registerVoter, scheduleElection)
Người H	Test nhóm hàm vote (double-vote, sai giờ, chưa whitelist)
Người I	Chạy test tổng, tổng hợp báo cáo bug gửi Nhóm 1-2
Nhóm 4 — Frontend/Demo (3 người)
Vai trò	Việc cụ thể
Người J	Chuẩn bị kịch bản demo Remix (thứ tự thao tác, tài khoản test)
Người K	Làm slide thuyết trình
Người L	Tập thao tác demo, canh thời gian trình bày
Nhóm 5 — Docs/Quản lý (3 người)
Vai trò	Việc cụ thể
Người M	Viết roadmap, vòng đời bầu cử
Người N	Quản lý Git: review PR, gộp nhánh, canh deadline
Người O	Viết README, hướng dẫn cài đặt
Lịch làm việc (5 ngày)
Contract lõi đã có sẵn phần lớn — không viết từ 0, chủ yếu là tách file, hoàn thiện, test kỹ và demo.

Ngày	N1-N2 (Core+Registry)	N3 (Test/QA)	N4 (Demo/Slide)	N5 (Docs/Git)
1	Tách file theo quy ước, hoàn thiện 9 function (refactor + polish)	Viết khung test (chờ contract)	Outline slide, xác định kịch bản demo	Setup repo, CODEOWNERS, branch protection, CI
2	Merge các file thành VotingCore.sol hoàn chỉnh, tự compile thử	Chạy test thật trên Remix/Hardhat, ghi nhận bug	Dựng slide với nội dung thật	Viết README, bắt đầu roadmap/vòng đời bầu cử
3	Fix bug theo N3 báo (ngày ưu tiên cao nhất cả team)	Test lại sau fix, xác nhận hết lỗi	Tập demo lần 1 với contract thật, ghi lỗi thao tác	Hoàn thiện docs, rà lại slide cho khớp code
4	Khoá code — không sửa thêm trừ bug nghiêm trọng	Test hồi quy toàn bộ lần cuối	Tập demo lần 2, canh thời gian trình bày	Rà soát toàn bộ tài liệu, chuẩn bị file nộp
5	Dự phòng — hỗ trợ nếu Remix lỗi lúc demo	Đứng máy dự phòng, sẵn sàng trả lời câu hỏi kỹ thuật	Thuyết trình/nộp bài	Hỗ trợ hậu cần, đảm bảo tài liệu sẵn sàng
Lưu ý riêng cho bản 5 ngày:

Không còn nhịp merge develop→main mỗi 2-3 ngày — merge vào develop liên tục khi PR pass CI, gộp lên main vào cuối ngày 2, 3, 4.
Ngày 3 là ngày quan trọng nhất — N4/N5 rảnh tay có thể hỗ trợ N3 test thủ công trên Remix.
Ngày 5 không code nữa, chỉ demo — tránh sửa code sát giờ gây lỗi bất ngờ.
Phần 2 — Quy ước đặt tên & cú pháp
2.1 Naming convention
Đối tượng	Quy ước	Đúng	Sai
Tên contract	PascalCase	VotingCore	votingCore
Tên function	camelCase	addCandidate	AddCandidate
Biến state	camelCase	candidatesLocked	candidates_locked
Biến private/internal	_camelCase	_candidateId	candidateId
Hằng số (constant)	SCREAMING_SNAKE_CASE	MAX_CANDIDATES	maxCandidates
Struct	PascalCase	Candidate	candidate
Event	PascalCase	VoteCast	voteCast
Modifier	camelCase	onlyDuringElection	OnlyDuringElection
Tham số function	_camelCase	_voter	Voter
2.2 Cấu trúc file — thứ tự bắt buộc
// 1. Pragma & import
// 2. State variables
// 3. Events
// 4. Modifiers
// 5. Constructor
// 6. External/public functions (nhóm theo chức năng, có comment ngăn cách)
// 7. Internal/private functions
// 8. View/pure functions (để cuối cùng)
2.3 Comment bắt buộc — chuẩn NatSpec
/// @notice Ghi nhận 1 phiếu bầu cho ứng viên được chỉ định
/// @param _candidateId ID của ứng viên trong mảng candidates
/// @dev Tự động khoá lịch bầu cử ở lần gọi hợp lệ đầu tiên
function vote(uint _candidateId) external onlyDuringElection {
Bắt buộc với mọi function external/public.

2.4 Quy tắc riêng của dự án
Thông báo lỗi trong require() viết tiếng Việt không dấu: "Ban da bau roi".
Mọi hành động đổi trạng thái quan trọng bắt buộc có event đi kèm.
Không dùng tên viết tắt mơ hồ (cnt, tmp, vt) — luôn viết rõ nghĩa.
2.5 Công cụ ép buộc tự động
Công cụ	Việc gì
Solhint	Linter — báo lỗi sai naming, thiếu visibility
Prettier-Solidity	Tự format code khi save
Husky (pre-commit hook)	Chặn git commit nếu sai convention
// .solhint.json
{
  "extends": "solhint:recommended",
  "rules": {
    "func-visibility": ["error", { "ignoreConstructors": true }],
    "var-name-mixedcase": "error",
    "const-name-snakecase": "error"
  }
}
Phần 3 — Quy trình Git
3.1 Cấu trúc branch
main        ← chỉ merge từ develop, đã test kỹ, dùng để demo/nộp bài
develop     ← nhánh tổng hợp hàng ngày
feature/*   ← mỗi người/nhóm nhỏ làm trên đây
Đặt tên nhánh: feature/<module>-<việc> Ví dụ: feature/registry-batch-check, feature/core-vote-events, feature/qa-test-scheduler

3.2 Quy trình từng bước
Kéo develop mới nhất → tạo feature/... từ đó (không code thẳng trên develop)
Commit nhỏ, thường xuyên — dùng Conventional Commits: feat:, fix:, test:, docs:
feat: them ham batchRegisterVoters
fix: chan dia chi address(0) trong registerVoter
test: them test case double-vote
Push nhánh, mở Pull Request vào develop — không ai push thẳng vào develop/main
CI tự động chạy (GitHub Actions + Hardhat): compile + test — PR không merge được nếu fail
Ít nhất 1 người review (ưu tiên khác nhóm, review chéo)
Merge vào develop → sau 2-3 ngày, N5 gộp develop → main khi QA xác nhận ổn
3.3 CODEOWNERS — tự động gán người review đúng module
.github/CODEOWNERS:

/contracts/VoterRegistry.sol      @nhom-2
/contracts/CandidateManager.sol   @nhom-1
/contracts/ElectionScheduler.sol  @nhom-1
/contracts/VotingCore.sol         @nhom-1 @nhom-2
/test/                            @nhom-3
/docs/                            @nhom-5
3.4 Nhịp đồng bộ
Tần suất	Việc
Hàng ngày (5 ngày)	Standup 10 phút đầu giờ: hôm qua làm gì, hôm nay làm gì, có bị chặn không
Mỗi PR	CI chạy tự động, review trước khi merge vào develop
Cuối ngày 2, 3, 4	Merge develop → main sau khi QA xác nhận ổn
Ngày 4	Code freeze — chỉ sửa bug nghiêm trọng, không thêm tính năng mới
Ngày 5	Không code — chỉ demo/nộp bài
3.5 Cấu trúc thư mục repo
project-voting/
├── contracts/
│   ├── VotingCore.sol
│   ├── CandidateManager.sol
│   ├── VoterRegistry.sol
│   └── ElectionScheduler.sol
├── test/
│   ├── admin.test.js
│   └── vote.test.js
├── scripts/
│   └── deploy.js
├── docs/
│   ├── roadmap.md
│   └── vong-doi-bau-cu.md
├── .github/
│   └── CODEOWNERS
├── .solhint.json
└── README.md
Checklist trước khi bắt đầu code
 Cả 15 người đã đọc file này
 Repo đã setup .solhint.json, Prettier, Husky pre-commit hook
 .github/CODEOWNERS đã cấu hình đúng theo nhóm
 Branch protection đã bật cho main và develop (chặn push trực tiếp)
 CI (GitHub Actions) đã chạy được compile + test tự động