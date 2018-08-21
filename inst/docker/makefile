runInShell:
	R -f runCyjShinyInBackground.R

runInBackground:
	nohup R -r runCyjShinyInBackground.R &


build:
	docker build -t cyjshinydemo -f Dockerfile .

bash:
	docker run -ti --rm -p 60040:3838 cyjshinydemo bash

dockerRun:
	docker run -p 60042:3838 cyjshinydemo

