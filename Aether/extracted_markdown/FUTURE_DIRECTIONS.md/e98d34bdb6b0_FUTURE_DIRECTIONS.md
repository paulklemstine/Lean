# FUTURE DIRECTIONS — Berggren Tree Geodesic Structure and Lorentz Lattice Reduction

## Synthesis

This cycle reframed the Berggren tree of primitive Pythagorean triples as a
**geodesic spanning tree** of the positive integer light cone of the Lorentz form
`Q(a,b,c) = a² + b² − c²`, and made the analogy with the Stern–Brocot tree
quantitative. Building strictly on top of `Cryptography.BerggrenLatticeReduction`
(its freeness theorem `evalAtRoot_injective` and its linear height bound
`height_lower_bound_root`), we proved four theorems in
`Catalog/Cryptography/BerggrenGeodesic.lean`. The central structural insight is a
clean separation of concerns: *freeness* makes the geodesic word unique (so
"length-minimizing" is automatic), while the *quantitative depth* content lives
entirely in two-sided bounds on the hypotenuse. We supplied the missing companion
to the catalog's linear bound: a per-step factor-`7` growth bound that iterates to
`c ≤ 5·7^{|w|}`, pinning the geodesic depth at `Θ(log c)`.

What surprised us — and what we want the next team to internalize — is how much of
the "geodesic" narrative is *forced by freeness alone* and therefore does **not**
require the deep Barning–Hall descent. The genuinely hard, still-missing piece is
**surjectivity**: that every primitive Pythagorean triple is reached from `(3,4,5)`.
Our `berggren_geodesic_spanning` is conditional on reachability for exactly this
reason; closing that gap is the highest-value next step and would turn three
conditional/structural results into unconditional statements about *all* primitive
triples. The enumeration theorem `berggren_level_count` (exactly `3^d` triples at
depth `d`) is the cross-domain highlight: it fuses the combinatorial branching
factor with the algebraic freeness, and the *same* injectivity underlies both the
geodesic uniqueness and the absence of level collisions.

The failure analysis was instructive. Inline destructuring of triples inside the
height induction silently detached positivity hypotheses from the new variables;
factoring the per-step bound into a standalone `actGen_hyp_le_seven` lemma fixed it
and is a reusable pattern. Indexing depth-`d` words by `List.length = d` lacks a
direct `Fintype`, whereas `Fin d → BerggrenGen` with `List.ofFn` gives a clean
finite domain that reuses `evalAtRoot_injective` verbatim — a template for any
future "level cardinality" results on generated trees.

## Results Summary

- `berggren_geodesic_spanning`: proved — every triple reachable from `(3,4,5)` has a unique, length-minimizing Berggren word (the tree is a geodesic spanning tree of its reachable set).
- `berggren_word_length_le_height`: proved — geodesic depth is at most `c − 5` (linear upper bound on depth), extending `height_lower_bound_root`.
- `berggren_height_le_geom`: proved — `c ≤ 5·7^{|w|}`, the new exponential companion bound giving a logarithmic lower bound on depth; together with the linear bound this proves `Θ(log c)` tree depth.
- `berggren_level_count`: proved — exactly `3^d` distinct primitive triples lie at tree depth `d`, fusing branching combinatorics with semigroup freeness.
- `actGen_hyp_le_seven`, `hyp_le_geom`: proved (supporting lemmas) — single-step and iterated factor-`7` hypotenuse growth bounds.

## Research Directions

### Direction 1: Unconditional surjectivity (Barning–Hall descent)
**Hypothesis**: For every primitive Pythagorean triple `(a,b,c)` with `0 < a,b,c`,
there exists a Berggren word `w` with `evalAtRoot w = (a,b,c)` (after fixing the
leg order). Equivalently, `evalAtRoot` is a bijection onto the positive primitive
light cone.
**Test**: Formalize the descent map (the unique parent already exists as
`actGen_unique_parent` in the catalog) and prove the descent strictly decreases the
hypotenuse until reaching `(3,4,5)`, via strong induction on `tripleHeight`.
**Why now**: The catalog already provides the *unique parent* and *strict height
decrease* lemmas; descent is the missing well-founded recursion, and our
`berggren_word_length_le_height` gives the termination measure for free.
**If true**: `berggren_geodesic_spanning` becomes unconditional for *all* primitive
triples, and `berggren_level_count` becomes an exact census of the entire light cone.
**If false**: It would expose primitive triples unreachable from `(3,4,5)`,
contradicting the classical Berggren theorem — almost certainly indicating a
leg-ordering or sign subtlety in the formalization rather than a true gap.

### Direction 2: Sharp growth constant and the `√n` enumeration law
**Hypothesis**: The factor `7` in `berggren_height_le_geom` can be replaced by any
constant `> 1 + 2√2 ≈ 3.83`, and consequently the `n`-th triple in hypotenuse order
satisfies `‖v‖₂ = Θ(√n)`.
**Test**: Prove a refined per-step bound `c' ≤ (1+2√2)·c + o(c)` using
`(a+b)² ≤ 2c²`, then count triples with `c ≤ H` (between `~log` and `~H` per the
two-sided depth bounds) to derive the `√n` law.
**Why now**: We have both the exponential upper and linear lower height bounds in
hand; only the counting integration across depths is missing.
**If true**: Confirms the precise Stern–Brocot-rate analogy claimed in the concept
and gives a certified complexity for Berggren enumeration.
**If false**: The true growth is non-uniform across branches (the B-branch dominates
via the Pell recurrence), suggesting a branch-weighted, non-`Θ(√n)` law.

### Direction 3: Word metric vs. Lorentz (Minkowski) reduction order
**Hypothesis**: A triple `v` is "Berggren-reduced" (its geodesic word is
lexicographically minimal in `{A,B,C}*`) **iff** `v` is the unique shortest vector,
in the `ℓ²` sense, of its `O(2,1;ℤ)`-orbit intersected with the positive light cone.
**Test**: Define a lexicographic order on words, transport it through
`evalAtRoot`, and compare against an explicit `ℓ²`-minimization over the orbit on
small examples (`c ≤ 100`) before attempting the general equivalence.
**Why now**: Freeness gives a canonical word per triple, so "lexicographically
minimal word" is now well-defined; the catalog's Lorentz-preservation lemmas supply
the orbit structure.
**If true**: Directly links the combinatorial word metric to indefinite-form
lattice reduction — the cryptographic payoff of the whole program.
**If false**: Word-metric geodesics and `ℓ²`-shortest vectors diverge, quantifying
the gap between combinatorial and metric reduction on indefinite forms.

### Direction 4: Primitivity preservation as a gcd cocycle
**Hypothesis**: `evalAtRoot w` is primitive (`gcd` of the legs `= 1`) for *every*
word `w`, and primitivity is exactly characterized by the light-cone membership plus
parity of the legs.
**Test**: Prove `Int.gcd (actGen g t).1 (actGen g t).2.1 = Int.gcd t.1 t.2.1` for
each generator `g` on good triples, then induct.
**Why now**: All generators are unimodular-up-to-sign on the relevant `2×2` minors;
the per-step invariance is a finite `omega`/`gcd` computation reusing `GoodTriple`.
**If true**: Upgrades every theorem here from "good triple" to "primitive triple",
matching the classical Berggren statement exactly.
**If false**: Some generator introduces a common factor, which would refine the
tree to a proper sublattice and change the `3^d` census.

### Direction 5: Quantum-walk mixing time from the depth bounds
**Hypothesis**: A continuous-time quantum walk on the Berggren tree (cf.
`Computation/QuantumBerggrenWalk.lean`) reaches a triple of hypotenuse `c` in time
`O(log c)`, matching the classical geodesic depth proved here.
**Test**: Combine `berggren_height_le_geom` (depth `≤ log₇(c/5)`) with the tree's
`3^d` level cardinality to bound the walk's hitting time on the depth-`d` shell.
**Why now**: The exact level count and the logarithmic depth bound are both new
this cycle and are exactly the two inputs a hitting-time argument needs.
**If true**: Bridges geodesic combinatorics to quantum search complexity on
arithmetic trees — a concrete cryptographic-hardness/quantum-speedup statement.
**If false**: The walk localizes (Anderson-type) on the indefinite-form tree,
revealing a quantum obstruction absent in the classical geodesic picture.
