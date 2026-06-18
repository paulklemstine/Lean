# Future Directions: Inverse Stereographic Renormalization Group

## 1. Complex Möbius Transformations and Hyperbolic Fixed Points

The current formalization works over ℝ, where `stereoRot(s)` has negative discriminant (elliptic type) for generic angles, meaning fixed points live in ℂ. The natural next step is to extend `RealMobius` to `ComplexMobius` (or work with `GL₂(ℂ)` directly) and classify transformations into elliptic (|tr| < 2), parabolic (|tr| = 2), and hyperbolic (|tr| > 2) types. The key insight is that the multiplier at complex fixed points determines the local RG flow topology: elliptic gives periodic orbits, parabolic gives power-law decay, and hyperbolic gives exponential convergence — exactly the three universality classes of critical behavior. Why now? We have `multiplier_sum_eq_tr_sq_sub_two` proved over ℝ, and Mathlib's `Complex` library is mature enough to support the extension.

**Testable conjecture**: For a complex Möbius transformation with `|tr²/det| > 4`, the multipliers λ₁, λ₂ at the two fixed points satisfy `λ₁ · λ₂ = 1`, and the iterates `f^n(x)` converge to the fixed point with |λ| < 1 for any starting point in the basin of attraction. Formalize the convergence rate as `‖f^n(x) - p‖ ≤ C · |λ|^n`.

## 2. Higher-Dimensional Conformal Groups and Liouville's Theorem

The 1D theory connects Möbius transformations (PSL₂(ℝ)) to S¹ via stereographic projection. In higher dimensions, the conformal group of Sⁿ is SO(n+1,1), and Liouville's rigidity theorem states that for n ≥ 3, every conformal map of an open subset of ℝⁿ is a Möbius transformation. The key insight is that this rigidity result is exactly the statement that the RG flow in dimensions ≥ 3 is constrained to lie in a finite-dimensional group — there are no "anomalous" RG flows, which is the geometric content of the c-theorem in 2D conformal field theory. Why now? Mathlib has `Stereographic` for the n-sphere and smooth manifold infrastructure.

**Testable conjecture**: Formalize the conformal group action of `O(n+1,1)` on `EuclideanSpace ℝ (Fin n)` via stereographic coordinates and prove that the composition law for n-dimensional Möbius transformations has `det(fg) = det(f) · det(g)` with `det` now being the determinant of the (n+2)×(n+2) matrix representation.

## 3. 1D Ising Model: Exact Beta Function Computation

The 1D Ising model has transfer matrix `T = [[exp(K), exp(-K)], [exp(-K), exp(K)]]` where `K = J/kT` is the reduced coupling. The RG transformation for block-spin doubling sends `K → K'` where `tanh(K') = tanh(K)²`. The key insight is that this RG map is conjugate (via `K = arctanh(t)`) to `t ↦ t²`, which is NOT a Möbius transformation but whose logarithm `log t ↦ 2 log t` IS linear — the "linearized RG" near the fixed point at `t = 0` (infinite temperature) has multiplier 2, while near `t = 1` (zero temperature) has multiplier 0. Our `multiplier_at_fixed_pt_eq` theorem can verify these values if we embed the Ising RG map into the Möbius framework via suitable coordinates. Why now? We have the fixed-point and multiplier machinery fully proved.

**Testable conjecture**: Define the 1D Ising RG map as `t ↦ t²` (in the tanh variable) and verify that its derivative at the unstable fixed point `t = 0` is 0 and at `t = 1` is 2, matching the known critical exponent `ν = 1/log(2)` via the relation `λ = b^(1/ν)` with `b = 2` (block size).

## 4. Trace-Multiplier Duality and Spectral Zeta Functions

Our `multiplier_sum_eq_tr_sq_sub_two` theorem establishes that for normalized Möbius maps, the sum of multipliers at the two fixed points equals `tr² - 2`. This is a shadow of a deeper trace formula: the Selberg trace formula relates sums over closed geodesics (= conjugacy classes of Möbius maps = RG cycles) to spectral data (= eigenvalues of the Laplacian = energy levels). The key insight is that our multiplier-trace duality is the rank-1 case of the Selberg trace formula, and extending it to iterated maps `f^n` would give the dynamical zeta function `Z(s) = ∏_p (1 - |λ_p|^(-s))⁻¹` summed over periodic orbits. Why now? The `comp_det` and `multiplier_comp` theorems provide the composition law needed to compute multipliers of iterates.

**Testable conjecture**: For the n-th iterate of a hyperbolic Möbius transformation with multiplier λ, prove that `(f^n).multiplier(p) = λⁿ` at the fixed point p, and that the dynamical zeta function `Z(s) = (1 - λ^(-s))⁻¹ · (1 - λ^s)⁻¹` has poles at `s = 2πik/log(λ)` — the "Ruelle resonances."

## 5. Cross-Domain Bridge: Möbius Arithmetic and Farey Fractions

The Möbius maps with integer coefficients (the original `MobiusMap` from HyperbolicNumberTheory) act on ℚ ∪ {∞} and generate the Farey graph. Each edge of the Farey graph corresponds to a pair of Farey neighbors p/q and r/s with |ps - qr| = 1. The key insight is that the "RG flow" on the Farey graph — coarse-graining by removing every other vertex — is exactly the mediant operation (p+r)/(q+s), and the "beta function" at a rational fixed point p/q of the continued fraction expansion measures the rate of convergence of the CF approximants, which equals the Lyapunov exponent of the corresponding `MobiusMap` orbit. This bridges our real Möbius theory to Diophantine approximation. Why now? We proved `comp_det`, `comp_assoc`, and `inv_comp` for `RealMobius`, and these specialize immediately to the integer case when the entries happen to be integers.

**Testable conjecture**: For the golden ratio φ = (1+√5)/2, the continued fraction `[1;1,1,1,...]` corresponds to iterating the Möbius map `T(x) = 1/(1+x)` which has `T(φ) = φ`. Verify that the multiplier `T'(φ) = -1/(1+φ)² = -1/φ²` and that `|T'(φ)| = 1/φ² < 1`, confirming that φ is an attracting fixed point of the CF algorithm with convergence rate φ⁻² — the slowest possible convergence, making φ the "hardest number to approximate."
