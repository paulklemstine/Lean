/-
# Block counts and the classification of tuples over a small alphabet

`Algebra.KernelPatterns.Bell` classifies the orbits of `Equiv.Perm α` on `n`-tuples
over `α` under the assumption `n ≤ |α|`, where every pattern is realised.  Over a
*small* alphabet only the patterns with at most `|α|` blocks occur.  This file
introduces the block count of a pattern and removes the hypothesis `n ≤ |α|`:

* `KernelPattern.numBlocks_patternOf` — the block count of the pattern of a tuple is
  the number of distinct values of the tuple;
* `KernelPattern.exists_tuple_iff_numBlocks_le` — a pattern is realised over `α`
  exactly when its block count is at most `|α|`;
* `KernelPattern.card_orbits_eq_card_patterns_le` — the number of `Equiv.Perm α`-orbits
  on `n`-tuples equals the number of patterns with at most `|α|` blocks, for *every*
  finite alphabet.
-/
import Algebra.KernelPatterns.Core
import Algebra.KernelPatterns.Bell

namespace KernelPattern

open Finset

variable {α : Type*} {n : ℕ}

/-- The number of blocks of a pattern: the size of its image (equivalently, its number
of fixed points). -/
def numBlocks (p : Pattern n) : ℕ := (Finset.image p.1 Finset.univ).card

/-- The canonical form has as many distinct values as the tuple itself. -/
theorem card_image_canon [DecidableEq α] (x : Fin n → α) :
    (Finset.image (canon x) Finset.univ).card = (Finset.image x Finset.univ).card := by
  refine Finset.card_bij (fun j _ => x j) ?_ ?_ ?_
  · intro j _
    exact Finset.mem_image.2 ⟨j, Finset.mem_univ _, rfl⟩
  · intro j hj k hk hjk
    obtain ⟨i, -, hi⟩ := Finset.mem_image.mp hj
    obtain ⟨i', -, hi'⟩ := Finset.mem_image.mp hk
    have hj' : canon x j = j := by rw [← hi]; exact canon_idem x i
    have hk' : canon x k = k := by rw [← hi']; exact canon_idem x i'
    calc j = canon x j := hj'.symm
    _ = canon x k := (canon_eq_iff x j k).2 hjk
    _ = k := hk'
  · intro a ha
    obtain ⟨i, -, hi⟩ := Finset.mem_image.mp ha
    refine ⟨canon x i, Finset.mem_image.2 ⟨i, Finset.mem_univ _, rfl⟩, ?_⟩
    show x (canon x i) = a
    rw [apply_canon x i, hi]

/-- The block count of the pattern of a tuple is the number of distinct entries. -/
theorem numBlocks_patternOf [DecidableEq α] (x : Fin n → α) :
    numBlocks (patternOf x) = (Finset.image x Finset.univ).card :=
  card_image_canon x

theorem numBlocks_le_card [DecidableEq α] [Fintype α] (x : Fin n → α) :
    numBlocks (patternOf x) ≤ Fintype.card α := by
  rw [numBlocks_patternOf]
  exact Finset.card_le_univ _

/-- **Realisability**: a pattern is the pattern of a tuple over `α` exactly when it has
at most `|α|` blocks. -/
theorem exists_tuple_iff_numBlocks_le [DecidableEq α] [Finite α] (p : Pattern n) :
    (∃ x : Fin n → α, patternOf x = p) ↔ numBlocks p ≤ Nat.card α := by
  have _inst : Fintype α := Fintype.ofFinite α
  constructor
  · rintro ⟨x, rfl⟩
    rw [Nat.card_eq_fintype_card]
    exact numBlocks_le_card x
  · intro hle
    obtain ⟨e⟩ : Nonempty ((Finset.image p.1 Finset.univ : Finset (Fin n)) ↪ α) := by
      apply Function.Embedding.nonempty_of_card_le
      rw [Fintype.card_coe]
      rw [Nat.card_eq_fintype_card] at hle
      exact hle
    have hmem : ∀ i : Fin n, p.1 i ∈ Finset.image p.1 Finset.univ :=
      fun i => Finset.mem_image.2 ⟨i, Finset.mem_univ _, rfl⟩
    refine ⟨fun i => e ⟨p.1 i, hmem i⟩, ?_⟩
    apply Subtype.ext
    have hsame : SameKernel (fun i => e ⟨p.1 i, hmem i⟩) p.1 := by
      intro i j
      constructor
      · intro h
        have := e.injective h
        exact congrArg Subtype.val this
      · intro h
        exact congrArg e (Subtype.ext h)
    rw [patternOf_val, sameKernel_iff_canon_eq.1 hsame, canon_eq_self_of_isPattern p.2]

/-- The orbit invariant, valued in the patterns with at most `|α|` blocks. -/
noncomputable def orbitPatternLe [DecidableEq α] [Finite α] :
    Quotient (permSetoid α n) → {p : Pattern n // numBlocks p ≤ Nat.card α} := by
  refine fun X => ⟨orbitPattern X, ?_⟩
  induction X using Quotient.inductionOn with
  | _ x =>
    exact (exists_tuple_iff_numBlocks_le (patternOf x)).1 ⟨x, rfl⟩

theorem orbitPatternLe_val [DecidableEq α] [Finite α] (X : Quotient (permSetoid α n)) :
    (orbitPatternLe X).1 = orbitPattern X := rfl

theorem orbitPatternLe_bijective [DecidableEq α] [Finite α] :
    Function.Bijective (orbitPatternLe (α := α) (n := n)) := by
  constructor
  · intro X Y h
    exact orbitPattern_injective (by
      rw [← orbitPatternLe_val, ← orbitPatternLe_val, h])
  · rintro ⟨p, hp⟩
    obtain ⟨x, hx⟩ := (exists_tuple_iff_numBlocks_le p).2 hp
    exact ⟨Quotient.mk (permSetoid α n) x, Subtype.ext (by rw [orbitPatternLe_val,
      orbitPattern_mk, hx])⟩

/-- **Classification over an arbitrary finite alphabet**: the orbits of `Equiv.Perm α`
on `n`-tuples over `α` are in bijection with the patterns having at most `|α|` blocks;
no relation between `n` and `|α|` is assumed. -/
theorem card_orbits_eq_card_patterns_le (α : Type*) [DecidableEq α] [Finite α] (n : ℕ) :
    Nat.card (Quotient (permSetoid α n))
      = Fintype.card {p : Pattern n // numBlocks p ≤ Nat.card α} := by
  rw [Nat.card_congr (Equiv.ofBijective _ (orbitPatternLe_bijective (α := α) (n := n))),
    Nat.card_eq_fintype_card]

/-! ## Small cases, by `decide`

For `n` larger than `|α|` the orbit count drops below the Bell number: over a binary
alphabet the `3`-tuples fall into `4` orbits instead of `Nat.bell 3 = 5`, the missing
pattern being the one with three distinct entries. -/

theorem card_patterns_three_le_two :
    Fintype.card {p : Pattern 3 // numBlocks p ≤ 2} = 4 := by decide

theorem orbits_binary_three : Nat.card (Quotient (permSetoid (Fin 2) 3)) = 4 := by
  rw [card_orbits_eq_card_patterns_le (Fin 2) 3]
  simpa using card_patterns_three_le_two

theorem orbits_binary_three_lt_bell :
    Nat.card (Quotient (permSetoid (Fin 2) 3)) < Nat.bell 3 := by
  rw [orbits_binary_three]
  have : Nat.bell 3 = 5 := by
    have := bell_values
    simpa using congrArg (fun t => t.2.2.2.1) this
  omega

end KernelPattern