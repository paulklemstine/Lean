import Mathlib
import Cryptography.FactoringBarriers.HarveyBalance

/-!
# The `1/5` barrier of the baby-step/giant-step motif, derived three ways

This file builds on `Crypto.FactoringBarrier.HarveyBalance.costExp`, the exponent
`max a (max b (1/2 − a/2 − b))` of Harvey's three-term cost (`r = N^a`, `m = N^b`),
and re-derives its optimum `1/5` by three independent arguments.

1. **Slack constraint** (`slack_constraint_*`).  In any linear order, adding a
   constraint `g` to an objective `f` with optimum `v` leaves the optimum at `v`
   whenever `g ≤ v` at one optimiser of `f`; conversely, a constraint can raise
   the optimum only if it is *active* (`g > v`) at *every* optimiser.  Instantiated
   with an order-finding term of `N`-exponent `0` (any polylog power, modelled
   lexicographically), the optimum `1/5` cannot move.
2. **Delete-a-term / closed variable** (`costGen_*`, `delete_*`).  The general
   three-leg shape `max(a, c·b, γ − u·a − w·b)` has optimum exactly
   `γ / (1 + u + w/c)`; the m-leg enters only through the ratio `w / c`
   (benefit/cost).  With benefit `w ≤ c` (injectivity vs. output counting) the
   optimum is `≥ 1/5`; reaching `1/6` needs `w = (3/2)·c`.  The optimiser
   `(1/5,1/5)` is unique and deleting any one leg strictly lowers the optimum:
   all three legs are co-binding.
3. **Space–time invariant** (`space_time_invariant`).  Writing time
   `A = max(a, 1/2 − a/2 − b)` and space `C = b`, every parameter choice satisfies
   `3·A + 2·C ≥ 1` (i.e. `T³·S² ≥ N`).  A cap on space raises time; a floor on
   space never lowers it below the invariant; and `max(A, C) ≥ 1/5` follows.

`three_derivations_agree` packages the three values.
-/

namespace Catalog.Algebra.MotifBarrier.Motif

open Crypto.FactoringBarrier.HarveyBalance

/-! ## 1. The slack-constraint lemma -/

section Slack

variable {X α : Type*} [LinearOrder α]

/-- **Slack constraint, lower half.** Adding any constraint never lowers the optimum. -/
theorem slack_constraint_lower {f g : X → α} {v : α} (hlow : ∀ x, v ≤ f x) (x : X) :
    v ≤ max (f x) (g x) :=
  le_trans (hlow x) (le_max_left _ _)

/-- **Slack constraint, attainment.** If `g ≤ v` at an optimiser `x₀` of `f`,
then `max f g` still attains `v` at `x₀`. -/
theorem slack_constraint_attained {f g : X → α} {v : α} {x₀ : X} (hx₀ : f x₀ = v)
    (hslack : g x₀ ≤ v) : max (f x₀) (g x₀) = v := by
  rw [hx₀]; exact max_eq_left hslack

/-- **Slack constraint, converse ("only active constraints move the optimum").**
If the constrained problem has every value `> v`, then `g` is active at every
optimiser of `f`. -/
theorem constraint_moves_only_if_active {f g : X → α} {v : α}
    (hraise : ∀ x, v < max (f x) (g x)) : ∀ x, f x = v → v < g x := by
  intro x hx
  have := hraise x
  rw [hx] at this
  rcases lt_max_iff.mp this with h | h
  · exact absurd h (lt_irrefl _)
  · exact h

/-- **Hypothesis collapse is inert on a slack constraint.** Removing a constraint
that is slack at an optimiser of the constrained problem leaves the optimal value
unchanged: both problems have optimum exactly `v`. -/
theorem collapse_inert {f g : X → α} {v : α} (hlow : ∀ x, v ≤ f x) {x₀ : X}
    (hx₀ : f x₀ = v) (hslack : g x₀ ≤ v) :
    (∀ x, v ≤ f x) ∧ f x₀ = v ∧ (∀ x, v ≤ max (f x) (g x)) ∧ max (f x₀) (g x₀) = v :=
  ⟨hlow, hx₀, slack_constraint_lower hlow, slack_constraint_attained hx₀ hslack⟩

end Slack

/-- Harvey's exponent as a function of the pair `(a, b)`. -/
def harvey (p : ℚ × ℚ) : ℚ := costExp p.1 p.2

/-- **The order-finding term is slack.** An order-finding step of `N`-exponent `0`
(polylog cost) added to Harvey's cost leaves the optimum at exactly `1/5`. -/
theorem order_term_slack :
    (∀ a b : ℚ, 1 / 5 ≤ max (costExp a b) 0) ∧ max (costExp (1 / 5) (1 / 5)) 0 = 1 / 5 := by
  refine ⟨fun a b => ?_, ?_⟩
  · exact slack_constraint_lower (f := harvey) (g := fun _ => (0 : ℚ))
      (fun p => one_fifth_is_lower_bound p.1 p.2) (a, b)
  · exact slack_constraint_attained (f := harvey) (g := fun _ => (0 : ℚ)) (x₀ := (1/5, 1/5))
      one_fifth_attained (by norm_num)

/-- **Two-scale (exponent, log-power) version.** Costs are ordered
lexicographically: first the `N`-exponent, then the power of `lg N`.  Any
order-finding term `N^0·lg^k N`, however large `k`, is strictly below the
optimum `N^{1/5}·lg^ℓ N` for every `ℓ`: the slack is unbounded in the log scale. -/
theorem order_term_lex_slack (k ℓ : ℚ) :
    (toLex ((0 : ℚ), k) : ℚ ×ₗ ℚ) < toLex ((1 / 5 : ℚ), ℓ) := by
  rw [Prod.Lex.toLex_lt_toLex]
  left; norm_num

/-- ...hence adding it to the two-scale cost changes nothing. -/
theorem order_term_lex_absorbed (k ℓ : ℚ) :
    max (toLex ((1 / 5 : ℚ), ℓ) : ℚ ×ₗ ℚ) (toLex ((0 : ℚ), k)) = toLex ((1 / 5 : ℚ), ℓ) :=
  max_eq_left (order_term_lex_slack k ℓ).le

/-- **Any extra leg (e.g. the `M`-leg) whose exponent at `(1/5,1/5)` is at most
`1/5` is exponent-redundant.** -/
theorem extra_leg_redundant (g : ℚ → ℚ → ℚ) (hg : g (1 / 5) (1 / 5) ≤ 1 / 5) :
    (∀ a b, 1 / 5 ≤ max (costExp a b) (g a b)) ∧
      max (costExp (1 / 5) (1 / 5)) (g (1 / 5) (1 / 5)) = 1 / 5 :=
  ⟨fun a b => le_trans (one_fifth_is_lower_bound a b) (le_max_left _ _),
    slack_constraint_attained one_fifth_attained hg⟩

/-! ## 2. Delete-a-term and the closed m-variable -/

/-- The general three-leg exponent: pair-cost `a`, list-cost `c·b`, residual
search `γ − u·a − w·b`. -/
def costGen (γ u w c a b : ℚ) : ℚ := max a (max (c * b) (γ - u * a - w * b))

/-- Harvey's exponent is the instance `γ = 1/2, u = 1/2, w = 1, c = 1`. -/
theorem costGen_harvey (a b : ℚ) : costGen (1 / 2) (1 / 2) 1 1 a b = costExp a b := by
  simp [costGen, costExp]; ring_nf

/-- **Lower bound for the general three-leg shape.** -/
theorem costGen_lower {γ u w c : ℚ} (hu : 0 ≤ u) (hw : 0 ≤ w) (hc : 0 < c) (a b : ℚ) :
    γ / (1 + u + w / c) ≤ costGen γ u w c a b := by
  set m := costGen γ u w c a b with hm
  have h1 : a ≤ m := le_max_left _ _
  have h2 : c * b ≤ m := le_trans (le_max_left _ _) (le_max_right _ _)
  have h3 : γ - u * a - w * b ≤ m := le_trans (le_max_right _ _) (le_max_right _ _)
  have hD : 0 < 1 + u + w / c := by positivity
  rw [div_le_iff₀ hD]
  have hwc : w * b = (w / c) * (c * b) := by field_simp
  have h4 : (w / c) * (c * b) ≤ (w / c) * m := mul_le_mul_of_nonneg_left h2 (by positivity)
  nlinarith [mul_le_mul_of_nonneg_left h1 hu]

/-- **Attainment for the general shape.** -/
theorem costGen_attained {γ u w c : ℚ} (hu : 0 ≤ u) (hw : 0 ≤ w) (hc : 0 < c) :
    costGen γ u w c (γ / (1 + u + w / c)) (γ / (1 + u + w / c) / c) = γ / (1 + u + w / c) := by
  have hD : 0 < 1 + u + w / c := by positivity
  set v := γ / (1 + u + w / c) with hv
  have hcb : c * (v / c) = v := by field_simp
  have h3 : γ - u * v - w * (v / c) = v := by
    rw [hv]; field_simp; ring
  rw [costGen, hcb, h3]; simp

/-- **The closed m-variable.** If the m-leg's benefit weight `w` does not exceed
its cost weight `c` (injectivity: benefit `≤ 1`; output counting: cost `≥ 1`),
then no parameter choice beats `1/5`. -/
theorem closed_variable {w c : ℚ} (hw : 0 ≤ w) (hc : 0 < c) (hwc : w ≤ c) (a b : ℚ) :
    1 / 5 ≤ costGen (1 / 2) (1 / 2) w c a b := by
  have h := costGen_lower (γ := 1 / 2) (u := 1 / 2) (by norm_num) hw hc a b
  have hr : w / c ≤ 1 := (div_le_one hc).mpr hwc
  have hr0 : 0 ≤ w / c := by positivity
  refine le_trans ?_ h
  rw [le_div_iff₀ (by positivity)]
  linarith

/-- **The re-split invariance of the m-leg.** Only the ratio `w/c` matters:
rescaling the m-parameter (`b ↦ b/λ`, `c ↦ λc`, `w ↦ λw`) leaves the cost unchanged. -/
theorem costGen_resplit (γ u w c a b : ℚ) {l : ℚ} (hl : l ≠ 0) :
    costGen γ u (l * w) (l * c) a (b / l) = costGen γ u w c a b := by
  simp only [costGen]
  congr 2
  · field_simp
  · field_simp

/-- **What `1/6` would cost.** In the closed-variable family with `γ = u = 1/2`,
the optimum is `1/6` exactly when the m-leg's benefit/cost ratio is `3/2`
— impossible under `w ≤ c`. -/
theorem sixth_needs_ratio {w c : ℚ} (hw : 0 ≤ w) (hc : 0 < c) :
    (1 / 2 : ℚ) / (1 + 1 / 2 + w / c) = 1 / 6 ↔ w = 3 / 2 * c := by
  have hD : 0 < 1 + 1 / 2 + w / c := by positivity
  rw [div_eq_iff hD.ne']
  constructor
  · intro h
    have : w / c = 3 / 2 := by linarith
    field_simp at this; linarith
  · intro h; rw [h]; field_simp; ring

/-- **The optimiser `(1/5, 1/5)` is unique.** -/
theorem optimiser_unique {a b : ℚ} (h : costExp a b = 1 / 5) : a = 1 / 5 ∧ b = 1 / 5 := by
  have h1 : a ≤ 1 / 5 := h ▸ le_max_left _ _
  have h2 : b ≤ 1 / 5 := h ▸ le_trans (le_max_left _ _) (le_max_right _ _)
  have h3 : 1 / 2 - a / 2 - b ≤ 1 / 5 := h ▸ le_trans (le_max_right _ _) (le_max_right _ _)
  constructor <;> linarith

/-- **Co-binding, part 1: at the optimum all three legs are equal to `1/5`.** -/
theorem all_legs_active {a b : ℚ} (h : costExp a b = 1 / 5) :
    a = 1 / 5 ∧ b = 1 / 5 ∧ 1 / 2 - a / 2 - b = 1 / 5 := by
  obtain ⟨rfl, rfl⟩ := optimiser_unique h
  norm_num

/-- **Co-binding, part 2 (delete-a-term).** Deleting any single leg strictly lowers
the optimum below `1/5`, with parameters in the natural box `0 ≤ a, b ≤ 1/2`. -/
theorem delete_any_leg_lowers :
    max (1 / 8 : ℚ) (1 / 2 - (1 / 2) / 2 - 1 / 8) < 1 / 5 ∧   -- drop the pair leg `a`
    max (0 : ℚ) (1 / 2 - 0 / 2 - 1 / 2) < 1 / 5 ∧             -- drop the list leg `b`
    max (0 : ℚ) 0 < 1 / 5 := by                               -- drop the search leg
  norm_num

/-- **Delete-a-term, quantified form.**  Each two-leg sub-problem has value below `1/5`
somewhere in the box, so each leg is necessary for the `1/5` floor. -/
theorem delete_leg_exists :
    (∃ a b : ℚ, 0 ≤ a ∧ a ≤ 1 / 2 ∧ 0 ≤ b ∧ b ≤ 1 / 2 ∧ max b (1 / 2 - a / 2 - b) < 1 / 5) ∧
    (∃ a b : ℚ, 0 ≤ a ∧ a ≤ 1 / 2 ∧ 0 ≤ b ∧ b ≤ 1 / 2 ∧ max a (1 / 2 - a / 2 - b) < 1 / 5) ∧
    (∃ a b : ℚ, 0 ≤ a ∧ a ≤ 1 / 2 ∧ 0 ≤ b ∧ b ≤ 1 / 2 ∧ max a b < 1 / 5) :=
  ⟨⟨1 / 2, 1 / 8, by norm_num⟩, ⟨0, 1 / 2, by norm_num⟩, ⟨0, 0, by norm_num⟩⟩

/-! ## 3. The space–time invariant -/

/-- Time exponent of the motif: pairs plus residual search. -/
def timeExp (a b : ℚ) : ℚ := max a (1 / 2 - a / 2 - b)

/-- **The space–time invariant `3·A + 2·C ≥ 1`**, i.e. `T³·S² ≥ N`. -/
theorem space_time_invariant (a b : ℚ) : 1 ≤ 3 * timeExp a b + 2 * b := by
  have h1 : a ≤ timeExp a b := le_max_left _ _
  have h2 : 1 / 2 - a / 2 - b ≤ timeExp a b := le_max_right _ _
  linarith

/-- **The invariant is tight**: along `a = (1 − 2b)/3` equality holds for every `b`. -/
theorem space_time_tight (b : ℚ) :
    3 * timeExp ((1 - 2 * b) / 3) b + 2 * b = 1 := by
  have : timeExp ((1 - 2 * b) / 3) b = (1 - 2 * b) / 3 := by
    rw [timeExp]; apply max_eq_left; linarith
  rw [this]; ring

/-- **A cap on space raises time.** -/
theorem space_cap_raises_time {a b σ : ℚ} (hb : b ≤ σ) : (1 - 2 * σ) / 3 ≤ timeExp a b := by
  have := space_time_invariant a b; linarith

/-- **Sub-`1/5` time forces super-`1/5` space** — so a floor on memory never helps. -/
theorem fast_time_needs_space {a b : ℚ} (h : timeExp a b < 1 / 5) : 1 / 5 < b := by
  have := space_time_invariant a b; linarith

/-- **The invariant alone re-derives the `1/5` floor.** -/
theorem invariant_gives_one_fifth (a b : ℚ) : 1 / 5 ≤ max (timeExp a b) b := by
  have := space_time_invariant a b
  by_contra h
  push_neg at h
  have h1 : timeExp a b < 1 / 5 := lt_of_le_of_lt (le_max_left _ _) h
  have h2 : b < 1 / 5 := lt_of_le_of_lt (le_max_right _ _) h
  linarith

/-- `max (timeExp a b) b` is exactly Harvey's exponent. -/
theorem timeExp_max_eq_costExp (a b : ℚ) : max (timeExp a b) b = costExp a b := by
  simp only [timeExp, costExp]
  rw [max_assoc, max_comm (1 / 2 - a / 2 - b) b]

/-! ## The capstone: three derivations agree -/

/-- **Three independent derivations of the same `1/5`.**
(i) Harvey's lower bound together with slack of the order term;
(ii) the general three-leg optimum `γ/(1+u+w/c)` at `γ = u = 1/2, w = c = 1`;
(iii) the space–time invariant. All give a floor of exactly `1/5`, attained at the
unique optimiser `(1/5, 1/5)`. -/
theorem three_derivations_agree :
    (∀ a b : ℚ, 1 / 5 ≤ max (costExp a b) 0) ∧
    ((1 / 2 : ℚ) / (1 + 1 / 2 + 1 / 1) = 1 / 5 ∧
      ∀ a b : ℚ, (1 / 2 : ℚ) / (1 + 1 / 2 + 1 / 1) ≤ costGen (1 / 2) (1 / 2) 1 1 a b) ∧
    (∀ a b : ℚ, 1 / 5 ≤ max (timeExp a b) b) ∧
    (∀ a b : ℚ, costExp a b = 1 / 5 ↔ a = 1 / 5 ∧ b = 1 / 5) := by
  refine ⟨order_term_slack.1, ⟨by norm_num, fun a b =>
    costGen_lower (by norm_num) (by norm_num) (by norm_num) a b⟩,
    invariant_gives_one_fifth, fun a b => ⟨optimiser_unique, ?_⟩⟩
  rintro ⟨rfl, rfl⟩
  exact one_fifth_attained

end Catalog.Algebra.MotifBarrier.Motif