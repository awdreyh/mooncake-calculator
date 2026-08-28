class SeedsStrings {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'cantonese_dough': 'Cantonese Dough',
      'snow_skin_dough': 'Snow Skin Dough',
      'sushi_dough': 'Sushi Dough',
      'red_bean_filling': 'Red Bean filling',
      'lotus_seed_filling': 'Lotus Seed filling',
      'five_nuts': 'Five Nuts',
      'recipe_cantonese_dough': 'Classic Cantonese Dough Recipe',
      'recipe_cantonese_dough_description':
          'A classic recipe for Cantonese dough, perfect for making traditional Cantonese mooncakes.',
      'recipe_snow_skin_dough': 'Classic Snow Skin Dough Recipe',
      'recipe_red_bean_filling': 'ClassicRed Bean filling Recipe',
      'recipe_lotus_seed_filling': 'Classic Lotus Seed filling Recipe',
      'recipe_five_nuts': 'Five Nuts Recipe',
      'recipe_snow_skin_dough_description':
          'A classic recipe for snow skin dough, perfect for making traditional snow skin mooncakes.',
      'recipe_red_bean_filling_description':
          'A classic recipe for red bean filling, perfect for making traditional Cantonese mooncakes.',
      'recipe_lotus_seed_filling_description':
          'A classic recipe for lotus seed filling, perfect for making traditional Cantonese mooncakes.',
      'recipe_five_nuts_description':
          'A classic recipe for five nuts filling, perfect for making traditional Cantonese mooncakes.',
      'flour': 'Flour',
      'vegetable_oil': 'Vegetable Oil',
      'invert_syrup': 'Inverted Syrup',
      'lye_water': 'Lye Water',
      'sugar': 'Sugar',
      'glutinous_rice_flour': 'Glutinous Rice Flour',
      'gluten_free_flour': 'Gluten Free Flour',
      'rice_flour': 'Rice Flour',
      'milk': 'Milk',
      'red_bean_dry': 'Red Bean Dry',
      'lotus_seed_dry': 'Lotus Seed Dry',
      'mixed_nuts': ' Mixed Nuts',
      'dry_fruits': ' Dry Fruits',
      'cooked_flour': ' Cooked Flour',
    },
    'zh': {
      'cantonese_dough': '广式月饼',
      'snow_skin_dough': '冰皮月饼',
      'sushi_dough': '苏式月饼',
      'red_bean_filling': '红豆沙',
      'lotus_seed_filling': '莲蓉',
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
      'flour': '面粉',
      'vegetable_oil': '植物油',
      'invert_syrup': '转化糖浆',
      'lye_water': '枧水',
      'sugar': '糖',
      'glutinous_rice_flour': '糯米粉',
      'gluten_free_flour': '澄粉',
      'rice_flour': '粘米粉',
      'milk': '牛奶',
      'red_bean_dry': '红豆(干)',
      'lotus_seed_dry': '莲子(干)',
      'mixed_nuts': '五仁',
      'dry_fruits': '干果',
      'cooked_flour': '熟面粉',
    },
  };

  static String get(String key, String languageCode) {
    return translations[languageCode]?[key] ?? translations['en']?[key] ?? key;
  }
}
