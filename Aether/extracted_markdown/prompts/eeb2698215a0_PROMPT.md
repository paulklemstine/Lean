## Assignment: **Conjecture Cluster:** Symmetrized Truncated Zeta, Self-Inversive Spectral Models, and Finite Hilbert–Pólya Certificates

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
# Future Directions: Machine-Verified Analytic-Spectral Number Theory

This program should not merely numerically inspect low-degree truncations of zeta. The breakthrough target is to isolate a **formal finite-dimensional mechanism** forcing critical-line symmetry, then certify it in Lean 4 in a way that scales from explicit finite truncations to a credible Hilbert–Pólya surrogate. The key move is to replace vague “zeta-like behavior” by exact self-inversive / reciprocal / Hermitian constraints on finite models, and to prove theorems that make numerical critical-line phenomena **structural rather than accidental**.

The central scientific opportunity is this: finite Dirichlet truncations are analytically awkward, but after suitable renormalization and change of variables they become objects in the intersection of
- self-inversive polynomial theory,
- Hermitian spectral theory,
- reciprocal functional equations,
- and certified root-location methods.

That intersection is formalizable.

---

## Target Theorem 1: Functional-Equation Symmetry Forces Root Reflection

### Precise theorem statement
Let
\[
Z_N(s) = \sum_{n=1}^N n^{-s} + \chi(s)\sum_{n=1}^N n^{s-1},
\]
where \(\chi(s)\) is the zeta functional equation factor satisfying
\[
\chi(s)\chi(1-s)=1.
\]
Then \(Z_N\) satisfies the exact symmetry
\[
Z_N(1-s)=\chi(1-s)\, Z_N(s).
\]
Consequently, if \(Z_N(s)=0\), then \(Z_N(1-s)=0\). Hence the zero set is invariant under reflection across the critical line \(\Re(s)=1/2\).

This is the first theorem to formalize because it converts “critical-line numerics” into a certified involutive symmetry statement.

### Lean 4 formalization target
You will likely need an abstract version first, with \(\chi\) treated axiomatically.

```lean
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.Complex.Basic
import Mathlib.Data.Complex.Exponential
import Mathlib.Algebra.BigOperators.Basic

open scoped BigOperators
open Complex

def dirichletTrunc (N : ℕ) (s : ℂ) : ℂ :=
  ∑ n in Finset.Icc 1 N, Complex.exp (-s * Complex.log n)

def dualDirichletTrunc (N : ℕ) (s : ℂ) : ℂ :=
  ∑ n in Finset.Icc 1 N, Complex.exp ((s - 1) * Complex.log n)

def symTrunc
    (χ : ℂ → ℂ) (N : ℕ) (s : ℂ) : ℂ :=
  dirichletTrunc N s + χ s * dualDirichletTrunc N s

theorem symTrunc_functional_symmetry
    (χ : ℂ → ℂ)
    (hχ : ∀ s : ℂ, χ s * χ (1 - s) = 1) :
    ∀ s : ℂ, symTrunc χ N (1 - s) = χ (1 - s) * symTrunc χ N s := by
  sorry

theorem symTrunc_zero_reflection
    (χ : ℂ → ℂ)
    (hχ : ∀ s : ℂ, χ s * χ (1 - s) = 1) :
    ∀ s : ℂ, symTrunc χ N s = 0 → symTrunc χ N (1 - s) = 0 := by
  sorry
```

You may need a more robust implementation of \(n^{-s}\) as `Complex.exp (-s * Complex.log (n : ℂ))`, with lemmas specialized to positive naturals.

### Why this is a breakthrough
This theorem is not deep analytically, but it is foundational scientifically: it gives a **machine-checked symmetry certificate** for every finite truncation, which is the exact finite analogue of the zeta functional equation. Every subsequent root-location theorem should be formulated as an enhancement of this symmetry: reflection invariance, then self-inversiveness, then spectral realization.

### Proof strategy options
**Strategy A: Direct algebraic expansion.**
1. Expand `symTrunc χ N (1 - s)`.
2. Rewrite the two sums using the identities \(n^{-(1-s)} = n^{s-1}\) and \(n^{(1-s)-1}=n^{-s}\).
3. Use `hχ` to replace \(\chi(1-s)\chi(s)\) by \(1\).

**Strategy B: Prove a general involutive template.**
1. Define a pair of functions \(A(s), B(s)\) with \(A(1-s)=B(s)\), \(B(1-s)=A(s)\).
2. Prove generally that \(F(s)=A(s)+\chi(s)B(s)\) satisfies \(F(1-s)=\chi(1-s)F(s)\) whenever \(\chi(s)\chi(1-s)=1\).
3. Instantiate with truncated Dirichlet sums.

**Strategy C: Bundle symmetry as a semilinear operator.**
1. Define the reflection operator \(R(f)(s)=f(1-s)\).
2. Show the truncated pair spans a 2-dimensional \(R\)-stable space.
3. Show `symTrunc` is an eigenvector up to multiplier \(\chi(1-s)\).

**Most promising:** Strategy B. It creates a reusable formal lemma for all future “approximate functional equation” objects, not just this truncation.

### Cross-domain connections
- **Automorphic forms:** finite model of functional-equation symmetry.
- **Operator theory:** involutive symmetry on a two-dimensional coefficient space.
- **Quantum mechanics:** reflection symmetry as a finite-dimensional parity analogue.
- **Certified numerics:** exact symmetry drastically reduces search space for zeros.

### Application keywords
`functional equation`, `critical line symmetry`, `Dirichlet truncation`, `zero reflection`, `Lean spectral certificates`, `finite Hilbert–Pólya`

---

## Target Theorem 2: Self-Inversive Reduction of Critical-Line Questions

The real breakthrough is to push the symmetry into a **self-inversive polynomial statement** after a conformal change of variables. This turns analytic zero questions into algebraic root-pairing questions.

### Precise theorem statement
Let \(P\) be a polynomial over \(\mathbb C\). Suppose
\[
P(z) = \omega z^d \overline{P(1/\overline z)}
\quad\text{for all } z\neq 0,
\]
with \(|\omega|=1\). Then the roots of \(P\) are invariant under the map
\[
z \mapsto \frac{1}{\overline z}.
\]
Equivalently, if \(P(z)=0\) and \(z\neq 0\), then \(P(1/\overline z)=0\).

This theorem is already mathematically standard, but in your program it should be the algebraic engine connecting critical-line symmetry to unit-circle root location after a Möbius transform.

### Lean 4 type signature target
If catalog already contains something like `self_inversive_root_pairing`, strengthen and repackage it into a reusable theorem with explicit root transport.

```lean
import Mathlib.Data.Polynomial.Basic
import Mathlib.Data.Polynomial.Eval
import Mathlib.Analysis.Complex.Polynomial

open Polynomial ComplexConjugate

def IsSelfInversive (P : Polynomial ℂ) : Prop :=
  ∃ (d : ℕ) (ω : ℂ), Complex.abs ω = 1 ∧
    ∀ z : ℂ, z ≠ 0 →
      Polynomial.eval z P =
        ω * z^d * Complex.conj (Polynomial.eval (1 / Complex.conj z) P)

theorem selfInversive_root_pairing
    {P : Polynomial ℂ}
    (hP : IsSelfInversive P) :
    ∀ {z : ℂ}, z ≠ 0 → Polynomial.eval z P = 0 →
      Polynomial.eval (1 / Complex.conj z) P = 0 := by
  sorry
```

A stronger finite-set statement on `P.roots` would be even better if multiplicities are manageable.

### Why this is a breakthrough
This is the exact bridge from analytic number theory to algebraic/spectral geometry. Once certified, it lets you turn “critical-line roots” into “unit-circle roots after transport,” and then invoke the rich theory of paraunitary, self-inversive, and Hermitian-generated polynomials. This is the point where the zeta truncation project stops being a numerical curiosity and becomes a finite-dimensional spectral program.

### Proof strategy options
**Strategy A: Direct evaluation at reciprocal conjugates.**
1. Start from the defining identity at \(z\).
2. If `eval z P = 0`, conclude the RHS vanishes.
3. Use \(|\omega|=1\) and \(z\neq 0\) to divide by the nonzero prefactor and conclude \(\overline{P(1/\bar z)}=0\), hence `eval (1 / conj z) P = 0`.

**Strategy B: Reverse-polynomial formalism.**
1. Define the reversed-conjugated polynomial \(P^\sharp(z)=z^d \overline{P(1/\bar z)}\).
2. Show self-inversiveness is `P = C ω * P^\sharp`.
3. Use standard root-transfer lemmas for reverse polynomials.

**Strategy C: Root multiset argument.**
1. Factor \(P\) over \(\mathbb C\).
2. Apply the self-inversive relation to the factorization.
3. Compare root multisets under reciprocal-conjugation.

**Most promising:** Strategy B, because it interfaces best with Mathlib polynomial APIs and can later support multiplicity statements.

### Cross-domain connections
- **Control theory:** self-inversive polynomials are discrete-time stability boundaries.
- **Signal processing:** paraunitary / reciprocal filters.
- **Random matrix theory:** unit-circle and symmetry constraints on spectra.
- **Algebraic geometry:** involution on \(\mathbb P^1\) via \(z \mapsto 1/\bar z\).

### Application keywords
`self-inversive polynomial`, `unit-circle roots`, `Möbius transform`, `critical-line transport`, `reciprocal conjugation`, `formal root pairing`

---

## Target Theorem 3: Hermitian Characteristic Polynomials Have Real Roots, Hence Unit-Circle/Line Certificates After Transport

Hypothesis 2 needs a theorem that is fully formalizable and genuinely useful: if your finite arithmetic matrix is Hermitian, then its characteristic polynomial has real roots; after Cayley transport this becomes a unit-circle statement.

### Precise theorem statement
Let \(H \in M_n(\mathbb C)\) be Hermitian. Then every root of its characteristic polynomial is real:
\[
\forall \lambda \in \mathbb C,\quad \det(\lambda I - H)=0 \implies \lambda \in \mathbb R.
\]
Equivalently, the spectrum of a Hermitian matrix is contained in \(\mathbb R\).

A second transport theorem:
under the Cayley transform
\[
z = \frac{\lambda - i}{\lambda + i},
\]
real \(\lambda\) map to \(|z|=1\), \(z\neq -1\). Thus Hermitian spectra yield self-inversive/unit-circle zero sets after transport.

### Lean 4 type signature target
Mathlib likely already contains spectral theorems for Hermitian matrices; your task is to package them into a bridge theorem usable by arithmetic matrix constructions.

```lean
import Mathlib.LinearAlgebra.Matrix.Hermitian
import Mathlib/LinearAlgebra/Matrix/Charpoly/Basic
import Mathlib/Analysis/Complex/Basic

open Matrix

theorem charpoly_root_real_of_isHermitian
    {n : Type*} [Fintype n] [DecidableEq n]
    (H : Matrix n n ℂ) (hH : IsHermitian H) :
    ∀ {λ : ℂ}, Polynomial.eval λ H.charpoly = 0 → λ.im = 0 := by
  sorry

theorem cayley_of_real_on_unit_circle
    {λ : ℂ} (hλ : λ.im = 0) (hneq : λ ≠ -Complex.I) :
    Complex.abs ((λ - Complex.I) / (λ + Complex.I)) = 1 := by
  sorry
```

If `Polynomial.eval λ H.charpoly = 0` is not the right root API, use `IsRoot H.charpoly λ`.

### Why this is a breakthrough
This is the **spectral bridge infrastructure** needed to turn arithmetic constructions into critical-line surrogates. The philosophical statement becomes formal mathematics:

Hermitian arithmetic matrix  
\(\Rightarrow\) real spectrum  
\(\Rightarrow\) unit-circle zeros after Cayley transform  
\(\Rightarrow\) critical-line candidates after inverse Möbius transport.

That is a machine-verifiable finite Hilbert–Pólya mechanism.

### Proof strategy options
**Strategy A: Use existing spectral theorem infrastructure.**
1. Invoke Mathlib’s theorem that eigenvalues of Hermitian matrices are real.
2. Connect eigenvalues to roots of the characteristic polynomial.
3. Package the result into a theorem tailored for arithmetic matrix families.

**Strategy B: Quadratic form proof.**
1. Let \(Hv=\lambda v\), \(v\neq 0\).
2. Compare \(\langle Hv,v\rangle\) and \(\langle v,Hv\rangle\).
3. Deduce \(\lambda=\bar\lambda\), hence \(\lambda\in\mathbb R\).

**Strategy C: Normality + Schur decomposition.**
1. Hermitian implies normal.
2. Unitary triangularization gives diagonal form.
3. Hermitian condition forces diagonal entries real.

**Most promising:** Strategy A if the library supports it; otherwise Strategy B is short and elegant.

### Cross-domain connections
- **Hilbert–Pólya:** explicit finite-dimensional realization mechanism.
- **Quantum mechanics:** Hermitian operators as observables with real spectra.
- **Numerical linear algebra:** stable eigenvalue certification.
- **Arithmetic combinatorics:** matrices from prime-weighted graphs.

### Application keywords
`Hermitian matrix`, `characteristic polynomial`, `real spectrum`, `Cayley transform`, `Hilbert–Pólya`, `arithmetic spectral model`

---

## Target Theorem 4: A Formal Nonexistence/Constraint Result for Naive Arithmetic Matrix Models

Do not only chase positive statements. If Hypothesis 2 is too optimistic, clear the dead end with a sharp impossibility theorem. This is scientifically valuable.

### Candidate counterexample theorem
For the matrix family
\[
(H_N)_{p,q} = \frac{\log(pq)}{\sqrt{pq}}
\quad (p,q \le N \text{ prime}),
\]
show that \(H_N\) has rank at most \(2\), because
\[
\log(pq)=\log p + \log q.
\]
Hence
\[
(H_N)_{p,q} = \frac{\log p}{\sqrt p}\frac{1}{\sqrt q} + \frac{1}{\sqrt p}\frac{\log q}{\sqrt q},
\]
so \(H_N = u v^\top + v u^\top\), rank \(\le 2\). Therefore its characteristic polynomial cannot approximate generic high-degree zeta-truncation coefficient structure except in a severely degenerate sense.

This is exactly the kind of dead-end-clearing theorem that prevents wasted cycles.

### Lean 4 type signature target
```lean
import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.Data.Real.Basic

theorem primeLogMatrix_rank_le_two
    (N : ℕ) :
    Matrix.rank (fun p q => ((Real.log p + Real.log q) / Real.sqrt (p * q : ℝ))) ≤ 2 := by
  sorry
```

You may need to formalize over an arbitrary finite index type first, not literally primes. The right abstract theorem is:

```lean
theorem rank_add_outer_le_two
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (u v : ι → ℝ) :
    Matrix.rank (Matrix.of fun i j => u i * v j + v i * u j) ≤ 2 := by
  sorry
```

Then instantiate with prime-indexed vectors.

### Why this is a breakthrough
A negative theorem here is not a retreat — it is a purification of the program. It shows that a seemingly arithmetic-rich construction is spectrally too low-rank to encode zeta complexity. That kind of theorem sharply redirects the Hilbert–Pólya search toward genuinely nondegenerate arithmetic kernels.

### Proof strategy options
**Strategy A: Outer-product decomposition.**
1. Rewrite the matrix as `u ⬝ vᵀ + v ⬝ uᵀ`.
2. Use rank bounds for outer products.
3. Conclude rank ≤ 2 by subadditivity.

**Strategy B: Column-space dimension bound.**
1. Show every column lies in `span {u, v}`.
2. Hence column space has dimension at most 2.
3. Convert to rank bound.

**Strategy C: Factorization through ℝ².**
1. Build matrices \(A : \iota \to \mathbb R^2\), \(B : \mathbb R^2 \to \iota\).
2. Show \(H = AB\).
3. Infer rank ≤ 2.

**Most promising:** Strategy A, if Mathlib has the right outer-product rank lemmas; otherwise Strategy B is very robust.

### Cross-domain connections
- **Compressed sensing:** low-rank obstruction.
- **Kernel methods:** degenerate kernels versus expressive kernels.
- **Arithmetic graph theory:** naive prime kernels may be spectrally trivial.
- **Scientific method:** formal counterexamples as research accelerators.

### Application keywords
`low-rank obstruction`, `prime kernel`, `spectral degeneracy`, `counterexample theorem`, `arithmetic matrices`, `formal rank bound`

---

## Target Theorem 5: Critical-Line Fixed Points Correspond to Unit-Circle Fixed Modulus Under Möbius Transport

Hypothesis 3 needs a clean, exact bridge theorem.

### Precise theorem statement
Let
\[
\phi(s)=\frac{s-\tfrac12}{s+\tfrac12}
\quad\text{or}\quad
\psi(s)=\frac{s-\tfrac12}{s-\tfrac12+i},
\]
or another chosen Möbius transform sending the vertical line \(\Re(s)=1/2\) to the unit circle. Prove:
\[
\Re(s)=\frac12 \iff |\phi(s)|=1
\]
for all \(s\) away from the pole of \(\phi\).

This should be made exact with the chosen transform. It gives the geometric transport needed to interpret critical-line root questions as unit-circle root questions.

### Lean 4 type signature target
```lean
import Mathlib.Analysis.Complex.Basic

def criticalLineMap (s : ℂ) : ℂ :=
  (s - (1 / 2 : ℂ)) / (s + (1 / 2 : ℂ))

theorem criticalLine_iff_unitCircle
    {s : ℂ} (h : s ≠ -(1 / 2 : ℂ)) :
    s.re = 1 / 2 ↔ Complex.abs (criticalLineMap s) = 1 := by
  sorry
```

You may prefer a transform with cleaner algebra. Choose the one that gives the strongest exact theorem and easiest formal proof.

### Why this is a breakthrough
This theorem is the geometric Rosetta stone of the whole program: it translates the Riemann-style critical-line problem into a self-inversive/unit-circle problem, where finite-dimensional algebra and spectral theory are strongest.

### Proof strategy options
**Strategy A: direct complex algebra.**
1. Write \(s = \sigma + it\).
2. Compute numerator and denominator moduli explicitly.
3. Show equality of moduli is equivalent to \(\sigma=1/2\).

**Strategy B: use general Möbius geometry.**
1. Prove vertical lines and circles are generalized circles in \(\widehat{\mathbb C}\).
2. Show the chosen transform sends the critical line to the unit circle by checking three points.
3. Extract the exact iff statement.

**Strategy C: matrix action of \(PSL_2(\mathbb C)\).**
1. Represent the Möbius transform by a 2×2 matrix.
2. Use preservation of generalized circles.
3. Specialize to the critical line.

**Most promising:** Strategy A for Lean formalization; Strategy B for conceptual exposition.

### Cross-domain connections
- **Complex geometry:** generalized circles under Möbius maps.
- **Scattering theory:** boundary transforms between lines and circles.
- **Signal processing:** frequency boundary as unit circle.
- **Analytic number theory:** critical line becomes a spectral boundary.

### Application keywords
`Möbius transform`, `critical line`, `unit circle`, `complex geometry`, `root transport`, `formal equivalence`

---

## Synthesis Goal: A Finite Hilbert–Pólya Blueprint

The truly field-opening theorem would combine the above ingredients into a single formal statement of the following shape:

### Grand theorem blueprint
For a family of finite objects \(F_N\) satisfying:
1. an exact reflection/functional-equation symmetry,
2. a Möbius transport to self-inversive polynomial form,
3. and a Hermitian spectral realization,

their zero sets are forced into reflection-symmetric or unit-circle-symmetric configurations, and in the spectrally realized case they lie exactly on the transported critical boundary.

This would be a formal finite-dimensional prototype of Hilbert–Pólya:
not the infinite zeta operator itself, but a rigorously certified tower of finite surrogates.

A Lean-facing abstract theorem might look like:

```lean
theorem finite_HP_bridge
    (P : Polynomial ℂ)
    (hself : IsSelfInversive P)
    (hchar : ∃ (n : Type) (_ : Fintype n) (_ : DecidableEq n)
      (H : Matrix n n ℂ), IsHermitian H ∧
      P = cayleyTransformCharpoly H) :
    ∀ z : ℂ, Polynomial.eval z P = 0 → Complex.abs z = 1 := by
  sorry
```

Even if this exact theorem is too ambitious for one cycle, build toward it modularly.

---

## Build on Catalog Theorems

You explicitly mentioned a catalog theorem `self_inversive_root_pairing`. Do not merely reuse it; strengthen it in one of these directions:
1. **Multiplicity-aware version:** reciprocal-conjugate symmetry preserves root multiplicity.
2. **Unit-circle criterion:** under additional coefficient sign/positivity assumptions, all roots lie on the unit circle.
3. **Transport theorem:** package self-inversiveness plus Möbius transform into a direct critical-line statement.
4. **Spectral instantiation:** show characteristic polynomials of certain structured matrices are self-inversive after Cayley transform.

If the catalog already contains spectral bridge infrastructure, use it to prove the Hermitian-to-unit-circle theorem above as a direct corollary. If it contains certified root bounds, combine them with self-inversive pairing to reduce search domains by half.

---

## Recommended execution order

1. **Formalize and prove the abstract functional symmetry theorem** for `symTrunc`.
2. **Formalize the Möbius critical-line ↔ unit-circle equivalence**.
3. **Strengthen `self_inversive_root_pairing`** into a transport-ready theorem.
4. **Prove the Hermitian charpoly real-root theorem packaging**.
5. **Either**
   - construct a nontrivial arithmetic Hermitian family and prove exact spectral constraints, or
   - prove the low-rank obstruction for the naive prime-log kernel and kill the bad conjecture cleanly.

This order maximizes theorem reuse and minimizes sorry.

---

## Scientific significance

If successful, this work opens a new field: **machine-verified finite analytic-spectral number theory**. The point is not just proving isolated lemmas in Lean. The point is to create a certified architecture where
- analytic functional equations,
- algebraic self-inversiveness,
- Möbius geometry,
- and Hermitian spectral theory

interlock into a coherent finite model of zeta zero phenomena.

That architecture would enable:
- certified numerical exploration of RH surrogates,
- formal elimination of degenerate Hilbert–Pólya candidates,
- arithmetic matrix design guided by theorem rather than intuition,
- and eventually a library of “critical-boundary forcing mechanisms” applicable beyond zeta, e.g. \(L\)-functions, period polynomials, and automorphic truncations.

This is not an incremental extension. It is a blueprint for making RH-adjacent experimentation mathematically auditable.

---

## FUTURE_DIRECTIONS.md requirement

Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 falsifiable scientific hypotheses**, each including:
- exact conjectural statement,
- finite computational test,
- expected obstruction/failure mode,
- and which formal theorem would certify or refute it.

At minimum include hypotheses of the following form:

1. **Nondegenerate arithmetic kernel hypothesis.**  
   There exists an explicit prime-indexed Hermitian kernel \(K_N\) with rank growing at least \(c \pi(N)\) and with Cayley-transformed charpoly roots all on the unit circle.

2. **Transport exactness hypothesis.**  
   For low-degree symmetrized Dirichlet truncations, Möbius-transported polynomials are exactly self-inversive after a computable normalization factor.

3. **Failure-of-naive-kernel hypothesis.**  
   The prime-log kernel family is universally low-rank and cannot match more than \(O(1)\) independent coefficients of zeta truncation models.

4. **Critical-line certification hypothesis.**  
   Every formally self-inversive truncation polynomial of degree \(\le 20\) arising from the chosen zeta model has all roots on the unit circle if and only if an associated Hermitian witness matrix exists.

5. **Approximate functional equation rigidity hypothesis.**  
   Any finite truncation model satisfying exact reflection symmetry and bounded coefficient distortion from a Hermitian-induced self-inversive polynomial has zero sets within explicit distance of the critical line.

Each hypothesis must be testable and refutable, not aspirational.

Go build the finite Hilbert–Pólya machine.

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

Research domain: Speculative
Research mode: prove
