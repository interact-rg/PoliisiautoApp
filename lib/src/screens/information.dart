/*
 * Copyright (c) 2022, Miika Sikala, Essi Passoja, Lauri Klemettilä
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

import '../common.dart';
import '../widgets/drawer.dart';

List<Widget> buildCreditWidgets() {
  Text normText(String t) => Text(t, textAlign: TextAlign.center);
  Text boldText(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
  return [
    const SizedBox(height: 0),
    boldText('Software project -kurssi, syksy 2023'),
    normText('Atte Viertola (projektimanageri)'),
    normText('Severi Pitkänen'),
    normText('Aarni Ylitalo'),
    const SizedBox(height: 0),
    boldText('Software project -kurssi, kevät 2023'),
    normText('Muhammad Nabeel Ali (projektimanageri)'),
    normText('Santeri Yritys'),
    normText('Li Lan'),
    normText('Hamza Javed'),
    normText('Alberto Esquivias'),
    const SizedBox(height: 10),
    boldText('Software project -kurssi, syksy 2022'),
    normText('Miika Sikala (projektimanageri)'),
    normText('Lauri Klemettilä'),
    normText('Essi Passoja'),
    const SizedBox(height: 10),
    boldText('Oulu International School (OIS) ja Jäälin koulu, 2022'),
    normText('OIS 3-4 luokka, opettaja Heidi Tuomela'),
    normText('OIS 7A- ja 7B-luokat, opettaja Pooja Kakkar'),
    normText('Jääli 1-4 luokka, opettajat Sanna Alalauri ja Mari Perätalo'),
    const SizedBox(height: 10),
    boldText('Thesis worker, 2021 - 2022'),
    normText('Moilanen Tapio (konseptivideot)'),
    const SizedBox(height: 10),
    boldText('Research and Development Project -kurssiryhmä, kevät 2021'),
    normText('Pesonen Atte (projektimanageri)'),
    normText('Ansamaa Matti'),
    normText('Bui Le Ba Vuong'),
    normText('Salmelin Silja'),
    normText('Kärkäs Petteri'),
    const SizedBox(height: 10),
    boldText(
        'Jäälin koulu, Kaakkurin koulu ja Oulu International School (OIS), 2021'),
    normText('Jääli 6 luokka, opettaja Eveliina Jurvelin'),
    normText('Kaakkuri 6 luokka, opettaja Antti Arffman'),
    normText('OIS 2-3 luokka, opettaja Heidi Tuomela'),
  ];
}

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.aboutApp)),
      drawer: const PoliisiautoDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: InformationContent(),
              ),
            ),
          ),
        ),
      ));
}

class InformationContent extends StatefulWidget {
  const InformationContent({super.key});

  @override
  State<InformationContent> createState() => _InformationContentState();
}

class _InformationContentState extends State<InformationContent> {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Image.asset(
              'assets/logo-text-2x.png',
              width: 140,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.infoText,
            textAlign: TextAlign.center,
          ),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.thanks,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          ...buildCreditWidgets()
        ],
      );
}
