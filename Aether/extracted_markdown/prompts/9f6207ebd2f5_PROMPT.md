Soli Deo Gloria

## Assignment: Direction 3: Multivariate k-Fold Log-Concavity and M-Convexity

Prove genuinely new, non-trivial theorems that open a new interface between higher-order log-concavity, discrete convex analysis, and Lorentzian geometry. Build directly on the catalog theorems in:

- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean`
- `Catalog/Pythagorean/HigherOrderLogConcavity.lean`

Minimize sorry. Do not settle for a definition-only file: the goal is a new multivariate theory with structural theorems, an algorithmic test, and a falsifiable conjectural frontier.

---

## Core Vision

The univariate hierarchy of k-fold log-concavity is not an isolated phenomenon. It should be the one-dimensional shadow of a multivariate depth hierarchy governed by **directional ratio operators**, whose fixed-point geometry is controlled by **M-convex support exchange** and whose homogeneous polynomial avatar is **recursive Lorentzianity**.

You should create the first formal blueprint for this theory:

- a multivariate notion of iterated directional log-concavity for functions on `ℤ^n`,
- a support-level theorem showing that positive multivariate ultra/log-concavity forces exchange structure,
- a polynomial specialization linking this hierarchy to recursive Lorentzian conditions,
- and a verified computational procedure testing the exchange/log-concavity interface on finite supports.

If successful, this opens a field: **higher-order discrete convexity**.

---

## Precise Mathematical Program

### New definitions to introduce

You must define at least one genuinely new structure/concept not already in the catalog. Recommended core definitions:

1. **Directional ratio operator** for lattice functions:
   \[
   R_i f(x) := \frac{f(x+e_i)}{f(x)}
   \]
   on a domain where both values are positive.

2. **Directional log-concavity in direction `i`**:
   \[
   R_i f(x+e_i) \le R_i f(x)
   \]
   equivalently
   \[
   f(x+2e_i)\,f(x)\le f(x+e_i)^2.
   \]

3. **Mixed directional log-concavity / exchange-type inequality**:
   for distinct `i,j`,
   \[
   f(x+e_i+e_j)\,f(x)\le f(x+e_i)\,f(x+e_j).
   \]
   This is the multivariate TP\(_2\)/discrete Hessian shadow and is the correct bridge to Lorentzian and valuated matroid phenomena.

4. **k-fold directional log-concavity**:
   recursively require the directional ratio transforms to satisfy the previous-level condition in every coordinate direction where defined.

5. **Support-level exchange witness**:
   a finite-support predicate saying that whenever `x,y` lie in support and `x_i > y_i`, there exists `j` with `x_j < y_j` and both exchanged lattice points remain in support. This should be aligned carefully with `SupportSatisfiesExchange`.

You may package these into a structure such as:

```lean
structure IsDirectionalLogConcave
    {n : ℕ} (f : (Fin n → ℤ) → ℝ) : Prop where
  pos : ∀ x, 0 < f x
  axis_logconcave :
    ∀ (i : Fin n) (x : Fin n → ℤ),
      f (x + single i 2) * f x ≤ (f (x + single i 1)) ^ 2
  mixed_logconcave :
    ∀ (i j : Fin n) (hij : i ≠ j) (x : Fin n → ℤ),
      f (x + single i 1 + single j 1) * f x ≤
        f (x + single i 1) * f (x + single j 1)
```

or a more support-aware / finite-domain variant if positivity on all `ℤ^n` is too rigid.

---

## Target Theorems

You must prove at least 3 substantial theorems. The following are the recommended flagship statements.

### Theorem 1: One-dimensional recovery theorem
Show that your multivariate definition restricts to the catalog’s univariate `KFoldLogConcave` / `RatioSeq` framework when `n = 1`.

#### Mathematical statement
For `f : ℤ → ℝ`, define `F : (Fin 1 → ℤ) → ℝ` by `F x = f (x 0)`. Then directional k-fold log-concavity of `F` is equivalent to the univariate k-fold log-concavity of the induced sequence, after domain alignment.

#### Lean target sketch
```lean
theorem directionalLogConcave_fin1_iff_univariate
    (f : ℤ → ℝ) :
    MultivariateKFoldLogConcave 1
      (fun x : Fin 1 → ℤ => f (x 0))
    ↔
    UnivariateKFoldLogConcave f
```

This theorem matters because it certifies that your new theory is not ad hoc: it is the true multivariate extension of the existing hierarchy.

---

### Theorem 2: Exchange inequality from mixed directional log-concavity
This is the first real breakthrough target.

#### Mathematical statement
Let `f : ℤ^n → ℝ≥0` have finite support and satisfy positivity on support and the mixed directional log-concavity inequalities. Then the support of `f` satisfies a two-step exchange closure, and under a natural nondegeneracy hypothesis this implies `SupportSatisfiesExchange`.

A precise theorem you can likely formalize:

> If `f` has finite support and for all `x,i,j` one has  
> \[
> f(x+e_i+e_j)f(x)\le f(x+e_i)f(x+e_j),
> \]
> then the support of `f` is discretely midpoint-convex along coordinate rectangles:
> whenever `x, x+e_i+e_j ∈ supp(f)`, also `x+e_i ∈ supp(f)` and `x+e_j ∈ supp(f)`.

From this, derive an exchange theorem for supports lying on a fixed total-degree slice.

#### Lean target sketch
```lean
theorem support_closed_under_coordinate_rectangle
    {n : ℕ}
    (f : (Fin n → ℤ) → ℝ)
    (hfin : Set.Finite {x | f x ≠ 0})
    (hmixed :
      ∀ (i j : Fin n) (hij : i ≠ j) (x : Fin n → ℤ),
        f (x + single i 1 + single j 1) * f x ≤
          f (x + single i 1) * f (x + single j 1)) :
    ∀ (i j : Fin n) (hij : i ≠ j) (x : Fin n → ℤ),
      f x ≠ 0 →
      f (x + single i 1 + single j 1) ≠ 0 →
      f (x + single i 1) ≠ 0 ∧ f (x + single j 1) ≠ 0
```

Then a stronger target:

```lean
theorem supportSatisfiesExchange_of_mixedDirectionalLogConcave
    {n d : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (hpos : ∀ m ∈ f.support, 0 < f.coeff m)
    (hmixed : MixedDirectionalLogConcaveCoeffs f) :
    SupportSatisfiesExchange f.support
```

This theorem is revolutionary because it upgrades coefficient inequalities into a **combinatorial matroidal support law**. That is exactly the kind of structural bridge that changes a subject.

---

### Theorem 3: Recursive Lorentzian compatibility
You should prove a compatibility theorem between your directional hierarchy and `IsRecursivelyLorentzian`.

#### Mathematical statement
For homogeneous polynomials with positive coefficients, recursive Lorentzianity implies first-order mixed directional log-concavity of the coefficient function on each degree slice. Ideally, prove a converse under support exchange + positivity + local Hessian inequalities.

A realistic forward theorem:

```lean
theorem recursivelyLorentzian_implies_mixedDirectionalLogConcave
    {n d : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (hlor : IsRecursivelyLorentzian f) :
    MixedDirectionalLogConcaveCoeffs f
```

A stronger equivalence theorem, if feasible:

```lean
theorem recursivelyLorentzian_iff_directionalKFold
    {n d k : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (hpos : ∀ m ∈ f.support, 0 < f.coeff m) :
    IsRecursivelyLorentzian f ↔
    CoeffFunctionIsDirectionalKFoldLogConcave k f
```

Even proving the forward implication with a nontrivial converse under extra hypotheses would already be important. This creates the first formal bridge between **higher-order ratio dynamics** and **Lorentzian algebraic geometry**.

---

### Theorem 4: Degree-slice M-convexity from coefficient inequalities
On a fixed degree slice, support exchange is the finite combinatorial shadow of M-convexity. You should make this explicit.

#### Lean target sketch
```lean
theorem homogeneous_support_mconvex_of_directional_conditions
    {n d : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (hhom : f.IsHomogeneousOfDegree d)
    (hpos : ∀ m ∈ f.support, 0 < f.coeff m)
    (hdir : MixedDirectionalLogConcaveCoeffs f) :
    MConvexOnDegreeSlice d f.support
```

If `MConvexOnDegreeSlice` does not exist, define it. This fulfills the “novel definitions” requirement and creates a reusable concept for future work in valuated matroids and discrete optimization.

---

## Lean 4 Type Signature Guidance

Use realistic formal types. You do not need to force the final names below, but your theorem statements should be this precise.

### For lattice functions
```lean
def LatticeFun (n : ℕ) := (Fin n → ℤ) → ℝ

def step (i : Fin n) (k : ℤ) : (Fin n → ℤ) := Pi.single i k

def directionalRatio {n : ℕ} (f : LatticeFun n) (i : Fin n) (x : Fin n → ℤ) : ℝ :=
  f (x + step i 1) / f x

def DirectionallyLogConcave {n : ℕ} (f : LatticeFun n) : Prop :=
  (∀ i x, f (x + step i 2) * f x ≤ (f (x + step i 1))^2) ∧
  (∀ i j, i ≠ j → ∀ x,
    f (x + step i 1 + step j 1) * f x ≤
      f (x + step i 1) * f (x + step j 1))

def KFoldDirectionalLogConcave : ℕ → LatticeFun n → Prop
  | 0, f => True
  | k+1, f =>
      DirectionallyLogConcave f ∧
      ∀ i, KFoldDirectionalLogConcave k (fun x => directionalRatio f i x)
```

### For polynomial coefficients
```lean
def coeffFun {n : ℕ} (f : MvPolynomial (Fin n) ℝ) : LatticeFun n :=
  fun x =>
    if hx : ∀ i, 0 ≤ x i
    then
      let m : Fin n →₀ ℕ := ...
      f.coeff m
    else 0
```

You may instead work directly with `Fin n →₀ ℕ` to avoid coercion pain. In fact, this is likely the cleaner route.

### Cleaner finitely-supported version
```lean
def AddMonoidFun (n : ℕ) := (Fin n →₀ ℕ) → ℝ

def bump (i : Fin n) (k : ℕ) : Fin n →₀ ℕ := Finsupp.single i k

def CoeffDirectionalLogConcave {n : ℕ} (f : (Fin n →₀ ℕ) → ℝ) : Prop :=
  (∀ i m, f (m + bump i 2) * f m ≤ (f (m + bump i 1))^2) ∧
  (∀ i j, i ≠ j → ∀ m,
    f (m + bump i 1 + bump j 1) * f m ≤
      f (m + bump i 1) * f (m + bump j 1))
```

This version is especially promising because `MvPolynomial.coeff` already lives naturally on finitely-supported exponent vectors.

---

## Proof Strategy Architecture

You must include at least 2–3 serious proof paths and choose among them intelligently.

### Strategy A: Support extraction from multiplicative inequalities
**Most promising for early theorems.**

1. Work with coefficient/support functions on `Fin n →₀ ℕ`.
2. Prove rectangle-closure lemmas: if `a*b ≤ c*d` and `a,d > 0`, then `c,d` nonzero constraints force support propagation.
3. Use homogeneous degree slicing to convert rectangle closure into the exchange property.

Why this is promising:
- It avoids analytic Hessian machinery.
- It interfaces directly with `SupportSatisfiesExchange`.
- It should formalize cleanly with `rcases`, `by_contra`, and support arithmetic on `Finsupp`.

Expected tactics:
- `rcases` on support membership hypotheses,
- `by_contra` to show vanishing intermediate coefficients contradicts positivity,
- multi-step `calc` chains for inequality transport,
- induction on `∑ i, |x i - y i|` for exchange derivations.

---

### Strategy B: Derivative/Hessian route through Lorentzian polynomials
**Most conceptually powerful for the recursive Lorentzian theorem.**

1. Translate coefficient inequalities into local statements about first and second partial derivatives.
2. Use catalog Lorentzian results to obtain Hessian sign conditions or strong log-concavity on derivative slices.
3. Push those inequalities back to coefficients of homogeneous polynomials.

Why this is promising:
- It is the mathematically deepest route.
- It aligns your new hierarchy with the actual geometry of Lorentzian polynomials.
- It could yield a converse theorem under positivity assumptions.

Risks:
- May require substantial coefficient-derivative bookkeeping in `MvPolynomial`.
- Could be heavy unless the catalog already exposes the right lemmas.

Use this route especially for:
`recursivelyLorentzian_implies_mixedDirectionalLogConcave`.

---

### Strategy C: Induction on k for the new hierarchy
**Best for the “k-fold” layer and univariate compatibility.**

1. Define the recursive transform carefully so positivity is preserved on the intended domain.
2. Prove base case and monotonicity lemmas for ratio transforms.
3. Induct on `k`, reducing multivariate statements to transformed functions.

Why this is promising:
- It directly mirrors `HigherOrderLogConcavity.lean`.
- It lets you port proof patterns from the univariate file.
- It gives a scalable formal architecture even if the deepest equivalence remains conjectural.

Use this route for:
`directionalLogConcave_fin1_iff_univariate`
and any theorem of the form “k+1-fold implies k-fold.”

---

## Cross-Domain Connections You Must Exploit

At least one theorem must connect this domain to a genuinely different area.

### Option 1: Matroid theory / combinatorial optimization
Support exchange is the combinatorial heart of matroids and M-convexity. Show that your coefficient inequalities imply a feasible-exchange property used in discrete optimization. This is the most natural and likely the strongest connection.

### Option 2: Statistical physics
Interpret `f(m)` as a discrete partition function over occupation vectors. Then mixed directional log-concavity expresses a **negative dependence / diminishing returns** principle. Prove a theorem or formulate a conjecture linking your inequalities to stability of particle allocation models.

Example formal target:
a finite-support partition function with directional log-concavity has exchange-closed support, meaning admissible occupancy states form an M-convex energy landscape.

### Option 3: Optimal transport / entropy on discrete spaces
Directional ratios are local chemical potentials. k-fold directional log-concavity suggests a hierarchy of curvature constraints on lattice measures. Even if full transport theory is too far, articulate this connection in `FUTURE_DIRECTIONS.md`.

### Option 4: Tropical geometry
Take logarithms of positive coefficients: the inequalities become submodularity-type conditions on `-log f`. This suggests that “k-fold M-convexity” is a tropical convexity hierarchy. If you can prove a lemma of the form
\[
g = -\log f \implies g(x+e_i)+g(x+e_j)\le g(x)+g(x+e_i+e_j),
\]
you create a clean bridge to tropical/discrete convex analysis.

This is an excellent cross-domain theorem candidate.

---

## Conjecture with Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test that could disprove it.

### Recommended conjecture
**Conjecture (Directional Lorentzian Equivalence).**  
Let `f : MvPolynomial (Fin n) ℝ` be homogeneous with strictly positive coefficients on support. Then:
\[
\texttt{IsRecursivelyLorentzian } f
\quad\Longleftrightarrow\quad
\texttt{CoeffFunctionIsKFoldDirectionalLogConcave } k\, f
\]
for all `k ≤ degree f`, together with `SupportSatisfiesExchange f.support`.

This is strong, falsifiable, and meaningful.

### Testable prediction
For all homogeneous polynomials in `n ≤ 4`, degree `d ≤ 5`, with integer coefficients in a bounded box:
- if recursive Lorentzianity holds, then the coefficient support passes your exchange checker and all mixed directional inequalities;
- any counterexample will first appear on a sparse support violating a two-step rectangle closure.

Your `demo.py` should:
1. generate random homogeneous supports/coefficient tables,
2. test directional inequalities,
3. test exchange,
4. compare against any available Lorentzian recognizer or a surrogate criterion.

A single explicit counterexample would refute the conjecture; absence across broad finite search strengthens it.

---

## Mandatory Deliverables

You must produce **all** of the following.

### 1. Lean file with deep theorems
Requirements:
- At least 3 substantial theorems.
- Proofs must use nontrivial tactics such as `induction`, `rcases`, `by_contra`, `field_simp`, or multi-step `calc`.
- No trivial enumeration proofs unless the theorem itself is profound.
- Introduce at least one new definition not already in the catalog.

### 2. Verified algorithm / computational method
Implement a certified procedure that checks, on a finite support:
- directional axis log-concavity,
- mixed directional log-concavity,
- rectangle closure / exchange witnesses.

This should not just compute booleans; prove soundness theorems like:
```lean
theorem checkMixedDirectionalLogConcave_sound :
  checkMixedDirectionalLogConcave data = true →
  MixedDirectionalLogConcave data.fun
```

and similarly for support exchange on the represented finite set.

### 3. `demo.py`
Interactive demonstration showing:
- random or hand-crafted coefficient tables,
- whether directional inequalities hold,
- whether support satisfies exchange,
- examples from matroids / partition functions / homogeneous polynomials,
- a search mode for conjecture testing.

### 4. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the new definitions,
- the main theorems,
- why this is a breakthrough,
- examples and counterexamples,
- the conjectural landscape,
- what comes next.

Someone reading only this paper must understand the mathematics and significance without seeing code.

### 5. `ARTICLE.md`
Write in Scientific American style. Explain the discovery as a new theory of multivariate shape, dependence, and exchange in discrete systems. Do **not** focus on formal verification machinery. Focus on the ideas.

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**
At least one direction must bridge to a different domain, such as statistical physics, tropical geometry, or optimization.

---

## Concrete Theorem Candidates to Formalize

Here is a sharpened list. Proving even 3 of these would constitute a serious contribution.

1. **Fin-1 equivalence theorem**
```lean
theorem kfoldDirectional_fin1_equiv_kfoldUnivariate
    (k : ℕ) (f : ℤ → ℝ) :
    KFoldDirectionalLogConcave k (fun x : Fin 1 → ℤ => f (x 0))
      ↔
    KFoldLogConcaveLike k f
```

2. **Rectangle support closure**
```lean
theorem support_rectangle_closure
    {n : ℕ} {f : (Fin n →₀ ℕ) → ℝ}
    (hpos : ∀ m, 0 ≤ f m)
    (hmixed :
      ∀ (i j : Fin n) (hij : i ≠ j) (m : Fin n →₀ ℕ),
        f (m + Finsupp.single i 1 + Finsupp.single j 1) * f m ≤
        f (m + Finsupp.single i 1) * f (m + Finsupp.single j 1)) :
    ∀ (i j : Fin n) (hij : i ≠ j) (m : Fin n →₀ ℕ),
      f m ≠ 0 →
      f (m + Finsupp.single i 1 + Finsupp.single j 1) ≠ 0 →
      f (m + Finsupp.single i 1) ≠ 0 ∧
      f (m + Finsupp.single j 1) ≠ 0
```

3. **Exchange from rectangle closure on a homogeneous slice**
```lean
theorem support_exchange_of_homogeneous_rectangle_closure
    {n d : ℕ} {s : Finset (Fin n →₀ ℕ)}
    (hdeg : ∀ m ∈ s, m.sum (fun _ a => a) = d)
    (hrect : RectangleClosed s) :
    SupportSatisfiesExchange s
```

4. **Recursive Lorentzian ⇒ mixed coefficient inequalities**
```lean
theorem recursivelyLorentzian_implies_coeff_mixed_logconcave
    {n : ℕ} {f : MvPolynomial (Fin n) ℝ} :
    IsRecursivelyLorentzian f →
    MixedDirectionalLogConcaveCoeffs f
```

5. **Tropical/submodular bridge**
Let `g(m) = -Real.log (f m)` on positive support. Prove:
```lean
theorem negLog_submodular_of_mixedDirectionalLogConcave
    {n : ℕ} {f : (Fin n →₀ ℕ) → ℝ}
    (hpos : ∀ m, 0 < f m)
    (hmixed : CoeffDirectionalLogConcave f) :
    ∀ (i j : Fin n) (hij : i ≠ j) (m : Fin n →₀ ℕ),
      g (m + Finsupp.single i 1) + g (m + Finsupp.single j 1) ≤
      g m + g (m + Finsupp.single i 1 + Finsupp.single j 1)
```

This theorem is especially valuable because it links your theory to tropical geometry and discrete convex analysis in a crisp inequality form.

---

## Implementation Advice

- Prefer exponent vectors `Fin n →₀ ℕ` over raw `ℤ^n` when working with polynomial coefficients.
- Isolate lemmas about `Finsupp.single`, addition, and total degree early.
- If `SupportSatisfiesExchange` is stated for a specific support representation, build adapter lemmas immediately.
- Use finite-support positivity assumptions carefully; support propagation arguments become much cleaner over `ℝ≥0` or with explicit `0 ≤ f m`.
- Separate:
  1. function-level inequalities,
  2. support-level closure properties,
  3. polynomial-level consequences.

This modularity will make the file robust and extensible.

---

## Why This Would Be a Breakthrough

If you succeed, you will have created the first formalized theory in which:

- higher-order log-concavity is no longer one-dimensional,
- Lorentzian geometry is connected to recursive ratio dynamics,
- M-convexity emerges from coefficient inequalities rather than being imposed axiomatically,
- and tropical/discrete convex structure appears as the logarithmic shadow of Lorentzian positivity.

This would open a new research program across:
- combinatorial Hodge theory,
- matroid theory,
- discrete optimization,
- negative dependence in probability,
- partition functions in statistical physics,
- and tropical convexity.

It is not an incremental extension. It is a candidate unification.

---

## Application Keywords

higher-order log-concavity; M-convexity; discrete convex analysis; Lorentzian polynomials; support exchange; valuated matroids; negative dependence; partition functions; tropical geometry; submodularity; combinatorial Hodge theory; homogeneous polynomials; coefficient inequalities; lattice functions; optimal transport on discrete spaces

---

## Final Charge

Do not merely define “multivariate k-fold log-concavity.” Force it to do mathematical work.

At minimum, I want:
1. a rigorous new definition,
2. a nontrivial recovery of the univariate theory,
3. a theorem deriving exchange structure from coefficient inequalities,
4. a bridge to recursive Lorentzianity or tropical submodularity,
5. a certified finite checker and computational exploration,
6. and a bold conjecture that could be falsified by search.

Build a theory that makes it impossible to think about higher-order log-concavity as only a theory of sequences.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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
