# Future Directions: Arithmetic Persistence Theory

## Synthesis

The theorems proved in this work — exact separation via height signatures, tropical defect equivalence, and certified classification — establish a foundational layer for a new field we call *arithmetic persistence theory*. The core discovery is that persistence-style filtering of Frobenius slope data provably detects the supersingular/finite-height dichotomy. This opens five interconnected research directions, ranging from immediate extensions (height refinement, abelian varieties) to paradigm-shifting conjectures (motivic persistence, arithmetic phase transitions). Each direction builds on the certified separation theorems as its foundational ingredient, and each is falsifiable by explicit computation.

---

## Direction 1: Height Refinement — Distinguishing Finite Heights via Persistence Barcode Statistics

**Conjecture:** For K3 surfaces with finite formal Brauer group height $h \in \{1, \ldots, 10\}$, the persistent rank curve $r_P(t)$ has exactly $h$ distinct jump locations, and the multiset of jump magnitudes determines $h$ uniquely. Specifically, the number of distinct non-zero slope deviations from the symmetry center equals $h$.

**Test:** Construct synthetic slope profiles for each height $h = 1, \ldots, 10$ using the symmetric-pair model (slopes $1 \pm k/h$ for $k = 1, \ldots, h$). Compute the persistent rank curves and verify that the number of jumps equals $h$. Then test on actual Frobenius slope data from Kedlaya's algorithm for diagonal quartic K3 surfaces at small primes.

**Impact:** If successful, this upgrades the binary classifier to a complete height detector, recovering the full invariant $h \in \{1, \ldots, 10, \infty\}$ from persistence data. This would be the first computable persistence-based algorithm for formal group heights.

**Catalog References:** `Speculative/ArithmeticPersistence.lean` — `firstJump_characterization`, `persistentRank_monotone`.

**Proof Strategy:** Define the "jump multiset" as the sorted sequence of deviations $\{|s - c| : s \in S, s \neq c\}$. Prove that distinct heights produce distinct jump multisets under the symmetric-pair normalization. The key lemma is that the jump at position $k/h$ has multiplicity exactly 2 (one from each symmetric partner).

**Domain Bridges:** Connects to spectral theory (the jump multiset is a discrete spectrum), coding theory (the profile acts as a code with minimum distance equal to the minimal deviation), and representation theory (the symmetric pair structure reflects Weyl group symmetry of the root system).

**Lineage:** Direct extension of Theorems 3.1–3.4 in the current work.

**Ambition:** Extension — builds directly on proved theorems.

---

## Direction 2: Arithmetic Persistence for Abelian Varieties and Motives

**Conjecture:** The persistence detection mechanism generalizes to abelian varieties of dimension $g$: for an abelian variety $A/\mathbb{F}_p$ with Newton polygon slopes $\lambda_1 \leq \cdots \leq \lambda_{2g}$, the height signature and tropical defect detect the ordinary/supersingular dichotomy, and the persistent rank curve refines the Newton polygon stratification.

**Test:** For elliptic curves ($g = 1$), the ordinary/supersingular dichotomy is classical. Implement the persistence classifier on slope data $\{0, 1\}$ (ordinary) vs $\{1/2, 1/2\}$ (supersingular) and verify agreement with the Hasse invariant. For $g = 2$, test on Jacobians of genus-2 curves with known Newton polygons.

**Impact:** A unified persistence framework for formal group invariants across all abelian varieties would connect topological data analysis to the Langlands program, where Newton polygon strata play a central role in the geometry of Shimura varieties.

**Catalog References:** `Speculative/ArithmeticPersistence.lean` — `heightSignature_maximal_iff_supersingular`, `tropicalDefect_zero_iff_supersingular`.

**Proof Strategy:** The key insight is that the abstract framework is already type-agnostic: `PrimeSlopeProfile` takes any finite set of rational slopes. For abelian varieties, the symmetry center changes (center = 1/2 for weight-1 cohomology), and the number of slopes is $2g$ instead of 22. Reprove the separation theorems with parameterized center and verify that the proofs are center-independent (they are, by construction).

**Domain Bridges:** Langlands program (Newton polygon strata on Shimura varieties), p-adic Hodge theory (Fontaine's classification), algebraic K-theory (motivic filtrations).

**Lineage:** Generalization of the K3-specific framework to arbitrary dimension.

**Ambition:** Grand challenge — could open a new chapter in the Langlands program.

---

## Direction 3: Tropical Persistence and Min-Plus Homological Algebra

**Conjecture:** The tropical defect function $\tau_P(t) = \max_{s \in S} \max(0, |s - c| - t)$ is the degree-0 term of a richer tropical chain complex whose homology groups detect finer invariants than the height alone. Specifically, define a filtered chain complex in the min-plus semiring with generators indexed by slopes and differentials determined by the deviation structure; the resulting "tropical persistence module" should have barcode decomposition whose long bars correspond to height strata.

**Test:** Implement the tropical chain complex for height-2 and height-3 profiles. Compute the barcode and verify that long bars correspond to large slope deviations (i.e., high-height contributions). Compare with the classical persistence barcode on the Rips complex of the slope point cloud.

**Impact:** This would establish a new branch of homological algebra: *min-plus persistence theory*. Unlike classical persistence over a field, min-plus persistence lacks unique decomposition, making the theory richer and more challenging. The arithmetic setting provides natural examples.

**Catalog References:** `Speculative/ArithmeticPersistence.lean` — `tropicalDefect_zero_iff_supersingular`, `SlopePersistenceModel`.

**Proof Strategy:** The key insight is that the tropical defect is the "sup-norm" of the deviation function on the slope set. A chain complex can be built by taking the nerve of the open cover $\{B_t(c)\}_{t \geq 0}$ of the slope set (balls of radius $t$ around the center). The homology of this nerve captures the connectivity of the thresholded slope set. Prove that H_0 of this complex at parameter $t$ equals the number of connected components of $\{s : |s - c| > t\}$, which for discrete slope sets is simply the number of slopes outside the ball.

**Domain Bridges:** Tropical geometry (min-plus linear algebra), idempotent analysis (Maslov dequantization), statistical mechanics (free energy as tropical limit of partition function).

**Lineage:** Direct extension of the tropical defect theorem.

**Ambition:** Grand challenge — would create a new algebraic theory.

---

## Direction 4: Arithmetic Phase Transitions and Statistical Physics

**Conjecture:** The supersingular/finite-height transition has the structure of a phase transition in a discrete statistical mechanics model. Specifically, define an "arithmetic energy" $E(P) = \sum_{s \in S} |s - c|^2$ and a "partition function" $Z_P(\beta) = \sum_{s \in S} e^{-\beta |s - c|^2}$. The supersingular regime corresponds to the zero-temperature ground state ($E = 0$), and the tropical defect $\tau_P(0)$ acts as an order parameter: it vanishes in the supersingular "phase" and is positive in the finite-height "phase."

**Test:** For each height $h = 1, \ldots, 10$, compute $E(P)$, $Z_P(\beta)$, and the "specific heat" $C(\beta) = -\beta^2 \partial^2 \log Z / \partial \beta^2$. Verify that $C(\beta)$ shows a peak whose location scales with $1/h^2$, signaling a height-dependent crossover.

**Impact:** If the analogy is precise, it imports the powerful machinery of renormalization group theory and universality classes into arithmetic geometry. The distribution of K3 heights across primes could exhibit universal scaling laws analogous to critical exponents.

**Catalog References:** `Speculative/ArithmeticPersistence.lean` — `tropicalDefect_pos_of_finiteHeight`, `IsSupersingularProfile`.

**Proof Strategy:** The key insight is that the tropical defect is the zero-temperature limit of a free energy: $\tau_P(0) = \lim_{\beta \to \infty} \beta^{-1} \log Z_P(\beta)$ when appropriately normalized. Prove this limit formula rigorously and show that the phase transition in the $(\beta, h)$ plane has a well-defined critical curve.

**Why now?** Recent developments in arithmetic statistics (Bhargava's program, Sato-Tate distributions) provide empirical data on how heights are distributed across primes. The statistical physics framework could unify these distributional results under a single thermodynamic picture.

**Domain Bridges:** Statistical mechanics (phase transitions, universality), random matrix theory (eigenvalue statistics), arithmetic statistics (Sato-Tate, Lang-Trotter).

**Lineage:** Reinterpretation of the tropical defect theorem through the lens of statistical physics.

**Ambition:** Grand challenge — paradigm shift connecting arithmetic geometry to statistical physics.

---

## Direction 5: Computable Probes for Reduction Types via Machine Learning

**Conjecture:** A neural network trained on persistence features (height signature curves, tropical defect curves, jump parameters) extracted from Frobenius slope data can predict formal Brauer group heights with accuracy exceeding 95% on held-out K3 families, even when trained only on synthetic slope profiles.

**Test:** Generate 10,000 synthetic slope profiles spanning all heights $h = 1, \ldots, 10, \infty$. Extract persistence feature vectors (persistent rank at 50 evenly-spaced scales, tropical defect at 50 scales, first jump parameter, min deviation). Train a random forest and a small neural network on 80% of the data and evaluate on 20%. Then test on Frobenius data from actual K3 surfaces (computed via Kedlaya's algorithm for small primes).

**Impact:** This would create a practical computational tool for arithmetic geometers: given point-counting data for a K3 surface at a prime, automatically classify the reduction type. The certified correctness theorems provide theoretical guarantees that underpin the ML classifier's reliability.

**Catalog References:** `Speculative/ArithmeticPersistence.lean` — `classifyHeightRegime_correct_supersingular`, `classifyHeightRegime_correct_gap`.

**Proof Strategy:** The key insight is that the certified classifier already achieves perfect accuracy on exact data; the ML layer is needed only to handle noise and to learn the optimal threshold $\varepsilon$ adaptively. Prove a PAC-learning bound: given $n$ profiles with noise $\delta < $ stability radius, the empirical risk minimizer converges to the Bayes-optimal classifier at rate $O(1/\sqrt{n})$.

**Why now?** The convergence of topological data analysis, machine learning, and computational number theory has created all the necessary infrastructure. Point-counting algorithms have matured to handle K3 surfaces at primes up to $\sim 10^6$, providing enough data for meaningful training.

**Domain Bridges:** Machine learning (feature engineering from topological summaries), computational number theory (point counting, Kedlaya's algorithm), cryptography (K3-based hash functions and post-quantum schemes).

**Lineage:** Application of the certified classifier to practical computation.

**Ambition:** Extension — directly applicable engineering of proved theorems.
