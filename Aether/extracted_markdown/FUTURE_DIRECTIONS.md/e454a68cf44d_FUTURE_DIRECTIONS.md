# Future Directions: Categorical Probe Information Theory

## Synthesis

The chain rule for sheaf compression establishes that compression defect on presheaves over finite sites admits a genuine conditional-information formalism. The key identity $I_{\mathrm{sh}}(F; G \oplus H) = I_{\mathrm{sh}}(F; G) + I_{\mathrm{sh}}(F; H \mid G)$ demonstrates that compression witnesses compose like information-bearing contexts. Combined with monotonicity ($\kappa(F) \leq \kappa(F \oplus G)$), upper bounds ($I_{\mathrm{sh}}(F;G) \leq \min(\kappa(F), \kappa(G))$), symmetry, and the defect decomposition formula, these results constitute a categorical compression calculus.

The following directions extend this foundation along five axes: submodularity (connecting to polymatroid theory), data processing (connecting to channel theory), interaction information (connecting to synergy/redundancy), logarithmic refinement (connecting to Shannon entropy), and computational scalability. Each direction is grounded in specific catalog theorems and proposes precise, testable conjectures.

---

## Direction 1: Submodularity of Sheaf Compression

**Conjecture:** For every finite site $(C, J)$ and presheaves $F, G, H$ with nonempty compression card sets, the sheaf compression number satisfies the submodular inequality:
$$\kappa_{\mathrm{sh}}(F \oplus G) + \kappa_{\mathrm{sh}}(G \oplus H) \geq \kappa_{\mathrm{sh}}(G) + \kappa_{\mathrm{sh}}(F \oplus G \oplus H)$$

**Test:** Exhaustive enumeration over all presheaf triples on categories with ≤ 3 objects and section sets of size ≤ 4. Compute both sides for every triple and report any violation. For the triangle category $a \to b \to c$ with trivial topology, this is approximately $4^3 = 64$ triples.

**Impact:** If true, $\kappa_{\mathrm{sh}}$ defines a polymatroid rank function on the lattice of coproduct-closed presheaf collections. This would immediately import the entire theory of submodular optimization — greedy algorithms, Lovász extensions, matroid intersection — into categorical compression theory.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ChainRule.lean` — `sheafCompressionNumber_coprod_le`, `sheafCompressionNumber_le_coprod_left`
- `Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — `sheafCompressionNumber_coprod_le`

**Proof Strategy:** Use the witness decomposition approach: an optimal witness for $F \oplus G \oplus H$ projects to witnesses for $F \oplus G$ and $G \oplus H$ with controlled overlap. The shared $G$-component creates the submodularity slack. Alternatively, prove via the defect decomposition: submodularity is equivalent to $I_{\mathrm{sh}}(F; H \mid G) \leq I_{\mathrm{sh}}(F; H)$, which states that conditioning cannot increase mutual compression.

**Domain Bridges:** Polymatroid theory, submodular optimization, matroid rank functions, combinatorial optimization

**Lineage:** Extends `sheafCompressionNumber_coprod_le` (subadditivity) and `conditionalCompressionDefect_nonneg` (monotonicity)

**Ambition:** ★★★★ — Would establish sheaf compression as a polymatroid, unlocking algorithmic applications

---

## Direction 2: Data Processing Inequality for Presheaf Morphisms

**Conjecture:** If $\phi: G \to H$ is a natural transformation of presheaves that is "profile-preserving" (i.e., for every probe $Z$ and morphism $f: Z \to X$, the restriction maps factor through $\phi$), then:
$$I_{\mathrm{sh}}(F; H) \leq I_{\mathrm{sh}}(F; G)$$

**Test:** Enumerate all natural transformations between presheaves on the arrow category with section sets of size ≤ 3. For each, check if it is profile-preserving and verify the inequality. A single counterexample would require refining the "profile-preserving" condition.

**Impact:** This would be the sheaf-theoretic data processing inequality, the foundational result of channel theory. It would establish that mutual compression decreases along "information channels" (natural transformations), opening the door to categorical channel capacity, rate-distortion theory, and source coding theorems for structured data.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ChainRule.lean` — `mutualCompression`, `mutualCompression_le_left`
- `Pythagorean/ProbeComplexity/Theorems.lean` — `card_hom_le_profile_capacity`

**Proof Strategy:** Show that a profile-preserving morphism $G \to H$ induces a factorization of the profile map for $F \oplus H$ through the profile map for $F \oplus G$. Then the injectivity of the profile map (from `profileMap_injective`) gives the cardinality bound, which translates to a compression number inequality.

**Domain Bridges:** Channel theory, rate-distortion theory, Markov chains, statistical sufficiency

**Lineage:** Extends `card_hom_le_profile_capacity` (profile capacity bound) and `mutualCompression_le_left` (upper bound)

**Ambition:** ★★★★★ — Grand challenge. Would create categorical channel theory.

---

## Direction 3: Interaction Information and Synergy Detection

**Conjecture:** The ternary interaction information
$$I_{\mathrm{sh}}(F; G; H) := I_{\mathrm{sh}}(F; G) + I_{\mathrm{sh}}(F; H) - I_{\mathrm{sh}}(F; G \oplus H)$$
can be **negative** for suitable presheaves on a finite site, indicating categorical synergy: $F$ shares more information with $(G, H)$ jointly than with each separately.

**Test:** Brute-force search over all presheaf triples on the arrow category and triangle category. Compute $I_{\mathrm{sh}}(F;G;H)$ for each and identify the first negative instance. If no instance exists up to section size 5, conjecture positivity and attempt a proof.

**Impact:** Negative interaction information is a signature of synergistic information in neuroscience, distributed computing, and cryptography. Demonstrating it in the categorical setting would validate sheaf compression as a genuine multi-variate information measure, not merely a pairwise one.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ChainRule.lean` — `mutualCompression`, `conditionalMutualCompression`, `mutualCompression_chain_rule`

**Proof Strategy:** Construct an explicit counterexample. Consider presheaves where $F$'s sections encode a "parity" of $G$ and $H$'s sections — this is the categorical analogue of XOR, which produces synergy in classical information theory. The key is finding presheaves where the coproduct $G \oplus H$ reveals structure invisible to $G$ or $H$ alone.

**Domain Bridges:** Neuroscience (integrated information theory), cryptography (secret sharing), distributed computing (coordination complexity)

**Lineage:** Builds on `mutualCompression_chain_rule` (chain rule) and `conditionalMutualCompression_eq_explicit` (defect decomposition)

**Ambition:** ★★★ — Conceptually important, computationally tractable

---

## Direction 4: Logarithmic Refinement via Profile Capacity

**Conjecture:** Define the **logarithmic compression entropy**:
$$h_{\mathrm{sh}}(J, F) := \log_2 \prod_{Z \in P^*} |F(Z)|$$
where $P^*$ is an optimal separating probe family. Then $h_{\mathrm{sh}}$ satisfies a chain rule analogous to Shannon entropy:
$$h_{\mathrm{sh}}(J, F \oplus G) \leq h_{\mathrm{sh}}(J, F) + h_{\mathrm{sh}}(J, G)$$
with equality iff the optimal probe families for $F$ and $G$ are disjoint.

**Test:** Compute $h_{\mathrm{sh}}$ on all presheaves over the arrow category with section sizes ≤ 4. Verify subadditivity and characterize equality cases.

**Impact:** This bridges sheaf compression to classical information theory by replacing the combinatorial compression number (probe count) with a capacity-weighted entropy. It would enable direct comparison with Shannon entropy and provide tighter bounds for applications.

**Catalog References:**
- `Pythagorean/ProbeComplexity/Theorems.lean` — `card_hom_le_profile_capacity`
- `Pythagorean/ProbeComplexity/ChainRule.lean` — `sheafCompressionNumber_coprod_le`

**Proof Strategy:** Use `card_hom_le_profile_capacity` to bound section counts by profile products. The logarithm converts products to sums, giving the subadditivity. Equality analysis requires understanding when optimal probe families can be "merged" without waste.

**Domain Bridges:** Shannon entropy, source coding, rate-distortion theory, counting complexity

**Lineage:** Direct extension of `card_hom_le_profile_capacity` into the chain rule framework

**Ambition:** ★★★★ — Bridges discrete compression to continuous information theory

---

## Direction 5: Computational Complexity of Compression Numbers

**Conjecture:** Computing $\kappa_{\mathrm{sh}}(J, F)$ for a finite site with $n$ objects is NP-hard in general (under appropriate encodings of the presheaf and topology), but admits polynomial-time algorithms when:
1. The underlying category is a tree (no directed cycles)
2. The topology is trivial or discrete
3. All section sets have bounded size

**Test:** Implement the exhaustive algorithm and measure runtime scaling on random categories with $n = 3, 4, 5, 6, 7$ objects. Identify the phase transition where exhaustive search becomes infeasible. For special cases, implement polynomial algorithms and verify correctness against the exhaustive baseline.

**Impact:** Understanding the computational complexity of compression numbers is essential for practical applications. Polynomial algorithms for special cases would enable sheaf compression to be applied to real-world datasets (databases, networks, sensor arrays) at scale.

**Catalog References:**
- `Pythagorean/ProbeComplexity/ChainRule.lean` — all compression number definitions
- `Pythagorean/ProbeComplexity/Defs.lean` — `ProbeFamily.IsSeparating`

**Proof Strategy:** For the NP-hardness direction, reduce from SET COVER: given a universe $U$ and collection $\mathcal{S}$, construct a category where objects correspond to sets, morphisms encode element membership, and the compression number equals the minimum cover size. For polynomial cases, exploit tree structure for dynamic programming or bounded section size for constraint propagation.

**Domain Bridges:** Computational complexity, approximation algorithms, parameterized complexity, database query optimization

**Lineage:** Motivated by the exhaustive search algorithm in `algorithms.py`

**Ambition:** ★★★ — Practical importance, connects to CS theory
