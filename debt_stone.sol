pragma solidity ^0.4.17;

contract DebtStones {
    
    struct PersonStruct {
        uint loan;
        uint debt;
        uint debt_requests;
    }
    
    struct FinanceInformation {
        uint amount;
        uint paid;
    }
    
    mapping (address => mapping(address => uint)) activeContracts;
    mapping (address => mapping(address => uint)) queueRequestsForReturnDebt;
    
    mapping (address => mapping(address => FinanceInformation)) debt_stone;
    mapping (address => PersonStruct) users;
    
    event EventSentRequest(address debtor, address creditor, uint amount);
    event EventApprouveDebt(address debtor, address creditor, uint amount);
    event EventSentRequestForReturnDebt(address debtor, address creditor, uint amount);
    event EventApprouveReturnDebt(address debtor, address creditor, uint amount);
    
    function requestMoneyInDebt(address creditor, uint amount) public returns(bool) {
        
        if(amount == 0){
            return false;
        }
        
        address debtor = msg.sender;
        
        //Checking this request in queue
        if(
            activeContracts[debtor][creditor] == 0 &&
            amount > 0
        ){
            users[debtor].debt_requests++;
            activeContracts[debtor][creditor] = amount;
            
            EventSentRequest(debtor, creditor, amount);
            return true;
        }
        
        return false;
        
    }
    
    function approuveDebt(address debtor, uint amount) public returns(bool){
        
        address creditor = msg.sender;
        
        if(
            activeContracts[debtor][creditor] > 0 &&
            activeContracts[debtor][creditor] == amount
        ){
            EventApprouveDebt(debtor, creditor, amount);
            users[debtor].debt += amount;
            
            debt_stone[debtor][creditor].amount += amount;
            return true;
        }
        
        return false;
    }
    
    function requestMoneyReturnDebt(address creditor, uint amount) public returns (bool){
        
        address debtor = msg.sender;
        
        if(
            activeContracts[debtor][creditor] > 0 && 
            queueRequestsForReturnDebt[debtor][creditor] == 0 && 
            activeContracts[debtor][creditor] <= amount
        ){
            EventSentRequestForReturnDebt(debtor, creditor, amount);
            queueRequestsForReturnDebt[debtor][creditor] = amount;
            return true;
        }
        
        return false;
    }
    
    function approuveReturnDebt(address debtor, uint amount) public returns(bool) {
        address creditor = msg.sender;
        
        if(
            activeContracts[debtor][creditor] > 0 && 
            queueRequestsForReturnDebt[debtor][creditor] > 0 &&
            activeContracts[debtor][creditor] <= amount
        ){
            delete queueRequestsForReturnDebt[debtor][creditor];
            users[debtor].loan += amount;
            debt_stone[debtor][creditor].paid += amount;
            
            EventApprouveReturnDebt(debtor, creditor, amount);
            return true;
        }
        
        return false;
        
    }
    
    
    function getTotalLoan(address user) public view returns (uint){
        return users[user].loan;
    }
    
    function getTotalDebt(address user) public view returns (uint){
        return users[user].debt;
    }
    
    function getTotalDebtRequests(address user) public view returns (uint){
        return users[user].debt_requests;
    }
}
