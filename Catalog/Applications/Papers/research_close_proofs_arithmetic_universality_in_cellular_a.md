# Arithmetic Universality in Additive Cellular Automata via p-adic Renormalization

## Abstract

We develop a compact and complete algebraic theory of one-dimensional,
nearest-neighbour **additive** cellular automata (CAs) over the finite field
$\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$, $p$ prime. The central device is an
encoding of finitely supported bi-infinite configurations
$s : \mathbb{Z} \to \mathbb{F}_p$ as elements of the **Laurent polynomial ring**
$\mathbb{F}_p[T, T^{-1}]$, under which the additive nearest-neighbour rule (the
$\mathbb{F}_p$-analogue of Wolfram's *Rule 90*) becomes multiplication by the
single ring element $\mathrm{caOp} = T + T^{-1}$, and $t$-step time evolution
becomes the power $(\mathrm{caOp})^t$. Within this framework we establish five
results. (1) Evolution is $\mathbb{F}_p$-linear at every time step (additivity
and homogeneity), so the automaton obeys an exact superposition principle.
(2) The binomial theorem yields a closed generating function
$(T+T^{-1})^n = \sum_{k=0}^{n}\binom{n}{k}T^{2k-n}$, identifying the time-$n$
configuration with the $n$-th row of Pascal's triangle reduced mod $p$. (3) The
Frobenius ("freshman's dream") identity in characteristic $p$ gives the one-step
renormalization $(T+T^{-1})^p = T^p + T^{-p}$. (4) Iterating Frobenius gives the
renormalization tower $(T+T^{-1})^{p^k} = T^{p^k} + T^{-p^k}$, and (5) its
translation-covariant form $(\mathrm{caOp})^{p^k}\cdot T^a = T^{a+p^k}+T^{a-p^k}$.
Together these exhibit the additive CA as an exact renormalization-group fixed
point under scale-$p$ coarse-graining, identify its self-similarity with the
Frobenius endomorphism of $\mathbb{F}_p$, and explain the Sierpiński structure of
its space-time diagram. We close with a Lucas-theorem census of live cells and a
program of conjectures (sparsity counts, nonlinear extensions, two-dimensional
analogues) toward a general theory of *arithmetic universality* in local rules.

**Keywords:** cellular automata, additive automata, Rule 90, Laurent polynomial
ring, Frobenius endomorphism, characteristic $p$, renormalization group,
Sierpiński triangle, Lucas' theorem, finite fields.

---

## 1. Introduction

### 1.1 Background and motivation

Cellular automata (CAs) are among the simplest dynamical systems that exhibit
genuinely complex behaviour. A one-dimensional, nearest-neighbour CA is specified
by an alphabet $A$ and a local rule $f : A^3 \to A$ that computes the new value of
a cell from the cell and its two neighbours. Despite this minimal data, CAs span
the full range from trivial to computationally universal, and they have served as
models for everything from fluid turbulence to biological pattern formation.

A distinguished sub-family is the class of **additive** (or **linear**) CAs, in
which the alphabet is the finite field $\mathbb{F}_p$ and the local rule is an
$\mathbb{F}_p$-linear combination of the neighbouring cells. The archetype is the
$\mathbb{F}_2$ rule "new cell $=$ left neighbour $+$ right neighbour (mod 2),"
known in Wolfram's enumeration as **Rule 90**. Its space-time diagram, started
from a single live cell, reproduces the **Sierpiński triangle**, and the
appearance of this fractal is classically explained by the fact that Pascal's
triangle reduced modulo 2 has odd entries precisely on the Sierpiński set.

This paper formalizes and substantially generalizes that classical observation.
We treat *all* primes $p$ at once, we exhibit the entire space-time diagram (not
just the support) as an explicit element of a ring, and — the conceptual core — we
identify the self-similarity of the diagram with a precise
**renormalization-group fixed point** whose origin is the Frobenius endomorphism
of characteristic $p$. We call the resulting phenomenon **$p$-adic
renormalization**: coarse-graining the automaton by sampling every $p$ steps and
rescaling space by $p$ returns the automaton unchanged.

### 1.2 Contributions

1. A clean operator-algebraic model of additive nearest-neighbour CAs over
   $\mathbb{F}_p$ as multiplication in $\mathbb{F}_p[T,T^{-1}]$ (Section 2).
2. An exact superposition principle: evolution is additive and
   $\mathbb{F}_p$-homogeneous at every time step (Section 3).
3. The generating-function closed form realizing the diagram as Pascal's triangle
   mod $p$ (Section 4).
4. The renormalization theorems: one-step Frobenius collapse, the full tower, and
   its translation-covariant seed form (Section 5).
5. Concrete computational corollaries over $\mathbb{F}_2$ and $\mathbb{F}_3$, and
   a Lucas-theorem census of live cells (Sections 6–7).

All five results are theorems with complete proofs; the proofs sketched below
correspond to fully checked formal arguments depending only on the standard
foundational axioms.

---

## 2. The model

### 2.1 Configurations as Laurent polynomials

Let $p$ be prime and $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$. A **configuration**
is a finitely supported function $s : \mathbb{Z} \to \mathbb{F}_p$, assigning to
each lattice site $x$ a field value $s(x)$, with $s(x) = 0$ for all but finitely
many $x$.

**Definition 2.1 (State space).** The state space is the Laurent polynomial ring
$$ \mathrm{State}(p) \;:=\; \mathbb{F}_p[T, T^{-1}], $$
and a configuration $s$ is encoded as the Laurent polynomial
$$ \widehat{s}(T) \;=\; \sum_{x \in \mathbb{Z}} s(x)\, T^{x}. $$
The correspondence $s \mapsto \widehat{s}$ is an $\mathbb{F}_p$-vector-space
isomorphism between finitely supported configurations and $\mathbb{F}_p[T,T^{-1}]$.

Here $T$ is a formal indeterminate; multiplication by $T$ corresponds to a unit
shift of the configuration to the right and by $T^{-1}$ to a shift to the left.

**Lemma 2.2 (Characteristic).** $\mathrm{State}(p)$ has characteristic $p$.

*Proof sketch.* The structural ring homomorphism (algebra map)
$\mathbb{F}_p \to \mathbb{F}_p[T,T^{-1}]$ sending a scalar to the corresponding
constant polynomial is injective. Characteristic is preserved by injective ring
homomorphisms, and $\mathbb{F}_p$ has characteristic $p$; hence so does the
Laurent ring. $\square$

This lemma is indispensable: it is exactly the hypothesis that licenses the
Frobenius identity used throughout Section 5.

### 2.2 The evolution operator

**Definition 2.3 (CA operator).** The additive nearest-neighbour CA operator over
$\mathbb{F}_p$ is the element
$$ \mathrm{caOp}(p) \;:=\; T^{1} + T^{-1} \;\in\; \mathrm{State}(p). $$

The local rule "the new value of a cell is the sum of its two neighbours mod $p$"
is implemented by left multiplication by $\mathrm{caOp}(p)$: indeed,
$$
(T + T^{-1}) \cdot \sum_x s(x)\,T^x
= \sum_x s(x)\,T^{x+1} + \sum_x s(x)\,T^{x-1}
= \sum_x \big(s(x-1) + s(x+1)\big)\,T^{x},
$$
so the coefficient at site $x$ after one step is $s(x-1)+s(x+1)$, the sum of the
two neighbours. (For $p=2$ this is precisely Rule 90.)

**Definition 2.4 (Time evolution).** The $t$-step evolution of a configuration
$s$ is multiplication by the $t$-th power of the operator:
$$ \Phi^t(\widehat{s}) \;:=\; (\mathrm{caOp}(p))^{t}\cdot \widehat{s}, \qquad t \in \mathbb{N}. $$

The whole space-time diagram is therefore controlled by the single sequence of
ring elements $(\mathrm{caOp}(p))^t$, $t = 0, 1, 2, \dots$. The remainder of the
paper studies this sequence.

---

## 3. Linearity: the superposition principle

Because evolution is implemented by multiplication, the distributive and
scalar-compatibility laws of the ring immediately yield an exact superposition
principle.

**Theorem 3.1 (Additivity).** For all $t \in \mathbb{N}$ and all configurations
$s_1, s_2$,
$$ (\mathrm{caOp}\, p)^{t}\,(s_1 + s_2) \;=\; (\mathrm{caOp}\, p)^{t}\,s_1 \;+\; (\mathrm{caOp}\, p)^{t}\,s_2. $$

*Proof.* Left multiplication distributes over addition in any ring:
$a(b+c) = ab + ac$. Apply with $a = (\mathrm{caOp}\,p)^t$. (No primality of $p$ is
needed — this holds over any coefficient ring.) $\square$

**Theorem 3.2 (Homogeneity).** For all $t \in \mathbb{N}$, scalars
$c \in \mathbb{F}_p$, and configurations $s$,
$$ (\mathrm{caOp}\, p)^{t}\,(c \bullet s) \;=\; c \bullet \big((\mathrm{caOp}\, p)^{t}\, s\big), $$
where $\bullet$ is the scalar action of $\mathbb{F}_p$ on $\mathrm{State}(p)$.

*Proof.* The scalar action commutes with ring multiplication on the right
($a \cdot (c \bullet b) = c \bullet (a\cdot b)$ in a commutative algebra). Apply
with $a = (\mathrm{caOp}\,p)^t$. $\square$

**Remark 3.3.** Theorems 3.1–3.2 say the time-$t$ map is an
$\mathbb{F}_p$-module endomorphism of the configuration space for every $t$. This
is the decisive structural feature distinguishing additive CAs from generic
(nonlinear) CAs: arbitrary initial data decompose as $\mathbb{F}_p$-linear
combinations of single-cell seeds $T^a$, and the evolution of each seed is solved
exactly in Section 5. Knowing one seed determines everything.

---

## 4. The generating function: Pascal's triangle mod $p$

**Theorem 4.1 (Generating function).** For every $n \in \mathbb{N}$,
$$ (\mathrm{caOp}\, p)^{n} \;=\; \sum_{k=0}^{n} \binom{n}{k}\; T^{\,2k - n}. $$

*Proof sketch.* Expand $(T + T^{-1})^n$ by the binomial theorem:
$(T+T^{-1})^n = \sum_{k=0}^n \binom{n}{k} (T)^{k}\,(T^{-1})^{n-k}$. Using
$T^a T^b = T^{a+b}$ and the law of exponents, the exponent of the $k$-th term is
$k - (n-k) = 2k - n$. The binomial coefficient $\binom{n}{k}$ appears as a natural
number acting on the ring element $T^{2k-n}$ by repeated addition (the $n$-fold
scalar), which in $\mathbb{F}_p$ is reduction of $\binom{n}{k}$ modulo $p$. The
only subtlety is the exponent bookkeeping $n - k$ over $\mathbb{N}$: on the
summation range $0 \le k \le n$ the natural-number subtraction agrees with integer
subtraction, $(n-k : \mathbb{N}) = (n : \mathbb{Z}) - k$, which justifies the
exponent $2k - n$. $\square$

**Interpretation.** Theorem 4.1 says the time-$n$ configuration is exactly the
$n$-th row of Pascal's triangle, reduced modulo $p$, laid out on the lattice with
the $k$-th entry at site $2k - n$. The step of $2$ in the exponents reflects that
the rule couples only sites of equal parity: $\mathbb{Z}$ decomposes into an even
and an odd sublattice, and a single-cell seed lives on one of them at any fixed
time.

A live cell at site $x$ at time $n$ corresponds to $\binom{n}{(x+n)/2} \not\equiv 0
\pmod p$. Thus the *geometry* of the space-time diagram is encoded in the
*arithmetic* of binomial coefficients modulo $p$. For $p = 2$ this recovers the
classical identification of the odd entries of Pascal's triangle with the
Sierpiński gasket.

---

## 5. p-adic renormalization

This section contains the conceptual core. The key algebraic input is the
Frobenius identity in characteristic $p$.

**Lemma 5.1 (Freshman's dream / Frobenius).** In a commutative ring of
characteristic $p$,
$$ (a + b)^{p} = a^{p} + b^{p}, \qquad\text{and more generally}\qquad (a+b)^{p^k} = a^{p^k} + b^{p^k}. $$

*Proof sketch.* Expanding $(a+b)^p$ by the binomial theorem, every intermediate
coefficient $\binom{p}{j}$ for $0 < j < p$ is divisible by $p$ (since $p$ is prime
and appears in the numerator $p!$ but not the denominator $j!(p-j)!$), hence
vanishes in characteristic $p$; only the $j=0$ and $j=p$ terms survive. The
power-$p^k$ statement follows by iterating, i.e. by applying the map
$x \mapsto x^p$ (the Frobenius endomorphism) $k$ times. $\square$

### 5.1 One-step renormalization

**Theorem 5.2 (One-step collapse).**
$$ (\mathrm{caOp}\, p)^{p} \;=\; T^{\,p} + T^{\,-p}. $$

*Proof.* By Definition 2.3, $\mathrm{caOp}\,p = T^1 + T^{-1}$. By Lemma 2.2 the
ring has characteristic $p$, so Lemma 5.1 gives
$(T^1 + T^{-1})^p = (T^1)^p + (T^{-1})^p = T^p + T^{-p}$, using
$(T^a)^p = T^{ap}$. $\square$

Operationally: after exactly $p$ steps, a single seed at the origin becomes
exactly the pair of cells at $\pm p$. All the Pascal substructure built up over
the intermediate $p-1$ steps cancels in $\mathbb{F}_p$ — equivalently, every
interior binomial coefficient $\binom{p}{j}$, $0 < j < p$, is divisible by $p$.
The surviving terms are the two extreme rays of the light cone.

### 5.2 The renormalization tower

**Theorem 5.3 (Renormalization tower).** For every $k \in \mathbb{N}$,
$$ (\mathrm{caOp}\, p)^{\,p^{k}} \;=\; T^{\,p^{k}} + T^{\,-p^{k}}. $$

*Proof.* Apply the power-$p^k$ form of Lemma 5.1 to $T^1 + T^{-1}$:
$(T^1+T^{-1})^{p^k} = (T^1)^{p^k} + (T^{-1})^{p^k} = T^{p^k} + T^{-p^k}$. $\square$

**Renormalization-group reading.** Define the coarse-graining that samples the
dynamics only at times that are multiples of $p$ and rescales the spatial lattice
by the factor $p$. Theorem 5.3 with $k=1$ says the $p$-step evolution operator,
viewed after this rescaling, is again $T + T^{-1}$ — the *same* one-step operator.
The additive CA is therefore an **exact fixed point** of its scale-$p$
coarse-graining, and the fixed-point relation reproduces itself at every level
$p^k$. This is the algebraic source of the exact discrete scale invariance
(self-similarity) of the space-time diagram: magnifying the Sierpiński structure
by a factor of $p$ returns the identical structure, because the generating algebra
literally repeats with period $p$ in $\log$-time.

### 5.3 Translation covariance

**Theorem 5.4 (Seed evolution).** For every $k \in \mathbb{N}$ and every site
$a \in \mathbb{Z}$,
$$ (\mathrm{caOp}\, p)^{\,p^{k}} \cdot T^{a} \;=\; T^{\,a + p^{k}} + T^{\,a - p^{k}}. $$

*Proof.* Multiply Theorem 5.3 by $T^a$, distribute over the sum, and use
$T^{u}\cdot T^{a} = T^{u+a}$:
$(T^{p^k}+T^{-p^k})T^a = T^{p^k+a} + T^{-p^k+a} = T^{a+p^k} + T^{a-p^k}$. $\square$

Thus a single seed placed anywhere evolves, after $p^k$ steps, into exactly two
seeds symmetric about $a$ at distance $p^k$ — the renormalized light cone,
manifestly independent of where the origin is chosen.

---

## 6. Computational corollaries

The theorems specialize to fully explicit identities for small primes; these are
the concrete renormalization instances.

**Corollary 6.1 (Rule 90 over $\mathbb{F}_2$).**
$$ (\mathrm{caOp}\, 2)^{4} \;=\; T^{4} + T^{-4}. $$

*Proof.* Theorem 5.3 with $p=2$, $k=2$ gives
$(\mathrm{caOp}\,2)^{2^2} = T^{2^2} + T^{-2^2}$; evaluate $2^2 = 4$. $\square$

This is the cleanest visible signature of Sierpiński self-similarity: starting
from one cell, after $4 = 2^2$ steps the configuration is exactly two cells at
$\pm 4$.

**Corollary 6.2 (Additive CA over $\mathbb{F}_3$).**
$$ (\mathrm{caOp}\, 3)^{3} \;=\; T^{3} + T^{-3}. $$

*Proof.* Theorem 5.3 with $p=3$, $k=1$ gives
$(\mathrm{caOp}\,3)^{3^1} = T^{3^1}+T^{-3^1}$. $\square$

These are not isolated coincidences but the lowest rungs of the renormalization
tower of Theorem 5.3, instantiated at the two smallest primes.

---

## 7. A live-cell census via Lucas' theorem

The generating function (Theorem 4.1) reduces the population of the space-time
diagram to a counting problem about binomial coefficients modulo $p$, which Lucas'
theorem resolves in closed form.

**Lucas' theorem.** Write $t = \sum_i d_i p^i$ and $k = \sum_i e_i p^i$ in base
$p$. Then $\binom{t}{k} \equiv \prod_i \binom{d_i}{e_i} \pmod p$. In particular
$\binom{t}{k} \not\equiv 0 \pmod p$ iff $e_i \le d_i$ for every digit.

**Proposition 7.1 (Live-cell count).** The number of nonzero cells of
$(\mathrm{caOp}\,p)^t$ equals
$$ N_p(t) \;=\; \prod_i (d_i + 1), \qquad t = \sum_i d_i p^i. $$

*Proof sketch.* By Theorem 4.1 the live cells are in bijection with the indices
$0 \le k \le t$ for which $\binom{t}{k} \not\equiv 0 \pmod p$. By Lucas' theorem
these are exactly the $k$ whose base-$p$ digits $e_i$ satisfy $0 \le e_i \le d_i$
in every position, and the number of such digit strings is $\prod_i (d_i + 1)$. $\square$

**Corollary 7.2 (Sparsity at renormalized times).** $N_p(t) = 2$ if and only if
$t$ is a power of $p$, and then the support is exactly $\{-p^k, +p^k\}$.

*Proof.* $\prod_i (d_i+1) = 2$ forces exactly one nonzero digit equal to $1$ and
all others $0$, i.e. $t = p^k$. The support statement is Theorem 5.3. $\square$

Proposition 7.1 thus expresses the *combinatorial* density of the fractal as a
purely *arithmetic* quantity — a product over the base-$p$ digits of the time —
and recovers the renormalization collapse (Corollary 7.2) as the special case of
minimal digit sum. The diagram is sparsest precisely at the powers of $p$, and the
algebra predicts this from the carry structure of base-$p$ addition.

---

## 8. Discussion

### 8.1 Why the encoding works

The leverage of the entire theory comes from a single modelling decision: encode
configurations as elements of $\mathbb{F}_p[T,T^{-1}]$ so that the local rule is
*multiplication by a fixed element*. Three consequences follow at once. First,
linearity (Section 3) is automatic — it is the distributive law. Second, the full
space-time history is the orbit of powers of one element, so the binomial theorem
applies verbatim (Section 4). Third, the coefficient ring inherits characteristic
$p$, unlocking the Frobenius identity that drives renormalization (Section 5). A
direct pointwise model $\mathbb{Z} \to \mathbb{F}_p$ would require explicit
convolution bookkeeping at every step and would obscure all three structures; the
ring encoding makes them free.

### 8.2 Renormalization as Frobenius

The phrase "renormalization-group fixed point" is often associated with
approximate, asymptotic, or numerically observed scale invariance. The present
setting is unusual in that the fixed-point relation is *exact and elementary*: it
is literally the statement $(a+b)^p = a^p + b^p$, the Frobenius endomorphism of a
characteristic-$p$ ring. The conceptual content of this paper is the recognition
that the self-similarity of additive CAs — a fact from the theory of dynamical
systems and complexity — *is* the Frobenius map of number theory, viewed through
the polynomial encoding. The bridge runs in both directions: dynamical
self-similarity illuminates Frobenius, and Frobenius explains dynamical
self-similarity.

### 8.3 Relation to classical results

The $p=2$ case of Theorem 4.1 is the classical identity behind "Pascal's triangle
mod 2 = Sierpiński triangle." Proposition 7.1 is the cellular-automaton reading of
Lucas' theorem and of Kummer's theorem on $p$-adic valuations of binomial
coefficients. The novelty here is the *unified packaging*: one ring element, whose
powers give the whole diagram (Theorem 4.1), whose power-$p^k$ values collapse by
Frobenius (Theorems 5.2–5.4), and whose support is counted by digits
(Proposition 7.1) — all for every prime simultaneously, and all phrased as exact
identities in a single commutative ring.

### 8.4 Applications

Additive CAs underlie practical constructions in pseudorandom number generation,
built-in self-test for digital circuits, and certain error-correcting codes. The
renormalization tower (Theorem 5.3) characterizes exactly the times at which such
a device is maximally predictable (two live cells), and the generating function
(Theorem 4.1) gives a constant-memory closed form for the state at any time
without iterating the rule. Proposition 7.1 gives an $O(\log_p t)$ formula for the
Hamming weight of the time-$t$ state, useful for analyzing the statistical quality
of CA-based generators.

---

## 9. Future directions

**Direction 1 — Exact light-cone sparsity at renormalized times (Sierpiński
count).** We conjecture (and Proposition 7.1 establishes in the additive case)
that for every prime $p$ and every $k$, the number of nonzero cells of
$(\mathrm{caOp}\,p)^t$ is multiplicative in the base-$p$ digits of $t$, namely
$\prod_i (d_i + 1)$ where $t = \sum_i d_i p^i$; in particular it equals exactly
$2$ precisely when $t$ is a power of $p$, with support exactly $\{-p^k, p^k\}$. The
key insight is that the generating function reduces cell-occupancy to the
non-vanishing of $\binom{t}{k} \bmod p$, which Lucas' theorem turns into a
digit-wise product — so the combinatorial sparsity of the space-time diagram is a
purely arithmetic statement about carries in base $p$. The remaining program is to
promote the digit count to a full formalized account of the fractal dimension
$\log_p\!\big(\tfrac{p(p+1)}{2}\big)$ of the limiting set.

**Direction 2 — General additive rules and wider neighbourhoods.** Replace
$\mathrm{caOp} = T + T^{-1}$ by an arbitrary Laurent polynomial
$g(T) = \sum_j c_j T^j$ with $c_j \in \mathbb{F}_p$ (a general additive rule of
arbitrary radius). The generating function generalizes to the multinomial
expansion of $g(T)^n$, and $g(T)^{p^k} = g(T^{p^k})$ by Frobenius — a one-line
renormalization for *every* additive rule. The open problems concern the support
and periodicity of $g(T)^n$ for composite $n$, where Lucas-type theorems for
multinomials and the factorization of $g$ over $\mathbb{F}_p$ enter.

**Direction 3 — Prime-power and composite alphabets.** Over $\mathbb{Z}/p^m$ or
$\mathbb{Z}/N$ the freshman's dream fails, but graded/filtered versions persist
(e.g. $(a+b)^p \equiv a^p + b^p \bmod p$ lifts to congruences mod higher powers
controlled by Kummer's theorem). The goal is a renormalization "with corrections,"
quantifying how the clean two-ray collapse degrades as one moves from a field to a
ring with zero divisors.

**Direction 4 — Two and higher dimensions.** Encode $\mathbb{Z}^d$ configurations
in $\mathbb{F}_p[T_1^{\pm},\dots,T_d^{\pm}]$ and take $\mathrm{caOp}$ to be a sum
of monomials for the chosen neighbourhood. Frobenius again gives
$\mathrm{caOp}^{p^k}$ as the same polynomial with variables raised to $p^k$,
predicting higher-dimensional Sierpiński-type fractals (e.g. the
Sierpiński-carpet/Menger-sponge analogues) and their exact scaling. The
combinatorics becomes multidimensional Lucas counting.

**Direction 5 — Toward nonlinear arithmetic universality.** The deepest aim is to
identify nontrivial *nonlinear* local rules whose space-time generating functions
still encode recognizable arithmetic (beyond binomial coefficients), realizing the
original conjecture of arithmetic universality for a class strictly larger than the
additive one. The additive theory here is the fully solved beachhead: it shows the
encoding-and-Frobenius strategy is sound, and it provides exact baselines against
which nonlinear deviations can be measured.

---

## 10. Conclusion

By encoding additive cellular automata over $\mathbb{F}_p$ as multiplication in
the Laurent ring $\mathbb{F}_p[T,T^{-1}]$, we reduced their entire space-time
behaviour to the powers of a single element $\mathrm{caOp} = T + T^{-1}$. The
binomial theorem then exhibited the diagram as Pascal's triangle mod $p$, and the
Frobenius identity collapsed it, at every renormalized time $p^k$, to a pair of
light-cone rays $T^{p^k} + T^{-p^k}$. This identifies the self-similarity of these
automata with the Frobenius endomorphism of prime arithmetic, casts their scaling
behaviour as an exact renormalization-group fixed point, and counts their live
cells by a digit product via Lucas' theorem. The additive case is thereby
completely understood, and it stands as a precise, fully proved template for the
broader program of arithmetic universality in local dynamical rules.
