import Physics.GradedTransitivityGSet

/-!
# Graded `G`-sets: the fixed-point (Burnside) form of the transitivity counts

Burnside's lemma turns the orbit count `t r Y` into an average of fixed-point counts of
the individual group elements acting on injective `r`-tuples:

  `∑_{g ∈ G} #Fix_r(g) = t r Y · |G|`.

For a graded `G`-set this exhibits the transitivity generating function as a
*partition function over the group*: each `g` contributes its number of fixed injective
`r`-tuples, and eventual `r`-transitivity says exactly that this total settles at `|G|`,
i.e. the "average number of fixed `r`-tuples per group element" tends to `1`.

## Main results

* `Physics.GradedTransitivity.burnside_transCount` — Burnside's lemma for injective
  `r`-tuples.
* `Physics.GradedTransitivity.sum_fixedBy_eq_card_of_transitive` — for an `r`-transitive
  action the fixed-point total is exactly `|G|`.
* `Physics.GradedTransitivity.denom_of_eventually_transitive_fixedPoints` — the
  fixed-point generating function `∑ₙ (∑_g #Fix_r(g, Yₙ)) qⁿ` is rational with
  denominator dividing `(1 − q)^{r+1}`.
-/

namespace Physics.GradedTransitivity

open Finset Function PowerSeries MulAction

variable {G : Type*} [Group G]

/-- **Burnside's lemma for injective `r`-tuples.**  The total number of fixed injective
`r`-tuples, summed over the group, equals `t r Y · |G|`. -/
theorem burnside_transCount [Fintype G] {Y : Type*} [Fintype Y] [MulAction G Y] (r : ℕ) :
    ∑ g : G, Nat.card (fixedBy (InjTuple r Y) g) = transCount G r Y * Nat.card G := by
  classical
  have hfin : Finite (InjTuple r Y) := inferInstanceAs (Finite {f : Fin r → Y // Injective f})
  letI : Fintype (InjTuple r Y) := Fintype.ofFinite _
  letI : ∀ g : G, Fintype (fixedBy (InjTuple r Y) g) := fun _ => Fintype.ofFinite _
  letI : Fintype (orbitRel.Quotient G (InjTuple r Y)) := Fintype.ofFinite _
  have hb := MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G (InjTuple r Y)
  simp only [Nat.card_eq_fintype_card]
  rw [hb, transCount, orbitNum, Nat.card_eq_fintype_card]

/-- At `r`-transitivity Burnside's identity degenerates: the total number of fixed
injective `r`-tuples is exactly the order of the group. -/
theorem sum_fixedBy_eq_card_of_transitive [Fintype G] {Y : Type*} [Fintype Y] [MulAction G Y]
    {r : ℕ} (h : IsTransitiveDeg G r Y) :
    ∑ g : G, Nat.card (fixedBy (InjTuple r Y) g) = Nat.card G := by
  rw [burnside_transCount r, (transCount_eq_one_iff r Y).mpr h, one_mul]

/-- **Fixed-point generating function.**  If the grades of a graded `G`-set are eventually
`r`-transitive, the group-summed fixed-point counts of injective `r`-tuples form an
eventually constant sequence (constant value `|G|`), so their generating function is
rational with denominator dividing `(1 − q)^{r+1}`. -/
theorem denom_of_eventually_transitive_fixedPoints [Fintype G] {Y : ℕ → Type*}
    [∀ n, Fintype (Y n)] [∀ n, MulAction G (Y n)] {r N : ℕ}
    (h : ∀ n, N ≤ n → IsTransitiveDeg G r (Y n)) :
    IsPoly ((1 - X : PowerSeries ℤ) ^ (r + 1)
      * gf (fun n => ((∑ g : G, Nat.card (fixedBy (InjTuple r (Y n)) g) : ℕ) : ℤ))) := by
  refine denom_of_eventually_const (N := N) (c := (Nat.card G : ℤ)) ?_ r
  intro n hn
  exact_mod_cast congrArg (fun k : ℕ => (k : ℤ)) (sum_fixedBy_eq_card_of_transitive (h n hn))

end Physics.GradedTransitivity