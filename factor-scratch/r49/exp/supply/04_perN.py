#!/usr/bin/env python3.12
"""PER-N VARIANCE.

T1exact.py used ONE semiprime per bit size (random.Random(4242+bits)), and its own
caveat list admits it.  The scan rate depends on N only through c = m^3 mod N, so a
single N is a single draw of a possibly heavy-tailed quantity.  This measures the
SPREAD of the scan rate across many N at a fixed bit size -- if the spread is large,
the file's three-point "47 -> 326" is measuring which N it happened to draw, not the
size dependence.
"""
import random
import statistics
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49/exp/supply")
import S_common as S

SEED = 20261003
BITS = [int(x) for x in (sys.argv[1] if len(sys.argv) > 1 else "24,28,32").split(",")]
N_PER = int(sys.argv[2]) if len(sys.argv) > 2 else 24
INST = int(sys.argv[3]) if len(sys.argv) > 3 else 20000

print("=" * 88)
print("PER-N SPREAD of the scan rate at fixed bit size (%d instances per N, %d N's)"
      % (INST, N_PER))
print("seed = %d" % SEED)
print("=" * 88)

for bits in BITS:
    rng = random.Random(SEED + 777 * bits)
    ps = [x for x in S.prime_3mod4((1 << (bits // 2 - 1)) | 1, 1 << (bits // 2)) if x > 3]
    pq = [(p, q) for p in ps for q in ps if p < q
          and (1 << (bits - 1)) <= p * q < (1 << bits)]
    rng.shuffle(pq)
    pq = pq[:N_PER]
    rates = []
    t0 = time.time()
    for (p, q) in pq:
        N = p * q
        m0 = S.icbrt_floor(N)
        ms = [m0 + rng.randrange(m0 + 1) for _ in range(INST)]
        cs = []
        for m in ms:
            v = (m * m * m) % N
            cs.append(v - N if v > N // 2 else v)
        cnt, _ = S.rels_batch(ms, cs)
        rates.append(sum(cnt) / INST)
    rates_s = sorted(rates)
    lo = rates_s[0]
    hi = rates_s[-1]
    med = statistics.median(rates)
    mean = sum(rates) / len(rates)
    sd = statistics.stdev(rates) if len(rates) > 1 else 0.0
    # Poisson noise floor: a single N with this many events has relative sd
    # 1/sqrt(events); events = mean*INST
    ev = mean * INST
    print("\nbits=%d   N in [%d,%d]  (%d semiprimes, %.0fs)"
          % (bits, 1 << (bits - 1), 1 << bits, len(pq), time.time() - t0))
    print("  scan rate per N: min %.3e  median %.3e  mean %.3e  max %.3e"
          % (lo, med, mean, hi))
    print("  spread max/min = %.1fx     sd/mean = %.2f" % (hi / lo if lo > 0 else float("inf"),
                                                           sd / mean if mean else 0))
    print("  events per N (mean) = %.0f -> Poisson rel. sd = 1/sqrt(ev) = %.3f"
          % (ev, 1 / ev ** 0.5 if ev > 0 else float("inf")))
    print("  => observed sd/mean %.2f vs Poisson floor %.3f : %s"
          % (sd / mean if mean else 0, 1 / ev ** 0.5 if ev > 0 else float("inf"),
             "EXCESS (real N-to-N variation)" if (sd / mean if mean else 0) > 3 / ev ** 0.5
             else "consistent with Poisson alone"))
    print("  sorted rates:", " ".join("%.2e" % r for r in rates_s[:6]), "...",
          " ".join("%.2e" % r for r in rates_s[-3:]))
