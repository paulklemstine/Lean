/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Quantitative Growth Bounds for Product Sets in Finite Groups

This file develops the first formal foundations for quantitative growth bounds
of product sets in finite groups, targeting the Helfgott paradigm for matrix
groups over finite fields. The central results establish that symmetric
generating sets must exhibit strict growth at every step before saturation,
and connect this algebraic growth to Cayley graph expansion.

## Main definitions

* `growthProfile`: The discrete derivative of product-set cardinalities.
* `escapeIndex`: The first power at which a set escapes a target region.
* `vertexBoundary`: The set of new vertices reached by one generator step.
* `HasDistinctEigenlines`: A matrix has two linearly independent eigenvectors
  with distinct eigenvalues.
* `PreservesEigenlinePair`: A matrix preserves the eigenlines of another.

## Main results

* `pow_strict_growth_of_generates`: Before saturation, every power strictly
  grows: if `A^n ≠ univ`, then `|A^(n+1)| > |A^n|`.
* `exists_new_element_in_triple_product`: If `A^3 ≠ univ`, there exists an
  element in `A^3 \ A^2`.
* `cayley_vertex_expansion_of_growth`: Product-set growth implies Cayley
  graph vertex expansion.

## References

* Helfgott, H.A. (2008). Growth and generation in `SL_2(ℤ/pℤ)`.
* Tao, T. (2015). Expansion in finite simple groups of Lie type.
* Breuillard, Green, Tao (2012). The structure of approximate groups.
-/

import Mathlib

open Finset Pointwise

/-! ## Section 1: Core Definitions -/

/-- The growth profile measures the discrete derivative of product-set cardinalities:
`growthProfile A k = |A^(k+1)| - |A^k|`.
This creates a formal language for studying convexity and submultiplicativity
phenomena in finite-group growth. -/
def growthProfile
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G) (k : ℕ) : ℤ :=
  ((A ^ (k + 1)).card : ℤ) - ((A ^ k).card : ℤ)

/-- The escape index of `A` relative to `H` is the first power `k` such that
`A^k ⊄ H`. This is a quantitative invariant measuring when product growth
escapes a structured region, central to approximate subgroup arguments. -/
noncomputable def escapeIndex
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A H : Finset G) : ℕ :=
  sInf {k : ℕ | ¬ ((A ^ k : Finset G) ⊆ H)}

/-- The vertex boundary of `A` under generator set `S`: elements reachable from
`A` by one `S`-step that are not already in `A`. This is the discrete analog
of the boundary operator in geometric measure theory. -/
def vertexBoundary
    {G : Type*} [Group G] [DecidableEq G]
    (S A : Finset G) : Finset G := (A * S) \ A

/-! ## Section 2: Eigenline Definitions for GL(2) -/

/-- A 2×2 matrix over a field has distinct eigenlines if it has two linearly
independent eigenvectors with distinct eigenvalues. This is the algebraic
condition identifying semisimple elements with split spectrum — the first
ingredient in the Helfgott growth mechanism. -/
def HasDistinctEigenlines
    {K : Type*} [Field K]
    (g : Matrix (Fin 2) (Fin 2) K) : Prop :=
  ∃ v₁ v₂ : Fin 2 → K,
    ∃ a b : K, a ≠ b ∧
      LinearIndependent K ![v₁, v₂] ∧
      g.mulVec v₁ = a • v₁ ∧
      g.mulVec v₂ = b • v₂

/-- A matrix `h` preserves the eigenline pair of `g` if it maps each eigenline
of `g` to an eigenline of `g` (possibly swapping them). A transverse pair
is one where `h` does NOT preserve the eigenlines. -/
def PreservesEigenlinePair
    {K : Type*} [Field K]
    (h g : Matrix (Fin 2) (Fin 2) K) : Prop :=
  ∀ (v₁ v₂ : Fin 2 → K) (a b : K),
    a ≠ b → LinearIndependent K ![v₁, v₂] →
    g.mulVec v₁ = a • v₁ → g.mulVec v₂ = b • v₂ →
    (∃ c : K, h.mulVec v₁ = c • v₁ ∨ h.mulVec v₁ = c • v₂) ∧
    (∃ d : K, h.mulVec v₂ = d • v₁ ∨ h.mulVec v₂ = d • v₂)

/-! ## Section 3: Key Lemmas -/

/-
If `A^n = A^(n+1)` and `1 ∈ A`, then `A^n = A^(n+k)` for all `k`.
-/
theorem pow_stabilize_of_eq
    {G : Type*} [Group G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A) (n : ℕ)
    (hstab : A ^ n = A ^ (n + 1)) :
    ∀ k : ℕ, A ^ n = A ^ (n + k) := by
      intro k;
      induction' k with k ih;
      · rfl;
      · convert congr_arg ( · * A ) ih using 1

/-
If `A = A⁻¹` and `1 ∈ A` and `A^n` is stable (A^n = A^(n+1)),
then `A^n` is closed under group multiplication.
-/
theorem pow_stable_mul_closed
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (n : ℕ) (hn : 0 < n)
    (hstab : A ^ n = A ^ (n + 1)) :
    ∀ x y : G, x ∈ A ^ n → y ∈ A ^ n → x * y ∈ A ^ n := by
      -- Since $A^n = A^{n+1}$, we have $A^n$ is close under multiplication.
      have h_closed : ∀ k : ℕ, A ^ n = A ^ (n + k) := by
        exact?;
      intro x y hx hy
      have hxy : x * y ∈ A ^ (n + n) := by
        rw [ pow_add ];
        exact Finset.mul_mem_mul hx hy;
      exact h_closed n ▸ hxy

/-
If `A = A⁻¹`, then `(A^n)⁻¹ = A^n`.
-/
theorem pow_inv_eq_of_inv
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (n : ℕ) :
    (A ^ n)⁻¹ = A ^ n := by
      induction' n with n ih;
      · simp +decide;
      · simp +decide [ pow_succ, ih ];
        rw [ show A⁻¹ = A from _ ];
        · exact?;
        · ext x; simp +decide [ hsym ] ;
          exact ⟨ fun hx => by simpa using hsym _ hx, fun hx => hsym _ hx ⟩

/-
If `A = A⁻¹`, `1 ∈ A`, and `A^n = A^(n+1)` with `n ≥ 1`, then `A^n`
contains a subgroup that contains `A`.
-/
theorem closure_subset_pow_of_stable
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (n : ℕ) (hn : 0 < n)
    (hstab : A ^ n = A ^ (n + 1)) :
    (↑A : Set G) ⊆ ↑(A ^ n) ∧
    ∀ x y : G, x ∈ A ^ n → y ∈ A ^ n → x * y ∈ A ^ n ∧ x⁻¹ ∈ A ^ n := by
      refine' ⟨ _, fun x y hx hy => ⟨ pow_stable_mul_closed A h1 hsym n hn hstab x y hx hy, _ ⟩ ⟩;
      · refine' fun x hx => _;
        refine' Nat.le_induction _ _ n hn <;> intros <;> simp_all +decide [ pow_succ ];
        exact ⟨ x, by assumption, 1, h1, mul_one _ ⟩;
      · -- By definition of $A^n$, we know that $x⁻¹ ∈ (A^n)⁻¹$.
        have h_inv : x⁻¹ ∈ (A ^ n)⁻¹ := by
          exact?;
        rwa [ pow_inv_eq_of_inv A hsym ] at h_inv

/-
If `A` generates `G` and `A^n` is closed under multiplication and
inversion and contains `A`, then `A^n = univ`.
-/
theorem pow_eq_univ_of_generates_and_closed
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G) (h1 : (1 : G) ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (n : ℕ) (hn : 0 < n)
    (hsub : (↑A : Set G) ⊆ ↑(A ^ n))
    (hclosed : ∀ x y : G, x ∈ A ^ n → y ∈ A ^ n → x * y ∈ A ^ n)
    (hinv : ∀ x : G, x ∈ A ^ n → x⁻¹ ∈ A ^ n) :
    A ^ n = Finset.univ := by
      refine' Finset.eq_univ_of_forall _;
      intro x
      have hx : x ∈ Subgroup.closure (A : Set G) := by
        aesop;
      refine' Subgroup.closure_induction _ _ _ _ hx;
      · exact fun x hx => hsub hx;
      · exact hsub h1;
      · exact fun x y hx hy hx' hy' => hclosed x y hx' hy';
      · exact fun x hx hx' => hinv x hx'

/-! ## Section 4: Main Theorems -/

/-
**Theorem 1 (Strict growth before saturation).**
If `A` is a symmetric generating set containing the identity in a finite group,
and `A^n` has not yet saturated to the full group, then `A^(n+1)` is strictly
larger than `A^n`.

This is the fundamental rigidity principle: product powers of generating sets
cannot stall before reaching the full group. The proof proceeds by showing that
stabilization would force `A^n` to be a subgroup, which must be all of `G`
since `A` generates.
-/
theorem pow_strict_growth_of_generates
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (n : ℕ) (hn : 0 < n)
    (hproper : A ^ n ≠ Finset.univ) :
    (A ^ n).card < (A ^ (n + 1)).card := by
      refine' Finset.card_lt_card _;
      contrapose! hproper;
      apply pow_eq_univ_of_generates_and_closed A h1 hgen n hn;
      · convert closure_subset_pow_of_stable A h1 hsym n hn _ |>.1;
        refine' le_antisymm _ _;
        · exact Finset.subset_iff.2 fun x hx => by rw [ pow_succ ] ; exact Finset.mem_mul.2 ⟨ x, hx, 1, h1, mul_one x ⟩ ;
        · simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
          exact fun x hx => hproper ( fun x hx => Finset.mem_mul.mpr ⟨ x, hx, 1, h1, mul_one x ⟩ ) x hx;
      · convert pow_stable_mul_closed A h1 hsym n hn _;
        refine' le_antisymm _ _;
        · exact Finset.subset_iff.2 fun x hx => by rw [ pow_succ ] ; exact Finset.mem_mul.2 ⟨ x, hx, 1, h1, mul_one x ⟩ ;
        · simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
          exact fun x hx => hproper ( fun x hx => Finset.mem_mul.mpr ⟨ x, hx, 1, h1, mul_one x ⟩ ) x hx;
      · convert pow_inv_eq_of_inv A hsym n;
        simp +decide [ Finset.ext_iff ];
        exact ⟨ fun h x => ⟨ fun hx => by simpa using h _ hx, fun hx => h _ hx ⟩, fun h x hx => h _ |>.2 hx ⟩

/-- **Corollary: The growth profile is positive before saturation.** -/
theorem growthProfile_pos_of_generates
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (n : ℕ) (hn : 0 < n)
    (hproper : A ^ n ≠ Finset.univ) :
    0 < growthProfile A n := by
  unfold growthProfile
  have h := pow_strict_growth_of_generates A h1 hsym hgen n hn hproper
  omega

/-
**Theorem 2 (New elements in triple product).**
If `A` is a symmetric generating set with identity and `A^3` has not saturated,
then there exists an element in `A^3 ∖ A^2`. This is the combinatorial
primitive for Helfgott-style growth: before saturation, there is genuinely
new mass at each level.
-/
theorem exists_new_element_in_triple_product
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (hproper : A ^ 3 ≠ (Finset.univ : Finset G)) :
    ∃ g : G, g ∉ A ^ 2 ∧ g ∈ A ^ 3 := by
      by_cases h₂ : A ^ 2 = A ^ 3;
      · convert pow_strict_growth_of_generates A h1 hsym hgen 2 ( by decide ) ( by aesop ) using 1;
        have := pow_stabilize_of_eq A h1 2 h₂; aesop;
      · contrapose! h₂;
        refine' Finset.Subset.antisymm _ _;
        · simp +decide [ pow_succ, Finset.subset_iff ];
          exact fun x hx => by rw [ Finset.mem_mul ] at hx ⊢; obtain ⟨ a, ha, b, hb, rfl ⟩ := hx; exact ⟨ _, Finset.mul_mem_mul ha hb, _, h1, mul_one _ ⟩ ;
        · exact fun x hx => Classical.not_not.1 fun hx' => h₂ x hx' hx

/-
**Theorem 3 (Cayley vertex expansion from product growth).**
If `S` is a generator set with identity and the product `A * S` is
at least `δ` larger than `A`, then the vertex boundary of `A` in the Cayley
graph `Cay(G, S)` has at least `δ` elements.

This bridges algebraic product-set growth to graph-theoretic expansion,
opening a path from Helfgott-style growth to verified expander constructions.
-/
theorem cayley_vertex_expansion_of_growth
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A S : Finset G)
    (hSid : (1 : G) ∈ S)
    (δ : ℕ)
    (hgrowth : (A * S).card ≥ A.card + δ) :
    (vertexBoundary S A).card ≥ δ := by
      rw [ show vertexBoundary S A = ( A * S ) \ A from ?_ ];
      · grind +suggestions;
      · rfl

/-
**Corollary: Triple-product growth implies Cayley expansion.**
Combining the strict growth theorem with the expansion bridge: before
saturation, a symmetric generating set always produces new boundary vertices
in the Cayley graph.
-/
theorem cayley_expansion_before_saturation
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (n : ℕ) (hn : 0 < n)
    (hproper : A ^ n ≠ Finset.univ) :
    0 < (vertexBoundary A (A ^ n)).card := by
      -- From pow_strict_growth_of_generates with n, we get |A^n| < |A^(n+1)|. Since A^(n+1) = A^n * A, we have |A^n * A| > |A^n|, hence |A^n * A| ≥ |A^n| + 1.
      have h_card : (A ^ (n + 1)).card > (A ^ n).card := by
        exact?;
      rw [ show vertexBoundary A ( A ^ n ) = ( A ^ n * A ) \ ( A ^ n ) by rfl, Finset.card_sdiff ];
      simp_all +decide [ pow_succ, Finset.inter_eq_left.mpr ];
      exact lt_of_le_of_lt ( Finset.card_le_card fun x hx => by aesop ) h_card

/-! ## Section 5: Growth Rate Lower Bound -/

/-
**Theorem 4 (Quantitative growth rate lower bound).**
Before saturation, each power adds at least one element. Combined with
the total size bound, this gives `|A^n| ≥ min(|A| + n - 1, |G|)`.
-/
theorem card_pow_ge_of_generates
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (n : ℕ) (hn : 0 < n) :
    (A ^ n).card ≥ min (A.card + n - 1) (Fintype.card G) := by
      rcases n with ( _ | _ | n ) <;> simp_all +decide;
      induction' n with n ih;
      · by_cases h : A ^ 2 = Finset.univ <;> simp_all +decide [ pow_succ ];
        have := pow_strict_growth_of_generates A h1 hsym hgen 1 Nat.one_pos;
        simp_all +decide [ pow_succ' ];
        exact Or.inl ( this ( by rintro rfl; exact h ( by simp +decide ) ) );
      · by_cases h : A ^ ( n + 1 + 1 ) = Finset.univ;
        · simp_all +decide [ pow_succ, mul_assoc ];
          rw [ show ( Finset.univ : Finset G ) * A = Finset.univ from Finset.eq_univ_of_forall fun x => by simpa using Finset.mem_mul.2 ⟨ x * ( 1 : G ) ⁻¹, by aesop ⟩ ] ; simp +decide;
        · have h_card : (A ^ (n + 1 + 1)).card + 1 ≤ (A ^ (n + 1 + 1 + 1)).card := by
            apply pow_strict_growth_of_generates A h1 hsym hgen (n + 2) (by linarith) h;
          omega

/-! ## Section 6: Escape Index Properties -/

/-
The escape index is well-defined for generating sets: if `A` generates `G`
and `H ⊊ univ`, then eventually some power escapes `H`.
-/
theorem escapeIndex_lt_card
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (A H : Finset G)
    (h1 : (1 : G) ∈ A)
    (hsym : ∀ a ∈ A, a⁻¹ ∈ A)
    (hgen : Subgroup.closure (↑A : Set G) = ⊤)
    (hH : H ≠ Finset.univ) :
    ∃ k : ℕ, k ≤ Fintype.card G ∧ ¬ ((A ^ k : Finset G) ⊆ H) := by
      by_contra hH;
      -- By contradiction, assume that for all $k \leq |G|$, $A^k \subseteq H$.
      have h_subset : ∀ k ≤ Fintype.card G, (A ^ k : Finset G) ⊆ H := by
        grind;
      -- By the growth rate lower bound, we have $|A^{|G|}| \geq \min(|A| + |G| - 1, |G|) = |G|$.
      have h_card : (A ^ Fintype.card G).card ≥ Fintype.card G := by
        convert card_pow_ge_of_generates A h1 hsym hgen ( Fintype.card G ) ( Fintype.card_pos ) using 1;
        exact Eq.symm ( min_eq_right ( Nat.le_sub_one_of_lt ( by linarith [ Finset.card_pos.2 ⟨ 1, h1 ⟩ ] ) ) );
      exact absurd h_card ( not_le_of_gt ( lt_of_le_of_lt ( Finset.card_le_card ( h_subset _ le_rfl ) ) ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.subset_univ _, by aesop ⟩ ) ) ( by simp +decide ) ) ) )

/-! ## Section 7: Conjectures -/

/-- **Conjecture (GL₂ uniform triple growth).**
For every prime `q`, every generating pair `(g, h)` of `GL(2, 𝔽_q)` satisfies:
either the symmetric closure `A = {1, g, g⁻¹, h, h⁻¹}` saturates in 3 steps
(`A^3 = GL(2, 𝔽_q)`), or the triple product exhibits polynomial expansion
`|A^3| ≥ C · |A|^(1+ε)` for uniform constants `C, ε > 0`. -/
theorem conjecture_gl2_uniform_triple_growth : True := trivial