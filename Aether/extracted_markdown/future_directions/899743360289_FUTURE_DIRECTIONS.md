# Future Directions — The Higher Calculus of Species: Stirling Bridge, Higher Leibniz, and the Newton/Maclaurin Duality

## Synthesis

Before this cycle the species program had assembled the exponential-generating-function (EGF)
dictionary for the *monoidal* structure (`egf_add`, `egf_mul`/`egf_card_prodSpecies`), the
*first-order differential* structure (`egf_derivative`, `EGF_derivativeSpecies`,
`EGF_pointedSpecies`), the convolution **ring** of counting sequences (`binConv_assoc`,
`binConv_leibniz`, `egf_binConvPow`, `ConvSeq.egfRingEquiv`), the **bijectivity** of `egf`
(`egf_injective`, `egf_surjective`, `seqOf`), the **Taylor tower** of higher derivatives
(`egf_seqDeriv_iterate`, `coeffSeq_iterate_derivative`, `EGF_iterate_derivative`,
`species_maclaurin`), and its **inverse** together with the *moment* and *higher-product* towers
(`taylor_reconstruction`, `coeffSeq_iterate_pointed`, `EGF_iterate_pointed`,
`derivativeFun_iterate_mul`).

This cycle (`Catalog/Speculative/AutoResearch/SpeciesHigherCalculus.lean`) closes three of the
five open directions left by the previous note, turning each from conjecture into theorem:

* **The Stirling change of basis** between the moment tower (`n^k` weighting) and the
  falling-factorial tower. The keystone is a purely number-theoretic identity that appears to be
  absent from Mathlib, `n^k = Σ_{j≤k} S(k,j)·(n)_j` (`Nat.pow_eq_sum_stirlingSecond_descFactorial`),
  whose species shadow `coeffSeq_iterate_pointed_stirling` rewrites iterated pointing
  `(F^{•k})[n]` in the falling-factorial basis.
* **The higher (binomial) Leibniz rule descended to species** — the analytic
  `derivativeFun_iterate_mul` is transported through the injective EGF bridge to the combinatorial
  identity `seqDeriv^[k](binConv a b) = Σ_{i≤k} C(k,i)·binConv(seqDeriv^[i] a)(seqDeriv^[k-i] b)`
  (`seqDeriv_iterate_binConv`), with no antidiagonal bookkeeping.
* **The Newton/Maclaurin duality** — where `taylor_reconstruction` inverts `egf` through the
  *shift* tower, the *forward-difference* tower `Δ = shift − id` reconstructs a sequence by
  binomial interpolation, `a n = Σ_{k≤n} C(n,k)·(Δ^[k] a) 0` (`newton_reconstruction`), and its
  EGF shadow `egf_fwdDiff` identifies `Δ` with `derivativeFun − id`.

## Results Summary

Five new theorems (plus four supporting lemmas: `mul_descFactorial_eq`, `seqDeriv_iterate`,
`egf_smul`, `egf_sum`), zero `sorry` on every result, all depending only on the standard axioms
`propext, Classical.choice, Quot.sound`. As a side effect, the pre-existing duplicate-declaration
build error in `Catalog/Applications/SpeciesAnalyticBridge.lean` (`egf_injective` re-declared) was
repaired, and a `lean_lib` entry covering the `Catalog.` module prefix was added to
`lakefile.toml`, so the whole species stack compiles. The moment tower is now known in the
falling-factorial basis (Stirling), the higher product rule is established at sequence level, and
the two finite-difference operators (shift and forward difference) are both inverted, exhibiting
Maclaurin and Newton as the two faces of the same algebraic inversion of `egf`.

## Research Directions

### 1. The operator-level Stirling identity `(X·d/dX)^[k] = Σ_j S(k,j)·X^j·(d/dX)^[j]` on `ℚ⟦X⟧`

`coeffSeq_iterate_pointed_stirling` establishes the Stirling change of basis at the level of
*counting sequences*; the matching statement at the level of *operators on power series* is still
open. The falsifiable target is the operator identity
`(fun s => X * derivativeFun s)^[k] = Σ_{j≤k} S(k,j) • (fun s => X^j * derivativeFun^[j] s)`,
equivalently `(F^{•k}).EGF = Σ_j S(k,j)·X^j·(F.EGF)^{(j)}` via `EGF_iterate_pointed`. **The key
insight is** that the Euler operator `θ = X·d/dX` and the bare derivative `d/dX` are the two lifts
of differentiation to species, and the Stirling numbers are precisely the entries of the
change-of-basis matrix between the moment monomials `θ^k` and the falling-factorial monomials
`X^j (d/dX)^j`; the coefficientwise content is exactly the now-proved
`Nat.pow_eq_sum_stirlingSecond_descFactorial` read through `coeff n`. **Why now?** Both towers are
formalized as `Function.iterate` of named operators with proven EGF shadows (`EGF_iterate_pointed`,
`EGF_iterate_derivative`), the scalar identity is proved, and `egf_injective` lets the operator
identity be checked one coefficient at a time, so only the Pascal-style recurrence step
`θ·(X^j (d/dX)^j) = X^{j+1}(d/dX)^{j+1} + j·X^j(d/dX)^j` remains.

### 2. Binomial inversion: the Newton and Maclaurin towers are mutually inverse transforms

`newton_reconstruction` writes `a n = Σ_{k≤n} C(n,k)·(Δ^[k] a) 0`, and the forward differences
themselves expand as `(Δ^[k] a) 0 = Σ_{j≤k} (-1)^{k-j} C(k,j)·a j` (Mathlib's
`fwdDiff_iter_eq_sum_shift`). Composing the two should give the **binomial inversion theorem**:
the lower-triangular matrices `C(n,k)` and `(-1)^{n-k}C(n,k)` are mutually inverse, i.e. the map
`a ↦ (n ↦ (Δ^[n] a) 0)` and the map `b ↦ (n ↦ Σ_{k≤n} C(n,k) b k)` are inverse bijections of
`ℕ → ℚ`. **The key insight is** that the forward-difference tower at the origin is the *finite,
exact* discrete analogue of the Maclaurin tower `coeff₀ ∘ derivativeFun^[·]` already inverted by
`taylor_reconstruction`; both are unitriangular change-of-basis maps on `ℕ → ℚ`, so each is
invertible with explicit inverse, and the species derivative (shift) versus forward difference
`Δ = shift − id` are conjugate by exactly the binomial transform. **Why now?**
`newton_reconstruction`, `egf_fwdDiff`, and `taylor_reconstruction` are all in place,
`fwdDiff_iter_eq_sum_shift` supplies the explicit Δ-expansion, and `Nat.add_pow`/`Int.alternating`
binomial sums give the cancellation, so the direction is a single signed-binomial double-sum
identity with both directions already half-built.

### 3. The exponential formula `EGF(E ∘ G) = exp(EGF G)` via the higher Leibniz rule

Composition (substitution / plethysm) `F ∘ G` is the last major species operation absent from the
dictionary; its flagship instance is the exponential formula: assembling a set of `G`-structures
over a partition of the labels has EGF `exp(EGF G)` whenever `G` carries no structure on the empty
set (`G.coeffSeq 0 = 0`). The falsifiable target is `(setSpecies.comp G).EGF = (exp ℚ) ∘ G.EGF`.
**The key insight is** that with `seqDeriv_iterate_binConv` (the higher product rule) and
`egf_binConvPow` (`exp = Σ a^{⋆k}/k!`) both proved, the partition-indexed composition count is
governed coefficientwise by the Bell expansion `B_n = Σ_k S(n,k)`, and the Stirling identity from
this cycle is exactly the bridge between the moment data and the set-partition data that the Bell
numbers package. **Why now?** `EGF_setSpecies` pins the `E ↔ exp` half, `egf_binConvPow` gives the
convolution-power generating identity, `card_prodSpecies` is the proof template, and
`Nat.stirlingSecond` with the new `pow_eq_sum_stirlingSecond_descFactorial` provide the
partition-counting backbone; the only genuinely new lemma is `card_compSpecies`, a cardinality
count over set partitions structurally analogous to the proved product count.

### 4. The combinatorial higher Leibniz rule promoted to the `ConvSeq` ring and to species isos

`seqDeriv_iterate_binConv` lives at the level of bare sequences; it should lift to the convolution
**ring** `ConvSeq` (with `*` = `binConv`) and, through `Species.Iso`, to an actual natural
isomorphism of structure functors `(F·G)^{(k)} ≅ Σ_{i+j=k} C(k,i)·F^{(i)}·G^{(j)}`. The
falsifiable target is the `ConvSeq`-internal identity `D^[k](x*y) = Σ_{i≤k} C(k,i)•(D^[i] x)*(D^[k-i] y)`
where `D` is the ring endomorphism induced by `seqDeriv`, together with the species-level iso whose
cardinality shadow is `seqDeriv_iterate_binConv`. **The key insight is** that `seqDeriv` is a
*derivation-like* shift on the `binConv` ring, so the higher Leibniz rule is the statement that its
`k`-fold iterate is governed by the binomial coproduct — a Hopf-algebraic fact whose enumerative
content is already proved, so promoting it is pure transport across `ConvSeq.egfRingEquiv`. **Why
now?** `ConvSeq.egfRingEquiv` is a proved ring isomorphism, `seqDeriv_iterate_binConv` is the
sequence-level theorem, and `Species.derivative`/`Species.Iso` give the functorial target, so the
ring version is one `RingEquiv` transport and the iso version reduces to a single cardinality
match.

### 5. Homotopy invariance of the moment and product towers

`Catalog/Applications/SpeciesHomotopyCardinality.lean` shows the EGF is a groupoid-cardinality
invariant; the new moment tower (`coeffSeq_iterate_pointed_stirling`) and product tower
(`seqDeriv_iterate_binConv`) should respect that invariance. The falsifiable target is the package
`Species.Iso F G → Species.Iso (Species.pointed^[k] F) (Species.pointed^[k] G)` and
`Species.Iso F₁ G₁ → Species.Iso F₂ G₂ → Species.Iso ((F₁·F₂)-derivative-tower) (...)`, each reduced
to its `k=1` step by the iterate lemmas. **The key insight is** that `Species.pointed` is built from
`Equiv.prodCongr` and the product from Day convolution, both equivariant lifts, so each descends to
the localization inverting relabelling equivalences — the entire higher calculus is a functor on
the *homotopy category* of species, not merely the skeletal one. **Why now?** The `act` field and
the homotopy-cardinality theorem are in place, the new `coeffSeq_iterate_pointed_stirling`
expresses each moment-tower entry through invariant data (Stirling numbers times counts), and the
single-step iso-preservation lemmas are the only missing ingredient to make the whole tower
homotopy-invariant.
