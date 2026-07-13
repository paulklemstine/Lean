/-
# Weighted multiverse quantifiers as a min-plus shortest-path calculus

This file develops the *quantitative* layer of the multiverse / tropical bridge.
Where the Boolean bridge sends a statement's truth values to the two tropical
constants `1` and `0` and reads existence/universality off tropical sums and
products, here every universe carries a **real-valued cost** `c u` — think of it
as the forcing complexity, the length of a forcing iteration, or a
measure-theoretic weight of the universe.

Assigning to a universe `u` the tropical value
`trop (c u)` when the statement holds there and `trop ⊤` (the tropical zero) when
it fails, the two big operators of the min-plus semiring acquire concrete
optimisation meanings:

* the **tropical sum** over the multiverse computes the *cheapest witnessing
  universe* — a shortest-path / Viterbi reading of possibility
  (`cheapest_witness`);
* the **tropical product** over the multiverse computes the *total cost* of a
  statement that holds everywhere — the aggregate forcing budget of a
  multiverse-truth (`necessity_total_cost`).

The qualitative Boolean facts reappear as the *degenerate, zero-cost* case: with
all costs set to `0` the weighted value collapses to the Boolean bridge map
`boolToTropR` (`wval_zero_cost`), and possibility/necessity become the pure
finiteness statements `cheapest_eq_top_iff` / `necessary_iff_finite`.

A concrete three-universe multiverse (`L`, a Cohen extension, an inner model with
a measurable cardinal) illustrates the calculus: the Continuum Hypothesis is
possibly true, its cheapest witnessing universe is the zero-cost ground model `L`
(`ch_cheapest_cost`), yet it is not multiverse-true (`ch_not_necessary`).

## Main results

* `boolToTropR_or`, `boolToTropR_and` — the Boolean-to-tropical map is a semiring
  homomorphism (`∨ ↦ min`, `∧ ↦ +`).
* `cheapest_untrop`, `necessityCost_untrop` — the two weighted big operators are
  a min-plus `inf` and a `sum` of costs.
* `cheapest_eq_top_iff`, `possible_iff_finite` — possibility is finiteness of the
  cheapest cost.
* `cheapest_witness` — the cheapest cost is *attained* at an actual witnessing
  universe, which is cost-minimal among all witnesses.
* `cheapest_mono` — lowering per-universe costs never raises the cheapest cost
  (a comparison/monotonicity principle).
* `necessary_iff_finite`, `necessity_total_cost` — multiverse-truth is finiteness
  of the aggregate cost, which then equals the ordinary sum of the costs.
-/
import Mathlib

open Tropical
open scoped BigOperators

namespace MultiverseTropicalWeighted

/-! ## The Boolean-to-tropical bridge map -/

/-- The bridge map into the *real* min-plus semiring: `true ↦ 1 = trop 0`,
`false ↦ 0 = trop ⊤`. -/
noncomputable def boolToTropR (b : Bool) : Tropical (WithTop ℝ) := if b then 1 else 0

@[simp] lemma boolToTropR_true : boolToTropR true = 1 := rfl
@[simp] lemma boolToTropR_false : boolToTropR false = 0 := rfl

/-- **Disjunction is tropical addition (`min`).** -/
theorem boolToTropR_or (a b : Bool) :
    boolToTropR (a || b) = boolToTropR a + boolToTropR b := by
  cases a <;> cases b <;> simp

/-- **Conjunction is tropical multiplication (`+`).** -/
theorem boolToTropR_and (a b : Bool) :
    boolToTropR (a && b) = boolToTropR a * boolToTropR b := by
  cases a <;> cases b <;> simp

/-! ## Weighted per-universe values -/

/-- The min-plus cost of a universe `i` for the statement `p`: its real cost
`c i` when `p` holds there, and `⊤` (infinite / unreachable) when it fails. -/
noncomputable def wcost {ι : Type} (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) (i : ι) :
    WithTop ℝ := if p i then (c i : WithTop ℝ) else ⊤

/-- The tropical value of a universe: `trop` of its weighted cost. -/
noncomputable def wval {ι : Type} (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) (i : ι) :
    Tropical (WithTop ℝ) := trop (wcost p c i)

@[simp] lemma untrop_wval {ι : Type} (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) (i : ι) :
    untrop (wval p c i) = wcost p c i := rfl

/-- **The Boolean bridge is the zero-cost degenerate case.** With every universe
carrying cost `0`, the weighted value collapses to the Boolean bridge map. -/
theorem wval_zero_cost {ι : Type} (p : ι → Prop) [DecidablePred p] (i : ι) :
    wval p (fun _ => 0) i = boolToTropR (decide (p i)) := by
  rw [← untrop_inj_iff]
  by_cases hi : p i <;> simp [wval, wcost, boolToTropR, hi]

/-! ## The two weighted big operators -/

/-- The **cheapest-witness** operator: the tropical sum (`min`) of the per-universe
values over a finite multiverse. -/
noncomputable def cheapest {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p]
    (c : ι → ℝ) : Tropical (WithTop ℝ) := ∑ i, wval p c i

/-- The **aggregate-cost** operator: the tropical product (`+`) of the per-universe
values over a finite multiverse. -/
noncomputable def necessityCost {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p]
    (c : ι → ℝ) : Tropical (WithTop ℝ) := ∏ i, wval p c i

/-- The cheapest operator is a min-plus infimum of the per-universe costs. -/
theorem cheapest_untrop {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) :
    untrop (cheapest p c) = Finset.univ.inf (wcost p c) := by
  rw [cheapest, Finset.untrop_sum']; rfl

/-- The aggregate operator is an ordinary sum of the per-universe costs. -/
theorem necessityCost_untrop {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) :
    untrop (necessityCost p c) = ∑ i, wcost p c i := by
  rw [necessityCost, untrop_prod]; rfl

/-! ## Possibility as finite cheapest cost -/

/-- The cheapest cost is infinite exactly when the statement holds nowhere. -/
theorem cheapest_eq_top_iff {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) :
    untrop (cheapest p c) = ⊤ ↔ ∀ i, ¬ p i := by
  rw [cheapest_untrop, Finset.inf_eq_top_iff]
  constructor
  · intro h i hi; have := h i (Finset.mem_univ i); simp [wcost, hi] at this
  · intro h i _; simp [wcost, h i]

/-- **Possibility is finiteness of the cheapest cost.** A statement is possibly
true (holds in some universe) iff its cheapest witnessing cost is finite. -/
theorem possible_iff_finite {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) :
    (∃ i, p i) ↔ untrop (cheapest p c) ≠ ⊤ := by
  rw [ne_eq, cheapest_eq_top_iff]; push_neg; rfl

/-- **The cheapest cost is attained at a cost-minimal witnessing universe.** This
is the shortest-path / Viterbi reading of possibility: whenever the statement is
possible, there is an actual universe `i₀` in which it holds, whose cost equals
the min-plus value of the whole multiverse and is minimal among all witnesses. -/
theorem cheapest_witness {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p]
    (c : ι → ℝ) (h : ∃ i, p i) :
    ∃ i₀, p i₀ ∧ untrop (cheapest p c) = (c i₀ : WithTop ℝ) ∧ ∀ j, p j → c i₀ ≤ c j := by
  classical
  rw [cheapest_untrop]
  set S : Finset ι := Finset.univ.filter p with hSdef
  have hSne : S.Nonempty := by obtain ⟨i, hi⟩ := h; exact ⟨i, by simp [hSdef, hi]⟩
  obtain ⟨i₀, hi₀S, hmin⟩ := Finset.exists_mem_eq_inf' hSne (fun j => c j)
  have hp0 : p i₀ := by simpa [hSdef] using hi₀S
  refine ⟨i₀, hp0, ?_, ?_⟩
  · apply le_antisymm
    · calc Finset.univ.inf (wcost p c) ≤ wcost p c i₀ := Finset.inf_le (Finset.mem_univ i₀)
        _ = (c i₀ : WithTop ℝ) := by simp [wcost, hp0]
    · apply Finset.le_inf; intro j _
      by_cases hj : p j
      · have hle : c i₀ ≤ c j := by rw [← hmin]; exact Finset.inf'_le _ (by simp [hSdef, hj])
        simp only [wcost, hj, if_true]; exact_mod_cast hle
      · simp [wcost, hj]
  · intro j hj; rw [← hmin]; exact Finset.inf'_le _ (by simp [hSdef, hj])

/-- **Monotonicity of the cheapest cost.** Lowering the per-universe costs never
raises the cheapest witnessing cost — a comparison principle for the shortest
path across the multiverse. -/
theorem cheapest_mono {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p]
    (c c' : ι → ℝ) (hcc : ∀ i, c i ≤ c' i) :
    untrop (cheapest p c) ≤ untrop (cheapest p c') := by
  rw [cheapest_untrop, cheapest_untrop]
  apply Finset.inf_mono_fun; intro i _
  by_cases hi : p i
  · simp only [wcost, hi, if_true]; exact_mod_cast hcc i
  · simp [wcost, hi]

/-! ## Multiverse-truth as finite aggregate cost -/

/-- **Multiverse-truth is finiteness of the aggregate cost.** A statement holds in
every universe iff the total (tropical-product) cost is finite. -/
theorem necessary_iff_finite {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p] (c : ι → ℝ) :
    (∀ i, p i) ↔ untrop (necessityCost p c) ≠ ⊤ := by
  rw [necessityCost_untrop, ne_eq, WithTop.sum_eq_top]
  push_neg
  constructor
  · intro h i _; simp [wcost, h i]
  · intro h i; by_contra hi
    exact absurd (by simp [wcost, hi] : wcost p c i = ⊤) (h i (Finset.mem_univ i))

/-- **The aggregate cost of a multiverse-truth is the ordinary sum of costs.**
When a statement holds everywhere, the tropical product of its per-universe values
untropicalises to the plain sum of the universe costs. -/
theorem necessity_total_cost {ι : Type} [Fintype ι] (p : ι → Prop) [DecidablePred p]
    (c : ι → ℝ) (h : ∀ i, p i) :
    untrop (necessityCost p c) = ((∑ i, c i : ℝ) : WithTop ℝ) := by
  rw [necessityCost_untrop,
    show (∑ i, wcost p c i) = ∑ i, ((c i : ℝ) : WithTop ℝ) from
      Finset.sum_congr rfl (fun i _ => by simp [wcost, h i]),
    ← WithTop.coe_sum]

/-! ## A concrete three-universe multiverse -/

/-- Three universes: Gödel's constructible `L`, a Cohen forcing extension, and an
inner model carrying a measurable cardinal. -/
inductive Univ | L | cohen | meas
  deriving DecidableEq, Fintype

open Univ

/-- Truth of the Continuum Hypothesis across the three universes: it holds in `L`
and in the (fine-structural) inner model, and fails in the Cohen extension. -/
def CHb : Univ → Bool | L => true | cohen => false | meas => true

/-- The forcing costs of the universes: `L` is the free ground model, the Cohen
extension needs one step of forcing, the measurable inner model is expensive. -/
def fcost : Univ → ℝ | L => 0 | cohen => 1 | meas => 5

/-- CH is possibly true across the multiverse. -/
theorem ch_possible : ∃ u, CHb u = true := ⟨L, rfl⟩

/-- **The cheapest witness of CH is the zero-cost ground model `L`.** The min-plus
value of CH across the multiverse is exactly `0`. -/
theorem ch_cheapest_cost :
    untrop (cheapest (fun u => CHb u = true) fcost) = ((0 : ℝ) : WithTop ℝ) := by
  obtain ⟨i₀, _, heq, hmin⟩ := cheapest_witness (fun u => CHb u = true) fcost ⟨L, rfl⟩
  have hle : fcost i₀ ≤ 0 := by simpa [fcost] using hmin L rfl
  have hge : (0 : ℝ) ≤ fcost i₀ := by cases i₀ <;> norm_num [fcost]
  rw [heq, le_antisymm hle hge]

/-- **CH is not multiverse-true**: it fails in the Cohen extension. -/
theorem ch_not_necessary : ¬ (∀ u, CHb u = true) := by
  intro h; exact absurd (h cohen) (by decide)

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** The Boolean multiverse/tropical bridge from the previous cycle
(existence ↦ tropical sum, universality ↦ tropical product) should lift to a
*quantitative* calculus once universes carry real costs: the tropical sum ought
to compute a cheapest witnessing universe (a shortest-path / Viterbi reading) and
the tropical product an aggregate cost. Conjecture: possibility ⇔ finiteness of a
min over costs, and the min is attained at a genuine cost-minimal witness.

**Experiment.** We modelled a universe's value as `trop (c u)` when the statement
holds and `trop ⊤` otherwise, so that `min`-plus addition selects the cheapest
holding universe and `+`-multiplication accumulates costs. Untropicalising via
`Finset.untrop_sum'` / `untrop_prod` turned the two big operators into a
`Finset.inf` over `WithTop ℝ` and a `Finset.sum`. The attainment result
(`cheapest_witness`) reduced to a nonempty-finset argmin
(`Finset.exists_mem_eq_inf'`) once the `⊤`-valued non-witnesses were shown not to
affect the infimum.

**Analysis.** Every conjecture survived. The clean pattern is that the
qualitative Boolean bridge is exactly the degenerate zero-cost slice
(`wval_zero_cost`): possibility/necessity become finiteness statements
(`possible_iff_finite`, `necessary_iff_finite`), and the extra real structure
records *how expensive* a witness is. Monotonicity (`cheapest_mono`) shows the
construction behaves like a shortest-path functional: cheaper edges, cheaper path.

**Critique.** The results are non-vacuous: `cheapest_witness` produces an explicit
optimal universe and a minimality inequality, and the concrete multiverse pins the
CH witness to the zero-cost ground model while refuting multiverse-truth
(`ch_cheapest_cost`, `ch_not_necessary`) — neither is a definitional triviality.
A corner case worth flagging: `⊤` costs (statement failing) must be excluded from
the argmin, which is why `cheapest_witness` takes a possibility hypothesis; without
it the infimum is `⊤` and no real witness exists, precisely `possible_iff_finite`.

**Synthesis.** The min-plus semiring gives multiverse quantification a genuine
optimisation semantics: `∃` is a cheapest-witness search and `∀` a total-budget
sum, with the Boolean theory recovered at zero cost. This positions independence
phenomena inside the same shortest-path calculus used for dynamic programming and
Viterbi decoding.
-/

end MultiverseTropicalWeighted