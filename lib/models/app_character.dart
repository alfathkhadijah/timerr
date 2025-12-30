import 'package:flutter/material.dart';

class AppCharacter {
  final String id;
  final String name;
  final String icon; // Emoji or Icon name
  final Color effectColor;
  final int cost;

  AppCharacter({
    required this.id,
    required this.name,
    required this.icon,
    required this.effectColor,
    required this.cost,
  });

  static List<AppCharacter> allCharacters = [
    AppCharacter(
      id: 'tomato',
      name: 'Happy Tomato',
      icon: '🍅',
      effectColor: Colors.redAccent,
      cost: 0,
    ),
    AppCharacter(
      id: 'cat',
      name: 'Sleepy Cat',
      icon: '🐱',
      effectColor: Colors.orangeAccent,
      cost: 150,
    ),
    AppCharacter(
      id: 'panda',
      name: 'Panda Focus',
      icon: '🐼',
      effectColor: Colors.grey,
      cost: 250,
    ),
    AppCharacter(
      id: 'robot',
      name: 'Studious Bot',
      icon: '🤖',
      effectColor: Colors.blueAccent,
      cost: 400,
    ),
    AppCharacter(
      id: 'coffee',
      name: 'Coffee Boost',
      icon: '☕',
      effectColor: Colors.brown,
      cost: 300,
    ),
    AppCharacter(
      id: 'rocket',
      name: 'Focus Rocket',
      icon: '🚀',
      effectColor: Colors.deepPurpleAccent,
      cost: 500,
    ),
    AppCharacter(
      id: 'mochi',
      name: 'Sweet Mochi',
      icon: '🍡',
      effectColor: Colors.pinkAccent,
      cost: 180,
    ),
    AppCharacter(
      id: 'teddy',
      name: 'Teddy Bear',
      icon: '🧸',
      effectColor: Colors.brown,
      cost: 220,
    ),
    AppCharacter(
      id: 'flower',
      name: 'Cherry Blossom',
      icon: '🌸',
      effectColor: Colors.pink,
      cost: 150,
    ),
    AppCharacter(
      id: 'puffin',
      name: 'Chilly Puffin',
      icon: '🐧',
      effectColor: Colors.lightBlueAccent,
      cost: 350,
    ),
    AppCharacter(
      id: 'unicorn',
      name: 'Magic Unicorn',
      icon: '🦄',
      effectColor: Colors.purpleAccent,
      cost: 600,
    ),
  ];
}
