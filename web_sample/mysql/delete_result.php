<?php
$con = mysqli_connect("database-1.cbwucaqcm637.ap-northeast-2.rds.amazonaws.com", "admin", "timangs123", "sqlDB") or die("MySQL 접속 실패 !!");
mysqli_set_charset($con, "utf8mb4");

$userID = $_POST["userID"];

$sql = "DELETE FROM userTBL WHERE userID = ?"; // Prepared Statement 사용
$stmt = mysqli_prepare($con, $sql);

if ($stmt === false) {  // Prepare 실패 처리
    die("Prepared Statement 생성 실패: " . mysqli_error($con));
}

mysqli_stmt_bind_param($stmt, "s", $userID);
$ret = mysqli_stmt_execute($stmt);

if ($ret === false) { // Execute 실패 처리
     $error_message = mysqli_stmt_error($stmt);
}
?>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 삭제 결과</title>
    <style>
        /* (스타일은 insert_result.php와 동일하게 유지) */
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
    </style>
</head>
<body>
    <div class="container">
        <h1>회원 삭제 결과</h1>
        <?php if ($ret): ?>
            <p>회원 정보가 성공적으로 삭제되었습니다.</p>
        <?php else: ?>
            <p>회원 정보 삭제 실패!!!</p>
            <p>실패 원인: <?php echo htmlspecialchars($error_message); // XSS 방지 ?></p>
        <?php endif; ?>
        <a href="index.html">초기 화면</a>
    </div>
</body>
</html>

<?php
mysqli_stmt_close($stmt);
mysqli_close($con);
?>