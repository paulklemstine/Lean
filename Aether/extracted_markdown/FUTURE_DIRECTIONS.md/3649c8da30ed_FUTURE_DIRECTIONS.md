# Future Directions — Discrete Dynamics of Self-Modification

## Synthesis

The foundational file `Catalog/Computation/SelfModifyingHalt.lean` established that a
self-modifying machine is *behaviourally* a standard machine over the product space
`P × S` (the simulation theorem `selfmod_halts_iff_standard`), so its halting problem
is Turing-equivalent to the classical one. The new file
`Catalog/Computation/SelfModDynamics.lean` pushes past behavioural equivalence into the
**dynamics** of the orbit itself, treating a never-halting (`Total`) machine as a
self-map `dyn : P × S → P × S` and transporting the elementary theory of finite
dynamical systems through the bridge lemma `run_eq_iter` (run = iterate of `dyn`).

Three structural facts emerge, two of them in tension:

1. **Finiteness makes prediction trivial.** `orbit_mem_initial_segment` confines every
   iterate to the first `card (P × S)` steps, so `selfmod_reaches_bad_iff_bounded`
   turns any infinite-horizon orbit property into a bounded search. On bounded memory,
   self-modification adds *no* analytic difficulty — a sharp counterpoint to the
   undecidability of the unbounded case.
2. **Finiteness forces self-reproduction.** `selfmod_quine_cycle` shows a total finite
   machine re-enters a previously visited configuration within `card` steps: a
   finitary Kleene/quine fixed point, answering Future Direction #2 of the foundation.
3. **Reachability — not step complexity — is where control fails.**
   `alignment_obstruction` shows that under strong connectivity a single misaligned
   state poisons the whole space: there is no nonempty forward-invariant safe region,
   so no state-based monitor can keep the agent aligned (Future Direction #4).

These results pin the difficulty of "alignment" squarely on the *reachability
relation* of the dynamics, not on the complexity of the step map.

## Results Summary

| Theorem | Statement |
|---|---|
| `dyn_eventually_periodic` | Every point of a finite self-map reaches a periodic point within `card` steps, with period `≤ card`. |
| `orbit_mem_initial_segment` | Every iterate already occurs among the first `card+1` iterates. |
| `selfmod_quine_cycle` | A total finite self-modifying machine reproduces a past configuration within `card (P×S)` steps and runs forever. |
| `selfmod_reaches_bad_iff_bounded` | "Ever reaches a bad config" reduces to a length-`card` search. |
| `alignment_obstruction` / `selfmod_alignment_obstruction` | Strong connectivity + one bad state ⇒ no nonempty safe region; every start reaches a bad state. |

All theorems compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, `Quot.sound`.

## Falsifiable Research Directions

### 1. Tight cycle-length bounds for linear self-modification
The quine-cycle bound `card (P × S)` is generic and almost never tight. Conjecture:
for *affine* self-modification on `P × S = (ZMod n)^d` — step `c ↦ Ac + b` for fixed
`A, b` — the maximal cycle length equals the multiplicative order of `A` in
`GL_d(ZMod n)` (times the additive contribution of `b`), which is exponentially
smaller than `n^d` for generic `A`. **The key insight is** that affine dynamics
factor through group theory, so cycle length is an *order* computation, not a search.
**Why now?** `selfmod_quine_cycle` already isolates "cycle length" as the right
invariant and Mathlib's `ZMod`, `Matrix`, and `orderOf` APIs make the affine case
fully formalizable today. *Falsifier:* exhibit an affine `A` whose realized cycle
length strictly exceeds `orderOf A` times the `b`-period.

### 2. Minimal reachability hypothesis for the alignment obstruction
`alignment_obstruction` assumes full strong connectivity, which is stronger than
needed. Conjecture: the obstruction survives under the strictly weaker hypothesis
"every configuration reaches *some* configuration from which a bad state is
reachable" (a single recurrent bad attractor in the condensation graph). **The key
insight is** that only the *terminal strongly connected component* of the orbit graph
matters, so alignment is possible iff there exists a bad-free terminal component.
**Why now?** The proof currently routes through `forwardInvariant_eq_univ_of_stronglyConnected`;
replacing "= univ" with "contains the terminal SCC" is a localizable edit, and the
condensation of a finite relation is elementary to define. *Falsifier:* a finite
machine with a bad-free terminal SCC yet no nonempty forward-invariant safe region.

### 3. Decidability lifts to a quantitative complexity bound
`selfmod_reaches_bad_iff_bounded` proves an *iff* with a bounded search but stops short
of a `Decidable` instance and a cost. Conjecture: for a `Total` machine on `P × S` the
predicate "the run ever enters `R`" is decidable in `O(card · cost(step))` time and
`O(card · log card)` space — a Floyd cycle-detection bound — and this is optimal.
**The key insight is** that orbit confinement means you never need more than `card`
simulated steps, so the halting/safety analysis is *linear* in the memory size despite
self-modification. **Why now?** The mathematical iff is already formalized; promoting it
to `Decidable` and proving the step count is a direct application of
`orbit_mem_initial_segment`. *Falsifier:* a family of total machines forcing
`ω(card)` step simulations to decide an orbit property.

### 4. Oracle stratification by self-modification depth
Generalize `Total` to a *depth-`k`* machine that may rewrite its program at most `k`
times before becoming fixed. Conjecture: the halting problem for depth-`k` machines is
`Σ⁰₁`-complete for every `k ≥ 0` (no climb in the arithmetical hierarchy), but the
*orbit-eventual-periodicity radius* on finite memory grows like `card^{k+1}`,
separating the depth levels *quantitatively* even though they coincide
*degree-theoretically*. **The key insight is** that self-modification depth is a
*resource* parameter (refining `card`-bounds) rather than a *degree* parameter — it
cannot cross the bridge that `selfmod_halts_iff_standard` already collapses. **Why now?**
This directly fuses the catalog's `OracleBurden` jump hierarchy with the new dynamics
layer; the depth filtration is definable on top of the existing `SelfModMachine`.
*Falsifier:* a depth-`1` machine whose halting set is properly `Σ⁰₂`, or a depth-`k`
family whose periodicity radius stays `O(card)`.

### 5. Probabilistic quine cycles and absorbing alignment
Replace the deterministic `dyn` by a Markov kernel on the finite space `P × S`
(stochastic code rewriting, as in real learning/malware systems). Conjecture: the
deterministic quine cycle becomes a *recurrent class*, and the alignment obstruction
becomes "if the unique recurrent class contains a bad state, the agent visits it
infinitely often almost surely". **The key insight is** that `IsPeriodic` is the `1`-step
specialization of "positive-recurrent communicating class", so the whole Section-2 theory
is the deterministic shadow of finite Markov-chain ergodics. **Why now?** Mathlib's
growing probability/finite-state-Markov infrastructure makes the stochastic lift feasible,
and the deterministic theorems give exact targets to specialize back to. *Falsifier:* a
finite kernel whose unique recurrent class contains a bad state yet which avoids that
state with positive probability from some start.
