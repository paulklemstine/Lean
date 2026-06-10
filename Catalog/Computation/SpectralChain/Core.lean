/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Chain Framework: Finite Reversible Markov Chains

This file builds, from first principles, a formally verified bridge between four
mathematical domains for finite reversible Markov chains:

* **Spectral graph theory** — Dirichlet forms, variance, Poincaré (spectral gap)
* **Probability** — stationary mean, mixing-time bounds
* **Geometry** — edge weights / flows, conductance (Cheeger constant), cut symmetry
* **Combinatorics** — phase classification through the spectral gap

## Main Results

1. `weight_symm` — reversibility makes the edge weight `π_i P_ij` symmetric.
2. `Var_eq_double_sum` — the variance double-sum identity
   `Var(f) = ½ ∑_{i,j} π_i π_j (f_i - f_j)²`.
3. `flowOut_symm` — flow out of a cut equals flow into it (cut symmetry).
4. `DirichletForm_indicator` / `Var_indicator` — Dirichlet form and variance of a
   set indicator are the cut flow and `π(S)(1-π(S))`.
5. `cheeger_easy_inequality` — **the easy direction of Cheeger's inequality**:
   any spectral gap is bounded by twice the conductance, `γ ≤ 2 · flowOut(S)/π(S)`.
   This is the cross-domain bridge geometry → spectral.
6. `mixing_diverges_at_zero_gap` — as the spectral gap → 0, the mixing-time bound
   diverges: the structural phase-transition result.
-/

import Mathlib

open Finset BigOperators

namespace SpectralChain

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A finite reversible Markov chain: a stationary distribution `π` and a
stochastic transition kernel `P` satisfying detailed balance. -/
structure ReversibleChain (V : Type*) [Fintype V] where
  /-- Stationary distribution. -/
  π : V → ℝ
  /-- Transition probabilities. -/
  P : V → V → ℝ
  π_pos : ∀ i, 0 < π i
  π_sum : ∑ i, π i = 1
  P_nonneg : ∀ i j, 0 ≤ P i j
  P_stoch : ∀ i, ∑ j, P i j = 1
  reversible : ∀ i j, π i * P i j = π j * P j i

namespace ReversibleChain

variable (C : ReversibleChain V)

/-- The (symmetric) edge weight / flow `w_ij = π_i P_ij`. -/
def weight (i j : V) : ℝ := C.π i * C.P i j

/-- Stationary mean of an observable `f`. -/
def mean (f : V → ℝ) : ℝ := ∑ i, C.π i * f i

/-- Variance of `f` against the stationary distribution. -/
def Var (f : V → ℝ) : ℝ := ∑ i, C.π i * (f i - C.mean f) ^ 2

/-- Dirichlet form (energy) of `f`. -/
noncomputable def DirichletForm (f : V → ℝ) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, C.weight i j * (f i - f j) ^ 2

/-- Total flow out of a set `S` across its boundary. -/
def flowOut (S : Finset V) : ℝ := ∑ i ∈ S, ∑ j ∈ Sᶜ, C.weight i j

/-- Stationary measure of a set. -/
def piSet (S : Finset V) : ℝ := ∑ i ∈ S, C.π i

/-- The `{0,1}` indicator observable of a set. -/
def indicator (S : Finset V) : V → ℝ := fun i => if i ∈ S then 1 else 0

/-! ### Basic weight / energy properties -/

/-
!-- Detailed balance `π_i P_ij = π_j P_ji` is exactly weight symmetry. -- !--
-/
omit [DecidableEq V] in
theorem weight_symm (i j : V) : C.weight i j = C.weight j i := by
  exact C.reversible i j

/-
!-- Each factor is nonnegative. -- !--
-/
omit [DecidableEq V] in
theorem weight_nonneg (i j : V) : 0 ≤ C.weight i j := by
  exact mul_nonneg ( le_of_lt ( C.π_pos i ) ) ( C.P_nonneg i j )

/-
!-- A sum of nonnegative squared terms with nonnegative weights. -- !--
-/
omit [DecidableEq V] in
theorem DirichletForm_nonneg (f : V → ℝ) : 0 ≤ C.DirichletForm f := by
  exact mul_nonneg ( by norm_num ) ( Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( C.weight_nonneg i j ) ( sq_nonneg _ ) )

/-! ### Variance identity (spectral graph theory) -/

/-
!-- Expand the double sum and use `∑ π = 1` to collapse to `∑ π f² - mean²`,
which equals the standard variance. -- !--
-/
omit [DecidableEq V] in
theorem Var_eq_double_sum (f : V → ℝ) :
    C.Var f = (1 / 2) * ∑ i, ∑ j, C.π i * C.π j * (f i - f j) ^ 2 := by
  -- Write everything through the centred observable `g i = f i - mean`.
  set m := C.mean f with hm
  have hsum : ∑ i, C.π i = 1 := C.π_sum
  -- The centred observable has zero mean.
  have hcenter : ∑ i, C.π i * (f i - m) = 0 := by
    have h1 : ∑ i, C.π i * (f i - m) = (∑ i, C.π i * f i) - m * ∑ i, C.π i := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [h1, hsum]; simp [hm, ReversibleChain.mean]
  -- Expand each summand into product form `(a i)·(b j)`.
  have expand : ∀ i j, C.π i * C.π j * (f i - f j) ^ 2
      = (C.π i * (f i - m) ^ 2) * C.π j + C.π i * (C.π j * (f j - m) ^ 2)
        - (2 * (C.π i * (f i - m))) * (C.π j * (f j - m)) := by
    intro i j; ring
  have key : ∑ i, ∑ j, C.π i * C.π j * (f i - f j) ^ 2
      = 2 * ∑ i, C.π i * (f i - m) ^ 2 := by
    simp_rw [expand, Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.sum_mul_sum]
    rw [hsum, hcenter]; ring
  rw [show C.Var f = ∑ i, C.π i * (f i - m) ^ 2 from rfl, key]; ring

/-
!-- Immediate from the double-sum identity: a sum of nonnegative terms. -- !--
-/
omit [DecidableEq V] in
theorem Var_nonneg (f : V → ℝ) : 0 ≤ C.Var f := by
  exact Finset.sum_nonneg fun i _ => mul_nonneg ( le_of_lt ( C.π_pos i ) ) ( sq_nonneg _ )

/-! ### Cut symmetry (geometry) -/

/-
!-- Swap the order of summation and use `weight_symm`: the flow out of `S`
equals the flow out of `Sᶜ`. -- !--
-/
theorem flowOut_symm (S : Finset V) : C.flowOut S = C.flowOut Sᶜ := by
  have h_symm : ∑ i ∈ S, ∑ j ∈ Sᶜ, C.weight i j = ∑ j ∈ Sᶜ, ∑ i ∈ S, C.weight j i := by
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => C.weight_symm _ _ );
  convert h_symm using 1;
  unfold ReversibleChain.flowOut; simp +decide [ Finset.compl_eq_univ_sdiff ] ;

/-! ### Indicator computations (the geometry ↔ spectral bridge) -/

/-
!-- `(1_S i - 1_S j)² = 1` exactly across the cut; splitting the double sum
over `S, Sᶜ` and using cut symmetry gives `2 · flowOut S`, halved. -- !--
-/
theorem DirichletForm_indicator (S : Finset V) :
    C.DirichletForm (indicator S) = C.flowOut S := by
      unfold ReversibleChain.DirichletForm ReversibleChain.flowOut;
      unfold indicator;
      have h_split : ∑ i, ∑ j, C.weight i j * (if i ∈ S then 1 else 0) * (if j ∉ S then 1 else 0) = ∑ i ∈ S, ∑ j ∈ Sᶜ, C.weight i j := by
        simp +decide [ Finset.sum_ite, Finset.filter_not ];
        simp +decide [ Finset.compl_eq_univ_sdiff ];
      have h_split2 : ∑ i, ∑ j, C.weight i j * (if i ∉ S then 1 else 0) * (if j ∈ S then 1 else 0) = ∑ i ∈ Sᶜ, ∑ j ∈ S, C.weight i j := by
        simp +decide [ Finset.sum_ite, Finset.filter_not ];
        rw [ ← Finset.sum_sdiff ( Finset.subset_univ S ) ] ; simp +decide [ Finset.compl_eq_univ_sdiff ] ;
      convert congr_arg ( fun x : ℝ => 1 / 2 * x ) ( congr_arg₂ ( · + · ) h_split h_split2 ) using 1 <;> ring_nf
      · rw [ ← add_mul, ← Finset.sum_add_distrib ] ; congr ; ext i ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext j ; split_ifs <;> ring;
      · rw [ ← Finset.sum_comm ] ; norm_num [ weight_symm ] ; ring;

/-
!-- The mean of `1_S` is `π(S)`, and the variance collapses to `π(S)(1-π(S))`. -- !--
-/
theorem Var_indicator (S : Finset V) :
    C.Var (indicator S) = C.piSet S * (1 - C.piSet S) := by
      unfold ReversibleChain.Var ReversibleChain.piSet ReversibleChain.mean indicator;
      simp +decide [ sub_sq, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
      simp +decide [ sub_add_eq_add_sub, Finset.sum_add_distrib, mul_add, mul_sub, Finset.mul_sum _ _ _ ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, C.π_sum ] ; ring

/-! ### A spectral gap certificate -/

/-- A certificate that the chain satisfies a Poincaré inequality with constant
`γ`: the spectral gap is at least `γ`. -/
structure SpectralGapCert (C : ReversibleChain V) where
  γ : ℝ
  γ_nonneg : 0 ≤ γ
  poincare : ∀ f : V → ℝ, γ * C.Var f ≤ C.DirichletForm f

/-! ### Cheeger's easy inequality (geometry → spectral, the key bridge) -/

/-
!-- Apply the Poincaré inequality to the indicator `1_S`. Then
`γ · π(S)(1-π(S)) ≤ flowOut S`. With `π(S) ≤ 1/2` we have `1-π(S) ≥ 1/2`,
so `γ · π(S)/2 ≤ flowOut S`, i.e. `γ ≤ 2 · flowOut(S)/π(S)`. -- !--
-/
theorem cheeger_easy_inequality (cert : SpectralGapCert C) (S : Finset V)
    (hpos : 0 < C.piSet S) (hhalf : C.piSet S ≤ 1 / 2) :
    cert.γ ≤ 2 * (C.flowOut S / C.piSet S) := by
      rw [ ← mul_div_assoc, le_div_iff₀ ];
      · have := cert.poincare ( SpectralChain.ReversibleChain.indicator S );
        rw [ Var_indicator, DirichletForm_indicator ] at this;
        nlinarith [ mul_le_mul_of_nonneg_left hhalf hpos.le, cert.γ_nonneg ];
      · exact hpos

/-! ### Mixing-time divergence (combinatorics: phase transition) -/

/-- Spectral-gap mixing-time bound `t_mix ≈ (1/γ) · log(n/ε)`. -/
noncomputable def mixingBound (γ ε n : ℝ) : ℝ := (1 / γ) * Real.log (n / ε)

/-
!-- For fixed positive `L := log(n/ε)`, the map `γ ↦ (1/γ)·L` is antitone on
positives: a larger spectral gap never increases the mixing bound. -- !--
-/
theorem mixingBound_antitone {ε n γ₁ γ₂ : ℝ} (hL : 0 ≤ Real.log (n / ε))
    (h1 : 0 < γ₁) (h12 : γ₁ ≤ γ₂) :
    mixingBound γ₂ ε n ≤ mixingBound γ₁ ε n := by
      exact mul_le_mul_of_nonneg_right ( one_div_le_one_div_of_le h1 h12 ) hL

/-
!-- Since `(1/γ)·L → ∞` as `γ → 0⁺` (with `L > 0`), for every target `T` there
is a positive gap whose mixing bound exceeds `T`: the phase-transition core. -- !--
-/
theorem mixing_diverges_at_zero_gap {ε n : ℝ} (hL : 0 < Real.log (n / ε))
    (T : ℝ) : ∃ γ : ℝ, 0 < γ ∧ γ < 1 ∧ T ≤ mixingBound γ ε n := by
      -- Let L = Real.log(n/ε) > 0. We want γ with 0 < γ < 1 and T ≤ (1/γ)*L.
      set L := Real.log (n / ε)
      have hL_pos : 0 < L := by
        exact hL
      use min (1 / 2) (L / (|T| + 1));
      refine' ⟨ _, _, _ ⟩ <;> norm_num [ mixingBound ];
      · positivity;
      · cases abs_cases T <;> nlinarith [ show 0 < Real.log ( n / ε ) from hL_pos, show 0 < min ( 1 / 2 ) ( Real.log ( n / ε ) / ( |T| + 1 ) ) from lt_min ( by norm_num ) ( div_pos hL_pos ( by linarith ) ), mul_div_cancel₀ ( Real.log ( n / ε ) ) ( by linarith : ( |T| + 1 ) ≠ 0 ), min_le_left ( 1 / 2 ) ( Real.log ( n / ε ) / ( |T| + 1 ) ), min_le_right ( 1 / 2 ) ( Real.log ( n / ε ) / ( |T| + 1 ) ), mul_inv_cancel₀ ( ne_of_gt ( show 0 < min ( 1 / 2 ) ( Real.log ( n / ε ) / ( |T| + 1 ) ) from lt_min ( by norm_num ) ( div_pos hL_pos ( by linarith ) ) ) ) ]

/-! ### A concrete instance: the uniform 2-state chain -/

/-- The uniform 2-state chain `π = (1/2, 1/2)`, `P ≡ 1/2`: the simplest nontrivial
reversible chain, used to exercise the framework with concrete numbers. -/
noncomputable def twoState : ReversibleChain (Fin 2) where
  π := fun _ => 1 / 2
  P := fun _ _ => 1 / 2
  π_pos := by intro i; norm_num
  π_sum := by rw [Fin.sum_univ_two]; norm_num
  P_nonneg := by intro i j; norm_num
  P_stoch := by intro i; rw [Fin.sum_univ_two]; norm_num
  reversible := by intro i j; norm_num

/-- Each directed edge of the uniform 2-state chain carries weight `1/4`. -/
example : twoState.weight 0 1 = 1 / 4 := by
  unfold ReversibleChain.weight twoState; norm_num

/-- Cut symmetry instantiated on the 2-state chain. -/
example (S : Finset (Fin 2)) : twoState.flowOut S = twoState.flowOut Sᶜ :=
  twoState.flowOut_symm S

/-! ### Generalization and boundary of the Cheeger bridge

* **Strengthening (open, hard direction).** The framework proves the *easy* half
  `γ ≤ 2·flowOut(S)/π(S)` of the discrete Cheeger inequality. The hard half
  `h²/2 ≤ γ`, where `h` is the conductance, would complete the equivalence; see
  `FUTURE_DIRECTIONS.md`, Direction 1. We record its shape as a `sorry`ed
  conjecture below.
* **Boundary.** The hypothesis `0 < π(S)` is essential: for `S = ∅` the quantity
  `flowOut(S)/π(S)` is `0/0`, so no nontrivial bound on `γ` can hold. -/

-- !-- Conjectural hard direction of Cheeger; left unproved (see FUTURE_DIRECTIONS.md). -- !--
theorem cheeger_hard_direction_conjecture (cert : SpectralGapCert C)
    (h : ℝ) (hh : 0 ≤ h)
    (hcond : ∀ S : Finset V, 0 < C.piSet S → C.piSet S ≤ 1 / 2 →
      h ≤ C.flowOut S / C.piSet S) :
    h ^ 2 / 2 ≤ cert.γ := by sorry

end ReversibleChain

end SpectralChain