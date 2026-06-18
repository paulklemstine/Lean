# Future Directions: Baker–Norine Riemann–Roch on Graphs

This cycle extended `Catalog/Bridges/GraphRiemannRoch.lean` with the
`BakerNorineBounds` section, proving genuine consequences of the (still only
*stated*) Baker–Norine identity: the engine lemma `winnable_add_effective`,
translation-invariance and transitivity of linear equivalence, monotonicity of
the rank (`hasRankAtLeast_mono`), the **Riemann inequality** `r(D) ≤ deg D`
(`hasRankAtLeast_le_degree`), and the corollary that negative-degree divisors
have rank `−1` (`negative_degree_rank_neg`). All hold for an arbitrary finite
simple graph with no connectivity assumption, and depend only on the standard
axioms. The directions below build directly on these foundations.

## 1. The full Baker–Norine equality from the two inequalities

We have the easy half of Riemann–Roch — the Riemann inequality `r(D) ≤ deg D`.
The hard half is the symmetric Clifford/duality bound that closes the gap to the
exact identity `r(D) − r(K − D) = deg D + 1 − g`, the content of
`RiemannRoch.RiemannRochHolds`. The natural attack is via *reduced divisors*
(Dhar's burning algorithm relative to a base vertex `q`): every divisor class
has a unique `q`-reduced representative, and `r(D) ≥ 0 ⟺` the `q`-reduced form is
nonnegative at `q`. **The key insight is** that the Riemann inequality already
proved here is exactly the inequality obtained by applying winnability to a
single concentrated `chips q r` divisor, so reduced divisors are simply the
optimal such test divisors — turning the existing `hasRankAtLeast_le_degree`
proof into the base case of the full argument. **Why now?** The
`Winnable`/`HasRankAtLeast`/`chips` API and the stability lemma
`winnable_add_effective` are precisely the primitives Dhar's algorithm
manipulates, so the remaining work is combinatorial (formalizing burning) rather
than foundational.

## 2. Reduced divisors and uniqueness via Dhar's burning algorithm

State and prove: for a connected `G` and base vertex `q`, every divisor is
linearly equivalent to a unique `q`-reduced divisor, definable by a terminating
burning process. **The key insight is** that linear-equivalence transitivity
(`linearEquiv_trans`) plus translation-invariance (`linearEquiv_add_right`),
both proved this cycle, make the set of representatives of a class a torsor under
the Laplacian image, so uniqueness reduces to showing the burning process is a
well-defined normal form on that torsor. **Why now?** Transitivity and
translation invariance were the missing algebraic ingredients; with them, "two
reduced divisors in the same class are equal" becomes a finite descent argument
that the subagent can discharge once burning is encoded.

## 3. A computable, decidable rank function and the genus-`g` bound

Replace the predicate `HasRankAtLeast` with a `ℤ`-valued `rank D` and prove
`rank D = -1 ↔ ¬ Winnable G D` and `deg D ≥ 2g - 1 → rank D = deg D - g`
(the Riemann–Roch range where the correction term vanishes). **The key insight
is** that monotonicity (`hasRankAtLeast_mono`) already shows the set
`{r : HasRankAtLeast G D r}` is downward-closed, so it is an interval `(-∞, ρ]`
and `rank D := ρ` is well-defined; the Riemann inequality bounds `ρ ≤ deg D`,
giving a finite search space hence decidability. **Why now?** With both
monotonicity and the upper bound in hand, `rank` is provably a `sup` of a
bounded, downward-closed set — the exact situation where `Int`-valued
well-foundedness gives a clean total function.

## 4. Clifford's theorem for graphs: `2·r(D) ≤ deg D` for special divisors

For a divisor with `0 ≤ r(D)` and `0 ≤ r(K − D)` (a "special" divisor), prove
`r(D) ≤ deg D / 2`. **The key insight is** that adding the Riemann inequality
for `D` and for `K − D` and using `deg K = 2g − 2` (already
`ChipFiring.canonical_divisor_degree`) collapses to Clifford's bound, so the
theorem is a two-line corollary of `hasRankAtLeast_le_degree` applied twice
once duality (`r(K−D)` controlled by `r(D)`) is available. **Why now?** The
canonical-degree identity and the Riemann inequality are both formalized; only
the duality pairing between `D` and `K − D` remains, isolating a single missing
lemma rather than a whole theory.

## 5. Specialization to `K_n` and the gonality sequence

Use the complete-graph results (`CompleteGraph.K_genus`, `K_canonical_degree`)
together with the new bounds to compute the rank of small divisors on `K_n`,
and conjecture the gonality `gon(K_n) = n − 1` (minimum degree of a positive-rank
divisor). **The key insight is** that on `K_n` the symmetry group acts
transitively on vertices, so `chips v₀ k` divisors of equal degree are all
linearly equivalent, collapsing the rank computation to a one-parameter family
that the Riemann inequality pins down from above. **Why now?** `K_genus` and the
canonical-divisor computations for `K_n` are already proved and sorry-free, so
the gonality conjecture can be tested concretely for `n = 3,4,5,6` by `decide`-
style evaluation before attempting the general proof.
