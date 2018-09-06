/*
	subtitle search for addic7ed.com (English ONLY!)
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
// Insert your addic7ed.com credentials(wikisubtitlesuser,wikisubtitlespass) below (you can get them from the browser cookies after you login)!
string Header = "Referer: http://www.addic7ed.com/ \n Cookie: wikisubtitlesuser=xxxxxx; wikisubtitlespass=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;"; 
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
	string ret = HostUrlGetString(API_URL);
	return "200 OK";
}
string version1 ;
string hi;
array<dictionary> SubtitleSearch(string MovieFileName, dictionary MovieMetaData)
{
	array<dictionary> ret;
	string hash = GetHash(MovieFileName);
	string title = string(MovieMetaData["title"]);
	string country = string(MovieMetaData["country"]);
	string year = string(MovieMetaData["year"]);
	string seasonNumber = string(MovieMetaData["seasonNumber"]);
	string episodeNumber = string(MovieMetaData["episodeNumber"]);
	string url = "http://www.addic7ed.com/serie/" + title + "/" + seasonNumber + "/" + episodeNumber + "/1";
	string text = HostUrlGetString(url, UserAgent,Header,"",cookie);
	array<string> lines = text.split("\n");
	for (int i = 0, len = lines.size(); i < len; i++)
	{
		string line = lines[i];
		if (!line.empty())
		{
			int s = line.find("buttonDownload");
			int s1 = line.find("/original");
			if (s > 0 && s1 >0)
			{
				string linev = lines[i-21];
				string linev1 = lines[i+6];
				string linev2 = lines[i+5];
				int v = linev.find("Version ");
				string version = linev.substr(v + 8);
				string version1 = version.substr(0,version.find(","));
				hi="";
				if  ( linev1.find("Hearing Impaired") > 0 || linev2.find("Hearing Impaired") > 0 )
				{
					hi=".HI";
				}
				string id = line.substr(s1);
				string id1 = id.substr(0,id.find("\""));
				dictionary item;
				item["id"] = id1;
				item["title"] = title + ".S0" + seasonNumber + ".E0" + episodeNumber + "." + version1 + hi;
				item["lang"] = "en";
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
	return HostUrlGetString(url,UserAgent,Header,"",cookie);
}


