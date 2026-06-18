# Future Directions: Machine-Verified Analytic-Spectral Number Theory

## Hypothesis 1: Symmetrized Dirichlet Truncation Roots on the Critical Line

**Conjecture:** For the symmetrized truncated zeta polynomial defined by

$$Z_N(s) = \sum_{n=1}^{N} n^{-s} + \chi(s) \sum_{n=1}^{N} n^{s-1}$$

(where χ is the functional equation factor), all roots lie on Re(s) = 1/2 for N ≤ 100.

**Test:** Compute the roots of Z_N numerically for N = 2, 3, ..., 200 using high-precision arithmetic. Record the maximum deviation |Re(root) - 1/2| at each N. Identify the first N (if any) where a root deviates from the critical line by more than 10⁻⁶.

**Impact:** If true for small N, this validates the spectral certificate approach for finite truncations and suggests a constructive path to RH via controlled approximation. If false, the failure mode reveals which symmetry breaks as truncation increases, guiding the design of better spectral surrogates.

---

## Hypothesis 2: Arithmetic Hermitian Matrix Family with Convergent Coefficients

**Conjecture:** There exists a constructive family of Hermitian matrices H_N of dimension π(N) × π(N) (where π is the prime counting function), built from arithmetic data (e.g., log-prime-weighted adjacency of a divisibility graph), whose characteristic polynomial coefficients converge to those of the symmetrized Dirichlet truncation polynomial Z_N as N → ∞.

**Test:** For each N ∈ {10, 20, 50, 100, 200}, construct H_N as the matrix with entries h_{p,q} = log(p·q) / (p·q)^{1/2} for primes p, q ≤ N. Compare the first k = 5 coefficients of det(xI - H_N) with those of Z_N. Fit the convergence rate as a function of N and extrapolate.

**Impact:** Convergence would establish the first explicit, constructive link between arithmetic data and zeta-like zero structure — a concrete realization of the Hilbert–Pólya philosophy. This would be formalizable in Lean using our spectral bridge infrastructure. Divergence would constrain which arithmetic encodings are viable for the HP program.

---

## Hypothesis 3: Self-Inversive Criterion Captures All Critical-Line Roots for Low-Degree Zeta Models

**Conjecture:** For Dirichlet polynomial truncations P_N(z) = Σ_{n≤N} n^{-z} of degree ≤ 20 (after change of variable to polynomial form), the self-inversive root-pairing criterion (formally verified as `self_inversive_root_pairing`) exactly characterizes which roots lie on the critical line. Specifically: a root z lies on Re(z) = 1/2 if and only if it participates in a conjugate-reciprocal pair {z, 1/z̄} after the appropriate Möbius transformation centering the critical line.

**Test:** For N = 3, 4, ..., 25, compute roots of P_N and check (a) whether each critical-line root is paired with its conjugate reciprocal within tolerance 10⁻⁸, and (b) whether any off-line root also satisfies the pairing. Success means pairing ⟺ critical line. Search numerically for the first counterexample (a root satisfying pairing but with Re ≠ 1/2).

**Impact:** This would provide an algebraic certificate for critical-line membership, reducing a transcendental condition to a polynomial identity check. Our formal proof of root pairing makes this immediately machine-verifiable for any specific degree. If the equivalence holds, it opens a path to algorithmic verification of RH for finite models.

---

## Hypothesis 4: GUE Spacing Statistics of Spectral Surrogates Match Zeta Zeros Better Than Non-Hermitian Models

**Conjecture:** The nearest-neighbor spacing distribution of roots of the spectral zeta polynomial (constructed from a GUE random matrix of size n) matches the spacing distribution of the first n zeta zeros (on the critical line) with KS-statistic < 0.05 for n ≥ 50, and significantly outperforms the spacing distribution from roots of a random (non-Hermitian) polynomial of the same degree.

**Test:** (a) Compute the first 200 nontrivial zeta zeros from published tables. (b) For each n ∈ {20, 50, 100, 200}, generate 1000 GUE matrices, compute spectral zeta polynomial roots, and measure KS distance from zeta zero spacings. (c) Repeat with random complex polynomials of the same degree. Compare mean KS statistics. Report the p-value for the null hypothesis that GUE and non-Hermitian models are equally good fits.

**Impact:** Quantitative confirmation would provide the strongest existing numerical evidence that the Hilbert–Pólya mechanism is the correct framework for zeta zero statistics at the individual-zero level (beyond Montgomery's pair correlation). This bridges our formal spectral infrastructure to empirical number theory and would justify significant further investment in formalizing random matrix theory in Lean.

---

## Hypothesis 5: Abstract Explicit-Formula Schema Unifies Multiple Counting Function Error Bounds

**Conjecture:** The abstract conditional implication architecture defined in our Lean framework (RHFor ζ → PrimeCountSqrtLogBound) can be instantiated on at least three independent counting functions — (1) the prime counting function π(x), (2) the Chebyshev function ψ(x), and (3) the squarefree counting function Q(x) — using a single shared "explicit formula control" hypothesis, without additional analytic assumptions beyond those already formalized.

**Test:** (a) Define ψ(x) = Σ_{p^k ≤ x} log p and Q(x) = Σ_{n ≤ x} |μ(n)| in Lean using Mathlib's arithmetic functions. (b) State the three error bound theorems as conditional implications from a common abstract hypothesis `ExplicitFormulaControl`. (c) Attempt to prove all three using the subagent, sharing the abstract bridge. Success means all three compile without sorry from the single shared hypothesis.

**Impact:** This would demonstrate that the formal architecture is genuinely reusable and compositional — not just a one-off formalization exercise. It validates the "abstract implication scaffolding" strategy and creates immediate infrastructure for formalizing any future result in analytic number theory that depends on zero-location control. The shared hypothesis isolates the exact analytic bottleneck across all three applications.
