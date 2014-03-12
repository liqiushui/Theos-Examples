//Before we do anything, let's declare an NSString called wrongPass which we'll use later.
NSString *wrongPass = nil;

//Here, we're telling theos we want to 'hook' the header SBLockScreenView. 'Hooking' basically means we want to access this header and modify the methods inside it.
%hook SBDeviceLockController


//In this example, we are hijacking the method - (BOOL)attemptDeviceUnlockWithPassword and making it run our own code. This method takes a few arguments, (id)arg1 and (BOOL)arg2, however, you can rename these arguments anything you'd like, such as (id)testName.
- (BOOL)attemptDeviceUnlockWithPassword:(id)passEntered appRequested:(BOOL)arg2 {

    //IF the original method returned false (remember, the method we're hooking is a bool),
    if (!%orig) {
        
         //THEN set the string wrongPass (which we defined earlier) to the custom argument 'passEntered'.
        wrongPass = passEntered;
        
    }
        
    //Then, once you're done with the above, return the original method without modifying it at all.
    return %orig;
    
}

//This lets theos know that we're done hooking this header.
%end

//Now, we'll hook the header SBUIPasscodeLockViewWithKeypad. From the name, we can infer that this header is the view we see on the 'Enter Passcode' view.
%hook SBUIPasscodeLockViewWithKeypad

//Let's hijack the method - (id)statusTitleView, which sets the 'Enter passcode' text.
- (id)statusTitleView {

    //If the wrongPass string actually contains any information, (i.e. the 'if' block in the above hook did run),
    if (wrongPass != nil) {

        //THEN, 'hook' the ivar called '_statusTitleView'.
        
        //This is how you hook an ivar, or 'instance variable'. The syntax is a little weird, but what we're doing in this line is declaring a new UILabel called 'label' which ovverrides ('hooks into') the ivar '_statusTitleView, which is an ivar of the SBUIPasscodeLockViewWithKeypad header.
        UILabel *label = MSHookIvar<UILabel *>(self, "_statusTitleView");
        
        //Now, we're setting this UILabel to the wrongPass string.
        label.text = [NSString stringWithFormat:@"You entered %@", wrongPass];
        
        //Finally, return this label instead of whatever - (id)statusTitleView would've originally returned.
        return label;

    }
    
    
    //However, if the above code *didn't* run, (i.e. a wrong password was not entered and the wrongPass string still equaled nil), just return the original method as if we didn't change anything. '%orig' basically just means 'do whatever you were going to do before i got here', and since we're hooking a method which needs something to be returned (id), we *return* the original function.
    return %orig;
    
}

//Tell theos we're done with this header.
%end
