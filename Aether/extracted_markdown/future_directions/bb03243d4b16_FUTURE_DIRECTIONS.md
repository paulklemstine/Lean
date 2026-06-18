# Future Research Directions

## Synthesis

The exact weighted tropical dimension formula — dim = β₁ᵂ + κᵂ — reveals that tropical kernel dimension is governed by the topology of a *degeneracy subgraph* rather than the ambient graph. This opens a stratified view of tropical geometry on weighted networks, where weight coincidences play the role of resonance conditions. The five directions below form a coherent program: Direction 1 extends the dimension formula to a full Riemann–Roch theory; Direction 2 connects the tie subgraph to spectral graph theory; Direction 3 generalizes to approximate/real-valued weights; Direction 4 builds moduli-theoretic infrastructure; and Direction 5 bridges to optimization and network science. Together, they constitute a research program in **weighted tropical Hodge theory on graphs**.

---

## Direction 1: Weighted Tropical Riemann–Roch Theorem

**Conjecture:** There exists a weight-sensitive divisor rank function r_w(D) on weighted graphs such that for every divisor D of degree d and every weighted graph (G, w) of weighted genus g_w = β₁ᵂ(G, w, V):

$$r_w(D) - r_w(K_w - D) = d - g_w + 1$$

where K_w is a canonical divisor defined via the tie subgraph.

**Test:** Compute r_w and verify the identity exhaustively on all weighted graphs with ≤ 5 vertices and weights in {1,...,5}. A single counterexample refines the definition of K_w.

**Impact:** This would be the first Riemann–Roch theorem for weighted tropical curves, extending Baker–Norine [2007] from the unweighted to the weighted setting. It would provide a complete divisor theory for weighted networks.

**Catalog References:** `Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (weighted Betti definition), `Pythagorean/TropicalBridge/WeightedDefect.lean` (structural defect formula).

**Proof Strategy:** Define the weighted canonical divisor K_w using the tie subgraph degree sequence. Prove the identity by induction on |E(G)| using Dhar's burning algorithm adapted to the tie subgraph.

**Domain Bridges:** Algebraic geometry (Riemann–Roch), combinatorics (chip-firing), optimization (divisor theory on networks).

**Lineage:** Direct extension of Theorem C (exact dimension formula) from the current work.

**Ambition:** Grand challenge — would define a new field of weighted tropical divisor theory.

---

## Direction 2: Spectral Interpretation of Weighted Betti Numbers

**Conjecture:** The weighted Betti number β₁ᵂ(G, w, S) equals the multiplicity of the zero eigenvalue of the *tie-constrained Laplacian* — the weighted graph Laplacian restricted to the tie subgraph — minus the number of tie components:

$$\beta_1^w = \dim \ker L_{\mathrm{tie}} - c(T[S])$$

**Test:** Compute eigenvalues of the tie-constrained Laplacian for all weighted graphs on 4 vertices. Verify the identity against β₁ᵂ.

**Impact:** Establishes a bridge between tropical geometry and spectral graph theory. The key insight is that tie edges correspond to zero-energy modes of a constrained system, analogous to frustration-free states in statistical mechanics.

**Catalog References:** `Pythagorean/TropicalBridge/WeightedDefect.lean` (weighted Laplacian definition, row-sum and symmetry theorems).

**Proof Strategy:** Show that the tie-constrained Laplacian has the same kernel dimension as the combinatorial cycle space of T[S]. Use the matrix-tree theorem adapted to subgraphs.

**Domain Bridges:** Spectral graph theory, mathematical physics (zero modes, frustration-free systems), linear algebra.

**Lineage:** Builds on the weighted Laplacian infrastructure in WeightedDefect.lean and the tie subgraph from ExactWeightedTropicalDimension.lean.

**Ambition:** Solid extension with potential for breakthrough — could unify tropical and spectral approaches to graph invariants.

---

## Direction 3: Approximate Tie Subgraphs for Real-Valued Weights

**Conjecture:** For real-valued weights with an ε-approximate tie condition (|w(u,v) - w(u,k)| < ε), there exists a critical threshold ε*(G, w) below which the approximate tie subgraph T_ε stabilizes and the weighted dimension formula holds:

$$\forall \varepsilon < \varepsilon^*(G, w): \quad \dim_{\mathrm{trop}}^\varepsilon = \beta_1^{w,\varepsilon} + \kappa^{w,\varepsilon}$$

**Test:** Compute ε* for random weighted graphs with real-valued weights drawn from [0,1]. Plot the stability diagram dim(ε) and verify threshold behavior.

**Impact:** Extends the theory from integer to real weights, which is necessary for applications in metric graph theory, valuation theory, and continuous optimization. The key insight is that tropical ties have a natural "width" governed by the weight separation.

**Catalog References:** `Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (tie subgraph definition — currently integer-valued).

**Proof Strategy:** Define ε-tie subgraph with approximate equality. Show that for ε below the minimum nonzero weight gap, the ε-tie subgraph equals the exact tie subgraph. Prove stability via a perturbation argument.

**Domain Bridges:** Metric geometry, valuation theory, numerical analysis, optimization under uncertainty.

**Lineage:** Generalizes the exact integer-weight theory to the continuous setting.

**Ambition:** Solid extension — necessary for practical applications and theoretical completeness.

---

## Direction 4: Moduli Stratification by Tie Subgraph Type

**Conjecture:** The space of all weight functions w : E(G) → ℤ on a fixed graph G admits a natural stratification:

$$\mathcal{W}(G) = \bigsqcup_{T \leq G} \mathcal{W}_T(G)$$

where $\mathcal{W}_T = \{w : T(G,w) = T\}$ is the stratum of weight functions with tie subgraph T. The weighted kernel dimension is constant on each stratum and equals β₁(T[S]) + κ(T, q, S).

**Test:** For K₄ with integer weights in {1,...,10}, enumerate all strata and verify dimension constancy within each stratum.

**Impact:** This would organize the "moduli space of weighted graphs" into a combinatorially controlled stratification, analogous to Schubert calculus in flag varieties. The key insight is that the tie subgraph type is a discrete invariant that controls continuous families of weights. Why now? The tie subgraph definition and dimension formula are now certified, providing the foundation for stratification theory.

**Catalog References:** `Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (tie subgraph construction), `Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (generic weight characterization).

**Proof Strategy:** Characterize each stratum $\mathcal{W}_T$ by a system of equalities and inequalities on edge weights. Show these form a polyhedral complex. Prove dimension constancy by showing the weighted invariants depend only on T, not on the specific weights.

**Domain Bridges:** Algebraic geometry (moduli theory), combinatorics (posets of subgraphs), polyhedral geometry.

**Lineage:** Extends the generic/uniform dichotomy to a full stratification.

**Ambition:** Grand challenge — paradigm-shifting for tropical moduli theory.

---

## Direction 5: Optimization Applications — Degeneracy Detection in Network Flow

**Conjecture:** In a minimum-cost network flow problem on (G, w), the number of distinct optimal bases (basic feasible solutions) is bounded below by 2^{β₁ᵂ(G,w,S)} where S is the set of intermediate nodes.

**Test:** Solve random minimum-cost flow problems on graphs with 5–10 nodes. Count optimal bases by enumeration. Compare with 2^{β₁ᵂ}.

**Impact:** Provides a graph-theoretic lower bound on the number of optimal solutions in network optimization, with direct applications to simplex method cycling analysis and robust optimization. The key insight is that tie edges create degenerate pivots, and their cycle structure controls the multiplicity of optimal solutions. Why now? The tie subgraph makes degeneracy computationally accessible for the first time.

**Catalog References:** `Pythagorean/TropicalBridge/ExactWeightedTropicalDimension.lean` (weighted Betti number), `Pythagorean/TropicalBridge/WeightedDefect.lean` (boundary mass definition connecting to network flow).

**Proof Strategy:** Map tropical kernel elements to degenerate simplex pivots. Show that independent tie cycles produce independent degenerate basis exchanges. Use the cycle rank to count independent exchanges.

**Domain Bridges:** Operations research (network flow, linear programming), optimization theory (degeneracy, cycling), computational complexity.

**Lineage:** Applies the weighted dimension formula to a concrete optimization problem.

**Ambition:** Solid extension with high practical impact — could influence algorithm design for degenerate LP solvers.
