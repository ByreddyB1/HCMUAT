/******************************************************
 Author: Bhushan
 Description: Created as part Mock callout implementation for MiTreas test classes.
 ******************************************************/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private HttpResponse response;

    public MockHttpResponseGenerator(HttpResponse response) {
        this.response = response;
    }

    public HttpResponse respond(HttpRequest req) {
        return response;
    }
}