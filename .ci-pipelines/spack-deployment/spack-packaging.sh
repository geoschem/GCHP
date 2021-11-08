# this script is intended to update the GCHP package on spack 
# with the release of a new GCHP version
# Note: this will only modify updating the source code
# updating additional dependencies will require manual editting

echo $GH_ACCESS_TOKEN > token.txt

cd GCHP
# first we get the commit hash
git fetch --all --tags
git checkout $VERSION_TAG
COMMIT_HASH=$(git rev-list -n 1 $VERSION_TAG)
echo "creating spack package for version $VERSION_TAG with gchp hash: $COMMIT_HASH"
TAR_URL="https://github.com/geoschem/GCHP/archive/$VERSION_TAG.tar.gz"
echo "gchp spack package will fetch package from: $TAR_URL"
VERSION_STRING="version('$VERSION_TAG', commit='$COMMIT_HASH',  submodules=True)"
BRANCH="gchp-$VERSION_TAG"


cd ../home/spack
git pull
gh auth login < /token.txt
gh repo fork --remote=true --org=geoschem --clone=false
git checkout -b $BRANCH

# replace the tarball link to new version
sed -i "s|https://github.com/geoschem/GCHP/archive/.*.gz|$TAR_URL|" var/spack/repos/builtin/packages/gchp/package.py
# add new line to version history
sed -i "1,/version(.*/s//$VERSION_STRING\n    &/" var/spack/repos/builtin/packages/gchp/package.py

spack style
git commit -m "gchp: added version $VERSION_TAG"
git push -u origin $BRANCH
# gh pr create --title "gchp: added version $VERSION_TAG" --base spack:develop --repo spack/spack


