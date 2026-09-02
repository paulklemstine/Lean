import Mathlib
import Catalog.Computation.UnionClosedAdjoinTop

/-!
# Cycle 3: a sharp local degree bound for union-closed families

Cycle 1 (`Catalog.Computation.UnionClosedAdjoinTop`) proved Frankl's *singleton* case: a
union-closed family containing `{a}` has `a` abundant, i.e. `|F| ≤ 2 * deg F a`.  This cycle
asks what a member of *arbitrary* size says about the degrees of its elements, and answers it
exactly.

**Main theorem** (`card_le_localBound_mul_deg`).  If `F` is union-closed, `A ∈ F` and
`a ∈ A`, then

`|F| ≤ (2 ^ (|A| - 1) + 1) * deg F a`.

**Sharpness** (`extremalFamily_card_eq`).  For every finite `A` and `a ∈ A` the family
`extremalFamily A a = insert A (A.erase a).powerset` is union-closed, contains `A`, and
realises the bound with equality: it has `2 ^ (|A| - 1) + 1` members of which exactly one
contains `a`.  So the constant `2 ^ (|A| - 1) + 1` cannot be improved for any size of `A`.

For `|A| = 1` the bound reads `|F| ≤ 2 * deg F a`, i.e. it *recovers Frankl's singleton case*
as its first instance, this time from a fibre-counting argument rather than from an
injection; for `|A| = 2` it gives `|F| ≤ 3 * deg F a`, which is a genuinely new constraint
(the pair theorem of cycle 1 only bounds the *maximum* of the two degrees).

Finally `frankl_of_card_le_four` settles Frankl's conjecture for all union-closed families
with at most four members, using the top-membership lemma of cycle 1.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (H8) the naive fibre bound `|F| ≤ 2 ^ |A| * deg F a` is not
optimal; the true constant should be `2 ^ (|A| - 1) + 1`, because only the members *avoiding*
`a` need to be spread over fibres.  (H9) that constant is attained for every `|A|`.
(H10) Frankl's conjecture is provable outright for very small families.

Experiment (Experimenter): exhaustive search over all `4960` union-closed families on a
four-element ground set returned maximal ratios `|F| / deg F a` equal to `2, 3, 5, 9` for
members `A` of size `1, 2, 3, 4` — exactly `2 ^ (|A| - 1) + 1`, confirming both H8 and H9
before any proof was attempted.  Both are now theorems: the bound
(`card_le_localBound_mul_deg`, via `Finset.card_le_mul_card_image` with the fibre injection
`B ↦ B ∩ A` landing in `(A.erase a).powerset`), and its sharpness for arbitrary `A`
(`extremalFamily_card_eq`).  H10 holds up to four members (`frankl_of_card_le_four`); the
proof needs exactly the fact that two distinct nonempty members force an element of degree
at least two.

Analysis (Analyst): the mechanism is that `B ↦ B ∪ A` collapses the members avoiding `a`
onto members containing `A`, and a fibre is parameterised by `B ∩ A ⊆ A.erase a`.  The `+1`
in the constant is the contribution of the members containing `a` themselves, which is why
the bound degrades gracefully rather than exponentially in the abundance-relevant regime.

Critique (Critic): the bound is useless for abundance as soon as `|A| ≥ 2` (a constant `3`
does not give a factor `2`), and this is not a defect of the proof — the extremal family
shows the constant is optimal.  Any route to Frankl's conjecture through a *single* member
of size `≥ 2` is therefore impossible; one must use several members at once, as the pair
theorem of cycle 1 does.
-/

namespace Catalog.Computation.UnionClosedAdjoinTop

open Finset

variable {α : Type*} [DecidableEq α]

/-! ## The fibre bound -/

/-- The members of a union-closed family that *avoid* `a` are spread over the members
containing `A ∋ a` with fibres of size at most `2 ^ |A \ {a}|`. -/
theorem codeg_le_pow_mul_deg {F : Finset (Finset α)} (hF : IsUnionClosed F)
    {A : Finset α} (hA : A ∈ F) {a : α} (ha : a ∈ A) :
    (F.filter (fun B => a ∉ B)).card ≤ 2 ^ (A.erase a).card * deg F a := by
  set G := F.filter (fun B => a ∉ B) with hG
  have hfib : ∀ C ∈ G.image (fun B => B ∪ A),
      (G.filter (fun B => B ∪ A = C)).card ≤ 2 ^ (A.erase a).card := by
    intro C _
    rw [← Finset.card_powerset (A.erase a)]
    apply Finset.card_le_card_of_injOn (fun B => B ∩ A)
    · intro B hB
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hB
      obtain ⟨hB1, _⟩ := hB
      rw [hG, Finset.mem_filter] at hB1
      simp only [Finset.coe_powerset, Set.mem_preimage, Set.mem_powerset_iff, Finset.coe_subset]
      intro y hy
      rw [Finset.mem_inter] at hy
      exact Finset.mem_erase.2 ⟨fun h => hB1.2 (h ▸ hy.1), hy.2⟩
    · intro B hB B' hB' h
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hB hB'
      have e1 : B = (C \ A) ∪ (B ∩ A) := by
        rw [← hB.2]; ext y; by_cases hy : y ∈ A <;> simp [hy]
      have e2 : B' = (C \ A) ∪ (B' ∩ A) := by
        rw [← hB'.2]; ext y; by_cases hy : y ∈ A <;> simp [hy]
      rw [e1, e2, show B ∩ A = B' ∩ A from h]
  have h1 := Finset.card_le_mul_card_image (f := fun B => B ∪ A) G _ hfib
  have h2 : (G.image (fun B => B ∪ A)).card ≤ deg F a := by
    rw [deg]
    apply Finset.card_le_card
    intro C hC
    obtain ⟨B, hB, rfl⟩ := Finset.mem_image.1 hC
    rw [hG, Finset.mem_filter] at hB
    exact Finset.mem_filter.2 ⟨hF _ hB.1 _ hA, Finset.mem_union_right _ ha⟩
  exact h1.trans (Nat.mul_le_mul_left _ h2)

/-- **Local degree bound.**  In a union-closed family, any element `a` of any member `A`
has degree at least `|F| / (2 ^ (|A| - 1) + 1)`. -/
theorem card_le_localBound_mul_deg {F : Finset (Finset α)} (hF : IsUnionClosed F)
    {A : Finset α} (hA : A ∈ F) {a : α} (ha : a ∈ A) :
    F.card ≤ (2 ^ (A.erase a).card + 1) * deg F a := by
  have hsplit := deg_add_codeg F a
  have hcodeg := codeg_le_pow_mul_deg hF hA ha
  have : (2 ^ (A.erase a).card + 1) * deg F a
      = 2 ^ (A.erase a).card * deg F a + deg F a := by ring
  omega

/-- The exponent in the local bound is `|A| - 1`. -/
theorem card_erase_eq_sub_one {A : Finset α} {a : α} (ha : a ∈ A) :
    (A.erase a).card = A.card - 1 := Finset.card_erase_of_mem ha

/-- **First instance: Frankl's singleton case.**  For `A = {a}` the local bound reads
`|F| ≤ 2 * deg F a`, i.e. `a` is abundant. -/
theorem abundant_of_singleton_mem' {F : Finset (Finset α)} (hF : IsUnionClosed F) {a : α}
    (ha : ({a} : Finset α) ∈ F) : Abundant F a := by
  have h := card_le_localBound_mul_deg hF ha (Finset.mem_singleton_self a)
  rw [Finset.erase_singleton] at h
  simpa using h

/-- **Second instance.**  A member of size two gives `|F| ≤ 3 * deg F a` for *both* of its
elements — a two-sided constraint that the pair theorem does not provide. -/
theorem card_le_three_mul_deg_of_pair_mem {F : Finset (Finset α)} (hF : IsUnionClosed F)
    {a b : α} (hab : ({a, b} : Finset α) ∈ F) (hne : a ≠ b) : F.card ≤ 3 * deg F a := by
  have h := card_le_localBound_mul_deg hF hab (Finset.mem_insert_self a {b})
  have hcard : (({a, b} : Finset α).erase a).card = 1 := by
    rw [Finset.erase_insert (by simpa using hne)]
    simp
  rw [hcard] at h
  simpa using h

/-! ## Sharpness: the extremal family -/

/-- The extremal family for the local bound: all subsets of `A \ {a}`, plus `A` itself. -/
def extremalFamily (A : Finset α) (a : α) : Finset (Finset α) :=
  insert A (A.erase a).powerset

theorem extremalFamily_isUnionClosed (A : Finset α) (a : α) :
    IsUnionClosed (extremalFamily A a) := by
  intro B hB C hC
  simp only [extremalFamily, Finset.mem_insert, Finset.mem_powerset] at hB hC ⊢
  rcases hB with rfl | hB
  · rcases hC with rfl | hC
    · left; simp
    · left
      refine Finset.union_eq_left.2 (hC.trans (Finset.erase_subset _ _))
  · rcases hC with rfl | hC
    · left
      exact Finset.union_eq_right.2 (hB.trans (Finset.erase_subset _ _))
    · right; exact Finset.union_subset hB hC

theorem mem_extremalFamily (A : Finset α) (a : α) : A ∈ extremalFamily A a :=
  Finset.mem_insert_self _ _

/-- Exactly one member of the extremal family contains `a`, namely `A` itself. -/
theorem deg_extremalFamily {A : Finset α} {a : α} (ha : a ∈ A) :
    deg (extremalFamily A a) a = 1 := by
  have h : (extremalFamily A a).filter (fun B => a ∈ B) = {A} := by
    ext B
    simp only [extremalFamily, Finset.mem_filter, Finset.mem_insert, Finset.mem_powerset,
      Finset.mem_singleton]
    constructor
    · rintro ⟨rfl | hB, hmem⟩
      · rfl
      · exact absurd (hB hmem) (by simp)
    · rintro rfl
      exact ⟨Or.inl rfl, ha⟩
  rw [deg, h, Finset.card_singleton]

theorem card_extremalFamily {A : Finset α} {a : α} (ha : a ∈ A) :
    (extremalFamily A a).card = 2 ^ (A.erase a).card + 1 := by
  have hnot : A ∉ (A.erase a).powerset := by
    simp only [Finset.mem_powerset]
    intro h
    exact (Finset.notMem_erase a A) (h ha)
  rw [extremalFamily, Finset.card_insert_of_notMem hnot, Finset.card_powerset]

/-- **Sharpness of the local degree bound.**  For every `A` and `a ∈ A` there is a
union-closed family containing `A` in which the bound
`|F| ≤ (2 ^ (|A| - 1) + 1) * deg F a` holds with equality. -/
theorem extremalFamily_card_eq {A : Finset α} {a : α} (ha : a ∈ A) :
    (extremalFamily A a).card
      = (2 ^ (A.erase a).card + 1) * deg (extremalFamily A a) a := by
  rw [deg_extremalFamily ha, card_extremalFamily ha, mul_one]

/-- The local bound is attained, hence optimal, for every size of `A`. -/
theorem localBound_is_optimal (A : Finset α) (a : α) (ha : a ∈ A) :
    ∃ F : Finset (Finset α), IsUnionClosed F ∧ A ∈ F ∧
      F.card = (2 ^ (A.erase a).card + 1) * deg F a :=
  ⟨extremalFamily A a, extremalFamily_isUnionClosed A a, mem_extremalFamily A a,
    extremalFamily_card_eq ha⟩

/-! ## Frankl's conjecture for families with at most four members -/

/-- Two distinct members both containing `x` give `x` degree at least two. -/
theorem two_le_deg_of_two_mem {F : Finset (Finset α)} {B C : Finset α} {x : α} (hB : B ∈ F)
    (hC : C ∈ F) (hBC : B ≠ C) (hxB : x ∈ B) (hxC : x ∈ C) : 2 ≤ deg F x := by
  have hsub : ({B, C} : Finset (Finset α)) ⊆ F.filter (fun A => x ∈ A) := by
    intro D hD
    rcases Finset.mem_insert.1 hD with rfl | hD
    · exact Finset.mem_filter.2 ⟨hB, hxB⟩
    · rw [Finset.mem_singleton] at hD
      subst hD
      exact Finset.mem_filter.2 ⟨hC, hxC⟩
  have hle := Finset.card_le_card hsub
  rw [Finset.card_insert_of_notMem (by simpa using hBC), Finset.card_singleton] at hle
  rw [deg]
  exact hle

/-- Two distinct *nonempty* members of a union-closed family produce an element of degree at
least two. -/
theorem exists_two_le_deg {F : Finset (Finset α)} (hF : IsUnionClosed F) {B C : Finset α}
    (hB : B ∈ F) (hC : C ∈ F) (hBC : B ≠ C) (hB0 : B.Nonempty) (hC0 : C.Nonempty) :
    ∃ x, 2 ≤ deg F x := by
  by_cases hD : B ∪ C = B
  · obtain ⟨x, hx⟩ := hC0
    exact ⟨x, two_le_deg_of_two_mem hC hB (Ne.symm hBC) hx
      (hD ▸ Finset.mem_union_right _ hx)⟩
  · obtain ⟨x, hx⟩ := hB0
    exact ⟨x, two_le_deg_of_two_mem hB (hF _ hB _ hC) (Ne.symm hD) hx
      (Finset.mem_union_left _ hx)⟩

/-- **Frankl's conjecture for small families.**  Every union-closed family with a nonempty
member and at most four members has an abundant element. -/
theorem frankl_of_card_le_four {F : Finset (Finset α)} (hF : IsUnionClosed F)
    {A : Finset α} (hA : A ∈ F) (hA0 : A.Nonempty) (hcard : F.card ≤ 4) :
    ∃ x, Abundant F x := by
  by_cases hsmall : F.card ≤ 2
  · obtain ⟨x, hx⟩ := hA0
    refine ⟨x, ?_⟩
    have : 1 ≤ deg F x := by
      rw [deg, Finset.one_le_card]
      exact ⟨A, Finset.mem_filter.2 ⟨hA, hx⟩⟩
    unfold Abundant
    omega
  · push_neg at hsmall
    have hempty : F.filter (fun B => ¬ B.Nonempty) ⊆ {∅} := by
      intro B hB
      rw [Finset.mem_filter] at hB
      rw [Finset.mem_singleton, Finset.not_nonempty_iff_eq_empty.1 hB.2]
    have hsplit : (F.filter (fun B => B.Nonempty)).card
        + (F.filter (fun B => ¬ B.Nonempty)).card = F.card := by
      rw [Finset.card_filter_add_card_filter_not]
    have h1 : (F.filter (fun B => ¬ B.Nonempty)).card ≤ 1 := by
      simpa using Finset.card_le_card hempty
    have h2 : 1 < (F.filter (fun B => B.Nonempty)).card := by omega
    obtain ⟨B, hB, C, hC, hBC⟩ := Finset.one_lt_card.1 h2
    rw [Finset.mem_filter] at hB hC
    obtain ⟨x, hx⟩ := exists_two_le_deg hF hB.1 hC.1 hBC hB.2 hC.2
    exact ⟨x, by unfold Abundant; omega⟩

/-- Combining with cycle 1: for a small union-closed family the abundant witness produced
above still works after adjoining the top. -/
theorem frankl_adjoinTop_of_card_le_four {F : Finset (Finset α)} (hF : IsUnionClosed F)
    {A : Finset α} (hA : A ∈ F) (hA0 : A.Nonempty) (hcard : F.card ≤ 4) :
    ∃ x, Abundant (adjoinTop F) x := by
  obtain ⟨x, hx⟩ := frankl_of_card_le_four hF hA hA0 hcard
  exact ⟨x, abundant_adjoinTop_of_nonempty ⟨A, hA⟩ hx⟩

end Catalog.Computation.UnionClosedAdjoinTop