//
//  ChallengeFriendsViewController.m
//  NumeroLoco
//
//  Created by Developer on 28/07/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "ChallengeFriendsViewController.h"
#import "FriendsCell.h"
#import "GameKitHelper.h"

#define kPlayerKey @"player"
#define kScoreKey @"score"
#define kIsChallengedKey @"isChallenged"

#define kCheckMarkTag 4

@interface ChallengeFriendsViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, GameKitHelperProtocol>
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UITextField *messageTextfield;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *dataSource;
@end

@implementation ChallengeFriendsViewController

#pragma mark - Lazy Instantiation 

-(NSMutableDictionary *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableDictionary alloc] init];
    }
    return _dataSource;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self gameCenterSetup];
    [self setupUI];
}

-(void)gameCenterSetup {
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    gameKitHelper.delegate = self;
    [gameKitHelper findScoresOfFriendsToChallenge];
}

-(void)setupUI {
    //NavigationBar
    self.navBar = [[UINavigationBar alloc] init];
    [self.view addSubview:self.navBar];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"Challenge Friends"];
    self.navBar.items = @[navigationItem];
    
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
    navigationItem.leftBarButtonItem = closeBarButtonItem;
    
    UIBarButtonItem *challengeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Challenge" style:UIBarButtonItemStylePlain target:self action:@selector(challengeFriend)];
    navigationItem.rightBarButtonItem = challengeBarButtonItem;
    
    //Message label
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.text = @"Challenge Message:";
    self.messageLabel.textColor = [UIColor lightGrayColor];
    self.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    [self.view addSubview:self.messageLabel];
    
    //Challenge Textfield
    self.messageTextfield = [[UITextField alloc] init];
    self.messageTextfield.textColor = [UIColor lightGrayColor];
    self.messageTextfield.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    self.messageTextfield.borderStyle = UITextBorderStyleRoundedRect;
    self.messageTextfield.delegate = self;
    [self.view addSubview:self.messageTextfield];
    
    //Friends TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.rowHeight = 80.0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FriendsCell class] forCellReuseIdentifier:@"CellIdentifier"];
    [self.view addSubview:self.tableView];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    NSLog(@"bounds: %@", NSStringFromCGRect(self.view.bounds));
    self.navBar.frame = CGRectMake(0.0, 0.0, bounds.size.width, 44.0);
    self.messageLabel.frame = CGRectMake(20.0, 80.0, 180.0, 30.0);
    self.messageTextfield.frame = CGRectMake(self.messageLabel.frame.origin.x + self.messageLabel.frame.size.width + 10.0, 75.0, bounds.size.width - (self.messageLabel.frame.origin.x + self.messageLabel.frame.size.width + 10.0 + 20.0), 40.0);
    self.tableView.frame = CGRectMake(0.0, self.messageTextfield.frame.origin.y + self.messageTextfield.frame.size.height + 60.0, bounds.size.width, bounds.size.height - (self.messageTextfield.frame.origin.y + self.messageTextfield.frame.size.height + 60.0));
}

#pragma mark - UITableViewDataSource 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    if (!cell) {
        cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    //cell.friendName.text = @"Diego Fernando Vidal Illera";
    //cell.friendScore.text = @"5400";
    
    NSDictionary *dict = [self.dataSource allValues][indexPath.row];
    GKScore *score = dict[kScoreKey];
    GKPlayer *player = dict[kPlayerKey];
    NSNumber *number = dict[kIsChallengedKey];
    
    if ([number boolValue] == YES) {
        cell.checkmark.hidden = NO;
    } else {
        cell.checkmark.hidden = YES;
    }
    
    [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
         if (!error) {
             cell.friendImageView.image = photo;
         } else {
             NSLog(@"Error loading image");
         }
     }];
    
    cell.friendName.text = player.displayName;
    cell.friendScore.text = score.formattedValue;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isChallenged = NO;
    
    //1
    FriendsCell *tableViewCell = (FriendsCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (tableViewCell.checkmark.isHidden == NO) {
        tableViewCell.checkmark.hidden = YES;
    } else {
        tableViewCell.checkmark.hidden = NO;
        isChallenged = YES;
    }
    
    NSArray *array = [self.dataSource allValues];
    NSMutableDictionary *dict = array[indexPath.row];
    
    //4
    [dict setObject:[NSNumber numberWithBool:isChallenged] forKey:kIsChallengedKey];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

-(void)challengeFriend {
    //1
    if ([self.messageTextfield.text length] > 0) {
        self.messageTextfield.layer.borderColor = [UIColor clearColor].CGColor;
        //2
        NSMutableArray *playerIds = [NSMutableArray array];
        NSArray *allValues = [self.dataSource allValues];
        
        for (NSDictionary *dict in allValues) {
            if ([dict[kIsChallengedKey] boolValue] == YES) {
                
                GKPlayer *player = dict[kPlayerKey];
                [playerIds addObject:player.playerID];
            }
        }
        if (playerIds.count > 0) {
            //3
            [[GameKitHelper sharedGameKitHelper] sendScoreChallengeToPlayers:playerIds withScore:self.score message:
             self.messageTextfield.text];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please select at least one player" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
        /*if (self.challengeButtonPressedBlock) {
            self.challengeButtonPressedBlock();
        }*/
    } else {
        self.messageTextfield.layer.borderWidth = 2;
        self.messageTextfield.layer.borderColor = [UIColor redColor].CGColor;
    }
}

-(void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UItextfieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - GameKitHelperDelegate

-(void)onScoresOfFriendsToChallengeListReceived:(NSArray *)scores {
    //1
    NSMutableArray *playerIds =
    [NSMutableArray array];
    
    //2
    [scores enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop){
         
         GKScore *score = (GKScore*) obj;
         
         //3
         if(self.dataSource[score.playerID]
            == nil) {
             self.dataSource[score.playerID] =
             [NSMutableDictionary dictionary];
             [playerIds addObject:score.playerID];
         }
         
         //4
         if (score.value < _score) {
             [self.dataSource[score.playerID]
              setObject:[NSNumber numberWithBool:YES]
              forKey:kIsChallengedKey];
         }
         
         //5
         [self.dataSource[score.playerID]
          setObject:score forKey:kScoreKey];
     }];
    
    //6
    [[GameKitHelper sharedGameKitHelper]
     getPlayerInfo:playerIds];
    [self.tableView reloadData];
}

-(void) onPlayerInfoReceived:(NSArray*)players {
    //1
    [players
     enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         
         GKPlayer *player = (GKPlayer*)obj;
         
         //2
         if (self.dataSource[player.playerID]
             == nil) {
             self.dataSource[player.playerID] =
             [NSMutableDictionary dictionary];
         }
         [self.dataSource[player.playerID]
          setObject:player forKey:kPlayerKey];
         
         //3
         [self.tableView reloadData];
     }];
}

@end
