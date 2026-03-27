mkdir -p glean
find . -type f -name "*.lean" -print0 | while IFS= read -r -d '' file; do
  dest="glean/$(basename "$file")"
  if [ -f "$dest" ]; then
    size_src=$(wc -c < "$file")
    size_dest=$(wc -c < "$dest")
    if [ "$size_src" -gt "$size_dest" ]; then
      echo "Overwriting: '$dest' with larger file '$file'"
      cp "$file" "$dest"
    else
      echo "Skipping: '$file' (smaller or equal to existing '$dest')"
    fi
  else
    cp "$file" "$dest"
  fi
done

find . -type f -name "*.md" -print0 | while IFS= read -r -d '' file; do   dest="papers2/$(basename "$file")";   if [ -f "$dest" ]; then     size_src=$(wc -c < "$file");     size_dest=$(wc -c < "$dest");     if [ "$size_src" -gt "$size_dest" ]; then       cp "$file" "$dest";     fi;   else     cp "$file" "$dest";   fi; done
