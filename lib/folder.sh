# ---------------------------------------
# folder
# ---------------------------------------

function bh_folder_sorted_by_size() {
  du -ahd 1 | sort -h
}

function bh_folder_info() {
  local extensions=$(for f in *.*; do printf "%s\n" "${f##*.}"; done | sort -u)
  echo "size="$(du -sh | awk '{print $1;exit}')
  echo "dirs="$(find . -mindepth 1 -maxdepth 1 -type d | wc -l)
  echo -n "files="$(find . -mindepth 1 -maxdepth 1 -type f | wc -l)"("
  for i in $extensions; do
    echo -n ".$i="$(find . -mindepth 1 -maxdepth 1 -type f -iname \*\.$i | wc -l)","
  done
  echo ")"
}

function bh_folder_find_duplicated_pdf() {
  find . -iname "*.pdf" -not -empty -type f -printf "%s\n" | sort -rn | uniq -d | xargs -I{} -n1 find . -type f -size {}c -print0 | xargs -r -0 md5sum | sort | uniq -w32 --all-repeated=separate
}