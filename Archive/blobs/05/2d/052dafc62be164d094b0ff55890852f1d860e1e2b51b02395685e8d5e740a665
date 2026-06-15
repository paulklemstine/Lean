
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

**Title**: The current formalization defines the Veblen hierarchy at finite levels `veblenN
**Domain**: Logic
**Mathematical framing**: # Future Directions: Ordinal Analysis Across Systems

## 1. Full Transfinite Veblen Hierarchy

The current formalization defines the Veblen hierarchy at finite levels `veblenN : ℕ → (Ordinal → Ordinal)` by iterating `Ordinal.deriv`. The natural next step is extending this to transfinite levels using ordinal-indexed recursion: define `veblen : Ordinal → Ordinal → Ordinal` where `veblen α` for limit `α` enumerates the common fixed points of all `veblen β` for `β < α`.

The key insight is that Mathlib's `Ordinal.deriv` already handles the successor case perfectly, so the challenge reduces to formalizing the limit case using `Ordinal.nfp` over a family indexed by ordinals below `α`.

Why now? Mathlib's ordinal fixed-point infrastructure (`deriv`, `nfp`, `derivFamily`) is mature enough to support this. The missing piece is a clean transfinite recursion scheme for function-valued ordinal families, which could be built using `Ordinal.rec` or well-founded recursion on ordinals.

## 2. Semantic Interpretation of BHOrd and Correctness of ψ

The `BHOrd` notation system defines ordinal terms syntactically but lacks a semantic interpretation function `BHOrd → Ordinal`. The conjecture is that one can define a partial interpretation function `interp : BHOrd → Option Ordinal` such that for all well-formed terms `t`, `interp t` agrees with the standard ordinal it represents, and moreover `interp (psi zero) = Some epsilon0` where `epsilon0` is our formalized ε₀.

The key insight is that the interpretation of `psi` requires defining the collapsing set `C(α)` as a well-founded inductive-recursive definition, not just the approximation sequence we currently have. The full `collapsingSet` needs to be shown to be closed under the required operations, and the minimum ordinal not in `collapsingSet α` gives `ψ(α)`.

Why now? We have both the syntactic system (`BHOrd`) and the semantic foundation (`collapsingApprox`, `collapsingSet`) formalized. Connecting them is the natural bridge theorem.

## 3. Proof-Theoretic Strength Separation: PA vs. KP

The central claim of ordinal analysis is that ε₀ is the proof-theoretic ordinal of PA while ψ(Ω^ω) is that of KP (Kripke-Platek set theory). A formalization of this would involve: (a) defining a notion of "provably well-ordered" for a formal system, (b) showing that PA proves the well-ordering of all ordinal notations below ε₀, and (c) showing PA cannot prove the well-ordering of ε₀ itself.

The key insight is that (b) can be formalized as a meta-theorem about derivability in PA, using Gödel numbering of ordinal terms. The hard part is (c), which requires formalizing Gentzen's consistency proof or its modern refinements.

Why now? Lean 4 has increasingly good support for meta-programming and proof reflection. The `ONote` type in Mathlib already provides ordinal notations below ε₀ with decidable ordering, which is exactly the structure needed for encoding "provably well-ordered" statements.

## 4. Ordinal Notation Comparison and Normal Forms

Our `BHOrd` type permits non-normal-form terms (e.g., `add (add one one) one` vs. `add one (add one one)`). A decidable comparison function `BHOrd.compare : BHOrd → BHOrd → Ordering` that respects ordinal semantics would require defining Cantor Normal Form for the extended system and proving that every term has a unique normal form.

The key insight is that comparison of `psi` terms reduces to comparison of their arguments when the arguments are in normal form, making the recursion well-founded on term size. This is essentially the Bachmann property: ψ is order-preserving on its domain.

Why now? The `termSize` function and `isSmall`/`psiDepth` predicates we defined provide the structural foundation for well-founded recursion on BHOrd terms. The comparison algorithm is well-documented in Buchholz's work on ordinal notation systems.

## 5. Automated Ordinal Bounds for Recursive Programs

A long-term application: given a structurally recursive function in Lean 4, automatically compute an ordinal bound on its computational complexity (in the sense of the slow-growing hierarchy). The Veblen hierarchy provides natural complexity classes: functions below ε₀ correspond to primitive recursive functions, those below Γ₀ to predicative functions.

The key insight is that Lean 4's termination checker already computes a well-founded relation for recursive functions. Mapping these relations to ordinal notations in our `BHOrd` system would give automatic complexity bounds, connecting proof-theoretic ordinal analysis to practical program analysis.

Why now? The formalized Veblen hierarchy provides the semantic foundation, and Lean 4's elaboration and meta-programming infrastructure makes it feasible to inspect termination proofs programmatically. The `veblenN_succ_fixedPoint` theorem ensures the hierarchy is coherent across levels.

Research domain: Logic
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
# Future Directions: From the Finite Veblen Tower to Full Ordinal Analysis

The module `Catalog/Logic/VeblenHierarchy.lean` builds the finite-level Veblen
hierarchy `veblenN : ℕ → Ordinal → Ordinal` by iterating Mathlib's fixed-point
enumerator `Ordinal.deriv`, and proves that this tower is *coherent*: every level
is normal, each level-`n+1` value is a fixed point of level `n`, the tower is
monotone (and strictly separating away from fixed points) in the level, and the
least level-`1` fixed point `epsilon0` genuinely satisfies `ω ^ ε₀ = ε₀` with
`ω ≤ ε₀`. The following conjectures extend this verified core.

## 1. The Two-Argument (Transfinite) Veblen Function `φ : Ordinal → Ordinal → Ordinal`

Our `veblenN` is indexed by natural numbers. The classical Veblen function is
indexed by *ordinals*, with `φ α` for a limit `α` enumerating the common fixed
points of all `φ β`, `β < α`. The conjecture is that `veblenN n` agrees with the
restriction of the transfinite `φ` to finite first arguments, i.e. there is a
normal `φ : Ordinal → Ordinal → Ordinal` with `φ (n : Ordinal) = veblenN n` for
all `n : ℕ`, `φ (succ α) = Ordinal.deriv (φ α)`, and `φ` continuous in the first
argument.

The key insight is that `veblenN_succ_fp` and `veblenN_isNormal` are *exactly*
the successor-step obligations of the transfinite recursion, so the only genuinely
new content is the limit case, which should be packaged as
`Ordinal.derivFamily` over the family `fun (β : Set.Iio α) => φ β`. Our finite
results then become the base instances that pin down the recursion.

Why now? Mathlib already ships `Ordinal.derivFamily` and `Ordinal.nfpFamily`,
and our `veblenN_mono_level` shows the level-indexed compatibility that any
transfinite extension must restrict to — so the finite tower is a ready-made
correctness oracle for the ordinal-indexed definition.

## 2. The Diagonal Γ₀ and Its Fixed-Point Equation

Define `Gamma0 := Ordinal.nfp (fun α => /- φ α 0 -/) 0`, the Feferman–Schütte
ordinal, as the first fixed point of the level-diagonal `n ↦ veblenN n 0`
(extended transfinitely as in Direction 1). The conjecture is the analogue of our
`omega_opow_epsilon0`: `Gamma0` is the least ordinal closed under the entire
two-argument Veblen function, i.e. `φ Gamma0 0 = Gamma0`.

The key insight is that the diagonal `n ↦ veblenN n 0` is itself increasing —
this is precisely the content of our `veblenN_mono_level` specialized to `o = 0` —
so its normalized fixed point exists and the proof mirrors, one level up, the
`epsilon0` argument we already formalized.

Why now? We have a fully verified template (`omega_le_epsilon0`,
`omega_opow_epsilon0`) for "least fixed point of an inflationary normal map
satisfies its defining equation"; `Γ₀` is the same theorem applied to the
diagonal map, so the reasoning transfers with the transfinite `φ` in hand.

## 3. Strict Separation and the Exact Fixed-Point Locus

We proved `veblenN_lt_succ_of_not_fp`: levels separate strictly *except* at fixed
points of the low
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
