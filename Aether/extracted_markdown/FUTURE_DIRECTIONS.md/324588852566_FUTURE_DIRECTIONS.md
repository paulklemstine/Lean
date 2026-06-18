# Future Directions: Measurable Cardinals and the Large-Cardinal Hierarchy

The file `Catalog/Shared/MeasurableCardinal.lean` formalizes **measurable cardinals**
through `κ`-complete nonprincipal ultrafilters and proves, with **zero `sorry`** on the
main results, that a measurable cardinal is regular (`Cardinal.IsMeasurable.isRegular`),
a strong limit (`Cardinal.IsMeasurable.isStrongLimit`), and therefore inaccessible
(`Cardinal.IsMeasurable.isInaccessible`). The engine of all three results is the
combinatorial lemma `MeasurableCardinal.small_notMem` ("small sets are null"), together
with its dual `IsCardComplete.iUnion_notMem_of_cardComplete` and the pure set-theoretic
covering lemma `exists_small_cover_of_cof_lt`. These give a clean, reusable interface to
the `κ`-complete dual ideal that the directions below build on. Each direction is a
concrete Lean statement that either compiles to a proof or is refuted by a
counterexample.

## 1. Fodor's pressing-down lemma on the ultrafilter

The `κ`-complete ultrafilter `U` makes the dual ideal `{s | s ∉ U}` a `κ`-complete ideal
extending the bounded ideal — this is the content of `small_notMem`. The conjecture is
that *every* regressive function `f : α → α` (where `f x` lies strictly below `x` in a
fixed well order) is constant on a set in `U`, the ultrafilter form of Fodor's lemma:
`∀ f, (∀ x, r (f x) x ∨ f x = x) → ∃ c, {x | f x = c} ∈ U`.

The key insight is that `small_notMem` already shows that the fibers below a fixed point
are null, so a regressive `f` partitions `α` into `≤ κ` pieces of which exactly one must
lie in `U` by `κ`-completeness applied to the complement family — the same
complement-duality trick used in `iUnion_notMem_of_cardComplete`, now indexed by the
range rather than by singletons.

Why now? The dual-ideal infrastructure (`iUnion_notMem_of_cardComplete`,
`compl_small_mem`) is in place and is precisely the closure property Fodor's argument
consumes; no new cardinal arithmetic is required, only a careful "exactly one block is
large" case split over `≤ κ` blocks.

## 2. Measurable implies Mahlo

We proved measurable ⟹ inaccessible. The natural strengthening is measurable ⟹ Mahlo:
the set of regular (indeed inaccessible) cardinals below `κ` is stationary, and in fact
belongs to `U`. The falsifiable statement: the set `{μ | μ < κ ∧ μ.IsInaccessible}`,
transported to `α` via the canonical well order built in `exists_small_cover_of_cof_lt`,
is a member of the ultrafilter — hence meets every club.

The key insight is that membership in `U` is strictly stronger than stationarity, and it
is obtained by showing the complementary set of singular `μ < κ` is null: an Ulam-matrix
reflection argument that decomposes the singulars by cofinality, each layer being null by
`small_notMem`.

Why now? `isRegular` already gives the reflection target (regularity of `κ` itself), and
the `κ`-complete ideal lets us sum `< κ` null layers; the only missing combinatorial
piece is the Ulam matrix, which has a finite, formalization-friendly recursion.

## 3. The ultrapower and Łoś's theorem

A measurable cardinal is `Π¹₁`-indescribable, witnessed by the elementary embedding into
the ultrapower `Ult(V, U)` with critical point `κ`. A first concrete fragment: build the
ultrapower of `Λ → α` modulo `U`-a.e.-equality as a Lean quotient and prove Łoś's theorem
for atomic formulas, then derive that the diagonal embedding is elementary on bounded
quantifiers.

The key insight is that `IsCardComplete` is *literally* the hypothesis of Łoś's theorem
for `κ`-complete ultrapowers: `< κ`-closure of `U` is exactly what makes a.e.-quantifier
exchange valid. The quotient construction reuses the membership API
(`Ultrafilter.compl_mem_iff_notMem`, `Ultrafilter.mem_or_compl_mem`) already exercised in
`isStrongLimit`.

Why now? Every ingredient of the Łoś hypothesis is already a named lemma in the file;
formalizing the quotient and the atomic case is bookkeeping over the existing ultrafilter
interface, with no new set theory.

## 4. Sharpness of the uncountability hypothesis

Our development requires `ℵ₀ < #α`, and the covering lemma `exists_small_cover_of_cof_lt`
explicitly fails for finite `α` (e.g. `#α = 2`: cofinality `1 < 2`, yet two points cannot
be covered by one set of size `≤ 1`). The boundary conjecture pins this down: there is a
nonprincipal `#ℕ`-complete ultrafilter on `ℕ` (vacuously, since `#ℕ`-completeness only
constrains finite intersections), so `small_notMem` *fails* at `α = ℕ` — every singleton
is null, but `ℕ` is the union of countably many singletons.

The key insight is that the entire theory hinges on the strict inequality `#ι < #α`
controlling the index size, and at `α = ℕ` the critical index size `ℵ₀` equals `#α`, so
the covering-by-singletons step of `small_notMem` is unavailable — isolating
uncountability as the unique load-bearing hypothesis.

Why now? The boundary example via `Ultrafilter.hyperfilter` is already in Mathlib;
formalizing both the positive `#ℕ`-completeness statement and the failure of
`small_notMem` closes the boundary analysis with no new infrastructure.

## 5. From single ultrafilters to the Mitchell order

Once measurability is formalized, the next structural object is the Mitchell order on
`κ`-complete normal measures: `U ◁ W` iff `U` belongs to the ultrapower by `W`. A first
testable fragment: `◁` is well-founded on the set of `κ`-complete nonprincipal
ultrafilters on `α`, equipping each with an ordinal rank `o(U)`.

The key insight is that the dual-ideal closure (`iUnion_notMem_of_cardComplete`) makes the
collection of `U`-measure-one sets a `κ`-complete filter, and well-foundedness of `◁`
reduces, via Łoś (Direction 3), to well-foundedness of the membership relation on
ultrapowers — ultimately the well-foundedness of `∈` available through Mathlib's ordinals.

Why now? Direction 3 supplies the ultrapower and Mathlib's `WellFoundedLT` / ordinal-rank
API turns the descending-chain condition into a definable rank function with essentially
no new mathematics — only bookkeeping over the ultrafilter API established here.
