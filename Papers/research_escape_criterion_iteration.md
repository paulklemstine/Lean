# An Exact Escape Criterion for the Quadratic Family: Iteration Bounds, Escape Times, and the Escape-Rate Potential

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

For the quadratic family $f_c(z) = z^2 + c$ on the complex plane we develop, from a single elementary inequality, a complete and quantitative theory of escape. Let $R(c) = \max(2, |c|)$ denote the escape radius. We prove that the region $\{|z| > R(c)\}$ is forward invariant and that orbits entering it grow at least geometrically, $|f_c^{\,n}(z)| \ge (|z|-1)^n|z|$ with ratio $|z|-1 > 1$; consequently a single crossing of the escape radius, at any iterate whatsoever, certifies divergence to infinity. This yields a test that is both *sound* and *complete*: an orbit is bounded if and only if it never exceeds $R(c)$. Specialised to the critical orbit, it gives the exact characterisation $c \in M \iff |f_c^{\,n}(0)| \le 2$ for all $n$, where $M$ is the Mandelbrot set, together with a proof that the constant $2$ is sharp (the parameter $c = -2$ has a bounded critical orbit attaining modulus exactly $2$). The test sets $T_n = \{c : |f_c^{\,k}(0)| \le 2 \text{ for } k \le n\}$ are closed and nested with $M = \bigcap_n T_n$, whence $M$ is compact; the analogous argument in dynamical space shows each filled Julia set $K_c$ is compact, totally invariant and nonempty.

We then sharpen the geometric estimate, which is exponentially lossy, into a doubly exponential one: $\log|f_c^{\,n}(z)| - 1 \ge 2^n(\log|z| - 1)$, giving escape times of order $\log\log B$ for a threshold $B$ in place of the order-$B$ bound available from the geometric estimate. The logarithmic viewpoint supports a potential theory. A distortion lemma — if $r > 2$ and $r^2 - r \le s \le r^2 + r$ then $|\log s - 2\log r| \le 2/r$ — shows that $2^{-n}\log|f_c^{\,n}(z)|$ is Cauchy with geometric rate, defining the escape rate (Green's function) $G_c(z)$ on the escaping region. We establish the functional equation $G_c(f_c(z)) = 2G_c(z)$ and its iterate $G_c(f_c^{\,N}(z)) = 2^N G_c(z)$, strict positivity, the a priori bound $|G_c(z) - \log|z|| \le 1$ sharpened to $|G_c(z) - \log|z|| \le 2/|z|$, the explicit approximation error $|2^{-n}\log|f_c^{\,n}(z)| - G_c(z)| \le 2^{-n}$, uniform convergence, and hence continuity of $G_c$ on $\{|z| > R(c)\}$. Transporting the construction to parameter space gives the Douady–Hubbard potential $G_M(c) = \lim_n 2^{-n}\log|f_c^{\,n}(c)|$, defined for $|c| > 2$ via $G_M(c) = \tfrac12 G_c(c^2+c)$, which is positive, explicitly bounded below, and continuous on $\{|c| > 2\}$.

**Keywords:** quadratic family, escape criterion, escape radius, Mandelbrot set, filled Julia set, Green's function, Douady–Hubbard potential, escape-time algorithm.

---

## 1. Introduction

### 1.1 The problem

Fix $c \in \mathbb{C}$ and consider the quadratic polynomial
$$f_c : \mathbb{C} \to \mathbb{C}, \qquad f_c(z) = z^2 + c .$$
For a starting point $z \in \mathbb{C}$ we write $z_n = f_c^{\,n}(z)$ for the $n$-th iterate, with $z_0 = z$. Two sets organise the classical theory:

* the **filled Julia set** $K_c = \{ z \in \mathbb{C} : (z_n)_{n\ge0} \text{ is bounded} \}$;
* the **Mandelbrot set** $M = \{ c \in \mathbb{C} : (f_c^{\,n}(0))_{n \ge 0} \text{ is bounded} \}$.

Both are defined by a condition — boundedness of an infinite orbit — that cannot be checked in finite time. Every computational treatment therefore replaces the definition with a *test*: iterate until either a fixed budget is exhausted or the orbit modulus exceeds a bailout radius, conventionally $2$.

The purpose of this paper is to prove that this substitution is not an approximation but an identity, to determine exactly which constants make it work, and to extract from the same inequality a quantitative theory: effective escape times, an escape-rate potential, and its regularity.

### 1.2 What is proved

The starting observation, that a point far from the origin is pushed farther by $f_c$, is standard. What we develop here is the complete chain of consequences, each stated with explicit constants:

1. **Forward invariance and geometric growth** of the escaping region (Theorem 3.3), valid for arbitrary starting points, not just the critical point.
2. **Divergence from an arbitrary escape time** (Theorem 3.5): a crossing at *any* iterate, however late, certifies divergence.
3. **Soundness and completeness** of the escape-time test (Theorem 4.1).
4. **The radius-2 characterisation of $M$** (Theorem 4.3) together with **sharpness** of the constant $2$ (Theorem 4.6).
5. **Compactness of $M$** as the intersection of the algorithm's nested closed test sets (Theorem 5.3), and the corresponding structure theory of $K_c$ (Section 6).
6. **Doubly exponential escape** and $\log\log$ escape times (Theorems 7.1–7.3).
7. **Existence, functional equation, bounds, and continuity of the escape rate** $G_c$ (Sections 8–9), and of the Douady–Hubbard potential $G_M$ (Section 10).

A recurring theme is that the *geometric* form of the escape estimate and its *logarithmic* form, though logically equivalent at the level of one step, differ enormously in what they yield after $n$ steps: the first gives an escape time linear in the target threshold, the second a $\log\log$ escape time and an entire potential theory.

---

## 2. Definitions

Throughout, $|\cdot|$ denotes the modulus on $\mathbb{C}$ and $\log$ the natural logarithm.

**Definition 2.1 (Orbit).** For $c, z \in \mathbb{C}$ and $n \in \mathbb{N}$, the orbit is $z_n := f_c^{\,n}(z)$, so that $z_0 = z$ and $z_{n+1} = z_n^2 + c$. When the base point is the critical point $0$ we write $c_n := f_c^{\,n}(0)$ and call $(c_n)$ the **critical orbit**; thus $c_0 = 0$, $c_1 = c$, $c_2 = c^2 + c$.

The orbit satisfies the cocycle identity
$$f_c^{\,m+n}(z) = f_c^{\,n}\bigl(f_c^{\,m}(z)\bigr), \tag{2.1}$$
which is what allows all statements about starting points to be re-applied at arbitrary later times.

**Definition 2.2 (Escape radius).** The escape radius of the parameter $c$ is
$$R(c) := \max\bigl(2, |c|\bigr).$$
The **escaping region** of $c$ is $E_c := \{ z \in \mathbb{C} : |z| > R(c) \}$. Note $R(c) \ge 2$ and $|c| \le R(c)$.

**Definition 2.3 (Bounded orbit).** The orbit of $z$ under $f_c$ is *bounded* if there is $B \in \mathbb{R}$ with $|z_n| \le B$ for all $n$. The filled Julia set is $K_c := \{z : \text{the orbit of } z \text{ is bounded}\}$, and $M := \{c : 0 \in K_c\}$.

**Definition 2.4 (Escape rate).** For $z \in E_c$ set $\ell_n(c,z) := 2^{-n}\log|z_n|$ and
$$G_c(z) := \lim_{n \to \infty} \ell_n(c, z) = \lim_{n\to\infty} \frac{\log|f_c^{\,n}(z)|}{2^{\,n}} .$$
Theorem 8.3 shows the limit exists for all $z \in E_c$. $G_c$ is the *escape rate*, or Green's function of $K_c$ with pole at infinity.

**Definition 2.5 (Douady–Hubbard potential).** For $|c| > 2$ put
$$G_M(c) := \tfrac12\, G_c\bigl(c^2 + c\bigr) = \tfrac12\,G_c\bigl(f_c(c)\bigr).$$
Theorem 10.2 identifies this with $\lim_n 2^{-n}\log|f_c^{\,n}(c)|$, the escape rate of the critical *value*.

*Remark 2.6.* The normalisation in Definition 2.5 deserves comment. The natural object in parameter space is the escape rate of the critical value $c$ under $f_c$; using the critical point $0$ instead changes the answer by a factor of $2$, since $G_c(f_c(z)) = 2G_c(z)$. Moreover, when $|c| > 2$ one has $R(c) = |c|$, so $c \notin E_c$ (the inequality $|c| > R(c)$ fails) and $G_c(c)$ is not directly covered by the existence theorem. Applying one step of the dynamics to enter $E_c$ and dividing by $2$ to compensate resolves both issues at once.

---

## 3. The escape criterion

### 3.1 The one-step estimate

**Lemma 3.1 (One-step growth).** Let $z \in E_c$, i.e. $|z| > R(c)$. Then
$$\bigl(|z| - 1\bigr)|z| \ \le\ |f_c(z)| .$$

*Proof.* The triangle inequality gives $|z^2 + c| \ge |z|^2 - |c|$. Since $|c| \le R(c) < |z|$, we get $|z^2 + c| \ge |z|^2 - |z| = (|z|-1)|z|$. $\square$

Because $|z| > R(c) \ge 2$, the factor $|z| - 1$ exceeds $1$: the map is strictly expanding in modulus on $E_c$.

**Lemma 3.2 (Forward invariance).** If $z \in E_c$ then $f_c(z) \in E_c$.

*Proof.* From $|z| > R(c) \ge 2$ we have $|z| - 1 > 1$, so by Lemma 3.1, $|f_c(z)| \ge (|z|-1)|z| > |z| > R(c)$. $\square$

### 3.2 The growth theorem

**Theorem 3.3 (Escape norm growth).** Let $z \in E_c$. Then for every $n \in \mathbb{N}$,
$$|z_n| > R(c) \qquad \text{and} \qquad \bigl(|z| - 1\bigr)^{n}\,|z| \ \le\ |z_n| .$$

*Proof sketch.* Induction on $n$, carrying both statements simultaneously. For $n = 0$ both are immediate. Assume both hold at $n$. The first clause at $n$ says $z_n \in E_c$, so Lemma 3.2 gives $z_{n+1} \in E_c$, which is the first clause at $n+1$. For the second, since $|z| > 2$ we have $(|z|-1)^n \ge 1$, so the induction hypothesis yields $|z_n| \ge (|z|-1)^n |z| \ge |z|$. Hence
$$(|z|-1)^{n+1}|z| = (|z|-1)\cdot\bigl((|z|-1)^n |z|\bigr) \le (|z|-1)\,|z_n| \le \bigl(|z_n| - 1\bigr)|z_n| \le |f_c(z_n)| = |z_{n+1}|,$$
the middle inequality using $|z| \le |z_n|$ and the last one Lemma 3.1 applied at $z_n \in E_c$. $\square$

**Theorem 3.4 (Escape criterion).** If $|z| > R(c)$ then $|z_n| \to \infty$ as $n \to \infty$.

*Proof.* Since $|z| > R(c) \ge 2$, the ratio $|z| - 1 > 1$, so $(|z|-1)^n|z| \to \infty$; Theorem 3.3 bounds $|z_n|$ below by this quantity. $\square$

Theorem 3.4 concerns the initial point, but the criterion the escape-time algorithm relies on must permit a crossing at an arbitrary iterate. The cocycle identity (2.1) upgrades it for free.

**Theorem 3.5 (Divergence from an arbitrary escape time).** Suppose there exists $N$ with $|z_N| > R(c)$. Then $|z_n| \to \infty$.

*Proof.* Apply Theorem 3.4 to the starting point $z_N \in E_c$: the sequence $n \mapsto |f_c^{\,n}(z_N)|$ tends to infinity. By (2.1), $f_c^{\,n}(z_N) = z_{n+N}$, so the shifted sequence $n \mapsto |z_{n+N}|$ tends to infinity, and a sequence tends to infinity if and only if some (equivalently, every) shift of it does. $\square$

Note that the parameter $c$ is *not* assumed to satisfy any a priori bound. The escaping region is defined relative to $c$ through $R(c) = \max(2,|c|)$, and that single definition makes the criterion uniform over the whole family.

### 3.3 Effective escape time from the geometric bound

**Theorem 3.6 (Effective escape time).** Let $\varepsilon > 0$, $B \in \mathbb{R}$, and suppose $|z| > R(c)$ and $|z| \ge 2 + \varepsilon$. If
$$n \ \ge\ \frac{B}{\varepsilon\,|z|},$$
then $|z_n| \ge B$.

*Proof.* By Bernoulli's inequality, $(1 + \varepsilon)^n \ge 1 + n\varepsilon$; and $|z| - 1 \ge 1 + \varepsilon$, so $(|z|-1)^n \ge (1+\varepsilon)^n \ge 1 + n\varepsilon$. Theorem 3.3 then gives
$$|z_n| \ \ge\ (|z|-1)^n |z| \ \ge\ (1 + n\varepsilon)|z| \ =\ |z| + n\,\varepsilon |z| \ \ge\ n\,\varepsilon|z| \ \ge\ B,$$
the last step being the hypothesis on $n$ rearranged (note $\varepsilon|z| > 0$). $\square$

This is a *terminating* form of the criterion: given a bailout threshold $B$ and a margin $\varepsilon$ by which the current point exceeds $2$, one can name in advance a number of iterations that suffices. Its weakness is that the bound is linear in $B$; Section 7 replaces it by a $\log\log B$ bound.

---

## 4. Soundness, completeness, and the radius-2 test

**Theorem 4.1 (Bounded $\iff$ never escapes).** For all $c, z \in \mathbb{C}$:
$$\text{the orbit of } z \text{ under } f_c \text{ is bounded} \iff |z_n| \le R(c) \text{ for all } n .$$

*Proof.* ($\Leftarrow$) Immediate: $R(c)$ is itself a bound. ($\Rightarrow$) Suppose the orbit is bounded by $B$ but $|z_N| > R(c)$ for some $N$. By Theorem 3.5, $|z_n| \to \infty$, so some $|z_m| > B$, contradicting boundedness. $\square$

Theorem 4.1 is the precise statement that the escape-time test is sound (it never falsely reports escape) and complete (it never fails to report an escape that occurs). It also has a structural content worth isolating: a bounded orbit is bounded by the *explicit* constant $R(c)$, not merely by some unspecified constant.

**Corollary 4.2 (Escape $\iff$ divergence).** $\exists N,\ |z_N| > R(c)$ $\iff$ $|z_n| \to \infty$.

*Proof.* ($\Rightarrow$) is Theorem 3.5. ($\Leftarrow$) a sequence tending to infinity eventually exceeds $R(c)$. $\square$

We now specialise to the critical orbit. If $|c| > 2$ then $R(c) = |c|$, and
$$|c_2| = |c^2 + c| \ \ge\ |c|^2 - |c| = (|c|-1)|c| \ >\ |c| = R(c),$$
so the criterion fires and the critical orbit diverges. Contrapositively, every $c \in M$ satisfies $|c| \le 2$, hence $R(c) = 2$ for such $c$.

**Theorem 4.3 (The radius-2 test).** For every $c \in \mathbb{C}$,
$$c \in M \iff |f_c^{\,n}(0)| \le 2 \ \text{ for all } n \in \mathbb{N}.$$

*Proof.* ($\Leftarrow$) The bound $2$ witnesses boundedness of the critical orbit. ($\Rightarrow$) If $c \in M$ then, by the remark above, $|c| \le 2$ and so $R(c) = 2$; Theorem 4.1 applied to the base point $z = 0$ then gives $|c_n| \le R(c) = 2$ for all $n$. $\square$

**Theorem 4.4 (Dichotomy for the critical orbit).** For every $c \in \mathbb{C}$, exactly one of the following holds:
$$\text{(i) } |f_c^{\,n}(0)| \le 2 \text{ for all } n, \qquad\text{or}\qquad \text{(ii) } |f_c^{\,n}(0)| \to \infty .$$

*Proof.* Suppose (i) fails, say $|c_N| > 2$. If $|c| \le 2$ then $R(c) = 2$ and Theorem 3.5 gives (ii). If $|c| > 2$, the computation preceding Theorem 4.3 gives $|c_2| > R(c)$ and again Theorem 3.5 gives (ii). The two alternatives are mutually exclusive since a divergent sequence is unbounded. $\square$

### 4.1 Sharpness of the constant 2

**Lemma 4.5.** The critical orbit of $c = -2$ is $0, -2, 2, 2, 2, \dots$; precisely, $f_{-2}^{\,n+2}(0) = 2$ for all $n \ge 0$.

*Proof.* $f_{-2}(0) = -2$, $f_{-2}(-2) = 4 - 2 = 2$, and $f_{-2}(2) = 4 - 2 = 2$, so $2$ is a fixed point and the orbit is constant from index $2$ onwards; formally, induction on $n$. $\square$

Consequently $-2 \in M$ by Theorem 4.3, its critical orbit attaining modulus exactly $2$.

**Theorem 4.6 (Sharpness).** For every $R < 2$ there is a parameter $c \in M$ and an index $n$ with $|f_c^{\,n}(0)| > R$. Hence the constant $2$ in Theorem 4.3 cannot be lowered, and the escape test must be stated with a strict inequality.

*Proof.* Take $c = -2$ and $n = 2$: $|f_{-2}^{\,2}(0)| = 2 > R$, while $-2 \in M$ by Lemma 4.5 and Theorem 4.3. $\square$

Theorem 4.6 explains a detail that is easy to get wrong: the escaping region must be $\{|z| > R(c)\}$ and not $\{|z| \ge R(c)\}$. The tip of the real antenna of $M$ sits exactly on the threshold.

---

## 5. Topological consequences: the algorithm computes $M$

**Definition 5.1 (Test sets).** For $n \in \mathbb{N}$ put
$$T_n := \{\, c \in \mathbb{C} : |f_c^{\,k}(0)| \le 2 \text{ for all } k \le n \,\}.$$
$T_n$ is precisely the set of parameters that an escape-time renderer with iteration budget $n$ paints black.

**Lemma 5.2.** Each map $c \mapsto f_c^{\,n}(0)$ is a polynomial in $c$, hence continuous; consequently each $T_n$ is closed, and $T_0 \supseteq T_1 \supseteq T_2 \supseteq \cdots$.

*Proof.* Continuity by induction: $c \mapsto f_c^{\,0}(0) = 0$ is constant, and $f_c^{\,n+1}(0) = (f_c^{\,n}(0))^2 + c$ is continuous if $f_c^{\,n}(0)$ is. Then $T_n = \bigcap_{k \le n} \{c : |f_c^{\,k}(0)| \le 2\}$ is a finite intersection of preimages of closed sets under continuous maps, hence closed. Monotonicity is immediate from the definition. $\square$

**Theorem 5.3.** $M = \bigcap_{n \ge 0} T_n$. Consequently $M$ is closed; being contained in the closed disc of radius $2$, it is compact.

*Proof.* By Theorem 4.3, $c \in M$ iff $|c_k| \le 2$ for all $k$, which holds iff $c \in T_n$ for every $n$ (one direction takes $k \le n$; the other takes $n = k$). Closedness follows from Lemma 5.2 since an intersection of closed sets is closed. Boundedness was shown before Theorem 4.3: $c \in M \Rightarrow |c| \le 2$. A closed and bounded subset of $\mathbb{C}$ is compact. $\square$

The content of Theorem 5.3 is that the escape-time algorithm is not an approximation scheme with an unquantified error: the nested closed sets it computes intersect exactly in $M$, and this identity *is* the proof of compactness.

---

## 6. The filled Julia set

Fix $c$ and vary the starting point. Everything above transfers verbatim, with $2$ replaced by $R(c)$.

**Theorem 6.1 (Escape-time characterisation).** $z \in K_c \iff |f_c^{\,n}(z)| \le R(c)$ for all $n$. In particular $K_c \subseteq \overline{D}(0, R(c))$.

*Proof.* This is Theorem 4.1; the inclusion is the case $n = 0$. $\square$

**Theorem 6.2 (Total invariance).** $z \in K_c \iff f_c(z) \in K_c$.

*Proof.* The orbit of $f_c(z)$ is the orbit of $z$ shifted by one, so one is bounded iff the other is. $\square$

**Theorem 6.3 (Compactness).** $K_c$ is compact.

*Proof.* Let $J_n := \{z : |f_c^{\,k}(z)| \le R(c) \text{ for } k \le n\}$. Each $z \mapsto f_c^{\,n}(z)$ is a polynomial in $z$, hence continuous, so each $J_n$ is closed, and Theorem 6.1 gives $K_c = \bigcap_n J_n$, a closed set. It is bounded by $R(c)$, hence compact. $\square$

**Theorem 6.4 (Nonemptiness).** $K_c \ne \emptyset$ for every $c$.

*Proof.* The equation $w^2 + c = w$ has a root $w = \tfrac12\bigl(1 + u\bigr)$ where $u$ is any square root of $1 - 4c$, which exists since $\mathbb{C}$ is algebraically closed. Then $f_c(w) = w$, so the orbit of $w$ is constant and hence bounded: $w \in K_c$. $\square$

Combining Theorem 6.1 with the positivity of the escape rate (Theorem 8.7) gives a "potential-theoretic" description of the complement: $z \notin K_c$ if and only if some iterate $z_N$ lies in $E_c$ and has strictly positive escape rate $G_c(z_N) > 0$.

---

## 7. Doubly exponential escape

The geometric bound of Theorem 3.3 is true but exponentially lossy, because it records only that $f_c$ multiplies the modulus by a factor, whereas squaring *doubles the logarithm*. The following theorem is the corrected accounting.

**Theorem 7.1 (Doubly exponential escape).** Let $|z| > R(c)$. Then for all $n$,
$$\log|z_n| - 1 \ \ge\ 2^{\,n}\bigl(\log|z| - 1\bigr).$$

*Proof sketch.* Induction. The base case is an identity. For the step, note first that $|z| \le |z_n|$ (from Theorem 3.3, since $(|z|-1)^n \ge 1$) and $|z_n| > 2$. By Lemma 3.1 applied at $z_n$, $|z_{n+1}| \ge (|z_n| - 1)|z_n|$, so
$$\log|z_{n+1}| \ \ge\ \log|z_n| + \log\bigl(|z_n| - 1\bigr).$$
It therefore suffices to check $\log|z_n| + \log(|z_n|-1) - 1 \ge 2\bigl(\log|z_n| - 1\bigr)$, i.e.
$$\log\frac{|z_n|}{|z_n| - 1} \ \le\ 1 .$$
Since $|z_n| > 2$, the ratio $|z_n|/(|z_n|-1) < 2 < e$, so the inequality holds. Chaining with the induction hypothesis $\log|z_n| - 1 \ge 2^n(\log|z|-1)$ gives $\log|z_{n+1}| - 1 \ge 2(\log|z_n| - 1) \ge 2^{n+1}(\log|z|-1)$. $\square$

**Corollary 7.2 (Explicit doubly exponential lower bound).** For $|z| > R(c)$,
$$|z_n| \ \ge\ \exp\!\Bigl(2^{\,n}\bigl(\log|z| - 1\bigr) + 1\Bigr).$$

Since $|z| > 2$ implies $\log|z| - 1 > \log 2 - 1$, the bound is only useful once $|z| > e$; but the theorem holds for all $|z| > R(c)$, the statement being vacuous (a lower bound below the trivial one) when $\log|z| < 1$.

**Theorem 7.3 ($\log\log$ escape time).** Let $|z| > R(c)$, $|z| \ge 3$, and $B > 0$. If
$$2^{\,n} \ \ge\ \frac{\log B - 1}{\log|z| - 1},$$
then $|z_n| \ge B$.

*Proof.* Since $|z| \ge 3$ we have $\log|z| \ge \log 3 > 1$, so the right-hand side is well defined and the hypothesis rearranges to $2^n(\log|z| - 1) \ge \log B - 1$. Theorem 7.1 gives $\log|z_n| - 1 \ge 2^n(\log|z|-1) \ge \log B - 1$, i.e. $\log|z_n| \ge \log B$, i.e. $|z_n| \ge B$. $\square$

Comparison with Theorem 3.6 is instructive. To reach a threshold $B$, the geometric estimate certifies $\Theta(B)$ iterations, the logarithmic one $\Theta(\log\log B)$. Numerically, from $|z| = 3$ a threshold of $B = 10^{100}$ requires
$$2^n \ \ge\ \frac{100\log 10 - 1}{\log 3 - 1} \approx 2325, \quad\text{i.e.}\quad n = 12,$$
whereas Theorem 3.6 with $\varepsilon = 1$ would only guarantee it after $n \ge 10^{100}/3$ steps. This explains a practical fact: in escape-time rendering, raising the bailout radius from $2$ to an enormous value costs a negligible number of extra iterations, which is why "smooth colouring" with large bailout is cheap.

---

## 8. The escape rate

### 8.1 A distortion lemma

**Theorem 8.1 (Logarithmic distortion).** Let $r > 2$ and let $s$ satisfy $r^2 - r \le s \le r^2 + r$. Then
$$\bigl|\log s - 2\log r\bigr| \ \le\ \frac{2}{r} .$$

*Proof sketch.* Write $s = r^2(1+t)$ with $|t| \le 1/r < 1/2$; note $s > 0$ since $r^2 - r > 0$. Then $\log s - 2\log r = \log(1+t)$, and for $|t| \le 1/2$ one has the elementary bound $|\log(1+t)| \le |t|/(1-|t|) \le 2|t| \le 2/r$. $\square$

The point of Theorem 8.1 is that squaring is *almost* exact on logarithms in the escaping region: the additive term $c$ perturbs $\log|z_{n+1}|$ away from $2\log|z_n|$ by at most $2/|z_n|$, an error that decays as the orbit escapes.

**Lemma 8.2 (Two-sided one-step bound).** For $|z| > R(c)$ and any $n$,
$$|z_n|^2 - |z_n| \ \le\ |z_{n+1}| \ \le\ |z_n|^2 + |z_n| .$$

*Proof.* Theorem 3.3 gives $|z_n| > R(c) \ge |c|$, so $|c| < |z_n|$; then $|z_n^2 + c|$ lies between $|z_n|^2 - |c|$ and $|z_n|^2 + |c|$, and both are within the stated range. $\square$

### 8.2 Existence

**Theorem 8.3 (Existence of the escape rate).** For $|z| > R(c)$ the sequence $\ell_n = 2^{-n}\log|z_n|$ converges. Its limit is $G_c(z)$.

*Proof sketch.* By Lemma 8.2 and Theorem 8.1 with $r = |z_n| > 2$, $s = |z_{n+1}|$,
$$\bigl|\log|z_{n+1}| - 2\log|z_n|\bigr| \ \le\ \frac{2}{|z_n|} \ \le\ 1 ,$$
using $|z_n| > 2$. Dividing by $2^{n+1}$,
$$|\ell_{n+1} - \ell_n| \ \le\ 2^{-(n+1)} . \tag{8.1}$$
The right-hand side is summable, so $(\ell_n)$ is Cauchy in the complete space $\mathbb{R}$ and converges. $\square$

**Theorem 8.4 (A priori bound).** For $|z| > R(c)$, $\bigl|G_c(z) - \log|z|\bigr| \le 1$.

*Proof.* $\ell_0 = \log|z|$, and summing (8.1) over all $n \ge 0$ gives $|G_c(z) - \ell_0| \le \sum_{n\ge0}2^{-(n+1)} = 1$. $\square$

**Theorem 8.5 (Sharp asymptotic bound).** For $|z| > R(c)$,
$$\bigl|G_c(z) - \log|z|\bigr| \ \le\ \frac{2}{|z|} .$$
Consequently, for every $\varepsilon > 0$ there is $R_\varepsilon$ (one may take $R_\varepsilon = \max(2, 2/\varepsilon)$) such that $|G_c(z) - \log|z|| < \varepsilon$ whenever $|z| > R_\varepsilon$ and $|z| > R(c)$, uniformly in $c$.

*Proof.* Refine the estimate leading to (8.1): instead of $2/|z_n| \le 1$, use monotonicity of the orbit modulus, $|z| \le |z_n|$ (Theorem 3.3), to get $2/|z_n| \le 2/|z|$, whence $|\ell_{n+1} - \ell_n| \le (2/|z|)\,2^{-(n+1)}$. Summing gives $|G_c(z) - \log|z|| \le (2/|z|)\sum_{n\ge0}2^{-(n+1)} = 2/|z|$. The uniform statement follows since the bound does not involve $c$. $\square$

Theorem 8.5 identifies $G_c$ as a Green's function with the correct logarithmic pole at infinity: $G_c(z) = \log|z| + O(1/|z|)$.

### 8.3 The functional equation and positivity

**Theorem 8.6 (Functional equation).** For $|z| > R(c)$,
$$G_c\bigl(f_c(z)\bigr) = 2\,G_c(z), \qquad\text{and more generally}\qquad G_c\bigl(f_c^{\,N}(z)\bigr) = 2^{N} G_c(z) \quad (N \in \mathbb{N}).$$

*Proof.* The orbit of $f_c(z)$ is the orbit of $z$ shifted by one: $f_c^{\,n}(f_c(z)) = z_{n+1}$. Hence
$$\ell_n\bigl(c, f_c(z)\bigr) = \frac{\log|z_{n+1}|}{2^{\,n}} = 2\cdot\frac{\log|z_{n+1}|}{2^{\,n+1}} = 2\,\ell_{n+1}(c,z).$$
Both sides converge (note $f_c(z) \in E_c$ by Lemma 3.2), and the limit of the right side is $2G_c(z)$. The general case follows by induction on $N$, using forward invariance at each step. $\square$

This is the structural heart of the theory: $G_c$ conjugates the nonlinear map $f_c$ to multiplication by $2$ on the range of the potential.

**Theorem 8.7 (Positivity).** For $|z| > R(c)$, $G_c(z) > 0$.

*Proof.* By Theorem 3.4 the orbit modulus tends to infinity, so there is $N$ with $|z_N| \ge 3$; also $z_N \in E_c$. Then $\log|z_N| \ge \log 3 > 1$, and Theorem 8.4 applied at $z_N$ gives $G_c(z_N) \ge \log|z_N| - 1 > 0$. By Theorem 8.6, $G_c(z_N) = 2^N G_c(z)$, so $G_c(z) = 2^{-N}G_c(z_N) > 0$. $\square$

---

## 9. Regularity of the escape rate

**Theorem 9.1 (Explicit approximation error).** For $|z| > R(c)$ and every $n$,
$$\left| \frac{\log|z_n|}{2^{\,n}} - G_c(z) \right| \ \le\ \frac{1}{2^{\,n}} .$$

*Proof.* Sum the step bound (8.1) from index $n$ onwards: $|\ell_n - G_c(z)| \le \sum_{m \ge 0} 2^{-(n+m+1)} = 2^{-n}$. $\square$

The bound is a *computable stopping rule*: to evaluate $G_c(z)$ within tolerance $\delta$, iterate $n = \lceil \log_2(1/\delta)\rceil$ times. It also does not depend on $z$ or $c$, which is exactly what is needed for uniformity.

**Theorem 9.2 (Uniform convergence).** The functions $z \mapsto 2^{-n}\log|z_n|$ converge to $G_c$ uniformly on $E_c = \{z : |z| > R(c)\}$.

*Proof.* Immediate from Theorem 9.1, since $2^{-n} \to 0$ independently of $z$. $\square$

**Theorem 9.3 (Continuity).** $G_c$ is continuous on $E_c$.

*Proof.* Each approximant is continuous on $E_c$: $z \mapsto z_n$ is a polynomial, and $|z_n| \neq 0$ on $E_c$ (indeed $|z_n| > R(c) \ge 2$ by Theorem 3.3), so $z \mapsto \log|z_n|$ is continuous there. A uniform limit of continuous functions is continuous, and Theorem 9.2 supplies uniformity. $\square$

Continuity of $G_c$ is what underlies "smooth colouring" in fractal rendering: the colour assigned to an escaping pixel is a function of a normalised iteration count that converges uniformly to a continuous quantity, so adjacent pixels receive nearby colours and the visible banding of naive escape-time colouring disappears.

---

## 10. The Douady–Hubbard potential

Fix now the starting point at the critical value and vary $c$.

**Lemma 10.1.** If $|c| > 2$ then $f_c^{\,2}(0) = c^2 + c$ satisfies $|c^2+c| > R(c) = |c|$.

*Proof.* $R(c) = \max(2,|c|) = |c|$. And $|c^2 + c| \ge |c|^2 - |c| = (|c|-1)|c| > |c|$ since $|c| - 1 > 1$. $\square$

So Definition 2.5, $G_M(c) = \tfrac12 G_c(c^2+c)$, makes sense for $|c| > 2$.

**Theorem 10.2 (The defining limit).** For $|c| > 2$,
$$G_M(c) \ = \ \lim_{n \to \infty} \frac{\log\bigl|f_c^{\,n}(c)\bigr|}{2^{\,n}} .$$

*Proof sketch.* Write $w = c^2 + c = f_c(c)$, so $f_c^{\,n}(w) = f_c^{\,n+1}(c)$. By Theorem 8.3, $2^{-n}\log|f_c^{\,n}(w)| \to G_c(w) = 2G_M(c)$. Substituting and dividing by $2$,
$$\frac{\log|f_c^{\,n+1}(c)|}{2^{\,n+1}} \longrightarrow G_M(c),$$
which is the claim after re-indexing. $\square$

Thus $G_M(c)$ is the escape rate of the critical value — equal to $G_c(c)$ wherever the latter is defined — rather than of the critical point; see Remark 2.6.

**Theorem 10.3 (Explicit lower bound and positivity).** For $|c| > 2$, writing $w = c^2 + c$,
$$G_M(c) \ \ge\ \frac{1}{2}\left(\log|w| - \frac{2}{|w|}\right) \qquad\text{and}\qquad G_M(c) > 0 .$$

*Proof.* Lemma 10.1 puts $w$ in $E_c$; Theorem 8.5 gives $G_c(w) \ge \log|w| - 2/|w|$ and Theorem 8.7 gives $G_c(w) > 0$. Divide by $2$. $\square$

**Theorem 10.4 (Continuity of the potential).** $G_M$ is continuous on $\{c \in \mathbb{C} : |c| > 2\}$.

*Proof sketch.* Define the approximants $P_n(c) := 2^{-(n+1)}\log|f_c^{\,n+2}(0)|$, which one checks equals $\tfrac12\,\ell_n(c, c^2+c)$. By Theorem 9.1 applied at $z = c^2+c$ (legitimate by Lemma 10.1),
$$\bigl|P_n(c) - G_M(c)\bigr| \ \le\ \tfrac12\cdot 2^{-n} \le 2^{-n},$$
uniformly for $|c| > 2$. Each $P_n$ is continuous on $\{|c|>2\}$, since $c \mapsto f_c^{\,n+2}(0)$ is a polynomial in $c$ that is nonvanishing there (its modulus exceeds $R(c) \ge 2$ by Theorem 3.3 and Lemma 10.1). Uniform convergence of continuous functions gives continuity of $G_M$. $\square$

Together with the fact that $G_M$ extends by $0$ to $M$ (where the critical orbit is bounded and the normalised logarithms tend to $0$), Theorem 10.4 is the analytic statement behind the coloured exterior of the Mandelbrot image: it is a level-set plot of a continuous, positive function that vanishes exactly on the black region.

---

## 11. Algorithms

Three algorithms follow directly from the theorems, all with certified behaviour.

### 11.1 Certified membership test

**Input:** $c \in \mathbb{C}$, budget $N$. **Output:** `ESCAPED` (a proof-carrying verdict: $c \notin M$) or `UNDECIDED`.

Iterate $z \leftarrow z^2 + c$ from $z = 0$ up to $N$ times; if ever $|z| > 2$ return `ESCAPED`, otherwise `UNDECIDED`. Theorem 4.3 and Theorem 3.5 guarantee that `ESCAPED` is never wrong, and Theorem 4.1 that every $c \notin M$ is eventually reported for large enough $N$. `UNDECIDED` is genuinely undecided: $M$ is not decidable by any finite test, and the algorithm's honest output reflects that. Complexity: $O(N)$ complex multiplications; comparing $|z|^2 > 4$ avoids the square root.

### 11.2 Certified escape time

**Input:** $c$, an escaping point $z$ with $|z| \ge 3$, and a threshold $B > 1$. **Output:** an integer $n$ with the *guarantee* $|f_c^{\,n}(z)| \ge B$.

Return $n = \bigl\lceil \log_2\bigl(\max(1,(\log B - 1)/(\log|z|-1))\bigr)\bigr\rceil$. Correctness is Theorem 7.3. The cost of computing $n$ is $O(1)$; the resulting iteration count is $O(\log\log B)$. If only the weaker hypothesis $|z| \ge 2 + \varepsilon$ is available, Theorem 3.6 gives the fallback $n = \lceil B/(\varepsilon|z|)\rceil$.

### 11.3 Escape rate to prescribed tolerance

**Input:** $c$, $z$ with $|z| > \max(2,|c|)$, tolerance $\delta > 0$. **Output:** $\widehat G$ with $|\widehat G - G_c(z)| \le \delta$.

Set $n = \lceil \log_2(1/\delta)\rceil$, iterate $n$ times and return $2^{-n}\log|z_n|$. Correctness is Theorem 9.1. Cost: $n = O(\log(1/\delta))$ iterations. Because the error bound is uniform in $z$, the same $n$ serves for a whole image; in floating point the iteration must be guarded against overflow, which the doubly exponential growth of Corollary 7.2 makes imminent — the standard remedy is to stop early at a large bailout $B$ and use $G_c(z) \approx 2^{-m}\log|z_m|$ at the first $m$ with $|z_m| \ge B$, whose error is bounded by $2^{-m}\cdot(2/B)$ via Theorem 8.5 and the functional equation.

---

## 12. Numerical illustration

The following values illustrate the estimates (five significant figures).

**Growth versus the certified bound.** For $c = 0.3 + 0.1i$, $z = 2.5$ (so $R(c) = 2$ and $|z| - 1 = 1.5$):

| $n$ | $\lvert z_n\rvert$ (actual) | $(\lvert z\rvert-1)^n\lvert z\rvert$ (Theorem 3.3) | $\exp(2^n(\log\lvert z\rvert-1)+1)$ (Corollary 7.2) |
|---|---|---|---|
| 0 | $2.5000$ | $2.5000$ | $2.5000$ |
| 1 | $6.5508$ | $3.7500$ | $2.2992$ |
| 2 | $43.216$ | $5.6250$ | $1.9448$ |
| 3 | $1867.9$ | $8.4375$ | $1.3914$ |
| 4 | $3.4890\times10^6$ | $12.656$ | $0.7122$ |

The geometric bound is valid but loses a factor of $2.8\times10^5$ by step four. (For $|z| = 2.5 < e$ the doubly exponential bound is vacuous, since $\log|z| - 1 < 0$; from $|z| > e$ onwards it dominates dramatically — e.g. for $|z| = 5$ it certifies $|z_4| \ge \exp(16(\log 5 - 1)+1) \approx 4.7\times10^4$ against the geometric $1280$, the true value being $1.7\times10^{11}$.)

**Escape rate.** For $c = 0$ the escape rate is exactly $\log|z|$, since $z_n = z^{2^n}$; the numerics reproduce this to machine precision, and confirm $|G_0(z) - \log|z|| = 0 \le 2/|z|$. For $c = -1$, $z = 4$: the approximants $2^{-n}\log|z_n|$ are $1.386294, 1.354025, 1.352912, 1.352909, 1.352909, \dots$, converging within the certified envelope $2^{-n}$ of Theorem 9.1 (the actual errors, $3.3\times10^{-2}$, $1.1\times10^{-3}$, $2.5\times10^{-6}$, $2.5\times10^{-11}$, decay doubly exponentially), and $|G_{-1}(4) - \log 4| = 0.03339 \le 2/4$, consistent with Theorem 8.5.

**Functional equation.** For the same $c=-1$, $z=4$: $G_{-1}(f_{-1}(4)) = G_{-1}(15) = 2.705818 = 2 \times 1.352909$, matching Theorem 8.6 to twelve digits.

**Potential in parameter space.** $G_M(2.5) = 1.092610$, $G_M(-3) = 0.873782$, $G_M(4+4i) = 1.794252$, each exceeding the certified lower bound of Theorem 10.3 and each agreeing with the defining limit of Theorem 10.2 by the fourth approximant. The difference $G_M(c) - \log|c|$ measured at $|c| = 10, 10^2, 10^3, 10^4$ is $4.79\times10^{-2}, 4.98\times10^{-3}, 5.00\times10^{-4}, 5.00\times10^{-5}$: decay of order $1/(2|c|)$, comfortably inside the certified $2/|c|$.

**Sharpness.** The orbit of $c = -2$ is $0, -2, 2, 2, \dots$: bounded, with modulus exactly $2$ at every step from index $2$. Any bailout radius below $2$ misclassifies it.

---

## 13. Discussion

### 13.1 One inequality, many theorems

Every result above is downstream of $|z^2 + c| \ge |z|^2 - |c|$. What varies is the coordinate in which the consequence is recorded:

* In *modulus*: $|f_c(z)| \ge (|z|-1)|z|$ — expansion by a factor $> 1$, hence invariance, divergence, and the sound-and-complete test.
* In *logarithm*: $\log|f_c(z)| \ge \log|z| + \log(|z|-1)$, i.e. $\log|f_c(z)| - 1 \ge 2(\log|z|-1)$ — doubling, hence doubly exponential escape and $\log\log$ escape times.
* In *normalised logarithm*: $\bigl|\log|f_c(z)| - 2\log|z|\bigr| \le 2/|z|$ — an almost-exact doubling with summable defect, hence the existence, functional equation, and continuity of $G_c$.

The three are equivalent statements about a single step, and radically different statements about $n$ steps. This is a general lesson about iteration estimates: the useful ones are those whose defect telescopes.

### 13.2 The role of strictness

The theory is *strict* at the escape radius, and must be. If the escaping region were taken to be $\{|z| \ge R(c)\}$, Lemma 3.1 would still hold, but the amplification factor $|z| - 1$ could equal $1$, invariance would degenerate, and the parameter $c = -2$ — whose critical orbit lands on the fixed point $2$ of modulus exactly $R(-2) = 2$ — would be a counterexample to the resulting criterion. The sharpness theorem shows that this is not a technicality of the proof but a genuine feature of the family: $M$ touches the circle $|z| = 2$ in dynamical space at exactly this parameter.

### 13.3 What the estimates do and do not give

The escape criterion gives no information whatsoever about points that *never* escape; it does not decide membership of $M$ in finite time, and cannot, since it is exactly the outer approximation $M = \bigcap T_n$ that converges. Any finite computation therefore certifies non-membership only. The theory does, however, make the outer approximation completely explicit: after $n$ iterations one knows precisely the closed set $T_n \supseteq M$ that has been verified, and the potential $G_M$ quantifies how far a rejected parameter is from $M$ in the conformal-capacity sense.

### 13.4 Relation to classical potential theory

$G_c$, extended by $0$ on $K_c$, is the Green's function of the unbounded component of $\mathbb{C}\setminus K_c$ with pole at infinity: it is positive and harmonic off $K_c$, vanishes on $K_c$, and satisfies $G_c(z) = \log|z| + O(1/|z|)$ at infinity, which pins the normalisation and shows that $K_c$ has logarithmic capacity $1$ for every $c$. The functional equation $G_c \circ f_c = 2G_c$ is the potential-theoretic shadow of the fact that $f_c$ has degree $2$. In parameter space, $G_M$ plays the same role for $M$, and its level curves are the equipotentials whose landing behaviour organises the combinatorics of the Mandelbrot set.

---

## 14. Future work

**Böttcher coordinate.** The estimates here are the real part of a complex story. The same telescoping that makes $2^{-n}\log|z_n|$ Cauchy, with defect $2/|z_n|$ at step $n$, should make the complex logarithms $2^{-n}\operatorname{Log} z_n$ Cauchy once a branch is fixed, because on the escaping region $z_n^2$ dominates $c$ and the argument correction is $O(1/|z_n|)$. The expected conclusion is that for $|z| > \max(2,|c|)$ the products
$$\varphi_c(z) = z\prod_{n\ge0}\Bigl(1 + \frac{c}{z_n^2}\Bigr)^{2^{-(n+1)}}$$
converge to an injective holomorphic map with $\varphi_c(f_c(z)) = \varphi_c(z)^2$ and $|\varphi_c(z)| = e^{G_c(z)}$ — the Böttcher coordinate linearising $f_c$ near infinity. Only the branch bookkeeping stands between the results above and this conclusion.

**Modulus of continuity for $G_M$.** Continuity of $G_M$ on $\{|c|>2\}$ is established here; the expected refinement is Lipschitz continuity on $\{|c| \ge R\}$ for each $R > 2$, with an explicit constant $K_R$, together with $G_M(c) - \log|c| = O(1/|c|)$ as $c \to \infty$. The uniform $2^{-n}$ error bound reduces this to a derivative estimate on the individual approximants $P_n$.

**Harmonicity and equipotentials.** Establishing that $G_c$ is harmonic on the complement of $K_c$ (rather than merely continuous), and extending it across the escape radius to the full basin of infinity by the functional equation, would allow the equipotential and external-ray machinery to be developed on this foundation.

**Sharper distortion.** The constant $2$ in $|\log s - 2\log r| \le 2/r$ is not optimal; replacing it by the exact $-\log(1 - 1/r)$ would tighten every downstream bound, including $|G_c(z) - \log|z|| \le 2/|z|$, whose optimal form should be $\log|z| - G_c(z) \sim |c|^2/(2|z|^2)$ for large $|z|$.

---

## 15. Conclusion

From the triangle inequality applied once, we have obtained: forward invariance and geometric growth on $\{|z| > \max(2,|c|)\}$; divergence certified by a single crossing at any time; a test for boundedness that is both sound and complete; the radius-$2$ characterisation of the Mandelbrot set, with the constant $2$ proved sharp; compactness of $M$ and of every filled Julia set, obtained as the exact limit of the escape-time algorithm's nested closed test sets; doubly exponential escape with $\log\log$ escape times; and a complete elementary construction of the escape-rate potential, with functional equation, explicit error bounds, and continuity, in both dynamical and parameter space.

The escape-time algorithm is often described as a heuristic that draws an approximation to a set defined by an infinitary condition. The results here invert that description. The algorithm's test sets are exactly the finite stages of $M$; its bailout radius is exactly the sharp constant; its "smooth" colouring converges uniformly to a continuous potential with a computable error bar. What looks like a picture of a fractal is a picture of a theorem.
