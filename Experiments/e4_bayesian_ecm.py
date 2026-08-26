#!/usr/bin/env python3
"""E-4: Bayesian posterior B1 scheduling vs fixed-length escalation.
H: updating P(factor digits=d) after each failed curve concentrates effort
at the likeliest size, beating fixed escalating level lengths on time-to-factor.
Band: 25-digit (83b) factors - where B1 choice matters (E-3 calibration)."""
import sys, os, json, time
sys.path.insert(0, os.path.dirname(__file__))
from e2_adaptive_ecm import gen_semiprime, ecm_curves

# Posterior over factor sizes (digits): grid 15..35
GRID = list(range(15, 36))
def expected_curves(B1, d):
    # crude calibrated model: curves needed grows exponentially past the
    # B1-optimal digit count (~ log10(B1)*2.2)
    opt = 2.2 * __import__('math').log10(B1)
    return max(1.0, 3.0 ** max(0, d - opt))

def bayes_arm(N, rounds=14):
    prior = {d: 1.0/len(GRID) for d in GRID}
    t0 = time.perf_counter(); total = 0.0
    for _ in range(rounds):
        if not prior or total > 600: break
        # pick B1 maximizing expected progress rate: sum_d post(d)/exp_curves(B1,d)
        best_b1, best_score = 11000, -1
        for B1 in (2000, 5000, 11000, 25000, 50000, 110000):
            score = sum(p / expected_curves(B1, d) for d, p in prior.items())
            if score > best_score:
                best_score, best_b1 = score, B1
        k = 6
        f, el = ecm_curves(N, best_b1, k)
        total += el
        if f: return f, time.perf_counter() - t0
        # Bayesian update: failed k curves at B1 -> likelihood for each d
        for d in GRID:
            ec = expected_curves(best_b1, d)
            prior[d] *= (1 - min(0.99, k/ec)) if ec > 0 else 0.01
        s = sum(prior.values()) or 1.0
        prior = {d: p/s for d, p in prior.items()}
    return None, time.perf_counter() - t0

def escalate_arm(N):
    # e2's fixed-level adaptive (baseline)
    from e2_adaptive_ecm import ADAPT_LEVELS
    t0 = time.perf_counter(); total = 0.0
    for B1, k in [(1500,3),(4800,6),(15000,12),(48000,24),(150000,48)]:
        f, el = ecm_curves(N, B1, k); total += el
        if f: return f, time.perf_counter() - t0
        total += el
    return None, time.perf_counter() - t0

rows = []
for trial in range(3):
    N = gen_semiprime(83)   # 25-digit factors: the discriminating band
    for name, fn in (("bayes", lambda: bayes_arm(N)), ("escalate", lambda: escalate_arm(N))):
        f, el = fn()
        ok = bool(f) and N % f == 0
        rows.append({"trial": trial, "arm": name, "s": round(el,1), "ok": ok})
        print(f"  [{name:>8}] t#{trial}: {el:7.1f}s ok={ok}", flush=True)
json.dump(rows, open(os.path.join(os.path.dirname(__file__), 'e4_results.json'), 'w'), indent=1)
for arm in ("bayes","escalate"):
    rs = [r["s"] for r in rows if r["arm"]==arm and r["ok"]]
    print(f"{arm}: solved {len(rs)}/3 median {statistics.median(rs) if rs else '-'}s")
