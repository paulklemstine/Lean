import Mathlib

/-!
# Conjecture D10: is the Molien invariant exactly the Burnside mark vector modulo scaling?

For a finite group `G` acting on a finite set `X` there are two classical invariants.

* the **Burnside mark vector** `H ↦ markOn X H = |X^H|`, indexed by the subgroups of `G`;
* the **Molien invariant** `H ↦ molien X H = (1/|H|) ∑_{h ∈ H} |X^h|`, the subgroup-wise
  average of the permutation character (equivalently, by Burnside's lemma, the number of
  `H`-orbits, equivalently the constant term data of the Molien series of the permutation
  representation restricted to `H`).

Conjecture D10 asserts that these two invariants agree up to a scalar.  This file settles
the conjecture:

* **positive half** (`molien_eq_avgMarks`): the Molien invariant is always a *linear image*
  of the mark vector — it is the average over `h ∈ H` of the marks at the cyclic subgroups
  `⟨h⟩`.  Hence the mark vector determines the Molien invariant.
* **sharp positive result** (`markOn_eq_of_fixCount_eq_of_cyclic`): if every subgroup of `G`
  is cyclic (e.g. `G` cyclic), the Molien invariant conversely determines the whole mark
  vector *on the nose* (scaling factor `1`).
* **negative half** (`D10_false`): for the Klein four group `V = (ℤ/2)²` there are two
  `V`-sets with *identical* Molien invariants at every subgroup whose mark vectors are not
  proportional.  So Conjecture D10 is **false** in general, and the cyclic hypothesis above
  is exactly the boundary of its validity.

Along the way we prove the structural comparison `markOn ≤ molien` with the equality case
(`molien_eq_markOn_iff`), Burnside's orbit-counting identity in this normalisation
(`molien_eq_card_orbits`) and the resulting arithmetic divisibility
`|H| ∣ ∑_{h ∈ H} |X^h|`.
-/

namespace D10

open Finset MulAction

section Defs

variable {G : Type*} [Group G]

/-- The number of points of `X` fixed by the single element `g`, i.e. the value at `g`
of the permutation character of `X`. -/
def fixCount (X : Type*) [MulAction G X] [Fintype X] [DecidableEq X] (g : G) : ℕ :=
  (univ.filter fun x : X => g • x = x).card

/-- The **Burnside mark** of the `G`-set `X` at the subgroup `H`: the number of `H`-fixed
points of `X`. -/
def markOn (X : Type*) [MulAction G X] [Fintype X] [DecidableEq X]
    (H : Subgroup G) [Fintype H] : ℕ :=
  (univ.filter fun x : X => ∀ h : H, (h : G) • x = x).card

/-- The **Molien invariant** of the `G`-set `X` at the subgroup `H`: the average number of
fixed points of the elements of `H`. -/
def molien (X : Type*) [MulAction G X] [Fintype X] [DecidableEq X]
    (H : Subgroup G) [Fintype H] : ℚ :=
  (∑ h : H, (fixCount X (h : G) : ℚ)) / (Fintype.card H : ℚ)

end Defs

section Basic

variable {G : Type*} [Group G] {X : Type*} [MulAction G X] [Fintype X] [DecidableEq X]

theorem fixCount_one : fixCount X (1 : G) = Fintype.card X := by
  rw [fixCount, filter_true_of_mem (by intro x _; simp), card_univ]

theorem fixCount_le_card (g : G) : fixCount X g ≤ Fintype.card X :=
  card_filter_le _ _

theorem markOn_le_fixCount (H : Subgroup G) [Fintype H] (h : H) :
    markOn X H ≤ fixCount X (h : G) :=
  card_le_card (by intro x hx; simp only [mem_filter, mem_univ, true_and] at *; exact hx h)

theorem markOn_bot : markOn X (⊥ : Subgroup G) = Fintype.card X := by
  classical
  simp only [markOn]
  rw [filter_true_of_mem, card_univ]
  intro x _
  rintro ⟨h, hh⟩
  rw [Subgroup.mem_bot] at hh
  simp [hh]

omit [Fintype X] [DecidableEq X] in
/-- A point fixed by `g` is fixed by every integer power of `g`. -/
theorem smul_zpow_fixed {g : G} {x : X} (hx : g • x = x) (n : ℤ) : g ^ n • x = x := by
  have hnat : ∀ m : ℕ, g ^ m • x = x := by
    intro m
    induction m with
    | zero => simp
    | succ k ih => rw [pow_succ, mul_smul, hx, ih]
  cases n with
  | ofNat m => simpa using hnat m
  | negSucc m =>
      have h : (g ^ (m + 1))⁻¹ • x = x := by rw [inv_smul_eq_iff, hnat]
      simpa [zpow_negSucc] using h

/-- Fixed points of an element and of the cyclic subgroup it generates coincide. -/
theorem fixCount_eq_markOn_zpowers (g : G) [Fintype (Subgroup.zpowers g)] :
    fixCount X g = markOn X (Subgroup.zpowers g) := by
  simp only [fixCount, markOn]
  refine congrArg card (filter_congr ?_)
  intro x _
  constructor
  · rintro hx ⟨y, hy⟩
    obtain ⟨n, rfl⟩ := hy
    simpa using smul_zpow_fixed hx n
  · intro hx
    exact hx ⟨g, Subgroup.mem_zpowers g⟩

end Basic

section Molien

variable {G : Type*} [Group G] {X : Type*} [MulAction G X] [Fintype X] [DecidableEq X]

theorem card_subgroup_pos (H : Subgroup G) [Fintype H] : (0 : ℚ) < (Fintype.card H : ℚ) := by
  exact_mod_cast Fintype.card_pos

/-- The Molien invariant at `⊥` is the cardinality of `X`. -/
theorem molien_bot : molien X (⊥ : Subgroup G) = (Fintype.card X : ℚ) := by
  have h1 : ∀ h : (⊥ : Subgroup G), fixCount X (h : G) = Fintype.card X := by
    rintro ⟨h, hh⟩
    rw [Subgroup.mem_bot] at hh
    subst hh
    exact fixCount_one
  simp only [molien, h1]
  rw [Finset.sum_const, card_univ, nsmul_eq_mul]
  field_simp

/-- **Structural comparison**: the Burnside mark is at most the Molien invariant. -/
theorem markOn_le_molien (H : Subgroup G) [Fintype H] : (markOn X H : ℚ) ≤ molien X H := by
  rw [molien, le_div_iff₀ (card_subgroup_pos H)]
  calc (markOn X H : ℚ) * (Fintype.card H : ℚ)
      = ∑ _h : H, (markOn X H : ℚ) := by
        rw [Finset.sum_const, card_univ, nsmul_eq_mul, mul_comm]
    _ ≤ ∑ h : H, (fixCount X (h : G) : ℚ) :=
        Finset.sum_le_sum fun h _ => by exact_mod_cast markOn_le_fixCount (X := X) H h

/-- The mark at `H` equals `|X|` exactly when `H` acts trivially. -/
theorem markOn_eq_card_iff (H : Subgroup G) [Fintype H] :
    markOn X H = Fintype.card X ↔ ∀ (h : H) (x : X), (h : G) • x = x := by
  rw [markOn, ← card_univ]
  constructor
  · intro hcard h x
    have : (univ.filter fun x : X => ∀ h : H, (h : G) • x = x) = univ :=
      Finset.eq_univ_of_card _ (by simpa using hcard)
    have hx : x ∈ univ.filter fun x : X => ∀ h : H, (h : G) • x = x := by
      rw [this]; exact mem_univ _
    simp only [mem_filter, mem_univ, true_and] at hx
    exact hx h
  · intro htriv
    congr 1
    exact filter_true_of_mem fun x _ h => htriv h x

/-- **Equality case**: Molien and mark agree at `H` precisely when `H` acts trivially on `X`. -/
theorem molien_eq_markOn_iff (H : Subgroup G) [Fintype H] :
    molien X H = (markOn X H : ℚ) ↔ ∀ (h : H) (x : X), (h : G) • x = x := by
  constructor
  · intro heq
    have hsum : ∑ h : H, fixCount X (h : G) = Fintype.card H * markOn X H := by
      have : (∑ h : H, (fixCount X (h : G) : ℚ)) = (Fintype.card H : ℚ) * markOn X H := by
        rw [molien, div_eq_iff (ne_of_gt (card_subgroup_pos H))] at heq
        rw [heq]; ring
      exact_mod_cast this
    have hle : ∀ h ∈ (univ : Finset H), markOn X H ≤ fixCount X (h : G) :=
      fun h _ => markOn_le_fixCount (X := X) H h
    have hconst : ∑ _h : H, markOn X H = Fintype.card H * markOn X H := by
      rw [Finset.sum_const, card_univ, smul_eq_mul]
    have hall := (Finset.sum_eq_sum_iff_of_le hle).mp (by rw [hconst, hsum])
    have h1 := hall 1 (mem_univ _)
    rw [Subgroup.coe_one, fixCount_one] at h1
    exact (markOn_eq_card_iff H).mp h1
  · intro htriv
    have hfix : ∀ h : H, fixCount X (h : G) = Fintype.card X := by
      intro h
      rw [fixCount, filter_true_of_mem (fun x _ => htriv h x), card_univ]
    rw [(markOn_eq_card_iff H).mpr htriv]
    simp only [molien, hfix]
    rw [Finset.sum_const, card_univ, nsmul_eq_mul]
    field_simp

/-- **Burnside's lemma**, in Molien normalisation: the Molien invariant at `H` counts the
`H`-orbits of `X`. -/
theorem sum_fixCount_eq_card_orbits_mul (H : Subgroup G) [Fintype H] :
    (∑ h : H, fixCount X (h : G))
      = Nat.card (Quotient (MulAction.orbitRel H X)) * Fintype.card H := by
  classical
  have key := MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group (α := H) (β := X)
  rw [Nat.card_eq_fintype_card, ← key]
  refine Finset.sum_congr rfl fun h _ => ?_
  rw [Fintype.card_eq_nat_card, Nat.card_eq_card_toFinset, fixCount]
  congr 1
  ext x
  simp only [MulAction.fixedBy, Set.mem_setOf_eq, Set.mem_toFinset, mem_filter, mem_univ, true_and]
  exact Iff.rfl

theorem molien_eq_card_orbits (H : Subgroup G) [Fintype H] :
    molien X H = (Nat.card (Quotient (MulAction.orbitRel H X)) : ℚ) := by
  rw [molien, div_eq_iff (ne_of_gt (card_subgroup_pos H))]
  have := sum_fixCount_eq_card_orbits_mul (X := X) H
  exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) this

/-- **Arithmetic corollary**: `|H|` divides the character sum `∑_{h ∈ H} |X^h|`. -/
theorem card_dvd_sum_fixCount (H : Subgroup G) [Fintype H] :
    Fintype.card H ∣ ∑ h : H, fixCount X (h : G) :=
  ⟨Nat.card (Quotient (MulAction.orbitRel H X)), by
    rw [sum_fixCount_eq_card_orbits_mul, mul_comm]⟩

/-- The Molien invariant is a nonnegative integer. -/
theorem molien_nonneg (H : Subgroup G) [Fintype H] : 0 ≤ molien X H := by
  rw [molien_eq_card_orbits]
  positivity

/-- **Positive half of D10**: the Molien invariant is a linear image of the mark vector:
it is the average of the marks at the cyclic subgroups generated by the elements of `H`. -/
theorem molien_eq_avgMarks (H : Subgroup G) [Fintype H] [∀ g : G, Fintype (Subgroup.zpowers g)] :
    molien X H
      = (∑ h : H, (markOn X (Subgroup.zpowers (h : G)) : ℚ)) / (Fintype.card H : ℚ) := by
  rw [molien]
  congr 1
  exact Finset.sum_congr rfl fun h _ => by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) (fixCount_eq_markOn_zpowers (X := X) (h : G))

/-- Burnside's lemma for the full group: `|G|` divides the total character sum. -/
theorem card_group_dvd_sum_fixCount [Fintype G] :
    Fintype.card G ∣ ∑ g : G, fixCount X g := by
  classical
  refine ⟨Nat.card (Quotient (MulAction.orbitRel G X)), ?_⟩
  have key := MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group (α := G) (β := X)
  rw [Nat.card_eq_fintype_card, mul_comm, ← key]
  refine Finset.sum_congr rfl fun g _ => ?_
  rw [Fintype.card_eq_nat_card, Nat.card_eq_card_toFinset, fixCount]
  congr 1
  ext x
  simp only [MulAction.fixedBy, Set.mem_setOf_eq, Set.mem_toFinset, mem_filter, mem_univ, true_and]

end Molien

section Comparison

variable {G : Type*} [Group G] {X Y : Type*}
  [MulAction G X] [Fintype X] [DecidableEq X] [MulAction G Y] [Fintype Y] [DecidableEq Y]

/-- Equal permutation characters force equal Molien invariants at every subgroup. -/
theorem molien_eq_of_fixCount_eq (hchar : ∀ g : G, fixCount X g = fixCount Y g)
    (H : Subgroup G) [Fintype H] : molien X H = molien Y H := by
  simp only [molien, hchar]

/-- Marks are invariants of the isomorphism type of a `G`-set. -/
theorem markOn_eq_of_equivariant_equiv (e : X ≃ Y) (he : ∀ (g : G) (x : X), e (g • x) = g • e x)
    (H : Subgroup G) [Fintype H] : markOn X H = markOn Y H := by
  refine Finset.card_bij (fun x _ => e x) ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx ⊢
    intro h
    rw [← he, hx h]
  · intro a _ b _ hab
    exact e.injective hab
  · intro y hy
    refine ⟨e.symm y, ?_, by simp⟩
    simp only [mem_filter, mem_univ, true_and] at hy ⊢
    intro h
    apply e.injective
    rw [he, Equiv.apply_symm_apply, hy h]

/-- **Sharp positive form of D10.**  If the subgroup `H` is cyclic, then the permutation
character alone pins down the mark at `H` (with scaling factor exactly `1`). -/
theorem markOn_eq_of_fixCount_eq_of_cyclic (hchar : ∀ g : G, fixCount X g = fixCount Y g)
    (H : Subgroup G) [Fintype H] (hH : IsCyclic H) : markOn X H = markOn Y H := by
  obtain ⟨g, rfl⟩ := (Subgroup.isCyclic_iff_exists_zpowers_eq_top H).mp hH
  rw [← fixCount_eq_markOn_zpowers (X := X), ← fixCount_eq_markOn_zpowers (X := Y), hchar]

/-- For a cyclic group the Molien data (equivalently the permutation character) determines the
entire Burnside mark vector: D10 holds, on the nose, over cyclic groups. -/
theorem markOn_eq_of_fixCount_eq_of_isCyclic [IsCyclic G]
    (hchar : ∀ g : G, fixCount X g = fixCount Y g) (H : Subgroup G) [Fintype H] :
    markOn X H = markOn Y H :=
  markOn_eq_of_fixCount_eq_of_cyclic hchar H inferInstance

end Comparison

section KleinCounterexample

/-! ### The Klein four group counterexample

Let `V = ℤ/2 × ℤ/2` (written multiplicatively).  Its three subgroups of index two are the
kernels of the three surjections `χ₀(a,b) = a`, `χ₁(a,b) = b`, `χ₂(a,b) = a + b`.

* `Xthree` is the disjoint union `V/A ⊔ V/B ⊔ V/C` of the three transitive two-element
  `V`-sets;
* `Xreg` is the disjoint union of the regular `V`-set with two fixed points.

Both have six elements and, as we verify, *identical permutation characters*; hence
identical Molien invariants at every subgroup.  Their mark vectors, however, disagree at
the top subgroup (`0` versus `2`), and no rescaling can repair this. -/

/-- The Klein four group, written multiplicatively. -/
abbrev V4 := Multiplicative (ZMod 2 × ZMod 2)

/-- The three index-two characters of the Klein four group. -/
def kleinChar (i : Fin 3) (p : ZMod 2 × ZMod 2) : ZMod 2 := ![p.1, p.2, p.1 + p.2] i

/-- `Xthree = V/A ⊔ V/B ⊔ V/C`: three copies of `ℤ/2`, the `i`-th one acted on through the
character `kleinChar i`. -/
abbrev Xthree := ZMod 2 × Fin 3

instance : SMul V4 Xthree :=
  ⟨fun g x => (x.1 + kleinChar x.2 (Multiplicative.toAdd g), x.2)⟩

instance : MulAction V4 Xthree where
  one_smul := by decide
  mul_smul := by decide

/-- `Xreg = V ⊔ pt ⊔ pt`: the regular `V`-set together with two fixed points. -/
abbrev Xreg := (ZMod 2 × ZMod 2) ⊕ Bool

instance : SMul V4 Xreg :=
  ⟨fun g x => match x with
    | .inl p => .inl (p + Multiplicative.toAdd g)
    | .inr b => .inr b⟩

instance : MulAction V4 Xreg where
  one_smul := by decide
  mul_smul := by decide

instance decMemTopV4 : DecidablePred (· ∈ (⊤ : Subgroup V4)) :=
  fun x => isTrue (Subgroup.mem_top x)

instance decMemBotV4 : DecidablePred (· ∈ (⊥ : Subgroup V4)) :=
  fun x => decidable_of_iff (x = 1) Subgroup.mem_bot.symm

/-- The two `V`-sets have the **same permutation character**:
`(6,2,2,2)` on `Xthree` and on `Xreg` alike (both take the value `6` at the identity and
`2` at each involution). -/
theorem klein_fixCount_eq : ∀ g : V4, fixCount Xthree g = fixCount Xreg g := by decide

/-- Consequently the two `V`-sets have the **same Molien invariant at every subgroup**. -/
theorem klein_molien_eq (H : Subgroup V4) [Fintype H] : molien Xthree H = molien Xreg H :=
  molien_eq_of_fixCount_eq klein_fixCount_eq H

theorem markOn_Xthree_top : markOn Xthree (⊤ : Subgroup V4) = 0 := by decide

theorem markOn_Xreg_top : markOn Xreg (⊤ : Subgroup V4) = 2 := by decide

theorem markOn_Xthree_bot : markOn Xthree (⊥ : Subgroup V4) = 6 := by decide

theorem markOn_Xreg_bot : markOn Xreg (⊥ : Subgroup V4) = 6 := by decide

/-- The mark vectors genuinely differ. -/
theorem klein_markOn_ne :
    markOn Xthree (⊤ : Subgroup V4) ≠ markOn Xreg (⊤ : Subgroup V4) := by
  rw [markOn_Xthree_top, markOn_Xreg_top]
  decide

/-- **Conjecture D10 is false.**  There are two `V`-sets whose Molien invariants agree at
every subgroup, yet whose Burnside mark vectors are not proportional: no scalar `c` can
satisfy `mark(Xthree) = c · mark(Xreg)`, because `⊥` forces `c = 1` while `⊤` forces
`c = 0`. -/
theorem D10_false :
    (∀ (H : Subgroup V4) [Fintype H], molien Xthree H = molien Xreg H) ∧
      ¬ ∃ c : ℚ, ∀ (H : Subgroup V4) [Fintype H],
        (markOn Xthree H : ℚ) = c * (markOn Xreg H : ℚ) := by
  refine ⟨fun H _ => klein_molien_eq H, ?_⟩
  rintro ⟨c, hc⟩
  have hbot := hc ⊥
  have htop := hc ⊤
  rw [markOn_Xthree_bot, markOn_Xreg_bot] at hbot
  rw [markOn_Xthree_top, markOn_Xreg_top] at htop
  norm_num at hbot htop
  exact absurd (hbot.symm.trans htop) (by norm_num)

/-- The Klein four group is not cyclic; `⊤` is its unique non-cyclic subgroup. -/
theorem V4_not_isCyclic : ¬ IsCyclic V4 := by
  intro h
  obtain ⟨g, hg⟩ := isCyclic_iff_exists_zpowers_eq_top.mp h
  have hsq : ∀ x : V4, x * x = 1 := by decide
  have hord : orderOf g ∣ 2 := orderOf_dvd_of_pow_eq_one (by rw [pow_two]; exact hsq g)
  have hcard : Nat.card (Subgroup.zpowers g) = Nat.card V4 := by rw [hg, Subgroup.card_top]
  rw [Nat.card_zpowers] at hcard
  have h4 : Nat.card V4 = 4 := by rw [Nat.card_eq_fintype_card]; decide
  rw [h4] at hcard
  rw [hcard] at hord
  exact absurd (Nat.le_of_dvd (by norm_num) hord) (by norm_num)

/-- **Sharpness of the boundary.**  The two mark vectors agree at *every cyclic* subgroup of
`V` -- by the cyclic half of D10 -- and therefore differ exactly at `⊤`, the unique
non-cyclic subgroup of the Klein four group. -/
theorem klein_marks_agree_on_cyclic (H : Subgroup V4) [Fintype H] (hH : IsCyclic H) :
    markOn Xthree H = markOn Xreg H :=
  markOn_eq_of_fixCount_eq_of_cyclic klein_fixCount_eq H hH

/-- The two `V`-sets are **not isomorphic** as `V`-sets, even though their permutation
characters (hence their Molien invariants) coincide: the Burnside mark vector is a strictly
finer invariant than the Molien invariant. -/
theorem Xthree_not_equiv_Xreg :
    ¬ ∃ e : Xthree ≃ Xreg, ∀ (g : V4) (x : Xthree), e (g • x) = g • e x := by
  rintro ⟨e, he⟩
  exact klein_markOn_ne (markOn_eq_of_equivariant_equiv e he ⊤)

end KleinCounterexample

end D10