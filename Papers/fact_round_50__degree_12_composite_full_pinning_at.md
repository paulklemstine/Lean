# Reading a Galois Group Out of Prime Remainders

### A guided tour of the degree-12 rung: conductor 56, the group $C_6 \times C_2$, and the number $1.7296$

---

## 0. The one-sentence version

Take the primes, look only at their remainders modulo $56$, ask each one a single
yes/no-flavoured question, count the answers, and compute one Shannon entropy. The
number you get — $1.7296$ bits — is small enough to rule out one of the only two
possible symmetry groups, and therefore *identifies* the symmetry group of a
degree-$12$ number field. This page builds that sentence up from nothing.

---

## 1. The question you can ask a prime

Fix the modulus $56$. For a prime $p$ other than $2$ and $7$ (the two primes dividing
$56$), define its **type**:

$$T(p) \;=\; \min\{\,k \ge 1 \;:\; p^{k} \equiv \pm 1 \pmod{56}\,\}.$$

Try it by hand before reading on. $13^2 = 169 = 3\cdot 56 + 1$, so $T(13) = 2$.
$11^2 \equiv 9$, $11^3 \equiv -13$, $11^6 \equiv 1$, so $T(11) = 6$. And $T(55) = 1$
because $55 \equiv -1$.

That is the entire input. Everything else on this page is consequences.

{{algorithm:0}}

<details>
<summary>Why the "$\pm$" in the definition? (click to expand)</summary>

Because we are working inside the **real** part of a cyclotomic field. The field
$\mathbb{Q}(\zeta_{56})$, where $\zeta_{56} = e^{2\pi i/56}$, has an automorphism
sending $\zeta \mapsto \zeta^{-1}$ — complex conjugation. Its fixed field is
$$\mathbb{Q}(\zeta_{56})^{+} = \mathbb{Q}\!\left(\zeta_{56}+\zeta_{56}^{-1}\right)
= \mathbb{Q}\!\left(2\cos\tfrac{2\pi}{56}\right),$$
a subfield of the real numbers. Passing to that subfield means identifying $a$ with
$-a$ among the residues, and the type is exactly the order of $p$ *after that
identification*. Reading about
[cyclotomic fields](https://en.wikipedia.org/wiki/Cyclotomic_field) and
[Galois theory](https://en.wikipedia.org/wiki/Galois_theory) will fill in the
background, but nothing below depends on it: everything can be checked by
multiplying remainders.

</details>

---

## 2. The laboratory

Before any theory, play. The widget below builds the reduced residues modulo any
conductor you choose, colours them by type, tabulates the densities, computes the
entropy of the residue $\to$ type channel, draws the Frobenius orbits, verifies the
semiprime counting law, and finally places the measured entropy on an axis next to
the entropies of *all* abelian groups of the right order.

Start at the default $f = 56$. Then try $f = 35$ (a cyclic rung of the same degree)
and watch the entropy jump above $2$.

{{interactive_demo:0}}

Three things to notice while you play:

1. **$a$ and $-a$ always get the same colour.** That is what lets the type descend to
   the quotient by $\pm 1$ — the symmetry group of the real field.
2. **The pinning gap is always exactly zero.** Every conductor, every time.
3. **The orbit lengths in section 4 of the widget are never ragged.** Every orbit of a
   given Frobenius class has the same length.

Each of these has a proof, and each proof is short. They are the next three sections.

---

## 3. What the group actually is

$56 = 8 \cdot 7$, so by the Chinese Remainder Theorem
$$(\mathbb{Z}/56)^\times \;\cong\; (\mathbb{Z}/8)^\times \times (\mathbb{Z}/7)^\times
\;\cong\; (C_2 \times C_2) \times C_6 ,$$
a group of order $\varphi(56) = 24$. Concretely, every reduced residue mod $56$ is
uniquely
$$a \;=\; 3^{\,i}\, 13^{\,j}\, (-1)^{k}, \qquad 0\le i<6,\ 0\le j<2,\ 0\le k<2,$$
because $3$ has order $6$, $13$ has order $2$, and $-1$ has order $2$, and the three
are independent. Killing the last coordinate — which is precisely what the real
subfield does — gives

$$G^{+} \;=\; (\mathbb{Z}/56)^\times/\{\pm 1\} \;\cong\; C_6 \times C_2, \qquad |G^{+}| = 12 .$$

> **Theorem (Degree twelve, and non-cyclicity).** The field
> $\mathbb{Q}(\zeta_{56})^{+}$ has degree exactly $12$ over $\mathbb{Q}$, and its
> Galois group is $C_6 \times C_2$: abelian of order $12$, but **not cyclic**, since
> every element $g$ satisfies $6g = 0$ and so has order at most $6 < 12$.

Order $12$ is the first composite order at which the cyclic answer is not forced —
there are exactly two abelian groups of that order,
$C_{12}$ and $C_6\times C_2$ (see the
[classification of finite abelian groups](https://en.wikipedia.org/wiki/Finitely_generated_abelian_group#Classification)).
So this is the first rung of the ladder where there is anything to *detect*.

<details>
<summary>Why conductor 56 and not one of the other nine candidates?</summary>

Exactly ten conductors satisfy $\varphi(f) = 24$, namely
$35, 39, 45, 52, 56, 70, 72, 78, 84, 90$. Three of them ($70, 78, 90$) give the same
fields as $35, 39, 45$. Of the seven distinct fields, four have cyclic Galois group
and three ($56, 72, 84$) have $C_6\times C_2$. The rule "smallest conductor of degree
$12$ with non-cyclic group" picks $56$. The algorithm below reproduces the whole
table from scratch.

{{algorithm:4}}

</details>

---

## 4. Types are orders, and the census is a Chebotarev fingerprint

Here is the bridge between the elementary computation and the algebra.

> **Theorem (Type $=$ Frobenius order).** Under the identification
> $G^{+}\cong C_6\times C_2$ sending $3^{i}13^{j}$ to $(i,j)$, the type of a residue
> is exactly the order of the corresponding group element.

*Sketch.* If $m = T(3^i 13^j)$ then $3^{im}13^{jm} = \pm 1$, and since the only sign
ambiguity lives in the discarded third coordinate, $m\cdot(i,j) = 0$; minimality of
$m$ transfers to minimality in the group. $\square$

Counting is now pure bookkeeping. Among the $24$ residues, the types $1,2,3,6$ occur
$2,6,4,12$ times, i.e. with densities

$$\frac1{12},\qquad \frac14,\qquad \frac16,\qquad \frac12,$$

and these are exactly twice the numbers $1,3,2,6$ of elements of $C_6\times C_2$ of
each order. That is the **Chebotarev match**: the arithmetic census reproduces the
group's order statistics.

{{algorithm:1}}

Because the type depends only on $p \bmod 56$, the
[Chebotarev density theorem](https://en.wikipedia.org/wiki/Chebotarev%27s_density_theorem)
(here just [Dirichlet's theorem](https://en.wikipedia.org/wiki/Dirichlet%27s_theorem_on_arithmetic_progressions))
promotes those residue densities into densities among the actual primes. Here is the
convergence, computed over the primes below $300\,000$:

{{visualization:0}}

The left panel is the four densities settling onto $1/12, 1/4, 1/6, 1/2$. The right
panel is the entropy story of the next section, previewed: the empirical entropy and
the empirical mutual information are *the same curve*, and they converge to a value
comfortably below $2$.

---

## 5. Full pinning: why the gap is zero, always

Model the map
$$X = (p \bmod 56) \;\longmapsto\; T = \text{type of } p$$
as a communication channel and ask how much of $X$ the output reveals. The measure is
[mutual information](https://en.wikipedia.org/wiki/Mutual_information)
$I(X;T) = H(X) + H(T) - H(X,T)$.

> **Theorem (Full pinning).** For *any* finite set $S$, *any* function $\varphi$ on it,
> and $X$ uniform on $S$:
> $$H\big(X,\varphi(X)\big) = H(X) \qquad\text{and hence}\qquad
> I\big(X;\varphi(X)\big) = H\big(\varphi(X)\big).$$
> The pinning gap $H(T) - I(X;T)$ is identically zero.

<details>
<summary>The proof, in three lines</summary>

The joint distribution of $(X, \varphi(X))$ is supported on the graph of $\varphi$,
and each of the $|S|$ graph points carries probability $1/|S|$. So the joint entropy
is $\sum_{a\in S} \frac1{|S|}\log_2|S| = \log_2|S| = H(X)$. Substituting into
$I = H(X)+H(T)-H(X,T)$ leaves $I = H(T)$. $\square$

The moral: *full pinning is exactly determinism*. What is arithmetically substantial
is not the identity but its hypothesis — that the splitting type of a prime is a
function of its remainder at all. That is a theorem of class field theory, and it is
the only place where number theory enters.

</details>

The exact value follows from the census:

$$H(T) \;=\; \tfrac1{12}\log_2 12 + \tfrac14\log_2 4 + \tfrac16\log_2 6 + \tfrac12\log_2 2
\;=\; \boxed{\ \frac43 + \frac{\log_2 3}{4}\ } \;=\; 1.7295739\ldots$$

and the residue itself carries $H(X) = \log_2 24 = 3+\log_2 3 \approx 4.585$ bits, so
$$H(X\mid T) \;=\; \frac53 + \frac34\log_2 3 \;\approx\; 2.855 \;>\; 0 .$$
The channel is perfectly faithful about what it reports and deeply lossy about
everything else: a clean coarsening, retaining about $37.7\%$ of the residue's
information.

The demo below performs all of this in **exact arithmetic** — no floating point
anywhere — including a rigorous bracket for $\log_2 3$ obtained from integer
comparisons.

{{demo:1}}

<details>
<summary>How do you bracket $\log_2 3$ rigorously without analysis?</summary>

Compare integers. $2^{84} < 3^{53}$ gives $84/53 < \log_2 3$, and
$3^{147} < 2^{233}$ gives $\log_2 3 < 233/147$. Both are exact comparisons of large
integers, and the two fractions are
[continued-fraction convergents](https://en.wikipedia.org/wiki/Continued_fraction)
of $\log_2 3 = 1.5849625\ldots$, so the bracket is tight to about $10^{-4}$:
$$1.58490 < \log_2 3 < 1.58504 \quad\Longrightarrow\quad 1.7295 < H(T) < 1.7296 .$$

</details>

---

## 6. The payoff: one number, one group

Every finite group $A$ has an **order profile**: the distribution of $\operatorname{ord}(x)$
for a uniformly random $x\in A$. Its entropy $H(A)$ is a single real number. Compute it
for the only two candidates at order $12$:

| group | order profile | entropy |
|---|---|---|
| $C_{12}$ | orders $1,2,3,4,6,12$ with multiplicities $1,1,2,2,2,4$ | $\dfrac56 + \log_2 3 = 2.41830\ldots$ |
| $C_6\times C_2$ | orders $1,2,3,6$ with multiplicities $1,3,2,6$ | $\dfrac43 + \dfrac{\log_2 3}{4} = 1.72957\ldots$ |

> **Theorem (Entropy separation at order twelve).**
> $$H(C_{12}) \;>\; 2 \;>\; H(C_6\times C_2).$$
> Consequently a measured order-profile entropy below $2$ bits certifies that an
> abelian group of order $12$ is **not** cyclic.

We measured $1.7296$. That is below $2$. The group is $C_6\times C_2$ — deduced from
prime remainders, with no field arithmetic anywhere in the pipeline.

{{visualization:1}}

Panel C of that figure is a small surprise worth pausing on: computed for every
abelian group of every order up to $24$, no two groups of the same order share the
invariant. Whether that persists is the central open question below.

{{algorithm:3}}

<details>
<summary>Why should the invariant be complete in general? (a conjecture, with its mechanism)</summary>

**Conjecture.** For abelian groups $A, B$ of the same order $n \le 100$, the
order-profile entropies agree if and only if $A\cong B$.

The mechanism: the order profile of an abelian group is a combinatorial object built
from divisor counts, so its entropy is always a $\mathbb{Q}$-linear combination of
$\log_2 p$ over the primes $p\mid n$. The logarithms $\{\log_2 p\}$ are linearly
independent over $\mathbb{Q}$ — for rational combinations this is just unique
factorisation. So an *analytic* coincidence between two entropies forces a
*combinatorial* coincidence between the profiles, which in the abelian world is very
close to forcing an isomorphism. Making "very close to" precise is the content of the
conjecture.

</details>

---

## 7. Two structural laws that make it all work

### 7.1 Orbit purity and $e\cdot f\cdot g = 12$

A prime acts on the $12$ symmetry slots by translation by its own class. Translation
orbits in a group are never ragged:

> **Theorem (Orbit purity).** In a finite abelian group $A$, translation by $g$ splits
> $A$ into orbits *all* of length $\operatorname{ord}(g)$; hence
> $(\#\text{orbits})\cdot\operatorname{ord}(g) = |A|$.

At conductor $56$ this is the classical decomposition law $e\cdot f\cdot g = 12$ with
$e = 1$ (no ramification away from $2$ and $7$), and only four shapes are possible:
$$(f,g) \in \{(1,12),\ (2,6),\ (3,4),\ (6,2)\}.$$

{{algorithm:2}}

### 7.2 Semiprimes carry the same bits

> **Theorem (Pair law).** If $S$ is a finite set closed under multiplication by each of
> its elements, then for every $t$,
> $$\#\{(u,v)\in S\times S : T(uv) = t\} \;=\; |S|\cdot\#\{w\in S : T(w) = t\}.$$

At conductor $56$ the pair counts are $48, 144, 96, 288$ out of $576$ — the same
densities $\tfrac1{12},\tfrac14,\tfrac16,\tfrac12$. Observing a product of two primes
instead of a prime costs **nothing**: the semiprime channel transmits the identical
$1.72957\ldots$ bits. The reason is one sentence: for fixed $u$, the map $v\mapsto uv$
permutes $S$, so the inner count cannot depend on $u$.

---

## 8. Everything at once

The full demonstration below runs all eight strands end to end: the unit group and its
basis $\{3,13,-1\}$; the type census and its Chebotarev match; the exact entropy and
the vanishing pinning gap; the same statistics on the $17\,982$ primes below
$200\,000$ together with a label-shuffling significance test; the orbit shapes; the
semiprime enumeration; the entropy separation; and finally the conductor-selection
table that singles out $56$ from its nine competitors.

{{demo:0}}

---

## 9. Where to go next

- **Climb the ladder.** The orbit-purity and pair laws were proved for arbitrary finite
  abelian groups, and full pinning for arbitrary finite channels, so the machinery
  transfers unchanged to any conductor. Only the arithmetic census must be recomputed.
- **Prove the injectivity conjecture.** If the order-profile entropy is a complete
  invariant for abelian groups, then a single measured real number determines the
  Galois group of every abelian rung — not just this one.
- **Go non-abelian.** Replace "order of the Frobenius element" by "conjugacy class of
  the Frobenius", and ask whether the corresponding class-profile entropy still
  separates.
- **Make it effective.** How many primes are needed before the empirical entropy is
  provably within $\varepsilon$ of the exact value? Effective versions of Chebotarev's
  theorem would turn the certificate into a finite, checkable computation.

---

### One last look

$$\underbrace{\frac43 + \frac{\log_2 3}{4}}_{\text{a closed form}}
\;=\; \underbrace{1.7296\ \text{bits}}_{\text{a measurement}}
\;<\; \underbrace{2}_{\text{a threshold}}
\;<\; \underbrace{\frac56 + \log_2 3}_{\text{the cyclic alternative}} .$$

Remainders of primes, counted correctly, know the shape of a symmetry group.
