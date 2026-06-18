# Future Directions: Automatic Sequences and the Decidability Boundary

## Synthesis

This research cycle established the formal foundations of automatic sequence theory in Lean 4, proving 14 theorems including the decidability of the value-in-sequence problem for DFAOs, the non-periodicity of the Thue-Morse sequence, kernel membership, and a cross-domain bridge between periodicity and linear recurrences. The most promising discovery is the precise location of the decidability boundary: automatic sequences have decidable zero-in-sequence problems, but the broader class of morphic sequences may not.

The cross-domain bridge theorem (eventually_periodic_implies_recurrence) reveals that the decidability boundary in automata theory corresponds to an algebraic boundary: eventually periodic sequences have rational generating functions, automatic sequences satisfy Mahler-type functional equations, and morphic sequences can have transcendental generating functions. This algebraic perspective opens connections to p-adic analysis and Christol's theorem, linking the Catalog's work on ultrametric structures (`MachineLearning/UltrametricKLDivergence.lean`) to the decidability theory developed here.

The highest breakthrough potential lies in Direction 1 (the morphic decidability conjecture), which could resolve a long-standing open problem in combinatorics on words. Direction 3 (Christol's theorem) offers the richest cross-domain connections, bridging automata theory, algebraic geometry over finite fields, and p-adic analysis.

---

### Direction 1: Morphic Zero-in-Sequence Decidability

**Conjecture**: For any prolongable morphism σ on a finite alphabet and any target letter b, it is decidable whether b appears in the fixed point σ^ω(a).

**Test**: Implement the decidability algorithm for all morphisms on alphabets of size ≤ 5 with image lengths ≤ 6. Run the algorithm and verify against brute-force iteration up to index 10^7. If the algorithm terminates correctly on all cases (including non-uniform morphisms like the Fibonacci morphism 0→01, 1→0), this provides strong evidence for the conjecture. A failure to terminate or incorrect result on any test case would refute the conjecture (or the algorithm).

**Impact**: If true, this extends the decidability frontier from automatic sequences to all morphic sequences—a dramatically larger class that includes Sturmian sequences, the Fibonacci word, and many sequences arising in symbolic dynamics. If false, the counterexample would pin down exactly where undecidability begins, with implications for word combinatorics and symbolic dynamics.

**Catalog References**: `Speculative/AutoResearch/AutomaticSequences.lean` (MorphicDecidabilityConjecture definition, AlphabetMorphism.IsProlongable)

**Proof Strategy**: For uniform morphisms, reduce to the DFAO decidability result (proven in this cycle). For non-uniform morphisms, attempt to show that the set of letters appearing in σ^ω(a) stabilizes after finitely many iterations—specifically, after at most |alphabet|² iterations, using a pigeonhole argument on the growth of the "seen letters" set. Key lemma needed: if σ^n(a) contains all letters that σ^(n+1)(a) contains, then σ^ω(a) contains no additional letters.

**Domain Bridges**: Automata Theory <-> Combinatorics on Words, Computation <-> Logic

**Lineage**: Builds directly on DFAO.sequence_range_finite and DFAO.reachable_step from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: First-Order Decidability for Automatic Sequences (Büchi-Bruyère)

**Conjecture**: The full first-order theory of any k-automatic sequence is decidable. That is, given a DFAO M generating sequence (aₙ) and a first-order sentence φ over (ℕ, +, aₙ), it is decidable whether φ is true.

**Test**: Formalize the Büchi automaton construction that converts first-order sentences about k-automatic sequences into finite automata, then verify on 50 test sentences (e.g., "∃n. a(n) = 0 ∧ a(n+1) = 0", "∀n. a(n) + a(n+1) ≤ 1"). Check that the constructed automaton accepts/rejects correctly by comparison with brute-force evaluation up to n = 10^4.

**Impact**: Would provide a decision procedure for ALL first-order properties of automatic sequences, not just "does value a appear?" This would subsume our value-in-sequence decidability result as a special case and connect to the theory of automatic structures in model theory.

**Catalog References**: `Speculative/AutoResearch/AutomaticSequences.lean` (DFAO definition, IsKAutomatic), `Logic/` (potential connections to decidability results in the Logic catalog)

**Proof Strategy**: 
1. Formalize Büchi automata (automata on infinite words).
2. Show that addition in base k is recognizable by a finite automaton (standard construction).
3. Show that the k-automatic sequence can be queried by an automaton.
4. Prove closure of recognizable relations under Boolean operations and projection (quantifier elimination).
5. Conclude decidability by checking emptiness of the resulting automaton.

Key lemma: Presburger arithmetic augmented with automatic predicates is decidable.

**Domain Bridges**: Logic <-> Automata Theory, Computation <-> Algebra

**Lineage**: Extends DFAO.sequence_range_finite and the reachability results from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Christol's Theorem — Algebraicity over Finite Fields

**Conjecture**: A formal power series Σ aₙ xⁿ over F_q (a finite field of order q = p^k) is algebraic over F_q(x) if and only if the sequence (aₙ) is p-automatic.

**Test**: Formalize the forward direction (p-automatic ⟹ algebraic) for p = 2, q = 2. Construct the minimal polynomial explicitly for the Thue-Morse generating function over F₂ and verify that it satisfies the polynomial equation. The Thue-Morse generating function over F₂ satisfies G(x)² + G(x) + x/(1+x)² = 0, which can be verified computationally for the first 1000 coefficients.

**Impact**: Christol's theorem is one of the deepest results connecting automata theory to algebraic geometry. Formalizing it would bridge the Catalog's automatic sequence work to algebraic structures, and would connect to the p-adic analysis in `MachineLearning/UltrametricKLDivergence.lean` (power series over p-adic fields).

**Catalog References**: `Speculative/AutoResearch/AutomaticSequences.lean` (DFAO, kKernel, IsKAutomatic), `MachineLearning/UltrametricKLDivergence.lean` (power_series_partial_sum_bound — p-adic power series)

**Proof Strategy**:
1. Define formal power series over F_q in Lean (Mathlib has `PowerSeries`).
2. Define algebraicity: ∃ P ∈ F_q(x)[y], P ≠ 0 ∧ P(G) = 0.
3. Forward: Given a DFAO, construct the algebraic equation by showing the kernel elements satisfy a system of algebraic equations (Cartier operators).
4. Backward: Given algebraicity, construct the DFAO via the kernel. Show algebraicity implies the kernel of Cartier operators is finite, which implies k-automaticity.

**Domain Bridges**: Automata Theory <-> Algebra, Number Theory <-> Computation

**Lineage**: Builds on kKernel, DFAO.kernel_finite, and the algebraic bridge theorem from this cycle.

**Ambition**: extension

---

### Direction 4: Kernel Finiteness via Digit Decomposition

**Conjecture**: For any DFAO M with n states and any k ≥ 2, the k-kernel of the generated sequence has exactly n' distinct elements, where n' is the number of states reachable from the initial state.

**Test**: Formalize the digit decomposition lemma: toBaseK(k, k^e · m + r) = pad(toBaseK(k, r), e) ++ toBaseK(k, m), where pad extends a digit list to length e with trailing zeros. Verify this lemma for k ∈ {2,3,5} and 1000 random (e, r, m) triples. Then use it to complete the sorry in DFAO.kernel_finite.

**Impact**: Completes the formal proof of the Eilenberg kernel characterization, which is the foundation of automatic sequence theory. The digit decomposition lemma is independently useful for formalizing any result about base-k representations.

**Catalog References**: `Speculative/AutoResearch/AutomaticSequences.lean` (DFAO.kernel_finite — the one remaining sorry, toBaseK, kKernel)

**Proof Strategy**:
1. Define `fromBaseK : List (Fin k) → ℕ` as the inverse of toBaseK.
2. Prove `fromBaseK (toBaseK k hk n) = n` by induction.
3. Prove the digit decomposition: if r < k^e, then toBaseK(k, k^e * m + r) consists of the digits of r (padded to e digits) followed by the digits of m. Key sublemma: `(k^e * m + r) % k = r % k` when r < k.
4. Use digit decomposition to show that running the DFAO on toBaseK(k^e * m + r) decomposes into running on digits of r (reaching state s_r) then running on digits of m from s_r.
5. Conclude: each kernel element is determined by s_r, and there are at most n such states.

**Domain Bridges**: Number Theory <-> Automata Theory

**Lineage**: Directly completes the sorry in DFAO.kernel_finite from this cycle.

**Ambition**: extension

---

### Direction 5: Automatic Sequences and Quasicrystal Spectra

**Conjecture**: The diffraction spectrum of a one-dimensional quasicrystal whose atomic positions are determined by a k-automatic sequence has purely singular continuous spectral measure if and only if the sequence is not eventually periodic.

**Test**: Compute the Fourier transform of the first N = 2^16 terms of the Thue-Morse sequence and verify that the spectrum is singular continuous (no discrete peaks, continuous support). Compare with the eventually periodic sequence 0,1,0,1,... (which should have discrete spectrum at frequency 1/2) and the Rudin-Shapiro sequence (known to have absolutely continuous spectrum).

**Impact**: Connects automatic sequence theory to condensed matter physics and materials science. Quasicrystals (discovered by Dan Shechtman, Nobel Prize 2011) have diffraction patterns that are neither periodic nor random—exactly the regime where automatic sequences live.

**Catalog References**: `Speculative/AutoResearch/AutomaticSequences.lean` (thueMorse_not_eventually_periodic, DFAO.sequence_range_finite), `Physics/` (potential connections to spectral theory)

**Proof Strategy**:
1. Define the autocorrelation function γ(h) = lim_{N→∞} (1/N) Σ_{n=0}^{N-1} a(n) a(n+h).
2. For the Thue-Morse sequence, compute γ using the self-similarity: γ(2h) relates to γ(h) via the doubling property.
3. Show that the Fourier transform of γ has no point masses (ruling out discrete spectrum) and no L¹ density (ruling out absolutely continuous spectrum).
4. Key lemma: thueMorse_double and thueMorse_double_succ_ne imply specific decay rates for γ.

**Domain Bridges**: Automata Theory <-> Physics, Algebra <-> Analysis

**Lineage**: Builds on thueMorse_not_eventually_periodic, thueMorse_double, and thueMorse_double_succ_ne from this cycle.

**Ambition**: extension
