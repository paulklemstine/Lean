## Assignment: Galois Theory Beyond Symbolic Formulae — Derived Series, Radical Towers, and the Formal Boundary of Solvability

Prove new, non-trivial theorems in Lean 4 that turn classical Galois theory into a machine-checked theory of **algorithmic solvability**. Do not stop at textbook restatement. The target is a formal bridge from field extensions to group-theoretic derived series, culminating in certified non-solvability results for concrete quintics and a roadmap toward Abel–Ruffini.

Build aggressively on Mathlib’s field theory, polynomial, splitting field, and finite group infrastructure. The catalog theorem `galois_connection_theory_variety` is conceptually relevant: use it as a signal to emphasize order-theoretic correspondences and anti-isomorphisms, even if the exact theorem is not directly reusable. The rest of the listed catalog appears largely orthogonal; do not force them unless a genuine bridge emerges.

### Mode
**formalize + prove**

---

## Core Vision

The breakthrough is not merely “formalize the fundamental theorem of Galois theory.” The breakthrough is:

1. **Formalize the correspondence between intermediate fields and subgroups as a computable architecture** in Lean.
2. **Certify solvability of a polynomial by radicals via solvability of its Galois group** in concrete families.
3. **Mechanize explicit non-solvability for a concrete irreducible quintic with Galois group `S₅`**, which is the mathematically meaningful Lean-accessible precursor to the full generic Abel–Ruffini theorem.
4. Push toward a formal statement that **generic quintic unsolvability is a theorem about the universal obstruction encoded by `S₅`**, not just a slogan about formulas.

This opens a field-level program: **formal inverse Galois theory meets certified symbolic impossibility**. It would connect theorem proving, computational algebra, and the logic of algebraic equations.

---

## Primary Theorem Targets

### Theorem A: Solvable Galois group implies solvable-by-radicals structure
Formalize a precise theorem for finite Galois extensions.

**Mathematical statement**
For fields `K ⊆ L`, if `L/K` is finite Galois and `Gal(L/K)` is solvable, then there exists a finite tower of intermediate fields
`K = K₀ ⊆ K₁ ⊆ ... ⊆ Kₙ = L`
such that each extension `Kᵢ₊₁/Kᵢ` is obtained by adjoining a root of `X^(mᵢ) - aᵢ`, under suitable hypotheses on roots of unity in the base.

Because the full radicals formalization may be heavy, a first Lean target should be a structurally weaker but still deep theorem:

**Lean-oriented theorem target**
```lean
theorem exists_normal_series_of_prime_degree
  (K L : Type*) [Field K] [Field L] [Algebra K L]
  [FiniteDimensional K L] [Normal K L] [Separable K L]
  (hsolv : Group.Solvable (L ≃ₐ[K] L)) :
  ∃ n : ℕ, ∃ F : Fin (n+1) → IntermediateField K L,
    F 0 = ⊥ ∧ F (Fin.last n) = ⊤ ∧
    (∀ i : Fin n,
      F i.castSucc ≤ F i.succ) ∧
    (∀ i : Fin n,
      Nat.Prime (finrank (F i.succ) (F i.succ : IntermediateField K L) ⧸? ))
```

This exact signature will likely need adaptation because quotient/intermediate-field degree terms are delicate in Mathlib. A more realistic first target is:

```lean
theorem exists_subgroup_normal_series_of_solvable
  (G : Type*) [Group G] [Finite G]
  (hsolv : Group.Solvable G) :
  ∃ n : ℕ, ∃ H : Fin (n+1) → Subgroup G,
    H 0 = ⊤ ∧ H (Fin.last n) = ⊥ ∧
    (∀ i : Fin n, H i.succ ≤ H i.castSucc) ∧
    (∀ i : Fin n, H i.succ.Normal) ∧
    (∀ i : Fin n, IsCommutative ((H i.castSucc) ⧸ (H i.succ.subgroupOf (H i.castSucc))) (· * ·))
```

Then transfer this series through the Galois correspondence to intermediate fields.

**Why this matters**
This theorem is the certified skeleton behind solvability by radicals. Even if the full radicals API is unfinished, the existence of a derived/normal series on the automorphism side is the exact obstruction-theoretic content.

---

### Theorem B: Concrete quintic with Galois group `S₅` is not solvable by radicals
Do not wait for the full generic theorem. Prove a concrete theorem with a specific polynomial such as `X^5 - X - 1` over `ℚ`, or another quintic with known Galois group `S₅` and manageable irreducibility/discriminant properties.

**Mathematical statement**
Let `f(X) = X^5 - X - 1 ∈ ℚ[X]`. If `Gal(f/ℚ) ≅ S₅`, then `f` is not solvable by radicals. Formalize the implication from `Gal(f/ℚ) ≅ S₅` to non-solvability, and separately formalize enough arithmetic evidence to certify the group as non-solvable, ideally actually `S₅`.

**Lean-oriented theorem target**
```lean
theorem not_solvable_by_radicals_of_galoisGroup_equiv_S5
  (f : Polynomial ℚ)
  (hf_sep : f.Separable)
  (hf_irred : Irreducible f)
  (hG : Nonempty ((f.SplittingField ≃ₐ[ℚ] f.SplittingField) ≃ Equiv.Perm (Fin 5))) :
  ¬ SolvableByRadicals ℚ f
```

You will almost certainly need to define:
```lean
def SolvableByRadicals (K : Type*) [Field K] (f : Polynomial K) : Prop := ...
```

A weaker but highly viable theorem is:

```lean
theorem galoisGroup_not_solvable_of_equiv_S5
  (f : Polynomial ℚ)
  (hG : Nonempty ((f.SplittingField ≃ₐ[ℚ] f.SplittingField) ≃ Equiv.Perm (Fin 5))) :
  ¬ Group.Solvable (f.SplittingField ≃ₐ[ℚ] f.SplittingField)
```

using the known fact that `S₅` is not solvable.

Then a second theorem:
```lean
theorem not_solvable_by_radicals_of_galoisGroup_not_solvable
  (f : Polynomial ℚ) :
  ¬ Group.Solvable (f.SplittingField ≃ₐ[ℚ] f.SplittingField) →
  ¬ SolvableByRadicals ℚ f
```

This modularizes the hard arithmetic and the conceptual Galois obstruction.

**Why this matters**
A machine-checked non-solvability theorem for a concrete quintic is already a landmark: it turns “no formula in radicals exists” into a certified theorem object. This is formal algebra as impossibility theory.

---

### Theorem C: Derived series criterion for solvability of polynomial Galois groups
Formalize a criterion linking the derived series of the automorphism group of the splitting field to polynomial solvability.

**Mathematical statement**
For a separable polynomial `f ∈ K[X]` with splitting field `L`, if the derived series of `Gal(L/K)` reaches the trivial subgroup in finitely many steps, then `f` is solvable by radicals; if the derived subgroup chain stabilizes above `⊥`, then `f` is not solvable by radicals.

**Lean-oriented theorem target**
```lean
theorem solvable_iff_derivedSeries_stabilizes_at_bot
  (G : Type*) [Group G] [Finite G] :
  Group.Solvable G ↔ ∃ n : ℕ, Group.derivedSeries G n = ⊥
```

and then instantiate with
```lean
theorem polynomial_solvable_by_radicals_of_derivedSeries_bot
  (K : Type*) [Field K]
  (f : Polynomial K) :
  (∃ n : ℕ, Group.derivedSeries (f.SplittingField ≃ₐ[K] f.SplittingField) n = ⊥) →
  SolvableByRadicals K f
```

Even if the second theorem is too ambitious initially, the first is a powerful finite-group theorem with direct downstream use.

**Why this matters**
This recasts radical solvability as a dynamical property of repeated commutators. It is the right abstraction for eventual automation and algorithm extraction.

---

## Secondary Theorem Targets

### Theorem D: `S₅` is not solvable
This may already exist in some form for symmetric groups; if not, prove it.

```lean
theorem not_solvable_perm_fin_five :
  ¬ Group.Solvable (Equiv.Perm (Fin 5))
```

A stronger theorem:
```lean
theorem not_solvable_perm_fin_of_five_le {n : ℕ} (h : 5 ≤ n) :
  ¬ Group.Solvable (Equiv.Perm (Fin n))
```

This is a major reusable lemma for all future Abel–Ruffini style arguments.

---

### Theorem E: A concrete irreducible quintic has discriminant not a square
Choose a polynomial where modular factorization and discriminant calculations are tractable. For example:
- `X^5 - X - 1`
- `X^5 - 4*X + 2`
- another standard quintic with known `S₅` Galois group

A useful theorem shape is:

```lean
theorem irreducible_X5_sub_X_sub_one : Irreducible (X^5 - X - (1 : Polynomial ℚ))
```

and/or

```lean
theorem discriminant_X5_sub_X_sub_one_nonsquare :
  ¬ IsSquare (Polynomial.discriminant (X^5 - X - (1 : Polynomial ℚ)))
```

These arithmetic lemmas are stepping stones to proving the Galois group is not contained in `A₅`, hence often `S₅` once a 5-cycle/transposition pattern is established.

---

## Proof Strategy Architecture

### Strategy 1: Group-theoretic spine first, radicals later
**Most promising overall.**

1. Prove finite-group lemmas:
   - solvable iff derived series terminates,
   - `A₅` simple nonabelian,
   - `S₅` not solvable.
2. Formalize the Galois group of a splitting field as a finite group and transfer subgroup data via the Galois correspondence.
3. Introduce a minimal `SolvableByRadicals` definition only after the obstruction theory is in place.

**Why promising**
Mathlib is stronger on groups, finite structures, and field extensions than on a polished “radicals tower” API. This route secures breakthrough theorems early and isolates definitional complexity.

---

### Strategy 2: Concrete quintic first via modular arithmetic and permutation group constraints
1. Pick one quintic `f ∈ ℚ[X]`.
2. Prove irreducibility over `ℚ` using Eisenstein after shift, reduction mod `p`, or rational root exclusion plus degree arguments.
3. Use factorization modulo primes to infer cycle types in the Galois group:
   - irreducible mod `p` gives a 5-cycle,
   - a factorization pattern like `(2)(1)(1)(1)` or discriminant nonsquare gives an odd permutation / transposition evidence.
4. Conclude `Gal(f/ℚ) = S₅`, then invoke non-solvability.

**Why promising**
This avoids formalizing the full generic quintic and instead attacks a sharply defined theorem. It is also closer to computational algebra and may be testable with external scripts before Lean formalization.

---

### Strategy 3: Order-theoretic Galois correspondence as anti-equivalence
1. Formalize the lattice anti-isomorphism between intermediate fields and subgroups of the automorphism group.
2. Show that subgroup normal series induce field towers.
3. Show abelian quotient data corresponds to stepwise extension structure.
4. Add radicals assumptions as an enhancement.

**Why promising**
This is conceptually beautiful and ties directly to the “galois_connection” theme in the catalog. It could produce a highly reusable formal architecture for future inverse Galois and descent work.

**Why less immediately promising**
The anti-equivalence layer is elegant but may consume time before yielding a headline theorem.

---

## Lean 4 Type Signature Suggestions

These signatures are aspirational and should be adjusted to actual Mathlib names.

### Finite solvable group criterion
```lean
theorem solvable_iff_exists_derivedSeries_eq_bot
  (G : Type*) [Group G] [Finite G] :
  Group.Solvable G ↔ ∃ n : ℕ, Group.derivedSeries G n = ⊥
```

### Non-solvability of `S₅`
```lean
theorem not_solvable_S5 :
  ¬ Group.Solvable (Equiv.Perm (Fin 5))
```

### Galois group obstruction theorem
```lean
theorem not_solvableByRadicals_of_galoisGroup_not_solvable
  (K : Type*) [Field K]
  (f : Polynomial K) [Fact f.Separable] :
  ¬ Group.Solvable (f.SplittingField ≃ₐ[K] f.SplittingField) →
  ¬ SolvableByRadicals K f
```

### Concrete quintic obstruction
```lean
theorem quintic_X5_sub_X_sub_one_not_solvableByRadicals :
  ¬ SolvableByRadicals ℚ (Polynomial.X^5 - Polynomial.X - 1)
```

This exact polynomial expression will need coercion cleanup. You may prefer a local definition:
```lean
noncomputable def quintic : Polynomial ℚ := X^5 - X - C 1
```

then:
```lean
theorem quintic_not_solvableByRadicals :
  ¬ SolvableByRadicals ℚ quintic
```

### Intermediate field / subgroup correspondence theorem
```lean
theorem intermediateField_subgroup_order_iso
  (K L : Type*) [Field K] [Field L] [Algebra K L]
  [FiniteDimensional K L] [Normal K L] [Separable K L] :
  Nonempty (IntermediateField K L ≃o OrderDual (Subgroup (L ≃ₐ[K] L)))
```

If an exact order isomorphism already exists in Mathlib, use it rather than reproving.

---

## Cross-Domain Connections

1. **Computational Complexity / Impossibility Theory**  
   Abel–Ruffini is an algebraic analogue of lower bounds: some outputs cannot be generated by a restricted computational model (radical expressions). Formalizing this opens a language for certified symbolic impossibility.

2. **Programming Languages / Compiler Correctness**  
   A radical tower is a typed expression language for algebraic numbers. Proving non-solvability says no program in that language computes roots of the generic quintic. This is a semantics-of-expressions perspective on Galois theory.

3. **Cryptography / Hidden Symmetry**  
   Galois groups encode hidden permutation symmetries of roots. Non-solvability corresponds to symmetry complexity that resists decomposition into abelian layers. This suggests formal analogies with nonabelian hardness phenomena.

4. **Order Theory / Abstract Interpretation**  
   The Galois correspondence between subgroups and intermediate fields is literally a structured abstraction relationship. This resonates with `galois_connection_theory_variety` from the catalog at the conceptual level.

5. **Symbolic-Numeric Algebra**  
   Certified statements about irreducibility, discriminants, and factorization patterns can feed verified CAS pipelines and theorem-prover-backed algebra software.

---

## Application Keywords

**Abel–Ruffini, solvability by radicals, splitting field, Galois group, derived series, solvable group, symmetric group `S₅`, alternating group `A₅`, intermediate fields, Galois correspondence, irreducibility, discriminant, modular factorization, certified impossibility, computational algebra, formal verification, symbolic computation**

---

## Concrete Work Plan

### Phase I: Build the obstruction core
- Search Mathlib for:
  - `Group.Solvable`
  - `derivedSeries`
  - solvability lemmas for permutation groups
  - `IntermediateField`
  - Galois correspondence theorems
  - `SplittingField`, `Polynomial.Separable`, `Normal`, `FiniteDimensional`
- Prove or reuse:
  - `solvable_iff_exists_derivedSeries_eq_bot`
  - `not_solvable_S5`

### Phase II: Define or approximate solvability by radicals
- Introduce a minimal robust definition:
  - existence of a finite tower of field extensions with each step generated by an `n`th root
  - optionally parameterized by roots of unity assumptions
- Prove:
  - solvable-by-radicals implies solvable Galois group
  - contrapositive obstruction theorem

### Phase III: Certify a concrete quintic
- Define a specific quintic over `ℚ`
- Prove irreducibility
- Prove enough cycle/discriminant facts to conclude Galois group contains the right permutations
- Derive non-solvability by radicals

### Phase IV: Stretch toward generic Abel–Ruffini
- Formalize the statement that the “generic quintic” has Galois group `S₅`
- If this is too large, produce a precise scaffold theorem reducing generic unsolvability to a universal `S₅`-specialization argument

---

## Standards for Nontriviality

Do **not** settle for a vacuous theorem like “if a polynomial is not solvable by radicals then it is not solvable by radicals.”  
A successful cycle should include at least one of:

1. a formal proof that `S₅` is not solvable,
2. a formal obstruction theorem from Galois-group non-solvability to non-solvability by radicals,
3. a certified concrete quintic non-solvability result,
4. a reusable order-isomorphism theorem between intermediate fields and subgroups.

Any one of these is meaningful; two or more would be exceptional.

---

## Deliverables

Required:
- Lean 4 files with minimized sorry usage
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- `demo.py` for modular factorization experiments supporting theorem selection
- `diagram.svg` illustrating subgroup/intermediate-field anti-correspondence and derived series towers

---

## Mandatory FUTURE_DIRECTIONS.md

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each including:
1. a precise theorem statement,
2. an expected Lean type signature,
3. a proof strategy,
4. dependencies in Mathlib or new definitions required,
5. one cross-domain connection.

Examples of strong next steps:
- formal inverse Galois realization for small solvable groups,
- certified discriminant criteria for `S_n` vs `A_n`,
- resolvent-based Galois group computation in Lean,
- generic polynomial formalization over `ℚ(t₁,...,tₙ)`,
- verified algorithm deciding solvability by radicals for degree `≤ 5` input polynomials.

You are not just formalizing classical algebra. You are building a verified theory of **which equations admit symbolic programs and which are provably beyond them**. That is the frontier.

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

Research domain: Algebra
Research mode: prove
