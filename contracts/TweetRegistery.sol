// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;


import "./lib/Stringutils.sol";
import "./utils/UserRegistery.sol";
import "./utils/TweetStructure.sol";


contract TweetRegistry is TweetStructure,UserRegistry {

       //  Mappings
    mapping(string => Tweet) private tweets;
    mapping(string => Comment) private comments;
    mapping(address => string[]) private userTweets;
    mapping(address => string[]) private userComments;
    mapping(string => uint256) private tweetCommentCount;

    // Constants
    uint256 private constant MAX_TEXT_LENGTH = 300;
    
    // modifiers
    modifier onlyRegisteredUser() {
        if (!this.isUserRegistered(msg.sender)) revert UserNotRegistered();
        _;
    }

    modifier tweetExists(string calldata tweetId) {
        if (
            bytes(tweets[tweetId].tweetId).length == 0 ||
            tweets[tweetId].isDeleted
        ) {
            revert TweetNotFound();
        }
        _;
    }

    modifier onlyAuthor(string calldata tweetId) {
        if (tweets[tweetId].content.author != msg.sender) {
            revert UnauthorizedAction();
        }
        _;
    }

    constructor() UserRegistry() {}

    function createTweet(
        string calldata text,
        string[] calldata ipfsHashes,
        string calldata retweetId
    ) external onlyRegisteredUser returns (string memory) {
        string memory tweetId = StringUtils.generateUniqueId();

        if (bytes(retweetId).length > 0) {
            if (
                bytes(tweets[retweetId].tweetId).length == 0 ||
                tweets[retweetId].isDeleted
            ) {
                revert InvalidRetweet();
            }

            Tweet storage newTweet = tweets[tweetId];
            newTweet.tweetId = tweetId;
            newTweet.retweetId = retweetId;
            newTweet.retweetText = text;
            newTweet.content = TweetContent({
                timestamp: block.timestamp,
                author: msg.sender,
                text: "",
                mediaIpfsHashes: new string[](0),
                isEdited: false
            });
            newTweet.isDeleted = false;
        } else {
            if (bytes(text).length > MAX_TEXT_LENGTH) {
                revert TextTooLong();
            }

            Tweet storage newTweet = tweets[tweetId];
            newTweet.tweetId = tweetId;
            newTweet.content = TweetContent({
                timestamp: block.timestamp,
                author: msg.sender,
                text: text,
                mediaIpfsHashes: ipfsHashes,
                isEdited: false
            });
            newTweet.isDeleted = false;
        }

        userTweets[msg.sender].push(tweetId);
        emit TweetCreated(tweetId, msg.sender, block.timestamp);
        return tweetId;
    }

    function addComment(
        string calldata tweetId,
        string calldata replyText,
        string[] calldata ipfsHashes
    ) external onlyRegisteredUser tweetExists(tweetId) returns (string memory) {
        if (bytes(replyText).length > MAX_TEXT_LENGTH) {
            revert TextTooLong();
        }

        string memory commentId = StringUtils.generateUniqueId();

        Comment storage newComment = comments[commentId];
        newComment.commentId = commentId;
        newComment.content = TweetContent({
            timestamp: block.timestamp,
            author: msg.sender,
            text: replyText,
            mediaIpfsHashes: ipfsHashes,
            isEdited: false
        });
        newComment.isDeleted = false;

        tweets[tweetId].commentIds.push(commentId);
        userComments[msg.sender].push(commentId);
        tweetCommentCount[tweetId]++;

        emit CommentAdded(tweetId, commentId, msg.sender);
        return commentId;
    }

    function expressTheTweet(
        string calldata tweetId,
        bool isLike
    ) external onlyRegisteredUser tweetExists(tweetId) {
        Tweet storage tweet = tweets[tweetId];

        if (tweet.expressions[msg.sender].expressedBy == msg.sender) {
            tweet.expressions[msg.sender].isLike = isLike;
            tweet.expressions[msg.sender].timestamp = block.timestamp;
        } else {
            tweet.expressions[msg.sender] = Expression({
                timestamp: block.timestamp,
                expressedBy: msg.sender,
                isLike: isLike,
                isRetweet: false
            });
            tweet.expressionAddresses.push(msg.sender);
        }

        emit ExpressionAdded(tweetId, msg.sender, isLike, false);
    }

    function expressComment(
        string calldata commentId,
        bool isLike
    ) external onlyRegisteredUser {
        Comment storage comment = comments[commentId];
        if (comment.isDeleted) revert CommentNotFound();

        if (comment.expressions[msg.sender].expressedBy == msg.sender) {
            comment.expressions[msg.sender].isLike = isLike;
            comment.expressions[msg.sender].timestamp = block.timestamp;
        } else {
            comment.expressions[msg.sender] = Expression({
                timestamp: block.timestamp,
                expressedBy: msg.sender,
                isLike: isLike,
                isRetweet: false
            });
            comment.expressionAddresses.push(msg.sender);
        }
    }

    function editTweet(
        string calldata tweetId,
        string calldata newText
    ) external onlyRegisteredUser tweetExists(tweetId) onlyAuthor(tweetId) {
        Tweet storage tweet = tweets[tweetId];

        if (bytes(tweet.retweetId).length > 0) {
            tweet.retweetText = newText;
        } else {
            if (bytes(newText).length > MAX_TEXT_LENGTH) {
                revert TextTooLong();
            }
            tweet.content.text = newText;
            tweet.content.isEdited = true;
        }

        emit TweetEdited(tweetId, msg.sender, block.timestamp);
    }

    function editComment(
        string calldata commentId,
        string calldata newText
    ) external onlyRegisteredUser {
        Comment storage comment = comments[commentId];
        if (comment.isDeleted) revert CommentNotFound();
        if (comment.content.author != msg.sender) revert UnauthorizedAction();

        if (bytes(newText).length > MAX_TEXT_LENGTH) {
            revert TextTooLong();
        }

        comment.content.text = newText;
        comment.content.isEdited = true;

        emit CommentEdited(comment.commentId, commentId, msg.sender);
    }

    function deleteTweet(
        string calldata tweetId
    ) external onlyRegisteredUser tweetExists(tweetId) onlyAuthor(tweetId) {
        tweets[tweetId].isDeleted = true;
        emit TweetDeleted(tweetId, msg.sender, block.timestamp);
    }

    function getTweetBasicInfo(
        string calldata tweetId
    ) external view returns (TweetView memory) {
        Tweet storage tweet = tweets[tweetId];
        return
            TweetView({
                content: tweet.content,
                retweetId: tweet.retweetId,
                retweetText: tweet.retweetText,
                commentCount: tweetCommentCount[tweetId],
                expressionCount: tweet.expressionAddresses.length,
                isDeleted: tweet.isDeleted
            });
    }

    function getTweetAuthorInfo(
        string calldata tweetId
    ) external view returns (UserView memory) {
        Tweet storage tweet = tweets[tweetId];
        (string memory username, string memory profilePic) = this
            .getUserDetails(tweet.content.author);
        return UserView({username: username, profilePic: profilePic});
    }

    function getCommentBasicInfo(
        string calldata commentId
    )
        external
        view
        returns (
            TweetContent memory content,
            uint256 expressionCount,
            bool isDeleted
        )
    {
        Comment storage comment = comments[commentId];
        return (
            comment.content,
            comment.expressionAddresses.length,
            comment.isDeleted
        );
    }

    function getCommentAuthorInfo(
        string calldata commentId
    ) external view returns (UserView memory) {
        Comment storage comment = comments[commentId];
        (string memory username, string memory profilePic) = this
            .getUserDetails(comment.content.author);
        return UserView({username: username, profilePic: profilePic});
    }

    function getTweetExpressionAddresses(
        string calldata tweetId
    ) external view returns (address[] memory users, bool[] memory likes) {
        Tweet storage tweet = tweets[tweetId];
        users = tweet.expressionAddresses;
        likes = new bool[](users.length);

        for (uint i = 0; i < users.length; i++) {
            likes[i] = tweet.expressions[users[i]].isLike;
        }
    }

    function getTweetExpressionUsers(
        string calldata tweetId
    )
        external
        view
        returns (string[] memory usernames, string[] memory profilePics)
    {
        Tweet storage tweet = tweets[tweetId];
        address[] memory users = tweet.expressionAddresses;
        usernames = new string[](users.length);
        profilePics = new string[](users.length);

        for (uint i = 0; i < users.length; i++) {
            (usernames[i], profilePics[i]) = this.getUserDetails(users[i]);
        }
    }

    function getCommentExpressionAddresses(
        string calldata commentId
    ) external view returns (address[] memory users, bool[] memory likes) {
        Comment storage comment = comments[commentId];
        users = comment.expressionAddresses;
        likes = new bool[](users.length);

        for (uint i = 0; i < users.length; i++) {
            likes[i] = comment.expressions[users[i]].isLike;
        }
    }

    function getCommentExpressionUsers(
        string calldata commentId
    )
        external
        view
        returns (string[] memory usernames, string[] memory profilePics)
    {
        Comment storage comment = comments[commentId];
        address[] memory users = comment.expressionAddresses;
        usernames = new string[](users.length);
        profilePics = new string[](users.length);

        for (uint i = 0; i < users.length; i++) {
            (usernames[i], profilePics[i]) = this.getUserDetails(users[i]);
        }
    }

    function getTweetComments(
        string calldata tweetId
    ) external view returns (string[] memory) {
        return tweets[tweetId].commentIds;
    }

    function getUserTweets(
        address user
    ) external view returns (string[] memory) {
        return userTweets[user];
    }

    function getUserComments(
        address user
    ) external view returns (string[] memory) {
        return userComments[user];
    }

    function getLatestTweets() external view returns (TweetView[] memory) {
        uint256 count = 0;
        string[] memory allTweets = new string[](userTweets[msg.sender].length);

        for (uint i = 0; i < userTweets[msg.sender].length; i++) {
            string memory tweetId = userTweets[msg.sender][i];
            if (!tweets[tweetId].isDeleted) {
                allTweets[count] = tweetId;
                count++;
            }
        }
        for (uint i = 0; i < count; i++) {
            for (uint j = 0; j < count - 1; j++) {
                if (
                    tweets[allTweets[j]].content.timestamp <
                    tweets[allTweets[j + 1]].content.timestamp
                ) {
                    string memory temp = allTweets[j];
                    allTweets[j] = allTweets[j + 1];
                    allTweets[j + 1] = temp;
                }
            }
        }

        uint256 latestCount = count > 100 ? 100 : count;
        TweetView[] memory latestTweets = new TweetView[](latestCount);

        for (uint i = 0; i < latestCount; i++) {
            Tweet storage tweet = tweets[allTweets[i]];
            latestTweets[i] = TweetView({
                content: tweet.content,
                retweetId: tweet.retweetId,
                retweetText: tweet.retweetText,
                commentCount: tweetCommentCount[tweet.tweetId],
                expressionCount: tweet.expressionAddresses.length,
                isDeleted: tweet.isDeleted
            });
        }

        return latestTweets;
    }
}
