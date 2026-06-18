# Future Directions: Scaling Laws from Spectral Decay

## 1. General Power-Law Exponent α > 1

We proved the scaling law for the special case α = 2 (eigenvalues λ_k = 1/k²),
obtaining the exponent -1/2. The natural generalization: for eigenvalues decaying
as k^{-α} with α > 1, the tail sum ∑_{k>M} k^{-α} should be bounded by
C · M^{1-α}/(α-1), giving a scaling exponent -(α-1)/α.

The key insight is that the telescoping argument generalizes via the integral
comparison test: 1/k^α ≤ ∫_{k-1}^{k} x^{-α} dx, and the integral telescopes
to give the M^{1-α} bound. This requires formalizing improper integrals over
[M, ∞) in Lean.

Why now? Mathlib's measure theory and integration libraries have matured enough
to support interval integrals of power functions, making the integral comparison
test formalizable.

## 2. Double Descent and Interpolation Threshold

Our bias-variance framework assumes the classical regime M < N. When M ≈ N
(interpolation threshold), the variance diverges, producing the "double descent"
phenomenon. Formalizing this requires showing that the minimum of 1/M + M/(N-M)
over 1 ≤ M < N has qualitatively different behavior from 1/M + M/N.

The key insight is that replacing the variance term M/N with M/(N-M) introduces
a pole at M = N, and the optimization landscape changes from a single minimum
to a problem requiring separate analysis on each side of the interpolation
threshold.

Why now? The double descent phenomenon has been empirically validated across many
architectures, but no rigorous mathematical proof from spectral assumptions exists.
The bias-variance framework we formalized is the right starting point.

## 3. Multivariate Scaling Laws: Compute-Optimal Allocation

Real scaling laws involve three resources: model size M, dataset size N, and
compute budget C ≈ M·N. Given C, one must jointly optimize M and N subject to
M·N ≤ C. Formalizing this as a constrained optimization problem:
minimize 1/M + M/N subject to M·N = C, yielding M* ~ C^{1/3}, N* ~ C^{2/3}
(for α = 2).

The key insight is that the Lagrange multiplier method reduces to a
single-variable optimization after substituting the constraint, and the resulting
scaling M* ~ C^{α/(2α+1)} captures the Chinchilla-type compute-optimal laws.

Why now? The one-variable AM-GM result we proved is the core tool; extending it
to constrained optimization requires only elementary calculus (which is increasingly
well-supported in Mathlib via `HasDerivAt` and `IsLocalMin`).

## 4. Kernel Eigenvalue Decay from Architecture

We assumed power-law eigenvalue decay as given. A deeper result would derive
this decay from the architecture: for a single hidden-layer neural network with
random weights (the NNGP/NTK regime), the kernel eigenvalues on the sphere S^{d-1}
decay as k^{-(d+1)/d} in the Mercer expansion.

The key insight is that the NNGP kernel is a dot-product kernel on the sphere,
whose Mercer expansion in spherical harmonics has coefficients determined by the
activation function's Gegenbauer expansion. The decay rate is dictated by the
smoothness of the activation.

Why now? Mathlib has spherical harmonics foundations and Gegenbauer polynomial
support is growing. Formalizing this connection would close the gap between
architecture and scaling exponent.

## 5. Information-Theoretic Lower Bounds

Our results give upper bounds on optimal error. A matching lower bound would show
that no estimator (not just kernel truncation) can achieve better than N^{-(α-1)/α}
scaling when the target lies in the RKHS with spectral decay α. This is a minimax
lower bound via Fano's inequality or Assouad's lemma.

The key insight is that the lower bound follows from packing the RKHS unit ball
with functions that are mutually distinguishable only with N^{(α-1)/α} samples,
using the eigenvalue decay to control the packing number.

Why now? Fano's inequality and basic information-theoretic tools are formalizable
in Lean's probability library. Combined with our spectral framework, this would
yield a complete characterization of optimal rates.
