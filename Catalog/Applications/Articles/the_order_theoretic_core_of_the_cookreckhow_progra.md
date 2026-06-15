# Mapping the Hidden Landscape of Mathematical Proof

## A question older than computers

Every mathematician knows the feeling: two proofs of the same theorem, one
a single elegant line, the other a sprawling page of case analysis. Both are
correct. Both end with the same fact. Yet one feels *better* — shorter,
cleaner, more powerful. Is there a way to make that gut feeling precise?

In the 1970s, Stephen Cook and Robert Reckhow turned this intuition into one
of the deepest research programs in logic. Their idea was disarmingly simple.
Forget *what* a proof says and ask only *how long* it is. A **proof system**,
in their abstraction, is just a machine that takes a candidate proof, checks
it, and reports which theorem it certifies — with the rule that *every* true
statement has *some* proof. The interesting question is no longer "is this
true?" but "how big must a proof be?"

This shift unlocked a strange and beautiful geography. Some proof systems are
genuinely more powerful than others: anything you can prove cheaply in system
A, you can also prove cheaply in system B, but not the other way around. To
make "cheaply" precise, Cook and Reckhow allowed proofs to be translated
between systems as long as they don't blow up by more than a *polynomial*
factor. If system B can mimic system A this way, we say B **p-simulates** A.
The dream at the heart of the program — still open after fifty years — is that
no proof system is universally efficient, a statement that, if proved, would
settle whether `NP` differs from `coNP` and edge us toward `P ≠ NP`.

This article is about the *shape* of that universe. Not whether the dream is
true, but what the landscape of proof systems looks like as a mathematical
object in its own right. The answer, it turns out, is astonishingly rich:
it is infinitely tall, infinitely wide, has a floor but no ceiling, and is so
finely subdivided that you can always squeeze a new system between any two
comparable ones.

## Turning proofs into geometry

The first move is to clean up the picture. Strip a proof system down to its
essentials and you are left with three ingredients: a type of *proofs*, a rule
`proves` that tells you which theorem each proof certifies, a *size* assigned
to each proof, and a guarantee of *completeness* — every theorem really does
have a proof. That is the whole structure.

Now define the central relation. System **P p-simulates Q** if there is a
"blow-up budget" — a function `f` that is increasing and *polynomially
bounded* — such that every Q-proof can be replaced by a P-proof of the very
same theorem whose size is at most `f` applied to the original size. The
phrase "polynomially bounded" gets a crisp definition: a function `f` is
polynomially bounded when `f(n) + 1 ≤ (n+2)ᵏ` for some fixed power `k`. (The
small `+2` is a clever bit of bookkeeping; it dodges an annoying corner case
at `n = 0` and makes the whole theory snap together.)

This relation behaves exactly as a notion of "at least as efficient as"
should. It is **reflexive** — every system simulates itself, with the trivial
budget that changes nothing. And it is **transitive** — if P simulates Q and Q
simulates R, then P simulates R, because you can compose the two budgets, and
the composition of two polynomially bounded increasing functions is again
polynomially bounded. (That single algebraic fact, that polynomials are closed
under composition, is the quiet engine behind everything.) A relation that is
reflexive and transitive is called a **preorder**, and that is the first solid
fact: proof systems form a preorder under p-simulation.

When two systems simulate *each other*, they are equally efficient — we call
them **p-equivalent** and lump them into a single point. Collapsing every
equivalence class to a point turns the preorder into a genuine **partial
order**, and its points are the famous **p-degrees**. The rest of the story is
the geography of this partial order.

## Why some proofs are doomed to be long

Before exploring the landscape, we need a way to prove that one system is
*strictly* stronger than another — that the simulation goes one way but not
back. This requires a source of "hardness," a family of theorems whose proofs
are forced to be enormous in one system but tiny in another.

The hero here is an old friend: the **Fibonacci numbers** `1, 1, 2, 3, 5, 8,
13, …`. They grow exponentially. A clean way to see this is the bound
`2ⁿ ≤ F(2n+1)`, proved by a two-step induction using the recurrence
`F(m+2) = F(m+1) + F(m) ≥ 2·F(m)`. Because Fibonacci growth outpaces every
exponential of the form `2ⁿ`, it certainly outpaces every polynomial: **no
polynomially bounded function can stay above the Fibonacci numbers**. The proof
compares growth rates directly — for any fixed power `k`, the ratio
`(2m+3)ᵏ / 2ᵐ` tends to zero, so eventually `2ᵐ` overtakes the polynomial,
which combined with `2ᵐ ≤ F(2m+1)` strangles any polynomial bound.

This gives a master tool, a **separation template**: suppose system Q proves a
family of theorems with proofs of modest, linear size, while every proof of
those same theorems in system P is forced to have size at least `s(n)` for
some function `s` that is *not* polynomially bounded. Then P **cannot**
p-simulate Q — for if it could, the blow-up budget would have to dominate `s`,
which is impossible. Fibonacci hardness is just the most famous instance; the
template works for any super-polynomial hardness function at all.

To make this concrete, picture two honest systems over the natural numbers.
In the **linear system**, the proof of the number `n` is simply `n` itself, at
size `n`. In the **Fibonacci system**, the proof of `n` is again `n`, but its
size is recorded as `F(n)`. The Fibonacci system pays exponentially more for
its proofs, and by the template, the linear system is *not* p-simulated by the
Fibonacci one. Two systems, genuinely different in power: the landscape has at
least two points. From here it explodes.

## A floor, infinite stairs, and no ceiling

**There is a floor.** Imagine the laziest possible system: every theorem `n`
is "proved" by the token `n` at size *zero*. This **zero system** simulates
absolutely everything — to translate any proof, just hand back the free,
size-zero token for the right theorem. So it sits at the very bottom of the
order, a least p-degree below all others, and it is *strictly* below the
linear system, which genuinely needs unbounded sizes. (A caveat worth stating
plainly: this floor exists because we measured only *size* and ignored Cook
and Reckhow's requirement that checking a proof be efficiently computable.
Re-impose that honesty constraint and the floor is expected to vanish — a
tantalizing direction for future work.)

**There are infinite stairs.** One can build a ladder of systems, each
strictly more powerful than the last, climbing forever. The order has no
finite height; it contains an infinite increasing chain. The world of proof
systems is unboundedly tall.

**There is no ceiling.** Crucially, the ladder never tops out at a universal
maximum. No single proof system p-simulates all the others. Any candidate
"strongest system" can be defeated by a diagonal construction: build a family
of theorems whose required proof sizes grow as `2^(s(t)) + 2^t`, where `s(t)`
is read off from how the candidate proves theorem `t`. The first term ties the
hardness to the candidate's own behavior; the second, `2^t`, then races past
any constant the candidate can muster, because polynomials are eventually
swamped by exponentials. The candidate is forced to fail. This is the order-
theoretic shadow of the Cook–Reckhow dream itself: *there is no best proof
system.*

## Infinitely wide: a forest of incomparable systems

Height is only half of a shape. A staircase is tall but thin. Is the landscape
of proof systems also *wide* — does it contain many systems that are simply
**incomparable**, neither simulating the other?

The answer is a resounding yes, and the construction is gorgeous. It uses the
**2-adic valuation**: for each natural number `n`, count how many times `2`
divides it. This single number, `v₂(n)`, sorts all the integers into infinitely
many infinite bins — bin `0` is the odd numbers, bin `1` is numbers like
`2, 6, 10, …`, bin `2` is `4, 12, 20, …`, and so on. The numbers in bin `i`
are exactly those of the form `2ⁱ · (odd)`.

Now build the **`i`-th spike system**: it assigns an exponential cost `2ⁿ` to
every theorem `n` in bin `i`, and a free cost of `0` to everything else. Each
spike system carries a single, towering exponential "spike" planted on its own
private bin, and is cheap everywhere else.

Here is the punchline. Take two different spike systems, `i ≠ j`. Could spike
system `i` simulate spike system `j`? A simulation comes with a fixed blow-up
budget `f`, and in particular a fixed value `f(0)`. But spike system `i` has
an *unbounded* exponential spike on its bin — pick a theorem in bin `i` larger
than `f(0)`, and the cost `2ⁿ` there blows past any value the budget can
provide on the cheap inputs. The single number `f(0)` simply cannot stretch to
cover an unbounded spike sitting on a disjoint set of theorems. So neither
system simulates the other: **the spike systems are pairwise incomparable.**

Because there are infinitely many bins, there are infinitely many spike
systems, and distinct ones land at distinct p-degrees. They form an **infinite
antichain** — an infinite collection of points, no two of which are comparable.
The landscape is not a tidy line of better-and-worse systems; it is a sprawling
forest. In particular, the p-simulation order is *not* a total order: there
exist pairs of proof systems where neither is more efficient than the other.

## Infinitely fine: room between any two rungs

A final question completes the portrait. The landscape is tall and wide — but
is it *grainy* or *smooth*? If one system is strictly stronger than another, is
there always a third nestled strictly between them, or can two systems sit
right next to each other with nothing in between?

At least at the Fibonacci separation, the order is smooth — it has **density**.
Recall the linear system sits strictly below the Fibonacci system. We can build
an **intermediate system** that lives genuinely between them, using a parity
trick. Its cost function is Fibonacci-fast on the *even* numbers but merely
linear on the *odd* numbers. Half-spiky, half-tame.

Why does this land strictly in the middle? On the even numbers it inherits the
full Fibonacci explosion, so it is super-polynomial — too fast for the linear
system to simulate, placing it strictly *above* linear. But it is also *too
thin* to be Fibonacci: on the odd numbers it has thrown away the Fibonacci
rate entirely. The full Fibonacci system has hard, expensive proofs on *those*
odd indices that the intermediate system, with its merely linear costs there,
cannot account for under any polynomial budget — placing it strictly *below*
Fibonacci. Squeezed from both sides, the intermediate system occupies a brand
new p-degree, strictly between the two. The same thinning trick can be repeated
along the entire ladder, suggesting the order is densely subdivided everywhere.

## The portrait, and why it matters

Step back and the full shape emerges. The universe of proof systems, ordered
by efficiency, is:

- **a partial order** of p-degrees, not a mere jumble;
- equipped with a **least element** (in the size-only model);
- of **infinite height**, an endless staircase with **no greatest element**;
- of **infinite width**, harboring infinite antichains of mutually
  incomparable systems;
- and **dense**, with room to insert new degrees between comparable ones.

This is the structure of a vast, intricate object — closer to the rational
numbers in its density and the real plane in its width than to any simple list.
And the engine that drives every one of these results is a single clean
principle: for the systems built over the natural numbers, *p-simulation is
exactly polynomial domination of cost functions*. Comparing two proof systems
reduces to comparing two growth rates, and the entire geometry of the proof
universe becomes a question about how fast functions grow — answered, again and
again, by the one arithmetic fact that **exponentials beat polynomials**.

The Cook–Reckhow program asked whether there is a best way to prove things. The
geography we have traced gives a structural reason to doubt it: in this world
there is no summit, only an ever-rising, ever-branching, infinitely fine
landscape of proof. Whether the deepest separations — the ones that would
resolve `P` versus `NP` — sit somewhere in this terrain remains the great open
question. But at least now we have a map.
