# Future Directions: Asymmetric Computation Games

## Synthesis

This research cycle introduced the **Survival Profile** framework — a novel mathematical structure that cleanly captures the ordinal-valued survival capabilities of computationally bounded players in asymmetric games. The central discovery is the **Sharp Dichotomy Theorem**: a survival profile either has a finite bound or achieves survival ordinal ω, with nothing in between. This structural rigidity connects game theory to ordinal arithmetic in a way that mirrors the Infinite Time Turing Machine (ITTM) computation hierarchy.

The most promising cross-domain connection is between survival profiles and the existing **TransfiniteGameValues** catalog entry. That module defines `GameTree` with a rank function; our work shows that the family of all `GameTree.ofRank(n)` profiles constitutes a full survival profile with ordinal ω. The nested family construction extends this to arbitrary nesting depths, each corresponding to a level of the ITTM hierarchy. This bridge between concrete game trees and abstract ordinal survival opens a path toward computing exact transfinite game values for specific combinatorial games.

The highest breakthrough potential lies in **Direction 1** (Exact Ordinal Profiles), which would require extending survival profiles beyond downward-closed subsets of ℕ to encode ordinal arithmetic directly. Success here would establish a complete correspondence between levels of nondeterministic computation and ordinal exponentiation — a result connecting game theory, computability theory, and proof theory.

---

### Direction 1: Exact Ordinal Survival Profiles

**Conjecture**: There exists a natural extension of `SurvivalProfile` — call it `TransfiniteSurvivalProfile` — whose survival ordinal can take any value in the ordinal hierarchy below ε₀. Specifically, for each ordinal α < ε₀, there exists a profile P_α with survivalOrd(P_α) = α, and the map α ↦ P_α preserves ordinal addition and multiplication.

**Test**: Construct a concrete `TransfiniteSurvivalProfile` with survival ordinal exactly ω² = ω·ω. This requires the profile to encode ω-many "epochs" of ω-length survival. Verify that the profile cannot survive ω² + 1 rounds. A key sub-test: verify that the ascending family composed with itself (familyProfile(λk → familyProfile(λj → boundedProfile(k·j)))) has survival ordinal exactly ω².

**Impact**: If true, this would establish a complete isomorphism between ordinal arithmetic below ε₀ and the algebra of survival profiles. This would be a fundamental result connecting game theory to proof theory, since ε₀ is the proof-theoretic ordinal of Peano Arithmetic.

**Catalog References**: `Pythagorean/TransfiniteGameValues.lean` (GameTree, gameRank), `Pythagorean/MortalEternityGame.lean` (SurvivalProfile, omega_survival_exact, survival_omega_iff_full)

**Proof Strategy**: Define `TransfiniteSurvivalProfile` using a well-ordered index set instead of ℕ. The survival ordinal becomes the order type of the index set. Key lemma: show that ordinal addition of profiles corresponds to sequential composition, and ordinal multiplication corresponds to family composition. Use Mathlib's `Ordinal.add_le_add_right` and `Ordinal.mul_le_mul_left` for the arithmetic.

**Domain Bridges**: Game Theory ↔ Proof Theory (ordinal analysis), Computability ↔ Set Theory (ITTM levels ↔ ordinal hierarchy)

**Lineage**: Builds on `omega_survival_exact`, `survival_omega_iff_full`, and the nested family construction from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Survival Profiles and Wadge Degrees

**Conjecture**: The sharp dichotomy theorem (`survival_omega_iff_full`) is an instance of a more general phenomenon: for each Wadge degree d, there exists a "d-survival profile" whose survival ordinal is the ordinal rank of d in the Wadge hierarchy. Under the Axiom of Determinacy, the Wadge hierarchy is well-ordered, and every ordinal below Θ appears as a survival ordinal.

**Test**: Show that the game-theoretic definition of Wadge reducibility (Player II can copy Player I's strategy with a continuous transformation) corresponds to a morphism of survival profiles that preserves the survival ordinal. Verify for the first three levels of the Wadge hierarchy (open sets, Σ₁, Π₁).

**Impact**: If true, this would embed the entire Wadge hierarchy into the survival profile framework, providing a game-theoretic characterization of topological complexity classes. This would connect descriptive set theory to computational game theory.

**Catalog References**: `Pythagorean/TransfiniteGameTheory.lean` (Gale-Stewart games, Wadge hierarchy), `Pythagorean/MortalEternityGame.lean` (SurvivalProfile, survival_omega_iff_full)

**Proof Strategy**: Define a notion of "profile reduction" where P ≤_W Q if there is a continuous function mapping Q-strategies to P-strategies preserving survival length. Show this agrees with Wadge reducibility for the corresponding payoff sets. The key lemma is that Wadge determinacy gives exactly two cases: P ≤_W Q or Q ≤_W P^c (complement).

**Domain Bridges**: Descriptive Set Theory ↔ Game Theory, Topology ↔ Computability

**Lineage**: Extends the dichotomy theorem from a binary (full/bounded) classification to a full hierarchy.

**Ambition**: grand_challenge

---

### Direction 3: Computational Complexity of Profile Evaluation

**Conjecture**: Deciding whether a survival profile given by a Turing machine M (where M(n) = 1 iff canSurvive(n)) is full is Π₁⁰-complete — equivalent to the halting problem's complement. More precisely: {M : M computes a full profile} is Π₁⁰-complete.

**Test**: Reduce the complement of the halting problem to fullness testing: given a TM T, construct a profile P_T where P_T.canSurvive(n) iff T does not halt in n steps. Then P_T is full iff T does not halt. Conversely, reduce fullness testing to ∀n: M(n)=1, which is Π₁⁰.

**Impact**: This would show that the dichotomy theorem is computationally sharp — you cannot algorithmically decide which side of the dichotomy a given profile falls on. This connects the game-theoretic structure to computability theory.

**Catalog References**: `Pythagorean/MortalEternityGame.lean` (SurvivalProfile, isFull), `Computation/InfoEfficientAlgorithms.lean` (InfoEfficientAlgorithm)

**Proof Strategy**: The forward reduction is straightforward (given above). For completeness, show that any Π₁⁰ set can be encoded as {parameters where the corresponding profile is full}. Use the s-m-n theorem to make the reduction uniform.

**Domain Bridges**: Computability Theory ↔ Game Theory, Logic ↔ Computer Science

**Lineage**: Extends the structural results of this cycle to computational complexity.

**Ambition**: extension

---

### Direction 4: Profile Algebras and Tropical Semirings

**Conjecture**: The monoid of survival profiles under sequential composition, when extended with the family-profile operation as "multiplication," forms a tropical-semiring-like structure where addition is the family operation (sup/choice) and multiplication is sequential composition (sum). The survival ordinal is a homomorphism from this algebra to the ordinal tropical semiring (min-plus algebra on ordinals).

**Test**: Verify that familyProfile distributes over seq: familyProfile(λk → P_k.seq(Q)) = familyProfile(λk → P_k).seq(Q). Check for the first 5 levels of bounded profiles.

**Impact**: If the algebraic structure is clean, it would connect survival profiles to tropical geometry and provide optimization algorithms for strategy design. The existing `TropicalGameValue` in TransfiniteGameValues.lean would be a special case.

**Catalog References**: `Pythagorean/TransfiniteGameValues.lean` (TropicalGameValue, tropical_mul_comm), `Pythagorean/MortalEternityGame.lean` (SurvivalProfile.seq, familyProfile)

**Proof Strategy**: Define the two operations precisely. Show that seq is associative (already proved), family is associative and commutative, and seq distributes over family. The key difficulty is that family is defined over countable indices while seq is binary — need to show consistency.

**Domain Bridges**: Tropical Geometry ↔ Game Theory, Algebra ↔ Optimization

**Lineage**: Builds on seq_assoc and the tropical bridge from TransfiniteGameValues.

**Ambition**: extension

---

### Direction 5: Mortal Strategies in Specific Combinatorial Games

**Conjecture**: For the Pythagorean descent game (defined in TransfiniteGameValues.lean), the survival ordinal of Mortal playing from hypotenuse n equals the tree rank of the game tree rooted at n. More precisely: the survival profile induced by the Pythagorean descent game from n equals boundedProfile(treeRank(n)).

**Test**: Compute the tree ranks for small Pythagorean hypotenuses (5, 10, 13, 15, 17, 25) and verify that they match the survival lengths in the descent game. Use `#eval` to compute game trees for these values.

**Impact**: This would provide a concrete bridge between abstract survival profiles and number-theoretic game values, connecting the survival ordinal hierarchy to the distribution of Pythagorean triples.

**Catalog References**: `Pythagorean/TransfiniteGameValues.lean` (pythDescent, pythagorean_descent_wellfounded, GameTree.ofRank), `Pythagorean/MortalEternityGame.lean` (SurvivalProfile, boundedProfile)

**Proof Strategy**: Define the game tree of Pythagorean descent from n by recursion on n (well-founded by pythagorean_descent_wellfounded). Show that the tree rank equals the longest descent chain. Then show the induced survival profile is bounded by this rank.

**Domain Bridges**: Number Theory ↔ Game Theory, Combinatorics ↔ Ordinal Analysis

**Lineage**: Builds on both TransfiniteGameValues (Pythagorean descent) and MortalEternityGame (survival profiles).

**Ambition**: extension
