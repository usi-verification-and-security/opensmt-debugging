import sys
import re



def main(args):
	res = ""
	f = open(args[0], "r")
	line = f.readline()
	while line:
		print(line)
		data = line.split()
		if len(data) > 2:
			x = float(data[2])
			res = res + str(x) + "\n"
		line = f.readline()
	print(res)

if __name__ == '__main__':
	main(sys.argv[1:])
