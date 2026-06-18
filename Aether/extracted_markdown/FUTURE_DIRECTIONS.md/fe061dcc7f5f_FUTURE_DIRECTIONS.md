# Future Directions: Local Euler Data and Symmetric Power Transfer

## Synthesis

The formalization of local Euler data and symmetric power transfer creates a **verified algebraic substrate** for Langlands functoriality that is simultaneously extensible (toward Rankin–Selberg, plethysm, and ramification), connectable (to complexity theory, spectral dynamics, and mathematical physics), and computationally generative (producing certified algorithms and testable conjectures). The five directions below form a coherent program: Directions 1–2 extend the algebraic core, Direction 3 connects to complexity theory, Direction 4 bridges to spectral/physical theory, and Direction 5 proposes a grand challenge that would unite them all. Each direction builds on the verified foundations established in this work — particularly the symmetric power transfer formula, the determinant compatibility law, and the self-duality theorem — ensuring that future results inherit the certainty of the current formalization.

---

## Direction 1: Rankin–Selberg Local Convolution

**Conjecture:** Given two local Euler data D₁ = (d₁, r₁) and D₂ = (d₂, r₂), define their *Rankin–Selberg convolution* as the Euler datum with roots {r₁(i) · r₂(j)}_{i,j}. Then the Euler polynomial of the convolution factors as a product of d₁ · d₂ linear factors, and the determinant of the convolution satisfies det(D₁ ⊗ D₂) = det(D₁)^{d₂} · det(D₂)^{d₁}.

**The key insight is** that Rankin–Selberg convolution at the unramified level is entirely determined by the multiplicative structure of Satake parameters, making it amenable to the same algebraic formalization that succeeded for symmetric powers.

**Why now?** The `LocalEulerDatum` structure already supports arbitrary degree and root functions. Defining tensor products requires only a new constructor and a theorem about products over product index sets (Fin d₁ × Fin d₂), which Mathlib's `Finset.prod` API handles well.

**Test:** Verify that for GL₂ × GL₂ data with known Satake parameters, the convolution Euler polynomial matches the classical Rankin–Selberg factor. Computationally verify the determinant formula for all pairs (d₁, d₂) ≤ (10, 10).

**Impact:** This would give a verified model of the most important analytic construction in automorphic forms — the Rankin–Selberg method accounts for a large fraction of known cases of functoriality.

**Catalog References:**
- `Algebra/LanglandsFunctoriality.lean` — `LocalEulerDatum`, `symmPow_root_product`
- `Algebra/AlgebraicCircuitComplexity.lean` — degree bounds for product polynomials

**Proof Strategy:** Define the convolution, prove the root count by `Fintype.card_prod`, and prove the determinant formula by splitting the double product and applying `symmPow_root_product`-style exponent arithmetic.

**Domain Bridges:** Number theory → Representation theory (tensor products of representations)

**Lineage:** Direct extension of the symmetric power transfer framework.

**Ambition:** Solid extension — well-understood mathematics, new formalization.

---

## Direction 2: Plethysm and Iterated Symmetric Powers

**Conjecture:** For all m, n ≥ 1 and α, β in a commutative ring, every root of Sym^m(Sym^n(α, β)) is a monomial α^a β^b with a + b = mn, and the number of roots is (m+1)(n+1). Furthermore, the roots of Sym^m(Sym^n(α, β)) coincide with the set {∏_{k=1}^{m} α^{n-j_k} β^{j_k} : 0 ≤ j₁ ≤ j₂ ≤ ... ≤ j_m ≤ n}.

**The key insight is** that iterated symmetric power transfer corresponds to *plethysm* of symmetric functions, one of the deepest and most computationally challenging operations in algebraic combinatorics.

**Why now?** The `symmPowDatum` function can be applied iteratively by extracting Satake parameters from the roots of the first transfer. The weight homogeneity theorem (`symmPow_roots_homogeneous`) provides the inductive foundation.

**Test:** Compute the root sets of Sym^2(Sym^3(α,β)) and Sym^3(Sym^2(α,β)) for specific α, β values and verify they have the correct cardinalities (12 and 12 respectively) and total weights (6 and 6).

**Impact:** A verified plethysm computation would be the first formal foothold in one of representation theory's hardest combinatorial problems — plethysm coefficients are not known to be computable in polynomial time.

**Catalog References:**
- `Algebra/LanglandsFunctoriality.lean` — `symmPowDatum`, `symmPow_roots_homogeneous`

**Proof Strategy:** Induction on the iterated transfer, using `symmPow_roots_homogeneous` at each level. The monomial weight constraint propagates multiplicatively through the iteration.

**Domain Bridges:** Number theory → Algebraic combinatorics → Computational complexity (plethysm complexity)

**Lineage:** Builds directly on `symmPowDatum` and weight homogeneity.

**Ambition:** Grand challenge — connects to open problems in algebraic combinatorics.

---

## Direction 3: Functoriality as Certified Complexity Amplification

**Conjecture:** For the family of polynomials P_n = P_{Sym^n(α,β)} over any infinite field, the multiplicative complexity μ(P_n) satisfies μ(P_n) = Θ(n). More precisely, n ≤ μ(P_n) ≤ O(n log n), and the lower bound is tight because P_n has n+1 distinct roots requiring n multiplications to form.

**The key insight is** that functorial transfer produces structured polynomial families whose complexity can be analyzed using the catalog's algebraic circuit framework, creating a verified bridge between the Langlands program and computational complexity.

**Why now?** The degree bound `symmPow_euler_natDegree_le` is already proved. The catalog's `AlgebraicCircuitComplexity.lean` provides the circuit model and degree-depth tradeoff. Connecting them requires only a verified reduction from the Euler polynomial to the circuit evaluation semantics.

**Test:** For specific small n (2, 3, 4, 5), construct explicit circuits computing P_n and verify that their sizes match the predicted bounds. Verify the depth lower bound ⌈log₂(n+1)⌉ computationally for n ≤ 50.

**Impact:** This would create a formal instance of the "GCT" (Geometric Complexity Theory) philosophy: representation-theoretic structure implies computational lower bounds. It is a stepping stone toward using Langlands-type symmetry to prove computational hardness results.

**Catalog References:**
- `Algebra/LanglandsFunctoriality.lean` — `symmPow_euler_natDegree_le`
- `Algebra/AlgebraicCircuitComplexity.lean` — `AlgCircuit.degreeBound`, depth-degree tradeoff

**Proof Strategy:** Construct the reduction as a function from Euler polynomial degree to circuit depth lower bound, composing `symmPow_euler_natDegree_le` with the degree-depth theorem from the catalog.

**Domain Bridges:** Number theory → Algebraic complexity → Computational complexity (P vs NP program)

**Lineage:** Extends the degree bound theorem; connects to catalog circuit complexity.

**Ambition:** Solid extension with grand-challenge connections.

---

## Direction 4: Self-Dual Transfer, Spectral Symmetry, and Random Matrix Statistics

**Conjecture:** For α > 1 real, the eigenvalue angle distribution of the companion matrix of P_{Sym^n(α, α⁻¹)} converges (as n → ∞) to a specific deterministic measure on the unit circle related to the arcsine distribution. Furthermore, the spacing statistics of these eigenvalue angles exhibit intermediate statistics between Poisson and GUE, with the crossover controlled by ln(α).

**The key insight is** that the self-duality theorem (`symmPow_roots_inv_closed`) produces reciprocal polynomials whose root geometry is precisely the type studied in random matrix theory — the roots of characteristic polynomials of random unitary matrices are reciprocal polynomial roots on the unit circle.

**Why now?** The self-duality theorem is proved. The palindromic coefficient structure is verified numerically. What remains is to formalize the spectral theory of companion matrices of reciprocal polynomials and connect to the existing catalog results on spectral transfer.

**Test:** For α ∈ {1.01, 1.1, 2, 10} and n ∈ {10, 50, 100, 500}, compute the eigenvalue angles of the companion matrix of P_{Sym^n(α, α⁻¹)}, compute nearest-neighbor spacing statistics, and compare against Poisson, GOE, GUE, and intermediate distributions.

**Impact:** This would create a formal bridge between Langlands functoriality and random matrix theory — the connection that underlies the Katz–Sarnak philosophy governing zeros of L-functions. A verified spectral analysis of local Euler factors would be unprecedented.

**Catalog References:**
- `Algebra/LanglandsFunctoriality.lean` — `symmPow_roots_inv_closed`
- `Algebra/Apollonian/SpectralTransfer.lean` — spectral transfer bounds

**Proof Strategy:** Define the companion matrix of a reciprocal polynomial, prove its eigenvalues are the polynomial roots, and use the known root structure α^{n-2i} to compute eigenvalue angles explicitly.

**Domain Bridges:** Number theory → Random matrix theory → Mathematical physics → Spectral theory

**Lineage:** Extends the self-duality theorem toward analytic consequences.

**Ambition:** Grand challenge — would connect three major mathematical programs.

---

## Direction 5: Toward Formal Unramified Local Langlands for GL_n

**Conjecture:** There exists a formally verified bijection between semisimple conjugacy classes in GL_n(ℂ) and isomorphism classes of unramified smooth representations of GL_n(ℚ_p), compatible with symmetric power transfer in the sense that the diagram

```
GL₂-reps  ──Sym^n──▶  GL_{n+1}-reps
   |                        |
   ▼                        ▼
 Satake    ──Sym^n──▶     Satake
  params                   params
```

commutes, where the bottom map is exactly `symmPowDatum`.

**The key insight is** that our `LocalEulerDatum` is already the combinatorial shadow of a semisimple conjugacy class, and the symmetric power transfer is already the bottom row of this diagram. What remains is to formalize the representation-theoretic content of the top row and the vertical maps.

**Why now?** The algebraic infrastructure is in place. Mathlib has growing support for p-adic fields, smooth representations, and algebraic groups. The Satake isomorphism for GL_n is well-understood mathematically and involves only Hecke algebras, which are algebraic objects amenable to formalization.

**Test:** For GL₂ and GL₃ over ℚ_p (p = 2, 3, 5), construct explicit unramified representations, compute their Satake parameters, verify the correspondence, and check that Sym^2 transfer commutes with the correspondence.

**Impact:** This would be the first formal verification of any case of the local Langlands correspondence — a result that earned Michael Harris and Richard Taylor (among others) major recognition.

**Catalog References:**
- `Algebra/LanglandsFunctoriality.lean` — all definitions and theorems
- `Algebra/LanglandsGL1/` — existing GL₁ formalization

**Proof Strategy:** Build the Satake isomorphism for GL_n as an algebra isomorphism between the unramified Hecke algebra and the representation ring of GL_n(ℂ). Use Mathlib's Hecke algebra infrastructure and representation theory.

**Domain Bridges:** Number theory → Representation theory → Algebraic geometry

**Lineage:** The culmination of the entire local Euler data program.

**Ambition:** Grand challenge — multi-year project that would be a landmark in formal mathematics.
