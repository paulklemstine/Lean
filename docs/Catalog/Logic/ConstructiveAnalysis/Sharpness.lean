/-
# Sharpness results for the constructive development

This file settles, with complete proofs, three of the quantitative questions raised
by the Bishop-style development in this directory.

* **Sharpness of the root modulus.**  `Bishop.abs_sub_root_le` bounds the distance of
  an `ε`-approximate root from the exact root by `ε / c`, where `c` is the slope
  bound.  `Bishop.root_modulus_attained` shows that this bound is *attained*, and
  `Bishop.no_root_modulus_below_one` shows that no constant `κ < 1` can replace the
  factor `1` in `ε / c`.

* **Necessity of Bishop's diagonal shift.**  `Bishop.Reg.limit` builds the limit of a
  regular sequence of reals by the shifted diagonal `n ↦ (x_{2n+1})_{2n+1}`.
  `Bishop.unshifted_diagonal_not_regular` exhibits an explicit regular sequence of
  Bishop reals for which the *unshifted* diagonal `n ↦ (x n).approx n` is not a
  regular sequence, so the shift cannot be dropped.  For that same family the
  shifted diagonal does converge, to the correct limit
  (`Bishop.diagWitness_limit_toReal`).

* **The optimal contraction ratio of a one-query located search.**  The trisection
  search `Bishop.bisect` of `ConstructiveSup.lean` contracts by `2/3` per call to the
  locatedness oracle.  Here the general one-query scheme with query points at
  fractions `α < β` is formalized (`Bishop.stepGen`, `Bishop.searchGen`); it is proved
  to preserve the enclosure invariant and to contract by exactly `max β (1-α)`.
  Consequently `2/3` is *not* optimal — `α = 2/5, β = 1/2` contracts by `3/5`
  (`Bishop.trisection_not_optimal`) — while `1/2` is an infimum that is never
  attained (`Bishop.one_query_contraction_gt_half`,
  `Bishop.exists_one_query_contraction_lt_half_add`).

* **Quantitative failure of the exact intermediate value theorem.**
  `Bishop.no_continuous_root_selector` excludes *continuous* root selectors for
  Bishop's shelf family; `Bishop.shelf_selector_oscillation_ge_one` shows that no
  selector at all — continuous or not — has oscillation smaller than `1` on any
  neighbourhood of the critical parameter `0`.
-/

import Mathlib
import Logic.ConstructiveAnalysis.BishopReals
import Logic.ConstructiveAnalysis.ConstructiveIVT
import Logic.ConstructiveAnalysis.BrouwerianCounterexamples
import Logic.ConstructiveAnalysis.ConstructiveOrder
import Logic.ConstructiveAnalysis.ConstructiveSup

namespace Bishop

open Set

/-! ## 1. The root modulus `ε / c` is sharp -/

/-- The linear function `x ↦ c * x` has the explicit modulus of uniform continuity
`ω ε = ε / c`. -/
theorem linear_hasModulusOn {c : ℝ} (hc : 0 < c) (s : Set ℝ) :
    HasModulusOn (fun x => c * x) s (fun ε => ε / c) := by
  intro ε hε
  refine ⟨by positivity, fun x _ y _ h => ?_⟩
  have habs : |c * x - c * y| = c * |x - y| := by
    rw [← mul_sub, abs_mul, abs_of_pos hc]
  rw [habs]
  calc c * |x - y| ≤ c * (ε / c) := by
        exact mul_le_mul_of_nonneg_left h hc.le
    _ = ε := by field_simp

/-- The linear function `x ↦ c * x` has slope bound exactly `c`. -/
theorem linear_hasSlopeBoundOn (c : ℝ) (s : Set ℝ) :
    HasSlopeBoundOn (fun x => c * x) s c := fun _ _ _ _ _ => le_of_eq (by ring)

/-- **The root modulus of `Bishop.abs_sub_root_le` is attained.**

For every slope bound `c > 0` and every accuracy `ε > 0` with `ε / c ≤ 1` there is a
function with modulus of uniform continuity `ω`, slope bound `c` and a root `r` in
`[-1,1]`, together with an `ε`-approximate root `x` whose distance from `r` is
*exactly* `ε / c`.  So the estimate `|x - r| ≤ ε / c` cannot be improved. -/
theorem root_modulus_attained {c ε : ℝ} (hc : 0 < c) (hε : 0 < ε) (hle : ε / c ≤ 1) :
    ∃ (f : ℝ → ℝ) (ω : ℝ → ℝ) (r x : ℝ),
      HasModulusOn f (Icc (-1 : ℝ) 1) ω ∧ HasSlopeBoundOn f (Icc (-1 : ℝ) 1) c ∧
        f (-1) ≤ 0 ∧ 0 ≤ f 1 ∧ r ∈ Icc (-1 : ℝ) 1 ∧ f r = 0 ∧
        x ∈ Icc (-1 : ℝ) 1 ∧ |f x| ≤ ε ∧ |x - r| = ε / c := by
  have hεc : 0 < ε / c := by positivity
  refine ⟨fun x => c * x, fun ε => ε / c, 0, ε / c,
    linear_hasModulusOn hc _, linear_hasSlopeBoundOn c _, by linarith, by linarith,
    ⟨by norm_num, by norm_num⟩, by ring, ⟨by linarith, hle⟩, ?_, ?_⟩
  · show |c * (ε / c)| ≤ ε
    have hcε : c * (ε / c) = ε := by field_simp
    rw [hcε, abs_of_pos hε]
  · rw [sub_zero, abs_of_pos hεc]

/-- **No smaller constant works.**  There is no `κ < 1` such that every
`ε`-approximate root of a function with slope bound `c` lies within `κ * (ε / c)` of
the exact root. -/
theorem no_root_modulus_below_one {κ : ℝ} (hκ : κ < 1) :
    ¬ ∀ (f : ℝ → ℝ) (a b c ε r x : ℝ), 0 < c → 0 < ε →
        HasSlopeBoundOn f (Icc a b) c → r ∈ Icc a b → f r = 0 → x ∈ Icc a b →
        |f x| ≤ ε → |x - r| ≤ κ * (ε / c) := by
  intro h
  have := h (fun x => 1 * x) (-1) 1 1 1 0 1 one_pos one_pos
    (linear_hasSlopeBoundOn 1 _) ⟨by norm_num, by norm_num⟩ (by ring)
    ⟨by norm_num, le_rfl⟩ (by norm_num)
  rw [sub_zero, abs_one] at this
  norm_num at this
  linarith

/-! ## 2. Bishop's diagonal shift is necessary

The limit of a regular sequence of Bishop reals is built in `Bishop.Reg.limit` from
the *shifted* diagonal `n ↦ (x_{2n+1})_{2n+1}`.  The following family shows the
unshifted diagonal `n ↦ (x n).approx n` need not be regular at all. -/

namespace Reg

/-- The `k`-th member of the witness family: it denotes the real `1/(k+1)`, but its
own `n`-th approximation is off by exactly `1/(n+1)`, with a sign alternating in
`k`. -/
def diagWitness (k : ℕ) : Reg where
  approx n := 1 / (k + 1) + (-1 : ℚ) ^ k * (1 / (n + 1))
  regular m n := by
    have e : (1 / ((k : ℚ) + 1) + (-1 : ℚ) ^ k * (1 / ((m : ℚ) + 1)))
        - (1 / ((k : ℚ) + 1) + (-1 : ℚ) ^ k * (1 / ((n : ℚ) + 1)))
        = (-1 : ℚ) ^ k * (1 / ((m : ℚ) + 1) - 1 / ((n : ℚ) + 1)) := by ring
    rw [e, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul]
    have hm : (0 : ℚ) < 1 / ((m : ℚ) + 1) := by positivity
    have hn : (0 : ℚ) < 1 / ((n : ℚ) + 1) := by positivity
    rw [abs_le]
    constructor <;> linarith

@[simp] lemma diagWitness_approx (k n : ℕ) :
    (diagWitness k).approx n = 1 / (k + 1) + (-1 : ℚ) ^ k * (1 / (n + 1)) := rfl

/-- The `k`-th member of the witness family denotes the real number `1/(k+1)`. -/
theorem diagWitness_toReal (k : ℕ) : (diagWitness k).toReal = 1 / ((k : ℝ) + 1) := by
  refine toReal_eq_of_approx_le _ _ 1 (fun n => ?_)
  have hcast : (((diagWitness k).approx n : ℚ) : ℝ)
      = 1 / ((k : ℝ) + 1) + (-1 : ℝ) ^ k * (1 / ((n : ℝ) + 1)) := by
    rw [diagWitness_approx]; push_cast; ring
  rw [hcast]
  have e : 1 / ((k : ℝ) + 1) + (-1 : ℝ) ^ k * (1 / ((n : ℝ) + 1)) - 1 / ((k : ℝ) + 1)
      = (-1 : ℝ) ^ k * (1 / ((n : ℝ) + 1)) := by ring
  rw [e, abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul, one_mul,
    abs_of_pos (by positivity : (0 : ℝ) < 1 / ((n : ℝ) + 1))]

/-- The witness family is a regular sequence of Bishop reals. -/
theorem diagWitness_isRegularSeq : IsRegularSeqOfReals diagWitness := by
  intro k l
  rw [diagWitness_toReal, diagWitness_toReal]
  have hk : (0 : ℝ) < 1 / ((k : ℝ) + 1) := by positivity
  have hl : (0 : ℝ) < 1 / ((l : ℝ) + 1) := by positivity
  rw [abs_le]
  constructor <;> linarith

/-- **The diagonal shift in the completeness theorem is necessary.**

There is a regular sequence of Bishop reals whose *unshifted* diagonal
`n ↦ (x n).approx n` violates the regularity condition (at `m = 0`, `n = 1` the
approximations differ by `2`, while regularity would allow only `3/2`).  Hence
`Bishop.Reg.limit` cannot be defined by the unshifted diagonal. -/
theorem unshifted_diagonal_not_regular :
    ∃ x : ℕ → Reg, IsRegularSeqOfReals x ∧
      ¬ ∀ m n : ℕ, |(x m).approx m - (x n).approx n| ≤ 1 / (m + 1) + 1 / (n + 1) := by
  refine ⟨diagWitness, diagWitness_isRegularSeq, fun h => ?_⟩
  have h01 := h 0 1
  norm_num [diagWitness_approx] at h01

/-- For the same family the *shifted* diagonal does converge, and to the right
limit: the reals `1/(k+1)` tend to `0`, and `Bishop.Reg.limit` denotes `0`. -/
theorem diagWitness_limit_toReal :
    (limit diagWitness_isRegularSeq).toReal = 0 := by
  set L := (limit diagWitness_isRegularSeq).toReal
  by_contra hne
  have hpos : 0 < |L| := abs_pos.mpr hne
  obtain ⟨k, hk⟩ := exists_nat_inv_lt 2 hpos
  have h1 := limit_spec diagWitness_isRegularSeq k
  rw [diagWitness_toReal] at h1
  have h2 : |L| ≤ |L - 1 / ((k : ℝ) + 1)| + |1 / ((k : ℝ) + 1)| := by
    calc |L| = |(L - 1 / ((k : ℝ) + 1)) + 1 / ((k : ℝ) + 1)| := by ring_nf
      _ ≤ |L - 1 / ((k : ℝ) + 1)| + |1 / ((k : ℝ) + 1)| := abs_add_le _ _
  have hkpos : (0 : ℝ) < 1 / ((k : ℝ) + 1) := by positivity
  rw [abs_of_pos hkpos] at h2
  have hfin : |L| ≤ 2 / ((k : ℝ) + 1) := by
    have e : (1 : ℝ) / ((k : ℝ) + 1) + 1 / ((k : ℝ) + 1) = 2 / ((k : ℝ) + 1) := by ring
    linarith [h1, h2]
  linarith

end Reg

/-! ## 3. The optimal contraction ratio of a one-query located search

`Bishop.bisect` queries the locatedness oracle once per step at the two trisection
points and contracts the enclosure by `2/3`.  The general one-query scheme queries at
the fractions `α < β` of the current interval; on a `true` answer the right endpoint
becomes the `β`-point, on a `false` answer the left endpoint becomes the `α`-point.
Its contraction factor is `max β (1 - α)`. -/

/-- One step of the general one-query search with query fractions `α < β`. -/
def stepGen (α β : ℚ) (L : ℚ → ℚ → Bool) (pq : ℚ × ℚ) : ℚ × ℚ :=
  if L (pq.1 + α * (pq.2 - pq.1)) (pq.1 + β * (pq.2 - pq.1)) then
    (pq.1, pq.1 + β * (pq.2 - pq.1))
  else
    (pq.1 + α * (pq.2 - pq.1), pq.2)

/-- The sequence of enclosures produced by the general one-query search. -/
def searchGen (α β : ℚ) (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) : ℕ → ℚ × ℚ
  | 0 => (a₀, b₀)
  | n + 1 => stepGen α β L (searchGen α β L a₀ b₀ n)

@[simp] lemma searchGen_zero (α β : ℚ) (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) :
    searchGen α β L a₀ b₀ 0 = (a₀, b₀) := rfl

@[simp] lemma searchGen_succ (α β : ℚ) (L : ℚ → ℚ → Bool) (a₀ b₀ : ℚ) (n : ℕ) :
    searchGen α β L a₀ b₀ (n + 1) = stepGen α β L (searchGen α β L a₀ b₀ n) := rfl

lemma stepGen_width_le (α β : ℚ) (L : ℚ → ℚ → Bool)
    (pq : ℚ × ℚ) (hw : 0 ≤ pq.2 - pq.1) :
    (stepGen α β L pq).2 - (stepGen α β L pq).1 ≤ max β (1 - α) * (pq.2 - pq.1) := by
  have hb : β ≤ max β (1 - α) := le_max_left _ _
  have ha : 1 - α ≤ max β (1 - α) := le_max_right _ _
  simp only [stepGen]
  split
  · have : (pq.1 + β * (pq.2 - pq.1)) - pq.1 = β * (pq.2 - pq.1) := by ring
    simp only [this]
    exact mul_le_mul_of_nonneg_right hb hw
  · have : pq.2 - (pq.1 + α * (pq.2 - pq.1)) = (1 - α) * (pq.2 - pq.1) := by ring
    simp only [this]
    exact mul_le_mul_of_nonneg_right ha hw

lemma stepGen_width_pos {α β : ℚ} (hα : 0 < α) (hαβ : α < β) (hβ : β < 1)
    (L : ℚ → ℚ → Bool) (pq : ℚ × ℚ) (hw : 0 < pq.2 - pq.1) :
    0 < (stepGen α β L pq).2 - (stepGen α β L pq).1 := by
  simp only [stepGen]
  split
  · have e : (pq.1 + β * (pq.2 - pq.1)) - pq.1 = β * (pq.2 - pq.1) := by ring
    rw [e]
    have : 0 < β := lt_trans hα hαβ
    positivity
  · have e : pq.2 - (pq.1 + α * (pq.2 - pq.1)) = (1 - α) * (pq.2 - pq.1) := by ring
    rw [e]
    have h1 : 0 < 1 - α := by linarith
    positivity

/-- **The contraction rate of the general one-query search.**  After `n` oracle calls
the enclosure has width at most `(max β (1-α))^n (b₀ - a₀)`, and it never degenerates. -/
theorem searchGen_width_le {α β : ℚ} (hα : 0 < α) (hαβ : α < β) (hβ : β < 1)
    (L : ℚ → ℚ → Bool) {a₀ b₀ : ℚ} (hab : a₀ < b₀) (n : ℕ) :
    0 < (searchGen α β L a₀ b₀ n).2 - (searchGen α β L a₀ b₀ n).1 ∧
      (searchGen α β L a₀ b₀ n).2 - (searchGen α β L a₀ b₀ n).1
        ≤ (max β (1 - α)) ^ n * (b₀ - a₀) := by
  induction n with
  | zero =>
      simp only [searchGen_zero, pow_zero, one_mul]
      exact ⟨by linarith, le_rfl⟩
  | succ n ih =>
      obtain ⟨hpos, hle⟩ := ih
      refine ⟨stepGen_width_pos hα hαβ hβ L _ hpos, ?_⟩
      have h1 := stepGen_width_le α β L (searchGen α β L a₀ b₀ n) hpos.le
      have hr : 0 ≤ max β (1 - α) := le_trans (by linarith : (0:ℚ) ≤ β) (le_max_left _ _)
      calc (searchGen α β L a₀ b₀ (n + 1)).2 - (searchGen α β L a₀ b₀ (n + 1)).1
          ≤ max β (1 - α) * ((searchGen α β L a₀ b₀ n).2
              - (searchGen α β L a₀ b₀ n).1) := h1
        _ ≤ max β (1 - α) * ((max β (1 - α)) ^ n * (b₀ - a₀)) :=
            mul_le_mul_of_nonneg_left hle hr
        _ = (max β (1 - α)) ^ (n + 1) * (b₀ - a₀) := by ring

lemma enclosing_stepGen {S : Set ℝ} (D : LocatedData S) {α β : ℚ}
    (hαβ : α < β) {pq : ℚ × ℚ} (hlt : pq.1 < pq.2) (h : Enclosing S pq) :
    Enclosing S (stepGen α β D.L pq) := by
  obtain ⟨hup, hlow⟩ := h
  have hw : 0 < pq.2 - pq.1 := by linarith
  have hm : pq.1 + α * (pq.2 - pq.1) < pq.1 + β * (pq.2 - pq.1) := by
    have : α * (pq.2 - pq.1) < β * (pq.2 - pq.1) :=
      mul_lt_mul_of_pos_right hαβ hw
    linarith
  by_cases hL : D.L (pq.1 + α * (pq.2 - pq.1)) (pq.1 + β * (pq.2 - pq.1)) = true
  · have hstep : stepGen α β D.L pq = (pq.1, pq.1 + β * (pq.2 - pq.1)) := by
      simp [stepGen, hL]
    rw [hstep]
    exact ⟨D.upper _ _ hm hL, hlow⟩
  · have hLf : D.L (pq.1 + α * (pq.2 - pq.1)) (pq.1 + β * (pq.2 - pq.1)) = false := by
      simpa using hL
    have hstep : stepGen α β D.L pq = (pq.1 + α * (pq.2 - pq.1), pq.2) := by
      simp [stepGen, hLf]
    rw [hstep]
    exact ⟨hup, D.witness _ _ hm hLf⟩

/-- **The general one-query search maintains the enclosure invariant.** -/
theorem searchGen_enclosing {S : Set ℝ} (D : LocatedData S) {α β : ℚ}
    (hα : 0 < α) (hαβ : α < β) (hβ : β < 1) {a₀ b₀ : ℚ} (hab : a₀ < b₀)
    (h₀ : Enclosing S (a₀, b₀)) (n : ℕ) : Enclosing S (searchGen α β D.L a₀ b₀ n) := by
  induction n with
  | zero => simpa using h₀
  | succ n ih =>
      have hpos := (searchGen_width_le hα hαβ hβ D.L hab n).1
      exact enclosing_stepGen D hαβ (by linarith) ih

/-- **The trisection ratio `2/3` is not optimal.**  The one-query scheme with query
fractions `α = 2/5`, `β = 1/2` maintains the same enclosure invariant while
contracting by `3/5 < 2/3` per oracle call. -/
theorem trisection_not_optimal {S : Set ℝ} (D : LocatedData S) {a₀ b₀ : ℚ}
    (hab : a₀ < b₀) (h₀ : Enclosing S (a₀, b₀)) :
    (3 / 5 : ℚ) < 2 / 3 ∧ ∀ n : ℕ,
      Enclosing S (searchGen (2 / 5) (1 / 2) D.L a₀ b₀ n) ∧
        (searchGen (2 / 5) (1 / 2) D.L a₀ b₀ n).2
            - (searchGen (2 / 5) (1 / 2) D.L a₀ b₀ n).1
          ≤ (3 / 5 : ℚ) ^ n * (b₀ - a₀) := by
  have hα : (0 : ℚ) < 2 / 5 := by norm_num
  have hαβ : (2 / 5 : ℚ) < 1 / 2 := by norm_num
  have hβ : (1 / 2 : ℚ) < 1 := by norm_num
  have hmax : max (1 / 2 : ℚ) (1 - 2 / 5) = 3 / 5 := by norm_num
  refine ⟨by norm_num, fun n => ⟨searchGen_enclosing D hα hαβ hβ hab h₀ n, ?_⟩⟩
  have := (searchGen_width_le hα hαβ hβ D.L hab n).2
  rwa [hmax] at this

/-- **`1/2` is a strict lower bound for the contraction ratio.**  No one-query scheme
with query fractions `α < β` contracts by a factor `≤ 1/2`. -/
theorem one_query_contraction_gt_half {α β : ℚ} (hαβ : α < β) :
    1 / 2 < max β (1 - α) := by
  rcases le_or_gt β (1 / 2) with h | h
  · have : α < 1 / 2 := lt_of_lt_of_le hαβ h
    exact lt_of_lt_of_le (by linarith) (le_max_right _ _)
  · exact lt_of_lt_of_le h (le_max_left _ _)

/-- **`1/2` is the infimum.**  For every `η > 0` there is a one-query scheme whose
contraction ratio is below `1/2 + η`. -/
theorem exists_one_query_contraction_lt_half_add {η : ℚ} (hη : 0 < η) :
    ∃ α β : ℚ, 0 < α ∧ α < β ∧ β < 1 ∧ max β (1 - α) < 1 / 2 + η := by
  set t : ℚ := min η (1 / 4)
  have ht0 : 0 < t := lt_min hη (by norm_num)
  have ht4 : t ≤ 1 / 4 := min_le_right _ _
  have htη : t ≤ η := min_le_left _ _
  refine ⟨1 / 2 - t / 2, 1 / 2 + t / 2, by linarith, by linarith, by linarith, ?_⟩
  have : max (1 / 2 + t / 2) (1 - (1 / 2 - t / 2)) = 1 / 2 + t / 2 := by
    rw [max_eq_left]
    linarith
  rw [this]
  linarith

/-! ### A worked instance of the faster search

The half-line `(-∞, 1/2]` with the decidable oracle of `Bishop.locatedIic`, searched
on `[0,1]` with the query fractions `2/5, 1/2`. -/

/-- The `2/5, 1/2` search encloses the supremum `c` of `(-∞, c]` at every stage. -/
theorem searchGen_Iic_encloses {c a₀ b₀ : ℚ} (h1 : a₀ < c) (h2 : c ≤ b₀) (hab : a₀ < b₀)
    (n : ℕ) :
    ((searchGen (2 / 5) (1 / 2) (locatedIic c).L a₀ b₀ n).1 : ℝ) < (c : ℝ) ∧
      (c : ℝ) ≤ ((searchGen (2 / 5) (1 / 2) (locatedIic c).L a₀ b₀ n).2 : ℝ) := by
  have h₀ : Enclosing (Set.Iic (c : ℝ)) (a₀, b₀) := by
    constructor
    · intro s hs
      have : (c : ℝ) ≤ (b₀ : ℝ) := by exact_mod_cast h2
      exact le_trans hs this
    · exact ⟨(c : ℝ), Set.mem_Iic.mpr (le_refl _), by exact_mod_cast h1⟩
  obtain ⟨hup, s, hsS, hs⟩ :=
    searchGen_enclosing (α := 2 / 5) (β := 1 / 2) (locatedIic c) (by norm_num) (by norm_num) (by norm_num) hab h₀ n
  exact ⟨lt_of_lt_of_le hs (Set.mem_Iic.mp hsS), hup (c : ℝ) (Set.mem_Iic.mpr (le_refl _))⟩

/-! The search is genuinely computable; the following facts about the `2/5, 1/2`
search for `c = 1/2` on `[0,1]` are checked at compile time. -/

-- the first five enclosures
#guard (List.range 5).map (fun n => searchGen (2 / 5) (1 / 2) (locatedIic (1 / 2)).L 0 1 n)
    = [(0, 1), (0, 1 / 2), (1 / 5, 1 / 2), (8 / 25, 1 / 2), (49 / 125, 1 / 2)]

-- after ten steps the width respects the proved bound `(3/5)^10` ...
#guard (searchGen (2 / 5) (1 / 2) (locatedIic (1 / 2)).L 0 1 10).2
      - (searchGen (2 / 5) (1 / 2) (locatedIic (1 / 2)).L 0 1 10).1 ≤ (3 / 5 : ℚ) ^ 10

-- ... which is smaller than the trisection bound `(2/3)^10`
#guard (3 / 5 : ℚ) ^ 10 < (2 / 3 : ℚ) ^ 10

-- and the enclosure does contain `1/2`
#guard (searchGen (2 / 5) (1 / 2) (locatedIic (1 / 2)).L 0 1 10).1 < (1 / 2 : ℚ) &&
    (1 / 2 : ℚ) ≤ (searchGen (2 / 5) (1 / 2) (locatedIic (1 / 2)).L 0 1 10).2

/-! ## 4. Every root selector for the shelf family jumps by at least `1`

`Bishop.no_continuous_root_selector` shows that no *continuous* root selector exists
for Bishop's shelf family.  In fact no selector at all can have small oscillation
near the critical parameter `t = 0`: the roots are `1` for `t > 0` and `2` for
`t < 0`, so on every neighbourhood of `0` a selector takes both values. -/

/-- For a positive parameter the unique root of the shelf function is `x = 1`. -/
theorem shelf_root_of_pos {t x : ℝ} (ht : 0 < t) (h : shelf t x = 0) : x = 1 := by
  simp only [shelf] at h
  rcases min_cases (x - 1) (max t (x - 2)) with ⟨he, _⟩ | ⟨he, _⟩ <;> rw [he] at h
  · linarith
  · rcases max_cases t (x - 2) with ⟨he2, h2⟩ | ⟨he2, h2⟩ <;> rw [he2] at h <;> linarith

/-- For a negative parameter the unique root of the shelf function is `x = 2`. -/
theorem shelf_root_of_neg {t x : ℝ} (ht : t < 0) (h : shelf t x = 0) : x = 2 := by
  simp only [shelf] at h
  rcases min_cases (x - 1) (max t (x - 2)) with ⟨he, hle⟩ | ⟨he, _⟩ <;> rw [he] at h
  · rcases max_cases t (x - 2) with ⟨he2, _⟩ | ⟨he2, _⟩ <;> rw [he2] at hle <;> linarith
  · rcases max_cases t (x - 2) with ⟨he2, _⟩ | ⟨he2, _⟩ <;> rw [he2] at h <;> linarith

/-- Every root of every member of the shelf family lies in `[1,2]`. -/
theorem shelf_root_mem_Icc {t x : ℝ} (h : shelf t x = 0) : 1 ≤ x ∧ x ≤ 2 := by
  have hmax : x - 2 ≤ max t (x - 2) := le_max_right _ _
  simp only [shelf] at h
  rcases min_cases (x - 1) (max t (x - 2)) with ⟨he, _⟩ | ⟨he, hle⟩ <;> rw [he] at h
  · exact ⟨by linarith, by linarith⟩
  · exact ⟨by linarith, by linarith⟩

/-- **Quantitative failure of the exact intermediate value theorem.**  For *every*
choice function `r` picking a root of `shelf t` for each parameter `t ∈ [-1,1]`, and
every `η > 0`, the oscillation of `r` on the parameters of size at most `η` is at
least `1`.  So no root selector, however discontinuous, is even approximately
continuous at the critical parameter `0`. -/
theorem shelf_selector_oscillation_ge_one {r : ℝ → ℝ}
    (hr : ∀ t ∈ Icc (-1 : ℝ) 1, shelf t (r t) = 0) {η : ℝ} (hη : 0 < η) :
    1 ≤ sSup (r '' (Icc (-1 : ℝ) 1 ∩ Icc (-η) η))
          - sInf (r '' (Icc (-1 : ℝ) 1 ∩ Icc (-η) η)) := by
  set T : Set ℝ := Icc (-1 : ℝ) 1 ∩ Icc (-η) η
  set S : Set ℝ := r '' T
  have hsub : ∀ y ∈ S, 1 ≤ y ∧ y ≤ 2 := by
    rintro _ ⟨t, ht, rfl⟩
    exact shelf_root_mem_Icc (hr t ht.1)
  have hbddA : BddAbove S := ⟨2, fun y hy => (hsub y hy).2⟩
  have hbddB : BddBelow S := ⟨1, fun y hy => (hsub y hy).1⟩
  set s : ℝ := min η 1
  have hs0 : 0 < s := lt_min hη one_pos
  have hs1 : s ≤ 1 := min_le_right _ _
  have hsη : s ≤ η := min_le_left _ _
  have hmemP : s ∈ T := ⟨⟨by linarith, hs1⟩, ⟨by linarith, hsη⟩⟩
  have hmemN : -s ∈ T := ⟨⟨by linarith, by linarith⟩, ⟨by linarith, by linarith⟩⟩
  have h1 : r s = 1 := shelf_root_of_pos hs0 (hr s hmemP.1)
  have h2 : r (-s) = 2 := shelf_root_of_neg (by linarith) (hr (-s) hmemN.1)
  have hmem2 : (2 : ℝ) ∈ S := by
    refine ⟨-s, hmemN, ?_⟩
    rw [h2]
  have hmem1 : (1 : ℝ) ∈ S := by
    refine ⟨s, hmemP, ?_⟩
    rw [h1]
  have hup : (2 : ℝ) ≤ sSup S := le_csSup hbddA hmem2
  have hlo : sInf S ≤ 1 := csInf_le hbddB hmem1
  linarith

/-- The hypothesis of `shelf_selector_oscillation_ge_one` is not vacuous: root
selectors do exist (classically), for instance the discontinuous one `t ↦ 2` for
`t < 0` and `t ↦ 1` otherwise. -/
theorem exists_shelf_root_selector :
    ∃ r : ℝ → ℝ, ∀ t ∈ Icc (-1 : ℝ) 1, shelf t (r t) = 0 := by
  classical
  refine ⟨fun t => if t < 0 then 2 else 1, fun t _ => ?_⟩
  by_cases ht : t < 0
  · have hmax : max t ((2 : ℝ) - 2) = 0 := by
      rw [sub_self]
      exact max_eq_right ht.le
    simp only [if_pos ht, shelf, hmax]
    norm_num
  · push_neg at ht
    have hmax : max t ((1 : ℝ) - 2) = t := max_eq_left (by linarith)
    simp only [if_neg (not_lt.mpr ht), shelf, hmax]
    norm_num
    exact ht

end Bishop