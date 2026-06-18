# Future Directions: Ising Partition Function Stability Theory

## 1. Optimal Constants in the Coupling Noise Bound

We proved that the 1/n² robustness scale is tight up to a multiplicative constant (the sharp_coupling_noise_scale_conjecture, now a theorem using c = 5n²). The natural next question is: **what is the exact optimal constant c* such that for c < c*, every gapped-Lorentzian coupling matrix preserves its signature under c·ε/n²-perturbation, and for c > c*, there exist counterexamples?**

The key insight is that the optimal constant should depend on the geometry of the gapped signature—specifically, the ratio between the gap ε and the operator norm of J. For diagonal matrices the threshold is c* = 1 (matching our certified_robustness_preserves_signature with factor 1/2), but for non-diagonal matrices with large off-diagonal entries the threshold could be smaller.

Why now? The sharp_coupling_noise_scale_conjecture proof constructs explicit diagonal counterexamples. Extending to the non-diagonal case requires understanding how eigenvector delocalization affects the perturbation sensitivity, connecting to random matrix theory. The formal infrastructure for quadratic form bounds (quadFormBound_of_entry_bound) is now in place.

## 2. Phase Transition Detection via Lorentzian Signature Change

The combined_robustness theorem shows that small coupling perturbations preserve the Lorentzian signature. **Conversely, can we detect phase transitions by monitoring when the Lorentzian signature changes?** Specifically: for the 2D Ising model on an n×n lattice with nearest-neighbor coupling J, does the Hessian of log Z transition from Lorentzian to non-Lorentzian exactly at the Onsager critical temperature β_c = ln(1+√2)/(2J)?

The key insight is that the susceptibility matrix (whose positive semidefiniteness we proved in covarianceForm_nonneg) diverges at the critical point, and this divergence is precisely the breakdown of the gapped Lorentzian property. The spectral gap ε should vanish as β → β_c.

Why now? We have the formal connection between covariance forms and Lorentzian quadratic forms (covarianceForm_eq_variance). The missing piece is a quantitative lower bound on the spectral gap in terms of β - β_c, which would give a formal proof that Lorentzian stability theory "sees" the Onsager transition.

## 3. Extension to Complex Couplings and Lee-Yang Theory

The isingPartition_logLipschitz theorem bounds the sensitivity of the real partition function. **Does an analogous stability result hold for the partition function viewed as a polynomial in complex fugacities?** The Lee-Yang theorem states that the zeros of Z lie on the unit circle in the fugacity plane.

The key insight is that Lorentzian polynomials (which have real, interlacing roots in each variable) are a real analogue of Lee-Yang polynomials (which have unimodular roots). A unified stability theory should show that small coupling perturbations preserve root location—on the real line for Lorentzian polynomials, and on the unit circle for Lee-Yang polynomials.

Why now? The gibbsVariance_nonneg and covarianceForm_nonneg results establish the positive semidefiniteness of the susceptibility matrix, which in the complex setting becomes a condition on the locations of Fisher zeros. The isingPartition_zero_coupling factorization theorem provides a base case where the zeros are exactly computable.

## 4. Concentration of Free Energy per Site

The isingPartition_logLipschitz theorem gives absolute bounds on log Z. For large systems, physicists expect **self-averaging**: the free energy per site f_n = -(1/βn) log Z converges as n → ∞ and concentrates around its mean under random coupling disorder. Can we prove a formal concentration inequality?

The key insight is that log Z is a Lipschitz function of the n² coupling entries (with Lipschitz constant β by our theorem), so by standard concentration inequalities (Gaussian or bounded-differences), f_n concentrates with variance O(1/n²). This is the rigorous version of the physicist's claim that "the free energy is self-averaging."

Why now? The Lipschitz bound is already proved. What's needed is to formalize the bounded-differences inequality (McDiarmid's inequality) in Mathlib and apply it to the coupling matrix entries viewed as independent random variables. The gibbsExpectation linearity results (gibbsExpectation_add, gibbsExpectation_smul) provide the algebraic infrastructure for working with expectations.

## 5. Multilinear Extension and Lorentzian Polynomial Characterization

The Ising partition function Z(h) = Σ_σ exp(β E(σ)) can be rewritten as a multiaffine polynomial in variables x_i = exp(2β h_i). **Is this multiaffine polynomial Lorentzian (in the sense of Brändén–Huh) if and only if the coupling matrix has at most one positive eigenvalue?** This would complete the bridge between statistical mechanics and algebraic combinatorics.

The key insight is that the partition function with zero field, viewed as a polynomial in the exponential field variables, has coefficients that are weighted sums over spin configurations—and the sign pattern of the Hessian of log Z (which we connected to the covariance form) should control whether these coefficients satisfy the Lorentzian condition.

Why now? The covarianceForm_eq_variance theorem establishes that the Hessian of log Z equals the covariance matrix. The isingPartition_zero_coupling factorization shows that at J=0, Z factors as a product of linear terms, which is trivially Lorentzian. The HasGappedSignature and HasAtMostOnePositiveEigenvalue definitions provide the formal framework for stating and proving the characterization.
