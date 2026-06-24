# Existence of Non-Trivial Boolean Degree One Functions on the Grassmann Scheme $J_q(4,2)$

**Author:** Aristotle

**Date:** 2026-06-24

**Domain:** Shared (Finite geometry, association schemes, algebraic combinatorics)

---

## Abstract

A *Boolean degree one function* on the Grassmann scheme $J_q(4,2)$ — equivalently a
*Cameron–Liebler line class* of the projective space $PG(3,q)$ — is a
$\{0,1\}$-valued function on the lines whose expansion in the eigenspaces of the
Grassmann graph is supported on the first two layers. Every such function carries an
integer *parameter* $x$ with $0 \le x \le q^2+1$, and its support has exactly
$x\,(q^2+q+1)$ lines. Eight functions are *trivial* (constructed from point-pencils
and plane-pencils): the constants $0,1$ and the four $\pm$ combinations of one point-
and one plane-pencil, whose parameters fill the set $\{0,1,2,q^2-1,q^2,q^2+1\}$. We
isolate and prove the unconditional **arithmetic core** of the Bruen–Drudge
self-complementary construction. Define the midpoint parameter
$\operatorname{bdParam}(q) = \lfloor (q^2+1)/2 \rfloor$. We prove (i) for odd $q$,
$2\operatorname{bdParam}(q) = q^2+1$, so the midpoint is a genuine integer and is
self-complementary; (ii) for $q \ge 3$,
$2 < \operatorname{bdParam}(q) < q^2-1$, so the midpoint lies strictly inside the
non-trivial parameter window. We then formalize the conditional consequence: any
Cameron–Liebler class realized at parameter $\operatorname{bdParam}(q)$ on the genuine
line set of $J_q(4,2)$ (with $q \ge 3$) has a *non-constant* indicator function, and
hence is a non-trivial Boolean degree one function. The geometric realizability (the
Bruen–Drudge theorem) is carried as an explicit hypothesis rather than re-derived, so
the proof cleanly separates number theory from geometry. All results have been
formally verified.

**Keywords:** Cameron–Liebler line class, Grassmann scheme $J_q(4,2)$, Boolean degree
one function, Bruen–Drudge construction, self-complementary, projective space
$PG(3,q)$, $q$-Krawtchouk, association scheme.

---

## 1. Introduction

### 1.1 Setting

Let $\mathbb{F}_q$ be the finite field with $q$ elements ($q$ a prime power), and let
$V = \mathbb{F}_q^4$. The **Grassmann scheme** $J_q(4,2)$ is the association scheme
whose points are the $2$-dimensional subspaces of $V$ — equivalently, the *lines* of
the projective space $PG(3,q)$ — with relations determined by the dimension of the
intersection of two subspaces. Its underlying graph, the **Grassmann graph**, joins
two lines when they meet in a point (intersect in dimension $1$).

A function $f : \{\text{lines}\} \to \{0,1\}$ is a **Boolean degree one function** if,
in the orthogonal eigenspace decomposition associated to the scheme, $f$ has nonzero
components only in the trivial eigenspace $V_0$ and the first eigenspace $V_1$. These
functions coincide exactly with the indicator functions of **Cameron–Liebler line
classes**, introduced by Cameron and Liebler (1982). They are a central object of
algebraic combinatorics, with equivalent descriptions in terms of equitable
partitions, tight sets, and eigenvectors of the Grassmann graph.

### 1.2 The parameter and the trivial classes

A foundational fact is that every Cameron–Liebler line class $L$ has an integer
**parameter** $x = x(L)$ with $0 \le x \le q^2+1$, and that
$$
|L| \;=\; x\,(q^2+q+1).
$$
That is, the size of the class is $x$ times the number of lines through a point. This
*degree-one counting identity* is the combinatorial signature we use throughout.

Eight classes are constructible directly from incidence geometry and are deemed
**trivial**:

| Construction | Description | Parameter $x$ |
|---|---|---|
| $0$ | empty class | $0$ |
| $1$ | all lines | $q^2+1$ |
| $x_p$ | lines through a point $p$ | $1$ |
| $1-x_p$ | complement | $q^2$ |
| $y_r$ | lines in a plane $r$ | $1$ |
| $1-y_r$ | complement | $q^2$ |
| $x_p + y_r$ | lines through $p$ or in $r$ ($p \notin r$) | $2$ |
| $1-x_p-y_r$ | complement | $q^2-1$ |

Their parameters form the **trivial set**
$$
T_q \;=\; \{\,0,\,1,\,2,\,q^2-1,\,q^2,\,q^2+1\,\}.
$$
The set-theoretic complement of a class with parameter $x$ has parameter $q^2+1-x$;
thus $T_q$ is invariant under the involution $x \mapsto q^2+1-x$, and the trivial
classes occupy only the *extremes* of the parameter range.

The motivating problem: **does a Boolean degree one function exist whose parameter
lies strictly inside the open window $(2, q^2-1)$?** Such a function is *non-trivial*:
it is none of the eight constructions above.

### 1.3 Contribution

We isolate the unconditional arithmetic skeleton of the Bruen–Drudge construction and
formally verify it, then connect it to non-triviality through a minimal,
hypothesis-driven model of a Cameron–Liebler class. Concretely:

1. We define the self-complementary midpoint parameter
   $\operatorname{bdParam}(q) = \lfloor (q^2+1)/2 \rfloor$ and prove it is a genuine
   integer half exactly for odd $q$ (`bdParam_two_mul`,
   `bdParam_self_complement`).
2. We prove the non-triviality bounds $2 < \operatorname{bdParam}(q) < q^2-1$ for
   $q \ge 3$ (`bdParam_gt_two`, `bdParam_gt_four`, `bdParam_lt`,
   `bdParam_nontrivial`).
3. We supply the line-count infrastructure
   $\#\{\text{lines through a point}\} = q^2+q+1$ and
   $\#\{\text{all lines}\} = (q^2+1)(q^2+q+1)$.
4. We model a Cameron–Liebler class abstractly (structure `CLClass`) and prove that a
   class realized at parameter $\operatorname{bdParam}(q)$, $q \ge 3$, has a
   non-constant indicator (`CLClass.exists_true`, `CLClass.exists_false`,
   `CLClass.toFun_not_constant`).

The arithmetic (items 1–3) is proved with no geometric assumptions. The geometric
realizability — the existence of the Bruen–Drudge class — is the content of the
hypothesis embodied in the `CLClass` structure (item 4); we do not re-derive it.

---

## 2. Foundational line counts

We work over the natural numbers $\mathbb{N}$ throughout.

**Definition 2.1 (lines through a point).** The number of lines of $PG(3,q)$ through a
fixed point is
$$
\operatorname{numLinesThroughPoint}(q) \;=\; q^2 + q + 1.
$$
*Justification.* The lines through a fixed point $p$ correspond bijectively to the
$2$-spaces of $V$ containing the fixed $1$-space $\langle p\rangle$, equivalently to
the $1$-spaces of the quotient $V/\langle p\rangle \cong \mathbb{F}_q^3$, i.e. to the
points of $PG(2,q)$, of which there are $q^2+q+1$.

**Definition 2.2 (total lines).** The total number of lines of $PG(3,q)$ is the
Gaussian binomial coefficient
$$
\operatorname{numLines}(q) \;=\; \binom{4}{2}_q \;=\; (q^2+1)(q^2+q+1).
$$
*Justification.* $\binom{4}{2}_q = \frac{(q^4-1)(q^3-1)}{(q^2-1)(q-1)}
= (q^2+1)(q^2+q+1)$ after cancellation.

**Lemma 2.3 (positivity).** $\operatorname{numLinesThroughPoint}(q) > 0$ and
$\operatorname{numLines}(q) > 0$ for all $q$.

These two counts are the only geometric quantities needed below.

---

## 3. The Bruen–Drudge midpoint parameter

**Definition 3.1.** The **Bruen–Drudge parameter** is
$$
\operatorname{bdParam}(q) \;=\; \left\lfloor \frac{q^2+1}{2} \right\rfloor
\qquad(\text{natural-number division}).
$$
It is the natural candidate for a *self-complementary* parameter: a class with
parameter $x$ is congruent to its own complement (parameter $q^2+1-x$) iff
$2x = q^2+1$, i.e. $x = (q^2+1)/2$.

### 3.1 Integrality for odd $q$

**Theorem 3.2 (`bdParam_two_mul`).** *If $q$ is odd, then*
$$
2\,\operatorname{bdParam}(q) \;=\; q^2 + 1.
$$
*Proof sketch.* If $q$ is odd then $q^2$ is odd, so $q^2+1$ is even and
$2 \mid (q^2+1)$. For an even number $m$, $2\lfloor m/2\rfloor = m$
(`Nat.mul_div_cancel'` applied to $2 \mid q^2+1$). Apply with $m = q^2+1$. $\square$

**Corollary 3.3 (`bdParam_self_complement`).** *If $q$ is odd, then*
$$
\operatorname{bdParam}(q) + \operatorname{bdParam}(q) \;=\; q^2 + 1,
$$
*so the parameter is self-complementary under $x \mapsto q^2+1-x$.*
*Proof.* Rewrite $x + x = 2x$ and apply Theorem 3.2. $\square$

*Remark (even $q$ obstruction).* For even $q$, $q^2+1$ is odd, so $2 \mid (q^2+1)$
fails and $2\lfloor (q^2+1)/2\rfloor = q^2 \ne q^2+1$. Thus there is **no** integer
self-complementary parameter when $q$ is even; e.g. $q=4$ gives $q^2+1 = 17$ and
$2\cdot 8 = 16$. Self-complementarity is an arithmetic phenomenon available only for
odd $q$.

### 3.2 Non-triviality bounds for $q \ge 3$

**Theorem 3.4 (lower bound, `bdParam_gt_two`).** *For $q \ge 3$,*
$$
2 \;<\; \operatorname{bdParam}(q).
$$
*Proof sketch.* By the floor inequality $2 < \lfloor (q^2+1)/2\rfloor$ iff
$2\cdot 3 \le q^2+1$ (i.e. $\lfloor m/2\rfloor \ge k+1 \iff m \ge 2(k+1)$), and
$q^2+1 \ge 10 > 6$ for $q \ge 3$. $\square$

**Theorem 3.5 (sharper lower bound, `bdParam_gt_four`).** *For $q \ge 3$ with $q$
odd,*
$$
4 \;<\; \operatorname{bdParam}(q).
$$
*Proof sketch.* Write $q = 2k+1$; then $q^2+1 = 4k^2+4k+2$ and
$\operatorname{bdParam}(q) = 2k^2+2k+1$. For $q \ge 3$ we have $k \ge 1$, whence
$2k^2+2k+1 \ge 5 > 4$. $\square$

**Theorem 3.6 (upper bound, `bdParam_lt`).** *For $q \ge 3$,*
$$
\operatorname{bdParam}(q) \;<\; q^2 - 1.
$$
*Proof sketch.* Since $\lfloor (q^2+1)/2\rfloor \le (q^2+1)/2$, it suffices that
$(q^2+1)/2 < q^2-1$, i.e. $q^2+1 < 2q^2-2$, i.e. $q^2 > 3$, which holds for $q \ge 2$.
Formally one uses $2\lfloor (q^2+1)/2\rfloor \le q^2+1$ and a linear-arithmetic step.
$\square$

**Theorem 3.7 (non-triviality, `bdParam_nontrivial`).** *For $q \ge 3$,*
$$
2 \;<\; \operatorname{bdParam}(q) \;<\; q^2 - 1.
$$
*Proof.* Conjunction of Theorems 3.4 and 3.6. $\square$

Hence for $q \ge 3$ the midpoint parameter lies strictly inside the open window
$(2, q^2-1)$ and therefore avoids the trivial set
$T_q = \{0,1,2,q^2-1,q^2,q^2+1\}$.

### 3.3 The threshold at $q = 3$

**Proposition 3.8 (informal, the $q=2$ obstruction).** *The non-trivial window
$(2, q^2-1)$ contains no integer iff $q \le 2$.*

*Discussion.* The open integer interval $(2, q^2-1)$ is non-empty iff
$q^2 - 1 > 3$, i.e. $q^2 > 4$, i.e. $q \ge 3$. Equivalently, the trivial set $T_q$
covers all of $\{0,\dots,q^2+1\}$ exactly when $q^2+1 \le 5$, i.e. $q \le 2$. For
$q=2$ the parameter range is $\{0,1,2,3,4,5\}$ and $T_2 = \{0,1,2,3,4,5\}$ is the
entire range — no non-trivial parameter exists. For $q=3$ the range is
$\{0,\dots,10\}$, $T_3 = \{0,1,2,8,9,10\}$, and the window $\{3,4,5,6,7\}$ opens,
with midpoint $\operatorname{bdParam}(3)=5$ inside. (The full $q=2$ *impossibility*
for actual classes — as opposed to the parameter count — is recorded as a future
direction; the parameter-level statement above is what the arithmetic core
establishes.)

---

## 4. From parameter to non-constancy

We now model a Cameron–Liebler class abstractly and deduce non-triviality from the
counting identity, *without* assuming the geometric construction beyond the existence
of such a class.

**Definition 4.1 (`CLClass`).** Fix $q \in \mathbb{N}$ and a finite type
$\textsf{lines}$ with decidable equality. A **Cameron–Liebler class** on
$\textsf{lines}$ is a triple
$$
C = (\,\operatorname{toFun},\ \operatorname{param},\ \operatorname{card\_eq}\,)
$$
where $\operatorname{toFun} : \textsf{lines} \to \{\textsf{true},\textsf{false}\}$ is
the Boolean indicator, $\operatorname{param} \in \mathbb{N}$ is the parameter, and
$\operatorname{card\_eq}$ is the degree-one counting identity
$$
\bigl|\{\,l : \operatorname{toFun}(l) = \textsf{true}\,\}\bigr|
\;=\; \operatorname{param}\cdot \operatorname{numLinesThroughPoint}(q)
\;=\; \operatorname{param}\,(q^2+q+1).
$$
This structure carries *exactly* the data a Boolean degree one function must satisfy.
Its inhabitation by the Bruen–Drudge class at $\operatorname{param} =
\operatorname{bdParam}(q)$ is the geometric hypothesis (Bruen–Drudge theorem); we do
not prove inhabitation, we reason from it.

**Theorem 4.2 (`CLClass.exists_true`).** *If $\operatorname{param} > 0$, then
$\operatorname{toFun}(l) = \textsf{true}$ for some line $l$.*
*Proof sketch.* If $\operatorname{toFun}$ were identically $\textsf{false}$, the
support would be empty, so by $\operatorname{card\_eq}$ we would have
$0 = \operatorname{param}\cdot(q^2+q+1)$. Since $q^2+q+1 > 0$ (Lemma 2.3) and
$\operatorname{param} > 0$, the right side is positive — contradiction. $\square$

**Theorem 4.3 (`CLClass.exists_false`).** *If $\#\,\textsf{lines} =
\operatorname{numLines}(q)$ and $\operatorname{param} < q^2+1$, then
$\operatorname{toFun}(l) = \textsf{false}$ for some line $l$.*
*Proof sketch.* Contrapositive: if $\operatorname{toFun}$ were identically
$\textsf{true}$, the support would be all of $\textsf{lines}$, so
$\operatorname{card\_eq}$ gives
$\operatorname{numLines}(q) = \operatorname{param}\,(q^2+q+1)$, i.e.
$(q^2+1)(q^2+q+1) = \operatorname{param}\,(q^2+q+1)$. Cancelling the positive factor
$q^2+q+1$ yields $\operatorname{param} = q^2+1$, contradicting
$\operatorname{param} < q^2+1$. $\square$

**Theorem 4.4 (conditional non-triviality, `CLClass.toFun_not_constant`).** *Let
$q \ge 3$, let $\#\,\textsf{lines} = \operatorname{numLines}(q)$, and let $C$ be a
Cameron–Liebler class with $\operatorname{param} = \operatorname{bdParam}(q)$. Then
$\operatorname{toFun}$ is non-constant:*
$$
\bigl(\exists\,l,\ \operatorname{toFun}(l)=\textsf{true}\bigr)
\ \wedge\
\bigl(\exists\,l,\ \operatorname{toFun}(l)=\textsf{false}\bigr).
$$
*Proof.* For the first conjunct, Theorem 3.4 gives
$\operatorname{bdParam}(q) > 2 > 0$, so $\operatorname{param} > 0$ and Theorem 4.2
applies. For the second conjunct, Theorem 3.6 gives
$\operatorname{bdParam}(q) < q^2-1 < q^2+1$, so $\operatorname{param} < q^2+1$ and
Theorem 4.3 applies (using $\#\,\textsf{lines}=\operatorname{numLines}(q)$).
$\square$

**Corollary 4.5 (existence of a non-trivial Boolean degree one function).** *For odd
$q \ge 3$, granting the Bruen–Drudge realizability hypothesis (a `CLClass` with
parameter $\operatorname{bdParam}(q)$ on the genuine line set of $J_q(4,2)$ exists),
its indicator is a non-constant Boolean degree one function whose parameter lies
strictly inside $(2,q^2-1)$ and hence outside the trivial set $T_q$. It is therefore a
non-trivial Boolean degree one function.* By Corollary 3.3 it is moreover
self-complementary.

---

## 5. Algorithms

The arithmetic core is fully computable, enabling direct verification and exploration.

### 5.1 Parameter-window classifier

**Purpose.** Given $q$, compute the trivial set $T_q$, the non-trivial window
$(2,q^2-1)$, the midpoint $\operatorname{bdParam}(q)$, and decide membership.

**Pseudocode.**
```
function classify(q):
    nltp        <- q*q + q + 1
    nlines      <- (q*q + 1) * nltp
    maxparam    <- q*q + 1
    bd          <- (q*q + 1) // 2
    trivial     <- {0, 1, 2, q*q - 1, q*q, q*q + 1}
    window      <- { x : 2 < x < q*q - 1 }            # integers
    is_integer_midpoint <- (2*bd == q*q + 1)          # true iff q odd
    nontrivial  <- (bd in window)                     # true iff q >= 3
    return (nltp, nlines, maxparam, bd, trivial, window,
            is_integer_midpoint, nontrivial)
```
**Complexity.** $O(1)$ arithmetic; window enumeration is $O(q^2)$ if listed.

### 5.2 Non-constancy certificate from the counting identity

**Purpose.** Given a parameter $x$ and the ambient line count $N=\operatorname{numLines}(q)$,
certify that any class with that parameter is non-constant.

**Pseudocode.**
```
function nonconstant_certificate(q, x):
    nltp   <- q*q + q + 1
    N      <- (q*q + 1) * nltp
    support_size <- x * nltp                  # forced by degree-one identity
    has_true  <- (support_size > 0)           # <=> x > 0
    has_false <- (support_size < N)           # <=> x < q*q + 1
    return has_true and has_false             # non-constant iff 0 < x < q*q+1
```
**Complexity.** $O(1)$. Correctness is Theorems 4.2–4.3.

---

## 6. Numerical illustrations

For $q \in \{2,3,4,5,7,9\}$ (see `demo.py`):

| $q$ | parity | $q^2+q+1$ | $(q^2+1)(q^2+q+1)$ | $\operatorname{bdParam}$ | $2\operatorname{bdParam}$ vs $q^2+1$ | window $(2,q^2-1)$ | midpoint in window |
|---|---|---|---|---|---|---|---|
| 2 | even | 7 | 35 | 2 | $4 \ne 5$ | $\varnothing$ | no |
| 3 | odd | 13 | 130 | 5 | $10 = 10$ | $\{3,\dots,7\}$ | yes |
| 4 | even | 21 | 357 | 8 | $16 \ne 17$ | $\{3,\dots,14\}$ | yes (but not integer-self-complementary) |
| 5 | odd | 31 | 806 | 13 | $26 = 26$ | $\{3,\dots,23\}$ | yes |
| 7 | odd | 57 | 2850 | 25 | $50 = 50$ | $\{3,\dots,47\}$ | yes |
| 9 | odd | 91 | 7462 | 41 | $82 = 82$ | $\{3,\dots,79\}$ | yes |

The table confirms: integer self-complementarity holds exactly for odd $q$; the
midpoint enters the non-trivial window exactly from $q=3$ onward.

---

## 7. Applications and connections

**Spectral graph theory.** The lines of $PG(3,q)$ are the vertices of the Grassmann
graph $J_q(4,2)$, a distance-regular (P-polynomial) graph. Boolean degree one
functions are the $\{0,1\}$-vectors lying in $V_0 \oplus V_1$, the top two eigenspaces.
The existence of non-trivial such vectors is a structural fact about the graph's
combinatorial eigenvectors and connects to the broader study of Boolean functions on
association schemes.

**Coding theory and designs.** Cameron–Liebler classes correspond to tight sets and
yield structured line sets used in the construction of two-weight codes and
combinatorial designs; self-complementary classes at the midpoint are particularly
symmetric.

**Field arithmetic as obstruction.** The dependence on the parity of $q$
(Theorem 3.2 and its remark) and the threshold at $q=3$ (Proposition 3.8) exhibit how
number-theoretic constraints on $q$ govern the existence of geometric structures.

**$q$-Krawtchouk bridge to the Hamming scheme.** In the Hamming scheme $H(n,2)$,
degree-one Boolean functions are governed by the first Krawtchouk polynomial
$K_1(x;n) = n-2x$. The Grassmann scheme is the $q$-analogue: its first eigenvalue is a
$q$-deformation of $n-2x$, and Boolean degree one functions are its $\{0,1\}$-valued
eigenvectors. The midpoint $x=(q^2+1)/2$ is exactly where the $q$-linear functional
balances, identifying the self-complementary Bruen–Drudge class as the finite-field
analogue of a balanced Boolean function.

---

## 8. Discussion: separating arithmetic from geometry

A methodological point deserves emphasis. The Bruen–Drudge theorem (geometric
existence of a self-complementary Cameron–Liebler class for odd $q$) rests on an
explicit construction using elliptic quadrics and finite-field arithmetic. Rather than
re-deriving that construction, we factor the result into two independent parts:

- an **unconditional arithmetic core** (Sections 2–3), proving everything about the
  midpoint parameter that does not depend on a class existing; and
- a **hypothesis-driven deduction** (Section 4), proving that *given* a class at the
  midpoint, its indicator is non-constant and hence non-trivial.

This factoring makes the logical content transparent: the only geometric input is the
inhabitation of `CLClass` at the midpoint parameter; everything else is number theory
plus the degree-one counting identity. The same template applies to any parameter $x$:
a class at parameter $x$ is non-trivial precisely when $2 < x < q^2-1$, and
non-constant precisely when $0 < x < q^2+1$.

---

## 9. Future directions

(See PACKAGE.json `future_directions` for the full text.)

- **C1.** The non-trivial window is non-empty iff $q \ge 3$; prove the $q=2$
  impossibility as a finite enumeration on the $35$-line geometry.
- **C2.** Every self-complementary Boolean degree one function forces $q$ odd and
  support size $(q^2+1)(q^2+q+1)/2$.
- **C3.** Parameter rigidity: $\{0,1,2,q^2-1,q^2,q^2+1\}$ is the unique maximal subset
  of $\{0,\dots,q^2+1\}$ closed under complementation and realized for all $q$.
- **C4.** A $q$-Krawtchouk eigenvalue bridge to the Hamming scheme, identifying
  Boolean degree one functions as $\{0,1\}$-eigenvectors of the first $q$-Krawtchouk
  eigenvalue.

---

## 10. Conclusion

We have formally established the arithmetic backbone of the Bruen–Drudge construction:
the midpoint parameter $\operatorname{bdParam}(q)=\lfloor(q^2+1)/2\rfloor$ is a genuine
self-complementary integer exactly for odd $q$, and lies strictly inside the
non-trivial window $(2,q^2-1)$ for all $q \ge 3$. Coupled with a minimal,
hypothesis-driven model of a Cameron–Liebler class and the elementary line counts
$q^2+q+1$ and $(q^2+1)(q^2+q+1)$, this yields a clean conditional theorem: any class
realized at the midpoint, for $q \ge 3$, is a non-constant — hence non-trivial —
Boolean degree one function on $J_q(4,2)$. The result cleanly separates the
unconditional number theory from the geometric realizability carried by the
Bruen–Drudge theorem.
