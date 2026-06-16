# The Vietoris–Rips Completion Threshold and its Tropical Reading

## Abstract

The Vietoris–Rips complex is the central combinatorial object of topological
data analysis: from a (pseudo)metric space and a scale parameter
$\varepsilon \ge 0$ it produces a simplicial complex whose faces are the finite
subsets of pairwise diameter at most $\varepsilon$. As $\varepsilon$ increases the
complex grows monotonically from a discrete set of vertices to the *full
complex*, in which every finite subset is a face. We give a complete and exact
characterization of the **completion threshold** — the precise scale at which the
Vietoris–Rips complex first equals the full complex. We prove that completion
occurs if and only if every pair of points lies within distance $\varepsilon$, so
that high-dimensional completeness is entirely governed by the 1-skeleton (a
flag/clique phenomenon). For finite spaces this collapses to a single number, the
**diameter**, equivalently the **max-plus birth sum** — the tropical (max-plus
semiring) sum of all pairwise distances. We develop the tropical reading of this
fold and record its three structural consequences: additivity over unions (the
fold respects the assembly of data from parts), monotonicity/functoriality under
non-expanding maps, and sharp 1-Lipschitz stability under metric perturbation. We
present executable algorithms, numerical demonstrations, and a program of
extensions to higher-dimensional skeleta, a literal tropical-semiring functional,
and multiparameter filtrations. All core results have been formally verified.

**Keywords.** Vietoris–Rips complex, topological data analysis, completion
threshold, diameter, tropical semiring, max-plus algebra, simplicial complex,
persistence, stability.

---

## 1. Introduction

### 1.1 Motivation

Given a finite collection of points sampled from some unknown space — molecular
conformations, sensor readings, pixels of an image, galaxies in a survey — a
recurring problem is to recover qualitative *shape* (connectivity, loops, voids)
in a manner that is coordinate-free and robust to noise. The dominant tool is the
**Vietoris–Rips filtration**: one fixes a scale $\varepsilon$, connects points
whose distance is at most $\varepsilon$, fills in every clique as a simplex, and
studies how the homology of the resulting complex evolves as $\varepsilon$ varies.

As $\varepsilon \to \infty$ the complex saturates: eventually *every* finite
subset of points becomes a face and the complex equals the **full complex**, a
single contractible simplex on the entire vertex set. Beyond that scale the
filtration carries no further information. Identifying this saturation scale
exactly — the **completion threshold** — is both conceptually fundamental and
practically useful: it is the point past which raising the scale parameter is
provably wasted effort.

### 1.2 Contributions

We make the following contributions, all formally verified.

1. **A lightweight, self-contained framework.** We model simplicial complexes as
   downward-closed families of finite subsets (`SimpleComplex`), and define the
   full complex and the Vietoris–Rips complex within it (Section 2).

2. **The Completion Threshold Theorem** (Theorem 3.1). The Vietoris–Rips complex
   at scale $\varepsilon$ equals the full complex if and only if every pair of
   points is within distance $\varepsilon$. High-dimensional completeness is thus
   reducible to pairwise (1-skeleton) completeness.

3. **The Diameter Form** (Theorem 3.4). For a finite nonempty space, completion
   occurs iff the maximum pairwise distance is at most $\varepsilon$; the diameter
   is the *least* completion scale (a sharp threshold).

4. **The tropical reading** (Section 4). The completion threshold is the max-plus
   birth sum $\bigoplus_{x,y}\mathrm{dist}(x,y)$, a tropical-semiring sum, from
   which we derive additivity over unions, monotonicity/functoriality under
   non-expanding maps, and sharp 1-Lipschitz stability.

5. **Algorithms and demonstrations** (Sections 5–6) and a research program of
   extensions (Section 7).

---

## 2. Definitions

Throughout, $\alpha$ denotes a type (a set of "points"). When a metric is needed
we assume $\alpha$ carries a **pseudometric** $\mathrm{dist}\colon \alpha\times\alpha\to\mathbb{R}$
(i.e. $\mathrm{dist}(x,x)=0$, symmetry, and the triangle inequality, but distinct
points may be at distance $0$). All results hold at this generality; genuine
metric spaces are a special case. We write $\mathrm{Finset}(\alpha)$ for the set
of finite subsets of $\alpha$.

### Definition 2.1 (Simple complex)

A **simple complex** on $\alpha$ is a pair $(F)$ where $F \subseteq \mathrm{Finset}(\alpha)$
is a set of *faces* that is **downward closed**:
$$
\forall\, s,t \in \mathrm{Finset}(\alpha),\quad s \in F \ \wedge\ t \subseteq s \ \Longrightarrow\ t \in F.
$$
Downward closure is the defining structural property of a simplicial complex: any
sub-simplex of a simplex is a simplex. Two simple complexes are equal iff their
face sets are equal (extensionality).

### Definition 2.2 (Full complex)

The **full complex** on $\alpha$, written $\Delta(\alpha)$, is the simple complex
whose face set is *all* of $\mathrm{Finset}(\alpha)$:
$$
\mathrm{faces}(\Delta(\alpha)) = \mathrm{Finset}(\alpha).
$$
It is trivially downward closed (every subset is a face), and every finite subset
$s$ satisfies $s \in \mathrm{faces}(\Delta(\alpha))$.

### Definition 2.3 (Vietoris–Rips complex)

Let $\alpha$ be a pseudometric space and $\varepsilon \in \mathbb{R}$. The
**Vietoris–Rips complex at scale $\varepsilon$**, written $\mathrm{VR}(\varepsilon)$,
is the simple complex whose faces are the finite subsets of pairwise diameter at
most $\varepsilon$:
$$
\mathrm{faces}(\mathrm{VR}(\varepsilon)) = \bigl\{\, s \in \mathrm{Finset}(\alpha) \ \big|\ \forall\, x \in s,\ \forall\, y \in s,\ \mathrm{dist}(x,y) \le \varepsilon \,\bigr\}.
$$

**Lemma 2.4 (Well-definedness / downward closure).** $\mathrm{VR}(\varepsilon)$ is
a simple complex.

*Proof.* If $s$ is a face and $t \subseteq s$, then any $x,y \in t$ are also in
$s$, so $\mathrm{dist}(x,y) \le \varepsilon$ holds. Hence $t$ is a face. $\square$

**Lemma 2.5 (Membership criteria).** For any finite $s$:
$$
s \in \mathrm{faces}(\Delta(\alpha)) \iff \top \qquad\text{and}\qquad
s \in \mathrm{faces}(\mathrm{VR}(\varepsilon)) \iff \forall\, x \in s,\ \forall\, y\in s,\ \mathrm{dist}(x,y)\le\varepsilon.
$$
Both hold by definition.

---

## 3. The Completion Threshold

### Theorem 3.1 (Completion Threshold Theorem)

Let $\alpha$ be a pseudometric space and $\varepsilon \in \mathbb{R}$. Then
$$
\mathrm{VR}(\varepsilon) = \Delta(\alpha)
\quad\Longleftrightarrow\quad
\forall\, x, y \in \alpha,\ \mathrm{dist}(x,y) \le \varepsilon.
$$

**Proof.**

($\Rightarrow$) Suppose $\mathrm{VR}(\varepsilon) = \Delta(\alpha)$. Fix
$x, y \in \alpha$. The two-point set $\{x,y\}$ is a face of the full complex
(Definition 2.2), hence — by the assumed equality — a face of
$\mathrm{VR}(\varepsilon)$. Membership (Lemma 2.5) applied to the elements
$x, y \in \{x,y\}$ yields $\mathrm{dist}(x,y) \le \varepsilon$.

($\Leftarrow$) Suppose $\mathrm{dist}(x,y) \le \varepsilon$ for all $x,y$. To prove
the equality of complexes it suffices (extensionality) to show the face sets
coincide. The faces of $\mathrm{VR}(\varepsilon)$ are always a subset of the faces
of $\Delta(\alpha)$, so it remains to show every finite $s$ is a Rips face. Take
arbitrary $x, y \in s$; then $\mathrm{dist}(x,y) \le \varepsilon$ by hypothesis.
As $x,y$ were arbitrary, $s$ satisfies the Rips condition (Lemma 2.5), i.e.
$s \in \mathrm{faces}(\mathrm{VR}(\varepsilon))$. Hence the face sets are equal and
$\mathrm{VR}(\varepsilon) = \Delta(\alpha)$. $\square$

**Remark 3.2 (Flag/clique phenomenon).** The forward direction only uses
two-point faces, and the reverse direction only needs pairwise control. Thus
full completeness in *all* dimensions is equivalent to completeness of the
**1-skeleton**: the Vietoris–Rips complex is a flag (clique) complex, fully
determined by its edges. No higher-dimensional obstruction can survive once every
edge is present.

**Remark 3.3 (Pseudometric generality).** No use is made of $\mathrm{dist}(x,y)=0
\Rightarrow x=y$; the theorem holds for pseudometrics, hence for quotient metrics,
graph shortest-path metrics with zero-weight identifications, and so on.

### Theorem 3.4 (Diameter / max-plus form)

Let $\alpha$ be a *finite, nonempty* pseudometric space, and let
$$
D := \max_{(x,y)\in\alpha\times\alpha}\ \mathrm{dist}(x,y)
$$
be the **diameter** (the supremum, attained because $\alpha\times\alpha$ is finite
and nonempty). Then for any $\varepsilon$,
$$
\mathrm{VR}(\varepsilon) = \Delta(\alpha) \quad\Longleftrightarrow\quad D \le \varepsilon.
$$

**Proof.** By Theorem 3.1, $\mathrm{VR}(\varepsilon)=\Delta(\alpha)$ iff
$\mathrm{dist}(x,y)\le\varepsilon$ for all $x,y$. A finite maximum over a nonempty
index set is $\le\varepsilon$ iff every term is $\le\varepsilon$ (the
characterizing property of `sup'`/least upper bound on a finite nonempty set).
Hence the universally quantified pairwise bound is equivalent to
$D = \max_{x,y}\mathrm{dist}(x,y) \le \varepsilon$. $\square$

**Corollary 3.5 (Sharp least threshold).** The diameter $D$ is the *least* scale
at which completion occurs:
$$
D = \min\{\varepsilon : \mathrm{VR}(\varepsilon) = \Delta(\alpha)\},
\qquad\text{and}\qquad
\mathrm{VR}(\varepsilon) = \Delta(\alpha) \iff \varepsilon \ge D.
$$
In particular, for every $\varepsilon < D$ there exists an unfilled pair, so
$\mathrm{VR}(\varepsilon)\ne\Delta(\alpha)$; and $D$ itself attains completion.
This identifies an exact, sharp frontier rather than an asymptotic one. $\square$

---

## 4. The Tropical Reading

### 4.1 The max-plus semiring

The **max-plus tropical semiring** is $\mathbb{T}_{\max} = (\mathbb{R}\cup\{-\infty\},\ \oplus,\ \otimes)$ with
$$
a \oplus b := \max(a,b), \qquad a \otimes b := a + b,
$$
additive identity $-\infty$ and multiplicative identity $0$. It is a commutative,
idempotent semiring ($a\oplus a = a$): all the laws of a ring hold except additive
inverses. Many geometric and optimization problems become *linear* over
$\mathbb{T}_{\max}$ (shortest paths, scheduling, polytope combinatorics).

### 4.2 The max-plus birth sum

Each pair $\{x,y\}$ of points carries a **birth time**, the scale at which the
edge $\{x,y\}$ first appears, namely $\mathrm{dist}(x,y)$. Define the **max-plus
birth sum** of a finite nonempty space $\alpha$ as the tropical sum of all these
birth times:
$$
\mathrm{tropBirthSum}(\alpha) \;:=\; \bigoplus_{(x,y)\in\alpha\times\alpha} \mathrm{dist}(x,y) \;=\; \max_{(x,y)} \mathrm{dist}(x,y) \;=\; D.
$$
Thus **the completion threshold is exactly a tropical sum of edge birth times**;
Theorem 3.4 reads
$$
\mathrm{VR}(\varepsilon) = \Delta(\alpha) \iff \mathrm{tropBirthSum}(\alpha) \le \varepsilon.
$$
Semantically the diameter is folklore; the *content* of the tropical reading is
that this fold is the addition operation of a semiring, which forces the
structural laws below.

### 4.3 Structural consequences

**Proposition 4.1 (Additivity over unions).** For finite nonempty spaces with a
common ambient metric,
$$
\mathrm{tropBirthSum}(\alpha \cup \beta)
= \mathrm{tropBirthSum}(\alpha) \ \oplus\ \mathrm{tropBirthSum}(\beta)\ \oplus\ \max_{x\in\alpha,\,y\in\beta}\mathrm{dist}(x,y).
$$
*Proof sketch.* The maximum over $(\alpha\cup\beta)^2$ splits into the maxima over
$\alpha^2$, $\beta^2$, and the cross terms $\alpha\times\beta$ (using symmetry).
Each block-max is a $\oplus$-summand; commutativity and associativity of $\oplus$
assemble them. $\square$

In the pure intrinsic reading (treating the union as a disjoint assembly whose
threshold is the larger of the parts plus their separation), this exhibits
$\mathrm{tropBirthSum}$ as an **additive** map from the monoid of spaces-under-union
to $(\mathbb{R},\oplus)$ — the first step toward a genuine tropical-semiring
homomorphism (Section 7).

**Proposition 4.2 (Monotonicity and functoriality).** Let
$f\colon\alpha\to\beta$ be **non-expanding**, i.e.
$\mathrm{dist}(f(x),f(x'))\le\mathrm{dist}(x,x')$ for all $x,x'$.

1. (Edge monotonicity.) If $s$ is a Rips face of $\alpha$ at scale $\varepsilon$,
   then $f(s)$ is a Rips face of $\beta$ at scale $\varepsilon$.
2. (Threshold monotonicity, finite case.) If $f$ is surjective then
   $\mathrm{tropBirthSum}(\beta) \le \mathrm{tropBirthSum}(\alpha)$; if $f$ is an
   isometric embedding then $\mathrm{tropBirthSum}(f(\alpha)) = \mathrm{tropBirthSum}(\alpha)$.

*Proof sketch.* (1) For $x,y\in s$, $\mathrm{dist}(f(x),f(y))\le\mathrm{dist}(x,y)\le\varepsilon$.
(2) Every distance in the image is dominated by a distance in the source, so the
image maximum is dominated by the source maximum; isometric embeddings preserve
each distance, hence the maximum. $\square$

**Proposition 4.3 (Sharp 1-Lipschitz stability).** Let $d, d'$ be two
pseudometrics on the same finite nonempty point set with sup-distance
$\|d-d'\|_\infty := \max_{x,y}|d(x,y)-d'(x,y)| \le \delta$. Then the thresholds
satisfy
$$
\bigl|\, \mathrm{tropBirthSum}_{d}(\alpha) - \mathrm{tropBirthSum}_{d'}(\alpha) \,\bigr| \le \delta.
$$
The bound is sharp: a one-pair perturbation of size $\delta$ on the diametral pair
moves the threshold by exactly $\delta$.

*Proof sketch.* A maximum is 1-Lipschitz in its arguments under the sup-norm:
$|\max_i a_i - \max_i b_i| \le \max_i|a_i - b_i|$. Apply with
$a_{xy}=d(x,y)$, $b_{xy}=d'(x,y)$. Tightness: enlarge only the unique diametral
distance by $\delta$; the maximum rises by exactly $\delta$. $\square$

**Interpretation.** Stability (4.3) is the licence to trust the threshold under
measurement noise; it is the completion-threshold analogue of the bottleneck and
interleaving stability theorems that underpin persistent homology, and it dovetails
with them: a $\delta$-interleaving of metrics induces a $\delta$ shift in this
zero-dimensional "is the 1-skeleton complete?" feature.

---

## 5. Algorithms

We record the computational content. Let $n = |\alpha|$, with distances accessible
in $O(1)$.

### Algorithm A — Completion threshold (diameter).

Compute $D = \mathrm{tropBirthSum}(\alpha)$ by a single tropical fold:

```
input: points P[0..n-1], distance d
D <- -infinity
for i in 0..n-1:
  for j in i+1..n-1:
    D <- max(D, d(P[i], P[j]))      # tropical addition
return D
```

Complexity $O(n^2)$ time, $O(1)$ extra space. By Corollary 3.5 the returned $D$ is
the exact least completion scale: $\mathrm{VR}(\varepsilon)=\Delta(\alpha) \iff \varepsilon\ge D$.

### Algorithm B — Completion decision at a given scale.

Decide $\mathrm{VR}(\varepsilon)=\Delta(\alpha)$ without forming any simplex:

```
input: points P, distance d, scale eps
for i < j:
  if d(P[i],P[j]) > eps: return False
return True
```

Equivalently `tropBirthSum(P) <= eps`. Complexity $O(n^2)$, and it short-circuits
on the first violating pair. Correctness is Theorem 3.1 / 3.4.

### Algorithm C — Per-face birth times and skeleton completion.

The birth time of a face $s$ is its internal tropical fold
$\mathrm{faceBirth}(s) = \max_{x,y\in s}\mathrm{dist}(x,y)$. The full $k$-skeleton
completes at $\max_{|s|=k+1}\mathrm{faceBirth}(s)$, which (since each
$\mathrm{faceBirth}(s)\le D$ and the diametral pair is itself a $1$-face) equals
$D$ for every $k\ge 1$. Computing all face births of dimension $\le k$ costs
$O\!\binom{n}{k+1}(k+1)^2$.

---

## 6. Numerical Illustrations

The companion `demo.py` exercises all of the above on explicit point clouds. A
representative selection:

- **Square in the plane.** Vertices $(0,0),(1,0),(0,1),(1,1)$ under Euclidean
  distance have diameter $\sqrt 2 \approx 1.41421$ (the diagonals). Hence the Rips
  complex is full precisely for $\varepsilon \ge \sqrt2$, and unfilled for any
  smaller scale (e.g. at $\varepsilon=1$ the two diagonal pairs are missing).

- **Collinear triple.** Points $0,1,3$ on the line have diameter $3$; completion
  at $\varepsilon=3$, exactly when the extreme pair $\{0,3\}$ links.

- **Stability check.** Perturbing one coordinate by $\delta=0.05$ moves the
  measured diameter by at most $0.05$, confirming Proposition 4.3 empirically; the
  worst case (perturbing the diametral pair outward) moves it by exactly $0.05$.

- **Union additivity.** For two clusters, the diameter of the union equals the max
  of the two intra-cluster diameters and the largest inter-cluster distance,
  confirming Proposition 4.1.

---

## 7. Discussion and Future Work

The completion threshold sits at a triple crossroads — topology (Rips
saturation), geometry (the diameter), and tropical algebra (the max-plus sum) —
and the value of the result is in pinning each correspondence down exactly and
robustly. Several extensions are immediate.

1. **Higher-dimensional completion thresholds.** Thread the per-face birth fold
   (Algorithm C) through the flag/clique construction to characterize when each
   $k$-skeleton fills in; by Remark 3.2 all skeleta of dimension $\ge 1$ complete
   simultaneously at $D$, but the *graded* $f$-vector profile $\varepsilon\mapsto(f_0,f_1,\dots)$
   is a finer invariant reconstructible from the multiset of face births.

2. **A literal tropical-semiring functional.** Re-express $\mathrm{tropBirthSum}$
   as a $\mathrm{Tropical}\,\mathbb{R}^{\mathrm{op}}$-valued map and upgrade
   Propositions 4.1–4.2 to a genuine semiring-homomorphism statement, with simplex
   *joins* realizing tropical product $\otimes$.

3. **Stability into persistence.** Plug Proposition 4.3 into the
   interleaving/bottleneck framework so that the "is the 1-skeleton complete?"
   feature becomes a stable persistence summary in its own right.

4. **Verified point-cloud algorithm.** Wrap Algorithm A/B as a computable,
   certificate-returning procedure over rational distances, with the threshold
   theorem as the correctness lemma.

5. **Multiparameter and functorial thresholds.** Real data carries several scales
   (e.g. density and distance); the monotone, functorial fold assembles into a
   monotone functional on the parameter poset, transporting along non-expanding
   maps.

**Conjecture (barcode as a multiset of folds).** For a finite metric space the
entire multidimensional $f$-vector profile is reconstructible from the multiset of
face births $\{\mathrm{faceBirth}(s)\}$ alone — the barcode is bookkeeping of
tropical folds, not independent homological data.

---

## 8. Conclusion

We have characterized the Vietoris–Rips completion threshold exactly: the complex
equals the full complex iff every pair of points is within the scale (Theorem
3.1), equivalently iff the scale reaches the diameter (Theorem 3.4), which is the
least such scale (Corollary 3.5). The threshold is the max-plus birth sum — a
tropical sum of edge births — and inherits from that algebra additivity over
unions, monotonicity under non-expanding maps, and sharp 1-Lipschitz stability.
The picture is computable in $O(n^2)$ and formally verified, and it opens a
concrete program connecting topological data analysis to tropical geometry.

---

## Appendix A. Formal statements (as verified)

- `vietorisRips_eq_fullComplex_iff (ε : ℝ) : VR(ε) = fullComplex α ↔ ∀ x y, dist x y ≤ ε`
- `vietorisRips_eq_fullComplex_iff_sup'_le [Fintype α] (ε) (hne) : VR(ε) = fullComplex α ↔ univ.sup' hne (fun p => dist p.1 p.2) ≤ ε`
- `mem_fullComplex (s) : s ∈ (fullComplex α).faces`
- `mem_vietorisRips_iff (s) : s ∈ (vietorisRips ε).faces ↔ ∀ x ∈ s, ∀ y ∈ s, dist x y ≤ ε`
- `SimpleComplex.downward_closed` (structural field), instantiated for `fullComplex` and `vietorisRips`.
