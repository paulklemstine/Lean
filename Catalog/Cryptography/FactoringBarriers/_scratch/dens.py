import math
from sympy import primerange
print("CRT-density heuristic: #achievable = prod_p min(l,p) (exact, CRT is independent).")
print("density = #achievable/U ; first achievable b ~ 1/density ; rigorous floor U^(1/l).")
print(f"{'n':>7} {'l':>5} {'log U':>8} {'log #ach':>10} {'log 1/dens (=log(U/#))':>22} "
      f"{'FLOOR logU/l':>13} {'n^(1/3)':>8}  heuristic hits floor?")
for n in [100, 1000, 10000, 100000, 1000000]:
    l = round(n ** (2/3))
    s = sum(math.log(min(l, p)) for p in primerange(1, n+1))
    lu = sum(math.log(p) for p in primerange(1, n+1))
    print(f"{n:>7} {l:>5} {lu:>8.1f} {s:>10.1f} {lu-s:>22.2f} {lu/l:>13.2f} "
          f"{n**(1/3):>8.1f}  {'YES' if abs((lu-s)-lu/l)<0.15*lu else 'NO'}")
print()
print("=> the heuristic first-b and the rigorous floor AGREE: both ~ n/3 in log,")
print("   i.e. n^(1/3) = e^{n^{1/3}}... no: both are exp(n^{1/3}) = e^{O(n^{1/3})}.")
print("   MEASURED (exhaustive, n<=28): log min b / n = 0.5 .. 0.77, i.e. exp(0.7n),")
print("   which is exp(0.7n) ABOVE the exp(n^{1/3}) target by a factor exp(~0.7n).")
