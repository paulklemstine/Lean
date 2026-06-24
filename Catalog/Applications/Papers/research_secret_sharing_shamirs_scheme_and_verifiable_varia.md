# Threshold Secret Sharing and Verifiable Variants: Reconstruction, Information-Theoretic Privacy, and the Detection of Malicious Dealers

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Cryptography (with bridges to Algebra: polynomial evaluation and homomorphic commitments)

---

## Abstract

We present a self-contained, rigorously verified treatment of threshold secret
sharing and its verifiable extension. Working over an arbitrary field $F$ (in
practice a finite field $\mathbb{Z}_p$), we model Shamir's $(t,n)$ scheme by
encoding a secret as the constant term of a polynomial of degree less than $t$ and
distributing evaluations of that polynomial as shares. We establish three
foundational guarantees: **reconstruction** (any $t$ shares determine the secret),
**information-theoretic privacy** (any $t-1$ shares are consistent with every
possible secret, hence reveal nothing), and **threshold sharpness** ($t-1$ shares
are insufficient). The governing principle is that *the reconstruction threshold
equals the degree of the sharing polynomial plus one*.

We then formalize **Feldman's Verifiable Secret Sharing (VSS)**, which augments
Shamir's scheme with homomorphic commitments to the polynomial coefficients so that
a possibly malicious dealer is forced to commit to a single sharing polynomial and
every participant can verify its own share without learning others'. Modeling the
prime-order group additively as a field $F$ with a fixed nonzero generator $g$
(group exponentiation $g^a$ being the scalar multiple $a \cdot g$), we prove:
**completeness** (honest shares always verify), an exact **verification
characterization** (a claimed share verifies iff it equals the committed
evaluation), **soundness** (any deviating share is rejected — cheating dealers are
caught), and **binding** (the commitment vector determines the polynomial
uniquely, precluding equivocation). All results are derived from a single algebraic
identity — that the homomorphic combination of coefficient commitments reproduces
the commitment to the share — together with the injectivity of $a \mapsto a\cdot g$
when $g \neq 0$. We give proof sketches, algorithms, numerical demonstrations, and
a discussion of extensions (Pedersen commitments, quantitative privacy, robust
reconstruction).

---

## 1. Introduction

Secret sharing addresses a fundamental tension in information security: a secret
stored in a single location is *fragile* (a single failure destroys it) while a
secret replicated across many locations is *leaky* (any single compromise exposes
it). Shamir (1979) resolved this tension with a *threshold* scheme: a secret is
split into $n$ shares so that any $t$ of them reconstruct it while any $t-1$ reveal
nothing whatsoever. The construction is elementary — it rests on polynomial
interpolation over a field — yet its privacy guarantee is the strongest possible:
*information-theoretic* (perfect) security, immune even to a computationally
unbounded adversary.

Shamir's scheme assumes an honest dealer. A malicious dealer can distribute
*inconsistent* shares that cause different reconstructing coalitions to recover
different secrets, with no participant able to detect the fault locally. Feldman
(1987) closed this gap with **Verifiable Secret Sharing (VSS)**: the dealer
publishes cryptographic commitments to the polynomial's coefficients, and each
participant verifies its share against these public commitments. The verification
neither reveals other shares nor the secret, yet it catches any cheating dealer.

This paper formalizes both schemes and their guarantees. Section 2 fixes notation
and definitions. Section 3 develops Shamir's reconstruction and privacy. Section 4
develops Feldman's VSS: the central commitment identity and the completeness,
soundness, and binding theorems. Section 5 gives algorithms; Section 6, numerical
demonstrations; Section 7, applications; Section 8, discussion and future work.

---

## 2. Preliminaries and Definitions

Throughout, $F$ is a field. For threshold $t$, sharing polynomials are drawn from
$F[X]$ with degree strictly less than $t$. We write $f.\mathrm{eval}(x)$ for the
evaluation of $f \in F[X]$ at $x \in F$, and $f.\mathrm{coeff}(j)$ for its $j$-th
coefficient.

**Definition 2.1 (Shamir sharing).** Fix a threshold $t \geq 1$ and distinct
nonzero evaluation points $x_1, \dots, x_n \in F$. A dealer encodes a secret
$c \in F$ by choosing a polynomial
$$f(X) = c + a_1 X + a_2 X^2 + \cdots + a_{t-1} X^{t-1}, \qquad \deg f < t,$$
with $f(0) = c$ and $a_1, \dots, a_{t-1}$ chosen uniformly at random. The **share**
of the participant at point $x_i$ is $s_i = f(x_i)$. The **secret** is $c = f(0)$.

**Definition 2.2 (Reconstruction via Lagrange interpolation).** Given $t$ pairs
$(x_i, s_i)$ with distinct $x_i$, the unique polynomial $f$ of degree $< t$ through
them is
$$f(X) = \sum_{i=1}^{t} s_i \prod_{\substack{1 \le m \le t \\ m \ne i}} \frac{X - x_m}{x_i - x_m},$$
and the secret is recovered as $c = f(0) = \sum_{i=1}^{t} s_i \prod_{m \ne i} \frac{-x_m}{x_i - x_m}.$

**Definition 2.3 (Group model for commitments).** Following the additive convention
for prime-order cyclic groups, we model the group as the field $F$ with a fixed
nonzero generator $g \in F$. Group exponentiation $g^a$ is the scalar multiple
$a \cdot g$. The map $a \mapsto a \cdot g$ is the commitment primitive; over a real
deployment $F$ is replaced by a cyclic group in which discrete logarithms are hard,
making the map computationally one-way while remaining a group homomorphism.

**Definition 2.4 (Feldman commitment).** For a polynomial $f \in F[X]$ and
generator $g$, the $j$-th **Feldman commitment** is
$$\mathrm{feldmanCommit}(g, f, j) \;=\; f.\mathrm{coeff}(j) \cdot g \;=\; a_j \cdot g.$$
The dealer publishes $C_j = \mathrm{feldmanCommit}(g, f, j)$ for $0 \le j < t$.

**Definition 2.5 (Feldman verification predicate).** A claimed share value $s$ at
point $x$, checked against published commitments $C : \mathbb{N} \to F$ with
threshold $t$, **verifies** iff
$$\mathrm{FeldmanVerifies}(g, t, C, x, s) \;:\Longleftrightarrow\; s \cdot g \;=\; \sum_{j=0}^{t-1} x^{j}\, C_j .$$

---

## 3. Shamir's Scheme: Reconstruction and Privacy

The entire behavior of Shamir's scheme follows from a single structural fact about
polynomials over a field.

**Fundamental interpolation principle.** A polynomial of degree $< t$ over a field
is uniquely determined by its values at any $t$ distinct points, and is left
completely free by its values at any $t-1$ points. Equivalently, the evaluation map
$f \mapsto (f(x_1), \dots, f(x_t))$ is a linear isomorphism from the space of
degree-$<t$ polynomials to $F^t$ when the $x_i$ are distinct.

### 3.1 Reconstruction

**Theorem 3.1 (shamir_reconstruction).** *Let $f \in F[X]$ have degree $< t$ and
let $x_1, \dots, x_t$ be distinct points with shares $s_i = f(x_i)$. Then $f$ is the
unique degree-$<t$ polynomial through the $(x_i, s_i)$, and the secret is recovered
exactly as $c = f(0)$ by Lagrange interpolation (Definition 2.2).*

*Proof sketch.* Existence is immediate: $f$ itself passes through its own
evaluation points. Uniqueness follows because the difference of two degree-$<t$
polynomials agreeing at $t$ distinct points is a degree-$<t$ polynomial with $t$
roots, hence zero. The Lagrange formula is the explicit inverse of the (invertible,
Vandermonde) evaluation map, so evaluating it at $0$ returns $f(0) = c$. $\square$

This theorem is the precise sense in which **the reconstruction threshold equals the
degree of the polynomial plus one**: a degree-$(t-1)$ polynomial needs exactly
$t = (t-1)+1$ points to be pinned down.

### 3.2 Information-Theoretic Privacy

**Theorem 3.2 (shamir_privacy).** *Fix a coalition of $t-1$ evaluation points
$x_1, \dots, x_{t-1}$ (all nonzero, distinct) and observed shares
$y_1, \dots, y_{t-1}$. For **every** candidate secret $c \in F$ there exists a
unique polynomial $f$ of degree $< t$ with $f(0) = c$ and $f(x_i) = y_i$ for all
$i$.*

*Proof sketch.* The $t-1$ coalition constraints together with the constraint
$f(0) = c$ impose $t$ interpolation conditions at $t$ distinct points (the $x_i$
together with $0$). By the fundamental interpolation principle there is exactly one
degree-$<t$ polynomial meeting all $t$ conditions. As $c$ ranges over $F$, these
unique polynomials are pairwise distinct (they differ at $0$), establishing a
bijection between secrets and consistent polynomials. $\square$

**Interpretation.** Every secret is consistent with exactly one sharing polynomial
explaining the observed $t-1$ shares; the coalition's view is identical across all
secrets. If the unknown coefficients were chosen uniformly, the posterior
distribution over the secret given $t-1$ shares equals its prior. The shares carry
**zero information** about the secret — *perfect* (information-theoretic) security,
independent of any computational assumption.

**Theorem 3.3 (shamir_insufficient).** *Any $t-1$ shares are insufficient to
determine the secret: there exist (in fact, for each element of $F$, exactly one)
distinct degree-$<t$ polynomials consistent with the observed $t-1$ shares but
yielding different secrets. Hence the threshold $t$ is sharp.*

*Proof sketch.* Immediate from Theorem 3.2: distinct $c \neq c'$ yield distinct
consistent polynomials $f \neq f'$ with $f(0) = c \neq c' = f'(0)$, both matching
the same observed shares. $\square$

Together, Theorems 3.1–3.3 give the complete characterization of a $(t,n)$
threshold scheme: *exactly* $t$ shares reconstruct and *any* $t-1$ are perfectly
private.

---

## 4. Feldman's Verifiable Secret Sharing

Shamir's guarantees presuppose an honest dealer. A malicious dealer may distribute
shares that do not lie on any single degree-$<t$ polynomial, so that distinct
coalitions reconstruct distinct secrets — undetectably at share-receipt time.
Feldman's VSS removes this trust assumption by having the dealer commit publicly to
each coefficient.

### 4.1 The Commitment Identity

**Theorem 4.1 (feldman_commitment_eval).** *Let $f \in F[X]$ with
$f.\mathrm{natDegree} < t$, let $g \in F$, and let $x \in F$. Then*
$$\sum_{j=0}^{t-1} x^{j}\, \mathrm{feldmanCommit}(g, f, j) \;=\; f(x)\cdot g.$$

*Proof sketch.* Since $\deg f < t$, the truncated sum $\sum_{j<t} f.\mathrm{coeff}(j)\,x^j$
equals $f(x)$ (Mathlib's `eval_eq_sum_range'` under the degree bound). Substituting
$\mathrm{feldmanCommit}(g,f,j) = f.\mathrm{coeff}(j)\cdot g$ and factoring the common
$g$ out of the finite sum (distributivity, `Finset.mul_sum`):
$$\sum_{j<t} x^j\,(f.\mathrm{coeff}(j)\cdot g) = \Big(\sum_{j<t} f.\mathrm{coeff}(j)\,x^j\Big)\cdot g = f(x)\cdot g. \qquad \square$$

This is the algebraic heart of Feldman verification: the homomorphic combination of
the coefficient commitments reproduces the commitment to the share value $f(x)$. The
degree bound $\mathrm{natDegree} < t$ is load-bearing — it makes the finite
$\mathrm{range}\,t$ sum faithful to $f.\mathrm{eval}$; without it, high-degree
coefficients escape the commitment and verification loses meaning.

### 4.2 Completeness

**Theorem 4.2 (feldman_complete).** *For $f$ with $\deg f < t$ and any $x$, the
honest share $f(x)$ verifies:* $\mathrm{FeldmanVerifies}(g, t, \mathrm{feldmanCommit}(g,f), x, f(x))$.

*Proof sketch.* Unfold the predicate: the goal is $f(x)\cdot g = \sum_{j<t} x^j C_j$,
which is exactly Theorem 4.1 read right-to-left. Notably this requires **no**
assumption on $g$ — completeness holds even for $g = 0$, correctly reflecting that
completeness needs no generator hypothesis. $\square$

### 4.3 Soundness: Cheating Dealers Are Caught

**Theorem 4.3 (feldman_verify_iff).** *Suppose $g \neq 0$ and $\deg f < t$. Then a
claimed share $s$ at point $x$ verifies against the honest commitments if and only
if it equals the committed evaluation:*
$$\mathrm{FeldmanVerifies}(g, t, \mathrm{feldmanCommit}(g,f), x, s) \iff s = f(x).$$

*Proof sketch.* By Definition 2.5 and Theorem 4.1, the predicate is $s\cdot g =
f(x)\cdot g$. Since $g \neq 0$ and $F$ is a field, $a \mapsto a\cdot g$ is injective
(`mul_left_cancel₀`), so $s\cdot g = f(x)\cdot g \iff s = f(x)$. The converse
direction is substitution. $\square$

**Theorem 4.4 (feldman_catches_cheater).** *Suppose $g \neq 0$ and $\deg f < t$. If
a claimed share $s$ differs from the committed evaluation, $s \neq f(x)$, then it is
rejected:* $\neg\,\mathrm{FeldmanVerifies}(g, t, \mathrm{feldmanCommit}(g,f), x, s)$.

*Proof sketch.* Contrapositive of Theorem 4.3: if verification held, the iff would
force $s = f(x)$, contradicting $s \neq f(x)$. $\square$

Theorem 4.4 is the formal statement that **cheating dealers are caught**: against a
nonzero generator, the *only* share value that passes verification at point $x$ is
the honest $f(x)$. Any forgery, corruption, or inconsistency is rejected with
certainty. The hypothesis $g \neq 0$ is essential: a zero generator maps every
value to $0$ and hides all discrepancies.

### 4.4 Binding

**Theorem 4.5 (feldman_binding).** *Suppose $g \neq 0$. If two polynomials $f, f'$
of degree $< t$ produce identical Feldman commitments on all of $\mathrm{range}\,t$,
i.e. $\mathrm{feldmanCommit}(g,f,j) = \mathrm{feldmanCommit}(g,f',j)$ for all
$j < t$, then $f = f'$.*

*Proof sketch.* By polynomial extensionality it suffices to show $f.\mathrm{coeff}(j)
= f'.\mathrm{coeff}(j)$ for every $j$. For $j < t$: the commitment equality gives
$f.\mathrm{coeff}(j)\cdot g = f'.\mathrm{coeff}(j)\cdot g$, and cancelling the
nonzero $g$ yields equal coefficients. For $j \ge t$: both coefficients vanish since
$\deg f, \deg f' < t$ (`coeff_eq_zero_of_natDegree_lt`). Hence $f = f'$. $\square$

**Interpretation.** The commitment vector determines the polynomial uniquely: once
the dealer broadcasts $(C_0, \dots, C_{t-1})$, it is bound to a single sharing
polynomial and cannot later equivocate, claiming to have shared a different curve.
Binding is the coefficient-wise cancellation analogue of the pointwise cancellation
used in soundness; both are instances of injectivity of $a \mapsto a\cdot g$.

### 4.5 Synthesis

Feldman's VSS is exactly **Shamir + a binding homomorphic commitment**. Privacy is
inherited from Shamir (the commitments $a_j\cdot g$ are one-way and reveal nothing
about the coefficients under the discrete-log assumption), while
`feldman_verify_iff` and `feldman_binding` add *public verifiability* against a
malicious dealer. Every Feldman guarantee reduces to one algebraic identity
(Theorem 4.1) plus injectivity of $(\cdot\, g)$ on a field with $g \neq 0$ —
soundness and binding being the pointwise and coefficient-wise cancellation
directions respectively.

---

## 5. Algorithms

**Algorithm A — Shamir Share Generation.** Given secret $c$, threshold $t$, and
points $x_1, \dots, x_n$: sample random $a_1, \dots, a_{t-1} \in F$, form
$f(X) = c + \sum_{k=1}^{t-1} a_k X^k$, and output shares $s_i = f(x_i)$ by Horner
evaluation. Complexity $O(nt)$ field operations.

**Algorithm B — Lagrange Reconstruction.** Given $t$ pairs $(x_i, s_i)$ with
distinct $x_i$, evaluate the Lagrange interpolant at $0$:
$c = \sum_{i} s_i \prod_{m\ne i} \frac{-x_m}{x_i - x_m}$. Complexity $O(t^2)$ field
operations, including one inversion per Lagrange basis weight.

**Algorithm C — Feldman Commit & Verify.** The dealer publishes
$C_j = a_j\cdot g$ for $0 \le j < t$. A participant with claimed share $(x, s)$
accepts iff $s\cdot g = \sum_{j<t} x^j C_j$, evaluated by Horner's rule in the
exponent. Verification cost $O(t)$ group operations per share; by Theorem 4.3 it
accepts exactly when $s = f(x)$.

---

## 6. Numerical Demonstrations

The companion `demo.py` realizes all results over the prime field
$\mathbb{Z}_p$ with $p = 2{,}087$ (and other primes), using pure-Python modular
arithmetic. It demonstrates: (i) round-trip sharing/reconstruction from any $t$
shares (Theorem 3.1); (ii) that all $\binom{n}{t}$ choices of $t$ shares recover the
same secret for an honest dealer; (iii) perfect privacy by exhibiting, for fixed
$t-1$ shares, exactly one consistent polynomial per candidate secret (Theorem 3.2),
so the count of consistent polynomials equals $p$ (one per secret); (iv) Feldman
commitment verification accepting honest shares (Theorem 4.2) and rejecting every
tampered share (Theorem 4.4); and (v) binding, by confirming that distinct
polynomials never collide in commitments (Theorem 4.5).

---

## 7. Applications

- **Threshold key custody.** Private keys for high-value assets (cryptocurrency
  wallets, signing keys, HSMs) are split so any $t$-of-$n$ quorum can operate while
  no minority can leak or misuse the key.
- **Distributed key generation (DKG).** Mutually distrustful parties jointly
  generate a key none ever holds alone; Feldman VSS lets each party verify others'
  contributions and identify saboteurs — a core primitive of threshold signatures,
  blockchains, and secure multiparty computation.
- **Resilient archival.** Estates, password-manager master secrets, and disaster
  recovery: survive both loss and betrayal simultaneously.
- **Electronic voting and auctions.** Verifiable sharing underpins protocols where
  inputs must remain private yet provably well-formed.

---

## 8. Discussion and Future Work

The formal development isolates the minimal algebraic content of each guarantee.
Shamir's privacy is *not* a computational assumption but a genuine absence of
information, equivalent to the invertibility of a Vandermonde evaluation map.
Feldman's verifiability is a one-line homomorphism identity plus field cancellation.
A noted limitation: Feldman commitments are *binding but not hiding* — they leak
$a_j\cdot g$, which under discrete-log hardness hides $a_j$ computationally but not
information-theoretically; in particular the commitment to the secret, $C_0 = c\cdot
g$, leaks $c\cdot g$.

Future directions (carried from the originating research cycle):

- **Perfect secrecy as an explicit equivalence.** Package the per-secret uniqueness
  of Theorem 3.2 into a bijection $F \simeq \{f : \deg f < t,\ f|_s = y\}$ between
  secrets and consistent polynomials, making "uniform over secrets" a first-class
  object.
- **Quantitative privacy over finite fields.** Over $\mathbb{Z}_p$, prove the number
  of consistent degree-$<t$ polynomials is exactly $p$ regardless of the observed
  $t-1$ shares, upgrading information-theoretic security to a `PMF`-level uniformity
  statement ("$t-1$ shares reveal zero bits").
- **Pedersen commitments.** Replace $a_j\cdot g$ by $a_j\cdot g + r_j\cdot h$ with a
  second independent generator $h$, trading perfect binding for computational
  binding while gaining *unconditional hiding* — a provable Feldman/Pedersen
  separation.
- **Robust reconstruction.** With at most $e < (n-t+1)/2$ corrupted shares,
  Reed–Solomon / Berlekamp–Welch decoding recovers $f$ uniquely; Shamir shares are a
  Reed–Solomon codeword, so robustness is the minimum-distance bound
  $d = n - t + 1$, bridging secret sharing and coding theory.

---

## 9. Conclusion

We have given a complete, rigorously verified account of threshold secret sharing
and its verifiable upgrade. Shamir's scheme delivers exact reconstruction from $t$
shares and *perfect* privacy below the threshold, governed by the principle that the
reconstruction threshold equals the polynomial degree plus one. Feldman's VSS adds
public verifiability against a malicious dealer through homomorphic coefficient
commitments, with completeness, exact soundness (cheaters caught), and binding all
flowing from one commitment identity and the injectivity of multiplication by a
nonzero generator. The result is a primitive that is simultaneously available,
confidential, and accountable.
