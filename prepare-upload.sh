#! /bin/sh -ex

REV=`git log -1 --format="%H" | cut -c1-10`

# build
#mvn clean cobertura:cobertura package

rm -rf upload
mkdir -p upload

# site docs
cp -r site/* upload/

# coverage reports
mkdir -p upload/files/coverage
echo "<html><head>" > upload/files/coverage/index.html
echo "<title>Code Coverage Reports for JMeter-Plugins.org</title>" >> upload/files/coverage/index.html
echo "</head><body>" >> upload/files/coverage/index.html
echo "<h1>Code Coverage Reports for JMeter-Plugins.org, revision $REV</h1>" >> upload/files/coverage/index.html
echo "<ul style='font-size: x-large'>" >> upload/files/coverage/index.html

for D in `ls` ; do
    if [ -d $D/target/site/cobertura ] ; then
        cp -r $D/target/site/cobertura upload/files/coverage/$D
	echo "<li><a href='$D'>$D</a></li>" >> upload/files/coverage/index.html
    fi
done
echo "</ul>" >> upload/files/coverage/index.html
echo "</body><html>" >> upload/files/coverage/index.html

# package snapshots
mkdir -p upload/files/nightly

for D in `ls` ; do
    if ls $D/target/*-*.zip 2>/dev/null ; then
        cp $D/target/*-*.zip upload/files/nightly/
    fi
done

cd manager/target/jpgc-repo
zip -vr ../../../upload/files/nightly/jmeter-plugins-all.zip .
cd ../../../

cp manager/target/jmeter-plugins-manager-*.jar upload/files/nightly/

rename "s/.jar/_$REV.jar/" upload/files/nightly/*.jar
rename "s/.zip/_$REV.zip/" upload/files/nightly/*.zip

# examples
cp -r examples upload/img/

curl -sS https://getcomposer.org/installer | php
cd upload
../composer.phar update --no-dev --prefer-stable
cp vendor/undera/pwe/.htaccess ./
cd ..

cd upload
zip -r site.zip * .htaccess
cd ..