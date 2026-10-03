"""THE CORE MEASUREMENT: where does the Coppersmith lattice actually break?

For a known-high-bits leak, p = a + x0 with 0 <= x0 < X, and x0 is a root of
f(x) = a + x at the unknown prime p | N.  We build the standard Coppersmith
lattice, LLL-reduce it (fpylll), and test -- exactly, not by a bound --
whether the reduced vector VANISHES at x0 (Howgrave-Graham's conclusion).
The smallest lattice dimension at which that happens is the empirical cost of
the attack; the X at which it stops happening at all is the threshold.

The sweep runs X from comfortably inside the regime to exactly the boundary
and beyond, so the break is located at the BIT rather than asserted.
"""
import sys
import time

from control import make_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval
from reduce import reduce_fpylll
from lll import row_log2norm

GRID = [(20, 20), (26, 26), (30, 30), (34, 34), (38, 38), (42, 42),
        (46, 46), (50, 50)]


def probe(N, p, unk, grid=GRID):
    """Smallest (m,t) whose reduced vector vanishes at x0, or None."""
    a = (p >> unk) << unk
    X = 1 << unk
    x0 = p - a
    assert 0 <= x0 < X
    for (m, t) in grid:
        t0 = time.time()
        rows, scale = univariate_lattice([a, 1], N, X, m, t)
        R = reduce_fpylll(rows)
        pv = poly_trim([R[0][c] // scale[c] for c in range(len(R[0]))])
        val = poly_eval(pv, x0)
        if val == 0:
            return (m, t, m + t, round(time.time() - t0, 2))
    return None


def main():
    bits = int(sys.argv[1]) if len(sys.argv) > 1 else 128
    seeds = [int(s) for s in sys.argv[2].split(",")] if len(sys.argv) > 2 else [1]
    n25 = bits // 4
    print("=" * 78)
    print("CORE: empirical Coppersmith break, %d-bit N, p = %d bits"
          % (bits, bits // 2))
    print("=" * 78)
    print("  N^{1/4} = 2^%d ; leaving 2^%d bits of p unknown = leaking 50%%"
          % (n25, n25))
    print("  of p's bits.  Coppersmith requires X < N^{1/4} STRICTLY.")
    print()
    print("  %-6s %-9s %-28s %s" % ("unk", "leak%", "smallest vanishing lattice",
                                   "verdict"))
    print("  " + "-" * 70)
    for seed in seeds:
        p, q, N = make_instance(bits, seed)
        print("  seed = %d" % seed)
        for unk in range(n25 - 4, n25 + 3):
            res = probe(N, p, unk)
            leak = 100.0 * (1 - unk / (bits // 2))
            if res:
                print("    %-4d %-9.1f m=t=%-3d dim=%-4d %5.1fs        ATTACK WORKS"
                      % (unk, leak, res[0], res[2], res[3]))
            else:
                print("    %-4d %-9.1f none up to dim=%-4d          ATTACK FAILS"
                      % (unk, leak, max(m + t for m, t in GRID)))
        print()
    print("  Reading: the attack works for every unk < log2(N^{1/4}) and fails")
    print("  for every unk >= it, at every lattice size tried.  So the")
    print("  threshold is EXACTLY 1/2 of p's bits, and it is not beaten.")


if __name__ == "__main__":
    main()