# Lattice Points on the Affine Fermat Cubic: Sharp Taxicab and Cabtaxi Values, a Scaling Structure Theorem, and the Ceiling of the Shell Method

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We study the lattice points of the affine Fermat cubic $x^3 + y^3 = N$ in two regimes: the positive orthant, whose points are the classical *taxicab* representations of $N$ as a sum of two positive cubes, and the full integral plane with both coordinates nonzero, whose points are the *cabtaxi* representations of $N$ as a sum of two nonzero integer cubes. We obtain the following.

1. **A priori localisation.** Every nonzero integral point of $x^3+y^3=N$ with $N \ge 1$ satisfies $x^2 \le N$ and $y^2 \le N$. The estimate is what makes the signed problem finite: the unbounded mixed-sign branch of the real curve carries no lattice points once $N$ is fixed.

2. **Sharp small values.** $\mathrm{Taxicab}(2) = 1729$ (existence and minimality), $\mathrm{Cabtaxi}(2) = 91$ with $91 = 3^3 + 4^3 = 6^3 - 5^3$, and $\mathrm{Cabtaxi}(3) = 728$ with $728 = 6^3 + 8^3 = 9^3 - 1^3 = 12^3 - 10^3$. In particular the "signs are strictly cheaper" phenomenon holds at $n=2$: $91 < 1729$. At $N = 728$ the signed representation count is $3$ while the unsigned count is $1$, a ratio of $3:1$.

3. **Exact structure of cube scaling.** For $m \ge 1$ the map $(a,b) \mapsto (ma, mb)$ is a bijection from the representations of $N$ onto the representations of $m^3N$ whose summands are both divisible by $m$. Consequently $r(N) \le r(m^3N)$, and the defect is exactly the set of primitive representations. The natural "cube-free core" conjecture — that $r$ is determined by the cube-free part of $N$ — is **false**: $344 = 2^3 \cdot 43$ has $r(344) = 1 > 0 = r(43)$.

4. **A sharpened elementary growth floor and its ceiling.** If $N$ has at least $n$ representations as a sum of two positive cubes then $N \ge 110\,(n-1)^3$; in particular $N > n^3$ for $n \ge 2$. We identify the exact fixed point of the underlying squeeze and show that no refinement of this "shell" argument can exceed the constant $\left(2^{1/3}/(2^{1/3}-1)\right)^3 = 113.8953\ldots$, so the method is intrinsically cubic.

5. **Reduction of the unboundedness conjecture.** For any finite family of rational points with nonzero (resp. positive) coordinates on a single cubic $x^3 + y^3 = q$, $q > 0$, there is a positive integer with at least that many signed (resp. positive) representations. Hence the existence of $\mathrm{Taxicab}(n)$ for all $n$ follows from the existence of a single cubic carrying infinitely many rational points in the appropriate region. We record the chord–tangent duplication identity that would generate such an orbit.

6. **Unconditional witnesses.** Explicit lattice points certify integers with $3, 4, 5$ and $6$ representations, and combining the $6$-witness with the scaling injection yields infinitely many integers with at least six representations. Bracketing $n = 6$ gives $13\,750 \le \mathrm{Taxicab}(6) \le 24\,153\,319\,581\,254\,312\,065\,344$, a gap of eighteen orders of magnitude.

**Keywords:** taxicab numbers, cabtaxi numbers, Fermat cubic, lattice points, elliptic curves, chord–tangent construction, sums of two cubes, Hardy–Ramanujan.

---

## 1. Introduction

The number $1729$ owes its fame to an exchange between Hardy and Ramanujan, but the mathematical content of that exchange is geometric. Fix a positive integer $N$. The real solutions of
$$x^3 + y^3 = N$$
form a smooth affine cubic curve; the *representations* of $N$ as a sum of two cubes are precisely the points of this curve with integral coordinates. Counting representations is therefore counting lattice points on a cubic, and the difficulty of the taxicab problem is the difficulty of controlling lattice points on curves of genus one.

This paper isolates what can be proved about this counting problem by elementary and geometric means, determines precisely where those means fail, and reduces the principal open conjecture to a single input from arithmetic geometry.

### 1.1 Notation and basic definitions

**Definition 1.1 (positive representation set).** For $N \in \mathbb{N}$ put
$$R(N) = \{(a,b) \in \mathbb{Z}_{\ge 1}^2 : a \le b,\ a^3 + b^3 = N\}, \qquad r(N) = |R(N)|.$$
The condition $a \le b$ selects one representative from each unordered pair.

**Definition 1.2 (signed representation set).** For $N \in \mathbb{N}$ put
$$R^{\pm}(N) = \{(a,b) \in \mathbb{Z}^2 : a \neq 0,\ b \neq 0,\ a \le b,\ a^3 + b^3 = N\}, \qquad r^{\pm}(N) = |R^{\pm}(N)|.$$

**Definition 1.3 (taxicab and cabtaxi values).** $\mathrm{Taxicab}(n)$ is the least $N \ge 1$ with $r(N) \ge n$, and $\mathrm{Cabtaxi}(n)$ is the least $N \ge 1$ with $r^{\pm}(N) \ge n$ (when such $N$ exist).

Both sets are finite, but for different reasons, and establishing this is the first order of business. In the positive case it is trivial: $a \le a^3 \le N$ and $b \le b^3 \le N$, so $R(N) \subseteq [1,N]^2$. In the signed case the real curve has an unbounded branch in the second and fourth quadrants, along which $|x|, |y| \to \infty$ with $x^3 + y^3$ constant; finiteness of $R^\pm(N)$ requires an argument.

---

## 2. Localisation: the a priori bound on the signed cubic

**Theorem 2.1 (a priori bound).** *Let $N \ge 1$ and let $a, b$ be nonzero integers with $a \le b$ and $a^3 + b^3 = N$. Then*
$$a^2 \le N \quad\text{and}\quad b^2 \le N.$$

*Proof.* First, $b > 0$. Indeed if $b < 0$ then $a \le b \le -1$, and every integer $x \le -1$ satisfies $x^3 \le -1$ (from $x^2 \ge 1$ and $x < 0$ one gets $x \cdot x^2 \le x \le -1$); hence $N = a^3 + b^3 \le -2 < 0$, a contradiction. Since $b \ne 0$, $b \ge 1$.

Two cases remain.

*Positive quadrant, $a \ge 1$.* Then $b \ge 1$, so $b^2 \le b^3$, and $b^3 = N - a^3 \le N - 1 < N$; hence $b^2 \le N$. From $0 \le a \le b$ we get $a^2 \le b^2 \le N$.

*Mixed sign, $a < 0 < b$.* Write $a = -k$ with $k \ge 1$. Then
$$N = b^3 - k^3 = (b - k)\bigl(b^2 + bk + k^2\bigr).$$
Since $N > 0$ and the second factor is positive, $b > k$, hence $b - k \ge 1$ and
$$N \ge b^2 + bk + k^2 \ge \max(b^2, k^2) = \max(b^2, a^2). \qquad \blacksquare$$

The mixed-sign case is the whole content. Geometrically, the real branch through the second quadrant does run off to infinity, but the *gap between consecutive cubes* grows quadratically: $b^3 - (b-1)^3 = 3b^2 - 3b + 1$. To have $b^3 - k^3 = N$ small with $b$ large one needs $b - k \ge 1$, and then the quadratic factor already exceeds $N$. Lattice points cannot follow the branch out.

**Corollary 2.2 (localisation to a box).** *If $1 \le N < (B+1)^2$ then $R^{\pm}(N) \subseteq [-B, B]^2$.*

*Proof.* By Theorem 2.1, $a^2 \le N < (B+1)^2$, so $|a| \le B$; likewise for $b$. $\blacksquare$

Corollary 2.2 is the engine of every sharp cabtaxi computation below: it turns the determination of $\mathrm{Cabtaxi}(n)$ into a finite sweep over an explicitly bounded square.

---

## 3. Sharp small values

### 3.1 The positive case: $\mathrm{Taxicab}(2) = 1729$

**Lemma 3.1.** *If $N < 1729$ and $(a,b) \in R(N)$ then $1 \le a \le b \le 12$.*

*Proof.* $b^3 \le N \le 1728 = 12^3$, and $13^3 = 2197 > 1728$. $\blacksquare$

**Theorem 3.2 (Hardy–Ramanujan, sharp form).**
$$R(1729) = \{(1,12), (9,10)\}, \qquad r(1729) = 2,$$
*and $r(N) \le 1$ for every $N < 1729$. Hence $\mathrm{Taxicab}(2) = 1729$.*

*Proof sketch.* Existence: $1 + 1728 = 729 + 1000 = 1729$. Minimality: by Lemma 3.1 every representation of any $N \le 1728$ lies in the grid $[1,12]^2$; an exhaustive sweep of the $78$ ordered pairs $1 \le a \le b \le 12$ shows that the map $(a,b) \mapsto a^3 + b^3$ is injective on those pairs whose value is below $1729$. Consequently no $N < 1729$ has two distinct representations. That $R(1729)$ contains nothing else follows from the same sweep, since $1729 \le 12^3 + 12^3$ forces both summands into $[1,12]$. $\blacksquare$

The proof pattern — *bound, then sweep* — recurs throughout; the mathematical content is always the bound.

### 3.2 The signed case: $\mathrm{Cabtaxi}(2) = 91$

**Theorem 3.3.**
$$R^{\pm}(91) = \{(-5, 6), (3,4)\}, \qquad 91 = 3^3 + 4^3 = 6^3 - 5^3,$$
*and $r^{\pm}(N) \le 1$ for every $1 \le N < 91$. Hence $\mathrm{Cabtaxi}(2) = 91$.*

*Proof sketch.* Since $91 < 100 = 10^2$, Corollary 2.2 with $B = 9$ places every signed representation of $91$, and of every smaller positive integer, in $[-9,9]^2$. Inside that square there are finitely many nonzero ordered pairs $(a,b)$, $a \le b$, with $0 < a^3 + b^3 < 91$ together with those summing to $91$; sweeping them shows (i) the only pairs with $a^3+b^3 = 91$ are $(-5,6)$ and $(3,4)$, and (ii) the map $(a,b) \mapsto a^3+b^3$ is injective on the pairs with value in $(0,91)$. $\blacksquare$

**Corollary 3.4 (signs are strictly cheaper at $n = 2$).** $\mathrm{Cabtaxi}(2) = 91 < 1729 = \mathrm{Taxicab}(2)$.

This is the $n = 2$ instance of the general expectation that permitting a negative summand strictly lowers the least number with $n$ representations. It is not a formal consequence of anything: allowing signs enlarges the representation set of *each* $N$, but the minimal $N$ could in principle be unchanged. Here it drops by a factor of $19$.

### 3.3 The signed case: $\mathrm{Cabtaxi}(3) = 728$

**Theorem 3.5.**
$$R^{\pm}(728) = \{(-10, 12), (-1, 9), (6,8)\},$$
*so $728 = 6^3 + 8^3 = 9^3 - 1^3 = 12^3 - 10^3$, and $r^{\pm}(N) \le 2$ for every $1 \le N < 728$. Hence $\mathrm{Cabtaxi}(3) = 728$.*

*Proof sketch.* $728 < 729 = 27^2$, so Corollary 2.2 with $B = 26$ confines all signed representations of $728$ and of every smaller positive integer to $[-26,26]^2$. The sweep of that square verifies the three representations listed and shows that no value in $(0, 728)$ is attained by three distinct admissible pairs. $\blacksquare$

**Proposition 3.6 (the signed count strictly dominates).** *For every $N \ge 1$, $r(N) \le r^{\pm}(N)$, since $R(N) \hookrightarrow R^{\pm}(N)$ by inclusion. The inequality can be strict with ratio at least $3$:*
$$R(728) = \{(6,8)\}, \qquad r(728) = 1, \qquad r^{\pm}(728) = 3.$$

That is, the curve $x^3 + y^3 = 728$ has one lattice point in the open positive quadrant and three in the punctured plane. The two extra points, $(-1,9)$ and $(-10,12)$, live on the mixed-sign branch — the branch that Theorem 2.1 confines to $|x|, |y| \le 26$.

---

## 4. Cube scaling: an exact structure theorem, and the failure of cube-free reduction

If $N = a^3 + b^3$ then $m^3 N = (ma)^3 + (mb)^3$, so representations can always be transported upwards along cube multiples. The next theorem says that this construction accounts for *exactly* the representations of $m^3N$ that are divisible by $m$, and nothing more.

**Theorem 4.1 (structure theorem for cube scaling).** *Let $m \ge 1$ and $N \ge 0$. Then*
$$\{(x,y) \in R(m^3 N) : m \mid x \text{ and } m \mid y\} = \{(ma, mb) : (a,b) \in R(N)\},$$
*and the map $(a,b) \mapsto (ma, mb)$ is a bijection between $R(N)$ and this set.*

*Proof.* ($\supseteq$) If $(a,b) \in R(N)$ then $ma \ge 1$, $ma \le mb$, and $(ma)^3 + (mb)^3 = m^3(a^3+b^3) = m^3N$; both coordinates are divisible by $m$.

($\subseteq$) Let $(x,y) \in R(m^3N)$ with $x = ma$, $y = mb$. Then $ma \ge 1$ gives $a \ge 1$; $ma \le mb$ gives $a \le b$ by cancelling $m > 0$; and $m^3(a^3 + b^3) = m^3 N$ gives $a^3 + b^3 = N$ after cancelling $m^3 > 0$. So $(a,b) \in R(N)$.

Injectivity of $(a,b) \mapsto (ma,mb)$ is cancellation of $m$. $\blacksquare$

**Corollary 4.2 (monotonicity along cube multiples).** $r(N) \le r(m^3 N)$ for all $m \ge 1$.

The obvious next hope is that this inequality is an equality — equivalently, that the representation count is an invariant of the cube-free core. It fails at once.

**Theorem 4.3 (refutation of the cube-free core conjecture).** *We have $344 = 2^3 \cdot 43$ with $43$ cube-free, and*
$$R(43) = \varnothing, \qquad R(344) = \{(1,7)\},$$
*so $r(344) = 1 > 0 = r(43)$. Hence $r$ is not determined by the cube-free core, and the injection of Corollary 4.2 is in general strict.*

*Proof.* Any representation of $43$ has larger summand $b$ with $b^3 \le 43$, so $b \le 3$; the six pairs with $1 \le a \le b \le 3$ have cube-sums $2, 9, 28, 16, 35, 54$, none equal to $43$. Any representation of $344$ has $b \le 7$ since $8^3 = 512 > 344$; sweeping $1 \le a \le b \le 7$ leaves exactly $(1,7)$, and indeed $1 + 343 = 344$. $\blacksquare$

The reason is structural rather than accidental: $(1,7)$ is a *primitive* representation, $\gcd(1,7) = 1$, so it is invisible to the scaling map, which only ever produces pairs with a common factor $m$. The corrected statement is a decomposition.

**Corollary 4.4 (imprimitive–primitive decomposition).** *For $m \ge 1$,*
$$r(m^3 N) = r(N) + \#\{(x,y) \in R(m^3N) : m \nmid x \text{ or } m \nmid y\},$$
*the first term being exactly the image of the scaling bijection. The representation function of a number is therefore governed by its cube-free core only up to this primitive defect, which is nonempty already for $344$.*

---

## 5. The shell method: a sharpened growth floor and its intrinsic ceiling

### 5.1 The lower bound

The key structural remark is that a representation is determined by its larger summand.

**Lemma 5.1 (injectivity in the larger summand).** *The projection $(a,b) \mapsto b$ is injective on $R(N)$.*

*Proof.* If $(a,b), (a',b) \in R(N)$ then $a^3 = N - b^3 = (a')^3$, and cubing is injective on $\mathbb{N}$. $\blacksquare$

**Lemma 5.2 (the shell).** *If $(a,b) \in R(N)$ then $N/2 \le b^3 \le N$.*

*Proof.* $b^3 \le a^3 + b^3 = N$, and $N = a^3 + b^3 \le 2b^3$ since $a \le b$. $\blacksquare$

So the larger summands of the $r(N)$ representations are $r(N)$ distinct integers lying in the shell $\left[(N/2)^{1/3},\, N^{1/3}\right]$. Writing $s$ for the smallest and $m$ for the largest of them, distinctness forces $m - s \ge r(N) - 1$, while Lemma 5.2 gives $m^3 \le N \le 2s^3$. Everything now follows from a purely numerical squeeze.

**Lemma 5.3 (shell squeeze).** *Let $s \ge 1$, $j \ge 0$ and $N$ satisfy $(s+j)^3 \le N \le 2 s^3$. Then $N \ge 110\, j^3$.*

*Proof.* Assume $j \ge 1$ (otherwise the claim is trivial). Expanding $(s+j)^3 \le 2s^3$ gives
$$3s^2 j + 3 s j^2 + j^3 \le s^3. \tag{5.1}$$
*First squeeze.* Since $j \ge 1$ and $s \ge 1$, (5.1) gives $s^3 > 3s^2 j$, hence $s > 3j$; in particular $s \ge 3j$.

*Second squeeze.* Write $s = 3j + \rho$ with $\rho \ge 0$. Substituting $s = 3j+\rho$ into (5.1) and collecting terms,
$$s^3 - 3s^2 j - 3 s j^2 - j^3 = -10 j^3 + 6 j^2 \rho + 6 j \rho^2 + \rho^3 \ \ge 0,$$
that is
$$10 j^3 \le 6 j^2 \rho + 6 j \rho^2 + \rho^3. \tag{5.2}$$
If $5\rho < 4j$, i.e. $\rho < \tfrac45 j$, the right-hand side of (5.2) is strictly less than
$$6 j^2 \cdot \tfrac45 j + 6j \cdot \tfrac{16}{25} j^2 + \tfrac{64}{125} j^3 = \left(\tfrac{24}{5} + \tfrac{96}{25} + \tfrac{64}{125}\right) j^3 = 9.152\, j^3 < 10 j^3,$$
a contradiction. Hence $5 \rho \ge 4j$, i.e. $s = 3j + \rho \ge 3j + \tfrac45 j = \tfrac{19}{5} j$.

*Conclusion.* Then $s + j \ge \tfrac{24}{5} j$, so
$$N \ge (s+j)^3 \ge \left(\tfrac{24}{5}\right)^3 j^3 = \tfrac{13824}{125} j^3 = 110.59\ldots\, j^3 \ge 110 j^3. \qquad \blacksquare$$

**Theorem 5.4 (sharpened growth floor).** *If $r(N) \ge n$ then $N \ge 110\,(n-1)^3$.*

*Proof.* For $n \le 1$ the claim is vacuous. For $n \ge 2$, let $T$ be the set of larger summands of representations of $N$; by Lemma 5.1, $|T| = r(N) \ge n$. Let $s = \min T$ and $m = \max T$. Since $T \subseteq [s,m] \cap \mathbb{Z}$, we get $m - s + 1 \ge n$, i.e. $m \ge s + (n-1)$. Lemma 5.2 applied to the representations realising $m$ and $s$ gives $m^3 \le N$ and $N \le 2 s^3$. Apply Lemma 5.3 with $j = m - s \ge n-1$ and use monotonicity of $j \mapsto j^3$. $\blacksquare$

**Corollary 5.5.** *If $r(N) \ge n$ with $n \ge 2$ then $N > n^3$.*

*Proof.* Write $n = k+1$ with $k \ge 1$. Theorem 5.4 gives $N \ge 110 k^3$, while $(k+1)^3 \le (2k)^3 = 8k^3 < 110k^3$. $\blacksquare$

### 5.2 The ceiling: the shell method cannot beat $113.90$

Lemma 5.3 was obtained by iterating a single inequality twice. It is natural to ask what iterating it indefinitely gives, and the answer is a hard limit.

**Proposition 5.6 (saturation of the shell method).** *Let $c$ be any constant such that the implication*
$$\bigl[\,(s+j)^3 \le N \le 2s^3,\ s, j \ge 1\,\bigr] \implies N \ge c\, j^3$$
*holds for all real $s, j, N$. Then*
$$c \le \left(\frac{2^{1/3}}{2^{1/3}-1}\right)^{3} = 113.8953\ldots$$

*Proof.* The constraint set is scale-invariant: put $t = s/j$. The hypothesis $(s+j)^3 \le 2s^3$ is $(t+1)^3 \le 2 t^3$, i.e. $t+1 \le 2^{1/3} t$, i.e.
$$t \le t_\ast := \frac{1}{2^{1/3}-1} = 3.8473\ldots$$
The best available conclusion is $N \ge (s+j)^3 = (t+1)^3 j^3$, and the extremal admissible configuration is $t = t_\ast$, $N = (s+j)^3$, giving
$$c \le (t_\ast + 1)^3 = \left(\frac{2^{1/3}}{2^{1/3}-1}\right)^3 = 2 t_\ast^3 = 113.8953\ldots \qquad \blacksquare$$

Note that the fixed-point equation $(t+1)^3 = 2t^3$ is the same as $t^3 = 3t^2 + 3t + 1$, so the proved constant $110$ and the supremum $113.90$ bracket everything the method can deliver. The two ingredients used — the ordering $a \le b$ and positivity — are therefore *provably insufficient* to obtain any super-cubic bound.

### 5.3 How far the truth is from the ceiling

**Theorem 5.7 (unconditional witnesses).** *The following integers are sums of two positive cubes in at least $3, 4, 5, 6$ ways respectively:*

$$
\begin{aligned}
87\,539\,319 &= 167^3 + 436^3 = 228^3 + 423^3 = 255^3 + 414^3,\\[2pt]
6\,963\,472\,309\,248 &= 2421^3 + 19083^3 = 5436^3 + 18948^3 \\
 &= 10200^3 + 18072^3 = 13322^3 + 16630^3,\\[2pt]
48\,988\,659\,276\,962\,496 &= 38787^3 + 365757^3 = 107839^3 + 362753^3 = 205292^3 + 342952^3\\
 &= 221424^3 + 336588^3 = 231518^3 + 331954^3,\\[2pt]
24\,153\,319\,581\,254\,312\,065\,344 &= 582162^3 + 28906206^3 = 3064173^3 + 28894803^3\\
 &= 8519281^3 + 28657487^3 = 16218068^3 + 27093208^3\\
 &= 17492496^3 + 26590452^3 = 18289922^3 + 26224366^3.
\end{aligned}
$$

**Corollary 5.8 (infinitude of six-fold numbers).** *For every $m \ge 1$, $r\bigl(m^3 \cdot 24\,153\,319\,581\,254\,312\,065\,344\bigr) \ge 6$. Hence there are infinitely many integers that are a sum of two positive cubes in at least six ways, and they occur beyond every bound.*

*Proof.* Combine Theorem 5.7 with Corollary 4.2; for the unboundedness note $m^3 \cdot 24\,153\ldots \ge m$. $\blacksquare$

**Corollary 5.9 (bracket at $n = 6$).** $13\,750 \le \mathrm{Taxicab}(6) \le 24\,153\,319\,581\,254\,312\,065\,344$.

*Proof.* Theorem 5.4 with $n = 6$ gives $N \ge 110 \cdot 125 = 13\,750$; Theorem 5.7 gives the upper bound. $\blacksquare$

The bracket spans eighteen orders of magnitude. This is the quantitative case for believing that the true growth is exponential — that $\log \mathrm{Taxicab}(n)/n \to \infty$ — and, by Proposition 5.6, the case for looking outside elementary shell arguments to prove it.

---

## 6. Reduction of the unboundedness conjecture to arithmetic geometry

**Conjecture 6.1.** *For every $n$ there is a positive integer with at least $n$ representations as a sum of two positive cubes; equivalently, $\mathrm{Taxicab}(n)$ exists for all $n$.*

By Theorem 4.1 the elementary scaling operation cannot produce this: it transports representation sets but never enlarges them. The following two results show that the entire remaining difficulty is the production of rational points on one curve.

### 6.1 Clearing denominators

**Theorem 6.2 (signed transfer theorem).** *Let $q \in \mathbb{Q}$, $q > 0$, and let $S$ be a finite set of pairs $(x,y) \in \mathbb{Q}^2$ with $x \ne 0$, $y \ne 0$, $x \le y$ and $x^3 + y^3 = q$. Then there is a positive integer $M$ with $r^{\pm}(M) \ge |S|$.*

*Proof.* If $S = \varnothing$ take $M = 1$. Otherwise let
$$D = \prod_{(x,y) \in S} \mathrm{den}(x)\,\mathrm{den}(y) \in \mathbb{Z}_{\ge 1},$$
so that $Dx$ and $Dy$ are integers for every $(x,y) \in S$. For each such pair,
$$(Dx)^3 + (Dy)^3 = D^3(x^3 + y^3) = D^3 q,$$
a rational number independent of the pair; since it equals an integer combination of cubes it is an integer, and it is positive because $D^3 > 0$ and $q > 0$. Set $M = D^3 q \in \mathbb{Z}_{\ge 1}$. The map $(x,y) \mapsto (Dx, Dy)$ sends $S$ into $R^{\pm}(M)$: the coordinates are nonzero (a nonzero rational times $D > 0$), the ordering $Dx \le Dy$ is preserved, and the cube identity holds. It is injective because $D \ne 0$. Hence $r^{\pm}(M) \ge |S|$. $\blacksquare$

**Theorem 6.3 (positive transfer theorem).** *Let $S$ be a finite set of pairs $(x,y) \in \mathbb{Q}^2$ with $0 < x \le y$ and $x^3 + y^3 = q$ for a common $q$. Then there is a positive integer $M$ with $r(M) \ge |S|$.*

*Proof.* Identical, with $D$ as above; positivity of $x$ and $y$ makes $Dx, Dy$ positive integers, so the scaled points lie in $R(M)$ rather than merely $R^{\pm}(M)$. $\blacksquare$

**Corollary 6.4 (reduction of Conjecture 6.1).** *Suppose there exist $q \in \mathbb{Q}_{>0}$ and infinitely many distinct pairs $(x_k, y_k) \in \mathbb{Q}^2$ with $0 < x_k \le y_k$ and $x_k^3 + y_k^3 = q$. Then for every $n$ there is a positive integer $M$ with $r(M) \ge n$, i.e. Conjecture 6.1 holds. The same argument with merely nonzero coordinates yields the signed form of the conjecture.*

*Proof.* Apply Theorem 6.3 to $S = \{(x_k,y_k) : k < n\}$, a set of exactly $n$ elements by distinctness. $\blacksquare$

So the combinatorial half of the conjecture is free; the entire content is the existence of a single cubic with an infinite supply of rational points in the relevant region.

### 6.2 The chord–tangent engine

The affine cubic $x^3 + y^3 = q$ is a curve of genus one, birational to the Weierstrass curve $Y^2 = X^3 - 432 q^2$. Its rational points therefore carry a group law, realised geometrically: a line through two rational points meets the cubic in a third rational point, and the tangent at a rational point meets it again. Explicitly:

**Theorem 6.5 (tangent duplication identity).** *Let $x, y, N \in \mathbb{Q}$ with $x^3 + y^3 = N$ and $x^3 \ne y^3$. Put*
$$x' = \frac{x(x^3 + 2y^3)}{x^3 - y^3}, \qquad y' = \frac{-y(2x^3 + y^3)}{x^3 - y^3}.$$
*Then $(x')^3 + (y')^3 = N$.*

*Proof.* Write $u = x^3$, $v = y^3$; note $u \ne v$ by hypothesis. Clearing the common denominator $(u - v)^3$, the claim becomes the polynomial identity
$$u(u + 2v)^3 - v(2u + v)^3 = (u+v)(u-v)^3.$$
Both sides expand to $u^4 - 2u^3 v + 2 u v^3 - v^4$. $\blacksquare$

**Proposition 6.6 (the duplication genuinely moves).** *Let $x, y$ be rational with $x^3 \ne y^3$.*
1. *If $x \ne 0$ and $y \ne 0$ then $x' \ne x$.*
2. *If $x > 0$ and $y > 0$ then $x' \ne y$.*

*Proof.* (1) $x' = x$ means $x(x^3+2y^3) = x(x^3 - y^3)$, i.e. $3xy^3 = 0$, impossible for $x, y \ne 0$.
(2) $x' = y$ means $x(x^3 + 2y^3) = y(x^3 - y^3)$, i.e.
$$x^4 - x^3 y + 2xy^3 + y^4 = 0,$$
whose left-hand side is strictly positive for $x, y > 0$ (indeed $x^4 - x^3y + y^4 > 0$ always, because if $x \le y$ then $y^4 \ge x^3 y$, and if $x > y$ then $x^4 > x^3 y$). $\blacksquare$

Thus each duplication step produces a genuinely new unordered pair, and the orbit of a starting point never collapses in one step. What remains unproved — and this is precisely the arithmetic input Corollary 6.4 requires — is that the orbit is *infinite*, i.e. that the starting point is of infinite order in the Mordell–Weil group of the curve, and that infinitely many orbit members land in the positive quadrant.

**Example 6.7.** Start from $(1,2)$ on $x^3 + y^3 = 9$. The formulas give
$$x' = \frac{1\cdot(1 + 16)}{1 - 8} = -\frac{17}{7}, \qquad y' = \frac{-2(2+8)}{1-8} = \frac{20}{7},$$
and indeed $(-17)^3 + 20^3 = -4913 + 8000 = 3087 = 9 \cdot 7^3$, so $\left(-\tfrac{17}{7}\right)^3 + \left(\tfrac{20}{7}\right)^3 = 9$. Clearing denominators with $D = 7$, as in Theorem 6.2, sends the two rational points $(1,2)$ and $(-17/7, 20/7)$ to the integral points $(7,14)$ and $(-17,20)$ on $x^3 + y^3 = 3087$: indeed
$$3087 = 7^3 + 14^3 = 20^3 - 17^3,$$
a signed taxicab number produced entirely by the mechanism of Section 6. This is the transfer theorem in miniature.

---

## 7. Algorithms

Three computational procedures underpin the results, all of them justified by the localisation theorems of Sections 2 and 5.

**Algorithm A (representation enumeration).** To compute $R(N)$: for $b$ from $\lceil (N/2)^{1/3} \rceil$ to $\lfloor N^{1/3} \rfloor$, test whether $N - b^3$ is a positive perfect cube $a^3$ with $a \le b$; collect the hits. The shell of Lemma 5.2 reduces the loop length from $N^{1/3}$ to $(1 - 2^{-1/3}) N^{1/3} \approx 0.206\, N^{1/3}$, and each test is $O(\log N)$ by integer cube root. Total cost $O(N^{1/3} \log N)$.

**Algorithm B (signed representation enumeration).** To compute $R^{\pm}(N)$: by Theorem 2.1 every coordinate satisfies $|x| \le \lfloor \sqrt{N} \rfloor$. Loop over $b$ from $1$ to $\lfloor \sqrt N \rfloor$ and test whether $N - b^3$ is a (possibly negative) perfect cube $a^3$ with $a \le b$, $a \ne 0$. Cost $O(\sqrt N \log N)$ — quadratically worse than the positive case, and that asymmetry is exactly the price of the mixed-sign branch.

**Algorithm C (least $N$ with $n$ representations, by shell sieve).** To find $\mathrm{Taxicab}(n)$ or $\mathrm{Cabtaxi}(n)$ below a bound $B$: build a hash table keyed by cube sums, inserting $a^3 + b^3$ for all admissible $(a,b)$ with value below $B$ (the admissible range for $b$ being $b \le B^{1/3}$ in the positive case and $b \le \sqrt{B}$ in the signed case), then return the least key with multiplicity $\ge n$. Cost $O(B^{2/3})$ positive, $O(B)$ signed. The searches certifying $\mathrm{Taxicab}(2) = 1729$, $\mathrm{Cabtaxi}(2) = 91$ and $\mathrm{Cabtaxi}(3) = 728$ are instances with $B = 1729, 91, 728$ and search squares $[1,12]^2$, $[-9,9]^2$, $[-26,26]^2$ respectively.

**Algorithm D (rational orbit generation and transfer).** Given a rational point $(x_0,y_0)$ on $x^3+y^3=q$, iterate the duplication of Theorem 6.5 to obtain $(x_1,y_1), (x_2,y_2), \ldots$; take a common denominator $D$ of the first $n$ points and output $M = D^3 q$ together with the $n$ integer representations $(Dx_k, Dy_k)$. This is Corollary 6.4 made effective; its output is unconditional, and only the *count* depends on the orbit not repeating.

---

## 8. Discussion

**Finiteness as a theorem.** The recurring lesson is that every exhaustive computation in this subject rests on a prior geometric inequality. For positive representations, $b^3 \le N$ is immediate. For signed representations, it takes Theorem 2.1 — a factorisation of $b^3 - k^3$ — to close off the mixed-sign branch, and the resulting box has side $\sqrt{N}$ rather than $N^{1/3}$. The asymmetry is not an artefact: the signed problem genuinely has more points, as Proposition 3.6 shows at $N = 728$.

**Where the elementary theory stops.** Theorem 5.4 and Proposition 5.6 together pin the shell method exactly: it delivers $110(n-1)^3$, it cannot deliver more than $113.90(n-1)^3$, and the observed values grow far faster. This kind of ceiling result is useful precisely because it is negative: it identifies the ordering-plus-positivity input as inadequate and points the search for better bounds towards canonical heights on the associated elliptic curves, where growth of the smallest point of a given rank is genuinely exponential.

**Primitivity is the right invariant.** Theorem 4.1 says cube scaling is transparent; Theorem 4.3 says it is not exhaustive. Together they suggest that the natural object of study is the *primitive* representation count $r^{\mathrm{prim}}(N) = \#\{(a,b) \in R(N) : \gcd(a,b) = 1\}$, with $r(N) = \sum_{d^3 \mid N} r^{\mathrm{prim}}(N/d^3)$. Primitive representations of $N$ correspond to factorisations of $N$ in the Eisenstein integers $\mathbb{Z}[\omega]$, $\omega = e^{2\pi i/3}$, via $a^3 + b^3 = (a+b)(a + \omega b)(a + \omega^2 b)$; this is the arithmetic that the elementary theory cannot see.

**Signed versus unsigned.** Corollary 3.4 confirms at $n = 2$ that signs are cheaper, and $\mathrm{Cabtaxi}(3) = 728 \ll \mathrm{Taxicab}(3) = 87\,539\,319$ makes the same point far more dramatically at $n=3$. Yet both problems are governed by the same curve and the same group law, so one expects the *exponents* to agree asymptotically even though the constants differ wildly. Quantifying that expectation — showing that $\log \mathrm{Cabtaxi}(n)/\log \mathrm{Taxicab}(n) \to 1$, say — is an attractive concrete target.

---

## 9. Future work

1. **Unbounded representation counts.** Prove that some cubic $x^3 + y^3 = q$ has infinitely many rational points with positive coordinates. By Corollary 6.4 this immediately yields $\mathrm{Taxicab}(n)$ for all $n$. The natural approach is to exhibit $q$ for which the associated Mordell curve $Y^2 = X^3 - 432q^2$ has positive rank and a generator whose orbit meets the positive quadrant infinitely often.

2. **Super-polynomial growth.** Prove $\log \mathrm{Taxicab}(n)/n \to \infty$. Proposition 5.6 shows this cannot come from the shell method; the plausible route is a height argument, since points generated by chord–tangent operations have canonical heights growing geometrically, forcing the least common denominator, and hence the resulting integer, to grow at least exponentially in the number of representations.

3. **The primitive decomposition.** Establish Corollary 4.4's second term quantitatively: show that $\#\{(x,y) \in R(p^3 N) : p \nmid \gcd(x,y)\}$ is nonzero for infinitely many $N$ and each prime $p$, and describe it in terms of the factorisation of $N$ in $\mathbb{Z}[\omega]$.

4. **Signed versus unsigned exponents.** Prove that $\mathrm{Cabtaxi}(n) < \mathrm{Taxicab}(n)$ for every $n \ge 2$ (known here for $n = 2$, and true for $n = 3$ by the tabulated values), while showing that the two grow with the same exponential rate.

5. **Effective ceilings for other elementary methods.** The saturation analysis of Proposition 5.6 is a template: for each elementary constraint one adds (congruence conditions modulo $9$, say, or the structure of $\gcd(a,b)$), determine the fixed point of the resulting squeeze and hence the best constant obtainable. Mapping out which elementary inputs can and cannot break the cubic barrier would sharpen the case that the problem is irreducibly one of arithmetic geometry.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| A priori bound | Nonzero integral points of $x^3+y^3=N$, $N \ge 1$, satisfy $x^2 \le N$, $y^2 \le N$ |
| Hardy–Ramanujan | $R(1729) = \{(1,12),(9,10)\}$ and $r(N) \le 1$ for $N < 1729$ |
| Cabtaxi 2 | $R^{\pm}(91) = \{(-5,6),(3,4)\}$, minimal; $91 < 1729$ |
| Cabtaxi 3 | $R^{\pm}(728) = \{(-10,12),(-1,9),(6,8)\}$, minimal; $r(728)=1 < 3 = r^{\pm}(728)$ |
| Cube scaling | $m$-divisible part of $R(m^3N)$ $\leftrightarrow$ $R(N)$; hence $r(N) \le r(m^3N)$ |
| Cube-free core fails | $344 = 2^3\cdot 43$, $r(344) = 1 > 0 = r(43)$ |
| Growth floor | $r(N) \ge n \implies N \ge 110(n-1)^3$; in particular $N > n^3$ for $n \ge 2$ |
| Method ceiling | No shell argument can beat $\bigl(2^{1/3}/(2^{1/3}-1)\bigr)^3 = 113.8953\ldots$ |
| Transfer | Finitely many rational points on one cubic $\Rightarrow$ one integer with that many representations |
| Reduction | An infinite rational orbit in the positive quadrant implies $\mathrm{Taxicab}(n)$ exists for all $n$ |
| Witnesses | Explicit integers with $3,4,5,6$ representations; infinitely many with $6$ |
| Bracket at $n=6$ | $13\,750 \le \mathrm{Taxicab}(6) \le 24\,153\,319\,581\,254\,312\,065\,344$ |
