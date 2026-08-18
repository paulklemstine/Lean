import Mathlib

/-!
# The Bonferroni machinery: multiplicity calculus for arbitrary finite families

This file builds, from scratch and for an *arbitrary* finite family
`A : ι → Finset Ω` indexed by a finite set `I : Finset ι`, the exact
book-keeping that underlies every Bonferroni-type inequality.

The organising object is the **multiplicity** (or *degree*, or *coverage
count*) function
`mult I A x = #{i ∈ I | x ∈ A i}`.
All first- and second-order *marginals* of the family are moments of `mult`
on the cover `⋃ i ∈ I, A i`:

* `sum_mult_eq_sum_card` : `∑ₓ mult x = ∑ᵢ |Aᵢ|`  (first marginal moment)
* `sum_mult_sq_eq_sum_prod` : `∑ₓ (mult x)² = ∑_{(i,j)} |Aᵢ ∩ Aⱼ|` (second)
* `sum_offDiag_eq` : the off-diagonal part is `∑ₓ mult x * (mult x - 1)`.

From these two identities the whole machinery follows:

* `card_sum_le_card_biUnion_add_offDiag` — the **second Bonferroni inequality**
  in its off-diagonal (unordered-pair-free) form.
* `card_doubleCollision_mul_le` — the **double-collision bound**: twice the
  number of points covered at least twice is at most the pairwise-overlap mass.
* `sq_sum_card_le_card_cover_mul_sum_prod` — the **Cauchy–Schwarz upgrade**
  `(∑ᵢ |Aᵢ|)² ≤ |cover| · ∑_{(i,j)} |Aᵢ ∩ Aⱼ|`, which is strictly stronger than
  Bonferroni whenever the family is far from a partition.

Machine-learning reading: `Ω` is a finite sample space, `A i` the set of samples
on which hypothesis `i` fails (its *bad event*), `|A i|` the first marginal,
`|A i ∩ A j|` the second.  `mult` is the number of ensemble members that fail
at a given sample, `cover` is the set of samples on which the ensemble is not
unanimously correct, and `doubleCollision` is the set of samples where the
failures are *correlated*.
-/

namespace BonferroniMarginals

open Finset

variable {Ω ι : Type*} [DecidableEq Ω]
variable {I : Finset ι} {A : ι → Finset Ω}

/-! ## The multiplicity function -/

/-- `mult I A x` is the number of members of the family that contain `x`:
the *coverage multiplicity* of the point `x`. -/
def mult (I : Finset ι) (A : ι → Finset Ω) (x : Ω) : ℕ :=
  (I.filter (fun i => x ∈ A i)).card

/-- The union (cover) of the family. -/
def cover (I : Finset ι) (A : ι → Finset Ω) : Finset Ω := I.biUnion A

/-- The set of points covered at least twice — where two members *collide*. -/
def doubleCollision (I : Finset ι) (A : ι → Finset Ω) : Finset Ω :=
  (cover I A).filter (fun x => 2 ≤ mult I A x)

@[simp] lemma mem_cover {x : Ω} : x ∈ cover I A ↔ ∃ i ∈ I, x ∈ A i := by
  simp [cover]

lemma mult_pos_iff {x : Ω} : 0 < mult I A x ↔ x ∈ cover I A := by
  simp [mult, Finset.card_pos, Finset.filter_nonempty_iff]

lemma one_le_mult_of_mem_cover {x : Ω} (hx : x ∈ cover I A) : 1 ≤ mult I A x :=
  mult_pos_iff.mpr hx

lemma subset_cover {i : ι} (hi : i ∈ I) : A i ⊆ cover I A := fun _ hx =>
  mem_cover.mpr ⟨i, hi, hx⟩

/-- The multiplicity is the sum of the indicator marginals. -/
lemma mult_eq_sum_indicator (x : Ω) :
    mult I A x = ∑ i ∈ I, if x ∈ A i then 1 else 0 := by
  rw [mult, Finset.card_filter]

/-! ## The two moment identities -/

/-- **First moment identity.** Summing the multiplicity over any set containing the
cover recovers the sum of the first marginals `|Aᵢ|`. -/
lemma sum_mult_eq_sum_card_of_subset (S : Finset Ω) (hS : ∀ i ∈ I, A i ⊆ S) :
    ∑ x ∈ S, mult I A x = ∑ i ∈ I, (A i).card := by
  simp only [mult_eq_sum_indicator]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i hi => ?_
  rw [← Finset.card_filter]
  congr 1
  rw [Finset.filter_mem_eq_inter, Finset.inter_eq_right.mpr (hS i hi)]

/-- **First moment identity** on the cover. -/
lemma sum_mult_eq_sum_card (I : Finset ι) (A : ι → Finset Ω) :
    ∑ x ∈ cover I A, mult I A x = ∑ i ∈ I, (A i).card :=
  sum_mult_eq_sum_card_of_subset _ fun _ hi => subset_cover hi

/-- **Second moment identity.** The sum of squared multiplicities is the total
pairwise-overlap mass, i.e. the sum of all second marginals `|Aᵢ ∩ Aⱼ|`
(ordered pairs, diagonal included). -/
lemma sum_mult_sq_eq_sum_prod_of_subset (S : Finset Ω) (hS : ∀ i ∈ I, A i ⊆ S) :
    ∑ x ∈ S, (mult I A x) ^ 2 = ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card := by
  have hpt : ∀ x : Ω, (mult I A x) ^ 2
      = ∑ p ∈ I ×ˢ I, if x ∈ A p.1 ∩ A p.2 then 1 else 0 := by
    intro x
    rw [sq, mult_eq_sum_indicator, Finset.sum_mul_sum]
    rw [Finset.sum_product]
    refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
    by_cases hi : x ∈ A i <;> by_cases hj : x ∈ A j <;> simp [hi, hj]
  simp only [hpt]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun p hp => ?_
  rw [Finset.mem_product] at hp
  rw [← Finset.card_filter]
  congr 1
  rw [Finset.filter_mem_eq_inter, Finset.inter_eq_right.mpr]
  exact (Finset.inter_subset_left.trans (hS p.1 hp.1))

/-- **Second moment identity** on the cover. -/
lemma sum_mult_sq_eq_sum_prod (I : Finset ι) (A : ι → Finset Ω) :
    ∑ x ∈ cover I A, (mult I A x) ^ 2 = ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card :=
  sum_mult_sq_eq_sum_prod_of_subset _ fun _ hi => subset_cover hi

/-- Splitting the ordered pair sum into diagonal (first marginals) and off-diagonal
(genuine pairwise overlaps). -/
lemma sum_prod_eq_sum_card_add_offDiag [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card
      = ∑ i ∈ I, (A i).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  rw [← Finset.diag_union_offDiag (s := I),
    Finset.sum_union (Finset.disjoint_diag_offDiag I)]
  congr 1
  have hdiag : I.diag = I.image (fun a => (a, a)) := by
    ext p
    simp only [Finset.mem_diag, Finset.mem_image, Prod.ext_iff]
    constructor
    · rintro ⟨h1, h2⟩; exact ⟨p.1, h1, rfl, h2⟩
    · rintro ⟨a, ha, h1, h2⟩; exact ⟨h1 ▸ ha, h1 ▸ h2⟩
  rw [hdiag, Finset.sum_image (by intro a _ b _ h; simpa using congrArg Prod.fst h)]
  simp

/-- The off-diagonal (pairwise overlap) mass equals the second factorial moment
`∑ₓ mult x · (mult x - 1)` of the multiplicity function. -/
lemma sum_offDiag_eq [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card
      = ∑ x ∈ cover I A, (mult I A x) * (mult I A x - 1) := by
  have h1 := sum_mult_sq_eq_sum_prod I A
  have h2 := sum_prod_eq_sum_card_add_offDiag I A
  have h3 := sum_mult_eq_sum_card I A
  have hsplit : ∑ x ∈ cover I A, (mult I A x) ^ 2
      = ∑ x ∈ cover I A, ((mult I A x) * (mult I A x - 1) + mult I A x) := by
    refine Finset.sum_congr rfl fun x hx => ?_
    have := one_le_mult_of_mem_cover hx
    obtain ⟨k, hk⟩ := Nat.exists_eq_add_of_le this
    rw [hk]
    have h1k : 1 + k - 1 = k := by omega
    rw [h1k]
    ring
  rw [hsplit, Finset.sum_add_distrib, h3] at h1
  omega

/-! ## The Bonferroni machinery -/

/-- **Second Bonferroni inequality (off-diagonal form).**
For an arbitrary finite family, the sum of the first marginals exceeds the size
of the union by at most the total pairwise-overlap mass:
`∑ᵢ |Aᵢ| ≤ |⋃ᵢ Aᵢ| + ∑_{i ≠ j} |Aᵢ ∩ Aⱼ|`.

The proof is a pointwise inequality `2d ≤ 1 + d²` for the multiplicity `d`,
summed over the cover; this is where the "square completion" `(d-1)² ≥ 0`
enters. -/
theorem card_sum_le_card_biUnion_add_offDiag [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    ∑ i ∈ I, (A i).card
      ≤ (cover I A).card + ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  have key : 2 * ∑ x ∈ cover I A, mult I A x
      ≤ ∑ x ∈ cover I A, 1 + ∑ x ∈ cover I A, (mult I A x) ^ 2 := by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    refine Finset.sum_le_sum fun x _ => ?_
    nlinarith [sq_nonneg ((mult I A x : ℤ) - 1), Nat.zero_le (mult I A x)]
  rw [sum_mult_eq_sum_card] at key
  rw [sum_mult_sq_eq_sum_prod, sum_prod_eq_sum_card_add_offDiag] at key
  simp only [Finset.sum_const, smul_eq_mul, mul_one] at key
  omega

/-- **Double-collision bound.**  Twice the number of points that are covered at
least twice is at most the total pairwise-overlap mass.  Equivalently: a family
with small second marginals can have only few points of multiple coverage. -/
theorem card_doubleCollision_mul_le [DecidableEq ι] (I : Finset ι) (A : ι → Finset Ω) :
    2 * (doubleCollision I A).card ≤ ∑ p ∈ I.offDiag, (A p.1 ∩ A p.2).card := by
  rw [sum_offDiag_eq]
  have hsub : doubleCollision I A ⊆ cover I A := Finset.filter_subset _ _
  calc 2 * (doubleCollision I A).card
      = ∑ x ∈ doubleCollision I A, 2 := by
        rw [Finset.sum_const, smul_eq_mul, mul_comm]
    _ ≤ ∑ x ∈ doubleCollision I A, (mult I A x) * (mult I A x - 1) := by
        refine Finset.sum_le_sum fun x hx => ?_
        have h2 : 2 ≤ mult I A x := (Finset.mem_filter.mp hx).2
        have : 1 ≤ mult I A x - 1 := by omega
        calc (2:ℕ) = 2 * 1 := by ring
          _ ≤ mult I A x * (mult I A x - 1) := Nat.mul_le_mul h2 this
    _ ≤ ∑ x ∈ cover I A, (mult I A x) * (mult I A x - 1) :=
        Finset.sum_le_sum_of_subset hsub

/-- A point of the cover which is not a double collision lies in exactly one member. -/
lemma mult_eq_one_of_not_doubleCollision {x : Ω} (hx : x ∈ cover I A)
    (hx2 : x ∉ doubleCollision I A) : mult I A x = 1 := by
  have h1 := one_le_mult_of_mem_cover hx
  simp only [doubleCollision, Finset.mem_filter, hx, true_and, not_le] at hx2
  omega

/-! ## The Cauchy–Schwarz upgrade

The Bonferroni inequality uses the pointwise bound `2d ≤ 1 + d²`.  Summing the
*sharp* Cauchy–Schwarz inequality instead gives a bound that is strictly
stronger for families that are far from a partition. -/

/-- **Lagrange identity** for the multiplicity function (over `ℤ`):
`2·(|S|·∑ f² − (∑ f)²) = ∑_{x,y} (f x − f y)²`. -/
lemma lagrange_identity {α : Type*} (S : Finset α) (f : α → ℤ) :
    2 * ((S.card : ℤ) * (∑ x ∈ S, f x ^ 2) - (∑ x ∈ S, f x) ^ 2)
      = ∑ x ∈ S, ∑ y ∈ S, (f x - f y) ^ 2 := by
  have expand : ∀ x ∈ S, ∑ y ∈ S, (f x - f y) ^ 2
      = (S.card : ℤ) * f x ^ 2 - 2 * f x * (∑ y ∈ S, f y) + ∑ y ∈ S, f y ^ 2 := by
    intro x _
    have : ∀ y, (f x - f y) ^ 2 = f x ^ 2 - 2 * (f x * f y) + f y ^ 2 := by
      intro y; ring
    simp only [this, Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const,
      nsmul_eq_mul, ← Finset.mul_sum]
    ring
  rw [Finset.sum_congr rfl expand]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul,
    ← Finset.mul_sum, ← Finset.sum_mul]
  ring

/-- **Cauchy–Schwarz bound on the union (Corrádi form).**
`(∑ᵢ |Aᵢ|)² ≤ |⋃ᵢ Aᵢ| · ∑_{(i,j)} |Aᵢ ∩ Aⱼ|`.

This is the second-order-marginal bound on the union that is *sharp* for regular
covers (see `Rigidity.lean`), unlike the Bonferroni inequality. -/
theorem sq_sum_card_le_card_cover_mul_sum_prod (I : Finset ι) (A : ι → Finset Ω) :
    (∑ i ∈ I, (A i).card) ^ 2
      ≤ (cover I A).card * ∑ p ∈ I ×ˢ I, (A p.1 ∩ A p.2).card := by
  have hL := lagrange_identity (cover I A) (fun x => (mult I A x : ℤ))
  have hnn : (0:ℤ) ≤ ∑ x ∈ cover I A, ∑ y ∈ cover I A,
      ((mult I A x : ℤ) - (mult I A y : ℤ)) ^ 2 :=
    Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _
  rw [← hL] at hnn
  have h1 : ((∑ x ∈ cover I A, mult I A x : ℕ) : ℤ) = ∑ x ∈ cover I A, (mult I A x : ℤ) := by
    push_cast; ring
  have h2 : ((∑ x ∈ cover I A, (mult I A x) ^ 2 : ℕ) : ℤ)
      = ∑ x ∈ cover I A, (mult I A x : ℤ) ^ 2 := by push_cast; ring
  have hkey : ((∑ x ∈ cover I A, mult I A x : ℕ) : ℤ) ^ 2
      ≤ ((cover I A).card : ℤ) * ((∑ x ∈ cover I A, (mult I A x) ^ 2 : ℕ) : ℤ) := by
    rw [h1, h2]; linarith
  rw [sum_mult_eq_sum_card, sum_mult_sq_eq_sum_prod] at hkey
  exact_mod_cast hkey

end BonferroniMarginals