//
//  RottenTomatoesConnection.m
//  JSONRottenTomatoes
//
//  Created by Jeremy Herrero on 8/14/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "RottenTomatoesConnection.h"
#import "Movie.h"

@implementation RottenTomatoesConnection {
    int numberOfNetworkCalls;
}

- (void)getMovieInfo {
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=16&page=1&country=us&apikey=xx88qet7sppj6r7jp7wrnznd"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    numberOfNetworkCalls++;
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error)
            NSLog(@"%@", error);
        
        if (data == nil) // DONT THROW EXCEPTIONS IN JSONObjectWithData
            data = [NSData data];

        // Retrieve all the Rotten Tomatoes movie data
        NSDictionary *rottenTomatoesJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        // Create an array of movie data and 2 temp arrays -
        // One to hold movie objects - tempArray
        // One to hold poster images - tempPostersArray
        NSArray *dataMovieArray = [rottenTomatoesJSON objectForKey:@"movies"];
        NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[dataMovieArray count]];
        NSMutableArray *tempPostersArray = [NSMutableArray arrayWithCapacity:[dataMovieArray count]];
        
        for (NSDictionary *dictionary in dataMovieArray) {
            // Create a movie using our init override method in Movie.m
            Movie *movie = [[Movie alloc] initWithMovieDictionary:dictionary];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:movie.movieListImageURL]];
            UIImage *moviePosterThumbnail = [UIImage imageWithData:data];
            [tempPostersArray addObject:moviePosterThumbnail];
            [tempArray addObject:movie];
        }
        
        // Populate our NSArrays with temporary mutable arrays
        // Again, we do this to protect our arrays from accidental edits, etc.
        NSArray *moviePostersArray = [NSArray arrayWithArray:tempPostersArray];
        NSArray *moviesArray = [NSArray arrayWithArray:tempArray];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MoviesInfo" object:nil userInfo:@{
            @"moviePosters": moviePostersArray,
            @"movies": moviesArray
         }];
        
        // Stop NetworkActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
}

- (void)getMovieGenres:(NSArray *)movies {
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Get the ID for each movie object and retrieve the first genre entry
    // for each film from Movie Info JSON

    for (Movie *movie in movies) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/movies/%@.json?apikey=xx88qet7sppj6r7jp7wrnznd", movie.movieID]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        numberOfNetworkCalls++;

        // Rotten Tomatoes only allow 10 calls per second. So we must wait for a
        // second or we get errors back.
        if (numberOfNetworkCalls % 10 == 0)
            usleep(1000 * 1000);

        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            // Access the movie info dictionary on Rotten Tomatoes and set the
            // movie genre to the first element in the "genres" array
            NSDictionary *movieInfoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *movieGenresArray = [movieInfoDictionary objectForKey:@"genres"];
            movie.movieGenre = [movieGenresArray objectAtIndex:0];
            
            if (error) {
                NSLog(@"Error: %@", error);
                NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
            
            // Stop the Network Activity Indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MovieGenre" object:nil userInfo:@{@"movie": movie}];
        }];
    }
}
@end
