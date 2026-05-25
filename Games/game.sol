// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Game{

    struct Data{
        address player1;
        address player2;
        uint256 bal1;
        uint256 bal2;
        bool open;
    }
    enum Choice {none, stone, paper, scissor}
    
    Data public info;
    mapping (address => Choice) choice;
    uint256 public nonce = 0;

    // events
    event ChannelOpened(address player1, address player2);
    event GamePlayed(address winner, bool isDraw);
    event ChannelClosed();

    // for opening Channel
    function openChannel(address add) public  {
        require(!info.open, "Close current channel first");
        info.player1 = msg.sender;
        info.player2 = add;
        info.open = true;
        nonce++;
        emit ChannelOpened(info.player1, info.player2);
    }
    // for closing channel
    function closeChannel() public {
        require(info.bal1 == 0 && info.bal2 == 0, "Withdraw funds first!");
        require(info.open, "Nothing to close");
        require(msg.sender == info.player1 || msg.sender == info.player2, "ONLY Players can Close");
        info.open = false;
        nonce++;
        emit ChannelClosed();
    }
    // for adding funds
    function addFunds() public payable {
        require(msg.value >= 0.01 ether, "0.01 ETH MIN.");
        require(info.open, "Not Opened");
        if (msg.sender == info.player1) {
            info.bal1 += msg.value;
        } else if (msg.sender == info.player2) {
            info.bal2 += msg.value;
        } else {
            revert("Invalid user");
        }
    }
    // for withdrawing funds
    function withdrawFunds() public {
        require(msg.sender == info.player1 || msg.sender == info.player2, "Invalid User");
        
        if(msg.sender == info.player1){
            require(info.bal1 > 0 ,"Nothing to Withdraw");
            uint256 bal = info.bal1;
            info.bal1 = 0;
            (bool success, ) = payable(msg.sender).call{value: bal}("");
            require(success,"Transfer Failed");
        }
        else {
             require(info.bal2 > 0 ,"Nothing to Withdraw");
             uint256 bal = info.bal2;
             info.bal2 = 0;
            (bool success, ) = payable(msg.sender).call{value: bal}("");
            require(success,"Transfer Failed");
        }
    }
    // for selecting the option (both users must call this)
    function play(bytes memory signature, Choice c) public {
        require(info.open, "Open Channel first");
        require(c != Choice.none , "Select first!");
        require(choice[msg.sender] == Choice.none,"You have selcted already!");
        require(msg.sender == info.player1 || msg.sender == info.player2, "Invalid User");
        bytes32 message = getMessage(c);
        address signer = _recover(message, signature);
        require(signer == msg.sender, "Invalid Signature");
        choice[msg.sender] = c;
    }
    // for checking the results
    function check() public returns(address){
        address winner;
        require(msg.sender == info.player1 || msg.sender == info.player2, "Only players");
        require(choice[info.player1] != Choice.none && choice[info.player2] != Choice.none, "Choose first!");
        if(choice[info.player1] == Choice.stone){
            if(choice[info.player2]== Choice.stone){
                winner = address(0);
            }
            else if(choice[info.player2] == Choice.paper){
                winner = info.player2;
            }
            else {
                winner = info.player1;
            }
        }
        else if (choice[info.player1] == Choice.paper){
             if(choice[info.player2] == Choice.stone){
                winner = info.player1;
            }
            else if(choice[info.player2] == Choice.paper){
                winner = address(0);
            }
            else {
                winner = info.player2;
            }
        }
        else {
             if(choice[info.player2] == Choice.stone){
                winner = info.player2;
            }
            else if(choice[info.player2] == Choice.paper){
                winner = info.player1;
            }
            else {
                winner = address(0);
            }
        }
        if(winner != address(0)){
            _addRewards(winner);
        }
        _restore();
        emit GamePlayed(winner, winner == address(0));
        nonce++;
        return winner;
    }

    function getMessage(Choice c) public view returns(bytes32){
        return keccak256(abi.encodePacked(address(this), info.bal1, info.bal2, nonce, c));
    }

    // Helper Functions

    function _addRewards(address adr) internal {
        if(adr == info.player1){
            require(info.bal2 >= 0.001 ether,"Not Enough ETH" );
            info.bal1 += 0.001 ether;
            info.bal2 -= 0.001 ether;
        }
        else{
            require(info.bal1 >= 0.001 ether,"Not Enough ETH" );
            info.bal2 += 0.001 ether;
            info.bal1 -= 0.001 ether;
        }
    } 

    function _restore() internal {
        choice[info.player1] = Choice.none;
        choice[info.player2] = Choice.none;
    }

    function _recover(bytes32 hash, bytes memory sig) internal pure returns (address) {
        require(sig.length == 65);
        bytes32 r; bytes32 s; uint8 v;
         bytes32 ethSignedHash = keccak256(abi.encodePacked(
        "\x19Ethereum Signed Message:\n32",
        hash
    ));
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return ecrecover(ethSignedHash, v, r, s);
    }
    // receive function to receive ETH
    receive() external payable { }
}
