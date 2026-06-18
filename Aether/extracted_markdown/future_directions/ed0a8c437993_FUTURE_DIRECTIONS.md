# Future Directions: Categorical Observational Information Theory

## Synthesis

The compression stability theorems established in this work — monotonicity, rigidity, and strict increase — form the foundation of a **categorical observational information theory**. The central insight is that probe families on finite presheaf models define observational partitions, and enlargement corresponds to partition refinement. This creates a bridge between category theory, information theory, finite model theory, and experimental design.

The five directions below extend this foundation along complementary axes:
1. **Entropic refinement** deepens the invariant from cardinality counting to true information-theoretic measurement.
2. **Approximate separation** extends the theory to noisy/metric settings relevant to engineering.
3. **Active probe selection** transforms the static theory into a dynamic optimization framework.
4. **Categorical Blackwell comparison** elevates the inclusion ordering to a richer comparison of probe families.
5. **Lattice structure of observational partitions** reveals the algebraic structure underlying all the results.

Together, these directions would build a complete toolkit for "observational complexity" that is simultaneously mathematically deep and practically applicable.

---

## Direction 1: Entropic Measurement Invariant

**Ambition:** grand_challenge

**Conjecture:** For any finite presheaf model (Ob, F, r) and probe family P, define the *observational entropy* as:

$$H_{\text{obs}}(P) = \sum_{Y \in \text{Ob}} H(\pi_P(Y))$$

where $\pi_P(Y)$ is the partition of $F(Y)$ induced by probe signatures, and $H$ is the Shannon entropy of a partition (viewing block sizes as a probability distribution via normalization). Then:
1. $P \subseteq P'$ implies $H_{\text{obs}}(P) \leq H_{\text{obs}}(P')$ (entropic monotonicity).
2. $H_{\text{obs}}(P) = H_{\text{obs}}(P')$ iff NoNewSeparation(P, P', r) (entropic rigidity).

**Test:** Formalize `observationalEntropy` in Lean as a sum of Shannon entropies over partition distributions. Prove entropic monotonicity using the log-sum inequality. Test computationally on all presheaf models with ≤ 4 objects and fibers of size ≤ 4.

**Impact:** This would bridge the gap between our combinatorial measurement invariant and the full information-theoretic framework. The cardinality-based invariant cannot distinguish a partition into {3, 1, 1, 1} blocks from one into {2, 2, 1, 1} blocks — both have 4 blocks. Entropy can. This refinement would make the theory directly applicable to channel capacity computations and rate-distortion analysis.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `measurementInvariant_mono`, `measurementInvariant_eq_iff_noNewSeparation`
- `Pythagorean/ProbeComplexity/RepresentableDimension.lean` — `measurementInvariant`, `measurementSpaceImageCard`

**Proof Strategy:** Entropic monotonicity follows from a key lemma: if partition $\pi'$ refines $\pi$, then $H(\pi) \leq H(\pi')$. This is a standard information-theoretic fact (conditioning reduces entropy, applied to the partition algebra). The Lean proof would use `Real.log_le_log` and convexity of $-x \log x$. The rigidity direction requires showing that entropy equality forces identical partitions, which uses strict concavity of $-x \log x$.

**Domain Bridges:** Information theory (Shannon entropy), statistical mechanics (Boltzmann entropy), quantum information (von Neumann entropy), machine learning (cross-entropy loss).

**Lineage:** Extends Theorems 1–4 from cardinality to entropy. The cardinality theorems are the "counting" shadow of the entropic theorems.

---

## Direction 2: Approximate Separation and Metric Probe Theory

**Ambition:** solid_extension

**Conjecture:** For a finite presheaf model where each $F(Y)$ is equipped with a metric $d_Y$, define *$\varepsilon$-separation* by probe family $P$:

$$\text{Sep}_\varepsilon(P, Y, x, y) \iff \|\sigma_P(Y, x) - \sigma_P(Y, y)\| > \varepsilon$$

Then the $\varepsilon$-measurement invariant (count of $\varepsilon$-equivalence classes) is still monotone under probe enlargement, and for sufficiently small $\varepsilon$, exact monotonicity is recovered.

**Test:** Implement $\varepsilon$-separation computationally for presheaf models with real-valued fibers. Test monotonicity for 100 random presheaf models with Gaussian restriction maps at $\varepsilon \in \{0.01, 0.1, 0.5, 1.0\}$. Formalize the Lean statement for the case where fibers are `Fin n` with the discrete metric.

**Impact:** This connects the theory to compressed sensing, dimensionality reduction (Johnson-Lindenstrauss), and robust feature selection. Practical sensor networks operate with measurement noise, and approximate separation is the physically relevant notion.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `ObProbeFamily.SeparatesElements`, `ObProbeFamily.ObsEq`

**Proof Strategy:** For the discrete metric on finite types, $\varepsilon$-separation with $\varepsilon < 1$ is exactly ordinary separation, so the existing theorems apply. For general metrics, use the fact that $\varepsilon$-equivalence classes form a partition that coarsens as $\varepsilon$ grows, and apply the abstract partition refinement lemma.

**Domain Bridges:** Compressed sensing, Johnson-Lindenstrauss lemma, metric geometry, robust statistics, error-correcting codes.

**Lineage:** Generalizes the exact separation theory to the approximate setting. Builds on `ObProbeFamily.SeparatesElements` and `ObProbeFamily.ObsEq`.

---

## Direction 3: Active Probe Selection via Greedy Invariant Maximization

**Ambition:** solid_extension

**Conjecture:** The greedy algorithm that iteratively selects the probe maximizing the marginal increase in the measurement invariant achieves a $(1 - 1/e)$-approximation to the optimal measurement invariant among all probe families of size $k$.

More precisely: let $f(P) = M(P)$ be the measurement invariant. Then $f$ is:
1. Monotone: $P \subseteq P'$ implies $f(P) \leq f(P')$ (already proved).
2. Submodular: $f(P \cup \{z\}) - f(P) \geq f(P' \cup \{z\}) - f(P')$ whenever $P \subseteq P'$.

If both hold, the greedy algorithm achieves the $(1 - 1/e)$ guarantee.

**Test:** Verify submodularity computationally for all presheaf models with 4 objects and fibers of size ≤ 5 (enumerate all such models up to isomorphism). Attempt to prove submodularity in Lean, or find a counterexample. Run the greedy algorithm on 100 random presheaf models and compare to the brute-force optimum.

**Impact:** If the measurement invariant is submodular, the greedy algorithm gives a provably near-optimal sensor placement / feature selection strategy. This would be directly applicable to sensor network design, experimental design, and active learning.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `measurementInvariant_mono`, `strict_increase_of_newSeparation`

**Proof Strategy:** Submodularity of $f(P) = \sum_Y |\text{image}(\sigma_P(Y, \cdot))|$ follows if the objectwise contributions $m_P(Y) = |\text{image}(\sigma_P(Y, \cdot))|$ are each submodular in $P$. This is the "coverage function" — the number of distinct values of a coordinate projection — which is a well-known submodular function.

**Domain Bridges:** Submodular optimization, greedy algorithms, sensor placement, experimental design, active learning, coverage functions.

**Lineage:** Builds directly on `measurementInvariant_mono`. The strict increase theorem `strict_increase_of_newSeparation` ensures the greedy algorithm makes progress whenever unused probes exist.

---

## Direction 4: Categorical Blackwell Comparison of Probe Families

**Ambition:** grand_challenge

**Conjecture:** Define a partial order on probe families by *informational dominance*: $P \succeq Q$ iff for every presheaf model $(F, r)$, $\text{NoNewSeparation}(Q, P, r)$ holds. Then:
1. This is a well-defined partial order (reflexive, transitive, antisymmetric up to equivalence).
2. Inclusion $Q \subseteq P$ implies $P \succeq Q$.
3. $P \succeq Q$ and $Q \succeq P$ iff $P$ and $Q$ induce the same observational partition on every presheaf.
4. This ordering is a lattice when restricted to probe families on a fixed finite type.

This is the categorical analogue of Blackwell's comparison of experiments.

**Test:** Enumerate all probe families on a 4-object category and compute the Blackwell ordering. Verify it forms a lattice. Compare to the inclusion ordering (which is a sub-ordering). Formalize the lattice structure in Lean.

**Impact:** Blackwell's comparison is one of the deepest concepts in statistical decision theory. Formalizing its categorical analogue would create a bridge between statistics and category theory, opening new perspectives on both.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `ObProbeFamily.NoNewSeparation`, `measurementInvariant_eq_iff_noNewSeparation`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `ProbeFamily.IsSeparating.supset`

**Proof Strategy:** The partial order is reflexive (trivially) and transitive (by composition of the no-new-separation property). Antisymmetry (up to equivalence) follows from the iff characterization: if $P \succeq Q$ and $Q \succeq P$, then $M(P) = M(Q)$ for all presheaf models, meaning the two families have identical discriminatory power.

**Domain Bridges:** Statistical decision theory (Blackwell sufficiency), information geometry (Fisher information ordering), quantum information (measurement comparison), economics (Blackwell's theorem in mechanism design).

**Lineage:** This is the natural next level after the monotonicity/rigidity package. The current work proves the special case where one family is a subset of the other; the Blackwell comparison generalizes to arbitrary pairs.

---

## Direction 5: Lattice Structure of Observational Partitions

**Ambition:** solid_extension

**Conjecture:** For a fixed finite presheaf model $(Ob, F, r)$, the set of observational partitions $\{\pi_P : P \in \mathcal{P}(\text{Ob})\}$ (one partition per probe family) forms a finite lattice under the refinement ordering. Furthermore:
1. The bottom element is the trivial partition (empty probe family).
2. The top element is the partition induced by the full probe family.
3. Meet ($\pi_P \wedge \pi_Q$) corresponds to the partition induced by $P \cap Q$.
4. Join ($\pi_P \vee \pi_Q$) corresponds to the partition induced by $P \cup Q$.
5. The measurement invariant is a monotone function on this lattice.

**Test:** For 50 random presheaf models with 3–5 objects and fibers of size 2–6, compute the lattice of observational partitions and verify the lattice axioms. Verify that $\pi_{P \cap Q} = \pi_P \wedge \pi_Q$ and $\pi_{P \cup Q} = \pi_P \vee \pi_Q$. Formalize in Lean at least the monotonicity of the invariant on the lattice.

**Impact:** This would reveal the algebraic structure underlying all the compression stability results. The lattice perspective connects to matroid theory (if the lattice is geometric), Möbius inversion (for computing the invariant via inclusion-exclusion), and the partition lattice literature.

**Catalog References:**
- `Pythagorean/ProbeComplexity/CompressionStability.lean` — `ObProbeFamily.ObsEq`, `ObsEq_of_le`, `card_image_mono_of_refines`

**Proof Strategy:** Property 4 ($\pi_{P \cup Q} = \pi_P \vee \pi_Q$) follows from the definition: $x$ and $y$ are equivalent under $P \cup Q$ iff they are equivalent under both $P$ and $Q$, which is the join (finest common coarsening). Property 3 requires showing that $P \cap Q$ induces the meet (coarsest common refinement), which follows from the coordinate-projection structure of probe signatures.

**Domain Bridges:** Lattice theory, matroid theory, partition lattices, Möbius inversion, combinatorial optimization, algebraic combinatorics.

**Lineage:** The current `card_image_mono_of_refines` theorem is the monotonicity statement for the lattice. The lattice structure gives a richer algebraic framework for analyzing probe families.
