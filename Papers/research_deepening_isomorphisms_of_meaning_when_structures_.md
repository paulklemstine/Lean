# Isomorphisms of Meaning: When Structures Collide

## Abstract

We make precise a distinction between the *truth* of a mathematical object —
the totality of its properties invariant under a group of admissible
isomorphisms — and its *meaning* — the residual choice of concrete representative
that those isomorphisms are free to move. Working in two independent registers,
the symmetric group of a finite set and the monoid of divisibility-preserving
integer sequences, we show that the two registers share a single mechanism. On
the group side we study the *isomorphism of isomorphisms* $\Phi_e : \mathrm{Sym}(\alpha)
\xrightarrow{\ \sim\ } \mathrm{Sym}(\beta)$ induced by an equivalence $e :
\alpha \simeq \beta$; we prove it is functorial and transports every
relabeling-invariant quantity (order, sign, support cardinality, cycle type)
unchanged. We then exhibit a sharp *collision*: two symmetries of a three-point
set that agree on cycle type, order, and sign — hence on every invariant of the
abstract group — yet act on different points. On the arithmetic side we show the
Fibonacci and Mersenne sequences are distinct functions obeying the identical
structural law of a strong divisibility sequence and the identical divisibility
implication. We conclude that isomorphic structures generically carry different
meanings undetectable by any structural invariant, and that the size of this
truth/meaning gap is, in the finite case, an orbit cardinality — a computable
quantity.

**Keywords:** symmetric group, permutation invariants, cycle type, isomorphism of
isomorphisms, functoriality, strong divisibility sequence, Fibonacci, Mersenne,
truth versus meaning.

---

## 1. Introduction

A recurring theme across mathematics, logic, and the study of analogy is the
tension between *structural sameness* and *concrete identity*. Two objects may be
indistinguishable by every intrinsic, relabeling-invariant property, and yet
differ in what they concretely do to the elements that name them. We make this
slogan precise and prove it in two settings that at first sight have nothing in
common.

We adopt a deliberately operational vocabulary. Fix a class of *admissible
isomorphisms* acting on a class of objects. We call:

- **Truth** the collection of properties of an object that are invariant under
  the action — equivalently, the object's orbit-invariants;
- **Meaning** the residual data distinguishing objects within a single orbit —
  the concrete representative that an isomorphism is free to move.

Our central thesis is that *truth is transported faithfully by isomorphisms while
meaning is not*, so that isomorphic structures can, and generically do, carry
different meanings that no structural invariant can detect. We prove this in a
group-theoretic register (Sections 3–5) and an arithmetic register (Section 6),
and identify the shared mechanism (Section 7).

### Contributions

1. A functoriality theorem for the **isomorphism of isomorphisms** $\Phi_e$
   induced by an equivalence of sets (Theorem 3.2).
2. Transport theorems establishing that order, parity (sign), support
   cardinality, and cycle type are *truths*: preserved by $\Phi_e$ (Theorems
   4.1–4.4).
3. A **collision theorem**: two permutations of a three-point set agreeing on
   cycle type, order, and sign yet acting on different points (Theorem 5.2). Since
   cycle type is the *complete* conjugacy invariant, this is a hard ceiling, not
   an artifact of weak invariants.
4. An arithmetic analogue: the **meaning-morphism collision** of the Fibonacci
   and Mersenne sequences as distinct strong divisibility sequences obeying an
   identical structural law and divisibility implication (Theorems 6.2–6.3).
5. A unifying interpretation (Section 7) recasting the truth/meaning gap as an
   orbit-cardinality, hence a computable quantity.

---

## 2. Preliminaries and definitions

Throughout, $\alpha, \beta, \gamma$ denote sets (types), and $\mathrm{Sym}(\alpha)$
denotes the group of all bijections $\alpha \to \alpha$ under composition — the
*symmetric group* of $\alpha$, whose elements we call *permutations* or
*symmetries*.

**Definition 2.1 (Equivalence).** An *equivalence* $e : \alpha \simeq \beta$ is a
bijection with a two-sided inverse $e^{-1} : \beta \simeq \alpha$. Equivalences
compose: given $e : \alpha \simeq \beta$ and $e' : \beta \simeq \gamma$, the
composite $e' \circ e : \alpha \simeq \gamma$ is again an equivalence.

**Definition 2.2 (Transported symmetry).** Given an equivalence $e : \alpha
\simeq \beta$ and a symmetry $f \in \mathrm{Sym}(\alpha)$, the *transported
symmetry* $\Phi_e(f) \in \mathrm{Sym}(\beta)$ is
$$\Phi_e(f) = e \circ f \circ e^{-1}.$$
Concretely, $\Phi_e(f)(x) = e\big(f(e^{-1}(x))\big)$ for $x \in \beta$: relabel
the input by $e^{-1}$, apply $f$, relabel the output by $e$.

**Definition 2.3 (Support).** For a permutation $f$ of a finite set, its
*support* is the set of points it moves:
$$\mathrm{supp}(f) = \{\, x : f(x) \neq x \,\}.$$
Its *support cardinality* is $\#\,\mathrm{supp}(f)$.

**Definition 2.4 (Order).** The *order* of $f$, written $\mathrm{ord}(f)$, is the
least positive integer $k$ with $f^k = \mathrm{id}$ (and $0$ if no such $k$
exists; for finite permutations it is always positive).

**Definition 2.5 (Sign).** For a permutation $f$ of a finite set, its *sign*
$\mathrm{sgn}(f) \in \{+1, -1\}$ is $+1$ if $f$ is a product of an even number of
transpositions and $-1$ otherwise. It is a group homomorphism $\mathrm{Sym}(\alpha)
\to \{\pm 1\}$.

**Definition 2.6 (Cycle type).** Every permutation of a finite set factors
uniquely, up to order, into disjoint cycles. Its *cycle type* $\mathrm{ct}(f)$ is
the multiset of the lengths of these cycles (counting only cycles of length $\geq
2$). Two permutations of the same finite set are *conjugate* — related by
$g = h f h^{-1}$ for some $h$ — if and only if they have the same cycle type.

**Definition 2.7 (Strong divisibility sequence).** A sequence $u : \mathbb{N} \to
\mathbb{N}$ is a *strong divisibility sequence* if
$$\gcd(u_m, u_n) = u_{\gcd(m, n)} \qquad \text{for all } m, n.$$
Equivalently, $u$ is a structure-preserving map ("meaning-morphism") of the
divisibility monoid, carrying $\gcd$ on indices to $\gcd$ on values.

---

## 3. The isomorphism of isomorphisms

An equivalence $e : \alpha \simeq \beta$ acts on symmetries by conjugation,
$\Phi_e(f) = e \circ f \circ e^{-1}$. This assignment is the natural bridge
between the two symmetric groups.

**Proposition 3.1 (Group isomorphism).** For each equivalence $e : \alpha \simeq
\beta$, the map $\Phi_e : \mathrm{Sym}(\alpha) \to \mathrm{Sym}(\beta)$ is a group
isomorphism, with inverse $\Phi_{e^{-1}}$.

*Proof sketch.* Conjugation by a fixed invertible element is always a group
automorphism when domain and codomain coincide; here the "conjugating element" is
the equivalence $e$ mediating between two different groups, so the same
computation gives $\Phi_e(fg) = e f g e^{-1} = (e f e^{-1})(e g e^{-1}) =
\Phi_e(f)\,\Phi_e(g)$, and $\Phi_{e^{-1}}$ undoes it. $\square$

We call $\Phi_e$ the **isomorphism of isomorphisms**: it is an isomorphism
between the two groups whose elements are themselves the isomorphisms
(self-equivalences) of $\alpha$ and $\beta$.

**Theorem 3.2 (Functoriality).** For equivalences $e : \alpha \simeq \beta$ and
$e' : \beta \simeq \gamma$ and any $f \in \mathrm{Sym}(\alpha)$,
$$\Phi_{e' \circ e}(f) = \Phi_{e'}\big(\Phi_e(f)\big).$$

*Proof sketch.* Evaluate both sides at a point $x \in \gamma$. The left side is
$(e' \circ e) \circ f \circ (e' \circ e)^{-1}$, sending $x \mapsto e'\big(e(f(e^{-1}(e'^{-1}(x))))\big)$.
The right side conjugates first by $e$ and then by $e'$, sending $x \mapsto
e'\big(e(f(e^{-1}(e'^{-1}(x))))\big)$. The expressions coincide pointwise, so the
permutations are equal. $\square$

Theorem 3.2 says $e \mapsto \Phi_e$ is a functor from the groupoid of
sets-and-bijections to the category of groups; the isomorphism of isomorphisms is
*natural* in $e$. This functoriality is what licenses transporting invariants
along chains of relabelings without ambiguity, and it is used implicitly whenever
a truth is carried from one structure to another.

---

## 4. Truth is preserved: transport of invariants

We now establish that the standard relabeling-invariant quantities of a
permutation are *truths* in our sense: $\Phi_e$ carries each of them across
unchanged.

**Theorem 4.1 (Order is a truth).** For any equivalence $e : \alpha \simeq \beta$
and $f \in \mathrm{Sym}(\alpha)$,
$$\mathrm{ord}\big(\Phi_e(f)\big) = \mathrm{ord}(f).$$

*Proof sketch.* $\Phi_e$ is an injective monoid homomorphism (Proposition 3.1);
order is invariant under injective monoid homomorphisms, since $\Phi_e(f)^k =
\Phi_e(f^k)$ equals the identity iff $f^k$ does. $\square$

**Theorem 4.2 (Sign is a truth).** For finite $\alpha, \beta$ and $f \in
\mathrm{Sym}(\alpha)$,
$$\mathrm{sgn}\big(\Phi_e(f)\big) = \mathrm{sgn}(f).$$

*Proof sketch.* Conjugation preserves the decomposition into transpositions:
$\Phi_e$ maps a transposition $(a\ b)$ to the transposition $(e(a)\ e(b))$, hence
sends a product of $k$ transpositions to a product of $k$ transpositions, leaving
the parity — and therefore the sign — unchanged. $\square$

**Theorem 4.3 (Support transports; its cardinality is a truth).** For finite
$\alpha, \beta$, an equivalence $e : \alpha \simeq \beta$, and $f \in
\mathrm{Sym}(\alpha)$,
$$\mathrm{supp}\big(\Phi_e(f)\big) = e\big(\mathrm{supp}(f)\big),$$
the image of the support under $e$. Consequently
$$\#\,\mathrm{supp}\big(\Phi_e(f)\big) = \#\,\mathrm{supp}(f).$$

*Proof sketch.* A point $x \in \beta$ is moved by $\Phi_e(f)$ iff
$e(f(e^{-1}(x))) \neq x$ iff $f(e^{-1}(x)) \neq e^{-1}(x)$ (using injectivity of
$e$) iff $e^{-1}(x) \in \mathrm{supp}(f)$ iff $x \in e(\mathrm{supp}(f))$. This is
a membership chase through the definition of $\Phi_e$ and the bijectivity of $e$.
Since $e$ is a bijection, it maps the support to a set of equal cardinality;
cardinality is therefore preserved. $\square$

Theorem 4.3 is the cleanest illustration of the truth/meaning split *inside a
single object*: the support's *cardinality* is invariant (truth), while its
*elements* move with $e$ (meaning).

**Theorem 4.4 (Cycle type is a truth; and is complete).** For finite $\alpha$ and
$f, g \in \mathrm{Sym}(\alpha)$, if $f$ and $g$ are conjugate then $\mathrm{ct}(f)
= \mathrm{ct}(g)$. Conversely, equal cycle type implies conjugacy. In particular
$\mathrm{ct}\big(\Phi_e(f)\big) = \mathrm{ct}(f)$.

*Proof sketch.* Conjugation permutes the disjoint-cycle factorization by
relabeling the entries of each cycle, preserving cycle lengths; hence conjugate
permutations share a cycle type. The converse is the classical fact that any two
permutations with matching cycle lengths are related by relabeling the points
cycle-by-cycle. Transport is the special case where the conjugation is $\Phi_e$.
$\square$

Cycle type is thus the *maximal* isomorphism-invariant of a finite permutation —
the terminal truth through which all other conjugation-invariants factor. This
completeness is what gives the collision of the next section its bite.

---

## 5. Meaning is not preserved: a collision on three points

We now show truth underdetermines meaning, already at the smallest nontrivial
scale.

**Lemma 5.1.** In $\mathrm{Sym}(\{0,1,2\})$, the transpositions $(0\ 1)$ and
$(1\ 2)$ are conjugate.

*Proof sketch.* Both are single 2-cycles, so both have cycle type
$\{2\}$; by the completeness half of Theorem 4.4, equal cycle type implies
conjugacy. (Concretely, conjugating $(0\ 1)$ by the transposition $(0\ 2)$ yields
$(1\ 2)$.) $\square$

**Theorem 5.2 (Collision).** There exist permutations $f, g \in
\mathrm{Sym}(\{0,1,2\})$ such that
$$\mathrm{ct}(f) = \mathrm{ct}(g), \quad \mathrm{ord}(f) = \mathrm{ord}(g), \quad
\mathrm{sgn}(f) = \mathrm{sgn}(g),$$
and yet
$$f \neq g \quad \text{and} \quad \mathrm{supp}(f) \neq \mathrm{supp}(g).$$

*Proof sketch.* Take $f = (0\ 1)$ and $g = (1\ 2)$.
- *Cycle type:* equal by Lemma 5.1 (both are $\{2\}$).
- *Order:* each is a transposition, hence of prime order $2$; explicitly
  $\mathrm{ord}(f) = \mathrm{ord}(g) = 2$.
- *Sign:* each is a single transposition, hence odd, $\mathrm{sgn}(f) =
  \mathrm{sgn}(g) = -1$.
- *Inequality:* $f(0) = 1 \neq 0 = g(0)$, so $f \neq g$.
- *Supports differ:* $\mathrm{supp}(f) = \{0, 1\} \neq \{1, 2\} =
  \mathrm{supp}(g)$.
The three invariant clauses are verified by conjugacy and by finite computation;
the two inequality clauses by evaluating at a single point. $\square$

**Interpretation.** No invariant of the abstract symmetry group separates $f$ from
$g$: they agree on cycle type — the *complete* conjugacy invariant — hence
necessarily on order, sign, and support size, and on *every* other function that
is constant on conjugacy classes. What distinguishes them is only the concrete
support: *which* two points they move. This is the sharp "structures collide"
phenomenon. Because cycle type is the terminal truth (Theorem 4.4), the collision
cannot be resolved by enriching the invariant list; it is a hard ceiling. Truth
is silent; only the labels speak.

---

## 6. Arithmetic register: colliding meaning-morphisms

The same phenomenon reappears in number theory, with strong divisibility
sequences (Definition 2.7) playing the role of structure-preserving maps and
their numerical values playing the role of meaning.

**Proposition 6.1 (Structural consequence).** If $u$ is a strong divisibility
sequence then
$$m \mid n \ \Longrightarrow\ u_m \mid u_n.$$

*Proof sketch.* If $m \mid n$ then $\gcd(m, n) = m$, so the defining law gives
$\gcd(u_m, u_n) = u_{\gcd(m,n)} = u_m$; a number equal to $\gcd(u_m, u_n)$
divides $u_n$, hence $u_m \mid u_n$. $\square$

**Theorem 6.2 (Meaning-morphism collision).** The Fibonacci sequence $F$ (with
$F_1 = F_2 = 1$, $F_{n+1} = F_n + F_{n-1}$) and the Mersenne sequence $u_n = 2^n -
1$ are both strong divisibility sequences, and yet they are distinct as functions:
$$F \neq (n \mapsto 2^n - 1).$$

*Proof sketch.* That $F$ is a strong divisibility sequence is the classical
identity $\gcd(F_m, F_n) = F_{\gcd(m,n)}$. That $n \mapsto 2^n - 1$ is one follows
from $\gcd(2^m - 1, 2^n - 1) = 2^{\gcd(m,n)} - 1$. For distinctness, evaluate at
$n = 3$: $F_3 = 2$ while $2^3 - 1 = 7$, so the two functions disagree. $\square$

**Theorem 6.3 (Shared divisibility law).** For all $m, n$ with $m \mid n$,
$$F_m \mid F_n \quad \text{and} \quad (2^m - 1) \mid (2^n - 1).$$

*Proof sketch.* Apply Proposition 6.1 to each of the two strong divisibility
sequences of Theorem 6.2. $\square$

**Interpretation.** Fibonacci and Mersenne obey — word for word — the same
structural law (Definition 2.7) and the same observable consequence (Theorem
6.3), yet they are different objects (Theorem 6.2). The shared law is the *truth*;
the differing values are the *meaning*. This is precisely the collision of Section
5, transposed from the symmetric group to the divisibility monoid: a single
structural truth forces a shared observable consequence in two distinct arithmetic
worlds while leaving their concrete values free to differ.

---

## 7. The unifying mechanism

Sections 3–5 (group-theoretic) and Section 6 (arithmetic) instantiate one
abstract pattern. In each register there is:

- a class of **objects** (permutations; integer sequences),
- an acting class of **admissible isomorphisms** (relabelings $\Phi_e$;
  value-relabelings fixing divisibility),
- a notion of **truth** = orbit-invariants (order, sign, support size, cycle
  type; the gcd-preservation law and its divisibility consequence),
- a notion of **meaning** = the choice of representative within an orbit (which
  points move; which values appear).

The isomorphism of isomorphisms transports every truth *faithfully* — this is the
content of functoriality (Theorem 3.2) together with the transport theorems
(Section 4) — while remaining free to permute meaning. Hence:

> **Thesis.** Isomorphic structures can, and generically do, carry different
> meanings that no invariant of the structure can detect. The collision is not an
> artifact of weak invariants: it persists against the *complete* invariant
> (cycle type), and it recurs verbatim in the arithmetic of divisibility.

A quantitative refinement is visible already: the number of distinct meanings
sharing a fixed truth is, in the finite case, the cardinality of an automorphism
orbit. For the three-point collision the relevant orbit — the conjugacy class of a
transposition in $\mathrm{Sym}(\{0,1,2\})$ — has three elements, namely $(0\ 1)$,
$(0\ 2)$, $(1\ 2)$, matching the three distinct 2-element supports. The truth
"cycle type $\{2\}$" is thus realized by exactly three meanings. The truth/meaning
gap is not vague; it is a countable, computable quantity.

---

## 8. Applications and connections

**Reasoning by analogy.** Systems that transfer knowledge by structural analogy
bet that "same structure" implies "same behavior". The collision theorem draws the
precise boundary of that bet: structural invariants transfer perfectly, but the
concrete action need not. Analogical transfer is sound exactly on truths and
underdetermined exactly on meanings.

**Cryptography and sequence design.** The Mersenne divisibility law $(2^m - 1)
\mid (2^n - 1)$ underlies primality structure of Mersenne numbers; the Fibonacci
law $F_m \mid F_n$ underlies the theory of ranks of apparition. Theorem 6.3
exhibits both as consequences of a single structural property, clarifying which
features of such sequences are *forced* (truth) and which are *free* (meaning) —
useful when designing sequences to a divisibility specification.

**Classification.** Cycle type as the terminal truth (Theorem 4.4) is the engine
of conjugacy classification in symmetric groups. Framing it as "the universal
invariant through which all others factor" makes explicit why enumerating
conjugacy classes enumerates *all* structural distinctions.

---

## 9. Future directions

**Conjecture 1 — Meaning-rigidity of complete invariants.** For a finite
structure, the number of distinct meanings sharing a fixed truth is exactly the
size of the automorphism orbit of a representative; an object is *meaning-rigid*
(truth determines meaning) precisely when its stabilizer is the whole automorphism
group. The truth/meaning gap thus becomes an exact counting law computable from
the automorphism group. The three-point collision shows the orbit is nontrivial
already at the smallest scale, and the orbit-counting tools needed to make this
quantitative are in hand, so the statement is immediately testable on symmetric
and cyclic groups.

**Conjecture 2 — No invariant refines cycle type.** For finite permutations, every
function constant on relabeling-classes factors through the cycle type;
consequently no additional invariant can separate the colliding transpositions
without appealing to labels. Cycle type is not merely *an* invariant but the
*terminal* one — the universal truth through which all others factor — so the
collision is a hard ceiling rather than an artifact of a weak invariant list.

**Conjecture 3 — Divisibility meaning-morphisms form a rigid family.** Among
integer sequences preserving divisibility structure, the pattern of *apparition
indices* (the first index at which each prime appears) is a complete truth; two
such sequences share it iff one is obtained from the other by a value-relabeling
fixing divisibility — yet infinitely many share every finite initial apparition
pattern while differing in value. Fibonacci and Mersenne are then not isolated
curiosities but two points of a large family whose common truth is an apparition
pattern, reframing strong divisibility sequences as meanings attached to one
structural skeleton.

---

## 10. Conclusion

We have made the slogan "same structure, different meaning" into a theorem, twice.
On the symmetric group of a set, the isomorphism of isomorphisms transports every
invariant faithfully yet cannot separate two transpositions that move different
points; in the divisibility monoid, Fibonacci and Mersenne obey an identical
structural law yet take different values. The shared mechanism is that truth is
the orbit-invariant part of an object while meaning is the residual choice of
representative, and isomorphisms are by definition free to move the latter. The
gap between the two is real, irreducible against the complete invariant, and — in
the finite case — a countable orbit cardinality. When structures collide, they do
not break; they reveal that *being the same* and *being identical* were always
distinct questions.
