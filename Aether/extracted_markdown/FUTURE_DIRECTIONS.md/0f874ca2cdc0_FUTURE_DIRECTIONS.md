# Future Directions — Closure Systems as Tropical Idempotent Semimodules

These conjectures extend `Bridges/ClosureTropicalSemimodule.lean`, which encodes a
finite closure operator `C` by the family of **max-plus support functions**
`tropSupport K w = ⨆_{x ∈ K} w x` of its closed sets `K`, proves Tannaka-style
injectivity of `C ↦ supportFamily C`, and gives an explicit probe-based
reconstruction `generatedSystem G`. Each direction below is concrete, testable on
small finite types via `#eval`/`decide`, and falsifiable.

## 1. Tropical scalar-translation closure of the support semimodule

**Conjecture.** For every `K : Finset α` and constant `c : ℝ`, the translated
support function satisfies `tropSupport K (fun y => w y + (c : WithBot ℝ)) =
tropSupport K w + (c : WithBot ℝ)` (with `⊥ + c = ⊥`), and consequently the set
`{ tropSupport K | K is C-closed }` generates — under pointwise `⊔` and this
scalar translation — a genuine idempotent `Tropical ℝ`-semimodule whose lattice
of "tropical halfspaces" is order-isomorphic to the closed-set lattice of `C`.

**The key insight is** that closure under tropical *max* is already proved
(`tropSupport_union`), so the only missing semimodule axiom is closure under
*scalar translation*, which is exactly the statement that `Finset.sup` commutes
with adding a constant in `WithBot ℝ` — a finite, purely order-theoretic fact.

**Why now?** `tropSupport_union` and `tropSupport_mono_*` are in place, so the
semimodule skeleton exists; this direction completes it without touching the
in-flight tropical-polynomial Jacobian machinery in `Tropical/Canonical/Basic.lean`.

## 2. Closed sets = tropical halfspace intersections of the generated system

**Conjecture.** A finite set `K` is closed in `generatedSystem G` if and only if
`K` is an intersection of probe sets in `G` together with `univ`; equivalently,
`K` is closed iff `tropSupport K` is a finite pointwise infimum of "shifted
indicators" coming from `G`. Concretely: `ClClosed (generatedSystem G) K ↔
∃ S ⊆ G, K = S.inf id` (with the empty intersection giving `univ`).

**The key insight is** that `generatedCl_le_of_mem` and `probe_clClosed` already
pin down the meet-structure of the reconstructed closed sets, so the characterization
reduces to showing every fixed point of `generatedCl G` is reached as an explicit
finite meet — turning "closed set" into a decidable tropical-geometric predicate.

**Why now?** The reconstruction operator `generatedCl` and its idempotence are
proved; this direction upgrades the operator-level result to a *lattice-level*
structure theorem, the natural next layer.

## 3. Functoriality / Galois adjunction between probes and closures

**Conjecture.** The maps `G ↦ generatedSystem G` (probe families → closure
operators) and `C ↦ {closed sets of C}` (closure operators → set families) form
a Galois connection: `generatedSystem G` is the greatest closure making all of
`G` closed (already proved as `generatedCl_greatest`), and conversely
`generatedSystem (closedSets C) = C` for every `C`. Hence the reconstruction is a
*retraction* onto the image of the support-semimodule embedding.

**The key insight is** that `generatedCl_greatest` supplies one half of the
adjunction inequality and `supportFamily_injective` guarantees the embedding is
mono, so the round-trip identity `generatedSystem (closedSets C) = C` is the only
remaining obligation and follows from `cl_eq_of_sameClosed`.

**Why now?** Both adjoint candidates are already defined and one inequality is a
theorem; closing the loop yields a clean categorical statement that connects this
file to the Tannaka reconstruction theme of `Bridges/AlgebraEMLReconstruction.lean`.

## 4. Separation degree and a cryptographic probe-complexity bound

**Conjecture.** Define the *separation degree* of `C` as the least `d` such that
some family of `d` point-mass probes `tropDelta x` distinguishes every pair of
distinct closed sets. Then `d` equals the size of the largest antichain in the
closed-set lattice minus one, and any probe-based reconstruction needs at least
`d` evaluations — giving an information-theoretic lower bound on closure recovery.

**The key insight is** that `mem_iff_tropSupport_tropDelta` shows each point mass
recovers exactly one coordinate of membership, so the number of probes needed to
separate closed sets is a covering invariant of the lattice, directly computable
on finite `α`.

**Why now?** Point-mass separation (`tropSupport_injective`,
`mem_iff_tropSupport_tropDelta`) is already proved, so the quantitative refinement
to a minimal separating probe set is a finite optimization atop existing lemmas,
bridging to the post-quantum separator bounds in `AlgebraEMLReconstruction`.

## 5. Tropical-polynomial realization of support functions (ReLU bridge)

**Conjecture.** Every support function `tropSupport K` restricted to a single
weight coordinate `t ↦ tropSupport K (w + t · e_x)` is a univariate continuous
piecewise-linear function, hence has a canonical tropical-rational normal form in
the sense of `Tropical/Canonical/Basic.lean` (`TropicalPoly.eval`); moreover the
canonical form's slope set encodes membership `x ∈ K`.

**The key insight is** that `tropSupport K` is a finite max of affine maps in each
coordinate, which is precisely the `TropicalPoly` evaluation model already in the
catalog — so the closure-to-tropical bridge meets the existing ReLU/tropical
canonical-form development at a shared object.

**Why now?** With the support-function layer fully proved here and the univariate
canonical-form layer live in `Tropical/Canonical/Basic.lean`, this is the smallest
concrete connection between the two, and it would let closure reconstruction reuse
the certified equivalence decision procedure for ReLU networks.
