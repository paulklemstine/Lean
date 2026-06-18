# Future Directions — Unique Games, MAX-CUT, and SDP Gaps

## Synthesis

This cycle attacked the Unique Games Conjecture (UGC) from the only angle that
yields *unconditional, machine-checked* mathematics: the structural lower bound
on game value that every soundness analysis silently relies on. The file
`Applications/UniqueGamesMaxCut.lean` formalizes two-prover unique games on
`Fin n` vertices with `Fin k` labels, where each edge `(u, v)` carries a
permutation constraint `σ` satisfied by a labeling `f` iff `f v = σ (f u)`.

The centerpiece, `exists_value_ge`, proves that **every** unique game with
`k ≥ 1` labels admits a labeling satisfying at least a `1/k` fraction of its
edges (`edges.card ≤ k * satCount G f`). The engine is `edge_frac`: an exact
cardinality identity `(#satisfying labelings) * k = k ^ n` proved by an explicit
`Function.update`-based partition, which converts the probabilistic statement
"a random labeling satisfies each edge with probability `1/k`" into pure
counting — no real-valued expectation required. Specializing to `k = 2` with
the swap constraint, `maxcut_half` recovers the classical theorem that every
graph has a cut crossing at least half of its edges. This is a genuine
cross-domain bridge: the same averaging argument that floors UGC soundness is
the MAX-CUT half-edges bound, and it connects to the catalog's existing
expander/probabilistic-method material (e.g. `Speculative/ProbabilisticMethod`,
`Algebra/ExpanderWalk`) where double-counting and second-moment arguments recur.

## Results Summary

- `satCount_le`: the value of any labeling is at most the number of edges.
- `edge_frac`: a *proper* edge is satisfied by exactly a `1/k` fraction of all
  `k ^ n` labelings — the exact combinatorial heart of the soundness floor.
- `exists_value_ge`: the random-assignment value floor `edges/k`, unconditional.
- `maxcut_sat_iff`: MAX-CUT edges are satisfied iff their endpoints differ.
- `maxcut_half`: every loop-free graph has a cut with `≥ half` its edges.

All five compile with `sorry = 0` and depend only on `propext`,
`Classical.choice`, and `Quot.sound`.

## Falsifiable Research Directions

### 1. The value floor is *tight*, and tightness needs the right gadget.

For each `k` there is a unique game whose optimum value equals exactly `1/k`,
witnessing that `exists_value_ge` cannot be improved. **The key insight is**
that the worst case is the "anti-consistent" instance: take the complete
constraint graph on `k+1` vertices with constraints that admit no globally
consistent labeling, forcing every labeling to disagree on a `1 - 1/k`
fraction. **Why now?** We already have `edge_frac` giving the per-edge
`1/k` average exactly; proving a matching *upper* bound `satCount G f * k ≤ edges.card`
for a specific gadget closes the analysis into an exact `value = 1/k` theorem and
is the smallest possible next step. Falsifiable: if no `k`-label instance attains
`1/k`, the conjectured tightness gadget is wrong.

### 2. Parallel repetition shrinks the soundness gap multiplicatively.

Define the tensor/product of two unique games and prove that the value of the
`t`-fold product is at most `value^c·t` for some constant `c > 0` (a weak,
formalizable shadow of Raz's parallel repetition). **The key insight is** that
a labeling of the product factors through coordinate projections, so satisfied
product-edges are (sub)multiplicative in the factors — a counting inequality, not
an information-theoretic one. **Why now?** Our `Sat`/`satCount` API already treats
edges as an indexed family; the product game is just `edges₁ ×ˢ edges₂` with the
product permutation, so the statement is expressible immediately and the easy
direction (value of product `≤` value of one factor) is within reach.

### 3. Random assignment is optimal up to a constant for *expander* unique games.

If the constraint graph is a spectral expander, no labeling beats the `1/k`
floor by more than a factor depending on the spectral gap. **The key insight is**
that the satisfied-edge count is a quadratic form in the labeling's indicator
vectors, so the expander mixing lemma bounds its deviation from the `1/k` mean.
**Why now?** The catalog already contains expander machinery
(`Algebra/ExpanderWalk/Amplification`, `Algebra/ClassicalGroupExpanders`); wiring
the mixing lemma into `satCount` reuses existing infrastructure rather than
building spectral theory from scratch. Falsifiable: exhibit an expander unique
game whose optimum exceeds the predicted `1/k + O(λ)` bound.

### 4. An SDP relaxation strictly dominates the random-assignment floor.

Formalize the basic semidefinite relaxation of MAX-CUT (unit vectors per vertex,
maximize `∑ (1 - ⟨x_u, x_v⟩)/2`) and prove `sdp_value ≥ maxcut_value ≥ edges/2`,
then exhibit a graph (the 5-cycle) where `sdp_value > maxcut_value`. **The key
insight is** that the SDP feasible region contains the integral cuts as `±1`
vectors, so SDP optimum dominates combinatorial optimum *by construction*, and a
single small graph certifies the strict gap. **Why now?** With `maxcut_half`
already pinning the integral side, the only new object is the vector relaxation;
the 5-cycle gap (`sdp ≈ 0.9755·|E|` vs `maxcut = 0.8·|E|`) is a finite
computation Lean can verify, giving the first catalog theorem that *separates* a
relaxation from its integral value.

### 5. Goemans–Williamson rounding beats the floor by a fixed constant.

Prove the analyzable kernel of the GW theorem: for the SDP solution, random
hyperplane rounding satisfies each edge with probability `arccos(⟨x_u,x_v⟩)/π`,
hence the rounded cut has expected value `≥ α_GW · sdp_value` with
`α_GW ≈ 0.878`. **The key insight is** that the rounding probability is a
*pointwise* function of the inner product, so the global bound reduces to the
one-variable inequality `arccos(t)/π ≥ α_GW · (1 - t)/2` on `[-1, 1]` — a
self-contained real-analysis lemma. **Why now?** This converts the SDP-gap story
into an honest approximation guarantee and, under the UGC, `α_GW` is exactly the
optimal MAX-CUT approximation ratio — making this the precise quantitative bridge
from our unconditional floor to the conditional UGC frontier. Falsifiable: any
`t ∈ [-1,1]` violating the one-variable inequality breaks the `0.878` constant.
