/-
# Voice-Leading Geometry: Four-Voice Harmonic Motion as Metric Space

This file establishes that four-voice harmonic motion admits a formally verified
geodesic cost structure. The central object is `vlCost4`, a permutation-minimized
voice-leading cost on `Fin 4 → ℤ`, which we prove satisfies the triangle inequality,
is invariant under voice permutations, and is optimized by sorted matching when both
chords are monotone.

## Main Results

* `vlCost4_triangle`: The four-voice voice-leading cost satisfies the triangle inequality,
  making it a pseudometric on chord space.
* `vlCost4_perm_invariant`: The cost is invariant under independent permutation of voices
  in both source and target chords.
* `vlCost4_sorted_optimal`: When both chords are monotone nondecreasing, the identity
  matching (no voice crossing) realizes the minimal cost.
* `abs_swap_uncross`: The atomic uncrossing lemma: swapping crossed voice assignments
  never increases total absolute deviation.

## Mathematical Significance

These results formalize the geometry of harmonic motion: chord space becomes a metric
space under voice-leading cost, optimal voice assignment has canonical structure
(sorted matching), and harmonic progressions compose with bounded cost (triangle
inequality). This is the foundation for certified harmonic path planning, connections
to discrete optimal transport, and tropical/min-plus algebraic structure on progression
spaces.
-/

import Mathlib

open Finset Function Equiv

/-! ## Core Definitions -/

/-- A four-voice chord: an assignment of integer pitches to four voices. -/
abbrev Chord4 := Fin 4 → ℤ

/-- The cost of a specific voice assignment given by permutation `σ`:
    the sum of absolute pitch differences across matched voices. -/
def permCost (x y : Chord4) (σ : Equiv.Perm (Fin 4)) : ℕ :=
  ∑ i : Fin 4, Int.natAbs (x i - y (σ i))

/-- The optimal four-voice voice-leading cost: the minimum over all 24 permutations
    of the per-voice absolute pitch differences. This is a discrete assignment cost. -/
noncomputable def vlCost4 (x y : Chord4) : ℕ :=
  Finset.inf' Finset.univ ⟨1, Finset.mem_univ 1⟩ (permCost x y)

/-- A chord is monotone nondecreasing (sorted in pitch order). -/
def MonotoneFin4 (x : Chord4) : Prop :=
  ∀ ⦃i j : Fin 4⦄, i ≤ j → x i ≤ x j

/-! ## Helper Lemmas -/

/-- The voice-leading cost for a specific permutation is bounded below by the optimal cost. -/
theorem vlCost4_le_permCost (x y : Chord4) (σ : Equiv.Perm (Fin 4)) :
    vlCost4 x y ≤ permCost x y σ :=
  Finset.inf'_le _ (Finset.mem_univ σ)

/-
There exists an optimal permutation realizing the voice-leading cost.
-/
theorem vlCost4_exists_optimal (x y : Chord4) :
    ∃ σ : Equiv.Perm (Fin 4), vlCost4 x y = permCost x y σ := by
  convert Finset.exists_mem_eq_inf' _ _;
  rotate_left;
  exact ℕ;
  exact inferInstance;
  exact Finset.univ;
  exact ⟨ 1, Finset.mem_univ _ ⟩;
  exact fun σ => permCost x y σ;
  aesop

/-
Pointwise triangle inequality for Int.natAbs.
-/
theorem int_natAbs_triangle (a b c : ℤ) :
    Int.natAbs (a - c) ≤ Int.natAbs (a - b) + Int.natAbs (b - c) := by
  grind +ring

/-
Sum of natAbs differences satisfies triangle inequality under composition.
-/
theorem permCost_triangle_comp (x y z : Chord4) (σ τ : Equiv.Perm (Fin 4)) :
    permCost x z (τ * σ) ≤ permCost x y σ + permCost y z τ := by
  unfold permCost at *;
  convert Finset.sum_le_sum fun i _ => int_natAbs_triangle ( x i ) ( y ( σ i ) ) ( z ( τ ( σ i ) ) ) using 1;
  rw [ Finset.sum_add_distrib, ← Equiv.sum_comp σ fun i => Int.natAbs ( y i - z ( τ i ) ) ]

/-! ## Theorem 1: Triangle Inequality -/

/-
**Main Theorem 1.** The four-voice voice-leading cost satisfies the triangle inequality.
    This makes `(Chord4, vlCost4)` a pseudometric space, establishing that harmonic motion
    admits a genuine geodesic cost geometry.
-/
theorem vlCost4_triangle (x y z : Chord4) :
    vlCost4 x z ≤ vlCost4 x y + vlCost4 y z := by
  -- By definition of $vlCost4$, we know that there exist permutations $\sigma$ and $\tau$ such that $vlCost4 x y = permCost x y \sigma$ and $vlCost4 y z = permCost y z \tau$.
  obtain ⟨σ, hσ⟩ := vlCost4_exists_optimal x y
  obtain ⟨τ, hτ⟩ := vlCost4_exists_optimal y z;
  exact hσ.symm ▸ hτ.symm ▸ le_trans ( vlCost4_le_permCost x z ( τ * σ ) ) ( permCost_triangle_comp x y z σ τ )

/-! ## Theorem 2: Permutation Invariance -/

/-
**Main Theorem 2.** The voice-leading cost is invariant under independent permutation
    of voices in both chords. This identifies the true object of study as chord configuration
    modulo voice labels—the conceptual leap from "voices as registers" to "harmonic state space."
-/
theorem vlCost4_perm_invariant (x y : Chord4) (τ₁ τ₂ : Equiv.Perm (Fin 4)) :
    vlCost4 (x ∘ τ₁) (y ∘ τ₂) = vlCost4 x y := by
  refine' le_antisymm _ _;
  · -- Let $\sigma$ be a permutation that realizes the minimum cost for $x$ and $y$.
    obtain ⟨σ, hσ⟩ : ∃ σ : Equiv.Perm (Fin 4), vlCost4 x y = permCost x y σ := vlCost4_exists_optimal x y;
    refine' le_trans ( Finset.inf'_le _ <| Finset.mem_univ <| τ₂⁻¹ * σ * τ₁ ) _;
    unfold permCost at *; simp_all +decide [ Fin.sum_univ_four ] ;
    have := Equiv.sum_comp τ₁ fun i => Int.natAbs ( x i - y ( σ i ) ) ; ( have := Equiv.sum_comp ( Equiv.refl ( Fin 4 ) ) fun i => Int.natAbs ( x i - y ( σ i ) ) ; simp_all +decide [ Fin.sum_univ_four ] ; );
  · obtain ⟨ σ, hσ ⟩ := vlCost4_exists_optimal ( x ∘ τ₁ ) ( y ∘ τ₂ );
    convert vlCost4_le_permCost x y ( τ₂ * σ * τ₁⁻¹ ) using 1;
    unfold permCost at *;
    rw [ hσ, ← Equiv.sum_comp ( τ₁⁻¹ ) ] ; aesop

/-! ## Uncrossing Lemma -/

/-
**Atomic Uncrossing Lemma.** If `a ≤ b` and `c ≤ d`, then the "crossed" assignment
    `|a - d| + |b - c|` costs at least as much as the "uncrossed" assignment
    `|a - c| + |b - d|`. This is the engine behind Monge optimality.
-/
theorem abs_swap_uncross {a b c d : ℤ} (hab : a ≤ b) (hcd : c ≤ d) :
    Int.natAbs (a - c) + Int.natAbs (b - d) ≤
    Int.natAbs (a - d) + Int.natAbs (b - c) := by
  omega

/-! ## Theorem 3: Sorted Matching Optimality -/

/-
**Main Theorem 3.** When both chords are monotone nondecreasing, the identity matching
    (no voice crossing) realizes the minimal cost. This is a discrete Monge/rearrangement
    theorem: optimal four-voice transport in 1D is canonical after sorting.
-/
theorem vlCost4_sorted_optimal (x y : Chord4) (hx : MonotoneFin4 x) (hy : MonotoneFin4 y) :
    vlCost4 x y = ∑ i : Fin 4, Int.natAbs (x i - y i) := by
  refine' le_antisymm (vlCost4_le_permCost x y 1) _;
  -- By the properties of the absolute value function and the monotonicity of $x$ and $y$, we can show that the sum of absolute differences is minimized when the voices are matched in order.
  have h_abs_diff_min : ∀ (σ : Equiv.Perm (Fin 4)), ∑ i, Int.natAbs (x i - y (σ i)) ≥ ∑ i, Int.natAbs (x i - y i) := by
    intro σ;
    -- By the properties of the absolute value function and the monotonicity of $x$ and $y$, we can show that the sum of absolute differences is minimized when the voices are matched in order. We can prove this by considering all possible permutations of the voices.
    have h_permutations : ∀ (σ : Equiv.Perm (Fin 4)), ∑ i, Int.natAbs (x i - y (σ i)) ≥ ∑ i, Int.natAbs (x i - y i) := by
      intro σ
      have h_cases : ∀ (i j k l : Fin 4), i ≠ j ∧ i ≠ k ∧ i ≠ l ∧ j ≠ k ∧ j ≠ l ∧ k ≠ l → Int.natAbs (x 0 - y i) + Int.natAbs (x 1 - y j) + Int.natAbs (x 2 - y k) + Int.natAbs (x 3 - y l) ≥ Int.natAbs (x 0 - y 0) + Int.natAbs (x 1 - y 1) + Int.natAbs (x 2 - y 2) + Int.natAbs (x 3 - y 3) := by
        intro i j k l hijkl
        have h_cases : ∀ (i j k l : Fin 4), i ≠ j ∧ i ≠ k ∧ i ≠ l ∧ j ≠ k ∧ j ≠ l ∧ k ≠ l → Int.natAbs (x 0 - y i) + Int.natAbs (x 1 - y j) + Int.natAbs (x 2 - y k) + Int.natAbs (x 3 - y l) ≥ Int.natAbs (x 0 - y 0) + Int.natAbs (x 1 - y 1) + Int.natAbs (x 2 - y 2) + Int.natAbs (x 3 - y 3) := by
          intro i j k l hijkl
          have h_monotone : x 0 ≤ x 1 ∧ x 1 ≤ x 2 ∧ x 2 ≤ x 3 ∧ y 0 ≤ y 1 ∧ y 1 ≤ y 2 ∧ y 2 ≤ y 3 := by
            exact ⟨ hx ( by decide ), hx ( by decide ), hx ( by decide ), hy ( by decide ), hy ( by decide ), hy ( by decide ) ⟩
          fin_cases i <;> fin_cases j <;> simp +decide at hijkl ⊢;
          all_goals fin_cases k <;> fin_cases l <;> simp +decide at hijkl ⊢;
          grind +extAll;
          lia;
          grind +splitImp;
          lia;
          grind +splitImp;
          bv_omega;
          lia;
          grind +splitIndPred;
          grind +extAll;
          lia;
          lia;
          lia;
          grind +qlia;
          lia;
          grind +splitImp;
          grind +splitImp;
          lia;
          grind +splitImp;
          · grind +splitImp;
          · grind +splitImp;
          · grind +splitImp;
          · grind +splitImp;
          · grind +splitImp;
        exact h_cases i j k l hijkl
      simp +decide [ Fin.sum_univ_four ];
      exact h_cases _ _ _ _ ⟨ σ.injective.ne ( by decide ), σ.injective.ne ( by decide ), σ.injective.ne ( by decide ), σ.injective.ne ( by decide ), σ.injective.ne ( by decide ), σ.injective.ne ( by decide ) ⟩;
    exact h_permutations σ;
  exact Finset.le_inf' _ _ fun σ _ => h_abs_diff_min σ

/-! ## Self-cost is zero -/

/-
The voice-leading cost of a chord to itself is zero.
-/
theorem vlCost4_self (x : Chord4) : vlCost4 x x = 0 := by
  refine' le_antisymm _ _;
  · exact Finset.inf'_le _ ( Finset.mem_univ 1 ) |> le_trans <| by simp +decide [ permCost ] ;
  · exact Nat.zero_le _

/-! ## Symmetry -/

/-
The voice-leading cost is symmetric.
-/
theorem vlCost4_symm (x y : Chord4) : vlCost4 x y = vlCost4 y x := by
  -- By definition of `permCost`, we know that `permCost x y σ = permCost y x (σ⁻¹)`.
  have h_permCost_symm (σ : Equiv.Perm (Fin 4)) : permCost x y σ = permCost y x σ⁻¹ := by
    apply Finset.sum_bij (fun i _ => σ i);
    · exact fun _ _ => Finset.mem_univ _;
    · exact fun a₁ _ a₂ _ h => σ.injective h;
    · exact fun b _ => ⟨ σ.symm b, Finset.mem_univ _, by simp +decide ⟩;
    · exact fun a _ => by rw [ Equiv.Perm.inv_apply_self ] ; rw [ ← Int.natAbs_neg ] ; ring;
  unfold vlCost4;
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun σ => ⟨ σ⁻¹, by simp +decide ⟩;
  · exact fun σ => ⟨ σ⁻¹, le_rfl ⟩

/-! ## Computational Examples -/

/-- C major triad doubled at root in close position: C3 E3 G3 C4 = [48, 52, 55, 60] -/
def cMajor4 : Chord4 := ![48, 52, 55, 60]

/-- F major triad doubled at root: F3 A3 C4 F4 = [53, 57, 60, 65] -/
def fMajor4 : Chord4 := ![53, 57, 60, 65]

/-- G dominant seventh: G3 B3 D4 F4 = [55, 59, 62, 65] -/
def gDom7 : Chord4 := ![55, 59, 62, 65]

/-- The identity permutation cost for C major → F major is computable. -/
example : permCost cMajor4 fMajor4 1 = 20 := by native_decide

/-- The voice-leading cost is at most the identity permutation cost. -/
theorem vlCost4_cMaj_fMaj_le : vlCost4 cMajor4 fMajor4 ≤ 20 := by
  calc vlCost4 cMajor4 fMajor4 ≤ permCost cMajor4 fMajor4 1 :=
        vlCost4_le_permCost _ _ _
    _ = 20 := by native_decide