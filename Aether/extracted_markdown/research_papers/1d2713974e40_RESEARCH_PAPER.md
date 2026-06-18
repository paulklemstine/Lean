# The Fibonacci Apparition Lattice: A Discrete Geometry in Which Parallel Lines Both Converge and Diverge

## Abstract

We study the *rank of apparition* (entry point) $\alpha(m)$ of a positive
integer $m$ with respect to the Fibonacci sequence — the least index $k>0$ with
$m \mid F_k$ — and we recast its arithmetic as a discrete geometry of
*divisibility lines* $L(m) = \{k : m \mid F_k\}$. The Law of Apparition,
$m \mid F_k \iff \alpha(m) \mid k$, identifies each $L(m)$ with the principal
ideal $\alpha(m)\,\mathbb{N}$, an arithmetic progression of common difference
$\alpha(m)$. We prove four structural results about the map $\alpha$ viewed as a
morphism between the divisibility lattice of moduli and the divisibility lattice
of indices: (i) an **unrestricted join law**
$\alpha(\operatorname{lcm}(a,b)) = \operatorname{lcm}(\alpha(a),\alpha(b))$ for
all $a,b>0$, removing the classical coprimality hypothesis; (ii)
**monotonicity** $a \mid b \Rightarrow \alpha(a) \mid \alpha(b)$; (iii) a
**meet bound** $\alpha(\gcd(a,b)) \mid \gcd(\alpha(a),\alpha(b))$; and (iv) a
**strictness witness** ($a=4,b=6$) showing the meet bound is in general proper,
so $\alpha$ is a join-morphism but *not* a meet-morphism. Geometrically these
say that two divisibility lines locally **diverge** (distinct constant spacings,
the Euclidean/hyperbolic face) yet globally **reconverge** on the intersection
line $L(\operatorname{lcm}(a,b))$ with step $\operatorname{lcm}(\alpha
a,\alpha b)$ (the elliptic face). The join/meet asymmetry is the precise
arithmetic signature distinguishing the two faces. We close with the Pythagorean
apparition profile $(\alpha 3,\alpha 4,\alpha 5)=(4,6,5)$, applications, and
directions toward a full prime-power reconstruction of $\alpha$. All results are
formally verified.

**Keywords.** Fibonacci numbers, rank of apparition, entry point, divisibility
lattice, parallel postulate, discrete geometry, lattice morphism, least common
multiple.

---

## 1. Introduction

### 1.1 Motivation: the parallel postulate, three ways

Euclid's fifth postulate is equivalent to the statement that through a point not
on a line there passes exactly one parallel. Replacing this axiom yields the
two classical non-Euclidean geometries: in hyperbolic geometry parallels
*diverge* (infinitely many ultraparallels, separating at exponential rate),
while in elliptic geometry there are no parallels at all — every pair of
geodesics *converges* and meets. A geometry cannot do both: divergence and
convergence are mutually exclusive properties of the metric.

In this paper we exhibit a *discrete, arithmetic* geometry in which the
dichotomy genuinely dissolves. The "lines" are divisibility classes inside the
Fibonacci sequence; "parallel" is a local statement about spacing and
"intersection" a global statement about coincidence; and the same pair of
parallel lines diverges locally and reconverges globally. The phenomenon is not
a metaphor: each behavior is a theorem, and the location of every reconvergence
is given by an exact closed form.

### 1.2 The organizing object

For $m \ge 1$ the **rank of apparition** is
$$\alpha(m) = \min\{\,k > 0 : m \mid F_k\,\},$$
where $F$ is the Fibonacci sequence $F_1 = F_2 = 1$, $F_{n+2}=F_{n+1}+F_n$
(with the convention $F_0 = 0$). That the minimum exists for every $m$ is the
classical *totality* result (the Fibonacci sequence is purely periodic modulo
$m$, hence hits $0$). The map $\alpha:\mathbb{Z}_{\ge 1}\to\mathbb{Z}_{\ge 1}$
is the protagonist.

### 1.3 Contributions

Working over the divisibility lattice $(\mathbb{Z}_{\ge 1}, \mid)$ — whose join
is $\operatorname{lcm}$ and meet is $\gcd$ — we establish and formally verify:

1. **Join law (Theorem 4.1).**
   $\alpha(\operatorname{lcm}(a,b)) = \operatorname{lcm}(\alpha(a),\alpha(b))$
   for *all* $a,b>0$, with no coprimality assumption.
2. **Monotonicity (Theorem 5.1).** $a \mid b \Rightarrow \alpha(a)\mid\alpha(b)$.
3. **Meet bound (Theorem 6.1).**
   $\alpha(\gcd(a,b)) \mid \gcd(\alpha(a),\alpha(b))$.
4. **Strictness (Theorem 6.2).** With $a=4,b=6$:
   $\alpha(\gcd(4,6)) = 3 \neq 6 = \gcd(\alpha 4,\alpha 6)$, so the meet bound is
   not in general an equality.
5. **Geometric reading (Section 7).** $L(m) = \alpha(m)\mathbb{N}$; lines
   diverge locally; $L(a)\cap L(b) = L(\operatorname{lcm}(a,b))$ with step
   $\operatorname{lcm}(\alpha a, \alpha b)$ (convergence); the
   join/meet asymmetry separates the two faces.
6. **Pythagorean profile (Section 8).** $(\alpha 3,\alpha 4,\alpha 5)=(4,6,5)$.

The technical heart is a single device, the **divisibility-equivalence
principle** (Lemma 3.2): two indices are equal iff they have the same multiples.
Combined with the Law of Apparition, it reduces every lattice identity about
$\alpha$ to an elementary identity about $\gcd$/$\operatorname{lcm}$ of indices.

---

## 2. Preliminaries and notation

We write $a \mid b$ for "a divides b", $\gcd$ and $\operatorname{lcm}$ for the
greatest common divisor and least common multiple on $\mathbb{Z}_{\ge 0}$, and
$\mathbb{N} = \{0,1,2,\dots\}$. For $d \ge 1$ we write $d\mathbb{N} =
\{0,d,2d,\dots\}$ for the set of non-negative multiples of $d$; equivalently
$d\mathbb{N} = \{k : d \mid k\}$, the principal ideal generated by $d$.

We use three standard facts about the divisibility lattice:

- $\operatorname{lcm}(a,b) \mid k \iff (a \mid k \text{ and } b \mid k)$
  (the universal property of the join);
- $d \mid \gcd(x,y) \iff (d \mid x \text{ and } d \mid y)$
  (the universal property of the meet);
- $\gcd(a,b) \mid a$ and $\gcd(a,b)\mid b$; $a \mid \operatorname{lcm}(a,b)$ and
  $b \mid \operatorname{lcm}(a,b)$.

**The Fibonacci sequence.** $F_0=0,\ F_1=1$, and $F_{n+2}=F_{n+1}+F_n$. We use
two classical facts as the arithmetic backbone, assumed established in the
underlying entry-point theory:

- **(A1) Totality.** For every $m \ge 1$ there exists $k>0$ with $m \mid F_k$;
  hence $\alpha(m)$ is well defined.
- **(A2) Apparition membership.** $m \mid F_{\alpha(m)}$ (the first appearance is
  a genuine appearance), and $\alpha(m) \le k$ for any $k>0$ with $m\mid F_k$.

---

## 3. The Law of Apparition and the equivalence principle

### 3.1 The Law of Apparition

The keystone of the entire theory is the following equivalence, which we treat
as established in the foundational layer (`fib_dvd_iff_fibEntry_dvd`).

> **Theorem 3.1 (Law of Apparition).** For every $m \ge 1$ and every $k \ge 0$,
> $$m \mid F_k \iff \alpha(m) \mid k.$$

*Sketch.* ($\Leftarrow$) If $\alpha(m) \mid k$ then $k = j\,\alpha(m)$, and the
divisibility property $F_a \mid F_{ja}$ of Fibonacci numbers together with
$m \mid F_{\alpha(m)}$ (A2) gives $m \mid F_{\alpha(m)} \mid F_k$.
($\Rightarrow$) Suppose $m \mid F_k$. Write $k = q\,\alpha(m) + r$ with
$0 \le r < \alpha(m)$. Using the identity
$F_k = F_{q\alpha(m)+r} = F_{q\alpha(m)+1}F_r + F_{q\alpha(m)}F_{r-1}$ and
$m \mid F_{q\alpha(m)}$ (from the easy direction), one gets $m \mid
F_{q\alpha(m)+1}F_r$; since $\gcd(F_n, F_{n+1}) = 1$ the factor
$F_{q\alpha(m)+1}$ is coprime to $m$, so $m \mid F_r$. Minimality of $\alpha(m)$
forces $r = 0$, i.e. $\alpha(m)\mid k$. $\square$

**Corollary 3.1 (Lines are ideals).** For every $m\ge1$,
$$L(m) := \{k \ge 0 : m \mid F_k\} = \alpha(m)\,\mathbb{N}.$$
Thus each $L(m)$ is an arithmetic progression based at $0$ with common
difference exactly $\alpha(m)$, and consecutive members differ by exactly
$\alpha(m)$ with no member strictly between them.

### 3.2 The divisibility-equivalence principle

The following two-line lemma is the workhorse: it converts statements about
*which indices* divide a quantity into equalities between quantities.

> **Lemma 3.2 (Equivalence principle).** If $d,e \ge 1$ satisfy
> $d \mid k \iff e \mid k$ for all $k$, then $d = e$.

*Proof.* Apply the hypothesis at $k=e$: from $e \mid e$ we get $d \mid e$.
Apply it at $k=d$: from $d\mid d$ we get $e \mid d$. Antisymmetry of
divisibility yields $d=e$. $\square$

In Lean this is `nat_eq_of_dvd_iff`, proved by
`Nat.dvd_antisymm ((h e).mpr dvd_rfl) ((h d).mp dvd_rfl)`.

The strategy for every lattice identity $\alpha(X) = Y$ below is uniform: show
$X \mid F_k \iff Y \mid k$ for all $k$ (using Theorem 3.1 to unfold $\alpha$),
then conclude $\alpha(X) = Y$ by combining Theorem 3.1 (with $m=X$) and Lemma
3.2.

---

## 4. The join law

> **Theorem 4.1 (Unrestricted join law).** For all $a,b \ge 1$,
> $$\alpha\big(\operatorname{lcm}(a,b)\big) = \operatorname{lcm}\big(\alpha(a),\,\alpha(b)\big).$$

*Proof.* Fix $k \ge 0$. Using the join universal property and then the Law of
Apparition twice,
$$
\operatorname{lcm}(a,b) \mid F_k
\iff (a \mid F_k)\wedge(b\mid F_k)
\iff (\alpha(a)\mid k)\wedge(\alpha(b)\mid k)
\iff \operatorname{lcm}(\alpha a,\alpha b)\mid k .
$$
Hence the indices $\alpha(\operatorname{lcm}(a,b))$ and
$\operatorname{lcm}(\alpha a, \alpha b)$ have the same set of multiples: by
Theorem 3.1 (with $m = \operatorname{lcm}(a,b)$) the left side equals
$\{k : \alpha(\operatorname{lcm}(a,b)) \mid k\}$, and the displayed chain shows
this equals $\{k:\operatorname{lcm}(\alpha a,\alpha b)\mid k\}$. Lemma 3.2 gives
equality. $\square$

The Lean proof `fibEntry_lcm` instead establishes the two divisibilities
directly (`Nat.dvd_antisymm`): for $\le$, one shows
$\operatorname{lcm}(\alpha a,\alpha b)$ divides $\alpha(\operatorname{lcm}(a,b))$
by checking each of $\alpha a,\alpha b$ divides it via the Law of Apparition and
$a,b \mid F_{\alpha(\operatorname{lcm}(a,b))}$; for $\ge$, one shows
$\alpha(\operatorname{lcm}(a,b)) \mid \operatorname{lcm}(\alpha a,\alpha b)$ by
verifying $\operatorname{lcm}(a,b) \mid F_{\operatorname{lcm}(\alpha a,\alpha
b)}$. Both routes are elementary once Theorem 3.1 is available.

**Remark 4.1 (Strict generalization).** When $\gcd(a,b)=1$ we have
$\operatorname{lcm}(a,b) = ab$, so Theorem 4.1 specializes to the classical
coprime multiplicativity $\alpha(ab) = \operatorname{lcm}(\alpha a,\alpha b)$
(the previously known `fibEntry_mul_coprime`). Theorem 4.1 removes the hypothesis
entirely; e.g. $\alpha(\operatorname{lcm}(4,6)) = \alpha(12) = 12 =
\operatorname{lcm}(6,12) = \operatorname{lcm}(\alpha 4,\alpha 6)$ even though
$\gcd(4,6)=2 \ne 1$.

---

## 5. Monotonicity

> **Theorem 5.1 (Monotonicity).** If $a \mid b$ and $b \ge 1$, then
> $\alpha(a) \mid \alpha(b)$.

*Proof.* If $a = 0$ the hypothesis $a \mid b$ forces $b=0$, excluded; so $a\ge1$.
By (A2), $b \mid F_{\alpha(b)}$, and $a \mid b$ gives $a \mid F_{\alpha(b)}$. By
the Law of Apparition (with $m=a$, $k=\alpha(b)$), $a \mid F_{\alpha(b)}$ is
equivalent to $\alpha(a) \mid \alpha(b)$. $\square$

This is `fibEntry_monotone`. Geometrically: refining the modulus (passing from
$a$ to a multiple $b$) refines the line — $L(b) \subseteq L(a)$ as sets, and the
step of the finer line is a multiple of the step of the coarser one.

---

## 6. The meet bound and its strictness

### 6.1 The bound

> **Theorem 6.1 (Meet bound).** For all $a,b \ge 1$,
> $$\alpha\big(\gcd(a,b)\big) \mid \gcd\big(\alpha(a),\,\alpha(b)\big).$$

*Proof.* Since $\gcd(a,b) \mid a$ and $\gcd(a,b)\mid b$, Theorem 5.1 gives
$\alpha(\gcd(a,b)) \mid \alpha(a)$ and $\alpha(\gcd(a,b)) \mid \alpha(b)$. By the
meet universal property, a common divisor of $\alpha(a)$ and $\alpha(b)$ divides
their gcd, so $\alpha(\gcd(a,b)) \mid \gcd(\alpha a,\alpha b)$. $\square$

This is `fibEntry_gcd_dvd`, proved by `Nat.dvd_gcd` applied to two invocations of
monotonicity.

### 6.2 The bound is strict

To compute concrete entry points we use a finitary characterization.

> **Lemma 6.1 (Entry-point certificate).** If $m\ge1$ divides $F_n$ at the
> positive index $n$ and $m \nmid F_k$ for all $0<k<n$, then $\alpha(m)=n$.

This is `fibEntry_eq`, immediate from the definition of $\alpha$ as a least
element (`Nat.find_eq_iff`). Using it we certify, from the small Fibonacci values
$F_3=2,F_4=3,F_5=5,F_6=8,F_{12}=144$:
$$\alpha(2)=3,\qquad \alpha(4)=6,\qquad \alpha(6)=12.$$

> **Theorem 6.2 (Strictness witness).** $\alpha(\gcd(4,6)) \neq
> \gcd(\alpha(4),\alpha(6))$. Indeed
> $$\alpha(\gcd(4,6)) = \alpha(2) = 3, \qquad \gcd(\alpha 4,\alpha 6)=\gcd(6,12)=6,$$
> and $3 \ne 6$.

*Proof.* Direct substitution of the three certified values, $\gcd(4,6)=2$ and
$\gcd(6,12)=6$. $\square$

This is `fibEntry_gcd_not_exact`.

### 6.3 Interpretation: $\alpha$ is a join- but not a meet-morphism

Theorems 4.1 and 6.2 together pin down the categorical behavior of $\alpha$ as a
map of lattices $(\mathbb{Z}_{\ge1},\mid) \to (\mathbb{Z}_{\ge1},\mid)$:

- $\alpha$ **preserves joins exactly** (Theorem 4.1): $\alpha(a \vee b) =
  \alpha(a) \vee \alpha(b)$.
- $\alpha$ **preserves order** (Theorem 5.1), hence sends meets *into* the meet
  by the universal bound (Theorem 6.1): $\alpha(a\wedge b) \le \alpha(a)\wedge
  \alpha(b)$ in the divisibility order.
- $\alpha$ **does not preserve meets** (Theorem 6.2): the bound is sometimes
  strict.

A monotone map that preserves all joins but not all meets is exactly a *left
adjoint*-type phenomenon: it commutes with the "upward" lattice operation while
only sub-commuting with the "downward" one. This asymmetry is the structural
core of the geometry developed next.

---

## 7. The geometry: parallels that diverge and converge

### 7.1 Lines, parallelism, divergence

By Corollary 3.1 every modulus $m$ defines a line $L(m) = \alpha(m)\mathbb{N}$ on
the index axis, an arithmetic progression of step $\alpha(m)$. Call $L(a)$ and
$L(b)$ **parallel** when $\alpha(a) \neq \alpha(b)$ (their local spacings
disagree). Enumerate the $n$-th ticks $a_n = n\,\alpha(a)$ and
$b_n = n\,\alpha(b)$; their separation is
$$|a_n - b_n| = n\,|\alpha(a) - \alpha(b)| \xrightarrow[n\to\infty]{} \infty.$$

> **Proposition 7.1 (Local divergence — Euclidean/hyperbolic face).** Two
> parallel lines $L(a),L(b)$ have constant, unequal tick spacings $\alpha(a)\neq
> \alpha(b)$, so corresponding ticks separate linearly without bound.

This is the structural content of the even-spacing statement
(`apparition_step` in the geometric layer): consecutive members of $L(m)$ are
spaced *exactly* $\alpha(m)$, nothing between. Distinct spacings $\Rightarrow$
drift. Example: $L(3)=\{0,4,8,12,\dots\}$ and $L(5)=\{0,5,10,15,\dots\}$ have
separations $0,1,2,3,\dots$.

### 7.2 Global convergence

> **Theorem 7.2 (Reconvergence — elliptic face).** For all $a,b\ge1$,
> $$L(a) \cap L(b) = L\big(\operatorname{lcm}(a,b)\big) =
> \operatorname{lcm}(\alpha a,\alpha b)\,\mathbb{N},$$
> a non-trivial arithmetic progression. Hence any two parallel lines re-intersect
> infinitely often, on an evenly spaced ladder of step
> $\operatorname{lcm}(\alpha a,\alpha b)$.

*Proof.* For any $k$, $k \in L(a)\cap L(b)$ iff $a\mid F_k$ and $b\mid F_k$ iff
$\operatorname{lcm}(a,b)\mid F_k$ (join universal property) iff $k \in
L(\operatorname{lcm}(a,b))$. By Corollary 3.1 this set is
$\alpha(\operatorname{lcm}(a,b))\mathbb{N}$, and by the Join Law (Theorem 4.1)
$\alpha(\operatorname{lcm}(a,b)) = \operatorname{lcm}(\alpha a,\alpha b)$. The
progression is non-trivial because $\operatorname{lcm}(\alpha a,\alpha b)\ge 1$.
$\square$

So $L(3)\cap L(5) = L(15) = \{0,20,40,\dots\}$ with step
$\operatorname{lcm}(4,5)=20$: the very lines that diverge in §7.1 cross
forever. Divergence and convergence coexist because the first is a *local
spacing* property and the second a *global coincidence* property; nothing in the
discrete setting couples them into a contradiction.

### 7.3 The asymmetry as the geometric signature

The Join Law makes *convergence exact*: the reconvergence step is computed, not
estimated, as $\operatorname{lcm}(\alpha a,\alpha b)$. By contrast the meet bound
(Theorem 6.1) is only an inequality and is sometimes strict (Theorem 6.2): the
"downward" combination of moduli is *not* faithfully tracked by $\alpha$.
Geometrically, the way fine lines refine coarse ones is lossy in a way that the
way lines intersect is not. The geometry is intrinsically lopsided, and the
lopsidedness is precisely the failure of the meet-morphism property.

---

## 8. The Pythagorean apparition profile

Applying the entry-point certificate (Lemma 6.1) to the legs and hypotenuse of
the primitive triple $(3,4,5)$, from $F_4=3$, $F_5=5$, $F_6=8$:
$$\alpha(3)=4,\qquad \alpha(4)=6,\qquad \alpha(5)=5,$$
giving the **apparition profile** $(\alpha 3,\alpha 4,\alpha 5)=(4,6,5)$. This is
a concrete fingerprint of the lattice on the most elementary Pythagorean object,
and it interacts with the structural laws: e.g. $L(3)\cap L(4) = L(12)$ with step
$\operatorname{lcm}(4,6)=12$, and $L(3)\cap L(5)=L(15)$ with step
$\operatorname{lcm}(4,5)=20$ (both confirmed numerically).

---

## 9. Algorithms

### 9.1 Computing $\alpha(m)$

```
function ALPHA(m):            # m >= 1
    assert m >= 1
    a, b <- 0, 1              # F_0, F_1
    k <- 0
    repeat:
        if a mod m == 0 and k > 0: return k
        a, b <- b, a + b
        k <- k + 1
```
Termination is guaranteed by totality (A1); the number of iterations is
$\alpha(m) \le m^2$ (Fibonacci is periodic mod $m$ with period $\le 6m$, the
Pisano period, and $\alpha(m)$ divides it). Working with residues mod $m$ keeps
the integers bounded, giving $O(\pi(m))$ arithmetic operations where $\pi(m)$ is
the Pisano period.

### 9.2 Predicting reconvergence (the Join Law as an algorithm)

To find where lines $L(a),L(b)$ meet, **do not** search Fibonacci numbers:
compute $\operatorname{lcm}(\alpha(a),\alpha(b))$ directly (Theorem 7.2). This
replaces an $O(\,\cdot\,)$ search over indices with two entry-point computations
and one $\gcd$.

---

## 10. Applications

- **Fast simultaneous-divisibility queries.** "What is the first index where
  $F_k$ is divisible by all of $m_1,\dots,m_r$?" is, by iterated Theorem 4.1,
  $\operatorname{lcm}(\alpha m_1,\dots,\alpha m_r)$ — no Fibonacci search.
- **Periodicity and pseudoprimality testing.** Entry points underlie Lucas-style
  primality tests; the lattice laws give clean composition rules for
  $\alpha$ across factorizations.
- **A teaching bridge.** The construction is a vivid, fully elementary example
  of an arithmetic phenomenon rendered as geometry, suitable for illustrating
  lattice morphisms, principal ideals, and the non-Euclidean parallel postulate
  in one stroke.
- **A reusable proof pattern.** The equivalence principle (Lemma 3.2) plus a
  "membership characterization" (Theorem 3.1) is a transferable template for
  proving lattice identities about any *entry-point*-style invariant of a linear
  recurrence (Lucas sequences, more general divisibility sequences).

---

## 11. Discussion and limitations

The results are sharp on the join side (exact law, no hypotheses) and
deliberately one-sided on the meet side (a bound with an explicit
counterexample to equality). The geometry is *discrete*: "lines" are
progressions on $\mathbb{N}$ rather than curves, and "parallelism" is defined
through spacing rather than a metric. This is a feature — it is exactly what
allows local divergence and global convergence to coexist without contradiction
— but it means the analogy to Riemannian non-Euclidean geometry is structural,
not metric. A genuine metric realization (e.g. embedding $L(m)$ into a curved
space where the reconvergence is geodesic) is left open.

---

## 12. Future directions

*(Reproduced from the Phase A research notes.)*

**Synthesis.** This cycle reframed the divisibility structure of Fibonacci
numbers as a discrete geometry and proved that this geometry simultaneously
exhibits the Euclidean and the elliptic faces of the parallel postulate. The
organizing object is the entry point (rank of apparition) $\alpha(m)$: the least
$k>0$ with $m \mid F(k)$. The Entry-Point Characterization Theorem shows each
divisibility line $L(m) = \{k : m \mid F(k)\}$ is exactly the principal ideal
$\alpha(m)\cdot\mathbb{N}$. Reading these ideals geometrically: *Divergence
(Euclidean face)* — consecutive members of a line are spaced exactly $\alpha(m)$
with no member between, evenly spaced parallel hyperplanes that drift apart
linearly as $\alpha(m)$ grows; *Convergence (elliptic/"impossible" face)* — for
coprime moduli the two lines are forced to re-intersect, and their meeting set is
again a line generated by $\operatorname{lcm}(\alpha a,\alpha b)$. The bridge
between the two faces is the lcm law $\alpha(a\cdot b)=\operatorname{lcm}(\alpha
a,\alpha b)$ for coprime $a,b$, generalized here to the unrestricted join law.
Together with the $(3,4,5)$ instantiation (apparition profile $(4,6,5)$) this
packages the apparition lattice into a usable arithmetic-geometry dictionary.

**Direction 1 — The full apparition reconstruction functor $\alpha$ from prime
powers.** *Conjecture.* For every $m \ge 1$,
$\alpha(m)=\operatorname{lcm}$ over prime powers $p^e \,\|\, m$ of $\alpha(p^e)$,
and $\alpha(p^e)=p^{\max(e-e_0,0)}\cdot\alpha(p)$, where $e_0$ is the $p$-adic
valuation of $F_{\alpha(p)}$ (the "wall" exponent). Equivalently, $\alpha$ is a
fully-multiplicative-on-lcm functor from the divisor lattice of $m$ to the index
lattice of $\mathbb{N}$. The key insight is that the join law already proves the
coprime-gluing half; what remains is the single-prime lifting law, governed by
the $p$-adic valuation $v_p(F_k)$ and the lifting-the-exponent lemma for Lucas
sequences. Once both halves are in place, $\alpha$ is completely reconstructible
from its values on primes.

**Further directions.** (i) Characterize the *Fibonacci–Wieferich* primes where
the wall exponent $e_0 > 1$ and analyze their effect on the lattice geometry.
(ii) Extend the divergence/convergence dictionary to general Lucas sequences
$U_n(P,Q)$ and identify which recurrences retain the join-morphism / not-a-
meet-morphism asymmetry. (iii) Seek a metric model in which the discrete
reconvergence becomes literal geodesic convergence, making the "impossible
geometry" a bona fide curved space.

---

## 13. Conclusion

The rank of apparition turns the divisibility structure of the Fibonacci numbers
into a discrete geometry of evenly spaced lines. Two such lines locally diverge,
with distinct constant spacings, and globally reconverge on the line
$L(\operatorname{lcm}(a,b))$ whose step is exactly
$\operatorname{lcm}(\alpha a,\alpha b)$ — the Euclidean and elliptic faces of the
parallel postulate, realized simultaneously and provably. The exactness of the
convergence (the unrestricted join law) and the strictness of the meet bound
together identify $\alpha$ as a join-morphism that is not a meet-morphism, the
arithmetic signature of this impossible geometry. The smallest Pythagorean
triple leaves the profile $(4,6,5)$ as its fingerprint, and a clean program for
the full prime-power reconstruction of $\alpha$ lies ahead.
