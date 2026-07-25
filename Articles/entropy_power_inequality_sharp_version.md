# When Entropy Draws a Right Triangle

## A geometric language for the sharp entropy-power boundary

Randomness is usually described with words that sound intangible: uncertainty, disorder, information. Geometry, by contrast, feels concrete. We can draw a length, square it, and watch two perpendicular contributions combine by the Pythagorean theorem. Yet a particular normalization of entropy reveals that these are not separate worlds. At the sharp boundary of the entropy power inequality, uncertainty behaves like the squared radius of a Euclidean object.

That observation is the organizing idea of this article. It gives a clean translation among three quantities: differential entropy, entropy power, and entropy radius. It identifies the exact logarithmic threshold at which entropy powers add. It explains why isotropic Gaussian random vectors attain equality in every positive dimension. And it provides an exact stability law: raising the entropy above the sharp threshold by a known amount creates a precisely calculable surplus in entropy power.

The point is not merely a change of notation. The radius picture makes the information-theoretic inequality look like a right triangle, places Gaussian convolution in a familiar geometry, and exposes a close analogy with the radius formulation of the Brunn--Minkowski inequality.

## From entropy to an effective size

Let $h$ be a real number representing differential entropy in dimension $n$, where $n$ is a positive integer. Define the entropy power by

$$
N_n(h)=\frac{\exp(2h/n)}{2\pi e}.
$$

The normalization is chosen so that a centered isotropic Gaussian with covariance $vI_n$ has entropy power exactly $v$. Thus entropy power translates an additive logarithmic quantity into a variance-like scale.

Now define the entropy radius

$$
r_n(h)=\frac{\exp(h/n)}{\sqrt{2\pi e}}.
$$

The central identity is immediate but decisive:

$$
N_n(h)=r_n(h)^2.
$$

Indeed, squaring the numerator doubles the exponent, while squaring the denominator produces $2\pi e$. Entropy power is literally the square of entropy radius.

This lets us hear the entropy power inequality in geometric language. For entropies $h_X$, $h_Y$, and $h_S$, the inequality

$$
N_n(h_X)+N_n(h_Y)\le N_n(h_S)
$$

is equivalent to

$$
r_n(h_X)^2+r_n(h_Y)^2\le r_n(h_S)^2.
$$

So the output radius is at least the Euclidean length obtained by placing the two input radii on perpendicular axes. In symbols,

$$
r_n(h_S)\ge \sqrt{r_n(h_X)^2+r_n(h_Y)^2}.
$$

This is the Pythagorean radius-growth law. It does not by itself establish the probabilistic entropy power inequality for arbitrary random vectors; that deeper statement also requires hypotheses such as independence and analytic facts about convolution. What it does establish is an exact equivalence once the three entropies are given: the information inequality and the geometric radius inequality are the same numerical assertion.

## The sharp boundary

Because the exponential function is strictly increasing, entropy power increases strictly with entropy in every positive dimension. This means there is one and only one output entropy at which equality holds.

Solving

$$
N_n(h_S)=N_n(h_X)+N_n(h_Y)
$$

for $h_S$ gives the sharp entropy boundary

$$
B_n(h_X,h_Y)=\frac n2\log\!\left(\exp(2h_X/n)+\exp(2h_Y/n)\right).
$$

Two exact statements follow.

**Sharp boundary theorem.** For every positive integer $n$ and all real $h_X,h_Y,h_S$,

$$
N_n(h_X)+N_n(h_Y)\le N_n(h_S)
$$

if and only if

$$
B_n(h_X,h_Y)\le h_S.
$$

Moreover, equality of entropy powers holds if and only if

$$
h_S=B_n(h_X,h_Y).
$$

The proof is transparent. Substituting the definition of $B_n$ into $N_n$ cancels the logarithm and exponential, yielding the sum of the two input powers. Strict monotonicity then converts comparison of powers into comparison of entropies and makes the equality point unique.

The boundary is a scaled log-sum-exp function, a smooth version of a maximum. If one input entropy greatly exceeds the other, the boundary lies only slightly above the larger entropy. If the inputs are equal, say $h_X=h_Y=h$, then

$$
B_n(h,h)=h+\frac n2\log 2.
$$

That extra term is exactly what is needed to double entropy power.

## Why Gaussians fit perfectly

Consider a centered isotropic Gaussian random vector in $n$ dimensions with covariance $vI_n$, where $v>0$. Its differential entropy is

$$
h_G(n,v)=\frac n2\log(2\pi e v).
$$

Substitution into the entropy-power formula gives

$$
N_n(h_G(n,v))=v,
$$

and consequently

$$
r_n(h_G(n,v))=\sqrt v.
$$

Thus the entropy radius of an isotropic Gaussian is its ordinary standard deviation. The abstract information radius has become a familiar statistical length.

Now take independent centered isotropic Gaussians with variances $v_X$ and $v_Y$. Their sum is again centered and isotropic, with variance $v_X+v_Y$. Therefore

$$
N_n(h_G(n,v_X+v_Y))
=N_n(h_G(n,v_X))+N_n(h_G(n,v_Y)),
$$

for every positive dimension $n$ and all $v_X,v_Y>0$. In radius language,

$$
r_n(h_G(n,v_X+v_Y))^2
=r_n(h_G(n,v_X))^2+r_n(h_G(n,v_Y))^2.
$$

This is not just reminiscent of the Pythagorean theorem; after normalization, it is exactly the same algebra. Independent Gaussian noise sources add their variances, while their standard deviations combine as perpendicular lengths.

A concrete example makes the picture vivid. Let $v_X=1$ and $v_Y=4$. The input entropy radii are $1$ and $2$, while the output radius is $\sqrt5$. The three radii can be drawn as the sides of a right triangle. The calculation works in dimension $1$, dimension $10$, or dimension $10{,}000$, because the normalization absorbs the dimension into the entropy scale.

## Measuring distance above the boundary

A sharp inequality should say more than where equality occurs. It should quantify what happens away from equality. Define the entropy-power deficit, or slack, by

$$
D_n(h_X,h_Y,h_S)
=N_n(h_S)-N_n(h_X)-N_n(h_Y).
$$

The entropy power inequality is exactly the statement $D_n\ge0$. Suppose the output entropy lies an amount $\delta$ above the sharp boundary:

$$
h_S=B_n(h_X,h_Y)+\delta.
$$

Then the exponential definition gives an exact multiplicative law:

$$
N_n(h_S)
=\exp(2\delta/n)\bigl(N_n(h_X)+N_n(h_Y)\bigr).
$$

Subtracting the boundary value yields the exact additive stability identity

$$
D_n(h_X,h_Y,h_S)
=\bigl(\exp(2\delta/n)-1\bigr)
\bigl(N_n(h_X)+N_n(h_Y)\bigr).
$$

This formula contains no approximation. If $\delta>0$, then $\exp(2\delta/n)>1$, so the deficit is strictly positive. If $\delta=0$, the deficit vanishes. If $\delta$ is small, the expansion $\exp(2\delta/n)-1\approx2\delta/n$ shows that the slack initially grows linearly with entropy excess:

$$
D_n\approx \frac{2\delta}{n}
\bigl(N_n(h_X)+N_n(h_Y)\bigr).
$$

The exact identity and its small-excess approximation clarify the role of dimension. For a fixed entropy excess $\delta$, the multiplicative change is governed by $\delta/n$, the excess per coordinate.

## A bridge to convex geometry

The Brunn--Minkowski inequality says that for measurable sets $A,B\subset\mathbb R^n$, volume radius grows at least linearly under Minkowski addition:

$$
\operatorname{vol}(A+B)^{1/n}
\ge \operatorname{vol}(A)^{1/n}+\operatorname{vol}(B)^{1/n}.
$$

Entropy radius offers a probabilistic analogue of geometric radius, but the combination law has exponent two:

$$
r_S^2\ge r_X^2+r_Y^2.
$$

This contrast is informative. Minkowski addition of sets aligns geometric lengths, producing linear addition of radii. Convolution of independent random variables combines variance-like quantities, producing Euclidean addition of entropy radii. Both theories turn a complicated operation into a simple statement about effective size.

The bridge becomes especially suggestive for random vectors uniformly distributed on sets. Their differential entropy is the logarithm of volume, so entropy normalization naturally recovers a volume scale. Making the full connection rigorous for general sets requires analytic work involving convolution, regularization, and limiting arguments. Still, the radius language reveals why information theory and convex geometry repeatedly share the same functional shapes: logarithms turn products into sums, exponentials restore scale, and normalized radii expose the underlying addition law.

## A universal curve hidden in the formulas

The stability identity also reveals a useful data-collapse principle. Divide the deficit by the boundary power $N_n(h_X)+N_n(h_Y)$. The dependence on the two inputs disappears:

$$
\frac{D_n}{N_n(h_X)+N_n(h_Y)}=\exp(2\delta/n)-1.
$$

Every pair of input entropies therefore follows the same dimension-normalized curve. An engineer comparing noise budgets, a statistician comparing smoothing operations, and a geometer studying radius growth would all see the same graph after scaling by boundary power. At $\delta=0$ the graph passes through zero; for positive excess it rises exponentially; and its initial slope is $2/n$.

The formulas are also computationally friendly. To evaluate the boundary without overflowing when entropies are large, let $m=\max(h_X,h_Y)$ and rewrite it as

$$
B_n(h_X,h_Y)=m+\frac n2\log\!\left(\exp(2(h_X-m)/n)+\exp(2(h_Y-m)/n)\right).
$$

Both exponents are now nonpositive. This familiar log-sum-exp stabilization turns the theorem into a reliable numerical diagnostic: compute the boundary, compare it with the observed output entropy, and use the exact identity to translate the gap into power slack.

The same idea extends conceptually to many inputs. For entropies $h_1,\ldots,h_k$, the natural boundary is

$$
\frac n2\log\!\left(\sum_{j=1}^k\exp(2h_j/n)\right),
$$

whose entropy power is the sum of all input powers. In radius language, the output radius is the Euclidean norm of a $k$-dimensional vector of input radii. The right triangle becomes a right-angled coordinate system.

## Where the picture leads

The results here isolate the exact algebraic skeleton of the sharp entropy-power boundary. Entropy power is squared entropy radius. The inequality is Pythagorean growth. The logarithmic boundary is necessary and sufficient. Isotropic Gaussians attain equality in every positive dimension because variance adds. Entropy excess produces an exact, positive power surplus.

The larger frontier is analytic and geometric. For arbitrary absolutely continuous independent random vectors, one seeks a full proof that convolution places the sum entropy above this boundary, together with the equality classification by Gaussian laws with proportional covariance matrices. A matrix version replaces scalar variance by the determinant radius $\det(\Sigma)^{1/n}$ and connects Gaussian entropy power to Minkowski's determinant inequality. Quantitative stability would go further still, using a small deficit to control distance from the proportional-Gaussian family.

But even before those extensions, the central image is worth keeping: entropy can be assigned a radius, and at the sharp Gaussian boundary two independent sources of uncertainty meet as the legs of a right triangle.