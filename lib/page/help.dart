import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

@immutable
class QuestionData {
  final String question;
  final String answer;

  QuestionData(this.question, String answer) : answer = answer.replaceAll('\n', '\n\n');
  factory QuestionData.fromYaml(YamlMap map) => QuestionData(map['question'], map['answer']);
}

class HelpPage extends StatelessWidget {
  Future<List<QuestionData>> loadHelp() async {
    final yaml = await rootBundle.loadString('assets/help.yml');
    final YamlList questions = loadYaml(yaml);
    return questions.map((question) => QuestionData.fromYaml(question)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ajuda'),
        ),
        body: FutureBuilder<List<QuestionData>>(
          future: loadHelp(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: ExpansionPanelList.radio(
                  children: [
                    for (final question in snapshot.data)
                      ExpansionPanelRadio(
                        headerBuilder: (context, expanded) => ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: expanded ? 0 : 4 ),
                          title: Text(question.question),
                        ),
                        body: Padding(
                          padding: EdgeInsets.fromLTRB(12, 0, 24, 8),
                          child: Text(
                            question.answer,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        value: question.hashCode,
                      )
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
