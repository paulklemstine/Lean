/-
# Cycle 4: the variational characterisation of extremal peelings

Cycles 1–3 characterise the extremisers of the peeling bound by an
*inequality* (all layers small), by a *symmetry* (invariance of the layer
contents under a transitive action) and by an explicit *geometric family*
(equal-measure dilations of a star-shaped body).  This file adds the fourth,
variational, description and ties it to the previous three.

Write `A = peelBudget P N` for the content removed in a window of `N` steps.
The **layer energy** of the window is `∑_{k<N} gap_k²`.  The exact identity

`∑_{k<N} gap_k² - A²/N = ∑_{k<N} (gap_k - A/N)²`   (`peel_energy_identity`)

immediately gives:

* `peel_energy_ge` — the energy is at least `A²/N` (a Cauchy–Schwarz bound
  obtained here by a square-completion, with no appeal to Cauchy–Schwarz);
* `peel_energy_eq_iff_extremal` — equality holds exactly for the extremisers
  of the stopping-time bound, giving a second, independent proof of the
  rigidity theorem `peel_extremal_tfae`;
* `exists_peel_large_gap` — the dual pigeonhole: every window also contains a
  step whose layer is at least the average, so `min gap ≤ rate ≤ max gap`
  with a double equality precisely in the extremal case.

The geometric corollary `shell_energy_minimal` states that among all ball
peelings of `B(0,R) ⊆ ℝ^d` into `N` shells, the equal-volume shells of
`shellRadius` minimise the sum of squared shell volumes.

## Lab notes

`N = 4`, `A = 1`.  Uniform gaps `(¼,¼,¼,¼)`: energy `4·1/16 = 0.25 = A²/N`.
Front-loaded gaps `(1,0,0,0)`: energy `1`, excess `0.75`, which equals
`∑ (gap - ¼)² = (3/4)² + 3·(1/4)² = 0.5625 + 0.1875 = 0.75` — the identity
checks out numerically, and the excess is exactly the variance of the layer
distribution.
-/
import Geometry.PeelDilationBodies

namespace Catalog.Geometry.Peel

open Finset MeasureTheory

variable (P : PeelProfile) {N : ℕ}

/-! ## The energy identity -/

/-- The layer energy of a window of `N` peeling steps. -/
def peelEnergy (P : PeelProfile) (N : ℕ) : ℝ := ∑ k ∈ range N, (peelGap P k) ^ 2

/-- **Energy identity.**  The excess of the layer energy over `A²/N` is exactly
the total squared deviation of the layers from the average. -/
theorem peel_energy_identity (hN : 0 < N) :
    peelEnergy P N - (peelBudget P N) ^ 2 / N
      = ∑ k ∈ range N, (peelGap P k - peelRate P N) ^ 2 := by
  have hNR : (0 : ℝ) < N := by exact_mod_cast hN
  have hexp : ∑ k ∈ range N, (peelGap P k - peelRate P N) ^ 2
      = (∑ k ∈ range N, (peelGap P k) ^ 2)
        - 2 * peelRate P N * (∑ k ∈ range N, peelGap P k)
        + (N : ℝ) * (peelRate P N) ^ 2 := by
    rw [Finset.sum_congr rfl (fun k _ => by ring :
      ∀ k ∈ range N, (peelGap P k - peelRate P N) ^ 2
        = (peelGap P k) ^ 2 - 2 * peelRate P N * peelGap P k + (peelRate P N) ^ 2)]
    rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, Finset.sum_const,
      Finset.card_range, nsmul_eq_mul]
  rw [hexp, sum_peelGap, peelEnergy, peelRate]
  field_simp
  ring

/-- **The energy is minimised by the extremal peelings.**  Every window of `N`
steps has layer energy at least `A²/N`. -/
theorem peel_energy_ge (hN : 0 < N) :
    (peelBudget P N) ^ 2 / N ≤ peelEnergy P N := by
  have h := peel_energy_identity P hN
  have hnn : 0 ≤ ∑ k ∈ range N, (peelGap P k - peelRate P N) ^ 2 :=
    Finset.sum_nonneg fun k _ => sq_nonneg _
  linarith

/-- **Equality case.**  The layer energy equals `A²/N` exactly when the peeling
saturates the stopping-time bound at every step; by `peel_extremal_tfae` this
is a second, independent route to the rigidity theorem. -/
theorem peel_energy_eq_iff_extremal (hN : 0 < N) :
    peelEnergy P N = (peelBudget P N) ^ 2 / N ↔ ∀ k < N, peelGap P k = peelRate P N := by
  have hid := peel_energy_identity P hN
  constructor
  · intro heq k hk
    have hzero : ∑ j ∈ range N, (peelGap P j - peelRate P N) ^ 2 = 0 := by linarith
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg _)).1 hzero k
      (Finset.mem_range.2 hk)
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
    linarith
  · intro h
    have hzero : ∑ k ∈ range N, (peelGap P k - peelRate P N) ^ 2 = 0 := by
      refine Finset.sum_eq_zero fun k hk => ?_
      rw [h k (Finset.mem_range.1 hk)]
      ring
    linarith

/-! ## The dual pigeonhole -/

/-- **Dual pigeonhole.**  Every window also contains a step whose layer is at
least the average rate: good stopping times come with bad ones. -/
theorem exists_peel_large_gap (hN : 0 < N) :
    ∃ k < N, peelRate P N ≤ peelGap P k := by
  have hsum : ∑ _k ∈ range N, peelRate P N ≤ ∑ k ∈ range N, peelGap P k := by
    rw [sum_peelGap, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    exact (nsmul_peelRate P).le
  obtain ⟨k, hk, hle⟩ :=
    Finset.exists_le_of_sum_le (s := range N) (Finset.nonempty_range_iff.2 hN.ne') hsum
  exact ⟨k, Finset.mem_range.1 hk, hle⟩

/-- Sandwich: the average rate is always squeezed between some layer content
below and some layer content above, and the extremal peelings are exactly
those where the squeeze is an equality at every step. -/
theorem peel_rate_sandwich (hN : 0 < N) :
    (∃ k < N, peelGap P k ≤ peelRate P N) ∧ (∃ k < N, peelRate P N ≤ peelGap P k) :=
  ⟨exists_peel_stopping_time P hN, exists_peel_large_gap P hN⟩

/-! ## Geometric corollary: equal-volume shells minimise the shell energy -/

/-- **Minimality of the equal-volume shell peeling.**  Among all nested ball
peelings of `B(0,R) ⊆ ℝ^d` shrinking to a point in `N` steps, the equal-volume
shells minimise the sum of squared shell volumes, the minimum being
`vol B(0,R)² / N`. -/
theorem shell_energy_minimal (d N : ℕ) (hd : 0 < d) (hN : 0 < N) {R : ℝ} (hR : 0 ≤ R)
    (r : ℕ → ℝ) (hanti : Antitone r) (hnn : ∀ k, 0 ≤ r k) (h0 : r 0 = R) (hlast : r N = 0) :
    (ballVol d R) ^ 2 / N
      ≤ ∑ k ∈ range N, (ballVol d (r k) - ballVol d (r (k + 1))) ^ 2 ∧
    ∑ k ∈ range N,
        (ballVol d (shellRadius R d N k) - ballVol d (shellRadius R d N (k + 1))) ^ 2
      = (ballVol d R) ^ 2 / N := by
  set P := radiusProfile d hd r hanti hnn with hP
  have hsize : ∀ j, P.size j = ballVol d (r j) := fun _ => rfl
  have hbudget : peelBudget P N = ballVol d R := by simp [peelBudget, hsize, h0, hlast]
  constructor
  · have h := peel_energy_ge P hN
    rw [hbudget] at h
    simpa [peelEnergy, peelGap, hsize] using h
  · have hgap : ∀ k ∈ range N,
        (ballVol d (shellRadius R d N k) - ballVol d (shellRadius R d N (k + 1))) ^ 2
          = (ballVol d R / N) ^ 2 := by
      intro k hk
      have hk' : k < N := Finset.mem_range.1 hk
      have := shellPeel_gap d N k hN hk' (R := R)
      rw [← shellPeel_size d N k hd hR, ← shellPeel_size d N (k + 1) hd hR]
      rw [show (shellPeel d R N).size k - (shellPeel d R N).size (k + 1)
        = peelGap (shellPeel d R N) k from rfl, this]
    rw [Finset.sum_congr rfl hgap, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
    have hNR : (0 : ℝ) < N := by exact_mod_cast hN
    field_simp

end Catalog.Geometry.Peel