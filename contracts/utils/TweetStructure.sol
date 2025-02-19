
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract TweetStructure{
    // Errors
    error TextTooLong();
    error UnauthorizedAction();
    error TweetNotFound();
    error InvalidRetweet();
    error InvalidExpression();
    error CommentNotFound();
    error RetweetNotAllowedOnComments();
    error CannotInteractWithoutRegistration();

    // Events
    event TweetCreated(
        string indexed tweetId,
        address indexed author,
        uint256 timestamp
    );
    event TweetEdited(
        string indexed tweetId,
        address indexed author,
        uint256 timestamp
    );
    event TweetDeleted(
        string indexed tweetId,
        address indexed author,
        uint256 timestamp
    );
    event ExpressionAdded(
        string indexed tweetId,
        address indexed user,
        bool isLike,
        bool isRetweet
    );
    event CommentAdded(
        string indexed tweetId,
        string indexed commentId,
        address indexed author
    );
    event CommentEdited(
        string indexed tweetId,
        string indexed commentId,
        address indexed author
    );

    // Structs

    struct Expression {
        uint256 timestamp;
        address expressedBy;
        bool isLike;
        bool isRetweet;
    }

    struct TweetContent {
        uint256 timestamp;
        address author;
        string text;
        string[] mediaIpfsHashes;
        bool isEdited;
    }

    struct Comment {
        string commentId;
        TweetContent content;
        mapping(address => Expression) expressions;
        address[] expressionAddresses;
        bool isDeleted;
    }

    struct Tweet {
        string tweetId;
        string retweetId;
        string retweetText;
        TweetContent content;
        mapping(address => Expression) expressions;
        address[] expressionAddresses;
        string[] commentIds;
        bool isDeleted;
    }
    // retuend
    struct TweetView {
        TweetContent content;
        string retweetId;
        string retweetText;
        uint256 commentCount;
        uint256 expressionCount;
        bool isDeleted;
    }

    struct UserView {
        string username;
        string profilePic;
    }

    struct ExpressionView {
        address[] users;
        bool[] likes;
        string[] usernames;
        string[] profilePics;
    }


    
 

}