# When Everyone Must Take a Side: The Geometry of Winning Arguments

## A debate with no fence-sitters

Imagine a heated debate. On the table lies a collection of claims, and between
some of them there is open conflict: claim $a$ attacks claim $b$, meaning that if
you accept $a$ you cannot, in good conscience, also accept $b$. This is the whole
of the setup — a set of *arguments* together with a relation of *attack*. It is
astonishingly bare, and yet from these two ingredients an entire theory of
rational agreement grows.

The central question is: **which sets of arguments can a reasonable person hold
all at once?** A first, obvious requirement is *internal peace*. A defensible
position should not contain two claims that attack each other; it should be
**conflict-free**. But conflict-freeness alone is weak. A single lonely claim is
conflict-free, and so is the empty position of believing nothing at all. What
separates a genuinely *winning* position from a merely quiet one?

The answer that concerns us here is the sharpest of them all: the **stable
extension**. A position $S$ is stable when it is conflict-free **and it leaves
nobody on the fence**. Every argument you have *not* accepted must be actively
knocked out by something you *have* accepted. In symbols, for every argument
$a \notin S$ there is a $b \in S$ with $b$ attacking $a$. Stable positions are the
"no abstention" verdicts: each claim in the debate is either embraced or
explicitly defeated. There is no third category of the merely undecided.

This article tells the story of stable positions — why they sit at the very top
of a natural hierarchy of "reasonable" positions, how in the symmetric world of
mutual disagreement they coincide exactly with the most economical positions, and
how, in a beautiful final twist, *counting* them turns out to be the same as
computing a classical topological invariant, the **Euler characteristic**.

## A ladder of reasonableness

Not all conflict-free positions are equally defensible. Philosophers of
argumentation identified a whole ladder of standards, each stricter than the last.
Our results show that a stable position climbs every rung of that ladder at once.

The rungs, from the ground up, are these.

- **Conflict-free**: no internal contradictions.
- **Admissible**: conflict-free *and self-defending*. A position defends a claim
  $a$ if, whenever some outsider $b$ attacks $a$, the position contains a
  counter-attacker $c$ (a $c \in S$ with $c$ attacking $b$). An admissible
  position defends all of its own members — it can rebut every challenge to
  anything it believes.
- **Complete**: admissible *and closed under defense*. Whatever the position is
  able to defend, it already contains. It has no blind spots: any claim it could
  successfully champion, it has already adopted.
- **Preferred**: a *maximal* admissible position. You cannot add a single further
  claim while remaining admissible. These are the boldest defensible verdicts.

Our first main result is that a stable position is not merely one of these — it is
all of them simultaneously.

**Theorem (the stable hierarchy).** *Every stable extension is preferred, hence
complete, hence admissible, hence conflict-free.*

The proof is a short chain of elementary observations, each pleasing in its own
right.

First, **a stable position defends every claim it holds**. Suppose $a \in S$ and
some $b$ attacks $a$. Could $b$ also lie in $S$? No — then $S$ would contain the
mutual conflict $b$-attacks-$a$, violating conflict-freeness. So $b$ lies outside
$S$, and stability guarantees that something inside $S$ attacks $b$. That is
exactly a successful defense of $a$. Hence every stable position is admissible.

Second, **a stable position is complete**. Suppose the position could defend some
claim $a$ but did not contain it. Since $a \notin S$, stability hands us an
attacker $b \in S$ of $a$. But the position defends $a$, so it also contains a
counter-attacker $c \in S$ hitting $b$. Now $b$ and $c$ both live in $S$ and $c$
attacks $b$ — a conflict inside a conflict-free set. Contradiction. So a stable
position already holds everything it can defend.

Third, and most strikingly, **a stable position is preferred**. Suppose an
admissible position $T$ contains $S$. Take any claim $a$ in $T$. If $a$ were
outside $S$, stability would give an attacker $b \in S \subseteq T$ of $a$; but
then $T$ contains both the attacker $b$ and its target $a$, contradicting the
conflict-freeness of $T$. So $T$ can contain nothing beyond $S$, and $T = S$. A
stable position is thus a *maximal* defensible verdict: nothing can be added to
it.

The very same argument, read one level down, shows that **a stable position is a
facet** — a maximal conflict-free set. Geometrically, if we build a shape whose
faces are exactly the conflict-free sets (a construction we return to below), the
stable positions are among its largest faces.

## The skeptic always agrees

At the opposite extreme from the bold, maximal stable verdicts sits the most
cautious voice in the room: the **grounded extension**. It is the position a
perfect skeptic would hold — accept a claim only if you are *forced* to, only if
it is defended by claims you were already forced to accept, and so on from the
ground up. Formally it is the smallest position closed under defense, built by
starting from nothing and repeatedly adding every claim the current position can
defend until nothing new appears.

Our next result links the timid skeptic to every bold partisan.

**Theorem.** *The grounded extension is contained in every stable extension.*

In words: whatever the cautious skeptic is compelled to accept, every committed
stable partisan accepts too. The skeptic's verdict is the common core shared by
all the "no abstention" positions. The proof is a single line once the pieces are
in place: a stable position is closed under defense, and the grounded extension is
by construction the *smallest* such position, so it sits inside.

## The symmetric world: economy equals strength

So far attack has been a one-way street: $a$ can attack $b$ without $b$ attacking
back. But a great many real disagreements are **symmetric** — if two claims
contradict each other, the contradiction cuts both ways. And no sensible claim
attacks itself, so we also ask that the relation be **irreflexive**. This is the
world of pure mutual incompatibility.

In this world something remarkable happens: the entire top of the ladder
collapses into a single rung.

**Theorem (symmetric collapse).** *In a symmetric, irreflexive framework, a
position is stable if and only if it is preferred if and only if it is a facet —
a maximal conflict-free set.*

Two forces conspire to produce this. On one hand, symmetry makes *self-defense
free*: if $b$ attacks a member $a$ of your position, then $a$ attacks $b$ right
back, so the position defends itself using nothing but its own members. This
already tells us every conflict-free set is admissible, and hence the preferred
positions are exactly the maximal conflict-free ones.

On the other hand, maximality forces stability. Suppose $S$ is a maximal
conflict-free set and some $a$ lies outside it. Because $S$ is maximal, we cannot
enlarge it to $S \cup \{a\}$ without creating a conflict. Irreflexivity means $a$
does not conflict with itself, so the trouble must be a clash between $a$ and some
$b \in S$. Symmetry then turns that clash into an attack from $b \in S$ onto $a$.
So $a$ is attacked from within $S$ — which is exactly what stability demands. The
most economical positions (the maximal conflict-free ones) and the strongest
positions (the stable ones) are one and the same.

## Counting positions with topology

Here the story takes its most surprising turn. Let us build a geometric object
out of the debate. Declare every conflict-free set of arguments to be a *face* of
a shape $K$. A single compatible argument is a vertex; a compatible pair is an
edge; a compatible triple fills in a triangle; and so on. This shape — a
**simplicial complex** — encodes at a glance which claims can coexist.

Every shape has an **Euler characteristic**, the alternating count
$$\chi = (\text{vertices}) - (\text{edges}) + (\text{triangles}) - \cdots,$$
a single integer famously invariant under continuous deformation. For a hollow
sphere it is $2$; for a doughnut, $0$; for a scattering of $n$ isolated dots, it
is simply $n$.

To make the connection concrete, consider the most contentious debate imaginable:
the **complete conflict graph** on $n$ arguments, in which every two distinct
claims attack each other. Here no two claims can coexist, so the only
conflict-free sets are the empty set and the singletons. The geometric shape $K$
is therefore just $n$ isolated points — no edges, no triangles, nothing higher.
Its Euler characteristic is exactly $n$.

What are the stable positions of this all-against-all debate? A conflict-free
position can hold at most one claim, and to leave nobody on the fence it must hold
*exactly* one — a single claim attacks every other. So the stable extensions are
precisely the $n$ singletons, and there are exactly $n$ of them.

Comparing the two counts yields the punchline.

**Theorem (the stable Euler bridge).** *For the complete conflict graph on
$n \geq 1$ arguments, the Euler characteristic of the coexistence complex equals
the number of stable positions:*
$$\chi(K) = \#\{\text{stable extensions}\} = n.$$

A purely *logical* quantity — how many all-or-nothing verdicts a debate admits —
turns out to equal a purely *topological* one — the Euler characteristic of a
shape assembled from the debate. Two subjects that have no obvious business
together are here in exact numerical agreement. At $n = 4$, for instance, both
sides of the bridge read $4$: four isolated points, four stable verdicts.

## Why it matters

This little theory is a miniature of what mathematics does best: it strips a
messy human phenomenon — argument, disagreement, the search for a defensible
stance — down to two bare relations and then discovers unreasonable order lurking
inside. The hierarchy of positions gives a precise vocabulary for how demanding a
standard of "reasonableness" one wants. The symmetric collapse tells us that in
the common case of mutual disagreement, being *maximally economical* and being
*maximally decisive* amount to the same thing. And the Euler bridge reveals that
the number of decisive verdicts is not an accident but a shadow of a geometric
invariant.

Abstract argumentation frameworks are not idle toys. They underpin systems that
reason with conflicting information — legal reasoning, multi-agent negotiation,
inconsistency-tolerant databases, and the machinery by which automated agents
weigh competing recommendations. Knowing that stable verdicts sit atop a clean
hierarchy, that a cautious core is shared by all of them, and that their number is
a topological invariant, gives both a sturdier theoretical foundation and, in
concrete cases, a shortcut for counting solutions.

The next time you find yourself in an argument where everyone must, at last, take
a side, remember: you are standing inside a geometric object, and the number of
ways the debate can end is written in its shape.
