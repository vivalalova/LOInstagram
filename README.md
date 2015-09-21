## FTInstagram

This allows you to get instagram auto of user in your app.
Learn more at https://instagram.com/developer/authentication/ 

Now just implemented about 

* Authentication 
* User base information
* Recent media published by user 

####TRY IT
----------------------
* Add FTInstagram.h and FTInstagram.m to your project
* Add AFNetworking to your project
* Build to check if error
* Create a Instagram app on instagram https://instagram.com/developer/clients/manage/
	* REDIRECT URI = " ig{Client_id}:// " , like following
	* ![enter image description here](https://github.com/FUNTEKco/FTInstagram/blob/master/instagram/InstagramClient.png?raw=true)
*  Modify info.plist of your project like following
	* ![enter image description here](https://github.com/FUNTEKco/FTInstagram/blob/master/instagram/infoPlist.png?raw=true)

AppDelegate.m
```objc
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [[FTInstagram shareInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
```

And others just like the example in  ViewController.m
```
[[FTInstagram shareInstance] loginWithScope:@[@"basic",@"comments",@"likes",@"relationships"] Completion:^(BOOL success, NSString *errorReason) {

}];
```

####feedback
-----------------
If any suggest,proposal , or bug .
Please let us know https://github.com/FUNTEKco/FTInstagram/issues
