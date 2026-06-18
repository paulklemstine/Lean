## Assignment: Cramér's Conjecture on Prime Gaps

Mode: **prove + formalize + counterexample-aware**

Your stated target, “prove that consecutive prime gaps satisfy `p_{n+1} - p_n = O((log p_n)^2)`,” is currently far beyond known mathematics. Treat that exact asymptotic as a **guiding north star**, not as the first formal theorem. The real breakthrough is to build a Lean framework in which:

1. **rigorous unconditional prime-gap bounds** are formalized,
2. **probabilistic Cramér-style models** are defined and analyzed,
3. **bridges between heuristic random models and certified arithmetic statements** are made explicit,
4. and, if the strong conjectural target is unreachable, you prove sharp structural theorems that make the conjecture mathematically testable inside Lean.

Do not settle for toy lemmas. Build a formal theory of prime-gap growth that can support future attacks on Cramér-type phenomena.

---

### Visionary Research Objective

Construct a Lean 4 blueprint for a new formal field:

> **Certified Prime Gap Theory**: a synthesis of analytic number theory, probabilistic combinatorics, and asymptotic formalization, where one can state and prove unconditional upper/lower bounds on prime gaps, define random prime models, and compare heuristic predictions to arithmetic reality.

The revolutionary point is not merely to restate folklore; it is to create a machine-checkable infrastructure where:
- prime gaps become explicit arithmetic objects,
- asymptotic upper bounds become formal predicates,
- random models produce theorem-level predictions,
- and discrepancy between model and theorem becomes quantifiable.

This opens a path toward formalized analytic number theory in Mathlib at a level that can eventually absorb:
- Bertrand/postulate-type interval results,
- Chebyshev bounds,
- explicit prime-counting inequalities,
- Cramér, Granville, and Poisson gap heuristics,
- and even future formalized sieve arguments.

---

## Core Definitions to Introduce

You should define a canonical “next prime” and prime gap function, avoiding dependence on the abstract indexing `p_n` unless Mathlib already provides a convenient nth-prime object.

A promising route is:

```lean
def NextPrime (n : ℕ) : ℕ := Nat.minFac (n+1) -- placeholder, likely not correct for "next prime"
```

But this is not the right final definition. Instead define:

```lean
def IsNextPrimeAfter (n p : ℕ) : Prop :=
  Nat.Prime p ∧ n < p ∧ ∀ m, n < m → m < p → ¬ Nat.Prime m
```

and then, once existence is available from Mathlib or from a formalized Euclid/Bertrand theorem, package:

```lean
noncomputable def nextPrimeAfter (n : ℕ) : ℕ := sInf {p : ℕ | IsNextPrimeAfter n p}
```

or a finite-search equivalent once interval existence is known.

Then define the gap:

```lean
def primeGapAfter (n : ℕ) : ℕ := nextPrimeAfter n - n
```

If nth-prime infrastructure exists in Mathlib, also define:

```lean
def primeGapNth (n : ℕ) : ℕ := nthPrime (n+1) - nthPrime n
```

and prove equivalence lemmas between the “next prime after” and “nth prime” viewpoints where possible.

---

## Precise Theorem Targets

### Theorem A: Existence of the next prime after any integer
This is foundational and should be made theorem-level clean.

**Lean target:**
```lean
theorem exists_next_primeAfter (n : ℕ) :
  ∃ p, IsNextPrimeAfter n p
```

This is not deep by itself, but it is the gateway to every later theorem. Use Euclid-style infinitude of primes plus well-ordering/minimality.

---

### Theorem B: Strict positivity of prime gaps
A sanity theorem, but useful for later asymptotic comparisons.

**Lean target:**
```lean
theorem primeGapAfter_pos (n : ℕ) :
  0 < primeGapAfter n
```

This should be immediate from `n < nextPrimeAfter n`.

---

### Theorem C: Bertrand-style linear upper bound on prime gaps
This is the first genuinely nontrivial theorem with classical significance.

For `n ≥ 1`, there is a prime in `(n, 2n]`, hence the next prime after `n` is at most `2n`, so the gap is at most `n`.

**Lean target:**
```lean
theorem primeGapAfter_le_self_of_one_le (n : ℕ) (h : 1 ≤ n) :
  primeGapAfter n ≤ n
```

Equivalent form:
```lean
theorem nextPrimeAfter_le_two_mul (n : ℕ) (h : 1 ≤ n) :
  nextPrimeAfter n ≤ 2 * n
```

This is already a meaningful formalized prime-gap theorem. If Bertrand’s postulate is not in Mathlib, proving/formalizing it becomes a major contribution.

---

### Theorem D: Infinitely many “small relative gap” primes
From Bertrand alone one gets infinitely many primes `p` with a successor prime `q ≤ 2p`, i.e. gap at most `p`.

**Lean target:**
```lean
theorem infinitely_many_primes_with_gap_le_self :
  Set.Infinite {p : ℕ | Nat.Prime p ∧ primeGapAfter p ≤ p}
```

This theorem transforms an interval theorem into an infinitude statement and sets up a reusable pattern for stronger gap theorems later.

---

### Theorem E: Formal asymptotic framework for Cramér-type bounds
Do **not** fake a proof of Cramér’s conjecture. Instead formalize the statement as a precise predicate.

A natural asymptotic predicate over naturals/real-valued functions:

```lean
def BigO_NatToReal (f g : ℕ → ℝ) : Prop :=
  ∃ C N, 0 < C ∧ ∀ n ≥ N, ‖f n‖ ≤ C * ‖g n‖
```

Then define the conjectural statement:

```lean
def CramerConjecture : Prop :=
  BigO_NatToReal
    (fun n => (primeGapNth n : ℝ))
    (fun n => Real.log (nthPrime n))^2
```

More syntactically carefully in Lean:
```lean
def CramerConjecture : Prop :=
  ∃ C N : ℝ, 0 < C ∧
    ∀ n : ℕ, N ≤ n →
      ((primeGapNth n : ℝ) ≤ C * (Real.log (nthPrime n))^ 2)
```

You may need to adjust domains so `N : ℕ` and coerce to reals:
```lean
def CramerConjecture : Prop :=
  ∃ C : ℝ, ∃ N : ℕ, 0 < C ∧
    ∀ n ≥ N, (primeGapNth n : ℝ) ≤ C * (Real.log (nthPrime n))^2
```

This is not the theorem to prove now; it is the formal target around which the entire architecture is organized.

---

### Theorem F: A rigorous probabilistic Cramér-model expectation theorem
This is where originality can emerge.

Define a finite Bernoulli model where each integer `m ≥ 3` is independently “prime-like” with probability `1 / log m` (or a truncated safe version to avoid pathologies for small `m`). Then prove an expectation estimate for the number of model-primes in an interval.

**Lean target sketch:**
```lean
def cramerWeight (m : ℕ) : ℝ :=
  if h : 2 ≤ m then 1 / Real.log m else 0

def expectedPrimeLikesInInterval (N H : ℕ) : ℝ :=
  ∑ m in Finset.Icc N (N+H), cramerWeight m
```

Then target a theorem of the shape:
```lean
theorem expectedPrimeLikes_interval_asymp_lower
    (N H : ℕ) (hN : 3 ≤ N) :
  (H : ℝ) / Real.log (N + H) ≤ expectedPrimeLikesInInterval N H
```

and similarly an upper bound:
```lean
theorem expectedPrimeLikes_interval_asymp_upper
    (N H : ℕ) (hN : 3 ≤ N) :
  expectedPrimeLikesInInterval N H ≤ ((H + 1 : ℕ) : ℝ) / Real.log N
```

These are rigorous monotonicity-based estimates, not probabilistic handwaving. Once formalized, they become the seed of machine-checked Cramér heuristics.

---

### Theorem G: Heuristic threshold theorem for logarithmic-square intervals
In the Cramér model, intervals of length about `(log N)^2` should contain a prime-like number with nontrivial probability. You can make this exact for the model.

If you define the Bernoulli product measure formally, prove a finite version:

> For suitable `A > 1`, the probability that `[N, N + ⌈A (log N)^2⌉]` contains at least one model-prime is bounded below by a positive constant tending heuristically toward `1 - exp(-A)`.

A finite explicit lower bound is enough.

**Lean target sketch:**
```lean
theorem cramer_model_interval_nonempty_lower_bound
    (A : ℝ) (N : ℕ) (hA : 0 < A) (hN : 16 ≤ N) :
  let H := Nat.ceil (A * (Real.log N)^2)
  -- probability statement over a finite independent Bernoulli family
  True
```

You may need to first formalize only the deterministic expectation estimate and leave the full product-probability theorem for a second pass. But if you can pull off even a finite Bernoulli inequality theorem in Lean, that is a serious bridge result.

---

## Why This Would Be a Breakthrough

A direct proof of Cramér’s conjecture is unrealistic. But a formalized theory that cleanly separates:
- unconditional arithmetic theorems,
- asymptotic conjectures,
- random model predictions,
- and explicit discrepancy statements

would be genuinely field-opening for Lean mathematics.

It would create the first reusable formal substrate for:
- probabilistic number theory,
- certified prime gap experimentation,
- asymptotic comparison of random and arithmetic sequences,
- and eventually formalized sieve heuristics.

This is especially powerful because prime gaps sit at the fault line between:
- **deterministic arithmetic structure** and
- **pseudo-random statistical behavior**.

That same interface drives modern work in additive combinatorics, complexity theory, pseudorandomness, and even spectral methods.

---

## 2–3 Proof Strategy Architectures

### Strategy 1: Arithmetic-first, theorem-certification route
Most promising for immediate formal success.

1. **Define `IsNextPrimeAfter`, `nextPrimeAfter`, `primeGapAfter` cleanly.**
   Prove existence/uniqueness/minimality lemmas using infinitude of primes and well-ordering.
2. **Formalize Bertrand’s postulate or import an existing Mathlib theorem.**
   Deduce `nextPrimeAfter n ≤ 2*n` for `n ≥ 1`, hence `primeGapAfter n ≤ n`.
3. **Package asymptotic statements as definitions only.**
   Define `CramerConjecture`, `BigO_NatToReal`, and the comparison framework without proving the conjecture.

Why this is promising: it yields solid, nontrivial arithmetic theorems now, minimizes speculative dependencies, and produces infrastructure future cycles can strengthen.

---

### Strategy 2: Probabilistic-model-first route
Most visionary if Mathlib probability support is sufficient.

1. **Define finite Cramér weights** `1 / log m` on intervals `[N, N+H]`.
2. **Prove deterministic expectation bounds** via monotonicity of `log`:
   \[
   \frac{H+1}{\log(N+H)} \le \sum_{m=N}^{N+H}\frac{1}{\log m}
   \le \frac{H+1}{\log N}.
   \]
3. **Lift to Bernoulli occupancy probabilities** using independence and inequalities like
   \[
   \Pr(\text{none selected}) = \prod (1-p_m) \le e^{-\sum p_m}.
   \]
   Then deduce a lower bound for nonemptiness of intervals of length `A(log N)^2`.

Why this is promising: it creates a formal bridge from number theory to probabilistic combinatorics and turns Cramér’s conjecture into a theorem about a certified random model.

---

### Strategy 3: Counterexample-aware discrepancy route
Most scientifically honest and cross-domain rich.

1. **Formalize the conjectural statement and the random-model prediction side-by-side.**
2. **Prove the model predicts logarithmic-square scale occupancy.**
3. **Prove arithmetic theorems are presently much weaker**, e.g. linear-in-`n` from Bertrand, possibly stronger if catalog/Mathlib supports explicit interval-prime results.
4. **Define a discrepancy functional** measuring the gap between heuristic and theorem.

Why this is promising: even without proving new deep number theory, it gives a mathematically meaningful “distance-to-Cramér” formal object, ideal for future certified experiments.

---

## Cross-Domain Connections You Must Exploit

### 1. Probability theory / statistical mechanics
Cramér’s model is a dilute gas of rare events. Prime gaps become waiting times in an inhomogeneous Bernoulli process. This invites:
- occupancy bounds,
- large deviations,
- Poisson approximation,
- entropy-style arguments.

### 2. Complexity theory / pseudorandomness
Prime indicators behave partly random, partly structured. Formalizing discrepancy between true primes and Bernoulli models suggests analogies with:
- derandomization,
- pseudorandom generators,
- hardness vs randomness,
- extractor-style uniformity tests on arithmetic sequences.

### 3. Spectral / quantum analogy
Your catalog contains `spectral_gap_cf_bounds` and tropical/quantum material. Use this aggressively at the conceptual level:
- prime gaps as “energy level spacings,”
- Cramér model as a Poissonian spectrum,
- arithmetic deviations from Poisson as a spectral rigidity phenomenon.

Even if no direct theorem is possible yet, explicitly formulate this analogy in `FUTURE_DIRECTIONS.md` as falsifiable hypotheses.

### 4. Tropical / logarithmic compression
The catalog theorem `log_compression_bound` is elementary, but the thematic link is real: logarithms compress multiplicative scale to additive scale. Prime gap conjectures are fundamentally statements about additive fluctuations on logarithmically compressed coordinates. If possible, define normalized gaps
\[
g_n / (\log p_n)^2
\]
as a “log-compressed observable.”

---

## How to Build on the Catalog Theorems

The listed catalog theorems are not directly about primes, but do not ignore them. Use them as **bridging motifs**:

1. `log_compression_bound`  
   Use as a signal to build a systematic library of logarithmic comparison lemmas for naturals and reals:
   - positivity of `Real.log n` for `n ≥ 3`,
   - monotonicity on natural coercions,
   - bounds for `1 / log n` over intervals.
   This is likely much more useful than the theorem itself.

2. `spectral_gap_cf_bounds`  
   Leverage conceptually to define a “prime gap spectrum” section in `ARTICLE.md` or `FUTURE_DIRECTIONS.md`: compare empirical prime-gap histograms to Poisson/spectral spacing laws. If there is any reusable spectral inequality pattern in the file, adapt proof style or naming conventions.

3. `qTropMap_coordwise_bounds`  
   Not arithmetically relevant directly, but it exemplifies certified coordinatewise inequalities. Emulate that style when proving interval sum bounds for `1 / log n`: pointwise monotonic bounds aggregated over finite sets.

4. `inf'_eq_of_bounds_and_witness`  
   Potentially useful if you realize `nextPrimeAfter` via an infimum/minimum characterization over a finite/infinite set. This may actually become structurally relevant.

---

## Concrete Lean 4 Type Signatures to Aim For

Use these or close variants.

```lean
def IsNextPrimeAfter (n p : ℕ) : Prop :=
  Nat.Prime p ∧ n < p ∧ ∀ m : ℕ, n < m → m < p → ¬ Nat.Prime m
```

```lean
theorem exists_next_primeAfter (n : ℕ) :
  ∃ p : ℕ, IsNextPrimeAfter n p
```

```lean
noncomputable def nextPrimeAfter (n : ℕ) : ℕ := by
  classical
  exact Nat.find (exists_next_primeAfter n)
```

```lean
def primeGapAfter (n : ℕ) : ℕ :=
  nextPrimeAfter n - n
```

```lean
theorem nextPrimeAfter_prime (n : ℕ) :
  Nat.Prime (nextPrimeAfter n)
```

```lean
theorem lt_nextPrimeAfter (n : ℕ) :
  n < nextPrimeAfter n
```

```lean
theorem primeGapAfter_pos (n : ℕ) :
  0 < primeGapAfter n
```

```lean
theorem nextPrimeAfter_le_two_mul (n : ℕ) (h : 1 ≤ n) :
  nextPrimeAfter n ≤ 2 * n
```

```lean
theorem primeGapAfter_le_self_of_one_le (n : ℕ) (h : 1 ≤ n) :
  primeGapAfter n ≤ n
```

```lean
def cramerWeight (m : ℕ) : ℝ :=
  if h : 2 ≤ m then 1 / Real.log (m : ℝ) else 0
```

```lean
def expectedPrimeLikesInInterval (N H : ℕ) : ℝ :=
  ∑ m in Finset.Icc N (N + H), cramerWeight m
```

```lean
theorem expectedPrimeLikes_interval_lower
    (N H : ℕ) (hN : 3 ≤ N) :
  ((H + 1 : ℕ) : ℝ) / Real.log (N + H : ℝ)
    ≤ expectedPrimeLikesInInterval N H
```

```lean
theorem expectedPrimeLikes_interval_upper
    (N H : ℕ) (hN : 3 ≤ N) :
  expectedPrimeLikesInInterval N H
    ≤ ((H + 1 : ℕ) : ℝ) / Real.log (N : ℝ)
```

```lean
def CramerConjecture : Prop :=
  ∃ C : ℝ, ∃ N : ℕ, 0 < C ∧
    ∀ n ≥ N, (primeGapNth n : ℝ) ≤ C * (Real.log (nthPrime n : ℝ))^2
```

If `nthPrime` is unavailable, define the conjecture in terms of `nextPrimeAfter` instead:
```lean
def CramerConjecture_after : Prop :=
  ∃ C : ℝ, ∃ N : ℕ, 0 < C ∧
    ∀ n ≥ N, (primeGapAfter n : ℝ) ≤ C * (Real.log (n : ℝ))^2
```

This is not equivalent to the classical formulation but is a meaningful adjacent formal target.

---

## Minimal Nontrivial Milestone Sequence

1. `IsNextPrimeAfter` + existence + uniqueness.
2. `nextPrimeAfter` and `primeGapAfter` API.
3. Bertrand-based upper bound `primeGapAfter n ≤ n`.
4. Interval expectation bounds for the Cramér model.
5. Formal statement of `CramerConjecture`.
6. Optional: finite Bernoulli nonemptiness theorem for length `A(log N)^2`.

If you get all six, you have not proved Cramér’s conjecture—but you have created a new formal research platform around it.

---

## Counterexample Discipline

Be explicit in comments and theorem names:
- **Do not claim** the unconditional theorem `primeGapAfter n = O((log n)^2)`.
- If a proposed theorem would imply a known open problem, mark it as a conjecture or a definition, not a theorem.
- If Mathlib lacks ingredients for deep asymptotics, prove finite explicit inequalities instead.

A valuable contribution here is a **negative result about formal reach**:
- identify exactly which missing ingredients block a proof of stronger prime-gap bounds,
- and encode those dependencies in `FUTURE_DIRECTIONS.md`.

---

## Deliverables

### Required Lean files
Create one or more files such as:
- `Speculative/NumberTheory/PrimeGapFramework.lean`
- `Speculative/NumberTheory/CramerModel.lean`
- `Speculative/NumberTheory/PrimeGapAsymptotics.lean`

### Required theorem content
At minimum prove:
- existence of next prime,
- positivity of prime gap,
- a nontrivial upper bound from Bertrand or equivalent interval-prime theorem,
- deterministic expectation bounds for the Cramér model.

### Required documentation
Produce `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**.

Each must have:
- a precise conjecture,
- a clear computational or formal test,
- a statement of what evidence would refute it.

---

## Mandatory FUTURE_DIRECTIONS.md hypotheses

Include entries of this flavor:

### Cramér-Model Occupancy Threshold
**Conjecture**: For every real `A > 1`, there exists `N₀` such that for all `N ≥ N₀`, the Cramér model assigns probability at least `0.5` to the event that `[N, N + ⌈A (log N)^2⌉]` contains a model-prime.  
**Test**: Formalize the finite Bernoulli product on intervals and prove an explicit lower bound from `1 - exp(-S)` where `S` is the interval expectation.  
**Refutation criterion**: Failure to derive a uniform lower bound from the certified expectation estimates.

### Prime/Model Discrepancy Functional
**Conjecture**: There exists a formally definable discrepancy statistic `D(N,H)` comparing true prime counts and Cramér expectations on intervals `[N,N+H]` such that `D(N,⌈(log N)^2⌉)` is unbounded.  
**Test**: Define `D` in Lean and compute/estimate it for explicit finite ranges.  
**Refutation criterion**: Evidence that all certified discrepancy estimates remain uniformly bounded on tested ranges.

### Spectral Spacing Analogy for Prime Gaps
**Conjecture**: Normalized prime gaps exhibit a certified finite-sample spacing statistic closer to Poisson than to Wigner-Dyson behavior.  
**Test**: Define finite histogram/statistic pipelines over actual prime gaps and compare to explicit reference distributions.  
**Refutation criterion**: Certified numerical evidence that the statistic is systematically closer to a non-Poisson spectral law.

### Log-Compressed Prime Gap Stability
**Conjecture**: The normalized observable `g(n) / (log n)^2` is more stable under dyadic rescaling than `g(n)` itself, in the sense of smaller certified oscillation on intervals `[2^k, 2^(k+1)]`.  
**Test**: Define oscillation metrics and compare exact computations on finite ranges.  
**Refutation criterion**: Certified computations showing no reduction in oscillation after normalization.

### Bertrand-to-Cramér Formal Bridge
**Conjecture**: Every future strengthening of interval-prime theorems in Lean can be functorially converted into a prime-gap upper bound theorem for `primeGapAfter`.  
**Test**: Build an abstraction layer taking as input a theorem `∀ n≥N, ∃ p prime, n < p ∧ p ≤ n + F n` and outputting `primeGapAfter n ≤ F n`.  
**Refutation criterion**: Discovery of a formal obstruction preventing this transfer principle.

---

## Application Keywords

analytic number theory, prime gaps, Cramér conjecture, probabilistic number theory, Bernoulli processes, Poisson approximation, asymptotic analysis, certified randomness, pseudorandomness, spectral statistics, logarithmic normalization, formalized mathematics, Lean 4, Mathlib, interval prime theorems, discrepancy theory, additive-combinatorial heuristics

---

You are not being asked for a cosmetic formalization of a famous conjecture. You are being asked to create the first serious Lean architecture in which prime gaps can be studied simultaneously as:
- arithmetic facts,
- asymptotic objects,
- and stochastic predictions.

That architecture is the theorem.

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
