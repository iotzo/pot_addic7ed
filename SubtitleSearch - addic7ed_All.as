/*
	subtitle search for addic7ed.com (All Languages!)
*/
 
//	string GetTitle() 													-> get title for UI
//	string GetVersion													-> get version for manage
//	string GetDesc()													-> get detail information
//	string GetLoginTitle()												-> get title for login dialog
//	string GetLoginDesc()												-> get desc for login dialog
//	string ServerCheck(string User, string Pass) 						-> server check
//	string ServerLogin(string User, string Pass) 						-> login
//	void ServerLogout() 												-> logout
//	string GetLanguages()																-> get support language
//	string SubtitleWebSearch(string MovieFileName, dictionary MovieMetaData)			-> search subtitle bu web browser
//	array<dictionary> SubtitleSearch(string MovieFileName, dictionary MovieMetaData)	-> search subtitle
//	string SubtitleDownload(string id)													-> download subtitle
//	string GetUploadFormat()															-> upload format
//	string SubtitleUpload(string MovieFileName, dictionary MovieMetaData, string SubtitleName, string SubtitleContent)	-> upload subtitle

bool cookie = true;
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:61.0) Gecko/20100101 Firefox/61.0";
string Username="";
string Password="";
uint64 GetHash(string FileName)
{
	int64 size = 0;
	uint64 hash = 0;
	uint64 fp = HostFileOpen(FileName);

	if (fp != 0)
	{
		size = HostFileLength(fp);
		hash = size;
		
		for (int i = 0; i < 65536 / 8; i++) hash = hash + HostFileReadQWORD(fp);
		
		int64 ep = size - 65536;
		if (ep < 0) ep = 0;
		HostFileSeek(fp, ep, 0);
		for (int i = 0; i < 65536 / 8; i++) hash = hash + HostFileReadQWORD(fp);
		
		HostFileClose(fp);
	}
	
	return hash;
}

string API_URL = "http://www.addic7ed.com";

string GetTitle()
{
	return "Addic7ed.com";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return API_URL;
}

string GetLanguages()
{
	return "en";
}

string ServerCheck(string User, string Pass)
{
//	string ret = HostUrlGetString(API_URL);

	return "200 OK";
}


string ServerLogin(string User, string Pass)
{
	Username=User;
	Password=Pass;
	uint64 http = HostOpenHTTP("http://www.addic7ed.com/dologin.php", UserAgent,"Host: www.addic7ed.com\r\nAccept: */*\r\nContent-Length: 45\r\nContent-Type: application/x-www-form-urlencoded", "username="+Username+"&password="+Password+"&remember=true");
	string headers1 = HostGetHeaderHTTP(http);
	
	int stat = HostGetStatusHTTP(http);
		
	HostCloseHTTP(http);
	


	return "OK";

}





array<dictionary> SubtitleSearch(string MovieFileName, dictionary MovieMetaData)
{
	array<dictionary> ret;
	string hash = GetHash(MovieFileName);
	string title = string(MovieMetaData["title"]);
	string country = string(MovieMetaData["country"]);
	string year = string(MovieMetaData["year"]);
	string seasonNumber = string(MovieMetaData["seasonNumber"]);
	string episodeNumber = string(MovieMetaData["episodeNumber"]);
	string url = "http://www.addic7ed.com/serie/" + title + "/" + seasonNumber + "/" + episodeNumber + "/0";
	string text = HostUrlGetString(url, UserAgent);
	array<string> lines = text.split("\n");
	string id;
	string lang;
	string status;
	string ver;
	int verpos;


	if (text.empty())
	{
				//check for "'"'s in the title :)
			string DbTitle;
			string text1 = HostUrlGetString(API_URL, UserAgent);
			string text2 = text1.substr(text1.find("select name=\"qsShow\""),text1.find("id=\"qsSeason\"")-text1.find("select name=\"qsShow\""));
			array<string> lines1 = text2.split("option value=");
			for (int i = 0, len = lines1.size(); i < len; i++)
			{
				DbTitle = lines1[i].substr(lines1[i].find(">")+1,lines1[i].find("<")-lines1[i].find(">")-1);
				int num = DbTitle.find("'");
				DbTitle.replace("'","");
				if (DbTitle == title)
				{
					title.insert(num,"'");
					url = "http://www.addic7ed.com/serie/" + title + "/" + seasonNumber + "/" + episodeNumber + "/0";
					text = HostUrlGetString(url, UserAgent);
					lines = text.split("\n");
					break;
				}
			}
		
	}



	for (int i = 0, len = lines.size(); i < len; i++)
	{
		string line = lines[i];
		string hi;
		if (!line.empty())
		{
			int s = line.find("buttonDownload");
			int s1 = line.find("/original");
			int s2 = line.find("/updated");
			if (s > 0 && ( s1 >0 || s2 > 0) )
			{
				status = lines[i-4].substr(lines[i-4].find("<b>")+3);
				if ( status != "Completed" ) continue ;
				lang = lines[i-6].substr(36,lines[i-6].find("<a")-36);
				string linev2 = lines[i+5];
				
				for ( int j = i; j> i-40; j-- )
				{
					verpos = lines[j].find("Version ") +8;
					if ( verpos > 8 ) 
					{
						ver = lines[j].substr(verpos,lines[j].find(",")-verpos);
						break;
					}
				}
				
				for (int j = i; j< i+20; j++)
				{
				if ( lines[j].find("Hearing Impaired") > 0 )
					{
						hi=".HI";
						break;
					}
				}
				

				
				if (s1 > 0) id = line.substr(s1);
				if (s2 > 0) id = line.substr(s2);
				string id1 = id.substr(0,id.find("\""));
				dictionary item;
				item["id"] = id1;
				item["title"] = title + ".S0" + seasonNumber + ".E0" + episodeNumber + "." + ver + hi;
				item["language"] = lang;
				item["format"] = "srt";
				ret.insertLast(item);
			}
			
		}
	}
	
	return ret;
}
 
string SubtitleDownload(string id)
{
	string url = "http://www.addic7ed.com" + id;
	return HostUrlGetString(url,UserAgent);
}


