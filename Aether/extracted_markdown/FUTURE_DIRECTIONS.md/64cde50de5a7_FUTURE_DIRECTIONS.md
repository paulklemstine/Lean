# Future Directions — Local-to-Global Structure of the Exponential-Convolution Ring

## Synthesis

The combinatorial species program in `Catalog/Applications/` has, over several cycles,
turned Joyal's exponential generating function (EGF) `egf a = ∑ₙ (aₙ/n!) Xⁿ` from a
collection of scattered homomorphism identities into a fully bundled algebraic object:

* `CombinatorialSpecies.lean` — the EGF dictionary for sum (`egf_add`), Day-convolution
  product (`egf_mul`, `egf_card_prodSpecies`), and the first-order differential calculus
  (`egf_derivative`, `egf_pointing`).
* `SpeciesAnalyticBridge.lean` — the EGF is a *bijection* `(ℕ → ℚ) ≃ ℚ⟦X⟧` with explicit
  inverse `seqOf`, hence a complete enumerative invariant (`Species.EGF_inj`).
* `SpeciesConvolutionRing.lean` — the bijection is upgraded to a ring isomorphism
  `egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧`, so counting sequences form a commutative ring under
  pointwise `+` and binomial convolution `binConv`.

This cycle (`SpeciesConvolutionLocalRing.lean`) adds the **local-to-global** layer. The EGF
ring isomorphism is exploited to transport the local-ring (DVR) and integral-domain structure
of `ℚ⟦X⟧` onto the species ring `ConvSeq`, and to pin down its arithmetic in terms of a single
stalk — the empty-set count `a 0`. The headline results are:

* `egf_constantCoeff` — the **stalk at the origin** of the EGF is exactly the empty-set count
  `a 0` (the number of structures a species places on the empty label set).
* `ConvSeq.instIsLocalRing` — the exponential-convolution ring of counting sequences is a
  **local ring**, transported from the local-ring (DVR) structure of `ℚ⟦X⟧`.
* `ConvSeq.isUnit_iff` — **global invertibility is detected at a single stalk**: a counting
  sequence is a unit iff `a 0 ≠ 0`.
* `ConvSeq.mem_maximalIdeal_iff` — the unique maximal ideal is the **augmentation ideal**
  `{a | a 0 = 0}`: precisely the species with no structure on the empty set.
* `ConvSeq.instIsDomain` — the species ring is an **integral domain**: the binomial
  convolution of two nonzero counting sequences is nonzero.

The unifying picture: invertibility of a species "global object" is a purely *local*
(degree-0) condition, the species-theoretic face of the sheaf slogan *"a section is a unit iff
its germ at each point is."* Here the relevant space is a single point — the formal disk
`Spec ℚ⟦X⟧` — whose closed point carries the empty-set count.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `egf_constantCoeff` | `constantCoeff (egf a) = a 0` | propext, choice, Quot.sound |
| `ConvSeq.instIsLocalRing` | `IsLocalRing ConvSeq` | propext, choice, Quot.sound |
| `ConvSeq.isUnit_iff` | `IsUnit a ↔ a.seq 0 ≠ 0` | propext, choice, Quot.sound |
| `ConvSeq.mem_maximalIdeal_iff` | `a ∈ 𝔪 ↔ a.seq 0 = 0` | propext, choice, Quot.sound |
| `ConvSeq.instIsDomain` | `IsDomain ConvSeq` | propext, choice, Quot.sound |

All compile with `sorry = 0`. Two pre-existing duplicate-declaration build errors in the
chain — `egf_injective` re-declared in `SpeciesAnalyticBridge.lean` over the base file, and
`binConv_comm` re-declared in `SpeciesConvolutionRing.lean` over the base file — were repaired
by commenting out the redundant downstream copies (the base declarations are imported), so the
whole species chain compiles. A scoped `SpeciesChain` library target was added to
`lakefile.toml` so the chain builds in isolation despite the repository's mixed module-naming
conventions.

## Research Directions

### 1. The order valuation and the discrete-valuation-ring refinement
With `ConvSeq.instIsDomain` and `ConvSeq.instIsLocalRing` now in hand, the natural next object
is the *order* valuation `ord : ConvSeq → ℕ ∪ {∞}` sending a counting sequence to its least
arity with nonzero count (its first nonempty arity as a species). Conjecture: `ord` is
multiplicative, `ord (a ⋆ b) = ord a + ord b`, the `𝔪`-adic filtration `𝔪ᵏ` is exactly
`{a | ∀ i < k, a i = 0}`, and `ConvSeq` is therefore a discrete valuation ring with explicit
uniformizer the singleton species `X` (the sequence `(0,1,0,0,…)`). *The key insight is* that
binomial convolution does not move the lowest nonzero degree: the bottom coefficient of
`a ⋆ b` at arity `ord a + ord b` is `C(i+j, i)·a_i·b_j ≠ 0`, so the valuation is literally the
EGF-degree filtration. *Why now?* `isUnit_iff` and `mem_maximalIdeal_iff` already identify `𝔪`,
and `IsDomain` guarantees no cancellation in the bottom coefficient, so the order-additivity is
a single antidiagonal computation that upgrades the local-ring fact to a DVR with a named
uniformizer.

### 2. A constructive species reciprocal from local invertibility
`ConvSeq.isUnit_iff` asserts that `a 0 ≠ 0` guarantees an inverse, but only abstractly via the
analytic transport. Conjecture: the inverse is given by the explicit Newton-style recursion
`b 0 = 1 / a 0`, `b n = -(1 / a 0)·∑_{i=1}^n C(n,i)·a i·b (n-i)`, and this `b` satisfies
`binConv a b = binConvOne` coefficientwise. *The key insight is* that the recursion is finite at
every arity and is the species analogue of power-series inversion, turning the local-to-global
existence statement into a `#eval`-able algorithm. *Why now?* The unit criterion is proved and
`binConv` is already defined over `Finset.antidiagonal`, so the missing piece is purely the
closed-form recursion and a finite induction on arity proving it inverts `a`.

### 3. The exponential formula as an isomorphism `𝔪 ≃ 1 + 𝔪`
For a species `G` with `G 0 = 0` (i.e. `G ∈ 𝔪` by `mem_maximalIdeal_iff`), the assembly of
connected pieces `E ∘ G` should have EGF `exp (egf G)`. Conjecture: the map `G ↦ E∘G` is a
group isomorphism from the additive group of the maximal ideal `𝔪` onto the multiplicative group
of principal units `1 + 𝔪` of `ConvSeq`. *The key insight is* that `exp` converges
coefficientwise *exactly* on `𝔪` (the convergence obstruction is precisely the empty-set count
being nonzero), so the classical exponential formula becomes the statement that `exp` carries `𝔪`
bijectively onto `1 + 𝔪`. *Why now?* The local-ring scaffolding isolates `𝔪` as the convergence
domain, and `egf_binConvPow` already gives `egf (G^{⋆k}) = (egf G)^k`, so summing `1/k!` over the
`𝔪`-adically convergent tower assembles the isomorphism.

### 4. The residue field and a split short exact sequence
The local ring `ConvSeq` has residue field `ConvSeq / 𝔪`. Conjecture: the empty-set count map
`a ↦ a 0` induces a ring isomorphism `ConvSeq / 𝔪 ≅ ℚ`, and the short exact sequence
`0 → 𝔪 → ConvSeq → ℚ → 0` splits via the inclusion of scalar species `c ↦ (c,0,0,…)`. *The key
insight is* that `egf_constantCoeff` already exhibits `a ↦ a 0` as a surjective ring hom with
kernel exactly `𝔪` (by `mem_maximalIdeal_iff`), so the first isomorphism theorem delivers the
residue field and the scalar embedding is a one-sided inverse. *Why now?* All three ingredients
— the surjection, the kernel description, and the section — are immediate from this cycle's
theorems, making the residue-field identification a short assembly rather than new theory.

### 5. Multivariate species and a sheaf over the formal polydisk
`k`-sorted species (structures on `k` independently labelled sets) should form a ring isomorphic
to `ℚ⟦X₁,…,X_k⟧` via a multivariate EGF. Conjecture: this ring is again local with maximal ideal
the multi-augmentation `{a | a 0…0 = 0}` and again an integral domain, and the "set sort `i` to a
point" restriction maps assemble into a presheaf on the face lattice of the formal polydisk whose
global sections are the multivariate counting sequences. *The key insight is* that the
single-variable local-to-global theorem of this file is the rank-one (closed-point) stalk of a
multivariate sheaf, and the gluing of single-sort stalks recovers multi-sort species because EGF
multiplication is sort-wise. *Why now?* Mathlib's `MvPowerSeries` already carries the local-ring
and domain instances over a field, so the entire transport in this file ports almost verbatim,
giving the concrete sheaf/local-to-global object with the present file as its rank-one fiber.
