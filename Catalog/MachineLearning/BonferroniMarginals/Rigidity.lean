import MachineLearning.BonferroniMarginals.Core

/-!
# Rigidity: exactly how much the Bonferroni machinery loses

`Core.lean` proves the two Bonferroni-type inequalities for an arbitrary finite
family.  This file identifies their **defect** exactly, and characterises the
families that make each of them an equality.  The slogan is:

> Every Bonferroni inequality is an identity plus a nonnegative *irregularity*
> functional of the multiplicity function; the inequality is tight precisely on
> the families whose irregularity vanishes.

Main results.

* `bonferroni_defect_identity` — the exact identity
  `∑ᵢ|Aᵢ| + ∑ₓ (mult x − 1)² = |cover| + ∑_{i≠j}|Aᵢ ∩ Aⱼ|`.
  The Bonferroni slack is the total squared deviation of the coverage
  multiplicity from `1`.
* `bonferroni_tight_iff_mult_one`, `bonferroni_tight_iff_pairwiseDisjoint` —
  the second Bonferroni inequality is an equality **iff** the family is pairwise
  disjoint.
* `doubleCollision_tight_iff` — the double-collision bound is an equality **iff**
  no point is covered three times: the machinery is sharp exactly on families of
  *bounded multiplicity 2*.
* `cauchySchwarz_tight_iff_regular` — the Cauchy–Schwarz (Corrádi) bound is an
  equality **iff** the cover is *regular*, i.e. the multiplicity is constant.

Machine-learning reading: the Bonferroni union bound is lossless exactly for
ensembles whose failure sets never overlap, and the second-order Corrádi bound
is lossless exactly for ensembles whose failures are spread perfectly evenly
over the sample space — a formal statement of "the union bound is tight iff the
errors are uncorrelated, the second-moment bound is tight iff they are equally
correlated".
-/

namespace BonferroniMarginals

open Finset

variable {Ω ι : Type*} [DecidableEq Ω]
variable {I : Finset ι} {A : ι → Finset Ω}

/-! ## Regular covers -/

/-- The family covers each point of its union exactly `d` times. -/
def IsRegularCover (I : Finset ι) (A : ι → Finset Ω) (d : ℕ) : Prop :=
  ∀ x ∈ cover I A, mult I A x = d

/-- For a regular cover the first marginals are determined by the union:
`∑ᵢ |Aᵢ| = d · |cover|`. -/
theorem sum_card_eq_of_regular {d : ℕ} (h : IsRegularCover I A d) :
    ∑ i ∈ I, (A i).card = d * (cover I A).card := by
  rw [← sum_mult_eq_sum_card, Finset.sum_congr rfl h]
  simp [mul_comm]

/-! ## The exact Bonferroni defect -/

/-- **The Bonferroni defect identity.**  For every finite family,
`∑ᵢ |Aᵢ| + ∑ₓ (mult x − 1)² = |⋃ᵢ Aᵢ| + ∑_{i ≠ j} |Aᵢ ∩ Aⱼ|`.

Since the middle term is a sum of squares, this refines
`card_sum_le_card_biUnion_add_offDiag` into an equality and exhibits the loss of
the Bonferroni inequality as the *irregularity* `∑ₓ (mult x − 1)²`. -/
theorem bonferroni_defect_identity [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    ∑ i ∈ I, (A i).card + ∑ x ∈ cover I A, (mult I A x - 1) ^ 2
      = (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  rw [sum_offDiag_eq, ← sum_mult_eq_sum_card, ← Finset.sum_add_distrib]
  rw [show (cover I A).card = ∑ _x ∈ cover I A, 1 by simp, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun x hx => ?_
  obtain ⟨k, hk⟩ := Nat.exists_eq_add_of_le (one_le_mult_of_mem_cover hx)
  rw [hk, show 1 + k - 1 = k by omega]
  ring

/-- **Tightness of the second Bonferroni inequality**: it is an equality exactly
when every covered point has multiplicity one. -/
theorem bonferroni_tight_iff_mult_one [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    (∑ i ∈ I, (A i).card = (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card)
      ↔ ∀ x ∈ cover I A, mult I A x = 1 := by
  have hid := bonferroni_defect_identity I A
  constructor
  · intro heq
    have hzero : ∑ x ∈ cover I A, (mult I A x - 1) ^ 2 = 0 := by omega
    intro x hx
    have h1 := one_le_mult_of_mem_cover hx
    have hterm := (Finset.sum_eq_zero_iff.mp hzero) x hx
    have hsq : mult I A x - 1 = 0 := by simpa using hterm
    omega
  · intro hone
    have hzero : ∑ x ∈ cover I A, (mult I A x - 1) ^ 2 = 0 :=
      Finset.sum_eq_zero fun x hx => by rw [hone x hx]; simp
    omega

/-- Multiplicity one everywhere is the same as pairwise disjointness of the family. -/
theorem mult_eq_one_iff_pairwiseDisjoint (I : Finset ι) (A : ι → Finset Ω) :
    (∀ x ∈ cover I A, mult I A x = 1)
      ↔ ∀ i ∈ I, ∀ j ∈ I, i ≠ j → Disjoint (A i) (A j) := by
  classical
  constructor
  · intro h i hi j hj hij
    rw [Finset.disjoint_left]
    intro x hxi hxj
    have hxc : x ∈ cover I A := mem_cover.mpr ⟨i, hi, hxi⟩
    have hsub : ({i, j} : Finset ι) ⊆ I.filter (fun k => x ∈ A k) := by
      intro k hk
      simp only [Finset.mem_insert, Finset.mem_singleton] at hk
      rcases hk with rfl | rfl <;> simp [Finset.mem_filter, hi, hj, hxi, hxj]
    have hcard : 2 ≤ (I.filter (fun k => x ∈ A k)).card := by
      have := Finset.card_le_card hsub
      rwa [Finset.card_insert_of_notMem (by simpa using hij), Finset.card_singleton] at this
    have := h x hxc
    rw [mult] at this
    omega
  · intro h x hx
    obtain ⟨i, hi, hxi⟩ := mem_cover.mp hx
    have : I.filter (fun k => x ∈ A k) = {i} := by
      apply Finset.eq_singleton_iff_unique_mem.mpr
      refine ⟨by simp [Finset.mem_filter, hi, hxi], ?_⟩
      intro j hj
      simp only [Finset.mem_filter] at hj
      by_contra hne
      exact (Finset.disjoint_left.mp (h j hj.1 i hi hne)) hj.2 hxi
    rw [mult, this, Finset.card_singleton]

/-- **The union bound is lossless exactly for disjoint families.** -/
theorem bonferroni_tight_iff_pairwiseDisjoint [DecidableEq ι] (I : Finset ι)
    (A : ι → Finset Ω) :
    (∑ i ∈ I, (A i).card = (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card)
      ↔ ∀ i ∈ I, ∀ j ∈ I, i ≠ j → Disjoint (A i) (A j) :=
  (bonferroni_tight_iff_mult_one I A).trans (mult_eq_one_iff_pairwiseDisjoint I A)

/-! ## Tightness of the double-collision bound -/

/-- **The double-collision bound is lossless exactly for families of multiplicity ≤ 2.**
If some point is covered three times, the bound `2·|doubleCollision| ≤ pairwise mass`
is strict. -/
theorem doubleCollision_tight_iff [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    (2 * (doubleCollision I A).card = ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card)
      ↔ ∀ x ∈ cover I A, mult I A x ≤ 2 := by
  classical
  have hsub : doubleCollision I A ⊆ cover I A := Finset.filter_subset _ _
  have hrestrict : ∑ x ∈ cover I A, (mult I A x) * (mult I A x - 1)
      = ∑ x ∈ doubleCollision I A, (mult I A x) * (mult I A x - 1) := by
    refine (Finset.sum_subset hsub ?_).symm
    intro x hx hxn
    have := mult_eq_one_of_not_doubleCollision hx hxn
    simp [this]
  have hkey : (2 * (doubleCollision I A).card
      = ∑ x ∈ doubleCollision I A, (mult I A x) * (mult I A x - 1))
      ↔ ∀ x ∈ doubleCollision I A, mult I A x = 2 := by
    rw [show 2 * (doubleCollision I A).card = ∑ _x ∈ doubleCollision I A, 2 by
      rw [Finset.sum_const, smul_eq_mul, mul_comm]]
    rw [Finset.sum_eq_sum_iff_of_le (fun x hx => ?_)]
    · constructor
      · intro h x hx
        have h2 : 2 ≤ mult I A x := (Finset.mem_filter.mp hx).2
        have := h x hx
        nlinarith [this, h2, Nat.sub_add_cancel (show 1 ≤ mult I A x by omega)]
      · intro h x hx
        rw [h x hx]
    · have h2 : 2 ≤ mult I A x := (Finset.mem_filter.mp hx).2
      calc (2:ℕ) = 2 * 1 := by ring
        _ ≤ mult I A x * (mult I A x - 1) := Nat.mul_le_mul h2 (by omega)
  rw [sum_offDiag_eq, hrestrict, hkey]
  constructor
  · intro h x hx
    by_cases hx2 : x ∈ doubleCollision I A
    · exact le_of_eq (h x hx2)
    · exact le_of_eq_of_le (mult_eq_one_of_not_doubleCollision hx hx2) one_le_two
  · intro h x hx
    have h2 : 2 ≤ mult I A x := (Finset.mem_filter.mp hx).2
    exact le_antisymm (h x (hsub hx)) h2

/-! ## Tightness of the Cauchy–Schwarz (Corrádi) bound -/

/-- **The second-moment bound is lossless exactly for regular covers.**
`(∑ᵢ|Aᵢ|)² = |cover| · ∑_{(i,j)} |Aᵢ ∩ Aⱼ|` holds iff the coverage multiplicity
is constant on the union. -/
theorem cauchySchwarz_tight_iff_regular (I : Finset ι) (A : ι → Finset Ω) :
    ((∑ i ∈ I, (A i).card) ^ 2
        = (cover I A).card * ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card)
      ↔ ∃ d, IsRegularCover I A d := by
  classical
  constructor
  · intro heq
    rw [← sum_mult_eq_sum_card, ← sum_mult_sq_eq_sum_prod] at heq
    have hL := lagrange_identity (cover I A) (fun x => (mult I A x : ℤ))
    have hcast : ((cover I A).card : ℤ) * (∑ x ∈ cover I A, (mult I A x : ℤ) ^ 2)
        - (∑ x ∈ cover I A, (mult I A x : ℤ)) ^ 2 = 0 := by
      have : (((∑ x ∈ cover I A, mult I A x) ^ 2 : ℕ) : ℤ)
          = (((cover I A).card * ∑ x ∈ cover I A, (mult I A x) ^ 2 : ℕ) : ℤ) := by
        exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) heq
      push_cast at this
      linarith
    rw [hcast] at hL
    have hzero : ∑ x ∈ cover I A, ∑ y ∈ cover I A,
        ((mult I A x : ℤ) - (mult I A y : ℤ)) ^ 2 = 0 := by linarith
    have hall : ∀ x ∈ cover I A, ∀ y ∈ cover I A, mult I A x = mult I A y := by
      intro x hx y hy
      have h1 := (Finset.sum_eq_zero_iff_of_nonneg
        (fun z _ => Finset.sum_nonneg fun _ _ => sq_nonneg _)).mp hzero x hx
      have h2 := (Finset.sum_eq_zero_iff_of_nonneg
        (fun _ _ => sq_nonneg _)).mp h1 y hy
      have : (mult I A x : ℤ) = (mult I A y : ℤ) := by nlinarith [h2]
      exact_mod_cast this
    rcases (cover I A).eq_empty_or_nonempty with hemp | ⟨x0, hx0⟩
    · exact ⟨0, fun x hx => absurd hx (by simp [hemp])⟩
    · exact ⟨mult I A x0, fun x hx => hall x hx x0 hx0⟩
  · rintro ⟨d, hd⟩
    rw [← sum_mult_eq_sum_card, ← sum_mult_sq_eq_sum_prod]
    have h1 : ∑ x ∈ cover I A, mult I A x = (cover I A).card * d := by
      rw [Finset.sum_congr rfl hd]; simp [mul_comm]
    have hsq : ∀ x ∈ cover I A, (mult I A x) ^ 2 = d ^ 2 := fun x hx => by rw [hd x hx]
    have h2 : ∑ x ∈ cover I A, (mult I A x) ^ 2 = (cover I A).card * d ^ 2 := by
      rw [Finset.sum_congr rfl hsq]; simp
    rw [h1, h2]; ring

/-- For a regular cover of multiplicity `d ≥ 1` the union is determined by the
first marginals alone: `|cover| = (∑ᵢ|Aᵢ|)/d`, division-free form. -/
theorem card_cover_mul_of_regular {d : ℕ} (h : IsRegularCover I A d) :
    d * (cover I A).card = ∑ i ∈ I, (A i).card :=
  (sum_card_eq_of_regular h).symm

end BonferroniMarginals