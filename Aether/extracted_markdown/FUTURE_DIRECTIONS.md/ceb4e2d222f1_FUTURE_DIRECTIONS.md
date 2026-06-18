# Future Directions: Sperner's Lemma and Combinatorial Fixed Points in Game Theory

## Synthesis

This cycle established the foundational layer connecting Sperner's lemma to game theory through formalized Lean 4 proofs. We proved the one-dimensional Sperner's lemma in two forms—existence of a bichromatic edge and the stronger odd-count version—then derived a discrete Brouwer fixed point theorem directly from Sperner's lemma. On the game theory side, we formalized finite two-player games and proved that dominant strategy profiles are Nash equilibria, with uniqueness under strict dominance.

The key structural insight is that the coloring `c(j) = decide(f(j) < j)` transforms any self-map into a Sperner-compatible coloring whose boundary conditions are automatic (c(0) = false since natural numbers are non-negative; c(N+1) = true when f has no fixed point). The direction of the diagonal crossing is recovered by considering the minimal bichromatic edge, which must transition from false to true. This coloring construction is the bridge that connects combinatorial topology (Sperner) to fixed point theory (Brouwer) to game theory (Nash).

The game theory formalization is currently limited to pure strategies and dominant strategy equilibria. The main gap—and the central challenge for the next cycle—is extending to mixed strategies, where the simplex structure becomes essential and the connection to Sperner's lemma becomes direct rather than analogical.

## Results Summary

- `sperner_one_dim`: **proved** — 1D Sperner's lemma (existence): any Boolean coloring with boundary conditions has a bichromatic edge
- `sperner_one_dim_odd`: **proved** — Strictly stronger odd-count version: the number of bichromatic edges is always odd
- `discrete_brouwer_from_sperner`: **proved** — Discrete Brouwer fixed point theorem derived directly from Sperner's lemma: any self-map of {0,...,N+1} either has a fixed point or exhibits a diagonal crossing
- `dominant_is_nash`: **proved** — Dominant strategy profiles are Nash equilibria
- `nash_unique_dominant`: **proved** — Strictly dominant strategy profiles are the unique Nash equilibria

## Research Directions

### Direction 1: Two-Dimensional Sperner's Lemma
**Hypothesis**: Sperner's lemma for triangulated triangles with 3-coloring can be formalized in Lean 4: any proper Sperner coloring of a triangulation of a triangle has an odd number of fully-colored (trichromatic) sub-triangles.
**Test**: Define a triangulation as a simplicial complex on Fin 3-colored vertices, state the boundary condition (face opposite vertex i contains no vertex colored i), and prove the result by a path-following/parity argument on edges shared between triangles.
**Why now**: The 1D infrastructure (parity arguments, boundary condition handling, inductive structure) transfers directly. The 1D odd-count proof's structure—tracking parity changes as vertices are added—generalizes to tracking parity of trichromatic triangles as triangles are added to the triangulation.
**If true**: This unlocks the full Sperner → Brouwer → Kakutani → Nash chain in arbitrary dimension.
**If false**: The failure would reveal which aspects of higher-dimensional triangulation combinatorics are genuinely harder to formalize (likely the simplicial complex data structure and the boundary-walk argument).

### Direction 2: Mixed Strategy Nash Equilibrium for 2×2 Games via Sperner
**Hypothesis**: For any 2×2 game (2 players, 2 strategies each), a mixed strategy Nash equilibrium can be constructed by discretizing the strategy simplex [0,1]×[0,1], applying a Sperner-type coloring based on best responses, and taking a limit as the discretization refines.
**Test**: Define mixed strategies as probability distributions over Fin 2, define expected payoffs, construct the Sperner coloring, and prove that the limit of approximate equilibria from successively finer discretizations converges to an exact Nash equilibrium.
**Why now**: The `discrete_brouwer_from_sperner` theorem already shows how Sperner yields approximate fixed points. The 2×2 case reduces the simplex to an interval, making the construction concrete. The key insight is that for 2×2 games, the best-response correspondence is piecewise linear, so the Sperner coloring is particularly well-behaved.
**If true**: This provides a constructive, Sperner-based proof of Nash's theorem for the simplest non-trivial case, avoiding Kakutani's theorem entirely.
**If false**: The failure point would likely be the convergence argument (passing from approximate to exact equilibria), which requires compactness of the strategy space—revealing whether the constructive content of Sperner's lemma is genuinely sufficient or whether a non-constructive compactness argument is unavoidable.

### Direction 3: Computational Complexity of Sperner-Based Equilibrium Search
**Hypothesis**: The path-following algorithm implicit in Sperner's lemma (Scarf's algorithm) can be formalized as a function `Fin N → Fin N` on discretized simplices, with a formal proof that it terminates in at most `N^n` steps for an n-player game with N total pure strategies.
**Test**: Implement the complementary pivoting algorithm for the 1D case (which reduces to binary search on bichromatic edges), prove termination, and bound the number of steps.
**Why now**: The `bichromaticEdges` definition and the odd-count theorem already provide the combinatorial foundation. The key insight is that in 1D, the Scarf algorithm is simply walking along the interval and stopping at the first bichromatic edge, which terminates in at most n+1 steps.
**If true**: This would be the first formalized complexity bound for an equilibrium-finding algorithm, connecting computational complexity theory to combinatorial topology.
**If false**: The bound might not be tight, or the algorithm might require a more sophisticated termination argument in higher dimensions.

### Direction 4: Generalized Coloring Lemma (k-chromatic Sperner)
**Hypothesis**: The 1D Sperner's lemma generalizes to k colors: given a coloring f : {0,...,n} → Fin k with f(0) = 0 and f(n) = k-1, and with the property that f changes by at most 1 at each step (|f(i+1) - f(i)| ≤ 1), there exists at least one edge where f increases (f(i+1) = f(i) + 1) for each color transition 0→1, 1→2, ..., (k-2)→(k-1).
**Test**: Prove the k=3 case first, then generalize by induction on k, using the 1D Sperner lemma as the base case.
**Why now**: The 1D framework handles the k=2 case cleanly. The key insight is that the constraint |f(i+1) - f(i)| ≤ 1 is the 1D analog of the Sperner boundary condition in higher dimensions, where colors can only appear on their designated faces.
**If true**: This provides a purely combinatorial path to higher-dimensional Sperner without needing simplicial complex machinery.
**If false**: The monotonicity constraint might be too restrictive, indicating that higher-dimensional Sperner genuinely requires the full simplicial framework.

### Direction 5: Zero-Sum Game Minimax from Discrete Brouwer
**Hypothesis**: For finite zero-sum games, the minimax theorem (max_i min_j payoff(i,j) = min_j max_i payoff(i,j)) can be derived from the discrete Brouwer fixed point theorem by discretizing the best-response dynamics.
**Test**: Define a zero-sum game, formalize the best-response map on the discretized strategy space, apply `discrete_brouwer_from_sperner` to find an approximate saddle point, and show convergence to an exact saddle point.
**Why now**: The `discrete_brouwer_from_sperner` theorem provides the fixed-point machinery, and `dominant_is_nash` / `nash_unique_dominant` provide the game-theoretic framework. The key insight is that in a zero-sum game, the Nash equilibrium IS the minimax solution, so finding one via Brouwer immediately yields the other.
**If true**: This completes the Sperner → Brouwer → Minimax chain, providing a combinatorial proof of von Neumann's minimax theorem.
**If false**: The difficulty would likely be in the convergence step—zero-sum games have saddle points but the best-response map may not be single-valued, requiring Kakutani (set-valued) rather than Brouwer (point-valued) fixed point theory.
