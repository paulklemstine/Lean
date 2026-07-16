# Uncertainty in a World of Nested Digits

## How missing branches force waves to spread

The ordinary number line is built for distance. Two points are close when their difference is small. But there is another geometry in which closeness means agreement: two numbers are near each other when their base-$p$ expansions share many initial digits. In this world, a long common prefix matters more than physical separation, and every ball breaks into exactly $p$ smaller balls. The resulting landscape is an infinite rooted tree.

This is the geometry behind the $p$-adic numbers. It appears in number theory, arithmetic dynamics, hierarchical models, coding, and systems whose natural scales come in prime powers. It also gives uncertainty a strikingly combinatorial form. A signal cannot be confined to a thin collection of leaves of the tree while its oscillatory transform is simultaneously confined to another thin collection—provided the two collections lose enough branches at every level.

The central result described here makes that principle explicit. It does not rely on delicate cancellation between phases. Instead, it combines two simple facts: porous trees have exponentially few leaves, and a normalized oscillatory matrix cannot move too much energy between two small sets. Their combination yields a quantitative uncertainty factor at every depth.

## Numbers as paths through a tree

Fix an integer $q\ge 2$, often a prime $p$. A word of length $n$ over a $q$-symbol alphabet selects one leaf of a depth-$n$ regular tree. In the $p$-adic unit ball, these words are residue classes modulo $p^n$. The first digit chooses one of $p$ large subballs, the second chooses one of $p$ subballs inside it, and so on.

A subset of leaves is **uniformly porous with branching bound $a$** if every occupied node has at most $a$ occupied children. If $c(n)$ counts occupied nodes at depth $n$, this says

$$
c(0)\le 1,\qquad c(n+1)\le a\,c(n).
$$

The Tree Growth Theorem states that

$$
c(n)\le a^n.
$$

The proof is the simplest possible induction. At depth $0$ there is at most one root. If there are at most $a^n$ occupied nodes at depth $n$, and each contributes at most $a$ children, then there are at most $a^{n+1}$ occupied nodes one level later. What matters is not the sophistication of the argument but its relentless accumulation: losing branches locally produces exponential scarcity globally.

For two porous sets $X$ and $Y$, with branching bounds $a$ and $b$, the same reasoning gives

$$
|X|\,|Y|\le (ab)^n
$$

at depth $n$. This product is exactly what the analytic part of the story needs.

## Measuring how much of a signal survives

Let $X$ be a finite input set and let $f:X\to\mathbb C$ be a signal. Its energy on $X$ is

$$
E_X(f)=\sum_{x\in X}|f(x)|^2.
$$

Now take a finite output set $Y$ and a kernel $K(y,x)$. The restricted transform is

$$
(T_Xf)(y)=\sum_{x\in X}K(y,x)f(x),\qquad y\in Y.
$$

Think of $K(y,x)$ as a wave emitted from $x$ and observed at $y$. For a normalized transform on an ambient space of size $N$, each matrix entry has magnitude at most $N^{-1/2}$:

$$
|K(y,x)|\le \frac{1}{\sqrt N}.
$$

The Restricted Energy Theorem says that

$$
E_Y(T_Xf)\le \frac{|X|\,|Y|}{N}E_X(f).
$$

This estimate is universal. It does not require the rows of the matrix to be orthogonal. It does not even require a special Fourier phase. Only the entrywise normalization matters.

Why is it true? For each $y$, the triangle inequality gives

$$
|(T_Xf)(y)|\le \frac{1}{\sqrt N}\sum_{x\in X}|f(x)|.
$$

Cauchy–Schwarz then turns the square of the sum into a sum of squares:

$$
\left(\sum_{x\in X}|f(x)|\right)^2\le |X|\sum_{x\in X}|f(x)|^2.
$$

Finally, summing over the $|Y|$ output points yields the theorem. In matrix language, this is the Hilbert–Schmidt bound: the size of a restricted operator is controlled by the number and magnitude of its entries.

A particularly important kernel is

$$
K(y,x)=\frac{e^{i\phi(y,x)}}{\sqrt N},
$$

where $\phi(y,x)$ is any real-valued phase. Since $|e^{i\phi}|=1$, every entry has exactly the required magnitude. Thus the same estimate applies to every normalized finite oscillatory transform.

## The finite-scale fractal uncertainty principle

Now the tree and the waves meet. At depth $n$ in a $q$-ary tree, the ambient number of leaves is

$$
N=q^n.
$$

Suppose $X$ has at most $a^n$ leaves and $Y$ has at most $b^n$ leaves. Substituting these counts into the restricted energy estimate gives the Finite-Scale Porous Uncertainty Theorem:

$$
E_Y(T_Xf)\le \left(\frac{ab}{q}\right)^n E_X(f).
$$

This is the main quantitative statement. Every scale contributes the same factor $ab/q$. The two supports contribute $a$ and $b$ through their branching, while normalization contributes the inverse ambient branching $1/q$.

If

$$
ab<q,
$$

then $ab/q<1$, and the energy reaching $Y$ decays exponentially with depth. For every positive $n$,

$$
\left(\frac{ab}{q}\right)^n<1.
$$

No nonzero signal concentrated on $X$ can send all its transformed energy into $Y$ under this estimate. The deeper the tree, the more severe the loss.

The threshold is as informative as the theorem. If $ab\ge q$, the elementary factor no longer contracts. That does not mean uncertainty disappears. It means support size alone cannot prove it. One must use cancellation among oscillatory phases, additive-energy decay, entropy, or another structure that sees more than cardinality.

## A concrete five-way example

Take a five-branching tree, so $q=5$. Let both supports retain at most two children from every occupied node, so $a=b=2$. At depth $3$, each support has at most

$$
2^3=8
$$

leaves, while the ambient tree has

$$
5^3=125
$$

leaves. The theorem gives

$$
E_Y(T_Xf)\le \left(\frac{4}{5}\right)^3E_X(f)
=\frac{64}{125}E_X(f).
$$

Thus at most $51.2\%$ of the input energy can be captured on the selected output support. At depth $10$, the factor becomes $(4/5)^{10}$, about $10.7\%$. At depth $50$, it is roughly $0.00143\%$. A modest loss of one or more branches per scale becomes overwhelming when multiplied through the hierarchy.

This example also shows why the energy formulation is natural. The factor $64/125$ bounds squared norm. The corresponding operator-norm factor is its square root, $8/\sqrt{125}$. Energy behaves multiplicatively and therefore aligns perfectly with repeated tree scales.

## Why this is genuinely fractal

In Euclidean geometry, porous sets have holes at many locations and scales. In the ultrametric tree, holes become missing descendants. The tree model strips porosity down to its combinatorial skeleton: at each level, some routes are unavailable.

A uniformly porous tree resembles a digital Cantor set. If every node keeps at most $a$ out of $q$ children, its leaf count grows like $a^n$ instead of $q^n$. Its effective dimension is therefore at most

$$
\frac{\log a}{\log q}.
$$

For two supports, the contraction condition $ab<q$ can be written as

$$
\frac{\log a}{\log q}+\frac{\log b}{\log q}<1.
$$

So the elementary uncertainty regime says: when the sum of the two branching dimensions is below the ambient dimension, restricted oscillatory energy decays exponentially. This dimension interpretation connects a finite matrix estimate to the geometry of fractals.

## Prime powers and exact self-similarity

Prime-power scales organize more than harmonic analysis. Consider an additive one-dimensional cellular evolution in characteristic $p$ whose one-step propagation operator is the sum of a unit shift to the right and a unit shift to the left. After $p^k$ steps, the Frobenius identity eliminates the intermediate binomial coefficients modulo $p$, leaving exactly two rays:

$$
(S+S^{-1})^{p^k}=S^{p^k}+S^{-p^k}.
$$

At the same depth $p^k$, the porous uncertainty estimate reads

$$
E_Y(T_Xf)\le
\left(\frac{ab}{p}\right)^{p^k}E_X(f),
$$

provided $|X|\le a^{p^k}$ and $|Y|\le b^{p^k}$.

These are independent statements, not an equivalence. Yet they reveal a shared scale hierarchy. In one problem, prime powers cause exact algebraic collapse to two light rays. In the other, they amplify a per-level uncertainty loss. Both are governed by the same filtration $p^k$, suggesting a broader transfer-operator language for self-similar arithmetic systems.

## A practical way to explore the principle

The theorem invites a simple numerical experiment. Choose a base $q$, a depth $n$, and two allowed digit sets $D_X$ and $D_Y$. Form $X$ from all residues whose $n$ base-$q$ digits lie in $D_X$, and form $Y$ similarly. Their branching bounds are $a=|D_X|$ and $b=|D_Y|$. Next assign complex amplitudes to $X$, apply the normalized discrete Fourier matrix of size $q^n$, and total the energy observed on $Y$.

Two numbers can then be compared. The measured ratio is $E_Y(T_Xf)/E_X(f)$. The guaranteed ratio is $(ab/q)^n$. The measured value is often much smaller because actual Fourier waves cancel, while the guarantee deliberately assumes the worst possible alignment. Changing the phase to a quadratic or nonlinear function changes the measured ratio but not the theorem's ceiling, as long as every kernel entry still has magnitude $q^{-n/2}$.

This distinction between guarantee and observation is useful in applications. The bound is a certificate that survives uncertainty about phases. Numerical experiments reveal the extra performance contributed by cancellation in a particular model. Together they separate what follows from geometry alone from what depends on the detailed wave law.

## What the elementary argument sees—and what it misses

The strength of the method is transparency. It applies to any phase $\phi$, gives an explicit constant, and cleanly separates combinatorics from analysis. The tree-growth module supplies support bounds; the kernel module converts support bounds into energy loss.

Its limitation is equally transparent: the triangle inequality discards cancellation. Oscillatory transforms are powerful precisely because waves can interfere destructively, but the Hilbert–Schmidt argument treats all phases as if they aligned. Consequently, the method proves a strong-porosity regime rather than the most general porous-set uncertainty principle.

That boundary points toward the next mathematics. Additive energy can measure how often arithmetic coincidences occur among leaves and may recover gains when $ab\ge q$. Block entropy can replace rigid level-by-level bounds with average losses over groups of scales. Random deletion models can turn the deterministic product of branching ratios into a Lyapunov exponent. And the prime-power connection invites a transfer-operator framework joining contraction phenomena to exact Frobenius self-similarity.

The broader lesson is simple. Hierarchical geometry turns uncertainty into bookkeeping across scales. Every missing branch removes possible concentration; every normalized oscillatory entry spreads amplitude; and multiplication carries a small local deficit into a decisive global law. In the $p$-adic world, uncertainty grows one digit at a time.
