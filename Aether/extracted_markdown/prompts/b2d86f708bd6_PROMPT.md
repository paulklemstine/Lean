Soli Deo Gloria

## Assignment: Direction 5 — Resolvent Geometry as a General Framework

**Mode:** `prove`

Aristotle, aim for a theorem package that does not merely repackage DPP folklore, but **extracts resolvent geometry as the hidden linear-algebraic skeleton of negative dependence**. The breakthrough is to show that what looks special about determinantal measures is in fact the first visible case of a wider phenomenon:

> **negatively dependent measure → logarithmic Hessian geometry at the all-ones point → conditional negative semidefiniteness on the mass-preserving hyperplane → resolvent-type representation**

If successful, this opens a new field interface between **probabilistic combinatorics, Lorentzian/stable polynomial theory, matrix analysis, and discrete Hodge-type geometry**.

Your goal is to formalize and prove nontrivial theorems around a new notion of **resolvent-compatible polynomial geometry**, building directly on:

- `Catalog/Speculative/AutoResearch/DPPLorentzian.lean`
  - especially objects/theorems around `IsDPPLorentzian`, `dppPartitionFunction`
- `Pythagorean/LorentzianCertificate.lean`
  - especially the certificate style for transporting Hessian-sign information into formally checkable inequalities

The target is not a single theorem but a **coherent mini-theory** with at least one new definition, at least three substantial proofs, one cross-domain theorem, one algorithmic verifier, and one falsifiable conjecture.

---

## Core Mathematical Vision

For a polynomial
\[
p(x_1,\dots,x_n)=\sum_{S\subseteq [n]} \mu(S)\prod_{i\in S}x_i
\]
with nonnegative coefficients, define its logarithmic Hessian at the all-ones point:
\[
\mathcal H_p(i,j)
:= \left.\frac{\partial^2}{\partial x_i\partial x_j}\log p(x)\right|_{x=\mathbf 1}.
\]
For a determinantal partition function \(p_A(x)=\det(I+\mathrm{Diag}(x)A)\), one expects a concrete resolvent formula in terms of
\[
L := A(I+A)^{-1}
\quad\text{or equivalently}\quad
(I+A)^{-1},
\]
and the Hessian entries should be expressible by quadratic combinations of matrix entries. The larger thesis is that **conditional negative semidefiniteness of the Hessian on the zero-sum subspace** is the invariant that survives beyond the determinantal world.

This is not just another Hessian-sign theorem. If established in a robust formal form, it reframes negative dependence as a **metric/curvature phenomenon** attached to generating polynomials.

---

## Precise Formalization Targets

You should introduce at least one genuinely new definition. I recommend the following.

### New definition 1: conditional negative semidefiniteness on the zero-sum hyperplane

For a symmetric matrix \(M : \mathrm{Matrix}\ n\ n\ \mathbb R\),
\[
\forall v,\ \Big(\sum_i v_i = 0\Big)\to v^\top M v \le 0.
\]

Possible Lean 4 shape:
```lean
def Matrix.CondNegSemidef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ) : Prop :=
  ∀ v : n → ℝ, (∑ i, v i = 0) →
    0 ≤ - ∑ i, ∑ j, v i * M i j * v j
```

or equivalently:
```lean
def Matrix.CondNegSemidef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ) : Prop :=
  ∀ v : n → ℝ, (∑ i, v i = 0) →
    (∑ i, ∑ j, v i * M i j * v j) ≤ 0
```

### New definition 2: resolvent-compatible polynomial data

Abstract the property that a polynomial’s Hessian at `1` is represented by a matrix formula.

A flexible first version:
```lean
structure ResolventCompatible
    {n : Type*} [Fintype n] [DecidableEq n] where
  p : MvPolynomial n ℝ
  h_nonneg : ∀ d, 0 ≤ p.coeff d
  H : Matrix n n ℝ
  h_symm : H.IsSymm
  h_represents_logHessianAtOne : Prop
```

If the full multivariate analytic Hessian is too heavy, work with a combinatorial proxy extracted from coefficients and directional second derivatives at `1`.

### New definition 3: coefficient-level Hessian at one

For multilinear polynomials especially, define a finite combinatorial Hessian matrix from coefficients or partial derivatives evaluated at `1`. This may be more tractable in Lean than full Fréchet derivatives:
```lean
def coeffHessianAtOne
    {n : Type*} [Fintype n] [DecidableEq n]
    (p : MvPolynomial n ℝ) : Matrix n n ℝ := ...
```

You may define it via iterated `pderiv` and evaluation at `1`.

---

## Theorem Package to Prove

You must prove at least **3 deep theorems**. Here is the package I recommend.

### Theorem 1: DPP resolvent Hessian formula
This is the anchor theorem. Make it exact and computational.

**Mathematical statement.**  
Let \(A\) be a real symmetric matrix such that \(I+A\) is invertible, and let
\[
p_A(x)=\det(I+\operatorname{Diag}(x)A).
\]
Then the logarithmic Hessian of \(p_A\) at \(x=\mathbf 1\) is represented by a symmetric matrix \(\mathcal H_A\) whose entries satisfy a resolvent identity of the form
\[
\mathcal H_A(i,j)=
-\,L_{ij}^2 \quad (i\neq j),
\qquad
\mathcal H_A(i,i)=L_{ii}-L_{ii}^2
\]
or an equivalent formula depending on your normalization, where
\[
L := A(I+A)^{-1}.
\]
You should also prove symmetry and derive the quadratic form identity
\[
v^\top \mathcal H_A v
=
-\sum_{i<j} c_{ij}(v_i-v_j)^2 + \text{diagonal correction},
\]
with coefficients explicitly in terms of \(L\).

**Lean target shape.**
```lean
theorem dpp_logHessianAtOne_resolvent_formula
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ)
    (hA_symm : A.IsSymm)
    (hInv : IsUnit (A + 1))
    :
    ∃ H : Matrix n n ℝ,
      H.IsSymm ∧
      (∀ i j, i ≠ j →
        H i j = -((A ⬝ (A + 1)⁻¹) i j)^2) ∧
      (∀ i,
        H i i = (A ⬝ (A + 1)⁻¹) i i
              - ((A ⬝ (A + 1)⁻¹) i i)^2)
```

You may need to adjust matrix notation and invertibility hypotheses to actual Mathlib conventions. If the exact matrix inverse API is painful, phrase in terms of an explicit `B` with `(A + 1) ⬝ B = 1`.

**Why this is a breakthrough.**  
It makes the DPP case not just “negative dependence by determinants,” but a theorem of **curvature extraction by resolvents**. This is the conceptual bridge to the general theory.

---

### Theorem 2: Conditional negative semidefiniteness from resolvent representation
This is the structural theorem.

**Mathematical statement.**  
Suppose \(H\) is a symmetric matrix with off-diagonal entries of the form
\[
H_{ij}=-w_{ij}\quad(i\neq j),\qquad w_{ij}\ge 0,
\]
and diagonal chosen so that each row sum is zero:
\[
H_{ii}=\sum_{j\neq i} w_{ij}.
\]
Then \(H\) is conditionally negative semidefinite:
\[
\forall v\in\mathbb R^n,\ \sum_i v_i=0 \implies v^\top(-H)v \ge 0.
\]
Equivalently,
\[
v^\top H v = -\sum_{i<j} w_{ij}(v_i-v_j)^2 \le 0
\]
for every zero-sum \(v\).

This theorem is elementary in spirit but should be formalized in a nontrivial way with full matrix/quadratic-form manipulation. It becomes the **transfer principle** from resolvent formulas to negative dependence.

**Lean target shape.**
```lean
theorem condNegSemidef_of_laplacian_form
    {n : Type*} [Fintype n] [DecidableEq n]
    (w : n → n → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (hw_nonneg : ∀ i j, 0 ≤ w i j)
    let H : Matrix n n ℝ :=
      fun i j =>
        if h : i = j then ∑ k in Finset.univ.erase i, w i k else -w i j
    in
    Matrix.CondNegSemidef H
```

**Why this is a breakthrough.**  
This theorem identifies the hidden Laplacian geometry behind Hessians of generating functions. It says the logarithmic Hessian is not merely negative in some coordinate sense; it behaves like an **energy form of a weighted interaction graph**. That opens the door to spectral graph theory, effective resistance, and discrete geometry.

---

### Theorem 3: Cross-domain bridge — graph basis generating functions induce conditional NSD Hessians
This is the cross-pollination theorem.

Choose one of the following two routes.

#### Route A: Graphic matroids
For a finite graph \(G\), let
\[
B_G(x)=\sum_{T\text{ spanning tree}} \prod_{e\in T} x_e.
\]
Prove, in a formalized special case or abstracted certificate form, that the coefficient-Hessian or logarithmic Hessian at \(x=\mathbf 1\) is conditionally negative semidefinite.

This would connect:
- negative dependence / matroid measures
- graph Laplacians and Kirchhoff theory
- polynomial Hessian geometry

**Lean target shape.**
```lean
theorem graphic_basis_generating_condNegSemidef
    (G : SimpleGraph V)
    [Fintype V] [DecidableEq V]
    :
    Matrix.CondNegSemidef (coeffHessianAtOne (graphicBasisPolynomial G))
```

If full spanning-tree formalization is too ambitious, prove a certificate theorem saying: **if** a polynomial admits a Laplacian-form Hessian certificate, **then** it is conditionally NSD. Then instantiate on a tractable graph family such as cycles, complete graphs on small vertex sets, or parallel-edge toy models.

#### Route B: Products of linear forms / Lorentzian side
Let
\[
p(x)=\prod_{r=1}^m \ell_r(x)
\]
where each \(\ell_r\) has nonnegative coefficients. Prove that under suitable positivity hypotheses, the log-Hessian at `1` is a sum of rank-one negative semidefinite pieces on the zero-sum subspace, hence conditionally NSD.

This is formally more tractable and still strongly cross-domain: it links **hyperbolic/Lorentzian polynomial geometry** to **matrix energy forms**.

**Lean target shape.**
```lean
theorem condNegSemidef_logHessian_product_linear_forms
    {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m]
    (ℓ : m → (n → ℝ))
    (h_nonneg : ∀ r i, 0 ≤ ℓ r i)
    (h_pos : ∀ r, 0 < ∑ i, ℓ r i)
    :
    Matrix.CondNegSemidef (productLinearForms_logHessianAtOne ℓ)
```

**Why this is a breakthrough.**  
This would show that “resolvent geometry” is not confined to determinants. It persists in a different algebraic universe—products of linear forms / Lorentzian polynomials—suggesting a unifying curvature principle across apparently unrelated classes of negatively dependent measures.

---

## Optional Theorem 4: Stability/Lorentzian certificate transfer
Use `Pythagorean/LorentzianCertificate.lean` as a model.

**Statement idea.**  
If a multilinear polynomial has a certified decomposition of its coefficient-Hessian into a sum of negative semidefinite rank-one forms plus a graph-Laplacian term, then its Hessian is conditionally negative semidefinite at `1`.

This theorem becomes the machine for future discoveries.

**Lean target shape.**
```lean
theorem condNegSemidef_of_certificate
    {n : Type*} [Fintype n] [DecidableEq n]
    (p : MvPolynomial n ℝ)
    (cert : ResolventCertificate p)
    :
    Matrix.CondNegSemidef (coeffHessianAtOne p)
```

---

## Proof Strategy Architecture

You asked for 2–3 proof strategy steps; here are **three proof pathways**, with one recommended as primary.

### Strategy A — Direct matrix calculus from determinant identities
**Best for Theorem 1. Most promising overall.**

1. Define \(p_A(x)=\det(I+\mathrm{Diag}(x)A)\) and differentiate using Jacobi’s formula:
   \[
   \partial_i \log\det M(x)=\mathrm{tr}(M(x)^{-1}\partial_i M(x)).
   \]
2. Differentiate again:
   \[
   \partial_{ij}^2 \log\det M
   = -\mathrm{tr}(M^{-1}\partial_i M\, M^{-1}\partial_j M)
   \]
   because \(M\) is affine in the \(x_i\).
3. Specialize at \(x=\mathbf 1\), where \(M(1)=I+A\), and rewrite in terms of
   \[
   L=A(I+A)^{-1}
   \]
   to get explicit entrywise formulas.

**Why most promising:** determinant differentiation has a rigid algebraic structure, and the resulting formulas are exactly the kind of matrix equalities Lean can digest via `calc`, `field_simp`, trace identities, and entrywise extensionality.

---

### Strategy B — Coefficient-level combinatorial differentiation
**Best if analytic derivative infrastructure is cumbersome.**

1. Restrict first to multilinear generating polynomials of measures:
   \[
   p(x)=\sum_S \mu(S)\prod_{i\in S}x_i.
   \]
2. Express \(\partial_i p(1)\) and \(\partial_{ij}^2 p(1)\) as probabilities:
   \[
   \partial_i p(1)=\mathbb P(i\in S)\cdot p(1),\qquad
   \partial_{ij}^2 p(1)=\mathbb P(i,j\in S)\cdot p(1).
   \]
3. Rewrite the Hessian of \(\log p\) at `1` as
   \[
   \mathcal H_p(i,j)
   = \frac{\partial_{ij}^2 p(1)}{p(1)}
     - \frac{\partial_i p(1)\partial_j p(1)}{p(1)^2},
   \]
   i.e. as a covariance matrix of indicator variables up to normalization/sign convention. Then prove conditional NSD under negative dependence assumptions or certificate hypotheses.

**Why valuable:** this makes the geometry probabilistically transparent and may avoid analytic overhead. It also exposes the link to covariance, entropy, and information geometry.

---

### Strategy C — Lorentzian/hyperbolic certificate transport
**Best for Theorem 3 Route B and future generalization.**

1. Use catalog infrastructure to extract Hessian-sign certificates for Lorentzian or completely log-concave classes.
2. Define a formal certificate object encoding a decomposition of the Hessian into negative semidefinite atoms.
3. Prove a generic transfer theorem from certificate to conditional NSD.

**Why important:** this turns one-off examples into a reusable theorem engine. It is probably not the first theorem to attack, but it is the right architecture for scaling.

---

## Recommended Order of Attack

1. **Define `Matrix.CondNegSemidef`** and prove foundational lemmas:
   - symmetry invariance
   - equivalent quadratic-form characterizations
   - Laplacian-form implies conditional NSD

2. **Build the DPP resolvent theorem** in the most manageable setting:
   - finite index type
   - real symmetric matrices
   - invertibility of `1 + A`
   - perhaps start with entrywise formulas rather than full multivariate differential abstraction

3. **Create a coefficient-Hessian/log-Hessian abstraction** for multilinear polynomials.

4. **Prove a cross-domain theorem**:
   - either products of linear forms
   - or a graphic-matroid family / spanning-tree family
   - or both, if feasible

5. **Implement a computational verifier** that checks the conditional NSD certificate numerically/symbolically for sample families.

---

## Suggested Lean 4 Theorem Statements

These are aspirational signatures; adapt them to actual Mathlib APIs.

```lean
def Matrix.CondNegSemidef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ) : Prop :=
  ∀ v : n → ℝ, (∑ i, v i = 0) →
    (∑ i, ∑ j, v i * M i j * v j) ≤ 0
```

```lean
theorem condNegSemidef_of_laplacian_form
    {n : Type*} [Fintype n] [DecidableEq n]
    (w : n → n → ℝ)
    (hw_symm : ∀ i j, w i j = w j i)
    (hw_nonneg : ∀ i j, 0 ≤ w i j) :
    Matrix.CondNegSemidef
      (fun i j =>
        if h : i = j then ∑ k in Finset.univ.erase i, w i k else -w i j)
```

```lean
def coeffHessianAtOne
    {n : Type*} [Fintype n] [DecidableEq n]
    (p : MvPolynomial n ℝ) : Matrix n n ℝ := ...
```

```lean
theorem logHessian_eq_coeffHessian_correction
    {n : Type*} [Fintype n] [DecidableEq n]
    (p : MvPolynomial n ℝ)
    (hp1 : 0 < eval (fun _ => (1 : ℝ)) p) :
    ∀ i j,
      logHessianAtOne p i j
        = coeffHessianAtOne p i j / eval (fun _ => (1 : ℝ)) p
        - firstDerivAtOne p i * firstDerivAtOne p j
            / (eval (fun _ => (1 : ℝ)) p)^2
```

```lean
theorem dpp_logHessianAtOne_resolvent_formula
    {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℝ)
    (hA_symm : A.IsSymm)
    (hInvertible : IsUnit (1 + A.det)) :
    ∃ H : Matrix n n ℝ, H.IsSymm ∧
      (∀ i j, i ≠ j →
        H i j = -((A ⬝ (1 + A)⁻¹) i j)^2) ∧
      (∀ i,
        H i i = ((A ⬝ (1 + A)⁻¹) i i)
              - ((A ⬝ (1 + A)⁻¹) i i)^2)
```

```lean
theorem condNegSemidef_logHessian_product_linear_forms
    {n m : Type*} [Fintype n] [DecidableEq n] [Fintype m]
    (ℓ : m → n → ℝ)
    (h_nonneg : ∀ r i, 0 ≤ ℓ r i)
    (h_pos : ∀ r, 0 < ∑ i, ℓ r i) :
    Matrix.CondNegSemidef (productLinearForms_logHessianAtOne ℓ)
```

```lean
structure ResolventCertificate
    {n : Type*} [Fintype n] [DecidableEq n]
    (p : MvPolynomial n ℝ) where
  H : Matrix n n ℝ
  h_repr : H = coeffHessianAtOne p
  weights : n → n → ℝ
  h_nonneg : ∀ i j, 0 ≤ weights i j
  h_symm : ∀ i j, weights i j = weights j i
  h_laplacian : ∀ i j,
    H i j =
      if h : i = j then ∑ k in Finset.univ.erase i, weights i k else -weights i j
```

```lean
theorem condNegSemidef_of_certificate
    {n : Type*} [Fintype n] [DecidableEq n]
    (p : MvPolynomial n ℝ)
    (cert : ResolventCertificate p) :
    Matrix.CondNegSemidef (coeffHessianAtOne p)
```

---

## Deep Proof Tactics You Must Actually Use

Your file must contain at least 3 genuinely nontrivial proofs using combinations of:

- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- matrix `ext`
- finite sum rearrangement
- rewriting via symmetry hypotheses
- quadratic-form expansions on `Finset.univ`

Concretely:

- **Theorem 2** should use a multi-step `calc` to derive
  \[
  \sum_{i,j} v_i H_{ij} v_j = -\sum_{i<j} w_{ij}(v_i-v_j)^2.
  \]
- **Theorem 1** should use `field_simp` or equivalent denominator-clearing if you represent log-Hessian entries through determinant quotients.
- At least one proof should use `by_contra` to convert failure of conditional NSD into a contradiction with a sum-of-squares identity.
- At least one theorem should use `rcases` on a certificate object or matrix decomposition witness.

Do not settle for theorem statements that collapse to `rfl` or finite brute force.

---

## Cross-Domain Connections to Make Explicit

You are required to include at least one theorem connecting this domain to another. The most compelling bridges here are:

1. **Probability theory ↔ matrix analysis**  
   The log-Hessian at `1` is a covariance/interaction matrix of inclusion indicators.

2. **Negative dependence ↔ spectral graph theory**  
   Conditional NSD turns Hessians into Laplacian-like energy forms, suggesting effective resistance and diffusion analogies.

3. **Lorentzian polynomials ↔ discrete curvature**  
   Lorentzian/Hodge inequalities become curvature inequalities for generating functions.

4. **Statistical physics ↔ polynomial geometry**  
   The Hessian of `log p` is a susceptibility matrix; conditional NSD is a “repulsive response” law.

5. **Information geometry ↔ combinatorics**  
   `∇² log p` behaves like a Fisher-information-style object for combinatorial measures.

At least one theorem or section of `RESEARCH_PAPER.md` should explicitly articulate one of these bridges.

---

## Computational/Algorithmic Deliverable

You must provide a **verified algorithm or computational method**, not just theorem statements.

### Proposed algorithm
Implement a procedure that, given a multilinear polynomial with nonnegative coefficients or a matrix-derived DPP instance:

1. computes first and second partials at `1`,
2. builds the candidate Hessian/log-Hessian matrix,
3. attempts to fit it to a Laplacian/resolvent certificate,
4. checks conditional NSD numerically on the zero-sum subspace,
5. outputs either:
   - a certificate witness, or
   - a counterexample candidate.

This can be formalized partially in Lean and demonstrated in Python.

### `demo.py` ideas
Interactive examples for:
- DPPs from random PSD matrices
- products of linear forms
- basis-generating polynomials of small graphic matroids
- permanent-like examples

Display:
- Hessian matrix
- eigenvalues on the zero-sum subspace
- fitted Laplacian weights
- whether the conjectured resolvent law appears to hold

---

## Falsifiable Conjecture with Clear Computational Test

You must state at least one conjecture that could fail on computation.

### Primary conjecture
For every multilinear homogeneous polynomial \(p\) with nonnegative coefficients that is Lorentzian and normalized by \(p(\mathbf 1)>0\), the matrix
\[
\left(\partial_{ij}^2 \log p\right)(\mathbf 1)
\]
is conditionally negative semidefinite.

### Stronger resolvent conjecture
For every negatively dependent measure \(\mu\) whose generating polynomial \(p_\mu\) is completely log-concave, there exists a symmetric nonnegative kernel \(w_{ij}\) and a diagonal correction \(d_i\) such that
\[
\mathcal H_{p_\mu}(\mathbf 1)
=
D - W
\]
with \(W_{ij}=w_{ij}\) for \(i\neq j\), row sums controlled by marginals, and hence conditional NSD.

### Computational test protocol
Search over:
- graphic matroid basis polynomials for small graphs,
- products of random positive linear forms,
- permanent-like polynomials of small nonnegative matrices,
- small strongly Rayleigh measures from catalog examples.

A single instance with a positive eigenvalue on the zero-sum subspace disproves the primary conjecture.

---

## Why This Would Be Revolutionary

If you succeed, you will have isolated a new invariant:

> **the conditional-NSD logarithmic Hessian as the curvature tensor of repulsive combinatorial measures**

That would:

- recast negative dependence in geometric language,
- connect DPP resolvents to Lorentzian and strongly Rayleigh worlds,
- suggest new algorithms for certifying repulsion,
- provide spectral tools for combinatorial probability,
- and create a formal platform for “curvature of generating functions.”

This is the kind of result that can seed an entire research program:
- Hessian comparison theorems for stable polynomials,
- tropical or information-geometric analogues,
- discrete Ricci-type notions for matroids and measures,
- new concentration inequalities via Hessian energy forms.

---

## Application Keywords

Use these in the paper and metadata:

**application keywords:** negative dependence, determinantal point processes, Lorentzian polynomials, strongly Rayleigh measures, conditional negative semidefiniteness, resolvent identity, matrix analysis, spectral graph theory, combinatorial Hodge theory, generating polynomials, covariance geometry, statistical physics, information geometry, susceptibility matrix, matroid theory

---

## Mandatory Deliverables

You must produce **all** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**. Each direction must contain the exact sentences:
- **“The key insight is...”**
- **“Why now?”**

At least one direction must bridge to a different domain, such as:
- information theory,
- statistical physics,
- spectral graph theory,
- tropical geometry,
- optimization.

Do not write templates; write genuine research prose.

### 2. `RESEARCH_PAPER.md`
A standalone scientific document that explains:
- the new definitions,
- the main theorems,
- proof ideas,
- why the resolvent viewpoint is conceptually new,
- computational evidence,
- limitations and conjectures,
- future work.

A reader with no access to the code must still understand the discovery.

### 3. `ARTICLE.md`
Write in **Scientific American** style:
- engaging,
- accessible,
- focused on the mathematics and significance.

**Taboo:** do **not** focus on formal verification or proof assistants. Focus on the ideas: repulsive randomness, hidden curvature, and why determinants were only the beginning.

### 4. Verified algorithm or computational method
Implement a certificate checker / Hessian analyzer as described above.

### 5. `demo.py`
Provide an interactive demo that:
- constructs examples,
- computes Hessians at `1`,
- checks zero-sum-subspace eigenvalues,
- attempts a resolvent/Laplacian fit,
- prints or plots the outcome.

---

## Final Charge

Do not aim for a cosmetic theorem. Aim for a formal seed of a new doctrine:

> **Resolvent geometry is the linear-algebraic avatar of negative dependence.**

Build the DPP case cleanly. Prove the Laplacian transfer theorem rigorously. Then push into Lorentzian or graphic-matroid territory to show this is not an accident but the beginning of a unification.

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
