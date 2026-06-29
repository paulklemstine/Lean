# When a Network Falls Apart: The Hidden Geometry of Connectivity

## A puzzle about cutting things in two

Imagine you are handed a sprawling network — a power grid, a corporate
org-chart, a tangle of correlated genes — and you ask the most basic
question one can ask about any structure: *is it all one piece?* A network
is **connected** if you cannot split it into two independent halves without
something important leaking across the boundary. It is **disconnected** if
it secretly consists of two pieces that do not really talk to each other.

Now make the puzzle harder. Pick one special element of your network — a
single hub, a single gene, a single road — and start *spending* it.
Mathematicians call this taking a **slice-projection** (or a *contraction*):
you contract more and more of that element's "capacity" into the structure
and watch how the rest reorganizes around it. At each stage you get a new,
smaller network, and you can ask again: *is this one connected?*

You now have a sequence of yes/no answers, one for each amount $j$ of the
element you have spent, from $j = 0$ all the way up to $j = f(e)$, the
element's full **rank**. Written out, it might look like

$$\text{connected? } \quad \text{Y, Y, Y, N, N, Y?}$$

The deep question — the one this work is about — is: **what patterns are
possible?** Can connectivity flicker on and off arbitrarily as you spend the
element, or is there a hidden law forcing the answer into a rigid shape?

## The conjecture: connectivity lives on an interval

The guiding belief, the **Interval Property**, is striking in its
simplicity:

> For a connected structure and any element $e$, the set of spending levels
> $j \in \{0, 1, \dots, f(e)\}$ at which the slice-projection is **connected**
> forms one unbroken interval of integers.

In plain language: once connectivity turns off, it stays off, and once it
turns on, it stays on within a single contiguous run. You can never see the
forbidden flicker $\dots\text{Y, N, Y}\dots$. The "connected" answers huddle
together into a single block like $\text{N, N, Y, Y, Y, N}$ — never
scattered.

This is a *strengthening* of a known fact: that **no two consecutive
slice-projections can both be disconnected**. That older result rules out
$\dots\text{N, N}\dots$ in certain regimes; the Interval Property is the
bolder claim that the connected answers form a single solid stretch. For the
classical objects called **matroids**, the property is automatic and almost
boring, because there the rank $f(e)$ is at most $1$ — there is essentially
nothing to spend, so the sequence has length one or two and is trivially an
interval. The richness appears only for **polymatroids**, the
continuous-capacity cousins of matroids, where an element can carry many
units and the sequence becomes genuinely long.

## A surprising bridge: connectivity as a Fourier expansion

Here is where the story takes an unexpected turn. The natural way to attack
the Interval Property is through a piece of mathematics that looks, at first,
like it belongs to an entirely different universe: **tropical Fourier
analysis**.

In ordinary Fourier analysis you take a complicated signal and write it as a
sum of simple waves. In the **tropical** (or **max-plus**) world, addition
is replaced by *taking a maximum* and multiplication is replaced by ordinary
*addition*. A "sum of waves" becomes a **maximum of tilted ramps**. This is
not a curiosity: it is the native algebra of optimization, scheduling,
shortest paths, and — as it turns out — of the rank functions that govern
connectivity.

Concretely, fix a finite **dictionary** of basic modes $\varphi_k$, each a
real-valued pattern on a finite domain. A function $f$ has a **tropical
Fourier expansion** if it can be written as

$$f(x) = \max_k \big( c_k + \varphi_k(x) \big)$$

for some coefficients $c_k$. We call such an $f$ **order-convex** over the
dictionary: it is, in the tropical sense, a "convex combination" of the
modes. The whole question of whether connectivity behaves nicely becomes a
question of whether the relevant rank functions admit such an expansion.

## The tight coefficient: the largest ramp that fits underneath

The engine of the theory is a beautifully concrete construction. Given a
target function $f$ and a single mode $\varphi_k$, what is the *best*
coefficient $c_k$ to use? You want $c_k + \varphi_k$ to push up as high as
possible against $f$ without ever poking through it. The answer is forced:

$$\text{tightCoeff}(f, \varphi, k) \;=\; \min_x \big( f(x) - \varphi_k(x) \big).$$

This is the largest scalar $t$ such that $t + \varphi_k \le f$ everywhere —
the highest you can slide the ramp $\varphi_k$ up until it just kisses the
graph of $f$ from below. Assembling all these tight ramps and taking their
upper envelope gives the **canonical reconstruction**:

$$\text{reconstruct}(f, \varphi, x) \;=\; \max_k \big( \text{tightCoeff}(f, \varphi, k) + \varphi_k(x) \big).$$

This object is the tropical analogue of the **Fenchel–Moreau biconjugate**
— the best possible approximation of $f$ from below that the dictionary can
produce. Two facts about it are intuitive and were both verified rigorously:

- **It never overshoots.** The reconstruction is always $\le f$ everywhere.
  (Each ramp was built to fit underneath, so their maximum still fits
  underneath.)
- **It dominates every rival.** If any coefficients $c_k$ give ramps fitting
  under $f$, then each $c_k$ is $\le$ the tight coefficient. The canonical
  reconstruction is the unique best one — nothing legal beats it.

## The finite-discrepancy criterion

Because the reconstruction can only ever fall short, we can measure exactly
*how* short. The **discrepancy** is the worst-case gap:

$$\text{discrepancy}(f, \varphi) \;=\; \max_x \big( f(x) - \text{reconstruct}(f, \varphi, x) \big).$$

It is always $\ge 0$ — the reconstruction never exceeds $f$. And now comes
the headline theorem, clean and exact:

> **Main Theorem (finite-discrepancy criterion).**
> A function $f$ is order-convex over the dictionary — that is, it admits
> *some* tropical Fourier expansion — **if and only if** its discrepancy is
> exactly zero:
> $$\text{OrderConvex}(f, \varphi) \iff \text{discrepancy}(f, \varphi) = 0.$$

The logic is a small gem and avoids any circular reasoning. If $f$ has an
expansion at all, then by the domination property its *own* coefficients are
beaten by the tight ones, so the canonical reconstruction already reaches
$f$ — the gap closes. Conversely, if the gap is zero, the tight coefficients
*are* an explicit expansion. The criterion turns an existential question
("does *any* expansion exist?") into a single computable number ("is this
maximum zero?"). That is the dream of every working mathematician: a yes/no
property reduced to a finite calculation.

## Back to polymatroids and connectivity

This abstract machinery is not floating free; it is bolted onto the geometry
of connectivity. A **polymatroid** is a real-valued function $f$ on the
subsets of a finite ground set that obeys three rules every reasonable
"capacity" or "rank" measure obeys:

- **Normalized:** the empty set has rank $0$, i.e. $f(\emptyset) = 0$.
- **Monotone:** larger sets have at least as much rank, i.e. $A \subseteq B
  \implies f(A) \le f(B)$.
- **Submodular:** there are diminishing returns,
  $$f(A \cup B) + f(A \cap B) \le f(A) + f(B).$$

The **slice-projection** of $f$ by a slice $s$ is the contracted function

$$\text{sliceProj}(f, s, A) \;=\; f(A \cup s) - f(s),$$

which simply re-bases the world around having already committed $s$. A first
structural result confirms that the family is closed under this operation:

> **Slice-projections preserve the species.** If $f$ is a polymatroid, then
> every slice-projection $\text{sliceProj}(f, s, \cdot)$ is again a
> polymatroid (`sliceProj_isPolymatroid`).

Connectivity is then captured by the **connectivity function**

$$\lambda(A) \;=\; f(A) + f(A^{\mathsf c}) - f(E),$$

which measures how much "leaks" across the cut separating $A$ from its
complement $A^{\mathsf c}$ inside the full ground set $E$. A second result
guarantees this measure is never negative — neither for a polymatroid nor
for any of its slice-projections:

> **Connectivity is nonnegative.** For a polymatroid, $\lambda(A) \ge 0$ for
> every $A$, and the same holds for every slice-projection
> (`polyConnectivity_nonneg`, `sliceProj_polyConnectivity_nonneg`).

A cut with $\lambda(A) = 0$ is a genuine clean break; the structure is
*connected* precisely when no such clean break exists for a nontrivial $A$.

## The well-behaved case, and a sharp counterexample

Two final results pin down the boundaries of the theory.

On the positive side, the simplest polymatroids of all — the **modular**
(weighted-cardinality) functions, where $f(A)$ is just the total weight of
the elements in $A$ — are always order-convex and therefore always pass the
criterion with zero discrepancy (`modular_orderConvex`,
`modular_discrepancy_zero`). These are the "perfectly tame" functions whose
connectivity profile is as regular as can be.

On the cautionary side, the theory exhibits an explicit **counterexample**
showing the order-convexity hypothesis is genuinely needed. Take a single
constant mode as your entire dictionary and ask it to reconstruct a
*non-constant* function. It cannot: a flat ramp can only build a flat
envelope. The discrepancy is strictly positive (`cex_discrepancy_pos`), so
the function is provably *not* order-convex (`cex_not_orderConvex`). A
dictionary too poor to capture variation will always leave a gap — and the
criterion detects it instantly.

## Why this matters

The payoff of recasting connectivity as tropical Fourier analysis is more
than aesthetic. It hands us a *computable certificate*. Rather than searching
over the exponentially many ways a structure might split, we compute one
number — the discrepancy — and read off whether the relevant rank function
lives in the well-behaved, order-convex world where the Interval Property is
within reach.

The larger program, now scaffolded, is to show that the entire
**connectivity-defect profile** $j \mapsto \kappa(j)$ — how badly the
$j$-th slice fails to be connected — is **discretely concave**: a curve that
bulges upward, never dipping in the middle. Concave integer profiles have
super-level sets that are automatically intervals, which would deliver the
Interval Property in full. The reason to believe it is almost visual:
$\kappa$ is a *minimum of functions each straight-line (affine) in the
spending level $j$*, because each candidate cut contributes a fixed
connectivity value plus a term linear in how the element's units are split.
And the minimum of straight lines is always a concave curve. Connectivity,
it seems, is not a chaotic flicker but the shadow of a single concave arc —
and the language that reveals it is the surprising algebra in which we add by
taking maxima.
