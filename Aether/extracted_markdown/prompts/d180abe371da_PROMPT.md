# Soli Deo Gloria

## Assignment: Direction 3: Temporal Logic Model Checking for Simply Typed Lambda Calculus — The König's Lemma Bridge

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

## The Deep Mathematical Insight

The central revelation is this: **Simply typed lambda calculus sits at the exact boundary where model checking becomes possible.** Untyped lambda calculus is Turing-complete — its reduction graphs can be infinite, making temporal verification undecidable. But strong normalization for STLC collapses the potentially infinite reduction graph into a *finite* one via a König's Lemma argument. This is not merely a technical fact — it is a **bridge theorem** connecting proof theory, rewriting theory, and temporal logic in a way that opens certified verification for functional programs.

The key mathematical fact that makes everything work:

**Strong Normalization + Finite Branching → Finite Reduction Graph (König's Lemma)**

For any rewrite system that is (a) strongly normalizing (every reduction sequence terminates) and (b) finitely branching (each term has finitely many one-step reducts), the reduction graph of any term is finite. This is the contrapositive of König's Lemma: an infinite, finitely branching tree must have an infinite path.

For STLC specifically:
- **Strong normalization**: Proved by Tait/Girard reducibility candidates — every well-typed term terminates.
- **Finite branching**: Each term has at most `size(t)` one-step reducts (one per redex), so the branching factor is bounded by term size.
- **Subject reduction**: Every reduct of a well-typed term is well-typed (types are preserved under reduction), ensuring we stay in the well-behaved fragment.

The normalization depth bound relates to the **proof-theoretic ordinal ε₀** — the maximum reduction length for a term of type τ is bounded by a function in the fast-growing hierarchy at level ε₀. This is not just a curiosity: it means the complexity of CTL* model checking for STLC terms is astronomically large but *computable*, placing it in a precise relationship with the arithmetical hierarchy.

---

## Core Definitions (Novel Structures)

```lean
-- Simply typed lambda calculus types
inductive STLCType where
  | base (n : ℕ) : STLCType
  | arrow (σ τ : STLCType) : STLCType

deriving DecidableEq, Repr

-- Typing contexts
abbrev Context := List STLCType

-- Well-typed terms with de Bruijn indices
inductive TypedTerm (Γ : Context) : STLCType → Type where
  | var : ∀ {τ}, τ ∈ Γ → TypedTerm Γ τ
  | app : ∀ {σ τ}, TypedTerm Γ (STLCType.arrow σ τ) → TypedTerm Γ σ → TypedTerm Γ τ
  | lam : ∀ σ {τ}, TypedTerm (σ :: Γ) τ → TypedTerm Γ (STLCType.arrow σ τ)

namespace TypedTerm

-- Substitution (capture-avoiding via de Bruijn)
def subst {Γ Δ σ} (ρ : ∀ τ, τ ∈ Γ → TypedTerm Δ τ) : TypedTerm Γ σ → TypedTerm Δ σ

-- Single variable substitution
def substOne {Γ σ τ} (s : TypedTerm Γ σ) (t : TypedTerm (σ :: Γ) τ) : TypedTerm Γ τ :=
  subst (fun τ h => match h with | List.head _ => s | List.tail _ h => var h) t

end TypedTerm

-- One-step β-reduction
inductive BetaStep : ∀ {Γ τ}, TypedTerm Γ τ → TypedTerm Γ τ → Prop where
  | beta : ∀ {Γ σ τ} (body : TypedTerm (σ :: Γ) τ) (arg : TypedTerm Γ σ),
      BetaStep (TypedTerm.app (TypedTerm.lam σ body) arg) (body.substOne arg)
  | app_left : ∀ {Γ σ τ} {t t' : TypedTerm Γ (STLCType.arrow σ τ)} {u : TypedTerm Γ σ},
      BetaStep t t' → BetaStep (TypedTerm.app t u) (TypedTerm.app t' u)
  | app_right : ∀ {Γ σ τ} {t : TypedTerm Γ (STLCType.arrow σ τ)} {u u' : TypedTerm Γ σ},
      BetaStep u u' → BetaStep (TypedTerm.app t u) (TypedTerm.app t u')
  | lam : ∀ {Γ σ τ} {t t' : TypedTerm (σ :: Γ) τ},
      BetaStep t t' → BetaStep (TypedTerm.lam σ t) (TypedTerm.lam σ t')

-- Reflexive transitive closure of β-reduction
def BetaStar {Γ τ} : TypedTerm Γ τ → TypedTerm Γ τ → Prop :=
  Relation.ReflTransGen (@BetaStep Γ τ)

-- Strong normalization: no infinite reduction sequences
def IsSN {Γ τ} (t : TypedTerm Γ τ) : Prop :=
  ¬∃ f : ℕ → TypedTerm Γ τ, f 0 = t ∧ ∀ n, BetaStep (f n) (f (n + 1))

-- The finite transition system induced by a typed term
structure FTS (Γ : Context) (τ : STLCType) where
  states : FinSet (TypedTerm Γ τ)
  step : TypedTerm Γ τ → TypedTerm Γ τ → Prop
  states_closed : ∀ t ∈ states, ∀ u, step t u → u ∈ states
  step_def : ∀ t u, step t u ↔ BetaStep t u

-- CTL* state formulas and path formulas (mutually inductive)
inductive CTLStarStateFormula where
  | atom (n : ℕ) : CTLStarStateFormula
  | not : CTLStarStateFormula → CTLStarStateFormula
  | and : CTLStarStateFormula → CTLStarStateFormula → CTLStarStateFormula
  | exists_path : CTLStarPathFormula → CTLStarStateFormula

inductive CTLStarPathFormula where
  | state : CTLStarStateFormula → CTLStarPathFormula
  | next : CTLStarPathFormula → CTLStarPathFormula
  | until : CTLStarPathFormula → CTLStarPathFormula → CTLStarPathFormula
  | not : CTLStarPathFormula → CTLStarPathFormula
  | and : CTLStarPathFormula → CTLStarPathFormula → CTLStarPathFormula

-- Normalization depth: maximum length of any reduction sequence from t
def normDepth {Γ τ} (t : TypedTerm Γ τ) : ℕ :=
  sSup {n | ∃ u, BetaStar t u ∧ reductionLength t u = n}
```

---

## Target Theorems (Precise Lean 4 Signatures)

### Theorem 1: Strong Normalization via Reducibility Candidates (THE FOUNDATION)

```lean
-- Reducibility candidate for type τ
def IsReducible {Γ τ} (t : TypedTerm Γ τ) : Prop :=
  match τ with
  | STLCType.base _ => IsSN t
  | STLCType.arrow σ τ' =>
    ∀ Δ (ρ : ∀ σ', σ' ∈ Γ → TypedTerm Δ σ'),
    ∀ s : TypedTerm Δ σ, IsReducible s → IsReducible (t.subst ρ · s)

-- Fundamental theorem: every well-typed term is reducible
theorem fundamental_theorem {Γ τ} (t : TypedTerm Γ τ) :
    IsReducible t := by
  -- Proof by induction on the typing derivation
  -- Var case: reducibility of variables follows from SN of variables
  -- App case: by IH and the arrow clause of reducibility
  -- Lam case: by IH and the definition of reducibility for arrow types
  sorry

-- Corollary: every well-typed term is strongly normalizing
theorem strong_normalization {Γ τ} (t : TypedTerm Γ τ) :
    IsSN t := by
  -- Direct from fundamental_theorem + reducibility_implies_SN
  sorry
```

### Theorem 2: Finite Reduction Graph via König's Lemma (THE BRIDGE)

```lean
-- Finite branching: each term has finitely many one-step reducts
theorem finite_branching {Γ τ} (t : TypedTerm Γ τ) :
    {u : TypedTerm Γ τ | BetaStep t u}.Finite := by
  -- The number of one-step reducts is bounded by the number of redexes
  -- Each redex contracts to exactly one term
  sorry

-- König's Lemma (contrapositive): SN + finite branching → finite graph
theorem konig_lemma_finite {α : Type} (r : α → α → Prop)
    (h_branch : ∀ a, {b | r a b}.Finite)
    (h_sn : ∀ a, ¬∃ f : ℕ → α, f 0 = a ∧ ∀ n, r (f n) (f (n + 1))) :
    ∀ a, {b | Relation.ReflTransGen r a b}.Finite := by
  -- Key proof: if the reachable set were infinite, by finite branching,
  -- König's Lemma gives an infinite path, contradicting SN
  sorry

-- THE MAIN THEOREM: typed terms have finite reduction graphs
theorem typed_reduction_graph_finite {Γ τ} (t : TypedTerm Γ τ) :
    {u : TypedTerm Γ τ | BetaStar t u}.Finite := by
  -- Apply konig_lemma_finite with strong_normalization and finite_branching
  exact konig_lemma_finite BetaStep
    (fun u => finite_branching u)
    (fun u => strong_normalization u)
    t
```

### Theorem 3: CTL* Decidability on Typed Terms (THE PAYOFF)

```lean
-- Construct the FTS from a typed term
def ftsFromTyped {Γ τ} (t : TypedTerm Γ τ) : FTS Γ τ := by
  -- Use typed_reduction_graph_finite to construct the finite state set
  -- Define step as BetaStep restricted to reachable terms
  sorry

-- CTL* satisfaction on an FTS (mutually recursive with path semantics)
def satisfiesState {Γ τ} (f : FTS Γ τ) (s : TypedTerm Γ τ) :
    CTLStarStateFormula → Prop
def satisfiesPath {Γ τ} (f : FTS Γ τ) (path : ℕ → TypedTerm Γ τ) :
    CTLStarPathFormula → Prop

-- CTL* model checking is decidable on finite transition systems
theorem ctl_star_decidable {Γ τ} (f : FTS Γ τ) (s : f.states) (φ : CTLStarStateFormula) :
    Decidable (satisfiesState f (s : TypedTerm Γ τ) φ) := by
  -- By induction on φ, using the finiteness of f.states
  -- For EF/EG/Until: compute fixpoints on the finite state set
  sorry

-- THE GRAND THEOREM: CTL* is decidable for well-typed lambda terms
theorem ctl_star_decidable_typed {Γ τ} (t : TypedTerm Γ τ) (φ : CTLStarStateFormula) :
    Decidable (satisfiesState (ftsFromTyped t) t φ) := by
  -- Combine ftsFromTyped with ctl_star_decidable
  sorry
```

### Theorem 4: Cross-Domain — Normalization Depth and the Fast-Growing Hierarchy

```lean
-- The Ackermann-like normalization bound for STLC
-- For type base^n → base, the max reduction length is bounded by
-- a function at level n of the Grzegorczyk hierarchy

-- Type height measures the nesting of arrows
def typeHeight : STLCType → ℕ
  | STLCType.base _ => 0
  | STLCType.arrow σ τ => 1 + max (typeHeight σ) (typeHeight τ)

-- The normalization bound grows as the fast-growing hierarchy at level typeHeight
-- This connects STLC normalization to proof-theoretic ordinals
theorem norm_bound_type_height {Γ τ} (t : TypedTerm Γ τ) :
    ∃ f : ℕ → ℕ, f ∈ fastGrowingHierarchy (typeHeight τ) ∧
    normDepth t ≤ f (termSize t) := by
  -- The proof proceeds by analyzing the reducibility proof
  -- and extracting computational content (proof mining / Gödel's Dialectica)
  sorry
```

---

## Proof Strategies (Three Paths)

### Strategy A: Reducibility Candidates + König's Lemma (RECOMMENDED)

**Why most promising**: This is the most well-understood path and decomposes cleanly into independent lemmas, each of substantial independent interest.

1. **Prove strong normalization** via Tait's reducibility candidates (the `fundamental_theorem`). This is a 4-case induction on typing derivations (var, app, lam) where the lam case requires the key lemma that reducibility of a term under an arbitrary reducible substitution implies reducibility of the lambda abstraction.

2. **Prove finite branching** by showing that the number of redexes in a term is finite (bounded by `termSize t`), and each redex contracts to exactly one term. This is straightforward but requires careful formalization of "number of redexes."

3. **Apply König's Lemma** (contrapositive form): a finitely branching tree with no infinite path is finite. The reduction graph from `t` forms a finitely branching tree (by step 2) with no infinite path (by step 1), hence is finite.

4. **CTL* decidability** follows from standard model checking on finite systems: compute fixpoints for the temporal operators over the finite state set.

### Strategy B: Proof-Theoretic — Extract Bounds via Gödel's Dialectica

**Alternative approach**: Instead of König's Lemma (which gives existence but no explicit bound), use Gödel's Dialectica interpretation to extract explicit normalization bounds from the reducibility proof. This gives:

1. An explicit function `normBound : STLCType → ℕ → ℕ` such that every term of type τ with size n normalizes within `normBound τ n` steps.

2. This bound is in the **fast-growing hierarchy** at level `typeHeight(τ)`, connecting to proof-theoretic ordinal analysis.

3. The explicit bound allows **complexity analysis** of the resulting model checker: CTL* model checking for a term `t : Γ ⊢ τ` runs in time `O(|φ| · (normBound τ |t|)^|φ|)`.

**Advantage**: Gives explicit complexity bounds. **Disadvantage**: The Dialectica extraction is much harder to formalize in Lean.

### Strategy C: Semantic — Domain-Theoretic via Scott Domains

**Alternative approach**: Use domain theory to give a semantic proof.

1. Construct the Scott domain `D_τ` for each type τ (the domain of denotations).
2. Show that the denotation map `⟦t⟧ : Env → D_τ` factors through the normal form.
3. The finite approximation lattice of `D_τ` is finite at each level, giving a bound on the "depth" needed.
4. The FTS at this depth is complete for temporal properties.

**Advantage**: Connects to denotational semantics and domain theory. **Disadvantage**: Requires substantial domain-theoretic infrastructure not currently in Mathlib.

**Recommendation**: Use Strategy A for the main proof, but state the explicit bounds from Strategy B as a conjecture (see below) for future work.

---

## Cross-Domain Connections

### 1. Proof Theory ↔ Rewriting Theory ↔ Temporal Logic
The König's Lemma bridge connects three fields that rarely communicate:
- **Proof theory** provides strong normalization (the tree has no infinite path)
- **Rewriting theory** provides finite branching (the tree is locally finite)
- **Temporal logic** provides the verification framework (CTL* on finite systems)

This triangle is the core contribution: **certified temporal verification via proof-theoretic bounds**.

### 2. Type Theory ↔ Complexity Theory
The normalization bound for STLC types places definable functions in precise complexity classes:
- Type `base → base → base`: polynomial-time functions
- Type `(base → base) → base → base`: exponential-time functions
- Type height n: functions in the Grzegorczyk hierarchy at level n

This connects to **implicit computational complexity** and **type-based resource analysis**.

### 3. Category Theory ↔ Model Checking
STLC is the internal language of cartesian closed categories (CCCs). The FTS construction is functorial: it extends to a functor from the category of typed reduction graphs to the category of finite transition systems. CTL* formulas define subcategories of "well-behaved" systems. This opens the door to **categorical model checking** — using universal properties to decompose verification.

### 4. Topology ↔ Logic (Stone Duality)
The FTS carries a natural topology (the Alexandroff topology of the reduction ordering). By Stone duality, CTL* formulas correspond to open/closed sets in this topology. This connects to:
- **Algebraic semantics** of temporal logic
- **Topological semantics** of intuitionistic logic
- **Spatial logics** for concurrency

---

## Falsifiable Conjectures

### Conjecture 1: The König Bound is Tight
**Statement**: There exist simply typed terms `t_n : Γ ⊢ (base → base)^n → base` whose reduction graphs have size ≥ `tower(n)` (iterated exponentiation to height n).

**Test**: Construct explicit terms using Church numerals at higher types. Compute their reduction graphs and measure the size. If the graph size grows faster than `tower(n)`, the conjecture is confirmed. If it grows slower, the König argument may be refined.

### Conjecture 2: CTL* Subsumes Type Inhabitation
**Statement**: For STLC, the question "does there exist a term of type τ?" is reducible to CTL* model checking on a specific FTS.

**Test**: Define the FTS for the empty context and type τ. Show that the type is inhabited iff the CTL* formula `EF(atom "inhabited")` is satisfied. This would connect type inference to model checking, opening practical applications.

### Conjecture 3: The Polynomial-Time Fragment
**Statement**: For terms of type height ≤ 2, CTL* model checking runs in polynomial time in the term size.

**Test**: Implement the model checker for type-height-2 terms. Measure runtime on terms of increasing size. Fit to polynomial/exponential curves. If the fit is polynomial, the conjecture holds.

### Conjecture 4: Categorical Decomposition
**Statement**: If `t = app f g` where `f : σ → τ` and `g : σ`, then `FTS(t)` is isomorphic (as a labeled transition system) to a specific pushout construction from `FTS(f)` and `FTS(g)`.

**Test**: Construct `FTS(f)`, `FTS(g)`, and `FTS(app f g)` for small terms. Check if the pushout (in the category of FTSs) matches `FTS(app f g)`. If it does for all tested cases, the categorical decomposition conjecture is supported.

---

## Mandatory Deliverables

You MUST produce ALL of:

1. **FUTURE_DIRECTIONS.md**: 3-5 testable scientific hypotheses, each a falsifiable conjecture with a clear computational test (not vague exploration).

2. **RESEARCH_PAPER.md**: A STANDALONE scientific document. Someone reading ONLY this paper must understand what was discovered, why it matters, and what to investigate next. Include: (a) the König's Lemma bridge as the central theorem, (b) the connection to proof-theoretic ordinals, (c) complexity bounds for CTL* model checking on typed terms.

3. **ARTICLE.md**: Written in Scientific American style — engaging, accessible. Explain how "types are the key that unlocks temporal verification" — the paradox that restricting expressiveness (to typed terms) enables new capabilities (model checking). Use the analogy: "Untyped programs are fractals — infinite complexity at every scale. Typed programs are crystals — bounded, regular, and their properties can be checked."

4. **Verified algorithm**: A computational method (not just a theorem statement) for constructing the FTS from a typed term and running CTL* model checking on it.

5. **demo.py**: An interactive demonstration that:
   - Takes a simply typed lambda term as input
   - Constructs the finite transition system (reduction graph)
   - Accepts a CTL* formula
   - Returns whether the formula is satisfied
   - Visualizes the reduction graph and highlights satisfying states

---

## Application Keywords (for Impact Tracking)

`certified-verification`, `model-checking`, `simply-typed-lambda-calculus`, `strong-normalization`, `konigs-lemma`, `CTL-star`, `proof-theoretic-ordinals`, `fast-growing-hierarchy`, `type-based-complexity`, `categorical-model-checking`, `stone-duality`, `rewriting-theory`, `temporal-logic`, `verified-compilation`, `program-equivalence`

---

## Ambition: ★★★★★

This is a **grand challenge** result. It proves that the simply typed lambda calculus — the foundational system of type theory and functional programming — has decidable temporal logic verification. This connects proof theory, rewriting theory, and model checking in a single formal framework. The implications for verified compilation, program equivalence, and certified optimization are immediate and profound. The door it opens — categorical model checking, type-based complexity analysis, and the topological semantics of temporal logic — defines an entire research program.

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
