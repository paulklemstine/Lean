Soli Deo Gloria

## Assignment: Direction 1: Character Sum Bounds for `S_n` via Moment Kernel Decomposition

**Mode:** `prove`

Prove a genuinely new theorem at the interface of random Cayley graph theory, asymptotic representation theory of the symmetric group, and spectral moment methods. Do not merely repackage existing conjugation-invariance lemmas: use them as the launchpad for a representation-theoretic decomposition that forces a quantitative decay law for excess moments.

The target is to formalize the first nontrivial asymptotic correction term in the moment method for random 2-generated Cayley graphs of `S_n`. This is not an incremental bound. It is the first step toward a fully formal “character-expansion theory of random Cayley expansion,” where spectral statistics are controlled by low-dimensional irreducible representations.

---

## Core Theorem Vision

Let
- `momentKernel σ τ m` be the certified moment kernel already defined in the catalog,
- `μ_F2^(m)(e)` denote the free-group return moment of length `m`,
- and define the excess moment
  \[
  \delta_m(\sigma,\tau) := \mathrm{momentKernel}(\sigma,\tau,m)-\mu_{F_2}^{(m)}(e).
  \]

For fixed even length `2k`, the central conjectural law is:

\[
\mathbb E_{(\sigma,\tau)\in S_n\times S_n}[\delta_{2k}(\sigma,\tau)] = O_k(1/n).
\]

The breakthrough is to **make this quantitative through a character/moment decomposition**, isolating the standard representation as the first correction term and proving that every other certified contribution is lower-order or nonnegative in a controlled sense.

This would open a new formal research program: **asymptotic spectral statistics of random Cayley graphs via machine-checked character theory**.

---

## Precise Formal Targets

You should introduce at least one new definition that does not already exist in the catalog, such as a class-averaged excess moment or a representation-truncated correction term.

### New definitions to introduce

A promising pair of definitions:

```lean
def excessMoment {n : ℕ} (σ τ : Equiv.Perm (Fin n)) (m : ℕ) : ℚ :=
  momentKernel σ τ m - freeGroupReturnMoment 2 m

def avgExcessMoment (n m : ℕ) : ℚ :=
  ((∑ σ : Equiv.Perm (Fin n), ∑ τ : Equiv.Perm (Fin n), excessMoment σ τ m) : ℚ) /
    ((Nat.factorial n)^2)
```

If `freeGroupReturnMoment` is not yet defined under that exact name, align with the catalog’s certified object from `MomentMethodAdvanced.lean` and keep the mathematical meaning unchanged.

A second genuinely new definition should capture class compression:

```lean
def classAveragedExcessMoment (n m : ℕ) : ℚ := ...
```

where the sum is reduced using conjugacy invariance to partitions / cycle types.

---

## Theorem 1: Conjugacy-class compression of the average excess moment

This is the gateway theorem: the global average over pairs collapses to a weighted sum over conjugacy classes because the kernel is invariant under simultaneous conjugation.

### Precise theorem statement

For every `n` and `m`, the average excess moment equals a sum indexed by conjugacy classes of `S_n`, with weights given by class sizes.

A Lean-facing version can be stated abstractly first, then specialized once the class-indexing mechanism is chosen:

```lean
theorem avgExcessMoment_eq_class_sum
    (n m : ℕ) :
    avgExcessMoment n m
      =
    classAveragedExcessMoment n m := by
  ...
```

If you formalize conjugacy classes concretely via cycle types / integer partitions of `n`, an even stronger theorem is desirable:

```lean
theorem avgExcessMoment_eq_cycleType_sum
    (n m : ℕ) :
    avgExcessMoment n m
      =
    ((∑ a in cycleTypes n, ∑ b in cycleTypes n,
        ((classSize a : ℚ) * (classSize b : ℚ)) *
          excessMomentOfCycleTypes a b m) : ℚ) /
      ((Nat.factorial n)^2) := by
  ...
```

### Why this matters

This theorem converts an intractable sum over `(n!)^2` pairs into a finite partition sum. It is the formal analogue of passing from microscopic randomness to a mesoscopic order parameter. Without this compression, no realistic asymptotic or computational theorem is possible.

### Proof strategy options

**Strategy A: Orbit-stabilizer averaging via simultaneous conjugation**  
1. Use `momentKernel_conj_invariant` and the corresponding excess-moment invariance.  
2. Show the summand is constant on diagonal conjugation orbits of `S_n` acting on `S_n × S_n`.  
3. Rewrite the double sum as a sum over orbit representatives weighted by orbit cardinality.

**Strategy B: Direct quotient by conjugacy classes**  
1. Prove `excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m = excessMoment σ τ m`.  
2. Construct a class function on pairs.  
3. Invoke finite-group summation over fibers of the quotient map to the class parameter space.

**Strategy C: Cycle-type factorization**  
1. Show dependence only on cycle types using the certified conjugation invariance theorem.  
2. Choose canonical representatives for each partition.  
3. Expand the total average as a weighted partition sum.

**Most promising:** Strategy A, because it uses the existing catalog theorem most directly and minimizes auxiliary infrastructure. Strategy C is scientifically more illuminating and better for computation, so if feasible, pursue both: A for the main proof, C for the executable algorithm.

---

## Theorem 2: Uniform vanishing of the odd excess moment average

This theorem is not the headline asymptotic result, but it is a deep structural theorem and should be proven nontrivially. It serves as a parity-selection rule analogous to symmetry cancellation in statistical mechanics and quantum field theory.

### Precise theorem statement

For odd word length, the class-averaged excess moment vanishes.

```lean
theorem avgExcessMoment_odd_eq_zero
    (n r : ℕ) :
    avgExcessMoment n (2 * r + 1) = 0 := by
  ...
```

This statement should only be asserted if it matches the actual free-group parity behavior encoded in the catalog definitions. If the catalog uses a convention where odd moments vanish only after subtracting the free-group term, prove the exact version that is mathematically true.

### Why this matters

This is the first nontrivial selection rule for the moment kernel. It shows that the excess signal lives entirely in the even sector, exactly where spectral expansion and return probabilities interact. In physics language, this is a parity superselection law for the random walk moment observable.

### Proof strategy options

**Strategy A: Closed-word parity obstruction**  
1. Use `trace_pow_eq_closedWordCount` or `spectral_moment_eq_return_prob`.  
2. Show that odd-length closed reduced words cannot return to the identity in the relevant free-group model.  
3. Transport this to `avgExcessMoment`.

**Strategy B: Involution on words / walk reversal**  
1. Construct a sign-reversing involution or cancellation principle on odd words.  
2. Show that the moment contribution cancels pairwise.  
3. Deduce vanishing after averaging.

**Strategy C: Spectral symmetry**  
1. Express odd moments as traces of odd powers of a symmetric operator with centered free-group correction.  
2. Use a spectral symmetry or bipartite-type cancellation argument where valid.  
3. Deduce exact zero.

**Most promising:** Strategy A, because it interfaces cleanly with certified return-probability identities and should support a Lean proof with induction and `calc`.

---

## Theorem 3: Quantitative `1/n` upper bound for the averaged even excess moment

This is the flagship theorem. Even a clean explicit bound with a constant depending on `k` is a major result.

### Precise theorem statement

For each fixed `k`, there exists a constant `Ck` such that for all sufficiently large `n`,
\[
\left| \mathrm{avgExcessMoment}(n,2k)\right| \le \frac{C_k}{n}.
\]

A Lean 4 target should be stated in a form compatible with available asymptotic infrastructure. For example:

```lean
theorem avgExcessMoment_even_le_const_div
    (k : ℕ) :
    ∃ C : ℚ, 0 < C ∧ ∀ n : ℕ, 2 ≤ n →
      |avgExcessMoment n (2 * k)| ≤ C / n := by
  ...
```

If `ℚ` creates friction for absolute values and asymptotics, move to `ℝ`:

```lean
theorem avgExcessMoment_even_le_const_div
    (k : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 2 ≤ n →
      |(avgExcessMoment n (2 * k) : ℝ)| ≤ C / n := by
  ...
```

A weaker but still excellent milestone theorem is:

```lean
theorem avgExcessMoment_even_isBigO_inv
    (k : ℕ) :
    Asymptotics.IsBigO atTop
      (fun n : ℕ => (avgExcessMoment n (2 * k) : ℝ))
      (fun n : ℕ => (1 : ℝ) / n) := by
  ...
```

### Why this is revolutionary

This would be the first formal asymptotic moment bound for random Cayley graphs on `S_n`, and it would identify the mechanism behind the correction: low-dimensional representation theory, not brute-force combinatorics. It creates a bridge between:
- random graph expansion,
- symmetric-group character theory,
- asymptotic representation theory,
- and certified spectral computation.

It also gives a concrete, formal foothold on the Random Cayley Expander Conjecture by controlling the first finite-`n` deviation from the free-group law.

### Proof strategy options

**Strategy A: Standard-representation dominance**
1. Express the averaged kernel through a certified trace/character expansion over irreducible representations of `S_n`.  
2. Isolate the trivial representation term as exactly the free-group contribution.  
3. Show the leading nontrivial term comes from the standard representation of dimension `n-1`, producing an `O(1/n)` correction via character orthogonality; bound all remaining terms by dimension growth.

**Strategy B: Character-sum inequality without full Plancherel expansion**
1. Use class compression from Theorem 1.  
2. Bound each class contribution using permutation character estimates or cycle-count statistics.  
3. Sum over partitions with a dimension-sensitive inequality to recover `C_k / n`.

**Strategy C: Tensor-moment decomposition**
1. Interpret the `2k`-th moment as an invariant count in a tensor power representation.  
2. Decompose the tensor power into irreducibles and identify the standard representation block as the first correction.  
3. Use Schur orthogonality and combinatorics of partition algebras / Young diagrams to bound the remainder.

**Most promising:** Strategy A if Mathlib’s character theory is sufficient; Strategy B if not. Strategy C is the most conceptually powerful and would connect this project to invariant theory and statistical mechanics, but it may require more infrastructure.

---

## Cross-domain theorem requirement

You must include at least one theorem that genuinely bridges this subject to another domain.

### Recommended bridge: spectral graph theory + statistical mechanics

Define a normalized partition-function-style observable from the moment kernel, e.g. a truncated generating function
\[
Z_n(\beta; \sigma,\tau) := \sum_{k \le K} \frac{\beta^{2k}}{(2k)!}\,\delta_{2k}(\sigma,\tau),
\]
and prove a theorem showing that average control of moments yields average control of this truncated “free energy correction.”

A Lean-style target:

```lean
def truncatedExcessPartitionFn
    {n : ℕ} (K : ℕ) (β : ℚ) (σ τ : Equiv.Perm (Fin n)) : ℚ := ...

theorem avg_truncatedExcessPartitionFn_bound
    (K n : ℕ) :
    ∃ C : ℚ, 0 < C ∧ ∀ β : ℚ,
      |((∑ σ : Equiv.Perm (Fin n), ∑ τ : Equiv.Perm (Fin n),
          truncatedExcessPartitionFn K β σ τ) : ℚ)|
      ≤ C * (∑ k in Finset.range (K+1), |β|^(2*k)) := by
  ...
```

This is a real cross-domain bridge: the moment method becomes a finite-temperature partition function. It links expander theory to statistical mechanics and opens a route to concentration inequalities and phase-transition analogies.

Alternative bridge: probability / Markov chains. Prove that the averaged excess moment controls deviation of finite-time return probabilities from the free-group benchmark.

**Application keywords:** random Cayley graphs, symmetric-group characters, spectral moments, expander heuristics, asymptotic representation theory, partition functions, statistical mechanics, return probabilities, class functions, tensor invariants.

---

## Conjecture with testable prediction

State explicitly and make it computationally falsifiable:

### Conjecture A: asymptotic sharpness of the standard representation
For each fixed `k ≥ 1`, there exists `c_k ≠ 0` such that
\[
n \cdot \mathbb E_{\sigma,\tau}[\delta_{2k}(\sigma,\tau)] \to c_k
\quad \text{as } n \to \infty.
\]

Interpretation: the `O(1/n)` law is not merely an upper bound; it is the true first-order asymptotic, and the standard representation supplies the constant.

### Computational test
For `n = 5,\dots,12`, compute
\[
A_{n,k} := \mathrm{avgExcessMoment}(n,2k),
\qquad
B_{n,k} := n \cdot A_{n,k},
\]
for small `k` (say `k = 1,2,3,4`), and regress `A_{n,k}` against `1/n`.  
A disproof occurs if:
- the residuals systematically favor `1/\sqrt n` or constant behavior,
- or `B_{n,k}` fails to stabilize numerically.

### Stronger conjecture
If your decomposition gets far enough, formulate:
\[
\mathbb E[\delta_{2k}] = \frac{c_k^{\mathrm{std}}}{n-1} + O_k(n^{-2}),
\]
where `c_k^{std}` is an explicit standard-representation coefficient.

---

## Required catalog build-on points

You must explicitly use and cite how the following certified results enter the proof:

1. `Pythagorean/CayleyExpander/MomentMethod.lean`
   - `closedWordCount_conj_invariant`
   - `momentKernel_conj_invariant`

   **Use:** These certify that the kernel depends only on simultaneous conjugacy class data, enabling Theorem 1 and reducing all averages to class functions.

2. `Pythagorean/CayleyExpander/MomentMethodAdvanced.lean`
   - `trace_pow_eq_closedWordCount`
   - `spectral_moment_eq_return_prob`

   **Use:** These identify moment kernels with trace / return-probability objects, enabling parity arguments and any representation-theoretic trace expansion.

Do not just name these theorems. In `RESEARCH_PAPER.md`, explain exactly where each enters the architecture.

---

## Proof architecture expectations

Your Lean file must contain at least 3 substantial theorems with real proof structure. At minimum, ensure the proofs use some of:
- induction,
- `rcases`,
- `by_contra`,
- `field_simp`,
- multi-step `calc`,
- nontrivial rewriting through invariance lemmas.

A good file architecture would be:

1. `excessMoment_conj_invariant`
2. `avgExcessMoment_eq_class_sum`
3. `avgExcessMoment_odd_eq_zero`
4. `avgExcessMoment_even_le_const_div` or a rigorously weaker certified upper bound
5. one cross-domain theorem such as `avg_truncatedExcessPartitionFn_bound`

Even if the full `O(1/n)` theorem requires one intermediate weaker lemma first, that is acceptable — but the file must still contain at least 3 nontrivial proven theorems.

---

## Suggested Lean 4 theorem signatures

These are targets, not shackles; adapt names and codomains to actual catalog conventions.

```lean
def excessMoment {n : ℕ} (σ τ : Equiv.Perm (Fin n)) (m : ℕ) : ℚ :=
  momentKernel σ τ m - freeGroupReturnMoment 2 m

theorem excessMoment_conj_invariant
    {n m : ℕ} (ρ σ τ : Equiv.Perm (Fin n)) :
    excessMoment (ρ * σ * ρ⁻¹) (ρ * τ * ρ⁻¹) m = excessMoment σ τ m := by
  ...

def avgExcessMoment (n m : ℕ) : ℚ := ...

theorem avgExcessMoment_eq_class_sum
    (n m : ℕ) :
    avgExcessMoment n m = classAveragedExcessMoment n m := by
  ...

theorem avgExcessMoment_odd_eq_zero
    (n r : ℕ) :
    avgExcessMoment n (2 * r + 1) = 0 := by
  ...

theorem avgExcessMoment_even_le_const_div
    (k : ℕ) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 2 ≤ n →
      |(avgExcessMoment n (2 * k) : ℝ)| ≤ C / n := by
  ...
```

If you cannot yet formalize the full asymptotic theorem, prove a certified finite-`n` explicit inequality of the form
```lean
|(avgExcessMoment n (2 * k) : ℝ)| ≤ explicitConst k n
```
and then use `demo.py` to show numerically that `explicitConst k n ~ C_k / n`. But be ambitious: the target is the actual `1/n` law.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean development** with the new definitions and at least 3 nontrivial theorems.
2. **A verified algorithm or computational method**:
   - an executable class-sum algorithm for `avgExcessMoment n (2*k)` using conjugacy-class compression,
   - or a certified evaluator for truncated excess partition functions.
3. **`demo.py`**:
   - compute the average excess moment for random or exhaustive pairs in `S_n` for `n = 5, ..., 12`,
   - fit a regression against `1/n`,
   - visualize `A_{n,k}` and `n A_{n,k}`.
4. **`RESEARCH_PAPER.md`**:
   - standalone scientific paper,
   - explain the free-group baseline, the conjugacy compression, the representation-theoretic correction mechanism, and the significance for random Cayley expanders.
5. **`ARTICLE.md`**:
   - Scientific American style,
   - explain why random symmetry should mimic a free group and why tiny `1/n` deviations matter,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 directions:
   - each must include the exact sentences:
     - “The key insight is ...”
     - “Why now?”
   - at least one direction must bridge to another domain, such as statistical mechanics, quantum information, or asymptotic combinatorics.

---

## Scientific significance to emphasize

If successful, this project would do more than bound a moment. It would create a **formal asymptotic dictionary**:
- free-group law = universal infinite-`n` limit,
- standard representation = first finite-size correction,
- conjugacy compression = computational tractability,
- spectral moments = observable bridge to expansion.

This is the seed of a new field: **certified asymptotic representation theory for random combinatorial structures**.

The deeper story is that randomness in `S_n` is not structureless. Its first deviation from universality is encoded in a canonical irreducible representation. That is exactly the kind of theorem that changes how people think.

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
