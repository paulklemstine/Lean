import Mathlib

/-!
# The Algebra of Surprise: Combining and Refining Jokes

This file extends the metric theory of surprise (see `JokeHumorMetric`) and the
universal/terminal theory of resolutions (see `UniversalJoke`) with the *algebra* of
how surprise behaves when jokes are **combined** and **refined**.

A "setup" is modelled by a finite nonempty configuration of resolutions `S ⊆ ℝ`, laid
out along a single interpretive axis, and its **surprise** is the range

`humor S = max' S - min' S`,

the gap between its most divergent and most conservative reading. Two setups can be
combined by juxtaposition (`∪`) — telling both jokes together — or intersected
(`∩`) — restricting to their shared readings. This file characterises how surprise
transforms under these operations, and packages the whole thing categorically.

## Combination laws

* `humor_union_eq` : the surprise of a combined setup is determined *entirely* by the
  four extremal resolutions of the two parts.
* `humor_union_ge_left` / `humor_union_ge_right` : combining jokes never decreases
  surprise — juxtaposition is *inflationary*.
* `humor_union_le_add_of_inter` : **subadditivity under shared context.** If the two
  setups share a common resolution (a "pivot" both jokes pass through), the combined
  surprise is at most the sum of the individual surprises. This is the lax structure
  map of surprise viewed as a lax monoidal functor for the union monoidal structure.
* `humor_inter_le_left` : restricting to shared readings can only decrease surprise.

## Categorical packaging

Setups are ordered by refinement (`⊆`), which makes `Setup` a (thin) category. The
central structural result is:

* `surpriseFunctor` : surprise is a **functor** `Setup ⥤ ℝ` from the category of
  setups (ordered by refinement) to the real line (ordered by magnitude), and
* `surprise_of_refinement` : every refinement of setups is sent to an inequality of
  surprises — functoriality is exactly the statement that "a funnier reading of a
  funnier setup stays funnier".

-- !-- Lab Notes -- !--
Hypothesis: surprise is not merely a numerical invariant but an *algebraic* one — it
interacts predictably with the natural operations on setups (union, intersection,
refinement), and these interactions are the shadow of a functorial/lax-monoidal
structure.

Experiment: model setups as nonempty `Finset ℝ`. Each combination law was reduced to
`Finset.max'_union`, `Finset.min'_union`, and the order lemmas `le_max'` / `min'_le`,
then discharged by `linarith` (after a `max_def`/`min_def` case split for the
subadditivity bound). The functor was obtained from monotonicity of `humor` via
`Monotone.functor`.

Analysis: `humor_union_le_add_of_inter` is the load-bearing result: subadditivity
*fails* in general (two far-apart jokes have combined surprise far exceeding the sum of
their individual surprises), but holds precisely when the setups share a pivot. This is
the categorical fingerprint of a lax monoidal — not strong monoidal — structure.

Critique: the model is one-dimensional, so `min'`/`max'` genuinely bracket each set.
The shared-context hypothesis in `humor_union_le_add_of_inter` is necessary, not
cosmetic: without it the bound is false.

Synthesis: surprise is a monotone functor from the poset of setups to the reals, lax
monoidal for juxtaposition with shared context — combining jokes inflates surprise,
refining setups is respected, and shared context tames the growth.
-/

open CategoryTheory Finset

namespace JokeSurpriseAlgebra

/-- The **surprise** of a setup: the gap between its most divergent resolution
(`max'`) and its most conservative resolution (`min'`). -/
noncomputable def humor (S : Finset ℝ) (h : S.Nonempty) : ℝ := S.max' h - S.min' h

/-- **Combination is determined by the extremes.** The surprise of a combined setup
depends only on the four extremal resolutions of its two parts. -/
theorem humor_union_eq (S T : Finset ℝ) (hS : S.Nonempty) (hT : T.Nonempty) :
    humor (S ∪ T) hS.inl = max (S.max' hS) (T.max' hT) - min (S.min' hS) (T.min' hT) := by
  unfold humor
  rw [Finset.max'_union hS hT, Finset.min'_union hS hT]

/-- **Juxtaposition is inflationary (left).** Combining a setup with another can only
increase its surprise. -/
theorem humor_union_ge_left (S T : Finset ℝ) (hS : S.Nonempty) :
    humor S hS ≤ humor (S ∪ T) hS.inl := by
  unfold humor
  have hmax : S.max' hS ≤ (S ∪ T).max' hS.inl :=
    Finset.le_max' _ _ (Finset.mem_union_left _ (S.max'_mem hS))
  have hmin : (S ∪ T).min' hS.inl ≤ S.min' hS :=
    Finset.min'_le _ _ (Finset.mem_union_left _ (S.min'_mem hS))
  linarith

/-- **Juxtaposition is inflationary (right).** Symmetric to `humor_union_ge_left`. -/
theorem humor_union_ge_right (S T : Finset ℝ) (hT : T.Nonempty) :
    humor T hT ≤ humor (S ∪ T) hT.inr := by
  unfold humor
  have hmax : T.max' hT ≤ (S ∪ T).max' hT.inr :=
    Finset.le_max' _ _ (Finset.mem_union_right _ (T.max'_mem hT))
  have hmin : (S ∪ T).min' hT.inr ≤ T.min' hT :=
    Finset.min'_le _ _ (Finset.mem_union_right _ (T.min'_mem hT))
  linarith

/-- **Subadditivity under shared context.** If two setups share a common resolution
`c` (a pivot both jokes pass through), the surprise of their combination is at most the
sum of their individual surprises. This is the lax structure map of surprise as a lax
monoidal functor; the shared-context hypothesis is essential — it fails for
far-apart setups with no common reading. -/
theorem humor_union_le_add_of_inter (S T : Finset ℝ) (hS : S.Nonempty) (hT : T.Nonempty)
    (c : ℝ) (hcS : c ∈ S) (hcT : c ∈ T) :
    humor (S ∪ T) hS.inl ≤ humor S hS + humor T hT := by
  rw [humor_union_eq S T hS hT]
  unfold humor
  have h1 : S.min' hS ≤ c := Finset.min'_le _ _ hcS
  have h2 : c ≤ S.max' hS := Finset.le_max' _ _ hcS
  have h3 : T.min' hT ≤ c := Finset.min'_le _ _ hcT
  have h4 : c ≤ T.max' hT := Finset.le_max' _ _ hcT
  simp only [max_def, min_def]
  split_ifs <;> linarith

/-- **Restriction is deflationary.** Restricting a setup to the resolutions it shares
with another can only decrease its surprise. -/
theorem humor_inter_le_left (S T : Finset ℝ) (h : (S ∩ T).Nonempty) (hS : S.Nonempty) :
    humor (S ∩ T) h ≤ humor S hS := by
  unfold humor
  have hmax : (S ∩ T).max' h ≤ S.max' hS :=
    S.le_max' _ (Finset.mem_of_mem_inter_left ((S ∩ T).max'_mem h))
  have hmin : S.min' hS ≤ (S ∩ T).min' h :=
    S.min'_le _ (Finset.mem_of_mem_inter_left ((S ∩ T).min'_mem h))
  linarith

/-! ### Surprise as a functor

We now package the monotonicity of surprise categorically. Setups form a thin category
under refinement (`⊆`); the reals form a thin category under magnitude (`≤`). Surprise
is a functor between them. -/

/-- A **setup**: a nonempty finite configuration of resolutions. -/
def Setup : Type := {S : Finset ℝ // S.Nonempty}

/-- Setups are ordered by **refinement**: `S ≤ T` means every resolution of `S` is a
resolution of `T`. This makes `Setup` a (thin) category. -/
instance : Preorder Setup := Subtype.preorder _

/-- Surprise as a bare function on setups. -/
noncomputable def humorS (S : Setup) : ℝ := S.1.max' S.2 - S.1.min' S.2

/-- **Surprise is monotone under refinement.** -/
theorem humorS_monotone : Monotone humorS := by
  rintro ⟨S, hS⟩ ⟨T, hT⟩ (hsub : S ⊆ T)
  have hmax : S.max' hS ≤ T.max' hT := T.le_max' _ (hsub (S.max'_mem hS))
  have hmin : T.min' hT ≤ S.min' hS := T.min'_le _ (hsub (S.min'_mem hS))
  simp only [humorS]; linarith

/-- **Surprise is a functor** from the category of setups (ordered by refinement) to
the real line (ordered by magnitude). -/
noncomputable def surpriseFunctor : Setup ⥤ ℝ := humorS_monotone.functor

/-- **Functoriality of surprise.** Every refinement of setups is sent to an inequality
of surprises. -/
theorem surprise_of_refinement (S T : Setup) (h : S ⟶ T) : humorS S ≤ humorS T :=
  leOfHom (surpriseFunctor.map h)

end JokeSurpriseAlgebra