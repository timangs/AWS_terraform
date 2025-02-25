<?php
   $con=mysqli_connect("database-1.cbwucaqcm637.ap-northeast-2.rds.amazonaws.com", "admin", "timangs123", "sqlDB") or die("MySQL 접속 실패 !!");
mysqli_set_charset($con, "utf8mb4");

$userID = $_POST["userID"];
$name = $_POST["name"];
$birthYear = $_POST["birthYear"];
$email = $_POST["email"];
$mobile = $_POST["mobile"];
$mDate = date("Y-m-j");

$sql = "INSERT INTO userTBL (userID, name, birthYear, email, mobile, mDate) VALUES (?, ?, ?, ?, ?, ?)";
$stmt = mysqli_prepare($con, $sql);
mysqli_stmt_bind_param($stmt, "ssisss", $userID, $name, $birthYear, $email, $mobile, $mDate);
$ret = mysqli_stmt_execute($stmt);

?>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>신규 회원 입력 결과</title>
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
    </style>
</head>
<body>
<div class="container">
    <h1>신규 회원 입력 결과</h1>
    <?php if ($ret): ?>
        <p>데이터가 성공적으로 입력됨.</p>
    <?php else: ?>
        <p>데이터 입력 실패!!!</p>
        <p>실패 원인: <?php echo mysqli_error($con); ?>.</p>
    <?php endif; ?>
    <a href="index.html">초기 화면</a>
</div>
</body>
</html>

<?php
mysqli_stmt_close($stmt);
mysqli_close($con);
?>