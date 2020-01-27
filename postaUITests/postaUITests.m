//
//  postaUITests.m
//  postaUITests
//
//  Created by Bosko Petreski on 6/4/18.
//  Copyright © 2018 Bosko Petreski. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface postaUITests : XCTestCase

@end

@implementation postaUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExampleAPI {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"RB027053174LA"]/*[[".cells.staticTexts[@\"RB027053174LA\"]",".staticTexts[@\"RB027053174LA\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app.alerts[@"Info"].buttons[@"OK"] tap];
    
}
- (void)testExample {
    
    XCUIApplication *app = XCUIApplication.new;
    [app.navigationBars[@"Title"].buttons[@"Add"] tap];
    
    XCUIElement *addAlert = app.alerts[@"Add"];
    XCUIElementQuery *collectionViewsQuery = addAlert.collectionViews;
    XCUIElement *trackingTextField = collectionViewsQuery.textFields[@"tracking"];
    [trackingTextField tap];
    [trackingTextField tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIElement *detailsTextField = collectionViewsQuery.textFields[@"details"];
    [detailsTextField tap];
    [trackingTextField tap];
    [trackingTextField tap];
    
    XCUIElement *tKey = app/*@START_MENU_TOKEN@*/.keys[@"t"]/*[[".keyboards.keys[@\"t\"]",".keys[@\"t\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [tKey tap];
    
    XCUIApplication *app2 = app;
    [app2/*@START_MENU_TOKEN@*/.keys[@"r"]/*[[".keyboards.keys[@\"r\"]",".keys[@\"r\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *aKey = app2/*@START_MENU_TOKEN@*/.keys[@"a"]/*[[".keyboards.keys[@\"a\"]",".keys[@\"a\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [aKey tap];
    [aKey tap];
    [app2/*@START_MENU_TOKEN@*/.keys[@"c"]/*[[".keyboards.keys[@\"c\"]",".keys[@\"c\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *kKey = app2/*@START_MENU_TOKEN@*/.keys[@"k"]/*[[".keyboards.keys[@\"k\"]",".keys[@\"k\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [kKey tap];
    [app2/*@START_MENU_TOKEN@*/.keys[@"i"]/*[[".keyboards.keys[@\"i\"]",".keys[@\"i\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *nKey = app2/*@START_MENU_TOKEN@*/.keys[@"n"]/*[[".keyboards.keys[@\"n\"]",".keys[@\"n\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [nKey tap];
    [nKey tap];
    [detailsTextField tap];
    [tKey tap];
    [app2/*@START_MENU_TOKEN@*/.keys[@"w"]/*[[".keyboards.keys[@\"w\"]",".keys[@\"w\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElement *sKey = app2/*@START_MENU_TOKEN@*/.keys[@"s"]/*[[".keyboards.keys[@\"s\"]",".keys[@\"s\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [sKey tap];
    [tKey tap];
    [tKey tap];
    [trackingTextField tap];
    [tKey tap];
    [app2/*@START_MENU_TOKEN@*/.keys[@"e"]/*[[".keyboards.keys[@\"e\"]",".keys[@\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [sKey tap];
    [tKey tap];
    [tKey tap];
    [detailsTextField tap];
    [app2/*@START_MENU_TOKEN@*/.keys[@"f"]/*[[".keyboards.keys[@\"f\"]",".keys[@\"f\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [kKey tap];
    [kKey tap];
    [addAlert.buttons[@"OK"] tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationFaceUp;
    
    
}

@end
