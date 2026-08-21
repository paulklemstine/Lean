/-
# The associativity defect of a finite unital magma

This file is the combinatorial counterpart of `Catalog/Combinatorics/CodiscreteMagmaBicategory.lean`.
There we showed that *every* pointed magma `M` produces a coherent bicategory `MagmaBicat M`
whose weak associator repairs the associativity defect of `M`.  Here we measure that defect.

For a finite pointed magma we set
`defect M = #{(a,b,c) : (a*b)*c ≠ a*(b*c)}`.

Main results:
* `UnitalMagmaDefect.defect_eq_zero_iff` : `defect M = 0` iff `M` is associative;
* `UnitalMagmaDefect.assocCount_prod` : the number of *associative* triples is multiplicative
  under products of magmas, i.e. the associativity density is multiplicative;
* `UnitalMagmaDefect.defect_congr` and `UnitalMagmaDefect.defect_op` : the defect is invariant
  under magma isomorphism and under passing to the opposite magma;
* `UnitalMagmaDefect.defect_even_of_comm` : the defect of a finite **commutative** magma is
  always even (reversal involution, palindromic triples are never defective), whence
  `defect_ne_one_of_comm`;
* `UnitalMagmaDefect.defect_le_of_comm_unital` and
  `UnitalMagmaDefect.exists_comm_unital_magma_maximal_defect` : the sharp commutative bound
  `(n-1)^3 - (n-1)^2`, attained by the *negation magma* `NegMagma (ZMod m)` for odd `m`;
* `UnitalMagmaDefect.card_nonidentity_associators` and `strict_iff_defect_zero` : the bridge to
  the bicategory, `defect M` counts the non-identity associator instances of `MagmaBicat M`;
* `UnitalMagmaDefect.defect_le_of_unital` : if `1` is a two-sided unit then no defect triple can
  involve `1`, whence `defect M ≤ (card M - 1) ^ 3`;
* `UnitalMagmaDefect.ShiftMagma.defect_eq` : the *shift magma* `ShiftMagma σ = Option S`
  attached to a fixed-point-free self-map `σ : S → S` is a unital magma **every** one of whose
  non-unit triples is defective, so it attains the bound;
* `UnitalMagmaDefect.exists_unital_magma_maximal_defect` : for every `n ≥ 3` there is a unital
  magma of cardinality `n` with `defect = (n-1)^3`, i.e. the bound above is sharp;
* `UnitalMagmaDefect.AdjoinOne.defect_eq` : freely adjoining a unit to a magma changes no
  associativity defect, so every defect profile occurs for a *unital* magma;
* `UnitalMagmaDefect.shiftMagma_not_strict` / `shiftMagma_coherent` : the corresponding
  codiscrete bicategory is genuinely weak (not strict), yet all of its 2-cells are invertible
  and any two parallel 2-cells agree.
-/
import Mathlib
import Combinatorics.CodiscreteMagmaBicategory

universe u

open Finset CategoryTheory

namespace UnitalMagmaDefect

section Defect

variable (M : Type u) [Mul M] [Fintype M] [DecidableEq M]

/-- The set of triples at which associativity fails. -/
def defectSet : Finset (M × M × M) :=
  univ.filter fun t => (t.1 * t.2.1) * t.2.2 ≠ t.1 * (t.2.1 * t.2.2)

/-- The associativity defect of a finite magma: the number of non-associative triples. -/
def defect : ℕ := (defectSet M).card

variable {M}

@[simp] lemma mem_defectSet {a b c : M} :
    (a, b, c) ∈ defectSet M ↔ (a * b) * c ≠ a * (b * c) := by
  simp [defectSet]

/-- The defect vanishes exactly for semigroups. -/
theorem defect_eq_zero_iff : defect M = 0 ↔ ∀ a b c : M, (a * b) * c = a * (b * c) := by
  rw [defect, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
  constructor
  · intro h a b c
    by_contra hne
    exact h (a, b, c) (mem_defectSet.2 hne)
  · rintro h ⟨a, b, c⟩ hmem
    exact (mem_defectSet.1 hmem) (h a b c)

/-- The trivial bound: there are at most `(card M)^3` triples. -/
theorem defect_le_cube : defect M ≤ (Fintype.card M) ^ 3 := by
  have h2 : Fintype.card (M × M × M) = Fintype.card M ^ 3 := by
    rw [Fintype.card_prod, Fintype.card_prod]; ring
  calc defect M ≤ (univ : Finset (M × M × M)).card := Finset.card_filter_le _ _
    _ = Fintype.card (M × M × M) := Finset.card_univ
    _ = Fintype.card M ^ 3 := h2

/-- The set of triples at which associativity holds. -/
def assocSet (M : Type u) [Mul M] [Fintype M] [DecidableEq M] : Finset (M × M × M) :=
  univ.filter fun t => (t.1 * t.2.1) * t.2.2 = t.1 * (t.2.1 * t.2.2)

/-- The number of associative triples of a finite magma. -/
def assocCount (M : Type u) [Mul M] [Fintype M] [DecidableEq M] : ℕ := (assocSet M).card

@[simp] lemma mem_assocSet {a b c : M} :
    (a, b, c) ∈ assocSet M ↔ (a * b) * c = a * (b * c) := by
  simp [assocSet]

/-- Associative and defective triples partition all triples. -/
theorem assocCount_add_defect : assocCount M + defect M = Fintype.card M ^ 3 := by
  have hpart : (assocSet M).card + (defectSet M).card = (univ : Finset (M × M × M)).card :=
    Finset.card_filter_add_card_filter_not (p := fun t : M × M × M =>
      (t.1 * t.2.1) * t.2.2 = t.1 * (t.2.1 * t.2.2))
  have h2 : Fintype.card (M × M × M) = Fintype.card M ^ 3 := by
    rw [Fintype.card_prod, Fintype.card_prod]; ring
  rw [assocCount, defect, hpart, Finset.card_univ, h2]

end Defect

section Product

variable {M : Type u} {N : Type u} [Mul M] [Mul N] [Fintype M] [Fintype N]
  [DecidableEq M] [DecidableEq N]

/-- **Multiplicativity of the associative-triple count.**  A triple of pairs is associative in
`M × N` iff both of its component triples are associative, whence the count is multiplicative. -/
theorem assocCount_prod : assocCount (M × N) = assocCount M * assocCount N := by
  rw [assocCount, assocCount, assocCount, ← Finset.card_product]
  refine Finset.card_bij'
    (fun t _ => ((t.1.1, t.2.1.1, t.2.2.1), (t.1.2, t.2.1.2, t.2.2.2)))
    (fun p _ => ((p.1.1, p.2.1), (p.1.2.1, p.2.2.1), (p.1.2.2, p.2.2.2))) ?_ ?_ ?_ ?_
  · rintro ⟨⟨a, a'⟩, ⟨b, b'⟩, ⟨c, c'⟩⟩ hmem
    have h := mem_assocSet.1 hmem
    rw [Prod.ext_iff] at h
    simp only [Finset.mem_product]
    exact ⟨mem_assocSet.2 h.1, mem_assocSet.2 h.2⟩
  · rintro ⟨⟨a, b, c⟩, ⟨a', b', c'⟩⟩ hmem
    simp only [Finset.mem_product] at hmem
    refine mem_assocSet.2 ?_
    rw [Prod.ext_iff]
    exact ⟨mem_assocSet.1 hmem.1, mem_assocSet.1 hmem.2⟩
  · rintro ⟨⟨a, a'⟩, ⟨b, b'⟩, ⟨c, c'⟩⟩ _; rfl
  · rintro ⟨⟨a, b, c⟩, ⟨a', b', c'⟩⟩ _; rfl

/-- **The defect of a product.**  Equivalently, the *associativity density* is multiplicative:
`1 - d(M × N) = (1 - d(M))(1 - d(N))` for `d(M) = defect M / (card M)^3`. -/
theorem defect_prod :
    defect (M × N) = (Fintype.card M * Fintype.card N) ^ 3 - assocCount M * assocCount N := by
  have h := assocCount_add_defect (M := M × N)
  rw [assocCount_prod, Fintype.card_prod] at h
  omega

end Product

section Invariance

/-- The opposite of a finite type is finite. -/
instance fintypeMulOpposite (α : Type u) [Fintype α] : Fintype αᵐᵒᵖ :=
  ⟨(Finset.univ : Finset α).map ⟨MulOpposite.op, MulOpposite.op_injective⟩, by
    intro x
    simp only [Finset.mem_map, Finset.mem_univ, true_and, Function.Embedding.coeFn_mk]
    exact ⟨x.unop, rfl⟩⟩

/-- Equality in the opposite type is decidable. -/
instance decidableEqMulOpposite (α : Type u) [DecidableEq α] : DecidableEq αᵐᵒᵖ :=
  fun x y => decidable_of_iff (x.unop = y.unop)
    ⟨fun h => MulOpposite.unop_injective h, fun h => by rw [h]⟩

variable {M : Type u} {N : Type u} [Mul M] [Mul N] [Fintype M] [Fintype N]
  [DecidableEq M] [DecidableEq N]

/-- The defect is an isomorphism invariant of magmas. -/
theorem defect_congr (e : M ≃* N) : defect M = defect N := by
  rw [defect, defect]
  refine Finset.card_bij' (fun t _ => (e t.1, e t.2.1, e t.2.2))
    (fun s _ => (e.symm s.1, e.symm s.2.1, e.symm s.2.2)) ?_ ?_ ?_ ?_
  · rintro ⟨a, b, c⟩ ht
    refine mem_defectSet.2 fun hEq => (mem_defectSet.1 ht) ?_
    apply e.injective
    simpa only [map_mul] using hEq
  · rintro ⟨x, y, z⟩ hs
    refine mem_defectSet.2 fun hEq => (mem_defectSet.1 hs) ?_
    apply e.symm.injective
    simpa only [map_mul] using hEq
  · rintro ⟨a, b, c⟩ _; simp
  · rintro ⟨x, y, z⟩ _; simp

/-- **Reversal invariance.**  A magma and its opposite have the same associativity defect:
`(a,b,c) ↦ (c,b,a)` is a bijection between their defect sets. -/
theorem defect_op : defect (Mᵐᵒᵖ) = defect M := by
  rw [defect, defect]
  refine Finset.card_bij'
    (fun t _ => (MulOpposite.unop t.2.2, MulOpposite.unop t.2.1, MulOpposite.unop t.1))
    (fun s _ => (MulOpposite.op s.2.2, MulOpposite.op s.2.1, MulOpposite.op s.1)) ?_ ?_ ?_ ?_
  · rintro ⟨x, y, z⟩ ht
    have hne := mem_defectSet.1 ht
    refine mem_defectSet.2 fun hEq => hne ?_
    apply MulOpposite.unop_injective
    simpa only [MulOpposite.unop_mul] using hEq.symm
  · rintro ⟨a, b, c⟩ hs
    have hne := mem_defectSet.1 hs
    refine mem_defectSet.2 fun hEq => hne ?_
    apply MulOpposite.op_injective
    simpa only [MulOpposite.op_mul] using hEq.symm
  · rintro ⟨x, y, z⟩ _; simp
  · rintro ⟨a, b, c⟩ _; simp

end Invariance

section Commutative

variable {M : Type u} [Mul M] [Fintype M] [DecidableEq M] (hcomm : ∀ a b : M, a * b = b * a)

include hcomm

omit [Fintype M] [DecidableEq M] in
/-- In a commutative magma a *palindromic* triple `(a, b, a)` is always associative:
both `(a*b)*a` and `a*(b*a)` equal `a*(a*b)`. -/
theorem palindrome_assoc (a b : M) : (a * b) * a = a * (b * a) := by
  rw [hcomm (a * b) a, hcomm b a]

/-- The reversal `(a, b, c) ↦ (c, b, a)` maps defect triples to defect triples. -/
theorem reverse_mem_defectSet {a b c : M} (h : (a, b, c) ∈ defectSet M) :
    (c, b, a) ∈ defectSet M := by
  have hne := mem_defectSet.1 h
  refine mem_defectSet.2 fun hEq => hne ?_
  have h1 : (c * b) * a = a * (b * c) := by
    rw [hcomm (c * b) a, hcomm c b]
  have h2 : c * (b * a) = (a * b) * c := by
    rw [hcomm b a, hcomm c (a * b)]
  rw [h1, h2] at hEq
  exact hEq.symm

/-- **Parity theorem.**  The associativity defect of a finite *commutative* magma is always even:
the reversal involution `(a,b,c) ↦ (c,b,a)` acts on the defect set without fixed points, since
palindromic triples are automatically associative. -/
theorem defect_even_of_comm : Even (defect M) := by
  have hsum : ∑ _t ∈ defectSet M, (1 : ZMod 2) = 0 := by
    refine Finset.sum_involution (fun t _ => (t.2.2, t.2.1, t.1)) (fun t _ => by decide)
      (fun t ht _ => ?_) (fun t ht => ?_) (fun t _ => rfl)
    · rintro hfix
      obtain ⟨a, b, c⟩ := t
      have hac : c = a := congrArg Prod.fst hfix
      subst hac
      exact (mem_defectSet.1 ht) (palindrome_assoc hcomm _ _)
    · obtain ⟨a, b, c⟩ := t
      exact reverse_mem_defectSet hcomm ht
  rw [Finset.sum_const, nsmul_eq_mul, mul_one] at hsum
  exact ZMod.natCast_eq_zero_iff_even.1 hsum

/-- A commutative magma never has exactly one non-associative triple. -/
theorem defect_ne_one_of_comm : defect M ≠ 1 := by
  intro h
  have := defect_even_of_comm hcomm
  rw [h] at this
  simp at this

end Commutative

section Unital

variable {M : Type u} [Mul M] [One M] [Fintype M] [DecidableEq M]
  (hl : ∀ a : M, (1 : M) * a = a) (hr : ∀ a : M, a * (1 : M) = a)

include hl hr

/-- A defect triple never involves the unit. -/
theorem defectSet_subset_nonunit :
    defectSet M ⊆ (univ.erase (1 : M)) ×ˢ ((univ.erase (1 : M)) ×ˢ (univ.erase (1 : M))) := by
  rintro ⟨a, b, c⟩ hmem
  have hne := mem_defectSet.1 hmem
  simp only [Finset.mem_product, Finset.mem_erase, Finset.mem_univ, and_true]
  refine ⟨?_, ?_, ?_⟩
  · rintro rfl; exact hne (by rw [hl, hl])
  · rintro rfl; exact hne (by rw [hl, hr])
  · rintro rfl; exact hne (by rw [hr, hr])

/-- **The unital defect bound.**  A unital magma with `n` elements has at most `(n-1)^3`
non-associative triples: the unit is always associative with everything. -/
theorem defect_le_of_unital : defect M ≤ (Fintype.card M - 1) ^ 3 := by
  have hcard : ((univ.erase (1 : M)) ×ˢ ((univ.erase (1 : M)) ×ˢ (univ.erase (1 : M)))).card
      = (Fintype.card M - 1) ^ 3 := by
    rw [Finset.card_product, Finset.card_product,
      Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ]
    ring
  calc defect M ≤ _ := Finset.card_le_card (defectSet_subset_nonunit hl hr)
    _ = (Fintype.card M - 1) ^ 3 := hcard

end Unital

section CommutativeUnital

variable {M : Type u} [Mul M] [One M] [Fintype M] [DecidableEq M]

omit [Mul M] [One M] [Fintype M] in
/-- The number of non-palindromic triples drawn from a finite set `S` is `|S|^3 - |S|^2`. -/
theorem card_nonpalindromic (S : Finset M) :
    ((S ×ˢ (S ×ˢ S)).filter fun t => t.1 ≠ t.2.2).card = S.card ^ 3 - S.card ^ 2 := by
  classical
  have hpal : ((S ×ˢ (S ×ˢ S)).filter fun t => ¬ t.1 ≠ t.2.2)
      = (S ×ˢ S).image (fun p : M × M => (p.1, p.2, p.1)) := by
    ext ⟨a, b, c⟩
    simp only [Finset.mem_filter, Finset.mem_product, Finset.mem_image, not_not, Prod.mk.injEq,
      Prod.exists]
    constructor
    · rintro ⟨⟨ha, hb, _⟩, rfl⟩
      exact ⟨a, b, ⟨ha, hb⟩, rfl, rfl, rfl⟩
    · rintro ⟨x, y, ⟨hx, hy⟩, rfl, rfl, rfl⟩
      exact ⟨⟨hx, hy, hx⟩, rfl⟩
  have hinj : Function.Injective (fun p : M × M => (p.1, p.2, p.1)) := by
    rintro ⟨a, b⟩ ⟨a', b'⟩ h
    simp only [Prod.mk.injEq] at h
    exact Prod.ext h.1 h.2.1
  have hpalcard : ((S ×ˢ (S ×ˢ S)).filter fun t => ¬ t.1 ≠ t.2.2).card = S.card ^ 2 := by
    rw [hpal, Finset.card_image_of_injective _ hinj, Finset.card_product]; ring
  have htot : (S ×ˢ (S ×ˢ S)).card = S.card ^ 3 := by
    rw [Finset.card_product, Finset.card_product]; ring
  have hsplit := Finset.card_filter_add_card_filter_not (s := S ×ˢ (S ×ˢ S))
    (p := fun t : M × M × M => t.1 ≠ t.2.2)
  omega

/-- **The commutative unital bound.**  For a *commutative* unital magma with `n` elements the
defect is at most `(n-1)^3 - (n-1)^2`: on top of the unit triples, all palindromic triples
`(a, b, a)` are forced to be associative. -/
theorem defect_le_of_comm_unital (hcomm : ∀ a b : M, a * b = b * a)
    (hl : ∀ a : M, (1 : M) * a = a) (hr : ∀ a : M, a * (1 : M) = a) :
    defect M ≤ (Fintype.card M - 1) ^ 3 - (Fintype.card M - 1) ^ 2 := by
  classical
  set S : Finset M := univ.erase 1 with hS
  have hSsub : defectSet M ⊆ (S ×ˢ (S ×ˢ S)).filter fun t => t.1 ≠ t.2.2 := by
    intro t ht
    refine Finset.mem_filter.2 ⟨defectSet_subset_nonunit hl hr ht, ?_⟩
    obtain ⟨a, b, c⟩ := t
    rintro (rfl : a = c)
    exact (mem_defectSet.1 ht) (palindrome_assoc hcomm a b)
  have hScard : S.card = Fintype.card M - 1 := by
    rw [hS, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ]
  calc defect M ≤ _ := Finset.card_le_card hSsub
    _ = S.card ^ 3 - S.card ^ 2 := card_nonpalindromic S
    _ = (Fintype.card M - 1) ^ 3 - (Fintype.card M - 1) ^ 2 := by rw [hScard]

end CommutativeUnital

/-! ### The shift magma: a unital magma of maximal defect -/

/-- The **shift magma** attached to a self-map `σ : S → S`: the underlying type is `Option S`,
`none` is a two-sided unit, and the product of two non-units `some a`, `some b` is `some (σ b)`.
-/
@[nolint unusedArguments]
def ShiftMagma {S : Type u} (_σ : S → S) : Type u := Option S

namespace ShiftMagma

variable {S : Type u} (σ : S → S)

instance : One (ShiftMagma σ) := ⟨(none : Option S)⟩

instance : Mul (ShiftMagma σ) :=
  ⟨fun x y =>
    match (x : Option S), (y : Option S) with
    | none, y => y
    | x, none => x
    | some _, some b => (some (σ b) : Option S)⟩

instance [DecidableEq S] : DecidableEq (ShiftMagma σ) := inferInstanceAs (DecidableEq (Option S))

instance [Fintype S] : Fintype (ShiftMagma σ) := inferInstanceAs (Fintype (Option S))

/-- The element of `ShiftMagma σ` named by `a : S`. -/
def of (a : S) : ShiftMagma σ := (some a : Option S)

variable {σ}

@[simp] lemma one_def : (1 : ShiftMagma σ) = (none : Option S) := rfl

@[simp] lemma one_mul' (x : ShiftMagma σ) : (1 : ShiftMagma σ) * x = x := rfl

@[simp] lemma mul_one' (x : ShiftMagma σ) : x * (1 : ShiftMagma σ) = x := by
  cases (x : Option S) <;> rfl

@[simp] lemma of_mul_of (a b : S) : of σ a * of σ b = of σ (σ b) := rfl

lemma of_injective : Function.Injective (of σ) := fun _ _ h => Option.some_injective _ h

lemma of_ne_one (a : S) : of σ a ≠ 1 := fun h =>
  Option.some_ne_none a (show (some a : Option S) = none from h)

lemma eq_one_or_of (x : ShiftMagma σ) : x = 1 ∨ ∃ a : S, x = of σ a := by
  rcases (x : Option S) with _ | a
  · exact Or.inl rfl
  · exact Or.inr ⟨a, rfl⟩

variable [Fintype S] [DecidableEq S]

/-- If `σ` has no fixed point, then **every** triple of non-units is a defect triple. -/
theorem defectSet_eq (hσ : ∀ x, σ x ≠ x) :
    defectSet (ShiftMagma σ) =
      (univ.erase (1 : ShiftMagma σ)) ×ˢ
        ((univ.erase (1 : ShiftMagma σ)) ×ˢ (univ.erase (1 : ShiftMagma σ))) := by
  apply Finset.Subset.antisymm
  · exact defectSet_subset_nonunit one_mul' mul_one'
  · rintro ⟨x, y, z⟩ hmem
    simp only [Finset.mem_product, Finset.mem_erase, Finset.mem_univ, and_true] at hmem
    obtain ⟨hx, hy, hz⟩ := hmem
    obtain ⟨a, rfl⟩ := (eq_one_or_of x).resolve_left hx
    obtain ⟨b, rfl⟩ := (eq_one_or_of y).resolve_left hy
    obtain ⟨c, rfl⟩ := (eq_one_or_of z).resolve_left hz
    refine mem_defectSet.2 ?_
    simp only [of_mul_of]
    intro h
    exact hσ (σ c) (of_injective h).symm

/-- **Maximal defect.**  For a fixed-point-free `σ`, the unital magma `ShiftMagma σ` attains the
bound `defect = (card - 1)^3`. -/
theorem defect_eq (hσ : ∀ x, σ x ≠ x) :
    defect (ShiftMagma σ) = (Fintype.card (ShiftMagma σ) - 1) ^ 3 := by
  rw [defect, defectSet_eq hσ, Finset.card_product, Finset.card_product,
    Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ]
  ring

/-- In terms of the underlying type: the defect is `(card S)^3`. -/
theorem defect_eq_card (hσ : ∀ x, σ x ≠ x) : defect (ShiftMagma σ) = (Fintype.card S) ^ 3 := by
  have hc : Fintype.card (ShiftMagma σ) = Fintype.card S + 1 :=
    Fintype.card_option (α := S)
  rw [defect_eq hσ, hc]
  simp

end ShiftMagma

/-! ### Sharpness of the bound for every cardinality -/

/-- The cyclic shift on `Fin m`, for `m ≥ 2`: a fixed-point-free self-map. -/
def cyclicShift (m : ℕ) (c : Fin m) : Fin m :=
  if h : c.val + 1 < m then ⟨c.val + 1, h⟩ else ⟨0, lt_of_le_of_lt (Nat.zero_le _) c.isLt⟩

theorem cyclicShift_ne (m : ℕ) (hm : 2 ≤ m) (c : Fin m) : cyclicShift m c ≠ c := by
  unfold cyclicShift
  split_ifs with h
  · intro hc
    have := congrArg Fin.val hc
    simp at this
  · intro hc
    have hval := congrArg Fin.val hc
    simp only at hval
    have hlt := c.isLt
    omega

/-- **Sharpness.**  For every `n ≥ 3` there is a unital magma with `n` elements whose
associativity defect equals `(n-1)^3`, the maximum allowed by `defect_le_of_unital`. -/
theorem exists_unital_magma_maximal_defect (n : ℕ) (hn : 3 ≤ n) :
    ∃ (M : Type) (_ : Mul M) (_ : One M) (_ : Fintype M) (_ : DecidableEq M),
      Fintype.card M = n ∧ (∀ a : M, (1 : M) * a = a) ∧ (∀ a : M, a * (1 : M) = a) ∧
        defect M = (n - 1) ^ 3 := by
  set m := n - 1 with hm
  have hm2 : 2 ≤ m := by omega
  refine ⟨ShiftMagma (cyclicShift m), inferInstance, inferInstance, inferInstance, inferInstance,
    ?_, ShiftMagma.one_mul', ShiftMagma.mul_one', ?_⟩
  · have : Fintype.card (ShiftMagma (cyclicShift m)) = Fintype.card (Fin m) + 1 :=
      Fintype.card_option (α := Fin m)
    simp only [Fintype.card_fin] at this
    omega
  · rw [ShiftMagma.defect_eq_card (cyclicShift_ne m hm2)]
    simp

/-! ### The negation magma: a commutative unital magma of maximal defect -/

/-- The **negation magma** of an additive abelian group `G`: the underlying type is `Option G`,
`none` is a two-sided unit, and `some a * some b = some (-(a + b))`. -/
def NegMagma (G : Type u) [AddCommGroup G] : Type u := Option G

namespace NegMagma

variable {G : Type u} [AddCommGroup G]

instance : One (NegMagma G) := ⟨(none : Option G)⟩

instance : Mul (NegMagma G) :=
  ⟨fun x y =>
    match (x : Option G), (y : Option G) with
    | none, y => y
    | x, none => x
    | some a, some b => (some (-(a + b)) : Option G)⟩

instance [DecidableEq G] : DecidableEq (NegMagma G) := inferInstanceAs (DecidableEq (Option G))

instance [Fintype G] : Fintype (NegMagma G) := inferInstanceAs (Fintype (Option G))

/-- The element of `NegMagma G` named by `a : G`. -/
def of (a : G) : NegMagma G := (some a : Option G)

@[simp] lemma one_mul' (x : NegMagma G) : (1 : NegMagma G) * x = x := rfl

@[simp] lemma mul_one' (x : NegMagma G) : x * (1 : NegMagma G) = x := by
  cases (x : Option G) <;> rfl

@[simp] lemma of_mul_of (a b : G) : of a * of b = of (-(a + b)) := rfl

lemma of_injective : Function.Injective (of : G → NegMagma G) :=
  fun _ _ h => Option.some_injective _ h

lemma eq_one_or_of (x : NegMagma G) : x = 1 ∨ ∃ a : G, x = of a := by
  rcases (x : Option G) with _ | a
  · exact Or.inl rfl
  · exact Or.inr ⟨a, rfl⟩

/-- The negation magma is commutative. -/
lemma mul_comm' (x y : NegMagma G) : x * y = y * x := by
  rcases eq_one_or_of x with rfl | ⟨a, rfl⟩
  · rw [one_mul', mul_one']
  rcases eq_one_or_of y with rfl | ⟨b, rfl⟩
  · rw [one_mul', mul_one']
  rw [of_mul_of, of_mul_of, add_comm]

variable [Fintype G] [DecidableEq G]

/-- In the negation magma, a triple of non-units is defective exactly when its outer entries
differ -- provided `G` has no `2`-torsion. -/
theorem of_mem_defectSet_iff (h2 : ∀ x y : G, x + x = y + y → x = y) (a b c : G) :
    ((of a : NegMagma G), of b, of c) ∈ defectSet (NegMagma G) ↔ a ≠ c := by
  rw [mem_defectSet]
  simp only [of_mul_of]
  constructor
  · intro hne hac
    refine hne (congrArg of ?_)
    subst hac
    abel
  · intro hac heq
    have h := of_injective heq
    have h' : a + a = c + c := by
      have hshift := congrArg (fun z : G => z + (a + c - b)) h
      simp only at hshift
      abel_nf at hshift
      simpa [two_zsmul] using hshift
    exact hac (h2 a c h')

/-- **Maximal commutative defect.**  If `G` has no `2`-torsion, the commutative unital magma
`NegMagma G` attains the commutative bound `(n-1)^3 - (n-1)^2`. -/
theorem defect_eq (h2 : ∀ x y : G, x + x = y + y → x = y) :
    defect (NegMagma G) = (Fintype.card G) ^ 3 - (Fintype.card G) ^ 2 := by
  classical
  set S : Finset (NegMagma G) := univ.erase 1 with hS
  have hset : defectSet (NegMagma G) = (S ×ˢ (S ×ˢ S)).filter fun t => t.1 ≠ t.2.2 := by
    apply Finset.Subset.antisymm
    · intro t ht
      refine Finset.mem_filter.2 ⟨defectSet_subset_nonunit one_mul' mul_one' ht, ?_⟩
      obtain ⟨x, y, z⟩ := t
      rintro (rfl : x = z)
      exact (mem_defectSet.1 ht) (palindrome_assoc mul_comm' x y)
    · rintro ⟨x, y, z⟩ hmem
      rw [Finset.mem_filter] at hmem
      obtain ⟨hprod, hne⟩ := hmem
      simp only [hS, Finset.mem_product, Finset.mem_erase, Finset.mem_univ, and_true] at hprod
      obtain ⟨hx, hy, hz⟩ := hprod
      obtain ⟨a, rfl⟩ := (eq_one_or_of x).resolve_left hx
      obtain ⟨b, rfl⟩ := (eq_one_or_of y).resolve_left hy
      obtain ⟨c, rfl⟩ := (eq_one_or_of z).resolve_left hz
      exact (of_mem_defectSet_iff h2 a b c).2 fun hac => hne (by rw [hac])
  have hScard : S.card = Fintype.card G := by
    rw [hS, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ,
      show Fintype.card (NegMagma G) = Fintype.card G + 1 from Fintype.card_option (α := G)]
    omega
  rw [defect, hset, card_nonpalindromic, hScard]

end NegMagma

/-- **Sharpness of the commutative bound.**  For every odd `m ≥ 3` there is a *commutative*
unital magma with `n = m + 1` elements and defect exactly `(n-1)^3 - (n-1)^2`. -/
theorem exists_comm_unital_magma_maximal_defect (m : ℕ) (hodd : Odd m) (hm : 3 ≤ m) :
    ∃ (M : Type) (_ : Mul M) (_ : One M) (_ : Fintype M) (_ : DecidableEq M),
      Fintype.card M = m + 1 ∧ (∀ a b : M, a * b = b * a) ∧ (∀ a : M, (1 : M) * a = a) ∧
        (∀ a : M, a * (1 : M) = a) ∧ defect M = m ^ 3 - m ^ 2 := by
  haveI : NeZero m := ⟨by omega⟩
  have h2 : ∀ x y : ZMod m, x + x = y + y → x = y := by
    intro x y hxy
    have hcop : Nat.Coprime 2 m := Nat.coprime_two_left.2 hodd
    have hunit : IsUnit (2 : ZMod m) := by
      have := (ZMod.isUnit_iff_coprime 2 m).2 hcop
      simpa using this
    have h2x : (2 : ZMod m) * x = (2 : ZMod m) * y := by
      rw [two_mul, two_mul]; exact hxy
    exact hunit.mul_left_cancel h2x
  refine ⟨NegMagma (ZMod m), inferInstance, inferInstance, inferInstance, inferInstance, ?_,
    NegMagma.mul_comm', NegMagma.one_mul', NegMagma.mul_one', ?_⟩
  · rw [show Fintype.card (NegMagma (ZMod m)) = Fintype.card (ZMod m) + 1 from
      Fintype.card_option (α := ZMod m), ZMod.card]
  · rw [NegMagma.defect_eq h2, ZMod.card]

/-! ### Adjoining a unit does not change the defect -/

/-- Freely adjoining a unit to a magma `α`. -/
def AdjoinOne (α : Type u) : Type u := Option α

namespace AdjoinOne

variable {α : Type u} [Mul α]

instance : One (AdjoinOne α) := ⟨(none : Option α)⟩

instance : Mul (AdjoinOne α) :=
  ⟨fun x y =>
    match (x : Option α), (y : Option α) with
    | none, y => y
    | x, none => x
    | some a, some b => (some (a * b) : Option α)⟩

instance [DecidableEq α] : DecidableEq (AdjoinOne α) := inferInstanceAs (DecidableEq (Option α))

instance [Fintype α] : Fintype (AdjoinOne α) := inferInstanceAs (Fintype (Option α))

/-- The image of `a : α` in `AdjoinOne α`. -/
def of (a : α) : AdjoinOne α := (some a : Option α)

@[simp] lemma one_mul' (x : AdjoinOne α) : (1 : AdjoinOne α) * x = x := rfl

@[simp] lemma mul_one' (x : AdjoinOne α) : x * (1 : AdjoinOne α) = x := by
  cases (x : Option α) <;> rfl

@[simp] lemma of_mul_of (a b : α) : of a * of b = of (a * b) := rfl

omit [Mul α] in
lemma of_injective : Function.Injective (of : α → AdjoinOne α) :=
  fun _ _ h => Option.some_injective _ h

omit [Mul α] in
lemma of_ne_one (a : α) : (of a : AdjoinOne α) ≠ 1 := fun h =>
  Option.some_ne_none a (show (some a : Option α) = none from h)

omit [Mul α] in
lemma eq_one_or_of (x : AdjoinOne α) : x = 1 ∨ ∃ a : α, x = of a := by
  rcases (x : Option α) with _ | a
  · exact Or.inl rfl
  · exact Or.inr ⟨a, rfl⟩

variable [Fintype α] [DecidableEq α]

/-- The defect triples of `AdjoinOne α` are exactly the images of the defect triples of `α`. -/
theorem defectSet_eq_image :
    defectSet (AdjoinOne α)
      = (defectSet α).image (fun t => ((of t.1 : AdjoinOne α), of t.2.1, of t.2.2)) := by
  ext ⟨x, y, z⟩
  constructor
  · intro hmem
    have hsub := defectSet_subset_nonunit (M := AdjoinOne α) one_mul' mul_one' hmem
    simp only [Finset.mem_product, Finset.mem_erase, Finset.mem_univ, and_true] at hsub
    obtain ⟨hx, hy, hz⟩ := hsub
    obtain ⟨a, rfl⟩ := (eq_one_or_of x).resolve_left hx
    obtain ⟨b, rfl⟩ := (eq_one_or_of y).resolve_left hy
    obtain ⟨c, rfl⟩ := (eq_one_or_of z).resolve_left hz
    refine Finset.mem_image.2 ⟨(a, b, c), mem_defectSet.2 ?_, rfl⟩
    intro h
    exact (mem_defectSet.1 hmem) (by simp only [of_mul_of, h])
  · intro h
    obtain ⟨⟨a, b, c⟩, hm, heq⟩ := Finset.mem_image.1 h
    obtain ⟨rfl, rfl, rfl⟩ := Prod.mk.injEq .. ▸ heq.symm
    refine mem_defectSet.2 ?_
    simp only [of_mul_of]
    intro hh
    exact (mem_defectSet.1 hm) (of_injective hh)

/-- **Unitalisation preserves the defect.**  Every associativity defect profile of an arbitrary
finite magma is realised by a unital magma of one more element. -/
theorem defect_eq : defect (AdjoinOne α) = defect α := by
  have hinj : Function.Injective
      (fun t : α × α × α => ((of t.1 : AdjoinOne α), of t.2.1, of t.2.2)) := by
    rintro ⟨a, b, c⟩ ⟨a', b', c'⟩ h
    simp only [Prod.mk.injEq] at h
    obtain ⟨h1, h2, h3⟩ := h
    exact Prod.ext (of_injective h1) (Prod.ext (of_injective h2) (of_injective h3))
  rw [defect, defect, defectSet_eq_image, Finset.card_image_of_injective _ hinj]

end AdjoinOne

/-! ### A worked example: the smallest maximal-defect unital magma -/

/-- The three-element shift magma `{1, a, b}` with `a * b = σ b`, `σ` the transposition of
`Bool`.  All `8 = (3-1)^3` triples of non-units are non-associative, matching
`ShiftMagma.defect_eq`, and this is the smallest possible example. -/
example : defect (ShiftMagma (fun b : Bool => !b)) = 8 := by decide

/-- The general theorem specialises to the same value. -/
example : defect (ShiftMagma (fun b : Bool => !b)) = 8 := by
  rw [ShiftMagma.defect_eq_card (fun b => by cases b <;> simp)]
  simp

/-! ### Consequences for the codiscrete bicategory -/

open CodiscreteMagma

/-- The codiscrete bicategory of a maximal-defect shift magma is **not** strict. -/
theorem shiftMagma_not_strict {S : Type u} (σ : S → S) (hσ : ∀ x, σ x ≠ x) (a : S) :
    ¬ Bicategory.Strict (MagmaBicat (ShiftMagma σ)) := by
  refine not_strict_of_defect (Or.inl ⟨ShiftMagma.of σ a, ShiftMagma.of σ a,
    ShiftMagma.of σ a, ?_⟩)
  simp only [ShiftMagma.of_mul_of]
  intro h
  exact hσ (σ a) (ShiftMagma.of_injective h).symm

/-- ... and yet it is perfectly coherent: all 2-cells are invertible and any two parallel
2-cells agree. -/
theorem shiftMagma_coherent {S : Type u} (σ : S → S)
    (f g : star (ShiftMagma σ) ⟶ star (ShiftMagma σ)) (η θ : f ⟶ g) : η = θ ∧ IsIso η :=
  ⟨two_cell_unique η θ, two_cell_isIso η⟩

variable {M : Type u} [Mul M] [One M] [Fintype M] [DecidableEq M]

/-- 1-cells of `MagmaBicat M` have decidable equality when `M` does. -/
instance decidableEqOneCell : DecidableEq (star M ⟶ star M) :=
  inferInstanceAs (DecidableEq (Codiscrete M))

/-- **The defect counts the genuinely weak associators.**  In `MagmaBicat M` the associator at
`(a,b,c)` is an invertible 2-cell between *distinct* 1-cells exactly at the defect triples, so the
number of non-identity associator instances is `defect M`. -/
theorem card_nonidentity_associators :
    (univ.filter fun t : M × M × M =>
        (cell t.1 ≫ cell t.2.1) ≫ cell t.2.2 ≠ cell t.1 ≫ (cell t.2.1 ≫ cell t.2.2)).card
      = defect M := by
  rw [defect, defectSet]
  refine congrArg Finset.card (Finset.filter_congr ?_)
  rintro ⟨a, b, c⟩ _
  simp only [comp_cell, ne_eq, cell_eq_cell]

/-- **Strictness ↔ zero defect.**  For a unital magma the codiscrete bicategory is a `2`-category
precisely when the combinatorial defect vanishes; otherwise all `defect M` associator instances
are genuinely non-identity invertible 2-cells. -/
theorem strict_iff_defect_zero (hl : ∀ a : M, (1 : M) * a = a) (hr : ∀ a : M, a * (1 : M) = a) :
    Bicategory.Strict (MagmaBicat M) ↔ defect M = 0 := by
  rw [defect_eq_zero_iff, strict_iff_monoid]
  exact ⟨fun h => h.1, fun h => ⟨h, hl, hr⟩⟩

end UnitalMagmaDefect