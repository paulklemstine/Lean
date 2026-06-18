## Assignment: Goldbach Verification Framework — but make it mathematically real

This direction is only worth pursuing if you **do not** treat it as a brute-force certification exercise. A mere formal proof that Goldbach holds up to \(10^6\) by reflection is not a breakthrough. The breakthrough is to build a **general additive-prime verification architecture** in Lean 4: a framework that separates

1. structural parity/combinatorial obstructions,
2. certified finite verification,
3. reusable “circle-method-style” major/minor arc abstractions,
4. and a tactic/algorithm layer that can certify additive decompositions from externally generated witnesses.

Your target is therefore not “Goldbach up to a bound,” but a **formal additive number theory platform** whose first flagship instantiation is Goldbach verification.

Use the existing verified parity results such as `even_odd_family` and `three_odd_forces_odd_d` as the seed of a robust parity obstruction layer. In particular, these are not the final destination; they are the microscopic local rules from which the global additive-prime framework should be assembled.

---

## Mode: prove

## Core Vision

Construct a Lean 4 framework for **certified additive prime decompositions** that proves mathematically nontrivial structural theorems, supports finite verification of binary Goldbach up to a parameter \(N\), and formalizes a reusable abstraction of the Hardy–Littlewood heuristic/circle-method decomposition without pretending to formalize the full analytic machinery of Vinogradov unless the necessary analysis is already genuinely available in Mathlib.

The deepest contribution here would be:

- a **new formal structure** encoding additive decomposition problems over arithmetic subsets of \(\mathbb N\),
- a **representation-transfer theorem** reducing universal verification over an interval to a finite certificate schema,
- a **parity obstruction theorem** explaining why odd/even decomposition types behave differently,
- and a **verified search algorithm / tactic** that turns explicit prime-pair witnesses into theorem-producing certificates.

If full Vinogradov is too far from current Mathlib analysis infrastructure, do **not** fake it. Instead, formalize the exact finite-combinatorial skeleton that a future circle-method proof would need, and prove the strongest honest theorem available now.

---

## Precise theorem targets

You must prove at least 3 substantial theorems with multi-step arguments. At least one should involve induction or interval decomposition; at least one should use contradiction/parity obstruction; at least one should connect number theory to another domain such as combinatorics, finite algorithms, or harmonic-analytic abstractions.

### New definition requirement

Define a genuinely new concept, for example:

```lean
structure AdditiveBasisCertificate where
  carrier : Finset ℕ
  witness : ℕ → Option (ℕ × ℕ)
  sound_prime_left : ∀ n p q, witness n = some (p,q) → Nat.Prime p
  sound_prime_right : ∀ n p q, witness n = some (p,q) → Nat.Prime q
  sound_sum : ∀ n p q, witness n = some (p,q) → p + q = n
```

and/or

```lean
def RepresentsAsSumFrom (s : Set ℕ) (k n : ℕ) : Prop :=
  ∃ f : Fin k → ℕ, (∀ i, f i ∈ s) ∧ (∑ i, f i) = n
```

and/or

```lean
def GoldbachUpTo (N : ℕ) : Prop :=
  ∀ n, 4 ≤ n → n ≤ N → Even n →
    ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n
```

A stronger and more reusable abstraction would be:

```lean
def TwoPrimeRepresentable (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

def ThreePrimeRepresentable (n : ℕ) : Prop :=
  ∃ p q r : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ Nat.Prime r ∧ p + q + r = n
```

These definitions are simple, but the novelty lies in building a **certificate and transfer framework** around them.

---

## Theorem 1: Interval transfer / certificate soundness theorem

This should be a central formally meaningful theorem, not a one-off check.

### Statement
If a certificate provides valid prime-pair witnesses for every even \(n\) in an interval \([4,N]\), then Goldbach holds on that interval.

### Lean 4 type signature
A plausible target:

```lean
theorem certificate_implies_GoldbachUpTo
  (N : ℕ)
  (C : AdditiveBasisCertificate)
  (hcov :
    ∀ n, 4 ≤ n → n ≤ N → Even n →
      ∃ p q, C.witness n = some (p,q))
  : GoldbachUpTo N := by
  ...
```

If you choose a certificate indexed only on the interval, then adapt the type accordingly.

### Why this matters
This theorem converts computation into mathematics in a reusable way: not “the machine checked Goldbach to \(10^6\),” but “any externally generated witness table can be imported into Lean and certified once and for all.” This is the right architecture for future verification at \(10^8\), \(10^{10}\), or for ternary Goldbach variants.

### Proof strategy options
**Strategy A: direct extraction from certificate fields**
1. Unfold `GoldbachUpTo`.
2. Use `hcov` to obtain a witness pair.
3. Apply the soundness axioms of the certificate to recover primality and sum equality.

**Strategy B: interval induction on even numbers**
1. Prove a helper theorem that every even \(n \in [4,N]\) lies in the certificate domain.
2. Induct through the interval in steps of 2.
3. At each step extract and validate the witness.
This is more elaborate and may better support future “contiguous interval certification” results.

**Most promising:** Strategy A for the main theorem, Strategy B for a secondary theorem showing how interval coverage can be compressed to a stepwise certificate.

---

## Theorem 2: Parity obstruction theorem for prime additive representations

This theorem should explain, in a mathematically clean way, why binary and ternary Goldbach problems split by parity. Build explicitly on `even_odd_family` and `three_odd_forces_odd_d`.

### Statement
Every sum of two odd primes is even, and every representation of an odd integer \(n > 5\) as a sum of two primes must use \(2\) as one summand. Equivalently, odd numbers cannot generically satisfy binary Goldbach except in the degenerate \(2 + p\) case.

### Lean 4 type signature
For example:

```lean
theorem odd_two_prime_rep_forces_two
  {n p q : ℕ}
  (hn : Odd n)
  (hp : Nat.Prime p)
  (hq : Nat.Prime q)
  (hsum : p + q = n) :
  p = 2 ∨ q = 2 := by
  ...
```

and then a corollary:

```lean
theorem odd_gt_five_not_sum_of_two_odd_primes
  {n p q : ℕ}
  (hn : Odd n)
  (hgt : 5 < n)
  (hp : Nat.Prime p)
  (hq : Nat.Prime q)
  (hpodd : Odd p)
  (hqodd : Odd q) :
  p + q ≠ n := by
  ...
```

You may also prove a ternary analogue:

```lean
theorem three_odd_primes_sum_is_odd
  {p q r : ℕ}
  (hp : Nat.Prime p) (hq : Nat.Prime q) (hr : Nat.Prime r)
  (hpodd : p ≠ 2) (hqodd : q ≠ 2) (hrodd : r ≠ 2) :
  Odd (p + q + r) := by
  ...
```

### Why this matters
This is not elementary fluff if done correctly: it becomes the formal local obstruction theory for additive prime problems. It clarifies why binary Goldbach lives on even integers while Vinogradov’s theorem lives on odd integers. This is the first layer of a future circle method formalization: the singular series is useless unless local obstructions are understood first.

### Proof strategy options
**Strategy A: parity of primes**
1. Prove or import that every prime \(p \neq 2\) is odd.
2. Use `even_odd_family` to control parity of sums.
3. Derive contradiction if both primes are odd and sum to an odd number.

**Strategy B: contradiction via modular arithmetic mod 2**
1. Show primes \(> 2\) are \(1 \mod 2\).
2. Compute \((p+q) \mod 2\).
3. Conclude one summand must be 2.

**Strategy C: bridge to ternary setting using `three_odd_forces_odd_d`**
1. Rephrase odd-prime summands as odd integers.
2. Apply the existing theorem to derive parity of the total.
3. Use this as the combinatorial backbone for the ternary representation layer.

**Most promising:** A hybrid of A and C, because it visibly builds on catalog theorems and creates a reusable parity API.

---

## Theorem 3: Monotone extension theorem for verified Goldbach ranges

This theorem is conceptually important for scalable verification.

### Statement
If `GoldbachUpTo N` holds and you have certified witnesses for all even \(n\) in \((N,M]\), then `GoldbachUpTo M` holds.

### Lean 4 type signature
```lean
theorem GoldbachUpTo.extend
  {N M : ℕ}
  (hNM : N ≤ M)
  (hN : GoldbachUpTo N)
  (hnew :
    ∀ n, N < n → n ≤ M → Even n →
      ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n) :
  GoldbachUpTo M := by
  ...
```

### Why this matters
This is the theorem that turns verification into a **modular research program**. Instead of one giant proof for \(10^6\), you get compositional extension lemmas. This is exactly how large-scale formal verification should work: small trusted kernels, append-only certificates, monotone range extension.

### Proof strategy options
**Strategy A: split by `n ≤ N` or `N < n`**
1. Fix \(n\) in \([4,M]\).
2. By cases on `n ≤ N`.
3. Apply either `hN` or `hnew`.

**Strategy B: interval decomposition as sets**
1. Define the set of even integers verified by Goldbach.
2. Show \([4,M] = [4,N] ∪ (N,M]\).
3. Push representation property through union decomposition.

**Most promising:** Strategy A. It is simple but not trivial, and it establishes the compositional backbone for all future certification workflows.

---

## Theorem 4: Cross-domain theorem — additive representation as a finite bipartite covering problem

You are required to include a cross-domain connection. The best one here is **number theory + combinatorics/algorithms**.

Define the prime set in a range and the Goldbach graph:
- left/right vertices are primes \(\le N\),
- an even number \(n\) is “covered” if it is the label of some edge \(p+q=n\).

### New definition
```lean
def goldbachPairsUpTo (N : ℕ) : Finset (ℕ × ℕ) :=
  ((Nat.primesBelow (N+1)).product (Nat.primesBelow (N+1))).filter
    (fun pq => pq.1 + pq.2 ≤ N)

def CoveredEvens (N : ℕ) : Set ℕ :=
  {n | ∃ p q, (p,q) ∈ goldbachPairsUpTo N ∧ p + q = n}
```

If `Nat.primesBelow` does not exist exactly in this form, define your own finite prime list with proofs of correctness.

### Statement
Every even \(n \le N\) is Goldbach-representable iff \(n\) lies in the edge-sum cover of the prime graph up to \(N\).

### Lean 4 type signature
```lean
theorem goldbach_graph_cover_iff
  {N n : ℕ} (h4 : 4 ≤ n) (hnN : n ≤ N) (he : Even n) :
  TwoPrimeRepresentable n ↔ n ∈ CoveredEvens N := by
  ...
```

### Why this matters
This reframes Goldbach as a **finite covering problem on a graph/hypergraph**, connecting additive number theory to combinatorics, certified search, and complexity theory. It opens the door to:
- optimized witness compression,
- sparse covering certificates,
- SAT/SMT-assisted search with Lean-verified replay,
- and eventually probabilistic heuristics formally compared against actual coverage data.

### Proof strategy options
**Strategy A: unfold definitions**
1. From a two-prime representation, show both primes are \(\le n \le N\).
2. Package them into the graph edge.
3. Conversely, extract a pair from graph coverage and read off primality.

**Strategy B: finite-set extensionality**
1. Define the set of all even numbers represented by prime pairs.
2. Show equality with `CoveredEvens N`.
3. Deduce the pointwise iff.

**Most promising:** Strategy A for a first implementation; Strategy B if you want a more elegant reusable library theorem.

---

## Ambitious but honest analytic target: circle-method skeleton, not fake full Vinogradov

Do **not** claim to have formalized Vinogradov’s theorem unless you actually formalize the necessary analytic estimates. Instead, define the formal skeleton needed for a future proof.

### Suggested formalization target
Define a finite exponential sum proxy over roots of unity / finite Fourier transforms:

```lean
def primeWeightSum (N : ℕ) (θ : ℝ) : ℂ :=
  ∑ n in Finset.range (N+1), (if Nat.Prime n then Complex.exp (2 * Real.pi * Complex.I * θ * n) else 0)
```

Then define a decomposition into “major” and “minor” regions abstractly:

```lean
structure CirclePartition where
  major : Set ℝ
  minor : Set ℝ
  disjoint : Disjoint major minor
  cover : major ∪ minor = Set.univ
```

You can then prove purely structural lemmas such as:
- decomposition of an integral/sum over major and minor pieces,
- monotonicity bounds,
- triangle-inequality-based upper estimates,
- finite Fourier representation identities in a discrete setting.

### Structural theorem
```lean
theorem major_minor_decomposition_bound
  (N : ℕ) (P : CirclePartition) :
  ‖primeWeightSum N‖ ≤
    ‖(major contribution)‖ + ‖(minor contribution)‖ := by
  ...
```

Even if the exact analytic objects need adaptation to available Mathlib APIs, the point is to create a **formal interface** for future circle-method proofs. This is your cross-domain bridge: additive number theory ↔ harmonic analysis.

---

## Explicit anti-goal

Do **not** spend the cycle “proving Goldbach up to \(10^6\)” solely by a giant `native_decide`. That violates the spirit of the project and the depth requirements. Computation is acceptable only when wrapped in a mathematically meaningful certification theorem and accompanied by structural theorems.

---

## Concrete Lean targets

You should aim to produce a file containing at least these theorem names or close analogues:

```lean
def TwoPrimeRepresentable (n : ℕ) : Prop := ...
def ThreePrimeRepresentable (n : ℕ) : Prop := ...
def GoldbachUpTo (N : ℕ) : Prop := ...
structure AdditiveBasisCertificate where ...

theorem certificate_implies_GoldbachUpTo
  (N : ℕ) (C : AdditiveBasisCertificate) ... : GoldbachUpTo N := by ...

theorem odd_two_prime_rep_forces_two
  {n p q : ℕ} ... : p = 2 ∨ q = 2 := by ...

theorem GoldbachUpTo.extend
  {N M : ℕ} ... : GoldbachUpTo M := by ...

theorem goldbach_graph_cover_iff
  {N n : ℕ} ... : TwoPrimeRepresentable n ↔ n ∈ CoveredEvens N := by ...
```

If feasible, add:

```lean
theorem even_of_two_odd_primes_sum
  {p q : ℕ} ... : Even (p + q) := by ...

theorem odd_of_three_odd_primes_sum
  {p q r : ℕ} ... : Odd (p + q + r) := by ...
```

These should not be one-line tautologies; the proof scripts should showcase real tactic structure: `rcases`, helper lemmas, parity rewriting, contradictions, interval case splits, and `calc`.

---

## Recommended file architecture

Create a focused file, e.g.
`NumberTheory/Goldbach/VerificationFramework.lean`

Suggested sections:
1. Basic representation definitions.
2. Prime parity lemmas.
3. Certificate structures and soundness.
4. Interval extension theorems.
5. Graph-cover/combinatorial reformulation.
6. Optional harmonic-analysis/circle-method interface.
7. Verified tactic/algorithm.

---

## Verified algorithm requirement

You must deliver a **verified algorithm or computational method**, not only theorem statements.

### Minimal acceptable algorithm
A function that, given an even `n`, searches downward through candidate primes and returns an optional witness pair:

```lean
def findGoldbachPair (n : ℕ) : Option (ℕ × ℕ) := ...
```

with a theorem of the form:

```lean
theorem findGoldbachPair_sound
  {n p q : ℕ}
  (h : findGoldbachPair n = some (p,q)) :
  Nat.Prime p ∧ Nat.Prime q ∧ p + q = n := by ...
```

and, if you can manage it, a completeness theorem relative to a finite search space:

```lean
theorem findGoldbachPair_complete
  {n : ℕ}
  (hrep : TwoPrimeRepresentable n) :
  ∃ p q, findGoldbachPair n = some (p,q) := by ...
```

This is the theorem that upgrades the algorithm from heuristic code to verified mathematics.

### Tactic requirement
Implement a small tactic or elaborator utility that closes goals of the form
`TwoPrimeRepresentable n`
when a witness pair is known or can be found by the verified search procedure.

Even a lightweight tactic that replays a certificate table is acceptable if fully sound.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture with a clear computational disproof criterion.

A strong candidate:

### Conjecture: sparse witness monotonicity
For sufficiently large even \(n\), the minimal prime \(p\) such that \(n-p\) is prime is \(O((\log n)^2)\).

Formal informal statement:
> There exists \(C > 0\) such that for all sufficiently large even \(n\), there is a Goldbach representation \(n = p + q\) with \(p \le C(\log n)^2\).

This is falsifiable: compute the least witnessing prime for all even \(n \le B\), and search for violations against explicit constants \(C\).

A more Lean-friendly finite prediction:
```lean
def leastGoldbachPrime (n : ℕ) : Option ℕ := ...
```
Conjecture:
> For all even \(n \in [4,10^7]\), `leastGoldbachPrime n ≤ 1000`.

This can be disproved by a single counterexample and is therefore scientifically meaningful.

A second possible conjecture connecting to graph theory:
> The Goldbach graph on primes up to \(N\) covers all even vertices up to \(N\) with edge multiplicity growing at least logarithmically on average.

This opens a bridge to probabilistic combinatorics.

---

## Cross-domain connections to emphasize

1. **Additive number theory ↔ certified algorithms**  
   Goldbach becomes a theorem about sound witness extraction and replayable certificates.

2. **Additive number theory ↔ graph theory / hypergraph covering**  
   Prime-pair sums define a finite covering system of even integers.

3. **Additive number theory ↔ harmonic analysis**  
   Circle-method major/minor arc decomposition can be formalized as an interface for exponential-sum bounds.

4. **Additive number theory ↔ complexity theory**  
   The search for short certificates of representability suggests compressed proof objects, SAT encodings, and complexity bounds for additive witness verification.

5. **Additive number theory ↔ statistical physics / random models**  
   The heuristic density of prime representations mirrors pair-correlation phenomena and partition-function style counts. Even a brief discussion in the paper could seed future work.

---

## Application keywords

Goldbach conjecture, additive number theory, certified computation, formal verification, Lean 4, Mathlib, prime representations, parity obstructions, graph covering, finite certificates, witness extraction, proof-producing algorithms, circle method, harmonic analysis, exponential sums, ternary Goldbach, Vinogradov framework, computational number theory, theorem-proving tactics, complexity-aware certification.

---

## Deliverables — all mandatory

You must produce **all** of the following:

1. **Lean formalization** with at least 3 nontrivial theorems as above, minimizing `sorry`.
2. **A verified algorithm or computational method**, with soundness theorem.
3. **A working `demo.py`** that:
   - queries or emulates the witness search,
   - demonstrates sample certified Goldbach decompositions,
   - and visualizes the Goldbach graph / coverage statistics up to a user-chosen bound.
4. **`FUTURE_DIRECTIONS.md`** with 3–5 testable scientific hypotheses. Each must be falsifiable with a specified computation or formal experiment.
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - problem statement,
   - formal definitions,
   - main theorems,
   - algorithmic architecture,
   - significance,
   - limitations,
   - and next-step research agenda.
6. **`ARTICLE.md`** in Scientific American style:
   - explain why formalizing additive prime problems matters,
   - how proof assistants turn computations into mathematics,
   - and what this framework could mean for the future of experimental mathematics.

---

## Final standard

Do not deliver a decorative formalization. Deliver the beginnings of a **formal additive prime theory stack**. The finite Goldbach verifier is only the first module. The real result is a reusable architecture that future Aristotle can extend toward ternary Goldbach, Schnirelmann-type additive bases, and eventually genuine circle-method formalization.

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

Research domain: Algebra
Research mode: prove
