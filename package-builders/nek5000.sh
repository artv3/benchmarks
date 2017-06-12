# This file is part of CEED. For more details, see exascaleproject.org.

# Clone Nek5000.

if [[ -z "$pkg_sources_dir" ]]; then
   echo "This script ($0) should not be called directly. Stop."
   return 1
fi
if [[ -z "$OUT_DIR" ]]; then
   echo "The variable 'OUT_DIR' is not set. Stop."
   return 1
fi

pkg_src_dir="Nek5000"
NEK5K_SOURCE_DIR="$pkg_sources_dir/$pkg_src_dir"
pkg_bld_dir="$OUT_DIR/$pkg_src_dir"
NEK5K_DIR="$pkg_bld_dir"
pkg="Nek5000"

function nek5k_clone()
{
   pkg_repo_list=("git@github.com:Nek5000/Nek5000.git"
                  "https://github.com/Nek5000/Nek5000.git")
   pkg_git_branch="master"
   cd "$pkg_sources_dir" || return 1
   if [[ -d "$pkg_src_dir" ]]; then
      update_git_package
      return
   fi
   for pkg_repo in "${pkg_repo_list[@]}"; do
      echo "Cloning $pkg from $pkg_repo ..."
      git clone "$pkg_repo" "$pkg_src_dir" && return 0
   done
   echo "Could not successfully clone $pkg. Stop."
   return 1
}

function nek5k_build()
{
   if [[ ! -d "$pkg_bld_dir" ]]; then
      cd "$OUT_DIR" && git clone "$NEK5K_SOURCE_DIR" || {
         echo "Cloning $NEK5K_SOURCE_DIR to OUT_DIR failed. Stop."
         return 1
      }
   elif [[ -e "${pkg_bld_dir}_build_successful" ]]; then
      echo "Using successfully built $pkg from OUT_DIR."
      return 0
   fi

   echo "Building $pkg, sending output to ${pkg_bld_dir}_build.log ..." && {
      ## Just build the requited tools: genbox and genmap
      cd "$pkg_bld_dir/tools" && \
      mv genbox/SIZE genbox/SIZE.orig && \
      sed "3s/30/120/" genbox/SIZE.orig > genbox/SIZE && \
      ./maketools genbox && \
      mv genmap/SIZE genmap/SIZE.orig && \
      sed "2s/500 000/2 100 000/" genmap/SIZE.orig > genmap/SIZE && \
      ./maketools genmap && \
      mv reatore2/reatore2.f reatore2/reatore2.f.orig && \
      sed "21s/10/21/" reatore2/reatore2.f.orig > reatore2/reatore2.f && \
      ./maketools reatore2
   } &> "${pkg_bld_dir}_build.log" || {
      echo " ... building $pkg FAILED, see log for details."
      return 1
   }
   echo "Build successful."
   : > "${pkg_bld_dir}_build_successful"
}

function build_package()
{
   nek5k_clone && nek5k_build
}
