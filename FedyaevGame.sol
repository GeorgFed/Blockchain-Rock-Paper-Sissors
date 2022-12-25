// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract FedyaevHW4 {
    uint256 public someOfMoney = 0;

    struct PlayerOfGame {
        bytes32 move;
        address payable playerOfGameAddress;
        uint256 canStart;
        uint256 symbolOfGamePlayer;
    }

    PlayerOfGame playerOFGameFirst =
        PlayerOfGame(0x0, payable(address(0x0)), 1, 0);
    PlayerOfGame playerOfGameSecond =
        PlayerOfGame(0x0, payable(address(0x0)), 1, 0);

    event NewPlayerOfGameCome(address player);
    event PlayerSetSymbol(address player);
    event PlayerShowSymbol(address player, uint256 symbolOfGamePlayer);
    event PlayerMakeTransaction(address player, uint256 summ);

    modifier isReadyToPay() {
        require(
            (playerOFGameFirst.playerOfGameAddress == payable(address(0x0)) ||
                playerOfGameSecond.playerOfGameAddress ==
                payable(address(0x0))) &&
                (playerOFGameFirst.canStart == 1 ||
                    playerOfGameSecond.canStart == 1) &&
                (playerOFGameFirst.move == 0x0 ||
                    playerOfGameSecond.move == 0x0) &&
                (playerOFGameFirst.symbolOfGamePlayer == 0 ||
                    playerOfGameSecond.symbolOfGamePlayer == 0)
        );
        _;
    }

    modifier paySomeMoney() {
        require(msg.value > 0);
        _;
    }

    modifier canStartGame() {
        require(
            (playerOFGameFirst.playerOfGameAddress != payable(address(0x0)) &&
                playerOfGameSecond.playerOfGameAddress !=
                payable(address(0x0))) &&
                (playerOFGameFirst.symbolOfGamePlayer == 0 &&
                    playerOfGameSecond.symbolOfGamePlayer == 0) &&
                (playerOFGameFirst.move == 0x0 ||
                    playerOfGameSecond.move == 0x0) &&
                (playerOFGameFirst.canStart == 2 ||
                    playerOfGameSecond.canStart == 2)
        );
        _;
    }

    modifier checkCondition() {
        require(
            msg.sender == playerOFGameFirst.playerOfGameAddress ||
                msg.sender == playerOfGameSecond.playerOfGameAddress
        );
        _;
    }

    modifier canShowResults() {
        require(
            (playerOFGameFirst.symbolOfGamePlayer == 0 ||
                playerOfGameSecond.symbolOfGamePlayer == 0) &&
                (playerOFGameFirst.move != 0x0 &&
                    playerOfGameSecond.move != 0x0) &&
                (playerOFGameFirst.canStart == 3 ||
                    playerOfGameSecond.canStart == 3)
        );
        _;
    }

    modifier canPlayersPay() {
        require(
            (playerOFGameFirst.symbolOfGamePlayer != 0 &&
                playerOfGameSecond.symbolOfGamePlayer != 0) &&
                (playerOFGameFirst.move != 0x0 &&
                    playerOfGameSecond.move != 0x0) &&
                (playerOFGameFirst.canStart == 4 &&
                    playerOfGameSecond.canStart == 4)
        );
        _;
    }

    function puyNewPlayer()
        public
        payable
        isReadyToPay
        paySomeMoney
        returns (uint256)
    {
        if (playerOFGameFirst.canStart == 1) {
            if (playerOfGameSecond.canStart == 1) {
                someOfMoney = msg.value;
            } else {
                require(someOfMoney == msg.value, "invalid value");
            }
            playerOFGameFirst.playerOfGameAddress = payable(msg.sender);
            playerOFGameFirst.canStart = 2;

            emit NewPlayerOfGameCome(msg.sender);
            return 1;
        } else if (playerOfGameSecond.canStart == 1) {
            if (playerOFGameFirst.canStart == 1) {
                someOfMoney = msg.value;
            } else {
                require(someOfMoney == msg.value, "invalid value");
            }

            playerOfGameSecond.playerOfGameAddress = payable(msg.sender);
            playerOfGameSecond.canStart = 2;

            emit NewPlayerOfGameCome(msg.sender);
            return 2;
        }
        return 0;
    }

    function startingTheGame(bytes32 move)
        public
        canStartGame
        checkCondition
        returns (bool)
    {
        if (
            msg.sender == playerOFGameFirst.playerOfGameAddress &&
            playerOFGameFirst.move == 0x0
        ) {
            playerOFGameFirst.canStart = 3;
            playerOFGameFirst.move = move;
        } else if (
            msg.sender == playerOfGameSecond.playerOfGameAddress &&
            playerOfGameSecond.move == 0x0
        ) {
            playerOfGameSecond.canStart = 3;
            playerOfGameSecond.move = move;
        } else {
            return false;
        }

        emit PlayerSetSymbol(msg.sender);
        return true;
    }

    function showResults(uint256 symbolOfGamePlayer, string calldata call)
        public
        canShowResults
        checkCondition
        returns (bool)
    {
        if (msg.sender == playerOFGameFirst.playerOfGameAddress) {
            require(
                sha256(
                    abi.encodePacked(msg.sender, symbolOfGamePlayer, call)
                ) == playerOFGameFirst.move,
                "Failed to show results"
            );

            playerOFGameFirst.canStart = 4;
            playerOFGameFirst.symbolOfGamePlayer = symbolOfGamePlayer;

            emit PlayerShowSymbol(msg.sender, symbolOfGamePlayer);
            return true;
        } else if (msg.sender == playerOfGameSecond.playerOfGameAddress) {
            require(
                sha256(
                    abi.encodePacked(msg.sender, symbolOfGamePlayer, call)
                ) == playerOfGameSecond.move,
                "Failed to show results"
            );
            playerOfGameSecond.canStart = 4;
            playerOfGameSecond.symbolOfGamePlayer = symbolOfGamePlayer;

            emit PlayerShowSymbol(msg.sender, symbolOfGamePlayer);
            return true;
        }
        return false;
    }

    function makeResults()
        public
        canPlayersPay
        checkCondition
        returns (uint256)
    {
        if (
            playerOFGameFirst.symbolOfGamePlayer ==
            playerOfGameSecond.symbolOfGamePlayer
        ) {
            address payable playerOfGame1 = playerOFGameFirst
                .playerOfGameAddress;
            address payable playerOfGame2 = playerOFGameFirst
                .playerOfGameAddress;

            uint256 summ = someOfMoney;
            stopRPS();
            playerOfGame1.transfer(summ);
            playerOfGame2.transfer(summ);

            emit PlayerMakeTransaction(playerOfGame1, summ);
            emit PlayerMakeTransaction(playerOfGame2, summ);
            return 0;
        } else if (
            (playerOFGameFirst.symbolOfGamePlayer == 1 &&
                playerOfGameSecond.symbolOfGamePlayer == 3) ||
            (playerOFGameFirst.symbolOfGamePlayer == 2 &&
                playerOfGameSecond.symbolOfGamePlayer == 1) ||
            (playerOFGameFirst.symbolOfGamePlayer == 3 &&
                playerOfGameSecond.symbolOfGamePlayer == 2)
        ) {
            address payable playerWinner = playerOFGameFirst
                .playerOfGameAddress;
            uint256 summ = 2 * someOfMoney;
            stopRPS();

            playerWinner.transfer(summ);
            emit PlayerMakeTransaction(playerWinner, summ);
            return 1;
        } else {
            address payable playerWinner = playerOfGameSecond
                .playerOfGameAddress;
            uint256 summ = 2 * someOfMoney;
            stopRPS();
            playerWinner.transfer(summ);
            emit PlayerMakeTransaction(playerWinner, summ);
            return 2;
        }
    }

    function stopRPS() private {
        playerOFGameFirst = PlayerOfGame(0x0, payable(address(0x0)), 1, 0);
        playerOfGameSecond = PlayerOfGame(0x0, payable(address(0x0)), 1, 0);
        someOfMoney = 0;
    }
}
