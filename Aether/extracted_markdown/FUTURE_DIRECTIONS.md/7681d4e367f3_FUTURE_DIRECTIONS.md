# Future Directions: The Categorical and Ordinal Geometry of GL Frames

## Synthesis

This cycle pushed the Kripke-semantic core of Gödel–Löb provability logic
(`Catalog/Logic/GLKripke.lean`, `Catalog/Logic/PolymodalGL.lean`) in two of the
directions that the previous polymodal cycle flagged as open — the *categorical
obstruction* (Direction 2) and the *quantitative-Löb rank stratification*
(Direction 4) — and in doing so turned two informal remarks into machine-checked
theorems while *correcting* one conjecture that turned out to be vacuous.

The first thread (`Catalog/Logic/GLProductBox.lean`) confronts the asymmetry first
observed in `prod_diamond_rectangle`: the diamond of a rectangle factors exactly
(`◇(A ×ˢ B) = ◇A ×ˢ ◇B`), but the box does not. We proved the surviving half
`(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` in general (`prod_box_rectangle_subset`), proved that
equality is recovered when both factors are *edgeless*
(`prod_box_rectangle_of_edgeless`), and built an explicit two-world witness
(`prod_box_not_factor`) on `Bool` (one edge) and `Unit` (a dead end) where the
inclusion is **strict**. The decisive structural discovery is a correction to the
previous cycle's Direction 2: it conjectured that box factors *iff both frames are
serial*, but a serial GL frame is **empty** — converse well-foundedness
(`GLFrame.flip_wellFounded`) forces every nonempty GL frame to have a dead end. So the
right coincidence criterion is not seriality but **edge-freeness**, and the dead end is
exactly the obstruction (it empties the universal quantifier behind `□`).

The second thread (`Catalog/Logic/GLRankStratification.lean`) lifts the concrete
computation `natBox^[k] ∅ = Set.Iio k` of `Catalog/Logic/LobNatModel.lean` from the
single frame `(ℕ, >)` to *every* GL frame. We proved `□∅ = {dead ends}`
(`boxSet_empty_eq_maximal`), characterized the bottom ordinal layer
`rank w = 0 ↔ IsMaximal w` (`rank_eq_zero_iff_maximal`), and proved the full
stratification `□^k ∅ = { w | rank w < k }` (`boxSet_iterate_eq_rank_lt`). This is a
clean identity *consistency strength = ordinal rank*: the iterated falsity `□^k⊥` is
satisfied exactly at worlds whose ordinal rank is below `k`. The `(ℕ, >)` picture, where
`rank n = n` and `Iio k = {n | n < k}`, is now the special case of an every-frame
theorem.

## Results Summary

- `GLFrame.prod_box_rectangle_subset` — proved: `(□A) ×ˢ (□B) ⊆ □(A ×ˢ B)` always, the
  surviving half of box-factorization in the synchronized product.
- `GLFrame.prod_box_rectangle_of_edgeless` — proved: box factors (`□(A ×ˢ B) = □A ×ˢ □B`)
  when both factor frames are edgeless — the only way box can factor over a nonempty
  product.
- `GLFrame.prod_box_not_factor` — proved (explicit `Bool`/`Unit` witness): the inclusion
  is *strict*, `(□A) ×ˢ (□B) ⊊ □(A ×ˢ B)`; box genuinely fails to factor. The point
  `(true, ())` is in the right side vacuously (dead end) but not the left.
- `GLFrame.boxSet_empty_eq_maximal` — proved: `□∅` is exactly the set of dead-end worlds.
- `GLFrame.rank_eq_zero_iff_maximal` — proved: `rank w = 0 ↔ IsMaximal w`, the bottom
  layer of the rank stratification.
- `GLFrame.boxSet_iterate_eq_rank_lt` — proved: `□^k ∅ = { w | rank w < k }` for every GL
  frame, generalizing `natBox_iterate_eq_Iio` and identifying consistency strength with
  ordinal rank.
- (Infrastructure) `ProvabilityLattice` restored in `Catalog/Logic/ProvabilityLogic.lean`,
  repairing the dangling import that previously prevented the entire GL chain from
  building.

All main theorems use only `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### Direction 1: The exact factorization criterion — a full iff for box

We proved two endpoints: edge-freeness suffices for equality, and a dead-end witness
forces strictness. The missing middle is the precise characterization. Conjecture:
`(∀ A B, (F.prod G).boxSet (A ×ˢ B) = (F.boxSet A) ×ˢ (G.boxSet B))` holds **iff**
`F` is empty, or `G` is empty, or both `F` and `G` are edgeless. The test is to prove
the forward direction by contraposition — if both frames are nonempty and at least one
has an edge, use `exists_maximal_world` to manufacture a dead end in the other
coordinate and replay the `prod_box_not_factor` construction with `A` excluding the live
successor. The key insight is that the only obstruction to factorization is a *live edge
in one coordinate paired with a dead end in the other*, so the equality locus is governed
entirely by the joint edge/dead-end profile of the two frames. Why now? We have both
halves (`prod_box_rectangle_of_edgeless` and `prod_box_not_factor`) and the dead-end
generator `exists_maximal_world` already proved; only the bookkeeping that interpolates
them remains. If true, it pins down exactly when `□` is a product-preserving functor; if
false, it would expose a third, non-edge-based source of box-factorization that the
synchronized-product semantics had hidden.

### Direction 2: Rank equals longest-chain length — the combinatorial face of the gauge

The stratification `□^k ∅ = {rank w < k}` strongly suggests `rank w` is the length of the
longest ascending `R`-chain out of `w`. Conjecture: in any GL frame, `F.rank w` equals
`sSup { n | ∃ chain w = x₀ R x₁ R ⋯ R xₙ }`, and consequently `rank w` is always a
*natural number* (below `ω`) because the frame is finite. The test is to define a chain
predicate over `ℕ`-indexed sequences with a length bound, prove `rank`-monotonicity along
chains from `gl_rank_lt_of_R`, and prove the reverse by extracting a maximal chain through
`boxSet_iterate_eq_rank_lt`. The key insight is that the *ordinal* rank and the *integer*
proof-depth are the same number on finite frames — the well-founded recursion behind
`IsWellFounded.rank` is secretly counting the longest path. Why now? `boxSet_iterate_eq_rank_lt`
already equates membership in `□^k ∅` with `rank w < k`, so the chain length is squeezed
between consecutive iterates; the only new ingredient is the chain-extraction lemma. If
true, it makes "rank" computable and `#eval`-able on explicit finite frames; if false, it
reveals branching frames where ordinal rank and longest-chain depth diverge, a genuinely
two-dimensional notion of provability depth.

### Direction 3: Functoriality of rank under products and p-morphisms

With rank now defined for every frame, we can ask how it transforms under the categorical
operations. Conjecture: for the synchronized product,
`(F.prod G).rank (w₁, w₂) = min (F.rank w₁) (G.rank w₂)` (a product step dies as soon as
*either* coordinate dies), and any bounded morphism (p-morphism) `f : F → G` satisfies
`G.rank (f w) ≤ F.rank w`, with equality when `f` is surjective on successors. The test is
to define `GLFrameMorphism` (maps preserving `R` forward and reflecting it backward along
images), prove the `min` identity for the product by mutual induction on the two ranks via
`gl_rank_lt_of_R`, and prove rank-monotonicity from the back-condition. The key insight is
that rank is a *functorial invariant*: it is the universal measure that the product
minimizes and that bounded morphisms can only decrease, exactly mirroring how consistency
strength behaves under interpretation. Why now? `GLFrame.prod`, `prod_validates_loeb`, and
the rank machinery are all in place; rank gives the first numerical invariant against which
to test functoriality. If true, it equips the category of GL frames with a rank functor to
the ordinals; if false, the failure pinpoints which morphisms fail to be bounded.

### Direction 4: An ε₀-valued rank for an ordinal-indexed GLP frame

Our `boxSet_iterate_eq_rank_lt` works for *finite* GL frames where rank stays below `ω`.
The natural escalation is to drop finiteness for converse-well-founded *infinite* frames
and reach named proof-theoretic ordinals. Conjecture: there is a converse-well-founded
frame on `World := {α : Ordinal // α < ε₀}` with accessibility `α R β ↔ β < α` whose top
world has `rank = ε₀`, and whose level-shifted polymodal refinement realizes the
Veblen/Japaridze tower `ω, ω^ω, …`. The test is to generalize `GLFrame` (or build a
parallel `InfGLFrame`) that requires only converse well-foundedness instead of finiteness,
re-derive `rank` and `gl_rank_lt_of_R` (which already only use well-foundedness), and
compute the rank of the top world as `ε₀` using ordinal arithmetic. The key insight is that
`IsWellFounded.rank` of the *converse order* on an ordinal segment *is the identity*, so the
proof-theoretic ordinal of PA appears as a literal `rank`. Why now? `gl_rank_lt_of_R` and
the rank definition already depend only on `flip_wellFounded`, not on `Finite`, so the
descent lemma survives verbatim once finiteness is relaxed. If true, it is a verified bridge
from frame semantics to the ordinal `ε₀`; if false, it sharpens exactly which arithmetical
content beyond the bare frame the GLP–ordinal correspondence requires.

### Direction 5: A tropical cost semantics certified by the rank

Replace the boolean `boxSet` by a real- or ordinal-valued *cost*
`cost(w, □φ) = (sup over R-successors of cost(·, φ)) + 1`, defined by well-founded recursion
on `flip R`. Conjecture: this recursion is total (terminating by `flip_wellFounded`),
satisfies a tropical Löb inequality `cost(w, □(□φ → φ)) ≥ cost(w, □φ)`, and bounds the
boolean rank from above: `cost(w, □^k⊥) = min (k, rank w)`, so its growth rate in `k` is
exactly `rank w`. The test is to define `tropicalForces` by `WellFounded.fix` on
`flip F.R`, prove the recursion equation, and relate `cost(w, □^k⊥)` to
`boxSet_iterate_eq_rank_lt`. The key insight is that the *same* well-founded relation that
makes `rank` total makes a quantitative cost function total, so the qualitative
stratification and a quantitative "proof cost" share a single recursion. Why now?
`flip_wellFounded` provides precisely the well-founded relation needed for the total
recursive definition, which was the missing ingredient for a tropical layer, and
`boxSet_iterate_eq_rank_lt` gives the boolean target to calibrate against. If true, it
produces a tropical incompleteness gauge tying proof cost to ordinal rank; if false, it
isolates where the cost recursion stops being monotone under the GL axioms — the precise
point at which quantitative and qualitative provability part ways.
