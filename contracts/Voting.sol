// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Poll {
        uint id;
        string title;
        string description;
        address creator;
        mapping(uint => Option) options;
        uint optionCount;
        mapping(address => bool) hasVoted;
    }

    struct Option {
        uint id;
        string text;
        uint voteCount;
    }

    mapping(uint => Poll) public polls;
    uint public pollCount;

    modifier onlyCreator(uint _pollId) {
        require(
            msg.sender == polls[_pollId].creator,
            "Only the poll creator can add options"
        );
        _;
    }

    modifier onlyOnceVote(uint _pollId) {
        require(
            !polls[_pollId].hasVoted[msg.sender],
            "You have already voted in this poll"
        );
        _;
    }

    event CreatePoll(
        address indexed creator,
        string _title,
        string _description
    );
    event AddOption(address indexed creator, uint _pollId, string _text);
    event Voted(address indexed voter, uint _pollId, uint _optionId);

    /*//////////////////////////////////////////////////////////////
                              Create a poll
    //////////////////////////////////////////////////////////////*/
    function createPoll(
        string memory _title,
        string memory _description
    ) public {
        require(
            bytes(_title).length > 0 && bytes(_description).length > 0,
            "Title and description are required"
        );
        pollCount++;
        Poll storage p = polls[pollCount];
        p.id = pollCount;
        p.title = _title;
        p.description = _description;
        p.creator = msg.sender;

        emit CreatePoll(msg.sender, _title, _description);
    }

    /*//////////////////////////////////////////////////////////////
                        Add options to a poll
    //////////////////////////////////////////////////////////////*/
    function addOption(
        uint _pollId,
        string memory _text
    ) public onlyCreator(_pollId) {
        polls[_pollId].optionCount++;
        polls[_pollId].options[polls[_pollId].optionCount] = Option(
            polls[_pollId].optionCount,
            _text,
            0
        );
        emit AddOption(msg.sender, _pollId, _text);
    }

    /*//////////////////////////////////////////////////////////////
                          Vote to the option
    //////////////////////////////////////////////////////////////*/
    function vote(uint _pollId, uint _optionId) public onlyOnceVote(_pollId) {
        polls[_pollId].hasVoted[msg.sender] = true;
        polls[_pollId].options[_optionId].voteCount++;
        emit Voted(msg.sender, _pollId, _optionId);
    }

    /*//////////////////////////////////////////////////////////////
                          Get the vote count
    //////////////////////////////////////////////////////////////*/
    function getVoteCount(
        uint _pollId,
        uint _optionId
    ) public view returns (uint) {
        return polls[_pollId].options[_optionId].voteCount;
    }

    /*//////////////////////////////////////////////////////////////
                         Get the option text
    //////////////////////////////////////////////////////////////*/
    function getOptionText(
        uint _pollId,
        uint _optionId
    ) public view returns (string memory) {
        return polls[_pollId].options[_optionId].text;
    }
}
