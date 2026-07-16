# Listening for Entanglement in a Handful of Moments

Quantum entanglement is famously difficult to see. A bipartite quantum state may involve a matrix with millions of entries, while an experiment can usually estimate only a modest number of summary statistics. The practical question is therefore not merely whether entanglement exists, but whether it leaves a detectable fingerprint in quantities that can actually be measured.

A particularly elegant answer comes from **moments**. Just as the mean and variance summarize a probability distribution, power sums summarize a spectrum. For a finite collection of real spectral nodes $x_1,\ldots,x_n$ with nonnegative weights $w_1,\ldots,w_n$, define the $k$th moment by

$$
p_k=\sum_{j=1}^n w_jx_j^k.
$$

In the application to bipartite quantum states, the $x_j$ represent eigenvalues of a partially transposed density matrix, and the weights represent multiplicities or other nonnegative spectral weights. Partial transposition is a simple rearrangement of matrix entries associated with one half of the system. Every separable state remains positive after this rearrangement. Consequently, finding a negative eigenvalue after partial transposition certifies entanglement.

Directly finding that eigenvalue may be expensive. The central idea developed here is that negativity can announce itself indirectly, through a small matrix assembled from moments.

## A matrix made from echoes

Fix a positive integer $m$. Arrange the moments in the shifted Hankel matrix

$$
H_m=(p_{a+b+1})_{0\le a,b<m}.
$$

Its entries are constant along anti-diagonals. At level $m=2$, for example,

$$
H_2=
\begin{pmatrix}
p_1&p_2\\
p_2&p_3
\end{pmatrix}.
$$

Why this arrangement? Choose coefficients $c_0,\ldots,c_{m-1}$ and form the probe polynomial

$$
f(t)=\sum_{a=0}^{m-1}c_at^a.
$$

A direct expansion gives the decisive identity

$$
c^{\mathsf T}H_mc
=\sum_{a,b=0}^{m-1}c_ac_bp_{a+b+1}
=\sum_{j=1}^n w_jx_jf(x_j)^2.
$$

This is the **shifted-Hankel sum-of-squares identity**. It turns an opaque quadratic expression in measured moments into a spectral balance sheet. Each node contributes its weight, its sign, and the square of the probe evaluated there.

If every $w_j$ and every $x_j$ is nonnegative, every term on the right is nonnegative. Therefore $H_m$ is positive semidefinite at every level: no coefficient vector can make $c^{\mathsf T}H_mc$ negative. This is the basic moment consequence of positivity after partial transposition.

The identity also reveals geometry. Under the same sign assumptions, define a feature vector for each monomial index $a$ by

$$
v_a(j)=\sqrt{w_jx_j}\,x_j^a.
$$

Then

$$
(H_m)_{ab}=\sum_jv_a(j)v_b(j).
$$

Thus $H_m$ is a Gram matrix: it records inner products among feature vectors. Its positivity is not an accidental inequality but a geometric fact, as unavoidable as the nonnegativity of squared length.

## A hierarchy that only gets sharper

Each level permits a polynomial of one higher degree. If $H_{m+1}$ is positive semidefinite, then $H_m$ must be positive semidefinite too: take any degree-at-most-$m-1$ probe and append a zero leading coefficient. The larger quadratic form then reduces exactly to the smaller one.

This gives the **Nesting Theorem**: satisfaction of level $m+1$ implies satisfaction of level $m$. Equivalently, any violation detected at a lower level persists as a failure of every higher level. The tests form a genuine hierarchy rather than an unrelated collection of inequalities.

The hierarchy has an intuitive interpretation. A low-degree polynomial is a broad brush; it cannot vary rapidly across the spectrum. A higher-degree polynomial can concentrate more strongly around a suspicious negative region. More moments buy a more flexible listening device.

Yet finite levels have limits. A negative node need not be exposed by every bounded-degree probe. The hierarchy supplies sufficient certificates of negativity, not a finite-level equivalence with spectral positivity.

## The first nonlinear alarm

At level $m=1$, positivity asks only for $p_1\ge0$. The first genuinely nonlinear condition appears at level $m=2$. A positive semidefinite $2\times2$ matrix must have nonnegative determinant, so

$$
p_1p_3-p_2^2\ge0,
$$

or equivalently

$$
p_2^2\le p_1p_3.
$$

This inequality can also be seen directly from Cauchy--Schwarz. For nonnegative nodes and weights, compare the vectors with components $\sqrt{w_jx_j}$ and $\sqrt{w_jx_j}\,x_j$. Their inner product is $p_2$, while their squared norms are $p_1$ and $p_3$.

The contrapositive is the experimentally useful statement:

> **First Moment Negativity Certificate.** If the weights are nonnegative and $p_1p_3<p_2^2$, then at least one spectral node is negative.

For a partially transposed quantum state, that negative node is a certificate of entanglement. Only three moments are needed.

Consider equal weights on the nodes $-1,2,3$. Their first three moments are $p_1=4$, $p_2=14$, and $p_3=34$. Since $p_1p_3=136<196=p_2^2$, the test detects negativity immediately. By contrast, the nodes $1,2,3$ give $p_1=6$, $p_2=14$, and $p_3=36$, and the required inequality $196\le216$ holds.

The certificate is one-way. If the inequality holds, the spectrum may still contain a negative node that this particular quadratic probe fails to isolate. Passing a medical screening test is not the same as proving perfect health; it means only that the test found no alarm.

## What happens when measurements wobble?

Real experiments do not return exact moments. Suppose the exact values are $p_1,p_2,p_3$ and the estimates are $q_1,q_2,q_3$. Assume

$$
|p_i|\le B\quad\text{and}\quad |q_i-p_i|\le\varepsilon
$$

for $i=1,2,3$. Suppose further that the exact violation has margin $\delta>0$:

$$
p_2^2-p_1p_3\ge\delta.
$$

Errors perturb both the square $p_2^2$ and the product $p_1p_3$. Each perturbation is bounded by

$$
2B\varepsilon+\varepsilon^2.
$$

Therefore, if

$$
2\bigl(2B\varepsilon+\varepsilon^2\bigr)<\delta,
$$

then the measured moments still satisfy

$$
q_1q_3<q_2^2.
$$

This is the **Robustness Theorem for the First Certificate**. It replaces the vague instruction “measure accurately” with an explicit error budget. The larger the determinant margin, the more noise the certificate can tolerate.

The bound is deliberately conservative: it protects against every combination of errors inside the prescribed box. More detailed statistical knowledge can yield sharper confidence intervals, but the deterministic guarantee is valuable precisely because it makes no distributional assumptions.

## Random quantum states and threshold behavior

The motivating arena is a random mixed state on $\mathbb C^d\otimes\mathbb C^d$. Such a state can be produced by choosing a random pure state on the larger space $\mathbb C^d\otimes\mathbb C^d\otimes\mathbb C^s$ and discarding the environment $\mathbb C^s$. The environment dimension $s$ controls the degree of mixing.

As $d$ grows and $s$ scales like $\lambda d^2$, one expects sharp transitions: below a level-dependent critical value, a moment matrix typically detects a violation; above it, the same finite-level test is typically satisfied. Establishing exact random-matrix thresholds requires asymptotic moment formulas and concentration estimates beyond the finite spectral algebra presented here. What the present results provide is the deterministic engine into which those probabilistic estimates fit.

That division of labor is powerful. Random-matrix theory predicts where the moments concentrate. The shifted-Hankel identity translates those moments into a sign test. The stability theorem then turns a limiting sign into a finite-size statement whenever concentration beats the available margin.

## From data to a witness

The method suggests a concrete workflow. Estimate moments $p_1$ through $p_{2m-1}$. Assemble $H_m$. Compute its smallest eigenvalue. If that eigenvalue is negative beyond the uncertainty budget, its eigenvector supplies coefficients for a polynomial probe $f$. The identity

$$
c^{\mathsf T}H_mc=\sum_jw_jx_jf(x_j)^2<0
$$

then proves that the spectrum cannot be entirely nonnegative.

This makes the method more than a yes-or-no test. The least-eigenvalue eigenvector identifies the polynomial that is most negative among normalized coefficient vectors. It is an optimized witness adapted to the measured moments.

The broader lesson reaches beyond quantum information. Moments are compressed data, Hankel matrices organize their consistency, and polynomial probes turn hidden support constraints into quadratic forms. The same pattern appears in inverse problems, signal processing, optimization, and classical moment theory.

## A small experiment at the edge of certainty

Imagine an experimenter obtains $q_1$, $q_2$, and $q_3$ after many repeated measurements. She computes the observed gap $q_2^2-q_1q_3$. A positive number looks promising, but its sign alone is not enough: calibration drift might have pushed the estimate across zero. She therefore bounds the magnitude of each exact moment by $B$, derives an uncertainty $\varepsilon$ for each estimate, and compares the observed or predicted margin with $2(2B\varepsilon+\varepsilon^2)$. Only when the margin clears that barrier does she announce a robust certificate.

This discipline matters because the boundary $p_2^2=p_1p_3$ has a concrete meaning. Equality in Cauchy--Schwarz occurs when the two feature vectors are proportional. On every node carrying positive $w_jx_j$, that means $x_j$ is constant. A spectrum concentrated at one positive value therefore sits on the boundary. Near such a concentrated spectrum, tiny changes can alter the determinant sign, exactly where caution is warranted.

At higher levels, the same experimental story becomes an eigenvalue problem. The smallest eigenvalue of $H_m$ measures the weakest direction of the moment geometry. A clearly negative value is an alarm; its eigenvector tells the experimenter which polynomial combination of moments produced the alarm. Instead of searching blindly through many inequalities, one diagonalization discovers the best normalized probe available at that level.

There is also a useful computational trade-off. Level $m$ consumes moments through order $2m-1$. Raising $m$ can reveal subtler negative support, but high moments are typically harder to estimate and more sensitive to outliers. The hierarchy therefore offers a dial between experimental cost and detection power rather than insisting on an all-or-nothing reconstruction.

Entanglement may inhabit an enormous matrix, but it can cast a small shadow. Three numbers can already reveal a negative spectral direction; more numbers build a nested family of sharper probes. The art is to arrange those numbers so that geometry becomes audible—and the shifted Hankel matrix does exactly that.
