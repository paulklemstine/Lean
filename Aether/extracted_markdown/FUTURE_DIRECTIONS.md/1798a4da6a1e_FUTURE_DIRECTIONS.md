# Future Directions — Provability Logic, Fixed Points, and Category Theory

## Synthesis

This cycle built the missing *algebraic spine* of the catalog's provability-logic work.
The catalog already contained the Kripke semantics of GL (`Catalog/Logic/GLKripke.lean`)
and explicit computations in one concrete frame (`Catalog/Logic/LobNatModel.lean`), but
both quote a `GLOperator` / `ProvabilityLattice` typeclass whose defining modules are not
present in the repository, so the two files float free of any abstract foundation.

We replaced that gap with a single, self-contained, *more general* class — `GLAlgebra`
over an arbitrary `HeytingAlgebra` (the Magari / diagonalizable algebras) — and showed
that the entire first-order strength of Gödel–Löb logic is squeezed out of three
equations: `□⊤ = ⊤`, `□(a⊓b) = □a⊓□b`, and Löb's axiom `□(□a⇨a) ≤ □a`. From these we
derived axiom 4, Löb's rule, the uniqueness of the diagonal fixed point, and Gödel's
Second Incompleteness Theorem. We then bridged to category theory: the box operator is
an endofunctor on the order category, and Löb's theorem becomes the statement that this
endofunctor has a *unique* fixed object, the terminal `⊤`. Finally, the concrete
`(ℕ, >)` frame instantiates the class and recovers the LobNatModel rank spectrum.

## Results Summary

Files: `Catalog/Bridges/ProvabilityFixedPoint.lean`, `Catalog/Bridges/ProvabilityModel.lean`.

* `GLAlgebra` — Heyting algebra + normal box satisfying Löb's axiom.
* `GLAlgebra.box_mono` — monotonicity of `□`.
* `GLAlgebra.box_four` — **axiom 4 (`□a ≤ □□a`) is derivable from Löb alone**; transitivity
  of provability is not an extra assumption. (Auxiliary element `□a ⊓ a` + Heyting
  adjunction + Löb.)
* `GLAlgebra.loeb_rule` — **Löb's theorem as a fixed point**: `□a ≤ a ⇒ a = ⊤`.
* `GLAlgebra.box_unique_fixedPoint` — `⊤` is the unique fixed point of `□`.
* `GLAlgebra.godel_second` — Gödel II: consistency (`□⊥ ≠ ⊤`) implies `□(□⊥⇨⊥) ≠ ⊤`.
* `NatGL` / `natGL_consistent` — a concrete, consistent model on `Set ℕ` (the `(ℕ, >)`
  frame), so the axioms are non-vacuous and all abstract theorems transport.
* `natBox_iterate_eq_Iio`, `consistency_strength_strictMono` — `□^k⊥ = Iio k` and the
  strictly increasing consistency spectrum.
* `boxFunctor`, `boxFunctor_obj_top`, `loeb_iso_terminal` — the categorical reading:
  box is an endofunctor preserving the terminal object, and any object iso to its own box
  is terminal.

All main results compile with `sorry = 0` and depend only on standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. The de Jongh–Sambin explicit fixed-point theorem in `GLAlgebra`

We proved the *bare* operator `□` has the unique fixed point `⊤`. The full
de Jongh–Sambin theorem is far stronger: every formula `p(x)` in which `x` occurs only
under a `□` has, provably in GL, a *unique* fixed point `x ↔ p(x)`, and that fixed point
is explicitly definable without `x`. The conjecture: for every `GLAlgebra` `α` and every
`□`-guarded monotone `f : α → α` (i.e. `f` factors through `□`), there is a unique
`a` with `f a = a`, computable as `f` iterated on `⊤` (or `⊥`) finitely often. **The key
insight is** that `□`-guardedness turns `f` into a contraction with respect to the
well-founded "provability rank", so Banach-style uniqueness becomes well-founded
recursion rather than a metric argument. **Why now?** We already have `box_four` and the
rank computation `□^k⊥ = Iio k`; guardedness + rank is exactly the descent measure needed,
and the abstract `GLAlgebra` interface makes the statement model-independent. Falsifiable:
exhibit a `□`-guarded `f` on `Set ℕ` with two distinct fixed points, or with none.

### 2. Polymodal GLP and an ordinal-indexed consistency spectrum

`consistency_strength_strictMono` gives an `ℕ`-indexed chain `□^k⊥`. Japaridze's polymodal
logic GLP stacks countably many provability operators `[n]` of increasing strength and is
the engine behind Beklemishev's ordinal analysis of PA. Conjecture: a `PolyGLAlgebra`
(a family `box n` with `box (n+1) a ≤ box n a` and each `box n` a GL operator) admits, on
a transfinite carrier, a strictly increasing consistency spectrum indexed by `ε₀` rather
than `ℕ`, with `box_four` upgrading to monotonicity across the whole hierarchy. **The key
insight is** that the iterated-falsity computation `□^k⊥ = Iio k` is the `n = 0`, finite
slice of a transfinite "worm" ordering, and the catalog's `Catalog/Logic/PolymodalGL.lean`
and `StronglyCriticalOrdinals.lean` already supply the ordinal scaffolding to climb past
`ω`. **Why now?** The single-operator algebra and its rank spectrum are now formal; adding
a second operator that dominates the first is the minimal step that exposes the ordinal
structure, and the ordinal machinery is sitting unused in the `Logic/` catalog.

### 3. A genuine category of GL-algebras and a free–forgetful adjunction

We built the box *endofunctor* of one algebra. The next object is the *category* `GLAlg`
whose objects are GL-algebras and whose morphisms are box-preserving Heyting
homomorphisms. Conjecture: the forgetful functor `GLAlg ⥤ HeytAlg` has a left adjoint (the
free GL-algebra on a Heyting algebra, i.e. the Lindenbaum algebra of GL over a set of
atoms), and `NatGL` is *weakly terminal* among countable consistent objects. **The key
insight is** that Löb's axiom is an *equational* condition, so `GLAlg` is a variety and the
adjoint exists by general algebra — the content is identifying the free object with a
syntactic GL-derivability quotient. **Why now?** `loeb_iso_terminal` shows our objects
already carry the categorical structure Mathlib's `CategoryTheory` expects; promoting from
one object's endofunctor to a category of objects is the natural continuation and connects
the provability domain to the bundled-algebra category patterns used elsewhere in
`Bridges/`. Falsifiable: show the free GL-algebra on one generator is finite (it is not —
it should be infinite, mirroring the infinitely many non-equivalent modalities of GL).

### 4. Arithmetical completeness (a Solovay-style theorem) for the `(ℕ, >)` model

Solovay's theorem says GL is *exactly* the modal logic of PA-provability. Its non-collapse
half — distinct GL-principles are distinguished by some arithmetical interpretation — is
mirrored, in miniature, by `consistency_strength_strictMono`. Conjecture: for every modal
formula `A` *not* provable in GL there is a valuation `v : Var → Set ℕ` such that the
`natBox`-interpretation `⟦A⟧_v ≠ ⊤`; equivalently, `NatGL` (over all valuations) is a
*complete* algebra for GL. **The key insight is** that the finite Kripke frames validating
GL (catalog `GLKripke.lean`) all embed as `>`-initial segments into `(ℕ, >)`, so a single
countable model suffices for completeness — no need to range over all finite frames. **Why
now?** We have both the finite-frame soundness (`gl_frame_validates_loeb` in the catalog)
and the concrete `(ℕ, >)` algebra in one importable place; gluing finite frames into `ℕ`
is the missing lemma. Falsifiable: find a GL-unprovable `A` whose `natBox`-interpretation
is `⊤` under every valuation.

### 5. Quantitative Gödel II: a provability-rank lower bound on consistency proofs

`godel_second` is qualitative (`□(□⊥⇨⊥) ≠ ⊤`); `natBox_iterate_eq_Iio` is quantitative
(`□^k⊥ = Iio k`). Conjecture: in `NatGL` the *least* world that refutes the `k`-fold
consistency statement grows linearly, `min { n | n ∉ □(□^k⊥ ⇨ ⊥) } = k+1`, giving a sharp
"depth cost" of relative consistency; and abstractly, in any `GLAlgebra`, the
reflection-rank function `a ↦ rank(□a) − rank(a)` is exactly `1` on the consistency tower.
**The key insight is** that in the canonical model provability rank *is* the identity on
`ℕ`, so consistency strength is literally measured in frame depth, turning Gödel II into an
exact arithmetic identity rather than a non-equality. **Why now?** The rank computation is
already formal and the strict-monotonicity proof exposes exactly the `Iio`-gap that the
lower bound quantifies; this is the smallest quantitative refinement that the current
lemmas almost give for free. Falsifiable: compute a `k` where the refuting world is not
`k+1`.
