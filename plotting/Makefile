.SUFFIXES: .eps .pdf .gp .list .png

epstopdf?=./bin/epstopdf

.gp.png: %.gp %.list
	gnuplot $<
#	latex $*.tex
#	dvips -o $*.eps `basename $*`.dvi
#	rm -f `basename $*`.{dvi,aux,log,out} $*.tex $*-inc.eps


.eps.pdf: %.eps
	$(epstopdf) $*.eps

