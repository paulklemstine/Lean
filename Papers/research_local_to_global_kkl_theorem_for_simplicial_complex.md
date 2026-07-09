# A Local-to-Global Principle for Coordinate Influence

## Abstract

The influence of a coordinate on a Boolean function measures how often flipping
that coordinate changes the function's value. Influence is central to the analysis
of Boolean functions, to hardness of approximation, and to the study of robustness
and diffusion in cryptographic constructions. The Kahn–Kalai–Linial (KKL) theorem
is a *local* statement about a single function: any non-degenerate function of low
total influence must have a coordinate whose influence is unusually large. In this
paper we isolate and prove a complementary *local-to-global* principle. We show
that influence **self-averages over links**: the global influence of a coordinate
is a weighted average of its influences on the codimension-one restrictions (links)
of the underlying combinatorial object. From this single identity we derive a
family of local-to-global theorems: (i) on the Boolean cube, a total-influence
lower bound on both links of a coordinate forces a globally influential
coordinate; (ii) an abstract averaging engine that runs on any weighted family of
links, converting a *local KKL hypothesis* into a *global total-influence bound*
and a *global influential coordinate*; (iii) a faithful conditional (variance-
thresholded) version matching the true logical shape of KKL; and (iv) an exact
total-influence law for regular systems. The Boolean cube is recovered as a
literal instance of the abstract engine. We discuss algorithms, numerical
illustrations, and the road toward the full logarithmic KKL bound on
high-dimensional expanders.

## 1. Introduction

Let $f : \{0,1\}^n \to \{0,1\}$ be a Boolean function. The **influence** of
coordinate $i$ is the probability, over a uniformly random input, that flipping the
$i$-th bit changes the output. Equivalently, working with unnormalized counts,
it is the number of edges of the Boolean hypercube in direction $i$ whose two
endpoints receive different values under $f$. Influences quantify the sensitivity
of a function to individual inputs and are foundational objects in discrete
Fourier analysis, social choice theory, percolation, property testing, and the
theory of pseudorandomness underpinning cryptography.

The Kahn–Kalai–Linial theorem (1988) is the archetypal *local* result: for a
balanced $f$, some coordinate has influence at least $\Omega(\log n / n)$, far
exceeding the average $\mathrm{TotInf}(f)/n$ one would expect under uniform spread.
More generally, KKL guarantees a coordinate of influence
$\Omega(\mathrm{Var}(f) \cdot \log n / n)$.

A distinct and highly productive modern paradigm is **local-to-global** analysis,
central to the theory of high-dimensional expanders (Bafna–Hoory–Kaufman 2022;
Gur–Lifshitz–Liu 2022; Gotlib–Kaufman 2023). Here one proves properties of a large
combinatorial complex by verifying properties only of its **links** — the small
neighborhoods obtained by fixing a face. The recurring question is: *if every link
satisfies a property, does the whole complex?*

This paper addresses that question for influence. Our contribution is to identify
the exact structural mechanism — an averaging identity we call the **bridge** —
that transfers influence information from links to the whole object, and to build a
small tower of theorems on top of it. The results are elementary but reusable: the
bridge is the combinatorial heart shared by every local-to-global influence
argument.

### Contributions

1. **The bridge (influence self-averaging).** On the Boolean cube, each coordinate
   influence is exactly the sum of its influences in the two codimension-one links
   of any fixed coordinate.
2. **Flagship cube theorem.** A local total-influence lower bound $T$ on both links
   of a coordinate $j$ yields a coordinate $i \ne j$ with $(n-1)\,\mathrm{Inf}(f,i)
   \ge 2T$.
3. **Abstract engine.** For an arbitrary weighted family of links satisfying the
   bridge, a local KKL hypothesis (each link has an influential coordinate) yields
   a global total-influence bound and a global influential coordinate.
4. **Faithful conditional and exact regular law.** A variance-thresholded version
   matching the true KKL conditional, and an exact total-influence identity for
   regular systems.
5. **Instantiation.** The Boolean cube is a literal instance of the abstract
   engine (two unit-weight links).

## 2. The concrete model: the Boolean cube and its links

Throughout, $n \ge 1$ and a point of the cube is a function $x : \{0,\dots,n-1\}
\to \{0,1\}$, written $x \in \{0,1\}^n$.

**Definition 2.1 (Coordinate flip).** For $x \in \{0,1\}^n$ and coordinate $i$,
let $x^{\oplus i}$ denote $x$ with its $i$-th coordinate negated and all other
coordinates unchanged. Flipping is an involution, $(x^{\oplus i})^{\oplus i} = x$,
and for $j \ne i$ we have $(x^{\oplus i})_j = x_j$ — moving along direction $i$
leaves coordinate $j$ untouched.

**Definition 2.2 (Influence).** The (unnormalized) **influence** of coordinate $i$
on $f : \{0,1\}^n \to \{0,1\}$ is
$$\mathrm{Inf}(f,i) = \#\{\, x \in \{0,1\}^n : f(x) \ne f(x^{\oplus i}) \,\}.$$
(Each sensitive $i$-edge $\{x, x^{\oplus i}\}$ is counted at both endpoints; the
count is even and equals twice the number of sensitive $i$-edges. All our identities
are homogeneous in this convention, so it is immaterial.)

**Definition 2.3 (Link influence).** Fix a coordinate $j$ and value $b \in
\{0,1\}$. The **link** of the frozen vertex $(j, b)$ is the subcube $\{x : x_j =
b\}$, a copy of $\{0,1\}^{n-1}$. The **link influence** of coordinate $i$ in this
link is
$$\mathrm{InfSub}(f, j, b, i) = \#\{\, x : x_j = b \ \text{and}\ f(x) \ne f(x^{\oplus i}) \,\}.$$

**Definition 2.4 (Total influences).** The **total influence** is $\mathrm{TotInf}(f)
= \sum_i \mathrm{Inf}(f, i)$. The **link total influence** of the link $(j, b)$,
summed over coordinates other than the frozen one, is
$$\mathrm{LinkTotInf}(f, j, b) = \sum_{i \ne j} \mathrm{InfSub}(f, j, b, i).$$

### 2.1 The bridge

**Theorem 2.5 (Influence self-averaging — the bridge).** For every function $f$
and every pair of coordinates $j, i$,
$$\mathrm{Inf}(f, i) = \mathrm{InfSub}(f, j, 0, i) + \mathrm{InfSub}(f, j, 1, i).$$

*Proof sketch.* The set of inputs $x$ with $f(x) \ne f(x^{\oplus i})$ partitions
according to the value of $x_j \in \{0,1\}$; the two parts are counted exactly by
$\mathrm{InfSub}(f,j,0,i)$ and $\mathrm{InfSub}(f,j,1,i)$. Formally, split the
filtered set by the predicate $x_j = 1$ using the identity
$|\{P\}| = |\{P \wedge Q\}| + |\{P \wedge \neg Q\}|$, and identify the two pieces
with the link counts. $\square$

An immediate consequence is monotonicity: each link influence is bounded by the
global influence, $\mathrm{InfSub}(f, j, b, i) \le \mathrm{Inf}(f, i)$, since the
other summand is non-negative.

**Theorem 2.6 (Total-influence decomposition).** For every $f$ and coordinate $j$,
$$\sum_{i \ne j} \mathrm{Inf}(f, i) = \mathrm{LinkTotInf}(f, j, 0) + \mathrm{LinkTotInf}(f, j, 1).$$

*Proof sketch.* Sum the bridge (Theorem 2.5) over all $i \ne j$ and regroup the
two summands. $\square$

### 2.2 Pigeonhole and the flagship theorem

**Lemma 2.7 (Some element beats the average).** For a finite nonempty set $S$ and
$g : S \to \mathbb{N}$, there exists $i \in S$ with $\sum_{k \in S} g(k) \le |S|
\cdot g(i)$.

*Proof sketch.* Take $i$ maximizing $g$; then $\sum_{k} g(k) \le \sum_{k} g(i) =
|S| \cdot g(i)$. $\square$

**Theorem 2.8 (Local-to-Global KKL, cube form).** Let $n \ge 2$ and fix a
coordinate $j$. Suppose both links of $j$ carry total influence at least $T$:
$$T \le \mathrm{LinkTotInf}(f, j, 0) \quad\text{and}\quad T \le \mathrm{LinkTotInf}(f, j, 1).$$
Then there exists a coordinate $i \ne j$ with
$$2T \le (n-1)\,\mathrm{Inf}(f, i),$$
i.e. $\mathrm{Inf}(f, i) \ge 2T/(n-1)$.

*Proof sketch.* By Theorem 2.6, $\sum_{i \ne j}\mathrm{Inf}(f, i) \ge 2T$. The
index set $\{i : i \ne j\}$ has size $n - 1 \ge 1$, so it is nonempty; apply Lemma
2.7 with $g = \mathrm{Inf}(f, \cdot)$ to obtain $i \ne j$ with $\sum_{i \ne
j}\mathrm{Inf}(f, i) \le (n-1)\,\mathrm{Inf}(f, i)$. Chaining the two inequalities
gives $2T \le (n-1)\,\mathrm{Inf}(f, i)$. $\square$

**Theorem 2.9 (Local ⟹ global influential coordinate).** If some coordinate $i$
is influential inside a link, $\tau \le \mathrm{InfSub}(f, j, b, i)$, then it is at
least as influential globally, $\tau \le \mathrm{Inf}(f, i)$.

*Proof sketch.* Immediate from monotonicity $\mathrm{InfSub} \le \mathrm{Inf}$
(a corollary of the bridge). $\square$

## 3. The abstract local-to-global engine

The argument above uses only three features: a weighted family of links, a notion
of local influence, and the bridge. We abstract them.

Let the coordinates be indexed by a finite type and let the links be indexed by a
finite type $\kappa$. Let $w : \kappa \to \mathbb{R}$ assign non-negative weights,
let $I_\ell(i) \ge 0$ be the local influence of coordinate $i$ in link $\ell$, and
let $I(i)$ be the global influence.

**Theorem 3.1 (Abstract local-to-global KKL).** Assume:
- (weights) $w_\ell \ge 0$ for all $\ell$, and (non-negativity) $I_\ell(i) \ge 0$;
- (**bridge**) $I(i) = \sum_{\ell} w_\ell \, I_\ell(i)$ for every coordinate $i$;
- (**local KKL**) every link has an influential coordinate: for each $\ell$ there
  is $i$ with $\tau \le I_\ell(i)$.

Then the global total influence satisfies
$$\tau \cdot \sum_{\ell} w_\ell \;\le\; \sum_i I(i).$$

*Proof sketch.* Exchange the order of summation using the bridge:
$\sum_i I(i) = \sum_i \sum_\ell w_\ell I_\ell(i) = \sum_\ell w_\ell \big(\sum_i
I_\ell(i)\big)$. For each $\ell$, the local KKL coordinate $i_0$ gives $\tau \le
I_\ell(i_0) \le \sum_i I_\ell(i)$ (a single term is at most the non-negative sum).
Hence $\sum_\ell w_\ell (\sum_i I_\ell(i)) \ge \sum_\ell w_\ell \tau = \tau
\sum_\ell w_\ell$. $\square$

**Lemma 3.2 (Real averaging).** For a nonempty finite index type and $g : \iota
\to \mathbb{R}$, there exists $i$ with $\sum_j g(j) \le |\iota| \cdot g(i)$.

**Theorem 3.3 (Abstract global influential coordinate).** Under the hypotheses of
Theorem 3.1, with the coordinate type nonempty, there exists a coordinate $i$ with
$$\tau \cdot \sum_{\ell} w_\ell \;\le\; |\text{coords}| \cdot I(i).$$

*Proof sketch.* Combine Theorem 3.1 with Lemma 3.2 applied to $g = I$. $\square$

### 3.1 The cube as an instance

**Theorem 3.4 (Cube via the abstract engine).** Fix $j$ and $T \in \mathbb{N}$.
Suppose each link of $j$ has an influential coordinate: $\exists i,\ T \le
\mathrm{InfSub}(f, j, 0, i)$ and $\exists i,\ T \le \mathrm{InfSub}(f, j, 1, i)$.
Then $2T \le \mathrm{TotInf}(f)$.

*Proof sketch.* Instantiate Theorem 3.1 with link index $\kappa = \{0,1\}$, unit
weights $w \equiv 1$, local influences $I_\ell(i) = \mathrm{InfSub}(f, j, \ell, i)$,
global influence $I(i) = \mathrm{Inf}(f, i)$, and threshold $\tau = T$. The abstract
bridge is precisely the concrete bridge (Theorem 2.5) after summing over the two
Boolean values; $\sum_\ell w_\ell = 2$; and $\sum_i I(i) = \mathrm{TotInf}(f)$. The
conclusion $\tau \cdot 2 \le \sum_i I(i)$ is $2T \le \mathrm{TotInf}(f)$. $\square$

### 3.2 Faithful conditional and regular systems

**Theorem 3.5 (Variance-thresholded local-to-global KKL).** Suppose each link
carries a *variance proxy* $V_\ell$ and a threshold $V_0$, and the local KKL
hypothesis holds in its genuine conditional form: *if $V_0 \le V_\ell$ then link
$\ell$ has a coordinate of influence $\ge \tau$*. If in addition every link is
non-degenerate ($V_0 \le V_\ell$ for all $\ell$), then $\tau \cdot \sum_\ell w_\ell
\le \sum_i I(i)$, and consequently some coordinate satisfies $\tau \sum_\ell w_\ell
\le |\text{coords}| \cdot I(i)$.

*Proof sketch.* Non-degeneracy discharges the conditional on every link, reducing
to Theorems 3.1 and 3.3. $\square$

This version matches the *true logical shape* of KKL: the conclusion "there is an
influential coordinate" is guaranteed precisely for links that are non-degenerate.

**Theorem 3.6 (Exact law for regular systems).** If every link has the same total
influence $\sum_i I_\ell(i) = A$ and every weight is one, then the global total
influence is exactly
$$\sum_i I(i) = |\kappa| \cdot A.$$

*Proof sketch.* By the bridge with unit weights, $\sum_i I(i) = \sum_\ell \sum_i
I_\ell(i) = \sum_\ell A = |\kappa| \cdot A$. $\square$

**Theorem 3.7 (Cube, real-valued influential coordinate).** For $n \ge 1$, if each
of the two links of $j$ has an influential coordinate of influence $\ge T$, then
some global coordinate satisfies $2T \le n \cdot \mathrm{Inf}(f, i)$.

*Proof sketch.* Theorem 3.4 gives $2T \le \mathrm{TotInf}(f)$; real averaging
(Lemma 3.2) over all $n$ coordinates yields a coordinate at least the average.
$\square$

## 4. Algorithms

The theory is fully constructive; the underlying computations are direct counts and
scans. We highlight two algorithmic primitives.

**Algorithm A (Influence and link-influence tabulation).** Given $f$ as a truth
table over $\{0,1\}^n$, compute $\mathrm{Inf}(f, i)$ for all $i$ and
$\mathrm{InfSub}(f, j, b, i)$ for all $i, j, b$ by iterating over all $2^n$ inputs
and, for each coordinate $i$, comparing $f(x)$ with $f(x^{\oplus i})$. Complexity
$O(n \cdot 2^n)$ time. The bridge (Theorem 2.5) is then verified by a coordinate-
wise equality check.

**Algorithm B (Local-to-global certificate).** Given the guarantee $T \le
\mathrm{LinkTotInf}(f, j, b)$ for both $b$, output a coordinate $i \ne j$
witnessing $2T \le (n-1)\,\mathrm{Inf}(f, i)$: simply return the influence-maximizing
coordinate among $i \ne j$. Correctness is Theorem 2.8; complexity $O(n)$ after
tabulation.

## 5. Applications

- **Robustness and diffusion.** Influence quantifies output sensitivity to single
  input bits. The local-to-global law lets one certify sensitivity properties of a
  function from properties of its bit-restrictions, a natural decomposition when
  analyzing diffusion in symmetric primitives or resilience of shared-randomness
  protocols.
- **High-dimensional expansion.** The abstract engine consumes exactly the bridge
  $I(i) = \sum_\ell w_\ell I_\ell(i)$. Any complex furnishing such a self-averaging
  identity over its links inherits the influence local-to-global theorems,
  connecting to the broader local-to-global program for expanders.
- **Analysis of Boolean functions.** The results give a clean, modular route from
  restriction-level information to global influential coordinates, complementary to
  Fourier-analytic proofs of KKL.

## 6. Discussion and limitations

The global conclusions here are **averaging** bounds (max $\ge$ average). They are
tight for the mechanism used — a pigeonhole on the total influence — but weaker
than the full KKL theorem, which extracts a coordinate of influence $\Omega(\mathrm
{Var}(f)\,\log n / n)$ even when the total influence is small. Bridging that gap
requires the Fourier-analytic and hypercontractive machinery (Bonami–Beckner)
that the elementary averaging argument deliberately avoids. The value of the
present development is its **modularity**: the bridge is isolated as the single
transferable hypothesis, so any object supplying it inherits the theorems.

## 7. Future directions

1. **The genuine KKL logarithmic bound.** Upgrade the averaging conclusion to the
   true $\Omega(\mathrm{Var}(f)\,\log n / n)$ influential coordinate, via Fourier
   analysis on the cube and hypercontractivity / the Bonami–Beckner inequality.
2. **True simplicial complexes.** Replace the cube by a pure $d$-dimensional
   complex with a measure on top faces, define links and induced local functions,
   and *derive* the bridge $I(i) = \sum_\ell w_\ell I_\ell(i)$ from the complex
   structure. The abstract engine already consumes exactly this bridge.
3. **Weighted / spectral links.** Incorporate the spectral gap of links (high-
   dimensional expansion) to turn the local bound into a stronger,
   expansion-dependent global bound.
4. **Variance transfer.** Prove a local-to-global statement for the variance proxy
   itself, so global non-degeneracy follows from local non-degeneracy, closing the
   loop with the variance-thresholded theorem.
5. **Hypercontractivity on high-dimensional expanders.** Formalize the
   Gur–Lifshitz–Liu hypercontractive inequality on high-dimensional expanders, from
   which KKL-type theorems follow directly — an alternative route to item 1.

## 8. Conclusion

We isolated the influence self-averaging identity — the *bridge* — and showed it is
the reusable engine behind local-to-global theorems for coordinate influence. From
the bridge alone we obtained a flagship cube theorem, an abstract averaging engine,
a faithful conditional version, and an exact regular law, with the cube recovered as
a literal instance. Global power is the sum of local power, and a uniform floor on
the links raises the ceiling of the whole complex.

## References

- J. Kahn, G. Kalai, N. Linial. *The influence of variables on Boolean functions.*
  FOCS 1988.
- M. Bafna, S. Hoory, T. Kaufman. Local-to-global expansion and applications, 2022.
- T. Gur, N. Lifshitz, S. Liu. Hypercontractivity on high-dimensional expanders,
  2022.
- R. Gotlib, T. Kaufman. Local-to-global in higher dimensions, 2023.
- A. Bonami. Étude des coefficients de Fourier des fonctions de $L^p(G)$, 1970.
- R. O'Donnell. *Analysis of Boolean Functions.* Cambridge University Press, 2014.
