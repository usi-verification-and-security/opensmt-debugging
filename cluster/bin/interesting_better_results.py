import sys
import re


def main(args):
	res = ""
	f = open(args[0], "r")
	line = f.readline()
	reg_exp = "[0-9\.]+ [0-9\.]+ #.*"
	while line:
		print(line)
		if re.match(reg_exp, line):
			data = line.split()
			x = float(data[0])
			y = float(data[1])
			if x >= 2*y :
				res = res + str(x) + " " + str(y) + " " + data[3] + "\n"
		line = f.readline()
	print(res)

if __name__ == '__main__':
	main(sys.argv[1:])
