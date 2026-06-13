/-
# Dream Spaces: Finite-Intersection Structures that Fail to be Topologies

A **dream space** on a type `X` is a collection of "opens" containing `∅` and `X` and
closed under *finite* intersection — but **not** required to be closed under arbitrary
unions. It is the natural home for "dream-like" reasoning: locally coherent (closed under
finite conjunction of conditions) yet globally able to fail the union axiom of a topology.

A dream space is **topological** exactly when it *is* a topology, i.e. closed under
arbitrary unions. The main result is that the canonical *finite-or-univ* dream space on `ℕ`
is genuinely non-topological: the set of even numbers is a union of (open) singletons but
is itself not open.

## Main results
* `DreamSpace` — the structure (`∅`, `univ`, closed under binary `∩`).
* `dreamNat` — the finite-or-univ dream space on `ℕ`.
* `evens_not_dreamOpen` — `{n | Even n}` is not `dreamNat`-open.
* `dreamNat_not_topological` — `dreamNat` is not closed under arbitrary unions.

-- !-- Lab Notebook -- !--
Hypothesis: The collection of finite-or-cofinite... no: finite-or-univ subsets of `ℕ` is
  closed under finite intersection (so a dream space) but not under arbitrary unions, hence
  strictly weaker than a topology.
Result: `dreamNat` is a lawful `DreamSpace`; `evens_not_dreamOpen` shows the evens are not
  open (infinite and not all of `ℕ`); `dreamNat_not_topological` exhibits the evens as a
  union of open singletons, refuting the union axiom.
Insight: The single counterexample (evens = ⋃ of even singletons) simultaneously witnesses
  both "infinite, non-universal set" and "union of opens", so non-openness *is*
  non-topologicality. The finite-intersection axiom never controls unbounded unions.
Failure analysis: Proving `{n | Even n}` infinite via `Set.Infinite` directly is awkward;
  routing through `Set.infinite_of_not_bddAbove` with the witness `2*(b+1)` is robust. The
  other branch (`evens = univ`) is killed by exhibiting the odd element `1`.
-/

import Mathlib

open Set

namespace DreamLogic

/-- A **dream space** on `X`: a family of "opens" containing `∅` and the whole space and
closed under binary intersection. Unlike a topology, *no* arbitrary-union axiom is imposed,
modelling locally-coherent ("dream-like") reasoning that may fail global closure. -/
structure DreamSpace (X : Type*) where
  /-- The designated open sets. -/
  opens : Set (Set X)
  /-- The empty set is open. -/
  empty_mem : (∅ : Set X) ∈ opens
  /-- The whole space is open. -/
  univ_mem : (Set.univ : Set X) ∈ opens
  /-- Opens are closed under binary intersection. -/
  inter_mem : ∀ s t, s ∈ opens → t ∈ opens → s ∩ t ∈ opens

namespace DreamSpace

/-- A dream space is **topological** when it is, in fact, a topology: its opens are closed
under arbitrary unions. -/
def IsTopological {X : Type*} (D : DreamSpace X) : Prop :=
  ∀ F : Set (Set X), (∀ s ∈ F, s ∈ D.opens) → ⋃₀ F ∈ D.opens

end DreamSpace

/-- The **finite-or-univ dream space** on `ℕ`: a set is open iff it is finite or all of `ℕ`.
This is closed under finite intersection but, as shown below, not under arbitrary unions. -/
def dreamNat : DreamSpace ℕ where
  opens := {s | s.Finite ∨ s = Set.univ}
  empty_mem := Or.inl Set.finite_empty
  univ_mem := Or.inr rfl
  inter_mem := by
    rintro s t (hs | hs) (ht | ht)
    · exact Or.inl (hs.inter_of_left t)
    · subst ht; exact Or.inl (by simpa using hs)
    · subst hs; exact Or.inl (by simpa using ht)
    · subst hs; subst ht; exact Or.inr (by simp)

/-- The set of even naturals is infinite. -/
theorem evens_infinite : {n : ℕ | Even n}.Infinite := by
  apply Set.infinite_of_not_bddAbove
  rintro ⟨b, hb⟩
  have := hb (a := 2 * (b + 1)) ⟨b + 1, by ring⟩
  omega

-- !-- The evens are infinite (so not finite) and miss `1` (so not `univ`); both
-- disjuncts of `dreamNat.opens` fail. -- !--
/-- **The even numbers are not `dreamNat`-open.** -/
theorem evens_not_dreamOpen : {n : ℕ | Even n} ∉ dreamNat.opens := by
  rintro (h | h)
  · exact evens_infinite h
  · have : (1 : ℕ) ∈ {n : ℕ | Even n} := by rw [h]; trivial
    simp [Nat.even_iff] at this

-- !-- The evens equal the union of the open singletons `{n}` (`n` even), yet are not open
-- — directly refuting closure under arbitrary unions. -- !--
/-- **`dreamNat` is not topological.** The evens are a union of open singletons but are
themselves not open, so the finite-or-univ dream space violates the union axiom. -/
theorem dreamNat_not_topological : ¬ dreamNat.IsTopological := by
  intro h
  apply evens_not_dreamOpen
  have hunion : ⋃₀ ((fun n => {n}) '' {n : ℕ | Even n}) = {n : ℕ | Even n} := by
    ext x; simp
  rw [← hunion]
  apply h
  rintro s ⟨n, _, rfl⟩
  exact Or.inl (Set.finite_singleton n)

end DreamLogic