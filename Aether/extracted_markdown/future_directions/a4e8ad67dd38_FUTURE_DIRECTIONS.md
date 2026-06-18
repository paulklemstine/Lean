# Future Directions — The EGF Algebra of Combinatorial Species

## Synthesis

The base file `Applications/CombinatorialSpecies.lean` had already isolated the two pillars of
Joyal's analytic-functor dictionary — additivity (`egf_add`) and the binomial-convolution product
law (`egf_mul`, `egf_card_prodSpecies`) — together with the decisive structural fact that the EGF
transform is **injective** (`egf_injective`). The new file `Applications/SpeciesEGFAlgebra.lean`
takes the next conceptual step: it stops treating these as separate identities and shows that they
*cohere into a single algebraic object*. Concretely, the binomial convolution `binConv` on counting
sequences inherits the full commutative-ring skeleton of `ℚ⟦X⟧` — a two-sided unit `deltaSeq`
(`binConv_one_left/right`, `egf_delta`), associativity (`binConv_assoc`), distributivity over
pointwise addition (`binConv_left_distrib`), and even a **Leibniz product rule** (`binConv_leibniz`)
— all obtained by the uniform "analytic shadow" move: transport along the injective intertwiner
`egf`. On the species side we added the disjoint-union species (`Species.sum`, `EGF_sumSpecies`) and
the unit species (`oneSpecies`, `EGF_oneSpecies`), giving the additive monoid and the multiplicative
identity that complete the picture started by `egf_card_prodSpecies`.

## Results Summary

- `egf_delta` — the unit counting sequence `δ = (1,0,0,…)` has EGF `1`.
- `binConv_assoc` — associativity of the species product, as the shadow of `mul_assoc`.
- `binConv_one_left`, `binConv_one_right` — `δ` is a two-sided unit for `binConv`.
- `binConv_left_distrib` — `binConv` distributes over pointwise addition.
- `binConv_leibniz` — the Leibniz product rule `(a ⋆ b)′ = a′ ⋆ b + a ⋆ b′` for the index shift.
- `Species.sum` / `EGF_sumSpecies` — disjoint union of species ↔ addition of EGFs.
- `oneSpecies` / `EGF_oneSpecies` — the unit species ↔ the power series `1`.

All theorems compile with no `sorry` and only the standard Lean/Mathlib axioms.

## Falsifiable Research Directions

**1. The EGF is a bona fide injective ring homomorphism `(ℕ → ℚ, +, ⋆) →+* ℚ⟦X⟧`.**
Package the scattered laws into a single bundled `RingHom` out of a type synonym `ExpSeq := ℕ → ℚ`
whose multiplication is `binConv` and whose one is `deltaSeq`, transported via
`Function.Injective.commRing` along `egf`. The falsifiable claim: such a `CommRing ExpSeq` instance
exists making `egf` a `RingHom`, and it is *not* the pointwise Pi-ring (so the two ring structures on
`ℕ → ℚ` are genuinely different and `egf` is a ring iso onto its image). The key insight is that
every ring axiom for `binConv` is already a one-line shadow of the corresponding axiom in `ℚ⟦X⟧`, so
the only real work is the instance plumbing (pow, nsmul, zsmul, casts), each provable by `egf`
additivity/multiplicativity plus induction. Why now? The six laws proved this cycle are *exactly* the
hypotheses `Function.Injective.commRing` demands; the bundling is the natural capstone and turns the
species file into an importable algebra rather than a list of lemmas.

**2. The structural product species is a genuine functor with EGF equal to the product.**
The base file proves the product *counting* law (`egf_card_prodSpecies`) but never builds the product
as a `Species` (it lacks the relabelling action). Conjecture: one can equip
`(F · G)[n] = Σ_{S ⊆ Fin n} F[|S|] × G[n∖|S|]` with a monoid-hom action of `Equiv.Perm (Fin n)`
(permuting the chosen subset `S` and relabelling within both blocks) so that `Species.prod` is a
lawful species and `EGF_prodSpecies : (F.prod G).EGF = F.EGF * G.EGF` holds. The key insight is that
the action only needs to permute the index `S ↦ σ • S` while carrying the inner structures along a
cardinality-preserving reindexing, so functoriality reduces to `Finset.image` being a group action
and the inner `F.act`/`G.act` being homs. Why now? With `oneSpecies` (the multiplicative unit) and
`Species.sum` (the additive monoid) now in place, `Species.prod` is the one missing operation needed
to state that `(Species, ⊞, ·, 0, 1)` is a semiring up to natural isomorphism, with `EGF` a semiring
morphism into `ℚ⟦X⟧`.

**3. The categorified Leibniz rule lifts from sequences to species.**
We proved the Leibniz rule `binConv_leibniz` at the level of counting sequences. Conjecture: it lifts
to a species isomorphism `(F · G)′ ≅ F′ · G + F · G′` whose EGF identity is exactly
`(F.EGF * G.EGF)′ = F′.EGF * G.EGF + F.EGF * G′.EGF`, which already follows from
`EGF_derivativeSpecies`, `binConv_leibniz`, and direction 2's `EGF_prodSpecies`. The key insight is
that, by `egf_injective`, the *enumerative* Leibniz identity is forced the instant the product
species exists; the remaining content is purely the combinatorial bijection witnessing the
isomorphism of structure types. Why now? `binConv_leibniz` and `EGF_derivativeSpecies` are both
proved, so the EGF half is free and only the species-level bijection (direction 2's action) is
outstanding.

**4. Composition of species ↔ substitution of EGFs (the exponential formula).**
The deepest missing operation is composition `(F ∘ G)[n] = Σ_{partitions π of [n]} F[|π|] ×
∏_{B ∈ π} G[|B|]`, whose EGF is `F.EGF` evaluated at `G.EGF` (for `G` with no constant term). A
sharp, falsifiable special case: for the set species `E` (with `EGF = exp`) and a species `G` with
`G[0] = ∅`, the composite `E ∘ G` satisfies `(E ∘ G).EGF = PowerSeries.exp ℚ ∘ G.EGF`, i.e. the
classical exponential formula "EGF of structures whose connected pieces are `G`-structures is
`exp(EGF G)`". The key insight is that the partition sum is a `binConv`-style convolution indexed by
set partitions, so the proof should reduce to a `Bell`-number recursion that `egf_mul` already linearizes coefficientwise. Why now? With `egf_mul`, `egf_delta` (the `G[0]=∅` boundary condition),
and the additive/Leibniz calculus established, composition is the unique remaining classical
operation, and the exponential formula is the headline payoff of the entire species program.

**5. The EGF dictionary refines to a `ZMod p` / characteristic-`p` shadow detecting congruences.**
Replace `ℚ` by `ZMod p` (or work integrally and reduce) and ask which species identities survive.
Conjecture: `egf` over `ℚ` is injective (proved), but its mod-`p` reduction is *not*, and the kernel
encodes exactly the Kummer/Lucas congruences for the binomial coefficients appearing in `binConv`. A
concrete falsifiable instance: for the linear-order species `L` with `L[n] = n!`, the mod-`p`
EGF stabilizes (all coefficients past `p-1` vanish since `p ∣ n!`), giving a finite-degree truncation
phenomenon absent over `ℚ`. The key insight is that the factorial denominators in `egf` are precisely
where characteristic-`p` information is destroyed, so studying the *failure* of injectivity mod `p`
turns the EGF bridge into a detector of arithmetic structure in counting sequences. Why now? The
injectivity proof `egf_injective` makes its own boundary conditions explicit (it uses
`Nat.factorial_ne_zero` in `ℚ`), pinpointing exactly the hypothesis that breaks mod `p` and making
the contrast a clean, immediately testable next experiment.
