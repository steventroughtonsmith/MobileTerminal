// VT100TableViewController.m
// MobileTerminal

#import "VT100TableViewController.h"

#import "ColorMap.h"
#import "FontMetrics.h"
#import "VT100RowView.h"
#import "VT100Types.h"

@implementation VT100TableViewController

@synthesize fontMetrics;
@synthesize stringSupplier;

- (id) initWithColorMap:(ColorMap*)someColormap;
{
  self = [super init];
  if (self != nil) {
    colorMap = [someColormap retain];

//	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	  
	  [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	  [[UITableView appearance] setBackgroundColor:[UIColor blackColor]];
	  
	[self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
	[self.tableView setBackgroundColor:[colorMap background]];
	  
//	  self.tableView.backgroundView.backgroundColor = [UIColor redColor];
	  
//	   self.tableView.
//	  self.tableView.cellLayoutMarginsFollowReadableWidth = YES;
	  
//	  self.view.backgroundColor = [UIColor blackColor];
	  self.view.opaque = YES;
//	  [self.tableView setBackgroundView:nil];
	  self.tableView.opaque = YES;
	 //[colorMap background]];
    [self.tableView setAllowsSelection:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setSeparatorColor:[UIColor clearColor]];
	  self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
//	  self.tableView.hidden = YES;
//	  self.tableView.separatorEffect = nil;
}
  return self;
}

- (void) dealloc
{
  [colorMap release];
  [super dealloc];
}

// Computes the size of a single row
- (CGRect)cellFrame {
  CGFloat height = [fontMetrics boundingBox].height;
  CGFloat width = [self.tableView bounds].size.width;
  return CGRectMake(0, 0, width, height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self cellFrame].size.height;
}

#pragma mark -
#pragma mark Table view data source
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Remove seperator inset
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	
	// Prevent the cell from inheriting the Table View's margin settings
	if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
	
	// Explictly set your cell's layout margins
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [stringSupplier rowCount];
}

- (UITableViewCell*)tableViewCell:(UITableView *)tableView
{
  static NSString * kCellIdentifier = @"Cell";
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCellIdentifier] autorelease];
    VT100RowView* rowView =
        [[VT100RowView alloc] initWithFrame:[self cellFrame]];
	  
    rowView.stringSupplier = stringSupplier;
   [cell.contentView addSubview:rowView];
	  
	  cell.layoutMargins = UIEdgeInsetsZero;
	  cell.preservesSuperviewLayoutMargins = NO;
	  
    [rowView release];	  
  }
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSAssert(fontMetrics != nil, @"fontMetrics not initialized");
  NSAssert(stringSupplier != nil, @"stringSupplier not initialized");
    
  // Ignore position 0 since it should always be 0.  The row number here is not
  // just the row on the screen -- it also includes rows in the scrollback
  // buffer.
  NSAssert([indexPath indexAtPosition:0] == 0, @"Invalid index");
  NSUInteger tableRow = [indexPath indexAtPosition:1];
  NSAssert(tableRow < [stringSupplier rowCount], @"Invalid table row index");
  
  // This table has a single type of row that represents a line of text.  The
  // actual row object is configured once, but the text is replaced every time
  // we return a new cell object.
  UITableViewCell *cell = [self tableViewCell:tableView];
	
  // Update the line of text (via row number) associated with this cell
  NSArray* subviews = [cell.contentView subviews];
  NSAssert([subviews count] == 1, @"Invalid contentView size");
  VT100RowView* rowView = [subviews objectAtIndex:0];
  rowView.rowIndex = (int)tableRow;
  rowView.fontMetrics = fontMetrics;  
  // resize the row in case the table has changed size
  cell.frame = [self cellFrame];
  rowView.frame = [self cellFrame];  
  [cell setNeedsDisplay];
  [rowView setNeedsDisplay];
  return cell;  
}

- (void)scrollToBottom:(BOOL)animated
{
  NSUInteger indexes[2];
  indexes[0] = 0;
  indexes[1] = [self tableView:[self tableView] numberOfRowsInSection:0] - 1;
  NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
  [self.tableView scrollToRowAtIndexPath:indexPath
                        atScrollPosition:UITableViewScrollPositionBottom
                                animated:animated];              
}

- (void)refresh
{
  UITableView* tableView = [self tableView];
  [tableView reloadData];
  [tableView setNeedsDisplay];  
  // Scrolling to the bottom with animations looks much nicer, but will not
  // work if the table cells have not finished loading yet.
  // [self scrollToBottom:NO];
}

@end

