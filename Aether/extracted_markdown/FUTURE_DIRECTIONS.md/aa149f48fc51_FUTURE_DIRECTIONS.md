# Future Directions — The Fundamental Theorem of Identity Systems and Homotopy-Initial Families

## Synthesis of this cycle

The catalog's synthetic-HoTT layer (`Catalog/Logic/HoTT/Foundations.lean`) *defined*
the structure `HoTTFound.IdentitySystem` — a based type family `R` over `a₀` carrying
a reflexivity witness `rflR : R a₀` together with a proof that the total space
`Σ a, R a` is contractible and centred at `⟨a₀, rflR⟩` — and its docstring promised
that "the fundamental theorem says this data yields an equivalence `(a₀ = a) ≃' R a`
for all `a`." That theorem was never stated, let alone proved. This cycle closes the
gap.

In `Catalog/Logic/HoTT/Fundamental.lean` we prove the **fundamental theorem of
identity types** (HoTT book §5.8 / Awodey–Gambino–Sojakova) as a genuine
biconditional, entirely `sorry`-free:

> A based family `R` over `a₀` with reflexivity witness `r₀ : R a₀` has contractible
> total space `Σ a, R a` **iff** the canonical transport map
> `idToR : (a₀ = a) → R a`, `p ↦ p ▸ r₀`, is an equivalence for every `a`.

Forward (`IdentitySystem.idToR_bijective`, packaged as the equivalence
`IdentitySystem.fundamentalEquiv : (a₀ = a) ≃' R a`) and converse
(`isIdentitySystem_of_fiberwise_equiv`) are both established, together with the
coherence law `pathIdentitySystem_idToR` showing the tautological path family
realises `idToR` as the identity. This makes precise the slogan that the path
family `(a₀ = -)` is the **homotopy-initial** (free / left-localized) pointed family
over `a₀`: every identity system is fibrewise equivalent to it, uniquely.

The decisive structural observation — recorded in the file's Lab Notebook — is that
in Lean's proof-irrelevant `Prop`, *injectivity of `idToR` is free* (the identity
type is a `Subsingleton`), so the entire mathematical content of the fundamental
theorem is concentrated in **surjectivity**, and surjectivity is exactly where
contractibility of the total space is spent. This is a reusable design principle for
the whole "homotopy & path spaces" program in a proof-irrelevant ambient theory.

## Results summary

- `HoTTFound.IdentitySystem.idToR_injective` — always injective (proof irrelevance).
- `HoTTFound.IdentitySystem.idToR_surjective` — surjective, from contractibility.
- `HoTTFound.IdentitySystem.idToR_bijective` — the fundamental theorem, fibrewise.
- `HoTTFound.IdentitySystem.fundamentalEquiv` / `.fundamental` — the promised
  equivalence `(a₀ = a) ≃' R a`.
- `HoTTFound.pathIdentitySystem_idToR` — coherence with the tautological path family.
- `HoTTFound.isIdentitySystem_of_fiberwise_equiv` — the converse, giving the full ↔.

All depend only on `propext`, `Classical.choice`, `Quot.sound` (the converse needs
only `propext`).

## Research directions for the next cycle

### 1. Uniqueness of the fundamental equivalence (the "induction principle" sharpening)

We proved the *existence* of `(a₀ = a) ≃' R a`. The sharper, falsifiable claim is
**uniqueness up to the structure**: for an identity system `S`, any pointed
fibrewise map `g : ∀ a, (a₀ = a) → R a` with `g a₀ rfl = S.rflR` must agree with
`S.idToR` pointwise, and is therefore an equivalence. Concretely, conjecture that
`(∀ a (p : a₀ = a), g a p = S.idToR a p)` is *forced* by `g a₀ rfl = S.rflR` alone.
The key insight is that a pointed map out of the contractible based-path space is
determined by its value at the centre `⟨a₀, rfl⟩`, so `g` is rigid. Why now? The
machinery is already in place — `idToR`, `fundamentalEquiv`, and
`contractible_based_paths` — and uniqueness is the missing half that upgrades the
"fundamental theorem" into a genuine *induction principle* (a dependent eliminator)
for identity systems, the form actually used in HoTT practice.

### 2. Transport of the fundamental theorem along a fibrewise equivalence (functoriality)

Conjecture: if `R` and `R'` are two families over `a₀` with reflexivity witnesses,
and there is a *pointed* fibrewise equivalence `R a ≃' R' a` commuting with the
witnesses, then `R` is an identity system iff `R'` is, and the induced square of
`idToR` maps commutes up to the proof-irrelevant equality on paths. The key insight
is that contractibility of total spaces is invariant under fibrewise equivalence
(it is a homotopy-invariant property), so "being an identity system" is itself a
property of the *homotopy type* of the family, not its presentation. Why now? With
`fundamentalEquiv` and `isIdentitySystem_of_fiberwise_equiv` proved, transport is a
short composition of existing equivalences, and it would establish the first genuine
*invariance* statement (the v13 "higher categorical invariance" mandate) for this
corner of the catalog.

### 3. Bridging to Mathlib's classical homotopy: identity systems as representable functors

Conjecture a representability bridge: the based-path identity system represents the
functor `a ↦ (a₀ = a)` and, via `HoTTFound.Equiv'`-to-`Equiv` translation, this
matches the topological fact already in the catalog
(`Catalog/Speculative/AutoResearch/PathSpaceHLevels.lean`,
`maps_to_contractible_homotopic`) that mapping spaces into a contractible target are
connected up to homotopy. Precisely: the contractibility of `Σ a, R a` should be
provably equivalent to the statement that the "constant family" map into it is a
homotopy equivalence in Mathlib's `ContinuousMap.Homotopic` sense for the discrete
realisation. The key insight is that an identity system is a *synthetic* witness of
the same universal property that `ContractibleSpace` provides *classically* —
terminality in the homotopy category. Why now? The synthetic side
(`Fundamental.lean`) and the classical side (`PathSpaceHLevels.lean`) now both exist
in the catalog with compatible vocabulary (`IsContr`, `Contractible`,
`ContractibleSpace`), so a cross-domain bridge theorem is finally a matter of
matching two existing universal properties rather than building new theory.

### 4. Higher identity systems and a synthetic Eckmann–Hilton at the path level

Conjecture that iterating the construction — an identity system on the *path family*
of an identity system — yields a contractible 2-cell structure, and that the two
induced composition operations on `a₀ = a₀` satisfy the interchange law, so the
catalog's `HoTT.eckmann_hilton_comm` (in `Logic/HomotopyTypeTheory.lean`) applies to
show the loop family is abelian. The key insight is that the fundamental theorem
turns the (a priori opaque) loop space `a₀ = a₀` into the concrete family value
`R a₀`, transporting algebraic structure across the equivalence. Why now? Both
ingredients are proven and in scope — the fundamental equivalence here and
Eckmann–Hilton in the catalog — so the next cycle can *compose* them rather than
re-derive either, testing whether π₁-abelianness survives the proof-irrelevant
encoding.

### 5. Failure boundary: where proof irrelevance trivialises the theory (a falsifiable negative)

A sharp, falsifiable *negative* conjecture: in Lean's proof-irrelevant `Prop`,
every h-level above `(-1)` collapses, so the fundamental theorem has nontrivial
content *only* when the family `R` lands in `Prop`-like (subsingleton) fibres, and
any attempt to state a genuinely 2-dimensional ("uniqueness of `idToR` up to a
*specified, nontrivial* path") refinement will be provably vacuous. The key insight
is that `IsHSet` is automatic here (recorded already in `PathSpaceHLevels.lean`), so
the catalog's synthetic homotopy theory is *exactly* an (∞,1)-theory truncated at
1-types — and the precise truncation level is testable by exhibiting a family where
the data-valued `≃'` and the `Prop`-valued `Nonempty (≃')` provably diverge. Why
now? This cycle pinned down *which* half of the fundamental theorem carries content
(surjectivity) and which is free (injectivity); the natural next experiment is to
map the full boundary of triviality, telling future cycles whether to stay synthetic
or to migrate to a data-valued (`Sort`-level) identity-type development to recover
higher structure.
