import matplotlib.pyplot as plt
import numpy as np

def chebyshev_approx_error(f, degree, a=0, b=1, num_eval=500):
    k = np.arange(1, degree + 2)
    nodes = 0.5*(a+b) + 0.5*(b-a)*np.cos((2*k-1)*np.pi/(2*(degree+1)))
    values = f(nodes)
    x_eval = np.linspace(a, b, num_eval)
    p_eval = np.zeros(num_eval)
    for i in range(len(nodes)):
        term = values[i] * np.ones(num_eval)
        for j in range(len(nodes)):
            if i != j:
                term *= (x_eval - nodes[j]) / (nodes[i] - nodes[j])
        p_eval += term
    return np.max(np.abs(f(x_eval) - p_eval))

def compute_spectrum(f, epsilons, max_deg=100):
    spectrum = []
    for eps in epsilons:
        for d in range(1, max_deg):
            err = chebyshev_approx_error(f, d)
            if err < eps:
                spectrum.append(2*d+1)
                break
        else:
            spectrum.append(2*max_deg+1)
    return spectrum

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

epsilons = np.logspace(-1, -8, 20)

f1 = lambda x: np.sin(2*np.pi*x)
f2 = lambda x: np.abs(x - 0.5)
f3 = lambda x: np.sin(20*np.pi*x)

spec1 = compute_spectrum(f1, epsilons)
spec2 = compute_spectrum(f2, epsilons)
spec3 = compute_spectrum(f3, epsilons)

ax1.semilogx(epsilons, spec1, 'b-o', label='sin(2πx)', markersize=4)
ax1.semilogx(epsilons, spec2, 'r-s', label='|x-0.5|', markersize=4)
ax1.semilogx(epsilons, spec3, 'g-^', label='sin(20πx)', markersize=4)
ax1.set_xlabel('Tolerance ε')
ax1.set_ylabel('EML Tree Size Ψ(ε)')
ax1.set_title('EML Approximation Spectrum')
ax1.legend()
ax1.grid(True, alpha=0.3)
ax1.invert_xaxis()

# Right: approximation quality vs degree
x = np.linspace(0, 1, 500)
degrees = range(1, 30)
errs1 = [chebyshev_approx_error(f1, d) for d in degrees]
errs2 = [chebyshev_approx_error(f2, d) for d in degrees]

ax2.semilogy(degrees, errs1, 'b-o', label='sin(2πx)', markersize=4)
ax2.semilogy(degrees, errs2, 'r-s', label='|x-0.5|', markersize=4)
ax2.set_xlabel('Polynomial Degree')
ax2.set_ylabel('Max Approximation Error')
ax2.set_title('Convergence Rate: Analytic vs Lipschitz')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('approximation_spectrum.png', dpi=150, bbox_inches='tight')
plt.show()