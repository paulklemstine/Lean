# The Vote That Can Never Be Fully Audited

## A simple rule, an impossible shortcut

Imagine you run elections for a living. Not just any elections — the kind where
the outcome is not a single winner but a *collective position* drawn from a ring
of possibilities arranged in a circle: a budget level, a temperature setpoint, a
policy on a sliding scale. Society can land on any of $n$ positions, and you
think of those positions as the numbers $0, 1, 2, \dots, n-1$ arranged like the
hours on a clock, where after position $n-1$ you wrap back around to $0$.

Your job is to certify that a proposed decision procedure is *coherent* — that it
never contradicts itself. A self-contradiction, in this world, has a beautiful
and concrete form: a sequence of admissible "shifts" that, chained together,
should move society somewhere new but instead bring it exactly back to where it
started. If a procedure permits such a closed loop, it can be talked in a circle.
It is incoherent.

Now here is the dream every auditor has. Wouldn't it be wonderful if you could
certify coherence by checking only *short* loops? Check all the loops of length
up to, say, ten. If none of them closes, declare the procedure coherent and go
home. This would be a *finite test* — a fixed, bounded checklist that works for
every procedure, forever.

This article is about a theorem that crushes that dream, and does so in the most
constructive way imaginable. It does not merely say "no finite test exists." It
hands you, for *every* proposed checklist length, a perfectly legitimate, fully
"maximal" decision frame whose only flaw is a self-contradiction *just one step
longer* than your checklist can see. The flaw is always there. Your checklist
will always miss it. And we can name the exact length where each checklist goes
blind.

The mathematical object that measures all of this is a single number we call the
**incoherence index**, and the punchline is that this index can be made
arbitrarily large. There is no ceiling. The shortest self-contradiction can hide
arbitrarily deep.

## From committees to clock arithmetic

Let us make the picture precise, because the precision is where the beauty lives.

A **standard social decision frame** on $n$ states is a finite collection $F$ of
"atoms." Each atom is one of the residues $1, 2, \dots, n-1$ in the cyclic group
$\mathbb{Z}/n\mathbb{Z}$ — clock arithmetic modulo $n$. You should read an atom as
a single *admissible adjustment*: a recognized way that a strict majority (or a
tie-break) can nudge the collective position around the circle. The number $0$ is
deliberately excluded as an atom, because "do nothing" is never itself a
majority-driven move.

A **perfectly balanced sequence** is a non-empty list of atoms, drawn from $F$
(repetition allowed), whose total — added up in clock arithmetic — comes back to
$0$. In symbols, if the list is $x_1, x_2, \dots, x_k$ with each $x_i \in F$, then
$$x_1 + x_2 + \cdots + x_k \equiv 0 \pmod{n}.$$
This is exactly the "closed loop": a chain of legitimate majority moves that
returns society precisely to its starting state, as though nothing had happened —
even though every individual step was a genuine, recognized push. A balanced
sequence is the fingerprint of incoherence.

The **incoherence index** of a frame $F$, written $\mathrm{index}(F)$, is the
length of the *shortest* perfectly balanced sequence. If no balanced sequence
exists at all, the frame is genuinely coherent and we set the index to $0$. So:

- $\mathrm{index}(F) = 0$ means **coherent** — no closed loop, ever.
- $\mathrm{index}(F) = k \ge 2$ means the shortest self-contradiction needs
  exactly $k$ moves.

(Why never exactly $1$? A loop of length one would be a single atom equal to
$0$ — but $0$ is banned from being an atom. So the index is either $0$ or at
least $2$. This little gap will matter.)

Finally, a frame is **maximal** when its atoms *generate the entire circle*:
starting from $0$ and combining the admissible moves, you can reach every one of
the $n$ states. Maximality is the stamp of a serious, fully expressive decision
procedure. It rules out degenerate frames that can only ever reach half the
options. We want our impossibility result to apply to the *good* frames, not the
crippled ones — and it does.

## The humblest frame holds the deepest secret

Here is the construction that powers everything, and it is almost insultingly
simple. Take the single-atom frame
$$F = \{1\} \subseteq \mathbb{Z}/n\mathbb{Z}.$$
One admissible move: "step forward by one." That's the whole procedure.

First, **this frame is maximal.** Stepping forward by one, repeatedly, visits
every position on the clock: $0, 1, 2, \dots, n-1$ and back to $0$. The single
move $1$ generates the entire group. So $\{1\}$ is a legitimate, fully expressive
frame, not a degenerate toy.

Second, **what is its incoherence index?** A balanced sequence built only from
copies of the move $1$ is just "step forward $k$ times," whose total is $k
\pmod n$. For this to return to $0$, we need $n \mid k$. The shortest positive
such $k$ is $n$ itself. So the *only* way to talk this procedure in a circle is to
go all the way around — exactly $n$ steps. Therefore
$$\mathrm{index}(\{1\}) = n.$$

Read that again. The simplest possible non-trivial procedure on $n$ states — one
move, "increment" — has the *largest possible* incoherence index, namely $n$. Its
self-contradiction is real (go around the clock once and you're back home) but it
is maximally hidden: any audit that checks loops shorter than $n$ will see a
spotless, contradiction-free procedure.

This is the engine. By dialing $n$ up, we can place the shortest contradiction as
deep as we like.

## The checklist that always fails

Now we can state the impossibility cleanly. Fix any audit budget $B$ — your
checklist examines all loops of length at most $B$. Call a frame "**coherent up to
$B$**" if it passes this audit: no balanced sequence of length $\le B$ exists.

The first key theorem says the index is *exactly* the threshold where audits
start to bite. For any genuinely incoherent frame (one that has *some* balanced
sequence at all):
$$F \text{ passes the width-}B \text{ audit} \quad\Longleftrightarrow\quad
B < \mathrm{index}(F).$$
In words: a frame survives the length-$B$ checklist precisely when its shortest
contradiction is *longer* than $B$. The incoherence index is not a vague measure
of badness — it is the sharp dividing line between "the audit misses it" and "the
audit catches it."

From this the central result drops out like a stone. Take any budget $B$. Build
the frame $\{1\} \subseteq \mathbb{Z}/(B+1)\mathbb{Z}$. Its index is exactly
$B+1$. So:

- $B < B+1$: the frame **passes** the width-$B$ audit. Clean bill of health.
- $B+1 \not< B+1$: the frame **fails** the width-$(B+1)$ audit. One step further
  and the contradiction appears — the loop "increment $B+1$ times" closes.

And crucially, **this frame is maximal**: it is a fully expressive, legitimate
decision procedure, not a pathological edge case. So for *every* budget $B$, there
is a respectable frame that your length-$B$ checklist certifies as coherent, yet
which harbors a contradiction of length $B+1$. We call this the **strict
refinement** theorem: each time you extend your checklist by one, you genuinely
catch frames you couldn't catch before — and there is always a fresh culprit
waiting just beyond the new edge.

The consequence has a name worth savoring: **coherence is not finitely
axiomatizable.** No fixed, bounded family of short-loop checks can ever stand in
for the full coherence criterion. The hierarchy of finite approximations refines
strictly and *forever*; it never stabilizes, never closes, never becomes complete.
The full test — "is there *any* closed loop, of *any* length?" — cannot be
compressed into a finite checklist. You must, in principle, be willing to look
arbitrarily far.

## Why density is the enemy of hiding

A natural objection: surely large indices are some fragile, exotic phenomenon? In
fact the opposite is true, and the contrast is illuminating.

The extremal index $n$ is the *exclusive privilege of the sparse, single-generator
frame*. The moment you enrich a frame with more atoms, short contradictions tend
to appear and the index collapses. The cleanest illustration lives on a clock of
size $4$. Compare two maximal frames:

- The sparse frame $\{1\} \subseteq \mathbb{Z}/4\mathbb{Z}$ has index $4$: the
  only closed loop is "increment four times."
- The saturated frame $\{1, 3\} \subseteq \mathbb{Z}/4\mathbb{Z}$ has index
  **just $2$**: the two moves $1$ and $3$ already sum to $4 \equiv 0$, so the loop
  $[1, 3]$ closes immediately.

Both frames are maximal — each contains the generator $1$ — so reachability is
identical. The chasm between index $4$ and index $2$ is caused *purely by atom
density*. Adding the extra move $3$ created an instant short-circuit. This tells
us something structural: **maximality alone does not determine the index.** To
hide a contradiction deeply you need not just an expressive procedure but a
*sparse* one. Richness of options is, paradoxically, what exposes incoherence
quickly; austerity is what conceals it.

## The spectrum has no ceiling

Putting the pieces together, the incoherence index roams freely upward. For every
target $N$, the frame $\{1\} \subseteq \mathbb{Z}/(2N+4)\mathbb{Z}$ has index
$2N+4 > N$ — and that index is even, maximal, and realized by a fully legitimate
frame. So the set of achievable indices is **unbounded**. There is no largest
incoherence index; there is no deepest possible hiding place; there is no finite
"worst case" you could prepare for once and be done.

In fact one can pin down the extremal landscape exactly. On $n$ states, the
largest index any non-empty frame can have is precisely $n$ — because you can
always close *some* loop by repeating a single atom $n$ times, "going around the
clock." And that maximum of $n$ is *attained*, by our humble friend $\{1\}$. The
incoherence index thus ranges over $0$ (coherent), then jumps to the band from $2$
up to $n$, with the top of the band reserved for the sparsest maximal frame. For
every even $n \ge 4$ — and indeed every $n$ — that top value $n$ is realized by a
genuine maximal frame.

## Why this matters beyond the clock

It is tempting to file this away as a cute fact about modular arithmetic, but the
shape of the argument recurs across mathematics and computer science.

A perfectly balanced sequence is, stripped of its social-choice costume, a
**zero-sum sequence** in a finite abelian group — exactly the objects studied by
additive combinatorics under the banner of the *Davenport constant*. The shortest
balanced sequence is a minimal zero-sum, and the incoherence index is a
Davenport-constant-style invariant. The fact that this invariant is unbounded, and
that it is *exactly* the threshold controlling a hierarchy of finite tests, is a
clean instance of a recurring theme: **local checks cannot certify global
structure when that structure can hide at unbounded depth.**

The same drama plays out wherever people hope to replace an infinite criterion
with a finite checklist:

- In **formal logic**, many natural properties are not finitely axiomatizable;
  the strict refinement of finite fragments is precisely how one proves it.
- In **verification and testing**, "test all behaviors up to depth $B$" is the
  industry's bread and butter — and this result is a sharp parable for why
  bounded testing can never, in general, substitute for a full proof: an adversary
  can always plant a bug exactly one step beyond your horizon.
- In **social choice theory** itself, it tempers a seductive hope. We would love
  to certify that a voting rule is consistent by inspecting only small
  coalitions or short cycles of preference. This says: in the strict-majority
  setting modeled here, no such bounded inspection is ever enough. Consistency is
  irreducibly a global property.

The deepest lesson is almost philosophical. There is a recurring fantasy that
complexity can always be tamed by a sufficiently long, but still *finite*,
checklist — that with enough diligence we can bound the unknown. The incoherence
index is a crisp, fully rigorous refutation of that fantasy in one concrete arena.
For every checklist you write, however long, there sits a legitimate, expressive,
maximal decision procedure whose single hidden contradiction lies exactly one step
past your last line. The contradiction is real. Your checklist is finite. And the
gap between them never closes.

## The number to remember

If you take one thing away, let it be the number $\mathrm{index}(\{1\}) = n$: the
simplest procedure on a clock of $n$ states hides its only contradiction as far
away as it possibly can. Increase $n$, and the hiding place recedes without limit.
That single, elementary computation — "to get back to zero by stepping forward,
you must step forward exactly $n$ times" — is the seed from which the entire
impossibility grows. Sometimes the deepest secrets are kept by the humblest
things.
