#!/usr/bin/env sh

# Optional environment variables:
#   - JAVA_OPTS     Aditional Java options

if [ $# -eq 1 ]; then
	# if only has one arguments, we assume user is running alternate command like `bash` to inspect the image
	exec "$@"
else
    exec java $JAVA_OPTS -jar $APP_JAR "$@"
fi
