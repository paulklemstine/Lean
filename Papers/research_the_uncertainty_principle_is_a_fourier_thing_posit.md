# A Unified Uncertainty Principle for Holomorphic Integral Transforms

## Abstract

The Heisenberg uncertainty principle is traditionally presented as a foundational law of quantum mechanics. It is, more accurately, a theorem of harmonic analysis: it expresses the impossibility of simultaneously concentrating a function and its Fourier transform. In its sharpest qualitative form — the Benedicks–Amrein–Berthier phenomenon — a nonzero function and its Fourier transform cannot both be supported on sets of finite Lebesgue measure. We show that this qualitative uncertainty principle is not a peculiarity of the Fourier transform but a structural feature shared by *every invertible integral transform whose image consists of holomorphic functions on a connected open domain*. The common engine is a single, classical fact from complex analysis: a holomorphic function on a connected open set that vanishes on a nonempty open subset (or, over the whole plane, on a set of positive measure) vanishes identically. We isolate this engine as an abstract lemma and derive from it: (i) the compact-support Fourier uncertainty principle for entire functions; (ii) the null-zero-set and infinite-support consequences; (iii) the positive-measure (Benedicks–Amrein–Berthier) form for entire images; and (iv) uncertainty principles for the Laplace transform (half-plane domain) and the Mellin transform (strip domain). We illustrate the theory on worked examples — the sine and cosine (building blocks of the sinc kernel), and the Gaussian (the fixed point of the Fourier transform and the extremal object of the inequality) — and discuss extensions to the Z-transform, the two-sided Laplace transform, the Borel transform, the discrete Donoho–Stark inequality, and the Radon transform.

**Keywords.** Uncertainty principle, Fourier transform, Laplace transform, Mellin transform, identity theorem, entire functions, Benedicks–Amrein–Berthier theorem, Paley–Wiener, analytic continuation.

---

## 1. Introduction

### 1.1 The uncertainty principle as mathematics

The uncertainty principle of quantum mechanics asserts that the product of the standard deviations of a particle's position and momentum is bounded below,

$$\Delta x \cdot \Delta p \ge \frac{\hbar}{2}.$$

The position and momentum wavefunctions of a quantum system are, however, a Fourier-transform pair. Once this is recognized, the inequality is seen to be a statement purely about a function $f$ and its Fourier transform $\hat f$, with Planck's constant $\hbar$ serving only as a unit conversion. The mathematical content is:

$$\left(\int t^2 |f(t)|^2\, dt\right)\left(\int k^2 |\hat f(k)|^2\, dt\right) \ge \frac{1}{16\pi^2}\left(\int |f|^2\right)^2,$$

the classical variance uncertainty inequality, with the Gaussian as the unique equality case. No physics is involved.

### 1.2 Qualitative uncertainty and the goal of this paper

The variance inequality is the *quantitative* face of uncertainty. There is a sharper *qualitative* face: a function and its transform cannot both be **strongly confined**. The strongest confinement is having support of finite measure. The definitive results here are:

- **Benedicks (1985), Amrein–Berthier (1977).** If $f \in L^1(\mathbb R^n)$ and both $\{f \ne 0\}$ and $\{\hat f \ne 0\}$ have finite Lebesgue measure, then $f = 0$.

Our thesis is that the qualitative uncertainty principle, at least for transforms whose image is holomorphic, follows from a *single* mechanism — analytic rigidity — and is therefore a universal feature of integral transforms rather than a Fourier-specific accident. Concretely:

- the Fourier transform of a compactly supported $L^1$ function extends to an **entire** function of the complex frequency variable (Paley–Wiener);
- the Laplace transform of a function supported on $[a,\infty)$ is **holomorphic on a right half-plane**;
- the Mellin transform is **holomorphic on a vertical strip**;

and in each case the transform lives on an open, connected domain $U \subseteq \mathbb C$. On any such domain the identity principle forbids the transform from vanishing on an open set unless it vanishes identically — which is precisely the impossibility of confinement.

### 1.3 Contributions

1. We isolate the **abstract uncertainty engine** (Theorem 3.1): a function analytic on a preconnected set $U$ vanishing on a nonempty open $W \subseteq U$ vanishes on all of $U$.
2. We derive the **Fourier compact-support principle** (Theorem 4.1): an entire function with compact support is zero.
3. We prove the **measure-theoretic consequences** (Theorems 4.2–4.5): the zero set of a nonzero entire function is null; its support has infinite measure; vanishing on a positive-measure set forces zero (Benedicks–Amrein–Berthier for entire images); finite-measure support forces zero.
4. We instantiate the engine on the **Laplace** (Theorem 6.1) and **Mellin** (Theorem 6.2) transforms.
5. We supply **worked examples** — sine/cosine and the Gaussian — with explicit measure computations.

---

## 2. Preliminaries and definitions

Throughout, $\mathbb C$ denotes the complex plane, identified with $\mathbb R^2$ for measure-theoretic purposes, and $\operatorname{vol}$ denotes two-dimensional Lebesgue measure.

**Definition 2.1 (Holomorphic / analytic on a set).** A function $f : \mathbb C \to \mathbb C$ is *analytic on a neighborhood of a set* $U$ if for every $z \in U$ there is an open ball around $z$ on which $f$ is given by a convergent power series. When $U = \mathbb C$ we call $f$ **entire**. For open $U$, analyticity on a neighborhood of $U$ coincides with complex differentiability on $U$.

**Definition 2.2 (Support and tsupport).** The *support* of $f$ is $\operatorname{supp} f = \{z : f(z) \ne 0\}$. Its *topological support* (or closed support) is $\operatorname{tsupp} f = \overline{\operatorname{supp} f}$. We say $f$ has **compact support** if $\operatorname{tsupp} f$ is compact.

**Definition 2.3 (Preconnected set).** A set $U$ is *preconnected* if it cannot be split by two open sets each meeting $U$ into disjoint nonempty pieces. Every convex set — in particular $\mathbb C$, any half-plane, any strip, any ball — is preconnected.

**Definition 2.4 (Zero set).** The *zero set* of $f$ is $Z(f) = \{z : f(z) = 0\}$.

**Definition 2.5 (Integral transform, informal).** An *integral transform* sends a signal $f$ to a function $T[f](s) = \int f(t)\,K(s,t)\,dt$ for a kernel $K$. Examples: the **Fourier** kernel $e^{-2\pi i s t}$; the **Laplace** kernel $e^{-st}$ on $[a,\infty)$; the **Mellin** kernel $t^{s-1}$ on $(0,\infty)$. In each case, for suitable signals, $s \mapsto T[f](s)$ extends holomorphically to an open connected region of $\mathbb C$ (the plane, a half-plane, a strip respectively).

---

## 3. The abstract uncertainty engine

The whole theory rests on the identity principle for analytic functions.

**Theorem 3.1 (Identity-principle uncertainty).** *Let $f : \mathbb C \to \mathbb C$ be analytic on a neighborhood of a preconnected set $U$. Let $W \subseteq U$ be open and nonempty, and suppose $f \equiv 0$ on $W$. Then $f \equiv 0$ on all of $U$.*

**Proof sketch.** Pick $z_0 \in W$. Since $W$ is open, $W$ is a neighborhood of $z_0$, so $f$ is *eventually zero* near $z_0$ (it is zero on a whole neighborhood). By the identity theorem for analytic functions on a preconnected set — an analytic function that is locally zero at one point of a preconnected domain is zero throughout — $f$ vanishes on all of $U$. $\qquad\blacksquare$

**Interpretation.** Theorem 3.1 *is* the uncertainty principle in its most general holomorphic form. If a transform $T[f]$ is holomorphic on a connected open domain $U$ and is supported on a set $S \subsetneq U$ whose complement in $U$ contains a nonempty open set $W$ (for example, if $S$ has empty interior, or is compact and $U$ is not), then $T[f] \equiv 0$ on $W$, hence on $U$, hence — by invertibility of $T$ — $f = 0$. The specific transform only determines the shape of $U$:

| Transform | Domain of holomorphy $U$ | Preconnected? |
|---|---|---|
| Fourier (compact support) | $\mathbb C$ | yes (convex) |
| Laplace on $[a,\infty)$ | right half-plane $\{\operatorname{Re} s > 0\}$ | yes (convex) |
| Mellin | vertical strip $\{a < \operatorname{Re} s < b\}$ | yes (convex) |
| Two-sided Laplace | horizontal/vertical strip | yes (convex) |
| Z-transform | annulus | yes (connected) |

---

## 4. The Fourier uncertainty principle and its measure-theoretic forms

We now specialize $U = \mathbb C$, i.e. to entire functions, the setting of the Fourier transform of compactly supported signals via Paley–Wiener.

**Theorem 4.1 (Compact-support form).** *An entire function $f$ with compact support is identically zero.*

**Proof sketch.** Since $\operatorname{tsupp} f$ is compact and $\mathbb C$ is not compact, the complement $(\operatorname{tsupp} f)^c$ is a nonempty open set on which $f \equiv 0$. Apply Theorem 3.1 with $U = \mathbb C$ (preconnected) and $W = (\operatorname{tsupp} f)^c$: $f \equiv 0$ on $\mathbb C$. $\qquad\blacksquare$

This is the cleanest statement of Fourier uncertainty: a compactly supported signal (whose transform is entire by Paley–Wiener) cannot also have a compactly supported transform, unless it is zero.

We now quantify how *little* a nonzero transform can vanish.

**Theorem 4.2 (Null zero set).** *If $f$ is entire and $f \not\equiv 0$, then $\operatorname{vol}(Z(f)) = 0$.*

**Proof sketch.** Choose $x$ with $f(x) \ne 0$. By analyticity, the set $\{f \ne 0\}$ is **codiscrete** (its complement is discrete): the zeros of a nonzero analytic function are isolated. Hence $Z(f)$ is discrete. Since $f$ is continuous, $Z(f)$ is closed. A closed, discrete subset of the second-countable (hence Lindelöf) space $\mathbb C$ is countable. A countable subset of $\mathbb R^2$ has Lebesgue measure zero. $\qquad\blacksquare$

**Theorem 4.3 (Infinite support).** *If $f$ is entire and $f \not\equiv 0$, then $\operatorname{vol}(\operatorname{supp} f) = \infty$.*

**Proof sketch.** The plane splits as $\mathbb C = \operatorname{supp} f \cup Z(f)$, so $\infty = \operatorname{vol}(\mathbb C) \le \operatorname{vol}(\operatorname{supp} f) + \operatorname{vol}(Z(f)) = \operatorname{vol}(\operatorname{supp} f) + 0$. Hence $\operatorname{vol}(\operatorname{supp} f) = \infty$. $\qquad\blacksquare$

**Theorem 4.4 (Benedicks–Amrein–Berthier form, entire image).** *If $f$ is entire and $\operatorname{vol}(Z(f)) > 0$, then $f \equiv 0$.*

**Proof sketch.** Contrapositive of Theorem 4.2: if $f \not\equiv 0$ then $\operatorname{vol}(Z(f)) = 0$, contradicting positivity. $\qquad\blacksquare$

**Theorem 4.5 (Measure-theoretic uncertainty).** *If $f$ is entire and $\operatorname{vol}(\operatorname{supp} f) < \infty$, then $f \equiv 0$.*

**Proof sketch.** Contrapositive of Theorem 4.3. $\qquad\blacksquare$

Theorems 4.4 and 4.5 are the Benedicks–Amrein–Berthier conclusion for the class of transforms with entire image: a signal and its (entire) transform cannot both be supported on sets of finite measure.

---

## 5. Worked examples

### 5.1 Sine, cosine, and the sinc kernel (Fourier)

The sinc function $\operatorname{sinc}(k) = \sin(\pi k)/(\pi k)$ is the Fourier transform of the box indicator $\mathbf 1_{[-1,1]}$ — the canonical example of a compactly supported signal with a fully spread-out transform. Its numerator is built from $\sin$ and $\cos$, which are entire.

**Proposition 5.1.** *$\sin$ and $\cos$ are entire, and neither is identically zero (since $\sin(\pi/2) = 1$ and $\cos 0 = 1$).*

**Corollary 5.2.** *$\operatorname{vol}(Z(\sin)) = \operatorname{vol}(Z(\cos)) = 0$, and $\operatorname{vol}(\operatorname{supp}\sin) = \infty$.*

These follow directly from Theorems 4.2 and 4.3. The sinc kernel's transform (the box) is compactly supported, but the sine wave itself — as a function on the plane — vanishes only on the discrete null set $\{n\pi\}$ and is otherwise nonzero, illustrating the infinite-support conclusion.

### 5.2 The Gaussian: the extremal object

**Proposition 5.3.** *The function $z \mapsto e^{-z^2}$ is entire and nowhere zero; hence $\operatorname{supp}(e^{-z^2}) = \mathbb C$ and $\operatorname{vol}(\operatorname{supp}(e^{-z^2})) = \infty$.*

**Proof sketch.** The complex exponential never vanishes, so $e^{-z^2} \ne 0$ for all $z$; its support is the whole plane. $\qquad\blacksquare$

The Gaussian is the fixed point of the Fourier transform ($\widehat{e^{-\pi t^2}} = e^{-\pi k^2}$) and the unique minimizer of the variance uncertainty product. Its complex incarnation is the *equality case* made visible: not only can it not be confined, it does not vanish anywhere at all — the smoothest, most symmetric refusal of localization.

---

## 6. Uncertainty for the Laplace and Mellin transforms

The same engine, with a different domain $U$, yields uncertainty principles for other transforms.

**Theorem 6.1 (Laplace uncertainty).** *Let $f$ be holomorphic on the right half-plane $H = \{\operatorname{Re} s > 0\}$ — as every Laplace transform of an $L^1$ signal supported on $[a,\infty)$ is on its region of convergence. If $f$ vanishes on a nonempty open subset $W \subseteq H$, then $f \equiv 0$ on $H$; consequently, by injectivity of the Laplace transform, the signal is zero.*

**Proof sketch.** $H$ is convex, hence preconnected. Apply Theorem 3.1 with $U = H$. $\qquad\blacksquare$

**Theorem 6.2 (Mellin uncertainty).** *Let $f$ be holomorphic on a vertical strip $S = \{a < \operatorname{Re} s < b\}$ — the strip of holomorphy of a Mellin transform. If $f$ vanishes on a nonempty open subset $W \subseteq S$, then $f \equiv 0$ on $S$.*

**Proof sketch.** A strip is the intersection of two half-planes $\{\operatorname{Re} s > a\}$ and $\{\operatorname{Re} s < b\}$, each convex; the intersection is convex, hence preconnected. Apply Theorem 3.1 with $U = S$. $\qquad\blacksquare$

**Remark 6.3.** The convexity (hence preconnectedness) of the half-plane and the strip is exactly the hypothesis Theorem 3.1 needs. The two-sided Laplace transform (strip), the Z-transform (annulus, connected but not convex), and the Borel transform (a growth-determined region) are all covered identically, each yielding its own uncertainty principle.

---

## 7. Algorithms

The theory is qualitative, but its predictions are numerically checkable. We describe two algorithms used in the accompanying computational demonstrations.

### 7.1 Concentration trade-off estimator

**Purpose.** Given a discretized signal, estimate the time-spread $\Delta x$ and frequency-spread $\Delta k$ (via second moments of $|f|^2$ and $|\hat f|^2$) and verify $\Delta x \cdot \Delta k \ge 1/(4\pi)$ numerically, confirming the Gaussian saturates the bound.

**Pseudocode.**
```
Input: sampled signal f on a grid of N points, spacing dt
1. normalize f so that sum |f|^2 dt = 1
2. compute mean time  mu_t = sum t |f|^2 dt
3. compute Delta_x^2 = sum (t - mu_t)^2 |f|^2 dt
4. compute fhat = FFT(f), frequencies k, normalize similarly
5. compute Delta_k^2 = sum (k - mu_k)^2 |fhat|^2 dk
6. return Delta_x * Delta_k, compare to 1/(4*pi)
```

### 7.2 Support-measure certifier

**Purpose.** Empirically confirm that as a compactly supported signal is narrowed (support measure $\to \varepsilon$), the effective support of its transform grows without bound, illustrating Theorem 4.3.

**Pseudocode.**
```
Input: family of box signals of width w -> 0
For each width w:
  1. build box_w = indicator of [-w/2, w/2]
  2. compute transform (analytically: sinc scaled by w)
  3. measure effective support = { k : |transform(k)| > tau } for threshold tau
  4. record (w, measure_of_effective_support)
Output: table showing product stays bounded below / support blows up
```

---

## 8. Applications and discussion

**Signal processing.** The uncertainty principle is the theoretical ceiling on joint time–frequency resolution. Every windowed transform (short-time Fourier transform, wavelets, Gabor frames) is a design under this constraint. Recognizing the constraint as a theorem — not an artifact of finite data — clarifies that no algorithm can evade it.

**Quantum mechanics.** The identification of position–momentum uncertainty with Fourier uncertainty demystifies the former: it is a mathematical necessity for any wave description, independent of measurement or interpretation.

**Number theory and scaling problems.** Mellin uncertainty (Theorem 6.2) is the analytic backbone behind rigidity statements for Dirichlet series and zeta-type functions: a Mellin transform cannot vanish on an open subset of its strip without vanishing identically.

**Unified viewpoint.** The central message is economy: one lemma (Theorem 3.1) governs the entire zoo of transform uncertainty principles. The transform chooses the domain; rigidity does the rest.

---

## 9. Future directions

1. **Paley–Wiener, formalized.** Prove that the Fourier transform of a compactly supported $L^1$ (or $L^2$) function extends to an entire function of exponential type, closing the loop between the *signal* and the *entire transform* used here, upgrading "the transform is entire ⇒ …" to a theorem directly about $\hat f$.

2. **Benedicks–Amrein–Berthier proper.** The full theorem — $f$ and $\hat f$ cannot both be supported on sets of finite Lebesgue measure unless $f = 0$ — for the genuine Fourier transform on $\mathbb R^n$ (no analyticity assumed). The present development proves the entire-image special case; the general case needs a different (measure-theoretic / Zygmund) argument.

3. **Quantitative Heisenberg.** Formalize $\Delta x \cdot \Delta k \ge 1/2$ via the variance form $\|x f\|_2 \cdot \|\xi\,\hat f\|_2 \ge (1/4\pi)\|f\|_2^2$, the sharp inequality with the Gaussian as the equality case — connecting to the Gaussian's full-plane support as the extremal object.

4. **Discrete uncertainty (Donoho–Stark).** For the DFT on $\mathbb Z/N$, $|\operatorname{supp} f|\cdot|\operatorname{supp}\hat f| \ge N$ for $f \ne 0$: a finite-dimensional, fully computable analogue provable via Plancherel and an $L^\infty$/Vandermonde bound.

5. **Radon transform.** A support theorem: if $f$ on $\mathbb R^2$ is supported in a strip and its Radon transform is supported in a set of finite measure of line-space, then $f = 0$. This needs the microlocal / holomorphic-extension machinery of the Radon transform.

6. **Other holomorphic transforms.** The engine Theorem 3.1 applies verbatim to the two-sided Laplace transform (strip), the Z-transform (annulus), and the Borel transform, each giving its own uncertainty principle by choosing the domain $U$.

---

## 10. Conclusion

The uncertainty principle is not a law of physics but a theorem of complex analysis wearing physical clothing. Its engine is the rigidity of holomorphic functions: an analytic function on a connected open domain that vanishes on an open set vanishes everywhere. From this one fact flow the compact-support Fourier principle, the null-zero-set and infinite-support results, the positive-measure Benedicks–Amrein–Berthier form, and — by merely changing the domain — uncertainty principles for the Laplace and Mellin transforms and beyond. Every invertible transform with a holomorphic image has its own uncertainty principle, and they are all, at bottom, the same principle.
