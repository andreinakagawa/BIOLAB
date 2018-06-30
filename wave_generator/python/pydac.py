import numpy as np
from serial import Serial
import matplotlib.pyplot as plt
import time

def conv(xv,xmin,xmax):
	ymin = 0
	ymax = 4095
	yv = (((xv-xmin)*(ymax-ymin))/(xmax-xmin)) + ymin
	return int(yv)

emg = np.loadtxt('aquisicao1.txt')
emgr = np.zeros(emg.shape)
pkg_st = 0x24
pkg_et = 0x21

baud = 115200
s = Serial('/dev/tty.usbmodem1421',baud)
time.sleep(1)

package = [None]*4
package[0] = pkg_st
package[-1] = pkg_et

for k in range(np.size(emg,0)):
	#print(np.min(emg),np.max(emg))
	#print(conv(emg[k],np.min(emg),np.max(emg)))
	emgr[k] = conv(emg[k],np.min(emg),np.max(emg))
	package[1] = int(emgr[k])>>8
	package[2] = int(emgr[k])&0xff
	#print(package[1],package[2])
	#print(emgr[k])
	#s.write(bytearray(package))	
	#time.sleep(0.0005)

i0 = 9000
i1 = 13000
for i in range(10):
	for k in range(i0,i1,1):
		package[1] = int(emgr[k])>>8
		package[2] = int(emgr[k])&0xff
		s.write(bytearray(package))
		time.sleep(0.001)

plt.figure()
plt.plot(emgr)
plt.show()
