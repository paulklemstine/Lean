# Self-Dual Codes as a Bridge to Smooth 4-Manifold Intersection-Form Pipelines

## Abstract

We develop, in complete and self-contained form, the structural dictionary
between binary self-dual error-correcting codes and the unimodular intersection
forms of smooth closed four-manifolds, and we establish that the dictionary
respects the natural "gluing" operations on both sides. On the topology side the
gluing operation is the **orthogonal direct sum** of intersection forms — the
algebraic model of the connected sum `M # N` of four-manifolds — under which
unimodularity (Poincaré duality), evenness (the spin condition), and standard
diagonalizability are each closed. On the coding side the corresponding operation
is **coordinate concatenation** `C ⊕ D`, under which we prove that Hamming weight
is additive, the binary inner product is block-diagonal, cardinality is
multiplicative, double-evenness is preserved, self-orthogonality is preserved,
and — the headline closure result — **self-duality is preserved**. We further
recall the two length-divisibility theorems that make the bridge sharp: every
self-dual doubly-even binary code has length divisible by `4` (via the all-ones
"global section" argument) and, in fact, by `8` (Gleason's theorem, via a Gauss
sum / MacWilliams evaluation yielding the master identity `|C| = (1+i)ⁿ`). These
are the code-side mirrors of the rank-`8` divisibility of positive-definite even
unimodular lattices, the regime in which the lattice `E8` — and hence its mod-2
shadow, the extended Hamming `[8,4,4]` code — lives. As the capstone application
we construct the length-`16` code `H₁₆ = Hamming ⊕ Hamming`, the precise mod-2
shadow of the rank-`16` form `E8 ⊕ E8`, and derive all of its invariants
(doubly-even, self-dual, `256` codewords, length divisible by `8`) from the
general closure theorems rather than by brute-force enumeration over `2¹⁶`
vectors. All results have been formally verified.

**Keywords:** self-dual codes, doubly-even codes, intersection forms, smooth
four-manifolds, Construction A, Gleason's theorem, connected sum, E8 lattice,
extended Hamming code, MacWilliams identity.

---

## 1. Introduction

The classification of smooth closed simply-connected four-manifolds is controlled
to a remarkable extent by a single algebraic invariant: the **intersection form**,
a symmetric unimodular bilinear form on the second homology lattice. Two cornerstone
constraints shape the landscape. Poincaré duality forces the form to be unimodular;
Donaldson's diagonalization theorem forces every *smooth definite* form to be a
standard diagonal of `±1`s, so that the even unimodular form `E8` — algebraically
impeccable — describes a topological shape that admits no smooth structure of the
required kind.

In parallel, coding theory has long known that **binary self-dual codes** obey a
structurally identical set of laws: self-duality plays the role of unimodularity,
double-evenness plays the role of the spin/even condition, and the length of a
doubly-even self-dual code is divisible by `8` — Gleason's theorem — exactly as the
rank of a positive-definite even unimodular lattice is divisible by `8`. The link is
not coincidental: **Construction A** reduces an even unimodular lattice modulo `2`
to a doubly-even self-dual code, identifying the two divisibility miracles as one.

This paper formalizes the bridge with an emphasis on **stability under gluing**. The
natural operation on four-manifolds is the connected sum `M # N`, whose intersection
form is the orthogonal direct sum of the summands' forms. We prove that the entire
structural package transports to the coding side under coordinate concatenation, and
we deploy the resulting closure theorems to build the length-`16` code `H₁₆`, the
faithful mod-2 image of `E8 ⊕ E8`.

We work throughout over the binary field `𝔽₂ = ZMod 2`, identifying a binary vector of
length `n` with a function `Fin n → ZMod 2`.

---

## 2. Definitions

Throughout, `n, m : ℕ` and codes are finite sets of binary vectors.

**Definition 2.1 (Hamming weight).** For `v : Fin n → ZMod 2`, the *weight* is the
number of nonzero coordinates,
> `wt v = |{ i : v i = 1 }|`.

**Definition 2.2 (Overlap).** For `x, y : Fin n → ZMod 2`,
> `overlap x y = |{ i : x i = 1 ∧ y i = 1 }|`.

**Definition 2.3 (Binary inner product).** For `x, y : Fin n → ZMod 2`,
> `⟨x, y⟩ = ip x y = ∑ᵢ xᵢ · yᵢ ∈ ZMod 2`.

**Definition 2.4 (Doubly even).** A vector `v` is *doubly even* when `4 ∣ wt v`. A
code `C` is doubly even when every `v ∈ C` is.

**Definition 2.5 (Self-dual code).** A finite set `C ⊆ (ZMod 2)ⁿ` is *self-dual* when
it coincides with its own orthogonal complement:
> for all `x`,  `x ∈ C ⟺ (∀ y ∈ C, ⟨x, y⟩ = 0)`.

**Definition 2.6 (All-ones vector).** `ones n : Fin n → ZMod 2` is the constant
function `i ↦ 1`.

**Definition 2.7 (Coordinate concatenation / direct sum of codes).** For
`C ⊆ (ZMod 2)ᵐ` and `D ⊆ (ZMod 2)ⁿ`, the *direct sum* is
> `C ⊕ D = { append a b : a ∈ C, b ∈ D } ⊆ (ZMod 2)^{m+n}`,

where `append a b` places the `m` coordinates of `a` first and the `n` coordinates of
`b` second. We write the left and right blocks of a vector `z : (ZMod 2)^{m+n}` as
`leftPart z` (its first `m` coordinates) and `rightPart z` (its last `n`), so that
`append (leftPart z) (rightPart z) = z`.

On the topology side we use the standard package:

**Definition 2.8 (Intersection form).** An *intersection form* of rank `n` is a
symmetric integer matrix `G : Fin n → Fin n → ℤ` (the Gram matrix). It is
*unimodular* when `det G = ±1`; *even* when the quadratic value `v ↦ vᵀ G v` is even
for all `v` (equivalently every diagonal entry `Gᵢᵢ` is even); and *standard
diagonalizable* when there is an integer change of basis `T` with `Tᵀ G T = I`.

**Definition 2.9 (Orthogonal direct sum of forms).** For forms `Q` (rank `m`) and `R`
(rank `n`), `Q ⊕ R` (rank `m + n`) has block-diagonal Gram matrix `diag(G_Q, G_R)`
reindexed along `Fin m ⊕ Fin n ≃ Fin (m+n)`. It models the connected sum `M # N`.

---

## 3. The structural dictionary

The bridge rests on Construction A and is summarized by the following
correspondence, each row of which is a theorem-for-theorem match between the two
theories developed in this paper.

| Coding theory | Smooth 4-manifold topology |
|---|---|
| binary code `C ⊆ (ZMod 2)ⁿ` | intersection form `Q` of rank `n` |
| self-dual: `C = C^⊥` | unimodular: `det = ±1` (Poincaré duality) |
| doubly even: `4 ∣ wt v` | even form: even diagonal (spin) |
| length `n` | rank `n` |
| concatenation `C ⊕ D` | orthogonal sum `Q ⊕ R` (connected sum) |
| `|C ⊕ D| = |C|·|D|` | `det(Q ⊕ R) = det Q · det R` |
| extended Hamming `[8,4,4]` | the lattice/form `E8` |
| Gleason: `8 ∣ n` | even unimodular definite ⟹ `8 ∣` rank |
| `Hamming ⊕ Hamming` (len 16) | `E8 ⊕ E8` (rank 16) |

---

## 4. Block arithmetic of concatenation

The proofs of the closure theorems all reduce to two elementary but decisive
splitting lemmas, which express that concatenation introduces no cross-interaction
between the two blocks. These are the combinatorial shadow of the off-diagonal
zeros in the block-diagonal Gram matrix `diag(G_Q, G_R)`.

**Lemma 4.1 (Membership criterion).** `z ∈ C ⊕ D ⟺ leftPart z ∈ C ∧ rightPart z ∈ D`.
Equivalently, in existential form,
> `z ∈ C ⊕ D ⟺ ∃ a ∈ C, ∃ b ∈ D, z = append a b`.

*Proof sketch.* The image definition gives the forward direction by extracting the
preimage pair; the reverse direction uses `append (leftPart z) (rightPart z) = z` and
`leftPart (append a b) = a`, `rightPart (append a b) = b`. ∎

**Lemma 4.2 (Weight is additive).** `wt (append a b) = wt a + wt b`.

*Proof sketch.* The support of `append a b` is the disjoint union of the support of
`a` (in the first block) and the support of `b` (in the second block); count via the
splitting `∑_{Fin (m+n)} = ∑_{Fin m} + ∑_{Fin n}`. ∎

**Lemma 4.3 (Inner product is block-diagonal).**
> `⟨append a b, append c d⟩ = ⟨a, c⟩ + ⟨b, d⟩`.

*Proof sketch.* Split the defining sum over `Fin (m+n)` into the first-block and
second-block sums; on the first block `append a b` and `append c d` restrict to `a`
and `c`, on the second to `b` and `d`. No cross-terms appear because each coordinate
belongs to exactly one block. ∎

**Lemma 4.4 (Cardinality is multiplicative).** `|C ⊕ D| = |C| · |D|`.

*Proof sketch.* The map `(a, b) ↦ append a b` is injective on `C × D`: from
`append a b = append a' b'` one recovers `a = a'` by reading the first `m`
coordinates and `b = b'` from the last `n`. Hence the image has the same cardinality
as the product `C × D`. This is the code-side image of `det` multiplicativity across
block-diagonal blocks. ∎

---

## 5. Closure theorems

We now prove that the structural predicates survive concatenation. Each is the exact
mirror of a closure theorem for the orthogonal direct sum of intersection forms.

**Theorem 5.1 (Double-evenness is closed under `⊕`).** If every `v ∈ C` and every
`v ∈ D` is doubly even, then every `v ∈ C ⊕ D` is doubly even.

*Proof sketch.* By Lemma 4.1 any `v ∈ C ⊕ D` is `append a b` with `a ∈ C`, `b ∈ D`;
by Lemma 4.2, `wt v = wt a + wt b`. Since `4 ∣ wt a` and `4 ∣ wt b`, also
`4 ∣ wt v`. This mirrors `directSum_isEven`: evenness of a form is governed entirely
by its diagonal, which in a block-diagonal sum is the concatenation of the two
diagonals. ∎

**Theorem 5.2 (Self-orthogonality is closed under `⊕`).** If `⟨x, y⟩ = 0` for all
`x, y ∈ C` and for all `x, y ∈ D`, then `⟨x, y⟩ = 0` for all `x, y ∈ C ⊕ D`.

*Proof sketch.* Write `x = append a b`, `y = append c d` with `a, c ∈ C`, `b, d ∈ D`
(Lemma 4.1). By Lemma 4.3, `⟨x, y⟩ = ⟨a, c⟩ + ⟨b, d⟩ = 0 + 0 = 0`. This is precisely
the statement that the off-diagonal blocks of `diag(G_Q, G_R)` vanish. ∎

**Theorem 5.3 (Self-duality is closed under `⊕`) — the headline.** If `C` and `D` are
each self-dual, then `C ⊕ D` is self-dual.

*Proof sketch.* The membership equivalence to be proved is, for arbitrary
`x : (ZMod 2)^{m+n}`,
> `x ∈ C ⊕ D ⟺ ∀ y ∈ C ⊕ D, ⟨x, y⟩ = 0.`

(⟹) If `x ∈ C ⊕ D`, then `leftPart x ∈ C` and `rightPart x ∈ D` (Lemma 4.1). For any
`y = append a b ∈ C ⊕ D` we split `⟨x, y⟩ = ⟨leftPart x, a⟩ + ⟨rightPart x, b⟩` via
Lemma 4.3; both summands vanish by the self-duality of `C` and `D` respectively. This
is exactly Theorem 5.2 specialized to a member.

(⟸) Suppose `x` is orthogonal to all of `C ⊕ D`. We must show
`leftPart x ∈ C` and `rightPart x ∈ D`. To probe the left block, test `x` against the
"left-only" codewords `append a 0` for `a ∈ C` (these lie in `C ⊕ D` because the
zero word lies in any self-dual code, so `0 ∈ D`). The block-diagonal splitting
collapses `⟨x, append a 0⟩` to `⟨leftPart x, a⟩`, so `leftPart x` is orthogonal to all
of `C`, hence — by self-duality of `C` — `leftPart x ∈ C`. Symmetrically, probing
with `append 0 b` for `b ∈ D` shows `rightPart x ∈ D`. By Lemma 4.1, `x ∈ C ⊕ D`.

The essential content of the backward direction is the existence of the probing
codewords, which is exactly the fact that a self-dual code contains the zero word.
This mirrors the block-diagonal `Tᵀ G T` argument proving `directSum_unimodular` /
`directSum_stdDiagonalizable` on the lattice side: Poincaré self-duality is preserved
by connected sum. ∎

**Theorem 5.4 (Length divisibility is additive).** If `C` and `D` are each
doubly-even and self-dual, then `8 ∣ (m + n)`.

*Proof sketch.* By Theorems 5.1 and 5.3, `C ⊕ D` is doubly-even and self-dual; apply
Gleason's theorem (Theorem 6.4 below) to `C ⊕ D`, whose length is `m + n`. ∎

These four theorems are the code-side images of the lattice closure results
`directSum_isEven`, `directSum_unimodular`, `directSum_stdDiagonalizable`, and the
additivity of rank divisibility under orthogonal sum.

---

## 6. The length-divisibility tower

The bridge is made *sharp* by two divisibility theorems, layered exactly as on the
lattice side (`self-dual ⟹ 2 ∣ n` ⊂ `doubly-even self-dual ⟹ 8 ∣ n`, mirroring
`unimodular` ⊂ `even unimodular ⟹ rank divisible by 8`).

**Theorem 6.1 (Inner product equals overlap parity).** `⟨x, y⟩ = (overlap x y mod 2)`.

*Proof sketch.* In `ZMod 2` the product `xᵢ · yᵢ` equals `1` exactly when both factors
are `1`; summing counts the overlap positions modulo `2`. ∎

**Theorem 6.2 (All-ones inner product).** `⟨ones n, y⟩ = (wt y mod 2)`, and
`wt (ones n) = n`.

*Proof sketch.* `overlap (ones n) y` is the support of `y`, of size `wt y`; combine
with Theorem 6.1. The support of `ones n` is everything, so its weight is `n`. ∎

**Theorem 6.3 (Mod-4 length theorem).** Any self-dual doubly-even binary code `C` of
length `n` satisfies `4 ∣ n`.

*Proof sketch.* Every codeword has even weight (doubly even ⟹ `2 ∣ wt`), so by
Theorem 6.2 `⟨ones n, y⟩ = 0` for all `y ∈ C`. By self-duality, `ones n ∈ C`. As a
codeword it is doubly even, and `wt (ones n) = n`, so `4 ∣ n`. The all-ones vector is
a canonical "global section" whose forced membership records the length. ∎

**Theorem 6.4 (Gleason's length theorem).** Any self-dual doubly-even binary code `C`
of length `n` satisfies `8 ∣ n`.

*Proof sketch.* This is a self-contained Gauss-sum / MacWilliams argument over `ℂ`.

1. Let `csgn : ZMod 2 → ℂ` be the nontrivial multiplicative character `a ↦ (−1)ᵃ`, and
   `bchar x c = ∏ⱼ (−1)^{xⱼcⱼ} = (−1)^{⟨x,c⟩}`.
2. *Character orthogonality.* For a self-dual (hence linear) `C`,
   `∑_{c ∈ C} (−1)^{⟨x,c⟩} = |C|` if `x ∈ C` and `0` otherwise. The vanishing case
   uses the involution `c ↦ c + c₀` for some `c₀ ∈ C` with `⟨x, c₀⟩ ≠ 0`, which
   negates every summand; self-duality guarantees `C` is closed under addition.
3. *Fourier transform of `iwt x = i^{wt x}`.* A per-coordinate factorization gives
   `∑ₓ i^{wt x} (−1)^{⟨x,y⟩} = (1+i)^{n−wt y}(1−i)^{wt y}`. When `y` is doubly even
   this collapses to `(1+i)ⁿ`, using `1−i = (−i)(1+i)` and `(−i)^{wt y} = 1`.
4. *Master identity.* Evaluating the double sum
   `∑ₓ i^{wt x} ∑_{c∈C}(−1)^{⟨x,c⟩}` two ways yields
   > `|C| = (1 + i)ⁿ`  (as complex numbers).
5. *Number theory.* `|C|` is a positive real number, while the powers of `1+i` cycle
   with period `8`: `(1+i)⁴ = −4` is negative and the intermediate powers are
   non-real, so only exponents divisible by `8` land on the positive real axis
   (`(1+i)⁸ = 16`). Hence `8 ∣ n`. ∎

The two divisibility theorems are the code-side mirrors of the lattice fact that
positive-definite even unimodular lattices have rank divisible by `8`, the regime in
which `E8` is minimal.

---

## 7. The flagship instance: the extended Hamming `[8,4,4]` code

**Definition 7.1.** The extended Hamming code `Hamming ⊆ (ZMod 2)⁸` is the image of the
encoder `a ↦ ∑ᵢ aᵢ · gᵢ`, where the generator rows `g₀, …, g₃` are
```
g₀ = 1 1 1 1 1 1 1 1
g₁ = 0 0 0 0 1 1 1 1
g₂ = 0 0 1 1 0 0 1 1
g₃ = 0 1 0 1 0 1 0 1
```
(equivalently the first-order Reed–Muller code `RM(1,3)`).

**Theorem 7.2.** `Hamming` is self-dual and doubly even, with `16` codewords and weight
enumerator `1 + 14 X⁴ + X⁸` (one word of weight `0`, fourteen of weight `4`, one of
weight `8`). Its minimum distance is `4`.

*Proof sketch.* Self-duality and double-evenness are finite verifications over the
`256` candidate vectors and `16` codewords. The weight enumerator and minimum
distance follow from enumerating the `16` codewords. ∎

**Corollary 7.3.** Applying Theorem 6.4 to `Hamming` recovers `8 ∣ 8` from the general
Gleason theorem rather than by hand — mirroring how `E8`'s obstruction is *derived*
from its evenness, not checked entry by entry.

The extended Hamming code is the precise mod-2 shadow of the lattice `E8` under
Construction A.

---

## 8. The capstone: `Hamming ⊕ Hamming`, shadow of `E8 ⊕ E8`

**Definition 8.1.** `H₁₆ = Hamming ⊕ Hamming ⊆ (ZMod 2)^{8+8}` is the length-`16`
concatenation of two copies of the extended Hamming code.

**Theorem 8.2.** `H₁₆` is doubly even, self-dual, has exactly `256 = 16 · 16`
codewords, and length `16` divisible by `8` — *all derived from the general closure
theorems* of Section 5, not from enumeration over `2¹⁶ = 65536` vectors.

*Proof sketch.*
- *Doubly even:* Theorem 5.1 with both halves `Hamming` (doubly even by 7.2).
- *Self-dual:* Theorem 5.3 with both halves `Hamming` (self-dual by 7.2).
- *Cardinality:* Lemma 4.4 gives `|H₁₆| = 16 · 16 = 256`.
- *Length:* Theorem 5.4 gives `8 ∣ 16`.
∎

**Topological mirror.** On the lattice/topology side, the orthogonal sum `E8 ⊕ E8` is
the rank-`16` form that is even and unimodular, yet — by the transfer of the
evenness obstruction through the direct sum (`directSum_isEven` plus
`even_not_stdDiagonalizable`) — **not standard diagonalizable**. It is the smallest
even unimodular form clearing Rokhlin's signature-`16` hurdle while still failing
Donaldson's diagonalization, so it is not the intersection form of any smooth closed
simply-connected four-manifold. `H₁₆` is the faithful mod-2 reflection of this object:
the stability of the `8`-divisibility under gluing on the code side is the exact image
of the stability of the `E8` obstruction under connected sum on the manifold side.

---

## 9. Algorithms

We record the explicit constructive procedures underlying the verifications. All run
over the binary field; the dominant cost for self-duality checks is the `O(|candidates|
· |C| · n)` triple loop, which is why deriving `H₁₆`'s invariants structurally (rather
than enumerating `2¹⁶` vectors) is essential.

**Algorithm A (Code generation by encoding).** Given a `k × n` generator matrix `G`,
enumerate all `2ᵏ` message vectors, encode each as `c_j = ∑ᵢ aᵢ Gᵢⱼ (mod 2)`, and
collect the distinct codewords. Complexity `O(2ᵏ · k · n)`.

**Algorithm B (Self-duality test).** Given a code `C ⊆ (ZMod 2)ⁿ`, return `true` iff
for every candidate `x ∈ (ZMod 2)ⁿ`, `x ∈ C` agrees with "`x` orthogonal to all of
`C`". Complexity `O(2ⁿ · |C| · n)`.

**Algorithm C (Concatenation / direct sum).** Given `C` and `D`, return
`{ append a b : a ∈ C, b ∈ D }`. Complexity `O(|C| · |D| · (m+n))`; cardinality of the
output is exactly `|C| · |D|` (Lemma 4.4).

**Algorithm D (Gleason master-identity evaluator).** Given a doubly-even self-dual `C`
of length `n`, numerically evaluate `∑_{c ∈ C} i^{wt c}` and confirm it equals `(1+i)ⁿ`
and that `|C| = 2^{n/2}`; deduce `8 ∣ n` from the period-`8` cycle of `(1+i)`.
Complexity `O(|C| · n)`.

---

## 10. Applications and discussion

1. **Transferring obstructions.** A divisibility or non-existence result proved on one
   side of the bridge can be read off on the other. Gleason's `8 ∣ n` is the code-side
   image of the rank-`8` divisibility that underlies the `E8` obstruction in smooth
   four-manifold topology.

2. **Building flagship objects for free.** The closure theorems turn small verified
   objects into large ones with no extra computation: `H₁₆`'s four invariants follow
   from `Hamming`'s plus the general theorems, avoiding a `2¹⁶`-vector search. The same
   mechanism produces, in principle, the length-`24` doubly-even self-dual codes (the
   shadow of the Leech lattice) from smaller pieces.

3. **Stability under gluing.** The parallel additivity — connected sum on manifolds,
   concatenation on codes — shows the bridge is not merely a static dictionary but a
   *functor-like* correspondence respecting composition. The `E8 ⊕ E8` obstruction and
   the `H₁₆` length law are two faces of one stability phenomenon.

4. **A template for catalog growth.** The layered tower (mod-2 length, mod-4 length,
   mod-8 Gleason; unimodular, even unimodular, rank-`8` divisibility) gives a clean
   blueprint for adding refinements: each new code-side invariant should be sought as
   the mod-2 shadow of a lattice/topology invariant, and vice versa.

---

## 11. Future work

- **Minimum distance under concatenation.** Prove `d(C ⊕ D) = min(d C, d D)`, completing
  the metric half of the dictionary alongside the weight/cardinality half established
  here.

- **Two-variable MacWilliams and Gleason invariance.** Establish the full MacWilliams
  identity `W_{C^⊥}(X,Y) = |C|⁻¹ W_C(X+Y, X−Y)` from the `char_orthogonality` /
  `fourier_iwt` machinery, and show that a doubly-even self-dual code's weight
  enumerator is a polynomial in `X⁸ + 14X⁴Y⁴ + Y⁸` and `X⁴Y⁴(X⁴−Y⁴)⁴` (Gleason's
  invariant-theoretic theorem). The Hamming enumerator `1 + 14x⁴ + x⁸` should be a fixed
  point of the order-`8` substitution.

- **Gleason's distance bound.** Prove `d ≤ 4⌊n/24⌋ + 4` for doubly-even self-dual codes;
  the first extremal case `n = 24` is the binary Golay code, the code shadow of the
  Leech lattice.

- **Evenness-free cardinality layer.** Isolate the master identity `|C|² = 2ⁿ`,
  `2 ∣ n`, and `|C| = 2^{n/2}` for arbitrary self-dual codes, sitting below the
  doubly-even refinements, mirroring `unimodular ⊂ even unimodular`.

---

## 12. Conclusion

We have made precise, and verified, the bridge between binary self-dual codes and the
unimodular intersection forms of smooth four-manifolds, with the central new content
being **stability under gluing**: coordinate concatenation of codes mirrors connected
sum of manifolds, and the structural predicates — double-evenness, self-orthogonality,
self-duality, cardinality, and the `8`-divisibility of the length — are each preserved.
The extended Hamming `[8,4,4]` code is the mod-2 shadow of `E8`; its self-concatenation
`H₁₆` is the mod-2 shadow of the smooth-impossible form `E8 ⊕ E8`. Both `8`s — the one
governing codes and the one governing four-manifolds — are, through Construction A, the
same.
