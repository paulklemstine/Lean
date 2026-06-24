# A Gaussian-Integer Bridge for Ring-LWE: The Sum of Two Squares as the Geometry of Lattice Encryption

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Pythagorean / Lattice Cryptography

---

## Abstract

We develop the algebraic and number-theoretic foundations needed to state the
ring variant of the Learning With Errors (ring-LWE) problem over the Gaussian
integers $\mathbb{Z}[i]$ and to establish a clean decryption-correctness
guarantee for a public-key encryption scheme built upon it. The central object
is the Gaussian norm $N(a + bi) = a^2 + b^2$ — the Pythagorean sum of two
squares — whose **multiplicativity** $N(zw) = N(z)N(w)$ is precisely the
Brahmagupta–Fibonacci composition identity. We layer the development so that
each result depends only on previously established components: (1) the Gaussian
norm and its non-negativity; (2) multiplicativity via Brahmagupta–Fibonacci;
(3) the splitting/inertness dichotomy of rational primes in $\mathbb{Z}[i]$
governed by residues modulo $4$ (Fermat's two-squares theorem); (4) the
ring-LWE problem and an associated public-key scheme; and (5) a decryption
correctness theorem stating that decryption succeeds whenever the error vector
$(e_x, e_y)$ lies in the Euclidean ball $e_x^2 + e_y^2 < (q/4)^2$. Separately,
we present the algebraic core of the LWE search-to-decision reduction: affine
maps $x \mapsto ax + b$ ($a \neq 0$) are bijections modulo a prime, yielding a
pigeonhole-based per-coordinate advantage bound with a tight factor-$n$ loss,
and a certificate interface composing an assumed Regev quantum worst-case
reduction with the search-to-decision step. All results have been formalized and
machine-checked. We stop short of reproving Regev's analytic/quantum reduction,
which is isolated as an explicit hypothesis.

---

## 1. Introduction

Lattice-based cryptography is the leading approach to public-key cryptography
secure against quantum adversaries. Its security rests on the conjectured
hardness of the **Learning With Errors (LWE)** problem (Regev, 2005) and its
algebraically efficient variant **ring-LWE** (Lyubashevsky–Peikert–Regev,
2010). Regev's foundational theorem reduces worst-case lattice problems such as
the (gap) shortest vector problem $\mathrm{GapSVP}$ to average-case decision-LWE
via a quantum algorithm, providing the strongest possible form of security
guarantee: an average-case instance is as hard as the worst case.

This paper formalizes the **Pythagorean heart** of one concrete and historically
resonant instantiation: ring-LWE over the Gaussian integers $\mathbb{Z}[i]$. The
arithmetic of $\mathbb{Z}[i]$ is governed by the norm $N(a + bi) = a^2 + b^2$,
the quintessential sum of two squares. Three classical facts drive the entire
development:

1. **Brahmagupta–Fibonacci identity** (7th/13th century):
   $(a^2 + b^2)(c^2 + d^2) = (ac - bd)^2 + (ad + bc)^2$, which makes $N$
   multiplicative.
2. **Fermat's two-squares theorem**: an odd prime $p$ is a sum of two squares
   iff $p \equiv 1 \pmod 4$, controlling whether $p$ splits or stays inert in
   $\mathbb{Z}[i]$.
3. **Nearest-codeword rounding** in $\mathbb{Z}/q\mathbb{Z}$, whose correctness
   radius is exactly $q/4$, giving a *Euclidean ball* error-tolerance region
   $x^2 + y^2 < (q/4)^2$ in two dimensions.

Our contribution is a layered, fully verified formalization establishing the
norm theory, the prime dichotomy, the encryption scheme, and a decryption
correctness theorem, together with the algebraic core of the search-to-decision
reduction and a quantitative certificate interface for the Regev worst-case
reduction.

### Notation and conventions

Throughout, $q = 2t$ denotes an even modulus with half-modulus $t = q/2$. A
Gaussian integer is $z = a + bi$ with $a = \mathrm{Re}(z)$, $b = \mathrm{Im}(z)$.
The Gaussian norm is $N(z) = a^2 + b^2 \in \mathbb{Z}$. Errors are written
$(e_x, e_y)$ for the real and imaginary parts, respectively. Plaintext bits are
$m \in \{0, 1\}$.

---

## 2. The Gaussian norm

**Definition 2.1 (Gaussian norm).** For $z = a + bi \in \mathbb{Z}[i]$, define

$$N(z) := (\mathrm{Re}\,z)^2 + (\mathrm{Im}\,z)^2 = a^2 + b^2.$$

This is realized in the formalization as `gaussNorm (z : GaussianInt) : ℤ`.

**Proposition 2.2 (Agreement with the field norm; `gaussNorm_eq_zsqrtdNorm`).**
The explicit norm agrees with the standard ring norm on $\mathbb{Z}[i]$
(Mathlib's `Zsqrtd.norm`): $N(z) = z.\mathrm{norm}$.

*Proof sketch.* The ring $\mathbb{Z}[i]$ is the quadratic ring $\mathbb{Z}[\sqrt{-1}]$,
whose generic norm is $a^2 - (-1)b^2 = a^2 + b^2$. Expanding both definitions and
applying ring normalization gives the identity. $\square$

**Proposition 2.3 (Non-negativity; `gaussNorm_nonneg`).** For every
$z \in \mathbb{Z}[i]$, $N(z) \geq 0$.

*Proof sketch.* $N(z) = a^2 + b^2$ is a sum of squares of integers, hence
non-negative by positivity. $\square$

---

## 3. Multiplicativity via Brahmagupta–Fibonacci

The single most important structural property of the norm is multiplicativity.
We obtain it directly from the classical composition identity for sums of two
squares.

**Lemma 3.1 (Brahmagupta–Fibonacci identity).** For integers $a, b, c, d$,

$$(a^2 + b^2)(c^2 + d^2) = (ac - bd)^2 + (ad + bc)^2.$$

(In the formalization this is `FINAL.Pythagorean.brahmagupta_fibonacci`,
imported and applied to the coordinates of the factors.)

**Theorem 3.2 (Multiplicativity of the Gaussian norm; `gaussNorm_mul`).** For
all $z, w \in \mathbb{Z}[i]$,

$$N(z \cdot w) = N(z) \cdot N(w).$$

*Proof sketch.* Write $z = a + bi$, $w = c + di$. The product in $\mathbb{Z}[i]$
has real part $ac - bd$ and imaginary part $ad + bc$:

$$\mathrm{Re}(zw) = ac - bd, \qquad \mathrm{Im}(zw) = ad + bc.$$

Therefore
$N(zw) = (ac - bd)^2 + (ad + bc)^2$, which by Lemma 3.1 equals
$(a^2 + b^2)(c^2 + d^2) = N(z)N(w)$. Formally, after substituting the explicit
real and imaginary parts of the product, the goal is closed by a linear
combination of the Brahmagupta–Fibonacci identity. $\square$

This theorem is the algebraic backbone of arithmetic in $\mathbb{Z}[i]$: the
norm is a multiplicative monoid homomorphism $(\mathbb{Z}[i], \cdot) \to
(\mathbb{Z}_{\geq 0}, \cdot)$, and the set of norm values — the sums of two
squares — is consequently closed under multiplication.

---

## 4. The splitting / inertness dichotomy

The behavior of a rational prime $p$ inside $\mathbb{Z}[i]$ is governed entirely
by $p \bmod 4$. This is Fermat's two-squares theorem in Gaussian-prime language,
and it dictates the choice of secure ring-LWE moduli.

**Theorem 4.1 (Split primes; `prime_split`).** If $p$ is prime with
$p \equiv 1 \pmod 4$, then there exist integers $a, b$ with $a^2 + b^2 = p$.

**Corollary 4.2 (Non-primality in $\mathbb{Z}[i]$; `prime_not_prime_in_gaussian`).**
If $p$ is prime with $p \equiv 1 \pmod 4$, then $p$ is *not* prime in
$\mathbb{Z}[i]$; it splits as $p = (a + bi)(a - bi)$ where $a^2 + b^2 = p$.

*Proof sketch.* By Theorem 4.1, $p = a^2 + b^2 = N(a + bi)$, so
$p = (a+bi)(a-bi)$ is a nontrivial factorization (neither factor is a unit since
each has norm $p > 1$), witnessing that $p$ is reducible, hence not prime. $\square$

**Theorem 4.3 (Inert primes; `prime_inert`).** If $p$ is prime with
$p \equiv 3 \pmod 4$, then $p$ remains prime in $\mathbb{Z}[i]$.

**Theorem 4.4 (Not a sum of two squares; `prime_inert_not_sum_two_squares`).** If
$p \equiv 3 \pmod 4$, then there are no integers $a, b$ with $a^2 + b^2 = p$.

*Proof sketch.* Squares modulo $4$ are $0$ or $1$, so $a^2 + b^2 \in \{0, 1, 2\}
\pmod 4$ and can never be $\equiv 3$. Hence $p \equiv 3 \pmod 4$ is not a sum of
two squares; equivalently, $p$ has no nontrivial factorization in $\mathbb{Z}[i]$
(any factor would contribute a norm strictly between $1$ and $p^2$ equal to $p$,
which is impossible), so $p$ is inert. $\square$

These results partition the rational primes into two cryptographically distinct
families: **split moduli** ($p \equiv 1 \pmod 4$, each a sum of two squares) and
**inert moduli** ($p \equiv 3 \pmod 4$). The choice affects the ring structure
$\mathbb{Z}[i]/(p)$ and therefore the geometry of the underlying lattice.

---

## 5. Ring-LWE over $\mathbb{Z}[i]$

We instantiate a generic LWE scaffolding at the coefficient ring
$\mathbb{Z}[i]$.

**Definition 5.1 (Ring-LWE sample; `RLWESample`, `rlweSample`).** A ring-LWE
sample over $\mathbb{Z}[i]$ is a pair $(a, b) \in \mathbb{Z}[i] \times
\mathbb{Z}[i]$. The *honest* sample with secret $s$, error $e$, and public
element $a$ is

$$\mathrm{rlweSample}(s, e, a) = (a,\; a \cdot s + e).$$

**Definition 5.2 (Euclidean error bound; `errorBounded`).** A Gaussian error
$e$ is *bounded by $r$* if its error vector lies in the open Euclidean ball of
radius $r$:

$$\mathrm{errorBounded}(r, e) :\Longleftrightarrow (\mathrm{Re}\,e)^2 +
(\mathrm{Im}\,e)^2 < r^2.$$

**Definition 5.3 (Search ring-LWE; `SearchRLWE`).** Given a radius $r$ and a list
of samples, $\mathrm{SearchRLWE}(r, \text{samples})$ is the problem of recovering
a secret consistent with all samples, where "small residual" means the residual
error lies in the radius-$r$ Euclidean ball. Formally this instantiates the
generic `SearchLWE` predicate with the noise predicate $\mathrm{errorBounded}(r,
\cdot)$.

The use of the Euclidean (sum-of-two-squares) ball as the noise region is the
natural geometric notion in $\mathbb{Z}[i]$ and is what links the algebra of the
norm to the correctness analysis below.

---

## 6. A public-key scheme and decryption correctness

We now describe a bit-encryption scheme over $\mathbb{Z}[i]$ and prove its
correctness. Fix $q = 2t$, so $t = q/2$ is the half-modulus; a plaintext bit
$m \in \{0, 1\}$ is encoded in a coordinate as $m \cdot t \in \{0, q/2\}$.

### 6.1 The decoder and one-dimensional correctness

**Definition 6.1 (Nearest-codeword decoder; `decodeCoord`).** For half-modulus
$t$ and a coordinate value $v$,

$$\mathrm{decodeCoord}(t, v) = \begin{cases} 0 & \text{if } 2v < t, \\ 1 &
\text{otherwise.} \end{cases}$$

**Theorem 6.2 (One-dimensional decoding correctness; `decodeCoord_correct`).**
Let $m \in \{0, 1\}$ and let $e$ be an integer error with $2|e| < t$. Then

$$\mathrm{decodeCoord}(t,\; e + m \cdot t) = m.$$

*Proof sketch.* Two cases. If $m = 0$, the coordinate is $e$ with $2|e| < t$, so
$2e < t$ and the decoder outputs $0 = m$. If $m = 1$, the coordinate is $e + t$;
from $2|e| < t$ we get $2(e + t) = 2e + 2t \geq -t + 2t = t$ (in fact $> t$), so
$2(e+t) \not< t$ and the decoder outputs $1 = m$. Formally one splits on the two
values of $m$ and the sign of $e$ (via the case analysis of $|e|$) and discharges
each branch by linear integer arithmetic. $\square$

### 6.2 Encoding, encryption, decryption

**Definition 6.3 (Message encoding; `encodeMsg`).** A two-bit message
$(m_x, m_y)$ is encoded as the Gaussian integer

$$\mathrm{encodeMsg}(t, m_x, m_y) = (m_x \cdot t) + (m_y \cdot t)\, i.$$

**Definition 6.4 (Ciphertext; `Ciphertext`).** A ciphertext is a pair
$(u, v) \in \mathbb{Z}[i]^2$, where $u$ is the public part and $v$ is the masked,
message-carrying part.

**Definition 6.5 (Encryption; `encrypt`).** With secret $s$, public coordinate
$a$, error coordinates $(e_x, e_y)$, message bits $(m_x, m_y)$, and half-modulus
$t$,

$$\mathrm{encrypt} = \big(a,\; a \cdot s + (e_x + e_y i) +
\mathrm{encodeMsg}(t, m_x, m_y)\big).$$

**Definition 6.6 (Decryption; `decrypt`).** Given the secret $s$ and ciphertext
$(u, v)$, compute the *phase* $\phi = v - u \cdot s$ and round each coordinate:

$$\mathrm{decrypt}(t, s, (u, v)) = \big(\mathrm{decodeCoord}(t, \mathrm{Re}\,\phi),\;
\mathrm{decodeCoord}(t, \mathrm{Im}\,\phi)\big).$$

Substituting the ciphertext from Definition 6.5, the phase is
$\phi = (e_x + e_y i) + \mathrm{encodeMsg}(t, m_x, m_y)$, so
$\mathrm{Re}\,\phi = e_x + m_x t$ and $\mathrm{Im}\,\phi = e_y + m_y t$. The mask
$u \cdot s = a \cdot s$ cancels exactly.

### 6.3 From the Euclidean ball to per-coordinate bounds

The decoder needs the per-coordinate condition $2|e| < t$; the scheme's stated
noise model is the *Euclidean ball* $e_x^2 + e_y^2 < (q/4)^2$. The bridge is:

**Theorem 6.7 (Coordinate bound, real part; `coord_bound_re`).** Let $t > 0$ and
$q = 2t$. If

$$e_x^2 + e_y^2 < \left(\frac{q}{4}\right)^2,$$

then $2|e_x| < t$.

*Proof sketch.* Since $q = 2t$, the radius satisfies $(q/4)^2 = (t/2)^2$. Because
$e_y^2 \geq 0$, we have $e_x^2 < (t/2)^2$. As $t/2 \geq 0$, taking square roots
gives $|e_x| < t/2$, i.e. $2|e_x| < t$. The formalization performs this over
$\mathbb{R}$ (casting the integer errors) using $|x| < c$ from $x^2 < c^2$ with
$c \geq 0$, then transfers back to the integers. $\square$

**Theorem 6.8 (Coordinate bound, imaginary part; `coord_bound_im`).** Under the
same hypotheses, $2|e_y| < t$.

*Proof sketch.* Identical to Theorem 6.7 after swapping the roles of $e_x$ and
$e_y$ (the ball condition is symmetric). $\square$

### 6.4 Decryption correctness

Combining the above yields the main correctness statement.

**Theorem 6.9 (Decryption correctness for ring-LWE over $\mathbb{Z}[i]$).** Let
$q = 2t$ with $t > 0$, let $(m_x, m_y) \in \{0,1\}^2$, and let the error vector
satisfy the Euclidean ball condition

$$e_x^2 + e_y^2 < \left(\frac{q}{4}\right)^2.$$

Then decryption recovers the message exactly:

$$\mathrm{decrypt}\big(t, s,\; \mathrm{encrypt}(t, s, a, e_x, e_y, m_x, m_y)\big)
= (m_x, m_y).$$

*Proof sketch.* By Definition 6.6 the phase is $\phi = (e_x + e_y i) +
\mathrm{encodeMsg}(t, m_x, m_y)$ because the mask $u \cdot s = a \cdot s$ cancels.
Hence $\mathrm{Re}\,\phi = e_x + m_x t$ and $\mathrm{Im}\,\phi = e_y + m_y t$. By
Theorems 6.7 and 6.8, the ball condition gives $2|e_x| < t$ and $2|e_y| < t$.
Applying Theorem 6.2 (`decodeCoord_correct`) to each coordinate yields
$\mathrm{decodeCoord}(t, e_x + m_x t) = m_x$ and likewise for $m_y$. Therefore the
pair returned by `decrypt` is exactly $(m_x, m_y)$. $\square$

The disk $x^2 + y^2 = (q/4)^2$ — a Pythagorean circle — is precisely the boundary
of the region in which correctness is guaranteed.

---

## 7. The algebraic core of the search-to-decision reduction

Correctness is necessary but not sufficient; security rests on reductions. We
formalize the deterministic algebraic core of the LWE search-to-decision
reduction (Regev 2005; Peikert 2009) over a prime field $\mathbb{Z}/p\mathbb{Z}$.

**Theorem 7.1 (Affine bijectivity; `ZMod.affine_bijective`).** Let $p$ be prime
and $a, b \in \mathbb{Z}/p\mathbb{Z}$ with $a \neq 0$. Then the affine map
$x \mapsto a x + b$ is a bijection of $\mathbb{Z}/p\mathbb{Z}$.

*Proof sketch.* For prime $p$, $\mathbb{Z}/p\mathbb{Z}$ is a field, so
multiplication by $a \neq 0$ is injective, hence (on a finite type) bijective.
Composing with the translation $x \mapsto x + b$, itself a bijection, preserves
bijectivity. $\square$

This is the mechanism by which "wrong guesses" in the coordinate-by-coordinate
hybrid produce *uniform* re-randomized samples: an affine re-randomization of the
public component preserves uniformity exactly when $a \neq 0$. Two immediate
consequences used in the hybrid analysis:

- **Summation invariance (`ZMod.sum_affine_eq`).** For any
  $f : \mathbb{Z}/p\mathbb{Z} \to \mathbb{R}$ and $a \neq 0$,
  $\sum_x f(a x + b) = \sum_x f(x)$ (reindexing along the affine bijection).
- **Full-image preservation (`ZMod.affine_image_univ`).** The affine image of
  the whole space is the whole space.

**Theorem 7.2 (Per-coordinate advantage bound; `search_to_decision_advantage_bound`).**
Let $n \geq 1$, $\delta \in \mathbb{R}$, and let $\mathrm{coordAdvantage} :
\{0, \dots, n-1\} \to \mathbb{R}$ satisfy $\delta \leq \sum_i
\mathrm{coordAdvantage}(i)$. Then there exists an index $i$ with

$$\mathrm{coordAdvantage}(i) \geq \frac{\delta}{n}.$$

*Proof sketch.* Pigeonhole. If every coordinate had advantage strictly below
$\delta / n$, then the sum would be strictly below $n \cdot (\delta/n) = \delta$,
contradicting the hypothesis $\delta \leq \sum_i \mathrm{coordAdvantage}(i)$. $\square$

This is the source of the standard factor-$n$ advantage loss in the
search-to-decision reduction, and it is tight for the coordinate-by-coordinate
strategy.

### 7.1 Noise accumulation and rounding correctness

The catalog core also supplies the analytic bounds underlying Regev-style
encryption:

**Theorem 7.3 (Noise accumulation; `noise_accumulation_bound`).** If $|e_i| \leq
B$ for $i = 1, \dots, m$, then $\left|\sum_i e_i\right| \leq m B$.

*Proof sketch.* Triangle inequality followed by termwise bounding:
$\left|\sum_i e_i\right| \leq \sum_i |e_i| \leq \sum_i B = m B$. $\square$

**Theorem 7.4 (Rounding correctness; `regev_rounding_bit1`).** For $q > 0$ and
$|e| < q/4$, the noisy encoding $q/2 + e$ of the bit $1$ lies strictly in the
interval $(q/4,\ 3q/4)$.

*Proof sketch.* From $|e| < q/4$ we get $-q/4 < e < q/4$; adding $q/2$ gives
$q/4 < q/2 + e < 3q/4$ by linear arithmetic. $\square$

These (with their companions `regev_rounding_bit0`,
`regev_encryption_rounding_correctness`, and `encoding_separation`) confirm that
the $q/4$ rounding radius separates the two codewords $0$ and $q/2$.

---

## 8. The Regev certificate interface

Regev's worst-case→decision reduction is quantum and analytic; we do **not**
reprove it. Instead we isolate it as an explicit assumption and prove all
deterministic algebra downstream.

**Definition 8.1 (Crypto reduction).** A `CryptoReduction` is a multiplicative
advantage-loss factor $\ell > 0$ together with the bookkeeping that composes
reductions: if reduction $R_1$ loses a factor $\ell_1$ and $R_2$ loses $\ell_2$,
then $R_1 \circ R_2$ loses $\ell_1 \ell_2$ (`reduction_compose_loss`).

**Definition 8.2 (Regev reduction certificate; `RegevReductionCertificate`).** For
real parameters $(n, q, \alpha, \gamma)$, a certificate bundles: $n \geq 0$,
$\alpha > 0$, $q > 0$; the noise-feasibility condition $\alpha q \geq 2\sqrt{n}$;
the approximation-factor relation $\gamma = n/\alpha$ (Regev's $\tilde{O}(n/\alpha)$
relation); and an *assumed* worst-case→decision reduction
(`quantumReduction : CryptoReduction`).

**Theorem 8.3 (Approximation-factor bound; `RegevReductionCertificate.approx_factor_le`).**
Any certificate satisfies

$$\gamma \leq \frac{q\sqrt{n}}{2}.$$

*Proof sketch.* Substitute $\gamma = n/\alpha$ and apply
`approx_factor_upper_bound`: from $\alpha q \geq 2\sqrt{n}$, $\alpha > 0$, and
$(\sqrt n)^2 = n$, the inequality $n/\alpha \leq q\sqrt n / 2$ follows by
clearing the positive denominator $\alpha$ and a nonlinear arithmetic step. $\square$

**Theorem 8.4 (Worst-case → search-LWE; `regev_certificate_gives_worst_case_to_search_lwe`).**
Given a certificate, a search-to-decision reduction, and the matching advantage
hypotheses $\mathrm{adv}_{\text{dec}} \leq \ell_{\text{quantum}} \cdot
\mathrm{adv}_{\text{wc}}$ and $\mathrm{adv}_{\text{search}} \leq
\ell_{\text{s2d}} \cdot \mathrm{adv}_{\text{dec}}$, one obtains both the
approximation bound $\gamma \leq q\sqrt n / 2$ and the composed worst-case →
search-LWE advantage bound

$$\mathrm{adv}_{\text{search}} \leq (\ell_{\text{quantum}} \cdot
\ell_{\text{s2d}}) \cdot \mathrm{adv}_{\text{wc}}.$$

*Proof sketch.* The first conjunct is Theorem 8.3. The second is
`reduction_compose_loss` applied to the two advantage hypotheses, multiplying the
loss factors. No part of Regev's quantum reduction is reproved; it enters only
through the certificate field and the supplied hypothesis. $\square$

Supporting parameter-algebra lemmas include `approx_factor_boundary_identity`
(at the boundary $\alpha q = 2\sqrt n$, $n/\alpha = q\sqrt n / 2$),
`noise_feasible_of_dimension_ge_one` ($n \geq 1$ and feasibility give
$\alpha q \geq 2$), and the monotonicity results `feasibility_mono_modulus` and
`feasibility_mono_noise`.

---

## 9. Algorithms

The development induces several concrete, executable procedures:

1. **Norm-based product encoding (Brahmagupta–Fibonacci composition).** Given two
   sums of two squares, compute the squares representing their product:
   $(a, b), (c, d) \mapsto (ac - bd, ad + bc)$. Complexity $O(1)$ ring
   operations.
2. **Prime classification for modulus selection.** Given a prime $p$, classify it
   as split ($p \equiv 1 \pmod 4$, returning $(a, b)$ with $a^2 + b^2 = p$ via a
   two-squares search) or inert ($p \equiv 3 \pmod 4$). The two-squares search
   runs in $O(\sqrt p)$ trial steps.
3. **Encrypt/decrypt over $\mathbb{Z}[i]$.** Encryption is one ring
   multiplication and two additions; decryption is one ring multiplication, one
   subtraction, and two rounding comparisons. All $O(1)$ ring operations.
4. **Euclidean-ball noise check.** Verify $e_x^2 + e_y^2 < (q/4)^2$ to certify
   that a given error will decrypt correctly. $O(1)$.

---

## 10. Applications

- **Compact post-quantum encryption.** Ring-LWE over $\mathbb{Z}[i]$ packs two
  message bits per ciphertext coordinate, with a clean Euclidean error budget
  that is straightforward to reason about and to parameterize.
- **Parameter selection.** The split/inert dichotomy (Theorems 4.1–4.4) is a
  design rule for choosing moduli with the desired ring structure; the
  certificate interface (Section 8) ties chosen parameters to a worst-case
  hardness guarantee with an explicit approximation factor $\gamma \leq q\sqrt n
  / 2$.
- **Reusable number theory.** Multiplicativity of the norm and the two-squares
  theorem are foundational across algebraic number theory; the formal artifacts
  are directly reusable beyond cryptography.

---

## 11. Discussion

The development is deliberately *layered*: no result is used in its own proof,
and each section builds only on earlier ones. This makes the dependency graph
auditable and the trust story transparent — in particular, the one analytic/
quantum ingredient we do not reprove (Regev's worst-case→decision reduction) is
isolated behind a single explicit hypothesis (`quantumReduction`), so a reader
can see exactly what is assumed and what is proved.

A notable conceptual thread is that the *same* sum-of-two-squares expression
plays three roles: as the ring norm whose multiplicativity (Brahmagupta–
Fibonacci) drives the algebra; as the obstruction governing which primes split
(Fermat); and as the Euclidean ball $x^2 + y^2 < (q/4)^2$ defining the decryption
correctness region. Pythagoras' identity is thus simultaneously the algebra, the
number theory, and the geometry of the scheme.

---

## 12. Future work

Several falsifiable, formalizable conjectures extend this development:

- **Field-ness of inert quotients ⇒ full Gaussian search-to-decision.** For
  $p \equiv 3 \pmod 4$, $\mathbb{Z}[i]/(p) \cong \mathbb{F}_{p^2}$ is a field, so
  affine rerandomization $z \mapsto az + b$ ($a \neq 0$) is a bijection, giving a
  Gaussian search-to-decision reduction with the same per-coordinate $1/n$
  advantage loss.
- **Norm-form noise composition under modulus switching.** Combining two
  Gaussian-LWE samples yields noise with $N(e_1 + u e_2) \leq (\sqrt{N(e_1)} +
  \sqrt{N(e_2)})^2$ for any unit $u$, with equality iff the error vectors are
  collinear.
- **Density of secure parameters.** The split moduli ($p \equiv 1 \pmod 4$) and
  inert moduli ($p \equiv 3 \pmod 4$) are each asymptotically $\tfrac12 \pi(N)$
  (Dirichlet), with a `decide`-checkable finite version.
- **Structure of sums of two squares.** $\{n : \text{sum of two squares}\}$ is
  exactly the image of the norm map, closed under multiplication, with the
  classical even-valuation criterion at primes $\equiv 3 \pmod 4$.
- **Unit group and rerandomization period.** The unit group of $\mathbb{Z}[i]$ is
  $\{1, i, -1, -i\}$ of order $4$, giving a rotation hybrid of period $4$;
  generalizes to $\mathbb{Z}[\zeta]$ for roots of unity $\zeta$.

---

## 13. Conclusion

We have formalized, with machine-checked proofs, the Pythagorean foundations of
ring-LWE over the Gaussian integers: multiplicativity of the norm via the
Brahmagupta–Fibonacci identity (`gaussNorm_mul`), the split/inert prime dichotomy
(`prime_split`, `prime_inert` and companions), a public-key encryption scheme
with a clean decryption-correctness guarantee inside the Euclidean ball of radius
$q/4$ (`decodeCoord_correct`, `coord_bound_re`, `coord_bound_im`), and the
algebraic core of the search-to-decision reduction
(`ZMod.affine_bijective`, `search_to_decision_advantage_bound`) together with a
certificate interface composing the assumed Regev quantum reduction
(`regev_certificate_gives_worst_case_to_search_lwe`). The result is a transparent,
auditable account in which a single classical identity — the sum of two squares —
underlies the algebra, the number theory, and the geometry of a post-quantum
encryption scheme.
