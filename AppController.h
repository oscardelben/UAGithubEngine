//
//  UAGithubEngineAppDelegate.h
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngineGlobalHeader.h"

#import "UAGithubEngine.h"


@interface AppController : NSObject <UAGithubEngineDelegate> {
    UAGithubEngine *githubEngine;
	
}

@end
