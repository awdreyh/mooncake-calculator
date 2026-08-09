import '../../../model/ingredient.dart';
final List<Map<String, dynamic>> recipesSeed = [

  {
    'id': '0ef4bca1-77e2-4fbb-914b-1f3d5d0538f8',
    'name': '经典广式月饼饼皮',
    'quantity': 8,
    'size': 100,
    'ratio': 0.4,
    'typeId': '7a91f6c1-4c5d-482e-a15a-7d9e7b3c0f89',
    'description': '经典广式月饼饼皮食谱，适合制作传统的广式月饼。',
    'ingredients': [
      { 'id': '3ad16c7d-16c1-4baf-8a83-7b4f5d3c2e01',  'name': '低筋面粉', 'amount': 162.0, 'unit': UnitType.g.name },
      { 'id': 'b6f8e2f4-6139-46c0-8b58-4d9f2c7e5d03',  'name': '糖浆', 'amount': 114.0, 'unit': UnitType.g.name },
      { 'id': 'd4e5f6a7-3b2c-4d1e-9f8a-1b2c3d4e5f60',  'name': '油', 'amount': 44.0, 'unit': UnitType.g.name },
      { 'id': 'f1a2b3c4-5d6e-7f89-0a1b-2c3d4e5f6078',  'name': '碱水', 'amount': 1.0, 'unit': UnitType.g.name }
    ],
    'isFavorite': false,
    'rating': 0,
    'url': null,
    'comment': null
  },
  {
    'id': '8e0e37f0-9aad-4758-8c7d-c88c9f8f5b85',
    'name': '经典冰皮月饼饼皮',
    'quantity': 8,
    'size': 100,
    'ratio': 0.4,
    'typeId': 'c1d2f9b4-5e6a-4d73-9998-8c3f6c7f3e5a',
    'description': '经典冰皮月饼饼皮食谱，适合制作传统的冰皮月饼。',
    'ingredients': [
      { 'id': 'eb4c35b7-a69f-4c3a-bd91-8f7d6e5c4b02',  'name': '糯米粉', 'amount': 41.0, 'unit': UnitType.g.name },
      { 'id': 'a19f2e3d-4c6b-48d2-9e1f-2a3b4c5d6e07',  'name': '澄粉', 'amount': 26.0, 'unit': UnitType.g.name },
      { 'id': 'c8f7e6d5-b4a3-4c2d-9e1f-0a1b2c3d4e05',  'name': '粘米粉', 'amount': 34.0, 'unit': UnitType.g.name },
      { 'id': 'f2d1c3b4-a5e6-4d7c-9f8a-0b1c2d3e4f06',  'name': '牛奶', 'amount': 172.0, 'unit': UnitType.g.name },
      { 'id': 'b3c4d5e6-f7a8-4b9c-8d0e-1f2a3b4c5d07',  'name': '植物油', 'amount': 25.0, 'unit': UnitType.g.name }
    ],
    'isFavorite': false,
    'rating': 0,
    'url': null,
    'comment': null
  },
  {
    'id': 'd67aebee-2aad-4ef3-8c3f-9b43f8a1b7e4',
    'name': '经典红豆沙馅料',
    'quantity': 8,
    'size': 100,
    'ratio': 0.4,
    'typeId': 'f7a5d8b9-2c1f-4f3d-a8bd-2a4e7d5c9e1f',
    'description': '经典豆沙馅食谱，适合制作传统的广式月饼。',
    'ingredients': [
      { 'id': 'c5f4e3d2-b1a0-4f9d-8e7c-6a5b4c3d2e01',  'name': '红豆（干）', 'amount': 168.0, 'unit': UnitType.g.name },
      { 'id': 'd7e6f5a4-b3c2-4d1e-9f8a-0b1c2d3e4f02',  'name': '转化糖浆', 'amount': 33.0, 'unit': UnitType.g.name },
      { 'id': 'e8f7a6b5-c4d3-4e2f-9a0b-1c2d3e4f5a03',  'name': '糖', 'amount': 33.0, 'unit': UnitType.g.name },
      { 'id': 'f9a8b7c6-d5e4-4f3a-9b0c-1d2e3f4a5b04',  'name': '植物油', 'amount': 33.0, 'unit': UnitType.g.name }
    ],
    'isFavorite': false,
    'rating': 0,
    'url': null,
    'comment': null
  },
  {
    'id': '3d4f1c7e-5b9c-4692-ab39-6d2e7f4a1b6c',
    'name': '经典五仁馅料',
    'quantity': 8,
    'size': 100,
    'ratio': 0.4,
    'typeId': 'a6d5f8c9-3b2c-4e1a-b9f7-6d8e4c7b5f3a',
    'description': '经典五仁馅食谱，适合制作传统的广式月饼。',
    'ingredients': [
      { 'id': '41a3b5c7-d8e9-4f2a-b3c1-2d4e5f6a7b08',  'name': '红豆（干）', 'amount': 168.0, 'unit': UnitType.g.name },
      { 'id': '52b4c6d8-e9f0-4a1b-c2d3-4e5f6a7b8c09',  'name': '转化糖浆', 'amount': 33.0, 'unit': UnitType.g.name },
      { 'id': '63c5d7e9-f0a1-4b2c-d3e4-5f6a7b8c9d01',  'name': '糖', 'amount': 33.0, 'unit': UnitType.g.name },
      { 'id': '74d6e8f0-a1b2-4c3d-e4f5-6a7b8c9d0e12',  'name': '植物油', 'amount': 33.0, 'unit': UnitType.g.name }
    ],
    'isFavorite': false,
    'rating': 0,
    'url': null,
    'comment': null
  }
];
