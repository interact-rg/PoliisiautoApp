# Poliisiauto API Documentation

This document provides a comprehensive overview of the Poliisiauto API and its mobile integration.

## Base URLs

- **Production**: `https://poliisiautoweb.onrender.com/api/v1`
- **Development**: `http://127.0.0.1:8000/api/v1`

---

## Authentication

The API uses **Bearer Token Authentication** via Laravel Sanctum.

### Register Device

`POST /register`
Registers a new device/user.

- **Request Body**: `first_name`, `last_name`, `email`, `password`, `password_confirmation`, `device_name`.
- **Response**: `{ "access_token": "..." }`

### Login

`POST /login`
Authenticates a user and returns a token.

- **Request Body**: `email`, `password`, `device_name`, `api_key`.
- **Response**: `{ "access_token": "..." }`

### Logout

`POST /logout` (Authenticated)
Invalidates the current session.

---

## Reports (Conversations)

Reports act as containers for messages between students/devices and teachers.

### List Reports

`GET /report` (Authenticated)
Fetches all reports accessible to the user.

- **Mobile Integration**: Implements a 5-minute memory cache to optimize performance.

### Fetch Report Details

`GET /messages/{report_id}` (Authenticated)
Fetches the full details of a specific report by its ID.

- **Note**: This endpoint returns the primary report object, often including metadata from the last message.

---

## Messages

### List Messages for a Report

`GET /messages/{report_id}` (Authenticated)
Fetches all messages associated with a specific report.

- **Mobile Integration**: Displays messages in a chat-like interface. Supports both List and single Map object responses from the backend.

### Fetch Single Message

`GET /messages/{id}` (Authenticated)
Fetches details for a single message. Used during notification navigation.

### Send Message

`POST /reports/{report_id}/messages` (Authenticated, Multipart/Form-data)

- **Parameters**: `content`, `type` (text/audio), `is_anonymous`, `lat`, `lon`, `file` (if audio).

---

## Features & Implementation Details

### Audio Messages

- **Storage**: Audio files are stored in `storage/audio/`.
- **Playback**: The mobile app uses `audioplayers` to stream `.wav` files directly from the `file_path` URL returned by the API.

### Location Tracking

- **GPS Coordinates**: Every message can include `lat` and `lon`.
- **UI**: Displayed as a small location icon with coordinates in the message bubble.

### Performance & Caching

- **Memory Cache**: `PoliisiautoApi` maintains a memory cache for `fetchReports` and `fetchMessages` to reduce network latency.
- **Pull-to-Refresh**: Available on the notification screen to force a cache bypass.

### Notification Flow

1. Server sends FCM message with `message_id`.
2. Mobile app fetches full message details via `GET /api/v1/messages/{id}`.
3. App navigates directly to `ReportDetailsScreen` based on the `report_id` found in the message details.
