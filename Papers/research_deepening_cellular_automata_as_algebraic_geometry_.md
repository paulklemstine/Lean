# Nilpotency of Additive Cellular Automata on Cyclic Lattices: A Bridge Between Wolfram Dynamics and the Geometry of Roots of Unity

## Abstract

We study the additive elementary cellular automaton on a finite cyclic lattice
$\mathbb{Z}/n$ whose local rule replaces each cell by the sum, modulo two, of
itself and its right neighbour. Encoding spatially $n$-periodic binary
configurations as elements of the finite ring $R_n = \mathbb{F}_2[X]/(X^n - 1)$,
we identify one time step with multiplication by the distinguished element
$u = 1 + X$. We prove a sharp trichotomy-collapsing-to-dichotomy: the automaton
is *globally nilpotent* — every configuration reaches the all-zero state in
finitely many steps — if and only if $n$ is a power of two. Algebraically, the
element $u$ is nilpotent in $R_n$ iff $n = 2^k$; geometrically, the finite group
scheme $\mu_n = \operatorname{Spec} \mathbb{F}_2[X]/(X^n - 1)$ is a non-reduced
(purely infinitesimal) "fat point" iff $n$ is a power of the characteristic. When
mortality holds, we further show the nilpotency index — the exact relaxation time
of the automaton — equals $n$. The proof combines the Frobenius "freshman's
dream," primality of $X + 1$ in $\mathbb{F}_2[X]$, a derivative/parity argument,
and a characteristic-two square-root descent. The result exemplifies a general
principle: a dynamical property of a Wolfram-style automaton is equivalent to a
reducedness property of an associated scheme, mediated by elementary arithmetic.

**Keywords:** elementary cellular automata, additive rules, nilpotency, finite
group schemes, roots of unity, non-reduced schemes, Frobenius, characteristic
two, $\mathbb{F}_2[X]$.

---

## 1. Introduction

Elementary cellular automata (ECAs) are the $256$ one-dimensional binary automata
whose next-cell value is a Boolean function of a three-cell neighbourhood.
Despite their minimal description, ECAs display the full spectrum of dynamical
behaviour, culminating in the Turing-completeness of Rule 110. Among the $256$
rules a distinguished subfamily is *additive* (or *linear*): the rules whose
local map is $\mathbb{F}_2$-linear. For these — Rules $60, 90, 102, 150, \dots$ —
the global map is a linear operator, and the entire theory of the automaton
becomes the theory of a single matrix, or, better, of a single element in a
group ring.

This paper focuses on the simplest nontrivial additive ECA on a **finite cyclic**
lattice: the rule

$$s_i \longmapsto s_i + s_{i+1} \pmod 2, \qquad i \in \mathbb{Z}/n,$$

(Wolfram's Rule 60, read right-to-left) acting on spatially $n$-periodic
configurations. Our central question is one of *global nilpotency*: for which
lattice sizes $n$ does every configuration eventually reach the quiescent
all-zero state?

We answer this completely and connect the answer to two other mathematical
worlds. The bridge is built by encoding configurations in the finite ring
$R_n = \mathbb{F}_2[X]/(X^n - 1)$, the coordinate ring of the group scheme
$\mu_n$ of $n$-th roots of unity over $\mathbb{F}_2$. Under this encoding, the
automaton is multiplication by $u = 1 + X$, and global nilpotency of the
dynamics equals nilpotency of the ring element $u$, which in turn equals
non-reducedness of the scheme $\mu_n$.

**Main Theorem.** *For $n > 0$, the following are equivalent:*
1. *Every configuration $s \in R_n$ satisfies $(\text{caStep})^{[t]}(s) = 0$ for
   some $t$ (global nilpotency of the dynamics);*
2. *$u = 1 + X$ is nilpotent in $R_n = \mathbb{F}_2[X]/(X^n - 1)$;*
3. *$X^n - 1 = (X + 1)^n$ in $\mathbb{F}_2[X]$;*
4. *the scheme $\mu_n$ over $\mathbb{F}_2$ is non-reduced (a fat point);*
5. *$n$ is a power of two.*

The equivalences $(1)\Leftrightarrow(2)$ and $(2)\Leftrightarrow(5)$ are proved
in full below; $(3)$ is the technical fulcrum, and $(4)$ is the geometric
reinterpretation.

### 1.1 Related context

The dynamics of additive cellular automata over finite fields have a long
history, going back to work of Martin, Odlyzko, and Wolfram, and to the algebraic
theory of linear ECAs via polynomial and matrix methods. The novelty here is not
the individual ingredients but the explicit, provable **dictionary** between
three vocabularies — Wolfram dynamics, commutative algebra, and scheme-theoretic
geometry — and the sharpness of the resulting classification, together with the
exact relaxation time.

---

## 2. The algebraic dictionary

### 2.1 Configurations as ring elements

Let $\mathbb{F}_2 = \mathbb{Z}/2$ be the two-element field. A spatially
$n$-periodic binary configuration is a function $s : \mathbb{Z}/n \to
\mathbb{F}_2$, equivalently a vector $(s_0, \dots, s_{n-1}) \in \mathbb{F}_2^n$.

**Definition 2.1 (State ring).** The state ring of the automaton on the cyclic
lattice $\mathbb{Z}/n$ is the finite quotient ring

$$R_n \;=\; \mathbb{F}_2[X]\,/\,(X^n - 1),$$

with the $\mathbb{F}_2$-linear isomorphism $R_n \cong \mathbb{F}_2[\mathbb{Z}/n]$
(the group algebra of the cyclic group) sending the cell at position $i$ to the
monomial $X^i$. Explicitly, the configuration $(s_0, \dots, s_{n-1})$ corresponds
to the residue class of $\sum_{i=0}^{n-1} s_i X^i$.

Multiplication by $X$ in $R_n$ is the cyclic shift $s_i \mapsto s_{i-1}$, because
$X^n = 1$ closes the lattice into a ring (in both senses of the word).

### 2.2 The rule as multiplication

**Definition 2.2 (CA operator).** Let $u = 1 + X \in R_n$, the *CA unit*. One
time step of the automaton is the ring multiplication

$$\operatorname{caStep} : R_n \to R_n, \qquad s \mapsto u \cdot s.$$

Indeed, $(1 + X)\sum_i s_i X^i = \sum_i (s_i + s_{i-1}) X^i$, which — after
relabelling — is precisely the rule "new cell $=$ old cell $+$ neighbour."

**Lemma 2.3 (Time evolution).** *For every $t \in \mathbb{N}$ and every
$s \in R_n$,*

$$(\operatorname{caStep})^{[t]}(s) = u^t \cdot s.$$

*Proof.* Immediate by induction on $t$: the base case is $u^0 s = s$, and the
step uses associativity, $u^{t+1} s = u (u^t s)$. $\qquad\blacksquare$

**Corollary 2.4 (Dynamics $\leftrightarrow$ nilpotency).** *The automaton is
globally nilpotent — for every $s$ there is $t$ with
$(\operatorname{caStep})^{[t]}(s) = 0$ — if and only if $u$ is a nilpotent
element of $R_n$.*

*Proof.* If $u^N = 0$ then $u^N s = 0$ for all $s$, so every configuration dies
by step $N$. Conversely, apply global nilpotency to the specific configuration
$s = 1$ (a single black cell at the origin): some $t$ gives $u^t \cdot 1 = u^t =
0$. $\qquad\blacksquare$

### 2.3 Nilpotency as divisibility

Nilpotency in a quotient of a polynomial ring unwinds to a divisibility
statement.

**Lemma 2.5 (Nilpotency is divisibility).** *For $n > 0$, $u = 1 + X$ is
nilpotent in $R_n$ if and only if there exists $N$ with*

$$(X^n - 1) \mid (X + 1)^N \quad \text{in } \mathbb{F}_2[X].$$

*Proof.* By definition $u^N = 0$ in $R_n = \mathbb{F}_2[X]/(X^n - 1)$ means the
lift $(X + 1)^N$ lies in the ideal $(X^n - 1)$, i.e. is divisible by $X^n - 1$.
$\qquad\blacksquare$

Thus the entire problem reduces to a question about the polynomial $X^n - 1$ and
powers of $X + 1$ over $\mathbb{F}_2$.

---

## 3. The characteristic-two toolbox

All computations take place in $\mathbb{F}_2[X]$, an integral domain of
characteristic two, where the following elementary facts hold.

**Lemma 3.1 (Squaring is injective).** *For $A, B \in \mathbb{F}_2[X]$, if
$A^2 = B^2$ then $A = B$.*

*Proof.* In characteristic two, $(A + B)^2 = A^2 + 2AB + B^2 = A^2 + B^2$. If
$A^2 = B^2$ then $(A+B)^2 = A^2 + B^2 = 2A^2 = 0$, so $A + B = 0$ (a domain has no
nonzero nilpotents), whence $A = -B = B$ (as $-1 = 1$). $\qquad\blacksquare$

**Lemma 3.2 (Frequency doubling).** *For every $m$,
$(X^m - 1)^2 = X^{2m} - 1$ in $\mathbb{F}_2[X]$.*

*Proof.* Since $-1 = 1$, we have $X^m - 1 = X^m + 1$. By the Frobenius identity
$(a + b)^2 = a^2 + b^2$ in characteristic two,
$(X^m + 1)^2 = X^{2m} + 1 = X^{2m} - 1$. $\qquad\blacksquare$

**Lemma 3.3 (Primality of $X + 1$).** *The polynomial $X + 1$ is prime in
$\mathbb{F}_2[X]$.*

*Proof.* Over any field, $X - c$ is prime for every constant $c$. Taking $c = 1$
and using $-1 = 1$ gives $X - 1 = X + 1$. $\qquad\blacksquare$

**Lemma 3.4 (Frobenius collapse).** *For every $k$,*

$$(X + 1)^{2^k} = X^{2^k} + 1 = X^{2^k} - 1 \quad \text{in } \mathbb{F}_2[X].$$

*Proof.* The Frobenius endomorphism $a \mapsto a^2$ is a ring homomorphism in
characteristic two; iterating $k$ times, $a \mapsto a^{2^k}$ is also a ring
homomorphism. Applying it to $X + 1$ gives $(X + 1)^{2^k} = X^{2^k} + 1^{2^k} =
X^{2^k} + 1$. Since $-1 = 1$, this equals $X^{2^k} - 1$. $\qquad\blacksquare$

---

## 4. The classification

We prove the equivalence of statements (2), (3), (5) of the Main Theorem in
three implications, and then assemble the theorem.

### 4.1 Powers of two are mortal

**Proposition 4.1.** *If $n = 2^k$ then $X^n - 1 = (X + 1)^n$; consequently $u^n =
0$ in $R_n$ and the automaton is globally nilpotent.*

*Proof.* The first identity is exactly Lemma 3.4. Reducing modulo $X^n - 1$, the
right-hand side $(X + 1)^n = u^n$ maps to the residue of $X^n - 1$, which is $0$.
By Corollary 2.4 the dynamics is globally nilpotent. $\qquad\blacksquare$

### 4.2 A parity constraint from the derivative

**Proposition 4.2 (Even from the derivative).** *If $n \ge 2$ and $X^n - 1 =
(X + 1)^n$ in $\mathbb{F}_2[X]$, then $n$ is even (i.e. $n \equiv 0 \bmod 2$).*

*Proof.* Apply the formal derivative $\tfrac{d}{dX}$ to both sides. The left side
gives $n X^{n-1}$; the right side gives $n (X + 1)^{n-1}$. Now evaluate at
$X = 0$. Since $n \ge 2$, $X^{n-1}$ vanishes at $0$, so the left side evaluates to
$0$. The right side evaluates to $n \cdot (0 + 1)^{n-1} = n$. Hence $n = 0$ in
$\mathbb{F}_2$, i.e. $n$ is even. $\qquad\blacksquare$

### 4.3 Descent by square roots

**Proposition 4.3 (Arithmetic heart).** *If $n > 0$ and $X^n - 1 = (X + 1)^n$,
then $n = 2^k$ for some $k$.*

*Proof.* Strong induction on $n$. If $n = 1$, then $n = 2^0$. If $n \ge 2$, then
by Proposition 4.2 $n$ is even, say $n = 2m$ with $m \ge 1$. We reduce the
identity from $n$ to $m$. Squaring both sides of the desired reduced identity and
using Lemma 3.2 and the law of exponents,

$$(X^m - 1)^2 = X^{2m} - 1 = X^n - 1 = (X + 1)^n = (X + 1)^{2m} = \big((X + 1)^m\big)^2.$$

By Lemma 3.1 (injectivity of squaring) we may take square roots to conclude
$X^m - 1 = (X + 1)^m$. Since $m < n$, the induction hypothesis yields $m = 2^k$,
hence $n = 2m = 2^{k+1}$. $\qquad\blacksquare$

### 4.4 From divisibility to the exact identity

**Proposition 4.4 (Prime-power divisors).** *If $n > 0$ and
$(X^n - 1) \mid (X + 1)^N$ for some $N$, then $X^n - 1 = (X + 1)^n$.*

*Proof.* Since $X + 1$ is prime (Lemma 3.3), every divisor of $(X + 1)^N$ is an
associate of a power $(X + 1)^i$ for some $0 \le i \le N$. Both $X^n - 1$ and
$(X + 1)^i$ are **monic**, and two monic associates are equal; hence
$X^n - 1 = (X + 1)^i$. Comparing degrees, $\deg(X^n - 1) = n$ and
$\deg((X + 1)^i) = i$, so $i = n$ and $X^n - 1 = (X + 1)^n$. $\qquad\blacksquare$

### 4.5 Assembling the Main Theorem

**Theorem 4.5 (Nilpotency dichotomy).** *For $n > 0$,*

$$u = 1 + X \text{ is nilpotent in } R_n \iff n = 2^k \text{ for some } k.$$

*Proof.* By Lemma 2.5, nilpotency of $u$ is equivalent to $(X^n - 1) \mid
(X + 1)^N$ for some $N$.

($\Rightarrow$) Given such $N$, Proposition 4.4 gives $X^n - 1 = (X + 1)^n$, and
Proposition 4.3 gives $n = 2^k$.

($\Leftarrow$) If $n = 2^k$, Proposition 4.1 gives $u^n = 0$, so in particular
$(X^n - 1) \mid (X + 1)^n$ and $u$ is nilpotent. $\qquad\blacksquare$

**Theorem 4.6 (Dynamical form).** *For $n > 0$, every configuration on the cyclic
lattice $\mathbb{Z}/n$ reaches the all-zero state in finitely many steps iff $n$
is a power of two.*

*Proof.* Combine Corollary 2.4 with Theorem 4.5. $\qquad\blacksquare$

**Worked instances.** The automaton on lattices of size $4 = 2^2$ and $8 = 2^3$
is globally nilpotent (every configuration dies). The automaton on lattices of
size $3$, $5$, $6$, $7$ is *not* nilpotent: some configuration cycles forever.
For instance, on the $3$-cycle the single-cell pattern $1$ evolves
$1 \to 1 + X \to 1 + X^2 \to \cdots$ and never reaches $0$, since $3$ is not a
power of two.

---

## 5. The relaxation time

For mortal lattices the classification refines to an exact rate of decay.

**Theorem 5.1 (Nilpotency index).** *If $n = 2^k$, the nilpotency index of
$u$ — the least $N$ with $u^N = 0$ in $R_n$ — is exactly $n$.*

*Proof.* We have $u^n = (X + 1)^n = X^n - 1 \equiv 0$, so $N \le n$. For minimality,
suppose $u^N = 0$ with $N < n$; then $(X^n - 1) \mid (X + 1)^N$. Since $X + 1$ is
prime and $X^n - 1 = (X + 1)^n$ (Proposition 4.1), this forces $(X + 1)^n \mid
(X + 1)^N$, hence $n \le N$, a contradiction. Therefore $N = n$. $\qquad\blacksquare$

Dynamically, the single-cell configuration on the $2^k$-lattice takes the full
$n = 2^k$ steps to die, and its space-time diagram is a wrapped **Sierpiński
triangle** (Pascal's triangle modulo two) truncated exactly when the wraparound
completes the annihilation.

---

## 6. Geometric interpretation: fat points and non-reduced schemes

The ring $R_n = \mathbb{F}_2[X]/(X^n - 1)$ is the coordinate ring of the affine
group scheme $\mu_n = \operatorname{Spec} R_n$ of $n$-th roots of unity over
$\mathbb{F}_2$. Two classical dichotomies for $\mu_n$ mirror our results.

**Reducedness.** A commutative ring is *reduced* if it has no nonzero nilpotents;
the scheme $\mu_n$ is reduced iff $R_n$ is reduced iff $X^n - 1$ is squarefree.
Over $\mathbb{F}_2$, $X^n - 1$ is squarefree iff its derivative $n X^{n-1}$ is
coprime to it, i.e. iff $n$ is odd. Thus:

- **$n$ odd:** $\mu_n$ is *étale/reduced* — a clean union of (Galois orbits of)
  distinct points. The automaton is reversible-flavoured and non-nilpotent.
- **$n = 2^k$:** $X^n - 1 = (X + 1)^n$ is a single prime raised to the $n$-th
  power. The scheme $\mu_n$ is supported at the *single* point $X = 1$ with
  multiplicity $n$: a **fat point**, non-reduced and purely infinitesimal. The
  nilpotent $u = 1 + X$ is the algebraic witness of the infinitesimal thickness,
  and its index $n$ is the length of the fat point.
- **general $n = 2^k m$ ($m$ odd):** $\mu_n$ splits, over $\mathbb{F}_2$, into
  fat pieces of thickness $2^k$ arranged over the reduced points of $\mu_m$; $u$
  is nilpotent iff the reduced part is trivial, i.e. $m = 1$.

This is a manifestation of the general principle that in characteristic $p$, the
map $\mu_n \to \mu_n$ (equivalently roots of $X^n - 1$) develops infinitesimal
structure exactly when $p \mid n$, collapsing entirely to a fat point when $n$ is
a power of $p$. Our Main Theorem is the specialization $p = 2$, seen through the
lens of an automaton.

**Summary of the dictionary.**

| Dynamics | Algebra | Geometry | Arithmetic |
|---|---|---|---|
| every pattern dies | $u = 1 + X$ nilpotent | $\mu_n$ is a fat point (non-reduced) | $n = 2^k$ |
| some pattern lives forever | $u$ not nilpotent | $\mu_n$ has a reduced part | $n$ has an odd factor $> 1$ |
| relaxation time | nilpotency index of $u$ | length of the fat point | $n = 2^k$ |

---

## 7. Algorithms

We record the effective procedures underlying the classification. Throughout,
polynomials over $\mathbb{F}_2$ are represented as bitmasks (integer whose bit $i$
is the coefficient of $X^i$), so addition is XOR.

**Algorithm A (Global nilpotency test via squarefree criterion).** To decide
whether the size-$n$ automaton is mortal: it is mortal iff $n$ is a power of two,
checkable in $O(\log n)$ by testing $n \,\&\, (n-1) = 0$. Equivalently, and as an
independent check, compute $g = \gcd(X^n - 1, \tfrac{d}{dX}(X^n - 1))$ over
$\mathbb{F}_2$; the automaton is mortal iff $X^n - 1 = (X+1)^n$, detectable by
verifying $g = X^n - 1$ (fully non-squarefree, single repeated prime).

**Algorithm B (Direct orbit simulation).** Given $n$ and a configuration $s$,
iterate $s \mapsto u \cdot s$ (a XOR of $s$ with its cyclic shift) and record the
first repeated state; the automaton is globally nilpotent iff the orbit of
*every* configuration terminates at $0$. Because $R_n$ has $2^n$ elements, an
exhaustive check is $O(2^n \cdot n)$; the algebraic test above avoids the
exponential blow-up.

**Algorithm C (Nilpotency index).** For $n = 2^k$, compute the least $N$ with
$u^N \equiv 0 \pmod{X^n - 1}$ by repeated squaring/multiplication; the answer is
provably $N = n$.

Full pseudocode and type-hinted implementations accompany this paper.

---

## 8. Applications and significance

1. **Exact classification of a Wolfram automaton.** A complete, if-and-only-if
   description of the long-term fate of an entire infinite family of automata,
   parameterized by lattice size.

2. **Computable relaxation time.** For mortal lattices the exact number of steps
   to extinction is $n$, giving a closed-form mixing/relaxation time rather than
   an asymptotic bound.

3. **A teachable bridge.** The result is a compact, fully elementary
   demonstration that dynamical, algebraic, and geometric notions can be
   *provably identical*, suitable as an illustration of how scheme-theoretic
   non-reducedness manifests concretely.

4. **A template for generalization.** The proof skeleton (Frobenius collapse,
   primality, derivative parity, square-root descent) transports verbatim to
   other characteristics and rules, as described next.

---

## 9. Future directions

1. **Nilpotency index / relaxation time.** We established the index is exactly
   $n$ for $n = 2^k$; a systematic study of relaxation times for the mixed case
   $n = 2^k m$ (odd $m > 1$) — where the automaton is not nilpotent but the fat
   part still decays — would quantify the transient before periodicity.

2. **General additive rules.** Replace $u = 1 + X$ by an arbitrary Laurent
   polynomial $p(X, X^{-1})$ (the full $\mathbb{F}_2$-linear ECA family: Rules
   90, 150, 60, …). Nilpotency of $p$ in $\mathbb{F}_2[X]/(X^n - 1)$ holds iff
   every irreducible factor of $X^n - 1$ divides $p$; the present result is the
   case $p = 1 + X$.

3. **Reducedness $\Leftrightarrow$ reversibility.** $X^n - 1$ is separable
   ($\mu_n$ étale/reduced) iff $n$ is odd; relate this to reversibility and cycle
   structure of the CA, and to the factorization of $X^n - 1$ into cyclotomic
   polynomials over $\mathbb{F}_2$ (governed by the multiplicative order of $2$
   modulo $d$ for $d \mid n$).

4. **Higher characteristic.** Everything transports to $\mathbb{F}_p$ with the
   rule $1 + X$: nilpotency holds iff $n$ is a power of $p$. The proof skeleton
   ($p$-th-power injectivity, derivative $p$-divisibility, prime-power divisors)
   generalizes directly.

5. **Two-dimensional / larger neighbourhoods.** Extend to
   $\mathbb{F}_2[X, Y]/(X^n - 1, Y^m - 1)$ and multivariate additive CAs,
   connecting nilpotency to the geometry of $\mu_n \times \mu_m$.

---

## 10. Conclusion

Starting from a childlike game on a necklace of black and white beads, we have
proved a sharp dichotomy — mortality iff power-of-two length — and shown it is one
theorem written in four alphabets: dynamics, algebra, geometry, and arithmetic.
The additive automaton dies out completely precisely when the roots-of-unity
scheme $\mu_n$ over $\mathbb{F}_2$ degenerates into a single non-reduced fat
point, precisely when $n$ is a power of the characteristic. The relaxation time
of the dying automaton measures the infinitesimal length of that fat point. Small
observations about a toy, it turns out, are shadows of foundational structure.
