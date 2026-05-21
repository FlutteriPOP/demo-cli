# Dart AI CLI

A powerful, command-line interface powered by Genkit and Google Gemini that allows you to manage a local workspace using natural language.

## Features
- **Agentic Loop (Autonomous Multi-Step Execution)**: The CLI can now evaluate the results of its own actions and perform follow-up tasks autonomously until a complex goal is reached! (Max 10 steps per prompt).
- **Loading Spinner UI**: Enjoy a buttery smooth asynchronous `⠋ Thinking...` spinner while the AI processes your requests.
- **Contextual Memory**: The AI remembers your conversation and previous commands in the session.
- **Token Usage Tracking**: Get real-time transparency into how many tokens the AI is consuming per action.
- **File Management**: Ask the AI to `create`, `read`, `update`, `append`, `delete`, `list`, or `rename` files inside your workspace.
- **Execute Commands**: The AI can execute safe shell commands on your behalf using the `run` action (e.g. `flutter create app`).
- **Beautiful UI**: Features a colorful terminal output and interactive loop.

## Setup & Usage

To start the CLI, run:
```sh
dart run
```

Type natural language instructions, or use `quit`, `exit`, or `q` to leave the application.

*Powered by Google Genkit for Dart.*
