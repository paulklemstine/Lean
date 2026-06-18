## Assignment: Algebra–EML–Logic Closure Rate–Proof Duality via Idempotent Consequence Semimodules and Certified Minimal Proof-Complexity Reconstruction

**Mode:** prove

Prove genuinely new, nontrivial theorems that turn closure theory into a formal theory of proof complexity. Build directly on existing `IsClosureOperator` infrastructure and any certified minimal-reconstruction theorems already present in the catalog (especially closure/EML/tropical reconstruction results, canonical-basis results, and finite realization theorems). Minimize `sorry` by isolating finite combinatorial lemmas and reusing catalog closure lemmas aggressively.

---

## Vision

The target is not “another closure representation theorem.” The target is a **proof-complexity semantics for finite closure systems**:

> a finite closure operator together with a tropical/idempotent cost profile should be recognized as exactly the shadow of a finite weighted consequence system, and from that shadow one should be able to reconstruct a **minimal derivation architecture**.

If successful, this opens a new field:

- **proof complexity as closure information theory**
- **tropical semantics of derivations**
- **certified minimal proof reconstruction**
- **Horn logic as idempotent linear algebra**
- **rate–distortion analogues for formal deduction**

This would connect algebraic logic, antimatroid/convex geometry, tropical optimization, and EML-style information measures in a way that is not currently standard.

---

## Core formal objects to define

Let `X : Finset α` or more canonically `[Fintype α] [DecidableEq α]`. Work over subsets `Set α` or finite sets if existing catalog lemmas favor one representation.

Define:

1. **Closure system**
   - `cl : Set α → Set α`
   - with `IsClosureOperator cl`

2. **Closed sets**
   - `IsClosed (C : Set α) : Prop := cl C = C`

3. **Weighted consequence system**
   - atomic propositions are elements of `α`
   - a rule is a pair `(premises, conclusion)` or more generally `(premises, conclusions)`
   - each rule has a nonnegative weight in `ℕ∞`, `WithTop ℕ`, or `ℝ≥0∞`
   - derivation DAG cost is tropical/additive: sum over rule usages, minimization over all derivations

4. **Capacity on closed sets**
   - `κ : {C : Set α // cl C = C} → W`
   - where `W` is an idempotent/tropical weight type with order and addition
   - intended meaning: minimum proof cost required to generate `C`

5. **Principal closed increments**
   - for `x : α`, consider `cl (C ∪ {x})`
   - these should play the role of irreducible proof steps / semimodule generators

6. **Idempotent consequence semimodule**
   - the semimodule should encode closure-generated joins and tropical costs
   - even if full semimodule abstraction is too heavy, define enough structure so the representation theorem can be stated and proved in finite combinatorial terms

---

## Precise theorem targets

### Theorem 1: Finite weighted consequence realization / minimality duality

Prove a finite realization theorem of the following form.

### Mathematical statement

Let `α` be finite. Let `cl : Set α → Set α` be a closure operator. Let `Closed := {C : Set α // cl C = C}`. Let `κ : Closed → WithTop ℕ` (or another catalog-compatible cost codomain). Assume:

1. **Normalization**
   \[
   \kappa(\operatorname{cl}(\varnothing)) = 0.
   \]

2. **Monotonicity on closed sets**
   \[
   C \subseteq D \implies \kappa(C) \le \kappa(D).
   \]

3. **Tropical subadditivity**
   \[
   \kappa(\operatorname{cl}(A \cup B)) \le \kappa(\operatorname{cl}(A)) + \kappa(\operatorname{cl}(B)).
   \]

4. **Principal-step realizability**
   Every join-irreducible closed extension \(J\) over a closed \(C\) has a finite principal increment cost witnessed by an atomic or irreducible derivation step.

5. **Exchange / proof-elimination axiom**
   A finite anti-redundancy condition implying existence of a canonical basis of principal increments and elimination of dominated proof steps.

Then there exists a finite weighted Horn-style consequence system `R` on `α` such that:

- its derivability closure equals `cl`
- for every closed `C`, the minimum weighted derivation DAG cost generating `C` is exactly `κ(C)`
- after minimization (eliminating cost-dominated and closure-redundant rules), `R` is unique up to cost-preserving isomorphism of rule systems

Moreover, the minimal rule system is reconstructible from the family of principal closed increments.

### Lean 4 theorem shape

A realistic top-level theorem signature could look like:

```lean
theorem finite_weighted_consequence_representation
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (hcl : IsClosureOperator cl)
  (κ : {C : Set α // cl C = C} → WithTop ℕ)
  (hκ_norm :
    κ ⟨cl ∅, by simpa using hcl.idempotent (∅ : Set α)⟩ = 0)
  (hκ_mono :
    ∀ {C D : Set α} (hC : cl C = C) (hD : cl D = D),
      C ⊆ D → κ ⟨C, hC⟩ ≤ κ ⟨D, hD⟩)
  (hκ_subadd :
    ∀ A B : Set α,
      κ ⟨cl (A ∪ B), by simpa using hcl.idempotent (A ∪ B)⟩
        ≤ κ ⟨cl A, by simpa using hcl.idempotent A⟩
        + κ ⟨cl B, by simpa using hcl.idempotent B⟩)
  (hprincipal : PrincipalStepRealizable cl κ)
  (hexchange : ProofExchangeAxiom cl κ) :
  ∃ R : WeightedConsequenceSystem α,
    ClosureOf R = cl ∧
    ProofCapacityOf R = κ ∧
    IsMinimalWeightedPresentation R ∧
    ∀ R' : WeightedConsequenceSystem α,
      ClosureOf R' = cl →
      ProofCapacityOf R' = κ →
      IsMinimalWeightedPresentation R' →
      CostPreservingIso R R'
```

If uniqueness is too ambitious for the first pass, split into:
- existence of a minimal realizing system
- uniqueness of the minimized principal-step system

This theorem is the heart of the project.

---

### Theorem 2: Certified reconstruction of a minimal derivation DAG / canonical basis

From `cl` and `κ`, define a reconstruction algorithm that extracts principal increments and assembles a minimal weighted derivation DAG or canonical weighted Horn basis.

### Mathematical statement

There exists a computable procedure `reconstruct` such that for every finite closure-capacity structure satisfying the hypotheses of Theorem 1:

- `reconstruct cl κ` returns a weighted consequence system `Rmin`
- `Rmin` realizes `cl`
- `Rmin` realizes `κ`
- `Rmin` is minimal under rule count / total weight / dominance preorder
- from `Rmin`, for each closed set `C`, one can extract a derivation DAG with certified minimal cost `κ(C)`

### Lean 4 theorem shape

```lean
theorem reconstruct_minimal_weighted_consequence_system
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (hcl : IsClosureOperator cl)
  (κ : {C : Set α // cl C = C} → WithTop ℕ)
  (hax : ClosureCapacityAxioms cl κ) :
  let R := reconstructWeightedConsequenceSystem cl κ
  ClosureOf R = cl ∧
  ProofCapacityOf R = κ ∧
  IsMinimalWeightedPresentation R ∧
  CertifiedReconstruction cl κ R
```

And a pointwise optimality theorem:

```lean
theorem reconstruct_derivation_dag_optimal
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (hcl : IsClosureOperator cl)
  (κ : {C : Set α // cl C = C} → WithTop ℕ)
  (hax : ClosureCapacityAxioms cl κ) :
  ∀ C : {C : Set α // cl C = C},
    ∃ D : DerivationDAG α,
      GeneratesClosedSet D C.1 ∧
      cost D = κ C ∧
      IsCostMinimalDerivation cl C.1 D
```

This theorem is the algorithmic bridge: not merely existence, but certified extraction.

---

### Theorem 3: Closure proof-rate theorem / rate–distortion analogue

Define rank/size complexity of a closed set, e.g. by minimal generator cardinality:
\[
\operatorname{rk}(C) := \min \{ |A| : \operatorname{cl}(A)=C \}.
\]
Then define the proof-rate function:
\[
R(m) := \sup \{ \kappa(C) : C \text{ closed and } \operatorname{rk}(C)\le m \}
\]
or the least universal budget sufficient for all rank-`≤ m` closed sets.

Prove a closure-theoretic rate theorem.

### Mathematical statement

For every finite weighted consequence system realizing `(cl, κ)`:

1. `R(m)` is well-defined and monotone in `m`.
2. There exists an optimal compressed basis `B_m` achieving `R(m)`.
3. Equality in the natural lower bound is characterized by antimatroid-like / greedoid-like canonical proof systems, where derivations admit exchange-free greedy normal forms.

This is the proof-complexity analogue of rate–distortion or source coding: how much proof cost is necessary to realize all theories of bounded rank?

### Lean 4 theorem shape

```lean
def closedRank
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α) (C : Set α) : Nat := ...

def proofRate
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (κ : {C : Set α // cl C = C} → WithTop ℕ)
  (m : Nat) : WithTop ℕ := ...

theorem proofRate_monotone
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (κ : {C : Set α // cl C = C} → WithTop ℕ) :
  Monotone (proofRate cl κ)

theorem proofRate_optimal_compressed_basis
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (hcl : IsClosureOperator cl)
  (κ : {C : Set α // cl C = C} → WithTop ℕ)
  (hax : ClosureCapacityAxioms cl κ) :
  ∀ m : Nat, ∃ B : WeightedProofBasis α,
    AchievesProofRate cl κ m B ∧
    IsOptimalCompressedBasis cl κ m B

theorem proofRate_equality_iff_antimatroidal
  {α : Type*} [Fintype α] [DecidableEq α]
  (cl : Set α → Set α)
  (hcl : IsClosureOperator cl)
  (κ : {C : Set α // cl C = C} → WithTop ℕ)
  (hax : ClosureCapacityAxioms cl κ) :
  ∀ m : Nat,
    SharpProofRateEquality cl κ m ↔
    ExistsCanonicalAntimatroidLikeProofSystem cl κ m
```

Even a weaker finite version here would already be a breakthrough.

---

## Recommended proof architecture

### Strategy A: Canonical basis via join-irreducible closed increments
This is likely the most promising route.

1. **Classify principal increments**
   - Define the poset of closed sets.
   - Isolate join-irreducible or cover-type extensions `C < J`.
   - Show each irreducible extension carries a primitive cost extracted from `κ`.

2. **Construct the rule system**
   - For each principal increment, create a Horn-style rule
     `premises(C) ⟹ new_atom_or_extension`
     with weight equal to the primitive increment cost.
   - Show closure generated by these rules equals the original `cl`.

3. **Prove optimality/minimality**
   - Use the exchange/proof-elimination axiom to show every derivation can be normalized to a canonical DAG using only principal steps.
   - Show any alternative system realizing the same `(cl, κ)` must contain equivalent primitive increments, giving uniqueness after minimization.

**Why this is promising:** it aligns with finite closure theory, canonical implicational bases, antimatroid greediness, and tropical decomposition into irreducibles. It is structurally closest to known catalog reconstruction theorems.

---

### Strategy B: Idempotent semimodule / tropical linearization
This is the most conceptually ambitious route.

1. **Encode closed sets as semimodule elements**
   - Interpret closed sets as idempotent sums of principal generators.
   - Let `κ` be a tropical valuation / Minkowski functional on this semimodule.

2. **Recover primitive generators from extreme rays**
   - Show principal closed increments correspond to extremal semimodule elements.
   - Prove finite generation from the exchange axiom.

3. **Translate semimodule decomposition into proof rules**
   - A tropical decomposition of a closed set into principal generators becomes a derivation DAG.
   - Minimal tropical weight equals minimal proof cost.

**Why this is exciting:** it connects proof theory to tropical convexity and idempotent functional analysis. If it works, it would not merely solve the finite theorem; it would define a new language for proof complexity.

**Risk:** more abstraction, more setup burden in Lean.

---

### Strategy C: Hypergraph shortest-path / DAG realization
This is the algorithmic route and may be best for the reconstruction theorem.

1. **Represent derivations as weighted directed hypergraphs**
   - premises = hyperedge tails
   - conclusion/increment = hyperedge head
   - derivation cost = shortest hyperpath / minimal DAG cost

2. **Infer hyperedges from `κ`**
   - Define candidate primitive hyperedges as those whose cost cannot be decomposed into cheaper unions.
   - Prove completeness using subadditivity and exchange.

3. **Use finite optimization**
   - Since `α` is finite, enumerate closed sets and verify optimality by dynamic programming over the closure lattice.

**Why this is useful:** it is highly formalizable, algorithmic, and naturally yields certified reconstruction. It also interfaces well with minimal-DAG theorems if such results are already in the catalog.

---

## Building blocks from the catalog to exploit

Use any available theorems and structures around:

- `IsClosureOperator`
- finite closure systems / Galois or Stone-style duality lemmas
- EML/tropical capacity monotonicity and subadditivity lemmas
- certified minimal reconstruction theorems from Tanner/crystal/closure settings
- canonical basis / irredundant basis lemmas
- finite antimatroid / greedoid / convex-geometry style exchange lemmas if present
- tropical/idempotent algebra lemmas for subadditive capacities
- DAG minimality or shortest derivation lemmas if available

Do not cite catalog results vaguely. Inline them as explicit build blocks:
- if there is a theorem proving finite closure systems admit canonical generators, use it to define principal increments;
- if there is a theorem identifying minimal tropical decompositions, use it to prove cost-optimality of derivation DAGs;
- if there is already a reconstruction correctness theorem in another domain, imitate its specification and proof skeleton.

The central methodological move is:
**closure theorem + irreducible generator theorem + tropical minimality theorem = proof-system realization theorem.**

---

## Key definitions that will matter

You should define these carefully enough that the main theorem is natural in Lean.

- `WeightedRule α`
- `WeightedConsequenceSystem α`
- `DerivableFrom : WeightedConsequenceSystem α → Set α → Set α`
- `ClosureOf : WeightedConsequenceSystem α → Set α → Set α`
- `DerivationDAG α`
- `GeneratesClosedSet`
- `cost : DerivationDAG α → WithTop ℕ`
- `ProofCapacityOf : WeightedConsequenceSystem α → {C // cl C = C} → WithTop ℕ`
- `PrincipalStepRealizable cl κ`
- `ProofExchangeAxiom cl κ`
- `IsMinimalWeightedPresentation R`
- `CostPreservingIso R R'`
- `CertifiedReconstruction cl κ R`
- `closedRank`
- `proofRate`

If full generality over arbitrary cost semirings is too much, specialize first to `WithTop ℕ`. That still captures discrete proof complexity and is Lean-friendly.

---

## Nontrivial lemmas worth isolating

1. **Closed-set finiteness**
   - The type of closed subsets of a finite type is finite.

2. **Principal decomposition lemma**
   - Every closed set is a finite join/closure of principal closed increments.

3. **Irreducible-cost extraction lemma**
   - Under subadditivity + exchange, `κ` is determined by its values on principal increments.

4. **Canonical normalization lemma**
   - Every derivation DAG can be transformed into a reduced DAG with no dominated steps and no repeated closure-equivalent nodes.

5. **Minimal presentation existence**
   - Finite weighted consequence systems admit a minimization procedure.

6. **Minimal presentation uniqueness**
   - Two minimal presentations with the same primitive increments are cost-preservingly isomorphic.

7. **Rate compression lemma**
   - For fixed `m`, there is an optimal basis controlling all closed sets of rank ≤ `m`.

These lemmas are likely the actual proof bottlenecks. Prove them separately and then compose.

---

## Cross-domain connections to exploit explicitly

This project becomes powerful only if you lean into the cross-pollination:

### 1. Algebraic logic ↔ tropical geometry
A derivation is a tropical sum of proof steps; minimal proof cost is a tropical valuation. Closed theories become tropical convex objects.

### 2. Proof complexity ↔ information theory
`κ(C)` is an information budget for realizing theory `C`. The proof-rate function `R(m)` is a logical analogue of a rate function or coding profile.

### 3. Antimatroids / greedoids ↔ cut elimination
Exchange-free canonical derivations resemble greedy feasible-set generation. Canonical proof systems should correspond to antimatroid-like closure geometries.

### 4. Hypergraph algorithms ↔ formal proof certification
Minimal derivation DAG reconstruction is a shortest-hyperpath problem with theorem-prover guarantees.

### 5. Category/duality themes ↔ semantics of consequence
A weighted consequence system should be viewed as a presentation, while `(cl, κ)` is the invariant semantics. The theorem says semantics and minimal presentation coincide in the finite idempotent world.

### 6. Matroid/convex geometry ↔ proof dependence
Join-irreducible increments are proof atoms. Exchange captures proof dependence/independence similarly to basis exchange.

These are not decorative analogies. They suggest the exact shape of definitions and lemmas.

---

## Why this would be a breakthrough

If proved, this would say:

- proof systems can be **recognized purely from closure + cost data**
- proof complexity has a **semantic representation theorem**
- there is a **certified canonical compressed proof basis**
- minimal derivations can be reconstructed from a closure-capacity profile without prior access to rules

That is a field-opening perspective. It reframes finite proof systems the way coding theory reframes communication systems: not by syntax first, but by **capacity profiles** and **minimal realizations**.

This could lead to:
- certified proof compression
- semantic lower bounds on proof complexity
- tropical abstractions of cut elimination
- new invariants for automated theorem proving
- closure-theoretic models of explainability and minimal reasoning

---

## Concrete implementation advice in Lean

- Start finite and discrete: `α` finite, weights in `WithTop ℕ`.
- Use `Set α` if catalog closure infrastructure already does; otherwise `Finset α` with coercions.
- Define closed sets as a subtype.
- Separate semantic closure from syntactic derivability.
- Keep the derivation DAG structure lightweight initially; a recursive derivation tree may suffice before DAG quotienting.
- Prove existence and correctness first; prove uniqueness and rate theorem second.
- If necessary, first formalize a restricted theorem for **singleton-conclusion Horn systems** and then generalize.

A good decomposition is:

1. definitions file
2. finite closed-set combinatorics
3. principal increments and canonical basis
4. weighted consequence realization
5. reconstruction correctness
6. proof-rate theorem

---

## Deliverables

Produce:

1. The main Lean theorem(s) formalizing Theorem 1 and at least one of Theorem 2 or 3.
2. Supporting definitions and lemmas with minimal `sorry`.
3. A reconstruction function with a correctness theorem, even if computational optimality is initially stated abstractly.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough-level next steps**, for example:
   - infinite/compact closure-capacity representation
   - lower bounds and separation theorems for proof-rate profiles
   - categorical duality for weighted consequence systems
   - tropical cut-elimination and normalization complexity
   - applications to proof compression in ATP / SAT / Horn reasoning

---

## Application keywords

proof complexity, closure systems, Horn logic, idempotent semimodules, tropical algebra, EML, derivation DAGs, canonical basis, antimatroids, greedoids, weighted consequence systems, proof compression, rate–distortion, information-theoretic logic, certified reconstruction, hypergraph optimization, algebraic logic, tropical proof semantics

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

Research domain: Bridges
Research mode: prove
