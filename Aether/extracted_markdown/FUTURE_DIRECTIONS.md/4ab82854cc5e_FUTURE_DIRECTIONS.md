# Future Directions: Sharp Threshold Concentration Theory

## Synthesis

The sharp threshold concentration theory developed here establishes that **local obstruction geometry controls global phase transition sharpness**. The four main theorems — structural characterization of minimal unsatisfiability, finite-size scaling bounds, asymptotic concentration, and influence/susceptibility bounds — form a coherent framework connecting certificate complexity, Boolean function analysis, and statistical physics.

The following directions extend this framework along two axes: **deepening** (tighter bounds, stronger theorems for specific systems) and **broadening** (new application domains, connections to open problems). Each direction is falsifiable and builds directly on the formalized catalog results.

---

## Direction 1: Turán-Integrated Tight Threshold Bounds

**Conjecture.** For the triangle obstruction system on $K_n$, the exact satisfiability threshold equals the Turán number $\text{ex}(n, K_3) = \lfloor n^2/4 \rfloor$, and the unsatisfiability threshold equals $\text{ex}(n, K_3) + 1$, giving transition width exactly 1 and normalized width $1/\binom{n}{2}$.

**Test.** Compute exact transition windows for $n = 3, \ldots, 12$. Verify that $k_{\text{sat}} = \lfloor n^2/4 \rfloor$ in all cases. For $n \leq 7$, this is feasible by exhaustive enumeration. For $n = 8, \ldots, 12$, use the known classification of extremal triangle-free graphs (complete bipartite graphs).

**Impact.** If proved, this would give the *exact* threshold for a natural obstruction system, not just bounds. It would demonstrate that the framework can achieve tight results when combined with extremal graph theory.

**Catalog References.**
- `Pythagorean/SharpThresholdConcentration.lean`: `ObsSys.sat_of_card_lt`, `normalizedTransitionWidth`
- `Catalog/Computation/Hypergraph/Defs.lean`: `transversal_superset`

**Proof Strategy.** Formalize Turán's theorem for triangles (which states that the unique maximum triangle-free graph on $n$ vertices is the complete bipartite graph $K_{\lfloor n/2 \rfloor, \lceil n/2 \rceil}$). Then show: (1) any edge set of size $\leq \text{ex}(n, K_3)$ has a triangle-free superset of the same size (by embedding into the Turán graph), hence is satisfiable; (2) any edge set of size $> \text{ex}(n, K_3)$ must contain a triangle (by the maximality of the Turán graph).

**Domain Bridges.** Extremal graph theory ↔ obstruction systems ↔ phase transitions.

**Lineage.** Extends `ObsSys.sat_of_card_lt` (which gives $k_{\text{sat}} \geq 2$) to the exact value $k_{\text{sat}} = \lfloor n^2/4 \rfloor$.

**Ambition.** 🔬 Solid extension — formalizing a classical result (Turán's theorem) and connecting it to the obstruction framework.

---

## Direction 2: Susceptibility Peak Localization (Grand Challenge)

**Conjecture.** For any monotone obstruction system $(U, \mathcal{O})$, the pivotal count $\chi(k)$ achieves its maximum at some $k^*$ satisfying $k_{\text{sat}} \leq k^* \leq k_{\text{unsat}}$. That is, the **susceptibility peak lies within the transition window**.

**Test.** Compute the full pivotal profile $\chi(k)$ for triangle systems on $K_n$, $n = 3, \ldots, 8$. Verify that $\arg\max_k \chi(k) \in [k_{\text{sat}}, k_{\text{unsat}}]$. Also test on random obstruction systems: generate 100 random hypergraphs on 15 vertices with obstruction sizes 3–5, compute the pivotal profile, and check peak location.

**Impact.** This would establish the pivotal count as a **computable order parameter** that locates the phase transition. In statistical physics, the susceptibility peak is the primary method for locating critical temperatures in finite systems. A rigorous proof would bridge combinatorics and finite-size scaling theory.

**Catalog References.**
- `Pythagorean/SharpThresholdConcentration.lean`: `pivotalCount`, `pivotal_in_obstruction`, `pivotalCount_le_of_obstruction_bound`

**Proof Strategy.** For the lower bound ($k^* \geq k_{\text{sat}}$): if $k < k_{\text{sat}}$, all $k$-sets are satisfiable, so $\chi(k) = 0$, hence the maximum cannot occur here. For the upper bound ($k^* \leq k_{\text{unsat}}$): if $k > k_{\text{unsat}}$, all $k$-sets are unsatisfiable, but also all $(k-1)$-sets might be unsatisfiable, giving $\chi(k) = 0$. The gap requires showing that the peak cannot occur outside the window, which is non-trivial when some sets are satisfiable and others are not at the boundary sizes.

**Domain Bridges.** Statistical physics (susceptibility = $\partial m/\partial h$) ↔ Boolean function analysis (total influence) ↔ combinatorics (pivotal count).

**Lineage.** Extends `pivotalCount_le_ground` and `pivotalCount_le_of_obstruction_bound` to a localization result.

**Ambition.** 🌟 Grand challenge — would establish a new characterization of phase transition location.

---

## Direction 3: Probabilistic Threshold Formalization

**Conjecture.** For a monotone obstruction system $(U, \mathcal{O})$ and the uniform random model where each atom is included independently with probability $p$, the probability of satisfiability transitions from $1 - \epsilon$ to $\epsilon$ in a window of width $O(s / |U|)$ in the $p$ parameter, where $s$ is the maximum obstruction size.

**Test.** For triangle systems on $K_n$, $n = 5, \ldots, 15$, sample $10^5$ random edge sets at various densities $p$. Plot the satisfiability probability as a function of $p$. Fit the transition curve and measure the width of the $[0.1, 0.9]$ quantile window. Compare with the theoretical bound $3/\binom{n}{2}$.

**Impact.** This would connect the finite combinatorial framework to the standard probabilistic setup of threshold theory, making the results directly comparable to the Friedgut–Kalai theorem.

**Catalog References.**
- `Pythagorean/SharpThresholdConcentration.lean`: `sharp_threshold_of_subquadratic`, `normalizedTransitionWidth`
- `Catalog/Pythagorean/CertificatePhaseTransition.lean`: `exists_transition_window`

**Proof Strategy.** Define the satisfiability probability $\text{Pr}_p[\text{Sat}(S)]$ where $S$ is a random subset with each element included independently with probability $p$. Use the Markov/Chebyshev approach: the expected number of obstructions in $S$ is $\sum_{o \in \mathcal{O}} p^{|o|}$. When this is small, satisfiability is likely. When it is large, use the second moment method or Lovász Local Lemma for the converse. The transition width in $p$ follows from the derivative of this expectation.

**Domain Bridges.** Probability theory (random graphs, $G(n,p)$ model) ↔ obstruction systems ↔ threshold phenomena.

**Lineage.** Extends the deterministic transition window (`exists_transition_window`) to a probabilistic setting.

**Ambition.** 🔬 Solid extension — connects formalized results to the standard probabilistic framework.

---

## Direction 4: Non-Monotone Obstruction Systems (Grand Challenge)

**Conjecture.** For "almost monotone" obstruction systems — where the satisfiability predicate is downward-closed except for a set of $\epsilon \cdot 2^{|U|}$ exceptions — the transition width is at most $(1 + \epsilon) \cdot s / |U|$.

**Test.** Construct non-monotone perturbations of the triangle system by randomly declaring $\epsilon$-fraction of unsatisfiable sets to be satisfiable. Compute transition widths and compare with the monotone case. Test for $\epsilon = 0.01, 0.05, 0.1$ and $n = 4, \ldots, 7$.

**Impact.** The satisfiability threshold in random $k$-SAT is the most famous non-monotone phase transition in combinatorics. Extending the obstruction framework to non-monotone systems would open a path toward this central problem.

**Catalog References.**
- `Pythagorean/SharpThresholdConcentration.lean`: `ObsSys.sat_mono` (monotonicity assumption), `ObsSys.minimalUnsat_mem_obstructions`

**Proof Strategy.** Replace the exact monotonicity argument in Theorem 1 with an approximate version. If $S$ is "approximately minimally unsatisfiable" (removing any element makes it satisfiable with probability $\geq 1 - \epsilon$), then $S$ is "close to" an obstruction. Quantify this closeness and propagate through the concentration argument.

**Domain Bridges.** Computational complexity (random SAT) ↔ combinatorics ↔ approximate Boolean function analysis.

**Lineage.** Generalizes `ObsSys.sat_mono` and the entire framework to non-monotone settings.

**Ambition.** 🌟 Grand challenge — paradigm shift from monotone to approximately monotone systems.

---

## Direction 5: Multicolor Obstruction Systems and Pythagorean Triples

**Conjecture.** For the Boolean Pythagorean Triples obstruction system (where obstructions are monochromatic Pythagorean triples in a 2-coloring of $\{1, \ldots, n\}$), the normalized transition width is $O(1/n)$.

**Test.** For $n = 10, 20, \ldots, 100$, use SAT solving to find the exact satisfiability threshold (largest $n$ admitting a valid 2-coloring of $\{1, \ldots, n\}$). Compare with the known result $n^* = 7824$ (Heule, Kullmann, Marek 2016). For smaller instances, compute transition widths directly.

**Impact.** This would connect the sharp threshold theory directly to the Boolean Pythagorean Triples problem — one of the most celebrated results in automated reasoning. It would demonstrate that the obstruction framework applies to the original motivating problem of the catalog.

**Catalog References.**
- `Catalog/Computation/Hypergraph/Defs.lean`: `IsPythagoreanTriple`, `HasMonochromaticTriple`
- `Catalog/Pythagorean/CertificatePhaseTransition.lean`: `satisfiable_of_card_lt_minObstructionSize`

**Proof Strategy.** Model the Pythagorean coloring problem as an obstruction system where atoms are numbers $\{1, \ldots, n\}$ and obstructions are Pythagorean triples $(a, b, c)$ with $a^2 + b^2 = c^2$. The obstruction size is always 3. Apply `sharp_threshold_of_subquadratic` with $s(n) = 3$ and ground set size $n$, giving normalized width $\leq 3/n \to 0$.

**Domain Bridges.** Number theory (Pythagorean triples) ↔ SAT solving ↔ phase transitions ↔ combinatorics.

**Lineage.** Directly extends `sharp_threshold_of_subquadratic` to the Pythagorean setting, connecting the new theory to the catalog's original domain.

**Ambition.** 🔬 Solid extension — direct application of proved theorems to a celebrated problem.
