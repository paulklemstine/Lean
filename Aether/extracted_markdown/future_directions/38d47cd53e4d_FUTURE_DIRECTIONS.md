# Future Directions: Conference Matrices and the Paley Construction in Lean 4

This cycle formalized the *algebraic core* of the Paley construction in
`Catalog/Algebra/Hadamard/Conference.lean`. We introduced conference matrices over an
arbitrary finite index type (`IsConferenceMatrix`), a generalized Hadamard predicate
(`IsHadamardF`), and proved the two construction theorems that turn conference matrices into
Hadamard matrices:

* **Paley type II (skew case)** — `isHadamardF_one_add_skew_conference`: a skew conference
  matrix `C` of order `n` (`Cᵀ = -C`) yields a Hadamard matrix `I + C` of order `n`. We
  further showed (`one_add_skew_conference_skewHadamard`) that `I + C` is in fact a
  *skew-Hadamard* matrix (`H + Hᵀ = 2·I`).
* **Paley type I (symmetric case)** — `isHadamardF_paleyBlock`: a symmetric conference
  matrix `S` of order `n` yields a Hadamard matrix of order `2n` via the block matrix
  `[[S+I, S-I], [S-I, -(S+I)]]`, transported to `Fin (n+n)` in
  `hadamard_order_two_mul_of_symm_conference`.

We anchored these with a concrete order-2 instance (`skewConferenceTwo`,
`hadamardF_order_two`) and a sharpness counterexample
(`not_isHadamardF_one_add_symmConferenceTwo`) showing the skewness hypothesis is genuinely
necessary. These results extend the catalog's tensor-closure / Sylvester family
(`hadamardOrder'_mul`, `hadamardOrder'_pow_two` in `Constructions.lean`) with a structurally
different, non-power-of-two route to Hadamard existence. The remaining gap to the full Paley
theorem is purely arithmetic: *existence* of conference matrices from finite-field quadratic
residues. The following directions target that gap and adjacent frontiers.

## 1. The quadratic-residue conference matrix over `GF(q)`

Construct, for a prime power `q`, the Paley core matrix `C i j = χ(j - i)` where `χ` is the
quadratic character of `GF(q)` (extended by `χ(0) = 0`), and prove `IsConferenceMatrix C`
on the index type `ZMod q` (for `q` prime) or `GaloisField`. Then derive `IsSkew C` when
`q ≡ 3 (mod 4)` and `C.IsSymm` when `q ≡ 1 (mod 4)`, so that the two theorems already proved
in `Conference.lean` immediately yield Hadamard matrices of orders `q` and `2q` respectively.

The key insight is that `C · Cᵀ = (q-1)·I` reduces entirely to the **character-sum identity**
`∑_{t} χ(t)χ(t + d) = -1` for `d ≠ 0`, which is a finite, self-contained number-theoretic
lemma — no analysis required. Skew vs. symmetric is governed by `χ(-1) = (-1)^((q-1)/2)`.

Why now? Mathlib already provides `quadraticChar`, `ZMod.quadraticChar`, `legendreSym`, and
the Gauss-sum machinery, and our `Conference.lean` reduces the *entire* Hadamard conclusion
to exactly the `IsConferenceMatrix` predicate. The only missing piece is one character-sum
lemma, making this the highest-leverage next step.

## 2. Paley orders form a new infinite family closed under tensoring

Combine direction 1 with the catalog's `hadamardOrder'_mul` to prove that the set of Hadamard
orders contains `{ q + 1 : q prime power, q ≡ 3 mod 4 }` together with all products of such
numbers and powers of two — a strict superset of the Sylvester family. Concretely, certify
new sporadic orders such as 12 (`q = 11`), 20 (`q = 19`), 24, 28 (`q = 27`), and 60.

The key insight is that Hadamard existence is *multiplicatively closed* (already proved as
`hadamardOrder'_mul`), so a single new prime-power input explodes into an infinite
multiplicative semigroup of certified orders; the Paley primes seed the orders that powers of
two alone can never reach.

Why now? The tensor-closure theorem is already formalized and verified, and direction 1
supplies the seeds. This turns isolated existence facts into a structured, enumerable family
and would be the first verified non-power-of-two infinite Hadamard family in any proof
assistant.

## 3. Conference matrices force `card ≡ 2 (mod 4)` (a clean necessary condition)

Prove that a symmetric conference matrix of order `n > 1` can only exist when `n ≡ 2
(mod 4)`, and a skew one only when `n ≡ 0 (mod 4)`, mirroring the catalog's
`four_dvd_of_hadamardOrder` necessary condition for Hadamard matrices. This sharpens the
boundary example `not_isHadamardF_one_add_symmConferenceTwo` into a full obstruction theory.

The key insight is that reducing the defining identity `C·Cᵀ = (n-1)·I` modulo 4 and
combining it with the `±1` off-diagonal / zero-diagonal structure yields a parity constraint
on `n` — exactly the same row-triple counting argument used in `four_dvd_of_hadamardOrder`,
now applied to a zero-diagonal matrix.

Why now? `Catalog/Algebra/Hadamard/Basic.lean` already contains the full counting proof of
the analogous Hadamard obstruction; adapting that argument to the conference setting is a
direct, finite combinatorial transcription rather than new mathematics.

## 4. Symmetric conference matrices and the Hadamard–BIBD bridge

Connect direction 1's symmetric Paley cores to the design-theory file
`Catalog/Algebra/Hadamard/Design.lean`. Show that the `{0,1}`-incidence matrix obtained from
a symmetric conference matrix of order `q+1` is the incidence matrix of a symmetric
`2-(q, (q-1)/2, (q-3)/4)` design (a *conference/Paley design*), and that its associated
Hadamard matrix realizes the `2-(4t-1, 2t-1, t-1)` design counted by `normalized_row_pair_ones`.

The key insight is that the quadratic-residue set of `GF(q)` is exactly a `(q, (q-1)/2,
(q-3)/4)`-difference set, so the pair-intersection counts that `Design.lean` already proves
(`normalized_row_pair_ones`, value `n/4`) coincide with the residue-difference counts — the
linear-algebraic and combinatorial counts are literally the same character sum.

Why now? `Design.lean` already formalizes `SymmetricBIBD` and the `n/4` intersection count;
direction 1 supplies the explicit residue structure. The bridge is then an equality of two
already-formalized counts rather than a new design-existence proof.

## 5. Williamson construction via a quaternionic four-square identity

Generalize the block technique of `paleyBlock` from a 2×2 block layout to the 4×4 Williamson
array `[[A,B,C,D],[-B,A,-D,C],[-C,D,A,-B],[-D,-C,B,A]]`, proving that symmetric `±1` matrices
`A,B,C,D` with `A² + B² + C² + D² = 4n·I` (and pairwise commuting, e.g. circulant) produce a
Hadamard matrix of order `4n`.

The key insight is that the off-diagonal blocks cancel by *exactly* the same
commute-and-subtract mechanism already used in `isHadamardF_paleyBlock` (where
`A·B - B·A = 0`), now organized by the quaternion multiplication table; the diagonal blocks
sum to `4n·I` by the four-square hypothesis, generalizing our `A²+B² = 2n·I` step.

Why now? `isHadamardF_paleyBlock` is a proven 2-block prototype of the cancellation argument,
and Mathlib's `Matrix.fromBlocks_multiply` / `fromBlocks_transpose` API scales to nested
blocks. Adding a `Circulant`/commuting-symmetric hypothesis would let the same proof skeleton
certify Williamson orders (12, 20, 28, 36, …) that neither Sylvester nor Paley alone reaches.
