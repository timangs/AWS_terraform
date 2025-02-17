<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 정보 수정</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-align: center;
            background-color: #f4f4f4;
        }
        div {
            max-width: 300px;
            width: 100%;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            font-size: 1.5em;
            margin-bottom: 20px;
            color: #333;
        }
        input[type="text"], input[type="email"] {
            display: block;
            margin: 10px auto;
            padding: 10px;
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }
        input[type="text"][readonly] {
            background-color: #f0f0f0;
            color: #777;
            cursor: not-allowed;
        }
        input[type="submit"] {
            background: #28a745;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
        }
        input[type="submit"]:hover {
            background: #218838;
        }
        .error-message {
            color: red;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div>
        <h1>회원 정보 수정</h1>

        <?php
        $con = mysqli_connect("database-1.cbwucaqcm637.ap-northeast-2.rds.amazonaws.com", "admin", "timangs123", "sqlDB") or die("MySQL 접속 실패 !!");
        mysqli_set_charset($con, "utf8mb4");

        $userID = "";
        $name = "";
        $birthYear = "";
        $email = "";
        $mobile = "";
        $errorMessage = "";

        // GET 방식으로 userID를 받음
        if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['userID'])) {
            $userID = $_GET["userID"];

            $sql = "SELECT name, birthYear, email, mobile FROM userTBL WHERE userID = ?";
            $stmt = mysqli_prepare($con, $sql);

            if ($stmt === false) {
                $errorMessage = "Prepared Statement 생성 실패: " . mysqli_error($con);
            } else {
                mysqli_stmt_bind_param($stmt, "s", $userID);
                $executeResult = mysqli_stmt_execute($stmt);

                if ($executeResult === false) {
                  $errorMessage = "데이터 조회 실패: " . mysqli_stmt_error($stmt);
                } else {
                  mysqli_stmt_bind_result($stmt, $name, $birthYear, $email, $mobile);

                  if (!mysqli_stmt_fetch($stmt)) { // 결과가 없는 경우
                      $errorMessage = "해당 아이디를 찾을 수 없습니다.";
                  }
                }
                mysqli_stmt_close($stmt);
            }
        }
        mysqli_close($con);
        ?>

        <?php if (!empty($errorMessage)): ?>
            <div class="error-message"><?php echo htmlspecialchars($errorMessage); ?></div>
        <?php endif; ?>


        <form method="post" action="update_result.php">
            <input type="text" name="userID" value="<?php echo htmlspecialchars($userID); ?>" readonly>  <input type="text" name="name" placeholder="새 이름" value="<?php echo htmlspecialchars($name); ?>">
            <input type="text" name="birthYear" placeholder="새 생년월일" value="<?php echo htmlspecialchars($birthYear); ?>">
            <input type="email" name="email" placeholder="새 이메일" value="<?php echo htmlspecialchars($email); ?>">
            <input type="text" name="mobile" placeholder="새 휴대폰 번호" value="<?php echo htmlspecialchars($mobile); ?>">

            <input type="submit" value="수정">

        </form>

    </div>
</body>
</html>