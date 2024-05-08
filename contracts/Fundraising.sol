// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Fundraising{
    uint public targetAmount;
    address public owner; ///캠페인이 성공하면 자금을 보낼 Owner의 지갑 주소. string이 아님!!
    mapping(address=>uint256) public donations; ///기부한 사람의 주소와 액수를 매핑할 자료형
    uint256 public raisedAmount = 0; ///Owner가 모금한 금액
    uint256 public finishTime = block.timestamp + 2 weeks;

    constructor(uint256 _targetAmount){
        targetAmount = _targetAmount; ///컨트랙을 배포할 때 Owner가 Target Amount(모금하고자 하는 금액)을 명시하도록 하겠다는 뜻.
        owner = msg.sender; ///해당 컨트랙을 작성하는 자의 주소
    }
    receive()external payable{
        require(block.timestamp < finishTime, "This campaign is over.");
        donations[msg.sender] += msg.value;
        raisedAmount += msg.value;
    } ///후원한 사람의 이름과 금액을 EOA와 컨트랙 코드 상 거래 시 동시에 저장할 수 있게끔 하는 함수 "payable"은 돈을 받을 수 있다는 뜻, "external"은 외부로부터 수행될 수 있는 함수
    ///즉 누군가가 우리의 컨트랙으로 돈을 보내면 receive()함수가 실행된다.
    function withDrawFunction() external{
        require(msg.sender == owner, "Funds will only be released to the owner."); ///함수를 호출하는 사람이 컨트랙 제작자인지?
        require(raisedAmount >= targetAmount, "The project did not reach the goal."); ///모금액이 목표금액을 넘었는지?
        require(block.timestamp > finishTime, "campaign is not over yet.");
        payable(owner).transfer(raisedAmount);
    }
    function refund() external{
        require(block.timestamp > finishTime, "The campaign is not over yet."); ///캠페인이 끝난 경우
        require(raisedAmount < targetAmount, "The campaign reached the goal."); ///모금액을 달성한 경우
        require(donations[msg.sender] > 0, "You did not tonate to this campaign."); ///환불을 요청하는 유저가 실제로 기부했다면
        uint256 toRefund = donations[msg.sender]; ///유저가 기부한 금액을 변수 안에 넣고
        donations[msg.sender] = 0; /// 두 번 환불을 요청할 수 없도록 하면 된다.
        payable(msg.sender).transfer(toRefund);
    }
}