//
//  ViewController.m
//  JSONRottenTomatoes
//
//  Created by Brad Woodard on 8/3/13.
//  Copyright (c) 2013 Brad Woodard. All rights reserved.
//

#import "ViewController.h"
#import "Movie.h"
#import "RottenTomatoesConnection.h"

@interface ViewController () {
    BOOL                                arrayIsReady;
    NSString                            *randomMovieTitle;
    NSArray                             *moviesArray;
    NSArray                             *moviePostersArray;
    NSMutableArray                      *shakeArray;
    NSMutableArray                      *randomMovieSelectedArray;
    RottenTomatoesConnection            *rottenTomatoesConnection;
    __weak IBOutlet UITableView         *moviesTable;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    //the : for onMoviesInfo says it expects a parameter which is the notication and contains the userInfo..and userInfo contains the arrays
    
    rottenTomatoesConnection = [RottenTomatoesConnection new];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(onMoviesInfo:)
     name:@"MoviesInfo"
     object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMovieGenre:) name:@"MovieGenre" object:nil];
    
    [super viewDidLoad];
    [self getRottenTomatoesDATA];
    randomMovieSelectedArray = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (arrayIsReady == YES) {
        if (motion == UIEventSubtypeMotionShake) {
            if (shakeArray.count != 1) {
                [randomMovieSelectedArray removeAllObjects];
                int index = arc4random() % shakeArray.count;
                randomMovieTitle = [NSString stringWithFormat:@"%@", [[shakeArray objectAtIndex:index] movieTitle]];
                [randomMovieSelectedArray addObject:[shakeArray objectAtIndex:index]];
                [shakeArray removeObjectAtIndex:index];
                NSLog(@"Random Movie: %@", [[randomMovieSelectedArray objectAtIndex:0] movieTitle]);
                NSLog(@"Remaining Movies: %@", shakeArray);
            } else {
                NSLog(@"Random Movie: %@", [[randomMovieSelectedArray objectAtIndex:0] movieTitle]);
            }
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
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
    if (movie.movieGenre == nil) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@. Genre: Loading... Peer Rating: %@", movie.movieMPAA, movie.moviePeerRating];
        
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@. Genre: %@. Peer Rating: %@", movie.movieMPAA, movie.movieGenre, movie.moviePeerRating];
    }
    
    cell.imageView.image = moviePosterThumbnail;
    
    return cell;
}

- (void)getRottenTomatoesDATA
{
    [rottenTomatoesConnection getMovieInfo];
}


- (void)onMoviesInfo:(NSNotification *)note
{
    moviesArray = note.userInfo[@"movies"];
    moviePostersArray = note.userInfo[@"moviePosters"];
    [rottenTomatoesConnection performSelectorInBackground:@selector(getMovieGenres:) withObject:moviesArray];
    shakeArray = [[NSMutableArray alloc] initWithArray:moviesArray];
    arrayIsReady = YES;
}

- (void)onMovieGenre:(NSNotification *)note {
    [moviesTable reloadData];
}

@end
