## Assignment: Eigenvalue analysis

Mode: **prove**

Prove a genuinely new bridge theorem connecting tropical spectral theory, eventual periodicity in max-plus dynamics, and an entropy lower bound extracted from transient preperiod structure. This should not be a vague exploration: isolate a formal theorem that can be stated over finite matrices with concrete `Fin n → Fin n → ℝ` entries, build it on the catalog results, and drive toward a reusable formal framework for tropical Perron–Frobenius dynamics.

### Research Direction

A generic tropical matrix should not merely have a unique critical cycle: that uniqueness should force a rigid decomposition of orbit growth into

1. a single asymptotic linear mode governed by the tropical eigenvalue, and  
2. a finite transient search phase whose combinatorial branching admits an entropy certificate.

The breakthrough target is to **formalize a theorem schema saying that a strict cycle-gap hypothesis implies unique critical cycle selection and a positive lower bound on transient entropy before eventual periodicity**.

This opens a field-level bridge between:
- tropical linear algebra,
- symbolic dynamics / eventual periodicity,
- information theory,
- mixing-time style lower bounds,
- and complexity lower bounds for weighted circuit models.

### Mathematical Framing

For a tropical matrix `A : Matrix (Fin n) (Fin n) ℝ`, define the weight of a directed cycle as the sum of edge weights along the cycle, and its mean weight as weight divided by length. The tropical eigenvalue is the maximum cycle mean. A “generic” matrix should mean that there is a **unique** cycle attaining this maximum, with a strictly positive gap to all competing cycles.

The desired theorem is not just uniqueness of the eigenvalue in the abstract — you already have `tropical_eigenvalue_unique`. The new contribution is:

- package a concrete **strict cycle-gap condition** on finite matrices,
- show it implies **unique critical cycle** in a way usable for dynamics,
- then prove that if one studies iterates / path-optimization dynamics induced by `A`, the transient regime before periodic locking has nontrivial entropy bounded below using `tropical_entropy_search_bound` and `tropical_cycle_gap_mixing_lower_bound`.

### Precise Theorem Targets

You will likely need to introduce definitions first. Use concrete finite types and avoid abstract semiring generality until the core theorem is established.

#### Definition layer to add

Suggested definitions in Lean:

```lean
def cycleWeight {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    List (Fin n) → ℝ := ...

def cycleMean {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (c : List (Fin n)) : ℝ :=
  cycleWeight A c / c.length

def isCycle {n : ℕ} (c : List (Fin n)) : Prop := ...

def criticalCycle {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (c : List (Fin n)) : Prop :=
  isCycle c ∧ ∀ d, isCycle d → cycleMean A d ≤ cycleMean A c

def uniqueCriticalCycle {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃! c, criticalCycle A c

def cycleGap {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sSup {δ : ℝ | ∃ c, criticalCycle A c ∧
    ∀ d, isCycle d → d ≠ c → cycleMean A d ≤ cycleMean A c - δ}
```

You may prefer a more combinatorial finite-max definition over `Finset` rather than `sSup`; that is probably much easier in Lean. In fact, you should almost certainly define cycle gap via a finite set of canonical cycles (e.g. nodup nonempty cycles up to rotation if feasible, or simply a finite search space of bounded-length closed walks if that is easier to formalize first).

#### Main theorem A: strict cycle-gap implies unique critical cycle

```lean
theorem strict_cycle_gap_implies_uniqueCriticalCycle
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hgap : ∃ c, criticalCycle A c ∧
      ∃ ε > 0, ∀ d, isCycle d → d ≠ c →
        cycleMean A d ≤ cycleMean A c - ε) :
    uniqueCriticalCycle A
```

This theorem should be made to explicitly leverage the catalog theorem

- `tropical_eigenvalue_unique`

not as a replacement, but as a certified bridge from your concrete cycle-gap criterion to the already-verified abstract uniqueness statement.

#### Main theorem B: transient entropy lower bound from cycle gap

You will need a notion of transient search distribution. A practical formalization target is: given a finite set of candidate cycles or candidate path-prefixes surviving after `k` tropical optimization steps, define a probability distribution on survivors and prove that if at least two candidates remain before the critical cycle dominates, then entropy is positive; if the cycle gap controls elimination rate, derive a lower bound.

A realistic first strong theorem is:

```lean
theorem transient_entropy_positive_of_multiple_competitors
    {α : Type*} [Fintype α] [DecidableEq α]
    (p : StrictProbDist α)
    (hcard : 2 ≤ Fintype.card α) :
    0 < tropicalEntropy p
```

But that is too generic unless tied back to matrices. The real target should be a bridge theorem such as:

```lean
theorem strict_cycle_gap_yields_entropy_bound
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hgap : ∃ c, criticalCycle A c ∧
      ∃ ε > 0, ∀ d, isCycle d → d ≠ c →
        cycleMean A d ≤ cycleMean A c - ε)
    (htransient : ∃ p : StrictProbDist {d // isCycle d},
      2 ≤ Fintype.card {d // p d > 0}) :
    ∃ c > 0, c ≤ tropicalEntropy p
```

This may need adjustment to match the exact API of `StrictProbDist` and `tropical_entropy_search_bound`. If direct matrix-to-distribution formalization is too heavy, prove an intermediate theorem:

1. strict cycle-gap gives a finite elimination/mixing bound on noncritical cycles;
2. any pre-locking stage with at least two surviving candidates induces positive entropy;
3. combine with `tropical_entropy_search_bound` and `tropical_cycle_gap_mixing_lower_bound`.

#### Main theorem C: eventual dominance / periodicity certificate

A more ambitious and more original theorem is:

```lean
theorem unique_critical_cycle_eventual_locking
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (huniq : uniqueCriticalCycle A) :
    ∃ T : ℕ, ∀ t ≥ T, orbitSelector A t = criticalSelector A
```

Here `orbitSelector` should encode whichever finite combinatorial optimization process you define: maximizing paths of length `t`, maximizing closed walks, or selecting argmax states in `A^[t] ⊗ x`. The exact object is flexible, but it must be concrete and finite.

This theorem would be a major breakthrough because it converts tropical eigenvalue uniqueness into a **computable preperiodicity theorem**.

### Lean 4 Type Signature Guidance

Use signatures close to the following style, adapting to the actual APIs you create:

```lean
theorem strict_cycle_gap_implies_uniqueCriticalCycle
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hgap :
      ∃ c : List (Fin n), criticalCycle A c ∧
        ∃ ε : ℝ, 0 < ε ∧
          ∀ d : List (Fin n), isCycle d → d ≠ c →
            cycleMean A d ≤ cycleMean A c - ε) :
    uniqueCriticalCycle A := by
  ...
```

```lean
theorem transient_entropy_lower_bound_of_cycle_gap
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (p : StrictProbDist ι)
    (hsearch : 2 ≤ Fintype.card ι) :
    ∃ c : ℝ, 0 < c ∧ c ≤ tropicalEntropy p := by
  ...
```

```lean
theorem cycle_gap_mixing_entropy_bridge
    {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hgap : ...)
    (hmix : ...)
    (p : StrictProbDist α) :
    ∃ c : ℝ, 0 < c ∧ c ≤ tropicalEntropy p := by
  ...
```

If the exact constant from `tropical_entropy_search_bound` is available, specialize to that constant instead of existential `∃ c > 0`.

### Existing Verified Theorems to Build On

Use the catalog aggressively and explicitly:

1. `tropical_eigenvalue_unique`
   - file: `Tropical/FourierAnalysis/Core.lean`
   - Use it as the abstract uniqueness engine after you prove your strict cycle-gap criterion implies the hypotheses needed by this theorem.
   - If its hypotheses are abstract, write a translation lemma from finite cycle combinatorics into that abstract setup.

2. `tropical_entropy_search_bound`
   - file: `Tropical/InformationTheory/Advanced.lean`
   - Use it to certify a quantitative lower bound for entropy once you define a transient search distribution over surviving competitors.
   - The key move is to interpret the preperiod search over candidate cycles / path-prefixes as a finite probabilistic object.

3. `tropical_cycle_gap_mixing_lower_bound`
   - file: `Tropical/MixingTheory.lean`
   - This is the bridge from spectral gap to transient duration / mixing obstruction.
   - Your theorem should say: a positive cycle gap forces a controlled elimination process, hence a nontrivial transient window, hence entropy.

4. `tropical_and_bound`
   - file: `Tropical/Oracles/OracleApplicationsFrontier.lean`
   - Potentially useful for combining independent lower bounds: one from uniqueness/gap, one from entropy/mixing.
   - If it is a min-type or conjunction-style inequality, use it to package two constraints into one certified frontier theorem.

5. `tropical_circuit_lower_bound_transfer_generic`
   - file: `Tropical/WeightedBPSimulation.lean`
   - This is your route to computational complexity significance.
   - After proving the entropy bridge, show that matrices with large transient search complexity induce lower bounds for tropical circuit or weighted branching-program representations.

### Proof Strategy Architecture

#### Strategy A: Finite cycle enumeration + gap separation + uniqueness transfer
Most promising for Lean.

1. Define a finite search space of candidate cycles.
   - For an `n × n` matrix, every simple cycle has length at most `n`.
   - Encode cycles as lists over `Fin n` satisfying closure/nodup conditions.
   - Build a `Finset` of canonical cycles if feasible.

2. Prove strict gap implies unique maximizer of `cycleMean`.
   - This is a pure finite argmax theorem.
   - From `∃ ε > 0` separating one cycle from all others, derive uniqueness directly.

3. Transfer to tropical eigenvalue uniqueness.
   - Use `tropical_eigenvalue_unique` as the abstract spectral consequence of your concrete finite theorem.
   - This creates a reusable bridge lemma between combinatorial and abstract tropical spectral theories.

Why this is promising:
- It avoids deep dynamical formalization at first.
- It gives a robust theorem with immediate mathematical content.
- It establishes the exact genericity notion you need later.

#### Strategy B: Path-growth asymptotics via max-plus powers
Best for the eventual periodicity theorem.

1. Define weight of length-`t` paths and the maximal path weight from `i` to `j`.
   - Interpret `(A^t) i j` tropically as maximal path weight.

2. Use unique critical cycle to show asymptotic domination.
   - Any path spending asymptotically maximal average weight must shadow the unique critical cycle.
   - The strict cycle gap gives exponential/linear separation in score from competitors, depending on your normalization.

3. Deduce eventual locking / periodic selector stabilization.
   - For large `t`, the maximizing combinatorial structure is forced through the critical cycle.
   - This yields eventual periodicity and a finite transient length.

Why this matters:
- This is the real tropical Perron–Frobenius dynamical theorem.
- It transforms uniqueness from a static statement into a temporal one.

#### Strategy C: Entropy from transient candidate branching
Most speculative, but potentially the most revolutionary.

1. Define a transient candidate set `S_t` of cycles/path-prefixes not yet eliminated at time `t`.
2. Put a canonical probability distribution on `S_t`.
   - Uniform if necessary initially.
   - Or weighted by score deficits / search probabilities if supported by existing APIs.

3. Prove:
   - if `|S_t| ≥ 2`, entropy is positive;
   - if cycle-gap prevents immediate collapse, then such a stage exists or persists for bounded time;
   - apply `tropical_entropy_search_bound` and `tropical_cycle_gap_mixing_lower_bound`.

Why this is revolutionary:
- It interprets tropical transient dynamics as an information-theoretic object.
- That is not just spectral theory; it is a new language for tropical computation.

### Cross-Domain Connections

You must connect the theorem to at least one external domain in the formal writeup, ideally two.

#### 1. Symbolic dynamics / thermodynamic formalism
A unique critical cycle is a zero-temperature ground state. The transient phase is analogous to metastability and entropy production before freezing. This suggests future tropical analogues of:
- pressure,
- Gibbs measures,
- large deviations,
- zero-temperature limits.

#### 2. Markov mixing / spectral gap theory
Your cycle gap acts like a nonclassical spectral gap. `tropical_cycle_gap_mixing_lower_bound` should be leveraged to argue that tropical optimization dynamics possess a mixing/preperiod analogue. This is a bold bridge between max-plus linear algebra and probabilistic mixing.

#### 3. Complexity theory
Via `tropical_circuit_lower_bound_transfer_generic`, show that long transient search before periodic locking corresponds to irreducible computational complexity in tropical circuits / weighted branching programs. This is the kind of theorem that could open a tropical complexity theory of spectral dynamics.

#### 4. Information theory
Entropy of unresolved critical structure before asymptotic locking is a tropical analogue of search uncertainty. This is not metaphorical if formalized with `StrictProbDist`: it becomes a certified lower bound on information required to identify asymptotic behavior.

### Application Keywords

tropical eigenvalue, max-plus algebra, unique critical cycle, cycle mean gap, eventual periodicity, transient entropy, tropical Perron–Frobenius, symbolic dynamics, thermodynamic formalism, metastability, mixing lower bounds, tropical information theory, weighted branching programs, tropical circuit complexity, spectral gap, path optimization

### Concrete Deliverables

1. A Lean file introducing the finite cycle framework for `Matrix (Fin n) (Fin n) ℝ`.
2. At least one fully proved theorem of the form:
   - strict cycle-gap ⇒ unique critical cycle, or
   - unique critical cycle ⇒ eventual locking, or
   - transient competitor multiplicity ⇒ positive entropy lower bound.
3. At least one bridge lemma explicitly invoking a catalog theorem.
4. Minimize `sorry`; if some definitions are heavy, isolate them cleanly and prove the strongest theorem available around them.

### If direct proof gets stuck

- Replace full cycle enumeration by simple closed walks of bounded length.
- Replace exact entropy formula by existential positivity from cardinality ≥ 2.
- Replace eventual periodicity of full matrix powers by stabilization of an argmax selector or dominant cycle family.
- Prove a weaker but clean theorem first:
  `strict_cycle_gap_implies_uniqueCriticalCycle`,
  then layer the entropy theorem afterward.

### Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with 3–5 specific next steps, each including:
- a precise theorem statement,
- likely Lean definitions needed,
- 2 proof strategies,
- and one cross-domain connection.

The future directions should be breakthrough-level, such as:
1. tropical zero-temperature variational principle,
2. entropy-rate formula for eventual periodic max-plus systems,
3. complexity lower bounds from transient spectral ambiguity,
4. tropical analogues of Ruelle–Perron–Frobenius,
5. certified algorithms for detecting unique critical cycles with proof-producing Lean output.

This cycle is a chance to found a new theory: **tropical spectral dynamics with information-theoretic transients**. Build the definitions so the next cycle can attack the full entropy-periodicity-complexity triangle.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Tropical
Research mode: prove
