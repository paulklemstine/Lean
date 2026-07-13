# The Uncanny Valley of Prime-Generating Polynomials

## Abstract

A *prime-generating polynomial* is a polynomial with integer coefficients that
produces prime values over a long, unbroken run of consecutive inputs. The
archetype is Euler's quadratic $n^2 + n + 41$, which is prime for all forty
inputs $n = 0, 1, \dots, 39$ before failing at $n = 40$, where its value is the
perfect square $41^2$. Such formulas inhabit a mathematical *uncanny valley*:
they are so nearly perfect prime oracles that they invite belief, only to fail
abruptly. This paper establishes the structural reason no such formula can
succeed forever. We prove that **no nonconstant integer polynomial takes a prime
value at every integer input**, and, more strongly, that **the set of inputs at
which a nonconstant integer polynomial fails to be prime is infinite**. Both
results flow from a single divisibility identity, $f(a) \mid f(a + k\,f(a))$,
which propagates any prime value along an entire arithmetic progression until the
finiteness of a polynomial's value set forces a collapse. We give complete proof
sketches, illustrate every step on Euler's polynomial, and outline a program of
generalizations: quantitative density bounds, abstraction to value sets with a
finite-fiber divisibility property, extension to several variables, and the
transcendence obstruction any genuine prime formula must overcome.

**Keywords:** prime numbers, integer polynomials, divisibility, arithmetic
progressions, Euler's polynomial, prime-generating formulas.

---

## 1. Introduction

The distribution of prime numbers is one of the oldest and deepest subjects in
mathematics. Alongside the analytic study of how primes thin out, there runs a
persistent and more elementary quest: to find a *formula* that outputs primes.
The most seductive candidates are polynomials, and the most celebrated of these
is Euler's polynomial
$$f(n) = n^2 + n + 41,$$
which returns a prime for each of the forty consecutive inputs
$n = 0, 1, \dots, 39$. A run this long makes the polynomial *look* like a genuine
prime generator — and this near-perfection is precisely what makes its eventual
failure so striking. We borrow a term from robotics and human perception: a
formula this close to a prime oracle sits in an **uncanny valley**, almost right
but structurally doomed.

This paper makes the doom precise. Our contributions are:

1. A clean statement and proof of the classical impossibility: no nonconstant
   integer polynomial is prime at every integer input (Theorem 3.1).
2. A strengthening: the inputs at which such a polynomial is *not* prime form an
   infinite set (Theorem 3.2).
3. An explicit, self-contained analysis of Euler's polynomial exhibiting both the
   long prime run and its first failure (Section 4).
4. A program of conjectural generalizations (Section 6).

The mathematics is elementary but the conceptual payoff is sharp: the very
algebraic regularity that lets a polynomial produce a long prime run — its
predictable behavior modulo each of its own values — is exactly what guarantees
its collapse.

---

## 2. Definitions and preliminaries

Throughout, $\mathbb{Z}[x]$ denotes the ring of polynomials in one variable with
integer coefficients. For $f \in \mathbb{Z}[x]$ and $a \in \mathbb{Z}$ we write
$f(a)$ for the value of $f$ at $a$.

**Definition 2.1 (Prime integer).** An integer $p$ is *prime* if $p \notin
\{-1, 0, 1\}$ and whenever $p \mid ab$ then $p \mid a$ or $p \mid b$.
Equivalently, $|p|$ is a prime natural number. In particular $2, 3, 5, \dots$ and
their negatives are prime, while $0$ and $\pm 1$ are not.

**Definition 2.2 (Nonconstant polynomial).** A polynomial $f \in \mathbb{Z}[x]$
is *nonconstant* if there is no integer $c$ with $f = c$ (as a polynomial). A
nonconstant polynomial has degree at least $1$.

**Definition 2.3 (Prime-generating).** We call $f \in \mathbb{Z}[x]$
*prime-generating* if $f(n)$ is prime for every $n \in \mathbb{Z}$. The central
question of this paper is whether any nonconstant $f$ can be prime-generating.

We record two elementary facts used repeatedly.

**Lemma 2.4 (Finite fibers of a nonconstant polynomial).** *If
$f \in \mathbb{Z}[x]$ is nonconstant and $v \in \mathbb{Z}$, then the set
$\{n \in \mathbb{Z} : f(n) = v\}$ is finite.*

*Proof.* The set is precisely the set of integer roots of the nonconstant
polynomial $f - v$, which has degree $\deg f \ge 1$ and hence at most $\deg f$
roots. $\qquad\blacksquare$

**Lemma 2.5 (A prime dividing a prime).** *If $p, q \in \mathbb{Z}$ are both
prime and $p \mid q$, then $q = p$ or $q = -p$.*

*Proof.* Write $q = pk$. Passing to absolute values, $|q| = |p|\,|k|$ with $|p|$
and $|q|$ prime natural numbers. Since $|p| \ge 2$ divides the prime $|q|$, we
must have $|k| = 1$ and $|q| = |p|$. Hence $q = \pm p$. $\qquad\blacksquare$

---

## 3. The main results

### 3.1 The divisibility engine

The entire theory rests on one identity, which we call the divisibility engine.

**Lemma 3.0 (Divisibility engine).** *For every $f \in \mathbb{Z}[x]$ and all
integers $a, k$,*
$$f(a) \ \big|\ f\bigl(a + k\,f(a)\bigr).$$

*Proof.* For any polynomial $f \in \mathbb{Z}[x]$ and any integers $u, v$, the
difference $u - v$ divides $f(u) - f(v)$. This is the integer specialization of
the algebraic factorization $u^j - v^j = (u - v)(u^{j-1} + \cdots + v^{j-1})$
applied termwise to $f$; summing over the monomials of $f$ shows
$(u - v) \mid (f(u) - f(v))$.

Apply this with $u = a + k\,f(a)$ and $v = a$. Then $u - v = k\,f(a)$, so
$$k\,f(a) \ \big|\ f\bigl(a + k\,f(a)\bigr) - f(a).$$
In particular $f(a) \mid f(a + k\,f(a)) - f(a)$, and since trivially
$f(a) \mid f(a)$, we conclude $f(a) \mid f(a + k\,f(a))$. $\qquad\blacksquare$

The name is apt: fixing a base point $a$, the identity manufactures an infinite
arithmetic progression $a, a + f(a), a + 2f(a), \dots$ every one of whose outputs
is divisible by $f(a)$. This progression is the mechanism that dooms every
prime-generating formula.

### 3.2 No polynomial escapes the valley

**Theorem 3.1 (Impossibility of prime-generating polynomials).** *No nonconstant
polynomial $f \in \mathbb{Z}[x]$ satisfies $f(n)$ prime for every
$n \in \mathbb{Z}$.*

*Proof sketch.* Suppose for contradiction that $f$ is nonconstant and $f(n)$ is
prime for all $n$. Choose any base point $a$; since $f(a)$ is prime we have
$f(a) \notin \{-1, 0, 1\}$. Set $p = f(a)$.

By the divisibility engine (Lemma 3.0), for every integer $k$,
$$p = f(a) \ \big|\ f\bigl(a + k\,p\bigr).$$
Each value $f(a + k\,p)$ is prime by hypothesis, and it is divisible by the prime
$p$, so Lemma 2.5 forces
$$f(a + k\,p) \in \{p,\, -p\} \qquad \text{for every } k \in \mathbb{Z}.$$

Thus the infinitely many distinct inputs $a + k\,p$ (distinct because $p \ne 0$)
all map into the two-element set $\{p, -p\}$. By pigeonhole at least one value,
say $p$, is attained at infinitely many of these inputs. But by Lemma 2.4 a
nonconstant polynomial attains any fixed value only finitely often. This
contradiction shows $f$ cannot be prime-generating. $\qquad\blacksquare$

An equivalent way to package the endgame, which is often the cleanest phrasing,
is to observe that the set
$$S = \{x \in \mathbb{Z} : f(x) = p \text{ or } f(x) = -p\}$$
is infinite, yet is contained in the union of the (finite) root sets of the two
nonconstant polynomials $f - p$ and $f + p$ — unless one of those polynomials is
identically zero, i.e. $f = p$ or $f = -p$ as polynomials, contradicting
nonconstancy.

### 3.3 The valley has infinite width

The impossibility theorem shows a nonconstant polynomial fails to be prime
*somewhere*. In fact it fails almost everywhere in the following sense.

**Theorem 3.2 (Infinitely many non-prime values).** *If $f \in \mathbb{Z}[x]$ is
nonconstant, then the set*
$$\{\,n \in \mathbb{Z} : f(n) \text{ is not prime}\,\}$$
*is infinite.*

*Proof sketch.* Argue by contraposition: suppose the set of non-prime inputs is
finite. Then $f$ is prime at all but finitely many inputs; in particular there is
a base point $a$ with $f(a)$ prime and $f(a) \ne 0$. Put $p = f(a)$.

Consider the arithmetic progression $\{a + k\,p : k \in \mathbb{Z}\}$, an
infinite set of inputs. All but finitely many of these are among the (cofinitely
many) inputs where $f$ is prime. For each such input $a + k\,p$, the divisibility
engine gives $p \mid f(a + k\,p)$, and primality plus Lemma 2.5 forces
$f(a + k\,p) \in \{p, -p\}$. Hence infinitely many inputs map into $\{p, -p\}$.

As before, this set of inputs lies in the union of the root sets of $f - p$ and
$f + p$; being infinite, it forces one of these polynomials to vanish
identically, so $f = p$ or $f = -p$ as a polynomial. Either way $f$ is constant.
Contrapositively, a nonconstant $f$ has infinitely many non-prime inputs.
$\qquad\blacksquare$

**Remark.** The two theorems share a single engine. Theorem 3.1 needs only one
prime value to ignite the progression; Theorem 3.2 observes that the same
ignition, started from a cofinite supply of prime values, floods the progression
with composite outputs. Neither argument uses anything about primes beyond Lemma
2.5 — the finite-fiber divisibility property — a fact we exploit in Section 6.

---

## 4. Euler's polynomial: a guided tour of the valley

We illustrate every abstract step on the archetype
$$f(n) = n^2 + n + 41.$$

**The polynomial is nonconstant.** Its degree-$2$ coefficient is $1 \ne 0$, so
$f \ne c$ for any constant $c$; Lemma 2.4 applies with $\deg f = 2$, so $f$ takes
each value at most twice.

**The illusion — a run of forty primes.** Direct computation confirms that
$f(n) = n^2 + n + 41$ is prime for every $n \in \{0, 1, \dots, 39\}$:
$$41, 43, 47, 53, 61, 71, 83, 97, 113, 131, 151, 173, 197, 223, 251, 281, \dots, 1601.$$
Each of these forty values is prime. This is the top lip of the uncanny valley:
the formula behaves exactly like a prime oracle over a substantial range.

**The reveal — first failure at $n = 40$.** The run ends immediately at the next
input:
$$f(40) = 40^2 + 40 + 41 = 1600 + 40 + 41 = 1681 = 41^2,$$
a perfect square, hence composite. The failure is not accidental but structurally
inevitable: note $f(40) = 41^2$ and $41 = f(0)$, an instance of the divisibility
engine with $a = 0$, $p = 41$. Indeed $40 = 0 + (-1)\cdot 41 + 81$... more
transparently, $f(0) = 41$ divides $f(0 + k\cdot 41)$ for all $k$, and the same
mechanism seeds squares such as $f(40) = 41^2$ nearby.

**The general obstruction, applied.** Theorem 3.1, specialized to Euler's
polynomial, guarantees a priori — without computing $f(40)$ — that some input
must yield a non-prime value. The explicit witness $n = 40$ merely confirms what
the structure already demands. Theorem 3.2 further guarantees that infinitely
many inputs beyond $n = 40$ also yield composite values.

---

## 5. Algorithms

The results suggest natural computational procedures, useful for exploration and
for exhibiting concrete failures.

### 5.1 Prime-run length

Given a nonconstant $f \in \mathbb{Z}[x]$ and a starting input $n_0$, compute the
number of consecutive inputs $n_0, n_0 + 1, \dots$ for which $f$ remains prime.
Theorem 3.1 guarantees this loop terminates. For Euler's polynomial started at
$0$, it returns $40$.

```
function PrimeRunLength(f, n0):
    n <- n0
    while |f(n)| is prime:
        n <- n + 1
    return n - n0
```

### 5.2 Certified failure via the divisibility engine

Rather than searching blindly, use the engine to *construct* a composite value.
Find any $a$ with $p = f(a)$ prime and $|p| \ge 2$. Then for any $k \ne 0$ the
input $a + k\,p$ satisfies $p \mid f(a + k\,p)$. If additionally
$|f(a + k\,p)| > |p|$ then $f(a + k\,p)$ is a genuine composite (a proper
multiple of $p$). Because $|f|$ grows without bound on a nonconstant polynomial,
such $k$ always exists, giving a *certificate* of failure with an explicit
divisor.

```
function CertifiedFailure(f):
    find a with p = f(a) prime, |p| >= 2
    k <- 1
    while |f(a + k*p)| <= |p|:
        k <- k + 1
    return (n = a + k*p, divisor = p, value = f(n))   # p | f(n), |f(n)| > |p|
```

### 5.3 Density of prime outputs

Empirically estimate the density of prime outputs by counting prime values among
$f(0), \dots, f(N)$. Theorem 3.2 predicts the count of *non*-prime values grows
without bound; the conjectures of Section 6 predict the prime density tends to $0$.

---

## 6. Discussion and future directions

This cycle established that no nonconstant integer polynomial takes a prime value
at every input, and that in fact the inputs where the "prime illusion" breaks
form an infinite set. The obstruction is a single divisibility identity,
$f(a) \mid f(a + k\,f(a))$, propagating a prime value along an arithmetic
progression until finiteness of a polynomial's value set forces a collapse. The
following conjectures push the phenomenon further.

**Conjecture 1 — Quantitative width of the valley.** For a nonconstant integer
polynomial $f$ of degree $d$, the number of inputs $n \in \{0, 1, \dots, N\}$ at
which $f(n)$ is composite grows like $N - O(N / \log N)$; equivalently, the
density of prime inputs tends to $0$. *The key insight is* that the divisibility
engine forces composite values along an entire arithmetic progression of modulus
$f(a)$, so each prime output "spends" a whole residue class, and only a
logarithmically thin set of inputs can survive.

**Conjecture 2 — Universality across value-restricted targets.** Replace "prime"
by any set $T \subseteq \mathbb{Z}$ that meets each divisibility fiber
$\{m : p \mid m\}$ in only finitely many associates (e.g. prime powers with
bounded exponent, or squarefree numbers with a fixed number of prime factors).
Then no nonconstant integer polynomial can take values in $T$ at every input.
*The key insight is* that the proof never used primality beyond "a prime dividing
a value pins that value to finitely many possibilities"; abstracting this to a
*finite-fiber divisibility* condition on $T$ reproduces the collapse.

**Conjecture 3 — Multivariate uncanny valley.** No nonconstant polynomial
$f \in \mathbb{Z}[x_1, \dots, x_k]$ that genuinely depends on at least one
variable takes a prime value at every integer lattice point. *The key insight is*
that fixing all but one variable reduces the problem to the single-variable
theorem, so the only obstruction is ruling out the degenerate case where every
such restriction is constant — which forces $f$ itself constant.

**Conjecture 4 — Escaping the valley requires transcendence.** Any function
$g : \mathbb{Z} \to \mathbb{Z}$ that IS prime at every input must be
non-polynomial in a strong sense: its finite differences of every order are
eventually nonzero, so $g$ cannot satisfy any linear recurrence with constant
coefficients. To truly generate the primes, a formula must abandon the algebraic
world entirely.

---

## 7. Conclusion

Euler's polynomial is the mathematician's uncanny valley: a formula so nearly a
prime oracle that it invites belief, and whose inevitable failure at $n = 40$ is
all the more jarring for the forty flawless steps that precede it. We have shown
this is no isolated misfortune. A single divisibility identity forces every
nonconstant integer polynomial to fail — not once, but infinitely often. The
regularity that produces long prime runs is the very regularity that guarantees
their end. The primes, it appears, cannot be captured by any formula that is
merely *almost* right.
