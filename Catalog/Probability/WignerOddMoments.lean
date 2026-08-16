/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Vanishing of the odd spectral moments, and moment matching up to order four

The semicircle distribution has vanishing odd moments (`semicircleMoment_odd`).
Here we prove the matching statement on the matrix side, for an arbitrary centred,
unit-variance entry law: the first and third expected spectral moments of a Wigner
matrix vanish **exactly**, at every finite dimension `N`.

* the first moment vanishes deterministically, because the diagonal of the model
  is identically zero;
* the third moment vanishes because every closed 3-walk `i → j → k → i` on
  distinct vertices traverses three *distinct* edges, so some edge is used exactly
  once and centredness kills the expectation.  (A closed 3-walk can never pair up
  its edges: this is the parity obstruction behind the vanishing of odd moments.)

Combining these with the second- and fourth-moment computations of the earlier
files, we obtain the capstone of this development:

  for every `m ≤ 4`,
  `E [ (1/N) tr ((W/√N)^m) ] → ∫ x^m dσ(x)`,

where `σ` is the semicircle law on `[-2, 2]`.  Thus the expected empirical spectral
distribution of a general Wigner ensemble matches the semicircle law on all moments
up to order four, universally in the entry distribution.
-/
import Probability.WignerSecondMomentConcentration

open Matrix BigOperators Finset Filter Topology
open RademacherWigner (edgeOf edgeOf_comm edgeOf_eq_iff)

namespace WignerUniversal

variable {S : Type*} [Fintype S] {N : ℕ}

/-! ### The first moment -/

/-- The model has zero diagonal, hence zero trace, for every realisation. -/
theorem trace_GW (L : EntryLaw S) (ω : Conf N S) : (GW L ω).trace = 0 := by
  simp [Matrix.trace, Matrix.diag, gentry]

/-! ### Expansion of the third trace power -/

theorem trace_pow_three (M : Matrix (Fin N) (Fin N) ℝ) :
    (M ^ 3).trace = ∑ i, ∑ j, ∑ k, M i j * M j k * M k i := by
  rw [show (3 : ℕ) = 2 + 1 from rfl, pow_succ, pow_two]
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Finset.sum_mul]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Finset.sum_comm]

/-- **Parity obstruction for triangles.**  In a closed 3-walk on three distinct
vertices the first edge `{i,j}` differs from the two other edges traversed. -/
theorem edges3_ne_first {i j k : Fin N} (hij : i ≠ j) (hjk : j ≠ k) (hki : k ≠ i) :
    edgeOf j k ≠ edgeOf i j ∧ edgeOf k i ≠ edgeOf i j := by
  constructor
  · intro h
    rcases (edgeOf_eq_iff hjk hij).1 h with ⟨h1, -⟩ | ⟨-, h2⟩
    · exact hij h1.symm
    · exact hki h2
  · intro h
    rcases (edgeOf_eq_iff hki hij).1 h with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact hki h1
    · exact hjk h1.symm

/-- Every nondegenerate closed 3-walk has zero expectation. -/
theorem gexpect_walk3_zero (L : EntryLaw S) {i j k : Fin N} (hij : i ≠ j) (hjk : j ≠ k)
    (hki : k ≠ i) :
    gexpect L (fun ω : Conf N S =>
      gentry L ω i j * gentry L ω j k * gentry L ω k i) = 0 := by
  obtain ⟨e2, e3⟩ := edges3_ne_first hij hjk hki
  have h1 : ∀ ω : Conf N S,
      gentry L ω i j * gentry L ω j k * gentry L ω k i =
        ∏ e, L.v (ω e) ^ ([edgeOf i j, edgeOf j k, edgeOf k i].count e) := by
    intro ω
    rw [gentry_of_ne L ω hij, gentry_of_ne L ω hjk, gentry_of_ne L ω hki]
    have h := prod_walk (fun e => L.v (ω e)) [edgeOf i j, edgeOf j k, edgeOf k i]
    simp only [List.map_cons, List.map_nil, List.prod_cons, List.prod_nil, mul_one] at h
    rw [← mul_assoc] at h
    exact h
  simp only [h1]
  rw [gexpect_prod L (fun e s => L.v s ^ ([edgeOf i j, edgeOf j k, edgeOf k i].count e))]
  refine Finset.prod_eq_zero (Finset.mem_univ (edgeOf i j)) ?_
  have hcount : [edgeOf i j, edgeOf j k, edgeOf k i].count (edgeOf i j) = 1 := by
    simp [e2, e3]
  simp [hcount, L.mean]

/-- **The third trace moment vanishes exactly**, at every finite `N`, for every
centred entry law. -/
theorem gexpect_trace_three (L : EntryLaw S) (N : ℕ) :
    gexpect L (fun ω : Conf N S => ((GW L ω) ^ 3).trace) = 0 := by
  have h1 : ∀ ω : Conf N S, ((GW L ω) ^ 3).trace =
      ∑ i : Fin N, ∑ j : Fin N, ∑ k : Fin N,
        gentry L ω i j * gentry L ω j k * gentry L ω k i := fun ω =>
    trace_pow_three (GW L ω)
  simp only [h1]
  rw [gexpect_sum]
  refine Finset.sum_eq_zero fun i _ => ?_
  rw [gexpect_sum]
  refine Finset.sum_eq_zero fun j _ => ?_
  rw [gexpect_sum]
  refine Finset.sum_eq_zero fun k _ => ?_
  by_cases hij : i = j
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k i = 0 := by
      intro ω; simp [gentry, hij]
    simp only [h0]
    exact gexpect_zero L
  by_cases hjk : j = k
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k i = 0 := by
      intro ω; simp [gentry, hjk]
    simp only [h0]
    exact gexpect_zero L
  by_cases hki : k = i
  · have h0 : ∀ ω : Conf N S,
        gentry L ω i j * gentry L ω j k * gentry L ω k i = 0 := by
      intro ω; simp [gentry, hki]
    simp only [h0]
    exact gexpect_zero L
  exact gexpect_walk3_zero L hij hjk hki

/-! ### The first and third normalised spectral moments -/

theorem gexpect_normalizedMoment_one (L : EntryLaw S) (N : ℕ) :
    gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 1) = 0 := by
  have hrw : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) 1 = 0 := by
    intro ω
    rw [WignerBridge.normalizedMoment_eq]
    simp [trace_GW]
  simp only [hrw]
  exact gexpect_zero L

theorem gexpect_normalizedMoment_three (L : EntryLaw S) (N : ℕ) :
    gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 3) = 0 := by
  have hrw : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) 3 =
      (1 / (N : ℝ) * (Real.sqrt (N : ℝ))⁻¹ ^ 3) * ((GW L ω) ^ 3).trace := by
    intro ω
    rw [WignerBridge.normalizedMoment_eq, RademacherWigner.card_fin_config]
  simp only [hrw]
  rw [gexpect_const_mul, gexpect_trace_three, mul_zero]

theorem gexpect_normalizedMoment_zero (L : EntryLaw S) (N : ℕ) (hN : 0 < N) :
    gexpect L (fun ω : Conf N S => WignerBridge.normalizedMoment (GW L ω) 0) = 1 := by
  have hNR : (N : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hN.ne'
  have hrw : ∀ ω : Conf N S, WignerBridge.normalizedMoment (GW L ω) 0 = 1 := by
    intro ω
    rw [WignerBridge.normalizedMoment_eq, RademacherWigner.card_fin_config, pow_zero, pow_zero,
      Matrix.trace_one, RademacherWigner.card_fin_config]
    field_simp
  simp only [hrw]
  simpa using gexpect_const (N := N) L 1

/-! ### Moment matching up to order four -/

/-- **Capstone: universal moment matching up to order four.**  For every centred,
unit-variance entry law and every `m ≤ 4`, the expected `m`-th moment of the
empirical spectral distribution of `W/√N` converges to the `m`-th moment of the
semicircle law on `[-2,2]`.  The limit is independent of the entry distribution. -/
theorem tendsto_gexpect_normalizedMoment_of_le_four (L : EntryLaw S) {m : ℕ} (hm : m ≤ 4) :
    Tendsto (fun N : ℕ => gexpect L (fun ω : Conf N S =>
        WignerBridge.normalizedMoment (GW L ω) m)) atTop
      (𝓝 (WignerSemicircle.semicircleMoment m)) := by
  interval_cases m
  · -- m = 0
    rw [WignerSemicircle.semicircleMoment_zero]
    refine (tendsto_const_nhds (x := (1 : ℝ))).congr' ?_
    filter_upwards [eventually_gt_atTop 0] with N hN
    exact (gexpect_normalizedMoment_zero L N hN).symm
  · -- m = 1
    have h1 : WignerSemicircle.semicircleMoment 1 = 0 := by
      simpa using WignerSemicircle.semicircleMoment_odd 0
    rw [h1]
    simpa only [gexpect_normalizedMoment_one L] using
      (tendsto_const_nhds (x := (0 : ℝ)) (f := atTop (α := ℕ)))
  · -- m = 2
    rw [WignerSemicircle.semicircleMoment_two]
    have hlim : Tendsto (fun N : ℕ => 1 - 1 / (N : ℝ)) atTop (𝓝 1) := by
      have h : Tendsto (fun N : ℕ => (1 : ℝ) / (N : ℝ)) atTop (𝓝 0) :=
        tendsto_one_div_atTop_nhds_zero_nat
      simpa using (tendsto_const_nhds (x := (1 : ℝ))).sub h
    refine hlim.congr' ?_
    filter_upwards [eventually_gt_atTop 0] with N hN
    exact (gexpect_normalizedMoment_two L N hN).symm
  · -- m = 3
    have h3 : WignerSemicircle.semicircleMoment 3 = 0 := by
      simpa using WignerSemicircle.semicircleMoment_odd 1
    rw [h3]
    simpa only [gexpect_normalizedMoment_three L] using
      (tendsto_const_nhds (x := (0 : ℝ)) (f := atTop (α := ℕ)))
  · -- m = 4
    exact tendsto_gexpect_normalizedMoment_four L

end WignerUniversal