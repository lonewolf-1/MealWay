// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//Importing the contents of "menu.sol"
import "./menu.sol";


contract students{
    /*TYPE DECLARATION*/
    //mapping with students wallet address
    mapping(address => Student) public studentAddressMap;
    //mapping to check if student is already signed up
    mapping(address => bool) public isStudentRegistered;    
    //composition
    schoolMenu public Menu ;
    //defining the datatype to be stored in Student
    struct Student {
        address studentID;
    }

    /* EVENTS */
    // Event to log the addition of a new student
    event StudentAdded(address indexed studentID);

    /* CONSTRUCTOR */
    constructor(){
        //new instance of the schoolMenu class created
        Menu = new schoolMenu();  
    } 

    /* FUNCTIONS */
    //creates student and adds them to the map, wallet address is the student ID
    function addStudent() external  {
        //setting sender's address as studentID
        address _studentID = msg.sender; 

        //checks if a student is already registered
        require(!isStudentRegistered[_studentID], "Student already exists");

        //creates a new Student struct and initialises with the provided studentID
        Student memory newStudent = Student(_studentID);

        //adds the new student to the mapping
        studentAddressMap[_studentID] = newStudent;

        //marks the student as registered
        isStudentRegistered[_studentID] = true;

        emit StudentAdded(_studentID);

    }
    
    //calling Menu function from an external contract
    function retrieveMenu() public view returns(string[5] memory, uint8[5] memory){
        return Menu.getFoodMenu();
    }
    
}