# A Figurate-Geometry Reformulation of Brocard's Problem: Triangular Factorial-Eighths

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Geometry (figurate numbers)

---

## Abstract

Brocard's problem asks for all natural numbers $n$ such that $n! + 1$ is a
perfect square. The only known solutions are the **Brown numbers**
$n \in \{4, 5, 7\}$, giving $(n,m) = (4,5), (5,11), (7,71)$; whether these are
the only solutions is a famous open conjecture (Brocard 1876, Ramanujan 1913).
We recast the problem in the language of figurate (triangular) numbers. Writing
$T_y = y(y+1)/2$ for the $y$-th triangular number, we prove the unconditional
equivalence
$$\text{for } n \ge 2:\quad \bigl(\exists\, y,\ n! = 8\,T_y\bigr) \iff \bigl(\exists\, m,\ n! + 1 = m^2\bigr),$$
i.e. $n!/8$ is triangular precisely when $n$ is a Brown number. The bridge is the
classical discriminant identity $8\,T_y + 1 = (2y+1)^2$, which we promote to a
full two-way **square characterization of triangularity**: $t$ is triangular iff
$8t + 1$ is a perfect square. As corollaries we obtain (i) the structural fact
that any Brown root $m$ is odd with index map $y \mapsto 2y+1$, (ii) the explicit
triangular indices $2, 5, 35$ of the three Brown numbers, and (iii) a finite,
exhaustive verification that no Brown number exists for $8 \le n \le 50$. We do
**not** claim the full classification — that is exactly Brocard's open problem —
but we make the geometric dictionary completely rigorous and discuss several
falsifiable research directions it suggests. All results in this paper have been
formally verified.

**Keywords:** Brocard's problem, Brown numbers, triangular numbers, figurate
numbers, factorial, perfect square, discriminant identity, Wilson's theorem.

---

## 1. Introduction

### 1.1 Brocard's problem

For a natural number $n$, the factorial is $n! = \prod_{k=1}^{n} k$ (with the
conventions $0! = 1! = 1$). **Brocard's problem** asks:

> For which $n$ does there exist an integer $m$ with $n! + 1 = m^2$?

Direct computation finds three solutions:
$$4! + 1 = 25 = 5^2, \qquad 5! + 1 = 121 = 11^2, \qquad 7! + 1 = 5041 = 71^2,$$
corresponding to $n = 4, 5, 7$. These are the **Brown numbers**. Extensive
computation (to $n$ with more than $10^9$) has revealed no further solutions, and
it is conjectured there are none. No proof is known. The problem was posed by
Henri Brocard in 1876 and independently by Srinivasa Ramanujan in 1913.

### 1.2 A geometric reformulation

This paper studies Brocard's problem through **figurate numbers**, specifically
the triangular numbers $T_y = y(y+1)/2$ that count dots in a triangular array of
side $y$. Our central observation is that the classical identity
$$8\,T_y + 1 = (2y+1)^2$$
is strong enough, when read in both directions, to convert Brocard's problem into
a question purely about triangularity:

> **(Main equivalence.)** For $n \ge 2$, the integer $n!/8$ is triangular if and
> only if $n! + 1$ is a perfect square.

This dictionary is exact and unconditional. It does not resolve Brocard's problem
— the full classification "only $\{4,5,7\}$" remains open — but it provides a
clean geometric face to every solution and a structured framework for further
attack.

### 1.3 Contributions

1. A division-free characterization of triangular numbers and the discriminant
   identity $8T_y + 1 = (2y+1)^2$ (Section 3).
2. A two-way **square characterization of triangularity**: $t$ is triangular iff
   $8t+1$ is a perfect square (Section 4).
3. The **main geometric equivalence** for Brocard's problem (Section 5).
4. Structural corollaries: oddness of the Brown root and the index map
   $y \mapsto 2y+1$; the explicit indices $2, 5, 35$ (Section 6).
5. A finite exhaustive verification that no Brown number exists for
   $8 \le n \le 50$ (Section 7).
6. A discussion of falsifiable research directions, including a linear-detector
   rigidity conjecture and Wilson-theorem obstructions (Section 8).

All statements have been formally verified in a proof assistant; we present
mathematical statements and proof sketches here.

---

## 2. Preliminaries and definitions

We work throughout in the natural numbers $\mathbb{N} = \{0, 1, 2, \dots\}$.

**Definition 2.1 (Triangular number).** For $y \in \mathbb{N}$, the $y$-th
*triangular number* is
$$T_y := \frac{y(y+1)}{2}.$$
Since $y(y+1)$ is always even (one of two consecutive integers is even), the
division is exact and $T_y \in \mathbb{N}$. The first values are
$T_0 = 0, T_1 = 1, T_2 = 3, T_3 = 6, T_4 = 10, T_5 = 15, T_6 = 21, \dots$

**Definition 2.2 (Perfect square).** An integer $s$ is a *perfect square* if
$s = m^2$ for some $m \in \mathbb{N}$.

**Definition 2.3 (Brown number).** A natural number $n$ is a *Brown number* if
there exists $m \in \mathbb{N}$ with $n! + 1 = m^2$. (Equivalently, $(n,m)$ is a
*Brown pair*.)

**Definition 2.4 (Triangular witness).** Given $n$, a *triangular witness* is an
index $y$ with $n! = 8\,T_y$, i.e. $n!/8 = T_y$ is triangular.

A subtle but important modeling point: we phrase "triangular" as the existence of
an *index*, $\exists\, y,\ t = T_y$, rather than as a loose floor-division
condition. This makes the characterizing equivalence of Section 4 symmetric and
removes the friction of truncated natural-number division.

---

## 3. The discriminant identity

The engine of the entire development is a single quadratic identity, which we
prepare with a division-free reformulation of $T_y$.

**Lemma 3.1 (Division-free triangular identity).** For all $y \in \mathbb{N}$,
$$2\,T_y = y(y+1).$$

*Proof sketch.* By definition $T_y = y(y+1)/2$ with exact division because
$2 \mid y(y+1)$ (consecutive integers; equivalently `Nat.even_mul_succ_self`).
Multiplying back by $2$ cancels the division, giving $2T_y = y(y+1)$. The only
technical care needed is to discharge the divisibility *before* invoking ring
normalization, since natural-number division is otherwise opaque to algebraic
tactics. $\qquad\blacksquare$

**Theorem 3.2 (Figurate discriminant identity).** For all $y \in \mathbb{N}$,
$$8\,T_y + 1 = (2y + 1)^2.$$

*Proof sketch.* Expand the right side: $(2y+1)^2 = 4y^2 + 4y + 1 = 4\,y(y+1) + 1$.
By Lemma 3.1, $y(y+1) = 2T_y$, so $4\,y(y+1) = 8\,T_y$. Hence
$(2y+1)^2 = 8\,T_y + 1$. $\qquad\blacksquare$

**Geometric reading.** Eight congruent triangular arrays of side $y$, together
with one central dot, tile exactly a square array of odd side $2y+1$. This is the
figurate content of the identity and the reason "multiply by $8$, add $1$"
detects triangularity.

---

## 4. Square characterization of triangular numbers

Theorem 3.2 gives one direction (triangular $\Rightarrow$ $8t+1$ square). The
converse requires extracting the index from a square root, which hinges on a
parity observation.

**Lemma 4.1 (Root parity).** If $8t + 1 = m^2$, then $m$ is odd.

*Proof sketch.* The left side $8t + 1$ is odd, so $m^2$ is odd, hence $m$ is odd
(an even square is even). Formally, applying the predicate "is even" to both
sides of $8t + 1 = m^2$ and simplifying with parity lemmas forces $m$ odd.
$\qquad\blacksquare$

**Theorem 4.2 (Square characterization of triangularity).** For all
$t \in \mathbb{N}$,
$$\bigl(\exists\, y,\ t = T_y\bigr) \iff \bigl(\exists\, m,\ 8t + 1 = m^2\bigr).$$

*Proof sketch.*
($\Rightarrow$) If $t = T_y$, take $m = 2y + 1$; Theorem 3.2 gives
$8t + 1 = (2y+1)^2 = m^2$.

($\Leftarrow$) Suppose $8t + 1 = m^2$. By Lemma 4.1, $m$ is odd, so $m = 2y + 1$
for some $y$. Then $m^2 = (2y+1)^2 = 8T_y + 1$ by Theorem 3.2, and comparing with
$m^2 = 8t + 1$ yields $8t = 8T_y$, hence $t = T_y$. Thus $t$ is triangular with
explicit index $y = (m-1)/2$. $\qquad\blacksquare$

Theorem 4.2 is the "right" statement: triangularity, a figurate property,
coincides with a single quadratic-residue / square test. It is also genuinely
non-vacuous — both predicates hold for $t \in \{0, 1, 3, 6, 10\}$ and fail for
$t \in \{2, 4, 5\}$ — so the equivalence connects nonempty, distinct families.

---

## 5. The main geometric equivalence for Brocard's problem

We now specialize the characterization to factorial-eighths. For $n \ge 4$ one
has $8 \mid n!$, so $n!/8$ is a genuine natural number; the statement below is
phrased to avoid division entirely.

**Lemma 5.1 (Brown root is odd).** Let $n \ge 2$ and suppose $n! + 1 = m^2$. Then
$m$ is odd.

*Proof sketch.* Since $n \ge 2$, $2 \mid n!$ (as $2$ is one of the factors), so
$n!$ is even and $m^2 = n! + 1$ is odd; therefore $m$ is odd. $\qquad\blacksquare$

**Theorem 5.2 (Main equivalence — Brocard via triangular numbers).** For
$n \ge 2$,
$$\bigl(\exists\, y,\ n! = 8\,T_y\bigr) \iff \bigl(\exists\, m,\ n! + 1 = m^2\bigr).$$

*Proof sketch.*
($\Rightarrow$) Given $y$ with $n! = 8T_y$, set $m = 2y + 1$. Then
$n! + 1 = 8T_y + 1 = (2y+1)^2 = m^2$ by Theorem 3.2.

($\Leftarrow$) Given $m$ with $n! + 1 = m^2$, Lemma 5.1 gives $m$ odd, say
$m = 2y + 1$. By Theorem 3.2, $m^2 = 8T_y + 1$, so $n! + 1 = 8T_y + 1$, hence
$n! = 8T_y$. The index $y = (m-1)/2$ is the triangular witness. $\qquad\blacksquare$

**Interpretation.** The Brown numbers are exactly the $n$ for which the
factorial-eighth $n!/8$ is a perfect triangle of dots. Brocard's problem is, in
this precise sense, the figurate problem "when is $n!/8$ triangular?". The
equivalence is unconditional; it reformulates, but does not resolve, the open
classification.

---

## 6. Structural corollaries: the index map and the three solutions

**Corollary 6.1 (Index map).** In any Brown pair $(n, m)$ with $n \ge 2$, the
root is odd and $m = 2y + 1$ where $y = (m-1)/2$ is the triangular index. Thus the
correspondence between Brown solutions and triangular witnesses is given
explicitly by
$$y \longmapsto m = 2y + 1, \qquad m \longmapsto y = \frac{m-1}{2}.$$

*Proof.* Immediate from Lemma 5.1 and the construction in Theorem 5.2.
$\qquad\blacksquare$

**Theorem 6.2 (The three Brown numbers in triangular form).**
$$4! = 8\,T_2, \qquad 5! = 8\,T_5, \qquad 7! = 8\,T_{35}.$$

*Proof.* Direct computation:
$4! = 24 = 8 \cdot 3 = 8\,T_2$;
$5! = 120 = 8 \cdot 15 = 8\,T_5$;
$7! = 5040 = 8 \cdot 630 = 8\,T_{35}$. (Verified by decision procedure.)
$\qquad\blacksquare$

Via the index map, the corresponding roots are $m = 2\cdot 2 + 1 = 5$,
$m = 2\cdot 5 + 1 = 11$, and $m = 2\cdot 35 + 1 = 71$, recovering the classical
$(4,5), (5,11), (7,71)$. The triangular indices $2, 5, 35$ exhibit gaps $3$ and
$30$ that follow no apparent linear or polynomial pattern — a reflection of the
super-exponential irregularity of $n!$.

---

## 7. Finite verification: no Brown numbers in $8 \le n \le 50$

**Theorem 7.1 (No Brown number for $8 \le n \le 50$).** For every $n$ with
$8 \le n \le 50$ there is no $m$ with $n! + 1 = m^2$. Equivalently (by
Theorem 5.2) there is no triangular witness for $n!/8$ in this range.

*Proof sketch.* Exhaustive case analysis over the finitely many $n$. For each
$n$, one computes $n! + 1$ and checks it is not a perfect square; the cleanest
formal route compares $n! + 1$ with $\lfloor\sqrt{n!+1}\rfloor^2$ and observes
they differ. The computation is finite and decidable. $\qquad\blacksquare$

**Role of the result.** Beyond extending the empirical record, Theorem 7.1 makes
the main equivalence demonstrably *non-vacuous*: the predicates "triangular
factorial-eighth" and "factorial successor is square" each have explicit models
($n = 4, 5, 7$) and explicit non-models ($n = 8, \dots, 50$). The dictionary of
Section 5 connects two genuinely inhabited, genuinely distinct families.

---

## 8. Discussion and future directions

The reformulation gives Brocard's problem a figurate face, but the hard core
remains: deciding triangularity of $n!/8$ uniformly in $n$ is equivalent to
Brocard's open classification. No elementary obstruction is known. We record
several falsifiable directions the geometry suggests.

**C1. Linear-detector rigidity.** Conjecture: among positive integer pairs
$(a,b)$, the form $a\,t + b$ is a perfect square for *every* triangular $t$ and a
non-square for every non-triangular $t$ **iff** $(a,b) = (8,1)$. The figurate
discriminant $8T_y + 1 = (2y+1)^2$ would then be the unique linear
square-detector of triangularity. The $(8,1)$ direction is exactly Theorem 4.2;
the uniqueness is checkable by finite search over small $(a,b)$.

**C2. Density and the factor-split obstruction.** Conjecture: the set
$\{n : n!/8 \text{ is triangular}\}$ has natural density $0$, and more strongly
$n! + 1$ is never square for $n \ge 8$ (Brocard). The key structure is that
$n! + 1 = m^2$ forces $(m-1)(m+1) = n!$ with $\gcd(m-1, m+1) \le 2$, splitting
$n!$ into two near-equal, almost-coprime factors — increasingly implausible as the
prime content of $n!$ grows. Borel–Cantelli heuristics already make the
density-zero expectation believable; converting the factor split into a formal
congruence obstruction is the next concrete target.

**C3. Wilson-index obstruction for prime-shifted $n$.** Conjecture: if
$n = p - 1$ for a prime $p \ge 11$, then $n!/8$ is not triangular. By Wilson's
theorem, $(p-1)! \equiv -1 \pmod p$, so $p \mid (p-1)! + 1 = m^2$, forcing
$p \mid m$ and hence $m \ge p$, i.e. $m^2 \ge p^2$. Comparing with
$m^2 = (p-1)! + 1$ and the lower bound $(p-1)! \ge p^2$ yields a contradiction for
large $p$, closing this infinite sub-family unconditionally.

**C4. Triangular-index growth law.** The three Brown indices are $2, 5, 35$;
conjecturally these are the only $y$ with $8T_y + 1 = n! + 1$ for some $n$, and
they obey no polynomial recurrence (gaps $3, 30$). The index map of Corollary 6.1,
$y = (\sqrt{n!+1} - 1)/2$, inherits the irregularity of $n!$, making "no
recurrence" a falsifiable claim testable against any future-discovered Brown
number.

---

## 9. Conclusion

We have recast Brocard's problem in the geometry of triangular numbers. The
classical identity $8T_y + 1 = (2y+1)^2$, read in both directions, yields a clean
square characterization of triangularity (Theorem 4.2) and, specialized to
factorial-eighths, the unconditional equivalence "$n!/8$ triangular $\iff$ $n!+1$
square" (Theorem 5.2). The three Brown numbers become three explicit triangles of
sides $2, 5, 35$, the Brown root is always the odd number $m = 2y + 1$, and an
exhaustive check rules out new solutions for $8 \le n \le 50$. The full
classification remains the open Brocard–Ramanujan conjecture, but the figurate
dictionary clarifies precisely what a fourth solution would have to look like and
points to several concrete, falsifiable lines of further attack.

---

## References

- H. Brocard, *Question 166*, Nouv. Corresp. Math. **2** (1876), 287.
- S. Ramanujan, *Question 469*, J. Indian Math. Soc. **5** (1913), 59.
- Triangular numbers and the identity $8T_y + 1 = (2y+1)^2$ are classical
  (Pythagorean figurate numbers).
