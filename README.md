HTTPRequestHelper
=================

Make it easy to use NSURLConnection to do get or post http request.


##sample:

###GET
	NSDictionary *params = [NSDictionary dictionary];
	HTTPRequestHelper *client = [[HTTPRequestHelper alloc] initWithTarget:self
                                                             selector:@selector(dataDidReceived:)];
    [client get:@"http://www.google.com" params:params];
    [client release];

	- (void)dataDidReceived:(id)data {
    	HTTPLOG(@"data: %@", data);
    }
    
###POST        
    
    HTTPRequestHelper *client = [[HTTPRequestHelper alloc] initWithTarget:self
                                                             selector:@selector(dataDidReceived:)];
    [client post:@"http://www.google.com" params:params];
    
    
    [client release];
    
###POST(upload file)
    HTTPRequestHelper *client = [[HTTPRequestHelper alloc] initWithTarget:self
                                                             selector:@selector(dataDidReceived:)];
    [client post:@"http://www.google.com" params:params data:[NSData data] dataKey:@"data_key"];
    
    
    [client release];
    

