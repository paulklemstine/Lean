# Future Directions: Intersection Forms and the Smooth 4D Poincaré Frontier

## Synthesis

The `SmoothPoincare` nucleus now contains three layers. `IntersectionForms.lean`
fixes the algebraic vocabulary — symmetric integral Gram matrices with the predicates
`Unimodular` (Poincaré duality), `IsEven` (spin), `StdDiagonalizable` (Donaldson's
conclusion) — and proves the obstruction `even_not_stdDiagonalizable`, instantiated by
the rank-`8` `E8form`. This cycle added two structural extensions:

* **`DirectSum.lean`** makes the orthogonal sum `⊕ᵢ` (the algebraic connected sum
  `M # N`) a first-class operation and proves that all three predicates are *closed*
  under it (`directSum_unimodular`, `directSum_isEven`, `directSum_stdDiagonalizable`).
  The decisive corollary `E8E8_not_stdDiagonalizable` shows the obstruction is
  **stable**: the rank-`16`, signature-`16` form `E8 ⊕ E8` clears Rokhlin's hurdle yet
  still fails Donaldson. The single odd diagonal value that detects the obstruction
  survives orthogonal summation, so connected sums cannot smooth it away.

* **`HomotopySphere.lean`** proves a sharp *negative metatheorem*: every rank-`0`
  intersection form equals `sphereForm` (`intersectionForm_zero_unique`), so the
  intersection form is constant on homotopy 4-spheres
  (`HomotopySphere4.form_indistinguishable`). The toolkit is provably blind to exotic
  smooth structure on `S⁴` — which is exactly why the smooth 4D Poincaré conjecture
  requires genuinely smooth (gauge-theoretic / Seiberg–Witten) input.

Together these isolate *where* algebra stops and analysis must begin: the additive
structure (`⊕ᵢ`) carries every algebraic invariant faithfully, the obstruction is
stable under it, and on the rank-`0` boundary the algebra collapses entirely.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `even_diag_of_isEven` | even form ⇒ even diagonal (converse of `isEven_of_even_diag`) | proved |
| `reindex_fromBlocks_diag_isSymm` | reindexed block-diagonal of symmetric blocks is symmetric | proved |
| `directSum_unimodular` | `Unimodular` closed under `⊕ᵢ` | proved |
| `directSum_isEven` | `IsEven` closed under `⊕ᵢ` | proved |
| `directSum_stdDiagonalizable` | `StdDiagonalizable` closed under `⊕ᵢ` | proved |
| `E8E8_even`, `E8E8_unimodular` | `E8 ⊕ E8` is even and unimodular | proved |
| `E8E8_not_stdDiagonalizable` | `E8 ⊕ E8` (signature 16) still fails Donaldson | proved |
| `intersectionForm_zero_unique` | every rank-0 form equals `sphereForm` | proved |
| `HomotopySphere4.form_indistinguishable` | intersection form constant on homotopy 4-spheres | proved |

All results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Direction 1 — A formal `signature` and the van der Blij congruence

**Conjecture.** Equip diagonalizable forms with an integer `signature` (number of
positive minus negative diagonal entries after an `ℝ`-diagonalization) that is *additive*
under `⊕ᵢ`: `signature (Q ⊕ᵢ R) = signature Q + signature R`. Then for any unimodular
`Q` there is a characteristic element `c` (with `Q.value v ≡ c ⬝ᵥ v (mod 2)` for all `v`)
satisfying `Q.value c ≡ signature Q (mod 8)`; for even forms one may take `c = 0`, giving
`8 ∣ signature Q`.

The key insight is that the characteristic element compresses the obstruction
`even_not_stdDiagonalizable` into a single `ℤ/8`-valued invariant: oddness of the
diagonal of the standard form is precisely the statement `c ≠ 0`, and van der Blij's
lemma turns that parity datum into a signature congruence. Why now? `DirectSum.lean`
already proves additivity of the structural predicates by pure block algebra, so the
*same* `fromBlocks`/`reindex` machinery (`directSum_stdDiagonalizable` in particular)
gives signature-additivity for free, leaving only the mod-8 bookkeeping on the diagonal
case — a self-contained next step that reuses `value_basisChange` verbatim.

## Direction 2 — The 8-divisibility theorem for even unimodular definite forms

**Conjecture.** Add a `PosDef` predicate (`∀ v ≠ 0, 0 < Q.value v`). Every positive
*definite*, *even*, *unimodular* `Q : IntersectionForm n` has rank divisible by `8`:
`Unimodular Q → IsEven Q → PosDef Q → 8 ∣ n`. The base case `n = 8` is realized by
`E8form` and `n = 16` by `E8E8form`.

The key insight is that evenness plus unimodularity force, over `ℝ`, an embedding into
the even unimodular lattice tower whose signature is constrained mod 8; the rank `8` of
`E8form` is the minimal witness, so `even_not_stdDiagonalizable` is really the `n < 8`
shadow of a mod-8 law. Why now? With Direction 1's `signature` in hand, the definite
case forces `signature = ± rank`, collapsing the mod-8 signature congruence directly to
`8 ∣ n`; and `E8form`/`E8E8form` already supply the two smallest sharpness witnesses, so
the theorem can be tested against concrete data the instant it is stated.

## Direction 3 — Rokhlin as a `ℤ/16` obstruction via a `Smoothable` predicate

**Conjecture.** Introduce a `Smoothable` predicate that *abstracts* the analytic inputs
as hypotheses (never axioms): a `Smoothable` even form has signature divisible by `16`.
Then prove the sharp comparison — `E8form` fails Donaldson at rank `8`
(`E8_not_stdDiagonalizable`) while `E8E8form` passes Rokhlin (signature `16`,
`E8E8_even`, `E8E8_unimodular`) yet still fails Donaldson (`E8E8_not_stdDiagonalizable`),
so `E8 ⊕ E8` is the *smallest* even unimodular form separating the two obstructions.

The key insight is that the analytic (Donaldson) and characteristic-class (Rokhlin)
obstructions are genuinely independent: one is detected by a diagonal parity that
survives `⊕ᵢ`, the other by a signature congruence that `E8 ⊕ E8` satisfies. Why now?
`E8E8form` is already built and fully certified in `DirectSum.lean`; the
`Smoothable`-as-hypothesis pattern keeps the development axiom-free while still proving a
crisp, falsifiable separation theorem — it is one definition plus one `⟨...⟩` away.

## Direction 4 — A stable cancellation law for the obstruction

**Conjecture.** Formalize a *stable* Donaldson statement: if `Q ⊕ᵢ (stdForm k)` is
standard-diagonalizable for some `k`, then the *even part* of `Q` is trivial — adding
`ℂP²` summands (`stdForm`) cannot retroactively diagonalize an even summand. Concretely,
prove the contrapositive obstruction transfers: if `Q` is even of positive rank then
`Q ⊕ᵢ R` is never even-diagonalizable for any `R` that keeps it even, mirroring Wall's
stabilization theorem (diffeomorphism after enough `S²×S²` summands).

The key insight is that the obstruction lives in a single odd diagonal entry that is
*invariant* under orthogonal summation, exactly as `directSum_isEven` and
`E8E8_not_stdDiagonalizable` already exhibit; stability is therefore an algebraic
fixed-point statement, not an analytic one. Why now? `⊕ᵢ` and its closure lemmas are
proved, so the only new ingredient is tracking the parity through `stdForm k` — a finite
diagonal computation entirely within reach of the existing `even_diag_of_isEven` /
`isEven_of_even_diag` pair.

## Direction 5 — Indefinite forms and the Hasse–Minkowski classification

**Conjecture.** Define the hyperbolic plane `H = ⟨0,1;1,0⟩` and the `K3` form
`E8 ⊕ E8 ⊕ H ⊕ H ⊕ H` (after sign change), and prove the *indefinite* classification:
every indefinite unimodular form is `⊕ᵢ`-equivalent either to `⟨1⟩^a ⊕ ⟨-1⟩^b` (odd) or
to `(±E8)^a ⊕ H^b` (even), the Hasse–Minkowski / Milnor classification. As a first
milestone, prove `H` is even, unimodular, and indefinite, and that `H ⊕ᵢ H` is
standard-diagonalizable over `ℤ` while `E8 ⊕ᵢ H` is *not* even though both have
signature `0`.

The key insight is that indefiniteness restores cancellation (lost in the definite
world), so `⊕ᵢ`-equivalence becomes a *complete* invariant — the polar opposite of the
rank-`0` collapse in `HomotopySphere.lean`, where the invariant is trivially complete by
being constant. Why now? `DirectSum.lean` supplies the equivalence-preserving operation
`⊕ᵢ` and all three closure lemmas; defining `H` is a two-line matrix literal, and the
even/odd dichotomy can be checked computationally exactly as `E8_even` was, making this
the natural bridge from the definite obstruction theory to the full classification.
