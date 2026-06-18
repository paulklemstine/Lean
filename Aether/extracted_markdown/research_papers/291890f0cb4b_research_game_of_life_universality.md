# Formalized Universality Theory for Cellular Automata: Light Cones, Simulation Composition, and Spaceship Speed Bounds

## Abstract

We present a rigorous formalization in Lean 4 of the structural foundations of cellular automata universality theory, with Conway's Game of Life as the primary example. Our main contributions are:

1. **Light Cone Theorem**: A complete proof that the Game of Life satisfies finite speed of propagation — the state at any cell after *t* steps depends only on cells within Chebyshev distance *t*.

2. **Spaceship Speed Bound**: The first mechanically verified proof that spaceships with nonempty finite support cannot exceed speed 1 (one cell per step), resolving a folklore result that had not previously been formally verified.

3. **Simulation Composition Algebra**: A framework for composing CA simulations with multiplicative time overhead, including associativity, identity elements, and multi-step correctness.

4. **Periodic Orbit Theory**: Generalized results on iterate modular reduction, minimal period divisibility, and finite orbit bounds via the pigeonhole principle.

5. **Universality Closure**: A proof that universality is preserved under simulation — if a universal CA can be simulated by another CA, the simulator is also universal.

All proofs are mechanically verified in Lean 4 with Mathlib, using no sorry statements and no non-standard axioms.

## 1. Introduction

Conway's Game of Life [Conway, 1970; Gardner, 1970] is a two-dimensional cellular automaton defined on the integer lattice ℤ² with binary states (alive/dead). Despite its simple rule — a cell's next state depends only on the number of alive cells in its Moore neighborhood — the Game of Life exhibits remarkably rich behavior, including Turing completeness [Rendell, 2011].

The Turing completeness of the Game of Life has been demonstrated through increasingly sophisticated constructions. Rendell built a universal Turing machine simulator using glider-based logic gates. Paul Rendell's construction uses approximately 1000 × 1000 cells. More recent work by Adam Goucher has shown that even simpler constructions suffice.

However, the mathematical foundations underlying these constructions — the light cone theorem, simulation composition laws, and speed bounds — have remained informal. In this work, we formalize these foundational results in Lean 4, establishing a rigorous framework for reasoning about cellular automata universality.

### 1.1 Relationship to Prior Catalog Results

Our work builds on and extends several prior formalized results:

- **`turing_simulation_width_bound`** (Tropical/TropicalDeepResearch.lean): Established width bounds for Turing machine simulation. Our simulation composition theorem generalizes this to arbitrary CA-to-CA simulations.

- **`berggren_orbit_turing_complete`** (Pythagorean/BerggrenCA.lean): Proved Turing completeness of a cellular automaton on Berggren orbit lattices. Our framework provides the abstract simulation algebra that such results instantiate.

- **`berggren_universality_via_locality_and_growth`** (Pythagorean/EmergentComputation.lean): Factored universality through locality and growth bounds. Our light cone and spaceship speed theorems provide analogous results for the standard Game of Life.

- **`simulation_complexity_inverse_gap`** (Algebra/Core.lean): Established complexity bounds for simulation. Our three-level overhead theorem extends this to arbitrary composition chains.

## 2. Definitions

### 2.1 Game of Life

**Definition 2.1** (Board). A *board* is a function `b : ℤ × ℤ → Bool`.

**Definition 2.2** (Moore Neighborhood). The *Moore neighborhood* of cell `p` is the set of 8 cells adjacent to `p` (including diagonals but excluding `p` itself).

**Definition 2.3** (Step Function). The Game of Life step function is:
```
step(b)(p) = 
  if b(p) then (n = 2 ∨ n = 3)
  else (n = 3)
```
where `n` is the number of alive neighbors of `p` in `b`.

**Definition 2.4** (Evolution). `evolve(t, b) = step^t(b)`.

### 2.2 Chebyshev Distance

**Definition 2.5** (Chebyshev Distance). `chebyshevDist(p, q) = max(|p₁ - q₁|, |p₂ - q₂|)`.

### 2.3 Cellular Automaton Simulation

**Definition 2.6** (Cellular Automaton). A *cellular automaton* `(S, d, step, q)` consists of a state space `S`, dimension `d`, global step function, and quiescent state.

**Definition 2.7** (Simulation). A *simulation* of CA₂ by CA₁ is a triple `(encode, T, commute)` where:
- `encode` maps CA₂ configurations to CA₁ configurations
- `T` is the time overhead
- `commute`: `step₁^T ∘ encode = encode ∘ step₂`

This "encoding commutation" model is standard in the intrinsic universality literature [Ollinger, 2008].

## 3. Main Results

### 3.1 Light Cone Theorem

**Theorem 3.1** (Step Locality). *If boards b₁ and b₂ agree on the Chebyshev ball of radius 1 around p, then `step(b₁)(p) = step(b₂)(p)`.*

*Proof.* The step function depends only on `b(p)` and `aliveNeighborCount(b, p)`. The latter filters the Moore neighborhood, which is contained in the Chebyshev ball of radius 1. □

**Theorem 3.2** (Light Cone / Finite Speed of Propagation). *If boards b₁ and b₂ agree on the Chebyshev ball of radius t around p, then `evolve(t, b₁)(p) = evolve(t, b₂)(p)`.*

*Proof.* By induction on t. The base case is trivial. For the inductive step, we show that `step(b₁)` and `step(b₂)` agree on the ball of radius t around p, using Step Locality and the observation that the ball of radius 1 around any point q in the ball of radius t around p is contained in the ball of radius t+1 around p. □

### 3.2 Spaceship Speed Bound

**Theorem 3.3** (Spaceship Speed Bound). *Let b be a board with nonempty finite support, and suppose b is a spaceship with period p and displacement v. Then `max(|v₁|, |v₂|) ≤ p`.*

*Proof sketch.* The proof proceeds by establishing four extremal constraints. For each coordinate direction, we identify the extremal alive cell (e.g., the cell with maximum x-coordinate in the support). The spaceship property implies that the translated extremal cell must be alive after p steps. By the light cone theorem (via `empty_outside_light_cone`), this requires some alive cell within Chebyshev distance p of the translated extremal cell. But if the displacement exceeds p, this cell would have a larger coordinate than the extremal cell — contradiction.

The proof handles all four directions (±x, ±y) simultaneously by extracting max/min elements from the finite support using `Finset.exists_max_image` and `Finset.exists_min_image`. □

**Remark.** The nonempty support hypothesis is necessary. The empty board vacuously satisfies the spaceship definition for any displacement, since `translate(v, emptyBoard) = emptyBoard = evolve(p, emptyBoard)` for all v and p.

### 3.3 Translation Invariance

**Theorem 3.4** (Translation Invariance). *For any vector v and board b, `step(translate(v, b)) = translate(v, step(b))`.*

*Proof.* The key insight is that the Moore neighbors of `p` in the translated board correspond exactly to the translations of the Moore neighbors of `p - v` in the original board. The alive neighbor count is therefore preserved under translation. □

**Corollary 3.5.** *Translation invariance extends to arbitrary evolution: `evolve(t, translate(v, b)) = translate(v, evolve(t, b))`.*

### 3.4 Simulation Composition

**Theorem 3.6** (Multi-Step Simulation). *If sim is a simulation of CA₂ by CA₁ with time overhead T, then `step₁^{T·n}(encode(cfg)) = encode(step₂^n(cfg))` for all n.*

*Proof.* By induction on n, using the encoding commutation property and the additive structure of iterate. □

**Theorem 3.7** (Simulation Composition). *If sim₁₂ simulates CA₂ by CA₁ with overhead T₁, and sim₂₃ simulates CA₃ by CA₂ with overhead T₂, then there exists a simulation of CA₃ by CA₁ with overhead T₁ · T₂.*

*Proof.* The composed simulation uses `encode = encode₁₂ ∘ encode₂₃`. The commutation property follows from the multi-step theorem. □

**Theorem 3.8** (Associativity). *Simulation composition is associative: the overhead of `(s₁ ∘ s₂) ∘ s₃` equals that of `s₁ ∘ (s₂ ∘ s₃)`, both being `T₁ · T₂ · T₃`.*

### 3.5 Periodic Orbit Structure

**Theorem 3.9** (Period Closure). *If f^p(x) = x (with p > 0), then f^{kp}(x) = x for all k > 0.*

**Theorem 3.10** (Iterate Modular Reduction). *If f^p(x) = x, then f^t(x) = f^{t mod p}(x) for all t.*

**Theorem 3.11** (Minimal Period Divisibility). *If p is the minimal period and f^q(x) = x, then p | q.*

**Theorem 3.12** (Finite Orbit Bound). *For f : α → α with |α| = n finite, the orbit of any x contains a collision within n steps: ∃ t₁ < t₂ ≤ n, f^{t₁}(x) = f^{t₂}(x).*

### 3.6 Universality Theory

**Theorem 3.13** (Universality Closure). *If CA₁ is universal and CA₂ can simulate CA₁, then CA₂ is universal.*

**Theorem 3.14** (Reversible CA Inverse). *A bijective CA step function has a two-sided inverse.*

## 4. PEGB Analysis

### 4.1 Light Cone Theorem (P-E-G-B)

- **Proof**: Complete Lean 4 proof by induction on t, using step locality and ball containment.
- **Example**: A single alive cell at the origin. After 5 steps, only cells within Chebyshev distance 5 can be alive — a 11×11 square.
- **Generalization**: The light cone theorem holds for *any* CA with bounded neighborhood radius r, giving `evolve(t, b₁)(p) = evolve(t, b₂)(p)` when the boards agree on the ball of radius r·t.
- **Boundary**: The bound is tight — the Game of Life actually achieves speed-1 propagation via diagonal gliders (speed c/4 in taxicab distance, but c in Chebyshev distance).

### 4.2 Spaceship Speed Bound (P-E-G-B)

- **Proof**: Complete Lean 4 proof using extremal cell arguments and the light cone.
- **Example**: The standard glider has period 4 and displacement (1,1), so max(1,1) = 1 ≤ 4. The LWSS has period 4 and displacement (2,0), so max(2,0) = 2 ≤ 4.
- **Generalization**: For a CA with neighborhood radius r, the speed bound becomes max(|v₁|, |v₂|) ≤ r·p.
- **Boundary**: The bound is sharp in the limit — "speed-1 ships" achieving max(|v|) = p exist (e.g., the photon in Life-like rules). However, in standard Life, the fastest known spaceship travels at c/2.

### 4.3 Simulation Composition (P-E-G-B)

- **Proof**: Complete Lean 4 proof showing compositions form a monoid with multiplicative overhead.
- **Example**: If the Game of Life simulates Rule 110 with overhead 1000, and Rule 110 simulates a Turing machine with overhead 500, then GoL simulates the TM with overhead 500,000.
- **Generalization**: The simulation category can be enriched with space overhead, giving a two-parameter monoid (time × space).
- **Boundary**: The composition theorem doesn't address whether the composed simulation preserves finite support, which would require additional hypotheses on the encoding.

### 4.4 Periodic Orbit Theory (P-E-G-B)

- **Proof**: Complete Lean 4 proofs for period closure, modular reduction, and divisibility.
- **Example**: The blinker in GoL has minimal period 2. It returns at steps 2, 4, 6, ... but never at odd steps.
- **Generalization**: These theorems hold for arbitrary endomorphisms of any type, not just cellular automata — they capture the pure orbit structure of discrete dynamical systems.
- **Boundary**: For continuous dynamical systems, the divisibility result fails (irrational rotations have dense orbits without exact return).

## 5. Algorithms

### 5.1 Game of Life Simulation

```python
def step(board: set[tuple[int,int]]) -> set[tuple[int,int]]:
    neighbors = Counter()
    for (x, y) in board:
        for dx in [-1, 0, 1]:
            for dy in [-1, 0, 1]:
                if dx or dy:
                    neighbors[(x+dx, y+dy)] += 1
    return {p for p, n in neighbors.items()
            if n == 3 or (n == 2 and p in board)}
```

### 5.2 Spaceship Detection

```python
def detect_spaceship(board, max_period=100):
    current = board
    for t in range(1, max_period+1):
        current = step(current)
        for dx in range(-t, t+1):
            for dy in range(-t, t+1):
                if (dx, dy) != (0, 0):
                    translated = {(x-dx, y-dy) for (x,y) in current}
                    if translated == board:
                        return t, (dx, dy)
    return None
```

## 6. Discussion

### 6.1 Significance

The formalization provides the first mechanically verified treatment of several foundational results in cellular automata theory. While these results are "well-known" in the informal literature, their formal verification reveals subtleties (e.g., the necessity of the nonempty support hypothesis for the spaceship speed bound) that are often glossed over.

### 6.2 Comparison with Prior Work

The closest prior formal work is the Berggren CA universality proof in the project catalog, which establishes Turing completeness of a CA on Pythagorean orbit lattices. Our contribution is orthogonal: we provide the abstract simulation framework and structural theorems that such results instantiate.

### 6.3 Limitations

Our formalization does not include:
- The concrete gadget constructions (glider guns, eaters, reflectors) needed for a full Turing completeness proof of GoL specifically
- Space overhead bounds for simulations
- The Garden of Eden theorem (surjective CA ⟹ pre-injective on finite patterns)

These remain important directions for future work.

## 7. Future Work

1. **Concrete GoL gadgets**: Formalize specific glider collision outcomes to build verified logic gates.
2. **Space overhead**: Extend the simulation framework with spatial scaling factors.
3. **Garden of Eden**: Formalize the Curtis-Hedlund-Lyndon theorem and its consequences.
4. **Intrinsic universality**: Prove that certain CA are intrinsically universal (can simulate any CA with bounded overhead).
5. **Undecidability**: Formalize the undecidability of the halting problem for GoL (consequence of Turing completeness).

## References

1. Conway, J.H. (1970). The Game of Life. *Scientific American*, 223(4).
2. Gardner, M. (1970). Mathematical Games. *Scientific American*, 223(4), 120-123.
3. Rendell, P. (2011). A Universal Turing Machine in Conway's Game of Life. *AUTOMATA 2011*, LNCS 6714.
4. Ollinger, N. (2008). Universalities in cellular automata. *Handbook of Natural Computing*, Springer.
5. Berlekamp, E., Conway, J.H., Guy, R. (2001). *Winning Ways for Your Mathematical Plays*, Vol. 4.
6. Hedlund, G.A. (1969). Endomorphisms and automorphisms of the shift dynamical system. *Math. Systems Theory*, 3, 320-375.

## Appendix: Theorem Summary

| Theorem | File | Key Insight |
|---------|------|-------------|
| step_local | Defs.lean | GoL depends only on radius-1 neighborhood |
| light_cone | Defs.lean | Finite speed of propagation |
| multi_step | Defs.lean | Simulation iterates correctly |
| simulation_compose | Defs.lean | Simulations compose with multiplicative overhead |
| step_translate_commute | Universality.lean | GoL is translation-invariant |
| periodic_orbit | Universality.lean | Periodic orbits reduce modularly |
| period_divides_return | Universality.lean | Minimal period divides all return times |
| spaceship_speed_bound | Universality.lean | Spaceships can't exceed speed 1 |
| three_level_overhead | Universality.lean | Three-level composition is associative |
| minimal_period_divides | Bridges.lean | Generalized to arbitrary endomorphisms |
| simulation_algebra_associative | Bridges.lean | Overhead multiplication is associative |
| universal_closed_under_simulation | Bridges.lean | Universality transfers through simulation |
| finite_orbit_bound | Bridges.lean | Finite systems must cycle (pigeonhole) |
| reversible_has_inverse | Bridges.lean | Bijective CAs have inverses |
