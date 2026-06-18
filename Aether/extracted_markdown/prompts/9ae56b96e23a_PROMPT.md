Soli Deo Gloria

## Assignment: Direction 1: Universal Support-Tutte Polynomial

**Mode:** prove

Prove a genuinely new theorem establishing a universal deletion–contraction invariant for M-convex supports, with a formalized algorithm that computes it and tests order-independence on nontrivial families. Build explicitly on the minor-closure infrastructure in `Catalog/Pythagorean/SupportMinorTheory.lean`, especially any definitions and lemmas around support minors, `SupportTutteInvariant`, and the size-control theorem `minor_step_card_le`.

This is not a request for a routine generalization of matroid Tutte theory. The goal is to create a new algebraic invariant for discrete convex supports that contains classical Tutte theory as a shadow, but also sees arithmetic degree data that matroids erase. If successful, this opens a new interface among discrete convex analysis, combinatorial Hopf algebras, tropical geometry, and reliability/statistical-mechanics style partition functions.

---

## Core Vision

Classical Tutte universality is one of the deepest organizing principles in combinatorics: every deletion–contraction invariant with the right multiplicativity factors through a single polynomial. Your task is to build an analogue for **M-convex supports**: finite support sets in `ℕ^n` or affine slices thereof satisfying exchange axioms strong enough to support minors, loops/coloops, and recursive elimination.

The breakthrough theorem should show that support-minor theory is not merely a convenient recursion scheme, but the presentation of a **universal algebraic object**. This would create a new invariant theory for supports that is richer than matroid theory because supports remember multiplicities/degree profiles, not just `{0,1}` incidence.

---

## Precise Theorem Target

You should introduce a new formal object, tentatively called a **support activity algebra** or **universal support-Tutte polynomial**, and prove a theorem of the following form.

### Mathematical statement

Let `S` range over a class `GoodSupport` of finite M-convex supports equipped with deletion and contraction operations along coordinates/elements, with distinguished loop and coloop cases and a direct-sum operation `⊕` on disjoint coordinate sets.

Define a polynomial-valued invariant
\[
T_S(X,Y)\in \mathbb{Z}[X,Y]
\]
by:
- multiplicativity on disjoint-coordinate direct sums,
- deletion–contraction recurrence
  \[
  T_S =
  \begin{cases}
    X \, T_{S / e} & \text{if } e \text{ is a coloop},\\
    Y \, T_{S \setminus e} & \text{if } e \text{ is a loop},\\
    T_{S \setminus e} + T_{S / e} & \text{otherwise},
  \end{cases}
  \]
- normalization on the empty support.

Then prove:

> **Universal Support-Tutte Theorem.**  
> For every commutative semiring or ring `R`, and every invariant
> \[
> F : \text{GoodSupport} \to R
> \]
> satisfying:
> 1. `F (S₁ ⊕ S₂) = F S₁ * F S₂`,
> 2. loop/coloop rules
>    \[
>    F(S)=a\cdot F(S\setminus e),\qquad F(S)=b\cdot F(S/e),
>    \]
>    for fixed `a b : R`,
> 3. generic deletion–contraction
>    \[
>    F(S)=u\cdot F(S\setminus e)+v\cdot F(S/e),
>    \]
>    for fixed `u v : R` on ordinary elements,
>
> there exists a unique semiring/ring homomorphism
> \[
> \varphi : \mathbb{Z}[X,Y] \to R
> \]
> (or the appropriate coefficient algebra with parameters) such that
> \[
> F(S)=\varphi(T_S)
> \]
> for all `S`.

If the exact recurrence in your catalog already packages the coefficients differently, adapt the polynomial ring accordingly. For example, the truly universal object may need coefficients in `ℤ[L,C,U,V]` rather than `ℤ[X,Y]`. If that happens, prove the strongest correct theorem and then derive the two-variable specialization as a corollary under the normalization `u=v=1`.

### Lean 4 theorem shape (target signature)

You may need to adjust names/types to match the catalog, but aim for a theorem with the following structure:

```lean
theorem exists_unique_supportTutte_factor
    {α : Type*} [DecidableEq α]
    {R : Type*} [CommSemiring R]
    (F : GoodSupport α → R)
    (hmul : ∀ S T, DisjointCoord S T → F (directSum S T) = F S * F T)
    (hloop : ∀ S e, IsLoop e S → F S = a * F (delete S e))
    (hcoloop : ∀ S e, IsColoop e S → F S = b * F (contract S e))
    (hdelcon :
      ∀ S e, OrdinaryElement e S →
        F S = u * F (delete S e) + v * F (contract S e)) :
    ∃! φ : MvPolynomial (Fin 4) ℤ →+* R,
      ∀ S, F S = φ (supportTuttePoly S)
```

and a specialization theorem such as:

```lean
theorem supportTutte_universal_two_var
    {α : Type*} [DecidableEq α] :
    ∀ F : GoodSupport α → R, ... →
    ∃! φ : Polynomial (Polynomial ℤ) →+* R,
      ∀ S, F S = φ (supportTuttePoly2 S)
```

If `MvPolynomial` is cleaner than nested `Polynomial`, use it. If `ℤ` coefficients create unnecessary friction, begin with `ℕ`, then lift to `ℤ` or a general semiring.

---

## New Definitions Required

You must define at least one genuinely new concept not already present in the catalog. The most promising choices are:

1. **SupportActivityData**  
   A structure encoding, for a chosen elimination order, the count of support-loops, support-coloops, and ordinary steps encountered in a recursive minor tree.

   Example shape:
   ```lean
   structure SupportActivityData where
     loops : ℕ
     coloops : ℕ
     ordinaryLeft : ℕ
     ordinaryRight : ℕ
   ```

2. **CanonicalActivityOrder**  
   A predicate or structure asserting that a total order on coordinates/elements yields an order-independent activity expansion on a support.

3. **GoodSupport**  
   If the catalog does not already package exactly the right hypotheses, define a wrapper structure bundling finiteness, M-convexity, and closure under minors.

4. **supportTuttePoly / supportTuttePolyAux**  
   A recursive polynomial-valued invariant whose well-foundedness is justified using `minor_step_card_le` plus a strict descent measure.

The novelty should not be cosmetic: it must be mathematically load-bearing in the proof.

---

## Minimum Theorem Package

Your Lean file must contain at least **3 substantial theorems** proved by real argument. At least one should use induction on a support-size or minor-depth measure; at least one should use multi-step `calc`; at least one should involve nontrivial case splitting via `rcases`/`by_cases`/`by_contra`.

Here is the package I want:

### Theorem A: Well-defined recursion / termination
Prove that the recursive definition of `supportTuttePoly` terminates and is independent of the chosen recursive witness if your recursion is packaged through a well-founded relation.

Possible target:
```lean
theorem supportTuttePoly_wf :
  WellFounded supportMinorMeasure
```
together with
```lean
theorem supportTuttePoly_eq_rec
    (S : GoodSupport α) (e : α) :
    ...
```

This theorem is where `minor_step_card_le` should enter critically.

### Theorem B: Multiplicativity
Prove:
```lean
theorem supportTuttePoly_directSum
    (S T : GoodSupport α)
    (hdisj : DisjointCoord S T) :
    supportTuttePoly (directSum S T)
      = supportTuttePoly S * supportTuttePoly T
```

This is the algebraic backbone of universality.

### Theorem C: Universality / unique factorization
Prove the main theorem:
```lean
theorem exists_unique_supportTutte_factor ...
```

This should be a serious induction on the minor measure, not a superficial wrapper.

### Theorem D: Cross-domain bridge theorem
You must include at least one theorem connecting support-Tutte theory to another domain. Strong candidates:

- **Matroid bridge:** for `{0,1}`-valued supports arising from bases of a matroid, your support-Tutte polynomial specializes to the classical Tutte polynomial.
- **Statistical mechanics bridge:** a specialization equals a support partition function counting minor histories with loop/coloop weights.
- **Tropical geometry bridge:** the support-Tutte polynomial is invariant under support-equivalences preserving the associated tropical subdivision combinatorics.

A precise and achievable version is:

```lean
theorem supportTutte_eq_matroidTutte_of_basisIndicator
    (M : Matroid α) :
    supportTuttePoly (basisIndicatorSupport M) = matroidTuttePoly M
```

If exact equality is too ambitious because of normalization mismatch, prove equality after an explicit change of variables.

This theorem is strategically vital: it certifies that your theory is not an isolated gadget but a strict extension of a central invariant.

---

## Proof Strategy Architecture

You must pursue at least 2–3 plausible proof paths and explicitly choose the most viable one.

### Strategy A: Induction on minor measure via universal recursion
1. Define a well-founded measure on supports, likely cardinality or a lexicographic pair involving ambient coordinate count and support size.
2. Use `minor_step_card_le` and any strictness lemmas to show deletion/contraction descend in this measure except at base cases.
3. Define `supportTuttePoly` recursively.
4. Prove universality by induction: any invariant satisfying the same recurrence agrees with the polynomial under the evaluation homomorphism.
5. Prove uniqueness by extensionality over recursively generated supports.

**Why promising:** This is closest to classical Tutte universality proofs and uses the catalog’s minor machinery exactly where it is strongest.

### Strategy B: Free algebra / initial object approach
1. Define a category (or bare algebraic presentation) of support invariants with generators given by irreducible minor steps and relations given by deletion–contraction plus direct-sum multiplicativity.
2. Show `supportTuttePoly` presents the initial object in this category.
3. Recover universality as the categorical initiality statement.

**Why promising:** Conceptually strongest and most revolutionary. It would make the theory robust and reusable.  
**Why risky:** Higher formalization overhead in Lean may obscure the core theorem unless the algebraic infrastructure is already nearby.

### Strategy C: Activity expansion and order-independence
1. Define support activities relative to a total order.
2. Show the recursive polynomial equals a sum over activity data.
3. Prove independence of order by comparing both sides to the deletion–contraction characterization.
4. Deduce universality from the order-independent expansion.

**Why promising:** This is the closest analogue of the classical internal/external activity story and would be mathematically beautiful.  
**Why risky:** “Canonical activity ordering” may be the hardest new combinatorial notion to make precise for general M-convex supports.

**Recommendation:** Start with **Strategy A** as the formal backbone. If successful, add a partial **Strategy C** theorem for restricted supports or for computational experiments. Strategy B can be sketched in `RESEARCH_PAPER.md` and `FUTURE_DIRECTIONS.md` even if not fully formalized.

---

## Cross-Domain Connections You Should Exploit

1. **Matroid theory:**  
   Classical Tutte universality should appear as a special case. This is the clearest validation theorem.

2. **Discrete convex analysis / Murota-style exchange systems:**  
   M-convexity is the structural source of the minor recursion. Make this explicit. The theorem says discrete convex supports admit an invariant calculus parallel to matroids.

3. **Statistical mechanics / partition functions:**  
   Tutte-type polynomials are often partition functions in disguise. A specialization of `supportTuttePoly` should count weighted minor histories, analogous to Fortuin–Kasteleyn or reliability expansions. Even a modest theorem here is powerful.

4. **Tropical geometry:**  
   Supports govern Newton polytopes and tropical hypersurfaces. A support invariant sensitive to deletion/contraction may encode subdivision-level information invisible to classical matroid invariants.

5. **Algorithmic complexity / symbolic computation:**  
   A verified recursive algorithm computing `supportTuttePoly` on finite supports gives a new exact symbolic tool for discrete convex structures.

**Application keywords:** universal invariant, deletion–contraction, M-convexity, discrete convex analysis, Tutte polynomial, matroid specialization, partition function, tropical support geometry, symbolic recursion, combinatorial Hopf algebra, reliability polynomial, activity expansion.

---

## Computational Deliverable: Verified Algorithm

You must provide a verified algorithm, not just theorems.

### Required algorithm
Implement a recursive computation of `supportTuttePoly` for finite supports with memoization or canonical minor reduction where feasible.

Target artifacts:
- a Lean function computing `supportTuttePoly` on concrete finite examples,
- correctness theorem:
  ```lean
  theorem compute_supportTuttePoly_correct
      (S : GoodSupport α) :
      computeSupportTuttePoly S = supportTuttePoly S
  ```
- experimental comparison of two coordinate orderings on all M-convex subsets of the degree-≤5 simplex on 4 variables, or on the largest feasible certified subfamily.

If full exhaustive enumeration is too expensive in Lean, split responsibilities:
- Lean proves correctness of the recursive algorithm and order-invariance on a substantial certified class.
- `demo.py` performs broader computational experiments externally.

### Falsifiable conjecture with testable prediction
State explicitly:

> **Conjecture (Order-independence of support activities).**  
> For every finite M-convex support `S`, the activity expansion of `supportTuttePoly` is independent of the chosen total order on coordinates/elements.

**Testable prediction:**  
Enumerate all M-convex subsets of the degree-≤5 simplex in 4 variables; compute the activity polynomial under at least two distinct total orders. Any disagreement falsifies the conjecture.

Also consider a stronger conjecture if experiments support it:

> **Conjecture (Matroid shadow specialization).**  
> If two M-convex supports induce the same matroidal basis shadow, then a specific specialization of `supportTuttePoly` agrees on both.

This is computationally falsifiable and could reveal what extra information the support invariant retains beyond matroids.

---

## Lean Engineering Expectations

Use the catalog aggressively, not decoratively. In particular:
- import and reuse the support-minor infrastructure from  
  `Catalog/Pythagorean/SupportMinorTheory.lean`;
- identify the exact theorem names around `SupportTutteInvariant` and `minor_step_card_le`;
- if there are already lemmas about deletion/contraction preserving M-convexity, chain them into your induction measure proof rather than reproving from scratch.

You should minimize `sorry`, and any remaining `sorry` must be confined to peripheral lemmas, not the main theorems or algorithm correctness.

Do **not** choose statements whose proof collapses to `native_decide`, `decide`, `norm_num`, or `rfl`. The main theorems must require real mathematical argument.

---

## Concrete Deliverables

You must produce **all** of the following:

1. **Lean file(s)** containing:
   - at least one new mathematical definition,
   - at least 3 substantial theorems,
   - a verified computation algorithm for `supportTuttePoly`,
   - one cross-domain theorem.

2. **`FUTURE_DIRECTIONS.md`** with **3–5 original research directions**, each including:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   - at least one direction bridging to a different domain.

3. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - must explain the problem, theorem, proof ideas, significance, experiments, and next questions,
   - must be understandable without reading the code.

4. **`ARTICLE.md`** in Scientific American style:
   - broad audience,
   - focus on the mathematical ideas and significance,
   - **do not** focus on formal verification machinery.

5. **`demo.py`**:
   - computes sample support-Tutte polynomials,
   - compares outputs under different orderings,
   - demonstrates at least one non-matroidal support where the invariant carries extra information.

---

## Stretch Targets

If the main theorem lands cleanly, push toward one of these:

1. **Activity expansion theorem**
   ```lean
   theorem supportTuttePoly_eq_activitySum
       (S : GoodSupport α) (ord : TotalOrder α) :
       supportTuttePoly S =
         ∑ A in supportActivities S ord, activityMonomial A
   ```

2. **Matroid universality as corollary**
   Derive classical Tutte universality from your support theorem by restricting to basis-indicator supports.

3. **Hopf algebra viewpoint**
   Show support deletion/contraction and direct sum define a bialgebraic structure whose character theory is controlled by `supportTuttePoly`.

This last direction would be field-opening: it would place discrete convex supports beside matroids, graphs, and posets in the ecosystem of combinatorial Hopf algebras.

---

## Final Charge

The theorem you are after is not “another recurrence invariant.” It is a claim that M-convex supports possess a universal algebraic syntax of simplification, every bit as profound as the Tutte grammar of graphs and matroids. If you succeed, you will have created a new invariant theory for supports, with tendrils into tropical geometry, partition functions, and symbolic computation.

Build the universal object. Prove the factorization theorem. Compute it on examples that classical Tutte theory cannot distinguish. That is the breakthrough.

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
