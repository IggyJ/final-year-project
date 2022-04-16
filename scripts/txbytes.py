import serial, time

tty = serial.Serial('/dev/ttyUSB0', baudrate=9600, bytesize=8, parity='N', stopbits=1)

# time.sleep(1)

val = int.to_bytes(0x0f, 1, 'little')
print(val)
tty.write(val)

time.sleep(1)

tty.close()
