# Future Directions: The Borsuk-Ulam–Arrow Bridge

## Synthesis

This research cycle established a rigorous formal bridge between Arrow's impossibility theorem and topological obstruction theory, centered on the Kendall distance metric on the symmetric group. The key achievements are: (1) a complete machine-verified proof of Arrow's impossibility theorem for 3 alternatives and 2 voters, decomposed into four modular lemmas (splitting, two contagion directions, and field expansion); (2) the formalization of Kendall distance as a metric, including a proof that the reversal permutation achieves the maximal distance $\binom{n}{2}$, establishing the "preference sphere" as a genuine metric space; and (3) the introduction of Condorcet curvature, a novel geometric invariant measuring how social welfare functions distort preference space geometry, with a proof that dictatorship corresponds to curvature collapse.

The most promising cross-domain connection is between the **decisive coalition ultrafilter structure** and **topological fixed-point theory**. Our contagion lemmas (Theorems `decisive_contagion_ac` and `decisive_contagion_cb`) demonstrate that decisiveness "spreads" through the preference graph like a topological infection — once a voter is decisive for one pair, the interconnected structure of the preference sphere forces decisiveness to propagate to all pairs. This propagation mechanism is the discrete analogue of the Brouwer fixed-point theorem's proof via Sperner's lemma, where local coloring constraints force global consequences. The Condorcet curvature framework from this cycle connects to the `ArrowCurvature/Defs.lean` catalog entry, extending it with quantitative bounds.

The highest breakthrough potential lies in **Direction 1**: proving the decisive contraction principle for arbitrary $k$, which would complete Arrow's theorem in full generality. The key obstacle is constructing explicit permutations on $\text{Fin}\,k$ that satisfy specific ranking constraints — a problem that may benefit from the permutation group machinery already available in Mathlib's `Equiv.Perm` API. Direction 3 (quantitative Arrow bounds) has the highest novelty potential, as it would create an entirely new subfield of "approximate social choice theory."

---

### Direction 1: Decisive Contraction for General $k$ — Completing Arrow's Theorem

**Conjecture**: For any $k \geq 3$, $n \geq 2$, if coalition $S$ with $|S| \geq 2$ is decisive for pair $(a,b)$ under a Pareto + IIA SWF, then there exists a proper subset $T \subsetneq S$ that is decisive for some pair $(c,d)$.

**Test**: Prove the `decisive_contraction_principle` theorem in `Geometry/BorsukUlamArrow.lean` (currently `sorry`). The key step is constructing permutations on $\text{Fin}\,k$ that rank three specified alternatives in a given order. Verify by building the full Arrow theorem for $k = 4$, $n = 3$ as a test case.

**Impact**: This would yield the first complete machine-verified proof of Arrow's impossibility theorem in full generality ($k \geq 3$, $n \geq 2$). It would also validate the topological framework by showing that the splitting + contagion + field expansion structure generalizes beyond the $k=3$, $n=2$ case.

**Catalog References**: `Geometry/BorsukUlamArrow.lean` (this cycle), `Speculative/AutoResearch/TopologicalArrowImpossibility.lean` (prior formalization attempt)

**Proof Strategy**: The main obstacle is constructing permutations on $\text{Fin}\,k$ with prescribed pairwise rankings. For three distinct alternatives $a, b, c \in \text{Fin}\,k$:
1. Define `mkPerm3 (a b c : Fin k) (ha : a ≠ b) (hb : b ≠ c) (hc : c ≠ a) : Equiv.Perm (Fin k)` that places $a$ at rank 0, $b$ at rank 1, $c$ at rank 2, and fills remaining positions arbitrarily.
2. Verify the pairwise ranking properties of `mkPerm3`.
3. Use `mkPerm3` to construct the splitting profile.
4. Apply the same case analysis as our $k=3$ proof.

The key Mathlib lemma needed is `Equiv.Perm.extendDomain` or a construction via `Equiv.swap` compositions.

**Domain Bridges**: Social choice theory ↔ Combinatorial topology (Sperner's lemma analogue), Group theory (permutation group actions) ↔ Metric geometry (Kendall distance)

**Lineage**: Builds on `arrow_impossibility_three`, `decisive_contagion_ac`, `decisive_contagion_cb` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Riemannian Social Choice — Curvature Classification of Impossibility Theorems

**Conjecture**: The Condorcet curvature $\kappa(f, p)$ of any Pareto + IIA SWF concentrates on a single voter as $k \to \infty$. Precisely: for any $\varepsilon > 0$, there exists $K$ such that for $k \geq K$, any Pareto + IIA SWF $f$ satisfies $|\kappa(f, p) - d_K(p_d, \text{id})| < \varepsilon \cdot \binom{k}{2}$ for some dictator $d$, where the bound holds for all profiles $p$.

**Test**: Compute $\kappa(f, p)$ for all dictatorial SWFs on $k = 3, 4, 5$ alternatives with $n = 2$ voters, and verify that the curvature equals $d_K(p_d, \text{id}) - \frac{1}{n}\sum_i d_K(p_i, \text{id})$ exactly. Use `#eval` in Lean to compute Kendall distances for specific permutations.

**Impact**: Would establish a new quantitative framework for social choice theory where impossibility theorems are classified by their "curvature signature." This bridges discrete mathematics with Riemannian geometry in a novel way.

**Catalog References**: `Bridges/ArrowCurvature/Defs.lean` (existing curvature framework), `Geometry/BorsukUlamArrow.lean` (Condorcet curvature definition)

**Proof Strategy**:
1. Define a `PseudoMetricSpace` instance on `Equiv.Perm (Fin k)` using Kendall distance (we have the metric axioms proved).
2. Define sectional curvature via comparison triangles in the Kendall metric space.
3. Prove that the Kendall metric space has non-negative Alexandrov curvature (this is known but not formalized).
4. Classify SWFs by their curvature profile: dictatorial = flat, majority = positively curved, Condorcet cycle = negatively curved.

**Domain Bridges**: Social choice ↔ Riemannian geometry, Metric geometry ↔ Combinatorics (inversions in permutations)

**Lineage**: Builds on `condorcetCurvature`, `curvature_bounded`, `dictator_curvature_collapse` from this cycle, and `ArrowCurvature/Defs.lean`.

**Ambition**: grand_challenge

---

### Direction 3: Quantitative Arrow Bounds — Approximate Social Choice Theory

**Conjecture**: If a SWF $f$ on $k \geq 3$ alternatives with $n$ voters satisfies Pareto and is "$\varepsilon$-IIA" (meaning: the social ranking of $a$ vs $b$ depends on voters' rankings of $a$ vs $b$ for at least $(1-\varepsilon)$ fraction of profiles), then $f$ is "$\delta(\varepsilon)$-dictatorial" for some function $\delta$ with $\delta(\varepsilon) \to 0$ as $\varepsilon \to 0$.

**Test**: For $k = 3$, $n = 2$, enumerate all functions $f : S_3^2 \to S_3$ satisfying Pareto. For each, compute the "IIA violation rate" $\varepsilon$ and the "dictatorship distance" $\delta$ (fraction of profiles where $f(p)$ disagrees with the closest dictatorial SWF). Plot $\delta$ vs $\varepsilon$ and test whether the relationship is monotonic.

**Impact**: Would create a new subfield of "approximate social choice theory" with practical applications to mechanism design. Current impossibility theorems are all-or-nothing; quantitative versions would tell us how much fairness we sacrifice for how much IIA violation.

**Catalog References**: `Geometry/BorsukUlamArrow.lean` (Kendall distance, Arrow's theorem), `Computation/InfoEfficientAlgorithms.lean` (information-theoretic bounds)

**Proof Strategy**:
1. Define $\varepsilon$-IIA: for at least $(1-\varepsilon) \cdot |S_k^n|$ profiles $p$, IIA holds.
2. Define $\delta$-dictatorial: there exists $d$ such that $f$ agrees with dictator $d$ on at least $(1-\delta)$ fraction of profiles.
3. Prove the splitting lemma still works if IIA holds on a "large enough" subset.
4. The contagion argument propagates the approximate decisiveness, losing a factor at each step.
5. Use union bound + IIA to bound the total violation.

**Domain Bridges**: Social choice ↔ Property testing (computer science), Metric geometry ↔ Probability theory

**Lineage**: Builds on `splitting_lemma`, `decisive_contagion_ac`, `decisive_contagion_cb` from this cycle.

**Ambition**: extension

---

### Direction 4: Gibbard-Satterthwaite via Preference Sphere Topology

**Conjecture**: The Gibbard-Satterthwaite theorem (no non-dictatorial, strategy-proof social choice function on $\geq 3$ alternatives is onto) can be proved using the same preference sphere topology, with "strategy-proofness" corresponding to a monotonicity condition on the SWF map.

**Test**: Formalize the Gibbard-Satterthwaite theorem for $k = 3$, $n = 2$ by:
1. Defining strategy-proofness: no voter can benefit by misreporting preferences.
2. Showing that strategy-proofness + surjectivity implies a form of IIA.
3. Applying the Arrow machinery to derive dictatorship.

**Impact**: Would unify the two major impossibility theorems of social choice theory under a single topological framework, and demonstrate the power of the Borsuk-Ulam–Arrow bridge beyond Arrow's theorem alone.

**Catalog References**: `Geometry/BorsukUlamArrow.lean` (Arrow machinery), `Speculative/AutoResearch/TopologicalArrowImpossibility.lean`

**Proof Strategy**:
1. Define a social choice function (SCF) $g : S_k^n \to \text{Fin}\,k$ (maps profiles to a single winner, not a ranking).
2. Define strategy-proofness: for all voters $i$, profiles $p$, and alternative ballots $\sigma'_i$, voter $i$ weakly prefers $g(p)$ to $g(p_{-i}, \sigma'_i)$ under their true preference $\sigma_i$.
3. Prove the "options set" lemma: the set of alternatives achievable by voter $i$ unilaterally changing their ballot is always a contiguous interval in the social ordering.
4. Show that strategy-proofness implies a monotonicity property on the SCF.
5. Derive IIA from monotonicity + surjectivity.
6. Apply Arrow's theorem machinery.

The connection to topology: strategy-proofness is a discrete monotonicity condition, analogous to the requirement that a map between CW complexes preserves cell structure. The Gibbard-Satterthwaite theorem is then a discrete Lefschetz fixed-point theorem.

**Domain Bridges**: Social choice ↔ Fixed-point theory, Mechanism design ↔ Algebraic topology

**Lineage**: Builds on `arrow_impossibility_three` and the contagion lemmas from this cycle.

**Ambition**: extension

---

### Direction 5: Computational Kendall Geometry — Algorithms and Visualization

**Conjecture**: The Kendall distance ball $B_r(\sigma) = \{\tau \in S_n : d_K(\sigma, \tau) \leq r\}$ has cardinality given by the Mahonian distribution $M(n, r) = \sum_{k=0}^{r} p(n, k)$ where $p(n, k)$ is the number of permutations with exactly $k$ inversions. Furthermore, $M(n, r) / n!$ converges to a Gaussian distribution as $n \to \infty$.

**Test**: Implement an algorithm to enumerate $B_r(\text{id})$ for $n = 4, 5, 6$ and $r = 0, 1, \ldots, \binom{n}{2}$. Compare the distribution to the Gaussian approximation. Verify the Mahonian distribution formula computationally.

**Impact**: Would provide computational tools for exploring the geometry of the preference sphere, enabling visualization of voting system properties and experimental discovery of new geometric phenomena.

**Catalog References**: `Geometry/BorsukUlamArrow.lean` (Kendall distance), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**:
1. Prove that inversions are in bijection with adjacent transposition sequences (Kendall distance = number of inversions of $\sigma \circ \tau^{-1}$).
2. Formalize the Mahonian distribution: $\sum_{\sigma \in S_n} q^{d_K(\text{id}, \sigma)} = [n]_q!$ where $[n]_q! = \prod_{k=1}^{n} \frac{1-q^k}{1-q}$.
3. Use generating function techniques to derive the Gaussian approximation.

**Domain Bridges**: Combinatorics ↔ Probability theory, Algebraic combinatorics ↔ Metric geometry

**Lineage**: Builds on `kendallDist`, `kendall_reverse_maximal`, `max_pairs_eq_choose` from this cycle.

**Ambition**: extension
