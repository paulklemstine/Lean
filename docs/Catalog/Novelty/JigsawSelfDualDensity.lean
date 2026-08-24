import Mathlib
import Novelty.JigsawAssemblySpectrum

/-!
# How rare is self-duality?  An exact count of complement-stable assembly spaces

Cycle three proved that framed puzzles realise *every* subset of the Boolean cube
as an assembly space (`JigsawFreeComplement.assemblySet_puzzleOfSet`).  Counting
assembly spaces is therefore counting subsets of the cube, and counting
*self-dual* ones is counting complement-stable subsets.  This cycle computes that
number exactly, closing the density question raised at the end of cycle four.

## Contents

* `stableSpaces` is the finite family of complement-stable subsets of the cube.
* `card_stableSpaces`: there are exactly `2 ^ (2 ^ (n-1))` of them for `n ≥ 1`.
  The proof is a bijection with the powerset of the polarity gauge: intersecting
  with the gauge, and rebuilding by adjoining complements.
* `card_stableSpaces_sq`: the square of that number is the total number of
  assembly spaces, `2 ^ (2 ^ n)`.  Self-duality is thus exactly a "square root"
  condition — exponentially rare, yet realised in every admissible size by
  `JigsawFreeComplement.selfDual_spectrum`.
* `stableSpaces_lt_all`: the strict inequality making the rarity explicit.
-/

open Function

namespace JigsawFreeComplement

variable {n : ℕ}

/-! ## Part 1 — The family of complement-stable assembly spaces -/

/-- Complement-stable subsets of the Boolean cube: exactly the assembly spaces of
self-dual framed puzzles, by `assemblySet_puzzleOfSet`. -/
def stableSpaces (n : ℕ) : Finset (Finset (Fin n → Bool)) :=
  Finset.univ.filter fun S => ∀ a ∈ S, compAssign a ∈ S

@[simp] theorem mem_stableSpaces {S : Finset (Fin n → Bool)} :
    S ∈ stableSpaces n ↔ ∀ a ∈ S, compAssign a ∈ S := by
  simp [stableSpaces]

/-- Every complement-stable subset is the assembly space of a framed puzzle whose
assembly space is complement-stable — the family really does enumerate self-dual
assembly spaces. -/
theorem stableSpaces_realised (S : Finset (Fin n → Bool)) (hS : S ∈ stableSpaces n) :
    ∃ P : FPuzzle n, assemblySet P = S ∧ assemblySet (compPuzzle P) = assemblySet P := by
  refine ⟨puzzleOfSet S, assemblySet_puzzleOfSet S, ?_⟩
  rw [assemblySet_compPuzzle, assemblySet_puzzleOfSet]
  rw [mem_stableSpaces] at hS
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [Finset.mem_image] at ha
    obtain ⟨b, hb, rfl⟩ := ha
    exact hS b hb
  · intro a ha
    simp only [Finset.mem_image]
    exact ⟨compAssign a, hS a ha, compAssign_involutive a⟩

/-! ## Part 2 — The bijection with the powerset of the gauge -/

/-- Adjoining complements makes any finite set of assemblies stable; this is the
inverse of intersecting with the gauge. -/
theorem stable_union_image (T : Finset (Fin n → Bool)) :
    T ∪ T.image compAssign ∈ stableSpaces n := by
  rw [mem_stableSpaces]
  intro a ha
  simp only [Finset.mem_union, Finset.mem_image] at ha ⊢
  rcases ha with h | ⟨b, hb, rfl⟩
  · exact Or.inr ⟨a, h, rfl⟩
  · exact Or.inl (by rwa [compAssign_involutive b])

/-- Intersecting a stable set with the gauge and rebuilding recovers it. -/
theorem gauge_reconstruction (hn : 0 < n) {S : Finset (Fin n → Bool)}
    (hS : S ∈ stableSpaces n) :
    (S ∩ polarityGauge hn Finset.univ) ∪
      (S ∩ polarityGauge hn Finset.univ).image compAssign = S := by
  rw [mem_stableSpaces] at hS
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [Finset.mem_union, Finset.mem_image, Finset.mem_inter] at ha
    rcases ha with ⟨h, -⟩ | ⟨b, ⟨hb, -⟩, rfl⟩
    · exact h
    · exact hS b hb
  · intro a ha
    simp only [Finset.mem_union, Finset.mem_image, Finset.mem_inter, polarityGauge,
      Finset.mem_filter, Finset.mem_univ, true_and]
    cases h : a ⟨0, hn⟩ with
    | true => exact Or.inl ⟨ha, rfl⟩
    | false =>
        refine Or.inr ⟨compAssign a, ⟨hS a ha, ?_⟩, compAssign_involutive a⟩
        simp [compAssign, h]

/-- Cutting the rebuilt set back down to the gauge recovers the gauge subset. -/
theorem gauge_section (hn : 0 < n) {T : Finset (Fin n → Bool)}
    (hT : T ⊆ polarityGauge hn (Finset.univ : Finset (Fin n → Bool))) :
    (T ∪ T.image compAssign) ∩ polarityGauge hn Finset.univ = T := by
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [Finset.mem_inter, Finset.mem_union, Finset.mem_image, polarityGauge,
      Finset.mem_filter, Finset.mem_univ, true_and] at ha
    obtain ⟨h, h0⟩ := ha
    rcases h with h | ⟨b, hb, rfl⟩
    · exact h
    · have hb0 : b ⟨0, hn⟩ = true := (Finset.mem_filter.1 (hT hb)).2
      simp [compAssign, hb0] at h0
  · intro a ha
    simp only [Finset.mem_inter, Finset.mem_union]
    exact ⟨Or.inl ha, hT ha⟩

/-- **Exact count of self-dual assembly spaces.**  On `n ≥ 1` variables there are
exactly `2 ^ (2 ^ (n-1))` complement-stable subsets of the cube: one for each
subset of the polarity gauge. -/
theorem card_stableSpaces (hn : 0 < n) :
    (stableSpaces n).card = 2 ^ (2 ^ (n - 1)) := by
  classical
  set G := polarityGauge hn (Finset.univ : Finset (Fin n → Bool)) with hG
  have hbij : (stableSpaces n).card = G.powerset.card := by
    refine Finset.card_bij' (fun S _ => S ∩ G) (fun T _ => T ∪ T.image compAssign)
      ?_ ?_ ?_ ?_
    · intro S _
      exact Finset.mem_powerset.2 Finset.inter_subset_right
    · intro T _
      exact stable_union_image T
    · intro S hS
      exact gauge_reconstruction hn hS
    · intro T hT
      exact gauge_section hn (Finset.mem_powerset.1 hT)
  rw [hbij, Finset.card_powerset, hG, gauge_univ_card hn]
  congr 1
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp [pow_succ]

/-- **Self-duality is a square-root condition.**  The number of self-dual
assembly spaces squared is the total number of assembly spaces. -/
theorem card_stableSpaces_sq (hn : 0 < n) :
    (stableSpaces n).card * (stableSpaces n).card = 2 ^ 2 ^ n := by
  rw [card_stableSpaces hn, ← pow_add]
  congr 1
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp [pow_succ]
  ring

/-- Every subset of the cube is an assembly space, so the total number of
assembly spaces is `2 ^ (2 ^ n)`. -/
theorem card_all_spaces :
    (Finset.univ : Finset (Finset (Fin n → Bool))).card = 2 ^ 2 ^ n := by
  simp [Finset.card_univ, Fintype.card_finset]

/-- **Rarity.**  Self-dual assembly spaces are strictly, indeed exponentially,
outnumbered. -/
theorem stableSpaces_lt_all (hn : 0 < n) :
    (stableSpaces n).card < (Finset.univ : Finset (Finset (Fin n → Bool))).card := by
  rw [card_all_spaces, card_stableSpaces hn]
  refine Nat.pow_lt_pow_right (by norm_num) ?_
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  have : 0 < 2 ^ m := Nat.two_pow_pos m
  simp only [Nat.add_sub_cancel, pow_succ]
  omega

/-! ## Part 3 — Numerical experiments -/

#eval (stableSpaces 1).card
#eval (stableSpaces 2).card
#eval (Finset.univ : Finset (Finset (Fin 2 → Bool))).card

/-- On one variable there are `2` self-dual spaces out of `4`; on two variables
`4` out of `16`.  Both agree with `card_stableSpaces` and exhibit the
square-root law. -/
theorem small_stable_counts :
    (stableSpaces 1).card = 2 ∧ (stableSpaces 2).card = 4 := by
  refine ⟨?_, ?_⟩
  · rw [card_stableSpaces (by norm_num)]; norm_num
  · rw [card_stableSpaces (by norm_num)]; norm_num

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  Cycle five took up the density question left open by cycle
four.  (N1) Is the family of complement-stable assembly spaces in bijection with
the powerset of the polarity gauge?  (N2) If so, is its cardinality exactly
`2 ^ (2 ^ (n-1))`?  (N3) Does that make self-duality an exact square-root
condition relative to the `2 ^ (2 ^ n)` assembly spaces?  (N4) Are the small
cases consistent?

**Experiment.**  The bijection was implemented as "intersect with the gauge" with
inverse "adjoin complements", and the two round trips were proved separately
(`gauge_reconstruction`, `gauge_section`).  The counts were evaluated for
`n = 1, 2`: `2` stable spaces out of `4` subsets, and `4` out of `16`,
respectively — matching `2 ^ (2 ^ 0) = 2` and `2 ^ (2 ^ 1) = 4`.

**Analysis.**  N1–N4 all survive.  The bijection is the same gauge section used
for the orbit decomposition, now applied one level up, at the level of *sets of
assemblies* rather than assemblies; that reuse is the structural pattern of this
whole thread — a single fixed-point-free involution controls objects, their
solution spaces, and the family of solution spaces.  `card_stableSpaces_sq`
records the resulting square-root law, and `stableSpaces_lt_all` its
inequality form.  Combined with `selfDual_spectrum` from cycle three, the picture
is complete: self-dual spaces are exponentially rare but occur in every even
size up to `2 ^ n`.

**Critique.**  The count is of complement-stable *subsets*, and by
`assemblySet_puzzleOfSet` these correspond exactly to self-dual assembly spaces;
it is *not* a count of self-dual puzzles as syntactic objects, of which there are
infinitely many (clause pieces may be repeated or reordered).  The distinction is
recorded in `stableSpaces_realised`, which produces one canonical realising
puzzle per stable space.  The `n = 0` case is excluded throughout, consistent
with the fixed configuration found in cycle one.

**Synthesis.**  Counting at the level of solution-space families gives an exact
exponential: `2 ^ (2 ^ (n-1))` self-dual assembly spaces, the square root of the
total.  Self-duality is therefore neither an obstruction (cycle one) nor a
degeneracy (cycle three) but a measure-zero symmetry class with an explicit
parameterisation by the polarity gauge.
-/

end JigsawFreeComplement