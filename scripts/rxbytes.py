import serial, time

tty = serial.Serial('/dev/ttyUSB0', baudrate=38400, stopbits=1)

while True:
    val = tty.read(1)
    # c = str(val.decode('ascii'))
    # print(c, end='', flush=True)
    print(str(hex(val[0])) + " " + str(val[0]))
    # print(str(val[0]))

tty.close()
