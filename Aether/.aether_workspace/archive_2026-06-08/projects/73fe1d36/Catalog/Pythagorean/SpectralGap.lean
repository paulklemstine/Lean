/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Gap Theorems for Certified Cayley Graphs

This file proves the spectral gap theorems connecting harmonic triviality
to quantitative expansion:

1. **Dirichlet energy nonnegativity**
2. **Maximum principle → harmonic constancy**
3. **Dirichlet energy zero → constancy**
4. **Positive Dirichlet energy for nonzero mean-zero functions**
5. **Connected Cayley graphs have positive spectral gap**
-/

import Mathlib
import GL2Expander.Defs

open Finset BigOperators

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-! ## Dirichlet Energy Properties -/

theorem dirichlet_energy_nonneg
    (S : Finset G) (f : G → ℝ) :
    0 ≤ DirichletEnergy S f := by
  exact mul_nonneg (inv_nonneg.2 <| Nat.cast_nonneg _)
    (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _)

theorem dirichlet_energy_add_const
    (S : Finset G) (f : G → ℝ) (c : ℝ) :
    DirichletEnergy S (fun x => f x + c) = DirichletEnergy S f := by
  unfold DirichletEnergy; simp [add_sub_add_right_eq_sub]

/-! ## Averaging Operator Properties -/

theorem avgOp_preserves_sum
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ) :
    ∑ x : G, avgOp S f x = ∑ x : G, f x := by
  unfold avgOp
  simp only [← Finset.mul_sum _ _ _]
  rw [inv_mul_eq_div, div_eq_iff (Nat.cast_ne_zero.mpr hS.card_pos.ne')]
  rw [Finset.sum_comm, mul_comm]
  exact Eq.trans (Finset.sum_congr rfl fun _ _ => Equiv.sum_comp (Equiv.mulRight _) _) (by simp)

/-! ## Maximum Principle -/

theorem harmonic_max_neighbors_eq
    (S : Finset G) (hS : S.Nonempty)
    (f : G → ℝ) (x : G) (M : ℝ)
    (hfx : f x = M) (hmax : ∀ y : G, f y ≤ M)
    (havg : f x = avgOp S f x) :
    ∀ s ∈ S, f (x * s) = M := by
  unfold avgOp at havg
  intro s hs
  by_contra hne
  have hlt : f (x * s) < M := lt_of_le_of_ne (hmax _) hne
  have : (↑S.card : ℝ)⁻¹ * ∑ t ∈ S, f (x * t) < M := by
    rw [inv_mul_lt_iff₀ (Nat.cast_pos.mpr hS.card_pos)]
    calc ∑ t ∈ S, f (x * t)
        < ∑ _t ∈ S, M := Finset.sum_lt_sum (fun a _ => hmax (x * a)) ⟨s, hs, hlt⟩
      _ = S.card * M := by simp [mul_comm]
  linarith [havg, hfx]

theorem right_mul_closed_eq_univ'
    (S : Finset G) (A : Finset G)
    (_hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hA : A.Nonempty)
    (hclosed : ∀ a ∈ A, ∀ s ∈ S, a * s ∈ A) :
    A = Finset.univ := by
  set H : Subgroup G := Subgroup.closure (S : Set G)
  have h_mul_subset : ∀ g ∈ H, ∀ a ∈ A, a * g ∈ A := by
    refine' fun g hg => Subgroup.closure_induction (fun s hs => _) _ _ _ hg
    · exact fun a ha => hclosed a ha s hs
    · aesop
    · exact fun x y hx hy hx' hy' a ha => by simpa only [mul_assoc] using hy' _ (hx' _ ha)
    · intro x hx ih a ha
      have h_inv : Finset.image (fun b => b * x) A = A :=
        Finset.eq_of_subset_of_card_le (Finset.image_subset_iff.mpr ih)
          (by rw [Finset.card_image_of_injective _ fun a b h => mul_right_cancel h])
      replace h_inv := Finset.ext_iff.mp h_inv a; aesop
  have h_top : ∀ g : G, g ∈ H := by aesop
  obtain ⟨a, ha⟩ : ∃ a, a ∈ A := hA
  exact Finset.eq_univ_of_forall fun g => by simpa using h_mul_subset (a⁻¹ * g) (h_top _) a ha

theorem harmonic_eq_const
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarmonicOn S f) :
    ∃ c : ℝ, ∀ x : G, f x = c := by
  obtain ⟨M, hM⟩ : ∃ M, M ∈ Set.range f ∧ ∀ y ∈ Set.range f, y ≤ M := by
    exact ⟨Finset.max' (Set.range f |> Set.toFinset)
      ⟨_, Set.mem_toFinset.mpr (Set.mem_range_self 1)⟩,
      Set.mem_toFinset.mp (Finset.max'_mem _ _),
      fun y hy => Finset.le_max' _ _ (Set.mem_toFinset.mpr hy)⟩
  have hA_nonempty : (Finset.filter (fun x => f x = M) Finset.univ).Nonempty :=
    ⟨hM.1.choose, Finset.mem_filter.mpr ⟨Finset.mem_univ _, hM.1.choose_spec⟩⟩
  have hA_closed : ∀ a ∈ Finset.filter (fun x => f x = M) Finset.univ,
      ∀ s ∈ S, a * s ∈ Finset.filter (fun x => f x = M) Finset.univ := by
    intro a ha s hs
    have := harmonic_max_neighbors_eq S hS f a M ?_ ?_ ?_ <;> aesop
  exact ⟨M, fun x => by
    have := right_mul_closed_eq_univ' S (Finset.filter (fun x => f x = M) Finset.univ)
      hsym hgen (by simpa using hA_nonempty) (by simpa using hA_closed)
    replace this := Finset.ext_iff.mp this x; aesop⟩

theorem harmonic_meanzero_eq_zero'
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hf : IsHarmonicOn S f) (hmz : IsMeanZeroOn f) :
    f = 0 := by
  obtain ⟨c, hc⟩ := harmonic_eq_const S hS hsym hgen f hf
  simp_all [funext_iff, IsMeanZeroOn]

/-! ## L² Norm Properties -/

omit [Group G] [DecidableEq G] in
theorem l2NormSq_nonneg' (f : G → ℝ) : 0 ≤ l2NormSq' f :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

omit [Group G] [DecidableEq G] in
theorem l2NormSq_eq_zero_iff' (f : G → ℝ) : l2NormSq' f = 0 ↔ f = 0 := by
  unfold l2NormSq'
  rw [Finset.sum_eq_zero_iff_of_nonneg fun _ _ => sq_nonneg _]; aesop

/-! ## Dirichlet Energy Zero Implies Constancy -/

/-
If the Dirichlet energy is zero, then `f(x) = f(x*s)` for all `x` and `s ∈ S`.
-/
omit [DecidableEq G] in
theorem dirichlet_zero_implies_neighbor_eq
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ)
    (hE : DirichletEnergy S f = 0) :
    ∀ (x : G) (s : G), s ∈ S → f x = f (x * s) := by
  -- By definition of Dirichlet energy, we have that $\sum_{x \in G} \sum_{s \in S} (f(x) - f(xs))^2 = 0$.
  have h_sum_zero : ∑ x : G, ∑ s ∈ S, (f x - f (x * s)) ^ 2 = 0 := by
    unfold DirichletEnergy at hE;
    aesop;
  rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ ] at h_sum_zero;
  simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, sub_eq_zero ];
  exact fun x s hs => h_sum_zero x s hs

/-
If `f(x) = f(x*s)` for all `x, s ∈ S`, then `f` is harmonic.
-/
omit [DecidableEq G] in
theorem neighbor_eq_implies_harmonic
    (S : Finset G) (hS : S.Nonempty) (f : G → ℝ)
    (heq : ∀ (x : G) (s : G), s ∈ S → f x = f (x * s)) :
    IsHarmonicOn S f := by
  intro x
  unfold avgOp
  have h_sum_eq : ∑ s ∈ S, f (x * s) = S.card * f x := by
    rw [ Finset.sum_congr rfl fun s hs => heq x s hs |> Eq.symm, Finset.sum_const, nsmul_eq_mul ]
  simp [h_sum_eq];
  rw [ ← mul_assoc, inv_mul_cancel₀ ( Nat.cast_ne_zero.mpr hS.card_pos.ne' ), one_mul ]

/-
**Theorem (Positive Dirichlet energy for nonzero mean-zero functions).**

On a connected Cayley graph, the Dirichlet energy of any nonzero mean-zero
function is strictly positive. This is the core qualitative spectral gap result.

*Proof.* If E(f) = 0, then f(x) = f(x*s) for all generators s. By the
maximum principle (via harmonic constancy), f is constant. Being mean-zero
and constant, f = 0.
-/
theorem dirichlet_pos_of_meanzero_nonzero
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hmz : IsMeanZeroOn f) (hf : f ≠ 0) :
    0 < DirichletEnergy S f := by
  contrapose! hf;
  apply harmonic_meanzero_eq_zero' S hS hsym hgen f (neighbor_eq_implies_harmonic S hS f (dirichlet_zero_implies_neighbor_eq S hS f (le_antisymm hf (dirichlet_energy_nonneg S f)) )) hmz

/-! ## Spectral Gap Positivity -/

/-
**Theorem (Harmonic triviality implies positive spectral gap).**

This is the quantitative bridge from harmonic analysis to spectral expansion.
The spectral gap `spectralGap' S` — defined as the infimum of
`E(f)/‖f‖²` over nonzero mean-zero functions — is strictly positive
whenever the Cayley graph is connected.

*Proof.* The spectral gap equals the minimum eigenvalue of the Laplacian
restricted to the mean-zero subspace. Since harmonic triviality implies
this eigenvalue is positive, the spectral gap is positive.

In the finite-dimensional setting, this minimum is attained (the set
of unit-norm mean-zero functions is compact), so the infimum is
actually a minimum.
-/
theorem harmonic_trivial_implies_gap_pos'
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hcard : 1 < Fintype.card G)
    (hharm : ∀ f : G → ℝ, IsHarmonicOn S f → IsMeanZeroOn f → f = 0) :
    0 < spectralGap' S := by
  -- By definition of $spectralGap'$ �,� we know that it is the infimum of $ DirichletEnergy S$ over nonzero mean-zero functions.
  have h_inf_pos : ∃ f : G → ℝ, IsMeanZeroOn f ∧ l2NormSq' f = 1 ∧ 0 < DirichletEnergy S f := by
    -- Let's choose any $f$ that � is� mean-zero and has unit $L^2$ norm.
    obtain ⟨f, hf_mean_zero, hf_norm⟩ : ∃ f : G → ℝ, IsMeanZeroOn f ∧ l2NormSq' f = 1 := by
      -- Let's choose any two distinct � elements� $a$ and $b$ in $G$.
      obtain ⟨a, b, hab⟩ : ∃ a b : G, a ≠ b := by
        exact Fintype.one_lt_card_iff.1 hcard;
      -- Define the function $f$ such that $f(a) = \frac{1}{\sqrt{2}}$, $f(b) = -\frac{1}{\sqrt �{�2}}$, and $f(x) = 0$ for all other $x \in G$.
      use fun x => if x = a then 1 / Real.sqrt 2 else if x = b then -1 / Real.sqrt 2 else 0;
      unfold IsMeanZeroOn l2NormSq';
      norm_num [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hab ];
      grind;
    grind +suggestions;
  -- Since the set of mean-zero functions is compact and the� Dir�ich �let� energy is continuous, the infimum is attained.
  have h_compact : IsCompact {f : G → ℝ | IsMeanZeroOn f ∧ l2NormSq' f = 1} := by
    have h_closed : IsClosed {f : G → ℝ | IsMeanZeroOn f ∧ l2NormSq' f = 1} := by
      exact IsClosed.inter ( isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_apply _ ) continuous_const ) ( isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_apply _ |> Continuous.pow <| 2 ) continuous_const );
    exact CompactIccSpace.isCompact_Icc.of_isClosed_subset h_closed fun f hf => ⟨ fun i => neg_le_of_abs_le <| by simpa using Real.abs_le_sqrt <| show f i ^ 2 ≤ 1 by have := hf.2; rw [ show l2NormSq' f = ∑ i, f i ^ 2 from rfl ] at this; exact this ▸ Finset.single_le_sum ( fun i _ => sq_nonneg ( f i ) ) ( Finset.mem_univ i ), fun i => le_of_abs_le <| by simpa using Real.abs_le_sqrt <| show f i ^ 2 ≤ 1 by have := hf.2; rw [ show l2NormSq' f = ∑ i, f i ^ 2 from rfl ] at this; exact this ▸ Finset.single_le_sum ( fun i _ => sq_nonneg ( f i ) ) ( Finset.mem_univ i ) ⟩;
  -- By the extreme value theorem, the infimum of $ DirichletEnergy S$ over nonzero mean-zero functions is attained.
  obtain ⟨f, hf⟩ : ∃ f ∈ {f : G → ℝ | IsMeanZeroOn f ∧ l2NormSq' f = 1}, ∀ g ∈ {f : G → ℝ | IsMeanZeroOn f ∧ l2NormSq' f = 1}, DirichletEnergy S f ≤ DirichletEnergy S g := by
    have h_continuous : ContinuousOn (fun f : G → ℝ => DirichletEnergy S f) {f : G → ℝ | IsMeanZeroOn f ∧ l2NormSq' f = 1} := by
      refine' Continuous.continuousOn _;
      refine' continuous_const.mul _;
      fun_prop;
    exact h_compact.exists_isMinOn ⟨ h_inf_pos.choose, h_inf_pos.choose_spec.1, h_inf_pos.choose_spec.2.1 ⟩ h_continuous;
  refine' lt_of_lt_of_le _ ( le_csInf _ _ );
  any_goals exact Set.Nonempty.image _ ⟨ f, hf.1 ⟩;
  convert dirichlet_pos_of_meanzero_nonzero S hS hsym hgen f hf.1.1 _;
  · rintro rfl; simp_all +decide [ l2NormSq' ];
  · grind +qlia

/--
**Master Theorem (Connected Cayley graphs have positive spectral gap).**

For any symmetric generating set of a finite group with |G| > 1,
the Cayley graph has positive spectral gap.
-/
theorem connected_cayley_spectral_gap_pos'
    (S : Finset G) (hS : S.Nonempty)
    (hsym : ∀ s ∈ S, s⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (hcard : 1 < Fintype.card G) :
    0 < spectralGap' S :=
  harmonic_trivial_implies_gap_pos' S hS hsym hgen hcard
    (harmonic_meanzero_eq_zero' S hS hsym hgen)