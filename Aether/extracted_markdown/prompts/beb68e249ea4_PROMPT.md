# Soli Deo Gloria

## Assignment: Arithmetic Monodromy from Persistent Homology of p-adic Newton Iteration Graphs

You are not being asked for a toy formalization. You are being asked to create a new arithmetic-topological language for detecting Galois structure from modular dynamics.

The conjectural vision is extraordinary: **persistent homology of Newton iteration graphs modulo primes should encode Frobenius statistics, hence arithmetic monodromy**. If this can be made precise even in a first rigorous regime, it opens a field: a topological interface between arithmetic dynamics, finite-field Newton maps, persistent invariants, and inverse Galois heuristics.

Your task is to extract the first theorems in this direction that are both formally robust and mathematically catalytic.

## Mode: prove

Produce a Lean 4 development establishing a rigorous backbone for the program, centered on **Newton graphs over finite fields**, **filtrations by arithmetic-dynamical complexity**, and **persistence statistics that provably recover root-count/Frobenius information in a first nontrivial regime**.

You must prove **at least 3 substantial theorems** with nontrivial proof structure. Do not hide behind decidability or brute force. The point is to build the theory.

---

## Core mathematical objects to define

Define at least one genuinely new concept. The following package is recommended.

### 1. Newton map on a finite field with singular masking
For a commutative field `K` and polynomial `f : K[X]`, define the partial Newton map
\[
N_f(x)=x-\frac{f(x)}{f'(x)}
\]
when `f'(x) ≠ 0`, and treat derivative-zero points as singular/marked.

In Lean, aim for a totalized version carrying singularity information:

```lean
def newtonStep? (f : Polynomial K) (x : K) : Option K :=
  if h : Polynomial.derivative f.eval x ≠ 0 then
    some (x - f.eval x / Polynomial.derivative f.eval x)
  else
    none
```

You may prefer a graph-oriented definition that avoids partiality issues:

```lean
def IsNewtonEdge (f : Polynomial K) (x y : K) : Prop :=
  Polynomial.eval x (Polynomial.derivative f) ≠ 0 ∧
  y = x - (Polynomial.eval x f) / (Polynomial.eval x (Polynomial.derivative f))
```

### 2. Newton functional graph over `ZMod p`
For prime `p`, define the directed graph on `ZMod p` induced by `newtonStep?`.

```lean
def newtonGraph (p : ℕ) [Fact p.Prime] (f : Polynomial (ZMod p)) : SimpleGraph (ZMod p)
```

If directed graphs are inconvenient in Mathlib’s current graph API, define your own edge relation and work with predecessor fibers and fixed points directly. The mathematics matters more than the container.

### 3. Persistence-relevant filtration datum
Define a filtration statistic on vertices. Two promising choices:

- **root-basin depth**: least `n` such that `N_f^[n](x)` is a fixed root, if such `n` exists;
- **preimage-count filtration**: threshold vertices by size of the predecessor fiber;
- **singularity-aware depth**: penalize or separate points where `f'(x)=0`.

A clean formal target is:

```lean
def rootBasinDepth (f : Polynomial K) (x : K) : ℕ∞ := ...
```

or

```lean
def predecessorCount (f : Polynomial K) (y : K) : ℕ := ...
```

Then define a persistence statistic that can actually be proved to correlate with arithmetic data. For example:

```lean
def persistenceRootProfile (p : ℕ) [Fact p.Prime]
    (f : Polynomial (ZMod p)) : Finset ℕ := ...
```

or a histogram-valued invariant.

### 4. Arithmetic monodromy proxy
Define a first-order arithmetic statistic that is already known to reflect Frobenius cycle data:

- number of roots of `f mod p`,
- number of fixed points of the Newton map,
- number of attracting fixed points/root basins under a filtration,
- distribution of basin depths when all roots are simple modulo `p`.

The crucial bridge is that **simple roots are exactly fixed points of the Newton map at nonsingular points**.

---

## Precise theorem targets

You should prove a cluster of theorems that together establish the first rigorous bridge from Newton persistence to Frobenius data.

### Theorem 1: Fixed points of Newton map are exactly simple roots
This is the foundational arithmetic-dynamical identity.

**Mathematical statement.**  
Let `K` be a field and `f ∈ K[X]`. If `x ∈ K` satisfies `f'(x) ≠ 0`, then
\[
N_f(x)=x \iff f(x)=0.
\]
Hence for squarefree reduction mod `p`, the fixed points of the Newton map are exactly the roots of `f mod p`.

**Lean target signature:**
```lean
theorem newton_fixed_iff_eval_eq_zero
    {K : Type*} [Field K] (f : Polynomial K) {x : K}
    (hderiv : Polynomial.eval x (Polynomial.derivative f) ≠ 0) :
    (x - (Polynomial.eval x f) / (Polynomial.eval x (Polynomial.derivative f)) = x)
      ↔ Polynomial.eval x f = 0 := by
```

This theorem is not cosmetic: it identifies the `H_0` birth set of the Newton dynamics with the Frobenius root-count statistic.

---

### Theorem 2: Root count equals number of nonsingular Newton fixed points over `ZMod p`
This is the first arithmetic monodromy bridge.

**Mathematical statement.**  
For prime `p`, let `f ∈ (ZMod p)[X]`. Then the number of `x ∈ ZMod p` such that `x` is a fixed point of the Newton map and `f'(x) ≠ 0` equals the number of simple roots of `f mod p`. If `f mod p` is squarefree, this equals the total number of roots of `f mod p`.

**Lean target signature:**
```lean
theorem card_newtonFixed_eq_card_roots_of_squarefree
    (p : ℕ) [Fact p.Prime] (f : Polynomial (ZMod p))
    (hsq : f.IsSquarefree) :
    Fintype.card {x : ZMod p // Polynomial.eval x f = 0}
      =
    Fintype.card {x : ZMod p //
      Polynomial.eval x (Polynomial.derivative f) ≠ 0 ∧
      x - (Polynomial.eval x f) / (Polynomial.eval x (Polynomial.derivative f)) = x} := by
```

A variant replacing `IsSquarefree` by an explicit simple-root predicate is also acceptable if technically cleaner.

This theorem gives a **certified persistence statistic**:
\[
S_p(f):=\#\{\text{Newton fixed points}\},
\]
which already recovers the Frobenius fixed-point statistic.

---

### Theorem 3: The persistence-zero statistic recovers Frobenius fixed-point counts
Define the filtration so that depth `0` vertices are exactly Newton fixed points. Then prove that the zero-depth barcode multiplicity equals the number of roots modulo `p` for good primes.

**Mathematical statement.**  
For squarefree `f mod p`, if `rootBasinDepth f x = 0` iff `x` is a nonsingular Newton fixed point, then
\[
\#\{x : \mathrm{depth}(x)=0\} = \#\{x : f(x)=0\}.
\]

**Lean target signature:**
```lean
theorem card_depth_zero_eq_card_roots
    (p : ℕ) [Fact p.Prime] (f : Polynomial (ZMod p))
    (hsq : f.IsSquarefree) :
    Fintype.card {x : ZMod p // rootBasinDepth f x = 0}
      =
    Fintype.card {x : ZMod p // Polynomial.eval x f = 0} := by
```

You may define `rootBasinDepth` so that this theorem becomes genuinely meaningful rather than tautological.

---

### Theorem 4: Distinguish arithmetic types via root-count distributions
This theorem should connect the Newton-persistence statistic to classical arithmetic data in a way that can separate Galois behavior.

A realistic formal target is not full Chebotarev in Lean, but a **finite-level separation theorem**:

**Mathematical statement.**  
Suppose `f, g ∈ ℤ[X]` have infinitely many good primes and their reductions satisfy that the root-count functions
\[
p \mapsto \#\{x \in \mathbb{F}_p : f(x)=0\}, \qquad
p \mapsto \#\{x \in \mathbb{F}_p : g(x)=0\}
\]
differ on some set of primes. Then the Newton fixed-point persistence statistics differ on the same set of primes.

This is mathematically modest but conceptually essential: it proves that the topological statistic is at least as discriminating as root-count Frobenius data.

**Lean-friendly target signature:**
```lean
theorem persistence_stat_separates_when_root_counts_differ
    (f g : ℕ → Polynomial (ZMod ·)) :
    -- formulate over a finite sampled prime set or a parameterized family
    ...
```

If this exact formulation is too awkward in Lean, prove a finite-prime comparison theorem for two fixed primes or two polynomial families indexed by `p`. The key is a theorem with real content: **difference in arithmetic root data forces difference in persistence data**.

---

### Theorem 5: Cross-domain theorem — Newton graph fixed-point homology equals arithmetic root homology
You must include a theorem explicitly connecting arithmetic dynamics to topology.

One clean route: define the zeroth persistent Betti number of the depth-0 sublevel graph and show it equals the number of roots when the depth-0 subgraph is discrete.

**Mathematical statement.**  
If the depth-0 filtration layer consists exactly of nonsingular Newton fixed points and has no nontrivial edges, then
\[
\beta_0(\text{depth-0 layer}) = \#\{x : f(x)=0\}.
\]

**Lean target signature:**
```lean
theorem beta0_depthZero_eq_rootCount
    (p : ℕ) [Fact p.Prime] (f : Polynomial (ZMod p))
    (hsq : f.IsSquarefree)
    (hdisc : depthZeroSubgraphDiscrete f) :
    beta0 (depthZeroSubgraph f) =
      Fintype.card {x : ZMod p // Polynomial.eval x f = 0} := by
```

If full homology is too heavy for current infrastructure, define `beta0` combinatorially as number of connected components of a finite graph. That still qualifies as a true topology/arithmetic bridge.

---

## Why this would be a breakthrough

The usual arithmetic information extracted from reduction modulo primes is algebraic: factorization type, root counts, trace formulas, point counts. You are being asked to show that **iterative dynamics and topological persistence form another arithmetic measurement device**.

If successful, this creates:

- a new topological probe of Frobenius statistics,
- a finite-field dynamical model of arithmetic monodromy,
- a bridge from persistent homology to inverse Galois heuristics,
- a pathway toward data-driven recognition of Galois groups from modular dynamical signatures.

This is not “Newton’s method over finite fields” as a curiosity. This is **arithmetic dynamics as topological spectroscopy**.

---

## Proof architecture: 3 possible strategies

You should explicitly choose among the following approaches and use at least one deeply.

### Strategy A: Algebra-first, then topology
Most promising for Lean.

1. Prove the exact fixed-point identity
   \[
   N_f(x)=x \iff f(x)=0
   \]
   under `f'(x) ≠ 0` by algebraic rearrangement.
   This will require `field_simp`, careful use of `hderiv`, and a reverse implication.

2. Use squarefreeness to show every root is nonsingular:
   from `f.IsSquarefree`, deduce `eval x f = 0 → eval x (derivative f) ≠ 0`.
   This is where catalog lemmas on squarefree polynomials and coprimality with derivatives should be exploited.

3. Transfer the arithmetic counting statement to the graph/persistence layer by extensional equality of finite subtype sets.

Why promising: it isolates the hard algebra in a compact theorem and then turns the rest into structured counting and graph reasoning.

---

### Strategy B: Basin-depth dynamics
Best if you want a richer persistence theorem.

1. Define `rootBasinDepth` using iteration of the Newton map toward fixed roots.
2. Prove depth `0` is equivalent to being a fixed nonsingular root.
3. Prove cardinality/β₀ statements for the depth-0 filtration layer.

Why promising: this gives a real persistence object rather than just a counting trick. It better matches the long-term conjecture.

Risk: iteration with partial maps in Lean can be technically subtle. You may need a totalized map to `Option K` or a marked singular state.

---

### Strategy C: Fiber/preimage filtration
Best for combinatorial graph theorems.

1. Define predecessor count
   \[
   \mathrm{pred}(y)=\#\{x : N_f(x)=y\}.
   \]
2. Show roots/fixed points are extremal or structurally distinguished in this filtration.
3. Prove that the zero-layer or minimal-layer persistence recovers root count.

Why promising: finite counting over `ZMod p` is Lean-friendly and can lead to algorithms.

Risk: the arithmetic meaning may be less immediate than basin depth unless carefully designed.

**Recommendation:** Use **Strategy A + B**. A gives the first hard theorem quickly and reliably; B upgrades it into genuine persistence language.

---

## Catalog building blocks to exploit

You must actively search Mathlib for the strongest available lemmas around:

- `Polynomial.eval`
- `Polynomial.derivative`
- `Polynomial.IsSquarefree`
- squarefree/root multiplicity equivalences over fields
- coprimality of `f` and `f.derivative`
- finite cardinality lemmas for subtypes over `ZMod p`
- iteration (`Function.iterate`)
- finite graph connected components if available

In particular, build on facts of the following form:

1. **Squarefree implies derivative nonvanishing at roots** over a field.  
   This is the exact arithmetic input needed to identify roots with nonsingular fixed points.

2. **Polynomial root-set finiteness over finite fields**.  
   Needed for cardinality statements and algorithm extraction.

3. **`ZMod p` is a field when `p` is prime**.  
   Essential for division and Newton-step definitions.

Do not merely cite these ideas; wire them into your proof terms and explain in comments how they drive the argument.

---

## Cross-domain connections you must make explicit

At least one theorem and the paper exposition must connect to another domain. Strong options:

### Arithmetic dynamics + Topological data analysis
The Newton graph filtration is a persistence object; the barcode at depth 0 recovers arithmetic root information.

### Number theory + Dynamical systems
Frobenius root counts become fixed-point counts of a rational map over finite fields.

### Algebra + Topology
Connected components / Betti numbers of filtration layers encode algebraic splitting behavior.

### Number theory + Statistical learning
The persistence histogram `S_p(f)` is a candidate feature vector for classifying Galois groups from modular samples.

You must state this bridge explicitly in at least one formal theorem and in the prose documents.

---

## Application keywords

Include these keywords in your prose and orient the project around them:

**arithmetic dynamics, Newton map over finite fields, persistent homology, Frobenius statistics, Galois group detection, arithmetic monodromy, inverse Galois heuristics, topological data analysis, finite field dynamics, graph filtration, basin depth, root-count distribution, Chebotarev-inspired signatures, modular dynamical invariants**

---

## Falsifiable conjecture and computational prediction

You must state at least one conjecture with a concrete disproof protocol.

### Conjecture A: fixed-point persistence separates generic transitive Galois groups
For squarefree irreducible `f, g ∈ ℤ[X]` of the same degree with non-isomorphic transitive Galois groups, the empirical distributions of
\[
S_p(f)=\#\{x\in\mathbb F_p : \text{Newton depth}(x)=0\}
\]
over good primes differ unless the Frobenius fixed-point distributions agree.

**Testable prediction:** over sampled good primes up to bound `B`, the histograms of `S_p(f)` distinguish generic `S_d`, `A_d`, dihedral, and cyclic families with statistically significant accuracy.

**Refutation criterion:** produce two families with distinct transitive Galois groups but asymptotically indistinguishable `S_p` distributions.

### Conjecture B: depth-profile refines root-count statistics
The full basin-depth histogram
\[
D_p(f)=(\#\{x:\mathrm{depth}(x)=k\})_{k\ge 0}
\]
contains strictly more information than the root count alone for a density-positive set of primes.

**Testable prediction:** there exist polynomial pairs with equal root-count distributions but different depth-profile distributions.

This is especially interesting because it would mean persistence detects arithmetic structure beyond the most naive Frobenius observable.

---

## Concrete implementation expectations in Lean

Your Lean file should contain:

1. New definitions:
   - `newtonStep?` or equivalent
   - `IsNewtonFixed`
   - `rootBasinDepth` or `predecessorCount`
   - one graph/topological persistence proxy

2. At least 3 substantial theorems, such as:
   - `newton_fixed_iff_eval_eq_zero`
   - `card_newtonFixed_eq_card_roots_of_squarefree`
   - `card_depth_zero_eq_card_roots`
   - one cross-domain `beta0`/connected-component theorem

3. Proof tactics that visibly involve:
   - `field_simp`
   - `rcases`
   - `by_contra`
   - multi-step `calc`
   - induction if you define iterated depth

4. Minimal sorrys. If one hard library gap remains, isolate it sharply and document it.

---

## Suggested proof skeleton for the foundational theorem

For `newton_fixed_iff_eval_eq_zero`:

```lean
theorem newton_fixed_iff_eval_eq_zero
    {K : Type*} [Field K] (f : Polynomial K) {x : K}
    (hderiv : Polynomial.eval x (Polynomial.derivative f) ≠ 0) :
    (x - (Polynomial.eval x f) / (Polynomial.eval x (Polynomial.derivative f)) = x)
      ↔ Polynomial.eval x f = 0 := by
  constructor
  · intro hfix
    have hdiv : (Polynomial.eval x f) / (Polynomial.eval x (Polynomial.derivative f)) = 0 := by
      linarith
    have := div_eq_zero_iff.mp hdiv
    rcases this with hnum | hden
    · exact hnum
    · exact (hderiv hden).elim
  · intro hroot
    field_simp [hderiv, hroot]
```

This exact sketch may need adjustment depending on available lemmas, but the proof should genuinely use the field structure rather than collapse by simplification.

---

## Suggested stronger theorem if the library cooperates

If you can access root multiplicity lemmas, prove:

**Theorem.** Over a field `K`, for any `x : K`,
\[
f(x)=0 \land f'(x)=0 \iff \text{the root multiplicity of }x\text{ in }f \text{ is at least }2.
\]

Then deduce squarefree reductions have no singular roots. This would make the arithmetic input conceptually complete.

Possible Lean target:

```lean
theorem eval_and_derivative_eq_zero_iff_rootMultiplicity_ge_two
    {K : Type*} [Field K] (f : Polynomial K) {x : K} :
    Polynomial.eval x f = 0 ∧ Polynomial.eval x (Polynomial.derivative f) = 0
      ↔ 2 ≤ rootMultiplicity x f := by
```

If this exact theorem is too ambitious, prove a one-way implication sufficient for squarefree applications.

---

## Deliverables — all mandatory

You must produce all of the following:

### 1. Lean development
A complete Lean 4 file formalizing the new definitions and proving the theorems above, with minimal sorry.

### 2. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each with:
- a title,
- a short paragraph,
- a sentence beginning **“The key insight is...”**
- a sentence beginning **“Why now?”**
At least one direction must bridge to a different domain, such as:
- spectral graph theory,
- étale cohomology heuristics,
- statistical learning theory,
- tropical geometry,
- quantum information-inspired dynamics.

### 3. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the definitions,
- the main theorems,
- why Newton persistence is an arithmetic invariant,
- how this relates to Frobenius and Galois groups,
- what conjectures and experiments come next.

Someone reading only this document must understand the discovery without seeing the code.

### 4. `ARTICLE.md`
Write in **Scientific American style**.  
Make it vivid and idea-driven. Explain how a root-finding algorithm, when viewed modulo primes, produces dynamical fingerprints of hidden symmetry.  
**Do not focus on formal verification machinery.** Focus on the mathematics and why it could matter.

### 5. Verified algorithm / computational method
Implement a verified computational method for:
- constructing the Newton graph over `ZMod p`,
- computing fixed points / depth-0 profile,
- optionally computing basin-depth histograms.

This must be mathematically tied to the proven theorems.

### 6. `demo.py`
Provide an interactive script that:
- samples primes,
- reduces integer polynomials modulo `p`,
- computes the Newton graph statistic,
- plots or prints persistence/root-count histograms,
- compares families with different known Galois groups.

This is essential: the theorem should generate data, and the data should guide the next conjecture.

---

## Final charge

Do not settle for a formal curiosity. Prove the first theorems showing that **persistent features of modular Newton dynamics are arithmetic invariants**. Even if you only fully recover the Frobenius fixed-point statistic in this cycle, do it in a way that makes the next leap inevitable: from root counts to full cycle-type detection, from fixed points to basin-depth barcodes, from arithmetic dynamics to monodromy spectroscopy.

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

Research domain: Speculative
Research mode: prove
