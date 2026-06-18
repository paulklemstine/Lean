# Future Directions: Closure Operators as Monotone Computations

The file `Bridges/ClosureComputationGaloisBridge.lean` establishes a Galois-style
bridge between the order-theoretic semantics of `SetClosureOperator` (from
`Bridges/AlgebraEMLReconstruction.lean`) and an explicit finite computation model
of inflationary fixed-point iteration. The proved core is fivefold: a finite
Knaster–Tarski theorem (`closure_eq_sInter_postFixed`), a least-closed-set
characterization (`closure_least_closed`), a finite convergence bound on
inflationary iteration (`finite_iterate_stabilizes`), a termination certificate
for underapproximating steps (`iterate_eq_closure_of_underapprox`), and a probe
extensionality / identification theorem (`closure_ext_of_probeResponse`). The
following directions extend this skeleton toward a full closure-computation
complexity theory.

## Direction 1: Tight worst-case convergence and a complexity-class separation

`finite_iterate_stabilizes` proves termination within `Fintype.card α` strict
growth steps but does not certify that the bound is *attained*. The next step is
to construct, for each `n`, an inflationary step on a type of cardinality `n`
whose iteration needs exactly `n` strict inclusions before stabilizing (e.g. a
"shift by one" operator that adds a single fresh element per round), proving the
bound is sharp, and then to lower-bound the number of `step` evaluations any
iterative closure reconstructor must perform. **The key insight is that the
strict-growth counting argument behind `finite_iterate_stabilizes` is not merely
an upper bound but a potential function whose extremal trajectories realize a
genuine `Θ(card α)` query lower bound for closure reconstruction.** Why now:
the potential function `(step^[·] s).ncard` is already isolated in the proof, so
turning the existence bound into a matching adversary construction is a direct,
falsifiable next move that converts the bridge into a complexity statement.

## Direction 2: Galois adjunction between step semantics and closed-set lattices

The bridge currently links a *single* closure operator to *its* iteration. The
structural upgrade is to make the correspondence functorial: order the
inflationary monotone step operators by pointwise inclusion, order closure
operators by their closed-set lattices, and prove that "take the least fixed
point above each seed" is the upper adjoint of "restrict a closure to a single
step", yielding an actual Galois connection (hence the title's promise). **The
key insight is that `iterate_eq_closure_of_underapprox` is exactly the unit/counit
inequality of a Galois connection in disguise: underapproximation is the order
relation and closedness is the fixed-point condition that the adjunction
collapses.** Why now: both orders are already definable from existing catalog
primitives (`PostFixedAbove`, `ClosedSet`), and Mathlib's `GaloisConnection` API
makes the adjunction laws mechanically checkable once the two orders are pinned
down.

## Direction 3: Probe families as a learning / identification protocol with sample bounds

`closure_ext_of_probeResponse` shows that *all* subset-probe responses determine
a closure operator, but uses the full powerset of probes. The research target is
a *separating finite probe family*: identify the minimal collection of probe sets
(ideally `card α` singleton probes per seed) whose responses already pin down the
operator, and prove an identification theorem with an explicit query budget,
connecting to the `ProbeFamily` / `ClosureStableProbe` machinery of
`Bridges/AlgebraEMLClosureComputation.lean`. **The key insight is that singleton
probes `{x}` reduce membership queries to a `card α × card α` response matrix, so
closure identification is equivalent to learning a monotone Boolean matrix, with
the closure axioms acting as consistency constraints that shrink the hypothesis
space.** Why now: the extensionality proof already only needs reflexive probes,
so weakening the hypothesis from "all probes" to "a separating family" is an
incremental, testable strengthening rather than a new theory.

## Direction 4: Failure boundary — dropping finiteness or idempotence

The development is falsifiable precisely at its hypotheses, and mapping the
failure boundary is itself a result. Concretely: exhibit an inflationary monotone
step on `ℕ` (e.g. `s ↦ s ∪ {sup s + 1}`) whose iteration never stabilizes,
formally proving `finite_iterate_stabilizes` is false without `[Fintype α]`; and
exhibit an extensive monotone but *non-idempotent* operator whose post-fixed-point
intersection differs from its single application, breaking
`closure_eq_sInter_postFixed`. **The key insight is that finiteness and
idempotence are not cosmetic regularity assumptions but the two independent
load-bearing axioms, and isolating one counterexample per axiom certifies the
theorem package is minimal.** Why now: the proofs make the use of each hypothesis
explicit (`ncard` bound for finiteness, `cl.idempotent` for the Knaster–Tarski
membership), so the counterexamples can be aimed directly at the single step that
consumes each assumption.

## Direction 5: Extraction of a verified closure-reconstruction algorithm

The termination certificate `iterate_eq_closure_of_underapprox` is the
correctness core of an actual algorithm: iterate an underapproximating
`Finset`-valued step, test closedness once, and return. The direction is to port
the theory from `Set α` to `Finset α` (using the catalog's `FiniteClosureSystem`
from `Bridges/AlgebraicEMLThermodynamicFormalism.lean`), produce a
`Decidable`/computable `closure` function, and prove it equals `cl s` with a
`card α`-step runtime bound, yielding a kernel-checked closure-computation
procedure. **The key insight is that the bridge already supplies both halves of
program correctness — partial correctness from `iterate_subset_closure` plus
`closure_least_closed`, and termination from `finite_iterate_stabilizes` — so the
remaining work is purely the `Set`-to-`Finset` transport, not new mathematics.**
Why now: `FiniteClosureSystem` is an existing catalog structure with exactly the
extensive/monotone/idempotent fields needed, making the transport a matter of
re-deriving the five lemmas over a decidable finite lattice with `Finset.card` in
place of `Set.ncard`.
