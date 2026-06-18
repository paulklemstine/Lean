# Future Directions — Code-Based Cryptography (McEliece / Goppa)

This cycle formalized the *correctness interface* of the McEliece cryptosystem in
`Cryptography/McElieceGoppa.lean`: bounded-distance unique decoding
(`unique_decoding`), its tightness at even minimum distance
(`decoding_fails_at_even_distance`), the full encrypt/decrypt round-trip
(`mcEliece_correct`), the code-size/dimension theorem (`code_card`), and the
Classic McEliece *mceliece8192128* parameter computation. The decoder is
abstracted by the predicate `CorrectsErrors`, isolating the single guarantee a
Goppa code must provide. The directions below push from this interface toward the
*combinatorial* and *hardness* core of the scheme.

## 1. The error-sphere volume and the Hamming/Singleton bounds

Prove the exact size of a Hamming sphere: over a finite field `F` with `|F| = q`,
the number of words `x : Fin n → F` with `hammingNorm x = t` is
`C(n,t)·(q-1)^t`. From this, derive the Hamming (sphere-packing) bound
`q^k · V_q(n,t) ≤ q^n` for any `t`-error-correcting `[n,k]` code, and the
Singleton bound `d ≤ n - k + 1` via `code_card`.

The key insight is that the McEliece error space — the very object an attacker
must search — is *exactly* this sphere, so its `C(8192,128)·1^128 = C(8192,128)`
cardinality is the quantitative root of the `≈2^256` brute-force barrier already
named in `mceliece8192128_codespace_size`. Why now? `code_card` already gives the
`q^k` half of the sphere-packing inequality, and Mathlib's `Nat.choose` plus
`hammingNorm_perm` (proved here) supply the bijective bookkeeping; only the
support-counting step is missing.

## 2. Permutation-equivalence as a group action, and code automorphisms

Upgrade the isometry lemmas `hammingDist_perm` / `hammingNorm_perm` into a genuine
action of `Equiv.Perm (Fin n)` (and the full monomial group `F^* ≀ S_n`) on codes,
and define the automorphism group `Aut(C) = { (D,σ) : C∘σ = C }`. Prove that
permutation-equivalent codes have identical minimum distance and decoding radius.

The key insight is that McEliece security is precisely the assumption that the
public key `S·G·P` is computationally indistinguishable from a random generator
*up to this monomial action* — so the action is the right categorical home for
the "Goppa-distinguishing" problem. Why now? Both isometry lemmas are already
proved as `Finset.card_bij'` bijections; promoting them to `MulAction` instances
is a structural, low-risk refactor that immediately makes equivalence statements
expressible.

## 3. A search-to-decision reduction for syndrome decoding

Formalize the syndrome-decoding problem `SD(H, s, t) := ∃ e, hammingNorm e ≤ t ∧
H *ᵥ e = s` and prove a *self-reduction*: an oracle deciding membership of `SD`
can be queried coordinate-by-coordinate to actually *reconstruct* a witness `e`
(search ≤ decision in polynomially many calls). State the
Berlekamp–McEliece–Tilborg NP-hardness target as a reduction from a Mathlib
NP-complete problem (e.g. via `Computation`-library SAT/3-cover encodings).

The key insight is that the *decision-to-search* direction is fully constructive
and provable today without any complexity machinery, while it captures the exact
sense in which "breaking McEliece = decoding a random code." Why now? The
parity-check view `H *ᵥ e = s` is one transpose away from the `vecMul` API used
throughout this file, and the catalog's `Computation` and `Bridges/Decoder`
modules already host reduction-style arguments to imitate.

## 4. Indistinguishability and the distinguisher advantage as a measure

Define a McEliece distinguisher's advantage as `|Pr[D(S·G·P)=1] − Pr[D(R)=1]|`
over the uniform random generator `R`, using `PMF`/`MeasureTheory`, and prove the
hybrid lemma: if no algorithm decodes `t` random errors with non-negligible
probability, then no algorithm distinguishes the Goppa generator with
non-negligible advantage. This is the "distinguishing ≤ decoding" claim made
informally in the concept.

The key insight is that `mcEliece_correct` already shows the *honest* channel is
noiseless; the security reduction only needs to transport a decoding success
event through the bijective scrambling `(S, P)`, and `hammingNorm_perm` guarantees
the error-weight distribution is invariant under that transport. Why now? Mathlib's
`PMF` and `ENNReal` give a usable probability layer, and the invariance lemmas
needed to push distributions through `S·G·P` are exactly those proved here.

## 5. Parameter optimization: rate vs. corrected errors as a frontier

Formalize the binary Goppa design relation `k ≥ n − m·t` with `n = 2^m`, and
prove the monotonicity/trade-off frontier: for fixed `n`, increasing `t`
strictly decreases the guaranteed rate `k/n` while strictly increasing the
proven error-correction radius in `unique_decoding`. Verify a *family* of
standardized sets (`mceliece348864`, `mceliece6688128`, `mceliece8192128`) lands
on the predicted `(rate, security)` curve, generalizing `mceliece8192128_params`.

The key insight is that 256-bit security is not a single number but a *Pareto
point* on a provable rate-vs-radius curve, so formalizing the curve turns
parameter selection into a checkable optimization rather than a table lookup. Why
now? `mceliece8192128_params` and `code_card` already pin the two axes (`k` and
the corrected radius `t`) for one point; extending to the inequality `k ≥ n−m·t`
across a parameter family is pure `Nat`/`omega` arithmetic the subagent handles
reliably.
