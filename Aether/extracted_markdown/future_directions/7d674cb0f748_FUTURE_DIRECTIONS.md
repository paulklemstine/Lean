# Future Directions: The Hodge Filtration ↔ Bigrading Duality

## Synthesis

This cycle formalized the **filtration/decomposition duality** at the heart of pure
Hodge theory, in the weight-two case. A pure Hodge structure speaks two dual
languages: the *bigrading* `V_ℂ = H²⁰ ⊕ H¹¹ ⊕ H⁰²` and the decreasing *Hodge
filtration* `F² ⊆ F¹ ⊆ F⁰ = V_ℂ`. The new file
`Catalog/Geometry/HodgeTheory/Filtration.lean` introduces
`HodgeStructureWeightTwoConj`, which extends the catalog's
`HodgeStructureWeightTwo` (`Catalog/Geometry/HodgeTheory/Defs.lean`) by promoting
its *pairwise*-independence to a genuine internal direct sum and equipping the
complexification with complex conjugation. On this object we proved:

* `F_antitone` — `F•` is a genuine decreasing filtration.
* `conj_H02`, `conjF1_eq`, `conjF2_eq` — conjugation acts on the pieces and the
  filtration steps by Hodge symmetry `H^{p,q} = conj H^{q,p}`.
* `opposition` — the *opposition relations* `Fᵖ ⊕ conj F^{k-p+1} = V_ℂ`, i.e. `F²`
  is complementary to `conj F¹` and `F¹` to `conj F²`.
* `recover_H11` — the reconstruction identity `H¹¹ = F¹ ∩ conj F¹`, the case
  `p = q = 1` of `H^{p,q} = Fᵖ ∩ conj F^q`.
* `filtration_determines_decomposition` — **the Hodge filtration together with
  conjugation is a complete invariant**: equal conjugations and equal filtrations
  force equal bigradings.
* `nonempty_of_trivial` — the theory is inhabited, so these results are not vacuous.

## Results Summary

The decisive *Insight* (logged in the Lab Notebook) is that reconstruction genuinely
requires the internal-direct-sum hypothesis, not merely the pairwise-trivial
intersection that the catalog object recorded: three lines in a plane meet pairwise
trivially yet are not independent. With the direct-sum hypothesis in place,
reconstruction of the middle piece collapses to a single application of the modular
law in the submodule lattice — a clean illustration of how a representation-theoretic
"complete invariant" statement reduces to lattice theory once the conjugation pairing
is available. All theorems depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. General-weight Hodge filtration and opposition

Generalize from weight two to an arbitrary weight `k` Hodge structure given by a
family `H : ℤ → Submodule ℂ V_ℂ` supported on `p + q = k`, with `Fᵖ = ⊕_{i ≥ p} H^{i,k-i}`.
Prove the full opposition theorem `Fᵖ ⊕ conj F^{k-p+1} = V_ℂ` and the general
reconstruction `H^{p,q} = Fᵖ ∩ conj F^q` for all `p + q = k`.
**The key insight is** that the weight-two modular-lattice computation
(`recover_H11`) is the base case of a telescoping induction on the filtration length,
where each step peels off one graded piece via `sup_inf_assoc_of_le`.
**Why now?** The weight-two proof is complete and isolates exactly the lattice lemma
and conjugation interface that the induction needs; only the bookkeeping over `ℤ`-indexed
families remains, for which Mathlib's `DirectSum.IsInternal` and `iSupIndep` are ready.

### 2. Construct genuine complex conjugation on `ℂ ⊗[ℚ] V`

Replace the conjugation supplied as structure *data* by the canonical conjugate-linear
involution `starRingEnd ℂ ⊗ id` on the complexification, as a bona fide
`(ℂ ⊗[ℚ] V) ≃ₛₗ[starRingEnd ℂ] (ℂ ⊗[ℚ] V)`, and show every rational Hodge structure
(in the sense of `Defs.lean`) satisfying Hodge symmetry yields a
`HodgeStructureWeightTwoConj` with *this* conjugation.
**The key insight is** that conjugation is forced by the rational lattice `V ⊆ V_ℂ`:
it is the unique semilinear involution fixing `1 ⊗ V` pointwise, so it need not be
carried as data at all.
**Why now?** Mathlib has `TensorProduct.congr`, `LinearMap.baseChange`, and
`Algebra.TensorProduct` machinery; the missing piece is a small `semilinear` tensor
constructor, which is self-contained and testable in isolation.

### 3. The opposition condition characterizes pure Hodge structures (E₁-degeneration shadow)

Prove the converse direction: given *any* decreasing filtration `F•` on `V_ℂ` and a
conjugation `c` such that `Fᵖ ⊕ c(F^{k-p+1}) = V_ℂ` for all `p` ("`F` is `k`-opposed
to its conjugate"), the subspaces `H^{p,q} := Fᵖ ∩ c(F^q)` form a weight-`k` Hodge
structure. This is the exact linear-algebraic content of the Hodge-to-de Rham
spectral sequence degenerating at `E₁`.
**The key insight is** that opposition is an *equivalence* between filtered+conjugated
data and bigraded data; this cycle proved one direction (`filtration ⇒` invariant), and
the converse is a finite intersection/sum bookkeeping over the opposition splittings.
**Why now?** `opposition` and `recover_H11` already give the forward maps and the
reconstruction formula; the converse reuses `IsCompl` API (`IsCompl.sup_eq_top`,
`Submodule.exists_unique` decompositions) with no new infrastructure.

### 4. Künneth/tensor product of conjugated Hodge structures

Define the tensor product `HodgeStructureWeightTwoConj V × HodgeStructureWeightTwoConj W
→` a weight-four structure on `V ⊗ W`, with bigrading
`(H ⊗ H)^{p,q} = ⊕_{a+c=p, b+d=q} H^{a,b}(V) ⊗ H^{c,d}(W)` and the product conjugation
`conj ⊗ conj`, and prove the resulting filtration is the *convolution*
`Fⁿ(V ⊗ W) = Σ_{i+j=n} Fⁱ(V) ⊗ Fʲ(W)`.
**The key insight is** that opposition is multiplicative: the tensor of two opposed
filtrations is opposed, so the complete-invariant theorem upgrades to a statement that
the Künneth filtration determines the product decomposition.
**Why now?** The complete-invariant theorem of this cycle is exactly the hypothesis a
multiplicativity proof needs on each factor, and Mathlib's `TensorProduct` distributes
over `⊔`/`⊓` enough to make the convolution identity a `Finset.sum` manipulation.

### 5. Polarization, the Weil operator, and Hodge–Riemann positivity

Reintroduce the catalog's `PolarizedHodgeStructure` form `Q` and define the **Weil
operator** `W` acting as the scalar `i^{p-q}` on `H^{p,q}` (so `+1` on `H¹¹`, `-1` on
`H²⁰ ⊕ H⁰²` in the real form). Prove that `(x, y) ↦ Q(x, conj W y)` is a Hermitian form
and that opposition implies its restriction to `H¹¹` has the expected signature
(Hodge–Riemann bilinear relations, weight-two case).
**The key insight is** that the Weil operator is *definable from the filtration alone*
via the opposition projections constructed in `opposition`, so positivity becomes a
sign computation on the recovered pieces rather than a geometric input.
**Why now?** `opposition` already exhibits the complementary splittings whose
projections define `W`, and Mathlib's `LinearMap.BilinForm`, `IsSymm`, and signature
API (`Submodule.finrank_sup_add_finrank_inf_eq`) close the loop with the catalog's
`SignedBilinearForm`/`hodge_index_signature_bound` results in `StandardConjectures.lean`.
