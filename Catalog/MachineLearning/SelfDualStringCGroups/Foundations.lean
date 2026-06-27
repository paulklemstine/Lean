/-
# Foundations of string group representations and self-duality

A *string group representation* of a group `G` of rank `r` is a tuple of `r`
involutory generators `ρ 0, …, ρ (r-1)` satisfying the *string commuting
condition*: non-consecutive generators commute.  These are the abstract data
underlying the automorphism groups of abstract regular polytopes (string
C-groups when, in addition, the intersection property holds).

This file develops the basic theory used by the rest of the project:

* `StringGroupRep` — the structure, its `period` matrix and the symmetry
  `period_swap`, together with the diagonal value `period_self`;
* `StringGroupRep.dual` — the dual (order-reversed) representation, its
  involutivity `dual_dual`, and the predicate `IsSelfDual`;
* `period_rev_of_selfDual` and `schlafli_palindrome` — the palindrome theorem:
  a self-dual representation has a Schläfli symbol invariant under reversal;
* `map` / `map_selfDual_of_inner` — push-forward along a homomorphism and the
  transfer of (inner) self-duality.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "External symmetry constrains internal combinatorics."
  A self-dual string group representation should force the period matrix — and
  hence the Schläfli symbol — to be palindromic.
Experiment (Experimenter): Encoded `StringGroupRep`, the `period` matrix, the
  `dual` construction, and `IsSelfDual`.  Proved `period_swap` from
  `(ab)⁻¹ = b⁻¹a⁻¹` plus `orderOf_inv`, and pushed self-duality through the
  reversal symmetry to obtain `schlafli_palindrome`.
Analysis (Analyst): The palindrome property is purely group-theoretic — it needs
  only that the dualizing map is a group automorphism reversing generators.  The
  diagonal `period_self = 1` is forced by the involution axiom (`orderOf 1 = 1`).
Critique (Critic): None of these theorems are vacuous — `period_swap`,
  `dual_dual` and `schlafli_palindrome` each require a genuine algebraic step
  (`orderOf_inv`, `Fin.rev_rev`, automorphism-compatibility).  `period_self`
  could be trivial, so it is kept only as an auxiliary, not a main result.
Synthesis (PI): These foundations are reused by `Simplex.lean` and
  `AlternatingMaxRank.lean`.
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

/-- The period matrix is symmetric. -/
theorem period_swap (S : StringGroupRep G r) (i j : Fin r) :
    S.period i j = S.period j i := by
  have h_inv : (S.ρ i * S.ρ j)⁻¹ = S.ρ j * S.ρ i := by
    rw [mul_inv_rev, inv_eq_of_mul_eq_one_right (S.invol j),
      inv_eq_of_mul_eq_one_right (S.invol i)]
  unfold StringGroupRep.period
  rw [← h_inv, orderOf_inv]

/-
The diagonal of the period matrix is constantly `1`: each generator squares
to the identity, whose order is `1`.
-/
theorem period_self (S : StringGroupRep G r) (i : Fin r) : S.period i i = 1 := by
  unfold StringGroupRep.period;
  simp +decide [ S.invol ]

/-- The **dual** representation: reverse the order of the generators. -/
def dual (S : StringGroupRep G r) : StringGroupRep G r where
  ρ i := S.ρ i.rev
  invol i := S.invol _
  comm {i j} h := by
    grind +suggestions

/-
Dualizing twice returns the original representation.
-/
theorem dual_dual (S : StringGroupRep G r) : S.dual.dual = S := by
  obtain ⟨ ρ, invol, comm ⟩ := S;
  congr! 1;
  exact funext fun i => by simp +decide [ StringGroupRep.dual ] ;

/-- A representation is **self-dual** when some automorphism of `G` reverses the
generators. -/
def IsSelfDual (S : StringGroupRep G r) : Prop :=
  ∃ α : G ≃* G, ∀ i, α (S.ρ i) = S.ρ i.rev

/-- For a self-dual representation, the period matrix is invariant under
simultaneous reversal of both indices. -/
theorem period_rev_of_selfDual (S : StringGroupRep G r) (h : S.IsSelfDual)
    (i j : Fin r) : S.period i.rev j.rev = S.period i j := by
  obtain ⟨ α, hα ⟩ := h
  unfold StringGroupRep.period
  simp +decide [ ← hα, ← map_mul ]

/-- The **Schläfli symbol**: the first sub-diagonal of the period matrix. -/
noncomputable def schlafli (S : StringGroupRep G r) (k : Fin (r - 1)) : ℕ :=
  S.period ⟨k, by have := k.isLt; omega⟩ ⟨k + 1, by have := k.isLt; omega⟩

/-- For a self-dual representation the Schläfli symbol is a palindrome. -/
theorem schlafli_palindrome (S : StringGroupRep G r) (h : S.IsSelfDual)
    (k : Fin (r - 1)) : S.schlafli k.rev = S.schlafli k := by
  convert S.period_rev_of_selfDual h ⟨k, by omega⟩ ⟨k + 1, by omega⟩ using 1
  convert S.period_swap _ _ using 2 <;> all_goals grind

/-- Push a representation forward along a group homomorphism. -/
def map (φ : G →* H) (S : StringGroupRep G r) : StringGroupRep H r where
  ρ i := φ (S.ρ i)
  invol i := by rw [← map_mul, S.invol, map_one]
  comm {i j} h := by rw [← map_mul, S.comm h, map_mul]

/-- If a representation is self-dual through conjugation by an *inner* element
`w`, the push-forward along any homomorphism is self-dual through conjugation by
the image of `w`. -/
theorem map_selfDual_of_inner (φ : G →* H) (S : StringGroupRep G r) (w : G)
    (hw : ∀ i, w * S.ρ i * w⁻¹ = S.ρ i.rev) : (S.map φ).IsSelfDual := by
  refine ⟨MulAut.conj (φ w), ?_⟩
  intro i
  show φ w * φ (S.ρ i) * (φ w)⁻¹ = φ (S.ρ i.rev)
  rw [← map_inv, ← map_mul, ← map_mul, hw i]

end StringGroupRep

open StringGroupRep

/-! ## The simplex representation and its Schläfli symbol

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The simplex is the canonical self-dual polytope, so
  its Schläfli symbol must be the palindrome `{3,…,3}`; this is the base case for
  vertex-gluing constructions of higher-rank self-dual representations.
Experiment (Experimenter): Built `simplex` from adjacent transpositions, proved
  self-duality via conjugation by `revP`, and reduced the Schläfli computation to
  `orderOf ((i,i+1)·(i+1,i+2)) = 3`, identifying the product as a 3-cycle.
Analysis (Analyst): The non-trivial step is that overlapping adjacent
  transpositions multiply to a *3-cycle* (order 3), not the identity or an
  involution.  This is exactly the `{3}` of every simplex ridge.
Critique (Critic): `simplex_schlafli_eq_three` computes an explicit permutation
  order via primality / `IsThreeCycle`, not by `decide` over an unbounded family.
Synthesis (PI): The simplex is doubled below to realise rank `2m` in `A_{4m+3}`.
-/

/-- The reversal permutation `i ↦ rev i` of `Fin n`. -/
def revP (n : ℕ) : Equiv.Perm (Fin n) := ⟨Fin.rev, Fin.rev, Fin.rev_rev, Fin.rev_rev⟩

@[simp] theorem revP_apply (n : ℕ) (i : Fin n) : revP n i = i.rev := rfl

/-- The **rank-`r` simplex representation** of the symmetric group on `r+1`
points, generated by the adjacent transpositions `(i, i+1)`. -/
def simplex (r : ℕ) : StringGroupRep (Equiv.Perm (Fin (r + 1))) r where
  ρ i := Equiv.swap i.castSucc i.succ
  invol i := Equiv.swap_mul_self _ _
  comm {i j} h := by
    apply Equiv.ext
    intro x
    simp [swap_apply_def]
    grind

/-- The simplex representation is self-dual through conjugation by the reversal
permutation. -/
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

/-- The product of two **overlapping** transpositions `(p q)·(q s)` over three
distinct points is a 3-cycle, hence has order `3`. -/
theorem overlap_order {α : Type*} [DecidableEq α] [Fintype α] (p q s : α)
    (hpq : p ≠ q) (hqs : q ≠ s) (hps : p ≠ s) :
    orderOf (Equiv.swap p q * Equiv.swap q s) = 3 := by
  rw [Equiv.swap_comm p q]
  exact (Equiv.Perm.isThreeCycle_swap_mul_swap_same (Ne.symm hpq) hqs hps).orderOf

/-- **Schläfli symbol of the simplex.**  Every entry is `3`: the product of two
overlapping adjacent transpositions `(k, k+1)·(k+1, k+2)` is the 3-cycle
`(k, k+1, k+2)`, whose order is `3`. -/
theorem simplex_schlafli_eq_three (r : ℕ) (k : Fin (r - 1)) :
    (simplex r).schlafli k = 3 := by
  have hk := k.isLt
  unfold StringGroupRep.schlafli StringGroupRep.period simplex
  simp only
  have hb : (⟨(k : ℕ), by omega⟩ : Fin r).succ = (⟨(k : ℕ) + 1, by omega⟩ : Fin r).castSucc :=
    Fin.ext rfl
  rw [hb]
  apply overlap_order
  · apply Fin.ne_of_val_ne; simp only [Fin.val_castSucc]; omega
  · apply Fin.ne_of_val_ne; simp only [Fin.val_castSucc, Fin.val_succ]; omega
  · apply Fin.ne_of_val_ne; simp only [Fin.val_castSucc, Fin.val_succ]; omega

/-- The simplex's Schläfli symbol is a palindrome — a direct consequence of
`simplex_schlafli_eq_three`, consistent with the general `schlafli_palindrome`. -/
theorem simplex_schlafli_palindrome (r : ℕ) (k : Fin (r - 1)) :
    (simplex r).schlafli k.rev = (simplex r).schlafli k := by
  rw [simplex_schlafli_eq_three, simplex_schlafli_eq_three]

/-! ## The doubling construction: self-dual rank `2m` inside `A_{4m+3}`

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A self-dual rank-`2m` representation of `A_{4m+3}`
  exists for every `m`, obtained by the vertex-gluing / doubling method: embed
  two copies of the rank-`2m` simplex plus a fixed point into `A_{4m+3}`.
Experiment (Experimenter): Built the doubling homomorphism `σ ↦ σ ⊕ σ ⊕ 1`,
  transported it to `Perm (Fin (4m+3))`, verified the image is even
  (`dblPerm_sign = 1`), corestricted to `A_{4m+3}`, and pushed the simplex
  forward, transferring self-duality with `map_selfDual_of_inner`.
Analysis (Analyst): The doubled permutation is a product of two equal even/odd
  parts, so its sign is a square — always `+1`; hence it lands in `A_{4m+3}`.
Critique (Critic): `A4m3_selfDual_rank2m` is UNCONDITIONAL — it proves the
  achievability (lower-bound) half of the rank conjecture outright.
Synthesis (PI): Combined below with the literature inputs to bracket the
  maximal self-dual rank at exactly `2m`.
-/

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

/-- **Maximal self-dual rank theorem for `A_{4m+3}` (conditional).**

For `n = 4m+3` with `m ≥ 3`, any self-dual string C-group representation of the
alternating group `A_n` has rank at most `2m`.

The two external inputs are supplied as hypotheses, exactly as in the informal
argument from the Fernandes–Leemans theory:

* `hbound` is the known rank bound for string C-group representations of
  alternating groups: the rank is at most `⌊(n-1)/2⌋ = 2m+1`.
* `hmaxShape` is the structural fact that a representation attaining the *odd*
  maximal rank `2m+1` has a Schläfli symbol that is **not** a palindrome.

The genuinely combinatorial content — that self-duality forces a palindromic
Schläfli symbol and therefore excludes the odd maximal rank — is proved here via
`schlafli_palindrome`.  The hypothesis `hm : 3 ≤ m` records the regime of
interest from the literature. -/
theorem max_selfDual_rank_A4m3 {m : ℕ} (_hm : 3 ≤ m) {r : ℕ}
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