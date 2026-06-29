# The Pólya-Tree Divisor-Sum Recurrence: A Self-Contained Formal Development of the Euler Transform for A000081

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Cryptography (combinatorial foundations of hash-tree structures)

## Abstract

The number $a(n)$ of unlabelled rooted trees on $n$ nodes — the Pólya trees,
catalogued as OEIS A000081 — satisfies a classical divisor-sum recurrence arising
from the Euler transform of its own generating function. Writing the
Euler-transform coefficient $c(k) = \sum_{d \mid k} d\,a(d)$, the counts obey
$n \cdot a(n+1) = \sum_{k=1}^{n} c(k)\,a(n+1-k)$ with $a(1)=1$. We present a
self-contained development in which $a(n)$ is *defined* directly by this
recurrence — implemented over the natural numbers via a structurally recursive
prefix list using truncating integer division — and we establish four results
about the resulting sequence: (i) the first sixteen values agree with A000081;
(ii) a fully general recurrence theorem valid for all $n \ge 1$ stating that the
defined sequence satisfies the divisor-sum recurrence with natural-number
division; (iii) an exactness (integrality) theorem on the range $1 \le n \le 13$
giving the division-free integer identity; and (iv) positivity of the counts on
$1 \le n \le 15$. The technical core is a prefix-stability lemma showing that the
value stored at any index is independent of how far the prefix list has been
extended, which collapses the list-based definition onto the intended
divisor-sum form. We discuss the headline open problem — unconditional
integrality of the Euler transform for all $n$ — together with growth asymptotics
(Otter's constant), forest/tree shift identities, divisor-sum congruences, and a
bivariate refinement. The development sits within the combinatorial-cryptography
catalogue, adjacent to Merkle–Damgård and $k$-mer-avoidance material, because
Pólya-tree enumeration underlies hash-tree and tree-indexed key-derivation
structures.

**Keywords:** Pólya trees, A000081, Euler transform, divisor-sum recurrence,
generating functions, integrality, Merkle trees, unlabelled rooted trees.

## 1. Introduction

A *rooted tree* is a connected acyclic graph with a distinguished vertex, the
root. Two rooted trees are considered the same if there is a root-preserving
graph isomorphism between them; equivalently, a rooted tree is a root together
with an unordered multiset of rooted subtrees. The objects counted here are
*unlabelled* (vertices carry no identities) and *plane-free* (children are not
ordered). The number of such trees on $n$ vertices is denoted $a(n)$; the sequence
$$1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, 12486, 32973, 87811, \dots
\qquad (n = 1, 2, 3, \dots)$$
is OEIS A000081, one of the central sequences of enumerative combinatorics.

These counts grow super-polynomially and cannot be obtained by direct
enumeration beyond small $n$. The standard route is Pólya's functional equation
for the ordinary generating function $A(z) = \sum_{n \ge 1} a(n) z^n$, whose
logarithmic derivative yields a divisor-sum recurrence. This recurrence is an
instance of the **Euler transform**, the combinatorial operation that converts the
counting sequence of connected building blocks into the counting sequence of
multisets of those blocks.

The recurrence carries a final division step, and the central conceptual point of
this work is that the quotient is *always* an integer — the **integrality** of the
Euler transform. We formalize the recurrence as a definition over $\mathbb{N}$
with truncating division, prove the recurrence holds in full generality, prove
exactness (no truncation) on a verified range, and isolate integrality-in-general
as the headline open problem.

### 1.1 Cryptographic context

Pólya-tree enumeration is the combinatorial substrate of hash-tree and
Merkle-style data structures. A Merkle tree is a rooted tree whose internal nodes
store hashes of their children; certificate-transparency logs, blockchain
state commitments, and verifiable backups are built on them. Prefix trees
(tries) and tree-indexed key-derivation hierarchies are likewise rooted trees.
Questions about the number of distinct tree shapes of a given size, collision
probabilities for random tree-shaped objects, and the entropy of tree-shaped key
schedules all reduce to counting Pólya trees. This entry therefore sits in the
cryptography catalogue alongside combinatorial-hashing material such as
Merkle–Damgård constructions and $k$-mer avoidance.

## 2. Definitions

We work entirely over the natural numbers $\mathbb{N} = \{0, 1, 2, \dots\}$, using
truncating integer division $\lfloor \cdot / n \rfloor$, written $/$ below. We
adopt the convention $a(0) = 0$ (the empty tree contributes nothing), with
$a(1) = 1$.

**Definition 2.1 (Divisor set).** For $k \ge 1$, let $\mathrm{div}(k)$ denote the
set of positive divisors of $k$. By convention $\mathrm{div}(0) = \varnothing$, so
sums over divisors of $0$ are empty.

**Definition 2.2 (Euler-transform coefficient).** For $n \ge 0$,
$$c(n) \;=\; \sum_{d \in \mathrm{div}(n)} d \cdot a(d).$$
Thus $c(0) = 0$, $c(1) = a(1) = 1$, $c(2) = a(1) + 2a(2)$, and so on. The
coefficient $c(k)$ records, for each divisor $d$ of $k$, the weight $d \cdot a(d)$;
combinatorially this is the contribution of size-$d$ subtree blocks repeated
$k/d$ times.

**Definition 2.3 (Prefix-list realization).** To obtain a structurally recursive,
machine-checkable definition that avoids well-founded-recursion side conditions,
we realize the sequence through a growing prefix list $L = [a(0), a(1), \dots,
a(m)]$. Two operations drive the construction.

The **divisor-sum on a list** evaluates Definition 2.2 against the values stored
in $L$:
$$\mathrm{Sdiv}(L, k) \;=\; \sum_{d \in \mathrm{div}(k)} d \cdot L_d,$$
where $L_d$ denotes the entry of $L$ at index $d$ (read as $0$ if out of range).

The **next-value operation** computes one further term. If $L$ has length $m+1$
(so it stores $a(0), \dots, a(m)$) and we set $n = m$, then
$$\mathrm{nextVal}(L) \;=\; \Big( \sum_{k=1}^{n} \mathrm{Sdiv}(L, k)\cdot L_{\,n+1-k} \Big) \,/\, n.$$

The **prefix list** itself is then defined recursively:
$$\mathrm{treeList}(0) = [0], \quad \mathrm{treeList}(1) = [0, 1], \quad
\mathrm{treeList}(n+2) = \mathrm{treeList}(n+1) \mathbin{+\!+} [\,\mathrm{nextVal}(\mathrm{treeList}(n+1))\,].$$

Finally, the **tree-count sequence** is read off the diagonal:
$$a(n) \;=\; \big(\mathrm{treeList}(n)\big)_n,$$
the entry at index $n$ of the length-$(n+1)$ prefix list (again $0$ if out of
range). This circular-looking definition is well founded because $\mathrm{nextVal}$
only ever reads strictly earlier entries.

## 3. Structural lemmas

The bridge between the list realization (Definition 2.3) and the intended
divisor-sum recurrence rests on two structural facts.

**Lemma 3.1 (Length).** For all $n$, $\;|\mathrm{treeList}(n)| = n + 1$.

*Proof sketch.* Induction on $n$. The base cases $n = 0, 1$ are immediate from
the definition. For the step, $\mathrm{treeList}(n+2)$ appends exactly one element
to $\mathrm{treeList}(n+1)$, increasing the length by one; by the induction
hypothesis the latter has length $n+2$, so the former has length $n+3$. $\;\square$

**Lemma 3.2 (Prefix stability).** For all $m, j$ with $j \le m$,
$$\big(\mathrm{treeList}(m)\big)_j \;=\; a(j).$$
That is, the value stored at index $j$ does not depend on how far the list has
been grown, as long as the list reaches index $j$ at all.

*Proof sketch.* Induction on $m$, generalizing over $j$. For $m = 0$ the only
admissible $j$ is $0$ and the claim is definitional. For the inductive step,
$\mathrm{treeList}(m+2) = \mathrm{treeList}(m+1) \mathbin{+\!+} [\mathrm{nextVal}(\cdots)]$.
If $j \le m+1$, the index $j$ lies in the unchanged prefix
$\mathrm{treeList}(m+1)$ (using Lemma 3.1 to locate the append boundary), and the
induction hypothesis applies. If $j = m+2$, the value is the freshly appended
$\mathrm{nextVal}$ entry, which is exactly $a(m+2)$ by Definition 2.3. $\;\square$

Lemma 3.2 is the linchpin: it lets every occurrence of a list lookup $L_d$ or
$L_{n+1-k}$ inside $\mathrm{Sdiv}$ and $\mathrm{nextVal}$ be replaced by the
corresponding global value $a(d)$ or $a(n+1-k)$, and correspondingly
$\mathrm{Sdiv}(\mathrm{treeList}(n), k)$ by $c(k)$, provided the indices stay
within range.

## 4. Main results

**Theorem 4.1 (Correctness table).** The first sixteen values of the sequence are
$$[a(0), a(1), \dots, a(15)] = [0, 1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842,
4766, 12486, 32973, 87811],$$
in agreement with OEIS A000081.

*Proof sketch.* Direct evaluation of the recursive definition; each entry is
computed by the $\mathrm{nextVal}$ step and compared against the reference values.
The computation is finite and decidable. $\;\square$

**Theorem 4.2 (General divisor-sum recurrence).** For every $n \ge 1$,
$$a(n+1) \;=\; \Big( \sum_{k=1}^{n} c(k)\,a(n+1-k) \Big) \,/\, n,$$
where $/$ is truncating natural-number division.

*Proof sketch.* By Definition 2.3, $a(n+1) = \mathrm{nextVal}(\mathrm{treeList}(n))$,
which by the length Lemma 3.1 (so that the internal "$n$" equals the intended $n$)
equals $\big(\sum_{k=1}^{n} \mathrm{Sdiv}(\mathrm{treeList}(n), k)\cdot
(\mathrm{treeList}(n))_{n+1-k}\big)/n$. Apply prefix stability (Lemma 3.2) in two
places. First, for each $k$ in the range and each divisor $d$ of $k$, we have
$d \le k \le n$, so the lookup at index $d$ equals $a(d)$; summing,
$\mathrm{Sdiv}(\mathrm{treeList}(n), k) = c(k)$. Second, for $1 \le k \le n$ the
index $n+1-k$ satisfies $n+1-k \le n$, so the lookup equals $a(n+1-k)$.
Substituting both yields the claimed identity. $\;\square$

Theorem 4.2 is genuinely general: it holds for all $n \ge 1$ with no upper bound.
It is the defining engine of the sequence — it says the list realization computes
precisely the Euler-transform recurrence with truncating division.

**Theorem 4.3 (Exactness / integrality on a range).** For every $n$ with
$1 \le n \le 13$,
$$n \cdot a(n+1) \;=\; \sum_{k=1}^{n} c(k)\,a(n+1-k).$$

*Proof sketch.* For each of the thirteen values of $n$, both sides are finite
natural numbers computed from the definition; the identity is verified by direct
evaluation. The content beyond Theorem 4.2 is that the division by $n$ is
*exact* — there is no truncation — so the equation holds with multiplication
rather than division. Equivalently, $n \mid \sum_{k=1}^{n} c(k)\,a(n+1-k)$ on this
range. $\;\square$

**Theorem 4.4 (Positivity).** For every $n$ with $1 \le n \le 15$, $\;a(n) \ge 1$.

*Proof sketch.* Direct evaluation against the correctness table; every listed
value from $a(1)$ to $a(15)$ is at least $1$. $\;\square$

## 5. The generating-function origin

The recurrence is the coefficient form of Pólya's functional equation. Let
$A(z) = \sum_{n \ge 1} a(n) z^n$. The decomposition of a rooted tree into a root
plus an unordered multiset of rooted subtrees gives
$$A(z) \;=\; z \, \exp\!\Big( \sum_{i \ge 1} \tfrac{1}{i}\, A(z^i) \Big).$$
The factor $z$ marks the root; the exponential builds the multiset of children
(the standard multiset-construction operator on generating functions); and the
substitution $z \mapsto z^i$ encodes using a given subtree $i$ times.

Taking the logarithmic derivative $z A'(z)/A(z)$ of the functional equation and
clearing denominators produces
$$z\,\frac{A'(z)}{A(z)} \;=\; 1 + \sum_{i \ge 1} z^i A'(z^i).$$
Now observe the divisor structure: the coefficient of $z^k$ in
$\sum_{i \ge 1} z^i A'(z^i)$ is
$$[z^k] \sum_{i \ge 1} z^i A'(z^i) \;=\; \sum_{i \mid k} \frac{k}{i}\, a\!\Big(\frac{k}{i}\Big) \,=\, \sum_{d \mid k} d\, a(d) \,=\, c(k),$$
after re-indexing $d = k/i$. Extracting the coefficient of $z^{n}$ from
$z A'(z) = A(z)\big(1 + \sum_{k \ge 1} c(k) z^k\big)$ and matching terms gives
$$n\, a(n) \;=\; \sum_{k=1}^{n-1} c(k)\, a(n-k) \,+\, [\text{root term}],$$
which after the standard index shift is exactly
$n\,a(n+1) = \sum_{k=1}^{n} c(k)\,a(n+1-k)$. The divisors in $c(k)$ are thus the
algebraic residue of subtree repetition. This derivation also explains the name
**Euler transform**: the operator $b \mapsto a$ with generating-function relation
$1 + \sum a(n) z^n = \prod_{k \ge 1} (1 - z^k)^{-b(k)}$ is realized at the level of
coefficients by precisely this divisor-sum convolution.

## 6. Algorithms

**Algorithm 6.1 (Linear-prefix Pólya-tree generator).** Given a target $N$,
maintain the prefix array $a[0..N]$ and the coefficient array $c[1..N]$.
Initialize $a[0] = 0$, $a[1] = 1$. For each $m$ from $1$ to $N-1$: compute
$c[m]$ by summing $d\cdot a[d]$ over divisors $d$ of $m$; then form
$S = \sum_{k=1}^{m} c[k]\,a[m+1-k]$ and set $a[m+1] = S / m$. The divisor sums can
be accumulated via a sieve in $O(N \log N)$ total; the convolution dominates at
$O(N^2)$, giving an overall $O(N^2)$ algorithm using $O(N)$ space.

```
function PolyaTreeCounts(N):
    a := array of size N+1, all 0
    c := array of size N+1, all 0
    a[1] := 1
    # Sieve the Euler coefficients c[k] = sum_{d | k} d * a[d] is built lazily
    for m from 1 to N-1:
        c[m] := 0
        for d in divisors(m):
            c[m] := c[m] + d * a[d]
        S := 0
        for k from 1 to m:
            S := S + c[k] * a[m+1-k]
        a[m+1] := S div m          # division is always exact (integrality)
    return a
```

**Algorithm 6.2 (Integrality certificate).** To certify integrality on a range,
compute the unrounded sum $S = \sum_{k=1}^{n} c(k)\,a(n+1-k)$ and verify
$S \bmod n = 0$ for each $n$ in the range, returning the explicit quotient
$a(n+1) = S/n$. A failure (non-zero remainder) would constitute a counterexample
to the integrality conjecture; none occurs through $n = 13$ (and, computationally,
far beyond).

## 7. Numerical illustrations

The table below shows the first terms together with the Euler coefficients and the
exactness check $n\,a(n+1) = S_n$ where $S_n = \sum_{k=1}^n c(k)\,a(n+1-k)$.

| $n$ | $a(n)$ | $c(n)$ | $S_n$ | $n\,a(n+1)$ |
|----:|-------:|-------:|------:|------------:|
| 1 | 1 | 1 | 1 | 1 |
| 2 | 1 | 3 | 4 | 4 |
| 3 | 2 | 7 | 12 | 12 |
| 4 | 4 | 19 | 36 | 36 |
| 5 | 9 | 46 | 100 | 100 |
| 6 | 20 | 129 | 288 | 288 |
| 7 | 48 | 337 | 805 | 805 |

For example, the divisors of $6$ are $1, 2, 3, 6$, so
$c(6) = 1\cdot a(1) + 2\cdot a(2) + 3\cdot a(3) + 6\cdot a(6) =
1\cdot 1 + 2\cdot 1 + 3\cdot 2 + 6\cdot 20 = 1 + 2 + 6 + 120 = 129$, and the
convolution check at $n = 6$ reads $S_6 = c(1)a(6) + c(2)a(5) + c(3)a(4) +
c(4)a(3) + c(5)a(2) + c(6)a(1) = 20 + 27 + 28 + 38 + 46 + 129 = 288 = 6\cdot 48 =
6\,a(7)$. The table values use the running definition and are reproduced exactly
by the reference implementation in the companion demo.

## 8. Discussion

The development illustrates a recurring methodological point: defining a
combinatorial sequence directly by its recurrence (rather than importing a table)
makes correctness a theorem about the recurrence itself, and isolates the genuinely
hard content. Here the hard content is *integrality* — the assertion that the
truncating division never truncates. We proved the general recurrence for all $n$
(Theorem 4.2) but the exactness only on a finite range (Theorem 4.3), faithfully
reflecting the state of knowledge: integrality is "obvious" combinatorially (the
left side counts objects) yet has no short purely arithmetic proof.

The list/prefix encoding (Definition 2.3) deserves comment. A first instinct is to
define $a$ by strong recursion with the recurrence used directly as the recursive
clause. That approach forces one to discharge $d < n$ side conditions arising
inside divisor and interval sums at definition time, which is awkward. The
prefix-list encoding is structurally recursive — each step appends exactly one
element computed from strictly earlier elements — and the prefix-stability Lemma
3.2 cleanly re-establishes the intended global recurrence afterward, separating
the *computation* from the *specification*.

## 9. Future directions

The following directions are precise and testable.

**C1 — Unconditional integrality (headline open problem).** For all $n \ge 1$,
$n \mid \sum_{k=1}^{n} c(k)\,a(n+1-k)$, equivalently the exactness identity
$n\,a(n+1) = \sum_{k=1}^{n} c(k)\,a(n+1-k)$ holds without truncation for every $n$
(we proved only $n \le 13$). A proof should come either from the combinatorial
meaning (rooted-tree counts are integers) or from a cyclic-sieving / $\mathbb{Z}/n$
argument on the Euler product $T(x) = x\prod_{k}(1 - x^k)^{-a(k)}$.

**C2 — Asymptotics.** $a(n+1)/a(n) \to \alpha \approx 2.9557652856\ldots$ (Otter's
constant) and $a(n) \sim C\,\alpha^n n^{-3/2}$. A weaker formalizable milestone:
strict monotone growth $a(n) < a(n+1)$ for all $n \ge 1$, and crude exponential
bounds $2^{n-2} \le a(n) \le 4^n$ for $n \ge 1$.

**C3 — Forests vs. trees (shift identity).** With $f(n)$ the number of rooted
forests on $n$ nodes (A000081 shifted, $f(n) = a(n+1)$), formalize the
log-derivative identity $x T'(x)/T(x) = \sum_{k \ge 1} c(k) x^k$ over a power-series
ring and derive the recurrence from it.

**C4 — Divisor-sum congruences.** Study residues $a(p) \bmod p$ for primes $p$ and
seek a non-trivial congruence relating $a(p^2)$ to $a(p)$ modulo $p$; testable
immediately on a prime range and then generalizable.

**C5 — Bivariate refinement.** Refine $a(n)$ by number of leaves (or height) to a
bivariate $A(n, \ell)$ with a Cauchy-product divisor-sum recurrence; conjecture row
sums recover $a(n)$ and prove integrality on a range.

## 10. Conclusion

We have given a self-contained account of the Pólya-tree divisor-sum recurrence:
a structurally recursive definition of $a(n)$, agreement with A000081 on the first
sixteen terms, a fully general recurrence theorem for all $n \ge 1$ with
natural-number division, exactness (integrality) on $1 \le n \le 13$, and
positivity on $1 \le n \le 15$. The mathematics is anchored in Pólya's functional
equation and its logarithmic derivative, which explains the divisor structure as
the signature of subtree repetition. The unresolved kernel — integrality for all
$n$ — is stated precisely as a clean open problem with concrete attack routes.
Because Pólya-tree counts underlie hash-tree and tree-indexed cryptographic
structures, the development connects a classical enumeration to the combinatorial
foundations of secure data structures.
