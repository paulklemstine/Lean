
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

**Title**: The previous cycle established the Hodge–Deligne E-polynomial
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Hodge–Deligne E-polynomial as a Motivic Measure

## Synthesis

The previous cycle established the Hodge–Deligne E-polynomial
`E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ` on the abstract `HodgeDiamond` structure
and proved its *single-variety* symmetries: the Serre/Poincaré functional equation
`E(X) = (uv)ⁿ E(X; 1/u, 1/v)`, the mirror functional equation, and their numerical
shadows (`eulerChar_mirror_sign`, `totalDim_mirror`).

This cycle **deepens** that file (`Catalog/Bridges/HodgeEPolynomial.lean`) by promoting the
E-polynomial from a single-variety invariant to a *ring / measure level* invariant. We
introduce the three universal operations on Hodge diamonds — direct sum `⊕`, tensor
product `⊗` (with the genuine Künneth convolution of Hodge numbers), and the Tate /
Lefschetz twist `X(1)` — and prove how `E` transforms under each:

* `epoly_directSum` — **additivity** `E(X ⊕ Y) = E(X) + E(Y)`;
* `epoly_kunneth` — **Künneth multiplicativity** `E(X ⊗ Y) = E(X) · E(Y)`;
* `eulerChar_kunneth` — the numerical product law `χ(X ⊗ Y) = χ(X) · χ(Y)`;
* `epoly_tateTwist` — `E(X(1)) = uv · E(X)` (the Tate twist acts as the Lefschetz class `𝕃 = uv`);
* `poincare_serre_palindrome` — the one-variable specialisation `P(X; t) = E(X; t, t)` is
  palindromic `P(X; t) = t^{2n} P(X; 1/t)` under Serre duality.

Together these say: `X ↦ E(X; u, v)` is a homomorphism of (semi)rings from the
Grothendieck ring of supported Hodge diamonds (under `⊕`, `⊗`) into `K[u, v]`,
intertwining the Tate twist with multiplication by `uv`. In one phrase: **the
E-polynomial is a motivic measure**. The proof rests on two reusable lemmas extracted in
the file, `cauchy_prod_1D` and `cauchy_prod_2D` (truncated Cauchy products under a support
hypothesis), which are exactly the local-to-global engine: the *global* invariant of a
product factors through the *local* (factor) data, and the only assumption needed is
`Supported` — the algebraic shadow of a Hodge structure concentrated in degrees `0 … n`.

## Results Summary

All results are over an arbitrary field `K` and verified with no `sorry` and only the
standard axioms `propext, Classical.choice, Quot.sound`:

| Theorem | Statement |
|---|---|
| `cauchy_prod_1D` | truncated 1-D Cauchy product under one-sided support |
| `cauchy_prod_2D` | truncated 2-D Cauchy product (two applications of the 1-D form) |
| `epoly_directSum` | `E(X ⊕ Y) = E(X) + E(Y)` |
| `epoly_kunneth` | `E(X ⊗ Y) = E(X) · E(Y)` |
| `eulerChar_kunneth` | `χ(X ⊗ Y) = χ(X) · χ(Y)` |
| `epoly_tateTwist` | `E(X(1)) = uv · E(X)` |
| `poincare_serre_palindrome` | `P(X; t) = t^{2n} P(X; 1/t)` under Serre duality |

These extend, rather than reprove, the catalog: `epoly_directSum` and `epoly_tateTwist`
build on `EPoly`/`eulerChar`; `eulerChar_kunneth` is derived through
`epoly_one_one_eq_eulerChar`; `poincare_serre_palindrome` is a direct specialisation of
`epoly_serre_functional_equation`.

## Bold, Falsifiable Research Directions

### 1. The Grothendieck semiring of Hodge diamonds is a commutative semiring, and `E` is a semiring homomorphism

We proved additivity, multiplicativity, and the Tate-twist law *pointwise*. The next step
is to bundle them: show that `(SupportedDiamond, ⊕, ⊗, 0, point)` is a commutative
semiring (associativity and commutativity of `⊗`, distributivity of `⊗` over `⊕`, the
one-point diamond as multiplicative unit) and that `X ↦ E(X; ·, ·) : SupportedDiamond → K[u,v]`
is a semiring homomorphism, with the Tate twist realised as multiplication by the Lefschetz
element `𝕃 = uv`. **The key insight is** that every structural law of the target ring
`K[u,v]` should pull back along `E` to a *combinatorial* identity on Hodge numbers that is
again a Cauchy-product reflection — so `cauchy_prod_2D` is not just the proof of one
theorem but the single lemma generating the whole semiring structure. **Why now?** With
`epoly_kunneth` and `epoly_directSum` in hand the homomorphism property is *already* proved
on generators; only the associativity/commutativity of `tensorProd` (pure index
bookkeeping) remains, making this the cheapest high-value consolidation available. It is
falsifiable: a single counterexample to `(X ⊗ Y) ⊗ Z ≅ X ⊗ (Y ⊗ Z)` at the level of Hodge
numbers would refute the semiring claim.

### 2. A local-to-global gluing law: `E` is a finitely additive measure on stratifications, with vanishing first obstruction

Model a stratified variety as a presheaf of Hodge diamonds on a finite poset (the strata),
where restriction maps record "the diamond of the closure minus the open stratum". Conjecture
a Mayer–Vietoris / scissor law: for a decomposition into locally closed strata `S_i`,
`E(X) = Σ_i E(S_i)`, and more strongly that the assignment extends to a finitely additive
measure on the Boolean algebra these strata generate. **The key insight is** that because
`E` already factors through *signed* (Euler) sums, the cohomological obstruction to gluing
local E-data lives in `H¹` of the poset with coefficients in the additive group of
polynomials, and this group is *flasque* for the constant presheaf — so the obstruction
vanishes and local additivity forces global additivity. **Why now?** `epoly_directSum` is
exactly the two-stratum (disjoint-union) case; promoting it to an arbitrary finite poset is
the natural sheaf-theoretic generalisation and directly serves the engine's local-to-global
mandate. Falsifiable: exhibit a finite poset presheaf where the alternating stratum sum
disagrees with the global `E`, i.e. a non-trivial `H¹` class.

### 3. The motivic zeta function `Z(X; T) = Σ_n E(Symⁿ X) Tⁿ` is rational with a Serre-type functional equation

Define symmetric powers `Symⁿ X` of a Hodge diamond (the `Sⁿ`-invariant part of `X^{⊗ n}`)
and the generating series `Z(X; T) = Σ_{n ≥ 0} E(Symⁿ X) Tⁿ ∈ K[u,v][[T]]`. Conjecture
that `Z(X; T)` is a *rational* function of `T` and satisfies a functional equation in `T ↔
(uv)^{-?} T^{-1}` mirroring `poincare_serre_palindrome`. **The key insight is** that the
palindrome `P(X; t) = t^{2n} P(X; 1/t)` is the `n = 1` shadow of a functional equation of
the full zeta function under `s ↦ 2n − s`; Serre duality on each `Symⁿ X` should assemble
into a single symmetry of `Z`. **Why now?** We have just proved both the multiplicativity
(`epoly_kunneth`, which controls `E(X^{⊗ n})`) and the palindrome that the functional
equation must specialise to — the two ingredients a Kapranov-style motivic-zeta argument
requires. Falsifiable: compute `Z` for a small explicit diamond (e.g. `h^{0,0}=h^{1,1}=1`)
and check rationality and the predicted symmetry numerically.

### 4. The two-variable E-polynomial is a complete invariant for diamonds with Hodge symmetry and Serre duality

Conjecture that among `Supported` diamonds satisfying both Hodge symmetry `h^{p,q} = h^{q,p}`
and Serre duality, the map `X ↦ E(X; u, v)` is *injective* — i.e. the signed two-variable
polynomial recovers all individual Hodge numbers. **The key insight is** that the sign
`(-1)^{p+q}` only entangles anti-diagonals, but the two *separate* exponents `uᵖ vᵍ` keep
each cell `(p,q)` distinguishable, so the obstruction to injectivity is precisely a linear
system whose matrix is triangular once the imposed symmetries cut the unknowns in half.
**Why now?** The structural laws proved this cycle let us reduce the injectivity question to
the *indecomposable* generators of the Grothendieck ring (Direction 1), turning a global
uniqueness statement into a finite stalk-level linear-algebra check. Falsifiable, and quite
possibly *false* in characteristic `p` (where `(-1)` and cancellation behave differently) —
a counterexample there would itself be a valuable discovery sharpening the hypotheses.

### 5. A refined polynomial-level mirror map exchanging the two Hodge gradings

Strengthen `epoly_mirror_functional_equation` to a *full* mirror involution on
`CalabiYauData` that exchanges the roles of `u` and `v` (complex vs. Kähler moduli), and
prove the resulting Hodge-number exchange `h^{p,q}(X) = h^{n-p,q}(X^∨)` assembles into
`E(X^∨; u, v) = E(X; u, v)` evaluated with the gradings swapped. **The key insight is** that
the mirror reflection `(p,q) ↦ (n-p, q)` and Serre duality `(p,q) ↦ (n-p, n-q)` *generate a
dihedral group* acting on the index square, and the E-polynomial linearises this action into
a representation on `K[u,v]`; classifying that representation classifies all functional
equations the E-polynomial can satisfy. **Why now?** Both generating reflections are already
formalised (`epoly_mirror_functional_equation`, `epoly_serre_functional_equation`), so the
group they generate — and hence the complete symmetry group of `E` — is within immediate
reach. Falsifiable: the dihedral relation `(mirror ∘ serre)^k = id` predicts a specific finite
order; a diamond violating the induced E-polynomial identity refutes the representation.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- DIFF: Catalog/Applications/SpeciesAnalyticBridge.lean
--- a/Applications/SpeciesAnalyticBridge.lean
+++ b/Applications/SpeciesAnalyticBridge.lean
@@ -62,10 +62,14 @@
 @[simp] lemma egf_seqOf (f : ℚ⟦X⟧) : egf (seqOf f) = f := by
   ext n; rw [coeff_egf, seqOf]; field_simp
 
-/-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
-exponential generating functions. -/
-theorem egf_injective : Function.Injective egf := by
-  intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]
+-- NOTE (build fix): `egf_injective` is already declared in
+-- `Catalog/Applications/CombinatorialSpecies.lean` in this same namespace, so re-declaring it
+-- here is a duplicate declaration that breaks compilation.  Commented out; all references below
+-- resolve to `CombinatorialSpecies.egf_injective` from the imported base file.
+-- /-- **Complete invariance.** `egf` is injective: distinct counting sequences have distinct
+-- exponential generating functions. -/
+-- theorem egf_injective : Function.Injective egf := by
+--   intro a b h; rw [← seqOf_egf a, ← seqOf_egf b, h]
 
 /-- **Surjectivity.** Every formal power series over `ℚ` is the EGF of some counting
 sequence (namely `seqOf`). -/



-- NEW_FILE: Catalog/Bridges/HodgeEPolynomial.lean
/-
  # The Hodge–Deligne E-polynomial as a Motivic Measure

  This file develops the Hodge–Deligne E-polynomial

      E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ

  on an abstract combinatorial `HodgeDiamond` (complex dimension `dim` together
  with integer Hodge numbers `h p q`), and promotes it from a *single-variety*
  invariant to a *ring / measure level* invariant.

  We introduce the three universal operations on Hodge diamonds — direct sum
  `directSum`, tensor product `tensorProd` (the genuine Künneth convolution of
  Hodge numbers) and the Tate / Lefschetz twist `tateTwist` — and prove how `E`
  transforms under each:

  * `epoly_directSum`  — additivity            `E(X ⊕ Y) = E(X) + E(Y)`;
  * `epoly_kunneth`    — Künneth multiplicativity `E(X ⊗ Y) = E(X) · E(Y)`;
  * `eulerChar_kunneth`— numerical product law `χ(X ⊗ Y) = χ(X) · χ(Y)`;
  * `epoly_tateTwist`  — `E(X(1)) = uv · E(X)` (the Tate twist is the Lefschetz
                          class `𝕃 = uv`);
  * `epoly_serre_functional_equation` — Serre duality gives the Poincaré
                          functional equation `E(X) = (uv)ⁿ E(X; 1/u, 1/v)`;
  * `poincare_serre_palindrome` — its one-variable shadow `P(X; t) = t^{2n} P(X; 1/t)`.

  Together these say: `X ↦ E(X; u, v)` is a homomorphism of (semi)rings from the
  Grothendieck ring of supported Hodge diamonds (under `⊕`, `⊗`) into `K[u, v]`,
  intertwining the Tate twist with multiplication by `uv`.  In one phrase: **the
  E-polynomial is a motivic measure**.

  The proof rests on two reusable lemmas extracted in the file, `cauchy_prod_1D`
  and `cauchy_prod_2D` (truncated Cauchy products under a support hypothesis),
  which are exactly the local-to-global engine: the *global* invariant of a
  product factors through the *local* (factor) data, and the only assumption
  needed is `Supported`.

  Everything is over an arbitrary commutative ring `R` (a field `K` for the
  functional equation, where inverses appear).
-/
import Mathlib

open Finset

namespace HodgeEPolynomial

-- !-- Lab Notebook -- !--
-- Hypothesis: the signed two-variable E-polynomial of an abstract Hodge diamond
--   is a *motivic measure* — additive on direct sums, multiplicative on the
--   Künneth tensor product, and intertwining the Tate twist with multiplication
--   by the Lefschetz class 𝕃 = uv — and Serre duality forces a palindromic
--   functional equation.
-- Result: all headline facts proved with no `sorry` (cauchy_prod_1D,
--   cauchy_prod_2D, epoly_directSum, epoly_kunneth, eulerChar_kunneth,
--   epoly_tateTwist, epoly_serre_functional_equation, poincare_serre_palindrome).
-- Insight: the sign factorises, (-1)^{p+q} = (-1)^i(-1)^{p-i}(-1)^k(-1)^{q-k}
--   on the antidiagonal i+j=p, k+l=q, so the *entire* term function
--   T(i,k) = (-1)^{i+k} h(i,k) uⁱ vᵏ is multiplicative under convolution. Thus a
--   single truncated 2-D Cauchy product (`cauchy_prod_2D`) is the one engine that
--   powers Künneth; additivity is plain linearity and the Tate twist is a clean
--   reindex of the diamond by (p,q) ↦ (p+1,q+1).
-- Failure analysis: the support hypothesis `Supported` is essential — without it
--   `tensorProd`'s convolution range and the factor ranges do not line up and the
--   truncation in `cauchy_prod_2D` drops genuinely nonzero terms. The functional
--   equation must live over a *field* (inverses u⁻¹, v⁻¹) and uses the parity
--   identity (-1)^{2n-p-q} = (-1)^{p+q}.

/-! ## The abstract Hodge diamond -/

/-- An abstract **Hodge diamond**: a complex dimension `dim` together with integer
Hodge numbers `h p q` (the `(p,q)` Hodge number).  Negative or out-of-range
entries are simply `0` for a *supported* diamond. -/
structure HodgeDiamond where
  /-- The complex dimension. -/
  dim : ℕ
  /-- The Hodge numbers `h^{p,q}`. -/
  h : ℕ → ℕ → ℤ

/-- A diamond is **`Supported`** when its Hodge numbers are concentrated in
bidegrees `0 ≤ p, q ≤ dim`, the algebraic shadow of a pure Hodge structure on a
smooth projective variety of complex dimension `dim`. -/
def HodgeDiamond.Supported (X : HodgeDiamond) : Prop :=
  ∀ p q, (X.dim < p ∨ X.dim < q) → X.h p q = 0

/-- The **Hodge–Deligne E-polynomial** `E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ`,
evaluated at ring elements `u v : R`. -/
def EPoly {R : Type*} [CommRing R] (X : HodgeDiamond) (u v : R) : R :=
  ∑ p ∈ Finset.range (X.dim + 1), ∑ q ∈ Finset.range (X.dim + 1),
    (-1 : R) ^ (p + q) * (X.h p q : R) * u ^ p * v ^ q

/-- The **topological Euler characteristic** `χ(X) = Σ_{p,q} (-1)^{p+q} h^{p,q}`. -/
def eulerChar (X : HodgeDiamond) : ℤ :=
  ∑ p ∈ Finset.range (X.dim + 1), ∑ q ∈ Finset.range (X.dim + 1),
    (-1 : ℤ) ^ (p + q) * X.h p q

/-- The one-variable **Poincaré polynomial** `P(X; t) = E(X; t, t)`. -/
def poincarePoly {R : Type*} [CommRing R] (X : HodgeDiamond) (t : R) : R := EPoly X t t

/-! ## The three universal operations -/

/-- **Direct sum** of Hodge diamonds: `h^{p,q}(X ⊕ Y) = h^{p,q}(X) + h^{p,q}(Y)`. -/
def directSum (X Y : HodgeDiamond) : HodgeDiamond where
  dim := max X.dim Y.dim
  h := fun p q => X.h p q + Y.h p q

/-- **Tensor product** of Hodge diamonds, with the genuine Künneth convolution of
Hodge numbers `h^{p,q}(X ⊗ Y) = Σ_{i+j=p, k+l=q} h^{i,k}(X) h^{j,l}(Y)`. -/
def tensorProd (X Y : HodgeDiamond) : HodgeDiamond where
  dim := X.dim + Y.dim
  h := fun p q => ∑ i ∈ Finset.range (p + 1), ∑ k ∈ Finset.range (q + 1),
        X.h i k * Y.h (p - i) (q - k)

/-- The **Tate / Lefschetz twist** `X(1)`: shift the diamond by `(p,q) ↦ (p+1,q+1)`,
so `h^{p,q}(X(1)) = h^{p-1,q-1}(X)` (and `0` on the `p = 0` or `q = 0` edge). -/
def tateTwist (X : HodgeDiamond) : HodgeDiamond where
  dim := X.dim + 1
  h := fun p q => match p, q with
        | p + 1, q + 1 => X.h p q
        | _, _ => 0

/-! ## The Cauchy-product engine -/

/-
!-- comment -- !--
Extend both factor sums to `range (N+M+1)` (the new terms vanish by support),
expand the product with `Finset.sum_mul_sum`, and regroup the double sum by the
value `p = i + j` of the antidiagonal via `Finset.sum_range_succ`-style nested
reindexing; terms with `p > N+M` are zero.
!-- comment -- !--

**Truncated 1-D Cauchy product.**  For `f` supported on `[0,N]` and `g` on
`[0,M]`, the product of the truncated sums is the convolution truncated at
`N+M`.
-/
theorem cauchy_prod_1D {R : Type*} [CommRing R] (f g : ℕ → R) (N M : ℕ)
    (hf : ∀ i, N < i → f i = 0) (hg : ∀ j, M < j → g j = 0) :
    (∑ i ∈ range (N + 1), f i) * (∑ j ∈ range (M + 1), g j)
      = ∑ p ∈ range (N + M + 1), ∑ i ∈ range (p + 1), f i * g (p - i) := by
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ p ∈ Finset.range (N + M + 1), ∑ i ∈ Finset.range (p + 1), f i * g (p - i) = ∑ i ∈ Finset.ra
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Hodge–Deligne E-polynomial as a Motivic Measure

## Synthesis

This cycle builds, from the ground up, the Hodge–Deligne E-polynomial

```
E(X; u, v) = Σ_{p,q} (-1)^{p+q} h^{p,q} uᵖ vᵍ
```

on an abstract combinatorial `HodgeDiamond` (a complex dimension `dim` together
with integer Hodge numbers `h p q`), living in `Catalog/Bridges/HodgeEPolynomial.lean`,
and immediately promotes it from a *single-variety* invariant to a *ring / measure
level* invariant. We introduce the three universal operations on Hodge diamonds —
direct sum `directSum` (`⊕`), tensor product `tensorProd` (`⊗`, with the genuine
Künneth convolution of Hodge numbers), and the Tate / Lefschetz twist `tateTwist`
(`X(1)`) — and prove how `E` transforms under each:

* `epoly_directSum` — **additivity** `E(X ⊕ Y) = E(X) + E(Y)`;
* `epoly_kunneth` — **Künneth multiplicativity** `E(X ⊗ Y) = E(X) · E(Y)`;
* `eulerChar_kunneth` — the numerical product law `χ(X ⊗ Y) = χ(X) · χ(Y)`;
* `epoly_tateTwist` — `E(X(1)) = uv · E(X)` (the Tate twist acts as the Lefschetz
  class `𝕃 = uv`);
* `epoly_serre_functional_equation` — Serre duality gives the Poincaré functional
  equation `E(X; u, v) = (uv)ⁿ E(X; 1/u, 1/v)`;
* `poincare_serre_palindrome` — its one-variable specialisation
  `P(X; t) = E(X; t, t)` is palindromic `P(X; t) = t^{2n} P(X; 1/t)`.

Together these say: `X ↦ E(X; u, v)` is a homomorphism of (semi)rings from the
Grothendieck ring of supported Hodge diamonds (under `⊕`, `⊗`) into `K[u, v]`,
intertwining the Tate twist with multiplication by `uv`. In one phrase: **the
E-polynomial is a motivic measure.** The proof rests on two reusable lemmas
extracted in the file, `cauchy_prod_1D` and `cauchy_prod_2D` (truncated Cauchy
products under a one-sided/two-sided support hypothesis), which are exactly the
local-to-global engine: the *global* invariant of a product factors through the
*local* (factor) data, and the only assumption needed for multiplicativity is
`Supported` — the algebraic shadow of a Hodge structure concentrated in degrees
`0 … n`. (Pleasantly, the functional equation turned out to need only Serre
duality, not `Supported`, since `E` ranges over `0 … n` by construction; the Lean
statement records this sharpening.)

## Results Summary

All results are over an arbitrary commutative ring `K` (a field for the functional
equation, where inverses appear) and are verified with **no `sorry`** and only the
standard axioms `propext, Classical.choice, Quot.sound`.

| Theorem | Statement |
|---|---|
| `cauchy_prod_1D` | truncated 1-D Cauchy product under one-sided support |
| `cauchy_prod_2D` | truncated 2-D Cauchy product (two applications of the 1-D form) |
| `epoly_directSum` | `E(X ⊕ Y) = E(X) + E(Y)` |
| `epoly_kunneth` | `E(X ⊗ Y) = E(X) · E(Y)` |
| `eulerChar_kunneth` | `χ(X ⊗ Y) = χ(X) · χ(Y)` |
| `epoly_tateTwist` | `E(X(1)) = uv · E(X)` |
| `epoly_serre_functional_equation` | `E(X) = (uv)ⁿ E(X; 1/u, 1/v)` under Serre duality |
| `poincare_serre_palindrome`
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
