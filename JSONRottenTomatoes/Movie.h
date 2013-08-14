//
//  Movie.h
//  JSONRottenTomatoes
//
//  Created by Brad Woodard on 8/13/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (strong, nonatomic) NSString *movieID;
@property (strong, nonatomic) NSString *movieTitle;
@property (strong, nonatomic) NSString *movieGenre;
@property (strong, nonatomic) NSString *moviePeerRating;
@property (strong, nonatomic) NSString *movieListImageURL;
@property (strong, nonatomic) NSString *movieMPAA;

// Overwrite init with a method to create our Movie object directly
// from the Movie Dictionary we retrieve from Rotten Tomatoes
- (instancetype)initWithMovieDictionary:(NSDictionary *)movieDictionary;

@end
