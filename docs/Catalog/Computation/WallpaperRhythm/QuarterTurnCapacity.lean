/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic
-/
import Computation.WallpaperRhythm.OrbitEntropy

/-!
# Realizable symmetry groups, quarter-turn capacity, and point-group descent

This file continues the orbit-counting analysis of symmetry-invariant rhythmic
patterns of `Computation.WallpaperRhythm.OrbitCounting` and
`Computation.WallpaperRhythm.OrbitEntropy`, and settles three of the questions
left open there.

## Main results

### Realizability of symmetry types

* `symmetryGroup_subgroupPattern` — for a group `G` acting on itself by
  translation, *every* subgroup `H ≤ G` is the symmetry group of an explicit
  pattern, namely the indicator function of `H`.
* `symmetryGroup_torusSubgroupPattern` — the same on a `p × q` time–pitch torus
  with the cyclic time-shift action of `OrbitCounting`: every subgroup of the
  shift group is realized exactly by an explicit pattern.  Hence no
  symmetry type is missing, and a pattern's symmetry group carries strictly more
  information than the ambient group.

### Quarter-turn capacity of a square torus

* `QuarterTurns` — the cyclic group of order four, acting on `ZMod p × ZMod p`
  by the descended quarter turn `(t, n) ↦ (-n, t)` of `OrbitEntropy`.
* `card_fixedBy_ofTurns_one`, `card_fixedBy_ofTurns_two` — each quarter turn
  fixes `twoTorsionCard p` cells and the half turn fixes `twoTorsionCard p ^ 2`.
* `card_pattern_quarterTurn` — consequently the number of quarter-turn invariant
  patterns is exactly `2 ^ ((p ^ 2 + 2 t + t ^ 2) / 4)` with
  `t = twoTorsionCard p`, specializing to `2 ^ ((p ^ 2 + 3) / 4)` for odd `p`
  (`card_pattern_quarterTurn_odd`) and `2 ^ ((p ^ 2 + 8) / 4)` for even `p`
  (`card_pattern_quarterTurn_even`).  `card_orbits_quarterTurn` gives the
  underlying orbit count, and the numeric instances `8`, `128`, `8`, `64` are
  recorded for the `3 × 3`, `5 × 5`, `2 × 2` and `4 × 4` tori.

### Which point-group elements descend to a rectangular torus

* `signedDiag_mapsTo_torusLattice` — a diagonal sign change always preserves the
  sublattice `pℤ × qℤ`, hence always descends to the `p × q` torus.
* `signedSwap_mapsTo_torusLattice_iff` — a signed coordinate *swap* preserves
  `pℤ × qℤ` if and only if `p = q`.

Together these determine the subgroup of the order-eight point group `D₄` of
signed permutation matrices that descends to a given torus: all of `D₄` when
`p = q`, and exactly the order-four diagonal subgroup otherwise.
-/

namespace WallpaperRhythm
namespace QuarterTurnCapacity

open MulAction
open WallpaperRhythm.OrbitCounting
open WallpaperRhythm.OrbitEntropy

/-! ## Every subgroup is realized as a symmetry group -/

section Realizability

variable {G : Type*} [Group G]

open Classical in
/-- The indicator pattern of a subgroup, viewed as a binary pattern on `G` with
the translation action of `G` on itself. -/
noncomputable def subgroupPattern (H : Subgroup G) : G → Bool :=
  fun a => if a ∈ H then true else false

@[simp] theorem subgroupPattern_apply (H : Subgroup G) (a : G) :
    subgroupPattern H a = true ↔ a ∈ H := by
  simp [subgroupPattern]

/-- **Realizability of symmetry types.**  For the translation action of a group on
itself, every subgroup occurs as the symmetry group of an explicit pattern: the
indicator function of the subgroup. -/
theorem symmetryGroup_subgroupPattern (H : Subgroup G) :
    symmetryGroup G (subgroupPattern H) = H := by
  ext g
  constructor
  · intro hg
    have h1 := (mem_symmetryGroup_iff.mp hg) 1
    rw [smul_eq_mul, mul_one, Bool.eq_iff_iff] at h1
    simpa using h1
  · intro hg
    refine mem_symmetryGroup_iff.mpr fun a => ?_
    rw [smul_eq_mul, Bool.eq_iff_iff, subgroupPattern_apply, subgroupPattern_apply]
    exact Subgroup.mul_mem_cancel_left H hg

end Realizability

open Classical in
/-- The indicator pattern on the `p × q` torus of a subgroup of the time-shift
group: a cell `(t, n)` is an onset exactly when the shift by `t` lies in `H`. -/
noncomputable def torusSubgroupPattern (p q : ℕ) (H : Subgroup (Multiplicative (ZMod p))) :
    ZMod p × ZMod q → Bool :=
  fun v => if Multiplicative.ofAdd v.1 ∈ H then true else false

@[simp] theorem torusSubgroupPattern_apply (p q : ℕ)
    (H : Subgroup (Multiplicative (ZMod p))) (t : ZMod p) (n : ZMod q) :
    torusSubgroupPattern p q H (t, n) = true ↔ Multiplicative.ofAdd t ∈ H := by
  simp [torusSubgroupPattern]

/-- **Realizability on a toroidal drum grid.**  Every subgroup of the cyclic
time-shift group of the `p × q` torus is *exactly* the symmetry group of an
explicit pattern.  In particular the symmetry group of a single pattern ranges
over all subgroups, from `⊥` to `⊤`, so no symmetry type is missing. -/
theorem symmetryGroup_torusSubgroupPattern (p q : ℕ)
    (H : Subgroup (Multiplicative (ZMod p))) :
    symmetryGroup (Multiplicative (ZMod p)) (torusSubgroupPattern p q H) = H := by
  ext g
  constructor
  · intro hg
    have h1 := (mem_symmetryGroup_iff.mp hg) ((0 : ZMod p), (0 : ZMod q))
    rw [timeShift_smul, Bool.eq_iff_iff] at h1
    simpa using h1
  · intro hg
    refine mem_symmetryGroup_iff.mpr fun v => ?_
    rw [timeShift_smul, Bool.eq_iff_iff, torusSubgroupPattern_apply,
      show torusSubgroupPattern p q H v = torusSubgroupPattern p q H (v.1, v.2) from rfl,
      torusSubgroupPattern_apply,
      show (Multiplicative.ofAdd (v.1 + Multiplicative.toAdd g))
        = Multiplicative.ofAdd v.1 * g from rfl]
    exact Subgroup.mul_mem_cancel_right H hg

/-! ## The cyclic group of quarter turns -/

/-- The abstract cyclic group of order four, which will act on a square torus by
quarter turns.  It is introduced as a type of its own so that its action does not
clash with the time-shift actions of `OrbitCounting`. -/
def QuarterTurns : Type := Multiplicative (ZMod 4)

namespace QuarterTurns

instance : Group QuarterTurns := inferInstanceAs (Group (Multiplicative (ZMod 4)))
instance : Fintype QuarterTurns := inferInstanceAs (Fintype (Multiplicative (ZMod 4)))
instance : DecidableEq QuarterTurns := inferInstanceAs (DecidableEq (Multiplicative (ZMod 4)))

/-- The element of `QuarterTurns` performing `a` quarter turns. -/
def ofTurns (a : ZMod 4) : QuarterTurns := (Multiplicative.ofAdd a : Multiplicative (ZMod 4))

/-- The number of quarter turns an element performs, as a natural number `< 4`. -/
def exp (g : QuarterTurns) : ℕ :=
  ZMod.val (Multiplicative.toAdd (g : Multiplicative (ZMod 4)))

@[simp] theorem exp_ofTurns (a : ZMod 4) : exp (ofTurns a) = a.val := rfl

theorem exp_mul (g h : QuarterTurns) : exp (g * h) = (exp g + exp h) % 4 := by
  show ZMod.val (Multiplicative.toAdd (g : Multiplicative (ZMod 4))
      + Multiplicative.toAdd (h : Multiplicative (ZMod 4))) = _
  rw [ZMod.val_add]
  rfl

@[simp] theorem exp_one : exp (1 : QuarterTurns) = 0 := rfl

theorem card_quarterTurns : Nat.card QuarterTurns = 4 := by
  show Nat.card (Multiplicative (ZMod 4)) = 4
  simp [Nat.card_eq_fintype_card]

/-- The four elements of the group, listed by their number of quarter turns. -/
theorem univ_eq : (Finset.univ : Finset QuarterTurns) =
    {ofTurns 0, ofTurns 1, ofTurns 2, ofTurns 3} := by
  decide

end QuarterTurns

open QuarterTurns

/-- Iterating a map whose fourth power is the identity only depends on the
exponent modulo four. -/
theorem iterate_mod_four {β : Type*} {f : β → β} (hf : ∀ v, f^[4] v = v) (m : ℕ) (v : β) :
    f^[m] v = f^[m % 4] v := by
  conv_lhs => rw [← Nat.div_add_mod m 4]
  rw [Function.iterate_add_apply]
  generalize f^[m % 4] v = w
  induction m / 4 with
  | zero => simp
  | succ k ih => rw [Nat.mul_succ, Function.iterate_add_apply, hf, ih]

/-- **The quarter-turn action.**  The cyclic group of order four acts on the
`p × p` time–pitch torus, the generator acting by the descended quarter turn
`(t, n) ↦ (-n, t)`. -/
instance quarterTurnAction (p : ℕ) : MulAction QuarterTurns (ZMod p × ZMod p) where
  smul g v := (quarterTurnZMod p)^[exp g] v
  one_smul v := by
    show (quarterTurnZMod p)^[exp (1 : QuarterTurns)] v = v
    rw [exp_one]
    rfl
  mul_smul g h v := by
    show (quarterTurnZMod p)^[exp (g * h)] v
      = (quarterTurnZMod p)^[exp g] ((quarterTurnZMod p)^[exp h] v)
    rw [← Function.iterate_add_apply, exp_mul]
    exact (iterate_mod_four (quarterTurnZMod_iterate_four p) _ v).symm

theorem quarterTurn_smul (p : ℕ) (g : QuarterTurns) (v : ZMod p × ZMod p) :
    g • v = (quarterTurnZMod p)^[exp g] v := rfl

/-- The cube of the quarter turn is the anticlockwise quarter turn. -/
theorem quarterTurnZMod_iterate_three (p : ℕ) (v : ZMod p × ZMod p) :
    (quarterTurnZMod p)^[3] v = (v.2, -v.1) := by
  show quarterTurnZMod p ((quarterTurnZMod p)^[2] v) = _
  rw [quarterTurnZMod_iterate_two]
  simp [quarterTurnZMod]

section SquareTorus

variable (p : ℕ) [NeZero p]

/-- The cells of the square torus fixed by the quarter turn are exactly the
diagonal cells `(t, t)` whose coordinate is its own negative. -/
def quarterFixedEquiv :
    {v : ZMod p × ZMod p // quarterTurnZMod p v = v} ≃ {x : ZMod p // -x = x} where
  toFun v := ⟨v.1.1, by
    have h1 : -v.1.2 = v.1.1 := congrArg Prod.fst v.2
    have h2 : v.1.1 = v.1.2 := congrArg Prod.snd v.2
    rw [← h2] at h1
    exact h1⟩
  invFun x := ⟨(x.1, x.1), by
    show ((-x.1 : ZMod p), x.1) = (x.1, x.1)
    rw [x.2]⟩
  left_inv v := by
    apply Subtype.ext
    have h2 : v.1.1 = v.1.2 := congrArg Prod.snd v.2
    exact Prod.ext rfl h2
  right_inv _ := rfl

omit [NeZero p] in
theorem fixedBy_ofTurns_zero :
    fixedBy (ZMod p × ZMod p) (ofTurns 0) = Set.univ := by
  ext v
  simp only [mem_fixedBy, quarterTurn_smul, exp_ofTurns, Set.mem_univ, iff_true]
  show (quarterTurnZMod p)^[(0 : ZMod 4).val] v = v
  rfl

omit [NeZero p] in
theorem fixedBy_ofTurns_one :
    fixedBy (ZMod p × ZMod p) (ofTurns 1)
      = {v : ZMod p × ZMod p | quarterTurnZMod p v = v} := by
  ext v
  have hval : ((1 : ZMod 4)).val = 1 := rfl
  simp only [mem_fixedBy, quarterTurn_smul, exp_ofTurns, hval, Function.iterate_one,
    Set.mem_setOf_eq]

omit [NeZero p] in
theorem fixedBy_ofTurns_two :
    fixedBy (ZMod p × ZMod p) (ofTurns 2) = {v : ZMod p × ZMod p | -v = v} := by
  ext v
  have hval : ((2 : ZMod 4)).val = 2 := rfl
  simp only [mem_fixedBy, quarterTurn_smul, exp_ofTurns, hval, Set.mem_setOf_eq,
    quarterTurnZMod_iterate_two]

theorem ofTurns_three_eq_inv : ofTurns 3 = (ofTurns 1 : QuarterTurns)⁻¹ := by
  decide

omit [NeZero p] in
theorem fixedBy_ofTurns_three :
    fixedBy (ZMod p × ZMod p) (ofTurns 3)
      = {v : ZMod p × ZMod p | quarterTurnZMod p v = v} := by
  rw [ofTurns_three_eq_inv, fixedBy_inv, fixedBy_ofTurns_one]

/-- The quarter turn of a square torus fixes exactly `twoTorsionCard p` cells: the
diagonal cells of order at most two. -/
theorem card_fixedBy_ofTurns_one :
    Nat.card (fixedBy (ZMod p × ZMod p) (ofTurns 1)) = twoTorsionCard p := by
  rw [fixedBy_ofTurns_one, show Nat.card {v : ZMod p × ZMod p | quarterTurnZMod p v = v}
      = Nat.card {v : ZMod p × ZMod p // quarterTurnZMod p v = v} from rfl,
    Nat.card_congr (quarterFixedEquiv p), card_negFixed p]

theorem card_fixedBy_ofTurns_three :
    Nat.card (fixedBy (ZMod p × ZMod p) (ofTurns 3)) = twoTorsionCard p := by
  rw [fixedBy_ofTurns_three, show Nat.card {v : ZMod p × ZMod p | quarterTurnZMod p v = v}
      = Nat.card {v : ZMod p × ZMod p // quarterTurnZMod p v = v} from rfl,
    Nat.card_congr (quarterFixedEquiv p), card_negFixed p]

/-- The half turn of a square torus fixes exactly `twoTorsionCard p ^ 2` cells. -/
theorem card_fixedBy_ofTurns_two :
    Nat.card (fixedBy (ZMod p × ZMod p) (ofTurns 2)) = twoTorsionCard p ^ 2 := by
  rw [fixedBy_ofTurns_two, show Nat.card {v : ZMod p × ZMod p | -v = v}
      = Nat.card {v : ZMod p × ZMod p // -v = v} from rfl,
    Nat.card_congr (negFixedProdEquiv p p), Nat.card_prod, card_negFixed p, sq]

/-- **Burnside data for the quarter-turn action.**  The identity fixes all `p ^ 2`
cells, each quarter turn fixes `twoTorsionCard p` cells and the half turn fixes
`twoTorsionCard p ^ 2` cells. -/
theorem sum_card_fixedBy_quarterTurns :
    (∑ g : QuarterTurns, Nat.card (fixedBy (ZMod p × ZMod p) g))
      = p ^ 2 + 2 * twoTorsionCard p + twoTorsionCard p ^ 2 := by
  classical
  have hzero : Nat.card (fixedBy (ZMod p × ZMod p) (ofTurns 0)) = p ^ 2 := by
    rw [fixedBy_ofTurns_zero p]
    simp [Nat.card_eq_fintype_card, ZMod.card, sq]
  rw [QuarterTurns.univ_eq]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [hzero, card_fixedBy_ofTurns_one p, card_fixedBy_ofTurns_two p,
    card_fixedBy_ofTurns_three p]
  ring

/-- **Quarter-turn capacity of a square torus.**  The number of binary patterns on
the `p × p` time–pitch torus invariant under the full group of quarter turns is
`2 ^ ((p ^ 2 + 2 t + t ^ 2) / 4)`, where `t = twoTorsionCard p` is the number of
cells of a `p`-cycle equal to their own negative. -/
theorem card_pattern_quarterTurn :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod p × ZMod p)) =
      2 ^ ((p ^ 2 + 2 * twoTorsionCard p + twoTorsionCard p ^ 2) / 4) := by
  classical
  rw [card_groupInvariantPattern_burnside, sum_card_fixedBy_quarterTurns p,
    QuarterTurns.card_quarterTurns]

/-- The quarter-turn action on a square torus has
`(p ^ 2 + 2 t + t ^ 2) / 4` orbits. -/
theorem card_orbits_quarterTurn :
    Nat.card (orbitRel.Quotient QuarterTurns (ZMod p × ZMod p)) =
      (p ^ 2 + 2 * twoTorsionCard p + twoTorsionCard p ^ 2) / 4 := by
  have h := card_pattern_quarterTurn p
  rw [card_groupInvariantPattern] at h
  exact Nat.pow_right_injective (le_refl 2) h

/-- **Odd square tori.**  For odd `p` the three nontrivial rotations fix only the
origin, so the capacity is `2 ^ ((p ^ 2 + 3) / 4)`. -/
theorem card_pattern_quarterTurn_odd (hp : Odd p) :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod p × ZMod p)) =
      2 ^ ((p ^ 2 + 3) / 4) := by
  have ht : twoTorsionCard p = 1 := if_neg (Nat.not_even_iff_odd.mpr hp)
  rw [card_pattern_quarterTurn p, ht]
  norm_num

/-- **Even square tori.**  For even `p` the quarter turns fix two cells each and the
half turn fixes four, so the capacity is `2 ^ ((p ^ 2 + 8) / 4)`. -/
theorem card_pattern_quarterTurn_even (hp : Even p) :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod p × ZMod p)) =
      2 ^ ((p ^ 2 + 8) / 4) := by
  have ht : twoTorsionCard p = 2 := if_pos hp
  rw [card_pattern_quarterTurn p, ht]
  congr 1

end SquareTorus

/-- The `3 × 3` torus carries exactly `8` quarter-turn invariant patterns. -/
theorem card_pattern_quarterTurn_three :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod 3 × ZMod 3)) = 8 := by
  rw [card_pattern_quarterTurn_odd 3 (by decide)]
  norm_num

/-- The `5 × 5` torus carries exactly `128` quarter-turn invariant patterns. -/
theorem card_pattern_quarterTurn_five :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod 5 × ZMod 5)) = 128 := by
  rw [card_pattern_quarterTurn_odd 5 (by decide)]
  norm_num

/-- The `2 × 2` torus carries exactly `8` quarter-turn invariant patterns. -/
theorem card_pattern_quarterTurn_two :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod 2 × ZMod 2)) = 8 := by
  rw [card_pattern_quarterTurn_even 2 (by decide)]
  norm_num

/-- The `4 × 4` torus carries exactly `64` quarter-turn invariant patterns. -/
theorem card_pattern_quarterTurn_four :
    Nat.card (GroupInvariantPattern QuarterTurns (ZMod 4 × ZMod 4)) = 64 := by
  rw [card_pattern_quarterTurn_even 4 (by decide)]
  norm_num

/-! ## Which point-group elements descend to a rectangular torus

The linear part of a planar isometry preserving the square lattice `ℤ × ℤ` is a
signed permutation matrix, i.e. either a diagonal sign change or a signed
coordinate swap.  We determine exactly which of these preserve the sublattice
`pℤ × qℤ`, hence descend to the `p × q` torus. -/

/-- A diagonal sign change of the integer plane. -/
def signedDiag (e₁ e₂ : ℤ) (v : ℤ × ℤ) : ℤ × ℤ := (e₁ * v.1, e₂ * v.2)

/-- A signed coordinate swap of the integer plane. -/
def signedSwap (e₁ e₂ : ℤ) (v : ℤ × ℤ) : ℤ × ℤ := (e₁ * v.2, e₂ * v.1)

/-- **Diagonal point-group elements always descend.**  Reflections in the time and
pitch axes and the half turn preserve `pℤ × qℤ` for all `p, q`. -/
theorem signedDiag_mapsTo_torusLattice (p q : ℕ) (e₁ e₂ : ℤ) :
    ∀ v ∈ torusLattice p q, signedDiag e₁ e₂ v ∈ torusLattice p q := by
  rintro v ⟨hv1, hv2⟩
  exact ⟨Dvd.dvd.mul_left hv1 e₁, Dvd.dvd.mul_left hv2 e₂⟩

/-- **Swapping point-group elements descend only to square tori.**  A signed
coordinate swap (a quarter turn, or a reflection in a diagonal) preserves
`pℤ × qℤ` if and only if `p = q`. -/
theorem signedSwap_mapsTo_torusLattice_iff (p q : ℕ) (e₁ e₂ : ℤ)
    (h₁ : IsUnit e₁) (h₂ : IsUnit e₂) :
    (∀ v ∈ torusLattice p q, signedSwap e₁ e₂ v ∈ torusLattice p q) ↔ p = q := by
  constructor
  · intro h
    have hp := h ((p : ℤ), 0) ⟨dvd_refl _, dvd_zero _⟩
    have hq := h (0, (q : ℤ)) ⟨dvd_zero _, dvd_refl _⟩
    have hqp : (q : ℤ) ∣ (p : ℤ) := by
      have := hp.2
      simp only [signedSwap] at this
      exact (IsUnit.dvd_mul_left h₂).mp this
    have hpq : (p : ℤ) ∣ (q : ℤ) := by
      have := hq.1
      simp only [signedSwap] at this
      exact (IsUnit.dvd_mul_left h₁).mp this
    exact Nat.dvd_antisymm (Int.natCast_dvd_natCast.mp hpq) (Int.natCast_dvd_natCast.mp hqp)
  · rintro rfl v ⟨hv1, hv2⟩
    exact ⟨Dvd.dvd.mul_left hv2 e₁, Dvd.dvd.mul_left hv1 e₂⟩

end QuarterTurnCapacity
end WallpaperRhythm