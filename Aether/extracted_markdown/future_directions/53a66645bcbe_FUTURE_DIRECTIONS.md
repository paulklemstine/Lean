# Future Directions — Conference Matrices and the Paley Construction (Lean 4)

## Synthesis

This cycle closed the central open gap left by the previous Paley development: the
**Paley II doubling theorem**. The earlier `Algebra/Hadamard/Paley.lean` had fully
formalized the *skew* (Paley I) construction — a skew conference matrix `C` of order `n`
gives a skew-Hadamard matrix `I + C` of the same order `n` — but recorded the *symmetric*
case only as a `sorry`-ed conjecture. We replaced that conjecture with a complete proof:
a symmetric conference matrix `S` of order `n` produces a Hadamard matrix of order `2n` via
the block array `[[S+I, S-I], [S-I, -(S+I)]]`. The proof factors cleanly into three reusable
pieces — entries are `±1` (`paleyTwoBlock_entries`), the block matrix is "self-orthogonal"
`B Bᵀ = 2n·I` (`paleyTwoBlock_mul_transpose`), and an abstract transport lemma
(`hadamardOrderP_of_sum_block`) that carries a Hadamard structure across the equivalence
`Fin n ⊕ Fin n ≃ Fin (2n)`. The structural insight is that the entire symmetric construction
reduces to a single algebraic fact, `S² = (n-1)·I`, after which the off-diagonal blocks cancel
by the commutativity of `S` with the identity and the diagonal blocks sum to `2n·I`.

The new file `Algebra/Hadamard/Conference.lean` then supplies the connective tissue between
the two construction theorems and the rest of the catalog. Its highlight is a genuine
**cross-domain bridge**: a skew conference matrix of order `n > 2` forces `4 ∣ n`, obtained by
feeding the Paley I output `I + C` (a real Hadamard matrix) into the catalog's row-triple
counting obstruction `four_dvd_of_hadamardOrder` from `Basic.lean`. A construction theorem and
a combinatorial counting theorem compose into a necessary condition. We anchored everything
with concrete order-2 seeds and certified Hadamard orders `2` (skew route) and `4` (symmetric
doubling route).

The most instructive *failure* was a confirmed boundary: for a symmetric conference matrix the
naive skew recipe `I + S` is **not** Hadamard
(`not_isHadamardP_one_add_symmConferenceTwo`) — the rows of `I + S` coincide and lose
orthogonality. This counterexample is exactly why the symmetric case must double the order, and
it pins the skew/symmetric dichotomy as a structural necessity rather than a convenience. The
remaining frontier is the same as before — *existence* of conference matrices from finite-field
quadratic residues — plus the Williamson generalization, which we recorded as the single,
explicitly-flagged conjecture in the Lean source.

## Results Summary

- `symmetricConference_hadamardOrder_two_mul`: **proved** — a symmetric conference matrix of order `n` yields a Hadamard matrix of order `2n` (Paley II doubling; previously an open `sorry`).
- `paleyTwoBlock_entries`: **proved** — every entry of the Paley II block matrix `[[S+I,S-I],[S-I,-(S+I)]]` is `±1`.
- `paleyTwoBlock_mul_transpose`: **proved** — the block matrix satisfies `B Bᵀ = 2n·I` (the conference identity lifted to the doubled order).
- `hadamardOrderP_of_sum_block`: **proved** — abstract transport of a `±1`, self-orthogonal `Fin n ⊕ Fin n` matrix to a Hadamard order `2n`.
- `symmetricConference_mulSelf`: **proved** — the defining square `S² = (n-1)·I` of a symmetric conference matrix.
- `skewConferenceTwo`, `symmConferenceTwo`: **proved** — explicit order-2 skew and symmetric conference matrices.
- `hadamardOrderP_two_of_skew`, `hadamardOrderP_four_of_symm`: **proved** — certified Hadamard orders `2` and `4` from the two seeds, exercising both constructions end-to-end.
- `skewConference_four_dvd`: **proved** — cross-file obstruction: a skew conference matrix of order `n > 2` forces `4 ∣ n` (Paley I composed with `four_dvd_of_hadamardOrder`).
- `not_isHadamardP_one_add_symmConferenceTwo`: **proved (counterexample)** — `I + S` is not Hadamard for the symmetric order-2 conference matrix, proving the skewness hypothesis of Paley I is necessary.
- `williamson_hadamardOrder`: **conjecture (sorry)** — pairwise-commuting symmetric `±1` matrices with `A²+B²+C²+D² = 4n·I` should assemble into a Hadamard matrix of order `4n`.

## Research Directions

### Direction 1: Quadratic-residue conference matrix over `GF(q)`
**Hypothesis**: For prime `q`, the Paley core `C i j = χ(j - i)` (with `χ` the quadratic
character of `ZMod q`, `χ 0 = 0`) is a conference matrix on the index `ZMod q`, skew when
`q ≡ 3 (mod 4)` and symmetric when `q ≡ 1 (mod 4)`.
**Test**: Prove `C Cᵀ = (q-1)·I` by reducing it to the character-sum identity
`∑_t χ(t) χ(t + d) = -1` for `d ≠ 0`; derive skew/symmetric from `χ(-1) = (-1)^((q-1)/2)`.
Then `skewConference_hadamardOrder` / `symmetricConference_hadamardOrder_two_mul` immediately
give Hadamard orders `q` and `2q`.
**Why now**: This cycle reduced the *entire* Hadamard conclusion to the `IsConference` data;
the only missing input is one finite character-sum lemma, and Mathlib already has
`quadraticChar`, `ZMod.quadraticChar`, and `legendreSym`.
**If true**: It yields the first verified non-power-of-two infinite Hadamard family.
**If false**: A failure localizes precisely in the character-sum step, exposing a gap in
Mathlib's quadratic-character API rather than in the matrix algebra.

### Direction 2: The Paley orders form a multiplicatively closed family
**Hypothesis**: The set of certified Hadamard orders contains
`{ q + 1 : q ≡ 3 (mod 4) prime power }` together with all products of such numbers with powers
of two — a strict superset of the Sylvester family (e.g. orders `12, 20, 24, 28, 60`).
**Test**: Combine Direction 1's skew seeds with the catalog's `hadamardOrder'_mul`
(tensor closure) and `hadamardOrder'_pow_two`; certify each listed sporadic order.
**Why now**: Tensor closure is already proved and verified; a single new prime-power seed
explodes into an infinite multiplicative semigroup of orders.
**If true**: It converts isolated existence facts into a structured, enumerable family.
**If false**: It would reveal a subtlety in transporting Kronecker products across the
`HadamardOrderP`/`HadamardOrder'` predicate boundary.

### Direction 3: Symmetric conference matrices force `n ≡ 2 (mod 4)`
**Hypothesis**: A symmetric conference matrix of order `n > 1` exists only when `n ≡ 2 (mod 4)`
(the symmetric analogue of `skewConference_four_dvd`, which already shows skew ⇒ `4 ∣ n`).
**Test**: Reduce `C Cᵀ = (n-1)·I` modulo 4 against the zero-diagonal / `±1` off-diagonal
structure, mirroring the row-triple counting in `four_dvd_of_hadamardOrder` but for a
zero-diagonal matrix; alternatively route through the order-`2n` Hadamard matrix and a refined
count.
**Why now**: `skewConference_four_dvd` shows the construction-then-count composition works; the
symmetric case is the same template applied to the doubled matrix.
**If true**: It completes the obstruction theory begun by
`not_isHadamardP_one_add_symmConferenceTwo`, fully delimiting which orders are reachable.
**If false**: The counterexample would itself be a new conference matrix of unexpected order —
an existence result in disguise.

### Direction 4: Williamson construction via a four-square identity
**Hypothesis**: Pairwise-commuting symmetric `±1` matrices `A, B, C, D` of order `n` with
`A² + B² + C² + D² = 4n·I` assemble (via the quaternionic 4×4 array) into a Hadamard matrix of
order `4n` (`williamson_hadamardOrder`, currently a `sorry`).
**Test**: Generalize `paleyTwoBlock` to the 4-block layout; show off-diagonal blocks cancel by
the same commute-and-subtract mechanism (now organized by the quaternion table) and diagonal
blocks sum to `4n·I` by the four-square hypothesis; transport with a 4-fold version of
`hadamardOrderP_of_sum_block`.
**Why now**: `paleyTwoBlock_mul_transpose` is a proven 2-block prototype of exactly this
cancellation, and `Matrix.fromBlocks_multiply` / `fromBlocks_transpose` scale to nested blocks.
**If true**: It certifies Williamson orders (`12, 20, 28, 36, …`) that neither Sylvester nor
Paley alone reaches.
**If false**: The failure would isolate whether commutativity alone suffices or whether a
stronger (e.g. circulant) hypothesis is required for the off-diagonal cancellation.

### Direction 5: Symmetric conference matrices and the Hadamard–BIBD bridge
**Hypothesis**: The `{0,1}`-incidence matrix of a symmetric conference matrix of order `q+1`
is the incidence matrix of a symmetric `2-(q, (q-1)/2, (q-3)/4)` design, and its associated
Hadamard matrix realizes the `2-(4t-1, 2t-1, t-1)` design counted by `Design.lean`'s
`normalized_row_pair_ones`.
**Test**: Identify the quadratic-residue set of `GF(q)` as a `(q, (q-1)/2, (q-3)/4)`-difference
set and equate its difference counts with the `n/4` pair-intersection count already proved in
`Design.lean`.
**Why now**: `Design.lean` already formalizes `SymmetricBIBD` and the `n/4` intersection count;
Direction 1 supplies the explicit residue structure, so the bridge is an equality of two
already-formalized counts rather than a new design-existence proof.
**If true**: It unifies the linear-algebraic and combinatorial accounts of Paley structures as
literally the same character sum.
**If false**: A mismatch would expose a normalization or off-by-one discrepancy between the
matrix and design conventions in the catalog.
