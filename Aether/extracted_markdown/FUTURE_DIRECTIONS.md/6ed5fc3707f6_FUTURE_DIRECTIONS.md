# Future Directions: Proof Phase Transitions in Random Implicational Theories

## Synthesis

This cycle laid the missing foundation for the "proof phase transition" program. The
concept brief referenced an infrastructure (`ImplTheory`, `Derivable`,
`theory_extension_monotone`, `chain_derivable`, the barrier method) that did not yet
exist anywhere in the catalog — a genuine cold start. We therefore built it from
scratch in `Catalog/Logic/ImplicationalThreshold.lean`, modelling an implicational
theory as a binary relation `T : α → α → Prop` (the directed edge set) and derivability
as its reflexive–transitive closure `Relation.ReflTransGen T`. This thin layer turns
out to be exactly the right abstraction: it exposes derivability as a *monotone* set
function of the axioms and admits a clean *barrier* certificate for non-derivability.

The two structural pillars are now formal. `theory_extension_monotone` proves that
`Derivable` is monotone increasing in the axiom relation — the precise hypothesis of
Friedgut's sharp-threshold theorem, and the reason a threshold should exist at all. Its
dual, `barrier_not_derivable` (via the invariance lemma `derivable_mem_of_closed`),
proves that any forward-closed set separating source from target certifies
non-derivability; this is the lower-bound half that a sharp-threshold proof consumes at
low density. The cross-domain payoff is `chain_axiom_critical`: on the minimal-density
chain theory, deleting any single axiom destroys derivability of `0 → n`. Its proof
*combines* the two pillars — the deleted theory is a subtheory (monotonicity) and the
down-set `{x ≤ k}` is the unique barrier created by the deletion — giving the first
formal "criticality index 1" statement.

What was tricky rather than what failed: the inductions over `Relation.ReflTransGen`
needed the right monovariant (`a ≤ ·` for `derivable_succ_iff`) and a strengthened
target (`derivable 0 → m for all m ≤ n`) to feed `chain_le_derivable`; and `omega`
cannot see through `Set` membership, so barrier goals must be `simp only
[Set.mem_setOf_eq]`-normalised first. These are the load-bearing idioms the next team
should reuse. The structural insight is that the whole random-theory program factors
through *monotonicity ⊕ barriers*, and every direction below is an instance of pushing
one of those two pillars into a richer setting.

## Results Summary

- `theory_extension_monotone`: proved — derivability is a monotone increasing property
  of the axiom set, the structural hypothesis behind any sharp-threshold statement.
- `derivable_mem_of_closed`: proved — forward-closed sets are invariant along
  derivations (the engine behind every barrier argument).
- `barrier_not_derivable`: proved — a forward-closed separating set certifies
  non-derivability; the low-density lower-bound tool.
- `derivable_succ_iff`: proved — boundary characterization: the successor theory on `ℕ`
  derives `a → b` iff `a ≤ b` (the deterministic endpoint of the random model).
- `chain_derivable`: proved — the length-`n` chain theory derives `0 → n` with a
  derivation of length exactly `n` (the graph diameter), anchoring proof-length study.
- `chain_axiom_critical`: proved — every chain axiom has criticality index `1`; deleting
  any single edge breaks `0 → n`. The headline cross-concept theorem (monotonicity ⊕
  barrier).

## Research Directions

### Direction 1: Probabilistic sharp threshold for random implicational theories
**Hypothesis**: For the random theory on `Fin n` where each directed edge is present
independently with probability `p`, there is a critical `p*(n)` such that
`Pr[Derivable T 0 (n-1)]` jumps from `≤ ε` to `≥ 1-ε` over a window of width `o(1)`
around `p*`.
**Test**: Formalize the event `Derivable T 0 (n-1)` as a monotone Boolean function on
`{0,1}^{n²}` using `theory_extension_monotone` to discharge monotonicity, then feed it
to a (to-be-formalized) Friedgut/Bourgain coarse-threshold theorem; numerically, sample
the empirical curve for small `n` to estimate `p*(n) ≈ log n / n`.
**Why now**: Monotonicity is now a one-liner (`theory_extension_monotone`), so the only
remaining ingredient is the general threshold theorem itself.
**If true**: Connects formal proof theory to the random-graph threshold machinery and
makes "proof phase transition" a theorem rather than a metaphor.
**If false**: Would mean derivability has a *coarse* threshold, revealing a genuine
proof-theoretic obstruction (a "pivotal-axiom" cluster) absent in ordinary connectivity.

### Direction 2: Proof-length thresholds and the diameter bound
**Hypothesis**: Define `minDerivLen T a b` as the least `k` with a `k`-step derivation.
On the chain theory, `minDerivLen (chain n) 0 n = n`; for random theories above `p*`,
`minDerivLen 0 (n-1) = O(log n / log(np))` with high probability, versus `∞` below.
**Test**: First prove the deterministic core — `minDerivLen (chain n) 0 n = n` and the
general lower bound `minDerivLen T a b ≥ graph distance` — by refining
`chain_le_derivable` into a length-counting induction; then layer the random diameter
estimate.
**Why now**: `chain_derivable` already realizes the diameter-length derivation; the only
new infrastructure is a `ℕ`-valued length function compatible with `ReflTransGen`.
**If true**: Bridges to resolution proof complexity (implicational derivation = monotone
resolution), importing random-`k`-CNF lower bounds.
**If false**: Short proofs exist even below the derivability threshold, indicating
proof-length and existence thresholds genuinely decouple.

### Direction 3: Hypergraph (multi-premise) theories and threshold sharpening
**Hypothesis**: For `k`-premise implications `(a₁ ∧ … ∧ a_k) → b` (directed
hypergraphs), derivability is still monotone, and the critical window narrows as `k`
grows, mirroring random `k`-SAT.
**Test**: Generalize `Derivable` to a hypergraph closure (least fixed point of "all
premises derived ⇒ conclusion derivable"), re-prove `theory_extension_monotone` and
`barrier_not_derivable` (the barrier becomes "closed under any rule all of whose
premises lie in `S`"), then study the window width as a function of `k`.
**Why now**: The barrier lemma `derivable_mem_of_closed` is stated purely via
forward-closure, so it generalizes to hypergraph closure almost verbatim — the
template is already in place.
**If true**: Directly connects this framework to the most studied object in
probabilistic combinatorics (random SAT thresholds).
**If false**: A `k`-independent window would signal that single-conclusion intuition
fails for hypergraph reachability, a surprising structural fact.

### Direction 4: Giant derivability component and order-entropy non-analyticity
**Hypothesis**: The derivability preorder (atoms ordered by `Derivable`) collapses, at
`p = 1/n`, from many small antichains to a single giant strongly-connected derivability
class, and the log-number of linear extensions has a non-analytic point at `p*`.
**Test**: Define the SCC quotient of `Derivable` and prove the deterministic anchors
(chain ⇒ a total order of `n+1` classes), then transport the random-digraph giant-SCC
theorem at `p = 1/n` through the `Derivable`/SCC correspondence.
**Why now**: The clean `ImplTheory`/`Derivable` split isolates the random object (edges)
from the derived structure (the preorder), exactly the separation needed to invoke
random-digraph theory.
**If true**: Gives a thermodynamic ("giant component") reading of proof-theoretic
phase transitions with a measurable order parameter.
**If false**: The derivability order's transition is decoupled from the SCC transition,
isolating a purely proof-theoretic emergence phenomenon.

### Direction 5: The criticality-index distribution and backbone universality
**Hypothesis**: Generalize `chain_axiom_critical` to define `critIndex T a b e` = least
number of axioms (including `e`) whose removal kills `Derivable T a b`. Then (i) the
index is monotone — adding axioms can only lower existing indices — and (ii) at
criticality the index distribution follows a power law, the proof-theoretic analogue of
SAT backbones.
**Test**: First prove the monotonicity lemma (a corollary of `theory_extension_monotone`
plus `barrier_not_derivable`), confirming chain edges have index `1`; then compute the
empirical index distribution for random theories near `p*`.
**Why now**: `chain_axiom_critical` is exactly the `critIndex = 1` base case, and its
monotonicity-⊕-barrier proof scheme is the template for the general monotonicity lemma.
**If true**: Establishes a universal backbone/criticality law across theory ensembles.
**If false**: A non-power-law (e.g. bimodal) distribution would expose theory-specific
proof structure violating constraint-satisfaction universality.
