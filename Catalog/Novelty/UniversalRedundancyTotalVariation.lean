/-
# The price of universality, X: an exact closed form for two sources

The rigidity theorem of `UniversalRedundancyRigidity.lean` says the price of
universality measures distinguishability rather than cardinality.  For a class of
**two** sources we can say exactly how:

  `S({p₀, p₁}) = 1 + TV(p₀, p₁)`,

`TV` the total variation distance, so the exact minimax regret is

  `log₂ (1 + TV(p₀, p₁))`  bits,

interpolating continuously between `0` bits for identical sources and `1` bit —
the cost of naming the source — for perfectly distinguishable ones.  This is the
first *closed form* in the programme: the price of universality of a two-element
class is a metric quantity.
-/
import Novelty.UniversalRedundancyRigidity

namespace PriceOfUniversality

open Finset Real

variable {A : Type*} [Fintype A]

/-- Total variation distance between the two members of a two-element class. -/
noncomputable def tv (p : Fin 2 → A → ℝ) : ℝ := (1/2) * ∑ a, |p 0 a - p 1 a|

omit [Fintype A] in
/-- For a two-element class the maximum likelihood is the pointwise maximum. -/
theorem maxLik_fin_two (p : Fin 2 → A → ℝ) (a : A) :
    maxLik p a = max (p 0 a) (p 1 a) := by
  refine le_antisymm ((Finset.sup'_le_iff univ_nonempty _).2 fun θ _ => ?_) ?_
  · fin_cases θ
    · exact le_max_left _ _
    · exact le_max_right _ _
  · exact max_le (le_maxLik p 0 a) (le_maxLik p 1 a)

/-- **Closed form for the Shtarkov sum of a two-source class.** -/
theorem shtarkov_fin_two {p : Fin 2 → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    shtarkov p = 1 + tv p := by
  have hmax : ∀ a : A, maxLik p a = (p 0 a + p 1 a + |p 0 a - p 1 a|) / 2 := by
    intro a
    rw [maxLik_fin_two]
    rcases le_total (p 0 a) (p 1 a) with h | h
    · rw [max_eq_right h, abs_of_nonpos (by linarith)]; ring
    · rw [max_eq_left h, abs_of_nonneg (by linarith)]; ring
  calc shtarkov p = ∑ a, (p 0 a + p 1 a + |p 0 a - p 1 a|) / 2 :=
        Finset.sum_congr rfl fun a _ => hmax a
    _ = ((∑ a, p 0 a) + (∑ a, p 1 a) + ∑ a, |p 0 a - p 1 a|) / 2 := by
        rw [← Finset.sum_div, Finset.sum_add_distrib, Finset.sum_add_distrib]
    _ = 1 + tv p := by rw [(hp 0).total, (hp 1).total, tv]; ring

/-- **The exact price of universality for two sources.** -/
theorem minimax_regret_fin_two {p : Fin 2 → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    logb 2 (shtarkov p) = logb 2 (1 + tv p) := by rw [shtarkov_fin_two hp]

theorem tv_nonneg (p : Fin 2 → A → ℝ) : 0 ≤ tv p := by
  have h : 0 ≤ ∑ a, |p 0 a - p 1 a| := Finset.sum_nonneg fun a _ => abs_nonneg _
  rw [tv]; linarith

/-- Total variation never exceeds `1` for probability distributions. -/
theorem tv_le_one {p : Fin 2 → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) : tv p ≤ 1 := by
  have h := shtarkov_le_card (p := p) hp
  rw [shtarkov_fin_two hp, Fintype.card_fin] at h
  norm_num at h
  linarith

/-- **The price of universality of a two-source class lies between `0` and `1`
bit**; by `shtarkov_fin_two` it is the monotone function `log₂ (1 + TV)` of the
total variation distance between the sources. -/
theorem regret_fin_two_bounds {p : Fin 2 → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    0 ≤ logb 2 (shtarkov p) ∧ logb 2 (shtarkov p) ≤ 1 := by
  have h0 : (1:ℝ) ≤ shtarkov p := one_le_shtarkov hp
  have h1 : shtarkov p ≤ 2 := by
    have := tv_le_one hp
    rw [shtarkov_fin_two hp]; linarith
  constructor
  · simpa using Real.logb_le_logb_of_le (b := 2) (by norm_num) (by norm_num) h0
  · have := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by linarith) h1
    simpa [Real.logb_self_eq_one] using this

/-- **Maximal price iff perfect distinguishability, quantitatively.** Two sources
cost the full bit of universality exactly when their total variation distance is
`1`, i.e. exactly when they have disjoint supports. -/
theorem tv_eq_one_iff_disjoint {p : Fin 2 → A → ℝ} (hp : ∀ θ, IsPMF (p θ)) :
    tv p = 1 ↔ DisjointSupports p := by
  rw [← shtarkov_eq_card_iff hp, shtarkov_fin_two hp, Fintype.card_fin]
  constructor
  · intro h; rw [h]; norm_num
  · intro h; norm_num at h; linarith

end PriceOfUniversality