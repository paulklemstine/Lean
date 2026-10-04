import re, collections
files=["/home/raver1975/lean/Papers/the_smoothness_wall_is_a_subgroup_wall.md",
       "/home/raver1975/lean/Papers/the_baseline_that_was_not.md",
       "/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md"]
tag=["#522","#521","CENSUS"]
num=re.compile(r'(?<![\w.])(\d+\.\d+)(?![\w])')
where=collections.defaultdict(list)
for f,t in zip(files,tag):
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in num.finditer(line):
            where[m.group(1)].append((t,i,line.strip()[:100]))
print("=== JOB 4: decimal literals occurring in >=2 places ACROSS the 3 documents ===")
print("    (only literals with >=2 DISTINCT (file,line) sites are shown)\n")
for lit in sorted(where, key=lambda s:-len(where[s])):
    sites=where[lit]
    docs={(t,i) for t,i,_ in sites}
    if len(docs)>=2 and len({t for t,_,_ in sites})>=1 and not lit.startswith(('0.0','1.0','2.0')):
        print(f"  {lit!r}  x{len(sites)}")
        for t,i,s in sites: print(f"      {t}:{i}  {s}")
        print()
