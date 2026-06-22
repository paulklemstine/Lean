# Geometry Without Numbers: How Logic Grows a Landscape of Its Own

## A surprising kinship

Two of the great cathedrals of modern mathematics rarely share a room. One is
**algebraic geometry**, the study of shapes carved out by polynomial equations —
circles, spheres, elliptic curves, and the vast generalizations that occupy
much of twentieth-century mathematics. The other is **logic**, the study of
proof, provability, and what follows from what. The first feels spatial and
visual; the second feels symbolic and austere.

This article is about a bridge between them. It turns out that the *rules of
proof themselves* can be organized into a geometric landscape — with points,
with closed regions, and with a notion of "where a statement vanishes" — that
behaves uncannily like the geometry of equations. The construction rests on a
single, elementary algebraic gadget called a **semiring**, and on the idea of
asking when two computations should be considered "the same."

The payoff is a small but complete dictionary. On one side: ideals, prime
ideals, the Zariski topology, vanishing loci, and the radical of an ideal — the
core vocabulary of algebraic geometry. On the other side: congruences on a
semiring, prime congruences, closed sets of proofs, and the statements that
"come out true everywhere." Everything matches. And, importantly, every match
in this article has been checked all the way down to its logical foundations.

Let me build the landscape from the ground up.

## The raw material: semirings

A **ring** is a number system where you can add, subtract, and multiply: the
integers $\mathbb{Z}$ are the prototype. A **semiring** is the same idea but
*without subtraction*. You can add and multiply, addition and multiplication
play nicely together (the distributive law $a(b+c) = ab + ac$ holds), there is a
zero and a one — but you are not allowed to negate.

Why drop subtraction? Because the most interesting examples of "proof algebra"
and "optimization algebra" have no subtraction to offer. Consider:

- The **Boolean semiring** $\mathbb{B} = \{0, 1\}$, where "addition" is logical
  OR and "multiplication" is logical AND. Here $1 + 1 = 1$: truth OR truth is
  still truth. There is no element you could call $-1$.
- The **tropical semiring**, where "addition" is taking the minimum of two
  numbers and "multiplication" is ordinary addition. Again $x + x = \min(x,x) =
  x$, and again there is nothing to subtract.

These are not curiosities. The Boolean semiring is the algebra of *provability*:
read $1$ as "provable" and $0$ as "unproven," read $+$ as "I can derive this in
at least one way," and read $\times$ as "I need both." The tropical semiring is
the algebra of *shortest paths and cheapest costs*; it sits at the heart of
optimization, dynamic programming, and a fast-growing field called tropical
geometry. A theory that works for all semirings speaks to all of these at once.

A semiring in which $x + x = x$ for every $x$ is called **idempotent**. Both
examples above are idempotent, and idempotence will return as a hero later.

## The key move: when are two things "the same"?

Geometry begins when we decide which objects to glue together. In algebraic
geometry, you build new spaces by declaring certain polynomials to be zero. In
our setting, the analogous move is to declare certain elements **equivalent**.

A **congruence** on a semiring is an equivalence relation $\sim$ that respects
the arithmetic. Concretely, in the Lean formalization underlying this article,
a congruence (named `SRCong`) is a relation `rel` that is:

- reflexive: $a \sim a$;
- symmetric: $a \sim b \Rightarrow b \sim a$;
- transitive: $a \sim b$ and $b \sim c \Rightarrow a \sim c$;
- compatible with addition: if $a \sim b$ and $c \sim d$ then $a + c \sim b + d$;
- compatible with multiplication: if $a \sim b$ and $c \sim d$ then
  $a \cdot c \sim b \cdot d$.

A congruence is exactly the data you need to form a *quotient* — a new, coarser
semiring in which the glued elements have genuinely become equal. In the
provability reading, a congruence says "these two proofs accomplish the same
thing"; in the optimization reading, "these two computations cost the same."

In a ring, congruences are interchangeable with **ideals**: knowing which
elements are congruent to $0$ tells you everything. In a semiring this is no
longer automatic, so we keep the congruence itself as the primary object and
look at its shadow, the set of elements equivalent to zero.

## The vanishing set, and why it behaves like an ideal

For a congruence $C$, define its **zero class** to be
$$Z(C) = \{\, a : a \sim_C 0 \,\}.$$
These are the elements the congruence has "killed." In the provability reading,
$Z(C)$ is the set of statements that the proof system $C$ regards as having no
content; in geometry, it is the analogue of an ideal — the set of functions that
vanish.

The first theorem of the theory says that $Z(C)$ really does behave like an
ideal. Formally proved as `zero_mem_zeroClass`, `zeroClass_add_closed`, and
`zeroClass_mul_absorb`, the statement is:

> **Proposition (zero classes are ideals).** For every congruence $C$,
> 1. $0 \in Z(C)$;
> 2. if $a, b \in Z(C)$ then $a + b \in Z(C)$;
> 3. if $a \in Z(C)$ then $a \cdot b \in Z(C)$ for every $b$.

The third part is the "absorbing" property: an ideal swallows whatever you
multiply it by. The proofs are short and pleasant. To see that $a + b$ vanishes
when both $a$ and $b$ do, note that $a \sim 0$ and $b \sim 0$, so by
compatibility with addition $a + b \sim 0 + 0 = 0$. To see absorption, from
$a \sim 0$ and $b \sim b$ we get $a \cdot b \sim 0 \cdot b = 0$. These two
one-line arguments are the seeds of the entire geometry.

## Prime points

In ordinary geometry the most important ideals are the **prime** ones, because
they correspond to *points* (and, more generally, to irreducible subvarieties).
The defining property of a prime ideal is the schoolbook rule: if a product
$a \cdot b$ lands in the ideal, then one of the factors already did.

We copy this verbatim. A **prime congruence** (named `PrimeSRCong`) is a
congruence with the extra property
$$a \cdot b \sim 0 \ \Longrightarrow\ a \sim 0 \ \text{or}\ b \sim 0.$$
This is the logical "law of integral domains" transplanted onto proofs: a
compound claim is trivial only because one of its parts already was.

The collection of all prime congruences on a semiring $R$ is the central object
of the theory. We call it the **proof spectrum** of $R$, written
$\operatorname{Spec_{proof}}(R)$ (in Lean, `ProofSpectrum`). It is the exact
analogue of the prime spectrum $\operatorname{Spec}(R)$ of a commutative ring —
the space whose points are prime ideals and on which all of scheme-theoretic
geometry is built. A theorem named `prime_cong_zero_class_prime_theory`
confirms the link in the other direction: the zero class of a prime congruence
is itself a *prime theory*, a set of statements closed under consequence and
satisfying the integral-domain law. Points of the spectrum and prime theories
are two faces of one coin.

## Where statements vanish: the Zariski topology

Now we can do geometry. Given any statement (element) $a$ and any point (prime
congruence) $P$, say that **$a$ vanishes at $P$** if $a \sim_P 0$ — that is, if
the proof system $P$ regards $a$ as trivial. (In Lean this is the predicate
`vanishes`.)

Take a whole *set* $S$ of statements and ask: at which points do **all** of them
vanish simultaneously? That set of points is the **Zariski-closed set** cut out
by $S$,
$$V(S) = \{\, P : a \sim_P 0 \text{ for every } a \in S \,\},$$
named `zariskiClosed` in the formalization. This is the precise mirror of the
classical vanishing locus $V(S) = \{x : f(x) = 0 \text{ for all } f \in S\}$ of
a family of polynomials. The points are now proof systems instead of
coordinates, but the definition is character-for-character the same.

For these sets to deserve the name "closed," they must obey the axioms of a
topology. The theory proves exactly the required laws:

> **Theorem (the Zariski axioms hold).**
> 1. **(`zariskiClosed_empty_eq_univ`)** $V(\varnothing)$ is the entire
>    spectrum: with no equations to satisfy, every point qualifies.
> 2. **(`zariskiClosed_union_eq_inter`)** $V(S \cup T) = V(S) \cap V(T)$:
>    demanding *more* equations carves out a *smaller* set, exactly the
>    intersection.
> 3. **(`zariskiClosed_antiMono`)** If $S \subseteq T$ then
>    $V(T) \subseteq V(S)$: bigger systems of equations have fewer solutions.
> 4. **(`zariskiClosed_iInter`)** For any family of sets $\mathcal{S}$,
>    $$V\!\left(\bigcup \mathcal{S}\right) = \bigcap_{S \in \mathcal{S}} V(S).$$
>    Closed sets are closed under arbitrary intersection — the property that
>    makes the topology well defined.

Each of these is the literal semiring counterpart of a textbook fact about
varieties, and each is proved from the definitions with no extra hypotheses.
The third one is worth dwelling on, because it captures something both
geometers and logicians feel in their bones: **the more you assume, the less is
possible.** Adding axioms to a theory shrinks the class of models that satisfy
them, just as adding equations to a system shrinks the solution set.

## The dictionary made precise: a Galois connection

We now have two directions of travel. From a set of statements $S$ we get a set
of points $V(S)$. Conversely, from a set of points $X$ we can recover the
statements that vanish on *all* of them,
$$\operatorname{Th}(X) = \{\, a : a \text{ vanishes at every } P \in X \,\},$$
the **theory** of $X$ (in Lean, `theoryOfSpec`). One map turns algebra into
geometry; the other turns geometry back into algebra.

The relationship between them is the cleanest possible. The theorem
`galois_connection_theory_variety` states:

> **Theorem (Galois connection).** For every set of statements $S$ and every set
> of points $X$,
> $$S \subseteq \operatorname{Th}(X) \quad\Longleftrightarrow\quad X \subseteq V(S).$$

This single equivalence is the engine of the whole subject. It says that "every
statement in $S$ holds throughout $X$" and "every point of $X$ satisfies $S$"
are *the same assertion*, read from two directions. In classical algebraic
geometry this is the formal heart of the Nullstellensatz; here it falls out of
the definitions, and it ties provability (the $\operatorname{Th}$ side) to
semantics (the $V$ side) in one stroke.

A Galois connection always comes with a **closure operator**: apply both maps in
turn. Starting from a theory $T$, the round trip $\operatorname{Th}(V(T))$
produces the **radical** of $T$ — the set of all consequences that are forced by
the same set of points. Two further theorems pin down its behavior:

- **(`radicalTheory_idempotent`)** The radical operator is *idempotent*: taking
  the radical twice gives nothing new. Closures, once taken, stay taken.
- **(`radical_fixpoint_iff_inter_primes`)** A theory equals its own radical
  *exactly when* it is an intersection of prime theories.

The second statement is a genuine structure theorem. It tells you precisely
which theories are "geometrically honest" — the closed ones, the fixed points of
the round trip — and it identifies them as the theories you can assemble out of
points. This is the proof-theoretic shadow of the classical fact that radical
ideals are exactly the intersections of the primes containing them.

## Idempotence: where logic meets optimization

Recall the idempotent semirings, where $x + x = x$: Boolean logic and tropical
optimization both live here. The theory has a small suite of results that make
this world especially well behaved.

When addition is idempotent it secretly *is* an order. Define $x \le y$ to mean
$x + y = y$. The theorem `idempotent_add_natural_preorder` proves this is a
genuine preorder, and `idem_add_is_join` proves that the addition $x + y$ is
precisely the **join** — the least upper bound — of $x$ and $y$ in that order.
In other words, "adding" in an idempotent semiring is the same as "taking the
better of the two," which is exactly what OR does for truth values and what
$\min$ does for costs. A companion lemma, `idem_nsmul_eq`, records the
characteristic collapse: summing $n$ copies of an element gives the element
back, $n \cdot x = x$, so there is no notion of "how many times" — only
"whether."

This is the bridge promised at the start. The very same spectral machinery —
prime congruences, vanishing loci, the Zariski topology — runs over the
idempotent semirings of tropical geometry and Boolean logic. The geometry of
proofs and the geometry of optimal paths are, structurally, the same geometry.

## A concrete picture

It helps to see the landscape in a familiar case. Take the ring
$\mathbb{Z}/6\mathbb{Z}$ — the integers mod $6$. Its congruences correspond to
its ideals, which are generated by the divisors of $6$: the whole thing, and the
ideals $(2)$ and $(3)$, and $(0)$. Among these, the prime congruences are the
two coming from the prime divisors $2$ and $3$. So the proof spectrum of
$\mathbb{Z}/6\mathbb{Z}$ has exactly **two points**, one "at $2$" and one "at
$3$."

Now watch the dictionary work. The element $2$ vanishes at the point "$2$" but
not at the point "$3$"; the element $3$ vanishes at "$3$" but not at "$2$." So
$V(\{2\})$ is a single point, $V(\{3\})$ is the other single point, and
$V(\{2,3\}) = V(\{2\}) \cap V(\{3\}) = \varnothing$ — there is no proof system in
which both $2$ and $3$ are trivial, because their product $6 \equiv 0$ would
force one of them to vanish first, and they cannot *both* be the culprit. The
union-equals-intersection law is not an abstraction here; it is the statement
that $6$ factors as $2 \times 3$, seen geometrically. (A purist will note one
extra, degenerate "point" where *everything* is declared trivial at once; ignore
it and the two genuine points are exactly the primes $2$ and $3$.)

The accompanying numerical demonstration carries this out in full: it enumerates
all congruences of small finite semirings, isolates the prime ones, builds the
maps $V$ and $\operatorname{Th}$, and verifies — by direct computation, over
thousands of cases — every theorem stated above, including the Galois connection
and the radical idempotence.

## Why it matters

The first reason is unification. A single, elementary definition — a congruence
on a semiring — turns out to support the entire opening chapter of algebraic
geometry, and to do so simultaneously for rings, for Boolean logic, and for
tropical optimization. Concepts that look like accidents of one field (the
Zariski topology, the radical, the Nullstellensatz correspondence) are revealed
as features of the underlying *order and arithmetic*, present wherever you can
add and multiply without needing to subtract.

The second reason is for logic and computation specifically. Reading $+$ as "or"
and $\times$ as "and," the proof spectrum becomes a space of *consistent ways of
assigning content to statements*, and the Zariski-closed sets become *provability
loci* — the regions where a given body of claims is uniformly trivial.
Decidability questions about proof search acquire a geometric face: a closed set
is empty exactly when the assumptions are jointly contradictory, which is the
content of the $V(\{2,3\}) = \varnothing$ example writ large.

The third reason is tropical. Because idempotent semirings are exactly the home
of shortest paths, scheduling, and dynamic programming, a working spectral
geometry over them invites the tools of algebraic geometry into optimization —
and, conversely, lets the concrete intuition of "min and plus" illuminate the
abstractions of scheme theory.

None of this requires numbers in the usual sense. It requires only the decision
about when two things should count as the same — and the discovery that this
decision, made carefully, grows a landscape with points, regions, and a horizon
of its own.
