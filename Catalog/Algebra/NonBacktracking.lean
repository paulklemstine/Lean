import Algebra.NonBacktracking.RelWalkCount
import Algebra.NonBacktracking.HashimotoTrace
import Algebra.NonBacktracking.VertexCycles
import Algebra.NonBacktracking.CyclePositivity
import Algebra.NonBacktracking.AcyclicVanishing
import Algebra.NonBacktracking.Girth
import Algebra.NonBacktracking.ReversalParity
import Algebra.NonBacktracking.CycleMultiplicity
import Algebra.NonBacktracking.Monotonicity
import Algebra.NonBacktracking.Examples

/-!
# Non-backtracking walks and the Hashimoto matrix

Index module for the development of the trace formula

`trace (Bⁿ) = #{rooted closed non-backtracking walks of length n}`

for the Hashimoto (non-backtracking) matrix `B` of a finite simple graph.

* `Algebra.NonBacktracking.RelWalkCount` — walk counting for the 0-1 matrix of an
  arbitrary decidable relation (a digraph), which the non-backtracking relation requires
  since it is not symmetric.
* `Algebra.NonBacktracking.HashimotoTrace` — the Hashimoto matrix, the main counting
  theorem and its cyclic form, the length-three (triangle) evaluation, row sums and the
  regular-graph growth bound.
* `Algebra.NonBacktracking.VertexCycles` — the vertex-word form of the counting theorem.
* `Algebra.NonBacktracking.CyclePositivity` — cycles force a positive trace; vanishing
  traces detect acyclicity.
* `Algebra.NonBacktracking.AcyclicVanishing` — the converse: forests have identically
  zero non-backtracking trace, giving the characterisation
  `G.IsAcyclic ↔ ∀ n ≥ 1, trace (Bⁿ) = 0`.
* `Algebra.NonBacktracking.Girth` — the trace sequence vanishes below the girth and is
  positive at it, so `girth G = min {n ≥ 1 : trace (Bⁿ) ≠ 0}`.
* `Algebra.NonBacktracking.ReversalParity` — dart reversal is a fixed-point-free
  involution, so every `trace (Bⁿ)` is even.
* `Algebra.NonBacktracking.CycleMultiplicity` — each cycle of length `m` contributes `2m`
  rooted closed non-backtracking walks, so `2 · girth ≤ trace (B ^ girth)`.
* `Algebra.NonBacktracking.Monotonicity` — the trace sequence is monotone under graph
  inclusion.
* `Algebra.NonBacktracking.Examples` — `K₃`, `K₄`, `C₅` and a tree, checked in the kernel.
-/