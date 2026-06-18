# Future Directions

## Synthesis

This research cycle established a rigorous mathematical framework for the "periodic table of finite groups" by defining the **solvability spectrum** — a novel invariant that decomposes a solvable group's structure into abelian layers, analogous to electron shells. The key discovery is the **solvability gap theorem**: non-nilpotent solvable groups must have solvability depth ≥ 2, creating a provable "energy gap" between the noble-gas-like abelian groups and the more complex solvable groups. This gap, combined with the **Frattini–commutator containment** (the commutator subgroup is trapped inside the Frattini subgroup for nilpotent groups), establishes a clean separation between "inert" and "reactive" group-theoretic behavior.

The most promising cross-domain connection is between the solvability spectrum and the **composition factor theory** from the Catalog's existing work on group solvability (`Catalog/Algebra/GroupSolvability.lean`). The spectrum captures finer information than the composition factors alone: two groups with the same composition factors (same "elements") can have different spectra (different "arrangements"), making the spectrum a richer invariant for classification. The connection to the existing `cyclic_composition_law` in `Pythagorean/FiltrationObstruction.lean` is suggestive — the filtration/obstruction framework may provide tools for studying when the spectrum determines the group.

The highest breakthrough potential lies in Direction 1 (Spectrum Reconstruction), where the key question is whether the solvability spectrum, together with composition factor data, determines the group up to finitely many possibilities. This would be a group-theoretic analogue of the Brauer–Wielandt theorem and would have concrete computational consequences.

---

### Direction 1: Spectrum Reconstruction Conjecture

**Conjecture**: For a finite solvable group G, the solvability spectrum σ_G = (σ_G(0), σ_G(1), ..., σ_G(d-1)) together with the isomorphism types of the abelian composition factors D_n(G)/D_{n+1}(G) determines the isomorphism type of G up to a finite bounded set, where the bound depends only on the spectrum pattern.

**Test**: Enumerate all groups of order 72 with solvability spectrum (2, 2, 9) and (4, 18). Count the number of non-isomorphic groups sharing each spectrum-plus-factor-type pattern. If the count exceeds a polynomial function of the order, the conjecture fails.

**Impact**: If true, this gives a tractable approach to classifying solvable groups: enumerate spectrum patterns (polynomially many in Ω(n)), then for each pattern enumerate the finitely many extensions. If false, the failure boundary would reveal which "chemical bonds" between abelian layers introduce genuine ambiguity.

**Catalog References**: `Catalog/Algebra/GroupSolvability.lean`, `Catalog/Pythagorean/FiltrationObstruction.lean` (cyclic_composition_law)

**Proof Strategy**: Start by proving the conjecture for metabelian groups (depth 2), where G is an extension 1 → A → G → B → 1 with A, B abelian. The extensions are classified by H²(B, A), which is finite. Then use induction on depth. Key lemma needed: bound the number of non-split extensions with given abelian kernel and quotient.

**Domain Bridges**: Algebra (group extensions) ↔ Cohomology (H² computations) ↔ Computation (enumeration algorithms)

**Lineage**: Builds on the solvability spectrum definition and strict descent theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Frattini Stratification Index

**Conjecture**: Define the *Frattini depth* F(G) as the length of the iterated Frattini series Φ_0(G) = G, Φ_{n+1}(G) = Φ(Φ_n(G)). For a finite p-group G of order p^k, the Frattini depth satisfies F(G) ≤ k - rank(G/Φ(G)), where rank denotes the minimal number of generators.

**Test**: Compute the Frattini depth for all groups of order 2^5 = 32 (there are 51 such groups) and verify the bound. A single counterexample disproves the conjecture.

**Impact**: If true, this bounds the "complexity layering" of p-groups by a simple function of order and rank, giving a second axis (complementary to solvability depth) for the periodic table classification. If false, the counterexample reveals p-groups whose Frattini structure is richer than expected.

**Catalog References**: `Algebra/PeriodicTable/Core.lean` (commutator_le_frattini_of_nilpotent)

**Proof Strategy**: Use the Burnside basis theorem: for a p-group G, G/Φ(G) is elementary abelian of rank d = rank(G). Each step of the Frattini series reduces the order by at least a factor of p^d (by the same basis theorem applied to Φ_n(G)). This gives Φ_{k/d}(G) = 1, hence F(G) ≤ ⌈k/d⌉ ≤ k - d + 1.

**Domain Bridges**: Algebra (Frattini theory) ↔ EML (complexity measures) ↔ Computation (group enumeration)

**Lineage**: Extends the Frattini–commutator duality from this cycle.

**Ambition**: extension

---

### Direction 3: Chief Factor Spectrum and the Socle Dual

**Conjecture**: Define the *chief factor spectrum* χ_G as the multiset of orders of chief factors (factors in a chief series) of a finite group G. The chief factor spectrum is uniquely determined by the solvability spectrum for metabelian groups (depth ≤ 2), but not in general for depth ≥ 3.

**Test**: For all groups of order 48 (there are 52), compute both the solvability spectrum and the chief factor spectrum. Find a pair with the same solvability spectrum but different chief factor spectra, or prove this is impossible for groups of this order.

**Impact**: If the conjecture holds, it establishes a clean hierarchy: solvability spectrum → chief factor spectrum → composition factor types, with each level providing strictly finer information. The breakpoint at depth 3 would mean that the "periodic table" needs at least three invariants for full classification.

**Catalog References**: `Algebra/PeriodicTable/Core.lean` (groupValence, IsMinNormal), `Algebra/PeriodicTable/Advanced.lean` (derivedSeries_strictMono_lt_solDepth)

**Proof Strategy**: For metabelian groups, the chief factors refine the derived factors D_0/D_1 and D_1/D_2 = D_1. Since D_1 is abelian, its chief factors are its composition factors. For depth ≥ 3, construct explicit counterexamples using semidirect products with non-isomorphic actions.

**Domain Bridges**: Algebra (chief series) ↔ Bridges (closure operations on subgroup lattices) ↔ Cryptography (group-based protocols)

**Lineage**: Builds on valence theory and the product decomposition theorem from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Solvability and the Depth Function

**Conjecture**: The function d : ℕ → ℕ defined by d(n) = max{solDepth(G) : G solvable of order n} satisfies d(n) = Ω(n) for all n ≥ 2, where Ω(n) is the number of prime factors with multiplicity. In other words, the Quantitative Periodic Law bound is always achievable.

**Test**: For n = 12 = 2² × 3, verify that there exists a solvable group of order 12 with depth 3 = Ω(12). For n = 30 = 2 × 3 × 5, verify depth 3. For n = 2^k, the group is the iterated wreath product Z/2Z ≀ ... ≀ Z/2Z, which should have depth k = Ω(2^k).

**Impact**: If true, this completely characterizes the "height" of the periodic table at each order. Combined with the depth-1-implies-nilpotent theorem, it gives a complete stratification of the row structure.

**Catalog References**: `Catalog/EML/PeriodicTableGroups.lean` (quantitative_periodic_law_conjecture), `Algebra/PeriodicTable/Advanced.lean`

**Proof Strategy**: The lower bound (existence of groups achieving Ω(n)) can be proved by explicit construction: for n = p_1^{a_1} × ... × p_k^{a_k}, construct a solvable group of depth Ω(n) using iterated semidirect products and wreath products. The upper bound Ω(n) is the Quantitative Periodic Law.

**Domain Bridges**: Algebra (wreath products) ↔ Tropical (tropical valuation depth, cf. `Computation/PadicValuationDepth.lean`) ↔ EML (ensemble complexity)

**Lineage**: Extends the solvability gap theorem and the Quantitative Periodic Law from the Catalog.

**Ambition**: grand_challenge

---

### Direction 5: Computational Periodic Table Engine

**Conjecture**: There exists a polynomial-time algorithm that, given a finite group G (by its multiplication table or generators and relations), computes the full periodic table entry: solvability depth, spectrum, valence, family, center order, and Frattini quotient rank.

**Test**: Implement the algorithm for groups up to order 100 using GAP or SageMath. Benchmark runtime against order. Verify that the computed invariants match the theoretical predictions from the Lean-verified theorems.

**Impact**: A practical tool for group-theoretic computation. The algorithm would make the periodic table framework usable for working algebraists and could be integrated into computer algebra systems.

**Catalog References**: `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm), `Algebra/PeriodicTable/Core.lean`

**Proof Strategy**: The derived series can be computed in O(|G|³) by iterated commutator generation. The center is computed in O(|G|²). The Frattini subgroup requires finding all maximal subgroups (potentially exponential in general, but polynomial for solvable groups). Prove polynomial bounds for solvable groups; characterize the computational complexity for general groups.

**Domain Bridges**: Algebra (group algorithms) ↔ Computation (complexity theory) ↔ Cryptography (group-based protocols)

**Lineage**: Applies the theoretical framework from this cycle to computational practice.

**Ambition**: extension
