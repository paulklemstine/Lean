
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

**Title**: The current formalization captures the algebraic and analytic *ingredients* of t
**Domain**: Computation
**Mathematical framing**: # Future Directions: LWE Hardness Reductions

## 1. Formal Verification of the Full Regev Quantum Reduction

The current formalization captures the algebraic and analytic *ingredients* of the LWE search-to-decision reduction — affine bijections over Z_p, noise accumulation bounds, rounding correctness, and the pigeonhole advantage decomposition. The natural next step is to close the loop by formalizing the **quantum reduction from GapSVP to LWE** itself, which requires modeling the quantum step where a BDD oracle is used to sample from a discrete Gaussian.

The key insight is that the quantum step can be decomposed into a classical "iterative rounding" procedure plus a single quantum Fourier sampling step. The iterative rounding is purely algebraic and amenable to formalization; the quantum sampling can be abstracted as an oracle satisfying a distributional specification (certified approximate discrete Gaussian). This decomposition avoids formalizing quantum circuits entirely.

Why now? The `ApproxDiscreteGaussian` structure in `RegevReduction/Theorems.lean` already provides the right abstraction for the quantum oracle, and the `ModuleReductionStep` framework can compose the classical reduction steps. The missing piece is the distributional analysis connecting the BDD oracle to Gaussian sampling — specifically, proving that the smoothing parameter η_ε(Λ) controls the quality of the resulting samples.

## 2. Ring-LWE and Module-LWE Search-to-Decision Reductions

The coordinate-by-coordinate search-to-decision strategy formalized here works for standard LWE but fails for structured variants. For **Ring-LWE** (Lyubashevsky-Peikert-Regev 2010), the reduction requires the algebraic structure of number fields — specifically, the Chinese Remainder Theorem for splitting R_q = Z_q[X]/(f(X)) when f splits modulo q.

The key insight is that the affine bijection `ZMod.affine_bijective` generalizes from Z_p to Z_p[X]/(f) when f is irreducible mod p, but the search-to-decision reduction uses the *splitting* structure rather than irreducibility. Formalizing this requires Mathlib's `Polynomial.Splits` and the CRT for polynomial quotients, both of which exist in Mathlib.

Why now? The `ZMod.sum_affine_eq` theorem (showing sums are invariant under affine rerandomization) is the template for the Ring-LWE analogue, where the sum runs over elements of R_q instead of Z_q. The module-level abstractions in `SearchDecision.lean` (e.g., `abstract_hybrid_telescope`) already handle the case of arbitrary finite indexing sets, so the hybrid argument infrastructure is ready.

## 3. Tightness of the Factor-n Loss in Search-to-Decision

The `search_to_decision_advantage_bound` theorem shows that the coordinate-by-coordinate reduction loses a factor of n in advantage. A natural question is whether this loss is **tight** — i.e., whether there exists an LWE instance where the best coordinate-by-coordinate strategy indeed loses exactly a factor of n.

The key insight is that tightness should follow from a **probabilistic construction**: for a uniformly random secret s, with high probability, all coordinates of s contribute roughly equally to the decision advantage. A formal proof would show that for the discrete Gaussian error distribution, the per-coordinate advantages concentrate around δ/n with deviation O(δ/n^{3/2}).

Why now? The pigeonhole argument in `search_to_decision_advantage_bound` is tight as a combinatorial statement (it just says "some coordinate has advantage ≥ δ/n"). The concentration argument would use the existing Gaussian tail bounds from `HardnessReduction.lean` combined with the Azuma-Hoeffding inequality, which exists in Mathlib as `measure_norm_le_of_martingale`.

## 4. Noise Flooding with Explicit Rényi Divergence Bounds

The current `NoiseFloodingLemma` (in `HardnessReduction.lean`) asserts that large Gaussian noise "floods" a bounded signal, making the sum statistically close to a pure Gaussian. A more precise and practically useful statement would give the bound in terms of **Rényi divergence** rather than statistical distance.

The key insight is that Rényi divergence of order α between D_{Z,s}(x + ·) and D_{Z,s} can be bounded as R_α ≤ exp(π α B²/s²) for |x| ≤ B. This multiplicative bound composes perfectly under independent sampling (R_α of products = product of R_α's), giving much tighter bounds for the multi-sample setting used in LWE encryption.

Why now? The `LeftoverHash.lean` module already formalizes collision probability (which is exp(R_2)), and the Cauchy-Schwarz bridge (`l1_le_sqrt_card_mul_l2`) connects ℓ² bounds to statistical distance. Extending this to Rényi divergence of general order requires only the Hölder inequality (available in Mathlib) and the explicit Gaussian moment computation.

## 5. Verified Parameter Selection for NIST Standards (Kyber/ML-KEM)

The theorems in this module can be instantiated with **concrete parameters** to verify the security claims of NIST post-quantum standards. For ML-KEM (formerly CRYSTALS-Kyber), the parameters are n=256, q=3329, k∈{2,3,4}, with centered binomial error distribution of parameter η∈{2,3}.

The key insight is that the `decryption_correct_after_switching` theorem, combined with the `noise_accumulation_subset_bound`, can produce a **verified bound on the decryption failure probability** for specific ML-KEM parameter sets. This requires: (1) computing the exact noise bound B for the centered binomial distribution (B = η), (2) computing the subset sum bound for k·n error terms, and (3) verifying B + nδ < q/4.

Why now? All the analytic machinery is in place: the rounding correctness (`regev_rounding_bit1`), noise accumulation (`noise_accumulation_bound`), and modulus switching (`combined_noise_after_switching`) theorems compose directly. The concrete computation can be done with `#eval` in Lean and verified with `native_decide` for the specific parameter choices. This would produce the first machine-verified security proof for a NIST post-quantum standard.

Research domain: Computation
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
# Future Directions: Rényi Divergence for Lattice Cryptography

The new module `RenyiDivergence.lean` formalizes the *multiplicative Rényi
divergence* `RD_α(P ‖ Q) = ∑ₓ P(x)^α Q(x)^{1-α}` over finite index sets and
proves its core structural properties: non-negativity, the diagonal value
`RD_α(P‖P) = ∑P`, **multiplicativity under independent products**, its
`m`-th-power behaviour for i.i.d. samples, the order-2 / collision-probability
bridge, and — as the analytic centrepiece — the **exact Gaussian shift
identity** `RD_α = exp(-π α(1-α)c²/s²) · ∑ᵢ ρ_s(latt i - αc)` together with the
flooding bound for `0 ≤ α ≤ 1`. A boundary counterexample shows independence is
essential, and a tightness witness shows the factor-`n` advantage loss cannot
be improved. These pieces suggest the following concrete next steps.

## 1. From the finite shift identity to a true smoothing-parameter bound

The proved identity `gaussian_renyiDiv_shift` reduces the Rényi divergence of a
shifted lattice Gaussian to a *recentred* lattice theta sum `∑ᵢ ρ_s(latt i - αc)`.
The remaining gap is to bound that recentred sum by the unshifted one,
`∑ᵢ ρ_s(latt i)`, up to a `(1+ε)` factor whenever `s` exceeds the smoothing
parameter `η_ε(Λ)`.

The key insight is that the recentred theta sum is a *translate* of the lattice
Gaussian, and the smoothing parameter is precisely the threshold above which the
lattice Gaussian is flat under translation (its Fourier transform off the dual
lattice is `≤ ε`). Combining this with our exact prefactor would upgrade
`gaussian_renyiDiv_flooding` from a conditional statement (assuming a sum bound
`Z`) into an unconditional `RD_α ≤ 1 + ε` bound — the form actually used in
security proofs.

Why now? `gaussian_renyiDiv_shift` already isolates the *only* non-algebraic
ingredient (translation-invariance of the theta sum). Mathlib's Poisson
summation (`Real.tsum_eq` / `EisensteinSeries` theta machinery) gives the dual
characterization needed, so the missing lemma is a self-contained analytic fact
rather than a from-scratch development.

## 2. Probability preservation under bounded Rényi divergence

A defining feature that makes Rényi divergence usable in cryptography is the
*probability preservation* property: if an event `E` has probability `p` under
`Q`, then under `P` it has probability at least `p^{α/(α-1)} / RD_α(P‖Q)^{1/(α-1)}`.
This is the lemma that converts a divergence bound into a security-loss bound.

The key insight is that probability preservation is exactly a reverse Hölder
inequality applied to the indicator of `E`: write `Q(E) = ∑_{x∈E} P(x)^{α/(α-1)·(α-1)/α}…`
and apply Hölder with exponents `(α, α/(α-1))`. Our `renyiDiv` definition already
uses `rpow`, so the statement lives in the same algebraic language.

Why now? The multiplicativity and `m`-th-power lemmas (`renyiDiv_multiplicative`,
`renyiDiv_pow_of_iid`) already give the *composition* half of the toolkit; the
probability-preservation lemma is the *consumption* half. Mathlib's
`inner_le
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
