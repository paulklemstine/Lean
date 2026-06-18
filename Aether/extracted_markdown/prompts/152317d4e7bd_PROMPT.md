## Assignment: Convergent Rewrite Systems as Quotient Optimizers — The Master Theorem of Certified Algebraic Optimization

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

## The Vision

Every verified compiler, every SMT solver, every Gröbner basis computation relies on a single deep principle that has never been formally proven in full generality: **a convergent rewrite system computes canonical representatives of algebraic congruence classes, and this canonicalization preserves semantics.** Commutative normalization was proven in `commNorm_preserves_eval`. Gröbner basis correctness is assumed in every algebraic geometry computation. SMT solvers trust congruence closure. This project unifies them all under one certified roof.

---

## Formalization Target: Core Structures

```lean
/-- A single-sorted algebraic signature: operation names with arities -/
structure Signature where
  ops : Type
  arity : ops → ℕ

/-- Terms over a signature with variable supply X -/
inductive Term (Σ : Signature) (X : Type) where
  | var : X → Term Σ X
  | app : (op : Σ.ops) → (Fin (Σ.arity op) → Term Σ X) → Term Σ X

/-- An equational theory: a finite set of oriented and unoriented equations -/
structure EqTheory (Σ : Signature) (X : Type) where
  equations : List (Term Σ X × Term Σ X)

/-- A convergent rewrite system derived from an equational theory -/
structure ConvergentSystem (Σ : Signature) (X : Type) where
  theory : EqTheory Σ X
  rules : List (Term Σ X × Term Σ X)  -- oriented rules
  h_terminating : IsTerminating rules
  h_confluent : IsConfluent rules
  h_sound : ∀ ⦃t u⦄, reduces rules t u → theory.congruent t u
  h_complete : ∀ ⦃t u⦄, theory.congruent t u → converts rules t u

/-- A Σ-algebra: a carrier with interpretations for each operation -/
structure Algebra (Σ : Signature) where
  carrier : Type
  interp : (op : Σ.ops) → (Fin (Σ.arity op) → carrier) → carrier

/-- Evaluation of a term in an algebra under a valuation -/
def eval {Σ : Signature} {X : Type} (A : Algebra Σ) (ι : X → A.carrier) :
    Term Σ X → A.carrier

/-- An algebra satisfies an equational theory -/
def Satisfies {Σ X} (A : Algebra Σ) (E : EqTheory Σ X) : Prop :=
  ∀ eq ∈ E.equations, ∀ (ι : X → A.carrier),
    eval A ι eq.fst = eval A ι eq.snd
```

---

## Theorem 1 (Soundness of Rewrite Steps)

Every single rewrite step in a sound system preserves evaluation in every model of the theory.

```lean
theorem step_preserves_eval {Σ : Signature} {X : Type} [Finite X]
    (R : ConvergentSystem Σ X) (A : Algebra Σ) (hA : A.Satisfies R.theory)
    (ι : X → A.carrier) {t u : Term Σ X} (h : Step R.rules t u) :
    eval A ι t = eval A ι u :=
  sorry  -- Key: decompose into context closure of a rule instance, then
         -- use that R.theory.congruent l r implies eval A ι l = eval A ι r
```

**Proof strategy**: By cases on `h`. A step `t → u` means `t = C[lσ]` and `u = C[rσ]` for some rule `l → r`, context `C`, and substitution `σ`. Since `R.h_sound` gives `theory.congruent l r`, and `A` satisfies `theory`, we get `eval A (ι ∘ σ) l = eval A (ι ∘ σ) r`. The context `C` preserves this equality by structural induction on `C`.

---

## Theorem 2 (Master Theorem: Convergent Systems Preserve Semantics)

The crown jewel. Generalizes `commNorm_preserves_eval` from `Pythagorean/QuotientOptimizer.lean` to arbitrary equational theories.

```lean
theorem convergent_nf_preserves_eval {Σ : Signature} {X : Type} [Finite X]
    (R : ConvergentSystem Σ X) (A : Algebra Σ) (hA : A.Satisfies R.theory)
    (ι : X → A.carrier) (t : Term Σ X) :
    eval A ι (nf R t) = eval A ι t :=
  sorry  -- The master theorem
```

**Proof Strategy A (Quotient Lifting — MOST PROMISING)**:
1. Define `≡_E` as the congruence closure of `R.theory.equations` on `Term Σ X`.
2. Prove `quotient_map_nf : ∀ t, ⟦nf R t⟧ = ⟦t⟧` — the normal form maps to the same quotient class. This follows from `R.h_complete` (every equation in `E` is convertible via `R`) and confluence (convertible terms share a normal form).
3. Prove `eval_factors : ∀ t u, t ≡_E u → eval A ι t = eval A ι u` — evaluation respects the congruence because `A` satisfies `E`. This is the algebraic content: satisfaction = congruence-invariance.
4. Combine: `eval A ι (nf R t) = eval A ι t` because `nf R t ≡_E t`.

**Why Strategy A dominates**: It factors the proof into two conceptually clean lemmas (quotient coherence + evaluation factorization) that each have independent value. The quotient structure is already in Mathlib (`Quotient`, `Quotient.lift`). This mirrors the proof in `QuotientOptimizer.preserves_eval` but at full generality.

**Proof Strategy B (Derivation Induction)**:
1. Prove `step_preserves_eval` (Theorem 1 above).
2. By well-founded induction on the rewrite derivation (using `R.h_terminating` via `Acc`), prove `eval A ι (nf R t) = eval A ι t` for all `t`.
3. The inductive step: if `t → u`, then `nf R t = nf R u` (by confluence uniqueness), and by induction `eval A ι (nf R u) = eval A ι u`, and by `step_preserves_eval` `eval A ι t = eval A ι u`.
4. Base case: if `t` is already in normal form, then `nf R t = t`.

**Proof Strategy C (Categorical Universal Property)**:
1. Prove that `Term Σ X // ≡_E` is the initial `E`-algebra (free algebra modulo `E`).
2. The evaluation map `eval A ι : Term Σ X → A.carrier` factors uniquely through this quotient.
3. The normal form map `nf R` provides a section `Term Σ X // ≡_E → Term Σ X` of the projection.
4. Therefore `eval A ι ∘ nf R = eval A ι` by the universal property.

**Strategy A is recommended** because it requires the least categorical machinery and best leverages existing Mathlib quotient infrastructure.

---

## Theorem 3 (Cross-Domain: Gröbner Bases as Convergent Systems)

This bridges term rewriting to computational algebraic geometry, establishing that Gröbner basis reduction is an instance of our master theorem.

```lean
/-- Bridge: a Gröbner basis induces a convergent system on the polynomial ring -/
theorem grobner_is_convergent_system {n : ℕ} {k : Field}
    (G : Finset (MVPolynomial (Fin n) k))
    (hGB : IsGrobnerBasis G) :
    ∃ R : ConvergentSystem (PolynomialSignature n k) (Fin n → k),
      R.theory.equations.map Prod.fst = G.map (fun p => (p, 0)) ∧
      ∀ p, nf R (poly_to_term p) = poly_to_term (nf_G G p) := sorry

/-- Consequence: Gröbner normal forms preserve polynomial identity modulo the ideal -/
theorem grobner_nf_preserves_class {n : ℕ} {k : Field} [DecidableEq k]
    (G : Finset (MVPolynomial (Fin n) k))
    (hGB : IsGrobnerBasis G) (I : Ideal (MVPolynomial (Fin n) k))
    (hGI : Ideal.span ↑(G.image Polynomial.C) = I)
    (p : MVPolynomial (Fin n) k) :
    ⟦nf_G G p⟧ = ⟦p⟧  -- equality in the quotient ring k[x₁,...,xₙ]/I :=
  -- Follows from convergent_nf_preserves_eval specialized to the
  -- algebra k[x₁,...,xₙ]/I with the Gröbner convergent system
  sorry
```

This connects to `Pythagorean/VerifiedCompilerSynthesis.lean` — the `endomorphism_preserves_semantics` result is a special case where the algebra is an endomorphism ring.

---

## Theorem 4 (Compositionality: Modular Convergence)

A new result about composing optimizations — critical for multi-pass compilers.

```lean
/-- If R₁ is convergent for E₁ and R₂ for E₂, and their union is convergent,
    then the composed normal form equals the union normal form -/
theorem modular_composition {Σ X} [Finite X]
    {R₁ R₂ : ConvergentSystem Σ X}
    (h_disjoint : DisjointRules R₁.rules R₂.rules)
    (h_union_conv : IsConvergent (R₁.rules ++ R₂.rules))
    (A : Algebra Σ) (hA₁ : A.Satisfies R₁.theory) (hA₂ : A.Satisfies R₂.theory)
    (ι : X → A.carrier) (t : Term Σ X) :
    eval A ι (nf_union R₁ R₂ h_union_conv t) = eval A ι t :=
  sorry  -- Apply master theorem to the union system,
         -- using that A satisfies both theories
```

---

## Novel Definition: CertifiedOptimizer

```lean
/-- A certified optimizer: a convergent system together with a proof
    that it preserves semantics for all models of its theory.
    This is the central object of study — the algebraic analogue of
    a verified compiler pass. -/
structure CertifiedOptimizer (Σ : Signature) (X : Type) [Finite X] where
  system : ConvergentSystem Σ X
  certified : ∀ (A : Algebra Σ) (hA : A.Satisfies system.theory)
              (ι : X → A.carrier) (t : Term Σ X),
              eval A ι (nf system t) = eval A ι t

/-- The canonical certified optimizer constructed from any convergent system -/
def mkOptimizer {Σ X} [Finite X] (R : ConvergentSystem Σ X) :
    CertifiedOptimizer Σ X where
  system := R
  certified := convergent_nf_preserves_eval R
```

---

## Falsifiable Conjecture

**Conjecture (Normal Form Minimality)**: For any `CertifiedOptimizer` over a finite signature where all rules are size-reducing (i.e., `|r| < |l|` for every rule `l → r`), the normal form `nf R t` is the unique term of minimum size in its `≡_E`-equivalence class.

```lean
/-- FALSIFIABLE: If any size-reducing convergent system has a normal form
    that is NOT the unique minimum-size term in its equivalence class,
    this theorem is false. -/
conjecture nf_is_size_minimal {Σ X} [Finite X]
    (R : ConvergentSystem Σ X)
    (h_size_reducing : ∀ ⦃l r⦄, (l, r) ∈ R.rules → size r < size l)
    (t : Term Σ X) :
    ∀ u, R.theory.congruent t u → size (nf R t) ≤ size u
```

**Test**: Implement 50 random size-reducing convergent systems over signatures with ≤ 5 operations. For each, generate 10,000 random terms, compute all terms in their equivalence classes (for small algebras, this is feasible), and check if the normal form is always size-minimal. Any counterexample disproves the conjecture.

**Expected outcome**: The conjecture is likely **FALSE** because size-reduction alone doesn't guarantee global minimality — a term might reduce to a local minimum that isn't globally minimal. The counterexample would reveal deep structure about the landscape of equational classes.

---

## Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable hypotheses including:
   - The size-minimality conjecture above with a concrete falsification protocol
   - A hypothesis about the computational complexity of normal-form computation for overlapping convergent systems (P vs. EXP conjecture)
   - A conjecture connecting CertifiedOptimizers to Galois connections between term orderings

(b) **RESEARCH_PAPER.md** — a standalone document proving that convergent rewrite systems are semantics-preserving optimizers, with the Gröbner basis application as a worked example, readable without code access.

(c) **ARTICLE.md** — Scientific American style: "The Universal Optimization Theorem: How One Mathematical Principle Powers Your Compiler, Your SMT Solver, and Your Algebraic Geometry Toolkit."

(d) **Verified algorithm**: `def computeNF {Σ X} [Finite X] [DecidableEq (Term Σ X)] (R : ConvergentSystem Σ X) : Term Σ X → Term Σ X` with a proof that it terminates and computes the correct normal form.

(e) **demo.py**: Generate random convergent rewrite systems (start with Knuth-Bendix completion of random equation sets), compute normal forms, verify semantic preservation in random finite algebras, and test the size-minimality conjecture.

---

## Catalog Integration

Build directly on:
- `Pythagorean/QuotientOptimizer.lean` — `commNorm_preserves_eval`: generalize the quotient-lifting proof technique from the commutativity case to arbitrary equational theories
- `Pythagorean/QuotientOptimizer.lean` — `QuotientOptimizer.preserves_eval`: extend the `QuotientOptimizer` structure to `CertifiedOptimizer`
- `Pythagorean/VerifiedCompilerSynthesis.lean` — `endomorphism_preserves_semantics`: this is the special case where the algebra is an endomorphism ring; the master theorem generalizes it

---

## Why This Is a Breakthrough

This theorem is the **Helly's theorem of algebraic optimization**: just as Helly's theorem unifies Carathéodory, Radon, and Kirchberger under one roof, the Convergent Optimizer theorem unifies:
- **Compiler verification**: peephole optimizations are convergent rewrite systems
- **SMT solving**: congruence closure is convergent rewriting over ground equations  
- **Algebraic geometry**: Gröbner bases are convergent systems for polynomial ideals
- **Automated theorem proving**: superposition calculus = convergent rewriting + ordering

One theorem, four fields. That's a paradigm shift.

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
