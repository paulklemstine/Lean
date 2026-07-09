import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    p = 5
    ang = {x: 2 * np.pi * x / p for x in range(p)}
    pts = {x: (np.cos(ang[x]), np.sin(ang[x])) for x in range(p)}
    plt.figure(figsize=(6, 6))
    for x in range(p):
        y = pow(x, p, p)
        x0, y0 = pts[x]; x1, y1 = pts[y]
        plt.annotate('', xy=(x1, y1), xytext=(x0, y0),
                     arrowprops=dict(arrowstyle='->', color='crimson'))
        plt.plot(*pts[x], 'o', ms=18, color='steelblue')
        plt.text(x0 * 1.15, y0 * 1.15, str(x), ha='center', va='center')
    plt.title('x -> x^5 on Z/5Z: every point is fixed')
    plt.axis('equal'); plt.axis('off'); plt.tight_layout()
    plt.savefig('clock_fifth_power.png', dpi=150)
    print('saved clock_fifth_power.png')

if __name__ == '__main__':
    main()
