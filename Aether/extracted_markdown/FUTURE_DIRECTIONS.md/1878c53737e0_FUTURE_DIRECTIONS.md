# Future Directions: Width-Controlled Learnability Regimes

## Synthesis

The theorems established in this work — the structural memory envelope, the width-controlled complete policy, the linear phase transition control law, and the boundary state count — form the foundation of a new research program connecting graph structure to reasoning memory. The core insight is that pathwidth of the clause-interaction graph acts as a *linear order parameter* for a learnability phase transition, separating compressed-search regimes (bounded memory, transfer-matrix tractable) from expansive-search regimes (unbounded memory, combinatorially explosive).

The five directions below extend this foundation along complementary axes: generalizing from pathwidth to treewidth (Direction 1), proving runtime bounds alongside memory bounds (Direction 2), connecting to random CSP phase transitions (Direction 3), establishing optimality of the memory bound (Direction 4), and building a bridge to quantum computational complexity (Direction 5). Together, they would establish *structural learnability theory* as a new field at the intersection of proof complexity, parameterized algorithms, statistical mechanics, and learning theory.

---

## Direction 1: Treewidth Generalization — Multi-Frontier Memory Control

**Conjecture:** For any CNF formula $F$ whose clause-interaction graph has treewidth at most $k$, there exists a tree-decomposition-guided retention policy with memory bound $O(k)$ per frontier and total active memory $O(k^2)$ at any point during a complete DFS traversal of the decomposition tree.

**Test:** Formalize a tree decomposition policy structure analogous to `WidthControlledPolicy` but parameterized by a tree decomposition. Prove the memory bound by induction on the tree structure, using the existing frontier bound at each node. Implement and test on random bounded-treewidth instances with $k \in \{3, 5, 10, 20\}$ and $n \in \{100, 1000, 10000\}$.

**Refutation criterion:** The conjecture would be falsified if there exist bounded-treewidth instances where any tree-decomposition-guided DFS strategy requires $\omega(k^2)$ active memory. A computational search for such counterexamples among graphs with treewidth $k$ and pathwidth $\Theta(k \log k)$ would be the primary test.

**Impact:** Treewidth is the more natural structural parameter for most applications (database queries, probabilistic inference, tensor networks). Generalizing from pathwidth to treewidth would make the theory applicable to a vastly larger class of problems.

**Catalog References:**
- `Catalog/Pythagorean/ClauseInteractionPathwidth/Theorems.lean` (frontier bound, separator theorem)
- `Catalog/Pythagorean/CDCLPathwidth/PhaseTransition.lean` (width-controlled policy)

**Proof Strategy:** Define tree-frontier as the union of frontiers along the root-to-current-node path. The DFS traversal maintains at most depth $d$ active frontiers, each of size $\leq k+1$. Since depth $d \leq$ number of bags, the total active memory is $\leq (k+1) \cdot d$. For balanced tree decompositions, $d = O(\log n)$, giving $O(k \log n)$ total memory — which is better than $O(k^2)$ for large $n$.

**Domain Bridges:** Database query optimization (acyclic queries), Bayesian network inference (junction tree algorithm), tensor network contraction (tree tensor networks).

**Lineage:** Direct extension of Theorems 1–2 in this work.

**Ambition:** 🔬 Solid extension — the mathematical machinery is largely in place.

---

## Direction 2: Polynomial Runtime Certification

**Conjecture:** For fixed width $k$, the decomposition-guided bounded-memory solver runs in time $O(|F| \cdot 2^{(k+1) \cdot \ell})$ where $\ell$ is the maximum clause length. For fixed $k$ and $\ell$, this is $O(|F|)$ — linear in formula size.

**Test:** Formalize a step-counting version of the solver policy. Define a runtime function `runtimeBound : WidthControlledPolicy → ℕ` that counts the total number of boundary-state enumerations across all stages. Prove that `runtimeBound π ≤ m · 2^((k+1) · ℓ)` where `m = P.bags.length`.

**Refutation criterion:** The conjecture would be falsified if there exist bounded-pathwidth instances where any decomposition-guided strategy requires superpolynomial time (for fixed $k$, $\ell$). This is extremely unlikely given the transfer-matrix structure, but a formal proof is needed.

**Impact:** Completes the picture: bounded memory *and* polynomial runtime for bounded-width instances. This would be a formal FPT (fixed-parameter tractable) result parameterized by pathwidth, complementing existing results by Fischer-Makowsky-Ravve.

**Catalog References:**
- `Catalog/Pythagorean/CDCLPathwidth/PhaseTransition.lean` (memory bound)
- `Catalog/Pythagorean/ClauseInteractionPathwidth/Defs.lean` (clause evaluation, locality)

**Proof Strategy:** Formalize a step counter as a `ℕ`-valued function on the policy. Each stage requires enumerating at most $2^{|\text{vars}(\text{frontier})|}$ assignments. Since $|\text{frontier}| \leq k+1$ and each clause has $\leq \ell$ variables, $|\text{vars}(\text{frontier})| \leq (k+1)\ell$. Sum over $m$ stages.

**Domain Bridges:** Parameterized complexity theory (FPT algorithms), dynamic programming on tree/path decompositions.

**Lineage:** Extension of Theorem 2 (policy existence) with quantitative runtime analysis.

**Ambition:** 🔬 Solid extension — the argument is classical, formalization is the main challenge.

---

## Direction 3: Random CSP Phase Transition Alignment

**Conjecture (Grand Challenge):** For random $k$-SAT instances at clause-to-variable ratio $\alpha$, the expected pathwidth of the clause-interaction graph undergoes a phase transition near the satisfiability threshold $\alpha_c(k)$. Below a secondary threshold $\alpha_w(k) < \alpha_c(k)$, the pathwidth is $O(\log n)$ (compressed regime); above $\alpha_c(k)$, the pathwidth is $\Omega(n)$ (expansive regime).

**Test:** Generate random 3-SAT instances with $n \in \{50, 100, 200, 500\}$ at ratios $\alpha \in \{2.0, 3.0, 3.5, 4.0, 4.2, 4.5, 5.0\}$. Compute or estimate the pathwidth of the clause-interaction graph using heuristic methods (e.g., min-degree, min-fill). Plot pathwidth vs. $\alpha$ and look for a transition.

**Refutation criterion:** The conjecture would be falsified if pathwidth grows as $\Theta(n)$ even for $\alpha \ll \alpha_c$, or if pathwidth remains bounded even for $\alpha \gg \alpha_c$. Either outcome would decouple the structural transition from the satisfiability transition.

**Impact:** This would be a paradigm-shifting result connecting three major fields: random combinatorics (phase transitions in random graphs), proof complexity (resolution hardness near threshold), and statistical physics (replica symmetry breaking). It would identify pathwidth as the *structural order parameter* that governs the satisfiability phase transition.

**Catalog References:**
- `Catalog/Pythagorean/CDCLPathwidth/PhaseTransition.lean` (memory threshold, exponential separation)
- `Catalog/Pythagorean/CertificatePhaseTransition.lean` (phase transition framework)

**Proof Strategy:** For the lower regime ($\alpha < \alpha_w$): random graphs below the giant component threshold have bounded treewidth with high probability (Kloks, 1994). The clause-interaction graph of a sparse random CNF inherits this structure. For the upper regime: use expansion properties of random graphs above threshold to show that the clause-interaction graph has $\Omega(n)$ pathwidth.

**Domain Bridges:** Random graph theory, statistical physics of disordered systems, proof complexity lower bounds.

**Lineage:** Connects the phase transition control law (Theorem 3) to random combinatorics.

**Ambition:** 🚀 Grand challenge — would unify three major research traditions.

---

## Direction 4: Optimality of the Memory Bound

**Conjecture:** The bound $T^*(k) = k+1$ is tight: for every $k$, there exists a CNF formula $F_k$ with clause-interaction pathwidth exactly $k$ such that any complete frontier-preserving retention policy requires at least $k+1$ retained clauses at some stage.

**Test:** Construct explicit formula families. The candidate is a "ladder" formula: $F_k$ consists of $k+1$ clauses forming a path in the interaction graph, with each consecutive pair sharing exactly one variable. Any path decomposition of this graph has width exactly $k$, and the frontier at the midpoint contains all $k+1$ clauses.

**Refutation criterion:** The conjecture would be falsified if a cleverer retention policy (not aligned with the canonical decomposition) achieves memory $< k+1$ while preserving all frontier interactions. This would mean the frontier-based definition of completeness is too strong.

**Impact:** Establishes the exact memory complexity: $T^*(k) = k+1$, not $\Theta(k)$ with unknown constants. Combined with the upper bound (Theorem 1), this gives a complete characterization.

**Catalog References:**
- `Catalog/Pythagorean/CDCLPathwidth/PhaseTransition.lean` (upper bound)
- `Catalog/Pythagorean/ConfigGraph/Theorems.lean` (clause space lower bounds)

**Proof Strategy:** Formalize the ladder formula family. Show that its clause-interaction graph is a path, hence has pathwidth exactly $k$. Show that at the midpoint of any path decomposition, all $k+1$ clauses must appear in the bag (by edge coverage). Hence any frontier-preserving policy must retain all $k+1$ at that stage.

**Domain Bridges:** Proof complexity (space lower bounds), extremal graph theory.

**Lineage:** Tightness result for Theorem 1.

**Ambition:** 🔬 Solid extension — the construction is explicit and the proof strategy is clear.

---

## Direction 5: Quantum Transfer Matrix and Entanglement Width

**Conjecture (Grand Challenge):** For quantum constraint satisfaction problems (quantum SAT, local Hamiltonian problems) whose interaction graph has pathwidth $\leq k$, the entanglement entropy across any cut is bounded by $O(k)$ qubits. Consequently, matrix product state (MPS) representations of width $2^{O(k)}$ suffice for ground state computation.

**Test:** Formalize the quantum analogue of the boundary state count: for a 1D system with interaction range $k+1$, the Schmidt rank across any cut is bounded by $2^{k+1}$. Implement MPS-based ground state solvers for random bounded-pathwidth local Hamiltonians and measure the required bond dimension.

**Refutation criterion:** The conjecture would be falsified if bounded-pathwidth quantum systems exhibit volume-law entanglement (entanglement entropy $\Omega(n)$) despite bounded interaction width. This would indicate a fundamental difference between classical and quantum constraint satisfaction.

**Impact:** This would bridge classical parameterized complexity (pathwidth-bounded SAT) to quantum computational complexity (entanglement-bounded quantum SAT). It would place the classical memory phase transition in a broader quantum information-theoretic context.

**Catalog References:**
- `Catalog/Pythagorean/CDCLPathwidth/PhaseTransition.lean` (boundary state count, exponential separation)
- `Catalog/Pythagorean/QuantumBridge/` (quantum-classical bridge framework)

**Proof Strategy:** Use the area law for 1D gapped systems (Hastings, 2007) as the quantum analogue. The key step is showing that pathwidth-bounded interaction graphs can be mapped to effectively 1D systems with bounded interaction range, inheriting the area law.

**Domain Bridges:** Quantum information theory (entanglement entropy, area laws), tensor network methods (MPS, DMRG), condensed matter physics (gapped phases).

**Lineage:** Extends the transfer-matrix bridge (Theorem 4) to the quantum setting.

**Ambition:** 🚀 Grand challenge — would connect two of the deepest threads in computational complexity.
