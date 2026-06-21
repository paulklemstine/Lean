# Where Does the Crossing Happen? A Constructive Look at the Intermediate Value Theorem

## A theorem everybody believes

Picture a hiker who starts a walk at the bottom of a valley and finishes at the top of a ridge. At some point during the walk she must have stood exactly at sea level. This is so obvious that it barely feels like mathematics. Yet it is one of the cornerstones of calculus, where it goes by a formal-sounding name: the **Intermediate Value Theorem** (IVT).

In its classical form the IVT says: if $f$ is a continuous function on an interval $[a,b]$, and $f(a)$ and $f(b)$ have opposite signs, then there is some point $c$ between $a$ and $b$ where $f(c) = 0$. The function crosses zero somewhere; the hiker passes through sea level.

It is hard to imagine a statement more intuitive. But here is a question that has bothered mathematicians for over a century: **where, exactly, is that crossing point?** The classical theorem promises that a point $c$ exists. It does not tell you how to find it. And, more disturbingly, it turns out that *no general recipe can find it exactly*. The crossing point is real, but it can be uncomputable.

This article is about a different, more honest version of the theorem — one that does not merely assert the existence of a crossing but actually hands you a procedure to *locate it as precisely as you like*. This is the spirit of **constructive mathematics**, the program championed in the twentieth century by Errett Bishop, who insisted that to prove something exists you ought to be able to build it.

## The trouble with "there exists"

To see why the classical IVT is slippery, consider a function that hovers flat near zero for a while and then rises. If it is *exactly* zero across a whole stretch, then "the" crossing point is not even unique. Worse, you can engineer continuous functions whose unique crossing point encodes the answer to an undecidable problem — a number you can never pin down with any algorithm.

The deep issue is that **deciding the exact sign of a real number is impossible in general**. A real number is an infinite object: a never-ending stream of digits. To know for certain that some quantity is *exactly* zero, rather than a fantastically tiny positive or negative number, you would in principle have to inspect infinitely many digits. No finite computation can do that.

Bishop's response was radical and clarifying. Instead of asking "*at which point is $f$ exactly zero?*", ask the question an engineer or a numerical analyst would actually care about:

> Given any tolerance $\varepsilon > 0$, can we *find* a point $x$ where $|f(x)| \le \varepsilon$?

This is the **approximate intermediate value theorem**. It does not claim an exact root. It claims something you can actually deliver: a point where the function is as close to zero as you demand. And crucially, the proof of this version is a genuine algorithm.

## Continuity you can measure

Before we can search for a near-crossing, we need to know how *steady* the function is — how much it can change when its input changes a little. Classical continuity is famously abstract ("for every epsilon there exists a delta..."), and the delta is allowed to be conjured into existence without any way of computing it.

Constructive mathematics insists that the delta come with an instruction manual. This packaged form of continuity is called a **modulus of continuity**. Concretely, in our setting it is a promise of the following shape, tied to your chosen tolerance $\varepsilon$ and a step size $\delta$:

$$\text{for all } x, y \in [a,b], \quad |y - x| \le \delta \;\Longrightarrow\; |f(y) - f(x)| \le \varepsilon.$$

In plain words: *if two inputs are within $\delta$ of each other, their outputs are within $\varepsilon$ of each other.* The number $\delta$ is the explicit guarantee. It is not promised to exist somewhere; it is handed to you.

With this tool in hand, the strategy for finding a near-crossing becomes almost embarrassingly simple — and that simplicity is the whole point.

## The recipe: walk the grid

Here is the algorithm at the heart of this work.

1. **Lay down a grid.** Chop the interval $[a,b]$ into $N$ equal pieces. The grid points are
$$x_i = a + \frac{i}{N}(b - a), \qquad i = 0, 1, \dots, N.$$
The first point $x_0$ is $a$, the last point $x_N$ is $b$, and consecutive points are a uniform distance $(b-a)/N$ apart.

2. **Choose the grid fine enough.** Pick $N$ large enough that the spacing $(b-a)/N$ is at most $\delta$. Then by the modulus of continuity, the value of $f$ changes by at most $\varepsilon$ from one grid point to the next.

3. **Watch the sign flip.** We start with $f(a) \le 0$ and end with $f(b) \ge 0$. Walking along the grid, the value of $f$ goes from non-positive to non-negative. Somewhere a sign change must occur between two neighboring grid points.

4. **The crossing is right there.** At the grid point where the sign flips, the function cannot be far from zero — because it changes by at most $\varepsilon$ per step, and it sits on the boundary between negative and positive. That grid point $x$ satisfies $|f(x)| \le \varepsilon$.

That is the entire proof, and it is constructive through and through: it inspects finitely many points, finds the place where the sign changes, and returns it. No infinite digit-hunting, no appeals to the abstract completeness of the real line.

## The combinatorial heart

What makes this clean is that the genuinely *analytic* part of the argument (continuity, real numbers, distances) is completely separated from the genuinely *combinatorial* part (a finite sequence changes sign). The combinatorial core can be stated entirely about a finite list of numbers, with no mention of continuity at all:

> **Finite sign-change.** Let $u_0, u_1, \dots, u_N$ be any list of real numbers with $u_0 \le 0$ and $u_N \ge 0$. Then *either* some entry is exactly zero, *or* there is an adjacent pair $u_i, u_{i+1}$ where the list crosses from non-positive to non-negative (that is, $u_i \le 0$ and $u_{i+1} \ge 0$).

The proof is a small gem of logic. Suppose neither alternative held. Then no entry is zero and no adjacent pair straddles zero. Start at $u_0 \le 0$; since it is not zero, it is strictly negative. If $u_i$ is negative, then $u_{i+1}$ cannot be non-negative (that would be a sign change), so $u_{i+1}$ is also negative. By induction *every* entry is negative — including $u_N$. But we assumed $u_N \ge 0$. Contradiction. So one of the two alternatives must hold.

Notice that this lemma knows nothing about functions, limits, or continuity. It is pure finite reasoning about a row of numbers. This is the constructive philosophy made visible: isolate the finite, decidable skeleton of the argument, and bolt the analysis onto it afterward.

Building one rung up, we get the **discrete approximate IVT**: if our list of numbers starts non-positive, ends non-negative, and never jumps by more than $\varepsilon$ between neighbors, then *some* entry has absolute value at most $\varepsilon$. (If an entry is exactly zero, it certainly qualifies; if instead we found a sign-change pair, the non-negative member of that pair is at most one $\varepsilon$-jump above a non-positive number, so it is within $\varepsilon$ of zero.)

Feed the grid samples $u_i = f(x_i)$ into this discrete lemma, supply the modulus of continuity to guarantee the small-jump condition, and the full theorem drops out:

> **Approximate IVT with explicit modulus.** Let $f$ be a function on $[a,b]$ with $a \le b$. Suppose $f(a) \le 0 \le f(b)$, and suppose $f$ has the modulus property above for some step $\delta$ and tolerance $\varepsilon \ge 0$. Choose $N$ so the grid spacing $(b-a)/N$ is at most $\delta$. Then there is a point $x \in [a,b]$ with $|f(x)| \le \varepsilon$.

And a symmetric version handles the case where the signs are reversed — $f(a) \ge 0 \ge f(b)$ — simply by running the same argument on $-f$.

## Why this is more than a technicality

It would be easy to dismiss all this as philosophical fussing. The classical theorem is "true," after all; why insist on the approximate version?

The answer is that **the approximate version is the one computers actually use.** Every numerical root-finder — bisection, Newton's method, the algorithms inside your calculator and your spreadsheet — is in the business of producing a point where $|f(x)|$ is small, not a point where $f(x)$ is provably, exactly zero. The constructive IVT is the rigorous foundation for what these tools really do. When your software reports "the root is approximately $1.41421356$," it is delivering exactly the guarantee this theorem provides: a point within a known tolerance, found by a finite, terminating search.

There is also a deeper intellectual payoff. The classical IVT is usually proved by invoking the **connectedness** of the interval $[a,b]$ — a sophisticated topological property — or the **completeness** of the real numbers via a least-upper-bound argument. These proofs are elegant but non-constructive: they conjure the crossing point out of an abstract supremum you cannot compute. The development described here pointedly *avoids* all of that machinery. It never uses connectedness, never uses the classical IVT, never uses a least-upper-bound. It uses only a finite walk along a grid and a single inductive sign-change argument. The result is a theorem that is not only true but *transparent*: you can see precisely where the crossing comes from, and you could carry out the search by hand.

## The price and the prize

Constructive mathematics always extracts a price, and honesty about that price is part of its charm. The price here is that you do not get an exact root — you get an approximate one, and you must say in advance how close is close enough. You also must supply the modulus of continuity: the function has to come with its own steadiness guarantee, rather than relying on an abstract existence claim.

But look at the prize. In exchange for naming your tolerance, you receive an *actual algorithm*: lay the grid, walk it, return the spot where the sign turns over. The procedure halts. It inspects only finitely many points. Its cost is proportional to the number of grid points $N$, which you can read off directly from how steady the function is and how close you want to land. There is nothing mysterious, nothing uncomputable, nothing waiting at the end of an infinite digit expansion.

This is Bishop's vision in miniature: a classical theorem, beloved and intuitive, rebuilt so that every existence claim is backed by a construction. The hiker really does pass through sea level — and now we can tell her, to any precision she asks for, exactly where to look.

## Looking ahead

The simple grid search is the beginning, not the end. One natural refinement replaces the linear walk along $N$ points with a **bisection**: repeatedly cut the bracketing interval in half, homing in on the sign change in roughly $\log N$ steps rather than $N$. Another direction makes the search fully executable by pairing the function with a *certified inexact comparator* — a way to compare $f$ against zero accurately to within $\varepsilon$ using rational approximations — since the search never needs the exact sign, only a comparison good to tolerance $\varepsilon$.

And the idea generalizes upward in dimension. The **Poincaré–Miranda theorem** is the higher-dimensional cousin of the IVT, about maps of a box in $n$ dimensions with sign conditions on opposite faces. Its constructive, approximate form rests on a finite combinatorial labeling of a triangulated grid — a Sperner-style argument that, just like our one-dimensional sign-change lemma, contains no analytic content at all. The same clean separation between finite combinatorics and modulus of continuity that makes the one-dimensional story so transparent points the way to the multidimensional one.

The crossing exists. More than that: we can find it.
