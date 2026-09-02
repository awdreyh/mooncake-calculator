
import '../../../model/type.dart';
final List<Map<String, dynamic>> typesSeed = [  

  {
    'id': '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
    'category': Category.dough.name,
    'name': 'cantonese_dough',
    'image_path': 'assets/images/types/cantonese.jpg'
  },
  {
    'id': 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
    'category': Category.dough.name,
    'name': 'snow_skin_dough',
    'image_path': 'assets/images/types/snowSkin.jpg',
  },
  {
    'id': 'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g',
    'category': Category.dough.name,
    'name': 'sushi_dough',
    'image_path': 'assets/images/types/sushi.jpg'
  },
  {
    'id': 'f7a5d8b9-2c1f-4f3d-a8bd-2a4e7d5c9e1f',
    'category': Category.filling.name,
    'name': 'red_bean_filling',
    'image_path': 'assets/images/types/redBean.jpg',
    'matched_dough_type_ids': [
      '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
      'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
      'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g'
    ]
  },
  {
    'id': 'b3c4d5e6-7f8g-9h0i-1j2k-3l4m5n6o7p8q',
    'category': Category.filling.name,
    'name': 'lotus_seed_filling',
    'image_path': 'assets/images/types/lotusSeed.jpg',
    'matched_dough_type_ids': [
      '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
      'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
      'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g'
    ]
  },
  {
    'id': 'a6d5f8c9-3b2c-4e1a-b9f7-6d8e4c7b5f3a',
    'category': Category.filling.name,
    'name': 'five_nuts',
    'image_path': 'assets/images/types/fiveNuts.jpg',
    'matched_dough_type_ids': [
      '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
      'd2e3f4a5-6b7c-8d9e-0f1a-2b3c4d5e6f7g'
    ]
  }
];