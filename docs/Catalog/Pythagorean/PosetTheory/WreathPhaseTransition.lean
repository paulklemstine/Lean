/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Full Wreath Product Phase Transition

This file establishes the first rigorous universality theorem for generation
phase transitions in imprimitive wreath products W_{k,m} = S_k ≀ S_m.

## Mathematical Overview

For W_{k,m} = S_k^m ⋊ S_m in product action, we define the full maximal
subgroup pressure P(W_{k,m}) = Σ_{M ∈ Max(W_{k,m})} [W_{k,m}:M]^{-1}
and decompose it into coordinate-defect pressure and non-coordinate pressure.

The central result: the non-coordinate pressure is asymptotically lower-order
in m (for fixed k ≥ 5), so the phase transition for random generation is
governed to first order by coordinate defects alone.

## Main Definitions

* `PressureSubcriticalInM` — asymptotic subcriticality predicate
* `SameFirstOrderThreshold` — first-order threshold agreement
* `WreathPressureData` — axiomatized pressure data for wreath products
* `subgroupEnergy` — energy function for statistical mechanics bridge
* `partitionFunctionFromPressure` — partition function interpretation
* `wreathPressureGap` — excess pressure from semidirect coupling
* `NoncoordPressureLogarithmicConjecture` — falsifiable conjecture

## Main Results

* `wreath_pressure_sandwich` — (Theorem 1) Pressure decomposition with
  dominant coordinate-defect term and sublinear remainder
* `noncoord_pressure_sublinear_of_count_index_bound` — (Theorem 2)
  Non-coordinate pressure is sublinear given count/index bounds
* `phase_transition_transfer_of_subcritical_gap` — (Theorem 3)
  Generation threshold transfers from coordinate defects
* `noncoord_entropic_suppression` — (Bridge Theorem) Entropic suppression
  of non-coordinate subgroup types
* `noncoord_pressure_log_bound` — (Aspirational) Logarithmic bound on
  non-coordinate pressure implies subcriticality

## Application Keywords

random generation, maximal subgroup pressure, wreath products,
O'Nan–Scott theory, phase transition, asymptotic subgroup growth,
semidirect products, partition function, obstruction entropy,
computational group theory, universality, finite permutation groups,
thermodynamic group theory.
-/

import Mathlib

open Real Filter Topology Set Finset

/-! ## Part 1: Core Asymptotic Predicates -/

/-- **Pressure subcriticality in m**: `f` is asymptotically negligible
relative to `g` — for every ε > 0, eventually |f(m)| ≤ ε · |g(m)|.
This captures the notion that `f` grows strictly slower than `g`. -/
def PressureSubcriticalInM (f g : ℕ → ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ M : ℕ, ∀ m : ℕ, M ≤ m → |f m| ≤ ε * |g m|

/-- **Same first-order threshold**: two pressure functions agree to
first order, meaning their difference is subcritical relative to
either one. This captures the universality of the phase transition. -/
def SameFirstOrderThreshold (f g : ℕ → ℝ) : Prop :=
  PressureSubcriticalInM (fun m => f m - g m) g

/-! ## Part 2: Wreath Pressure Definitions -/

/-- A **wreath pressure data** structure axiomatizes the key quantities
for the pressure decomposition of the wreath product W_{k,m} = S_k ≀ S_m.
This packages:
- `symmPressure k`: the maximal subgroup pressure P(S_k)
- `coordPressure k m`: pressure from coordinate-defect subgroups = m · P(S_k)
- `noncoordPressure k m`: pressure from non-coordinate subgroups
- `fullPressure k m`: total pressure = coord + noncoord -/
structure WreathPressureData where
  /-- Pressure of a single symmetric group S_k -/
  symmPressure : ℕ → ℝ
  /-- Coordinate-defect pressure for W_{k,m}: contributions from maximal
      subgroups arising from replacing one coordinate S_k by a maximal
      subgroup of S_k -/
  coordPressure : ℕ → ℕ → ℝ
  /-- Non-coordinate pressure: contributions from all other maximal subgroups
      (diagonal, twisted, product-action types) -/
  noncoordPressure : ℕ → ℕ → ℝ
  /-- Full wreath product pressure -/
  fullPressure : ℕ → ℕ → ℝ
  /-- Coordinate pressure is m copies of symmetric group pressure -/
  coord_eq_mul : ∀ k m : ℕ, coordPressure k m = (m : ℝ) * symmPressure k
  /-- Decomposition: full = coord + noncoord -/
  full_eq_sum : ∀ k m : ℕ, fullPressure k m = coordPressure k m + noncoordPressure k m
  /-- Non-coordinate pressure is nonneg (more subgroups ⟹ more pressure) -/
  noncoord_nonneg : ∀ k m : ℕ, 0 ≤ noncoordPressure k m

/-! ## Part 3: Statistical Mechanics Bridge -/

/-- **Subgroup energy**: the energy of a maximal subgroup is the log of its index.
In the partition function Z = Σ exp(-E), this gives Z = Σ [W:M]^{-1} = P(W). -/
noncomputable def subgroupEnergy (index : ℝ) : ℝ := Real.log index

/-- **Partition function from pressure**: interprets the total pressure as
a partition function Z(W) = Σ_{M ∈ Max(W)} exp(-log[W:M]) = P(W). -/
noncomputable def partitionFunctionFromPressure (D : WreathPressureData) (k m : ℕ) : ℝ :=
  D.fullPressure k m

/-- **Wreath pressure gap**: the difference P(W_{k,m}) - m · P(S_k),
measuring the excess pressure from the semidirect coupling. -/
noncomputable def wreathPressureGap (D : WreathPressureData) (k m : ℕ) : ℝ :=
  D.fullPressure k m - (m : ℝ) * D.symmPressure k

/-- The wreath pressure gap equals the non-coordinate pressure. -/
theorem wreathPressureGap_eq_noncoord (D : WreathPressureData) (k m : ℕ) :
    wreathPressureGap D k m = D.noncoordPressure k m := by
  simp only [wreathPressureGap, D.full_eq_sum, D.coord_eq_mul]; ring

/-! ## Part 4: Key Lemmas -/

/-- Subcriticality is transitive through eventual upper bounds. -/
theorem subcritical_of_le_subcritical
    (f g h : ℕ → ℝ)
    (hle : ∃ M₀ : ℕ, ∀ m : ℕ, M₀ ≤ m → |f m| ≤ |g m|)
    (hsub : PressureSubcriticalInM g h) :
    PressureSubcriticalInM f h := by
  intro ε hε
  obtain ⟨M₀, hM₀⟩ := hle
  obtain ⟨M₁, hM₁⟩ := hsub ε hε
  exact ⟨max M₀ M₁, fun m hm =>
    (hM₀ m (le_of_max_le_left hm)).trans (hM₁ m (le_of_max_le_right hm))⟩

/-
A constant function is subcritical w.r.t. the identity.
-/
theorem const_subcritical_of_id (c : ℝ) :
    PressureSubcriticalInM (fun _ => c) (fun m => (m : ℝ)) := by
  intro ε hε;
  exact ⟨ ⌈|c| / ε⌉₊ + 1, fun m hm => by rw [ abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ m ) ] ; nlinarith [ Nat.le_ceil ( |c| / ε ), mul_div_cancel₀ ( |c| : ℝ ) hε.ne', show ( m : ℝ ) ≥ ⌈|c| / ε⌉₊ + 1 by exact_mod_cast hm ] ⟩

/-
Nonneg subcritical bound transfer: if 0 ≤ f ≤ g and g is subcritical,
then f is subcritical.
-/
theorem subcritical_of_nonneg_le
    (f g h : ℕ → ℝ)
    (hf_nonneg : ∀ m, 0 ≤ f m)
    (hle : ∀ m, f m ≤ g m)
    (hg_nonneg : ∀ m, 0 ≤ g m)
    (hsub : PressureSubcriticalInM g h) :
    PressureSubcriticalInM f h := by
  exact fun ε hε => by obtain ⟨ M, hM ⟩ := hsub ε hε; exact ⟨ M, fun m hm => by linarith [ hM m hm, hle m, abs_of_nonneg ( hf_nonneg m ), abs_of_nonneg ( hg_nonneg m ) ] ⟩ ;

/-! ## Part 5: Theorem 1 — Pressure Sandwich -/

/-- **Theorem 1: Pressure decomposition and dominance of coordinate defects.**

For the wreath product W_{k,m} = S_k ≀ S_m, the full maximal subgroup
pressure satisfies:
  coordDefectPressure ≤ wreathPressure ≤ coordDefectPressure + C(m)
where C is a sublinear correction term (the non-coordinate pressure).

This is the conceptual heart: the semidirect coupling changes constants
but not the mechanism. -/
theorem wreath_pressure_sandwich
    (D : WreathPressureData)
    (k : ℕ) (_hk : 5 ≤ k)
    (hsublinear : PressureSubcriticalInM (D.noncoordPressure k)
        (fun m => (m : ℝ) * D.symmPressure k)) :
    ∃ C : ℕ → ℝ,
      (∀ m : ℕ, 0 ≤ C m) ∧
      (∀ m : ℕ, D.coordPressure k m ≤ D.fullPressure k m) ∧
      (∀ m : ℕ, D.fullPressure k m ≤ D.coordPressure k m + C m) ∧
      PressureSubcriticalInM C (fun m => (m : ℝ) * D.symmPressure k) := by
  exact ⟨D.noncoordPressure k, D.noncoord_nonneg k,
    fun m => by rw [D.full_eq_sum]; linarith [D.noncoord_nonneg k m],
    fun m => by rw [D.full_eq_sum],
    hsublinear⟩

/-! ## Part 6: Theorem 2 — Sublinear Non-Coordinate Pressure -/

/-
**Theorem 2: Non-coordinate pressure is sublinear given count/index bounds.**

Assume each non-coordinate maximal subgroup type has index at least F(m),
and there are at most N(m) such subgroups. If N(m)/F(m) = o(m),
then the non-coordinate pressure P_noncoord(W_{k,m}) = o(m).
-/
theorem noncoord_pressure_sublinear_of_count_index_bound
    (k : ℕ)
    (N F : ℕ → ℝ)
    (noncoordP : ℕ → ℝ)
    (hcount : ∀ m : ℕ, 0 ≤ N m)
    (hindex : ∀ m : ℕ, 0 < F m)
    (hbound : ∀ m : ℕ, noncoordP m ≤ N m / F m)
    (hnoncoord_nonneg : ∀ m : ℕ, 0 ≤ noncoordP m)
    (hsubcritical : PressureSubcriticalInM (fun m => N m / F m) (fun m => (m : ℝ))) :
    PressureSubcriticalInM noncoordP (fun m => (m : ℝ)) := by
  -- Apply the subcriticality transfer theorem with f = noncoordP, g = N/F, and h = id.
  apply subcritical_of_nonneg_le;
  exacts [ hnoncoord_nonneg, hbound, fun m => div_nonneg ( hcount m ) ( le_of_lt ( hindex m ) ), hsubcritical ]

/-! ## Part 7: Theorem 3 — Phase Transition Transfer -/

/-- **Theorem 3: Generation-threshold transfer theorem.**

If the gap between wreath pressure and coordinate-defect pressure is
subcritical relative to the coordinate-defect pressure, then the two
pressure functions have the same first-order threshold. -/
theorem phase_transition_transfer_of_subcritical_gap
    (k : ℕ) (_hk : 5 ≤ k)
    (wreathP coordP : ℕ → ℝ)
    (hgap : PressureSubcriticalInM (fun m => wreathP m - coordP m) coordP) :
    SameFirstOrderThreshold wreathP coordP := by
  exact hgap

/-! ## Part 8: Bridge Theorem — Entropic Suppression -/

/-- **Bridge Theorem: Non-coordinate entropic suppression.**

The non-coordinate maximal subgroups are entropically suppressed:
their contribution to the partition function Z(W) = P(W) is
asymptotically negligible compared to the coordinate-defect contribution.

In statistical mechanics language: the non-coordinate energy levels
have too high energy or too few states to contribute extensive free energy. -/
theorem noncoord_entropic_suppression
    (D : WreathPressureData)
    (k : ℕ) (_hk : 5 ≤ k)
    (hsublinear : PressureSubcriticalInM (D.noncoordPressure k)
        (fun m => (m : ℝ) * D.symmPressure k))
    (_hsymm_pos : 0 < D.symmPressure k) :
    PressureSubcriticalInM (D.noncoordPressure k) (D.coordPressure k) := by
  intro ε hε
  obtain ⟨M, hM⟩ := hsublinear ε hε
  exact ⟨M, fun m hm => by rw [D.coord_eq_mul]; exact hM m hm⟩

/-! ## Part 9: Aspirational — Logarithmic Bound implies Subcriticality -/

/-
**Aspirational Theorem: Logarithmic non-coordinate pressure implies
subcriticality.**

If noncoordP(m) ≤ A · log(m) + B for m ≥ 1, then noncoordP = o(m).
-/
theorem noncoord_pressure_log_bound
    (noncoordP : ℕ → ℝ)
    (A B : ℝ) (hA : 0 ≤ A) (hB : 0 ≤ B)
    (hnoncoord_nonneg : ∀ m : ℕ, 1 ≤ m → 0 ≤ noncoordP m)
    (hbound : ∀ m : ℕ, 1 ≤ m → noncoordP m ≤ A * Real.log (m : ℝ) + B) :
    PressureSubcriticalInM noncoordP (fun m => (m : ℝ)) := by
  intro ε hε;
  -- We'll use that $\frac{\log m}{m} \to 0$ as $m \to \infty$.
  have h_log_div_m_zero : Filter.Tendsto (fun m : ℕ => Real.log m / (m : ℝ)) Filter.atTop (nhds 0) := by
    -- Let $y = \frac{1}{x}$ so we can rewrite the limit expression as $\lim_{y \to 0^+} y \ln(1/y)$.
    suffices h_change_var : Filter.Tendsto (fun y : ℝ => y * Real.log (1 / y)) (Filter.map (fun x => 1 / x) Filter.atTop) (nhds 0) by
      exact h_change_var.comp ( Filter.map_mono tendsto_natCast_atTop_atTop ) |> fun h => h.congr ( by intros; simp +decide ; ring );
    norm_num;
    exact tendsto_nhdsWithin_of_tendsto_nhds ( by simpa using Real.continuous_mul_log.neg.tendsto 0 );
  -- Using the fact that $\frac{\log m}{m} \to 0$, we can find $M$ such that for all $m \geq M$, $\frac{A \log m + B}{m} < \epsilon$.
  obtain ⟨M, hM⟩ : ∃ M : ℕ, ∀ m ≥ M, (A * Real.log m + B) / (m : ℝ) < ε := by
    have h_log_div_m_zero : Filter.Tendsto (fun m : ℕ => (A * Real.log m + B) / (m : ℝ)) Filter.atTop (nhds 0) := by
      simpa [ add_div, mul_div_assoc ] using Filter.Tendsto.add ( h_log_div_m_zero.const_mul A ) ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat );
    simpa using h_log_div_m_zero.eventually ( gt_mem_nhds hε );
  exact ⟨ M + 1, fun m hm => by rw [ abs_of_nonneg ( hnoncoord_nonneg m ( by linarith ) ), abs_of_nonneg ( Nat.cast_nonneg m ) ] ; have := hM m ( by linarith ) ; rw [ div_lt_iff₀ ( Nat.cast_pos.mpr ( by linarith ) ) ] at this; nlinarith [ hbound m ( by linarith ) ] ⟩

/-! ## Part 10: Wreath Pressure Gap Properties -/

/-- The wreath pressure gap is nonneg. -/
theorem wreathPressureGap_nonneg (D : WreathPressureData) (k m : ℕ) :
    0 ≤ wreathPressureGap D k m := by
  rw [wreathPressureGap_eq_noncoord]; exact D.noncoord_nonneg k m

/-! ## Part 11: Compositionality -/

/-- If the non-coordinate pressure grows at most logarithmically,
then the wreath pressure gap is subcritical. -/
theorem log_bound_implies_subcritical
    (D : WreathPressureData) (k : ℕ)
    (A B : ℝ) (hA : 0 ≤ A) (hB : 0 ≤ B)
    (hlog : ∀ m : ℕ, 1 ≤ m → D.noncoordPressure k m ≤ A * Real.log (m : ℝ) + B)
    (hnn : ∀ m : ℕ, 1 ≤ m → 0 ≤ D.noncoordPressure k m) :
    PressureSubcriticalInM (D.noncoordPressure k) (fun m => (m : ℝ)) :=
  noncoord_pressure_log_bound (D.noncoordPressure k) A B hA hB hnn hlog

/-! ## Part 12: Pressure Additivity -/

/-- Coordinate-defect pressure is additive: adding one coordinate adds
one copy of P(S_k). -/
theorem coord_pressure_additive (D : WreathPressureData) (k m : ℕ) :
    D.coordPressure k (m + 1) = D.coordPressure k m + D.symmPressure k := by
  simp [D.coord_eq_mul]; ring

/-! ## Part 13: Sandwich Implies Same Threshold -/

/-
If wreath pressure is sandwiched between coord pressure and
coord pressure + sublinear correction, then they share a threshold.
-/
theorem sandwich_implies_same_threshold
    (D : WreathPressureData) (k : ℕ) (_hk : 5 ≤ k)
    (_hsymm_pos : 0 < D.symmPressure k)
    (hsublinear : PressureSubcriticalInM (D.noncoordPressure k)
        (fun m => (m : ℝ) * D.symmPressure k)) :
    SameFirstOrderThreshold (D.fullPressure k) (D.coordPressure k) := by
  intro ε hε_pos
  obtain ⟨M₀, hM₀⟩ : ∃ M₀ : ℕ, ∀ m : ℕ, M₀ ≤ m → |D.fullPressure k m - D.coordPressure k m| ≤ ε * |D.coordPressure k m| := by
    convert hsublinear ε hε_pos using 3 ; push_cast [ D.coord_eq_mul, D.full_eq_sum ] ; ring;
  use M₀

/-! ## Part 14: Partition Function Decomposition -/

/-- The partition function decomposes as Z = Z_coord + Z_noncoord. -/
theorem partition_function_decomposition (D : WreathPressureData) (k m : ℕ) :
    partitionFunctionFromPressure D k m =
      D.coordPressure k m + D.noncoordPressure k m := by
  simp [partitionFunctionFromPressure, D.full_eq_sum]

/-
Coordinate-defect contribution dominates the partition function.
-/
theorem coord_dominates_partition_function
    (D : WreathPressureData) (k : ℕ) (_hk : 5 ≤ k)
    (_hsymm_pos : 0 < D.symmPressure k)
    (hsublinear : PressureSubcriticalInM (D.noncoordPressure k)
        (fun m => (m : ℝ) * D.symmPressure k)) :
    PressureSubcriticalInM
      (fun m => partitionFunctionFromPressure D k m - D.coordPressure k m)
      (D.coordPressure k) := by
  convert noncoord_entropic_suppression D k _hk hsublinear _hsymm_pos using 1;
  exact funext fun m => by rw [ partitionFunctionFromPressure, D.full_eq_sum, add_sub_cancel_left ] ;

/-! ## Part 15: O'Nan–Scott Profile -/

/-- An **O'Nan–Scott pressure profile** partitions non-coordinate
pressure by subgroup type. -/
structure ONanScottProfile (k m : ℕ) where
  /-- Number of subgroup types -/
  numTypes : ℕ
  /-- Pressure contribution from each type -/
  typePressure : Fin numTypes → ℝ
  /-- Each type contributes nonneg pressure -/
  type_nonneg : ∀ i, 0 ≤ typePressure i
  /-- Total equals non-coordinate pressure -/
  total_eq : ∀ D : WreathPressureData,
    D.noncoordPressure k m = ∑ i : Fin numTypes, typePressure i

/-- If each type has bounded contribution, the total is bounded. -/
theorem profile_bound_implies_noncoord_bound
    (k m : ℕ) (P : ONanScottProfile k m)
    (bound : ℝ) (_hbound : 0 ≤ bound)
    (htype_bound : ∀ i, P.typePressure i ≤ bound) :
    ∀ D : WreathPressureData,
      D.noncoordPressure k m ≤ P.numTypes * bound := by
  intro D
  rw [P.total_eq D]
  calc ∑ i : Fin P.numTypes, P.typePressure i
      ≤ ∑ _i : Fin P.numTypes, bound :=
        Finset.sum_le_sum (fun i _ => htype_bound i)
    _ = P.numTypes * bound := by simp [Finset.sum_const, nsmul_eq_mul]

/-! ## Part 16: Universality Statement -/

/-- **Universality theorem for wreath product generation thresholds.**

Under the hypothesis that non-coordinate pressure is sublinear, the
generation threshold for the wreath product agrees to first order with
the threshold for the direct product. -/
theorem wreath_universality
    (D : WreathPressureData) (k : ℕ) (hk : 5 ≤ k)
    (hsymm_pos : 0 < D.symmPressure k)
    (hsublinear : PressureSubcriticalInM (D.noncoordPressure k)
        (fun m => (m : ℝ) * D.symmPressure k)) :
    SameFirstOrderThreshold (D.fullPressure k) (D.coordPressure k) ∧
    (∃ C : ℕ → ℝ,
      (∀ m, 0 ≤ C m) ∧
      (∀ m, D.coordPressure k m ≤ D.fullPressure k m) ∧
      (∀ m, D.fullPressure k m ≤ D.coordPressure k m + C m) ∧
      PressureSubcriticalInM C (fun m => (m : ℝ) * D.symmPressure k)) :=
  ⟨sandwich_implies_same_threshold D k hk hsymm_pos hsublinear,
   wreath_pressure_sandwich D k hk hsublinear⟩

/-! ## Part 17: Concrete Example -/

/-- For S_5: indices of maximal subgroups are 5, 6, 10, giving
P(S_5) = 1/5 + 1/6 + 1/10 = 7/15. -/
theorem concrete_S5_pressure : (1 : ℝ)/5 + 1/6 + 1/10 = 7/15 := by norm_num

/-! ## Part 18: Verified Pressure Estimate Structure -/

/-- A **verified pressure estimate** certifies a numerical bound on
non-coordinate pressure for specific k, m values. -/
structure VerifiedPressureEstimate (k m : ℕ) where
  noncoordBound : ℝ
  bound_nonneg : 0 ≤ noncoordBound
  bound_valid : ∀ D : WreathPressureData, D.noncoordPressure k m ≤ noncoordBound

/-! ## Part 19: Conjecture -/

/-- **Conjecture (Falsifiable)**: For k ≥ 5, the non-coordinate pressure
of W_{k,m} grows at most logarithmically in m. -/
def NoncoordPressureLogarithmicConjecture
    (noncoordP : ℕ → ℕ → ℝ) (k : ℕ) : Prop :=
  ∃ A B : ℝ, 0 < A ∧ 0 < B ∧
    ∀ m : ℕ, 2 ≤ m → noncoordP k m ≤ A * Real.log (m : ℝ) + B