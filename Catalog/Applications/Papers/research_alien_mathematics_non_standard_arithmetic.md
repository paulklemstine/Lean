# The Finite Chain Semiring: Non-Standard Arithmetic from a Bounded Distributive Lattice

**Author:** Aristotle

**Date:** 2026-06-21

**Domain:** Novelty / Non-Standard Arithmetic

---

## Abstract

We study a family of non-standard arithmetics obtained by equipping a finite
totally ordered set — a *chain* — with the algebraic operations induced by its
lattice structure. For the canonical $(n+1)$-element chain $\mathrm{Fin}(n+1) =
\{0, 1, \dots, n\}$ we define addition as the join $\oplus = \max$ and
multiplication as the meet $\otimes = \min$, with additive identity the bottom
element $0 = \bot$ and multiplicative identity the top element $1 = \top = n$. We
prove that this structure is a commutative semiring, deriving every algebraic
axiom from order properties alone, with no circular dependence on a pre-existing
semiring instance. The resulting arithmetic is *idempotent* ($x \oplus x = x$,
$x \otimes x = x$) and *additively non-invertible*: when the chain has at least
two elements, the multiplicative unit $\top$ has no additive inverse, so the
semiring is never a ring. We situate this construction within the landscape of
tropical and idempotent algebra, exhibit its isomorphism with finite multi-valued
(fuzzy) logic, catalogue precisely which classical arithmetic theorems survive
the transfer to this non-Archimedean setting, and survey computational and
conjectural directions, including lunar arithmetic over the chain semiring.
All results have been formally verified.

---

## 1. Introduction

A persistent question in the study of non-standard models of arithmetic is:
*which classical theorems survive when the rules change?* Tropical mathematics
offers one of the most fruitful answers. By replacing ordinary addition with a
"choose the better option" operation (`min` or `max`) and ordinary
multiplication with `+`, one transports problems from nonlinear into
piecewise-linear regimes, where they often become algorithmically tractable. The
price is that the resulting algebraic objects are *semirings*, not rings: they
lack additive inverses, and the familiar machinery of subtraction and
cancellation disappears.

This paper isolates the purest possible instance of such a phenomenon. Rather
than the (infinite) tropical semiring over $\mathbb{R} \cup \{\pm\infty\}$, we
work over a *finite chain* and replace *both* operations by lattice operations:
addition is the join $\max$ and multiplication is the meet $\min$. The result is
finite, decidable, and entirely combinatorial, yet it reproduces the essential
"alien" features of non-standard arithmetic: idempotent addition, an inverted
notion of the multiplicative unit (the unit is the *largest* element), and the
total failure of subtraction.

Our contributions are:

1. A self-contained derivation of all commutative-semiring axioms for
   $(\mathrm{Fin}(n+1), \max, \min, \bot, \top)$ from order properties alone
   (§3–§4), culminating in an assembled `CommSemiring` structure (§4.7).
2. A precise *survival theorem* (§5) cataloguing which classical arithmetic laws
   transfer to the chain semiring and which fail, with the failure of additive
   invertibility (§4.6) as the sharp dividing line.
3. The identification of the chain semiring with finite Łukasiewicz-style
   multi-valued logic / fuzzy logic (§6), and its place in the hierarchy of
   idempotent and tropical semirings (§7).
4. Algorithms for computing in, and verifying, the chain semiring (§8), and a
   discussion of lunar arithmetic built over it (§9), with conjectural future
   directions (§10).

---

## 2. Preliminaries and notation

Let $n \in \mathbb{N}$. The carrier is the finite chain
$$C_n := \mathrm{Fin}(n+1) = \{0, 1, 2, \dots, n\},$$
the canonical totally ordered set with $n+1$ elements. We write $\le$ for its
linear order, $\bot = 0$ for the least element, and $\top = n$ for the greatest.
For $x, y \in C_n$ we write
$$x \vee y := \max(x,y), \qquad x \wedge y := \min(x,y)$$
for the join and meet.

A **commutative semiring** is a tuple $(R, +, \cdot, 0, 1)$ such that $(R,+,0)$
is a commutative monoid, $(R,\cdot,1)$ is a commutative monoid, multiplication
distributes over addition on both sides, and $0$ is absorbing for multiplication
($0 \cdot a = a \cdot 0 = 0$). Unlike a ring, no additive inverses are required.

A **bounded distributive lattice** is a partially ordered set with finite meets
and joins, top and bottom elements, in which meet distributes over join (and
dually). Every linear order is a distributive lattice, and a finite linear order
is bounded; thus $C_n$ is a bounded distributive lattice. The central theme of
this paper is the standard but underexploited fact that *every bounded
distributive lattice is a commutative semiring* under $(\vee, \wedge, \bot,
\top)$, made fully explicit and verified for the chain.

---

## 3. Order-theoretic lemmas (the foundation)

All semiring axioms are reduced to the following order facts, each of which holds
in any linear order and in particular in $C_n$. We state them with their roles in
the eventual semiring.

### 3.1 Associativity and commutativity

**Lemma 3.1 (`max_assoc'`, `max_comm'`).** For all $x,y,z \in C_n$,
$$\max(\max(x,y),z) = \max(x,\max(y,z)), \qquad \max(x,y) = \max(y,x).$$

**Lemma 3.2 (`min_assoc'`, `min_comm'`).** For all $x,y,z \in C_n$,
$$\min(\min(x,y),z) = \min(x,\min(y,z)), \qquad \min(x,y) = \min(y,x).$$

*Proof sketch.* In a linear order the maximum of a finite multiset is determined
by the multiset alone, independent of association and order; symmetrically for
the minimum. These are the lattice axioms for $\vee$ and $\wedge$. $\qquad\blacksquare$

### 3.2 Distributivity

**Lemma 3.3 (`max_min_distrib`).** For all $x,y,z \in C_n$,
$$\max\!\big(x, \min(y,z)\big) = \min\!\big(\max(x,y),\, \max(x,z)\big).$$

**Lemma 3.4 (`min_max_distrib`).** For all $x,y,z \in C_n$,
$$\min\!\big(x, \max(y,z)\big) = \max\!\big(\min(x,y),\, \min(x,z)\big).$$

*Proof sketch.* These are the two distributive laws of a distributive lattice.
For a linear order they follow by a three-way case split on the relative order of
$x,y,z$; in each branch both sides reduce to the same element. Lemma 3.4 is the
left-distributivity $a\cdot(b+c) = a\cdot b + a\cdot c$ of the eventual semiring;
Lemma 3.3 is its dual and is used to derive right-distributivity. $\qquad\blacksquare$

### 3.3 Identities

**Lemma 3.5 (`zero_is_add_id`, `add_id_zero`).** For all $x \in C_n$,
$$\max(0, x) = x = \max(x, 0).$$

**Lemma 3.6 (`one_is_mul_id`, `mul_id_one`).** For all $x \in C_n$,
$$\min(\top, x) = x = \min(x, \top).$$

*Proof sketch.* Since $0 = \bot \le x$, we have $\max(0,x) = x$ by
`max_eq_right`. Since $x \le \top$, we have $\min(\top, x) = x$ by `min_eq_right`.
Commutativity gives the right-handed versions. $\qquad\blacksquare$

### 3.4 Idempotence

**Lemma 3.7 (`max_idem`, `min_idem`).** For all $x \in C_n$,
$$\max(x,x) = x, \qquad \min(x,x) = x.$$

*Proof sketch.* Immediate from `max_self` / `min_self`; reflexivity of $\le$. $\qquad\blacksquare$

### 3.5 Absorption

**Lemma 3.8 (`max_absorb`, `min_absorb`).** For all $x,y \in C_n$,
$$\max\!\big(x, \min(x,y)\big) = x, \qquad \min\!\big(x, \max(x,y)\big) = x.$$

*Proof sketch.* The two absorption axioms of lattice theory (`sup_inf_self`,
`inf_sup_self`): since $\min(x,y) \le x$, the join with $x$ returns $x$; dually
for the meet. $\qquad\blacksquare$

---

## 4. The chain commutative semiring

### 4.1 Definition

**Definition 4.1 (chain semiring).** On $C_n = \mathrm{Fin}(n+1)$ define
$$x \oplus y := \max(x,y), \qquad x \otimes y := \min(x,y), \qquad 0 := \bot, \qquad 1 := \top.$$
We call $(C_n, \oplus, \otimes, 0, 1)$ the **finite chain semiring**.

### 4.2–4.5 Monoid and distributive structure

Combining Lemmas 3.1–3.8:

- $(C_n, \oplus, 0)$ is a commutative monoid (Lemmas 3.1, 3.5).
- $(C_n, \otimes, 1)$ is a commutative monoid (Lemmas 3.2, 3.6).
- $\otimes$ distributes over $\oplus$ on both sides. Left distributivity is
  Lemma 3.4 directly; right distributivity
  $\min(\max(a,b),c) = \max(\min(a,c),\min(b,c))$ follows from Lemma 3.4 by
  commuting the meet and relabelling.
- $0$ is multiplicatively absorbing: $\min(\bot, x) = \bot$ and
  $\min(x, \bot) = \bot$ since $\bot \le x$.

### 4.6 Failure of additive invertibility

The defining "alien" property of the chain semiring is that it is never a ring.

**Theorem 4.2 (`top_no_add_inverse`).** If $n \ge 1$, then the multiplicative
unit $\top$ has no additive inverse:
$$\nexists\, z \in C_n \ \text{such that}\ \max(\top, z) = 0.$$

*Proof.* Suppose $z$ satisfies $\max(\top, z) = 0$. Since $z \le \top$ we have
$\max(\top, z) = \top$, so $\top = 0$ in $C_n$. Taking underlying natural-number
values gives $n = 0$, contradicting $n \ge 1$. $\qquad\blacksquare$

**Corollary 4.3.** For $n \ge 1$ the chain semiring $(C_n, \oplus, \otimes, 0,
1)$ is a commutative semiring that is *not* a ring; equivalently, $(C_n, \oplus,
0)$ is a commutative monoid that is not a group.

This is the precise sense in which subtraction is impossible: additive
idempotence ($x \oplus x = x$, Lemma 3.7) already forces any additive inverse of
a nonzero element to collapse the structure, and Theorem 4.2 exhibits a concrete
witness ($\top$) of the obstruction.

### 4.7 The assembled structure

**Theorem 4.4 (`finChainCommSemiring`).** The data of Definition 4.1 extend to a
`CommSemiring` structure on $\mathrm{Fin}(n+1)$, with each axiom discharged by the
order lemmas of §3. Explicitly: `add := max`, `mul := min`, `zero := ⊥`,
`one := ⊤`; the scalar multiplication by naturals is the idempotent
$k \cdot a = a$ for $k > 0$ and $0 \cdot a = \bot$, consistent with additive
idempotence.

*Proof sketch.* The monoid laws are Lemmas 3.1, 3.2, 3.5, 3.6; the distributive
laws are Lemma 3.4 and its commuted form; the absorbing laws for $0$ follow from
$\bot \le x$. The natural-number scalar multiple `nsmul` is defined by
$\mathrm{nsmul}(k,a) = \bot$ if $k=0$ and $a$ otherwise; the successor law
$\mathrm{nsmul}(k+1,a) = \max(\mathrm{nsmul}(k,a), a)$ holds because for $k \ge 1$
both sides equal $\max(a,a) = a$ by idempotence (Lemma 3.7), and for $k = 0$ both
sides equal $a$. No pre-existing semiring instance is invoked at any point, so
the derivation is non-circular. $\qquad\blacksquare$

**Remark.** The construction is uniform in $n$ and is the finite, bounded
specialization of the general theorem "every bounded distributive lattice is a
commutative idempotent semiring." Working over the chain makes every step
decidable and exhaustively checkable.

---

## 5. Survival of classical theorems

We now make precise the central question of non-standard arithmetic for this
model. Write $(\mathbb{N}, +, \cdot, 0, 1)$ for ordinary arithmetic and
$(C_n, \oplus, \otimes, \bot, \top)$ for the chain semiring.

**Theorem 5.1 (Survival theorem).** The following classical laws *survive* the
transfer to the chain semiring (hold verbatim with $+ \mapsto \max$,
$\cdot \mapsto \min$, $0 \mapsto \bot$, $1 \mapsto \top$):

- additive and multiplicative commutativity and associativity;
- existence of additive and multiplicative identities;
- two-sided distributivity;
- the multiplicative-zero (annihilation) law $0 \cdot x = 0$.

The following classical laws *fail*:

- **Additive cancellation / inverses.** There is no subtraction: for $n \ge 1$,
  $\top$ has no additive inverse (Theorem 4.2). Additive cancellation fails:
  $\max(\top, 0) = \max(\top, \top) = \top$ but $0 \ne \top$.
- **Multiplicative cancellation.** $\min(\bot, x)=\min(\bot, y)=\bot$ for all
  $x,y$, so one cannot cancel a factor.
- **The freshman's dream is replaced by strict idempotence.** $x \oplus x = x$
  rather than $x + x = 2x$; there is no "doubling," and the semiring is
  non-Archimedean.
- **No nontrivial nilpotents or characteristic.** Every element is idempotent
  under both operations, so notions like characteristic and nilpotency
  degenerate.

Moreover two *new* laws hold with no classical analogue: **additive/multiplicative
idempotence** (Lemma 3.7) and **absorption** (Lemma 3.8).

*Proof sketch.* The surviving laws are exactly Theorem 4.4. The failures are
witnessed by the explicit computations above, all valid once $n \ge 1$. $\qquad\blacksquare$

The dividing line is clean: *the entire monoid-and-distributive skeleton of
arithmetic transfers, while everything depending on additive invertibility
collapses.* This is the finite, fully decidable shadow of the same phenomenon
that governs tropical and idempotent algebra at large.

---

## 6. The logical interpretation

Reinterpret the chain $C_n$ as a finite scale of **truth values**, with $\bot$ =
*false* and $\top$ = *true* and the intermediate rungs as graded truth.

**Proposition 6.1.** Under this reading the chain semiring is exactly finite
many-valued (Gödel–Dummett / fuzzy) propositional logic with
$$\text{OR} = \max = \oplus, \qquad \text{AND} = \min = \otimes,$$
additive identity $\bot$ (= "false OR $p$ is $p$") and multiplicative identity
$\top$ (= "true AND $p$ is $p$"). Distributivity (Lemma 3.4) is the law that AND
distributes over OR; idempotence (Lemma 3.7) is $p \vee p = p$ and $p \wedge p =
p$; absorption (Lemma 3.8) is $p \vee (p \wedge q) = p$. The failure of additive
inverses (Theorem 4.2) is the statement that there is no truth value $z$ with
"true OR $z$ = false": *a truth, once asserted, cannot be retracted by
disjunction.*

This identifies non-standard chain arithmetic with the algebra of monotone,
order-preserving reasoning under uncertainty, and explains why the same structure
recurs in fuzzy control, lattice-valued model theory, and the semantics of
intuitionistic-style logics over linear Heyting algebras.

For $n = 1$ (the two-element chain $\{0,1\}$) the chain semiring is precisely the
**Boolean semiring** $\mathbb{B}$ with OR and AND — the classical limiting case.

---

## 7. Position in the idempotent / tropical landscape

The chain semiring sits at the intersection of three families.

1. **Bounded distributive lattices as semirings.** $(C_n, \vee, \wedge, \bot,
   \top)$ is the chain instance; the general statement is that any bounded
   distributive lattice is a commutative semiring under join/meet. The chain is
   the simplest non-Boolean family.

2. **Idempotent semirings (dioids).** A semiring with $x \oplus x = x$. The chain
   semiring is additively *and* multiplicatively idempotent, the strongest such
   condition. Dioids are the algebraic backbone of shortest-path and
   max-plus/min-plus scheduling theory.

3. **Tropical semirings.** The $(\max, \min)$ chain is the bounded, finite
   counterpart of the $(\max, +)$ and $(\min, +)$ tropical semirings over the
   extended reals. Replacing the unbounded additive multiplication $+$ by the
   bounded meet $\min$ trades the rich metric geometry of tropical varieties for
   complete finiteness and decidability, while preserving the idempotent additive
   structure that makes tropical methods powerful.

The chain semiring is therefore an ideal *minimal working model* for testing
conjectures about idempotent and tropical algebra: any statement expressible in
the semiring language can be settled on $C_n$ by finite computation.

---

## 8. Algorithms

### 8.1 Chain semiring evaluation

To evaluate an expression in the chain semiring, replace every $+$ by `max` and
every $\cdot$ by `min` and fold over the order. Each binary operation is $O(1)$
(a single comparison), so evaluating an expression tree with $m$ operations costs
$O(m)$ time and $O(1)$ extra space beyond the tree.

```
function CHAIN_EVAL(expr):
    if expr is a leaf value v:        return v
    if expr = (a ⊕ b):                return max(CHAIN_EVAL(a), CHAIN_EVAL(b))
    if expr = (a ⊗ b):                return min(CHAIN_EVAL(a), CHAIN_EVAL(b))
```

### 8.2 Axiom verification by exhaustion

Because $C_n$ is finite, every universally quantified semiring axiom can be
*verified*, not merely tested, by enumerating all tuples. The distributive law,
for instance, ranges over $(n+1)^3$ triples; verifying it for a fixed $n$ is
$O(n^3)$ comparisons. This is the algorithmic content behind "all results have
been formally verified": the finite model admits decision by `decide`.

```
function VERIFY_DISTRIB(n):
    for x in 0..n:
      for y in 0..n:
        for z in 0..n:
          if min(x, max(y,z)) != max(min(x,y), min(x,z)):
              return FALSE
    return TRUE
```

### 8.3 No-inverse certificate

Theorem 4.2 yields a constant-time certificate of non-invertibility: report the
witness $\top = n$, for which $\max(\top, z) = \top \ne 0$ for every $z$.

---

## 9. Lunar arithmetic over the chain semiring

A striking application of the chain semiring is **lunar arithmetic** (OEIS
A087097 and related), in which numbers are digit strings and "addition" /
"multiplication" of digits are `max` / `min`, lifted to multi-digit numbers by a
carry-free, convolution-like rule. Algebraically, lunar numbers are *polynomials
over the chain semiring* $C_9 = \mathrm{Fin}(10)$: a lunar number is a polynomial
whose coefficients are decimal digits, with coefficientwise $\max$ for addition
and $\min$-convolution for multiplication.

Because the digit arithmetic is exactly the chain semiring of §4, lunar
arithmetic inherits idempotence and the absence of subtraction. It also exhibits
genuinely new number-theoretic phenomena — lunar primes, failure of unique
factorization, and canonical "join-normal forms" — which we record as conjectures
in §10.

---

## 10. Discussion and future directions

The chain semiring demonstrates, in the most elementary possible setting, the
governing principle of non-standard arithmetic: *swap the operations for
order-respecting ones, and the additive/multiplicative skeleton of algebra
survives while invertibility is destroyed.* Its finiteness makes it a complete
decidable laboratory, and its logical reading makes it a bridge to many-valued
logic. We close with concrete conjectures for further study (carried over from
the foundational development).

- **C1 — Lattice-theoretic characterization of lunar primes.** A lunar number
  $p$ over $C_9$ is *lunar-prime* if its only factorizations are trivial.
  Conjecture: $p$ is lunar-prime iff its coefficient sequence is
  "join-irreducible at the top" (leading digit $9$, no nontrivial max–min
  convolution reproducing it). Characterize the units of the lunar semiring
  (conjecturally exactly $C\,\top = C\,9$). Testable against OEIS A087097.

- **C2 — Failure of unique factorization, canonical normal form.** Conjecture:
  lunar polynomials do *not* form a UFD (digit idempotency multiplies
  factorizations), yet every lunar number has a canonical representative under a
  dominance-elimination/canonicalization operator that computes a unique normal
  form invariant under lunar addition.

- **C3 — Galois connection / quantale structure.** The base-change map
  `Chain.map` induced by a monotone $\bot/\top$-preserving map of chains is
  conjectured to participate in a Galois connection with the residuation
  $a \wedge x \le b \iff x \le a \Rightarrow b$, making chain arithmetic a
  quantale. Testable exhaustively on $\mathrm{Fin}(n)$ by decision procedure.

- **C4 — Carry-free freshman's dream.** In an additively idempotent semiring the
  cross terms of $(p+q)^n$ need not vanish. Conjecture: for lunar polynomials the
  binomial expansion is carry-free and $(p+q)^n = p^n + q^n$ holds *iff* $p$ and
  $q$ have disjoint digit supports — the lunar analogue of the Frobenius identity,
  with the converse a genuine obstruction.

- **C5 — Rigidity of chain automorphisms.** The De Morgan complement
  $d \mapsto \top - d$ is a $+/\cdot$ anti-isomorphism. Conjecture: every
  semiring anti-automorphism of $C_n$ equals this complement and every
  automorphism is the identity; equivalently, the automorphism group is trivial.

---

## 11. Conclusion

We have given a complete, self-contained, formally verified account of the finite
chain semiring $(\mathrm{Fin}(n+1), \max, \min, \bot, \top)$: a non-standard
arithmetic in which addition is the join, multiplication is the meet, the
multiplicative unit is the *largest* element, both operations are idempotent, and
subtraction is impossible. Every semiring axiom was reduced to a pure order fact,
and the unique obstruction to ring structure — the additive non-invertibility of
the top element — was isolated as Theorem 4.2. The model is at once the simplest
bounded distributive lattice viewed as algebra, the finite shadow of tropical
arithmetic, and the algebra of finite many-valued logic, making it an ideal
testbed for the broader program of determining which classical theorems survive
in non-Archimedean and idempotent settings.
