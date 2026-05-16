# FarmTok - AI-Powered Smart Farming Assistant

FarmTok is a comprehensive mobile application designed for Tanzanian and African farmers, providing AI-powered crop disease detection, weather intelligence, farming advice, and offline-first functionality.

## Features

- **AI Crop Disease Scanner**: Analyze crop images for diseases with AI-powered detection
- **Farming AI Chatbot**: Get instant farming advice using Groq AI
- **Weather Intelligence**: Real-time weather data with farming recommendations
- **Offline-First Architecture**: Works without internet connectivity
- **Modern UI**: Clean, green-themed interface optimized for farmers
- **Multi-language Support**: English and Swahili support

## Tech Stack

- **Flutter**: Cross-platform mobile development
- **Supabase**: Backend as a Service (Auth, Database, Storage)
- **Groq AI**: AI chatbot and disease analysis
- **OpenWeatherMap**: Weather intelligence
- **Hive**: Local offline storage
- **Provider**: State management

## Setup Instructions

### Prerequisites

1. Flutter SDK (latest stable version)
2. Android Studio or VS Code with Flutter extensions
3. Supabase account
4. Groq API key
5. OpenWeatherMap API key

### 1. Clone and Setup Project

```bash
git clone <repository-url>
cd farmtok
flutter pub get
```

### 2. Environment Configuration

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
GROQ_API_KEY=your_groq_api_key
OPENWEATHERMAP_API_KEY=your_openweathermap_api_key
```

### 3. Supabase Setup

1. Create a new Supabase project
2. Run the SQL schema from `supabase_schema.sql` in your Supabase SQL editor
3. Configure authentication settings in Supabase dashboard
4. Set up storage bucket for crop images (optional for basic functionality)

### 4. API Keys Setup

1. **Groq AI**: Get API key from [groq.com](https://groq.com)
2. **OpenWeatherMap**: Get API key from [openweathermap.org](https://openweathermap.org)

### 5. Run the Application

```bash
flutter run
```

## Database Schema

The application uses the following tables:

- `users`: User profiles extending Supabase auth
- `crop_scans`: Disease scan results
- `ai_chats`: Chatbot conversation history
- `weather_logs`: Weather data storage
- `recommendations`: AI-generated farming tips
- `notifications`: Push notifications

## Architecture

```
lib/
├── core/                 # Core utilities and constants
├── models/              # Data models
├── services/            # API services and business logic
├── providers/           # State management
├── screens/             # UI screens
├── widgets/             # Reusable UI components
├── utils/               # Helper functions
└── offline/             # Offline storage adapters
```

## Key Features Implementation

### Authentication
- Email/password authentication via Supabase
- User profile management
- Session persistence

### AI Disease Scanner
- Camera integration for image capture
- AI-powered disease detection
- Treatment recommendations
- Offline scan caching

### AI Chatbot
- Real-time chat interface
- Groq AI integration
- Conversation history
- Offline message caching

### Weather Intelligence
- OpenWeatherMap API integration
- 7-day weather forecast
- Farming condition recommendations
- Safety alerts for spraying

### Offline-First
- Hive local storage
- Cached data synchronization
- Graceful offline mode

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
- Create an issue on GitHub
- Contact the development team

---

**FarmTok** - Empowering African farmers with AI technology 🌱