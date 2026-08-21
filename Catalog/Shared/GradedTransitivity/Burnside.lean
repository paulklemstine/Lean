import Shared.GradedTransitivity.PolyClassification

/-!
# A Burnside bridge: fixed-point growth forces a rational Hilbert series

The main theorem of the cluster uses transitivity to control `t_r(Y_n)`.
Burnside's orbit-counting lemma provides a completely different, quantitative
route: `t_r(Y_n)` is the average over `g ∈ G` of the number of injective
`r`-tuples fixed by `g`.  Hence *polynomial growth of fixed-point counts*
already forces the Hilbert series to be rational with denominator dividing
`(1-q)^{r+1}` — no transitivity needed.

This is the cross-domain half of the picture: group actions (Burnside)
feeding the formal power series machine of `FiniteDifference`.

## Main results

* `torbits_burnside` : Burnside's formula for `t_r`.
* `hilbertSeq_rational_of_fixedPoint_growth` : polynomial fixed-point growth
  gives denominator `(1-q)^{r+1}`.
-/

namespace GradedTransitivity

open Polynomial

/-- **Burnside's orbit-counting lemma for injective `r`-tuples.** -/
theorem torbits_burnside {G : Type*} [Group G] [Fintype G] {Y : Type*} [MulAction G Y]
    [Finite Y] (r : ℕ) :
    ∑ g : G, Nat.card (MulAction.fixedBy (Fin r ↪ Y) g) = torbits G Y r * Nat.card G := by
  classical
  haveI : Finite (Fin r ↪ Y) := Finite.of_injective (fun f : Fin r ↪ Y => (f : Fin r → Y))
    (fun f f' hff' => by ext i; exact congrFun hff' i)
  haveI : Fintype (Fin r ↪ Y) := Fintype.ofFinite _
  haveI : ∀ g : G, Fintype (MulAction.fixedBy (Fin r ↪ Y) g) := fun _ => Fintype.ofFinite _
  haveI : Fintype (Quotient (MulAction.orbitRel G (Fin r ↪ Y))) := Fintype.ofFinite _
  have hb := MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G (Fin r ↪ Y)
  simpa [torbits, Nat.card_eq_fintype_card] using hb

section Growth

variable {G : Type*} [Group G] [Fintype G] {Y : ℕ → Type*} [∀ n, MulAction G (Y n)]
  [∀ n, Finite (Y n)]

/-- **Fixed-point growth criterion.**  If, for every `g ∈ G`, the number of
injective `r`-tuples of `Y_n` fixed by `g` is eventually a polynomial in `n` of
degree `≤ r`, then `∑_n t_r(Y_n) qⁿ` is rational with denominator dividing
`(1-q)^{r+1}` — with no transitivity assumption whatsoever. -/
theorem hilbertSeq_rational_of_fixedPoint_growth (r N : ℕ) (p : G → ℚ[X])
    (hdeg : ∀ g, (p g).natDegree ≤ r)
    (hfix : ∀ g : G, ∀ n ≥ N,
      (Nat.card (MulAction.fixedBy (Fin r ↪ Y n) g) : ℚ) = (p g).eval (n : ℚ)) :
    ∃ P : ℚ[X], (1 - PowerSeries.X) ^ (r + 1) *
        gen (fun n => (torbits G (Y n) r : ℚ)) = (P : PowerSeries ℚ) := by
  have hcard : (Nat.card G : ℚ) ≠ 0 := by
    have : 0 < Nat.card G := Nat.card_pos
    exact_mod_cast this.ne'
  refine exists_poly_of_eventually_polynomial (r := r) (N := N)
    (p := C (1 / (Nat.card G : ℚ)) * ∑ g : G, p g) ?_ ?_
  · refine le_trans (Polynomial.natDegree_C_mul_le _ _) ?_
    exact Polynomial.natDegree_sum_le_of_forall_le _ _ (fun g _ => hdeg g)
  · intro n hn
    have hburn := torbits_burnside (G := G) (Y := Y n) r
    have hQ : ((∑ g : G, Nat.card (MulAction.fixedBy (Fin r ↪ Y n) g) : ℕ) : ℚ)
        = (torbits G (Y n) r : ℚ) * (Nat.card G : ℚ) := by
      exact_mod_cast congrArg (fun m : ℕ => (m : ℚ)) hburn
    rw [Nat.cast_sum] at hQ
    have hsum : ∑ g : G, (p g).eval (n : ℚ)
        = (torbits G (Y n) r : ℚ) * (Nat.card G : ℚ) := by
      rw [← hQ]
      exact (Finset.sum_congr rfl (fun g _ => (hfix g n hn))).symm
    simp only [Polynomial.eval_mul, Polynomial.eval_C, Polynomial.eval_finset_sum, hsum]
    field_simp

end Growth

/-- Non-vacuity of the fixed-point growth criterion: a *constant* graded
`G`-set (all grades equal to one finite `G`-set `Y`) satisfies its hypotheses,
with the fixed-point counts constant in the grade. -/
theorem hilbertSeq_rational_of_constant_family {G : Type*} [Group G] [Fintype G]
    {Y : Type*} [MulAction G Y] [Finite Y] (r : ℕ) :
    ∃ P : ℚ[X], (1 - PowerSeries.X) ^ (r + 1) *
        gen (fun _ : ℕ => (torbits G Y r : ℚ)) = (P : PowerSeries ℚ) :=
  hilbertSeq_rational_of_fixedPoint_growth (Y := fun _ => Y) r 0
    (fun g => C ((Nat.card (MulAction.fixedBy (Fin r ↪ Y) g) : ℚ)))
    (fun g => by simp) (fun g n _ => by simp)

end GradedTransitivity