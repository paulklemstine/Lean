# Gleason's Length Theorem via a Self-Contained Gauss-Sum / MacWilliams Argument: The Code-Side Mirror of the Rank-8 Miracle for Even Unimodular Lattices

## Abstract

We give a complete, elementary, and fully self-contained proof that every binary **doubly-even self-dual** code has length divisible by **8**. This is the sharp form of the length-divisibility constraint, refining the easier mod-4 bound. Our proof formalizes the classical Gauss-sum / MacWilliams argument entirely over the complex numbers, requiring no external invariant theory and no appeal to Gleason's classification of self-dual weight enumerators. The argument's engine is a single **master identity**, `|C| = (1+i)^n`, obtained by evaluating one double sum in two ways: once via *character orthogonality* over the self-dual (hence linear) code, and once via the per-coordinate factorization of the *discrete Fourier transform* of `x \mapsto i^{\mathrm{wt}(x)}`. The doubly-even hypothesis collapses the transform's value from `(1+i)^{n-w}(1-i)^{w}` to `(1+i)^{n}`; self-duality supplies the orthogonality. Because `|C|` is a positive real while the powers of `1+i` rotate with period 8 (`(1+i)^4 = -4`, `(1+i)^8 = 16`), positivity forces `8 \mid n`. We situate the theorem as the exact combinatorial mirror of the geometric fact that positive-definite even unimodular lattices exist only in rank divisible by 8, with the extended Hamming `[8,4,4]` code and the `E8` lattice as the minimal witnesses on each side, and we recover `8 \mid 8` for the Hamming code as a corollary of the general theorem rather than by direct computation.

**Keywords:** self-dual codes, doubly-even codes, Gleason's theorem, MacWilliams identity, Gauss sums, weight enumerators, even unimodular lattices, E8.

---

## 1. Introduction

### 1.1 The phenomenon

A binary linear code `C \subseteq \mathbb{F}_2^n` is **self-dual** if it equals its own dual `C^\perp` with respect to the standard bilinear form, and **doubly-even** if every codeword has Hamming weight divisible by 4. Such codes are central objects of combinatorial coding theory and are the discrete shadows of even unimodular lattices under reduction modulo 2. A basic structural question is: *for which lengths `n` can a doubly-even self-dual code exist?*

The answer is one of the cleanest constraints in the subject:

> **Theorem (Gleason length constraint).** If `C \subseteq \mathbb{F}_2^n` is doubly-even and self-dual, then `8 \mid n`.

The constant 8 is sharp: doubly-even self-dual codes exist precisely at the lengths `n \in \{8, 16, 24, \dots\}`, and at no others. The minimal example is the extended Hamming code `[8,4,4]`.

This statement is the exact combinatorial analogue of a celebrated theorem in the geometry of numbers:

> A positive-definite **even unimodular** lattice has rank divisible by 8.

The minimal example there is the `E8` root lattice. Under *Construction A* — which builds a lattice from a binary code by reducing coordinates modulo 2 and rescaling — "even" corresponds to "doubly-even," "unimodular" corresponds to "self-dual," and "rank divisible by 8" corresponds to "length divisible by 8." The Hamming `[8,4,4]` code is precisely the mod-2 reduction of `E8`.

### 1.2 The gap this paper closes

There are two natural divisibility statements about doubly-even self-dual codes:

- The **mod-4** bound (`4 \mid n`) is elementary: every doubly-even self-dual code contains the all-ones vector `\mathbf 1` (because, double-evenness implying even weights, `\mathbf 1` is orthogonal to every codeword and hence lies in `C^\perp = C`), and `\mathrm{wt}(\mathbf 1) = n` must itself be divisible by 4.
- The **mod-8** bound (`8 \mid n`) is the sharp, and genuinely harder, statement. It is classically obtained as a corollary of Gleason's theorem on the structure of self-dual weight enumerators, which invokes invariant theory of a finite reflection group.

This paper gives a direct, self-contained proof of the mod-8 bound that bypasses Gleason's classification entirely, using only a Gauss-sum evaluation of `\sum_{c \in C} i^{\mathrm{wt}(c)}`. The argument is constructive and elementary: every step is finite linear algebra and complex arithmetic.

### 1.3 Contributions

1. A complete proof of the mod-8 length constraint for arbitrary `n`, resting on the master identity `|C| = (1+i)^n` (Theorem 5.1).
2. A reusable MacWilliams-style infrastructure over `\mathbb{C}`: character orthogonality on self-dual codes (Theorem 4.2) and the per-coordinate Fourier factorization of `i^{\mathrm{wt}}` (Theorem 4.4), together with its doubly-even collapse (Corollary 4.5).
3. An arithmetic lemma isolating the eight-fold periodicity of the `(1+i)`-tower (Lemma 5.2), pinpointing exactly where the constant 8 originates.
4. A derivation of `8 \mid 8` for the extended Hamming code as a *corollary* of the general theorem (Corollary 6.1), mirroring how the lattice-side obstruction for `E8` is derived from evenness rather than checked by hand.

---

## 2. Preliminaries and Definitions

Throughout, `n` is a non-negative integer and we work with vectors in `\mathbb{F}_2^n`, modeled as functions `x : \{0,1,\dots,n-1\} \to \mathbb{Z}/2\mathbb{Z}`. We write `i` for the imaginary unit in `\mathbb{C}`.

**Definition 2.1 (Hamming weight).** The *Hamming weight* of `x \in \mathbb{F}_2^n` is the number of nonzero coordinates,
$$\mathrm{wt}(x) := \#\{\,j : x_j = 1\,\}.$$
Note `0 \le \mathrm{wt}(x) \le n`.

**Definition 2.2 (overlap and inner product).** The *overlap* of `x, y` is the number of positions where both are 1,
$$\mathrm{ov}(x,y) := \#\{\,j : x_j = 1 \text{ and } y_j = 1\,\},$$
and the *binary inner product* is
$$\langle x, y\rangle := \sum_{j} x_j\, y_j \in \mathbb{F}_2.$$
A coordinatewise check (`x_j y_j = 1` iff `x_j = y_j = 1`) gives the identity
$$\langle x, y\rangle = \mathrm{ov}(x,y) \bmod 2. \tag{2.1}$$

**Definition 2.3 (self-dual code).** A finite set `C \subseteq \mathbb{F}_2^n` is *self-dual* if
$$x \in C \iff \big(\forall y \in C,\ \langle x, y\rangle = 0\big). \tag{2.2}$$
That is, `C` equals its own dual. We take (2.2) as the definition; from it linearity is *derived* below (Proposition 3.1), so no separate linearity hypothesis is needed.

**Definition 2.4 (doubly-even).** A vector `v` is *doubly-even* if `4 \mid \mathrm{wt}(v)`. A code `C` is doubly-even if every `v \in C` is.

**Definition 2.5 (the sign character of `\mathbb{Z}/2`).** Define `\mathrm{sgn} : \mathbb{Z}/2 \to \mathbb{C}` by
$$\mathrm{sgn}(a) := \begin{cases} 1 & a = 0,\\ -1 & a = 1.\end{cases}$$
This is the nontrivial multiplicative character of the additive group `(\mathbb{Z}/2, +)`: it satisfies `\mathrm{sgn}(a+b) = \mathrm{sgn}(a)\,\mathrm{sgn}(b)` (immediate by the four cases) and `\mathrm{sgn}(a) = -1` whenever `a \ne 0`.

**Definition 2.6 (the bilinear character).** For `x, c \in \mathbb{F}_2^n` define
$$\mathrm{bchar}(x, c) := \prod_{j} \mathrm{sgn}(x_j c_j).$$
Since `\mathrm{sgn}` is multiplicative and `\langle x,c\rangle = \sum_j x_j c_j`, an induction over coordinates gives
$$\mathrm{bchar}(x,c) = \mathrm{sgn}\big(\langle x, c\rangle\big) = (-1)^{\langle x, c\rangle}. \tag{2.3}$$

**Definition 2.7 (the weight character).** Define `\mathrm{iwt} : \mathbb{F}_2^n \to \mathbb{C}` by
$$\mathrm{iwt}(x) := i^{\mathrm{wt}(x)}.$$
This is the per-symbol "complete weight enumerator variable" specialized to the value `i`.

---

## 3. Self-Dual Codes are Linear

The single hypothesis (2.2) already encodes linearity. We record the two facts we need.

**Proposition 3.1 (closure).** Let `C` be self-dual. Then:

1. `0 \in C`;
2. for all `a, b \in C`, `a + b \in C`.

*Proof.* (1) The zero vector satisfies `\langle 0, y\rangle = 0` for all `y`, so by (2.2) it lies in `C`. (2) By (2.2), `a, b \in C` means `\langle a, y\rangle = \langle b, y\rangle = 0` for every `y \in C`. By bilinearity of the inner product in its left argument, `\langle a + b, y\rangle = \langle a, y\rangle + \langle b, y\rangle = 0` for all `y \in C`; hence `a + b \in C` by (2.2). ∎

The bilinearity used in (2) is itself elementary: `\langle x, c + d\rangle = \sum_j x_j (c_j + d_j) = \langle x, c\rangle + \langle x, d\rangle`, and symmetrically in the left slot. Proposition 3.1 says exactly that a self-dual code is an `\mathbb{F}_2`-subspace, so `|C| = 2^{\dim C}` and, since `C = C^\perp` forces `\dim C = n/2`, we have `|C|^2 = 2^n`. We will not need this counting fact directly; it is re-derived inside the master identity.

---

## 4. Character Orthogonality and the Fourier Transform of `iwt`

### 4.1 Orthogonality over a self-dual code

**Theorem 4.2 (character orthogonality).** Let `C \subseteq \mathbb{F}_2^n` be self-dual. Then for every `x \in \mathbb{F}_2^n`,
$$\sum_{c \in C} (-1)^{\langle x, c\rangle} \;=\; \sum_{c\in C}\mathrm{bchar}(x,c) \;=\; \begin{cases} |C| & x \in C,\\ 0 & x \notin C.\end{cases}$$

*Proof.* If `x \in C`, then by self-duality `\langle x, c\rangle = 0` for every `c \in C`, so every summand `\mathrm{bchar}(x,c) = \mathrm{sgn}(0) = 1` and the sum is `|C|`.

If `x \notin C`, then by (2.2) there exists `c_0 \in C` with `\langle x, c_0\rangle \ne 0`, hence `\mathrm{sgn}(\langle x, c_0\rangle) = -1`. Let `S := \sum_{c \in C}\mathrm{bchar}(x,c)`. The map `c \mapsto c + c_0` is a bijection of `C` onto itself: it is well-defined by Proposition 3.1(2), and it is an involution because `c_0 + c_0 = 0` in characteristic 2. Re-indexing the sum by this bijection,
$$S = \sum_{c \in C}\mathrm{bchar}(x, c + c_0).$$
By (2.3) and bilinearity, `\mathrm{bchar}(x, c+c_0) = (-1)^{\langle x, c\rangle + \langle x, c_0\rangle} = (-1)^{\langle x,c\rangle}\cdot(-1)^{\langle x,c_0\rangle} = -\,\mathrm{bchar}(x,c)`. Therefore `S = -S`, whence `2S = 0` and `S = 0`. ∎

This is the standard "a nontrivial character sums to zero" argument; self-duality is exactly what makes `C` a group under addition so that the translation `c \mapsto c + c_0` is available.

### 4.2 The Fourier transform of the weight character

**Theorem 4.4 (per-coordinate Fourier factorization).** For every `y \in \mathbb{F}_2^n`,
$$\sum_{x \in \mathbb{F}_2^n} \mathrm{iwt}(x)\,(-1)^{\langle x, y\rangle} \;=\; (1+i)^{\,n - \mathrm{wt}(y)}\,(1-i)^{\,\mathrm{wt}(y)}.$$

*Proof.* Both `\mathrm{iwt}(x) = \prod_j i^{x_j}` and `(-1)^{\langle x,y\rangle} = \prod_j (-1)^{x_j y_j}` are products over coordinates, and the sum over `x \in \mathbb{F}_2^n` is a product of sums over each `x_j \in \{0,1\}` (a discrete Fubini / `\prod`-`\sum` interchange). The `j`-th factor is
$$\sum_{x_j \in \{0,1\}} i^{x_j}(-1)^{x_j y_j} = 1 + i\,(-1)^{y_j} = \begin{cases} 1 + i & y_j = 0,\\ 1 - i & y_j = 1.\end{cases}$$
There are `n - \mathrm{wt}(y)` coordinates with `y_j = 0` and `\mathrm{wt}(y)` with `y_j = 1`, giving the stated product. ∎

**Corollary 4.5 (doubly-even collapse).** If `y` is doubly-even (`4 \mid \mathrm{wt}(y)`), then
$$\sum_{x \in \mathbb{F}_2^n} \mathrm{iwt}(x)\,(-1)^{\langle x, y\rangle} = (1+i)^{\,n}.$$

*Proof.* Use the algebraic identity `1 - i = (-i)(1+i)`. Writing `w := \mathrm{wt}(y)`,
$$(1+i)^{n-w}(1-i)^{w} = (1+i)^{n-w}\,(-i)^{w}(1+i)^{w} = (1+i)^{n}\,(-i)^{w}.$$
Since `4 \mid w` and `(-i)^4 = i^4 = 1`, we get `(-i)^w = 1`, so the expression equals `(1+i)^n`. ∎

The rewriting `1 - i = (-i)(1+i)` is the device that eliminates the natural-number subtraction `n - w` from the final answer: it converts the two-factor product into `(1+i)^n` times a pure root-of-unity correction that the doubly-even hypothesis annihilates.

---

## 5. The Master Identity and the Mod-8 Theorem

### 5.1 Evaluating one double sum two ways

**Theorem 5.1 (master identity).** Let `C \subseteq \mathbb{F}_2^n` be doubly-even and self-dual, and suppose `C \ne \varnothing` (automatic, since `0 \in C` by Proposition 3.1). Then
$$|C| \;=\; (1+i)^{\,n} \quad \text{in } \mathbb{C}.$$

*Proof.* Consider the double sum
$$D := \sum_{x \in \mathbb{F}_2^n} \mathrm{iwt}(x) \sum_{c \in C} (-1)^{\langle x, c\rangle}.$$

**Evaluation A (inner sum first, over `c`).** By character orthogonality (Theorem 4.2), the inner sum is `|C|` when `x \in C` and `0` otherwise. Hence
$$D = |C|\sum_{x \in C}\mathrm{iwt}(x) = |C|\sum_{x \in C} i^{\mathrm{wt}(x)}.$$
Since `C` is doubly-even, each `\mathrm{wt}(x)` is a multiple of 4, so `i^{\mathrm{wt}(x)} = 1`, and `\sum_{x\in C} i^{\mathrm{wt}(x)} = |C|`. Therefore
$$D = |C|^2.$$

**Evaluation B (interchange order, sum over `x` first).** Swapping the two finite sums,
$$D = \sum_{c \in C}\ \sum_{x \in \mathbb{F}_2^n} \mathrm{iwt}(x)(-1)^{\langle x, c\rangle}.$$
For each `c \in C`, `c` is doubly-even, so by Corollary 4.5 the inner sum equals `(1+i)^n`. Hence
$$D = \sum_{c \in C}(1+i)^n = |C|\,(1+i)^n.$$

Equating the two evaluations, `|C|^2 = |C|\,(1+i)^n`. Since `|C| \ge 1 \ne 0` (the code contains `0`), we may divide by `|C|` to obtain `|C| = (1+i)^n`. ∎

The identity is the computational heart of the theorem and is reusable: it holds for *any* doubly-even self-dual code and is the finite avatar of the lattice theta-function transformation.

### 5.2 The eight-fold tower

**Lemma 5.2 (positivity forces divisibility by 8).** If `(1+i)^n` is a positive real number, then `8 \mid n`.

*Proof.* Compute the powers of `1+i` along the residues of `n` modulo 8. Since `(1+i)^2 = 2i` and `(1+i)^4 = (2i)^2 = -4`, while `(1+i)^8 = (-4)^2 = 16`, the value `(1+i)^n` factors as `\big((1+i)^8\big)^{\lfloor n/8\rfloor}\cdot (1+i)^{\,n \bmod 8} = 16^{\lfloor n/8\rfloor}\cdot(1+i)^{\,n \bmod 8}`. The factor `16^{\lfloor n/8\rfloor}` is a positive real, so `(1+i)^n` is a positive real iff `(1+i)^{\,n \bmod 8}` is. Tabulating the eight residues:

| `r = n \bmod 8` | `(1+i)^r` | positive real? |
|---|---|---|
| 0 | `1` | yes |
| 1 | `1+i` | no |
| 2 | `2i` | no |
| 3 | `-2+2i` | no |
| 4 | `-4` | no (negative) |
| 5 | `-4-4i` | no |
| 6 | `-8i` | no |
| 7 | `8-8i` | no |

Only `r = 0` yields a positive real. Hence `n \bmod 8 = 0`, i.e. `8 \mid n`. ∎

Geometrically, `1+i = \sqrt 2\, e^{i\pi/4}`, so `(1+i)^n = 2^{n/2} e^{i\pi n/4}`; this lies on the positive real axis precisely when `\pi n/4` is a multiple of `2\pi`, i.e. `8 \mid n`. The modulus `2^{n/2}` recovers the self-dual cardinality `|C| = 2^{n/2}`.

### 5.3 Main theorem

**Theorem 5.3 (Gleason length constraint, mod-8).** Every binary doubly-even self-dual code `C \subseteq \mathbb{F}_2^n` has `8 \mid n`.

*Proof.* By Theorem 5.1, `|C| = (1+i)^n`. The left-hand side `|C|` is a positive integer (the code is nonempty, containing `0`), hence a positive real. By Lemma 5.2, `8 \mid n`. ∎

---

## 6. The Extended Hamming Code as Minimal Witness

We instantiate the general theorem on the smallest doubly-even self-dual code, the extended Hamming code `[8,4,4]` (equivalently the Reed–Muller code `RM(1,3)`), the mod-2 shadow of the `E8` lattice.

**Definition 6.1 (the code).** Let `G` be the `4 \times 8` generator matrix
$$G = \begin{pmatrix} 1&1&1&1&1&1&1&1\\ 0&0&0&0&1&1&1&1\\ 0&0&1&1&0&0&1&1\\ 0&1&0&1&0&1&0&1 \end{pmatrix},$$
the all-ones row together with the three coordinate "address-bit" functions. The Hamming code `H` is the image of the encoder `a \mapsto a G`, a set of `16 = 2^4` codewords of length 8.

The following properties hold (each verifiable by finite enumeration of the 16 codewords):

- **Self-dual:** `x \in H \iff \forall y \in H, \langle x, y\rangle = 0`.
- **Doubly-even:** every codeword has weight in `\{0,4,8\}`, all multiples of 4.
- **Distance spectrum / weight enumerator:** exactly 1 word of weight 0, 14 of weight 4, and 1 of weight 8, giving the enumerator `W_H(x) = 1 + 14x^4 + x^8` and minimum distance `d = 4`. These account for all `1 + 14 + 1 = 16` codewords.

**Corollary 6.1 (`8 \mid 8` from the general theorem).** Applying Theorem 5.3 to `H`, which is doubly-even and self-dual, yields `8 \mid 8`.

The point of stating `8 \mid 8` as a corollary of the *general* theorem — rather than checking it by hand — is structural: it mirrors how, on the lattice side, the rank obstruction for `E8` is *derived* from evenness and unimodularity, not verified directly. The general mechanism and its minimal instance are thereby made to coincide.

---

## 7. The Lattice Mirror

The mod-8 length constraint is the combinatorial reflection of a foundational theorem in the geometry of numbers.

**Definitions.** A lattice `\Lambda \subseteq \mathbb{R}^m` is *integral* if `\langle u, v\rangle \in \mathbb{Z}` for all `u, v \in \Lambda`; *even* if `\langle v, v\rangle \in 2\mathbb{Z}` for all `v`; and *unimodular* if its fundamental domain has volume 1 (equivalently `\Lambda = \Lambda^*`, the dual lattice). It is *positive-definite* if the ambient form is.

**Theorem (lattice rank-8 miracle).** A positive-definite even unimodular lattice has rank divisible by 8.

**The dictionary (Construction A).** Reduction modulo 2 sends an even unimodular lattice to a doubly-even self-dual binary code:

| Lattice notion | Code notion |
|---|---|
| even (`\langle v,v\rangle \in 2\mathbb{Z}`) | doubly-even (`4 \mid \mathrm{wt}`) |
| unimodular / self-dual (`\Lambda = \Lambda^*`) | self-dual (`C = C^\perp`) |
| rank `m` | length `n` |
| rank divisible by 8 | length divisible by 8 |
| theta function `\Theta_\Lambda(\tau)` | Gauss sum `\sum_c i^{\mathrm{wt}(c)}` |
| `E8` lattice (rank 8) | extended Hamming `[8,4,4]` |

Both theorems are proved by exhibiting a quantity (the theta function, respectively the Gauss sum) that is simultaneously forced to be a positive real and to lie on an eight-fold-periodic tower. On the lattice side the periodicity comes from the modular transformation law of theta functions under `SL_2(\mathbb{Z})` and the value of a Gauss sum; on the code side it comes, transparently, from the eight powers of `1+i`. Our Theorem 5.1 is the finite, elementary incarnation of that transformation law.

---

## 8. Algorithms

Two finite algorithms underlie the development. The first verifies the hypotheses of the main theorem for an explicit code; the second is the constructive Gauss-sum evaluation that the proof formalizes.

**Algorithm A — Self-duality and double-evenness verification.** Given a generating set, enumerate the linear span `C` (closure under `+`), then (i) check `4 \mid \mathrm{wt}(v)` for every `v \in C`; (ii) check `C = C^\perp` by confirming that for each candidate `x \in \mathbb{F}_2^n`, membership `x \in C` coincides with orthogonality to all of `C`. Complexity: span enumeration is `O(2^k \cdot n)` for dimension `k`; the duality check is `O(2^n \cdot |C| \cdot n)` in the naive form (feasible for the `[8,4,4]` code), or `O(|C|^2 \cdot n)` if one only verifies self-*orthogonality* and uses the cardinality count `|C| = 2^{n/2}`.

**Algorithm B — Master-identity Gauss-sum evaluation.** Directly compute `\sum_{c \in C} i^{\mathrm{wt}(c)}` (which equals `|C|` for doubly-even `C`) and, independently, `(1+i)^n`, and confirm the master identity `|C| = (1+i)^n`. Then read off `n \bmod 8` from the requirement that `(1+i)^n` be a positive real. Complexity: `O(|C| \cdot n)` for the Gauss sum and `O(\log n)` for the power.

---

## 9. Discussion

**What each hypothesis does.** The proof exposes the role of each ingredient with unusual clarity. *Self-duality* is what makes `C` a *group* under addition, enabling the translation `c \mapsto c + c_0` that drives character orthogonality (Theorem 4.2); without it the Fourier inversion has no clean form. *Double-evenness* is what collapses the Fourier transform value from `(1+i)^{n-w}(1-i)^w` to the single power `(1+i)^n` (Corollary 4.5), pinning `|C|` onto the `(1+i)`-tower. The two hypotheses conspire to place a positive real number on a complex tower whose period is 8.

**Sharpness.** The argument is sharp because it identifies the *exact* obstruction: `(1+i)^n` is a positive real iff `8 \mid n`. The weaker mod-4 bound corresponds to discarding phase information and retaining only `(1+i)^4 = -4` (a real, though negative); insisting on *positivity* is what upgrades 4 to 8.

**Avoiding invariant theory.** The classical route to the mod-8 bound passes through Gleason's theorem, which describes the ring of self-dual weight enumerators as invariants of a finite complex reflection group of order 192, with the order-8 generator `1 + 14x^4 + x^8` (the Hamming enumerator!) as a fundamental invariant. Our Gauss-sum argument extracts only the single numerical consequence we need — the divisibility of the length — without constructing the invariant ring, making it entirely elementary and self-contained.

**Reusability.** Theorem 5.1 (`|C| = (1+i)^n`) and the MacWilliams infrastructure (Theorems 4.2, 4.4, Corollary 4.5) are general tools. The same double-sum technique, with `i` replaced by other roots of unity, yields constraints for other families (e.g. lengths divisible by 24 for extremal codes, when combined with weight-spectrum input), and over `\mathbb{F}_4` or with Lee weights for the lattice families `E8 \oplus E8` versus `D_{16}^+` in rank 16.

---

## 10. Future Directions

The development sits inside a larger program building the smooth/topological gap in dimension 4 from two parallel towers: a **lattice tower** (even unimodular forms `E8`, `E8 \oplus E8`, the Donaldson diagonalizability obstruction, and the rank-divisible-by-8 miracle) and a **code tower** (the doubly-even self-dual `[8,4,4]` Hamming code, the doubly-even ⟹ self-orthogonal bridge, the weight enumerator `1 + 14x^4 + x^8`, and length divisibility). The mod-8 theorem of this paper is the sharp code-side mirror of the lattice statement, with `E8 \leftrightarrow \text{Hamming}[8,4,4]` the minimal witnesses on each side.

Promising next steps:

1. **Rank-16 fingerprinting.** Use the master identity and weight-enumerator data to distinguish the two even unimodular rank-16 lattices `E8 \oplus E8` and `D_{16}^+`, which share the same theta function up to low order but differ in finer arithmetic — the combinatorial avatar of the "fine arithmetic" distinguishing smooth structures.

2. **Length-24 and extremal codes.** Extend the Gauss-sum method, with higher roots of unity and minimum-distance input, toward the divisibility and structure of extremal doubly-even self-dual codes (the Golay code at length 24, mirror of the Leech lattice).

3. **Modular-form bridge.** Make precise the correspondence between the finite Gauss sum `\sum_c i^{\mathrm{wt}(c)}` and the lattice theta function `\Theta_\Lambda`, exhibiting the `(1+i)`-tower periodicity as the elementary shadow of the modular transformation law.

4. **Higher MacWilliams machinery.** Generalize the per-coordinate Fourier factorization to complete and joint weight enumerators, providing reusable infrastructure for the full theory of self-dual codes over `\mathbb{Z}/2`, `\mathbb{Z}/4`, and `\mathbb{F}_4`.

---

## 11. Conclusion

We have given a complete, elementary, self-contained proof that doubly-even self-dual binary codes have length divisible by 8. The proof reduces the entire phenomenon to a single transparent identity, `|C| = (1+i)^n`, and an eight-fold periodicity in the complex plane. It bypasses Gleason's invariant-theoretic classification, isolates the precise role of each hypothesis, and exhibits the theorem as the exact combinatorial mirror of the rank-8 miracle for even unimodular lattices — with the extended Hamming code and the `E8` lattice as the twin minimal witnesses. The number 8, appearing on both sides of the lattice/code dictionary, is revealed to be one and the same law: the period of a 45-degree rotation in `\mathbb{C}`.
