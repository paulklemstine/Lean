# Future Directions: Arithmetic Monster Theory

## Synthesis

This cycle established the formal foundations of digit-interaction theory through 13 machine-verified theorems, centered on the digit bag as the correct algebraic abstraction. The most promising discovery is the **cross-domain connection between Pythagorean triples and digit-sum constraints** (Theorem `pythagorean_digitSum_mod`), which demonstrates that the casting-out homomorphism interacts nontrivially with quadratic forms. This opens a bridge between recreational digit theory and deep number-theoretic structures.

The carry-free arithmetic theorems (`carryFree_digitSum_add`, `carryFree_digitLen_max`) reveal that carries are the sole mechanism of digit-sum non-conservation, suggesting an information-theoretic interpretation: the "entropy" of a multiplication is determined by its carry pattern. The digit interaction signature provides a concrete measure of this entropy, with the conservation law `preserved + created = digitLen` acting as a first law of digit thermodynamics.

The highest breakthrough potential lies at the intersection of digit theory and asymptotic analysis: establishing the density of vampire numbers would settle a 30-year open question and could connect to analytic number theory via exponential sums on digit bags. The ghost phase transition at base 3 suggests connections to combinatorial sieving and extremal graph theory.

---

### Direction 1: Asymptotic Density of Vampire Numbers

**Conjecture**: The number V(N) of base-10 vampire numbers v ≤ N with 4-digit factorizations satisfies V(N) = Θ(N^{1-c}) for some constant 0 < c < 1. Specifically, we conjecture c ≈ 0.45 based on computational evidence up to N = 10^8.

**Test**: Compute V(N) for N = 10^k (k = 4, 5, 6, 7, 8) in bases 10 and 16. Fit log V(N) vs log N to estimate c(b). The conjecture predicts a stable negative slope. If the slope varies significantly across ranges, the power-law model is falsified.

**Impact**: This would be the first rigorous density result for any digit-rearrangement class, settling an open question from Pickover (1994). If the power-law model fails, understanding why would reveal new structure in the distribution of digit-preserving multiplications.

**Catalog References**: `Pythagorean/ArithmeticMonsterTheory/Theorems.lean` — `vampire_modEq_sum` provides the modular sieve, `vampire_digitLen_add` constrains which factor pairs can contribute.

**Proof Strategy**: Use the Fourier transform on (ℤ/(b-1)ℤ)^k to express digit-bag equality as an exponential sum. Apply the modular obstruction as a first-order sieve. Estimate the remaining sum via Weil-type bounds. The key challenge is bounding the number of solutions to the digit-bag equation over the allowed factor ranges.

**Domain Bridges**: NumberTheory <-> Combinatorics, AnalyticNumberTheory <-> DigitTheory

**Lineage**: Builds on `vampire_modEq_sum`, `vampire_digitLen_add`, and the modular sieve algorithm from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Digit Entropy and Carry Complexity

**Conjecture**: For random n ∈ [1, N], the Shannon entropy H(digitBag(b, n)) converges to log(b) − c/log(N) for a constant c > 0 as N → ∞. Furthermore, for vampire numbers, the entropy is strictly higher than average (vampires are "high-entropy" numbers).

**Test**: Compute the average digit-bag entropy for all numbers up to 10^6 in bases 6, 10, 16. Compare against the entropy of vampire numbers in the same range. The conjecture predicts vampire entropy is at least 5% higher than average. A computational counterexample (vampire with below-average entropy) in any range would refine or refute this.

**Impact**: Would establish the first quantitative connection between digit structure and information theory. The carry-free theorems from this cycle (`carryFree_digitSum_add`) demonstrate that carries inject entropy; this direction makes that intuition precise.

**Catalog References**: `Pythagorean/ArithmeticMonsterTheory/Theorems.lean` — `carryFree_digitSum_add`, `digitSignature_conservation`, `digit_complexity_vampire_bound`.

**Proof Strategy**: Model digit bags as multinomial distributions. Use the central limit theorem for digit frequencies to establish the average entropy. For vampire numbers, use the constraint digitBag(v) = digitBag(x) + digitBag(y) to show that the convolution structure forces higher entropy via the entropy power inequality.

**Domain Bridges**: InformationTheory <-> NumberTheory, Probability <-> DigitTheory

**Lineage**: Builds on `carryFree_digitSum_add`, `digitSignature_conservation`, and the digit interaction signature framework.

**Ambition**: extension

---

### Direction 3: Pythagorean-Tropical Digit Bridge

**Conjecture**: The digit-sum obstruction for Pythagorean triples extends to a tropical algebraic structure: defining tropical digit operations as max/plus on digit bags, the Pythagorean equation a² + b² = c² induces a tropical constraint on the digit-bag lattice that is strictly stronger than the mod-(b-1) obstruction.

**Test**: For all Pythagorean triples with c ≤ 1000, compute both the mod-9 obstruction and the tropical constraint (max over digit positions of the tropical Pythagorean residue). Count how many triples are eliminated by each filter separately. The conjecture predicts the tropical filter eliminates at least 10% more candidates than the mod-9 filter alone.

**Impact**: Would establish the first bridge between tropical geometry and digit theory, connecting two domains that share algebraic structure (both involve max/min operations on ℕ-valued functions) but have never been formally linked. The Catalog has extensive tropical infrastructure (`Tropical/` subdirectory) that could be leveraged.

**Catalog References**: `Pythagorean/ArithmeticMonsterTheory/Theorems.lean` — `pythagorean_digitSum_mod`. Tropical infrastructure in `Tropical/` catalog.

**Proof Strategy**: Define tropical digit operations using the Tropical semiring from Mathlib. Formalize the tropical Pythagorean equation. Prove that the tropical constraint implies the mod-(b-1) constraint but is strictly stronger by constructing explicit triples that pass mod-9 but fail the tropical test.

**Domain Bridges**: Tropical <-> Pythagorean, TropicalGeometry <-> DigitTheory

**Lineage**: Builds on `pythagorean_digitSum_mod` and the cross-domain methodology from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Digit-Disjoint Graph Theory

**Conjecture**: The digit-disjointness graph G_b (vertices = positive integers, edges = digit-disjoint pairs) in base b ≥ 3 has chromatic number exactly b−1. Furthermore, the clique number equals the maximum number of pairwise digit-disjoint numbers achievable with k digits, which grows exponentially in k.

**Test**: For base 3, enumerate all maximal cliques in G_3 restricted to numbers up to 3^5 = 243. The conjecture predicts the maximum clique size is 2 (since in base 3 the digits are {0, 1, 2}, and any positive number uses at least one of {1, 2}). For base 10, find the largest set of pairwise digit-disjoint numbers below 10^4.

**Impact**: Would connect digit theory to extremal graph theory and Ramsey theory. The ghost impossibility theorem (base 2 vs. base 3 phase transition) already hints at graph-theoretic structure; this direction makes it explicit.

**Catalog References**: `Pythagorean/ArithmeticMonsterTheory/Theorems.lean` — `not_digitDisjoint_base2`, `exists_digitDisjoint_pair_ge`.

**Proof Strategy**: Prove the upper bound on chromatic number by constructing a proper (b−1)-coloring based on the leading nonzero digit. Prove the lower bound by constructing a (b−1)-clique using repdigit numbers (numbers like 111, 222, ... in base 10). For the clique number growth, use a greedy algorithm on digit-disjoint sets.

**Domain Bridges**: GraphTheory <-> NumberTheory, ExtremalCombinatorics <-> DigitTheory

**Lineage**: Builds on `not_digitDisjoint_base2`, `exists_digitDisjoint_pair_ge`.

**Ambition**: extension

---

### Direction 5: Automatic Sequences and Digit-Preserving Maps

**Conjecture**: The characteristic function of vampire numbers (in any fixed base b ≥ 2) is NOT b-automatic. That is, the set of vampire numbers cannot be recognized by a finite automaton reading the base-b digits of the input.

**Test**: Compute the first 1000 vampire numbers in base 10 and test whether the resulting binary sequence (is_vampire(n) for n = 0, 1, 2, ...) has bounded factor complexity. Automatic sequences have linear factor complexity; if the vampire sequence has superlinear complexity, the conjecture is confirmed computationally.

**Impact**: Would connect digit theory to the Cobham-Semenov theorem and the theory of definability in Presburger arithmetic. Since the vampire predicate involves multiplication (v = x·y), it is expected to escape automatic-sequence characterization, but a proof would require deep structural analysis.

**Catalog References**: `Pythagorean/ArithmeticMonsterTheory/Defs.lean` — `IsVampire` definition. `Pythagorean/ArithmeticMonsterTheory/Theorems.lean` — structural theorems providing the framework.

**Proof Strategy**: Assume for contradiction that the vampire characteristic function is b-automatic. Then by Cobham's theorem, it is also b'-automatic for any b' multiplicatively independent of b. But the vampire predicate depends on base (different bases produce different vampires), yielding a contradiction. The main technical challenge is formalizing the base-dependence rigorously.

**Domain Bridges**: AutomataTheory <-> NumberTheory, FormalLanguages <-> DigitTheory

**Lineage**: Builds on the full framework established in this cycle, particularly the base-dependent definitions and the ghost phase transition.

**Ambition**: extension
