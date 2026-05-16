# FarmTok API Testing Guide

This document explains how to test all APIs and functionality in the FarmTok app to ensure everything works as intended.

## Overview

The FarmTok app includes comprehensive testing functionality accessible through the API Test Screen. This allows you to verify that all services, APIs, and functionality are working correctly.

## Accessing API Tests

1. Launch the FarmTok app
2. Sign in or navigate to the home screen
3. Tap the bug report icon (🪲) in the top-right corner of the app bar
4. This opens the API Test Screen

## Services Tested

### 1. Environment Variables

- **Purpose**: Verify that all required API keys and configuration are loaded
- **Tests**: Checks for SUPABASE_URL, SUPABASE_ANON_KEY, GROQ_API_KEY, OPENWEATHERMAP_API_KEY
- **Expected**: All keys should be configured for full functionality

### 2. Supabase Service

- **Purpose**: Test database connectivity and authentication
- **Tests**: Service initialization and basic database connection
- **Expected**: Should connect successfully if Supabase is configured

### 3. Local Cache Service

- **Purpose**: Verify local data storage using Hive
- **Tests**: Save and retrieve test data from local cache
- **Expected**: Should successfully store and retrieve data locally

### 4. Weather Service

- **Purpose**: Test OpenWeatherMap API integration
- **Tests**: Current weather, 7-day forecast, and smart alerts
- **Expected**: Should return weather data for test coordinates (Nairobi, Kenya)

### 5. AI Service
- **Purpose**: Test multi-provider AI system (Groq, OpenRouter, Together AI, Hugging Face)
- **Tests**: API connectivity and fallback system
- **Expected**: Should connect to at least one AI provider, with intelligent fallbacks

### 6. Notification Service

- **Purpose**: Test local notification functionality
- **Tests**: Service initialization
- **Expected**: Should initialize without errors

## Test Results

Each test returns one of these statuses:

- **✅ Passed**: Service working correctly
- **⚠️ Warning**: Service partially working or missing configuration
- **❌ Failed**: Service not working, check configuration or connectivity

## Troubleshooting

### Common Issues

1. **Environment Variables Missing**

   - Ensure `.env` file exists in project root
   - Check that all required API keys are set

2. **Supabase Connection Failed**

   - Verify SUPABASE_URL and SUPABASE_ANON_KEY are correct
   - Check internet connectivity
   - Ensure Supabase project is active

3. **Weather API Failed**

   - Verify OPENWEATHERMAP_API_KEY is valid
   - Check API quota/limits
   - Ensure internet connectivity

4. **AI Service Failed**

   - Verify GROQ_API_KEY is valid
   - Check API quota/limits
   - Ensure internet connectivity

5. **Local Cache Failed**

   - Check device storage permissions
   - Ensure Hive can write to local storage

## API Endpoints Used

### External APIs

- **OpenWeatherMap**: `https://api.openweathermap.org/data/2.5/`
  - Current weather: `/weather`
  - Forecast: `/forecast`
- **Groq AI**: `https://api.groq.com/openai/v1/chat/completions`
- **OpenRouter AI**: `https://openrouter.ai/api/v1/chat/completions`
- **Together AI**: `https://api.together.xyz/v1/chat/completions`
- **Hugging Face**: `https://api-inference.huggingface.co/models/`

### Internal Services

- **Supabase**: Custom PostgreSQL database
- **Hive**: Local NoSQL database
- **Flutter Local Notifications**: Device notifications

## Configuration

Ensure your `.env` file contains:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GROQ_API_KEY=your_groq_api_key
OPENWEATHERMAP_API_KEY=your_openweather_api_key

# Alternative AI Providers
OPENROUTER_API_KEY=your_openrouter_api_key
TOGETHER_API_KEY=your_together_api_key
HUGGINGFACE_API_KEY=your_huggingface_api_key
```

## Running Tests Programmatically

You can also run tests programmatically by calling:

```dart
import '../services/api_test_service.dart';

final results = await ApiTestService.testAllServices();
ApiTestService.printTestResults(results);
```

This will test all services and print detailed results to the console.
