import Bridges.MolienQSeriesRigidity

/-!
# Regular actions: the exact blind spot of Molien-type rigidity

This file continues the Conjecture D thread of
`Catalog/Bridges/MolienQSeriesRigidity.lean` (q-series rigidity / Molien-type dichotomy) and
`Catalog/Bridges/MolienPeelingReconstruction.lean` (effective reconstruction).  Those files show
that the fixed-point q-series `Φ_{G,X}(q) = ∑_g q^{|X^g|}` and the orbit-counting generating
function `N_{G,X}(t) = ∑_n #((Fin n → X)/G) tⁿ` determine one another (after normalising by
`|G|`).  The natural next question, recorded as Conjectures D3 and D8 of `FUTURE_DIRECTIONS.md`,
is *how much more* than the fixed-point data these invariants see.  The answer proved here is:
**nothing more at all**, and the failure is already visible on the most symmetric actions.

## Results

* `fixCount_regular`, `fixFiberCard_regular`, `fixMultiset_regular` — the complete fixed-point
  data of the left regular action of a finite group on itself: one element (the identity) fixes
  everything, every other element fixes nothing.
* `orbitCount_regular` — `#((Fin (n+1) → G)/G) = |G|ⁿ`, i.e. the orbit-counting series of a
  regular action is `N(t) = 1 + t/(1 − |G|t)`, a function of `|G|` alone.
* `regular_fixQSeries_eq_iff`, `regular_molien_indistinguishable` — two regular actions are
  Molien-indistinguishable **iff** the two groups have the same order.  So on the class of
  regular actions the entire q-series / orbit-count package is exactly one number, `|G|`.
* `molien_blind_to_group_structure` — the concrete witness: `Z/4` and `Z/2 × Z/2` acting on
  themselves have identical fixed-point q-series and identical orbit counts in every degree,
  yet the groups are not isomorphic.  Conjecture D therefore cannot be upgraded from "determines
  the fixed-point distribution" to "determines the group", and this is a theorem, not a gap in
  the proof (compare `normalisation_necessary`, which located the other boundary).
* `sameGroup_orbitCount_iff_fixMultiset`, `sameGroup_orbitCount_iff_fixFiberCard` — Conjecture D8:
  for two actions of *one and the same* group the normalisation disappears and rigidity upgrades
  from densities to raw fibre cardinalities: equality of the first `max(|X|,|Y|)+1` orbit counts
  is equivalent to equality of the multisets `{|X^g|}` and `{|Y^g|}`.
* `orbitCount_eq_iff_of_card_eq` — the two boundaries combined: for groups of equal order,
  agreement of finitely many orbit counts, agreement of all of them, equality of the q-series and
  equality of the fixed-point multisets are all the same condition.
-/

namespace MolienRigidity

open MulAction Finset

/-! ## Part 1: the fixed-point data of the left regular action -/

section Regular

variable (G : Type*) [Group G] [Fintype G] [DecidableEq G]

/-- **Fixed points of the regular action.**  Acting on itself by left translation, the identity
of `G` fixes all of `G` and every other element fixes nothing. -/
theorem fixCount_regular (g : G) : fixCount G G g = if g = 1 then Fintype.card G else 0 := by
  rw [fixCount]
  by_cases h : g = 1
  · subst h
    have hf : (fixedBy G (1 : G)) = Set.univ := by ext x; simp
    simp [hf, Nat.card_eq_fintype_card]
  · have hf : (fixedBy G g) = (∅ : Set G) := by
      ext x
      simp only [mem_fixedBy, Set.mem_empty_iff_false, iff_false, smul_eq_mul]
      exact fun hx => h (right_eq_mul.mp hx.symm)
    simp [hf, h]

/-- The fixed-point fibres of a regular action: one element with `|G|` fixed points, and
`|G| - 1` elements with none. -/
theorem fixFiberCard_regular (v : ℕ) :
    fixFiberCard G G v =
      if v = Fintype.card G then 1 else if v = 0 then Fintype.card G - 1 else 0 := by
  have hN : 0 < Fintype.card G := Fintype.card_pos
  rw [fixFiberCard]
  by_cases hv : v = Fintype.card G
  · subst hv
    have hf : (univ.filter fun g : G => fixCount G G g = Fintype.card G) = {1} := by
      ext g
      by_cases hg : g = 1 <;> simp [fixCount_regular, hg]
      omega
    simp [hf]
  · by_cases hv0 : v = 0
    · subst hv0
      have hf : (univ.filter fun g : G => fixCount G G g = 0) = univ.erase 1 := by
        ext g
        by_cases hg : g = 1 <;> simp [fixCount_regular, hg]
      simp [hf, hv, Finset.card_erase_of_mem, Finset.card_univ]
    · have hf : (univ.filter fun g : G => fixCount G G g = v) = ∅ := by
        ext g
        by_cases hg : g = 1 <;> simp [fixCount_regular, hg] <;> omega
      simp [hf, hv, hv0]

/-- The fixed-point multiset of a regular action depends only on the order of the group. -/
theorem fixMultiset_regular :
    fixMultiset G G = Fintype.card G ::ₘ Multiset.replicate (Fintype.card G - 1) 0 := by
  have hN : 0 < Fintype.card G := Fintype.card_pos
  refine Multiset.ext.mpr fun v => ?_
  rw [count_fixMultiset, fixFiberCard_regular, Multiset.count_cons, Multiset.count_replicate]
  split_ifs <;> omega

/-- **The orbit counts of a regular action.**  `#((Fin (n+1) → G)/G) = |G|ⁿ`: the regular action
is free, so the orbit-counting series is `1 + t/(1 - |G| t)` — a function of the group order
alone, with no other trace of the group. -/
theorem orbitCount_regular (n : ℕ) : orbitCount G G (n + 1) = Fintype.card G ^ n := by
  have hN : 0 < Fintype.card G := Fintype.card_pos
  have hb := burnside_moment G G (n + 1)
  have hsum : (∑ g : G, fixCount G G g ^ (n + 1)) = Fintype.card G ^ (n + 1) := by
    rw [Finset.sum_eq_single (1 : G)]
    · rw [fixCount_regular]; simp
    · intro b _ hb1
      rw [fixCount_regular, if_neg hb1]
      simp
    · intro h; exact absurd (Finset.mem_univ (1 : G)) h
  rw [hsum, Nat.card_eq_fintype_card] at hb
  have : Fintype.card G * orbitCount G G (n + 1) = Fintype.card G * Fintype.card G ^ n := by
    rw [hb, pow_succ, mul_comm]
  exact Nat.eq_of_mul_eq_mul_left hN this

end Regular

/-! ## Part 2: Molien-indistinguishability of regular actions -/

section Indistinguishable

variable (G : Type*) [Group G] [Fintype G] [DecidableEq G]
variable (H : Type*) [Group H] [Fintype H] [DecidableEq H]

/-- **The q-series of a regular action sees exactly the group order.**  Two regular actions have
the same fixed-point q-series iff the two groups have the same order — the isomorphism type of
the group is invisible. -/
theorem regular_fixQSeries_eq_iff :
    fixQSeries G G = fixQSeries H H ↔ Fintype.card G = Fintype.card H := by
  rw [fixQSeries_eq_iff_fixMultiset]
  constructor
  · exact card_eq_of_fixMultiset_eq G G H H
  · intro hGH
    rw [fixMultiset_regular, fixMultiset_regular, hGH]

/-- **Regular actions of equal-order groups are Molien-indistinguishable**: same fixed-point
q-series, and hence the same orbit count in every degree. -/
theorem regular_molien_indistinguishable (hGH : Fintype.card G = Fintype.card H) :
    fixQSeries G G = fixQSeries H H ∧ ∀ n, orbitCount G G n = orbitCount H H n := by
  have hq : fixQSeries G G = fixQSeries H H := (regular_fixQSeries_eq_iff G H).mpr hGH
  refine ⟨hq, fun n => ?_⟩
  have := congrArg (fun s => PowerSeries.coeff n s) (fixQSeries_determines_orbitSeries G G H H hq)
  simpa [orbitSeriesPS] using this

end Indistinguishable

/-! ## Part 3: the concrete blind spot — `Z/4` versus `Z/2 × Z/2` -/

section Witness

/-- The cyclic group of order four, written multiplicatively. -/
abbrev C4 : Type := Multiplicative (ZMod 4)

/-- The Klein four-group, written multiplicatively. -/
abbrev V4 : Type := Multiplicative (ZMod 2 × ZMod 2)

theorem card_C4 : Fintype.card C4 = 4 := by decide

theorem card_V4 : Fintype.card V4 = 4 := by decide

/-- `Z/4` and `Z/2 × Z/2` are not isomorphic: every element of the Klein group is an involution,
while `1 ∈ Z/4` is not. -/
theorem C4_not_mulEquiv_V4 : IsEmpty (C4 ≃* V4) := by
  constructor
  intro e
  have hinv : ∀ x : V4, x * x = 1 := by decide
  have hkey := hinv (e (Multiplicative.ofAdd (1 : ZMod 4)))
  rw [← map_mul] at hkey
  have hsq : (Multiplicative.ofAdd (1 : ZMod 4)) * (Multiplicative.ofAdd (1 : ZMod 4)) = 1 :=
    e.injective (hkey.trans (map_one e).symm)
  revert hsq
  decide

/-- **Molien rigidity is blind to the isomorphism type of the group.**  The regular actions of
`Z/4` and of `Z/2 × Z/2` have identical fixed-point q-series and identical orbit counts in every
degree, yet the two groups are not isomorphic.  Hence Conjecture D is optimal: the pair
(q-series, orbit series) is a complete invariant of the fixed-point distribution and of strictly
nothing finer. -/
theorem molien_blind_to_group_structure :
    fixQSeries C4 C4 = fixQSeries V4 V4 ∧
      (∀ n, orbitCount C4 C4 n = orbitCount V4 V4 n) ∧
      IsEmpty (C4 ≃* V4) :=
  ⟨(regular_molien_indistinguishable C4 V4 (card_C4.trans card_V4.symm)).1,
    (regular_molien_indistinguishable C4 V4 (card_C4.trans card_V4.symm)).2,
    C4_not_mulEquiv_V4⟩

/-- The common orbit-counting sequence of the two witnesses is `1, 1, 4, 16, 64, …`, so the
coincidence is not a degenerate one: the actions are faithful, transitive and free. -/
theorem orbitCount_witness (n : ℕ) :
    orbitCount C4 C4 (n + 1) = 4 ^ n ∧ orbitCount V4 V4 (n + 1) = 4 ^ n := by
  refine ⟨?_, ?_⟩
  · rw [orbitCount_regular, card_C4]
  · rw [orbitCount_regular, card_V4]

end Witness

/-! ## Part 3b: the blind spot is not isolated — an infinite family -/

section Family

variable (p : ℕ) [NeZero p]

theorem card_cyclic_sq : Fintype.card (Multiplicative (ZMod (p ^ 2))) = p ^ 2 := by
  simp [Fintype.card_multiplicative, ZMod.card]

theorem card_elementary_sq : Fintype.card (Multiplicative (ZMod p × ZMod p)) = p ^ 2 := by
  simp [Fintype.card_multiplicative, ZMod.card, sq]

omit [NeZero p] in
/-- For `p ≥ 2` the cyclic group of order `p²` is not isomorphic to `Z/p × Z/p`: the latter has
exponent dividing `p`, the former does not. -/
theorem cyclic_sq_not_mulEquiv_elementary (hp : 2 ≤ p) :
    IsEmpty (Multiplicative (ZMod (p ^ 2)) ≃* Multiplicative (ZMod p × ZMod p)) := by
  constructor
  intro e
  have hB : ∀ y : Multiplicative (ZMod p × ZMod p), y ^ p = 1 := by
    intro y
    have hy : p • (Multiplicative.toAdd y) = 0 := by
      refine Prod.ext ?_ ?_ <;> simp [nsmul_eq_mul]
    calc y ^ p = Multiplicative.ofAdd (p • Multiplicative.toAdd y) := rfl
      _ = 1 := by rw [hy]; rfl
  set x : Multiplicative (ZMod (p ^ 2)) := Multiplicative.ofAdd (1 : ZMod (p ^ 2)) with hx
  have h1 : e (x ^ p) = 1 := by rw [map_pow]; exact hB _
  have h2 : x ^ p = 1 := e.injective (h1.trans (map_one e).symm)
  have h3 : ((p : ℕ) : ZMod (p ^ 2)) = 0 := by
    have hxp : Multiplicative.ofAdd ((p : ℕ) • (1 : ZMod (p ^ 2))) = 1 := h2
    simpa [nsmul_eq_mul] using hxp
  have h4 : p ^ 2 ∣ p := (ZMod.natCast_eq_zero_iff p (p ^ 2)).mp h3
  have := Nat.le_of_dvd (by omega) h4
  nlinarith

/-- **The blind spot occurs in every order `p²` with `p ≥ 2`.**  The regular actions of `Z/p²`
and of `Z/p × Z/p` are Molien-indistinguishable — identical fixed-point q-series, identical
orbit counts in every degree — while the groups are non-isomorphic.  So the failure exhibited by
`molien_blind_to_group_structure` is generic, not an accident of order four. -/
theorem molien_blind_family (hp : 2 ≤ p) :
    fixQSeries (Multiplicative (ZMod (p ^ 2))) (Multiplicative (ZMod (p ^ 2)))
        = fixQSeries (Multiplicative (ZMod p × ZMod p)) (Multiplicative (ZMod p × ZMod p)) ∧
      (∀ n, orbitCount (Multiplicative (ZMod (p ^ 2))) (Multiplicative (ZMod (p ^ 2))) n
          = orbitCount (Multiplicative (ZMod p × ZMod p)) (Multiplicative (ZMod p × ZMod p)) n) ∧
      IsEmpty (Multiplicative (ZMod (p ^ 2)) ≃* Multiplicative (ZMod p × ZMod p)) := by
  have hcard : Fintype.card (Multiplicative (ZMod (p ^ 2)))
      = Fintype.card (Multiplicative (ZMod p × ZMod p)) :=
    (card_cyclic_sq p).trans (card_elementary_sq p).symm
  exact ⟨(regular_molien_indistinguishable _ _ hcard).1,
    (regular_molien_indistinguishable _ _ hcard).2, cyclic_sq_not_mulEquiv_elementary p hp⟩

end Family

/-! ## Part 4: Conjecture D8 — for a fixed group, rigidity holds without normalisation -/

section SameGroup

variable (G : Type*) [Group G] [Fintype G]
variable (X : Type*) [MulAction G X] [Finite X]
variable (Y : Type*) [MulAction G Y] [Finite Y]

/-- **Conjecture D8.**  For two actions of the *same* group the `1/|G|` normalisation is common
to both sides and therefore harmless: agreement of the orbit counts in the first
`max(|X|,|Y|)+1` degrees is *equivalent* to equality of the raw fixed-point multisets.  (For
actions of different groups this fails; see `normalisation_necessary`.) -/
theorem sameGroup_orbitCount_iff_fixMultiset :
    (∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount G Y n)
      ↔ fixMultiset G X = fixMultiset G Y := by
  constructor
  · intro h
    exact (fixDensity_eq_iff_fixMultiset G X G Y rfl).mp
      (orbitCount_determines_fixDensity G X G Y h)
  · intro h n _
    exact fixDensity_determines_orbitCount G X G Y
      ((fixDensity_eq_iff_fixMultiset G X G Y rfl).mpr h) n

/-- Fibrewise form of Conjecture D8: finitely many orbit counts determine, for every `v`, the
exact *number* of group elements fixing exactly `v` points. -/
theorem sameGroup_orbitCount_iff_fixFiberCard :
    (∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount G Y n)
      ↔ ∀ v, fixFiberCard G X v = fixFiberCard G Y v := by
  rw [sameGroup_orbitCount_iff_fixMultiset]
  constructor
  · intro h v
    have := Multiset.ext.mp h v
    rwa [count_fixMultiset, count_fixMultiset] at this
  · intro h
    refine Multiset.ext.mpr fun v => ?_
    rw [count_fixMultiset, count_fixMultiset, h v]

end SameGroup

/-! ## Part 5: the complete picture for groups of equal order -/

section Equivalence

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]
variable (H : Type*) [Group H] [Fintype H] (Y : Type*) [MulAction H Y] [Finite Y]

/-- **The four equivalent forms of Molien rigidity.**  For actions of groups of the same order,
finite agreement of orbit counts, full agreement of orbit counts, equality of the fixed-point
q-series, and equality of the fixed-point multisets are all one and the same condition.  Together
with `molien_blind_to_group_structure` this pins down exactly what the orbit-counting series
knows: the fixed-point multiset, and nothing else. -/
theorem orbitCount_eq_iff_of_card_eq (hGH : Fintype.card G = Fintype.card H) :
    ((∀ n ≤ max (Nat.card X) (Nat.card Y), orbitCount G X n = orbitCount H Y n)
        ↔ (∀ n, orbitCount G X n = orbitCount H Y n)) ∧
      ((∀ n, orbitCount G X n = orbitCount H Y n) ↔ fixQSeries G X = fixQSeries H Y) ∧
      (fixQSeries G X = fixQSeries H Y ↔ fixMultiset G X = fixMultiset H Y) := by
  refine ⟨⟨fun h n => ?_, fun h n _ => h n⟩, (molien_rigidity_iff G X H Y hGH).symm,
    fixQSeries_eq_iff_fixMultiset G X H Y⟩
  exact fixDensity_determines_orbitCount G X H Y (orbitCount_determines_fixDensity G X H Y h) n

end Equivalence

end MolienRigidity