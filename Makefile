

build:
	npm run mkbin
	# add node shebang to ./bin/index.js
	echo '#!/usr/bin/env node' | cat - ./bin/index.js > temp && mv temp ./bin/index.js

