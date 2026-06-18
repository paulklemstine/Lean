# Future Directions: Arithmetic Persistence Theory

## Synthesis

The theorems proved in this work — monotonicity, jump decomposition, p-adic stability, equivariance, and family separation — establish the first layer of a theory connecting p-adic arithmetic to persistence-style invariants. These results form a coherent foundation: monotonicity and equivariance ensure the construction is well-defined and natural; the jump formula provides a computational handle; stability guarantees robustness; and family separation demonstrates discriminating power.

The five directions below extend this foundation along complementary axes. The first two are **grand challenges** — paradigm-shifting conjectures that, if resolved, would create new mathematical subjects. The remaining three are **solid extensions** building directly on the proved theorems, each achievable with current techniques and offering immediate payoffs. Together, they form a research program that connects number theory, topology, combinatorics, statistical mechanics, and machine learning through the unifying lens of arithmetic filtrations.

---

## Direction 1: Galois Group Recovery from Persistence Laws (Grand Challenge)

**Conjecture:** For each degree n ≥ 4, the empirical distribution of the persistence signature vector `(lowerSupportCard(σ_f, a_f, p, 0), ..., lowerSupportCard(σ_f, a_f, p, T))` over primes p ≤ X determines the Galois group Gal(f) for 100% of squarefree degree-n polynomials f ∈ ℤ[x] with |coefficients| ≤ H, as H → ∞.

**Test:** 
1. Sample 10⁶ random degree-5 polynomials with coefficients in [-10⁴, 10⁴].
2. Compute Galois groups using Magma/Pari-GP.
3. Compute persistence signatures at primes p ≤ 1000.
4. Train a classifier on (signature → Galois group).
5. Measure classification accuracy. Conjecture predicts >99% accuracy for T ≥ 10.

**Impact:** If true, this provides a polynomial-time heuristic for Galois group computation, bypassing discriminant and resolvent methods. It would establish that *all* arithmetic monodromy information is encoded in the persistence statistics of coefficient valuations. If false, the counterexample families would reveal deep arithmetic coincidences of independent interest.

**Catalog References:** `Speculative/ArithmeticPersistence/Defs.lean` — `profile_distinguishes_binomial_from_trinomial`, `filtration_stability_under_padic_congruence`

**Proof Strategy:** 
- Start with degree 4 where only 5 transitive subgroups of S₄ exist.
- Use Chebotarev density theorem to relate Frobenius element distributions to persistence statistics.
- Show that the persistence signature at a prime p encodes the cycle type of Frobenius at p, which by Chebotarev determines the Galois group.

**Domain Bridges:** Number theory ↔ Topological data analysis ↔ Machine learning

**Lineage:** Extends `profile_distinguishes_binomial_from_trinomial` from two specific families to all families.

**Ambition:** ★★★★★ — Would create a new subfield: "arithmetic persistence spectroscopy."

---

## Direction 2: Arithmetic Phase Transitions and Statistical Mechanics (Grand Challenge)

**Conjecture:** The filtration of polynomial support by p-adic weight defines a discrete statistical mechanical model on the lattice of exponent vectors, where the weight function plays the role of energy. The "partition function" Z(β, p) = Σ_{m ∈ σ} β^{monomialWeight(a, p, m)} exhibits phase transitions (in the large-support limit) corresponding to transitions between Galois group types.

The key insight is that the jump profile — the distribution of birth times in the filtration — behaves like the energy level density in a statistical mechanical system. Polynomials with different Galois groups correspond to different "phases" of this system, separated by critical values of the inverse temperature parameter β.

**Test:**
1. For degree-n polynomials with n = 10, 20, 50, compute Z(β, p) for β ∈ [0, 5] and p ≤ 100.
2. Plot ∂²log Z/∂β² as a function of β.
3. Check if sharp peaks (specific heat anomalies) appear at β values that separate Galois types.

**Impact:** Would establish a rigorous connection between arithmetic statistics and statistical mechanics, potentially enabling the use of renormalization group techniques for studying Galois groups of families of polynomials.

**Catalog References:** `Speculative/ArithmeticPersistence/Defs.lean` — `totalPersistenceMass`, `jumpCount`, `filtration_cardinality_jump`

**Proof Strategy:**
- Define the partition function using `totalPersistenceMass` as the total energy.
- Use the jump formula to decompose Z(β, p) into level contributions.
- Apply saddle-point methods in the large-support limit.

**Domain Bridges:** Number theory ↔ Statistical mechanics ↔ Topology

**Lineage:** The `totalPersistenceMass` definition is the "total energy" of the system; the stability theorem provides a notion of thermodynamic stability.

**Ambition:** ★★★★★ — Would bridge arithmetic geometry and statistical physics in a new way.

**Why now?** The formal infrastructure for filtration, jump decomposition, and stability is now machine-verified, providing a rigorous foundation that was previously unavailable.

---

## Direction 3: Higher-Dimensional Persistence via Support Graphs

**Conjecture:** Defining an adjacency graph on exponent vectors (by Hamming distance 1 or coordinate-sharing) and tracking connected components through the filtration produces an H₀ persistence barcode that carries strictly more information than the cardinality profile alone. Specifically, there exist polynomial families indistinguishable by cardinality profiles but separated by component-count profiles.

The key insight is that the spatial arrangement of monomials in exponent space — not just their count — matters for arithmetic classification. Two polynomials can have identical cardinality profiles (same number of monomials at each filtration level) but different connectivity structures (how those monomials are arranged).

**Test:**
1. Define the support adjacency graph where exponent vectors u, v are adjacent if ||u - v||₁ = 1.
2. For bivariate polynomials with support in [0, 10]², compute connected components at each filtration level.
3. Compare component-count profiles between families with identical cardinality profiles.

**Impact:** Upgrades the theory from H₀ cardinality (trivial topology) to H₀ connectivity (nontrivial topology). This is the minimal extension needed to claim genuine "persistence" in the topological sense.

**Catalog References:** `Speculative/ArithmeticPersistence/Defs.lean` — `lowerSupportAtLevel`, `lowerSupportAtLevel_mono`, `lowerSupportAtLevel_succ_eq_union`

**Proof Strategy:**
- Formalize `SimpleGraph` on exponent vectors with the adjacency relation.
- Use `lowerSupportAtLevel_succ_eq_union` to track how new vertices affect connectivity.
- Prove: if a new vertex connects k previously distinct components, the component count decreases by k - 1.

**Domain Bridges:** Combinatorics ↔ Topology ↔ Number theory

**Lineage:** Direct extension of the disjoint decomposition theorem to graph-level invariants.

**Ambition:** ★★★☆☆ — Achievable with current Mathlib graph theory infrastructure.

**Why now?** Mathlib's `SimpleGraph` and connectivity API are now mature enough to support this formalization. The monotonicity and decomposition theorems provide the necessary filtration infrastructure.

---

## Direction 4: Chebotarev Density and Persistence Laws

**Conjecture:** For a degree-n polynomial f with Galois group G, the distribution of `monomialWeight(a_f, p, m)` over primes p (for fixed m) is governed by the Chebotarev density theorem applied to the extension ℚ(α)/ℚ where α is a root of f. Specifically, the density of primes where `monomialWeight = k` is determined by the proportion of conjugacy classes in G with specific cycle structures.

The key insight is that the p-adic valuation of a coefficient a_m = f(m)(α₁)···f(m)(αₙ) (in a suitable sense) relates to the factorization of p in the splitting field, which is governed by Frobenius elements.

**Test:**
1. For f(x) = x⁵ - x - 1 (Galois group S₅), compute v_p(discriminant) for p ≤ 10⁶.
2. Compare the empirical density of {p : v_p(disc) = k} with Chebotarev predictions.
3. Repeat for f(x) = x⁵ + 2 (Galois group F₂₀, solvable).

**Impact:** Would provide the theoretical explanation for *why* persistence signatures determine Galois groups, not just empirical evidence *that* they do.

**Catalog References:** `Speculative/ArithmeticPersistence/Defs.lean` — `monomialWeight`, `jumpCount`, `filtration_stability_under_padic_congruence`

**Proof Strategy:**
- Connect coefficient valuations to ramification indices via the relationship between discriminant valuations and Galois action.
- Use Chebotarev density to compute the limiting distribution of each weight over primes.
- Show that different Galois groups produce different weight distributions.

**Domain Bridges:** Number theory (Chebotarev) ↔ Probability/statistics ↔ Topology

**Lineage:** The stability theorem suggests that persistence laws vary smoothly with coefficients; Chebotarev provides the connection to Galois groups.

**Ambition:** ★★★★☆ — Requires deep number theory but is conceptually clear.

**Why now?** The formal filtration framework provides the correct invariants to connect to Chebotarev; without it, the question couldn't be precisely stated.

---

## Direction 5: Persistence-Based Polynomial Classification via Machine Learning

**Conjecture:** A neural network or gradient-boosted classifier trained on persistence signature features achieves >95% accuracy in predicting the Galois group of random degree-5 polynomials over ℤ, using only the first 20 primes and filtration levels up to 10.

The key insight is that persistence signatures are *computable* (O(|σ| · |P| · T) time), *robust* (by the stability theorem), and *discriminating* (by the separation theorem), making them ideal features for machine learning classification.

**Test:**
1. Generate 10⁶ random degree-5 polynomials with coefficients in [-1000, 1000].
2. Compute Galois groups using Pari-GP.
3. Compute persistence signatures at primes 2, 3, ..., 71 with T = 10.
4. Train XGBoost classifier on 80% of data, test on 20%.
5. Report accuracy, confusion matrix, and feature importance.

**Impact:** Would demonstrate practical utility of the theory for computational algebra. The feature importance analysis would reveal *which* primes and filtration levels carry the most Galois information, guiding further theoretical development.

**Catalog References:** `Speculative/ArithmeticPersistence/Defs.lean` — all definitions and theorems

**Proof Strategy:** Empirical. The formal theorems provide the mathematical foundation justifying the feature space; the ML experiment tests whether it is rich enough for classification.

**Domain Bridges:** Number theory ↔ Machine learning ↔ Topological data analysis

**Lineage:** Combines all theorems: monotonicity ensures the feature space is well-ordered, stability ensures robustness to coefficient noise, and separation ensures discriminating power exists.

**Ambition:** ★★☆☆☆ — Immediately achievable with existing tools. High impact if successful.

**Why now?** The algorithms are implemented and verified; the formal theorems provide mathematical guarantees; modern ML infrastructure makes large-scale experiments trivial.
