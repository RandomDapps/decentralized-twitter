// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract UserRegistry {
    struct User {
        string username;
        string profilePic;
    }

    mapping(address => User) private users;
    mapping(string => address) private usernameToAddress;

    address public owner;

    event UsernameRegistered(address indexed user, string username, string profilePic, bool isOwner);
    event UsernameUpdated(address indexed user, string oldUsername, string newUsername, string newProfilePic);
    event UsernameDeleted(address indexed user, string username, bool isOwner);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    error UsernameTooShort();
    error UsernameAlreadyTaken();
    error AddressAlreadyRegistered();
    error NotOwner();
    error UserNotRegistered();
    error InvalidAddress();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUsername(string calldata username, string calldata profilePic) external {
        _registerUser(msg.sender, username, profilePic, false);
    }

    function registerUsernameByOwner(address user, string calldata username, string calldata profilePic) external onlyOwner {
        _registerUser(user, username, profilePic, true);
    }

    function updateUsername(string calldata newUsername, string calldata newProfilePic) external {
        _updateUser(msg.sender, newUsername, newProfilePic);
    }

    function getUserDetails(address user) external view returns (string memory, string memory) {
        return (users[user].username, users[user].profilePic);
    }

    function deleteUser() external {
        _deleteUser(msg.sender, false);
    }

    function deleteUserByOwner(address user) external onlyOwner {
        _deleteUser(user, true);
    }

    function isUserRegistered(address user) external view returns (bool) {
        return bytes(users[user].username).length > 0;
    }

    function _transferOwnership(address newOwner) internal onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _registerUser(address user, string calldata username, string calldata profilePic, bool isOwner) internal {
        if (bytes(username).length < 6) revert UsernameTooShort();
        if (usernameToAddress[username] != address(0)) revert UsernameAlreadyTaken();
        if (bytes(users[user].username).length > 0) revert AddressAlreadyRegistered();

        users[user] = User(username, profilePic);
        usernameToAddress[username] = user;

        emit UsernameRegistered(user, username, profilePic, isOwner);
    }

    function _updateUser(address user, string calldata newUsername, string calldata newProfilePic) internal {
        if (bytes(newUsername).length < 6) revert UsernameTooShort();
        if (usernameToAddress[newUsername] != address(0)) revert UsernameAlreadyTaken();
        if (bytes(users[user].username).length == 0) revert UserNotRegistered();

        string memory oldUsername = users[user].username;

        delete usernameToAddress[oldUsername];
        users[user] = User(newUsername, newProfilePic);
        usernameToAddress[newUsername] = user;

        emit UsernameUpdated(user, oldUsername, newUsername, newProfilePic);
    }

    function _deleteUser(address user, bool isOwner) internal {
        if (msg.sender != user && !isOwner) revert NotOwner();
        if (bytes(users[user].username).length == 0) revert UserNotRegistered();

        string memory username = users[user].username;

        delete users[user];
        delete usernameToAddress[username];

        emit UsernameDeleted(user, username, isOwner);
    }
}
