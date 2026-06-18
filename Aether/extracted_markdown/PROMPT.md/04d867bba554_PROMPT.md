
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
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: The file `MirrorSymmetry/ArithmeticMirror.lean` formalizes a rigorous,
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Arithmetic Mirror Symmetry

The file `MirrorSymmetry/ArithmeticMirror.lean` formalizes a rigorous,
self-contained skeleton of mirror symmetry: the Hodge-diamond mirror reflection
`p ↦ n - p`, the resulting Euler-characteristic relation `χ(Y) = (-1)^n χ(X)`
(specializing to `χ(Y) = -χ(X)` for threefolds), the combinatorial form of
*"rational curves on `X` ↔ rank of `Pic(Y)`"* via the `h^{1,1} ↔ h^{2,1}` swap,
and — on the arithmetic side — the Weil functional equation for the zeta function
of projective space, proved as a polynomial identity over an arbitrary
commutative ring. The following directions extend this nucleus toward genuine
arithmetic mirror symmetry.

## 1. Hodge symmetry and the full mirror diamond

The current `mirror` only reflects the first index `p ↦ n - p`. A Calabi–Yau
diamond also enjoys complex conjugation `h^{p,q} = h^{q,p}` and Serre duality
`h^{p,q} = h^{n-p,n-q}`. **Conjecture:** under the joint hypotheses of Hodge
symmetry and Serre duality, the mirror map composed with conjugation is an
involution that fixes the Euler characteristic up to the global sign `(-1)^n`,
and the diagonal Hodge numbers `h^{p,p}` of `Y` are a permutation of the
anti-diagonal `h^{p,n-p}` of `X`.

The key insight is that mirror symmetry is the *second* reflection symmetry of an
already doubly-symmetric diamond, so all three reflections (conjugation, Serre,
mirror) generate a finite reflection group acting on the diamond, and the Euler
characteristic is the unique (up to scale) alternating invariant of that group.

Why now? The Euler-characteristic machinery (`eulerChar_mirror`) is already in
place and only manipulates alternating sums under index reflection; adding the
two extra reflections is the same `Finset.sum_range_reflect` argument applied in
the second variable, so the proof obligations are immediate variations of what is
proved.

## 2. Stringy Hodge numbers and the topological mirror test

Batyrev–Dais stringy Hodge numbers `h^{p,q}_{st}` extend ordinary Hodge numbers
to singular and orbifold Calabi–Yau, and the *topological mirror symmetry test*
asserts `h^{p,q}_{st}(X) = h^{n-p,q}_{st}(Y)`. **Conjecture:** for a Hodge
diamond enriched with a `ℚ`-valued correction supported on a finite set of
"singular strata", the stringy Euler characteristic still satisfies
`χ_{st}(Y) = (-1)^n χ_{st}(X)`, and the correction terms cancel pairwise under
the mirror reflection.

The key insight is that the stringy invariant is again an alternating sum over a
reflection-symmetric index set, merely valued in `ℚ` rather than `ℤ`, so the sign
bookkeeping of `eulerChar_mirror` transfers verbatim once the summand type is
generalized from `ℤ` to a `CommRing`.

Why now? `eulerChar` is defined over `ℤ` but its proof uses only ring identities
and `sum_range_reflect`; generalizing the codomain to an arbitrary commutative
ring is a low-risk refactor that immediately unlocks the rational-valued stringy
setting.

## 3. Functional equation for products of projective spaces and hypersurfaces

`projectiveSpace_zeta_functional_equation` proves the Weil functional equation
for `ℙⁿ`. **Conjecture:** the zeta function of a product `ℙ^{n_1} × ⋯ × ℙ^{n_k}`
satisfies the functional equation with reflection exponent
`N = Σ n_i` and sign `(-1)^{Σ(n_i+1)}`, obtained as the product of the individual
functional equations; and for a degree-`d` Calabi–Yau hypersurface in `ℙ^{n+1}`
(`d = n + 2`) the *primitive* part of the zeta numerator is palindromic of even
weight `n`.

The key insight is that the functional equation is multiplicative for the zeta
function of a product (the reciprocal-root multiset is the Minkowski sum of the
factors' multisets), so the global identity factors through the single-factor
identity already proved.

Why now? The proved identity is stated over an arbitrary `CommRing` and is a pure
`Finset.prod` manipulation, so the product case is a `Finset.prod_mul_distrib`
away, and the palindromy of the primitive part reduces to the same
`prod_range_reflect` sign computation used in the base case.

## 4. Mirror congruences for point counts (Wan's theorem, toy form)

Wan's theorem on mirror symmetry for zeta functions predicts congruences between
the number of `𝔽_q`-points of a Calabi–Yau and its mirror. **Conjecture:** for
the combinatorial point-count model `N_m = Σ_{i=0}^n q^{im}` attached to `ℙⁿ` and
the mirror-reflected weights, the difference of point counts of a mirror pair is
divisible by `q - 1` for all `m`, and the quotient is itself a palindromic
polynomial in `q^m`.

The key insight is that `q - 1` divisibility is exactly the geometric-series
identity `(q^m - 1) · Σ_{i<n+1} (q^m)^i = (q^m)^{n+1} - 1`, so congruences between
mirror point counts reduce to congruences between *Hodge numbers* via the
already-proven Euler-characteristic exchange.

Why now? The geometric-series identity is one `Finset.geom_series` lemma away in
Mathlib, and `eulerChar_mirror` already provides the bridge from point-count
differences to Hodge-number differences; the only new ingredient is the explicit
divisibility, which `omega`/`Finset` arithmetic can discharge.

## 5. Modularity of the weight as a categorical shadow

The deepest prediction is that the zeta function of a rigid Calabi–Yau threefold
is modular of weight `4`. A fully rigorous formalization is far off, but a
*falsifiable shadow* is reachable: **Conjecture:** the reflection exponent
`N = n` and weight `w = n` extracted from `projectiveSpace_zeta_functional_equation`
satisfy `w = N`, and for a rigid CY threefold model (`h^{2,1} = 0`, so
`h^{1,1}` determined by `χ`) the functional-equation sign forced by
`eulerChar_mirror_threefold` is exactly the sign `+1` compatible with a weight-`4`
modular form's functional equation.

The key insight is that the *sign* of the Weil functional equation and the
*parity* of the Euler characteristic are the same `(-1)^{n}` datum, so the
"modularity-compatible sign" is not an extra hypothesis but a theorem of the
combinatorial model already built.

Why now? Both the sign of the functional equation
(`projectiveSpace_zeta_functional_equation`) and the threefold Euler sign
(`eulerChar_mirror_threefold`) are now formal theorems; equating them is a finite
sign check, giving the first machine-checked compatibility statement between the
arithmetic and Hodge-theoretic sides of mirror symmetry.

Research domain: Geometry
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Geometry/MirrorSymmetry/ArithmeticMirror.lean
/-
  Arithmetic Mirror Symmetry: a self-contained combinatorial skeleton.

  This file formalizes a rigorous, ring-valued skeleton of mirror symmetry:

    * the Hodge-diamond mirror reflection `p ↦ n - p` and its companion
      reflections (second-index reflection and transpose),
    * the resulting Euler-characteristic relation `χ(mirror Y) = (-1)^n χ(X)`,
      specializing to `χ = -χ` for threefolds,
    * the reflection-group structure of the diamond: the three reflections all
      act on `χ` by `±1`, so `χ` is an invariant of the symmetry group up to sign,
    * the Weil functional equation for the zeta function of projective space,
      proved as a polynomial identity over an *arbitrary* commutative ring,
    * a cross-domain bridge: for `Pⁿ` the `𝔽_q`-point count is congruent to the
      topological Euler characteristic `n+1` modulo `q - 1`.

  Everything is stated over a general `CommRing R` (the codomain of the Hodge
  numbers / coefficients), which immediately subsumes the integer-valued
  ordinary theory and the rational-valued "stringy" theory.
-/
import Mathlib

open Finset

namespace ArithmeticMirror

/-! ### Hodge diamonds and the Euler characteristic -/

variable {R : Type*} [CommRing R]

/-- The Euler characteristic of a Hodge diamond `h : (p,q) ↦ h^{p,q}` of a
complex `n`-dimensional variety, as the alternating double sum. -/
def eulerChar (n : ℕ) (h : ℕ → ℕ → R) : R :=
  ∑ p ∈ Finset.range (n+1), ∑ q ∈ Finset.range (n+1), (-1)^(p+q) * h p q

/-- The mirror diamond reflects the first Hodge index `p ↦ n - p`. -/
def mirror (n : ℕ) (h : ℕ → ℕ → R) : ℕ → ℕ → R := fun p q => h (n - p) q

/-- The second-index reflection `q ↦ n - q`. -/
def mirror2 (n : ℕ) (h : ℕ → ℕ → R) : ℕ → ℕ → R := fun p q => h p (n - q)

/-- The transpose (complex-conjugation) reflection `h^{p,q} ↦ h^{q,p}`. -/
def transpose (h : ℕ → ℕ → R) : ℕ → ℕ → R := fun p q => h q p

-- !-- Lab Notebook -- !--
-- Hypothesis: the mirror reflection `p ↦ n-p` should rescale χ by exactly (-1)^n.
-- Result: proved (`eulerChar_mirror`).  Insight: the whole content is
-- `Finset.sum_range_reflect` plus the elementary sign identity
-- (-1)^(n-p) = (-1)^n (-1)^p valid for p ≤ n; no positivity or field structure
-- is needed, so the statement holds over any CommRing.
-- Failure analysis: a first attempt factored the sign in the wrong order and the
-- `rw` could not find `(-1)^p * (-1)^p`; isolating the helper `hsub` fixed it.

-- !-- comment -- !--
-- Reflecting the first Hodge index multiplies the Euler characteristic by (-1)^n:
-- reindex the outer sum by `p ↦ n-p` and use (-1)^(n-p) = (-1)^n (-1)^p.
-- !-- comment -- !--
/-- **Mirror Euler relation.** Reflecting the first Hodge index multiplies the
Euler characteristic by `(-1)^n`. -/
theorem eulerChar_mirror (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (mirror n h) = (-1)^n * eulerChar n h := by
  unfold eulerChar mirror
  rw [Finset.mul_sum]
  rw [← Finset.sum_range_reflect
        (fun p => ∑ q ∈ Finset.range (n+1), (-1)^(p+q) * h (n-p) q) (n+1)]
  apply Finset.sum_congr rfl
  intro p hp
  simp only [Finset.mem_range] at hp
  have hpn : p ≤ n := by omega
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro q _
  have e1 : n + 1 - 1 - p = n - p := by omega
  rw [e1]
  have e2 : n - (n - p) = p := by omega
  rw [e2]
  have hsub : (-1:R)^(n-p) = (-1)^n * (-1)^p := by
    have hkey : (-1:R)^(n-p) * (-1)^p = (-1)^n := by
      rw [← pow_add, Nat.sub_add_cancel hpn]
    have hu : ((-1:R)^p) * ((-1:R)^p) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    calc (-1:R)^(n-p) = (-1)^(n-p) * ((-1)^p * (-1)^p) := by rw [hu, mul_one]
      _ = ((-1)^(n-p) * (-1)^p) * (-1)^p := by ring
      _ = (-1)^n * (-1)^p := by rw [hkey]
  have sgn : (-1:R)^((n-p)+q) = (-1)^n * (-1)^(p+q) := by
    rw [pow_add, hsub, pow_add]; ring
  rw [sgn]; ring

-- !-- comment -- !--
-- Same argument on the inner (q) sum: reflecting the second index also scales χ
-- by (-1)^n.
-- !-- comment -- !--
/-- The second-index reflection multiplies the Euler characteristic by `(-1)^n`. -/
theorem eulerChar_mirror2 (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (mirror2 n h) = (-1)^n * eulerChar n h := by
  unfold eulerChar mirror2
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro p _
  rw [Finset.mul_sum]
  rw [← Finset.sum_range_reflect (fun q => (-1)^(p+q) * h p (n-q)) (n+1)]
  apply Finset.sum_congr rfl
  intro q hq
  simp only [Finset.mem_range] at hq
  have hqn : q ≤ n := by omega
  have e1 : n + 1 - 1 - q = n - q := by omega
  rw [e1]
  have e2 : n - (n - q) = q := by omega
  rw [e2]
  have hsub : (-1:R)^(n-q) = (-1)^n * (-1)^q := by
    have hkey : (-1:R)^(n-q) * (-1)^q = (-1)^n := by
      rw [← pow_add, Nat.sub_add_cancel hqn]
    have hu : ((-1:R)^q) * ((-1:R)^q) = 1 := by
      rw [← pow_add, ← two_mul, pow_mul]; norm_num
    calc (-1:R)^(n-q) = (-1)^(n-q) * ((-1)^q * (-1)^q) := by rw [hu, mul_one]
      _ = ((-1)^(n-q) * (-1)^q) * (-1)^q := by ring
      _ = (-1)^n * (-1)^q := by rw [hkey]
  have sgn : (-1:R)^(p+(n-q)) = (-1)^n * (-1)^(p+q) := by
    rw [pow_add, pow_add, hsub]; ring
  rw [sgn]; ring

-- !-- comment -- !--
-- The transpose merely swaps the two summation indices in an expression whose
-- sign `(-1)^(p+q)` is already symmetric, so χ is unchanged (no hypotheses).
-- !-- comment -- !--
/-- **Transpose invariance.** The Euler characteristic is invariant under the
Hodge transpose `h^{p,q} ↦ h^{q,p}`; unlike the mirror this needs no symmetry
hypothesis on `h`. -/
theorem eulerChar_transpose (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (transpose h) = eulerChar n h := by
  unfold eulerChar transpose
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro p _
  apply Finset.sum_congr rfl; intro q _
  rw [Nat.add_comm]

-- !-- comment -- !--
-- Composing both index reflections multiplies χ by (-1)^n twice, i.e. by 1:
-- the diamond's reflection group acts on χ through the sign character.
-- !-- comment -- !--
/-- **Double reflection is trivial on `χ`.** Reflecting both Hodge indices fixes
the Euler characteristic, since `(-1)^n · (-1)^n = 1`. This exhibits `χ` as an
invariant of the reflection group generated by the two mirror reflections. -/
theorem eulerChar_double_reflection (n : ℕ) (h : ℕ → ℕ → R) :
    eulerChar n (mirror n (mirror2 n h)) = eulerChar n h := by
  rw [eulerChar_mirror, eulerChar_mirror2, ← mul_assoc, ← pow_add, ← two_mul, pow_mul]
  norm_num

-- !-- comment -- !--
-- Specialize `eulerChar_mirror` at n = 3 where (-1)^3 = -1.
-- !-- comment -- !--
/-- **Threefold mirror relation.** For a Calabi–Yau threefold the mirror has
opposite Euler characteristic. -/
theorem eulerChar_mirror_threefold (h : ℕ → ℕ → R) :
    eulerChar 3 (mirror 3 h) = - eulerChar 3 h := by
  rw [eulerChar_mirror]; norm_num

-- !-- comment -- !--
-- The h^{1,1} ↔ h^{2,1} exchange (rational curves ↔ Picard rank) is literally
-- `mirror 3 h 1 1 = h 2 1` by unfolding the reflection p ↦ 3 - p.
-- !-- comment -- !--
omit [CommRing R] in
/-- **Hodge-number exchange.** On a threefold the mirror swaps `h^{1,1}` and
`h^{2,1}` — the combinatorial shadow of "rational curves on `X` ↔ rank of
`Pic(Y)`". -/
theorem mirror_swaps_hodge_threefold (h : ℕ → ℕ → R) :
    mirror 3 h 1 1 = h 2 1 := rfl

/-! ### The arithmetic side: the Weil functional equation for `Pⁿ` -/

-- !-- Lab Notebook -- !--
-- Hypothesis: the multiset of Frobenius reciprocal roots {q^0,…,q^n} of P^n is
-- self-dual under α ↦ q^n/α, yielding the Weil functional equation.
-- Result: proved as the division-free polynomial identity
--   ∏ (q^{n-i} T - 1) = (-1)^{n+1} ∏ (1 - q^i T)   (`projectiveSpace_zeta_functional_equation`).
-- Insight: clearing the denominators of Z(1/(q^n T)) = (-1)^{n+1} q^{n(n+1)/2} T^{n+1} Z(T)
-- collapses to `Finset.prod_range_reflect` (the reciprocal roots q^i ↦ q^{n-i})
-- followed by pulling out a factor (-1) from each of the n+1 factors.
-- Failure analysis: the guessed lemma `prod_neg_eq_neg_one_
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Arithmetic Mirror Symmetry

## Synthesis

The new file `Catalog/Geometry/MirrorSymmetry/ArithmeticMirror.lean` builds a
self-contained, fully-proved (`sorry`-free) skeleton of mirror symmetry that
*unifies* the Hodge-theoretic and arithmetic faces of the subject under a single
combinatorial mechanism: **reflection of a finite index range**. Concretely it
proves, over an arbitrary commutative ring `R`:

* `eulerChar_mirror` — reflecting the first Hodge index scales the Euler
  characteristic by `(-1)^n`;
* `eulerChar_mirror2`, `eulerChar_transpose`, `eulerChar_double_reflection` — the
  three reflections (first index, second index, transpose) generate a symmetry
  group acting on `χ` through the sign character, so `χ` is a group invariant up
  to sign;
* `eulerChar_mirror_threefold`, `mirror_swaps_hodge_threefold` — the threefold
  specialization `χ(Y) = -χ(X)` and the `h^{1,1} ↔ h^{2,1}` exchange;
* `projectiveSpace_zeta_functional_equation` — the Weil functional equation for
  `ℙⁿ` as a division-free polynomial identity, valid over any `CommRing`;
* `functional_equation_sign_vs_euler_sign` — the bridge `(-1)^{n+1} = -(-1)^n`
  identifying the functional-equation sign and the Euler sign;
* `projHodge_eulerChar`, `pointCount_congr_eulerChar` — `χ(ℙⁿ) = n+1` and the
  cross-domain congruence `#ℙⁿ(𝔽_q) ≡ χ(ℙⁿ) (mod q-1)`.

The unifying observation is that *every* statement above is an instance of
`Finset.sum_range_reflect` / `Finset.prod_range_reflect` applied to a
sign-weighted alternating object. This is what makes the skeleton ring-valued and
therefore portable to the stringy (ℚ-valued) and motivic settings.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `eulerChar_mirror` | `χ(mirror Y) = (-1)^n χ(X)` over any `CommRing` | proved |
| `eulerChar_mirror2` | second-index reflection scales `χ` by `(-1)^n` | proved |
| `eulerChar_transpose` | `χ` invariant under `h^{p,q} ↦ h^{q,p}` (no hypotheses) | proved |
| `eulerChar_double_reflection` | both reflections compose to identity on `χ` | proved |
| `eulerChar_mirror_threefold` | `χ(Y) = -χ(X)` for `n=3` | proved |
| `projectiveSpace_zeta_functional_equation` | Weil FE for `ℙⁿ`, division-free, any ring | proved |
| `functional_equation_sign_vs_euler_sign` | `(-1)^{n+1} = -(-1)^n` | proved |
| `projHodge_eulerChar` | `χ(ℙⁿ) = n+1` | proved |
| `pointCount_congr_eulerChar` | `#ℙⁿ(𝔽_q) ≡ χ(ℙⁿ) (mod q-1)` | proved |

## Research Directions

### 1. The diamond reflection group is exactly the Klein four-group acting through the sign character

The three reflections proved here (first-index mirror, second-index mirror,
transpose) are involutions; the two index reflections commute and their composite
is `eulerChar_double_reflection`. **Conjecture:** the subgroup of `Sym` they
generate is `ℤ/2 × ℤ/2`, the transpose is the diagonal element, and the induced
action on `χ` factors through a single homomorphism `(ℤ/2)² → {±1}` sending each
index reflection to `(-1)^n` and 
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
