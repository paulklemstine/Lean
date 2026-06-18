# Future Directions — The Exponential-Convolution Ring and the Joyal Dictionary

## Synthesis

The species program in this project now has three layers. The base file
`Catalog/Applications/CombinatorialSpecies.lean` proved that the exponential generating
function `egf a = ∑ₙ (aₙ/n!) Xⁿ` is *additive* over the sum of species (`egf_add`) and
*multiplicative* over the Day-convolution product (`egf_mul`, `egf_card_prodSpecies`), and
identified the species of sets with `exp` and the species of linear orders with `1/(1-X)`.
The sibling file `Catalog/Applications/SpeciesAnalyticBridge.lean` upgraded these to a
*bijection* `egfEquiv : (ℕ → ℚ) ≃ ℚ⟦X⟧` (with explicit inverse `seqOf`), and added the
differential layer (`egf_seqDeriv`, `egf_seqPoint`, `binConv_leibniz`).

The new file `Catalog/Applications/SpeciesConvolutionRing.lean` closes the *structural*
gap. It bundles the scattered homomorphism identities into a single object: counting
sequences form a commutative ring `ConvSeq` under pointwise addition and binomial
convolution, and the EGF is a ring isomorphism `egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧`. From
this one bundling we read off — with zero index manipulation — the commutative-semiring
axioms of `binConv` (`binConv_comm`, `binConv_assoc`, the unit laws, `binConv_add`), the
power law `egf (binConvPow a k) = (egf a)^k`, and a generalization of the linear-order EGF
to every factorial-counted species.

## Results summary

- `ConvSeq` / `egfRingEquiv` — the exponential-convolution **ring** of counting sequences,
  and the EGF as a bundled **ring isomorphism** onto `ℚ⟦X⟧`.
- `ConvSeq.mul_seq`, `add_seq`, `one_seq`, `zero_seq` — the transported ring operations are
  *exactly* `binConv`, pointwise `+`, `binConvOne`, and `0`.
- `binConv_comm`, `binConv_assoc`, `binConv_one_left`, `binConv_one_right`, `binConv_add` —
  the exponential-convolution semiring axioms, obtained for free from the ring structure.
- `egf_binConvPow` — the EGF of the computable `k`-fold convolution `binConvPow a k` equals
  `(egf a)^k`.
- `Species.EGF_inv_one_sub_X_of_factorial` (+ `egf_linearOrderSpecies_inv`) — every species
  counted by `n!` has EGF `1/(1-X)`.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`.

## Direction 1 — Composition of species = substitution of EGFs

**Conjecture.** Define a *composition* product on counting sequences with `T 0 = 0` by
summing over set partitions: a `(S ∘ T)`-structure on `[n]` is a partition of `[n]` into
blocks, an `S`-structure on the set of blocks, and a `T`-structure on each block. Then
`egf (S ∘ T) = (egf S) ∘ (egf T)` as formal power-series substitution, and as the special
case `S = E` (constant `1`), `egf (E ∘ T) = exp (egf T)` (the exponential formula).

The key insight is that the just-proven power law `egf_binConvPow : egf (binConvPow a k) =
(egf a)^k` is precisely the "`k` identical blocks" stratum of the partition sum; composition
is the assembly of these strata weighted by partition counts, so the substitution law should
follow by summing `egf_binConvPow` over `k` against the multinomial partition coefficients
rather than by re-deriving any convolution from scratch. **Why now?** With `egf_binConvPow`
and `egfRingEquiv` in hand, the analytic side (`PowerSeries` composition / `exp`) and the
power identity are both already available; the only missing combinatorial input is the count
of partitions into `k` blocks, which Mathlib supplies via `Finset` partitions and Stirling /
`Nat.choose` machinery. Closing this turns the homomorphism into the full Joyal dictionary.

## Direction 2 — `egfRingEquiv` makes named EGFs a subring dictionary

**Conjecture.** The image under `egfRingEquiv` of the sub-semiring of *integer-valued,
combinatorially realized* counting sequences (those of the form `n ↦ |F[n]|` for a
`Species F`) is closed under `+`, `binConv`, and `binConvPow`, and contains `exp`,
`1/(1-X)`, and every polynomial in them. Concretely, `setSpecies`, `linearOrderSpecies`,
and their convolution products generate a recognizable sub-dictionary of `ℚ⟦X⟧`.

The key insight is that `egfRingEquiv` being a *ring* iso (not just three separate maps)
means the set of realizable EGFs is automatically a sub-semiring, so closure properties are
inherited rather than re-proved; combined with `Species.EGF_inj` from the sibling file, two
species are isomorphic in count iff their EGFs coincide *as ring elements*. **Why now?** The
ring iso and the injectivity invariant already exist; the remaining work is to define the
structural sum and product of `Species` (not just of raw sequences) and check
`(setSpecies + linearOrderSpecies).EGF = exp + 1/(1-X)` via `map_add`, which is now a
one-liner. This seeds a reusable library of named species with verified EGFs.

## Direction 3 — The derivative is a ring derivation on `ConvSeq`

**Conjecture.** The derivative map `seqDeriv` (from the sibling file) lifts to an additive
map `ConvSeq → ConvSeq` that is a **derivation**: `D (a * b) = D a * b + a * D b` and
`D 1 = 0`, making `(ConvSeq, +, binConv, D)` a differential commutative ring, and
`egfRingEquiv` a differential ring isomorphism onto `(ℚ⟦X⟧, derivativeFun)`.

The key insight is that `binConv_leibniz` already proves the product rule at the sequence
level, and `egf_seqDeriv` shows `seqDeriv` transports to `derivativeFun`; bundling these
into a `Derivation`/differential-ring structure on `ConvSeq` is the exact derivative-side
analogue of what `egfRingEquiv` did for the product. **Why now?** Both the Leibniz identity
and the transport lemma are in place, and Mathlib has a `Derivation` API; the only new step
is to package `seqDeriv` as an additive hom on the wrapper `ConvSeq` and feed the existing
lemmas as its fields, after which `map`-style differential identities become free downstream.

## Direction 4 — Functoriality forces counts to be cardinality invariants (categorical loop)

**Conjecture.** For the categorical species layer, define `speciesCard F n :=
Fintype.card (F.obj n)`; then any natural isomorphism `F ≅ G` induces `speciesCard F =
speciesCard G`, hence `F.EGF = G.EGF` via `egfRingEquiv`. More strongly, `speciesCard` is
invariant under the relabelling action, so the concrete `ConvSeq` layer is a faithful shadow
of the categorical `Species` layer.

The key insight is that `Fintype.card` is an `Equiv`-invariant (`Fintype.card_congr`), so a
pointwise structural iso upgrades to equality of counts, and then `Species.EGF_inj` upgrades
equality of counts to equality of ring elements in `ConvSeq` — closing the loop between the
groupoid-action definition of species and the enumerative ring. **Why now?** The
`Species` structure (with its `act : Sₙ →* Perm (F[n])` field) and `Species.EGF_inj` already
exist; the missing lemma is a short `Fintype.card_congr` bridge, whose real value is
methodological: it certifies the ring `ConvSeq` as the legitimate invariant of the
categorical theory.

## Direction 5 — Units and the multiplicative inversion algorithm

**Conjecture.** A counting sequence `a` is a unit in `ConvSeq` iff `a 0 ≠ 0`, and its
inverse is computed by the explicit recursion `b 0 = (a 0)⁻¹`,
`b n = -(a 0)⁻¹ · ∑_{i=1}^{n} C(n,i) · a i · b (n-i)`. Equivalently, `egfRingEquiv` carries
units of `ConvSeq` to units of `ℚ⟦X⟧` and the recursion is the image of `PowerSeries`
inversion under `seqOf`.

The key insight is that `egfRingEquiv` is a ring iso, so `IsUnit a ↔ IsUnit (egf a)`, and
`PowerSeries` over a field is a local ring whose units are exactly the series with nonzero
constant term — transporting this back through `seqOf` yields a *terminating, computable*
binomial-convolution inversion algorithm. **Why now?** Mathlib's `PowerSeries.invOfUnit`
and the constant-term unit criterion give the analytic side immediately; the ring iso
established here is exactly the tool needed to pull the inverse back to an explicit
algorithm on counting sequences, delivering constructive content (a `#eval`-able inverse)
on top of the abstract isomorphism.
