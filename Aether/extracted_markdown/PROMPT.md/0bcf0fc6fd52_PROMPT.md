## Assignment: **prove**

### Breakthrough Objective
Turn the symbolic-dynamical structure of digit expansions into a formal transcendence engine. The decisive target is not a small extension of existing complexity criteria, but a theorem that converts **finite-state describability** into **arithmetic impossibility** for algebraic irrationals. The conceptual leap is this:

> **Minimal aperiodic sofic systems are automata-theoretic generators of transcendental numbers.**

If formalized cleanly in Lean 4, this opens a new corridor between **symbolic dynamics**, **automata theory**, **finite-state compression**, and **Diophantine transcendence**.

---

## Theorem Target 1: Sofic transcendence from linear factor complexity

### Precise mathematical statement
Let `b ≥ 2`. Let `a : ℕ → Fin b` be the base-`b` digit sequence of a real number `x ∈ (0,1)`. Assume:

1. `a` belongs to a **minimal aperiodic sofic shift** `X`,
2. every sequence in `X` has factor complexity bounded linearly:
   \[
   \exists C,D \in \mathbb{N},\ \forall n \ge 1,\ p_a(n) \le Cn + D,
   \]
   where `p_a(n)` is the number of distinct length-`n` blocks in `a`,
3. `a` is not eventually periodic.

Then `x` is transcendental.

This should be packaged as a corollary of the Adamczewski–Bugeaud style theorem already present in the catalog, presumably something like:

- `transcendental_of_nonperiodic_linear_complexity`

The nontrivial new theorem is the bridge from **soficity** to **linear complexity**, with minimality/aperiodicity supplying the non-eventual-periodicity hypothesis.

### Lean 4 theorem signature target
A realistic formal target is:

```lean
theorem transcendental_of_mem_minimal_aperiodic_sofic
    {b : ℕ} (hb : 2 ≤ b)
    (a : ℕ → Fin b) (x : ℝ)
    (hx : hasBaseBDigits b x a)
    (hX_sofic : SoficShift b X)
    (hmem : a ∈ X)
    (hmin : MinimalShift X)
    (haper : AperiodicShift X) :
    Transcendental ℚ x
```

If the catalog already phrases transcendence via irrationality plus non-algebraicity, adapt to its exact predicate. A more modular intermediate theorem is:

```lean
theorem eventuallyLinear_factorComplexity_of_sofic
    {b : ℕ} {X : Set (ℕ → Fin b)}
    (hX_sofic : SoficShift b X) :
    ∃ C D : ℕ, ∀ a ∈ X, ∀ n : ℕ, 1 ≤ n → factorComplexity a n ≤ C * n + D
```

and then

```lean
theorem not_eventuallyPeriodic_of_mem_minimal_aperiodic
    {b : ℕ} {X : Set (ℕ → Fin b)} {a : ℕ → Fin b}
    (hmem : a ∈ X) (hmin : MinimalShift X) (haper : AperiodicShift X) :
    ¬ EventuallyPeriodic a
```

followed by the synthesis theorem:

```lean
theorem transcendental_of_sofic_digits
    {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) (x : ℝ)
    (hx : hasBaseBDigits b x a)
    (hlin : ∃ C D : ℕ, ∀ n : ℕ, 1 ≤ n → factorComplexity a n ≤ C * n + D)
    (haper : ¬ EventuallyPeriodic a) :
    Transcendental ℚ x
```

using the catalog theorem `transcendental_of_nonperiodic_linear_complexity`.

---

## Theorem Target 2: Finite-state compression gap for algebraic irrationals

### Precise mathematical statement
Let `a : ℕ → Fin b` be the base-`b` digit sequence of an algebraic irrational real `x`. Define `fsComplexity a N` to be the minimum number of states of a deterministic finite automaton/transducer sufficient to generate the prefix `a|_N`.

A bold theorem target is:

\[
\forall b \ge 2,\ \forall x \in (0,1),\ 
\bigl(\text{$x$ algebraic irrational}\bigr)
\to
\forall K,\ \exists^\infty N,\ fsComplexity(a,N) > K.
\]

This is the minimal rigorous “no bounded finite-state compression” statement. A stronger form, if reachable, is:

\[
\exists c>0,\ \forall^\infty? \text{ or infinitely many } N,\ fsComplexity(a,N)\ge cN.
\]

But the first theorem is the right opening wedge: prove **unbounded** finite-state complexity from transcendence criteria plus a formal lemma that bounded finite-state complexity implies membership in a sofic/automatic system and hence linear factor complexity.

### Lean 4 theorem signature target
Conservative target:

```lean
theorem fsComplexity_unbounded_of_algebraic_irrational
    {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) (x : ℝ)
    (hx : hasBaseBDigits b x a)
    (halg : Algebraic ℚ x)
    (hirr : Irrational x) :
    ∀ K : ℕ, ∃ N : ℕ, K < fsComplexity a N
```

Ambitious strengthened target:

```lean
theorem exists_infinitelyMany_fsComplexity_ge_linear_of_algebraic_irrational
    {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) (x : ℝ)
    (hx : hasBaseBDigits b x a)
    (halg : Algebraic ℚ x)
    (hirr : Irrational x) :
    ∃ c > 0, Set.Infinite {N : ℕ | c * N ≤ fsComplexity a N}
```

If `fsComplexity : (ℕ → Fin b) → ℕ → ℕ` is already in the catalog, build directly on it. If not, first formalize the finite-state model carefully enough to prove the boundedness-to-soficity implication.

---

## Core building blocks to exploit from the catalog
You explicitly mentioned:

- `transcendental_of_nonperiodic_linear_complexity`
- `fsComplexity`

You should search for nearby lemmas with names resembling:

- `factorComplexity`
- `EventuallyPeriodic`
- `hasBaseBDigits`
- `automatic` / `sofic` / `subshift`
- any theorem relating bounded automata/state complexity to low subword complexity

The key architecture is:

1. **Sofic presentation ⇒ linear factor complexity**
2. **Minimal aperiodic shift ⇒ no eventual periodicity**
3. **Linear complexity + nonperiodicity ⇒ transcendence**
4. **Bounded finite-state description complexity ⇒ sofic/automatic envelope**
5. **Therefore algebraic irrational digits force unbounded finite-state complexity**

If the exact catalog theorem is stronger, use it aggressively; do not reprove AB from scratch.

---

## Proof strategy sketches

### Strategy A: Graph-presentation route for Hypothesis 1 — most promising
This is the cleanest formal path.

#### Step 1: Formalize sofic shifts via labeled finite directed graphs
Represent a sofic shift `X` by a finite graph `G` with edge labels in `Fin b`, where `a ∈ X` iff every finite block of `a` labels a path in `G` (or iff `a` is read along a bi-infinite path, depending on your chosen convention).

Then prove:

```lean
theorem factorComplexity_le_numPaths
    factorComplexity a n ≤ numLabelWordsOfLength G n
```

and then bound `numLabelWordsOfLength G n)` linearly in the right-resolving/minimal presentation setting, or at least by `V * n` using follower-set control if the presentation is deterministic enough.

#### Step 2: Extract linear complexity
For a minimal right-resolving sofic presentation, the number of distinct length-`n` factors is bounded by the number of vertex pairs/follower sets times `n`, or by a catalog lemma if one already exists. You do **not** need the sharp constant; any affine bound suffices.

#### Step 3: Apply transcendence criterion
Invoke `transcendental_of_nonperiodic_linear_complexity`, after discharging non-eventual-periodicity from minimal aperiodicity.

**Why this is most promising:** it leverages finite combinatorics, avoids heavy number theory, and reduces the arithmetic content to a previously formalized theorem.

---

### Strategy B: Rauzy graph / follower-set route
Instead of path counting directly on a sofic presentation, work with the language of the shift.

#### Step 1
Define the set of length-`n` factors and the Rauzy graph whose vertices are length-`n` words and edges are length-`n+1` words.

#### Step 2
Show that in a sofic shift, the number of follower sets is finite. Then prove that finite follower-set cardinality implies eventual affine upper bound on factor complexity:
\[
p(n+1)-p(n)\le M
\]
for some finite `M`, hence
\[
p(n)\le p(1)+M(n-1).
\]

#### Step 3
Apply the transcendence criterion.

**Why this is powerful:** it isolates the true symbolic-dynamical invariant — finite follower sets — and may generalize beyond sofic shifts to broader classes later (quasi-sofic, substitutive, S-adic systems).

---

### Strategy C: Compression-first route for Hypothesis 2
Attack the finite-state complexity statement via contradiction.

#### Step 1
Prove a structural lemma:
if `fsComplexity a N ≤ K` for all `N`, then all prefixes of `a` are generated by a fixed finite family of `K`-state machines, hence the set of factors of `a` is recognized inside a finite automata-theoretic envelope; in particular, `a` lies in a sofic shift or has uniformly linear factor complexity.

A plausible theorem target:

```lean
theorem linear_factorComplexity_of_bounded_fsComplexity
    {b : ℕ} {a : ℕ → Fin b}
    (hK : ∃ K, ∀ N, fsComplexity a N ≤ K) :
    ∃ C D, ∀ n ≥ 1, factorComplexity a n ≤ C * n + D
```

#### Step 2
Use algebraic irrationality to rule out eventual periodicity.

#### Step 3
Apply `transcendental_of_nonperiodic_linear_complexity` contrapositive-style to conclude bounded `fsComplexity` is impossible.

**Why this matters:** it converts transcendence into a **finite-state incompressibility principle**, which is conceptually new and computationally testable.

---

## Deeper mathematical insight: what really needs to be proved

The crucial symbolic fact is not merely “sofic shifts have linear complexity” in some vague sense. The deeper invariant is:

> **Finite follower-set entropy collapse** forces affine subword complexity.

For a shift `X`, if the number of distinct follower sets of words is finite, then the first difference `p(n+1)-p(n)` is uniformly bounded. This is the true theorem behind the sofic case. If you can formalize this more general statement, the sofic theorem becomes an immediate corollary and the resulting framework will be far more reusable.

A breakthrough-level intermediate theorem would therefore be:

```lean
theorem linear_factorComplexity_of_finiteFollowerSets
    {b : ℕ} {X : Set (ℕ → Fin b)}
    (hfin : Set.Finite {F : Set (List (Fin b)) | ∃ w, followerSet X w = F}) :
    ∃ C D : ℕ, ∀ a ∈ X, ∀ n ≥ 1, factorComplexity a n ≤ C * n + D
```

This theorem would elevate the project from “a sofic corollary” to a new formal bridge theorem in symbolic dynamics.

---

## Cross-domain connections to exploit

### 1. Symbolic dynamics ↔ transcendence theory
The main bridge is Adamczewski–Bugeaud: low combinatorial complexity of digits obstructs algebraicity. Your theorem would formalize the slogan:

- **Finite automaton structure in the digit expansion implies transcendence.**

This is a dramatic strengthening of the old intuition that “too much regularity forces transcendence.”

### 2. Automata theory ↔ Diophantine approximation
Finite-state compressibility is a computational regularity notion. Showing that algebraic irrationals resist it turns a Diophantine statement into a computational lower bound. This is analogous in spirit to complexity-theoretic lower bounds, but for arithmetic expansions.

### 3. Formal language theory ↔ arithmetic geometry
Sofic languages are regular at the level of factors. If digit languages of algebraic numbers cannot be regular/sofic except in the periodic rational case, then arithmetic geometry is constraining formal-language complexity.

### 4. Information theory ↔ transcendence
The finite-state complexity theorem can be read as a lower bound on **finite-state description rate** for algebraic irrationals. This suggests future notions of “arithmetic information content” of expansions.

### 5. Ergodic theory ↔ certified computation
Minimal aperiodic subshifts such as Sturmian, substitutive, and coded systems become certified generators of transcendental constants once their digits are embedded as base-`b` expansions.

---

## Concrete subtheorems worth proving in Lean
These are excellent stepping stones with high reuse value.

```lean
theorem not_eventuallyPeriodic_of_mem_aperiodic_shift
    {b : ℕ} {X : Set (ℕ → Fin b)} {a : ℕ → Fin b}
    (hmem : a ∈ X) (haper : AperiodicShift X) :
    ¬ EventuallyPeriodic a
```

```lean
theorem factorComplexity_mono_under_shift_language_inclusion
    {b : ℕ} {a c : ℕ → Fin b}
    (hsub : ∀ n, factors a n ⊆ factors c n) :
    ∀ n, factorComplexity a n ≤ factorComplexity c n
```

```lean
theorem eventualLinear_of_bounded_complexity_increment
    {f : ℕ → ℕ}
    (hinc : ∃ M, ∀ n, f (n+1) - f n ≤ M) :
    ∃ C D, ∀ n, f n ≤ C * n + D
```

```lean
theorem finiteFollowerSets_implies_bounded_complexity_increment
    {b : ℕ} {X : Set (ℕ → Fin b)} :
    ...
```

```lean
theorem bounded_fsComplexity_implies_linear_factorComplexity
    {b : ℕ} {a : ℕ → Fin b} :
    ...
```

These lemmas modularize the project and minimize future `sorry`s.

---

## Why this would be revolutionary
If completed, this does more than formalize an isolated transcendence corollary. It establishes a **general theorem schema**:

- symbolic regularity
- automata compressibility
- low subword complexity

all become certified sufficient conditions for transcendence of digit-defined reals.

That opens an entire formal research program:
- transcendence from substitutive systems,
- transcendence from S-adic expansions,
- lower bounds on automata complexity of algebraic numbers,
- machine-checkable obstructions to algebraicity from formal-language properties.

This is not incremental. It is the beginning of a **formal arithmetic complexity theory of real numbers**.

---

## Application keywords
`transcendence theory`, `symbolic dynamics`, `sofic shifts`, `subword complexity`, `finite automata`, `finite-state compression`, `automatic sequences`, `Adamczewski–Bugeaud`, `Diophantine approximation`, `formal language theory`, `information complexity`, `Lean 4`, `Mathlib`

---

## Deliverables
1. Prove the strongest version of `eventuallyLinear_factorComplexity_of_sofic` you can.
2. Derive `transcendental_of_mem_minimal_aperiodic_sofic`.
3. If feasible, prove `fsComplexity_unbounded_of_algebraic_irrational`.
4. Minimize `sorry` by isolating finite combinatorial lemmas into reusable files.
5. Explicitly document which catalog theorem is used for the final transcendence step.

---

## FUTURE_DIRECTIONS.md requirement
Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable hypotheses**, each with:
- precise conjecture,
- why it might be true,
- exact formal test in Lean or computation,
- clear refutation criterion.

At least these three hypotheses should be included in sharpened form:

### Hypothesis A: Finite follower-set transcendence principle
**Conjecture.**
If the base-`b` digit sequence of an irrational real belongs to a shift with finitely many follower sets, then the real is transcendental.

**Test.**
Formalize `followerSet`; prove finite follower sets imply affine factor complexity; invoke the catalog transcendence theorem.

**Refutation.**
An algebraic irrational with digit expansion in a finite-follower-set shift.

### Hypothesis B: Unbounded finite-state complexity for algebraic irrationals
**Conjecture.**
For every algebraic irrational `x`, the function `N ↦ fsComplexity a N` of its base-`b` digits is unbounded.

**Test.**
Prove bounded `fsComplexity` implies linear factor complexity; combine with the transcendence criterion.

**Refutation.**
An algebraic irrational whose digit prefixes are uniformly generated by bounded-state automata.

### Hypothesis C: Linear lower bound on finite-state complexity
**Conjecture.**
There exists `c > 0` such that for every algebraic irrational `x`, infinitely many `N` satisfy
\[
fsComplexity(a,N) \ge cN.
\]

**Test.**
Empirically estimate `fsComplexity` for prefixes of `√2`, `∛2`, `φ`, etc.; seek a proof by strengthening bounded-complexity arguments to quantitative lower bounds.

**Refutation.**
A verified sublinear upper bound `fsComplexity(a,N) = o(N)` for an algebraic irrational.

### Hypothesis D: Substitutive transcendence extension
**Conjecture.**
Every irrational real whose base-`b` digits are generated by a primitive aperiodic substitution is transcendental.

**Test.**
Show primitive substitutive sequences have linear factor complexity in the existing framework; apply the same transcendence criterion.

**Refutation.**
An algebraic irrational with primitive substitutive digit expansion.

Be bold: the goal is to turn automata-theoretic regularity into a formal no-go theorem for algebraicity.

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
