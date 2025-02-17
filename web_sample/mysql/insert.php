<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-align: center;
        }
        div {
            max-width: 300px;
            width: 100%;
        }
        h1 {
            font-size: 1.5em;
            margin-bottom: 20px;
        }
        input {
            display: block;
            margin: 10px auto;
            padding: 10px;
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .button-group input {
            background: #007BFF;
            color: #fff;
            border: none;
            cursor: pointer;
        }
        .button-group input:hover {
            background: #0056b3;
        }
        .info {
            margin-top: 20px;
            font-size: 0.9em;
            color: #555;
        }
    </style>
</head>
<body>
    <div>
        <h1>신규 회원 입력</h1>
        <form method="post" action="insert_result.php">
            <input type="text" name="userID" placeholder="아이디">
            <input type="text" name="name" placeholder="이름">
            <input type="text" name="birthYear" placeholder="생년월일">
            <input type="text" name="email" placeholder="이메일주소">
            <input type="text" name="mobile" placeholder="휴대전화번호">
            <div class="button-group">
                <input type="submit" value="회원 입력">
            </div>
        </form>
        <div class="info">hyzzangg@gmail.com/BlueJasmine CORP.</div>
    </div>
</body>
</html>
