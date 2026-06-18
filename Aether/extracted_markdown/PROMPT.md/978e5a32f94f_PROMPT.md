Soli Deo Gloria

## Assignment: Direction 3: Lorentzian Condition Numbers for Association Schemes (Grand Challenge)

**Mode:** prove

Build a new theory of **scheme-symmetric Lorentzian stability radii** that upgrades the two-eigenvalue phenomenon for uniform matroids into a general spectral principle for association schemes. The target is not a toy extension: it is a conceptual bridge between Lorentzian polynomials, Bose–Mesner algebras, coding theory, and quantum-style witness constructions.

You must prove genuinely new, non-trivial theorems, building explicitly on catalog results and minimizing `sorry`.

## Core Vision

The uniform matroid story suggests that Lorentzian stability is not an accident of elementary symmetric polynomials, but a **representation-theoretic spectral phenomenon**: when the coefficient support of a polynomial carries an association scheme structure, the relevant Hessian or leaf-Hessian operators should lie in the Bose–Mesner algebra and therefore diagonalize in the primitive idempotent basis. If true, the stability radius becomes a **condition number of the scheme itself**.

This would open an entirely new program:

- **Lorentzian algebraic combinatorics:** stability radii computed from eigenmatrices of schemes.
- **Coding-theoretic robustness:** Hamming/Johnson spectral data predicting Lorentzian perturbation thresholds.
- **Quantum-information analogy:** primitive idempotents acting as entanglement-witness-like instability certificates.
- **Algorithmic spectral certification:** a verified method for computing or bounding Lorentzian stability from finite-dimensional commutative algebras.

## Exact Research Targets

### New definitions you should introduce

You must define at least one genuinely new concept not already present in the catalog. Suggested core definitions:

1. **Scheme-symmetric leaf operator**  
   A linear operator on the quadratic leaf space associated to a polynomial whose coefficients are constant on classes of an association scheme.

2. **Lorentzian spectral gap of a scheme perturbation family**  
   The smallest positive generalized eigenvalue separating the distinguished positive direction from the orthogonal idempotent components.

3. **Scheme condition number**  
   A spectral ratio extracted from the first eigenmatrix / dual eigenmatrix that predicts the stability radius.

Suggested Lean-facing structures:
- a finite type of vertices `X`
- a partition of `X × X` into symmetric relations
- the associated adjacency matrices as endomorphisms
- a commutative family of self-adjoint operators on a finite free module

You do **not** need to formalize the full Delsarte theory if that is too heavy. It is acceptable to formalize a robust intermediate notion sufficient for Johnson/Hamming examples and then prove the spectral radius theorem there.

---

## Precise theorem statements to target

You should aim to formalize at least three deep theorems. The following are the right scale.

### Theorem 1: Simultaneous diagonalization in the scheme leaf algebra
**Mathematical statement.**  
Let `𝒜 = {A₀, …, A_d}` be a commutative symmetric association scheme on a finite set `X`. Let `L` be a finite-dimensional quadratic leaf space attached to a scheme-symmetric polynomial family `f_t`, and suppose each leaf Hessian operator `H_t : L → L` lies in the Bose–Mesner algebra image on `L`. Then there exists a common eigenbasis given by primitive idempotent components, and the spectrum of `H_t` is obtained by evaluating a scalar polynomial in the scheme eigenvalues.

This is the mechanism that turns Lorentzian stability into spectral algebra.

**Lean 4 target signature (schematic but precise):**
```lean
theorem simultaneousDiagonalization_schemeLeaf
  {ι : Type*} [Fintype ι] [DecidableEq ι]
  {R : Type*} [LinearOrderedField R]
  {V : Type*} [AddCommGroup V] [Module R V] [FiniteDimensional R V]
  (S : SchemeData ι R)
  (L : Type*) [AddCommGroup L] [Module R L] [FiniteDimensional R L]
  (ρ : BoseMesnerRep S L)
  (H : R →ₗ[R] Module.End R L)
  (hcomm : ∀ t s, Commute (H t) (H s))
  (hmem : ∀ t, H t ∈ boseMesnerSubalgebra S ρ) :
  ∃ (e : Basis (primitiveIdempotentIndex S) R L),
    ∀ t i, ∃ μ : R, (H t) (e i) = μ • (e i)
```

If the full statement is too ambitious for current infrastructure, prove a specialized finite-matrix version first:
```lean
theorem simultaneousDiagonalization_of_mem_boseMesner
  ...
```

### Theorem 2: Spectral formula for the Lorentzian stability radius
**Mathematical statement.**  
Let `f` be a scheme-symmetric Lorentzian polynomial family with one distinguished positive eigenspace and all remaining primitive idempotent components negative at the base point. Let `λ₀(t), …, λ_d(t)` be the eigenvalue branches of the leaf Hessian along the primitive idempotents. Then the stability radius equals the first parameter value where one nontrivial eigenvalue reaches zero:
\[
\rho(f)=\inf\{t>0:\exists j\ge1,\ \lambda_j(t)=0\}.
\]
Under affine dependence `λ_j(t)=a_j-t b_j` with `a_j,b_j>0`, one gets
\[
\rho(f)=\min_{j\ge1}\frac{a_j}{b_j}.
\]

This theorem is the real breakthrough: it turns Lorentzian stability into a finite spectral optimization problem.

**Lean 4 target signature:**
```lean
theorem lorentzianStabilityRadius_eq_iInf_eigenRatio
  {R : Type*} [LinearOrderedField R]
  (F : SchemeLorentzianFamily R)
  (haff : ∀ j, ∃ a b : R, 0 < a ∧ 0 < b ∧
    ∀ t, F.eigenvalue j t = a - t * b) :
  F.stabilityRadius =
    sInf {r : R | ∃ j, 0 < j ∧ r = (Classical.choose (haff j)).1 /
                              (Classical.choose (Classical.choose_spec (haff j))).1}
```

A cleaner finite-index version is acceptable:
```lean
theorem lorentzianStabilityRadius_eq_min_ratio
  ...
  : F.stabilityRadius = Finset.inf' F.nontrivialClasses ...
      (fun j => (F.posGap j) / (F.perturbWeight j))
```

This should explicitly build on:
- `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
  - `lorentzian_stability_radius_exists`

Explain exactly how: use existence of the radius from the catalog theorem, then identify that abstract radius with the minimum vanishing time of the diagonalized eigenvalue branches.

### Theorem 3: Johnson-scheme specialization recovering the uniform matroid gap
**Mathematical statement.**  
For the Johnson scheme `J(n,2)`, the general spectral formula specializes to the known uniform-matroid Lorentzian gap and reproduces value `1` in the normalized setting. This is the sanity check that certifies the new theory is the correct generalization.

**Lean 4 target signature:**
```lean
theorem johnson_J_n_2_radius_eq_one
  {R : Type*} [LinearOrderedField R]
  (n : ℕ) (hn : 4 ≤ n) :
  johnsonLorentzianRadius (R := R) n 2 = 1
```

This theorem must explicitly use:
- `Pythagorean/UniformMatroidLorentzian.lean`
  - `uniform_leaf_hessian_decomposition`

Explain exactly how: the catalog theorem gives the two-eigenvalue decomposition for the uniform case; identify it with the `J(n,2)` primitive-idempotent decomposition and show the general ratio formula collapses to the already-known gap.

### Theorem 4: Cross-domain theorem — Hamming schemes and coding-theoretic instability bounds
**Mathematical statement.**  
For a Hamming scheme `H(n,q)`, the Lorentzian stability radius of a scheme-symmetric perturbation is bounded below by a quantity determined by the Krawtchouk spectrum; equivalently, the dual distance distribution controls the first instability mode.

This is your mandatory cross-domain bridge: Lorentzian geometry meets coding theory.

**Lean 4 target signature:**
```lean
theorem hammingScheme_radius_lowerBound_by_krawtchouk
  {R : Type*} [LinearOrderedField R]
  (n q : ℕ) (hq : 2 ≤ q)
  (F : HammingSchemeLorentzianFamily R n q) :
  F.krawtchoukLowerBound ≤ F.stabilityRadius
```

If full Hamming machinery is too large, prove a finite-dimensional abstract version and instantiate it on a toy Hamming example.

---

## Refined central conjecture

Your original conjecture should be sharpened into a mathematically testable form.

### Spectral Ratio Conjecture for Association Schemes
Let `𝒜` be a commutative symmetric association scheme with primitive idempotents `E₀, …, E_d`, and let `f_t` be a one-parameter scheme-symmetric perturbation family whose leaf Hessian acts on the quadratic leaf space as
\[
H_t=\sum_{k=0}^d \theta_k(t) E_k.
\]
Assume:
1. `θ₀(t) > 0` on the relevant interval,
2. `θ_j(0) < 0` for all `j ≥ 1`,
3. each `θ_j(t)` is affine in `t`,
4. Lorentzianity is equivalent to preserving the one-positive-direction signature on the leaf space.

Then
\[
\rho(f)=\min_{j\ge1}\frac{|\theta_j(0)|}{|\theta'_j(0)|}.
\]
If `θ_j(t)` is computed from the first eigenmatrix `P` and perturbation coordinates `c_k`, then
\[
\rho(f)=\min_{j\ge1}\frac{\left|\sum_k a_k P_{jk}\right|}{\left|\sum_k c_k P_{jk}\right|}.
\]

This is a much stronger and cleaner formulation than the informal ratio involving `p_k(1)` and `p_k(j_min)`, because it makes clear what data are spectral, what is being minimized, and why primitive idempotents are the true instability modes.

---

## Proof architecture: 3 viable strategies

You must present and pursue at least 2–3 strategy paths, and identify which one is most promising.

### Strategy A: Bose–Mesner algebra → primitive idempotents → exact spectral radius
1. Define the relevant leaf space and prove the leaf Hessians lie in a commutative subalgebra generated by adjacency operators.
2. Use commutativity + symmetry/self-adjointness to simultaneously diagonalize the operators in primitive idempotent coordinates.
3. Express Lorentzianity as a signature condition and show instability occurs exactly when one nontrivial eigenvalue crosses zero.
4. Conclude the radius is the minimum eigen-ratio.

**Why this is most promising:** it directly generalizes the catalog’s two-eigenvalue uniform-matroid decomposition and gives the cleanest theorem with the strongest downstream algorithmic consequences.

### Strategy B: Representation-theoretic orbit decomposition
1. Model the coefficient support as an orbit space under a transitive automorphism group.
2. Decompose the leaf space into irreducible isotypic components.
3. Show the Hessian is scalar on each irreducible component by Schur-type reasoning in the commutative case.
4. Translate the resulting scalars into association-scheme eigenvalues.

**Why it matters:** conceptually deep and likely to expose connections to spherical designs and harmonic analysis, but heavier to formalize unless the representation theory already exists in the local environment.

### Strategy C: Matrix-analytic variational approach
1. Define the leaf Hessian matrix explicitly in a canonical basis.
2. Prove it is a polynomial in commuting adjacency matrices.
3. Use Rayleigh quotient / min-max style arguments to characterize the first instability threshold.
4. Recover exact formulas in Johnson/Hamming cases by explicit diagonalization.

**Why this is useful:** more computational and may be easier to instantiate for concrete schemes, especially if full primitive-idempotent infrastructure is cumbersome.

**Recommendation:** pursue Strategy A as the main line, with Strategy C as the fallback route for Johnson `J(n,2)` and `J(n,3)`.

---

## Required interaction with catalog theorems

You must explicitly use and cite the following catalog artifacts:

1. `Pythagorean/UniformMatroidLorentzian.lean`
   - `uniform_leaf_hessian_decomposition`

   **How to use it:** interpret this theorem as the rank-2 prototype of the primitive-idempotent decomposition. Your Johnson `J(n,2)` theorem should show that the catalog decomposition is exactly the first nontrivial instance of the general scheme framework.

2. `Catalog/Speculative/AutoResearch/LorentzianStability.lean`
   - `lorentzian_stability_radius_exists`

   **How to use it:** do not reprove existence abstractly from scratch. Use this theorem to obtain the radius, then prove your new contribution: in the scheme-symmetric setting, the abstract radius equals a spectral minimum / eigen-ratio formula.

If there are additional relevant final catalog files in the dynamic context, use them too, especially anything about finite-dimensional spectral theory, symmetric matrices, or quadratic forms.

---

## Concrete milestones

### Milestone 1: Abstract infrastructure
Create a Lean file introducing a structure such as:
```lean
structure SchemeLorentzianFamily (R : Type*) [LinearOrderedField R] where
  ι : Type*
  instFintype : Fintype ι
  instDecEq : DecidableEq ι
  leafSpace : Type*
  instAddCommGroup : AddCommGroup leafSpace
  instModule : Module R leafSpace
  instFiniteDimensional : FiniteDimensional R leafSpace
  classes : Finset ι
  eigProj : ι → Module.End R leafSpace
  h_orthogonal : ...
  h_complete : ...
  eigenvalue : ι → R → R
  leafHessian : R → Module.End R leafSpace
  h_decomp : ∀ t, leafHessian t = ∑ i, (eigenvalue i t) • eigProj i
  positiveClass : ι
  ...
```
This counts as a novel definition if done thoughtfully.

### Milestone 2: Radius-as-minimum-ratio theorem
Prove a general theorem identifying the radius with the first vanishing nontrivial eigenvalue.

### Milestone 3: Johnson `J(n,2)` recovery theorem
Show the theory reproduces the known gap `1`.

### Milestone 4: Johnson `J(n,3)` prediction theorem
Even if exact equality is difficult, prove a rigorous upper/lower bound and provide computational evidence in `demo.py`.

Suggested theorem:
```lean
theorem johnson_J_n_3_radius_bounds
  {R : Type*} [LinearOrderedField R]
  (n : ℕ) (hn : 6 ≤ n) :
  lowerBound_J_n_3 (R := R) n ≤ johnsonLorentzianRadius (R := R) n 3 ∧
  johnsonLorentzianRadius (R := R) n 3 ≤ upperBound_J_n_3 (R := R) n
```

### Milestone 5: Cross-domain theorem
Prove at least one theorem connecting to coding theory, spectral graph theory, or quantum information.

Possible quantum-information style theorem:
primitive idempotent perturbations give optimal instability witnesses, analogous to extremal entanglement witnesses in a commutative operator algebra.

---

## Deep proof requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, `rcases`, `by_contra`, `field_simp`,
   or multi-step `calc` reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your
   domain to a different mathematical domain:
   - association schemes + coding theory,
   - association schemes + spectral graph theory,
   - association schemes + quantum information,
   - association schemes + optimization / condition numbers.

5. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.

---

## Testable conjectures and computational predictions

### Conjecture A: Johnson exactness
For `J(n,3)`, the Lorentzian stability radius equals the minimum primitive-idempotent eigen-ratio predicted by the Johnson eigenmatrix.

**Computational test:**  
For `n = 6,7,8,9,10`, compute:
1. the predicted spectral ratio from the Johnson eigenmatrix,
2. an empirical instability threshold by binary search over perturbation size,
3. compare them numerically.

A single counterexample falsifies the conjecture.

### Conjecture B: Hamming monotonicity
For fixed alphabet size `q`, the normalized stability radius in `H(n,q)` is nonincreasing in `n`.

**Computational test:**  
Evaluate the spectral prediction for `n = 2,3,...,12` and search for monotonicity failure.

### Conjecture C: Primitive-idempotent witness optimality
Among all scheme-symmetric perturbations of fixed norm, the earliest instability is achieved by a perturbation supported on a single nontrivial primitive idempotent.

**Computational test:**  
Sample random perturbations in the Bose–Mesner algebra and compare their thresholds against pure-idempotent directions.

---

## Cross-domain connections you should emphasize

### 1. Coding theory
Hamming and Johnson schemes encode distance-regular combinatorics of codes. If your theorem succeeds, Lorentzian stability becomes computable from Krawtchouk / Eberlein spectra, suggesting a new invariant of codes and designs.

### 2. Spectral condition numbers
Your radius formula is a genuine condition number: it measures distance to loss of Lorentzian signature in a highly symmetric family. This links combinatorial Hodge theory with numerical linear algebra.

### 3. Quantum information
The primitive idempotents of a commutative scheme algebra play the role of extremal observables. The first eigenmode to cross zero is analogous to the first entanglement witness detecting non-positivity. This analogy may lead to a “commutative shadow” of quantum separability thresholds.

### 4. Spherical designs and harmonic analysis
Association schemes are finite analogues of harmonic decompositions. A successful theory hints at continuous analogues on symmetric spaces, where Lorentzian thresholds may be governed by zonal spherical functions.

---

## Application keywords

Use these explicitly in your prose and metadata:
- Lorentzian polynomials
- association schemes
- Bose–Mesner algebra
- primitive idempotents
- Johnson scheme
- Hamming scheme
- spectral gap
- condition number
- coding theory
- Krawtchouk polynomials
- Eberlein polynomials
- stability radius
- combinatorial Hodge theory
- spectral certification
- quantum witness analogy

---

## Deliverables (ALL mandatory)

You must produce all of the following:

1. **Lean development** with the new definitions and at least 3 substantial theorems, using deep proof tactics and minimizing `sorry`.

2. **A verified algorithm or computational method** that computes or bounds the spectral Lorentzian stability radius from finite scheme data. This must be more than a theorem statement: implement a concrete procedure.

3. **`demo.py`** that interactively demonstrates:
   - the `J(n,2)` recovery of radius `1`,
   - the `J(n,3)` predicted spectral ratio,
   - at least one Hamming-scheme experiment,
   - a binary-search comparison between predicted and empirical instability thresholds.

4. **`RESEARCH_PAPER.md`** as a standalone scientific paper. Someone reading only this paper must understand:
   - what was proved,
   - why it is a breakthrough,
   - what examples were computed,
   - what conjectures remain,
   - what future work is now enabled.

5. **`ARTICLE.md`** in Scientific American style. It must be engaging and accessible, and must explain the mathematical ideas and significance.  
   **TABOO:** do **not** focus on formal verification or machine verification. Focus on the science.

6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.  
   Each direction must include:
   - a sentence beginning **“The key insight is...”**
   - a sentence beginning **“Why now?”**
   At least one direction must bridge to a different domain.

---

## Standard of success

Success is **not** “some association-scheme-flavored lemmas.”  
Success is:

- a new spectral formalism for Lorentzian stability under scheme symmetry,
- a theorem identifying the radius with an eigen-ratio minimum in a nontrivial class,
- recovery of the uniform-matroid case as a special instance,
- at least one cross-domain theorem to coding theory or quantum-style witnesses,
- a working computational pipeline that produces falsifiable predictions.

This is the right level of ambition: if completed, it would found a new subprogram at the interface of algebraic combinatorics and Lorentzian geometry.

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
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
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
