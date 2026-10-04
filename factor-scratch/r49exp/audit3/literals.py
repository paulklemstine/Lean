import re, collections
P="/home/raver1975/lean/Catalog/Cryptography/FactoringBarriers/Round48_SUMMARY.md"
T=open(P,encoding="utf-8").read().split("\n")
# numeric literals with a decimal point or >=2 digits, per line
pat=re.compile(r'\d+\.\d+|\d{2,}')
hits=collections.defaultdict(list)
for i,l in enumerate(T,1):
    for m in pat.findall(l):
        hits[m].append(i)
print("== literals appearing in >1 place (potential stale duplicates) ==")
for k,v in sorted(hits.items(), key=lambda kv:-len(kv[1])):
    if len(v)>1:
        print("  %-10s x%-3d lines %s"%(k,len(v),v[:9]))
