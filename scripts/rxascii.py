import serial, time

tty = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=7, parity='N', stopbits=1)

while True:
    val = tty.readline()

    try:
        print(val.decode('ascii'), end='')

    except UnicodeDecodeError:
        print("Could not decode: {}".format(val))
        


tty.close()
