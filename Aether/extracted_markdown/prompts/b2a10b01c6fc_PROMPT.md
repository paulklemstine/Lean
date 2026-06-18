## Assignment: Langlands Correspondence: GL(1) Case

Mode: **formalize + prove**

This is not a request for a cosmetic number-theory extension. This is a demand to build the first serious Lean 4 bridge from explicit reciprocity phenomena to the conceptual architecture of the Langlands program in the rank-one case. The target is a mathematically honest formal skeleton of **global class field theory as the GL(1) Langlands correspondence**, with enough rigor and modularity that later cycles can attach local class field theory, Pontryagin duality, automorphic representations, and eventually higher-rank adelic harmonic analysis.

You should not try to jump directly to the full theorem over arbitrary global fields unless the infrastructure is already there. Instead, architect a formally robust ascent:
1. define the relevant adelic/idelic objects in a usable restricted-product style,
2. prove the key structural maps and quotient statements,
3. formalize the reciprocity map in the **explicit base case `K = ℚ`**,
4. prove a mathematically meaningful GL(1)-Langlands equivalence in the **finite-order / abelianized / explicit** regime.

The breakthrough is not “another reciprocity theorem.” The breakthrough is a reusable Lean framework where reciprocity is expressed as a morphism between adelic and Galois worlds, and where Dirichlet/Hecke characters become the first automorphic objects in a formal Langlands tower.

---

## Primary Theorem Targets

### Target A: Restricted-product architecture for finite idèles over `ℚ`
Define the finite adèle and finite idèle objects of `ℚ` as restricted products over primes, with integrality outside a finite set.

A mathematically precise target:

- Define a type of finite adèles of `ℚ` as families `(x_p)_p` with `x_p ∈ ℚ_p` and `x_p ∈ ℤ_p` for all but finitely many primes.
- Define finite idèles as families `(x_p)_p` with `x_p ∈ ℚ_pˣ` and `x_p ∈ ℤ_pˣ` for all but finitely many primes.
- Prove these form a ring / commutative group, respectively.
- Define the diagonal embedding `ℚ → 𝔸_f(ℚ)` and `ℚˣ → 𝕀_f(ℚ)`.

This is the infrastructure theorem that everything else rests on.

A Lean-shaped signature sketch:
```lean
def FiniteAdeleRat : Type _
def FiniteIdeleRat : Type _

instance : CommRing FiniteAdeleRat
instance : CommGroup FiniteIdeleRat

def ratDiagonalToFiniteAdele : ℚ →+* FiniteAdeleRat
def ratUnitsDiagonalToFiniteIdele : ℚˣ →* FiniteIdeleRat
```

If full `ℚ_p` / `ℤ_p` infrastructure is too heavy in one cycle, introduce an intermediate explicit model:
- either a sigma-type over primes with “integral outside finite support” predicate,
- or a valuation-based surrogate where coordinates are tracked by `padicValRat`.

A fallback theorem still worth proving:
```lean
def FiniteIdeleValuationData : Type :=
{f : ℕ → ℤ // Set.Finite {p | Nat.Prime p ∧ f p ≠ 0}}
```
with multiplication induced by addition of valuations, expressing the divisor-theoretic shadow of the idèle group.

This is weaker than the true idèle group, but it can already support the product formula and reciprocity shadow.

---

### Target B: Product formula over `ℚ`
Formalize the valuation-theoretic global constraint behind reciprocity:

For every nonzero rational `x`,
\[
\sum_{p \text{ prime}} v_p(x)\log p + \log |x|_\infty = 0,
\]
or equivalently in multiplicative normalized form,
\[
\prod_{v} |x|_v = 1.
\]

A Lean-friendly exact theorem, avoiding transcendental logs if necessary:
```lean
theorem rat_product_formula_finset
  (x : ℚˣ) :
  ((x : ℚ) .num.natAbs : ℤ) ≠ 0 := by
  -- infrastructure lemma placeholder
```

But the actual target should be stated in terms of prime valuations with finite support:
```lean
theorem rat_sum_padicValRat_eq
  (x : ℚˣ) :
  ∑ᶠ p, (padicValRat p (x : ℚ)) = 0 := by
  -- after normalization conventions are fixed
```

More realistically, prove an explicit numerator-denominator version:
```lean
theorem rat_factorization_balance
  (x : ℚˣ) :
  ∏ p in ((x : ℚ).num.natAbs.factors.toFinset), p ^ Nat.something
  =
  ∏ p in ((x : ℚ).den.factors.toFinset), p ^ Nat.something := by
```

The key point is not the exact API, but that you extract a finite-support valuation statement from unique factorization of integers/rationals and package it in a form later reusable for adèles/idèles.

This theorem is the formal shadow of the statement that principal idèles land in the kernel of the global reciprocity defect.

---

### Target C: Explicit Artin reciprocity for `ℚ`
The genuine conceptual milestone for this cycle:

For each positive integer `n`, construct the reciprocity morphism from the finite idèle class data of `ℚ` to the Galois group of the cyclotomic extension `ℚ(ζ_n)/ℚ`, and prove that it agrees with the usual map sending a prime `p ∤ n` to the Frobenius automorphism `ζ_n ↦ ζ_n^p`.

A precise theorem statement at the finite-level quotient:

```lean
def rayResidueMap (n : ℕ) : FiniteIdeleRat →* (ZMod n)ˣ := ...

theorem reciprocity_on_prime_idele
  {n p : ℕ} [Fact (0 < n)] [Fact p.Prime] (hp : Nat.Coprime p n) :
  rayResidueMap n (uniformizerIdele p)
    = Units.map (ZMod.castHom ?h) ⟨p, hp⟩ := by
```

Then identify `(ℤ/nℤ)ˣ` with the Galois group of the `n`th cyclotomic extension in whatever formal approximation is currently feasible:

```lean
def cyclotomicGal (n : ℕ) := (ZMod n)ˣ

theorem artin_reciprocity_Q_mod_n
  (n : ℕ) [Fact (0 < n)] :
  ∃ φ : FiniteIdeleRat →* cyclotomicGal n,
    -- principal idèles in kernel, continuity omitted if unavailable
    ∀ {p : ℕ}, p.Prime → Nat.Coprime p n →
      φ (uniformizerIdele p) = ⟨p, by simpa using ‹Nat.Coprime p n›⟩ := by
```

This is not yet the full topological statement of global class field theory, but it is already a nontrivial, explicit GL(1) Langlands correspondence over `ℚ`: the automorphic side is encoded by congruence/ray data on idèles, and the Galois side by cyclotomic abelian extensions.

---

### Target D: Finite-order GL(1) Langlands over `ℚ`
Prove the correspondence between finite-order Hecke characters of `ℚ` of conductor dividing `n` and 1-dimensional Galois representations factoring through the cyclotomic extension of conductor dividing `n`.

A formalized theorem can be packaged as an equivalence between character spaces:
```lean
def HeckeCharMod (n : ℕ) := {χ : FiniteIdeleRat →* ℂˣ // FactorsThroughModulus χ n}
def GalCharMod   (n : ℕ) := cyclotomicGal n →* ℂˣ

def langlandsGL1Q_mod (n : ℕ) : HeckeCharMod n ≃ GalCharMod n := ...
```

Or, if `ℂˣ` is too painful, use roots of unity / arbitrary commutative target group:
```lean
def HeckeCharTo (A : Type _) [CommGroup A] (n : ℕ) := ...
def GalCharTo   (A : Type _) [CommGroup A] (n : ℕ) := ...

def langlands_GL1_Q_finite
  (A : Type _) [CommGroup A] (n : ℕ) :
  HeckeCharTo A n ≃ GalCharTo A n := ...
```

This is the theorem that transforms the project from “formalized reciprocity computations” into “formalized Langlands in rank one.”

---

## Why This Would Be a Breakthrough

Formal mathematics has many isolated number-theoretic artifacts, but almost no serious, reusable Lean infrastructure for the adelic language that modern arithmetic geometry actually uses. If you can formalize even the `ℚ`-case with restricted products, quotient structures, and explicit reciprocity, you create:

- the first credible Lean entry point into the **Langlands program**,
- a bridge from **classical reciprocity laws** (quadratic reciprocity already exists in the catalog) to **adelic representation theory**,
- a framework for future formalization of:
  - local class field theory,
  - Tate’s thesis,
  - Hecke L-functions,
  - automorphic characters,
  - global duality and Poitou–Tate,
  - eventually higher-rank `GL_n`.

This is a field-opening formalization, not an isolated theorem.

---

## How to Build on the Existing Catalog

The existing catalog theorems are not directly class-field-theoretic, but they reveal useful reusable motifs:

1. `quadratic_reciprocity_law`
   - Use it as the first explicit sanity check that your reciprocity map specializes to classical residue-symbol behavior.
   - A bold bridge theorem: show that the mod-2 or quadratic character extracted from your finite-order GL(1) correspondence recovers the quadratic reciprocity law on primes.
   - This turns an isolated reciprocity theorem into a corollary of global reciprocity architecture.

2. `galois_connection_theory_variety`
   - Even if not directly about Galois groups of fields, mine its abstraction pattern: order-reversing correspondences and closure operators.
   - There is a conceptual opportunity to package subgroup/quotient correspondences in abelian class field theory via a Galois-connection-style API.
   - If feasible, define a closure operator on idèle class subgroups corresponding to finite abelian extensions.

3. `circle_group_law`
   - This may help as a certified group-law template for compact multiplicative targets.
   - Characters into `ℂˣ` often reduce, in finite-order cases, to roots of unity inside the unit circle.
   - You may reuse proof patterns for multiplicative maps landing in norm-1 elements.

4. `pell_group_law_unif`, `berggren_all_in_lorentz_group`
   - These signal the repository can sustain algebraic group constructions with nontrivial laws.
   - Use their style as precedent for explicit structure-building: define the object first, prove closure and law second, then establish functorial maps.
   - The moral: don’t fear explicit algebraic engineering.

---

## Recommended Proof Architecture

### Strategy A: Explicit cyclotomic-first approach for `ℚ` only
Most promising for this cycle.

1. **Model finite idèle congruence data explicitly**
   - Avoid full topological restricted products initially.
   - Define an idèle-like object by prime-indexed valuation/unit data with finite support.
   - Build the reduction map modulo `n` to `(ℤ/nℤ)ˣ`.

2. **Construct reciprocity via Chinese remainder / Frobenius**
   - Show each prime `p ∤ n` determines an automorphism of cyclotomic data by `ζ_n ↦ ζ_n^p`.
   - Extend multiplicatively from prime idèles/principal data.
   - Prove principal rational elements act trivially modulo the product formula / congruence compatibility.

3. **Identify character groups**
   - Precompose Galois characters with the reciprocity map.
   - Show every finite-order Hecke character factors through some modulus and thus through `(ℤ/nℤ)ˣ`.
   - Obtain the correspondence as a universal property of quotienting by principal congruence conditions.

Why this is most promising:
- It avoids requiring all of algebraic number theory at once.
- It isolates the essence of GL(1) Langlands in a finite explicit quotient.
- It can directly connect to `quadratic_reciprocity_law`.

---

### Strategy B: Quotient-theoretic class field theory skeleton
More conceptual, higher upside, but infrastructure-heavy.

1. Define the principal idèle subgroup inside the finite idèle group.
2. Define ray-class-like quotients for `ℚ`.
3. Prove an isomorphism
   \[
   \mathbb{I}_\mathbb{Q}/\mathbb{Q}^\times U(n) \cong (\mathbb{Z}/n\mathbb{Z})^\times.
   \]
4. Use this quotient as the formal statement of the Artin map at level `n`, then derive the character correspondence by Pontryagin-style duality at finite level.

Why this matters:
- This is much closer to the true global class field theory statement.
- It creates APIs reusable for arbitrary global fields later.

Risk:
- Quotients and subgroup normality bookkeeping may dominate the cycle.

---

### Strategy C: Reciprocity-from-symbols route
A daring route if cyclotomic/Galois infrastructure is weak.

1. Define local symbols / residue characters at primes.
2. Assemble them into a global symbol on rationals with finite support.
3. Prove a product formula for symbols.
4. Show quadratic reciprocity appears as the degree-2 shadow, then generalize to mod-`n` characters.

This would be elegant and historically resonant, but it risks proving only a reciprocity shadow rather than the genuine GL(1) correspondence unless carefully packaged.

---

## Concrete Theorem Sequence to Attack

You should aim for a chain of formally composable theorems like the following.

### 1. Finite support of rational valuations
```lean
theorem finite_prime_support_of_rat
  (x : ℚ) :
  Set.Finite {p : ℕ | Nat.Prime p ∧ padicValRat p x ≠ 0} := by
```

### 2. Additivity of valuations
```lean
theorem padicValRat_mul'
  {p : ℕ} [Fact p.Prime] {x y : ℚ} (hx : x ≠ 0) (hy : y ≠ 0) :
  padicValRat p (x * y) = padicValRat p x + padicValRat p y := by
```

### 3. Principal-support balance / product formula shadow
```lean
theorem rat_valuation_sum_zero
  (x : ℚˣ) :
  (∑ᶠ p, padicValRat p (x : ℚ) • (IdealizedPrimeWeight p)) = principalWeight x := by
```
If this exact shape is unrealistic, replace by an explicit numerator-denominator identity.

### 4. Congruence map from finite idèle data to `(ZMod n)ˣ`
```lean
def finiteIdeleToZModUnit (n : ℕ) : FiniteIdeleRat →* (ZMod n)ˣ := ...
```

### 5. Triviality on principal congruent subgroup
```lean
theorem finiteIdeleToZModUnit_principal_trivial
  (n : ℕ) :
  ∀ x : ℚˣ, x ∈ principalCongruenceSubgroup n →
    finiteIdeleToZModUnit n (ratUnitsDiagonalToFiniteIdele x) = 1 := by
```

### 6. Explicit Artin/Frobenius compatibility
```lean
theorem artin_on_primes
  {n p : ℕ} [Fact p.Prime] (hp : Nat.Coprime p n) :
  finiteIdeleToZModUnit n (uniformizerIdele p) = Units.unitOfCoprime p n hp := by
```

### 7. Finite-order GL(1) Langlands equivalence
```lean
def finiteHeckeCharacters (n : ℕ) (A : Type _) [CommGroup A] := ...
def finiteGaloisCharacters (n : ℕ) (A : Type _) [CommGroup A] := ...

theorem gl1_langlands_Q_finite_level
  (n : ℕ) (A : Type _) [CommGroup A] :
  finiteHeckeCharacters n A ≃ finiteGaloisCharacters n A := by
```

---

## Cross-Domain Connections You Must Exploit

### 1. Reciprocity law as distributed conservation law
The product formula is a conservation law across all places. This is a striking bridge to:
- statistical mechanics,
- network flow,
- gauge constraints.

You do not need to formalize physics, but you should explicitly frame the valuation balance theorem as a global conservation law assembled from local observables. This perspective may guide APIs for “local-to-global invariant sums.”

### 2. Galois connections and duality
Use the conceptual pattern behind `galois_connection_theory_variety`:
- subgroups of idèle classes ↔ abelian extensions,
- kernels of characters ↔ finite quotients,
- reciprocity as a universal dualizing map.

Even if only lightly formalized now, this should shape your definitions.

### 3. Classical reciprocity as the rank-one shadow of Langlands
Use `quadratic_reciprocity_law` as a demonstrator that your framework strictly contains a famous theorem.
An excellent bridge theorem would be:

```lean
theorem quadratic_reciprocity_from_artin_GL1_Q
  (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
  (hpq : p ≠ q) (hpodd : p ≠ 2) (hqodd : q ≠ 2) :
  -- statement recovering Legendre-symbol symmetry from the Artin map
  True := by
```

Replace `True` by the strongest formalizable exact statement available. Even a partial derivation would be strategically powerful.

### 4. Harmonic analysis / representation theory
Characters of idèle class groups are the simplest automorphic representations.
This project therefore opens a path to:
- Fourier analysis on locally compact abelian groups,
- Tate’s thesis,
- Hecke L-functions,
- automorphic induction in the abelian case.

You should mention these in comments/docs and orient the API toward them.

---

## Lean 4 Type Signature Guidance

Use concrete, incremental type signatures. Prefer proving finite-level theorems before topological completions.

Suggested intermediate definitions:
```lean
def PrimeSupport := {S : Finset ℕ // ∀ p ∈ S, Nat.Prime p}

def RatValuationData : Type :=
{f : ℕ → ℤ // Set.Finite {p | Nat.Prime p ∧ f p ≠ 0}}

def RatUnitMod (n : ℕ) := (ZMod n)ˣ

def finitePrimeIdele (p : ℕ) : RatValuationData := ...
def valuationDataToResidueClass (n : ℕ) : RatValuationData →* RatUnitMod n := ...
```

For finite-order characters:
```lean
def CharacterTo (G A : Type _) [CommGroup G] [CommGroup A] := G →* A

def RayClassCharacter (n : ℕ) (A : Type _) [CommGroup A] :=
  CharacterTo ((ZMod n)ˣ) A

def CyclotomicCharacter (n : ℕ) (A : Type _) [CommGroup A] :=
  CharacterTo ((ZMod n)ˣ) A
```

Then prove the equivalence is literally identity after identifying both sides with the same finite quotient. This is mathematically honest for `ℚ` at finite level and dramatically easier to formalize than a full-blown abstract Hecke-character definition on day one.

---

## What to Avoid

- Do **not** spend the whole cycle setting up general global fields if it prevents proving a single reciprocity theorem.
- Do **not** define adèles as arbitrary dependent records with no usable algebra.
- Do **not** aim for topological perfection before algebraic substance.
- Do **not** state “Langlands correspondence” in vague prose only; produce an actual finite-level equivalence theorem.

---

## Deliverables

1. Lean 4 code implementing as much of Targets A–D as possible.
2. At least one theorem that is genuinely nontrivial and new relative to the catalog:
   - ideally `artin_reciprocity_Q_mod_n`,
   - minimally a finite-level reciprocity/character correspondence theorem.
3. Documentation comments explaining the mathematical meaning of each construction.
4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete next steps**, each containing:
   - precise theorem statement,
   - Lean target signature,
   - proof strategy,
   - cross-domain significance.

This file is mandatory.

---

## Application Keywords

Langlands correspondence, global class field theory, Artin reciprocity, adèle ring, idèle class group, cyclotomic extensions, Frobenius automorphism, Hecke characters, Galois representations, finite abelian extensions, product formula, local-to-global principle, harmonic analysis, Tate’s thesis, automorphic forms, Pontryagin duality, reciprocity laws, algebraic number theory, formal verification, Lean 4, Mathlib.

---

## Final Charge

Build the first credible formal GL(1) Langlands bridge in Lean. Start with `ℚ`, finite level, explicit cyclotomic reciprocity, and quotient-theoretic character equivalence. If you succeed, you will have converted reciprocity from a collection of isolated symbolic miracles into a machine: local data in, global Galois symmetry out. That machine can power an entire future research program.

And produce `FUTURE_DIRECTIONS.md` as a real research roadmap, not an afterthought.

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
