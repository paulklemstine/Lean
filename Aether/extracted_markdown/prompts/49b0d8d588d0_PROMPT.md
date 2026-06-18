## Assignment: Legendre's Conjecture as a Formal Prime-Gap Program

Mode: **prove + formalize + discover**

You are not being asked for a cosmetic restatement of Legendre’s conjecture. You are being asked to architect a formal research program around one of the oldest unresolved assertions in prime number theory, extracting the strongest unconditional theorems Mathlib can currently support, and then building a probabilistic/heuristic bridge to the Cramér model that makes the eventual conjecture mathematically actionable in Lean.

The central target is deliberately audacious:

> **Legendre Conjecture.**  
> For every positive integer `n`, there exists a prime `p` such that
> `n^2 < p ∧ p < (n+1)^2`.

This is open. Therefore the breakthrough is not “prove Legendre in Lean” by wishful thinking, but to produce a **field-opening formal scaffold** that:
1. isolates the exact obstruction,
2. proves nontrivial unconditional interval-prime theorems around squares,
3. formalizes square-gap criteria implying Legendre,
4. encodes the Cramér heuristic as a precise asymptotic/random-model prediction,
5. creates a reusable Lean framework for translating prime-gap theorems into interval-prime theorems.

Your mission is to formalize the strongest mathematically meaningful theorems you can actually certify, while making the conjecture structurally inevitable.

---

## Core Mathematical Targets

### Target A: Gap-to-Legendre reduction theorem
The first theorem should not be conjectural. It should show that any sufficiently strong prime-gap bound implies Legendre.

A precise mathematical statement:

> If every sufficiently large prime `p_k` satisfies  
> `p_(k+1) - p_k < 2 * sqrt(p_k) + 1`,  
> then for all sufficiently large `n`, there exists a prime in `(n^2, (n+1)^2)`.

This is the correct structural theorem: Legendre is a consequence of prime gaps smaller than the interval length between consecutive squares.

A Lean-facing formulation should avoid explicit prime indexing if painful, and instead use a generic interval-covering hypothesis.

### Suggested Lean 4 theorem signature
```lean
theorem legendre_of_prime_gap_bound
  (N : ℕ)
  (hgap :
    ∀ m ≥ N, ∃ p : ℕ,
      Nat.Prime p ∧ m < p ∧ p ≤ m + (2 * Nat.sqrt m + 1)) :
  ∀ n : ℕ, n*n ≥ N → ∃ p : ℕ, Nat.Prime p ∧ n*n < p ∧ p < (n+1)*(n+1)
```

This formulation replaces difficult consecutive-prime indexing with a directly usable short-interval prime hypothesis. It is mathematically honest: any theorem proving primes in intervals of length `2√x+1` yields Legendre for large `n`.

The key identity is:
`(n+1)^2 - n^2 = 2n + 1`,
and for `m = n^2`, one has `Nat.sqrt m = n`. Hence
`m + (2 * Nat.sqrt m + 1) = n^2 + 2n + 1 = (n+1)^2`.

To get strict inequality `< (n+1)^2`, you may need the interval hypothesis with `<` instead of `≤`, or else prove the endpoint cannot itself be prime for `n ≥ 1` because `(n+1)^2` is composite. That endpoint-exclusion lemma is easy and useful.

### Supporting lemma
```lean
theorem sq_succ_not_prime {n : ℕ} (h : 1 ≤ n+1) :
  ¬ Nat.Prime ((n+1)*(n+1))
```
or more naturally
```lean
theorem not_prime_sq {m : ℕ} (hm : 2 ≤ m) : ¬ Nat.Prime (m^2)
```

This is a crucial bridge lemma: if your interval theorem only gives `p ≤ (n+1)^2`, this lemma upgrades it to `p < (n+1)^2`.

---

### Target B: Explicit unconditional theorem from existing prime-existence results
If Mathlib contains Bertrand’s postulate / existence of a prime between `n` and `2n`, leverage it to prove a genuine theorem about intervals near squares.

A robust target:

> For every `n ≥ 2`, there exists a prime `p` with  
> `n^2 < p ∧ p < 2n^2`.

This is weaker than Legendre, but nontrivial and fully formalizable from Bertrand. It demonstrates that square-origin intervals contain primes with explicit control.

### Suggested Lean 4 theorem signature
```lean
theorem exists_prime_between_sq_and_two_mul_sq
  {n : ℕ} (hn : 2 ≤ n) :
  ∃ p : ℕ, Nat.Prime p ∧ n^2 < p ∧ p < 2 * n^2
```

This theorem matters because it is the first rung in a hierarchy:
- prime in `(x, 2x)` by Bertrand,
- prime in shorter intervals near `x = n^2`,
- eventually prime in `(n^2, n^2 + O(n))`,
- finally prime in `(n^2, (n+1)^2)`.

A second unconditional strengthening, if available from Mathlib’s Chebyshev/Bertrand infrastructure:

```lean
theorem exists_prime_between_sq_and_sq_plus_linear
  (hShortInterval :
    ∀ x ≥ X0, ∃ p, Nat.Prime p ∧ x < p ∧ p < x + C * Nat.sqrt x) :
  ...
```

Even if this remains abstract, formalizing the reduction is valuable.

---

### Target C: Finite verification reduction
Legendre can be reduced to a finite computation if a sufficiently strong asymptotic interval theorem is assumed beyond a threshold.

> If there exists `N` such that every interval `(m, m + 2√m + 1]` with `m ≥ N` contains a prime, and Legendre is verified by computation for all `n < √N`, then Legendre holds for all `n`.

### Suggested Lean 4 theorem signature
```lean
theorem legendre_of_eventually_short_interval_primes
  (N : ℕ)
  (hlarge :
    ∀ m ≥ N, ∃ p : ℕ, Nat.Prime p ∧ m < p ∧ p ≤ m + (2 * Nat.sqrt m + 1))
  (hsmall :
    ∀ n : ℕ, n*n < N → ∃ p : ℕ, Nat.Prime p ∧ n*n < p ∧ p < (n+1)*(n+1)) :
  ∀ n : ℕ, ∃ p : ℕ, Nat.Prime p ∧ n*n < p ∧ p < (n+1)*(n+1)
```

This theorem is mathematically powerful because it converts a global conjecture into:
- an eventual asymptotic theorem,
- plus finite verification.

That architecture is exactly how many major computational number theory results are organized.

---

### Target D: Cramér-model formalization layer
Do not try to formalize probability over the actual primes immediately. Instead define a **Cramér-style random prime indicator** on `ℕ≥2`, where `n` is independently “prime” with probability `1 / log n`, and derive the expected number of model-primes in the Legendre interval.

The heuristic prediction is:
\[
\mathbb{E}\left[\#\{k : n^2 < k < (n+1)^2,\ X_k = 1\}\right]
\approx \sum_{n^2 < k < (n+1)^2} \frac{1}{\log k}
\sim \frac{2n+1}{2\log n}.
\]
This tends to infinity, so the Cramér model predicts not merely one prime but many primes between consecutive squares.

A formal asymptotic target over `Real` and finite sums:

```lean
theorem cramer_legendre_interval_expectation_asymptotic :
  Filter.Tendsto
    (fun n : ℕ =>
      (∑ k in Finset.Icc (n^2 + 1) ((n+1)^2 - 1), (Real.log k)⁻¹) /
      (((2 : ℝ) * n + 1) / (2 * Real.log n)))
    Filter.atTop
    (nhds 1)
```

You may need to replace this with a more technically accessible asymptotic sandwich theorem first, e.g. upper/lower bounds showing the ratio tends to `1`. Even proving a coarse lower bound like
\[
\sum_{n^2 < k < (n+1)^2} \frac{1}{\log k}
\ge \frac{2n-1}{\log((n+1)^2)}
\]
is already meaningful and Lean-friendly.

A simpler rigorous theorem to target first:

```lean
theorem cramer_interval_expectation_lower_bound
  {n : ℕ} (hn : 2 ≤ n) :
  ((2 : ℝ) * n - 1) / Real.log ((n+1)^2)
    ≤
  ∑ k in Finset.Icc (n^2 + 1) ((n+1)^2 - 1), (Real.log k)⁻¹
```

This opens a bridge between analytic number theory and probabilistic combinatorics in Lean.

---

## Why this would be a breakthrough

Formal mathematics has many isolated prime lemmas and many isolated asymptotic tools. What is missing is a **unified formal machine** that converts:
- prime gap hypotheses,
- short interval prime theorems,
- finite computations,
- probabilistic heuristics,

into concrete interval-prime conclusions around polynomial sequences like `n^2`.

That machine would not only scaffold Legendre’s conjecture; it would generalize to:
- primes between values of other sparse sequences,
- Brocard-type intervals between consecutive prime squares,
- Oppermann-style conjectures,
- short interval heuristics for polynomial images,
- formal comparisons between deterministic and random models of primes.

This is exactly the sort of infrastructure that transforms Lean from a theorem repository into a laboratory for speculative analytic number theory.

---

## Proof Strategy Architecture

### Strategy 1: Interval-length transference from short-interval hypotheses
Most promising.

1. **Abstract interval theorem.**  
   Prove a generic lemma: if every interval `(m, m + L(m)]` contains a prime, and `L(n^2) ≤ (n+1)^2 - n^2`, then there is a prime between consecutive squares.
2. **Specialize to `L(m) = 2 * sqrt(m) + 1`.**  
   Use `Nat.sqrt (n^2) = n` to identify the interval endpoint exactly.
3. **Exclude the right endpoint.**  
   Use `¬ Nat.Prime ((n+1)^2)` for `n+1 ≥ 2`.

Why this is best: it isolates the essence of Legendre into one transference principle, making later asymptotic or computational advances immediately usable.

---

### Strategy 2: Finite verification + eventual theorem
Best for a publishable formal artifact if direct asymptotics are hard.

1. Formalize a theorem reducing Legendre to:
   - an eventual short-interval-prime statement beyond `N`,
   - plus explicit verification for `n < B`.
2. Implement a computational checker for small `n` using primality decision procedures in Lean or an external verified script.
3. Package the result as a template for other interval conjectures.

Why this matters: this is the exact architecture used in computational analytic number theory. Even absent a proof of Legendre, the theorem is structurally deep and reusable.

---

### Strategy 3: Cramér-model expectation and concentration heuristics
Most visionary cross-domain direction.

1. Define the expected count in the square interval:
   `E_n = ∑_{k=n^2+1}^{(n+1)^2-1} 1/log k`.
2. Prove explicit lower and upper bounds on `E_n` using monotonicity of `log`.
3. If probability tools are available, derive a heuristic “probability of no model-prime” upper bound:
   \[
   \prod_{k}(1 - 1/\log k) \approx \exp(-E_n),
   \]
   which decays rapidly as `n → ∞`.

Why this matters: it turns Legendre from a static conjecture into a formally quantified random-model prediction. This is a bridge between analytic number theory, probability, and formal asymptotics.

---

## Concrete Lean Targets

You should aim to create a file family such as:

- `Speculative/AutoResearch/LegendreGapReduction.lean`
- `Speculative/AutoResearch/LegendreBertrandIntervals.lean`
- `Bridges/CramerModelSquareIntervals.lean`

### Theorem candidates

```lean
theorem not_prime_sq {m : ℕ} (hm : 2 ≤ m) : ¬ Nat.Prime (m^2)
```

```lean
theorem legendre_of_prime_in_short_intervals
  (N : ℕ)
  (h :
    ∀ m ≥ N, ∃ p : ℕ, Nat.Prime p ∧ m < p ∧ p ≤ m + (2 * Nat.sqrt m + 1)) :
  ∀ n : ℕ, n^2 ≥ N → ∃ p : ℕ, Nat.Prime p ∧ n^2 < p ∧ p < (n+1)^2
```

```lean
theorem exists_prime_between_sq_and_two_mul_sq
  {n : ℕ} (hn : 2 ≤ n) :
  ∃ p : ℕ, Nat.Prime p ∧ n^2 < p ∧ p ∧ p < 2 * n^2
```
(If parser issues arise, correct the duplicated conjunction.)

```lean
theorem legendre_of_eventually_verified
  (N : ℕ)
  (hlarge :
    ∀ m ≥ N, ∃ p : ℕ, Nat.Prime p ∧ m < p ∧ p ≤ m + (2 * Nat.sqrt m + 1))
  (hsmall :
    ∀ n : ℕ, n^2 < N → ∃ p : ℕ, Nat.Prime p ∧ n^2 < p ∧ p < (n+1)^2) :
  ∀ n : ℕ, ∃ p : ℕ, Nat.Prime p ∧ n^2 < p ∧ p < (n+1)^2
```

```lean
theorem cramer_interval_expectation_lower_bound
  {n : ℕ} (hn : 2 ≤ n) :
  (((2 : ℝ) * n - 1) / Real.log ((n+1)^2 : ℝ))
    ≤
  ∑ k in Finset.Icc (n^2 + 1) ((n+1)^2 - 1), (Real.log (k : ℝ))⁻¹
```

If asymptotic APIs are manageable:

```lean
theorem cramer_square_interval_expectation_diverges :
  Filter.Tendsto
    (fun n : ℕ =>
      ∑ k in Finset.Icc (n^2 + 1) ((n+1)^2 - 1), (Real.log (k : ℝ))⁻¹)
    Filter.atTop
    Filter.atTop
```

This theorem alone would be a beautiful formal statement of the heuristic abundance of primes between consecutive squares in the Cramér world.

---

## Building on catalog theorems

The listed catalog theorems are not obviously number-theoretic, but that is not a reason to ignore them; it is an invitation to create a bridge.

- `exists_prime_theory_avoiding` from `PrimeCongruenceProofSemiring.lean`  
  This suggests a formal language around “prime” as a structural existence principle in algebraic settings. Use it conceptually to motivate an abstraction layer: prime existence in arithmetic intervals should be treated as a certified witness problem, not just an existential theorem. If the theorem is reusable at the level of avoiding finite obstructions, investigate whether interval-prime searches can be phrased as avoiding composite congruence patterns.

- `krull_height_theorem_security_prime`  
  The keyword “security_prime” hints at prime-sensitive algebraic certification. Cross-pollinate by viewing short-interval primes as arithmetic certificates with bounded search radius, analogous to bounded-height prime witnesses in algebraic geometry.

- `exists_refinement_cell_for_pair` and the ultrametric witness theorems  
  These can inspire a surprising cross-domain analogy: intervals between squares form a one-dimensional “cell decomposition” of the integers, and Cramér-style local prime densities define a probabilistic geometry on these cells. If a theorem or definition can be repurposed, do so; if not, cite the analogy in `ARTICLE.md` as part of the conceptual bridge.

Do not force meaningless dependencies. But do extract a methodological principle: **existence theorems become stronger when reformulated as witness-localization theorems**. That is exactly what short-interval prime theorems are.

---

## Cross-domain connections to develop

### 1. Analytic number theory × probability
The Cramér model is the obvious bridge. Formalize expectation bounds for prime-like random variables on square intervals.

### 2. Number theory × computational complexity
Legendre’s conjecture can be reframed as a bounded-search witness problem:
given `n`, find a prime in an interval of length `2n`.  
This is a search problem with arithmetic structure. Discuss whether stronger interval-prime theorems imply low-complexity certified witness extraction.

### 3. Number theory × discrete geometry
The intervals `(n^2, (n+1)^2)` partition the integers into annuli around squares. Prime occupancy in these annuli resembles a lattice-point occupancy problem with varying local density.

### 4. Number theory × statistical mechanics
The Cramér heuristic treats primes as a dilute gas with site occupation probability `1/log n`. The absence of primes in a square interval is then a rare-event probability analogous to a local vacuum fluctuation.

These are not decorative metaphors. They suggest formal definitions, asymptotic observables, and falsifiable hypotheses.

---

## Nontrivial definitions worth introducing

1. **Square interval**
```lean
def squareInterval (n : ℕ) : Finset ℕ :=
  Finset.Icc (n^2 + 1) ((n+1)^2 - 1)
```

2. **Prime count in a square interval**
```lean
def squarePrimeCount (n : ℕ) : ℕ :=
  ((squareInterval n).filter Nat.Prime).card
```

3. **Cramér expected prime count**
```lean
def cramerSquareExpectation (n : ℕ) : ℝ :=
  ∑ k in squareInterval n, (Real.log (k : ℝ))⁻¹
```

4. **Legendre property**
```lean
def LegendreHolds (n : ℕ) : Prop :=
  ∃ p : ℕ, Nat.Prime p ∧ n^2 < p ∧ p < (n+1)^2
```

Then prove relations among these definitions. This creates an extensible formal API.

---

## What to avoid

- Do **not** claim to have proved Legendre’s conjecture unconditionally.
- Do **not** spend the cycle on tiny variants like changing `n^2` to `n^2+1`.
- Do **not** bury the work in numerical experiments without theorem extraction.
- Do **not** use the Cramér model only rhetorically; formalize at least one rigorous expectation bound.

---

## Deliverables

### Required Lean deliverables
1. At least one unconditional theorem about primes in intervals starting at `n^2`.
2. At least one reduction theorem of the form “short interval primes imply Legendre.”
3. At least one formal theorem about Cramér-model expected prime count on square intervals.
4. Minimize `sorry`; if any remain, isolate them in analytically difficult asymptotic lemmas rather than elementary arithmetic facts.

### Required documentation
Produce `FUTURE_DIRECTIONS.md` with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a clear computational or formal test.

You must include hypotheses of the following flavor:

1. **Gap-threshold hypothesis**  
   There exists an explicit `N` such that for all `m ≥ N`, there is a prime in `(m, m + 2*sqrt(m)]`.  
   **Test:** verify numerically up to a large bound; compare against known maximal prime gaps.

2. **Square-interval occupancy hypothesis**  
   For all `n ≥ N0`, `squarePrimeCount n ≥ 2`.  
   **Test:** compute `squarePrimeCount n` for growing ranges and search for counterexamples.

3. **Cramér calibration hypothesis**  
   The ratio  
   `squarePrimeCount n / cramerSquareExpectation n`  
   has limsup and liminf near `1` on sampled ranges.  
   **Test:** empirical evaluation on large intervals.

4. **Brocard-strengthened hypothesis**  
   Between `p_k^2` and `p_(k+1)^2`, the number of primes is at least `2` for all `k ≥ K`.  
   **Test:** enumerate prime squares and count interval primes.

5. **Complexity-witness hypothesis**  
   There exists a practical algorithm whose average search time for a prime in `(n^2, (n+1)^2)` is polylogarithmic in `n` under Cramér-style assumptions.  
   **Test:** benchmark randomized search over large `n`.

These must be precise enough to be refuted.

---

## Application keywords

**analytic number theory, prime gaps, Legendre conjecture, Cramér model, short intervals, formal asymptotics, certified search, probabilistic number theory, computational verification, sparse sequences, prime-count heuristics, Lean 4, Mathlib**

---

## Final directive

Treat Legendre’s conjecture not as a single impossible theorem, but as the nucleus of a new formal discipline: **interval arithmetic of primes around sparse polynomial sequences**. Build the transference lemmas. Build the witness theorems. Build the probabilistic bridge. Build the finite-verification architecture. If the direct road is blocked, construct the map that will make the road inevitable.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Speculative
Research mode: prove
