Soli Deo Gloria

## Assignment: Direction 4 — Tropical Metastability Detection on Energy Landscapes

**Mode:** `prove`

Prove genuinely new theorems at the interface of tropical linear algebra, weighted graph theory, and metastability in statistical physics. Build directly on the catalog result

- `Pythagorean/TropicalBridge/WeightedTropicalHodge.lean` (especially the zero-kernel-under-degeneracy phenomenon alluded to as Theorem 3.9),

but do **not** stop at a variant. The target is a conceptual bridge: a mathematically precise equivalence between **tropical balance conditions** and **metastable degeneracies** in weighted energy landscapes, together with a **verified detection algorithm**.

The scientific wager is bold:

> If an energy landscape is encoded by a weighted directed graph whose edge weights are activation barriers, then metastability is not merely a dynamical phenomenon — it is a tropical linear-algebraic one. Equal-barrier competing escape routes should manifest as min-attainment multiplicities, and the resulting tropical kernel should measure the number of independent metastable degeneracies.

Your task is to turn that into a theorem suite, a computational method, and a research narrative that could launch a new “tropical statistical mechanics.”

---

## Core New Definitions to Introduce

You must define at least one genuinely new concept beyond the catalog. I recommend introducing all three of the following.

### 1. Weighted energy landscape
A weighted energy landscape consists of:
- a finite type of states `V`,
- an activation matrix `W : V → V → ℝ`,
- optionally a vertex energy `E : V → ℝ`.

Interpret `W i j` as the barrier height to escape from state `i` toward `j`.

### 2. Metastable degeneracy at a state
For a state `i : V`, say `i` is **metastably degenerate** if the minimum outgoing activation barrier is attained by at least two distinct neighbors:
\[
\exists j \neq k,\quad W(i,j)=W(i,k)=\min_{\ell} W(i,\ell).
\]

This is the exact graph-theoretic incarnation of “two equally favorable escape routes.”

### 3. Tropical metastability operator and degeneracy rank
Given a subset `S : Finset V`, define a tropical operator whose rows encode outgoing barriers from vertices in `S`. Then define the **metastability rank** of `S` as the maximal number of independent tropical balance relations supported on `S`.

You do not need a fully general abstract notion of tropical dimension if Mathlib support is limited. It is acceptable to formalize a robust surrogate such as:
- a set of pairwise independent balanced rows,
- or the cardinality of a maximal family of vertices in `S` whose balance relations are support-independent,
- or a rank defined via a combinatorial criterion equivalent to kernel dimension in your finite setting.

The point is to capture a mathematically meaningful and computable “number of independent metastable degeneracies.”

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. The following package is the most promising.

### Theorem 1: Tropical balance characterizes local metastable degeneracy
For a finite weighted graph, the tropical row corresponding to a state is balanced exactly when the state has at least two minimum-barrier exits.

#### Mathematical statement
Let `V` be finite and let `W : V → V → ℝ`. For `i : V`, define the row function
\[
r_i(j) := W(i,j).
\]
Then
\[
\text{Balanced}(r_i) \iff \exists j\neq k,\ r_i(j)=r_i(k)=\min_\ell r_i(\ell).
\]

This is the fundamental dictionary theorem.

#### Suggested Lean 4 shape
```lean
def IsMetastablyDegenerate {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i : V) : Prop :=
  ∃ j k : V, j ≠ k ∧
    W i j = sInf (Set.range (W i)) ∧
    W i k = sInf (Set.range (W i))

def TropicallyBalancedRow {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i : V) : Prop :=
  ∃ j k : V, j ≠ k ∧
    W i j = W i k ∧
    ∀ l : V, W i j ≤ W i l

theorem tropicallyBalancedRow_iff_metastablyDegenerate
    {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i : V) :
    TropicallyBalancedRow W i ↔ IsMetastablyDegenerate W i := by
  -- substantial proof
```

If `sInf` over finite ranges becomes awkward, replace with a finite minimum over `Finset.univ`. The key is to avoid trivialization.

#### Why this is a breakthrough
This theorem converts a physically meaningful but often heuristic notion — “the system hesitates because two escape channels are equally low” — into a certified algebraic criterion. It is the base axiom for tropical metastability theory.

---

### Theorem 2: Independent balanced rows yield a lower bound on metastability rank
If a family of states in `S` has pairwise support-independent tropical balance witnesses, then the tropical kernel/metastability rank on `S` is at least the cardinality of that family.

#### Mathematical statement
Let `S ⊆ V`. Suppose there exist distinct states `i₁, …, i_m ∈ S` and for each `i_a` two minimizing exits `j_a ≠ k_a`, with the corresponding balance certificates independent in an appropriate combinatorial sense (for example, no nontrivial overlap pattern that would collapse the witness family). Then
\[
m \le \operatorname{metastabilityRank}(W,S).
\]

You must make “independent” precise in a finite combinatorial way that is formalizable.

#### Suggested Lean 4 shape
```lean
def BalanceWitness {V : Type} [DecidableEq V] (W : V → V → ℝ) (i : V) :=
  {p : V × V // p.1 ≠ p.2 ∧ W i p.1 = W i p.2}

def WitnessIndependent {V : Type} [DecidableEq V]
    (F : Finset V) (σ : ∀ i, i ∈ F → BalanceWitness W i) : Prop :=
  -- your new combinatorial independence notion

def MetastabilityRank {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (S : Finset V) : Nat :=
  -- computable rank surrogate or exact finite tropical rank

theorem card_le_metastabilityRank_of_independent_balanced_family
    {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (S F : Finset V)
    (hF : F ⊆ S)
    (hbal : ∀ i, i ∈ F → TropicallyBalancedRow W i)
    (hind : WitnessIndependent (W := W) F
      (fun i hi => Classical.choose (hbal i hi))) :
    F.card ≤ MetastabilityRank W S := by
  -- deep finite combinatorial proof
```

#### Why this matters
This theorem upgrades local degeneracy detection into a quantitative theory: not just whether metastability exists, but how many independent metastable modes are present.

---

### Theorem 3: Under non-overlap/non-resonance hypotheses, metastability rank equals degeneracy count
This is the flagship theorem.

#### Mathematical statement
Under a suitable finite non-resonance condition on the balanced witnesses for vertices in `S` — for example, each balanced row has a unique unordered pair of minimizing exits and these pairs are support-independent — the metastability rank equals the number of metastably degenerate vertices in `S`:
\[
\operatorname{MetastabilityRank}(W,S)
=
\#\{i\in S : i \text{ is metastably degenerate}\}.
\]

This is exactly the “dimension = independent degeneracy count” theorem in a formalizable finite setting.

#### Suggested Lean 4 shape
```lean
def NonResonantOn {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (S : Finset V) : Prop :=
  -- formulate a strong enough hypothesis to make equality true

theorem metastabilityRank_eq_degeneracyCount
    {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (S : Finset V)
    (hNR : NonResonantOn W S) :
    MetastabilityRank W S
      = (S.filter (fun i => decide (IsMetastablyDegenerate W i))).card := by
  -- major theorem
```

#### Why this is a breakthrough
This is the first rigorous theorem turning tropical kernel dimension into a physically interpretable observable on energy landscapes. It opens the door to certified metastability diagnostics in chemistry and materials science.

---

## Strong Cross-Domain Theorem Requirement

You must include at least one theorem that explicitly bridges to a different domain. The most natural bridge is to **Markov chains / Arrhenius dynamics / statistical physics**.

### Theorem 4: Equal Arrhenius rates correspond to tropical balance
Suppose transition rates are Arrhenius:
\[
k(i,j)=A(i,j)\exp(-\beta W(i,j)).
\]
If prefactors are constant on outgoing edges from `i`, then as \(\beta \to \infty\), equality of dominant escape probabilities is equivalent to tropical balance of the barrier row.

A finite, formalizable version:

- Define the set of minimizing barriers from `i`.
- Prove that if `j` and `k` both minimize `W i ·`, then their rates are asymptotically tied for all sufficiently large `β`, and conversely if two outgoing rates are equal for all `β` under equal prefactors, then the barriers are equal.
- Conclude that tropical metastable degeneracy coincides with low-temperature dynamical degeneracy.

#### Suggested Lean 4 shape
```lean
def ArrheniusRate (β : ℝ) (A W : V → V → ℝ) (i j : V) : ℝ :=
  A i j * Real.exp (-β * W i j)

theorem equal_prefactor_equal_rate_iff_equal_barrier
    {V : Type} [Fintype V]
    (A W : V → V → ℝ) (i j k : V)
    (hA : A i j = A i k)
    (hpos : 0 < A i j) :
    (∀ β : ℝ, ArrheniusRate β A W i j = ArrheniusRate β A W i k) ↔
      W i j = W i k := by
  -- use exp injectivity, ring/field manipulations, calc reasoning
```

Then derive a corollary relating equal dominant low-temperature exits to `TropicallyBalancedRow`.

#### Why this cross-domain theorem is essential
It ties tropical algebra to actual physical kinetics, not just graph combinatorics. This is where the work stops being a formal curiosity and becomes a new language for metastable dynamics.

---

## Proof Strategy Architecture

You must present and execute **2–3 proof pathways** in the code comments or paper, and choose one as primary.

### Strategy A: Finite minimum / witness extraction / combinatorial rank
**Most promising.**
1. Encode tropical balance using explicit minimizers over `Finset.univ`.
2. Prove the local equivalence theorem by extracting two distinct minimizers and converting between “minimum attained twice” and “balanced row.”
3. Define a finite combinatorial independence notion for witness pairs and prove lower/upper bounds on metastability rank separately, then combine them under non-resonance.

**Why best:** It is robust in Lean 4, avoids overreliance on abstract tropical linear algebra infrastructure, and yields a certified algorithm almost for free.

### Strategy B: Build directly on weighted tropical Hodge theory
1. Interpret each balanced row as a local harmonic/tropical cycle condition.
2. Use the catalog theorem in `WeightedTropicalHodge.lean` to transfer degeneracy statements into kernel statements.
3. Derive equality of rank and degeneracy count via a finite decomposition theorem.

**Why exciting:** This would produce the deepest conceptual result and align your work with existing catalog structure.
**Risk:** May depend on the exact API and abstractions already present in the catalog.

### Strategy C: Low-temperature asymptotics first, tropicalization second
1. Define Arrhenius transition rates and prove asymptotic domination by minimal barriers.
2. Show that equal dominant channels correspond to multiplicity of minima.
3. Reinterpret this multiplicity as tropical balance and then package the result into a tropical kernel theorem.

**Why useful:** Strongest bridge to physics, ideal for the paper and article.
**Risk:** Asymptotic formalization can be technically heavier than the finite combinatorial route.

**Recommendation:** Use **Strategy A as the formal spine**, then layer in **Strategy C** for the cross-domain theorem, and import **Strategy B** where the catalog API makes it natural.

---

## Required Deep Proof Tactics

Your file must contain at least 3 nontrivial theorems proved with genuine mathematical structure. Concretely, aim to use:

- `rcases` to unpack minimizer witnesses and distinct exits,
- induction on finite sets / cardinality for maximal independent families,
- `by_contra` for upper-bound or uniqueness arguments,
- `field_simp` or exponential injectivity arguments in the Arrhenius theorem,
- multi-step `calc` chains for finite minimum inequalities and rate equalities.

Do **not** let the core results collapse to decidability or brute-force enumeration.

---

## Formalization Targets and Suggested Definitions

You may want a file such as:

- `EnergyLandscape/TropicalMetastability.lean`

Suggested core definitions:
```lean
structure EnergyLandscape (V : Type) [Fintype V] [DecidableEq V] where
  barrier : V → V → ℝ
  energy  : V → ℝ := fun _ => 0

def OutMinValue {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i : V) : ℝ := ...

def IsOutMinimizer {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i j : V) : Prop := ...

def IsMetastablyDegenerate {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i : V) : Prop := ...

def TropicallyBalancedRow {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (i : V) : Prop := ...

def BalanceWitness ...
def WitnessIndependent ...
def MetastabilityRank ...
def NonResonantOn ...
```

Also define a **verified algorithm**:
```lean
def metastableVertices {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) : Finset V := ...

def metastabilityRankCompute {V : Type} [Fintype V] [DecidableEq V]
    (W : V → V → ℝ) (S : Finset V) : Nat := ...
```

Then prove correctness theorems:
```lean
theorem mem_metastableVertices_iff ...
theorem metastabilityRankCompute_correct ...
```

This algorithmic component is mandatory.

---

## Computational/Algorithmic Deliverable

You must produce a verified computational method, not only theorem statements.

### Algorithm goal
Given a finite weighted graph:
1. compute the minimum outgoing barrier at each vertex,
2. detect whether the minimum is attained at least twice,
3. extract witness pairs,
4. compute a combinatorial independence family,
5. return metastability rank and the set of metastably degenerate states.

This can be greedy if your theorem proves correctness under `NonResonantOn`.

### `demo.py` requirement
Create a Python demo that:
- constructs small energy landscape graphs,
- computes metastable vertices and rank,
- visualizes equal-barrier competing exits,
- tests the conjecture on hand-built examples and random small weighted graphs,
- optionally compares with Arrhenius rates at large inverse temperature `β`.

The demo should illustrate:
- a unique-minimum vertex (not metastable),
- a doubly attained minimum (metastable),
- a graph with two independent metastable vertices,
- a resonant counterexample where naive equality with raw count fails unless `NonResonantOn` is assumed.

---

## Falsifiable Conjecture with Computational Test

You must state at least one conjecture with a clear disproof protocol.

### Conjecture
For finite weighted energy landscapes with generic non-resonant barrier data, the metastability rank equals the number of vertices whose minimum outgoing barrier is attained at least twice.

More sharply:
\[
\Pr\big(\operatorname{MetastabilityRank}(W,S)=\degcount(W,S)\big)\to 1
\]
for random continuous barrier models conditioned on a fixed degeneracy pattern.

### Testable prediction
Generate random weighted graphs, then forcibly impose selected equalities among outgoing edge weights. Compute:
- degeneracy count,
- combinatorial metastability rank,
- failure frequency of equality.

If equality fails, inspect overlap/resonance patterns and refine `NonResonantOn`.

A conjecture that can be falsified by a 6-vertex random search is scientifically valuable. Include at least one scriptable search for counterexamples.

---

## Catalog Leverage

You must explicitly inspect and use the catalog result in:

- `Pythagorean/TropicalBridge/WeightedTropicalHodge.lean`

Your paper/code should explain:
- which notion of tropical kernel or degeneracy already exists there,
- how your new definitions refine or reinterpret it for energy landscapes,
- whether your `MetastabilityRank` coincides with a pre-existing kernel notion under additional hypotheses.

If possible, prove a transfer theorem of the form:
```lean
theorem weightedTropicalKernel_eq_metastabilityRank_under_hypotheses ...
```
or at least a one-sided inequality.

This is important: the project should feel like a **new field built from the catalog**, not an isolated exercise.

---

## Revolutionary Significance

If you succeed, the payoff is outsized:

- **Statistical physics:** a new algebraic invariant for metastable escape structure.
- **Computational chemistry:** certified detection of competing folding pathways.
- **Materials science:** identification of barrier-degenerate transition states.
- **Tropical geometry:** a concrete physical semantics for tropical kernels.
- **Applied mathematics:** a new bridge from weighted graph combinatorics to low-temperature dynamics.

This would open a program in **tropical kinetics** or **tropical metastability theory**, where energy landscapes are analyzed via balance loci, kernel dimensions, and tropical Hodge structures.

---

## Application Keywords

Use these explicitly in the paper and article:

**tropical linear algebra, weighted graphs, metastability, energy landscapes, Arrhenius dynamics, low-temperature asymptotics, protein folding, transition state detection, statistical physics, computational chemistry, tropical kernel, combinatorial rank, barrier degeneracy, Markov chains, rare-event dynamics**

---

## Mandatory Deliverables

You must produce **all** of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different field, such as:
- Morse theory / persistent homology on energy landscapes,
- tropical optimal transport for reaction networks,
- metastability in spin glasses,
- tropical information theory for rare-event channels.

Do not write templates; write actual research prose.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the new definitions,
- the main theorems,
- why the results matter physically and mathematically,
- proof ideas,
- computational experiments,
- limitations and next questions.

Someone reading only this document must understand the discovery without seeing the code.

### 3. `ARTICLE.md`
Write in a **Scientific American** style:
- vivid, concept-driven, accessible,
- explain how equal escape barriers create “hesitating” states,
- show why tropical mathematics unexpectedly captures this,
- emphasize chemistry/physics significance.

**Taboo:** do **not** focus on formal verification machinery. The story is about the mathematics and science.

### 4. Verified algorithm
A certified method computing metastable vertices and metastability rank, with correctness theorems.

### 5. `demo.py`
An interactive demonstration with examples, visual output if feasible, and randomized testing of the conjecture.

---

## Final Standard

Do not settle for “a graph has two equal weights.” The goal is to found a new formal language for metastable degeneracy.

At minimum, your Lean development should establish:

1. **local equivalence**: tropical balance ↔ metastable degeneracy,
2. **quantitative lower/upper bounds**: independent balanced witnesses control rank,
3. **flagship equality theorem**: under non-resonance, rank = degeneracy count,
4. **physics bridge**: Arrhenius rate symmetry reflects tropical balance,
5. **algorithmic realization**: computable metastability detection with proofs.

Minimize sorry. Prefer one deep, coherent file with three serious theorems over many shallow fragments. Build something that a researcher in tropical geometry or statistical physics would genuinely not have expected to exist.

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
