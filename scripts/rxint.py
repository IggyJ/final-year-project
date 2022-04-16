import serial, time

tty = serial.Serial('/dev/ttyUSB0', baudrate=9600, stopbits=1)

while (tty.read(1)[0] == 255):
        pass

while True:
    val = tty.read(4)
    print(int.from_bytes(val, 'little', signed=False), flush=True)

tty.close()
