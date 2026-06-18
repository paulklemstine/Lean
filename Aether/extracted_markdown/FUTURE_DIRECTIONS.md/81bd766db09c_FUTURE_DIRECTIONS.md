# Future Directions: Topological Depth Detection in Arithmetic Graphs

## Synthesis

The formal verification of topological depth detection in volcano graphs opens a systematic research program connecting arithmetic graph theory, persistent homology, and spectral analysis. The central achievement — proving that cycle-rank profiles exactly recover volcano stratification — provides the foundational bridge between topological and arithmetic invariants. The five directions below form a coherent progression: Direction 1 grounds the theory in real arithmetic geometry, Directions 2–3 expand the topological and spectral toolkits, Direction 4 pursues the grand challenge of a complete arithmetic TDA correspondence, and Direction 5 applies the framework to cryptographic practice. Each direction builds on the cycle-profile machinery introduced in this work and extends it toward deeper mathematical structure.

---

## Direction 1: Formalize Real ℓ-Isogeny Volcano Structure in Mathlib

**Conjecture:** For every prime ℓ ≤ 37 and every sufficiently large prime p with an ordinary elliptic curve E/𝔽_p, the ℓ-isogeny graph around E satisfies the tree-below-crater hypothesis of our LayeredVolcano abstraction, except for an exceptional set of density O(1/√p).

**Test:** Implement the ℓ-isogeny graph for small primes ℓ ∈ {2, 3, 5, 7} and primes p up to 10^6. For each vertex, verify the tree-below-crater hypothesis and measure the exceptional density. Fit the decay rate as a function of p.

**Impact:** This would validate the abstract framework against real arithmetic data, transforming a combinatorial theorem schema into a statement about actual elliptic curves. Success would prove that topological depth detection is not merely a graph-theoretic curiosity but a genuine arithmetic-topological phenomenon.

**Catalog References:** `Catalog/Speculative/VolcanoPersistence/Main.lean` — LayeredVolcano definition, cycleProfile, firstCycleRadius_eq_depth theorem.

**Proof Strategy:** Build Lean 4 infrastructure for elliptic curves over finite fields, j-invariants, and ℓ-isogenies using Mathlib's algebraic geometry library. Prove that the Deuring correspondence gives the depth function, and that sub-crater neighborhoods are trees when the conductor is coprime to ℓ.

**Domain Bridges:** Algebraic number theory ↔ combinatorial graph theory ↔ formal verification.

**Lineage:** Directly extends the current LayeredVolcano abstraction to concrete arithmetic objects.

**Ambition:** Grand challenge — requires substantial new Mathlib infrastructure for isogenies.

---

## Direction 2: Full Persistent Homology and Bar-Length Arithmetic Invariants

**Conjecture:** In the persistent homology of radius-filtered ℓ-isogeny neighborhoods, the *death time* of the first H₁ class encodes the crater cycle length, and the total persistence (sum of bar lengths) determines the isomorphism class of the endomorphism ring up to a finite number of possibilities.

**Test:** Compute persistent homology (using ripser or GUDHI) for ℓ-isogeny neighborhoods of all vertices in the 2-isogeny graph of 𝔽_p for primes p ∈ {10007, 100003, 1000003}. Correlate birth-death pairs with endomorphism ring conductors.

**Impact:** Extends the first-cycle-radius invariant to a full barcode, potentially recovering the entire endomorphism ring structure from topological data. This would establish a complete TDA-to-arithmetic dictionary for isogeny graphs.

**Catalog References:** `Catalog/Speculative/VolcanoPersistence/Main.lean` — cycleProfile, eulerChar_ball_eq_one_sub_cycleProfile.

**Proof Strategy:** Define filtered simplicial complexes (flag/clique complexes) on volcano neighborhoods. Use discrete Morse theory to identify critical cells: 0-cells at vertex additions, 1-cells at edge additions that create cycles. Show that critical 1-cells occur exactly at crater-touching radii.

**Domain Bridges:** Algebraic topology (persistent homology) ↔ arithmetic geometry (endomorphism rings) ↔ computational topology (barcode algorithms).

**Lineage:** Extends cycle rank (β₁ surrogate) to full homological computation.

**Ambition:** Grand challenge — would establish a new paradigm for reading arithmetic from topology.

---

## Direction 3: Spectral-Topological Depth Detection via Non-Backtracking Operators

**Conjecture:** For a vertex v at depth d in an ℓ-volcano, the spectral gap of the non-backtracking operator restricted to B_r(v) undergoes a discontinuous change at r = d, and this spectral transition is detectable from the leading eigenvalue alone.

**Test:** Compute the non-backtracking matrix spectrum for ball subgraphs at each radius r = 0, 1, ..., D around vertices of known depth. Plot the leading eigenvalue as a function of r and detect the radius at which it first exceeds √ℓ (the Ramanujan bound for trees).

**Impact:** A spectral depth detector would be computationally faster than cycle-rank computation (matrix-vector products vs. connected component enumeration) and would connect to the Ihara zeta function and Ramanujan graph theory.

**Catalog References:** `Catalog/Speculative/VolcanoPersistence/Main.lean` — firstCycleRadius_stable_under_local_iso (locality of invariants).

**Proof Strategy:** Use the Ihara determinant formula relating the non-backtracking spectrum to the graph zeta function. Show that for tree balls, all eigenvalues lie within the radius-√ℓ disk, while crater-touching balls have eigenvalues exceeding this bound.

**Domain Bridges:** Spectral graph theory ↔ topological data analysis ↔ number theory (Ramanujan bounds).

**Lineage:** Provides a spectral complement to the topological depth detector.

**Ambition:** Solid extension — uses established spectral theory in a new arithmetic context.

---

## Direction 4: Topological Invariants of Hecke Graphs and Moduli Spaces

**Conjecture:** The cycle-profile depth detection mechanism extends to Hecke graphs on modular curves: for the Hecke operator T_ℓ acting on the supersingular locus, the first cycle radius in the Hecke graph of a CM point equals its conductor depth in the order lattice of the quaternion algebra.

**Test:** Compute Hecke graphs T_2 and T_3 for supersingular elliptic curves over 𝔽_{p²} for p ∈ {101, 1009, 10007}. Compute cycle profiles and compare with quaternion order indices.

**Impact:** This would extend the volcano framework from ordinary curves (commutative endomorphism rings) to supersingular curves (non-commutative quaternion algebras), opening a topological window into the most important case for post-quantum cryptography.

**Catalog References:** `Catalog/Speculative/VolcanoPersistence/Main.lean` — LayeredVolcano abstraction (needs generalization to non-layered Hecke graphs).

**Proof Strategy:** Generalize LayeredVolcano to allow non-tree sub-structures. Define depth using quaternion order indices. Show that the Hecke graph locally resembles a volcano near rational CM points.

**Domain Bridges:** Automorphic forms ↔ quaternion algebras ↔ topological data analysis ↔ post-quantum cryptography.

**Lineage:** Extends the ordinary-curve framework to the supersingular setting.

**Ambition:** Grand challenge — would unify ordinary and supersingular arithmetic under a single topological lens.

---

## Direction 5: Practical Cryptographic Navigation via Topological Heuristics

**Conjecture:** In CSIDH-style isogeny protocols operating on supersingular curves, a cycle-profile-based heuristic can distinguish "high-degree" vertices (near the identity in the class group) from "low-degree" vertices with probability ≥ 0.95, using only O(log p) local isogeny evaluations.

**Test:** Implement the cycle-profile classifier in SageMath for the CSIDH-512 parameter set. Measure classification accuracy and computational cost relative to the standard Elkies-algorithm approach.

**Impact:** A practical topological navigator for isogeny-based cryptosystems could impact key exchange efficiency and security analysis. Even a coarse topological classifier (crater vs. non-crater) would reduce the search space for class group actions.

**Catalog References:** `Catalog/Speculative/VolcanoPersistence/Main.lean` — predictDepth_correct, crater_iff_firstCycleRadius_eq_zero.

**Proof Strategy:** Adapt the depth predictor to the CSIDH graph structure (which is not a volcano but has related local geometry). Use the stability theorem to argue that bounded-radius exploration suffices.

**Domain Bridges:** Isogeny-based cryptography ↔ topological data analysis ↔ algorithmic number theory.

**Lineage:** Direct application of the verified depth classifier to a real-world system.

**Ambition:** Solid extension — applies existing theory to a specific computational problem.
