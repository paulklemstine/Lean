# With the CORRECT advantage  A = E_biased[f] - E_uniform[f],  does t* = 2 ln n / A^2 hold
# across the block sizes?  (f = +1 on the biased block of size n/2^bits, -1 outside.)
import math
NB = 18
ln_n = math.log(float(next_prime(2**NB)))
print(f"ln n = {ln_n:.2f}, so 2 ln n = {2*ln_n:.2f}", flush=True)
print(f"{'bits':>4} {'p':>5} {'E_unif f':>9} {'E_bias f':>9} {'A':>7} | {'t*':>5} "
      f"{'t* A^2':>8} {'t*A^2/(2 ln n)':>15}", flush=True)
vals = [(1,0.85,48),(1,0.70,48),(2,0.85,16),(2,0.70,24),
        (3,0.85,16),(3,0.70,16),(4,0.85, 8),(4,0.70, 8)]
ratios = []
for bits, p, tstar in vals:
    span = 2.0**(-bits)                     # block fraction
    e_unif = 2*span - 1
    e_bias = p + (1-p)*(2*span - 1)
    A = e_bias - e_unif
    lhs = tstar * A * A
    ratios.append(lhs/(2*ln_n))
    print(f"{bits:>4} {p:>5.2f} {e_unif:>9.3f} {e_bias:>9.3f} {A:>7.3f} | {tstar:>5} "
          f"{lhs:>8.1f} {lhs/(2*ln_n):>15.3f}", flush=True)
print()
print(f"t* A^2 / (2 ln n):  min {min(ratios):.3f}  max {max(ratios):.3f}  "
      f"mean {sum(ratios)/len(ratios):.3f}  spread {max(ratios)/min(ratios):.2f}x", flush=True)
print("the law  t* = 2 ln n / A^2  is confirmed across block sizes if this spread is small", flush=True)
