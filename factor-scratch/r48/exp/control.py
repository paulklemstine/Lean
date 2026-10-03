"""THE MANDATORY CONTROL.

The harness must separate a known-good case from a known-bad case before any
threshold it measures can be believed.

Setup.  N = p*q with p ~ q ~ sqrt(N), 256-bit N so the lattices stay small
enough to sweep densely.  Leak the top k bits of p: p = a + x with
0 <= x < 2^(nbits(p) - k).  Then x is a root of f(x) = a + x modulo p, and
since p | N it is a root of f modulo N in the Coppersmith sense, so the
univariate small-root routine applies directly with X = 2^(nbits(p)-k).

  KNOWN-GOOD: 50% of the bits of p  ->  x < 2^(nbits(p)/2) = 2^(nbits(N)/4),
              which is exactly the classical Coppersmith N^{1/4} regime.
              MUST SUCCEED.
  KNOWN-BAD:  25% of the bits of p  ->  x < 2^(3*nbits(p)/4), far beyond
              N^{1/4}.  MUST FAIL.

If both behave as required, the instrument can resolve a threshold.  If not,
it is broken and nothing downstream is reportable.
"""
import random
import sympy
from coppersmith import univariate_small_roots


def make_instance(bits=256, seed=1):
    rng = random.Random(seed)
    while True:
        p = sympy.nextprime(rng.getrandbits(bits // 2) | (1 << (bits // 2 - 1)))
        q = sympy.nextprime(rng.getrandbits(bits // 2) | (1 << (bits // 2 - 1)))
        if p != q:
            N = int(p) * int(q)
            if N.bit_length() == bits:
                return int(p), int(q), N


def top_bits_instance(bits=256, seed=1, leak_frac_num=1, leak_frac_den=2):
    """N plus the known top `leak_frac_num/leak_frac_den` of p's bits.

    The leaked value is a rounded DOWN to a multiple of 2^unk, so that the
    unknown part x0 = p - a really does satisfy 0 <= x0 < 2^unk.  Leaking
    p >> unk instead (without re-aligning) leaves x0 the full width of p,
    which silently inflates X and is exactly the kind of defect the
    mandatory control exists to catch.
    """
    p, q, N = make_instance(bits, seed)
    nb = p.bit_length()
    k = nb * leak_frac_num // leak_frac_den          # bits leaked
    unk = nb - k                                       # unknown low bits
    a = (p >> unk) << unk                             # known part, aligned
    assert 0 <= p - a < (1 << unk), "leak not aligned: x0 too wide"
    return dict(p=p, q=q, N=N, nbits=nb, leaked=k, unknown=unk,
                a=a, X=1 << unk)


def masked_instance(bits=256, seed=1, mask=None):
    """Generic instance with an arbitrary set of p's bits revealed.

    `mask` is a bitmask over p's bit positions (bit i = p's i-th low bit).
    Every revealed bit must be supplied in `a`; every unrevealed bit must be
    zero in `a`.  Then p = a + x0 with x0 < 2^(number of unrevealed bits).
    Returns (a, X, p, N, nbits).
    """
    p, q, N = make_instance(bits, seed)
    if mask is None:
        mask = 0
    a = 0
    for i in range(p.bit_length()):
        if (mask >> i) & 1:
            a |= ((p >> i) & 1) << i
    unk = p.bit_length() - bin(mask).count("1")
    a = (a >> unk) << unk
    return a, 1 << unk, p, N, p.bit_length(), unk


def run_case(inst, **kw):
    """Attack: find x0 = p - a with f(x0) = a + x0 = p, a factor of N."""
    f = [inst["a"], 1]
    roots, diag = univariate_small_roots(f, inst["N"], inst["X"],
                                         mod_is_factor=True, **kw)
    ok = bool(roots) and (inst["a"] + roots[0] == inst["p"])
    return ok, roots, diag


def main():
    print("=" * 78)
    print("MANDATORY CONTROL -- can the harness separate good from bad?")
    print("=" * 78)
    print("Coppersmith's '50% of the bits of p' is X < N^{1/4} with a STRICT")
    print("inequality.  Leaking exactly half the bits of p gives X = N^{1/4}")
    print("exactly, which is the boundary and is NOT covered.  So the")
    print("known-good case is 'half the bits, plus the one bit of margin the")
    print("strict inequality costs'; the exact-50% case is reported too, as")
    print("the boundary measurement itself.")
    print()
    results = {}
    bits = 128
    # Coppersmith's "50% of the bits of p" is X < N^{1/4} STRICTLY.  With a
    # 128-bit N that is X < 2^32, i.e. at most 31 unknown bits out of p's 64.
    # The known-good case sits just inside the regime; the known-bad case is
    # far outside it.
    cases = [
        ("KNOWN-GOOD  31 unknown bits", 31, True),
        ("BOUNDARY    exactly 32", 32, None),
        ("KNOWN-BAD   48 unknown bits", 48, False),
    ]
    for label, unk, expect in cases:
        for seed in (1, 2, 3):
            p, q, N = make_instance(bits, seed)
            nb = p.bit_length()
            a = (p >> unk) << unk
            assert 0 <= p - a < (1 << unk)
            inst = dict(p=p, q=q, N=N, nbits=nb, leaked=nb - unk,
                        unknown=unk, a=a, X=1 << unk)
            ok, roots, diag = run_case(inst)
            results.setdefault(label, []).append(ok)
            tag = "" if expect is None else (
                "" if ok == expect else "   *** CONTROL VIOLATION ***")
            print("%-26s seed=%d leaked=%2d/%2d  unknown=%2d  X=2^%2d  "
                  "N^{1/4}=2^%2d  -> %s%s"
                  % (label, seed, nb - unk, nb, unk, unk, bits // 4,
                     "FOUND p" if ok else "no root", tag))
    print("-" * 78)
    good = all(results["KNOWN-GOOD  31 unknown bits"])
    bad = all(not r for r in results["KNOWN-BAD   48 unknown bits"])
    print("KNOWN-GOOD (31 unknown bits, X=2^31 < N^{1/4}) succeeded on all 3 : %s" % good)
    print("KNOWN-BAD  (48 unknown bits, X=2^48 > N^{1/4}) failed on all 3    : %s" % bad)
    print("BOUNDARY   (exactly 32 unknown bits, X = N^{1/4})  outcomes: %s"
          % ["FOUND" if r else "no root" for r in results["BOUNDARY    exactly 32"]])
    verdict = good and bad
    print("CONTROL: %s" % ("PASS -- the harness can resolve a threshold"
                           if verdict else "FAIL -- do not report any threshold"))
    return verdict


if __name__ == "__main__":
    import sys
    sys.exit(0 if main() else 1)
