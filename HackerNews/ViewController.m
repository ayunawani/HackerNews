//
//  ViewController.m
//  HackerNews
//
//  Created by Ayush Nawani on 30/08/16.
//  Copyright © 2016 Ayush Nawani. All rights reserved.
//

#import "ViewController.h"
#import "NewsFetcher.h"
#import "NewsStories.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *allStories;
    NSMutableArray *allNews;
    NewsFetcher *newsFetcher;
}

-(void)viewWillAppear:(BOOL)animated
{
    newsFetcher = [[NewsFetcher alloc] init];
    newsFetcher.managedObjectContext = self.managedObjectContext;
    
    if (allNews.count < 400) {
        //NSInteger nextList = allNews.count;
        allStories = [newsFetcher fetchNewsFromServer:0 endIndex:10];
        [self saveNews];
        [self fetchNewsFromDB];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (BOOL)saveNews {
    
    NSDictionary *story;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    
    for (NSInteger i = 0; i < allStories.count; i++) {
        
        story = [allStories objectAtIndex:i];
        
        NSNumber *score = [story objectForKey:@"score"];
        NSString *author = [story objectForKey:@"by"];
        NSString *url = [story objectForKey:@"url"];
        NSString *title = [story objectForKey:@"title"];
        
        
        NSManagedObject *newStoriesObject = [NSEntityDescription insertNewObjectForEntityForName:@"NewsStories" inManagedObjectContext:context];
        
        [newStoriesObject setValue:score forKey:@"score"];
        [newStoriesObject setValue:url forKey:@"url"];
        [newStoriesObject setValue:author forKey:@"author"];
        [newStoriesObject setValue:title forKey:@"title"];
        
        NSError *error = nil;
        // Save the object to persistent store
        
        
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
    }
    
    return true;
}

-(BOOL)fetchNewsFromDB {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsStories"];
    allNews = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    //    [self.tableView reloadData];
    
    return true;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NewsStories *story = allNews[indexPath.item];
    UITextView *title = (UITextView *)[cell viewWithTag:1];
    UILabel *author = (UILabel *)[cell viewWithTag:2];
    title.scrollEnabled = NO;
    title.text = story.title;
    author.text = story.author;
    [title sizeToFit];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 400;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item  = indexPath.item;
    if (item > 0 && allNews.count-5 == indexPath.item) {
        
        if (allNews.count < 400) {
            NSInteger nextList = allNews.count;
            allStories = [newsFetcher fetchNewsFromServer:nextList endIndex:nextList + 5];
            [self saveNews];
            [self fetchNewsFromDB];
        }
    }
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NewsStories *story = allNews[indexPath.item];
    
    NSString *url = story.url;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
