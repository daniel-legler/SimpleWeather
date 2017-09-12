//
//  SimpleWeather_UITests.swift
//  SimpleWeather!UITests
//
//  Created by Daniel Legler on 9/11/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import XCTest

class SimpleWeatherUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSnapshots() {
        
        addUIInterruptionMonitor(withDescription: "Description") { (alert) -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        
        let app = XCUIApplication()
    
        let exists = NSPredicate(format: "exists == true")
        
        app.tap()
        app.tap()
        snapshot("01WeatherCollection")
        
        let weatherCell = app.collectionViews.cells.containing(.staticText, identifier:"San Francisco").element
        expectation(for: exists, evaluatedWith: weatherCell, handler: nil)
        waitForExpectations(timeout: 2.0, handler: nil)
        XCTAssert(weatherCell.exists)
        weatherCell.tap()
        
        snapshot("02WeatherDetail")
        
        app.navigationBars["SimpleWeather_.WeatherDetailVC"].buttons["Weather!"].tap()
        app.navigationBars["Weather!"].buttons["Add"].tap()
        app.searchFields["Search for a city"].typeText("London")
        snapshot("03WeatherSearch")
        
    }
    /*
     snapshot("01WeatherCollection")
     snapshot("02WeatherDetail")
     snapshot("03WeatherSearch")
     */
}
