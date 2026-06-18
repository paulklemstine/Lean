# Future Directions: Tropical Additive Combinatorics

## 1. Tropical Ternary Goldbach Formalization

**Goal:** Formalize a support-level tropical theorem for threefold min-plus convolution and connect it to Vinogradov's theorem on odd-number decomposition.

**Concrete steps:**
- Define `minplusConv3 f g h n := ⨅ (a b c : ℕ) (_ : a + b + c = n), f a + g b + h c`.
- Prove `minplusConv3_tropPredCost_eq_zero_iff`: the threefold convolution of `tropPredCost A` vanishes at n iff n lies in A + A + A.
- State Vinogradov's theorem as a hypothesis and derive its tropical reformulation: every sufficiently large odd number has zero tropical ternary prime cost.
- Implement a verified finite search certifying ternary Goldbach for small odd numbers.

**Hypothesis:** The tropical threefold convolution framework will expose compositional structure (e.g., factoring threefold convolution through twofold plus a single convolution) that yields new modular proof architectures for ternary Goldbach.

**Cross-domain connection:** Dynamic programming / shortest-path algebra — threefold convolution corresponds to three-hop shortest paths.

---

## 2. Weighted Prime Energy Inequalities

**Goal:** Define soft prime costs with meaningful weight functions and prove subadditivity, monotonicity, and comparison theorems that mirror sieve majorants.

**Concrete steps:**
- Define `logPrimeCost (n : ℕ) : WithTop ℝ := if Nat.Prime n then log n else ⊤` and prove that convolution of log-costs captures weighted additive representations.
- Define `sieveMajorant (n : ℕ) : ℝ≥0` using truncated von Mangoldt or Selberg sieve weights.
- Prove: if `s ≤ tropPredCost Nat.Prime` pointwise and `minplusConv s s n < ⊤`, then the soft convolution gives a finite upper bound on the "tropical energy" of decomposing n.
- Establish a transfer theorem: sieve upper bounds on prime-counting imply finite bounds on soft tropical convolution.

**Hypothesis:** Soft tropical energies form a graded family interpolating between exact representability (hard cost) and density estimates (sieve bounds), enabling incremental progress on Goldbach-type problems.

---

## 3. Verified Bounded Goldbach Engine in Lean

**Goal:** Implement a certified finite search showing zero tropical cost for all even numbers up to a substantial bound (e.g., 10⁶).

**Concrete steps:**
- Define a `Decidable` instance for `∃ a b, a + b = n ∧ Nat.Prime a ∧ Nat.Prime b` restricted to `a ∈ Finset.range (n+1)`.
- Prove that the finite search is equivalent to the infinite infimum: `minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) n = 0 ↔ (Finset.range (n+1)).∃ a, Nat.Prime a ∧ Nat.Prime (n - a)`.
- Use `native_decide` to verify Goldbach up to large bounds.
- Package as `goldbach_verified_to_bound : ∀ n, 4 ≤ n → n ≤ B → Even n → minplusConv (tropPredCost Nat.Prime) (tropPredCost Nat.Prime) n = 0`.
- Combine with `goldbach_from_finite_check_and_cover` to maximize the range of the hybrid theorem.

**Hypothesis:** The finite search engine can push verified bounds high enough to interface with known computational Goldbach verifications (currently up to 4 × 10¹⁸).

---

## 4. Tropical Sumset Growth Theorem (Basis Order Theory)

**Goal:** Prove that repeated tropical self-convolution of positive-density support functions eventually vanishes on all sufficiently large integers, formalizing a tropical analogue of Schnirelmann's basis theorem.

**Concrete steps:**
- Define tropical lower covering density: `σ_trop(A) := inf_{n ≥ 1} |{a ∈ A : a ≤ n}| / n`.
- Prove: if `σ_trop(A) > 0` and `1 ∈ A`, then repeated k-fold tropical convolution `tropPredCost A ⋆ₖ` eventually vanishes on all n ≥ N(k).
- Formalize the tropical analogue of Schnirelmann's theorem: if `σ_trop(A) ≥ 1/2`, then the twofold convolution already covers all sufficiently large integers.
- Prove monotonicity of tropical support under convolution: `supp(f ⋆ g) ⊇ supp(f) + supp(g)`.

**Hypothesis:** The tropical formulation of basis order theory will yield sharper effective bounds than the classical Schnirelmann approach because the min-plus structure provides a natural optimization framework.

**Cross-domain connection:** Tropical geometry — the support growth theorem is analogous to tropical Bézout's theorem for curve intersections.

---

## 5. Semiring Transfer Interface for Analytic Estimates

**Goal:** Design a formal interface allowing external analytic number theory estimates (prime number theorem, Goldbach-type density results, Chen's theorem) to be imported as hypotheses yielding tropical vanishing conclusions.

**Concrete steps:**
- Define a `TropicalAnalyticInput` structure: a bundled collection of hypotheses about prime distribution that suffice to derive tropical vanishing on specified domains.
- Prove: PNT + Bertrand's postulate → the set of primes has positive tropical covering density → (by the basis theorem) tropical self-convolution eventually vanishes.
- Prove: Chen's theorem (every sufficiently large even number is the sum of a prime and a product of at most two primes) → a relaxed tropical vanishing statement for a modified cost function.
- Create a modular architecture where new analytic inputs can be plugged in without re-deriving the tropical infrastructure.

**Hypothesis:** This interface layer will enable the formal mathematics community to incrementally strengthen tropical Goldbach results as new analytic estimates are formalized, creating a "progressive certification" pathway toward full Goldbach.

**Cross-domain connection:** Information theory / idempotent analysis — the transfer interface is analogous to a channel coding theorem, where analytic estimates provide "channel capacity" and the tropical framework provides "coding theorems" that convert capacity into reliable representation.
