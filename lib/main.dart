import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [Tab(child: Text("Holy Quran")), Tab(child: Text("Hadees"))],
          unselectedLabelColor: Colors.blueGrey,
          labelColor: const Color.fromARGB(255, 28, 133, 31),
          indicatorColor: Colors.greenAccent,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        body: TabBarView(children: [HolyQuran(), HadithsBookIndex()]),
      ),
    );
  }
}

class HolyQuran extends StatefulWidget {
  const HolyQuran({super.key});

  @override
  State<HolyQuran> createState() => _HolyQuranState();
}

class _HolyQuranState extends State<HolyQuran> {
  Map mapresp = {};
  List listresp = [];
  Future apicallkrdu() async {
    http.Response response = await http.get(
      Uri.parse("https://api.alquran.cloud/v1/surah"),
    );

    if (response.statusCode == 200) {
      setState(() {
        mapresp = jsonDecode(response.body);
        listresp = mapresp["data"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    apicallkrdu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: listresp.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailSurah(listresp[index]["number"]),
                ),
              );
            },
            leading: CircleAvatar(
              child: Text(
                listresp[index]["number"].toString(),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.greenAccent,
            ),
            title: Text(
              listresp[index]["name"] + " | " + listresp[index]["englishName"],
              style: TextStyle(color: const Color.fromARGB(255, 28, 133, 31)),

              textAlign: TextAlign.left,
            ),
            subtitle: Text(
              listresp[index]["englishNameTranslation"],
              textAlign: TextAlign.left,
            ),
            trailing: Text(
              listresp[index]["numberOfAyahs"].toString(),
              textAlign: TextAlign.left,
            ),
          );
        },
      ),
    );
  }
}

class DetailSurah extends StatefulWidget {
  var surahnum;
  DetailSurah(this.surahnum, {super.key});

  @override
  State<DetailSurah> createState() => _DetailSurahState();
}

class _DetailSurahState extends State<DetailSurah> {
  Map mapresp = {};
  Map maprespUrdu = {};
  List listresp = [];
  List list = [];

  Future apicallkrdu() async {
    var surahNumber = widget.surahnum;
    http.Response response = await http.get(
      Uri.parse("https://api.alquran.cloud/v1/surah/${surahNumber}"),
    );

    if (response.statusCode == 200) {
      setState(() {
        mapresp = jsonDecode(response.body);
        listresp = mapresp["data"]["ayahs"];
      });
    }
  }

  Future apiurduTranslation() async {
    var surahNumber = widget.surahnum;
    http.Response response = await http.get(
      Uri.parse("https://api.alquran.cloud/v1/surah/${surahNumber}/ur.maududi"),
    );

    if (response.statusCode == 200) {
      setState(() {
        maprespUrdu = jsonDecode(response.body);
        list = maprespUrdu["data"]["ayahs"];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apicallkrdu();
    apiurduTranslation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          listresp.isNotEmpty
              ? ListView.builder(
                itemCount: listresp.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            listresp[index]["text"],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiriQuran(),
                          ),

                          Text(
                            list[index]["text"],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoNastaliqUrdu(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : Center(child: CircularProgressIndicator()),
    );
  }
}

class HadithsBookIndex extends StatefulWidget {
  const HadithsBookIndex({super.key});

  @override
  State<HadithsBookIndex> createState() => _HadithsBookIndexState();
}

class _HadithsBookIndexState extends State<HadithsBookIndex> {
  Map mapbooks = {};
  List listbooks = [];
  Future apibooks() async {
    http.Response response = await http.get(
      Uri.parse(
        "https://hadithapi.com/api/books?apiKey=\$2y\$10\$BylaBcXs5Lw7ZOtYmQ3PXO1x15zpp26oc1FeGktdmF6YeYoRd88e",
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        mapbooks = jsonDecode(response.body);
        listbooks = mapbooks["books"];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apibooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: listbooks.length,
        itemBuilder: (context, index) {
          var hbook = listbooks[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChaptersScreen(hbook["bookSlug"]),
                ),
              );
            },
            leading: CircleAvatar(child: Text("${index + 1}")),
            title: Text(
              hbook["bookName"],
              style: TextStyle(color: const Color.fromARGB(255, 28, 133, 31)),
            ),
            subtitle: Text(hbook["writerName"]),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Chapters " + hbook["chapters_count"],
                  style: TextStyle(
                    color: const Color.fromARGB(255, 28, 133, 31),
                  ),
                ),
                Text(
                  "Hadith " + hbook["hadiths_count"],
                  style: TextStyle(
                    color: const Color.fromARGB(255, 28, 133, 31),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChaptersScreen extends StatefulWidget {
  var bookSlugChahye;
  ChaptersScreen(this.bookSlugChahye, {super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  Map mapChapters = {};
  List listChapters = [];
  Future apiChapters() async {
    http.Response response = await http.get(
      Uri.parse(
        "https://hadithapi.com/api/${widget.bookSlugChahye}/chapters?apiKey=\$2y\$10\$BylaBcXs5Lw7ZOtYmQ3PXO1x15zpp26oc1FeGktdmF6YeYoRd88e",
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        mapChapters = jsonDecode(response.body);
        listChapters = mapChapters["chapters"];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: listChapters.length,
        itemBuilder: (context, index) {
          var hbook = listChapters[index];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          HadithSCR(hbook["bookSlug"], hbook["chapterNumber"]),
                ),
              );
            },
            leading: CircleAvatar(
              child: Text(
                hbook["chapterNumber"],
                style: TextStyle(color: const Color.fromARGB(255, 38, 101, 40)),
              ),
              backgroundColor: Colors.greenAccent,
            ),
            title: Text(
              hbook["chapterArabic"],
              textAlign: TextAlign.left,
              style: GoogleFonts.amiriQuran(),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hbook["chapterUrdu"],
                  textAlign: TextAlign.left,
                  style: GoogleFonts.notoNastaliqUrdu(),
                ),
                Text(hbook["chapterEnglish"], textAlign: TextAlign.start),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HadithSCR extends StatefulWidget {
  var book;
  var chapterNumber;
  HadithSCR(this.book, this.chapterNumber, {super.key});

  @override
  State<HadithSCR> createState() => _HadithSCRState();
}

class _HadithSCRState extends State<HadithSCR> {
  Map mapHadiths = {};
  List listHadiths = [];
  Future apiHadiths() async {
    http.Response response = await http.get(
      Uri.parse(
        "https://hadithapi.com/public/api/hadiths?apiKey=\$2y\$10\$BylaBcXs5Lw7ZOtYmQ3PXO1x15zpp26oc1FeGktdmF6YeYoRd88e&book=${widget.book}&chapter=${widget.chapterNumber}&paginate=100000",
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        mapHadiths = jsonDecode(response.body);
        listHadiths = mapHadiths["hadiths"]["data"];
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiHadiths();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: listHadiths.length,
        itemBuilder: (context, index) {
          var hbook = listHadiths[index];
          return Center(
            child: Card(
              child: ListTile(
                title: Column(
                  children: [
                    CircleAvatar(
                      child: Text(
                        hbook["hadithNumber"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 38, 101, 40),
                        ),
                      ),
                      backgroundColor: Colors.greenAccent,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.greenAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            hbook["hadithArabic"],
                            textAlign: TextAlign.right,
                            style: GoogleFonts.amiriQuran(
                              color: const Color.fromARGB(255, 38, 101, 40),
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      hbook["hadithUrdu"],
                      textAlign: TextAlign.right,
                      style: GoogleFonts.notoNastaliqUrdu(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
