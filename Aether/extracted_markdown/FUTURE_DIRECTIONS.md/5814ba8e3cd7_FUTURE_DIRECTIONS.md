# Future Directions — Hadamard Matrix Theory (Paley / Sylvester cycle)

## Synthesis

This cycle attacked the Paley/Hadamard research direction by splitting it into its two
structurally independent engines and formalizing each completely on top of the catalog's
existing `IsHadamard` / `HadamardOrder` definitions (`Algebra/Hadamard/Basic.lean`).

The **multiplicative engine** (`Sylvester.lean`) shows that Hadamard orders are closed under
multiplication via the Kronecker product: `kron_isHadamard` proves `(A ⊗ₖ B)` reindexed by
`finProdFinEquiv` is Hadamard whenever `A` and `B` are. The decisive structural insight was to
prove orthogonality on the *product index type* `Fin m × Fin n` using one line of Kronecker
bilinearity (`mul_kronecker_mul`, `one_kronecker_one`), and only then transport the equation to
`Fin (m*n)` with `submatrix_mul_equiv`. A direct entrywise computation over `Fin (m*n)` drowns in
`finProdFinEquiv` index arithmetic; abstracting to the product type sidesteps it entirely. This
immediately yields the unconditional infinite Sylvester family `hadamardOrder_two_pow`.

The **number-theoretic engine** (`Paley.lean`) formalizes the two facts that make Paley's
construction work. `quadraticChar_neg_one_three_mod_four` is the skew property `χ(-1) = -1` for
`p ≡ 3 (mod 4)` (reduced to `χ₄`), and `quadraticChar_shift_autocorrelation` is the autocorrelation
identity `∑_c χ(c)·χ(c+a) = -1` for `a ≠ 0`. The latter is the heart of the file: it is *not* in
Mathlib, and the working proof came from the multiplicative reindexing `c ↦ 1 + a/c`, a bijection
`F\{0} → F\{1}`, after which the sum collapses to `(∑ χ) − χ(1) = 0 − 1`. A completing-the-square
substitution (`χ(c²+ac)`) was tried first and abandoned — it leaves `χ(u²−b²)` with no closed form.
These combine into the Jacobsthal Gram relations `jacobsthal_diag` (= `p−1`) and
`jacobsthal_offdiag` (= `−1`), i.e. `Q Qᵀ = p·I − J`, the exact combinatorial certificate a bordered
Paley matrix needs.

What remains open is the *assembly*: bordering the `(p+1)×(p+1)` Paley type-I matrix and proving it
satisfies `IsHadamard`. Both engines are now in place; the gap is purely the block-matrix bookkeeping
connecting `Q Qᵀ = p·I − J` plus skew-symmetry to `H Hᵀ = (p+1)·I`.

## Results Summary

- `HadamardSylvester.kron_isHadamard`: proved — the Kronecker product of two Hadamard matrices is Hadamard.
- `HadamardSylvester.hadamardOrder_mul`: proved — Hadamard orders are closed under multiplication.
- `HadamardSylvester.hadamardOrder_two_pow`: proved — every power of two is a Hadamard order (Sylvester family).
- `HadamardPaley.quadraticChar_neg_one_three_mod_four`: proved — `χ(-1) = -1` for `p ≡ 3 (mod 4)` (skew property).
- `HadamardPaley.quadraticChar_shift_autocorrelation`: proved — `∑_c χ(c)·χ(c+a) = -1` for `a ≠ 0` (not in Mathlib).
- `HadamardPaley.jacobsthal_diag`: proved — each Jacobsthal row self-correlates to `p-1`.
- `HadamardPaley.jacobsthal_offdiag`: proved — distinct Jacobsthal rows correlate to `-1`.

## Research Directions

### Direction 1: Assemble the bordered Paley type-I Hadamard matrix
**Hypothesis**: For prime `p ≡ 3 (mod 4)`, the bordered matrix `H` of order `p+1` with a border row/column
of `1`s and interior `I + Q` (`Q` the Jacobsthal matrix) satisfies `IsHadamard H`, hence `HadamardOrder (p+1)`.
**Test**: Build `H : Matrix (Option (ZMod p)) (Option (ZMod p)) ℤ` (or `Fin (p+1)`), and prove `H Hᵀ = (p+1)•I`
by case-splitting border/interior blocks, feeding `jacobsthal_diag`, `jacobsthal_offdiag`, and skew-symmetry
`Qᵀ = -Q` (from `quadraticChar_neg_one_three_mod_four`).
**Why now**: The Gram relations `Q Qᵀ = p·I − J` and the skew property are both proved this cycle; only the
block bookkeeping remains.
**If true**: Closes the original Paley conjecture for type I and, combined with `hadamardOrder_mul`, yields
Hadamard orders `2^k·(p+1)`.
**If false**: A failure would localize a missing identity (most likely `Q·J = 0` / row-sum of `Q` is `0`),
pinpointing the exact lemma the construction depends on.

### Direction 2: Skew-symmetry of the Jacobsthal matrix
**Hypothesis**: For `p ≡ 3 (mod 4)`, `jacobsthal p` is skew-symmetric: `(jacobsthal p)ᵀ = -(jacobsthal p)`.
**Test**: Prove `χ(i - j) = -χ(j - i)` from `χ(i-j) = χ(-(j-i)) = χ(-1)·χ(j-i) = -χ(j-i)` using
`quadraticChar_neg_one_three_mod_four` and `map_mul`.
**Why now**: The single missing input is `χ(-1) = -1`, already proved as `quadraticChar_neg_one_three_mod_four`.
**If true**: Supplies the skew block identity needed by Direction 1 and characterizes Paley type-I vs type-II.
**If false**: Would contradict the proven skew value, so a failure signals an indexing/sign convention bug rather
than a mathematical one — a useful guardrail.

### Direction 3: Row-sum of the Jacobsthal matrix vanishes
**Hypothesis**: For odd prime `p`, every row of `jacobsthal p` sums to `0`: `∑ j, χ(j - i) = 0`.
**Test**: Reindex by `Equiv.subRight i` to `∑ c, χ(c)` and apply `quadraticChar_sum_zero`.
**Why now**: `quadraticChar_sum_zero` is in Mathlib and the `Equiv.subRight` reindex pattern already worked in
`jacobsthal_diag`/`jacobsthal_offdiag` this cycle.
**If true**: Gives `Q·J = 0`, the last algebraic fact the border computation in Direction 1 needs.
**If false**: Impossible for the quadratic character; a failure would expose a `Fintype`/`DecidableEq` instance
mismatch in `ZMod p` sums.

### Direction 4: Generalize the autocorrelation to arbitrary prime powers
**Hypothesis**: `quadraticChar_shift_autocorrelation` holds verbatim for every finite field `𝔽_q` of odd
characteristic, so the Paley engine extends from primes `p` to all prime powers `q ≡ 3 (mod 4)`.
**Test**: The theorem is already stated for a general `[Field F] [Fintype F] [DecidableEq F]` with
`ringChar F ≠ 2`; redefine `jacobsthal` over `GaloisField p n` (or any such `F`) and re-derive the Gram
relations, replacing `ZMod.card`/`ZMod.ringChar_zmod_n` with `FiniteField.card`.
**Why now**: The deep identity was *deliberately* proved field-generically this cycle, not just for `ZMod p`;
only the matrix wrapper is `ZMod`-specific.
**If true**: Upgrades all downstream Hadamard existence results from primes to prime powers — the full strength
of Paley's theorem.
**If false**: Would reveal a hidden dependence on `ZMod p` (e.g. cyclicity of the additive group) that the
general finite field lacks.

### Direction 5: Quantitative Hadamard order density from the two engines
**Hypothesis**: Combining `hadamardOrder_mul`, `hadamardOrder_two_pow`, and Direction 1, the set
`{ n : HadamardOrder n }` contains `2^k·(p+1)` for all `k` and all primes `p ≡ 3 (mod 4)`, giving an
explicit infinite, multiplicatively-closed sub-monoid of Hadamard orders.
**Test**: Formalize the closure set as a `Submonoid ℕ` (under multiplication) generated by `2` and the Paley
orders, and prove membership lemmas; optionally bound the smallest non-member.
**Why now**: Multiplicative closure (`hadamardOrder_mul`) is proved and the base generators are within reach
(Sylvester proved, Paley one assembly step away).
**If true**: Turns scattered existence facts into a structural statement about the multiplicative monoid of
Hadamard orders — a cleaner object for the next cycle to study (e.g. its complement, density, the Hadamard
conjecture `4 | n ⇒ HadamardOrder n`).
**If false**: A counterexample to closure would contradict `hadamardOrder_mul`, so failure can only come from
a wrong generator — isolating which Paley order is unprovable.
