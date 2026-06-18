## Soli Deo Gloria

## Assignment: Depth Hierarchy with Controlled Inverses — The Spectral Margin Framework

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

### The Central Result

**Theorem (Controlled-Inverse Depth Hierarchy):** Let `e` be an EML expression possibly containing inverses, where every inverse is applied to a subexpression whose evaluation is bounded away from zero on positive reals by some uniform positive constant δ. If `e` has depth `D`, then `e` cannot represent `iterExp(D, x)` for sufficiently large `x`. The tight bound `n > D` persists.

**Lean 4 Type Signature:**

```lean
-- The spectral margin: infimum of |eval| on positive reals (NEW DEFINITION)
def spectralMargin (e : EML) : ℝ :=
  sInf { y | ∃ x > 0, |eval e x| ≤ y }

-- An expression has "controlled inverses" if every inverse argument
-- has positive spectral margin
def HasControlledInverses : EML → Prop
  | var => True
  | const _ => True
  | add e₁ e₂ => HasControlledInverses e₁ ∧ HasControlledInverses e₂
  | mul e₁ e₂ => HasControlledInverses e₁ ∧ HasControlledInverses e₂
  | exp e => HasControlledInverses e
  | inv e => spectralMargin e > 0 ∧ HasControlledInverses e

-- MAIN THEOREM: Controlled inverses don't help
theorem controlledInv_depth_hierarchy (D : ℕ) (e : EML)
    (h_ctrl : HasControlledInverses e)
    (h_depth : depth e ≤ D) :
    ∃ N, ∀ x > N, eval e x < iterExp D x := by
  sorry
```

---

### Proof Strategies (Three Paths)

**Strategy A — Poly-Tower Majorant Extension (RECOMMENDED):**
Build directly on `HasPolyTowerMajorant` from `Speculative/TightDepthHierarchy/Theorems.lean`.

1. **Key Lemma (Inverse Majorant Preservation):** If `e` has a poly-tower majorant of height `h` and `spectralMargin e ≥ δ > 0`, then `inv(e)` has a poly-tower majorant of height `h`. Proof: `1/eval(e,x) ≤ 1/δ` is a constant, and any constant is bounded by `PolyTower h (c · x^0)` for any `h ≥ 1`. The inverse does *not* push the majorant to height `h+1` — this is the crucial observation.

2. **Inductive tower construction:** By structural induction on `e`, every controlled-inverse EML expression of depth `D` has a poly-tower majorant of height `D`. The `exp` case pushes height by 1 (as before); the `inv` case preserves height (new).

3. **Comparison with iterExp:** Apply the existing result that `iterExp(D, x)` eventually exceeds any poly-tower of height `D`. This step reuses the catalog theorem directly.

**Why Strategy A is most promising:** It requires only one genuinely new lemma (step 1), and steps 2–3 are minor modifications of existing proof infrastructure. The key insight — that bounded-away-from-zero inverses are "spectrally invisible" to the tower height — is both deep and simple.

**Strategy B — Reduction to Inverse-Free via Polynomial Absorption:**

1. Show that any controlled-inverse expression `e` of depth `D` can be rewritten as `p(x) · e'(x)` where `e'` is inverse-free of depth `D` and `p` is a polynomial whose degree depends on the number of controlled inverses.
2. Since `iterExp(D, x)` grows faster than any polynomial times a poly-tower of height `D`, the hierarchy persists.
3. *Risk:* The rewriting in step 1 requires showing that products of `1/δ_i` factors can be absorbed into a polynomial, which needs careful handling of the interaction between inverses at different depths.

**Strategy C — Growth Class Monoid (most abstract, highest risk/highest reward):**

1. Define a commutative monoid of "growth classes" `GrowthClass` with multiplication = pointwise multiplication and a partial order = eventual domination.
2. Show that `GrowthClass` has a filtration by tower height, and that controlled inverses lie in the identity class (constants).
3. Prove that the filtration is a monoid homomorphism, so depth respects the filtration.
4. *This opens a new algebraic framework for studying expression complexity.*

---

### Novel Definitions Required

1. **`spectralMargin`** (defined above): The infimum of `|eval e x|` over positive reals. This is the key new concept — it generalizes the "bounded away from zero" condition to a quantitative measure. It is the EML analogue of the spectral gap in operator theory and the condition number in numerical analysis.

2. **`GrowthClass`**: The monoid of asymptotic growth rates under pointwise multiplication, filtered by tower height. This provides an algebraic framework for comparing expression complexity.

---

### Cross-Domain Connections (Deep Structure)

**1. Operator Theory — Spectral Gaps and Fredholm Inverses:**
The condition `spectralMargin e > 0` is precisely the condition that makes `inv(e)` a "Fredholm inverse" in the sense of operator algebras. In bounded operator theory, an operator `T` is Fredholm if it is invertible modulo compact operators, which requires `inf |σ(T)| > 0`. Our result says: *Fredholm-class inverses don't increase EML depth complexity.* This suggests a dictionary:

| EML Concept | Operator Theory |
|---|---|
| `spectralMargin e > 0` | `T` is bounded below / Fredholm |
| `inv(e)` with controlled margin | `T⁻¹` bounded operator |
| `inv(e)` with zero margin | `T⁻¹` unbounded (resolvent blows up) |
| Depth hierarchy | Spectral radius hierarchy |

**2. Arithmetic Circuit Complexity — Division Gates:**
Bürgisser-Clausen-Shokrollahi ask: does allowing division gates increase arithmetic circuit complexity? Our result answers this for a *natural restricted class*: division by bounded-away-from-zero expressions. This is the EML analogue of showing that "safe division" (division with well-conditioned divisors) doesn't increase circuit complexity. The open question that remains: does *unrestricted* division increase EML depth complexity? (We conjecture yes — see below.)

**3. Tropical Geometry — Min-Plus Spectral Theory:**
In tropical algebra, `inv(e)` becomes `-e` (tropical division = tropical subtraction). The condition `spectralMargin e > 0` becomes `inf e > -∞` in the tropical semiring. This connects to the tropical eigenvalue problem: the tropical spectral radius of a matrix is the maximum cycle mean, and expressions with bounded tropical spectral margin correspond to "tropically stable" expressions.

**4. Numerical Analysis — Condition Numbers:**
The spectral margin is the reciprocal of the condition number: `κ(e) = 1/spectralMargin(e)`. Our result says that well-conditioned inverses (κ bounded) don't increase depth complexity, but ill-conditioned inverses (κ → ∞) *might*. This connects the depth hierarchy to the theory of numerical stability.

---

### Testable Conjecture (Falsifiable Prediction)

**Conjecture (Uncontrolled Inverse Collapse):** If inverses are allowed on *any* nonvanishing expression (i.e., `eval e x ≠ 0` for all `x > 0`, but no uniform lower bound), then the depth hierarchy *collapses*: there exists an expression of depth `D` with uncontrolled inverses that represents `iterExp(D+1, x)`.

**Computational Test:** Enumerate EML expressions with uncontrolled inverses up to depth 3 and size 25. For each, evaluate at test points `x ∈ {2, 3, 5, 10, 100, 1000}`. Check if any expression with uncontrolled inverses at depth 3 matches `iterExp(4, x)` within relative error `10⁻⁶`. The candidate counterexample is `inv(inv(x) + inv(exp(x)))` — if this grows fast enough, it would falsify the conjecture. If no expression matches after exhaustive search up to size 25, this supports the conjecture.

**Why this matters:** If true, it would show that the *uniformity* of the lower bound δ > 0 is essential — merely requiring nonvanishing is insufficient. This is analogous to the distinction between Fredholm operators (bounded below) and merely injective operators (not bounded below) in functional analysis.

---

### Secondary Theorem (Cross-Domain Bridge)

**Theorem (Spectral Margin and Condition Number):** For any EML expression `e` with `spectralMargin e = δ > 0`, the condition number of the evaluation map satisfies `κ(e) ≤ M/δ` where `M` is the poly-tower majorant bound for `e`.

```lean
theorem spectral_margin_condition_number (e : EML) (δ : ℝ) (h_margin : spectralMargin e = δ)
    (h_pos : δ > 0) (h_ctrl : HasControlledInverses e)
    (h_depth : depth e = D) :
    ∃ M, ∀ x > 0, |eval e x| ≤ M ∧ |(eval e x)⁻¹| ≤ 1/δ := by
  sorry
```

This bridges EML depth complexity to numerical analysis: the condition number is controlled by the spectral margin, and our main theorem says that expressions with bounded condition numbers (under inverses) don't escape their depth class.

---

### Depth Requirements Verification

1. **Non-trivial proofs**: The main theorem requires induction on expression structure with case analysis on controlled vs. uncontrolled inverses. The spectral margin lemma requires `sInf` reasoning. The growth class monoid requires construction of a new algebraic structure.

2. **Deep proof tactics**: `induction` (expression structure), `rcases` (case split on inverse type), `by_contra` (asymptotic comparison), `calc` (tower height bounding), `field_simp` (inverse manipulation).

3. **Novel definitions**: `spectralMargin`, `HasControlledInverses`, `GrowthClass`.

4. **Cross-domain connection**: Spectral gap ↔ controlled inverses ↔ condition numbers (operator theory + numerical analysis + circuit complexity).

5. **Testable conjecture**: Uncontrolled Inverse Collapse conjecture with explicit enumeration protocol.

---

### Revolutionary Significance

This result establishes the **Spectral Margin Framework** for expression complexity: the representational power of an operation class is determined not by its syntactic form, but by its *spectral properties* — whether it preserves boundedness conditions on the evaluation map. This framework:

- **Opens a new field:** Spectral Complexity Theory — the study of how spectral properties of evaluation maps constrain expression complexity.
- **Enables applications:** Certified robustness guarantees for symbolic computation (any "well-conditioned" symbolic expression has bounded depth complexity); complexity-theoretic foundations for verified numerical methods.
- **Suggests follow-on work:** (a) Tropical spectral margin and tropical depth hierarchy; (b) Quantum circuit depth with controlled unitary inverses; (c) The full "uncontrolled inverse" conjecture; (d) Spectral margin for multivariate expressions and partial evaluation.

---

### Mandatory Deliverables

**(a) FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
1. Uncontrolled Inverse Collapse conjecture (enumeration test described above)
2. Tropical spectral margin conjecture: in tropical EML, `tropicalSpectralMargin e > -∞` implies depth hierarchy persists (test: enumerate tropical expressions up to depth 4)
3. Multivariate spectral margin: for `e : ℝⁿ → ℝ`, if `spectralMargin e > 0` on the positive orthant, depth hierarchy persists (test: random multivariate expressions)
4. Condition number threshold: there exists a critical `κ*` such that inverses with `κ < κ*` don't increase depth but inverses with `κ > κ*` might (test: binary search on κ)
5. Quantum depth analogy: controlled unitary inverses in quantum circuits don't increase depth complexity (test: quantum circuit simulation)

**(b) RESEARCH_PAPER.md** — standalone paper titled "Spectral Margins and Depth Hierarchies: When Controlled Inverses Don't Help"

**(c) ARTICLE.md** — Scientific American style: "The Hidden Spectral Rules That Govern Mathematical Expression Complexity"

**(d) Verified algorithm: `controlledInvMajorant` — computes the poly-tower majorant height for any controlled-inverse expression, certified in Lean

**(e) demo.py** — interactive demonstration: input any controlled-inverse EML expression, output its spectral margin, majorant height, and comparison with `iterExp(D, x)`; includes the enumeration test for the Uncontrolled Inverse Collapse conjecture

---

### Catalog Building Blocks

From `Speculative/TightDepthHierarchy/Theorems.lean`:
- `no_invFree_lowDepth_represents_iterExp`: The base theorem to extend
- `HasPolyTowerMajorant`: The majorant infrastructure to extend with inverse case
- `iterExp_exceeds_polyTower`: The comparison lemma to reuse directly

From `Speculative/TightDepthHierarchy/Defs.lean`:
- `noInv` predicate: Extend to `HasControlledInverses`
- `depth` function: Extend to handle `inv` case (depth preserved, not increased)
- `EML` inductive type: Extend with controlled `inv` constructor

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
