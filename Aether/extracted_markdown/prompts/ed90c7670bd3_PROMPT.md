
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

**Title**: This cycle formalized four key results about Collatz orbit structure in `Catalog
**Domain**: Pythagorean
**Mathematical framing**: # Future Directions: Collatz Parity Contraction Theory

## What We Proved

This cycle formalized four key results about Collatz orbit structure in `Catalog/Computation/CollatzParityContraction.lean`:

1. **Parity Exclusion** — after an odd Collatz step (3n+1), the result is always even, so consecutive odd steps are impossible.
2. **Power Comparison** — 3^j < 2^k whenever 2j < k (j ≥ 1), the arithmetic engine behind density contraction.
3. **Parity Density Bound** — at most ⌈k/2⌉ of the first k orbit values can be odd, a quantitative consequence of parity exclusion.
4. **Orbit Determinism** — if two Collatz trajectories meet, they agree on all subsequent iterates.

---

## Direction 1: Sharp Contraction Threshold via Real Logarithms

The current power comparison requires 2j < k (odd density < 1/2), but the optimal threshold is j/k < log(2)/log(3) ≈ 0.6309. The key insight is that the real-valued inequality j · log(3) < (k−j) · log(2) is equivalent to 3^j < 2^(k−j), which transfers to ℕ via Nat.cast_lt. This would give the tightest formal contraction criterion known.

**Why now?** Mathlib's `Real.log` API is mature enough to formalize this chain: define the contraction condition as `j * Real.log 3 < (k - j) * Real.log 2`, prove equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` via `Real.exp_log` and monotonicity, then transfer to ℕ. The `pow3_le_pow4` and `pow3_lt_pow2_of_two_mul_lt` lemmas from this cycle provide the integer-side infrastructure.

**Testable claim**: For k = 100 and j = 63 (density 0.63 < log2/log3), one should be able to prove 3^63 < 2^37 using the real logarithm path, while 2·63 = 126 > 100 means the integer-only path fails.

---

## Direction 2: Orbit Affine Upper Bound

After j odd steps and e even steps in a Collatz orbit starting at n, the orbit value is bounded above by (n · 3^j + 2 · 3^j) / 2^e. The key insight is that each odd step multiplies by at most 3 and adds at most 1 (contributing the +2·3^j error term from geometric series), while each even step divides by 2. Combined with `pow3_lt_pow2_of_two_mul_lt`, this gives an explicit contraction criterion: if 2j < e, the orbit value after j+e steps is less than n for sufficiently large n.

**Why now?** The parity exclusion bound `oddCount_le_half_ceil` guarantees that e ≥ j (at least as many even steps as odd steps), and the power comparison lemma handles the 3^j vs 2^e comparison. The missing piece is formalizing the affine recurrence T(n) ≤ (3n+1)/2 for odd-then-even steps.

**Testable claim**: For n = 27 (111-step orbit), with j = 41 odd steps and e = 70 even steps, verify that 27 · 3^41 / 2^70 < 27.

---

## Direction 3: Residue Class Descent Automation

The file `Catalog/Algebra/ResidueDescent.lean` proves that a finite residue-class descent certificate would imply the Collatz conjecture. The key insight is that combining parity exclusion with modular arithmetic can automatically generate descent certificates for small moduli. For modulus 2^M, each residue class mod 2^M determines exactly M steps of the Collatz orbit, and parity exclusion constrains which step sequences are realizable.

**Why now?** The `collatz_odd_step_yields_even` theorem eliminates half the candidate step sequences, making certificate search tractable. For M = 8, one needs to check 256 residue classes, but parity exclusion reduces the number of realizable 8-step parity words from 256 to at most 55 (Fibonacci number F_10, counting binary words with no consecutive 1s).

**Testable claim**: Formally verify descent certificates for all residue classes mod 2^4 (16 classes) and mod 2^6 (64 classes), using `oddCount_le_half_ceil` to bound the number of odd steps and `pow3_lt_pow2_of_two_mul_lt` to verify contraction.

---

## Direction 4: Fibonacci Connection to Parity Words

The number of valid parity words of length k (binary strings with no consecutive 1s) is the Fibonacci number F_{k+2}. The key insight is that `oddCount_le_half_ceil` is a corollary of a deeper structural fact: the set of realizable Collatz parity words is a subset of the Fibonacci-counted set of "no two consecutive ones" binary strings. This Fibonacci structure connects Collatz dynamics to the theory of independent sets in path graphs.

**Why now?** Mathlib has `Nat.fib` and basic Fibonacci identities. The combinatorial claim that |{w ∈ {0,1}^k : no consecutive 1s}| = F_{k+2} is provable by strong induction (the same structure used in `oddCount_le_half_ceil`). Connecting this to the actual Collatz parity constraint would upgrade the density bound from ⌈k/2⌉ to a precise count.

**Testable claim**: Prove that `Finset.card ((Finset.range (2^k)).filter (fun w => ∀ i < k-1, ¬(Nat.testBit w i = true ∧ Nat.testBit w (i+1) = true))) = Nat.fib (k+2)` for k ≤ 10 by computation, then prove it in general.

---

## Direction 5: Parity Exclusion in Generalized Collatz Systems

For a generalized Collatz system with modulus m (where the standard Collatz has m = 2), define the step function T_m and study which residue classes force consecutive applications of the same branch. The key insight is that parity exclusion generalizes: for the standard system, the "odd branch" maps odd numbers to even numbers, but for m = 3 (the "3n+1 mod 3" system), the branch structure is richer and may or may not have exclusion properties.

**Why now?** The GCS framework in `Catalog/Bridges/Defs.lean` defines generalized systems. Extending `collatz_odd_step_yields_even` to GCS would characterize which systems have automatic density bounds on branch usage, potentially distinguishing "tame" GCS (with exclusion, hence bounded density) from "wild" GCS (without exclusion, potentially undecidable).

**Testable claim**: For the GCS with modulus 3 and rules {0 ↦ n/3, 1 ↦ (2n+1)/3, 2 ↦ (4n+1)/3}, determine whether any branch-exclusion property holds by checking all residue classes mod 9.

Research domain: Pythagorean
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
# Future Directions: Sharp Collatz Contraction & Parity-Word Combinatorics

## What We Proved This Cycle

In `Catalog/Computation/CollatzSharpContraction.lean` we closed three of the open frontiers
left by the parity-contraction work, with fully verified (`sorry`-free, standard-axiom) proofs:

1. **Sharp logarithmic contraction criterion** (`pow3_lt_pow2_iff_log`): the real inequality
   `3^j < 2^k` is *equivalent* to the linear exponent inequality `j·log 3 < k·log 2`. This
   upgrades the crude integer sufficient condition `2j < k` to the exact threshold
   `j/k < log 2 / log 3 ≈ 0.6309`.
2. **Nat transfer + sharp witness** (`nat_pow3_lt_pow2_of_log`, `sharp_contraction_example`):
   the real criterion descends to `ℕ`, and `3^63 < 2^100` is exhibited as a real contraction
   (density `0.63`) that the integer criterion `2·63 < 100` provably cannot detect.
3. **Affine orbit bound** (`shortcut_affine`, `shortcut_lt_double`): the exact two-step affine
   identity `2·T_shortcut n = 3n+1` for odd `n`, plus the bound `T_shortcut n ≤ 2n`.
4. **Fibonacci parity-word count** (`goodLists_length`, `mem_goodLists`, `goodLists_nodup`,
   `noConsec_word_count_eq_fib`): an explicit, *verified* generator of all length-`k` binary
   words with no two consecutive `1`s, proven correct, duplicate-free, and of cardinality
   exactly `F_{k+2}`.

---

## Direction 1: From Word Count to a Realizable-Word Upper Bound

The set of *Collatz-realizable* parity words of length `k` is a subset of the no-consecutive-`1`s
words counted by `noConsec_word_count_eq_fib`, so the number of realizable orbit-parity prefixes is
at most `F_{k+2}`, which is `O(φ^k)` with `φ = (1+√5)/2 < 2`. The key insight is that
`mem_goodLists` already gives a *constructive bijection-grade* characterization of the admissible
words, so the realizability inclusion can be stated as a `List.Sublist`/`Finset.subset` fact and
the density bound `oddCount_le_half_ceil` becomes a corollary of the Fibonacci count rather than an
independent induction.

**Why now?** Both ingredients exist in Lean: `noConsec_word_count_eq_fib` gives the exact ambient
count, and the parity-exclusion theorem `collatz_odd_step_yields_even` supplies the membership
predicate. The only missing step is the injection from realizable prefixes into `goodLists k`.

**Testable claim**: For `k ≤ 12`, the number of orbit-parity prefixes actually realized by starting
values `n < 2^k` is `≤ Nat.fib (k+2)`, verifiable by `decide`/`#eval` and then in general via the
sublist injection.

---

## Direction 2: Quantitative Log-Threshold Bounds via Verified Rational Enclosures

`pow3_lt_pow2_iff_log` reduces contraction to comparing `j·log 3` and `k·log 2`, but applying it to
concrete `(j,k)` near the boundary `j/k = 0.6309…` requires verified numeric bounds on `log 3 /
log 2`. The key insight is that one does not need transcendence: a *rational sandwich*
`p/q < log 2 / log 3 < r/s` follows from integer power comparisons `3^a < 2^b` and `2^c < 3^d`
(both 
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
