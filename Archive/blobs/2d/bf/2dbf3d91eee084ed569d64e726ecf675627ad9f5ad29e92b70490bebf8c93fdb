# Future Directions — Synthetic HoTT / Identity Systems

Research cycles completed so far in `Catalog/Logic/HoTT/`:

1. `Foundations.lean` — `Contractible`, `Equiv'`, `IdentitySystem`, the based path
   family as the canonical identity system.
2. `IdentitySystems.lean` — the **Fundamental Theorem of Identity Systems**
   (`fundamentalIdentitySystem`), encode/decode, base-fibre contractibility,
   uniqueness (`idSys_unique`).
3. `IdentitySystemsConverse.lean` — the converse (`idSys_of_fiber_equiv`), the
   induced eliminator + β-rule, product closure, the Mathlib `Equiv` bridge.
4. `FundamentalTheoremFiberEquiv.lean` (this cycle) — the fiber-equivalence form
   of the fundamental theorem: redundancy of `center_eq`
   (`idSys_of_contractible_total`), canonicity of the encode map
   (`pencodeEquiv_toFun`, `fibrewise_map_eq_pencode`), the master biconditional
   `fundamental_theorem_id`, and closure under fibrewise equivalence of families
   (`idSys_trans_fiberEquiv`).

The following conjectures are **bold but testable** targets for the next cycles.
Each is phrased so that it can be stated as a precise Lean theorem against the
existing API.

---

## Conjecture 1 — Dependent-sum (Σ) closure of identity systems

**Statement.** Let `S : IdentitySystem A a₀ R` and, for the *total* base, suppose
that for each `a : A` and `r : R a` we have `T : (a : A) → R a → Sort _` together
with `IdentitySystem (R a) (rflR-image) (T a)`-style data. Then the family
`fun (p : Σ' a, R a) => T p.1 p.2` is an identity system on `Σ' a, R a` based at
`⟨a₀, S.rflR⟩`.

**Why plausible.** `idSys_prod` already proves the *non-dependent* product case via
`Equiv'.sigmaProd`. The dependent generalisation should follow from a dependent
regrouping equivalence `(Σ' p : (Σ' a, R a), T p.1 p.2) ≃' (Σ' a, Σ' r : R a, T a r)`
pushed through `Equiv'.contractible`, exactly mirroring how `idSys_prod` reused
`Contractible.prod`. **Test:** build `Contractible.sigma` (contractibility of a
Σ over a contractible base with contractible fibres) and the dependent regrouping
`Equiv'.sigmaAssoc`, then assemble.

## Conjecture 2 — Identity systems are stable under base reindexing

**Statement.** Let `φ : B ≃' A` be an equivalence of base types and
`S : IdentitySystem A a₀ R`. Then `fun b => R (φ.toFun b)` is an identity system on
`B` based at `φ.invFun a₀` (after transporting along `φ.right_inv`).

**Why plausible.** Reindexing the total space `Σ' b, R (φ b)` along `φ` gives an
`Equiv'` to `Σ' a, R a`, whose contractibility transports back via
`Equiv'.contractible`. The subtlety is the base-point coherence
`center = ⟨φ.invFun a₀, …⟩`, which `idSys_of_contractible_total` (this cycle)
should make free. **Test:** prove `Equiv'.psigmaReindex (φ : B ≃' A) (R : A → _) :
(Σ' b, R (φ.toFun b)) ≃' (Σ' a, R a)` and feed it to `idSys_of_contractible_total`.

## Conjecture 3 — The space of identity systems based at `a₀` is contractible

**Statement.** Fix `A` and `a₀ : A`. Define a suitable type of "identity systems
based at `a₀`" up to fibrewise equivalence. Then this type is contractible: the
based path family `pathIdentitySystem a₀` is its centre.

**Why plausible.** `idSys_unique` already gives, for any two identity systems
`S, S'`, a fibrewise equivalence `R a ≃' R' a`. Upgrading "any two are equivalent"
to "the type of them is contractible" is the standard move from `isProp` to
`isContr` once a point is exhibited (here `pathIdentitySystem a₀`). This is the
precise sense in which *the based path family is the initial / universal identity
system*. **Test:** define `idSysFibEquiv S S' := ∀ a, R a ≃' R' a`, show it is an
equivalence relation (refl/symm/trans via `Equiv'`), and that every `S` relates to
`pathIdentitySystem a₀`.

## Conjecture 4 — Encode/decode is natural; identity systems form a category

**Statement.** The assignment `S ↦ (a ↦ fundamentalIdentitySystem S a)` is natural:
for a fibrewise map `g : ∀ a, R a → R' a` commuting with the reflexivity witnesses
(`g a₀ S.rflR = S'.rflR`), the square relating `idSysEncode S`, `idSysEncode S'`,
and `g` commutes. Hence pointed families with contractible total space and
reflexivity-preserving fibrewise maps form a category in which all morphisms are
isomorphisms (a groupoid), and `pathIdentitySystem a₀` is initial.

**Why plausible.** By `fibrewise_map_eq_pencode` (this cycle), `g ∘ idSysEncode S`
is a fibrewise map out of the path family, hence determined by its value at `rfl`,
which is `g a₀ S.rflR = S'.rflR`; that value also determines `idSysEncode S'`. So
the naturality square commutes *definitionally*. **Test:** state
`naturality_encode (g : ∀ a, R a → R' a) (hg : g a₀ S.rflR = S'.rflR) (a) (p) :
g a (idSysEncode S a p) = idSysEncode S' a p` and prove by `cases p`.

## Conjecture 5 — A `Sort`-valued "fundamental theorem" without proof irrelevance

**Statement.** Replicate `fundamental_theorem_id` for the genuinely homotopical
identity type `Path` of `Applications/HoTT/ConstructiveFoundations.lean` (valued in
`Type`, where UIP fails): a family `R : A → Type` is fibrewise `≃` to `Path a₀ ·`
iff `R a₀` is inhabited and `Σ a, R a` is contractible — *and* the two roundtrip
homotopies are themselves coherent (no collapse via `proof_irrel`).

**Why plausible / why hard.** The `Eq`-based proofs in the current cycle get one
triangle "for free" from `proof_irrel`; for `Path` that triangle becomes real
homotopical content requiring an explicit 2-path. This is the bridge between the
catalog's two HoTT developments (`Logic/HoTT/*` and
`Applications/HoTT/ConstructiveFoundations.lean`) and would unify them. **Test:**
port `pencode`, `fibrewise_map_eq_pencode` (via `Path.rec`), and
`contractible_of_fiberEquiv` (via a `Path`-valued `psigmaCongr`) into
`ConstructiveFoundations`'s setting, supplying the missing coherence 2-path.
