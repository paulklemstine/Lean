
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Rigorous formal foundations for the Collatz conj
**Domain**: Applications
**Mathematical framing**: # Future Directions

## Synthesis

This research cycle established rigorous formal foundations for the Collatz conjecture's proof-theoretic analysis. The key results — parity exclusion, density contraction, odd density bounds, and orbit merge — form a coherent picture of why the conjecture is hard: local contraction is guaranteed by combinatorial constraints, but global contraction requires bounding growth phases that depend unpredictably on the input.

The most promising cross-domain connection is between the **Generalized Collatz System (GCS) framework** and the **computational universality** results in the Catalog's `Computation/` directory. Conway's theorem that GCS families are Turing-complete connects directly to the oracle and computability structures in `Computation/GravityOracle.lean` and `Computation/InfoEfficientAlgorithms.lean`. The GCS encoding notion defined in this cycle could bridge dynamical systems (Algebra) with computability theory (Computation), creating a formal pathway from specific Collatz dynamics to proof-theoretic independence.

The direction with highest breakthrough potential is Direction 1 (Sharp Contraction Threshold), because it would close the gap between our sufficient condition (odd density < 1/2) and the necessary condition (odd density < log₂3) using only real-number arithmetic already available in Mathlib. This would be the tightest known formal bound on Collatz contraction, directly useful for any future proof attempt.

---

### Direction 1: Sharp Contraction Threshold via Real Logarithms

**Conjecture**: For any Collatz orbit of length k with j odd steps, if j/k < log(2)/log(3), then the orbit segment contracts (the end value is less than the start value for sufficiently large starting values). Specifically: for all ε > 0, there exists N₀ such that if n ≥ N₀ and j/k < log(2)/log(3) - ε, then T^k(n) < n.

**Test**: Formalize the real-valued inequality log(3)/log(2) · j < k - j in Lean 4 using Mathlib's `Real.log`. Prove that this implies 3^j < 2^(k-j) using `Real.rpow_lt_rpow` and related lemmas. Verify computationally for k = 100, j = 62 (which is below the threshold) vs j = 64 (above).

**Impact**: This would give the sharpest possible formal contraction criterion, replacing our current sufficient condition (2j < k, i.e., density < 1/2) with the optimal threshold (density < log₂(2)/log₂(3) ≈ 0.6309). Any future proof of Collatz via density arguments would need this bound.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (pow3_lt_pow2_double, density_contraction), `Catalog/Algebra/ParityCylinders.lean` (isDescentWord)

**Proof Strategy**: 
1. Define the real-valued contraction condition: `j * Real.log 3 < (k - j) * Real.log 2`.
2. Show equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` using `Real.exp_log` and monotonicity.
3. Transfer to natural numbers: `(3 : ℝ)^j < (2 : ℝ)^(k-j)` implies `3^j < 2^(k-j)` in ℕ using `Nat.cast_lt`.
4. Apply to the orbit affine bound to get the contraction result.

**Domain Bridges**: Algebra (parity word theory) <-> Analysis (real logarithms) <-> Computation (contraction verification)

**Lineage**: Builds on `pow3_lt_pow2_double` and `density_contraction` from this cycle.

**Ambition**: extension

---

### Direction 2: Collatz Orbit Encoding of Finite Automata

**Conjecture**: For every deterministic finite automaton (DFA) with n states, there exists a Generalized Collatz System with modulus m = O(n!) that simulates the DFA's computation. Specifically, the GCS can be constructed so that its residue-class dynamics on a set of n distinguished values exactly mirrors the DFA's state transitions.

**Test**: Construct explicit GCS encodings for small DFAs (2-state, 3-state) and verify in Lean that the GCS dynamics on the embedded states matches the DFA transitions. Then prove the general construction for arbitrary n-state DFAs.

**Impact**: This would be a concrete, constructive version of Conway's universality theorem, restricted to finite automata. It would establish the precise modulus needed for encoding, which is relevant to understanding whether the standard Collatz modulus (m = 2) has any encoding power.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (GCS, GCS.Encodes, FiniteTransition), `Catalog/Computation/InfoEfficientAlgorithms.lean` (BSState)

**Proof Strategy**:
1. Define DFA as a `FiniteTransition` with input alphabet.
2. Use Chinese Remainder Theorem to construct residue classes that separate states.
3. Define affine rules that map each state's residue class to the successor state's class.
4. Prove the divisibility condition using CRT.
5. Verify the encoding property.

**Domain Bridges**: Algebra (GCS framework) <-> Computation (finite automata, Turing completeness) <-> Cryptography (CRT constructions)

**Lineage**: Builds on GCS and FiniteTransition definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Transfinite Orbit Measures and Goodstein Analogy

**Conjecture**: There exists an ordinal-valued measure μ : ℕ → Ordinal (below ε₀) such that for all n ≥ 2, μ(T(n)) < μ(n) in the standard Collatz map. If such a measure exists, the Collatz conjecture follows by transfinite induction, but the measure itself may require principles beyond PA (analogous to Goodstein's theorem).

**Test**: Define candidate measures combining stopping time, peak value, and bit-length. Test whether μ(T(n)) < μ(n) for n ≤ 10^6. The measure μ(n) = ω^(bit-length(n)) · (n mod 2^k) + lower-order terms is a natural starting point.

**Impact**: If a sub-ε₀ measure works, it would prove the Collatz conjecture using transfinite induction up to ε₀ (which is the proof-theoretic ordinal of PA). This would simultaneously prove Collatz and show it's provable in PA + transfinite induction, placing it at the same logical level as Goodstein's theorem. If no sub-ε₀ measure works, it would be strong evidence for independence from PA.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, peakValue, ComplexityClass), `Catalog/Logic/` (ordinal theory if available)

**Proof Strategy**:
1. Define ordinal-valued measures on ℕ using Cantor Normal Form.
2. Show that even steps decrease the measure (easy: bit-length decreases).
3. Show that odd steps increase bit-length by at most 1 but decrease a secondary component.
4. The challenge is finding a measure where the odd-step increase is compensated by subsequent even steps — this is where the parity exclusion theorem is crucial.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Logic (ordinal arithmetic, proof theory) <-> Computation (well-founded recursion)

**Lineage**: Builds on ComplexityClass and stoppingTime from this cycle, and the parity exclusion theorem.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Analysis of Parity Words

**Conjecture**: The discrete Fourier transform of the parity word of a Collatz orbit of length k has spectral energy concentrated at frequency 1/2 (reflecting the parity exclusion alternation). Specifically, the spectral coefficient at frequency 1/2 satisfies |ĉ(1/2)| ≥ c·√k for some universal constant c > 0, and this spectral concentration is equivalent to the contraction property.

**Test**: Compute the DFT of parity words for orbits starting at n = 27 (a famously long orbit with 111 steps). Check whether the spectral peak at frequency 1/2 dominates. Compare with random binary words satisfying the no-consecutive-ones constraint.

**Impact**: A spectral characterization of contraction would connect Collatz dynamics to harmonic analysis, potentially enabling tools from analytic number theory (e.g., exponential sum estimates) to attack the conjecture. This bridges the combinatorial parity-word approach with the Fourier-analytic approach of Tao (2019).

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (orbitParity, oddSteps_le_half), `Catalog/MachineLearning/CollatzSpectral/` (existing spectral framework), `Catalog/Algebra/ParityCylinders.lean` (parityWord)

**Proof Strategy**:
1. Define the DFT on ParityWord: ĉ(f) = Σ w(i) · exp(2πi·f·i/k).
2. Use parity exclusion to show the alternating component is large.
3. Connect spectral energy to oddSteps/evenSteps ratio.
4. Prove that spectral concentration at f=1/2 implies the contraction bound.

**Domain Bridges**: Algebra (parity words) <-> Analysis (Fourier transform) <-> MachineLearning (spectral Collatz framework)

**Lineage**: Builds on orbitParity and oddSteps_le_half from this cycle; connects to `CollatzSpectral/` in the Catalog.

**Ambition**: extension

---

### Direction 5: Computational Lower Bounds on Collatz Independence

**Conjecture**: If the Collatz conjecture is independent of PA, then for infinitely many n, the stopping time of n exceeds any primitive recursive function of n. Conversely, if all stopping times are bounded by a fixed primitive recursive function, then the conjecture is provable in PA.

**Test**: Formalize the equivalence between "Collatz stopping times are primitive-recursively bounded" and "Collatz is provable in PA" using the connection between provably total functions and proof-theoretic ordinals. Test computationally: check whether stopping times for n ≤ 10^8 exceed n^(log log n), which is a candidate super-polynomial but sub-primitive-recursive bound.

**Impact**: This would give a precise computational criterion for independence: either stopping times are "tame" (primitive-recursively bounded) and the conjecture is provable, or they are "wild" (eventually exceeding any primitive recursive function) and the conjecture is independent. This transforms a metamathematical question into a concrete computational one.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, ComplexityClass, CollatzIndependenceConjecture), `Catalog/Computation/PadicValuationDepth.lean` (depth measures)

**Proof Strategy**:
1. Formalize the concept of a "provably total function" in a proof system.
2. Show that if Collatz is provable in PA, then its stopping-time function is provably total in PA.
3. By the characterization of provably total functions of PA (those bounded by functions in the fast-growing hierarchy below ε₀), this gives a concrete bound.
4. Conversely, show that a primitive recursive bound on stopping times yields a PA proof.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Computation (primitive recursion, fast-growing hierarchy) <-> Logic (proof-theoretic ordinals)

**Lineage**: Builds on stoppingTime and CollatzIndependenceConjecture from this cycle.

**Ambition**: grand_challenge

**Concept description**: # Future Directions

## Synthesis

This research cycle established rigorous formal foundations for the Collatz conjecture's proof-theoretic analysis. The key results — parity exclusion, density contraction, odd density bounds, and orbit merge — form a coherent picture of why the conjecture is hard: local contraction is guaranteed by combinatorial constraints, but global contraction requires bounding growth phases that depend unpredictably on the input.

The most promising cross-domain connection is between the **Generalized Collatz System (GCS) framework** and the **computational universality** results in the Catalog's `Computation/` directory. Conway's theorem that GCS families are Turing-complete connects directly to the oracle and computability structures in `Computation/GravityOracle.lean` and `Computation/InfoEfficientAlgorithms.lean`. The GCS encoding notion defined in this cycle could bridge dynamical systems (Algebra) with computability theory (Computation), creating a formal pathway from specific Collatz dynamics to proof-theoretic independence.

The direction with highest breakthrough potential is Direction 1 (Sharp Contraction Threshold), because it would close the gap between our sufficient condition (odd density < 1/2) and the necessary condition (odd density < log₂3) using only real-number arithmetic already available in Mathlib. This would be the tightest known formal bound on Collatz contraction, directly useful for any future proof attempt.

---

### Direction 1: Sharp Contraction Threshold via Real Logarithms

**Conjecture**: For any Collatz orbit of length k with j odd steps, if j/k < log(2)/log(3), then the orbit segment contracts (the end value is less than the start value for sufficiently large starting values). Specifically: for all ε > 0, there exists N₀ such that if n ≥ N₀ and j/k < log(2)/log(3) - ε, then T^k(n) < n.

**Test**: Formalize the real-valued inequality log(3)/log(2) · j < k - j in Lean 4 using Mathlib's `Real.log`. Prove that this implies 3^j < 2^(k-j) using `Real.rpow_lt_rpow` and related lemmas. Verify computationally for k = 100, j = 62 (which is below the threshold) vs j = 64 (above).

**Impact**: This would give the sharpest possible formal contraction criterion, replacing our current sufficient condition (2j < k, i.e., density < 1/2) with the optimal threshold (density < log₂(2)/log₂(3) ≈ 0.6309). Any future proof of Collatz via density arguments would need this bound.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (pow3_lt_pow2_double, density_contraction), `Catalog/Algebra/ParityCylinders.lean` (isDescentWord)

**Proof Strategy**: 
1. Define the real-valued contraction condition: `j * Real.log 3 < (k - j) * Real.log 2`.
2. Show equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` using `Real.exp_log` and monotonicity.
3. Transfer to natural numbers: `(3 : ℝ)^j < (2 : ℝ)^(k-j)` implies `3^j < 2^(k-j)` in ℕ using `Nat.cast_lt`.
4. Apply to the orbit affine bound to get the contraction result.

**Domain Bridges**: Algebra (parity word theory) <-> Analysis (real logarithms) <-> Computation (contraction verification)

**Lineage**: Builds on `pow3_lt_pow2_double` and `density_contraction` from this cycle.

**Ambition**: extension

---

### Direction 2: Collatz Orbit Encoding of Finite Automata

**Conjecture**: For every deterministic finite automaton (DFA) with n states, there exists a Generalized Collatz System with modulus m = O(n!) that simulates the DFA's computation. Specifically, the GCS can be constructed so that its residue-class dynamics on a set of n distinguished values exactly mirrors the DFA's state transitions.

**Test**: Construct explicit GCS encodings for small DFAs (2-state, 3-state) and verify in Lean that the GCS dynamics on the embedded states matches the DFA transitions. Then prove the general construction for arbitrary n-state DFAs.

**Impact**: This would be a concrete, constructive version of Conway's universality theorem, restricted to finite automata. It would establish the precise modulus needed for encoding, which is relevant to understanding whether the standard Collatz modulus (m = 2) has any encoding power.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (GCS, GCS.Encodes, FiniteTransition), `Catalog/Computation/InfoEfficientAlgorithms.lean` (BSState)

**Proof Strategy**:
1. Define DFA as a `FiniteTransition` with input alphabet.
2. Use Chinese Remainder Theorem to construct residue classes that separate states.
3. Define affine rules that map each state's residue class to the successor state's class.
4. Prove the divisibility condition using CRT.
5. Verify the encoding property.

**Domain Bridges**: Algebra (GCS framework) <-> Computation (finite automata, Turing completeness) <-> Cryptography (CRT constructions)

**Lineage**: Builds on GCS and FiniteTransition definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Transfinite Orbit Measures and Goodstein Analogy

**Conjecture**: There exists an ordinal-valued measure μ : ℕ → Ordinal (below ε₀) such that for all n ≥ 2, μ(T(n)) < μ(n) in the standard Collatz map. If such a measure exists, the Collatz conjecture follows by transfinite induction, but the measure itself may require principles beyond PA (analogous to Goodstein's theorem).

**Test**: Define candidate measures combining stopping time, peak value, and bit-length. Test whether μ(T(n)) < μ(n) for n ≤ 10^6. The measure μ(n) = ω^(bit-length(n)) · (n mod 2^k) + lower-order terms is a natural starting point.

**Impact**: If a sub-ε₀ measure works, it would prove the Collatz conjecture using transfinite induction up to ε₀ (which is the proof-theoretic ordinal of PA). This would simultaneously prove Collatz and show it's provable in PA + transfinite induction, placing it at the same logical level as Goodstein's theorem. If no sub-ε₀ measure works, it would be strong evidence for independence from PA.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, peakValue, ComplexityClass), `Catalog/Logic/` (ordinal theory if available)

**Proof Strategy**:
1. Define ordinal-valued measures on ℕ using Cantor Normal Form.
2. Show that even steps decrease the measure (easy: bit-length decreases).
3. Show that odd steps increase bit-length by at most 1 but decrease a secondary component.
4. The challenge is finding a measure where the odd-step increase is compensated by subsequent even steps — this is where the parity exclusion theorem is crucial.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Logic (ordinal arithmetic, proof theory) <-> Computation (well-founded recursion)

**Lineage**: Builds on ComplexityClass and stoppingTime from this cycle, and the parity exclusion theorem.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Analysis of Parity Words

**Conjecture**: The discrete Fourier transform of the parity word of a Collatz orbit of length k has spectral energy concentrated at frequency 1/2 (reflecting the parity exclusion alternation). Specifically, the spectral coefficient at frequency 1/2 satisfies |ĉ(1/2)| ≥ c·√k for some universal constant c > 0, and this spectral concentration is equivalent to the contraction property.

**Test**: Compute the DFT of parity words for orbits starting at n = 27 (a famously long orbit with 111 steps). Check whether the spectral peak at frequency 1/2 dominates. Compare with random binary words satisfying the no-consecutive-ones constraint.

**Impact**: A spectral characterization of contraction would connect Collatz dynamics to harmonic analysis, potentially enabling tools from analytic number theory (e.g., exponential sum estimates) to attack the conjecture. This bridges the combinatorial parity-word approach with the Fourier-analytic approach of Tao (2019).

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (orbitParity, oddSteps_le_half), `Catalog/MachineLearning/CollatzSpectral/` (existing spectral framework), `Catalog/Algebra/ParityCylinders.lean` (parityWord)

**Proof Strategy**:
1. Define the DFT on ParityWord: ĉ(f) = Σ w(i) · exp(2πi·f·i/k).
2. Use parity exclusion to show the alternating component is large.
3. Connect spectral energy to oddSteps/evenSteps ratio.
4. Prove that spectral concentration at f=1/2 implies the contraction bound.

**Domain Bridges**: Algebra (parity words) <-> Analysis (Fourier transform) <-> MachineLearning (spectral Collatz framework)

**Lineage**: Builds on orbitParity and oddSteps_le_half from this cycle; connects to `CollatzSpectral/` in the Catalog.

**Ambition**: extension

---

### Direction 5: Computational Lower Bounds on Collatz Independence

**Conjecture**: If the Collatz conjecture is independent of PA, then for infinitely many n, the stopping time of n exceeds any primitive recursive function of n. Conversely, if all stopping times are bounded by a fixed primitive recursive function, then the conjecture is provable in PA.

**Test**: Formalize the equivalence between "Collatz stopping times are primitive-recursively bounded" and "Collatz is provable in PA" using the connection between provably total functions and proof-theoretic ordinals. Test computationally: check whether stopping times for n ≤ 10^8 exceed n^(log log n), which is a candidate super-polynomial but sub-primitive-recursive bound.

**Impact**: This would give a precise computational criterion for independence: either stopping times are "tame" (primitive-recursively bounded) and the conjecture is provable, or they are "wild" (eventually exceeding any primitive recursive function) and the conjecture is independent. This transforms a metamathematical question into a concrete computational one.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, ComplexityClass, CollatzIndependenceConjecture), `Catalog/Computation/PadicValuationDepth.lean` (depth measures)

**Proof Strategy**:
1. Formalize the concept of a "provably total function" in a proof system.
2. Show that if Collatz is provable in PA, then its stopping-time function is provably total in PA.
3. By the characterization of provably total functions of PA (those bounded by functions in the fast-growing hierarchy below ε₀), this gives a concrete bound.
4. Conversely, show that a primitive recursive bound on stopping times yields a PA proof.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Computation (primitive recursion, fast-growing hierarchy) <-> Logic (proof-theoretic ordinals)

**Lineage**: Builds on stoppingTime and CollatzIndependenceConjecture from this cycle.

**Ambition**: grand_challenge

**Novelty estimate**: 0.5
**Breakthrough potential**: 0.5
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
