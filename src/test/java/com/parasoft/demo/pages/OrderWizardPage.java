package com.parasoft.demo.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;

public class OrderWizardPage extends BasePage {

    @FindBy(name = "selectedArea")
    private WebElement storeAreaSelect;

    @FindBy(name = "positionId")
    private WebElement positionIdField;

    @FindBy(xpath = "/descendant::button[normalize-space(.)='GET LOCATION']")
    private WebElement getLocationButton;

    @FindBy(xpath = "/descendant::button[normalize-space(.)='INVOICE ASSIGNMENT']")
    private WebElement invoiceAssignmentButton;

    @FindBy(id = "campaign_id")
    private WebElement campaignIdField;

    @FindBy(id = "campaign_number")
    private WebElement campaignNumberField;

    @FindBy(xpath = "/descendant::button[normalize-space(.)='GO TO REVIEW']")
    private WebElement goToReviewButton;

    @FindBy(xpath = "/descendant::button[normalize-space(.)='SUBMIT FOR APPROVAL']")
    private WebElement submitForApprovalButton;

    @FindBy(className = "button-img")
    private WebElement cartImageButton;

    public OrderWizardPage(WebDriver driver) {
        super(driver);
    }

    public OrderWizardPage selectStoreLocation(String visibleText) {
        wait.until(ExpectedConditions.visibilityOf(storeAreaSelect));
        new Select(storeAreaSelect).selectByVisibleText(visibleText);
        return this;
    }

    public OrderWizardPage enterPositionId(String positionId) {
        type(positionIdField, positionId);
        return this;
    }

    public OrderWizardPage clickGetLocation() {
        click(getLocationButton);
        return this;
    }

    public OrderWizardPage clickInvoiceAssignment() {
        click(invoiceAssignmentButton);
        return this;
    }

    public OrderWizardPage enterCampaignId(String campaignId) {
        type(campaignIdField, campaignId);
        return this;
    }

    public OrderWizardPage enterCampaignNumber(String campaignNumber) {
        type(campaignNumberField, campaignNumber);
        return this;
    }

    public OrderWizardPage clickGoToReview() {
        click(goToReviewButton);
        return this;
    }

    public OrdersPage submitForApproval() {
        click(submitForApprovalButton);
        click(cartImageButton);
        return new OrdersPage(driver);
    }
}
