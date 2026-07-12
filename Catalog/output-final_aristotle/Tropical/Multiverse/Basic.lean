/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Set-Theoretic Multiverse (Hamkins), abstractly

This file gives an *abstract, model-agnostic* formalization of Joel David Hamkins'
**set-theoretic multiverse** view. Rather than building actual models of ZFC (which is
far beyond a self-contained development), we axiomatize exactly the data the multiverse
picture needs: a collection of *universes* (models), a type of *statements*, and a truth
relation `holds u s` ("statement `s` holds in universe `u`").

On top of this we define the central notion of **multiverse truth**:

* `MultiverseTrue M s` — `s` holds in *every* universe (the analogue of `∀`);
* `MultiverseFalse M s` — `s` fails in *every* universe;
* `PossiblyTrue M s` — `s` holds in *some* universe (the analogue of `∃`);
* `Independent M s` — `s` holds somewhere and fails somewhere;
* `Undetermined M s` — `s` is neither multiverse-true nor multiverse-false.

The main structural theorem is `independent_iff_undetermined`: a statement is independent
across the multiverse **iff** it has no multiverse truth value. This is the precise sense
in which, for a genuinely independent statement, "the question is meaningless without
specifying which universe."

These abstract results are instantiated on a concrete multiverse (with CH, V=L, and a
large-cardinal statement) in `Concrete.lean`, connected to forcing in `Forcing.lean`, and
bridged to tropical algebra in `TropicalBridge.lean`.
-/

namespace MultiverseSet

/-- A **set-theoretic multiverse**: a nonempty collection of universes (models), a type of
statements, and a truth relation. This is the abstract skeleton of Hamkins' multiverse. -/
structure Multiverse where
  /-- The universes (models of set theory) making up the multiverse. -/
  Universe : Type
  /-- The statements whose truth may vary across universes. -/
  Statement : Type
  /-- `holds u s` means statement `s` is true in universe `u`. -/
  holds : Universe → Statement → Prop
  /-- The multiverse is nonempty. -/
  nonempty : Nonempty Universe

variable {M : Multiverse}

/-- `s` is **multiverse-true** if it holds in every universe. -/
def MultiverseTrue (M : Multiverse) (s : M.Statement) : Prop := ∀ u, M.holds u s

/-- `s` is **multiverse-false** if it fails in every universe. -/
def MultiverseFalse (M : Multiverse) (s : M.Statement) : Prop := ∀ u, ¬ M.holds u s

/-- `s` is **possibly true** if it holds in some universe. -/
def PossiblyTrue (M : Multiverse) (s : M.Statement) : Prop := ∃ u, M.holds u s

/-- `s` is **independent** across the multiverse if it holds somewhere and fails somewhere. -/
def Independent (M : Multiverse) (s : M.Statement) : Prop :=
  (∃ u, M.holds u s) ∧ (∃ u, ¬ M.holds u s)

/-- `s` is **undetermined** if it is neither multiverse-true nor multiverse-false, i.e. it has
no multiverse truth value. -/
def Undetermined (M : Multiverse) (s : M.Statement) : Prop :=
  ¬ MultiverseTrue M s ∧ ¬ MultiverseFalse M s

/-- A multiverse-true statement is (given nonemptiness) possibly true. -/
theorem possiblyTrue_of_multiverseTrue {s : M.Statement} (h : MultiverseTrue M s) :
    PossiblyTrue M s := by
  obtain ⟨u⟩ := M.nonempty
  exact ⟨u, h u⟩

/-- An independent statement is not multiverse-true. -/
theorem not_multiverseTrue_of_independent {s : M.Statement} (h : Independent M s) :
    ¬ MultiverseTrue M s := by
  obtain ⟨_, ⟨u, hu⟩⟩ := h
  intro hall
  exact hu (hall u)

/-- An independent statement is not multiverse-false. -/
theorem not_multiverseFalse_of_independent {s : M.Statement} (h : Independent M s) :
    ¬ MultiverseFalse M s := by
  obtain ⟨⟨u, hu⟩, _⟩ := h
  intro hall
  exact hall u hu

/-- **Independence is exactly undeterminedness.** A statement is independent across the
multiverse iff it has no multiverse truth value. This is the formal counterpart of the
slogan: for a genuinely independent statement the question of its truth is meaningless
without first specifying a universe. -/
theorem independent_iff_undetermined {s : M.Statement} :
    Independent M s ↔ Undetermined M s := by
  unfold Independent Undetermined MultiverseTrue MultiverseFalse
  constructor
  · rintro ⟨⟨u, hu⟩, ⟨v, hv⟩⟩
    refine ⟨?_, ?_⟩
    · intro hall; exact hv (hall v)
    · intro hall; exact hall u hu
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_⟩
    · by_contra h
      exact h2 (fun u hu => h ⟨u, hu⟩)
    · by_contra h
      exact h1 (fun u => not_not.mp (fun hu => h ⟨u, hu⟩))

/-- Multiverse truth is preserved by (pointwise) conjunction of statements. -/
theorem multiverseTrue_and {s t : M.Statement}
    (hs : MultiverseTrue M s) (ht : MultiverseTrue M t) :
    ∀ u, M.holds u s ∧ M.holds u t := fun u => ⟨hs u, ht u⟩

/-- A multiverse-true statement admits no counterexample universe. -/
theorem no_counterexample_of_multiverseTrue {s : M.Statement} (h : MultiverseTrue M s) :
    ¬ ∃ u, ¬ M.holds u s := by
  rintro ⟨u, hu⟩; exact hu (h u)

/-- No statement is simultaneously multiverse-true and multiverse-false (nonemptiness). -/
theorem not_multiverseTrue_and_multiverseFalse {s : M.Statement} :
    ¬ (MultiverseTrue M s ∧ MultiverseFalse M s) := by
  rintro ⟨ht, hf⟩
  obtain ⟨u⟩ := M.nonempty
  exact hf u (ht u)

/-- Truth relativized to a *sub-multiverse* carved out by a predicate `P` on universes. -/
def MultiverseTrueOn (M : Multiverse) (P : M.Universe → Prop) (s : M.Statement) : Prop :=
  ∀ u, P u → M.holds u s

/-- Multiverse truth on a smaller sub-collection follows from truth on a larger one. -/
theorem multiverseTrueOn_mono {P Q : M.Universe → Prop} {s : M.Statement}
    (hPQ : ∀ u, Q u → P u) (h : MultiverseTrueOn M P s) : MultiverseTrueOn M Q s :=
  fun u hu => h u (hPQ u hu)

/-- Multiverse truth is truth on the full sub-collection. -/
theorem multiverseTrue_iff_trueOn_univ {s : M.Statement} :
    MultiverseTrue M s ↔ MultiverseTrueOn M (fun _ => True) s := by
  constructor
  · intro h u _; exact h u
  · intro h u; exact h u trivial

end MultiverseSet