# Decentralized Twitter-like Application

## Overview
This project is a decentralized social media application inspired by Twitter. It is built using Solidity and IPFS for content storage. The smart contract ensures secure tweet creation, expression tracking, retweets, and user management in a decentralized environment.

## Features
- **Tweet Creation & Storage:** Users can create tweets, including text and media references.
- **Retweets & Comments:** Supports retweets with optional additional text and comments.
- **Expressions (Likes, Dislikes, etc.):** Users can express sentiments on tweets and comments.
- **User Registration:** Only registered users can interact with tweets.
- **Secure & Immutable:** Uses unique tweet IDs for data integrity.
- **Latest Tweet Retrieval:** Fetches the latest tweets efficiently.

## Smart Contracts
### `TweetRegistry.sol`
Handles the core functionality of tweet creation, retweets, comments, and expressions.

#### Key Functions:
- `createTweet(string calldata content, string calldata mediaHash)`: Creates a new tweet.
- `retweet(string calldata originalTweetId, string calldata retweetText)`: Allows retweeting an existing tweet.
- `commentOnTweet(string calldata tweetId, string calldata content)`: Adds a comment to a tweet.
- `expressTheTweet(string calldata tweetId, string calldata expressionType)`: Expresses sentiments (like, dislike, etc.) on a tweet.
- `expressComment(string calldata tweetId, string calldata commentId, string calldata expressionType)`: Expresses sentiments on a comment.
- `getLatestTweets(uint count)`: Fetches the latest tweets.

### `StringUtils.sol`
Provides helper functions for generating unique tweet IDs using a combination of block attributes and sender information.

## Unique ID Generation
Each tweet ID is generated using a hash function based on:
- `block.timestamp`
- `block.prevrandao`
- `msg.sender`
- `block.number`
- `gasleft()`

This ensures a reasonable level of uniqueness while maintaining efficiency.

## Installation & Deployment
### Prerequisites
- Node.js & npm
- Hardhat or Truffle
- Solidity compiler (0.8.x)
- IPFS node (for media storage)

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/RandomDapps/decentralized-twitter.git
   cd decentralized-twitter
   ```
2. Install dependencies:
   ```sh
   npm install
   ```
3. Compile the smart contracts:
   ```sh
   npx hardhat compile
   ```
4. Deploy the contracts:
   ```sh
   npx hardhat run scripts/deploy.ts --network <network-name>
   ```

## Usage
- Register as a user.
- Create, retweet, and comment on tweets.
- Express (like/dislike) tweets and comments.
- Fetch the latest tweets using contract functions.

## Future Enhancements
- Implement a better indexing system for tweets.
- Allow users to remove expressions (unlike/unexpress).
- Improve sorting for `getLatestTweets()`.
- Extend compatibility for cross-chain deployment.

## License
This project is licensed under the MIT License.