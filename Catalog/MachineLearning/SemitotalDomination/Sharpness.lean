import Mathlib
import MachineLearning.SemitotalDomination.Approximation

/-!
# Sharpness of the packing constant `5`

The approximation factor of the algorithm is `5` because a closed unit disk holds at most `5`
pairwise `1`-separated points (`SemitotalDomination.card_le_five_of_pairwise_far`).  Here we show
that this constant cannot be improved: the five fifth roots of unity are pairwise at distance
`2 sin(π/5) ≈ 1.176 > 1` and all lie in the closed unit disk centred at the origin.

Consequently there is a genuine unit disk graph (a "pentagonal wheel": the centre together with
the five roots of unity) in which the closed neighbourhood of a vertex contains an independent
set of size exactly `5`, so the local packing bound used in the analysis is attained.

-- !-- Lab Notes -- !--
## Hypothesis
`5` is the exact local packing number of the plane at scale `1`, i.e. the geometric reason for
the ratio `5` (and not `4` or `6`).

## Experimental outcome
`2 sin 36° = 1.17557...`, so the regular pentagon on the unit circle is `1`-separated with slack
`0.17557`, while for the regular hexagon the separation drops to exactly `1`: the bound flips
between `5` and `6` precisely at the strict inequality.

## Insights
* The pairwise distances of the pentagon reduce to `cos(2πm/5) < 1/2` for `m = 1,2,3,4`, i.e. to
  the statement that all nonzero multiples of `72°` lie strictly between `60°` and `300°`.
* Hence the same argument shows the constant is `⌊2π / (π/3)⌋ - 1 = 5`, the "kissing number"
  bookkeeping of the plane.
-/

namespace SemitotalDomination

open Complex Real

/-- Squared distance between two points of the unit circle. -/
theorem dist_exp_mul_I_sq (a b : ℝ) :
    dist (Complex.exp ((a : ℂ) * I)) (Complex.exp ((b : ℂ) * I)) ^ 2
      = 2 - 2 * Real.cos (a - b) := by
  rw [dist_eq_norm, ← Complex.normSq_eq_norm_sq]
  simp [Complex.exp_mul_I, Complex.normSq_apply, Real.cos_sub, Complex.cos_ofReal_re,
    Complex.sin_ofReal_re]
  nlinarith [Real.sin_sq_add_cos_sq a, Real.sin_sq_add_cos_sq b]

/-- `cos d < 1/2` for `d` strictly between `60°` and `300°`. -/
theorem cos_lt_half {d : ℝ} (h1 : π / 3 < d) (h2 : d < 5 * π / 3) : Real.cos d < 1 / 2 := by
  have hpi := Real.pi_pos
  by_cases h : d ≤ π
  · have := Real.cos_lt_cos_of_nonneg_of_le_pi (by linarith : (0:ℝ) ≤ π / 3) h h1
    rwa [Real.cos_pi_div_three] at this
  · push_neg at h
    have he : d = 2 * π - (2 * π - d) := by ring
    rw [he, Real.cos_two_pi_sub]
    have := Real.cos_lt_cos_of_nonneg_of_le_pi (by linarith : (0:ℝ) ≤ π / 3)
      (by linarith : 2 * π - d ≤ π) (by linarith : π / 3 < 2 * π - d)
    rwa [Real.cos_pi_div_three] at this

/-- Two points of the unit circle whose angular difference is strictly between `60°` and `300°`
are at distance greater than `1`. -/
theorem one_lt_dist_of_angle {a b : ℝ} (h1 : π / 3 < a - b) (h2 : a - b < 5 * π / 3) :
    1 < dist (Complex.exp ((a : ℂ) * I)) (Complex.exp ((b : ℂ) * I)) := by
  have hc := cos_lt_half h1 h2
  have hsq := dist_exp_mul_I_sq a b
  nlinarith [dist_nonneg (x := Complex.exp ((a : ℂ) * I)) (y := Complex.exp ((b : ℂ) * I))]

/-- The angle of the `k`-th fifth root of unity. -/
noncomputable def pentAngle (k : ℕ) : ℝ := 2 * π * k / 5

/-- The five fifth roots of unity. -/
noncomputable def pent (k : Fin 5) : ℂ := Complex.exp ((pentAngle k : ℂ) * I)

theorem pent_far_aux {m n : ℕ} (hm : m < 5) (h : n < m) :
    1 < dist (Complex.exp ((pentAngle m : ℂ) * I)) (Complex.exp ((pentAngle n : ℂ) * I)) := by
  have hpi := Real.pi_pos
  have h1 : (1:ℝ) ≤ (m:ℝ) - (n:ℝ) := by
    have : (n:ℝ) + 1 ≤ (m:ℝ) := by exact_mod_cast h
    linarith
  have h2 : (m:ℝ) - (n:ℝ) ≤ 4 := by
    have hm' : (m:ℝ) ≤ 4 := by exact_mod_cast Nat.lt_succ_iff.mp hm
    have hn' : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n
    linarith
  apply one_lt_dist_of_angle <;> simp only [pentAngle] <;> nlinarith [hpi, h1, h2]

/-- **The regular pentagon is `1`-separated.** -/
theorem pent_far (k j : Fin 5) (h : k ≠ j) : 1 < dist (pent k) (pent j) := by
  have hne : (k : ℕ) ≠ (j : ℕ) := fun hc => h (Fin.ext hc)
  rcases Nat.lt_or_ge (k : ℕ) (j : ℕ) with hlt | hge
  · rw [dist_comm]
    exact pent_far_aux j.isLt hlt
  · exact pent_far_aux k.isLt (by omega)

theorem pent_mem_disk (k : Fin 5) : dist (pent k) 0 = 1 := by
  simp [pent]

theorem pent_injective : Function.Injective pent := by
  intro k j hkj
  by_contra hne
  have := pent_far k j hne
  rw [hkj] at this
  simp only [dist_self] at this
  linarith

/-- **Sharpness of the packing lemma.**  There are five points of the closed unit disk that are
pairwise at distance greater than `1`; so `card_le_five_of_pairwise_far` is optimal. -/
theorem exists_five_pairwise_far_in_unit_disk :
    ∃ T : Finset ℂ, T.card = 5 ∧ (∀ x ∈ T, dist x 0 ≤ 1) ∧
      (∀ x ∈ T, ∀ y ∈ T, x ≠ y → 1 < dist x y) := by
  classical
  refine ⟨Finset.univ.image pent, ?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ pent_injective]
    simp
  · intro x hx
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp hx
    exact le_of_eq (pent_mem_disk k)
  · intro x hx y hy hxy
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp hx
    obtain ⟨j, -, rfl⟩ := Finset.mem_image.mp hy
    exact pent_far k j (fun h => hxy (by rw [h]))

/-! ### A unit disk graph attaining the local bound -/

variable {V : Type*}

/-- The unit disk graph determined by a placement of the vertices in the plane. -/
def unitDiskGraph (pos : V → ℂ) : SimpleGraph V where
  Adj u v := u ≠ v ∧ dist (pos u) (pos v) ≤ 1
  symm := by
    rintro u v ⟨h1, h2⟩
    exact ⟨h1.symm, by rwa [dist_comm]⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

/-- Its tautological unit disk representation. -/
def unitDiskRepOfPos [Fintype V] [DecidableEq V] (pos : V → ℂ) :
    UnitDiskRep (unitDiskGraph pos) where
  pos := pos
  adj_iff _ _ := Iff.rfl

/-- The "pentagonal wheel": the centre of the disk together with the five roots of unity. -/
noncomputable def wheelPos : Option (Fin 5) → ℂ
  | none => 0
  | some k => pent k

/-- **The local packing bound `5` is attained.**  In the pentagonal wheel unit disk graph, the
closed neighbourhood of the centre contains an independent set with exactly `5` vertices. -/
theorem exists_five_independent_in_closed_neighbourhood :
    ∃ (W : Type) (_ : Fintype W) (pos : W → ℂ) (c : W) (I : Finset W),
      I.card = 5 ∧ (unitDiskGraph pos).IsIndepSet (I : Set W) ∧
      ∀ x ∈ I, (unitDiskGraph pos).Adj c x := by
  classical
  refine ⟨Option (Fin 5), inferInstance, wheelPos, none, Finset.univ.image some, ?_, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ (Option.some_injective _)]
    simp
  · rw [isIndepSet_iff]
    intro a ha b hb hab
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp ha
    obtain ⟨j, -, rfl⟩ := Finset.mem_image.mp hb
    have hne : k ≠ j := by
      rintro rfl
      exact (unitDiskGraph wheelPos).irrefl hab
    exact absurd hab.2 (not_le.mpr (pent_far k j hne))
  · intro x hx
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.mp hx
    refine ⟨by simp, ?_⟩
    show dist (0 : ℂ) (pent k) ≤ 1
    rw [dist_comm]
    exact le_of_eq (pent_mem_disk k)

end SemitotalDomination