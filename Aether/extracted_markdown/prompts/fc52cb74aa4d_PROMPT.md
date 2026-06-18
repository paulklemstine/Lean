Soli Deo Gloria

## Assignment: Tropical Satake Isomorphism for GL_n

**Mode: prove**

Build the first genuinely scalable formal blueprint for a **tropical Satake correspondence for `GL_n`**, not as a cosmetic generalization of the `GL_2` or `GL_3` case, but as a new structural theorem: the spherical min-plus Hecke algebra of `GL_n` should be identified with the semiring of `S_n`-invariant tropical polynomials on the coweight lattice. The breakthrough is not merely “one more rank.” The breakthrough is to isolate the **rank-uniform mechanism** by which Weyl symmetry, dominance order, and min-plus convolution become the same object viewed from representation theory, tropical geometry, and combinatorics.

Your task is to produce a Lean 4 development that makes this rank-uniform perspective precise and usable.

## Core Vision

For `GL_n`, the classical Satake isomorphism identifies the spherical Hecke algebra with Weyl-invariant functions on the dual torus. The tropical version should replace:
- multiplication by tropical addition,
- addition by minimum,
- characters by piecewise-linear support functions,
- Weyl invariance by permutation symmetry of coordinates.

What must emerge is a theorem saying that **tropicalized double-coset convolution is exactly the min-plus algebra of symmetric tropical polynomial data**. This opens a field: tropical harmonic analysis on reductive groups, algorithmic representation theory via semiring methods, and new bridges to discrete optimization and statistical physics.

Application keywords: **tropical Langlands, Hecke algebra, min-plus convolution, Weyl group invariants, symmetric tropical polynomials, majorization, Schur-convexity, combinatorial representation theory, optimization, statistical mechanics**

---

## Exact Theorem Targets

You must prove at least 3 substantial theorems with nontrivial proofs. The following are the central targets.

### New definitions to introduce

You must define at least one genuinely new structure. Suggested core definitions:

1. `TropicalMonomial n`
   - exponent vector in `Fin n → ℤ`
   - coefficient in `ℤ` or `WithTop ℤ`
   - evaluation by tropical affine form

2. `IsSymmetricTropical n f`
   - invariance under the `Equiv.Perm (Fin n)` action

3. `MinPlusHeckeOp n`
   - a finitely supported or structurally constrained min-plus kernel on dominant coweights
   - convolution defined by tropical min over intermediate dominant weights

4. `TropicalSatakeData n`
   - a structure packaging a Hecke operator together with its associated symmetric tropical polynomial candidate

A plausible Lean-facing definition pattern:

```lean
def DominantCoweight (n : ℕ) := {v : Fin n → ℤ // Monotone fun i => v i}

def IsSymmetricTropical (n : ℕ) (f : (Fin n → ℤ) → ℤ) : Prop :=
  ∀ σ : Equiv.Perm (Fin n), ∀ x, f (x ∘ σ) = f x

structure TropicalMonomial (n : ℕ) where
  coeff : ℤ
  expo  : Fin n → ℤ

def TropicalMonomial.eval {n : ℕ} (m : TropicalMonomial n) (x : Fin n → ℤ) : ℤ :=
  m.coeff + ∑ i, m.expo i * x i

def TropicalPolynomial (n : ℕ) := Finset (TropicalMonomial n)

def TropicalPolynomial.eval {n : ℕ} (P : TropicalPolynomial n) (x : Fin n → ℤ) : ℤ :=
  P.inf' (by sorry) (fun m => m.eval x)
```

If `Finset.inf'` becomes technically awkward, define a nonempty tropical polynomial structure or work with finite families indexed by `Fin k`.

---

## Primary Breakthrough Theorem

### Theorem A: Tropical Satake invariance-extension theorem for `GL_n`

Generalize the existing `satake_extend_invariant` from `GL_3` to arbitrary rank.

**Mathematical statement.**  
Let `n ≥ 1`. Any function on dominant coweights extends canonically to an `S_n`-invariant tropical function on all of `ℤ^n`, by sorting coordinates into dominant order; this extension is well-defined and invariant under the Weyl group.

This is the first indispensable theorem: it converts the “positive chamber” description of Hecke data into a global symmetric tropical function.

### Suggested Lean 4 type signature

```lean
theorem satake_extend_invariant_fin
    {n : ℕ}
    (hn : 1 ≤ n)
    (f : DominantCoweight n → ℤ) :
    ∃ F : (Fin n → ℤ) → ℤ,
      (∀ x : DominantCoweight n, F x.1 = f x) ∧
      IsSymmetricTropical n F
```

A stronger uniqueness version would be even better:

```lean
theorem satake_extend_invariant_unique
    {n : ℕ}
    (hn : 1 ≤ n)
    (f : DominantCoweight n → ℤ) :
    ∃! F : (Fin n → ℤ) → ℤ,
      (∀ x : DominantCoweight n, F x.1 = f x) ∧
      IsSymmetricTropical n F ∧
      (∀ x, F x = f ⟨sortDesc x, by sorry⟩)
```

where `sortDesc` is your canonical dominant representative. If full sorting on `Fin n → ℤ` is too heavy, model vectors as `Vector ℤ n` or `Fin n → ℤ` plus a separately defined “dominant rearrangement.”

**Why this matters.**  
This theorem is the tropical analogue of extending class functions from a Weyl chamber to the full torus. It is the structural bridge between representation-theoretic data and tropical geometry.

---

## Algebraic Correspondence Theorem

### Theorem B: Weyl-invariant tropical polynomial realization

Show that finitely generated tropical Hecke data produces a symmetric tropical polynomial, and conversely every symmetric tropical polynomial determines chamber data.

**Mathematical statement.**  
For each `n`, tropical polynomials on `ℤ^n` that are invariant under coordinate permutations are equivalent to finite min-envelope data on dominant coweights closed under Weyl orbit symmetrization.

### Suggested Lean 4 type signature

```lean
def IsWeylInvariantPolynomial {n : ℕ} (P : TropicalPolynomial n) : Prop :=
  IsSymmetricTropical n (TropicalPolynomial.eval P)

theorem tropical_polynomial_of_hecke
    {n : ℕ}
    (H : MinPlusHeckeOp n) :
    ∃ P : TropicalPolynomial n,
      IsWeylInvariantPolynomial P ∧
      ∀ x : Fin n → ℤ, TropicalPolynomial.eval P x = H.toFun x

theorem hecke_of_tropical_polynomial
    {n : ℕ}
    (P : TropicalPolynomial n)
    (hP : IsWeylInvariantPolynomial P) :
    ∃ H : MinPlusHeckeOp n,
      ∀ x : Fin n → ℤ, H.toFun x = TropicalPolynomial.eval P x
```

If equivalence is formalizable, aim for:

```lean
theorem tropical_satake_bijection
    {n : ℕ} :
    Nonempty (MinPlusHeckeOp n ≃
      {P : TropicalPolynomial n // IsWeylInvariantPolynomial P})
```

If a literal `Equiv` is too ambitious because of representation choices, prove a pair of inverse constructions up to extensional equality.

**Why this matters.**  
This is the actual tropical Satake statement: not just invariance, but an algebraic dictionary. It turns abstract Hecke operators into explicit symmetric tropical objects, making them computable.

---

## Convolution/Min-Plus Compatibility Theorem

### Theorem C: Tropical convolution corresponds to tropical polynomial product

You need one theorem showing the algebra structures match.

**Mathematical statement.**  
Under the tropical Satake transform, min-plus Hecke convolution corresponds to tropical polynomial multiplication (i.e. addition of affine forms followed by minimum over summands).

### Suggested Lean 4 type signature

```lean
def heckeConv {n : ℕ} (H K : MinPlusHeckeOp n) : MinPlusHeckeOp n := by sorry
def tropicalMul {n : ℕ} (P Q : TropicalPolynomial n) : TropicalPolynomial n := by sorry
def satakeTransform {n : ℕ} : MinPlusHeckeOp n → TropicalPolynomial n := by sorry

theorem satake_transform_convolution
    {n : ℕ}
    (H K : MinPlusHeckeOp n) :
    TropicalPolynomial.eval (satakeTransform (heckeConv H K))
      = TropicalPolynomial.eval (tropicalMul (satakeTransform H) (satakeTransform K))
```

Because function equality is hard to read, extensional form is preferable:

```lean
theorem satake_transform_convolution_eval
    {n : ℕ}
    (H K : MinPlusHeckeOp n) (x : Fin n → ℤ) :
    TropicalPolynomial.eval (satakeTransform (heckeConv H K)) x
      =
    TropicalPolynomial.eval (tropicalMul (satakeTransform H) (satakeTransform K)) x
```

Use the catalog theorem `tropical_plus_distributes_over_min` as a key semiring identity in the proof.

**Why this matters.**  
Without compatibility with convolution, you have only a dictionary of sets. With it, you have a true tropical harmonic-analysis machine.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem connecting tropical Satake to a different domain. The strongest accessible bridge is **majorization / convexity / optimization**.

### Theorem D: Symmetric tropical functions are constant on majorization fibers or monotone on dominant order

A realistic formal target is monotonicity on dominant coweights for a class of positive tropical polynomials.

```lean
def DominanceOrder {n : ℕ} (x y : Fin n → ℤ) : Prop := by sorry

theorem symmetric_tropical_monotone_on_dominant
    {n : ℕ}
    (P : TropicalPolynomial n)
    (hP : IsWeylInvariantPolynomial P)
    (hconv : TropicallyConvex P) :
    ∀ {x y : Fin n → ℤ}, DominanceOrder x y →
      TropicalPolynomial.eval P x ≤ TropicalPolynomial.eval P y
```

If majorization is too difficult, prove a chamberwise version on sorted vectors. This theorem creates the bridge to:
- **combinatorics** via partitions and dominance order,
- **optimization** via Schur-convexity analogues,
- **statistical physics** via energy minimization under permutation symmetry.

**Why this matters.**  
It reveals tropical Satake objects as energy landscapes ordered by dominance, suggesting a new variational interpretation of representation-theoretic data.

---

## Falsifiable Conjecture with Computational Test

State at least one explicit conjecture and implement a test in `demo.py`.

### Conjecture: Orbit-generated basis conjecture
For each `n`, every Weyl-invariant tropical polynomial is the tropical linear combination of orbit-symmetrized tropical monomials associated to dominant exponent vectors.

Possible Lean declaration:

```lean
conjecture tropical_weyl_basis
    (n : ℕ) :
    ∀ P : TropicalPolynomial n,
      IsWeylInvariantPolynomial P →
      ∃ S : Finset (Fin n → ℤ),
        ∀ x, TropicalPolynomial.eval P x
          =
        sInf (Finset.image (fun a => ∑ i, a i * x i) S)
```

This may be too strong globally; that is fine. The point is that it is **falsifiable**.

### Computational test
In `demo.py`, for small `n` (say `n = 2,3,4`) and bounded coefficients/exponents:
1. generate random symmetric tropical polynomials,
2. attempt to recover them from orbit-symmetrized monomials,
3. search for counterexamples,
4. visualize chamberwise linear regions.

A negative result is scientifically valuable.

---

## Proof Strategy Architecture

You must not rely on trivial automation. Use induction, `rcases`, `by_contra`, `field_simp` where relevant, and multi-step `calc`.

### Strategy 1: Weyl chamber canonicalization via sorting
Most promising for Theorem A.

1. Define a canonical dominant rearrangement `sortDesc : (Fin n → ℤ) → DominantCoweight n`.
2. Prove that `sortDesc (x ∘ σ) = sortDesc x` for every permutation `σ`.
3. Define the extension `F x := f (sortDesc x)` and prove:
   - agreement on dominant vectors,
   - `S_n`-invariance,
   - uniqueness by canonicalization.

Why promising: it directly generalizes the existing `satake_extend_invariant` theorem for `GL_3` and isolates the Weyl-group mechanism in a rank-free way.

### Strategy 2: Orbit-infimum construction
Best for Theorem B.

1. Represent a Hecke operator by finitely many dominant coweight-affine forms.
2. Extend each form to its full Weyl orbit.
3. Take the tropical minimum over the orbit-expanded family and prove symmetry.

Why promising: this turns “invariant tropical polynomial” into a concrete finite orbit construction, avoiding abstract quotient machinery.

### Strategy 3: Semiring/algebra transport for convolution compatibility
Best for Theorem C.

1. Define `heckeConv` as min-plus convolution over admissible intermediate weights.
2. Define `tropicalMul` by pairwise addition of monomials.
3. Use `tropical_plus_distributes_over_min` to commute min and tropical addition.
4. Prove equality pointwise by a `calc` chain expanding both sides to the same finite infimum.

Why promising: the catalog already contains the exact distributivity identity you need. The challenge is organizing the finite combinatorics, not discovering a new algebraic law.

---

## Catalog Leverage

You must explicitly build on these verified results:

1. `satake_extend_invariant`
   - file: `FINAL/Tropical/TropicalSatakeGL3Algebra.lean`
   - use it as the rank-3 prototype and extract the essential pattern: extension from dominant chamber to Weyl-invariant function.

2. `tropical_plus_distributes_over_min`
   - files:
     - `FINAL/Tropical/FormulaDefinability.lean`
     - `FINAL/Tropical/TropicalTypeTheory.lean`
   - use this as the semiring identity underlying convolution/product compatibility.

Do not merely cite them. Rebuild the proof architecture so the `GL_3` theorem becomes the base case or sanity-check instance of your rank-`n` definitions.

---

## Required Theorem Count and Proof Depth

Your file must contain **at least 3 deep theorems**, and they should visibly use nontrivial tactics and reasoning patterns. A recommended trio is:

1. `satake_extend_invariant_fin`
2. `tropical_polynomial_of_hecke` or `tropical_satake_bijection`
3. `satake_transform_convolution_eval`
4. plus the cross-domain theorem `symmetric_tropical_monotone_on_dominant`

At least three of these should involve:
- induction on `n`, finite support size, or orbit size,
- `rcases` decomposition of orbit representatives / dominant vectors,
- `by_contra` for uniqueness or minimality arguments,
- multi-step `calc` proofs,
- nontrivial use of order/algebra lemmas.

---

## Deliverables

You must produce **all** of the following:

### 1. Lean development
A new file, e.g.
- `FINAL/Tropical/TropicalSatakeGLn.lean`

with:
- new definitions,
- at least 3 substantial theorems,
- minimal `sorry`,
- explicit comments explaining the mathematical architecture.

### 2. Verified algorithm / computational method
Implement a certified or at least theorem-backed computational method for:
- computing the dominant representative of a weight,
- constructing the Weyl-invariant tropical polynomial from finite Hecke data,
- evaluating the tropical Satake transform on sample inputs.

This is mandatory. Not just theorem statements.

### 3. `demo.py`
An interactive demonstration that:
- constructs small-rank examples (`n=2,3,4`),
- computes orbit-symmetrized tropical polynomials,
- compares convolution on Hecke data with tropical polynomial multiplication,
- tests the conjecture on random instances,
- prints or plots chamberwise values.

### 4. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the tropical Satake problem,
- your exact new definitions,
- the main theorems,
- why rank-uniformity is hard,
- how the proofs work,
- what new mathematics this opens.

Someone reading only this document must understand the discovery and why it matters.

### 5. `ARTICLE.md`
Write this in **Scientific American style**:
- vivid,
- concept-driven,
- broad-audience accessible,
- focused on the mathematics and its implications.

Taboo: do **not** focus on formal verification machinery. Focus on the ideas.

### 6. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**. Each direction must include:
- a sentence beginning exactly with **“The key insight is...”**
- a sentence beginning exactly with **“Why now?”**

At least one direction must bridge to a different domain, such as:
- discrete optimization,
- statistical mechanics,
- geometric complexity theory,
- tropical automorphic forms,
- quantum/combinatorial representation theory.

---

## Cross-Domain Expansion Ideas

You are strongly encouraged to make one of these bridges explicit:

1. **Optimization**
   - Tropical symmetric polynomials as permutation-invariant cost landscapes.
   - Hecke convolution as dynamic programming / shortest-path composition.

2. **Statistical mechanics**
   - Min-plus convolution as zero-temperature partition-function composition.
   - Weyl symmetry as indistinguishability of particle labels.

3. **Majorization theory**
   - Dominant coweights are partitions.
   - Tropical Satake functions may behave like Schur-convex energies.

4. **Combinatorial representation theory**
   - Orbit-symmetrized monomials resemble tropicalized characters.
   - Connect to partitions, Young diagrams, and weight polytopes.

A theorem connecting to one of these domains is mandatory.

---

## Standard of Ambition

Do not stop at “define something and prove it is invariant.” The scientific target is a **rank-uniform algebraic correspondence with computational content**. If you can only fully prove a finite-support or finitely generated version, do that cleanly and explicitly. A sharp partial theorem with a real mechanism is far better than vague maximal generality.

The ideal outcome is that a mathematician reading your work says:

> “This is the first credible formal framework for tropical Satake beyond tiny rank, and it unexpectedly connects Hecke theory to symmetric tropical optimization.”

Make that sentence true.

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

Research domain: Tropical
Research mode: prove
