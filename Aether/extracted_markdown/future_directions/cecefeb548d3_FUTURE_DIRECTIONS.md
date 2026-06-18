# Future Directions: Geometric Information Theory on Sites

## Synthesis

The subadditivity of the sheaf compression number $\kappa_{\mathrm{sh}}$ under coproducts establishes it as a genuine information measure on geometric data. The compression defect $I_{\mathrm{sh}}(F; G) = \kappa_{\mathrm{sh}}(F) + \kappa_{\mathrm{sh}}(G) - \kappa_{\mathrm{sh}}(F \oplus G) \geq 0$ is a categorical mutual information. Together with the profile capacity bound from the catalog, these results form the foundation of a **geometric information theory on sites**.

The five directions below build a roadmap from this foundation toward a complete entropy calculus for sheaf compression. Directions 1–2 are solid extensions of the current machinery. Directions 3–5 are grand challenges that, if resolved, would establish sheaf compression as a first-class information measure alongside Shannon entropy and Kolmogorov complexity.

All directions reference specific catalog theorems and are formulated to be falsifiable by computational experiment or formal proof.

---

## Direction 1: Equality Criterion for Coproduct Subadditivity

**Conjecture:** $\kappa_{\mathrm{sh}}(J, F \oplus G) = \kappa_{\mathrm{sh}}(J, F) + \kappa_{\mathrm{sh}}(J, G)$ if and only if no jointly admissible family of size $< \kappa_{\mathrm{sh}}(F) + \kappa_{\mathrm{sh}}(G)$ exists.

**Test:** Enumerate all presheaf pairs $(F, G)$ on categories with $\leq 4$ objects and section sets of size $\leq 3$. For each pair, compute both sides and search exhaustively for jointly admissible families. Verify the biconditional.

**Impact:** Characterizes when geometric data sources are "informationally independent" — the presheaf analogue of $I(X;Y) = 0$. This would identify the geometric structures that preclude compression savings.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — `sheafCompressionNumber_coprod_le`, `JointlyAdmissible`
- `Catalog/FINAL/Bridges/SheafCompressionFiniteSite.lean` — `sheafCompressionCards`, monotonicity

**Proof Strategy:** Forward direction follows from Theorem 4 (contrapositive). Reverse direction requires showing that when no small jointly admissible family exists, every coproduct witness has cardinality $\geq \kappa(F) + \kappa(G)$. This likely requires a structural decomposition theorem for coproduct-separating families.

**Domain Bridges:** Information theory (characterization of independent sources), combinatorics (disjointness of separating families), coding theory (source separation).

**Lineage:** Direct extension of Theorems 2 and 4 from `CoproductSubadditivity.lean`.

**Ambition:** Solid extension — completes the subadditivity theory by characterizing the equality case.

---

## Direction 2: Chain Rule for Compression Defect

**Conjecture:** For presheaves $F$, $G$, $H$ on a finite site $(C, J)$, define the conditional compression
$$\kappa_{\mathrm{sh}}(H | G) := \kappa_{\mathrm{sh}}(J, G \oplus H) - \kappa_{\mathrm{sh}}(J, G).$$
Then:
$$I_{\mathrm{sh}}(F; G \oplus H) = I_{\mathrm{sh}}(F; G) + I_{\mathrm{sh}}(F; H | G)$$
where $I_{\mathrm{sh}}(F; H | G) := \kappa_{\mathrm{sh}}(F) + \kappa_{\mathrm{sh}}(H | G) - \kappa_{\mathrm{sh}}(J, F \oplus H | G)$.

**Test:** Enumerate triples $(F, G, H)$ on small categories. Compute all terms and verify the chain rule identity. A single counterexample refutes the conjecture.

**Impact:** If true, this would establish the first chain rule for a categorical information measure, mirroring $I(X; Y, Z) = I(X; Y) + I(X; Z | Y)$ in Shannon theory. This would make $I_{\mathrm{sh}}$ a full-fledged information-theoretic quantity.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — `compressionDefect`, `sheafCompressionNumber_coprod_le`
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — `card_hom_le_profile_capacity`

**Proof Strategy:** If the conditional compression is well-defined (nonnegativity from subadditivity), the chain rule should follow from a "witness decomposition" argument: an optimal witness for $F \oplus G \oplus H$ can be projected to witnesses for the sub-coproducts.

**Domain Bridges:** Information theory (chain rule for mutual information), category theory (iterated coproducts), probability theory (conditional entropy).

**Lineage:** Builds on the compression defect from `CoproductSubadditivity.lean` and the subadditivity theorem.

**Ambition:** Grand challenge — establishing a chain rule for a categorical information measure would be a significant foundational result.

---

## Direction 3: Multiplicative Bound for Products

**Conjecture:** For the pointwise product presheaf $(F \times G)(X) = F(X) \times G(X)$:
$$\kappa_{\mathrm{sh}}(J, F \times G) \leq \kappa_{\mathrm{sh}}(J, F) + \kappa_{\mathrm{sh}}(J, G).$$

More ambitiously: $\kappa_{\mathrm{sh}}(J, F \times G) = \max(\kappa_{\mathrm{sh}}(J, F), \kappa_{\mathrm{sh}}(J, G))$.

**Test:** Enumerate products of presheaf pairs on small categories. Compute $\kappa_{\mathrm{sh}}$ for $F$, $G$, and $F \times G$. Check both the additive and max bounds.

**Impact:** Products represent "simultaneous observation" of two data sources. If the max bound holds, it says that observing two data streams simultaneously requires only as many probes as the harder stream — a powerful "free lunch" theorem. This would distinguish $\kappa_{\mathrm{sh}}$ from entropy (which is additive for products of independent sources).

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/CompressionProduct.lean` — existing product formula work
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — subadditivity methodology

**Proof Strategy:** For the additive bound, the same union-of-witnesses strategy should work (products are separated component-wise). For the max bound, one needs to show that a family separating $F$ also separates $F \times G$ if it separates $G$. This is plausible since product projections are surjective.

**Domain Bridges:** Category theory (product vs coproduct duality), coding theory (joint vs separate coding), information theory (entropy of product sources).

**Lineage:** Dual of the coproduct subadditivity from `CoproductSubadditivity.lean`.

**Ambition:** Solid extension (additive bound) / grand challenge (max bound).

---

## Direction 4: Data Processing Inequality

**Conjecture:** For a natural transformation $\eta : F \Rightarrow G$ (a presheaf morphism):
$$\kappa_{\mathrm{sh}}(J, G) \leq \kappa_{\mathrm{sh}}(J, F)$$
provided $\eta$ is objectwise surjective.

More generally, if $\eta$ is objectwise $k$-to-one: $\kappa_{\mathrm{sh}}(J, G) \leq \kappa_{\mathrm{sh}}(J, F)$.

**Test:** Construct surjective presheaf morphisms on small sites. Verify the inequality. Test with $k$-to-one maps to explore the quantitative version.

**Impact:** This would be the categorical analogue of the data processing inequality $H(g(X)) \leq H(X)$: processing data can only decrease its complexity. Combined with subadditivity, this would complete the axiomatic picture of $\kappa_{\mathrm{sh}}$ as an information measure.

**Catalog References:**
- `Catalog/FINAL/Bridges/SheafCompressionFiniteSite.lean` — `PresheafSeparatedByProbes`, monotonicity
- `Catalog/Pythagorean/ProbeComplexity/Theorems.lean` — profile map injectivity

**Proof Strategy:** If $P$ separates $F$ and $\eta$ is surjective, then $P$ separates $G$: for $s \neq t$ in $G(X)$, lift to $\tilde{s} \neq \tilde{t}$ in $F(X)$ (surjectivity + naturality), find a distinguishing probe for $F$, and push forward through $\eta$.

**Domain Bridges:** Information theory (data processing inequality), category theory (functoriality of complexity), signal processing (lossy compression).

**Lineage:** Uses separation machinery from `SheafCompressionFiniteSite.lean`.

**Ambition:** Grand challenge — would complete the information-theoretic axiomatics.

---

## Direction 5: Spectral Decomposition of Compression

**Conjecture:** For a presheaf $F$ on a finite site with a filtration $0 = F_0 \subseteq F_1 \subseteq \cdots \subseteq F_n = F$ (chain of sub-presheaves), the compression number is bounded by the sum of "graded pieces":
$$\kappa_{\mathrm{sh}}(J, F) \leq \sum_{i=1}^n \kappa_{\mathrm{sh}}(J, F_i / F_{i-1})$$
for suitable quotient presheaves $F_i / F_{i-1}$.

**Test:** Construct filtered presheaves on small sites. Compute compression numbers for all graded pieces and verify the inequality.

**Impact:** This would connect sheaf compression to homological algebra, establishing a "spectral sequence" for information complexity. It would allow computing compression numbers of complex presheaves by decomposition into simpler pieces — analogous to how entropy decomposes along independence structures.

**Catalog References:**
- `Catalog/Pythagorean/ProbeComplexity/CompressionSpectrumStructure.lean` — existing spectral structure
- `Catalog/Pythagorean/ProbeComplexity/CoproductSubadditivity.lean` — subadditivity as base case

**Proof Strategy:** If $F$ has a filtration with semisimple graded pieces (each $F_i / F_{i-1}$ is a coproduct of simple presheaves), apply subadditivity iteratively. The general case requires understanding how separation interacts with exact sequences of presheaves.

**Domain Bridges:** Homological algebra (spectral sequences), representation theory (Jordan–Hölder filtrations), algebraic K-theory (additivity of invariants).

**Lineage:** Extension of coproduct subadditivity to general filtrations.

**Ambition:** Paradigm-shifting — would launch "homological information theory."
