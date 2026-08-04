"""Splice a single declaration's proof from a sorry-closer branch into the working file.

Usage:  python3 splice.py <path> <decl> <branch> [<decl> <branch> ...]
"""
import subprocess, sys, re


def show(rev, path):
    return subprocess.check_output(["git", "show", f"{rev}:{path}"], text=True).split("\n")


def find_decl(lines, name):
    start = None
    for i, l in enumerate(lines):
        if re.match(rf"^(lemma|theorem)\s+{re.escape(name)}\b", l):
            start = i
            break
    if start is None:
        raise SystemExit(f"decl {name} not found")
    j = start + 1
    end = len(lines)
    while j < len(lines):
        l = lines[j]
        if l.strip() == "":
            k = j
            while k < len(lines) and lines[k].strip() == "":
                k += 1
            if k >= len(lines) or not lines[k].startswith(" "):
                end = j
                break
            j = k
            continue
        if not l.startswith(" "):
            end = j
            break
        j += 1
    return start, end


def main():
    path = sys.argv[1]
    args = sys.argv[2:]
    cur = open(path).read().split("\n")
    for i in range(0, len(args), 2):
        name, branch = args[i], args[i + 1]
        src = show("origin/" + branch, path)
        s2, e2 = find_decl(src, name)
        s1, e1 = find_decl(cur, name)
        body = "\n".join(src[s2:e2])
        if "sorry" in body:
            print(f"WARNING: {name} on {branch} still has sorry")
        cur = cur[:s1] + src[s2:e2] + cur[e1:]
    open(path, "w").write("\n".join(cur))


main()
