# Future Directions

## Synthesis

This research cycle established the formal foundation for the Sperner-Nash bridge: a complete formalization of finite normal-form games with mixed strategies, Nash equilibria, and approximate equilibria, along with 12 fully verified theorems including the crucial support lemma and convexity decomposition. The support lemma—that strategies in the support of a Nash equilibrium must all achieve equal expected payoff—emerged as the structural linchpin connecting combinatorial coloring arguments to equilibrium existence.

The most promising cross-domain connection from this cycle is the bridge between **combinatorial fixed point theory** and **game-theoretic equilibrium refinement**. Our novel definition of *combinatorial equilibrium refinement* (sequences of Sperner-derived approximations to Nash equilibria) opens a new research direction that connects discrete combinatorics (Sperner's lemma, simplicial complexes) with continuous game theory (Nash equilibria, trembling-hand perfection). This bridge is bidirectional: combinatorial structures can illuminate equilibrium selection, and game-theoretic concepts can motivate new combinatorial theorems.

The highest breakthrough potential lies in **Direction 1** (proving the trembling-hand perfection conjecture), because a positive result would establish that the Sperner construction is not just an existence tool but an *equilibrium selection* mechanism—answering a question that has resisted resolution since Selten introduced trembling-hand perfection in 1975. A negative result would be equally informative, producing an explicit counterexample that clarifies the boundary between combinatorial and analytic refinement concepts.

---

### Direction 1: Trembling-Hand Perfection of Sperner-Limit Equilibria

**Conjecture**: Every Nash equilibrium obtainable as a limit of centers of fully-colored simplices in the Sperner construction (i.e., every limit of a combinatorial equilibrium refinement sequence) is trembling-hand perfect.

**Test**: Construct a game $G$ with a known non-trembling-hand-perfect Nash equilibrium $\sigma^*$. Implement the Sperner construction with multiple triangulation families (Kuhn triangulations, Freudenthal triangulations, random triangulations). Check whether any triangulation sequence produces $\sigma^*$ as a limit. If all tested triangulation families avoid $\sigma^*$, the conjecture gains support. A single family converging to $\sigma^*$ would refute it.

A good test game: a 3×3 game where the fully mixed equilibrium is not trembling-hand perfect due to weakly dominated strategies. For example:
$$A = \begin{pmatrix} 2 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 0 \end{pmatrix}, \quad B = \begin{pmatrix} 0 & 0 & 0 \\ 0 & 1 & 0 \\ 0 & 0 & 2 \end{pmatrix}$$

**Impact**: If true, this would establish the Sperner construction as a natural equilibrium refinement, unifying combinatorial fixed point theory with equilibrium selection theory. This would be a significant result in game theory with implications for mechanism design and evolutionary game theory. If false, the counterexample would precisely delineate what the Sperner construction can and cannot select.

**Catalog References**: `Bridges/SpernerNashEquilibria.lean` (CombinatorialEquilibriumRefinement, IsFullyMixed, nash_support_lemma)

**Proof Strategy**: 
1. Formalize trembling-hand perfection in Lean 4 (as a limit of Nash equilibria of perturbed games)
2. Show that Sperner approximations at interior grid points are equivalent to Nash equilibria of perturbed games (where the perturbation comes from the grid resolution)
3. Use the support lemma to show that the limit preserves the structure needed for trembling-hand perfection
4. Key lemma needed: if $\sigma^{(n)}$ are fully mixed $\epsilon_n$-Nash equilibria with $\epsilon_n \to 0$, the limit is trembling-hand perfect

**Domain Bridges**: Combinatorics (Sperner's lemma) ↔ Game Theory (equilibrium refinement) ↔ Topology (convergence of measures)

**Lineage**: Builds on the support lemma (nash_support_lemma) and combinatorial equilibrium refinement framework from this cycle. Extends the classical Selten (1975) refinement theory.

**Ambition**: grand_challenge

---

### Direction 2: Formal Sperner's Lemma in Arbitrary Dimension

**Conjecture**: Sperner's lemma can be formalized in Lean 4 for arbitrary dimension $n$ using a combinatorial (parity-counting) proof that avoids topological machinery entirely.

**Test**: Formalize the statement "every Sperner-labeled triangulation of the $n$-simplex has an odd number of fully-labeled $n$-simplices" and prove it by induction on dimension, using the door-counting argument (walking through doors between simplices of different labelings).

**Impact**: A formal Sperner's lemma would complete the Sperner-Nash pipeline and provide a foundation for formalizing Brouwer's fixed point theorem combinatorially. It would also be a significant contribution to the formalization of combinatorial topology in Lean/Mathlib.

**Catalog References**: `Bridges/SpernerNashEquilibria.lean` (HasSpernerProperty)

**Proof Strategy**:
1. Define simplicial complexes and triangulations of the standard simplex
2. Define Sperner labeling (boundary condition: vertex on face $F_i$ does not get label $i$)
3. Prove the 1-dimensional base case (intermediate value theorem for discrete functions)
4. Inductive step: define the "door graph" on $(n-1)$-faces between $n$-simplices
5. Show the door graph has odd degree at boundary doors (by induction hypothesis on the boundary)
6. Conclude by handshaking lemma: odd number of fully-labeled simplices

Key Lean definitions needed:
- `SimplicialComplex (n : ℕ)` with vertices indexed by `Fin k` and simplices as `Finset (Fin k)` of size $n+1$
- `SpernerLabeling (T : SimplicialComplex n) (c : Fin k → Fin (n+1))` satisfying the boundary condition
- `FullyLabeled (σ : Finset (Fin k))` meaning $c$ restricted to $\sigma$ is surjective onto $\text{Fin}(n+1)$

**Domain Bridges**: Combinatorics (simplicial complexes) ↔ Topology (Brouwer FPT) ↔ Game Theory (Nash existence)

**Lineage**: Extends the HasSpernerProperty definition from this cycle. Would complete the formalization pipeline.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Nash Equilibria

**Conjecture**: Replacing real-valued payoffs with tropical (max-plus) payoffs in a finite game yields a "tropical Nash equilibrium" concept where equilibria correspond to vertices of a tropical polytope, and the number of tropical Nash equilibria is always a power of 2.

**Test**: Define tropical games where payoffs are in $(\mathbb{R} \cup \{-\infty\}, \max, +)$ instead of $(\mathbb{R}, +, \times)$. Compute tropical Nash equilibria for all 2×2 games with payoffs in $\{0, 1, 2\}$ and verify the power-of-2 count. If any game has a non-power-of-2 count, the conjecture is false.

**Impact**: Tropical game theory would connect strategic interaction to combinatorial optimization, since tropical linear algebra is equivalent to shortest-path algorithms. This could yield polynomial-time algorithms for finding equilibria in restricted game classes.

**Catalog References**: `Tropical/` directory in Catalog, `Bridges/SpernerNashEquilibria.lean` (FiniteGame, IsNashEquilibrium)

**Proof Strategy**:
1. Define `TropicalGame` with payoff type `WithBot ℝ` (ℝ ∪ {-∞}) and tropical operations
2. Define tropical expected payoff: replace ∑ with max, replace × with +
3. Define tropical Nash equilibrium: no player can tropically improve
4. Prove structural theorems: tropical support lemma, tropical convexity
5. Connect to the existing Tropical/ catalog machinery for tropical semirings

**Domain Bridges**: Tropical Geometry (tropical polytopes) ↔ Game Theory (Nash equilibria) ↔ Optimization (shortest paths)

**Lineage**: Bridges the Tropical/ catalog with the game theory framework from this cycle. Novel cross-domain construction.

**Ambition**: extension

---

### Direction 4: Computational Complexity of the Sperner-Nash Algorithm

**Conjecture**: The Sperner-Nash algorithm for 2-player games can be made query-efficient: finding an $\epsilon$-Nash equilibrium requires $\Theta(1/\epsilon^2)$ payoff queries, matching the lower bound for randomized algorithms.

**Test**: Implement the Sperner-Nash algorithm with adaptive triangulation refinement (refine only near promising regions, not uniformly). Measure the number of payoff evaluations needed to find an $\epsilon$-Nash equilibrium for various $\epsilon$ values on random 10×10 games. Compare with the $O(1/\epsilon^{m+n-2})$ worst case of uniform refinement.

**Impact**: If the query complexity can be reduced to $O(1/\epsilon^2)$, the Sperner-Nash algorithm would be competitive with support enumeration for small games. This would also connect to the PPAD complexity class, since Sperner's lemma is PPAD-complete.

**Catalog References**: `Bridges/SpernerNashEquilibria.lean` (find_nash_sperner algorithm), `Computation/` directory

**Proof Strategy**:
1. Formalize query complexity for Nash equilibrium computation
2. Prove that adaptive refinement reduces the exponent from $m+n-2$ to a constant
3. Key insight: the regret landscape is Lipschitz, so adaptive refinement can exploit gradient information
4. Lower bound: use the PPAD reduction from Sperner to show optimality

**Domain Bridges**: Computational Complexity (PPAD, query complexity) ↔ Game Theory (Nash computation) ↔ Combinatorics (Sperner's lemma)

**Lineage**: Extends the algorithmic results from this cycle. Connects to the Computation/ catalog.

**Ambition**: extension

---

### Direction 5: Multi-Player Support Lemma and Coalition Stability

**Conjecture**: The support lemma generalizes to coalitional games: in a strong Nash equilibrium (no coalition can jointly deviate to improve all members' payoffs), every coalition's mixed strategy support must achieve equal "coalitional payoff" for each pure strategy profile in the support.

**Test**: Formalize strong Nash equilibrium in Lean 4. State the coalitional support lemma. Attempt to prove it using the same convexity argument as the individual support lemma. If the proof fails, identify which step breaks down (the convexity decomposition may not generalize to joint deviations).

**Impact**: A coalitional support lemma would extend the Sperner-Nash bridge to cooperative game theory, connecting combinatorial fixed points with coalition formation. This could lead to new algorithms for computing strong Nash equilibria, which are currently much harder to find than ordinary Nash equilibria.

**Catalog References**: `Bridges/SpernerNashEquilibria.lean` (nash_support_lemma, expectedPayoff_eq_weighted_sum)

**Proof Strategy**:
1. Define `StrongNashEquilibrium` as a profile where no coalition $C \subseteq \{1, \ldots, n\}$ can jointly deviate to improve all members
2. Generalize `expectedPayoff_eq_weighted_sum` to coalitional deviations
3. Apply the same "convex combination ≤ max" argument
4. Key difficulty: joint deviations change multiple players simultaneously, breaking the factorization $\prod_j \sigma_j(s_j)$

**Domain Bridges**: Cooperative Game Theory (coalition stability) ↔ Combinatorics (Sperner generalizations) ↔ Economics (mechanism design)

**Lineage**: Direct extension of the support lemma from this cycle to the multi-player setting.

**Ambition**: extension
