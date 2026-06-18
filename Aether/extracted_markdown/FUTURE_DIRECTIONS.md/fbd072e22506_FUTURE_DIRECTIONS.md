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
  pointwise `+` and binomial convolution `binConv`, with the semiring axioms read off for free.
* `SpeciesTaylorCalculus.lean` / `SpeciesTaylorReconstruction.lean` — the full Taylor tower:
  iterated derivative/pointing, Maclaurin reconstruction, and the higher Leibniz rule.

This cycle (`SpeciesConvolutionLocalRing.lean`) adds the **local-to-global** layer that the
engine's sheaf-theoretic mandate calls for. The headline results are:

* `egf_constantCoeff` — the **stalk at the origin** of the EGF is exactly the empty-set count
  `a 0` (the number of structures a species places on the empty label set).
* `ConvSeq.instIsLocalRing` — the exponential-convolution ring of counting sequences is a
  **local ring**, transported from the local-ring (DVR) structure of `ℚ⟦X⟧`.
* `ConvSeq.isUnit_iff` — **global invertibility is detected at a single stalk**: a counting
  sequence is a unit iff `a 0 ≠ 0`.
* `ConvSeq.mem_maximalIdeal_iff` — the unique maximal ideal is the **augmentation ideal**
  `{a | a 0 = 0}`: precisely the species with no structure on the empty set.

The unifying picture: invertibility of a species "global object" is a purely *local* (degree-0)
condition, the species-theoretic face of the sheaf slogan *"a section is a unit iff its germ at
each point is."* Here the relevant space is a single point — the formal disk `Spec ℚ⟦X⟧` — whose
closed point carries the empty-set count.

## Results Summary

| Theorem | Statement | Axioms |
|---|---|---|
| `egf_constantCoeff` | `constantCoeff (egf a) = a 0` | propext, choice, Quot.sound |
| `ConvSeq.instIsLocalRing` | `IsLocalRing ConvSeq` | propext, choice, Quot.sound |
| `ConvSeq.isUnit_iff` | `IsUnit a ↔ a.seq 0 ≠ 0` | propext, choice, Quot.sound |
| `ConvSeq.mem_maximalIdeal_iff` | `a ∈ 𝔪 ↔ a.seq 0 = 0` | propext, choice, Quot.sound |

All compile with `sorry = 0`. A pre-existing duplicate-declaration build error in
`SpeciesConvolutionRing.lean` (`binConv_comm` re-declared over the base file) was repaired by
commenting out the redundant copy, restoring the whole species chain to a compiling state. A
scoped `SpeciesChain` library target was added to `lakefile.toml` so the chain builds in
isolation despite the repository's mixed module-naming conventions.

## Research Directions

### 1. The completion-and-residue exact sequence of the species ring
Conjecture: the short exact sequence `0 → 𝔪 → ConvSeq → ℚ → 0` (where the quotient map is the
empty-set count `a ↦ a 0`, i.e. the residue field map of the local ring) splits, and the powers
`𝔪ᵏ` are exactly the sequences vanishing to order `k` at the origin, `{a | ∀ i < k, a i = 0}`.
Concretely, `ConvSeq` is `𝔪`-adically complete and its associated graded ring is a polynomial
ring `ℚ[t]`. *The key insight is* that the binomial convolution does not move the lowest nonzero
degree (`binConv` of order-`i` and order-`j` sequences has order `i+j`), so the `𝔪`-adic filtration
is literally the EGF-degree filtration and the valuation is the *first nonempty arity* of the
species. *Why now?* `ConvSeq.instIsLocalRing` and `ConvSeq.mem_maximalIdeal_iff` already pin down
`𝔪`; the order-additivity of `binConv` is a one-coefficient computation, so the graded-ring and
completeness statements are immediately within reach and would make `ConvSeq` a discrete valuation
ring with an explicit uniformizer (the species `X` of singletons).

### 2. Local invertibility ⇒ a constructive species reciprocal
Conjecture: when `a 0 ≠ 0` the multiplicative inverse in `ConvSeq` is given by the explicit
recursion `b 0 = 1/a 0`, `b n = -(1/a 0)·∑_{i=1}^{n} C(n,i) a i b (n-i)`, and this `b` satisfies
`binConv a b = binConvOne` *definitionally per coefficient*. *The key insight is* that
`isUnit_iff` only asserts existence of an inverse abstractly (via the analytic transport), but the
recursion above is the species analogue of Newton's series inversion and is finite at every arity,
turning the local-to-global existence statement into an algorithm. *Why now?* The unit criterion
is proved; the missing piece is purely the closed-form recursion, which the `binConv` definition
over `Finset.antidiagonal` supports directly, giving a computable (`#eval`-able) reciprocal whose
correctness is a finite induction on arity.

### 3. The exponential formula as a local-ring/sheaf gluing statement
Conjecture: for a species `G` with `G 0 = 0` (no structure on the empty set — i.e. `G ∈ 𝔪`), the
"assembly of connected pieces" `E ∘ G` (set of `G`-structures on the blocks of a partition) has
EGF `exp(egf G)`, and more sharply the map `𝔪 → 1 + 𝔪`, `G ↦ E∘G`, is a group isomorphism from
the additive group of the maximal ideal to the group of *principal units* `1 + 𝔪` of `ConvSeq`.
*The key insight is* that the exponential formula is exactly the statement that `exp` carries the
maximal ideal (where it converges coefficientwise, since `G ∈ 𝔪`) bijectively onto the principal
units of the local ring — the convergence obstruction is precisely membership in `𝔪`. *Why now?*
The local-ring scaffolding identifies `𝔪` as the exact convergence domain, and `egf_binConvPow`
already supplies `egf (G^{⋆k}) = (egf G)^k`; summing `1/k!` over the `𝔪`-adically convergent tower
turns the classical exponential formula into a clean isomorphism of `𝔪` with `1 + 𝔪`.

### 4. Stalkwise detection of zero-divisors and the integral-domain property
Conjecture: `ConvSeq` is an integral domain, and more refined than the local-ring fact, the
"order" valuation `ord : ConvSeq → ℕ ∪ {∞}` (least arity with nonzero count) is multiplicative,
`ord (binConv a b) = ord a + ord b`, making `ConvSeq` a valuation ring whose value group is `ℤ`.
*The key insight is* that `ℚ⟦X⟧` is a domain because the bottom coefficients multiply without
cancellation, and this transports across `egfRingEquiv` to the *bottom arities* of species — the
"local data at the origin" again controls a global property (no zero-divisors). *Why now?*
`IsDomain ℚ⟦X⟧` is in Mathlib and `egfRingEquiv` is in hand, so `IsDomain ConvSeq` is a one-line
transport; the multiplicative-valuation refinement reuses the order-additivity of direction #1.

### 5. Many-sorted / multivariate species and a sheaf over the formal polydisk
Conjecture: `k`-sorted species (structures on `k` independently-labelled sets) form a ring
isomorphic to `ℚ⟦X₁,…,X_k⟧` via a multivariate EGF, this ring is again local with maximal ideal
the multi-augmentation `{a | a 0…0 = 0}`, and the restriction maps "set sort `i` to a point"
assemble into a genuine presheaf on the face lattice of the formal polydisk whose global sections
are the multivariate counting sequences. *The key insight is* that the single-variable
local-to-global theorem is the closed-point fiber of a multivariate sheaf, and the gluing of
single-sort stalks recovers the multi-sort species exactly because EGF multiplication is
sort-wise. *Why now?* Mathlib's `MvPowerSeries` carries the local-ring and domain instances over a
field, so the entire single-variable file ports almost verbatim; this is the concrete sheaf /
local-to-global object the engine's mandate asks for, with the present file as its rank-one stalk.
