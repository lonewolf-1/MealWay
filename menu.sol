// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract schoolMenu{
    /*TYPE DECLARATION*/
    // Mapping created to store the food names 
    mapping(uint8 => string) public foodNames;
    // Mapping created to store food prices
    mapping(uint8 => uint8) public foodPrices;

    /* CONSTRUCTOR */
    constructor(){
        // setting item names and price
        foodNames[0] = "Burger";
        foodNames[1] = "Pizza";
        foodNames[2] = "Chicken";
        foodNames[3] = "Sandwich";
        foodNames[4] = "Fish";

        foodPrices[0] = 1; //Price for Burger
        foodPrices[1] = 2; //Price for Pizza
        foodPrices[2] = 4; //Price for Chicken
        foodPrices[3] = 3; //Price for Sandwich
        foodPrices[4] = 4; //Price for Fish
    }

    /* FUNCTIONS */
    // function which returns the food names and prices
    function getFoodMenu() public view returns (string[5] memory, uint8[5] memory){
        string[5] memory foodItemNames; 
        uint8[5] memory footItemPrices; 
        for (uint8 i = 0; i < 5; i++){
            foodItemNames[i] = foodNames[i];
            footItemPrices[i] = foodPrices[i];
        }
        return (foodItemNames, footItemPrices);
    }

    // function to only get the price of a food item
    function getFoodPrice(uint8 _itemId) public view returns (uint8) {
        require(_itemId < 5, "Invalid item ID");
        return foodPrices[_itemId];
    }

}


