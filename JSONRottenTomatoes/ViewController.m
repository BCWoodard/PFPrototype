//
//  ViewController.m
//  JSONRottenTomatoes
//
//  Created by Brad Woodard on 8/3/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "ViewController.h"
#import "Movie.h"

@interface ViewController ()
{
    NSArray                     *moviesArray;
    NSArray                     *moviePostersArray;
    __weak IBOutlet UITableView *moviesTable;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(getMovieGenre)
     name:@"MoviesArray"
     object:nil];
    
    [super viewDidLoad];
    [self getRottenTomatoesDATA];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [moviesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    // Grab movie object and poster thumbnail from their respective arrays
    Movie *movie = [moviesArray objectAtIndex:indexPath.row];
    UIImage *moviePosterThumbnail = [moviePostersArray objectAtIndex:indexPath.row];

    cell.textLabel.text = movie.movieTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@. Genre: %@. Peer Rating: %@", movie.movieMPAA, movie.movieGenre, movie.moviePeerRating];
    cell.imageView.image = moviePosterThumbnail;
    
    return cell;
}

- (void)getRottenTomatoesDATA
{
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=16&page=1&country=us&apikey=xx88qet7sppj6r7jp7wrnznd"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
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
        moviePostersArray = [NSArray arrayWithArray:tempPostersArray];
        moviesArray = [NSArray arrayWithArray:tempArray];
        
        // Send notification that our download is complete
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MoviesArray" object:nil];
        
        // Stop NetworkActivityIndicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
}


- (void)getMovieGenre
{
    // Activate the Network Activity Indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    // Get the ID for each movie object and retrieve the first genre entry
    // for each film from Movie Info JSON
    for (Movie *movie in moviesArray) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/movies/%@.json?apikey=xx88qet7sppj6r7jp7wrnznd", movie.movieID]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        
            // Access the movie info dictionary on Rotten Tomatoes and set the
            // movie genre to the first element in the "genres" array
            NSDictionary *movieInfoDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSArray *movieGenresArray = [movieInfoDictionary objectForKey:@"genres"];
            movie.movieGenre = [movieGenresArray objectAtIndex:0];
            
            // Stop the Network Activity Indicator
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            [moviesTable reloadData];
            
        }];
    }
}

@end
