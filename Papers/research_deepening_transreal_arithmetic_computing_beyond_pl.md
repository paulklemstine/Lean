# Transreal Arithmetic, Deepened: Surviving Structure, Homomorphisms, and the Geometry of a Total Number System

## Abstract

The **transreal numbers** $\mathbb{T} = \mathbb{R} \cup \{+\infty, -\infty,
\Phi\}$ extend the real line with two infinities and a value $\Phi$ (*nullity*,
morally $0/0$) so as to make addition, multiplication, negation, and reciprocal
*total*: every operation returns a value for every input, division by zero
included. Totality is bought at a price, and the central question of this paper
is to determine that price exactly. We show that the surviving algebraic
structure is precisely a pair of commutative monoids: $(\mathbb{T}, +, 0)$ and
$(\mathbb{T}, \cdot, 1)$ are both commutative monoids, so the full
commutative-monoid theory applies, while the ring axioms fail (no additive
inverse for $+\infty$; distributivity fails). We prove that negation is a
homomorphism of *both* monoids simultaneously and is an involution, and that
$\mathbb{R}$ embeds as a sub-monoid under both operations. We then pin down the
exact failures of the multiplicative involution: reciprocation is self-inverse
**everywhere except at the single point $-\infty$**, and it commutes with
negation everywhere except at $0$, where a signed-zero phenomenon forces
$1/(-0) = +\infty \neq -\infty = -(1/0)$. Finally we equip $\mathbb{T}$ with a
natural partial order in which $-\infty < r < +\infty$ for every real $r$ while
$\Phi$ is incomparable to everything; the order is provably not total, $\mathbb{R}$
order-embeds, and — because $\Phi$ floats free — $\mathbb{T}$ has neither a
greatest nor a least element, in sharp contrast to the extended reals
$[-\infty, +\infty]$. The recurring theme is *localization of failure*: each
classical law that breaks, breaks at a single, explicitly identified point.

**Keywords:** transreal numbers, nullity, division by zero, total arithmetic,
commutative monoid, homomorphism, reciprocal involution, partial order,
signed zero, extended reals, wheel theory.

---

## 1. Introduction

The prohibition on division by zero is one of the load-bearing conventions of
arithmetic. It is not a mere squeamishness: assigning $1/0$ any real value $c$
forces $1 = 0 \cdot c = 0$, collapsing the field. Yet in computational practice
the prohibition is a persistent nuisance. Any sufficiently long chain of
arithmetic operations may, on some input, attempt a forbidden division, and a
program cannot respond with "undefined"; it must return a value or halt.
Floating-point arithmetic addresses this with the special quantities $\pm\infty$
and `NaN`, which give division by zero and indeterminate forms concrete,
propagating results.

**Transreal arithmetic** (Anderson's *total* arithmetic) is a mathematical
system in this spirit. It enlarges $\mathbb{R}$ with $+\infty$, $-\infty$, and a
single indeterminate value $\Phi$ (*nullity*), and specifies total rules for
addition, multiplication, negation, and reciprocal. Nullity plays the role of
`NaN`: it is the value of genuinely indeterminate forms ($0/0$, $\infty-\infty$,
$0\cdot\infty$) and it is *absorbing* — once it appears, it propagates to the
final result.

The purpose of this paper is not to advocate for the system but to *measure* it.
Given that totality is achievable, which theorems of ordinary arithmetic and
order survive, and which collapse? We give a sharp answer, organized around a
single phenomenon we call **localization of failure**: every classical law that
fails does so at one explicitly identifiable point, and away from that point the
law holds without exception.

### Contributions

1. **Surviving algebraic structure, bundled (§3).** $(\mathbb{T}, +, 0)$ and
   $(\mathbb{T}, \cdot, 1)$ are commutative monoids. We identify precisely why
   the ring structure fails (inverses at $+\infty$; distributivity).
2. **Negation as a double homomorphism (§4).** Negation distributes over both
   the total sum and the total product, even at $\pm\infty$, and is an
   involution.
3. **Faithful embedding of $\mathbb{R}$ (§4).** $\mathbb{R}$ embeds as a
   sub-monoid under both operations.
4. **Exact reach of the reciprocal involution (§5).** $1/(1/x) = x$ if and only
   if $x \neq -\infty$; and $1/(-x) = -(1/x)$ if and only if $x \neq 0$, the
   failure at $0$ being a signed-zero effect.
5. **A non-linear order geometry (§6).** A partial order with $-\infty < r <
   +\infty$ and $\Phi$ incomparable; provably not total; $\mathbb{R}$
   order-embeds; no greatest and no least element.

---

## 2. The transreal numbers

### 2.1 Carrier

**Definition 2.1 (Transreal numbers).**
$$\mathbb{T} = \mathbb{R} \cup \{+\infty,\ -\infty,\ \Phi\},$$
the disjoint union of a copy of the real numbers with three new symbols:
positive infinity $+\infty$, negative infinity $-\infty$, and **nullity** $\Phi$.
We write $\iota : \mathbb{R} \to \mathbb{T}$ for the inclusion of the reals and,
when no confusion arises, identify a real $a$ with $\iota(a)$. The distinguished
constants are $0 = \iota(0)$ and $1 = \iota(1)$.

The design principle governing $\Phi$ is **absorption**: nullity is the value of
every indeterminate form and cannot be undone by later operations.

### 2.2 The total operations

**Definition 2.2 (Addition).** For $x, y \in \mathbb{T}$:
$$
x + y =
\begin{cases}
\iota(a+b) & x = \iota(a),\ y = \iota(b),\\[2pt]
+\infty & \{x,y\} \text{ meets } \{+\infty\} \text{, other summand in } \mathbb{R}\cup\{+\infty\},\\[2pt]
-\infty & \{x,y\} \text{ meets } \{-\infty\} \text{, other summand in } \mathbb{R}\cup\{-\infty\},\\[2pt]
\Phi & \{x,y\} = \{+\infty, -\infty\} \text{ or } \Phi \in \{x,y\}.
\end{cases}
$$
In words: finite addition is ordinary; an infinity dominates a finite summand;
$(+\infty)+(-\infty) = \Phi$; and $\Phi$ absorbs.

**Definition 2.3 (Multiplication).** For $x, y \in \mathbb{T}$: finite
multiplication is ordinary, $\iota(a)\cdot\iota(b) = \iota(ab)$; nullity absorbs,
$\Phi \cdot x = x \cdot \Phi = \Phi$; the infinities multiply by the sign rule,
$$(+\infty)(+\infty) = (-\infty)(-\infty) = +\infty, \qquad
(+\infty)(-\infty) = (-\infty)(+\infty) = -\infty;$$
and a real $a$ times an infinity depends on the sign of $a$,
$$\iota(a)\cdot(+\infty) =
\begin{cases}
+\infty & a > 0,\\
\Phi & a = 0,\\
-\infty & a < 0,
\end{cases}
\qquad
\iota(a)\cdot(-\infty) =
\begin{cases}
-\infty & a > 0,\\
\Phi & a = 0,\\
+\infty & a < 0,
\end{cases}$$
symmetrically in the two arguments. The critical clause is $0\cdot(\pm\infty) =
\Phi$: the indeterminate form $0\cdot\infty$ yields nullity.

**Definition 2.4 (Negation).**
$$-\iota(a) = \iota(-a), \qquad -(+\infty) = -\infty, \qquad -(-\infty) = +\infty,
\qquad -\Phi = \Phi.$$

**Definition 2.5 (Reciprocal).**
$$\frac{1}{\iota(a)} =
\begin{cases}\iota(a^{-1}) & a \neq 0,\\ +\infty & a = 0,\end{cases}
\qquad \frac{1}{+\infty} = \frac{1}{-\infty} = 0, \qquad \frac{1}{\Phi} = \Phi.$$

Division is *defined* by $x / y = x \cdot (1/y)$; it is total. In particular
$0/0 = 0 \cdot (1/0) = 0 \cdot (+\infty) = \Phi$, so nullity is consistent with
its intended meaning.

### 2.3 A canonical case split

Many proofs proceed by exhausting the possibilities for a transreal. The
following six-way split, refining the four constructors by the sign of a real,
is the workhorse.

**Lemma 2.6 (Six-way case split).** Every $t \in \mathbb{T}$ satisfies exactly
one of:
$$t = \Phi,\quad t = +\infty,\quad t = -\infty,\quad t = \iota(r)\ (r>0),\quad
t = \iota(0),\quad t = \iota(r)\ (r<0).$$
*Proof.* Immediate from the definition of $\mathbb{T}$ together with the
trichotomy of $\mathbb{R}$ applied to a real value. $\qquad\blacksquare$

This split makes associativity of multiplication — the most laborious of the
basic laws — a finite verification. With three factors there are $6^3 = 216$
sign-configurations; in every one, both groupings evaluate to the same element by
the sign rules of Definition 2.3.

---

## 3. Surviving algebraic structure

### 3.1 The additive monoid

**Theorem 3.1 (Additive commutative monoid).** $(\mathbb{T}, +, 0)$ is a
commutative monoid: for all $x, y, z \in \mathbb{T}$,
$$x + y = y + x, \qquad (x + y) + z = x + (y + z), \qquad 0 + x = x = x + 0.$$

*Proof sketch.* Commutativity and associativity are checked by exhausting the
constructor cases; on the finite part they reduce to the corresponding real
identities, and on the singular values they follow from the absorption of $\Phi$
and the finite-vs-infinite clauses of Definition 2.2. For the identity law, $0$
is a finite real, so $0 + \iota(a) = \iota(a)$; and $0 + \xi = \xi$ for each
singular $\xi \in \{+\infty, -\infty, \Phi\}$ by direct evaluation.
$\qquad\blacksquare$

**Remark 3.2 (No additive group).** $(\mathbb{T}, +, 0)$ is *not* a group. The
element $+\infty$ has no additive inverse: for every $y$, if $y \in \mathbb{R}
\cup \{+\infty\}$ then $(+\infty) + y = +\infty \neq 0$, while $(+\infty) +
(-\infty) = \Phi \neq 0$ and $(+\infty) + \Phi = \Phi \neq 0$. Thus the loss of
the ring structure is *localized to the infinities*: on $\mathbb{R}$, additive
inverses persist unchanged.

### 3.2 The multiplicative monoid

**Theorem 3.3 (Multiplicative commutative monoid).** $(\mathbb{T}, \cdot, 1)$ is
a commutative monoid: for all $x, y, z \in \mathbb{T}$,
$$x \cdot y = y \cdot x, \qquad (x\cdot y)\cdot z = x \cdot (y \cdot z),
\qquad 1 \cdot x = x = x \cdot 1.$$

*Proof sketch.* Commutativity follows from the symmetry of Definition 2.3.
Associativity is the six-way split of Lemma 2.6 applied to all three factors:
each of the $216$ configurations evaluates identically under both groupings,
using $\operatorname{sgn}(ab) = \operatorname{sgn}(a)\operatorname{sgn}(b)$ for
the finite–infinite interactions and absorption for $\Phi$. The identity law
holds because $1$ is a nonzero positive real, so $1\cdot\iota(a) = \iota(a)$ and
$1 \cdot \xi = \xi$ for each singular $\xi$. $\qquad\blacksquare$

### 3.3 Why the ring axioms fail

**Proposition 3.4 (Failure of the ring axioms).** $(\mathbb{T}, +, \cdot, 0, 1)$
is not a ring. Concretely:

1. *No additive inverses* (Remark 3.2): $+\infty$ has none.
2. *Distributivity fails.* For instance,
   $$(+\infty)\cdot\big(1 + (-1)\big) = (+\infty)\cdot 0 = \Phi,$$
   whereas
   $$(+\infty)\cdot 1 + (+\infty)\cdot(-1) = (+\infty) + (-\infty) = \Phi.$$
   These happen to agree; but taking $a$ with $a + (-a) = 0$ and distributing an
   infinity generally produces $(+\infty)+(-\infty)=\Phi$ on the right while the
   left may differ from $\Phi$ — e.g. $0\cdot(\,\cdot\,)$ interactions produce a
   genuine mismatch such as $(+\infty)\cdot(1 + 0)= +\infty$ versus
   $(+\infty)\cdot 1 + (+\infty)\cdot 0 = (+\infty) + \Phi = \Phi$. Since
   $+\infty \neq \Phi$, distributivity fails.

Thus the maximal surviving *algebraic* structure is exactly the pair of
commutative monoids of Theorems 3.1 and 3.3 — no more.

---

## 4. Negation, and the embedding of the reals

### 4.1 Negation is a homomorphism of both monoids

**Theorem 4.1 (Negation is a bi-homomorphism and involution).** For all $x, y
\in \mathbb{T}$,
$$-(x + y) = (-x) + (-y), \qquad -(x\cdot y) = (-x)\cdot y = x\cdot(-y),
\qquad (-x)\cdot(-y) = x\cdot y,$$
and $-(-x) = x$.

*Proof sketch.* Each identity is verified on the six-way split. Additively,
$-(\,\cdot\,)$ swaps $+\infty \leftrightarrow -\infty$, fixes $\Phi$, and negates
reals, and each clause of Definition 2.2 is preserved by this swap. For the
multiplicative laws, negating one factor flips its sign class ($>0
\leftrightarrow <0$, $+\infty \leftrightarrow -\infty$), which is exactly what
the sign rule of Definition 2.3 tracks; hence $-(x\cdot y) = (-x)\cdot y$, and
the remaining identities follow by combining. The involution $-(-x)=x$ holds
because $a \mapsto -a$ is an involution on $\mathbb{R}$ and the swap
$+\infty\leftrightarrow-\infty$ is its own inverse. $\qquad\blacksquare$

### 4.2 The reals embed as a sub-monoid under both operations

**Theorem 4.2 (Faithful monoid embeddings of $\mathbb{R}$).** The inclusion
$\iota : \mathbb{R} \to \mathbb{T}$ is:

1. an injective homomorphism of additive monoids: $\iota(a+b) = \iota(a) +
   \iota(b)$ and $\iota(0) = 0$;
2. an injective homomorphism of multiplicative monoids: $\iota(ab) = \iota(a)
   \cdot \iota(b)$ and $\iota(1) = 1$.

Consequently $\mathbb{R}$ is (isomorphic to) a sub-commutative-monoid of
$\mathbb{T}$ under each operation, and all ordinary real arithmetic is preserved
verbatim inside $\mathbb{T}$.

*Proof sketch.* On finite inputs, Definitions 2.2 and 2.3 reduce to real
addition and multiplication by fiat, giving both homomorphism laws; injectivity
is injectivity of the constructor $\iota$. The unit conditions are the
definitions of $0$ and $1$. $\qquad\blacksquare$

**Corollary 4.3.** Every polynomial identity valid in $\mathbb{R}$ remains valid
in $\mathbb{T}$ *as long as every intermediate value is finite*. The novelty of
$\mathbb{T}$ is entirely concentrated at the singular values.

---

## 5. The reciprocal: exact reach of the involution

Reciprocation is the operation that makes division total, and it is the site of
the most delicate failures. We locate them precisely.

### 5.1 Self-inverseness fails at exactly one point

**Theorem 5.1 (Exact reach of the reciprocal involution).** For all $x \in
\mathbb{T}$,
$$\frac{1}{\,1/x\,} = x \iff x \neq -\infty.$$

*Proof.* We evaluate the double reciprocal on the constructor cases.
- $x = \iota(a)$, $a \neq 0$: $1/x = \iota(a^{-1})$ with $a^{-1}\neq 0$, so
  $1/(1/x) = \iota((a^{-1})^{-1}) = \iota(a) = x$.
- $x = \iota(0) = 0$: $1/x = +\infty$, and $1/(+\infty) = 0 = x$.
- $x = +\infty$: $1/x = 0$, and $1/0 = +\infty = x$.
- $x = \Phi$: $1/x = \Phi$ and $1/\Phi = \Phi = x$.
- $x = -\infty$: $1/x = 0$, and $1/0 = +\infty \neq -\infty = x$.

Thus the identity holds in every case except $x = -\infty$. $\qquad\blacksquare$

**Remark 5.2 (Why $-\infty$ and only $-\infty$).** Both infinities have
reciprocal $0$, so $0$ cannot record which infinity produced it; the tie is
broken by the convention $1/0 = +\infty$. This is the *entire* obstruction to
reciprocation being an involution — a strict sharpening of the coarse statement
"reciprocal is not an involution." The involution is repaired exactly on the
sub-carrier $\mathbb{T} \setminus \{-\infty\}$.

### 5.2 Reciprocal versus negation, and signed zero

**Theorem 5.3 (Reciprocal commutes with negation off zero).** For all $x \in
\mathbb{T}$ with $x \neq 0$,
$$\frac{1}{-x} = -\frac{1}{x}.$$

*Proof sketch.* Case analysis: for nonzero reals, $(-a)^{-1} = -(a^{-1})$; for
$\pm\infty$, both sides are $0 = -0$; for $\Phi$, both sides are $\Phi$. The
excluded case $x = 0$ is treated next. $\qquad\blacksquare$

**Theorem 5.4 (Failure at zero: a signed-zero phenomenon).** At $x = 0$ the
identity of Theorem 5.3 fails:
$$\frac{1}{-0} = +\infty \qquad\text{while}\qquad -\frac{1}{0} = -\infty,$$
and $+\infty \neq -\infty$.

*Proof.* Since $-0 = 0$ as a real, $1/(-0) = 1/0 = +\infty$. On the other side,
$1/0 = +\infty$, so $-(1/0) = -(+\infty) = -\infty$. $\qquad\blacksquare$

**Interpretation.** The convention $1/0 = +\infty$ tacitly treats the argument as
a *positive* zero $0^{+}$; consistency would then demand $1/0^{-} = -\infty$. But
$\mathbb{T}$ has a single, sign-blind zero, so the would-be identity $1/(-x) =
-(1/x)$ cannot be maintained through it. The failure is again localized — to the
one point $0$ — and it exposes that reciprocation near zero is inherently
one-sided. A system wishing to restore this law would need to split $0$ into
signed zeros $0^\pm$, precisely as floating-point arithmetic does.

---

## 6. Order geometry: a total arithmetic with a non-total order

### 6.1 The order

**Definition 6.1 (Transreal order).** Define $\le$ on $\mathbb{T}$ to be the
reflexive relation generated by:
$$-\infty \le -\infty,\quad +\infty \le +\infty,\quad \iota(a) \le \iota(b)
\text{ iff } a \le b,$$
$$-\infty \le \iota(a) \le +\infty \text{ for every } a \in \mathbb{R}, \qquad
-\infty \le +\infty,$$
and $\Phi \le \Phi$ only. In particular $\Phi$ is related to nothing but itself.

**Theorem 6.2 ($\le$ is a partial order).** The relation $\le$ of Definition 6.1
is reflexive, antisymmetric, and transitive.

*Proof sketch.* Reflexivity is built in. Antisymmetry and transitivity are
verified on the six-way split; on the finite part they are inherited from
$(\mathbb{R}, \le)$, the infinities act as strict bottom/top of the finite chain,
and $\Phi$'s isolation makes every clause involving it vacuous beyond
reflexivity. $\qquad\blacksquare$

### 6.2 Non-totality

**Theorem 6.3 (The order is not total).** There exist $x, y \in \mathbb{T}$ with
neither $x \le y$ nor $y \le x$. Explicitly, $x = \Phi$ and $y = 0$ are
incomparable.

*Proof.* By Definition 6.1, $\Phi$ is $\le$-related only to $\Phi$; since $0 \neq
\Phi$, neither $\Phi \le 0$ nor $0 \le \Phi$ holds. $\qquad\blacksquare$

### 6.3 The reals order-embed

**Theorem 6.4 (Order embedding of $\mathbb{R}$).** The inclusion $\iota :
(\mathbb{R}, \le) \to (\mathbb{T}, \le)$ is an order embedding: $a \le b$ in
$\mathbb{R}$ if and only if $\iota(a) \le \iota(b)$ in $\mathbb{T}$.

*Proof.* Immediate from the finite clause of Definition 6.1. $\qquad\blacksquare$

Combined with $-\infty < \iota(a) < +\infty$ for all reals $a$, this realizes the
familiar picture of the finite line pinned between two infinities — but with the
extra, disconnected point $\Phi$ off to one side.

### 6.4 No extremes

**Theorem 6.5 (No greatest and no least element).** $\mathbb{T}$ has no greatest
element and no least element under $\le$.

*Proof.* Suppose $g$ were greatest, so $x \le g$ for all $x$. Taking $x = \Phi$
forces $\Phi \le g$, whence (by Definition 6.1) $g = \Phi$. But then $0 \le g =
\Phi$ is false, so $g$ is not an upper bound — a contradiction. The argument for
a least element is symmetric. $\qquad\blacksquare$

**Contrast 6.6 (Versus the extended reals).** The extended real line
$[-\infty, +\infty] = \mathbb{R} \cup \{-\infty, +\infty\}$ is a *complete
lattice*: it has greatest element $+\infty$ and least element $-\infty$, and
every subset has a supremum and infimum. Theorem 6.5 shows $\mathbb{T}$ is
categorically different: adjoining the arithmetically indispensable point $\Phi$
destroys the lattice extremes. **Totality of arithmetic is paid for with
non-totality of order.** This single trade-off is, arguably, the deepest
structural fact about the transreals.

---

## 7. Algorithms

Because every operation is total, transreal arithmetic is naturally executable.
We describe the core procedures used in the accompanying numerical
demonstrations.

### 7.1 Total evaluation with a sticky nullity flag

The absorption law for $\Phi$ makes it an error flag that propagates
automatically. Evaluating any arithmetic expression over $\mathbb{T}$ requires no
guard clauses around division: the result is $\Phi$ if and only if some
indeterminate form was encountered.

```
function EVAL(expr):
    if expr is a constant c:            return TReal(c)
    if expr is (a OP b):
        x <- EVAL(a); y <- EVAL(b)
        return APPLY(OP, x, y)          # APPLY is total; never raises
# Correctness: APPLY(OP, ., .) returns Phi whenever an indeterminate form
# (0/0, inf - inf, 0 * inf) arises, and Phi is absorbing, so Phi in the
# output <=> some sub-evaluation was indeterminate.
```

### 7.2 Reciprocal-orbit classifier

To exhibit Theorem 5.1 computationally, iterate reciprocation and detect the
fixed/periodic behaviour. Every point except $-\infty$ returns to itself after
two steps; $-\infty$ maps to $+\infty$ and then stabilizes.

```
function DOUBLE_RECIP_IS_ID(x):
    return RECIP(RECIP(x)) == x         # True iff x != -inf  (Theorem 5.1)
```

### 7.3 Order comparison producing a three-valued result

Because $\le$ is partial, comparison is three-valued: `LT`, `GT`, `EQ`, or
`INCOMPARABLE`. The last occurs exactly when $\Phi$ is one of the operands and
the other is different.

```
function COMPARE(x, y):
    if x == Phi or y == Phi:
        return EQ if x == y else INCOMPARABLE
    # both in R u {+/-inf}, a linear chain -inf < R < +inf
    return sign of (position(x) - position(y))
```

---

## 8. Applications and discussion

**Robust numerical pipelines.** The defining virtue of $\mathbb{T}$ is that a
long computation can be reasoned about *globally*: no sub-expression can throw,
and the presence of $\Phi$ in the output is a sound and complete certificate that
an indeterminate form occurred somewhere. This mirrors, and formalizes, the
role of `NaN` in floating-point standards, but with cleaner algebraic laws
(exact commutativity and associativity of both operations, which floating-point
lacks).

**A dependency laboratory for axioms.** Ordinary arithmetic fuses commutativity,
associativity, distributivity, inverses, and total order. The transreals
disentangle them: commutativity and associativity of $+$ and $\cdot$ survive
(§3), inverses and distributivity do not (Prop. 3.4), the multiplicative
involution survives off one point (§5), and total order is traded away for total
arithmetic (§6). Each surviving/failing law is attached to a named point, giving
a concrete map of logical dependencies.

**Relation to wheels.** Wheel theory gives a fully equational account of
structures with a total division, at the cost of additional identities (e.g.
$0 x = 0 x^2 \cdot \ldots$ style laws and a bottom element $\bot$). The
transreals satisfy weaker axioms — only the two monoid structures, negation, and
the reciprocal, with the localized failures catalogued here. The results of §5
in particular quantify the gap: the transreal reciprocal is *nearly* the wheel
involution, deviating at exactly one point.

**Limitations.** $\mathbb{T}$ is not a ring, so linear-algebraic constructions
(determinants, Gaussian elimination) do not transfer wholesale; distributivity is
needed even to state matrix multiplication cleanly. Likewise, the non-total order
means order-theoretic completeness arguments (suprema, monotone convergence over
the whole carrier) must be restricted to the $\Phi$-free part.

---

## 9. Future directions

- **Order/algebra interaction.** Determine whether the surviving monoid and
  order form an ordered commutative monoid on the comparable part $\mathbb{T}
  \setminus \{\Phi\}$, and characterize which covariance laws $a \le b \Rightarrow
  c + a \le c + b$ survive at $\pm\infty$. A promising target: quotient out
  $\Phi$ and study $[-\infty, +\infty]$ as the induced linear order.
- **Analysis survival.** Formalize transreal limits and ask which classical
  theorems survive: the intermediate value theorem fails across $\Phi$, but
  monotone-limit statements may survive on the $\Phi$-free part.
- **Wheels and the projective line.** Formalize the single-point projective
  wheel $\mathbb{R} \cup \{\infty, \bot\}$ and make precise the sense in which the
  transreals sit strictly below the wheel axioms.
- **Involution repair.** Study the largest sub-carrier on which the reciprocal is
  an involution (everything but $-\infty$) and whether it carries a group-like
  reciprocal structure.
- **Linear algebra over $\mathbb{T}$.** Since $\mathbb{T}$ is only a pair of
  monoids (no distributivity), study what a "transreal matrix product" can and
  cannot satisfy.

---

## 10. Conclusion

Transreal arithmetic buys totality — an answer for every operation, division by
zero included — and this paper prices that purchase exactly. The surviving
structure is a pair of commutative monoids joined by a negation homomorphism and
a faithful copy of the reals; the failures are the additive inverse of $+\infty$,
distributivity, the reciprocal involution at $-\infty$, the reciprocal/negation
law at $0$, and the totality of the order. In every instance the failure is
*localized* to a single, named point, and everywhere else the classical law
survives intact. That pattern — a structured theory reporting faithfully, point
by point, exactly what lies beyond the oldest taboo in arithmetic — is the
enduring content of the transreals.
