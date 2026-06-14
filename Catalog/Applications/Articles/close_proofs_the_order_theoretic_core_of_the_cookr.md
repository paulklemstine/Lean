# Close Proofs: The Hidden Order Inside "How Hard Is It to Prove?"

Every working mathematician has felt it: some theorems fall out in a line,
others demand pages of grinding computation, and a few resist for centuries.
But "hard to prove" is a slippery phrase. Hard for whom? With what tools? A
fact that is a one-liner with the right lemma can be a nightmare without it.
What if we could turn this gut feeling into a precise mathematical object — a
landscape in which proof methods themselves are *points*, and "easier than"
is an honest order relation?

That is exactly what the **Cook–Reckhow program** in proof complexity sets out
to do, and this article tells the story of its order-theoretic heart. We will
build a ruler for measuring the strength of *proof systems*, discover that the
resulting ranking is an intricate partial order with a bottom but no top,
infinite height, infinite width, and no gaps you can't fill — and we will see
that the entire menagerie reduces, almost magically, to a single elementary
question about how fast functions grow.

## What is a proof system, really?

Strip away the syntax of any particular logic and a proof system is a
disarmingly simple thing. You have some collection of *theorems* you might want
to certify, and some collection of *proofs*. A proof system is a way of reading
off, from each proof, the single theorem it establishes — together with a
notion of how big that proof is. Crucially, the system must be *complete*: every
theorem you care about has at least one proof.

We can capture this with three pieces of data:

- a function `proves` sending each proof to the theorem it certifies,
- a function `size` measuring the length of each proof, and
- a completeness guarantee: `proves` is surjective (every theorem is reachable).

That's it. No axioms, no inference rules, no Turing machines. A proof system is a
surjective map equipped with a yardstick. This abstraction is the genius of
Cook and Reckhow: it lets us compare *resolution*, *Frege systems*, *cutting
planes*, and exotic systems no one has implemented, all on equal footing.

## Simulation: when is one system at least as good as another?

Now for the ruler. We say a system **P p-simulates Q** — written informally as
"P is at least as strong as Q" — when every Q-proof can be translated into a
P-proof of *the same theorem* with only a polynomial blow-up in size. Formally,
there must be a single translation-cost function `f` such that:

- `f` is monotone and **polynomially bounded**, meaning there is an exponent `k`
  with `f(n) + 1 ≤ (n + 2)^k` for all `n`; and
- for every Q-proof `q` there is a P-proof `p` with `proves p = proves q` and
  `size p ≤ f(size q)`.

The polynomial budget is the whole point. We don't care about constant factors
or the difference between `n` and `n²` — those are the small change of
complexity theory. We care about the *qualitative* jump from polynomial to
super-polynomial. Two systems that can each cheaply imitate the other are
declared **p-equivalent**; they have the same intrinsic power even if they look
nothing alike.

The first thing to verify is that this "at least as strong as" relation behaves
the way an order should. It is reflexive: every system simulates itself, using
the identity translation. And it is transitive: if P simulates Q with cost `f`
and Q simulates R with cost `g`, then P simulates R with cost `f ∘ g`. The only
subtlety is that the composition of two polynomially bounded functions must
again be polynomially bounded — which is true, and is the algebraic engine that
makes the whole theory hang together. (A cute detail: the natural-looking budget
`f(n) ≤ (n+1)^k` is *not* closed under composition, because it can't dominate a
constant bigger than `1` at `n = 0`. The repaired budget `f(n) + 1 ≤ (n+2)^k`
fixes the corner case and is the version we use.) So simulation is a genuine
**preorder**, and quotienting by p-equivalence yields a genuine **partial
order** — the **poset of p-degrees**, our landscape of proof strength.

## The master key: everything is about growth rates

Here is where the story becomes beautiful. To probe the structure of this poset
we don't need exotic logics at all. We only need a family of toy systems that
let us *dial in any growth rate we like*.

Fix the theorems to be the natural numbers themselves, let a proof of `n` simply
*be* `n`, and decree that the proof of `n` has size `a(n)` for any function `a`
of our choosing. Call this the **size-indexed system** `sys(a)`. Completeness is
free (the identity map is surjective), and the size function is whatever we want.

For these systems, simulation collapses to pure arithmetic. One proves the
**Domination Characterization**:

> `sys(a)` p-simulates `sys(b)` **if and only if** there is a monotone
> polynomially bounded `f` with `a(n) ≤ f(b(n))` for all `n`.

In words: a slower-growing size function is always simulated by a faster-growing
one, and the *only* obstruction to simulation is that one growth rate genuinely
outruns every polynomial reshaping of the other. Every structural feature of the
landscape — chains, antichains, gaps, bounds — now reduces to elementary
inequalities between functions. This is the "homotopy-invariant" content of the
theory: the right invariant of a proof system is the **growth rate of its size
function up to polynomial reparameterization**.

## A first separation, courtesy of Fibonacci

Are there even two distinct degrees? Compare two size-indexed systems: the
**linear** system with size `a(n) = n`, and the **Fibonacci** system with size
`a(n) = F(n)`, the `n`-th Fibonacci number.

The linear system is easily simulated by the Fibonacci one — small proofs are
cheap to find, and `n ≤ F(n) + 4` is a comfortably linear bound. But the reverse
fails dramatically. To simulate the Fibonacci system using the linear one, some
polynomial would have to dominate `F`. And Fibonacci growth is **not
polynomially bounded**: from the clean bound `2^n ≤ F(2n+1)` one shows that `F`
eventually overtakes every polynomial (this is the familiar "exponential beats
polynomial" fact, here applied to Fibonacci's hidden exponential core). So the
Fibonacci system is *strictly stronger* than the linear one. We have our first
strict comparison, and our first two distinct p-degrees. The landscape is not a
single point.

This little argument is secretly a template. The only property of `F` we used
was that it isn't polynomially bounded. So **any** super-polynomial lower bound
on proof size separates systems — which is precisely the proof-complexity reading
of decades of hard work: super-polynomial size lower bounds are *exactly* what
pry proof systems apart in the simulation order.

## How tall is the landscape? Infinitely.

Two points is a start; can we build an infinite ascending staircase? Yes — by
moving our parameter into the exponent of an exponent. Define the **power ladder**
`powSystem(k)` to be the size-indexed system with size `2^(n^k)`.

Climbing the ladder by one rung, from `2^(n^k)` to `2^(n^(k+1))`, is a
super-polynomial jump, because `n^(k+1) = n · n^k` outruns `c · n^k + c` for
every constant `c` once `n` is large enough. (The naive ladder `2^(k·n)`
*collapses*: those rungs are all p-equivalent, since `2^((k+1)n) ≤ (2^(kn))²`.
The trick is to inflate the exponent itself.) Each rung therefore strictly
dominates the previous one, and we obtain an **infinite strictly increasing
chain** of p-degrees. The poset has infinite height.

## How wide is it? Also infinitely — and right down at the bottom.

Height measures comparable things; *width* measures incomparable ones — an
**antichain**, a family of degrees none of which simulates any other. Using size
functions that spike on disjoint sets of inputs, one builds an infinite antichain
of mutually incomparable degrees. Even more striking, this entire infinite
antichain can be trapped inside a *bounded* interval, low in the order, between
the bottom degree and a single fixed ceiling. Infinite width is not banished off
to infinity; it lives arbitrarily close to the floor. Height and width coexist
inside one short interval.

## Are there gaps? No — the order is dense along the ladder.

Between two consecutive rungs of the power ladder, is there room for anything in
between? There is, and the construction is a lovely *local-to-global glueing*.
Define a size function that runs the *faster* rate `2^(n^(k+1))` on the even
inputs and the *slower* rate `2^(n^k)` on the odd inputs. This **parity-glued**
system is super-polynomially above the lower rung (the even inputs keep the fast
rate, so the lower rung can't catch it) yet too thin to reach the upper rung (the
odd inputs fall back to the slow rate, so it can't catch the upper one). It sits
*strictly between* them. So between any two consecutive ladder degrees there is a
third: the order is **dense** along the entire ladder. There are no unjumpable
gaps.

## A floor but no ceiling

Finally, the shape at the extremes. There is a **least** p-degree — a weakest
possible system, a bottom of the order. But there is provably **no greatest**
one. For *any* candidate "universal" system T, you can diagonalize against it.
Build the size function `t ↦ 2^(sec t) + 2^t`, where `sec t` records the size of
T's own chosen proof of theorem `t`. If T could simulate this diagonal system,
one fixed polynomial in `sec t` would have to dominate both `2^(sec t)` and `2^t`
simultaneously, for every `t`. The first clamp forces `sec` to be globally
bounded; the second then demands `2^t` stay below a constant — absurd. So no
proof system simulates them all. The order type is genuinely asymmetric: a least
element exists, a greatest one cannot.

## Why this matters

Read through ordinary eyes, these are statements about an abstract poset. Read
through the lens of computational complexity, they are a map of one of the
deepest landscapes in the subject. The famous question of whether **NP equals
coNP** is *equivalent* to whether there is a single proof system at the top of
this order — a "polynomially bounded" system that proves every tautology with
short proofs. We have just seen that this poset has *no* top element among
size-indexed systems and that super-polynomial lower bounds are the only
currency of separation. That is not a proof that NP ≠ coNP — that remains one of
the great open problems — but it is the rigorous skeleton on which every attack
on the problem hangs.

What stays with you is the unifying lesson. We began with the vague human
intuition that some proofs are harder than others, and we ended with a crisp
partial order whose every feature — its bottom, its missing top, its infinite
height, its infinite width hiding near the floor, its gaplessness — is a
*theorem about how fast functions grow*. The difficulty of proving things,
properly abstracted, is the arithmetic of growth rates. The landscape of proofs
turns out to be a landscape of polynomials and exponentials, and once you have
the right ruler, you can survey it.
