package com.parasoft.demo.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class HomePage extends BasePage {

    @FindBy(xpath = "/descendant::span[normalize-space(.)='Backpacks']")
    private WebElement backpacksLink;

    public HomePage(WebDriver driver) {
        super(driver);
    }

    public CategoryPage goToBackpacks() {
        click(backpacksLink);
        return new CategoryPage(driver);
    }
}
