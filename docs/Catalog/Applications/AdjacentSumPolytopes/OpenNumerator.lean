import Applications.AdjacentSumPolytopes.NewtonJacobi
import Applications.AdjacentSumPolytopes.OpenClosedForm

/-!
# The numerator of the open series

`NewtonJacobi.lean` identified the numerator of the *cyclic* series as `-p'`, where
`p = det(I - X·adjMat s)`.  The open series has the same denominator `p` (proved in
`Recurrence.lean`) but a genuinely different numerator: the open counts are weighted
sums of the cosecant eigenvalues, with the discrete-sine weights `cot²(θ_t/2)/(2s+3)`
computed in `OpenClosedForm.lean`, rather than unweighted traces.

Feeding those weights into the *weighted* Newton identity `AdjSum.newton_weighted` gives a
closed formula for the open numerator as a partial-fraction (Lagrange) sum.

## Main results

* `AdjSum.openWeight` : the discrete-sine weight `cot²(θ_t/2)/(2s+3)`.
* `AdjSum.openSeries_map_eq_mk` : over `ℝ` the open series is the weighted power-sum
  series of the cosecant spectrum.
* `AdjSum.openSeries_numerator` : **the open numerator formula**
  `openSeries s · charDenom s = ∑_t (cot²(θ_t/2)/(2s+3)) ∏_{u ≠ t} (1 - λ_u X)`.
* `AdjSum.openNumerator_natDegree_le` : that numerator has degree at most `s`, matching
  the abstract bound of `Recurrence.lean`.

-- !-- Lab Notes -- !--
* **Experiment.** `s = 1`: the weights are `cot²(π/10)/5 = 1.8944` and
  `cot²(3π/10)/5 = 0.1056`, the eigenvalues `λ_0 = 1/(2 sin(π/10)) = 1.6180`,
  `λ_1 = -1/(2 sin(3π/10)) = -0.6180`, and the formula gives numerator
  `1.8944(1 + 0.6180X) + 0.1056(1 - 1.6180X) = 2 + X`, which is indeed
  `openSeries 1 · (1 - X - X²)` for the counts `2, 3, 5, 8, …`.
* **Analysis.** The contrast with the cyclic case is structural: the cyclic weights are
  all `1` (a trace), which makes the numerator collapse to the derivative `-p'`; the open
  weights are `⟨1, v_t⟩²`-type quantities, which do not collapse.  Both numerators live
  over the same denominator, so the shared-denominator theorem is refined here into a
  statement about the two *different* numerators.
* **Critique.** The formula is stated over `ℝ` because the weights are transcendental
  individually; only their combination is rational.  The rationality of the total is not
  re-proved here — it is already known from `Recurrence.lean` — so the two statements are
  complementary rather than redundant.
-/

namespace AdjSum

open Finset

/-- The discrete-sine weight attached to the `t`-th cosecant eigenvalue. -/
noncomputable def openWeight (s : ℕ) (t : ℕ) : ℝ :=
  (Real.cos (secAngle s t / 2) / Real.sin (secAngle s t / 2)) ^ 2 / (2 * (s : ℝ) + 3)

/-- The open counts are the weighted power sums of the cosecant spectrum. -/
theorem card_openSet_eq_weighted_sum (s d : ℕ) :
    ((openSet s d).card : ℝ)
      = ∑ t : Fin (s + 1), openWeight s (t : ℕ) * (secEigval s (t : ℕ)) ^ d := by
  rw [card_openSet_eq_sum s d, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun t _ => ?_)
  rw [openWeight]
  ring

/-- Over `ℝ` the open generating function is the weighted power-sum series. -/
theorem openSeries_map_eq_mk (s : ℕ) :
    PowerSeries.map (Int.castRingHom ℝ) (openSeries s)
      = PowerSeries.mk
          (fun m => ∑ t : Fin (s + 1), openWeight s (t : ℕ) * (secEigval s (t : ℕ)) ^ m) := by
  ext n
  rw [PowerSeries.coeff_map, openSeries, PowerSeries.coeff_mk, PowerSeries.coeff_mk, openCount]
  simpa using card_openSet_eq_weighted_sum s n

/-- **The open numerator formula.**  The numerator of the open Ehrhart-type series is the
partial-fraction sum of the discrete-sine weights over the cosecant spectrum. -/
theorem openSeries_numerator (s : ℕ) :
    PowerSeries.map (Int.castRingHom ℝ) (openSeries s * charDenom s)
      = ((∑ t : Fin (s + 1), Polynomial.C (openWeight s (t : ℕ))
            * rootPoly (fun u : Fin (s + 1) => secEigval s (u : ℕ)) (Finset.univ.erase t) :
          Polynomial ℝ) : PowerSeries ℝ) := by
  rw [map_mul, openSeries_map_eq_mk, charDenom_eq_coe, ← Polynomial.polynomial_map_coe,
    charDenomPolyR_eq_rootPoly, mul_comm]
  exact newton_weighted (fun u : Fin (s + 1) => secEigval s (u : ℕ))
    (fun u : Fin (s + 1) => openWeight s (u : ℕ)) Finset.univ

/-- Each partial-fraction summand, hence the whole open numerator, has degree at most
`s`. -/
theorem openNumerator_natDegree_le (s : ℕ) :
    (∑ t : Fin (s + 1), Polynomial.C (openWeight s (t : ℕ))
        * rootPoly (fun u : Fin (s + 1) => secEigval s (u : ℕ))
            (Finset.univ.erase t)).natDegree ≤ s := by
  refine Polynomial.natDegree_sum_le_of_forall_le _ _ (fun t _ => ?_)
  refine le_trans Polynomial.natDegree_mul_le ?_
  rw [Polynomial.natDegree_C, zero_add]
  refine le_trans (Polynomial.natDegree_prod_le _ _) ?_
  have hcard : (Finset.univ.erase t).card = s := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ t)]
    simp
  calc ∑ u ∈ Finset.univ.erase t,
        (1 - Polynomial.C (secEigval s (u : ℕ)) * Polynomial.X).natDegree
      ≤ ∑ _u ∈ Finset.univ.erase t, 1 := by
        refine Finset.sum_le_sum (fun u _ => ?_)
        refine le_trans (Polynomial.natDegree_sub_le _ _) ?_
        simp only [Polynomial.natDegree_one, max_le_iff]
        exact ⟨Nat.zero_le 1, le_trans Polynomial.natDegree_mul_le (by simp)⟩
    _ = s := by simp [hcard]

end AdjSum