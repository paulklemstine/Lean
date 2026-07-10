# Knots and Lattices: When a Knot Invariant Almost Counts Paths

## A tangle worth untangling

Take a piece of string, tie a knot in it, and glue the ends together. You now hold one of mathematics' most stubborn objects: a *knot*. It looks like a physical thing, but the questions it raises are ferociously abstract. Are two tangled loops secretly the same, just differently arranged in space? Or are they genuinely different, impossible to deform into one another without cutting?

To answer such questions, topologists attach *invariants* to knots — quantities that stay the same no matter how you wiggle the string. If two knots have different invariants, they must be genuinely different. The oldest and most beloved of these is the **Alexander polynomial**, discovered in 1928. To each knot $K$ it assigns a polynomial $\Delta_K(t)$ in a variable $t$ (and its reciprocal $t^{-1}$). The humble trefoil — the simplest nontrivial knot, the one you tie by accident in a garden hose — has Alexander polynomial

$$\Delta_{\text{trefoil}}(t) = t - 1 + t^{-1}.$$

The unknot, a plain circle, has $\Delta(t) = 1$. Because these differ, no amount of wiggling can turn a trefoil into a circle: the knot is real.

This article is the story of a tempting bridge between two worlds — the topology of knots and the combinatorics of counting — and of what happens when you actually try to cross it. The bridge nearly holds. Where it cracks is more interesting than if it had held all along.

## The seductive conjecture: knots as path-counters

Here is the dream. On the other side of mathematics from knot theory lives **combinatorics**, the art of counting arrangements. One of its cleanest objects is the *monotone lattice path*: a staircase route on graph paper that starts at the corner $(0,0)$ and climbs to $(n,n)$, taking only unit steps East or North. Each such path traces a silhouette, and beneath that silhouette sits an *area*. Count paths by their area and you get a **generating function**: a polynomial in $t$ whose coefficient of $t^k$ tells you how many paths enclose area exactly $k$.

$$G(t) = \sum_{\text{paths } p} t^{\operatorname{area}(p)}.$$

The conjecture that launched this investigation is audacious in its simplicity: *the Alexander polynomial is one of these path-counts*. That is, for every knot $K$ there should be a natural collection of lattice paths — a "knot lattice" — whose area generating function is exactly $\Delta_K(t)$. If true, this would mean a knot invariant is secretly a *combinatorial* object. Topology would become counting. The mysterious polynomial that distinguishes a trefoil from a circle would just be tallying staircases.

The idea is not pulled from thin air. The Alexander polynomial genuinely *does* have a combinatorial face, called a **state sum**. One decorates a knot diagram, marks each crossing with one of a few local choices, and calls the resulting global decoration a *state*. Each state $s$ carries two numbers: an *area* $a(s)$ and a *writhe* $w(s)$ that records a kind of twist. The theorem is that

$$\Delta_K(t) = \sum_{\text{states } s} (-1)^{w(s)}\, t^{a(s)}.$$

Look closely and you see the resemblance to path-counting: sum over configurations, weight each by $t$ raised to an area. The conjecture bets that the states are essentially lattice paths and that the whole thing reduces to a clean, positive count.

There is just one detail in that formula that the dream quietly ignores. The sign $(-1)^{w(s)}$.

## Where the bridge cracks

A count is a non-negative number. You cannot have $-1$ staircases of a given area, any more than you can have negative sheep in a field. So any honest path-count generating function has the property that *every one of its coefficients is at least zero*. Write out $G(t) = \sum_k c_k\, t^k$; each $c_k$ is literally the number of paths of area $k$, so $c_k \ge 0$.

Now look back at the trefoil:

$$\Delta_{\text{trefoil}}(t) = t - 1 + t^{-1}.$$

The coefficient of $t^0$ is $-1$.

That single minus sign is fatal. No collection of lattice paths, however cleverly chosen, and no definition of "area", however exotic, can ever produce a $-1$ in a coefficient — because coefficients of a genuine count are cardinalities, and cardinalities are non-negative. This is not a difficulty to be overcome with harder work or a bigger computer. It is a wall.

We can state the impossibility with full generality. Suppose someone hands us *any* finite set of "states" and *any* rule assigning each state an integer area. Form the unsigned generating function whose $t^k$ coefficient is the number of states of area $k$. Then:

> **Refutation.** This unsigned generating function can never equal $t - 1 + t^{-1}$. Its coefficient at $t^0$ would have to be both a non-negative count and equal to $-1$, which is impossible.

The claim is universally quantified: it rules out *every* state set and *every* area statistic at once. It is not that we failed to find the right lattice — it is that no right lattice exists. The literal conjecture, "every Alexander polynomial is an unsigned lattice-path count," is false, and the trefoil already proves it.

## The rescue: put the sign back

So the dream, taken literally, dies. But watch what happens when we stop pretending the sign isn't there.

Restore the weighting $(-1)^{w(s)}$ and allow states to contribute $+1$ or $-1$. Call the result the **signed state sum**: the coefficient of $t^k$ is now $\sum_{a(s)=k} \operatorname{sign}(s)$, a *signed* tally. For the trefoil, three states suffice. Give them areas $1$, $0$, and $-1$, and signs $+1$, $-1$, and $+1$. Add them up:

$$(+1)\,t^{1} + (-1)\,t^{0} + (+1)\,t^{-1} = t - 1 + t^{-1}.$$

Exactly the trefoil polynomial. So the invariant *is* a state sum after all — provided we grant it the one ingredient the naive conjecture threw away. The correct combinatorial model of the Alexander polynomial is not an unsigned path-count but a *signed* one. The sign is not a nuisance; it is the whole point.

There is a clean moral here about how mathematical ideas fail. The conjecture didn't miss by being vaguely wrong or hard to check. It missed by exactly one structural feature: the *sign group*. Unsigned counting lives in the non-negative integers; the Alexander polynomial lives one level up, in the world where things can cancel. Cancellation is precisely what lets a knot invariant carry information a raw count cannot.

## The hidden symmetry, explained

Signs do more than fix a coefficient — they *explain* one of the most striking features of Alexander polynomials. Look again at the trefoil: $t - 1 + t^{-1}$ reads the same forwards and backwards. Swap $t$ for $t^{-1}$ and nothing changes. This *reciprocity*,

$$\Delta_K(t) = \Delta_K(t^{-1}),$$

holds for *every* knot, not just the trefoil. Why should such a symmetry be automatic?

The signed picture gives a beautiful answer: it comes from a *pairing*. Imagine an operation $\varphi$ on the states — a "mirror" — that pairs each state with a partner. Suppose this mirror has three properties: applying it twice returns you to where you started (it's an *involution*); it *negates* area, sending a state of area $k$ to one of area $-k$; and it *preserves* sign, so partners contribute with the same $\pm 1$. Then the states of area $+k$ and the states of area $-k$ are matched one-to-one, with equal signs — so their signed tallies are equal. The generating function reads the same forwards and backwards:

> **Reciprocity from symmetry.** If a state set carries an area-negating, sign-preserving involution, its signed state sum is *palindromic*: the coefficient of $t^k$ equals the coefficient of $t^{-k}$ for every $k$.

The trefoil's three states carry exactly such a mirror: it fixes the central state and swaps the two outer ones, which indeed have opposite areas ($+1$ and $-1$) and equal signs. That is the entire reason $t - 1 + t^{-1}$ is a palindrome. A deep-looking analytic symmetry of a topological invariant turns out to be a simple fixed-point phenomenon in a finite set. Symmetry of the knot polynomial is combinatorial cancellation wearing a disguise.

## Meanwhile, the lattice paths have their own life

If lattice paths don't *equal* the Alexander polynomial, are they a dead end? Far from it. They form a rich combinatorial substrate in their own right, and studying them reveals constraints that any state-sum model must respect.

Encode a monotone path from $(0,0)$ to $(n,n)$ by recording *which* of its $2n$ steps go North. Since exactly $n$ steps are North, each path is precisely an $n$-element subset of a $2n$-element set of "slots". This dictionary is exact, and it immediately tells us how many paths there are: the number of ways to choose $n$ slots out of $2n$, the **central binomial coefficient**

$$\binom{2n}{n}.$$

For $n = 1, 2, 3$ this gives $2, 6, 20$ paths — the familiar staircase counts.

Because every path is an $n$-element set, families of paths are *uniform*: all their members have the same size. And uniform families are the natural habitat of one of the crown jewels of extremal combinatorics, the **Kruskal–Katona theorem**. It concerns the *shadow* of a family: the collection of all $(n-1)$-element sets obtained by deleting one element from some member. In path language, the shadow of a family of paths to $(n,n)$ is the family of shorter paths you get by erasing one North step and pulling the endpoint back toward the diagonal.

Kruskal–Katona says a family cannot be large while casting a small shadow. Specialized to paths, it reads:

> **Shadow bound for paths.** If a family of paths to $(n,n)$ has at least $\binom{k}{n}$ members (for $n \le k \le 2n$), then its shadow of shorter sub-paths has at least $\binom{k}{n-1}$ members.

In words: a dense collection of knot states is forced to have a dense collection of "lower" states beneath it. This is the combinatorial shadow of the topological state sum — a genuine constraint, not a metaphor. It hints that the complexity of a knot, measured through its state family, is tethered to the hard inequalities of extremal set theory.

## The bigger picture

What did we actually learn from a conjecture that turned out to be false?

First, a lesson in precision. "The Alexander polynomial counts lattice paths" is *almost* right, and the gap between almost and exactly is a single sign. Naming that gap — the difference between the non-negative integers and the integers, between counting and canceling — is more illuminating than a hundred confirmed examples would have been. Mathematics often advances by locating the exact fault line.

Second, a unification. Three seemingly separate facts about the Alexander polynomial — that it has a combinatorial state-sum formula, that its coefficients can be negative, and that it is always palindromic — turn out to be three views of one signed structure. The negativity is why it isn't a raw count; the palindromy is a pairing symmetry of its signed states; the state sum is the arena where both live.

Third, a bridge that partly holds. Lattice paths may not *be* the Alexander polynomial, but they carry the right shape — uniform families, area statistics, shadow inequalities — to constrain and illuminate it. Topology and combinatorics are not identified, but they are firmly roped together.

The trefoil in your garden hose, then, is quietly encoding all of this: a polynomial that reads the same in a mirror, a count that had to learn to subtract, and a staircase that almost, but not quite, tells the whole story. Sometimes the most honest thing a bridge can do is show you exactly where the river is too wide.
