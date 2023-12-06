# DEXTERITY DASH - Hand-Eye Coordination Tool - ECE241 Final Project
![E3297C0F-8B77-4BE0-AE88-34E51D8D0A61](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/d2fbda56-f730-4d2a-b3b5-2ded85dea539)
![68E11417-B646-413E-A382-EA41B3BA177F](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/66e1e866-d1dc-40f4-9479-f86caae3ffe6)




## Table of Contents

- [Introduction](#introduction)
- [Project Overview](#project-overview)
- [Hardware Setup](#hardware-setup)
- [Electrical Setup](#electrical-setup)
- [Software Setup](#software-setup)
- [Game Rules](#game-rules)
- [Project Structure](#project-structure)
- [Early Work](#early-work)

## Introduction

Welcome to the homepage of Dexterity Dash, a hand-eye coordination tool/game aiming to make training hand-eye coordination fun for those suffering from head trauma and brain injury. This engineering project aims to develop a hand-eye coordination game using the DE1-SoC FPGA board, Verilog for coding, and ModelSim for testing. The game enhances users' hand-eye coordination by requiring them to press illuminated buttons in a specific sequence within a time limit to score points.

## Project Overview

The primary goal of this project is to create a hand-eye coordination game. The DE1-SoC board, Quartus for Verilog coding, and ModelSim for testing are utilized to implement the game's logic. The game involves pressing one of 8 buttons that light up, and after each correct press, another button lights up. A default timer of 30 seconds challenges users to press as many correct buttons as possible to score the most points.

## Hardware Setup
### Solidworks model
![CAD 1](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/f7df1696-e6b6-4c69-ba0a-03a0627b2064)
Using solidworks, I created a comprehensive model of the game controller to ensure that all buttons are non-intersecting and ground clearance as well as screw clearance was accounted for.
### Construction Process
![9AA2A3A4-0FB5-4169-84FB-7F2263EB5E28](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/a0b8ed86-4258-477e-87aa-f8ff49a13bfe)
Using a Miter Saw, Drill press, and impact driver, we assembled the gameboard according to the Solidworks model.

![AEA7F85D-6630-497D-BC20-0A685D175983](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/7032171e-aac6-40be-a4d5-aa7db427167f)
After the wooden chassis was complete, we installed the buttons and LEDs to complete the mechanical aspect of the gameboard.

## Electrical Setup
### Circuit Schematic to be implemented on the breadboard
![image](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/d1be5c0d-4030-4d48-967f-dfd04706f4c5)
Using KiCad I created a schematic of the electrical system that had to be implemented to allow the FPGA to interact with the buttons and switches.

![download](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/3cbf9fd6-6ed5-401e-8441-873fb6a83798)
![486B255D-B9AB-4188-B3D1-C4E8ACC050CD](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/e878659e-f6ae-4cb4-bc1c-b90ef3d461d8)
![7FF55709-1F49-4A41-8A71-BEF448E0833A](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/18eb1549-8e2a-45c8-859b-1432bd40856f)
To ensure rapid production and prototyping, I used a breadboard to assemble the circuit show in the schematic, colour coding wires to allow for easy installation, debugging, and removall of wires. 

## Software Setup

Provide details on the software setup, including the use of Quartus for Verilog coding and ModelSim for testing. Include any specific configurations or settings required for the DE1-SoC board.

## Game Rules

Explain the rules of the hand-eye coordination game. Detail the button-press sequence, scoring mechanism, and the 1-minute time limit. Emphasize how the game helps users develop and enhance their hand-eye coordination skills.

## Project Structure

Outline the structure of the project's Verilog code. Describe the key modules and their functionalities, emphasizing the use of a Finite State Machine (FSM) to control the game flow.


## Early Work

Here is some of our early brainstorming and planning
![Rough Ideas-2](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/7637ecab-5271-4fc5-9616-c386ab64fb24)
![Rough Ideas-5](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/759b956e-619e-44e8-87f6-42791fa8c6ff)
![Rough Ideas-4](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/109dee0e-25c8-44a1-8a31-aed0b86b4f8c)
![schematic draft 1](https://github.com/Aryan-G4/Dexerity-Dash/assets/119129454/41fa3722-5c84-4e2a-90aa-90ec15a28713)






