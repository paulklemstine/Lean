# Future Directions: Subgroup Thermodynamics

## Synthesis

The subgroup pair pressure framework transforms random generation theory from a collection of ad hoc bounds into a systematic thermodynamic theory. The five formally verified theorems — sieve inequality, entropy-energy bounds, product factorization, and free energy additivity — establish the foundation. The key unifying insight is that generation probability is an emergent observable governed by a partition function over structural obstructions, with phase transitions occurring at the boundary where entropy (number of defects) overcomes energy (index barriers).

The directions below are ordered from most immediately actionable (building directly on verified theorems) to most ambitious (paradigm-shifting conjectures requiring new mathematical infrastructure). Each bridges to at least one domain beyond finite group theory.

---

## Direction 1: Correlation Corrections via Second-Order Pressure

**Conjecture:** Define the second-order pressure
```
pressure₂(G, {Hᵢ}) := ∑_{i<j} (|Hᵢ ∩ Hⱼ| / |G|)²
```
Then the Bonferroni-refined bound
```
P(nongen) ≥ pressure₁ - pressure₂
```
is tight up to O(pressure₃) for families where subgroups have pairwise small intersection.

**Test:** Compute `pressure₂` for maximal subgroups of S_n (n ≤ 8) and compare the two-term inclusion-exclusion bound with exact generation probability. The bound should be within 10% of the exact value for n ≥ 5.

**Impact:** Transforms the sieve from a crude union bound into a convergent series, enabling precision predictions of generation probability.

**Catalog References:** `Pythagorean/SubgroupPressure.lean` — `nongeneratingPairProbability_le_pressure`, `card_mem_pairs_eq_sq`.

**Proof Strategy:** Formalize `pressure₂` via `∑ i in univ, ∑ j in Finset.Ioi i, ...`. Prove the inclusion-exclusion lower bound using `Finset.sum_card_inter_le` or custom Bonferroni lemma. The intersection `Hᵢ ∩ Hⱼ` cardinality requires Mathlib's `Subgroup.inf` API.

**Domain Bridges:** Probabilistic combinatorics (Janson inequality, Lovász Local Lemma); coding theory (weight distribution of linear codes mirrors pressure decomposition).

**Lineage:** Direct extension of Theorem 1 (`nongeneratingPairCount_le_sum_sq`).

**Ambition:** Solid extension — fills a natural gap in the current framework. Confidence: 85% provable with current Mathlib.

---

## Direction 2: Full Wreath Product Phase Transition via O'Nan–Scott Decomposition

**Conjecture:** For `W = Sₖ ≀ Sₘ` in product action, let `{Hᵢ}` be the family of all maximal subgroups preserving a nontrivial block system compatible with the wreath structure. Then there exists a function `ρ*(k)` such that:
- If `m/k < ρ*(k)`, then `P(⟨x,y⟩ = W) > 1 - O(k⁻¹)`.
- If `m/k > ρ*(k)`, then `P(⟨x,y⟩ = W) < 1 - c` for a constant `c > 0`.

Moreover, `ρ*(k) ~ C / pressure(Sₖ, maximal)` for an explicit constant `C`.

**Test:** Enumerate maximal subgroups of `Sₖ ≀ Sₘ` for `km ≤ 12` (using GAP's `MaximalSubgroupClassReps`) and compute exact generation probability via random sampling (10⁶ pairs). Compare with the predicted `ρ*(k)`.

**Impact:** Would be the first rigorous phase transition theorem for random generation in a naturally-occurring family of non-simple groups. Opens connection to complexity theory (hardness of group membership testing in wreath products).

**Catalog References:** `Pythagorean/SubgroupPressure.lean` — `subgroupPairPressure_le_card_div_sq`, `card_div_sq_le_subgroupPairPressure`.

**Proof Strategy:** Use O'Nan–Scott classification for maximal subgroups of wreath products (Praeger 1990, Baddeley–Praeger–Schneider 2006). Classify maximal subgroups into types: block-defect, diagonal, twisted diagonal, product-type, almost simple. Show that for `m/k > ρ*(k)`, block-defect subgroups dominate the pressure. The block-defect contribution is already computed (linear in `m`), so the key challenge is bounding the contributions from the other types.

**Domain Bridges:** Computational group theory (GAP algorithms), permutation group complexity (Babai's quasipolynomial algorithm for graph isomorphism uses similar structural decomposition).

**Lineage:** Extends the block-defect analysis in Section 4 of the research paper from surrogates to genuine wreath products.

**Ambition:** Grand challenge — requires substantial new mathematical infrastructure (O'Nan–Scott for wreath products) but the payoff is enormous. Confidence: 40% achievable within one research cycle.

---

## Direction 3: Large Deviations Rate Function for Nongeneration

**Conjecture:** For a sequence of finite groups `Gₙ` with `|Gₙ| → ∞` and covering families `{Hᵢ⁽ⁿ⁾}`, the nongeneration probability satisfies a large deviation principle:

```
lim_{n→∞} (1/n) log P(⟨x,y⟩ ≠ Gₙ) = -I
```

where the rate function `I` is related to the free energy by `I = limₙ (1/n) F(Gₙ, {Hᵢ⁽ⁿ⁾})`.

**The key insight is** that the free energy additivity theorem provides the superadditivity condition needed for the large deviation principle: for product groups, `F(G₁ × ... × Gₙ) = ∑ᵢ F(Gᵢ)`, so the normalized free energy converges by the subadditive ergodic theorem.

**Why now?** The product factorization theorem (Theorem 3.4) is the first formally verified result establishing the superadditivity of free energy for subgroup families. This is exactly the condition needed to invoke Varadhan's lemma and establish a large deviation principle.

**Test:** Compute `(1/m) F((Sₖ)^m, block-defect family)` for fixed `k` and increasing `m`. This should converge to `F(Sₖ, maximal family)`, confirming the rate function.

**Impact:** Establishes a rigorous bridge between finite group theory and the theory of rare events. The rate function `I` would be a new invariant of group families, measuring the "exponential cost" of nongeneration.

**Catalog References:** `Pythagorean/SubgroupPressure.lean` — `log_subgroupPairPressure_prod`, `subgroupPairPressure_prod`.

**Proof Strategy:** Use the additivity of free energy (already proved) as the key input to a large deviation argument. For i.i.d. product groups, the LDP follows from Cramér's theorem. For wreath products, need to establish a suitable mixing condition.

**Domain Bridges:** Probability theory (large deviations, Cramér's theorem); statistical physics (free energy density, thermodynamic limit); information theory (source coding theorem via rate functions).

**Lineage:** Natural evolution of Theorem 5 (free energy additivity).

**Ambition:** Grand challenge — connecting algebra to probability at a foundational level. Confidence: 30% achievable, but even partial results (e.g., for product groups only) would be significant.

---

## Direction 4: Pressure Spectrum for Classical Groups GL(n,q)

**Conjecture:** For `G = GL(n, q)` with the family of maximal subgroups (Aschbacher classes), the pressure satisfies:

```
pressure(GL(n,q), maximal) ~ C(n) · q^{-2}
```

as `q → ∞` with `n` fixed. The constant `C(n)` counts conjugacy classes of maximal subgroups weighted by their structure constants.

**The key insight is** that for classical groups, the dominant contribution to pressure comes from the stabilizer of a 1-dimensional subspace (a maximal parabolic), which has index `(qⁿ - 1)/(q - 1) ~ qⁿ⁻¹`. As `q → ∞`, this dominates all other contributions.

**Why now?** The entropy-energy framework (Theorems 2a-2b) provides the right language: as `q` grows, the energy penalty `2 log(min index)` grows like `2(n-1) log q`, while the entropy `log |family|` grows like `C · log q`. For `n ≥ 3`, energy dominates, confirming Dixon-type results for classical groups.

**Test:** Compute exact pressure for `GL(2, q)`, `GL(3, q)` for small primes `q` using the known maximal subgroup classification. Verify `C(n)` against the asymptotic formula.

**Impact:** Would extend the thermodynamic framework from symmetric groups to the entire landscape of finite simple groups.

**Catalog References:** `Pythagorean/SubgroupPressure.lean` — `subgroupPairPressure_le_card_div_sq`.

**Proof Strategy:** Use Aschbacher's theorem to classify maximal subgroups of `GL(n,q)` into geometric and non-geometric types. Bound the pressure contribution from each Aschbacher class. The C₁ class (stabilizers of subspaces) gives the dominant contribution; others decay faster.

**Domain Bridges:** Algebraic geometry (subspace stabilizers in linear algebraic groups); finite geometry (spreads, Segre varieties); coding theory (linear codes as subgroups of `F_q^n`).

**Lineage:** Extends the framework from symmetric groups (permutation action) to linear groups (matrix action).

**Ambition:** Solid extension — the subgroup classification is known (Aschbacher 1984), but translating it into pressure formulas requires substantial work. Confidence: 60%.

---

## Direction 5: Percolation on the Subgroup Lattice

**Conjecture:** For a finite group `G`, define a random subgraph of the subgroup lattice by retaining each maximal subgroup `M` independently with probability `p`. The **generation percolation threshold** `p_c(G)` is the smallest `p` such that the retained subgroups cover all nongenerating pairs with probability at least 1/2.

Then `p_c(G)` is determined by the pressure:
```
p_c(G) ~ 1 / pressure(G, maximal subgroups, full family).
```

**The key insight is** that the pressure is the expected number of covering events in the full family. By the second moment method, when `p · pressure > 1`, the expected number of covering maximal subgroups for a random nongenerating pair exceeds 1, which is the threshold for percolation.

**Why now?** The entropy-energy bounds provide control on the variance of the covering count, which is the key input to the second moment method. The product factorization theorem ensures that the percolation threshold behaves multiplicatively under products, giving it the structure of a thermodynamic phase transition.

**Test:** For S_n (n ≤ 6), compute the exact covering probability as a function of `p` by inclusion-exclusion over subsets of maximal subgroups. Identify `p_c` numerically and compare with `1/pressure`.

**Impact:** Establishes a new model of percolation on algebraic lattices, bridging finite group theory with the theory of random graphs and critical phenomena.

**Catalog References:** `Pythagorean/SubgroupPressure.lean` — all five main theorems.

**Proof Strategy:** Use the second moment method (Paley-Zygmund inequality) applied to the random variable `X = ∑ᵢ 1_{Hᵢ retained} · 1_{(x,y) ∈ Hᵢ²}`. First moment = `p · pressure`. Second moment requires `pressure₂` (Direction 1). Apply Lovász Local Lemma for the general case.

**Domain Bridges:** Statistical physics (site percolation, Ising model on lattices); random graph theory (Erdős–Rényi threshold); combinatorial optimization (set cover).

**Lineage:** Synthesizes Directions 1 (correlation corrections) and the main pressure framework.

**Ambition:** Grand challenge — requires new mathematical framework combining percolation theory with subgroup lattice geometry. Confidence: 20%, but the question alone is worth posing. Even negative results (showing pressure does NOT control percolation) would be illuminating.
