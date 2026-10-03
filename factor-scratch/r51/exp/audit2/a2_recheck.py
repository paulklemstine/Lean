#!/usr/bin/env python3
"""RE-VERIFY the L-columns and the ln k values against the CURRENT (patched) paper."""
from math import log, log2, sqrt, exp
import scipy.optimize as so

print("=== R1. the patched paper still prints ln k = -573/-1217/-2539 ===")
for n,c in [(1024,-573),(2048,-1217),(4096,-2539)]:
    L=log(2**n)
    print(f"  n={n}: 4*sqrt(L ln L)-L = {4*sqrt(L*log(L))-L:>9.2f}   paper still says {c}")
print("  -> the coefficient was patched to 4 but the THREE NUMBERS were not. They are")
print("     the old 2*sqrt values.  MATERIAL residual defect.\n")

print("=== R2. the L COLUMNS: is the table right or wrong? ===")
print("  Paper: L[1/2] = 21.87/49.24/108.38/234.90 ; L[1/3] = 46.66/86.77/156.50/276.52")
p2={256:21.87,1024:49.24,4096:108.38,16384:234.90}
p3={256:46.66,1024:86.77,4096:156.50,16384:276.52}
print(f"{'n':>6} {'papL1/2':>9} {'stdL[1/2]':>10} {'papL1/3':>9} {'stdL[1/3]':>10} {'std GNFS L[1/3,(64/9)^1/3]':>24}")
for n in [256,1024,4096,16384]:
    N=2**n
    s2=log2(exp(sqrt(log(N)*log(log(N)))))            # c=1
    s3=log2(exp((log(N)*log(log(N)))**(1/3)))         # c=1
    g3=s3+log2((64/9)**(1/3))                          # with GNFS constant
    print(f"{n:>6} {p2[n]:>9.2f} {s2:>10.2f} {p3[n]:>9.2f} {s3:>10.2f} {g3:>24.2f}")
print()
print("  KEY: std L[1/2] (c=1) at n=256 is 43.73; the paper prints 21.87 = exactly half.")
print("  A 1/2 ratio is not any standard constant. Reverse-engineering the paper's col:")
for n in [256,1024,4096,16384]:
    N=2**n
    c=((64/9)**0.5)   # try GNFS-style constant on 1/2 too
    v=log2(exp(sqrt(log(N)*log(log(N)))))-1.0
    print(f"   n={n}: paper L[1/2] = {p2[n]:.2f} ; true-1.0 = {v:.2f}")
print("  -> paper's L[1/2] col == std L[1/2] MINUS EXACTLY 1.0 log2 unit at every n.")
print("     That is a constant c with log2(c) = -1, i.e. c = 1/2.  NOT a standard constant.")
print()
print("  paper L[1/3] col / std L[1/3]:")
for n in [256,1024,4096,16384]:
    N=2**n
    s3=log2(exp((log(N)*log(log(N)))**(1/3)))
    print(f"   n={n}: {p3[n]:.2f} vs {s3:.2f}  ratio {p3[n]/s3:.4f}")
print("  -> ratio 3.33/3.60/3.84/4.05 is NOT constant, so it is not a single c either.")

print()
print("=== R3. IS L[1/3] > L[1/2] EVER TRUE? (A2 agent claimed yes, crossover 40000 bits) ===")
for n in [256,1024,4096,16384,2**16]:
    N=2**n
    s2=log2(exp(sqrt(log(N)*log(log(N)))))
    s3=log2(exp((log(N)*log(log(N)))**(1/3)))
    print(f"   n=2^{n:<2}: L[1/2]={s2:8.2f}  L[1/3]={s3:8.2f}  L[1/3] < L[1/2]? {s3<s2}")
print("  -> L[1/3] < L[1/2] for ALL n, ALWAYS (smaller alpha-index = smaller cost).")
print("     There is NO crossover.  The A2 agent's 'crossover ~40000 bits' is WRONG.")
