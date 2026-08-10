import Mathlib

/-!
# The packing lemma behind the factor `5`

The constant `5` in the approximation ratio for semitotal domination on unit disk graphs comes
from a purely geometric fact:

> a closed disk of radius `1` cannot contain `6` points that are pairwise at distance `> 1`.

Equivalently, in a unit disk graph the closed neighbourhood of a vertex contains at most `5`
pairwise non-adjacent vertices.

We model the plane by `ℂ`.  The proof is the classical angular pigeonhole argument:
after translating the centre to `0`, the six points have well-defined arguments; sorting them
(`Tuple.sort`) shows that two of them subtend an angle of at most `π/3` at the centre, and two
points of the closed unit disk subtending an angle of at most `π/3` are at distance at most `1`
(law of cosines, `dist_le_one_of_cos_ge`).

-- !-- Lab Notes -- !--
## Hypothesis
The factor `5` is *not* combinatorial: it is the maximal number of pairwise `1`-separated points
in a closed unit disk.  (The bound is tight: the five vertices of a regular pentagon inscribed in
the unit circle are pairwise at distance `2 sin 36° ≈ 1.176 > 1`.)

## Experimental outcome (see ComputationalEvidence.md)
Random sampling of `6`-point configurations in the unit disk never produced a pairwise separation
above `1`; the numerical optimum of the minimal pairwise distance for `6` points in the unit disk
is exactly `1` (attained by the centre plus a regular hexagon on the boundary), which is why the
strict inequality `> 1` is essential — with `≥ 1` the statement is false.

## Insights
* The angular argument needs the *sorted* sequence of arguments; the pigeonhole into six `60°`
  sectors is not sufficient (six points can occupy six distinct sectors).
* The inequality `a² + b² - ab ≤ 1` for `a, b ∈ [0,1]` is the exact algebraic content of
  "angle `≤ 60°` implies distance `≤ max(a,b)`".
-/

namespace SemitotalDomination

open Complex Real

/-- If `0 ≤ d ≤ π/3` then `cos d ≥ 1/2`. -/
private lemma cos_ge_half_of_small {d : ℝ} (h0 : 0 ≤ d) (h1 : d ≤ π / 3) :
    (1 : ℝ) / 2 ≤ Real.cos d := by
  have hpi := Real.pi_pos
  have := Real.cos_le_cos_of_nonneg_of_le_pi h0 (by linarith) h1
  rwa [Real.cos_pi_div_three] at this

/-- If `5π/3 ≤ d ≤ 2π` then `cos d ≥ 1/2`. -/
private lemma cos_ge_half_of_near_two_pi {d : ℝ} (h1 : 5 * π / 3 ≤ d) (h2 : d ≤ 2 * π) :
    (1 : ℝ) / 2 ≤ Real.cos d := by
  have hpi := Real.pi_pos
  have h : d = 2 * π - (2 * π - d) := by ring
  rw [h, Real.cos_two_pi_sub]
  exact cos_ge_half_of_small (by linarith) (by linarith)

/-- Law of cosines in `ℂ`: two points of the closed unit disk centred at `0` whose arguments
differ by an angle of at most `60°` are at distance at most `1`. -/
theorem dist_le_one_of_cos_ge (z w : ℂ) (hz : ‖z‖ ≤ 1) (hw : ‖w‖ ≤ 1)
    (h : (1 : ℝ) / 2 ≤ Real.cos (z.arg - w.arg)) : ‖z - w‖ ≤ 1 := by
  rcases eq_or_ne z 0 with rfl | hz0
  · simpa using hw
  rcases eq_or_ne w 0 with rfl | hw0
  · simpa using hz
  have ha0 : 0 < ‖z‖ := by simpa using hz0
  have hb0 : 0 < ‖w‖ := by simpa using hw0
  have hzre : z.re = ‖z‖ * Real.cos z.arg := by rw [Complex.cos_arg hz0]; field_simp
  have hzim : z.im = ‖z‖ * Real.sin z.arg := by rw [Complex.sin_arg]; field_simp
  have hwre : w.re = ‖w‖ * Real.cos w.arg := by rw [Complex.cos_arg hw0]; field_simp
  have hwim : w.im = ‖w‖ * Real.sin w.arg := by rw [Complex.sin_arg]; field_simp
  have key : ‖z - w‖ ^ 2
      = ‖z‖ ^ 2 + ‖w‖ ^ 2 - 2 * (‖z‖ * ‖w‖) * Real.cos (z.arg - w.arg) := by
    have h1 : ‖z - w‖ ^ 2 = (z.re - w.re) ^ 2 + (z.im - w.im) ^ 2 := by
      rw [← Complex.normSq_eq_norm_sq]
      simp [Complex.normSq_apply]; ring
    have h2 : ‖z‖ ^ 2 = z.re ^ 2 + z.im ^ 2 := by
      rw [← Complex.normSq_eq_norm_sq]; simp [Complex.normSq_apply]; ring
    have h3 : ‖w‖ ^ 2 = w.re ^ 2 + w.im ^ 2 := by
      rw [← Complex.normSq_eq_norm_sq]; simp [Complex.normSq_apply]; ring
    rw [h1, h2, h3, Real.cos_sub]
    nth_rewrite 1 [hzre, hzim, hwre, hwim]
    nth_rewrite 1 [hzre, hzim, hwre, hwim]
    ring
  have hsq : ‖z - w‖ ^ 2 ≤ 1 := by
    rw [key]
    nlinarith [sq_nonneg (‖z‖ - ‖w‖), mul_nonneg (norm_nonneg z) (norm_nonneg w),
      mul_nonneg (sub_nonneg.mpr hz) (sub_nonneg.mpr hw)]
  nlinarith [norm_nonneg (z - w)]

/-- **Angular pigeonhole.**  Among six complex numbers, two distinct ones subtend an angle of at
most `60°` at the origin. -/
theorem exists_close_args (z : Fin 6 → ℂ) :
    ∃ i j, i ≠ j ∧ (1 : ℝ) / 2 ≤ Real.cos ((z i).arg - (z j).arg) := by
  classical
  have hpi := Real.pi_pos
  set θ : Fin 6 → ℝ := fun i => (z i).arg with hθ
  by_cases hinj : Function.Injective θ
  · set σ := Tuple.sort θ with hσ
    set f := θ ∘ σ with hf
    have hstrict : StrictMono f :=
      (Tuple.monotone_sort θ).strictMono_of_injective (hinj.comp σ.injective)
    have key : ∀ i j : Fin 6, i ≠ j → f i - f j ≤ π / 3 → 0 ≤ f i - f j →
        ∃ i' j' : Fin 6, i' ≠ j' ∧ (1 : ℝ) / 2 ≤ Real.cos ((z i').arg - (z j').arg) := by
      intro i j hij h1 h0
      exact ⟨σ i, σ j, fun h => hij (σ.injective h), cos_ge_half_of_small h0 h1⟩
    by_cases h1 : f 1 - f 0 ≤ π / 3
    · exact key 1 0 (by decide) h1 (by linarith [hstrict (show (0 : Fin 6) < 1 by decide)])
    by_cases h2 : f 2 - f 1 ≤ π / 3
    · exact key 2 1 (by decide) h2 (by linarith [hstrict (show (1 : Fin 6) < 2 by decide)])
    by_cases h3 : f 3 - f 2 ≤ π / 3
    · exact key 3 2 (by decide) h3 (by linarith [hstrict (show (2 : Fin 6) < 3 by decide)])
    by_cases h4 : f 4 - f 3 ≤ π / 3
    · exact key 4 3 (by decide) h4 (by linarith [hstrict (show (3 : Fin 6) < 4 by decide)])
    by_cases h5 : f 5 - f 4 ≤ π / 3
    · exact key 5 4 (by decide) h5 (by linarith [hstrict (show (4 : Fin 6) < 5 by decide)])
    push_neg at h1 h2 h3 h4 h5
    refine ⟨σ 5, σ 0, fun h => (by decide : (5 : Fin 6) ≠ 0) (σ.injective h), ?_⟩
    have hub : f 5 ≤ π := Complex.arg_le_pi _
    have hlb : -π < f 0 := Complex.neg_pi_lt_arg _
    have e5 : (z (σ 5)).arg = f 5 := rfl
    have e0 : (z (σ 0)).arg = f 0 := rfl
    rw [e5, e0]
    exact cos_ge_half_of_near_two_pi (by linarith) (by linarith)
  · rw [Function.not_injective_iff] at hinj
    obtain ⟨a, b, hab, hne⟩ := hinj
    have harg : (z a).arg = (z b).arg := hab
    refine ⟨a, b, hne, ?_⟩
    rw [harg, sub_self, Real.cos_zero]
    norm_num

/-- **Packing lemma.**  A closed disk of radius `1` contains no `6` points that are pairwise at
distance greater than `1`. -/
theorem no_six_pairwise_far_in_unit_disk (c : ℂ) (p : Fin 6 → ℂ)
    (hb : ∀ i, dist (p i) c ≤ 1) (hs : ∀ i j, i ≠ j → 1 < dist (p i) (p j)) : False := by
  obtain ⟨i, j, hij, hcos⟩ := exists_close_args (fun i => p i - c)
  have hi : ‖p i - c‖ ≤ 1 := by rw [← dist_eq_norm]; exact hb i
  have hj : ‖p j - c‖ ≤ 1 := by rw [← dist_eq_norm]; exact hb j
  have hle := dist_le_one_of_cos_ge _ _ hi hj hcos
  have heq : (p i - c) - (p j - c) = p i - p j := by ring
  rw [heq, ← dist_eq_norm] at hle
  exact absurd hle (not_le.mpr (hs i j hij))

/-- Any finite set of points of a closed unit disk that is pairwise `1`-separated has at most
`5` elements. -/
theorem card_le_five_of_pairwise_far (c : ℂ) (T : Finset ℂ)
    (hb : ∀ x ∈ T, dist x c ≤ 1) (hs : ∀ x ∈ T, ∀ y ∈ T, x ≠ y → 1 < dist x y) :
    T.card ≤ 5 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨t, htT, htc⟩ := Finset.exists_subset_card_eq (show 6 ≤ T.card by omega)
  have e : Fin 6 ≃ t := (t.equivFin.trans (finCongr htc)).symm
  refine no_six_pairwise_far_in_unit_disk c (fun i => (e i : ℂ))
    (fun i => hb _ (htT (e i).2)) ?_
  intro i j hij
  exact hs _ (htT (e i).2) _ (htT (e j).2) (fun hpq => hij (e.injective (Subtype.ext hpq)))

end SemitotalDomination