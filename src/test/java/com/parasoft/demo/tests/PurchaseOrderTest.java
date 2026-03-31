package com.parasoft.demo.tests;

import com.parasoft.demo.pages.CategoryPage;
import com.parasoft.demo.pages.HomePage;
import com.parasoft.demo.pages.LoginPage;
import com.parasoft.demo.pages.OrderWizardPage;
import com.parasoft.demo.pages.OrdersPage;
import com.parasoft.demo.pages.ApprovalsPage;
import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import java.util.Map;
import org.testng.Assert;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

/**
 * Requirement: PGT-13
 * Recorded: 2026-02-10
 *
 * Flow:
 *   1. Log in as purchaser
 *   2. Navigate to Backpacks category, filter by Riverwalk Traveler Gear location
 *   3. Add first item to cart and confirm
 *   4. Open cart and proceed to order submission wizard
 *   5. Select store location, enter position ID, fetch location
 *   6. Fill in invoice assignment (campaign ID + number)
 *   7. Go to review and submit for approval
 *   8. Verify the order status is "Processed"
 */
public class PurchaseOrderTest {

    private static final String BASE_URL = "http://localhost:4040";

    private WebDriver driver;

    @BeforeMethod
    public void setUp() {
        WebDriverManager.chromedriver().setup();
        ChromeOptions options = new ChromeOptions();
        // Uncomment the next line to run headless:
        // options.addArguments("--headless=new");
        options.addArguments("--password-store=basic");
        options.setExperimentalOption("prefs", Map.of(
            "credentials_enable_service", false,
            "profile.password_manager_enabled", false,
            "profile.password_manager_leak_detection", false
        ));
        driver = new ChromeDriver(options);
        driver.manage().window().maximize();
    }

    @Test(priority = 1, description = "PGT-13: Purchaser adds a backpack to cart and submits order for approval")
    public void testPurchaserSubmitsBackpackOrder() {
        // Step 1: Log in
        driver.get(BASE_URL + "/loginPage");
        HomePage homePage = new LoginPage(driver).login("purchaser", "password");

        // Step 2: Navigate to Backpacks and filter by Riverwalk Traveler Gear
        CategoryPage categoryPage = homePage.goToBackpacks()
                .filterByRiverwalkLocation();

        // Step 3: Add first item to cart and confirm
        categoryPage.addFirstItemToCart();

        // Step 4: Open cart and proceed to submission
        OrderWizardPage orderWizardPage = categoryPage.openCart()
                .proceedToSubmission();

        // Step 5: Select store location and resolve position
        orderWizardPage
                .selectStoreLocation("Riverwalk Traveler Gear")
                .enterPositionId("bob")
                .clickGetLocation();

        // Step 6: Fill in invoice assignment
        orderWizardPage
                .clickInvoiceAssignment()
                .enterCampaignId("1234")
                .enterCampaignNumber("5678");

        // Step 7: Review and submit
        OrdersPage ordersPage = orderWizardPage
                .clickGoToReview()
                .submitForApproval();

        // Step 8: Verify order status
        String orderStatus = ordersPage.getSecondOrderStatus();
        Assert.assertEquals(orderStatus, "Processed", "Order status should be 'Processed'");
    }

    @Test(priority = 2, dependsOnMethods = "testPurchaserSubmitsBackpackOrder",
            description = "PGT-APPROVER: Approver approves first open order (JSON-based flow)")
    public void testApproverApprovesOpenOrderFromJsonFlow() {
        // Steps from localhost-2026-03-31-12-43-42-approver.json
        driver.get(BASE_URL + "/loginPage");
        ApprovalsPage approvalsPage = new LoginPage(driver).loginToApprovals("approver", "password");
        String orderNumber = approvalsPage.openFirstOpenOrderOrFirstListed();
        approvalsPage.approveCurrentOrder("Approved via Selenium MCP approver JSON flow.");

        // Verify the same order is now Approved.
        String status = approvalsPage.getStatusForOrder(orderNumber);
        Assert.assertEquals(status, "Approved", "Order " + orderNumber + " should be Approved");
    }

    @AfterMethod
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
