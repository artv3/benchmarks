# This file is part of CEED. For more details, see exascaleproject.org.

# Clone MFEM, apply a patch, and build the parallel version.

if [[ -z "$pkg_sources_dir" ]]; then
   echo "This script ($0) should not be called directly. Stop."
   return 1
fi
if [[ -z "$OUT_DIR" ]]; then
   echo "The variable 'OUT_DIR' is not set. Stop."
   return 1
fi
if [[ -z "$mfem_patch_file" ]]; then
   echo "The variable 'mfem_patch_file' is not set. Stop."
   return 1
fi
mfem_patch_name="$(basename "$mfem_patch_file")"
mfem_patch_name="${mfem_patch_name%.patch}"
pkg_src_dir="mfem"
MFEM_SOURCE_DIR="$pkg_sources_dir/$pkg_src_dir"
pkg_bld_subdir="mfem-patched-$mfem_patch_name"
pkg_bld_dir="$OUT_DIR/$pkg_bld_subdir"
MFEM_DIR="$pkg_bld_dir"
pkg_version="$(git --git-dir=$MFEM_SOURCE_DIR/.git describe --long --abbrev=10 --tags)-patched"
pkg="MFEM (patched, $mfem_patch_name)"


function mfem_clone()
{
   pkg_repo_list=("git@github.com:mfem/mfem.git"
                  "https://github.com/mfem/mfem.git")
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


function mfem_build()
{
   if [[ "$mfem_patch_file" -nt "${pkg_bld_dir}_build_successful" ]]; then
      remove_package
   fi
   if package_build_is_good; then
      echo "Using successfully built $pkg from OUT_DIR."
      return 0
   elif [[ ! -d "$pkg_bld_dir" ]]; then
      cd "$OUT_DIR" && \
      git clone "$MFEM_SOURCE_DIR" "$pkg_bld_subdir" && \
      cd "$pkg_bld_subdir" && \
      patch -p1 < "$mfem_patch_file" || {
         printf "%s" "Cloning $MFEM_SOURCE_DIR to OUT_DIR/$pkg_bld_subdir"
         echo " and patching it failed. Stop."
         cd "$OUT_DIR" && rm -rf "$pkg_bld_dir"
         return 1
      }
   fi
   if [[ -z "$HYPRE_DIR" ]]; then
      echo "The required variable 'HYPRE_DIR' is not set. Stop."
      return 1
   fi
   if [[ -z "$METIS_DIR" ]]; then
      echo "The required variable 'METIS_DIR' is not set. Stop."
      return 1
   fi
   local METIS_5="NO"
   [[ "$METIS_VERSION" = "5" ]] && METIS_5="YES"
   echo "Building $pkg, sending output to ${pkg_bld_dir}_build.log ..." && {
      local num_nodes=1  # for 'make check' or 'make test'
      set_mpi_options    # for 'make check' or 'make test'
      cd "$pkg_bld_dir" && \
      make config \
         MFEM_USE_MPI=YES \
         $MFEM_EXTRA_CONFIG \
         MPICXX="$MPICXX" \
         CXXFLAGS="$CFLAGS" \
         HYPRE_DIR="$HYPRE_DIR/src/hypre" \
         METIS_DIR="$METIS_DIR" \
         MFEM_USE_METIS_5="$METIS_5" \
         MFEM_MPIEXEC="${MPIEXEC:-mpirun}" \
         MFEM_MPIEXEC_NP="${MPIEXEC_OPTS} ${MPIEXEC_NP:--np}" && \
      make -j $num_proc_build
   } &> "${pkg_bld_dir}_build.log" || {
      echo " ... building $pkg FAILED, see log for details."
      return 1
   }
   echo "Build successful."
   : > "${pkg_bld_dir}_build_successful"
}


function build_package()
{
   mfem_clone && mfem_build
}
