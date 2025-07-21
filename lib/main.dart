import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class RadioStation {
  final String name;
  final String url;
  final String country;
  final String language;
  final String category;

  RadioStation({
    required this.name,
    required this.url,
    required this.country,
    required this.language,
    required this.category,
  });
}

class MyApp extends StatelessWidget {
  final List<RadioStation> stations = [
    // 📰 News
    RadioStation(
      name: "France Info",
      url: "http://direct.franceinfo.fr/live/franceinfo-midfi.mp3",
      country: "France",
      language: "Français",
      category: "News",
    ),
    RadioStation(
      name: "BBC World Service",
      url: "http://stream.live.vc.bbcmedia.co.uk/bbc_world_service",
      country: "UK",
      language: "Anglais",
      category: "News",
    ),
    RadioStation(
      name: "RFI Monde",
      url: "https://live02.rfi.fr/rfimonde-96k.mp3",
      country: "France",
      language: "Français",
      category: "News",
    ),
    RadioStation(
      name: "Sky News Arabia",
      url: "https://liveaudio.skynewsarabia.com/skynewsarabia.aac",
      country: "Émirats",
      language: "Arabe",
      category: "News",
    ),

    // 🕌 Islamiyat
    RadioStation(
      name: "Quran Radio Saudi",
      url: "https://stream.radiojar.com/0tpy1vc5u6duv",
      country: "Arabie Saoudite",
      language: "Arabe",
      category: "Islamiyat",
    ),
    RadioStation(
      name: "Quran Karim FM",
      url: "http://stream.radiojar.com/8s5u5tpdtwzuv",
      country: "Maroc",
      language: "Arabe",
      category: "Islamiyat",
    ),
    RadioStation(
      name: "إذاعة السنة",
      url: "http://andromeda.shoutca.st:8189/autodj",
      country: "Global",
      language: "Arabe",
      category: "Islamiyat",
    ),
    RadioStation(
      name: "Makkah Live",
      url: "https://hls.makkahtv.tv/live/hls/maqtv_sd/index.m3u8",
      country: "Arabie Saoudite",
      language: "Arabe",
      category: "Islamiyat",
    ),
    RadioStation(
      name: "Madina Live",
      url: "https://hls.madinahtv.tv/live/hls/mntv_sd/index.m3u8",
      country: "Arabie Saoudite",
      language: "Arabe",
      category: "Islamiyat",
    ),

    // 📖 Story / Documentary
    RadioStation(
      name: "France Culture",
      url: "https://icecast.radiofrance.fr/franceculture-midfi.mp3",
      country: "France",
      language: "Français",
      category: "Story",
    ),
    RadioStation(
      name: "BBC Radio 4 Extra",
      url: "http://stream.live.vc.bbcmedia.co.uk/bbc_radio_four_extra",
      country: "UK",
      language: "Anglais",
      category: "Story",
    ),
    RadioStation(
      name: "NPR Storytelling",
      url: "https://npr-ice.streamguys1.com/live.mp3",
      country: "USA",
      language: "Anglais",
      category: "Story",
    ),
    RadioStation(
      name: "Radio Quran Stories",
      url: "https://stream.radiojar.com/w9n32a2rf9duv",
      country: "Global",
      language: "Arabe",
      category: "Story",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.deepPurple.shade700),
      ),
      home: RadioHome(stations: stations),
    );
  }
}

class RadioHome extends StatefulWidget {
  final List<RadioStation> stations;

  const RadioHome({Key? key, required this.stations}) : super(key: key);

  @override
  _RadioHomeState createState() => _RadioHomeState();
}

class _RadioHomeState extends State<RadioHome> {
  final player = AudioPlayer();
  RadioStation? currentStation;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  String selectedCountry = "All";
  bool isPlaying = false;
  bool isLoading = false; // Added loading state
  DateTime? lastAdTime; // Track the last time an ad was shown

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadInterstitialAd();
    player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        isLoading = state.processingState == ProcessingState.buffering;
        if (state.processingState == ProcessingState.completed) {
          player.stop();
          currentStation = null;
        }
      });
    });
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (_, __) => setState(() => _isAdLoaded = false),
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  Future<void> _playRadio(RadioStation station) async {
    try {
      setState(() => isLoading = true);
      await player.setUrl(station.url);
      await player.play();
      setState(() {
        currentStation = station;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur de lecture : $e")));
    }
  }

  void _playRadioWithAd(RadioStation station) {
    final now = DateTime.now();
    if (lastAdTime != null && now.difference(lastAdTime!).inSeconds < 60) {
      // Skip ad if less than 60 seconds since the last ad
      _playRadio(station);
      return;
    }

    if (_interstitialAd != null) {
      if (isPlaying) {
        player.pause(); // Pause playback during the ad
      }

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          setState(() => currentStation = station); // Update UI immediately
          _playRadio(station);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          setState(() => currentStation = station); // Update UI immediately
          _playRadio(station);
        },
      );

      try {
        if (_interstitialAd != null) {
          _interstitialAd!.show();
          lastAdTime = now; // Update the last ad time
        } else {
          throw Exception("Ad is not loaded or has been disposed.");
        }
      } catch (e) {
        debugPrint("Erreur en affichant la pub : $e");
        setState(() => currentStation = station); // Update UI immediately
        _playRadio(station);
      }
    } else {
      setState(() => currentStation = station); // Update UI immediately
      _playRadio(station);
      _loadInterstitialAd();
    }
  }

  void _stopRadio() {
    player.stop();
    setState(() => currentStation = null);
  }

  List<String> getCountries() {
    return [
      "All",
      ...{for (var s in widget.stations) s.country},
    ];
  }

  @override
  void dispose() {
    player.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStations = selectedCountry == "All"
        ? widget.stations
        : widget.stations.where((s) => s.country == selectedCountry).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("🌍 Radio Mondiale"),
        actions: [
          DropdownButton<String>(
            value: selectedCountry,
            dropdownColor: Colors.grey[900],
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: Container(),
            onChanged: (value) =>
                setState(() => selectedCountry = value ?? "All"),
            items: getCountries()
                .map(
                  (country) =>
                      DropdownMenuItem(value: country, child: Text(country)),
                )
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredStations.length,
              itemBuilder: (context, index) {
                final station = filteredStations[index];
                final isCurrent = station == currentStation;
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: isCurrent
                      ? Colors.deepPurple.shade300
                      : Colors.grey.shade900,
                  child: ListTile(
                    leading: Icon(Icons.radio),
                    title: Text(station.name),
                    subtitle: Text("${station.country} | ${station.language}"),
                    trailing: isCurrent
                        ? IconButton(
                            icon: Icon(Icons.stop, color: Colors.red),
                            onPressed: _stopRadio,
                          )
                        : IconButton(
                            icon: Icon(Icons.play_arrow, color: Colors.white),
                            onPressed: () => _playRadioWithAd(station),
                          ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (currentStation != null)
            Container(
              color: Colors.deepPurple.shade800,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentStation!.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentStation!.category,
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () => isPlaying ? player.pause() : player.play(),
                  ),
                ],
              ),
            ),
          if (_isAdLoaded && _bannerAd != null)
            SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
