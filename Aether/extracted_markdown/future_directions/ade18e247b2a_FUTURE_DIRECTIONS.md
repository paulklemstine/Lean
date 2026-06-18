# Future Directions: The Logic–Physics Bridge

## Synthesis

This cycle laid the *formal* foundations for the logic–physics bridge — the precise
correspondence between **physical realizability** (a body of laws admits a concrete state
realizing it; it "has a model") and **logical consistency** (the laws do not entail a
contradiction). Two self-contained Lean files were produced, each fully proved (`sorry = 0`,
only the standard `propext` / `Classical.choice` / `Quot.sound` axioms — and in one case
*no* axioms at all):

* `Catalog/Bridges/LogicPhysicsBridge.lean` — the **static** bridge. The headline theorem
  `realizable_iff_consistent` turns the slogan *"consistency is existence"* into a one-line,
  domain-agnostic biconditional. From it follow, almost for free, the structural
  meta-theorems that make the bridge a usable calculus: the realizability/⊥-entailment
  duality (`entails_false_iff_not_realizable`), the principle of explosion
  (`not_realizable_entails_all`), monotonicity under weakening (`realizable_of_subset`), a
  syntactic no-go (`contradiction_not_realizable`), and full **compositionality** across
  independent subsystems (`product_realizable_iff`, which depends on *no axioms*). A concrete
  physics instantiation (discrete energy levels) certifies the framework is non-vacuous,
  including a genuine physical no-go (`two_levels_not_realizable`).

* `Catalog/Bridges/TemporalRealizability.lean` — the **dynamical** bridge. The theorem
  `serial_realizable` shows a dynamical law with a nonempty initial set and a *serial* step
  relation always admits an infinite trajectory: physically, a non-stuck evolution law
  evolves forever; logically, a serial Kripke frame (modal axiom **D**) carries an infinite
  path. `temporal_eq_static` proves temporal realizability is literally an *instance* of the
  static bridge, and `serial_trajectoryTheory_consistent` composes the two.

The unifying discovery is *mathematical economy*: the correspondence rests on exactly two
nonconstructive primitives and nothing else — classical logic for the static half and
`Classical.choice` for the temporal half — while compositionality is purely structural and
needs neither. The axiom audit (`#print axioms`) is not an artifact of the proofs but a
structural boundary between *existence* (static) and *eternal evolution* (temporal).

## Results Summary

| Theorem | File | Content | Axioms |
|---|---|---|---|
| `realizable_iff_consistent` | LogicPhysicsBridge | realizable ⇔ consistent | propext, choice, Quot.sound |
| `entails_false_iff_not_realizable` | LogicPhysicsBridge | entails ⊥ ⇔ not realizable | classical |
| `not_realizable_entails_all` | LogicPhysicsBridge | explosion for worlds | none-classical |
| `realizable_of_subset` | LogicPhysicsBridge | monotonicity under weakening | none |
| `product_realizable_iff` | LogicPhysicsBridge | compositionality of subsystems | **none** |
| `contradiction_not_realizable` | LogicPhysicsBridge | law + its negation has no model | none |
| `atLevel_realizable`, `two_levels_not_realizable` | LogicPhysicsBridge | physics non-vacuity + no-go | standard |
| `serial_realizable` | TemporalRealizability | serial law ⇒ eternal trajectory | Classical.choice |
| `temporal_eq_static` | TemporalRealizability | temporal = static realizability | standard |
| `serial_trajectoryTheory_consistent` | TemporalRealizability | composed bridge | standard |

## Bold, Falsifiable Research Directions

### 1. Compactness as the bridge for *infinitary* law systems

Conjecture: for a theory `T` over a state space carrying a topology in which each law's
solution set `{s | L s}` is closed, `Realizable T` holds **iff every finite subtheory is
realizable** — a topological/compactness version of the bridge. Falsifiable: exhibit a
theory all of whose finite fragments are realizable but whose full conjunction is not, over
a *compact* state space — that would refute it; over a non-compact space it should fail and
pinpoint compactness as exactly the missing hypothesis.
The key insight is that `realizable_iff_consistent` already reduces realizability to a
*single* non-emptiness statement (`⋂_{L ∈ T} {s | L s} ≠ ∅`), so the only obstacle to going
infinitary is a finite-intersection property — compactness is not an analogy here but the
literal mechanism.
Why now? `LogicPhysicsBridge.lean` isolates `Realizable` as a clean `∃`-statement, and
Mathlib's `Set` / `Filter` / `IsCompact.nonempty_iInter_of_directed`-style API is mature, so
the lift is a direct next step rather than a fresh foundation.

### 2. A quantitative bridge: realizability *degree* and constraint entropy

Conjecture: when the state space is a `Fintype`, define the *realizability degree* of `T` as
the number of models `Fintype.card {s // Satisfies s T}`; then this degree is a monotone,
submodular function of the law set, and its logarithm (a "constraint entropy") is
**additive over the product construction** `product T T'`, with the count being an exact
product `card(models T) * card(models T')`. Falsifiable by a finite `decide` search: any
small-state counterexample to submodularity or to product-additivity refutes it.
The key insight is that `product_realizable_iff` — proved here with *no axioms* — is the
qualitative shadow of an exact *counting* identity (models of a product = product of model
counts), turning the Boolean bridge into a measure-theoretic one.
Why now? The catalog already connects log-cardinality to entropy
(`Catalog/Physics/Bridge.lean`, `uniform_shannon_eq_tropical`); composing that bridge with
`product_realizable_iff` makes the entropy reading immediate and `decide`-testable.

### 3. The temporal bridge with *fairness*: seriality is not enough for liveness

Conjecture: strengthening `serial_realizable`, a dynamics whose step relation is serial
*and* finitely branching admits a trajectory hitting every "recurrently enabled" state
infinitely often (a fair/liveness trajectory) **iff** no reachable state is a livelock trap;
and this fair-realizability is again an instance of static `Realizable` over an enriched
trajectory theory. Falsifiable: build a finitely-branching serial dynamics with a livelock
and show no fair trajectory exists, matching the predicted trap characterization.
The key insight is that `temporal_eq_static` shows liveness is *not* a new kind of bridge —
it is the static bridge applied to a richer law ("the trajectory is fair"), so fairness
should be a definitional enrichment of `trajectoryTheory`, not a new theory.
Why now? `serial_realizable` already builds the infinite path by `Nat.rec` over a chosen
successor; replacing the arbitrary choice by a round-robin selector is a small constructive
delta, and the modal-frame vocabulary is already in place via the `Serial` predicate.

### 4. Reverse mathematics of the bridge: how much choice is *necessary*?

Conjecture: the static bridge `realizable_iff_consistent` is provable constructively (no
classical axioms) **exactly** when the state space is searchable/decidable, while the
temporal bridge `serial_realizable` is equivalent over a constructive base to a weak
dependent-choice principle (`DC₀`) — i.e. choice is genuinely load-bearing for time but
eliminable for static, decidable worlds. Falsifiable in the strongest sense: a constructive
proof of `serial_realizable` without any choice on a non-decidable space would refute the
temporal half.
The key insight is that the axiom audit in this cycle (`product_realizable_iff` needs *no*
axioms; the static bridge needs only classical logic; `serial_realizable` needs
`Classical.choice`) is not an artifact of our particular proofs but a structural boundary
between *existence* and *eternal evolution*.
Why now? The `#print axioms` profile is already pinned for every theorem, giving a precise,
checkable target for the reverse-mathematics classification.

### 5. Closing the Carmichael composite tail via a realizability reformulation

Conjecture: the remaining open `sorry` in `Catalog/Shared/CarmichaelProof.lean` (every
composite `n > 10000` has a primitive Fibonacci divisor) can be recast as a *realizability*
statement — "the divisor-constraint theory of `F(n)` is realizable for all large `n`" — and
discharged by the cyclotomic lower bound `|Φ_n(φ, ψ)| → ∞`, which dominates the contribution
of the proper divisors. Falsifiable in the strongest sense: a single composite `n > 10000`
with no primitive divisor would refute Carmichael outright (none is expected; the formalized
growth bound is what is actually missing).
The key insight is that primitive-divisor existence is a special case of the
*compositionality* no-go (direction 1 / `product_realizable_iff`): the primitive part is
exactly the "law not entailed by any proper-divisor law", so the bridge language reframes a
number-theoretic gap as a model-existence gap.
Why now? The finite case `n ≤ 10000` is already decidable, and reducing the problem to a
single growth estimate means the bridge vocabulary clarifies precisely which estimate to
formalize next.
