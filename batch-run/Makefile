.SUFFIXES: .eps .pdf .fig .gp .mlst .tar.gz .list .decisions.list .nclauses.list .vars.list .time.list .tsolvertpdecs.list _decisions.gp _nclauses.gp _vars.gp _time.gp _tsolvertpdecs.gp .compute

osmt2decs=osmt_1_vs_2/bin/extract_results_decisions_osmt2.sh
osmt2ncls=osmt_1_vs_2/bin/extract_results_nclauses_osmt2.sh
osmt2nvar=osmt_1_vs_2/bin/extract_results_vars_osmt2.sh
osmt2time=osmt_1_vs_2/bin/extract_results_time_osmt2.sh
osmt2tstd=osmt_1_vs_2/bin/extract_results_tsolvertpdecs_osmt2.sh

scdecs=bin/make_scatterplot_decisions.py
scncls=bin/make_scatterplot_nclauses.py
scnvar=bin/make_scatterplot_vars.py
sctime=bin/make_scatterplot_time.py
sctstd=bin/make_scatterplot_tsolvertpdecs.py

all:
	pdflatex main
	bibtex main
	pdflatex main
	pdflatex main

.fig.eps: %.fig macros.tex
	fig2dev -L pstex $< $*.pstex
	fig2dev -L pstex_t -p $*.pstex $< $*.pstex_t
	./pstex2eps.sh $*
	rm -f $*.pstex $*.pstex_t

.gp.eps: %.gp %.list macros.tex
	gnuplot $<
	latex $*.tex
	dvips -o $*.eps `basename $*`.dvi
	rm -f `basename $*`.{dvi,aux,log,out} $*.tex $*-inc.eps


.eps.pdf: %.eps
	./epstopdf $*.eps

.tar.gz.compute: %.tar.gz %_decisions.pdf %_nclauses.pdf %_vars.pdf %_time.pdf %_tsolvertpdecs.pdf

.tar.gz.decisions.list:
	$(osmt2decs) $* > $*.decisions.list

.tar.gz.nclauses.list:
	$(osmt2ncls) $* > $*.nclauses.list

.tar.gz.vars.list:
	$(osmt2nvar) $* > $*.vars.list

.tar.gz.time.list:
	$(osmt2time) $* > $*.time.list

.tar.gz.tsolvertpdecs.list:
	$(osmt2tstd) $* > $*.tsolvertpdecs.list

.decisions.list_decisions.gp:
	$(scdecs) `dirname $*`/results-osmt1-decisions.list $*.decisions.list 'osmt1' "`basename $* |sed 's/osmt2-results-\([1-9][0-9]*-[0-9][0-9]-[0-9][0-9][a-z]*\)-/\1/g'`" $*_decisions.tex > $*_decisions.gp

.nclauses.list_nclauses.gp:
	$(scncls) `dirname $*`/results-osmt1-nclauses.list $*.nclauses.list 'osmt1' "`basename $* |sed 's/osmt2-results-\([1-9][0-9]*-[0-9][0-9]-[0-9][0-9][a-z]*\)-/\1/g'`" $*_nclauses.tex > $*_nclauses.gp

.vars.list_vars.gp:
	$(scnvar) `dirname $*`/results-osmt1-vars.list $*.vars.list 'osmt1' "`basename $* |sed 's/osmt2-results-\([1-9][0-9]*-[0-9][0-9]-[0-9][0-9][a-z]*\)-/\1/g'`" $*_vars.tex > $*_vars.gp

.time.list_time.gp:
	$(sctime) `dirname $*`/results-osmt1-time.list $*.time.list 'osmt1' "`basename $* |sed 's/osmt2-results-\([1-9][0-9]*-[0-9][0-9]-[0-9][0-9][a-z]*\)-/\1/g'`" $*_time.tex > $*_time.gp

.tsolvertpdecs.list_tsolvertpdecs.gp:
	$(sctstd) `dirname $*`/results-osmt1-tsolvertpdecs.list $*.tsolvertpdecs.list 'osmt1' "`basename $* |sed 's/osmt2-results-\([1-9][0-9]*-[0-9][0-9]-[0-9][0-9][a-z]*\)-/\1/g'`" $*_tsolvertpdecs.tex > $*_tsolvertpdecs.gp


