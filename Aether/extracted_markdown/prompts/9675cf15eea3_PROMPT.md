## Assignment: Erdős–Straus Conjecture as a Formal Egyptian-Fraction Geometry Program

**Mode:** `prove` + `discover`

You are not being asked for a toy verification of small cases. You are being asked to formalize a **structural theory of 3-term Egyptian decompositions of `4/n`** that pushes beyond brute force and creates reusable machinery for additive Diophantine representation in Lean 4.

The core ambition is to formalize a mathematically meaningful slice of the Erdős–Straus landscape:
1. **infinite parametric families** of exact decompositions,
2. **closure/transfer principles** turning one solution into many,
3. **a verified search algorithm** for bounded computation,
4. **cross-domain interpretation** of these decompositions as a discrete geometric/combinatorial object.

Your work should make it obvious how a future attack on the full conjecture could be organized formally.

---

## Central theorem targets

You should prove at least **3 substantial theorems**, with multi-step proofs using induction, `rcases`, `by_contra`, `field_simp`, divisibility arguments, and `calc`. Avoid any theorem whose content collapses to finite enumeration.

### New core definition

Define a new structure capturing Egyptian decompositions of `4/n`:

```lean
structure ESDecomposition (n : ℕ) where
  x y z : ℕ
  hx : 1 ≤ x
  hy : 1 ≤ y
  hz : 1 ≤ z
  eqn : (4 : ℚ) / n = (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z
```

Also define a denominator-cleared predicate, which is often better for proof search:

```lean
def ESWitness (n x y z : ℕ) : Prop :=
  1 ≤ x ∧ 1 ≤ y ∧ 1 ≤ z ∧
  (4 * x * y * z : ℤ) = (n : ℤ) * (x * y + x * z + y * z)
```

Then prove an equivalence theorem between the rational and cleared forms under positivity assumptions.

### Theorem 1: Universal even family

A first deep theorem should be a **uniform exact family for all even denominators**.

**Mathematical statement:**
For every `m ≥ 1`,
\[
\frac{4}{2m} = \frac{1}{m} + \frac{1}{2m} + \frac{1}{2m}.
\]
Hence every even `n ≥ 2` satisfies the Erdős–Straus equation.

**Lean target:**
```lean
theorem erdos_straus_even
    (m : ℕ) (hm : 1 ≤ m) :
    ESDecomposition (2 * m)
```

You should also derive the existential corollary:
```lean
theorem erdos_straus_of_even
    (n : ℕ) (hn : 2 ≤ n) (he : Even n) :
    ∃ d : ESDecomposition n, True
```

This is elementary mathematically, but in Lean it should be developed as part of a reusable exact framework, not as an isolated arithmetic trick.

### Theorem 2: Universal residue-class family `n ≡ 3 [4]`

A nontrivial infinite family:
for every `k ≥ 0`,
\[
\frac{4}{4k+3}
=
\frac{1}{k+1}
+
\frac{1}{(k+1)(4k+3)}
+
\frac{1}{(k+1)(4k+3)}.
\]

Indeed,
\[
\frac{1}{k+1} + \frac{2}{(k+1)(4k+3)}
=
\frac{4k+3+2}{(k+1)(4k+3)}
=
\frac{4(k+1)}{(k+1)(4k+3)}
=
\frac{4}{4k+3}.
\]

**Lean target:**
```lean
theorem erdos_straus_mod4_eq3
    (k : ℕ) :
    ESDecomposition (4 * k + 3)
```

This is an important theorem because it eliminates one full odd residue class by a uniform symbolic construction.

### Theorem 3: Divisor-lifting / multiplicative transfer principle

The most valuable theorem in the file should be a **solution transfer principle**. If `4/n` has a decomposition, then certain multiplicative modifications of `n` also do.

A clean version to target:

If
\[
\frac{4}{n} = \frac{1}{x} + \frac{1}{y} + \frac{1}{z},
\]
then for every `k ≥ 1`,
\[
\frac{4}{kn} = \frac{1}{kx} + \frac{1}{ky} + \frac{1}{kz}.
\]

**Lean target:**
```lean
theorem ESDecomposition.scale
    {n : ℕ} (d : ESDecomposition n) (k : ℕ) (hk : 1 ≤ k) :
    ESDecomposition (k * n)
```

This theorem is strategically powerful: it turns seed families into infinite cones of solutions and creates a formal mechanism for “covering sets” of denominators.

You should also prove the denominator-cleared version:

```lean
theorem ESWitness.scale
    {n x y z : ℕ} (h : ESWitness n x y z) (k : ℕ) (hk : 1 ≤ k) :
    ESWitness (k * n) (k * x) (k * y) (k * z)
```

### Theorem 4: A congruence-cover theorem

Use the previous families plus scaling to prove a genuine covering statement such as:

- every `n` divisible by `2` has a decomposition,
- every `n` congruent to `3 mod 4` has a decomposition,
- therefore every `n ≥ 2` outside the residue class `1 mod 4` and odd is covered.

A precise theorem:

```lean
theorem erdos_straus_cover_large_subfamily
    (n : ℕ) (hn : 2 ≤ n)
    (hcover : Even n ∨ n % 4 = 3) :
    ∃ d : ESDecomposition n, True
```

This is not the full conjecture, but it is already a formal theorem about a density-`3/4` set of denominators.

### Theorem 5: Verified bounded search correctness

Define a computational search procedure for bounded witnesses:
```lean
def searchES (B n : ℕ) : Option (ℕ × ℕ × ℕ) := ...
```

Then prove **soundness**:
```lean
theorem searchES_sound
    {B n x y z : ℕ}
    (h : searchES B n = some (x,y,z)) :
    ESWitness n x y z
```

If feasible, also prove a **relative completeness** statement:
if a witness exists with `x,y,z ≤ B`, then `searchES B n` finds one.

```lean
theorem searchES_complete
    {B n : ℕ}
    (hB : ∃ x y z, ESWitness n x y z ∧ x ≤ B ∧ y ≤ B ∧ z ≤ B) :
    ∃ x y z, searchES B n = some (x,y,z)
```

This gives you a verified experimental engine, not just a theorem statement.

---

## Precise full-conjecture framing

You should explicitly formalize the global conjecture as a Lean proposition, even if not fully proved:

```lean
def ErdosStrausConjecture : Prop :=
  ∀ n : ℕ, 2 ≤ n → ∃ x y z : ℕ,
    1 ≤ x ∧ 1 ≤ y ∧ 1 ≤ z ∧
    (4 : ℚ) / n = (1 : ℚ) / x + (1 : ℚ) / y + (1 : ℚ) / z
```

And a bounded computational verification proposition:

```lean
def VerifiedUpTo (N : ℕ) : Prop :=
  ∀ n : ℕ, 2 ≤ n → n ≤ N →
    ∃ x y z : ℕ, ESWitness n x y z
```

Then prove a theorem connecting the algorithm to bounded verification.

---

## Proof architecture: 3 viable strategies

### Strategy A: Rational-to-integer bridge via denominator clearing
This is likely the most promising primary route.

1. Define `ESWitness n x y z` using the cleared equation
   \[
   4xyz = n(xy+xz+yz).
   \]
2. Prove equivalence with the rational statement under positivity assumptions using `field_simp`, coercion lemmas, and positivity facts.
3. Prove parametric families in the integer-cleared form first, then transport them to `ESDecomposition`.

**Why promising:** Lean handles polynomial identities over `ℤ`/`ℕ` more robustly than repeated rational simplification. This route also interfaces naturally with search algorithms.

### Strategy B: Symmetry and ordered normal form
1. Define an equivalence notion under permutation of `(x,y,z)`.
2. Prove that any witness can be reordered so `x ≤ y ≤ z`.
3. Use the ordered form to reduce the search space and derive monotonic inequalities, e.g. bounds on `x` from
   \[
   \frac{4}{n} \le \frac{3}{x}.
   \]

**Why promising:** This supports the verified search completeness theorem and gives a geometric interpretation of the solution set as lattice points in a constrained region.

### Strategy C: Congruence families and multiplicative closure
1. Build explicit symbolic families for residue classes.
2. Prove scaling/transfer lemmas.
3. Package them into a “cover theorem” saying large arithmetic subsets of `ℕ` satisfy the conjecture.

**Why promising:** This most directly mirrors classical number-theoretic progress and turns isolated identities into a reusable formal covering framework.

**Recommended approach:** Use **Strategy A as the backbone**, then combine with **Strategy C** for the strongest theorem package. Add selected components of **Strategy B** to justify the algorithm and search bounds.

---

## Deeper mathematical insight to emphasize

The Erdős–Straus problem is not just a recreational Diophantine curiosity. In formal terms, it is about the geometry of the affine cubic surface
\[
4xyz = n(xy+xz+yz)
\]
inside the positive integer lattice. For each fixed `n`, the set of Egyptian decompositions is the set of positive lattice points on a rational cubic surface. Your file should treat this as a **discrete arithmetic geometry problem**, not merely as fraction manipulation.

This viewpoint suggests introducing a novel concept such as:

```lean
def ESSurface (n : ℕ) : Set (ℕ × ℕ × ℕ) :=
  {p | ESWitness n p.1 p.2.1 p.2.2}
```

or an ordered version:
```lean
def OrderedESWitness (n x y z : ℕ) : Prop :=
  ESWitness n x y z ∧ x ≤ y ∧ y ≤ z
```

Then prove at least one structural theorem about this set, e.g. scaling invariance or symmetry under permutation.

---

## Cross-domain connection requirement

You must include at least one theorem connecting this number-theoretic problem to a different domain.

### Best option: discrete geometry / combinatorial optimization
Interpret `ESWitness n x y z` as integer points on a cubic surface and prove a bounding theorem for ordered witnesses:
if `OrderedESWitness n x y z`, then
\[
x \le \frac{3n}{4}
\]
in a suitable natural-number inequality form.

A Lean-friendly version:
```lean
theorem ordered_witness_first_denominator_bound
    {n x y z : ℕ}
    (h : OrderedESWitness n x y z) :
    4 * x ≤ 3 * n
```

This is a genuine bridge from number theory to discrete geometry / lattice-point analysis.

### Alternative cross-domain option: information/energy interpretation
Using `jointDist_sum_one` as conceptual inspiration, interpret
\[
\frac{n}{4x}, \frac{n}{4y}, \frac{n}{4z}
\]
as a normalized resource split summing to `1` when a witness exists. Then prove the exact normalization identity in `ℚ`:

```lean
theorem witness_normalized_mass_sum_one
    {n x y z : ℕ}
    (h : ESDecomposition n) :
    ((n : ℚ) / (4 * h.x)) + ((n : ℚ) / (4 * h.y)) + ((n : ℚ) / (4 * h.z)) = 1
```

This is a rigorous bridge to probability/simplex geometry: Egyptian decompositions correspond to 3-atom rational distributions constrained by reciprocal denominators.

### More speculative bridge
Use `direct_cross_sum_congruent` as a template for constructing congruence-stable families, and mention `gradient_sum_bound` / `ultrametric_sum_zero_dominant_bound` as inspiration for “dominant term” inequalities in ordered witnesses. Do not force a fake dependency, but explicitly note that these catalog theorems motivate a transfer principle: arithmetic representations often become tractable after passing to a structured invariant.

---

## Building on catalog theorems

You are not expected to shoehorn irrelevant theorems into the proof, but you should **explicitly use the catalog as methodological precedent**:

- `direct_cross_sum_congruent` suggests proving **closure of witness families under congruence-preserving arithmetic constructions**.
- `sum_product` suggests organizing the search algorithm and parametric families around algebraic factorization identities rather than direct brute force.
- `jointDist_sum_one` motivates the normalized-mass theorem above, turning witness equations into simplex identities.
- `gradient_sum_bound` and `ultrametric_sum_zero_dominant_bound` suggest a strategy of deriving **dominance bounds** on ordered denominators, which can dramatically prune search.
- `exists_refinement_cell_for_pair` is a model for proving existence by partitioning a complicated space into controlled cells; analogously, partition denominators by congruence classes and cover each cell with a parametric family when possible.

Use these as conceptual scaffolding to make the development feel like part of a broader formal science program.

---

## Conjectures with testable predictions

You must include at least one falsifiable conjecture with a clear computational test.

### Conjecture A: ordered small-denominator bound
For every `n ≥ 2`, there exists an ordered witness with
\[
x \le n.
\]

Lean declaration:
```lean
def ESOrderedSmallFirstDenominatorConjecture : Prop :=
  ∀ n : ℕ, 2 ≤ n →
    ∃ x y z : ℕ,
      OrderedESWitness n x y z ∧ x ≤ n
```

**Test:** run `searchES` over all `n ≤ N` with an ordered search and record whether a witness with `x ≤ n` is found. A single counterexample disproves it.

### Conjecture B: residue-class completeness by finite templates
There exists a finite family of polynomial/rational templates in `k` that covers every odd `n`.

**Test:** encode a library of templates and check whether every odd `n ≤ N` matches one. Failure at any `n` disproves that specific finite template family.

### Conjecture C: search-space sparsity
For ordered witnesses, the feasible region in `(x,y)` after solving for `z` has asymptotic density zero inside `[1,B]^2`.

**Test:** for fixed `n`, count candidate pairs `(x,y)` yielding integral positive `z`; compare counts against `B^2` numerically.

---

## Algorithmic deliverable

Produce a verified algorithm, not just theorem statements.

Recommended computational method:
1. Search over ordered pairs `x ≤ y ≤ B`.
2. Solve for `z` from
   \[
   z = \frac{nxy}{4xy - nx - ny},
   \]
   provided the denominator is positive and divides the numerator.
3. Verify positivity and exactness in the cleared equation.

This avoids cubic search and is mathematically meaningful.

Lean definitions may look like:
```lean
def candidateZ (n x y : ℕ) : Option ℕ := ...
def searchOrderedES (B n : ℕ) : Option (ℕ × ℕ × ℕ) := ...
```

Then prove soundness and, if feasible, bounded completeness.

---

## File-level expectations

Your Lean file should contain:
- the new structures/definitions (`ESDecomposition`, `ESWitness`, `OrderedESWitness`, conjecture defs),
- at least **3 nontrivial theorems** with real proof content,
- one cross-domain theorem,
- one verified algorithm theorem,
- no reliance on blind finite enumeration for the main mathematics.

Minimize `sorry`. If one remains, it should be only for a genuinely difficult completeness theorem, and all surrounding infrastructure should be complete.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean formalization** with theorems and verified algorithm.
2. **`FUTURE_DIRECTIONS.md`** containing **3–5 testable scientific hypotheses**, each falsifiable with a clear computational or formal test.
3. **`RESEARCH_PAPER.md`** as a standalone scientific paper explaining:
   - the formal problem,
   - the new definitions,
   - the proved families and transfer principles,
   - the algorithm,
   - the cross-domain interpretation,
   - what remains open.
4. **`ARTICLE.md`** in Scientific American style, accessible but accurate, explaining why Egyptian fractions secretly form a geometry of arithmetic surfaces.
5. **`demo.py`** that:
   - takes `n` as input,
   - tries explicit families first,
   - falls back to the verified search routine,
   - displays the resulting decomposition and checks the identity numerically/symbolically.

---

## Application keywords

Egyptian fractions; Erdős–Straus conjecture; formalized number theory; Diophantine geometry; cubic surfaces; lattice-point search; congruence covering; verified algorithms; symbolic computation; arithmetic combinatorics; rational parametrization; discrete geometry; simplex normalization; proof engineering in Lean 4.

---

## Final research vision

Do not treat this as “prove a few cases of a conjecture.” Treat it as the beginning of a **formal arithmetic geometry of reciprocal decompositions**. The breakthrough is not merely another family identity; it is a reusable Lean framework where:
- exact Egyptian-fraction identities become certified objects,
- congruence classes are covered by symbolic templates,
- search is mathematically reduced and formally verified,
- the problem is reinterpreted as geometry on integer cubic surfaces.

That is the kind of infrastructure from which a real attack on the full conjecture could emerge.

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
