# Dead by Roblox - Menu Queue UI

This folder contains the React-Lua implementation for the menu queue selection system.

## Components

### QueueSelection.lua
The main UI component that displays:
- Role selection buttons (Survivor/Killer)
- Queue status display with timer
- Dynamic button states based on queue status
- Hover effects and visual feedback

### MenuApp.lua
The root React component that:
- Creates the main ScreenGui
- Sets up the background
- Renders the QueueSelection component

## Controllers

### MenuController.lua
Handles React root initialization:
- Creates ReactRoblox root in PlayerGui
- Mounts the MenuApp component
- Provides cleanup functionality

### QueueService.lua
Manages queue logic:
- `QueueAsSurvivor()` - Queue for survivor role
- `QueueAsKiller()` - Queue for killer role
- `CancelQueue()` - Cancel current queue
- `GetQueueStatus()` - Get current queue information
- `IsQueuing()` - Check if currently in queue

## Features

- **Dynamic UI**: Buttons change color, text, and behavior based on queue state
- **Queue Timer**: Shows how long you've been queuing
- **Role Locking**: Can't queue for multiple roles simultaneously
- **Visual Feedback**: Hover effects and disabled states
- **Real-time Updates**: UI updates every second to show current status

## Usage

1. The MenuRuntime.client.lua automatically initializes the UI when in the menu place
2. Players can click "Queue as Survivor" or "Queue as Killer" to join a queue
3. While queuing, the other button is disabled and the active queue shows a timer
4. Players can cancel their queue by clicking the "Cancel Queue" button
5. Queue status is displayed in real-time with visual indicators

## Extending the System

To add server-side matchmaking:
1. Create RemoteEvents for queue requests
2. Update QueueService to fire these events
3. Implement server-side queue management
4. Add teleportation to game place when match is found

## Dependencies

- React (jsdotlua/react@17.1.0)
- ReactRoblox (jsdotlua/react-roblox@17.1.0)