#KSharedSDK
轻松一键分享内容到 新浪微博，腾讯微博，QQ好友，微信朋友圈，微信好友。

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/kylescript/ksharedsdk/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

###为什么会有KSharedSDK？
--------------

###新浪微博，腾讯微博分享还未完成
-------------

##注意事项
####1.关于新浪微博
①申请一个新浪微博应用，地址：http://open.weibo.com/apps

②在应用高级信息里，填写授权回调页，取消授权回调页，并确保与代码中保持一致（kSinaWeiboRedirectURI）：https://github.com/kylescript

③在工程plist文件中，添加URL Types->URL Schemes->Item0内容为KSharedSDKDemo，并确保与代码中保持一致（kAppURLScheme），此参数用于应用（微博官方应用和我们的应用）之间参数传递。
