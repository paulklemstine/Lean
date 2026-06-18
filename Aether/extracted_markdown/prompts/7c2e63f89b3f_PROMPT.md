## Assignment: Formal Verification of Algorithms — from Correctness to Information-Theoretic Optimality

You are not being asked to merely verify textbook programs. You are being asked to turn three canonical algorithms into a **formal theory of algorithmic information flow**: binary search as optimal interrogation of ordered information, Dijkstra as monotone energy dissipation on weighted state spaces, and FFT/NTT as symmetry-exploiting compression of convolution. The breakthrough is to unify **program verification, asymptotic complexity, entropy/information bounds, and algebraic transform theory** in one Lean 4 development.

Your target is a new formal synthesis: **correctness + complexity + optimality certificates** for algorithms that are usually treated separately. Build on the catalog’s computation/information bridge theorems to show that these algorithms are not just correct—they are canonical realizations of information constraints.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`,
   or multi-step `calc` reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain (e.g., number theory + tropical
   geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

---

## Research Direction

Formalize classic algorithms with full correctness proofs in Lean 4, but elevate them into a **unified mathematical framework of optimal information extraction**:

- **Binary search** with loop invariants, correctness, logarithmic comparison bound, and an information-theoretic lower-bound comparison.
- **Dijkstra’s shortest path algorithm** on a formal weighted graph structure, with correctness from monotone frontier invariants, and complexity/entropy interpretation of frontier refinement.
- **FFT via number-theoretic transform (NTT)** over a finite commutative ring/field admitting principal roots of unity, with correctness of convolution acceleration and divide-and-conquer complexity recurrence.

The conceptual ambition is this:

> Prove that these algorithms instantiate three archetypes of efficient computation:
> ordered elimination, monotone relaxation, and symmetry factorization.

---

## Mathematical Framing

The decisive step is to define a new formal object expressing when an algorithm is **information-efficient** relative to the structure of its input space.

### Proposed new definition (novel structure)

Define a structure expressing a certified algorithm together with a quantitative information budget.

```lean
structure InfoEfficientAlgorithm (Input State Output : Type _) where
  step        : State → State
  init        : Input → State
  terminate   : State → Prop
  extract     : State → Output
  invariant   : Input → State → Prop
  potential   : State → ℕ
  sound       : ∀ x, invariant x (init x)
  preserve    : ∀ x s, invariant x s → ¬ terminate s → invariant x (step s)
  descent     : ∀ x s, invariant x s → ¬ terminate s → potential (step s) < potential s
  correct     : ∀ x s, invariant x s → terminate s → Spec x (extract s)
```

You may need to parameterize `Spec` explicitly:

```lean
structure InfoEfficientAlgorithm (Input State Output : Type _) (Spec : Input → Output → Prop) where
  ...
```

This is not just software engineering. It creates a reusable formal language in which binary search, Dijkstra, and FFT recursion can be compared under one roof.

A second useful new definition is a complexity certificate tied to divide-and-conquer or frontier refinement:

```lean
def logarithmic_steps (n k : ℕ) : Prop := n ≤ 2^k

def frontier_monotone
    {V : Type _} (dist : V → ℕ∞) (settled frontier : Set V) : Prop := ...
```

For FFT/NTT, define a formal transform-validity predicate:

```lean
def IsPrincipalRootNTT
    {R : Type _} [CommRing R] (ω : R) (n : ℕ) : Prop := 
  ω^n = 1 ∧ ∀ k < n, k ≠ 0 → ω^k ≠ 1
```

or, if Mathlib already offers a suitable root-of-unity predicate, use it and define instead a **butterfly decomposition certificate**:

```lean
def ButterflyFactorizationValid
    {R : Type _} [CommRing R] (ω : R) : ℕ → Prop
```

---

## Precise Theorem Targets

You must prove at least 3 substantial theorems. The following are the recommended flagship results.

### Theorem 1: Binary search correctness with logarithmic bound

Formalize binary search on a monotone Boolean predicate `p : Fin n → Bool` or an ordered array abstraction. The strongest clean theorem is a lower-bound index theorem.

#### Mathematical statement
Let `p : Fin n → Prop` be monotone:
\[
\forall i \le j,\; p(i) \to p(j).
\]
Assume there exists some `j` with `p j`. Then binary search returns the least index `i` such that `p i`, and uses at most `⌈log₂ n⌉ + C` iterations.

#### Suggested Lean theorem signature
```lean
theorem binarySearch_correct
    (n : ℕ)
    (p : Fin n → Prop)
    (mono : ∀ i j, i.val ≤ j.val → p i → p j)
    (hex : ∃ i, p i) :
    ∃ i : Fin n, p i ∧ ∀ j : Fin n, p j → i.val ≤ j.val
```

A complexity theorem should accompany it:

```lean
theorem binarySearch_steps_le_log
    (n : ℕ) :
    ∃ C : ℕ, ∀ h : 0 < n, binarySearchSteps n ≤ Nat.ceilLog2 n + C
```

If `Nat.ceilLog2` is inconvenient, use a power-of-two bound:

```lean
theorem binarySearch_steps_pow_bound
    (n : ℕ) (h : 0 < n) :
    2 ^ binarySearchSteps n ≤ 2 * n
```

This can be converted to logarithmic complexity.

### Why this is a breakthrough
Binary search is usually verified as a toy imperative algorithm. You should instead formalize it as a theorem that **ordered information can be extracted at exponential rate per comparison**. This becomes the prototype for the information-efficiency framework.

---

### Theorem 2: Dijkstra correctness via frontier invariants

#### Mathematical statement
For a finite weighted graph with nonnegative edge weights, Dijkstra’s algorithm computes the shortest-path distance from a source `s` to every reachable vertex `v`. Once a vertex is extracted as minimal tentative distance, its label is final.

#### Suggested Lean theorem signature
Use a graph representation convenient in Lean, e.g. adjacency function with finite support, or finite edge set.

```lean
theorem dijkstra_settled_correct
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ∞)
    (s : V)
    (hw : ∀ u v, w u v = ⊤ ∨ ∃ n : ℕ, w u v = n) :
    ∀ v : V, settledByDijkstra w s v → distLabel w s v = shortestPathDist w s v
```

A more invariant-focused theorem:

```lean
theorem dijkstra_extract_min_final
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ∞) (s u : V) :
    frontierInvariant w s →
    extractedMin w s u →
    distLabel w s u = shortestPathDist w s u
```

And a global correctness statement:

```lean
theorem dijkstra_correct
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ∞) (s : V) :
    finalDistancesOfDijkstra w s = shortestPathDist w s
```

### Why this is a breakthrough
This turns shortest paths into a formally certified instance of **monotone variational computation**: local relaxation plus global minimality. It links graph algorithms to order theory and potential methods. If done cleanly, this becomes a reusable template for Bellman–Ford variants, A*, min-plus algebra, and tropical geometry.

---

### Theorem 3: NTT/FFT convolution theorem

#### Mathematical statement
Let `R` be a commutative ring/field with a principal `n`th root of unity `ω`, where `n` is invertible in `R`. Then the NTT diagonalizes cyclic convolution:
\[
\operatorname{NTT}(a ∗ b)(k)=\operatorname{NTT}(a)(k)\operatorname{NTT}(b)(k).
\]
Consequently, inverse NTT recovers convolution in \(O(n \log n)\) recursive butterfly steps.

#### Suggested Lean theorem signature
For vectors `Fin n → R`:

```lean
theorem ntt_mul_pointwise
    {R : Type _} [CommRing R]
    (n : ℕ) (ω : R)
    (hω : IsPrincipalRootNTT ω n)
    (a b : Fin n → R) :
    NTT ω (cyclicConvolution a b) =
      fun k => NTT ω a k * NTT ω b k
```

Inversion theorem:

```lean
theorem intt_ntt
    {R : Type _} [Field R]
    (n : ℕ) (ω : R)
    (hω : IsPrincipalRootNTT ω n)
    (hn : (n : R) ≠ 0)
    (a : Fin n → R) :
    INTT ω (NTT ω a) = a
```

Complexity recurrence theorem:

```lean
theorem fft_cost_bound
    (n : ℕ) (hpow : ∃ m, n = 2^m) :
    fftCost n ≤ C * n * Nat.log2 (n + 1) + C
```

You may instead prove a recurrence solution specialized to powers of two:
```lean
theorem fft_cost_pow2
    (m : ℕ) :
    fftCost (2^m) ≤ C * 2^m * m + C
```

### Why this is a breakthrough
A formally verified FFT/NTT is already substantial. But the real breakthrough is to connect transform algorithms with **algebraic symmetry factorization** and complexity compression. This opens the door to verified polynomial multiplication, coding theory, cryptography, and mechanized analytic number theory.

---

## Strong Cross-Domain Connection Requirement

You must include at least one theorem connecting algorithm verification to a distinct mathematical domain. The most promising options are:

### Option A: Information theory + binary search
Use catalog results to interpret binary search complexity as entropy collapse.

Build on:

- `full_search_collapses`  
  from `FINAL/Computation/SearchInfoIsomorphism.lean`
- `compressor_gives_complexity_bound`  
  from `FINAL/Computation/ClosureKolmogorovDuality.lean`
- `complexity_bound_implies_finite_entropy_bound`  
  from `FINAL/Computation/EntropyBridge.lean`

#### Visionary theorem
Show that the comparison trace of binary search induces a bounded information certificate for locating an index in an ordered search space.

Possible theorem shape:
```lean
theorem binarySearch_complexity_implies_entropy_bound
    (n : ℕ) :
    algorithmicComplexity (binarySearchTraceSpace n) ≤ Nat.ceilLog2 n + 1 →
    finiteEntropyBound (binarySearchTraceSpace n)
```

If the catalog notions are more abstract, adapt them faithfully. The key is to **explicitly use** the catalog bridge:
complexity bound → finite entropy bound.

This is not a cosmetic citation. It says binary search is a certified entropy-reduction mechanism.

### Option B: Tropical geometry + Dijkstra
Shortest paths live naturally in the min-plus semiring. Prove that Dijkstra computes min-plus linear propagation under nonnegative weights.

Possible theorem shape:
```lean
theorem dijkstra_agrees_with_tropical_closure
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ∞) (s : V) :
    dijkstraDistances w s = tropicalShortestPathClosure w s
```

This is the cleanest route to a number theory/algebra/geometry crossover. It reframes graph search as tropical linear algebra.

### Option C: Number theory + FFT/NTT
Formalize NTT over `ZMod p` for primes `p` with `n ∣ p - 1`, linking algorithm verification to arithmetic existence of roots of unity.

Possible theorem shape:
```lean
theorem exists_primitive_root_for_ntt
    (p n : ℕ)
    [Fact p.Prime]
    (hdiv : n ∣ p - 1) :
    ∃ ω : ZMod p, IsPrincipalRootNTT ω n
```

Then instantiate convolution correctness over `ZMod p`. This is extremely valuable for verified cryptographic arithmetic.

---

## Proof Strategy Architecture

You must not rely on a single proof idea. Develop at least 2–3 proof routes and choose the strongest.

### Strategy A: Invariant-first verification
Best for binary search and Dijkstra.

1. Define a state machine for the algorithm.
2. State a strong invariant:
   - binary search: the least satisfying index, if it exists, remains inside `[lo, hi)`;
   - Dijkstra: settled vertices have final distances, frontier vertices carry upper bounds.
3. Prove initialization, preservation, and termination using induction on steps or a decreasing measure.
4. Extract correctness from the invariant at termination.
5. Derive complexity from a potential function:
   interval length for binary search, number of unsettled vertices / queue operations for Dijkstra.

**Why promising:** This aligns with Lean’s strengths: structures, recursive functions, induction on execution length, and theorem reuse.

### Strategy B: Order-theoretic / algebraic reformulation
Best for Dijkstra and binary search.

1. Express binary search as bisection on a monotone predicate over a finite linear order.
2. Express Dijkstra as iterative least fixed-point approximation in the min-plus semiring or complete lattice of distance labels.
3. Prove correctness via monotone operators and least fixed-point characterization of shortest-path distances.
4. Show the operational algorithm refines the algebraic semantics.

**Why promising:** This yields the deepest mathematics and strongest cross-domain theorem. It converts algorithm proofs into order/algebra theorems.

### Strategy C: Divide-and-conquer matrix factorization
Best for FFT/NTT.

1. Define the transform matrix \(F_n = (\omega^{ij})\).
2. Prove a block factorization for \(F_{2n}\) into permutation, diagonal twiddle, and two copies of \(F_n\).
3. Derive correctness of recursive FFT from matrix factorization.
4. Prove convolution diagonalization using direct `calc` expansions and finite sum rearrangement.
5. Prove complexity by recurrence on powers of two.

**Why promising:** This is mathematically elegant and scales to future formalization of spectral algorithms.

### Recommended plan
- Use **Strategy A** for binary search.
- Use **Strategy A + B hybrid** for Dijkstra.
- Use **Strategy C** for FFT/NTT.
- Then connect one of them to catalog information/entropy theorems for the field-opening result.

---

## How to Build on Existing Verified Theorems

You have real catalog leverage. Use it.

### 1. `full_search_collapses`
File: `FINAL/Computation/SearchInfoIsomorphism.lean`

Interpret this as saying exhaustive search spaces can be compressed/collapsed into a canonical information representation. Your move is to prove that **binary search realizes a structured collapse** for ordered search spaces with exponentially fewer probes than full search.

Use it to compare:
- naive full search trace space,
- binary search trace space,
- order-induced information collapse.

### 2. `compressor_gives_complexity_bound`
File: `FINAL/Computation/ClosureKolmogorovDuality.lean`

Use this theorem after constructing a concrete “trace compressor” for one algorithm:
- binary search decision trace,
- Dijkstra predecessor tree / settled-order certificate,
- FFT butterfly circuit description.

The point is to certify that structural regularity gives complexity bounds.

### 3. `complexity_bound_implies_finite_entropy_bound`
File: `FINAL/Computation/EntropyBridge.lean`

This should be your bridge theorem for the boldest statement:
> a verified algorithm with a complexity certificate yields a finite entropy bound on its observable trace space.

This is the cleanest way to turn program verification into scientific mathematics.

### 4. `tropical_and_bound`
File: `FINAL/Computation/OracleApplicationsFrontier.lean`

If you pursue the tropical shortest-path route, use this as evidence that tropical operations already appear in the catalog and can support a min-plus reformulation of Dijkstra. Even if the theorem is not directly about shortest paths, it gives you a formal bridge to tropical reasoning.

---

## Required Theorem Portfolio

At minimum, your Lean development should contain:

1. **Binary search correctness theorem** with a nontrivial loop invariant.
2. **Binary search logarithmic complexity theorem** using a measure-halving argument.
3. **Dijkstra extracted-min/finality theorem** using frontier invariants.
4. **Dijkstra global correctness theorem** for all vertices.
5. **NTT convolution theorem** or inverse-transform theorem.
6. **One cross-domain theorem**:
   - binary search ↔ entropy/information,
   - Dijkstra ↔ tropical algebra,
   - NTT ↔ number-theoretic root existence.
7. **One complexity theorem** proved by recurrence/induction, not by simplification.

You only need 3 deep theorems minimum, but the above is the standard of ambition you should aim for.

---

## Suggested Lean 4 Type Signatures

These are prototypes, not shackles.

```lean
theorem binarySearch_invariant
    (p : Fin n → Prop)
    (mono : ∀ i j, i.val ≤ j.val → p i → p j)
    :
    ∀ s, BinarySearch.Inv p s → ¬ BinarySearch.done s → BinarySearch.Inv p (BinarySearch.step p s)
```

```lean
theorem binarySearch_correct
    (p : Fin n → Prop)
    (mono : ∀ i j, i.val ≤ j.val → p i → p j)
    (hex : ∃ i, p i) :
    ∃ i : Fin n, p i ∧ ∀ j : Fin n, p j → i.val ≤ j.val
```

```lean
theorem binarySearch_steps_le
    (n : ℕ) :
    binarySearchSteps n ≤ Nat.succ (Nat.log2 (n + 1))
```

```lean
theorem dijkstra_relax_preserves_upper_bound
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ∞) (s : V) :
    ∀ u v, FrontierInv w s u → FrontierInv w s (relax w u v)
```

```lean
theorem dijkstra_extract_min_final
    {V : Type _} [Fintype V] [DecidableEq V]
    (w : V → V → ℕ∞) (s u : V) :
    FrontierInv w s u → ExtractedMin w s u →
    distLabel w s u = shortestPathDist w s u
```

```lean
theorem ntt_convolution
    {R : Type _} [CommRing R]
    (n : ℕ) (ω : R)
    (hω : IsPrincipalRootNTT ω n)
    (a b : Fin n → R) :
    NTT ω (cyclicConvolution a b) =
      fun k => NTT ω a k * NTT ω b k
```

```lean
theorem fft_recursion_cost
    (m : ℕ) :
    fftCost (2^m) ≤ C * 2^m * m + C
```

```lean
theorem binarySearch_entropy_bridge
    (n : ℕ) :
    ComplexityBound (binarySearchTraceSpace n) (Nat.ceilLog2 n + 1) →
    FiniteEntropyBound (binarySearchTraceSpace n)
```

Adapt notation to actual catalog APIs.

---

## Nontrivial Proof Tactics You Should Actually Use

You are required to exhibit depth in proof style, not just theorem statements.

- Use **induction** on recursion depth / interval length / powers of two.
- Use **`rcases`** to unpack existence of shortest paths, witnesses, and root-of-unity hypotheses.
- Use **`by_contra`** for minimality/finality arguments in binary search and Dijkstra.
- Use **`field_simp`** where needed in inverse NTT over fields.
- Use **multi-step `calc`** blocks for convolution identities and path-weight inequalities.
- Use finite sum manipulations (`Finset.sum_*`) rather than brute-force computation.

---

## Falsifiable Conjecture with Computational Test

You must include at least one conjecture with a clear disproof protocol.

### Recommended conjecture
**Conjecture (entropy-optimality of binary search traces).**
For every `n ≥ 1`, among all deterministic comparison algorithms locating the first true index of a monotone Boolean predicate on `Fin n`, binary search minimizes maximal trace entropy up to an additive constant.

Possible Lean-side declaration:
```lean
conjecture binarySearch_trace_entropy_optimal :
  ∀ n ≥ 1, ∀ A ∈ DeterministicMonotoneSearchAlgorithms n,
    traceEntropy (binarySearchAlg n) ≤ traceEntropy A + C
```

### Computational test
In `demo.py`, enumerate all deterministic comparison trees for small `n` (say `n ≤ 8`), compute:
- worst-case comparisons,
- empirical trace entropy over uniform monotone instances,
- compare against binary search.

A counterexample at small `n` would falsify the conjecture immediately.

Alternative conjectures:
- Dijkstra’s settled-order trace is tropical-minimal among label-setting algorithms.
- Radix-2 NTT butterfly factorization is arithmetic-operation minimal among exact convolution circuits of size `2^m` up to small `m`.

---

## Cross-Domain Connections to Emphasize

This project should explicitly connect algorithm verification to multiple mathematical worlds:

- **Information theory:** binary search as entropy reduction.
- **Order/lattice theory:** monotone predicates and fixed-point semantics.
- **Tropical geometry / min-plus algebra:** Dijkstra as tropical linear propagation.
- **Number theory:** existence of roots of unity for NTT over `ZMod p`.
- **Physics / variational language:** Dijkstra as monotone energy minimization on a discrete landscape.
- **Representation / harmonic analysis:** FFT as symmetry-adapted basis change.

These are not decorative analogies. They are the basis for theorems and future generalization.

---

## Application Keywords

formal verification, certified algorithms, binary search, Dijkstra, FFT, NTT, shortest paths, loop invariants, complexity bounds, entropy bounds, Kolmogorov complexity, information theory, tropical geometry, min-plus algebra, finite fields, roots of unity, convolution, divide-and-conquer, mechanized mathematics, Lean 4, Mathlib, algorithmic optimality, verified cryptography, spectral algorithms

---

## Mandatory Deliverables

You must produce **ALL** of the following:

1. **A structured `FUTURE_DIRECTIONS.md`** with 3–5 testable scientific hypotheses.  
   Each must be a falsifiable conjecture with:
   - precise statement,
   - why it might be true,
   - explicit computational or formal test that could disprove it.

2. **A `RESEARCH_PAPER.md`** that is a standalone scientific document.  
   Someone reading only this paper, without the code, must understand:
   - the exact theorems,
   - the new definitions,
   - why they matter,
   - what was proved formally,
   - what experiments or computations support the conjectures,
   - what future work is now possible.

3. **An `ARTICLE.md`** in Scientific American style.  
   It must explain, in accessible language, how classic algorithms were recast as laws of information flow and algebraic structure.

4. **A verified algorithm or computational method**, not just theorem statements.  
   At least one of binary search, Dijkstra, or NTT must be implemented in Lean in executable form with proved specification.

5. **A `demo.py`** that demonstrates the result interactively.  
   It should:
   - run binary search traces and compare to full search,
   - visualize Dijkstra frontier evolution on small graphs,
   - show NTT-based convolution vs naive convolution,
   - test the conjecture on small instances.

---

## Final Call

Do not write a polite verification exercise. Write a new chapter in mechanized mathematics:

- binary search as the formal geometry of ordered ignorance,
- Dijkstra as tropical variational dynamics,
- FFT as certified symmetry compression.

The real prize is not three algorithms. It is a **formal science of why efficient algorithms exist at all**.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Computation
Research mode: prove
