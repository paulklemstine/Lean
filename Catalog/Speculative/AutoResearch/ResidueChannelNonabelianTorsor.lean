/-
# The non-abelian residue channel: no pruning, but no torsor either (conjecture C5')

Tenth file of the residue-leakage thread.

`Catalog/Bridges/ResidueLeakageTorsorTriviality.lean` proved that the
factorisation fibre of the quadratic-residue fingerprint is a *trivial torsor*:
the set of consistent pairs `(F_A(p), F_A(q))` is exactly one coset of the
anti-diagonal of `{±1}^K`, so every candidate survives and the compensator of a
candidate is unique.  Conjecture C5' of `FUTURE_DIRECTIONS.md` asked what
happens when the abelian character channel is replaced by the **Artin-symbol
channel** of a non-abelian Galois extension: there the datum attached to a
prime is a conjugacy class `C_p ⊆ G`, the datum attached to `N = p·q` is the
class of `σ_N = σ_p σ_q`, and the fibre is
`{(C_p, C_q) : σ_N ∈ C_p · C_q}`.  C5' predicted that this fibre is a *proper*
subset of `Cl(G) × Cl(G)` for non-abelian `G`, i.e. that some candidate classes
are excluded — the first residue-type channel with nonzero pruning.

This file settles C5' in the purely group-theoretic form in which it was
stated, and the answer splits:

* **The pruning half of C5' is FALSE.** `nonabelian_no_pruning`: in *any* group,
  for any target `σ` and any candidate `p`, the element `q = p⁻¹σ` compensates.
  So the projection of the fibre onto the first coordinate is onto every
  conjugacy class; a non-abelian Artin channel prunes exactly nothing either.
  (`classCompatible_conj_left` / `classCompatible_conj_right` check that the
  relation really only depends on the two conjugacy classes, so this is a
  statement about `Cl(G) × Cl(G)`.)
* **The torsor half of C5' is TRUE, and is an exact characterisation.**
  `torsor_iff_abelian`: the compensator of a candidate is unique up to
  conjugacy for *all* targets and candidates **iff** the group is abelian.
  For a non-abelian group there are explicit targets with two non-conjugate
  compensators (`nonabelian_two_nonconj_compensators`), witnessed concretely in
  `S₃` by `perm3_two_nonconj_compensators`.
* The failure is genuinely a class-level phenomenon: at the level of *elements*
  the fibre is always a torsor, of size exactly `|C_p|`
  (`elementFibre_ncard`), for every group, abelian or not.

Conclusion for the thread: no-pruning is not an artefact of commutativity — it
survives every group-theoretic residue channel — while the rigid torsor
structure found for the quadratic fingerprint is *equivalent* to commutativity.
The `2^K`-torsor picture of `ResidueLeakageTorsorTriviality.lean` is therefore
exactly as general as the abelian hypothesis, and no residue channel of this
shape can prune the divisor search.

All statements are proved; no `sorry`, no `axiom`, no `native_decide`.
-/

import Mathlib

namespace Bridges.ResidueLeakage.Nonabelian

variable {G : Type*} [Group G]

/-- `classCompatible σ p q` says that the target `σ` lies in the product of the
conjugacy class of `p` with the conjugacy class of `q`: the class-level
statement "`(C_p, C_q)` is a consistent factorisation pattern for `σ`". -/
def classCompatible (σ p q : G) : Prop :=
  ∃ x y : G, IsConj p x ∧ IsConj q y ∧ x * y = σ

/-- Consistency depends on `p` only through its conjugacy class. -/
theorem classCompatible_conj_left {σ p p' q : G} (h : IsConj p p') :
    classCompatible σ p q ↔ classCompatible σ p' q := by
  constructor
  · rintro ⟨x, y, hx, hy, hxy⟩
    exact ⟨x, y, h.symm.trans hx, hy, hxy⟩
  · rintro ⟨x, y, hx, hy, hxy⟩
    exact ⟨x, y, h.trans hx, hy, hxy⟩

/-- Consistency depends on `q` only through its conjugacy class. -/
theorem classCompatible_conj_right {σ p q q' : G} (h : IsConj q q') :
    classCompatible σ p q ↔ classCompatible σ p q' := by
  constructor
  · rintro ⟨x, y, hx, hy, hxy⟩
    exact ⟨x, y, hx, h.symm.trans hy, hxy⟩
  · rintro ⟨x, y, hx, hy, hxy⟩
    exact ⟨x, y, hx, h.trans hy, hxy⟩

/-- Explicit description of the consistent partners of a candidate: `q` works
iff it is conjugate to `x⁻¹σ` for some `x` in the class of `p`. -/
theorem classCompatible_iff {σ p q : G} :
    classCompatible σ p q ↔ ∃ x : G, IsConj p x ∧ IsConj q (x⁻¹ * σ) := by
  constructor
  · rintro ⟨x, y, hx, hy, hxy⟩
    refine ⟨x, hx, ?_⟩
    have : y = x⁻¹ * σ := by rw [← hxy]; group
    rwa [this] at hy
  · rintro ⟨x, hx, hq⟩
    exact ⟨x, x⁻¹ * σ, hx, hq, by group⟩

/-- The canonical compensator: `p⁻¹σ` always works. -/
theorem classCompatible_inv_mul (σ p : G) : classCompatible σ p (p⁻¹ * σ) :=
  ⟨p, p⁻¹ * σ, IsConj.refl _, IsConj.refl _, by group⟩

/-- **No pruning in every group channel** (refutes the pruning half of C5').
For any target `σ` and any candidate `p` there is a compensating `q`, so the
fibre `{(C_p, C_q) : σ ∈ C_p C_q}` surjects onto all of `Cl(G)`: not a single
candidate class is excluded, abelian or not. -/
theorem nonabelian_no_pruning (σ p : G) : ∃ q : G, classCompatible σ p q :=
  ⟨p⁻¹ * σ, classCompatible_inv_mul σ p⟩

/-- In a commutative group the compensator is *exactly* `p⁻¹σ`: the fibre is a
trivial torsor.  This is the group-theoretic core of `consistentPairs_eq`. -/
theorem abelian_compensator_unique {H : Type*} [CommGroup H] (σ p q : H) :
    classCompatible σ p q ↔ q = p⁻¹ * σ := by
  constructor
  · rintro ⟨x, y, hx, hy, hxy⟩
    rw [isConj_iff_eq] at hx hy
    subst hx; subst hy
    rw [← hxy]; group
  · rintro rfl
    exact classCompatible_inv_mul σ p

/-- In a non-abelian group there are a target and a candidate with two
**non-conjugate** compensators: the class-level fibre is not a torsor.
Concretely, for non-commuting `a, b` the target `σ = a` and candidate `p = a`
admit both `q = 1` and `q = (b a b⁻¹)⁻¹ a ≠ 1`. -/
theorem nonabelian_two_nonconj_compensators {a b : G} (hab : a * b ≠ b * a) :
    classCompatible a a 1 ∧ classCompatible a a ((b * a * b⁻¹)⁻¹ * a) ∧
      ¬ IsConj (1 : G) ((b * a * b⁻¹)⁻¹ * a) := by
  refine ⟨⟨a, 1, IsConj.refl _, IsConj.refl _, by group⟩,
    ⟨b * a * b⁻¹, (b * a * b⁻¹)⁻¹ * a,
      ⟨⟨b, b⁻¹, by group, by group⟩, by simp [SemiconjBy]⟩, IsConj.refl _, by group⟩, ?_⟩
  intro hc
  rw [isConj_one_right] at hc
  have hba : b * a * b⁻¹ = a := inv_mul_eq_one.mp hc
  exact hab (by
    calc a * b = b * a * b⁻¹ * b := by rw [hba]
      _ = b * a := by group)

/-- **The torsor structure is equivalent to commutativity.**  The compensator
of a candidate is unique up to conjugacy, for every target and candidate, if
and only if the group is abelian.  Together with `nonabelian_no_pruning` this
closes conjecture C5': a non-abelian channel loses the rigid torsor structure
of the quadratic fingerprint, but gains no pruning power whatsoever. -/
theorem torsor_iff_abelian :
    (∀ σ p q q' : G, classCompatible σ p q → classCompatible σ p q' → IsConj q q') ↔
      ∀ a b : G, a * b = b * a := by
  constructor
  · intro h a b
    by_contra hab
    obtain ⟨h1, h2, h3⟩ := nonabelian_two_nonconj_compensators hab
    exact h3 (h a a 1 _ h1 h2)
  · intro hcomm σ p q q' h1 h2
    obtain ⟨x, y, hx, hy, hxy⟩ := h1
    obtain ⟨x', y', hx', hy', hxy'⟩ := h2
    have key : ∀ {u v : G}, IsConj u v → u = v := by
      intro u v huv
      obtain ⟨c, hc⟩ := huv
      rw [SemiconjBy] at hc
      exact mul_left_cancel (a := (c : G)) (by rw [hc, hcomm])
    have hq : q = y := key hy
    have hq' : q' = y' := key hy'
    have hxx : x = x' := (key hx).symm.trans (key hx')
    have hyy : y = y' := mul_left_cancel (a := x) (by rw [hxy, hxx, hxy'])
    rw [hq, hq', hyy]

/-- Compensators of the trivial candidate class: `q` works for `p = 1` exactly
when `q` is conjugate to the target. -/
theorem classCompatible_one_left {σ q : G} : classCompatible σ 1 q ↔ IsConj q σ := by
  constructor
  · rintro ⟨x, y, hx, hy, hxy⟩
    rw [isConj_one_right] at hx
    subst hx
    rw [one_mul] at hxy
    rwa [hxy] at hy
  · intro h
    exact ⟨1, σ, IsConj.refl _, h, by group⟩

/-- **The fibre is inhomogeneous in the non-abelian case.**  For non-commuting
`a, b` and target `σ = a`, the candidate class of `1` has exactly one
compensating class, while the candidate class of `a` has at least two.  So the
number of compensating classes is not constant along the fibre — the exact
opposite of the abelian situation, where `abelian_compensator_unique` gives
precisely one compensator for every candidate. -/
theorem compensator_multiplicity_jump {a b : G} (hab : a * b ≠ b * a) :
    (∀ q q' : G, classCompatible a 1 q → classCompatible a 1 q' → IsConj q q') ∧
      ¬ (∀ q q' : G, classCompatible a a q → classCompatible a a q' → IsConj q q') := by
  refine ⟨fun q q' hq hq' => ?_, ?_⟩
  · exact (classCompatible_one_left.mp hq).trans (classCompatible_one_left.mp hq').symm
  · intro h
    obtain ⟨h1, h2, h3⟩ := nonabelian_two_nonconj_compensators hab
    exact h3 (h 1 _ h1 h2)

/-- At the level of *elements* (rather than classes) the fibre is always a
torsor, in every group: the consistent pairs `(x, y)` with `x` in the class of
`p` and `x y = σ` are in bijection with the class of `p`, hence there are
exactly `|C_p|` of them.  So the abelian/non-abelian dichotomy of
`torsor_iff_abelian` is created purely by the passage to conjugacy classes. -/
theorem elementFibre_ncard (σ p : G) :
    {z : G × G | IsConj p z.1 ∧ z.1 * z.2 = σ}.ncard = {x : G | IsConj p x}.ncard := by
  have himg : {z : G × G | IsConj p z.1 ∧ z.1 * z.2 = σ}
      = (fun x : G => (x, x⁻¹ * σ)) '' {x : G | IsConj p x} := by
    ext ⟨x, y⟩
    constructor
    · rintro ⟨hx, hxy⟩
      exact ⟨x, hx, by simp [← hxy]⟩
    · rintro ⟨x', hx', h⟩
      obtain ⟨rfl, rfl⟩ := Prod.mk.injEq .. ▸ h
      exact ⟨hx', by group⟩
  rw [himg, Set.ncard_image_of_injective _ (fun u v huv => by simpa using congrArg Prod.fst huv)]

section Perm3

/-- `S₃` is non-abelian: an explicit pair of non-commuting permutations. -/
theorem perm3_noncomm :
    (Equiv.swap (0 : Fin 3) 1) * (Equiv.swap (1 : Fin 3) 2)
      ≠ (Equiv.swap (1 : Fin 3) 2) * (Equiv.swap (0 : Fin 3) 1) := by
  decide

/-- Concrete `S₃` witness for the non-abelian failure of the torsor property:
the target `σ = (0 1)` and candidate class `C_p = {transpositions}` admit two
non-conjugate compensators (the identity and a `3`-cycle).  Hence the
Artin-symbol fibre of a non-abelian extension is *not* a torsor, while by
`nonabelian_no_pruning` it still excludes no candidate class. -/
theorem perm3_two_nonconj_compensators :
    classCompatible (Equiv.swap (0 : Fin 3) 1) (Equiv.swap (0 : Fin 3) 1) 1 ∧
      classCompatible (Equiv.swap (0 : Fin 3) 1) (Equiv.swap (0 : Fin 3) 1)
        (((Equiv.swap (1 : Fin 3) 2) * (Equiv.swap (0 : Fin 3) 1) *
          (Equiv.swap (1 : Fin 3) 2)⁻¹)⁻¹ * (Equiv.swap (0 : Fin 3) 1)) ∧
      ¬ IsConj (1 : Equiv.Perm (Fin 3))
        (((Equiv.swap (1 : Fin 3) 2) * (Equiv.swap (0 : Fin 3) 1) *
          (Equiv.swap (1 : Fin 3) 2)⁻¹)⁻¹ * (Equiv.swap (0 : Fin 3) 1)) :=
  nonabelian_two_nonconj_compensators perm3_noncomm

/-- `S₃` is a genuine counterexample to the class-level torsor property. -/
theorem perm3_not_torsor :
    ¬ (∀ σ p q q' : Equiv.Perm (Fin 3), classCompatible σ p q → classCompatible σ p q' →
        IsConj q q') := by
  intro h
  exact perm3_noncomm (torsor_iff_abelian.mp h _ _)

end Perm3

end Bridges.ResidueLeakage.Nonabelian