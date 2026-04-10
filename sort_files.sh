#!/bin/bash
# File organization script
# Sorts files from lean4/ into categorized directories

BASE="/home/raver1975/lean"
SOURCE="$BASE/lean4"

# Create target directories
for d in research sciam lean visual demo teams misc; do
    mkdir -p "$BASE/$d"
    echo "Created directory: $d"
done

# Counters
research_count=0
sciam_count=0
lean_count=0
visual_count=0
demo_count=0
teams_count=0
misc_count=0

# Process all files
find "$SOURCE" -type f | while read -r file; do
    name=$(basename "$file")
    ext="${name##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    relpath="${file#$SOURCE/}"
    reldir=$(dirname "$relpath")
    
    category=""
    
    # 1. Scientific American articles (highest specificity)
    if echo "$name" | grep -qiE "SciAm|sciam|scientific_american"; then
        category="sciam"
    # 2. Research papers
    elif echo "$name" | grep -qiE "ResearchPaper|research_paper"; then
        category="research"
    elif echo "$reldir" | grep -qiE "papers" && echo "$name" | grep -qiE "research"; then
        category="research"
    # 3. Team files (non-lean files with team in name)
    elif echo "$name" | grep -qiE "team" && [ "$ext_lower" != "lean" ]; then
        category="teams"
    # 4. Demo files
    elif echo "$name" | grep -qiE "demo"; then
        category="demo"
    elif echo "$reldir" | grep -qiE "demos"; then
        category="demo"
    # 5. Visual files
    elif echo "$ext_lower" | grep -qE "^(svg|png|jpg|jpeg|gif|webp|bmp|ico)$"; then
        category="visual"
    elif echo "$reldir" | grep -qiE "visuals"; then
        category="visual"
    # 6. Lean files
    elif [ "$ext_lower" = "lean" ]; then
        category="lean"
    # 7. Everything else
    else
        category="misc"
    fi
    
    # Create target directory structure
    targetdir="$BASE/$category"
    if [ "$reldir" != "." ]; then
        targetdir="$targetdir/$reldir"
    fi
    mkdir -p "$targetdir"
    
    # Move file
    mv "$file" "$targetdir/$name" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "[$category] $relpath"
    else
        echo "ERROR: $relpath"
    fi
done

# Count results
echo ""
echo "=== File Organization Complete ==="
for d in research sciam lean visual demo teams misc; do
    count=$(find "$BASE/$d" -type f 2>/dev/null | wc -l)
    echo "$d: $count files"
done
total=$(find "$BASE/research" "$BASE/sciam" "$BASE/lean" "$BASE/visual" "$BASE/demo" "$BASE/teams" "$BASE/misc" -type f 2>/dev/null | wc -l)
echo "Total: $total files"
