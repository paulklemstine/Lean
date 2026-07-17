# When Curved Motion Becomes Integer Arithmetic

## A trace turns geometry into a recurrence

Imagine standing inside the Poincaré disk, the circular map on which straight hyperbolic roads appear as arcs bending toward the boundary. Repeating one symmetry of this space sends a point along an orbit: one step, two steps, three steps, and onward. The orbit is geometric, but hidden inside it is a remarkably crisp arithmetic clock.

Represent the symmetry by an integer matrix

$$
A=\begin{pmatrix}a&b\\c&d\end{pmatrix},\qquad ad-bc=1.
$$

Such a matrix acts on the upper half-plane by the fractional transformation $z\mapsto (az+b)/(cz+d)$; after a change of picture, the same motion acts on the Poincaré disk. Its trace is the integer $t=a+d$. Although changing coordinates can alter the four entries, conjugating the transformation does not alter $t$. Trace is therefore an intrinsic label for the motion.

Now define $u_n(t)$ to be the trace after the motion has been repeated $n$ times. The entire sequence obeys

$$
u_0(t)=2,\qquad u_1(t)=t,\qquad
u_{n+2}(t)=t\,u_{n+1}(t)-u_n(t).
$$

This is the determinant-one trace recurrence. It is the central character in our story. It replaces a tempting but ambiguous idea—trying to invent addition and multiplication directly on the vertices of a hyperbolic tessellation—with arithmetic attached to a canonical geometric quantity.

Every integer can play the role of the initial trace. For any $t\in\mathbb Z$, the matrix

$$
A_t=\begin{pmatrix}t-1&1\\t-2&1\end{pmatrix}
$$

has determinant $1$ and trace $t$. Thus the recurrence is not an artificial numerical toy: each one of its integer parameters comes from a genuine integral Möbius transformation.

## The trace-three universe

Take $t=3$. The recurrence begins

$$
2,\ 3,\ 7,\ 18,\ 47,\ 123,\ 322,\ldots
$$

At first this resembles any fast-growing integer sequence. Then a striking law appears. The term at twice an index can be calculated from the original term alone:

$$
u_{2n}=u_n^2-2.
$$

For example, $u_2=7$ and $u_4=47=7^2-2$. Likewise $u_5=123$ and $u_{10}=15127=123^2-2$. Threefold jumps are equally economical:

$$
u_{3n}=u_n^3-3u_n.
$$

Thus $u_3=18=3^3-3\cdot3$, and $u_{12}$ can be obtained from $u_4=47$ as $47^3-3\cdot47=103682$.

These are not coincidences confined to $t=3$. They hold for every integer $t$ and every nonnegative integer $n$.

**Trace Doubling Theorem.** For the recurrence $u_0=2$, $u_1=t$, and $u_{n+2}=tu_{n+1}-u_n$, one has

$$
u_{2n}(t)=u_n(t)^2-2
$$

for every integer $t$ and every $n\ge 0$.

**Trace Tripling Theorem.** Under the same assumptions,

$$
u_{3n}(t)=u_n(t)^3-3u_n(t)
$$

for every integer $t$ and every $n\ge 0$.

Why do index multiplication and polynomial evaluation fit together so perfectly? Because repeating a motion $n$ times and then repeating that result $m$ times is the same as repeating the original motion $mn$ times:

$$
(A^n)^m=A^{mn}.
$$

For a determinant-one $2\times2$ matrix $B$, the Cayley–Hamilton identity gives $B^2-(\operatorname{tr}B)B+I=0$. Taking traces yields

$$
\operatorname{tr}(B^2)=(\operatorname{tr}B)^2-2.
$$

Applying the same idea once more gives

$$
\operatorname{tr}(B^3)=(\operatorname{tr}B)^3-3\operatorname{tr}B.
$$

Set $B=A^n$, and the doubling and tripling formulas follow. Group dynamics has been compressed into elementary polynomials.

## A conic that every orbit remembers

The recurrence carries another invariant. Two consecutive terms always lie on one fixed quadratic curve:

$$
u_n^2-t u_nu_{n+1}+u_{n+1}^2=4-t^2.
$$

This is the Pell-Conic Invariant. It can be checked at $n=0$, where the left side is $4-2t^2+t^2=4-t^2$. The recurrence preserves it from one pair to the next. Consequently, the sequence of pairs $(u_n,u_{n+1})$ walks through integer points on the conic

$$
x^2-txy+y^2=4-t^2.
$$

For $|t|>2$, the matrix is hyperbolic and $t^2-4>0$. The conic then reads $x^2-txy+y^2=-(t^2-4)$, linking repeated hyperbolic motion with Pell-type Diophantine geometry. One may watch an orbit in the disk, list traces of powers, or study lattice points on this conic: these are three views of the same arithmetic mechanism.

Doubling respects this geometry in an especially transparent way. Squaring the doubling formula and simplifying gives the **Doubled Discriminant Factorization**:

$$
u_{2n}^2-4=(u_n^2-4)u_n^2.
$$

Equivalently,

$$
4-u_{2n}^2=(4-u_n^2)u_n^2.
$$

The discriminant-like quantity $u_n^2-4$ is multiplied by the perfect square $u_n^2$. Doubling therefore preserves its square class. This is exactly the kind of signature one hopes for when trying to distinguish primitive steps from repeated ones: a composite index leaves a visible square factor behind.

## The boundary cases matter

The classification of determinant-one transformations depends on trace. Values $|t|<2$ are elliptic, $|t|=2$ are parabolic, and $|t|>2$ are hyperbolic. The formulas do not break at the borders.

For $t=2$, the recurrence is constantly $2$. Its discriminant $u_n^2-4$ vanishes at every stage, and the factorization says $0=0\cdot4$. For $t=-2$, alternating signs appear, but the same zero discriminant remains. These degenerate cases are not nuisances to discard; they show that one polynomial law covers elliptic, parabolic, and hyperbolic behavior uniformly.

There is also a familiar analytic face to the recurrence. If $t=2\cosh\theta$, then

$$
u_n(t)=2\cosh(n\theta).
$$

The doubling formula becomes the standard identity $2\cosh(2x)=(2\cosh x)^2-2$, and the tripling formula becomes $2\cosh(3x)=(2\cosh x)^3-3(2\cosh x)$. The integral recurrence is therefore a Chebyshev-type shadow of hyperbolic trigonometry.

## Faster computation, richer structure

The formulas are useful computationally. A direct recurrence takes $O(n)$ integer steps to reach $u_n$. But if an index is built by doubling and tripling, one can jump through the orbit with polynomial updates. Pure powers of two require only $O(\log n)$ updates:

$$
x\longmapsto x^2-2.
$$

For instance, from $u_1=3$ one obtains $u_2=7$, $u_4=47$, $u_8=2207$, and $u_{16}=4870847$ using four quadratic evaluations. The integers themselves grow exponentially, so bit complexity still matters, but the number of recurrence stages collapses.

The pair recurrence also makes modular exploration finite. Modulo an integer $q>1$, advance by

$$
(x,y)\longmapsto (y,ty-x)\pmod q.
$$

This map is invertible, with inverse $(x,y)\mapsto(tx-y,x)$. Since there are only $q^2$ pairs, every modular trace orbit is purely periodic—there is no transient tail before the cycle begins. This observation suggests fast period experiments and connects orbit arithmetic with finite groups.

## What this does—and does not—say about primes

The phrase “hyperbolic prime” is evocative, but it needs a multiplication law before unique factorization can even be stated. Tessellation vertices alone do not supply a canonical monoid, and a finite list of zeros of a numerically chosen zeta function cannot prove a critical-line theorem. The trace approach takes a more disciplined route. It attaches arithmetic to conjugacy-invariant data that are already built into the geometry.

A natural prime-like object is then not an arbitrarily labeled vertex but a primitive closed geodesic, or equivalently a primitive hyperbolic conjugacy class. Its trace is tied to its length $\ell$ by

$$
|\operatorname{tr}A|=2\cosh(\ell/2).
$$

The doubling and tripling maps detect repeated powers of such classes in trace coordinates. They do not yet deliver a prime-geodesic counting theorem or a zeta-function critical-line theorem. What they provide is the exact arithmetic infrastructure on which those more ambitious questions can be posed without ambiguity.

## From a huge matrix to one integer

There is a second surprise in how much information the trace retains. A power $A^n$ has four matrix entries, each potentially enormous. Yet the traces of all later powers of $A^n$ are controlled by the single integer $u_n$. To predict the trace after doubling, no other entry is needed; to predict it after tripling, the same is true. The determinant condition has removed the missing degree of freedom. The eigenvalues of $A^n$ come as a reciprocal pair $\lambda^n$ and $\lambda^{-n}$, and their sum is $u_n$. Every symmetric power sum of this pair is therefore a polynomial in that sum.

This compression has a physical analogy. In a complicated dynamical system, one searches for observables that retain just enough information to predict quantities of interest. Trace is such an observable for repeated two-dimensional, area-preserving linear motion. It does not reconstruct the orbit point or the matrix itself, but it perfectly predicts the trace at multiplied times. In data language, it is a sufficient statistic for this restricted family of questions.

The compression is also robust under a change of viewpoint. Conjugating $A$ changes the coordinate grid but not $\operatorname{tr}(A^n)$. Two observers using different fundamental domains therefore obtain the same trace arithmetic. This invariance is essential if the numbers are to describe the geometry rather than the mapmaker's choices.

## A small laboratory of exact experiments

The recurrence is easy to explore without approximation. Choose an integer $t$, begin with $(2,t)$, and repeatedly replace a pair $(x,y)$ by $(y,ty-x)$. At each stage one may test the conic equation, then compare the term at a doubled or tripled index with its polynomial prediction. For $t=4$, for example, the sequence begins

$$
2,\ 4,\ 14,\ 52,\ 194,\ldots
$$

and doubling $u_2=14$ gives $u_4=14^2-2=194$. The conic check at the pair $(14,52)$ reads

$$
14^2-4\cdot14\cdot52+52^2=-12=4-4^2.
$$

Reducing the same experiment modulo $q$ turns unbounded growth into a finite cycle. This makes the system accessible at several scales: exact integers reveal growth, modular residues reveal repetition, polynomial jumps reveal index multiplication, and conic plots reveal geometry. No single picture tells the whole story, but all four agree because they arise from the same determinant-one motion.

## The road ahead

The quadratic and cubic laws point to a full family of monic integer polynomials $C_m$ satisfying

$$
u_{mn}(t)=C_m(u_n(t)),\qquad C_m\circ C_k=C_{mk}.
$$

One expects each discriminant to factor as

$$
C_m(x)^2-4=(x^2-4)Q_m(x)^2
$$

for an integer polynomial $Q_m$. The proven doubling identity is the first nontrivial case, and tripling supplies the next guidepost.

From there, several paths open: determine sharp periods modulo $q$; classify which Pell-conic points come from primitive group elements; and count primitive conjugacy classes by trace, translating geometric length into arithmetic size. The broad lesson is already clear. Curvature does not destroy arithmetic. When the right coordinate is chosen, curved motion writes its multiplication table in polynomials, its orbits on Pell conics, and its repetitions in perfect-square factors.