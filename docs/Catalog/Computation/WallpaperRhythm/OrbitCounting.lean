/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Applications.WallpaperRhythm.QuotientEntropy

/-!
# Orbit counting for symmetry-invariant rhythmic patterns

`WallpaperRhythm.InvariantPattern α s` (from
`Applications.WallpaperRhythm.QuotientEntropy`) is the type of binary patterns on
a cell set `α` that are constant on the classes of an abstract setoid `s`, and it
has cardinality `2 ^ (number of classes)`.  This file makes the setoid concrete:
it is produced by a **group action**, so that the abstract "number of classes"
becomes the **number of orbits**, and orbits are counted by **Burnside's lemma**
from fixed-point data.

Main definitions:

* `orbitSetoid G α` — the orbit setoid `MulAction.orbitRel G α`.
* `GroupInvariantPattern G α` — invariant patterns for that setoid.
* `symmetryGroup G f` — the subgroup of `G` preserving a single pattern `f`.

Main results:

* `equivPointwiseInvariant` — a `GroupInvariantPattern` is the same thing as a
  Boolean function satisfying `f (g • a) = f a` for all `g, a`.
* `card_groupInvariantPattern` — the capacity `2 ^ (#orbits)`.
* `card_pow_card_group_eq` — a division-free Burnside form:
  `(#patterns) ^ |G| = 2 ^ (∑ g, #fixedBy g)`.
* `card_groupInvariantPattern_burnside` — the Burnside form with division.
* `logb_card_groupInvariantPattern` — the capacity in bits equals the orbit count.
* `card_pattern_pointReflection` and `card_pattern_translation` — exact pattern
  counts on the finite toroidal grid `ZMod p × ZMod q` for the point-reflection
  (retrograde–inversion) action of `ℤˣ` and for the cyclic time-shift action of
  `Multiplicative (ZMod p)`; the first depends on the parity of `p` and `q`
  through the inversion-fixed cell count `twoTorsionCard`.
* `card_pattern_antitone` — capacity is antitone in the symmetry group.
* `symmetryGroup_ne_top`, `symmetryGroup_ne_bot` — the symmetry group of one
  concrete pattern is a *proper, nontrivial* subgroup of the ambient group, so a
  pattern's symmetry group must be distinguished from the ambient group.
-/

namespace WallpaperRhythm
namespace OrbitCounting

open MulAction

/-! ## The orbit setoid of a group action -/

variable (G : Type*) [Group G] (α : Type*) [MulAction G α]

/-- The setoid on cells whose classes are the orbits of the action of `G`. -/
def orbitSetoid : Setoid α := MulAction.orbitRel G α

/-- Binary patterns on the cell set `α` that are constant on `G`-orbits. -/
def GroupInvariantPattern : Type _ := InvariantPattern α (orbitSetoid G α)

variable {G α}

theorem orbitSetoid_iff {a b : α} :
    (orbitSetoid G α).r a b ↔ ∃ g : G, g • b = a := Iff.rfl

/-- A pattern is constant on orbits exactly when it is pointwise `G`-invariant. -/
def equivPointwiseInvariant :
    GroupInvariantPattern G α ≃ {f : α → Bool // ∀ (g : G) (a : α), f (g • a) = f a} where
  toFun f := ⟨f.1, fun g a => (f.2 (g • a) a ⟨g, rfl⟩)⟩
  invFun f := ⟨f.1, by
    intro a b hab
    obtain ⟨g, rfl⟩ := hab
    exact f.2 g b⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-! ## Counting invariant patterns by orbits -/

/-- The abstract capacity theorem, restated with `Nat.card` so that no `Fintype`
instance has to be chosen in the statement. -/
theorem nat_card_invariantPattern (s : Setoid α) [Finite α] :
    Nat.card (InvariantPattern α s) = 2 ^ Nat.card (Quotient s) := by
  classical
  cases nonempty_fintype α
  rw [Nat.card_eq_fintype_card, Nat.card_eq_fintype_card,
    InvariantPattern.card_eq_two_pow_quotient_card]

/-- **Orbit capacity theorem.**  The number of `G`-invariant binary patterns on a
finite cell set is `2` to the power of the number of `G`-orbits. -/
theorem card_groupInvariantPattern [Finite α] :
    Nat.card (GroupInvariantPattern G α) =
      2 ^ Nat.card (orbitRel.Quotient G α) :=
  nat_card_invariantPattern (orbitSetoid G α)

/-- **Burnside form, division-free.**  Raising the number of invariant patterns to
the order of the group gives `2` to the total number of fixed cells. -/
theorem card_pow_card_group_eq [Finite α] [Fintype G] :
    Nat.card (GroupInvariantPattern G α) ^ Nat.card G =
      2 ^ (∑ g : G, Nat.card (fixedBy α g)) := by
  classical
  cases nonempty_fintype α
  haveI : ∀ g : G, Fintype (fixedBy α g) := fun g => Fintype.ofFinite _
  haveI : Fintype (orbitRel.Quotient G α) := Fintype.ofFinite _
  have hb : (∑ g : G, Fintype.card (fixedBy α g)) =
      Fintype.card (orbitRel.Quotient G α) * Fintype.card G :=
    MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G α
  rw [card_groupInvariantPattern, ← pow_mul]
  congr 1
  simp only [Nat.card_eq_fintype_card] at *
  rw [← hb]

/-- **Burnside's lemma for pattern capacity.**  The number of invariant patterns is
`2` to the average number of fixed cells. -/
theorem card_groupInvariantPattern_burnside [Finite α] [Fintype G] :
    Nat.card (GroupInvariantPattern G α) =
      2 ^ ((∑ g : G, Nat.card (fixedBy α g)) / Nat.card G) := by
  classical
  cases nonempty_fintype α
  haveI : ∀ g : G, Fintype (fixedBy α g) := fun g => Fintype.ofFinite _
  haveI : Fintype (orbitRel.Quotient G α) := Fintype.ofFinite _
  have hb : (∑ g : G, Fintype.card (fixedBy α g)) =
      Fintype.card (orbitRel.Quotient G α) * Fintype.card G :=
    MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group G α
  have hG : 0 < Fintype.card G := Fintype.card_pos
  rw [card_groupInvariantPattern]
  congr 1
  simp only [Nat.card_eq_fintype_card] at *
  rw [hb, Nat.mul_div_cancel _ hG]

/-- The base-two information capacity, in bits, of the space of `G`-invariant
patterns is exactly the number of orbits. -/
theorem logb_card_groupInvariantPattern [Finite α] :
    Real.logb 2 (Nat.card (GroupInvariantPattern G α)) =
      Nat.card (orbitRel.Quotient G α) := by
  rw [card_groupInvariantPattern]
  push_cast
  rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

/-! ## The symmetry group of a single pattern -/

variable (G) in
/-- The symmetry group of a pattern: the elements of the ambient group that
preserve it.  A pattern is `G`-invariant exactly when this is all of `G`. -/
def symmetryGroup (f : α → Bool) : Subgroup G where
  carrier := {g | ∀ a, f (g • a) = f a}
  one_mem' := by intro a; simp
  mul_mem' := by
    intro g h hg hh a
    rw [mul_smul, hg, hh]
  inv_mem' := by
    intro g hg a
    have := hg (g⁻¹ • a)
    rw [smul_inv_smul] at this
    exact this.symm

@[simp] theorem mem_symmetryGroup_iff {f : α → Bool} {g : G} :
    g ∈ symmetryGroup G f ↔ ∀ a, f (g • a) = f a := Iff.rfl

/-- A Boolean pattern is invariant (a `GroupInvariantPattern`) exactly when its
symmetry group is the whole ambient group. -/
theorem symmetryGroup_eq_top_iff {f : α → Bool} :
    symmetryGroup G f = ⊤ ↔ ∀ (g : G) (a : α), f (g • a) = f a := by
  constructor
  · intro h g a
    have : g ∈ symmetryGroup G f := by rw [h]; trivial
    exact this a
  · intro h
    ext g
    simp [mem_symmetryGroup_iff, h g]

/-! ## Example 1: point reflection (retrograde–inversion) of a toroidal grid

The group of units `ℤˣ = {1, -1}` acts on the additive group `ZMod p × ZMod q`;
the nontrivial element sends a time–pitch cell `(t, n)` to `(-t, -n)`, the
"retrograde–inversion" of crystallographic music theory. -/

/-- In a cycle of odd length, inversion fixes only the origin. -/
theorem neg_eq_self_iff_of_odd {n : ℕ} [NeZero n] (hn : Odd n) (x : ZMod n) :
    -x = x ↔ x = 0 := by
  constructor
  · intro h
    have h2 : (2 : ZMod n) * x = 0 := by
      have hxx : x + x = 0 := by
        calc x + x = -x + x := by rw [h]
        _ = 0 := by ring
      calc (2 : ZMod n) * x = x + x := by ring
      _ = 0 := hxx
    have hu : IsUnit (2 : ZMod n) := by
      have hcast : ((2 : ℕ) : ZMod n) = (2 : ZMod n) := by push_cast; ring
      rw [← hcast, ZMod.isUnit_iff_coprime]
      exact Nat.coprime_two_left.mpr hn
    obtain ⟨u, hu'⟩ := hu
    have hz : (u⁻¹ : (ZMod n)ˣ) * ((2 : ZMod n) * x) = 0 := by rw [h2]; ring
    rw [← hu'] at hz
    simpa [← mul_assoc] using hz
  · rintro rfl; simp

/-- In a cycle of even length `2 * m`, inversion fixes exactly the origin and the
half-period `m`. -/
theorem neg_eq_self_iff_of_even {m : ℕ} (hm : 0 < m) (x : ZMod (2 * m)) :
    -x = x ↔ (x = 0 ∨ x = (m : ZMod (2 * m))) := by
  haveI : NeZero (2 * m) := ⟨by omega⟩
  have hx : ((x.val : ℕ) : ZMod (2 * m)) = x := by rw [ZMod.natCast_val, ZMod.cast_id]
  rw [neg_eq_iff_add_eq_zero]
  constructor
  · intro h
    have h2 : ((2 * x.val : ℕ) : ZMod (2 * m)) = 0 := by
      push_cast
      rw [hx]
      linear_combination h
    rw [ZMod.natCast_eq_zero_iff] at h2
    obtain ⟨c, hc⟩ := h2
    have hvc : x.val = m * c := by
      have h2' : 2 * x.val = 2 * (m * c) := by rw [hc]; ring
      omega
    have hlt : x.val < 2 * m := ZMod.val_lt x
    have hc2 : c < 2 := by
      by_contra hcon
      push_neg at hcon
      have : 2 * m ≤ m * c := by nlinarith
      omega
    interval_cases c
    · left; rw [← hx, hvc]; simp
    · right; rw [← hx, hvc]; simp
  · rintro (rfl | rfl)
    · simp
    · rw [← Nat.cast_add, show m + m = 2 * m by ring]
      simp

/-- The number of cells of a cycle of length `n` fixed by inversion:
two if `n` is even (the origin and the half-period), one if `n` is odd. -/
def twoTorsionCard (n : ℕ) : ℕ := if Even n then 2 else 1

theorem card_negFixed (n : ℕ) [NeZero n] :
    Nat.card {x : ZMod n // -x = x} = twoTorsionCard n := by
  rcases Nat.even_or_odd n with he | ho
  · obtain ⟨m, hm⟩ := he
    have hm0 : 0 < m := by
      rcases Nat.eq_zero_or_pos m with rfl | h
      · exact absurd (by simp [hm] : n = 0) (NeZero.ne n)
      · exact h
    have hn : n = 2 * m := by omega
    subst hn
    have hset : {x : ZMod (2 * m) | -x = x} = {0, (m : ZMod (2 * m))} := by
      ext x
      simp [neg_eq_self_iff_of_even hm0 x]
    have hne : (0 : ZMod (2 * m)) ≠ (m : ZMod (2 * m)) := by
      intro h
      haveI : NeZero (2 * m) := ⟨by omega⟩
      have hdvd : (2 * m) ∣ m := by
        rw [← ZMod.natCast_eq_zero_iff]
        exact h.symm
      have := Nat.le_of_dvd hm0 hdvd
      omega
    have hc : Nat.card {x : ZMod (2 * m) // -x = x} =
        ({x : ZMod (2 * m) | -x = x}).ncard := Nat.card_coe_set_eq _
    rw [show twoTorsionCard (2 * m) = 2 from if_pos ⟨m, by ring⟩, hc, hset,
      Set.ncard_pair hne]
  · have hset : {x : ZMod n | -x = x} = {0} := by
      ext x
      simpa using neg_eq_self_iff_of_odd ho x
    have hc : Nat.card {x : ZMod n // -x = x} = ({x : ZMod n | -x = x}).ncard :=
      Nat.card_coe_set_eq _
    rw [show twoTorsionCard n = 1 from if_neg (Nat.not_even_iff_odd.mpr ho), hc, hset,
      Set.ncard_singleton]

variable (p q : ℕ)

/-- Inversion-fixed cells of the torus are pairs of inversion-fixed coordinates. -/
def negFixedProdEquiv :
    {x : ZMod p × ZMod q // -x = x} ≃
      {a : ZMod p // -a = a} × {b : ZMod q // -b = b} where
  toFun x := (⟨x.1.1, congrArg Prod.fst x.2⟩, ⟨x.1.2, congrArg Prod.snd x.2⟩)
  invFun y := ⟨(y.1.1, y.2.1), Prod.ext y.1.2 y.2.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

theorem card_fixedBy_neg_one [NeZero p] [NeZero q] :
    Nat.card (fixedBy (ZMod p × ZMod q) (-1 : ℤˣ)) =
      twoTorsionCard p * twoTorsionCard q := by
  have hset : fixedBy (ZMod p × ZMod q) (-1 : ℤˣ) = {x : ZMod p × ZMod q | -x = x} := by
    ext x
    simp [mem_fixedBy, Units.smul_def]
  rw [hset]
  rw [show Nat.card {x : ZMod p × ZMod q | -x = x} =
      Nat.card ({x : ZMod p × ZMod q // -x = x}) from rfl]
  rw [Nat.card_congr (negFixedProdEquiv p q), Nat.card_prod,
    card_negFixed p, card_negFixed q]

theorem fixedBy_units_one :
    fixedBy (ZMod p × ZMod q) (1 : ℤˣ) = Set.univ := by
  ext x; simp

/-- **Point-reflection capacity of a toroidal drum grid.**  On the `p × q`
time–pitch torus the retrograde–inversion `(t, n) ↦ (-t, -n)` fixes exactly
`twoTorsionCard p * twoTorsionCard q` cells, so Burnside gives
`(p * q + twoTorsionCard p * twoTorsionCard q) / 2` orbits and that many bits of
pattern capacity. -/
theorem card_pattern_pointReflection [NeZero p] [NeZero q] :
    Nat.card (GroupInvariantPattern ℤˣ (ZMod p × ZMod q)) =
      2 ^ ((p * q + twoTorsionCard p * twoTorsionCard q) / 2) := by
  classical
  have hsum : (∑ u : ℤˣ, Nat.card (fixedBy (ZMod p × ZMod q) u)) =
      p * q + twoTorsionCard p * twoTorsionCard q := by
    have huniv : (Finset.univ : Finset ℤˣ) = {1, -1} := by decide
    rw [huniv, Finset.sum_pair (by decide : (1 : ℤˣ) ≠ -1),
      fixedBy_units_one p q, card_fixedBy_neg_one p q]
    simp [Nat.card_eq_fintype_card, ZMod.card]
  rw [card_groupInvariantPattern_burnside, hsum]
  norm_num [Nat.card_eq_fintype_card]

/-- For odd `p` and `q` the origin is the only fixed cell, giving exactly
`2 ^ ((p * q + 1) / 2)` retrograde–inversion invariant patterns. -/
theorem card_pattern_pointReflection_odd (hp : Odd p) (hq : Odd q) [NeZero p] [NeZero q] :
    Nat.card (GroupInvariantPattern ℤˣ (ZMod p × ZMod q)) =
      2 ^ ((p * q + 1) / 2) := by
  rw [card_pattern_pointReflection p q,
    show twoTorsionCard p = 1 from if_neg (Nat.not_even_iff_odd.mpr hp),
    show twoTorsionCard q = 1 from if_neg (Nat.not_even_iff_odd.mpr hq)]

/-! ## Example 2: cyclic time shifts of a toroidal grid -/

/-- The cyclic group of time shifts acting on a `p × q` time–pitch torus:
`g • (t, n) = (t + g, n)`. -/
instance timeShiftAction (p q : ℕ) :
    MulAction (Multiplicative (ZMod p)) (ZMod p × ZMod q) where
  smul g v := (v.1 + Multiplicative.toAdd g, v.2)
  one_smul v := by
    show (v.1 + (0 : ZMod p), v.2) = v
    simp
  mul_smul g h v := by
    show (v.1 + (Multiplicative.toAdd g + Multiplicative.toAdd h), v.2)
      = ((v.1 + Multiplicative.toAdd h) + Multiplicative.toAdd g, v.2)
    rw [add_comm (Multiplicative.toAdd g), add_assoc]

theorem timeShift_smul (g : Multiplicative (ZMod p)) (v : ZMod p × ZMod q) :
    g • v = (v.1 + Multiplicative.toAdd g, v.2) := rfl

theorem fixedBy_timeShift_one :
    fixedBy (ZMod p × ZMod q) (1 : Multiplicative (ZMod p)) = Set.univ := by
  ext x; simp

theorem fixedBy_timeShift_eq_empty [NeZero p] (g : Multiplicative (ZMod p)) (hg : g ≠ 1) :
    fixedBy (ZMod p × ZMod q) g = ∅ := by
  ext x
  simp only [mem_fixedBy, Set.mem_empty_iff_false, iff_false]
  intro h
  rw [timeShift_smul] at h
  have h1 : x.1 + Multiplicative.toAdd g = x.1 := congrArg Prod.fst h
  apply hg
  have : Multiplicative.toAdd g = 0 := by
    have := add_left_cancel (a := x.1) (b := Multiplicative.toAdd g) (c := 0)
    simpa using this (by simpa using h1)
  exact toAdd_eq_zero.mp this

/-- **Cyclic-canon capacity.**  A pattern on the `p × q` time–pitch torus that is
invariant under *every* time shift is exactly a choice of pitches, so there are
exactly `2 ^ q` such patterns. -/
theorem card_pattern_translation [NeZero p] [NeZero q] :
    Nat.card (GroupInvariantPattern (Multiplicative (ZMod p)) (ZMod p × ZMod q)) =
      2 ^ q := by
  classical
  have hsum :
      (∑ g : Multiplicative (ZMod p),
        Nat.card (fixedBy (ZMod p × ZMod q) g)) = p * q := by
    rw [Finset.sum_eq_single (1 : Multiplicative (ZMod p))]
    · rw [fixedBy_timeShift_one]
      simp [Nat.card_eq_fintype_card, ZMod.card]
    · intro g _ hg
      rw [fixedBy_timeShift_eq_empty p q g hg]
      simp
    · intro h; exact absurd (Finset.mem_univ _) h
  rw [card_groupInvariantPattern_burnside, hsum]
  have hcard : Nat.card (Multiplicative (ZMod p)) = p := by
    simp [Nat.card_eq_fintype_card, ZMod.card]
  rw [hcard, Nat.mul_div_cancel_left _ (Nat.pos_of_ne_zero (NeZero.ne p))]

/-! ## A pattern whose symmetry group is a proper nontrivial subgroup -/

/-- A four-beat, one-pitch pattern with onsets on beats `0` and `2`. -/
def backbeat : ZMod 4 × ZMod 1 → Bool := fun a => decide (a.1 = 0 ∨ a.1 = 2)

theorem mem_symmetryGroup_backbeat (g : Multiplicative (ZMod 4)) :
    g ∈ symmetryGroup (Multiplicative (ZMod 4)) backbeat ↔
      (g = 1 ∨ g = Multiplicative.ofAdd 2) := by
  rw [mem_symmetryGroup_iff]
  revert g
  decide

/-- The half-bar shift is a symmetry of the backbeat pattern. -/
theorem ofAdd_two_mem_symmetryGroup_backbeat :
    (Multiplicative.ofAdd (2 : ZMod 4)) ∈ symmetryGroup (Multiplicative (ZMod 4)) backbeat :=
  (mem_symmetryGroup_backbeat _).2 (Or.inr rfl)

/-- The symmetry group of the backbeat is *not* the whole shift group: a pattern's
symmetry group is generally smaller than the ambient crystallographic group. -/
theorem symmetryGroup_backbeat_ne_top :
    symmetryGroup (Multiplicative (ZMod 4)) backbeat ≠ ⊤ := by
  intro h
  have hmem : (Multiplicative.ofAdd (1 : ZMod 4)) ∈
      symmetryGroup (Multiplicative (ZMod 4)) backbeat := by rw [h]; trivial
  rcases (mem_symmetryGroup_backbeat _).1 hmem with h1 | h1 <;> revert h1 <;> decide

/-- The symmetry group of the backbeat is nevertheless nontrivial. -/
theorem symmetryGroup_backbeat_ne_bot :
    symmetryGroup (Multiplicative (ZMod 4)) backbeat ≠ ⊥ := by
  intro h
  have := ofAdd_two_mem_symmetryGroup_backbeat
  rw [h, Subgroup.mem_bot] at this
  revert this
  decide

/-! ## More symmetry means less capacity -/

/-- Orbits of a subgroup refine orbits of a larger subgroup. -/
def orbitQuotientMap {H K : Subgroup G} (h : H ≤ K) :
    orbitRel.Quotient H α → orbitRel.Quotient K α :=
  Quotient.map' id (by
    rintro a b ⟨g, rfl⟩
    exact ⟨⟨(g : G), h g.2⟩, rfl⟩)

theorem orbitQuotientMap_surjective {H K : Subgroup G} (h : H ≤ K) :
    Function.Surjective (orbitQuotientMap (α := α) h) := by
  intro q
  induction q using Quotient.inductionOn' with
  | _ a => exact ⟨Quotient.mk'' a, rfl⟩

/-- A larger symmetry group has no more orbits. -/
theorem card_orbitQuotient_le {H K : Subgroup G} (h : H ≤ K) [Finite α] :
    Nat.card (orbitRel.Quotient K α) ≤ Nat.card (orbitRel.Quotient H α) :=
  Nat.card_le_card_of_surjective _ (orbitQuotientMap_surjective h)

/-- **Capacity is antitone in symmetry.**  Imposing invariance under a larger group
of symmetries can only decrease the number of admissible binary patterns. -/
theorem card_pattern_antitone {H K : Subgroup G} (h : H ≤ K) [Finite α] :
    Nat.card (GroupInvariantPattern K α) ≤ Nat.card (GroupInvariantPattern H α) := by
  rw [card_groupInvariantPattern, card_groupInvariantPattern]
  exact Nat.pow_le_pow_right (by norm_num) (card_orbitQuotient_le h)

/-! ## Numerical instances -/

/-- On the `3 × 3` torus there are exactly `32` retrograde–inversion invariant
patterns (five orbits: the centre plus four antipodal pairs). -/
theorem card_pattern_pointReflection_three_three :
    Nat.card (GroupInvariantPattern ℤˣ (ZMod 3 × ZMod 3)) = 32 := by
  have := card_pattern_pointReflection_odd 3 3 (by decide) (by decide)
  norm_num at this
  exact this

/-- On the `4 × 3` torus, where the time axis has even length, the inversion fixes
two cells, so there are `(12 + 2) / 2 = 7` orbits and exactly `128` invariant
patterns. -/
theorem card_pattern_pointReflection_four_three :
    Nat.card (GroupInvariantPattern ℤˣ (ZMod 4 × ZMod 3)) = 128 := by
  have h := card_pattern_pointReflection 4 3
  norm_num [twoTorsionCard, Nat.even_iff] at h
  exact h

/-- On the `4 × 3` torus there are exactly `8` fully time-shift invariant patterns. -/
theorem card_pattern_translation_four_three :
    Nat.card (GroupInvariantPattern (Multiplicative (ZMod 4)) (ZMod 4 × ZMod 3)) = 8 := by
  have := card_pattern_translation 4 3
  norm_num at this
  exact this

end OrbitCounting
end WallpaperRhythm