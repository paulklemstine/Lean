"""
THE EXTRAPOLATION GAP for Stange arXiv:2211.06821.

Hypothesis 3.1 is PROVED (lower-bounded via Fontein-Wocjan [5, Thm 1.1], which
the paper cites) only when  n >= 8 b^{b/2}   [verified from the 600dpi page
IMAGE of p.4 -- pdftotext renders it as the garbage token "8bb/2", and an
earlier reading of the brief, "8^{b/2}", is WRONG by an exponential factor].

The useful regime requires b SUBEXPONENTIAL IN LOG n, i.e.
b = exp(O(sqrt(log n log log n)))  -- the paper says so on p.4 verbatim.

Question: is there ANY (b, c) where the two regimes overlap?
"""
from __future__ import annotations
import math


def b_max_proof(n: int) -> float:
    """Largest b with  n >= 8 b^{b/2}.  Monotone increasing in b.

    Done entirely in LOGS: 8 b^{b/2} <= n  <=>  log 8 + (b/2) log b <= log n.
    The direct float form overflows for mid ~ 1e9 (mid**(mid/2) blows up) --
    the round-48 lesson, in a new dress: a formula that cannot be evaluated at
    the parameter you care about is not a formula."""
    ln = math.log(n)
    tgt = ln - math.log(8.0)
    lo, hi = 1.0, 4096.0
    # guard: hi must already violate
    while math.log(8.0) + (hi / 2.0) * math.log(hi) <= ln:
        hi *= 2
    for _ in range(200):
        mid = (lo + hi) / 2
        if math.log(8.0) + (mid / 2.0) * math.log(mid) <= ln:
            lo = mid
        else:
            hi = mid
    return lo


def log_b_needed(n: int) -> float:
    """log of the largest b allowed by the proof regime."""
    return math.log(b_max_proof(n)) if b_max_proof(n) > 1 else 0.0


def b_useful_lower(n: int, beta: float = 1.0) -> float:
    """The paper's own useful regime: b = L_n(1/2, beta)
    = exp((beta+o(1)) sqrt(log n log log n))."""
    L = math.log(n)
    return math.exp(beta * math.sqrt(L * math.log(L)))


def main():
    print("=" * 78)
    print("PROOF REGIME (p.4, image-verified):   n >= 8 b^{b/2}")
    print("USEFUL REGIME (p.4):                  b = exp(O(sqrt(log n log log n)))")
    print("=" * 78)
    hdr = f"{'n':>8} {'log2 n':>8} | {'b_max(proof)':>12} | {'b_useful(beta=1)':>18} | {'ratio':>12}"
    print(hdr)
    print("-" * len(hdr))
    rows = []
    for lg in (20, 40, 66, 100, 200, 332, 1000, 2048):
        n = 10 ** lg
        bmax = b_max_proof(n)
        bu = b_useful_lower(n, 1.0)
        ratio = bu / bmax if bmax > 0 else float("inf")
        rows.append((lg, bmax, bu, ratio))
        print(f"{'10^%d' % lg:>8} {lg*math.log2(10):>8.0f} | {bmax:>12.2f} | "
              f"{bu:>18.3e} | {ratio:>12.3e}")

    print()
    print("At what b does 8 b^{b/2} exceed n?  (first integer b that breaks the proof regime)")
    for lg in (20, 40, 100):
        n = 10 ** lg
        b = int(b_max_proof(n)) + 1
        while math.log(8.0) + ((b - 1) / 2.0) * math.log(b - 1) <= math.log(n):
            b += 1
        print(f"  n = 10^{lg:<4}: proof regime breaks at b = {b}")

    print()
    print("Useful b required to even ATTEMPT a 2048-bit modulus (n ~ 10^616):")
    n = 10 ** 616
    bmax = b_max_proof(n)
    bu = b_useful_lower(n, 1.0)
    print(f"  b_max(proof)   = {bmax:.2f}")
    print(f"  b_useful(beta=1) = {bu:.3e}")
    print(f"  ratio (useful/proof) = {bu/bmax:.3e}")
    print(f"  ... i.e. the useful b exceeds the provable b by a factor of "
          f"{math.log10(bu/bmax):.0f} in DECIMAL DIGITS.")

    print()
    print("Is the proof regime EVER compatible with a subexponential-in-log-n b?")
    print("  Need  b <= b_max(n)  AND  b = exp(O(sqrt(log n log log n))).")
    # b_max grows like 2 log n / log log n  (solve b^{b/2} ~ n => (b/2)log b ~ log n)
    print("  Asymptotically 8 b^{b/2} <= n  <=>  (b/2) log b <= log n - log 8,")
    print("  so  b <= (2 log n)/W(...)  ~  2 log n / (log log n) ... i.e. b_max is")
    print("  only POLYLOGARITHMIC in log n:")
    for lg in (20, 100, 1000):
        n = 10 ** lg
        L = math.log(n)
        print(f"    n = 10^{lg:<5}: b_max = {b_max_proof(n):8.2f}   "
              f"2 log n/log log n = {2*L/math.log(L):8.2f}")
    print()
    print("  while the useful b is exp(O(sqrt(log n log log n))), which for ANY")
    print("  fixed positive constant in the O(.) exceeds every power of log n.")
    print("  => The two regimes are INCOMPATIBLE asymptotically. The proof regime")
    print("     is b = Theta(log n / log log n); the algorithm needs b far larger.")
    print("  => At n = 10^20 the proof regime caps b at ~%.0f, but the algorithm's"
          % b_max_proof(10 ** 20))
    print("     own runtime analysis (Section 4) balances relation-finding against")
    print("     an O(b^4) rational linear-algebra phase and needs b = Theta(1e3-1e4).")

    print()
    print("=" * 78)
    print("SUMMARY TABLE -- the gap, in decimal orders of magnitude")
    print("=" * 78)
    print(f"{'n':>8} | {'b_max(proof)':>12} | {'b_useful':>12} | {'gap (orders)':>13}")
    for lg, bmax, bu, ratio in rows:
        print(f"{'10^%d' % lg:>8} | {bmax:>12.2f} | {bu:>12.3e} | {math.log10(ratio):>13.1f}")


if __name__ == "__main__":
    main()
