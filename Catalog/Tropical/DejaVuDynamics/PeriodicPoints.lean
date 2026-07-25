/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Bridges.TropicalHecke.MinPlusAlgebra

/-!
# Periodic points in cognitive and tropical dynamics

A recurrence event is represented by a positive return time of a state under a
self-map.  The results below separate consequences of recurrence that hold for
all dynamical systems from claims requiring substantial interval-dynamical
hypotheses.  They also connect recurrence to min-plus spectral dynamics.

The central caution is that continuity on an interval does not make periodic
points dense: the continuous contraction `x ↦ x / 2` has only one periodic
point.  Thus density and Li–Yorke conclusions cannot be inferred from
continuity alone, and empirical incidence is not a density of points without a
specified probability measure and observation model.
-/

noncomputable section

open Function Set Matrix Finset

namespace DejaVuDynamics

/-- A state returns after the positive time `n`. -/
def IsPeriodicState {S : Type*} (f : S → S) (s : S) : Prop :=
  ∃ n : ℕ, 0 < n ∧ (f^[n]) s = s

/-- A state has exact period `p`. -/
def HasExactPeriod {S : Type*} (f : S → S) (s : S) (p : ℕ) : Prop :=
  0 < p ∧ (f^[p]) s = s ∧
    ∀ q : ℕ, 0 < q → q < p → (f^[q]) s ≠ s

/-
Every positive multiple of a return time is again a return time.
-/
theorem periodic_return_multiples {S : Type*} (f : S → S) (s : S) (p : ℕ)
    (hp : 0 < p) (hreturn : (f^[p]) s = s) (k : ℕ) (hk : 0 < k) :
    0 < p * k ∧ (f^[p * k]) s = s := by
  induction hk <;> simp_all +decide [ Nat.mul_succ, Function.iterate_add_apply ]

/-
Periodicity is transported by a semiconjugacy.
-/
theorem periodicState_of_semiconj {S T : Type*} {f : S → S} {g : T → T}
    (h : S → T) (hsemi : Semiconj h f g) {s : S}
    (hs : IsPeriodicState f s) : IsPeriodicState g (h s) := by
  obtain ⟨ n, hn ⟩ := hs;
  exact ⟨ n, hn.1, by rw [ ← hsemi.iterate_right n, hn.2 ] ⟩

/-
Exact period three produces three pairwise distinct states in the orbit.
-/
theorem exact_period_three_distinct {S : Type*} (f : S → S) (s : S)
    (h : HasExactPeriod f s 3) :
    s ≠ f s ∧ f s ≠ f (f s) ∧ f (f s) ≠ s := by
  obtain ⟨ hp₁, hp₂, hp₃ ⟩ := h;
  refine' ⟨ _, _, _ ⟩ <;> contrapose! hp₃;
  · exact ⟨ 1, by decide, by decide, hp₃.symm ⟩;
  · exact ⟨ 1, by decide, by decide, by simpa [ ← hp₃ ] using hp₂ ⟩;
  · exact ⟨ 2, by decide, by decide, hp₃ ⟩

/-- The logistic family. -/
def logistic (r x : ℝ) : ℝ := r * x * (1 - x)

/-
Parameters in `[0,4]` make the logistic map a self-map of `[0,1]`.
-/
theorem logistic_maps_unit_interval {r x : ℝ}
    (hr0 : 0 ≤ r) (hr4 : r ≤ 4) (hx : x ∈ Icc (0 : ℝ) 1) :
    logistic r x ∈ Icc (0 : ℝ) 1 := by
  exact ⟨ by exact mul_nonneg ( mul_nonneg hr0 hx.1 ) ( sub_nonneg.2 hx.2 ), by exact le_trans ( mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_right hr4 hx.1 ) ( sub_nonneg.2 hx.2 ) ) ( by nlinarith [ sq_nonneg ( x - 1 / 2 ) ] ) ⟩

/-
For `x ↦ x/2`, every positive return has to be the zero state.
-/
theorem half_map_periodic_iff_zero (x : ℝ) :
    IsPeriodicState (fun y : ℝ => y / 2) x ↔ x = 0 := by
  constructor;
  · rintro ⟨ n, hn, hx ⟩;
    norm_num [ div_eq_mul_inv, Function.iterate_mul, Function.iterate_fixed ] at hx;
    by_cases hx' : x = 0 <;> simp_all +decide;
    exact absurd hx ( ne_of_gt ( one_lt_pow₀ ( by norm_num ) hn.ne' ) );
  · exact fun hx => ⟨ 1, by norm_num, by norm_num [ hx ] ⟩

/-
Continuity on an interval alone does not force dense periodic points.
-/
theorem continuous_interval_periodic_points_not_dense :
    Continuous (fun x : ℝ => x / 2) ∧
      ¬ Dense {x : ℝ | IsPeriodicState (fun y : ℝ => y / 2) x} := by
  refine' ⟨ continuous_id.div_const _, _ ⟩;
  -- The set of periodic points of $f(x) = x/2$ is $\{0\}$.
  have h_periodic : {x : ℝ | IsPeriodicState (fun y => y / 2) x} = {0} := by
    ext x; simp [half_map_periodic_iff_zero];
  exact fun h => absurd ( h.exists_gt 1 ) ( by norm_num [ h_periodic ] )

/-
A zero tropical eigenvalue is precisely a fixed min-plus state.
-/
theorem zero_tropical_eigenpair_iff_fixed {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ) :
    IsTropicalEigenpair A 0 v ↔ tropMatVecMul A v = v := by
  constructor <;> intro h <;> simp_all +decide [ IsTropicalEigenpair ];
  exact funext h

/-
A tropical eigenstate evolves by linear drift along the all-ones direction.
-/
theorem tropical_eigenpair_iterate {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (lam : ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair A lam v) :
    ∀ k : ℕ, ((tropMatVecMul A)^[k]) v = fun i => v i + (k : ℝ) * lam := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply', ih]
      funext i
      rw [tropMatVecMul_shift, heig i]
      push_cast
      ring

/-
A zero tropical eigenstate is recurrent at every positive time.
-/
theorem zero_tropical_eigenpair_is_periodic {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (v : Fin n → ℝ)
    (heig : IsTropicalEigenpair A 0 v) :
    IsPeriodicState (tropMatVecMul A) v := by
  use 1;
  convert zero_tropical_eigenpair_iff_fixed A v |>.1 heig using 1;
  norm_num

-- !-- Lab Notes -- !--
-- Hypothesis: Period-three recurrence should force a concrete three-state cycle,
-- while tropical eigenstates should turn recurrence into spectral information.
-- Experiment: Iteration identities, logistic interval bounds, and min-plus shift
-- equivariance were tested against exact symbolic statements.  The universal
-- density claim was challenged with the contraction x ↦ x/2.
-- Analysis: Exact period three indeed supplies three distinct orbit states, and
-- zero tropical eigenvalue is exactly fixed-state recurrence.  Continuity alone
-- is insufficient for density: contraction collapses all periodicity to zero.
-- Critique: No claim equates empirical lifetime incidence with topological or
-- natural density.  Sharkovsky and Li–Yorke conclusions require interval maps
-- and hypotheses substantially stronger than continuity; they are not asserted
-- here.  The parameter 3.83 is not inferred from a 70% statistic.
-- Synthesis: The surviving framework combines functorial recurrence, an exact
-- period-three certificate, a rigorous logistic invariant interval, a sharp
-- counterexample to naive density, and a tropical spectral recurrence theorem.
-- !-- End Lab Notes -- !--

end DejaVuDynamics