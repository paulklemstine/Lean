## Assignment: Langlands Program: Functoriality

**Mode:** `prove`

You are not being asked for a toy model of Langlands. You are being asked to carve out a formally precise, nontrivial **representation-theoretic shadow of functoriality** that can actually be certified in Lean 4 today, while being mathematically rich enough to open a path toward genuine automorphic transfer. The right move is to formalize a **local/combinatorial avatar of symmetric power functoriality for GL(2)** and prove exact transfer laws for Euler factors, Satake parameters, and spectral growth data.

The breakthrough is not “formalize some definitions about automorphic forms.” The breakthrough is:

> **Build a verified functorial transfer machine for unramified GL(2) data, prove that symmetric-square and symmetric-cube lifts preserve the correct Euler-factor structure, and connect this transfer to spectral iteration bounds / complexity growth as a cross-domain manifestation of functoriality.**

This creates a certified foundation from which genuine automorphic and motivic functoriality can later be layered.

---

## Core Vision

The mathematically serious tractable target is the following paradigm:

- Model an **unramified local GL(2) parameter** by a pair of Satake roots `(α, β)` in a commutative semiring/field.
- Define the **standard local Euler factor**
  \[
  L_p(s,\pi)=\frac{1}{(1-\alpha X)(1-\beta X)}
  \quad\text{with } X=p^{-s} \text{ formalized as an indeterminate.}
  \]
- Define the **symmetric square transfer**
  \[
  \mathrm{Sym}^2(\alpha,\beta)=(\alpha^2,\alpha\beta,\beta^2),
  \]
  and the **symmetric cube transfer**
  \[
  \mathrm{Sym}^3(\alpha,\beta)=(\alpha^3,\alpha^2\beta,\alpha\beta^2,\beta^3).
  \]
- Prove exact identities of local Euler factors, compatibility under twisting/scaling, and composition laws.
- Then go beyond the obvious algebra: define a **functorial complexity/spectral invariant** and prove that transfer amplifies degree/spectral mass in a controlled way, connecting Langlands-style transfer to existing catalog theorems on spectral transfer and algebraic complexity.

This is the right level of ambition: precise enough for Lean, deep enough to matter.

---

## Precise Theorem Targets

You must prove **at least 3 substantial theorems**, and they must not collapse to trivial polynomial normalization. Use induction, `rcases`, `by_contra`, `field_simp`, and multi-step `calc` chains.

### New Definitions (MANDATORY)

Define at least one genuinely new structure, for example:

```lean
structure LocalGL2Parameter (R : Type _) [CommSemiring R] where
  alpha : R
  beta  : R

structure LocalGLnParameter (R : Type _) [CommSemiring R] where
  roots : List R
  nonempty : roots ≠ []
```

or, better, a more canonical finite-indexed version:

```lean
structure LocalGLnParameter (R : Type _) [CommSemiring R] (n : ℕ) where
  root : Fin n → R
```

Then define:
- `stdEulerFactor : LocalGLnParameter R n → Polynomial R`
- `symmSq : LocalGL2Parameter R → LocalGLnParameter R 3`
- `symmCube : LocalGL2Parameter R → LocalGLnParameter R 4`
- optionally `centralCharacter : LocalGL2Parameter R → R := α * β`
- optionally `tempered` / `unitary_like` / `weightBalanced` predicates as algebraic proxies.

A strong formal target is:

```lean
def LocalGL2Parameter.stdEulerFactor
  {R : Type _} [CommSemiring R] (π : LocalGL2Parameter R) : Polynomial R :=
  (Polynomial.X - Polynomial.C π.alpha) * (Polynomial.X - Polynomial.C π.beta)

def symmSq
  {R : Type _} [CommSemiring R] (π : LocalGL2Parameter R) : LocalGLnParameter R 3 := ...

def symmCube
  {R : Type _} [CommSemiring R] (π : LocalGL2Parameter R) : LocalGLnParameter R 4 := ...
```

You may also prefer the reciprocal Euler factor convention:
\[
\prod_i (1 - a_i X),
\]
which is often easier in Lean.

---

## Exact Theorem Statements with Lean 4 Signatures

### Theorem 1: Symmetric-square Euler factor identity
This is the local unramified shadow of the Gelbart–Jacquet lift.

Mathematical statement:
For any commutative semiring/field and local GL(2) parameter `π=(α,β)`, the Euler factor of the symmetric-square transfer is exactly
\[
(1-\alpha^2 X)(1-\alpha\beta X)(1-\beta^2 X).
\]

Lean target:
```lean
theorem stdEulerFactor_symmSq
  {R : Type _} [CommSemiring R]
  (π : LocalGL2Parameter R) :
  stdEulerFactor (symmSq π)
    = (1 - Polynomial.C (π.alpha ^ 2) * Polynomial.X) *
      (1 - Polynomial.C (π.alpha * π.beta) * Polynomial.X) *
      (1 - Polynomial.C (π.beta ^ 2) * Polynomial.X) := by
  ...
```

If you instead define Euler factors as products over roots:
```lean
theorem eulerFactor_symmSq_as_prod
  {R : Type _} [CommSemiring R]
  (π : LocalGL2Parameter R) :
  eulerFactor (symmSq π)
    = ∏ i : Fin 3, (1 - Polynomial.C ((symmSq π).root i) * Polynomial.X) := by
  ...
```

**Why this matters:** this is a rigorously verified local functorial transfer law, not just a definition chase. It creates the reusable formal interface for all symmetric-power transfers.

---

### Theorem 2: Symmetric-cube factorization and composition law
This is the next nontrivial lift and a genuine test that your definitions are coherent.

Mathematical statement:
For `π=(α,β)`,
\[
L_X(\mathrm{Sym}^3\pi)^{-1}
= (1-\alpha^3X)(1-\alpha^2\beta X)(1-\alpha\beta^2 X)(1-\beta^3X).
\]
Moreover, twisting by a scalar `χ` commutes with symmetric powers in the expected degree:
\[
\mathrm{Sym}^m(\chi\cdot\pi)=\chi^m \cdot \mathrm{Sym}^m(\pi)
\]
at the level of roots.

Lean target:
```lean
theorem stdEulerFactor_symmCube
  {R : Type _} [CommSemiring R]
  (π : LocalGL2Parameter R) :
  stdEulerFactor (symmCube π)
    = (1 - Polynomial.C (π.alpha ^ 3) * Polynomial.X) *
      (1 - Polynomial.C (π.alpha ^ 2 * π.beta) * Polynomial.X) *
      (1 - Polynomial.C (π.alpha * π.beta ^ 2) * Polynomial.X) *
      (1 - Polynomial.C (π.beta ^ 3) * Polynomial.X) := by
  ...
```

and a twisting theorem:
```lean
def twist
  {R : Type _} [CommSemiring R] (χ : R) (π : LocalGL2Parameter R) : LocalGL2Parameter R :=
{ alpha := χ * π.alpha, beta := χ * π.beta }

theorem symmSq_twist
  {R : Type _} [CommSemiring R]
  (χ : R) (π : LocalGL2Parameter R) :
  symmSq (twist χ π) = twistGL3 (χ ^ 2) (symmSq π) := by
  ...
```

**Why this matters:** compatibility with twisting is one of the basic sanity laws of functoriality. Formalizing it gives a genuine categorical flavor to the transfer.

---

### Theorem 3: Discriminant/control theorem detecting reducibility or endoscopic collapse
You need at least one theorem with actual logical depth, not merely expansion. Define a discriminant-like invariant
\[
\Delta(\pi)=(\alpha-\beta)^2
\]
over a commutative ring/field and prove that if `Δ = 0`, then the symmetric-square roots have multiplicities / degeneracies forcing a reducibility phenomenon in the local factor.

A precise tractable version:

```lean
def discr
  {R : Type _} [CommRing R] (π : LocalGL2Parameter R) : R :=
  (π.alpha - π.beta)^2

theorem discr_eq_zero_iff
  {R : Type _} [IsDomain R] [CommRing R]
  (π : LocalGL2Parameter R) :
  discr π = 0 ↔ π.alpha = π.beta := by
  ...
```

Then prove a transfer-collapse statement such as:
```lean
theorem symmSq_repeated_root_of_discr_eq_zero
  {R : Type _} [CommRing R]
  (π : LocalGL2Parameter R)
  (h : discr π = 0) :
  ∃ a : R,
    stdEulerFactor (symmSq π)
      = (1 - Polynomial.C a * Polynomial.X)^3 := by
  ...
```

**Why this matters:** this is a formal avatar of detecting special/endoscopic/non-generic behavior from local parameters. It pushes the development beyond polynomial bookkeeping into structure theory.

---

### Theorem 4: Cross-domain theorem linking functorial transfer to spectral growth or complexity
You are required to connect to another domain. Use the catalog intelligently.

A compelling direction is to define a simple numerical invariant of a local parameter, e.g.:
- `transferDegree` = degree of Euler factor,
- `weightMass` = sum of exponents in symmetric-power roots,
- `spectralRadiusProxy` = max/root-bound surrogate if working over `ℝ≥0`.

Then prove monotonic growth under transfer and connect it to the catalog theorem
`spectral_transfer_iterate_bound` from `Algebra/Apollonian/SpectralTransfer.lean`.

Example mathematical statement:
For a nonnegative real parameter `π=(α,β)` with `0 ≤ α, β`, the coefficient sum of the reciprocal symmetric-square Euler factor dominates that of the standard factor; iterated transfer satisfies an explicit bound comparable to spectral iteration growth.

Lean target sketch:
```lean
def coeffMass
  (P : Polynomial ℝ) : ℝ := ∑ i in P.support, |P.coeff i|

theorem coeffMass_symmSq_ge_std
  (π : LocalGL2Parameter ℝ)
  (ha : 0 ≤ π.alpha) (hb : 0 ≤ π.beta) :
  coeffMass (stdEulerFactor (symmSq π)) ≥ coeffMass (stdEulerFactor π) := by
  ...
```

Or define a transfer iteration:
```lean
def transferIterate : ℕ → LocalGL2Parameter ℝ → List ℝ
```
and prove a growth bound using `spectral_transfer_iterate_bound` as an analogy or actual lemma if your encoding aligns.

**Why this matters:** this forges a bridge between Langlands transfer and spectral dynamics / complexity growth. That is exactly the kind of unexpected connection that opens a field.

---

## Most Promising Proof Strategies

You must include 2–3 strategies and choose among them.

### Strategy A: Direct polynomial/Euler-factor formalization via finite products
**Best first route.**
1. Define local parameters and Euler factors using `Fin n → R` roots and finite products.
2. Prove generic lemmas about products under maps, permutations, and scalar twists.
3. Instantiate for `symmSq` and `symmCube` by explicit `Fin`-index calculations and `ring_nf` / `simp` / structured `calc`.

Why this is strongest:
- scales to `Symm^m`,
- avoids ad hoc coefficient expansions,
- mirrors the actual representation-theoretic mechanism: transfer = pushforward on Satake parameters.

### Strategy B: Coefficient-by-coefficient proof using elementary symmetric polynomials
1. Define the reciprocal Euler factor from elementary symmetric functions of roots.
2. Express symmetric-square and symmetric-cube coefficients in terms of `α+β` and `αβ`.
3. Prove factorization and discriminant identities by multi-step `calc`, `field_simp`, and ring arguments.

Why this is powerful:
- reveals internal structure,
- closer to Hecke eigenvalue recurrences and classical modular-form formulas,
- ideal for proving “transfer depends only on trace and determinant.”

This may be the most mathematically illuminating route if Mathlib support for symmetric polynomials is sufficient in your setup.

### Strategy C: Categorical/functorial abstraction
1. Define a category-like notion of parameter spaces with transfer maps.
2. Prove functoriality laws: identity, composition, twisting compatibility.
3. Recover polynomial identities as corollaries.

Why this is visionary:
- turns local Langlands shadows into reusable software architecture,
- sets up later automorphic and Galois parameter formalization.

Why it is likely second-stage rather than first:
- category infrastructure may consume time before core theorems land.

**Recommendation:** Start with **Strategy A**, prove the transfer laws, then elevate to **Strategy C** if time permits. Use **Strategy B** specifically for the discriminant/reducibility theorem.

---

## Cross-Domain Connections You Must Exploit

Do not keep this sealed inside representation theory. Build at least one theorem that touches another domain.

### 1. Spectral dynamics
Use `spectral_transfer_iterate_bound` as inspiration or ingredient:
- interpret repeated symmetric-power transfer as a spectral amplification process,
- compare growth of coefficient mass / degree / support under iteration.

### 2. Algebraic complexity / GCT
The catalog includes:
- `depth_lower_bound_from_degree`
- `mulGates_lower_bound_from_degree`
- `circuit_lower_bound_from_obstruction`

Exploit this by defining an explicit polynomial family arising from transferred Euler factors and proving that the degree growth under symmetric-power transfer triggers complexity lower bounds. For instance:
- build a family of Euler-factor polynomials whose degree is exactly `m+1` for `Symm^m`,
- use degree-growth lemmas to derive lower bounds for circuits computing these families.

This is not a gimmick: it reframes functorial transfer as a **complexity amplifier**.

### 3. Additive combinatorics / autocorrelation
The theorem `autocorrelation_symmetric` suggests another route:
- root multisets of transferred parameters possess symmetries,
- prove an autocorrelation symmetry for exponent multisets `{m-i, i}`,
- connect this to palindromic/self-reciprocal structure of Euler factors when `αβ = 1`.

A precise theorem here would be striking:
```lean
theorem symmSq_self_reciprocal_of_unit_det
  {R : Type _} [CommRing R]
  (π : LocalGL2Parameter R)
  (hdet : π.alpha * π.beta = 1) :
  IsSelfReciprocal (stdEulerFactor (symmSq π)) := by
  ...
```

This ties representation theory to combinatorial symmetry.

---

## Concrete Deliverables in the Lean File

Your file must contain:

1. **At least one new structure** for local Langlands/Satake data.
2. **At least 3 nontrivial theorems**, preferably:
   - `stdEulerFactor_symmSq`
   - `stdEulerFactor_symmCube`
   - `discr_eq_zero_iff`
   - one cross-domain theorem
3. Proofs using:
   - induction on symmetric-power index if you generalize to `symmPow`,
   - `rcases` for root cases / decomposition,
   - `by_contra` in a structural theorem,
   - `field_simp` when proving rational-function or discriminant identities,
   - substantial `calc` chains.
4. A **verified algorithm**:
   - implement `symmPowRoots : ℕ → LocalGL2Parameter R → List R`
   - compute transferred roots and Euler factors,
   - prove correctness of the algorithm against the abstract definition.
5. A computational demonstration script.

---

## Suggested Lean 4 Type Signatures

These are not mandatory verbatim, but your formalization should be this precise:

```lean
structure LocalGL2Parameter (R : Type _) [CommSemiring R] where
  alpha : R
  beta  : R

structure LocalGLnParameter (R : Type _) [CommSemiring R] (n : ℕ) where
  root : Fin n → R

def eulerFactor
  {R : Type _} [CommSemiring R] {n : ℕ} :
  LocalGLnParameter R n → Polynomial R
| π => ∏ i : Fin n, (1 - Polynomial.C (π.root i) * Polynomial.X)

def symmSq
  {R : Type _} [CommSemiring R] :
  LocalGL2Parameter R → LocalGLnParameter R 3
| π => ...

def symmCube
  {R : Type _} [CommSemiring R] :
  LocalGL2Parameter R → LocalGLnParameter R 4
| π => ...

def discr
  {R : Type _} [CommRing R] :
  LocalGL2Parameter R → R
| π => (π.alpha - π.beta)^2
```

And theorem signatures such as:

```lean
theorem eulerFactor_symmSq
  {R : Type _} [CommSemiring R]
  (π : LocalGL2Parameter R) :
  eulerFactor (symmSq π)
    = (1 - Polynomial.C (π.alpha ^ 2) * Polynomial.X) *
      (1 - Polynomial.C (π.alpha * π.beta) * Polynomial.X) *
      (1 - Polynomial.C (π.beta ^ 2) * Polynomial.X) := by
  ...

theorem discr_eq_zero_iff
  {R : Type _} [CommRing R] [IsDomain R]
  (π : LocalGL2Parameter R) :
  discr π = 0 ↔ π.alpha = π.beta := by
  ...
```

If you can generalize to all `m : ℕ`, even better:

```lean
def symmPowRoots
  {R : Type _} [CommSemiring R] (m : ℕ) (π : LocalGL2Parameter R) : Fin (m+1) → R
| i => π.alpha ^ (m - i.1) * π.beta ^ i.1

theorem eulerFactor_symmPow
  {R : Type _} [CommSemiring R] (m : ℕ) (π : LocalGL2Parameter R) :
  eulerFactor ⟨symmPowRoots m π⟩
    = ∏ i : Fin (m+1),
        (1 - Polynomial.C (π.alpha ^ (m - i.1) * π.beta ^ i.1) * Polynomial.X) := by
  ...
```

This theorem is definitional only if phrased badly; do **not** stop there. Use it to prove nontrivial corollaries:
- degree = `m+1`,
- twist compatibility,
- determinant/central-character formula,
- self-reciprocity under `αβ=1`,
- repeated-root criterion.

---

## Testable Conjecture (MANDATORY)

State at least one falsifiable conjecture with a clear computational disproof procedure.

A strong conjecture:

> **Conjecture (self-reciprocal stability of symmetric powers).**
> For any `m : ℕ` and any local GL(2) parameter `π=(α,β)` over a field with `αβ = 1`, the reciprocal Euler factor of `Symm^m(π)` is self-reciprocal.

Lean-style conjecture:
```lean
conjecture eulerFactor_symmPow_selfReciprocal_of_det_one
  {R : Type _} [CommRing R]
  (m : ℕ) (π : LocalGL2Parameter R)
  (hdet : π.alpha * π.beta = 1) :
  IsSelfReciprocal (eulerFactor ⟨symmPowRoots m π⟩)
```

**Computational test:** for random rational pairs `(α,β)` with `αβ=1`, compute the coefficient list of the Euler factor and compare it with its reversed list. A single counterexample disproves the conjecture.

An even bolder conjecture:

> **Conjecture (complexity amplification under functorial transfer).**
> The algebraic circuit depth needed to compute the coefficient vector of the symmetric-power Euler factor grows at least logarithmically in the transfer degree, uniformly over generic parameters.

This is testable numerically by constructing explicit coefficient polynomials and comparing certified degree-based lower bounds from the catalog.

---

## How to Use Existing Catalog Theorems

You were given:
- `spectral_transfer_iterate_bound`
- `depth_lower_bound_from_degree`
- `mulGates_lower_bound_from_degree`
- `circuit_lower_bound_from_obstruction`
- `autocorrelation_symmetric`

Do not name-drop them. Use them.

### Build plan:
1. Define a polynomial family from symmetric-power transfer.
2. Prove its degree or spectral-growth invariant.
3. Invoke:
   - `depth_lower_bound_from_degree`
   - `mulGates_lower_bound_from_degree`
   to derive complexity consequences.
4. Use `spectral_transfer_iterate_bound` to compare transfer iteration growth if you define a suitable iterate map.
5. Use `autocorrelation_symmetric` conceptually or structurally to prove root/exponent symmetry theorems.

This turns your work from isolated formalization into a bridge between Langlands and complexity/spectral theory.

---

## Revolutionary Significance

If you execute this well, you will have created:
- the first Lean-certified **local functorial transfer engine** for symmetric powers of GL(2),
- a reusable formal interface for Satake parameters and Euler factors,
- a rigorous bridge from representation-theoretic transfer to **spectral dynamics** and **algebraic complexity**,
- a foundation on which one can later formalize:
  - Hecke eigenvalue recurrences,
  - modular-form local factors,
  - motivic/Galois realizations,
  - trace formulas,
  - eventually genuine automorphic functoriality.

This is not incremental. It opens a formal research program.

---

## Mandatory Non-Code Deliverables

You must produce **all** of the following:

1. **`FUTURE_DIRECTIONS.md`**
   - 3–5 testable scientific hypotheses.
   - Each must be a falsifiable conjecture with a clear computational or formal test.
   - At least one hypothesis must concern higher symmetric powers.
   - At least one must concern complexity or spectral growth.

2. **`RESEARCH_PAPER.md`**
   - A standalone scientific paper.
   - It must explain the definitions, theorems, proofs, significance, and future work.
   - A reader with no access to the code must still understand the discovery.

3. **`ARTICLE.md`**
   - Scientific American style.
   - Explain functoriality, symmetric-power transfer, and why verified mathematics matters.
   - Make the cross-domain bridge vivid.

4. **A verified algorithm or computational method**
   - Implement and prove correct an algorithm computing symmetric-power transferred roots / Euler factors.

5. **`demo.py`**
   - Interactive demo computing Euler factors of `Symm^2` / `Symm^3`,
   - checking self-reciprocity under determinant-one conditions,
   - and experimentally probing the conjecture(s).

---

## Application Keywords

Langlands functoriality; local Langlands; Satake parameters; symmetric power lifting; Gelbart–Jacquet; automorphic L-functions; Euler factors; Hecke eigenvalues; self-reciprocal polynomials; spectral transfer; algebraic complexity; geometric complexity theory; endoscopy; representation theory; formal verification; Lean 4; Mathlib; computational number theory; certified symbolic algebra.

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
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

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

Research domain: Algebra
Research mode: prove
