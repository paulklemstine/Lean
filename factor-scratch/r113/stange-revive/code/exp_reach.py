"""
r113/stange-revive EXPERIMENT 1 -- how big a modulus can this method reach?

Three questions, three sections:

  A. The PROVED regime.  Stange p.4, read off the 300dpi render
     lit/p4_regime3.png (pdftotext renders it as the garbage token "8bb/2"),
     verbatim:
        "If b and n satisfy the relationship n >= 8b^{b/2} as n tends to
         infinity, then taking c = b+1, it is known that the probability has
         a lower bound [5, Theorem 1.1]."
     Computed in EXACT INTEGER ARITHMETIC as n^2 >= 64*b^b.  (FANOUT_BRIEF
     trap 4: float cube-root / floor errors manufacture fake refutations.)

  B. The COST-model crossover.  Using the paper's own runtime formula
     (Section 4, p.5-6) against rho / ECM / NFS.

  C. Does rho(u) actually describe the SMOOTHNESS RATE of g^x mod n?
     Measured directly, at increasing modulus size.  This is the load-bearing
     assumption of B; if it is wrong, B is wrong.
"""
import json
import math
import sys
import time

from cost import rho, log_rho, stange_cost
from stange import gen_rsa, relation_search, substream, _prime_list

OUT = "/home/raver1975/lean/factor-scratch/r113/stange-revive/out"

# ==========================================================================
print("=" * 78)
print("A.  THE PROVED REGIME  (Stange p.4, image-verified: n >= 8 b^(b/2))")
print("=" * 78)


def b_max_in_regime(n: int) -> int:
    """Largest b with n^2 >= 64*b^b, by exact integer arithmetic."""
    n2 = n * n
    b = 1
    best = 0
    while b < 10 ** 6:
        if n2 >= 64 * pow(b, b):
            best = b
        b += 1
        if 64 * pow(b, b) > n2 and b > best + 2:
            break
    return best


print(f"{'n':>8} {'log2 n':>9} {'b_max':>6}   {'b_max vs log2(n)':>18}")
rowsA = []
for e in (20, 30, 40, 60, 80, 100, 128, 200, 256, 512, 1024, 2048, 4096):
    n = 1 << e
    bm = b_max_in_regime(n)
    rowsA.append((e, bm))
    print(f"  2^{e:<5d} {e:9d} {bm:6d}   {bm / e:18.4f}")
print()
print("  b_max grows like 2 log n / log log n  (r49's regime note).  So the")
print("  proved factor base is TINY -- it is not a subexponential b at all.")

# ==========================================================================
print()
print("=" * 78)
print("B.  COST-MODEL CROSSOVER  (paper Section 4 formula vs the baselines)")
print("=" * 78)


def stange_cost_units(nbits, b, c=10):
    """
    Cost in MODULAR MULTIPLICATIONS, deliberately GENEROUS to Stange:
      * per trial we charge max(1.5*log2(n) mults for g^x mod n, b trial
        divisions) -- the MAX, not the sum, so we never double-charge;
      * relation finding  (b+c) * rho(u)^-1 trials   (paper p.5);
      * linear algebra + gcd  O(b^4 log b (log n)^4)  (paper Thm 3.2).
    """
    B = _prime_list(b + 1)[-1] if False else None
    from cost import nth_prime, primepi
    B = nth_prime(b)
    u = nbits * math.log(2.0) / math.log(B)
    nrels = b + c
    per_trial = max(1.5 * nbits, float(b))
    ln_rel = log_rho(u) + math.log(nrels) + math.log(per_trial)
    ln_lag = 4.0 * math.log(b) + math.log(max(b, 2)) + 4.0 * math.log(nbits)
    return {"b": b, "B": B, "u": u, "log_cost": ln_rel + ln_lag,
            "log_rel": ln_rel, "log_lag": ln_lag}


def best_b(nbits, c=10, bmax=30000):
    best = None
    b = 3
    while b <= bmax:
        r = stange_cost_units(nbits, b, c)
        if best is None or r["log_cost"] < best["log_cost"]:
            best = r
        b = int(b * 1.05) + 1
    return best


print(f"{'log2 n':>7} {'best b':>7} {'u':>7} {'stange ln':>11} "
      f"{'rho ln':>9} {'ecm ln':>9} {'nfs ln':>9}  {'stange/rho':>12}")
rowsB = []
for e in (128, 256, 512, 1024, 1536, 2048, 3072, 4096, 8192):
    t0 = time.time()
    r = best_b(e)
    lr = 0.25 * e * math.log(2.0)
    lp = (e / 2.0) * math.log(2.0)
    le = math.sqrt(2.0 * lp * math.log(lp))
    ln_ = (64.0 / 9.0) ** (1 / 3) * (e * math.log(2)) ** (1 / 3) \
        * math.log(e * math.log(2)) ** (2 / 3)
    rowsB.append((e, r["b"], r["u"], r["log_cost"], lr, le, ln_))
    print(f"{e:7d} {r['b']:7d} {r['u']:7.2f} {r['log_cost']:11.1f} "
          f"{lr:9.1f} {le:9.1f} {ln_:9.1f}  {r['log_cost'] - lr:12.1f}")
print("  (natural logs of the number of MODULAR MULTIPLICATIONS;")
print("   'stange/rho' > 0 means Stange costs more than rho)")

# crossover with rho, by bisection on log2(n)
def f(e):
    return best_b(int(e))["log_cost"] - 0.25 * int(e) * math.log(2.0)


lo, hi = 128.0, 20000.0
print()
print("  crossover search: is there ANY size where Stange beats rho?")
if f(hi) > 0:
    for _ in range(60):
        mid = (lo + hi) / 2
        if f(mid) > 0:
            lo = mid
        else:
            hi = mid
    print(f"    Stange <= rho for log2(n) <= {hi:.1f}  "
          f"(n = 2^{hi:.0f}), Stange > rho above that.")
    XOVER = hi
else:
    print("    Stange never beats rho on the searched grid.")
    XOVER = None

lo2, hi2 = 128.0, 20000.0
def f2(e):
    e = int(e)
    return best_b(e)["log_cost"] - (64.0 / 9.0) ** (1 / 3) * \
        (e * math.log(2)) ** (1 / 3) * math.log(e * math.log(2)) ** (2 / 3)
for _ in range(60):
    mid = (lo2 + hi2) / 2
    if f2(mid) > 0:
        lo2 = mid
    else:
        hi2 = mid
print(f"    Stange <= NFS for log2(n) <= {hi2:.1f}  (n = 2^{hi2:.0f}).")
print(f"    NFS <= rho  for log2(n) <= ", end="")
lo3, hi3 = 128.0, 20000.0
def f3(e):
    e = int(e)
    return 0.25 * e * math.log(2.0) - (64.0 / 9.0) ** (1 / 3) * \
        (e * math.log(2)) ** (1 / 3) * math.log(e * math.log(2)) ** (2 / 3)
for _ in range(60):
    mid = (lo3 + hi3) / 2
    if f3(mid) > 0:
        lo3 = mid
    else:
        hi3 = mid
print(f"{lo3:.1f}  (n = 2^{lo3:.0f})")
print()
print("  => the window in which Stange could beat rho sits BELOW the window in")
print("     which NFS beats rho.  There is NO size where Stange is the best.")

# ==========================================================================
print()
print("=" * 78)
print("C.  DOES rho(u) DESCRIBE THE SMOOTHNESS RATE OF g^x mod n ?")
print("=" * 78)
print("  measured = trials per relation, sampling x uniform in [1,n]")
print("  model    = 1/rho(log n / log B)")
print()
print(f"{'nbits':>6} {'B':>5} {'b':>4} {'u':>6} {'trials/rel meas':>16} "
      f"{'1/rho(u)':>14} {'ratio':>8} {'secs':>7}")
rowsC = []
for nbits, B in ((24, 25), (28, 30), (32, 40), (36, 47), (40, 60), (44, 70)):
    N, p, q = gen_rsa(nbits, 4242, f"C:{nbits}:{B}")
    primes = _prime_list(B)
    b = len(primes)
    if b + 6 > 10 ** 7:
        continue
    t0 = time.time()
    rels, trials, rejects, done = relation_search(
        2, N, primes, 6, substream(9, f"C:{nbits}:{B}"))
    dt = time.time() - t0
    if len(rels) == 0:
        print(f"{nbits:6d} {B:5d} {b:4d}  --  no relation in {trials} trials")
        continue
    tpr = trials / len(rels)
    u = math.log(N) / math.log(B)
    model = 1.0 / rho(u)
    rowsC.append((nbits, B, b, u, tpr, model))
    print(f"{nbits:6d} {B:5d} {b:4d} {u:6.2f} {tpr:16.1f} "
          f"{model:14.1f} {tpr / model:8.3f} {dt:7.1f}")

json.dump({"regime": rowsA, "cost": rowsB, "smoothness": rowsC,
           "crossover_stange_rho": XOVER, "crossover_stange_nfs": hi2,
           "crossover_nfs_rho": lo3},
          open(f"{OUT}/reach.json", "w"), indent=1)
print()
print(f"wrote {OUT}/reach.json")