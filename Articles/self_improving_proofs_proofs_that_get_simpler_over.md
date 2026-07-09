# Living Proofs: When Mathematical Arguments Simplify Themselves

## A proof is never finished

Ask a mathematician what a proof *is*, and you will usually hear something
static: a fixed sequence of logical steps, frozen the moment the last line is
written. But anyone who has taught a course twice knows better. The proof you
give in year two is shorter, cleaner, and more transparent than the one you gave
in year one. A clumsy case split collapses into a single observation. A lemma
you thought you needed turns out to be unnecessary. A quantifier vanishes.

This everyday experience hides a precise mathematical question. If proofs can be
*improved* — made simpler while still proving the same thing — then improvement
is a process, and processes can be studied. Does simplification always
terminate, or can a proof be polished forever? Is there a single "simplest"
proof of each theorem, a Platonic ideal toward which all our fumbling drafts
converge? And if you simplify greedily, always taking the next available
shortcut, are you guaranteed to arrive at that ideal?

This article tells the story of a small, self-contained theory that answers all
three questions. Two of the answers are reassuring. The third is a warning.

## What is a "refinement system"?

To reason about improvement we first have to say what a proof, and its
complexity, actually are — abstractly enough that the theory applies to any
notion of proof one likes.

Fix a single statement you want to prove; call it the **target**. A
**refinement system** for that target consists of three ingredients:

- A collection of **proof candidates** — the concrete arguments one might offer.
- A **validity** test: for each candidate, a yes/no verdict on whether it really
  does establish the target. A candidate that passes is called *valid*.
- A **complexity measure** $C$ assigning to each candidate a natural number.
  Think of $C(P) = \text{length}(P) + \text{depth}(P) + (\text{number of lemmas
  used})$, but any whole-number cost will do.

The crucial move is that complexity is measured in the natural numbers
$0, 1, 2, \dots$ — a set with no infinite descending staircase. That single fact
drives everything that follows.

Now define what it means for one proof to be *better* than another. A candidate
$P'$ **refines** $P$ when

$$P' \text{ is valid}, \quad P \text{ is valid}, \quad \text{and} \quad C(P') < C(P).$$

In words: both are genuine proofs of the same target, and $P'$ is strictly
simpler. Refinement is the act of replacing a proof by a better one.

## First good news: you cannot polish forever

Here is the first temptation to resist. Because you can *always imagine* a
proof getting simpler, you might fear that simplification could go on without
end — an infinite regress of ever-tinier proofs, never reaching bottom.

It cannot. This is the **Well-Foundedness of Refinement**:

> **Theorem.** In any refinement system there is no infinite chain
> $$P_0 \succ P_1 \succ P_2 \succ \cdots$$
> in which each $P_{n+1}$ refines $P_n$.

The reason is almost embarrassingly simple, and that simplicity is the point.
Each refinement step strictly decreases the complexity, and complexity is a
natural number. An infinite chain of refinements would produce an infinite
strictly-decreasing sequence of natural numbers $C(P_0) > C(P_1) > C(P_2) >
\cdots$, and no such sequence exists — you would run out of room above zero.
Formally, refinement is a *sub-relation* of "has strictly smaller complexity,"
and the latter is well-founded because $<$ on $\mathbb{N}$ is. Any property that
is inherited by sub-relations of a well-founded relation is therefore true of
refinement too.

The moral: **every simplification effort must eventually terminate.** No proof
is a bottomless well of improvement.

## Second good news: a simplest proof always exists

Termination of *each individual chain* is one thing. The existence of a genuine
champion — a proof no one can beat — is another, stronger claim. It holds too.

> **Theorem (Existence of a Simplest Proof).** As soon as the target has *any*
> valid proof at all, it has a valid proof whose complexity is less than or
> equal to that of *every* valid proof.

This is the promised "limit" of the refinement process made rigorous: a
complexity-minimal valid candidate, the simplest possible argument for the
theorem. The proof again leans on well-foundedness. Consider the set of all
valid candidates; it is non-empty by hypothesis. A well-founded relation always
has a *minimal element* in any non-empty set — an element from which you cannot
descend further. Such a minimal valid candidate has no valid refinement, which
means no valid proof is strictly simpler; that is exactly what it means to be a
global minimum of complexity.

So the dream is partly real. For every provable theorem there is a simplest
proof, and it is reachable in the sense that improvement always drives you
downward toward the minimal complexity.

## Third good news, with a catch: the process halts

What about an *automated* simplifier — a fixed rule that, given a proof, hands
you back a proof that is never more complex? Iterate it and watch the complexity
evolve. Does it settle down?

> **Theorem (Halting).** Let $\text{step}$ be any deterministic rule that never
> increases complexity: $C(\text{step}(P)) \le C(P)$ for every candidate $P$.
> Then starting from any proof $P_0$ and repeatedly applying the rule, the
> complexity eventually becomes constant. There is a stage $N$ after which
> $C(P_N) = C(P_{N+1}) = C(P_{N+2}) = \cdots$.

The complexities form a non-increasing sequence of natural numbers. Such a
sequence is bounded below by $0$, so it attains a minimum value; once it reaches
that value it can never rise again, and being non-increasing it can never fall
further either. It is pinned. The process *stabilizes*.

But here the catch of the whole story announces itself. Stabilizing is not the
same as *finishing the job*.

## The warning: local minima that are not global

The three theorems above paint an optimistic picture: improvement terminates, a
best proof exists, and automated polishing settles down. It would be natural to
conclude that if you simplify diligently, you will land on the simplest proof.

That conclusion is **false**, and it is false for a reason familiar to anyone who
has hiked a hilly landscape in fog: you can walk downhill until every direction
leads up, and still be standing in a shallow dip far above the valley floor.

Consider a deterministic simplifier operating on four proofs of one true target,
with complexities $5, 4, 3,$ and $2$. Call them *start*, *mid*, *local*, and
*global*. The simplifier's rule is:

$$\text{start} \;(5) \longmapsto \text{mid}\;(4) \longmapsto \text{local}\;(3) \longmapsto \text{local}\;(3) \longmapsto \cdots$$

From *start* it steps to *mid*, from *mid* to *local*, and from *local* it can
find no further legal improvement, so it repeats *local* forever. Everything the
theorems promised holds: the process descends, it never increases complexity,
and it halts — pinned at complexity $3$.

And yet a strictly simpler valid proof exists: *global*, of complexity $2$. It is
a perfectly legitimate refinement of *local* in the abstract sense — valid, and
strictly simpler. The simplifier simply never produces it, because *global* is
not among the moves its rule allows. The automated process is trapped in a
**local minimum**; the **global minimum** sits nearby, out of reach.

This is the sharp edge of the theory. Well-foundedness guarantees you stop.
Existence guarantees there is a best answer. Halting guarantees the machine
settles. None of them guarantees the machine settles on the best answer. The
gap between *a* minimum and *the* minimum is real and unavoidable for greedy,
step-by-step improvement.

## Not even a unique summit

One might still hope that at least the simplest proof is *unique* — a single
canonical argument crowning each theorem. Even this modest hope fails.

Take the humble target $2+2=4$. It has (at least) two genuinely different
one-line proofs: one by direct computation, one by a normalization routine. Both
are valid; both have complexity $1$; and no proof can be simpler than complexity
$1$. So there are **two distinct simplest proofs**, tied for the crown, neither
refining the other. "The simplest proof" is, in general, "*a* simplest proof."
Minimality is a property, not an address.

## How long is the road?

If simplification always terminates, one last question remains: *how quickly?*
Here the answer is a study in contrasts.

Every refinement chain is **finite**, and in fact its length is bounded by the
complexity of where you started: a chain beginning at a proof of complexity $m$
can take at most $m$ genuine steps, since each step burns at least one unit of
complexity and you cannot go below zero.

Yet this bound is **tight**, and there is no *universal* limit. For every whole
number $m$, one can exhibit a target and a chain of refinements exactly $m$ steps
long. There is no single number of steps that suffices for all theorems. This is
the rigorous heart of a striking intuition: the simplest proof of a theorem
might be reached only after an astronomically long march of improvements — a
googol of refinements, if you like — even though that march is guaranteed to be
finite. The four-color theorem's simplest proof might lie a hundred-digit number
of simplifications away from the sprawling argument we currently possess. It is
down there. The path to it is finite. But finite can be very, very long.

## Why this matters

There is a quiet philosophical shift buried in these theorems. We are used to
treating a proof as a finished artifact, correct or incorrect, and leaving it at
that. This theory invites us to see proofs instead as points in a landscape of
complexity, connected by the act of refinement — *living objects* that can be
improved, compared, and optimized.

The picture that emerges is honest about both the promise and the limits of that
view. Improvement is always well-founded: you will never chase simplicity
forever. A simplest proof always exists: the search has a genuine target.
Automated polishing always stabilizes: the machinery is well-behaved. But
greedy, local improvement can strand you in a shallow valley, the true simplest
proof may not be unique, and the road to it, though finite, can be
unfathomably long.

These are not merely observations about mathematics. They are the same shapes
that govern optimization everywhere — training a learning system, minimizing
energy in a physical model, compressing a file. Downhill is easy to guarantee.
*The bottom* is not. In understanding when proofs simplify themselves, we are
really studying the universal tension between local effort and global truth — and
learning, precisely, where the one stops short of the other.
