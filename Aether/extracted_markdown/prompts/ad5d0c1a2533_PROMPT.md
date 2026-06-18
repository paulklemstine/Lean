## Assignment: Birch–Swinnerton-Dyer via Tropical L-Function Specialization

Mode: **prove**

This direction is only worth pursuing if we make it precise enough to become a genuine new formal interface between arithmetic geometry, tropical algebra, and idempotent analysis. Do **not** merely restate BSD poetically. Replace inaccessible classical objects by rigorously defined tropical surrogates whose equality can actually be proved in Lean 4, and whose shape clearly points toward the full conjecture.

Your target is to build the first formal bridge theorem showing that a tropicalized special-value package simultaneously encodes:
1. a rank-like invariant from a finitely generated abelian group model of Mordell–Weil,
2. an order-of-vanishing invariant of a min-plus Dirichlet/L-series,
3. a residue-like invariant combining regulator/Tamagawa-style correction terms.

The breakthrough is not “BSD in full.” The breakthrough is a **formal tropical BSD machine**: a precise theorem schema in Lean that makes the BSD pattern executable in idempotent mathematics.

---

## Core Vision

Classical BSD predicts
\[
\operatorname{ord}_{s=1} L(E,s)=\operatorname{rank} E(\mathbb Q),
\]
and relates the leading coefficient at \(s=1\) to regulator, Tamagawa numbers, torsion, and Tate–Shafarevich data.

Your mission is to define a tropical analog where:

- the “order of vanishing” is replaced by a **stability order** or **contact order** of a min-plus L-function at a basepoint;
- the Mordell–Weil rank is replaced by a **tropical rank** extracted from a finitely generated additive structure;
- the leading coefficient package is replaced by an **idempotent residue** defined by repeated minima or slope extraction.

This must be done with concrete types already tractable in Lean: `ℕ`, `ℤ`, `ℝ`, `Finset`, functions `ℕ → ℝ`, and finitely generated abelian-group proxies such as `ℤ^n` or `Fin n → ℤ`.

---

## Precise Theorem Targets

You should introduce a toy-but-nontrivial formal model first, then prove a structural theorem that deserves to be called a tropical BSD prototype.

### Target Theorem A: Tropical rank equals tropical vanishing order for a split model

Define a tropical Mordell–Weil model:
\[
\mathrm{MW}_n := \mathbb Z^n \cong (Fin\, n \to \mathbb Z),
\]
with tropical rank `n`.

Define a min-plus L-function
\[
L^{\operatorname{trop}}_n(t) := \min_{I \subseteq \{0,\dots,n-1\}} \bigl(|I| \cdot t + c_I\bigr),
\]
for constants \(c_I \in \mathbb R\), normalized so that the minimum at \(t=0\) is attained exactly by subsets of minimal cardinality and the first break occurs with slope \(n\) in the generic split case.

Then prove that the tropical order of vanishing at `t = 0` equals `n`.

A Lean-friendly signature could be:

```lean
def TropicalMWRank (n : ℕ) : ℕ := n

def tropLSeries (n : ℕ) (c : Finset (Fin n) → ℝ) (t : ℝ) : ℝ :=
  Finset.inf' (Finset.powerset (Finset.univ : Finset (Fin n))) (by simp) (fun I => (I.card : ℝ) * t + c I)

def TropicalVanishingOrder
    (f : ℝ → ℝ) (t₀ : ℝ) (m : ℕ) : Prop :=
  ∀ᶠ ε in nhdsWithin 0 (Set.Ioi (0 : ℝ)),
    ∃ a : ℝ, f (t₀ + ε) = a + m * ε

theorem tropical_BSD_split_model
    (n : ℕ)
    (c : Finset (Fin n) → ℝ)
    (hgen : ∀ I : Finset (Fin n), c I = 0 ↔ I = ⊥)
    : ∃ m, TropicalVanishingOrder (tropLSeries n c) 0 m ∧ m = TropicalMWRank n := by
  sorry
```

This exact signature may need refinement because `Finset.inf'` over `ℝ` is awkward and `∀ᶠ` may be too analytic for a first pass. A more robust discrete version is likely better:

```lean
def tropLSeriesNat (n : ℕ) (c : Finset (Fin n) → ℤ) (k : ℕ) : ℤ :=
  ((Finset.powerset (Finset.univ : Finset (Fin n))).image
    (fun I => I.card * k + Int.toNat (c I))).min' (by sorry)

def discreteTropicalVanishingOrder (f : ℕ → ℤ) : ℕ :=
  sInf {m | ∀ k, f k = f 0 + m * k}

theorem tropical_BSD_discrete_split_model
    (n : ℕ)
    (c : Finset (Fin n) → ℕ)
    (h0 : c ∅ = 0)
    (hpos : ∀ I ≠ ∅, 0 < c I)
    : discreteTropicalVanishingOrder (tropLSeriesNat n c) = n := by
  sorry
```

Even better: define the order as the least slope among active affine pieces and prove it equals the minimal cardinality of a minimizing support family. That is fully combinatorial and ideal for Lean.

---

### Target Theorem B: Idempotent residue factors as tropical regulator plus tropical Tamagawa defect

Define a tropical regulator from a finite family of vectors \(v_i \in \mathbb R^n\) by
\[
R_{\operatorname{trop}}(v_1,\dots,v_n) := \min_{\sigma \in S_n} \sum_i (v_i)_{\sigma(i)},
\]
the tropical determinant/permanent-type quantity.

Define a Tamagawa defect term from local penalties \( \tau_p \in \mathbb R_{\ge 0}\) by finite sum
\[
T_{\operatorname{trop}} := \sum_{p \in S} \tau_p.
\]

Define the idempotent residue of the tropical L-function at the basepoint to be the minimum constant term among affine pieces realizing the vanishing slope.

Then prove:

```lean
def tropicalRegulator (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ) : ℝ := by
  exact Finset.inf' Finset.univ (by simp) (fun σ : Equiv.Perm (Fin n) =>
    ∑ i, M i (σ i))

def tropicalTamagawa (S : Finset ℕ) (τ : ℕ → ℝ) : ℝ :=
  ∑ p in S, τ p

def tropicalResidue
    (n : ℕ) (c : Finset (Fin n) → ℝ) : ℝ :=
  Finset.inf' ((Finset.powerset (Finset.univ : Finset (Fin n))).filter (fun I => I.card = n)) (by sorry) c

theorem tropical_residue_decomposes
    (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ)
    (S : Finset ℕ) (τ : ℕ → ℝ)
    (c : Finset (Fin n) → ℝ)
    (hres : tropicalResidue n c = tropicalRegulator n M + tropicalTamagawa S τ)
    : tropicalResidue n c = tropicalRegulator n M + tropicalTamagawa S τ := by
  exact hres
```

The above theorem is tautological as written, so do **not** stop there. Replace it by a theorem where `c` is *constructed* from `M` and `τ`, and prove the equality by unfolding the minimum:

```lean
def residueData
    (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ)
    (S : Finset ℕ) (τ : ℕ → ℝ)
    (I : Finset (Fin n)) : ℝ :=
  if h : I.card = n then tropicalRegulator n M + tropicalTamagawa S τ
  else (I.card : ℝ) + tropicalRegulator n M + tropicalTamagawa S τ + 1

theorem tropical_residue_model_exact
    (n : ℕ) (M : Matrix (Fin n) (Fin n) ℝ)
    (S : Finset ℕ) (τ : ℕ → ℝ) :
    tropicalResidue n (residueData n M S τ) =
      tropicalRegulator n M + tropicalTamagawa S τ := by
  sorry
```

This is the right shape: it proves a genuine minimum principle and packages regulator/Tamagawa terms into a single tropical residue.

Build explicitly on:
- `tropical_residue_min` from `Algebra/TropicalBSD/TropicalBSDPrototype.lean`,
- `tropical_idempotent_dense`,
- `tropical_min_assoc`.

These are not decorative references: use them to normalize nested `min` expressions, collapse idempotent duplicates, and prove the minimum is attained on the full-cardinality support.

---

### Target Theorem C: Tropical BSD inequality and equality criterion

After proving the exact split model, push to a more robust theorem:

\[
\operatorname{trop\_rank}(G) \le \operatorname{ord}^{\operatorname{trop}}_{t=0} L_G^{\operatorname{trop}}(t),
\]
with equality under a genericity/nondegeneracy condition.

Lean-style sketch:

```lean
structure TropicalBSDData where
  n : ℕ
  coeff : Finset (Fin n) → ℝ
  generic : Prop

def tropRank (D : TropicalBSDData) : ℕ := D.n

def tropOrd (D : TropicalBSDData) : ℕ := sorry

theorem tropical_BSD_inequality
    (D : TropicalBSDData) :
    tropRank D ≤ tropOrd D := by
  sorry

theorem tropical_BSD_equality_of_generic_data
    (D : TropicalBSDData)
    (hgen : D.generic) :
    tropRank D = tropOrd D := by
  sorry
```

This is the theorem schema that opens the field. It says: tropical BSD is not a one-off identity but a stability principle for an entire class of idempotent arithmetic objects.

---

## Recommended Lean 4 Type Signatures

Use these or refined variants:

```lean
def TropicalRankFG (n : ℕ) : ℕ := n

def affinePiece (I : Finset α) (t : ℝ) (c : Finset α → ℝ) : ℝ :=
  (I.card : ℝ) * t + c I

def tropicalLSeriesFinset
    {α : Type} [DecidableEq α] (s : Finset α) (c : Finset α → ℝ) (t : ℝ) : ℝ :=
  Finset.inf' (s.powerset) (by simp) (fun I => affinePiece I t c)

def minimizingCardinality
    {α : Type} [DecidableEq α] (s : Finset α) (c : Finset α → ℝ) : ℕ :=
  ((s.powerset).filter (fun I => c I = tropicalLSeriesFinset s c 0)).min' (by sorry) Finset.card

theorem tropical_order_eq_minimizing_cardinality
    {α : Type} [DecidableEq α]
    (s : Finset α) (c : Finset α → ℝ)
    (hgeneric : ∀ I ∈ s.powerset, ∀ J ∈ s.powerset, c I = c J → I.card = J.card → I = J) :
    minimizingCardinality s c ≤ s.card := by
  sorry
```

And for matrix/regulator structures:

```lean
def tropicalPermanent
    {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.inf' Finset.univ (by simp) (fun σ : Equiv.Perm (Fin n) =>
    ∑ i, M i (σ i))

theorem tropicalPermanent_idempotent_invariant
    {n : ℕ} (M : Matrix (Fin n) (Fin n) ℝ) :
    tropicalPermanent M = tropicalPermanent M := by
  simp [tropicalPermanent]
```

Again: do not settle for trivial equalities. Use this as scaffolding toward a nontrivial theorem asserting exact evaluation for diagonal or Monge-type matrices, where the identity permutation minimizes the tropical permanent.

---

## Proof Strategy Architecture

### Strategy A: Pure finite-combinatorial min-plus geometry
Most promising for Lean and for producing nontrivial theorems quickly.

1. **Define tropical L-series as a finite minimum of affine functions.**
   This avoids analytic convergence issues entirely.
2. **Extract tropical vanishing order as the minimal active slope near the basepoint.**
   In finite minima of affine functions, local behavior is governed by active pieces.
3. **Show active slope equals support cardinality.**
   Under genericity assumptions on the constants `c`, the unique minimizer at the basepoint has cardinality exactly the tropical rank.
4. **Use `tropical_min_assoc`, `tropical_idempotent_dense`, and `tropical_residue_min`** to normalize minima and prove exact attainment of the residue term.

Why this is strongest: it gives a complete, formal, self-contained tropical BSD theorem without importing deep analytic number theory. It is the ideal seed crystal.

---

### Strategy B: Finitely generated abelian groups and tropical height pairing
This is deeper and more structurally meaningful.

1. Model Mordell–Weil data by `Fin n → ℤ`.
2. Define a tropical height:
   \[
   h_{\operatorname{trop}}(x)=\min_i |x_i| \quad\text{or}\quad \sum_i w_i |x_i|
   \]
   depending on tractability.
3. Build a tropical regulator as the tropical determinant/permanent of a height-pairing matrix.
4. Show that the residue of the tropical L-series built from basis-support data equals the tropical regulator plus local defect.

Why it matters: this upgrades the theorem from a finite-minimum trick to a genuine arithmetic analogy with height pairings and regulators.

Risk: formal absolute values on `ℤ`, matrix tropical determinant minimization, and support combinatorics may take longer.

---

### Strategy C: Newton polygon / Legendre transform viewpoint
Most visionary, best for cross-domain impact.

1. Interpret the tropical L-series as a convex piecewise-linear function.
2. Tropical order of vanishing becomes the left/right slope at the basepoint.
3. The residue becomes the intercept of the supporting face.
4. Prove equality with rank by identifying the relevant face with the convex hull of basis-support data.

Why it is revolutionary: this recasts BSD as a theorem about convex geometry and support functions. It opens the door to importing tools from optimization, large deviations, and mirror symmetry.

Risk: some convex-analysis infrastructure may need to be built manually in Lean.

**Recommendation:** start with Strategy A, package the result abstractly enough to support Strategy B later, and explain Strategy C in `FUTURE_DIRECTIONS.md`.

---

## Cross-Domain Connections You Must Exploit

This project becomes field-opening only if you make the tropical BSD package converse with other disciplines.

### 1. Convex geometry / Newton polygons
A min-plus L-series is a support function of a finite set of affine pieces. The tropical vanishing order is literally a slope of a Newton polygon. This connects arithmetic rank to convex-geometric face data.

### 2. Optimization / shortest path / semiring algorithms
Tropical minima are algorithmic objects. If the BSD package is recast in min-plus linear algebra, then rank detection becomes computable by semiring methods. This suggests certified arithmetic heuristics.

### 3. Spectral algebra / idempotent analysis
Use `tropical_min_assoc` and idempotent density as algebraic laws of a semiring-valued spectral theory. The “special value formula” becomes an eigenvalue/residue identity in the tropical semiring.

### 4. Information theory
The tropical residue is a compression of multiple arithmetic correction factors into one idempotent invariant. This invites an entropy-style interpretation: the residue as an information bottleneck for arithmetic complexity.

### 5. Mathematical physics
Piecewise-linear special-value laws resemble zero-temperature limits of partition functions. The tropical L-series can be seen as a ground-state energy envelope, with rank as degeneracy order. This is exactly the kind of unexpected bridge that can launch a new subject.

---

## How to Build on Catalog Theorems

Use the verified theorems concretely, not ceremonially.

- `tropical_residue_min`  
  Use this as the foundational lemma for proving that the residue term is the minimum among active top-slope pieces. Extend it from prototype statements to your `tropicalResidue` construction.

- `tropical_idempotent_dense (x : ℝ) : min x x = x`  
  Use repeatedly when duplicate affine pieces appear after support normalization or cardinality partitioning.

- `tropical_min_assoc (a b c : ℝ)`  
  Essential for rebracketing nested minima when proving that a family minimum reduces to a selected active support set.

The symmetric-group theorems
- `symmetric_group_order`
- `qdf_symmetry_group_order`

should be used if you define the tropical regulator via permutations. They give a foothold for finite permutation indexing and may help justify nonemptiness/cardinality of permutation parameter spaces.

---

## Concrete Deliverables

1. **Lean file implementing the tropical BSD infrastructure**
   - `TropicalRankFG`
   - `tropicalLSeriesFinset` or discrete variant
   - `tropicalResidue`
   - `tropicalRegulator`
   - vanishing-order notion suited to finite minima

2. **At least one genuinely nontrivial theorem fully proved**
   Preferred:
   - `tropical_BSD_discrete_split_model`, or
   - `tropical_residue_model_exact`, or
   - `tropical_BSD_equality_of_generic_data`

3. **A bridge theorem to another domain**
   Example:
   - identify tropical vanishing order with slope of a convex piecewise-linear function;
   - or show tropical regulator equals tropical permanent of a diagonal/Monge matrix;
   - or show the residue computation is equivalent to a finite optimization problem.

4. **Minimize sorry**
   If a full equality theorem is too ambitious, prove the inequality theorem and a separate equality criterion.

---

## Suggested File Organization

- `Algebra/TropicalBSD/TropicalBSDSpecialization.lean`
- `Algebra/TropicalBSD/TropicalResidueRegulator.lean`
- `Algebra/TropicalBSD/TropicalNewtonPolygon.lean`

If you discover existing prototype infrastructure in `Algebra/TropicalBSD/TropicalBSDPrototype.lean`, extend it rather than duplicating it.

---

## Application Keywords

BSD, tropical geometry, idempotent analysis, min-plus algebra, arithmetic statistics, Newton polygon, tropical regulator, Tamagawa numbers, Mordell–Weil rank, special values of L-functions, semiring optimization, convex geometry, zero-temperature limit, tropical permanent, arithmetic information theory.

---

## Non-Negotiable Standard

Do not claim to prove classical BSD. Prove a **precise tropical analog** whose formal structure is unmistakably modeled on BSD and whose theorems are mathematically nontrivial, formally certified, and extensible.

---

## Required FUTURE_DIRECTIONS.md

You must produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each with:
- a precise theorem statement,
- why it would matter,
- what existing theorem from this cycle it builds on,
- expected formalization difficulty.

The next steps should be at the level of:
1. tropical BSD for weighted support filtrations;
2. tropical height-pairing and exact regulator formulas;
3. Newton-polygon equivalence of vanishing order and support codimension;
4. semiring Tauberian theorem for tropical Dirichlet series;
5. tropical Gross–Zagier-style derivative formula prototype.

Do not make them vague. Make them executable.

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
