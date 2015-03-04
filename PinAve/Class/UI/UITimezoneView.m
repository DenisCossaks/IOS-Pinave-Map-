//
//  UITimezoneView.m
//  NEP
//
//  Created by Gold Luo on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITimezoneView.h"

@implementation UITimezoneView

@synthesize textField;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
       
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setTimezonePicker{
    timeZoneDic = [NSMutableDictionary dictionary];
    
    NSArray *aryTimeZone = [NSTimeZone knownTimeZoneNames];
    for (NSString *strTimeZone in aryTimeZone) {
        NSArray *zoneComp = [strTimeZone componentsSeparatedByString:@"/"];
        NSString *strContinent = [zoneComp objectAtIndex:0];
        NSString *strRegion = @"";
        if ([zoneComp count] > 1) {
            strRegion = [zoneComp objectAtIndex:1];
        }
        NSMutableArray *regionsForCont = [timeZoneDic objectForKey:strContinent];
        if (regionsForCont == nil) {
            regionsForCont = [NSMutableArray array];
            [timeZoneDic setObject:regionsForCont forKey:strContinent];
        }
        [regionsForCont addObject:strRegion];
    }
    
    listFirst  = [[NSMutableArray alloc] initWithCapacity:10];
    listSecond = [[NSMutableArray alloc] initWithCapacity:10];
    
    [listFirst addObjectsFromArray:[self getTimezone]];
    [listSecond addObjectsFromArray:[self getRegion:[listFirst objectAtIndex:0]]];

}
-(IBAction)onDone:(id)sender
{
    [delegate closeTimezoneView];
    
    if (!iPad) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4f];
        
        [self removeFromSuperview];
        
        [UIView commitAnimations];
    }
}


-(NSMutableArray *) getRegion : (NSString* ) _region {
    return [timeZoneDic objectForKey:_region];
}

-(NSMutableArray *) getTimezone {
    return [[timeZoneDic allKeys] sortedArrayUsingSelector:@selector(localizedCompare:)];
}


#pragma mark --- Picker delegate 
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if (component == 0) {
        return [listFirst count];
    } else {
        return [listSecond count];
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return 120;
    } else {
        return 180;
    }
}

-(UIView *)pickerView:(UIPickerView *)zonepickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    static const int kReusableTag = 1;
    if (view.tag != kReusableTag) {
        CGRect frame = CGRectZero;
        frame.size = [zonepickerView rowSizeForComponent:component];
        frame = CGRectInset(frame, 4.0, 4.0);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        view = label;
        view.tag = kReusableTag;
        view.opaque = NO;
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = NO;
    }
    
    UILabel *textLabel = (UILabel*)view;
    if (component == 0) {
        textLabel.text = [listFirst objectAtIndex:row];
    } else {
        
        textLabel.text = [listSecond objectAtIndex:row];
    }    
    
	return view;
}

int nSelectFirst = 0;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        nSelectFirst = row;
        NSString *selectedFirst = [listFirst objectAtIndex:row];
        listSecond = nil;
        listSecond = [self getRegion: selectedFirst];
        
        [picker reloadComponent:1];
        
        NSString * displayRegion = @"";
        displayRegion = [listSecond objectAtIndex:0];
        [picker selectRow:0 inComponent:1 animated:YES];
        
        NSString* result = [NSString stringWithFormat:@"%@/%@", selectedFirst, displayRegion];
        
        self.textField.text = result;
    }
    else if (component == 1)
    {
        NSString* displayRegion = [listSecond objectAtIndex:row];

        NSString * selectedFirst = [listFirst objectAtIndex:nSelectFirst];
        
        NSString* result = [NSString stringWithFormat:@"%@/%@", selectedFirst, displayRegion];
        
        self.textField.text = result;
    }
}



@end
