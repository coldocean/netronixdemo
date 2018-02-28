//
//  DebugLog.h
//  netronixdemo
//
//  Created by Oleg Sitovs on 26/02/2018.
//  Copyright © 2018 Oleg Sitovs. All rights reserved.
//

#if DEVELOPMENT
#   define DebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DebugLog(...)
#endif

