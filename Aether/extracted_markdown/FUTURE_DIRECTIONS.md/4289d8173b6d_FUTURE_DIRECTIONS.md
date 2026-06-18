# Future Directions: The Proof Expansion Program

This document identifies five specific, falsifiable scientific hypotheses arising from the proof expansion constant framework. Each hypothesis is stated precisely, with a concrete test that would confirm or refute it, and a description of the impact if confirmed.

---

## Conjecture 1: Universal Binary Expansion Lower Envelope

**Conjecture.** For every recursively axiomatized, consistent theory $T$ extending Peano Arithmetic, and every "natural" hierarchy of theorems $\{\Phi_n\}_{n \in \mathbb{N}}$ where $\Phi_{n+1}$ is obtained from $\Phi_n$ by a uniform syntactic strengthening operation, there exists a constant $b > 1$ such that for all sufficiently large $m \le n$:

$$\mathrm{ProofLength}_T(\Phi_n) \ge b^{n-m} \cdot \mathrm{ProofLength}_T(\Phi_m).$$

**Test.** Search for hierarchies where semantic distance $n - m \to \infty$ but $\mathrm{ProofLength}(\Phi_n) / \mathrm{ProofLength}(\Phi_m)$ remains bounded by a polynomial in $n - m$. A single explicit family with unbounded distance and polynomial blowup refutes the conjecture. Candidate test families:
- Pigeonhole principles $\mathrm{PHP}^n_{n+1}$ in bounded arithmetic.
- Ramsey statements $R(k, k) \le f(k)$ with decreasing $f$.
- Iterated consistency statements $\mathrm{Con}^{(n)}(T)$.

**Impact.** If true, this would establish that proof complexity has an intrinsic exponential geometry: no clever encoding can avoid the cost of strengthening beyond a certain threshold. This would have profound consequences for automated theorem proving, implying that theorem-proving curricula must respect expansion constants to avoid catastrophic proof-length jumps.

---

## Conjecture 2: Semantic Entropy Correlation

**Conjecture.** Let $\mathcal{M}_N(\phi)$ denote the set of models of $\phi$ over structures of size $\le N$. Define semantic entropy $H_N(\phi) = \log_2 |\mathcal{M}_N(\phi)|$. For natural strengthening hierarchies, there exists $C > 0$ such that:

$$\log_2 \frac{\mathrm{ProofLength}(\Phi_n)}{\mathrm{ProofLength}(\Phi_m)} \ge C \cdot (H_N(\Phi_m) - H_N(\Phi_n))$$

for all sufficiently large $N$ and all $m \le n$.

**Test.** Compute $H_N(\phi)$ and proof lengths for families of propositional tautologies, graph coloring constraints, and SAT instances with parameterized clause density. Plot $\log(\text{proof ratio})$ vs. $\Delta H$ and test for a linear lower envelope. A family where entropy drops sharply but proof length grows sublinearly would refute this.

**Impact.** This would establish a formal bridge between information theory and proof complexity, suggesting that the "work" of proof is bounded below by the information-theoretic cost of semantic compression. This connects to statistical physics: proof cost as thermodynamic work against entropy reduction.

---

## Conjecture 3: Expansion Constant Universality Classes

**Conjecture.** Natural theorem hierarchies fall into finitely many "universality classes" based on their expansion constant. Specifically, for hierarchies over PA:
- **Class I (polynomial):** $b = 1$ (no exponential expansion). Only degenerate/trivial hierarchies.
- **Class II (single exponential):** $b \in (1, 2]$. Includes most arithmetic hierarchies.
- **Class III (double exponential):** Expansion rate is $2^{2^{\Theta(d)}}$. Includes hierarchies involving iterated exponentiation or Ackermann-type growth.

**Test.** Compute empirical expansion constants for:
1. Arithmetic progression statements (van der Waerden-type): $W(k) \le f(k)$.
2. Graph Ramsey statements: $R(k,k) \le g(k)$.
3. Paris-Harrington statements.
4. Friedman's finite forms of Kruskal's theorem.

Measure the best-fit $b$ for each family. If the distribution is continuous rather than clustered, the conjecture is refuted.

**Impact.** If true, this would create a taxonomy of theorem difficulty that transcends individual proof systems, analogous to universality classes in statistical mechanics or computational complexity classes.

---

## Conjecture 4: Expansion-Aware Curriculum Optimality

**Conjecture.** For an automated theorem prover with bounded computational resources, the optimal ordering of a finite set of theorems $\{\Phi_1, \ldots, \Phi_N\}$ to maximize the number proved within a time budget $T$ is a monotone ordering with respect to the proof expansion constant. Specifically, if $\Phi_i$ has expansion constant $b_i$ relative to previously proved theorems, the greedy ordering by increasing $b_i$ is within a factor of $O(\log N)$ of optimal.

**Test.** Implement the expansion-constant ordering for families of Lean/Isabelle theorems from Mathlib or the Archive of Formal Proofs. Compare against:
- Random ordering
- Ordering by statement complexity
- Ordering by proof length
- The greedy expansion-constant ordering

Measure total theorems proved within a fixed ATP time budget. If the expansion-constant ordering performs worse than random on a substantial benchmark, the conjecture is refuted.

**Impact.** This would provide the first principled, theory-grounded curriculum design for automated reasoning systems, potentially accelerating large-scale formalization projects.

---

## Conjecture 5: Model-Shrinkage Distance is a Proof Complexity Invariant

**Conjecture.** For propositional proof systems (Resolution, Frege, Extended Frege), the model-shrinkage distance $d(\phi, \psi) = \log_2(|\text{Mod}(\phi)|/|\text{Mod}(\psi)|)$ provides a lower bound on the ratio of proof lengths:

$$\frac{\mathrm{ProofLength}(\psi)}{\mathrm{ProofLength}(\phi)} \ge 2^{\Omega(d(\phi, \psi))}$$

whenever $\psi$ logically implies $\phi$ and both are provable in the system.

**Test.** Construct explicit CNF formula pairs $(\phi, \psi)$ where:
- $\psi \models \phi$
- The model count ratio is known exactly (e.g., via #SAT solvers like sharpSAT)
- Proof lengths are measured in Resolution and Frege systems

If a family exists where model count drops exponentially but proof length grows only polynomially, the conjecture is refuted.

**Impact.** This would be a breakthrough in proof complexity, providing a new technique for proving proof-length lower bounds via semantic (model-counting) arguments rather than purely syntactic methods. It would connect the #P-hardness of model counting to proof complexity lower bounds in a novel way.

---

## Meta-Observation

All five conjectures share a common theme: **semantic compression (reducing the set of models) forces syntactic inflation (increasing proof length)**. This "no free lunch" principle, if validated even partially, would establish proof expansion as a fundamental invariant of formal reasoning, bridging proof complexity, information theory, model theory, and computational learning theory into a unified geometric framework.

The most immediately testable conjecture is **Conjecture 2** (Semantic Entropy Correlation), as it requires only model counting and proof-length measurement on finite propositional instances. The most impactful if true is **Conjecture 5** (Model-Shrinkage as Proof Complexity Invariant), as it would provide new proof-complexity lower bound techniques.
