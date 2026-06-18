## Assignment: tropical_cryptography_breakthrough_bridge

**Mode:** `prove`

Prove a genuinely new bridge theorem that turns the slogan “tropical algebra supports post-quantum cryptographic primitives” into a precise formal statement. Do **not** settle for a vague hardness narrative. The target is a mathematically certified *structural cryptography theorem* showing that tropical linear maps give rise to collision-resistant behavior under a verifiable separation hypothesis, and that this behavior composes with existing entropy-security infrastructure.

This should be a cold-start flagship result: a theorem that is formal, nontrivial, and opens a new program in **tropical cryptography**.

---

## Core Breakthrough Objective

The right first theorem is not “matrix inversion is hard” — that is complexity-theoretic and difficult to formalize at once. The right first theorem is a **mathematical rigidity theorem** for tropical linear maps: under a row-separation condition, the min-plus action of a tropical matrix on a vector is injective on a structured domain. This gives a rigorous foundation for one-wayness heuristics: if the forward map is certifiably information-preserving on the intended message class but inversion requires solving a combinatorial argmin reconstruction problem, then we have a clean algebraic primitive on which later hardness assumptions can sit.

This is a breakthrough because it reframes tropical cryptography from speculative analogy into a theorem-driven discipline:
- **tropical linear algebra** provides the primitive,
- **entropy extraction** upgrades algebraic unpredictability into cryptographic security,
- **post-quantum lower bounds** motivate the relevance of the primitive under quantum attack models.

The theorem below is the right bridge: precise enough for Lean, strong enough to matter, and flexible enough to seed an entire formal theory of min-plus cryptographic constructions.

---

## Precise Theorem Target

### Mathematical statement

Let `A : Fin n → Fin m → ℝ` be a tropical matrix, and define its tropical action on a vector `x : Fin m → ℝ` by
\[
(T_A x)(i) := \min_j (A_{ij} + x_j).
\]
Assume each row `i` has a **unique designated minimizing column** `σ(i)` and that this designated choice is uniformly separated from all competitors:
\[
\forall i,\ \forall j \neq \sigma(i),\quad A_{ij} \ge A_{i,\sigma(i)} + \delta
\]
for some `δ > 0`.

Then for all vectors `x` with coordinate oscillation bounded by `δ`,
\[
\forall j,k,\ |x_j - x_k| \le \delta,
\]
the tropical action collapses to a classical affine readout:
\[
(T_A x)(i) = A_{i,\sigma(i)} + x_{\sigma(i)}.
\]

If moreover `σ : Fin n → Fin m` is bijective (so in particular `n = m` at the level of indexing data, or at least equivalently finite-cardinality matched), then the map `x ↦ T_A x` is injective on the bounded-oscillation domain. Hence tropical matrix action is an **exact encoding map** on that domain.

This is the theorem that turns tropical matrices into cryptographic encoders: the forward map is min-plus, but on a carefully separated regime it is structurally rigid enough to analyze and compose.

---

## Lean 4 formalization target

You should define the tropical action explicitly if not already present.

```lean
def tropicalMatVec {m n : ℕ} (A : Fin n → Fin m → ℝ) (x : Fin m → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.inf' (Finset.univ_nonempty) (fun j => A i j + x j)
```

Then target a theorem of the following shape. You may adjust hypotheses to fit available lemmas about `Finset.inf'`, bounded oscillation, or to use `ℚ` instead of `ℝ` if order lemmas are cleaner.

```lean
theorem tropicalMatVec_eq_of_row_separation
    {m n : ℕ}
    (A : Fin n → Fin m → ℝ)
    (σ : Fin n → Fin m)
    (δ : ℝ)
    (hδ : 0 ≤ δ)
    (hsep : ∀ i j, j ≠ σ i → A i (σ i) + δ ≤ A i j)
    (x : Fin m → ℝ)
    (hosc : ∀ j k, |x j - x k| ≤ δ) :
    tropicalMatVec A x = fun i => A i (σ i) + x (σ i) := by
  sorry
```

Then the cryptographic rigidity corollary:

```lean
theorem tropicalMatVec_injective_on_boundedOscillation
    {n : ℕ}
    (A : Fin n → Fin n → ℝ)
    (σ : Equiv (Fin n) (Fin n))
    (δ : ℝ)
    (hδ : 0 ≤ δ)
    (hsep : ∀ i j, j ≠ σ i → A i (σ i) + δ ≤ A i j) :
    Set.InjOn (tropicalMatVec A)
      {x : Fin n → ℝ | ∀ j k, |x j - x k| ≤ δ} := by
  sorry
```

A stronger version, if convenient, is to prove the explicit coordinate recovery formula
```lean
(tropicalMatVec A x) i = A i (σ i) + x (σ i)
```
first, then derive injectivity by evaluating at `σ.symm j`.

If `Set.InjOn` is awkward, an equivalent theorem with explicit quantifiers is acceptable:

```lean
theorem tropicalMatVec_injective_on_boundedOscillation'
    {n : ℕ}
    (A : Fin n → Fin n → ℝ)
    (σ : Equiv (Fin n) (Fin n))
    (δ : ℝ)
    (hδ : 0 ≤ δ)
    (hsep : ∀ i j, j ≠ σ i → A i (σ i) + δ ≤ A i j)
    {x y : Fin n → ℝ}
    (hx : ∀ j k, |x j - x k| ≤ δ)
    (hy : ∀ j k, |y j - y k| ≤ δ)
    (hEq : tropicalMatVec A x = tropicalMatVec A y) :
    x = y := by
  sorry
```

---

## Why this is a breakthrough

This theorem would create the first formally verified **structural foundation** for tropical one-way functions:
1. It identifies a concrete algebraic regime where tropical maps behave predictably.
2. It isolates the combinatorial source of inversion difficulty: outside the separated regime, recovering the active argmin pattern becomes the essential problem.
3. It provides a rigorous bridge from tropical algebra to cryptographic design, rather than an analogy.

This opens an entire field:
- **min-plus public-key design**
- **tropical trapdoor constructions**
- **post-quantum cryptographic assumptions based on argmin decoding**
- **entropy extraction from tropical encodings**
- **formal reductions between algebraic separation and cryptographic security notions**

In short: this is how tropical geometry stops being decorative and becomes cryptographic infrastructure.

---

## How to build on existing verified theorems

Use the catalog theorems as conceptual anchors, not decoration:

1. `tropical_plus_distributes_over_min`
   - File: `Cryptography/TropicalPostQuantumPrimitives.lean`
   - Use this to normalize tropical expressions and simplify rowwise min-plus manipulations.
   - The point is not merely distributivity: it certifies the algebraic coherence of the semiring-like behavior needed for the matrix action.

2. `post_quantum_grover_lower_bound`
   - File: `Cryptography/TropicalMinPlusOWF.lean`
   - Once the structural theorem is proved, cite this as motivation that brute-force inversion of tropical encodings retains post-quantum relevance.
   - You are not proving hardness from Grover; you are proving the algebraic substrate on which such hardness assumptions become meaningful.

3. `post_quantum_key_security_from_minEntropy`
   - File: `Cryptography/EntropyExtraction/LeftoverHash.lean`
   - This is the natural next bridge: if tropical encodings preserve or expose sufficient min-entropy on structured domains, then existing extractor theorems can convert that entropy into cryptographic key material.
   - Even if the full extraction theorem is deferred, state clearly how your injectivity theorem supplies the “no-collapse on message class” hypothesis needed for entropy preservation arguments.

4. `universal_bridge_density_one`
   - File: `Cryptography/RosettaStone/MasterFormula.lean`
   - Use this philosophically and, if applicable, technically: the theorem signals that bridge principles are already a live part of the codebase.
   - Your result should become a flagship instance of a Rosetta-stone style bridge between algebraic and cryptographic semantics.

5. `real_associator_zero` and `tropical_associator_zero`
   - File: `Algebra/Other/OctonionicTropicalApplications.lean`
   - These certify associative stability in the background algebra. This matters because cryptographic composition of round functions requires algebraic compositionality. Even if not directly invoked in the proof, mention the conceptual role: tropical composition is stable enough to support iterated constructions.

---

## Proof strategy architecture

### Strategy A: direct rowwise minimizer certification
**Most promising.**

1. For fixed `i`, prove that `j = σ i` is a minimizer of the set `{A i j + x j}`.
   - From bounded oscillation,
     \[
     x_j \ge x_{\sigma(i)} - \delta.
     \]
   - From row separation,
     \[
     A_{ij} \ge A_{i,\sigma(i)} + \delta.
     \]
   - Therefore
     \[
     A_{ij} + x_j \ge A_{i,\sigma(i)} + x_{\sigma(i)}.
     \]
2. Conclude that the `inf'` over `j` equals the designated value.
3. Extensionality in `i` gives the formula for `tropicalMatVec A x`.
4. For injectivity, if `σ` is a bijection, then from equality of outputs:
   \[
   A_{i,\sigma(i)} + x_{\sigma(i)} = A_{i,\sigma(i)} + y_{\sigma(i)},
   \]
   so `x (σ i) = y (σ i)` for all `i`. Surjectivity of `σ` yields `x = y`.

Why this is best:
- It is elementary order-theoretic reasoning over finite sets.
- It avoids any deep tropical geometry machinery.
- It is exactly the kind of theorem Lean handles well with careful inequalities and `Finset.inf'`.

---

### Strategy B: argmin uniqueness and selector extraction
1. Define a predicate saying `σ i` is the unique argmin of the `i`-th row functional on the oscillation-bounded domain.
2. Prove uniqueness of argmin using strict separation if you strengthen `hsep` to `A i (σ i) + δ < A i j`.
3. Package the tropical map as a selector-based affine map on that domain.
4. Derive injectivity as injectivity of a coordinate-permutation-plus-translation map.

Why this is attractive:
- It yields stronger theorems later, especially for **piecewise-linear cryptographic analysis**.
- It gives a reusable “active-minimizer extraction” API for future tropical circuit proofs.

Potential downside:
- Formalizing `argmin` cleanly in Lean may cost more setup than Strategy A.

---

### Strategy C: semiring/categorical factorization viewpoint
1. View each row functional as a tropical linear form.
2. Under separation, prove that on the bounded-oscillation polytope, each tropical linear form restricts to a single affine chart.
3. Show the whole matrix action factors through a permutation of coordinates plus diagonal translation.
4. Deduce injectivity and compositional properties.

Why this matters:
- This is the conceptual route toward **tropical block ciphers** and **piecewise-linear round functions**.
- It connects naturally to tropical geometry and polyhedral decompositions.

Why it is less immediate:
- The formal overhead is higher.
- Better as a secondary theorem after Strategy A succeeds.

---

## Recommended theorem sequence

Do not try to jump directly to hardness. Build a clean staircase:

1. **Definition layer**
   - `tropicalMatVec`
   - bounded oscillation predicate
   - row separation predicate

2. **Row rigidity theorem**
   - pointwise equality of tropical action with designated affine readout

3. **Global injectivity theorem**
   - `Set.InjOn` on the bounded-oscillation domain

4. **Entropy-preservation corollary** (if feasible)
   - finite-domain version: injective encoding preserves cardinality, hence preserves min-entropy lower bounds
   - then cite `post_quantum_key_security_from_minEntropy` as the cryptographic upgrade path

A possible finite-type theorem, if you want a more overt crypto statement, is:

```lean
theorem minEntropy_nondecreasing_under_injective_tropical_encoding
    {α : Type*} [Fintype α]
    {n : ℕ}
    (enc : α → Fin n → ℝ)
    (h_inj : Function.Injective enc) :
    Fintype.card (Set.range enc) = Fintype.card α := by
  sorry
```

Then instantiate `enc` using `tropicalMatVec A` restricted to a finite message family.

---

## Cross-domain connections you should explicitly surface

### 1. Tropical geometry × post-quantum cryptography
The active-minimizer pattern of a tropical map is a polyhedral-combinatorial object. Inversion means recovering which cell of a tropical hyperplane arrangement produced the ciphertext. This is geometrically natural and cryptographically rich.

### 2. Min-plus algebra × entropy extraction
Injective tropical encodings on structured domains preserve distinguishability and support min-entropy transport. This links tropical algebra directly to `LeftoverHash`-style key derivation.

### 3. Piecewise-linear analysis × quantum query lower bounds
Your theorem isolates where the map is affine and where combinatorial branching occurs. That is exactly the structure relevant for future formal lower bounds against quantum inversion algorithms: affine charts are easy; chart identification is the bottleneck.

### 4. Tropical algebra × coding theory
The row-separation condition is analogous to a distance/separation margin. This suggests tropical error-correcting codes, syndrome decoding in min-plus algebra, and robust decryption regions.

### 5. Tropical linearity × neural verification
There is a hidden connection to certified robustness: the same “margin implies chart stability” principle used in tropicalized neural networks appears here as “separation implies cryptographic determinacy.” This could unify verification and cryptography under tropical polyhedral methods.

---

## Concrete technical suggestions for Lean execution

- If `Finset.inf'` over `ℝ` is awkward, consider proving an auxiliary lemma:
  ```lean
  theorem Finset.inf'_eq_of_mem_and_le_all ...
  ```
  specialized to the current use case.
- You may find it easier to work with `sInf` on finite ranges if order lemmas are cleaner.
- Introduce:
  ```lean
  def BoundedOscillation (δ : ℝ) (x : Fin m → ℝ) : Prop :=
    ∀ j k, |x j - x k| ≤ δ
  ```
- Derive the useful inequality:
  ```lean
  have hxjk : x (σ i) - δ ≤ x j := ...
  ```
  from `|x j - x (σ i)| ≤ δ`.
- Then combine with `hsep` by `linarith`.
- For extensional equality of functions:
  ```lean
  funext i
  ```
- For injectivity with `σ : Equiv (Fin n) (Fin n)`, recover any coordinate `j` by taking `i := σ.symm j`.

If strict inequalities make the proof cleaner, strengthen to:
```lean
A i (σ i) + δ < A i j
```
with `0 < δ`.
That may also give uniqueness of the minimizing coordinate for free.

---

## Ambitious extension theorem if time permits

After the injectivity theorem, aim for a finite-message cryptographic corollary:

```lean
theorem tropical_encoding_preserves_minEntropy_on_finite_message_space
    {α : Type*} [Fintype α] [DecidableEq α]
    {n : ℕ}
    (encode : α → Fin n → ℝ)
    (h_inj : Function.Injective encode) :
    Fintype.card (Set.range encode) = Fintype.card α := by
  sorry
```

Then explain how, combined with
`post_quantum_key_security_from_minEntropy`,
this yields a blueprint for deriving keys from tropical ciphertext ensembles without entropy collapse.

This would be a major bridge result: **tropical encoding → entropy preservation → extractor security**.

---

## What would make this field-opening

A theorem of this form would establish:
- tropical matrix maps admit rigorously analyzable secure regimes,
- cryptographic one-wayness in tropical settings can be grounded in exact algebraic structure,
- future reductions can target the combinatorics of argmin-pattern inversion rather than hand-wavy “tropical hardness.”

This is the first stone in a possible new subject:
**formal tropical cryptography**.

If successful, this line could lead to:
- tropical trapdoor permutations,
- min-plus hash functions,
- tropical key encapsulation mechanisms,
- certified post-quantum primitives with polyhedral security semantics.

That is not an incremental extension. That is a new language for cryptography.

---

## Application keywords

`tropical cryptography`, `post-quantum cryptography`, `min-plus algebra`, `tropical matrix action`, `injective encoding`, `argmin decoding`, `polyhedral security`, `entropy preservation`, `leftover hash lemma`, `quantum query complexity`, `tropical one-way functions`, `formal verification`, `Lean 4`, `Mathlib`, `coding theory`, `piecewise-linear cryptanalysis`

---

## Deliverables

1. Formalize `tropicalMatVec` and any needed support predicates.
2. Prove `tropicalMatVec_eq_of_row_separation`.
3. Prove `tropicalMatVec_injective_on_boundedOscillation`.
4. If feasible, add a finite entropy/cardinality preservation corollary connecting to `post_quantum_key_security_from_minEntropy`.
5. Minimize `sorry` aggressively.

---

## Mandatory follow-up

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**, for example:
1. formalize tropical trapdoor functions via hidden active-minimizer patterns;
2. prove entropy lower bounds for random separated tropical matrices;
3. define and analyze tropical hash families with collision bounds;
4. formalize a quantum query model for tropical inversion;
5. build tropical error-correcting / key encapsulation primitives from row-separated matrices.

Make these specific, theorem-driven, and bold.

### Catalog Reference Files
@Algebra/Other/OctonionicTropicalApplications.lean
```lean
import Mathlib

/-! # CatalogBuild.Speculative.Other.OctonionicTropicalApplications

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Declarations: 15] -/
def associator {α : Type*} [AddGroup α] (mul : α → α → α) (a b c : α) : α :=
  mul (mul a b) c - mul a (mul b c)

-- For real numbers (associative), the associator is zero

/-- [Section: # CatalogBuild.Speculative.Other.OctonionicTropicalApplications
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 15] -/
theorem real_associator_zero (a b c : ℝ) :
    associator (· * ·) a b c = 0 := by
  simp [associator, mul_assoc]

-- Tropical max-plus is associative

theorem tropical_associator_zero (a b c : ℝ) :
    max (max a b) c = max a (max b c) :=
  max_assoc a b c

-- Error detection: nonzero associator means non-associative path

theorem error_detection_principle {α : Type*} [AddGroup α]
    (mul : α → α → α) (a b c : α)
    (h : associator mul a b c ≠ 0) :
    mul (mul a b) c ≠ mul a (mul b c) := by
  intro heq
  apply h
  simp [associator, heq]

def unitSphere (n : ℕ) : Set (Fin n → ℝ) :=
  {v | ∑ i, (v i) ^ 2 = 1}

-- The real Hopf map: (x, y) on S¹ ↦ x² - y²

def realHopfMap (v : Fin 2 → ℝ) : ℝ := (v 0) ^ 2 - (v 1) ^ 2

-- The Hopf map sends S¹ to [-1, 1]

theorem hopf_bounded (v : Fin 2 → ℝ) (hv : v ∈ unitSphere 2) :
    |realHopfMap v| ≤ 1 := by
  have h1 : (v 0) ^ 2 + (v 1) ^ 2 = 1 := by
    have := hv; simp [unitSphere, Fin.sum_univ_two] at this; exact this
  rw [realHopfMap, abs_le]
  constructor <;> nlinarith [sq_nonneg (v 0), sq_nonneg (v 1)]

-- The Hopf map is not constant on S¹

theorem hopf_nonconstant :
    ∃ v w : Fin 2 → ℝ, v ∈ unitSphere 2 ∧ w ∈ unitSphere 2 ∧
    realHopfMap v ≠ realHopfMap w := by
  refine ⟨![1, 0], ![0, 1], ?_, ?_, ?_⟩
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [unitSphere, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
  · simp [realHopfMap, Matrix.cons_val_zero, Matrix.cons_val_one]
    norm_num

theorem fano_line_count : fanoLines.length = 7 := by native_decide

-- Each point appears in exactly 3 lines

theorem fano_regularity_0 :
    (fanoLines.filter (fun t => t.1 = 0 ∨ t.2.1 = 0 ∨ t.2.2 = 0)).length = 3 := by
  native_decide

-- Fano plane diameter is at most 2

theorem fano_diameter_le_2 :
    ∀ (p q : Fin 7), p ≠ q →
    ∃ r : Fin 7, ∃ L₁ ∈ fanoLines, ∃ L₂ ∈ fanoLines,
      (L₁.1 = p ∨ L₁.2.1 = p ∨ L₁.2.2 = p) ∧
      (L₁.1 = r ∨ L₁.2.1 = r ∨ L₁.2.2 = r) ∧
      (L₂.1 = q ∨ L₂.2.1 = q ∨ L₂.2.2 = q) ∧
      (L₂.1 = r ∨ L₂.2.1 = r ∨ L₂.2.2 = r) := by
  native_decide

theorem triality_triple_gap (g₁ g₂ g₃ : ℝ) (h₁ : g₁ = 1) (h₂ : g₂ = 1) (h₃ : g₃ = 1) :
    g₁ + g₂ + g₃ = 3 := by linarith

theorem tropical_moufang (a b c : ℝ) :
    max (max a b) (max c a) = max a (max (max b c) a) := by
  simp [max_comm, max_left_comm]

-- One-way function: max preimage is not unique

theorem max_preimage_nonunique (c : ℝ) :
    ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b') := by
  refine ⟨c, c - 1, c - 1, c, ?_, ?_, ?_⟩
  · exact max_eq_left (by linarith)
  · exact max_eq_right (by linarith)
  · left; linarith

-- Catalan number C₃ = 5 (number of bracketings of 4 elements)

theorem five_applications_summary :
    -- 1. Error correction: associator detects errors in non-associative algebras
    (∀ a b c : ℝ, max (max a b) c = max a (max b c)) ∧
    -- 2. Hopf fibration: dimension reduction preserves structure
    (∀ v : Fin 2 → ℝ, v ∈ OctonionicHopf.unitSphere 2 →
      |OctonionicHopf.realHopfMap v| ≤ 1) ∧
    -- 3. Fano routing: 7 lines
    (TropicalFanoRouting.fanoLines.length = 7) ∧
    -- 4. Spectral gap: projection eigenvalues are 0 or 1
    ((1 : ℝ) - 0 = 1) ∧
    -- 5. Moufang crypto: max preimage is non-unique
    (∀ c : ℝ, ∃ a b a' b' : ℝ, max a b = c ∧ max a' b' = c ∧ (a ≠ a' ∨ b ≠ b')) :=
  ⟨fun a b c => max_assoc a b c,
   fun v hv => OctonionicHopf.hopf_bounded v hv,
   TropicalFanoRouting.fano_line_count,
   by norm_num,
   TropicalMoufangCrypto.max_preimage_nonunique⟩

end
```

@Algebra/Tropical_p_adic_Valuation_Bounds_and_Lifting_the_Exponent_for_Fibonacci_Primitive_Divisors.lean
```lean
/-
# Fibonacci Primitive Divisors and Lifting-the-Exponent

This file formalizes key results about primitive prime divisors of Fibonacci numbers,
including:
- The Fibonacci entry point (rank of apparition) z(p)
- The characterization: p | F_n ↔ z(p) | n
- Growth bounds for Fibonacci numbers
- The Lifting-the-Exponent (LTE) framework for Fibonacci sequences
- Carmichael's theorem: F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}

## References
- Carmichael, R.D. "On the numerical factors of the arithmetic forms αⁿ ± βⁿ" (1913)
- Yabuta, M. "A simple proof of Carmichael's theorem on primitive divisors" (2001)
-/

import Mathlib

open scoped BigOperators Nat
open Nat

set_option maxHeartbeats 8000000
set_option maxRecDepth 4000

/-! ## Section 1: Basic Fibonacci Properties -/

/-
Fibonacci numbers are strictly monotone for indices ≥ 2.
-/
theorem fib_strict_mono_of_ge_two {m n : ℕ} (hm : 2 ≤ m) (hmn : m < n) :
    Nat.fib m < Nat.fib n := by
  exact?

/-
F_n ≥ n for n ≥ 5.
-/
theorem fib_ge_index (n : ℕ) (hn : 5 ≤ n) : n ≤ Nat.fib n := by
  -- We can prove this by induction on $n$.
  induction' n using Nat.strong_induction_on with n ih;
  rcases hn with ( _ | _ | _ | _ | _ | n ) <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  grind

/-- F_n > 0 for n > 0. -/
theorem fib_pos_of_pos {n : ℕ} (hn : 0 < n) : 0 < Nat.fib n :=
  Nat.fib_pos.mpr hn

/-! ## Section 2: The Fibonacci Entry Point (Rank of Apparition)

For a prime p, the entry point z(p) is the smallest positive integer k
such that p | F_k. This exists because p | F_{p - (p/5)} by quadratic
reciprocity properties of Fibonacci numbers.
-/

open Classical in
/-- The Fibonacci entry point: the smallest positive k such that p | F_k.
    Returns 0 if no such k exists (which doesn't happen for primes ≥ 2). -/
noncomputable def fibEntryPoint (p : ℕ) : ℕ :=
  if h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else
    0

/-
If the entry point is positive, then p divides F_{z(p)}.
-/
theorem fib_entry_point_dvd (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib (fibEntryPoint p) := by
  unfold fibEntryPoint;
  split_ifs ; exact Nat.find_spec h |>.2

/-
The entry point is positive when a divisibility witness exists.
-/
theorem fib_entry_point_pos (p : ℕ) (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPoint p := by
  unfold fibEntryPoint; aesop;

/-
The entry point is minimal: if p | F_k and k > 0, then z(p) ≤ k.
-/
theorem fib_entry_point_le (p k : ℕ) (hk : 0 < k) (hpk : p ∣ Nat.fib k)
    (h : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    fibEntryPoint p ≤ k := by
  unfold fibEntryPoint;
  split_ifs ; aesop

/-! ## Section 3: Entry Point Divides Index

The key characterization: p | F_n if and only if z(p) | n.
This follows from the strong divisibility property gcd(F_m, F_n) = F_{gcd(m,n)}.
-/

/-
**Entry point divisibility**: For a prime p with p | F_m for some m > 0,
    we have p | F_n ↔ z(p) | n (assuming n > 0).
-/
theorem fib_dvd_iff_entry_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    p ∣ Nat.fib n ↔ fibEntryPoint p ∣ n := by
  -- By definition of z(p), we know that p | F_{z(p)} and z(p) is the smallest such positive integer.
  have hz : p ∣ Nat.fib (fibEntryPoint p) ∧ ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ≤ k := by
    exact ⟨ fib_entry_point_dvd p hex, fun k hk hk' => fib_entry_point_le p k hk hk' hex ⟩;
  have h_div : ∀ k : ℕ, 0 < k → p ∣ Nat.fib k → fibEntryPoint p ∣ k := by
    intros k hk_pos hk_div
    have h_gcd : Nat.gcd (fibEntryPoint p) k = fibEntryPoint p := by
      refine' Nat.le_antisymm _ _;
      · exact Nat.le_of_dvd ( fib_entry_point_pos p hex ) ( Nat.gcd_dvd_left _ _ );
      · refine' hz.2 _ ( Nat.gcd_pos_of_pos_right _ hk_pos ) _;
        have h_gcd : Nat.gcd (Nat.fib (fibEntryPoint p)) (Nat.fib k) = Nat.fib (Nat.gcd (fibEntryPoint p) k) := by
          exact?;
        exact h_gcd ▸ Nat.dvd_gcd hz.1 hk_div;
    exact h_gcd ▸ Nat.gcd_dvd_right _ _;
  exact ⟨ h_div n hn, fun h => dvd_trans hz.1 ( Nat.fib_dvd _ _ h ) ⟩

/-! ## Section 4: Primitive Prime Divisors -/

/-- A prime p is a **primitive prime divisor** of F_n if p | F_n and
    p does not divide F_k for any 0 < k < n. Equivalently, z(p) = n. -/
def IsPrimitivePrimeDivisor (p n : ℕ) : Prop :=
  Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k : ℕ, 0 < k → k < n → ¬(p ∣ Nat.fib k)

/-- F_n **has a primitive prime divisor** if there exists a prime p with z(p) = n. -/
def HasPrimitivePrimeDivisor (n : ℕ) : Prop :=
  ∃ p : ℕ, IsPrimitivePrimeDivisor p n

/-
A prime is a primitive divisor of F_n iff its entry point equals n.
-/
theorem isPrimitivePrimeDivisor_iff_entry_eq (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hex : ∃ k : ℕ, 0 < k ∧ p ∣ Nat.fib k) :
    IsPrimitivePrimeDivisor p n ↔ (p ∣ Nat.fib n ∧ fibEntryPoint p = n) := by
  constructor <;> intro h;
  · exact ⟨ h.2.1, le_antisymm ( fib_entry_point_le p n hn h.2.1 hex ) ( Nat.le_of_not_gt fun hlt => h.2.2 _ ( fib_entry_point_pos p hex ) hlt ( fib_entry_point_dvd p hex ) ) ⟩;
  · exact ⟨ hp, h.1, fun k hk₁ hk₂ hk₃ => by have := fib_entry_point_le p k hk₁ hk₃ hex; linarith ⟩

/-! ## Section 5: Growth Bounds for Fibonacci Numbers

These bounds are essential for proving that F_n has prime factors beyond
those of F_d for proper divisors d of n.
-/

/-
Exponential lower bound: F_n ≥ 2^((n-2)/2) for n ≥ 2.
-/
theorem fib_exponential_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    2 ^ ((n - 2) / 2) ≤ Nat.fib n := by
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩;
  · induction' k with k ih <;> norm_num [ Nat.fib_add_two, Nat.mul_succ ] at *;
    rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.mul_succ ];
    grind;
-- ... (truncated, full file has 493 lines)
```

@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Cryptography
Research mode: prove
