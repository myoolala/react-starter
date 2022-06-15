# React Starter

This project is a foundation for building custom applications using React and Node.js.

## Requirements

You will need [Nodejs](https://nodejs.org/en/download/) installed. If you are working on multiple projects, it may be a good idea to install the latest version of Node using [nvm](https://github.com/nvm-sh/nvm).

## Getting Started

Follow the steps below to get the app running on your local machine:

1. Navigate into the app folder.
1. Run `npm i`.
1. Run `npm run dev`.
1. Open your browser to `http://localhost:3000`.

Alternatively, you can run the app in docker which adds a mongo database

1. docker-compose up --build docker

## Scripts

| Name      | Description                             |
| --------- | --------------------------------------- |
| dev       | Run in development mode                 |
| test      | Run Jest using defaults                 |
| start     | Run in production mode                  |
| prettier  | Format all JS code in the src directory |
| build     | Generate the static js files for the ui |

## Conventions

Read more on the following topics in our included docs:

-   [State Management](./docs/StateManagement.md)
-   [Contributing](docs/Contributing.md)
-   [Releases](docs/Releases.md)
