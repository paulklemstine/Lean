# Future Directions — Identity Systems II: After the Converse, Eliminator, and Mathlib Bridge

## Synthesis of this cycle

The previous cycle proved the **Fundamental Theorem of Identity Systems**
(`fundamentalIdentitySystem` in `Catalog/Logic/HoTT/IdentitySystems.lean`): an
`IdentitySystem A a₀ R` yields a fibrewise equivalence `(a₀ = a) ≃' R a`. It left
open five concrete research directions. This cycle
(`Catalog/Logic/HoTT/IdentitySystemsConverse.lean`) closes four of them, all
`sorry`-free and depending only on `propext`.

The unifying discovery is that **contractibility transport across an `Equiv'`**
(`HoTTFound.Equiv'.contractible`, added last cycle) is the single reusable engine
for the entire identity-system calculus. Once the right `Σ'`-equivalence is named,
the converse, the closure properties, and the eliminator all become one-line
assemblies:

- `Equiv'.psigmaCongr` assembles fibrewise equivalences into one equivalence of
  total spaces;
- `idSys_of_fiber_equiv` (**Direction 1, the converse**) transports
  contractibility of the based path total space across it, so a family fibrewise
  equivalent to `a₀ = ·` *is* an identity system — giving, with the previous
  cycle, the full characterisation;
- `idSysElim` + `idSysElim_beta` (**Direction 4**) is the induced path-induction
  eliminator with its computation rule, free on `rfl` because every base-loop
  transport in a `Prop`-valued `Eq` is the identity (`mpr_congr_loop`);
- `Equiv'.toEquiv` + `fundamentalIdentitySystemEquiv` (**Direction 5**) exports
  the fundamental equivalence to Mathlib's `Equiv`;
- `Contractible.prod`, `Equiv'.sigmaProd`, `idSys_prod` (**Direction 3**) give
  closure under products.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `Equiv'.psigmaCongr` | `(∀ a, P a ≃' Q a) → (Σ' a, P a) ≃' (Σ' a, Q a)` | ✅ proved |
| `idSys_of_fiber_equiv` | `(∀ a, (a₀ = a) ≃' R a) → IdentitySystem A a₀ R` | ✅ proved |
| `mpr_congr_loop` | transport along a loop is the identity | ✅ proved |
| `idSysElim` | dependent eliminator induced by an identity system | ✅ proved |
| `idSysElim_beta` | `idSysElim S D d a₀ S.rflR = d` (computation rule) | ✅ proved |
| `Equiv'.toEquiv` | `α ≃' β → α ≃ β` (Mathlib bridge) | ✅ proved |
| `fundamentalIdentitySystemEquiv` | `IdentitySystem A a₀ R → (a₀ = a) ≃ R a` | ✅ proved |
| `Contractible.prod` | product of contractibles is contractible | ✅ proved |
| `Equiv'.sigmaProd` | `Σ'`-distribution over a product base | ✅ proved |
| `idSys_prod` | product of identity systems is an identity system | ✅ proved |

All results depend only on `propext` (and `idSysElim_beta` on no axioms at all).

## Research directions

### 1. The structure identity principle for `HProp'` (the last untouched direction)

The one remaining open direction from the previous cycle is a **structure identity
principle** for the catalog's `HProp'` universe. Conjecture (two halves): (a)
*unconditionally*, `HPropEquiv P Q` upgrades to an `Equiv' P.carrier Q.carrier`,
because `HProp'` is subsingleton-valued so a logical equivalence is already a type
equivalence; (b) *given a propositional-univalence hypothesis supplied as an
explicit parameter* `(univ : ∀ P Q, (P.carrier ↔ Q.carrier) → P = Q)`, that
equivalence becomes an honest `Eq`. *The key insight is* that the data-free
half needs no univalence — `Equiv'.toEquiv` and `Equiv'.contractible` already turn
"logically equivalent subsingletons" into "equivalent as types"; univalence is
only the final repackaging into `Eq`, and must be threaded as a hypothesis rather
than an axiom. **Why now?** With `Equiv'.toEquiv` in place the unconditional half
is immediate, isolating exactly where (and whether) univalence is genuinely
needed.

### 2. Package the characterisation as a single `Equiv'`-valued biconditional

We have both implications — `fundamentalIdentitySystem` (forward) and
`idSys_of_fiber_equiv` (converse) — but never assembled them into one statement.
Conjecture: there is a *coherent* round trip, `idSys_of_fiber_equiv` applied to
the family `fun a => fundamentalIdentitySystem S a` reproduces `S` up to a
canonical `IdentitySystem`-isomorphism, and conversely the encode map of
`idSys_of_fiber_equiv e` agrees fibrewise with `e`. *The key insight is* that both
directions factor through the same contractible total space `Σ' a, R a`, so the
round trip is governed by `Subsingleton`-ness of maps out of a contractible type,
not by new homotopy. **Why now?** `idSysElim`/`idSysElim_beta` give exactly the
uniqueness principle ("a map out of `R` is determined by its value on `rflR`")
needed to prove the two families of maps agree without path induction by hand.

### 3. Dependent-sum and pullback closure (finishing Direction 3)

Products are done; the dependent-sum and pullback cases remain. Conjecture: if `R`
is an identity system on `A` at `a₀` and, for each `a`, `Rᵃ` is an identity system
on `B a` at `b₀ a`, then the total family is an identity system on `Σ' a, B a` at
`⟨a₀, b₀ a₀⟩`; and identity systems pull back along any `f : C → A` whenever `f`
reflects the relevant paths. *The key insight is* that the contractibility of an
iterated `Σ'` total space again reduces, via `Equiv'.contractible` and a
`Σ'`-reassociation equivalence (the dependent analogue of `Equiv'.sigmaProd`), to
contractibility of the pieces. **Why now?** `Equiv'.psigmaCongr` plus
`Equiv'.sigmaProd` are templates; the dependent reassociation `Equiv'` is the only
new gadget, and its roundtrips are again definitional `rfl`s.

### 4. η / uniqueness for the induced eliminator

`idSysElim_beta` gives the β-rule; the dual is an **η/uniqueness rule**: any
section `g : ∀ a r, D a r` equals `idSysElim S D (g a₀ S.rflR)`. Conjecture: this
holds for every identity system, making `idSysElim` the *unique* dependent
eliminator and certifying `IdentitySystem` as a genuine higher-inductive-style
recursor. *The key insight is* that two sections agreeing on `rflR` agree
everywhere, because they agree on the centre of the contractible total space and
sections out of a contractible type are determined by their value at the centre.
**Why now?** The machinery is already present: `idSysElim` is transport from the
centre, and `mpr_congr_loop` shows that transport degenerates on loops, so the
uniqueness proof is the same `proof_irrel`-driven argument applied one level up.

### 5. Transport the Mathlib bridge: subsingleton/`Prop` consequences for free

`fundamentalIdentitySystemEquiv` lands the fundamental theorem in Mathlib's
`Equiv` API. Conjecture: this immediately yields, for any identity system, that
`R a` inherits every `Equiv`-stable property of the path space `a₀ = a` — e.g.
`Subsingleton (R a)` when `A` has decidable/`Prop`-level equality, and a
`DecidableEq`-style transport. *The key insight is* that `Equiv.subsingleton`,
`Equiv.decidableEq`, and friends are stated for Mathlib's `Equiv`, so the bridge
turns purely synthetic identity-system data into mainstream instances with no
extra proof. **Why now?** With the bridge proven to use only `propext`, exporting
these consequences is zero marginal cost and demonstrates the cross-domain payoff
(topology, category theory, decidability) promised by Direction 5.
