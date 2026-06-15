# Close Proofs: The Hidden Geometry of "Which Proof System Is Stronger?"

## A question every mathematician secretly asks

Suppose you and a friend each have a different toolkit for proving statements. You
have one method; your friend has another. A natural rivalry breaks out: *whose
method is better?* Not better at one specific theorem, but better across the board —
can your toolkit always reproduce, quickly and compactly, whatever your friend can
do?

This is not idle competition. It is one of the central questions of modern logic and
computer science, and it sits at the heart of the famous **P vs. NP** problem. The
study of it has a name — the **Cook–Reckhow program**, after a landmark 1979 paper —
and its objects of study are *proof systems*: formal machines that take a "proof" and
certify which theorem it establishes.

The surprise this article tells you about is that all the proof systems in the world,
when you compare them by strength, snap together into a single, beautifully ordered
landscape. That landscape has a *shape*. It has valleys where systems merge, ladders
that climb forever, and a precise geometric law governing who dominates whom. And the
law turns out to be astonishingly simple: **it is all about how fast a function
grows.**

## What a proof system really is

Strip away the syntax and a proof system is three things:

- a collection of objects we call **proofs**;
- a rule `proves` that reads off, from each proof, *which theorem it certifies*;
- a measure `size` that tells you *how long* each proof is.

We also insist the system be **complete**: every theorem in our universe has *some*
proof. That is the entire definition. A "proof" need not be a string of symbols; it
can be anything at all, as long as it certifies a theorem and has a length.

This austere definition is the secret to the whole theory. By refusing to look inside
proofs, we get to compare wildly different systems — resolution, Frege systems,
cutting planes, your toolkit, your friend's — on equal footing.

## "Simulates": the one relation that matters

Here is the comparison that organizes everything. We say a system **P p-simulates a
system Q** when:

> There is a translation that turns every Q-proof into a P-proof *of the very same
> theorem*, and the translation only blows up the size **polynomially**.

The word "polynomially" is doing enormous work. It means: if a Q-proof has size `n`,
the resulting P-proof has size at most `f(n)`, where `f` is some fixed polynomial
budget — like `n²` or `100·n³ + 7`. Polynomial blow-up is the universal currency of
"efficient" in computer science. A polynomial stretch is forgivable; an exponential
stretch is catastrophic.

To pin this down with no ambiguity, we declare a size-stretch function `f` to be a
legal blow-up — *polynomially bounded* — exactly when

> `f(n) + 1 ≤ (n + 2)^k`  for some fixed power `k`, for every `n`.

(The little `+2` in the base and the `+1` on the left are not decoration: they make
the class of legal blow-ups behave perfectly even at `n = 0`, where a naive bound
would break. This is the kind of detail that separates a slogan from a theorem.) We
also ask blow-ups to be **monotone** — bigger inputs give bigger budgets — because
that is exactly what lets us *chain* two translations together.

With "P simulates Q" defined, three facts fall out immediately:

- **Every system simulates itself** (translate by doing nothing).
- **Simulation chains**: if P simulates Q and Q simulates R, then P simulates R. The
  combined budget is just the composition of the two polynomial budgets — and a
  polynomial of a polynomial is again a polynomial.

In the language of order theory, these two facts say simulation is a **preorder**.
And when two systems simulate *each other*, we call them **p-equivalent**: for all
practical purposes they are the same system wearing different clothes. Collapsing each
cluster of p-equivalent systems to a single point produces the true objects of study —
the **p-degrees** — and they form a genuine *partial order*. This is the landscape
whose geometry we now map.

## First landmark: the landscape has valleys (meets exist)

Take any two proof systems, P and Q. Is there a single system that is *weaker than
both* — and is the *strongest possible* such system? In order-theoretic language: do P
and Q have a **greatest lower bound**, a *meet*?

They do, and the construction is delightfully concrete. Define the **direct sum**
`P ⊕ Q`:

> A proof in `P ⊕ Q` is *either* a P-proof *or* a Q-proof. It certifies whatever that
> proof certified, with the same size.

This is the "keep whichever proof you like" system. It is obviously weaker than P
alone (it carries extra Q-baggage) and weaker than Q alone, so it is a lower bound.
The striking part is that it is the *greatest* lower bound:

> **Meet theorem.** For any P and Q, the direct sum `P ⊕ Q` is the greatest lower
> bound of `{P, Q}` in the simulation order. Any system R that simulates both P and Q
> automatically simulates `P ⊕ Q`.

Why? If R can simulate P with budget `f` and simulate Q with budget `g`, then R
simulates the direct sum with budget `max(f, g)` — just use whichever translation
applies to the proof in front of you. The only thing you must check is that the
pointwise maximum of two polynomial budgets is *still* a polynomial budget. It is: if
`f(n)+1 ≤ (n+2)^a` and `g(n)+1 ≤ (n+2)^b`, then `max(f,g)(n)+1 ≤ (n+2)^(a+b+1)`.

The consequence is immediate and global:

> **The simulation preorder is down-directed**: any two systems have a common lower
> bound. The p-degrees form a **meet-semilattice**.

So the landscape is not a tangle of incomparable peaks. Wherever you stand, you can
always descend to a unique meeting point with any other peak. The valleys are always
there.

## Second landmark: the law of the land (simulation = growth domination)

To explore the *height* of the landscape we restrict to a clean family of systems we
can compute with. Over the theorem-universe of natural numbers, define for each size
function `a : ℕ → ℕ` the system `Sys(a)`:

> Its proofs *are* the natural numbers; the proof `n` certifies the theorem `n`; and
> its size is `a(n)`.

Two famous members of this family already appear in the catalog. `Sys(id)` — the
**linear system**, where the proof of `n` has size `n` — and `Sys(F)` — the
**Fibonacci system**, where the proof of `n` has size `F(n)`, the `n`-th Fibonacci
number, which grows exponentially.

For this family the entire simulation question collapses to a single, transparent
criterion:

> **Domination law.** `Sys(a)` simulates `Sys(b)` **if and only if** `a` is pointwise
> dominated by a monotone polynomial blow-up of `b` — informally, `a ≤ poly ∘ b`.

In words: *a smaller (slower-growing) size function makes a stronger system.* The
proof that grows more slowly can always afford to reproduce the proof that grows
faster. This single equivalence converts every hard question about proof simulation
into an elementary question about *comparing growth rates of functions* — a subject we
have understood since calculus.

It immediately re-derives the catalog's flagship separation. The linear system
simulates the Fibonacci system (linear is slower than exponential), but the Fibonacci
system does **not** simulate the linear system, because doing so would require a
polynomial to dominate the Fibonacci numbers — and Fibonacci grows faster than every
polynomial. So:

> **Strict 2-chain.** `linSystem < fibSystem`: the linear degree sits strictly below
> the Fibonacci degree.

The landscape has at least two distinct altitudes. But how high does it go?

## Third landmark: a ladder to infinity

Here is where the story becomes vivid. We want an *infinite* strictly increasing chain
of p-degrees — a ladder whose every rung is strictly stronger than the one below, with
no top. Each rung must be separated from the next by more than a polynomial, or the
domination law would collapse them together.

The first idea most people try is the ladder of size functions `2^(k·n)` for
`k = 1, 2, 3, …`. It fails — and *why* it fails is the heart of the insight. Consider
two consecutive rungs:

> `2^((k+1)·n) = (2^(k·n))² `

Squaring is a polynomial operation. So rung `k+1` is just rung `k` "squared," and by
the domination law the two rungs are *p-equivalent*: they collapse to the same degree.
A plain exponential, no matter how you scale its rate, lives entirely on one floor of
the building.

The fix is to move the parameter from the *rate* of the exponential into the
*exponent of the exponent*. Define the **power ladder**:

> `powSystem(k) = Sys( n ↦ 2^(n^k) )`,   for `k = 1, 2, 3, …`

Now compare rungs `k` and `k+1`. The exponent jumps from `n^k` to `n^(k+1) = n · n^k`.
Multiplying the exponent by `n` is a *genuinely super-polynomial* leap, and no
polynomial budget can bridge it. The precise arithmetic fact, proved in full, is:

> **Gap lemma.** For every power `c` and every `k ≥ 1`, there is an input `n` with
> `(2^(n^k) + 2)^c < 2^(n^(k+1))`.

Read the left side as "the most a degree-`c` polynomial blow-up could ever squeeze out
of rung `k`," and the right side as "rung `k+1`." The lemma says rung `k+1` eventually
outruns *every* polynomial inflation of rung `k`. By the domination law, rung `k`
cannot simulate rung `k+1`. Hence:

> **Infinite height.** The map `k ↦ powSystem(k)` is a strictly increasing chain of
> p-degrees, all distinct. The poset of p-degrees contains an infinite ascending
> ladder — it has **infinite height**.

The reason the exponential ladder fails and the power ladder succeeds is one of those
clarifying moments mathematics occasionally offers. Two growth rates are
"polynomially comparable" — and so collapse to one p-degree — exactly when each is a
polynomial of the other. The functions `2^(k·n)` are all polynomially comparable to
one another. The functions `2^(n^k)` are not: each one is polynomially *unreachable*
from the one below. Height in this landscape is precisely a tower of mutually
poly-incomparable growth rates.

## Why this is more than a curiosity

The Cook–Reckhow program connects directly to the deepest open problem in computer
science. A theorem of Cook and Reckhow says: **if no proof system can prove every
tautology with polynomial-size proofs, then NP ≠ coNP** — and in particular P ≠ NP.
Every separation of proof systems — every "P does not simulate Q" — is a small, hard-
won data point in the century-defining effort to understand the limits of efficient
computation.

What the results above contribute is *structure*. They tell us the arena of proof
systems is not a featureless soup but an ordered world with a definite shape:

- It has **valleys** (meets always exist): any two systems descend to a common
  greatest lower bound, realized by the homely "run either one" direct sum.
- It is governed by a **single law** for computable size families: simulation is
  exactly polynomial domination of growth rates. Hard logic becomes soft calculus.
- It is **infinitely tall**: there is no strongest interesting growth rate; the power
  ladder `2^(n^k)` climbs forever, each rung a super-polynomial step above the last.

And it leaves a tantalizing question hanging, dual to the meet theorem. We proved
*meets* (greatest lower bounds) always exist. Do *joins* — least *upper* bounds, a
single system that is the weakest thing stronger than both P and Q — always exist? If
not, the p-degrees would be a meet-semilattice that is provably **not a lattice**, a
subtle asymmetry with real content about how proof power can and cannot be combined.

## The moral

Comparing methods of reasoning sounds like a philosophical question. The Cook–Reckhow
viewpoint turns it into geometry, and the geometry turns out to be ruled by a single
humble idea: *how fast does a function grow, and can a polynomial catch up?* Valleys
where systems merge, a ladder that never ends, an entire ordered landscape of
mathematical power — all of it is written in the language of growth rates. Sometimes
the deepest questions about reasoning come down to a race between functions, and the
winner is whoever can run away from every polynomial.
