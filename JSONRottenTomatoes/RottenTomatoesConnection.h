//
//  RottenTomatoesConnection.h
//  JSONRottenTomatoes
//
//  Created by Jeremy Herrero on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Movie.h"

@interface RottenTomatoesConnection : NSObject

- (void)getMovieInfo;
- (void)getMovieGenres:(NSArray *)movies;

@end
