// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

contract Escrow{
    address payable public buyer;
    address payable public seller;
    uint256 public price;

    bool public buyer_in;
    bool public seller_in;

    enum State{ UNINITIATED,AWAITING_PAYMENT,AWAITING_DELIVERY,COMPLETE }

    State public currentState;

    constructor(address _buyer,address _seller,uint256 _price){
        buyer = payable(_buyer);
        seller = payable(_seller);
        price = _price;
    }

    modifier inState(State expectedState){require(currentState == expectedState);_;}
    modifier correctPrice{require(msg.value == price);_;}
    modifier correctBuyer{require(msg.sender == buyer);_;}

    function initialContract() public correctPrice inState(State.UNINITIATED) payable{
        if(msg.sender == buyer){
            buyer_in = true;
        }
        if(msg.sender == seller){
            seller_in = true;
        }
        if(buyer_in && seller_in){
            currentState = State.AWAITING_PAYMENT;
        }
    }

    function confirmPayment() public correctPrice correctBuyer inState(State.AWAITING_PAYMENT) payable{
        currentState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() public correctBuyer inState(State.AWAITING_DELIVERY){
        seller.transfer(price * 2);
        buyer.transfer(price);
        currentState = State.COMPLETE;
    }

}
