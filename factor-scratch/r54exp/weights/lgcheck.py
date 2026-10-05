import math
data = [(34, 21, 51.1), (36, 46, 110.6), (38, 44, 105.7), (40, 33, 162.7)]
print(f"{'bits':>5s} {'meas r*/N^(1/5)':>18s} {'pred (ln r)^{-4/5}':>19s}")
print("-"*45)
for bits, rstar, n5 in data:
    pred = (math.log(rstar))**-0.8
    print(f"{bits:>5d} {rstar/n5:>18.3f} {pred:>19.3f}")
print()
print("pair count vs r*ln r (Harvey's O(r lg r)):")
for bits, rstar, n5 in data:
    cnt = sum(rstar//a for a in range(1, rstar+1))
    print(f"  bits={bits} r={rstar:>4d} count={cnt:>6d} r*ln r={rstar*math.log(rstar):>8.1f} ratio={cnt/(rstar*math.log(rstar)):.2f}")
