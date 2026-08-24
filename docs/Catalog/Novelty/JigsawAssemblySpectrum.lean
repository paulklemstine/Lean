import Mathlib
import Novelty.JigsawComplementOrbitStructure

/-!
# Realizability: which assembly spaces and which combined counts occur

Cycles one and two proved that global tab--blank complementation acts freely on
the untagged combined assembly space of a framed puzzle on `n ≥ 1` variables and
decomposed that space into free orbits indexed by a polarity gauge.  Both are
*constraints*.  This cycle proves that the parity constraint is the **only**
one, by showing the constraint side is completely expressive.

## Contents

* **Complete expressiveness.**  `assemblySet_puzzleOfSet`: every subset `S` of
  the Boolean cube is the exact assembly space of a framed puzzle, namely the
  puzzle with one clause piece excluding each non-assembly.  Framed puzzles thus
  realise *all* Boolean constraint systems; the assembly-space map from framed
  puzzles onto subsets of the cube is surjective
  (`assemblySet_surjective`).  The realising puzzle uses `2^n - |S|` clause
  pieces (`puzzleOfSet_length`).

* **Assembly spectrum.**  `assembly_spectrum`: for every `k ≤ 2^n` some framed
  puzzle on `n` variables has exactly `k` assemblies.  In particular assembly
  counts of a *single* puzzle are unconstrained — odd counts occur — so the
  parity phenomenon is genuinely a property of the complement-stable union.

* **Combined spectrum, exactly.**  `combined_spectrum` together with
  `JigsawFreeComplement.union_card_even` characterises the possible combined
  counts on `n ≥ 1` variables: they are precisely the even numbers `≤ 2^n`
  (`combined_spectrum_iff`).  This is the sharp boundary the mission asked for:
  freeness forces evenness, expressiveness forces nothing else.

* **Realising every self-dual puzzle.**  `selfDual_spectrum`: every even count
  `≤ 2^n` is also the assembly count of a puzzle whose assembly space is
  complement-stable, so self-dual configurations exist in every admissible size
  and are never fixed points.
-/

open Function

namespace JigsawFreeComplement

open Jigsaw

variable {n : ℕ}

/-! ## Part 1 — A clause piece that excludes exactly one assembly -/

/-- The clause piece that forbids exactly the assembly `b`: it exposes, for each
variable, the input edge milled for the *opposite* of `b`'s choice, so it snaps
into place under `a` iff `a` differs from `b` somewhere. -/
def excludeClause (b : Fin n → Bool) : FClause n :=
  (List.finRange n).map fun i => (i, !b i)

/-- The excluding clause piece fits exactly the assemblies different from `b`. -/
theorem excludeClause_fits (a b : Fin n → Bool) :
    (∃ l ∈ excludeClause b, framedLitFits a l) ↔ a ≠ b := by
  constructor
  · rintro ⟨l, hl, hfit⟩
    simp only [excludeClause, List.mem_map] at hl
    obtain ⟨i, _, rfl⟩ := hl
    have h : a i = !b i := (framedLitFits_iff a (i, !b i)).1 hfit
    intro hab
    rw [hab] at h
    simp at h
  · intro hab
    have : ∃ i, a i ≠ b i := by
      by_contra hcon
      push_neg at hcon
      exact hab (funext hcon)
    obtain ⟨i, hi⟩ := this
    refine ⟨(i, !b i), ?_, ?_⟩
    · simp only [excludeClause, List.mem_map]
      exact ⟨i, List.mem_finRange i, rfl⟩
    · rw [framedLitFits_iff]
      cases hb : b i <;> cases ha : a i <;> simp_all

/-- The framed puzzle whose clause pieces exclude exactly the assemblies listed
in `L`.  This computable form drives the numerical experiments below. -/
def puzzleOfList (L : List (Fin n → Bool)) : FPuzzle n := L.map excludeClause

/-- Its assembly space is the complement of the excluded list. -/
theorem assemblySet_puzzleOfList (L : List (Fin n → Bool)) :
    assemblySet (puzzleOfList L) = Finset.univ.filter fun a => a ∉ L := by
  ext a
  rw [mem_assemblySet, Finset.mem_filter]
  constructor
  · intro ha
    refine ⟨Finset.mem_univ _, ?_⟩
    intro hmem
    exact (excludeClause_fits a a).1 (ha _ (List.mem_map_of_mem hmem)) rfl
  · rintro ⟨-, ha⟩ c hc
    simp only [puzzleOfList, List.mem_map] at hc
    obtain ⟨b, hb, rfl⟩ := hc
    refine (excludeClause_fits a b).2 ?_
    rintro rfl
    exact ha hb

/-! ## Part 2 — Every subset of the cube is an assembly space -/

/-- The framed puzzle realising a prescribed assembly space: one excluding clause
piece for each point of the cube that must *not* assemble. -/
noncomputable def puzzleOfSet (S : Finset (Fin n → Bool)) : FPuzzle n :=
  (Finset.univ \ S).toList.map excludeClause

/-- **Complete expressiveness.**  Every subset of the Boolean cube is exactly the
assembly space of a framed puzzle. -/
theorem assemblySet_puzzleOfSet (S : Finset (Fin n → Bool)) :
    assemblySet (puzzleOfSet S) = S := by
  ext a
  rw [mem_assemblySet]
  constructor
  · intro ha
    by_contra hS
    have hb : a ∈ Finset.univ \ S := by simp [hS]
    have hmem : excludeClause a ∈ puzzleOfSet S :=
      List.mem_map_of_mem (Finset.mem_toList.2 hb)
    exact (excludeClause_fits a a).1 (ha _ hmem) rfl
  · intro ha c hc
    simp only [puzzleOfSet, List.mem_map, Finset.mem_toList] at hc
    obtain ⟨b, hb, rfl⟩ := hc
    refine (excludeClause_fits a b).2 ?_
    rintro rfl
    simp [ha] at hb

/-- The assembly-space map is surjective onto subsets of the cube. -/
theorem assemblySet_surjective (S : Finset (Fin n → Bool)) :
    ∃ P : FPuzzle n, assemblySet P = S :=
  ⟨puzzleOfSet S, assemblySet_puzzleOfSet S⟩

/-- The realising puzzle has one clause piece per excluded assembly. -/
theorem puzzleOfSet_length (S : Finset (Fin n → Bool)) :
    (puzzleOfSet S).length = 2 ^ n - S.card := by
  simp [puzzleOfSet, Finset.length_toList, Finset.card_sdiff, Finset.card_univ]

/-! ## Part 3 — The spectrum of assembly counts -/

/-- **Assembly spectrum.**  Every count `k ≤ 2^n` is realised by a framed puzzle
on `n` variables.  Single-puzzle assembly counts are therefore completely
unconstrained; in particular they are frequently odd. -/
theorem assembly_spectrum (k : ℕ) (hk : k ≤ 2 ^ n) :
    ∃ P : FPuzzle n, (assemblySet P).card = k := by
  have hcard : (Finset.univ : Finset (Fin n → Bool)).card = 2 ^ n := by
    simp [Finset.card_univ]
  obtain ⟨S, _, hS⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset (Fin n → Bool)))
    (by omega : k ≤ (Finset.univ : Finset (Fin n → Bool)).card)
  exact ⟨puzzleOfSet S, by rw [assemblySet_puzzleOfSet, hS]⟩

/-- A complement-stable subset of the cube of any prescribed even size exists:
take `k` gauge points and adjoin their complements. -/
theorem exists_stable_set (hn : 0 < n) (k : ℕ) (hk : 2 * k ≤ 2 ^ n) :
    ∃ S : Finset (Fin n → Bool), (∀ a ∈ S, compAssign a ∈ S) ∧ S.card = 2 * k := by
  have hgauge : (polarityGauge hn (Finset.univ : Finset (Fin n → Bool))).card = 2 ^ n / 2 :=
    gauge_univ_card hn
  obtain ⟨T, hTsub, hT⟩ :=
    Finset.exists_subset_card_eq (s := polarityGauge hn (Finset.univ : Finset (Fin n → Bool)))
      (by omega : k ≤ (polarityGauge hn (Finset.univ : Finset (Fin n → Bool))).card)
  refine ⟨T ∪ T.image compAssign, ?_, ?_⟩
  · intro a ha
    simp only [Finset.mem_union, Finset.mem_image] at ha ⊢
    rcases ha with h | ⟨b, hb, rfl⟩
    · exact Or.inr ⟨a, h, rfl⟩
    · exact Or.inl (by rwa [compAssign_involutive b])
  · have hdisj : Disjoint T (T.image compAssign) := by
      rw [Finset.disjoint_right]
      rintro a ha hT'
      simp only [Finset.mem_image] at ha
      obtain ⟨b, hb, rfl⟩ := ha
      have hb0 : b ⟨0, hn⟩ = true := (Finset.mem_filter.1 (hTsub hb)).2
      have := (Finset.mem_filter.1 (hTsub hT')).2
      simp [compAssign, hb0] at this
    rw [Finset.card_union_of_disjoint hdisj,
      Finset.card_image_of_injective _ compAssign_involutive.injective, hT]
    ring

/-- **Combined spectrum.**  On `n ≥ 1` variables every even number `2k ≤ 2^n` is
the combined assembly count of some framed puzzle. -/
theorem combined_spectrum (hn : 0 < n) (k : ℕ) (hk : 2 * k ≤ 2 ^ n) :
    ∃ P : FPuzzle n, (combinedAssemblySet P).card = 2 * k := by
  obtain ⟨S, hstable, hcard⟩ := exists_stable_set hn k hk
  refine ⟨puzzleOfSet S, ?_⟩
  have hS : assemblySet (puzzleOfSet S) = S := assemblySet_puzzleOfSet S
  have hcomp : assemblySet (compPuzzle (puzzleOfSet S)) = S := by
    rw [assemblySet_compPuzzle, hS]
    apply Finset.Subset.antisymm
    · intro a ha
      simp only [Finset.mem_image] at ha
      obtain ⟨b, hb, rfl⟩ := ha
      exact hstable b hb
    · intro a ha
      simp only [Finset.mem_image]
      exact ⟨compAssign a, hstable a ha, compAssign_involutive a⟩
  rw [combinedAssemblySet, hS, hcomp, Finset.union_self, hcard]

/-- **Exact characterisation of combined counts.**  On at least one variable, a
number is the combined assembly count of a framed puzzle if and only if it is
even and at most `2^n`.  Freeness of complementation supplies the "only if";
complete expressiveness supplies the "if". -/
theorem combined_spectrum_iff (hn : 0 < n) (m : ℕ) :
    (∃ P : FPuzzle n, (combinedAssemblySet P).card = m) ↔ (Even m ∧ m ≤ 2 ^ n) := by
  constructor
  · rintro ⟨P, rfl⟩
    refine ⟨union_card_even hn P, ?_⟩
    have h : (combinedAssemblySet P).card ≤ (Finset.univ : Finset (Fin n → Bool)).card :=
      Finset.card_le_card (Finset.subset_univ _)
    simpa [Finset.card_univ] using h
  · rintro ⟨⟨k, rfl⟩, hle⟩
    obtain ⟨P, hP⟩ := combined_spectrum hn k (by omega)
    exact ⟨P, by omega⟩

/-- **Self-dual puzzles of every admissible size.**  For each even `2k ≤ 2^n`
there is a framed puzzle on `n ≥ 1` variables whose assembly space is
complement-stable and has `2k` elements, so self-duality never produces a fixed
configuration. -/
theorem selfDual_spectrum (hn : 0 < n) (k : ℕ) (hk : 2 * k ≤ 2 ^ n) :
    ∃ P : FPuzzle n, assemblySet (compPuzzle P) = assemblySet P ∧
      (assemblySet P).card = 2 * k := by
  obtain ⟨S, hstable, hcard⟩ := exists_stable_set hn k hk
  refine ⟨puzzleOfSet S, ?_, by rw [assemblySet_puzzleOfSet, hcard]⟩
  rw [assemblySet_compPuzzle, assemblySet_puzzleOfSet]
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [Finset.mem_image] at ha
    obtain ⟨b, hb, rfl⟩ := ha
    exact hstable b hb
  · intro a ha
    simp only [Finset.mem_image]
    exact ⟨compAssign a, hstable a ha, compAssign_involutive a⟩

/-- An odd assembly count is realisable, confirming that the parity theorem
cannot be strengthened to a single assembly space. -/
theorem odd_single_count : ∃ P : FPuzzle n, ¬ Even (assemblySet P).card := by
  obtain ⟨P, hP⟩ := assembly_spectrum (n := n) 1 (Nat.one_le_two_pow)
  exact ⟨P, by rw [hP]; decide⟩

/-! ## Part 4 — Numerical experiments -/

#eval (excludeClause (fun _ => true : Fin 3 → Bool))
#eval (assemblySet (puzzleOfList [(fun _ => true : Fin 2 → Bool)])).card
#eval (combinedAssemblySet (puzzleOfList [(fun _ => true : Fin 2 → Bool)])).card
#eval (assemblySet (puzzleOfList ([] : List (Fin 3 → Bool)))).card

/-- The realising puzzle for the singleton `{(true, true)}` on two variables uses
three clause pieces and has exactly one assembly; its combined space has two. -/
theorem singleton_realisation :
    (puzzleOfSet ({fun _ => true} : Finset (Fin 2 → Bool))).length = 3 ∧
    (assemblySet (puzzleOfSet ({fun _ => true} : Finset (Fin 2 → Bool)))).card = 1 ∧
    (combinedAssemblySet (puzzleOfSet ({fun _ => true} : Finset (Fin 2 → Bool)))).card = 2 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [puzzleOfSet_length]
    decide
  · rw [assemblySet_puzzleOfSet]
    decide
  · rw [combinedAssemblySet, assemblySet_compPuzzle, assemblySet_puzzleOfSet,
      Finset.image_singleton, Finset.singleton_union, Finset.card_insert_of_notMem (by decide),
      Finset.card_singleton]

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Cycle three asked whether the parity constraint discovered in
cycle one is the *only* constraint.  (L1) Is every subset of the Boolean cube an
assembly space of a framed puzzle?  (L2) If so, what is the minimal number of
clause pieces needed?  (L3) Which single-puzzle assembly counts occur?  (L4)
Which combined counts occur — is the characterisation exactly "even and at most
`2^n`"?  (L5) Do self-dual puzzles exist in every admissible size, or is
self-duality a rare degeneracy?

**Experiment.**  A clause piece `excludeClause b` was built whose input edges are
milled for the negation of every coordinate of `b`; it interlocks with `a`
exactly when `a ≠ b`.  Listing one such piece for each non-assembly realises a
prescribed space.  The construction was evaluated on the singleton
`{(true, true)}` over two variables: three clause pieces, one assembly, combined
count two — all three numbers confirmed by enumeration in
`singleton_realisation`, and matching the general formulas.  The full cube over
three variables was checked to have eight assemblies with zero clause pieces.

**Analysis.**  L1 survives in the strongest possible form
(`assemblySet_puzzleOfSet`): the assembly-space map is surjective, so framed
puzzles are a complete Boolean constraint language, and every counting statement
about assembly spaces is a statement about arbitrary subsets of the cube.  L2 is
answered for this construction, `2^n - |S|` pieces (`puzzleOfSet_length`); the
*minimal* piece count is not settled and is left open.  L3 survives: the assembly
spectrum is all of `[0, 2^n]` (`assembly_spectrum`), so odd counts occur
(`odd_single_count`), which is exactly why the parity theorem must be about the
complement-stable union.  L4 survives with an exact characterisation
(`combined_spectrum_iff`): the possible combined counts are precisely the even
numbers up to `2^n`.  L5 survives (`selfDual_spectrum`): self-dual assembly
spaces exist in every even size, so self-duality is generic rather than
degenerate, reinforcing the refutation of the original hypothesis that
self-duality creates fixed configurations.

**Critique.**  `combined_spectrum_iff` is the only place where the two halves of
the theory meet, and they are genuinely independent: the forward direction uses
the free-involution parity principle, the backward direction uses the
gauge-based construction of complement-stable sets.  Neither direction is
definitional.  A caveat: the puzzles produced by `puzzleOfSet` are maximally
redundant — one piece per excluded assembly — so the spectrum results say nothing
about puzzles of bounded description size, where the counting problem is
`#P`-hard by the parsimonious reduction of `Shared.JigsawSolutionSpace`.  The
bound `2 * k ≤ 2 ^ n` is necessary since the cube has `2^n` points.

**Synthesis.**  Framed puzzles express every Boolean constraint on their variable
set, so their combined assembly counts fill out exactly the even numbers up to
`2^n`, and their single counts fill out everything up to `2^n`.  Complementation
contributes precisely one bit of global information — the parity of the combined
space — and nothing more.
-/

end JigsawFreeComplement