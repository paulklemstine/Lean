## Assignment: Summary: Research Roadmap

Prove new, non-trivial theorems that turn the existing “invariant-bearing systems” infrastructure into a genuinely compositional mathematics of dynamics, entropy, and synchronization. Build on catalog theorems. Minimize sorry. Do not settle for routine generalization: the goal is to show that categorical products are not bookkeeping devices, but the engine behind sharp bounds and transfer principles across thermodynamics, automata, and cryptographic security.

Produce a structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps after the main theorem(s) are formalized.

---

## Mode: `prove`

## Central Vision

The existing binary product infrastructure suggests something much stronger than “products exist.” It suggests that invariant-equipped transition systems form a compositional semantics where:
- finite products encode parallel composition,
- well-founded measures certify joint termination,
- additive/logarithmic invariants propagate to pressure-style bounds,
- synchronization lengths in automata become combinatorial shadows of categorical product structure,
- and min-plus / entropy bounds in cryptography emerge as dual product laws.

The field-opening move is to prove **universal finite product and transfer theorems** strong enough that the same formal infrastructure drives all five directions. The right target is not five unrelated lemmas, but a small set of compositional meta-theorems from which the domain-specific statements fall out.

---

## Priority 1 — Finite Products as the Master Theorem

### Exact theorem target

Prove that the existing binary product extends to finite indexed products with the expected universal property, and package this as the foundational compositional principle for all subsequent directions.

A mathematically precise target is:

> For any finite family `(X i)` of invariant-bearing systems indexed by a finite type `ι`, there exists a product system `finProd X` with projection morphisms `π_i : finProd X ⟶ X i` such that for every cone `(f_i : Y ⟶ X i)`, there exists a unique mediating morphism `lift : Y ⟶ finProd X` satisfying `π_i ≫ lift = f_i` (or the conventionally oriented analogue in your category).

If your current development uses a concrete structure rather than `CategoryTheory.Limits`, prove the concrete universal property first, then derive the categorical form.

### Suggested Lean 4 type signature

Use the actual names in your codebase, but aim for a theorem of this shape:

```lean
theorem finProd_universal
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem)
  (Y : InvariantSystem)
  (f : ∀ i, Hom Y (X i)) :
  ∃! g : Hom Y (finProd X),
    ∀ i, proj X i ≫ g = f i
```

or, depending on morphism direction conventions:

```lean
theorem finProd_universal
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem)
  (Y : InvariantSystem)
  (f : ∀ i, Hom Y (X i)) :
  ∃! g : Hom Y (finProd X),
    ∀ i, g ≫ proj X i = f i
```

If the product object is represented concretely as a dependent tuple system, an even more implementation-ready version is:

```lean
theorem finProd_hom_ext
  {ι : Type u} [Fintype ι]
  {X : ι → InvariantSystem} {Y : InvariantSystem}
  {g h : Hom Y (finProd X)}
  (hproj : ∀ i, g ≫ proj X i = h ≫ proj X i) :
  g = h
```

together with

```lean
def finProdLift
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem)
  {Y : InvariantSystem}
  (f : ∀ i, Hom Y (X i)) :
  Hom Y (finProd X)
```

and its β/η laws.

### Why this is a breakthrough

This is the theorem that upgrades your work from “binary constructions exist” to a **formal compositional calculus**. Once finite products are universal, every multi-component bound becomes a theorem schema rather than a one-off proof. This opens:
- parallel composition semantics for cryptographic reductions,
- tensor-like combination principles for thermodynamic invariants,
- direct-product bounds for synchronizing automata,
- and eventually a bridge to operads, traced monoidal categories, and compositional verification.

### Proof strategy options

#### Strategy A — Induction on `Fintype.card ι` via binary products
1. Reindex the finite family along `Fin n` using `Fintype.equivFin`.
2. Define `finProd` recursively from the binary product and terminal object / singleton case.
3. Prove the universal property by induction, using the binary universal property at each step.

Why promising: this is the most robust Lean strategy if binary products are already verified. It minimizes new abstractions and uses extensionality over tuples.

#### Strategy B — Concrete tuple model first, abstract universal property second
1. Define `finProd X` concretely as a system with state/invariant data given pointwise over `∀ i, X i`.
2. Define projections and the mediating map by component extraction/assembly.
3. Prove uniqueness by function extensionality and the extensionality theorem for morphisms.

Why promising: if your systems are already record-based, this may be shorter than importing full categorical machinery. It also makes later computational theorems easier.

#### Strategy C — Use `CategoryTheory.Limits` as a backend
1. Instantiate your category of invariant-bearing systems with enough structure to admit finite products.
2. Show the binary product object agrees with the existing concrete construction.
3. Derive `finProd_universal` from `HasFiniteProducts`.

Why promising: strongest conceptual payoff, but only if your category instance is already close. Best if you want later interoperability with Mathlib’s limit machinery.

**Most promising:** Strategy A if this is a cold start from binary products; Strategy C only if categorical instances are already nearly complete.

### Cross-domain connections
- **Category theory:** finite limits, cones, representability.
- **Programming languages / semantics:** compositional denotational models for parallel systems.
- **Control theory:** product state spaces for coupled Lyapunov invariants.
- **Cryptography:** multi-stage protocol composition as a categorical product of adversarial views.

### Application keywords
`finite products`, `universal property`, `compositional semantics`, `categorical systems theory`, `parallel composition`, `formal verification`

---

## Priority 2 — Termination as Product Descent

### Exact theorem target

Show that if each component system admits a well-founded reduction measure, then the finite product system terminates under a lexicographic or multiset-combined measure.

A precise theorem schema:

> Let `(X_i)` be a finite family of systems, each equipped with a reduction relation `→_i` and a ranking function into a well-founded order. Then the induced product reduction on `finProd X` is well-founded. In particular, every reduction sequence in the product terminates.

### Suggested Lean 4 type signature

Concrete version:

```lean
theorem product_reduction_terminates
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem)
  (hterm : ∀ i, WellFounded (reduction (X i))) :
  WellFounded (productReduction (finProd X))
```

Sequence-oriented variant:

```lean
theorem product_reduction_terminates
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem)
  (hterm : ∀ i, WellFounded (reduction (X i))) :
  ∀ x, Acc (productReduction (finProd X)) x
```

If the product reduction is synchronous rather than asynchronous, make that explicit in the theorem statement.

### Why this is a breakthrough

This turns product structure into a machine for proving global liveness from local certificates. It is the formal analogue of “modular termination” in rewriting, distributed systems, and proof theory. In a cryptographic or protocol setting, it becomes compositional attack-surface exhaustion; in automata, it becomes bounded convergence; in thermodynamics, it becomes monotone decay to equilibrium.

### Proof strategy options

#### Strategy A — Lexicographic product of ranking functions
1. Extract a ranking function `ρ_i : X_i → α_i` into a well-founded order for each component.
2. Define a combined ranking on the product into a lexicographic product `Lex` over `∀ i, α_i` or an iterated finite lex order.
3. Show each product reduction strictly decreases the combined rank.

This is the cleanest if your reduction updates one component at a time.

#### Strategy B — Multiset measure
1. Send each product state to the multiset of component ranks.
2. Use the Dershowitz–Manna multiset extension of a well-founded order.
3. Show every reduction strictly decreases the multiset measure.

Best if component updates are not ordered or multiple components may reduce simultaneously.

#### Strategy C — Accessibility induction directly on tuples
1. Use induction over the finite index set.
2. Reduce the `n+1` case to the binary product of an `n`-fold product with one component.
3. Apply the existing binary termination theorem if available.

Best if you already prove a binary analogue.

**Most promising:** Strategy A for asynchronous one-step reduction; Strategy B for more symmetric semantics.

### Cross-domain connections
- **Rewriting theory:** modular termination and multiset path orders.
- **Proof theory:** cut elimination via product measures.
- **Distributed algorithms:** global convergence from local progress metrics.
- **Statistical mechanics:** monotone approach to equilibrium via product Lyapunov functions.

### Application keywords
`well-founded induction`, `termination`, `lexicographic order`, `multiset order`, `modular rewriting`, `liveness`

---

## Priority 3 — Pressure Bounds as Additivity/Subadditivity on Products

### Exact theorem target

Formalize a product inequality for a pressure-like invariant: the pressure of a composed system should be bounded by the sum of component pressures, or equal to the sum under independence hypotheses.

A precise mathematical target:

> If `pressure : InvariantSystem → ℝ` is monotone under the chosen notion of product composition and additive on independent observables, then for finite products
> `pressure (finProd X) ≤ ∑ i, pressure (X i)`,
> with equality under a certified independence condition.

### Suggested Lean 4 type signature

Subadditive form:

```lean
theorem pressure_product_bound
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem) :
  pressure (finProd X) ≤ ∑ i, pressure (X i)
```

Stronger conditional equality form:

```lean
theorem pressure_finProd_eq_sum
  {ι : Type u} [Fintype ι]
  (X : ι → InvariantSystem)
  (hindep : IndependentFamily X) :
  pressure (finProd X) = ∑ i, pressure (X i)
```

### Why this is a breakthrough

This would create a formal bridge between categorical composition and thermodynamic formalism. “Pressure” here is not just a real-valued annotation; it becomes a compositional resource measure. That opens a route to:
- entropy production bounds in coupled systems,
- complexity/energy tradeoff semantics for computation,
- and a common language with information theory and cryptography, where additivity and subadditivity are foundational.

### Proof strategy options

#### Strategy A — Direct real-analytic inequality from product definition
1. Expand `pressure (finProd X)` using the concrete product semantics.
2. Bound the relevant supremum / logarithm / partition sum by product-to-sum inequalities.
3. discharge finite-sum algebra with `Finset` lemmas and `linarith`/`nlinarith` where applicable.

Best if pressure is already defined concretely.

#### Strategy B — Prove a generic subadditive invariant theorem
1. Abstract a class of real-valued invariants satisfying monotonicity and binary product subadditivity.
2. Prove finite-product subadditivity by induction on cardinality.
3. Instantiate the theorem with `pressure`.

This is more visionary: it yields a reusable theorem schema for entropy, cost, energy, risk, and security.

#### Strategy C — Tropical/min-plus translation
1. Re-express pressure in logarithmic or min-plus coordinates.
2. Use min-plus distributivity / subadditivity, possibly leveraging
   `minplus_distributes_over_min_real`.
3. Pull the inequality back to ordinary real-valued pressure.

This is especially exciting if your pressure behaves like free energy or log-partition data.

**Most promising:** Strategy B, because it converts one theorem into a platform for many compositional inequalities.

### Catalog building blocks to exploit
- `minplus_distributes_over_min_real` from `Cryptography/TropicalMinPlusOWF.lean` can support a tropicalized proof architecture if pressure has a min-plus/log form.
- Existing entropy-style security theorems suggest additivity principles that may be abstracted and reused.

### Cross-domain connections
- **Thermodynamic formalism:** topological pressure, free energy.
- **Information theory:** entropy subadditivity, chain rules.
- **Tropical geometry:** logarithmic asymptotics and min-plus linearization.
- **Complexity theory:** compositional cost semantics.

### Application keywords
`pressure`, `subadditivity`, `free energy`, `entropy`, `tropicalization`, `resource semantics`

---

## Priority 4 — Automata Synchronization via Product Structure

### Exact theorem target

Show that synchronization bounds for product automata can be controlled in terms of component synchronization bounds. Even a non-sharp but universal upper bound would be highly valuable if formalized compositionally.

A theorem schema:

> If each finite automaton `A_i` admits a synchronizing word of length at most `L_i`, then the product automaton admits a synchronizing word of length bounded by a compositional expression `B(L_i, |A_i|)`; in favorable independent/reset-compatible cases, by `∑ i L_i`.

### Suggested Lean 4 type signature

```lean
theorem product_word_bound
  {ι : Type u} [Fintype ι]
  (A : ι → SyncAutomaton)
  (L : ι → ℕ)
  (hsync : ∀ i, ∃ w, IsSyncWord (A i) w ∧ w.length ≤ L i) :
  ∃ w, IsSyncWord (productAutomaton A) w ∧ w.length ≤ ∑ i, L i
```

If `∑ i, L i` is too optimistic in your model, replace with a proved bound, e.g. a product/cardinality-dependent expression. A weaker but still deep theorem is acceptable if it is universal and nontrivial.

### Why this is a breakthrough

This would connect categorical products to one of the deepest themes in automata theory: synchronization and Černý-type phenomena. A compositional synchronization theorem could create a new formal route to:
- modular control synthesis,
- symbolic model checking of coupled automata,
- and eventually product-based attacks on long-standing synchronizing word conjectures.

### Proof strategy options

#### Strategy A — Concatenate component reset words
1. Lift each component synchronizing word to a word acting on the product.
2. Show sequential application synchronizes coordinates one by one.
3. Bound the final length by the sum.

Works if the product alphabet/action allows coordinatewise control.

#### Strategy B — Rank reduction argument
1. Define the rank of a word on the product automaton.
2. Show component synchronizing words strictly reduce a suitable product rank.
3. Iterate until rank `1` is achieved.

More flexible if direct coordinate control is unavailable.

#### Strategy C — Categorical action semantics
1. View words as endomorphisms in the category of invariant systems.
2. Identify synchronization with factorization through a terminal or singleton object.
3. Use product universality to transport synchronizing morphisms.

Most conceptually novel, though probably harder in Lean.

**Most promising:** Strategy A if your automata product is direct and the alphabet decomposes; otherwise Strategy B.

### Cross-domain connections
- **Semigroup theory:** ranks, Green relations, transformation monoids.
- **Control theory:** reset sequences in hybrid systems.
- **Distributed computing:** convergence by staged local control.
- **Category theory:** synchronization as collapse through a universal morphism.

### Application keywords
`automata`, `synchronizing word`, `Černý`, `product automaton`, `reset sequence`, `control synthesis`

---

## Priority 5 — Security Composition in the Dual / Min Product

### Exact theorem target

Use the dual “min-product” semantics to prove that security of composed constructions is bounded by the minimum or sum-like combination of component security guarantees, depending on the adversarial model.

A mathematically sharp target:

> For systems with security metric `sec : S → ℝ`, if composition is modeled by a dual product where the attacker succeeds whenever one component fails, then the composed security is bounded below by the minimum of component securities:
> `sec (dualProd X Y) ≥ min (sec X) (sec Y)`.
> More generally, for finite products:
> `sec (dualFinProd X) ≥ inf_i sec (X_i)` or the corresponding finite minimum.

And, in entropy-style settings, derive a stronger additive theorem when independent entropy sources compose.

### Suggested Lean 4 type signature

Binary version:

```lean
theorem composed_security_bound
  (X Y : SecureSystem) :
  security (dualProd X Y) ≥ min (security X) (security Y)
```

Finite version:

```lean
theorem composed_security_bound_fin
  {ι : Type u} [Fintype ι]
  (X : ι → SecureSystem) :
  security (dualFinProd X) ≥ Finset.univ.inf' Finset.univ_nonempty (fun i => security (X i))
```

Entropy-strengthened version:

```lean
theorem composed_security_from_minEntropy
  (X Y : SecureSystem)
  (hindep : Independent X Y) :
  security (compose X Y) ≥ security X + security Y
```

### Why this is a breakthrough

This would unify categorical composition with concrete cryptographic reasoning: products become protocol combinators, and security bounds become universal properties rather than ad hoc hybrids. This opens a path toward:
- formally compositional reduction theory,
- entropy-preserving protocol pipelines,
- and min-plus cryptographic semantics linked to tropical optimization.

### Catalog building blocks to exploit
- `key_derivation_security_bound`
- `berggren_key_security_from_minEntropy`
- `security_level1_min_dim`
- `minplus_distributes_over_min_real`

These suggest two proof pathways: an entropy/additivity pathway and a min-plus/order-theoretic pathway. Use them explicitly rather than citing them decoratively.

### Proof strategy options

#### Strategy A — Order-theoretic monotonicity in the dual product
1. Define or expose the dual product order relation.
2. Show each projection or embedding is monotone with respect to security.
3. Derive the lower bound by the universal property and monotonicity of `min`.

Best if security is already an order-valued invariant.

#### Strategy B — Entropy extraction composition
1. Interpret each component security theorem as a lower bound from min-entropy.
2. Prove that the product/dual composition preserves the relevant entropy lower bound.
3. Invoke `key_derivation_security_bound` and/or `berggren_key_security_from_minEntropy`.

Best if your secure systems carry explicit entropy parameters.

#### Strategy C — Tropical/min-plus semantics
1. Re-express security loss in min-plus coordinates.
2. Use `minplus_distributes_over_min_real` to prove the dual-product law.
3. Translate back to ordinary security language.

This is the most cross-pollinating and could produce a genuinely new formal cryptographic semantics.

**Most promising:** Strategy B if entropy parameters are available; Strategy C if you want the most novel theorem.

### Cross-domain connections
- **Cryptography:** composable security, leakage resilience, extractor pipelines.
- **Tropical algebra:** min-plus composition laws for adversarial cost.
- **Information theory:** min-entropy and chain rules.
- **Proof theory:** cut-composition as security-preserving reduction.

### Application keywords
`composable security`, `min-entropy`, `dual product`, `tropical cryptography`, `extractors`, `protocol composition`

---

## Unifying Meta-Theorem You Should Seriously Attempt

If time permits, do not stop at domain-specific lemmas. Prove a reusable finite-product transfer theorem for invariants.

### Exact theorem target

> Any invariant `Φ : InvariantSystem → α` valued in a preorder with a binary composition law `⊗` satisfying:
> 1. monotonicity under morphisms,
> 2. binary product inequality `Φ (X ⨯ Y) ≤ Φ X ⊗ Φ Y` (or the dual inequality),
> 3. associativity/unitality of `⊗`,
>
> extends to finite products:
> `Φ (finProd X) ≤ ⨂ i, Φ (X i)`.

### Suggested Lean 4 type signature

```lean
theorem invariant_finProd_bound
  {ι : Type u} [Fintype ι]
  (Φ : InvariantSystem → α)
  [Preorder α] [Monoid α]
  (hprod : ∀ X Y, Φ (prod X Y) ≤ Φ X * Φ Y) :
  ∀ X : ι → InvariantSystem, Φ (finProd X) ≤ ∏ i, Φ (X i)
```

or additive:

```lean
theorem invariant_finProd_bound_add
  {ι : Type u} [Fintype ι]
  (Φ : InvariantSystem → ℝ)
  (hprod : ∀ X Y, Φ (prod X Y) ≤ Φ X + Φ Y) :
  ∀ X : ι → InvariantSystem, Φ (finProd X) ≤ ∑ i, Φ (X i)
```

### Why this is revolutionary

This would turn your library into a **factory for compositional theorems**. Pressure bounds, synchronization complexity, entropy/security loss, and termination heights all become instances. That is the kind of abstraction that opens a field rather than extends one.

---

## Lean execution guidance

- Prefer theorem schemas that can be instantiated repeatedly over isolated concrete lemmas.
- Build extensionality lemmas early:
  - product morphism extensionality,
  - projection simp rules,
  - finite tuple extensionality.
- If finite products are encoded recursively, prove clean rewrite lemmas for the `Fin.succ` case.
- Use `Fintype.equivFin` aggressively to reduce arbitrary finite indexing to `Fin n`.
- Separate:
  1. concrete product construction,
  2. universal property,
  3. invariant transfer theorem,
  4. domain-specific instantiations.

This separation will drastically reduce sorry pressure.

---

## Deliverables

1. Formalize and prove `finProd_universal`.
2. Prove at least one major transfer theorem among:
   - `product_reduction_terminates`
   - `pressure_product_bound`
   - `product_word_bound`
   - `composed_security_bound`
3. If possible, prove the generic meta-theorem (`invariant_finProd_bound` or additive variant).
4. Produce `FUTURE_DIRECTIONS.md` containing 3–5 specific next breakthroughs, for example:
   - finite coproducts / pushouts for adversarial composition,
   - traced monoidal structure for feedback systems,
   - entropy-pressure duality via tropicalization,
   - Černý-type lower/upper bounds through categorical rank,
   - compositional cut-elimination/security correspondence.

The ambition here is to make product structure the universal language of compositional mathematics across dynamics, automata, and cryptography.

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

Research domain: Cryptography
Research mode: prove
