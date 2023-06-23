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

    mapping(uint256 => Tweet) tweets;
    mapping(address => uint256[]) tweetsOf;
    mapping(address => Message[]) conversations;
    mapping(address => mapping(address => bool)) operators;
    mapping(address => address[]) followings;
    // mapping(address => address[]) public followers;

    uint256 nextId;
    uint256 nextMessageId;
    address owner = msg.sender;

    function _tweet(address user, string memory content) internal {
        tweets[nextId] = Tweet(nextId, user, content, block.timestamp);
        tweetsOf[user].push(nextId);
        nextId++;
    }

    //if someone wants to tweet from their own account/address
    function tweet(string memory content) public {
        require(msg.sender == owner, "Access not allowed");
        _tweet(msg.sender, content);
    }

    //if account manager wants to tweet for their client
    function tweet(address user, string memory content) public {
        require(operators[user][msg.sender], "Access not allowed");
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
        require(msg.sender == owner, "Access not allowed");
        _sendMessage(msg.sender, to, mssg);
    }

    //if account manager wants to message from their client's account
    function sendMessage(
        address user,
        address to,
        string memory mssg
    ) public {
        require(operators[user][msg.sender], "Access not allowed");
        _sendMessage(user, to, mssg);
    }

    function _follow(address user, address followed) internal {
        followings[user].push(followed);
    }

    //if someone wants to follow from their own account/address
    function follow(address followed) public {
        require(msg.sender == owner, "Access not allowed");
        _follow(msg.sender, followed);
    }

    //if account manager wants to follow from their client's account
    function follow(address user, address followed) public {
        require(operators[user][msg.sender], "Access not allowed");
        _follow(user, followed);
    }

    //to add account manager
    function allowAccess(address operator) public {
        require(msg.sender == owner, "Access not allowed");
        operators[msg.sender][operator] = true;
    }

    //to add account manager
    function removeAccess(address operator) public {
        require(msg.sender == owner, "Access not allowed");
        operators[msg.sender][operator] = false;
    }

    // function getTweet(uint256 key) public view returns (Tweet memory) {
    //     Tweet memory t = tweets[key];
    //     // t = Tweet(
    //     //     tweets[key].id,
    //     //     tweets[key].author,
    //     //     tweets[key].content,
    //     //     tweets[key].createdAt
    //     // );
    //     // t.id = tweets[key].id;
    //     // t.author = tweets[key].author;
    //     // t.content = tweets[key].content;
    //     // t.createdAt = tweets[key].createdAt;
    //     return t;
    // }

    function getLatestTweets(uint256 count)
        public
        view
        returns (Tweet[] memory)
    {
        require(
            msg.sender == owner || operators[owner][msg.sender],
            "Access not allowed"
        );
        require(count > 0 && count <= nextId, "count out of bound");
        Tweet[] memory latestTweets = new Tweet[](count); //we cannot return mappings so we create an array copy tweets and return it;
        for (uint256 i; i < count; i++) {
            latestTweets[i] = tweets[nextId - i - 1];
        }
        return latestTweets;
    }

    function getLatestTweetsOfUser(address user, uint256 count)
        public
        view
        returns (Tweet[] memory)
    {
        require(
            msg.sender == owner || operators[owner][msg.sender],
            "Access not allowed"
        );
        require(count > 0 && count <= nextId, "count out of bound");
        require(tweetsOf[user].length > 0, "no tweets");
        Tweet[] memory userTweets = new Tweet[](count); //we cannot return mappings so we create an array copy tweets and return it;
        uint256 userTweetsIndex = tweetsOf[user].length - 1;
        for (uint256 i; i < count; i++) {
            userTweets[i] = tweets[tweetsOf[user][userTweetsIndex - i]];
        }
        return userTweets;
    }
}
