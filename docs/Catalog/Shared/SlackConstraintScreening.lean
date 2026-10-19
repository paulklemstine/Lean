import Mathlib

/-!
# The slack-constraint lemma and the corrected Harvey pair-filter target

This file formalises §1, §2 and §4 of the round-33 corrections note.

## Catalog anchor

The three-term exponent model is the one read off Harvey (arXiv:2010.05450,
Prop. 4.3) in `Catalog/Cryptography/FactoringBarriers/HarveyBalance.lean`:

`costExp a b = max a (max b (1/2 - a/2 - b))`,  `r = N^a`, `m = N^b`,

with `T₁ = 1/2 - a/2 - b` (Fermat-gap / giant-step sweep), `T₂ = a` (the `(a,b)`
pairs), `T₃ = b` (the baby-step table).  That file proves the optimum is `1/5`.
The catalog libraries are not importable from one another under the current
lakefile layout, so the model is restated here verbatim (`harveyExp`) and over
`ℝ` (so that convex analysis applies).

## Results

* `slack_constraint_lemma` — **the slack-constraint lemma.**  If `f` is convex on
  a convex set `A`, `x` minimises `f` on `A ∩ C`, and the constraint set `C` is a
  neighbourhood of `x` (the constraint is *slack* at the optimum), then `x`
  already minimises `f` on all of `A`: dropping the constraint `C` (the
  hypothesis "fell") cannot lower the optimum.
* `slack_constraint_value_unchanged` — the same, phrased as equality of optimal
  values.
* `harveyExp_convex`, `harvey_baby_step_ceiling_slack` — Harvey's model is convex,
  and the baby-step ceiling `b ≤ 2/5` is slack at the optimum `(1/5,1/5)`.
* `harvey_ceiling_phase_diagram` — the exact optimal exponent under a ceiling
  `b ≤ c`: it is `1/5` for every `c ≥ 1/5` (slack regime) and `(1 - 2c)/3 > 1/5`
  for `c < 1/5` (active regime).  So the ceiling transmits to the exponent iff it
  is active, i.e. iff `c < 1/5`.
* `filteredExp_optimum` — a filter dividing the pair term `T₂` by `N^{σ₂}` and
  the sweep term `T₁` by `N^{σ₁}` gives optimum exactly `1/5 - σ₂/5 - 2σ₁/5`.
* `pair_only_filter_needs_sixth` / `pair_and_sweep_filter_needs_eighteenth` — the
  corrected sieve target: if the filter divides only the pair term the rate is
  `1/5 - σ/5`, and reaching `1/6` needs `σ = 1/6`; the record's `σ = 1/18` is
  exactly the target for a filter that divides *both* `T₁` and `T₂`.
* `filteredExp_optimum_unique` — at the optimum all three terms are equal
  (co-dominance), and the optimiser is unique.

## Honest limits

Log factors are dropped (exponent-level model).  The `lg^{0.8}N` figure quoted in
the note for the slack is not reproduced: at exponent level the ceiling `N^{2/5}`
exceeds the requirement `N^{1/5}` by a factor `N^{1/5}`, i.e. the slack is far
larger than any power of `lg N`.  Which terms a concrete filter divides is a
modelling input, not something proved here.
-/

namespace SlackConstraint

open Set Filter Topology

/-! ## 1. The slack-constraint lemma -/

/-- **Slack-constraint lemma.** Let `f` be convex on a convex set `A` in a real
topological vector space.  Suppose `x ∈ A ∩ C` minimises `f` on `A ∩ C`, and the
constraint is slack at `x`: `C` is a neighbourhood of `x`.  Then `x` minimises
`f` on the whole of `A` — removing the constraint cannot improve the optimum. -/
theorem slack_constraint_lemma {E : Type*} [AddCommGroup E] [TopologicalSpace E] [Module ℝ E]
    [IsTopologicalAddGroup E] [ContinuousSMul ℝ E]
    {A C : Set E} {f : E → ℝ} {x : E}
    (hconv : ConvexOn ℝ A f) (hxA : x ∈ A) (hslack : C ∈ 𝓝 x)
    (hmin : ∀ y ∈ A ∩ C, f x ≤ f y) :
    ∀ y ∈ A, f x ≤ f y := by
  have hloc : IsLocalMinOn f A x := by
    have : A ∩ C ∈ 𝓝[A] x := inter_mem_nhdsWithin A hslack
    filter_upwards [this] with y hy using hmin y hy
  exact fun y hy => IsMinOn.of_isLocalMinOn_of_convexOn hxA hloc hconv hy

/-- Value form: under the slack hypothesis, the constrained and unconstrained
optimal values coincide (both equal `f x`). -/
theorem slack_constraint_value_unchanged {E : Type*} [AddCommGroup E] [TopologicalSpace E]
    [Module ℝ E] [IsTopologicalAddGroup E] [ContinuousSMul ℝ E]
    {A C : Set E} {f : E → ℝ} {x : E}
    (hconv : ConvexOn ℝ A f) (hxA : x ∈ A) (hxC : x ∈ C) (hslack : C ∈ 𝓝 x)
    (hmin : ∀ y ∈ A ∩ C, f x ≤ f y) :
    sInf (f '' A) = f x ∧ sInf (f '' (A ∩ C)) = f x := by
  have hglob := slack_constraint_lemma hconv hxA hslack hmin
  constructor
  · apply le_antisymm
    · exact csInf_le ⟨f x, by rintro _ ⟨y, hy, rfl⟩; exact hglob y hy⟩ ⟨x, hxA, rfl⟩
    · exact le_csInf ⟨f x, x, hxA, rfl⟩ (by rintro _ ⟨y, hy, rfl⟩; exact hglob y hy)
  · apply le_antisymm
    · exact csInf_le ⟨f x, by rintro _ ⟨y, hy, rfl⟩; exact hmin y hy⟩ ⟨x, ⟨hxA, hxC⟩, rfl⟩
    · exact le_csInf ⟨f x, x, ⟨hxA, hxC⟩, rfl⟩ (by rintro _ ⟨y, hy, rfl⟩; exact hmin y hy)

/-! ## 2. Harvey's three-term model and the baby-step ceiling -/

/-- Harvey's exponent model (`HarveyBalance.costExp`, restated over `ℝ` on
`ℝ × ℝ`): `p = (a, b)` with `r = N^a`, `m = N^b`. -/
noncomputable def harveyExp (p : ℝ × ℝ) : ℝ := max p.1 (max p.2 (1 / 2 - p.1 / 2 - p.2))

theorem harveyExp_convex : ConvexOn ℝ univ harveyExp := by
  have h1 : ConvexOn ℝ univ (fun p : ℝ × ℝ => p.1) :=
    (LinearMap.fst ℝ ℝ ℝ).convexOn convex_univ
  have h2 : ConvexOn ℝ univ (fun p : ℝ × ℝ => p.2) :=
    (LinearMap.snd ℝ ℝ ℝ).convexOn convex_univ
  have h3 : ConvexOn ℝ univ (fun p : ℝ × ℝ => 1 / 2 - p.1 / 2 - p.2) := by
    refine ⟨convex_univ, ?_⟩
    intro x _ y _ s t hs ht hst
    simp only [Prod.fst_add, Prod.snd_add, Prod.smul_fst, Prod.smul_snd, smul_eq_mul]
    have : (1 / 2 : ℝ) = s * (1 / 2) + t * (1 / 2) := by rw [← add_mul, hst]; ring
    nlinarith [this]
  exact h1.sup (h2.sup h3)

theorem harveyExp_ge_fifth (p : ℝ × ℝ) : 1 / 5 ≤ harveyExp p := by
  unfold harveyExp
  have h1 := le_max_left p.1 (max p.2 (1 / 2 - p.1 / 2 - p.2))
  have h2 := le_max_left p.2 (1 / 2 - p.1 / 2 - p.2)
  have h3 := le_max_right p.2 (1 / 2 - p.1 / 2 - p.2)
  have h4 := le_max_right p.1 (max p.2 (1 / 2 - p.1 / 2 - p.2))
  linarith

theorem harveyExp_at_fifth : harveyExp (1 / 5, 1 / 5) = 1 / 5 := by
  norm_num [harveyExp]

/-- **Application of the slack lemma to Harvey.** The baby-step ceiling
`C = {b < 2/5}` (the `m ≤ N^{2/5}` ceiling) is a neighbourhood of the optimum
`(1/5, 1/5)`, and the optimum of the constrained problem is the global optimum:
lifting the ceiling (letting the hypothesis behind it fall) changes nothing. -/
theorem harvey_baby_step_ceiling_slack :
    {p : ℝ × ℝ | p.2 < 2 / 5} ∈ 𝓝 ((1 / 5 : ℝ), (1 / 5 : ℝ)) ∧
    ∀ q : ℝ × ℝ, harveyExp (1 / 5, 1 / 5) ≤ harveyExp q := by
  have hopen : IsOpen {p : ℝ × ℝ | p.2 < 2 / 5} :=
    isOpen_lt continuous_snd continuous_const
  have hmem : {p : ℝ × ℝ | p.2 < 2 / 5} ∈ 𝓝 ((1 / 5 : ℝ), (1 / 5 : ℝ)) :=
    hopen.mem_nhds (by norm_num)
  refine ⟨hmem, fun q => ?_⟩
  refine slack_constraint_lemma harveyExp_convex (mem_univ _) hmem ?_ q (mem_univ q)
  intro y _
  rw [harveyExp_at_fifth]; exact harveyExp_ge_fifth y

/-- Lower bound in the active regime: if the baby-step exponent is capped at
`b ≤ c`, the cost is at least `(1 - 2c)/3`. -/
theorem harvey_capped_lower (c a b : ℝ) (hb : b ≤ c) :
    (1 - 2 * c) / 3 ≤ harveyExp (a, b) := by
  unfold harveyExp
  simp only
  have h1 := le_max_left a (max b (1 / 2 - a / 2 - b))
  have h3 := le_max_right b (1 / 2 - a / 2 - b)
  have h4 := le_max_right a (max b (1 / 2 - a / 2 - b))
  linarith

/-- **Phase diagram of the baby-step ceiling.**  With the ceiling `b ≤ c`:

* if `c ≥ 1/5` (slack) the optimum is exactly `1/5`, attained at `(1/5,1/5)`;
* if `c < 1/5` (active) the optimum is exactly `(1-2c)/3`, attained at
  `((1-2c)/3, c)`, and this is strictly larger than `1/5`.

So a change in the ceiling moves the exponent iff the ceiling is active. -/
theorem harvey_ceiling_phase_diagram (c : ℝ) :
    (1 / 5 ≤ c →
      (∀ a b, b ≤ c → 1 / 5 ≤ harveyExp (a, b)) ∧ harveyExp (1 / 5, 1 / 5) = 1 / 5) ∧
    (c < 1 / 5 →
      (∀ a b, b ≤ c → (1 - 2 * c) / 3 ≤ harveyExp (a, b)) ∧
      harveyExp ((1 - 2 * c) / 3, c) = (1 - 2 * c) / 3 ∧ 1 / 5 < (1 - 2 * c) / 3) := by
  refine ⟨fun _ => ⟨fun a b _ => harveyExp_ge_fifth _, harveyExp_at_fifth⟩, fun hc => ?_⟩
  refine ⟨fun a b hb => harvey_capped_lower c a b hb, ?_, by linarith⟩
  unfold harveyExp
  simp only
  have e1 : (1 / 2 : ℝ) - (1 - 2 * c) / 3 / 2 - c = (1 - 2 * c) / 3 := by ring
  rw [e1, max_eq_right (by linarith : c ≤ (1 - 2 * c) / 3), max_self]

/-! ## 3. Filters: which term is divided decides the target -/

/-- Harvey's model with a filter of strength `N^{σ₂}` on the pair term `T₂` and
`N^{σ₁}` on the sweep term `T₁`. -/
def filteredExp (σ₁ σ₂ a b : ℚ) : ℚ := max (a - σ₂) (max b (1 / 2 - a / 2 - b - σ₁))

/-- The filtered optimum value `1/5 - σ₂/5 - 2σ₁/5`. -/
def filteredOpt (σ₁ σ₂ : ℚ) : ℚ := 1 / 5 - σ₂ / 5 - 2 * σ₁ / 5

/-- The optimiser of the filtered model. -/
def filteredArg (σ₁ σ₂ : ℚ) : ℚ × ℚ := (filteredOpt σ₁ σ₂ + σ₂, filteredOpt σ₁ σ₂)

theorem filteredExp_ge (σ₁ σ₂ a b : ℚ) : filteredOpt σ₁ σ₂ ≤ filteredExp σ₁ σ₂ a b := by
  unfold filteredExp filteredOpt
  have h1 := le_max_left (a - σ₂) (max b (1 / 2 - a / 2 - b - σ₁))
  have h2 := le_max_left b (1 / 2 - a / 2 - b - σ₁)
  have h3 := le_max_right b (1 / 2 - a / 2 - b - σ₁)
  have h4 := le_max_right (a - σ₂) (max b (1 / 2 - a / 2 - b - σ₁))
  linarith

/-- **Exact filtered optimum.** The optimum of the filtered model is
`1/5 - σ₂/5 - 2σ₁/5`, attained at `filteredArg`, where all three terms equal it. -/
theorem filteredExp_optimum (σ₁ σ₂ : ℚ) :
    (∀ a b, filteredOpt σ₁ σ₂ ≤ filteredExp σ₁ σ₂ a b) ∧
    filteredExp σ₁ σ₂ (filteredArg σ₁ σ₂).1 (filteredArg σ₁ σ₂).2 = filteredOpt σ₁ σ₂ := by
  refine ⟨filteredExp_ge σ₁ σ₂, ?_⟩
  unfold filteredExp filteredArg filteredOpt
  simp only
  have e1 : (1 / 5 - σ₂ / 5 - 2 * σ₁ / 5 + σ₂) - σ₂ = 1 / 5 - σ₂ / 5 - 2 * σ₁ / 5 := by ring
  have e2 : (1 / 2 : ℚ) - (1 / 5 - σ₂ / 5 - 2 * σ₁ / 5 + σ₂) / 2 -
      (1 / 5 - σ₂ / 5 - 2 * σ₁ / 5) - σ₁ = 1 / 5 - σ₂ / 5 - 2 * σ₁ / 5 := by ring
  rw [e1, e2, max_self, max_self]

/-- **Co-dominance and uniqueness.** Any optimiser of the filtered model is
`filteredArg`, and there all three terms are equal (no term "dominates"). -/
theorem filteredExp_optimum_unique (σ₁ σ₂ a b : ℚ)
    (h : filteredExp σ₁ σ₂ a b = filteredOpt σ₁ σ₂) :
    (a, b) = filteredArg σ₁ σ₂ ∧ a - σ₂ = b ∧ b = 1 / 2 - a / 2 - b - σ₁ := by
  unfold filteredExp filteredOpt at h
  have h1 := le_max_left (a - σ₂) (max b (1 / 2 - a / 2 - b - σ₁))
  have h2 := le_max_left b (1 / 2 - a / 2 - b - σ₁)
  have h3 := le_max_right b (1 / 2 - a / 2 - b - σ₁)
  have h4 := le_max_right (a - σ₂) (max b (1 / 2 - a / 2 - b - σ₁))
  have hb : b = 1 / 5 - σ₂ / 5 - 2 * σ₁ / 5 := by linarith
  have ha : a = 1 / 5 - σ₂ / 5 - 2 * σ₁ / 5 + σ₂ := by linarith
  refine ⟨?_, by linarith, by linarith⟩
  simp [filteredArg, filteredOpt, ha, hb]

/-- **Corrected sieve target (pair-only filter).** A filter that divides only the
pair term has rate `1/5 - σ/5`; it reaches exponent `1/6` iff `σ = 1/6`. -/
theorem pair_only_filter_needs_sixth (σ : ℚ) :
    filteredOpt 0 σ = 1 / 5 - σ / 5 ∧ (filteredOpt 0 σ = 1 / 6 ↔ σ = 1 / 6) := by
  unfold filteredOpt
  refine ⟨by ring, ⟨fun h => by linarith, fun h => by subst h; norm_num⟩⟩

/-- **Where `N^{1/18}` comes from.** A filter dividing *both* `T₁` and `T₂` by
`N^σ` has rate `1/5 - 3σ/5`, reaching `1/6` iff `σ = 1/18`.  The record's
`N^{1/18}` target silently assumed the filter also divides the sweep term. -/
theorem pair_and_sweep_filter_needs_eighteenth (σ : ℚ) :
    filteredOpt σ σ = 1 / 5 - 3 * σ / 5 ∧ (filteredOpt σ σ = 1 / 6 ↔ σ = 1 / 18) := by
  unfold filteredOpt
  refine ⟨by ring, ⟨fun h => by linarith, fun h => by subst h; norm_num⟩⟩

/-- The two targets differ by exactly a factor `3` in the exponent. -/
theorem sieve_target_ratio : (1 / 6 : ℚ) = 3 * (1 / 18) := by norm_num

/-- With no filter the model is Harvey's: optimum `1/5`. -/
theorem filteredOpt_zero : filteredOpt 0 0 = 1 / 5 := by norm_num [filteredOpt]

/-- The exponent gain of a pair-only filter of strength `N^σ` is exactly `σ/5`.
A constant-strength filter (e.g. the free `a ≤ b` filter, `s = 2`) has
`σ = 1/log₂ N → 0`, so it gains a constant factor, never an exponent. -/
theorem pair_filter_gain (σ : ℚ) : filteredOpt 0 0 - filteredOpt 0 σ = σ / 5 := by
  unfold filteredOpt; ring

end SlackConstraint