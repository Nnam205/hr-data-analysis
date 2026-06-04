-- ============================================================
--  HR DATA CLEANING — BẢN ĐẦY ĐỦ (REVISED)
--  Nguồn: cleaned_hr_data_analysis
--  Xuất:  hr_data_final
--  Mục tiêu: sẵn sàng đưa vào Python / Power BI
-- ============================================================

USE kho_du_lieu;


-- ============================================================
-- BƯỚC 0: XEM TỔNG QUAN DỮ LIỆU
-- ============================================================

-- 0a. Xem mẫu dữ liệu
SELECT * FROM cleaned_hr_data_analysis LIMIT 20;

-- 0b. Tổng số dòng ban đầu
SELECT COUNT(*) AS tong_so_dong_ban_dau FROM cleaned_hr_data_analysis;

-- 0c. Xem tất cả giá trị DISTINCT của các cột phân loại
--     → phát hiện typo, khoảng trắng ẩn, inconsistency trước khi xử lý
SELECT DISTINCT 'DepartmentType'    AS cot, DepartmentType       AS gia_tri FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'Performance Score', `Performance Score`           FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'Training Outcome',  `Training Outcome`            FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'EmployeeStatus',    EmployeeStatus                FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'EmployeeType',      EmployeeType                  FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'GenderCode',        GenderCode                    FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'PayZone',           PayZone                       FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'BusinessUnit',      BusinessUnit                  FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'RaceDesc',          RaceDesc                      FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'MaritalDesc',       MaritalDesc                   FROM cleaned_hr_data_analysis
UNION ALL SELECT DISTINCT 'Training Type',     `Training Type`               FROM cleaned_hr_data_analysis
ORDER BY cot, gia_tri;


-- ============================================================
-- BƯỚC 1: KIỂM TRA GIÁ TRỊ THIẾU (MISSING VALUES)
-- ============================================================

-- 1a. Đếm tổng missing mỗi cột
SELECT
    -- Cột chữ: lọc cả NULL và chuỗi rỗng
    SUM(CASE WHEN DepartmentType           IS NULL OR DepartmentType           = '' THEN 1 ELSE 0 END) AS missing_DepartmentType,
    SUM(CASE WHEN Title                    IS NULL OR Title                    = '' THEN 1 ELSE 0 END) AS missing_Title,
    SUM(CASE WHEN BusinessUnit             IS NULL OR BusinessUnit             = '' THEN 1 ELSE 0 END) AS missing_BusinessUnit,
    SUM(CASE WHEN EmployeeStatus           IS NULL OR EmployeeStatus           = '' THEN 1 ELSE 0 END) AS missing_EmployeeStatus,
    SUM(CASE WHEN EmployeeType             IS NULL OR EmployeeType             = '' THEN 1 ELSE 0 END) AS missing_EmployeeType,
    SUM(CASE WHEN GenderCode               IS NULL OR GenderCode               = '' THEN 1 ELSE 0 END) AS missing_GenderCode,
    SUM(CASE WHEN `Performance Score`      IS NULL OR `Performance Score`      = '' THEN 1 ELSE 0 END) AS missing_PerformanceScore,
    SUM(CASE WHEN `Training Outcome`       IS NULL OR `Training Outcome`       = '' THEN 1 ELSE 0 END) AS missing_TrainingOutcome,
    SUM(CASE WHEN `Training Program Name`  IS NULL OR `Training Program Name`  = '' THEN 1 ELSE 0 END) AS missing_TrainingProgramName,
    SUM(CASE WHEN `Training Type`          IS NULL OR `Training Type`          = '' THEN 1 ELSE 0 END) AS missing_TrainingType,
    SUM(CASE WHEN RaceDesc                 IS NULL OR RaceDesc                 = '' THEN 1 ELSE 0 END) AS missing_RaceDesc,
    SUM(CASE WHEN MaritalDesc              IS NULL OR MaritalDesc              = '' THEN 1 ELSE 0 END) AS missing_MaritalDesc,
    SUM(CASE WHEN PayZone                  IS NULL OR PayZone                  = '' THEN 1 ELSE 0 END) AS missing_PayZone,
    SUM(CASE WHEN Division                 IS NULL OR Division                 = '' THEN 1 ELSE 0 END) AS missing_Division,
    SUM(CASE WHEN State                    IS NULL OR State                    = '' THEN 1 ELSE 0 END) AS missing_State,
    -- Cột số: chỉ lọc NULL
    SUM(CASE WHEN `Current Employee Rating` IS NULL THEN 1 ELSE 0 END) AS missing_EmployeeRating,
    SUM(CASE WHEN `Engagement Score`        IS NULL THEN 1 ELSE 0 END) AS missing_EngagementScore,
    SUM(CASE WHEN `Satisfaction Score`      IS NULL THEN 1 ELSE 0 END) AS missing_SatisfactionScore,
    SUM(CASE WHEN `Work-Life Balance Score` IS NULL THEN 1 ELSE 0 END) AS missing_WorkLifeBalance,
    SUM(CASE WHEN `Training Cost`           IS NULL THEN 1 ELSE 0 END) AS missing_TrainingCost,
    SUM(CASE WHEN `Training Duration(Days)` IS NULL THEN 1 ELSE 0 END) AS missing_TrainingDuration,
    SUM(CASE WHEN Age                       IS NULL THEN 1 ELSE 0 END) AS missing_Age
FROM cleaned_hr_data_analysis;

-- 1b. Xem chi tiết các dòng có ít nhất 1 cột quan trọng bị thiếu
SELECT
    `Employee ID`,
    DepartmentType,
    EmployeeStatus,
    `Performance Score`,
    `Training Outcome`,
    `Engagement Score`,
    `Satisfaction Score`,
    Age
FROM cleaned_hr_data_analysis
WHERE DepartmentType           IS NULL OR DepartmentType           = ''
   OR EmployeeStatus           IS NULL OR EmployeeStatus           = ''
   OR `Performance Score`      IS NULL OR `Performance Score`      = ''
   OR `Training Outcome`       IS NULL OR `Training Outcome`       = ''
   OR `Engagement Score`       IS NULL
   OR `Satisfaction Score`     IS NULL
   OR `Work-Life Balance Score` IS NULL
   OR Age                      IS NULL;


-- ============================================================
-- BƯỚC 2: TRIM VÀ CHUẨN HOÁ CHUỖI
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- 2a. Trim khoảng trắng đầu/cuối toàn bộ cột chữ
UPDATE cleaned_hr_data_analysis
SET
    Title                      = TRIM(Title),
    Division                   = TRIM(Division),
    BusinessUnit               = TRIM(BusinessUnit),
    DepartmentType             = TRIM(DepartmentType),
    EmployeeStatus             = TRIM(EmployeeStatus),
    EmployeeType               = TRIM(EmployeeType),
    EmployeeClassificationType = TRIM(EmployeeClassificationType),
    PayZone                    = TRIM(PayZone),
    State                      = TRIM(State),
    GenderCode                 = TRIM(GenderCode),
    RaceDesc                   = TRIM(RaceDesc),
    MaritalDesc                = TRIM(MaritalDesc),
    `Performance Score`        = TRIM(`Performance Score`),
    `Training Program Name`    = TRIM(`Training Program Name`),
    `Training Type`            = TRIM(`Training Type`),
    `Training Outcome`         = TRIM(`Training Outcome`);

-- 2b. Chuẩn hoá chữ hoa/thường để tránh nhóm bị tách đôi
--     (ví dụ: 'male' vs 'Male' vs 'MALE' → đều thành 'Male')
UPDATE cleaned_hr_data_analysis
SET GenderCode = CONCAT(UPPER(LEFT(TRIM(GenderCode), 1)), LOWER(SUBSTRING(TRIM(GenderCode), 2)));

UPDATE cleaned_hr_data_analysis
SET EmployeeStatus = CONCAT(UPPER(LEFT(TRIM(EmployeeStatus), 1)), LOWER(SUBSTRING(TRIM(EmployeeStatus), 2)));

UPDATE cleaned_hr_data_analysis
SET DepartmentType = CONCAT(UPPER(LEFT(TRIM(DepartmentType), 1)), LOWER(SUBSTRING(TRIM(DepartmentType), 2)));

UPDATE cleaned_hr_data_analysis
SET `Performance Score` = CONCAT(UPPER(LEFT(TRIM(`Performance Score`), 1)), LOWER(SUBSTRING(TRIM(`Performance Score`), 2)));

UPDATE cleaned_hr_data_analysis
SET `Training Outcome` = CONCAT(UPPER(LEFT(TRIM(`Training Outcome`), 1)), LOWER(SUBSTRING(TRIM(`Training Outcome`), 2)));

UPDATE cleaned_hr_data_analysis
SET PayZone = UPPER(TRIM(PayZone));

-- 2c. Xác nhận lại DISTINCT sau khi chuẩn hoá — không còn bản ghi trùng do case
SELECT DISTINCT GenderCode      FROM cleaned_hr_data_analysis ORDER BY GenderCode;
SELECT DISTINCT EmployeeStatus  FROM cleaned_hr_data_analysis ORDER BY EmployeeStatus;
SELECT DISTINCT DepartmentType  FROM cleaned_hr_data_analysis ORDER BY DepartmentType;
SELECT DISTINCT `Performance Score` FROM cleaned_hr_data_analysis ORDER BY `Performance Score`;
SELECT DISTINCT `Training Outcome`  FROM cleaned_hr_data_analysis ORDER BY `Training Outcome`;
SELECT DISTINCT PayZone         FROM cleaned_hr_data_analysis ORDER BY PayZone;

SET SQL_SAFE_UPDATES = 1;


-- ============================================================
-- BƯỚC 3: KIỂM TRA TRÙNG LẶP
-- ============================================================

-- 3a. Trùng theo Employee ID (khoá chính logic)
SELECT `Employee ID`, COUNT(*) AS so_lan
FROM cleaned_hr_data_analysis
GROUP BY `Employee ID`
HAVING COUNT(*) > 1
ORDER BY so_lan DESC;

-- 3b. Trùng toàn bộ dòng (trường hợp copy nhầm)
SELECT
    `Employee ID`, Title, DepartmentType, StartDate,
    COUNT(*) AS so_lan_xuat_hien
FROM cleaned_hr_data_analysis
GROUP BY `Employee ID`, Title, DepartmentType, StartDate
HAVING COUNT(*) > 1;


-- ============================================================
-- BƯỚC 4: KIỂM TRA VÀ XỬ LÝ RANGE / OUTLIER CỘT SỐ
-- ============================================================

-- 4a. Thống kê mô tả cơ bản
SELECT
    MIN(`Engagement Score`)        AS min_engagement,    MAX(`Engagement Score`)        AS max_engagement,
    MIN(`Satisfaction Score`)      AS min_satisfaction,  MAX(`Satisfaction Score`)      AS max_satisfaction,
    MIN(`Work-Life Balance Score`) AS min_worklife,      MAX(`Work-Life Balance Score`) AS max_worklife,
    MIN(`Current Employee Rating`) AS min_rating,        MAX(`Current Employee Rating`) AS max_rating,
    MIN(Age)                       AS min_age,           MAX(Age)                       AS max_age,
    MIN(`Training Cost`)           AS min_cost,          MAX(`Training Cost`)           AS max_cost,
    MIN(`Training Duration(Days)`) AS min_duration,      MAX(`Training Duration(Days)`) AS max_duration
FROM cleaned_hr_data_analysis;

-- 4b. Kiểm tra giá trị âm / bằng 0 (phi logic nghiệp vụ)
SELECT COUNT(*) AS so_dong_cost_phi_logic
FROM cleaned_hr_data_analysis
WHERE `Training Cost` <= 0 OR `Training Cost` IS NULL;

SELECT COUNT(*) AS so_dong_duration_phi_logic
FROM cleaned_hr_data_analysis
WHERE `Training Duration(Days)` <= 0 OR `Training Duration(Days)` IS NULL;

-- 4c. Xem chi tiết dòng lỗi giá trị âm/zero
SELECT `Employee ID`, `Training Program Name`, `Training Duration(Days)`, `Training Cost`
FROM cleaned_hr_data_analysis
WHERE `Training Cost` <= 0 OR `Training Duration(Days)` <= 0;

-- Nới rộng bộ nhớ tạm để hàm GROUP_CONCAT không bị cắt xén dữ liệu khi đếm hàng ngàn dòng
SET SESSION group_concat_max_len = 1000000;

-- 4d. Phát hiện outlier thống kê bằng IQR (áp dụng cho Training Cost)
WITH quartiles AS (
    SELECT
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(`Training Cost` ORDER BY `Training Cost`), ',', FLOOR(0.25 * COUNT(*) + 1)), ',', -1) AS DECIMAL(10,2)) AS Q1,
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(`Training Cost` ORDER BY `Training Cost`), ',', FLOOR(0.75 * COUNT(*) + 1)), ',', -1) AS DECIMAL(10,2)) AS Q3
    FROM cleaned_hr_data_analysis
    WHERE `Training Cost` IS NOT NULL
)
SELECT
    q.Q1,
    q.Q3,
    (q.Q3 - q.Q1) AS IQR,
    q.Q1 - 1.5 * (q.Q3 - q.Q1) AS lower_bound,
    q.Q3 + 1.5 * (q.Q3 - q.Q1) AS upper_bound,
    COUNT(CASE WHEN d.`Training Cost` < q.Q1 - 1.5*(q.Q3-q.Q1)
                 OR d.`Training Cost` > q.Q3 + 1.5*(q.Q3-q.Q1) THEN 1 END) AS so_outlier
FROM cleaned_hr_data_analysis d
CROSS JOIN quartiles q
GROUP BY q.Q1, q.Q3; -- DÒNG GIẢI CỨU LỖI 1140 NẰM Ở ĐÂY!

-- 4e. Xem chi tiết các outlier Training Cost
WITH quartiles AS (
    SELECT
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(`Training Cost` ORDER BY `Training Cost`), ',', FLOOR(0.25 * COUNT(*) + 1)), ',', -1) AS DECIMAL(10,2)) AS Q1,
        CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(`Training Cost` ORDER BY `Training Cost`), ',', FLOOR(0.75 * COUNT(*) + 1)), ',', -1) AS DECIMAL(10,2)) AS Q3
    FROM cleaned_hr_data_analysis
    WHERE `Training Cost` IS NOT NULL
)
SELECT d.`Employee ID`, d.`Training Cost`, d.DepartmentType
FROM cleaned_hr_data_analysis d
CROSS JOIN quartiles q
WHERE d.`Training Cost` < q.Q1 - 1.5*(q.Q3 - q.Q1)
   OR d.`Training Cost` > q.Q3 + 1.5*(q.Q3 - q.Q1)
ORDER BY d.`Training Cost` DESC;


-- ============================================================
-- BƯỚC 5: KIỂM TRA LOGIC NGÀY THÁNG
-- ============================================================

-- 5a. DOB hoặc StartDate lớn hơn ngày hiện tại (phi logic)
SELECT `Employee ID`, DOB, StartDate
FROM cleaned_hr_data_analysis
WHERE STR_TO_DATE(DOB, '%d-%m-%Y') > CURDATE()
   OR STR_TO_DATE(StartDate, '%d-%b-%y') > CURDATE();

-- 5b. Tuổi lúc vào làm < 18
SELECT
    COUNT(*) AS so_nguoi_vao_lam_truoc_18_tuoi
FROM cleaned_hr_data_analysis
WHERE TIMESTAMPDIFF(YEAR,
        STR_TO_DATE(DOB, '%d-%m-%Y'),
        STR_TO_DATE(StartDate, '%d-%b-%y')) < 18;

-- Chi tiết
SELECT
    `Employee ID`,
    DOB,
    StartDate,
    TIMESTAMPDIFF(YEAR,
        STR_TO_DATE(DOB, '%d-%m-%Y'),
        STR_TO_DATE(StartDate, '%d-%b-%y')) AS tuoi_luc_vao_lam
FROM cleaned_hr_data_analysis
WHERE TIMESTAMPDIFF(YEAR,
        STR_TO_DATE(DOB, '%d-%m-%Y'),
        STR_TO_DATE(StartDate, '%d-%b-%y')) < 18;

-- 5c. Training Date trước StartDate (phi logic)
SELECT COUNT(*) AS so_dong_training_truoc_ngay_vao_lam
FROM cleaned_hr_data_analysis
WHERE STR_TO_DATE(`Training Date`, '%d-%b-%y') < STR_TO_DATE(StartDate, '%d-%b-%y');

-- Chi tiết
SELECT
    `Employee ID`,
    StartDate,
    `Training Date`,
    DATEDIFF(
        STR_TO_DATE(`Training Date`, '%d-%b-%y'),
        STR_TO_DATE(StartDate,       '%d-%b-%y')
    ) AS so_ngay_chenh_lech
FROM cleaned_hr_data_analysis
WHERE STR_TO_DATE(`Training Date`, '%d-%b-%y') < STR_TO_DATE(StartDate, '%d-%b-%y')
ORDER BY so_ngay_chenh_lech;

-- 5d. Thêm cột ngày tháng đã parse đúng kiểu DATE
--     → Python / pandas sẽ đọc đúng ngay, không cần parse lại
--     Dùng INFORMATION_SCHEMA để kiểm tra cột trước khi ADD (tương thích MySQL)

SET SQL_SAFE_UPDATES = 0;

-- Tạo procedure tái sử dụng: chỉ ADD COLUMN khi cột chưa tồn tại
DROP PROCEDURE IF EXISTS add_col_if_missing;
DELIMITER $$
CREATE PROCEDURE add_col_if_missing(
    IN p_table  VARCHAR(64),
    IN p_col    VARCHAR(64),
    IN p_def    TEXT          -- phần sau tên cột, VD: "DATE AFTER DOB"
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = p_table
          AND COLUMN_NAME  = p_col
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL add_col_if_missing('cleaned_hr_data_analysis', 'dob_parsed',           'DATE AFTER DOB');
CALL add_col_if_missing('cleaned_hr_data_analysis', 'start_date_parsed',    'DATE AFTER StartDate');
CALL add_col_if_missing('cleaned_hr_data_analysis', 'training_date_parsed', 'DATE AFTER `Training Date`');

-- CHỈ CHẠY LỆNH NÀY ĐỂ ĐỔI DỮ LIỆU
UPDATE cleaned_hr_data_analysis
SET
    dob_parsed           = STR_TO_DATE(DOB, '%d-%m-%Y'),
    start_date_parsed    = STR_TO_DATE(StartDate, '%d-%b-%y'),
    training_date_parsed = STR_TO_DATE(`Training Date`,              '%d-%b-%y');

SET SQL_SAFE_UPDATES = 1;

-- Xác nhận không còn NULL sau khi parse
SELECT
    SUM(CASE WHEN dob_parsed           IS NULL THEN 1 ELSE 0 END) AS null_dob,
    SUM(CASE WHEN start_date_parsed    IS NULL THEN 1 ELSE 0 END) AS null_start,
    SUM(CASE WHEN training_date_parsed IS NULL THEN 1 ELSE 0 END) AS null_training
FROM cleaned_hr_data_analysis;


-- ============================================================
-- BƯỚC 6: KIỂM TRA TÍNH NHẤT QUÁN LOGIC NGHIỆP VỤ
-- ============================================================

-- 6a. Phân bố EmployeeType × EmployeeClassificationType
--     → Phát hiện tổ hợp bất thường (vd: Full-Time nhưng là Contractor)
SELECT
    EmployeeType,
    EmployeeClassificationType,
    COUNT(*) AS so_luong
FROM cleaned_hr_data_analysis
GROUP BY EmployeeType, EmployeeClassificationType
ORDER BY EmployeeType, EmployeeClassificationType;

-- 6b. Kiểm tra nhân viên "Active" nhưng không có dữ liệu Training
SELECT COUNT(*) AS active_khong_co_training
FROM cleaned_hr_data_analysis
WHERE EmployeeStatus = 'Active'
  AND (`Training Program Name` IS NULL OR `Training Program Name` = '');

-- 6c. Kiểm tra Performance Score không nằm trong danh sách hợp lệ
--     (điều chỉnh danh sách theo đúng giá trị thực tế của dữ liệu)
SELECT DISTINCT `Performance Score`
FROM cleaned_hr_data_analysis
WHERE `Performance Score` NOT IN (
    'Exceeds', 'Fully Meets', 'Needs Improvement', 'PIP'
);

-- 6d. Kiểm tra Current Employee Rating ngoài khoảng 1–5
SELECT COUNT(*) AS rating_phi_hop_le
FROM cleaned_hr_data_analysis
WHERE `Current Employee Rating` NOT BETWEEN 1 AND 5;


-- ============================================================
-- BƯỚC 7: PHÂN TÍCH NHÓM TUỔI >= 70 TRƯỚC KHI LỌC
-- ============================================================

-- 7a. Xem danh sách
SELECT `Employee ID`, Title, DepartmentType, Age, EmployeeStatus
FROM cleaned_hr_data_analysis
WHERE Age >= 70
ORDER BY Age DESC;

-- 7b. So sánh hành vi 2 nhóm
SELECT
    CASE WHEN Age >= 70 THEN 'Nhom >= 70' ELSE 'Nhom < 70' END AS phan_loai,
    COUNT(*)                                AS so_luong,
    ROUND(AVG(`Training Cost`), 2)          AS chi_phi_dao_tao_tb,
    ROUND(AVG(`Current Employee Rating`), 2) AS diem_danh_gia_tb,
    ROUND(AVG(`Engagement Score`), 2)       AS engagement_tb,
    ROUND(AVG(`Satisfaction Score`), 2)     AS satisfaction_tb
FROM cleaned_hr_data_analysis
GROUP BY phan_loai;

-- 7c. Phân bố PayZone của nhóm >= 70
SELECT PayZone, COUNT(*) AS so_luong
FROM cleaned_hr_data_analysis
WHERE Age >= 70
GROUP BY PayZone
ORDER BY so_luong DESC;


-- ============================================================
-- BƯỚC 8: XỬ LÝ MISSING VALUES — THỰC THI
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- 8a. Xoá dòng thiếu các cột định danh / khoá nghiệp vụ bắt buộc
--     (không thể impute được, giữ lại sẽ gây lỗi phân tích)
DELETE FROM cleaned_hr_data_analysis
WHERE `Employee ID`  IS NULL OR `Employee ID`  = ''
   OR DepartmentType IS NULL OR DepartmentType = ''
   OR EmployeeStatus IS NULL OR EmployeeStatus = ''
   OR GenderCode     IS NULL OR GenderCode     = ''
   OR Age            IS NULL;

-- 8b. Điền missing cho cột số bằng giá trị trung bình toàn bộ tập
--     (thực hiện trong subquery để tránh lỗi "can't update same table")
UPDATE cleaned_hr_data_analysis
SET `Engagement Score` = (
    SELECT AVG_val FROM (
        SELECT ROUND(AVG(`Engagement Score`), 2) AS AVG_val
        FROM cleaned_hr_data_analysis
        WHERE `Engagement Score` IS NOT NULL
    ) AS t
)
WHERE `Engagement Score` IS NULL;

UPDATE cleaned_hr_data_analysis
SET `Satisfaction Score` = (
    SELECT AVG_val FROM (
        SELECT ROUND(AVG(`Satisfaction Score`), 2) AS AVG_val
        FROM cleaned_hr_data_analysis
        WHERE `Satisfaction Score` IS NOT NULL
    ) AS t
)
WHERE `Satisfaction Score` IS NULL;

UPDATE cleaned_hr_data_analysis
SET `Work-Life Balance Score` = (
    SELECT AVG_val FROM (
        SELECT ROUND(AVG(`Work-Life Balance Score`), 2) AS AVG_val
        FROM cleaned_hr_data_analysis
        WHERE `Work-Life Balance Score` IS NOT NULL
    ) AS t
)
WHERE `Work-Life Balance Score` IS NULL;

UPDATE cleaned_hr_data_analysis
SET `Training Cost` = (
    SELECT AVG_val FROM (
        SELECT ROUND(AVG(`Training Cost`), 2) AS AVG_val
        FROM cleaned_hr_data_analysis
        WHERE `Training Cost` IS NOT NULL AND `Training Cost` > 0
    ) AS t
)
WHERE `Training Cost` IS NULL OR `Training Cost` <= 0;

UPDATE cleaned_hr_data_analysis
SET `Training Duration(Days)` = (
    SELECT AVG_val FROM (
        SELECT ROUND(AVG(`Training Duration(Days)`), 0) AS AVG_val
        FROM cleaned_hr_data_analysis
        WHERE `Training Duration(Days)` IS NOT NULL AND `Training Duration(Days)` > 0
    ) AS t
)
WHERE `Training Duration(Days)` IS NULL OR `Training Duration(Days)` <= 0;

-- 8c. Điền missing cho cột chữ ít quan trọng bằng 'Unknown'
UPDATE cleaned_hr_data_analysis
SET `Training Program Name` = 'Unknown'
WHERE `Training Program Name` IS NULL OR `Training Program Name` = '';

UPDATE cleaned_hr_data_analysis
SET `Training Type` = 'Unknown'
WHERE `Training Type` IS NULL OR `Training Type` = '';

UPDATE cleaned_hr_data_analysis
SET `Training Outcome` = 'Unknown'
WHERE `Training Outcome` IS NULL OR `Training Outcome` = '';

SET SQL_SAFE_UPDATES = 1;

-- 8d. Xác nhận không còn missing sau xử lý
SELECT
    SUM(CASE WHEN DepartmentType           IS NULL OR DepartmentType           = '' THEN 1 ELSE 0 END) AS missing_DepartmentType,
    SUM(CASE WHEN EmployeeStatus           IS NULL OR EmployeeStatus           = '' THEN 1 ELSE 0 END) AS missing_EmployeeStatus,
    SUM(CASE WHEN GenderCode               IS NULL OR GenderCode               = '' THEN 1 ELSE 0 END) AS missing_GenderCode,
    SUM(CASE WHEN `Performance Score`      IS NULL OR `Performance Score`      = '' THEN 1 ELSE 0 END) AS missing_PerformanceScore,
    SUM(CASE WHEN `Training Outcome`       IS NULL OR `Training Outcome`       = '' THEN 1 ELSE 0 END) AS missing_TrainingOutcome,
    SUM(CASE WHEN `Engagement Score`       IS NULL THEN 1 ELSE 0 END) AS missing_Engagement,
    SUM(CASE WHEN `Satisfaction Score`     IS NULL THEN 1 ELSE 0 END) AS missing_Satisfaction,
    SUM(CASE WHEN `Work-Life Balance Score` IS NULL THEN 1 ELSE 0 END) AS missing_WorkLifeBalance,
    SUM(CASE WHEN `Training Cost`          IS NULL THEN 1 ELSE 0 END) AS missing_TrainingCost,
    SUM(CASE WHEN `Training Duration(Days)` IS NULL THEN 1 ELSE 0 END) AS missing_TrainingDuration,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_Age
FROM cleaned_hr_data_analysis;


-- ============================================================
-- BƯỚC 9: TẠO BẢNG SẠCH hr_data_final
-- ============================================================

-- 9a. Xoá bảng cũ nếu tồn tại để tạo lại từ đầu
DROP TABLE IF EXISTS hr_data_final;

-- 9b. Tạo bảng sạch — lọc Age >= 70
CREATE TABLE hr_data_final AS
SELECT * FROM cleaned_hr_data_analysis
WHERE Age < 70;

-- 9c. Log số dòng trước/sau
SELECT
    'cleaned_hr_data_analysis (gốc)'   AS bang,
    COUNT(*) AS so_dong FROM cleaned_hr_data_analysis
UNION ALL
SELECT
    'hr_data_final (sau lọc Age < 70)' AS bang,
    COUNT(*) AS so_dong FROM hr_data_final;

SELECT
    (SELECT COUNT(*) FROM cleaned_hr_data_analysis) AS truoc_loc,
    (SELECT COUNT(*) FROM hr_data_final)             AS sau_loc,
    (SELECT COUNT(*) FROM cleaned_hr_data_analysis)
      - (SELECT COUNT(*) FROM hr_data_final)          AS so_dong_bi_loai;


-- ============================================================
-- BƯỚC 10: THÊM CỘT PHÁI SINH (FEATURE ENGINEERING)
--          Tạo sẵn trong SQL để Python dùng được ngay
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- 10a. Số năm làm việc tính đến hiện tại
CALL add_col_if_missing('hr_data_final', 'years_of_service', 'INT AFTER start_date_parsed');

UPDATE hr_data_final
SET years_of_service = TIMESTAMPDIFF(YEAR, start_date_parsed, CURDATE())
WHERE start_date_parsed IS NOT NULL;


-- 10b. Nhóm tuổi (Age group)
CALL add_col_if_missing('hr_data_final', 'age_group', 'VARCHAR(20) AFTER Age');

UPDATE hr_data_final
SET age_group = CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    WHEN Age BETWEEN 40 AND 49 THEN '40-49'
    WHEN Age BETWEEN 50 AND 59 THEN '50-59'
    ELSE '60+'
END;


-- 10c. Nhóm thâm niên (Tenure group)
CALL add_col_if_missing('hr_data_final', 'tenure_group', 'VARCHAR(20) AFTER years_of_service');

UPDATE hr_data_final
SET tenure_group = CASE
    WHEN years_of_service < 2              THEN '0-1 yr'
    WHEN years_of_service BETWEEN 2 AND 4  THEN '2-4 yrs'
    WHEN years_of_service BETWEEN 5 AND 9  THEN '5-9 yrs'
    ELSE '10+ yrs'
END;

-- 10d. Training ROI flag: Kết quả đào tạo tốt hay không
CALL add_col_if_missing('hr_data_final', 'training_success', 'TINYINT(1) AFTER `Training Outcome`');

UPDATE hr_data_final
SET training_success = CASE
    WHEN LOWER(`Training Outcome`) IN ('pass', 'completed', 'passed') THEN 1
    ELSE 0
END;

-- 10e. Engagement level (Low / Medium / High) - giả sử thang 1-10
CALL add_col_if_missing('hr_data_final', 'engagement_level', 'VARCHAR(10) AFTER `Engagement Score`');

UPDATE hr_data_final
SET engagement_level = CASE
    WHEN `Engagement Score` >= 7 THEN 'High'
    WHEN `Engagement Score` >= 4 THEN 'Medium'
    ELSE 'Low'
END;

SET SQL_SAFE_UPDATES = 1;


-- ============================================================
-- BƯỚC 11: KIỂM TRA CUỐI — TRƯỚC KHI ĐƯA VÀO PYTHON
-- ============================================================

-- 11a. Cấu trúc bảng cuối
DESCRIBE hr_data_final;

-- 11b. Mẫu 10 dòng đầu
SELECT * FROM hr_data_final LIMIT 10;

-- 11c. Thống kê tổng hợp bảng cuối
SELECT
    COUNT(*)                                 AS tong_so_dong,
    COUNT(DISTINCT `Employee ID`)            AS so_nhan_vien_unique,
    COUNT(DISTINCT DepartmentType)           AS so_phong_ban,
    COUNT(DISTINCT `Training Program Name`)  AS so_chuong_trinh_dao_tao,
    ROUND(AVG(Age), 1)                       AS tuoi_trung_binh,
    ROUND(AVG(years_of_service), 1)          AS than_nien_tb_nam,
    ROUND(AVG(`Training Cost`), 2)           AS chi_phi_dao_tao_tb,
    ROUND(AVG(`Engagement Score`), 2)        AS engagement_tb,
    ROUND(AVG(`Satisfaction Score`), 2)      AS satisfaction_tb,
    ROUND(AVG(`Work-Life Balance Score`), 2) AS worklife_tb,
    ROUND(100.0 * SUM(training_success) / COUNT(*), 1) AS ty_le_dao_tao_thanh_cong_pct
FROM hr_data_final;

-- 11d. Phân bố theo phòng ban
SELECT
    DepartmentType,
    COUNT(*)                                 AS so_nhan_vien,
    ROUND(AVG(`Training Cost`), 2)           AS chi_phi_dao_tao_tb,
    ROUND(AVG(`Current Employee Rating`), 2) AS diem_danh_gia_tb,
    ROUND(AVG(`Engagement Score`), 2)        AS engagement_tb
FROM hr_data_final
GROUP BY DepartmentType
ORDER BY so_nhan_vien DESC;

-- 11e. Phân bố Performance Score
SELECT
    `Performance Score`,
    COUNT(*)                                          AS so_luong,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS ty_le_pct
FROM hr_data_final
GROUP BY `Performance Score`
ORDER BY so_luong DESC;

-- 11f. Xếp hạng nhân viên theo Performance Score trong từng phòng ban
WITH xep_hang AS (
    SELECT
        `Employee ID`,
        DepartmentType,
        `Performance Score`,
        RANK() OVER (
            PARTITION BY DepartmentType
            ORDER BY `Performance Score` DESC
        ) AS hang_hieu_suat
    FROM hr_data_final
)
SELECT DepartmentType, `Employee ID`, `Performance Score`
FROM xep_hang
WHERE hang_hieu_suat = 1
ORDER BY DepartmentType;


select *
from  hr_data_final;

-- ============================================================
-- KẾT THÚC — bảng hr_data_final đã sẵn sàng cho Python / Power BI
-- ============================================================