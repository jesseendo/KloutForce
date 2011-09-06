public class KloutServices {
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

/**
 * KloutServices is a wrapper class around the Klout (www.klout.com) Web Services API.
 * Documentation of the API is available from developer.klout.com.  Registration for, or
 * availability of, an API key from Mashery/Klout is required to use this class.  The author
 * is not affiliated with Klout in any way.
 * 
 * KloutServices includes a public inner class called KloutUser.  This class
 * is populated with the information returned by web calls to the Klout API.
 * Currently, only the User method (developer.klout.com/iodocs) is implemented.
 * 
 * Usage:
 * You must pass your API key when instantiating a new instance of KloutServices
 * <code>KloutServices klout = new KloutServices('xxxxxxxxxxxxxx');</code>
 *
 * To just get a Klout score based on a Twitter handle:
 * <code>Decimal score = klout.getKlout('jesseendo');</code>
 *
 * To get an entire User Profile returned, as a KloutUser object:
 * <code> KloutUser me = klout.getUserProfile('jesseendo');</code> 
 *
 * To get a List of User Profiles, as a List of KloutUser objects:
 * <code> List<KloutUser> us = klout.getUserProfiles(String[] {'jesseendo', 'benioff');</code>
 *
 * @author Jesse Endo (Twitter: @jesseendo)
 * @version 0.1
 */
    private String API_KEY;
    String ENDPOINT = 'http://api.klout.com/1/';
    String USER_URL = 'users/show.xml?users=#users#&key=';
    
    /**
     * Constructor
     */
    public KloutServices( String key )
    {
        this.API_KEY = key;
    }
    
    /**
     * Setters
     */
    public void setKey( String key )
    {
        this.API_KEY = key;
    }
    
    /**
     * Just get Klout score for a single User
     */
    public Decimal getKlout( String handle )
    {
        return getUserProfile( handle ).klout;
    }
    
    /**
     * Get all Profile details for a single User
     */
    public KloutUser getUserProfile( String handle )
    {
        List<KloutUser> users = getUserProfiles( new String[] {handle} );
        return users[0];
    }
    
    /**
     * Get Profile details for a List of Users
     */
    public List<KloutUser> getUserProfiles( List<String> handles )
    {   
        return makeRequest( USER_URL, handles );
    }
    
    
    /**
     * Private inner method to construct URL strings
     */
    private String constructURL( String action, List<String> users )
    {
        // Leave extensible to incorporate future API calls
        String url = ENDPOINT + action + API_KEY;
        url = url.replace( '#users#', createCommaSeparatedList( users ) );
        
        return url;
    }
    
    private String createCommaSeparatedList( List<String> users )
    {
        String listing = '';
        Iterator<String> i = users.iterator();
        
        while(i.hasNext())
        {
            listing += i.next();
            if(i.hasNext())
                listing += ',';
        }
        return listing;
    }
    
    
    private List<KloutUser> makeRequest( String actionURL, List<String> handles )
    {
        String url = constructURL( actionURL, handles );
        HttpResponse response = makeHTTPRequest( url );
        
        DOM.Document doc = response.getBodyDocument();
        
        List<KloutUser> userObjects = new List<KloutUser>();
        for(Dom.XMLNode user : doc.getRootElement().getChildElements()) {
            KloutUser userObject = new KloutUser(user);
            userObjects.add( userObject );
        }
        
        return userObjects;
    }
    
    
    /**
     * Convenience wrapper around HTTP calls
     */
    private HTTPResponse makeHTTPRequest( String endpoint )
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint( endpoint );
        request.setMethod( 'GET' );
        
        return http.send( request );
    }
    
    
    /**
     * Inner User Class
     */
    public class KloutUser
    {
        /**
         * Inner Map for storing information about this User
         */
        private Map<String, String> params = new Map<String, String>();
        
        /**
         * Convenience method for getting Twitter handle
         */
        public String twitter_handle {
            get { return params.get( 'twitter_screen_name' ); }
        }
        
        /**
         * Convenience method for getting Klout score
         */
        public Decimal klout {
            get { return Decimal.valueOf( params.get( 'kscore' ) ); }
        }
        
        /**
         * Accessor to internal Map for getting any attribute
         */
        public String get( String attribute )
        {
            if(params.containsKey(attribute))
                return params.get(attribute);
            else
                return null;
        }
        
        /**
         * Return all attributes stored for this object
         */
        public Set<String> listAttributes()
        {
            return params.keySet();
        }
        
        /**
         * Constructor
         */
        KloutUser(DOM.XMLNode node)
        {
            nodeToParam(node);
        }
        
        /**
         * Recursively build params map
         */
        private void nodeToParam( DOM.XMLNode node )
        {
            if( !node.getChildElements().isEmpty())
            {
                for( DOM.XMLNode child : node.getChildElements() )
                    nodeToParam( child );
            }
            else
                params.put( node.getName(), node.getText() );
        }
    }
}