# A Random Walk That Trusts Itself

### A guided tour of the dictionary between Markov chains and possible worlds

A token hops between a handful of rooms. At each step it consults a table of
probabilities and jumps. That is a **Markov chain**, and it is the workhorse behind
queueing theory, card shuffling, population genetics and PageRank.

Somewhere else entirely, logicians study statements of the form "necessarily $\varphi$",
written $\Box\varphi$, using **possible worlds**: a set $W$ of worlds with an accessibility
relation $R$, and the rule

$$w \Vdash \Box\varphi \quad\Longleftrightarrow\quad v \Vdash \varphi \ \text{ for every } v \text{ with } w \mathrel{R} v .$$

This page is a guided tour of a dictionary that makes those two subjects the *same*
subject — and of what the dictionary buys you: an impossibility theorem about
self-reference, an exact arithmetic criterion for when a random walk mixes, sharp
bounds on how long mixing takes, and a precise account of what "eventually recurring"
means.

Nothing below assumes prior knowledge of either field. Where a proof or a piece of
background would interrupt the story, it is folded away behind a triangle — click to
open it.

---

## 1. Throw away the numbers, keep the zeros

The whole bridge rests on one deliberately crude move. Given a transition matrix $P$,
forget the probabilities and remember only which of them are nonzero. The **support
frame** of $P$ has the states as worlds, and

$$u \mathrel{R} v \quad :\Longleftrightarrow\quad P(u,v) > 0,$$

read as "the token *can* move from $u$ to $v$".

This looks lossy. It is — but not at all about *possibility*:

> **Support-Power Theorem.** For a matrix with nonnegative entries, the $n$-step
> probability $P^n(u,v)$ is strictly positive if and only if the support frame carries a
> path of exactly $n$ edges from $u$ to $v$.

<details>
<summary>Click to reveal the proof</summary>

Induct on $n$. For $n = 0$ both sides say $u = v$. For the step,

$$P^{n+1}(u,v) = \sum_z P(u,z)\,P^n(z,v)$$

is a sum of nonnegative terms, so it is positive exactly when one term is positive, i.e.
when there is a $z$ with $P(u,z) > 0$ and $P^n(z,v) > 0$. By the induction hypothesis that
is precisely the existence of $z$ with $u \mathrel{R} z$ and a $n$-path $z \to v$. The
contrapositive form of the forward direction is the cleanest: if no such $z$ exists, every
summand vanishes, so the sum does.

Notice what makes it work: *no cancellation*. Nonnegativity is the entire hypothesis;
row sums play no role.
</details>

Because of this theorem, everything below can be computed without ever touching a
floating-point number, by running matrix multiplication in the Boolean semiring
(`OR` for `+`, `AND` for `×`). That is exactly what the first algorithm does, and it is
also the practical reason to prefer supports: no underflow, ever.

{{algorithm:0}}

---

## 2. Play with it

Before any more theory, get your hands on the object. In the laboratory below you draw a
transition structure by clicking cells, and every panel updates live: the support powers,
the return-time spectrum of a chosen state, the mixing verdict, the logical reading, and
the long-run structure.

Three things are worth doing right away.

1. Load **deterministic 4-cycle** and watch the support powers: a single positive
   diagonal marches around forever and never fills in.
2. Load **loopless aperiodic 3-state** — a chain with *no* holding probability anywhere —
   and watch it become totally positive at step 5 and stay there.
3. Load **a dead end** and read the logic panel: this is the one structure that a genuine
   stochastic matrix can never produce.

{{interactive_demo:0}}

---

## 3. Probability abhors a dead end

Here is the first theorem you can see in the widget. If the row of $P$ at $u$ sums to $1$,
some entry of it is positive, so **every state has a successor**. Logicians call such a
frame *serial*.

Seriality is the fingerprint of probability in this dictionary, and it is fatal to a
famous axiom. In the [logic of provability](https://plato.stanford.edu/entries/logic-provability/),
where $\Box$ means "is provable in arithmetic", the governing principle is **Löb's axiom**

$$\Box(\Box\varphi \to \varphi) \to \Box\varphi ,$$

which is Gödel's second incompleteness theorem in modal dress. It is valid exactly on the
frames that are transitive and *converse well-founded*: every forward chain must eventually
stop dead.

A stochastic chain never stops. Hence:

> **No nonempty Markov chain is a provability frame.** Löb's axiom is valid on the support
> frame of no nonempty stochastic matrix.

<details>
<summary>Click to reveal why seriality and converse well-foundedness clash</summary>

Suppose the converse relation were well-founded. Then we may prove a property at every
world by assuming it at all successors. Take the property to be **false**: seriality hands
us a successor $v$ of $w$, and the induction hypothesis at $v$ is falsehood. So falsehood
holds at every world — impossible unless there are no worlds at all.

The argument uses nothing about numbers, only that successors always exist.
</details>

What a chain does *instead* is the mirror image. Its valid formulas form a system that is
consistent, that proves its own consistency statement $\neg\Box\bot$ — the very sentence
Gödel forbids a strong theory to prove about itself — and that is, necessarily, not
Löbian. And it internalises its full soundness schema $\Box\varphi \to \varphi$ exactly
when the chain is **lazy**: $P(w,w) > 0$ at every state. The modeller's habit of letting
the token sometimes stay put is, read logically, self-declared soundness.

---

## 4. The spectrum of a state

Zoom in on one state $w$ and ask: for which exponents $n$ does the **reflection principle
of degree $n$**, $\Box^n\varphi \to \varphi$, hold at $w$ for every $\varphi$? Call the set
of such $n$ the **soundness spectrum** of $w$.

> **Spectrum Theorem.** Degree $n$ holds at $w$ if and only if $w$ lies on a closed walk of
> exactly $n$ steps — equivalently, if and only if $P^n(w,w) > 0$.

<details>
<summary>Click to reveal the proof (it is two lines, one per direction)</summary>

If $w \mathrel{R^n} w$ and $\Box^n\varphi$ holds at $w$, then $\varphi$ holds at every world
reachable in $n$ steps, in particular at $w$ itself.

Conversely, if $w$ is *not* reachable from itself in $n$ steps, make a variable $p$ true at
every world except $w$. Then every $n$-step successor of $w$ satisfies $p$, so $\Box^n p$
holds at $w$, while $p$ fails there. The principle is refuted.
</details>

Two facts now follow instantly. First, the spectrum is closed under addition: loop twice.
Together with the empty loop of length $0$, it is an **additive submonoid of $\mathbb{N}$**
— a *numerical semigroup*, the object behind the
[Chicken McNugget problem](https://en.wikipedia.org/wiki/Coin_problem). Second, for the
deterministic $n$-cycle the spectrum is exactly $n\mathbb{N}$: the logical degree of
self-trust is literally the probabilistic **period**.

The picture below shows several spectra side by side. Look at the last one — three loops of
lengths $6$, $10$ and $15$ glued at a common state. Its gcd is $1$, but *no two of those
lengths are coprime*.

{{visualization:0}}

---

## 5. The criterion: when does a chain mix?

The organising question is when the spectrum is **cofinite**: when does the walk admit a
return of *every* sufficiently large length?

If two return lengths are coprime, the Chicken McNugget theorem answers it. But the
$\langle 6, 10, 15\rangle$ example shows that is not the real theorem. The real theorem
mentions no generators at all.

> **Cofiniteness Criterion.** An additive submonoid $S \subseteq \mathbb{N}$ contains every
> sufficiently large integer if and only if no integer $d \ge 2$ divides all of $S$.

<details>
<summary>Click to reveal the proof — a subgroup trick and a napkin computation</summary>

**Easy direction.** If everything from $N$ on is in $S$, then given $d \ge 2$ the element
$Nd + 1$ is in $S$ and is not divisible by $d$ (otherwise $d \mid 1$).

**Hard direction, step one: get two consecutive elements.** Form the set of *differences*
$D = \{x - y : x, y \in S\} \subseteq \mathbb{Z}$. It is a subgroup, and
[every subgroup of $\mathbb{Z}$ is cyclic](https://en.wikipedia.org/wiki/Cyclic_group), so
$D = d\mathbb{Z}$. Since $S \subseteq D$, this $d$ divides every element of $S$. If $d = 0$
then $S = \{0\}$, which $2$ divides; if $d \ge 2$ we contradict the hypothesis directly.
So $d = 1$, meaning $1 = x - y$ for some $x, y \in S$: two consecutive elements $y, y+1$.

**Step two: the box argument.** Let $n \ge y^2$ and divide: $n = qy + r$ with $0 \le r < y$.
Since $n \ge y^2$ we get $q \ge y > r$, so

$$n = (q - r)\,y + r\,(y+1)$$

is a nonnegative combination of $y$ and $y+1$, hence lies in $S$. Everything from $y^2$ on
is in $S$.

The reason this beats the two-generator route is that the right invariant is the common
divisor of the *whole monoid*, not any chosen pair of generators.
</details>

Translated through the dictionary, this is the sharp form of a cornerstone of Markov-chain
theory. A finite chain is **irreducible** when every state reaches every state, and
**primitive** when some power of $P$ is strictly positive in every entry — the hypothesis
that makes the [Perron–Frobenius theorem](https://en.wikipedia.org/wiki/Perron%E2%80%93Frobenius_theorem)
deliver convergence to a unique stationary distribution.

> **Primitivity is Aperiodicity.** For a finite irreducible chain, $P$ is primitive
> $\iff$ one — equivalently every — state is aperiodic, meaning no $d \ge 2$ divides all its
> return lengths.

The textbook hypotheses collapse into special cases: a self-loop is $1 \in S$; two coprime
cycles is $\gcd = 1$; and the loopless three-state chain in the widget is primitive without
either. Go back and toggle the self-loops off the **lazy 4-cycle** to watch aperiodicity die
and the powers stop filling in.

{{algorithm:1}}

---

## 6. How long is "eventually"?

A cofiniteness statement with an unspecified threshold is unsatisfying. The bounds come from
a pigeonhole principle about paths.

> **Diameter Principle.** In a frame with $N$ worlds, anything reachable at all is reachable
> in fewer than $N$ steps.

<details>
<summary>Click to reveal the excision argument</summary>

Write a path as a function $f$ from step indices to worlds with $f(i) \mathrel{R} f(i+1)$.
If the path has length $k \ge N$, then $f(0), \dots, f(k)$ are more than $N$ values in a set
of size $N$, so $f(i) = f(j)$ for some $i < j$. Splice the loop out:

$$g(m) = \begin{cases} f(m), & m \le i,\\ f\bigl(m + (j-i)\bigr), & m > i,\end{cases}$$

which is again a path, of length $k - (j-i) < k$. Repeat until the length drops below $N$.
</details>

From this: if every state of an $N$-state irreducible chain holds with positive probability,
$P^k$ is totally positive for **every** $k \ge N-1$ — reach the target in fewer than $N$
steps, then idle. If only one state holds, route through it and the bound is $2(N-1)$.

And the first bound is attained. On the **nearest-neighbour chain** on $\{0, \dots, N-1\}$
one step changes the index by at most one, so getting from $0$ to $N-1$ needs $N-1$ steps
exactly.

{{visualization:2}}

---

## 7. Survival is not return

One last question, with a twist. The dual of $\Box$ is the diamond $\Diamond$, "some
accessible world satisfies...". Call a set $X$ of states *post-fixed* when every member has
a successor inside $X$; the union of all post-fixed sets is the **greatest fixed point** of
the diamond. Intuitively it collects the states from which the walk can go on forever, and
on a finite state space going on forever means repeating.

The natural guess is that this is the **recurrent** set — the states the walk returns to,
where all long-run behaviour lives. The guess is false, and the counterexample has two
states.

> **Recurrence Identification.** On a finite frame, the greatest fixed point of the diamond
> is exactly the set of worlds from which some world lying on a cycle is *reachable*.

<details>
<summary>Click to reveal the proof and the counterexample</summary>

*($\supseteq$)* The set of worlds reaching recurrence is post-fixed: if $w$ reaches a
recurrent $z$, then either $w = z$, and a positive-length cycle at $z$ supplies a successor
that still reaches $z$; or the first step of the route to $z$ lands on a world that still
reaches $z$. Maximality of the greatest fixed point does the rest.

*($\subseteq$)* Let $X$ be post-fixed and $w \in X$. Choose for each $x \in X$ a successor
$c(x) \in X$ and iterate: $w, c(w), c^2(w), \dots$ stays in $X$ and lives in a finite set, so
$c^i(w) = c^j(w)$ for some $i < j$. Then $c^i(w)$ sits on a cycle of length $j-i > 0$ and is
reachable from $w$.

*The counterexample.* Take two states with the rule "jump to state $1$ and stay". State $0$
is transient — it leaves and never returns — but $\{0,1\}$ is post-fixed, so $0$ is in the
greatest fixed point. Load the **absorbing chain** preset above and read the last panel.
</details>

The moral is a genuine limitation of expressive power: the diamond only ever looks *forward*,
so it sees that the walk survives but not that it comes home. Combined with seriality this
gives a clean statement about chains: on a finite stochastic chain, from *every* state one
can reach a state with positive return probability.

{{algorithm:2}}

---

## 8. Aggregation is a morphism

Practitioners shrink a chain by merging states. The merge is legitimate — the aggregate is
again Markov — when the map $f$ is **strongly lumpable**: the total probability of moving
from $u$ into the block $f^{-1}(y)$ depends on $u$ only through its own block. That condition
is *precisely* the modal notion of a **bounded morphism**.

<details>
<summary>Click to reveal the two-line verification</summary>

*Forth.* If $P(u,v) > 0$ then that single term bounds below the block sum over
$f^{-1}(f(v))$, which equals $Q(f(u), f(v))$; so $f(u) \to f(v)$ in the quotient.

*Back.* If $Q(f(u), y) > 0$ then the block sum over $f^{-1}(y)$ is positive, and a positive
sum of nonnegative reals has a positive summand $P(u,v)$ with $f(v) = y$.

Only nonnegativity is used — row-stochasticity plays no role whatsoever.
</details>

Consequences follow immediately: validity transfers along surjective lumpings, so aggregation
can only *add* valid principles; and laziness is inherited. It also yields limitative results
with tiny witnesses. The $2$-cycle has no holding probability, it lumps onto the one-state
chain, and that one *does* hold — so **no set of modal axioms can force a chain to have zero
holding probabilities**.

---

## 9. See it all at once

The script below reproduces every numerical claim on this page: the agreement between matrix
powers and path counting, spectra and their periods, the cofiniteness criterion including the
$\langle 6,10,15 \rangle$ case, primitivity of the loopless chain, the exponent bounds and
their sharpness, the fixed-point identification, and the lumpability checks.

{{demo:0}}

And here is the fill-in picture that started it all: a periodic chain permuting one positive
diagonal forever, next to an aperiodic one saturating and staying saturated.

{{visualization:1}}

---

## Where to go next

- The same combinatorial gadget — an $(n+m)$-path splits at its $n$-th vertex — is
  simultaneously iterated necessity, matrix multiplication, and addition of return times.
  Prove it once, get three theorems.
- The dictionary sees supports, not rates. Attaching quantitative
  [mixing times](https://en.wikipedia.org/wiki/Markov_chain_mixing_time) to the combinatorial
  exponents above is the natural next step.
- Only *strong* lumpability is a morphism. Weak lumpability, which depends on the initial
  distribution, is not — and the transfer principle genuinely fails for it.
- The recurrent set is not definable by a forward-looking fixed point. Which extension of the
  language defines it?

The token hopping between rooms turns out to have an opinion about its own soundness. The
surprise is that it is always, and provably, an optimist.
