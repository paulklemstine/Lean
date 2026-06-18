# Future Directions: The Poset of p-Degrees — Lattice Shape and Parametric Separation

## Synthesis

This cycle extended the order-theoretic core of the Cook–Reckhow program built in
`Logic/ProofComplexity/SimulationPreorder.lean` (the p-simulation `Preorder`, the `PEquiv`
`Setoid`, and the Fibonacci separation) and `SimulationDegrees.lean` (the generic
non-polynomial separation template `no_simulation_of_hard` and two distinct p-degrees). The
two new files determine the **lattice-theoretic shape** of the simulation preorder and pin
down its **bottom layer**.

`SimulationLattice.lean` shows that the direct sum `sumSystem P Q` of two abstract proof
systems is the **greatest lower bound** of `{P, Q}` (`sumSystem_isGLB`), so the simulation
preorder has binary meets and is downward directed (`simulationPreorder_codirected`,
`IsDirected _ (· ≥ ·)`). The only new arithmetic is closure of the polynomial blow-up class
under pointwise `max` (`polyMono_max`), mirroring the closure-under-composition that powered
transitivity in cycle 1.

`SimulationCollapse.lean` introduces the size-relabeled identity systems `idSystem sz` over
`Thm = ℕ` and proves the **polynomial collapse**: every honest polynomial-size system (size
polynomially bounded and at least linear) sits in a single p-degree (`pEquiv_idSystem`,
`idSystem_pEquiv_linSystem`, `linSystem_pEquiv_quadSystem`), while the Fibonacci system stays
strictly above it (`not_pEquiv_fib_lin`). Together with cycle 2's
`exists_two_distinct_pdegrees`, this gives a concrete two-layer skeleton: one polynomial
degree strictly below one Fibonacci degree, with binary meets available throughout.

## Results Summary

- `polyMono_max` / `polyBounded_max` — the monotone polynomial blow-up class is closed under
  pointwise maximum.
- `sumSystem` / `sumSystem_simulates_left` / `sumSystem_simulates_right` — the direct sum is a
  common lower bound (it simulates both summands via the identity blow-up).
- `sumSystem_greatest` / `sumSystem_isGLB` — the direct sum is the *greatest* lower bound: a
  genuine binary meet of `{P, Q}`.
- `simulationPreorder_codirected` — the simulation preorder is downward directed.
- `exists_monotone_polyBound` — every polynomial bound lies under a monotone one `(n+2)^k`.
- `pEquiv_idSystem` / `idSystem_pEquiv_linSystem` / `linSystem_pEquiv_quadSystem` — all honest
  polynomial-size systems collapse to one p-degree.
- `not_simulates_fib_lin` / `not_pEquiv_fib_lin` — that polynomial degree is strictly below
  the Fibonacci degree.

## Bold, Falsifiable Research Directions

### 1. The p-degree poset is a join-semilattice as well as a meet-semilattice

We proved binary *meets* (common strengthenings) via `sumSystem_isGLB`. Conjecture: the
p-degree poset, on the antisymmetrization `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`, also
admits binary *joins* (common weakenings) and is therefore a genuine lattice. The natural
candidate for the join of `P` and `Q` is an "intersection" system whose proofs certify only
theorems provable in *both* `P` and `Q`, with size the minimum of the two on the shared
theorem set. The key insight is that a join must be a system that *both* `P` and `Q` simulate,
so it can only certify the common theorems and must never be cheaper than either summand on
them — the `min`-of-sizes restricted to the shared theorem set is forced. Why now? The meet
half is mechanized and the blow-up class is closed under `min` by the identical one-line
argument used for `max` in `polyBounded_max`, so the order-theoretic scaffolding (`IsLUB`,
`Antisymmetrization`) is already in place; only the intersection-system construction and its
completeness witness remain. Falsifiable: exhibit `P`, `Q` with no least common weakener.

### 2. The polynomial degree is the unique bottom element of the p-degree poset

We showed (`pEquiv_idSystem`) that every system whose size is sandwiched between linear and
polynomial collapses to one degree, and (`not_pEquiv_fib_lin`) that the Fibonacci degree lies
strictly above it. Conjecture: the polynomial degree is the global **minimum** of the entire
p-degree poset of `idSystem`-style systems over `ℕ` whose size is at least linear — every such
system p-simulates `linSystem`. The key insight is that simulating the cheap linear system
only requires a *monotone polynomial envelope* of the simulating system's own size, and the
sole obstruction is whether that size is super-polynomial; being *simulated by* the trivially
cheap linear system is never blocked by the at-least-linear lower wall. Why now? `idSystem`,
`linSystem_simulates_idSystem`, and `exists_monotone_polyBound` already reduce the statement to
a clean growth inequality, so the conjecture is one quantifier-shuffle from the existing API.
Falsifiable: a system the linear system fails to simulate would refute it.

### 3. There is a strictly increasing ω-chain of p-degrees

We currently have exactly two layers (polynomial < Fibonacci). Conjecture: the p-degree poset
contains an infinite strictly ascending chain `d_0 < d_1 < d_2 < ...`, witnessed by an
iterated-exponential (tower) hierarchy `sz_k = exp^{(k)}`, with `idSystem sz_k` strictly below
`idSystem sz_{k+1}` because each tower function is super-polynomial in the previous. The key
insight is that strict separation in the simulation preorder is *exactly* the failure of one
growth class to polynomially dominate another (this is precisely what `no_simulation_of_hard`
abstracts), so a sequence of growth rates each super-polynomial in its predecessor yields a
strict chain mechanically. Why now? The parametric separation template already accepts an
arbitrary non-polynomial hardness function `s`; instantiating it along a recursively defined
tower needs only a self-contained "tower beats poly of previous tower" arithmetic lemma.
Falsifiable: a collapse `d_k = d_{k+1}` at some level.

### 4. The p-degree poset embeds an antichain of size continuum

Conjecture: there is an antichain (pairwise p-incomparable degrees) of size `2^ℵ₀` among
`idSystem`-style systems over `ℕ`, indexed by subsets `S ⊆ ℕ` via systems that are
super-polynomially hard exactly on the theorems `n ∈ S`. The key insight is that two such
systems are incomparable precisely when neither index set's "hard" positions are polynomially
dominated by the other's, and an almost-disjoint (Sierpiński) family of subsets of ℕ realizes
continuum-many mutually non-dominating hardness profiles. Why now? Incomparability reduces to
two applications of `no_simulation_of_hard` in opposite directions, and Mathlib already has
almost-disjoint families and cardinality-of-continuum infrastructure, so the missing piece is
only the bookkeeping that ties a hardness profile to a subset. Falsifiable: a proof that any
two degrees are comparable (a linearity theorem) would refute it.

### 5. A formal Cook–Reckhow theorem: NP = coNP iff a p-optimal (top) degree exists

The grand challenge. Conjecture (abstract Cook–Reckhow): the simulation preorder over a fixed
honest theorem set has a **maximum** p-degree (a single weakest system that every system
simulates — a p-optimal proof system in the classical sense) if and only if the underlying
tautology set is "self-provable" in a precise complexity-theoretic sense abstracting
`NP = coNP`. The key insight is that the existence of a p-optimal system is a purely
order-theoretic *top-element* statement in our preorder, exactly dual to the *bottom*
(polynomial degree) we characterized in `SimulationCollapse.lean`, so the classical
equivalence "NP = coNP ⟺ a polynomially bounded proof system exists" becomes a statement about
the top of the p-degree poset. Why now? Having mechanized meets, directedness, and the bottom
layer, the vocabulary for "top element" and "bounded degree" is in place; formalizing the
conditional equivalence isolates the one genuinely hard import behind an honest Lean
`variable`/hypothesis, turning a grand challenge into a precise checkable conditional.
Falsifiable: construct a theorem set with a maximum degree but no self-provability, or vice
versa.
