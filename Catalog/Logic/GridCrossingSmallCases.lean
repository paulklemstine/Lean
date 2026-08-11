/-
# Cylinder probabilities and the exact crossing polynomials of the `1 × 1` and `2 × 2` grids

Conjectures 1 and 2 of the previous cycle of this research thread quote
enumerated values of the horizontal crossing probability `θ_n(p)` of the
`n × n` grid and of its Russo derivative.  This file replaces the enumeration by
formal proofs for `n = 1` and `n = 2`.

The tool is a general cylinder formula: the probability that all sites of a
finite set `S` are open is `p ^ |S|` (`bernProb_allOpenEvent`), proved from the
one-site Harris defect formula of `Catalog/Logic/HarrisDefectPivotal.lean` — a
site outside `S` is never pivotal for the cylinder, so the defect vanishes and
the probability is exactly multiplied by `p`.

The combinatorial input for `n = 2` is that a grid walk that increases its row
index past `r` must do so in a single vertical step, whose two endpoints lie in
the same column (`gridWalk_vertical_pair`).  Hence for the `2 × 2` grid a
crossing exists exactly when some column is fully open, and inclusion–exclusion
gives `θ_2(p) = 2p² - p⁴`.

## Main results

* `bernProb_allOpenEvent`: `P_p(all sites of S open) = p ^ |S|`.
* `gridWalk_vertical_pair`: a grid walk crossing a row uses a vertical edge.
* `crossing_bernProb_one`: `θ_1(p) = p`.
* `crossing_bernProb_two`: `θ_2(p) = 2p² - p⁴`.
* `crossing_bernProb_one_half`, `crossing_bernProb_two_half`:
  `θ_1(1/2) = 1/2` and `θ_2(1/2) = 7/16`, together with
  `crossing_two_half_lt_one_half` and `crossing_two_half_lt_crossing_one_half`,
  the first instances of Conjecture 2.
* `crossing_deriv_half_le`: `θ_n'(1/2) ≤ n` for every `n ≥ 1`, the second half
  of Conjecture 1.
* `crossing_deriv_one`, `crossing_deriv_two`, `crossing_deriv_one_half_lt_two`:
  `θ_1'(p) = 1`, `θ_2'(p) = 4p - 4p³`, `θ_1'(1/2) = 1 < 3/2 = θ_2'(1/2) ≤ 2`,
  the first instances of Conjecture 1.
-/

import Logic.HarrisDefectPivotal
import Combinatorics.BernoulliInfluenceSqrt

open Finset

namespace BernoulliThresholdCoupling

/-! ## Cylinder events -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The event that every site of `S` is open. -/
def allOpenEvent (S : Finset ι) : Set (ι → Bool) := {η | ∀ v ∈ S, η v = true}

omit [Fintype ι] [DecidableEq ι] in
theorem allOpenEvent_isIncreasing (S : Finset ι) : IsIncreasing (allOpenEvent S) :=
  fun _ _ hdom hη v hv => hdom v (hη v hv)

omit [Fintype ι] [DecidableEq ι] in
theorem allOpenEvent_empty : allOpenEvent (∅ : Finset ι) = Set.univ := by
  ext η; simp [allOpenEvent]

omit [Fintype ι] in
theorem allOpenEvent_insert {S : Finset ι} {w : ι} :
    allOpenEvent (insert w S) = allOpenEvent S ∩ {η : ι → Bool | η w = true} := by
  ext η
  simp only [allOpenEvent, Set.mem_setOf_eq, Set.mem_inter_iff, Finset.mem_insert]
  constructor
  · intro h
    exact ⟨fun v hv => h v (Or.inr hv), h w (Or.inl rfl)⟩
  · rintro ⟨h1, h2⟩ v (rfl | hv)
    · exact h2
    · exact h1 v hv

omit [Fintype ι] in
/-- A site outside `S` is never pivotal for the cylinder event of `S`. -/
theorem pivotalSet_allOpenEvent_of_notMem {S : Finset ι} {w : ι} (hw : w ∉ S) :
    pivotalSet (allOpenEvent S) w = ∅ := by
  ext η
  simp only [Set.mem_empty_iff_false, iff_false]
  rintro ⟨h1, h2⟩
  refine h2 (fun v hv => ?_)
  have hvw : v ≠ w := fun h => hw (h ▸ hv)
  have hv' := h1 v hv
  rw [Function.update_of_ne hvw] at hv'
  rw [Function.update_of_ne hvw]
  exact hv'

/-- **Cylinder probability.**  The probability that all sites of `S` are open is
`p ^ |S|`. -/
theorem bernProb_allOpenEvent (p : ℝ) (S : Finset ι) :
    bernProb p (allOpenEvent S) = p ^ S.card := by
  classical
  induction S using Finset.induction_on with
  | empty => simp [allOpenEvent_empty, bernProb_univ]
  | insert w S hw ih =>
    rw [allOpenEvent_insert,
      harris_openSite_eq_of_not_pivotal (allOpenEvent_isIncreasing S) p
        (pivotalSet_allOpenEvent_of_notMem hw),
      ih, Finset.card_insert_of_notMem hw, pow_succ, mul_comm]

/-! ## Vertical steps of grid walks -/

/-- A grid walk whose row index rises past `r` must contain a vertical step at
that row: two open sites in the same column with consecutive rows, the upper one
in row `r`. -/
theorem gridWalk_vertical_pair {n : ℕ} {η : Fin n × Fin n → Bool} :
    ∀ {a b : Fin n × Fin n} (w : (gridGraph n).Walk a b), (∀ x ∈ w.support, η x = true) →
      ∀ {r : ℕ}, a.1.val < r → r ≤ b.1.val →
        ∃ x y : Fin n × Fin n, η x = true ∧ η y = true ∧ x.2 = y.2 ∧
          x.1.val + 1 = y.1.val ∧ y.1.val = r := by
  intro a b w
  induction w with
  | nil => intro _ r ha hb; omega
  | @cons a y b hadj q ih =>
    intro hsup r ha hb
    have hya : η y = true := hsup y (by simp)
    have haa : η a = true := hsup a (by simp)
    have hsupq : ∀ x ∈ q.support, η x = true := by
      intro x hx
      exact hsup x (by rw [SimpleGraph.Walk.support_cons]; exact List.mem_cons_of_mem _ hx)
    by_cases hy : y.1.val < r
    · exact ih hsupq hy hb
    · push_neg at hy
      refine ⟨a, y, haa, hya, ?_, ?_, ?_⟩ <;>
        rcases hadj with ⟨h1, h2⟩ | ⟨h1, h2⟩
      · exact absurd (congrArg Fin.val h1) (by omega)
      · exact h1
      · exact absurd (congrArg Fin.val h1) (by omega)
      · omega
      · exact absurd (congrArg Fin.val h1) (by omega)
      · omega

/-! ## The `1 × 1` grid -/

theorem crossingEvent_one_eq :
    crossingEvent 1 one_pos = allOpenEvent ({((0 : Fin 1), (0 : Fin 1))} : Finset _) := by
  ext η
  constructor
  · rintro ⟨a, b, w, hw⟩
    intro v _
    have h := hw _ w.start_mem_support
    have hv : v = (⟨0, one_pos⟩, a) := Subsingleton.elim _ _
    rwa [hv]
  · intro h
    refine ⟨0, 0, SimpleGraph.Walk.nil, fun x hx => ?_⟩
    exact h x (by simp [Subsingleton.elim x ((0 : Fin 1), (0 : Fin 1))])

/-- **The crossing polynomial of the `1 × 1` grid.** -/
theorem crossing_bernProb_one (p : ℝ) : bernProb p (crossingEvent 1 one_pos) = p := by
  rw [crossingEvent_one_eq, bernProb_allOpenEvent]
  simp

/-! ## The `2 × 2` grid -/

theorem crossingEvent_two_eq :
    crossingEvent 2 two_pos =
      allOpenEvent ({((0 : Fin 2), (0 : Fin 2)), ((1 : Fin 2), (0 : Fin 2))} : Finset _) ∪
        allOpenEvent ({((0 : Fin 2), (1 : Fin 2)), ((1 : Fin 2), (1 : Fin 2))} : Finset _) := by
  ext η
  constructor
  · rintro ⟨a, b, w, hw⟩
    obtain ⟨x, y, hx, hy, hxy, hstep, hyr⟩ :=
      gridWalk_vertical_pair w hw (r := 1) (by simp) (by simp)
    have hx0 : x.1 = 0 := by
      have : x.1.val = 0 := by omega
      exact Fin.ext this
    have hy1 : y.1 = 1 := by
      have : y.1.val = 1 := by omega
      exact Fin.ext this
    have hxy' : y = (1, x.2) := Prod.ext hy1 hxy.symm
    have hx' : x = (0, x.2) := Prod.ext hx0 rfl
    have hcase : x.2 = 0 ∨ x.2 = 1 := by
      have hb := x.2.isLt
      have h2 : x.2.val = 0 ∨ x.2.val = 1 := by omega
      rcases h2 with h | h
      · exact Or.inl (Fin.ext h)
      · exact Or.inr (Fin.ext h)
    rcases hcase with hcase | hcase
    · left
      intro v hv
      simp only [Finset.mem_insert, Finset.mem_singleton] at hv
      rcases hv with rfl | rfl
      · rw [hx', hcase] at hx; exact hx
      · rw [hxy', hcase] at hy; exact hy
    · right
      intro v hv
      simp only [Finset.mem_insert, Finset.mem_singleton] at hv
      rcases hv with rfl | rfl
      · rw [hx', hcase] at hx; exact hx
      · rw [hxy', hcase] at hy; exact hy
  · intro h
    have hcol : ∀ c : Fin 2, η ((0 : Fin 2), c) = true → η ((1 : Fin 2), c) = true →
        η ∈ crossingEvent 2 two_pos := by
      intro c h0 h1
      obtain ⟨w, hw⟩ := gridGraph_column_walk 2 two_pos c 1 (by omega)
      refine ⟨c, c, ?_⟩
      have hstart : (⟨0, two_pos⟩, c) = ((0 : Fin 2), c) := rfl
      have hend : ((⟨1, by omega⟩ : Fin 2), c) = ((1 : Fin 2), c) := rfl
      refine ⟨w, fun x hx => ?_⟩
      have hx2 := hw x hx
      have : x.1 = 0 ∨ x.1 = 1 := by omega
      rcases this with h | h
      · rw [show x = ((0 : Fin 2), c) from Prod.ext h hx2]; exact h0
      · rw [show x = ((1 : Fin 2), c) from Prod.ext h hx2]; exact h1
    rcases h with h | h
    · exact hcol 0 (h _ (by simp)) (h _ (by simp))
    · exact hcol 1 (h _ (by simp)) (h _ (by simp))

/-- **The crossing polynomial of the `2 × 2` grid.** -/
theorem crossing_bernProb_two (p : ℝ) :
    bernProb p (crossingEvent 2 two_pos) = 2 * p ^ 2 - p ^ 4 := by
  classical
  set S₀ : Finset (Fin 2 × Fin 2) := {((0 : Fin 2), (0 : Fin 2)), ((1 : Fin 2), (0 : Fin 2))}
    with hS₀
  set S₁ : Finset (Fin 2 × Fin 2) := {((0 : Fin 2), (1 : Fin 2)), ((1 : Fin 2), (1 : Fin 2))}
    with hS₁
  have hinter : allOpenEvent S₀ ∩ allOpenEvent S₁ = allOpenEvent (S₀ ∪ S₁) := by
    ext η
    simp only [allOpenEvent, Set.mem_inter_iff, Set.mem_setOf_eq, Finset.mem_union]
    constructor
    · rintro ⟨h0, h1⟩ v (hv | hv)
      · exact h0 v hv
      · exact h1 v hv
    · intro h
      exact ⟨fun v hv => h v (Or.inl hv), fun v hv => h v (Or.inr hv)⟩
  have hunion := bernProb_union_add_inter p (allOpenEvent S₀) (allOpenEvent S₁)
  rw [crossingEvent_two_eq, ← hS₀, ← hS₁]
  rw [hinter, bernProb_allOpenEvent, bernProb_allOpenEvent, bernProb_allOpenEvent] at hunion
  have hc0 : S₀.card = 2 := by decide
  have hc1 : S₁.card = 2 := by decide
  have hcu : (S₀ ∪ S₁).card = 4 := by decide
  rw [hc0, hc1, hcu] at hunion
  linarith

/-! ## The first instances of Conjectures 1 and 2 -/

theorem crossing_bernProb_one_half :
    bernProb (1 / 2 : ℝ) (crossingEvent 1 one_pos) = 1 / 2 := by
  rw [crossing_bernProb_one]

/-- `θ_2(1/2) = 7/16`, the value quoted in Conjecture 2. -/
theorem crossing_bernProb_two_half :
    bernProb (1 / 2 : ℝ) (crossingEvent 2 two_pos) = 7 / 16 := by
  rw [crossing_bernProb_two]; norm_num

/-- `θ_2(1/2) < 1/2`: the self-duality defect at `n = 2`. -/
theorem crossing_two_half_lt_one_half :
    bernProb (1 / 2 : ℝ) (crossingEvent 2 two_pos) < 1 / 2 := by
  rw [crossing_bernProb_two_half]; norm_num

/-- `θ_2(1/2) < θ_1(1/2)`: the first step of the conjectured decay. -/
theorem crossing_two_half_lt_crossing_one_half :
    bernProb (1 / 2 : ℝ) (crossingEvent 2 two_pos) <
      bernProb (1 / 2 : ℝ) (crossingEvent 1 one_pos) := by
  rw [crossing_bernProb_two_half, crossing_bernProb_one_half]; norm_num

/-- `θ_1'(p) = 1`. -/
theorem crossing_deriv_one (p : ℝ) :
    deriv (fun p : ℝ => bernProb p (crossingEvent 1 one_pos)) p = 1 := by
  have hfun : (fun p : ℝ => bernProb p (crossingEvent 1 one_pos)) = fun p : ℝ => p :=
    funext crossing_bernProb_one
  rw [hfun, deriv_id'']

/-- `θ_2'(p) = 4p - 4p³`. -/
theorem crossing_deriv_two (p : ℝ) :
    deriv (fun p : ℝ => bernProb p (crossingEvent 2 two_pos)) p = 4 * p - 4 * p ^ 3 := by
  have hfun : (fun p : ℝ => bernProb p (crossingEvent 2 two_pos))
      = fun p : ℝ => 2 * p ^ 2 - p ^ 4 := funext crossing_bernProb_two
  rw [hfun]
  have hd : HasDerivAt (fun p : ℝ => 2 * p ^ 2 - p ^ 4) (4 * p - 4 * p ^ 3) p := by
    have h1 : HasDerivAt (fun p : ℝ => 2 * p ^ 2) (2 * (2 * p)) p := by
      simpa using ((hasDerivAt_pow 2 p).const_mul (2 : ℝ))
    have h2 : HasDerivAt (fun p : ℝ => p ^ 4) (4 * p ^ 3) p := by
      simpa using hasDerivAt_pow 4 p
    have := h1.sub h2
    convert this using 1
    ring
  exact hd.deriv

/-- `θ_1'(1/2) = 1 < 3/2 = θ_2'(1/2) ≤ 2`: the first instance of Conjecture 1,
including the bound `θ_n'(1/2) ≤ n`. -/
theorem crossing_deriv_one_half_lt_two :
    deriv (fun p : ℝ => bernProb p (crossingEvent 1 one_pos)) (1 / 2) = 1 ∧
      deriv (fun p : ℝ => bernProb p (crossingEvent 2 two_pos)) (1 / 2) = 3 / 2 ∧
        deriv (fun p : ℝ => bernProb p (crossingEvent 1 one_pos)) (1 / 2) <
          deriv (fun p : ℝ => bernProb p (crossingEvent 2 two_pos)) (1 / 2) ∧
          deriv (fun p : ℝ => bernProb p (crossingEvent 2 two_pos)) (1 / 2) ≤ 2 := by
  refine ⟨crossing_deriv_one _, ?_, ?_, ?_⟩ <;>
    rw [crossing_deriv_two] <;> try rw [crossing_deriv_one]
  · norm_num
  · norm_num
  · norm_num

/-- **The second half of Conjecture 1, in full generality.**  The Russo
derivative of the crossing probability at `p = 1/2` is at most `n` for every
`n ≥ 1`; this is the square-root law `crossing_sum_influence_le` of the catalog,
read through Russo's formula. -/
theorem crossing_deriv_half_le (n : ℕ) (hn : 0 < n) :
    deriv (fun p : ℝ => bernProb p (crossingEvent n hn)) (1 / 2 : ℝ) ≤ (n : ℝ) := by
  rw [deriv_bernProb (crossingEvent_isIncreasing n hn)]
  exact crossing_sum_influence_le n hn

end BernoulliThresholdCoupling