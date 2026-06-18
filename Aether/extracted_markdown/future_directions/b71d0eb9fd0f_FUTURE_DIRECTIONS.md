# Future Directions — Direct-Sum Functoriality of Intersection Forms & Self-Dual Codes

This cycle formalized (0 sorries) the **direct-sum functoriality** shared by
integer intersection forms and binary linear codes, and proved the first rungs of
the "even ⇒ obstruction" ladder on both sides:

- `Logic/IntersectionFormSelfDual.lean` — under the block-diagonal direct sum
  `directSumForm A B = fromBlocks A 0 0 B`: symmetry, determinant
  multiplicativity, trace additivity, unimodularity, and the even type are all
  preserved/additive; on the code side the Gram law `G Gᵀ = 0`
  (self-orthogonality) is preserved; and any subspace equal to its own
  orthogonal complement under a nondegenerate reflexive form forces **even
  ambient dimension** (`selfDual_even_dim`).
- `Logic/EvenUnimodularObstruction.lean` — every even, symmetric, unimodular
  `2×2` integer form has determinant exactly `-1` (`even_unimodular_two_det`);
  its off-diagonal entry is odd; the hyperbolic plane `H` realizes the bound and
  `H ⊕ H` is even unimodular with `det = +1`.
- `Logic/SelfOrthogonalWeight.lean` — the diagonal of `G Gᵀ` computes Hamming
  weight mod 2, so self-orthogonal codes have **even-weight generators**
  (`gramLaw_row_even_weight`), with the contrapositive and the `[2,1]` code `i₂`
  as witness.

The conjectures below are concrete, falsifiable targets for the next cycle.

## D1. The weight-divisibility ladder `2 ∣ → 4 ∣ → 8 ∣`
**Conjecture.** A *doubly-even* self-dual binary code (`∀ c ∈ C, 4 ∣ wt c` and
`C = C⊥`) has length divisible by `8`; and the intermediate rung holds:
self-dual ⇒ every codeword has weight `≡ 0 (mod 2)`, while self-dual *and*
containing the all-ones vector pushes a `4 ∣` constraint on a distinguished
sublattice of codewords.

**The key insight is** that the squaring map is the identity on `ZMod 2`, so the
quadratic Gram condition `G Gᵀ = 0` collapses to the *linear* parity functional
`∑ⱼ Gᵢⱼ`; the proved `gramLaw_row_even_weight` is exactly the `2 ∣ wt` rung, and
the next rungs should come from the *quartic* refinement `wt(x+y) = wt x + wt y -
2·|x∩y|` controlling `4 ∣` once `2 ∣` is known coordinatewise.

**Why now?** `sum_eq_weight_mod_two` already packages the weight-as-functional
bridge, so the only missing ingredient is the bilinear `|x∩y|` correction term —
a finite, fully formalizable combinatorial identity rather than new analysis.

## D2. Even unimodular ⇒ `8 ∣ signature` (van der Blij), bootstrapped from rank 2
**Conjecture.** For every even, symmetric, unimodular integer form `M`, the
signature `σ(M) ≡ 0 (mod 8)`; the rank-2 case proved here (`det = -1`, hence
`σ = 0`) is the base of an induction that peels off hyperbolic planes `H` and a
single `E₈` block.

**The key insight is** that `even_unimodular_two_det` is a *mod-4* obstruction
(`4·k = 1` is unsolvable), and the genuine theorem is its *mod-8* amplification;
the proof technique — write the even diagonal as `2a, 2c`, split the off-diagonal
on parity, and surface the literal factor for `omega` — should re-run on the
quadratic form `x ↦ xᵀ M x mod 8` once a Gauss-sum/Milgram input is in place.

**Why now?** The direct-sum additivity of `det`, `trace`, and the even type is
already proved, so the inductive step "remove an `H` summand and reduce rank by 2"
has its bookkeeping lemmas in hand; only the `E₈` exceptional block remains to be
built and shown even unimodular.

## D3. Signature and rank are additive: a monoid homomorphism `(forms, ⊕) → ℤ × ℕ`
**Conjecture.** `σ(directSumForm A B) = σ(A) + σ(B)` and
`rank(directSumForm A B) = rank A + rank B`, upgrading the proved trace/det
multiplicativity to a full invariant homomorphism into `(ℤ, +) × (ℕ, +)`.

**The key insight is** that the spectrum of a block-diagonal matrix is the
*multiset union* of the block spectra, so the positive/negative inertia indices
simply add; the proved `directSumForm_trace` is the `∑ eigenvalues` shadow of the
much finer `#positive − #negative` statement.

**Why now?** Mathlib already has `Matrix.IsHermitian.eigenvalues` and
`BilinForm.finrank_add_finrank_orthogonal` (used here for `selfDual_even_dim`);
the eigenvalue-multiset-of-a-block-matrix lemma is the single missing link, and
it is a clean linear-algebra fact, not a deep theorem.

## D4. `i₂` is indecomposable and Krull–Schmidt holds for definite codes
**Conjecture.** The `[2,1]` code `i₂` is indecomposable under `⊕`, every binary
self-dual code factors into indecomposables, and (in the definite regime) the
factorization is unique up to permutation.

**The key insight is** that decomposability is a *coordinate-partition* property:
`C` splits iff swapping the `S`-part of one codeword with the `T`-part of another
stays in `C`; for `i₂ = {00, 11}` the swap `(0,1) ∉ C`, a finite check that
generalizes to "a codeword of full support obstructs every nontrivial split".

**Why now?** With `i2_gramLaw` and `gramLaw_directSum` already in place, the
direct-sum monoid of codes is fully formal; indecomposability needs only the
finite swap-closure predicate, after which Krull–Schmidt becomes an induction on
length using the proved `selfDual_even_dim` length parity.

## D5. Construction A as a functor `Codes → Lattices`
**Conjecture.** The map `C ↦ Λ_C = {x ∈ ℤⁿ : x mod 2 ∈ C}/√2` satisfies
`Λ_{C₁ ⊕ C₂} ≅ Λ_{C₁} ⊕ Λ_{C₂}`, with `C` self-dual ⇔ `Λ_C` unimodular and `C`
doubly-even ⇔ `Λ_C` even — turning this cycle's *parallel* code/form bookkeeping
into a single natural isomorphism.

**The key insight is** that the block-diagonal structure is preserved on the
nose: `directSumForm` (forms) and `fromBlocks` (codes) are the *same* operation
in two categories, so a functor intertwining them is forced to send `⊕` to `⊕`,
and the proved preservation of det/even type/Gram law are precisely the
component equalities the functor must respect.

**Why now?** Every invariant the functor must preserve (determinant ↔ unimodular,
even diagonal ↔ even lattice, Gram law ↔ self-orthogonality) is now a proved
direct-sum-compatible lemma, so only the `/√2` rescaling and the integrality of
the Gram form remain to be formalized.
