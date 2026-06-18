# Future Directions: Phase Transition in Proof Compression

## Hypothesis 1: Normalizer-Invariance Conjecture

**Conjecture:** For any two complete deterministic normalizers N₁, N₂ on the same bounded-search proof calculus, the families exhibiting exponential normalized blowup are identical up to polynomial distortion. That is, if `shortestNorm P N₁ (φ n) ≥ 2^(n^α)` infinitely often, then `shortestNorm P N₂ (φ n) ≥ 2^(n^β)` infinitely often for some β > 0, and vice versa.

**Test:** Implement two distinct normalizers for a sequent calculus with bounded-arithmetic axioms:
1. Standard cut-elimination via the Gentzen reduction
2. Normalization-by-evaluation via a term model

Compare the asymptotic classes on pigeonhole and local-search families. If both normalizers produce the same exponential-vs-polynomial classification for all tested families, the conjecture is supported. A single family where one normalizer achieves polynomial normalized proofs and the other requires exponential would refute it.

**Impact:** If true, this would establish that the phase transition is a property of the *theory* and *statement family*, not the normalization algorithm. This would ground a universality law: proof compression obeys theory-intrinsic asymptotic laws independent of implementation details, analogous to universality classes in statistical physics.

---

## Hypothesis 2: Theory Exponent Hypothesis

**Conjecture:** There exists a theory-dependent constant α_T > 0 such that every complete family of total-search principles over theory T has normalized distortion either eventually polynomial or at least `exp(L^{α_T})` infinitely often, where L is the shortest raw proof length.

**Test:** Formalize three distinct bounded arithmetic theories (e.g., PV, S¹₂, T²₂) and estimate the lower exponent α for several families (pigeonhole, local search, Ramsey-type) over each theory. If the estimated exponents cluster around a theory-specific value (within statistical error), the hypothesis is supported. If different families over the same theory yield wildly different exponents, the hypothesis is weakened.

**Impact:** If confirmed, α_T becomes a new invariant of formal theories — a "proof compression exponent" that quantifies how much abstraction power a theory provides. This would create a new classification of arithmetic theories by their compression characteristics, complementing the traditional strength hierarchy.

---

## Hypothesis 3: Herbrand-Search Equivalence

**Conjecture:** For bounded Π₂ families in first-order arithmetic, the shortest normalized proof length is polynomially equivalent to the minimal Herbrand expansion size. Specifically, there exist polynomials p, q such that:
- `shortestNorm(φ_n) ≤ p(HerbrandSize(φ_n))`
- `HerbrandSize(φ_n) ≤ q(shortestNorm(φ_n))`

**Test:** Formalize both Herbrand expansion size and normalized proof length for the pigeonhole family and a bounded local-search family. Compute upper and lower bounds on both quantities and check whether the polynomial relationship holds. A counterexample would be a family where Herbrand expansion size is polynomial but normalized proof length is superpolynomial (or vice versa).

**Impact:** If true, this would unify two classical measures of proof complexity (Herbrand complexity and normalization blowup) into a single equivalence class. This would allow transferring decades of results from Herbrand complexity theory directly to normalization bounds, and vice versa. It would also provide a semantic characterization of normalization blowup: the blowup measures exactly how many explicit witness instances are needed.

---

## Hypothesis 4: Communication Barrier Hypothesis

**Conjecture:** Families of total-search statements with high deterministic communication complexity under witness partitioning necessarily incur superpolynomial normalization blowup. Precisely: if the communication complexity of the search problem encoded by φ_n (where Alice holds part of the input and Bob holds the rest, and they must jointly find a witness) is Ω(n), then `shortestNorm(φ_n) ≥ 2^(Ω(n))`.

**Test:** Encode partitioned witness-search principles (e.g., set disjointness reduced to collision finding) and formally compute or bound both the communication complexity and the normalized proof length. If the implication holds for all tested families, the conjecture is supported. A family with high communication complexity but polynomial normalized proofs would refute it.

**Impact:** This would establish a deep connection between proof compression and communication complexity, opening a new channel for proving proof-length lower bounds. Communication complexity has a mature toolkit (information-theoretic methods, partition arguments, lifting theorems) that could be imported wholesale into proof complexity, potentially resolving open problems about specific proof systems.

---

## Hypothesis 5: Intermediate-Regime Refutation Candidate

**Conjecture:** There exists a natural complete family whose normalized distortion is stably `exp(Θ(√(log L)))`, refuting the strict polynomial-vs-exponential dichotomy.

**Test:** Construct candidate families based on:
1. Layered local-search principles with geometrically decreasing layer sizes
2. Bounded switching principles with sublinear switching depth
3. Compositions of polynomial-distortion and exponential-distortion subfamilies

For each candidate, compute normalized proof lengths for n = 1 to 100 and fit the distortion function to models: polynomial, `exp(√(log L))`, `exp(log^{2/3} L)`, and exponential. If any candidate consistently fits an intermediate model better than the endpoints, the dichotomy is refuted.

**Impact:** If such a family exists, the phase transition picture becomes richer — instead of a simple binary classification, proof compression would exhibit a spectrum of distortion regimes, analogous to the KPZ universality class in surface growth or the variety of critical exponents in statistical mechanics. This would demand a fundamentally more nuanced theory. If no such family can be found despite extensive search, it would strongly support the gap theorem and suggest a deep structural reason for the dichotomy.

---

## Priority Ordering

1. **Hypothesis 3 (Herbrand-Search Equivalence)** — Most tractable, connects to established proof theory, and provides immediate new tools.
2. **Hypothesis 1 (Normalizer Invariance)** — Foundational for the entire theory; must be tested early.
3. **Hypothesis 2 (Theory Exponent)** — Computationally intensive but high impact.
4. **Hypothesis 4 (Communication Barrier)** — Requires bridging two technical communities.
5. **Hypothesis 5 (Intermediate Regime)** — Hardest to confirm or refute; best attacked last.
