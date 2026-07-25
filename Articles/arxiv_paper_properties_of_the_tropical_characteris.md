# The Hidden Shape of Tropical Characteristic Coefficients

## When addition becomes a contest

Ordinary algebra asks numbers to add and multiply. Tropical algebra changes the rules: the larger of two numbers plays the role of addition, while ordinary addition plays the role of multiplication. In the max-plus convention,

$$
x\oplus y=\max(x,y),\qquad x\odot y=x+y.
$$

This small change turns familiar formulas into optimization problems. A tropical polynomial is not primarily a symbolic expression; when evaluated, it is the upper envelope of finitely many affine functions. Its corners record changes in which affine term wins. Those corners behave like spectral data, and the geometry of their arrangement can reveal hidden structure in a matrix.

The characteristic polynomial is one of linear algebra’s most information-rich objects. In the tropical setting, its coefficients are governed by weighted cycle covers. For a square matrix, choose a set of indices, look at the principal submatrix on that set, and consider every permutation of those indices. Each permutation selects one entry in every row and column. Add the selected entries, then keep the largest possible sum. This maximum is the **tropical permanent** of the principal submatrix.

For each size $k$, define $c_k$ to be the largest tropical permanent among all $k\times k$ principal submatrices. Thus $c_k$ is the best score attainable by choosing exactly $k$ indices and optimally covering them by directed cycles. These numbers form the leading coefficient sequence associated with the tropical characteristic polynomial.

The central question is deceptively simple: what shapes can the sequence

$$
c_0,c_1,\ldots,c_n
$$

have?

The answer developed here is a concavity principle. It does not come from manipulating the polynomial itself. It comes from exchanging index sets.

## The exchange engine

Imagine assigning an integer weight $w(S)$ to every subset $S$ of an $n$-element index set. In the matrix interpretation, $w(S)$ is the tropical permanent of the principal submatrix indexed by $S$. Let

$$
c_k=\max_{|S|=k}w(S).
$$

Because there are only finitely many subsets, this maximum is attained.

Now impose one structural rule. Whenever two sets $S$ and $T$ differ in size by two, so that $|T|=|S|+2$, suppose there are two intermediate sets $U$ and $V$, both of size $|S|+1$, satisfying

$$
w(S)+w(T)\leq w(U)+w(V).
$$

This is the **two-set principal exchange property**. It says that the combined value of a small configuration and a configuration two sizes larger can be redistributed into two middle-sized configurations without losing total weight.

For symmetric tropical matrices, this is the natural combinatorial mechanism suggested by reversible cycle covers: symmetry allows a directed edge to be reversed without changing its matrix weight. The results below are stated carefully: they apply to every principal-weight system that satisfies this exchange property. Establishing the property for any particular matrix class is the matrix-specific step.

Why is exchange powerful? Choose a maximizing set $S$ of size $k-1$ and a maximizing set $T$ of size $k+1$. Their weights are $c_{k-1}$ and $c_{k+1}$. Exchange produces two sets $U$ and $V$ of size $k$. Neither can weigh more than $c_k$, because $c_k$ is the maximum on that layer. Therefore

$$
c_{k-1}+c_{k+1}=w(S)+w(T)
\leq w(U)+w(V)
\leq 2c_k.
$$

This proves the **Coefficient Concavity Theorem**: for every interior index $1\leq k<n$,

$$
2c_k\geq c_{k-1}+c_{k+1}.
$$

The middle coefficient never lies below the midpoint of its neighbors. The coefficient graph bends downward.

## From local bending to global order

Concavity becomes even clearer when expressed through slopes. Define the consecutive increment

$$
d_k=c_k-c_{k-1}\qquad (1\leq k\leq n).
$$

Rearranging the midpoint inequality gives

$$
c_{k+1}-c_k\leq c_k-c_{k-1},
$$

or simply $d_{k+1}\leq d_k$. Thus each new index contributes no more than the preceding one. The coefficient sequence has diminishing marginal returns.

This local comparison propagates across every gap. If $1\leq i\leq j<n$, then repeated application yields

$$
c_{j+1}-c_j\leq c_i-c_{i-1}.
$$

This is the **Global Slope-Ordering Theorem**. It converts a family of local three-term inequalities into an ordering of all consecutive slopes. A coefficient near the end of the sequence can never rise faster than one near the beginning.

That global statement matters because tropical roots are read from changes of slope in the upper envelope associated with a tropical polynomial. Ordered coefficient differences organize the segments of the corresponding Newton diagram. Strictly decreasing differences suggest separated breakpoints; repeated differences signal merged segments or multiplicities. The exchange property therefore travels an unexpectedly long road: from cycle-cover surgery, to coefficient inequalities, to spectral geometry.

## A normalization that changes nothing essential

Tropical models often come with arbitrary choices of baseline and scale. The relevant transformation of a coefficient sequence is the addition of an affine function of the index:

$$
c'_k=c_k+ak+b,
$$

where $a$ and $b$ are integers. This changes every consecutive slope by the same constant:

$$
c'_k-c'_{k-1}=(c_k-c_{k-1})+a.
$$

The ordering of slopes is untouched. Equivalently, the affine terms cancel from every midpoint comparison:

$$
2c'_k-c'_{k-1}-c'_{k+1}
=2c_k-c_{k-1}-c_{k+1}.
$$

Hence the **Affine Invariance Theorem** says that discrete concavity survives every transformation $c_k\mapsto c_k+ak+b$.

At the level of max-plus arithmetic, the elementary identity behind translation is

$$
a+\max(x,y)=\max(a+x,a+y).
$$

Adding a common amount commutes with the tropical choice of a winner. This is why a uniform shift in weights appears as an affine adjustment of coefficient data rather than a change in its essential shape.

## A fast impossibility test

Necessary conditions become useful when they can reject bad data quickly. Here the test is immediate: scan every interior index and check whether

$$
2c_k\geq c_{k-1}+c_{k+1}.
$$

If even one inequality fails, the sequence cannot arise from any principal-weight system satisfying the two-set exchange property. This is the **Midpoint Obstruction Theorem**.

Consider the spike sequence

$$
(c_0,c_1,c_2,c_3,c_4)=(0,0,10,0,0).
$$

At first glance, the large central value looks suspicious, but a concave sequence is allowed to peak sharply. The actual failure occurs one step earlier: at $k=1$,

$$
2c_1=0<10=c_0+c_2.
$$

The jump into the spike is too abrupt. No affine correction can repair it, because affine changes leave the midpoint deficits unchanged.

Contrast this with the quadratic profile

$$
c_k=-k^2.
$$

Its slopes are $-1,-3,-5,\ldots$, which strictly decrease. Indeed,

$$
2(-k^2)-\bigl(-(k-1)^2\bigr)-\bigl(-(k+1)^2\bigr)=2>0.
$$

Every interior inequality is strict. This profile is a clean model of the geometry demanded by exchange, although satisfying the inequalities alone does not assert that a particular matrix realizes it.

## An algorithmic viewpoint

The theory suggests three simple computational tools.

First, a **concavity certificate** computes each deficit

$$
\Delta_k=2c_k-c_{k-1}-c_{k+1}.
$$

The sequence passes exactly when every $\Delta_k$ is nonnegative. This requires one pass through the coefficients and therefore linear time.

Second, a **slope audit** forms $d_k=c_k-c_{k-1}$ and checks that the resulting list is nonincreasing. It is mathematically equivalent to the midpoint test but often easier to visualize.

Third, an **affine-normalization comparison** transforms the data by $c'_k=c_k+ak+b$ and confirms that all deficits remain identical while all slopes shift by $a$. This separates meaningful curvature from arbitrary baseline choices.

These tools can screen candidate spectral data before any attempt is made to reconstruct a matrix. In optimization language, they detect violations of diminishing returns. In discrete convex analysis, they identify a one-dimensional shadow of an exchange geometry. In tropical spectral theory, they constrain the possible Newton diagrams.

## What has—and has not—been established

The logical hierarchy is important. The two-set exchange property is the input. From it follow, without additional positivity assumptions:

1. midpoint concavity of every interior coefficient;
2. nonincreasing adjacent slopes;
3. ordering of slopes across arbitrary gaps;
4. invariance under affine changes of the coefficient index; and
5. a one-inequality obstruction to realizability within the exchange class.

The conclusions do not by themselves prove that every symmetric tropical matrix satisfies the exchange property, nor that every integral concave sequence comes from such a matrix. Those are deeper realization questions. The present theory isolates exactly what must be shown on the matrix side and exactly what follows once it is shown.

That isolation is valuable. A complicated spectral statement has been reduced to a crisp combinatorial hinge: can two optimal principal cycle covers, whose sizes differ by two, be spliced into two intermediate covers without decreasing total weight? Symmetry suggests reversal as the operation that makes such surgery possible. If that conjectural mechanism is established in full generality, the entire concavity hierarchy applies automatically.

## The broader picture

Tropical mathematics often replaces cancellation with comparison and algebraic multiplicity with polyhedral geometry. Here it also replaces spectral calculation with an exchange story. The coefficients of a characteristic polynomial become champions of cardinality layers. Concavity says those champions cannot improve erratically: the benefit of moving from layer $k-1$ to layer $k$ must be at least as large as the benefit of moving from layer $k$ to layer $k+1$.

That principle connects several worlds. A matrix supplies weighted directed cycles. Symmetry hints at reversible surgery. Exchange forces diminishing returns. Diminishing returns orders slopes. Ordered slopes shape a Newton diagram. The path from local combinatorics to global spectral geometry is short enough to prove in a few lines, yet rich enough to guide algorithms and future classification.

The most revealing feature may be the obstruction. One failed midpoint inequality is not merely a numerical blemish. It is evidence that no hidden exchange mechanism of the stated kind can underlie the data. In this way, the curvature of a simple integer sequence becomes a diagnostic window into the combinatorial anatomy of tropical matrices.
