# Computational Evidence: Reflection Conjugacy of the Two ℝ-Observers

Before formalizing, the core claims were checked on small explicit sets and by
direct interval arithmetic.

## 1. The reflection sends lower-open sets to upper-open sets

Model: `lowerOpen U` means every `x ∈ U` has a right half-open interval `[x, b) ⊆ U`;
`upperOpen U` means every `x ∈ U` has a left half-open interval `(a, x] ⊆ U`.

Take `U = [0, 1)`, which is lower-open (witness `b = 1` at every point). Its reflection
`{x : -x ∈ U} = (-1, 0]` is upper-open (witness `a = -1` at every point). Symmetrically,
`(0, 1]` is upper-open and reflects to `[-1, 0)`, which is lower-open. The reflection map
`x ↦ -x` is an involution, so reflecting twice returns the original set. These match the
formal lemmas `upperOpen_neg_preimage`, `lowerOpen_neg_preimage`,
`neg_preimage_neg_preimage`.

Interval check underpinning the general lemma: if `[-x, b) ⊆ U` then for `y ∈ (-b, x]` we
have `-y ∈ [-x, b)`, hence `-y ∈ U`, i.e. `y` lies in the reflected set; and `-b < x`
follows from `-x < b`. This is exactly the `linarith` step in the neighbourhood argument.

## 2. The reflection swaps the two observers (Bool-index check)

`observersℝ` assigns `true ↦ lowerTop`, `false ↦ upperTop`. Pulling `lowerTop` back along
the reflection gives `upperTop` and vice versa, so the induced action on the index set is
the Boolean swap `not`, which fixes neither index. This is the finite check behind
`reflection_swaps_observersℝ` and its use of the permutation `boolSwap`.

## 3. Consensus commutes with pullback only for bijections

Sanity check on the adjunction: `induced e = coinduced e.symm` for an equivalence `e`, and
`coinduced` preserves suprema. For a non-injective map (e.g. a constant map), pullback of a
supremum is generally coarser than the supremum of pullbacks, so bijectivity is essential —
this is why `induced_iSup_of_equiv` requires an `Equiv`, not a bare function.

## 4. Emergent symmetry

The Euclidean line is reflection invariant, but neither the lower- nor the upper-limit
observer is: `[0,1)` is lower-open but not upper-open, and its reflection `(-1,0]` is
upper-open but not lower-open. So the reflection symmetry is a property of the *consensus*,
not of either observer — the phenomenon quantified informally in Future Direction 5.

All four points were confirmed by direct elaboration of the corresponding Lean statements
before assembling the final proofs.
