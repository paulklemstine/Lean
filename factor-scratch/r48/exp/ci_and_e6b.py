import math, random, json
from e7_audit import is_smooth, fisher_two_sided, wilson

# counts from parity_control.py run (L=29): n_A=n_B=n_EC=4000, n_C=267
N4, NC = 4000, 267
counts = {
    1.5: dict(A=0.559, B=0.518, EC=0.601, C=0.506),
    2.0: dict(A=0.282, B=0.244, EC=0.306, C=0.240),
    2.5: dict(A=0.107, B=0.100, EC=0.141, C=0.082),
    3.0: dict(A=0.036, B=0.036, EC=0.053, C=0.026),
}
print("=== E-7 ratio at MATCHED 29-bit order scale (observed / baseline) ===")
print("%4s | %-24s %-24s" % ("u", "class / uniform", "class / EC"))
for u, c in counts.items():
    kA, kB, kEC, kC = (round(c['A'] * N4), round(c['B'] * N4),
                       round(c['EC'] * N4), round(c['C'] * NC))
    rA, rEC = kC / NC / (kA / N4), kC / NC / (kEC / N4)
    loC, hiC = wilson(kC, NC)
    loE, hiE = wilson(kEC, N4)
    # ratio CI by dividing Wilson endpoints (conservative)
    ciA = (loC / (hiE if False else (kA / N4)), hiC / (kA / N4))
    ciE = (loC / (hiE), hiC / (loE))
    print("%4.1f | %d/%d=%.3f vs %.3f  r=%.3f | %d/%d=%.3f vs %.3f  r=%.3f  95%%CI[%.2f,%.2f]"
          % (u, kC, NC, kC / NC, kA / N4, rA, kC, NC, kC / NC, kEC / N4, rEC, ciE[0], ciE[1]))

print()
print("=== E-6b internal consistency check (B = 1000 fixed) ===")
rng = random.Random(555)
for bits in (11, 20, 29, 40, 60):
    LO, HI = 1 << (bits - 1), 1 << bits
    xs = [rng.randrange(LO, HI) for _ in range(3000)]
    k = sum(is_smooth(x, 1000) for x in xs)
    print("  uniform %2d-bit integer is B=1000-smooth: %d/3000 = %.4f"
          % (bits, k, k / 3000))
print()
print("  E-6b recorded: class 1.000, EC 0.925 at B=B_1000.")
print("  E6B_RESULTS.md says h <= 1684 (~11 bits) but 'typical EC order ~2^60'.")
print("  -> an 11-bit arm is ~1.000 by arithmetic; a 60-bit arm would be ~0.000.")
print("  The recorded 0.925 is NOT the 60-bit value and NOT reproducible from B=1000.")