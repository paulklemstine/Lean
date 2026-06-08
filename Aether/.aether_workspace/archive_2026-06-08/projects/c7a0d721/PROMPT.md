Soli Deo Gloria

## Assignment: Direction 1 — Hardness of Unrestricted-Degree Lorentzian Recognition

Work in **mode: prove/discover**. The goal is not a routine extension but a complexity-theoretic threshold theorem for a Hodge-theoretic positivity notion. You should aim to make precise, formal progress toward the following statement, and if the full coNP-hardness theorem is not yet reachable in one cycle, you must still prove structurally deep lower-bound and reduction lemmas that unmistakably move the boundary.

Prove new, non-trivial theorems. Build directly on the catalog results in `Pythagorean/LorentzianRecognition.lean`, especially:

- `card_multiindex_le_pow`
- `quadratic_leaf_count_le`

The breakthrough target is to show that the catalog’s upper bounds for recursive Lorentzian checking are not merely artifacts of a naive algorithm, but reflect an intrinsic explosion when the degree is unbounded.

---

## Central Vision

The fixed-degree theory of Lorentzian recognition currently behaves like a tame algebraic decision problem. The unrestricted-degree regime should instead behave like a genuine complexity barrier: the recursive Hessian-at-leaves criterion, so elegant in Hodge theory, may conceal a combinatorial explosion equivalent to Boolean unsatisfiability. If formalized, this would be the first serious complexity lower-bound for a **Hodge-theoretic positivity predicate**.

This is not just “another hardness result.” It would create a new bridge:

- **computational complexity** ↔ **Lorentzian/Hodge positivity**
- **Boolean satisfiability** ↔ **derivative-tree geometry**
- **proof complexity / certificate size** ↔ **algebraic combinatorics**

A successful result here opens a field: **complexity theory of Hodge predicates**.

---

## Precise Theorem Targets

You should aim to formalize a hierarchy of results, with at least 3 substantial theorems. The first two are fully realistic formal targets; the third is the flagship hardness theorem or a rigorously stated conditional version.

### Theorem A: Exponential-size derivative witness family
Construct an explicit family of homogeneous polynomials with nonnegative integer coefficients whose recursive derivative trees have size growing exponentially in the degree, and prove that any leaf-based recognition procedure must inspect all clause-coded branches in the worst case.

A suitable formal target is:

```lean
def ClauseEncodedFamily (m n : ℕ) : MvPolynomial (Fin n) ℕ := sorry

def derivativeLeafCountLowerBound
  (p : MvPolynomial σ ℕ) (d : ℕ) : Prop := sorry

theorem clauseEncodedFamily_leaf_explosion
  {m n : ℕ} (hmn : m ≤ n) :
  derivativeLeafCountLowerBound (ClauseEncodedFamily m n) (m + 2) ∧
  (∃ C : ℕ, C > 0 ∧
    C * 2^m ≤ quadratic_leaf_count (ClauseEncodedFamily m n)) := by
  sorry
```

If `quadratic_leaf_count` is not already defined exactly in this form, introduce a new definition compatible with the catalog’s `quadratic_leaf_count_le`. The point is to complement the upper bound by an explicit lower-bound construction.

### Theorem B: SAT-pattern encoding into Lorentzian branch structure
Define a polynomial family associated to a CNF formula so that branch derivatives correspond to partial assignments or clause selections, and prove a structural equivalence between branch obstruction and satisfiability pattern.

A target shape:

```lean
structure CNFFormula (Var Clause : Type) where
  vars : Finset Var
  clauses : Finset (Finset (Var × Bool))

def satEncodingPolynomial
  (φ : CNFFormula Var Clause) :
  MvPolynomial Var ℕ := sorry

def branchObstructed
  (φ : CNFFormula Var Clause)
  (I : Finset Var) : Prop := sorry

theorem satEncoding_branch_correspondence
  (φ : CNFFormula Var Clause) :
  ∀ I,
    branchObstructed φ I ↔
    ∃ τ : Var → Bool, extends_assignment I τ ∧ ¬ satisfies τ φ := by
  sorry
```

This theorem is the engine of the reduction: it says the derivative tree is not arbitrary algebra, but a semantic encoding of Boolean obstruction.

### Theorem C: Conditional hardness theorem for unrestricted-degree recognition
If full many-one coNP-hardness is too ambitious to completely certify in one pass, prove a **conditional theorem** of the form: if unrestricted-degree Lorentzian recognition were decidable in polynomial time, then a canonical unsatisfiability problem or branch-obstruction problem would also be polynomial-time decidable.

Ideal statement:

```lean
def IsLorentzianHomogeneous
  (p : MvPolynomial σ ℕ) : Prop := sorry

def polytime_recognizable_lorentzian : Prop := sorry
def polytime_unsat_cnf : Prop := sorry

theorem unrestricted_degree_lorentzian_recognition_hard
  (hLor : polytime_recognizable_lorentzian) :
  polytime_unsat_cnf := by
  sorry
```

A stronger version, if you can make the reduction exact:

```lean
theorem cnf_unsat_many_one_reduces_to_lorentzian
  :
  ∃ f : CNFFormula Var Clause → Σ n, MvPolynomial (Fin n) ℕ,
    polynomial_time f ∧
    ∀ φ, let q := (f φ).2
         IsLorentzianHomogeneous q ↔ ¬ CNFSatisfiable φ := by
  sorry
```

This is the theorem that would be remembered.

---

## Lean 4 Formalization Targets

You must include at least one genuinely new definition not already in the catalog. Recommended new definitions:

```lean
structure CNFFormula (Var Clause : Type) where
  vars : Finset Var
  clauses : Finset (Finset (Var × Bool))

def literalSatisfied (τ : Var → Bool) (ℓ : Var × Bool) : Prop :=
  τ ℓ.1 = ℓ.2

def clauseSatisfied (τ : Var → Bool) (C : Finset (Var × Bool)) : Prop :=
  ∃ ℓ ∈ C, literalSatisfied τ ℓ

def formulaSatisfied (τ : Var → Bool) (φ : CNFFormula Var Clause) : Prop :=
  ∀ C ∈ φ.clauses, clauseSatisfied τ C

def satEncodingPolynomial
  (φ : CNFFormula Var Clause) :
  MvPolynomial Var ℕ := sorry

def derivativeBranch
  (p : MvPolynomial σ ℕ) (s : List σ) :
  MvPolynomial σ ℕ := sorry

def quadratic_leaf_count
  (p : MvPolynomial σ ℕ) : ℕ := sorry

def branchObstructed
  (p : MvPolynomial σ ℕ) (s : List σ) : Prop := sorry
```

You may also define a more abstract certificate complexity notion:

```lean
def LorentzianCertificateSize
  (p : MvPolynomial σ ℕ) : ℕ := sorry
```

and prove lower bounds for it.

---

## Why This Would Be a Breakthrough

If you succeed, you will have established that a central positivity predicate from modern combinatorial Hodge theory has a complexity phase transition:

- **fixed degree**: tractable, structurally controlled
- **unbounded degree**: hardness emerges from combinatorial encoding

That is the exact kind of theorem that changes a field’s self-understanding. It says Hodge positivity is not merely a refined algebraic property; it is a computationally expressive language. This would motivate:

- approximation algorithms for Lorentzian recognition,
- parameterized complexity by degree/treewidth/support size,
- average-case recognition theory,
- complexity classifications for related Hodge predicates,
- new lower bounds for algebraic certificate systems.

---

## Proof Architecture: 3 Viable Strategies

You must present and pursue at least 2 of these, and explain in comments which one appears most promising.

### Strategy A: Direct CNF-to-derivative-tree reduction
**Most ambitious and conceptually strongest.**

1. Define a polynomial `P_φ` whose monomials encode clause-variable incidences and slack variables enforcing homogeneity.
2. Show that taking suitable directional/partial derivatives corresponds to choosing literals, clauses, or partial assignments.
3. Prove:
   - if `φ` is unsatisfiable, every relevant quadratic leaf satisfies the Lorentzian/Hessian sign condition;
   - if `φ` is satisfiable, there exists a branch producing a forbidden quadratic leaf.

Why promising: it gives the cleanest theorem and the strongest bridge to Cook–Levin style complexity. Why hard: formalizing exact derivative semantics over `MvPolynomial` is intricate.

### Strategy B: Certificate-complexity lower bound via adversarial branch families
**Most likely to succeed in one cycle.**

1. Introduce a formal model of recursive Lorentzian certificates using derivative trees.
2. Construct explicit homogeneous polynomials where different branches remain indistinguishable until depth `Ω(d)`.
3. Use counting/adversary arguments to prove any certificate must inspect `n^{Ω(d)}` or `2^{Ω(d)}` leaves.

Why promising: it builds directly on `quadratic_leaf_count_le`, turning an upper bound into a near-matching lower bound. Why revolutionary: even absent a full SAT reduction, it proves intrinsic hardness of the known recognition paradigm.

### Strategy C: Matrix/Hessian embedding route
**Best cross-domain route; may be easier algebraically.**

1. Encode a symmetric matrix family into quadratic leaves of a higher-degree homogeneous polynomial.
2. Prove that positivity/non-positivity of a matrix eigenvalue is equivalent to failure of a Lorentzian leaf condition after a controlled derivative sequence.
3. Lift hardness from matrix spectral obstruction to unrestricted-degree Lorentzian recognition.

Why promising: Lorentzian recognition already passes through Hessian signatures, so spectral problems are a natural intermediate language. Why deep: it connects algebraic combinatorics with spectral complexity and semialgebraic decision theory.

My judgment: **Strategy B + C together are the highest-probability route this cycle**, with Strategy A as the long-range flagship. B gives rigorous lower bounds now; C gives a plausible reduction skeleton; A is the full endgame.

---

## Required Deep Theorems

Your file must contain at least 3 theorems with nontrivial proofs using tactics such as induction, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`. Suggested theorem slate:

1. **Branch-count lower bound theorem**  
   Prove a nontrivial lower bound matching or complementing `quadratic_leaf_count_le`.

2. **Derivative-branch semantic theorem**  
   Show branch derivatives preserve or reflect a SAT-style semantic invariant.

3. **Cross-domain theorem: spectral obstruction ↔ Lorentzian obstruction**  
   Relate a matrix sign/eigenvalue condition to non-Lorentzian behavior of an encoded polynomial family.

A plausible cross-domain statement:

```lean
def matrixEncodedPolynomial (A : Matrix (Fin n) (Fin n) ℚ) :
  MvPolynomial (Fin (n + 2)) ℚ := sorry

theorem positive_eigenvalue_gives_nonlorentzian_leaf
  (A : Matrix (Fin n) (Fin n) ℚ)
  (hsymm : A.IsSymm)
  (hpos : ∃ x : Fin n → ℚ, x ≠ 0 ∧ 0 < dotProduct x (A.mulVec x)) :
  ∃ s, ¬ IsLorentzianHomogeneous (derivativeBranch (matrixEncodedPolynomial A) s) := by
  sorry
```

This theorem is exactly the kind of cross-pollination we want: **spectral linear algebra + Hodge positivity**.

---

## Cross-Domain Connections You Must Exploit

At least one theorem must connect Lorentzian recognition to another domain. Strong candidates:

- **Computational complexity**: SAT, coNP-hardness, certificate complexity
- **Spectral graph theory / linear algebra**: Hessian signatures, matrix embeddings
- **Matroid theory**: Lorentzian polynomials as generating objects for combinatorial geometries
- **Statistical physics**: partition functions with strong log-concavity / stability constraints
- **Proof complexity**: lower bounds on certificate size mirror lower bounds on resolution trees

The most compelling bridge for this cycle is:

> **Lorentzian derivative trees behave like proof trees.**
> Unsatisfiability certificates and recursive Lorentzian certificates may obey parallel lower bounds.

If you can formalize even a weak version of that sentence, it is a field-opening insight.

---

## Application Keywords

Include these explicitly in comments / paper framing / metadata:

- coNP-hardness
- Lorentzian polynomials
- Hodge theory
- algebraic combinatorics
- certificate complexity
- SAT reduction
- derivative trees
- Hessian signatures
- spectral obstruction
- parameterized complexity
- proof complexity
- strong log-concavity

---

## Concrete Build-on-Catalog Instructions

Use `quadratic_leaf_count_le` as the starting point for a dual story:

- the catalog gives an **upper bound** on recursive checking complexity;
- your mission is to prove that this complexity is, in a precise sense, **unavoidable** in the unrestricted-degree regime.

Use `card_multiindex_le_pow` for counting arguments on derivative branches / supports / multi-indices. In particular, convert combinatorial branch growth into explicit power/exponential lower bounds by comparing support families against multi-index capacities.

Do not merely cite these theorems. Use them as active components:
- upper bound to calibrate the search space,
- multi-index cardinality bound to control encoding size,
- then derive lower-bound separation by constructing a family saturating or defeating these bounds.

---

## Conjecture With Testable Prediction

You must state and computationally probe at least one falsifiable conjecture. Use something like:

> **Conjecture (branch-complexity barrier).** There exists a constant `c > 0` and an explicit family of homogeneous polynomials `p_d` with nonnegative integer coefficients and degree `d` such that every recursive Lorentzian certificate for `p_d` has size at least `exp(c d)`.

Testable prediction:
- For the first `d = 2,3,4,5,6,7`, exhaustive or randomized search over certificate trees should reveal minimal certificate size growing superpolynomially in `d`.
- A disproof would exhibit unexpectedly small certificates, suggesting a hidden compression principle and undermining the hardness narrative.

A second conjecture, if you can support it:

> **Conjecture (SAT encoding exactness).** For the clause-encoding family `P_φ`, one has `P_φ` Lorentzian iff `φ` is unsatisfiable.

This is falsifiable by brute-force search on small CNF instances.

---

## Deliverables You Must Produce

You must produce **all** of the following:

### 1. Formal Lean development
A new Lean file containing:
- at least 3 nontrivial theorems,
- at least 1 novel definition,
- at least 1 cross-domain theorem,
- minimized `sorry`s,
- comments explaining the mathematical architecture.

### 2. Verified algorithm or computational method
Not just theorem statements. Implement a certified or semi-certified computational method, for example:
- a procedure to compute derivative-branch trees,
- a search algorithm for quadratic leaves,
- an obstruction finder for candidate non-Lorentzian leaves,
- a SAT-to-polynomial instance generator.

### 3. `demo.py`
An interactive demo that:
- accepts a small CNF formula or matrix,
- constructs the encoded polynomial,
- explores derivative branches,
- reports candidate Lorentzian obstructions or certificate sizes,
- visualizes branch growth.

### 4. `RESEARCH_PAPER.md`
A standalone scientific paper that explains:
- the theorem(s),
- the reduction idea,
- why unrestricted degree changes the complexity,
- what was proved versus conjectured,
- future mathematical implications.

A reader with no code access must still understand the discovery.

### 5. `ARTICLE.md`
A Scientific American–style exposition for broad readers.
Do **not** focus on formal verification. Focus on the mathematical idea:
how a positivity condition from modern geometry can secretly encode computational hardness.

### 6. `FUTURE_DIRECTIONS.md`
Give 3–5 original research directions. For each direction, include the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as statistical physics, optimization, or proof complexity.

---

## Nontriviality Requirements

These are mandatory.

1. **NO trivial proofs.** Do not spend the cycle proving statements whose only content is computation by `native_decide`, `decide`, `norm_num`, or `rfl`, unless the statement itself is truly conceptually central.

2. **At least 3 deep theorems.** Use induction, `rcases`, `by_contra`, `field_simp`, and multi-step `calc` reasoning in meaningful ways.

3. **Novel definitions.** Introduce at least one new concept absent from the catalog.

4. **Cross-domain connection.** At least one theorem must connect Lorentzian recognition to another mathematical domain.

5. **Testable conjecture.** State a falsifiable conjecture with a computational test that could disprove it.

---

## Standard of Success

Success is not “I formalized some definitions around Lorentzian polynomials.” Success is one of the following:

- a rigorous lower bound showing derivative-tree explosion in unbounded degree;
- a reduction skeleton from SAT or spectral obstruction to Lorentzian recognition with key lemmas proved;
- a conditional hardness theorem with enough formal detail that the final complexity theorem is within reach;
- or, best of all, an exact reduction theorem.

What you are trying to reveal is a new scientific law:

> **Lorentzian positivity is computationally tame only when degree is bounded; beyond that, it becomes a language for hardness.**

That is the frontier.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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
