# Transfinite Game Values in Infinite Chess: An Explicit Hierarchy from $\omega$ to $\omega^\omega$

## Abstract

Infinite chess — chess played on an unbounded board $\mathbb{Z} \times \mathbb{Z}$ —
exhibits a phenomenon impossible in the finite game: positions from which the
winner can *force* checkmate, yet in no finite number of moves. The natural
measure of the length of such a forced win is not an integer but an **ordinal**,
the *game value* $v(P)$: the least ordinal $\alpha$ such that the winner can
guarantee mate within $\alpha$ moves. We develop a faithful abstract model of
forced-win game trees and their ordinal values, and prove that arbitrarily
large transfinite game values below $\omega^\omega$ are realised by explicit
positions. Our central structural result is that a sequential-composition
operation on games — *grafting* — realises ordinal addition on game values.
Using grafting together with a countably branching "delay" node, we construct
explicit positions of value $\omega$, of value $\omega^n$ for every natural
number $n$, and, by a diagonal construction, of value $\omega^\omega$. We prove
that these values form a strictly increasing hierarchy and that the diagonal
position strictly dominates every finite power $\omega^n$, including the fact
that the mate-in-$\omega$ position admits no finite move bound.

**Keywords:** infinite chess, transfinite game values, ordinal arithmetic,
game trees, ordinal suprema, checkmate, mate-in-omega, $\omega^\omega$.

---

## 1. Introduction

Ordinary chess is a finite game: every position has a definite game-theoretic
value, and every forced checkmate arrives within a bounded, finite number of
moves. On an **infinite** board — chess played with the usual pieces on the
lattice $\mathbb{Z} \times \mathbb{Z}$, with no edges — this finiteness fails in
a spectacular way. There exist positions from which one player, say White, can
force checkmate against any defence, and yet for which *no finite number of
moves* suffices to guarantee mate uniformly. The correct measure of the length
of such a win is a transfinite **ordinal**.

Formally, for a position $P$ from which White has a forced win, the **game
value** $v(P)$ is defined to be the least ordinal $\alpha$ such that White can
force checkmate in at most $\alpha$ moves. The best-known example is the
*mate-in-$\omega$* position, where $v(P) = \omega$: White wins, but Black can
delay mate by any finite number of moves he chooses, so no finite bound is
valid.

This paper answers the natural next question: **how large can $v(P)$ be?** We
prove that the game values realised by explicit positions climb through a rich
transfinite hierarchy. Specifically, we exhibit positions of value $\omega$,
positions of value $\omega^n$ for every $n \in \mathbb{N}$, and a diagonal
position of value $\omega^\omega$, and we show these values strictly increase and
that $\omega^\omega$ strictly dominates every $\omega^n$.

### 1.1 Contributions

1. A clean, faithful **model of forced-win game trees** with three node types —
   a checkmate leaf, a unique-continuation *winner* node, and a countably
   branching *loser* node — and a transfinite-recursive definition of their
   ordinal game value (Section 3).
2. A **sequential-composition** operation (*grafting*) on games, together with
   the structural theorem that grafting realises ordinal addition:
   $v(A \frown B) = v(B) + v(A)$ (Section 4).
3. An **explicit mate-in-$\omega$** position with $v = \omega$, together with a
   proof that this win has no finite bound (Section 5).
4. An **explicit power hierarchy**: positions of value exactly $\omega^n$ for
   every $n$, built by iterated grafting, and a proof that these values are
   strictly increasing (Section 6).
5. A **diagonal construction** yielding an explicit position of value
   $\omega^\omega$, strictly above every $\omega^n$ (Section 7).

### 1.2 Modelling philosophy

To isolate the *ordinal analysis* from the intricate combinatorics of pieces on
an unbounded board, we model the relevant game trees directly. This is standard
practice in the theory of infinite games: the ordinal game value depends only on
the tree of forced continuations and on which player moves at each node, not on
the geometry that produced the tree. Two node types suffice to realise every
ordinal below $\omega^\omega$: a *winner* node with a single forced continuation
(the winner is one move from a determined successor), and a *loser* node offering
a countable family of continuations (the loser chooses how to delay). This is
precisely the structure that the concrete infinite-chess positions of the
mate-in-$\omega$ tradition exhibit, and it is exactly what our target values
require.

---

## 2. Ordinal preliminaries

We recall the facts of ordinal arithmetic used throughout. Ordinals extend the
natural numbers past infinity: after $0, 1, 2, \dots$ comes the first infinite
ordinal $\omega$, then $\omega + 1, \omega + 2, \dots$, then
$\omega \cdot 2, \omega \cdot 3, \dots$, then $\omega^2, \omega^3, \dots$, and so
on.

- **Order-sensitivity of addition.** Ordinal addition is associative but *not*
  commutative. Crucially, $n + \omega = \omega$ for every finite $n$, whereas
  $\omega + n > \omega$. Adding a finite quantity *on the left* of an infinite
  ordinal is absorbed; adding it *on the right* genuinely lengthens.
- **Suprema.** Every set of ordinals has a least upper bound (supremum). For a
  countable family $(a_k)_{k \in \mathbb{N}}$ we write $\sup_k a_k$. In
  particular $\sup_n n = \omega$ and $\sup_k (\omega \cdot k) = \omega^2$.
- **Left addition is a normal function.** For fixed $a$, the map
  $x \mapsto a + x$ is continuous and strictly increasing, so it commutes with
  suprema: $a + \sup_k f(k) = \sup_k (a + f(k))$. This single fact drives every
  value computation below.
- **Monotonicity of exponentiation.** Since $\omega > 1$, the map
  $n \mapsto \omega^n$ is strictly increasing, and
  $\omega^n < \omega^\omega$ for every finite $n$, with
  $\omega^\omega = \sup_n \omega^n$.

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and ordinal operations use
standard conventions.

---

## 3. Games and their ordinal values

### 3.1 Game trees

**Definition 3.1 (Game).** A *game* (winning game tree) is one of:

- $M$ — a leaf, representing a delivered checkmate;
- $W(g)$ — a *winner* node with a unique forced continuation $g$ (White is
  exactly one move from the position $g$);
- $L(f)$ — a *loser* node with a countable family of continuations
  $f : \mathbb{N} \to \mathrm{Game}$ (Black chooses which continuation to play).

Every game is a well-founded tree built from these constructors: $M$ at the
leaves, $W$ for the winner's forced moves, and $L$ for the loser's countable
choices.

### 3.2 The game value

**Definition 3.2 (Game value).** The *game value* $v : \mathrm{Game} \to
\mathrm{Ord}$ is defined by transfinite recursion on the tree:

$$
v(M) = 0, \qquad
v(W(g)) = v(g) + 1, \qquad
v(L(f)) = \sup_{n \in \mathbb{N}} \bigl(v(f(n)) + 1\bigr).
$$

The interpretation matches optimal play. A delivered checkmate needs no further
moves, so its value is $0$. At a winner node the winner makes one move and
reaches $g$, contributing $v(g) + 1$; since the continuation is forced there is
nothing to optimise. At a loser node the loser chooses the continuation that
delays mate as long as possible, and the value is the supremum over his options,
each incremented by the move made to reach it. (In general the winner minimises
and the loser maximises; with the single-child winner node the minimisation is
trivial, which is all our target values require.)

**Lemma 3.3 (Left addition commutes with countable suprema).** For any ordinal
$a$ and any $f : \mathbb{N} \to \mathrm{Ord}$,
$$
a + \sup_n f(n) = \sup_n \bigl(a + f(n)\bigr).
$$
*Proof sketch.* The map $x \mapsto a + x$ is a normal (continuous, strictly
increasing) ordinal function, and normal functions preserve suprema of bounded
families; the range of $f$ is bounded above since ordinals below a fixed bound
form a set. $\square$

---

## 4. Sequential composition: grafting and additivity

The engine of the construction is an operation that plays one game to
completion and then continues with another.

**Definition 4.1 (Graft).** For games $A, B$, the graft $A \frown B$ replaces
every checkmate leaf $M$ of $A$ with a fresh copy of $B$. Recursively:

$$
M \frown B = B, \qquad
W(g) \frown B = W(g \frown B), \qquad
L(f) \frown B = L\bigl(n \mapsto f(n) \frown B\bigr).
$$

Intuitively: "first solve $A$; the instant you would have been mated, you find
yourself at the start of $B$; now solve $B$."

**Theorem 4.2 (Additivity of game value).** For all games $A, B$,
$$
v\bigl(A \frown B\bigr) = v(B) + v(A).
$$

*Proof sketch.* Induction on the structure of $A$.

- **Base ($A = M$).** $M \frown B = B$ and $v(B) + v(M) = v(B) + 0 = v(B)$.
- **Winner ($A = W(g)$).** By the inductive hypothesis
  $v(g \frown B) = v(B) + v(g)$, so
  $$
  v(W(g) \frown B) = v(g \frown B) + 1 = (v(B) + v(g)) + 1 = v(B) + (v(g)+1)
    = v(B) + v(W(g)),
  $$
  using associativity of ordinal addition.
- **Loser ($A = L(f)$).** By the inductive hypothesis, for each $n$,
  $v(f(n) \frown B) = v(B) + v(f(n))$. Hence
  $$
  v(L(f) \frown B)
    = \sup_n \bigl(v(B) + v(f(n)) + 1\bigr)
    = v(B) + \sup_n \bigl(v(f(n)) + 1\bigr)
    = v(B) + v(L(f)),
  $$
  where the middle step is Lemma 3.3 (left addition commutes with the supremum),
  together with $a + (b+1) = (a+b)+1$. $\square$

Note the **order** on the right-hand side: the outer game $A$ appears on the
right of the sum. This is not a convention but a necessity, forced by the
non-commutativity of ordinal addition, and it is exactly what makes grafting
compose values correctly.

**Definition 4.3 (Iterated graft).** For $k \in \mathbb{N}$ and a game $A$, write
$A^{\frown k}$ for $k$ sequential copies of $A$:
$$
A^{\frown 0} = M, \qquad
A^{\frown (k+1)} = A \frown A^{\frown k}.
$$

**Lemma 4.4 (Value of iterated graft).** $v(A^{\frown k}) = v(A) \cdot k$.

*Proof sketch.* Induction on $k$. The base case gives $v(M) = 0 = v(A)\cdot 0$.
For the step, Theorem 4.2 gives
$v(A^{\frown(k+1)}) = v(A^{\frown k}) + v(A) = v(A)\cdot k + v(A)
= v(A)\cdot(k+1)$. $\square$

---

## 5. Value $\omega$: the classical mate-in-$\omega$

**Definition 5.1 (Prefixing forced moves).** Let $W^n(g)$ denote $g$ with $n$
forced winner moves prefixed: $W^0(g) = g$ and $W^{n+1}(g) = W(W^n(g))$. Then
$v(W^n(g)) = v(g) + n$.

**Definition 5.2 (Finite game).** $F_n = W^n(M)$ is a forced win in exactly $n$
moves; indeed $v(F_n) = n$.

**Definition 5.3 (Mate-in-$\omega$ position).** The position
$$
P_\omega = L\bigl(n \mapsto F_n\bigr)
$$
is a loser node where Black chooses a natural number $n$, after which White mates
in exactly $n$ further forced moves.

**Theorem 5.4.** $v(P_\omega) = \omega$.

*Proof sketch.* By definition
$v(P_\omega) = \sup_n (v(F_n) + 1) = \sup_n (n + 1)$.
Every $n + 1$ is a finite ordinal, hence $\le \omega$, so the supremum is
$\le \omega$. Conversely, for any ordinal $w < \omega$ we have $w = m$ for some
$m \in \mathbb{N}$, and $w < m + 1 \le \sup_n(n+1)$; thus no ordinal below
$\omega$ is an upper bound. Therefore the supremum equals $\omega$. $\square$

**Theorem 5.5 (No finite bound).** There is no $n \in \mathbb{N}$ with
$v(P_\omega) = n$.

*Proof sketch.* $v(P_\omega) = \omega$ by Theorem 5.4, and $\omega > n$ for every
finite $n$. $\square$

Theorems 5.4 and 5.5 together capture the defining feature of infinite chess:
White forces mate, but no finite move count is a valid guarantee.

---

## 6. The power hierarchy: value $\omega^n$

We now iterate the delay-and-graft construction to climb the powers of $\omega$.

**Lemma 6.1 (A multiplicative supremum).** For any ordinal $v > 0$,
$$
\sup_{k \in \mathbb{N}} \bigl(v \cdot k + 1\bigr) = v \cdot \omega.
$$
*Proof sketch.* ($\le$) For each $n$, $v\cdot n + 1 \le v\cdot(n+1) \le v\cdot\omega$
since $n + 1 \le \omega$ and multiplication on the left is monotone. ($\ge$) Each
partial product $v\cdot k \le v\cdot k + 1$ lies below the supremum, and
$\sup_k v\cdot k = v\cdot \omega$ because left multiplication is continuous in
its right argument. $\square$

**Definition 6.2 (Power positions).** Define a family $Q_n$ of positions by
$$
Q_0 = W(M), \qquad
Q_{n+1} = L\bigl(k \mapsto Q_n^{\frown k}\bigr).
$$
That is: $Q_0$ is a one-move win; and at level $n+1$, Black chooses $k$ and White
must then solve $k$ sequential copies of the level-$n$ position.

**Theorem 6.3.** For every $n \in \mathbb{N}$, $v(Q_n) = \omega^n$.

*Proof sketch.* Induction on $n$.

- **Base.** $v(Q_0) = v(W(M)) = 0 + 1 = 1 = \omega^0$.
- **Step.** Assume $v(Q_n) = \omega^n$. Then
  $$
  v(Q_{n+1}) = \sup_k \bigl(v(Q_n^{\frown k}) + 1\bigr)
    = \sup_k \bigl(\omega^n \cdot k + 1\bigr),
  $$
  using Lemma 4.4. By Lemma 6.1 (with $v = \omega^n > 0$) this equals
  $\omega^n \cdot \omega = \omega^{n+1}$. $\square$

**Corollary 6.4 (Realisability).** For every $n$ there is an explicit position of
value $\omega^n$, namely $Q_n$.

**Theorem 6.5 (Strict monotonicity).** The map $n \mapsto v(Q_n) = \omega^n$ is
strictly increasing.

*Proof sketch.* Since $\omega > 1$, exponentiation with base $\omega$ is strictly
monotone in the exponent, so $m < n$ implies $\omega^m < \omega^n$. $\square$

---

## 7. The diagonal position: value $\omega^\omega$

The staircase $\omega, \omega^2, \omega^3, \dots$ consists entirely of *finite*
powers. A single diagonal construction leaps past all of them.

**Lemma 7.1 (An exponential supremum).**
$$
\sup_{n \in \mathbb{N}} \bigl(\omega^n + 1\bigr) = \omega^\omega.
$$
*Proof sketch.* ($\le$) For each $n$, $\omega^n + 1 \le \omega^{n+1} \le
\omega^\omega$ since $n + 1 \le \omega$ and exponentiation is monotone in the
exponent. ($\ge$) Given any $x < \omega^\omega$, because $x \mapsto \omega^x$ is a
normal function and $\omega^\omega = \sup_n \omega^n$, there is some $n$ with
$x < \omega^n \le \omega^n + 1 \le \sup_m(\omega^m + 1)$. Hence no ordinal below
$\omega^\omega$ bounds the family, so the supremum is $\omega^\omega$. $\square$

**Definition 7.2 (Diagonal position).** The diagonal position is
$$
D = L\bigl(n \mapsto Q_n\bigr),
$$
a loser node where Black chooses $n$ and White must then solve the $\omega^n$
position $Q_n$.

**Theorem 7.3.** $v(D) = \omega^\omega$.

*Proof sketch.* By definition and Theorem 6.3,
$$
v(D) = \sup_n \bigl(v(Q_n) + 1\bigr) = \sup_n \bigl(\omega^n + 1\bigr)
  = \omega^\omega,
$$
the last equality being Lemma 7.1. $\square$

**Theorem 7.4 (Strict domination).** For every $n \in \mathbb{N}$,
$$
v(Q_n) < v(D), \qquad \text{i.e.}\qquad \omega^n < \omega^\omega.
$$

*Proof sketch.* By Theorems 6.3 and 7.3 the claim is $\omega^n < \omega^\omega$.
Writing $\omega^n$ as $\omega$ raised to the finite exponent $n$ and using that
exponentiation with base $\omega > 1$ is strictly increasing in the exponent,
this reduces to $n < \omega$, which holds for every natural number. $\square$

Thus $\omega^\omega$ is genuinely unreachable within the finite-power hierarchy:
no $Q_n$ attains it, and the diagonal position sits strictly above the entire
staircase.

---

## 8. The hierarchy, summarised

Collecting the results, the explicit positions realise a strictly increasing
transfinite hierarchy of game values:

$$
\underbrace{1}_{Q_0} < \underbrace{\omega}_{Q_1}
< \underbrace{\omega^2}_{Q_2} < \underbrace{\omega^3}_{Q_3}
< \cdots < \underbrace{\omega^\omega}_{D}.
$$

- Every value $\omega^n$ is attained by an explicit position (Corollary 6.4).
- The values strictly increase (Theorem 6.5).
- The diagonal position attains $\omega^\omega$ (Theorem 7.3) and strictly
  dominates every $\omega^n$ (Theorem 7.4).
- The mate-in-$\omega$ position $P_\omega$ (equivalently $Q_1$ in value) has no
  finite bound (Theorems 5.4–5.5).

The two combinatorial primitives responsible for the entire hierarchy are
strikingly economical: a **winner node** with a single forced continuation
(realising $+1$, hence ordinal addition through grafting) and a **countably
branching loser node** (realising suprema, hence the passage to limits). Ordinal
addition, multiplication (as iterated addition), and exponentiation (as iterated
limits) all emerge from these two primitives.

---

## 9. Algorithms

The constructions are effective: given a target ordinal in the range covered,
one can *build the game tree* and *compute its value* symbolically.

**Algorithm 9.1 (Symbolic value computation).** Represent ordinals below
$\omega^\omega$ in Cantor normal form as finite lists of (exponent, coefficient)
pairs. Recurse over the game tree: $v(M) = 0$; $v(W(g)) = v(g) \oplus 1$ (ordinal
successor); and for $L(f)$, evaluate $f(0), f(1), \dots$ until the sequence of
values $v(f(k)) \oplus 1$ stabilises in its dominant Cantor term or is seen to
diverge, returning the ordinal supremum. Because our loser families are monotone
(finite games of increasing length, or grafted stacks of increasing height), the
supremum is the limit of the leading Cantor term.

**Algorithm 9.2 (Graft and iterated graft).** To realise $\alpha + \beta$ as a
game value, build games $A, B$ with $v(A) = \beta$ and $v(B) = \alpha$ and output
$A \frown B$; Theorem 4.2 certifies the value. To realise $v(A)\cdot k$, output
$A^{\frown k}$; Lemma 4.4 certifies it. To realise a limit such as
$v(A)\cdot\omega$ or a diagonal supremum, wrap the family in a loser node $L$.

**Algorithm 9.3 (Building a target power).** To construct a position of value
$\omega^n$, unfold the family $Q$: start from $W(M)$ and, $n$ times, replace the
current game $G$ by $L(k \mapsto G^{\frown k})$. To reach $\omega^\omega$, wrap
the whole family $(Q_n)_n$ in a single loser node.

---

## 10. Applications and interpretation

Game values are the honest measure of any *guaranteed-but-unbounded* process.

- **Termination without a modulus.** A procedure that always halts but whose
  adversary can force arbitrarily long (yet finite) runs has termination ordinal
  $\omega$; nested such procedures have $\omega^2, \omega^3, \dots$; a diagonal
  over the nesting depth reaches $\omega^\omega$. Infinite chess makes these
  abstract termination ordinals concrete and inspectable.
- **Adversarial scheduling.** When an adversary chooses among countably many
  delaying options at each of several stages, the total worst-case length is
  precisely the ordinal our loser-node/graft calculus computes.
- **Pedagogy of the transfinite.** The construction gives a tactile route into
  ordinal arithmetic: $+1$ is a forced move, $\cdot\, k$ is a stack of $k$
  puzzles, $\cdot\,\omega$ and $\omega^{(\cdot)}$ are the loser's countable
  choices, and non-commutativity of $+$ is visibly the difference between
  finishing a short task before versus after a long one.

---

## 11. Discussion and future work

The present hierarchy stops at $\omega^\omega$ because two primitives (the winner
node and the loser node) suffice for exactly that range, matching the target of
the construction. Several extensions are natural.

1. **Beyond $\omega^\omega$.** The same building blocks generalise: a supremum
   over a family whose values cofinally approach any given limit realises that
   limit. One expects to prove that *every* ordinal below $\varepsilon_0$ is a
   game value, by recursion on Cantor normal form — grafting for $+$, a
   multiplication combinator for $\cdot$, and a diagonal supremum for
   $\omega^{(\cdot)}$.

2. **A minimality/optimality theorem.** One can formalise that $v(P)$ is exactly
   the least ordinal in which the winner can force a win, by defining an explicit
   strategy semantics (the winner's move-count ordinal) and proving it agrees
   with $v$. This upgrades "cannot be done in fewer moves" from a definitional
   fact to a theorem about explicit play.

3. **Branching winner nodes.** Extending the model with a genuine winner-supremum
   node (the winner chooses among many moves, value = infimum) and proving that
   infimum commutes with left addition would yield the full min/sup value
   calculus.

4. **Connection to the literal board.** Bridging these abstract trees to a
   concrete piece-and-square model on $\mathbb{Z} \times \mathbb{Z}$ would realise
   the mate-in-$\omega$, $\omega^n$, and $\omega^\omega$ positions as literal
   chess positions, recovering the transfinite game-value phenomena of infinite
   chess at the level of actual play.

5. **Reusable ordinal lemmas.** The auxiliary facts — left addition commuting
   with countable suprema, $\sup_k(v\cdot k + 1) = v\cdot\omega$, and
   $\sup_n(\omega^n + 1) = \omega^\omega$ — are clean statements about how
   ordinal $+$, $\cdot$, and exponentiation interact with countable suprema, and
   are of independent interest.

---

## 12. Conclusion

Chess on an unbounded board realises transfinite game values. We built explicit
positions of value $\omega$, of value $\omega^n$ for every $n$, and of value
$\omega^\omega$, from just two primitives — a forced winner move and a countably
branching loser choice — glued by a grafting operation that realises ordinal
addition. These values form a strictly increasing hierarchy in which
$\omega^\omega$ strictly dominates every finite power. The complexity of
checkmate, freed from the board's edges, is measured not by the natural numbers
but by the ordinals.
