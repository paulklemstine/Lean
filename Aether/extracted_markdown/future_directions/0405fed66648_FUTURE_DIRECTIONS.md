# Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the **Group Genome** framework — a formal classification system for finite groups inspired by the chemical periodic table. The key contribution is the **derived depth** invariant, which precisely measures a solvable group's distance from commutativity, together with a seven-class chemical taxonomy (vacuum, noble gas, alkali, alkaline earth, halogen, transition metal, compound) and 16 machine-verified theorems establishing the framework's internal consistency.

The most promising cross-domain connection is between the derived depth and **spectral theory**. The derived series of a group can be viewed as a filtration, and the successive quotients G^(n)/G^(n+1) are abelian groups that carry a natural "spectrum" (their character group). This connects the chemical classification to harmonic analysis on groups — an entirely different branch of mathematics. The stability hierarchy (cyclic → abelian → nilpotent → solvable) corresponds to increasing complexity of the representation theory, suggesting that the derived depth controls the "spectral width" of a group.

The highest breakthrough potential lies in **Direction 1** (Derived Depth Bounds), which connects the Group Genome to number theory via prime factorization. A tight bound would make the genome truly predictive: given only |G|, one could constrain the possible derived depths and hence the chemical classes.

---

### Direction 1: Tight Derived Depth Bounds from Prime Factorization

**Conjecture**: For a solvable group G of order `p₁^{a₁} · p₂^{a₂} · ... · pₖ^{aₖ}`, the derived depth satisfies `d(G) ≤ a₁ + a₂ + ... + aₖ` (the total prime multiplicity, i.e., `Ω(|G|)`). Moreover, this bound is tight: for each n, there exists a solvable group of derived depth exactly n whose order has total prime multiplicity n.

**Test**: Compute the derived depth for all solvable groups of order ≤ 100 and verify the bound. For tightness, construct explicit groups achieving `d(G) = Ω(|G|)` — the iterated wreath product `ℤ/pℤ ≀ ℤ/pℤ ≀ ... ≀ ℤ/pℤ` (n copies) should achieve derived depth n with order p^(p^(n-1)).

**Impact**: If true, this gives the Group Genome predictive power comparable to Mendeleev's original table: knowing only the "atomic number" (group order), one can bound the "chemical properties" (derived depth, hence chemical class). If false, the failure would identify groups where the derived series "wastes" steps — a structurally interesting phenomenon.

**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (derivedDepth, derivedSeries_strictAnti_lt_depth)

**Proof Strategy**: For the upper bound, proceed by induction on Ω(|G|). The key step: if G is solvable and nontrivial, then G/G' is a nontrivial abelian group, so |G'| < |G|, and Ω(|G'|) < Ω(|G|). By induction, d(G') ≤ Ω(|G'|), and d(G) = d(G') + 1 ≤ Ω(|G'|) + 1 ≤ Ω(|G|). For the lower bound, construct iterated semidirect products or wreath products explicitly.

**Domain Bridges**: Number Theory ↔ Group Theory (prime factorization controls group structure), Novelty ↔ Algebra (extending the Group Genome with quantitative bounds)

**Lineage**: Builds on `derivedDepth_pos_of_nontrivial`, `derivedSeries_strictAnti_lt_depth`, and `derivedDepth_le_one_iff_comm` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: The Fitting Stratigraphy — Extending the Genome Beyond Solvability

**Conjecture**: Define the **Fitting height** `h(G)` as the minimum length of a Fitting series (ascending chain where each quotient is the Fitting subgroup of the remainder). Then for a solvable group, `h(G) ≤ d(G) ≤ 2·h(G)`. Moreover, define the **chemical valence** as the number of distinct primes dividing the order of the Fitting subgroup. Then groups with the same Fitting height and chemical valence have the same chemical class in the Group Genome taxonomy.

**Test**: Compute Fitting heights for solvable groups of order ≤ 200. Verify the inequality chain d(G)/2 ≤ h(G) ≤ d(G). Check whether chemical valence correctly predicts class membership.

**Impact**: The Fitting height is in some sense the "correct" complexity measure for solvable groups (it equals the length of the shortest normal series with nilpotent factors). Connecting it to derived depth would unify two different measures of group complexity. The Fitting subgroup acts as the "core" of a solvable group, analogous to the electron core of an atom.

**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (ChemicalClass, derivedDepth)

**Proof Strategy**: Use the fact that each step of the Fitting series reduces both the derived length and the Fitting height. The upper bound d(G) ≤ 2·h(G) follows because each Fitting quotient is nilpotent, hence its derived length is bounded by its nilpotency class. Formalize the Fitting subgroup in Lean (if not already in Mathlib) and prove the chain of inequalities.

**Domain Bridges**: Algebra ↔ Novelty (Fitting theory enriches the chemical classification)

**Lineage**: Direct extension of the Group Genome framework from this cycle.

**Ambition**: extension

---

### Direction 3: Spectral Width of the Derived Filtration

**Conjecture**: For a finite solvable group G, define the **spectral width** as `σ(G) = Σ_{i=0}^{d(G)-1} rank(G^(i)/G^(i+1))`, where rank denotes the minimum number of generators of the abelian group G^(i)/G^(i+1). Then σ(G) equals the minimum number of generators of G. In other words, the "total rank" of the derived filtration equals the generating number.

**Test**: Compute σ(G) and the minimum generating number for all solvable groups of order ≤ 60. A single counterexample disproves the conjecture. If the equality fails, test whether σ(G) ≥ d(G) always holds (a weaker but still interesting bound).

**Impact**: This would establish a deep connection between the "vertical" structure of a group (its derived filtration) and its "horizontal" structure (its generating set). It would mean that the derived depth captures not just qualitative non-commutativity but quantitative complexity. If false, the discrepancy σ(G) - d(G) would define a new invariant measuring how "efficiently" the derived series captures the group's structure.

**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (derivedSeries_strictAnti_lt_depth), `Novelty/CollatzSpectral/Theorems.lean` (spectral methods)

**Proof Strategy**: For abelian groups, σ(G) = rank(G) which equals the minimum generating number by the structure theorem. For general solvable groups, use the Burnside basis theorem and properties of the Frattini subgroup to relate generators to the first quotient G/G'.

**Domain Bridges**: Algebra ↔ Computation (generation complexity), Novelty ↔ EML (spectral analysis of algebraic objects)

**Lineage**: Extends the strict monotonicity theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Chemical Reaction Rules — Semidirect Products and Extensions

**Conjecture**: Define a **chemical reaction** as a group extension `1 → N → G → Q → 1`. Then the chemical class of G is determined by the chemical classes of N and Q together with the action of Q on N, according to explicit "reaction rules." Specifically:
- Noble Gas + Noble Gas → Noble Gas or Alkali (direct product: noble gas iff coprime orders)
- Halogen + Noble Gas → Halogen or Alkaline Earth
- Transition Metal + anything → Compound (if extension is non-split)

**Test**: Enumerate all semidirect products ℤ/pℤ ⋊ ℤ/qℤ for primes p, q ≤ 19 and verify the reaction rules. Then test split extensions of S₃ by ℤ/nℤ for n ≤ 10.

**Impact**: This would make the Group Genome truly predictive for group construction: given the "reactants" (N and Q), one could predict the "product" (G) without computing G explicitly. This is the group-theoretic analogue of predicting reaction products from reactant properties.

**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (classifyGroup, prod_solvable, prod_nilpotent)

**Proof Strategy**: Use the fact that extensions preserve solvability (if both N and Q are solvable, G is solvable). For nilpotency, the situation is more delicate: G is nilpotent iff the extension is central. Formalize the extension classification for semidirect products and prove the reaction rules case by case.

**Domain Bridges**: Algebra ↔ Novelty (extension theory as chemical reactions), Bridges ↔ Novelty (closure operators on group extensions)

**Lineage**: Builds on the product stability theorems from this cycle.

**Ambition**: extension

---

### Direction 5: The Genome Density Function — How Crowded Is Each Chemical Class?

**Conjecture**: Define `ρ(n, C)` = (number of groups of order n in chemical class C) / (total number of groups of order n). Then:
- `ρ(p, nobleGas) = 1` for all primes p (all groups of prime order are cyclic)
- `ρ(p², nobleGas) = 1/(p+1)` (one cyclic group among p+1 abelian groups of order p²... actually there are exactly 2)
- `ρ(n, compound) → 1` as n → ∞ along highly composite numbers (most large groups are non-solvable)

The last claim is the most surprising and controversial — it contradicts the intuition from Burnside's theorem that "most" groups are solvable (which holds for groups of odd order but not in general).

**Test**: Compute ρ(n, C) for all n ≤ 100 and all chemical classes C using GAP. Plot the density curves. Check whether ρ(2^k, alkalineEarth) → 1 as k → ∞ (most 2-groups are nilpotent non-abelian).

**Impact**: This quantifies which chemical classes are "common" and which are "rare" — analogous to natural abundance of elements. The distribution of groups across classes has deep connections to number theory (via the count of groups of given order) and probability (random group theory).

**Catalog References**: `Novelty/PeriodicTable/GroupGenome.lean` (ChemicalClass, classifyGroup)

**Proof Strategy**: For prime orders, use the fact that every group of prime order is cyclic (Lagrange's theorem). For p², use the classification of groups of order p². For the asymptotic claims, use results from the enumerative group theory literature on the dominance of p-groups.

**Domain Bridges**: Number Theory ↔ Novelty (counting functions), Computation ↔ Novelty (algorithmic enumeration)

**Lineage**: Extends the chemical classification from this cycle into quantitative territory.

**Ambition**: extension
