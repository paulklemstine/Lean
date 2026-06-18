# Future Directions — Hilbert 16: A Combinatorial Unification of Ovals and Limit Cycles

## Synthesis

This cycle started from the catalog file `Geometry/OvalArrangement.lean`, which had
axiomatized the Harnack bound and the nesting forest as *structure fields* (honest
book-keeping, but proving nothing about the forest itself). We extended it in
`Geometry/Hilbert16Unification.lean` with theorems that are genuinely *derived*
from the parent/depth axioms of a `ConcNestingForest`, and we exposed a single
conceptual object underlying **both halves** of Hilbert's sixteenth problem.

The organizing idea is Grothendieck-style: forget the analytic origin of a curve
and remember only that a smooth real plane curve's ovals — and a planar polynomial
vector field's limit cycles — are *finite families of pairwise-disjoint Jordan
curves in the plane*. For such a family the relation "A is enclosed by B" is a
**forest order**. We proved, for an arbitrary nesting forest:

* `root_iff_depth_zero` — outermost = depth 0;
* `numRoots_eq_card_depth_zero`, `card_eq_numRoots_add_numEdges` — the forest Euler
  identity `#nodes = #roots + #edges` (i.e. `V = #components + E`);
* `numRoots_pos` — a nonempty system has an outermost curve (min-depth node);
* `exists_leaf` — a nonempty system has an innermost curve (max-depth node).

On the arithmetic side we proved `genus_eq_choose` (`g(d) = C(d-1,2)`), tied it to
the catalog's `OvalArrangement.genus`, and established the growth law
`harnackBound_succ`, monotonicity `harnackBound_mono`, and the classical values
(`H(2)=1`, `H(3)=2`, `H(6)=11`). Finally `chainForest`, `chainForest_numRoots`,
`chainForest_maxDepth`, and `chain_unifies` exhibit a tower of `m` nested curves as
one single-root depth-`(m-1)` object that is *literally the same* whether tagged as
algebraic ovals or as limit cycles.

## Results Summary

| Theorem | Statement |
|---|---|
| `genus_eq_choose` | `(d-1).choose 2 = (d-1)(d-2)/2` |
| `harnackBound_succ` | `H(d+2) = H(d+1) + d` |
| `harnackBound_mono` | `H` is monotone |
| `harnackBound_sextic` | `H(6) = 11` |
| `ConcNestingForest.root_iff_depth_zero` | outermost ⇔ depth 0 |
| `ConcNestingForest.card_eq_numRoots_add_numEdges` | `n = #roots + #edges` |
| `ConcNestingForest.numRoots_pos` | outermost curve exists |
| `ConcNestingForest.exists_leaf` | innermost curve exists |
| `chainForest_numRoots` / `chainForest_maxDepth` | concentric tower has 1 root, depth `m-1` |
| `chain_unifies` | oval-nest ≡ limit-cycle-tower as forests |

All main results compile with `sorry`-count 0 and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. The Gudkov–Rokhlin congruence for M-curves
Formalize the statement that for a maximal curve (an *M-curve*) of even degree
`d = 2k` with `p` even ovals and `n` odd ovals (in the depth-parity sense already
defined as `isOuter`/`isInner`), one has `p − n ≡ k² (mod 8)`. As a first
falsifiable milestone, *state* the congruence over a `ConcNestingForest` equipped
with a Harnack-saturation hypothesis (`numOvals = g + 1`) and verify it by `decide`
on every realizable arrangement up to degree 6 (so against Harnack's, Hilbert's,
and Gudkov's sextics).
**The key insight is** that our depth-parity functions `isOuter`/`isInner` already
give the even/odd oval split `p`/`n` purely combinatorially, so the congruence
becomes a checkable statement about the forest rather than about analytic geometry.
**Why now?** The forest Euler identity and the parity lemmas inherited from
`OvalArrangement.lean` mean the bookkeeping `p + n = numOvals` and the
depth-parity classification are already proven; only the mod-8 arithmetic remains.

### 2. A combinatorial realizability characterization of nesting forests
Conjecture: a rooted forest `F` is realizable as the oval arrangement of *some*
smooth real plane curve of degree `d` **iff** `#nodes ≤ C(d-1,2)+1` and
`depth(F) ≤ ⌊d/2⌋`. The `≤` constraints are already theorems (`harnack`,
`depth_bound`); the open content is the *converse* (sufficiency).
**The key insight is** that `card_eq_numRoots_add_numEdges` turns realizability into
a counting problem on `(#roots, #edges, depth)` triples, which is finite for each
`d` and therefore decidable to test.
**Why now?** With `numEdges` defined and the Euler identity proven, one can
enumerate candidate forests for small `d` by `decide` and look for the first
counterexample to naive sufficiency — exactly the falsifiable experiment needed to
sharpen the conjecture (Hilbert's degree-6 list is the classical test case).

### 3. Linear systems have no limit cycles (`H_ODE(1) = 0`), combinatorially
Build a `PlanarCircleSystem` model of the limit-cycle set of a degree-`n` planar
vector field and prove the degree-1 case: a *linear* system's limit-cycle forest is
empty (`n = 0`), so `numRoots = 0` and there is no leaf. This is the ODE analogue
of `harnackBound_conic` and the base case of the second part of Hilbert 16.
**The key insight is** that `exists_leaf` says any nonempty configuration must have
an innermost cycle, while index theory forbids one for a linear field; contraposing
`exists_leaf` converts the analytic non-existence into the combinatorial statement
`n = 0`.
**Why now?** `exists_leaf` and `numRoots_pos` are in hand, so the only missing piece
is the (small) index-theoretic input specialized to linear fields — a self-contained
lemma rather than the full Poincaré–Bendixson machinery.

### 4. Nested limit cycles enclose alternating equilibria (index ladder)
Conjecture: in a tower of `m` nested limit cycles (`chainForest m`), the Poincaré
index of the region between consecutive cycles alternates, forcing at least
`⌈m/2⌉` equilibria. Formalize the "leaf ⇒ enclosed equilibrium" step and iterate
along the chain using `chainForest_maxDepth`.
**The key insight is** that `chainForest` already linearizes the nesting into a
depth function `0,1,…,m-1`, so an index assigned by depth-parity (reusing
`isOuter`/`isInner`) yields the alternation as an arithmetic fact about `depth % 2`.
**Why now?** The chain's depth structure is fully proven (`chainForest_maxDepth`),
and the parity infrastructure is shared with Part 1, so the index ladder is a direct
combinatorial corollary awaiting only the single-cycle index axiom.

### 5. Refined Euler identity linking edges to genus
Conjecture: for a Harnack-saturated arrangement of degree `d`, the number of
parent-edges `numEdges` (nested ovals) is bounded by `⌊d/2⌋·numRoots`, sharpening
`card_eq_numRoots_add_numEdges` via the depth bound.
**The key insight is** that every non-root sits on a chain of length `≤ ⌊d/2⌋`
beneath some root, so `numEdges` is controlled by `#roots × depth`, converting the
two independent catalog bounds (`harnack`, `depth_bound`) into one inequality.
**Why now?** Both ingredient bounds are already theorems in `OvalArrangement.lean`,
and `numEdges`/`maxDepth` are now defined, so the product bound is the natural next
lemma to attempt and is immediately falsifiable by enumerating small forests.
