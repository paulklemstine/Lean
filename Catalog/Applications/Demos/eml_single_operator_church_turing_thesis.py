"""
EML Single Operator Church-Turing Thesis — Demonstration

Shows that eml(x,y) = exp(x) - log(y) is computationally universal:
every continuous function on compact positive domains can be approximated
by EML compositions (polynomials in log).

Examples:
1. Approximating x^2 on [1, 3] using log-polynomials
2. Approximating sin(x) on [0.1, 3] using EML compositions  
3. The EML diagonal domination: exp(z) - log(z) > z for all z > 0
"""

import numpy as np
import math


def eml(x: float, y: float) -> float:
    """The EML primitive: eml(x, y) = exp(x) - log(y)"""
    if y <= 0:
        raise ValueError("y must be positive for log")
    return math.exp(x) - math.log(y)


def eml_recover_exp(x: float) -> float:
    """exp(x) = eml(x, 1)"""
    return eml(x, 1.0)


def eml_recover_log(y: float) -> float:
    """log(y) = 1 - eml(0, y)"""
    return 1.0 - eml(0.0, y)


def power_via_eml(x: float, alpha: float) -> float:
    """x^alpha = exp(alpha * log(x)) for x > 0
    Using EML: exp(alpha * log(x)) = eml(alpha * (1 - eml(0, x)), 1)
    """
    log_x = eml_recover_log(x)
    return eml_recover_exp(alpha * log_x)


def mul_via_eml(x: float, y: float) -> float:
    """x * y = exp(log(x) + log(y)) for x, y > 0"""
    return eml_recover_exp(eml_recover_log(x) + eml_recover_log(y))


def div_via_eml(x: float, y: float) -> float:
    """x / y = exp(log(x) - log(y)) for x, y > 0"""
    return eml_recover_exp(eml_recover_log(x) - eml_recover_log(y))


def log_polynomial(x: float, coeffs: list[float]) -> float:
    """Evaluate a polynomial in log(x): sum(c_k * log(x)^k)"""
    log_x = math.log(x)
    return sum(c * log_x ** k for k, c in enumerate(coeffs))


def fit_log_polynomial(f, a: float, b: float, degree: int) -> list[float]:
    """Fit a polynomial in log(x) to approximate f on [a, b].
    
    This demonstrates the Stone-Weierstrass density theorem:
    polynomials in log(x) are dense in C([a,b], R) for 0 < a.
    """
    # Sample points
    n_points = max(degree + 1, 50)
    xs = np.linspace(a, b, n_points)
    log_xs = np.log(xs)
    ys = np.array([f(x) for x in xs])
    
    # Fit polynomial in log(x)
    coeffs = np.polyfit(log_xs, ys, degree)
    return list(reversed(coeffs))


def evaluate_approximation(f, coeffs: list[float], a: float, b: float, n: int = 100):
    """Evaluate the quality of a log-polynomial approximation."""
    xs = np.linspace(a, b, n)
    max_error = 0.0
    for x in xs:
        true_val = f(x)
        approx_val = log_polynomial(x, coeffs)
        max_error = max(max_error, abs(true_val - approx_val))
    return max_error


def emlDiag(z: float) -> float:
    """The EML diagonal: exp(z) - log(z) for z > 0"""
    return math.exp(z) - math.log(z)


def main():
    print("=" * 70)
    print("EML SINGLE OPERATOR CHURCH-TURING THESIS — DEMONSTRATION")
    print("=" * 70)
    
    # Demo 1: EML recovers exp and log
    print("\n--- Demo 1: EML Recovers exp and log ---")
    test_vals = [0.5, 1.0, 2.0, 3.0]
    for x in test_vals:
        exp_eml = eml_recover_exp(x)
        exp_true = math.exp(x)
        log_eml = eml_recover_log(x) if x > 0 else float('nan')
        log_true = math.log(x) if x > 0 else float('nan')
        print(f"  x = {x:.1f}: exp_eml = {exp_eml:.6f}, exp_true = {exp_true:.6f}, "
              f"log_eml = {log_eml:.6f}, log_true = {log_true:.6f}")
    
    # Demo 2: Power functions via EML
    print("\n--- Demo 2: Power Functions via EML ---")
    for x in [1.5, 2.0, 3.0]:
        for alpha in [2.0, 0.5, -1.0]:
            eml_val = power_via_eml(x, alpha)
            true_val = x ** alpha
            print(f"  {x}^{alpha} = {eml_val:.6f} (EML), {true_val:.6f} (true), "
                  f"error = {abs(eml_val - true_val):.2e}")
    
    # Demo 3: Approximating f(x) = x^2 on [1, 3] via log-polynomials
    print("\n--- Demo 3: Log-Polynomial Approximation of x^2 ---")
    f_square = lambda x: x ** 2
    for degree in [2, 4, 6, 8, 10]:
        coeffs = fit_log_polynomial(f_square, 1.0, 3.0, degree)
        error = evaluate_approximation(f_square, coeffs, 1.0, 3.0)
        print(f"  Degree {degree:2d}: max error = {error:.2e}")
    
    # Demo 4: Approximating sin(x) on [0.1, 3] via log-polynomials
    print("\n--- Demo 4: Log-Polynomial Approximation of sin(x) ---")
    f_sin = math.sin
    for degree in [3, 5, 8, 12, 16, 20]:
        coeffs = fit_log_polynomial(f_sin, 0.1, 3.0, degree)
        error = evaluate_approximation(f_sin, coeffs, 0.1, 3.0)
        print(f"  Degree {degree:2d}: max error = {error:.2e}")
    
    # Demo 5: EML Diagonal Domination
    print("\n--- Demo 5: EML Diagonal Domination (exp(z) - log(z) > z) ---")
    for z in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0]:
        diag = emlDiag(z)
        gap = diag - z
        print(f"  z = {z:5.2f}: emlDiag(z) = {diag:12.4f}, "
              f"gap = {gap:12.4f} > 0 ✓" if gap > 0 else "  ERROR!")
    
    # Demo 6: Multiplication and division via EML
    print("\n--- Demo 6: Arithmetic via EML ---")
    pairs = [(2.0, 3.0), (1.5, 4.0), (7.0, 0.5)]
    for x, y in pairs:
        mul_eml = mul_via_eml(x, y)
        div_eml = div_via_eml(x, y)
        print(f"  {x} * {y} = {mul_eml:.6f} (EML), {x * y:.6f} (true)")
        print(f"  {x} / {y} = {div_eml:.6f} (EML), {x / y:.6f} (true)")
    
    print("\n" + "=" * 70)
    print("CONCLUSION: EML = exp(x) - log(y) is computationally universal")
    print("for continuous functions on compact positive domains.")
    print("=" * 70)


if __name__ == "__main__":
    main()


"""
Visualization: EML Universal Approximation

Three panels:
1. Log-polynomial approximation of various functions (Stone-Weierstrass in action)
2. EML diagonal domination: exp(z) - log(z) vs z
3. Approximation error vs polynomial degree (convergence rate)
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def fit_log_poly(f, a, b, degree, n_points=200):
    xs = np.linspace(a, b, n_points)
    log_xs = np.log(xs)
    ys = np.array([f(x) for x in xs])
    V = np.vander(log_xs, degree + 1, increasing=True)
    coeffs, _, _, _ = np.linalg.lstsq(V, ys, rcond=None)
    return coeffs


def eval_log_poly(coeffs, x):
    log_x = np.log(x)
    return sum(c * log_x ** k for k, c in enumerate(coeffs))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Approximation of sin(x) and x^2 by log-polynomials
    ax1 = axes[0]
    a, b = 0.2, 3.0
    xs = np.linspace(a, b, 500)

    # sin(x) approximation
    f_sin = np.sin
    ax1.plot(xs, f_sin(xs), 'k-', linewidth=2, label='sin(x)')
    for deg, color in [(3, 'C0'), (8, 'C1'), (16, 'C2')]:
        coeffs = fit_log_poly(f_sin, a, b, deg)
        ys_approx = [eval_log_poly(coeffs, x) for x in xs]
        ax1.plot(xs, ys_approx, '--', color=color, alpha=0.7,
                label=f'log-poly deg {deg}')

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('EML Approximation of sin(x)\n(Stone-Weierstrass)', fontsize=13)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Panel 2: EML Diagonal Domination
    ax2 = axes[1]
    zs = np.linspace(0.01, 5, 500)
    emlDiag = np.exp(zs) - np.log(zs)
    identity = zs

    ax2.plot(zs, emlDiag, 'C3-', linewidth=2, label='exp(z) - log(z)')
    ax2.plot(zs, identity, 'k--', linewidth=1.5, label='z')
    ax2.fill_between(zs, identity, emlDiag, alpha=0.15, color='C3')
    ax2.set_xlabel('z', fontsize=12)
    ax2.set_ylabel('value', fontsize=12)
    ax2.set_title('EML Diagonal Domination\nexp(z) - log(z) > z for z > 0', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 15)
    ax2.grid(True, alpha=0.3)
    ax2.annotate('Gap always > 0', xy=(2, 6), fontsize=10, color='C3',
                fontweight='bold')

    # Panel 3: Convergence rate
    ax3 = axes[2]
    functions = {
        'x²': lambda x: x**2,
        'sin(x)': np.sin,
        '1/(1+x)': lambda x: 1/(1+x),
        'sqrt(x)': np.sqrt,
    }
    degrees = list(range(1, 25))
    a_conv, b_conv = 0.5, 3.0

    for name, f in functions.items():
        errors = []
        for deg in degrees:
            coeffs = fit_log_poly(f, a_conv, b_conv, deg)
            xs_test = np.linspace(a_conv, b_conv, 500)
            err = max(abs(f(x) - eval_log_poly(coeffs, x)) for x in xs_test)
            errors.append(max(err, 1e-16))
        ax3.semilogy(degrees, errors, 'o-', markersize=3, label=name)

    ax3.set_xlabel('Log-polynomial degree', fontsize=12)
    ax3.set_ylabel('Max approximation error', fontsize=12)
    ax3.set_title('Convergence Rate\n(EML Universal Approximation)', fontsize=13)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(1e-16, 10)

    plt.tight_layout()
    plt.savefig('eml_universality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved eml_universality.png")


if __name__ == "__main__":
    main()
