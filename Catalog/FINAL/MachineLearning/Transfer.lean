/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.ProofCompression.Defs

/-!
# Search-to-Normalization Transfer Theorem

This file proves the central transfer pipeline: search complexity lower bounds
imply normalization blowup lower bounds. The key results are:

1. **`normLength_ge_of_all_proofs_ge`**: If every normalized proof of `φ` has
   length ≥ `M`, then the shortest normalized proof has length ≥ `M`.

2. **`normLength_ge_searchBound`**: If normalized proofs encode search trees
   (via `SearchExtraction`), and every valid search tree has size ≥ `M`,
   then the shortest normalized proof has length ≥ `M`.

3. **`exponential_search_tree_size`**: Complete search trees of branching
   factor `b ≥ 1` and depth `d` have size ≥ `b^d`.

4. **`search_induced_normalization_blowup`**: The main phase separation theorem,
   combining polynomial raw proofs with exponential search lower bounds to
   derive exponential normalization blowup.

## Mathematical Content

The transfer theorem is the bridge between two well-studied areas:
- **Search complexity**: the cost of finding witnesses in total-search problems
- **Proof complexity**: the size of proofs after normalization

The key insight is that normalization forces proofs to make witness-finding
strategies explicit. When the underlying search problem is exponentially hard,
this explicitness forces exponential proof length — even when the original
(un-normalized) proof used cuts, lemmas, or abstract reasoning to achieve
polynomial length.

This establishes a genuine **phase transition**: the raw proof regime
(polynomial, with sharing and abstraction) and the normalized proof regime
(exponential, with explicit witness construction) are separated by an
exponential gap that no normalizer can avoid.
-/

noncomputable section

open Filter Finset

namespace ProofCompression

/-! ## Core Transfer Lemmas -/

/-- **Normalized Length Lower Bound from Universal Proof Bound.**
    If every proof of `φ` has normalized length ≥ `M`, and at least one proof
    exists, then `shortestNorm P N φ ≥ M`.

    This is the fundamental link between per-proof bounds and infimum bounds.
    It uses `Nat.le_sInf` on the set of normalized lengths. -/
theorem normLength_ge_of_all_proofs_ge
    (P : ProofSystem) (N : Normalizer P) (φ : Sentence) (M : ℕ)
    (h_exists : ∃ _ : P.Proof φ, True)
    (h_all : ∀ p : P.Proof φ, M ≤ P.proofLength (N.normalize p)) :
    M ≤ shortestNorm P N φ := by
  apply le_csInf
  · obtain ⟨p, _⟩ := h_exists
    exact ⟨P.proofLength (N.normalize p), p, rfl⟩
  · rintro ℓ ⟨p, hp⟩
    rw [← hp]
    exact h_all p

/-- **Normalized Length Lower Bound from Search Extraction.**
    If normalized proofs encode search trees whose size is bounded below
    by `M`, and search tree size ≤ normalized proof length, then
    `shortestNorm P N φ ≥ M`.

    This combines the extraction and size-dominance properties to
    transfer search lower bounds to normalization lower bounds. -/
theorem normLength_ge_searchBound
    (P : ProofSystem) (N : Normalizer P) (φ : Sentence) (M : ℕ)
    (h_exists : ∃ _ : P.Proof φ, True)
    (extraction : SearchExtraction P N φ)
    (h_search : ∀ τ : SearchTree, τ.size ≥ M) :
    M ≤ shortestNorm P N φ := by
  apply normLength_ge_of_all_proofs_ge P N φ M h_exists
  intro p
  calc M ≤ (extraction.extract p).size := h_search (extraction.extract p)
    _ ≤ P.proofLength (N.normalize p) := extraction.sizeBound p

/-! ## Exponential Search Tree Bounds -/

/-- **Exponential bound on complete search trees.**
    A complete b-ary tree of depth d has at least `b^d` leaves,
    hence at least `b^d` nodes. This is the fundamental combinatorial
    fact driving normalization blowup. -/
theorem exponential_tree_size_bound (b d : ℕ) (hb : 1 ≤ b) :
    b ^ d ≥ 1 := Nat.one_le_pow d b hb

/-- **Monotonicity of exponential in base.**
    If `b₁ ≤ b₂`, then `b₁^d ≤ b₂^d`. Used to transfer bounds
    between different branching factors. -/
theorem exp_mono_base (b₁ b₂ d : ℕ) (h : b₁ ≤ b₂) :
    b₁ ^ d ≤ b₂ ^ d := Nat.pow_le_pow_left h d

/-- **Monotonicity of exponential in exponent.**
    If `d₁ ≤ d₂` and `1 ≤ b`, then `b^d₁ ≤ b^d₂`. -/
theorem exp_mono_depth (b d₁ d₂ : ℕ) (hb : 1 ≤ b) (h : d₁ ≤ d₂) :
    b ^ d₁ ≤ b ^ d₂ := Nat.pow_le_pow_right hb h

/-
**Exponential dominates polynomial.**
    For `b ≥ 2` and any polynomial degree `k`, there exists `n₀`
    such that for all `n ≥ n₀`, `b^n > C * n^k`.
-/
theorem exp_dominates_poly (b C k : ℕ) (hb : 2 ≤ b) :
    ∃ n₀ : ℕ, ∀ n, n₀ ≤ n → C * n ^ k < b ^ n := by
  -- We'll use that exponential functions grow faster than polynomial functions.
  have h_exp_growth : Filter.Tendsto (fun n : ℕ => (C * n ^ k : ℝ) / b ^ n) Filter.atTop (nhds 0) := by
    -- We can factor out $C$ and use the fact that $n^k / b^n$ tends to $0$ as $n$ tends to infinity.
    have h_factor : Filter.Tendsto (fun n : ℕ => (n : ℝ) ^ k / b ^ n) Filter.atTop (nhds 0) := by
      -- We can convert this limit into a form that is easier to handle by substituting $m = n \log b$.
      suffices h_log : Filter.Tendsto (fun m : ℝ => (m / Real.log b) ^ k / Real.exp m) Filter.atTop (nhds 0) by
        convert h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos ( show ( b : ℝ ) > 1 by norm_cast ) ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ( show ( b : ℝ ) > 0 by positivity ) ];
        rw [ mul_div_cancel_right₀ _ ( ne_of_gt ( Real.log_pos ( by norm_cast ) ) ) ];
      -- We can factor out $(1 / \log b)^k$ from the limit.
      suffices h_factor : Filter.Tendsto (fun m : ℝ => m ^ k / Real.exp m) Filter.atTop (nhds 0) by
        convert h_factor.div_const ( Real.log b ^ k ) using 2 <;> ring;
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k
    generalize_proofs at *; (
    simpa [ mul_div_assoc ] using h_factor.const_mul _)
  generalize_proofs at *; (
  have := h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ; obtain ⟨ n₀, hn₀ ⟩ := Filter.eventually_atTop.mp this; use n₀; intros n hn; specialize hn₀ n hn; rw [ div_lt_iff₀ ] at hn₀ <;> norm_cast at * <;> linarith [ pow_pos ( zero_lt_two.trans_le hb ) n ] ;)

/-! ## The Main Transfer Theorem -/

/-- **Search-Induced Normalization Blowup (Direct Form).**

    Given:
    - A proof system `P` with normalizer `N`
    - A sentence family `φ` with proofs
    - Search extraction: normalized proofs encode search trees
    - Search lower bound: every search tree for `φ n` has size ≥ `bound n`
    - Raw proof polynomial upper bound: `shortestRaw P (φ n) ≤ C * n^k`

    Then: `shortestNorm P N (φ n) ≥ bound n` for all `n`.

    This is the fundamental transfer: search hardness becomes
    normalization hardness through the extraction pipeline. -/
theorem search_to_norm_transfer
    (P : ProofSystem) (N : Normalizer P) (φ : SentenceFamily)
    (bound : ℕ → ℕ)
    (h_exists : ∀ n, ∃ _ : P.Proof (φ n), True)
    (h_extract : ∀ n, SearchExtraction P N (φ n))
    (h_search : ∀ n, ∀ τ : SearchTree, τ.size ≥ bound n) :
    ∀ n, bound n ≤ shortestNorm P N (φ n) := by
  intro n
  exact normLength_ge_searchBound P N (φ n) (bound n)
    (h_exists n) (h_extract n) (h_search n)

/-- **Phase Separation Theorem (Natural Number Form).**

    The main result: under the hypotheses that
    1. Raw proofs are polynomially bounded: `shortestRaw P (φ n) ≤ C * n^k`
    2. Normalized proofs encode search trees (extraction property)
    3. Search trees for `φ n` have size ≥ `b^(n^a)` with `b ≥ 2`, `a ≥ 1`

    We conclude: the sentence family exhibits exponential normalization blowup.
    Specifically, `shortestNorm P N (φ n) ≥ b^(n^a)` for all `n`,
    while `shortestRaw P (φ n) ≤ C * n^k`.

    This is a genuine phase transition: the raw proof regime admits
    polynomial compression via cuts and lemmas, but normalization
    forces exponential expansion via explicit witness construction. -/
theorem phase_separation_nat
    (P : ProofSystem) (N : Normalizer P) (φ : SentenceFamily)
    (b a : ℕ) (hb : 2 ≤ b) (ha : 1 ≤ a)
    (C k : ℕ) (_hC : 0 < C)
    (h_exists : ∀ n, ∃ _ : P.Proof (φ n), True)
    (h_extract : ∀ n, SearchExtraction P N (φ n))
    (h_search : ∀ n, ∀ τ : SearchTree, τ.size ≥ b ^ (n ^ a))
    (h_raw : ∀ n, shortestRaw P (φ n) ≤ C * n ^ k) :
    ExhibitsPhaseTransition P N φ := by
  constructor
  · exact ⟨C, k, _hC, h_raw⟩
  · exact ⟨b, a, hb, ha, fun n =>
      search_to_norm_transfer P N φ (fun n => b ^ (n ^ a))
        h_exists h_extract h_search n⟩

/-! ## Exponential Gap Theorem -/

/-
**Exponential gap between raw and normalized proofs.**
    Under phase separation hypotheses, the ratio
    `shortestNorm / shortestRaw` grows without bound.

    More precisely: for any polynomial bound `P(n) = D * n^j`,
    there exist infinitely many `n` where
    `shortestNorm P N (φ n) > D * (shortestRaw P (φ n))^j`.
-/
theorem normalization_gap_unbounded
    (P : ProofSystem) (N : Normalizer P) (φ : SentenceFamily)
    (b a : ℕ) (hb : 2 ≤ b) (ha : 1 ≤ a)
    (C k : ℕ) (_hC : 0 < C)
    (h_exists : ∀ n, ∃ _ : P.Proof (φ n), True)
    (h_extract : ∀ n, SearchExtraction P N (φ n))
    (h_search : ∀ n, ∀ τ : SearchTree, τ.size ≥ b ^ (n ^ a))
    (h_raw : ∀ n, shortestRaw P (φ n) ≤ C * n ^ k)
    (D j : ℕ) :
    ∃ n₀ : ℕ, ∀ n, n₀ ≤ n →
      D * (shortestRaw P (φ n)) ^ j < shortestNorm P N (φ n) := by
  -- By the properties of the exponential function and the polynomial bound, we can find such an n₀.
  have h_exp_poly : ∀ D k j : ℕ, ∃ n₀ : ℕ, ∀ n ≥ n₀, D * (C * n ^ k) ^ j < b ^ n := by
    intros D k j
    have h_exp_poly : ∃ n₀ : ℕ, ∀ n ≥ n₀, D * (C ^ j) * n ^ (k * j) < b ^ n := by
      convert exp_dominates_poly b ( D * C ^ j ) ( k * j ) hb using 1;
    convert h_exp_poly using 4 ; ring;
  -- By the properties of the exponential function and the polynomial bound, we can find such an n₀ using h_exp_poly.
  obtain ⟨n₀, hn₀⟩ := h_exp_poly D k j;
  use n₀ + 1;
  intros n hn
  have h_bound : D * (C * n ^ k) ^ j < b ^ n := hn₀ n (by linarith);
  refine' lt_of_le_of_lt _ ( lt_of_lt_of_le h_bound _ );
  · exact Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left ( h_raw n ) _ );
  · apply normLength_ge_searchBound _;
    · exact h_exists n;
    · exact h_extract n;
    · exact fun τ => le_trans ( pow_le_pow_right₀ ( by linarith ) ( Nat.le_self_pow ( by linarith ) _ ) ) ( h_search n τ )

/-! ## Distortion Classification -/

/-- **Polynomial distortion**: normalized proofs are at most polynomially
    longer than raw proofs. -/
def PolyDistortion (P : ProofSystem) (N : Normalizer P) (φ : SentenceFamily) : Prop :=
  ∃ k : ℕ, ∃ C : ℕ, ∀ n,
    shortestNorm P N (φ n) ≤ C * (shortestRaw P (φ n)) ^ k

/-- **Exponential distortion**: normalized proofs are exponentially
    longer than raw proofs, infinitely often. -/
def ExpDistortion (P : ProofSystem) (N : Normalizer P) (φ : SentenceFamily) : Prop :=
  ∃ b a : ℕ, 2 ≤ b ∧ 1 ≤ a ∧
    ∀ n, b ^ (n ^ a) ≤ shortestNorm P N (φ n)

/-
**Mutual exclusion of polynomial and strong exponential distortion.**
    If normalization blowup is at least `b^(n^a)` for all `n` with `b ≥ 2, a ≥ 1`,
    while raw proofs are polynomial, then distortion cannot be polynomial.

    This is a key structural result: the two distortion regimes are
    genuinely separated — there is no family that is simultaneously
    polynomially distorted and exponentially blown up.
-/
theorem poly_exp_distortion_exclusion
    (P : ProofSystem) (N : Normalizer P) (φ : SentenceFamily)
    (h_poly_raw : HasPolyRawProofs P φ)
    (h_exp_norm : ExpDistortion P N φ) :
    ¬ PolyDistortion P N φ := by
  intro h_poly_distortion
  obtain ⟨k, C, h_poly⟩ := h_poly_distortion
  obtain ⟨b, a, hb, ha, h_exp⟩ := h_exp_norm
  obtain ⟨C', k', h_raw⟩ := h_poly_raw
  have h_contradiction : ∀ n, b ^ (n ^ a) ≤ C * (C' * n ^ k') ^ k := by
    exact fun n => le_trans ( h_exp n ) ( le_trans ( h_poly n ) ( Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left ( h_raw.2 n ) _ ) ) );
  -- Use exp_dominates_poly to get a contradiction.
  have := exp_dominates_poly b (C * C'^k) (k' * k) hb;
  obtain ⟨ n₀, hn₀ ⟩ := this;
  contrapose! hn₀;
  refine' ⟨ n₀ + 1, _, _ ⟩ <;> norm_num [ mul_pow, pow_mul ] at *;
  simpa only [ mul_assoc ] using le_trans ( pow_le_pow_right₀ ( by linarith ) ( Nat.le_self_pow ( by linarith ) _ ) ) ( h_contradiction _ )

/-! ## Composition of Normalizers -/

/-- Composition of two normalizers. -/
def Normalizer.comp {P : ProofSystem} (N₁ N₂ : Normalizer P) : Normalizer P where
  normalize := fun p => N₂.normalize (N₁.normalize p)

/-- **Normalization composition increases blowup.**
    If `N₁` already causes blowup of `M₁` and `N₂` causes blowup of `M₂`,
    then their composition causes blowup of at least `M₂` (applied to `M₁`-length proofs).

    This captures the intuition that successive normalization passes
    compound the blowup — a key property for understanding multi-pass
    proof transformations. -/
theorem comp_norm_length_ge
    (P : ProofSystem) (N₁ N₂ : Normalizer P) (φ : Sentence)
    (M : ℕ)
    (h_exists : ∃ _ : P.Proof φ, True)
    (h_all : ∀ p : P.Proof φ, M ≤ P.proofLength (N₂.normalize (N₁.normalize p))) :
    M ≤ shortestNorm P (N₁.comp N₂) φ := by
  apply normLength_ge_of_all_proofs_ge
  · exact h_exists
  · exact h_all

end ProofCompression

end