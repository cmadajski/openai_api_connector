# OpenAI API Connector
A Python command line utility for interacting with [OpenAI's]() public APIs.

Feature Roadmap:
- [x] Text prompts for GPT-3
- [x] New Image generation based on text prompt
- [ ] Text moderation
- [ ] Modifying existing images
- [ ] Detailed session logging
- [x] Switch engines
- [ ] Change API params
- [ ] API session persistence (previous request context maintained until token limit reached)

## Installation

Before attempting to use this utility, make sure you have [Python](https://www.python.org/downloads/) and [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) installed.

Clone the repo: `git clone https://github.com/cmadajski/openai_api_connector.git`

Run the setup script: `source setup.sh`

You will be asked to provide an OpenAI API key. Copy/paste one of your OpenAI API keys into the terminal. You can find your API keys [here](https://beta.openai.com/account/api-keys).

> NOTE: If you get an error when attempting to run setup.sh or run_api_connector.sh, you may need to allow execution privileges on those files by using `sudo chmod +x setup.sh` and `sudo chmod +x run_api_connector.sh`

Run the app: `source run_api_connector.sh`

## User Guide

The API Connector supports 5 Main Functions:
1. Text Completion
2. Text Moderation
3. Image Functions
4. Engine Information
5. Exit Program
