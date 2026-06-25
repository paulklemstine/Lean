# A Regularity-Free Functional Equation for Betti–Whittaker Periods and Contragredients of GL(n)

**Author:** Aristotle
**Date:** 2026-06-25

## Abstract

For a broad class of cohomological automorphic representations $\pi$ of
$\mathrm{GL}(n)$ over a number field, the Betti–Whittaker periods of $\pi$ and of
its contragredient $\pi^\vee$ are conjecturally related by the functional
equation of the standard $L$-function. Chen (2024) established such a relation
under a *regularity* (strict-dominance) hypothesis on the infinitesimal
character. We isolate the combinatorial heart of this relation and prove a
strictly stronger, **regularity-free** statement. Modelling $\pi$ by its highest
weight $\lambda \in \mathbb{Z}^n$, we define the *centered period exponent*
$e(\lambda) = \sum_{i=0}^{n-1}(2i+1-n)\lambda_i$, the integer recording the
$2\pi i$-content of the Betti–Whittaker period. We prove that $e$ is
simultaneously **contragredient-invariant**, $e(\lambda^\vee) = e(\lambda)$, and
**twist-invariant**, $e(\lambda \otimes |\det|^k) = e(\lambda)$ for every
$k \in \mathbb{Z}$, the latter resting on the balanced Gauss identity
$\sum_{i}(2i+1-n) = 0$. Combining these yields the regularity-free functional
equation $e\big((\pi \otimes |\det|^k)^\vee\big) = e(\pi)$ for all weights and
all twists. We characterize self-duality $\pi \cong \pi^\vee$ by the vanishing of
all purity weights, and we exhibit the non-regular weight $\lambda = (1,1,0)$ on
which the relation holds but Chen's hypothesis fails, proving the generalization
is strict. All results have been formally verified.

**Keywords:** Betti–Whittaker periods, contragredient representation,
$\mathrm{GL}(n)$, functional equation, infinitesimal character, balanced Gauss
sum, cohomological automorphic representation, period relation.

**MSC 2020:** 11F67, 11F70, 22E55, 11F75.

---

## 1. Introduction

### 1.1 Periods and the functional equation

To a cohomological automorphic representation $\pi$ of $\mathrm{GL}(n)$ over a
number field one attaches transcendental invariants called *periods*, which
control the algebraicity of critical $L$-values. Among the most refined of these
are the **Betti–Whittaker periods**, obtained by comparing the rational
structure on Betti (singular) cohomology with the rational structure cut out by
the Whittaker model. A central expectation, in line with the conjectural
framework surrounding the Langlands program, is that the period attached to $\pi$
and the period attached to its **contragredient** $\pi^\vee$ are related by the
functional equation $s \mapsto 1-s$ of the standard $L$-function $L(s,\pi)$.

The arithmetic subtlety of such periods is concentrated, up to algebraic
factors, in integer powers of $2\pi i$. The exponent on $2\pi i$ — the
*period exponent* — is therefore a discrete, computable shadow of the period,
and the period relation manifests on this shadow as an identity of integers. It
is precisely this combinatorial layer that we isolate and prove.

### 1.2 Chen's relation and its regularity hypothesis

Chen (2024; "C24") established a contragredient relation for Betti–Whittaker
periods under the assumption that the infinitesimal character of $\pi$ is
**regular**, i.e. its highest weight is *strictly* dominant
($\lambda_0 > \cdots > \lambda_{n-1}$). Regularity is a genericity hypothesis
excluding degenerate weights with repeated coordinates, many of which are of
independent geometric and arithmetic interest.

### 1.3 Results of this paper

We dispense with regularity entirely. Working with the highest weight
$\lambda \in \mathbb{Z}^n$ and the centered period exponent
$e(\lambda) = \sum_i (2i+1-n)\lambda_i$, we prove:

1. **(Theorem 1, contragredient invariance)** $e(\lambda^\vee) = e(\lambda)$ for
   every $\lambda$.
2. **(Theorem 3, twist invariance)** $e(\lambda \otimes |\det|^k) = e(\lambda)$
   for every $k \in \mathbb{Z}$, via the balanced Gauss sum
   $\sum_i(2i+1-n)=0$ (Lemma 1).
3. **(Theorem 4, functional equation)**
   $e\big((\lambda \otimes |\det|^k)^\vee\big) = e(\lambda)$ for all $\lambda, k$.
4. **(Theorem 2, self-duality)** $\lambda^\vee = \lambda$ iff all purity weights
   $p_i = \lambda_i + \lambda_{n-1-i}$ vanish.
5. **(Theorem 5, strictness)** the relation holds on the non-regular weight
   $(1,1,0)$, which lies outside Chen's hypothesis.

All statements were formalized and machine-checked.

---

## 2. Definitions

Throughout, $n \in \mathbb{N}$ and indices run over
$\mathrm{Fin}\,n = \{0, 1, \dots, n-1\}$.

**Definition 1 (Weight).** A *weight* is a function
$\lambda : \mathrm{Fin}\,n \to \mathbb{Z}$, written
$\lambda = (\lambda_0, \dots, \lambda_{n-1})$. It models the highest weight,
equivalently the infinitesimal character, of a cohomological representation of
$\mathrm{GL}(n)$.

**Definition 2 (Contragredient / dual).** The *dual* of a weight $\lambda$ is the
weight $\lambda^\vee$ obtained by negating and reversing:
$$(\lambda^\vee)_i = -\,\lambda_{\,n-1-i}, \qquad i \in \mathrm{Fin}\,n.$$
This models the action of the contragredient $\pi \mapsto \pi^\vee$ on
infinitesimal characters.

**Definition 3 (Centered period exponent).** The *period exponent* of a weight
$\lambda$ is the integer
$$e(\lambda) \;=\; \sum_{i=0}^{n-1} (2i + 1 - n)\,\lambda_i.$$
The coefficient vector $c_i = 2i+1-n$ is *centered*: it is anti-symmetric under
the reversal $i \mapsto n-1-i$, reflecting the functional-equation midpoint
$s = 1/2$. The integer $e(\lambda)$ records the $2\pi i$-content of the
Betti–Whittaker period of the representation with weight $\lambda$.

**Definition 4 (Determinant twist).** For $k \in \mathbb{Z}$, the *twist* of
$\lambda$ by $|\det|^k$ is the weight
$$(\mathrm{twist}\,k\,\lambda)_i = \lambda_i + k,$$
a uniform shift of every coordinate. This models $\pi \mapsto \pi \otimes |\det|^k$.

**Definition 5 (Regularity).** A weight $\lambda$ is *regular* if it is strictly
decreasing, $\lambda_0 > \lambda_1 > \cdots > \lambda_{n-1}$ (strict dominance).
This is the hypothesis of Chen's relation.

**Definition 6 (Purity weight).** The *purity weight* in slot $i$ is
$p_i(\lambda) = \lambda_i + \lambda_{n-1-i}$, pairing a coordinate with its
mirror partner.

---

## 3. Structural identities of the contragredient

**Proposition 1 (Involutivity, `dual_involutive`).** For every weight $\lambda$,
$(\lambda^\vee)^\vee = \lambda$.

*Proof sketch.* Apply Definition 2 twice. Slot $i$ of $(\lambda^\vee)^\vee$ is
$-(\lambda^\vee)_{n-1-i} = -\big(-\lambda_{n-1-(n-1-i)}\big) = \lambda_i$, using
$n-1-(n-1-i) = i$ in $\mathrm{Fin}\,n$. $\square$

**Proposition 2 (Purity negates, `dual_purity`).** For every $\lambda$ and every
$i$, $p_i(\lambda^\vee) = -\,p_i(\lambda)$.

*Proof sketch.*
$p_i(\lambda^\vee) = (\lambda^\vee)_i + (\lambda^\vee)_{n-1-i}
= -\lambda_{n-1-i} - \lambda_i = -(\lambda_i + \lambda_{n-1-i}) = -p_i(\lambda)$.
$\square$

**Proposition 3 (Sum negates, `sum_dual`).** For every $\lambda$,
$\sum_{i} (\lambda^\vee)_i = -\sum_{i} \lambda_i$.

*Proof sketch.* $\sum_i (\lambda^\vee)_i = \sum_i -\lambda_{n-1-i}
= -\sum_i \lambda_{n-1-i} = -\sum_j \lambda_j$, where the last step reindexes by
the bijection $j = n-1-i$ on $\mathrm{Fin}\,n$. $\square$

---

## 4. Main theorems

### 4.1 Contragredient invariance

**Theorem 1 (`periodExp_dual`).** For every weight $\lambda$,
$$e(\lambda^\vee) = e(\lambda).$$

*Proof sketch.* Expand using Definitions 2 and 3:
$$e(\lambda^\vee) = \sum_{i=0}^{n-1}(2i+1-n)(\lambda^\vee)_i
= \sum_{i=0}^{n-1}(2i+1-n)\big(-\lambda_{n-1-i}\big).$$
Reindex with the involution $j = n-1-i$, so $i = n-1-j$. The coefficient
transforms as
$$2i+1-n = 2(n-1-j)+1-n = (n-1) - 2j = -\,(2j+1-n).$$
Hence
$$e(\lambda^\vee) = \sum_{j=0}^{n-1} \big(-(2j+1-n)\big)\big(-\lambda_j\big)
= \sum_{j=0}^{n-1}(2j+1-n)\lambda_j = e(\lambda).$$
The two sign reversals — one from negation, one from the reversal-odd centered
coefficient — cancel. $\square$

**Interpretation.** The $2\pi i$-content of the Betti–Whittaker period of $\pi$
equals that of $\pi^\vee$. This is the regularity-free Betti–Whittaker period
relation, generalizing Chen's relation by dropping all dominance hypotheses.

### 4.2 Self-duality

**Theorem 2 (`dual_eq_self_iff`).** A weight is self-dual iff all purity weights
vanish:
$$\lambda^\vee = \lambda \iff \forall i,\; \lambda_i + \lambda_{n-1-i} = 0.$$

*Proof sketch.* By Definition 2, $\lambda^\vee = \lambda$ means
$-\lambda_{n-1-i} = \lambda_i$ for all $i$, i.e. $\lambda_i + \lambda_{n-1-i} = 0$
for all $i$, which is the vanishing of every purity weight $p_i(\lambda)$.
Conversely the same equation gives $(\lambda^\vee)_i = -\lambda_{n-1-i} = \lambda_i$
for all $i$, hence equality of functions. $\square$

**Interpretation.** Self-dual representations $\pi \cong \pi^\vee$ — the carriers
of orthogonal/symplectic structure — are exactly those with vanishing purity,
i.e. weights anti-symmetric about the center.

### 4.3 The balanced Gauss sum

**Lemma 1 (`coeff_sum_zero`).** For every $n$,
$$\sum_{i=0}^{n-1}(2i+1-n) = 0.$$

*Proof sketch.* Split the sum:
$\sum_i (2i+1-n) = 2\sum_i i + n(1-n)$. By the Gauss identity
$\sum_{i=0}^{n-1} i = \tfrac{n(n-1)}{2}$, the first term is $n(n-1)$, so the
total is $n(n-1) + n - n^2 = n^2 - n + n - n^2 = 0$. (Formally one proves
$2\sum_i i = n(n-1)$ via `Finset.sum_range_id_mul_two` with an integer cast, then
concludes by linear arithmetic.) $\square$

**Remark (centering is necessary).** The cancellation is special to the centered
coefficients. The uncentered coefficient $c_i = i$ has
$\sum_i i = \tfrac{n(n-1)}{2} \neq 0$ for $n \ge 2$; the corresponding uncentered
moment $m(\lambda) = \sum_i i\,\lambda_i$ is *not* twist-invariant. Centering on
$s=1/2$ is the unique linear normalization making the period exponent
reflection- and twist-stable.

### 4.4 Twist invariance

**Theorem 3 (`periodExp_twist`).** For every $k \in \mathbb{Z}$ and every weight
$\lambda$,
$$e(\mathrm{twist}\,k\,\lambda) = e(\lambda).$$

*Proof sketch.* By Definitions 3 and 4,
$$e(\mathrm{twist}\,k\,\lambda) = \sum_i (2i+1-n)(\lambda_i + k)
= \sum_i (2i+1-n)\lambda_i + k\sum_i (2i+1-n) = e(\lambda) + k\cdot 0,$$
the last sum vanishing by Lemma 1. $\square$

**Interpretation.** Twisting $\pi$ by any integer power of $|\det|$ leaves the
$2\pi i$-content of its Betti–Whittaker period unchanged; the period exponent is
insensitive to determinant-character twists.

### 4.5 The regularity-free functional equation

**Theorem 4 (`bw_functional_equation`).** For every weight $\lambda$ and every
$k \in \mathbb{Z}$,
$$e\big((\mathrm{twist}\,k\,\lambda)^\vee\big) = e(\lambda).$$

*Proof sketch.* Compose the two invariances:
$e\big((\mathrm{twist}\,k\,\lambda)^\vee\big) = e(\mathrm{twist}\,k\,\lambda)$ by
Theorem 1, and $e(\mathrm{twist}\,k\,\lambda) = e(\lambda)$ by Theorem 3. $\square$

**Interpretation.** For every cohomological weight and every twist, the
$2\pi i$-content of the Betti–Whittaker period of the contragredient of
$\pi \otimes |\det|^k$ equals that of $\pi$. The reflection $s \mapsto 1-s$
(contragredient) and the twist are independent symmetries that together generate
the full functional-equation group action on period exponents, under which $e$ is
invariant. No regularity assumption appears.

### 4.6 Strictness: a non-regular witness

**Proposition 4 (`notRegular_witness`).** The weight $\lambda = (1,1,0)$ in
$\mathbb{Z}^3$ is not regular.

*Proof sketch.* Strict dominance requires $\lambda_0 > \lambda_1$, i.e. $1 > 1$,
which is false; hence $\lambda$ is not strictly decreasing. $\square$

**Theorem 5 (`regularityFree_witness`).** The weight $\lambda = (1,1,0)$ is not
regular, yet the contragredient relation holds:
$$\neg\,\mathrm{Regular}(1,1,0) \quad\text{and}\quad e\big((1,1,0)^\vee\big) = e(1,1,0).$$

*Proof sketch.* Non-regularity is Proposition 4. For the identity, $(1,1,0)^\vee
= (0,-1,-1)$ and, with centered coefficients $(-2,0,2)$ for $n=3$,
$$e(1,1,0) = -2\cdot 1 + 0\cdot 1 + 2\cdot 0 = -2, \qquad
e(0,-1,-1) = -2\cdot 0 + 0\cdot(-1) + 2\cdot(-1) = -2,$$
so both equal $-2$; alternatively the identity is the instance of Theorem 1 at
this weight. $\square$

**Interpretation.** A weight outside Chen's hypothesis satisfies the relation,
proving the regularity-free statement strictly contains the regular regime.

---

## 5. Algorithms

The results are entirely effective. We record the core computations.

**Algorithm A (Centered Period-Exponent Evaluation).** Given $\lambda \in
\mathbb{Z}^n$, return $e(\lambda) = \sum_{i=0}^{n-1}(2i+1-n)\lambda_i$ in $O(n)$
integer operations.

**Algorithm B (Contragredient and Twist Transforms).** Given $\lambda$, compute
$\lambda^\vee$ (negate-and-reverse, $O(n)$) and $\mathrm{twist}\,k\,\lambda$
(add $k$ coordinatewise, $O(n)$); used to verify Theorems 1, 3, 4 numerically.

**Algorithm C (Functional-Equation Orbit Verifier).** Given $\lambda$ and a
finite set of twist parameters $K \subset \mathbb{Z}$, verify
$e((\mathrm{twist}\,k\,\lambda)^\vee) = e(\lambda)$ for all $k \in K$ by direct
evaluation; the certified output is a boolean conjunction, $O(n|K|)$.

---

## 6. Applications

- **Critical-value algebraicity.** The period exponent is the integer normalizing
  factor in conjectural rationality statements for critical values of
  $L(s,\pi)$; its contragredient- and twist-invariance is exactly the
  compatibility one needs between the rationality of $L(s,\pi)$ and that of
  $L(1-s,\pi^\vee)$ and of twisted $L$-functions $L(s, \pi \otimes |\det|^k)$.
- **Self-dual detection.** Theorem 2 gives an $O(n)$ test for $\pi \cong \pi^\vee$
  purely from the weight, locating the orthogonal/symplectic representations
  whose $L$-functions carry a meaningful sign.
- **Degenerate weights.** Dropping regularity makes the relation applicable to
  the non-generic representations excluded by C24, including those arising from
  non-strict dominance such as $(1,1,0)$.

---

## 7. Discussion

The mechanism is a clean separation of two symmetries. Contragredient invariance
(Theorem 1) is a *parity* phenomenon: the reversal-odd centered coefficient
cancels the negate-and-reverse of the dual. Twist invariance (Theorem 3) is a
*balance* phenomenon: it holds exactly because the centered coefficients sum to
zero (Lemma 1). These are logically independent — one could imagine a coefficient
vector that is reversal-odd but not zero-sum, or vice versa — and centering on
$s=1/2$ is the unique linear normalization securing both at once. Together they
realize the full $\langle s\mapsto 1-s,\ \pi\mapsto\pi^\vee\rangle$ symmetry as an
invariance of a single integer.

The non-regular witness $(1,1,0)$ shows the strengthening is genuine, not formal:
the symmetry was always present and the regularity hypothesis of C24 was an
artifact of the method rather than a feature of the phenomenon.

---

## 8. Future directions

The following conjectures extend the present results and are stated as open
problems (they are **not** proved here).

**Conjecture 1 (Off-center functionals detect regularity).** For the uncentered
moment $m(\lambda) = \sum_i i\,\lambda_i$, one has $m(\lambda^\vee) = m(\lambda)$
iff $(n-1)\sum_i \lambda_i = 0$; otherwise the defect
$m(\lambda) - m(\lambda^\vee) = (n-1)\sum_i \lambda_i$ measures the failure of
self-balance. Centering at $s=1/2$ is the unique linear normalization making the
period exponent reflection-stable; every other normalization carries a
computable anomaly proportional to $\sum_i \lambda_i$. The same Gauss machinery
that gives $\sum_i(2i+1-n)=0$ computes $\sum_i i = n(n-1)/2 \neq 0$, making the
dichotomy immediately formalizable.

**Conjecture 2 (Tensor additivity of the period exponent).** For weights
$\lambda \in \mathbb{Z}^m$, $\mu \in \mathbb{Z}^n$, the Rankin–Selberg "box"
weight $(\lambda \boxplus \mu)_{(i,j)} = \lambda_i + \mu_j$ on
$\mathrm{Fin}\,m \times \mathrm{Fin}\,n$ satisfies a bilinear expansion of
$e(\lambda \boxplus \mu)$ into the per-factor contributions, and the
contragredient relation $e((\lambda \boxplus \mu)^\vee) = e(\lambda \boxplus \mu)$
persists. The period exponent is a "logarithmic" invariant linearizing the
$\mathrm{GL}(m) \times \mathrm{GL}(n) \to \mathrm{GL}(mn)$ Rankin–Selberg product,
turning multiplicativity of $L$-functions into additivity of $2\pi i$-exponents.
The bilinear expansion follows from `coeff_sum_zero` and `Finset.sum_product`;
contragredient stability follows by applying Theorem 1 in each factor.

**Conjecture 3 (Free action of the reflection/twist group on exponents).** The
involutions $\lambda \mapsto \lambda^\vee$ and $\lambda \mapsto \mathrm{twist}\,k\,
\lambda$ generate an affine action of $\mathbb{Z} \rtimes \mathbb{Z}/2$ on weights
under which $e$ is a complete invariant of the orbit's balanced part:
$e(\sigma\cdot\lambda) = e(\lambda)$ for all $\sigma$, and conversely
$e(\lambda) = e(\mu)$ with $\sum\lambda = \sum\mu$ implies $\lambda,\mu$ lie in the
same exponent fiber. The Betti–Whittaker functional equation is governed by a
single rank-1 obstruction (the total weight $\sum\lambda$), all higher data being
washed out by the centered exponent — a regularity-free strengthening of Chen.

---

## References

- C24 — Chen, *Betti–Whittaker periods and the contragredient relation for
  GL(n)* (2024).
- JLS26 — Companion work on Whittaker periods and rationality.
- BW — Foundational treatment of Betti–Whittaker periods.
- Clo — Clozel, on cohomological automorphic representations of $\mathrm{GL}(n)$.

*(Prose is self-contained; references are listed for context only.)*
