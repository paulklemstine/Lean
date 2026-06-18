# Future Directions — Hilbert 16: Topology of Algebraic Curves

## Synthesis

This cycle hardened and extended the Hilbert-16 corner of the catalog. Three
existing files (`Geometry/GenusFormula.lean`, `Geometry/OvalArrangement.lean`,
`Geometry/HamiltonianBridge.lean`) supplied the genus formula, the Harnack
bound, the abstract oval/forest combinatorics, and the Hamiltonian corridor from
algebraic curves (Part I) to limit cycles (Part II). Two new files build on top
of them:

- `Geometry/HarnackSharp.lean` recasts the genus as the binomial coefficient
  `g(d) = C(d-1,2)` and uses this to prove the Harnack bound is **monotone**,
  **strictly monotone for `d ≥ 2`**, and hence **injective on `{d ≥ 2}`** — i.e.
  the maximal oval count is a complete invariant of the degree in that range.
- `Geometry/OvalParity.lean` proves the **even/odd (outer/inner) partition** of a
  nesting forest is exact (`#even + #odd = n`), that the nesting relation is
  **acyclic** (no 2-cycles, no self-parent — depth is a genuine rank), and bridges
  to the genus: the number of *root* ovals obeys the Harnack bound `g+1` while the
  number of *nested* ovals is bounded by the genus `g` itself.

Along the way we repaired the project build (a `srcDir` mismatch and a stale
import in `HamiltonianBridge.lean`) and discharged the dangling `sorry` in
`Bridges/ArrowCurvature/Defs.lean`: the "Arrow–Curvature conjecture" as stated is
*vacuously* true because its hypothesis (every profile has positive Condorcet
curvature) is contradicted by the constant profile, whose majority relation is a
linear order with zero curvature.

## Results Summary

| Theorem | File | Content |
|---|---|---|
| `planeCurveGenus_eq_choose` | HarnackSharp | `g(d) = C(d-1,2)` |
| `planeCurveGenus_mono`, `harnackBound_mono` | HarnackSharp | monotonicity in degree |
| `planeCurveGenus_strictMonoFrom`, `harnackBound_strictMonoFrom` | HarnackSharp | strict growth for `d ≥ 2` |
| `harnackBound_inj_from` | HarnackSharp | Harnack bound determines the degree on `{d ≥ 2}` |
| `ConcNestingForest.outer_inner_partition` | OvalParity | `#even + #odd = n` |
| `ConcNestingForest.no_two_cycle`, `parent_ne_self` | OvalParity | acyclicity of nesting |
| `OvalArrangement.numRoots_le_harnack`, `nested_le_genus` | OvalParity | root/nested genus bounds |
| `arrow_curvature_conjecture` (sorry filled) | ArrowCurvature/Defs | vacuous via constant profile |

All main results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. Petrovskii's inequalities for the parity split

The exact partition `#even + #odd = n` proved in `OvalParity.lean` is only the
bookkeeping skeleton of the real theorem. Petrovskii showed that for a smooth
curve of *even* degree `2k`, the signed difference of even and odd ovals is
bounded: `-3k(k-1)/2 - 1 ≤ p - n ≤ 3k(k-1)/2 + 1`. Formalize an abstract
`PetrovskiiArrangement` structure carrying `p`, `n`, and these bounds, and prove
the degree-specialized corollaries (quartic, sextic) in the existing
`*_oval_bound` style. **The key insight is** that the even/odd split is not a
free combinatorial choice but is rigidly coupled to the degree through the
Euler-characteristic of the two complementary regions the real curve cuts ℝP²
into. **Why now?** The partition theorem and the `AbstractRealCurve`/`numRoots`
machinery already isolate `p` and `n` as first-class quantities, so the only
missing ingredient is the inequality datum — exactly the abstraction pattern the
catalog already uses for the Harnack bound.

### 2. Gudkov's congruence for M-curves

Define an *M-curve* as an arrangement attaining the Harnack bound
(`numOvals = genus + 1`), and formalize Gudkov–Rokhlin: for an M-curve of degree
`2k`, `p - n ≡ k² (mod 8)`. State it over `ZMod 8` (or as a `Nat` congruence to
dodge coercion friction) on an abstract structure, then derive the classical
sextic dichotomy `p - n ∈ {-1, 7}` becomes `≡ 1 (mod 8)`. **The key insight is**
that maximality (`= g+1`, the equality case of `card_le_genus_add_one`) is
exactly the hypothesis that promotes the soft inequality of Direction 1 into a
sharp arithmetic congruence — extremality buys rigidity. **Why now?** Strict
monotonicity (`harnackBound_strictMonoFrom`) already makes "attaining the bound"
a well-defined, degree-detecting predicate, giving a clean home for the M-curve
definition.

### 3. From "no 2-cycles" to full well-founded acyclicity

`no_two_cycle` and `parent_ne_self` rule out the shortest nesting cycles via the
`depth` rank. Upgrade this to the genuine forest theorem: the transitive closure
of `parent` is irreflexive, every oval reaches a root in exactly `depth` steps,
and therefore `maxDepth ≤ n - 1`. **The key insight is** that `depth` is a
strictly decreasing ℕ-valued rank along every parent edge, so iterating `parent`
is a well-founded recursion — acyclicity of *all* lengths follows from the single
local inequality `depth(parent i) < depth(i)`, with no planar topology needed.
**Why now?** The `child_depth`/`depth_parent_lt` API already gives the strict
rank; only an induction on `depth` (or `Nat` strong recursion) stands between the
current length-1/length-2 results and the global statement.

### 4. A quantitative weak Hilbert-16 bound through the Hamiltonian corridor

`HamiltonianBridge.lean` proves limit cycles of a perturbed Hamiltonian are
bounded by `C(d-1,2)+1`, but treats the perturbation abstractly. Sharpen it by
formalizing the Poincaré–Pontryagin–Melnikov picture at the level of *counting*:
the number of limit cycles born from a period annulus is at most the number of
zeros of the first Melnikov (Abelian) integral, itself a function whose zero
count is bounded by the degree of the perturbation via a Chebyshev/Descartes
argument. **The key insight is** that the genus bound on *ovals* and the bound on
*Melnikov zeros* are two shadows of one object — the dimension of the space of
Abelian integrals on the curve `H = c` — so the limit-cycle count inherits the
binomial bound `C(d-1,2)` already proved in `HarnackSharp.lean`. **Why now?** The
corridor degree → genus → Harnack → orbit count → limit-cycle count is already
laid in Lean; supplying a `MelnikovData` structure with a Descartes-style zero
bound turns the qualitative `limit_cycle_harnack_bound` into a quantitative,
falsifiable estimate.

### 5. Realizability: which forests occur?

The catalog bounds invariants of nesting forests but never asks the inverse
(Hilbert's actual question): which abstract `ConcNestingForest`s are realized by
a real curve of a given degree? Formalize the *codimension count* — a degree-`d`
curve has `C(d+2,2)-1` projective coefficients, and each prescribed oval/nesting
condition is a real-algebraic constraint — and prove a *necessary* counting
inequality: a realizable arrangement of depth `δ` and oval count `m` must satisfy
`m + (something in δ) ≤ C(d+2,2) - 1`. **The key insight is** that realizability
is governed by a dimension budget — the projective space of degree-`d` curves —
so impossibility results follow from pure parameter counting before any
construction is attempted. **Why now?** `depth_le_half_degree` and
`card_le_genus_add_one` already give the two axes (depth and count) that a
dimension inequality must constrain, making this the natural unifying superstructure
over Directions 1–3.
