# Future Directions

## Synthesis

This research cycle established a formal foundation for k-automatic sequences and their decidability properties, centering on the DFAO (Deterministic Finite Automaton with Output) framework. The key discovery is that the interplay between three structural properties — self-similarity, complementation, and finite kernel — determines the decidability landscape for sequence-theoretic questions. The closure theorem (k-automatic sequences are closed under arbitrary pointwise operations) connects to the Catalog's algebraic machinery, while the aperiodicity proof for Thue-Morse demonstrates how structural arguments about finite-state systems can resolve infinite combinatorial questions.

The most promising cross-domain connection from this cycle is the link between **kernel finiteness** and **decidability**. The k-kernel provides a bridge between automata theory (DFAOs), algebra (formal power series and Christol's theorem), and computability (the decidability frontier). This connection suggests that formalizing Eilenberg's theorem completely — both directions of the equivalence between k-automatic sequences and finite k-kernels — would unlock a powerful toolkit applicable to problems in number theory (automatic properties of arithmetic functions), formal language theory (regular languages as level sets), and algebraic geometry (algebraic power series over finite fields).

The Thue-Morse aperiodicity proof via period halving is a template for a broader class of arguments: any self-similar sequence with a complementation-type property will resist periodicity. This pattern should extend to other automatic sequences (Rudin-Shapiro, paperfolding) and potentially to morphic sequences, where the open decidability conjecture remains the most important unsolved problem in the field.

---

### Direction 1: Cobham's Theorem and Multiplicative Independence

**Conjecture**: If a sequence (a_n) over a finite alphabet is both j-automatic and k-automatic, where j and k are multiplicatively independent (i.e., log j / log k is irrational), then (a_n) is eventually periodic.

**Test**: Formalize the statement in Lean 4. Attempt to prove the result for the special case j = 2, k = 3. Construct explicit counterexamples showing the hypothesis of multiplicative independence is necessary (e.g., a sequence that is both 2-automatic and 4-automatic but not eventually periodic — this is possible since 4 = 2²).

**Impact**: Cobham's theorem is one of the deepest results in automatic sequence theory. A formalization would be a landmark in formalized combinatorics on words. It would also provide a tool for proving that specific sequences (like the Fibonacci word) are NOT k-automatic for any k.

**Catalog References**: `Computation/AutomaticDecidability.lean` (DFAO framework, IsKAutomatic definition), `Algebra/AutomaticSequences.lean` (existing k-kernel theory)

**Proof Strategy**: The proof of Cobham's theorem (due to Cobham 1972, with simplified proofs by Durand 1998 and Adamczewski-Bell 2010) proceeds by: (1) showing that a j-automatic and k-automatic sequence has bounded j-kernel and k-kernel; (2) using multiplicative independence to show that the "mixed kernel" (extracting along j^a · k^b · n + r) grows without bound unless the sequence is eventually periodic; (3) formalizing the Skolem-Mahler-Lech theorem or a combinatorial alternative for the base case.

**Domain Bridges**: Automata theory ↔ Number theory (multiplicative independence, p-adic valuations)

**Lineage**: Builds on DFAO framework and IsKAutomatic from this cycle's Computation/AutomaticDecidability.lean.

**Ambition**: grand_challenge

---

### Direction 2: Morphic Decidability for Uniform Morphisms

**Conjecture**: For any k-uniform morphism σ prolongable on letter a, the set of letters appearing in the fixed point σ^ω(a) equals the set of letters reachable from a in the letter dependency graph G_σ, where G_σ has edge b → c iff c appears in σ(b).

**Test**: Prove this equivalence formally in Lean 4 for the uniform case. Verify computationally for all k-uniform morphisms with k ≤ 5 over alphabets of size ≤ 4.

**Impact**: This would formalize one half of the morphic decidability picture, resolving the conjecture for the uniform case. The key insight is that uniformity guarantees that every letter reachable in the dependency graph appears in bounded-length prefixes of the fixed point, which can be computed.

**Catalog References**: `Computation/AutomaticDecidability.lean` (AlphabetMorphism, IsProlongable, MorphicDecidabilityConjecture)

**Proof Strategy**: (1) Define the letter dependency graph G_σ. (2) Show that if b is reachable from a in G_σ via path of length ℓ, then b appears in σ^ℓ(a) (induction on path length). (3) Show that σ^ℓ(a) has length k^ℓ and is a prefix of σ^ω(a) for prolongable morphisms. (4) Conclude: b appears in σ^ω(a) iff b is reachable from a in G_σ, and the latter is decidable by BFS in |Σ| steps.

**Domain Bridges**: Formal language theory ↔ Graph theory (reachability in finite digraphs)

**Lineage**: Extends MorphicDecidabilityConjecture and AlphabetMorphism from this cycle.

**Ambition**: extension

---

### Direction 3: Subword Complexity of Automatic Sequences

**Conjecture**: Every k-automatic sequence over a finite alphabet has subword complexity p(n) = O(n), where p(n) counts the number of distinct length-n subwords. Moreover, the constant in the O(n) bound depends only on the number of states of the generating DFAO.

**Test**: Prove p(n) ≤ C · n for some explicit constant C depending on |σ| and k. Compute p(n) for the Thue-Morse, Rudin-Shapiro, and paperfolding sequences for n ≤ 100 and verify the linear bound.

**Impact**: Subword complexity is a fundamental measure of sequence complexity. Linear complexity characterizes sequences "just above" eventually periodic (which have bounded complexity). Proving this for automatic sequences would provide a clean characterization of their position in the complexity hierarchy.

**Catalog References**: `Computation/AutomaticDecidability.lean` (DFAO.sequence), `Algebra/AutomaticSequences.lean` (kKernel)

**Proof Strategy**: (1) Define subword complexity p(n) = |{(a_i, a_{i+1}, ..., a_{i+n-1}) | i ∈ ℕ}|. (2) Show that each length-n subword is determined by the state of the DFAO after processing the first i digits plus the next n digits. (3) Since there are at most |σ| states and k^n possible n-digit words, bound p(n) by min(|σ| · something linear, k^n). (4) Use the kernel structure to get a tighter O(n) bound.

**Domain Bridges**: Combinatorics on words ↔ Automata theory ↔ Ergodic theory (Morse-Hedlund theorem)

**Lineage**: Extends DFAO.sequence and k-kernel theory from this cycle.

**Ambition**: extension

---

### Direction 4: Christol's Theorem Formalization

**Conjecture**: A formal power series f(x) = Σ a_n x^n ∈ 𝔽_p[[x]] is algebraic over 𝔽_p(x) (i.e., satisfies P(x, f(x)) = 0 for some nonzero polynomial P ∈ 𝔽_p[x, y]) if and only if the coefficient sequence (a_n) is p-automatic.

**Test**: Formalize the "automatic → algebraic" direction: given a DFAO over 𝔽_p, construct the polynomial P explicitly from the DFAO structure. Verify for the Thue-Morse generating function over 𝔽_2.

**Impact**: Christol's theorem is the deepest bridge between automata theory and algebra. A formalization would be one of the most significant results in formalized number theory, connecting the combinatorial DFAO framework to algebraic geometry over finite fields.

**Catalog References**: `Computation/AutomaticDecidability.lean` (DFAO, IsKAutomatic), Mathlib's `MvPolynomial` and `FormalPowerSeries` modules

**Proof Strategy**: For the "automatic → algebraic" direction: (1) Given a DFAO M with states σ, define power series f_s(x) = Σ_n λ(runFrom(s, toBaseK(n))) x^n for each state s. (2) Show that the f_s satisfy a system of p functional equations: f_s(x) = Σ_{d ∈ Fin p} x^d · f_{δ(s,d)}(x^p). (3) Eliminate to get a single polynomial equation for f = f_{q₀}. This requires Mathlib's polynomial and power series libraries, which are well-developed.

**Domain Bridges**: Automata theory ↔ Algebraic geometry (algebraic curves over finite fields) ↔ Number theory (p-adic analysis)

**Lineage**: Extends the full DFAO framework and IsKAutomatic definition from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Tropical Automatic Sequences

**Conjecture**: Define a "tropical DFAO" where the output function maps to the tropical semiring (ℝ ∪ {∞}, min, +) instead of a finite alphabet. The sequence generated by a tropical DFAO has a tropically algebraic generating function (satisfies a polynomial equation in the tropical semiring). Moreover, the zero-in-sequence problem for tropical DFAOs (does the sequence ever achieve its minimum value?) is decidable.

**Test**: Formalize tropical DFAOs as a special case of the DFAO framework with output in the tropical semiring. Construct examples: the "tropical Thue-Morse" sequence where the output is the hamming weight (not reduced mod 2). Show that its tropical generating function is algebraic.

**Impact**: This would bridge automatic sequence theory with tropical geometry, connecting to the Catalog's extensive tropical mathematics infrastructure. The decidability of tropical optimization problems is of independent interest in operations research and algebraic geometry.

**Catalog References**: `Tropical/` directory (tropical semiring infrastructure), `Computation/AutomaticDecidability.lean` (DFAO framework), `Computation/ReversibleTropicalMachine.lean` (tropical computation)

**Proof Strategy**: (1) Define TropicalDFAO as DFAO σ k (Tropical ℝ). (2) Show that the tropical generating function Σ⊕ a_n ⊗ x^n (where ⊕ = min and ⊗ = +) of a tropical DFAO sequence satisfies a system of tropical polynomial equations derived from the DFAO structure. (3) Use the finite state space to show decidability of the minimum-value problem: the minimum output value is min{λ(s) | s reachable}, which is a finite computation.

**Domain Bridges**: Automatic sequences ↔ Tropical geometry ↔ Optimization (shortest path problems as tropical linear algebra)

**Lineage**: Extends DFAO framework from this cycle; connects to Catalog's tropical mathematics infrastructure in `Tropical/` and `Computation/ReversibleTropicalMachine.lean`.

**Ambition**: extension
