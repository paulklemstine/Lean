import itertools
# S3 as permutations of {0,1,2}, compose g*h meaning apply g then h? Use g*h = h(g(.)) i.e standard product
def comp(a,b): return tuple(b[a[i]] for i in range(3))
def inv(a):
    r=[0]*3
    for i in range(3): r[a[i]]=i
    return tuple(r)
e=tuple(range(3))
# all 6 elements of S3
S3=[]
for perm in itertools.permutations(range(3)): S3.append(perm)
# dedupe
uniq=[]
for p in S3:
    if p not in uniq: uniq.append(p)
S3=uniq
def mul(a,b): return comp(a,b)
def comm(a,b): return mul(mul(mul(a,b),inv(a)),inv(b))  # a b a^-1 b^-1
# G' = A3 for S3
A3={p for p in S3 if all(comp(p,p)[i]==p[i] for i in range(3)) or p in [ (1,2,0),(2,0,1)]}
print("S3 size",len(S3),"A3 (derived) =",sorted(A3))
# Is [a,b] != [b,a] i.e. comm = inv(comm)? G' = A3 of order 3, not 2-torsion
for a in S3:
    for b in S3:
        c=comm(a,b); ci=comm(b,a)
        assert ci==inv(c), "identity [b,a]=[a,b]^-1 failed"
print("[b,a]=[a,b]^-1 holds for all pairs: TRUE")
# Prediction 1: for each target sigma, fibre F_sigma={(x,y): x*y=sigma}, is comm constant?
print("\nPrediction 1: commutator on fibre F_sigma = {(x,y): xy=sigma}")
nonconst=[]
for sig in S3:
    fib=[(x,mul(inv(x),sig)) for x in S3]  # all (x,y) with xy=sigma
    vals=sorted(set(comm(x,y) for x,y in fib))
    if len(vals)>1: nonconst.append(sig)
    print("  sigma=",sig,"|fibre|=",len(fib),"|distinct comm values|=",len(vals), "const" if len(vals)==1 else "NONCONST")
print("\nNon-constant fibres:",len(nonconst),"of",len(S3))
