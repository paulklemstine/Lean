# Future Directions: Code-Based Cryptography (McEliece / Goppa)

The file `Catalog/Cryptography/McElieceGoppa.lean` establishes the abstract
correctness backbone of the McEliece cryptosystem: bounded-distance unique
decoding (`unique_decoding`), weight-invariance of coordinate permutations
(`hammingNorm_comp_equiv`), end-to-end decryption correctness
(`mceliece_correct`), the sphere-packing bound (`sphere_packing_bound`), and a
concrete NIST level-5 parameter set (`cm6960119_*`). These results deliberately
take the *minimum distance* of the code as a hypothesis. The natural next
research cycle is to *derive* that hypothesis from the algebraic structure of
Goppa codes, and to formalize the hardness assumptions that underwrite security.
Five concrete, falsifiable directions follow.

## 1. The Goppa designed-distance theorem

Right now `cm6960119_corrects_119_errors` assumes the designed distance `2t+1`.
The honest statement to prove is that a *binary* Goppa code `Γ(L, g)` with a
squarefree Goppa polynomial `g` of degree `t` over `GF(2^m)` has minimum
distance `≥ 2t+1` (not merely `≥ t+1`). Formalize Goppa codes as the kernel of
the parity map `c ↦ Σᵢ cᵢ/(x − Lᵢ) mod g`, and prove the weight bound.

**The key insight is** that over characteristic 2 the syndrome polynomial of a
codeword is the formal derivative of `∏ᵢ (x − Lᵢ)^{cᵢ}`, whose squarefree part
doubles the apparent degree — this is exactly what upgrades the BCH bound `t+1`
to `2t+1` and is the single fact that distinguishes Goppa codes from generic
alternant codes.

**Why now?** The Schwartz–Zippel / minimum-distance infrastructure already in
`Cryptography/MinimumDistance.lean` and the abstract decoder in this file mean
the only missing piece is the algebraic identity; proving it would let
`cm6960119_corrects_119_errors` drop its hypothesis entirely and become
unconditional.

## 2. Patterson decoding as a constructive `decode`

`mceliece_correct` is parameterized by an *abstract* decoder satisfying the
`hdec` correctness contract. Replace it with a concrete `decode` implementing
Patterson's algorithm (solve the key equation `σ(x)·S(x) ≡ ω(x) mod g` via the
extended Euclidean algorithm) and prove it meets `hdec` for `wt(e) ≤ t`.

**The key insight is** that Patterson's split of the error locator into even and
odd parts, `σ = a² + x·b²`, linearizes the otherwise quadratic key equation in
characteristic 2, reducing decoding to one gcd computation — a step that is
fully formalizable with Mathlib's `EuclideanDomain` and polynomial API.

**Why now?** With `mceliece_correct` already discharging the wrapper
(scrambler + permutation), a verified Patterson decoder immediately yields a
*fully verified* McEliece decryption with no abstract holes.

## 3. Worst-case decoding hardness from the sphere-packing regime

The concept brief asks for NP-hardness of decoding random linear codes
(Berlekamp–McEliece–van Tilborg). A tractable first milestone: formalize the
*coset weights* / *syndrome decoding* decision problem and prove the
search-to-decision and self-reduction lemmas, using `sphere_packing_bound` to
show that below the packing radius solutions are unique (so the decision problem
is well-posed).

**The key insight is** that uniqueness of the nearest codeword inside the
packing radius (already proved as `unique_decoding`) is precisely what makes the
NP witness *checkable in polynomial time*, so the combinatorial reduction from
3-dimensional matching reduces to a counting argument the catalog's
`Cryptography/HardnessHierarchy.lean` framework can host.

**Why now?** `unique_decoding` and `sphere_packing_bound` give the two
well-posedness facts that every textbook NP-hardness proof silently assumes;
formalizing them is usually the bottleneck, and that bottleneck is now cleared.

## 4. The Gilbert–Varshamov counterpart to sphere packing

`sphere_packing_bound` is an upper bound on code size. Prove its lower
companion: a greedy/probabilistic argument showing a code of length `n`,
distance `d`, and size `≥ q^n / V_q(n, d−1)` exists (Gilbert–Varshamov). Pair
the two to bracket the achievable rate region.

**The key insight is** that the *same* ball-volume function `V` appearing in
`hammingBall_card_eq` controls both bounds — packing forbids overlap from above,
while a maximal code with no addable word forces covering from below — so a
single formalized volume lemma yields both inequalities.

**Why now?** `hammingBall_card_eq` already proves translation-invariance of the
ball volume, the exact lemma a GV argument needs; the lower bound is then a short
maximality argument over `Finset`.

## 5. Distinguishing-equals-decoding for Goppa generator matrices

The brief's deepest target: show that distinguishing a Goppa generator matrix
from a uniformly random one is as hard as decoding. Formalize the indistinguish-
ability game and a reduction transforming a distinguishing advantage into a
decoding oracle, building on the catalog's `Cryptography/SearchDecision.lean`
and `Cryptography/Security.lean` game frameworks.

**The key insight is** that the scrambler-and-permutation wrapper proved
transparent by `mceliece_correct` (the public key is `S·G·P`) means a
distinguisher must exploit *intrinsic* code structure rather than the masking —
so its advantage can be replayed against the underlying random-code decoding
instance with the permutation folded away via `hammingNorm_comp_equiv`.

**Why now?** `mceliece_correct` formally certifies that `S` and `P` do not
change the decoded message, which is exactly the algebraic invariance a
distinguishing-to-decoding reduction must invoke to discard the mask; with that
in hand the reduction becomes a game-hopping argument the catalog already
supports.
