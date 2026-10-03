import math

UMAX = 80.0
N = 2000000                      # grid points over [0, UMAX]
du = UMAX / N
rho = [0.0] * (N + 2)
n1 = int(1.0 / du)
for i in range(0, n1 + 2):
    rho[i] = 1.0
for i in range(n1 + 1, N + 1):
    u = i * du
    rho[i] = max(0.0, rho[i - 1] - rho[i - 1] / u * du)  # u*rho'(u) = -rho(u-1)

def R(u):
    if u <= 1.0:
        return 1.0
    if u >= UMAX - du:
        return 0.0
    x = u / du
    i = int(x)
    f = x - i
    return rho[i] * (1 - f) + rho[i + 1] * f

print("sanity rho(1)=%.4f rho(2)=%.4f (want 0.3069) rho(3)=%.4f (want 0.0486)"
      % (R(1.0), R(2.0), R(3.0)))
print()
B1000 = math.log2(1000)
nb = (1684).bit_length()
print("E-6b claims P(class)=1.000 and P(EC)=0.925 at B=B_1000, h<=1684.")
print("  1684 has %d bits" % nb)
print("  rho(%d bits vs B=1000) = rho(%.4f) = %.4f" % (nb, nb / B1000, R(nb / B1000)))
print("  rho(60 bits vs B=1000)  = rho(%.4f) = %.6g" % (60 / B1000, R(60 / B1000)))
print()
print("Implied B if each recorded number is a Dickman value at 29-bit orders:")
for target, label in [(1.00, 'E-6b class'), (0.925, 'E-6b ec'), (0.72, 'E-6c class'),
                      (0.44, 'E-6c ec'), (0.40, 'E-7 class'), (0.32, 'E-7 ec')]:
    lo, hi = 1.0, UMAX - 1.0
    for _ in range(200):
        mid = (lo + hi) / 2
        if R(mid) > target:
            lo = mid
        else:
            hi = mid
    u = (lo + hi) / 2
    print("  %-12s %.3f -> u=%.4f -> B=%.6g" % (label, target, u, 2 ** (29 / u)))
print()
print("My measured arms (29-bit orders), Dickman prediction:")
print("  u=1.5 rho=%.4f | u=2 rho=%.4f | u=2.5 rho=%.4f | u=3 rho=%.4f"
      % (R(1.5), R(2.0), R(2.5), R(3.0)))