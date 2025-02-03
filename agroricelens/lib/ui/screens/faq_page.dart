import 'package:flutter/material.dart';

import '../../constants.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<Map<String, String>> _faqData = [
    {
      "question": "What exactly is the issue with weedy rice?",
      "answer": "Weedy rice is a type of paddy that grows alongside cultivated paddy crops but differs significantly "
          "in characteristics. It has high growth competitiveness, matures earlier, and possesses a shattering trait "
          "that causes its grains to fall before harvesting. These fallen grains embed themselves in the soil, "
          "increasing the seed bank over successive seasons through dormancy. During the planting season, "
          "these dormant seeds germinate alongside sown seeds, particularly in direct seeding systems, "
          "leading to competition between weedy rice and the cultivated paddy.\n\nResearch has demonstrated that high "
          "populations of weedy rice compete with cultivated paddy for essential resources such as nutrients, water, "
          "and space. This competition can severely impact yields; for example, a 35% infestation of weedy rice may "
          "lead to a 50–60% yield loss, as reported by MARDI. Field surveys by the Selangor State Department of "
          "Agriculture in the PBLS area have revealed plots with infestation rates exceeding 30%, highlighting the "
          "severity of the problem in certain areas.\n\nVarious types and traits of weedy rice exist,"
          " with taller varieties typically dominating. In addition to yield reduction, severe infestations pose "
          "other challenges, such as increased risks of crop lodging and pest attacks. Since weedy rice lacks resistance "
          "and often acts as a host for pests, it further exacerbates the problem. "
          "Addressing these challenges is essential to ensure sustainable paddy cultivation and minimize losses in "
          "affected fields."
    },
    {
      "question": "Why has the issue of weedy rice become more widespread and serious recently?",
      "answer": "The increase in weedy rice infestation is due to several factors, including:\n\n1. Seed contamination via agricultural machinery movement, e"
          "specially harvesters, which transfer contaminated seeds from one area or plot to another. Farmers have limited "
          "control over preventing seed contamination, leading to a progressive increase in infestation across planting "
          "seasons.\n\n2. Direct seeding practices, where distinguishing between cultivated paddy and weedy rice during "
          "early growth stages is challenging. Manual removal becomes difficult, causing the seed bank of weedy rice to "
          "increase unchecked.\n\n3. Inadequate land preparation, such as uneven leveling during sowing, leaves dry patches "
          "where weedy rice seeds can germinate and compete with the main crop."
    },
    {
      "question": "What are the most effective methods to reduce and control this problem?",
      "answer": "Several methods have been employed to manage weedy rice infestations, "
          "including:\n\n1. Transplanting: Seedlings older than 11 days are transplanted using machinery, ensuring uniform "
          "growth and making tasks like thinning and weeding more effective. This reduces competition from weedy rice "
          "during the growth period.\n\n2. Broadcasting in flooded conditions: Treated seeds are sown in fields that are "
          "flooded from the beginning. Only treated seeds can germinate in anaerobic (submerged) conditions, "
          "preventing or reducing the germination of weeds and weedy rice. \n\n3. Land preparation: According to paddy "
          "planting guidelines, proper land preparation can minimize the seed bank and reduce the germination potential "
          "of weeds and weedy rice. Practices include burning straw immediately after harvesting and applying herbicides to "
          "kill volunteer paddy between the first and second plowing. Proper leveling is crucial for optimal seed growth.\n\n4. Removal of weedy rice: "
          "Harvesting should be carried out in stages during the planting period to ensure effective removal of weedy rice."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _faqData.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ExpansionTile(
              leading: Icon(Icons.question_answer, color: Constants.primaryColor),
              title: Text(
                _faqData[index]['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _faqData[index]['answer']!,
                    style: TextStyle(fontSize: 16, color: Constants.blackColor),
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
