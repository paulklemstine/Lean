import numpy as np
import matplotlib.pyplot as plt

def main() -> None:
    coeffs = [0.0, 1.0, 3.0]
    slopes = [0.0, 1.0, 2.0]
    xs = np.linspace(-4, 2, 400)
    lines = [c + s * xs for c, s in zip(coeffs, slopes)]
    env = np.min(np.stack(lines), axis=0)
    plt.figure(figsize=(7, 5))
    for c, s, ln in zip(coeffs, slopes, lines):
        plt.plot(xs, ln, '--', alpha=0.6, label=f'{c}+{s}x')
    plt.plot(xs, env, 'k-', linewidth=2.5, label='eval = min')
    plt.title('Tropical polynomial as lower envelope of affine monomials')
    plt.xlabel('x'); plt.ylabel('value'); plt.legend()
    plt.savefig('trop_envelope.png', dpi=150, bbox_inches='tight')
    print('saved trop_envelope.png')

if __name__ == '__main__':
    main()
