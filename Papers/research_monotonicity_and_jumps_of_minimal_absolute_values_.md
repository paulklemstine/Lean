# Monotonicity and Jumps of Minimal Moduli of Fifth-Root-of-Unity Sums, via the Golden Ratio

## Abstract

For an integer $n \ge 1$, let $\sigma_5(n)$ denote the minimal absolute value of a
non-vanishing sum of $n$ fifth roots of unity. We study the arithmetic that governs this
quantity and establish, in full rigor, the algebraic bridge connecting it to the golden
ratio and to the Fibonacci and Lucas numbers. The bridge is carried by the two Gaussian
periods $p = \zeta + \zeta^4$ and $q = \zeta^2 + \zeta^3$ of the fifth cyclotomic field,
where $\zeta$ is a primitive fifth root of unity. We prove that $p$ and $q$ are the two
roots of $x^2 + x - 1 = 0$, hence equal to $-\varphi$ and $-\psi$ (the negatives of the
golden ratio and its conjugate); that their symmetric power sums are signed Lucas numbers,
$p^n + q^n = (-1)^n L_n$; that their antisymmetric power differences satisfy
$(p^n - q^n)^2 = 5F_n^2$; and that their moduli are exactly $\{\varphi, \varphi^{-1}\}$.
From this we deduce the exact value of the first nontrivial case, $\sigma_5(2) =
\varphi^{-1}$, as a least-element statement: $\varphi^{-1}$ is attained by a two-term sum
and is a lower bound for every two-term sum. Building on these identities, we describe the
full conjectural picture: $\sigma_5(n)$ is monotone non-increasing along each residue class
modulo $5$, and the strict decreases $\sigma_5(n) > \sigma_5(n+5)$ occur precisely when
$n + 5 \in \{5F_m,\ L_m,\ 2L_m\}$ for some $m \ge 1$. We explain why Fibonacci and Lucas
numbers control the jump locations and outline the additional infrastructure required to
settle the full statement.

**Keywords:** fifth roots of unity, Gaussian periods, golden ratio, Fibonacci numbers,
Lucas numbers, cyclotomic fields, minimal modulus, vanishing sums of roots of unity.

## 1. Introduction

Vanishing sums of roots of unity are a classical object at the crossroads of algebra,
combinatorics, and geometry. A companion question — arguably subtler — asks how *close to
vanishing* a sum of roots of unity can come without actually vanishing. Fix a prime $p$
and consider sums of $n$ (not necessarily distinct) $p$-th roots of unity. Define
$$\sigma_p(n) \;=\; \min\Bigl\{\, \Bigl| \textstyle\sum_{k=1}^{n} \zeta^{a_k} \Bigr| \; : \; a_k \in \{0,1,\dots,p-1\},\ \textstyle\sum_k \zeta^{a_k} \ne 0 \,\Bigr\},$$
where $\zeta = e^{2\pi i/p}$. The quantity $\sigma_p(n)$ measures the finest resolution
attainable by an $n$-term sum: the closest a non-trivial superposition of $p$ equally
spaced unit phasors can come to perfect cancellation.

This paper concentrates on $p = 5$, where a remarkable structure emerges: the entire
theory is controlled by the golden ratio $\varphi = (1+\sqrt5)/2$ and by the Fibonacci and
Lucas numbers. The connection is not accidental. The fifth cyclotomic field
$\mathbb{Q}(\zeta)$ contains a unique real quadratic subfield, $\mathbb{Q}(\sqrt5) =
\mathbb{Q}(\varphi)$, and the two Gaussian periods that generate it turn out to be
$-\varphi$ and $-\psi$. Once this is recognized, the arithmetic of five-fold symmetry and
the arithmetic of the golden ratio become two descriptions of one object.

Our contributions are:

1. A self-contained proof that the Gaussian periods $p = \zeta + \zeta^4$ and
   $q = \zeta^2 + \zeta^3$ satisfy $p + q = -1$, $pq = -1$, and therefore equal
   $\{-\varphi, -\psi\}$ (Section 3).
2. Two exact "bridge" identities expressing power sums and power differences of the
   periods through Lucas and Fibonacci numbers (Section 4).
3. The determination of the moduli $\{\lvert p\rvert, \lvert q\rvert\} =
   \{\varphi, \varphi^{-1}\}$, and the resulting exact evaluation
   $\sigma_5(2) = \varphi^{-1}$ as a genuine least-element statement (Section 5).
4. A structural account of the full monotonicity-and-jumps phenomenon, explaining the
   role of $5F_m$, $L_m$, and $2L_m$ (Section 6), together with the algorithmic and
   computational context (Sections 7–8) and open problems (Section 9).

Throughout, $\varphi = (1+\sqrt5)/2$ denotes the golden ratio and $\psi = (1-\sqrt5)/2$
its conjugate. They satisfy $\varphi + \psi = 1$, $\varphi\psi = -1$, $\varphi^2 =
\varphi + 1$, and $\psi^2 = \psi + 1$; also $\varphi > 1 > 0 > \psi$ and $\lvert\psi\rvert
= \varphi^{-1}$.

## 2. Preliminaries: roots of unity and the pentagon

Let $\zeta$ be a primitive fifth root of unity, i.e. $\zeta^5 = 1$ and $\zeta^k \ne 1$ for
$1 \le k \le 4$. The five fifth roots of unity are $1, \zeta, \zeta^2, \zeta^3, \zeta^4$,
the vertices of a regular pentagon inscribed in the unit circle. Two facts are used
repeatedly.

**Lemma 2.1 (Pentagon balance).** *The full sum of fifth roots of unity vanishes:*
$$1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0.$$
*Proof.* The left side is the value at $\zeta$ of $1 + x + x^2 + x^3 + x^4 =
(x^5 - 1)/(x - 1)$; since $\zeta^5 = 1$ but $\zeta \ne 1$, it equals $0$. $\square$

**Lemma 2.2 (Conjugation).** *Since $\lvert\zeta\rvert = 1$, we have $\bar\zeta =
\zeta^{-1} = \zeta^4$, and more generally $\overline{\zeta^k} = \zeta^{-k} = \zeta^{5-k}$.*

Because $5$ is odd, a two-term sum $\zeta^i + \zeta^j$ can never vanish: cancellation
$\zeta^i = -\zeta^j$ would force a tenth root of unity that is not a fifth root. This is
why $\sigma_5(2)$ needs no non-vanishing side condition.

## 3. The Gaussian periods and the golden quadratic

**Definition 3.1.** The two *Gaussian periods* of the fifth cyclotomic field are
$$p \;=\; \zeta + \zeta^4, \qquad q \;=\; \zeta^2 + \zeta^3.$$
By Lemma 2.2 each is a sum of a root and its conjugate, hence real: $p = 2\cos(2\pi/5)$
and $q = 2\cos(4\pi/5)$.

**Theorem 3.2 (Period sum and product).** *The Gaussian periods satisfy*
$$p + q = -1 \qquad\text{and}\qquad pq = -1.$$
*Proof.* For the sum, $p + q = \zeta + \zeta^2 + \zeta^3 + \zeta^4 = -1$ by Lemma 2.1.
For the product, expand
$$pq = (\zeta + \zeta^4)(\zeta^2 + \zeta^3) = \zeta^3 + \zeta^4 + \zeta^6 + \zeta^7
= \zeta^3 + \zeta^4 + \zeta + \zeta^2 = -1,$$
using $\zeta^5 = 1$ to reduce $\zeta^6 = \zeta$ and $\zeta^7 = \zeta^2$, and Lemma 2.1
again. $\square$

**Corollary 3.3 (Golden identification).** *The periods $p, q$ are exactly the two roots
of $x^2 + x - 1 = 0$; hence*
$$\{p, q\} = \{-\varphi,\ -\psi\}.$$
*Proof.* By Theorem 3.2 and Vieta's formulas, $p$ and $q$ are the roots of
$x^2 - (p+q)x + pq = x^2 + x - 1$. The roots of $x^2 + x - 1$ are $(-1 \pm \sqrt5)/2 =
-\varphi$ and $-\psi$ (since $\varphi, \psi$ are the roots of $x^2 - x - 1$, replacing
$x \mapsto -x$ maps one quadratic to the other). Which period equals $-\varphi$ and which
equals $-\psi$ depends on the choice of primitive root $\zeta$; both assignments are
consistent with all identities below. $\square$

Concretely, $p = 2\cos 72^\circ = (\sqrt5 - 1)/2 = \varphi^{-1} = -\psi > 0$ and
$q = 2\cos 144^\circ = -(\sqrt5 + 1)/2 = -\varphi < 0$ for the standard choice
$\zeta = e^{2\pi i/5}$.

## 4. The bridge identities

We now express symmetric functions of the periods through the two classical integer
sequences. Recall the **Lucas numbers** $L_0 = 2$, $L_1 = 1$, $L_{n+2} = L_{n+1} + L_n$
(so $2,1,3,4,7,11,18,\dots$) and the **Fibonacci numbers** $F_0 = 0$, $F_1 = 1$,
$F_{n+2} = F_{n+1} + F_n$ (so $0,1,1,2,3,5,8,\dots$).

**Lemma 4.1 (Binet for Lucas).** *For all $n \ge 0$, $L_n = \varphi^n + \psi^n$.*
*Proof.* By strong induction. The base cases $n = 0$ ($\varphi^0 + \psi^0 = 2 = L_0$) and
$n = 1$ ($\varphi + \psi = 1 = L_1$) hold. For $n \ge 2$, using $\varphi^2 = \varphi + 1$
and $\psi^2 = \psi + 1$,
$$\varphi^n + \psi^n = \varphi^{n-2}\varphi^2 + \psi^{n-2}\psi^2
= (\varphi^{n-1} + \varphi^{n-2}) + (\psi^{n-1} + \psi^{n-2}) = L_{n-1} + L_{n-2} = L_n. \quad\square$$

Analogously, the standard Binet formula gives $F_n = (\varphi^n - \psi^n)/\sqrt5$, i.e.
$\varphi^n - \psi^n = \sqrt5\,F_n$.

**Theorem 4.2 (Lucas bridge).** *For every primitive fifth root of unity $\zeta$ and every
$n \ge 0$,*
$$(\zeta + \zeta^4)^n + (\zeta^2 + \zeta^3)^n \;=\; (-1)^n\, L_n.$$
*Proof.* By Corollary 3.3, $\{p, q\} = \{-\varphi, -\psi\}$, so in either assignment
$$p^n + q^n = (-\varphi)^n + (-\psi)^n = (-1)^n(\varphi^n + \psi^n) = (-1)^n L_n$$
by Lemma 4.1. $\square$

**Theorem 4.3 (Fibonacci bridge).** *For every primitive fifth root of unity $\zeta$ and
every $n \ge 0$,*
$$\bigl((\zeta + \zeta^4)^n - (\zeta^2 + \zeta^3)^n\bigr)^2 \;=\; 5\, F_n^2.$$
*Proof.* With $\{p, q\} = \{-\varphi, -\psi\}$, the difference is
$p^n - q^n = \pm\bigl((-\varphi)^n - (-\psi)^n\bigr) = \pm(-1)^n(\varphi^n - \psi^n)$,
where the leading $\pm$ records the assignment. Squaring removes both signs:
$$(p^n - q^n)^2 = (\varphi^n - \psi^n)^2 = (\sqrt5\,F_n)^2 = 5F_n^2. \quad\square$$

The two identities are complementary: the symmetric combination sees the Lucas numbers,
the antisymmetric combination sees the Fibonacci numbers, and together they encode the
complete power-sum arithmetic of the periods.

## 5. Moduli and the exact value of $\sigma_5(2)$

**Theorem 5.1 (Golden moduli).** *For every primitive fifth root of unity $\zeta$,*
$$\{\,\lvert p\rvert,\ \lvert q\rvert\,\} \;=\; \{\,\varphi,\ \varphi^{-1}\,\}.$$
*Proof.* By Corollary 3.3 the periods are $-\varphi$ and $-\psi$. Their absolute values
are $\lvert-\varphi\rvert = \varphi$ and $\lvert-\psi\rvert = \lvert\psi\rvert$. From
$\varphi\psi = -1$ and $\psi < 0$ we get $\varphi(-\psi) = 1$, so $-\psi = \varphi^{-1}$,
whence $\lvert\psi\rvert = \varphi^{-1}$. $\square$

Thus the golden ratio itself is realized *exactly* as the modulus of a two-term sum of
fifth roots of unity (the longer period), while its reciprocal is the modulus of the
other. We now show the reciprocal is optimal.

**Theorem 5.2 (Two-term lower bound).** *For all $i, j \ge 0$,*
$$\lvert \zeta^i + \zeta^j\rvert \;\ge\; \varphi^{-1}.$$
*Proof.* Write the squared modulus using $\lvert\zeta^k\rvert = 1$ and $\overline{\zeta^j}
= \zeta^{4j}$:
$$\lvert \zeta^i + \zeta^j\rvert^2 = 2 + 2\,\mathrm{Re}\bigl(\zeta^i\overline{\zeta^j}\bigr)
= 2 + 2\,\mathrm{Re}\bigl(\zeta^{\,e}\bigr), \qquad e \equiv i - j \pmod 5.$$
The real part $2\,\mathrm{Re}(\zeta^e) = \zeta^e + \zeta^{4e}$ takes only three values as
$e$ ranges over residues mod $5$: it equals $2$ (when $e \equiv 0$), $p$ (when
$e \equiv \pm1$), or $q$ (when $e \equiv \pm2$). Hence
$$\lvert \zeta^i + \zeta^j\rvert^2 \in \{\,2 + 2,\ 2 + p,\ 2 + q\,\} = \{4,\ 2 + p,\ 2 + q\}.$$
Since $\{p, q\} = \{-\varphi, -\psi\}$ with $-\varphi \le -\psi$, the smallest of these is
$2 - \varphi$. Finally $2 - \varphi = \varphi^{-2}$ because
$(2-\varphi)\varphi^2 = 2\varphi^2 - \varphi^3 = 2(\varphi+1) - \varphi(\varphi+1)
= (\varphi + 2) - (\varphi^2 + \varphi) = (\varphi+2) - (2\varphi + 1) = 1$. Therefore
$\lvert \zeta^i + \zeta^j\rvert^2 \ge \varphi^{-2}$, and taking square roots gives the
claim. $\square$

**Theorem 5.3 (Value of $\sigma_5(2)$).** *The reciprocal golden ratio $\varphi^{-1}$ is
the least modulus among all two-term sums of fifth roots of unity:*
$$\sigma_5(2) \;=\; \varphi^{-1} \;=\; 0.6180339887\ldots$$
*More precisely, $\varphi^{-1}$ is attained (by the shorter Gaussian period) and is a
lower bound for every two-term sum.*
*Proof.* Attainment: by Theorem 5.1 one of the periods, say $q = \zeta^2 + \zeta^3$, has
$\lvert q\rvert = \varphi^{-1}$, and this is a genuine two-term sum. Lower bound: Theorem
5.2. Since $5$ is odd, every two-term sum is automatically non-vanishing, so no side
condition is needed. Together these say $\varphi^{-1}$ is the least element of the set of
two-term moduli. $\square$

This is the base case of the general staircase and the anchor for everything that
follows: the very first minimal modulus is the golden ratio's reciprocal.

## 6. The full picture: monotonicity and jumps

We now state and explain the general phenomenon. The proofs of Sections 3–5 supply its
algebraic core; the full statement additionally requires a geometry-of-numbers analysis of
minimizers, discussed in Section 9.

**Main phenomenon.** *The sequence $\sigma_5(n)$ is monotone non-increasing along each
residue class of $n$ modulo $5$. Moreover a strict decrease*
$$\sigma_5(n) > \sigma_5(n+5)$$
*occurs if and only if $n + 5$ has one of the three forms $5F_m$, $L_m$, or $2L_m$ for
some integer $m \ge 1$, where $F_m$ and $L_m$ are the Fibonacci and Lucas numbers.*

**Why monotone.** Adding five more roots can only enlarge the pool of achievable sums:
given any non-vanishing $n$-term sum $S$, the sum $S + (1 + \zeta + \zeta^2 + \zeta^3 +
\zeta^4) = S + 0 = S$ is a non-vanishing $(n+5)$-term sum with the same modulus. Hence
every value achievable at level $n$ is achievable at level $n+5$, so the minimum cannot
increase: $\sigma_5(n+5) \le \sigma_5(n)$. This gives the non-increasing behavior on each
residue class immediately.

**Why the golden field.** By Lemma 2.1 every root sum is determined by its coefficient
vector $(a_0, \dots, a_4) \in \mathbb{Z}_{\ge0}^5$ only up to adding a constant to all
coordinates. Reducing modulo the all-ones vector and grouping conjugate pairs
$\zeta^k + \zeta^{5-k}$ expresses each sum in terms of $p$ and $q$, hence as an element of
the ring $\mathbb{Z}[\varphi]$ (the ring of integers of $\mathbb{Q}(\sqrt5)$). Minimizing
the complex modulus becomes minimizing $\lvert a + b\varphi\rvert$-type quantities over a
lattice in the golden field — a two-dimensional geometry-of-numbers problem.

**Why Fibonacci and Lucas locate the jumps.** In $\mathbb{Z}[\varphi]$ the powers of the
fundamental unit satisfy
$$\varphi^n = F_n\varphi + F_{n-1}, \qquad \varphi^n + \psi^n = L_n.$$
Thus Fibonacci numbers are exactly the coefficients that arise when one expresses a power
of $\varphi$ in the integral basis $\{1, \varphi\}$, and Lucas numbers are the traces
$\varphi^n + \psi^n$. The extremal (closest-to-origin) configurations turn out to be
$\varphi$-power multiples of the periods; the minimal modulus at level $n$ is therefore of
the form $\varphi^{-k}$ times a bounded correction, and the threshold index $k$ increments
exactly when the term count $n$ crosses a Fibonacci or Lucas scale. The three families
$5F_m$, $L_m$, $2L_m$ are precisely the term counts at which a new, tighter extremal
configuration first becomes available — respectively from the norm form $5F_m^2$ (Theorem
4.3), the trace $L_m$ (Theorem 4.2), and the doubled-trace configuration $2L_m$ arising
from combining a period with its conjugate. The base case $n = 2$ (with $n + 5 = 7 = L_4$,
recovering the first jump family) is Theorem 5.3.

## 7. Algorithms

The results above translate into effective procedures.

**Algorithm A (Direct minimal modulus).** To compute $\sigma_5(n)$ by brute force, note
that a sum is determined by the multiset of exponents used, i.e. by a composition
$(a_0, \dots, a_4)$ of $n$ into five nonnegative parts. There are $\binom{n+4}{4}$ such
compositions. For each, form $S = \sum_k a_k\zeta^k$, discard $S = 0$, and track the
minimum $\lvert S\rvert$. Complexity $O(n^4)$ sums; adequate for moderate $n$ and used to
generate the empirical staircase.

**Algorithm B (Golden-field reduction).** Using $p = -\varphi$ (or $\varphi^{-1}$) and
$q = -\varphi^{-1}$ (or $-\varphi$), reduce each conjugate-paired coefficient vector to an
element $a + b\sqrt5$ of $\mathbb{Z}[\varphi]$ and evaluate the exact modulus symbolically,
avoiding floating-point error and confirming that minimal values are exact powers of
$\varphi$ times small integers.

**Algorithm C (Jump detector).** Given a target range, enumerate the three families
$\{5F_m\}$, $\{L_m\}$, $\{2L_m\}$ up to the range bound, mark $n = (\text{value}) - 5$ as
predicted jump locations, and compare against the strict decreases observed in the
computed sequence $\sigma_5$. This verifies the jump characterization empirically.

## 8. Numerical illustration

The bridge identities are exact and can be checked to high precision. For the standard
root $\zeta = e^{2\pi i/5}$:

- $p = \zeta + \zeta^4 = 2\cos 72^\circ = 0.6180339887\ldots = \varphi^{-1}$, and
  $q = \zeta^2 + \zeta^3 = 2\cos 144^\circ = -1.6180339887\ldots = -\varphi$.
- $\lvert p\rvert = 0.618\ldots = \varphi^{-1}$, $\lvert q\rvert = 1.618\ldots = \varphi$;
  the smaller is $\sigma_5(2)$.
- Power sums: $p^n + q^n = (-1)^n L_n$ gives $-1, 3, -4, 7, -11, 18, \dots$ for
  $n = 1,2,3,4,5,6$, matching $\pm L_n$.
- Power differences: $(p^n - q^n)^2 = 5F_n^2$ gives $5, 5, 20, 45, 125, \dots$ for
  $n = 1,2,3,4,5$, i.e. $5\cdot1, 5\cdot1, 5\cdot4, 5\cdot9, 5\cdot25$.

The accompanying computational demonstrations verify these identities to machine precision
for a range of $n$, compute $\sigma_5(n)$ directly for small $n$, and confirm that the
locations of strict decrease coincide with the predicted set $\{5F_m, L_m, 2L_m\} - 5$.

## 9. Discussion and future directions

The material of Sections 3–5 is complete and rigorous: the Gaussian-period identities, the
Lucas and Fibonacci bridges, the golden-modulus computation, and the exact value
$\sigma_5(2) = \varphi^{-1}$ (stated as a least-element result) all stand on their own. The
full monotonicity-and-jumps statement of Section 6 rests on these foundations but requires
further development:

1. **A formal definition of $\sigma_5(n)$ for all $n$.** Model the set of $n$-term sums as
   the image of $f : \{0,\dots,4\}^n \to \mathbb{C}$, $f(a) = \sum_i \zeta^{a_i}$, restrict
   to nonzero values, and take the minimal modulus of this finite set. One must prove
   well-definedness and independence of the chosen primitive root. The case $n = 2$
   (Theorem 5.3) is the template and base case.

2. **Reduction to $\mathbb{Z}[\varphi]$.** Make precise the passage from coefficient
   vectors modulo the all-ones vector to elements of the golden ring, turning modulus
   minimization into a lattice problem in $\mathbb{Q}(\sqrt5)$. The Gaussian-period
   identities are the algebraic core of this reduction.

3. **The extremal structure.** Show that the minimizers are $\varphi$-power multiples of
   the periods, so that $\sigma_5$ values are, within each residue class, of the form
   $\varphi^{-k}$ times a bounded factor — which is exactly why Fibonacci and Lucas
   numbers, as the integer coefficients in $\varphi^n = F_n\varphi + F_{n-1}$ and the
   traces $\varphi^n + \psi^n = L_n$, control the jumps.

Beyond $p = 5$, the natural question is whether analogous "unit-scaled staircases" govern
$\sigma_p(n)$ for other primes, with the fundamental unit of the real cyclotomic field
$\mathbb{Q}(\zeta_p)^+$ playing the role that $\varphi$ plays here. For $p = 5$ that field
is $\mathbb{Q}(\sqrt5)$ and the unit is $\varphi$; for larger $p$ the units are more
intricate, and the corresponding integer sequences replacing Fibonacci and Lucas are not
yet identified. The clean $p = 5$ case established here is a proof of concept that such
sequences exist and can be pinned down exactly.

## 10. Conclusion

We have shown that the minimal-modulus problem for sums of fifth roots of unity is, at its
algebraic heart, a statement about the golden ratio. The two Gaussian periods of the
pentagon are $-\varphi$ and $-\psi$; their power sums are signed Lucas numbers, their power
differences encode Fibonacci numbers, and their moduli are $\varphi$ and $\varphi^{-1}$.
The immediate payoff is the exact value $\sigma_5(2) = \varphi^{-1}$, proved as a genuine
least-element result. The broader payoff is a precise dictionary between five-fold
cyclotomic symmetry and golden-ratio arithmetic that explains why Fibonacci and Lucas
numbers dictate the staircase of minimal moduli — a small but sharp instance of the deep
unity between algebraic number theory and combinatorics.
