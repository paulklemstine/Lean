# The Hidden Landscape of Proofs

## Why some proofs must be long

Every working mathematician has felt it: some truths are easy to *state* but agonizing
to *justify*. You can scribble a statement on a napkin, yet the shortest honest
argument runs for pages. This nagging gap — between how short a fact is to say and how
long it takes to prove — is not just a psychological quirk. It is a precise,
mathematical phenomenon, and it sits at the center of one of the deepest questions in
all of computer science: **is finding a proof fundamentally harder than checking one?**
That is the celebrated P versus NP problem, and one of its most elegant disguises lives
in the world of *proof complexity*.

This article tells the story of a single, sturdy mathematical object — the **simulation
preorder of proof systems** — and what we can prove about its shape. It turns out that
the universe of all possible proof systems is not a featureless blob. It has structure:
it is ordered, it has valleys where proofs are cheap and peaks where they are expensive,
it has infinitely tall staircases, and remarkably, *between any two steps of those
staircases there is always another step*. The landscape is infinitely deep and
infinitely fine-grained at the same time.

## What is a proof system, really?

In 1979, Stephen Cook and Robert Reckhow gave a beautifully austere definition of a
*propositional proof system*. Strip away the rules, the axioms, the syntax of any
particular logic, and what remains is this: a proof system is just a way of certifying
truths, together with a notion of how big each certificate is.

Formally, fix a collection of "theorems" you might want to prove. A **proof system** is:

- a set of objects we call *proofs*;
- a function `proves` that tells you which theorem each proof certifies;
- a function `size` that tells you how long each proof is; and
- a guarantee of *completeness*: every theorem has at least one proof.

That's it. No mention of modus ponens, no resolution rules, no clever encodings — just
the abstract skeleton. This minimalism is the secret to the whole theory's power,
because it lets us compare wildly different logical systems on a level playing field.

## Ranking proof systems: who can imitate whom?

Now the crucial idea. We say a proof system **P p-simulates Q** — written `P ≥ Q` in the
order we'll build — if every Q-proof can be *translated* into a P-proof of the very same
theorem, with only a modest (polynomial) increase in size. In words: *anything Q can do
efficiently, P can do efficiently too.* The "p" stands for polynomial, and it captures
the idea that a polynomial blow-up is "for free" in the eyes of complexity theory.

What does "polynomial blow-up" mean precisely? We allow the translation to inflate a
proof of size `n` up to size `f(n)`, where `f` is some fixed *monotone, polynomially
bounded* function — meaning `f(n) + 1 ≤ (n+2)^k` for some constant `k`, for every `n`.
Monotonicity matters: it is exactly what lets two translations chain together cleanly.

This single relation organizes the entire universe of proof systems. And the first thing
to prove is that it deserves to be called an *order* at all.

**The simulation relation is a preorder.** Two facts must hold:

- *Reflexivity:* every system simulates itself. (Translate each proof to itself; the
  blow-up is the identity function — trivially polynomial.)
- *Transitivity:* if P simulates Q and Q simulates R, then P simulates R. (Compose the
  two translations; the composite blow-up is the composition of the two polynomial
  functions, and — here is the one genuinely algebraic lemma — *the composition of two
  monotone polynomially bounded functions is again monotone and polynomially bounded.*)

These two facts make `Simulates` a genuine **preorder**. When two systems simulate *each
other*, we call them **p-equivalent**; this is a true equivalence relation, and collapsing
each equivalence class to a point yields the **poset of p-degrees** — the central object
of the whole theory. A "p-degree" is a level of proving power, with all the incidental
differences between equivalent systems washed away.

## A concrete separation: when Fibonacci stands in the way

An order is only interesting if it has more than one point. So we need a *separation*: two
proof systems where one genuinely cannot imitate the other. The catalog supplies a vivid
one, built from the Fibonacci numbers.

Consider two proof systems over the natural numbers. In both, the "proof" of the number
`n` is just `n` itself. They differ only in how they *charge* for that proof:

- The **linear system** charges `size(n) = n`.
- The **Fibonacci system** charges `size(n) = F(n)`, the n-th Fibonacci number.

Can the Fibonacci system simulate the linear one? That would require translating each
cheap linear proof (size `n`) into a Fibonacci proof of the same theorem, but the only
Fibonacci proof of `n` costs `F(n)`. So a simulation would force `F(n)` to stay below some
polynomial in `n`. And here is the punchline:

**Fibonacci growth is not polynomially bounded.** The Fibonacci numbers grow
exponentially — concretely, `2^n ≤ F(2n+1)` for every `n`, which follows from the
doubling estimate `F(m+2) ≥ 2·F(m)`. Since `2^n` eventually overtakes every polynomial,
no polynomial can cap `F`. Therefore **the Fibonacci system does not p-simulate the
linear system.** The two systems sit at genuinely different p-degrees; the poset has at
least two points.

This is a toy model, but it is *exactly* the shape of every real separation in proof
complexity: to prove that one system can't simulate another, you exhibit a family of
theorems that the second proves cheaply but the first can only prove with
super-polynomially large proofs. Super-polynomial lower bounds are precisely the
currency that buys separations.

## The order has meets: combining two systems

Given two proof systems, is there a single system that captures the *common* power of
both — the strongest system simulated by each? Yes, and it has a delightfully simple
construction: the **direct sum**. A proof in the direct sum `P ⊕ Q` is *either* a P-proof
*or* a Q-proof; you simply run whichever subsystem you prefer. It certifies the same
theorems with the same sizes.

The direct sum turns out to be the **greatest lower bound** of P and Q in the simulation
order. It is simulated by both (just inject your proof into the appropriate side), and any
system simulating both P and Q automatically simulates the direct sum — using the
*pointwise maximum* of the two translation functions, which (again by an algebraic lemma)
is still a monotone polynomially bounded blow-up. In lattice language: **binary meets
exist**, and the order is *down-directed* — any two systems share a common lower bound.

## An infinite staircase: the order is infinitely tall

Two points is a start, but the landscape is vastly richer. Consider the family of
**power-tower systems**: for each `k`, the system `powSystem k` charges `size(n) = 2^(n^k)`
for the proof of `n`. As `k` climbs, the cost explodes faster and faster.

Climbing one rung of this ladder is a strict increase in proving power. The lower rung
`powSystem k` is simulated by the higher one `powSystem (k+1)` (because `2^(n^k)` is
smaller than `2^(n^(k+1))`), but **the higher rung is not simulated by the lower one** for
`k ≥ 1`. The reason is a sharp arithmetic gap: no polynomial in `2^(n^k)` can keep up with
`2^(n^(k+1))`, because the exponent `n^(k+1) = n · n^k` outpaces any constant multiple of
`n^k` once `n` is large enough.

The result is an **infinite, strictly increasing chain** of p-degrees:

```
powSystem 1  <  powSystem 2  <  powSystem 3  <  powSystem 4  <  ...
```

and these are genuinely *distinct* points of the poset — the map sending `k` to its
p-degree is injective. The order of p-degrees has **infinite height**. There is no ceiling
to how much proving power a system can have.

## Density: there is always a step in between

Here is the most surprising structural fact. The infinite staircase above might lead you
to picture proving power as coming in discrete jumps. It does not. **Between any two
consecutive rungs of the ladder there is always another p-degree, strictly between them.**

The witness is a clever *parity-glued* system. Define a new system that behaves like the
*upper* rung `2^(n^(k+1))` on even inputs, but falls back to the *lower* rung `2^(n^k)` on
odd inputs. This hybrid:

- is strictly *above* the lower rung (its even-indexed proofs are genuinely more
  expensive — too expensive for the lower rung to simulate), and
- is strictly *below* the upper rung (its odd-indexed proofs are genuinely cheaper — so it
  can't match the upper rung's relentless cost on every input).

Sandwiching these two strict inequalities yields a p-degree strictly between `powSystem k`
and `powSystem (k+1)`, for every `k ≥ 1`. The order of p-degrees is **dense along the
ladder**: no two consecutive rungs are adjacent, and you can always squeeze another degree
in between. The landscape has no smallest gap.

## A holographic surprise: distances on the boundary

The final movement of this story reaches into geometry. Think of a logical theory as a
graph: the "points" are formulas, and there is an edge `a → b` whenever a single axiom
takes you from `a` to `b`. The **proof distance** between two formulas is then the length
of the shortest derivation connecting them — the graph distance.

A *translation* between two theories is a map on formulas that realizes each axiom step of
the source by a short derivation (of length at most some fixed *stretch* `L`) in the
target. The key theorem is a kind of **holographic principle**: a translation of stretch
`L` sends every length-`k` derivation in the source to a derivation of length at most
`L·k` in the target. The fine-grained, step-by-step structure in the "bulk" of a proof
controls the coarse distance you see on the "boundary." Concretely, proof distance is
**L-Lipschitz** under translation: it can shrink, but it can never blow up by more than
the stretch factor.

And sometimes the bound is *exactly* attained. On the simplest theory of all — the chain
`0 → 1 → 2 → ...`, where proof distance from `a` to `b` is simply `b - a` — the doubling
map `n ↦ 2n` is a stretch-2 translation, and it multiplies every proof distance by exactly
2. The chain is the extremal, zero-slack proof geometry where the holographic inequality
becomes an equality.

## Why this matters

Step back and look at what we've found. The abstract universe of all proof systems,
organized by who can efficiently imitate whom, is a rich and beautiful ordered landscape:
a preorder with a well-defined poset of degrees, with greatest-lower-bound *meets*, with
an honest two-point separation powered by Fibonacci growth, with an infinitely tall
staircase of power-tower systems, with *density* guaranteeing a degree between any two
consecutive rungs, and with a holographic Lipschitz law governing how proof distances
transform.

This is the "order-theoretic core" of the Cook–Reckhow program. Cook and Reckhow showed
that the grand question — does there exist a single, most-powerful proof system that
p-simulates *all* others? — is intimately tied to the NP-versus-coNP problem, a sibling of
P versus NP. Understanding the *shape* of the simulation order is understanding the
geography in which that question lives. Every separation theorem in real proof complexity —
for resolution, for cutting planes, for Frege systems — is a statement about two specific
points in this landscape failing to simulate one another. The infinite, dense, holographic
structure we have charted is the terrain on which the deepest open problems of logic and
computation are fought.

The map is not the territory. But for once, we can prove the map is exactly right.
