# Why Dynamic Programming Never Misses

### A guided tour of soundness, completeness, and the algebra underneath

---

## 0. The promise

Every time a phone turns a mumbled sentence into text, a navigation app quotes a driving time, or a
genome browser aligns two sequences, the same silent promise is made:

> *Out of the astronomically many possibilities, this one is the best.*

The number really is astronomical. If you must choose one of $|S|$ states at each of $n+1$ stages,
there are $|S|^{n+1}$ candidates: with $|S| = 40$ and $n = 19$ that is about $10^{32}$ — more than
the number of atoms in a human body. No machine will ever look at them all.

And yet the machine answers in milliseconds, and answers *exactly*. This page is about the theorem
that makes the promise true. Not the algorithm — the algorithm fits on a napkin — but the
**guarantee** that the frighteningly cheap thing it does is exactly as good as the frighteningly
expensive thing it refuses to do.

The guarantee has a one-line statement, and everything below is an unpacking of it:

> **Every labelling is dominated by some run of the dynamic program.**

---

## 1. The setup in one picture

Picture a corridor of rooms, one per **stage** $0, 1, 2, \dots$. In each room stands the same finite
cast of **states** $S$ — phonemes, road junctions, "match / insert / delete".

- A **labelling** is a choice of one state per room: a function $f$ with $f(i) \in S$.
- The score is **local and additive**: an initial weight $\mathrm{init}(s)$ for where you begin, plus
  a transition weight $\mathrm{step}_i(s,t)$ for each move from $s$ at stage $i$ to $t$ at stage $i+1$.

$$\mathrm{score}(f,0) = \mathrm{init}(f(0)), \qquad \mathrm{score}(f,n+1) = \mathrm{score}(f,n) + \mathrm{step}_n\big(f(n), f(n{+}1)\big).$$

Bellman's move is to stop asking about whole labellings and ask about **prefixes ending somewhere
specific**. Define
$$V(n,s) = \text{the best score of a labelling of stages } 0,\dots,n \text{ ending in state } s,$$
and observe that it obeys a recursion referring only to the previous column:
$$V(0,s) = \mathrm{init}(s), \qquad V(n+1,t) = \max_{s \in S}\big(V(n,s) + \mathrm{step}_n(s,t)\big).$$

That is the whole algorithm: $O(n|S|^2)$ arithmetic, versus $|S|^{n+1}$ candidates. The definition of
$V$ mentions *all* labellings; the recursion mentions *none*. Why should they agree?

**Play with it before reading the answer.** In the laboratory below you can edit every weight, drag
the horizon, forbid transitions, and flip between maximisation and minimisation. The panel at the
bottom runs an *exhaustive* audit in the background and reports whether the dynamic program's answer
survives comparison with brute force. Try to make it fail.

{{interactive_demo:0}}

> **Try this.** Set the horizon to 5 and note the audit line: the table filled $18$ cells while the
> brute-force check enumerated $729$ labellings. Now push the horizon to 7 — $6561$ labellings against
> $24$ cells. The gap is the whole point, and it grows without bound.

---

## 2. Two halves of one promise

Any claim that an algorithm "solves" an optimisation problem splits into two independent halves.
They fail for different reasons and are proved by different arguments, and it is worth insisting on
the distinction.

| | claim | fails when | proof style |
|---|---|---|---|
| **Soundness** | the reported value is *achieved* by a real labelling | the algorithm is over-optimistic: it quotes a 12-minute route no sequence of roads realises | a construction |
| **Completeness** | no labelling *beats* the reported value | the algorithm is myopic: it finds a real 14-minute route and never notices the 12-minute one | an estimate |

Neither implies the other, and each alone is worthless: "always return $-\infty$" is sound, and
"always return $+\infty$" is complete. Together they say $V(n,s)$ is the **greatest element** of the
set of achievable scores — attained, not merely an upper bound.

Completeness is the property greedy algorithms lack. It is also, surprisingly, the easy half.

<details>
<summary><b>Click to reveal the two-line proof of completeness</b></summary>

**Domination Theorem.** For every labelling $f$ and every stage $n$, $\mathrm{score}(f,n) \le V(n, f(n))$.

*Proof.* Induction on $n$.

*Base.* $\mathrm{score}(f,0) = \mathrm{init}(f(0)) = V(0,f(0))$ — equality, in fact.

*Step.* The recursion takes a maximum over *all* predecessors, so in particular it beats the one
predecessor $f$ actually used:
$$V(n,s) + \mathrm{step}_n(s,t) \le V(n+1,t) \quad \text{for all } s,t.$$
Combine with the inductive hypothesis, using only that adding a fixed quantity preserves the order:
$$\mathrm{score}(f,n+1) = \mathrm{score}(f,n) + c \le V(n,f(n)) + c \le V(n+1, f(n{+}1)),$$
where $c = \mathrm{step}_n(f(n), f(n{+}1))$. $\blacksquare$

Notice what the proof **did not use**: no subtraction, no real numbers, no positivity, no structure
on $S$ beyond being a set. Just "a maximum dominates its terms" and "$x \le y \Rightarrow x + c \le y + c$".
A $10^{32}$-fold search dispatched in two lines.
</details>

<details>
<summary><b>Click to reveal the construction behind soundness</b></summary>

**Realisability Theorem.** For every stage $n$ and state $s$ there is a labelling $f$ with $f(n) = s$
whose score equals $V(n,s)$ exactly, and all of whose prefixes are likewise optimal.

*Proof.* Induction on $n$. At stage $0$, the constant labelling at $s$ works. For $n+1$ and target $t$:
because $S$ is finite and non-empty, the maximum defining $V(n+1,t)$ is *attained* at some concrete
state $s^\ast$. By induction take an optimal labelling $f$ ending at $s^\ast$ at stage $n$, and splice
$t$ onto its end. The spliced labelling scores $V(n,s^\ast) + \mathrm{step}_n(s^\ast,t) = V(n+1,t)$. $\blacksquare$

Unwinding this induction *is* the backtracing loop: store an argmax predecessor in each cell, then walk
back through the pointers. Attainment of the maximum — not merely the existence of a supremum — is the
hypothesis doing the work, and it is the only place finiteness of $S$ is needed.
</details>

Putting the halves together:

> **Exactness.** $V(n,s)$ is the greatest element of $\{\mathrm{score}(f,n) : f(n) = s\}$.
>
> **Completeness Theorem.** For every labelling $f$ there is a run $g$ with $\mathrm{score}(f,n) \le \mathrm{score}(g,n)$.
>
> **Uniform Completeness.** A *single* run — the one ending at the state maximising $V(n,\cdot)$ —
> dominates every labelling at once.

The step from "for every $f$ there is a $g$" to "there is a $g$ for every $f$" is the logical difference
between $\forall\exists$ and $\exists\forall$, and it is exactly the difference between "never beaten in
a particular comparison" and "outputs *the* optimum".

---

## 3. The two algorithms, in code

The forward pass fills the table; the backtrace reads off a witness. Everything else on this page is
commentary on these two loops.

{{algorithm:0}}

{{algorithm:1}}

Note the second algorithm's `certify` function. It checks two *different* conditions:

- the **structural** condition (a *backtrace*): $V(i, f(i)) + \mathrm{step}_i(f(i), f(i{+}1)) = V(i{+}1, f(i{+}1))$ at every stage — literally what the pointer loop guarantees;
- the **semantic** condition (a *run*): every prefix is optimal for its own endpoint.

These are equivalent over *any* ordered weight monoid. Keep that distinction in mind; §6 is where it earns its keep.

---

## 4. The subtle theorem: optimality is hereditary

Here is the result with real content. Suppose you are handed a labelling that is optimal only *at the
end*: $\mathrm{score}(f,n) = V(n, f(n))$, with no promise about its prefixes. Might it have been sloppy
early and made up the difference with an unusually lucrative final step?

> **Bellman's Optimality Principle.** No. End-optimality forces every prefix to be optimal. Being
> end-optimal and being a run are the same thing.

<details>
<summary><b>Click to reveal the proof — and the one hypothesis it needs</b></summary>

Suppose the prefix were strictly suboptimal, $\mathrm{score}(f,n) < V(n,f(n))$. Adding the same final
step $c$ to both sides *strictly* preserves the inequality:
$$\mathrm{score}(f,n) + c < V(n,f(n)) + c \le V(n+1, f(n{+}1)),$$
so $\mathrm{score}(f,n+1) < V(n+1, f(n{+}1))$, contradicting end-optimality. Induct downwards. $\blacksquare$

The load-bearing word is **strictly**. Passing from $x < y$ to $x + c < y + c$ requires the weights to be
**cancellative**: adding $c$ must not collapse distinct values. Real numbers, integers and rationals are
cancellative. Some extremely useful weight systems are not — see §6, where this proof genuinely breaks
and has to be replaced.
</details>

The principle upgrades everything into a clean characterisation:

> **Characterisation of Runs.** A labelling is a run of the dynamic program **if and only if** it is
> optimal among all labellings with the same endpoint.

On the left, a *syntactic* property (generated by the recursion, step by step). On the right, a
*semantic* one (nothing beats it). Their coincidence is precisely what one means by saying the algorithm
is correct.

Here is the whole picture at once — every vertex annotated with its value, and the reconstructed optimum
highlighted:

{{visualization:0}}

---

## 5. Cutting the path: forward meets backward

Alongside the forward value $V(k,s)$ ("the best way *to get to* $s$ at stage $k$"), define the backward
value $B(k,m,s)$ ("the best total weight of $m$ further transitions *starting from* $s$ at stage $k$"):
$$B(k,0,s) = 0, \qquad B(k,m+1,s) = \max_{t \in S}\big(\mathrm{step}_k(s,t) + B(k+1,m,t)\big).$$

> **Forward–Backward Decomposition.** For all $k, m$:
> $$\max_{s \in S} V(k+m, s) = \max_{s \in S}\big(V(k,s) + B(k,m,s)\big).$$

An optimal path may be cut at *any* intermediate stage, and the global optimum reassembles as
(best way in) + (best way out). Drag the cut and watch the two halves trade magnitude while their maximised
sum stays pinned:

{{interactive_demo:1}}

The quantity $V(k,s) + B(k,m,s)$ is the best score of a labelling **forced** to occupy state $s$ at stage
$k$ — the *max-marginal*. Its shortfall from the global optimum is precisely the price of that constraint,
which is how sensitivity analysis and structured-prediction confidence estimates are computed.

{{algorithm:3}}

<details>
<summary><b>Click to reveal the proof, which is an exchange of two maxima</b></summary>

Expand $V(k+1,t)$ inside the left side and $B(k,m+1,s)$ inside the right side. Both turn into the *same*
double maximum over pairs (state before the cut, state after the cut) of
$$V(k,s) + \mathrm{step}_k(s,t) + B(k+1,m,t).$$
The two computations reach it in opposite orders, and $\max_s \max_t = \max_t \max_s$ finishes the job.
The pulling-out of constants uses the identity
$$\Big(\max_i a_i\Big) + c = \max_i (a_i + c),$$
which is nothing but "adding a constant preserves the order" — the third of the three axioms, in disguise. $\blacksquare$
</details>

---

## 6. The algebra underneath: tropical arithmetic

That distributive law is a hint. Write $\oplus$ for $\max$ and $\otimes$ for $+$. Then $(W, \oplus, \otimes)$
satisfies every semiring axiom — this is the [tropical, or max-plus, semiring](https://en.wikipedia.org/wiki/Tropical_semiring).
Seen from that height, the value function is a *vector*, the transition weights are a *matrix*, and the
recursion is matrix–vector multiplication.

Let $\mathcal{W}_k^{(m)}(s,t)$ denote the optimal weight of $m+1$ consecutive transitions from $s$ at stage
$k$ to $t$ at stage $k+m+1$. Then:

> **Tropical Chapman–Kolmogorov.**
> $$\mathcal{W}_k^{(m_1+m_2+1)}(s,u) = \max_{t \in S}\Big(\mathcal{W}_k^{(m_1)}(s,t) + \mathcal{W}_{k+m_1+1}^{(m_2)}(t,u)\Big).$$
>
> **Transfer identity.** $\displaystyle V(k+m+1, t) = \max_{s \in S}\big(V(k,s) + \mathcal{W}_k^{(m)}(s,t)\big).$

This is exactly the [Chapman–Kolmogorov equation](https://en.wikipedia.org/wiki/Chapman%E2%80%93Kolmogorov_equation)
for Markov kernels, with $\max$ replacing $\sum$ and $+$ replacing $\times$. The Viterbi algorithm is to the
forward algorithm as max-plus is to plus-times.

The payoff is algorithmic. When the transition weights do not depend on the stage, the walk matrices are
tropical *powers* of a single matrix, so repeated squaring computes the $m$-step optimum in
$\Theta(|S|^3 \log m)$ rather than $\Theta(m|S|^2)$:

{{algorithm:2}}

---

## 7. Three specialisations, one theorem

Nowhere above did a real number appear. What the arguments actually used is only:

1. weights can be added, associatively and commutatively;
2. weights are linearly ordered;
3. adding a constant preserves the order.

Any linearly ordered commutative monoid works, and the specialisations are startlingly diverse.

<details>
<summary><b>Max-plus, min-plus, and the free lunch of order duality</b></summary>

Take the same theorems and read the order **upside down**. Maximum becomes minimum, "dominated by" becomes
"dominates", and out falls the Bellman–Ford shortest-path theorem — with no new proof. This is the
methodological dividend of stating things over an abstract order: one argument, two theorems. In the
laboratory of §1, the *Maximise / Minimise* toggle changes exactly one comparison in the code.
</details>

<details>
<summary><b>Viterbi decoding: probabilities in disguise</b></summary>

Probabilities under multiplication become log-probabilities under addition, so the most likely state
sequence through a [hidden Markov model](https://en.wikipedia.org/wiki/Hidden_Markov_model) is a max-plus
optimum. Because a uniform shift of all weights shifts the optimum by a constant and cannot change *which*
labelling is optimal, unnormalised log-scores suffice — no partition function required.
</details>

<details>
<summary><b>Constrained problems, and where the classical proof breaks</b></summary>

Adjoin a bottom element $\bot$ meaning "forbidden", with $\bot + w = \bot$ and $\bot$ below everything.
Infeasible transitions get weight $\bot$ and the algorithm routes around them automatically.

But $\bot$ destroys cancellativity: $\bot + 1 = \bot + 2$ while $1 \ne 2$. The optimality-principle proof of
§4 breaks, and not just technically — a hopeless prefix followed by a forbidden step really is
"optimal at the end", in the degenerate sense that the whole path is infeasible.

**The repair is to change the definition, not to weaken the theorem.** Define a run *structurally* — as a
backtrace, requiring the recursion to be realised on the nose at each stage — and everything goes through:

> **Equivalence Theorem.** Over *any* ordered weight monoid, backtrace $\iff$ run.
>
> **General Completeness.** Over any ordered weight monoid, every labelling is dominated by some backtrace,
> and the value function is still the greatest achievable score.

So cancellativity, which looked indispensable, was an artefact of asking the wrong question.
</details>

The reward is an immediate treatment of constrained optimisation, with a criterion that practitioners
actually want:

> **Infeasibility Criterion.** $V(n,s) = \bot$ **if and only if** every labelling ending at $s$ uses a
> forbidden ingredient. The algorithm reporting "impossible" is a *proof* of impossibility, not a failure
> to search.

Run the demonstration below: it solves maximum-weight independent set on a path (no two adjacent vertices),
a decoding problem with a forbidden bigram, and a deliberately over-constrained instance where the answer is
$\bot$. Each is audited against exhaustive enumeration, and each reconstructed labelling is checked against
*both* the structural and the semantic definition of a run.

{{demo:1}}

> **Look for this in the output.** In the independent-set instance, $13$ of the $32$ labellings are feasible
> and the optimum is $15$, attained by vertices $\{1,3\}$ with weights $7$ and $8$. The dynamic program touched
> $10$ table cells, never enumerated a subset, and enforced independence *purely arithmetically* — no pruning
> heuristic, no separate feasibility test, no special case in the recursion.

---

## 8. Does it survive contact with reality?

Real weight tables are estimated from data and are therefore wrong. Does exactness matter if the numbers are
noisy? Yes, and quantifiably.

> **Lipschitz Stability.** If two specifications differ by at most $a$ in every initial weight and at most $b$
> in every transition weight, their value functions differ by at most $a + nb$ at horizon $n$.
>
> **Near-Optimality Transfer.** Consequently a run computed for the perturbed model is within $2(a + nb)$ of the
> true optimum for the true model.

The error accumulates **linearly** in the horizon, not exponentially. That is the difference between a method
one can deploy and a laboratory curiosity.

{{visualization:1}}

<details>
<summary><b>Click to reveal why the proof is soft</b></summary>

Two ingredients. First, **equivariance**: shifting every initial weight by $a$ and every transition weight by
$b$ shifts the value function by *exactly* $a + nb$ — which is also the precise sense in which the optimum only
cares about weight *differences*. Second, **monotonicity**: raising the data pointwise can only raise the value
function. Squeeze the perturbed specification between two uniform shifts of the true one and the bound falls out.
The factor $2$ in the transfer bound counts the two independent model–reality crossings: evaluating the true
optimum under the wrong model, and evaluating the wrong optimiser under the true model.
</details>

---

## 9. See it all at once

The full numerical tour — domination against random labellings, exactness against brute force at every horizon,
uniform completeness, the optimality principle checked over every labelling, forward–backward at every cut,
Chapman–Kolmogorov, order duality, stability, and the constrained instance — in one runnable script:

{{demo:0}}

---

## 10. What has actually been shown

Strip away the generality and the moral is this. Dynamic programming *looks* like a heuristic: it commits at each
stage without looking ahead, which is exactly the sin that makes greedy algorithms fail. It survives because it
commits **for every possible future** — keeping one candidate per state rather than one candidate overall. That is
the entire content of the value function, and completeness is the theorem that says the bookkeeping is enough.

Stated once and proved abstractly, it covers longest paths and shortest paths, probabilistic decoding and
constrained combinatorial optimisation, exact arithmetic and noisy estimates. The hypotheses that survive the
stripping — **add, order, monotonicity, attainment** — are the minimal price of the promise.

And the hypothesis that did *not* survive is the most interesting part of the story. Cancellativity looked
indispensable; it turned out to be an artefact of asking the wrong question. Ask what a run *is* rather than what a
run *achieves*, and the requirement disappears — taking with it the last obstacle between the abstract theorem and
the constrained problems practitioners actually solve.

---

### Where to go next

- [Dynamic programming](https://en.wikipedia.org/wiki/Dynamic_programming) — the general technique and its history.
- [Bellman equation](https://en.wikipedia.org/wiki/Bellman_equation) — the optimality principle in the setting of sequential decisions.
- [Viterbi algorithm](https://en.wikipedia.org/wiki/Viterbi_algorithm) — the layered decoder, and its role in communications and speech.
- [Tropical geometry](https://en.wikipedia.org/wiki/Tropical_geometry) — where max-plus algebra leads once you take it seriously.
- [Algebraic path problem](https://en.wikipedia.org/wiki/Semiring#Applications) — solving $x = Ax \oplus b$ over a general semiring, the homogeneous cousin of the layered theory above.
