import UIKit
import Material

class AppFABMenuController: FABMenuController {
    fileprivate let fabMenuSize = CGSize(width: 56, height: 56)
    fileprivate let bottomInset: CGFloat = 24
    fileprivate let rightInset: CGFloat = 24
    
    fileprivate var fabButton: FABButton!
    fileprivate var addCityFABMenuItem: FABMenuItem!
    fileprivate var editCitiesFABMenuItem: FABMenuItem!
    
    open override func prepare() {
        super.prepare()
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        
        prepareFABButton()
        prepareAddCityFABMenuItem()
        prepareRemindersFABMenuItem()
        prepareFABMenu()
    }
}

extension AppFABMenuController {
    fileprivate func prepareFABButton() {
        fabButton = FABButton(image: Icon.cm.add, tintColor: Theme.primaryNow())
        fabButton.pulseColor = Theme.primaryNow()
        fabButton.backgroundColor = Color.white
    }
    
    fileprivate func prepareAddCityFABMenuItem() {
        addCityFABMenuItem = FABMenuItem()
        addCityFABMenuItem.title = "Add City"
        addCityFABMenuItem.titleLabel.font = UIFont(name: "Avenir", size: 17)!
        addCityFABMenuItem.fabButton.image = Icon.cm.add
        addCityFABMenuItem.fabButton.tintColor = .white
        addCityFABMenuItem.fabButton.pulseColor = .white
        addCityFABMenuItem.fabButton.backgroundColor = Theme.primaryNow()
        addCityFABMenuItem.fabButton.addTarget(self, action: #selector(handleAddCityFABmenuItem(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareRemindersFABMenuItem() {
        editCitiesFABMenuItem = FABMenuItem()
        editCitiesFABMenuItem.title = "Edit"
        editCitiesFABMenuItem.titleLabel.font = UIFont(name: "Avenir", size: 17)!
        editCitiesFABMenuItem.fabButton.image = Icon.cm.edit
        editCitiesFABMenuItem.fabButton.tintColor = .white
        editCitiesFABMenuItem.fabButton.pulseColor = .white
        editCitiesFABMenuItem.fabButton.backgroundColor = Theme.secondaryNow()
        editCitiesFABMenuItem.fabButton.addTarget(self, action: #selector(handleEditCitiesFABMenuItem(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareFABMenu() {
        fabMenu.fabButton = fabButton
        fabMenu.fabMenuItems = [addCityFABMenuItem, editCitiesFABMenuItem]
        fabMenuBackingBlurEffectStyle = .prominent
        fabMenuBacking = .blur
        fabMenu.fabButton?.shadowColor = .black
        fabMenu.fabButton?.shadowRadius = 4.0
        
        view.layout(fabMenu)
            .size(fabMenuSize)
            .bottom(bottomInset)
            .right(rightInset)
    }
}

extension AppFABMenuController {
    @objc
    fileprivate func handleAddCityFABmenuItem(button: UIButton) {

        fabMenu.fabButton?.animate(.rotate(0))

        guard let rootVC = self.rootViewController as? SWNavigationController,
              let weatherVC = rootVC.topViewController as? WeatherCollectionVC else { return }
        
        weatherVC.addCityButtonPressed()
        fabMenu.close()
        fabMenu.isHidden = true
    }
    
    @objc
    fileprivate func handleEditCitiesFABMenuItem(button: UIButton) {
        
        fabMenu.fabButton?.animate(.rotate(0))

        guard let rootVC = self.rootViewController as? SWNavigationController,
            let weatherVC = rootVC.topViewController as? WeatherCollectionVC else { return }
        
        weatherVC.editButton()
        fabMenu.close()
        fabMenu.isHidden = true
        
    }
}

extension AppFABMenuController {
    @objc
    open func fabMenuWillOpen(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(45))

    }
    
    @objc
    open func fabMenuWillClose(fabMenu: FABMenu) {
        fabMenu.fabButton?.animate(.rotate(0))
        
    }
    
    @objc
    open func fabMenu(fabMenu: FABMenu, tappedAt point: CGPoint, isOutside: Bool) {
        print("fabMenuTappedAtPointIsOutside", point, isOutside)
        
        guard isOutside else {
            return
        }
        
    }
}
