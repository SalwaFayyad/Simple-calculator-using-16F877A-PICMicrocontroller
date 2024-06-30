# Simple-calculator-using-16F877A-PICMicro
This project, designated as the 3rd project within the Real-Time Applications & Embedded Systems course (ENCS4330), focuses on the development of a simple calculator system implemented on embedded systems. Specifically designed to demonstrate practical applications of real-time computing concepts and embedded system design principles.
### In the dedicated branch for this project within the repository, you will find the master assembly files and the co-processor assembly files.

## Description
The project aims to create a basic calculator capable of performing multiplication operations on integer numbers. The calculator is hardware-based and uses two 16F877A microcontrollers - one as the master CPU and the other is co-processor. Additionally, it includes a push button (P) for number input and a 16×2 character LCD for display, both connected to the master CPU.
### How the program work!
The program initiates by presenting a welcoming message on the LCD screen, which blinks three times, each blink lasting for 2 seconds, providing a visually engaging start. Following this, the user is prompted to input the first number. Utilizing a push button, the user incrementally inputs the number, with the cursor guiding the input position on the LCD screen. A deliberate 2-second pause between button clicks ensures ample time for accurate input. 
- Concurrently, USART communication is established between the PIC microcontrollers, with data being transmitted from the transmitting microcontroller's TX pin to the receiving microcontroller's RX pin. This communication protocol facilitates seamless exchange of data between the microcontrollers.
- Once the first number is confirmed, the program prompts the user to input the second number, following the same process as before. Throughout the interaction, the program maintains a user-friendly approach, providing clear instructions and allowing sufficient time for accurate input, ultimately ensuring a smooth and reliable experience for the user.
#### Notes 😄

- The LED added to the co-processor serves as a visual indicator of communication status between the two microcontrollers. When the system starts up, the LED indicates readiness. During multiplication operations, the LED blinks or changes its state to confirm successful data exchange. Any irregularities in LED behavior signal potential communication errors, prompting corrective actions. This simple addition enhances system reliability by providing real-time feedback on communication, ensuring smoother operation.
- Download the zip file and try our multiplication :)
![image](https://github.com/SalwaFayyad/Simple-calculator-using-16F877A-PICMicrocontroller/assets/104863637/61c0e455-8e11-4215-a45f-8df459588f9f)
![image](https://github.com/SalwaFayyad/Simple-calculator-using-16F877A-PICMicrocontroller/assets/104863637/06dafa22-cf6d-4b42-b9ec-7fa173c8c128)
