<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원 삭제</title>
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
            background: #dc3545; /* Red color for delete */
            color: #fff;
            border: none;
            cursor: pointer;
        }
        .button-group input:hover {
            background: #c82333; /* Darker red on hover */
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
        <h1>회원 삭제</h1>
        <form method="post" action="delete_result.php">
            <input type="text" name="userID" placeholder="삭제할 아이디 ">
            <div class="button-group">
                <input type="submit" value="삭제">
            </div>
        </form>
        <div class="info">hyzzangg@gmail.com/BlueJasmine CORP.</div>
    </div>
</body>
</html>