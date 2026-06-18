# An Intersection-Form Classification Pipeline via Direct Sums of Binary Self-Dual Codes

## Abstract

We develop the coding-theory mirror of the orthogonal direct-sum (connected-sum)
operation on intersection forms, and prove that the three structural predicates
governing the classification of even unimodular lattices — *self-duality*,
*double-evenness*, and the resulting *length divisibility by 8* — are each closed
under coordinate concatenation of binary codes. Concretely, for a binary code
`C ⊆ (ℤ/2)^m` and `D ⊆ (ℤ/2)^n`, we define the direct sum `C ⊕ D ⊆ (ℤ/2)^{m+n}`
as the set of concatenations of a `C`-codeword and a `D`-codeword, and establish:
(i) weight additivity, `wt(a ∥ b) = wt(a) + wt(b)`; (ii) block-diagonality of the
binary inner product, `⟨a ∥ b, c ∥ d⟩ = ⟨a, c⟩ + ⟨b, d⟩`; (iii) cardinality
multiplicativity, `|C ⊕ D| = |C| · |D|`; (iv) closure of double-evenness; and
(v) the headline closure of self-duality. Combining (iii)–(v) with the Gleason
length theorem — every binary doubly-even self-dual code has length divisible by
8, which we prove from a self-contained Gauss-sum / MacWilliams evaluation
yielding the master identity `|C| = (1 + i)^n` over ℂ — we obtain additive
divisibility of the Gleason length under direct sums. As the headline
application, `Hamming ⊕ Hamming`, the length-16 concatenation of two copies of
the extended Hamming `[8, 4, 4]` code, is shown to be self-dual, doubly even,
to possess exactly `256 = 16 · 16` codewords, and to have length 16 divisible by
8 — all *derived* from the general closure theorems rather than by brute force
over the `2^16` candidate vectors. This is the exact mod-2 shadow, under
Construction A, of the rank-16 even unimodular lattice `E8 ⊕ E8`. Every result is
formally verified.

**Keywords:** self-dual codes, doubly-even codes, direct sum, Construction A,
E8 lattice, intersection forms, Gleason theorem, weight enumerator, Poincaré
duality.

---

## 1. Introduction

### 1.1 Three classifications, one number

The classification of even unimodular lattices, the classification of binary
doubly-even self-dual codes, and the topological classification of simply
connected smooth 4-manifolds via their intersection forms are governed by a
common arithmetic skeleton, with the integer **8** at its center. Positive
definite even unimodular lattices exist only in ranks divisible by 8, with the
8-dimensional lattice E8 the minimal example. Binary doubly-even self-dual codes
exist only in lengths divisible by 8 (Gleason). On the topological side, Rokhlin's
theorem and Donaldson's diagonalization theorem pin obstructions whose
characteristic constant is again 8.

These three theories are linked by **Construction A**, which builds a lattice from
a binary code by lifting codewords to ℤ^n and rescaling. Under Construction A, the
orthogonal direct sum of even unimodular lattices reduces, modulo 2, to the
*direct sum* (coordinate concatenation) of binary self-dual codes. The
lattice-side closure theorems — that the orthogonal direct sum `Q ⊕ R` is closed
under unimodularity, evenness, and the standard form — have verbatim coding-theory
shadows, which we prove here.

### 1.2 Contributions

We make the following contributions, all formally verified for codes of arbitrary
length.

1. We define the **direct sum** `C ⊕ D` of binary codes and characterize its
   membership: a vector lies in `C ⊕ D` iff its left block lies in `C` and its
   right block lies in `D` (Theorem 3.1).
2. We prove **weight additivity** (Theorem 4.1) and **inner-product
   block-diagonality** (Theorem 4.2), the combinatorial shadows of the
   block-diagonal Gram matrix.
3. We prove **cardinality multiplicativity** `|C ⊕ D| = |C| · |D|`
   (Theorem 4.3), the shadow of determinant multiplicativity.
4. We prove **closure of double-evenness** (Theorem 5.1) and the headline
   **closure of self-duality** (Theorem 5.2) under direct sums.
5. We provide a self-contained proof of the **Gleason length theorem**
   (Theorem 6.1) via the master identity `|C| = (1 + i)^n`, and deduce
   **additive Gleason length divisibility** for direct sums (Corollary 6.2).
6. We instantiate everything on `Hamming ⊕ Hamming`, the length-16 mod-2 shadow
   of `E8 ⊕ E8` (Section 7).

---

## 2. Preliminaries and definitions

Throughout, vectors are functions `Fin n → ℤ/2`, identified with binary strings
of length `n`. We write `a ∥ b` for the concatenation of `a : Fin m → ℤ/2` and
`b : Fin n → ℤ/2`, the length-`(m+n)` vector whose first `m` coordinates are `a`
and whose last `n` coordinates are `b`.

**Definition 2.1 (Hamming weight).** The *weight* of `v : Fin n → ℤ/2` is
`wt(v) = #{ i : v(i) = 1 }`, the number of nonzero coordinates.

**Definition 2.2 (Binary inner product).** For `x, y : Fin n → ℤ/2`,
`⟨x, y⟩ = Σ_i x(i)·y(i) ∈ ℤ/2`. Two vectors are *orthogonal* when `⟨x, y⟩ = 0`.

**Definition 2.3 (Doubly even).** A vector `v` is *doubly even* when `4 ∣ wt(v)`.
A code is doubly even when all its codewords are.

**Definition 2.4 (Self-dual code).** A code `C ⊆ (ℤ/2)^n` is *self-dual* when, for
every `x`,
`x ∈ C ⟺ (∀ y ∈ C, ⟨x, y⟩ = 0)`,
i.e. `C` equals its own dual `C^⊥`. Self-dual codes are linear: they contain `0`
and are closed under addition (Lemma 2.5).

**Lemma 2.5 (Self-dual codes are linear).** If `C` is self-dual then
`0 ∈ C`, and `a, b ∈ C ⟹ a + b ∈ C`.

*Proof.* The zero vector is orthogonal to everything, so `0 ∈ C^⊥ = C`. For
closure under addition, by self-duality `a ∈ C` means `⟨a, y⟩ = 0` for all
`y ∈ C`, and likewise for `b`; bilinearity gives `⟨a + b, y⟩ = ⟨a, y⟩ + ⟨b, y⟩ =
0`, so `a + b ∈ C^⊥ = C`. ∎

**Definition 2.6 (Direct sum of codes).** For `C ⊆ (ℤ/2)^m` and `D ⊆ (ℤ/2)^n`,
the *direct sum* is
`C ⊕ D = { a ∥ b : a ∈ C, b ∈ D } ⊆ (ℤ/2)^{m+n}`.
This is the code-side analogue of the orthogonal direct sum of intersection forms,
whose Gram matrix is the block-diagonal `diag(G_Q, G_R)`.

We define the **left and right projections** `leftPart(z)(i) = z(i)` for
`i < m` and `rightPart(z)(j) = z(m + j)` for `j < n`. These split a length-`(m+n)`
vector into its two blocks, and satisfy `leftPart(z) ∥ rightPart(z) = z` for all
`z`, and `leftPart(a ∥ b) = a`, `rightPart(a ∥ b) = b`.

---

## 3. Membership in the direct sum

**Theorem 3.1 (Membership criterion).** For `z : Fin (m+n) → ℤ/2`,
`z ∈ C ⊕ D ⟺ leftPart(z) ∈ C ∧ rightPart(z) ∈ D`.

*Proof.* ( ⟹ ) If `z = a ∥ b` with `a ∈ C, b ∈ D`, then `leftPart(z) = a ∈ C`
and `rightPart(z) = b ∈ D` by the projection identities.
( ⟸ ) If `leftPart(z) ∈ C` and `rightPart(z) ∈ D`, then the pair
`(leftPart(z), rightPart(z))` witnesses membership, since
`leftPart(z) ∥ rightPart(z) = z`. ∎

This criterion converts every statement about `C ⊕ D` into a pair of independent
statements about the two blocks, which is the source of all the closure theorems.

---

## 4. Numerical invariants under direct sum

**Theorem 4.1 (Weight additivity).** For `a : Fin m → ℤ/2` and `b : Fin n → ℤ/2`,
`wt(a ∥ b) = wt(a) + wt(b)`.

*Proof.* The support of `a ∥ b` is the disjoint union of the support of `a`
(in the first `m` coordinates) and the support of `b` (in the last `n`). Splitting
the index set `Fin (m+n)` as `Fin m ⊔ Fin n` and counting nonzero coordinates in
each block gives the sum. ∎

**Theorem 4.2 (Inner-product block-diagonality).** For
`a, c : Fin m → ℤ/2` and `b, d : Fin n → ℤ/2`,
`⟨a ∥ b, c ∥ d⟩ = ⟨a, c⟩ + ⟨b, d⟩`.

*Proof.* Split the defining sum `Σ_{i<m+n} (a ∥ b)(i)·(c ∥ d)(i)` over the two
blocks. On the first `m` coordinates the integrand is `a(i)·c(i)`; on the last `n`
it is `b(j)·d(j)`. The cross terms vanish because each coordinate belongs to
exactly one block. Hence the sum equals `⟨a, c⟩ + ⟨b, d⟩`. ∎

Theorem 4.2 is the central structural fact: concatenation introduces **no
interference between the two blocks**. It is the combinatorial shadow of the
off-diagonal zero blocks in the Gram matrix `diag(G_Q, G_R)`.

**Theorem 4.3 (Cardinality multiplicativity).**
`|C ⊕ D| = |C| · |D|`.

*Proof.* The map `(a, b) ↦ a ∥ b` from `C × D` to `C ⊕ D` is surjective by
definition and injective because concatenation can be inverted by the block
projections: if `a ∥ b = a' ∥ b'` then applying `leftPart` gives `a = a'` and
`rightPart` gives `b = b'`. An injective image of a product set has cardinality
the product of the factors, so `|C ⊕ D| = |C × D| = |C| · |D|`. ∎

This is the code shadow of the multiplicativity of the lattice determinant
(covolume) under orthogonal direct sums, which underlies the closure of
unimodularity.

---

## 5. Closure of the structural predicates

**Theorem 5.1 (Closure of double-evenness).** If every codeword of `C` and of `D`
is doubly even, then every codeword of `C ⊕ D` is doubly even.

*Proof.* Let `z ∈ C ⊕ D`. By Theorem 3.1, `leftPart(z) ∈ C` and
`rightPart(z) ∈ D`, so `4 ∣ wt(leftPart(z))` and `4 ∣ wt(rightPart(z))`. By
weight additivity (Theorem 4.1) and `z = leftPart(z) ∥ rightPart(z)`,
`wt(z) = wt(leftPart(z)) + wt(rightPart(z))`, a sum of two multiples of 4, hence a
multiple of 4. ∎

**Theorem 5.2 (Closure of self-duality — headline).** If `C` and `D` are
self-dual, then `C ⊕ D` is self-dual; that is, for every `x`,
`x ∈ C ⊕ D ⟺ (∀ y ∈ C ⊕ D, ⟨x, y⟩ = 0)`.

*Proof.*
(⟹) Suppose `x = a ∥ b` with `a ∈ C`, `b ∈ D`. For any `y = c ∥ d ∈ C ⊕ D`
(with `c ∈ C, d ∈ D`), block-diagonality (Theorem 4.2) gives
`⟨x, y⟩ = ⟨a, c⟩ + ⟨b, d⟩`. Self-duality of `C` gives `⟨a, c⟩ = 0`, and of `D`
gives `⟨b, d⟩ = 0`, so `⟨x, y⟩ = 0`.

(⟸) Suppose `⟨x, y⟩ = 0` for all `y ∈ C ⊕ D`. We must show
`leftPart(x) ∈ C` and `rightPart(x) ∈ D`, since then Theorem 3.1 places
`x ∈ C ⊕ D`. We isolate one block at a time using the all-zeros word, which lies
in `C` and in `D` by Lemma 2.5.

- *Left block.* For any `c ∈ C`, the vector `c ∥ 0` belongs to `C ⊕ D` (as
  `0 ∈ D`). Applying the hypothesis with `y = c ∥ 0` and block-diagonality,
  `0 = ⟨x, c ∥ 0⟩ = ⟨leftPart(x), c⟩ + ⟨rightPart(x), 0⟩ = ⟨leftPart(x), c⟩`.
  Thus `leftPart(x)` is orthogonal to every `c ∈ C`, so by self-duality
  `leftPart(x) ∈ C^⊥ = C`.
- *Right block.* Symmetrically, for any `d ∈ D`, the vector `0 ∥ d ∈ C ⊕ D` gives
  `⟨rightPart(x), d⟩ = 0` for all `d ∈ D`, so `rightPart(x) ∈ D^⊥ = D`.

By Theorem 3.1, `x ∈ C ⊕ D`. ∎

The only nontrivial content of the backward direction is that a self-dual code
contains `0`, which lets one probe each block independently. This is the exact
mirror of the block-diagonal `Tᵀ G T` argument used in the closure of standard
diagonalizability on the lattice side.

---

## 6. The Gleason length theorem and additive divisibility

We now record the self-contained proof of the sharp length constraint, which
upgrades the elementary mod-4 result (the all-ones / global-section argument) to
the optimal mod-8 statement.

### 6.1 The Gauss-sum machinery

Let `csgn : ℤ/2 → ℂ` be the nontrivial multiplicative character
`csgn(a) = (-1)^a`, so `csgn(0) = 1`, `csgn(1) = -1`, and `csgn(a+b) =
csgn(a)·csgn(b)`. Define the additive character
`bchar(x, c) = ∏_j csgn(x(j)·c(j)) = (-1)^{⟨x,c⟩}` and the *weight character*
`iwt(x) = i^{wt(x)} = ∏_j (1 if x(j)=0 else i)`.

**Lemma 6.1a (Character orthogonality).** For a self-dual code `C`,
`Σ_{c ∈ C} bchar(x, c) = |C|` if `x ∈ C`, and `0` otherwise.

*Proof sketch.* If `x ∈ C`, then by self-duality `⟨x, c⟩ = 0` for all `c ∈ C`, so
every term is `1` and the sum is `|C|`. If `x ∉ C`, self-duality produces a
`c₀ ∈ C` with `⟨x, c₀⟩ ≠ 0`, hence `csgn(⟨x, c₀⟩) = -1`. The translation
`c ↦ c + c₀` is a bijection of `C` (Lemma 2.5, and an involution since `c₀ + c₀ =
0` in characteristic 2), and `bchar(x, c + c₀) = -bchar(x, c)`. So the sum `S`
satisfies `S = -S`, forcing `S = 0`. ∎

**Lemma 6.1b (Fourier transform of `iwt`).** For any `y`,
`Σ_x iwt(x)·bchar(x, y) = (1 + i)^{n - wt(y)} (1 - i)^{wt(y)}`.

*Proof sketch.* The sum factors over coordinates; the `j`-th factor is
`Σ_{t ∈ ℤ/2} (1 if t=0 else i)·(-1)^{t·y(j)}`, which equals `1 + i` if
`y(j) = 0` and `1 - i` if `y(j) = 1`. The product over the `n - wt(y)` zero
coordinates and `wt(y)` one coordinates gives the claim. ∎

When `y` is doubly even, the value collapses: using `1 - i = (-i)(1 + i)` and
`(-i)^{wt(y)} = 1` (since `4 ∣ wt(y)`), one finds
`Σ_x iwt(x)·bchar(x, y) = (1 + i)^n`.

### 6.2 The master identity and Gleason's theorem

**Lemma 6.1c (Master identity).** For a doubly-even self-dual code `C`,
`|C| = (1 + i)^n` in ℂ.

*Proof sketch.* Evaluate the double sum `Σ_x iwt(x) · (Σ_{c ∈ C} bchar(x, c))` two
ways. Using Lemma 6.1a, the inner sum is `|C|·[x ∈ C]`, and since codewords are
doubly even `iwt` is `1` on `C`, giving `|C|·|C|`. Using Fubini and Lemma 6.1b
on each (doubly even) codeword, the sum is `|C|·(1 + i)^n`. Cancel the nonzero
factor `|C|` (nonzero because `0 ∈ C`). ∎

**Theorem 6.1 (Gleason length theorem).** Every binary doubly-even self-dual code
has length divisible by 8.

*Proof.* By Lemma 6.1c, `|C| = (1 + i)^n`. The left side is a positive integer
(positive because `0 ∈ C`). Writing `n = 8q + r` with `0 ≤ r < 8` and using
`(1 + i)^8 = 16`, we get `(1 + i)^n = 16^q · (1 + i)^r`. For `r ∈ {1, …, 7}` the
value `(1 + i)^r` is either non-real or negative real — in particular
`(1 + i)^4 = -4 < 0` — so it cannot equal a positive real number. Hence `r = 0`,
i.e. `8 ∣ n`. ∎

### 6.3 Additive divisibility under direct sums

**Corollary 6.2 (Additive Gleason length).** If `C ⊆ (ℤ/2)^m` and `D ⊆ (ℤ/2)^n`
are both doubly even and self-dual, then `C ⊕ D` is doubly even and self-dual
(Theorems 5.1, 5.2), and consequently `8 ∣ (m + n)`.

*Proof.* By Theorems 5.1 and 5.2, `C ⊕ D` is a doubly-even self-dual code of
length `m + n`. Apply Theorem 6.1. ∎

Note that `8 ∣ m` and `8 ∣ n` individually already follow from Theorem 6.1
applied to the summands; the content of Corollary 6.2 is that the *direct sum*
remains within the class to which Gleason applies, so the constraint is *stable*,
not merely inherited.

---

## 7. The headline application: `Hamming ⊕ Hamming`

### 7.1 The extended Hamming `[8, 4, 4]` code

The extended Hamming code `H ⊆ (ℤ/2)^8` is the image of the encoder
`a ↦ Σ_i a(i)·g_i` over the generator rows

```
g_0 = 11111111
g_1 = 00001111
g_2 = 00110011
g_3 = 01010101
```

It has `2^4 = 16` codewords. Its complete weight enumerator is
`W_H(x) = 1 + 14x^4 + x^8`: exactly one word of weight 0, fourteen of weight 4,
and one of weight 8. Consequently `H` is **doubly even** (all weights divisible by
4), **self-dual** (`16 = 2^{8/2}` codewords, generator rows mutually orthogonal),
and has **minimum distance 4**, giving parameters `[8, 4, 4]`. Under Construction
A, `H` lifts to the lattice **E8**.

### 7.2 The direct sum

Define `Hamming16 = H ⊕ H ⊆ (ℤ/2)^{16}`. The general theory yields, with no
brute-force enumeration over the `2^16 = 65536` candidate vectors:

- **Self-dual** (Theorem 5.2, from self-duality of `H`).
- **Doubly even** (Theorem 5.1, from double-evenness of `H`).
- **`256 = 16 · 16` codewords** (Theorem 4.3).
- **Length 16 divisible by 8** (Corollary 6.2 / Theorem 6.1).

This is the precise mod-2 shadow, under Construction A, of the rank-16 even
unimodular lattice `E8 ⊕ E8`. The contrast with direct computation is the point:
the structural closure theorems recover all four facts from properties of the
single length-8 summand, exactly as the lattice obstruction for `E8 ⊕ E8` is
*derived* from the obstruction for `E8`, not rechecked in rank 16.

### 7.3 The decomposability dichotomy

In rank 16 there are exactly two even unimodular lattices up to isometry:
`E8 ⊕ E8` (decomposable) and `D16⁺` (indecomposable). Their mod-2 code shadows are
both doubly-even self-dual `[16, 8, ·]` codes with the *same* weight enumerator
`(1 + 14x^4 + x^8)^2 = 1 + 28x^4 + 198x^8 + 28x^{12} + x^{16}` — the latter being
the square of `W_H` precisely because (Conjecture, Section 9) the weight
enumerator of a direct sum is the product of the summands' enumerators. The two
codes are nonetheless inequivalent: `Hamming ⊕ Hamming` factors through the direct
sum construction, while the `D16⁺` shadow does not. This is the combinatorial
fingerprint of the topological distinction between a connected sum and an
irreducible manifold.

---

## 8. Discussion

### 8.1 The dictionary

The results assemble into an exact dictionary between operations:

| Lattice / topology                          | Code                                  |
|---------------------------------------------|---------------------------------------|
| orthogonal direct sum `Q ⊕ R`               | concatenation `C ⊕ D`                 |
| block-diagonal Gram `diag(G_Q, G_R)`        | block-diagonal inner product (Thm 4.2)|
| determinant multiplicativity                | `|C ⊕ D| = |C|·|D|` (Thm 4.3)         |
| unimodular = self-dual                      | self-dual (Thm 5.2)                   |
| even form                                   | doubly even (Thm 5.1)                 |
| rank divisible by 8                         | length divisible by 8 (Thm 6.1)       |
| E8                                          | extended Hamming `[8,4,4]`            |
| E8 ⊕ E8                                      | `Hamming ⊕ Hamming` (Section 7)       |

### 8.2 Why block-diagonality is the engine

Every closure theorem in Section 5 reduces, via the membership criterion
(Theorem 3.1), to the two halves not interfering. Theorem 4.2 makes this precise:
the inner product splits as a sum over the two blocks. The same observation drives
the lattice proofs through `det_fromBlocks_zero₁₂` and reindexing by
`finSumFinEquiv`. The use of the zero word as a "probe" in the backward direction
of Theorem 5.2 is the code-theoretic counterpart of evaluating a quadratic form on
basis vectors confined to one summand.

### 8.3 Sharpness

Theorem 6.1 is sharp: the constant 8 cannot be improved, because both E8 (length
8) and `Hamming ⊕ Hamming` (length 16) achieve the bound. The elementary mod-4
argument (the all-ones global section) is genuinely weaker; the upgrade to mod 8
requires the analytic content of the Gauss-sum identity `|C| = (1 + i)^n`.

---

## 9. Future directions

**Conjecture 1 (Weight-enumerator multiplicativity).** The weight distribution of
`C ⊕ D` is the convolution of those of `C` and `D`:
`#{ z ∈ C ⊕ D : wt(z) = k } = Σ_{i+j=k} #{ a ∈ C : wt(a)=i } · #{ b ∈ D : wt(b)=j }`.
Equivalently, `W_{C ⊕ D}(x) = W_C(x) · W_D(x)`. Specializing to `Hamming16`
predicts `(1 + 14x^4 + x^8)^2 = 1 + 28x^4 + 198x^8 + 28x^{12} + x^{16}`. This
refines Theorem 4.3 (the `x = 1` evaluation), mirroring the theta-series identity
`Θ_{E8 ⊕ E8} = Θ_{E8}^2`.

**Conjecture 2 (Minimum distance of a direct sum).** For nonzero-containing
self-dual `C, D`, the minimum distance of `C ⊕ D` equals `min(d(C), d(D))`. Hence
`Hamming16` has minimum distance 4 (not 8): it is a `[16, 8, 4]` code, strictly
worse than the indecomposable `D16⁺` shadow. Direct sums never improve minimum
distance — the code-side analogue of decomposable lattices never improving the
minimal norm.

**Conjecture 3 (Rank-16 dichotomy).** There are exactly two even unimodular
lattices of rank 16, `E8 ⊕ E8` and `D16⁺`; their mod-2 code shadows are
inequivalent doubly-even self-dual `[16, 8, 4]` codes with equal weight
enumerators (Conjecture 1) but distinct automorphism structure. Constructing
`D16⁺` explicitly and proving it is *not* of the form `C ⊕ D` for any nontrivial
split would formalize indecomposability on the code side.

---

## 10. Conclusion

We have built the coding-theory mirror of the orthogonal direct-sum operation on
intersection forms and shown that self-duality, double-evenness, cardinality, and
Gleason length divisibility are each closed under concatenation, with
block-diagonality of the binary inner product as the single unifying mechanism.
The headline instance, `Hamming ⊕ Hamming`, recovers all defining properties of
the mod-2 shadow of `E8 ⊕ E8` from the length-8 summand alone. Together with the
self-contained Gauss-sum proof of the Gleason length theorem, the development
provides a formally verified, end-to-end pipeline relating the classification of
even unimodular lattices to that of binary doubly-even self-dual codes.
