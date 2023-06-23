// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Twitter {
    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 createdAt;
    }

    struct Message {
        uint256 id;
        address from;
        address to;
        string mssg;
        uint256 createdAt;
    }

    mapping(uint256 => Tweet) public tweets;
    mapping(address => uint256[]) public tweetsOf;
    mapping(address => Message[]) public conversations;
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => address[]) public followings;
    // mapping(address => address[]) public followers;

    uint256 nextId;
    uint256 nextMessageId;

    function _tweet(address user, string memory content) internal {
        tweets[nextId] = Tweet(nextId, user, content, block.timestamp);
        tweetsOf[user].push(nextId);
        nextId++;
    }

    //if someone wants to tweet from their own account/address
    function tweet(string memory content) public {
        _tweet(msg.sender, content);
    }

    //if account manager wants to tweet for their client
    function tweet(address user, string memory content) public {
        _tweet(user, content);
    }

    function _sendMessage(
        address user,
        address to,
        string memory mssg
    ) internal {
        conversations[user].push(
            Message(nextMessageId, user, to, mssg, block.timestamp)
        );
        nextMessageId++;
    }

    //if someone wants to message from their own account/address
    function sendMessage(address to, string memory mssg) public {
        _sendMessage(msg.sender, to, mssg);
    }

    //if account manager wants to message from their client's account
    function sendMessage(
        address user,
        address to,
        string memory mssg
    ) public {
        _sendMessage(user, to, mssg);
    }

    function _follow(address user, address followed) internal {
        followings[user].push(followed);
    }

    //if someone wants to follow from their own account/address
    function follow(address followed) public {
        _follow(msg.sender, followed);
    }

    //if account manager wants to follow from their client's account
    function follow(address user, address followed) public {
        _follow(user, followed);
    }

    //to add account manager
    function allowAccess(address operator) public {
        operators[msg.sender][operator] = true;
    }

    //to add account manager
    function removeAccess(address operator) public {
        operators[msg.sender][operator] = false;
    }

    function fetchLatestTweets(uint256 count)
        public
        view
        returns (Tweet[] memory)
    {
        require(count > 0 && count < nextId, "count out of bound");
        Tweet[] memory latestTweets; //we cannot return mappings so we create an array copy tweets and return it;
        for (uint256 i; i < count; i++) {
            latestTweets[0] = tweets[nextId - i];
        }
        return latestTweets;
    }
}
