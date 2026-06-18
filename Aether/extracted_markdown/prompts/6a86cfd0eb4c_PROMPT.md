## Assignment: Algebra–Tropical–RepresentationTheory  
## Tropical Satake Polytope Duality via Idempotent Weight Semimodules and Certified Crystal Reconstruction

**Mode:** `formalize` with a sharp `prove` core.

Work in:

`Bridges/AlgebraTropicalRepresentationTheory/TropicalSatakePolytopeDuality.lean`

Your task is not to produce a decorative analogy. Your task is to make precise, in Lean 4, a finite tropical Satake-style reconstruction principle: **finite highest-weight crystal data can be encoded by tropical weight profiles, and under explicit axioms this encoding is reversible and canonical**.

This is the right replacement for the failed Hecke-first approach. The Hecke picture is too global and too analytic for the current formal ecosystem. The crystal/polytope picture is finite, combinatorial, algorithmic, and still genuinely Langlands-flavored: it treats representation-theoretic structure as tropical convex geometry. If you can certify reconstruction from tropical support data, you open an entirely new formal bridge between idempotent algebra, representation theory, and polyhedral algorithms.

---

## Core Vision

Let \(R\) be a finite root datum with finite index set of simple roots \(I\), weight lattice \(P\), and a chosen dominance preorder. Define a tropical character/profile as a finitely supported map
\[
\chi : P \to \mathbb{T}
\]
into an idempotent tropical semiring, interpreted as a weight valuation / support height / polytope profile. Impose finite admissibility axioms capturing:

1. **highest-weight normalization**,  
2. **Weyl-convexity / root-string convexity**,  
3. **extremality / indecomposability**,  
4. **tensor-subadditivity** compatible with tropical Minkowski addition.

Then define finite crystal data as a colored directed graph with:
- vertex type `B`,
- weight map `wt : B → P`,
- partial Kashiwara operators `e i`, `f i`,
- finite highest-weight generation,
- local root-string axioms.

The breakthrough theorem should state that an admissible indecomposable tropical profile determines a **unique minimal highest-weight crystal realization**, up to canonical isomorphism, and that extremal tropical generators correspond to crystal vertices / extremal weight data.

This is not just “another equivalence.” It would establish that **tropical support geometry is a complete finite invariant for a certified class of crystal objects**. That is the seed of a formal tropical Satake machine.

---

## Precise Formal Target

You should introduce finite, Lean-friendly surrogate structures first, and only then layer in richer semantics.

### Suggested foundational structures

You likely want finite types first:

```lean
structure FiniteRootDatum where
  ι : Type
  [fintype_ι : Fintype ι]
  [decEq_ι : DecidableEq ι]
  P : Type
  [addCommGroup_P : AddCommGroup P]
  [decEq_P : DecidableEq P]
  [fintype_P : Fintype P]
  simpleRoot : ι → P
  -- optional: simpleCoroot, pairing, dominance preorder, Weyl generators
```

A finite tropical profile:

```lean
structure TropicalWeightProfile (R : FiniteRootDatum) where
  val : R.P → WithTop ℤ
  finite_support : {p : R.P | val p ≠ ⊤}.Finite
  highest_weight : R.P
  normalized : val highest_weight = 0
  admissible : Prop
```

A finite crystal object:

```lean
structure FiniteCrystal (R : FiniteRootDatum) where
  B : Type
  [fintype_B : Fintype B]
  [decEq_B : DecidableEq B]
  wt : B → R.P
  e : R.ι → B → Option B
  f : R.ι → B → Option B
  highest : B
  highest_axiom : ∀ i, e i highest = none
  -- local partial inverse axioms
  ef_partial_inv : ∀ i b b', f i b = some b' → e i b' = some b
  fe_partial_inv : ∀ i b b', e i b = some b' → f i b' = some b
  -- generation/minimality axioms to be added
```

A tropical valuation/profile functor from crystals to profiles should first be defined at the level of support:

```lean
def crystalSupportProfile (R : FiniteRootDatum) (K : FiniteCrystal R) : TropicalWeightProfile R := ...
```

At minimum, let the profile record whether a weight occurs, then refine to multiplicity-free valuation, height profile, or extremal support profile.

---

## Main Theorem Statement

You should aim for a theorem of the following shape, first in a finite support / minimal realization setting.

### Mathematical statement

For every finite root datum \(R\), every admissible indecomposable tropical weight profile \(\chi\) in a normal Weyl-convex class admits a finite highest-weight crystal \(K_\chi\) such that:

1. `crystalSupportProfile Kχ = χ`,
2. \(K_\chi\) is minimal among finite crystals realizing \(\chi\),
3. any other minimal finite crystal realizing \(\chi\) is canonically isomorphic to \(K_\chi\).

Moreover, extremal generators of \(\chi\) correspond to extremal vertices of \(K_\chi\), and tropical tensor convolution corresponds to Minkowski/tropical addition of support data.

### Lean 4 theorem signature target

You will need to define `Admissible`, `Indecomposable`, `MinimalRealization`, and `CrystalIso`, but the theorem should look approximately like this:

```lean
theorem exists_unique_minimal_crystal_of_admissible_profile
    (R : FiniteRootDatum)
    (χ : TropicalWeightProfile R)
    (hχ_adm : Admissible χ)
    (hχ_ind : Indecomposable χ) :
    ∃! K : FiniteCrystal R,
      RealizesProfile K χ ∧
      MinimalRealization χ K
```

And the uniqueness-up-to-isomorphism form:

```lean
theorem exists_unique_minimal_crystal_of_admissible_profile_up_to_iso
    (R : FiniteRootDatum)
    (χ : TropicalWeightProfile R)
    (hχ_adm : Admissible χ)
    (hχ_ind : Indecomposable χ) :
    ∃ K : FiniteCrystal R,
      RealizesProfile K χ ∧
      MinimalRealization χ K ∧
      ∀ K' : FiniteCrystal R,
        RealizesProfile K' χ →
        MinimalRealization χ K' →
        Nonempty (CrystalIso K K')
```

A faithful valuation theorem should then follow:

```lean
theorem valuation_fully_faithful_on_minimal_indecomposables
    (R : FiniteRootDatum) :
    FullFaithfulOn
      (fun K : FiniteCrystal R => crystalSupportProfile R K)
      {K | MinimalHighestWeightCrystal K ∧ IndecomposableCrystal K}
```

If full faithfulness is too heavy initially, prove the decisive injectivity surrogate:

```lean
theorem profile_eq_of_minimal_crystal_iso_class
    (R : FiniteRootDatum)
    (K₁ K₂ : FiniteCrystal R)
    (h₁ : MinimalHighestWeightCrystal K₁)
    (h₂ : MinimalHighestWeightCrystal K₂)
    (hsupp : crystalSupportProfile R K₁ = crystalSupportProfile R K₂) :
    Nonempty (CrystalIso K₁ K₂)
```

And the extremal correspondence:

```lean
theorem extremal_generators_correspond_to_highest_weight_vertices
    (R : FiniteRootDatum)
    (K : FiniteCrystal R)
    (hK : MinimalHighestWeightCrystal K) :
    ExtremalGenerators (crystalSupportProfile R K) ≃ HighestWeightExtremalVertices K
```

---

## Proof Architecture: 3 Viable Strategies

### Strategy A: Certified support-poset reconstruction
This is likely the **most Lean-promising** route.

**Step 1.** Define a finite support poset from an admissible tropical profile:
- vertices = weights in finite support,
- edges = allowed simple-root descents,
- admissibility guarantees local root-string structure.

**Step 2.** Construct a canonical crystal candidate by taking:
- one vertex per certified extremal support atom,
- `f_i` as the unique admissible descent along root `i` when it exists,
- `e_i` as the inverse ascent.

**Step 3.** Prove:
- realization of the original profile,
- minimality by support generation,
- uniqueness by induction on dominance height / distance from highest weight.

Why this is promising: it reduces everything to finite combinatorics and partial inverses, avoiding deep representation-theoretic baggage. It also aligns best with existing certified extremal-support machinery.

---

### Strategy B: Tropical convex hull / extremal generator reconstruction
This is conceptually more ambitious and may yield stronger statements.

**Step 1.** Define the profile as an idempotent semimodule element and formalize extremal generators in the tropical convex sense.

**Step 2.** Show that admissible indecomposable profiles have a unique minimal extremal generating family. Here you should explicitly exploit:

- `exists_unique_minimal_extremal_support`  
  from  
  `Bridges/AlgebraTropicalCryptography/TropicalChoquetRadonTrapdoorDuality.lean`

Use it not as a metaphor but as a formal engine: adapt its uniqueness-of-minimal-extremal-support argument from tropical convex support decompositions to weight-profile decompositions indexed by the finite weight lattice.

**Step 3.** Convert each extremal generator into a crystal vertex and prove Kashiwara local axioms from root-convexity constraints.

Why this matters: it turns tropical Choquet-style extremality into crystal reconstruction. That is exactly the kind of cross-pollination that creates a new field.

---

### Strategy C: Polytope normal fan / Newton support route
This is the most geometric route and could be the most revolutionary if it lands.

**Step 1.** Define a finite Newton polytope or support polytope associated to the tropical profile.

**Step 2.** Show admissibility implies the edge directions lie in simple-root directions and satisfy local normality constraints.

**Step 3.** Reconstruct a crystal graph from the 1-skeleton plus highest-weight orientation, then prove uniqueness from polytope minimality.

Why this is powerful: it upgrades the theorem from “support set determines graph” to “polyhedral geometry determines representation combinatorics.” That would be a genuinely Satake-flavored statement.

Most likely, Strategy C should be built after A or B provides the combinatorial spine.

---

## Recommended Order of Attack

1. **Build a finite toy theory** where `P` is finite and profiles are support-valued or `WithTop ℤ`-valued.
2. Prove **existence/uniqueness of minimal reconstruction** in this toy setting.
3. Add **extremal generator correspondence**.
4. Add **tensor/Minkowski compatibility**.
5. Only then formulate the “fully faithful valuation” theorem.

Do not start with categorical full faithfulness. Start with canonical reconstruction and uniqueness up to iso. That is the irreversible core.

---

## Existing Verified Theorems to Exploit

### 1. `exists_unique_minimal_extremal_support`
File:
`Bridges/AlgebraTropicalCryptography/TropicalChoquetRadonTrapdoorDuality.lean`

Use it as the template for the uniqueness mechanism. The key transfer principle should be:

- tropical profile support admits an extremal decomposition,
- indecomposable admissible profiles force a unique minimal extremal support family,
- this family becomes the canonical vertex set of the reconstructed crystal.

If necessary, abstract its proof into a reusable finite-idempotent-support lemma.

### 2. `finite_tropical_hecke_realization_duality`
Even if the prior Hecke duality line was too ambitious globally, the theorem may still contain a useful finite realization pattern:
- realization from finite tropical data,
- uniqueness of a minimal object,
- support-to-algebra correspondence.

Mine it for categorical scaffolding, uniqueness patterns, and finite realization tactics. Reuse the formal architecture, not the failed philosophical framing.

---

## Concrete Intermediate Theorems

These should appear as explicit Lean milestones.

```lean
theorem exists_minimal_support_crystal
    (R : FiniteRootDatum)
    (χ : TropicalWeightProfile R)
    (hχ : Admissible χ) :
    ∃ K : FiniteCrystal R, RealizesProfile K χ
```

```lean
theorem minimal_crystal_unique_up_to_iso
    (R : FiniteRootDatum)
    (χ : TropicalWeightProfile R)
    (K₁ K₂ : FiniteCrystal R)
    (h₁ : RealizesProfile K₁ χ ∧ MinimalRealization χ K₁)
    (h₂ : RealizesProfile K₂ χ ∧ MinimalRealization χ K₂) :
    Nonempty (CrystalIso K₁ K₂)
```

```lean
theorem indecomposable_profile_has_unique_extremal_support
    (R : FiniteRootDatum)
    (χ : TropicalWeightProfile R)
    (hχ_adm : Admissible χ)
    (hχ_ind : Indecomposable χ) :
    ∃! S : Finset R.P, IsMinimalExtremalSupport χ S
```

```lean
theorem tensor_profile_corresponds_to_minkowski_sum
    (R : FiniteRootDatum)
    (K₁ K₂ : FiniteCrystal R) :
    crystalSupportProfile R (tensorCrystal K₁ K₂) =
      tropicalMinkowskiProfile (crystalSupportProfile R K₁) (crystalSupportProfile R K₂)
```

Even a weak finite version of the tensor theorem would already be major: it says tropical addition knows tensor product support.

---

## Cross-Domain Connections You Should Make Explicit in the Development

### 1. Tropical convexity ↔ highest-weight generation
Highest-weight crystals are generated by downward root moves; tropical convex profiles are generated by extremal support atoms. This is the same architecture in two languages.

### 2. Newton polytopes ↔ crystal graphs
The support polytope is the “shadow” of the representation; the crystal graph is the discrete skeleton of its root-direction geometry. Proving reconstruction from one to the other is a new formal bridge between polyhedral combinatorics and representation theory.

### 3. Idempotent semimodules ↔ categorified character theory
Ordinary characters add multiplicities; tropical characters retain extremal geometry. This suggests a new notion of **idempotent character theory** where indecomposable tropical profiles classify minimal combinatorial representations.

### 4. Certified algorithms ↔ canonical mathematics
A reconstruction theorem here is not just abstract existence: it gives a certifiable algorithm for recovering finite representation data from tropical support. This has computational consequences for symbolic representation theory, combinatorial optimization, and verified polyhedral computation.

### 5. Satake/Langlands flavor without analytic overhead
The classical Satake transform packages representation data into invariant functions. Your tropical-crystal version packages finite representation data into tropical support profiles. If formalized well, this becomes a realistic precursor to a genuine tropical geometric Satake program.

---

## Application Keywords

Use and expose these in theorem names, comments, and FUTURE_DIRECTIONS:

- tropical Satake
- crystal reconstruction
- highest-weight polytope
- idempotent character theory
- tropical convexity
- Newton polytope
- Kashiwara operators
- extremal support
- Minkowski tensor duality
- certified representation recovery
- combinatorial Langlands
- polyhedral representation theory

---

## Formalization Advice

- Keep the first version **finite everywhere**.
- Use `Finset` aggressively before abstracting to `Set`.
- Encode Kashiwara operators as `Option`.
- Separate:
  1. data,
  2. local crystal axioms,
  3. admissibility of tropical profiles,
  4. realization/minimality,
  5. uniqueness up to iso.
- Define isomorphism as a structure preserving `wt`, `e`, `f`.
- If the full Weyl group is too heavy, start with **simple-root convexity only** and state Weyl-convexity as a later strengthening.
- If multiplicities are difficult, first work with **support-only tropical characters**.

A successful finite theorem here is not a toy. It is the first certified theorem in a possible new subject.

---

## Deliverables

1. A Lean 4 file formalizing the finite structures and proving the strongest reconstruction theorem you can.
2. Clear theorem names for:
   - existence,
   - uniqueness up to iso,
   - extremal support correspondence,
   - tensor/Minkowski compatibility if reachable.
3. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough-level next steps**.

That file must not be generic. It must propose specific next theorems, for example:
- extension from finite weight sets to finitely generated submonoids of the weight lattice,
- tropical Demazure crystals,
- polytope-normal-fan reconstruction,
- tropical Littlewood–Richardson multiplicity bounds,
- geometric Satake shadows via idempotent perverse sheaf invariants.

Produce the finite certified core now. If you succeed, you will have created the first serious formal bridge from tropical convex geometry to crystal representation theory.

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
Research mode: formalize
