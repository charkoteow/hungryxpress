<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome Template</title>
        <style>
                .logo{
                    padding: 10px;
                    background-color: #f8f8f4;
                    display: flex;
                }
                .logo p{
                    font-family: sans-serif;
                    font-size: 20px;
                }

                .content{
                    padding: 10px;
                }

                .make_strong{
                    font-weight: bold;
                }
            </style>
    </head>
    <body>
        <table cellpadding="0" cellspacing="0" align="center" bgcolor="#ffffff" width="100%" style="max-width:670px;border:1px solid #e8e8e8">
            <tbody>

                <tr>
                    <td class="logo">
                        <div style="float:left;width:100px;" >
                            <img src="http://3.1.102.84/images/logo_default.png" alt="" style="width:100%;" border="0" class="">
                        </div>
                        <div style="padding-left: 15px;" >
                            <p>Hungry Express</p>
                        </div>
                        <div style="clear:both"></div>
                    </td>
                </tr>

                <tr> 
                    <td>
                        <div class="content" >
                            <p class="make_strong" >Hi {{ $name }},</p>
                            <p>Greetings from the team of <span class="make_strong" >Hungry Express.</span></p>
                            <p>Your account has been successfully registered.</p>
                            <a href="https://3.1.102.84/" target="_blank" >Click to login</a>
                        </div>
                    </td>
                </tr>

                <tr>
                    <td bgcolor="#E0E0E0" valign="center" align="center" height="50" style="color:#000000;font:600 13px/18px Segoe UI,Arial">
                        Copyright © HungryExpress, All rights reserved.
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>