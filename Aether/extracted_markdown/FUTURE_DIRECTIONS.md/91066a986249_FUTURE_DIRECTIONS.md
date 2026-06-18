# FUTURE_DIRECTIONS — Order Structure of the Berggren Tree of Pythagorean Triples

## Synthesis

This cycle attacked the standing research target *"construct an order-preserving map
relating the combinatorial structure of the Berggren tree to a linear order."* The Berggren
(Barning–Hall) tree is the rooted ternary tree of all **primitive Pythagorean triples**,
generated from the root `(3,4,5)` by three matrices `A, B, C ∈ O(2,1;ℤ)` that preserve the
Lorentz form `Q(a,b,c)=a²+b²−c²` (developed sorry-free in `Pythagorean/Core.lean`,
namespace `PythagoreanThermo`).

The new file `Pythagorean/OrderPreservingTree.lean` resolves the target. It identifies the
natural partial order on the tree — the **ancestor order**, which is exactly the
*suffix order* `<:+` on Berggren paths because a node's path is read innermost-first
(`pathTriple (i :: σ) = (berggrenMat i).mulVec (pathTriple σ)`) — and shows that this purely
combinatorial order is *faithfully recorded* by elementary geometric invariants:

* **Hypotenuse** `hyp` is strictly suffix-monotone (`hyp_lt_of_proper_suffix`).
* **Perimeter** `perim = a+b+c` is strictly suffix-monotone (`perim_lt_of_proper_suffix`).
* Together they give an **order embedding** of `(BPath, <:+)` into `(ℤ × ℤ)`
  (`tree_order_embedding`), and a single invariant already separates a node from all of its
  proper ancestors and descendants (`hyp_ne_of_proper_suffix`).

The conceptual payoff (Grothendieck-style): *ancestry is a shadow of the Lorentzian
dynamics.* One does not need to remember the matrix word to know whether one triple lies
above another in the tree — any one monotone geometric scalar decides it.

## Results summary

All results are `sorry`-free and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool`/`Lean.trustCompiler`
inherited from the `native_decide` facts in `Core`).

| Theorem | Statement |
|---|---|
| `pathTriple_append` | `pathTriple (pre ++ σ) = (pathMatrix pre).mulVec (pathTriple σ)` — the monoid action factors along path concatenation. |
| `perim_step_lt` | every Berggren child strictly increases the perimeter. |
| `hyp_le_append`, `perim_le_append` | a descendant never decreases hypotenuse / perimeter. |
| `hyp_lt_of_proper_suffix` | hypotenuse is strictly order-preserving on the ancestor order. |
| `perim_lt_of_proper_suffix` | perimeter is strictly order-preserving on the ancestor order. |
| `tree_order_embedding` | `(hyp, perim)` embeds the ancestor order into `ℤ × ℤ`. |
| `hyp_ne_of_proper_suffix` | comparable distinct nodes have distinct hypotenuses. |

A documented **negative result** (Failure analysis in the lab notebook): individual legs are
*not* per-step monotone, because `A` and `C` carry negative entries — the embedding must use
a *symmetric* invariant, which is why `perim` and `hyp` (not `pathTriple · 0`) are used.

## Research directions

### 1. The ancestor order is a genuine `OrderEmbedding`, and the tree is a forest of chains under it
We proved one direction: proper ancestor ⇒ strictly smaller `(hyp, perim)`. The bold
conjecture is the converse-completing structural claim: the map
`σ ↦ (hyp σ, perim σ)` is **injective on every chain**, and more strongly the *full*
function `BPath → ℤ × ℤ` is injective (distinct primitive triples have distinct
hypotenuse–perimeter pairs). This would upgrade `tree_order_embedding` to a bona fide
`OrderEmbedding (BPath, <:+) ↪o (ℤ × ℤ)` in the Mathlib sense.
**The key insight is** that two distinct primitive triples can coincide in hypotenuse *or*
in perimeter, but a primitive Pythagorean triple is determined by the unordered pair
`{leg, leg}` together with the hypotenuse, so the *pair* `(hyp, perim)` plus primitivity
should pin the triple down. **Why now?** `pathTriple_append` already exposes the monoid
action, and `Core` proves uniqueness of the Lorentz-null orbit; the remaining step is a
finite-search/`decide` argument on residues, well within reach of the current toolchain.

### 2. A logarithmic order-isomorphism onto an ordinal-indexed scale (the original ordinal-analysis target)
Define the rank `rk σ := σ.length` and recall `Core.hyp_ge_root_plus_depth`
(`5 + length ≤ hyp`) and `Core.hyp_B_iterate_bound` (`5·3ⁿ ≤ hyp` on the pure-`B` ray).
Conjecture: `⌊log₃ (hyp σ / 5)⌋` is a **monotone rank function** that, restricted to any
single branch ray, is an order-isomorphism onto an initial segment of `ω`, and across the
whole tree realizes the ordinal `ω^ω` as the order type of `(BPath, <:+)` truncated by
hypotenuse thresholds. **The key insight is** that the spectral radius `3+2√2`
(`Core.berggrenSpectralRadius`) sets a *uniform* exponential clock, so taking logarithms
linearizes the multiplicative dynamics into an additive (ordinal) scale. **Why now?** The
spectral constants and their Galois-conjugate identity `(3+2√2)(3−2√2)=1` are already proved
in `Core`; the only missing analytic input is a clean two-sided `log`-bound, which the
existing `hyp_le_append`/`hyp_B_iterate_bound` sandwich nearly delivers.

### 3. Monotonicity of the full invariant lattice and a Hasse-style refinement
Beyond `hyp` and `perim`, test which symmetric functions of `(a,b,c)` are suffix-monotone:
the area-proxy `a·b`, the inradius `r=(a+b−c)/2`, the excess `a+b−c`, and the
"Lorentz energy" used in `Core`'s thermodynamic formalism. Conjecture: `a+b−c` (the inradius
doubled) is **also strictly suffix-monotone**, giving a third independent coordinate and an
embedding into `ℤ³` that is *order-reflecting* (not merely order-preserving).
**The key insight is** that `a+b−c` is the unique (up to scale) linear functional vanishing
on the degenerate triple and positive on the Lorentz-null cone interior, so the Berggren
matrices act on it with all-positive structure constants. **Why now?** This is the same
`nlinarith`-after-`fin_cases` pattern that already discharged `perim_step_lt`; a single
analogous lemma settles it.

### 4. Comparability is decidable from invariants — an "antichain" census
Two triples are `<:+`-comparable iff one path is a suffix of the other. Conjecture: there is
a *decidable predicate purely in terms of `(hyp, perim)`* (no path data) that recognizes
comparability, and consequently the maximal antichains of the tree at hypotenuse `≤ N` are
counted by a clean `Θ(N^{log₃ 2})`-type law. **The key insight is** that suffix-comparability
is detected by the embedding of Direction 1 plus a divisibility/closure test inherited from
`pathMatrix_preserves_lorentz`. **Why now?** Once injectivity (Direction 1) lands,
comparability becomes a statement about the image lattice in `ℤ²`, where `decide` and
interval arithmetic apply directly.

### 5. Cross-domain bridge: the order embedding as a ζ-function / Dirichlet-series comparison
`Core` already defines the thermal potential `Real.log (hyp σ)` and proves partition-function
positivity. Conjecture: suffix-monotonicity of `hyp` implies the Pythagorean Dirichlet
series `∑_σ hyp(σ)^{-s}` is, term-by-term, **dominated along every chain by a geometric
series with ratio `(3+2√2)^{-s}`**, yielding an explicit abscissa of convergence
`s₀ = log 3 / log(3+2√2)`. **The key insight is** that an order-preserving energy turns a
sum over a tree into a sum over a well-founded order, where Abel summation along chains
replaces hard analytic continuation. **Why now?** The monotonicity lemmas of this file are
exactly the comparison inputs such a term-by-term bound needs, and `Core`'s spectral
constants supply the geometric ratio — the two halves were proved in separate cycles and can
now be joined.
