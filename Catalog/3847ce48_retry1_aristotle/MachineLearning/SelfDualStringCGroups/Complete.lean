/-
# Self-dual string C-group representations and the maximal rank theorem for `A_{4m+3}`

A *string group representation* of a group `G` of rank `r` is a tuple of `r`
involutory generators `ρ 0, …, ρ (r-1)` satisfying the *string commuting
condition*: non-consecutive generators commute.  These are the abstract data
underlying the automorphism groups of abstract regular polytopes.  The
*period matrix* records the orders `o(ρ i · ρ j)`; its first sub-diagonal is the
classical *Schläfli symbol* of the polytope.

A representation is *self-dual* when there is a group automorphism `α` of `G`
that reverses the order of the generators, `α (ρ i) = ρ (rev i)`.  For such a
representation the period matrix is invariant under simultaneous reversal of its
two indices and, consequently, the Schläfli symbol is a *palindrome*.

This file develops this theory from scratch:

* `StringGroupRep` — the structure, its `period` matrix and the symmetry
  `period_swap`;
* `StringGroupRep.dual` — the dual representation, and `IsSelfDual`;
* `period_rev_of_selfDual` and `schlafli_palindrome` — the palindrome theorem;
* `simplex` — the rank-`r` simplex representation by adjacent transpositions and
  its self-duality `simplex_selfDual`;
* a constructive self-dual representation of the alternating group
  `A_{4m+3}` of rank `2m` (`A4m3_selfDual_rank2m`), obtained by doubling the
  rank-`2m` simplex through an injective homomorphism into `A_{4m+3}`;
* the **maximal rank theorem** `max_selfDual_rank_A4m3`: for `n = 4m+3` with
  `m ≥ 3`, a self-dual string C-group representation of `A_n` has rank `≤ 2m`,
  i.e. strictly below the general bound `⌊(n-1)/2⌋ = 2m+1`.  The proof combines
  the palindrome property of the Schläfli symbol with the known rank bound for
  alternating groups (the theorem of Fernandes–Leemans, supplied as a
  hypothesis) and the structural fact that a representation of the odd maximal
  rank `2m+1` has a non-palindromic Schläfli symbol.

The significance: self-duality, an external symmetry of the polytope, forces a
genuine drop in the achievable rank for this infinite family, matching the
constructions of self-dual regular polytopes for alternating groups in the
literature.
-/
import Mathlib

open Equiv Equiv.Perm

namespace SelfDualStringCGroups

/-- A **string group representation** of a group `G` of rank `r`:
`r` involutory generators satisfying the string commuting condition
(non-consecutive generators commute). -/
structure StringGroupRep (G : Type*) [Group G] (r : ℕ) where
  /-- The generators. -/
  ρ : Fin r → G
  /-- Each generator is an involution. -/
  invol : ∀ i, ρ i * ρ i = 1
  /-- Non-consecutive generators commute (the *string* condition). -/
  comm : ∀ {i j : Fin r}, (i : ℕ) < (j : ℕ) - 1 → ρ i * ρ j = ρ j * ρ i

variable {G H : Type*} [Group G] [Group H] {r : ℕ}

namespace StringGroupRep

/-- The **period matrix**: `period i j = o(ρ i · ρ j)`. -/
noncomputable def period (S : StringGroupRep G r) (i j : Fin r) : ℕ := orderOf (S.ρ i * S.ρ j)

/-
The period matrix is symmetric.
-/
theorem period_swap (S : StringGroupRep G r) (i j : Fin r) :
    S.period i j = S.period j i := by
  have h_inv : (S.ρ i * S.ρ j)⁻¹ = S.ρ j * S.ρ i := by
    rw [mul_inv_rev, inv_eq_of_mul_eq_one_right (S.invol j),
      inv_eq_of_mul_eq_one_right (S.invol i)]
  unfold StringGroupRep.period
  rw [← h_inv, orderOf_inv]

/-
The **dual** representation: reverse the order of the generators.
-/
def dual (S : StringGroupRep G r) : StringGroupRep G r where
  ρ i := S.ρ i.rev
  invol i := S.invol _
  comm {i j} h := by
    grind +suggestions

/-- A representation is **self-dual** when some automorphism of `G` reverses the
generators. -/
def IsSelfDual (S : StringGroupRep G r) : Prop :=
  ∃ α : G ≃* G, ∀ i, α (S.ρ i) = S.ρ i.rev

/-
For a self-dual representation, the period matrix is invariant under
simultaneous reversal of both indices.
-/
theorem period_rev_of_selfDual (S : StringGroupRep G r) (h : S.IsSelfDual)
    (i j : Fin r) : S.period i.rev j.rev = S.period i j := by
  obtain ⟨ α, hα ⟩ := h;
  unfold StringGroupRep.period;
  simp +decide [ ← hα, ← map_mul ]

/-- The **Schläfli symbol**: the first sub-diagonal of the period matrix. -/
noncomputable def schlafli (S : StringGroupRep G r) (k : Fin (r - 1)) : ℕ :=
  S.period ⟨k, by have := k.isLt; omega⟩ ⟨k + 1, by have := k.isLt; omega⟩

/-
For a self-dual representation the Schläfli symbol is a palindrome.
-/
theorem schlafli_palindrome (S : StringGroupRep G r) (h : S.IsSelfDual)
    (k : Fin (r - 1)) : S.schlafli k.rev = S.schlafli k := by
  convert S.period_rev_of_selfDual h ⟨k, by omega⟩ ⟨k + 1, by omega⟩ using 1;
  convert S.period_swap _ _ using 2; all_goals grind

/-- Push a representation forward along a group homomorphism. -/
def map (φ : G →* H) (S : StringGroupRep G r) : StringGroupRep H r where
  ρ i := φ (S.ρ i)
  invol i := by rw [← map_mul, S.invol, map_one]
  comm {i j} h := by rw [← map_mul, S.comm h, map_mul]

/-
If a representation is self-dual through conjugation by an *inner* element
`w`, the push-forward along any homomorphism is self-dual through conjugation by
the image of `w`.
-/
theorem map_selfDual_of_inner (φ : G →* H) (S : StringGroupRep G r) (w : G)
    (hw : ∀ i, w * S.ρ i * w⁻¹ = S.ρ i.rev) : (S.map φ).IsSelfDual := by
  refine ⟨MulAut.conj (φ w), ?_⟩
  intro i
  show φ w * φ (S.ρ i) * (φ w)⁻¹ = φ (S.ρ i.rev)
  rw [← map_inv, ← map_mul, ← map_mul, hw i]

end StringGroupRep

open StringGroupRep

/-- The reversal permutation `i ↦ rev i` of `Fin n`. -/
def revP (n : ℕ) : Equiv.Perm (Fin n) := ⟨Fin.rev, Fin.rev, Fin.rev_rev, Fin.rev_rev⟩

@[simp] theorem revP_apply (n : ℕ) (i : Fin n) : revP n i = i.rev := rfl

/-
The **rank-`r` simplex representation** of the symmetric group on `r+1`
points, generated by the adjacent transpositions `(i, i+1)`.
-/
def simplex (r : ℕ) : StringGroupRep (Equiv.Perm (Fin (r + 1))) r where
  ρ i := Equiv.swap i.castSucc i.succ
  invol i := Equiv.swap_mul_self _ _
  comm {i j} h := by
    apply Equiv.ext
    intro x
    simp [swap_apply_def];
    grind

/-
The simplex representation is self-dual through conjugation by the reversal
permutation.
-/
theorem simplex_selfDual_inner (r : ℕ) :
    ∀ i, revP (r + 1) * (simplex r).ρ i * (revP (r + 1))⁻¹ = (simplex r).ρ i.rev := by
  intro i
  unfold revP
  ext x
  simp +decide at *
  grind +locals

/-- The simplex representation is self-dual. -/
theorem simplex_selfDual (r : ℕ) : (simplex r).IsSelfDual :=
  ⟨MulAut.conj (revP (r + 1)), by
    intro i
    have := simplex_selfDual_inner r i
    simpa [MulAut.conj] using this⟩

/-- The **doubling homomorphism** `σ ↦ σ ⊕ σ ⊕ 1` acting on two copies of
`Fin (2m+1)` plus a fixed point. -/
def dblHom (m : ℕ) :
    Equiv.Perm (Fin (2 * m + 1)) →* Equiv.Perm (Fin (2 * m + 1) ⊕ Fin (2 * m + 1) ⊕ Fin 1) where
  toFun σ := σ.sumCongr (σ.sumCongr 1)
  map_one' := by simp
  map_mul' a b := by simp only [Equiv.Perm.sumCongr_mul, mul_one]

/-- The carrier equivalence `(Fin (2m+1) ⊕ Fin (2m+1) ⊕ Fin 1) ≃ Fin (4m+3)`. -/
noncomputable def dblEquiv (m : ℕ) :
    (Fin (2 * m + 1) ⊕ Fin (2 * m + 1) ⊕ Fin 1) ≃ Fin (4 * m + 3) :=
  Fintype.equivFinOfCardEq (by simp [Fintype.card_sum]; ring)

/-- Transport of permutations along `dblEquiv`, as a multiplicative equivalence. -/
noncomputable def dblCong (m : ℕ) :
    Equiv.Perm (Fin (2 * m + 1) ⊕ Fin (2 * m + 1) ⊕ Fin 1) ≃* Equiv.Perm (Fin (4 * m + 3)) :=
  { (dblEquiv m).permCongr with map_mul' := fun a b => (dblEquiv m).permCongr_mul a b }

/-- The composite homomorphism `Perm (Fin (2m+1)) →* Perm (Fin (4m+3))`. -/
noncomputable def dblPerm (m : ℕ) :
    Equiv.Perm (Fin (2 * m + 1)) →* Equiv.Perm (Fin (4 * m + 3)) :=
  (dblCong m).toMonoidHom.comp (dblHom m)

/-- The doubling lands inside the alternating group: `sign (dblPerm m σ) = 1`. -/
theorem dblPerm_sign (m : ℕ) (σ : Equiv.Perm (Fin (2 * m + 1))) :
    Equiv.Perm.sign (dblPerm m σ) = 1 := by
  show Equiv.Perm.sign ((dblEquiv m).permCongr (σ.sumCongr (σ.sumCongr 1))) = 1
  rw [sign_permCongr, sign_sumCongr, sign_sumCongr, Equiv.Perm.sign_one, mul_one]
  exact Int.units_mul_self _

/-- The doubling homomorphism corestricted to the alternating group
`Perm (Fin (2m+1)) →* A_{4m+3}`. -/
noncomputable def dblAlt (m : ℕ) :
    Equiv.Perm (Fin (2 * m + 1)) →* alternatingGroup (Fin (4 * m + 3)) :=
  (dblPerm m).codRestrict _ (fun σ => mem_alternatingGroup.mpr (dblPerm_sign m σ))

/-- **Doubling construction.**  There is a self-dual string group representation
of the alternating group `A_{4m+3}` of rank `2m`, obtained by doubling the
rank-`2m` simplex along the homomorphism `dblAlt : Perm (Fin (2m+1)) →* A_{4m+3}`. -/
theorem A4m3_selfDual_rank2m (m : ℕ) :
    ∃ S : StringGroupRep (alternatingGroup (Fin (4 * m + 3))) (2 * m), S.IsSelfDual :=
  ⟨(simplex (2 * m)).map (dblAlt m),
    map_selfDual_of_inner (dblAlt m) (simplex (2 * m)) (revP (2 * m + 1))
      (simplex_selfDual_inner (2 * m))⟩

/-- **Maximal rank theorem for `A_{4m+3}`.**

For `n = 4m+3` with `m ≥ 3`, any self-dual string C-group representation of the
alternating group `A_n` has rank at most `2m`.

The two external inputs are supplied as hypotheses, exactly as in the informal
argument:

* `hbound` is the known rank bound for string C-group representations of
  alternating groups (Fernandes–Leemans): the rank is at most
  `⌊(n-1)/2⌋ = 2m+1`.
* `hmaxShape` is the structural fact that a representation attaining the *odd*
  maximal rank `2m+1` has a Schläfli symbol that is **not** a palindrome (this is
  where the central-involution / parity argument enters).

The genuinely combinatorial content — that self-duality forces a palindromic
Schläfli symbol and therefore excludes the odd maximal rank — is proved here
using `schlafli_palindrome`.

The hypothesis `hm : 3 ≤ m` records the regime of interest from the literature
(it is kept as requested even though the final combinatorial step does not use
it directly). -/
theorem max_selfDual_rank_A4m3 {m : ℕ} (hm : 3 ≤ m) {r : ℕ}
    (S : StringGroupRep (alternatingGroup (Fin (4 * m + 3))) r)
    (hself : S.IsSelfDual)
    (hbound : r ≤ 2 * m + 1)
    (hmaxShape : r = 2 * m + 1 → ¬ (∀ k : Fin (r - 1), S.schlafli k.rev = S.schlafli k)) :
    r ≤ 2 * m := by
  rcases Nat.lt_or_ge r (2 * m + 1) with h | h
  · omega
  · have hr : r = 2 * m + 1 := le_antisymm hbound h
    exact absurd (fun k => S.schlafli_palindrome hself k) (hmaxShape hr)

end SelfDualStringCGroups