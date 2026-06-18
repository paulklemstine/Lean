# Tropical Amoebas and Ronkin Functions: A Computation-Free Core via Maslov Dequantization

## Abstract

The *amoeba* of a Laurent polynomial `f` over the complex torus `(\mathbb{C}^*)^n`
is the image of its zero set under the coordinatewise logarithm-of-modulus map.
Amoebas occupy the interface between complex algebraic geometry, convex geometry,
and tropical geometry: their complement components are convex, their asymptotic
"tentacles" are governed by the Newton polytope, and their geometric backbone is a
piecewise-linear tropical hypersurface. The analytic bridge between these worlds
is the *Ronkin function*, a convex function that is affine with integer slope on
each complement component.

This paper develops a *computation-free* core of amoeba theory: the parts of the
theory that can be stated and proved without computing any integrals or invoking
heavy complex-analytic machinery, and which therefore admit a fully rigorous,
formally verified treatment. We prove that (i) the **tropical polynomial**
(amoeba spine) `\operatorname{trop} f(x) = \max_i (\log|c_i| + \langle m_i,
x\rangle)` is convex and piecewise-linear; (ii) each **dominance region** of the
spine (a connected piece of the amoeba complement, asymptotically) is convex and
carries a constant integer slope — the **order map** — equal to the exponent
vector of the dominant monomial; and (iii) the **Maslov-deformed Ronkin
function** `R_t(x) = t\log\sum_i \exp(A_i(x)/t)`, with `A_i(x) = \log|c_i| +
\langle m_i, x\rangle`, is convex for every `t > 0` and converges to the spine as
`t \to 0^+` with the explicit, uniform rate `|R_t - \operatorname{trop} f| \le
t\log N`, where `N` is the number of monomials of `f`. The last statement is a
concrete realization of **Maslov dequantization**: the tropical max-plus
semiring is the zero-temperature limit of the ordinary plus-times semiring, with
log-sum-exp as the deformation and `t` as the inverse temperature.

We give full statements, proof sketches, supporting algorithms, applications to
optimization and machine learning, and a set of falsifiable future directions
(strict convexity transverse to the recession cone, Legendre duality with the
Newton polytope, and a quantitative tentacle count).

---

## 1. Introduction

### 1.1 Amoebas as shadows of varieties

Let `f \in \mathbb{C}[z_1^{\pm 1}, \dots, z_n^{\pm 1}]` be a Laurent polynomial,
written
$$f(z) = \sum_{i=1}^N c_i\, z^{m_i}, \qquad c_i \in \mathbb{C}^*,\ m_i \in
\mathbb{Z}^n,$$
where `z^{m} = z_1^{m_1}\cdots z_n^{m_n}`. Its zero set `V(f) \subset
(\mathbb{C}^*)^n` is a complex hypersurface. The **logarithm map**
$$\operatorname{Log} : (\mathbb{C}^*)^n \to \mathbb{R}^n, \qquad
\operatorname{Log}(z) = (\log|z_1|, \dots, \log|z_n|),$$
collapses the angular (phase) directions and records only the radial sizes,
logarithmically. The **amoeba** of `f` is
$$\mathcal{A}_f := \operatorname{Log}(V(f)) \subseteq \mathbb{R}^n.$$
(The "negative-logarithm" convention `-\operatorname{Log}` used in some sources
merely reflects the amoeba through the origin and changes nothing essential; we
use the standard `\operatorname{Log}` throughout.)

Gelfand, Kapranov, and Zelevinsky introduced amoebas in 1994. Two structural
facts make them central objects:

- **Convex complement (Forsberg–Passare–Tsikh).** Each connected component of
  `\mathbb{R}^n \setminus \mathcal{A}_f` is convex and is indexed by a lattice
  point of the Newton polytope `\Delta_f = \operatorname{conv}\{m_i\}`.
- **Tropical backbone.** The amoeba retracts onto a piecewise-linear complex, its
  *spine*, which is (up to scaling deformations) the tropical hypersurface of the
  tropicalization of `f`.

### 1.2 The Ronkin function

The analytic glue is the **Ronkin function**
$$N_f(x) = \frac{1}{(2\pi i)^n}\int_{\operatorname{Log}^{-1}(x)} \log|f(z)|\,
\frac{dz_1}{z_1}\cdots\frac{dz_n}{z_n}.$$
Ronkin proved that `N_f` is convex on `\mathbb{R}^n`, and that on each complement
component `E` of `\mathcal{A}_f` it is *affine*, `N_f(x)|_E = \langle \nu_E, x
\rangle + \text{const}`, with `\nu_E \in \mathbb{Z}^n` the order (the lattice
point indexing `E`). The gradient `\nabla N_f` is the **order map**; it is locally
constant on the complement and takes values in `\Delta_f \cap \mathbb{Z}^n`.

### 1.3 Maslov dequantization

The **max-plus (tropical) semiring** `(\mathbb{R} \cup \{-\infty\}, \max, +)`
arises from the ordinary semiring `(\mathbb{R}_{\ge 0}, +, \times)` by the
"Maslov dequantization":
$$a \oplus_t b := t\log\!\big(e^{a/t} + e^{b/t}\big) \xrightarrow{t \to 0^+}
\max(a, b), \qquad a \odot b := a + b.$$
The parameter `t` plays the role of a temperature (or `\hbar`); the tropical
limit is the zero-temperature / semiclassical limit. The function
`\operatorname{LSE}_t(A_1, \dots, A_N) = t\log\sum_i e^{A_i/t}` is the deformed
"sum," and tropicalizing a polynomial replaces sums by maxima and products by
sums:
$$f = \sum_i c_i z^{m_i} \rightsquigarrow \operatorname{trop} f(x) = \max_i
\big(\log|c_i| + \langle m_i, x\rangle\big).$$

### 1.4 Contributions

We isolate and formally prove the *computation-free core* of this circle of
ideas — the statements that require neither evaluating the Ronkin integral nor the
full Forsberg–Passare–Tsikh machinery, yet capture the essential geometry:

1. **Convexity and piecewise-linearity of the spine** (Theorem 1).
2. **Convexity and constant integer slope of dominance regions** — the order map
   (Theorem 2, `tropPoly_slope_on_dominant`).
3. **Convexity of the Maslov-deformed Ronkin function for all `t > 0`**
   (Theorem 3, `ronkinDeform_convexOn`), via finite Hölder.
4. **Uniform dequantization rate** `|R_t - \operatorname{trop} f| \le t\log N`
   (Theorem 4), realizing Maslov dequantization in the amoeba setting.

These results connect to and extend two neighboring developments: the
zero-temperature semiclassical limit of statistical mechanics (free energy →
ground-state energy at rate `O(\log|\Omega|/\beta)`), and the convexity and gap
analysis of log-sum-exp.

---

## 2. Definitions

Throughout, fix the support data of `f`: a finite index set `i \in \{1, \dots,
N\}`, coefficients `c_i \in \mathbb{C}^*`, and exponents `m_i \in \mathbb{Z}^n`.
Write `a_i := \log|c_i| \in \mathbb{R}` and define the affine forms
$$A_i(x) := a_i + \langle m_i, x\rangle, \qquad x \in \mathbb{R}^n.$$

**Definition 2.1 (Tropical polynomial / amoeba spine).**
$$\operatorname{trop} f(x) := \max_{1 \le i \le N} A_i(x) = \max_i\big(\log|c_i|
+ \langle m_i, x\rangle\big).$$

**Definition 2.2 (Dominance region).** For an index `k`, the (open) **dominance
region** of `k` is
$$D_k := \{x \in \mathbb{R}^n : A_k(x) > A_j(x)\ \text{for all } j \ne k\}.$$
On `D_k`, the maximum defining the spine is uniquely attained at `k`.

**Definition 2.3 (Order map).** The **order map** `\operatorname{ord} : \bigcup_k
D_k \to \mathbb{Z}^n` sends `x \in D_k` to `m_k`. Equivalently, where the spine is
differentiable, `\operatorname{ord}(x) = \nabla(\operatorname{trop} f)(x)`.

**Definition 2.4 (Maslov-deformed Ronkin function).** For `t > 0`,
$$R_t(x) := t\,\log\!\Big(\sum_{i=1}^N \exp\!\big(A_i(x)/t\big)\Big).$$
This is the log-sum-exp ("softmax") deformation of the spine; it is a deformed
Ronkin function whose `t \to 0^+` limit is `\operatorname{trop} f`.

**Definition 2.5 (Newton polytope).** `\Delta_f := \operatorname{conv}\{m_1,
\dots, m_N\} \subset \mathbb{R}^n`. Its lattice points index the complement
components; the order map takes values among them.

---

## 3. Main results

### Theorem 1 (Convexity and piecewise-linearity of the spine)

*The tropical polynomial `\operatorname{trop} f` is convex on `\mathbb{R}^n`, and
piecewise-linear: `\mathbb{R}^n` is covered by finitely many polyhedral regions on
each of which `\operatorname{trop} f` agrees with a single affine form `A_i`.*

**Proof sketch.** Each `A_i(x) = a_i + \langle m_i, x\rangle` is affine, hence
convex. The pointwise maximum of finitely many convex functions is convex:
for `x, y` and `\lambda \in [0,1]`,
$$\operatorname{trop} f(\lambda x + (1-\lambda)y) = \max_i A_i(\lambda x +
(1-\lambda)y) = \max_i\big(\lambda A_i(x) + (1-\lambda)A_i(y)\big)$$
$$\le \lambda \max_i A_i(x) + (1-\lambda)\max_i A_i(y) = \lambda
\operatorname{trop} f(x) + (1-\lambda)\operatorname{trop} f(y).$$
For piecewise-linearity, partition `\mathbb{R}^n` by which index attains the
maximum; the closure of each nonempty `\{x : A_i(x) = \max_j A_j(x)\}` is a
polyhedron (a finite intersection of half-spaces `A_i \ge A_j`), and on it
`\operatorname{trop} f = A_i`. ∎

### Theorem 2 (Order map: convex dominance regions with constant integer slope)

*For each `k`, the dominance region `D_k` is open and convex, and on `D_k` one
has `\operatorname{trop} f = A_k`. Consequently `\operatorname{trop} f` is affine
on `D_k` with constant gradient `m_k \in \mathbb{Z}^n`; that is, the order map is
constant `= m_k` on `D_k`.* (Formal name: `tropPoly_slope_on_dominant`.)

**Proof sketch.** `D_k = \bigcap_{j \ne k} \{x : A_k(x) - A_j(x) > 0\}`. Each
factor is an open half-space (the strict super-level set of the affine form `A_k -
A_j`), and a finite intersection of open convex sets is open and convex. On `D_k`,
by definition `A_k(x) > A_j(x)` for all `j \ne k`, so `\max_j A_j(x) = A_k(x)`,
i.e. `\operatorname{trop} f|_{D_k} = A_k|_{D_k}`. Since `A_k(x) = a_k + \langle
m_k, x\rangle`, its gradient is the constant integer vector `m_k`. ∎

**Remark (Geometric meaning).** The `D_k` are, asymptotically, the connected
components of the complement of the amoeba spine; the unbounded `D_k` correspond
to the amoeba's *tentacles*. The slopes `m_k` are vertices of the Newton polytope
`\Delta_f`, so the order map realizes the Forsberg–Passare–Tsikh indexing
"complement components ↔ lattice points of `\Delta_f`" at the level of the
tropical spine. This is the computation-free shadow of the Ronkin theorem that
`\nabla N_f` is locally constant and integer-valued off the amoeba.

### Theorem 3 (Convexity of the deformed Ronkin function)

*For every `t > 0`, the Maslov-deformed Ronkin function `R_t(x) = t\log\sum_i
\exp(A_i(x)/t)` is convex on `\mathbb{R}^n`.* (Formal name:
`ronkinDeform_convexOn`.)

**Proof sketch.** It suffices to prove that the log-sum-exp map `L(u) =
\log\sum_i e^{u_i}` is convex and nondecreasing in each coordinate, and that `R_t`
is its composition with the affine map `x \mapsto (A_1(x)/t, \dots, A_N(x)/t)`
followed by multiplication by `t > 0`; composition of a convex nondecreasing
function with affine maps preserves convexity. Convexity of `L` is the finite
**Hölder inequality**: for `x, y` and `\lambda \in [0,1]`, with `p = 1/\lambda`,
`q = 1/(1-\lambda)`,
$$\sum_i e^{\lambda u_i + (1-\lambda) v_i} = \sum_i \big(e^{u_i}\big)^{\lambda}
\big(e^{v_i}\big)^{1-\lambda} \le \Big(\sum_i e^{u_i}\Big)^{\lambda}
\Big(\sum_i e^{v_i}\Big)^{1-\lambda},$$
which is exactly the weighted power-mean inequality `\sum_i p_i q_i \le (\sum_i
p_i)^{\lambda}(\sum_i q_i)^{1-\lambda}` (`Finset.inner_le_weight_mul_Lp` in the
finite case). Taking `\log` yields `L(\lambda u + (1-\lambda)v) \le \lambda L(u) +
(1-\lambda)L(v)`. Substituting `u = A(x)/t`, `v = A(y)/t` and multiplying by `t`
gives convexity of `R_t`. ∎

### Theorem 4 (Uniform Maslov dequantization rate)

*Let `N` be the number of monomials. For every `t > 0` and every `x \in
\mathbb{R}^n`,*
$$0 \le R_t(x) - \operatorname{trop} f(x) \le t\log N.$$
*In particular `R_t \to \operatorname{trop} f` uniformly on `\mathbb{R}^n` as `t
\to 0^+`.*

**Proof sketch.** Write `M(x) = \operatorname{trop} f(x) = \max_i A_i(x)`. Lower
bound: every summand is positive, so `\sum_i e^{A_i(x)/t} \ge e^{M(x)/t}`, hence
`R_t(x) = t\log\sum_i e^{A_i/t} \ge t\cdot M(x)/t = M(x)`. Upper bound: each
`A_i(x) \le M(x)`, so `\sum_i e^{A_i(x)/t} \le N e^{M(x)/t}`, and therefore
$$R_t(x) \le t\log\big(N e^{M(x)/t}\big) = M(x) + t\log N.$$
Combining, `0 \le R_t(x) - M(x) \le t\log N`. The bound is independent of `x`, so
convergence is uniform; sending `t \to 0^+` gives `R_t \to \operatorname{trop} f`.
∎

**Remark (Sharpness).** Both bounds are attained: the lower bound at points where
one monomial strictly dominates (the other terms become negligible as `t \to
0^+`), and the upper bound at the most balanced points, where all `N` forms tie
(`A_1(x) = \dots = A_N(x)`), giving exactly `R_t = M + t\log N`. The "hottest"
points of the deformation are precisely the deepest vertices of the spine.

### Corollary 5 (Convexity of the limit, recovered)

*Theorem 4 gives a second proof that `\operatorname{trop} f` is convex: it is a
uniform limit of the convex functions `R_t` (Theorem 3), and a pointwise limit of
convex functions is convex.*

---

## 4. Algorithms

The computation-free core is also computation-*friendly*: every object above is
finitely presented by the support data `\{(a_i, m_i)\}`.

**Algorithm A — Evaluate the spine and the order map.**
Input: support `\{(a_i, m_i)\}`, point `x`. Compute `A_i = a_i + \langle m_i, x
\rangle` for all `i`; return `\max_i A_i` (the spine value) and `\arg\max_i A_i`
(the dominant index; its `m_i` is the order). Cost `O(Nn)`. If the argmax is
unique, `x` lies in the interior of a dominance region; ties locate the spine.

**Algorithm B — Evaluate the deformed Ronkin function stably.**
Input: support, point `x`, temperature `t > 0`. Compute `A_i`, let `M = \max_i
A_i`, and return `M + t\log\sum_i \exp((A_i - M)/t)`. Subtracting `M` (the
log-sum-exp trick) prevents overflow and exposes the bound `0 \le R_t - M \le
t\log N` directly. Cost `O(Nn)`.

**Algorithm C — Certified dequantization schedule.**
Input: support, target accuracy `\varepsilon > 0`. Output: any `t \le
\varepsilon/\log N` (for `N \ge 2`). By Theorem 4 this guarantees `|R_t(x) -
\operatorname{trop} f(x)| \le \varepsilon` for *all* `x` simultaneously — a
uniform, certified approximation of the sharp tropical spine by the smooth
deformation.

**Algorithm D — Order-map labeling of complement regions.**
Sample `x` on a grid; for each sample compute the dominant index via Algorithm A
and record its exponent `m_k`. Connected sets of grid points sharing a label
approximate the dominance regions `D_k`; the distinct labels that appear are
exactly the visible lattice points of the Newton polytope, and the unbounded
labeled regions count the tentacles.

---

## 5. Applications

**5.1 Optimization via tropicalization.** Theorems 1–2 turn questions about the
complex zero set into questions about a convex, piecewise-linear function and its
polyhedral subdivision. Minimizing or analyzing `\operatorname{trop} f` is a
linear-programming-type problem; the order map gives the active monomial as a
certificate of optimality, exactly as a basic feasible solution does in LP.

**5.2 Machine learning: temperature and confidence.** `R_t` is the temperature-`t`
softmax/log-sum-exp. Theorem 3 is the convexity that underlies softmax-based
losses, and Theorem 4 is the precise statement that *a low-temperature softmax is
a faithful surrogate for the hard maximum*, with uniform error `t\log N`. Algorithm
C is a principled temperature schedule: to approximate an argmax decision over `N`
options to additive accuracy `\varepsilon`, take `t \le \varepsilon/\log N`. This
also bounds the "confidence inflation" of softmax outputs relative to the true
max.

**5.3 Statistical mechanics and the semiclassical limit.** Identifying `\beta =
1/t`, `R_t` is `(\,$-$\,)` the free energy of a system whose energy levels are
`-A_i(x)`, and Theorem 4 is the zero-temperature limit (free energy → ground-state
energy) with rate `O(\log N / \beta)`. This is the same dequantization phenomenon
that governs tropical statistical mechanics, here cast geometrically: the amoeba
spine is the ground-state landscape, and the Ronkin deformation is its
finite-temperature smoothing.

**5.4 Certified geometry of varieties.** Because the core avoids the Ronkin
integral, all of the above is constructive and verifiable: the spine, the order
map, and the dequantization bound are computed from finite data with explicit
error control, giving certified statements about the asymptotic geometry of
`V(f)` (its complement components, tentacle directions, and Newton-polytope
combinatorics).

---

## 6. Discussion

The guiding principle is a *separation of concerns*: the deep analytic content of
amoeba theory lives in the Ronkin integral and the Forsberg–Passare–Tsikh
theorem, but the *geometric skeleton* — convexity, piecewise-linearity, integer
slopes, and the dequantization limit — is elementary, finite, and robust. By
isolating this core we obtain statements that are simultaneously (a) faithful to
the classical theory (the order map reproduces the Newton-polytope indexing; the
deformed Ronkin function reproduces convexity and the spine limit), and (b)
entirely self-contained, resting only on convex-function calculus and a single
Hölder inequality.

The Maslov-dequantization rate `t\log N` deserves emphasis. It is *uniform in
`x`*, *sharp at both ends*, and *combinatorial* (it depends only on the number of
monomials, not on the coefficients, exponents, or dimension). This makes it an
unusually clean bridge between the smooth and tropical worlds, and explains why
the same inequality recurs across log-sum-exp analysis, softmax approximation, and
the semiclassical limit of statistical mechanics.

A subtle point is the relationship between the *dominance regions* `D_k` of the
spine and the *complement components* of the genuine amoeba `\mathcal{A}_f`. For
the spine they coincide asymptotically (away from a bounded region), and the order
map agrees with `\nabla N_f` off the amoeba. The bounded discrepancy between spine
and amoeba is exactly the content of the analytic theory we deliberately bracket;
the computation-free core controls everything outside it.

---

## 7. Future directions

The following are concrete, falsifiable continuations of the core.

### 7.1 Strict convexity transverse to the recession cone

Theorem 3 (`ronkinDeform_convexOn`) proves convexity of `R_t` via finite Hölder.
The natural strengthening is *strictness*: `R_t` should be **strictly convex** in
every direction `v` that is not orthogonal to all differences `m_i - m_j`, with
equality in Hölder forcing the ratios `\exp(A_i(x)/t)/\exp(A_i(y)/t)` to coincide
across `i`. Hölder is an equality exactly when the two summed vectors are
proportional, which pins the non-strict directions to the lineality space
`\bigcap_{i,j}(m_i - m_j)^{\perp}` — the recession directions of the spine. Since
the convexity proof already isolates the Hölder step, its equality case
(`Finset.inner_le_weight_mul_Lp` equality conditions) is the only missing
ingredient, upgrading a qualitative result to a sharp characterization of where
`R_t` fails to curve — precisely the spine's recession cone.

### 7.2 The Legendre dual of the Ronkin function is the Newton polytope

Define the Legendre transform `R_t^*(p) = \sup_x(\langle p, x\rangle - R_t(x))`.
Conjecture: as `t \to 0^+`, `R_t^*` converges to the (negated) support function
of `\Delta_f = \operatorname{conv}\{m_i\}`; equivalently
`\operatorname{dom}((\operatorname{trop} f)^*) = \Delta_f`, and the order map of
Theorem 2 sends each complement component to a distinct lattice vertex `m_k \in
\Delta_f`. The key insight: the order map is the subgradient of the convex
function `\operatorname{trop} f`, so the amoeba complement is in bijection with the
faces of `\Delta_f` met by the Legendre dual. With convex-conjugation
infrastructure already available, the bijection "complement components ↔ Newton
lattice points" can be stated and tested on small supports — e.g. `1 + z + w` (the
line), with three complement components and three vertices.

### 7.3 Quantitative spine separation and the tentacle count

Conjecture: the number of unbounded complement components ("tentacles") of the
amoeba equals the number of indices `k` whose dominance region `D_k` is unbounded,
which in turn equals the number of vertices of `\Delta_f` (with edge lattice
points contributing the higher-multiplicity tentacles). A quantitative *spine
separation* estimate — a lower bound on `\min_{j \ne k}(A_k - A_j)` over a region
— would convert this count into an effective statement with explicit thresholds,
testable directly via Algorithm D.

---

## 8. Conclusion

We have given a self-contained, computation-free core of amoeba and Ronkin-function
theory. The tropical spine `\operatorname{trop} f = \max_i(\log|c_i| + \langle
m_i, x\rangle)` is convex and piecewise-linear (Theorem 1); its dominance regions
are convex and carry constant integer slopes — the order map
(`tropPoly_slope_on_dominant`, Theorem 2); the Maslov-deformed Ronkin function
`R_t = t\log\sum_i \exp(A_i/t)` is convex for all `t > 0`
(`ronkinDeform_convexOn`, Theorem 3); and it dequantizes to the spine with the
uniform, sharp, combinatorial rate `|R_t - \operatorname{trop} f| \le t\log N`
(Theorem 4). Together these realize Maslov dequantization in the geometry of
amoebas and tie the subject to log-sum-exp convexity, the semiclassical limit of
statistical mechanics, and the temperature calculus of modern machine learning.
