## Assignment: Direction 5: Ordinal Rank as Symbolic Complexity Certificate

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Central Thesis:** The ordinal rank of an EML expression is a *symbolic complexity certificate* — a static, computable invariant that tightly bounds the cost of all fundamental symbolic operations (differentiation, simplification, normalization). This establishes ordinal rank as the EML-analogue of *proof-theoretic ordinals* in Gentzen-style proof theory: just as the proof-theoretic ordinal of a theory bounds the complexity of cut elimination, `exprRank(e)` bounds the complexity of symbolic transformation of `e`.

**Precise Theorem Statements with Lean 4 Signatures:**

```lean
-- NEW DEFINITION: Symbolic differentiation for EML expressions
def emlDeriv (x : Var) : EmlExpr → EmlExpr
  | .var y => if x = y then .const 1 else .const 0
  | .const _ => .const 0
  | .add a b => .add (emlDeriv x a) (emlDeriv x b)
  | .mul a b => .add (.mul a (emlDeriv x b)) (.mul (emlDeriv x a) b)
  | .eml a b => .add (.eml (emlDeriv x a) b) (.mul (.eml a b) (emlDeriv x b))

-- NEW DEFINITION: Ordinal-weighted size measuring blowup potential
def ordinalWeightedSize (e : EmlExpr) : ℕ :=
  (size e) * ((exprRank e).natCoeff + 1)

-- THEOREM 1: Differentiation is rank-non-expanding (the foundational invariant)
theorem emlDeriv_preserves_rank (x : Var) (e : EmlExpr) :
    exprRank (emlDeriv x e) ≤ exprRank e := by
  -- Proof by structural induction on e, using the key lemma that
  -- max(rank a', rank b') ≤ max(rank a, rank b) when a' = deriv a, b' = deriv b

-- THEOREM 2: Polynomial size blowup within each ω-block (the practical bound)
theorem emlDeriv_size_bound (x : Var) (e : EmlExpr) :
    ∃ f : ℕ → ℕ, f ∈ O((size e)^(2^((exprRank e).omegaCoeff))),
      size (emlDeriv x e) ≤ f (size e) := by
  -- The exponent 2^(omegaCoeff) arises because each differentiation step
  -- at rank ω·k + n applies the product rule, doubling subexpressions,
  -- and this compounds across the nesting depth captured by the ordinal.

-- THEOREM 3 (CROSS-DOMAIN): EML-Tropical rank correspondence
-- The ordinal rank equals the tropical rank under the canonical embedding
theorem tropicalEmbed_rank_correspondence (e : EmlExpr) :
    tropicalRank (tropicalEmbed e) = (exprRank e).omegaCoeff := by
  -- This bridges ordinal classification to tropical geometry:
  -- The ω-coefficient of exprRank counts the number of "essential"
  -- tropical hypersurface intersections in the Newton polytope of e.

-- THEOREM 4: Normalization terminates within ordinal-bounded steps
theorem emlNormalize_terminates_bound (e : EmlExpr) :
    ∃ n ≤ normalizationBound (exprRank e) (size e),
      emlNormalize e = emlNormalizeStep^[n] e ∧
      ∀ m ≥ n, emlNormalizeStep^[m] e = emlNormalizeStep^[n] e := by
  -- Uses well-foundedness of the ordinal rank as a termination measure,
  -- combined with the fact that each normalization step either reduces
  -- the (rank, size) pair in the lexicographic order or is a fixed point.
```

**Proof Strategy A (Primary — Structural Induction on Ordinal Rank):**
This is the most promising approach for Theorem 1. Proceed by strong induction on `exprRank e` as an ordinal:
- **Base case** (rank 0, constants/variables): `emlDeriv` produces rank-0 expressions by construction.
- **Inductive step for `eml(a,b)`**: The derivative is `eml(a',b) + eml(a,b)·b'`. By the product rule for rank, `rank(eml(a',b)) ≤ max(rank a', rank b) ≤ max(rank a, rank b) = rank(eml(a,b))`, where the middle inequality uses the inductive hypothesis on `a` and `b` (which have strictly smaller rank). Similarly for the second summand. The max of two expressions bounded by `rank(eml(a,b))` is itself bounded by `rank(eml(a,b))`.
- **Key lemma needed**: `exprRank_max : exprRank (.add a b) = max (exprRank a) (exprRank b)` and `exprRank_eml : exprRank (.eml a b) = max (exprRank a) (exprRank b) + 1` (or similar, depending on the EML definition).

**Proof Strategy B (Alternative — Ordinal Descent / Subrecursive Hierarchy):**
Map EML expressions to functions in the *Grzegorczyk hierarchy* indexed by their ordinal rank. Each rank level corresponds to a growth rate class ($E_0$ = bounded, $E_1$ = linear, $E_2$ = polynomial, $E_3$ = exponential, ...). Differentiation moves within the same level or below because the product rule at level $n$ produces terms at level $n$, and the composition rule at level $n+1$ produces terms at level $n+1$ or below. This gives Theorem 2 as a corollary of known bounds on the Grzegorczyk hierarchy. *This strategy is elegant but requires building the Grzegorczyk embedding first, which is substantial.*

**Proof Strategy C (Most Visionary — Tropical/Ultrametric Contractivity):**
Define an ultrametric $d(e_1, e_2) = \omega^{-(\text{exprRank}(e_1 \ominus e_2))}$ on EML expressions, where $\ominus$ is a formal difference operation. Prove that `emlDeriv` is a *non-expanding map* in this ultrametric: $d(\text{deriv}(e_1), \text{deriv}(e_2)) \leq d(e_1, e_2)$. This simultaneously gives rank preservation (set $e_2 = 0$) and a contractivity estimate that bounds normalization steps via the Banach fixed-point theorem in the ultrametric completion. *This is the deepest approach and connects to p-adic analysis and tropical geometry, but requires the most infrastructure.*

**Recommendation:** Start with Strategy A for Theorem 1 (it's the most direct), then develop the tropical embedding for Theorem 3 (which is the cross-domain bridge), and finally tackle Theorem 2 using the rank bound from Theorem 1 plus a careful size analysis.

**Falsifiable Conjecture (Sharp Complexity Threshold):**

> **Conjecture (Ordinal Complexity Jump):** Let $B(r, s) = \max\{\text{size}(\text{emlDeriv}(x, e)) : \text{exprRank}(e) = r,\, \text{size}(e) = s\}$. Then:
> - $B(n, s) = \Theta(s^{2^n})$ for finite ordinals $n \in \omega$
> - $B(\omega, s) = \Theta(s^s)$ (the jump from exponential to superexponential)
> - $B(\omega \cdot k + n, s) = \Theta(\text{tower}_k(s^{2^n}))$ where $\text{tower}_k$ is $k$-fold iterated exponentiation
>
> **Test:** Generate random EML expressions of rank $0, 1, 2, 3, \omega$ and size $s \in \{5, 10, 20, 50, 100\}$. Compute `emlDeriv` and measure `size(output)/size(input)`. If the ratio follows $s^{2^n - 1}$ for finite $n$ and $s^{s-1}$ for $\omega$, the conjecture is supported. A deviation of more than a constant factor disproves it.

**Catalog References:** Build on `Pythagorean/OrdinalClassification/Theorems.lean` (`exprRank`, `ordinalClassify`). Extend with the new definitions `emlDeriv`, `ordinalWeightedSize`, `tropicalEmbed`, `emlNormalize`.

**Domain Bridges:** 
- **Proof theory → Computer algebra**: Ordinal rank as EML's proof-theoretic ordinal, bounding "cut elimination" (normalization) complexity
- **Tropical geometry → Ordinal analysis**: The ω-coefficient equals tropical rank under the canonical embedding; tropical hypersurface arrangements classify rank jumps
- **Automatic differentiation → Static analysis**: Rank preservation means AD cost is predictably bounded by a static property of the expression graph
- **Subrecursive hierarchies (Grzegorczyk) → Symbolic computation**: Each ω-block in the ordinal rank corresponds to a Grzegorczyk level, giving precise growth rate bounds

**Application Keywords:** symbolic differentiation complexity, ordinal analysis, proof-theoretic ordinals, tropical rank, Grzegorczyk hierarchy, automatic differentiation cost prediction, compiler optimization, static complexity analysis, ultrametric contractivity, normalization termination

**Lineage:** This transforms the ordinal classifier from a descriptive tool into a *predictive* one — the first practical application of ordinal analysis outside proof theory.

**Ambition:** Theorems 1 and 2 are likely provable with moderate effort (the rank preservation follows from clean structural properties). Theorem 3 (tropical correspondence) is genuinely new and would open a research direction connecting tropical geometry to ordinal analysis. Theorem 4 (normalization termination) requires careful well-foundedness arguments but is within reach.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each a falsifiable conjecture with a clear computational test.

(b) **RESEARCH_PAPER.md** — a standalone scientific document explaining the ordinal complexity certificate framework, the rank-preservation theorem, the tropical correspondence, and their implications for static analysis of symbolic computation.

(c) **ARTICLE.md** — a Scientific American-style piece: "Why Some Equations Are Harder to Differentiate Than Others — And How Ordinal Numbers Tell Us in Advance."

(d) **A verified algorithm**: `emlDeriv` with proven rank-preservation and size-blowup bounds, plus `emlNormalize` with proven termination.

(e) **demo.py** — generates EML expressions of increasing ordinal rank, computes their derivatives, and plots `size(deriv(e))/size(e)` as a function of `exprRank(e)`, visualizing the ordinal complexity jumps.

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
