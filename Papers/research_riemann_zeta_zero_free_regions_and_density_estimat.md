# Prime Congruence Spectra: A Zariski Geometry for Semirings, Proofs, and Tropical Algebra

**Author:** Aristotle
**Date:** 2026-06-22
**Domain:** Algebra

## Abstract

We develop a spectral geometry for arbitrary semirings, taking *congruences* —
equivalence relations compatible with addition and multiplication — as the
fundamental algebraic objects in place of ideals. To each congruence we
associate its **zero class**, the set of elements equivalent to $0$, and prove
that zero classes satisfy the ideal axioms. We single out **prime congruences**
by the integral-domain law $a b \sim 0 \Rightarrow a \sim 0 \lor b \sim 0$, and
define the **proof spectrum** $\operatorname{Spec_{proof}}(R)$ as the collection
of all prime congruences. On this spectrum we define **Zariski-closed sets**
$V(S)$ and the **theory operator** $\operatorname{Th}(X)$, and we establish: (i)
that $V(\cdot)$ satisfies the closed-set axioms of a topology, including closure
under arbitrary intersection, $V(\bigcup \mathcal{S}) = \bigcap_S V(S)$; (ii)
that $V$ and $\operatorname{Th}$ form a Galois connection, $S \subseteq
\operatorname{Th}(X) \Leftrightarrow X \subseteq V(S)$; (iii) that the induced
closure operator (the **radical**) is idempotent and that its fixed points are
exactly the intersections of prime theories; and (iv) that over **idempotent**
semirings — where $x + x = x$, the home of Boolean logic and tropical algebra —
addition is the join of a natural order. The construction provides a uniform
spectral framework subsuming the prime spectrum of commutative algebra, a
provability semantics for proof theory (with $+ = {\vee}$, $\times = {\wedge}$),
and a geometry for tropical optimization. All results have been formalized and
machine-checked.

## 1. Introduction

The prime spectrum $\operatorname{Spec}(R)$ of a commutative ring is the
foundation of modern algebraic geometry: its points are prime ideals, its closed
sets are vanishing loci of families of ring elements, and the Nullstellensatz
correspondence relates algebra (ideals) to geometry (closed sets). This paper
asks whether the same edifice can be raised over **semirings** — algebraic
structures with addition and multiplication but *no subtraction* — and answers in
the affirmative.

The motivation is threefold. First, many computationally and logically central
structures are semirings with no additive inverses: the Boolean semiring
$\mathbb{B} = (\{0,1\}, \lor, \land)$ is the algebra of provability, and the
tropical semiring $(\mathbb{R} \cup \{\infty\}, \min, +)$ is the algebra of
optimization. Second, over such structures ideals are no longer in bijection
with congruences, so a faithful theory must take the congruence as primitive.
Third, the resulting geometry yields a clean dictionary between algebraic
geometry and proof theory, in which prime congruences are geometric points,
Zariski-closed sets are provability loci, and the radical operator computes
deductive closure.

Throughout, $R$ denotes a semiring (associative, with $0$ and $1$, distributive,
$0$ absorbing). We do not assume commutativity except where noted; the spectral
constructions below require none.

## 2. Congruences and zero classes

**Definition 1 (semiring congruence, `SRCong`).** A *congruence* on a semiring
$R$ is a relation $\mathord{\sim} \subseteq R \times R$ that is reflexive,
symmetric, transitive, and compatible with the operations:
$$a \sim b \ \land\ c \sim d \ \Rightarrow\ a + c \sim b + d, \qquad
a \sim b \ \land\ c \sim d \ \Rightarrow\ a c \sim b d.$$
Congruences are ordered by inclusion of their graphs, $C \le D$ iff
$a \sim_C b \Rightarrow a \sim_D b$; this makes the set of congruences a preorder
(in fact a complete lattice, though we use only the preorder here).

Two immediate consequences (Lemmas `mul_left`, `mul_right`) are the one-sided
scaling laws:
$$a \sim b \ \Rightarrow\ f a \sim f b \quad\text{and}\quad a \sim b \ \Rightarrow\ a f \sim b f,$$
obtained from compatibility with multiplication together with reflexivity
$f \sim f$.

**Definition 2 (zero class, `SRCong.zeroClass`).** The *zero class* of a
congruence $C$ is
$$Z(C) = \{\, a \in R : a \sim_C 0 \,\}.$$

**Proposition 1 (zero classes are ideals; `zero_mem_zeroClass`,
`zeroClass_add_closed`, `zeroClass_mul_absorb`).** For every congruence $C$:
1. $0 \in Z(C)$;
2. $a, b \in Z(C) \Rightarrow a + b \in Z(C)$;
3. $a \in Z(C) \Rightarrow a b \in Z(C)$ for all $b \in R$.

*Proof sketch.* (1) is reflexivity $0 \sim 0$. (2): from $a \sim 0$ and
$b \sim 0$, additive compatibility gives $a + b \sim 0 + 0 = 0$, and $0 + 0 = 0$.
(3): from $a \sim 0$ and $b \sim b$, multiplicative compatibility gives
$a b \sim 0 \cdot b = 0$, and $0 \cdot b = 0$ by absorption. $\qquad\blacksquare$

Proposition 1 shows that $Z(\cdot)$ is the semiring analogue of "the ideal
underlying a congruence." In a ring every ideal arises this way and the
correspondence is a bijection; over a general semiring the congruence carries
strictly more information, which is why we keep it primitive.

## 3. Prime congruences and the proof spectrum

**Definition 3 (prime congruence, `PrimeSRCong`).** A congruence $P$ is *prime*
if it satisfies the integral-domain law
$$a b \sim_P 0 \ \Longrightarrow\ a \sim_P 0 \ \lor\ b \sim_P 0 .$$

**Definition 4 (proof spectrum, `ProofSpectrum`).** The *proof spectrum* of $R$
is the type $\operatorname{Spec_{proof}}(R)$ of all prime congruences on $R$,
ordered by inclusion.

**Proposition 2 (prime zero classes are prime theories;
`prime_cong_zero_class_prime_theory`).** If $P$ is a prime congruence then $Z(P)$
is a *prime theory*: it is closed under the ideal operations of Proposition 1 and
satisfies $a b \in Z(P) \Rightarrow a \in Z(P) \lor b \in Z(P)$.

*Proof sketch.* Immediate from Definition 3 and Proposition 1: the integral-domain
law for $\sim_P$ is exactly primality for the set $Z(P)$. $\qquad\blacksquare$

Proposition 2 establishes the point–theory duality: points of the proof spectrum
(prime congruences) correspond to prime theories (deductively closed,
integral-domain-like sets of elements). Reading $+$ as disjunction and $\times$
as conjunction, a prime theory is a maximally coherent assignment of "triviality"
to compound statements, and a point of the spectrum is a consistent semantics.

**Proposition 3 (existence of nondegenerate points; `nontrivial_prime_exists`).**
If $R$ is an integral domain, the diagonal congruence (equality) is a prime
congruence with $Z = \{0\}$, so $\operatorname{Spec_{proof}}(R)$ contains a
nondegenerate point.

## 4. The Zariski topology on the proof spectrum

**Definition 5 (vanishing, `vanishes`).** An element $a \in R$ *vanishes* at a
point $P \in \operatorname{Spec_{proof}}(R)$ if $a \sim_P 0$; write
$\operatorname{van}(P, a)$.

**Definition 6 (Zariski-closed set, `zariskiClosed`).** For $S \subseteq R$,
$$V(S) = \{\, P \in \operatorname{Spec_{proof}}(R) : \forall s \in S,\ \operatorname{van}(P,s) \,\}.$$

**Definition 7 (theory of a set of points, `theoryOfSpec`).** For
$X \subseteq \operatorname{Spec_{proof}}(R)$,
$$\operatorname{Th}(X) = \{\, a \in R : \forall P \in X,\ \operatorname{van}(P,a) \,\}.$$

**Theorem 2 (Zariski closed-set axioms).** The family $\{V(S) : S \subseteq R\}$
satisfies:
1. **(`zariskiClosed_empty_eq_univ`)** $V(\varnothing) = \operatorname{Spec_{proof}}(R)$.
2. **(`zariskiClosed_union_eq_inter`)** $V(S \cup T) = V(S) \cap V(T)$.
3. **(`zariskiClosed_antiMono`)** $S \subseteq T \Rightarrow V(T) \subseteq V(S)$.
4. **(`zariskiClosed_iInter`)** For any $\mathcal{S} \subseteq \mathcal{P}(R)$,
   $$V\!\Big(\textstyle\bigcup \mathcal{S}\Big) = \bigcap_{S \in \mathcal{S}} V(S).$$

*Proof sketch.* (1) The universal quantifier over $\varnothing$ is vacuously
true, so every $P$ lies in $V(\varnothing)$. (2) $P \in V(S \cup T)$ iff every
element of $S \cup T$ vanishes at $P$, which splits as "every element of $S$
vanishes" and "every element of $T$ vanishes," i.e. $P \in V(S) \cap V(T)$. (3)
If $S \subseteq T$ and every element of $T$ vanishes at $P$, then in particular
every element of $S$ does. (4) $P \in V(\bigcup \mathcal{S})$ iff every $s$ lying
in some $S \in \mathcal{S}$ vanishes at $P$, iff for every $S \in \mathcal{S}$
every $s \in S$ vanishes, iff $P \in V(S)$ for all $S$, iff $P \in \bigcap_S
V(S)$. $\qquad\blacksquare$

By (1) and (4), $V$ takes unions to intersections and $\varnothing$ to the whole
space; in particular the closed sets are closed under arbitrary intersection,
which together with (2) (finite unions, via the union–intersection law for the
*generating sets*) gives a topology in the standard way. This is the **Zariski
topology** on $\operatorname{Spec_{proof}}(R)$.

## 5. The Galois connection and the radical

**Theorem 3 (Galois connection; `galois_connection_theory_variety`).** For all
$S \subseteq R$ and $X \subseteq \operatorname{Spec_{proof}}(R)$,
$$S \subseteq \operatorname{Th}(X) \quad\Longleftrightarrow\quad X \subseteq V(S).$$

*Proof sketch.* Both sides unfold to the single symmetric condition "for all
$P \in X$ and all $s \in S$, $\operatorname{van}(P,s)$." The left side reads it as
"$\forall s \in S, \forall P \in X$," the right as "$\forall P \in X, \forall
s \in S$"; these are equal. $\qquad\blacksquare$

A Galois connection between the powerset of $R$ and the powerset of the spectrum
induces a closure operator on each side. On theories, the composite
$$\operatorname{rad}(T) := \operatorname{Th}(V(T))$$
is the **radical**. Standard Galois-connection formalism, instantiated here,
yields:

**Theorem 4 (radical is a closure operator; `radicalTheory_idempotent`).**
$\operatorname{rad}$ is extensive ($T \subseteq \operatorname{rad}(T)$), monotone,
and idempotent ($\operatorname{rad}(\operatorname{rad}(T)) = \operatorname{rad}(T)$).

**Theorem 5 (fixed points are intersections of primes;
`radical_fixpoint_iff_inter_primes`).** A theory $T$ satisfies
$\operatorname{rad}(T) = T$ if and only if $T$ is an intersection of prime
theories,
$$T = \bigcap_{P \in V(T)} Z(P).$$

*Proof sketch.* Idempotence is the general fact $\operatorname{Th}\circ V \circ
\operatorname{Th}\circ V = \operatorname{Th}\circ V$ for any Galois connection,
which follows from the two unit/counit inequalities $T \subseteq
\operatorname{Th}(V(T))$ and $V(\operatorname{Th}(V(T))) = V(T)$. For Theorem 5,
$\operatorname{rad}(T) = \operatorname{Th}(V(T)) = \bigcap_{P \in V(T)} Z(P)$ by
unfolding $\operatorname{Th}$; hence $\operatorname{rad}(T) = T$ exactly when $T$
equals this intersection of prime zero classes. $\qquad\blacksquare$

Theorem 5 is the structure theorem of the subject: the geometrically meaningful
theories — the closed points of the round trip — are precisely those recoverable
as the common content of a family of prime semantics. It is the proof-theoretic
counterpart of "radical ideals are intersections of the primes above them," and,
read through $+ = {\vee}, \times = {\wedge}$, it says a theory is
"saturated" iff it is the intersection of the prime theories that model it.

## 6. Idempotent semirings: order, join, and the tropical bridge

A semiring is **idempotent** if $x + x = x$ for all $x$. The Boolean semiring
and every tropical semiring are idempotent.

**Theorem 6 (natural preorder; `idempotent_add_natural_preorder`).** In an
idempotent semiring, the relation $x \le y :\Leftrightarrow x + y = y$ is a
preorder (reflexive and transitive).

*Proof sketch.* Reflexivity is $x + x = x$. Transitivity: if $x + y = y$ and
$y + z = z$ then $x + z = x + (y + z) = (x + y) + z = y + z = z$, using
associativity. $\qquad\blacksquare$

**Theorem 7 (addition is join; `idem_add_is_join`).** In an idempotent
*commutative* semiring, $x + y$ is the least upper bound of $x$ and $y$ in the
natural order: $x \le x + y$, $y \le x + y$, and if $x \le z$ and $y \le z$ then
$x + y \le z$.

*Proof sketch.* $x \le x + y$ since $x + (x + y) = (x + x) + y = x + y$;
symmetrically for $y$. If $x + z = z$ and $y + z = z$ then $(x + y) + z =
x + (y + z) = x + z = z$, so $x + y \le z$. $\qquad\blacksquare$

**Proposition 4 (idempotent multiples; `idem_nsmul_eq`).** In an idempotent
additive monoid, $n \cdot x = x$ for every $n \ge 1$, where $n \cdot x$ denotes
the $n$-fold sum.

*Proof sketch.* Induction on $n$: $1 \cdot x = x$, and $(n+1)\cdot x = n\cdot x +
x = x + x = x$. $\qquad\blacksquare$

These results identify the additive structure of an idempotent semiring with a
join-semilattice. Consequently the spectral constructions of §§3–5 run verbatim
over Boolean logic and tropical algebra: prime congruences, vanishing loci, the
Zariski topology, and the radical all specialize, giving a single geometry for
provability and for $\min$-$+$ optimization.

## 7. A worked example: $\operatorname{Spec_{proof}}(\mathbb{Z}/6\mathbb{Z})$

For a commutative ring, congruences coincide with ideals and prime congruences
with prime ideals, so $\operatorname{Spec_{proof}}(R) \cong \operatorname{Spec}(R)$.
Take $R = \mathbb{Z}/6\mathbb{Z}$. Its ideals are $(0), (2), (3), (1)$ and its
prime ideals are $(2)$ and $(3)$, so the spectrum has two points $P_2, P_3$ with
$Z(P_2) = (2) = \{0,2,4\}$ and $Z(P_3) = (3) = \{0,3\}$.

Then $V(\{2\}) = \{P_2\}$, $V(\{3\}) = \{P_3\}$, and by Theorem 2(2)
$$V(\{2,3\}) = V(\{2\}) \cap V(\{3\}) = \{P_2\} \cap \{P_3\} = \varnothing,$$
reflecting that $2 \cdot 3 = 6 \equiv 0$ cannot vanish via a single factor at a
common point — the geometric content of the factorization $6 = 2 \times 3$.
Finally $\operatorname{Th}(\{P_2, P_3\}) = Z(P_2) \cap Z(P_3) = \{0\}$, the
radical of $(0)$, in agreement with Theorem 5.

(Definition 3 imposes no properness condition, so the all-collapsing *top*
congruence, with zero class the whole carrier, is also prime; restricting to the
two *proper* points $P_2, P_3$ recovers the classical picture above. The
accompanying demonstration prints both the full and the proper spectrum.)

## 8. Algorithms

The finite case is fully computable, which we exploit to validate the theory by
exhaustive enumeration (see the accompanying demonstrations).

**Algorithm A (congruence enumeration).** Given a finite semiring presented by
its addition and multiplication tables, enumerate set partitions of the carrier
and retain those whose induced relation is compatible with both operations.
Complexity is governed by the Bell number $B_n$ of the carrier size $n$; for the
small semirings used in validation this is entirely tractable.

**Algorithm B (prime detection).** For each congruence, test the
integral-domain law $a b \sim 0 \Rightarrow a \sim 0 \lor b \sim 0$ over all
pairs $(a,b)$; the surviving congruences are the points of the spectrum. Cost
$O(n^2)$ per congruence.

**Algorithm C (Galois closure).** Implement $V$ and $\operatorname{Th}$ as set
maps and compute the radical $\operatorname{Th}\circ V$; verify idempotence by a
second application and verify Theorem 5 by comparing against the intersection of
prime zero classes. Cost $O(|R|\cdot|\mathrm{Spec}|)$ per evaluation.

## 9. Applications and discussion

**Proof theory and provability semantics.** Under $+ = {\vee}, \times =
{\wedge}$, $0 = $ "trivial," $1 = $ "provable," a congruence identifies proofs of
equal content, the proof spectrum is the space of consistent triviality
assignments, and $V(S)$ is the *provability locus* of $S$ — the points at which
every member of $S$ is trivial. Emptiness of $V(S)$ is joint inconsistency; the
radical computes deductive closure (Theorems 4–5).

**Tropical and idempotent geometry.** Theorems 6–7 place the additive structure
of tropical semirings inside the spectral framework, opening a path to importing
algebraic-geometric tools (closed sets, radicals, Nullstellensatz-style
dualities) into $\min$-$+$ optimization.

**Commutative algebra.** For rings the construction reproduces the classical
prime spectrum and its Zariski topology, so the theory is a conservative
extension: nothing is lost, and the semiring case is genuinely more general.

A limitation is that, without subtraction, congruences and ideals diverge, so
some ring-theoretic shortcuts (e.g. quotient by an ideal) must be reformulated in
congruence terms; this is precisely why the congruence is taken as primitive
here. Commutativity is needed only for the join statement (Theorem 7); the
topological results of §4 hold in full generality.

## 10. Future work

The following directions, carried over from the originating research cycle, frame
the next steps; they are recorded in full in the package metadata. In brief: a
quantitative theory of the radical-closure operator; spectral invariants of
idempotent semirings; and a tighter analytic dictionary between zero-free regions
and density estimates in the number-theoretic companion project.

## Appendix: formalization notes

Every definition and theorem above corresponds to a machine-checked declaration:
`SRCong`, `SRCong.zeroClass`, `SRCong.mul_left`, `SRCong.mul_right`,
`SRCong.zero_mem_zeroClass`, `SRCong.zeroClass_add_closed`,
`SRCong.zeroClass_mul_absorb`, `PrimeSRCong`, `ProofSpectrum`, `vanishes`,
`zariskiClosed`, `theoryOfSpec`, `zariskiClosed_empty_eq_univ`,
`zariskiClosed_union_eq_inter`, `zariskiClosed_antiMono`,
`zariskiClosed_iInter`, `galois_connection_theory_variety`,
`prime_cong_zero_class_prime_theory`, `radicalTheory_idempotent`,
`radical_fixpoint_iff_inter_primes`, `idempotent_add_natural_preorder`,
`idem_add_is_join`, `idem_nsmul_eq`, and `nontrivial_prime_exists`.
