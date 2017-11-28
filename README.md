# AppteleUpdateService
Helper Class for Apptele.com Adhoc iOS Application update service

How to use this class with Apptele.com adhoc app update service?

1. Sign up at https://apptele.com, Create an application project to get an App Key & Secret.
2. Clone this project and Include AppteleUpdateService helper class in your application.
3. In AppteleUpdateService helper class please change the App Key and Secret got during step 1.
4. In your application add the following two lines where you want to check for update.

	AppteleUpdateService *updateService = [AppteleUpdateService sharedInstance];
	[updateService checkAndUpdate];

5. In case there is a new version user of your application will be prompted to install the update.
6. To release an update just upload the application with new version @ https://apptele.com
