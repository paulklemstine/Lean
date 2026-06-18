## Assignment: Alien Mathematics: What Theorems Would Non-Carbon Life Prove?

Mode: **prove**

Prove a genuinely new bridge theorem that turns the vague slogan “different semirings support different mathematics” into a precise, formal, Lean-native statement about which algebraic laws survive semiring change and which collapse to purely combinatorial content.

Minimize sorry. If a grand universal statement becomes too diffuse, isolate and prove the core finite theorem below first; that core is already conceptually strong and mathematically nontrivial.

---

## Research Direction

Construct a formal theory of **semiring-relative mathematical reality** on finite polynomial identities. The breakthrough target is to show that when one evaluates the same finitely supported polynomial expression over multiple semirings, the identities that survive uniformly are exactly the ones forced by **coefficient aggregation and support combinatorics**, while idempotent semirings collapse multiplicity information and thereby expose a tropical/combinatorial shadow of classical algebra.

This is the right formal nucleus for the “alien mathematics” vision:
- classical civilizations over `ℕ`, `ℤ`, `ℚ`, `ℝ` perceive multiplicity-sensitive identities;
- tropical/idempotent civilizations perceive only support and extremal structure;
- the overlap is not “all algebra,” but the combinatorial skeleton encoded by finite supports, reindexings, and idempotent collapse.

Do **not** try to formalize philosophy. Prove a theorem saying exactly what survives semiring transport.

---

## Precise Breakthrough Theorem Target

Work with finitely supported one-variable polynomials represented concretely as coefficient lists or finitely supported functions `ℕ →₀ ℕ` if convenient. The key theorem should compare:
1. classical evaluation in a non-idempotent semiring such as `ℕ`, and
2. tropical/idempotent evaluation where repeated monomials collapse under `sup`/`max`.

### Theorem A: Idempotent collapse depends only on support

For finite coefficient data, prove that in any idempotent commutative semiring, polynomial evaluation is invariant under replacing coefficients by the support indicator.

Informally:
> Over an idempotent commutative semiring, the value of a finite polynomial expression depends only on which monomials appear, not on how many times they appear.

This is the formal “alien shadow theorem”: multiplicity disappears for idempotent civilizations.

### Lean-oriented type signature

A robust concrete version is:

```lean
theorem eval_finset_sup_support
  {α : Type*} [CanonicallyOrderedCommSemiring α] [IsIdempotentOp α (· + ·)]
  (x : α) (s : Finset ℕ) (c : ℕ → α) :
  (∑ i in s, c i * x ^ i)
    =
  (∑ i in s.filter (fun i => c i ≠ 0), x ^ i) := by
```

If this exact typeclass combination is awkward, use a more concrete target first, e.g. `α = WithBot ℕ`, `α = ℝ` with `max`-plus encoded manually, or any existing tropical structure already present in the catalog.

A more combinatorial and likely easier theorem is:

```lean
theorem eval_eq_eval_support_of_add_idempotent
  {α : Type*} [CommSemiring α] [IsIdempotentOp α (· + ·)]
  (x : α) (s : Finset ℕ) :
  (∑ i in s, (x ^ i + x ^ i)) = ∑ i in s, x ^ i := by
```

and then iterate this to prove multiplicity-insensitivity for finitely many repeated monomials.

### Theorem B: Distinct provability landscapes via a separating identity

Prove that there exists a finite polynomial identity true in idempotent/tropical semirings and false in `ℕ`. The canonical separator is multiplicity collapse:

```lean
theorem tropical_not_nat_separator :
  (∀ a : ℝ, max a a = a) ∧ ¬ (∀ n : ℕ, n + n = n) := by
```

That version is too easy alone; strengthen it into a finite-expression separation theorem:

```lean
theorem exists_expression_separating_idempotent_from_nat :
  ∃ (s : Finset ℕ) (x : ℕ),
    ((∑ i in s, x ^ i) ≠ (∑ i in s.1.eraseDups, x ^ i)) := by
```

paired with the idempotent analogue where duplicates do collapse. If `eraseDups` is awkward on `Finset`, use lists for syntax and prove:
- list-based repeated monomials collapse in idempotent addition;
- the same list can evaluate differently in `ℕ`.

This gives a rigorous finite witness that semiring choice changes theoremhood.

### Theorem C: Combinatorial core as support invariance

Prove a finite support-invariance theorem stating that any equality of tropicalized expressions induced by permutation/reindexing/support-preserving bijection is semiring-independent.

For example:

```lean
theorem sum_powers_invariant_under_reindex
  {α : Type*} [CommSemiring α]
  (x : α) (s t : Finset ℕ)
  (h : s = t) :
  (∑ i in s, x ^ i) = ∑ i in t, x ^ i := by
```

That is trivial by `simpa [h]`, so sharpen it to a genuine support theorem:

```lean
theorem eval_support_equiv_invariant
  {α : Type*} [CommSemiring α]
  (x : α) (s t : Finset ℕ)
  (e : s ≃ t) :
  (∑ i in s, x ^ i) = ∑ j in t, x ^ j := by
```

The significance is not the statement itself, but that together with Theorem A it identifies the **support-level combinatorics** as the common residue after semiring variation.

---

## Why This Would Be a Breakthrough

This would create a formal, machine-checked prototype of a new subject:

**semiring-relative foundations of mathematics**.

Not model theory in full generality, and not merely tropical algebra. Rather, a theorem-driven account of which mathematical facts:
- depend on multiplicity,
- survive idempotent collapse,
- and reduce to finite combinatorial support.

This opens a path toward:
- tropical shadows of classical theorems,
- machine-verifiable algebraic “universes” indexed by base semiring,
- semantic compression of proof content into multiplicity-sensitive vs support-only components,
- and eventually a formal taxonomy of mathematics by algebraic substrate.

This is the first real step toward the science-fiction claim: different intelligences, built on different algebraic physics, would discover different theorem corpora.

---

## Building Blocks from the Catalog

Use the verified tropical idempotence results aggressively as base lemmas:
- `tropical_idempotent`
- `tropical_add_idempotent`
- `tropical_self_max_idempotent`
- `tropical_idempotent_quantum_obstruction`

How to use them:
1. **As the algebraic collapse axiom**: any theorem asserting repeated terms can be merged should reduce to the idempotence lemma.
2. **As the bridge from syntax to semantics**: list/finset expressions with duplicate monomials become equal after repeated use of tropical idempotence.
3. **As obstruction evidence**: the “quantum obstruction” theorem suggests idempotent collapse is not innocent; it destroys interference/multiplicity structure. Use this in the writeup to frame why distinct semirings really do induce distinct theorem landscapes.

---

## Proof Strategy Paths

### Strategy A: Finite-list normal form via deduplication
Most promising for Lean.

1. Represent a polynomial expression as a `List ℕ` of exponents, evaluated by
   ```lean
   def evalExpr (α) [CommSemiring α] (x : α) : List ℕ → α
   | [] => 0
   | i :: is => x ^ i + evalExpr α x is
   ```
2. In an idempotent additive semiring, prove:
   ```lean
   evalExpr α x L = evalExpr α x L.dedup
   ```
   by induction on `L`, using idempotence to remove duplicates.
3. Exhibit a concrete list, e.g. `[0,0]`, whose evaluation at `x = 1` differs in `ℕ` but agrees after deduplication in tropical/idempotent settings.

Why this is best:
- avoids heavy polynomial API overhead;
- isolates the exact combinatorial content;
- gives a clean “syntax vs substrate” theorem.

### Strategy B: Finset/finsupp support semantics
More elegant, slightly more abstract.

1. Define evaluation from a finitely supported exponent function `f : ℕ →₀ ℕ` by
   ```lean
   f.sum (fun i m => ...)
   ```
2. Prove that under additive idempotence, only the predicate `f i ≠ 0` matters.
3. Derive a support-factorization theorem:
   evaluation factors through `f.support`.

This is more canonical mathematically and gets closer to “intersection = combinatorial core,” but may require more algebraic plumbing in Lean.

### Strategy C: Polynomial API and semiring homomorphism shadow
Most visionary, highest risk.

1. Use `MvPolynomial` or `Polynomial`.
2. Define a “support shadow” map from classical coefficient semirings to an idempotent target by sending each nonzero coefficient to `1`.
3. Prove evaluation after shadowing depends only on support.

This is the most conceptually powerful because it resembles tropicalization and decategorification, but it may be too infrastructure-heavy for one cycle unless Mathlib support aligns perfectly.

**Recommendation:** Start with Strategy A, then package the result as a support-factorization theorem à la Strategy B. Mention Strategy C as the next escalation.

---

## Cross-Domain Connections

1. **Tropical Geometry**  
   The theorem says tropicalization forgets multiplicity and retains support/extremal data. This is the finite syntactic analogue of tropical shadow phenomena in algebraic geometry.

2. **Logic / Proof Theory**  
   Semiring change acts like a semantics transformer on statements. Idempotent collapse resembles proof irrelevance for repeated additive evidence; multiplicity-sensitive proofs vanish.

3. **Information Theory**  
   Classical coefficients carry multiplicity/weight information; idempotent evaluation keeps only support. This is analogous to passing from full distributions to support sets or zero-temperature limits.

4. **Quantum vs Classical Obstruction**  
   Multiplicity and interference are destroyed by idempotent collapse. This echoes why tropical/idempotent worlds cannot express phase-sensitive phenomena.

5. **Theoretical Computer Science**  
   This is a semantics of weighted automata under semiring change: Boolean/idempotent semirings track reachability, while `ℕ` tracks path counts. Your theorem is the algebraic core of that distinction.

---

## Concrete Implementation Advice

Prefer concrete, Lean-friendly definitions over maximal abstraction.

### Suggested definitions
```lean
def evalExprNat (x : ℕ) : List ℕ → ℕ
| [] => 0
| i :: is => x ^ i + evalExprNat x is

def evalExprTrop (x : ℝ) : List ℕ → ℝ
| [] => 0
| i :: is => max (x ^ i) (evalExprTrop x is)
```

Then prove:
1. `evalExprTrop x (L ++ L) = evalExprTrop x L`
2. `∃ L x, evalExprNat x (L ++ L) ≠ evalExprNat x L`
3. if `L.dedup = M.dedup`, then `evalExprTrop x L = evalExprTrop x M`

This already gives a theorem schema:
- idempotent semantics = support semantics,
- classical semantics ≠ support semantics in general.

If powers over tropicalized reals become awkward, replace `x ^ i` with an arbitrary weight function `w : ℕ → α`. That may actually be cleaner:

```lean
def evalList {α : Type*} [Add α] [OfNat α 0] (w : ℕ → α) : List ℕ → α
```

and in the tropical case use `max` recursively. Then the theorem becomes a pure statement about duplicate labels under `max`, independent of exponentiation details.

---

## Strong Intermediate Lemmas Worth Proving

```lean
theorem max_eval_list_duplicate
  (w : ℕ → ℝ) (a : ℕ) (L : List ℕ) :
  max (w a) (max (w a) (evalListMax w L))
    = max (w a) (evalListMax w L) := by
```

```lean
theorem evalListMax_dedup
  (w : ℕ → ℝ) (L : List ℕ) :
  evalListMax w L.dedup = evalListMax w L := by
```

```lean
theorem evalListNat_not_dedup_invariant :
  ∃ (w : ℕ → ℕ) (L : List ℕ),
    evalListNat w L.dedup ≠ evalListNat w L := by
```

```lean
theorem support_shadow_complete
  (w₁ w₂ : ℕ → ℝ)
  (h : ∀ n, (w₁ n = 0 ↔ w₂ n = 0)) :
  ∀ L, evalListMax w₁ L = evalListMax w₂ L := by
```

That last theorem may need a different codomain/assumption; as stated it is probably too strong. A corrected version would assume equality on active support values, or define weights as indicator values. Be ruthless about adjusting the exact statement to something true and formalizable.

---

## Application Keywords

- tropicalization
- idempotent algebra
- semiring semantics
- support invariance
- multiplicity collapse
- weighted automata
- proof semantics
- combinatorial core
- algebraic foundations
- nonclassical arithmetic
- decategorification
- zero-temperature limit

---

## Deliverables

1. A Lean file proving at least one substantial support-collapse theorem and one explicit separation theorem between `ℕ` and an idempotent/tropical structure.
2. Clean definitions for finite expression evaluation over at least two semiring-like worlds.
3. A short module-level note explaining the interpretation: multiplicity-sensitive vs support-only mathematics.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - a multivariate support-shadow theorem for `MvPolynomial`,
   - a weighted-automata semiring-invariance classification theorem,
   - a tropical shadow functor from classical polynomial identities,
   - a characterization of which ring identities survive passage to idempotent semirings,
   - a proof-theoretic semantics where repeated hypotheses collapse idempotently.

---

## Final Call

Do not settle for the slogan. Extract the theorem hidden inside it:

**alien mathematics differs when multiplicity matters; idempotent alien mathematics sees only support.**

Formalize that statement so cleanly that it becomes a reusable foundation stone. Once that is done, the larger vision — semiring-indexed theorem universes — stops being metaphysics and becomes mathematics.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Speculative
Research mode: prove
