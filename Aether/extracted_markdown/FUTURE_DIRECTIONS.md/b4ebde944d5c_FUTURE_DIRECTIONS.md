# Future Directions: Completing the Code-Size Trilogy

This cycle closed two of the three classical elementary bounds on the size of a
block code in the combinatorial "Library of Babel" framework (`Word = ι → G`,
Hamming metric), building directly on the catalog's
`Catalog/Tropical/SpherePackingBound.lean`:

* **`Catalog/Applications/GilbertVarshamov.lean`** — the *lower* bound dual to the
  catalog's sphere-packing upper bound. We proved `gilbert_varshamov`
  (`qⁿ ≤ |C|·V(d-1)` for any maximal `d`-code), its closed form
  `gilbert_varshamov_formula`, the covering lemma `maximal_covers`, and the
  two-sided `code_size_sandwich` (`|C|·V(t) ≤ qⁿ ≤ |C|·V(2t)` for a maximal
  `(2t+1)`-code). The conceptual core is the **packing/covering duality**:
  large minimum distance gives *disjoint* balls (Hamming bound) while maximality
  gives *covering* balls (Gilbert–Varshamov bound).

* **`Catalog/Applications/SingletonBound.lean`** — the third elementary bound,
  `singleton_bound` (`|C| ≤ qⁿ⁻ᵈ⁺¹`), via the projection-injectivity lemma
  `restriction_injOn`. Notably this required *no* alphabet group structure and *no*
  ball-volume formula, and we proved it without the classical `1 ≤ d` hypothesis,
  yielding a strictly more general statement.

Together with `SpherePackingBound.sphere_packing_bound`, the catalog now contains
the complete trio Hamming / Gilbert–Varshamov / Singleton, all phrased over a
common abstract alphabet and reusing the same `hammingDist`-as-`Finset`-cardinality
hinge. The following directions extend that architecture; each is testable — it can
be stated in Lean and either proved or refuted.

## 1. Greedy existence: the GV bound is *attained*

Our `gilbert_varshamov` is conditional on the hypothesis `IsMaximal C d`. The next
step is to discharge that hypothesis unconditionally: for every `A`, `L`, `d` there
*exists* a code `C` with `IsMaximal C d`, hence (by `gilbert_varshamov`) a code with
`qⁿ ≤ |C|·V(d-1)`. **The key insight is** that maximality is a pure existence
statement on the finite lattice of subsets of `ι → G`: start from `∅` and keep
inserting any word that preserves `d`-separation; since the ambient space is finite
the process terminates exactly at an `IsMaximal` code, so a `Finset.card`-induction
(strong induction on the number of insertable words) converts the conditional bound
into an unconditional one. **Why now?** `IsMaximal` is already defined and
`gilbert_varshamov` already consumes it, so the only missing piece is one
greedy-termination lemma — `∃ C, IsMaximal C d` — provable by well-founded recursion
on `(Finset.univ \ C).card`, after which "GV-optimal codes exist" follows for free.

## 2. The Plotkin bound via double counting

Conjecture: if `A·d > (A-1)·L` then any `d`-separated code satisfies the integer
Plotkin bound `|C|·(A·d - (A-1)·L) ≤ A·d`. **The key insight is** a double-count of
`∑_{x,y ∈ C} hammingDist x y`: summing per coordinate, each coordinate contributes
at most `(1 - 1/A)·|C|²` collisions (a finite convexity fact about how `|C|` symbols
distribute over `A` values), while `d`-separation forces the same total to be at
least `d·|C|·(|C|-1)`; comparing pins `|C|`. **Why now?** The per-coordinate
decomposition `hammingDist x y = ∑_i [x i ≠ y i]` is exactly the
`Finset.filter`-cardinality identity we used in `restriction_injOn` and in the
sphere count `hammingWeight_count`, so the only genuinely new ingredient is the
algebraic rearrangement of the two-sided count — no new geometry is required.

## 3. Perfect codes and the equality case of the sandwich

Conjecture: a `(2r+1)`-separated code is *perfect* (`|C|·V(r) = qⁿ`, equality in
sphere-packing) **iff** the radius-`r` balls about codewords *partition* the whole
space, equivalently iff `C` is simultaneously packing-tight and a maximal
`(2r+1)`-code of covering radius exactly `r`. **The key insight is** that our two
inequalities share a geometric witness: `hammingBall_pairwise_disjoint` drives the
upper bound via *disjointness* and `maximal_covers` drives the lower bound via
*covering*, so equality forces "disjoint **and** covering" = a tiling, which
collapses `code_size_sandwich` (with `d = 2r+1`, so `d-1 = 2r`) to a single value
only when `r` meets the covering radius. **Why now?** Both halves are already built
from explicit `biUnion` cardinality reasoning, so characterizing equality is exactly
tracking when `Finset.card_le_card` (subset becomes equality) and
`Finset.card_biUnion_le` (union card equals the sum, i.e. disjointness) become
equalities — purely combinatorial conditions already present in our proofs.

## 4. The MDS equality case of the Singleton bound

Conjecture: a `d`-separated code meets the Singleton bound with equality
(`|C| = qⁿ⁻ᵈ⁺¹`, an MDS code) **iff** the restriction of `C` to *every* set of
`n-d+1` coordinates is a bijection onto `(T → G)`. **The key insight is** that our
`restriction_injOn` already shows each such restriction is *injective*; equality in
`singleton_bound`'s final `Finset.card_le_card` forces it to additionally be
*surjective*, i.e. a bijection, and the symmetry across coordinate sets follows
because the Singleton argument used an *arbitrary* size-`(n-d+1)` subset `T`.
**Why now?** The proof of `singleton_bound` already isolates the single
`card_le_card` step where slack can occur, so the equality characterization is a
direct "injective + cardinalities match ⇒ bijective" upgrade, with no new metric
input.

## 5. Asymptotic rate versus the entropy bound

Conjecture: writing `δ = d/L` (relative distance) and `R = log_A|C| / L` (rate), the
proven exact volume `V(r) = ∑_{i≤r} C(L,i)(A-1)ⁱ` squeezes the sandwich into the
asymptotic envelope `1 - H_A(δ) - o(1) ≤ R ≤ 1 - H_A(δ/2) + o(1)`, where `H_A` is
the `A`-ary entropy. **The key insight is** that `gilbert_varshamov_formula` and
`SpherePackingBound.sphere_packing_bound_formula` reduce the entire asymptotic
theory to a single real-analytic estimate: the truncated binomial sum
`∑_{i≤r} C(L,i)(A-1)ⁱ` is `A^{L·H_A(r/L)}` up to a polynomial factor. **Why now?**
We no longer have to *assume* the volume formula on either side — both closed forms
are theorems in the catalog — so the remaining work is purely the calculus of
`Real.log`/`Real.exp` applied to `Nat.choose` bounds, machinery that already exists
in Mathlib.
