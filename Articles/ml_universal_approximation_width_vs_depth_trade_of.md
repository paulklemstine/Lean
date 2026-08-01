# Why Depth Multiplies the Expressive Power of ReLU Networks

A neural network is often pictured as a web of artificial neurons, but for a mathematician it can also be viewed as a machine for folding space. Each rectified linear unit, or ReLU, applies the simple rule

$$
\operatorname{ReLU}(x)=\max\{x,0\}.
$$

Nothing about this formula looks dramatic. To the left of zero it is flat; to the right it is a straight line. Yet when many such units are combined and, crucially, composed across layers, they can divide an input space into a rapidly growing collection of regions. On each region the network behaves like an affine function. The number of available regions is therefore a useful measure of how much geometric detail an architecture can potentially express.

This viewpoint makes the trade-off between width and depth unusually transparent. Width supplies alternatives side by side. Depth repeatedly recombines and refines what earlier layers have made. In a simple region-capacity model, a network of width $w$ and depth $L$ is assigned the capacity

$$
C(w,L)=(w+1)^L.
$$

The formula is not, by itself, a universal approximation theorem or an exact count of regions for every possible network. It is a deliberately clean combinatorial model of available piecewise-affine cells. Within that model, however, the comparison between wide and deep architectures is exact: width changes the base of a power, while depth changes its exponent.

## The smallest useful ReLU constructions

Before counting regions, it helps to see how elementary ReLU pieces cooperate. Two ReLU units recover the identity function exactly:

$$
\operatorname{ReLU}(x)-\operatorname{ReLU}(-x)=x.
$$

For $x\ge 0$, the first term equals $x$ and the second vanishes. For $x\le 0$, the first vanishes and the second equals $-x$, so subtracting it again yields $x$. Thus even though one ReLU discards the negative half-line, two oppositely oriented units preserve the entire signal.

Three shifted ReLU terms create a tent:

$$
T(x)=\operatorname{ReLU}(x)-2\operatorname{ReLU}(x-1)+\operatorname{ReLU}(x-2).
$$

This function passes through the key values

$$
T(0)=0,\qquad T(1)=1,\qquad T(2)=0.
$$

Indeed, it rises linearly from zero to one on $[0,1]$, falls linearly from one to zero on $[1,2]$, and is zero outside $[0,2]$. The tent is a miniature example of the geometry behind depth. Define its iterates by $T^{\circ 0}(x)=x$ and

$$
T^{\circ(L+1)}(x)=T\bigl(T^{\circ L}(x)\bigr).
$$

Each extra composition feeds an already folded signal through another fold. This recurring motif is central to stronger depth-separation results, because repeated composition can generate oscillatory structure economically. Here it also provides an intuitive companion to the capacity formula: layering means composition, not merely addition.

A scalar network with one hidden layer and $w$ neurons has the form

$$
F(x)=b_0+\sum_{i=1}^{w}a_i\operatorname{ReLU}(c_i x+b_i).
$$

Every such function is continuous. Each affine map $c_i x+b_i$ is continuous, ReLU is continuous, and finite sums and products preserve continuity. The pieces may meet at corners, but they do not tear apart. This is why ReLU networks naturally approximate continuous shapes by connected piecewise-linear patches.

## A capacity law with exact consequences

The model $C(w,L)=(w+1)^L$ immediately gives two monotonicity principles. If $w_1\le w_2$, then

$$
C(w_1,L)\le C(w_2,L),
$$

and if $L_1\le L_2$, then

$$
C(w,L_1)\le C(w,L_2).
$$

More neurons do not reduce capacity, and more layers do not reduce it either. The second statement uses the fact that the base $w+1$ is positive. These observations sound obvious, but their exact form lets us turn architectural comparisons into arithmetic.

Suppose an approximation task demands $m^n$ cells, where $n$ may be interpreted as an input dimension and $m$ as a resolution parameter along each coordinate. A regular grid with $m$ subdivisions in each of $n$ directions has precisely this scaling. At depth $n$, width $m-1$ meets the demand exactly:

$$
C(m-1,n)=m^n.
$$

When $m>0$ and $n>0$, this width is also minimal in the following sense: if

$$
m^n\le C(w,n),
$$

then necessarily $m-1\le w$. The proof is a one-line comparison of bases. If $w+1<m$, raising both positive integers to the positive power $n$ would give $(w+1)^n<m^n$, contradicting the assumed capacity.

This exact threshold can be translated into an error-resolution story. Define the cell demand

$$
Q(n,m)=m^n.
$$

If the error scale is encoded as $\varepsilon=1/m^n$, then $m=\varepsilon^{-1/n}$. The required shallow width $m-1$ therefore exhibits the familiar inverse-root scaling

$$
w\asymp \varepsilon^{-1/n}.
$$

This statement is about the encoded cell demand, not about every continuous function. Continuity alone does not specify how rapidly a function varies, so it cannot supply a universal function-independent rate. A Lipschitz constant, modulus of continuity, or similar regularity information is needed to connect a resolution parameter to actual approximation error.

The same demand looks very different when width is fixed and depth is allowed to grow. For an integer base $b\ge 2$, let $\lceil\log_b q\rceil$ denote the least nonnegative integer $d$ for which $q\le b^d$. Then any positive width $w$ satisfies

$$
q\le C\bigl(w,\lceil\log_{w+1}q\rceil\bigr).
$$

In particular, choosing the dimension-dependent width $w=n+4$ gives

$$
Q(n,m)\le C\bigl(n+4,\lceil\log_{n+5}Q(n,m)\rceil\bigr).
$$

Thus a fixed width of $n+4$ reaches any finite cell demand at a ceiling-logarithmic depth. Since $Q(n,m)=m^n$, the required depth is

$$
\left\lceil\log_{n+5}(m^n)\right\rceil.
$$

Under the encoding $\varepsilon=1/m^n$, this is proportional to $\log(1/\varepsilon)$. The contrast is the heart of the story: one architecture pays through an expanding width of order $\varepsilon^{-1/n}$, while another holds width fixed and pays through logarithmic depth.

## One more layer has a measurable price

Depth does more than eventually reach large demands. At every positive width it strictly increases capacity:

$$
C(w,L)<C(w,L+1)\qquad\text{for }w>0.
$$

The reason is multiplication. The new layer multiplies the old capacity by $w+1$, a factor of at least two.

Now ask a depth-one competitor of width $v$ to match a width-$w$, depth-$(L+1)$ architecture. The matching condition is

$$
C(w,L+1)\le C(v,1).
$$

Because $C(v,1)=v+1$, this forces

$$
v\ge (w+1)^{L+1}-1.
$$

The bound is sharp: choosing exactly

$$
v=(w+1)^{L+1}-1
$$

makes the two capacities equal. In this model, flattening a deep architecture into one layer therefore costs exponentially many neurons as $L$ grows.

There is also a comparison between neighboring depths. If a depth-$L$ network of width $v$ matches the capacity of a positive-width network with width $w$ and depth $L+1$, then it must satisfy

$$
w<v.
$$

Keeping the same width, or making it smaller, cannot compensate for the missing layer. Monotonicity in width would cap the competitor at $C(w,L)$, but strict growth in depth places the target above that value.

## What the capacity model says—and what it does not

The arithmetic establishes a precise architectural principle: repeated composition converts modest width into exponential combinatorial capacity. It also gives exact resource thresholds for a prescribed number of cells. These conclusions are valuable for design. If a task naturally demands a hierarchy of refinements, depth can represent that hierarchy without placing every alternative in one enormous layer. This is relevant wherever piecewise-linear models appear: image partitions, control laws, surrogate models for physical systems, and decision surfaces in classification.

But capacity is opportunity, not a guarantee. A network with enough potential cells may fail to place them where a particular function needs them. Nor does a cell count alone prove that every continuous function on $[-1,1]^n$ is approximated to a given tolerance by a prescribed architecture. The rigorous bridge to such a claim must construct the network, control its uniform error, and relate the function’s regularity to the necessary spatial resolution.

That distinction clarifies the research frontier. One direction is constructive: turn a fine partition of $[-1,1]^n$ into a ReLU network whose hidden layers never exceed width $n+4$. Another is quantitative: for $K$-Lipschitz functions, derive a shallow width bound proportional to $(K/\varepsilon)^n$. A third is adversarial: prove that mere continuity admits no common rate by building functions whose fine-scale behavior defeats every proposed width schedule. Finally, the tent map suggests a route from abstract capacity to realizable separation—count its affine intervals under iteration and prove that shallower networks cannot reproduce so many oscillations without exponential size.

There is a useful practical analogy. Imagine drawing a complicated landscape with straight-edged tiles. A wider workshop hires more tile-makers for a single shift; a deeper workshop lets the product of one shift become the raw material for the next. The first strategy increases what can be laid down in parallel. The second creates a production chain, so each stage can transform all distinctions made before it. The capacity law measures precisely this compounding effect.

That perspective also warns against treating parameter count as the only architectural statistic. Two networks with comparable numbers of neurons can organize them differently and therefore have very different model capacities. Training cost, numerical stability, and data efficiency still matter, and the largest-capacity architecture is not automatically the best predictor. Capacity says what an architecture could express, not what an optimization procedure will find from finite, noisy observations. Generalization remains a separate statistical question. Yet when representational scarcity is the bottleneck, the arrangement of neurons across layers can matter as much as their total number.

The central lesson survives all these refinements. Width and depth are not interchangeable currencies. Width buys parallel pieces; depth compounds structure. In the simple law $C(w,L)=(w+1)^L$, that distinction becomes visible at a glance—and exact enough to calculate the price of flattening a hierarchy.