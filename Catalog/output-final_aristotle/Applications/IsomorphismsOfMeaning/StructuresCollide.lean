import Mathlib
import Catalog.Applications.Pythagorean.StrongDivisibilitySequences

/-! # Isomorphisms of Meaning: When Structures Collide

Domain: Applications (Group theory / Combinatorics / Number theory).

Two objects can be *structurally identical* — indistinguishable by every intrinsic,
relabeling-invariant property — and yet carry different *meaning*, i.e. act
differently on the concrete elements that name them.  This file makes that slogan
precise in two independent registers and shows they share one mechanism.

### 1. The isomorphism of isomorphisms

For an equivalence `e : α ≃ β` between two sets, relabeling turns every
self-symmetry of `α` into a self-symmetry of `β`.  This assignment
`Equiv.permCongrHom e : Perm α ≃* Perm β` is an *isomorphism between the two
groups of isomorphisms* — an "isomorphism of isomorphisms".  It is functorial in
`e` (`permCongrHom_comp`).

**Truth is preserved.**  Every relabeling-invariant quantity of a permutation is
carried across unchanged:

* `orderOf_permCongr`      — the order of a symmetry;
* `sign_permCongr'`        — its parity;
* `card_support_permCongr` — the number of points it disturbs (via `support_permCongr`).

**Meaning is not.**  On a fixed three-point set there are two symmetries that agree
on *every* such invariant — same cycle type, same order, same sign — yet act on
different points: `invariants_agree_meaning_differs`.  No invariant of the abstract
group structure separates them; only the concrete labels do.

### 2. Meaning-morphisms of the divisibility monoid collide

A *strong divisibility sequence* `u` (from
`Catalog/Applications/Pythagorean/StrongDivisibilitySequences.lean`) is a
structure-preserving map of the divisibility monoid: `u (gcd m n) = gcd (u m) (u n)`.
Two genuinely different sequences — the Fibonacci numbers and the Mersenne numbers
`2ⁿ − 1` — satisfy the *same* structural law yet are unequal as functions
(`meaning_morphisms_collide`), and both consequently obey the *same* divisibility
implication `m ∣ n → u m ∣ u n` (`shared_divisibility_law`).  Identical structure,
different meaning.

The unifying insight, recorded in the Lab Notes, is that "truth" is exactly the
part of an object stable under the acting isomorphism, while "meaning" is the
residual choice of representatives that the isomorphism is free to move.
-/

namespace IsomorphismsOfMeaning

open Equiv Equiv.Perm

variable {α β γ : Type*}

/-! ## §1. The isomorphism of isomorphisms is functorial -/

/-
!-- Lab Notes: permCongrHom_comp -- !--
!-- Hypothesis: Relabeling self-symmetries is functorial: relabeling first by `e`
and then by `e'` equals relabeling by the composite `e.trans e'`. -- !--
!-- Experiment: `ext` on a point and unfold `permCongr_apply`; both sides send `x`
to `e' (e (f (e.symm (e'.symm x))))`. -- !--
!-- Analysis: This is the statement that `e ↦ permCongrHom e` is a functor from the
groupoid of sets-and-bijections to the category of groups; the "isomorphism of
isomorphisms" is natural in `e`. -- !--
!-- Critique: Not vacuous — it equates two a priori different group isomorphisms and
is used implicitly whenever invariants are transported. -- !--
!-- End Lab Notes -- !--
-/
theorem permCongrHom_comp (e : α ≃ β) (e' : β ≃ γ) (f : Perm α) :
    (e.trans e').permCongrHom f = e'.permCongrHom (e.permCongrHom f) := by
  ext x
  simp [Equiv.permCongr_apply]

/-! ## §2. Truth is preserved: relabeling-invariant quantities -/

/-
!-- Lab Notes: orderOf_permCongr -- !--
!-- Hypothesis: The order of a symmetry is a truth: it survives relabeling. -- !--
!-- Experiment: `permCongrHom e` is a group isomorphism, hence injective, and
`orderOf` is invariant under injective monoid homomorphisms. -- !--
!-- Analysis: This is the prototypical "truth": a purely group-theoretic quantity,
blind to the names of the points. -- !--
!-- End Lab Notes -- !--
-/
theorem orderOf_permCongr (e : α ≃ β) (f : Perm α) :
    orderOf (e.permCongrHom f) = orderOf f :=
  orderOf_injective e.permCongrHom.toMonoidHom e.permCongrHom.injective f

/-- Parity is a truth: relabeling preserves the sign of a permutation. -/
theorem sign_permCongr' [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (e : α ≃ β) (f : Perm α) : Perm.sign (e.permCongr f) = Perm.sign f :=
  sign_permCongr e f

/-
!-- Lab Notes: support_permCongr / card_support_permCongr -- !--
!-- Hypothesis: The *set* of disturbed points is relabeled along `e`
(`support (permCongr e f) = e '' support f`), so its *size* is a truth. -- !--
!-- Experiment: membership chase using `permCongr_apply` and injectivity of `e`,
then `Finset.card_map`. -- !--
!-- Analysis: The support illustrates the truth/meaning split in one object: its
*cardinality* is invariant (truth) while its *elements* move with `e` (meaning). -- !--
!-- End Lab Notes -- !--
-/
theorem support_permCongr [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (e : α ≃ β) (f : Perm α) :
    (e.permCongr f).support = f.support.map e.toEmbedding := by
  ext x
  simp only [Equiv.Perm.mem_support, Equiv.permCongr_apply, Finset.mem_map,
    Equiv.coe_toEmbedding]
  constructor
  · intro h
    refine ⟨e.symm x, ?_, by simp⟩
    intro hc
    apply h
    rw [hc]; simp
  · rintro ⟨a, ha, rfl⟩
    simp only [Equiv.symm_apply_apply]
    intro hc
    exact ha (e.injective hc)

theorem card_support_permCongr [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (e : α ≃ β) (f : Perm α) : (e.permCongr f).support.card = f.support.card := by
  rw [support_permCongr, Finset.card_map]

/-! ## §3. Meaning is not preserved: a collision on three points -/

/-
!-- Lab Notes: conj_preserves_cycleType -- !--
!-- Hypothesis: Cycle type is the complete relabeling-invariant of a finite
permutation; conjugate permutations share it. -- !--
!-- Experiment: direct from `isConj_iff_cycleType_eq`. -- !--
!-- Analysis: Cycle type is "all the truth there is" about a permutation up to
relabeling — the maximal isomorphism-invariant. -- !--
!-- End Lab Notes -- !--
-/
theorem conj_preserves_cycleType [Fintype α] [DecidableEq α] {f g : Perm α}
    (h : IsConj f g) : f.cycleType = g.cycleType :=
  isConj_iff_cycleType_eq.mp h

/-
!-- Lab Notes: invariants_agree_meaning_differs -- !--
!-- Hypothesis: On a three-point set there exist two symmetries with identical
cycle type, order, and sign that nevertheless disturb different points. -- !--
!-- Experiment: take the transpositions `(0 1)` and `(1 2)` in `Perm (Fin 3)`;
cycle-type equality follows from conjugacy, the remaining invariants and the
support inequality are decidable. -- !--
!-- Analysis: This is the sharp "structures collide" phenomenon: NO invariant of
the abstract symmetry group separates the two elements, yet their meaning — which
points they move — differs. Truth is silent; only the labels speak. -- !--
!-- Critique: Genuinely non-trivial: it simultaneously asserts agreement on three
invariants AND concrete disagreement, so neither side is vacuous. -- !--
!-- End Lab Notes -- !--
-/
theorem invariants_agree_meaning_differs :
    ∃ f g : Perm (Fin 3),
      f.cycleType = g.cycleType ∧ orderOf f = orderOf g ∧
        Perm.sign f = Perm.sign g ∧ f ≠ g ∧ f.support ≠ g.support := by
  refine ⟨swap 0 1, swap 1 2, ?_, ?_, ?_, ?_, ?_⟩
  · exact conj_preserves_cycleType (isConj_iff_cycleType_eq.mpr (by decide))
  · have h1 : orderOf (swap (0 : Fin 3) 1) = 2 := orderOf_eq_prime (by decide) (by decide)
    have h2 : orderOf (swap (1 : Fin 3) 2) = 2 := orderOf_eq_prime (by decide) (by decide)
    rw [h1, h2]
  · decide
  · decide
  · decide

/-! ## §4. Bridge: colliding meaning-morphisms of the divisibility monoid

These results build directly on the strong-divisibility theory of
`Catalog/Applications/Pythagorean/StrongDivisibilitySequences.lean`. -/

open StrongDivSeq

/-
!-- Lab Notes: meaning_morphisms_collide -- !--
!-- Hypothesis: The Fibonacci sequence and the Mersenne sequence `2ⁿ − 1` obey the
same structural law of the divisibility monoid yet are different functions. -- !--
!-- Experiment: reuse the catalog instances `fib_isStrongDivSeq` and
`mersenne_isStrongDivSeq 2`; separate them at `n = 3`, where `fib 3 = 2 ≠ 7`. -- !--
!-- Analysis: The arithmetic analogue of §3 — identical structure-preservation,
different meaning (values). -- !--
!-- End Lab Notes -- !--
-/
theorem meaning_morphisms_collide :
    IsStrongDivSeq Nat.fib ∧ IsStrongDivSeq (fun n => 2 ^ n - 1) ∧
      Nat.fib ≠ (fun n => 2 ^ n - 1) := by
  refine ⟨fib_isStrongDivSeq, mersenne_isStrongDivSeq 2, ?_⟩
  intro h
  have := congrFun h 3
  norm_num [Nat.fib] at this

/-
!-- Lab Notes: shared_divisibility_law -- !--
!-- Hypothesis: Because both sequences preserve the divisibility structure, both
inherit the same divisibility implication `m ∣ n → u m ∣ u n`. -- !--
!-- Experiment: apply the catalog lemma `IsStrongDivSeq.dvd_of_dvd` to each
instance. -- !--
!-- Analysis: A single structural truth ("preserves gcd") forces a shared
observable consequence in two different arithmetic worlds. -- !--
!-- End Lab Notes -- !--
-/
theorem shared_divisibility_law {m n : ℕ} (h : m ∣ n) :
    Nat.fib m ∣ Nat.fib n ∧ (2 ^ m - 1) ∣ (2 ^ n - 1) :=
  ⟨fib_isStrongDivSeq.dvd_of_dvd h, (mersenne_isStrongDivSeq 2).dvd_of_dvd h⟩

/-
!-- Lab Notes: Synthesis -- !--
The two registers (§1–§3 group-theoretic, §4 arithmetic) share one mechanism.
"Truth" is the image of an object under all admissible isomorphisms — its orbit
invariants (order, sign, support size, cycle type; the gcd-preservation law).
"Meaning" is the residual choice of representative within an orbit — which points a
permutation moves, which numerical values a divisibility-morphism takes.  An
isomorphism of isomorphisms transports every truth faithfully while remaining free
to permute meaning; hence isomorphic structures can, and generically do, carry
different meanings that no invariant of the structure can detect.
!-- End Lab Notes -- !--
-/

end IsomorphismsOfMeaning