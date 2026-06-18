# Future Directions: Intersection Forms and the Smooth 4D Poincaré Frontier

The file `IntersectionForms.lean` formalizes the algebraic core of four-dimensional
gauge theory: symmetric integral intersection forms, their unimodularity (Poincaré
duality), evenness (spin), and standard diagonalizability (Donaldson's conclusion).
Its headline result, `even_not_stdDiagonalizable`, is the algebraic mechanism that
forbids even definite forms on smooth 4-manifolds, instantiated by the `E8` form
(`E8_not_stdDiagonalizable`). The following research directions extend this nucleus
toward a genuinely useful Lean theory of 4-manifold invariants. Each is concrete,
testable, and falsifiable: a precise Lean statement that either compiles or does not.

## 1. The 8-divisibility theorem for even unimodular definite forms

**Conjecture.** Every positive-definite *even* unimodular symmetric integral form has
rank divisible by `8`. In Lean: if `Q : IntersectionForm n` is `Unimodular`, `IsEven`,
and positive-definite (a `PosDef` predicate to be added: `∀ v ≠ 0, 0 < Q.value v`),
then `8 ∣ n`.

The key insight is that evenness plus unimodularity force the form, over `ℝ`, to embed
in the even unimodular lattice tower whose signature is constrained mod 8 by the
`E8`/Milnor classification; the rank `8` of our explicit `E8form` is the minimal
witness, so the obstruction `even_not_stdDiagonalizable` is really the `n < 8` shadow
of a `mod 8` law. Why now? We already have a fully verified even unimodular definite
form of rank `8` (`E8form`, `E8_even`, `E8_unimodular`), so the base case and the
sharpness example are in hand — only the modular bookkeeping remains, and Mathlib's
quadratic-form and lattice libraries have matured enough to host it.

## 2. A formal van der Blij / signature-mod-8 invariant

**Conjecture.** For any unimodular `Q : IntersectionForm n` there is an integer vector
`c` (a *characteristic element*, `Q.value v ≡ c ⬝ᵥ v (mod 2)` for all `v`) and the
quantity `Q.value c` is congruent to the signature of `Q` modulo `8`; for *even* forms
one may take `c = 0`, giving `signature ≡ 0 (mod 8)`.

The key insight is that the characteristic element packages the obstruction
`even_not_stdDiagonalizable` into a single `ℤ/8`-valued invariant: oddness of the
diagonal in the standard form is exactly the statement that `c ≠ 0`, and van der Blij's
lemma turns this parity datum into a signature congruence. Why now? Our `value` and
`IsEven` predicates already isolate the parity pairing `Q.value v mod 2`; defining a
`signature` for diagonalizable forms and proving the congruence on the diagonal case is
a self-contained next step that reuses `value_basisChange` verbatim.

## 3. Connected-sum additivity and a stable cancellation law

**Conjecture.** Define the block-diagonal direct sum `Q ⊕ R` of intersection forms
(modeling the connected sum `M # N`). Then `Unimodular` and `IsEven` are each closed
under `⊕`, signatures add, and a *stable* form of Donaldson holds: if `Q ⊕ ⟨1⟩^k` is
standard-diagonalizable for some `k`, then so is `Q` — i.e. adding `ℂP²` summands cannot
"smooth away" the `E8` obstruction.

The key insight is that the obstruction in `even_not_stdDiagonalizable` is detected by a
single odd diagonal value, which survives orthogonal summation; thus the smooth/topological
gap is *stable*, mirroring Wall's theorem that 4-manifolds become diffeomorphic after
connected-summing with enough copies of `S²×S²`. Why now? The structure `IntersectionForm`
is parametric in `n`, and Mathlib's `Matrix.fromBlocks`/`reindex` API makes the direct sum
definable today; additivity proofs are pure block-matrix algebra of the kind already
exercised in `value_basisChange`.

## 4. Rokhlin's theorem as a `ℤ/16` obstruction, abstractly

**Conjecture.** Introduce a `Smoothable` predicate on intersection forms abstracting the
Donaldson and Rokhlin inputs as hypotheses (not axioms): a `Smoothable` even form has
signature divisible by `16`. Conclude that `E8form ⊕ E8form` (signature `16`, even,
unimodular, rank `16`) is the *smallest* even unimodular form that clears the Rokhlin
hurdle yet still fails Donaldson — pinpointing exactly where the two obstructions diverge.

The key insight is that `E8` fails Donaldson (rank `8`, our `E8_not_stdDiagonalizable`)
while `E8 ⊕ E8` passes Rokhlin (signature `16`) but is realized smoothly only as the
indefinite `K3` form after sign change — so the two obstructions, one analytic and one
characteristic-class, are genuinely independent and must be tracked separately. Why now?
With `E8form` in hand, `E8form ⊕ E8form` is one direct sum away (Direction 3), and the
`Smoothable`-as-hypothesis pattern keeps everything axiom-free while still proving a
sharp comparison.

## 5. A homotopy-`S⁴` certificate: forms cannot detect exotic structure

**Conjecture.** Formalize a `HomotopySphere4` record carrying `b₂ = 0` (equivalently an
`IntersectionForm 0`) and prove that *every* such object has the trivial form
`sphereForm`, hence is indistinguishable from the standard `S⁴` by any intersection-form
invariant — a precise statement of *why* the smooth 4D Poincaré conjecture is invisible
to this entire toolkit.

The key insight is that `sphere_intersection_trivial` already shows the rank-`0` form is
unimodular, even, and standard, so the intersection form is a *complete invariant of the
empty kind*: it collapses all homotopy-`S⁴` candidates to one point, proving a sharp
*negative* metatheorem that the conjecture demands genuinely smooth (gauge-theoretic /
Seiberg–Witten) input beyond algebra. Why now? The rank-`0` boundary case is fully
proved, so the remaining work is purely definitional packaging plus a one-line transport,
making this the most immediately reachable — and conceptually clarifying — direction.
