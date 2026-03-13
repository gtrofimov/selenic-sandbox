package com.parasoft.demo.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class CategoryPage extends BasePage {

    @FindBy(id = "LOCATION_2")
    private WebElement riverwalkLocationCheckbox;

    @FindBy(xpath = "/descendant::button[normalize-space(.)='ADD TO CART'][1]")
    private WebElement firstAddToCartButton;

    @FindBy(css = "#confirm_button > .retract_format")
    private WebElement confirmAddToCartButton;

    @FindBy(css = "#cart-button .button-img")
    private WebElement cartButton;

    @FindBy(xpath = "/descendant::button[normalize-space(.)='PROCEED TO SUBMISSION']")
    private WebElement proceedToSubmissionButton;

    public CategoryPage(WebDriver driver) {
        super(driver);
    }

    public CategoryPage filterByRiverwalkLocation() {
        click(riverwalkLocationCheckbox);
        return this;
    }

    public CategoryPage addFirstItemToCart() {
        click(firstAddToCartButton);
        click(confirmAddToCartButton);
        return this;
    }

    public CategoryPage openCart() {
        click(cartButton);
        return this;
    }

    public OrderWizardPage proceedToSubmission() {
        click(proceedToSubmissionButton);
        return new OrderWizardPage(driver);
    }
}
