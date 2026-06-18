# Future Directions: Measurable Cardinals and the Large-Cardinal Hierarchy

The new file `Catalog/Shared/MeasurableCardinal.lean` formalizes measurable cardinals via
`κ`-complete nonprincipal ultrafilters and proves, with **zero `sorry`**, that a measurable
cardinal is regular (`isRegular_of_measurable`), a strong limit
(`isStrongLimit_of_measurable`), and therefore inaccessible (`measurable_isInaccessible`).
The engine of all three results is one combinatorial lemma — `small_notMem`, "small sets are
null" — together with its dual `iUnion_notMem_of_cardComplete`. These give a clean,
reusable interface to the `κ`-complete ideal that the following directions build on. Each
direction below is testable and falsifiable: it is a concrete Lean statement that either
compiles to a proof or is refuted by a counterexample.

## 1. The induced normal measure and Fodor's theorem on the ultrafilter

The `κ`-complete ultrafilter `U` makes the dual ideal `{s | s ∉ U}` a `κ`-complete ideal
extending the bounded ideal (this is exactly the content of `small_notMem`). The conjecture is
that *every* regressive function `f : α → α` (i.e. `f x` lies below `x` in a fixed well order)
is constant on a set in `U` — the ultrafilter form of Fodor's pressing-down lemma. Formally:
`∀ f, (∀ x, r (f x) x ∨ f x = x) → ∃ c, {x | f x = c} ∈ U`.

The key insight is that `small_notMem` already shows fibers below a fixed point are null, so a
regressive `f` partitions `α` into `≤ κ` pieces of which exactly one must be in `U` by
`κ`-completeness applied to the *complement* family — the same complement-duality trick used in
`iUnion_notMem_of_cardComplete`, now indexed by the range rather than by singletons.

Why now? The dual-ideal infrastructure (`iUnion_notMem_of_cardComplete`, `compl_small_mem`) is
in place and is precisely the closure property Fodor's argument consumes; no new cardinal
arithmetic is needed, only a careful "exactly one block is large" case split over `≤ κ` blocks.

## 2. Measurable implies Mahlo (the next consistency link)

We proved measurable ⟹ inaccessible. The natural strengthening is measurable ⟹ Mahlo: the set
of inaccessible (indeed regular) cardinals below `κ` is *stationary*, and in fact belongs to
`U`. The falsifiable statement: `{μ | μ < κ ∧ (μ).IsInaccessible}` (transported to `α` via the
canonical well order) is a member of the ultrafilter, hence meets every club.

The key insight is that membership in `U` is strictly stronger than stationarity, and it is
obtained by showing the complementary set of *singular* `μ < κ` is null — an Ulam-matrix /
reflection argument that decomposes the singulars by their cofinality, each layer being null by
`small_notMem`.

Why now? `measurable_isRegular` gives the reflection target (regularity of `κ` itself), and the
`κ`-complete ideal lets us add up `< κ` null layers; the only missing combinatorial piece is the
Ulam matrix, which has a finite, formalization-friendly recursion.

## 3. Indescribability: `κ` reflects second-order statements

A measurable cardinal is `Π¹₁`-indescribable. A first concrete, testable instance: for every
family `(A_i)_{i<κ}` of subsets of `α`, any sentence about `(α, ∈, (A_i))` that holds is
witnessed by some initial segment below `κ`. Formally, reflection of a single closed-under-`<κ`
property `P` from `α` to a club of `μ < κ`.

The key insight is that the ultrafilter `U` is an *elementary-embedding seed*: the ultrapower
`Ult(V, U)` has critical point `κ`, and elementarity pushes any true statement below the
critical point. Even without building the full ultrapower, the `< κ`-closure proved here
(`hc : IsCardComplete`) is exactly the Łoś-theorem hypothesis for `κ`-complete ultrapowers.

Why now? `IsCardComplete` is the literal hypothesis of Łoś's theorem for `κ`-complete
ultrafilters; formalizing the ultrapower as a quotient of `Λ → α` modulo `U`-a.e.-equality
reuses the membership API (`Ultrafilter.compl_mem_iff_notMem`, `mem_or_compl_mem`) already
exercised in `isStrongLimit_of_measurable`.

## 4. Necessity of uncountability: a sharp boundary theorem

Our definition demands `ℵ₀ < #α`. The boundary conjecture makes this sharp: *there is a
nonprincipal ultrafilter on `ℕ` that is `#ℕ`-complete* (vacuously, since `#ℕ`-completeness only
constrains `< ℵ₀`-indexed, i.e. finite, intersections — automatic for any filter). Hence
`small_notMem` fails for `α = ℕ`: a cofinite set is co-finite yet every finite set is null, but
`ℕ` itself decomposes into countably many null singletons, so completeness at the *index size
`ℵ₀`* is exactly what is missing.

The key insight is that the whole theory hinges on the strict inequality `#ι < #α` controlling
the index, and at `α = ℕ` the critical index size `ℵ₀` equals `#α`, so the covering-by-singletons
argument of `small_notMem` is unavailable — pinpointing uncountability as the unique load-bearing
hypothesis.

Why now? The principal-ultrafilter boundary example `pure_isCardComplete` is already in the file;
its nonprincipal counterpart on `ℕ` (via `Ultrafilter.hyperfilter`, already in Mathlib) closes
the boundary analysis with no new infrastructure.

## 5. From single ultrafilters to the Mitchell order

Once measurability is formalized, the next structural object is the *Mitchell order* on
`κ`-complete normal measures: `U ◁ W` iff `U` belongs to the ultrapower by `W`. A first testable
fragment: the relation `◁` is well-founded on the set of `κ`-complete nonprincipal ultrafilters
on `α`, giving each such ultrafilter an ordinal rank `o(U)`.

The key insight is that the dual-ideal closure (`iUnion_notMem_of_cardComplete`) makes the set of
`U`-measure-one sets a `κ`-complete filter, and well-foundedness of `◁` is a descending-chain
condition that reduces, via Łoś, to well-foundedness of the membership relation on ultrapowers —
ultimately the well-foundedness of `∈` already available through Mathlib's ordinals.

Why now? Direction 3 supplies the ultrapower, and Mathlib's `WellFoundedLT`/ordinal-rank API
turns the descending-chain condition into a definable rank function with essentially no new
mathematics — only bookkeeping over the ultrafilter API established here.
