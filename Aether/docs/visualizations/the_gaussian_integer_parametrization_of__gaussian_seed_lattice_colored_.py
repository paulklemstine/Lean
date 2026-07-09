import math
import matplotlib.pyplot as plt

def gcd(a, b):
    return math.gcd(a, b)

def main() -> None:
    B = 12
    xs, ys, cs, prim_x, prim_y = [], [], [], [], []
    for a in range(1, B + 1):
        for b in range(0, a):
            xs.append(a); ys.append(b); cs.append(a*a + b*b)
            if gcd(a, b) == 1 and (a - b) % 2 == 1:
                prim_x.append(a); prim_y.append(b)
    plt.figure(figsize=(7, 7))
    sc = plt.scatter(xs, ys, c=cs, cmap='viridis', s=60)
    plt.scatter(prim_x, prim_y, facecolors='none', edgecolors='red',
                s=140, label='primitive seed')
    plt.colorbar(sc, label='hypotenuse a^2 + b^2')
    plt.xlabel('a = Re z'); plt.ylabel('b = Im z')
    plt.title('Gaussian seeds colored by generated hypotenuse')
    plt.legend(); plt.tight_layout()
    plt.savefig('gaussian_seed_lattice.png', dpi=150)
    print('wrote gaussian_seed_lattice.png')

if __name__ == '__main__':
    main()
