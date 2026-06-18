# FUTURE_DIRECTIONS — Congruence Invariance of the Donaldson Obstruction

## Synthesis

The catalog file `Applications/SmoothPoincare/IntersectionForms.lean` formalized the
*algebraic heart* of the smooth 4D Poincaré story: the Donaldson obstruction
`even_not_stdDiagonalizable` (a positive-rank **even** integral form is never equivalent
to the standard form `⟨1⟩ⁿ`), together with its application to the `E8` lattice
(`E8_not_stdDiagonalizable`). That result was *pointwise*: it spoke about one fixed Gram
matrix. But the intersection form of a 4-manifold is only defined up to a unimodular
change of basis of `H²`, so the mathematically correct object is the **congruence class**,
not the matrix. This cycle closed that gap.

The structural insight that emerged is that the Donaldson predicates split sharply by
their behaviour under congruence `Tᵀ G T = G'`. We proved that **evenness** and
**standard-diagonalizability** are both congruence invariants (`congruent_isEven`,
`congruent_stdDiagonalizable_iff`), and that integral congruence is a genuine equivalence
relation (`congruent_refl/symm/trans`). The decisive — and only nontrivial — step was
*symmetry*: it is exactly the statement that a unimodular integral matrix has an integral
inverse, which is precisely what Poincaré-duality unimodularity supplies. A useful
reframing also fell out: standard-diagonalizable forms *represent 1*
(`stdDiagonalizable_represents_one`) while even forms *represent no odd value*
(`isEven_not_represents_odd`), so the obstruction is cleanest as "1 is odd, even forms
can't reach it." This `Represents` lens, plus degree-2 homogeneity (`value_smul`), is the
reusable engine for everything downstream. The payoff theorem,
`congruent_E8_not_stdDiagonalizable`, upgrades the single `E8` witness to its entire
congruence class: *no* presentation of the `E8` lattice in any `H²`-basis is the
intersection form of a smooth closed simply-connected definite 4-manifold.

What did *not* yet get formalized is the analytic half (Donaldson's gauge theory) and the
deeper lattice theory (definiteness, the rank-8 minimality of `E8`, the
even-unimodular-signature constraints). Those are the natural next frontiers, and the
`Represents`/`Congruent` API built here is exactly the scaffolding they need.

## Results Summary

- `value_smul`: proved — quadratic forms are homogeneous of degree 2, `Q(a·v)=a²Q(v)`; the algebraic reason `represents 1` is the right primitive.
- `stdDiagonalizable_represents_one`: proved — a standard-diagonalizable positive-rank form represents the value 1, re-expressing the obstruction via represented values.
- `isEven_not_represents_odd`: proved — even forms represent no odd value (dimension-free).
- `even_not_stdDiagonalizable_via_represents`: proved — clean re-derivation of the catalog obstruction through the represented-value lens.
- `congruent_refl` / `congruent_symm` / `congruent_trans`: proved — integral congruence of Gram matrices is an equivalence relation; symmetry encodes integral invertibility of unimodular matrices.
- `congruent_isEven`: proved — evenness (spin-ness) is invariant under integral congruence.
- `StdDiagonalizable.of_congruent` / `congruent_stdDiagonalizable_iff`: proved — standard-diagonalizability is a congruence invariant.
- `congruent_E8_not_stdDiagonalizable`: proved — **main result**: every form in `E8`'s congruence class is obstructed, the basis-free form of the smooth/topological gap.

## Research Directions

### Direction 1: Unimodularity is a congruence invariant
**Hypothesis**: If `Congruent Q Q'` then `Q.Unimodular ↔ Q'.Unimodular`; more precisely
`Q'.gram.det = (T.det)^2 * Q.gram.det`, so determinants in a congruence class differ by a
unit square and `±1`-unimodularity is preserved.
**Test**: Prove `det (Tᵀ * G * T) = (det T)^2 * det G` via `Matrix.det_mul` and
`Matrix.det_transpose`, then conclude `IsUnit` transfers (and use `congruent_symm` for the
reverse). A disproof would require a congruence changing a unit determinant to a non-unit,
impossible over `ℤ`, so the experiment is purely a transfer lemma.
**Why now**: The congruence equivalence relation and its symmetry are already in hand, and
`congruent_isEven` is the exact template — only the determinant computation is new.
The key insight is that *every* numerical congruence invariant factors through
`det(Tᵀ G T) = (det T)² det G`.
**If true**: Completes the invariance trinity (even, std-diagonalizable, unimodular) and
lets one speak of "the discriminant of a congruence class."
**If false**: Would expose a defect in the `ℤ`-unimodular definition and force a move to
genuine lattice discriminant groups.

### Direction 2: The diagonal lattice `⟨1⟩ⁿ` is rigid — only odd forms can be standard
**Hypothesis**: For `n > 0`, `Q.StdDiagonalizable → ¬ Q.IsEven`; equivalently the standard
form is the unique even-or-odd dichotomy point: standard ⇒ odd.
**Test**: This is `even_not_stdDiagonalizable_via_represents` contrapositive-packaged; prove
`StdDiagonalizable → Represents 1 → ¬ IsEven` and expose it as a named `Odd`-flavoured
lemma `stdDiagonalizable_not_even`. Boundary case `n = 0`: `sphereForm` is *both* even and
standard, so the hypothesis must carry `0 < n`.
**Why now**: `stdDiagonalizable_represents_one` and `isEven_not_represents_odd` already
compose to give it; this is a one-line corollary that sharpens the catalog's `stdForm_not_even`.
The key insight is that parity of represented values is the single bit distinguishing the
standard lattice from `E8`.
**If true**: Gives a clean parity classification of standard-diagonalizable forms.
**If false (only at `n=0`)**: Pinpoints exactly where the obstruction degenerates — the
rank-zero sphere — which is itself the reason 4D Poincaré is invisible to intersection forms.

### Direction 3: Direct sums and the `Represents` semiring
**Hypothesis**: Define `Q ⊕ Q'` with block-diagonal Gram matrix; then
`(Q ⊕ Q').Represents (a + b)` whenever `Q.Represents a` and `Q'.Represents b`, evenness is
additive (`IsEven (Q ⊕ Q') ↔ IsEven Q ∧ IsEven Q'`), and congruence is a congruence for `⊕`.
**Test**: Build `IntersectionForm.directSum` via `Matrix.fromBlocks`, prove the
`value (Sum.elim v w) = Q.value v + Q'.value w` decomposition, then derive the represented-value
and evenness statements. Falsifiable: cross terms in `value` could obstruct additivity if
the block structure is set up wrong.
**Why now**: `value_smul` and the `value`/`Represents` API show how to manipulate the
quadratic value abstractly; direct sums are the next algebraic operation and unlock `E8 ⊕ E8`,
`E8 ⊕ ⟨1⟩`, and the hyperbolic plane `H`. The key insight is that the represented-value set
is a sub-semigroup under `⊕`, turning lattice surgery into addition of represented values.
**If true**: Enables formalizing `2·E8 ⊕ 3·H` (the `K3` intersection form) and statements
about which even forms are smoothly realizable.
**If false**: Would reveal that the naive Gram-block model loses the bilinear pairing's
interaction terms, demanding a coordinate-free bilinear-form definition.

### Direction 4: A positive-definiteness predicate and the rank-8 minimality of `E8`
**Hypothesis**: With `PosDef Q := ∀ v ≠ 0, 0 < Q.value v`, the `E8` form is positive
definite, and every positive-definite even unimodular form has rank divisible by 8.
**Test**: Formalize `PosDef E8form` (e.g. via an explicit sum-of-squares / Cholesky-type
witness over `ℚ`, since `E8`'s Gram is the Cartan matrix). The "rank divisible by 8" claim is
a deep theorem (signature ≡ 0 mod 8 for even unimodular forms) — state it as a `conjecture`
with `sorry` and attack the `PosDef E8form` part first.
**Why now**: `congruent_E8_not_stdDiagonalizable` makes `E8` the central object, but the
file currently treats it only combinatorially (even, symmetric). Definiteness is the missing
hypothesis that connects to Donaldson's *positive-definite* theorem. The key insight is that
positive-definiteness is itself a congruence invariant (it is a property of the represented
value set on nonzero vectors), so it slots directly into the invariance framework already built.
**If true**: Brings the formalization to the exact hypotheses of Donaldson's theorem and
opens the door to the `8 | signature` van der Blij / Milnor result.
**If false**: A computational error in the `E8` Cartan matrix would surface immediately,
which is itself a valuable correctness check on the catalog's `E8mat`.

### Direction 5: Topological realizability vs. smooth obstruction (Freedman side)
**Hypothesis**: There is a predicate `TopRealizable Q` (every unimodular symmetric integral
form is the intersection form of *some* closed simply-connected topological 4-manifold,
Freedman) such that `TopRealizable E8form ∧ ¬ ∃ smooth M, formOf M = E8form`. Formalize the
*statement* of this gap as a structure, even if the manifold-theoretic content stays axiom-free
and abstract.
**Test**: Introduce an abstract `class SmoothlyRealizable` and `class TopologicallyRealizable`
on `IntersectionForm` as Prop-valued predicates (no manifolds yet), assert Donaldson
(`SmoothlyRealizable Q → Q.PosDef → Q.StdDiagonalizable`) and Freedman
(`Q.Unimodular → TopologicallyRealizable Q`) as *hypotheses to a theorem*, and **derive**
`TopologicallyRealizable E8form ∧ ¬ SmoothlyRealizable E8form` from them plus
`congruent_E8_not_stdDiagonalizable`. This is falsifiable as a logical-entailment check: if the
implications do not compose, the abstraction is wrong.
**Why now**: This cycle made the obstruction a property of the congruence class, exactly the
granularity at which Donaldson and Freedman are stated. The key insight is that the entire
smooth/topological gap can be expressed as a clean entailment between two predicates plus the
purely algebraic `StdDiagonalizable` invariant we already proved — no analysis required to
state it rigorously.
**If true**: Produces the first fully-formal, axiom-clean statement of the smooth/topological
gap in dimension 4 as a Lean theorem schema, ready to be discharged once gauge theory enters
Mathlib.
**If false**: Tells us which interface predicates are too weak, guiding what gauge-theoretic
infrastructure must be formalized first.
