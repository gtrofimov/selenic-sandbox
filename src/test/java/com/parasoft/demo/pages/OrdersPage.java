package com.parasoft.demo.pages;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class OrdersPage extends BasePage {

    @FindBy(xpath = "//table/tbody/tr[2]/td[1]/span")
    private WebElement secondOrderStatusSpan;

    public OrdersPage(WebDriver driver) {
        super(driver);
    }

    public String getSecondOrderStatus() {
        return wait.until(ExpectedConditions.visibilityOf(secondOrderStatusSpan)).getText();
    }
}
