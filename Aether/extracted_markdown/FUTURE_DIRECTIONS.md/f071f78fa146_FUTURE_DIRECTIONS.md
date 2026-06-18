# Future Directions: Quotient Closure and Beyond

## Synthesis

The quotient closure theorem establishes that the Hardy hierarchy is compatible with division under appropriate admissibility conditions. This opens five interconnected research directions, all building toward the grand goal of a **fully formal Hardy differential field** embeddable into the transseries universe. The directions form a dependency chain: Direction 1 (reciprocal constructor) enables Direction 2 (unconditional quotient closure), which enables Direction 3 (localization), which enables Direction 4 (transseries embedding). Direction 5 (sharpness) is independent and provides the theoretical depth needed to understand the hierarchy's fine structure. Together, these directions chart a path from the current differential-ring formalization to a complete differential-field theory with certified asymptotic operations.

---

## Direction 1: Native Reciprocal Constructor for HardyLevel

**Conjecture:** The `HardyLevel` inductive can be extended with a reciprocal constructor
```
| recip {n f} : HardyLevel n f → EventuallyNonzero f → HardyLevel n (fun x => 1 / f x)
```
such that all existing theorems (`hardyLevel_mono`, `emlDepth_le_hardyLevel`, `hardyLevel_deriv_le_succ`, `iterExp_mem_hardyLevel`) remain provable, and the strict separation theorems (`exp_not_hardyLevel_zero`, `iterExp_succ_not_hardyLevel`) are not disrupted.

**Test:** After adding the constructor:
1. Re-prove `hardyLevel_zero_poly_bound` (the inductive proof must handle the new case).
2. Re-prove `exp_not_hardyLevel_zero` (reciprocals of polynomials have polynomial growth, so the new case should be straightforward).
3. Verify that the polynomial growth bound still implies separation.
4. Computational test: for 100 randomly generated HardyLevel-0 functions using the new constructor, verify `|f(x)| ≤ C · x^d` numerically on [1, 10⁶].

**Impact:** Eliminates the `inv_sq_level` hypothesis from `QuotientAdmissible`, yielding an unconditional quotient closure theorem. This is the single most impactful infrastructure improvement.

**Catalog References:**
- `MachineLearning/HardyHierarchy/Defs.lean` → `HardyLevel` inductive
- `Speculative/HardyHierarchy/Theorems.lean` → `hardyLevel_zero_poly_bound`, `exp_not_hardyLevel_zero`
- `Pythagorean/HardyHierarchy/Separation.lean` → `iterExp_succ_not_hardyLevel`

**Proof Strategy:** The key difficulty is the growth bound lemma: one must show that 1/*f* has polynomial growth when *f* has polynomial growth and is eventually nonzero. This requires: if |*f*(*x*)| ≥ *c* > 0 eventually (from eventual nonzero + continuity + level-0 structure), then |1/*f*(*x*)| ≤ 1/*c*. The challenge is extracting a uniform lower bound from the Hardy level structure.

**Domain Bridges:** Differential algebra (field closure), transseries (coefficient inversion).

**Lineage:** Direct extension of current `HardyLevel` inductive.

**Ambition:** High — this is foundational infrastructure that unlocks multiple downstream results.

---

## Direction 2: Unconditional Quotient Closure via Full Field Structure

**Conjecture:** With the reciprocal constructor from Direction 1, the following unconditional theorem holds:

*If* `HardyLevel d f`, `HardyLevel d g`, `EventuallyNonzero g`, `HardyLevel (d+1) (deriv f)`, and `HardyLevel (d+1) (deriv g)`, *then* `HardyLevel (d+1) (deriv (fun x => f x / g x))`.

No `inv_sq_level` hypothesis is needed.

**Test:**
1. Derive `HardyLevel d (fun x => 1/(g x))` from the reciprocal constructor.
2. Derive `HardyLevel d (fun x => 1/(g x)²)` from squaring closure.
3. Apply monotonicity to get `HardyLevel (d+1) (fun x => 1/(g x)²)`.
4. Apply the existing `hardyLevel_deriv_div_le_succ`.
5. Computational: verify on 50 expression pairs that the theorem's conclusion holds numerically.

**Impact:** Makes the quotient closure theorem fully self-contained — no external hypothesis about denominator reciprocals.

**Catalog References:**
- `Pythagorean/HardyHierarchy/QuotientClosure.lean` → `hardyLevel_deriv_div_le_succ`, `QuotientAdmissible`
- `Speculative/HardyHierarchy/Theorems.lean` → `hardyLevel_mono`

**Proof Strategy:** Mechanical — compose the reciprocal constructor with existing squaring and monotonicity lemmas.

**Domain Bridges:** Asymptotic numerics (Padé theory needs unconditional division).

**Lineage:** Depends on Direction 1.

**Ambition:** Medium — conceptually straightforward once Direction 1 is done, but the formal execution may require care with the inductive proofs.

---

## Direction 3: Localization of the Differential Ring

**Conjecture:** The multiplicative set *S* of eventually nonzero Hardy-level-*d* functions forms a multiplicative submonoid of the ring of Hardy-level-*d* functions, and the localization *R*_*S* inherits:
1. A differential structure (the derivative descends to the quotient).
2. The Hardy-level filtration (localized elements have well-defined levels).
3. The *d* + 1 derivative bound (the filtration is compatible with differentiation).

**Test:**
1. Define `EventuallyNonzeroSubmonoid d` as a `Submonoid` of the ring of level-*d* functions.
2. Verify the multiplicative submonoid axioms: 1 ∈ *S* (the constant 1 is eventually nonzero), and if *f*, *g* ∈ *S* then *fg* ∈ *S*.
3. Define the localization using Mathlib's `Localization` API.
4. Prove that the derivative respects the localization equivalence relation: if *a*/*s* = *b*/*t* then (*a*/*s*)' = (*b*/*t*)' eventually.
5. Computational: construct 20 localization equivalence classes and verify consistency.

**Impact:** This gives the algebraically correct object: a filtered differential localization, which is the formal precursor to a Hardy differential field.

**Catalog References:**
- `Pythagorean/HardyHierarchy/QuotientClosure.lean` → `EventuallyNonzero`, `QuotientAdmissible`
- Mathlib → `Localization`, `Submonoid`

**Proof Strategy:** Use Mathlib's localization API (`Localization.mk`, `Localization.lift`). The main difficulty is showing the derivative is well-defined on equivalence classes, which requires the quotient-rule computation.

**Domain Bridges:** Commutative algebra (localization theory), algebraic geometry (germs of functions), differential algebra (differential rings and fields).

**Lineage:** Depends on Directions 1 and 2.

**Ambition:** Grand challenge — this is a conceptually deep formalization that would be a significant contribution to formal mathematics.

---

## Direction 4: Transseries Embedding

**Conjecture:** The quotient-closed Hardy hierarchy (from Directions 1–3) admits a filtered differential-field embedding into the ordered field of transseries 𝕋, in the sense that:
1. Each Hardy level *d* maps into a specific "support-depth" stratum of 𝕋.
2. The embedding preserves the derivative (i.e., it is a differential-field homomorphism).
3. The embedding preserves the ordering (eventually positive functions map to positive transseries).

**Test:**
1. Define a map from PosEMLExpr to formal transseries (as Hahn series or a simplified syntactic model).
2. Verify the map preserves eval, deriv, and depth on 50 test expressions.
3. Check order-preservation: eventually positive expressions map to positive transseries.
4. Computational: compare asymptotic expansions of quotient derivatives in both representations.

**Impact:** This would be the first formally verified embedding of a concrete asymptotic hierarchy into the transseries universe, connecting the computational world (expressions, algorithms) to the model-theoretic world (Aschenbrenner–van den Dries–van der Hoeven).

**Catalog References:**
- All Hardy hierarchy files
- Potentially new `Transseries/` module

**Proof Strategy:** Start with a syntactic embedding: PosEMLExpr maps naturally to monomials in the log-exp algebra. The derivative correspondence follows from the chain rule. The ordering requires the eventual positivity results from the hierarchy.

**Domain Bridges:** Model theory (transseries as models of the theory of the reals with exponentiation), surreal numbers (Conway's number system includes transseries), theoretical computer science (decision procedures for exponential arithmetic).

**Lineage:** Depends on Directions 1–3.

**Ambition:** Grand challenge — this connects formal verification to one of the deepest results in contemporary asymptotic algebra.

---

## Direction 5: Sharpness of the *d* + 1 Bound

**Conjecture:** The *d* + 1 bound in the quotient closure theorem is **sharp**: for every *d* ≥ 1, there exist PosEML expressions *a*, *b* of depth *d* with *b* eventually positive such that the quotient-rule derivative (*a*/*b*)' has exact Hardy rank *d* + 1 (belongs to level *d* + 1 but not level *d*).

**Counter-conjecture:** The bound is **not sharp** — the quotient-rule derivative always remains at level *d*.

**Test:**
1. For *d* = 1: try *a* = exp(*x*), *b* = exp(*x*) + 1. Then (*a*/*b*)' should be computed exactly.
2. For *d* = 2: try nested exponentials. Compute (*a*/*b*)' and check if it genuinely exceeds level *d* growth.
3. Enumerate all depth-*d* pairs for *d* ∈ {1, 2, 3} and compute the maximum estimated Hardy level of (*a*/*b*)'.
4. If no pair achieves level *d* + 1, this disproves sharpness.

**Impact:** Resolving sharpness would either (a) demonstrate that the quotient operation genuinely increases asymptotic complexity (a deep structural result), or (b) show that the *d* + 1 bound can be tightened to *d* (an improvement of the main theorem).

**Catalog References:**
- `Pythagorean/HardyHierarchy/QuotientClosure.lean` → `hardyLevel_deriv_div_le_succ`
- `Pythagorean/HardyHierarchy/Separation.lean` → strict separation infrastructure

**Proof Strategy:** For sharpness, one needs to construct explicit examples and use the separation theorems to prove the derivative is not at level *d*. For non-sharpness, one would need a refined analysis of the quotient-rule numerator showing it always stays at level *d*.

**Domain Bridges:** Complexity theory (hierarchy collapses), number theory (growth of arithmetic functions).

**Lineage:** Independent of Directions 1–4.

**Ambition:** Medium-high — the answer is not obvious and would be a genuine mathematical contribution.
