# Future Directions — The Algebra of Combinatorial Species

## Synthesis

The catalog file `Applications/CombinatorialSpecies.lean` built the exponential-generating-function
(EGF) dictionary for Joyal's species: the disjoint union of species corresponds to addition of
power series, the structural (Day-convolution) product corresponds to multiplication via the
**binomial convolution** `binConv`, and the differential operators (derivative `F′`, pointing `F•`)
correspond to the formal derivative and the Euler operator on `ℚ⟦X⟧`.

The new file `Applications/SpeciesExponentialRing.lean` closes the algebraic loop. It shows that
these scattered homomorphism *laws* are really the fingerprints of a single object: the EGF
transform is an **isomorphism of commutative rings**

> `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧`,

where `ExpRing` is the set of counting sequences `ℕ → ℚ` under pointwise sum and binomial
convolution — the **Hurwitz / exponential-convolution ring** of enumerative combinatorics. The
transform is bijective with the explicit inverse `egfInv f n = n! · [Xⁿ] f`; the unit of the
combinatorial product is the Kronecker sequence `δ` (the empty-structure species `1`); and the
analytic identities `mul_assoc` / `one_mul` of `ℚ⟦X⟧` *force* the combinatorial associativity and
unit laws of the species product (`binConv_assoc`, `binConv_one_left`). Finally `egfInv_exp` shows
that `exp` pulls back to the constant-one sequence — the species of sets `E` — so the exponential
function is *literally* the image of "one structure on every label set".

## Results summary

* `egf_bijective` — the EGF transform is a bijection `(ℕ → ℚ) ≃ ℚ⟦X⟧`.
* `ExpRing.commRing` — the binomial-convolution ring on counting sequences.
* `ExpRing.egfRingEquiv` — the EGF transform is a ring isomorphism `ExpRing ≃+* ℚ⟦X⟧`.
* `binConv_assoc`, `binConv_one_left`, `binConv_one_right` — associativity and unit laws of the
  species product, obtained as analytic shadows.
* `egfInv_exp` / `egfRingEquiv_symm_exp` — the species of sets is the EGF-preimage of `exp`.

All main results compile with no `sorry` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Research directions

### 1. The substitution product and the exponential formula

The two monoidal operations formalized so far (sum and product) are only half of Joyal's calculus;
the third, and most powerful, is **substitution** `F ∘ G` — "an `F`-structure of `G`-structures",
whose counting law is a sum over set partitions. The bold conjecture is that the EGF transform
remains a homomorphism for this operation: `EGF(F ∘ G) = EGF(F) ∘ EGF(G)` whenever `G` has no
constant term, with the **exponential formula** `EGF(E ∘ G) = exp(EGF G)` as its flagship special
case. The key insight is that substitution should appear in `ExpRing` as a *second*, non-linear
composition operation that is intertwined by `egfRingEquiv` with formal power-series composition
`PowerSeries.comp`, turning the ring isomorphism into a morphism of the richer
"composition-with-multiplication" structure. Why now? The ring isomorphism `egfRingEquiv` already
provides the dictionary in both directions, and Mathlib now has a usable formal-composition API for
power series; the only genuinely new combinatorial content is the partition-indexed cardinality
count, which can be isolated as a single lemma analogous to `card_prodSpecies`.

### 2. Units, valuations, and the local structure of `ExpRing`

Because `egfRingEquiv` is a ring isomorphism onto `ℚ⟦X⟧`, the binomial-convolution ring `ExpRing`
inherits the entire local-ring structure of formal power series: it is a complete local ring whose
units are exactly the sequences with `a₀ ≠ 0`, with the `X`-adic valuation transported to "index of
the first nonzero term". The conjecture is that a species is invertible under the structural product
**iff** it has exactly one structure on the empty set, and that the inverse can be computed by the
recursive binomial-convolution Neumann series. The key insight is that *invertibility of a species*
is not a combinatorial accident but the shadow of `IsUnit` in `ℚ⟦X⟧`, so the entire valuation theory
is free once transported. Why now? `egfRingEquiv` makes the transport mechanical (`MulEquiv.isUnit`,
`RingEquiv` preserves `IsLocalRing`), so this direction converts a deep-sounding combinatorial claim
into a short corollary plus an explicit recursion.

### 3. A differential ring isomorphism

The catalog already proved `EGF(F′) = (EGF F)′` and `EGF(F•) = X·(EGF F)′`. The conjecture is that
the shift operator `a ↦ a(· + 1)` makes `ExpRing` a **differential ring** and that `egfRingEquiv`
upgrades to an isomorphism of differential rings intertwining the shift with `derivativeFun` on
`ℚ⟦X⟧`. The key insight is that the Leibniz rule for the species product — `(F·G)′ ≅ F′·G + F·G′` —
is then not a separate combinatorial theorem but a *forced* consequence of the differential-ring
axioms together with the existing product bridge. Why now? Both halves (the ring isomorphism and the
derivative bridge `egf_derivative`) are now in place, so the remaining step is purely to bundle the
shift as a derivation and check the single Leibniz identity through the isomorphism.

### 4. `ExpRing` as the decategorification (Grothendieck ring) of species

The structure `Species` of `CombinatorialSpecies.lean` is a genuine category (functors on the
groupoid of finite sets); `ExpRing` is its ring of counting sequences. The conjecture is that
`coeffSeq : Species → ExpRing` is a **decategorification functor**: it sends the categorical sum and
product of species to `+` and `binConv`, exhibiting `ExpRing` as the Grothendieck/Burnside-style
semiring of the symmetric monoidal category of species, with `egfRingEquiv` then identifying that
Grothendieck ring with `ℚ⟦X⟧`. The key insight is that the EGF is best understood as the composite
"categorify a power series ⇒ count ⇒ divide by symmetries", and the ring isomorphism is the precise
statement that no enumerative information is lost in this descent. Why now? The species product on
*objects* (`card_prodSpecies`) and the ring on *sequences* (`egfRingEquiv`) are both formalized, so
the missing arrow is exactly the functoriality square relating them — a finite, checkable diagram.

### 5. The λ-ring / plethystic refinement via cycle-index series

EGFs remember only cardinalities, not the symmetric-group action. Refining `obj n` to its
`Sₙ`-action and replacing `egf` by the **cycle-index (Frobenius characteristic) series** in symmetric
functions promotes `ExpRing` to a **λ-ring**, with plethysm `f[g]` as the substitution operation.
The conjecture is that there is a λ-ring homomorphism `Species → Λ_ℚ` whose composition with the
specialization `p₁ ↦ X, pₖ ↦ 0 (k ≥ 2)` recovers `egfRingEquiv`. The key insight is that `egfRingEquiv`
is the "principal specialization" of a much finer invariant, so all the equalities proved here are
shadows of identities in the ring of symmetric functions, where plethysm and the λ-operations live.
Why now? Mathlib's symmetric-functions and power-series libraries have matured to the point where the
specialization map is expressible, and the present ring isomorphism gives a concrete target to test
the refinement against on every example (sets ↦ `exp`, linear orders ↦ `1/(1-X)`).
