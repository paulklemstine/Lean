## Assignment: Direction 5: Arrow-Depth Exponential Complexity

Soli Deo Gloria

### Mode: `prove`

You are to attack a structural complexity law for simple types that, if true, sharply reorganizes the semantics of higher-order programs:

> **Visionary Goal.** Show that the semantic quotient/state complexity of a simple type is governed primarily by its **arrow depth**, not by the full syntactic size of the type tree.

This is not a request for a cosmetic sharpening of an existing estimate. If successful, it would identify **depth** as the true controlling invariant behind the explosion of behavioral state spaces in typed lambda calculi, with consequences for minimization, symbolic semantics, descriptive complexity, and parameterized program analysis.

Build directly on:

- `Pythagorean/BisimMinimization.lean` for `typeStateBound`
- `Pythagorean/STLCDefs.lean` for `Ty.depth`, `Ty.complexity`

Minimize `sorry`. No trivial proofs by `native_decide`, `decide`, `norm_num`, or `rfl` unless the theorem itself is genuinely conceptually important.

---

## Core Mathematical Thesis

The existing `typeStateBound` is defined structurally and appears to depend heavily on the full type shape. The breakthrough conjecture is that this dependence can be compressed to a function of **arrow depth alone**.

A plausible strong form is:

\[
\exists c \ge 2,\ \forall A,\ \mathrm{typeStateBound}(A) \le c^{\mathrm{depth}(A)+1}.
\]

But do **not** assume the strongest form is true. Your mission is to determine the sharp frontier:

1. Prove the strongest theorem you can.
2. If the pure depth-only bound is false, isolate the exact obstruction.
3. Replace the false conjecture by a corrected invariant that is still dramatically smaller than full type size.

---

## New Definitions You Should Introduce

You must define at least one genuinely new concept not already present in the catalog. The most promising is a structural width parameter measuring how much branching survives at each depth.

### Proposed new definition 1: depth profile
Define a function counting the number of subtrees at each arrow level.

Informally:
- `depthProfile A k` measures the number of type nodes of residual depth `k`
- or alternatively, the number of arrow constructors encountered on level `k`

This creates a bridge between raw syntax and growth recurrences.

### Proposed new definition 2: layered arrow width
Define a compressed width parameter such as:

\[
\mathrm{arrowWidth}(A) := \max_d \#\{\text{subterms of } A \text{ at arrow-depth } d\}.
\]

or a recursively weighted variant adapted to the recurrence for `typeStateBound`.

### Proposed new definition 3: balancedness defect
Define a statistic measuring deviation from a chain type:
- chain-like types have small width and may satisfy single-exponential bounds;
- bushy types may force super-exponential growth.

One of these should become the central organizing invariant.

---

## Precise Theorem Targets

You need at least 3 nontrivial theorems. Here is the strongest mathematically coherent progression.

### Theorem 1: universal bound by complexity
First establish a clean structural upper bound that exposes the recurrence.

**Mathematical statement**
There exists an explicit constant \(C \ge 2\) such that for all simple types \(A\),
\[
\mathrm{typeStateBound}(A) \le C^{\mathrm{complexity}(A)+1}.
\]

This is not the final destination, but it is the baseline from which depth compression can be studied rigorously.

**Lean 4 target signature**
```lean
theorem typeStateBound_le_exp_complexity
    (C : ℕ) (hC : 2 ≤ C) :
    ∀ A : Ty, typeStateBound A ≤ C ^ (Ty.complexity A + 1)
```

If the exact constant `C` must be specialized, do so. A specialized theorem is better than a vague one:
```lean
theorem typeStateBound_le_two_pow_complexity :
    ∀ A : Ty, typeStateBound A ≤ 2 ^ (Ty.complexity A + 1)
```

This theorem should require genuine structural induction and nontrivial arithmetic.

---

### Theorem 2: depth-only bound for a nontrivial class of types
The global conjecture may fail for arbitrary bushy types. A field-opening result would be to prove that it **does hold on a maximal natural subclass**, such as chain types / unary-arrow spines / bounded-width types.

Define a predicate such as `ChainTy : Ty → Prop` or `ArrowWidthLe : ℕ → Ty → Prop`.

**Mathematical statement**
For all chain types \(A\),
\[
\mathrm{typeStateBound}(A) \le c^{\mathrm{depth}(A)+1}
\]
for an explicit constant \(c\).

**Lean 4 target signature**
```lean
def ChainTy : Ty → Prop := ...

theorem typeStateBound_le_exp_depth_of_chain
    (c : ℕ) (hc : 2 ≤ c) :
    ∀ A : Ty, ChainTy A → typeStateBound A ≤ c ^ (Ty.depth A + 1)
```

A stronger and more interesting variant is parameterized by width:

```lean
def arrowWidth : Ty → ℕ := ...

theorem typeStateBound_le_exp_depth_mul_width
    (c : ℕ) (hc : 2 ≤ c) :
    ∀ A : Ty, typeStateBound A ≤ (c * (arrowWidth A + 1)) ^ (Ty.depth A + 1)
```

This would be a major conceptual advance: **state complexity is controlled by depth plus a low-dimensional width invariant**.

---

### Theorem 3: impossibility or lower-bound obstruction for pure depth control
This is where the project becomes scientifically honest and mathematically strong. If a uniform depth-only upper bound is too optimistic, prove a lower-bound family demonstrating the obstruction.

Construct a family `bushy : ℕ → Ty` of fixed or linearly growing depth whose `typeStateBound` grows too fast for a naive depth-only bound.

**Mathematical statement**
There exists an explicit family \(B_n\) such that:
- \(\mathrm{depth}(B_n)\) grows linearly or remains controlled,
- but \(\mathrm{typeStateBound}(B_n)\) grows at least exponentially in a width parameter.

For example:
\[
\forall n,\quad \mathrm{typeStateBound}(B_n) \ge 2^n
\quad\text{and}\quad
\mathrm{depth}(B_n) \le n+1.
\]

Or stronger, if possible, produce a family showing no universal \(c^{\mathrm{depth}(A)}\) bound can hold.

**Lean 4 target signature**
```lean
def bushy : ℕ → Ty := ...

theorem bushy_depth_bound :
    ∀ n : ℕ, Ty.depth (bushy n) ≤ n + 1

theorem bushy_typeStateBound_lower :
    ∀ n : ℕ, 2 ^ n ≤ typeStateBound (bushy n)
```

If this can be sharpened to a formal counterexample to the original conjecture, do it:
```lean
theorem not_exists_uniform_exp_depth_bound :
    ¬ ∃ c : ℕ, ∀ A : Ty, typeStateBound A ≤ c ^ (Ty.depth A + 1)
```

That theorem would be spectacular. A negative answer of this quality is absolutely acceptable and scientifically valuable.

---

## Most Promising Research Split

There are two fundamentally different futures here, and you should determine which one is real.

### Path A: the conjecture is true after a clever recurrence analysis
This requires showing that the arrow constructor recurrence does not amplify branching as badly as naive size analysis suggests.

#### Proof strategy steps
1. **Normalize the recurrence.**
   Extract from `typeStateBound` a monotone recursive inequality for base and arrow cases. Rewrite multiplicative terms into additive inequalities on logarithms, or compare with a depth-indexed majorant sequence.
2. **Introduce a depth-profile induction.**
   Instead of ordinary induction on syntax, prove a stronger induction statement simultaneously controlling `typeStateBound`, `depth`, and your new width/profile parameter.
3. **Solve the recurrence explicitly.**
   Show that the majorant sequence satisfies a linear or affine recurrence in depth, yielding a singly exponential closed form.

This is the most exciting path if it works.

---

### Path B: the pure depth conjecture is false, but a width-refined theorem is true
This is, in my judgment, the most mathematically plausible and potentially more important result.

#### Proof strategy steps
1. **Construct extremal families.**
   Compare chain types, balanced binary types, and repeated self-embedding arrow trees.
2. **Identify the missing invariant.**
   Show by explicit examples that types of equal depth can have radically different `typeStateBound`, forcing a width/profile correction.
3. **Prove the corrected theorem.**
   Introduce `arrowWidth`, `depthProfile`, or `balancedDefect`, and prove an upper bound of the form
   \[
   \mathrm{typeStateBound}(A) \le F(\mathrm{depth}(A), \mathrm{arrowWidth}(A)).
   \]

This path is especially promising because it converts a likely-false folklore intuition into a structurally exact theorem.

---

### Path C: asymptotic classification theorem
If you can push further, classify growth regimes:

- chain types: singly exponential in depth,
- bounded-width types: singly exponential with width-dependent base,
- balanced bushy types: possibly super-exponential in depth,
- unrestricted types: exponential in complexity.

#### Proof strategy steps
1. Define canonical families realizing each regime.
2. Prove upper/lower bounds matching on each family.
3. State a taxonomy theorem showing which structural parameters govern each asymptotic phase.

This would connect the project to phase transitions in combinatorics and complexity theory.

---

## Why This Would Be a Breakthrough

If successful, this project would identify a **semantic parameterized complexity theory for types**.

Today, state blowup in typed semantics is usually treated as an opaque function of syntax size. A theorem showing that state complexity collapses to arrow depth, or to depth plus a width profile, would mean:

- higher-order semantic complexity admits **structural compression**;
- bisimulation minimization can be parameterized by low-dimensional type invariants;
- compiler analyses can target depth and width instead of full type expansion;
- type-theoretic semantics gains an analogue of **treewidth/pathwidth phenomena** in graph algorithms;
- descriptive complexity gains a typed counterpart of “quantifier rank controls expressivity.”

This is exactly the kind of theorem that opens a field rather than merely extending one.

---

## Cross-Domain Connections You Must Surface

At least one theorem must explicitly connect this domain to another mathematical domain.

### 1. Descriptive complexity
Arrow depth should be compared to quantifier rank:
- complexity controlled by depth resembles finite-model bounds controlled by logical nesting depth;
- width parameters resemble variable-count or alternation-width refinements.

Possible theorem framing:
- monotonicity or boundedness results analogous to Ehrenfeucht–Fraïssé depth phenomena.

### 2. Automata theory
`typeStateBound` is a semantic state-count invariant. This is structurally analogous to:
- star height vs automaton size,
- register/stack depth vs state complexity,
- branching program width vs formula depth.

If you define `arrowWidth`, emphasize the analogy with branching width and circuit width.

### 3. Parameterized complexity
If `typeStateBound` is bounded by `f(depth)` or `f(depth,width)`, then minimization and equivalence procedures become fixed-parameter candidates.

Application keywords:
- fixed-parameter tractability
- kernelization by type shape
- semantic compression
- higher-order model reduction

### 4. Statistical physics / renormalization
A depth-profile theorem can be sold as a renormalization principle:
- local arrow composition induces a coarse-grained complexity flow,
- depth acts as scale,
- width acts as branching entropy.

Even one well-written paragraph in `RESEARCH_PAPER.md` connecting the recurrence to scale-dependent growth would make the work memorable.

---

## Suggested Lean 4 Formalization Targets

These are schematic and should be adapted to actual definitions in the catalog.

```lean
def ChainTy : Ty → Prop
| Ty.base => True
| Ty.arr A B => ChainTy B ∧ isBaseLike A   -- or another natural spine condition

def arrowWidth : Ty → ℕ
| Ty.base => 0
| Ty.arr A B => max (arrowWidth A) (arrowWidth B) + 1

def bushy : ℕ → Ty
| 0 => Ty.base
| n+1 => Ty.arr (bushy n) (bushy n)
```

Core theorem shapes:
```lean
theorem typeStateBound_mono_under_profile :
    ∀ A B : Ty, profileLe A B → typeStateBound A ≤ typeStateBound B

theorem typeStateBound_le_two_pow_complexity :
    ∀ A : Ty, typeStateBound A ≤ 2 ^ (Ty.complexity A + 1)

theorem typeStateBound_le_exp_depth_of_chain :
    ∀ A : Ty, ChainTy A → typeStateBound A ≤ 2 ^ (Ty.depth A + 1)

theorem bushy_depth_bound :
    ∀ n : ℕ, Ty.depth (bushy n) = n

theorem bushy_typeStateBound_lower :
    ∀ n : ℕ, 2 ^ n ≤ typeStateBound (bushy n)
```

If the exact formulas differ because of the catalog definitions, adjust them faithfully. The point is to formalize a **sharp asymptotic law**.

---

## Tactical Proof Guidance

You are required to produce at least 3 theorems with deep proof tactics. Use:

- structural induction on `Ty`
- strengthened induction hypotheses
- `rcases` on arrow/base forms
- `by_contra` for extremal/minimal-counterexample arguments
- `field_simp` if rational majorants arise
- multi-step `calc` blocks for recurrence solving
- monotonicity lemmas for exponentials and multiplication

Useful sublemmas to prove early:

```lean
theorem depth_le_complexity : ∀ A : Ty, Ty.depth A ≤ Ty.complexity A
theorem complexity_pos : ∀ A : Ty, 1 ≤ Ty.complexity A + 1
theorem pow_monotone_right : a ≤ b → a^n ≤ b^n
theorem max_add_one_control : max x y + 1 ≤ x + y + 1
```

Also prove shape lemmas for your new invariants:
```lean
theorem arrowWidth_le_complexity : ∀ A : Ty, arrowWidth A ≤ Ty.complexity A
theorem chain_depth_complexity_eq : ∀ A : Ty, ChainTy A → Ty.complexity A = Ty.depth A + k
```
for the appropriate `k`.

---

## Testable Conjectures You Must State

You must include at least one falsifiable conjecture with a clear computational test. Preferably include 3–5 in `FUTURE_DIRECTIONS.md`.

Here are strong candidates.

### Conjecture A: width-refined single exponential law
There exists a constant `c` such that
\[
\forall A,\quad \mathrm{typeStateBound}(A) \le c^{(\mathrm{depth}(A)+1)(\mathrm{arrowWidth}(A)+1)}.
\]

**Test:** Enumerate all simple types up to fixed complexity/depth and compute the smallest empirical `c`. Search for violations at depth 1–8.

### Conjecture B: chain optimality
Among all types of fixed depth and bounded base arity, chain types minimize `typeStateBound`, while balanced bushy types maximize it.

**Test:** Exhaustively enumerate type trees at each depth and compare extremizers.

### Conjecture C: asymptotic phase transition
There exists a threshold width growth regime separating singly exponential from super-exponential `typeStateBound`.

**Test:** Construct families with `arrowWidth(n)=O(1)`, `O(log n)`, `Θ(n)` and fit growth curves.

### Conjecture D: parameterized minimization tractability
Bisimulation minimization for typed semantic structures is fixed-parameter tractable in `(depth, arrowWidth)`.

**Test:** Implement quotient construction, fit runtime against size and profile parameters, and seek counterexamples.

### Conjecture E: logical correspondence
There exists a translation from simple types to formulas whose quantifier rank is linearly equivalent to `Ty.depth`, and whose model-count/state complexity tracks `typeStateBound`.

**Test:** Build explicit translations for small types and compare ranks and quotient sizes.

---

## Verified Algorithmic Deliverable

You must produce not only theorems but a verified computational method.

### Required algorithm
Implement a certified analyzer that computes:
- `Ty.depth`
- `Ty.complexity`
- your new invariant (`arrowWidth` or `depthProfile`)
- the predicted upper bound
- and compares it against the actual `typeStateBound`

This should culminate in a theorem of the shape:
```lean
def predictedBound (A : Ty) : ℕ := ...

theorem typeStateBound_le_predictedBound :
    ∀ A : Ty, typeStateBound A ≤ predictedBound A
```

If the pure depth-only conjecture fails, the analyzer should return a **diagnostic witness** showing which structural parameter caused the violation.

---

## demo.py Requirements

Your `demo.py` must interactively:
1. Generate or enumerate simple types up to a user-given depth/complexity.
2. Compute `depth`, `complexity`, `typeStateBound`, and your new invariant.
3. Plot growth against:
   - depth alone,
   - complexity,
   - depth × width,
   - candidate exponential fits.
4. Search automatically for counterexamples to naive depth-only bounds.
5. Highlight extremal families such as chain and bushy types.

This demo is not decoration; it is part of the scientific loop.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **Lean code** with at least 3 substantial theorems using deep proof tactics.
2. **A new mathematical definition** such as `ChainTy`, `arrowWidth`, `depthProfile`, or `balancedDefect`.
3. **A cross-domain theorem or explicitly formalized connection** to descriptive complexity, automata theory, or parameterized complexity.
4. **`FUTURE_DIRECTIONS.md`** with 3–5 falsifiable scientific hypotheses, each with a concrete computational test.
5. **`RESEARCH_PAPER.md`** as a standalone paper explaining the discovery, significance, proofs, and next questions. It must make sense without access to the code.
6. **`ARTICLE.md`** in Scientific American style, focused on the mathematical ideas and why they matter. Do not emphasize formal verification machinery.
7. **A verified algorithm or computational method**, not just theorem statements.
8. **`demo.py`** demonstrating the result interactively.

---

## Application Keywords

Use these explicitly in the paper and article:

- higher-order semantics
- bisimulation minimization
- semantic state complexity
- arrow depth
- structural parameterization
- fixed-parameter tractability
- descriptive complexity
- automata state explosion
- width-depth tradeoff
- semantic compression
- type-theoretic complexity
- renormalization of syntax
- asymptotic phase transition

---

## Final Scientific Standard

Do not settle for “some upper bound.” Either:

1. prove the depth-only exponential law cleanly, or  
2. refute it with an explicit family and replace it by a sharper structural theorem.

Both outcomes are excellent. The true target is a **classification principle** explaining which type-shape invariants control semantic state complexity. That is the field-opening contribution.

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

Research domain: Pythagorean
Research mode: prove
