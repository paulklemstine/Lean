"""Visualize Frobenius eigenvalues on the Hasse circle |z| = sqrt(p)."""
import cmath, math
import matplotlib.pyplot as plt

def count_points_Fp(a: int, b: int, p: int) -> int:
    squares = {(y * y) % p for y in range(p)}
    count = 1
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        count += 1 if rhs == 0 else (2 if rhs in squares else 0)
    return count

a, b, p = -1, 0, 101
ap = p + 1 - count_points_Fp(a, b, p)
disc = cmath.sqrt(ap * ap - 4 * p)
alpha, beta = (ap + disc) / 2, (ap - disc) / 2

theta = [i * 2 * math.pi / 400 for i in range(401)]
plt.figure(figsize=(6, 6))
plt.plot([math.sqrt(p) * math.cos(t) for t in theta],
         [math.sqrt(p) * math.sin(t) for t in theta], 'b-', label=f'|z| = sqrt({p})')
plt.scatter([alpha.real, beta.real], [alpha.imag, beta.imag],
            color='red', zorder=5, label=f'Frobenius eigenvalues (a_p={ap})')
plt.axhline(0, color='gray', lw=0.5); plt.axvline(0, color='gray', lw=0.5)
plt.gca().set_aspect('equal'); plt.legend(); plt.title('Frobenius eigenvalues on the Hasse circle')
plt.xlabel('Re'); plt.ylabel('Im')
plt.savefig('hasse_circle.png', dpi=150)
print('wrote hasse_circle.png')
