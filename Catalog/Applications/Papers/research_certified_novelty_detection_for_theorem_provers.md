# Certified Novelty Detection for Theorem Provers: A Metric Embedding Approach

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications

## Abstract

We develop and formally verify the metric core of a *novelty certification
system* for automated mathematical research engines. Each known result is mapped
to a point of a pseudometric space $X$ — the **theorem embedding space** — and the
set of known results is modeled as a finite catalog $C \subseteq X$. We define the
**novelty** of a candidate output $x$ as its distance to the nearest catalog
entry, $\operatorname{novelty}(C, x) = \min_{c \in C} \operatorname{dist}(x, c)$,
and a **novelty certificate at level $\varepsilon$** as a proof of
$\varepsilon \le \operatorname{novelty}(C, x)$ with $\varepsilon > 0$. We prove
four guarantees that justify the slogan *distance bounds novelty*: **soundness**
(a positive certificate proves $x \notin C$), **separation** (an
$\varepsilon$-certificate proves $x$ is $\varepsilon$-far from every catalog
entry), **stability** (novelty is $1$-Lipschitz, so a bounded embedding error
perturbs the certified novelty by at most the same bound), and **monotonicity**
(enlarging the catalog can only decrease novelty). We give an incremental update
law for streaming catalogs, a packing/covering **novelty budget** bounding the
number of mutually-novel results in a bounded space, and — by instantiating the
abstract machinery on the Fibonacci primitive prime divisor theorem — an
*unbounded* stream of certifiably-novel theorems. All results have been formalized
and machine-checked.

## 1. Introduction

Automated research engines that generate, prove, and archive mathematical
statements face a foundational quality-control problem: distinguishing genuinely
new output from rediscoveries of cataloged knowledge. Human mathematicians
adjudicate novelty by intuition; an autonomous system requires something stronger
than a heuristic label — it requires a *certificate* of novelty that is sound,
quantitative, robust to numerical error, and cheap to verify.

This paper formalizes such a certificate. Our contributions are:

1. A definition of novelty as distance-to-catalog in a pseudometric *theorem
   embedding space*, and of a novelty certificate as a single verified inequality
   (Section 3).
2. **Soundness** and **separation** theorems showing a positive certificate
   proves genuine absence from the catalog with a quantitative margin against
   *every* entry (Section 4).
3. A **$1$-Lipschitz stability** theorem — the load-bearing robustness result —
   making numerically computed distances into genuine certificates (Section 5).
4. **Monotonicity** and an **incremental update law** for streaming catalogs
   (Section 6).
5. A packing/covering **novelty budget** in bounded spaces, contrasted with an
   **unbounded novelty stream** derived from Carmichael's Fibonacci primitive
   divisor theorem (Section 7).

Throughout, the design choices are deliberately *conservative*: we use a
pseudometric (not a metric) so that distinct results with identical embeddings are
correctly reported as non-novel, and we carry nonemptiness of the catalog
explicitly rather than assigning a junk value to the empty minimum.

## 2. Preliminaries

Let $X$ be a **pseudometric space**: a type equipped with a distance
$\operatorname{dist} : X \times X \to \mathbb{R}$ satisfying, for all $x, y, z$,

- non-negativity, $\operatorname{dist}(x, y) \ge 0$;
- $\operatorname{dist}(x, x) = 0$;
- symmetry, $\operatorname{dist}(x, y) = \operatorname{dist}(y, x)$;
- the triangle inequality,
  $\operatorname{dist}(x, z) \le \operatorname{dist}(x, y) + \operatorname{dist}(y, z)$.

Unlike a metric, a pseudometric permits $\operatorname{dist}(x, y) = 0$ for
distinct $x \ne y$. This is the correct setting for a *certifier*: if two distinct
theorems embed to the same point, the conservative judgment is to declare them
indistinguishable (novelty zero), refusing to certify either as new.

A **catalog** is a finite set $C \subseteq X$, modeled as `Finset X`. The empty
catalog has no nearest point, so novelty is only defined for nonempty $C$; we carry
a nonemptiness witness $h_C : C \ne \emptyset$ in every statement.

**Definition 2.1 (Function-valued minimum over a finite set).** For a nonempty
finite set $C$ and a function $g : X \to \mathbb{R}$, the minimum
$\min_{c \in C} g(c)$ is well-defined. It satisfies two characteristic
properties: it is a lower bound's least upper bound, namely (i) $\min_{c\in C}
g(c) \le g(c_0)$ for each $c_0 \in C$, and (ii) if $\ell \le g(c)$ for all
$c \in C$, then $\ell \le \min_{c \in C} g(c)$. Moreover the minimum is *attained*:
some $c^\star \in C$ has $g(c^\star) = \min_{c \in C} g(c)$.

## 3. The embedding space and novelty certificates

**Definition 3.1 (Novelty).** For a nonempty catalog $C \subseteq X$ and a
candidate $x \in X$,
$$\operatorname{novelty}(C, x) \;=\; \min_{c \in C} \operatorname{dist}(x, c).$$

**Definition 3.2 (Novelty certificate).** A *novelty certificate at level
$\varepsilon$* for $x$ against $C$ is a pair $(\varepsilon, \pi)$ with
$\varepsilon > 0$ and $\pi$ a proof of
$\varepsilon \le \operatorname{novelty}(C, x)$.

The following two facts establish that novelty is genuinely the minimum distance.

**Lemma 3.3 (`novelty_le_dist`).** For every $c \in C$,
$\operatorname{novelty}(C, x) \le \operatorname{dist}(x, c)$.

*Proof.* Immediate from property (i) of the finite minimum (Definition 2.1):
the minimum over $C$ of $c \mapsto \operatorname{dist}(x, c)$ is at most its value
at any particular $c$. $\qquad\blacksquare$

**Lemma 3.4 (`exists_eq_novelty`).** There exists $c \in C$ with
$\operatorname{dist}(x, c) = \operatorname{novelty}(C, x)$.

*Proof.* By finiteness and nonemptiness, the function $c \mapsto
\operatorname{dist}(x, c)$ attains its minimum on $C$ at some $c^\star$. Then
$\operatorname{dist}(x, c^\star) \le \operatorname{dist}(x, c)$ for all $c \in C$,
which gives $\operatorname{novelty}(C, x) \ge \operatorname{dist}(x, c^\star)$ by
property (ii); combined with Lemma 3.3 (which gives the reverse inequality), the
two are equal. $\qquad\blacksquare$

**Lemma 3.5 (`novelty_nonneg`).** $0 \le \operatorname{novelty}(C, x)$.

*Proof.* Each distance is non-negative, so $0$ is a lower bound for all
$\operatorname{dist}(x, c)$; by property (ii) it is a lower bound for the minimum.
$\qquad\blacksquare$

**Lemma 3.6 (`le_novelty`).** If $\varepsilon \le \operatorname{dist}(x, c)$ for
all $c \in C$, then $\varepsilon \le \operatorname{novelty}(C, x)$.

*Proof.* This is exactly property (ii) of the finite minimum applied to the lower
bound $\varepsilon$. $\qquad\blacksquare$

Lemma 3.6 is the *certificate construction rule*: to produce an
$\varepsilon$-certificate it suffices to bound the distance to every catalog entry
from below by $\varepsilon$.

## 4. Soundness and separation

**Theorem 4.1 (Soundness, `cert_sound`).** If $\operatorname{novelty}(C, x) > 0$,
then $x \notin C$.

*Proof.* Contrapositive. Suppose $x \in C$. Then by Lemma 3.3 applied with $c = x$,
$$\operatorname{novelty}(C, x) \le \operatorname{dist}(x, x) = 0,$$
since a pseudometric has $\operatorname{dist}(x, x) = 0$. Hence
$\operatorname{novelty}(C, x) \le 0$, contradicting positivity. Therefore a
positive certificate forces $x \notin C$. $\qquad\blacksquare$

This is the *no-false-novelty* guarantee: the certifier never stamps "new" on a
result already in the catalog.

**Theorem 4.2 (Separation, `cert_separation`).** If
$\varepsilon \le \operatorname{novelty}(C, x)$, then
$\varepsilon \le \operatorname{dist}(x, c)$ for every $c \in C$.

*Proof.* Fix $c \in C$. Chaining the hypothesis with Lemma 3.3,
$$\varepsilon \le \operatorname{novelty}(C, x) \le \operatorname{dist}(x, c).
\qquad\blacksquare$$

Theorem 4.2 is what allows a single inequality to stand in for a check against the
entire catalog: an $\varepsilon$-certificate is a uniform $\varepsilon$-margin
against all of $C$ at once.

## 5. Stability: novelty is 1-Lipschitz

The central robustness result states that novelty changes no faster than the
candidate point moves. This is what makes a *numerically computed* embedding
distance a valid certificate.

**Lemma 5.1 (Additive stability, `novelty_le_add`).** For all $x, y \in X$,
$$\operatorname{novelty}(C, x) \le \operatorname{novelty}(C, y) + \operatorname{dist}(x, y).$$

*Proof.* By Lemma 3.4, choose $c \in C$ with $\operatorname{dist}(y, c) =
\operatorname{novelty}(C, y)$. Then, using Lemma 3.3 at $x$ and the triangle
inequality,
$$\operatorname{novelty}(C, x) \le \operatorname{dist}(x, c)
  \le \operatorname{dist}(x, y) + \operatorname{dist}(y, c)
  = \operatorname{dist}(x, y) + \operatorname{novelty}(C, y).
\qquad\blacksquare$$

**Theorem 5.2 (1-Lipschitz stability, `abs_novelty_sub_le`).** For all
$x, y \in X$,
$$\bigl|\operatorname{novelty}(C, x) - \operatorname{novelty}(C, y)\bigr|
  \le \operatorname{dist}(x, y).$$

*Proof.* Apply Lemma 5.1 twice, once as stated and once with $x, y$ swapped, and
use $\operatorname{dist}(x, y) = \operatorname{dist}(y, x)$:
$$\operatorname{novelty}(C, x) - \operatorname{novelty}(C, y) \le \operatorname{dist}(x, y),
  \qquad
  \operatorname{novelty}(C, y) - \operatorname{novelty}(C, x) \le \operatorname{dist}(x, y).$$
Together these bound the absolute value. $\qquad\blacksquare$

**Corollary 5.3 (`lipschitz_novelty`).** The map $x \mapsto
\operatorname{novelty}(C, x)$ is $1$-Lipschitz.

*Proof.* Theorem 5.2 is exactly the defining inequality of a $1$-Lipschitz map.
$\qquad\blacksquare$

**Robustness consequence.** Suppose a candidate carries an $\varepsilon$-certificate
computed from an embedding $\tilde{x}$ that differs from the true embedding $x$ by
$\operatorname{dist}(x, \tilde{x}) \le \delta$. By Theorem 5.2,
$$\operatorname{novelty}(C, x) \ge \operatorname{novelty}(C, \tilde{x}) - \delta
  \ge \varepsilon - \delta.$$
Thus whenever the margin exceeds the embedding error ($\varepsilon > \delta$), the
true novelty remains positive and the certificate survives. Errors do not amplify;
they pass through novelty with gain at most $1$.

## 6. Monotonicity and streaming updates

**Theorem 6.1 (Monotonicity, `novelty_mono`).** If $C \subseteq D$ (both
nonempty), then for all $x$,
$$\operatorname{novelty}(D, x) \le \operatorname{novelty}(C, x).$$

*Proof.* By Lemma 3.4 choose $c \in C$ realizing $\operatorname{novelty}(C, x) =
\operatorname{dist}(x, c)$. Since $C \subseteq D$, $c \in D$, so by Lemma 3.3
applied to $D$, $\operatorname{novelty}(D, x) \le \operatorname{dist}(x, c) =
\operatorname{novelty}(C, x)$. $\qquad\blacksquare$

Monotonicity formalizes the principle that *learning more known results can only
make novelty harder to certify, never easier* — there is no grade inflation as the
catalog grows.

**Theorem 6.2 (Incremental update, `novelty_insert`).** For $a \in X$ and nonempty
$C$,
$$\operatorname{novelty}(C \cup \{a\}, x)
  = \min\bigl(\operatorname{dist}(x, a),\, \operatorname{novelty}(C, x)\bigr).$$

*Proof sketch.* The minimum of $c \mapsto \operatorname{dist}(x, c)$ over
$C \cup \{a\}$ splits as the minimum of the value at $a$ and the minimum over $C$;
this is the standard recursion of `Finset.inf'` under insertion, and holds whether
or not $a \in C$. $\qquad\blacksquare$

Theorem 6.2 gives an $O(1)$ streaming update: when a new theorem $a$ enters the
catalog, the novelty of any candidate is refreshed by one distance computation and
one comparison, with no need to rescan the whole catalog.

## 7. Novelty budget vs. an unbounded novelty stream

The monotonicity and update laws describe how novelty *decays* as a catalog grows.
A complementary question is how much novelty a space can *hold*.

### 7.1 The novelty budget in bounded spaces

Call a catalog $\varepsilon$-**separated** if any two distinct entries are at
distance at least $\varepsilon$. An $\varepsilon$-separated catalog is precisely a
collection of mutually-novel results, each carrying an $\varepsilon$-certificate
against all the others (Theorem 4.2).

**Proposition 7.1 (Novelty budget, packing bound).** Suppose the embedding space
is covered by $N$ cells each of diameter $< \varepsilon$. Then any
$\varepsilon$-separated catalog has at most $N$ entries.

*Proof.* Two points in the same cell are at distance $< \varepsilon$, so an
$\varepsilon$-separated set contains at most one point per cell; hence its
cardinality is at most the number $N$ of cells. $\qquad\blacksquare$

Concretely, if the embedding lands in a $d$-dimensional box of side $R$, dividing
into a grid of cells of side $\varepsilon/\sqrt{d}$ gives $N = O\!\left((R\sqrt{d}/
\varepsilon)^d\right)$ cells, so the maximum number of mutually $\varepsilon$-novel
theorems is $O\!\left((R/\varepsilon)^d\right)$. In a bounded space, novelty is a
*finite, rationed resource*. (We conjecture this packing bound is tight up to the
doubling constant of the embedding; see Future Directions.)

### 7.2 An unbounded novelty stream from Fibonacci primitive divisors

The budget vanishes precisely when the space is unbounded — and a classical
number-theoretic fact supplies an *inexhaustible* novelty source.

Recall the Fibonacci numbers $F_1 = F_2 = 1$, $F_{n+1} = F_n + F_{n-1}$. A prime
$q$ is a **primitive prime divisor** of $F_n$ if $q \mid F_n$ but $q \nmid F_k$ for
all $0 < k < n$.

**Theorem 7.2 (Carmichael, prime-index case;
`RankOfApparition.fib_prime_index_has_primitive`).** For every prime $p \ge 3$,
$F_p$ has a primitive prime divisor.

Let $\operatorname{carPrime}(p)$ denote a chosen primitive prime of $F_p$, and
embed prime indices on the real line by
$\operatorname{carEmbed}(p) = \operatorname{carPrime}(p) \in \mathbb{R}$.

**Lemma 7.3 (Distinctness).** For distinct primes $p, p' \ge 3$,
$\operatorname{carPrime}(p) \ne \operatorname{carPrime}(p')$.

*Proof.* Without loss of generality $p < p'$. Suppose $q = \operatorname{carPrime}
(p) = \operatorname{carPrime}(p')$. As the primitive prime of $F_{p'}$, $q$ divides
no $F_k$ with $0 < k < p'$; but $q = \operatorname{carPrime}(p)$ divides $F_p$ and
$0 < p < p'$, a contradiction. $\qquad\blacksquare$

**Theorem 7.4 (Unbounded novelty budget).** The image catalog
$\{\operatorname{carEmbed}(p) : p \ge 3 \text{ prime}\} \subseteq \mathbb{R}$ is
$1$-separated and infinite. Consequently it contains arbitrarily large finite
sub-catalogs in which every member carries a novelty certificate at level $1$
against all others.

*Proof.* By Lemma 7.3 the embedded values are distinct integers, so any two differ
by at least $1$: the set is $1$-separated. There are infinitely many primes
$p \ge 3$, and by distinctness the map $p \mapsto \operatorname{carEmbed}(p)$ is
injective, so the image is infinite. For any finite sub-catalog, Theorem 4.2 turns
$1$-separation into a level-$1$ certificate for each member against the rest.
$\qquad\blacksquare$

**Remark.** Theorem 7.4 is the exact counterpoint to Proposition 7.1. The packing
bound caps mutually-novel results in any *bounded* region; the prime line is
unbounded, and Carmichael's theorem populates it with an endless $1$-separated
catalog. The construction uses Fibonacci primitivity only through the abstract
clause *"the chosen prime divides no earlier term,"* which holds for every
non-degenerate Lucas sequence — suggesting the stream is one instance of a
parametric family (see Future Directions, Conjecture 3).

## 8. Algorithms

We summarize the computational content. Let $n = |C|$ and let embeddings live in
$\mathbb{R}^d$.

- **Novelty evaluation** (Definition 3.1): compute $\operatorname{dist}(x, c)$ for
  each $c \in C$ and take the minimum. Time $O(nd)$, space $O(1)$ beyond the
  catalog.
- **Certificate verification** (Definition 3.2, Theorem 4.2): given a claimed
  level $\varepsilon$, verify $\varepsilon \le \operatorname{dist}(x, c)$ for all
  $c$; reject on the first violation. Time $O(nd)$.
- **Streaming update** (Theorem 6.2): on insertion of $a$, update
  $\operatorname{novelty}(C, x) \leftarrow \min(\operatorname{dist}(x, a),
  \operatorname{novelty}(C, x))$. Time $O(d)$ per candidate.
- **Budget estimate** (Proposition 7.1): estimate the maximum $\varepsilon$-novel
  catalog size by counting occupied grid cells of side $\varepsilon/\sqrt{d}$.

## 9. Applications

- **Quality control for autonomous research engines.** Every generated theorem is
  embedded and tested; only those with a positive (or above-threshold) certificate
  are reported as new, with a verifiable margin attached.
- **Robust deduplication under learned embeddings.** Because novelty is
  $1$-Lipschitz, certificates computed from approximate, learned embeddings remain
  valid as long as the margin exceeds the model's worst-case embedding error.
- **Curriculum and budget planning.** The packing bound estimates how much novel
  material a bounded conceptual region can yield, guiding where to expand search;
  the Fibonacci stream illustrates regions guaranteed inexhaustible.
- **General novelty adjudication.** The same template — embed, measure
  distance-to-known, certify with the three guarantees — applies to plagiarism
  detection, patent prior-art search, and de-novo molecular design.

## 10. Discussion

The mathematical backbone is the classical fact that distance-to-a-set is
$1$-Lipschitz, here specialized to a finite set and reconstructed from the
triangle inequality and the explicit minimizer (Lemma 3.4). What is new is the
*certification framing*: packaging soundness, separation, stability, and
monotonicity as the contract a novelty detector must satisfy, and proving each as a
machine-checked theorem so that a numerically computed distance becomes a formal
guarantee.

Two deliberate conservative choices keep the certifier honest. First, the use of a
*pseudo*metric ensures that distinct results with coincident embeddings are
reported as non-novel rather than spuriously distinguished. Second, novelty is
defined only for nonempty catalogs, with the nonemptiness witness carried
explicitly; we never invent a junk value for the empty minimum.

## 11. Future Directions

**Conjecture 1 — Sharp novelty budget via Lipschitz embeddings.** If $f : X \to
\mathbb{R}^d$ is an $L$-bi-Lipschitz embedding with image in a box of side $R$,
the maximum size of an $\varepsilon$-separated catalog is $\Theta((RL/\varepsilon)^
d)$, matching the packing bound up to the doubling constant. The upper half holds
with no geometric assumption; only an explicit $\varepsilon$-net lower-bound
construction remains.

**Conjecture 2 — Novelty as the Hausdorff gap of catalog growth.** For nested
catalogs $C_0 \subseteq C_1 \subseteq \cdots$, the certified novelties
$\operatorname{novelty}(C_n, x)$ are non-increasing and converge to
$\operatorname{dist}(x, \overline{\bigcup_n C_n})$; moreover
$\sup_x |\operatorname{novelty}(C_n, x) - \operatorname{novelty}(C_m, x)|$ equals
the Hausdorff distance $d_H(C_n, C_m)$. Monotonicity is already established; the
remaining step is the identification with $d_H$ via the $1$-Lipschitz law.

**Conjecture 3 — Every Lucas sequence yields an unbounded novelty stream.** For any
non-degenerate Lucas sequence $U_n(P, Q)$ (Fibonacci, Pell, Mersenne, …), the
primitive-prime map induces a $1$-separated real catalog of unbounded size. The
Fibonacci construction used primitivity only through the abstract "divides no
earlier term" clause; Carmichael's theorem holds for all non-degenerate Lucas
sequences, so the construction is parametric over the same rank-of-apparition
spine.

## 12. Conclusion

We have given a formally verified foundation for certified novelty detection:
novelty as distance-to-catalog in a pseudometric embedding space, certificates as
single verified inequalities, and four guarantees — soundness, separation,
$1$-Lipschitz stability, and monotonicity — that make those certificates
trustworthy under numerical error and catalog growth. A packing-based novelty
budget quantifies the scarcity of novelty in bounded spaces, while Carmichael's
Fibonacci primitive divisor theorem furnishes an explicit, unbounded stream of
certifiably-novel results. Distance, it turns out, really does bound novelty — and
in the right space, it bounds it from below forever.
