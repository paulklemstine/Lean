# The Mirror at the Heart of Shape

## How a single linear map reveals that two very different-looking landscapes are secretly the same

Imagine you are a cartographer of an abstract world. Instead of mountains and valleys made of rock, your terrain is built from numbers: every point in space is assigned an *altitude* by some function, and your job is to map the regions that lie below a given height. Hikers call these regions "the land below the snow line." Mathematicians call them **sublevel sets** — the collection of all points $x$ where a function $f$ stays at or beneath a chosen threshold $c$:

$$\{\, x \mid f(x) \le c \,\}.$$

These shapes are everywhere in modern science. They are the basins where a physical system settles into low energy. They are the feasible regions an optimizer is allowed to explore. They are the "shape of data" that topologists track as they sweep a threshold from low to high. Understanding their geometry — how many pieces they have, how many holes, how many cavities — is understanding the architecture of the problem itself.

This article is about a quiet, beautiful fact: that for an important family of functions, there is a hidden *mirror*. Each such function $f$ has a partner $f^{\circ}$, its **polarity dual**, and although $f$ and $f^{\circ}$ can look completely different, their sublevel-set landscapes are not merely similar — they are **identical in shape**, related by a single, rigid, linear transformation. Bend nothing, tear nothing: just apply one fixed linear map, and the terrain of $f$ snaps perfectly onto the terrain of $f^{\circ}$.

## The functions that scale

To tell this story properly we need to meet the cast of characters: the **RC functions**, short for *ratio of convex*.

Start with two building blocks, $p$ and $q$. Each is a function that takes a point in space and returns a non-negative number, and each is **positively homogeneous of degree one**. That is a precise way of saying they respect scaling perfectly:

$$p(t\,x) = t\,p(x) \quad\text{and}\quad q(t\,x) = t\,q(x) \qquad \text{for every } t > 0.$$

Double the input, double the output. The most familiar example is a norm — the length of a vector — but there are many others, including all the "gauge" functions that measure how far you have to inflate a convex body before it swallows a point. We also ask that $p$ and $q$ be **convex**, the gentle curvature condition that makes optimization tractable and that guarantees these gauges come from honest convex shapes.

Now form their ratio:

$$f(x) = \frac{p(x)}{q(x)}, \qquad \text{defined wherever } q(x) > 0.$$

This little quotient — the RC function — has a magical property. Because the degree-one scaling of $p$ on top cancels the degree-one scaling of $q$ on the bottom, the ratio doesn't care about scale *at all*:

$$f(t\,x) = \frac{p(t\,x)}{q(t\,x)} = \frac{t\,p(x)}{t\,q(x)} = \frac{p(x)}{q(x)} = f(x).$$

An RC function is **degree-zero homogeneous**: it is constant along every ray shooting out from the origin. Walk straight away from the origin in any fixed direction, and the altitude never changes.

This single observation has a striking geometric consequence. If a point $x$ lies in a sublevel set $\{f \le c\}$, then so does *every* positive multiple of $x$, because they all share the same altitude. The sublevel set is therefore a **cone**: a union of rays. It is not a blob floating somewhere in space; it is a searchlight beam, or a wedge, or a more intricate fan of directions, always anchored at the origin and stretching out to infinity. This conical structure is the geometric fingerprint of every RC function, and it is the stage on which our duality plays out.

## A concrete world you can hold in your hand

Abstraction is easier to trust when you can touch an example, so let us build the smallest interesting one, living in the flat plane of points $(x, y)$.

Take

$$p(x,y) = |x|, \qquad q(x,y) = |x| + |y|,$$

so that

$$f(x,y) = \frac{|x|}{|x| + |y|}.$$

This function answers a natural question: *of the total "city-block" distance you are from the origin, what fraction is horizontal?* On the $x$-axis the answer is $1$ (all horizontal); on the $y$-axis it is $0$ (all vertical); along the diagonals it is exactly $\tfrac12$. Its sublevel set $\{f \le c\}$ is a bow-tie of directions hugging the vertical axis — a genuine cone of rays.

Now meet its mirror image. The polarity dual swaps the roles of the two coordinates:

$$p^{\circ}(x,y) = |y|, \qquad q^{\circ}(x,y) = |x| + |y|, \qquad f^{\circ}(x,y) = \frac{|y|}{|x| + |y|}.$$

This is the *complementary* question: what fraction of your city-block distance is vertical? Its sublevel set is a bow-tie hugging the *horizontal* axis. As pictures, $\{f \le c\}$ and $\{f^{\circ} \le c\}$ point in different directions; they are not literally the same set of points.

And yet there is a single rigid motion that carries one exactly onto the other: the coordinate swap

$$L(x, y) = (y, x).$$

Reflect across the main diagonal and the vertical bow-tie becomes the horizontal one, ray for ray, point for point. The reason is a one-line identity you can check by hand:

$$f^{\circ}\big(L(x,y)\big) = f^{\circ}(y, x) = \frac{|x|}{|y| + |x|} = \frac{|x|}{|x|+|y|} = f(x, y).$$

The mirror $L$ *intertwines* the two functions: applying $f^{\circ}$ after $L$ gives back $f$. This is no accident of this particular example. It is the defining relationship of polarity duality, and it is the seed from which the entire theorem grows.

## The duality identity, and what it forces

Here is the heart of the matter, stated cleanly. We have two finite-dimensional spaces $X$ and $Y$ (think $\mathbb{R}^n$), a function $f$ on $X$, a function $f^{\circ}$ on $Y$, and an invertible linear map $L$ from $X$ to $Y$ — the polarity map — that is continuous along with its inverse. The one hypothesis we assume is the **intertwining identity**:

$$f^{\circ}\big(L(x)\big) = f(x) \qquad \text{for every } x.$$

From this single equation, a cascade of consequences follows. The first is purely set-theoretic, but it is the linchpin.

**The image theorem.** *The polarity map carries the sublevel set of $f$ exactly onto the sublevel set of $f^{\circ}$:*

$$\{\, y \mid f^{\circ}(y) \le c \,\} = L\big(\{\, x \mid f(x) \le c \,\}\big).$$

Why is this true? If $f(x) \le c$, then $f^{\circ}(L(x)) = f(x) \le c$, so $L(x)$ lands in the dual sublevel set — the image is contained in the target. Conversely, take any $y$ with $f^{\circ}(y) \le c$ and pull it back with the inverse map to $x = L^{-1}(y)$; the intertwining identity says $f(x) = f^{\circ}(L(x)) = f^{\circ}(y) \le c$, so $y = L(x)$ is genuinely the image of a point in the source sublevel set. The two sets are equal, not just comparable. This is where the *invertibility* of $L$ does real work: it lets us travel both directions across the mirror.

The image theorem says the two landscapes occupy the same points after the map. The next step upgrades this from a statement about *sets* to a statement about *shape*.

**The homeomorphism.** Because $L$ is continuous, has a continuous inverse, and matches the two sublevel sets point-for-point, it restricts to a **homeomorphism** between them:

$$\{\, x \mid f(x) \le c \,\} \;\cong\; \{\, y \mid f^{\circ}(y) \le c \,\}.$$

A homeomorphism is the topologist's gold standard of sameness. It is a continuous, invertible dictionary between two spaces that never tears and never glues. If two spaces are homeomorphic, they have the same number of connected components, the same loops, the same higher-dimensional holes — every topological feature is shared. The remarkable thing here is *how* the homeomorphism is built: not by some elaborate, wobbly deformation cooked up case by case, but by the **same fixed linear map $L$**, the same rigid mirror, for *every* threshold $c$ at once.

## Same shape, all the way up

Once you possess a homeomorphism, the rest of topology comes along for the ride. Two consequences are worth stating in plain language.

**Same homotopy type.** A homeomorphism is in particular a *homotopy equivalence*, the slightly looser notion of sameness that allows continuous stretching and shrinking. So $\{f \le c\}$ and $\{f^{\circ} \le c\}$ are homotopy equivalent: they can be continuously deformed into one another, and they share every invariant that homotopy theory can see.

**Isomorphic homology, in every dimension.** Homology is the great bookkeeping device of topology — a sequence of algebraic gadgets $H_0, H_1, H_2, \dots$ that count, respectively, the connected pieces of a space, its independent loops, its enclosed voids, and so on into higher dimensions. Homology is a *functor*: it turns continuous maps between spaces into algebraic maps between groups, and it turns homeomorphisms into isomorphisms automatically. Feed our duality homeomorphism into the homology machine and out comes, in every single degree $n$, an isomorphism

$$H_n\big(\{f \le c\}\big) \;\cong\; H_n\big(\{f^{\circ} \le c\}\big).$$

The same holds for *reduced* homology, the variant that ignores the trivial zeroth-degree contribution to focus on genuine holes. The two RC landscapes are not just superficially alike; they are indistinguishable to the most refined topological instruments we have, at every scale of dimension simultaneously.

There is an elegant economy here that deserves to be savored. We did not compute a single homology group. We never had to count the holes of either landscape. We simply observed that one rigid map carries one onto the other, and the deep theorem that *homology respects homeomorphisms* did all the counting for us, for free, forever. The duality is **automatic by functoriality** — a phrase that means, roughly, "the bookkeeping is honest, so equal inputs give equal outputs."

## Why convexity sits in the wings

A subtle and satisfying point lies just beneath the surface. Nowhere in the chain of reasoning above did we actually *use* convexity. The image theorem, the homeomorphism, the homotopy equivalence, the homology isomorphism — every one of them needs only that $L$ is a linear homeomorphism intertwining the two functions. The argument is, in the end, purely formal.

So where did the convexity go? It is in the wings, not on the stage. Convexity is what *guarantees the existence of the mirror in the first place*. The polarity duality of convex bodies — the classical operation that sends a convex shape to its polar dual and back again via the bipolar theorem — is precisely what produces, in finite dimensions, a genuine *linear* map $L$ realizing the duality of the gauges $p$ and $q$. Convexity earns us the map; once we hold the map, topology finishes the job. Separating these two roles — the analytic role of convexity and the topological role of linearity — is itself a clarifying insight, because it tells us exactly which hypothesis is responsible for which conclusion.

## A bridge to Morse theory and the shape of change

Why should anyone outside of pure topology care that two abstract landscapes share their holes? Because sublevel sets are how we watch *change* unfold.

Sweep the threshold $c$ from low to high and the sublevel set $\{f \le c\}$ grows from nothing, filling out the space. The moments when its shape suddenly changes — when a new component is born, when a loop closes, when a void seals shut — are the **critical values** of $f$, the heights of its passes and peaks. This is the worldview of Morse theory: the topology of a space is assembled, one critical point at a time, from the changing topology of its sublevel sets. It is also the worldview of *persistent homology*, the engine behind modern topological data analysis, which records exactly when each hole is born and when it dies as the threshold rises.

Our duality says that $f$ and its mirror $f^{\circ}$ undergo *the same sequence of changes*. Because the very same linear map $L$ relates their sublevel sets at *every* level $c$ simultaneously, it relates their entire histories of growth, not just isolated snapshots. The births and deaths of holes in the landscape of $f$ correspond, one for one, to the births and deaths in the landscape of $f^{\circ}$. The two functions are Morse-theoretically twins. A hard topological question about $f$ can be answered by studying whichever of the pair — $f$ or its dual — happens to be simpler.

This is the practical promise of duality across mathematics: it gives you two windows onto one truth, and lets you look through whichever is clearer.

## The view from here

What began as a quotient of two humble scaling functions has led us to a sturdy and general principle. Whenever a duality between functions can be realized by a rigid linear mirror that intertwines them, their sublevel landscapes are topologically identical, in every dimension and at every threshold at once — and the proof asks for nothing more than the honesty of the homology bookkeeping.

The horizon holds inviting questions. Each conical sublevel set should collapse, like a searchlight beam retracting to its bright spot on a far wall, onto its "link" — the slice it cuts from the unit sphere — reducing a calculation in the whole space to one on a sphere. The linear mirror, which here we *assumed*, ought to be *forced*: convex homogeneity may leave no other possibility, making the linear polarity map not just one valid choice but the canonical one. And the level-by-level twinning of $f$ and $f^{\circ}$ should mature into a full Morse-theoretic equivalence, synchronizing their critical points and their persistence diagrams.

But the central image is already in focus, and it is a clean one. Two landscapes that look nothing alike. One rigid mirror between them. And, reflected in that mirror, the discovery that they were the same shape all along.
