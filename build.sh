# pip3 uninstall pycurl
# brew install openssl
# bash build.sh develop
set -ex

openssl_dir="${openssl_dir:-$(brew --prefix openssl@3)}"

#curl_dir="$(brew --prefix curl)"

# ImportError: pycurl: libcurl link-time version (7.85.0) is older than compile-time version (7.87.0)
# so let's download that version directly.
# ref: https://stackoverflow.com/questions/37812070/mac-os-importerror-pycurl-libcurl-link-time-version-7-37-1-is-older-than-com
curl_version="${curl_version:-7.85.0}"

if [ ! -d curl-$curl_version/install ]
then
  wget https://curl.haxx.se/download/curl-$curl_version.tar.bz2 -O curl-$curl_version.tar.bz2
  tar -xf curl-$curl_version.tar.bz2
  home="$(pwd)"
  cd curl-$curl_version
  OPENSSL_ROOT_DIR="$openssl_dir" cmake -S . -B build -D CMAKE_INSTALL_PREFIX=install
  cd build
  make -j8
  make install
  cd "$home"
fi

curl_install_dir="$(pwd)/curl-$curl_version/install"


# Setting up compiler flags and PATH
export PATH="${curl_install_dir}/bin:$PATH"
export LDFLAGS="-L${curl_install_dir}/lib -L${openssl_dir}/lib"
export CPPFLAGS="-I${curl_install_dir}/include -I${openssl_dir}/include"
#export LDFLAGS="-L$(pwd)/curl-${curl_version}/lib"
#export CPPFLAGS="-I$(pwd)/curl-${curl_version}/include"

#python3 setup.py --curl-config=/opt/homebrew/opt/curl/bin/curl-config --with-openssl --openssl-dir=/opt/homebrew/opt/openssl@1.1 "$@"
#exec python3 setup.py --curl-config="${curl_install_dir}/bin/curl-config" --with-openssl --openssl-dir="$openssl_dir" "$@"
exec python3 setup.py --curl-config="${curl_install_dir}/bin/curl-config" "$@"
