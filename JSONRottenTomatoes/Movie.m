//
//  Movie.m
//  JSONRottenTomatoes
//
//  Created by Brad Woodard on 8/13/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (instancetype)initWithMovieDictionary:(NSDictionary *)movieDictionary
{
    self = [super init];
    
    if (self) {
        _movieID = [movieDictionary valueForKey:@"id"];
        _movieTitle = [movieDictionary valueForKey:@"title"];
        _moviePeerRating = [[movieDictionary objectForKey:@"ratings"] valueForKey:@"audience_score"];
        _movieListImageURL = [[movieDictionary objectForKey:@"posters"] valueForKey:@"profile"];
        _movieMPAA = [movieDictionary objectForKey:@"mpaa_rating"];
    }
    
    return self;
}

@end
