#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.

set -ex

function usage() {
    echo "Usage: $0 [args]"
    echo ""
    echo "Arguments:"
    echo -e "-v VERSION\t[Required] OpenSearch version."
    echo -e "-q QUALIFIER\t[Optional] Build qualifier."
    echo -e "-s SNAPSHOT\t[Optional] Build a snapshot, default is 'false'."
    echo -e "-p PLATFORM\t[Optional] Platform, ignored."
    echo -e "-a ARCHITECTURE\t[Optional] Build architecture, ignored."
    echo -e "-o OUTPUT\t[Optional] Output path, default is 'artifacts'."
    echo -e "-h help"
}

while getopts ":h:v:q:s:o:p:a:" arg; do
    case $arg in
        h)
            usage
            exit 1
            ;;
        v)
            VERSION=$OPTARG
            ;;
        q)
            QUALIFIER=$OPTARG
            ;;
        s)
            SNAPSHOT=$OPTARG
            ;;
        o)
            OUTPUT=$OPTARG
            ;;
        p)
            PLATFORM=$OPTARG
            ;;
        a)
            ARCHITECTURE=$OPTARG
            ;;
        :)
            echo "Error: -${OPTARG} requires an argument"
            usage
            exit 1
            ;;
        ?)
            echo "Invalid option: -${arg}"
            exit 1
            ;;
    esac
done

if [ -z "$VERSION" ]; then
    echo "Error: You must specify the OpenSearch version"
    usage
    exit 1
fi

[[ ! -z "$QUALIFIER" ]] && VERSION=$VERSION-$QUALIFIER
[[ "$SNAPSHOT" == "true" ]] && VERSION=$VERSION-SNAPSHOT
[ -z "$OUTPUT" ] && OUTPUT=artifacts

mkdir -p $OUTPUT/maven
mkdir -p $OUTPUT/plugins

cd notifications
./gradlew publishToMavenLocal -PexcludeTests="**/SesChannelIT*" -Dopensearch.version=$VERSION -Dbuild.snapshot=$SNAPSHOT -Dbuild.version_qualifier=$QUALIFIER
./gradlew assemble --no-daemon --refresh-dependencies -DskipTests=true -Dopensearch.version=$VERSION -Dbuild.snapshot=$SNAPSHOT -Dbuild.version_qualifier=$QUALIFIER
cd ..

mkdir -p $OUTPUT/plugins

notifCoreZipPath=$(find . -path \*core/build/distributions/*.zip)
distributions="$(dirname "${notifCoreZipPath}")"
echo "COPY ${distributions}/*.zip"
cp ${distributions}/*.zip ./$OUTPUT/plugins

notifZipPath=$(find . -path \*notifications/build/distributions/*.zip)
distributions="$(dirname "${notifZipPath}")"
echo "COPY ${distributions}/*.zip"
cp ${distributions}/*.zip ./$OUTPUT/plugins