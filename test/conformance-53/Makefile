TMPDIR=${PWD}/tmp
CWL=cwl/revsort.cwl
JOB=cwl/revsort-job.json

all: test

test: cwl_log.json
	../compare_json.rb expected.json cwl_log.json && echo ok.

cwl_log.json: cwltool.log
	../../generate_cwl_log --docker-ps ${TMPDIR}/ps-file --docker-info ${TMPDIR}/info-file --debug-output cwltool.log --output-dir . --cidfile-dir ${TMPDIR}

cwltool.log:
	mkdir ${TMPDIR}
	cwltool --debug --leave-container --timestamps --compute-checksum --record-container-id --cidfile-dir ${TMPDIR} --outdir ${TMPDIR} ${CWL} ${JOB} > /dev/null 2> cwltool.log
	docker info > ${TMPDIR}/info-file
	docker ps -a --no-trunc > ${TMPDIR}/ps-file

clean:
	rm -rf ${TMPDIR} cwl_log.json cwltool.log
