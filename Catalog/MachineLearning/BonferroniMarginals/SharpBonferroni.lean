import MachineLearning.BonferroniMarginals.Stability

/-!
# The sharp (unordered-pair) second Bonferroni inequality

`Core.lean` proves
`∑ᵢ|Aᵢ| ≤ |cover| + ∑_{(i,j) ∈ offDiag}|Aᵢ ∩ Aⱼ|`,
where the pair sum runs over *ordered* pairs and therefore counts every overlap
twice.  The classical second Bonferroni inequality is the unordered statement
`∑ᵢ|Aᵢ| − ∑_{i<j}|Aᵢ ∩ Aⱼ| ≤ |cover|`,
which is a factor `2` stronger on the correction term.  This file proves it in
the index-order-free form

`2·∑ᵢ|Aᵢ| ≤ 2·|cover| + ∑_{(i,j) ∈ offDiag}|Aᵢ ∩ Aⱼ|`

together with its exact defect and its tightness characterisation.

* `sharp_bonferroni_defect_identity` —
  `2·∑ᵢ|Aᵢ| + ∑ₓ (mult x − 1)(mult x − 2) = 2·|cover| + ∑_{i≠j}|Aᵢ ∩ Aⱼ|`.
  The defect is now the *second factorial* deviation of the multiplicity from
  the interval `{1, 2}`, rather than the squared deviation from `1`.
* `sharp_bonferroni` — the inequality.
* `sharp_bonferroni_tight_iff` — equality holds iff no point is covered three
  times, i.e. exactly on the families for which the double-collision bound
  `card_doubleCollision_mul_le` is also tight (`doubleCollision_tight_iff`).
  The two second-order inequalities of the machinery therefore have *the same*
  extremal class: multiplicity-`≤ 2` families.
* `sharp_bonferroni_strictly_stronger` — the sharp bound implies the
  `Core.lean` bound.

Machine-learning reading: the classical union-bound correction is exactly
lossless for ensembles in which no sample is misclassified by three or more
members; beyond that regime the correction over-counts, by a computable amount.
-/

namespace BonferroniMarginals

open Finset

variable {Ω ι : Type*} [DecidableEq Ω] [DecidableEq ι]

/-- **Exact defect of the sharp second Bonferroni inequality.** -/
theorem sharp_bonferroni_defect_identity (I : Finset ι) (A : ι → Finset Ω) :
    2 * ∑ i ∈ I, (A i).card
        + ∑ x ∈ cover I A, (mult I A x - 1) * (mult I A x - 2)
      = 2 * (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  rw [sum_offDiag_eq, ← sum_mult_eq_sum_card, Finset.mul_sum, ← Finset.sum_add_distrib,
    show 2 * (cover I A).card = ∑ _x ∈ cover I A, 2 by
      rw [Finset.sum_const, smul_eq_mul, mul_comm],
    ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x hx => ?_
  obtain ⟨k, hk⟩ := Nat.exists_eq_add_of_le (one_le_mult_of_mem_cover hx)
  rw [hk, show 1 + k - 1 = k by omega]
  cases k with
  | zero => simp
  | succ n =>
    rw [show 1 + (n + 1) - 2 = n by omega]
    ring

/-- **Sharp second Bonferroni inequality.**  The union-bound correction only
needs the *unordered* pairwise overlaps. -/
theorem sharp_bonferroni (I : Finset ι) (A : ι → Finset Ω) :
    2 * ∑ i ∈ I, (A i).card
      ≤ 2 * (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  have h := sharp_bonferroni_defect_identity I A
  omega

/-- The sharp bound implies the `Core.lean` bound, and is strictly stronger
whenever the pairwise-overlap mass is positive. -/
theorem sharp_bonferroni_strictly_stronger (I : Finset ι) (A : ι → Finset Ω) :
    2 * ∑ i ∈ I, (A i).card
      ≤ 2 * ((cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card) := by
  have h := sharp_bonferroni I A
  omega

/-- **Tightness of the sharp bound**: equality holds exactly when no point is
covered three or more times — the same extremal class as for the
double-collision bound. -/
theorem sharp_bonferroni_tight_iff (I : Finset ι) (A : ι → Finset Ω) :
    (2 * ∑ i ∈ I, (A i).card
        = 2 * (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card)
      ↔ ∀ x ∈ cover I A, mult I A x ≤ 2 := by
  have hid := sharp_bonferroni_defect_identity I A
  constructor
  · intro heq
    have hzero : ∑ x ∈ cover I A, (mult I A x - 1) * (mult I A x - 2) = 0 := by omega
    intro x hx
    have hterm := (Finset.sum_eq_zero_iff.mp hzero) x hx
    have h1 := one_le_mult_of_mem_cover hx
    rcases Nat.mul_eq_zero.mp hterm with h | h <;> omega
  · intro hle
    have hzero : ∑ x ∈ cover I A, (mult I A x - 1) * (mult I A x - 2) = 0 := by
      refine Finset.sum_eq_zero fun x hx => ?_
      have := hle x hx
      have h2 : mult I A x - 2 = 0 := by omega
      rw [h2, mul_zero]
    omega

/-- Both second-order inequalities of the machinery are tight on exactly the
same families: those of coverage multiplicity at most `2`. -/
theorem sharp_bonferroni_and_doubleCollision_same_extremals (I : Finset ι) (A : ι → Finset Ω) :
    (2 * ∑ i ∈ I, (A i).card
        = 2 * (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card)
      ↔ (2 * (doubleCollision I A).card = ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card) :=
  (sharp_bonferroni_tight_iff I A).trans (doubleCollision_tight_iff I A).symm

end BonferroniMarginals