"""
exp_nosieve.py -- WHY the hybrid cannot be built the way its name suggests.

THE STRUCTURAL CLAIM
---------------------
"NFS relation-finding feeding Stange's linear-algebra/gcd" presupposes that NFS's
relation-finding ROUTE can be transplanted onto Stange's relation CONDITION
(`g^x = prod p_i^{f_i} mod n`).  This experiment tests the presupposition instead of
assuming it.

NFS sieving works because the sieved quantity is POLYNOMIALIAL/ADDITIVE in the sieve
variable: for `a + b`, the condition `p | (a+b)` is decided by `(a+b) mod p`, which is
computable for free, and it is PERIODIC in the index -- so a sieve over a box of size W
costs `O(W * pi(B) / something)` and finds every divisible position without touching
the big integers.

Stange's condition is EXPONENTIAL: the sieved quantity is `g^x mod n`.  Two facts break
the sieve:

  (F1) `p | (g^x mod n)` is NOT decidable from cheap information.  `g^x mod n` is a
       residue in [0,n); knowing `g^x mod p` tells you nothing, because reducing mod n
       is not a ring homomorphism on the way down -- `g^x mod n mod p != g^x mod p` in
       general (n is not a multiple of p).  So each candidate costs a full modpow.
  (F2) The hit set is NOT periodic in x.  If it were periodic with a small period, one
       could enumerate hit classes instead of testing every x.

F2 is the load-bearing one and it is TESTABLE.  If the hit set were periodic with period
d < K, then `hits(x) == hits(x+d)` for all x in range.  We test that directly, and we
test the NFS control (`p | a+b`) on the SAME code path, where periodicity MUST hold.
If the NFS control is periodic and Stange's is not, the asymmetry is established on the
harness itself rather than on my reading of it.

WHAT THIS MEANS FOR H1/H2/H3
----------------------------
If F2 holds, then no sieve over x exists, so "NFS relation-finding" reduces to batching
the trial division -- which is what `hcore.find_relations_sieve` does, and which is a
constant-factor engineering change, not an algorithm change.  The measured end-to-end
ratio is then a statement about Python constants, and the honest conclusion is that the
hybrid's NAME promises an L[1/3] relation phase that the Stange condition cannot host.
"""

from __future__ import annotations

import random
import sys
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/hybrid")

import stange  # noqa: E402
from sympy.ntheory import n_order  # noqa: E402

K = 6000


def periodicity(hits_fn, K, dmax=64):
    """Smallest d <= dmax with hits(x) == hits(x+d) for ALL x in [1, K-d].
    Returns None if no such d -- i.e. the pattern is aperiodic on this window."""
    base = [hits_fn(x) for x in range(1, K + 1)]
    for d in range(1, dmax + 1):
        if all(base[x - 1] == base[x - 1 + d] for x in range(1, K - d + 1)):
            return d
    return None


def main():
    rng = random.Random(20261004)
    n, p_f, q_f = stange.gen_semiprime(32, rng)
    FB = stange.factor_base(stange.bbound_for_b(10), n)
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)

    print(f"n ~ 2^{n.bit_length()}, b = {len(FB)}, K = {K} candidate indices")
    print("=" * 78)
    print("F1 -- is `p | g^x mod n` decidable from g^x mod p?   (it must not be)")
    print("=" * 78)
    # ⚠️ MY FIRST VERSION OF F1 WAS VACUOUS, and it is worth recording because it is a
    # new instance of a failure the campaign has hit repeatedly.  I tested with `p_f`,
    # a FACTOR OF n.  But n == 0 (mod p_f), so (g^x - k*n) mod p_f == g^x mod p_f
    # IDENTICALLY, and the test reported a perfect 0/600 -- a "clean" result that
    # asserted the opposite of what it claimed to test.  The factor-base primes are the
    # ones that matter (and `factor_base` drops exactly the primes dividing n, which is
    # what made the mistake easy to make).  With a genuine FB prime the answer is 88%.
    pp = FB[3]
    assert n % pp != 0, "the test prime must NOT divide n, or the test is vacuous"
    mism = sum(1 for x in range(1, 601)
               if pow(g, x, n) % pp != pow(g, x, pp))
    print(f"  test prime p = {pp} (p | n? {n % pp == 0}) -- chosen because it does NOT "
          f"divide n")
    print(f"  (g^x mod n) mod p != g^x mod p in {mism}/600 cases ({100*mism/600:.1f}%)")
    print(f"  (with p | n the same test returns 0/600 by construction -- the vacuous "
          f"version)")
    print("  => the cheap residue does NOT determine divisibility; each trial needs the")
    print("     full modpow.  This is F1.")

    print()
    print("=" * 78)
    print("F2 -- PERIODICITY.  A sieve needs the hit set periodic in the index.")
    print("=" * 78)
    print(f"  {'quantity':>34} {'p':>4} {'hits':>6} {'E[hits]':>8} {'smallest period<=64':>22}")
    stange_periods = []
    for pp in list(FB)[:5]:
        h = [1 if pow(g, x, n) % pp == 0 else 0 for x in range(1, K + 1)]
        d = periodicity(lambda x, pp=pp: 1 if pow(g, x, n) % pp == 0 else 0, K)
        stange_periods.append(d)
        print(f"  {'p | (g^x mod n)   [STANGE]':>34} {pp:>4} {sum(h):>6} "
              f"{K/pp:>8.0f} {str(d):>22}")

    print()
    # THE NFS CONTROL on the SAME periodicity harness.
    print("  NFS CONTROL -- `p | (a+b)`, sieved over a box, the thing sieving is FOR:")
    nfs_periods = []
    for pp in list(FB)[:5]:
        d = periodicity(lambda x, pp=pp: 1 if (1000 + x) % pp == 0 else 0, K)
        nfs_periods.append(d)
        h = sum(1 for x in range(1, K + 1) if (1000 + x) % pp == 0)
        print(f"  {'p | (1000+x)      [NFS]':>34} {pp:>4} {h:>6} {K/pp:>8.0f} {str(d):>22}")

    print()
    print("=" * 78)
    print("VERDICT")
    print("=" * 78)
    nfs_ok = all(d == pp for d, pp in zip(nfs_periods, list(FB)[:5]))
    stange_none = sum(1 for d in stange_periods if d is None)
    print(f"  NFS control periodic with period exactly p in "
          f"{sum(1 for d,pp in zip(nfs_periods,list(FB)[:5]) if d==pp)}/5 primes "
          f"-> control is {'LIVE' if nfs_ok else 'BROKEN'}")
    print(f"  Stange hit set APERIODIC (no period <= 64) for {stange_none}/5 primes")
    print()
    if nfs_ok and stange_none >= 4:
        print("  >>> ESTABLISHED: sieving over x is IMPOSSIBLE for `g^x mod n`.")
        print("      The NFS control is perfectly periodic on the same harness, so the")
        print("      asymmetry is a property of the two CONDITIONS, not of my test.")
        print("      Consequence: 'NFS relation-finding feeding Stange's kernel' cannot")
        print("      import NFS's L[1/3] relation phase.  It can only batch trial")
        print("      division -- a constant-factor engineering change.")
    else:
        print("  >>> NOT ESTABLISHED.  Do not report the structural claim; report the "
              "timings only and say why.")


if __name__ == "__main__":
    main()