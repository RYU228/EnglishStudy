import 'dart:math';
import '../models/sentence_model.dart';

abstract class AIService {
  Future<List<SentenceModel>> generateSentences(String theme, int count);
}

class MockAIService implements AIService {
  final _random = Random();

  final Map<String, List<Map<String, String>>> _templates = {
    '일상': [
      {'korean': '오늘 하루 어떻게 보내셨나요?', 'english': 'How was your day today?'},
      {'korean': '내일은 날씨가 맑았으면 좋겠어요.', 'english': 'I hope the weather is clear tomorrow.'},
      {'korean': '시간 있을 때 주로 무엇을 하시나요?', 'english': 'What do you usually do in your free time?'},
      {'korean': '최근에 재미있는 영화를 봤어요.', 'english': 'I watched an interesting movie recently.'},
      {'korean': '커피 한 잔 마시면서 얘기해요.', 'english': 'Let\'s talk over a cup of coffee.'},
    ],
    '여행': [
      {'korean': '이 근처에 추천할 만한 관광지가 있나요?', 'english': 'Are there any tourist attractions you recommend near here?'},
      {'korean': '지하철 노선도는 어디서 얻을 수 있나요?', 'english': 'Where can I get a subway map?'},
      {'korean': '이곳은 입장료가 얼마인가요?', 'english': 'How much is the admission fee for this place?'},
      {'korean': '근처에 맛있는 로컬 음식을 파는 곳이 있나요?', 'english': 'Is there a place nearby that serves delicious local food?'},
    ],
    '비즈니스': [
      {'korean': '회의록을 작성해서 공유해 드리겠습니다.', 'english': 'I will write down the meeting minutes and share them with you.'},
      {'korean': '다음 단계를 위한 피드백을 부탁드립니다.', 'english': 'Please give us your feedback for the next steps.'},
      {'korean': '이 프로젝트의 우선순위는 무엇인가요?', 'english': 'What is the priority of this project?'},
      {'korean': '귀사와의 파트너십을 매우 중요하게 생각합니다.', 'english': 'We value our partnership with your company very much.'},
    ]
  };

  @override
  Future<List<SentenceModel>> generateSentences(String theme, int count) async {
    // Simulate network delay to mimic Gemini/OpenAI API latency
    await Future.delayed(const Duration(milliseconds: 1500));

    final normalizedTheme = theme.replaceAll(' 회화', '').trim();
    List<Map<String, String>> pool = _templates[normalizedTheme] ?? [];

    if (pool.isEmpty) {
      // Fallback pool for any other custom theme
      pool = [
        {'korean': '이것은 $theme에 대한 AI 생성 문장입니다.', 'english': 'This is an AI-generated sentence about $theme.'},
        {'korean': '$theme 학습을 통해 영어 실력을 키워보세요.', 'english': 'Improve your English skills through studying $theme.'},
        {'korean': '꾸준한 연습이 영어 회화 마스터의 지름길입니다.', 'english': 'Consistent practice is the shortcut to mastering English conversation.'},
        {'korean': '$theme 상황에서 유용하게 쓸 수 있는 표현입니다.', 'english': 'This is a useful expression in the context of $theme.'},
      ];
    }

    final List<SentenceModel> results = [];
    final int itemsToGenerate = min(count, 30); // limit to a reasonable count

    for (int i = 0; i < itemsToGenerate; i++) {
      // Choose template items (wrapping around if needed, adding index to keep unique if pool is small)
      final template = pool[i % pool.length];
      final suffixKo = i >= pool.length ? " (${i + 1})" : "";
      final suffixEn = i >= pool.length ? " (${i + 1})" : "";
      
      results.add(
        SentenceModel(
          korean: "${template['korean']}$suffixKo",
          english: "${template['english']}$suffixEn",
        ),
      );
    }

    // Shuffle slightly to feel organic
    results.shuffle(_random);
    return results;
  }
}
