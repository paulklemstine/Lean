Soli Deo Gloria

## Assignment: Direction 2: Moment Method Attack on the Random Cayley Expander Conjecture

**Mode:** `prove`

Build a formal bridge from combinatorial closed-walk counting on Cayley graphs of `S_n` to low-order spectral moment bounds for random 2-generator Cayley graphs. The target is not a toy lemma: it is the first certified moment-method scaffold for the Random Cayley Expander Conjecture.

You should prove genuinely new, non-trivial theorems, minimize `sorry`, and use the catalog as a launchpad rather than a cage.

## Core Vision

Let `G = S_n`, let `S = {σ, σ⁻¹, τ, τ⁻¹}`, and let `A` be the unnormalized or normalized adjacency operator of the Cayley graph `Cay(G,S)`. The quantity
\[
\frac{1}{|G|}\operatorname{tr}(A^{2k})
\]
is the `2k`-th spectral moment of the graph. If we can formally identify it with a word-counting problem and then prove nontrivial upper bounds for classes of reduced words, we create the first Lean-certified entry point from finite group combinatorics into asymptotic expander heuristics.

This is a breakthrough because the moment method is the universal language of spectral control: random matrix theory, quantum chaos, high-dimensional expansion, and pseudorandomness all begin by controlling traces of powers. For random Cayley graphs on `S_n`, this is the missing combinatorial skeleton.

## Precise Theorem Targets

You must formalize at least one new mathematical structure and prove at least 3 substantial theorems. The following are the primary targets.

### New definition: word evaluation and closed-walk moment kernel

Define a word alphabet for a symmetric generating multiset with two generators and formal inverses, together with an evaluation map into a group.

Suggested Lean objects:

```lean
inductive GenLetter
| sigma | sigmaInv | tau | tauInv
deriving DecidableEq, Repr

def GenLetter.inv : GenLetter → GenLetter
| GenLetter.sigma => GenLetter.sigmaInv
| GenLetter.sigmaInv => GenLetter.sigma
| GenLetter.tau => GenLetter.tauInv
| GenLetter.tauInv => GenLetter.tau

def evalWord {G : Type*} [Group G] (σ τ : G) : List GenLetter → G
| [] => 1
| a :: w =>
    (match a with
    | GenLetter.sigma => σ
    | GenLetter.sigmaInv => σ⁻¹
    | GenLetter.tau => τ
    | GenLetter.tauInv => τ⁻¹) * evalWord σ τ w
```

Then define the closed-word count:
```lean
def closedWordCount {G : Type*} [Fintype G] [Group G] (σ τ : G) (m : ℕ) : ℕ :=
  ((List.finRange (4^m)).filter fun i =>
    evalWord σ τ (decodeWord m i) = 1).length
```

If `decodeWord` is cumbersome, use `Finset.univ` over words of length `m` encoded as `Fin m → GenLetter`.

A more elegant structure would be:

```lean
structure TwoGenCayleyData (G : Type*) [Group G] where
  sigma : G
  tau   : G
```

and then define the associated symmetric step function and word evaluation. This is a good place to introduce a genuinely new concept, e.g. `ReducedTwoGenWord`, `BacktrackFreeWord`, or `MomentKernel`.

---

### Theorem 1: trace–closed-walk identity

For a finite group and symmetric generating multiset, the trace of the adjacency operator power equals the number of closed walks.

Mathematical statement:
\[
\operatorname{tr}(A^{m}) = |G| \cdot N_m(e),
\]
where `N_m(e)` is the number of length-`m` words in the generators evaluating to the identity, with normalization adjusted according to whether `A` is normalized.

For normalized adjacency with degree `d = |S|`:
\[
\frac{1}{|G|}\operatorname{tr}(A^m)=\frac{1}{d^m}\#\{w \in S^m : w=e\}.
\]

Suggested Lean 4 theorem signature:

```lean
theorem normalized_trace_pow_eq_closedWordCount
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    ((Matrix.trace (AdjacencyMatrixNormalized σ τ ^ m) : ℚ))
      = (Fintype.card G : ℚ) *
        (closedWordCount σ τ m : ℚ) / (4 : ℚ)^m
```

If a matrix-valued adjacency operator is too heavy, prove the equivalent operator-on-functions formulation first, then derive the trace identity for the finite-dimensional endomorphism. You may also work over `ℝ` instead of `ℚ` if matrix powers are smoother in Mathlib.

This theorem should not be a one-line cardinality rewrite. It should use multi-step `calc`, extensionality on matrix entries, and a combinatorial decomposition of paths.

---

### Theorem 2: odd moments vanish under symmetry

Because the generating multiset is inverse-stable and contains no identity step unless forced by a relation, odd spectral moments satisfy a symmetry law. At minimum prove a parity formulation for the walk count under a suitable involution on words, or prove a cancellation statement for centered adjacency.

A concrete version:

```lean
theorem closed_walk_count_conj_invariant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m =
    closedWordCount σ⁻¹ τ⁻¹ m
```

Better, if you define centered adjacency `A - Π` where `Π` is projection to constants, prove a trace identity for centered moments:
```lean
theorem centered_trace_pow_eq_nontrivial_closedWordCount
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (m : ℕ) :
    Matrix.trace ((AdjacencyMatrixNormalized σ τ - averagingProjection G) ^ m)
      = ...
```

This is the representation-theoretic object that actually measures expansion. Even a partial theorem here is field-opening.

---

### Theorem 3: reduced-word upper bound / no-immediate-backtracking count

Introduce a new notion of reduced or backtrack-free word and prove an exact counting theorem:
\[
\#\{\text{backtrack-free words of length } m\} = 4 \cdot 3^{m-1}
\quad (m \ge 1).
\]

Suggested Lean theorem:

```lean
def BacktrackFree : List GenLetter → Prop
| [] => True
| [a] => True
| a :: b :: w => (b ≠ GenLetter.inv a) ∧ BacktrackFree (b :: w)

theorem card_backtrackFree_words_length
    (m : ℕ) (hm : 1 ≤ m) :
    Fintype.card {w : Fin m → GenLetter // BacktrackFree (List.ofFn w)} = 4 * 3^(m-1)
```

This looks elementary, but if done correctly it is the combinatorial backbone of the moment method: it isolates the tree-like contribution from relation-driven returns. Prove it by induction, with explicit decomposition on the first letter and recursive extension choices. This theorem must use genuine proof tactics: induction, `rcases`, `calc`.

---

### Theorem 4: closed words are generated by relation words

Build on `Pythagorean/CayleyExpander/Connectivity.lean`, especially `word_in_generators_of_mem_closure`, to show that every closed walk corresponds to a relation word in the subgroup generated by `σ,τ`.

A precise theorem direction:

```lean
theorem evalWord_eq_one_iff_relation_in_closure
    {n : ℕ} (σ τ : Equiv.Perm (Fin n)) (w : List GenLetter) :
    evalWord σ τ w = 1 ↔
    -- formal relation statement in the subgroup closure of {σ, τ}
    ...
```

This should explicitly connect the combinatorics of words to subgroup generation and closure membership. It is the theorem that turns “walk counting” into “group law counting”.

---

### Theorem 5: low-moment exact formulas for `m = 2` and `m = 4`

Do not jump immediately to asymptotics. First certify exact formulas that already reveal the random-expander heuristic.

Examples:
- For length 2, the only universal closed words are immediate cancellations, so `closedWordCount σ τ 2 ≥ 4`, with equality under non-degeneracy assumptions.
- For length 4, classify closed words into cancellation patterns and genuine length-4 relations.

Possible theorem signature:

```lean
theorem closedWordCount_two
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    closedWordCount σ τ 2 = 4 + relationCorrection₂ σ τ
```

and similarly for 4:
```lean
theorem closedWordCount_four_decomposition
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) :
    closedWordCount σ τ 4 =
      treeLikeContribution₄ + relationCorrection₄ σ τ
```

This decomposition is the seed of the moment method: universal Catalan/tree-like terms plus relation corrections. If you can formalize even a weak but exact version, you have created a reusable infrastructure for future asymptotic work.

## Lean 4 Type Signatures to Aim For

You do not need to use exactly these names, but the formal targets should be close in strength and precision.

```lean
theorem trace_pow_eq_closed_walks
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSsymm : ∀ s ∈ S, s⁻¹ ∈ S) (m : ℕ) :
    Matrix.trace ((cayleyAdjMatrix S) ^ m)
      = ∑ g : G, closedWalksFromTo S m g g
```

```lean
theorem normalized_trace_pow_twoGen
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (σ τ : G) (k : ℕ) :
    Matrix.trace ((AdjacencyMatrixNormalized σ τ) ^ (2*k))
      = (Fintype.card G : ℚ) *
        (closedWordCount σ τ (2*k) : ℚ) / (4 : ℚ)^(2*k)
```

```lean
theorem backtrackFree_count
    (m : ℕ) (hm : 1 ≤ m) :
    Fintype.card {w : Fin m → GenLetter // BacktrackFree (List.ofFn w)}
      = 4 * 3^(m-1)
```

```lean
theorem closedWordCount_le_allWords
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (σ τ : G) (m : ℕ) :
    closedWordCount σ τ m ≤ 4^m
```

```lean
theorem closedWordCount_eq_relationWords
    {n : ℕ} (σ τ : Equiv.Perm (Fin n)) (m : ℕ) :
    closedWordCount σ τ m =
      Fintype.card {w : Fin m → GenLetter // evalWord σ τ (List.ofFn w) = 1}
```

The last theorem may seem tautological if you define it that way; if so, strengthen it into a decomposition theorem by reduced-word type or cancellation class.

## Proof Strategy Architecture

You must include 2–3 viable proof routes in the development and pursue the most promising one.

### Strategy A: finite-dimensional operator combinatorics
1. Define the Cayley adjacency matrix on `G` by `A g h = 1` iff `h = gs` for some `s ∈ S`, normalized by `|S|`.
2. Prove by induction on `m` that `(A^m) g h` counts length-`m` walks from `g` to `h`, divided by `|S|^m` in the normalized case.
3. Sum diagonal entries to obtain the trace identity; use group translation invariance to show all diagonal entries are equal, reducing the trace to `|G|` times the closed walk count at identity.

**Why this is promising:** It is robust, elementary, and avoids requiring deep character theory before the combinatorial skeleton exists.

### Strategy B: convolution algebra / group algebra
1. Define the probability measure
   \[
   \mu = \tfrac14(\delta_\sigma+\delta_{\sigma^{-1}}+\delta_\tau+\delta_{\tau^{-1}})
   \]
   on `G`.
2. Identify `A` with convolution by `μ` on functions `G → ℝ`.
3. Show
   \[
   \frac1{|G|}\operatorname{tr}(A^m)=\mu^{*m}(e),
   \]
   then identify `\mu^{*m}(e)` with normalized closed-word count.

**Why this is revolutionary:** This is the exact language of random walks, harmonic analysis, and quantum channels. It opens the door to spectral methods, mixing bounds, and noncommutative probability.

### Strategy C: representation-theoretic decomposition
1. Use the regular representation decomposition of `G`.
2. Express the trace as a sum over irreducibles:
   \[
   \operatorname{tr}(A^m)=\sum_{\rho \in \widehat G} (\dim \rho)\,\operatorname{tr}\!\left(\widehat{\mu}(\rho)^m\right).
   \]
3. Specialize to `G = S_n` and connect moment bounds to character sums of random permutations.

**Why this is the endgame:** This is the path toward asymptotic spectral gap. But it depends on first formalizing Strategy A or B. Treat Strategy C as the bridge to future work unless Mathlib support is already strong enough.

## Most Promising Route

Start with **Strategy A**, then repackage the result in the language of **Strategy B**. Strategy C should appear as a theorem statement, framework, or partially formalized corollary, even if the full asymptotic character bounds remain conjectural. The combinatorial trace identity is the indispensable theorem; without it, there is no moment method.

## Cross-Domain Connections

This project must explicitly connect to at least one different domain.

### 1. Random matrix theory
Spectral moments are the universal observables of random operators. Your trace identity is a noncommutative analogue of Wigner-moment counting, with relation words replacing pairings. This is not metaphorical: the same combinatorial architecture underlies semicircle laws, free probability, and expander eigenvalue control.

### 2. Quantum information theory
The normalized adjacency operator is a bistochastic channel on functions over `G`; centered powers measure decay of nontrivial modes exactly as spectral gaps control mixing of quantum channels. A theorem identifying trace moments with return probabilities is formally parallel to purity/moment calculations for random quantum circuits.

### 3. Statistical mechanics
Closed walks are partition-function terms for lattice path ensembles on nonabelian configuration spaces. Reduced-word counting is the tree-level contribution; relation words are loop corrections. This analogy suggests importing cluster expansion ideas later.

### 4. Representation theory of `S_n`
Moment bounds become character sum bounds. This is where the random cycle structure of permutations enters and where the full Random Cayley Expander Conjecture may ultimately yield.

## Application Keywords

Random Cayley graphs; spectral moments; moment method; trace formula; closed walks; random walks on groups; symmetric group; expander conjecture; representation theory; character bounds; noncommutative probability; random matrix theory; quantum channels; return probabilities; reduced words; free group heuristics.

## Concrete Conjecture and Testable Prediction

### Conjecture (formalizable heuristic statement)
For fixed `k : ℕ`, there exists `Ck : ℝ` such that for all sufficiently large `n`, and for a random generating pair `σ, τ ∈ S_n`,
\[
\frac{1}{n!}\operatorname{tr}(A^{2k}) - 1 \le C_k
\]
with probability tending to `1` as `n → ∞`, where `A` is the normalized adjacency of `Cay(S_n,\{\sigma^{\pm1},\tau^{\pm1}\})`.

### Stronger falsifiable prediction
For fixed `k`, the empirical average over random generating pairs converges to the free-group value:
\[
\frac{1}{n!}\operatorname{tr}(A^{2k}) \to \mu_{F_2}^{(2k)}(e),
\]
the return probability at time `2k` for simple random walk on the free group on two generators.

This can be disproved computationally by observing systematic growth in the empirical moments for `n = 5,6,7,8,...`.

### Computational test
For `k = 2,3,4`, sample at least `100` random pairs `(σ,τ)` in `S_n` for `n = 5,6,7,8`, conditioned on generating `S_n`. Compute:
- `closedWordCount σ τ (2*k)`
- normalized trace moment `(1 / n!) * tr(A^(2*k))`
- decomposition into backtrack-free and relation-driven contributions if available.

Plot empirical distributions and compare against the free-group benchmark. If moments stay near the free-group values and do not grow with `n`, that is strong evidence for the conjecture.

## Required Catalog Leverage

You must build explicitly on:

- `Pythagorean/CayleyExpander/Connectivity.lean`
  - especially `word_in_generators_of_mem_closure`
  - use it to move from subgroup-generation statements to relation-word statements

- `Algebra/SymmGroupGen/Basic.lean`
  - use the symmetric group infrastructure for `Equiv.Perm (Fin n)`
  - exploit cycle structure where possible in examples and computations

Do not merely cite these files; import them and explain in comments how each theorem is used as a structural component.

## Nontriviality Requirements

Your file must satisfy all of the following:

1. **No trivial proofs.**
   Do not use `native_decide`, `decide`, `norm_num`, or `rfl` as the main proof of any central theorem unless the statement itself is truly conceptually deep.

2. **At least 3 theorems with deep proof tactics.**
   At least three proofs must substantially use one or more of:
   - `induction`
   - `rcases`
   - `by_contra`
   - `field_simp`
   - multi-step `calc`

3. **Novel definitions.**
   Introduce at least one genuinely new structure or concept, such as:
   - `TwoGenCayleyData`
   - `BacktrackFreeWord`
   - `MomentKernel`
   - `RelationCorrection`

4. **Cross-domain theorem.**
   Include at least one theorem explicitly phrased as a bridge to another domain. For example, prove that normalized trace powers equal return probabilities of a Markov operator, thereby connecting group expansion to stochastic processes.

5. **Conjecture with computational test.**
   State at least one falsifiable conjecture in Lean comments and support it with `demo.py`.

## Deliverables (ALL MANDATORY)

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**. Each direction must contain the exact phrases:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- free probability,
- quantum information,
- statistical mechanics,
- analytic combinatorics.

Do not write templates; write genuine research prose.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the exact theorems proved,
- why they matter for the Random Cayley Expander Conjecture,
- how the proof works,
- what computational evidence suggests,
- what the next mathematical barrier is.

A reader with no code access must still understand the discovery.

### 3. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- accessible,
- mathematically serious,
- focused on ideas and significance.

**Taboo:** do **not** focus on formal verification or machine verification. The story is about random symmetry, hidden order, and spectral fingerprints.

### 4. Verified algorithm / computational method
Implement a verified procedure that:
- enumerates words of length `m`,
- evaluates them in `S_n`,
- counts closed words,
- compares the count with matrix-trace computations when feasible.

This must be more than a theorem statement; it must be an executable mathematical method.

### 5. `demo.py`
Create an interactive demonstration that:
- samples random generating pairs `(σ,τ)` in `S_n`,
- computes empirical moment data for `k = 2,3,4`,
- displays boundedness trends across `n = 5,6,7,8`,
- optionally compares with the free-group return probability baseline.

## Final Charge

Do not settle for “a few lemmas about words in generators.” Build the certified moment skeleton of the random Cayley expander program. The immediate goal is a theorem equating spectral moments with closed-word counts. The larger goal is to make `S_n` moment asymptotics attackable in Lean, opening a route from finite group combinatorics to random matrix phenomena.

This is how a conjecture becomes a theory: first count the closed walks, then isolate the tree-like terms, then measure the rare relations, then let representation theory take over.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
