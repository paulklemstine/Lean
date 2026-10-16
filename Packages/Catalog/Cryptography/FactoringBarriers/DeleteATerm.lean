import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.LinearCombination
import Mathlib.Tactic.FieldSimp
import Cryptography.FactoringBarriers.HarveyBalance

/-!
# Round 34: the delete-a-term screen, the redundant M-leg, and the load-bearing `m`

`HarveyBalance.lean` reads Harvey's Proposition 4.3 as the three-term exponent
minimax `costExp a b = max a (max b (1/2 - a/2 - b))` (`r = N^a`, `m = N^b`) and
proves its optimum is exactly `1/5`.  Round 33 added a fourth, smoothness-sieve
term `M^{1/2} = (N/r)^{1/4}`, of exponent `(1 - a)/4`.  This file settles what
that fourth term is worth, and turns the method used into a general tool.

## The general tool

* `delete_a_term_screen` — **the screening rule.**  For any parameter space `X`
  and any terms `F'`, a bound `c` survives *every* replacement `g'` of an extra
  term (including making it free) iff `c` is already a bound for `F'` alone.
* `term_worth_optimising_iff` — the contrapositive form: some modification of a
  term can push the minimax below `v` iff deleting that term already does.
* `inert_term_preserves_value` — an added term that is `≤ v` at one optimiser of
  the remaining terms leaves the minimax value exactly `v`.

## The M-leg (Headline 1)

With `costM θ a b = max (costExp a b) (θ·(1 - a))` (smoothness leg `(N/r)^θ`):

* `mleg_value_of_le` — for `0 ≤ θ ≤ 1/4` the value is **exactly `1/5`**: the leg
  is exponent-redundant.  This covers the actual leg `θ = 1/4`, the free leg
  `θ = 0` (`mleg_free_value`), and deletion (`HarveyBalance.optimum_exactly_one_fifth`).
* `mleg_value_of_ge` — for `θ ≥ 1/4` the value is exactly `θ/(1+θ)`: the full
  parametric value is `max(1/5, θ/(1+θ))`.
* `mleg_breakpoint` — for `θ > 1/4` **no** point reaches `1/5`.
* `mleg_cotight` — at the (unique, `costExp_unique_optimum`) optimum the actual
  leg equals `1/5`: it is *active* yet *redundant* — the real leg sits exactly on
  the breakpoint `θ = 1/4`.

## Which terms are load-bearing

Over the box `0 ≤ a, b ≤ 1`, deleting the interior, the pair term or the
baby-step term drops the value to `0` (`delete_interior_value`,
`delete_pairs_value`, `delete_babystep_value`); deleting the M-leg does not move
it.  `load_bearing_classification` packages this: **exactly three of the four
terms carry the exponent.**

## The `m`-reuse is load-bearing (Headline 2)

* `no_split_is_lehman` — removing the baby-step split (`m = 1`, `b = 0`) leaves
  exponent `≥ 1/3`.
* `babystep_must_balance` — every `b ≠ 1/5` gives cost `> 1/5` for every `a`.
* `collapse_value` / `collapse_penalty` — in the collapse-coupling model, where
  the `(a,b)`-grid and the interior are swept together by one Strassen-type
  product tree (cost the square root of the joint search space
  `r · N^{1/2}/r^{1/2}`), the exponent is `max(a, 1/4 + a/4)`, whose optimum is
  `1/4`; the penalty against `1/5` is exactly `1/20`.

## Screening the next target (the `m`-leg)

* `babyDiscount_value` — an `m^{1-ε}` baby-step list would give exactly
  `(1-ε)/(5-3ε) < 1/5` (`babyDiscount_beats_fifth`): the `m`-leg has leverage.
* `interiorGain_value` — an `N^{-δ}` interior gain gives exactly `(1-2δ)/5`.
* `flagged_target_misstated` / `flagged_target_below_floor` — the proposed target
  `T = N^{(1/2-δ)/5}` is off by a factor of two (at `δ = 0` it claims `1/10`,
  below the proven floor `1/5` of the model).
* `lever_exchange_rate` — an `m`-discount `ε` is worth an interior gain
  `δ = ε/(5-3ε)`.

Honest limits.  These are statements about exponent minimax models, with log
factors dropped.  The `0.046–0.052` fitted slope of the round-34 experiment is
recorded in `ComputationalEvidence.md` as reported data; it is not machine-checked
here.  `1/5` is an upper bound for factoring, never a floor.
-/

namespace Crypto.FactoringBarrier.DeleteATerm

open Crypto.FactoringBarrier.HarveyBalance

/-! ## The general screening tool -/

/-- `c` is a lower bound for the minimax of `F` over the parameter space. -/
def MinimaxLB {X : Type*} (F : X → ℚ) (c : ℚ) : Prop := ∀ x, c ≤ F x

/-- `v` is the minimax value of `F`: a lower bound that is attained. -/
def IsMinimaxValue {X : Type*} (F : X → ℚ) (v : ℚ) : Prop :=
  MinimaxLB F v ∧ ∃ x, F x = v

/-- The minimax value is unique. -/
theorem IsMinimaxValue.unique {X : Type*} {F : X → ℚ} {v w : ℚ}
    (hv : IsMinimaxValue F v) (hw : IsMinimaxValue F w) : v = w := by
  obtain ⟨hv1, x, hx⟩ := hv
  obtain ⟨hw1, y, hy⟩ := hw
  have h1 := hv1 y
  have h2 := hw1 x
  linarith

/-- **★ THE DELETE-A-TERM SCREEN.** A lower bound `c` survives *every* choice of
the extra term `g'` — shrinking it, reshaping it, making it free — iff `c` is a
lower bound for the remaining terms `F'` alone.  So a term whose deletion does not
move the minimax is worth nothing to optimise, whatever its size. -/
theorem delete_a_term_screen {X : Type*} (F' : X → ℚ) (c : ℚ) :
    (∀ g' : X → ℚ, MinimaxLB (fun x => max (F' x) (g' x)) c) ↔ MinimaxLB F' c := by
  constructor
  · intro h x
    have := h F' x
    simpa using this
  · intro h g' x
    exact le_trans (h x) (le_max_left _ _)

/-- **The screen, positive form.** Some modification `g'` of a term brings the
minimax strictly below `v` iff deleting the term already does. -/
theorem term_worth_optimising_iff {X : Type*} (F' : X → ℚ) (v : ℚ) :
    (∃ g' : X → ℚ, ∃ x, max (F' x) (g' x) < v) ↔ ∃ x, F' x < v := by
  constructor
  · rintro ⟨g', x, hx⟩
    exact ⟨x, lt_of_le_of_lt (le_max_left _ _) hx⟩
  · rintro ⟨x, hx⟩
    exact ⟨F', x, by simpa using hx⟩

/-- **An inert term preserves the value.** If `v` is the minimax value of `F'`,
attained at `x₀`, and the extra term satisfies `g x₀ ≤ v`, then `max F' g` has
value exactly `v`. -/
theorem inert_term_preserves_value {X : Type*} (F' g : X → ℚ) (v : ℚ) (x₀ : X)
    (hlb : MinimaxLB F' v) (hx₀ : F' x₀ = v) (hg : g x₀ ≤ v) :
    IsMinimaxValue (fun x => max (F' x) (g x)) v :=
  ⟨fun x => le_trans (hlb x) (le_max_left _ _), x₀, by
    show max (F' x₀) (g x₀) = v
    rw [hx₀]; exact max_eq_left hg⟩

/-- **Adding a term never lowers a value** (monotonicity of the minimax). -/
theorem add_term_monotone {X : Type*} (F' g : X → ℚ) (v w : ℚ)
    (hF : IsMinimaxValue F' v) (hFg : IsMinimaxValue (fun x => max (F' x) (g x)) w) :
    v ≤ w := by
  obtain ⟨_, x, hx⟩ := hFg
  have := hF.1 x
  have h2 : F' x ≤ max (F' x) (g x) := le_max_left _ _
  linarith

/-! ## The three-term Harvey minimax: uniqueness of the optimum -/

/-- **The optimum of the three-term balance is unique.** If `costExp a b ≤ 1/5`
then `a = b = 1/5`. -/
theorem costExp_unique_optimum (a b : ℚ) (h : costExp a b ≤ 1 / 5) :
    a = 1 / 5 ∧ b = 1 / 5 := by
  simp only [costExp, max_le_iff] at h
  obtain ⟨ha, hb, hi⟩ := h
  constructor <;> linarith

/-- The three-term Harvey minimax as an `IsMinimaxValue` statement. -/
theorem costExp_value : IsMinimaxValue (fun x : ℚ × ℚ => costExp x.1 x.2) (1 / 5) :=
  ⟨fun x => one_fifth_is_lower_bound x.1 x.2, (1 / 5, 1 / 5), one_fifth_attained⟩

/-! ## The M-leg -/

/-- The four-term cost with a smoothness leg `(N/r)^θ`, i.e. exponent `θ·(1-a)`.
The round-33 M-leg `M^{1/2} = (N/r)^{1/4}` is `θ = 1/4`. -/
def costM (θ a b : ℚ) : ℚ := max (costExp a b) (θ * (1 - a))

/-- **★ HEADLINE 1: THE M-LEG IS EXPONENT-REDUNDANT.** For every `0 ≤ θ ≤ 1/4`,
the four-term minimax is exactly `1/5` — the same as with the leg deleted. -/
theorem mleg_value_of_le (θ : ℚ) (hθ : θ ≤ 1 / 4) :
    IsMinimaxValue (fun x : ℚ × ℚ => costM θ x.1 x.2) (1 / 5) := by
  refine inert_term_preserves_value (fun x : ℚ × ℚ => costExp x.1 x.2)
    (fun x => θ * (1 - x.1)) (1 / 5) (1 / 5, 1 / 5) costExp_value.1 one_fifth_attained ?_
  show θ * (1 - 1 / 5) ≤ 1 / 5
  linarith

/-- The actual round-33 M-leg (`θ = 1/4`) leaves the value at `1/5`. -/
theorem mleg_actual_value :
    IsMinimaxValue (fun x : ℚ × ℚ => costM (1 / 4) x.1 x.2) (1 / 5) :=
  mleg_value_of_le _ le_rfl

/-- The M-leg made completely free (`M⁰`, exponent `0`) also leaves `1/5`. -/
theorem mleg_free_value :
    IsMinimaxValue (fun x : ℚ × ℚ => costM 0 x.1 x.2) (1 / 5) :=
  mleg_value_of_le _ (by norm_num)

/-- **The full parametric value above the breakpoint.** For `θ ≥ 1/4` the minimax
is exactly `θ/(1+θ)`, attained at `a = θ/(1+θ)`, `b = (1-a)/4`. -/
theorem mleg_value_of_ge (θ : ℚ) (hθ : 1 / 4 ≤ θ) :
    IsMinimaxValue (fun x : ℚ × ℚ => costM θ x.1 x.2) (θ / (1 + θ)) := by
  have hpos : (0 : ℚ) < 1 + θ := by linarith
  refine ⟨fun x => ?_, (θ / (1 + θ), (1 - θ / (1 + θ)) / 4), ?_⟩
  · show θ / (1 + θ) ≤ max (costExp x.1 x.2) (θ * (1 - x.1))
    rw [div_le_iff₀ hpos]
    have h1 : x.1 ≤ max (costExp x.1 x.2) (θ * (1 - x.1)) :=
      le_trans (le_max_left _ _) (le_max_left _ _)
    have h2 : θ * (1 - x.1) ≤ max (costExp x.1 x.2) (θ * (1 - x.1)) := le_max_right _ _
    nlinarith
  · show max (max (θ / (1 + θ)) (max ((1 - θ / (1 + θ)) / 4)
        (1 / 2 - θ / (1 + θ) / 2 - (1 - θ / (1 + θ)) / 4))) (θ * (1 - θ / (1 + θ)))
        = θ / (1 + θ)
    have e1 : 1 / 2 - θ / (1 + θ) / 2 - (1 - θ / (1 + θ)) / 4 = (1 - θ / (1 + θ)) / 4 := by
      ring
    have e2 : θ * (1 - θ / (1 + θ)) = θ / (1 + θ) := by
      field_simp; ring
    have hb : (1 - θ / (1 + θ)) / 4 ≤ θ / (1 + θ) := by
      rw [div_le_iff₀ (by norm_num : (0 : ℚ) < 4), sub_le_iff_le_add]
      have : 1 ≤ θ / (1 + θ) * 4 + θ / (1 + θ) := by
        rw [show θ / (1 + θ) * 4 + θ / (1 + θ) = 5 * θ / (1 + θ) by ring,
          le_div_iff₀ hpos]
        linarith
      linarith
    rw [e1, e2, max_self, max_eq_left hb, max_self]

/-- **The breakpoint is strict.** For `θ > 1/4`, *no* parameter choice reaches
`1/5`: the leg would then move the value, so it would be worth attacking. -/
theorem mleg_breakpoint (θ : ℚ) (hθ : 1 / 4 < θ) (a b : ℚ) : 1 / 5 < costM θ a b := by
  by_contra h
  push_neg at h
  have h1 : costExp a b ≤ 1 / 5 := le_trans (le_max_left _ _) h
  have h2 : θ * (1 - a) ≤ 1 / 5 := le_trans (le_max_right _ _) h
  obtain ⟨ha, -⟩ := costExp_unique_optimum a b h1
  rw [ha] at h2
  linarith

/-- **The real M-leg is co-tight.** At the unique optimum `a = b = 1/5`, the
actual leg `(N/r)^{1/4}` has exponent exactly `1/5`: it is active at the optimum,
yet deleting it does not move the value. Size, and even tightness, are not
leverage. -/
theorem mleg_cotight : (1 / 4 : ℚ) * (1 - 1 / 5) = 1 / 5 ∧
    ∀ a b : ℚ, costExp a b = 1 / 5 → (1 / 4 : ℚ) * (1 - a) = 1 / 5 := by
  refine ⟨by norm_num, fun a b h => ?_⟩
  obtain ⟨ha, -⟩ := costExp_unique_optimum a b h.le
  rw [ha]; norm_num

/-- **The parametric value function** `V(θ) = max(1/5, θ/(1+θ))` for `θ ≥ 0`:
flat (redundant leg) up to the breakpoint `θ = 1/4`, then strictly increasing. -/
theorem mleg_value_function (θ : ℚ) (hθ : 0 ≤ θ) :
    IsMinimaxValue (fun x : ℚ × ℚ => costM θ x.1 x.2) (max (1 / 5) (θ / (1 + θ))) := by
  have hpos : (0 : ℚ) < 1 + θ := by linarith
  rcases le_total θ (1 / 4) with h | h
  · have : θ / (1 + θ) ≤ 1 / 5 := by
      rw [div_le_iff₀ hpos]; linarith
    rw [max_eq_left this]; exact mleg_value_of_le θ h
  · have : 1 / 5 ≤ θ / (1 + θ) := by
      rw [le_div_iff₀ hpos]; linarith
    rw [max_eq_right this]; exact mleg_value_of_ge θ h

/-! ## Which terms are load-bearing (over the box `0 ≤ a, b ≤ 1`) -/

/-- The parameter box `0 ≤ a ≤ 1`, `0 ≤ b ≤ 1` (`1 ≤ r, m ≤ N`). -/
def Box : Type := {x : ℚ × ℚ // 0 ≤ x.1 ∧ x.1 ≤ 1 ∧ 0 ≤ x.2 ∧ x.2 ≤ 1}

/-- Delete the interior `N^{1/2}/(r^{1/2}m)`: value drops to `0`. -/
theorem delete_interior_value :
    IsMinimaxValue (fun x : Box => max x.1.1 x.1.2) 0 :=
  ⟨fun x => le_trans x.2.1 (le_max_left _ _),
    ⟨(0, 0), by norm_num, by norm_num, by norm_num, by norm_num⟩, by simp⟩

/-- Delete the pair term `r`: value drops to `0`. -/
theorem delete_pairs_value :
    IsMinimaxValue (fun x : Box => max x.1.2 (1 / 2 - x.1.1 / 2 - x.1.2)) 0 :=
  ⟨fun x => le_trans x.2.2.2.1 (le_max_left _ _),
    ⟨(1, 0), by norm_num, by norm_num, by norm_num, by norm_num⟩, by norm_num⟩

/-- Delete (make free) the baby-step term `m`: value drops to `0` — this is the
"free `m` is Lehman with a free `j`-loop" degenerate case. -/
theorem delete_babystep_value :
    IsMinimaxValue (fun x : Box => max x.1.1 (1 / 2 - x.1.1 / 2 - x.1.2)) 0 :=
  ⟨fun x => le_trans x.2.1 (le_max_left _ _),
    ⟨(0, 1 / 2), by norm_num, by norm_num, by norm_num, by norm_num⟩, by norm_num⟩

/-- On the box, the three-term and four-term costs both have value `1/5`. -/
theorem box_full_value :
    IsMinimaxValue (fun x : Box => costExp x.1.1 x.1.2) (1 / 5) ∧
    IsMinimaxValue (fun x : Box => costM (1 / 4) x.1.1 x.1.2) (1 / 5) := by
  have hpt : (0 : ℚ) ≤ 1 / 5 ∧ (1 / 5 : ℚ) ≤ 1 ∧ (0 : ℚ) ≤ 1 / 5 ∧ (1 / 5 : ℚ) ≤ 1 := by
    norm_num
  refine ⟨⟨fun x => one_fifth_is_lower_bound _ _, ⟨(1 / 5, 1 / 5), hpt⟩, one_fifth_attained⟩,
    ⟨fun x => le_trans (one_fifth_is_lower_bound _ _) (le_max_left _ _),
      ⟨(1 / 5, 1 / 5), hpt⟩, ?_⟩⟩
  show max (costExp (1 / 5) (1 / 5)) (1 / 4 * (1 - 1 / 5)) = 1 / 5
  rw [one_fifth_attained]; norm_num

/-- **★ THE LOAD-BEARING CLASSIFICATION.** Of the four terms
`{interior, r, m, M}`, deleting any of the first three moves the value
(`1/5 → 0`), while deleting `M` leaves it at `1/5`. By the delete-a-term screen,
exactly three of the four terms carry the exponent; the M-leg is a co-leader only
in polylog weight. -/
theorem load_bearing_classification :
    (∃ x : Box, max x.1.1 x.1.2 < 1 / 5) ∧
    (∃ x : Box, max x.1.2 (1 / 2 - x.1.1 / 2 - x.1.2) < 1 / 5) ∧
    (∃ x : Box, max x.1.1 (1 / 2 - x.1.1 / 2 - x.1.2) < 1 / 5) ∧
    (∀ g' : Box → ℚ, ∀ x : Box, 1 / 5 ≤ max (costExp x.1.1 x.1.2) (g' x)) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · obtain ⟨x, hx⟩ := delete_interior_value.2; exact ⟨x, by simp only at hx; rw [hx]; norm_num⟩
  · obtain ⟨x, hx⟩ := delete_pairs_value.2; exact ⟨x, by simp only at hx; rw [hx]; norm_num⟩
  · obtain ⟨x, hx⟩ := delete_babystep_value.2; exact ⟨x, by simp only at hx; rw [hx]; norm_num⟩
  · exact (delete_a_term_screen (fun x : Box => costExp x.1.1 x.1.2) (1 / 5)).2
      (fun x => one_fifth_is_lower_bound _ _)

/-! ## The `m`-reuse is load-bearing -/

/-- **No baby-step split is Lehman.** With `m = 1` (`b = 0`), the exponent is at
least `1/3` for every `r`. -/
theorem no_split_is_lehman (a : ℚ) : 1 / 3 ≤ costExp a 0 := by
  simp only [costExp]
  rcases le_total a (1 / 3) with h | h
  · exact le_trans (by linarith) (le_trans (le_max_right _ _) (le_max_right _ _))
  · exact le_trans h (le_max_left _ _)

/-- ...and `1/3` is attained at `r = N^{1/3}`: Lehman's exponent exactly. -/
theorem no_split_value : costExp (1 / 3) 0 = 1 / 3 := by
  norm_num [costExp]

/-- **The baby-step term must be exactly balanced.** If `m ≠ N^{1/5}` then every
`r` gives cost strictly above `1/5`. -/
theorem babystep_must_balance (b : ℚ) (hb : b ≠ 1 / 5) (a : ℚ) : 1 / 5 < costExp a b := by
  rcases lt_or_eq_of_le (one_fifth_is_lower_bound a b) with h | h
  · exact h
  · exact absurd (costExp_unique_optimum a b h.symm.le).2 hb

/-- The collapse-coupling model: one Strassen-type product tree sweeps the joint
space `r × N^{1/2}/r^{1/2}` of size `N^{1/2}r^{1/2}` at square-root cost,
exponent `1/4 + a/4`, alongside the pair enumeration `a`. -/
def collapseExp (a : ℚ) : ℚ := max a (1 / 4 + a / 4)

/-- **The collapse coupling has optimum exactly `1/4`** over `r ≥ 1` (`a ≥ 0`). -/
theorem collapse_value :
    IsMinimaxValue (fun x : {a : ℚ // 0 ≤ a} => collapseExp x.1) (1 / 4) := by
  refine ⟨fun x => ?_, ⟨0, le_rfl⟩, by norm_num [collapseExp]⟩
  have := x.2
  exact le_trans (by linarith) (le_max_right _ _)

/-- **★ HEADLINE 2: the penalty is exactly `N^{1/20}`.** Removing the baby-step
split degrades the 3-term balance (`1/5`) to the 2-term collapse (`1/4`); the
penalty `1/4 - 1/5 = 1/20` is strictly positive, so the `m`-reuse is load-bearing. -/
theorem collapse_penalty :
    ∀ v w : ℚ, IsMinimaxValue (fun x : {a : ℚ // 0 ≤ a} => collapseExp x.1) v →
      IsMinimaxValue (fun x : ℚ × ℚ => costExp x.1 x.2) w → v - w = 1 / 20 := by
  intro v w hv hw
  rw [hv.unique collapse_value, hw.unique costExp_value]
  norm_num

/-! ## Screening the next target: the baby-step `m`-leg

The delete-a-term screen says `m` *is* worth attacking (deleting it moves the
value).  Here is what an attack on it would buy, computed exactly before any round
is spent on it. -/

/-- Harvey's balance with the baby-step leg discounted to `m^{1-ε}`. -/
def babyDiscountExp (ε a b : ℚ) : ℚ := max a (max ((1 - ε) * b) (1 / 2 - a / 2 - b))

/-- **Value of an `m`-leg discount.** If the baby-step list could be built in
`m^{1-ε}` (`0 ≤ ε < 1`), the optimum would be exactly `(1-ε)/(5-3ε)` — strictly
below `1/5` for every `ε > 0`, so this leg has genuine leverage. -/
theorem babyDiscount_value (ε : ℚ) (hε : ε < 1) :
    IsMinimaxValue (fun x : ℚ × ℚ => babyDiscountExp ε x.1 x.2) ((1 - ε) / (5 - 3 * ε)) := by
  have h1 : (0 : ℚ) < 1 - ε := by linarith
  have h5 : (0 : ℚ) < 5 - 3 * ε := by linarith
  refine ⟨fun x => ?_, ((1 - ε) / (5 - 3 * ε), 1 / (5 - 3 * ε)), ?_⟩
  · show (1 - ε) / (5 - 3 * ε) ≤ max x.1 (max ((1 - ε) * x.2) (1 / 2 - x.1 / 2 - x.2))
    set v := max x.1 (max ((1 - ε) * x.2) (1 / 2 - x.1 / 2 - x.2))
    have ha : x.1 ≤ v := le_max_left _ _
    have hb : (1 - ε) * x.2 ≤ v := le_trans (le_max_left _ _) (le_max_right _ _)
    have hi : 1 / 2 - x.1 / 2 - x.2 ≤ v := le_trans (le_max_right _ _) (le_max_right _ _)
    rw [div_le_iff₀ h5]
    nlinarith
  · show max ((1 - ε) / (5 - 3 * ε)) (max ((1 - ε) * (1 / (5 - 3 * ε)))
        (1 / 2 - (1 - ε) / (5 - 3 * ε) / 2 - 1 / (5 - 3 * ε))) = (1 - ε) / (5 - 3 * ε)
    have e1 : (1 - ε) * (1 / (5 - 3 * ε)) = (1 - ε) / (5 - 3 * ε) := by ring
    have e2 : 1 / 2 - (1 - ε) / (5 - 3 * ε) / 2 - 1 / (5 - 3 * ε) = (1 - ε) / (5 - 3 * ε) := by
      have key : (5 - 3 * ε)⁻¹ * (5 - 3 * ε) = 1 := inv_mul_cancel₀ h5.ne'
      linear_combination (-1 / 2 : ℚ) * key
    rw [e1, e2, max_self, max_self]

/-- Any genuine discount strictly beats `1/5`. -/
theorem babyDiscount_beats_fifth (ε : ℚ) (h0 : 0 < ε) (hε : ε < 1) :
    (1 - ε) / (5 - 3 * ε) < 1 / 5 := by
  rw [div_lt_div_iff₀ (by linarith) (by norm_num)]
  linarith

/-- Harvey's balance with the BSGS interior shrunk by `N^{-δ}`. -/
def interiorGainExp (δ a b : ℚ) : ℚ := max a (max b (1 / 2 - δ - a / 2 - b))

/-- **Value of an interior gain.** Shrinking the interior to `N^{1/2-δ}/(r^{1/2}m)`
gives optimum exactly `(1-2δ)/5 = (1/2-δ)/(5/2)`. -/
theorem interiorGain_value (δ : ℚ) :
    IsMinimaxValue (fun x : ℚ × ℚ => interiorGainExp δ x.1 x.2) ((1 - 2 * δ) / 5) := by
  refine ⟨fun x => ?_, ((1 - 2 * δ) / 5, (1 - 2 * δ) / 5), ?_⟩
  · show (1 - 2 * δ) / 5 ≤ max x.1 (max x.2 (1 / 2 - δ - x.1 / 2 - x.2))
    have ha : x.1 ≤ max x.1 (max x.2 (1 / 2 - δ - x.1 / 2 - x.2)) := le_max_left _ _
    have hb : x.2 ≤ max x.1 (max x.2 (1 / 2 - δ - x.1 / 2 - x.2)) :=
      le_trans (le_max_left _ _) (le_max_right _ _)
    have hi : 1 / 2 - δ - x.1 / 2 - x.2 ≤ max x.1 (max x.2 (1 / 2 - δ - x.1 / 2 - x.2)) :=
      le_trans (le_max_right _ _) (le_max_right _ _)
    linarith
  · show max ((1 - 2 * δ) / 5) (max ((1 - 2 * δ) / 5)
        (1 / 2 - δ - (1 - 2 * δ) / 5 / 2 - (1 - 2 * δ) / 5)) = (1 - 2 * δ) / 5
    have e : 1 / 2 - δ - (1 - 2 * δ) / 5 / 2 - (1 - 2 * δ) / 5 = (1 - 2 * δ) / 5 := by ring
    rw [e, max_self, max_self]

/-- **The flagged target `T = N^{(1/2-δ)/5}` is misstated by a factor of two.**
The correct value of an interior gain is `(1-2δ)/5 = 2·(1/2-δ)/5`; the proposed
formula is half of it for every `δ ≠ 1/2`, and at `δ = 0` it would claim `1/10`,
which `HarveyBalance.one_fifth_is_lower_bound` excludes. -/
theorem flagged_target_misstated (δ : ℚ) (hδ : δ ≠ 1 / 2) :
    (1 - 2 * δ) / 5 = 2 * ((1 / 2 - δ) / 5) ∧ (1 / 2 - δ) / 5 ≠ (1 - 2 * δ) / 5 := by
  refine ⟨by ring, fun h => hδ ?_⟩
  linarith

/-- At `δ = 0` the misstated formula undercuts the proven floor of the model. -/
theorem flagged_target_below_floor : (1 / 2 - 0 : ℚ) / 5 < 1 / 5 ∧
    ∀ a b : ℚ, (1 / 2 - 0 : ℚ) / 5 < costExp a b := by
  refine ⟨by norm_num, fun a b => lt_of_lt_of_le (by norm_num) (one_fifth_is_lower_bound a b)⟩

/-- **Exchange rate of the two levers.** An `m`-leg discount `ε` and an interior
gain `δ` give the same exponent exactly at `δ = ε/(5-3ε)`: the discount `ε` is worth
the interior gain `δ = ε/(5-3ε)`. -/
theorem lever_exchange_rate (ε : ℚ) (hε : ε < 1) :
    (1 - 2 * (ε / (5 - 3 * ε))) / 5 = (1 - ε) / (5 - 3 * ε) := by
  have h5 : (5 - 3 * ε) ≠ 0 := by linarith
  have key : (5 - 3 * ε)⁻¹ * (5 - 3 * ε) = 1 := inv_mul_cancel₀ h5
  rw [eq_div_iff h5]
  linear_combination (-2 / 5 : ℚ) * ε * key

end Crypto.FactoringBarrier.DeleteATerm