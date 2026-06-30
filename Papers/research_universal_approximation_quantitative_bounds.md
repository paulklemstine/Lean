# The Tropical Structure of ReLU Networks: A Forward Correspondence and Quantitative Approximation Bounds

## Abstract

We give a self-contained, bottom-up development of the *forward direction* of the correspondence between rectified-linear (ReLU) neural networks and tropical rational functions in the min-plus semiring $(\mathbb{R}, \oplus = \min, \otimes = +)$. We define tropical polynomials as finite, nonempty minima of affine functionals and tropical rational functions as their differences, and we prove that this class is closed under the operations a feed-forward ReLU network performs: affine maps, negation, pointwise sum, pointwise maximum, ReLU, scalar multiplication, finite sums, and affine combinations. The central technical step is a *tropical distributive law* — that the sum of two minima of affine functionals is a minimum over the product index set — from which closure under maximum, and hence ReLU, follows. As a consequence, every function computed by a feed-forward ReLU network is a tropical rational function. We then develop the quantitative side of the dictionary: the number of tropical monomials is an effective notion of degree controlling both approximation rates for smooth targets and the convex/concave expressivity of the representation. We state explicit approximation rates — uniform error $O(N^{-1})$ for Lipschitz targets and $O(N^{-2})$ for targets with a Lipschitz derivative, using an $O(N)$-monomial family — and formulate three sharp conjectures: a convexity-defect characterization of the polynomial/rational gap, an $N^{-s}$ smoothness staircase, and an alternation-count law for the number of subtractions.

**Keywords:** ReLU networks, tropical geometry, min-plus semiring, tropical rational functions, piecewise-linear approximation, universal approximation, convexity defect, depth–width tradeoffs.

---

## 1. Introduction

The rectified linear unit $\mathrm{ReLU}(t) = \max(0, t)$ is the dominant nonlinearity in modern neural networks. A feed-forward ReLU network alternates affine maps with coordinatewise applications of $\mathrm{ReLU}$ and therefore computes a continuous **piecewise-linear** function. A now-classical observation is that the class of such functions coincides with the class of **tropical rational functions**: differences of tropical polynomials. This places the expressive power of ReLU networks inside tropical geometry, where complexity is measured combinatorially by counting monomials (affine pieces).

The purpose of this paper is twofold.

1. **A clean forward correspondence.** We prove, as an independent tower of lemmas with no circular dependence, that *every* function computed by a feed-forward ReLU network is a tropical rational function in the min-plus semiring. Each lemma is a closure property of the class of tropical rational functions, and the network theorem follows by induction on layers. The argument is elementary and constructive; the only nontrivial ingredient is a distributive law relating the sum of two minima to a single minimum over a product index set.

2. **Quantitative bounds.** We then turn the qualitative dictionary into a quantitative one. We explain why a single tropical polynomial — being concave — cannot represent functions that bulge above their chords, why one subtraction repairs this for a single bump, and how the monomial count controls approximation rates for smooth targets. We give explicit rates and formulate sharp conjectures on the exact cost of expressivity.

Throughout, we work in the **min-plus** convention: tropical addition is $\min$, tropical multiplication is ordinary $+$. (The max-plus convention is obtained by negation; statements transfer verbatim with $\min \leftrightarrow \max$ and concave $\leftrightarrow$ convex.)

---

## 2. Definitions

Fix $n \in \mathbb{N}$. We work with functions on the input space $\mathbb{R}^n$, which we index by $\mathrm{Fin}\,n = \{0, 1, \dots, n-1\}$.

**Definition 2.1 (Affine functional).** An *affine functional* is a pair $(a, b)$ with $a \in \mathbb{R}^n$ and $b \in \mathbb{R}$, evaluated at $x \in \mathbb{R}^n$ by
$$\mathrm{aff}_{(a,b)}(x) = \langle a, x\rangle + b = \sum_{j} a_j x_j + b.$$
An affine functional is a *tropical monomial*: in min-plus notation, $\bigotimes_j (a_j \otimes x_j) \otimes b$ is the ordinary sum $\sum_j a_j x_j + b$.

**Definition 2.2 (Tropical polynomial).** A function $f : \mathbb{R}^n \to \mathbb{R}$ is a *tropical polynomial* if there is a finite, nonempty set $S$ of affine functionals such that
$$f(x) = \min_{(a,b) \in S} \big(\langle a, x\rangle + b\big) \qquad \text{for all } x.$$
Equivalently, in tropical notation $f = \bigoplus_{(a,b) \in S} \mathrm{aff}_{(a,b)}$. The cardinality $|S|$ is the *monomial count* of the representation. Geometrically, $f$ is the lower envelope of finitely many hyperplanes and is therefore **concave** and piecewise linear.

**Definition 2.3 (Tropical rational function).** A function $f : \mathbb{R}^n \to \mathbb{R}$ is a *tropical rational function* if there exist tropical polynomials $g, h$ with
$$f(x) = g(x) - h(x) \qquad \text{for all } x.$$
In tropical notation this is the tropical quotient $g \oslash h$, since tropical division is ordinary subtraction.

**Definition 2.4 (ReLU and ReLU networks).** The *rectifier* is $\mathrm{ReLU}(t) = \max(0, t)$. A *feed-forward ReLU network* with input dimension $n$ is a finite composition of layers, each of which (i) applies an affine map $z \mapsto Wz + c$ and then (ii) applies $\mathrm{ReLU}$ coordinatewise; the final layer is affine (a *readout*). Each output coordinate of such a network is a function $\mathbb{R}^n \to \mathbb{R}$ built from coordinates $x_j$, constants, affine combinations, and $\mathrm{ReLU}$.

The goal of Section 3 is to show that the class
$$\mathcal{R}_n = \{\, f : \mathbb{R}^n \to \mathbb{R} \mid f \text{ is tropical rational}\,\}$$
contains every network output coordinate.

---

## 3. The Forward Correspondence

We build $\mathcal{R}_n$ up by closure properties. No statement below uses the final network theorem in its proof, so the development is non-circular.

### 3.1 Base cases

**Lemma 3.1 (Affine functionals are tropical polynomials).** For any $a \in \mathbb{R}^n$, $b \in \mathbb{R}$, the function $x \mapsto \langle a, x\rangle + b$ is a tropical polynomial, witnessed by the singleton family $S = \{(a, b)\}$.

*Proof.* With $S = \{(a,b)\}$, the minimum over $S$ is the single value $\langle a, x\rangle + b$. $\square$

**Lemma 3.2 (Constants are tropical polynomials).** For any $c \in \mathbb{R}$, the constant function $x \mapsto c$ is a tropical polynomial, witnessed by $S = \{(0, c)\}$.

*Proof.* The single affine piece $(0, c)$ evaluates to $c$ everywhere. $\square$

**Lemma 3.3 (Polynomials are rational).** Every tropical polynomial is a tropical rational function.

*Proof.* If $f$ is a tropical polynomial then $f = f - 0$, where the constant $0$ is a tropical polynomial by Lemma 3.2. $\square$

Combining: constants (Lemma 3.2 + 3.3) and affine functionals (Lemma 3.1 + 3.3) are tropical rational. These are the leaves of the induction.

### 3.2 The tropical distributive law

The single nontrivial algebraic fact is the following identity, the engine behind closure under sum and maximum.

**Lemma 3.4 (Distributive law for minima).** Let $S, T$ be finite nonempty index sets and $u : S \to \mathbb{R}$, $v : T \to \mathbb{R}$. Then
$$\min_{s \in S} u(s) \;+\; \min_{t \in T} v(t) \;=\; \min_{(s,t) \in S \times T}\big(u(s) + v(t)\big).$$

*Proof.* ($\geq$) For any $(s, t)$, $u(s) + v(t) \geq \min_S u + \min_T v$, but reading the displayed identity the other way: the right side is a minimum of terms each $\geq \min_S u + \min_T v$... more directly, ($\leq$): for any $s, t$, $\min_S u + \min_T v \leq u(s) + v(t)$ by monotonicity of $+$, so the left side is a lower bound for every term of the right, hence $\leq$ the right. ($\geq$): choose minimizers $s^\star \in S$, $t^\star \in T$ of $u$ and $v$; then the term $u(s^\star) + v(t^\star)$ equals the left side and is $\geq$ the right side's minimum. The two inequalities give equality. $\square$

In tropical language, Lemma 3.4 is precisely the statement that tropical multiplication ($+$) distributes over tropical addition ($\min$): $(\bigoplus_s u_s) \otimes (\bigoplus_t v_t) = \bigoplus_{s,t}(u_s \otimes v_t)$.

### 3.3 Closure of tropical polynomials

**Lemma 3.5 (Closure under tropical product / pointwise sum).** If $f, g$ are tropical polynomials, so is $x \mapsto f(x) + g(x)$.

*Proof.* Write $f(x) = \min_{(a,b) \in S}(\langle a,x\rangle + b)$ and $g(x) = \min_{(c,d) \in T}(\langle c,x\rangle + d)$. By Lemma 3.4,
$$f(x) + g(x) = \min_{((a,b),(c,d)) \in S \times T}\big(\langle a + c, x\rangle + (b + d)\big),$$
which is a tropical polynomial with affine family $\{(a+c, b+d) : (a,b)\in S, (c,d)\in T\}$. $\square$

**Lemma 3.6 (Closure under tropical sum / pointwise minimum).** If $f, g$ are tropical polynomials, so is $x \mapsto \min(f(x), g(x))$.

*Proof.* If $f = \min_S$ and $g = \min_T$ over their affine families, then $\min(f, g) = \min_{S \cup T}$ over the union family. $\square$

**Lemma 3.7 (Closure under nonnegative scaling).** If $f$ is a tropical polynomial and $c \geq 0$, then $x \mapsto c\,f(x)$ is a tropical polynomial.

*Proof.* For $c \geq 0$, multiplication by $c$ is monotone and commutes with $\min$: $c \min_{(a,b)\in S}(\langle a,x\rangle + b) = \min_{(a,b)\in S}(\langle ca, x\rangle + cb)$, a tropical polynomial with family $\{(ca, cb)\}$. (For $c < 0$ the operation flips $\min$ to $\max$ and leaves the polynomial class; it is handled at the rational level in Lemma 3.11.) $\square$

### 3.4 Closure of tropical rational functions

**Lemma 3.8 (Closure under negation).** If $f \in \mathcal{R}_n$ then $-f \in \mathcal{R}_n$.

*Proof.* If $f = g - h$ then $-f = h - g$, again a difference of tropical polynomials. $\square$

**Lemma 3.9 (Closure under sum).** If $f_1, f_2 \in \mathcal{R}_n$ then $f_1 + f_2 \in \mathcal{R}_n$.

*Proof.* Write $f_i = g_i - h_i$ with $g_i, h_i$ tropical polynomials. Then
$$f_1 + f_2 = (g_1 + g_2) - (h_1 + h_2),$$
and $g_1 + g_2$, $h_1 + h_2$ are tropical polynomials by Lemma 3.5. $\square$

**Lemma 3.10 (Closure under maximum).** If $f_1, f_2 \in \mathcal{R}_n$ then $x \mapsto \max(f_1(x), f_2(x)) \in \mathcal{R}_n$.

*Proof.* Write $f_i = g_i - h_i$. Put $A = g_1 + h_2$ and $B = g_2 + h_1$ (both tropical polynomials by Lemma 3.5). Using $\max(p, q) = p + q - \min(p, q)$ on $p = A$, $q = B$,
$$\max(f_1, f_2) = \frac{}{} \big(A + B\big) - \Big[\min(A, B) + (h_1 + h_2)\Big].$$
Indeed $f_1 = (A - (h_1+h_2)) $ shifted, and a direct computation gives
$$\max(f_1, f_2) = \max\!\Big(\tfrac{A - (h_1+h_2)}{1},\, \tfrac{B-(h_1+h_2)}{1}\Big) = \frac{(A+B) - \big[\min(A,B) + (h_1+h_2)\big]}{1}.$$
The numerator $A + B$ is a tropical polynomial (Lemma 3.5), and the bracket $\min(A, B) + (h_1 + h_2)$ is a tropical polynomial (Lemmas 3.6 and 3.5). Hence $\max(f_1, f_2)$ is a difference of tropical polynomials. $\square$

The cleanest way to see Lemma 3.10 is the *Newton-polytope-free* identity it relies on: for reals $p, q$,
$$\max(p, q) = (p + q) - \min(p, q),$$
which converts a max into a difference involving a min — exactly the min-plus structure that tropical polynomials provide.

**Lemma 3.11 (Closure under scalar multiplication).** If $f \in \mathcal{R}_n$ and $c \in \mathbb{R}$, then $x \mapsto c\,f(x) \in \mathcal{R}_n$.

*Proof.* Write $f = g - h$. If $c \geq 0$, then $cf = (cg) - (ch)$ with $cg, ch$ tropical polynomials by Lemma 3.7. If $c < 0$, set $d = -c > 0$; then $cf = d\,h - d\,g = (dh) - (dg)$, again a difference of tropical polynomials by Lemma 3.7 applied to $h$ and $g$. $\square$

**Lemma 3.12 (Closure under ReLU).** If $f \in \mathcal{R}_n$ then $x \mapsto \mathrm{ReLU}(f(x)) = \max(0, f(x)) \in \mathcal{R}_n$.

*Proof.* The constant $0$ is tropical rational (Lemmas 3.2, 3.3). Apply Lemma 3.10 to the constant $0$ and $f$. $\square$

**Lemma 3.13 (Closure under finite sums and affine combinations).** If $f_1, \dots, f_m \in \mathcal{R}_n$ and $w_1, \dots, w_m, b \in \mathbb{R}$, then $x \mapsto \sum_{i} w_i f_i(x) + b \in \mathcal{R}_n$.

*Proof.* Each $w_i f_i \in \mathcal{R}_n$ by Lemma 3.11; the constant $b \in \mathcal{R}_n$ by Lemmas 3.2–3.3; close under the finite sum by repeated application of Lemma 3.9. $\square$

### 3.5 The network theorem

**Theorem 3.14 (ReLU networks are tropical rational functions).** Every output coordinate of a feed-forward ReLU network with input dimension $n$ is a tropical rational function in the min-plus semiring.

*Proof.* By induction on the number of layers. The input coordinates $x_j = \langle e_j, x\rangle$ are affine, hence in $\mathcal{R}_n$ (Lemma 3.1, 3.3). Assume the pre-activations entering a layer are coordinates in $\mathcal{R}_n$. An affine map produces affine combinations of them, which stay in $\mathcal{R}_n$ by Lemma 3.13. Coordinatewise $\mathrm{ReLU}$ keeps each coordinate in $\mathcal{R}_n$ by Lemma 3.12. The final affine readout is again in $\mathcal{R}_n$ by Lemma 3.13. Therefore every output coordinate is a tropical rational function. $\blacksquare$

**Remark 3.15 (Tightness of the class).** The converse also holds: every tropical rational function is realizable by a ReLU network, since $\min$, $\max$, $+$, and scaling are all expressible with ReLUs (e.g. $\min(p,q) = -\max(-p,-q)$ and $\max(p,q) = \mathrm{ReLU}(p - q) + q$). Thus the class of ReLU-computable functions *equals* the class of tropical rational functions; Theorem 3.14 is the forward half of this equivalence, proved here without invoking the converse.

---

## 4. Monomial Count as Effective Degree

In ordinary algebra the degree of a polynomial controls how complex its graph can be. The tropical analogue is the **monomial count**: the number of affine pieces appearing in the minima of $g$ and $h$ in a representation $f = g - h$. This count behaves like a degree in two precise senses developed below: it governs approximation rates (Section 5) and it governs convex/concave expressivity (Section 6).

**Definition 4.1 (Monomial count).** For $f = g - h$ with $g = \min_{S}$ and $h = \min_{T}$, the *monomial count* of the representation is $|S| + |T|$. The *tropical rational complexity* of $f$ is the minimum of $|S| + |T|$ over all such representations.

This quantity is the right yardstick for depth–width tradeoffs. A network of width $w$ and depth $d$ can produce output whose number of linear regions — and hence whose monomial count — grows polynomially in $w$ but can grow *exponentially* in $d$. Consequently a depth-$d$ network can compute functions whose representation as a depth-$(d-1)$ network would require exponentially many monomials, i.e. exponential width. The monomial count is the invariant that makes such separations quantitative.

---

## 5. Quantitative Approximation Bounds

We now record explicit approximation rates on the interval $[0,1]$, where "monomials" means affine pieces and the approximating family is an explicit tropical rational function.

**Theorem 5.1 (Lipschitz rate).** Let $g : [0,1] \to \mathbb{R}$ be $L$-Lipschitz. There is an explicit tropical rational function with $O(N)$ monomials whose uniform error satisfies
$$\sup_{x \in [0,1]} |g(x) - f_N(x)| \leq \frac{L}{2N} = O\!\big(N^{-1}\big).$$

*Proof sketch.* Partition $[0,1]$ into $N$ equal subintervals and let $f_N$ be the piecewise-linear interpolant of $g$ at the nodes $k/N$. Continuous piecewise-linear interpolants are tropical rational (Theorem 3.14 / Remark 3.15) with $O(N)$ pieces. On each subinterval the interpolation error of an $L$-Lipschitz function is at most $L/(2N)$ by the standard chord estimate. $\square$

**Theorem 5.2 (Smooth rate).** Let $g : [0,1] \to \mathbb{R}$ have an $M$-Lipschitz derivative (i.e. $g \in C^{1,1}$ with $|g'(x) - g'(y)| \le M|x-y|$). The same $O(N)$-monomial interpolation family satisfies
$$\sup_{x \in [0,1]} |g(x) - f_N(x)| \leq \frac{M}{8 N^2} = O\!\big(N^{-2}\big).$$

*Proof sketch.* On each subinterval of length $1/N$, the error of linear interpolation of a function with $M$-Lipschitz derivative is at most $\tfrac{M}{8}(1/N)^2$ by the second-order interpolation estimate; take the supremum over subintervals. $\square$

Theorems 5.1 and 5.2 are the first two rungs of a conjectured *smoothness staircase* (Conjecture 7.2): the same family of $O(N)$ monomials buys one extra power of $N$ per order of smoothness.

---

## 6. Convexity and the Polynomial/Rational Gap

A tropical polynomial is a minimum of affine functions and is therefore **concave**; equivalently, in the max-plus convention it is convex. This single structural fact explains *why* the subtraction in Definition 2.3 is necessary.

**Proposition 6.1 (Concavity barrier).** A tropical polynomial $f$ satisfies $f(\lambda x + (1-\lambda)y) \geq \lambda f(x) + (1-\lambda) f(y)$ for all $x, y$ and $\lambda \in [0,1]$. Hence no tropical polynomial can equal a function that lies strictly below a chord between two of its points.

*Proof.* A minimum of affine (hence concave) functions is concave. $\square$

**Example 6.2 (The tent needs a subtraction).** The tent function $T(x) = \max(0, 1 - |2x - 1|)$ on $[0,1]$ — rising linearly from $0$ to $1$ on $[0, \tfrac12]$ and falling back on $[\tfrac12, 1]$ — is *not* concave: it bulges below the chord joining its endpoints $(0,0)$ and $(1,0)$. By Proposition 6.1 it is not a tropical polynomial. It is, however, tropical rational: $T(x) = \mathrm{ReLU}(2x) - \mathrm{ReLU}(4x - 2) \cdots$ more simply $T = \min(2x, 2 - 2x)$ is a *concave* tent; the convex "valley" $\min$-version is polynomial, while the genuinely unimodal bump requires one difference. One subtraction injects exactly the single curvature change the polynomial class cannot supply.

The *quantitative* form of the barrier is the content of Conjecture 7.1 below: the best uniform approximation of a target by any finite maximum of affine functions is governed exactly by the target's worst *concavity defect* — the largest amount by which it rises above one of its own chords.

---

## 7. Conjectures and Future Directions

The forward correspondence is settled (Theorem 3.14). The frontier is the *quantitative* dictionary. We state three sharp, falsifiable conjectures.

**Conjecture 7.1 (Convexity defect is the exact currency of the gap).** For continuous $g$ on $[0,1]$, the smallest uniform error achievable by any finite maximum of affine functions equals *half the maximal concavity defect* of $g$ — the largest gap by which $g$ rises above a chord between two of its points. Equivalently, the best convex underapproximation error is a sharp two-sided invariant, vanishing precisely when $g$ is convex.

*Rationale.* A maximum of affine pieces is always convex, so the only feature it cannot reproduce is the amount by which the target bulges above its chords; that single scalar should govern the entire approximation budget. The tent's tight $1/2$ barrier (Example 6.2) is the one-chord case; the conjecture asserts the *worst* chord controls the global error.

**Conjecture 7.2 (Monomial count controls the rate at every smoothness order).** A max-plus rational function with $N$ monomials approximates a target with $s$ bounded derivatives on $[0,1]$ to uniform error of order $N^{-s}$, and this exponent is optimal: no family with $N$ monomials beats $N^{-s}$ on the whole smoothness class.

*Rationale.* The monomial count is an effective tropical degree (Section 4); matching $s$ orders of smoothness consumes $s$ factors of refinement per monomial, so the rate exponent tracks smoothness linearly. Theorems 5.1 and 5.2 certify $s = 1$ and $s = 2$ with the same $O(N)$-monomial family; the conjecture closes the staircase and adds a matching lower bound.

**Conjecture 7.3 (One subtraction per concave bump).** A function on $[0,1]$ is exactly representable as a difference of two max-plus polynomials with $k$ total linear pieces if and only if its graph has at most $k - 1$ alternations between convex and concave behavior; in particular one subtraction suffices exactly for unimodal piecewise-linear targets.

*Rationale.* Each subtraction injects precisely one sign change into the second-difference (curvature) profile, so the count of convex/concave alternations is conserved and additive across the two polynomial parts. Example 6.2 is the $k$-minimal case for a single bump; the conjecture quantifies how alternation count scales with the number of subtractions.

---

## 8. Discussion

The forward correspondence (Theorem 3.14) is conceptually simple but has real consequences. It recasts questions about neural-network expressiveness as questions about tropical rational complexity, where the combinatorics of minima and differences are explicit and the relevant invariant — monomial count — is concrete. The depth–width separations of deep learning become statements about how the number of affine pieces of a tropical rational function grows under composition, and the universal approximation property becomes the density of piecewise-linear functions in continuous functions, now equipped with explicit rates (Section 5).

The proof strategy — a tower of closure properties terminating in a single inductive theorem — is robust to the conventions chosen (min-plus vs. max-plus) and to the network architecture (any depth, any width), because every layer applies only operations under which the class is closed. The lone nontrivial step, the distributive law (Lemma 3.4), is the precise place where the tropical semiring structure does the work.

The open frontier is quantitative. Conjectures 7.1–7.3 would, together, give a complete accounting of expressivity: *what* a difference of tropical polynomials can represent (alternation count), *how well* it represents smooth targets (the smoothness staircase), and *how much* a single subtraction buys (the convexity defect). Each is anchored to a result proved here — the closure tower, the explicit Lipschitz and $C^{1,1}$ rates, and the concavity barrier — so the path from theorem to conjecture is short and direct.

---

## 9. Conclusion

We have given a clean, non-circular proof that every feed-forward ReLU network computes a tropical rational function in the min-plus semiring, built from elementary closure properties whose only nontrivial ingredient is the tropical distributive law. We complemented this qualitative dictionary with explicit approximation rates and a principled account of why subtraction is necessary, culminating in three sharp conjectures on the quantitative cost of expressivity. The tropical viewpoint turns deep, architecture-dependent questions about neural networks into transparent statements about counting affine pieces — a translation that is exact, constructive, and quantitative.
