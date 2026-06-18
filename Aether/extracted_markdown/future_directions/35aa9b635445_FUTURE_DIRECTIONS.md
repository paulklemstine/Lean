# Future Directions: Cube Inversion Theory and Three-Cube Representations

## Synthesis

This research cycle established the **Three-Cube Inversion Principle** as a formal, verified bridge between two-cube and three-cube representations of integers. The core identity — if c³ − n = a³ + b³, then n = (−a)³ + (−b)³ + c³ — was proved along with 15+ supporting theorems covering: the taxicab structure of 1729, automatic mod-9 admissibility preservation, the cross-term parametric family 3ab(a+b), Vieta-style reflections, and the double-inversion property. A key negative result was the disproof of cross-term injectivity (the pairs (1,5) and (2,3) both yield 30), which constrains density-theoretic approaches.

The most promising cross-domain connection is between the **Cube Inversion Graph** (a novel structure introduced in this cycle, where edges connect sums of two cubes to integers reachable via overshoot decomposition) and the **density theory of sums of three cubes**. The classical conjecture that every admissible integer has a three-cube representation could potentially be approached through graph-theoretic analysis of the inversion graph's connectivity. The mod-9 preservation theorem guarantees that the inversion graph only reaches admissible integers, aligning it precisely with the target domain. The connection to Carmichael numbers (1729 − 1 = 12³ satisfies Korselt's criterion) suggests that the multiplicative structure of taxicab numbers constrains their inversion-graph neighborhoods in ways that connect to pseudoprimality theory.

The highest breakthrough potential lies in Direction 1 (Inversion Graph Connectivity), which could yield a constructive approach to the three-cube conjecture — or, if the graph has disconnected components among admissible integers, would identify a fundamentally new obstruction beyond mod-9.

---

### Direction 1: Inversion Graph Connectivity and the Three-Cube Conjecture

**Conjecture**: The Cube Inversion Graph (where CubeInvEdge(m, n) holds when m = a³ + b³ for some integers a, b and n = c³ − m for some c) has the property that every admissible integer (n ≢ 4, 5 mod 9) is reachable from some sum of two cubes within a bounded number of steps. Specifically: for every admissible n, there exists k ≤ 3 such that n is k-step reachable in the transitive closure of CubeInvEdge.

**Test**: Computationally enumerate the reachable sets R₁, R₂, R₃ (1-step, 2-step, 3-step reachable integers) up to N = 10⁶. Measure |Rₖ ∩ [1,N]| / |{admissible in [1,N]}| for k = 1, 2, 3. If R₃ covers > 99% of admissible integers, the conjecture is strongly supported. If disconnected components exist, identify their arithmetic structure.

**Impact**: If true, this would give a *constructive* proof strategy for the three-cube conjecture: every admissible n is reachable by a chain of inversion steps from a sum of two cubes, and each step preserves admissibility. If false, the disconnected components would identify integers that resist the inversion approach — potentially revealing new local obstructions beyond mod 9.

**Catalog References**: `MachineLearning/CubeInversion/Structure.lean` (CubeInvEdge, InversionReachable), `MachineLearning/CubeInversion/Inversion.lean` (inversion_preserves_admissibility_concrete), `Algebra/CubeResidues.lean` (sum_three_cubes_not_four_five_mod_nine)

**Proof Strategy**: 
1. Formalize the k-step reachability predicates and prove basic properties (monotonicity, admissibility preservation at each step).
2. Use the cross-term family to establish that R₁ contains all integers of the form 3ab(a+b) — this gives a dense subset.
3. For R₂, show that applying inversion to cross-term integers generates additional integers. The key lemma would be: if n = 3ab(a+b) and c³ − n = d³ + e³, then c³ − 3ab(a+b) has a characterizable arithmetic form.
4. Attempt to prove that R₃ has positive lower density among admissible integers using analytic estimates on the number of sums of two cubes ≤ N (known to be Θ(N^{2/3}/√(log N)) by Hooley/Wooley).

**Domain Bridges**: Number Theory (three-cube conjecture) ↔ Graph Theory (connectivity of CubeInvEdge) ↔ Analytic Number Theory (density of sums of two cubes)

**Lineage**: Builds on this cycle's `CubeInvEdge`, `InversionReachable`, `inversion_preserves_admissibility_concrete`, and `cross_term_inversion_accessible`.

**Ambition**: grand_challenge

---

### Direction 2: Carmichael-Taxicab Duality

**Conjecture**: Among integers n ≤ N that are both Carmichael numbers and sums of two cubes in at least one way, the proportion that are inversion-accessible from their own Korselt decomposition (i.e., where (n−1)^{1/3} exists as an integer c and c³ − n + 1 has a two-cube decomposition) tends to 1 as N → ∞.

More precisely: if n is a Carmichael number with n − 1 = m³, then the overshoot is (m+1)³ − n = (m+1)³ − m³ − 1 = 3m² + 3m. The conjecture is that 3m² + 3m = 3m(m+1) is "usually" a sum of two cubes — i.e., for a positive density of Carmichael numbers with cubic n − 1.

**Test**: Enumerate Carmichael numbers up to 10⁸. For each, check if n − 1 is a perfect cube. For those that are (1729 is the only known small example; verify whether others exist), check whether 3m(m+1) is a sum of two cubes. Even finding a second example would be significant.

**Impact**: If true, this reveals a deep structural connection between Fermat pseudoprimality and cube decomposition, suggesting that the "accident" of 1729 being both a Carmichael number and a taxicab number is part of a systematic pattern. If false (especially if 1729 is the only such number), it characterizes 1729's uniqueness in a new way.

**Catalog References**: `MachineLearning/CubeInversion/Inversion.lean` (korselt_1729, factorization_1729), `MachineLearning/CubeInversion/Defs.lean` (InversionTriple, IsTaxicab)

**Proof Strategy**:
1. Formalize the Korselt criterion and the property of n − 1 being a perfect cube.
2. Prove that if n − 1 = m³ and n is composite, then (m+1)³ − n = 3m² + 3m = 3m(m+1).
3. Study the Diophantine equation 3m(m+1) = x³ + y³ using the theory of elliptic curves (the curve X³ + Y³ = 3m(m+1) is a twist of the Fermat cubic).
4. Connect to the Erdős-Korselt conjecture on the density of Carmichael numbers.

**Domain Bridges**: Carmichael Numbers (pseudoprimality) ↔ Taxicab Theory (two-cube representations) ↔ Elliptic Curves (rational points on cubic twists)

**Lineage**: Builds on this cycle's korselt_1729 and the observation that 1729's factors (7, 13, 19) all appear in its cube decompositions.

**Ambition**: grand_challenge

---

### Direction 3: Overshoot Spectrum Gaps and New Obstructions

**Conjecture**: For certain admissible integers n, the overshoot spectrum {c³ − n : c ∈ ℤ, c³ > n} contains no sums of two positive cubes for c ≤ n^{1/3 + ε}, for any fixed ε > 0. That is, there exist "inversion-resistant" admissible integers whose smallest inversion triple requires a disproportionately large roof c.

**Test**: For each admissible n ≤ 10⁴, find the smallest c such that c³ − n is a sum of two cubes. Plot the distribution of c/n^{1/3}. If this ratio is unbounded (or grows logarithmically), the conjecture is supported. If it is bounded by a constant, the conjecture is false and the inversion principle is more powerful than expected.

**Impact**: If true, identifies a new "inversion obstruction" beyond mod-9 — integers that are admissible but hard to reach via inversion. This would constrain the approach in Direction 1 and suggest the need for different constructive methods. If false, it provides strong evidence that the inversion principle is sufficient for constructive three-cube representations.

**Catalog References**: `MachineLearning/CubeInversion/Structure.lean` (overshoot_residue_coverage), `MachineLearning/CubeInversion/Inversion.lean` (overshoot_13_1729)

**Proof Strategy**:
1. Formalize the "smallest inversion roof" function: minRoof(n) = min{c : c³ − n = a³ + b³ for some a, b > 0}.
2. Use the overshoot residue coverage theorem to constrain which residues of c can possibly yield decomposable overshoots.
3. Connect to the asymptotic density of sums of two cubes in arithmetic progressions: the overshoot c³ − n for fixed n and varying c samples values in a specific residue pattern mod 9, and the density of sums of two cubes in each residue class is known.
4. Attempt to prove an upper bound: minRoof(n) ≤ f(n) for some explicit f.

**Domain Bridges**: Additive Number Theory (density of sums of two cubes) ↔ Analytic Number Theory (distribution in arithmetic progressions) ↔ Computational Number Theory (exhaustive search)

**Lineage**: Builds on overshoot_residue_coverage and the mod-9 residue analysis from this cycle.

**Ambition**: extension

---

### Direction 4: Cross-Term Multiplicity and Taxicab-Like Structures

**Conjecture**: The number of integers n ≤ N with cross-term multiplicity ≥ 2 (i.e., n = 3a₁b₁(a₁+b₁) = 3a₂b₂(a₂+b₂) for distinct coprime pairs (a₁,b₁), (a₂,b₂)) is Θ(N^{2/3}). These "cross-term taxicab numbers" form a structured subfamily of integers with multiple three-cube representations.

**Test**: Enumerate all cross-term values 3ab(a+b) ≤ 10⁶ and count those with multiplicity ≥ 2. Fit the count to N^α and estimate α. The conjecture predicts α ≈ 2/3.

**Impact**: If true, provides a lower bound on the density of integers with multiple three-cube representations, connecting to the Hardy-Littlewood circle method predictions. The exponent 2/3 would match the known density exponent for sums of two cubes, suggesting a deep structural parallel.

**Catalog References**: `MachineLearning/CubeInversion/Structure.lean` (cross_term_not_injective, cross_term_counterexample)

**Proof Strategy**:
1. Study the Diophantine equation a₁b₁(a₁+b₁) = a₂b₂(a₂+b₂) using elementary methods (substitutions, divisibility).
2. Parametrize solutions: if a₁+b₁ = a₂+b₂ = s, then a₁b₁ = a₂b₂, which means a₁, b₁ and a₂, b₂ are roots of the same quadratic — contradicting distinctness. So the sums must differ.
3. Use the substitution u = a+b, v = ab to reduce to the problem of finding distinct (u₁,v₁), (u₂,v₂) with u₁v₁ = u₂v₂ and u² − 4v ≥ 0.
4. Count solutions using divisor function estimates.

**Domain Bridges**: Combinatorial Number Theory (multiplicity of representations) ↔ Algebraic Number Theory (quadratic forms and divisor functions)

**Lineage**: Directly extends the cross_term_not_injective disproof from this cycle.

**Ambition**: extension

---

### Direction 5: Tropical Cube Inversion

**Conjecture**: The inversion principle has a meaningful tropical analogue. In the tropical semiring (ℝ ∪ {−∞}, max, +), the "tropical cube" of x is 3x, and "tropical sum of two cubes" is max(3a, 3b). The tropical inversion principle would state: if 3c − n = max(3a, 3b), then n = min(−3a, −3b, 3c) in some appropriate sense. The conjecture is that the tropical inversion graph has fundamentally different connectivity properties from the classical one — specifically, that it is *always* connected on admissible tropical integers.

**Test**: Formalize tropical cubes and the tropical inversion principle. Check whether the tropical analogue of the mod-9 obstruction exists (it should not, since tropical arithmetic has no modular structure). Prove or disprove connectivity of the tropical inversion graph on ℝ.

**Impact**: If the tropical version is always connected while the classical version may not be, this identifies the arithmetic obstruction as the essential difficulty in the three-cube problem. This would provide a new perspective on why the problem is hard: it is the interaction between additive structure (sums of cubes) and multiplicative structure (modular arithmetic) that creates complexity.

**Catalog References**: `Tropical/` (tropical semiring definitions from Catalog), `MachineLearning/CubeInversion/Structure.lean` (CubeInvEdge, InversionReachable)

**Proof Strategy**:
1. Define tropical cubes and tropical sums using the max-plus semiring.
2. Formalize the tropical inversion principle as an identity in the tropical semiring.
3. Prove that the tropical inversion graph on ℝ is connected (this should follow from the density of tropical sums of two cubes).
4. Compare tropical and classical connectivity to isolate the role of modular arithmetic.

**Domain Bridges**: Tropical Geometry ↔ Number Theory (three-cube conjecture) ↔ Graph Theory (connectivity)

**Lineage**: New direction inspired by this cycle's CubeInvEdge and the Catalog's tropical semiring work.

**Ambition**: extension
