import Mathlib
import Catalog.NumberTheory.AsymptoticGermInterpretation

/-!
# The flat kernel: exactly how far germs go beyond coefficient extensionality

Third research cycle on the germ interpretation of the rank scale
(`Catalog.NumberTheory.AsymptoticGermInterpretation`,
`Catalog.NumberTheory.AsymptoticGermOrder`).

Cycle 1 proved that the germ interpretation of the summable fragment is
injective, and exhibited a flat function showing that arbitrary functions with
the same asymptotic expansion need not agree.  This cycle measures the failure
*exactly*.

Let `Flat f` mean that `f` is negligible against **every** rank of the scale.
The main theorem is that the fibres of the "take the asymptotic expansion" map
are precisely the cosets of the flat germs:

* `hasExpansion_iff_flat_sub` — if `f` has expansion `a`, then `g` has expansion
  `a` **iff** `f - g` is flat.

Flat germs form a linear subspace which is even an ideal for multiplication by
germs of bounded functions (`Flat.bigO_mul`), it is nontrivial
(`exp_neg_flat`), and it meets the image of the summable fragment only in `0`
(`BddSeries.flat_eval_iff_coeff_zero`).  Together these say: *coefficient
extensionality is valid modulo flatness, and not one bit further.*
-/

namespace Catalog.NumberTheory.AsymptoticGerm

open Filter Asymptotics
open scoped Topology

/-- A germ at `+∞` is *flat* when it is negligible against every rank of the
asymptotic scale. -/
def Flat (f : ℝ → ℝ) : Prop := ∀ n : ℕ, f =o[atTop] monoN n

lemma flat_zero : Flat 0 := fun _ => isLittleO_zero _ _

lemma Flat.neg {f : ℝ → ℝ} (hf : Flat f) : Flat (-f) := fun n => (hf n).neg_left

lemma Flat.add {f g : ℝ → ℝ} (hf : Flat f) (hg : Flat g) : Flat (f + g) :=
  fun n => (hf n).add (hg n)

lemma Flat.sub {f g : ℝ → ℝ} (hf : Flat f) (hg : Flat g) : Flat (f - g) :=
  fun n => (hf n).sub (hg n)

lemma Flat.const_smul {f : ℝ → ℝ} (hf : Flat f) (r : ℝ) : Flat (fun x => r * f x) :=
  fun n => (hf n).const_mul_left r

/-- Flat germs form an ideal: multiplying a flat germ by a germ of a bounded
function stays flat. -/
lemma Flat.bigO_mul {f g : ℝ → ℝ} (hg : g =O[atTop] (fun _ => (1 : ℝ))) (hf : Flat f) :
    Flat (fun x => g x * f x) := by
  intro n
  have := hg.mul_isLittleO (hf n)
  simpa using this

/-! ## The fibres of the expansion map -/

/-- Two functions with the same asymptotic expansion differ by a flat germ. -/
theorem flat_sub_of_hasExpansion {f g : ℝ → ℝ} {a : ℕ → ℝ}
    (hf : HasExpansion f a) (hg : HasExpansion g a) : Flat (f - g) := by
  intro N
  refine ((hf N).sub (hg N)).congr' ?_ (EventuallyEq.refl _ _)
  filter_upwards with x
  simp only [Pi.sub_apply]
  ring

/-- Adding a flat germ does not change the asymptotic expansion. -/
theorem hasExpansion_of_flat_sub {f g : ℝ → ℝ} {a : ℕ → ℝ}
    (hf : HasExpansion f a) (h : Flat (f - g)) : HasExpansion g a := by
  intro N
  refine ((hf N).sub (h N)).congr' ?_ (EventuallyEq.refl _ _)
  filter_upwards with x
  simp only [Pi.sub_apply]
  ring

/-- **The fibres of the expansion map are cosets of the flat germs.**  This is
the exact boundary between the valid formal principle and the false analytic
claim. -/
theorem hasExpansion_iff_flat_sub {f : ℝ → ℝ} {a : ℕ → ℝ} (hf : HasExpansion f a)
    (g : ℝ → ℝ) : HasExpansion g a ↔ Flat (f - g) :=
  ⟨fun hg => flat_sub_of_hasExpansion hf hg, fun h => hasExpansion_of_flat_sub hf h⟩

/-! ## Nontriviality of the flat kernel -/

/-- `e^{-x}` is flat. -/
theorem exp_neg_flat : Flat (fun x : ℝ => Real.exp (-x)) := exp_neg_isLittleO_monoN

/-- The flat kernel is nontrivial: flatness does not imply vanishing. -/
theorem flat_nontrivial : ∃ f : ℝ → ℝ, Flat f ∧ ∀ x : ℝ, f x ≠ 0 :=
  ⟨fun x => Real.exp (-x), exp_neg_flat, fun _ => Real.exp_ne_zero _⟩

namespace BddSeries

/-- The image of the summable fragment meets the flat kernel only in zero:
a bounded series whose germ is flat has all coefficients zero. -/
theorem flat_eval_iff_coeff_zero (c : BddSeries) : Flat c.eval ↔ c.coeff = 0 := by
  constructor
  · intro h
    have hzero : HasExpansion c.eval 0 := by
      intro N
      refine (h N).congr' ?_ (EventuallyEq.refl _ _)
      filter_upwards with x
      simp
    exact expansion_unique (c.eval_hasExpansion) hzero
  · intro h N
    have : c.eval = fun _ : ℝ => (0 : ℝ) := by
      funext x; simp [eval, evalT, h]
    rw [this]
    exact isLittleO_zero _ _

/-- Two bounded series have germs differing by a flat germ exactly when they
agree at every rank: on the fragment, "equal modulo flat" collapses to
"equal". -/
theorem flat_sub_eval_iff (c d : BddSeries) : Flat (c.eval - d.eval) ↔ c.coeff = d.coeff := by
  constructor
  · intro h
    have hsymm : Flat (d.eval - c.eval) := by
      refine fun N => ((h.neg N).congr' ?_ (EventuallyEq.refl _ _))
      filter_upwards with x
      simp only [Pi.neg_apply, Pi.sub_apply]
      ring
    exact expansion_unique (c.eval_hasExpansion)
      (hasExpansion_of_flat_sub (d.eval_hasExpansion) hsymm)
  · intro h
    have : c.eval - d.eval = fun _ : ℝ => (0 : ℝ) := by
      funext x; simp [eval, evalT, h]
    rw [this]
    exact fun N => isLittleO_zero _ _

/-- **Realization**: every germ with the same expansion as a fragment germ is
that germ plus a flat correction, and every flat correction is allowed.  So the
fragment germ is the unique *summable* representative of its expansion. -/
theorem eval_expansion_fibre (c : BddSeries) (g : ℝ → ℝ) :
    HasExpansion g c.coeff ↔ Flat (c.eval - g) :=
  hasExpansion_iff_flat_sub (c.eval_hasExpansion) g

end BddSeries

end Catalog.NumberTheory.AsymptoticGerm