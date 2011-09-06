/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestKloutServices {
/*
Copyright (c) 2011 Jesse Endo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

	static KloutServices testKlout;
	static List<String> testUsers = new String[] {'foo', 'bar'};
	static final String TEST_KEY = 'abcde12345';
	static final String TEST_ACTION_REPLACE = '?users=#users#&key=';
	static final String TEST_ACTION_NO_REPLACE = '?key=';
	
	static void setup()
	{
		testKlout = new KloutServices(TEST_KEY);
	}
	
    public static testmethod void test_createCommaSeparatedList()
    {
    	setup();
    	String testString = testKlout.createCommaSeparatedList(testUsers);
    	System.assertEquals('foo,bar', testString);
    }
    
    public static testmethod void test_constructURL_replace()
    {
    	setup();
    	String testURL = testKlout.constructURL(TEST_ACTION_REPLACE, testUsers);
    	System.assertEquals('http://api.klout.com/1/?users=foo,bar&key=abcde12345', testURL);
    }
    
    public static testmethod void test_constructURL_no_replace()
    {
    	setup();
    	String testURL = testKlout.constructURL(TEST_ACTION_NO_REPLACE, testUsers);
    	System.assertEquals('http://api.klout.com/1/?key=abcde12345', testURL);
    }
    
}