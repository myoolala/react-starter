# React Starter

This project is a foundation for building custom applications using React and Node.js.

## Requirements

You will need to have either [Nodejs](https://nodejs.org/en/download/) or [Docker](https://docker.com) installed. If you are working on multiple projects and not using docker, it may be a good idea to install the latest version of Node using [nvm](https://github.com/nvm-sh/nvm).

## Getting Started

Follow the steps below to get the app running on your local machine:

1. `docker-compose up --build app`

Alternatively, you can run the app in directly on your machine if you do not have docker installed

1. Navigate into the app folder.
1. Run `npm i`.
1. Run `npm run dev`.
1. Open your browser to `http://localhost:3000`.

## Scripts

| Name      | Description                             |
| --------- | --------------------------------------- |
| dev       | Run in development mode                 |
| test      | Run Jest using defaults                 |
| start     | Run in production mode                  |
| prettier  | Format all JS code in the src directory |
| build     | Generate the static js files for the ui |

## Deployment Container 

Built in is a container with terraform, terragrunt, and node all installed. The main purpose is so that there is a committed place of what version of each is necessary to deploy the code.

Other highlights of the container include:
1. Persistent bash history preserved in docker volumes
1. Volumes in the host machine's aws and ssh credentials
1. volumes in the entire repo to keep the docker context non-existant

### Running the devops container for the first time

1. Make sure your aws credentials are valid
1. Run `docker-compose build devops && docker-compose run devops`
1. Run `cd devops/scripts`
1. Run `./init-terragrunt.sh`

You can now run terragrunt from the terragrunt folder. You will need to update the various HCL files for your cloud environments, but they will be marked
Once done, run `terragrunt apply` on the area you'd like to deploy

## Redis

The app out of the box is configured to be able to work with redis for an offsite session storage. This will allow deploys to occur without logging users out. It also removes the need for sticky load balancers. This is config driven so you can disable it for a lighter backend

## Config

The app uses [env-var](https://www.npmjs.com/package/env-var) to pull in environment variables into a single config file. There are no other ways to inject a config by environment to keep the inheritance down to a minimum

## Conventions

Read more on the following topics in our included docs:

-   [State Management](./docs/StateManagement.md)
-   [Contributing](docs/Contributing.md)
-   [Releases](docs/Releases.md)


## Known issues:

- If a module unfound error from a missing npm package is thrown, the live restart does not work as it doesn't run npm installs. The process should exit instead