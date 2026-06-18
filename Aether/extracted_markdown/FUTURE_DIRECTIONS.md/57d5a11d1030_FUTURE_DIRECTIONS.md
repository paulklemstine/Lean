# Future Directions: Max-Envelope Arithmetic Persistence

## Synthesis

The max-envelope principle established in this work — that global torsion stability is bounded by the supremum of primewise stability channels — opens a broad research program connecting arithmetic persistence to tropical geometry, information theory, and robust optimization. The five directions below form a coherent arc: Direction 1 extends the decomposition to derived invariants, Direction 2 tropicalizes the algebraic framework, Direction 3 pushes to multiparameter settings, Direction 4 builds sheaf-theoretic foundations, and Direction 5 develops algorithmic applications. Together, they aim to establish *primewise completeness* as a general doctrine for arithmetic persistence theory.

---

## Direction 1: Primewise Completeness for Derived Persistence Invariants

**Conjecture:** The max-envelope inequality extends beyond torsion birth sets to derived invariants including persistence diagrams, Betti curves, and landscape functions, with the same L∞ aggregation structure.

**Test:** Formalize the persistence diagram for p-primary torsion modules over ℤ and prove that the bottleneck distance between global torsion diagrams is bounded by the maximum of p-primary bottleneck distances. Construct explicit counterexamples to equality in the derived setting.

**Impact:** Would unify the birth-set stability theory with the full algebraic stability theorem, providing a complete primewise decomposition of integer persistence.

**Catalog References:** `Pythagorean/PrimewiseTorsionStability.lean` (primewise stability), `Pythagorean/MaxEnvelopeStability.lean` (max-envelope framework, `IsMaxEnvelope`, `finite_prime_envelope_suffices'`)

**Proof Strategy:** Extend the min-max Lipschitz lemma (`natDist'_inf'_le_sup'_natDist'`) to bottleneck distances by proving that the matching between global diagrams decomposes into primewise matchings. Use the subsingleton property of birth sets as the base case.

**Domain Bridges:** Connects to algebraic K-theory (derived torsion invariants), homological algebra (spectral sequences for prime decomposition).

**Lineage:** Extends `finite_prime_envelope_suffices'` from birth sets to full diagram invariants.

**Ambition:** Grand challenge — would require building significant new infrastructure for integer persistence diagrams.

**The key insight is** that the algebraic stability theorem's proof structure already decomposes along prime channels; the challenge is formalizing the recombination step.

**Why now?** The max-envelope framework provides the right abstraction (`IsMaxEnvelope`, `IsBoundedByMaxEnvelope`) to state and attack this problem. The formalized birth decomposition theorem gives the base case.

---

## Direction 2: Tropicalization of Arithmetic Stability Functionals

**Conjecture:** The max-envelope operation defines a tropical semiring structure on stability functionals, where the "addition" is max and "multiplication" is ordinary addition, and the stability distance between filtration pairs is a point in a tropical variety.

**Test:** Define a tropical semiring of stability profiles (vectors of primewise distances indexed by primes), prove that the max-envelope is a tropical linear map, and show that the set of achievable stability profiles forms a tropical polyhedron.

**Impact:** Would connect arithmetic persistence to the rapidly developing theory of tropical geometry, enabling techniques from combinatorial optimization and polyhedral geometry.

**Catalog References:** `Pythagorean/MaxEnvelopeStability.lean` (`IsMaxEnvelope`, `IsBoundedByMaxEnvelope`, `isBoundedByMaxEnvelope_mono`)

**Proof Strategy:** Define `StabilityProfile := ℕ →₀ ℕ` (finitely supported functions from primes to distances). Show the set of profiles achievable by interleaving forms a tropical cone. Use `finite_prime_envelope_suffices'` to show the global shift is the tropical inner product of the profile with the all-ones vector.

**Domain Bridges:** Tropical geometry, max-plus algebra, combinatorial optimization, polyhedral computation.

**Lineage:** Natural successor to the max-envelope framework; replaces ad hoc max operations with systematic tropical algebra.

**Ambition:** Solid extension — the tropical framework should be within reach of current Lean/Mathlib infrastructure.

**The key insight is** that the max operation in the envelope theorem is not an accident — it is the addition in a tropical semiring that governs arithmetic stability.

**Why now?** Mathlib's increasing support for tropical semirings (via `Tropical` type) makes formalization feasible.

---

## Direction 3: Worst-Channel Theorems for Multiparameter Filtrations

**Conjecture:** For bifiltered abelian groups (filtered along two parameters), the torsion stability distance admits a max-envelope decomposition over primes in each parameter direction, yielding a 2D max-envelope controlled by the worst (prime, direction) pair.

**Test:** Define 2-parameter torsion birth sets, prove the 1D envelope theorem extends to each slice, and investigate whether the 2D envelope is tight or admits a gap.

**Impact:** Would extend the prime channel decomposition to the multiparameter persistence setting, which is the frontier of applied topology.

**Catalog References:** `Pythagorean/MaxEnvelopeStability.lean` (single-parameter max-envelope), `Pythagorean/PrimewiseTorsionStability.lean` (channel independence)

**Proof Strategy:** Iterate the single-parameter decomposition: first decompose along primes, then along the second filtration parameter. The min-max Lipschitz lemma generalizes to products of finite sets. Key difficulty: the birth decomposition may not factor cleanly in two parameters.

**Domain Bridges:** Multiparameter persistence, commutative algebra (bigraded modules), sheaf theory.

**Lineage:** Generalizes the entire framework from 1D to 2D filtrations.

**Ambition:** Grand challenge — multiparameter persistence is known to be significantly harder than the single-parameter case.

**The key insight is** that the worst-channel principle should apply independently in each filtration direction, giving a product max-envelope.

**Why now?** The formalized single-parameter theory provides the template; the key open question is whether the 2D case introduces genuinely new obstructions.

---

## Direction 4: Sheaf-Theoretic Local-to-Global Stability

**Conjecture:** The max-envelope principle is the global sections functor of a stability sheaf on the prime spectrum, where the stalk at each prime p records the p-primary stability distance.

**Test:** Define a presheaf on Spec(ℤ) whose sections over an open set U are the stability distances for primes in U. Prove the sheaf condition and show that global sections recover the max-envelope.

**Impact:** Would place the max-envelope principle in the context of algebraic geometry, opening connections to étale cohomology and motivic homotopy theory.

**Catalog References:** `Pythagorean/MaxEnvelopeStability.lean` (`IsMaxEnvelope`, `prime_in_S_of_birth_nonempty`)

**Proof Strategy:** Use the finite support property of active primes to show the presheaf satisfies descent. The max-envelope equals the global section because torsion decomposes into p-primary components with no cross-prime interaction.

**Domain Bridges:** Algebraic geometry (sheaves on Spec ℤ), number theory (local-global principles), derived algebraic geometry.

**Lineage:** Provides geometric foundations for the prime decomposition.

**Ambition:** Solid extension — the sheaf-theoretic viewpoint is mostly language, but formalizing it in Lean would be novel.

**The key insight is** that the max-envelope is a global sections computation, and the absence of cross-prime interference is the sheaf condition.

**Why now?** Mathlib's growing sheaf theory infrastructure makes this formalization path viable.

---

## Direction 5: Arithmetic Bottleneck Metrics and Algorithmic Applications

**Conjecture:** The max-envelope defines a metric on the space of filtrations that is computationally more tractable than the interleaving distance, with provable approximation guarantees.

**Test:** Implement the prime-decomposed stability computation, prove it runs in time O(|S| · L) where S is the active prime set and L is the filtration length, and show it provides a certified upper bound on interleaving distance.

**Impact:** Would yield practical algorithms for stability computation in integer persistence, with direct applications to computational topology and data analysis.

**Catalog References:** `Pythagorean/MaxEnvelopeStability.lean` (`finite_prime_envelope_suffices'`, `natDist'_le_of_between`), `Pythagorean/PrimewiseTorsionStability.lean` (`primeShiftBound`)

**Proof Strategy:** Formalize the parallel computation algorithm. Prove correctness using `finite_prime_envelope_suffices'`. Analyze complexity by bounding the number of active primes (at most log₂(max torsion order) many).

**Domain Bridges:** Algorithms, computational topology, parallel computing, approximation algorithms.

**Lineage:** Algorithmic realization of the theoretical framework.

**Ambition:** Solid extension — algorithms are directly implementable.

**The key insight is** that the prime decomposition converts a global optimization problem into embarrassingly parallel subproblems.

**Why now?** The formalized upper bound provides the correctness certificate; implementation is straightforward.
