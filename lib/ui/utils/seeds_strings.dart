class SeedsStrings {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'cantonese_dough': 'Cantonese Dough',
      'snow_skin_dough': 'Snow Skin Dough', 
      'sushi_dough': 'Sushi Dough',
      'red_bean_paste': 'Red Bean Paste',
      'lotus_seed_paste': 'Lotus Seed Paste',
      'five_nuts': 'Five Nuts',
      'recipe_cantonese_dough': 'Classic Cantonese Dough Recipe',
      'recipe_cantonese_dough_description': 'A classic recipe for Cantonese dough, perfect for making traditional Cantonese mooncakes.',
      'recipe_snow_skin_dough': 'Classic Snow Skin Dough Recipe',
      'recipe_red_bean_filling': 'ClassicRed Bean Paste Recipe',
      'recipe_lotus_seed_filling': 'Classic Lotus Seed Paste Recipe',
      'recipe_five_nuts': 'Five Nuts Recipe',
      'recipe_snow_skin_dough_description': 'A classic recipe for snow skin dough, perfect for making traditional snow skin mooncakes.',
      'recipe_red_bean_filling_description': 'A classic recipe for red bean paste, perfect for making traditional Cantonese mooncakes.',
      'recipe_lotus_seed_filling_description': 'A classic recipe for lotus seed paste, perfect for making traditional Cantonese mooncakes.',
      'recipe_five_nuts_description': 'A classic recipe for five nuts filling, perfect for making traditional Cantonese mooncakes.',
    },
    'zh':{
      'cantonese_dough': '广式月饼',
      'snow_skin_dough': '冰皮月饼', 
      'sushi_dough': '苏式月饼',
      'red_bean_paste': '红豆沙',
      'lotus_seed_paste': '莲蓉',
      'five_nuts': '五仁',
      'recipe_cantonese_dough': '经典广式月饼饼皮食谱',
      'recipe_cantonese_dough_description': '经典广式月饼饼皮食谱，适合制作传统的广式月饼。',
      'recipe_snow_skin_dough': '经典冰皮月饼饼皮食谱',
      'recipe_red_bean_filling': '经典红豆沙馅食谱',
      'recipe_lotus_seed_filling': '经典莲蓉馅食谱',
      'recipe_five_nuts': '经典五仁馅食谱',
      'recipe_snow_skin_dough_description': '经典冰皮月饼饼皮食谱，适合制作传统的冰皮月饼。',
      'recipe_red_bean_filling_description': '经典豆沙馅食谱，适合制作传统的广式月饼。',
      'recipe_lotus_seed_filling_description': '经典莲蓉馅食谱，适合制作传统的广式月饼。',
      'recipe_five_nuts_description': '经典五仁馅食谱，适合制作传统的广式月饼。', 
    }
  };

  static String get(String key, String languageCode) {
    return translations[languageCode]?[key] ?? translations['en']?[key] ?? key;
  }
}