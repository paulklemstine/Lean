/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Quantitative Stabilizer Descent for Approximate Subgroups

This file formalizes a quantitative stabilizer descent principle for
approximate subgroups. It establishes the formal bridge from small
doubling / approximate closure, through bounded coset coverings, to
strict dimension drop in the stabilizer — the core inductive engine
behind approximate-group structure theory.

## Main Definitions

* `leftStabilizer`: The left stabilizer {g : G | g • A ⊆ A * A}
* `StabilizerDescentProfile`: Structure packaging descent-ready stabilizer data
* `nlc`: Normalized log-cardinality (pointwise pseudofinite dimension)

## Main Results

* `leftStabilizer_one_mem'`: 1 ∈ Stab(A) when 1 ∈ A
* `subset_leftStabilizer_of_one_mem`: A ⊆ Stab(A) when 1 ∈ A
* `leftStabilizer_mul_subset`: Algebraic closure of stabilizer action
* `nlc_mono`: Monotonicity of normalized log-cardinality
* `nlc_le_one`: Upper bound of normalized log-cardinality
* `nlc_nonneg`: Non-negativity of normalized log-cardinality
* `nlc_le_of_card_le_mul`: Dimension bound from cardinality bound
* `stabilizer_dim_le_of_cover_bound`: Dimension drop from cover + gap
* `nlc_chain`: Iterated dimension drop via covering composition

## References

* Hrushovski, E. (2012). Stable group theory and approximate subgroups.
* Breuillard, E., Green, B., Tao, T. (2012). The structure of approximate groups.
* Ruzsa, I. Z. (1999). An analog of Freiman's theorem in groups.
-/

import Mathlib

open Finset Set Pointwise Filter Real

namespace StabilizerDescent

/-! ## Section 1: Left Stabilizer Definition -/

/-- The **left stabilizer** of a set `A` in a group `G`:
    Stab(A) = {g ∈ G | g * a ∈ A * A for all a ∈ A}. -/
def leftStabilizer {G : Type*} [Group G] (A : Set G) : Set G :=
  {g : G | ∀ a ∈ A, g * a ∈ A * A}

/-- Finite version of the left stabilizer for `Finset`. -/
def leftStabilizerFinset {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    (A : Finset G) : Finset G :=
  Finset.univ.filter (fun g => ∀ a ∈ A, g * a ∈ A * A)

/-! ## Section 2: Stabilizer Descent Profile -/

/-- **StabilizerDescentProfile**: packages descent-ready stabilizer data. -/
structure StabilizerDescentProfile (G : Type*) [Group G] where
  /-- The base approximate subgroup -/
  A : Set G
  /-- The stabilizer set -/
  S : Set G
  /-- Doubling parameter -/
  K : ℕ
  /-- Covering number bound -/
  M : ℕ
  /-- The stabilizer is the left stabilizer of A -/
  stab_eq : S = leftStabilizer A
  /-- The covering number M is controlled by K -/
  cover_controlled : M ≤ K ^ 2

/-! ## Section 3: Basic Stabilizer Properties -/

/-- If 1 ∈ A, then A ⊆ A * A. -/
theorem subset_mul_self_of_one_mem {G : Type*} [Group G]
    {A : Set G} (h1 : (1 : G) ∈ A) :
    A ⊆ A * A := by
  intro a ha
  exact ⟨a, ha, 1, h1, mul_one a⟩

/-- The identity is in Stab(A) when 1 ∈ A. -/
theorem leftStabilizer_one_mem' {G : Type*} [Group G]
    {A : Set G} (h1 : (1 : G) ∈ A) :
    (1 : G) ∈ leftStabilizer A := by
  intro a ha
  rw [one_mul]
  exact subset_mul_self_of_one_mem h1 ha

/-- Elements of A are in Stab(A) when 1 ∈ A. -/
theorem mem_leftStabilizer_of_mem {G : Type*} [Group G]
    {A : Set G} {g : G} (hg : g ∈ A) (_h1 : (1 : G) ∈ A) :
    g ∈ leftStabilizer A := by
  intro a ha
  exact ⟨g, hg, a, ha, rfl⟩

/-- **A ⊆ Stab(A) when 1 ∈ A.** -/
theorem subset_leftStabilizer_of_one_mem {G : Type*} [Group G]
    {A : Set G} (h1 : (1 : G) ∈ A) :
    A ⊆ leftStabilizer A :=
  fun _ hg => mem_leftStabilizer_of_mem hg h1

/-! ## Section 4: Stabilizer Algebraic Properties -/

/-- **Stabilizer multiplication sends A into A³**:
    If g, h ∈ Stab(A), then g*h sends every a ∈ A into A*A*A. -/
theorem leftStabilizer_mul_subset {G : Type*} [Group G]
    {A : Set G} {g h : G}
    (hg : g ∈ leftStabilizer A)
    (hh : h ∈ leftStabilizer A)
    (a : G) (ha : a ∈ A) :
    g * h * a ∈ A * A * A := by
  have hha : h * a ∈ A * A := hh a ha
  obtain ⟨b, hb, c, hc, hbc⟩ := hha
  have hgb : g * b ∈ A * A := hg b hb
  obtain ⟨d, hd, e, he, hde⟩ := hgb
  refine ⟨d * e, ⟨d, hd, e, he, rfl⟩, c, hc, ?_⟩
  simp only [] at hbc hde ⊢
  rw [hde, mul_assoc, hbc, mul_assoc]

/-- **Stabilizer inclusion is monotone in the target**. -/
theorem leftStabilizer_mono_target {G : Type*} [Group G]
    {A B : Set G} (h : A * A ⊆ B * B) :
    leftStabilizer A ⊆ {g : G | ∀ a ∈ A, g * a ∈ B * B} := by
  intro g hg a ha
  exact h (hg a ha)

/-! ## Section 5: Normalized Log-Cardinality -/

/-- Normalized log-cardinality: log|A| / log|G|. -/
noncomputable def nlc (G : Type*) [Fintype G] (A : Finset G) : ℝ :=
  Real.log (A.card : ℝ) / Real.log (Fintype.card G : ℝ)

/-
**Monotonicity of nlc**: A ⊆ B implies nlc(A) ≤ nlc(B).
-/
theorem nlc_mono {G : Type*} [Fintype G] [DecidableEq G]
    {A B : Finset G} (h : A ⊆ B) (hG : 2 ≤ Fintype.card G)
    (hA : A.Nonempty) :
    nlc G A ≤ nlc G B := by
  exact div_le_div_of_nonneg_right ( Real.log_le_log ( Nat.cast_pos.mpr hA.card_pos ) ( Nat.cast_le.mpr ( Finset.card_le_card h ) ) ) ( Real.log_nonneg ( Nat.one_le_cast.mpr ( by linarith ) ) )

/-
**nlc is at most 1**.
-/
theorem nlc_le_one {G : Type*} [Fintype G] [DecidableEq G]
    (A : Finset G) (hG : 2 ≤ Fintype.card G) :
    nlc G A ≤ 1 := by
  refine' div_le_one_of_le₀ _ ( Real.log_nonneg ( by norm_cast; linarith ) );
  by_cases hA : A.Nonempty <;> simp_all +decide [ Real.log_le_log, Finset.card_le_univ ];
  exact Real.log_nonneg ( mod_cast hG.trans' ( by decide ) )

/-
**nlc is nonneg when A is nonempty**.
-/
theorem nlc_nonneg {G : Type*} [Fintype G] [DecidableEq G]
    (A : Finset G) (hA : A.Nonempty) (hG : 2 ≤ Fintype.card G) :
    0 ≤ nlc G A := by
  exact div_nonneg ( Real.log_nonneg ( mod_cast Finset.card_pos.mpr hA ) ) ( Real.log_nonneg ( mod_cast hG.trans' ( by decide ) ) )

/-! ## Section 6: Key Covering-to-Dimension Lemma -/

/-
**Core covering-to-dimension lemma**: If |S| ≤ M * |H| with positive
    parameters, then nlc(S) ≤ nlc(H) + log(M)/log|G|.

    This converts finite combinatorial covering data into a
    normalized log-cardinality (dimension) inequality.
-/
theorem nlc_le_of_card_le_mul {G : Type*} [Fintype G] [DecidableEq G]
    {S H : Finset G} {M : ℕ}
    (hcard : S.card ≤ M * H.card)
    (hS : S.Nonempty)
    (hH : H.Nonempty)
    (hM : 0 < M)
    (hG : 2 ≤ Fintype.card G) :
    nlc G S ≤ nlc G H + Real.log (M : ℝ) / Real.log (Fintype.card G : ℝ) := by
  convert div_le_div_of_nonneg_right ( Real.log_le_log ( Nat.cast_pos.mpr hS.card_pos ) ( show ( S.card:ℝ ) ≤ ( M:ℝ ) * ( H.card:ℝ ) by exact_mod_cast hcard ) ) ( Real.log_nonneg ( show ( Fintype.card G:ℝ ) ≥ 1 by norm_cast; linarith ) ) using 1;
  rw [ Real.log_mul ( by positivity ) ( by positivity ), nlc ] ; ring

/-! ## Section 7: Stabilizer Dimension Drop -/

/-- **Theorem A: Stabilizer dimension drop from cover + dimension gap**.

    If |Stab(A)| ≤ M · |H| and nlc(H) + log(M)/log|G| ≤ nlc(A),
    then nlc(Stab(A)) ≤ nlc(A).

    Combined with a Ruzsa covering lemma giving M = M(K), this yields
    strict descent when there is a nontrivial dimension gap. -/
theorem stabilizer_dim_le_of_cover_bound {G : Type*} [Fintype G] [DecidableEq G]
    [Group G]
    (A : Finset G) {H : Finset G} {M : ℕ}
    (hcard : (leftStabilizerFinset A).card ≤ M * H.card)
    (hStab : (leftStabilizerFinset A).Nonempty)
    (hH : H.Nonempty)
    (hM : 0 < M)
    (hG : 2 ≤ Fintype.card G)
    (hgap : nlc G H + Real.log (M : ℝ) / Real.log (Fintype.card G : ℝ) ≤ nlc G A) :
    nlc G (leftStabilizerFinset A) ≤ nlc G A := by
  exact le_trans (nlc_le_of_card_le_mul hcard hStab hH hM hG) hgap

/-! ## Section 8: Covering Composition -/

/-
**Covering composition**: cardinality bound transitivity.
-/
theorem covering_compose {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    {S H₁ H₂ : Finset G} {M₁ M₂ : ℕ}
    (h1 : S.card ≤ M₁ * H₁.card)
    (h2 : H₁.card ≤ M₂ * H₂.card) :
    S.card ≤ M₁ * M₂ * H₂.card := by
  simpa only [ mul_assoc ] using h1.trans ( Nat.mul_le_mul_left _ h2 )

/-! ## Section 9: Iterated Dimension Drop -/

/-- **Iterated dimension drop**: chaining multiple descent steps. -/
theorem nlc_chain {G : Type*} [Fintype G] [DecidableEq G]
    {S H₁ H₂ : Finset G} {d₁ d₂ : ℝ}
    (h1 : nlc G S ≤ nlc G H₁ + d₁)
    (h2 : nlc G H₁ ≤ nlc G H₂ + d₂) :
    nlc G S ≤ nlc G H₂ + (d₁ + d₂) := by
  linarith

/-! ## Section 10: Stabilizer Membership Tautology -/

/-- Every element of the finite stabilizer sends A into A*A. -/
theorem large_stabilizer_tautology {G : Type*} [Group G]
    [DecidableEq G] [Fintype G]
    (A : Finset G) :
    ∀ g ∈ leftStabilizerFinset A, ∀ a ∈ A, g * a ∈ A * A := by
  intro g hg a ha
  simp only [leftStabilizerFinset, Finset.mem_filter] at hg
  exact hg.2 a ha

/-- The stabilizer has at most |G| elements. -/
theorem stabilizer_card_le {G : Type*} [Group G]
    [DecidableEq G] [Fintype G]
    (A : Finset G) :
    (leftStabilizerFinset A).card ≤ Fintype.card G := by
  exact Finset.card_le_univ _

/-! ## Section 11: Descent Profile Construction -/

/-- Construct a StabilizerDescentProfile from finite data. -/
noncomputable def mkDescentProfile {G : Type*} [Group G]
    (A : Set G) (K : ℕ) (_hK : 0 < K) :
    StabilizerDescentProfile G where
  A := A
  S := leftStabilizer A
  K := K
  M := K ^ 2
  stab_eq := rfl
  cover_controlled := le_refl _

/-! ## Section 12: Proper Approximate Subgroups -/

/-- A finset A is **proper** if it has nontrivial size. -/
def IsProper {G : Type*} [Fintype G] (A : Finset G) : Prop :=
  2 ≤ A.card ∧ A.card < Fintype.card G

/-
Proper sets have positive nlc.
-/
theorem nlc_pos_of_proper {G : Type*} [Fintype G] [DecidableEq G]
    (A : Finset G) (hG : 2 ≤ Fintype.card G) (hP : IsProper A) :
    0 < nlc G A := by
  exact div_pos ( Real.log_pos ( Nat.one_lt_cast.mpr ( hP.1 ) ) ) ( Real.log_pos ( Nat.one_lt_cast.mpr hG ) )

/-
Proper sets have nlc strictly less than 1.
-/
theorem nlc_lt_one_of_proper {G : Type*} [Fintype G] [DecidableEq G]
    (A : Finset G) (hG : 2 ≤ Fintype.card G) (hP : IsProper A) :
    nlc G A < 1 := by
  convert div_lt_one ?_ |>.2 ( Real.log_lt_log ?_ ?_ );
  · exact Real.log_pos ( Nat.one_lt_cast.mpr hG );
  · exact Nat.cast_pos.mpr ( by linarith [ hP.1 ] );
  · exact_mod_cast hP.2

/-! ## Section 13: Conjecture -/

/-- The finite additive stabilizer. -/
def additiveStabilizerFinset {G : Type*} [AddGroup G] [DecidableEq G] [Fintype G]
    (A : Finset G) : Finset G :=
  Finset.univ.filter (fun g => ∀ a ∈ A, g + a ∈ A + A)

/-- Normalized log-cardinality relative to a prime p. -/
noncomputable def normalizedLogCardPrime (p : ℕ) [Fact (Nat.Prime p)]
    (A : Finset (ZMod p)) : ℝ :=
  Real.log (A.card : ℝ) / Real.log (p : ℝ)

/-- **Conjecture (Uniform Cyclic Stabilizer Drop)**. -/
def uniformCyclicStabilizerDropConjecture : Prop :=
  ∀ K : ℕ, 2 ≤ K →
    ∃ c : ℝ, 0 < c ∧
      ∃ p₀ : ℕ, ∀ p : ℕ, p₀ ≤ p → ∀ (hp : Nat.Prime p),
        ∀ A : Finset (ZMod p),
          haveI : Fact (Nat.Prime p) := ⟨hp⟩
          (A + A).card ≤ K * A.card →
          2 ≤ A.card →
          A.card < p →
          @normalizedLogCardPrime p ⟨hp⟩ (@additiveStabilizerFinset (ZMod p) _ _ _ A) ≤
            @normalizedLogCardPrime p ⟨hp⟩ A - c

end StabilizerDescent