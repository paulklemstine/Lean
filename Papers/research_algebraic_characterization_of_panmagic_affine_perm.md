# An Algebraic Characterization of Panmagic Affine Permutations over $\mathbb{Z}_n$

## Abstract

We study affine self-maps $\sigma_{a,b}(x) = a x + b$ of the cyclic ring
$\mathbb{Z}_n = \mathbb{Z}/n\mathbb{Z}$ and determine precisely when they
generate *panmagic* (pandiagonal) structures. Following the classical
dictionary between permutations of cyclic groups and pandiagonal Latin squares,
we call $\sigma_{a,b}$ **panmagic** when it is simultaneously a permutation, an
*orthomorphism* (the difference map $x \mapsto \sigma(x) - x$ is a permutation),
and a *complete mapping* (the sum map $x \mapsto \sigma(x) + x$ is a
permutation). Our central structural result reduces this triple condition to a
single arithmetic statement: $\sigma_{a,b}$ is panmagic if and only if the three
consecutive ring elements $a$, $a - 1$, and $a + 1$ are all units of
$\mathbb{Z}_n$. From this we derive a sharp existence theorem: a panmagic affine
permutation of $\mathbb{Z}_n$ exists if and only if $\gcd(n, 6) = 1$, with the
universal witness $a = 2$ working for every admissible modulus. We also describe
the enumeration of such maps via a multiplicative counting function, and outline
generalizations to wider diagonal families, orthogonal families, and
higher-dimensional (matrix) analogues. All results are stated with full
mathematical detail and accompanied by proof sketches.

**Keywords:** affine permutation, panmagic square, pandiagonal Latin square,
orthomorphism, complete mapping, unit, $\mathbb{Z}_n$, Chinese Remainder
Theorem.

**MSC (informal):** combinatorial designs (Latin squares); finite commutative
ring theory; permutation polynomials.

---

## 1. Introduction

A *magic square* of order $n$ is an $n \times n$ array of symbols whose every
row and column (and, classically, both main diagonals) forms a transversal — a
complete system of representatives of the symbol set. The most symmetric variant
is the **pandiagonal** or **panmagic** square, in which *all* broken diagonals,
in both slant directions, are also transversals. Viewing the array on a discrete
torus $\mathbb{Z}_n \times \mathbb{Z}_n$, the broken diagonals are the orbits of
the two shear lines $y - x = \text{const}$ and $y + x = \text{const}$, of which
there are $2n$ in total.

A classical and powerful way to manufacture such arrays is to derive them from a
permutation $\sigma$ of $\mathbb{Z}_n$: place the symbol $\sigma(i) + j$ (or a
similar shift rule) in cell $(i,j)$. Under this dictionary, the rows and columns
are automatically transversals when $\sigma$ is a bijection, the positively
sloped broken diagonals are transversals precisely when $x \mapsto \sigma(x) - x$
is a bijection, and the negatively sloped broken diagonals are transversals
precisely when $x \mapsto \sigma(x) + x$ is a bijection. A permutation whose
difference map is again a permutation is an **orthomorphism**; one whose sum map
is again a permutation is a **complete mapping**. A permutation that is *both* an
orthomorphism and a complete mapping yields a pandiagonal Latin square; we call
such a permutation **panmagic**.

The simplest non-trivial family of permutations of $\mathbb{Z}_n$ is the family
of **affine maps** $\sigma_{a,b}(x) = a x + b$. These are exactly the elements
of the one-dimensional affine group $\mathrm{Aff}(\mathbb{Z}_n)$. The purpose of
this paper is to give a complete, elementary, and fully rigorous algebraic
characterization of which affine maps are panmagic, and to settle the
corresponding existence question for every modulus $n$.

Our results are:

1. **(Bijectivity)** $\sigma_{a,b}$ is a permutation iff $a$ is a unit.
2. **(Diagonal characterizations)** $\sigma_{a,b}$ is an orthomorphism iff
   $a - 1$ is a unit, and a complete mapping iff $a + 1$ is a unit.
3. **(Algebraic characterization)** $\sigma_{a,b}$ is panmagic iff $a$, $a-1$,
   $a+1$ are all units of $\mathbb{Z}_n$.
4. **(Existence)** A panmagic affine permutation of $\mathbb{Z}_n$ exists iff
   $\gcd(n, 6) = 1$.

The structural collapse in (3) — three seemingly different combinatorial demands
reducing to the invertibility of three consecutive ring elements — is the
conceptual core, and the existence dichotomy in (4) follows from it by examining
the primes $2$ and $3$.

---

## 2. Definitions and conventions

Throughout, $n$ is a positive integer and $\mathbb{Z}_n = \mathbb{Z}/n\mathbb{Z}$
is the ring of integers modulo $n$. We write $\mathbb{Z}_n^\times$ for its group
of units. An element $a \in \mathbb{Z}_n$ is a **unit** iff there exists
$a^{-1}$ with $a a^{-1} = 1$; equivalently, iff $\gcd(\tilde a, n) = 1$ for any
integer representative $\tilde a$.

**Definition 2.1 (Affine map).** For $a, b \in \mathbb{Z}_n$, the *affine map*
is
$$\sigma_{a,b} : \mathbb{Z}_n \to \mathbb{Z}_n, \qquad \sigma_{a,b}(x) = a x + b.$$

**Definition 2.2 (Orthomorphism).** A permutation $\sigma$ of $\mathbb{Z}_n$ is
an *orthomorphism* if $x \mapsto \sigma(x) - x$ is also a permutation.

**Definition 2.3 (Complete mapping).** A permutation $\sigma$ of $\mathbb{Z}_n$
is a *complete mapping* if $x \mapsto \sigma(x) + x$ is also a permutation.

**Definition 2.4 (Panmagic affine map).** The affine map $\sigma_{a,b}$ is
*panmagic* if it is a permutation, an orthomorphism, and a complete mapping; that
is, if all three of
$$x \mapsto \sigma_{a,b}(x), \qquad
  x \mapsto \sigma_{a,b}(x) - x, \qquad
  x \mapsto \sigma_{a,b}(x) + x$$
are bijections of $\mathbb{Z}_n$.

These definitions formalize, on the discrete torus, the demand that rows,
columns, and both families of broken diagonals all be transversals.

---

## 3. The unit criterion for affine bijections

The engine driving all subsequent results is a single lemma about affine maps in
*any* commutative ring; finiteness is not needed.

**Lemma 3.1 (Unit criterion).** Let $R$ be a commutative ring and $c, d \in R$.
The map $f(x) = c x + d$ is a bijection of $R$ if and only if $c$ is a unit.

*Proof sketch.* ($\Leftarrow$) If $c$ is a unit with inverse $u = c^{-1}$, then
$g(y) = u(y - d)$ satisfies $f(g(y)) = c\,u(y - d) + d = (y - d) + d = y$ and
$g(f(x)) = u(c x + d - d) = (uc)x = x$, so $f$ is a two-sided inverse pair,
hence bijective. Injectivity also follows from cancellation by the unit $c$.
($\Rightarrow$) If $f$ is surjective, pick $x$ with $f(x) = 1 + d$, i.e.
$c x + d = 1 + d$, so $c x = 1$ and $c$ is a unit. $\square$

The notable feature is that *surjectivity alone* already forces $c$ to be a unit,
so no cardinality argument is required; the equivalence is purely algebraic. In
the Lean development this is `mulAdd_bijective_iff`.

Specializing to $R = \mathbb{Z}_n$ gives the bijectivity of affine permutations.

**Proposition 3.2 (Bijectivity).** $\sigma_{a,b}$ is a permutation of
$\mathbb{Z}_n$ if and only if $a$ is a unit.

*Proof.* Direct instance of Lemma 3.1 with $c = a$, $d = b$. (`affine_bijective_iff`.) $\square$

---

## 4. Diagonal characterizations

The two diagonal demands are themselves affine bijectivity questions, with the
multiplier shifted by $\pm 1$.

**Proposition 4.1 (Orthomorphism criterion).** $\sigma_{a,b}$ is an
orthomorphism iff $a - 1$ is a unit.

*Proof.* For all $x$,
$$\sigma_{a,b}(x) - x = (a x + b) - x = (a - 1)x + b,$$
an affine map with multiplier $a - 1$. By Lemma 3.1, this is a bijection iff
$a - 1$ is a unit. (`orthomorphism_iff`.) $\square$

**Proposition 4.2 (Complete-mapping criterion).** $\sigma_{a,b}$ is a complete
mapping iff $a + 1$ is a unit.

*Proof.* For all $x$,
$$\sigma_{a,b}(x) + x = (a x + b) + x = (a + 1)x + b,$$
an affine map with multiplier $a + 1$. By Lemma 3.1, this is a bijection iff
$a + 1$ is a unit. (`completeMapping_iff`.) $\square$

Note that in both computations the additive constant $b$ is preserved unchanged;
it never affects whether the relevant map is a bijection. This already foretells
that panmagicness is independent of $b$.

---

## 5. The algebraic characterization

Combining the three criteria gives the central structural theorem.

**Theorem 5.1 (Algebraic characterization of panmagic affine maps).** For all
$a, b \in \mathbb{Z}_n$,
$$\sigma_{a,b} \text{ is panmagic} \iff a,\ a - 1,\ a + 1 \text{ are all units of } \mathbb{Z}_n.$$

*Proof.* By Definition 2.4, $\sigma_{a,b}$ is panmagic iff the three maps
$\sigma_{a,b}$, $\sigma_{a,b}(\cdot) - \mathrm{id}$, and
$\sigma_{a,b}(\cdot) + \mathrm{id}$ are all bijections. By Proposition 3.2 these
are bijections iff $a$, $a-1$, and $a+1$ (respectively) are units. Conjoining the
three equivalences yields the claim. (`isPanmagic_iff_units`.) $\square$

Theorem 5.1 is the heart of the paper: the highly constrained, geometric notion
of "pandiagonal in every broken diagonal" is exactly captured by the purely
multiplicative requirement that three consecutive elements be simultaneously
invertible. The shift $b$ is a free parameter — it translates the pattern but
never destroys or creates panmagicness — so the analysis reduces entirely to the
multiplier $a$.

---

## 6. Existence: the role of $2$ and $3$

We now determine for which $n$ a panmagic affine permutation exists at all. By
Theorem 5.1 this is equivalent to asking: *for which $n$ does there exist
$a \in \mathbb{Z}_n$ with $a$, $a-1$, $a+1$ all units?* The obstructions are
exactly the primes $2$ and $3$.

### 6.1 Local obstructions

**Lemma 6.1 (No solution mod 2).** There is no $x \in \mathbb{Z}_2$ for which
both $x$ and $x - 1$ are units.

*Proof.* Finite check: $\mathbb{Z}_2 = \{0, 1\}$. If $x = 0$ then $x$ is not a
unit; if $x = 1$ then $x - 1 = 0$ is not a unit. (`not_units_zmod_two`,
discharged by `decide`.) $\square$

**Lemma 6.2 (No solution mod 3).** There is no $x \in \mathbb{Z}_3$ for which
all of $x$, $x - 1$, $x + 1$ are units.

*Proof.* Finite check: among the three consecutive residues $x - 1, x, x + 1$
modulo $3$, all three residues $\{0, 1, 2\}$ occur, so exactly one equals $0$,
which is not a unit. (`not_units_zmod_three`, discharged by `decide`.) $\square$

These local facts propagate to any modulus divisible by $2$ or $3$ via reduction
ring homomorphisms.

**Lemma 6.3 (Obstruction at 2).** If $a$ and $a - 1$ are units of
$\mathbb{Z}_n$, then $2 \nmid n$.

*Proof sketch.* Suppose $2 \mid n$. The natural reduction map
$\pi : \mathbb{Z}_n \to \mathbb{Z}_2$ is a ring homomorphism, and ring
homomorphisms send units to units. Hence $\pi(a)$ and $\pi(a - 1) = \pi(a) - 1$
would both be units of $\mathbb{Z}_2$, contradicting Lemma 6.1.
(`not_two_dvd_of_units`.) $\square$

**Lemma 6.4 (Obstruction at 3).** If $a$, $a - 1$, $a + 1$ are units of
$\mathbb{Z}_n$, then $3 \nmid n$.

*Proof sketch.* Suppose $3 \mid n$. Reduce along
$\pi : \mathbb{Z}_n \to \mathbb{Z}_3$. Then $\pi(a)$, $\pi(a) - 1$, $\pi(a) + 1$
would all be units of $\mathbb{Z}_3$, contradicting Lemma 6.2.
(`not_three_dvd_of_units`.) $\square$

### 6.2 The universal witness

For the converse we need only a single construction.

**Lemma 6.5 (Witness $a = 2$).** If $\gcd(n, 6) = 1$, then $a = 2$ gives a
panmagic affine permutation $\sigma_{2,0}$.

*Proof.* With $a = 2$ the three required units are
$$a - 1 = 1, \qquad a = 2, \qquad a + 1 = 3.$$
The element $1$ is always a unit. Since $\gcd(n, 6) = 1$ means $\gcd(n, 2) = 1$
and $\gcd(n, 3) = 1$, both $2$ and $3$ are units of $\mathbb{Z}_n$. By
Theorem 5.1, $\sigma_{2,0}$ is panmagic. $\square$

No Chinese-Remainder gluing is needed: a single arithmetic-progression witness
works simultaneously for every admissible modulus.

### 6.3 The existence dichotomy

**Theorem 6.6 (Existence).** A panmagic affine permutation of $\mathbb{Z}_n$
exists if and only if $\gcd(n, 6) = 1$.

*Proof.* ($\Rightarrow$) Suppose $\sigma_{a,b}$ is panmagic. By Theorem 5.1,
$a$, $a-1$, $a+1$ are units. Lemma 6.3 gives $2 \nmid n$ and Lemma 6.4 gives
$3 \nmid n$, i.e. $\gcd(n, 2) = \gcd(n, 3) = 1$, hence $\gcd(n, 6) = 1$.
($\Leftarrow$) If $\gcd(n, 6) = 1$, Lemma 6.5 produces the explicit panmagic map
$\sigma_{2,0}$. (`exists_panmagic_iff_coprime_six`.) $\square$

Consequently the admissible moduli are exactly those coprime to $6$:
$$n \in \{1, 5, 7, 11, 13, 17, 19, 23, 25, 29, 31, 35, \dots\},$$
while every multiple of $2$ or $3$ is forbidden.

---

## 7. Enumeration

Theorem 5.1 also yields a clean count. Because panmagicness is independent of the
shift $b$, the number of panmagic affine permutations of $\mathbb{Z}_n$ is
$$N(n) = n \cdot P(n), \qquad
  P(n) = \#\{\, a \in \mathbb{Z}_n : a,\ a-1,\ a+1 \text{ all units} \,\}.$$

**Proposition 7.1 (Multiplicative count).** The function $P$ is multiplicative:
for coprime $m, n$, $P(mn) = P(m)P(n)$, and on prime powers
$$P(p^k) = \begin{cases} 0, & p \in \{2, 3\}, \\ p^{k-1}(p - 3), & p \geq 5.\end{cases}$$
Hence
$$P(n) = \prod_{p^k \,\|\, n} p^{k-1}(p - 3), \qquad P(1) = 1,$$
and $P(n) > 0$ iff $\gcd(n, 6) = 1$, recovering Theorem 6.6.

*Proof sketch.* Multiplicativity follows from the Chinese Remainder isomorphism
$\mathbb{Z}_{mn} \cong \mathbb{Z}_m \times \mathbb{Z}_n$ for coprime $m, n$:
an element is a unit in the product iff each coordinate is, and the three
conditions on $a, a \pm 1$ factor coordinatewise. For a prime power $p^k$ with
$p \geq 5$, an element $a$ fails to be "good" exactly when $a \equiv 0$,
$a \equiv 1$, or $a \equiv -1 \pmod p$ (the only ways for $a$, $a-1$, or $a+1$ to
be a non-unit); these are three *distinct* residues mod $p$ since $p \geq 5$, and
each lifts to $p^{k-1}$ residues mod $p^k$. Removing them from the $p^k$ total
leaves $p^k - 3p^{k-1} = p^{k-1}(p-3)$ good multipliers. For $p \in \{2, 3\}$
Lemmas 6.1–6.2 give count $0$. $\square$

For example $P(5) = 5^0(5-3) = 2$ and $N(5) = 5 \cdot 2 = 10$; $P(7) = 7 - 3 = 4$
and $N(7) = 28$; $P(25) = 5^1(5-3) = 10$ and $N(25) = 250$; $P(35) = P(5)P(7) =
2 \cdot 4 = 8$ and $N(35) = 280$. These are directly verifiable by exhaustive
search and serve as cross-checks of the theory. (This enumeration is conjectured
in the Phase A future directions and is fully consistent with the proven
Theorems 5.1 and 6.6.)

---

## 8. Worked examples

We illustrate the theory on several small moduli; each statement below is
mechanically checkable by exhaustive search and serves as an independent
confirmation of Theorems 5.1 and 6.6 and of Proposition 7.1.

**The smallest nontrivial board, $n = 5$.** Here $\gcd(5, 6) = 1$, so panmagic
maps exist. The good multipliers are those $a$ with $a$, $a - 1$, $a + 1$ all
units, i.e. all of $a$, $a - 1$, $a + 1$ nonzero modulo the prime $5$. The bad
residues are $a \equiv 0, 1, 4 \pmod 5$ (making $a$, $a - 1$, $a + 1$ vanish
respectively), leaving exactly $a \in \{2, 3\}$. Thus $P(5) = 2$, matching
$p^{k-1}(p - 3) = 5^0 \cdot 2 = 2$, and $N(5) = 5 \cdot 2 = 10$. The witness
$a = 2$, $b = 0$ gives the map $\sigma(x) = 2x$, whose associated array
$\mathrm{cell}(i, j) = (2i + j) \bmod 5$ is a genuine $5 \times 5$ pandiagonal
Latin square.

**A prime board, $n = 7$.** Again $\gcd(7, 6) = 1$. The bad residues are
$0, 1, 6$, leaving $a \in \{2, 3, 4, 5\}$, so $P(7) = 4 = 7 - 3$ and
$N(7) = 28$. Note that $a = 2$ and $a = 5$ are related by the symmetry
$a \mapsto -a$, which preserves the unit conditions because the set
$\{a, a - 1, a + 1\}$ maps to $\{-a, -a - 1, -a + 1\}$, the same triple up to
sign.

**A prime-power board, $n = 25$.** Now the relevant prime is $5$ with exponent
$2$. The bad residues modulo $5$ are $0, 1, 4$, each lifting to $5$ residues
modulo $25$; removing the $15$ bad values from $25$ leaves $10$ good
multipliers, matching $p^{k-1}(p - 3) = 5^1 \cdot 2 = 10$. Hence
$N(25) = 25 \cdot 10 = 250$.

**A composite board, $n = 35 = 5 \cdot 7$.** By multiplicativity,
$P(35) = P(5) \cdot P(7) = 2 \cdot 4 = 8$, so $N(35) = 35 \cdot 8 = 280$. The
Chinese Remainder Theorem identifies a good multiplier mod $35$ with a pair of
good multipliers mod $5$ and mod $7$; for instance $a = 2$ is good in both
coordinates and is the universal witness.

**A forbidden board, $n = 6$.** Since $6$ is divisible by both $2$ and $3$, no
panmagic affine permutation exists. Concretely, for any $a$, either $a$ or
$a - 1$ is even (hence a non-unit mod $6$), and among $a - 1, a, a + 1$ one is
divisible by $3$. Thus $P(6) = 0$ and $N(6) = 0$, consistent with Theorem 6.6.

## 9. Algorithms

The theory is constructive and yields efficient procedures.

### 9.1 Deciding panmagicness

Given $n$ and $(a, b)$, Theorem 5.1 reduces the test to three gcd computations.

```
function IS_PANMAGIC(n, a, b):
    return gcd(a, n) == 1 and gcd(a-1 mod n, n) == 1 and gcd(a+1 mod n, n) == 1
```

This runs in $O(\log n)$ ring operations via the Euclidean algorithm and entirely
avoids materializing the $n \times n$ square or enumerating its $2n$ diagonals.

### 9.2 Deciding existence and producing a witness

By Theorem 6.6 existence is a single gcd test, and Lemma 6.5 supplies the
witness.

```
function PANMAGIC_WITNESS(n):
    if gcd(n, 6) == 1:
        return (a = 2 mod n, b = 0)   # certified panmagic by Theorem 5.1
    else:
        return NONE                    # no panmagic affine map exists
```

### 9.3 Counting

By Proposition 7.1, $N(n) = n \cdot \prod_{p^k \| n} p^{k-1}(p-3)$, computable in
the time of one factorization of $n$.

---

## 10. Applications

**Pandiagonal Latin squares and combinatorial designs.** Panmagic permutations
are exactly the algebraic seeds of pandiagonal Latin squares, which underpin
statistical experimental design (row–column designs robust to cyclic shifts) and
the construction of mutually orthogonal Latin squares (MOLS).

**Sequence and array generation.** Affine panmagic maps give cheap, certifiable
recipes for arrays that remain balanced under toroidal shifts — useful in
interleavers for error-correcting codes and in spreading sequences where
diagonal balance corresponds to good correlation properties.

**Number-theoretic transparency.** The reduction of a global combinatorial
property to "three consecutive units" makes the admissible-modulus set
($\gcd(n,6)=1$) immediately legible and gives an exact population count, useful
when sampling such structures uniformly.

---

## 11. Discussion and future work

The results above are sharp and complete for the one-dimensional affine,
single-step case. Several precise and falsifiable extensions suggest themselves.

**C1 (Enumeration).** As in Proposition 7.1, conjecturally $N(n) = n\,P(n)$ with
$P$ the multiplicative function $P(p^k) = p^{k-1}(p-3)$ (and $0$ for
$p \in \{2,3\}$); provable via the CRT isomorphism and the prime-power count.

**C2 ($r$-panmagic / higher diagonals).** Call $\sigma$ *$r$-panmagic* if
$x \mapsto \sigma(x) + j x$ is a permutation for every $j \in \{-r, \dots, r\}$.
For affine $\sigma_{a,b}$ this means $a + j$ is a unit for all $|j| \leq r$.
Conjecture: an $r$-panmagic affine permutation of $\mathbb{Z}_n$ exists iff every
prime divisor of $n$ exceeds $2r + 1$, with witness $a = r + 1$. The present
paper is the cases $r = 0$ (trivial), one-sided $r = 1$ (odd $n$), and two-sided
$r = 1$ ($\gcd(n,6) = 1$).

**C3 (Orthogonality / MOLS bound).** Two affine permutations $\sigma_{a,b}$,
$\sigma_{c,d}$ are *orthogonal* iff $x \mapsto \sigma(x) - \tau(x)$ is a
permutation, i.e. iff $a - c$ is a unit. Conjecture: the maximum size of a family
of pairwise-orthogonal affine permutations of $\mathbb{Z}_n$ equals
$1 + \min_{p \mid n}(p - 1)$, attained by $\{\sigma_{a,0} : a \in S\}$ for a
maximal $S$ with pairwise-unit differences.

**C4 (Non-cyclic generalization).** Over a finite commutative ring $R$ (or
$(\mathbb{Z}_n)^d$), an affine panmagic permutation $x \mapsto A x + b$ should
exist iff some $A$ has $A$, $A - I$, $A + I$ all invertible; for $R = \mathbb{Z}_n$,
$d = 1$ this recovers $\gcd(n,6) = 1$. Over $(\mathbb{Z}_2)^d$, since
$A + I = A - I$, the obstruction is whether $1$ is an eigenvalue of $A$,
conjecturally avoidable for all $d \geq 2$.

**C5 (Diagonal spectrum).** For a unit $a$, define the *defect set*
$D(a) = \{ j : a + j \text{ not a unit}\}$. Conjecture: $\sigma_{a,b}$ lies on a
panmagic family of "width" $w$ iff $D(a) \cap \{-w, \dots, w\} = \emptyset$, with
an explicit Euler-product generating function matching C1.

---

## 12. Conclusion

We have shown that the rich, geometric notion of a panmagic affine permutation of
$\mathbb{Z}_n$ collapses to a transparent algebraic criterion — the simultaneous
invertibility of three consecutive elements $a$, $a - 1$, $a + 1$ — and that
existence is governed by the single divisibility condition $\gcd(n, 6) = 1$, with
$a = 2$ as a universal witness. The argument is elementary, fully constructive,
and yields efficient decision, witness-generation, and counting algorithms. The
framework extends naturally to wider diagonal families, orthogonal families, and
higher-dimensional analogues, each phrased as a precise conjecture for future
work.
