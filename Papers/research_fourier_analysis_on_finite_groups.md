# Fourier Analysis on Finite Cyclic Groups: Convolution, Plancherel, and the Spectral Formula for Additive Energy

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Algebra / Additive Combinatorics (Fourier analysis on finite abelian groups)

---

## Abstract

We develop a self-contained toolkit for discrete Fourier analysis on the cyclic
group $\mathbb{Z}/N\mathbb{Z}$ and apply it to additive combinatorics. Working with
the standard additive character $e(x) = \exp(2\pi i x/N)$, we establish character
orthogonality, the convolution theorem $\widehat{f \star g} = \widehat{f}\cdot
\widehat{g}$, and the Parseval/Plancherel identities. We then connect this analytic
machinery to the combinatorial notion of *additive energy* $E[A]$ of a set
$A \subseteq \mathbb{Z}/N\mathbb{Z}$, proving the central spectral identity

$$E[A] \;=\; \frac{1}{N}\sum_{k}\big\lVert\widehat{\mathbf 1_A}(k)\big\rVert^4,$$

together with its immediate corollary $E[A] \ge |A|^4/N$. The development isolates
the representation-counting role of self-convolution, namely
$(\mathbf 1_A \star \mathbf 1_A)(a)$ equals the number of ordered pairs in
$A \times A$ summing to $a$, and shows how Plancherel converts the $\ell^2$ norm of
that count into the fourth moment of the spectrum. These results constitute the
Fourier-analytic backbone of Roth-type theorems and of the
Balog–Szemerédi–Gowers theorem. We also record proof sketches faithful to a fully
formalized development, discuss algorithmic content, and outline several concrete
directions for extension, including a general finite-abelian-group version and an
equality characterization of the energy lower bound.

---

## 1. Introduction

### 1.1 Motivation

Additive combinatorics studies the interaction between the additive structure of a
set and its size. A central organizing quantity is the **additive energy** of a
finite set $A$ in an abelian group, defined as the number of additive quadruples

$$E[A] \;=\; \#\{(a,b,c,d) \in A^4 : a + b = c + d\}.$$

Additive energy interpolates between two extremes. A set with the structure of an
arithmetic progression maximizes energy (of order $|A|^3$), whereas a generic
"random" set minimizes it (of order $|A|^4/N$ in $\mathbb{Z}/N\mathbb{Z}$). The
dichotomy *structure vs. randomness*, which animates much of modern combinatorial
number theory, is measured precisely by where between these extremes a given set
falls.

The most powerful lens for analyzing additive energy is **Fourier analysis on
finite abelian groups**. The discrete Fourier transform diagonalizes convolution,
and additive energy is, at heart, an $\ell^2$ quantity built from a self-convolution.
The purpose of this paper is to make that connection completely explicit and
rigorous on the cyclic group $\mathbb{Z}/N\mathbb{Z}$, deriving the spectral
formula for additive energy from first principles.

### 1.2 Contributions

We prove, for every $N \ge 1$ and every function or set on $\mathbb{Z}/N\mathbb{Z}$:

1. **Character orthogonality** in the sharp form
   $\sum_i e(t\cdot i) = N\cdot[\![t=0]\!]$ (`stdAddChar_sum_mul`).
2. **The convolution theorem**
   $\widehat{f \star g}(k) = \widehat{f}(k)\,\widehat{g}(k)$ (`dft_conv`).
3. **Parseval's identity** in sesquilinear form and **Plancherel's identity** in
   real $\ell^2$-norm form (`parseval`, `plancherel`).
4. **The representation-counting lemma**
   $(\mathbf 1_A \star \mathbf 1_A)(a) = r_A(a)$ (`conv_ind`) and the energy
   decomposition $E[A] = \sum_a r_A(a)^2$ (`addEnergy_eq_sum_count_sq`).
5. **The spectral formula for additive energy**
   $E[A] = N^{-1}\sum_k \lVert\widehat{\mathbf 1_A}(k)\rVert^4$ (`addEnergy_eq_dft`)
   and the corollary $E[A] \ge |A|^4/N$ (`card_pow_four_div_le_addEnergy`).

All results are stated over $\mathbb{C}$ and hold for arbitrary complex-valued
functions where applicable; the additive-energy results specialize to indicator
functions of finite sets.

### 1.3 Conventions

Throughout, $N \ge 1$ is a fixed positive integer and we write $G = \mathbb{Z}/N\mathbb{Z}$.
We use the **standard additive character**
$$e\colon G \to \mathbb{C}, \qquad e(x) = \exp(2\pi i\, \tilde{x}/N),$$
where $\tilde{x} \in \{0,\dots,N-1\}$ is the canonical representative of $x$. It
satisfies $e(x+y) = e(x)e(y)$, $|e(x)| = 1$, and $\overline{e(x)} = e(-x)$. The
discrete Fourier transform uses the convention
$$\widehat{f}(k) \;=\; \sum_{j \in G} e(-jk)\, f(j),$$
which places the normalizing factor $N$ on the inverse transform. As a consequence,
Plancherel carries the factor $N$ on the spectral side, and the energy identity
carries the reciprocal factor $1/N$. All sums over an unqualified index range over
the entire group $G$.

---

## 2. Preliminaries: characters and orthogonality

### 2.1 The standard additive character

The characters of $G = \mathbb{Z}/N\mathbb{Z}$ are exactly the maps $x \mapsto e(kx)$
for $k \in G$; these are the irreducible unitary representations of the (abelian)
group, and they form an orthogonal basis of the space $\mathbb{C}^G$ of complex
functions on $G$. The single character $e$ generates all of them by the harmonic
$x \mapsto e(kx) = e(x)^k$.

**Lemma 2.1 (conjugation of the character; `conj_stdAddChar`).**
For all $x \in G$,
$$\overline{e(x)} \;=\; e(-x).$$

*Proof sketch.* Since $e$ is a homomorphism into the unit circle, $e(x)$ has modulus
$1$, so its complex conjugate equals its inverse. The inverse of $e(x)$ is $e(-x)$
because $e(x)e(-x) = e(0) = 1$. Formally one combines `AddChar.map_neg_eq_inv`
(the value at $-x$ is the multiplicative inverse) with the fact that for a
unit-modulus complex number the inverse equals the conjugate. $\square$

### 2.2 Orthogonality

The cornerstone of all finite Fourier analysis is the cancellation of a nontrivial
character summed over the whole group.

**Lemma 2.2 (character orthogonality; `stdAddChar_sum_mul`).**
For every $t \in G$,
$$\sum_{i \in G} e(t\cdot i) \;=\; \begin{cases} N, & t = 0, \\ 0, & t \neq 0.\end{cases}$$

*Proof sketch.* If $t = 0$ then every summand is $e(0) = 1$ and the sum is the
cardinality $N$ of $G$. If $t \neq 0$, the map $i \mapsto e(t\cdot i)$ is the
mul-shift of the primitive character $e$ by $t$, which is again a *nontrivial*
character because $e$ is primitive (this is `ZMod.isPrimitive_stdAddChar`). A
nontrivial character sums to zero over a finite group: writing $S = \sum_i \chi(i)$
for a character $\chi \neq 1$ and choosing $i_0$ with $\chi(i_0) \neq 1$, the
substitution $i \mapsto i + i_0$ gives $\chi(i_0) S = S$, forcing $S = 0$. $\square$

This single lemma is the source of every subsequent cancellation: Parseval, the
spectral collapse to a fourth moment, and the isolation of the $k = 0$ main term
all trace back to Lemma 2.2.

---

## 3. Convolution and the convolution theorem

### 3.1 Definitions

**Definition 3.1 (indicator; `ind`).** For a finite subset $s \subseteq G$, the
complex indicator function is
$$\mathbf 1_s(x) \;=\; \begin{cases} 1, & x \in s, \\ 0, & x \notin s.\end{cases}$$

**Definition 3.2 (cyclic convolution; `conv`).** For $f, g\colon G \to \mathbb{C}$,
$$(f \star g)(x) \;=\; \sum_{y \in G} f(y)\, g(x - y).$$

Convolution is commutative and associative, and the indicator of $\{0\}$ is its
identity. Its significance here is that it is diagonalized by the Fourier transform.

### 3.2 The convolution theorem

**Theorem 3.3 (convolution theorem; `dft_conv`).**
For all $f, g\colon G \to \mathbb{C}$ and all $k \in G$,
$$\widehat{(f \star g)}(k) \;=\; \widehat{f}(k)\,\widehat{g}(k).$$

*Proof sketch.* Expand the transform of the convolution by its definition:
$$\widehat{(f \star g)}(k) = \sum_{x}\Big(\sum_{y} f(y)\,g(x-y)\Big) e(-kx).$$
Fix $y$ and substitute $x = y + z$ in the outer sum; because $z \mapsto y + z$ is a
bijection of $G$, the sum is unchanged in range. Using the multiplicativity
$e(-k x) = e(-k y)\,e(-k z)$ we factor the double sum:
$$\widehat{(f \star g)}(k) = \sum_y f(y)\,e(-ky) \sum_z g(z)\,e(-kz) = \widehat{f}(k)\,\widehat{g}(k).$$
The only non-formal step is the reindexing, which is justified by invariance of a
full-group sum under translation (`Equiv.sum_comp` with `Equiv.addRight y`). $\square$

The convolution theorem is the workhorse of the entire development: it is what lets
us replace the (analytically awkward) self-convolution $\mathbf 1_A \star
\mathbf 1_A$ by the (algebraically trivial) pointwise square $\widehat{\mathbf 1_A}^2$.

---

## 4. Parseval and Plancherel

### 4.1 Parseval (sesquilinear form)

**Theorem 4.1 (Parseval; `parseval`).**
For all $f, g\colon G \to \mathbb{C}$,
$$\sum_{k} \widehat{f}(k)\,\overline{\widehat{g}(k)} \;=\; N\sum_{j} f(j)\,\overline{g(j)}.$$

*Proof sketch.* Expand both transforms:
$$\widehat{f}(k) = \sum_j f(j)\,e(-jk), \qquad \overline{\widehat{g}(k)} = \sum_\ell \overline{g(\ell)}\,e(\ell k),$$
where the second equality uses Lemma 2.1, $\overline{e(-\ell k)} = e(\ell k)$.
Multiplying and summing over $k$,
$$\sum_k \widehat f(k)\,\overline{\widehat g(k)} = \sum_j \sum_\ell f(j)\,\overline{g(\ell)} \sum_k e\big((\ell - j)k\big).$$
By orthogonality (Lemma 2.2) the inner $k$-sum equals $N$ when $\ell = j$ and $0$
otherwise. Collapsing the double sum to its diagonal $\ell = j$ yields
$N\sum_j f(j)\,\overline{g(j)}$. $\square$

### 4.2 Plancherel (norm form)

**Theorem 4.2 (Plancherel; `plancherel`).**
For all $f\colon G \to \mathbb{C}$,
$$\sum_{k} \big\lVert\widehat{f}(k)\big\rVert^2 \;=\; N\sum_{j} \big\lVert f(j)\big\rVert^2.$$

*Proof sketch.* Set $g = f$ in Theorem 4.1. The left-hand side becomes
$\sum_k \widehat f(k)\overline{\widehat f(k)} = \sum_k \lVert\widehat f(k)\rVert^2$
and the right-hand side becomes $N\sum_j \lVert f(j)\rVert^2$, using
$z\,\overline z = \lVert z\rVert^2$. Taking real parts (both sides are already real
and nonnegative) gives the stated identity over $\mathbb{R}$. $\square$

Plancherel says the Fourier transform is, up to the scalar $\sqrt N$, an isometry of
$\mathbb{C}^G$ with the Euclidean inner product. This isometry is precisely what
will let us move the energy computation into the spectral domain without loss.

---

## 5. Additive energy via Fourier

### 5.1 Representation counts

**Definition 5.1 (representation count; `count`).** For a finite set $s \subseteq G$
and $a \in G$,
$$r_s(a) \;=\; \#\{(x,y) \in s \times s : x + y = a\}.$$

**Lemma 5.2 (self-convolution counts representations; `conv_ind`).**
For all finite $s \subseteq G$ and $a \in G$,
$$(\mathbf 1_s \star \mathbf 1_s)(a) \;=\; r_s(a).$$

*Proof sketch.* By definition
$(\mathbf 1_s \star \mathbf 1_s)(a) = \sum_y \mathbf 1_s(y)\,\mathbf 1_s(a - y)$.
Each summand is $1$ exactly when $y \in s$ and $a - y \in s$, and $0$ otherwise.
The map $y \mapsto (y, a-y)$ is a bijection between $\{y : y \in s,\ a - y \in s\}$
and $\{(x,y) \in s \times s : x + y = a\}$, so the sum counts precisely $r_s(a)$.
Formally one rewrites the filtered product set as the image of this injection and
applies `Finset.card_image_of_injective`. $\square$

### 5.2 Energy as a sum of squared counts

**Lemma 5.3 (energy decomposition; `addEnergy_eq_sum_count_sq`).**
For all finite $s \subseteq G$,
$$E[s] \;=\; \sum_{a \in G} r_s(a)^2.$$

*Proof sketch.* The additive energy counts quadruples $(a,b,c,d) \in s^4$ with
$a + b = c + d$. Partition this set according to the common value $t = a + b = c+d$.
For each fixed $t$, the choices of $(a,b)$ with $a+b=t$ number $r_s(t)$, and
independently the choices of $(c,d)$ with $c+d=t$ also number $r_s(t)$, giving
$r_s(t)^2$ quadruples. Summing over $t$ yields $\sum_t r_s(t)^2$. $\square$

### 5.3 The spectral formula

**Theorem 5.4 (spectral formula for additive energy; `addEnergy_eq_dft`).**
For all finite $A \subseteq G$,
$$E[A] \;=\; \frac{1}{N}\sum_{k} \big\lVert\widehat{\mathbf 1_A}(k)\big\rVert^4.$$

*Proof sketch.* Combine the previous results in sequence:
$$E[A] \overset{\text{(5.3)}}{=} \sum_a r_A(a)^2 \overset{\text{(5.2)}}{=} \sum_a \big\lVert(\mathbf 1_A \star \mathbf 1_A)(a)\big\rVert^2.$$
(The values $r_A(a)$ are nonnegative reals, so squaring equals squaring the
modulus.) Apply Plancherel (Theorem 4.2) to the function
$h = \mathbf 1_A \star \mathbf 1_A$:
$$\sum_a \lVert h(a)\rVert^2 = \frac{1}{N}\sum_k \lVert\widehat h(k)\rVert^2.$$
By the convolution theorem (Theorem 3.3),
$\widehat h(k) = \widehat{\mathbf 1_A}(k)^2$, whence
$\lVert\widehat h(k)\rVert^2 = \lVert\widehat{\mathbf 1_A}(k)\rVert^4$. Substituting,
$$E[A] = \frac1N \sum_k \lVert\widehat{\mathbf 1_A}(k)\rVert^4. \qquad\square$$

Note the placement of the constant: because the chosen DFT convention puts the
normalizing $N$ on the inverse transform, Plancherel reads "$\sum$ of squared
spectrum $= N\cdot \sum$ of squared values," equivalently "$\sum$ of squared values
$= N^{-1}\cdot\sum$ of squared spectrum." This is the origin of the $1/N$ in the
energy identity.

### 5.4 The energy lower bound

**Corollary 5.5 (energy lower bound; `card_pow_four_div_le_addEnergy`).**
For all finite $A \subseteq G$,
$$E[A] \;\ge\; \frac{|A|^4}{N}.$$

*Proof sketch.* In the spectral sum of Theorem 5.4 every term is a nonnegative real.
Retaining only the $k = 0$ term gives a lower bound. The zeroth Fourier coefficient
is
$$\widehat{\mathbf 1_A}(0) = \sum_j e(0)\,\mathbf 1_A(j) = \sum_j \mathbf 1_A(j) = |A|,$$
so $\lVert\widehat{\mathbf 1_A}(0)\rVert^4 = |A|^4$ and
$E[A] \ge N^{-1}|A|^4$. Formally this is `Finset.single_le_sum` applied to the
nonnegative summands. $\square$

The bound is sharp: equality forces all higher-frequency terms to vanish, which
(over $\mathbb{Z}/N\mathbb{Z}$ with $N$ prime) happens precisely when $A$ is the
empty set or the whole group, and in general when $A$ is a coset of a subgroup
(see Future Directions, C5).

---

### 5.5 A worked example

It is illuminating to see every identity meet in a single concrete computation.
Take $N = 7$ and $A = \{0, 1, 2, 4\}$, so $|A| = 4$.

*Representation counts.* Counting ordered pairs $(x,y) \in A \times A$ with
$x + y \equiv a \pmod 7$ gives
$$r_A(0)=1,\ r_A(1)=3,\ r_A(2)=3,\ r_A(3)=2,\ r_A(4)=3,\ r_A(5)=2,\ r_A(6)=2.$$
(For instance $r_A(1) = 3$ because $1 = 0+1 = 1+0 = 4+4$, the last using $4+4=8\equiv1$.)
The counts sum to $\sum_a r_A(a) = 16 = |A|^2$, as they must, since every ordered
pair has *some* sum.

*Energy by counts.* By Lemma 5.3,
$$E[A] = \sum_a r_A(a)^2 = 1 + 9 + 9 + 4 + 9 + 4 + 4 = 40.$$

*Energy by brute force.* Direct enumeration of quadruples $(a,b,c,d) \in A^4$ with
$a+b \equiv c+d$ also yields $40$, confirming Lemma 5.3 on the nose.

*Energy by spectrum.* The zeroth Fourier coefficient is
$\widehat{\mathbf 1_A}(0) = |A| = 4$, contributing $\tfrac17\cdot 4^4 = \tfrac{256}{7}
\approx 36.57$ — already most of the energy. The remaining six frequencies
$k = 1, \dots, 6$ supply the balance, and the total
$\tfrac17\sum_k |\widehat{\mathbf 1_A}(k)|^4$ comes to exactly $40$, matching the
combinatorial count and confirming Theorem 5.4.

*Lower bound.* Corollary 5.5 predicts $E[A] \ge |A|^4/N = 256/7 \approx 36.57$, and
indeed $40 \ge 36.57$. The small gap $40 - 256/7 = 24/7$ is exactly the contribution
of the nonzero frequencies, quantifying how far $A$ departs from being spectrally
flat.

*Structure vs. randomness.* For comparison, in $\mathbb{Z}/11\mathbb{Z}$ the
arithmetic progression $\{0,1,2,3,4\}$ has energy $85$, whereas the spread-out set
$\{0,1,3,7,9\}$ of the same size has energy $69$; both exceed the common lower bound
$5^4/11 \approx 56.8$, but the progression — the more additively structured set — sits
further above it. The excess over $|A|^4/N$ is precisely the mass of the nonzero
spectrum, making the spectral formula a quantitative meter of additive structure.

## 6. Algorithmic content

The formal results translate directly into algorithms whose correctness is
guaranteed by the theorems above.

### 6.1 Direct vs. spectral additive energy

The naive computation of $E[A]$ enumerates additive quadruples and costs
$O(|A|^4)$ time, or $O(N^2)$ via the representation-count decomposition
$E[A] = \sum_a r_A(a)^2$ (compute all $r_A(a)$ by an $O(N^2)$ double loop, then
sum their squares in $O(N)$). The spectral formula offers an asymptotically faster
route: compute $\widehat{\mathbf 1_A}$ by a Fast Fourier Transform in
$O(N \log N)$, then evaluate $N^{-1}\sum_k |\widehat{\mathbf 1_A}(k)|^4$ in $O(N)$.
Theorem 5.4 certifies that the two procedures return the same value.

### 6.2 Spectral convolution

The convolution theorem yields the standard FFT-based convolution: to compute
$f \star g$, transform both inputs, multiply pointwise, and invert. This reduces
the cost from $O(N^2)$ to $O(N\log N)$ and is the computational reason convolution
is ubiquitous in signal processing. Lemma 5.2 then identifies the self-convolution
of an indicator with its representation function, so a single FFT yields all the
counts $r_A(a)$ at once.

---

## 7. Applications

### 7.1 Roth's theorem and three-term progressions

The number of three-term arithmetic progressions $x,\ x+d,\ x+2d$ contained in
$A \subseteq \mathbb{Z}/N\mathbb{Z}$ (with $N$ odd) admits a spectral expression
$N^{-1}\sum_k \widehat{\mathbf 1_A}(k)^2\,\widehat{\mathbf 1_A}(-2k)$, derived from
the convolution theorem by a linear change of variables. The $k = 0$ term is the
expected main term $|A|^3/N$; control of the remaining terms (large vs. small
Fourier coefficients) is the engine of the density-increment proof of Roth's
theorem. The convolution theorem (Theorem 3.3) and Plancherel (Theorem 4.2)
established here are exactly the ingredients that proof requires.

### 7.2 Balog–Szemerédi–Gowers

Additive energy is the precise quantity governed by the Balog–Szemerédi–Gowers
theorem, which converts "large energy" into "a large structured subset." The
spectral formula (Theorem 5.4) and the lower bound (Corollary 5.5) are the standard
tools for computing and bounding energy in applications of this theorem, and the
identity $E[A] = N^{-1}\sum_k|\widehat{\mathbf 1_A}(k)|^4$ makes the structure-vs-
randomness contest explicit as a competition between the $k=0$ term and the rest.

### 7.3 Signal processing and beyond

Outside number theory, the same three pillars power image filtering, audio
compression, error-correcting codes, and crystallography. The convolution theorem
is the basis of fast filtering; Plancherel is conservation of energy across the
spectrum; and character orthogonality is the reason distinct frequencies can be
separated without interference.

---

## 8. Discussion

The development is deliberately minimal: a single orthogonality lemma drives
everything. From it, Parseval follows by a diagonal collapse, Plancherel by
specialization, and the energy identity by composing Plancherel with the
convolution theorem applied to a self-convolution. The chain
$$E[A] = \sum_a r_A(a)^2 = \sum_a |(\mathbf 1_A\star\mathbf 1_A)(a)|^2 = \tfrac1N\sum_k|\widehat{\mathbf 1_A}(k)^2|^2 = \tfrac1N\sum_k|\widehat{\mathbf 1_A}(k)|^4$$
is short, but each link is a genuine theorem, and packaging them together yields a
reusable bridge between the combinatorial and analytic descriptions of a set.

A subtlety worth emphasizing is normalization. Different sources put the factor $N$
in different places (on the forward transform, the inverse transform, or split as
$\sqrt N$ on each). The convention used here places $N$ on the inverse transform,
which makes the forward transform purely a sum (convenient for the combinatorics)
at the cost of a $1/N$ in the energy identity. All identities are internally
consistent with this choice; a reader translating to another convention must track
the constant accordingly.

---

## 9. Future directions

The following conjectures are concrete, falsifiable targets for follow-up work.

**C1. Energy lower bound via the sumset.** $E[A] \ge |A|^4/|A+A|$, refining
Corollary 5.5 since $|A+A| \le N$. This follows from Cauchy–Schwarz applied to
$\sum_{t \in A+A} r_A(t) = |A|^2$ together with $\sum_t r_A(t)^2 = E[A]$, and is a
purely combinatorial companion to the Fourier bound.

**C2. Spectral count of 3-APs.** For $A \subseteq \mathbb{Z}/N\mathbb{Z}$ with
$\gcd(2,N)=1$, the number of three-term progressions equals
$N^{-1}\sum_k \widehat{\mathbf 1_A}(k)^2\,\widehat{\mathbf 1_A}(-2k)$ (with suitable
conjugation), with $k=0$ main term $|A|^3/N$. Derive it from the convolution
theorem plus the substitution $y \mapsto 2y$.

**C3. Convolution $\ell^2$ identity (Young-type).** The sharp identity
$\sum_a \lVert(f\star g)(a)\rVert^2 = N^{-1}\sum_k \lVert\widehat f(k)\rVert^2
\lVert\widehat g(k)\rVert^2$ follows directly from Theorems 3.3 and 4.2 and
generalizes Theorem 5.4 (take $f=g=\mathbf 1_A$); the related inequality
$\sum_a \lVert(f\star g)(a)\rVert^2 \le (\sum_a \lVert f(a)\rVert)^2
(\sum_a \lVert g(a)\rVert^2)$ is a discrete Young inequality.

**C4. Arbitrary finite abelian groups.** Re-prove Theorem 5.4 over a general finite
abelian group $G$ using $\mathrm{AddChar}(G,\mathbb{C})$ and the built-in
orthogonality, with $N := |G|$. The identity should hold verbatim; the only new
ingredient is a basis-free convolution theorem for character-Fourier transforms.

**C5. Equality characterization.** $E[A] = |A|^4/N$ if and only if $\widehat{\mathbf 1_A}$
is supported only at $k=0$, i.e. $\mathbf 1_A$ is constant. Over prime $N$ this forces
$A \in \{\varnothing, G\}$; for composite $N$ it classifies the equality sets as
cosets of subgroups.

---

## 10. Conclusion

We have given a complete, self-contained derivation of the spectral formula for
additive energy on $\mathbb{Z}/N\mathbb{Z}$, resting on three classical pillars —
character orthogonality, the convolution theorem, and Plancherel's identity — each
proved from first principles. The resulting identity $E[A] = N^{-1}\sum_k
|\widehat{\mathbf 1_A}(k)|^4$ and its corollary $E[A] \ge |A|^4/N$ are the
analytic backbone of Roth-type theorems and of the Balog–Szemerédi–Gowers theorem,
and the toolkit assembled here is directly reusable for the further directions
outlined above.
