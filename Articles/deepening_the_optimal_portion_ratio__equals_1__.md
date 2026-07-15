# The Cake Constant Hidden in a Three-State Rhythm

*A circular cutting problem, an unusual cubic number, and a tiny matrix turn out to share one exact scale.*

Imagine a perfectly round cake on a turntable. Each radial cut adds one more slice, but the portions that matter are not individual slices. A portion consists of two neighboring slices. At every stage, compare the largest such two-slice portion with the smallest. The closer this ratio is to $1$, the fairer the configuration looks.

This apparently domestic question quickly becomes a problem about dynamics. A cut that improves one local imbalance can create another elsewhere. The slices live on a circle, so the first and last are neighbors. And an infinite cutting schedule must remain controlled not merely at its final stage—there is no final stage—but after every cut.

A distinguished candidate for the best possible worst-case ratio is

$$
\mu=1+\rho,
$$

where $\rho$ is the unique number between $0$ and $1$ satisfying

$$
\rho^3+\rho^2=1.
$$

Numerically,

$$
\rho\approx0.7548776662,
\qquad
\mu\approx1.7548776662.
$$

The remarkable point is not just that this constant lies between $1$ and $2$. Its algebra reveals that the cake problem is tuned to the same scale as the Padovan recurrence, a cousin of the Fibonacci sequence, and to the growth rate of a three-state substitution system.

## One root, and only one

Before following that bridge, we need to know that $\rho$ is unambiguous. Consider

$$
f(x)=x^3+x^2.
$$

On the nonnegative real axis, $f$ is strictly increasing. Indeed, if $0\leq x<y$, then both powers increase, and at least one increases strictly, so $x^3+x^2<y^3+y^2$. Moreover,

$$
f(0)=0,
\qquad
f(1)=2.
$$

Continuity therefore gives a solution of $f(x)=1$ between $0$ and $1$, while strict increase says there cannot be two. This proves the **Existence and Uniqueness Theorem for the Cake Scale**: there is exactly one $\rho\in(0,1)$ for which $\rho^3+\rho^2=1$.

That elementary theorem is the hinge of the story. Once the root is fixed, every constant that follows is fixed as well.

## Turn the scale upside down

Now take the reciprocal

$$
p=\frac1\rho.
$$

Because $0<\rho<1$, we immediately know $p>1$. Divide the defining equation by $\rho^3$:

$$
1+\frac1\rho=\frac1{\rho^3}.
$$

In terms of $p$, this becomes

$$
p^3=p+1.
$$

The unique positive real number satisfying this equation is called the **plastic number**. It is approximately

$$
p\approx1.3247179572.
$$

The name “plastic” evokes a universal proportion, in the spirit of the golden ratio, though the two numbers obey different laws. The golden ratio satisfies a quadratic equation and governs a two-step recurrence. The plastic number satisfies a cubic equation and naturally governs a three-step rhythm.

The reciprocal substitution does more than rename the root. Divide $\rho^3+\rho^2=1$ by $\rho^2$ to obtain

$$
\rho+1=\frac1{\rho^2}.
$$

Therefore

$$
\boxed{\mu=1+\rho=p^2.}
$$

This is the **Cake–Plastic Identity**: the proposed two-slice portion constant is exactly the square of the plastic number. Numerically, $p^2\approx1.7548776662$, matching $1+\rho$.

This identity changes how one sees the constant. The expression $1+\rho$ looks like a local additive correction: one whole unit plus a fractional scale. The expression $p^2$ looks like two generations of multiplicative growth. They are exactly the same quantity.

## A recurrence concealed in a matrix

Where does $p$ naturally act as a growth factor? Consider triples of numbers transformed by

$$
(x,y,z)\longmapsto(y,z,x+y).
$$

This operation shifts the second and third entries forward, then creates a new third entry by adding the first two. Repeating it generates the Padovan recurrence: each new term is the sum of terms two and three places behind. In matrix form, the transformation is

$$
A=
\begin{pmatrix}
0&1&0\\
0&0&1\\
1&1&0
\end{pmatrix}.
$$

Now examine the positive vector

$$
v=
\begin{pmatrix}
1\\p\\p^2
\end{pmatrix}.
$$

Applying $A$ gives

$$
Av=
\begin{pmatrix}
p\\p^2\\1+p
\end{pmatrix}.
$$

But the plastic equation says $1+p=p^3$. Hence

$$
Av=
\begin{pmatrix}
p\\p^2\\p^3
\end{pmatrix}
=p
\begin{pmatrix}
1\\p\\p^2
\end{pmatrix}
=pv.
$$

This proves the **Positive Eigenvector Theorem**: $p$ is a positive eigenvalue of the Padovan transition matrix, with strictly positive eigenvector $(1,p,p^2)$. Every coordinate is positive because $p>0$.

An eigenvector is a shape that a transformation preserves up to scale. The matrix changes the size of $v$ by a factor of $p$ but does not change its proportions. The triple

$$
1:p:p^2
$$

is therefore a self-reproducing pattern for the three-state update. After one step, the pattern is the same, only enlarged by $p$.

This gives the central bridge: the cake ratio is the square of a positive matrix growth factor. A constant introduced through neighboring portions on a circle can be read as two iterations of the intrinsic scale of a recurrence.

## Why positivity matters

The vector $(1,p,p^2)$ is not merely algebraically convenient. Its strict positivity makes it meaningful as a vector of lengths, weights, frequencies, or proportions. Negative coordinates could solve an eigenvalue equation while being useless for physical subdivision. Positive coordinates can describe actual pieces.

Suppose three kinds of intervals, tiles, tasks, or symbolic states are updated by the rule encoded in $A$. If their relative quantities begin in the proportion $1:p:p^2$, the next update preserves that proportion. This is precisely the kind of self-similarity one seeks in an indefinitely repeated cutting strategy: a finite collection of local states whose global scale renews itself.

The result does not by itself construct the complete infinite cake-cutting schedule, nor does it prove that no schedule can beat $p^2$. Those remain separate geometric and combinatorial tasks. What it does establish is an exact algebraic skeleton for such a strategy. Any successful construction based on the three-state rhythm has a canonical scale available, and that scale is not approximate or accidental.

## Sharp numerical bounds

The constants also satisfy clean bounds:

$$
1<p<2,
\qquad
1<\mu<2.
$$

The first lower bound follows from $p=1/\rho$ and $0<\rho<1$. For the upper bound, first note that $\rho>1/2$. If instead $0<\rho\leq1/2$, then

$$
\rho^3+\rho^2\leq\frac18+\frac14=\frac38<1,
$$

contradicting the defining equation. Thus $p=1/\rho<2$. The bound for $\mu$ is even more direct: since $0<\rho<1$,

$$
1<1+\rho<2.
$$

The ratio therefore inhabits a narrow and intuitively sensible zone. It exceeds perfect equality, but it remains below a factor of two.

## From cakes to populations and schedules

The same mathematics appears whenever a system remembers three states. In population models, a triple might count three age classes; the matrix update shifts two classes and forms the newest class from two earlier contributions. In scheduling, the entries might represent three queues whose work is rotated and recombined. In symbolic dynamics, they can count three kinds of blocks under repeated substitution.

In all these interpretations, the positive eigenvector describes a stable composition and $p$ describes long-run one-step expansion. The square $p^2$ measures two-step expansion. The cake constant’s identity with $p^2$ suggests that balancing adjacent pairs is naturally a two-level question: a portion contains two neighboring slices, while the recurrence advances through three interlocked states.

This is not a claim that every application is the same problem. Rather, it is a precise statement that they share an algebraic engine. Whenever $p^3=p+1$ appears, the relation closes a three-stage update. Whenever $p^2=1+1/p$ appears, additive and multiplicative descriptions meet.

## A pocket-sized numerical experiment

The bridge can be explored with an ordinary calculator. Begin with $x=0.75$. Then $x^3+x^2\approx0.9844$, slightly below $1$. Try $x=0.76$, and the value rises to about $1.0166$. The desired $\rho$ must lie between them. Repeatedly halving the interval quickly pins it down near $0.7548776662$.

Now invert that decimal. The result is approximately $1.3247179572$, and cubing it gives approximately $2.3247179572$—exactly one more than the original number, to the displayed precision. Squaring it gives approximately $1.7548776662$, the same decimal obtained by adding $1$ to $\rho$.

The matrix check is just as tangible. Start with the triple

$$
(1,1.3247179572,1.7548776662).
$$

The update $(x,y,z)\mapsto(y,z,x+y)$ turns it into approximately

$$
(1.3247179572,1.7548776662,2.3247179572).
$$

Multiplying every original coordinate by $1.3247179572$ produces that same triple. The decimal exercise does not replace the exact argument, but it makes all three faces of the constant—root, square, and growth factor—visible at once. It also gives readers a direct way to reproduce the central phenomenon without specialized software.

## The larger lesson

Mathematical constants often acquire meaning by traveling. A root begins as the answer to one equation, then reappears as a growth rate, an eigenvalue, a geometric proportion, or a threshold. Each new role explains something the original formula hides.

Here the journey is especially compact. Start with the unique $
\rho\in(0,1)$ satisfying $\rho^3+\rho^2=1$. Turn it upside down to obtain the plastic number $p=1/\rho$, characterized by $p^3=p+1$. Square it to obtain the candidate cake ratio:

$$
1+\rho=p^2.
$$

Then place $1$, $p$, and $p^2$ in a vector. The Padovan matrix reproduces that vector at scale $p$:

$$
A(1,p,p^2)^{\mathsf T}=p(1,p,p^2)^{\mathsf T}.
$$

Those equations are the entire bridge. They connect local fairness on a circle, cubic algebra, recurrence growth, and positive spectral geometry.

The next challenge is to build the roadway on both sides: an explicit infinite cutting strategy that keeps every stage below the ratio $p^2$, and a universal obstruction showing that every strategy must eventually reach at least $p^2$. If both are achieved, the bridge developed here will not merely interpret the constant. It will explain why the optimum has exactly this value.
