
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Quantum Key Distribution: BB84 Security Proof
**Domain**: Cryptography
**Mathematical framing**: Formalize the BB84 protocol and prove its unconditional security against arbitrary quantum attacks. Show that the quantum bit error rate threshold for secure key distillation is approximately 11%. Prove that privacy amplification via universal hashing reduces Eve's information to exponentially small.
Research domain: Cryptography
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/SpectralFingerprints.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Spectral Fingerprints for Classical Subgroups

This file develops the theory of spectral fingerprints — characteristic polynomial
statistics that distinguish classical matrix groups over finite fields. The central
result is that the characteristic polynomial of a matrix encodes the ambient symmetry
group's type through its algebraic structure.

## Main Definitions

* `Polynomial.IsSelfReciprocal`: A polynomial whose coefficient sequence is palindromic.
* `SpectralProfile`: Structure recording irreducible, split, and self-reciprocal rates.
* `ClassicalGroupFamily`: Enumeration of classical group families (GL, SL, Sp, O).
* `SpectralFingerprint`: Extended fingerprint with group type and spectral profile.
* `irreducibleRateGL2`: Theoretical irreducible rate for GL_2(𝔽_q).
* `irreducibleRateSL2`: Theoretical irreducible rate for SL_2(𝔽_q).

## Main Results

* `sl_charpoly_constant_term`: The constant term of charpoly(A) for A ∈ SL_n equals (-1)^n.
* `self_reciprocal_reverse`: Self-reciprocal polynomials equal their reversal.
* `self_reciprocal_coeff_palindrome`: Coefficient palindromy characterization.
* `sl2_gl2_rate_separation`: GL_2 and SL_2 have distinct irreducible rates for primes q ≥ 3.
* `self_reciprocal_iff_positive_sign`: Connection between self-reciprocity and
  functional equation signs (cross-domain bridge to number theory).

## Cross-Domain Connections

- **Number Theory**: Self-reciprocal polynomials are the polynomial analogue of
  L-functions satisfying a functional equation with sign ε = +1.
- **Random Matrix Theory**: Finite-field analogue of Wigner's GOE/GUE/GSE classification.
- **Coding Theory**: Self-reciprocal polynomials generate self-dual cyclic codes.

## References

* Fulman, J. (1999). A probabilistic approach to conjugacy classes in the finite
  symplectic and orthogonal groups.
* Katz, N., Sarnak, P. (1999). Random Matrices, Frobenius Eigenvalues, and Monodromy.
-/

import Mathlib

open Polynomial Matrix Finset

/-! ## Novel Definition: Self-Reciprocal Polynomials -/

/-- A polynomial `f` is self-reciprocal if it equals its own reversal.
This means the coefficient sequence is palindromic: `coeff i = coeff (natDegree - i)`
for all `i ≤ natDegree`.

Self-reciprocal polynomials arise naturally as characteristic polynomials of
symplectic matrices, and are the polynomial analogue of L-functions satisfying
a functional equation with sign ε = +1. -/
def Polynomial.IsSelfReciprocal {R : Type*} [Semiring R] (f : R[X]) : Prop :=
  ∀ i : ℕ, f.coeff i = f.coeff (f.natDegree - i)

/-- The classical group families over finite fields, distinguished by their
spectral fingerprints. This enumeration captures the finite-field analogue
of Wigner's classification of random matrix ensembles. -/
inductive ClassicalGroupFamily where
  | GL : ClassicalGroupFamily  -- General linear group
  | SL : ClassicalGroupFamily  -- Special linear group
  | Sp : ClassicalGroupFamily  -- Symplectic group
  | Orth : ClassicalGroupFamily  -- Orthogonal group
  deriving DecidableEq, Repr

/-- A spectral profile records the key characteristic polynomial statistics
that distinguish classical group families. These rates are the finite-field
analogues of eigenvalue spacing statistics in random matrix theory. -/
structure SpectralProfile where
  /-- Fraction of elements with irreducible characteristic polynomial -/
  irreducibleRate : ℚ
  /-- Fraction of elements whose charpoly splits completely -/
  splitRate : ℚ
  /-- Fraction of elements with self-reciprocal charpoly -/
  selfReciprocalRate : ℚ
  /-- Rates are non-negative -/
  irred_nonneg : 0 ≤ irreducibleRate
  split_nonneg : 0 ≤ splitRate
  selfRecip_nonneg : 0 ≤ selfReciprocalRate

/-- A spectral fingerprint extends the characteristic polynomial fingerprint
with a group type classification and spectral profile. This is the data
structure for computational group recognition. -/
structure SpectralFingerprint where
  /-- Matrix dimension -/
  dim : ℕ
  /-- Field size -/
  fieldSize : ℕ
  /-- Identified group family -/
  groupType : ClassicalGroupFamily
  /-- Observed spectral profile -/
  profile : SpectralProfile

/-! ## Theorem 2: SL_n Characteristic Polynomial Constant Term -/

/-
**Constant term constraint for SL_n**: If A ∈ SL_n(R), then the constant term
of its characteristic polynomial equals (-1)^n. This is because the constant term
of det(xI - A) is det(-A) = (-1)^n · det(A) = (-1)^n, since det(A) = 1 in SL_n.

This constraint restricts the polynomial space by a factor of (1 - 1/q) compared
to GL_n, and is the simplest spectral fingerprint distinguishing SL from GL.
-/
theorem sl_charpoly_constant_term
    {R : Type*} [CommRing R]
    {n : Type*} [DecidableEq n] [Fintype n]
    (A : Matrix n n R)
    (hA : A.det = 1) :
    A.charpoly.coeff 0 = (-1 : R) ^ Fintype.card n := by
  rw [ Matrix.det_eq_sign_charpoly_coeff ] at hA;
  by_cases h : Even ( Fintype.card n ) <;> simp_all +decide;
  exact neg_eq_iff_eq_neg.mp hA

/-! ## Properties of Self-Reciprocal Polynomials -/

/-
The zero polynomial is self-reciprocal (its coefficient sequence is trivially palindromic).
-/
theorem self_reciprocal_zero (R : Type*) [Semiring R] : (0 : R[X]).IsSelfReciprocal := by
  exact fun _ => rfl

/-
The self-reciprocal property implies the constant term equals the leading coefficient.
-/
theorem self_reciprocal_constant_eq_leading {R : Type*} [Semiring R] (f : R[X])
    (hf : f.IsSelfReciprocal) : f.coeff 0 = f.leadingCoeff := by
  rw [ Polynomial.leadingCoeff, hf ];
  rfl

/-
For a monic self-reciprocal polynomial, the constant term is 1.
-/
theorem self_reciprocal_monic_constant_one {R : Type*} [Semiring R] (f : R[X])
    (hf : f.IsSelfReciprocal) (hm : f.Monic) : f.coeff 0 = 1 := by
  convert self_reciprocal_constant_eq_leading f hf using 1;
  exact hm.symm

/-
Self-reciprocity implies coefficient symmetry for valid indices.
-/
theorem self_reciprocal_coeff_symm {R : Type*} [Semiring R] (f : R[X])
    (hf : f.IsSelfReciprocal) (i : ℕ) (hi : i ≤ f.natDegree) :
    f.coeff i = f.coeff (f.natDegree - i) := by
  exact hf i

/-! ## Theoretical Irreducible Rates -/

/-- The theoretical irreducible rate for GL_2(𝔽_q): the fraction of elements
whose characteristic polynomial is irreducible over 𝔽_q.

For GL_2(𝔽_q), this equals q / (2(q+1)), derived from conjugacy class counting:
- Number of irreducible monic polynomials of degree 2 over 𝔽_q: q(q-1)/2
- Centralizer of an element with irreducible charpoly: ≅ 𝔽_{q²}^*, order q²-1
- Count: q²(q-1)² / 2, giving rate q / (2(q+1)). -/
noncomputable def irreducibleRateGL2 (q : ℕ) : ℚ :=
  (q : ℚ) / (2 * ((q : ℚ) + 1))

/-- The theoretical irreducible rate for SL_2(𝔽_q) for odd q:
(q-1) / (2q), derived from the additional constraint that the constant
term must equal 1 (i.e., det = 1). -/
noncomputable def irreducibleRateSL2 (q : ℕ) : ℚ :=
  ((q : ℚ) - 1) / (2 * (q : ℚ))

/-! ## Theorem 3: Separation of GL_2 and SL_2 Irreducible Rates -/

/-
**Key algebraic lemma**: q² ≠ q² - 1 for any natural number, which is the
core of the separation between GL_2 and SL_2 irreducible rates.
-/
theorem sq_ne_sq_sub_one (q : ℕ) (hq : 1 ≤ q) : (q : ℤ) ^ 2 ≠ (q : ℤ) ^ 2 - 1 := by
  grobner

/-
**Separation theorem**: For any prime q ≥ 3, the irreducible rates of GL_2(𝔽_q)
and SL_2(𝔽_q) are distinct. This is the simplest instance of the spectral
fingerprint separation phenomenon.

The proof reduces to showing q/(2(q+1)) ≠ (q-1)/(2q), which after cross-multiplying
becomes q² ≠ (q-1)(q+1) = q²-1, a strict inequality for all q.
-/
theorem sl2_gl2_rate_separation (q : ℕ) (hq : 3 ≤ q) :
    irreducibleRateGL2 q ≠ irreducibleRateSL2 q := by
  unfold irreducibleRateGL2 irreducibleRateSL2; rcases q with ( _ | _ | q ) <;> norm_num at *;
  rw [ div_eq_div_iff ] <;> ring <;> nlinarith

/-
The irreducible rate for GL_2 is strictly greater than f
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: BB84 Security Mathematics

The file `BB84Security.lean` formalizes the analytic core of the BB84 security
proof: the binary entropy function `h`, the Devetak–Winter secret-key rate
`r(Q) = 1 − 2h(Q)`, the *existence* of the ≈ 11 % QBER threshold (the zero of `r`
in `(0, 1/2)`), and the exponential decay of the leftover-hash privacy-amplification
bound. The results below are the natural next layer of theorems. Each is
falsifiable: it is stated as a precise Lean proposition that either compiles or
does not.

## 1. Uniqueness of the threshold and the sharp ≈ 0.1100 enclosure

Right now `qber_threshold_exists` gives *a* zero of `r` in `(0, 1/2)`. The next
step is to prove the threshold is **unique** and to **pin its value** to a tight
rational interval, e.g. `p* ∈ (0.1100, 0.1101)`. Uniqueness follows from strict
monotonicity of `r` on `(0, 1/2)`: since `h` is strictly increasing there, `r`
is strictly decreasing, so it crosses `0` exactly once.

The key insight is that strict monotonicity of `h` on `(0, 1/2)` reduces to the
sign of `h'(p) = log₂((1−p)/p)`, which is positive precisely when `p < 1/2`; this
turns a geometric "crossing once" statement into a one-line derivative-sign
computation. Why now? The current file already establishes continuity and the two
bracketing signs; adding `Real.deriv` of `binEntropy` (Mathlib has `Real.deriv_log`)
and `StrictMonoOn` is the only missing ingredient, so uniqueness is within immediate
reach.

## 2. Concavity of binary entropy and the data-processing inequality

Prove `h` is **concave** on `[0,1]` (`ConcaveOn ℝ (Icc 0 1) binEntropy`) and
deduce that the key rate `r` is **convex**, hence that mixing two error rates can
only help an eavesdropper. Concavity is the engine behind essentially every
entropy inequality used in QKD security (Holevo bound, data processing).

The key insight is that concavity of `h` is exactly nonpositivity of its second
derivative `h''(p) = −1/(p(1−p) ln 2) ≤ 0`, so the whole qualitative theory of
entropy bounds collapses to a single elementary inequality on `(0,1)`. Why now?
Mathlib's `InnerLeOuter`/`ConcaveOn` API plus `Real.deriv_logb` make the
second-derivative test mechanical, and concavity immediately upgrades several of
our pointwise facts (e.g. `h ≤ 1`) to global ones.

## 3. Finite-key security: the leftover-hash bound with explicit parameters

Our `leftoverDistance gap = ½·2^(−gap/2)` is the asymptotic form. The falsifiable
refinement is the **finite-`n` Tomamichel–Renner** statement: for a string of
smooth min-entropy `H_min^ε` and output length `ℓ`, the trace distance from
uniform is `≤ ε + ½·2^(−(H_min^ε − ℓ)/2)`, and choosing `ℓ = ⌊H_min^ε − 2 log(1/ε)⌋`
makes the total `≤ 2ε`.

The key insight is that the entire finite-key rate is governed by a single
"extractable randomness" quantity `H_min − ℓ`, so security with a *concrete* block
length `n` becomes an explicit inequality between integers and a logarithm rather
than a limit. Why now? We have alread
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
