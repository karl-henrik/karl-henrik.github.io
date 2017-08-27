---
layout: post
title: "Getting started with NodeMCU"
date: 2016-06-12 13:37:00 +0200
categories: NodeMCU Devices Electronics
comments: true

---

At the time I’m writing this I am at NDC Oslo were I did a few sessions on IoT. During one of the sessions I used a NodeMCU to demonstrate my points and when I also saw one of the exhibits handing them out I thought it could be a great time to share my getting started guide for **NodeMCU**.

![alt text]({{ site.url }}/images/nodemcu_tretton37_package.jpg)

To follow along this guide you are going to need the following things

1. DS20B18 temperature sensor (optional for this post)
2. NodeMCU ESP8266 development board
3. Blue LED
4. Breadboard so we don’t have to solder stuff when we are experimenting!

##### Note: If you are using a Mac Book Pro see trouble shooting to find drivers

### The breadboard
 
![alt text]({{ site.url }}/images/breadboard_demo.png)

The breadboard is nothing more than a plastic brick with holes in it that are connected in a specific pattern. The columns labelled + and – are all connected (long yellow rectangle) and is designed to be used for VCC and GND (power). The rows 1 to 30 are connected (the small yellow rectangle) up until the groove and the columns marked a,b,c and and so forth (the red rectangle) are not connected.

This allows us to use the breadboard as a simple “circuit board” to test small circuits without soldering or creating actual circuit boards.

 
### Mounting the hardware

![NodeMCU Closeup]({{ site.url }}/images/nodemcu_mounted_temp.png)

Placing the NodeMCU into the breadboard can be a bit tricky, especially if the board is new but keep an even pressure over the pin edge and it should work. The same goes for mounting the temperature sensor as its legs can be rather fragile so be gentle while mounting them.

Insert the NodeMCU unit (see image) into the breadboard as far left as you can – the entire pin row labelled D0,D1,D2 etc should be inserted into column A.

On the Temperature Sensor, make sure that temperature sensor pin marked “-“ (marked with a minus sign) that is closest to you in the picture is connected to the NodeMCU pin marked **G**, that the centre pin is connected to the NodeMCU pin marked **3V** and that the sensor pin marked **S**, the pin furthest away from you in the picture is connected to **D4**.

On the LED insert the longest leg on the LED into a hole that is connected to **D8** on the NodeMCU.
Then connect the short leg on the LED to a hole that is connected to the adjacent pin on the NodeMCU marked **G**
 

![nodemcu_close_up]({{ site.url }}/images/nodemcu_closeup_temp_led.png)

### Programming the device
The device can be programmed with many tools, my favorit being Visual Studio Code, but in this example we will use the Arduino editor.

The first step we need to do is to add the tools for NodeMCU to the Arduino IDE. Download Arduino IDE from Arduino.cc (1.6.4 or greater) – don’t use 1.6.2! You can use your existing IDE if you have already installed it. You can also try downloading the ready-to-go package from the ESP8266-Arduino project.

When this is done we need to install the ESP8266 Board Package. Enter “http://arduino.esp8266.com/stable/package_esp8266com_index.json” (without the quotes) into Additional Board Manager URLs field in the Arduino IDE preferences.  (Arduino -> Preferences -> Settings -> Additional Boards Manager)

![arduino settings]({{ site.url }}/images/nodemcu_arduino_settings.png)

After you have done that, go into the board manager (Tools -> Board: -> Board Manager) and search for ESP8266 and install that.

![boards manager]({{ site.url }}/images/nodemcu_board_manager.png)

Now all we have left to do is to setup the Arduino IDE to work with the NodeMCU. In the Arduino editor select Tools – Board -> NodeMCU 1.0 (ESP-12E Module) also make sure that the CPU Frequency is set to 80 Mhz. Then navigate to Port and select the port were the NodeMCU is connected, should you not see the port reboot your computer to finalize the driver installation.

![select nodemcu]({{ site.url }}/images/nodemcu_arduino_select.png)
 

### Testing it out!
Alright, so now we have done all we need to be able to program the device, let’s test it out! When programming, the first example that you do is often Hello World – a simple program that writes Hello World! to your screen. The microprocessor worlds version of Hello World is called Blink a Led so let’s to do that.


``` cpp
void setup()
{
	pinMode(D8,OUTPUT);
}

void loop()
{
	digitalWrite(D8, true);
	delay(500);
	digitalWrite(D8, false);
	delay(500);
}
```
If you did everything right, and I wrote everything correctly your LED should now be blinking! In my next post I will go into detail on how you can read the temperature from the sensor and host a small web server to show the temperature! Please send me comments if you find anything that does not work or should be improved upon!
