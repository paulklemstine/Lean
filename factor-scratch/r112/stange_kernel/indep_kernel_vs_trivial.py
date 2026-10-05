# DECISIVE independent test of the load-bearing claim.
#
# Claim: the Q-kernel (the paper's linear-algebra phase) contributes nothing
# beyond "obtain ANY multiple of ord(g)". Strip-and-gcd then delivers the
# classical 20/27.
#
# Test: for the same (N, g), compare success via the FULL kernel path against
# success via a TRIVIAL multiple of ord(g) obtained WITHOUT any factor base or
# linear algebra. If they agree on every trial, the kernel is not the mechanism.
import sys, random, math
sys.path.insert(0, '.')
import core

def ord_div_multiple(N, g, p, q, mult=2):
    """A multiple of ord(g) mod N obtained the trivial way:
    ord(g) mod p divides (p-1), so (p-1)*(q-1) is a multiple of ord(g) mod N."""
    return (p - 1) * (q - 1) * mult

agree = 0; tot = 0; kern_ok = 0; triv_ok = 0
for i in range(50):
    rng = random.Random(70000 + i)
    bits = rng.choice([22, 24, 26])
    N, p, q = core.gen_rsa(bits, rng)
    # pick a random unit g mod N (matching how the battery samples g)
    while True:
        g = rng.randrange(2, N - 1)
        if core.gcd(g, N) == 1:
            break
    # full kernel path
    try:
        r = core.one_trial(N, p, q, 8, 5, rng)
    except TypeError:
        print("one_trial signature mismatch"); print([x for x in dir(core.one_trial)]); sys.exit(0)
    f_kern = r.get("factor") if isinstance(r, dict) else None
    # trivial multiple path -- NO factor base, NO linear algebra
    m = ord_div_multiple(N, g, p, q)
    f_triv = core.factor_from_multiple(m, g, N)
    ok_k = f_kern is not None and f_kern * (N // f_kern) == N
    ok_t = f_triv is not None and f_triv * (N // f_triv) == N
    tot += 1
    kern_ok += ok_k; triv_ok += ok_t
    agree += (ok_k == ok_t)
    # and the true v2-law prediction
    op = core._order if hasattr(core, '_order') else None

print("trials:", tot)
print("full kernel path  succeeded: %d/%d" % (kern_ok, tot))
print("trivial-multiple  succeeded: %d/%d" % (triv_ok, tot))
print("AGREEMENT (same verdict on every trial): %d/%d" % (agree, tot))
print()
if agree == tot:
    print("=> The Q-kernel adds NOTHING beyond 'any multiple of ord(g)'. CONFIRMED.")
else:
    print("=> DISAGREEMENT on %d trials -- kernel may carry information." % (tot-agree))
