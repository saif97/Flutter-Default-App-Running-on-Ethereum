pragma solidity >=0.4.22 <0.9.0;

contract Counter {
    uint256 public counter = 0;

    function increment() public {
        counter++;
        emit CounterIncremented(counter);
    }


    event CounterIncremented(
        uint counter
    );
}
