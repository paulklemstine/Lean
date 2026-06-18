# Future Directions — The Equivalence Calculus, II: Reification, 2-out-of-6, and Contractibility as a Universal Property

## Synthesis

This cycle closed the conceptual loop opened by the fibrewise characterisation of
equivalences. Last cycle established the dictionary

> a map is a bijection ⇔ all of its homotopy fibres are contractible
> (`HoTT.bijective_iff_contr_fibers`, `HoTT.isEquiv_iff_bijective`)

and built the 2-out-of-3 calculus on top of the predicate
`HoTT.IsEquiv f := ∀ b, IsContr (HFiber f b)`. The new module
`Speculative.AutoResearch.EquivalenceCalculusUniversal` pushes that representation
program along two complementary axes.

**Axis 1 — Reification.** The synthetic, homotopy-spectral datum "every fibre is
contractible" is *reified* into an honest packaged inverse `HoTT.IsEquiv.toEquiv :
A ≃ B`. Once an inverse is in hand, the calculus is closed under inversion
(`isEquiv_symm`) and — crucially — satisfies the strong **2-out-of-6 property**
(`isEquiv_two_out_of_six`): if the two long composites `g∘f` and `h∘g` of a chain
`A →f B →g C →h D` are equivalences, then *all four* of `f, g, h, h∘g∘f` are. This
is strictly sharper than 2-out-of-3 and is exactly the axiom that pins down a class
of weak equivalences in the Dwyer–Kan / homotopical-algebra sense.

**Axis 2 — Universality.** Contractibility is shown to be *representable*: `A` is
contractible iff *every* mapping type `X → A` is contractible
(`isContr_iff_forall_isContr_fun`). This is the precise sense in which a contractible
type is a *terminal object of the homotopy category* — it is detected by a single
universal test against all mapping types, with no reference to a chosen centre. The
two axes meet in `isEquiv_of_isContr` (every map between contractible types is an
equivalence) and `isContr_of_isEquiv` (h-levels transport along reified
equivalences).

## Results Summary

All theorems below are proved with `sorry = 0` and depend only on the standard
axioms `propext`, `Classical.choice`, `Quot.sound`.

* `HoTT.IsEquiv.toEquiv` / `HoTT.IsEquiv.toEquiv_apply` — reify a fibrewise
  equivalence as a Mathlib `Equiv`, computing as the original map.
* `HoTT.isEquiv_symm` — equivalences are closed under inverse.
* `HoTT.isContr_of_isEquiv` — contractibility transports along `IsEquiv`.
* `HoTT.isEquiv_of_isContr` — every map between contractible types is an
  equivalence.
* `HoTT.isEquiv_two_out_of_six` — the **2-out-of-6 property** of equivalences.
* `HoTT.isContr_iff_forall_isContr_fun` — **contractibility as a universal
  property**, `IsContr A ↔ ∀ X, IsContr (X → A)`.

(Build hygiene: this cycle also repaired the package layout — `srcDir = "Catalog"`
in `lakefile.toml` — and removed a dangling `import Shared.CarmichaelHelper` from
`Catalog/Shared/CarmichaelProof.lean` that pointed at a non-existent file, so the
`Shared` and `Speculative` libraries now elaborate.)

## Research Directions

### 1. The saturated class of weak equivalences

Having `isEquiv_two_out_of_six` and the closure laws (`isEquiv_id`, `isEquiv_comp`,
`isEquiv_symm`, homotopy-stability), the natural next claim is that `HoTT.IsEquiv`
is a *saturated* class: it equals the class of maps inverted by the localisation at
itself, and it is closed under retracts in the arrow category. A falsifiable form:
*every map `f` that becomes invertible after composing on both sides with members of
`IsEquiv` is itself in `IsEquiv`.* The key insight is that 2-out-of-6 already forces
saturation for set-level types, because in `Type` the predicate collapses to
`Function.Bijective`, and bijections are closed under arrow-retracts — so the
abstract homotopical axioms can be discharged by finite bijection bookkeeping. Why
now? The 2-out-of-6 theorem proved this cycle is the only nontrivial axiom of a
saturated class; the remaining closure properties are corollaries of the dictionary
we already own, so the full characterisation is within one decomposition step.

### 2. Univalence-lite for whole algebraic structures, not just laws

The catalog currently transports *individual laws* (commutativity, associativity)
across equivalences (`magma_comm_transport_equiv`, `magma_assoc_transport_equiv`).
The next step is to transport an *entire bundled structure*: given `IsEquiv f` and a
`Monoid`/`Group`/`CommRing` instance on the source carrier, produce the transported
instance on the target and prove it agrees with `Equiv.transfer`-style transport.
The falsifiable conjecture: *for every algebraic theory `T` presented by operations
and equational axioms, `IsEquiv f` induces an isomorphism of `T`-models, and the
induced map on the type of `T`-structures is itself an equivalence.* The key insight
is that `IsEquiv.toEquiv` reduces structure transport to Mathlib's existing
`Equiv.*` transfer machinery, so each operation transports by conjugation and each
axiom transports by the law-level lemmas already in hand. Why now? Reification
(`toEquiv`) is the missing bridge: before this cycle there was no `A ≃ B` to feed
Mathlib's transfer lemmas; now there is.

### 3. Higher h-levels and a truncated equivalence calculus

The development stops at h-levels `(-2)` (`IsContr`) and `(-1)` (`IsMereProp`)
because Lean's proof-irrelevant `Prop` trivialises `IsHSet`. Re-running the program
in a *type-valued* identity setting (e.g. via `Quiver`/`CategoryTheory` path
groupoids, or an explicit `Path` type) would expose genuine `n`-truncation. The
falsifiable conjecture: *`IsEquiv` restricted to `n`-truncated types satisfies the
same 2-out-of-6 calculus, and the universal property `IsContr A ↔ ∀ X, IsContr(X→A)`
generalises to `IsTrunc n A ↔ ∀ X, IsTrunc n (X → A)`.* The key insight is that the
universal-property proof we gave uses only `isContr_fun` and a `PUnit`-evaluation
retraction, both of which have evident `n`-truncated analogues via Π-closure of
truncation. Why now? `isContr_iff_forall_isContr_fun` gives the `n = -2` base case
in closed form, making the induction on `n` the only remaining content.

### 4. Closing the Carmichael primitive-divisor infinite tail

`Catalog/Shared/CarmichaelProof.lean` proves Carmichael's primitive prime divisor
theorem for composite `13 ≤ n ≤ 10000` by a verified `native_decide` GCD sieve, but
leaves the infinite tail `n > 10000` as a `sorry`. The falsifiable conjecture that
closes it: *the Fibonacci primitive part `Φ_n = ∏_{d∣n} F(d)^{μ(n/d)}` satisfies
`Φ_n > n` for all `n > 12`, and every non-primitive prime factor of `Φ_n` divides
`n` to the first power only* — whence `Φ_n` must carry a primitive prime. The key
insight is that the entry-point machinery already formalised here
(`bridge_lemma`, `primPart`, `Nat.fib_gcd`) reduces the tail to exactly two
analytic facts: a Fibonacci Lifting-the-Exponent identity
`v_p(F(mk)) = v_p(F(m)) + v_p(k)` and the growth bound `F(n) ≥ φ^{n-2}`. Why now?
The sieve side is complete and the entry-point reduction is in place, so the only
missing pieces are these two self-contained number-theoretic lemmas — each a
realistic target for a dedicated cycle rather than the whole theorem at once.

### 5. The homotopy-category fragment of the calculus

`PathSpaceHLevels` already realises contractibility classically
(`map_to_contractible_nullhomotopic`, `maps_to_contractible_homotopic`). Combining
this with the universal property suggests: *the assignment `X ↦ (X → A)` for
contractible `A` is naturally equivalent to the constant functor at a point, and
this is detected fibrewise by `IsEquiv` of the unique map `A → PUnit`.* The
falsifiable conjecture: *`IsContr A ↔ IsEquiv (fun _ : A => PUnit.unit)`* and its
topological shadow *`ContractibleSpace Y ↔` the evaluation `C(X,Y) → Y` is a
homotopy equivalence for all `X`.* The key insight is that both sides are now
expressible in the catalog's own vocabulary — `IsEquiv`, `IsContr`,
`ContinuousMap.Homotopic` — so the bridge is a matter of assembling existing lemmas
rather than importing new theory. Why now? The reification `toEquiv` plus the
universal property give both the synthetic and the classical halves a common
`Equiv`-level interface for the first time.
