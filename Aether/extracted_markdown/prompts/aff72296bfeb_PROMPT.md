Soli Deo Gloria

## Assignment: Direction 4 — Shadow-Based Circuit Lower Bounds for the Permanent

**Mode:** `prove` with a calibrated fallback to `discover` if the full exponential lower bound resists formal proof.

Your task is to attack the permanent through the shadow framework at the level of **support combinatorics**, not by incremental circuit manipulations. The central object is the support of the permanent polynomial,
\[
\operatorname{Perm}_n(X)=\sum_{\sigma\in S_n}\prod_{i=1}^n X_{i,\sigma(i)},
\]
whose monomial support is canonically identified with the set of permutation matrices, equivalently perfect matchings in \(K_{n,n}\).

The visionary target is to convert this support geometry into a **certified arithmetic circuit lower bound** via the non-cancellation/shadow machinery in the catalog. This would create a new bridge:
\[
\text{combinatorics of permutation supports}
\;\Longrightarrow\;
\text{shadow expansion}
\;\Longrightarrow\;
\text{non-cancellation certificate}
\;\Longrightarrow\;
\text{arithmetic circuit lower bounds}.
\]

The full conjecture is deliberately audacious. But you must not stop at a speculative statement: formalize the combinatorial core, prove several genuinely nontrivial theorems, extract a verified algorithm, and isolate a falsifiable computational prediction.

---

## Core Mathematical Program

### Central conjectural theorem
Let `suppPerm n` denote the family of supports of degree-`n` monomials appearing in the permanent, viewed as subsets of the variable set
\[
\{(i,j)\mid i,j\in \mathrm{Fin}\ n\}.
\]
Let `shadow₂` be the 2-shadow operator sending a family of `n`-element subsets to the family of all `(n-2)`-element subsets contained in some member.

**Grand Conjecture.**
For all \(n\ge 3\),
\[
|\mathrm{Sh}_2(\mathrm{suppPerm}(n))| \ge 2^{n/2},
\]
and the support family `suppPerm n` satisfies the non-cancellation certificate from
`Bridges/Catalog/Speculative/AutoResearch/NonCancellationCertificate.lean`.
Consequently, every arithmetic circuit computing `Perm_n` has size at least
\[
\frac{2^{n/2}}{\mathrm{poly}(n)}.
\]

This would amount to a paradigm-shifting route toward Valiant-style lower bounds: not via determinant identities, shifted partial derivatives, or geometric complexity theory alone, but via **support-shadow expansion**.

---

## Precise formal targets

You should introduce a new combinatorial structure capturing partial permutation patterns, because this is the natural invariant beneath the 2-shadow.

### Novel definition to introduce
Define a structure representing a **partial permutation support**: a set of matrix positions with no repeated row and no repeated column.

Suggested Lean-level concept:
```lean
structure PartialPermSupport (n : ℕ) where
  cells : Finset (Fin n × Fin n)
  row_injective :
    ∀ ⦃a b : Fin n × Fin n⦄, a ∈ cells → b ∈ cells → a.1 = b.1 → a = b
  col_injective :
    ∀ ⦃a b : Fin n × Fin n⦄, a ∈ cells → b ∈ cells → a.2 = b.2 → a = b
```

This is not merely bookkeeping: it is the right interface between
- permutation monomial supports,
- matchings in bipartite graphs,
- rook placements / transversal matroids,
- and Hall-type completion arguments.

Also define:
```lean
def isPermutationSupport (s : Finset (Fin n × Fin n)) : Prop := ...
def permSupportFamily (n : ℕ) : Finset (Finset (Fin n × Fin n)) := ...
def twoShadow (F : Finset (Finset α)) : Finset (Finset α) := ...
def completionCount (p : PartialPermSupport n) : ℕ := ...
def defectRows (p : PartialPermSupport n) : Finset (Fin n) := ...
def defectCols (p : PartialPermSupport n) : Finset (Fin n) := ...
```

The key new invariant should be a **completion profile**: for a partial permutation support \(p\), how many permutation supports contain it? This is where representation theory and matching theory enter.

---

## Theorem statements you should aim to formalize

You must prove at least 3 deep theorems. The following package is the right scale.

### Theorem 1: Characterization of the 2-shadow of permanent support
A subset of size \(n-2\) lies in the 2-shadow of the permanent support iff it is a partial permutation support of size \(n-2\).

Mathematical statement:
\[
\forall n\ge 2,\quad
\mathrm{Sh}_2(\mathrm{suppPerm}(n))
=
\{\,s\subseteq [n]\times[n] : |s|=n-2 \text{ and } s \text{ has distinct rows and columns}\,\}.
\]

Suggested Lean signature:
```lean
theorem mem_twoShadow_permSupport_iff
    {n : ℕ} (hn : 2 ≤ n) (s : Finset (Fin n × Fin n)) :
    s ∈ twoShadow (permSupportFamily n) ↔
      s.card = n - 2 ∧ isPartialPermSupport s := by
```

Why this matters:
This theorem strips away the algebra and reveals the pure combinatorial heart: the 2-shadow is exactly the family of size-`n-2` nonattacking rook placements. Once formalized, counting shadow size becomes a counting problem for partial matchings.

This is already a breakthrough in architecture: it converts a speculative lower-bound certificate into a concrete enumerative object.

---

### Theorem 2: Exact counting formula for the 2-shadow
Every partial permutation support of size \(n-2\) is determined by the two missing rows, the two missing columns, and a bijection between the remaining \(n-2\) rows and columns. Therefore
\[
|\mathrm{Sh}_2(\mathrm{suppPerm}(n))|
=
\binom{n}{2}^2 (n-2)!.
\]

Suggested Lean signature:
```lean
theorem card_twoShadow_permSupport
    {n : ℕ} (hn : 2 ≤ n) :
    (twoShadow (permSupportFamily n)).card
      = (Nat.choose n 2)^2 * Nat.factorial (n - 2) := by
```

Equivalent asymptotic corollary:
\[
|\mathrm{Sh}_2(\mathrm{suppPerm}(n))| \ge 2^{n/2}
\quad\text{for all sufficiently large }n,
\]
indeed for all \(n\ge 4\) after a short verification.

Suggested Lean signature:
```lean
theorem twoShadow_permSupport_exp_lower_bound
    {n : ℕ} (hn : 4 ≤ n) :
    2^(n / 2) ≤ (twoShadow (permSupportFamily n)).card := by
```

Why this matters:
This goes beyond the original conjecture: not only lower-bounding the shadow, but computing it **exactly**. If successful, this would transform the permanent shadow-growth question from “mysterious” to “structurally rigid.”

This is the single most promising theorem in the brief.

---

### Theorem 3: Completion multiplicity is constant and equal to 2
Every \((n-2)\)-partial permutation support extends to exactly two permutation supports.

Mathematical statement:
If \(p\) is a partial permutation support of size \(n-2\), then the missing rows are \(\{r_1,r_2\}\), the missing columns are \(\{c_1,c_2\}\), and there are exactly two completions:
\[
\{(r_1,c_1),(r_2,c_2)\},\qquad \{(r_1,c_2),(r_2,c_1)\}.
\]

Suggested Lean signature:
```lean
theorem completionCount_eq_two
    {n : ℕ} (hn : 2 ≤ n) (p : PartialPermSupport n)
    (hcard : p.cells.card = n - 2) :
    completionCount p = 2 := by
```

Why this matters:
This theorem explains the shadow count and suggests a deeper regularity phenomenon: the permanent support family has an unexpectedly uniform local geometry in codimension 2. That uniformity is exactly the sort of property that a non-cancellation certificate can exploit.

---

### Theorem 4: Cross-domain bridge to bipartite matching / Hall theory
Translate the previous statements into the language of matchings in the complete bipartite graph \(K_{n,n}\): the 2-shadow consists precisely of matchings of size \(n-2\), and each such matching extends to a perfect matching in exactly two ways.

Suggested Lean signature:
```lean
theorem size_n_sub_two_matchings_in_Knn_extend_exactly_two_ways
    {n : ℕ} (hn : 2 ≤ n) :
    ∀ M : Finset (Fin n × Fin n),
      isMatching M →
      M.card = n - 2 →
      numberOfPerfectMatchingExtensions M = 2 := by
```

Why this matters:
This is your mandatory cross-domain theorem. It connects algebraic complexity to:
- extremal combinatorics,
- graph theory,
- matching theory,
- and potentially statistical physics via dimer models.

This theorem also makes the work legible to communities outside circuit complexity.

---

### Theorem 5: A certificate transfer theorem
Assuming the exact hypotheses of the catalog’s non-cancellation framework, show that the exact shadow formula for permanent support implies the corresponding circuit lower bound theorem.

This theorem should explicitly import and apply the catalog result, not re-prove the abstract machinery.

Suggested Lean signature schematic:
```lean
theorem permanent_lower_bound_from_shadow_certificate
    {n : ℕ} (hn : 4 ≤ n)
    (hcert : NonCancellationCertificate (permPolynomial n))
    :
    lowerBoundFromShadow (permPolynomial n)
      ((Nat.choose n 2)^2 * Nat.factorial (n - 2)) := by
```

You may need to adapt the exact names to the catalog API in:
- `Algebra/AlgebraicCircuitComplexity.lean`
- `Bridges/Catalog/Speculative/AutoResearch/NonCancellationCertificate.lean`

Why this matters:
This is the decisive synthesis theorem. It is the step that turns combinatorics into complexity.

---

## Most promising proof architecture

### Strategy A: Direct support-combinatorics via missing rows/columns
This is the most promising route.

1. **Characterize members of the 2-shadow** as subsets of size `n-2` with no repeated row/column.
   - Forward direction: removing two edges from a permutation graph preserves injectivity.
   - Reverse direction: any such partial support misses exactly two rows and two columns; add one of the two bijections between the missing row-set and missing column-set.

2. **Count such subsets exactly**.
   - Choose the missing rows: \(\binom n2\).
   - Choose the missing columns: \(\binom n2\).
   - Choose a bijection between the remaining rows and columns: \((n-2)!\).

3. **Deduce lower bounds** by elementary inequalities comparing
   \[
   \binom{n}{2}^2 (n-2)!
   \]
   to \(2^{n/2}\), and then feed the exact count into the non-cancellation framework.

Why Strategy A is best:
It isolates a finite rigid combinatorial mechanism and should formalize cleanly in Lean with `Fin`, `Finset`, cardinality lemmas, and factorial/binomial identities. It avoids heavy representation theory while still enabling later bridges.

---

### Strategy B: Matching-theoretic proof through Hall completion
1. Reinterpret permutation supports as perfect matchings in \(K_{n,n}\).
2. Show that deleting two edges from a perfect matching yields a matching of size \(n-2\).
3. Conversely, any matching of size \(n-2\) in \(K_{n,n}\) leaves exactly two unmatched vertices on each side, and there are exactly two perfect matching completions.

Why this is strong:
It makes the theorem conceptually transparent and naturally generalizable to immanants, Latin transversals, and dimer partition functions. It also gives a clean cross-domain narrative.

Potential drawback:
Depending on available graph/matching infrastructure in Mathlib, direct graph formalization may be heavier than the support-based approach. Use this as the conceptual guide even if the Lean proof is written with `Finset (Fin n × Fin n)`.

---

### Strategy C: Symmetric-group orbit method
1. Show `suppPerm n` is a single \(S_n\)-orbit under column permutation.
2. Identify the 2-shadow as an induced orbit decomposition of partial injective maps.
3. Count orbit representatives by stabilizer computations.

Why this is interesting:
This gives the representation-theoretic bridge and may later connect to immanants and character-sensitive lower bounds.

Why it is less promising as the first proof:
It is elegant but likely heavier in formal group-action machinery than necessary for the initial breakthrough. Use it for exposition or future directions.

---

## What to build from the catalog

You must explicitly leverage the existing infrastructure.

### From `Algebra/AlgebraicCircuitComplexity.lean`
Use the circuit model and lower-bound statement already formalized there. Do not create an ad hoc notion of circuit size if the catalog already provides one. Your contribution should be the **new combinatorial input** for the permanent.

### From `Bridges/Catalog/Speculative/AutoResearch/NonCancellationCertificate.lean`
Extract the exact hypothesis required to transfer a shadow lower bound into a circuit lower bound. Then prove that the permanent support satisfies the combinatorial side of those hypotheses, or isolate the remaining obstruction precisely if the full certificate is still out of reach.

In particular:
- identify the formal theorem that turns `|Sh₂(supp f)|` growth into a lower bound;
- prove the permanent’s support family satisfies the requisite shadow/cardinality hypotheses;
- if the full non-cancellation certificate has algebraic sign conditions, formalize the permanent’s positivity as the relevant simplification.

This is crucial: the project is not merely to count a family, but to connect that count to the catalog’s certified lower-bound pipeline.

---

## Deep proof tactics requirement

Your file must contain at least 3 theorems proved with genuinely multi-step reasoning. Suitable proof patterns here include:

- **induction** on `n` for lower-bound inequalities involving factorial/binomial growth;
- **rcases** on the missing rows/columns extracted from cardinality constraints;
- **by_contra** to prove uniqueness of the missing-row/missing-column decomposition;
- **field_simp** or semiring normalization for factorial/binomial identities if needed;
- **calc** chains for cardinality equalities and inequalities.

Examples of where depth should appear:
- proving every size `n-2` partial permutation support has exactly two completions;
- proving the exact counting formula;
- proving the asymptotic lower bound from the exact formula;
- proving the matching-theoretic equivalence.

Avoid any theorem whose essence is finite enumeration.

---

## Falsifiable conjecture with computational test

You must include at least one explicit conjecture that could fail.

### Recommended conjecture: higher-shadow exact formula
For fixed \(k\le n\), let \(\mathrm{Sh}_k\) denote the \(k\)-shadow down from size \(n\) to size \(n-k\). Then:
\[
|\mathrm{Sh}_k(\mathrm{suppPerm}(n))|
=
\binom{n}{k}^2 (n-k)!.
\]

Equivalent interpretation: the \(k\)-shadow consists exactly of partial permutation supports of size \(n-k\).

Suggested Lean conjecture form:
```lean
conjecture card_kShadow_permSupport
    (n k : ℕ) (hk : k ≤ n) :
    (kShadow k (permSupportFamily n)).card
      = (Nat.choose n k)^2 * Nat.factorial (n - k)
```

**Computational test:** verify this formula for all pairs
\[
3 \le n \le 8,\quad 0 \le k \le n
\]
by explicit generation of permutation supports and shadows in `demo.py`.

Why this is scientifically useful:
- If true, it reveals a full shadow geometry for the permanent support.
- If false for some generalized notion in the catalog, the counterexample will expose the exact obstruction.
- It suggests an avenue toward support-based lower bounds at multiple codimensions, not only codimension 2.

A second, even bolder conjecture you may state if supported computationally:

### Conjecture: support-shadow extremality among multilinear \(n!\)-term families
Among all families of \(n\)-element subsets of \([n]\times[n]\) satisfying row/column injectivity and having cardinality \(n!\), the permanent support minimizes no nontrivial low-order shadow; equivalently, it is shadow-expanding rather than compressed.

This is speculative but computationally testable for small \(n\).

---

## Cross-domain connections to emphasize

You must explicitly articulate at least one theorem bridging domains. Good bridges here are:

1. **Combinatorics ↔ Computational complexity**  
   Exact shadow counts become circuit lower bounds.

2. **Bipartite matching / Hall theory ↔ Algebraic complexity**  
   Permanent support is the perfect-matching complex of \(K_{n,n}\).

3. **Representation theory of \(S_n\) ↔ Support geometry**  
   Partial permutation supports form orbit families under row/column permutations; the shadow count is an orbit-counting phenomenon.

4. **Statistical physics / dimer models ↔ Permanent support**  
   The permanent enumerates perfect matchings; the 2-shadow enumerates near-perfect matchings with exactly two monomers on each side. This suggests a bridge between circuit lower bounds and monomer-dimer combinatorics.

This last bridge is particularly fertile and surprising. Even a modest formal theorem here could open a new language for lower bounds.

---

## Application keywords

Include these explicitly in your writeup and metadata-style summaries:

**Application keywords:** arithmetic circuit complexity, permanent polynomial, VP vs VNP, shadow method, non-cancellation certificate, permutation matrices, bipartite matchings, Hall theorem, rook placements, symmetric group, monomer-dimer model, support geometry, exact enumeration, lower bounds.

---

## Deliverables you must produce

You must produce **all** of the following.

### 1. Lean file with new definitions and theorems
It must include:
- at least one novel definition, preferably `PartialPermSupport` and a shadow/completion invariant;
- at least 3 nontrivial theorems with deep proof tactics;
- at least one cross-domain theorem;
- one explicit falsifiable conjecture.

Minimize `sorry`. If a major theorem remains blocked by a catalog interface mismatch, prove the full combinatorial theorem package anyway and isolate the precise missing lemma.

### 2. Verified algorithm / computational method
Implement a verified or semi-verified procedure that:
- generates `permSupportFamily n`,
- computes `twoShadow (permSupportFamily n)`,
- computes its cardinality,
- computes completion counts for partial supports,
- checks the exact formula
  \[
  |\mathrm{Sh}_2|=\binom{n}{2}^2 (n-2)!.
  \]

If possible, generalize to `kShadow`.

This is mandatory: not just theorem statements, but a computational engine.

### 3. `demo.py`
Provide an interactive script that:
- computes `|Sh₂(supp(Perm_n))|` for `n = 2,3,4,5,6,7`,
- compares with \(\binom{n}{2}^2 (n-2)!\),
- prints completion multiplicity statistics,
- tests the higher-shadow conjecture for small `n, k`,
- visualizes partial permutation supports / matchings if feasible.

The demo should make the phenomenon vivid.

### 4. `RESEARCH_PAPER.md`
This must be a standalone scientific document. A reader with no access to the code must understand:
- the permanent support viewpoint,
- the exact 2-shadow theorem,
- why the counting formula is surprising,
- how it interfaces with non-cancellation certificates,
- what is proved versus conjectural,
- what new research directions this opens.

Do not write this as project notes; write it as a coherent paper.

### 5. `ARTICLE.md`
Write in Scientific American style. Explain:
- what the permanent is,
- why lower bounds matter,
- how “shadows” of permutation patterns encode hidden structure,
- why exact shadow counting is conceptually new.

Taboo: do **not** focus on formal verification machinery. Focus on the mathematics and its significance.

### 6. `FUTURE_DIRECTIONS.md`
Provide 3–5 original research directions. Each direction must include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- dimer models / statistical mechanics,
- matroid theory,
- immanants and character theory,
- extremal set theory,
- tropical or geometric complexity.

---

## Concrete implementation suggestions in Lean 4

Use finite types aggressively:
- matrix positions as `Fin n × Fin n`,
- supports as `Finset (Fin n × Fin n)`.

For permanent support, you may define:
```lean
def permGraph {n : ℕ} (σ : Equiv.Perm (Fin n)) : Finset (Fin n × Fin n) := ...
```
and then
```lean
def permSupportFamily (n : ℕ) : Finset (Finset (Fin n × Fin n)) := ...
```

For partial injectivity:
```lean
def isPartialPermSupport {n : ℕ} (s : Finset (Fin n × Fin n)) : Prop :=
  (∀ ⦃a b⦄, a ∈ s → b ∈ s → a.1 = b.1 → a = b) ∧
  (∀ ⦃a b⦄, a ∈ s → b ∈ s → a.2 = b.2 → a = b)
```

For shadows:
```lean
def twoShadow {α : Type _} [DecidableEq α]
    (F : Finset (Finset α)) : Finset (Finset α) :=
  F.biUnion (fun s => s.powersetLen (s.card - 2))
```
or a specialized exact-cardinality-downshadow definition adapted to the catalog.

You may need a more controlled definition if `powersetLen` creates arithmetic side conditions. That is acceptable; clarity beats cleverness.

For counting, it may be cleaner to define a bijection between:
- elements of `twoShadow (permSupportFamily n)`,
and
- triples `(R, C, φ)` where `R` and `C` are 2-element subsets of `Fin n` and `φ` is a permutation of the complement.

This bijection is likely the cleanest path to the exact cardinality formula.

---

## What would count as a breakthrough here

A genuine success is **not** merely “the conjecture holds for n ≤ 7 by brute force.”  
A genuine success is one of the following:

1. You prove
   \[
   |\mathrm{Sh}_2(\mathrm{suppPerm}(n))|=\binom n2^2 (n-2)!,
   \]
   and formally transfer this into the catalog’s lower-bound framework under its stated certificate hypotheses.

2. You prove the exact combinatorial theorem and isolate the only remaining obstacle to a circuit lower bound as a sharply formulated algebraic certificate lemma.

3. You discover the stronger `k`-shadow formula and verify it computationally, thereby opening a whole hierarchy of support-based lower bounds.

Any of these would reframe the permanent lower-bound problem in a new and unexpectedly rigid combinatorial language.

Be bold: the point is not to timidly formalize folklore, but to expose a hidden exact structure in one of complexity theory’s most central objects.

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
