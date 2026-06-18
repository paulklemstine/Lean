
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Grokking: Phase Transitions in Learning
**Domain**: Tropical
**Mathematical framing**: Formalize grokking: prove a delayed generalization theorem for two-layer networks and characterize the phase transition as a saddle-node bifurcation.
Research domain: Tropical
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/CausalCertification.lean
/-
  # Causal Prime Decomposition and Ring-Theoretic Factorization Certification

  This file establishes the causal decomposition of prime spectra and the
  complexity-theoretic foundations of factorization certification.

  ## Main Results

  1. **multiplicative_prime_partition**: Coprime factors have disjoint prime support
  2. **valuation_determines_divisibility**: p^k | n ⟺ v_p(n) ≥ k
  3. **factorization_entropy_additive**: Ω(mn) = Ω(m) + Ω(n) for coprime m, n
  4. **gcd_factorization_min**: v_p(gcd(a,b)) = min(v_p(a), v_p(b))
  5. **composite_has_prime_factor**: Every composite has a small prime factor
  6. **three_prime_three_factorizations**: Three distinct primes → three coprime splits

  Bridge: connects Zariski topology (algebraic geometry) to post-quantum
  certification (cryptography) via causal structure (relativistic physics).
-/

import Mathlib
import Algebra.GravitationalFactoring.IdempotentLensing

open Finset Nat

namespace GravitationalFactoring

/-! ## Section I: Multiplicative Prime Partition -/

/-- **Multiplicative prime partition**: For coprime a, b, every prime
    dividing a·b belongs to exactly one factor.
    Bridge: multiplicative number theory → causal disconnection (physics). -/
theorem multiplicative_prime_partition (a b : ℕ) (ha : 0 < a) (hb : 0 < b)
    (hcop : Nat.Coprime a b) (p : ℕ) (hp : Nat.Prime p) (hd : p ∣ a * b) :
    (p ∣ a ∧ ¬(p ∣ b)) ∨ (¬(p ∣ a) ∧ p ∣ b) :=
  coprime_prime_unique_component a b p hcop hp hd

/-! ## Section II: Valuation and Divisibility -/

/-
**Valuation determines divisibility**: p^k | n ⟺ k ≤ v_p(n).
    Bridge: causal depth ≥ k ↔ chain of length k exists.
-/
theorem valuation_determines_divisibility (n p k : ℕ) (hp : Nat.Prime p) (hn : n ≠ 0) :
    p ^ k ∣ n ↔ k ≤ n.factorization p := by
  exact?

/-
**Valuation zero for non-divisors**: If p ∤ n then v_p(n) = 0.
    Bridge: absent causal chains have zero depth.
-/
theorem valuation_zero_of_not_dvd (n p : ℕ) (hp : Nat.Prime p) (hn : n ≠ 0) (h : ¬(p ∣ n)) :
    n.factorization p = 0 := by
  exact?

/-- **Valuation of prime**: v_p(p) = 1.
    Bridge: prime = single causal link. -/
theorem valuation_of_prime (p : ℕ) (hp : Nat.Prime p) :
    p.factorization p = 1 := by
  have := hp.factorization
  simp [this, Finsupp.single_apply]

/-- **Valuation of coprime product splits**: For coprime m, n,
    v_p(m·n) = v_p(m) + v_p(n).
    Bridge: entropy additivity (thermodynamics). -/
theorem valuation_coprime_additive (m n p : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    (m * n).factorization p = m.factorization p + n.factorization p :=
  valuation_additive m n p (by omega) (by omega)

/-! ## Section III: GCD and Factorization -/

/-
**GCD factorization formula**: v_p(gcd(a,b)) = min(v_p(a), v_p(b)).
    Bridge: gcd extraction = spectral lens focusing.
-/
theorem gcd_factorization_min (a b p : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (Nat.gcd a b).factorization p = min (a.factorization p) (b.factorization p) := by
  rw [ Nat.factorization_gcd ] <;> aesop

/-
**LCM factorization formula**: v_p(lcm(a,b)) = max(v_p(a), v_p(b)).
    Bridge: spectral union via lcm.
-/
theorem lcm_factorization_max (a b p : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    (Nat.lcm a b).factorization p = max (a.factorization p) (b.factorization p) := by
  rw [ Nat.factorization_lcm ] <;> aesop

/-
**GCD-LCM product identity**: gcd(a,b) · lcm(a,b) = a · b.
    Bridge: spectral intersection-union duality.
-/
theorem gcd_lcm_product (a b : ℕ) :
    Nat.gcd a b * Nat.lcm a b = a * b := by
  exact Nat.gcd_mul_lcm a b

/-! ## Section IV: Composite Structure -/

/-
**Composite detection**: Every composite number has a prime factor < n.
    Bridge: compositeness → non-empty certificate.
-/
theorem composite_has_prime_factor (n : ℕ) (hn : 1 < n) (hnp : ¬Nat.Prime n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ n ∧ p < n := by
  exact ⟨ Nat.minFac n, Nat.minFac_prime hn.ne', Nat.minFac_dvd n, Nat.lt_of_le_of_ne ( Nat.le_of_dvd hn.le ( Nat.minFac_dvd n ) ) fun con => hnp <| con ▸ Nat.minFac_prime hn.ne' ⟩

/-
**Semiprime structure**: For n = p·q with p ≠ q, the only nontrivial
    divisors are p and q.
    Bridge: RSA moduli structure → spectral simplicity.
-/
theorem semiprime_divisors (p q d : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) (hd : d ∣ p * q) (hd1 : 1 < d) (hdn : d < p * q) :
    d = p ∨ d = q := by
  rw [ Nat.dvd_mul ] at hd;
  rcases hd with ⟨ k₁, k₂, hk₁, hk₂, rfl ⟩ ; rw [ Nat.dvd_prime hp, Nat.dvd_prime hq ] at *; aesop;

/-! ## Section V: Factorization Entropy -/

/-
**Entropy additivity for coprime factors**: Ω(m·n) = Ω(m) + Ω(n).
    Bridge: Shannon entropy additivity → thermodynamic extensivity.
-/
theorem entropy_coprime_additive (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    factorizationEntropy (m * n) = factorizationEntropy m + factorizationEntropy n := by
  unfold factorizationEntropy;
  rw [ ← Multiset.coe_card, ← Multiset.coe_card, ← Multiset.coe_card ];
  rw [ ← Multiset.card_add ];
  congr 1;
  ext p;
  by_cases hp : Nat.Prime p <;> simp_all +decide [ Nat.primeFactorsList ];
  exact?

/-- **Entropy of 1 is zero**: Ω(1) = 0.
    Bridge: unit has no factorization information. -/
theorem entropy_one : factorizationEntropy 1 = 0 := by
  unfold factorizationEntropy; simp [Nat.primeFactorsList]

/-- **Entropy lower bound**: Ω(n) ≥ 1 for n > 1.
    Bridge: all non-units carry information. -/
theorem entropy_ge_one (n : ℕ) (hn : 1 < n) :
    1 ≤ factorizationEntropy n :=
  entropy_pos_of_gt_one n hn

/-
**Entropy upper bound**: Ω(n) ≤ log₂(n).
    Bridge: entropy bounded by information capacity (Shannon).
-/
theorem entropy_le_log (n : ℕ) (hn : 0 < n) :
    factorizationEntropy n ≤ Nat.log 2 n := by
  rw [ Nat.le_log_iff_pow_le ];
  · conv_rhs => rw [ ← Nat.prod_primeFactorsList hn.ne' ];
    simpa using List.prod_le_prod' fun p hp => Nat.Prime.two_le <| Nat.prime_of_mem_primeFactorsList hp;
  · norm_num;
  · positivity

/-! ## Section VI: Three-Prime Spectral Richness -/

/-
**Three distinct primes give three coprime factorizations**.
    For n = p·q·r, we get splits (p, q·r), (q, p·r), (r, p·q).
    Bridge: spectral richness → factoring search space.
-/
theorem three_prime_three_factorizations (p q r : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
    (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    p ∣ (p * q * r) ∧ q ∣ (p * q * r) ∧ r ∣ (p * q * r) ∧
    1 < p ∧ 1 < q ∧ 1 < r ∧
    Nat.Coprime p (q * r) ∧ Nat.Coprime q (p * r) ∧ Nat.Coprime r (p * q) := by
  simp_all +decide [ Nat.coprime_mul_iff_right, Nat.coprime_mul_iff_left, Nat.coprime_primes, mul_assoc ];
  exact ⟨ dvd_mul_of_dvd_right ( dvd_mul_right _ _ ) _, dvd_mul_of_dvd_right ( dvd_mul_left _ _ ) _, hp.one_lt, hq.one_lt, hr.one_lt, Ne.symm hpq, Ne.symm hpr, Ne.symm hqr ⟩

/-! ## Section VII: Idempotent Counting -/

/-
**Idempotent count for semiprimes**: For n = p·q with p ≠ q,
    there are exactly 2 nontrivial idempotents (from CRT producing
    2^2 - 2 = 2 nontrivial ones).
    Bridge: spectral lens count → factoring search space size.
-/
theorem semiprime_two_nontrivial_idempotents (p q : ℕ)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    ∃ e₁ e₂ : ZMod (p * q),
      e₁ * e₁ = e₁ ∧ e₂ * e₂ = e₂ ∧
      e₁ + e₂ = 1 ∧ e₁ * e₂ = 0 ∧
      e₁ ≠ 0 ∧ e₁ ≠ 1 ∧ e₂ ≠ 0 ∧ e₂ ≠ 1 := by
  convert coprime_orthogonal_idempotent_pair p q hp.one_lt hq.one_lt ( by simpa [ hpq ] using Nat.coprime_primes hp hq ) using 1

/-! ## Section VIII: Factoring via Square Roots of Unity -/

/-
**Nontrivial square root of 1 → factoring**: If x² ≡ 1 (mod n)
    and x ≠ ±1, then gcd(n, x-1) or gcd(n, x+1) gives a factor.
    This is the algebraic basis of Shor's algorithm.
    Bridge: quantum computing → algebraic factoring (physics/crypto).
-/
theorem sqrt_one_factoring (n x : ℕ) (hn : 1 < n) (hx : x < n)
    (hsq : (x * x) % n = 1 % n)
    (hne1 : x ≠ 1) (hnen1 : x ≠ n - 1) :
    1 < Nat.gcd n (x - 1) ∨ 1 < 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Tropical Phase Transitions in Learning

## 1. Multi-dimensional tropical bifurcation and ReLU network expressivity

The current work formalizes phase transitions for one-dimensional tropical polynomials (max of affine functions in one variable). The natural extension is to ℝⁿ: a tropical polynomial in n variables is `max_i(⟨aᵢ, x⟩ + bᵢ)` where `aᵢ ∈ ℝⁿ`. The tropical hypersurface (set where the max is achieved by ≥2 monomials) is a polyhedral complex whose combinatorial structure determines the decision boundaries of a ReLU network layer.

**Conjecture**: For a tropical polynomial with m monomials in ℝⁿ, the tropical hypersurface has at most `m choose 2` facets of codimension 1, and this bound is tight. The key insight is that each facet corresponds to a pair of monomials achieving co-dominance, and the arrangement of these hyperplanes `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ` is governed by the same linear algebra that controls ReLU network decision boundaries.

**Why now?** The one-dimensional crossover theory is fully formalized. Extending to ℝⁿ requires formalizing tropical hypersurfaces as polyhedral complexes, which is tractable given Mathlib's growing polyhedral geometry infrastructure.

## 2. Tropical gradient flow and delayed generalization dynamics

The bifurcation theorem shows that parameter changes cause monomial dominance switches. A deeper question: what is the dynamics of these switches under gradient descent? In the tropical limit, gradient descent on a loss landscape `L(θ) = max_i fᵢ(θ)` becomes a piecewise-linear dynamical system whose trajectories follow the 1-skeleton of a polyhedral complex.

**Conjecture**: For a tropical loss landscape with k monomials, the gradient flow trajectory crosses at most `k - 1` phase boundaries before converging, and the time spent in each region is bounded below by `Ω(1/gap)` where gap is the minimum spectral gap between co-dominant monomials at a boundary. The key insight is that the "delayed generalization" phenomenon (grokking) corresponds to the trajectory spending exponential time near a phase boundary where the gap is exponentially small — a tropical analogue of the classical saddle-point slowdown.

**Why now?** The crossover monotonicity theorem (`crossover_monotone_in_gap`) provides the foundation: it shows that the phase boundary position depends continuously and monotonically on parameters, which is the first step toward analyzing gradient flow near boundaries.

## 3. Tropical Legendre duality and implicit regularization

The Legendre-Fenchel transform has a natural tropical analogue: for `f(x) = max_i(aᵢx + bᵢ)`, the tropical Legendre dual is `f*(y) = -min_i(bᵢ : aᵢ = y)` (the negative of the intercept of the monomial with slope y). This duality exchanges the "weight space" and "feature space" views of a ReLU network.

**Conjecture**: Implicit regularization in neural network training (the tendency of gradient descent to find minimum-norm solutions) corresponds to selecting the t
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
