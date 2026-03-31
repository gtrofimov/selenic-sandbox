package com.parasoft.demo.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.Select;

import java.util.List;

public class ApprovalsPage extends BasePage {

    public ApprovalsPage(WebDriver driver) {
        super(driver);
    }

    public String openFirstOpenOrderOrFirstListed() {
        List<WebElement> openOrderLinks = driver.findElements(
                By.xpath("//tr[td[2][normalize-space()='Open']]/td[3]//a"));

        WebElement target;
        if (!openOrderLinks.isEmpty()) {
            target = wait.until(ExpectedConditions.elementToBeClickable(openOrderLinks.get(0)));
        } else {
            target = wait.until(ExpectedConditions.elementToBeClickable(
                    By.xpath("//tr[td[3]//a]/td[3]//a")));
        }

        String orderNumber = target.getText().trim();
        target.click();
        return orderNumber;
    }

    public ApprovalsPage approveCurrentOrder(String comment) {
        Select responseSelect = new Select(wait.until(
                ExpectedConditions.visibilityOfElementLocated(By.id("response_select"))));
        responseSelect.selectByVisibleText("Approve");

        WebElement comments = wait.until(ExpectedConditions.visibilityOfElementLocated(By.id("comments_content")));
        comments.clear();
        comments.sendKeys(comment);

        wait.until(ExpectedConditions.elementToBeClickable(By.id("save_btn"))).click();
        return this;
    }

    public String getStatusForOrder(String orderNumber) {
        By statusCell = By.xpath("//tr[td[3]//a[normalize-space()='" + orderNumber
                + "']]/td[2]");
        return wait.until(ExpectedConditions.visibilityOfElementLocated(statusCell)).getText().trim();
    }
}