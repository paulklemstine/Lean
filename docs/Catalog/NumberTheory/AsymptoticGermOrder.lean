import Mathlib
import Catalog.NumberTheory.AsymptoticGermInterpretation

/-!
# The germ order on the summable fragment: a lexicographic Hardy-field

Second research cycle on the germ interpretation of the rank scale
(`Catalog.NumberTheory.AsymptoticGermInterpretation`).

Cycle 1 showed that the interpretation `BddSeries.eval` of the normalized
summable fragment into germs at `+∞` is *injective*, that the leading nonzero
monomial controls the eventual sign, and that the analogous statement for
arbitrary functions is false (flat germs).

This cycle upgrades "controls the sign" to "controls the *order*".  The germs of
the fragment behave like a Hardy field: any two of them are eventually
comparable, with no oscillation, and the comparison is computed by the
**lexicographic order on coefficients**.

* `BddSeries.eval_isEquivalent_leading` — the germ is asymptotically equivalent
  to its leading monomial.
* `BddSeries.eval_lt_of_lexLt` — a lexicographic strict inequality of
  coefficients forces an eventual strict inequality of germs.
* `BddSeries.germ_trichotomy` — exactly one of the three comparisons holds
  eventually (no oscillation).
* `BddSeries.eval_lt_iff_lexLt` — the interpretation is an **order embedding**
  of the lexicographic order on bounded coefficient sequences into germs.
-/

namespace Catalog.NumberTheory.AsymptoticGerm

open Filter Asymptotics
open scoped Topology

/-- Strict lexicographic order on coefficient sequences: the first rank at which
`a` and `b` differ has `a` smaller. -/
def LexLt (a b : ℕ → ℝ) : Prop := ∃ n, (∀ m, m < n → a m = b m) ∧ a n < b n

lemma LexLt.ne {a b : ℕ → ℝ} (h : LexLt a b) : a ≠ b := by
  obtain ⟨n, _, hn⟩ := h
  intro he
  rw [he] at hn
  exact lt_irrefl _ hn

namespace BddSeries

/-- Evaluation is additive on the region of convergence. -/
lemma eval_sub_eventually (c d : BddSeries) :
    ∀ᶠ x : ℝ in atTop, (c - d).eval x = c.eval x - d.eval x := by
  filter_upwards [eventually_gt_atTop (1 : ℝ)] with x hx
  have hx0 : (0 : ℝ) < x := by linarith
  have h0 : (0 : ℝ) ≤ x⁻¹ := (inv_pos.mpr hx0).le
  have h1 : x⁻¹ < 1 := by
    rw [inv_lt_one_iff₀]
    right; exact hx
  exact evalT_sub c d h0 h1

/-- **The germ is asymptotically equivalent to its leading monomial.**  This is
the quantitative form of "the leading nonzero monomial controls the germ". -/
theorem eval_isEquivalent_leading {c : BddSeries} {n₀ : ℕ} (hvan : ∀ n, n < n₀ → c.coeff n = 0)
    (hlead : c.coeff n₀ ≠ 0) :
    c.eval ~[atTop] fun x => c.coeff n₀ * monoN n₀ x := by
  have hsum : ∀ x : ℝ, ∑ n ∈ Finset.range (n₀ + 1), c.coeff n * monoN n x
      = c.coeff n₀ * monoN n₀ x := by
    intro x
    rw [Finset.sum_eq_single n₀]
    · intro b hb hne
      rcases lt_or_gt_of_ne hne with h | h
      · rw [hvan b h, zero_mul]
      · exact absurd (Finset.mem_range.mp hb) (by omega)
    · intro h; exact absurd (Finset.mem_range.mpr (Nat.lt_succ_self n₀)) h
  have h : (fun x => c.eval x - c.coeff n₀ * monoN n₀ x) =o[atTop] monoN n₀ := by
    refine (c.eval_hasExpansion n₀).congr' ?_ (EventuallyEq.refl _ _)
    filter_upwards with x
    rw [hsum x]
  exact h.const_mul_right hlead

/-- A lexicographic strict inequality between coefficient sequences propagates to
an eventual strict inequality between germs. -/
theorem eval_lt_of_lexLt {c d : BddSeries} (h : LexLt c.coeff d.coeff) :
    ∀ᶠ x : ℝ in atTop, c.eval x < d.eval x := by
  obtain ⟨n₀, hvan, hlt⟩ := h
  have hv : ∀ n, n < n₀ → (d - c).coeff n = 0 := by
    intro n hn
    simp only [sub_coeff, Pi.sub_apply, hvan n hn, sub_self]
  have hl : 0 < (d - c).coeff n₀ := by
    simp only [sub_coeff, Pi.sub_apply]
    linarith
  filter_upwards [eventually_pos_of_leading hv hl, eval_sub_eventually d c] with x h1 h2
  rw [h2] at h1
  linarith

/-- **No oscillation.**  Two germs from the fragment are always eventually
comparable: exactly one of "equal", "eventually less", "eventually greater"
occurs.  This is the Hardy-field property for the summable fragment. -/
theorem germ_trichotomy (c d : BddSeries) :
    (c.coeff = d.coeff ∧ c.eval =ᶠ[atTop] d.eval)
      ∨ (∀ᶠ x : ℝ in atTop, c.eval x < d.eval x)
      ∨ (∀ᶠ x : ℝ in atTop, d.eval x < c.eval x) := by
  classical
  by_cases hcd : c.coeff = d.coeff
  · exact Or.inl ⟨hcd, (eval_eventuallyEq_iff c d).mpr hcd⟩
  · have hex : ∃ n, c.coeff n ≠ d.coeff n := Function.ne_iff.mp hcd
    set n₀ := Nat.find hex with hn₀
    have hspec : c.coeff n₀ ≠ d.coeff n₀ := Nat.find_spec hex
    have hvan : ∀ m, m < n₀ → c.coeff m = d.coeff m := by
      intro m hm
      exact not_not.mp (Nat.find_min hex hm)
    rcases lt_or_gt_of_ne hspec with h | h
    · exact Or.inr (Or.inl (eval_lt_of_lexLt ⟨n₀, hvan, h⟩))
    · exact Or.inr (Or.inr (eval_lt_of_lexLt ⟨n₀, fun m hm => (hvan m hm).symm, h⟩))

/-- **The germ interpretation is an order embedding**: eventual domination of
germs is *exactly* the lexicographic order on coefficients. -/
theorem eval_lt_iff_lexLt (c d : BddSeries) :
    (∀ᶠ x : ℝ in atTop, c.eval x < d.eval x) ↔ LexLt c.coeff d.coeff := by
  refine ⟨fun h => ?_, eval_lt_of_lexLt⟩
  rcases germ_trichotomy c d with ⟨heq, hev⟩ | hlt | hgt
  · obtain ⟨x, hx1, hx2⟩ := (h.and hev).exists
    exact absurd hx2 (ne_of_lt hx1)
  · classical
    by_contra hno
    -- `hlt` came from a first-difference comparison; extract it directly.
    have hcd : c.coeff ≠ d.coeff := by
      intro he
      obtain ⟨x, hx1, hx2⟩ := (h.and ((eval_eventuallyEq_iff c d).mpr he)).exists
      exact absurd hx2 (ne_of_lt hx1)
    have hex : ∃ n, c.coeff n ≠ d.coeff n := Function.ne_iff.mp hcd
    have hspec : c.coeff (Nat.find hex) ≠ d.coeff (Nat.find hex) := Nat.find_spec hex
    have hvan : ∀ m, m < Nat.find hex → c.coeff m = d.coeff m :=
      fun m hm => not_not.mp (Nat.find_min hex hm)
    rcases lt_or_gt_of_ne hspec with hh | hh
    · exact hno ⟨Nat.find hex, hvan, hh⟩
    · have hgt := eval_lt_of_lexLt (c := d) (d := c) ⟨Nat.find hex, fun m hm => (hvan m hm).symm, hh⟩
      obtain ⟨x, hx1, hx2⟩ := (h.and hgt).exists
      exact absurd hx1 (asymm hx2)
  · obtain ⟨x, hx1, hx2⟩ := (h.and hgt).exists
    exact absurd hx1 (asymm hx2)

/-- The germ order is irreflexive and antisymmetric in the strong, eventual
sense: a germ is never eventually strictly below itself. -/
theorem not_eval_lt_self (c : BddSeries) : ¬ (∀ᶠ x : ℝ in atTop, c.eval x < c.eval x) := by
  intro h
  obtain ⟨x, hx⟩ := h.exists
  exact lt_irrefl _ hx

/-- Transitivity of the germ order, hence with `germ_trichotomy` a strict total
order on the fragment modulo coefficient equality. -/
theorem eval_lt_trans {c d e : BddSeries}
    (h₁ : ∀ᶠ x : ℝ in atTop, c.eval x < d.eval x)
    (h₂ : ∀ᶠ x : ℝ in atTop, d.eval x < e.eval x) :
    ∀ᶠ x : ℝ in atTop, c.eval x < e.eval x := by
  filter_upwards [h₁, h₂] with x hx1 hx2
  exact hx1.trans hx2

end BddSeries

end Catalog.NumberTheory.AsymptoticGerm