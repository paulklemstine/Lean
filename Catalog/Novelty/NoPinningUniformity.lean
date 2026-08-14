/-
# Perfect uniformity of the product map: the information-theoretic core

Fifth companion to `Novelty/NoPinningLemma.lean`.  The no-pinning lemma is
analytic (Dirichlet).  Underneath it lies a purely group-theoretic fact which
explains *why* no congruence battery can ever leak a factor: the multiplication
map of a group is a perfectly uniform hash.  Every value `u` has exactly `|G|`
ordered factorisations `u = x·y`, and the first coordinate ranges over the whole
group.  Observing the product therefore conveys **zero** information about the
individual factor class.

## Main results

* `factorPairEquiv` — for any group `G` and any `u : G`, the set of ordered
  factorisations `{(x,y) : x·y = u}` is in bijection with `G` itself.
* `card_factor_pairs` — the finite count: `|{(x,y) : x·y = u}| = |G|`,
  independent of `u`.
* `card_factor_pairs_zmod` — for the unit group of `ZMod L` this is Euler's
  `φ(L)`: given the residue of a semiprime mod `L`, exactly `φ(L)` factor
  classes remain, i.e. all of them.
* `existsUnique_partner` — each candidate class has exactly one partner class
  (the analytic content of `compensating_class_unique`, at group level).
* `consistent_class_count_independent_of_target` — the number of consistent
  candidate classes does not depend on the observed data: a modulus-`L` battery
  transmits no information about the factor class.
-/

import Mathlib
import Novelty.NoPinningLemma

namespace Novelty.NoPinning

variable {G : Type} [Group G]

/-- Ordered factorisations of `u` in a group are in bijection with the group:
`x ↦ (x, x⁻¹u)`. -/
def factorPairEquiv (u : G) : {p : G × G // p.1 * p.2 = u} ≃ G where
  toFun p := p.1.1
  invFun x := ⟨(x, x⁻¹ * u), by group⟩
  left_inv := by
    rintro ⟨⟨x, y⟩, hxy⟩
    ext
    · rfl
    · simpa using by rw [← hxy]; group
  right_inv x := rfl

/-- **Perfect uniformity.**  In a finite group every element has exactly `|G|`
ordered factorisations. -/
theorem card_factor_pairs [Fintype G] [DecidableEq G] (u : G) :
    (Finset.univ.filter (fun p : G × G => p.1 * p.2 = u)).card = Fintype.card G := by
  classical
  refine Finset.card_bij' (fun p _ => p.1) (fun x _ => (x, x⁻¹ * u)) ?_ ?_ ?_ ?_
  · intro p hp; exact Finset.mem_univ _
  · intro x _
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    group
  · rintro ⟨x, y⟩ hp
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hp
    subst hp
    simp
  · intro x _; rfl

/-- Each candidate class `x` has a unique partner class: the data determines the
cofactor's class and nothing else. -/
theorem existsUnique_partner (u x : G) : ∃! y : G, x * y = u := by
  refine ⟨x⁻¹ * u, by group, fun y hy => ?_⟩
  rw [← hy]; group

/-- For the unit group of `ZMod L`: given the observed class `u` of a semiprime,
exactly `φ(L)` candidate classes remain — every single one of them. -/
theorem card_factor_pairs_zmod (L : ℕ) [NeZero L] (u : (ZMod L)ˣ) :
    (Finset.univ.filter (fun p : (ZMod L)ˣ × (ZMod L)ˣ => p.1 * p.2 = u)).card =
      Nat.totient L := by
  classical
  rw [card_factor_pairs u, ZMod.card_units_eq_totient L]

/-- **Zero information.**  The number of consistent candidate classes is the
same for every observed value: whatever a modulus-`L` battery reads off, the set
of possible factor classes is the full unit group.  (Compare
`consistent_classes_eq_univ`, which upgrades "class" to "prime".) -/
theorem consistent_class_count_independent_of_target (L : ℕ) [NeZero L]
    (u v : (ZMod L)ˣ) :
    (Finset.univ.filter (fun p : (ZMod L)ˣ × (ZMod L)ˣ => p.1 * p.2 = u)).card =
      (Finset.univ.filter (fun p : (ZMod L)ˣ × (ZMod L)ˣ => p.1 * p.2 = v)).card := by
  classical
  rw [card_factor_pairs_zmod L u, card_factor_pairs_zmod L v]

/-- Projection form: every unit class occurs as the first coordinate of a
factorisation of `u`.  No class is excluded. -/
theorem factor_classes_surjective (u : G) (x : G) : ∃ y : G, x * y = u :=
  ⟨x⁻¹ * u, by group⟩

end Novelty.NoPinning