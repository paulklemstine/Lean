# Future Directions — Homotopy Type Theory Flavoured Foundations

The Lean module `Logic/HomotopyTypeFoundations.lean` carves out the *constructive,
axiom-free* core that Lean's intensional type theory shares with Homotopy Type
Theory (HoTT): the Eckmann–Hilton collapse, the bottom of the h-level hierarchy
(contractibility, based-path-space contractibility, products), transport of
algebraic structure along type equivalences, and the 2-out-of-3 property of
equivalences. It also pins down the precise *boundary* — `lean_validates_uip` —
where Lean parts ways with univalence by validating Uniqueness of Identity
Proofs. The conjectures below are concrete, falsifiable next steps, each phrased
so that a single failing `example` or a complete proof settles it.

## 1. Eckmann–Hilton produces a genuine `CommMonoid` instance

The four lemmas `units_eq`, `mul_eq_add`, `mul_comm`, `mul_assoc` together say a
`DoubleUnital X` is, up to definitional unfolding, a commutative monoid on its
`mul`. The conjecture is that this can be packaged as a Lean `instance`
`DoubleUnital.toCommMonoid : CommMonoid X` whose `mul = D.mul` and `one = D.one`
*definitionally*, so that `ring`/`abel` become available on any `DoubleUnital`.
**The key insight is** that Eckmann–Hilton does not merely prove scattered
equations — it certifies that the *whole* `CommMonoid` interface is derivable
from interchange + bi-unitality, so the structure transfer is total rather than
piecemeal. **Why now?** All four obligations of the `CommMonoid` bundle are
already proven in the module; the only remaining work is the bundling, which is
exactly the kind of mechanical-but-load-bearing step that validates whether our
axiomatisation is the "right" minimal one. A falsifier would be a definitional
mismatch forcing a non-`rfl` coercion.

## 2. Eckmann–Hilton degenerates without an honest second unit

`units_eq` shows the two units collapse. The conjecture is a sharp *necessity*
result: drop bi-unitality of the *second* operation (keep only that `add` has a
left unit, say) and the conclusion `one = zero` becomes false, witnessed by an
explicit two-element counterexample structure. **The key insight is** that the
interchange law alone is too weak — Eckmann–Hilton genuinely consumes *both*
units, and the collapse is not a formal accident but a tight hypothesis-by-
hypothesis equivalence. **Why now?** Our `DoubleUnital` carries exactly four unit
axioms; testing minimality by deleting one and exhibiting a finite counter-model
(checkable by `decide`) is the cheapest possible way to prove the formalisation
is not over-specified, and it directly stress-tests the "Ω² explanation" of why
`π_n` is abelian only for `n ≥ 2`.

## 3. The h-level hierarchy is closed under dependent products (Π-types)

We proved contractibility is closed under binary products. The conjecture
extends this to *dependent* products: if `B : X → Type` is a family with every
`B x` contractible, then `∀ x, B x` is contractible (centre = pointwise centre,
using `funext`). More ambitiously, the same closure holds one level up for
`IsProp` (define `IsProp X := ∀ a b : X, a = b`) and `IsSet`. **The key insight
is** that the n-type hierarchy's stability under Π is what makes h-levels a
*modality-like* closed class, and `funext` is precisely the constructive
ingredient HoTT and Lean agree on. **Why now?** `funext` is available and the
binary case is already in the module as a template; pushing to Π-types and to the
`IsProp`/`IsSet` levels turns three isolated lemmas into a genuine *theory of
truncation levels* with one more proof step each.

## 4. Transport along an equivalence is functorial and preserves commutativity

`transportMul_assoc` and `transportMul_hom` show one equivalence transports
associativity and is a homomorphism. The conjecture is the *functoriality*
package: `transportMul (Equiv.refl α) m = m`, `transportMul (e.trans e') m =
transportMul e' (transportMul e m)`, and transport additionally preserves
commutativity and units. **The key insight is** that "univalence in action" is
not a single transport but a *functor* from the groupoid of equivalences to the
poset of algebraic theories satisfied — and Lean can witness every law univalence
would give us for free, by hand, with no new axiom. **Why now?** The two seed
lemmas already isolate the unfold-cancel-`congrArg` proof pattern; the refl/trans
laws follow the identical pattern and would demonstrate that the *entire*
content of univalence-for-this-structure is constructively available, sharpening
the contrast with `lean_validates_uip`.

## 5. UIP is exactly the obstruction: a univalence-incompatibility certificate

`lean_validates_uip` proves Lean satisfies UIP. The conjecture makes the
incompatibility quantitative: formalise a *toy univalence statement* `UA₂ : ∀
(A B : Type), (A ≃ B) → A = B` restricted to two-element types, and prove that
`UA₂` together with `lean_validates_uip` forces `(Equiv.refl Bool) = (notEquiv)`
as *equalities of equivalences*, collapsing the two automorphisms of `Bool` — a
provably false consequence. **The key insight is** that UIP and univalence are
not merely "different flavours" but *actively contradictory* once a type has two
distinct self-equivalences, and `Bool` is the smallest arena where this can be
exhibited mechanically. **Why now?** `lean_validates_uip` is the boundary lemma
already in hand, and `Bool`'s equivalence group is finite and `decide`-able; a
short derivation of `False` from `UA₂ + UIP` would convert an informal slogan
("Lean is set-level, so univalence is inconsistent here") into a checked theorem.
