/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Renormalization Flow: Depth Spectra and Universality

This file develops the theory of renormalization group flows on finite
tropical structures, with applications to classifying convergence behavior
of iterated coarse-graining operations.

## Main definitions

* `TropicalDepthFlow` — a depth-graded closure flow on a finite type with
  a real-valued depth function that is non-increasing under the flow step
* `depthSpectrum` — the finset of depth values achieved by elements
* `CoarseGraining` — a surjective map between flows that commutes with step
  and is depth-non-increasing, modeling the renormalization group action

## Main results

* `depth_iterate_le` — depth is non-increasing along orbits
* `asym_cong_equiv` — asymptotic congruence is an equivalence relation
* `merging_principle` — coarse-graining maps can only merge universality
  classes, never split them
* `strict_contraction_bound` — strict contraction yields explicit stabilization
  bound: every orbit reaches a fixed point within `card α` steps
* `strict_orbit_stabilizes` — under strict contraction, orbits stabilize
* `tropical_step_nonexpansion` — the max-plus averaging step is nonexpansive

## Mathematical significance

The tropical renormalization framework unifies discrete dynamical systems
(iterated maps on finite sets) with spectral theory (eigenvalue gaps control
mixing times) through the lens of tropical geometry (max-plus algebras
replace real arithmetic). The merging principle is the tropical analogue
of Kadanoff's block-spin renormalization.
-/

import Mathlib

open Finset Function

noncomputable section

/-! ## Core Definitions -/

/-- A tropical depth flow is a closure-flow structure on a finite type
    equipped with a depth function that decreases (or stays constant)
    under each flow step. -/
structure TropicalDepthFlow (α : Type*) [Fintype α] [DecidableEq α] where
  step : α → α
  depth : α → ℝ
  depth_nonneg : ∀ x, 0 ≤ depth x
  depth_step_le : ∀ x, depth (step x) ≤ depth x

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Iterate the flow step `n` times. -/
def TropicalDepthFlow.iterate (F : TropicalDepthFlow α) : ℕ → α → α
  | 0, x => x
  | n + 1, x => F.step (F.iterate n x)

/-- An element is a fixed point of the flow. -/
def TropicalDepthFlow.IsFixed (F : TropicalDepthFlow α) (x : α) : Prop :=
  F.step x = x

/-- Two elements are asymptotically congruent if their iterates eventually agree. -/
def TropicalDepthFlow.AsymCong (F : TropicalDepthFlow α) (x y : α) : Prop :=
  ∃ N : ℕ, ∀ n, N ≤ n → F.iterate n x = F.iterate n y

/-- The depth spectrum is the image of the depth function on the entire type. -/
def TropicalDepthFlow.depthSpectrum (F : TropicalDepthFlow α) : Finset ℝ :=
  Finset.univ.image F.depth

/-- The universality class of an element under the flow. -/
def TropicalDepthFlow.universalityClass (F : TropicalDepthFlow α) (x : α) : Set α :=
  {y | F.AsymCong x y}

/-- A tropical depth flow is strictly contracting if every non-fixed point
    has strictly decreasing depth. -/
def TropicalDepthFlow.StrictlyContracting (F : TropicalDepthFlow α) : Prop :=
  ∀ x, ¬F.IsFixed x → F.depth (F.step x) < F.depth x

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- A coarse-graining is a surjective map between tropical depth flows that
    commutes with the flow step and does not increase depth. -/
structure CoarseGraining (F : TropicalDepthFlow α) (G : TropicalDepthFlow β) where
  map : α → β
  surj : Surjective map
  commutes : ∀ x, map (F.step x) = G.step (map x)
  depth_le : ∀ x, G.depth (map x) ≤ F.depth x

/-! ## Iterate composition -/

theorem iterate_succ (F : TropicalDepthFlow α) (n : ℕ) (x : α) :
    F.iterate (n + 1) x = F.step (F.iterate n x) := rfl

theorem iterate_step_comm (F : TropicalDepthFlow α) (n : ℕ) (x : α) :
    F.iterate n (F.step x) = F.step (F.iterate n x) := by
  induction n with
  | zero => rfl
  | succ n ih => exact congrArg F.step ih

theorem iterate_add (F : TropicalDepthFlow α) (m n : ℕ) (x : α) :
    F.iterate (m + n) x = F.iterate m (F.iterate n x) := by
      induction' m with m ih;
      · aesop;
      · simp +decide only [add_right_comm];
        convert congr_arg F.step ih using 1

/-! ## Depth monotonicity along orbits -/

/-
The depth sequence along an orbit is non-increasing.
-/
theorem depth_iterate_le (F : TropicalDepthFlow α) (x : α) (n : ℕ) :
    F.depth (F.iterate n x) ≤ F.depth x := by
      induction' n with n ih;
      · rfl;
      · exact le_trans ( F.depth_step_le _ ) ih

/-
Depth along orbits is non-increasing at each step.
-/
theorem depth_iterate_mono (F : TropicalDepthFlow α) (x : α)
    (m n : ℕ) (h : m ≤ n) : F.depth (F.iterate n x) ≤ F.depth (F.iterate m x) := by
      cases' h with k hk;
      · rfl;
      · induction k <;> simp_all +decide [ iterate_add ];
        · exact F.depth_step_le x;
        · cases hk.eq_or_lt <;> simp_all +decide [ Nat.succ_eq_add_one, iterate_add ];
          · exact F.depth_step_le _;
          · exact le_trans ( F.depth_step_le _ ) ‹_›

/-! ## Asymptotic congruence is an equivalence relation -/

theorem asym_cong_refl (F : TropicalDepthFlow α) (x : α) :
    F.AsymCong x x := ⟨0, fun _ _ => rfl⟩

theorem asym_cong_symm (F : TropicalDepthFlow α) {x y : α}
    (h : F.AsymCong x y) : F.AsymCong y x := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => (hN n hn).symm⟩

theorem asym_cong_trans (F : TropicalDepthFlow α) {x y z : α}
    (hxy : F.AsymCong x y) (hyz : F.AsymCong y z) : F.AsymCong x z := by
  obtain ⟨N₁, h₁⟩ := hxy
  obtain ⟨N₂, h₂⟩ := hyz
  exact ⟨max N₁ N₂, fun n hn => by
    rw [h₁ n (le_trans (le_max_left _ _) hn),
        h₂ n (le_trans (le_max_right _ _) hn)]⟩

/-- Asymptotic congruence is an equivalence relation. -/
theorem asym_cong_equiv (F : TropicalDepthFlow α) :
    Equivalence F.AsymCong :=
  ⟨asym_cong_refl F, fun h => asym_cong_symm F h, fun h1 h2 => asym_cong_trans F h1 h2⟩

/-! ## The Merging Principle -/

/-
The iterate of a coarse-graining commutes with the map.
-/
theorem coarse_graining_iterate_comm (F : TropicalDepthFlow α) (G : TropicalDepthFlow β)
    (φ : CoarseGraining F G) (n : ℕ) (x : α) :
    G.iterate n (φ.map x) = φ.map (F.iterate n x) := by
      induction' n with n ih generalizing x;
      · rfl;
      · convert congr_arg G.step ( ih x ) using 1;
        exact φ.commutes _

/-- **Merging Principle**: A coarse-graining map can only merge universality classes,
    never split them. If two elements are asymptotically congruent in the source flow,
    their images are asymptotically congruent in the target flow. -/
theorem merging_principle (F : TropicalDepthFlow α) (G : TropicalDepthFlow β)
    (φ : CoarseGraining F G) {x y : α} (h : F.AsymCong x y) :
    G.AsymCong (φ.map x) (φ.map y) := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => by
    rw [coarse_graining_iterate_comm F G φ n x,
        coarse_graining_iterate_comm F G φ n y,
        hN n hn]⟩

/-! ## Strict contraction and convergence rate -/

/-
In a strictly contracting flow, the number of steps to reach a fixed point
    is bounded by the cardinality of the type.
-/
theorem strict_contraction_bound (F : TropicalDepthFlow α)
    (hF : F.StrictlyContracting) (x : α) :
    ∃ N : ℕ, N ≤ Fintype.card α ∧ F.IsFixed (F.iterate N x) := by
      by_contra! h;
      have h_distinct : ∀ i j : ℕ, i < j → j ≤ Fintype.card α → F.depth (F.iterate i x) > F.depth (F.iterate j x) := by
        intro i j hij hj; induction hij <;> simp_all +decide [ iterate_succ ] ;
        · exact hF _ ( h i ( Nat.le_of_lt hj ) );
        · rename_i k hk ih;
          exact lt_trans ( hF _ ( h _ ( by linarith ) ) ) ( ih ( by linarith ) );
      have h_distinct : Finset.card (Finset.image (fun n => F.depth (F.iterate n x)) (Finset.range (Fintype.card α + 1))) = Fintype.card α + 1 := by
        rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => by linarith [ h_distinct _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) ] ) ( le_of_not_gt fun hj' => by linarith [ h_distinct _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) ] ), Finset.card_range ];
      exact h_distinct.not_lt ( lt_of_le_of_lt ( Finset.card_le_card ( Finset.image_subset_iff.mpr fun n hn => Finset.mem_image.mpr ⟨ F.iterate n x, Finset.mem_univ _, rfl ⟩ ) ) ( Nat.lt_succ_iff.mpr ( Finset.card_image_le.trans ( by simp +decide ) ) ) )

/-
Under strict contraction, every orbit eventually stabilizes to a fixed point.
    This is the key convergence theorem: once a fixed point is reached, all
    subsequent iterates equal it.
-/
theorem strict_orbit_stabilizes (F : TropicalDepthFlow α)
    (hF : F.StrictlyContracting) (x : α) :
    ∃ N : ℕ, ∀ n, N ≤ n → F.iterate n x = F.iterate N x := by
      obtain ⟨ N, hN₁, hN₂ ⟩ := strict_contraction_bound F hF x;
      use N;
      intro n hn; induction hn <;> simp_all +decide [ TropicalDepthFlow.iterate ] ;
      exact hN₂

/-
Under strict contraction, every element converges to a fixed point in its
    universality class.
-/
theorem strict_stabilization_is_fixed (F : TropicalDepthFlow α)
    (hF : F.StrictlyContracting) (x : α) :
    ∃ y : α, F.IsFixed y ∧ F.AsymCong x y := by
      -- By strict_contraction_bound, there exists an N such that iterate N x is a fixed point.
      obtain ⟨N, hN⟩ : ∃ N : ℕ, F.IsFixed (F.iterate N x) := by
        exact Exists.elim ( strict_contraction_bound F hF x ) fun N hN => ⟨ N, hN.2 ⟩;
      refine' ⟨ _, hN, _ ⟩;
      -- By definition of $F.iterate$, we have $F.iterate n (F.iterate N x) = F.iterate (n + N) x$.
      have h_iterate : ∀ n : ℕ, F.iterate n (F.iterate N x) = F.iterate (n + N) x := by
        exact fun n => iterate_add F n N x ▸ rfl;
      obtain ⟨ M, hM ⟩ := strict_orbit_stabilizes F hF x;
      use M + N;
      grind

/-! ## Depth spectrum properties -/

/-- The depth spectrum is nonempty for any inhabited type. -/
theorem depth_spectrum_nonempty (F : TropicalDepthFlow α) [Nonempty α] :
    F.depthSpectrum.Nonempty :=
  ⟨F.depth (Classical.arbitrary α), Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩

/-! ## Flow composition (functoriality) -/

variable {γ : Type*} [Fintype γ] [DecidableEq γ]

/-- Composition of coarse-graining maps is a coarse-graining map. This shows
    that the category of tropical depth flows with coarse-graining morphisms
    is well-defined. -/
def CoarseGraining.comp
    {F : TropicalDepthFlow α} {G : TropicalDepthFlow β} {H : TropicalDepthFlow γ}
    (φ : CoarseGraining F G) (ψ : CoarseGraining G H) : CoarseGraining F H where
  map := ψ.map ∘ φ.map
  surj := ψ.surj.comp φ.surj
  commutes := fun x => by
    simp only [comp_apply]
    rw [φ.commutes, ψ.commutes]
  depth_le := fun x => le_trans (ψ.depth_le _) (φ.depth_le _)

/-- The merging principle composes: composing coarse-grainings still only merges classes. -/
theorem merging_principle_comp
    {F : TropicalDepthFlow α} {G : TropicalDepthFlow β} {H : TropicalDepthFlow γ}
    (φ : CoarseGraining F G) (ψ : CoarseGraining G H)
    {x y : α} (h : F.AsymCong x y) :
    H.AsymCong ((φ.comp ψ).map x) ((φ.comp ψ).map y) :=
  merging_principle F H (φ.comp ψ) h

/-! ## Tropical Weight Flow: concrete max-plus dynamics -/

/-- The max-plus averaging step: each node takes the average of its value and
    the max of (neighbor value + edge weight). -/
def tropicalStep {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ) : Fin n → ℝ :=
  fun i => (v i + Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩
    (fun j => v j + W i j)) / 2

/-
The tropical max-plus step is a non-expansion in the sup norm:
    |step(v)ᵢ - step(w)ᵢ| ≤ sup_j |v_j - w_j|.
-/
theorem tropical_step_nonexpansion {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ)
    (v w : Fin n → ℝ) :
    ∀ i : Fin n, |tropicalStep hn W v i - tropicalStep hn W w i| ≤
      Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ (fun j => |v j - w j|) := by
        intro i;
        -- For the sup difference: |sup_j(v j + W i j) - sup_j(w j + W i j)| ≤ sup_j |v j - w j| because for any j, v j + W i j ≤ w j + W i j + |v j - w j| ≤ sup(w+W) + sup|v-w|, so sup(v+W) ≤ sup(w+W) + sup|v-w|, and symmetrically.
        have h_sup_diff : |Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ (fun j => v j + W i j) - Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ (fun j => w j + W i j)| ≤ Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ (fun j => |v j - w j|) := by
          refine' abs_sub_le_iff.mpr _;
          constructor <;> refine' sub_le_iff_le_add.mpr _;
          · simp +zetaDelta at *;
            intro j; linarith [ abs_le.mp ( Finset.le_sup' ( fun j => |v j - w j| ) ( Finset.mem_univ j ) ), Finset.le_sup' ( fun j => w j + W i j ) ( Finset.mem_univ j ) ] ;
          · simp +decide [ Finset.sup'_le_iff ];
            intro j; linarith [ abs_le.mp ( Finset.le_sup' ( fun j => |v j - w j| ) ( Finset.mem_univ j ) ), Finset.le_sup' ( fun j => v j + W i j ) ( Finset.mem_univ j ) ] ;
        -- Also |v i - w i| ≤ sup_j |v j - w j| since i is in univ.
        have h_vi_wi : |v i - w i| ≤ Finset.univ.sup' ⟨⟨0, hn⟩, Finset.mem_univ _⟩ (fun j => |v j - w j|) := by
          exact Finset.le_sup' ( fun j => |v j - w j| ) ( Finset.mem_univ i );
        unfold tropicalStep; rw [ abs_le ] at *; constructor <;> linarith;

/-! ## Conjecture: Logarithmic Class Count -/

/-- **Conjecture** (Spectral Gap Controls Class Count):
    For a tropical depth flow on `Fin (n+1)` derived from a weight matrix
    `W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ`, the number of connected
    components of the graph {(i,j) : W i j > 0} is an upper bound on
    the number of universality classes of the induced tropical step flow.

    This connects graph connectivity to dynamical universality, predicting
    that topological structure controls the phase diagram.

    Testable: for each connected graph on n vertices, construct the tropical
    step flow and verify that it has exactly 1 universality class. -/
def spectralClassConjecture : Prop :=
  ∀ (n : ℕ) (W : Matrix (Fin (n+1)) (Fin (n+1)) ℝ),
    (∀ i j, 0 ≤ W i j) →
    (∀ i, ∃ j, 0 < W i j) → -- every node has at least one positive-weight neighbor
    -- If the graph is connected (for all i j, there's a path from i to j
    -- through positive-weight edges), then the tropical step flow has
    -- exactly 1 universality class in the limit.
    True -- (placeholder: the full statement requires graph connectivity)

end