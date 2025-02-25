<?php
$con = mysqli_connect("database-1.cbwucaqcm637.ap-northeast-2.rds.amazonaws.com", "admin", "timangs123", "sqlDB") or die("MySQL 접속 실패 !!");
mysqli_set_charset($con, "utf8mb4");

$userID = $_POST["userID"];
$name = $_POST["name"];
$birthYear = $_POST["birthYear"];
$email = $_POST["email"];
$mobile = $_POST["mobile"];

// 빈 값이 들어오면 NULL로 처리.  nullIf 함수 정의
function nullIfEmpty($value) {
  return ($value === '' || $value === null) ? NULL : $value; // 명시적 null, 빈 문자열 모두 처리
}

$name = nullIfEmpty($name);
$birthYear = nullIfEmpty($birthYear);
$email = nullIfEmpty($email);
$mobile = nullIfEmpty($mobile);

// userID는 WHERE 절에서 사용, 변경 X
$sql = "UPDATE userTBL SET
            name = COALESCE(?, name),
            birthYear = COALESCE(?, birthYear),
            email = COALESCE(?, email),
            mobile = COALESCE(?, mobile)
        WHERE userID = ?";

$stmt = mysqli_prepare($con, $sql);

if ($stmt === false) {
    die("Prepared Statement 생성 실패: " . mysqli_error($con)); // die()로 처리
}

mysqli_stmt_bind_param($stmt, "sssss", $name, $birthYear, $email, $mobile, $userID);
$ret = mysqli_stmt_execute($stmt);

if ($ret === false) {
    $error_message = mysqli_stmt_error($stmt); // 에러 메시지 저장
}

mysqli_stmt_close($stmt);
mysqli_close($con);

?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 정보 수정 결과</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            padding: 20px;
            text-align: center;
            width: 300px;
        }
        h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
        }
        p {
            font-size: 16px;
            color: #555;
            margin-bottom: 20px;
        }
        a {
            color: #007BFF;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
        .error-message { /* 에러 메시지 스타일 */
          color: red;
          margin-bottom: 10px;
      }
    </style>
</head>
<body>
    <div class="container">
        <h1>회원 정보 수정 결과</h1>
        <?php if ($ret): ?>
            <p>회원 정보가 성공적으로 수정되었습니다.</p>
        <?php else: ?>
            <p>회원 정보 수정 실패!!!</p>
             <p class="error-message">실패 원인: <?php echo htmlspecialchars($error_message); ?></p>
        <?php endif; ?>
        <a href="index.html">초기 화면</a>
    </div>
</body>
</html>