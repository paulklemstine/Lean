# Future Directions: Curriculum Complexity Theory

## 1. Infinite Curricula via Ordinal-Valued Ranks

**Target Theorem:** For any countable well-founded dependency system `(T, dep)`, there exists an ordinal-valued rank function `rank : T → Ordinal` such that `dep a b → rank b < rank a`, and the rank of every element is a countable ordinal.

**Proof Strategy:** Use transfinite induction on the well-founded relation `flip dep`. Define `rank(t) = sup{rank(s) + 1 | dep t s}`. The well-foundedness of `flip dep` guarantees termination. For countable `T`, all ranks are countable ordinals (below ω₁).

**Cross-Domain Connection:** This generalizes the finite curriculum existence theorem to infinite mathematical theories — modeling, for example, the entirety of Mathlib as a single dependency system with a well-founded import/dependency graph.

**Concrete Next Step:** Formalize `OrdinalDepSystem` for well-founded relations on arbitrary types (not necessarily finite), define ordinal-valued `depLevel`, and prove the analogue of `depLevel_lt_of_dep` for ordinals.

---

## 2. Category of Theories and Functoriality of Frontier Depth

**Target Theorem:** Define a category `DepSysCat` whose objects are dependency systems and whose morphisms are dependency-preserving maps (i.e., functions `f : T → T'` such that `dep' (f a) (f b)` whenever `dep a b`). Prove that `depLevel` is functorial: `depLevel_{T'} (f t) ≤ depLevel_T t` for any morphism `f`.

**Proof Strategy:** A morphism maps dependency chains to dependency chains (possibly collapsing some), so chain lengths can only decrease. Formalize this as a functor from `DepSysCat` to `(ℕ, ≤)`.

**Cross-Domain Connection:** This captures the idea of **conservative theory extension**: embedding a smaller theory into a larger one preserves (or reduces) curriculum depth. This is the formal analogue of "prerequisites transfer across fields."

**Concrete Next Step:** Define `DepSystem.Morphism` as a structure with a map and proof of dependency preservation, prove `depLevel_morphism_le`, and show composition of morphisms preserves the inequality.

---

## 3. Parallel Research Complexity via Antichain Decompositions

**Target Theorem:** Define the **width** of a dependency system as the maximum size of an antichain (set of mutually independent theorems). Prove Dilworth's theorem in this context: the minimum number of chains needed to cover `T` equals the width, and the minimum number of antichains (= sequential depth) equals the longest chain length.

**Proof Strategy:** Use Mirsky's theorem (dual of Dilworth): the minimum number of antichains partitioning a finite poset equals the length of the longest chain. This directly gives: `maxLevel S + 1` equals the minimum number of parallel research rounds.

**Cross-Domain Connection:** This formalizes **parallel research planning**: if you have unlimited researchers who can work simultaneously on independent theorems, the minimum time to complete all theorems is the longest dependency chain. The ratio `maxLevel / width` measures the "parallelizability" of a mathematical theory.

**Concrete Next Step:** Define `antichain` and `chainDecomposition`, prove Mirsky's theorem for finite posets, and derive the parallel complexity characterization as a corollary.

---

## 4. Curriculum Entropy and Information-Theoretic Bounds

**Target Theorem:** Define the **curriculum entropy** of a dependency system as:

$$H(S) = \log_2 |\{f : T \to \mathbb{N} \mid f \text{ is a valid curriculum ranking}\}|$$

Prove that $H(S) \geq \sum_{k=0}^{L} \log_2(|A_k|!)$ where $A_k$ is the set of theorems at level $k$ and $L$ is the maximum level. Prove the upper bound $H(S) \leq \log_2(|T|!)$.

**Proof Strategy:** Any permutation of theorems within the same level preserves validity of the curriculum. This gives at least $\prod_k |A_k|!$ valid orderings. The upper bound is trivial (all permutations).

**Cross-Domain Connection:** Curriculum entropy measures the **degrees of freedom** in organizing a mathematical theory. Low entropy means the theory is essentially linearly ordered (few valid curricula); high entropy means many equivalent learning paths exist. This connects to information theory and coding: the entropy bounds the minimum description length of a curriculum.

**Concrete Next Step:** Define `validCurriculumCount : DepSystem T → ℕ` as the cardinality of valid rankings, prove the factorial lower bound using level-set decomposition, and relate to classical Shannon entropy.

---

## 5. Automated Curriculum Extraction from Formal Proof Libraries

**Target Deliverable:** Given a formal proof library (e.g., a collection of theorems with their dependency graphs extracted from import/usage analysis), automatically synthesize an admissible curriculum and certify its optimality bounds.

**Algorithm:**
1. Parse the dependency graph from `#check` / import analysis.
2. Compute `depLevel` for each theorem via topological sort (O(|V| + |E|) time).
3. Output the level decomposition as a certified curriculum.
4. Verify optimality: the computed `maxLevel` equals the longest path in the DAG.

**Proof Strategy:** Implement this as a verified algorithm in Lean 4 using `DecidableRel` and `Fintype` computation. The correctness proof reduces to our `mem_stageKnowledge_iff` and `frontier_all_known_iff` theorems.

**Cross-Domain Connection:** This directly enables **automated research planning**: given the current state of a proof library, the algorithm identifies the "next accessible theorems" (those at level `maxLevel + 1` in the extended system) and suggests optimal research priorities.

**Concrete Next Step:** Implement `computeDepLevel : (T : Type) → [Fintype T] → [DecidableEq T] → DepSystem T → T → ℕ` as a decidable computation, prove it equals `depLevel`, and test on extracted dependency graphs from Mathlib modules.
