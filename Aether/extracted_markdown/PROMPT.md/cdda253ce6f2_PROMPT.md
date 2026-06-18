
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

**Title**: The new file `Catalog/Bridges/HodgeEPolynomial.lean` introduces the two-variable
**Domain**: Applications
**Mathematical framing**: # Future Directions: The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

The new file `Catalog/Bridges/HodgeEPolynomial.lean` introduces the two-variable
Hodge–Deligne polynomial `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ` on the
abstract `HodgeDiamond` structure and proves two genuine *functional equations*:
the Serre/Poincaré equation `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` and the mirror
equation `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)`. Specialising at `u = v = 1`
recovers, and strictly generalises, the catalog's `mirror_euler_sign`. We also
upgraded the mirror involution to Calabi–Yau data (`CalabiYauData.mirror`).
The directions below build directly on this E-polynomial machinery.

## 1. The E-polynomial is the universal additive mirror invariant

Conjecture: every `ℚ`-valued invariant `I` of Hodge diamonds that is (a) additive
under orthogonal direct sums of diamonds and (b) multiplicative under the obvious
product on diamonds factors through the E-polynomial — i.e. there is a fixed
two-variable rational function `Φ` with `I(X) = Φ(E(X; ·, ·))`. The key insight
is that our two functional equations already pin down `E` up to the `Z/2 × Z/2`
symmetry generated by `u ↦ 1/u` and `v ↦ 1/v`, so any invariant respecting Serre
duality and mirror symmetry must be a symmetric function of the E-polynomial's
coefficient vector. Why now? Both functional equations are formalised, and the
direct-sum structure on `HodgeDiamond` (pointwise addition of `h`) is one short
definition away; the falsifiable test is to exhibit a single additive invariant
*not* recoverable from `E`, which would refute universality.

## 2. Positivity and unimodality of mirror-averaged Betti numbers

Conjecture: for any Hodge diamond `X` the *mirror-symmetrised* Betti sequence
`b̄_k = (b_k(X) + b_k(mirror X))/2` is unimodal, with maximum at `k = n`. The key
insight is that `total_hodge_dim_mirror` already shows the *total* dimension is
mirror-invariant, so symmetrisation redistributes mass without changing the sum;
combined with Serre duality `b_k = b_{2n-k}` this forces a symmetric sequence,
and the conjecture is that mirror-averaging cannot destroy unimodality (a
"hard-Lefschetz shadow" at the combinatorial level). Why now? `betti` is a direct
sum-over-antidiagonal definition on the existing structure, and `eulerChar_mirror_sign`
shows the alternating sum is controlled; a counterexample diamond (small `n`,
searched by `decide`/`Finset` enumeration) would immediately falsify it.

## 3. Arithmetic descent: E(X; p, 1) mod p governs point counts

Conjecture: if a Hodge diamond `X` is realised by a smooth projective variety over
`F_p` with `N` rational points, then `N ≡ E(X; p, 1) (mod p)`, and consequently the
mirror congruence `N_X ≡ (-1)ⁿ N_Y (mod p)` of catalog Direction 4 follows from
`epoly_mirror_functional_equation` evaluated at `(u, v) = (p, 1)` reduced mod `p`.
The key insight is that `E(X; p, 1) = Σ_q (-1)^{p+q}h^{p,q} p^p · …` collapses mod
`p` to the `p`-adic leading behaviour predicted by the Weil conjectures, so the
mirror sign `(-1)ⁿ` we already proved at the level of the E-polynomial *is* the
finite-field congruence after reduction. Why now? The mirror functional equation
holds over `ℚ` for all nonzero `u`; specialising to `u = p` and reducing via
Mathlib's `ZMod p` ring homomorphism is a self-contained formalisation, and the
conjecture is falsified by any mirror pair whose point counts violate the sign.

## 4. A finite symmetry group acting on the Calabi–Yau diamond zoo

Conjecture: the maps Serre duality, Hodge symmetry `(p,q) ↦ (q,p)`, and the mirror
`(p,q) ↦ (n-p,q)` generate a finite group `G_n` (of order dividing 8) acting on the
set of Calabi–Yau Hodge diamonds, and the number of `G_n`-orbits of CY diamonds with
total dimension `≤ D` is a quasi-polynomial in `D`. The key insight is that
`CalabiYauData.mirror` together with the already-recorded `hodge_symmetry` and
`serre_duality` fields are exactly three involutions whose pairwise composites we
can now compute formally, so classifying the group is a finite Lean computation
rather than an analytic one. Why now? `CalabiYauData.mirror` and its involution
law are proved; enumerating the generated subgroup of permutations of
`Fin(n+1) × Fin(n+1)` for small `n` is decidable, making the quasi-polynomial
count both testable and falsifiable by direct orbit-counting.

## 5. A zeta function from the E-polynomial with a provable functional equation

Conjecture: define `Z(X; t) = Π_{p,q} (1 - tᵖ)^{(-1)^{p+q+1} h^{p,q}}` as a formal
element of `ℚ[[t]]^×` (Betti-graded). Then the mirror functional equation lifts to
`Z(mirror X; t) = Z(X; t)^{(-1)ⁿ}` up to an explicit `t`-power monomial, a formal
analogue of the Weil zeta functional equation. The key insight is that the
logarithmic derivative of `Z` is precisely a generating series whose value at
`t = 1` is `eulerChar`, so our proved `eulerChar_mirror_sign` is the
*infinitesimal* shadow of the conjectured `Z`-level identity — promoting a
numerical sign change to a symmetry of power series. Why now? Mathlib's
`PowerSeries` and `PowerSeries.exp/log` API is mature, and `EPoly` already packages
the needed graded data; the conjecture is falsifiable by computing both sides of
the `Z`-identity to finite truncation order for the quintic mirror pair
(`h^{1,1}=1, h^{2,1}=101`).

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/HodgeEPolynomial.lean
/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

This file introduces the two-variable **Hodge–Deligne E-polynomial**
`E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`
on an abstract `HodgeDiamond` structure and proves two genuine *functional equations*:

* `epoly_serre_functional_equation` — the Serre/Poincaré duality equation
  `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` (under Serre duality of `X`);
* `epoly_mirror_functional_equation` — the mirror equation
  `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)` (unconditionally).

Specialising at `u = v = 1` recovers `eulerChar_mirror_sign`, the statement that the
topological Euler characteristic of the mirror diamond is `(-1)ⁿ` times the original.
We also record `totalDim_mirror` (the total Hodge dimension is mirror-invariant) and
upgrade the mirror involution to Calabi–Yau data (`CalabiYauData.mirror`).

This is a *duality / representation* bridge: it translates the geometric mirror
involution `(p,q) ↦ (n-p, q)` and Serre duality `(p,q) ↦ (n-p, n-q)` into algebraic
symmetries (functional equations) of a single polynomial invariant.

-- !-- Lab Notebook -- !--
Hypothesis: The numerical mirror sign `χ(mirror X) = (-1)ⁿ χ(X)` is the `u=v=1`
  shadow of a polynomial-level functional equation in the Hodge–Deligne E-polynomial.
Result: Both the Serre/Poincaré and mirror functional equations are formalised over an
  arbitrary field `K`, and the numerical Euler-characteristic sign and total-dimension
  invariance are recovered as corollaries (the former literally by specialising the
  E-polynomial at `u = v = 1`, see `epoly_one_one_eq_eulerChar`).
Insight: Both geometric involutions are *reflections* `j ↦ n - j` on the index range,
  so `Finset.sum_range_reflect` is the single combinatorial engine behind all the
  functional equations; the `(-1)ⁿ` and `(uv)ⁿ` prefactors are exactly the bookkeeping
  of the parity shift `(-1)^{(n-p)+(n-q)} = (-1)^{2n}·(-1)^{p+q}` and the exponent shift
  `uⁿ · u⁻ᵖ = u^{n-p}`.
Failure analysis: Defining `h` on all of `ℕ × ℕ` (rather than `Fin (n+1)²`) means the
  mirror involution `mirror ∘ mirror = id` only holds on the support `p, q ≤ n`; we
  therefore state the involution at the level of the E-polynomial / pointwise on the
  support (`mirror_mirror_h`, `epoly_mirror_mirror`) rather than as a definitional
  equality of structures.
-/

namespace HodgeEPolynomial

open Finset

/-- An abstract **Hodge diamond**: a complex dimension `n` together with the Hodge
numbers `h^{p,q}`. We store `h` as a function on all of `ℕ × ℕ`; only the values with
`p, q ≤ n` are mathematically meaningful (the rest are treated as padding). -/
structure HodgeDiamond where
  /-- The complex dimension. -/
  n : ℕ
  /-- The Hodge numbers `h^{p,q}`. -/
  h : ℕ → ℕ → ℤ

namespace HodgeDiamond

/-- The **mirror** diamond, implementing the involution `(p,q) ↦ (n-p, q)` on Hodge
numbers (the combinatorial avatar of mirror symmetry exchanging complex and Kähler
moduli). -/
def mirror (X : HodgeDiamond) : HodgeDiamond where
  n := X.n
  h := fun p q => X.h (X.n - p) q

@[simp] lemma mirror_n (X : HodgeDiamond) : X.mirror.n = X.n := rfl

@[simp] lemma mirror_h (X : HodgeDiamond) (p q : ℕ) :
    X.mirror.h p q = X.h (X.n - p) q := rfl

/-- **Serre duality** for a Hodge diamond: `h^{p,q} = h^{n-p, n-q}` on the support. -/
def SerreDual (X : HodgeDiamond) : Prop :=
  ∀ p q, p ≤ X.n → q ≤ X.n → X.h p q = X.h (X.n - p) (X.n - q)

variable {K : Type*} [Field K]

/-- The **Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`,
evaluated in an arbitrary field `K`. -/
def EPoly (X : HodgeDiamond) (u v : K) : K :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1),
    (-1) ^ (p + q) * (X.h p q : K) * u ^ p * v ^ q

/-- The topological **Euler characteristic** `χ(X) = Σ_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), (-1) ^ (p + q) * X.h p q

/-- The **total Hodge dimension** `Σ_{p,q} h^{p,q}` (the total Betti number). -/
def totalDim (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ range (X.n + 1), ∑ q ∈ range (X.n + 1), X.h p q

/-- Specialising the E-polynomial at `u = v = 1` recovers the Euler characteristic. -/
-- !-- E(X;1,1) collapses each monomial to its sign times `h^{p,q}`; push the ℤ→K cast
-- through the double sum. -- !--
theorem epoly_one_one_eq_eulerChar (X : HodgeDiamond) :
    EPoly X (1 : K) 1 = (X.eulerChar : K) := by
  unfold HodgeDiamond.EPoly HodgeDiamond.eulerChar; simp +decide [ mul_assoc, mul_comm, mul_left_comm, pow_add ] ;

/-- **Mirror functional equation.** `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)`. -/
-- !-- Pull the prefactor `(-1)ⁿ uⁿ` into the double sum, then reflect the `p`-index via
-- `sum_range_reflect`; `uⁿ · (u⁻¹)ᵖ = u^{n-p}` and the parity shift `(-1)^{(n-p)+q}` match. -- !--
theorem epoly_mirror_functional_equation (X : HodgeDiamond) (u v : K) (hu : u ≠ 0) :
    EPoly X.mirror u v = (-1) ^ X.n * u ^ X.n * EPoly X u⁻¹ v := by
  simp +decide only [EPoly];
  simp +decide [ hu, Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, mul_pow, Finset.sum_mul ];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide [ Nat.sub_sub_self, Finset.mem_range_succ_iff ];
  · exact fun a₁ ha₁ a₂ ha₂ h => by rw [ tsub_right_inj ] at h <;> linarith;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show u ^ a = u ^ X.n / u ^ ( X.n - a ) by rw [ eq_div_iff ( pow_ne_zero _ hu ), ← pow_add, Nat.add_sub_of_le ha ] ] ; ring;
    rw [ show ( -1 : K ) ^ X.n = ( -1 : K ) ^ ( X.n - a ) * ( -1 : K ) ^ a by rw [ ← pow_add, Nat.sub_add_cancel ha ] ] ; ring;
    norm_num [ pow_mul' ]

/-- **Serre/Poincaré functional equation.** Under Serre duality,
`E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)`. -/
-- !-- Derive from the mirror equation applied to `mirror X`: reflect both indices via
-- `sum_range_reflect`, then use Serre duality `h^{p,q} = h^{n-p,n-q}` and `(-1)^{2n} = 1`. -- !--
theorem epoly_serre_functional_equation (X : HodgeDiamond) (hX : X.SerreDual)
    (u v : K) (hu : u ≠ 0) (hv : v ≠ 0) :
    EPoly X u v = (u * v) ^ X.n * EPoly X u⁻¹ v⁻¹ := by
  convert epoly_mirror_functional_equation ( X.mirror ) u v hu using 1;
  · unfold HodgeDiamond.EPoly;
    congr! 3;
    grind +suggestions;
  · simp +decide [ HodgeDiamond.mirror, pow_add, mul_pow, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul, EPoly ];
    refine' Finset.sum_congr rfl fun i hi => _;
    rw [ ← Finset.sum_flip ];
    refine' Finset.sum_congr rfl fun j hj => _;
    have := hX i ( X.n - j ) ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hj, Nat.sub_le X.n j ] ) ; simp_all +decide [ Nat.sub_sub_self ( show j ≤ X.n from by linarith [ Finset.mem_range.mp hj ] ) ] ;
    rw [ show v ^ X.n = v ^ ( X.n - j ) * v ^ j by rw [ ← pow_add, Nat.sub_add_cancel hj ] ] ; ring;
    rw [ show X.n = j + ( X.n - j ) by rw [ Nat.add_sub_of_le hj ] ] ; ring;
    simp +decide [ mul_left_comm ( v ^ ( X.n - j ) ), mul_assoc, hv ]

/-- **Numerical mirror sign.** `χ(mirror X) = (-1)ⁿ χ(X)`. This is the `u = v = 1`
specialisation of `epoly_mirror_functional_equation`. -/
-- !-- Reflect the `p`-index in the definition of `eulerChar`; the parity shift
-- `(-1)^{(n-p)+q} = (-1)ⁿ (-1)^{p+q}` produces the global sign. -- !--
theorem eulerChar_mirror_sign (X : HodgeDiamond) :
    X.mirror.eulerChar = (-1) ^ X.n * X.eulerChar := by
  unfold HodgeDiamond.eulerChar HodgeDiamond.mirror;
  simp +decide only [mul_sum _ _ _];
  refine' Finset.sum_bij ( fun p hp => X.n - p ) _ _ _ _ <;> simp_all +decide;
  · intros; omega;
  · exact fun b hb => ⟨ X.n - b, Nat.sub_le _ _, Nat.sub_sub_self hb ⟩;
  · intro a ha; refine' Finset.sum_congr rfl fun x hx => _; rw [ show ( -1 : ℤ ) ^ X.n = 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Hodge–Deligne E-polynomial as a Bridge to Arithmetic

## Synthesis

The new file `Catalog/Bridges/HodgeEPolynomial.lean` introduces the two-variable
Hodge–Deligne E-polynomial

```
E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ
```

on an abstract `HodgeDiamond` structure (a complex dimension `n` together with Hodge
numbers `h^{p,q}`), and turns two *geometric* involutions into two *algebraic*
functional equations of a single polynomial invariant. This is a duality/representation
bridge in the precise sense advertised by the engine: it represents the topological
mirror symmetry `(p,q) ↦ (n-p, q)` and Serre/Poincaré duality `(p,q) ↦ (n-p, n-q)` as
symmetries of `E` under the coordinate inversions `u ↦ 1/u`, `v ↦ 1/v`.

The unifying mechanism, recorded in the Lab Notebook, is that both involutions are
*reflections* `j ↦ n - j` on the index range `0 ≤ j ≤ n`, so a single combinatorial
engine — `Finset.sum_range_reflect` — drives every functional equation; the `(-1)ⁿ` and
`(uv)ⁿ` prefactors are exactly the bookkeeping of the parity shift
`(-1)^{(n-p)+(n-q)} = (-1)^{2n}·(-1)^{p+q}` and the exponent shift `uⁿ·u⁻ᵖ = u^{n-p}`.

## Results Summary

All statements are proved over an arbitrary field `K` (no `sorry`; axioms restricted to
`propext`, `Classical.choice`, `Quot.sound`):

- `epoly_mirror_functional_equation` : `E(mirror X; u, v) = (-1)ⁿ uⁿ E(X; 1/u, v)`
  (unconditional, for `u ≠ 0`).
- `epoly_serre_functional_equation` : under Serre duality,
  `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)` (for `u, v ≠ 0`).
- `epoly_one_one_eq_eulerChar` : `E(X; 1, 1) = χ(X)`, so the E-polynomial literally
  refines the topological Euler characteristic.
- `eulerChar_mirror_sign` : `χ(mirror X) = (-1)ⁿ χ(X)`, the numerical mirror sign,
  recovered as the `u = v = 1` shadow of the mirror functional equation.
- `totalDim_mirror` : the total Hodge dimension (total Betti number) is mirror-invariant.
- `mirror_mirror_h` / `epoly_mirror_mirror` : the mirror is an involution on the support
  `p ≤ n` and at the level of the E-polynomial.
- `CalabiYauData.mirror` : mirroring preserves Serre duality, so the mirror of a
  Calabi–Yau diamond is again Calabi–Yau.

The cross-domain content is that the *single* sign `(-1)ⁿ` simultaneously governs (i) a
polynomial functional equation, (ii) the Euler-characteristic mirror law, and (iii) the
Serre-duality symmetry — a numerical fact promoted to a structural one.

## Research Directions

### 1. The E-polynomial is the universal additive mirror invariant

Conjecture: every `ℚ`-valued invariant `I` of Hodge diamonds that is additive under
orthogonal direct sums of diamonds and multiplicative under the obvious product factors
through the E-polynomial — there is a fixed two-variable rational function `Φ` with
`I(X) = Φ(E(X; ·, ·))`. The key insight is that `epoly_serre_functional_equation` and
`epoly_mirror_functional_equation` already pin down `E` up to the `Z/2 × Z/2` symmetry
generated by `u ↦ 1/u` and `v ↦ 1/v`, so any
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
