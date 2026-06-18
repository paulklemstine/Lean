# Future Directions — Smooth 4D Poincaré: the Intersection-Form Engine

## Synthesis

The catalog already contained a single, sharp witness of the smooth/topological gap in
dimension four: the `E8` form (`Applications/SmoothPoincare/IntersectionForms.lean`) is
even, unimodular, and *not* standard-diagonalizable, so by Donaldson's theorem it is not
the intersection form of any smooth closed simply-connected 4-manifold — even though
Freedman realizes it topologically.

This cycle reframed that isolated fact as a **structural law of a symmetric monoidal
category of integral symmetric forms**. In
`Applications/SmoothPoincare/DirectSumObstruction.lean` we generalized the theory from
`Fin n` to an arbitrary finite index `ι` (`GForm ι`), proved Donaldson's parity
obstruction at that generality (`even_not_stdDiagonalizable`), and showed that all three
governing predicates — `Unimodular`, `IsEven`, `StdDiagonalizable` — are **additive**
under the orthogonal direct sum `⊕` (`dsum_unimodular`, `dsum_even`,
`dsum_stdDiagonalizable`, with the value-splitting lemma `dsum_value`). The capstone
`E8_sum_E8_obstruction` assembles these into the rank-16 spin/`11/8`-boundary witness:
`E8 ⊕ E8` is unimodular, even, and not standard-diagonalizable.

## Results Summary

- `GForm ι`: symmetric integral form over any finite index type (generalizes the catalog
  `Fin n` `IntersectionForm`).
- `value_basisChange`: congruence transports the quadratic value.
- `even_not_stdDiagonalizable`: the Donaldson parity obstruction, any nonempty `ι`.
- `isEven_of_even_diag`: even diagonal ⟹ even form (symmetric-sum splitting).
- `dsum`, `dsum_value`, `dsum_even`, `dsum_unimodular`, `dsum_stdDiagonalizable`: the
  monoidal additivity laws of the form category.
- `E8_sum_E8_obstruction`: `E8 ⊕ E8` is unimodular, even, not standard-diagonalizable.
- Axioms: `propext, Classical.choice, Quot.sound` only; zero `sorry`.

## Research Directions

### 1. Positive-definiteness of `E8` and the signature invariant
Formalize that `E8mat` is positive-definite over `ℝ` (equivalently, all eight leading
principal minors are positive — Sylvester's criterion), and define the signature `σ(Q) =
b₊ − b₋` of a `GForm`, proving it is additive: `σ(Q ⊕ R) = σ(Q) + σ(R)`. Then
`σ(E8) = 8` and `σ(E8 ⊕ E8) = 16`. **The key insight is** that signature is the *second*
independent congruence invariant (after parity), and `dsum`-additivity for it is the same
monoidal argument already proven for the three predicates here, so the present `dsum`
infrastructure transfers almost verbatim. **Why now?** With `dsum_value` and the
block-determinant machinery already in place, the only missing ingredient is a finite
minor computation that `decide`/`norm_num` can attack on the explicit `8×8` matrix; this
is the cheapest remaining concrete obstacle and unlocks every divisibility statement
below.

### 2. Rokhlin's theorem as a divisibility law: `16 ∣ σ` for even forms
Conjecture and formalize the algebraic shadow of Rokhlin's theorem: for the forms that
arise as smooth spin intersection forms, the signature is divisible by 16; in particular
`σ(E8) = 8` is *not* divisible by 16, giving a second, signature-based proof that `E8`
is not smoothly realizable, independent of diagonalizability. **The key insight is** that
the diagonalizability obstruction (`even_not_stdDiagonalizable`) and the Rokhlin
divisibility obstruction are two faces of the *same* even-unimodular rigidity, and proving
both for one form is a falsifiable cross-check of the framework. **Why now?** Direction 1
delivers `σ(E8) = 8`; the divisibility step is then pure `Int` arithmetic (`¬ 16 ∣ 8`),
needing no new geometry.

### 3. Classification of indefinite unimodular forms (Hasse–Minkowski shadow)
State and prove the algebraic core of the classification theorem: every *indefinite*
unimodular `GForm` is congruent to an orthogonal sum of copies of the hyperbolic form
`H = !![0,1;1,0]` (even case) or of `⟨1⟩` and `⟨-1⟩` (odd case). Build `H` as a `GForm`,
prove it unimodular and even, and show `H ⊕ H`, `E8 ⊕ H`, etc. are congruence-normal
forms. **The key insight is** that the `dsum` monoid is *freely generated* (in the
indefinite range) by `H`, `⟨1⟩`, `⟨-1⟩`, so classification becomes a normal-form theorem
about the monoid we already built. **Why now?** `dsum_stdDiagonalizable` shows congruence
is preserved by `⊕`; extending it to a `Congr` equivalence relation and proving `H ⊕ ⟨1⟩ ≅
⟨1⟩ ⊕ ⟨1⟩ ⊕ ⟨-1⟩`-type relations is the natural next layer on the existing definitions.

### 4. The `11/8`-conjecture inequality as a form-theoretic statement
Formalize the Furuta `10/8`-type inequality target: for an even unimodular form of
signature `σ` and rank `r` realized by a smooth spin 4-manifold, `r ≥ (11/8)|σ|` (the
conjectural bound), with the proven Furuta bound `r ≥ (10/8)|σ| + 2` as the falsifiable
milestone. Encode `E8 ⊕ E8 ⊕ 3H` (the K3 form, rank 22, signature 16) as the extremal
witness. **The key insight is** that the entire conjecture is an inequality between two
*additive* functionals on the `dsum` monoid (rank and `|signature|`), so it is a linear
statement on the monoid's generators once signature (Direction 1) exists. **Why now?**
K3's form is literally `dsum`-built from `E8` and `H`, both of which this cycle already
constructs or scopes, making the extremal case directly expressible.

### 5. A `Congr`-invariance API and the categorical packaging
Promote congruence to a typeclass-friendly equivalence on `GForm`, prove `IsEven`,
`Unimodular`, and (once defined) `signature` are `Congr`-invariants, and package `dsum`
as a `CommMonoid`/symmetric-monoidal structure on congruence classes. **The key insight
is** that "smooth-obstruction invariants are exactly the additive congruence-invariant
functionals on the form monoid," turning Donaldson/Rokhlin/Furuta into statements about a
single algebraic object. **Why now?** All three predicates are already proven additive
here; lifting them to a quotient `CommMonoid` is a mechanical but high-leverage
refactor that makes every later theorem a one-liner about monoid homomorphisms.
