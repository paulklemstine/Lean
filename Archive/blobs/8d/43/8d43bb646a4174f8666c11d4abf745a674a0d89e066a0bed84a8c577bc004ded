# Future Directions — The Fundamental Theorem of Identity Systems

## Synthesis of this cycle

The catalog's synthetic-HoTT layer (`Catalog/Logic/HoTT/Foundations.lean`) *defined*
the structure `HoTTFound.IdentitySystem` — a based family `R` over `a₀` carrying a
reflexivity witness `rflR : R a₀` together with a proof that the total space
`Σ' a, R a` is contractible and centred at `⟨a₀, rflR⟩` — and its docstring *promised*
that "the fundamental theorem says this data yields an equivalence `(a₀ = a) ≃' R a`
for all `a`." That theorem was never stated. This cycle closes the gap.

In `Catalog/Logic/HoTT/Fundamental.lean` we prove the **fundamental theorem of
identity types** (HoTT book §5.8 / Awodey–Gambino–Sojakova) as a genuine
biconditional, entirely `sorry`-free:

> A based family `R` over `a₀` with reflexivity witness `r₀ : R a₀` has contractible
> total space `Σ' a, R a` (centred at `⟨a₀, r₀⟩`) **iff** the canonical transport
> map `idToR : (a₀ = a) → R a`, `p ↦ p ▸ r₀`, is an equivalence for every `a`.

Both directions are established — forward as `IdentitySystem.idToR_bijective` and the
packaged equivalence `IdentitySystem.fundamentalEquiv : (a₀ = a) ≃' R a`, converse as
`isIdentitySystem_of_fiberwise_equiv` — together with the single-statement
biconditional `fundamentalTheorem_iff` and the coherence law
`pathIdentitySystem_idToR` showing the tautological path family realises `idToR` as
the identity. This makes precise the slogan that the path family `(a₀ = -)` is the
**homotopy-initial** pointed family over `a₀`.

The decisive structural observation, recorded in the file's Lab Notebook, is that in
Lean's proof-irrelevant `Prop`, *injectivity of `idToR` is free* (the identity type
is a `Subsingleton`), so the entire mathematical content of the fundamental theorem
is concentrated in **surjectivity**, where contractibility of the total space is
spent. This "injectivity free, surjectivity substantive" split is a reusable design
principle for the whole homotopy/path-space program in a proof-irrelevant ambient
theory.

## Results summary

- `IdentitySystem.idToR` — the canonical transport map `(a₀ = a) → R a`.
- `IdentitySystem.idToR_injective` — always injective (proof irrelevance), axiom-free.
- `IdentitySystem.idToR_surjective` — surjective, from contractibility, axiom-free.
- `IdentitySystem.idToR_bijective` — the fundamental theorem, fibrewise, axiom-free.
- `IdentitySystem.fundamentalEquiv` / `.fundamental` — the promised `(a₀ = a) ≃' R a`
  (uses only `Classical.choice` to select the inverse).
- `pathIdentitySystem_idToR` — coherence with the tautological path family, axiom-free.
- `isIdentitySystem_of_fiberwise_equiv` — the converse, axiom-free.
- `fundamentalTheorem_iff` — the full biconditional in one statement, axiom-free.

## Research directions for the next cycle

### 1. Uniqueness of the fundamental equivalence (the induction-principle sharpening)

We proved the *existence* of `(a₀ = a) ≃' R a`. The sharper, falsifiable claim is
**uniqueness up to the structure**: for an identity system `S`, any pointed fibrewise
map `g : ∀ a, (a₀ = a) → R a` with `g a₀ rfl = S.rflR` must agree with `S.idToR`
pointwise. Concretely, conjecture that `∀ a (p : a₀ = a), g a p = S.idToR a p` is
*forced* by `g a₀ rfl = S.rflR` alone. The key insight is that a pointed map out of
the contractible based-path space is determined by its value at the centre
`⟨a₀, rfl⟩`, so `g` is rigid: path-induction (`cases p`) reduces every input to `rfl`.
Why now? The machinery is already in place — `idToR`, `fundamentalEquiv`, and the
path-induction pattern used in `pathIdentitySystem_idToR` — and uniqueness is the
missing half that upgrades the "fundamental theorem" into a genuine *dependent
eliminator* for identity systems, the form actually used in HoTT practice.

### 2. Transport of the theorem along a fibrewise equivalence (homotopy-invariance)

Conjecture: if `R` and `R'` are two families over `a₀` with reflexivity witnesses and
a *pointed* fibrewise equivalence `R a ≃' R' a` commuting with the witnesses, then
`R` is an identity system iff `R'` is. The key insight is that contractibility of
total spaces is invariant under fibrewise equivalence (it is a homotopy-invariant
property), so "being an identity system" is a property of the *homotopy type* of the
family, not its presentation; the transport is a short composition of
`Equiv'.trans`/`Equiv'.symm` from `Foundations.lean` with `fundamentalTheorem_iff`.
Why now? With `fundamentalEquiv` and `isIdentitySystem_of_fiberwise_equiv` proved,
this is the first genuine *invariance* statement for this corner of the catalog and
needs no new theory — only assembly of existing equivalences.

### 3. The total-space map is an equivalence (a base-change reformulation)

Conjecture: an identity system is equivalent to the assertion that the fibrewise
collapse map `Σ' a, (a₀ = a) → Σ' a, R a`, `⟨a, p⟩ ↦ ⟨a, p ▸ r₀⟩`, is an `Equiv'`.
Both sides are contractible exactly when `R` is an identity system, so this packages
the *fibrewise* fundamental theorem as a *single total-space* equivalence. The key
insight is that "fibrewise equivalence between families over the same base" and
"equivalence of total spaces commuting with the projection" coincide here because
the base map is the identity — the standard HoTT lemma `totalEquiv`. Why now? We have
`contractible_based_paths` and `contr_total` giving contractibility of both ends, so
the equivalence can be built directly from the two centres without re-deriving the
fundamental theorem.

### 4. A synthetic Yoneda / representability bridge to Mathlib's contractibility

Conjecture a representability bridge: the based-path identity system represents the
functor `a ↦ (a₀ = a)`, and via a translation `HoTTFound.Equiv' → Equiv` this matches
Mathlib's classical fact that a `Subsingleton`/`Unique` total space is the universal
(terminal) pointed object. Precisely: `Contractible X` should be inter-derivable with
`Nonempty (X ≃' PUnit)` and hence with Mathlib's `Unique X`, letting the synthetic
`IdentitySystem` inherit `ContractibleSpace`-style universal properties. The key
insight is that an identity system is a *synthetic* witness of the same terminality
that `Unique`/`ContractibleSpace` provide *classically*. Why now? `Foundations.lean`
already supplies `contractible_subsingleton`, `contractible_punit`, and `Equiv'`, so
the bridge is a matter of matching two existing universal properties rather than
building new theory.

### 5. Failure boundary: where proof irrelevance trivialises higher structure

A sharp, falsifiable *negative* conjecture: in Lean's proof-irrelevant `Prop`, every
h-level above `(-1)` collapses, so the fundamental theorem has nontrivial 2-dimensional
content only when fibres are `Prop`-like; any attempt to state a genuinely
2-dimensional refinement (uniqueness of `idToR` up to a *specified, nontrivial* path)
will be provably vacuous because `a₀ = a` is a `Subsingleton`. The key insight is that
this cycle pinned down *which* half of the theorem carries content (surjectivity) and
which is free (injectivity, from `Subsingleton.elim`); the natural next experiment is
to map the full boundary of triviality by exhibiting a family where the data-valued
`≃'` and the `Prop`-valued `Nonempty (≃')` provably diverge. Why now? Establishing
this boundary tells future cycles whether to stay synthetic in `Prop` or migrate to a
data-valued (`Sort`-level) identity-type development to recover higher structure.
