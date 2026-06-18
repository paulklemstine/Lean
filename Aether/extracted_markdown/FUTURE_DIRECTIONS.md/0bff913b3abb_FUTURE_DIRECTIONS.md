# Future Directions — Intersection Form Classification Pipeline via Self-Dual Code Direct Sum

This cycle established the **direct-sum functoriality** shared by integer
intersection forms and binary self-dual codes, formalized in
`Catalog/Logic/IntersectionFormSelfDual.lean` (10 main theorems, 0 sorries):

- Forms: symmetry, determinant multiplicativity, unimodularity, even type, and
  trace are all preserved/additive under the block-diagonal direct sum.
- Codes: the Gram law `G Gᵀ = 0`, self-orthogonality, linear independence of
  generating rows, and the full self-dual property are preserved under direct
  sum; self-dual codes have even length.

The conjectures below are concrete, falsifiable targets for follow-up cycles.

## C1. Signature is additive (Sylvester / inertia bridge)
Define the signature `σ(M)` of a symmetric integer (or real) form via its
positive/negative inertia indices. **Conjecture:** `σ(directSumForm A B) = σ(A) + σ(B)`
and `rank(directSumForm A B) = rank A + rank B`, giving a genuine monoid
homomorphism `(form, ⊕) → (ℤ × ℕ, +)`. The crux is formalizing Sylvester's law
of inertia for `Matrix.IsHermitian` eigenvalues; once available, additivity
should follow from the block-diagonal eigenvalue decomposition.

## C2. The "even ⇒ 8 | signature" obstruction
**Conjecture (van der Blij / Milnor–Husemoller):** for an *even* unimodular
symmetric integer form `M`, the signature satisfies `σ(M) ≡ 0 (mod 8)`. This is
the lattice-theoretic shadow of the famous fact that a binary *doubly-even*
self-dual code has length divisible by 8. A first formal milestone: prove the
length-divisible-by-8 statement for doubly-even self-dual binary codes
(`∀ c ∈ C, 4 ∣ weight c` and `C = C⊥` ⇒ `8 ∣ #ι`).

## C3. Construction A is a functor
Make the code → lattice bridge explicit: for a binary code `C ⊆ 𝔽₂ⁿ`, define
`Λ_C = { x ∈ ℤⁿ : (x mod 2) ∈ C } / √2` with its Gram form. **Conjecture:**
`Λ_{C₁ ⊕ C₂} ≅ Λ_{C₁} ⊕ Λ_{C₂}` (direct sums commute with Construction A), and
`C` self-dual ⇔ `Λ_C` unimodular, `C` doubly-even ⇔ `Λ_C` even. This upgrades the
"parallel bookkeeping" of this cycle to an actual natural isomorphism.

## C4. Indecomposability and unique factorization under ⊕
**Conjecture:** every binary self-dual code (resp. unimodular form) factors as a
direct sum of indecomposable pieces, and — restricting to the *definite* /
positive-rank-only regime — this factorization is unique up to permutation
(Krull–Schmidt for the direct-sum monoid). Falsifiable subgoal: exhibit and
formally verify the smallest indecomposable self-dual codes (the `[2,1]` code
`i₂` and the `[8,4]` Hamming code `e₈`) and prove `i₂` is indecomposable.

## C5. Rank–determinant rigidity of the direct-sum monoid
**Conjecture:** the map `M ↦ (rank M, M.det, isEven M)` is a complete invariant
for *indefinite* unimodular forms (Milnor–Husemoller classification), i.e. two
indefinite unimodular forms with equal rank, equal `det = ±1` sign pattern, and
equal type are isomorphic. A formal route: build the standard generators
`⟨1⟩, ⟨-1⟩, H` (hyperbolic) and `E₈`, show every indefinite unimodular form is a
direct sum of these, then read off the invariants proved additive in this cycle.
