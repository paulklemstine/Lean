"""THE MANDATORY CONTROL, final form: bounded grid, 3 seeds.

Coppersmith's "50% of the bits of p" is X < N^{1/4} with a STRICT
inequality.  With a 128-bit N, N^{1/4} = 2^32 and p has 64 bits, so
"half the bits of p" == "32 unknown bits" == the EXACT boundary.

  KNOWN-GOOD : 31 unknown bits  (X = 2^31 < N^{1/4})  must SUCCEED
  BOUNDARY   : 32 unknown bits  (X = 2^32 = N^{1/4})  measured, expected to fail
  KNOWN-BAD  : 48 unknown bits  (X = 2^48 > N^{1/4})  must FAIL
"""
import sys, time
from control import make_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval
from reduce import reduce_fpylll

BITS = 128
GRID = [(16,16),(20,20),(26,26),(30,30),(34,34),(38,38),(42,42),(46,46),(50,50),(56,56)]

def probe(N, p, unk):
    a = (p >> unk) << unk; X = 1 << unk; x0 = p - a
    assert 0 <= x0 < X
    for (m,t) in GRID:
        rows, scale = univariate_lattice([a,1], N, X, m, t)
        R = reduce_fpylll(rows)
        pv = poly_trim([R[0][c]//scale[c] for c in range(len(R[0]))])
        if poly_eval(pv, x0) == 0:
            return (m,t,m+t)
    return None

print("="*76)
print("MANDATORY CONTROL -- %d-bit N, p = %d bits, N^{1/4} = 2^%d" % (BITS,BITS//2,BITS//4))
print("="*76)
res = {}
for label, unk, expect in (("KNOWN-GOOD 31 unknown", 31, True),
                           ("BOUNDARY   32 unknown", 32, None),
                           ("KNOWN-BAD  48 unknown", 48, False)):
    row=[]
    for seed in (1,2,3):
        p,q,N = make_instance(BITS, seed)
        t0=time.time(); r = probe(N,p,unk); el=time.time()-t0
        ok = r is not None
        row.append(ok)
        tag = "" if expect is None else ("" if ok==expect else "  *** CONTROL VIOLATION ***")
        print("  %-22s seed=%d  unk=%2d X=2^%2d  %-22s %5.1fs%s"
              % (label,seed,unk,unk,
                 ("WORKS dim=%d"%r[2]) if r else "no vanishing vector", el, tag), flush=True)
    res[label]=row
print("-"*76)
# NOTE: labels must match the tuples above EXACTLY (two spaces before the
# number), or this summary raises KeyError -- which is what happened on the
# first run, after all nine measurements had already been recorded.
GOOD = "KNOWN-GOOD 31 unknown"
BAD = "KNOWN-BAD  48 unknown"
BND = "BOUNDARY   32 unknown"
good = all(res[GOOD]); bad = all(not r for r in res[BAD])
print("KNOWN-GOOD (31 unk, X<N^{1/4}) succeeded on 3/3 : %s" % good)
print("KNOWN-BAD  (48 unk, X>N^{1/4}) failed on 3/3     : %s" % bad)
print("BOUNDARY   (32 unk, X=N^{1/4}) outcomes          : %s" % res[BND])
v = good and bad
print("CONTROL: %s" % ("PASS -- harness can resolve a threshold" if v else "FAIL"))
sys.exit(0 if v else 1)
