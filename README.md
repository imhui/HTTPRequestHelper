HTTPRequestHelper
=================

Make it easy to use NSURLConnection to do get or post http request.


##sample:

	HTTPRequestHelper *client = [[HTTPRequestHelper alloc] initWithTarget:self
                                                             selector:@selector(dataDidReceived:)];
    [client get:@"http://www.google.com" params:[NSDictionary dictionary]];
    [client release];

	- (void)dataDidReceived:(id)data {
    	HTTPLOG(@"data: %@", data);
    }
