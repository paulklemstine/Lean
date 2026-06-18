## Assignment: Ramsey Theory Beyond Enumeration — Structural Bounds, Probabilistic Certificates, and High-Dimensional Combinatorial Lines

You are not being asked to merely re-prove famous small Ramsey numbers by brute force. You are being asked to formalize the *architecture* of finite Ramsey theory: recursive upper bounds, extremal constructions, probabilistic lower bounds, and the first genuinely high-dimensional phenomenon where “monochromatic clique” becomes “combinatorial line.” The goal is to turn Lean into a laboratory for structural extremal combinatorics, not a museum of isolated finite checks.

The breakthrough target is this: create a reusable Lean 4 framework for 2-color graph Ramsey theory and word-space line Ramsey theory, then push it far enough to certify nontrivial exact values, asymptotic-style bounds, and a probabilistic construction. If successful, this opens a formal path toward extremal combinatorics, additive combinatorics, communication complexity, and coding-theoretic applications.

## Mode
**prove**

## Core Research Vision

The decisive theorem is not “6 works for R(3,3)” by enumeration. The decisive theorem is that **Ramsey upper bounds emerge from a recursive neighborhood dichotomy**, and **Ramsey lower bounds emerge from expectation/averaging arguments over random colorings**, and **Hales–Jewett emerges as the word-space analogue of unavoidable monochromatic structure**.

This is the point where formalized combinatorics becomes scientifically generative:
- graph colorings ↔ Boolean functions and circuit complexity,
- probabilistic method ↔ pseudorandomness and derandomization,
- Hales–Jewett ↔ coding theory, density increment methods, and theoretical CS,
- exact small Ramsey values ↔ SAT certificates and extremal search,
- Erdős–Szekeres recursion ↔ binomial entropy bounds and asymptotic combinatorics.

## Precise Formalization Targets

You should define a new structure for 2-colored complete graphs and a new notion of monochromatic witness that is reusable.

### Novel definitions required
Introduce at least one genuinely new structure, for example:

```lean
structure TwoColoring (V : Type*) [Fintype V] [DecidableEq V] where
  color : Sym2 V → Bool
```

or a more graph-theoretic version:

```lean
structure RamseyColoring (V : Type*) [Fintype V] [DecidableEq V] where
  red : SimpleGraph V
  complete_partition :
    ∀ ⦃u v : V⦄, u ≠ v → (red.Adj u v) ⊕ (¬ red.Adj u v)
```

and define monochromatic clique predicates:

```lean
def HasRedClique (C : RamseyColoring V) (k : ℕ) : Prop := ...
def HasBlueClique (C : RamseyColoring V) (k : ℕ) : Prop := ...
def RamseyWitness (C : RamseyColoring V) (s t : ℕ) : Prop :=
  HasRedClique C s ∨ HasBlueClique C t
```

For Hales–Jewett, define a combinatorial line in `Fin n → Fin k` via wildcard coordinates:

```lean
structure CombinatorialLine (n k : ℕ) where
  active : Fin n → Bool
  nontrivial : ∃ i, active i = true
  base : Fin n → Fin k
  point : Fin k → (Fin n → Fin k)
  line_axiom : ...
```

This is a real mathematical object, not a convenience wrapper.

---

## Theorem Cluster A: Recursive Ramsey Bound and Erdős–Szekeres Binomial Bound

### Theorem A1: Fundamental recursive Ramsey inequality
Prove the standard recursion in a reusable finite graph framework:

**Mathematical statement**  
For all integers `s,t ≥ 2`,
\[
R(s,t) \le R(s-1,t) + R(s,t-1).
\]

### Suggested Lean 4 signature
```lean
theorem ramsey_recursion
    (R : ℕ → ℕ → ℕ)
    (hRspec : ∀ s t, RamseySpec R s t)
    {s t : ℕ} (hs : 2 ≤ s) (ht : 2 ≤ t) :
    R s t ≤ R (s - 1) t + R s (t - 1) := ...
```

If you instead define Ramsey number directly as a least natural satisfying a predicate, use:

```lean
theorem ramseyNumber_recursion
    {s t : ℕ} (hs : 2 ≤ s) (ht : 2 ≤ t) :
    ramseyNumber s t ≤ ramseyNumber (s - 1) t + ramseyNumber s (t - 1) := ...
```

### Why this matters
This is the engine behind classical finite Ramsey theory. Once formalized correctly, every upper bound becomes a corollary of a single neighborhood-splitting argument. This shifts the project from isolated exact values to a theorem-generating machine.

### Proof strategy options
1. **Neighborhood dichotomy strategy (most promising)**  
   - Fix a vertex `v` in a coloring on `R(s-1,t)+R(s,t-1)` vertices.  
   - Partition the remaining vertices into red-neighbors and blue-neighbors of `v`.  
   - By pigeonhole/cardinality, one side is large enough.  
   - Apply the inductive Ramsey property on that side and adjoin `v` if needed.  
   This is the canonical proof and aligns best with Lean’s finite-set/cardinality machinery.

2. **Complement graph strategy**  
   - Encode blue edges as the complement of red edges in a complete graph.  
   - Reduce to a statement about cliques in a graph or its complement.  
   - Use graph complement lemmas to transport clique conditions.  
   Elegant if Mathlib’s `SimpleGraph` complement API is strong enough.

3. **Finite set recursion strategy**  
   - Formulate everything over `Fin n`, prove the recursive bound by explicit subset decomposition.  
   - This is lower-level but may avoid abstraction overhead if graph APIs are awkward.

---

### Theorem A2: Erdős–Szekeres upper bound
**Mathematical statement**  
For all `s,t ≥ 2`,
\[
R(s,t) \le \binom{s+t-2}{s-1}.
\]

### Suggested Lean 4 signature
```lean
theorem ramsey_erdos_szekeres_bound
    {s t : ℕ} (hs : 2 ≤ s) (ht : 2 ≤ t) :
    ramseyNumber s t ≤ Nat.choose (s + t - 2) (s - 1) := ...
```

### Why this is a breakthrough
This is the first nontrivial closed-form global upper bound. Formalizing it means Lean can certify a genuine asymptotic combinatorial argument, not just finite cases. It also creates infrastructure for entropy bounds and asymptotic estimates later.

### Proof strategy options
1. **Induction using Pascal’s identity (most promising)**  
   - Base cases `R(1,t)=1`, `R(s,1)=1` or adapted `≥2` formulation.  
   - Combine `ramseyNumber_recursion` with
     \[
     \binom{s+t-2}{s-1}=\binom{s+t-3}{s-2}+\binom{s+t-3}{s-1}.
     \]
   - Finish by induction on `s+t`.  
   This is the cleanest structural proof.

2. **Strong induction on pair `(s,t)`**  
   - Use lexicographic or antidiagonal induction.  
   - Invoke recursion and the binomial recurrence as arithmetic lemmas.

3. **Lattice path interpretation**  
   - Interpret the bound combinatorially via monotone paths and recursively encode obstructions.  
   Conceptually rich, but likely too heavy for first implementation.

---

## Theorem Cluster B: Exact Small Ramsey Values Without Trivial Enumeration

You should still target exact values, but only through structural decomposition plus a compact finite certificate where necessary.

### Theorem B1: Exact value \(R(3,3)=6\)
**Mathematical statement**
\[
R(3,3)=6.
\]

### Suggested Lean 4 signature
```lean
theorem ramsey_33 : ramseyNumber 3 3 = 6 := ...
```

### Expected proof architecture
- Upper bound `≤ 6` from Theorem A2 or direct recursion.
- Lower bound `> 5` via explicit construction of a 2-coloring of `K₅` with no monochromatic triangle, e.g. the 5-cycle coloring.

### Proof strategy options
1. **Cycle construction + recursive upper bound (most promising)**  
   - Define a coloring on `Fin 5` where red edges are cycle edges and blue edges are complementary cycle edges.  
   - Prove no red triangle and no blue triangle by structural argument on cyclic adjacency, not brute-force enumeration of all triangles.  
   - Combine with `≤ 6`.

2. **Group-action construction**  
   - Model `K₅` on `Z/5Z`; color by difference set `{±1}` red, `{±2}` blue.  
   - Use modular arithmetic to exclude monochromatic triangles.  
   This is more elegant and scales better conceptually.

3. **Finite certificate extraction**  
   - Use an explicit adjacency matrix and prove triangle-freeness via contradiction on modular distances.  
   Acceptable only if the proof is structural, not `native_decide`.

---

### Theorem B2: Exact value \(R(3,4)=9\)
**Mathematical statement**
\[
R(3,4)=9.
\]

### Suggested Lean 4 signature
```lean
theorem ramsey_34 : ramseyNumber 3 4 = 9 := ...
```

### Why it matters
This is the first exact value where purely conceptual recursion does not immediately settle both directions. A formal proof here demonstrates that Lean can integrate structural reasoning with explicit extremal construction.

### Proof strategy options
1. **Upper bound from recursion + exact lower-bound certificate (most promising)**  
   - Upper bound via recursion from smaller values.  
   - Lower bound via explicit coloring of `K₈` with no red triangle and no blue `K₄`.  
   - Use symmetry/group structure to compress the proof.

2. **Paley/circulant-style construction**  
   - Work on `Fin 8` or a cyclic model with difference classes.  
   - Prove clique exclusions by modular constraints.  
   This is the right balance between explicitness and theory.

3. **SAT-backed certificate formalization**  
   - External search finds a certificate; Lean verifies the graph avoids forbidden subgraphs.  
   This is acceptable if verification is theorem-driven and reusable.

---

### Theorem B3: Exact value \(R(4,4)=18\)
**Mathematical statement**
\[
R(4,4)=18.
\]

### Suggested Lean 4 signature
```lean
theorem ramsey_44 : ramseyNumber 4 4 = 18 := ...
```

### Strategic warning
This is ambitious. The upper bound is classical but not trivial; the lower bound requires a construction on 17 vertices with no monochromatic `K₄`. If full formalization is too large, isolate the structural upper bound and a verified certificate pipeline for the lower bound.

### Proof strategy options
1. **Recursive upper bound + imported certificate for lower bound (most promising)**  
   - Derive `≤ 18` from recursion and prior exact values.  
   - Verify a known 17-vertex coloring certificate.  
   - Build a general theorem: “a verified coloring avoiding red `K_s` and blue `K_t` yields `R(s,t) > n`.”  
   This gives lasting infrastructure.

2. **Symmetric/circulant construction verification**  
   - If a highly symmetric 17-vertex construction is available, formalize its clique-avoidance structurally.  
   Harder, but mathematically cleaner.

3. **Certificate abstraction layer**  
   - Define a compact data format for colorings and a verified checker for forbidden monochromatic cliques.  
   This turns one theorem into a platform.

---

## Theorem Cluster C: Probabilistic Method Lower Bound

This is where the project becomes genuinely field-opening.

### Theorem C1: First-moment Ramsey lower bound
**Mathematical statement**  
For every `k ≥ 2`, if
\[
\binom{n}{k} 2^{1-\binom{k}{2}} < 1,
\]
then there exists a 2-coloring of `K_n` with no monochromatic `K_k`. Hence
\[
R(k,k) > n.
\]

### Suggested Lean 4 signature
```lean
theorem ramsey_diagonal_lower_bound_of_expectation
    {n k : ℕ} (hk : 2 ≤ k)
    (h :
      (Nat.choose n k : ℚ) *
        (2 : ℚ) ^ (1 - (Nat.choose k 2 : ℤ).toNat) < 1) :
    ramseyNumber k k > n := ...
```

You may need a cleaner real-valued formulation:

```lean
theorem exists_coloring_no_mono_clique_of_first_moment
    {n k : ℕ} (hk : 2 ≤ k)
    (h :
      (Nat.choose n k : ℝ) * (2 : ℝ) ^ (1 - Nat.choose k 2) < 1) :
    ∃ C : RamseyColoring (Fin n),
      ¬ HasRedClique C k ∧ ¬ HasBlueClique C k := ...
```

### Why this is revolutionary
This is the probabilistic method in Lean: existence without construction. Once formalized, it opens the door to random graphs, pseudorandomness, threshold phenomena, coding lower bounds, and complexity-theoretic counting arguments.

### Proof strategy options
1. **Expectation + union bound (most promising)**  
   - Put the uniform distribution on 2-colorings of `K_n`.  
   - Define the random variable counting monochromatic `K_k`.  
   - Show expected count is
     \[
     \binom{n}{k}2^{1-\binom{k}{2}}.
     \]
   - If expectation is `< 1`, some coloring has count `0`.  
   This is the clean conceptual route.

2. **Finite averaging without full probability theory**  
   - Average the number of monochromatic `K_k` over the finite set of all colorings.  
   - Use a counting lemma rather than measure-theoretic expectation.  
   This may be much easier in Lean and is likely the best practical implementation.

3. **Double counting incidence pairs**  
   - Count pairs `(coloring, clique)` where the clique is monochromatic.  
   - Divide by number of colorings.  
   This is equivalent to (2), extremely formalization-friendly.

### Cross-catalog leverage
Use the spirit of:
- `density_lower_bound_nat` as a template for finite counting inequalities and lower-bound logic,
- `circuit_lower_bound_from_obstruction` and `depth_lower_bound_from_degree` as conceptual analogues: global lower bounds emerging from local obstruction counts.  
The connection is not superficial: Ramsey lower bounds and circuit lower bounds both derive impossibility from the proliferation of forbidden patterns.

---

## Theorem Cluster D: Hales–Jewett as High-Dimensional Ramsey Theory

Do not attempt the full theorem in maximal generality if it derails the project. But do formalize the *objects* and prove a meaningful nontrivial instance or dimension-reduction lemma.

### Theorem D1: Existence of a monochromatic combinatorial line in a low-dimensional case
A realistic initial target:

**Mathematical statement**  
Every 2-coloring of `[2]^2` or `[2]^3` contains a monochromatic combinatorial line.

Suggested stronger target:
\[
HJ(2,2)=2
\]
in an appropriate formulation.

### Suggested Lean 4 signature
```lean
theorem hales_jewett_2_2 :
    ∀ c : (Fin 2 → Fin 2) → Bool,
      ∃ L : CombinatorialLine 2 2,
        (∀ a b : Fin 2, c (L.point a) = c (L.point b)) := ...
```

Or for dimension 3 if that is the correct nontrivial first case under your definition.

### Theorem D2: Line-lifting / dimension monotonicity
**Mathematical statement**  
If every `r`-coloring of `[k]^n` has a monochromatic combinatorial line, then so does every `r`-coloring of `[k]^(n+1)`.

### Suggested Lean 4 signature
```lean
theorem hales_jewett_monotone_dim
    {k r n : ℕ} :
    HJProperty k r n → HJProperty k r (n + 1) := ...
```

### Why this matters
Hales–Jewett is the “Ramsey theorem of words.” Formalizing even its first layers opens a route toward van der Waerden, Szemerédi-type regularity ideas, coding theory, and communication protocols over Hamming cubes.

### Proof strategy options
1. **Direct line analysis in low dimension (most promising for first theorem)**  
   - Explicitly classify wildcard patterns.  
   - Use symmetry to avoid full enumeration.  
   - Prove every 2-coloring forces a monochromatic line.

2. **Projection/lifting strategy for monotonicity**  
   - Embed `[k]^n` as a coordinate slice of `[k]^(n+1)`.  
   - Pull back a coloring and lift a line.  
   This is elegant and highly reusable.

3. **Affine-cube viewpoint**  
   - Regard combinatorial lines as 1-dimensional affine subcubes in a discrete cube.  
   This gives later access to coding theory and Fourier-analytic perspectives.

---

## Required Cross-Domain Connection Theorems

You must include at least one theorem explicitly linking Ramsey theory to another domain.

### Option 1: Coding theory connection
Interpret a 2-coloring of `K_n` as a bit vector over edges; forbidden monochromatic cliques become forbidden local patterns. Then prove a basic Hamming-distance or counting theorem about the space of Ramsey-good colorings.

Example target:
```lean
theorem ramsey_coloring_hamming_separation
    {n k : ℕ} :
    ...
```

This connects directly to `rs_distance_lower_bound` by analogy: extremal colorings behave like codes with forbidden local degeneracies.

### Option 2: Circuit complexity connection
Use the existing catalog’s lower-bound theorems as inspiration and prove that detecting a monochromatic `K_k` requires nontrivial combinatorial depth under a simplified model, or at least formalize a reduction from clique-detection in a coloring encoding to a Boolean pattern-detection problem.

Application keywords: **circuit lower bounds, monotone complexity, property testing**.

### Option 3: Statistical physics connection
View a 2-coloring as a spin configuration on edges of a complete graph, and monochromatic cliques as low-energy local structures. Prove a theorem translating “no monochromatic triangle” into a local frustration condition. Even a clean formal equivalence would be valuable.

Application keywords: **Ising models, frustrated systems, energy landscapes**.

---

## Conjecture with Testable Prediction

You must include at least one falsifiable conjecture with a computational disproof criterion.

### Recommended conjecture
Define `RamseyGood n k` to be the number of 2-colorings of `K_n` with no monochromatic `K_k`.

**Conjecture.**
For fixed `k = 3`, the sequence
\[
\frac{\log(\text{RamseyGood}(n,3))}{\binom{n}{2}}
\]
is strictly decreasing for `3 ≤ n ≤ 10`.

### Lean-style declaration
```lean
def RamseyGoodCount (n k : ℕ) : ℕ := ...

conjecture ramseyGood_entropy_decreases :
  ∀ n, 3 ≤ n → n ≤ 9 →
    Real.log (RamseyGoodCount n 3) / (Nat.choose n 2) >
    Real.log (RamseyGoodCount (n+1) 3) / (Nat.choose (n+1) 2) := ...
```

### Computational test
Enumerate or SAT-count Ramsey-good colorings for `n ≤ 10`; one counterexample disproves the conjecture.

Alternative conjecture:
- random greedy constructions achieve asymptotically better lower-bound certificates than cyclic constructions for `R(4,4)`,
- extremal `(3,4)`-avoiding colorings on 8 vertices are unique up to isomorphism.

Both are falsifiable by exhaustive search / isomorphism testing.

---

## Proof Tactics Requirements

Your file must contain at least 3 substantial theorems using nontrivial tactics such as:
- induction on `s+t` or dimension `n`,
- `rcases` on clique witnesses/subset decompositions,
- `by_contra` for exclusion of monochromatic configurations,
- `field_simp` or arithmetic normalization in expectation/counting formulas,
- multi-step `calc` chains using binomial identities and cardinality inequalities.

Do **not** discharge exact Ramsey values by `native_decide` over all colorings unless the proof’s mathematical substance lies elsewhere and the decision procedure is only a tiny verification endpoint.

---

## Concrete Deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - the new structures/definitions,
   - at least 3 deep theorems,
   - at least one cross-domain theorem,
   - at least one probabilistic/counting lower bound,
   - minimized `sorry`.

2. **FUTURE_DIRECTIONS.md** with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with:
   - precise statement,
   - why it might be true,
   - explicit computational test that could disprove it.

3. **RESEARCH_PAPER.md** as a **standalone scientific document**:
   - motivation,
   - formal statements,
   - proof ideas,
   - computational experiments,
   - significance,
   - next questions.
   A reader with no code access must still understand the discovery.

4. **ARTICLE.md** in **Scientific American style**:
   - vivid and accessible,
   - explains why unavoidable patterns in large systems matter,
   - connects Ramsey theory to networks, error-correcting codes, and randomness.

5. **A verified algorithm or computational method**:
   - e.g. a certified checker for monochromatic clique avoidance,
   - a finite averaging engine for probabilistic lower bounds,
   - or a combinatorial-line detector for word colorings.

6. **demo.py**:
   - interactive visualization of 2-colorings of `K_n`,
   - clique detection,
   - certificate verification for lower-bound constructions,
   - optionally Hales–Jewett line visualization in `{0,1}^n`.

---

## Application Keywords
**Ramsey theory, extremal combinatorics, probabilistic method, finite graph colorings, Hales–Jewett theorem, coding theory, pseudorandomness, SAT certificates, combinatorial lines, circuit complexity, statistical physics, monochromatic structures, derandomization, entropy bounds, property testing**

---

## Final Strategic Priority

If forced to choose, prioritize in this order:

1. **A robust formal definition framework for Ramsey colorings and monochromatic cliques**  
2. **Recursive bound + Erdős–Szekeres theorem**  
3. **Probabilistic first-moment lower bound**  
4. **Exact value \(R(3,3)=6\)** via structural construction  
5. **One nontrivial Hales–Jewett theorem or monotonicity lemma**  
6. **Certificate infrastructure for \(R(3,4)\) and \(R(4,4)\)**

That ordering creates a platform. Exact values alone are dead ends; a reusable formal extremal-combinatorics engine is a new research frontier.

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
