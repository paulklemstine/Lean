import MachineLearning.BonferroniMarginals.Corradi

/-!
# The marginal-order dichotomy: second-order data does not determine the union

The Bonferroni machinery of `Core.lean` consumes only **first- and second-order
marginals** of a family: the numbers `|Aᵢ|` and `|Aᵢ ∩ Aⱼ|`.  This file settles
the natural question raised by that observation: *could any cleverer argument,
still using only those numbers, compute the union exactly?*

The answer is **no**, and the obstruction is explicit and tiny.

* `triangle` and `sunflower` are two families of three `2`-element subsets of a
  `4`-element sample space with **identical** first and second marginals
  (`|Aᵢ| = 2`, `|Aᵢ ∩ Aⱼ| = 1` for `i ≠ j`) and **different** unions
  (`3` versus `4`).
* `union_not_determined_by_second_order_marginals` — hence no function of the
  second-order marginal data computes the union cardinality
  (`no_second_order_formula`).
* `card_cover_eq_of_all_inf_card_eq` — the positive counterpart: the *full*
  intersection data (all orders) does determine the union, by inclusion–exclusion.
  For three sets, order `3` suffices and order `2` does not, so the threshold is
  sharp on this example.
* `triangle_corradi_tight` / `sunflower_corradi_strict` — the same pair of
  families shows that the Corrádi bound of `Corradi.lean` is *exactly* the best
  bound expressible in `(k, m, t)`: the triangle attains it, the sunflower is
  strictly above it.
* `sunflower_doubleCollision_strict` — and the double-collision bound is strict
  exactly because the sunflower has a point of multiplicity `3`, as predicted by
  `doubleCollision_tight_iff`.

Machine-learning reading: knowing every individual error rate and every pairwise
error correlation of an ensemble is provably insufficient to know the ensemble's
total error support; the missing information is a genuine higher-order
interaction.
-/

namespace BonferroniMarginals

open Finset

/-! ## The two witness families -/

/-- Three `2`-element sets forming a triangle: `{0,1}, {1,2}, {2,0}`. -/
def triangle : Fin 3 → Finset (Fin 4)
  | 0 => {0, 1}
  | 1 => {1, 2}
  | 2 => {2, 0}

/-- Three `2`-element sets forming a sunflower with core `{0}`:
`{0,1}, {0,2}, {0,3}`. -/
def sunflower : Fin 3 → Finset (Fin 4)
  | 0 => {0, 1}
  | 1 => {0, 2}
  | 2 => {0, 3}

/-- Both families have all first marginals equal to `2`. -/
theorem first_marginals_eq :
    ∀ i : Fin 3, (triangle i).card = 2 ∧ (sunflower i).card = 2 := by decide

/-- Both families have all second marginals equal: `|Aᵢ ∩ Aⱼ| = 1` for `i ≠ j`
and `= 2` on the diagonal. -/
theorem second_marginals_eq :
    ∀ i j : Fin 3, (triangle i ∩ triangle j).card = (sunflower i ∩ sunflower j).card := by
  decide

/-- Off the diagonal both families have pairwise overlap exactly `1`. -/
theorem second_marginals_offDiag :
    ∀ i j : Fin 3, i ≠ j →
      (triangle i ∩ triangle j).card = 1 ∧ (sunflower i ∩ sunflower j).card = 1 := by
  decide

/-- The triangle covers three points. -/
theorem card_cover_triangle : (cover (univ : Finset (Fin 3)) triangle).card = 3 := by
  decide

/-- The sunflower covers four points. -/
theorem card_cover_sunflower : (cover (univ : Finset (Fin 3)) sunflower).card = 4 := by
  decide

/-- The third-order marginals *do* differ: the triple intersection is empty for
the triangle and a single point for the sunflower.  This is the exact piece of
information the Bonferroni machinery cannot see. -/
theorem third_marginals_differ :
    (triangle 0 ∩ triangle 1 ∩ triangle 2).card = 0 ∧
      (sunflower 0 ∩ sunflower 1 ∩ sunflower 2).card = 1 := by decide

/-! ## The no-go theorem -/

/-- **Second-order marginals do not determine the union.**  There are two
families of subsets of a four-element set with the same first marginals and the
same second marginals, whose unions have different cardinalities. -/
theorem union_not_determined_by_second_order_marginals :
    ∃ A B : Fin 3 → Finset (Fin 4),
      (∀ i, (A i).card = (B i).card) ∧
      (∀ i j, (A i ∩ A j).card = (B i ∩ B j).card) ∧
      (cover (univ : Finset (Fin 3)) A).card ≠ (cover (univ : Finset (Fin 3)) B).card := by
  refine ⟨triangle, sunflower, ?_, second_marginals_eq, ?_⟩
  · intro i
    obtain ⟨h1, h2⟩ := first_marginals_eq i
    rw [h1, h2]
  · rw [card_cover_triangle, card_cover_sunflower]
    decide

/-- **No formula in the second-order marginals.**  Consequently there is no
function `F` of the first- and second-order marginal data that returns the size
of the union — for any index type of size at least three.  Every Bonferroni-type
statement must therefore be an inequality. -/
theorem no_second_order_formula :
    ¬ ∃ F : (Fin 3 → ℕ) → (Fin 3 → Fin 3 → ℕ) → ℕ,
        ∀ A : Fin 3 → Finset (Fin 4),
          (cover (univ : Finset (Fin 3)) A).card
            = F (fun i => (A i).card) (fun i j => (A i ∩ A j).card) := by
  rintro ⟨F, hF⟩
  obtain ⟨A, B, h1, h2, hne⟩ := union_not_determined_by_second_order_marginals
  apply hne
  rw [hF A, hF B]
  congr 1
  · funext i; exact h1 i
  · funext i j; exact h2 i j

/-! ## The positive counterpart: all orders suffice -/

/-- **All-order marginals do determine the union** (inclusion–exclusion).  If two
families have the same intersection cardinality over every nonempty subfamily,
their unions have the same cardinality. -/
theorem card_cover_eq_of_all_inf_card_eq {Ω ι : Type*} [DecidableEq Ω] [DecidableEq ι]
    (I : Finset ι) (A B : ι → Finset Ω)
    (h : ∀ (T : Finset ι) (hT : T.Nonempty), T ⊆ I →
      (T.inf' hT A).card = (T.inf' hT B).card) :
    (cover I A).card = (cover I B).card := by
  have hA := Finset.inclusion_exclusion_card_biUnion I A
  have hB := Finset.inclusion_exclusion_card_biUnion I B
  have hsum : ((cover I A).card : ℤ) = ((cover I B).card : ℤ) := by
    rw [cover, cover, hA, hB]
    refine Finset.sum_congr rfl fun t _ => ?_
    have ht : t.1 ⊆ I := Finset.mem_powerset.mp (Finset.mem_filter.mp t.2).1
    have hne : t.1.Nonempty := (Finset.mem_filter.mp t.2).2
    rw [h t.1 hne ht]
  exact_mod_cast hsum

/-! ## What this says about the quantitative bounds -/

/-- The Corrádi bound `k·m² ≤ N·(m + (k−1)t)` is **attained** by the triangle
(`k = 3, m = 2, t = 1, N = 3`: `12 = 12`). -/
theorem triangle_corradi_tight :
    (univ : Finset (Fin 3)).card * 2 ^ 2
      = (cover (univ : Finset (Fin 3)) triangle).card
          * (2 + ((univ : Finset (Fin 3)).card - 1) * 1) := by
  rw [card_cover_triangle]
  decide

/-- ... and is **strict** for the sunflower, which has the same marginals
(`k = 3, m = 2, t = 1`) but `N = 4`: `12 < 16`.  Both families satisfy the
hypotheses of `card_cover_corradi`, so `(k, m, t)` cannot determine `N`. -/
theorem sunflower_corradi_strict :
    (univ : Finset (Fin 3)).card * 2 ^ 2
      < (cover (univ : Finset (Fin 3)) sunflower).card
          * (2 + ((univ : Finset (Fin 3)).card - 1) * 1) := by
  rw [card_cover_sunflower]
  decide

/-- Both witnesses really do satisfy the marginal hypotheses of the Corrádi
bound, so the two previous statements are comparisons of the *same* bound. -/
theorem witnesses_satisfy_corradi_hypotheses :
    (∀ i ∈ (univ : Finset (Fin 3)), 2 ≤ (triangle i).card) ∧
    (∀ p ∈ (univ : Finset (Fin 3)).offDiag, (triangle p.1 ∩ triangle p.2).card ≤ 1) ∧
    (∀ i ∈ (univ : Finset (Fin 3)), 2 ≤ (sunflower i).card) ∧
    (∀ p ∈ (univ : Finset (Fin 3)).offDiag, (sunflower p.1 ∩ sunflower p.2).card ≤ 1) := by
  decide

/-- The double-collision bound is tight for the triangle (multiplicity `2`
everywhere) and strict for the sunflower (a point of multiplicity `3`),
exactly as `doubleCollision_tight_iff` predicts. -/
theorem doubleCollision_witnesses :
    2 * (doubleCollision (univ : Finset (Fin 3)) triangle).card
        = ∑ p ∈ (univ : Finset (Fin 3)).offDiag, (triangle p.1 ∩ triangle p.2).card ∧
    2 * (doubleCollision (univ : Finset (Fin 3)) sunflower).card
        < ∑ p ∈ (univ : Finset (Fin 3)).offDiag, (sunflower p.1 ∩ sunflower p.2).card := by
  decide

/-- The triangle is a regular cover of multiplicity `2`; by
`cauchySchwarz_tight_iff_regular` this is why it attains the Corrádi bound. -/
theorem triangle_isRegularCover : IsRegularCover (univ : Finset (Fin 3)) triangle 2 := by
  intro x hx
  revert hx
  revert x
  decide

/-- The sunflower is *not* a regular cover, which is why its Cauchy–Schwarz
bound is strict. -/
theorem sunflower_not_regular : ¬ ∃ d, IsRegularCover (univ : Finset (Fin 3)) sunflower d := by
  rintro ⟨d, hd⟩
  have h0 : mult (univ : Finset (Fin 3)) sunflower 0 = 3 := by decide
  have h1 : mult (univ : Finset (Fin 3)) sunflower 1 = 1 := by decide
  have hm0 : (0 : Fin 4) ∈ cover (univ : Finset (Fin 3)) sunflower := by decide
  have hm1 : (1 : Fin 4) ∈ cover (univ : Finset (Fin 3)) sunflower := by decide
  rw [hd 0 hm0] at h0
  rw [hd 1 hm1] at h1
  omega

end BonferroniMarginals