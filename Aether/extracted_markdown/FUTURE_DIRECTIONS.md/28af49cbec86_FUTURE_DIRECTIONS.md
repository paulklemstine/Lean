# Future Directions: Spectral Scaling Laws

## 1. Quantitative Spectral Truncation Bounds via Integral Comparison

The current `tail_sum_antitone` theorem establishes monotonicity of the approximation error but does not give quantitative rates. For a spectral profile with eigenvalue decay λ_k ~ C·k^(-α), the tail sum should satisfy

  Σ_{k≥P} λ_k ≤ C'·P^(-(α-1))

for α > 1, via comparison with the integral ∫_P^∞ t^(-α) dt = P^(-(α-1))/(α-1). The key insight is that this integral comparison (Euler-Maclaurin at zeroth order) converts the discrete spectral decay rate α into the continuous approximation error rate α-1, which is exactly the bias exponent observed empirically in neural scaling laws. Why now? Mathlib's `Antitone.sum_le_integral` and related integral-sum comparison lemmas are now mature enough to make this formalization tractable. This would close the gap between our abstract spectral framework and the concrete power-law exponents measured in practice.

**Testable prediction**: For the Matérn-ν kernel on [0,1]^d with ν > d/2, the eigenvalues decay as k^(-2ν/d - 1) (Weyl's law), predicting a bias exponent of 2ν/d. This is computationally verifiable by diagonalizing the kernel matrix for moderate d and ν.

## 2. Multi-Resource Scaling with n-way Compute Allocation

Our theorems handle two-resource allocation (parameters P and data D). Real training involves at least three resources: parameters, data, and training steps (epochs). The generalized problem minimizes

  L = Σᵢ Aᵢ · xᵢ^(-αᵢ)  subject to  Π xᵢ = C

The key insight is that the n-resource harmonic exponent γ = (Σ 1/αᵢ)⁻¹ follows from the same Lagrange multiplier analysis, and the optimal allocation exponents eᵢ = (1/αᵢ)/(Σ 1/αⱼ) form a probability distribution over resources. This "resource attention" distribution is the mathematical dual of the attention mechanism in transformers — both allocate capacity according to importance weights. Why now? Our `optimal_exponents_sum_to_one` theorem already proves the partition-of-unity property for n=2; the generalization to n resources requires only Finset-indexed versions of the same algebraic identities.

**Testable prediction**: For 3-resource scaling (P, D, epochs E) with measured exponents α_P ≈ 0.076, α_D ≈ 0.095, α_E ≈ 0.050 (from Hoffmann et al.), the theory predicts γ₃ = (1/0.076 + 1/0.095 + 1/0.050)⁻¹ ≈ 0.024. This can be validated against compute-optimal training runs.

## 3. Phase Transitions in the Bias-Variance Landscape

Our `bias_strict_decrease` theorem shows bias is strictly monotone, but real neural networks exhibit phase transitions — sudden capability jumps at specific scales. The key insight is that phase transitions arise when the spectral gap (ratio λ_{P}/λ_{P+1}) is anomalously large, creating a "spectral cliff" where adding one eigenmode captures disproportionate variance. Formally, if the spectral profile has a gap g_P = λ_P/λ_{P+1} ≫ 1 at index P*, then the loss landscape has a local "plateau-then-drop" structure around P*, observable as an emergent capability. Why now? Our SpectralProfile structure already encodes the eigenvalue ordering; adding a `spectralGap` function and proving that large gaps create loss function inflection points would connect our continuous scaling theory to the discrete phenomenon of emergence.

**Testable prediction (falsifiable)**: If a language model exhibits an emergent capability at scale P*, then the NTK eigenspectrum at scale P*-1 should show a spectral gap ratio λ_{P*}/λ_{P*+1} > 10. This is testable by computing NTK spectra of small transformer models across scales.

## 4. Information-Theoretic Lower Bounds on Scaling Exponents

Our `harmonic_exponent_bounds` theorem shows γ < min(α, β), but does not establish whether the bound is tight. The key insight is that the harmonic exponent γ = αβ/(α+β) is actually achievable — it is not just an upper bound but the exact rate — and this can be proved by constructing an explicit kernel whose spectral profile achieves the bound with equality. The Matérn family provides such a construction: for Matérn-ν on [0,1]^d, the bias exponent α = 2ν/d and the variance exponent β = 1, giving γ = 2ν/(d+2ν), which matches the minimax rate for nonparametric regression in Sobolev spaces of order ν. This connects neural scaling laws to classical statistical learning theory. Why now? Mathlib now has solid foundations for Sobolev spaces and kernel reproducing Hilbert spaces that would support formalizing the minimax connection.

**Testable prediction**: No kernel method can achieve a scaling exponent γ > αβ/(α+β) under the spectral decay assumption λ_k ~ k^(-α). This lower bound should hold for any learning algorithm, not just kernel methods, when the target function lives in the RKHS. Computationally testable by comparing scaling curves of different architectures on synthetic data from known RKHS functions.

## 5. Cross-Domain Bridge: Scaling Laws and Thermodynamic Free Energy

The loss function L(P, D) = A·P^(-α) + B·D^(-β) has the mathematical structure of a free energy F = E - TS in statistical mechanics, where the bias term plays the role of internal energy (model capacity) and the variance term plays the role of entropic cost (data complexity). The key insight is that the critical point condition α·(bias) = β·(variance) — our `marginal_balance_identity` — is precisely the thermodynamic equilibrium condition ∂F/∂T = 0, and the harmonic exponent γ is the critical exponent of the associated phase transition. This suggests that neural scaling laws are instances of universality in the renormalization group sense. Why now? The Catalog already contains formalized results on thermodynamic quantities (in Physics/) and spectral theory (in Algebra/); bridging them through the scaling law framework would create a genuinely novel cross-domain connection. The marginal balance identity we proved is the formal bridge — it states that at optimum, the system is at a "thermal equilibrium" between approximation and estimation.

**Testable prediction**: If we define a "scaling susceptibility" χ = -∂²L*/∂(log C)² at the optimal allocation, then χ should diverge at the critical exponent ratio α/β = 1 (the symmetric point), analogous to a second-order phase transition. This is numerically testable.
