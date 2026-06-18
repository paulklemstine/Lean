# Future Directions: The Periodic Table of Finite Groups

## Synthesis

This research cycle established the foundational framework for a "chemical classification" of finite groups, proving nine core theorems that formalize the analogy between Mendeleev's periodic table and finite group theory. The key insight is that the derived series provides a natural "electron configuration" for groups, with the derived length serving as the primary invariant. The cross-domain Euler-Group Bridge theorem (connecting Euler's totient φ(n) to the unit group order |(ℤ/nℤ)ˣ|) demonstrates that number-theoretic properties of the group order directly determine algebraic structure — a connection with immediate applications to cryptography and coding theory.

The most promising cross-domain connection from this cycle is the bridge between group solvability and molecular spectroscopy: the chemical series of a molecule's symmetry group correlates with the complexity of its spectral selection rules. This connection, if formalized, could yield computable predictions about molecular spectra from purely algebraic data. The isotope concept (groups with equal derived length) provides a novel equivalence relation that could unify disparate classification schemes across algebra, combinatorics, and representation theory.

The highest breakthrough potential lies in Direction 1 (formalizing Burnside's theorem), which would close the last remaining sorry in our Lean development and demonstrate that deep character-theoretic results can be machine-verified. Direction 3 (the spectroscopy bridge) has the highest impact potential for cross-domain applications.

---

### Direction 1: Formalizing Burnside's p^a q^b Theorem via Transfer Theory

**Conjecture**: Every finite group of order p^a · q^b, where p and q are primes, is solvable. This is Burnside's theorem (1904), which is known to be true but has never been fully formalized in a proof assistant.

**Test**: Formalize the proof using transfer theory (Bender's approach, avoiding character theory). The key steps are:
1. Prove that a minimal counterexample has a non-trivial center (using the class equation)
2. Apply Burnside's normal p-complement theorem
3. Use induction on the group order

If the transfer-theory approach fails, attempt the character-theory approach, which requires formalizing:
- Group representations over ℂ
- Character orthogonality relations
- Burnside's lemma on zeros of characters

**Impact**: If formalized, this would be the deepest result in finite group theory ever machine-verified, demonstrating that early 20th-century algebra can be fully mechanized. If the formalization reveals unexpected difficulties, it would map the precise boundary of current proof assistant capabilities for algebra.

**Catalog References**: `Algebra/PeriodicTable/Theorems.lean` (theorem `burnside_pq_conjecture`)

**Proof Strategy**: 
1. Formalize Burnside's transfer homomorphism in Mathlib
2. Prove the normal p-complement theorem (Burnside)
3. Establish the class equation for p-groups
4. Chain these together for the main result
Key lemmas needed: `Sylow.center_nontrivial`, `transfer_homomorphism`, `normal_complement_of_prime_power_index`

**Domain Bridges**: Algebra <-> Representation Theory, Algebra <-> Number Theory

**Lineage**: Builds on `nobleGas_is_solvable`, `nonabelian_simple_not_solvable`, and the solvability theorems from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Composition Factor Periodic Law — Do Groups with Isomorphic Composition Factors Share Properties?

**Conjecture**: If two finite solvable groups G and H have the same multiset of composition factors (up to isomorphism), then they have the same derived length.

**Test**: 
1. Enumerate all groups of order ≤ 100 using GAP or similar
2. Compute composition factors and derived lengths
3. Check whether the conjecture holds for all pairs with matching composition factors
4. If a counterexample is found, weaken the conjecture to: same composition factors implies derived length within ±1

**Impact**: If true, this would justify the "periodic law" analogy — groups in the same "column" (same composition factors) share key algebraic properties. If false, the counterexample would reveal which structural features beyond composition factors determine derived length (likely extension types).

**Catalog References**: `Algebra/PeriodicTable/Theorems.lean` (definition `derivedLength`, theorem `abelian_derivedSeries_stabilizes`)

**Proof Strategy**:
1. Formalize the Jordan-Hölder theorem (composition factor uniqueness)
2. Define a `compositionFactorMultiset` function
3. State and prove (or disprove) the conjecture for specific families (p-groups, metabelian groups)
4. Key Mathlib tools: `JordanHolder` module, `Multiset`, `derivedSeries`

**Domain Bridges**: Algebra <-> Combinatorics (multiset theory)

**Lineage**: Extends the chemical series classification and isotope concept from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: The Spectroscopy Bridge — Connecting Group Solvability to Molecular Spectral Complexity

**Conjecture**: The number of independent spectroscopic selection rules for a molecule with symmetry group G is bounded above by the derived length of G plus one. Specifically, if G is solvable with derived length d, then the number of irreducible representations of G is at most |G|^{d/(d+1)}.

**Test**: 
1. Compute the number of irreducible representations for symmetry groups of known molecules (H₂O, NH₃, CH₄, C₆₀)
2. Compare with the derived length of each symmetry group
3. Verify the bound for all groups of order ≤ 60

**Impact**: If true, this provides a purely algebraic prediction about molecular spectroscopy — chemists could estimate spectral complexity from the symmetry group alone, without computing representations. This would connect the `Compound` and `Radioactive` chemical series directly to observable physical properties.

**Catalog References**: `Algebra/PeriodicTable/Theorems.lean`, `EML/AdvancedTheory.lean` (for measure-theoretic foundations)

**Proof Strategy**:
1. Formalize the character table of a finite group
2. Prove that the number of irreducible representations equals the number of conjugacy classes
3. Bound the number of conjugacy classes using the derived length
4. Key Mathlib tools: `Representation`, `ConjClasses`, `derivedSeries`

**Domain Bridges**: Algebra <-> Physics (molecular spectroscopy), Algebra <-> Chemistry

**Lineage**: Extends the chemical analogy from this cycle to actual chemistry/physics applications.

**Ambition**: extension

---

### Direction 4: Group-Theoretic Entropy and Information Theory

**Conjecture**: The Shannon entropy of the conjugacy class distribution of a finite group G satisfies:
$$H(G) = -\sum_{C \in \text{ConjClasses}(G)} \frac{|C|}{|G|} \log \frac{|C|}{|G|} \leq \log(\text{derivedLength}(G) + 1) + \log \log |G|$$

**Test**:
1. Compute H(G) for all groups of order ≤ 60 using GAP
2. Compare with the conjectured bound
3. Identify groups that are tight (equality or near-equality)

**Impact**: If true, this connects algebraic structure (derived length) to information theory (entropy), providing a quantitative measure of "group complexity" that bridges algebra and information science. The bound would imply that solvable groups with low derived length have low information content — formalizing the "noble gas = simple" intuition.

**Catalog References**: `EML/AdvancedTheory.lean` (ensemble complexity), `Algebra/PeriodicTable/Theorems.lean`

**Proof Strategy**:
1. Formalize the conjugacy class distribution as a probability measure
2. Compute entropy using `MeasureTheory.entropy` or custom definitions
3. Use the class equation and bounds on conjugacy class sizes
4. Key tools: `ConjClasses`, `MeasureTheory.Measure.entropy`, `derivedLength`

**Domain Bridges**: Algebra <-> Information Theory, Algebra <-> MachineLearning

**Lineage**: Extends the "reactivity" concept from this cycle to an information-theoretic measure.

**Ambition**: extension

---

### Direction 5: Automated Group Classification via Tropical Geometry

**Conjecture**: The chemical series of a finite group G can be determined from the "tropical spectrum" of its Cayley graph — specifically, from the min-plus eigenvalues of the adjacency matrix of the Cayley graph with respect to a generating set.

**Test**:
1. Compute Cayley graphs for all groups of order ≤ 30 with standard generating sets
2. Compute the tropical spectrum (min-plus eigenvalues) of each Cayley graph
3. Cluster groups by tropical spectrum and compare with chemical series classification
4. Train a simple classifier (decision tree) on tropical spectra to predict chemical series

**Impact**: If successful, this provides a purely combinatorial/tropical method for group classification, bypassing the need for abstract algebraic computation. This would connect the catalog's Tropical geometry work directly to the group classification framework.

**Catalog References**: `Tropical/` directory, `Bridges/TropicalSatakeTop2Margin.lean`, `Algebra/PeriodicTable/Theorems.lean`

**Proof Strategy**:
1. Formalize the Cayley graph construction for finite groups
2. Define the tropical adjacency matrix and its eigenvalues
3. Prove that cyclic groups (noble gases) have tropical spectra of a specific form
4. Key tools: `CayleyGraph`, `Tropical`, `Matrix.eigenvalues`

**Domain Bridges**: Algebra <-> Tropical Geometry, Algebra <-> Graph Theory, Algebra <-> MachineLearning

**Lineage**: Bridges the Tropical geometry catalog (`top2_stable_of_test_family_margin`) with the group classification framework.

**Ambition**: extension
