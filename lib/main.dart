import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kumap/data/kuma.dart';
import 'package:kumap/marker/jig_marker.dart';
import 'package:kumap/marker/ku_marker.dart';
import 'package:kumap/provider/kuma_list_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: MaterialApp(
        title: '鯖江くまっぷ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const KumapPage(),
      ),
    );
  }
}

class KumapPage extends ConsumerWidget {
  const KumapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kumaList = switch (ref.watch(kumaListProvider)) {
      AsyncData(:final value) => value,
      _ => <Kuma>[],
    };

    return Scaffold(
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: JigMarker.pos,
          initialZoom: 14,
          minZoom: 9,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://cyberjapandata.gsi.go.jp/xyz/seamlessphoto/{z}/{x}/{y}.jpg',
          ),
          MarkerLayer(
            markers: [
              JigMarker(),
              ...kumaList.map(KuMarker.new),
            ],
          ),
          CircleLayer(
            circles: [
              JigCircleMarker(),
              ...kumaList.map(KuCircleMarker.new),
            ],
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                '国土地理院',
                onTap: () => launchUrlString(
                    'https://maps.gsi.go.jp/development/ichiran.html'),
              ),
              const TextSourceAttribution('Landsat8画像（GSI,TSIC,GEO Grid/AIST）'),
              const TextSourceAttribution(
                  'Landsat8画像（courtesy of the U.S. Geological Survey）'),
              const TextSourceAttribution('海底地形（GEBCO）'),
              TextSourceAttribution(
                'クマ出没情報 – めがねのまちさばえ 鯖江市',
                onTap: () => launchUrlString(
                    'https://www.city.sabae.fukui.jp/anzen_anshin/chojuhigaitaisaku/kuma-taisaku/kumasyutubotu/index.html'),
              ),
              TextSourceAttribution(
                'くまアイコン – ICOOON MONO',
                onTap: () => launchUrlString('https://icooon-mono.com/'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
