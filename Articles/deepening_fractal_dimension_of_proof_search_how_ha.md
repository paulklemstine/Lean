# The Geometry of Finding a Successful Path

## Why a search tree can have a dimension

Imagine entering a maze that changes its architecture at every junction. At the first turn there may be two doors, at the second five, at the third only one, and at the fourth four again. Most doors lead eventually to dead ends. A smaller set can still be extended toward a destination.

This is a useful picture for any rule-governed search: solving a puzzle, planning a route, debugging a program, exploring a game tree, or assembling a chain of deductions. At each stage there is an **ambient branching number**, the number of moves that could be tried, and a **successful branching number**, the number of those moves that remain compatible with eventual success. The two numbers can vary from level to level.

How large is the surviving part of such a search space? Merely counting successful paths is not enough. Ten survivors out of twenty possibilities mean something different from ten survivors out of a million. Nor is ordinary depth enough: one level with a thousand choices contains far more combinatorial volume than one level with two choices.

A natural answer comes from fractal geometry and information theory. The successful set has a **relative entropy dimension**: the logarithmic volume of successful choices divided by the logarithmic volume of all choices. This number behaves like a finite-scale fractal dimension. It lies between $0$ and $1$ under genuine pruning, increases when more successful choices are retained, obeys an exact power law, and combines across search phases by an information-weighted average.

The last point is the central surprise. Two phases of equal depth need not contribute equally. The phase containing more ambient information deserves more weight.

## From branching to information

Consider a finite branching profile

$$
a=(a_0,a_1,\ldots,a_{n-1}),
$$

where $a_i$ is the number of available choices at level $i$. Choices made at successive levels combine independently in the profile model, so the total number of terminal paths is

$$
P(a)=\prod_{i=0}^{n-1} a_i.
$$

The corresponding **logarithmic volume** is

$$
L(a)=\sum_{i=0}^{n-1}\log a_i.
$$

Provided every $a_i\ge 1$, the ordinary product rule for logarithms gives the Path-Count Identity:

$$
L(a)=\log P(a).
$$

This translation from products to sums is the engine of the theory. Path counts multiply across levels, but information volumes add. Additive quantities are much easier to compare and compose.

Now let

$$
b=(b_0,\ldots,b_{n-1})
$$

be the ambient profile and

$$
s=(s_0,\ldots,s_{n-1})
$$

be the successful profile. The intended pruning condition is $1\le s_i\le b_i$ at every level. When $L(b)>0$, define the **profile dimension** by

$$
D(b,s)=\frac{L(s)}{L(b)}
       =\frac{\sum_i\log s_i}{\sum_i\log b_i}.
$$

This is not a fraction of levels. It is a fraction of information. A level with branching $100$ contributes $\log 100$ units to the denominator, while a binary level contributes only $\log 2$.

## The exact scaling law

Classical fractal dimensions are characterized by power laws: the number of small pieces scales like a power of the number of ambient pieces. The same phenomenon appears here without approximation.

The **Entropy Power Law** states that if all entries of $b$ and $s$ are positive integers and $L(b)\ne 0$, then

$$
P(s)=P(b)^{D(b,s)}.
$$

The proof is a one-line idea with substantial meaning. Take logarithms. By the Path-Count Identity,

$$
\log P(s)=L(s)=D(b,s)L(b)=D(b,s)\log P(b).
$$

Exponentiating recovers the result.

Suppose, for example, that

$$
b=(2,3,5,2),\qquad s=(1,2,2,2).
$$

Then $P(b)=60$ and $P(s)=8$, so

$$
D(b,s)=\frac{\log 8}{\log 60}\approx 0.508.
$$

The number $0.508$ says that the surviving search space occupies roughly one-half of the ambient logarithmic growth scale. It does not say that half the paths survive: only $8/60$ do. Dimension records an exponent, not a percentage.

## Why the dimension stays between zero and one

Under coordinatewise pruning, each successful branching number obeys $1\le s_i\le b_i$. Because the logarithm is increasing,

$$
0\le \log s_i\le \log b_i.
$$

Summing over levels yields

$$
0\le L(s)\le L(b).
$$

If the ambient logarithmic volume is positive, division gives the **Unit-Interval Theorem**:

$$
0\le D(b,s)\le 1.
$$

The endpoints have clear meanings. Dimension $1$ means that successful branching preserves all ambient logarithmic volume. Dimension $0$ means that the successful profile has product $1$, so only one continuation survives at every effective scale.

There is also a **Monotonicity Theorem**. If two successful profiles $s$ and $t$ have the same length, satisfy $1\le s_i\le t_i$ for every $i$, and are measured against the same ambient profile $b$ with $L(b)>0$, then

$$
D(b,s)\le D(b,t).
$$

Keeping more viable choices cannot lower dimension. Notice how little this result assumes: no stationarity, no constant branching, and no probabilistic model.

## The right way to combine search phases

Real searches have phases. Early steps may involve selecting a broad strategy; middle steps may resolve technical constraints; late steps may become nearly deterministic. Suppose phase one has ambient and successful profiles $(b^{(1)},s^{(1)})$, while phase two has $(b^{(2)},s^{(2)})$. Joining the phases means concatenating their profiles.

Logarithmic volume is additive under concatenation:

$$
L\!\left(b^{(1)}\mathbin{\|}b^{(2)}\right)
=L\!\left(b^{(1)}\right)+L\!\left(b^{(2)}\right),
$$

and similarly for successful profiles. Therefore the **Multiscale Composition Theorem** states, whenever the relevant denominators are nonzero,

$$
D\!\left(b^{(1)}\mathbin{\|}b^{(2)},
         s^{(1)}\mathbin{\|}s^{(2)}\right)
=
\frac{L(b^{(1)})D(b^{(1)},s^{(1)})
+L(b^{(2)})D(b^{(2)},s^{(2)})}
{L(b^{(1)})+L(b^{(2)})}.
$$

Thus the combined dimension is a weighted mean, but the weights are not the numbers of levels. They are the ambient logarithmic volumes.

Consider two one-level phases. In the first, $2$ of $2$ choices survive, so its dimension is $1$. In the second, $2$ of $16$ choices survive, so its dimension is $\log 2/\log 16=1/4$. A depth-weighted average would give $5/8$. That is wrong. The first phase carries ambient volume $\log 2$ and the second carries $\log 16=4\log 2$, so the correct combined value is

$$
\frac{(\log 2)(1)+(4\log 2)(1/4)}{5\log 2}=\frac{2}{5}.
$$

Direct calculation confirms it: the concatenated ambient count is $32$, the successful count is $4$, and $\log 4/\log 32=2/5$.

The example exposes a common error in multiscale reasoning. Equal duration is not equal informational importance.

## Repetition and scale invariance

If a profile $a$ is repeated $k$ times, its path count becomes $P(a)^k$ and its logarithmic volume becomes $kL(a)$. Consequently, repeating both an ambient profile and its successful profile preserves their dimension. The **Repetition Invariance Theorem** says that for every positive integer $k$,

$$
D(b^{\| k},s^{\| k})=D(b,s),
$$

where $b^{\| k}$ means $k$ consecutive copies of $b$.

This is the hallmark of a dimensional quantity. Magnifying the same local geometry across more blocks increases both information volumes by the same factor, leaving their ratio unchanged.

A familiar special case appears in periodic binary search. Suppose every ambient level offers two branches, while only selected levels preserve both branches and the remaining levels force a single continuation. Over one period of $m$ levels, if $r$ levels retain two choices, then

$$
L(b)=m\log 2,\qquad L(s)=r\log 2,
$$

so the dimension is

$$
D=\frac{r}{m}.
$$

The fraction of genuinely branching levels is therefore recovered exactly—but only because all ambient levels carry equal information. The general theory explains both why this simple fraction works in the uniform binary case and why it fails for unequal branching.

## What the number does—and does not—measure

Relative entropy dimension measures the abundance of extendable paths. It can compare pruning regimes, identify information-heavy bottlenecks, and summarize nonstationary growth in a scale-stable number. Similar profiles arise in combinatorial planning, symbolic dynamics, constrained coding, decision trees, and hierarchical configuration spaces.

But dimension is not runtime. Two search trees can have identical numbers of successful prefixes at every depth while presenting those prefixes in radically different orders. A depth-first policy might encounter success immediately in one ordering and only after a huge detour in another. Geometry measures how much success exists; a traversal policy determines when it is found.

The distinction suggests a practical diagnostic. If a phase has low local dimension and large ambient logarithmic volume, it is an information-heavy bottleneck: many options exist, but few remain viable. Improving guidance there may matter more than simplifying many nearly deterministic levels. Conversely, a low-dimensional phase with tiny ambient volume may have little influence on the whole search.

## A map for more complicated worlds

Finite profiles are the cleanest setting because every identity is exact. Yet the formulas point beyond it. If path counts are merely submultiplicative, logarithmic volumes become subadditive and limiting growth rates should replace finite sums. Random stationary branching suggests ratios of expected logarithms. Finite-state constraints replace scalar branching products with matrix products and spectral radii. Sparse perturbations raise questions about stability.

Across these extensions, one principle is likely to remain: normalize successful logarithmic growth by ambient logarithmic growth.

The geometry of search is therefore not governed simply by how many steps a problem takes or how many choices appear at an average step. It is governed by where combinatorial information accumulates and how much of that information survives. Products count paths. Logarithms reveal volume. Their ratio turns a changing maze into a dimension.
That principle also gives a disciplined way to compare systems. Rather than asking only whether one search has more branches or more surviving paths, one asks how much ambient information each phase creates, how much successful information remains, and how those quantities compose. The resulting dimension is simple enough to calculate, but rich enough to expose the architecture hidden behind a raw leaf count.
