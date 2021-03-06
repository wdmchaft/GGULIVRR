Copyright 2012 Philippe Possemiers - Artesis University College
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Abstract

GGULIVRR is a Generic Game for Ubiquitous Learning in Interacting Virtual and Real Realities. It aims to provide an open-source framework so that learning games can easily be constructed for iOS and Android platforms without requiring special (except HTML) technical skills.

GGULIVRR uses several open-source techniques. To minimise content development time, the app uses a generic system to eliminate the need for designing several user interfaces. Also, to enhance the responsiveness and robustness of the game system, a caching system is used to make sure that the absence of an internet connection does not hinder the game.

The game system consists of two components :

* Web-service and master database that contains all information for the game (user accounts, multimedia files, tag information, scores, rules, ...).

* Mobile client and local database. This client replicates the master database information, presents the game UI and multimedia files and interprets the game rules.

For the first component and for the local client database, we have chosen Apache CouchDB (http://couchdb.apache.org/). This new database application is a noSQL, scheme-less, document-oriented database that exposes all operations through a RESTful web-service. The format of the records is JSON. The database also has strong support for replication and last but not least can be run on iOS as well as Android.

By using CouchDB, we get following important advantages :

* Through the replication features, we can transparently sync the latest game information from the cloud with the CouchDB instance on the mobile device. Once the information is synced, the game can be played without an internet connection since everything now resides in the database instance on the mobile device. Network latencies are eliminated since all information comes from the local database.

* All values posted by the user can be aggregated into a JSON document and replicated to the master database once an internet connection is available. 

* There is no need to write a separate web-service layer, since CouchDB has a built-in web service API.

For the second component, we have developed a framework in iOS and Android that uses HTML as mark-up language for the user interface. In iOS there is a UI component called UIWebView, while Android has WebView. Both components act like a full-fledged browser with support for all mime types and even a built-in Javascript engine. This way, plain HTML can transparently function as the UI. In the database, the HTML snippets are stored inside JSON documents together with their attachments. These attachments can be anything a browser understands (pictures, sounds, movie clips, animated gifs, etc...).

The use of HTML has following advantages:

* Interface design only has to be done once for all platforms.

* The game designer does not have to know anything about special UI features on iOS or Android.

* The game designer does not have to have special technical skills, UI development can be done in a simple HTML editor.

* Other platforms can be supported in the future.

* Through the use of HTML forms, the application posts everything to the REST API of the local CouchDB instance. This way, generic JSON documents can be generated with all the values that the user has filled in.

* Style sheets can change the look and feel and even the behaviour of the UI quickly and efficiently.

The mobile client makes use of QR codes to steer actions. The name of the JSON document to process at that location is stored in the QR code. When the client reads the code, the HTML and attachments are retrieved from the JSON document and shown in the UI of the mobile device. We are using the open-source ZBar library, available on iOS and Android for reading the QR codes.

# Quickstart

Important! This code does not work in the simulator. You need to test it on a real device.

1. Download the code, fill in your developer credentials and compile.
2. Start the app and fill in a username. Any user name will do, as it is postfixed with a unique value.
3. Fill in 'berlin' as the database. This syncs with a database on http:// 3mobile.iriscouch.com/berlin. You can examine the structure and contents of the database by going to http://3mobile.iriscouch.com/_utils/ with username 'jack' and password 'jack'. The database contains the questions (item1, item2, item3), a stylesheet and some user data.
4. Browse to a QR generator and make three QR codes, containing the text 'item1', 'item2' and 'item3'. The QR codes for three items are also included in the project under 'resources'.
5. Scan the codes and fill in some values for the questions. You will see the aggregated answers appearing in a document under your user name postfixed with the current time in milliseconds ( to avoid username conflicts ).

## Structure of the database

The questions in the database must all be named 'item', followed by a number ( no space ). They must contain a field, called 'body' in which you store the HTML.

Example of a question : 

```<html>
<head>
	<link rel='stylesheet' href='stylesheet.css'>
</head>
<body>
	<h1>Question 1</h1><br /><img src='$db/reichstag.jpg' />
	<br /><br /><form action='self'>What building is shown here?<br /><br />
	<input type='text' name='reichstag' class='ui-input-text' /> 
	<input type='submit' value='Answer' class='ui-btn'></form>
</body></html>
```

The names of the input fields are used to gather the answers of the users in key / value pairs into a JSON document that bears the name of the user. This name is postfixed with the current time in milliseconds. Each answer that is submitted, creates a new revision of this document and is completed with the geographical position of the user at the time of submission.

Attachments must be added to the document and be referred to as '$db/attachment'. All valid HTML file types are supported. Links to websites can be embedded and will allow to link to external ( not cached in the local database ) sites. Whenever a link is clicked, the 'back' button is also enabled so we can go back to the questions.

Stylesheet support is provided with the tag <link rel='stylesheet' href='stylesheet.css'> . Of course, the database must contain a document, called 'stylesheet' ( exactly the same in lowercase ) and the stylesheet entries must reside in the 'body' field.

The background which is shown between the questions is implemented by am HTML file called 'background'. Here you can add text, pictures or a watermark just as you would in a webpage.


