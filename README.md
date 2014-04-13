# JHActionSheet

UIActionSheet is a basic UI component, but is not very userful for me.


It is hard to customize. You can reference subclassing note for UIActionSheet from apple doc.

	UIActionSheet is not designed to be subclassed, nor should you add views to its hierarchy. If you need to 	
	present a sheet with more customization than provided by the UIActionSheet API, you can create your own and 	
	present it modally with presentViewController:animated:completion:.
	
Therefore I simply create a subsitute for UIActionSheet called JHActionSheet.

JHActionSheet allows you to 

- customize the color for title and background. 
- customize the color for buttons and background.
- show subTitle under title(Of course you can also customize the color for subTitle and background)

Note: On iPad, JHActionSheet is not showing in the center of screen, it is different from UIActionSheet.

Here is a screenshot.

![ScreenShot](https://github.com/joehsieh/JHActionSheet/blob/master/screenShot.png?raw=true)

Enjoy it!


