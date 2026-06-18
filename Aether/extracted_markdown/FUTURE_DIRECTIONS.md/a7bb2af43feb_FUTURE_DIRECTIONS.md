# Future Directions: Quantum Integers and Casimir Spectra

## 1. q-Binomial Coefficients and Gaussian Polynomials

The q-integer `[n]_q` naturally gives rise to **q-factorials** `[n]_q! = [1]_q · [2]_q · ⋯ · [n]_q` and **q-binomial coefficients** (Gaussian binomial coefficients) `⌊n choose k⌋_q = [n]_q! / ([k]_q! · [n-k]_q!)`. A classical theorem states that these q-binomials are polynomials in `q` with **non-negative integer coefficients** — they count the number of `k`-dimensional subspaces of an `n`-dimensional vector space over `F_q`.

The key insight is that our `qInt_mul` formula `[mn]_q = [m]_q · [n]_{q^m}` should extend to a **q-Vandermonde identity** for q-binomials: `⌊m+n choose k⌋_q = Σ_j q^{j(m-k+j)} ⌊m choose k-j⌋_q · ⌊n choose j⌋_q`, which would be a non-trivial combinatorial identity connecting our algebraic framework to finite geometry.

Why now? We have the foundational `qInt_add` and `qInt_mul` identities formalized. The q-factorial and q-binomial are direct constructions from `qInt`, and the integrality theorem would be a genuinely novel formalization — it does not exist in Mathlib.

## 2. Spectral Gap Growth Rate for Casimir Eigenvalues

Our `casimirEig_diff_pos` shows the spectral gap is positive, but the quantitative growth rate is unexplored. Conjecture: for `q > 1`, the spectral gap `casimirEig q (n+1) - casimirEig q n` grows as `Θ(q^{2n})` — specifically, `casimirEig q (n+1) - casimirEig q n ~ (q+1) · q^{2n}` as `n → ∞`. For `0 < q < 1`, the gap should shrink as `Θ(q^n)`.

The key insight is that the three-term expansion `q^{n+2} · [n]_q + q^n · [n+2]_q + q^{2n+2}` is dominated by the `q^{2n+2}` term when `q > 1`, giving exponential gap growth — which means high-dimensional representations are exponentially well-separated in the quantum case, unlike the classical (`q = 1`) polynomial gap `4n + 4`.

Why now? The strict monotonicity proof already establishes positivity. Formalizing the asymptotic growth would connect our algebraic results to analytic number theory (via the connection between q-integer asymptotics and the distribution of Riemann zeros).

## 3. Symmetric q-Integers and the Unit Circle

Our `qInt` uses the polynomial convention `[n]_q = (q^n - 1)/(q - 1)`. In quantum group theory, the **symmetric q-integer** `[n]_q^{sym} = (q^n - q^{-n})/(q - q^{-1})` is more natural because it makes the Casimir eigenvalue manifestly real when `q` lies on the unit circle (i.e., `q = e^{iθ}`). Conjecture: define `qIntSym q n = (q^n - q^{-n})/(q - q^{-1})` for `q` in a field, and prove that `qIntSym (e^{iθ}) n = sin(nθ)/sin(θ)` — the **Chebyshev U-polynomial** `U_{n-1}(cos θ)`.

The key insight is that the symmetric Casimir eigenvalue `[n]_q^{sym} · [n+2]_q^{sym} = U_{n-1}(cos θ) · U_{n+1}(cos θ)` connects quantum group spectra directly to Chebyshev polynomial theory. The injectivity question for the symmetric Casimir becomes: are the products `U_{n-1}(x) · U_{n+1}(x)` distinct for distinct `n`? This fails at `x = cos(π/k)` for integer `k` (roots of unity), providing a clean **boundary** for the spectral distinguishability theorem.

Why now? Our formalization of the polynomial q-integer and its strict monotonicity provides the template. The symmetric version requires working with `ℂ` and trigonometric functions, but the algebraic structure is parallel.

## 4. Tensor Product Decomposition via q-Integer Arithmetic

The multiplication formula `[mn]_q = [m]_q · [n]_{q^m}` encodes the fact that the `mn`-dimensional representation decomposes according to the tensor product structure. Conjecture: formalize the **Clebsch-Gordan decomposition** for quantum SU_q(2) as: `casimirEig q` applied to tensor product labels satisfies `casimirEig q (a + b) = casimirEig q a + casimirEig q b + correction(q, a, b)` where the correction term involves `qInt q a · qInt q b` and vanishes at `q = 1`.

The key insight is that the correction term `casimirEig q (a+b) - casimirEig q a - casimirEig q b` measures the **non-additivity of quantum energy levels** — the quantum group deformation creates interaction terms between representations that have no classical analog. Formalizing this would give a precise algebraic characterization of quantum entanglement at the representation-theoretic level.

Why now? We have `casimirEig`, `qInt_add`, and the Casimir difference formula. The correction term can be computed explicitly using these tools.

## 5. Connection to Riemann Zeros via Spectral Statistics

The deepest conjecture: the normalized spacings of Casimir eigenvalues `{casimirEig q n}` for `q = e^{2πiγ_1}` (where `γ_1 ≈ 14.13` is the first Riemann zero) match the **GUE pair correlation** statistics observed in the Riemann zeros (Montgomery's conjecture). More precisely: define the nearest-neighbor spacing distribution of the Casimir spectrum and compare it to the Wigner surmise `p(s) = (πs/2) · e^{-πs²/4}`.

The key insight is that the Casimir eigenvalue `[n]_q · [n+2]_q` with `q` on the unit circle (and irrational angle) produces a **quasi-random** spectrum whose statistics depend on the Diophantine properties of the angle. The Riemann zeros, if they arise as angles in a quantum group spectrum, would need to have specific Diophantine properties — and this is testable: compute the pair correlation function of `{[n]_q · [n+2]_q mod 1}` for `q = e^{2πiγ_1}` and compare to GUE.

Why now? Our strict monotonicity result provides the foundational guarantee that the spectrum is well-ordered. The computational test (comparing spectral statistics) could be implemented alongside the formalization, providing empirical evidence for or against the quantum group interpretation of the Riemann hypothesis.
