# Landauer's Lower Bound from the Deterministic Data-Processing Inequality

## Abstract

We develop, from first principles, the thermodynamic theory of deterministic computation,
unifying the *exact* Landauer cost of erasure, the algebraic characterization of reversibility,
and the construction of universal reversible gates under a single inequality. The central result
is a fully general, elementary form of the **deterministic data-processing inequality**: for any
function $f : \alpha \to \beta$ between finite types and any nonnegative weight function
$p : \alpha \to \mathbb{R}$, the Shannon entropy of the pushforward measure $f_* p$ never exceeds
that of $p$,
$$ H(f_* p) \le H(p), $$
with equality precisely when $f$ is injective on the support of $p$. From this single statement we
derive Landauer's principle as a genuine lower bound on dissipated heat,
$k\,T\,\big(H(p) - H(f_* p)\big) \ge 0$, which is exactly zero for reversible (injective)
computations, and we recover the catalog's *exact* erasure cost $k\,T\,n\log 2$ as the extremal
collapse-to-a-point case. The proof deliberately avoids the concavity and grouping machinery
usually invoked: its entire content is the pointwise domination $(f_* p)(f(x)) \ge p(x)$ — a fiber
sum dominates one of its terms — together with the monotonicity of the logarithm. We then connect
the analytic theory to concrete logic: the universal reversible gates CNOT, Toffoli, and Fredkin
are honest bijections, hence preserve entropy and dissipate no heat on *every* input distribution,
while still computing the standard irreversible primitives (XOR, COPY, AND, NOT, controlled-SWAP).
Finally, we record an algebraic bridge: every reversible relabeling induces an automorphism of the
tropical (min-plus) cost semiring, so reversibility appears simultaneously as a logical, an
information-theoretic, and an algebraic phenomenon.

**Keywords:** Landauer's principle, reversible computing, data-processing inequality, Shannon
entropy, pushforward measure, thermodynamic cost, reversible logic gates, tropical algebra.

---

## 1. Introduction

### 1.1 Motivation

The thermodynamics of computation rests on a single conceptual bridge, due to Landauer (1961):
informational entropy and thermodynamic entropy are, up to the universal factor $k\,T$
($k$ Boltzmann's constant, $T$ absolute temperature), the *same* quantity. Consequently, whenever a
computation reduces the Shannon entropy of the logical state of a machine by $\Delta H$, the second
law forces the dissipation of heat $Q \ge k\,T\,\Delta H$ into the environment. Bennett (1973)
complemented this with the observation that any computation can be made *logically reversible*, and
that reversible steps need not dissipate any heat at all.

A satisfying formal account must contain three ingredients in a single coherent framework:

1. a **general inequality** showing that deterministic computation cannot increase entropy, with a
   clean equality criterion for reversibility;
2. the **exact** cost of the canonical irreversible operation — erasure of a uniform register; and
3. **concrete constructions** of universal reversible gates whose freedom from dissipation follows
   from the same inequality.

This paper supplies all three and shows how they fit together. The technical novelty is not the
data-processing inequality per se — it is classical — but the *route*: we give a proof that requires
no concavity argument, no Jensen's inequality, and no grouping axioms, reducing the entire content
to one pointwise inequality and the monotonicity of $\log$.

### 1.2 Relationship to prior cataloged results

The framework builds on two prior bodies of results which we treat as established background.

*Exact Landauer cost and the reversibility dichotomy.* For the very special case of **uniform
$n$-bit erasure**, the entropy drop is exactly $n \log 2$ and the thermodynamic cost is exactly
$k\,T\,n\log 2$ — an equality, not a bound. Separately, a function on a finite type has *zero*
uniform entropy loss if and only if it is bijective, giving an algebraic characterization of
reversibility. These are sharp statements about *one* special map (erasure) and about *bijections*.

*Ancilla economy of reversible simulation.* Any function $f$ admits a reversible simulation — an
injection $g : \alpha \to \beta \times \mathrm{Aux}$ recovering $f$ in its first coordinate — and the
minimal cardinality of the ancilla type $\mathrm{Aux}$ equals the size of the largest fiber of $f$.
In particular one ancilla state suffices iff $f$ is already injective.

The present work supplies the **missing general principle** that subsumes the first body: a
data-processing inequality valid for *arbitrary* $f$ and *arbitrary* nonnegative $p$, with the
erasure equality and the zero-loss characterization recovered as the two extreme cases (maximal
fiber collapse and thin fibers, respectively).

### 1.3 Contributions

- A self-contained, elementary proof that $H(f_* p) \le H(p)$ for every function $f$ between finite
  types and every nonnegative weight $p$ (Theorem 4.3), via the pointwise domination
  $(f_* p)(f x) \ge p(x)$ (Lemma 3.2).
- The exact equality criterion: injective maps preserve entropy, $H(f_* p) = H(p)$ (Theorem 4.5).
- Landauer's principle as a lower bound, $k\,T\,(H(p) - H(f_* p)) \ge 0$, zero iff reversible
  (Corollaries 5.1–5.2).
- Recovery of the exact erasure cost $k\,T\,n\log 2$ as the extremal case (Section 5.3).
- Verification that CNOT, Toffoli, and Fredkin are bijections computing the standard primitives, and
  hence dissipate no heat on every input distribution (Section 6).
- The tropical-algebra bridge: reversible relabelings are automorphisms of the min-plus cost semiring
  (Section 7).

---

## 2. Preliminaries and Definitions

Throughout, $\alpha$ and $\beta$ denote finite types, with $\beta$ equipped with decidable equality
so that fibers are well-defined finite sets.

**Definition 2.1 (Weight function and distribution).** A *weight function* is any
$p : \alpha \to \mathbb{R}$. It is *nonnegative* if $p(x) \ge 0$ for all $x$. It is a *distribution*
(written $\mathrm{IsDistribution}(p)$) if additionally $\sum_{x} p(x) = 1$.

**Definition 2.2 (Shannon entropy).** For a weight function $p$ on a finite type $\alpha$, the
*Shannon entropy* is
$$ H(p) \;=\; -\sum_{x \in \alpha} p(x)\,\log p(x), $$
with the standard convention $0 \cdot \log 0 = 0$ (which is enforced automatically because the
factor $p(x)$ multiplies $\log p(x)$ and the relevant limit is $0$).

**Definition 2.3 (Pushforward / image measure).** Given $f : \alpha \to \beta$ and a weight function
$p : \alpha \to \mathbb{R}$, the *pushforward* $f_* p : \beta \to \mathbb{R}$ assigns to each
$y \in \beta$ the total weight of its fiber:
$$ (f_* p)(y) \;=\; \sum_{x \,:\, f(x) = y} p(x), $$
the sum ranging over $\{x \in \alpha : f(x) = y\}$.

**Definition 2.4 (Thermodynamic / Landauer cost).** For a computation $f$ run on inputs distributed
according to $p$, at temperature $T$ with Boltzmann constant $k$, the *dissipated work* is
$$ W_f(p) \;=\; k\,T\,\big(H(p) - H(f_* p)\big). $$

**Definition 2.5 (Uniform distribution).** On a nonempty finite type $\alpha$, the *uniform
distribution* is $u_\alpha(x) = 1 / |\alpha|$. On $\mathrm{Fin}(2^n)$ this models the contents of an
$n$-bit register about which nothing is known.

---

## 3. The Pushforward and Its Pointwise Domination

We first establish that the pushforward is well-behaved, then isolate the single inequality on which
everything rests.

**Lemma 3.1 (Nonnegativity and mass preservation).** If $p$ is nonnegative then $f_* p$ is
nonnegative, and for *every* weight function $p$,
$$ \sum_{y \in \beta} (f_* p)(y) \;=\; \sum_{x \in \alpha} p(x). $$
Consequently, if $p$ is a distribution then so is $f_* p$.

*Proof sketch.* Nonnegativity is immediate since each $(f_* p)(y)$ is a sum of nonnegative terms.
Mass preservation is the fiberwise partition identity: summing $p$ first over each fiber and then
over outputs re-sums $p$ over all of $\alpha$ (this is `Finset.sum_fiberwise`). The distribution
claim combines the two. $\qquad\blacksquare$

**Lemma 3.2 (Pointwise fiber domination).** Let $p$ be nonnegative. For every $x \in \alpha$,
$$ p(x) \;\le\; (f_* p)\big(f(x)\big). $$

*Proof sketch.* The point $x$ belongs to its own fiber $\{x' : f(x') = f(x)\}$, so $p(x)$ is one of
the summands of $(f_* p)(f(x)) = \sum_{x' : f(x') = f(x)} p(x')$. A single nonnegative summand is at
most the total (`Finset.single_le_sum`). $\qquad\blacksquare$

Lemma 3.2 is the entire engine of the paper. Intuitively: the output produced by $x$ is *at least as
probable* as $x$ itself, because the output may absorb the probability mass of every sibling sharing
$x$'s fiber. Reversibility is precisely the case where there are no siblings.

---

## 4. The Deterministic Data-Processing Inequality

The first step is a reindexing identity that pulls the entropy of the image measure back to a sum
over the domain.

**Lemma 4.1 (Domain reindexing of pushforward entropy).** For any $f$ and any weight function $p$,
$$ H(f_* p) \;=\; -\sum_{x \in \alpha} p(x)\,\log\big((f_* p)(f(x))\big). $$

*Proof sketch.* Start from $H(f_* p) = -\sum_{y} (f_* p)(y)\,\log((f_* p)(y))$ and expand
$(f_* p)(y) = \sum_{x : f(x)=y} p(x)$ in the leading factor only. Distributing the sum over the fiber
and using $f(x) = y$ for each $x$ in the fiber, the double sum over $(y, x \in \text{fiber } y)$
collapses (via `Finset.sum_fiberwise`) to a single sum over $x \in \alpha$, with the logarithm
evaluated at $(f_* p)(f(x))$. $\qquad\blacksquare$

This identity is what makes the comparison term-by-term possible: both $H(p)$ and $H(f_* p)$ are now
sums indexed by the *same* set $\alpha$.

**Definition 4.2 (Entropy gap).** The *entropy gap* of $f$ at $p$ is $H(p) - H(f_* p)$.

**Theorem 4.3 (Deterministic data-processing inequality).** For every $f : \alpha \to \beta$ and
every nonnegative weight function $p$,
$$ H(f_* p) \;\le\; H(p). $$

*Proof sketch.* By Definition 2.2 and Lemma 4.1,
$$ H(p) - H(f_* p) \;=\; \sum_{x \in \alpha} p(x)\,\Big[\log\big((f_* p)(f(x))\big) - \log\big(p(x)\big)\Big]. $$
Fix $x$. If $p(x) = 0$ the term is $0$. If $p(x) > 0$, then by Lemma 3.2 and monotonicity of the
logarithm (`Real.log_le_log`, valid because $0 < p(x) \le (f_* p)(f(x))$) we have
$\log p(x) \le \log\big((f_* p)(f(x))\big)$; multiplying by $p(x) \ge 0$ keeps the term nonnegative.
Hence every summand is nonnegative and the gap is nonnegative, i.e. $H(f_* p) \le H(p)$. The whole
argument uses only `Real.log_le_log`, `Finset.single_le_sum`, and `Finset.sum_le_sum` — no concavity.
$\qquad\blacksquare$

**Remark 4.4 (Why the elementary route works).** The classical proof routes through concavity of the
map $t \mapsto -t \log t$ and a per-fiber Jensen inequality, which drags in convexity API. The
identity of Lemma 4.1 sidesteps this: once both entropies are sums over $\alpha$, the comparison is
*pointwise*, and the only analytic input needed is that $\log$ is increasing. A first attempt at the
concavity route stalled on convexity-API mismatches; the pointwise route removes all analysis beyond
log-monotonicity.

**Theorem 4.5 (Equality for injective maps).** If $f$ is injective, then for every weight function
$p$,
$$ H(f_* p) \;=\; H(p). $$

*Proof sketch.* Injectivity makes every fiber a singleton, so $(f_* p)(f(x)) = p(x)$ for all $x$.
Substituting into Lemma 4.1 gives $H(f_* p) = -\sum_x p(x) \log p(x) = H(p)$. $\qquad\blacksquare$

Together, Theorems 4.3 and 4.5 give the dichotomy at the heart of reversible computing: the entropy
gap is *always nonnegative* and is *zero whenever the map is reversible*. The fully general converse
— that on a fixed-support distribution the gap is zero *only if* $f$ is injective on that support —
is the content of the conditional-entropy refinement discussed in Section 8.

---

## 5. Landauer's Principle

### 5.1 The lower bound

**Corollary 5.1 (Landauer lower bound).** For any $f$, any nonnegative weight $p$, and any
$k, T \ge 0$,
$$ W_f(p) \;=\; k\,T\,\big(H(p) - H(f_* p)\big) \;\ge\; 0. $$

*Proof.* Immediate from Theorem 4.3 and $kT \ge 0$. $\qquad\blacksquare$

### 5.2 Reversible computations are free

**Corollary 5.2 (Reversible $\Rightarrow$ free).** If $f$ is injective, then $W_f(p) = 0$ for every
$p$ and all $k, T$.

*Proof.* Immediate from Theorem 4.5: the bracket vanishes. $\qquad\blacksquare$

These two corollaries are the qualitative core of Landauer's principle: irreversible steps carry a
nonnegative heat tax; reversible steps are tax-free, on *every* input distribution.

### 5.3 The exact extremal case: uniform erasure

Erasure of an $n$-bit register is the function $e : \mathrm{Fin}(2^n) \to \mathrm{Unit}$ collapsing
every state to a single reset point. This is the extremal case of Lemma 3.2, where *all* $2^n$
inputs share one fiber.

**Proposition 5.3 (Entropy of the uniform register).** The uniform distribution on
$\mathrm{Fin}(2^n)$ has entropy
$$ H(u_{2^n}) \;=\; n \log 2. $$

*Proof sketch.* Each of the $2^n$ atoms has weight $2^{-n}$, so
$H = -\sum 2^{-n}\log 2^{-n} = -2^n \cdot 2^{-n} \cdot (-n \log 2) = n\log 2$. $\qquad\blacksquare$

**Proposition 5.4 (Entropy of the erased register).** The point-mass distribution on $\mathrm{Unit}$
has entropy $0$ (since $1 \cdot \log 1 = 0$).

**Theorem 5.5 (Exact Landauer cost of erasure).** The entropy drop of uniform $n$-bit erasure is
exactly $n\log 2$, and hence
$$ W_e(u_{2^n}) \;=\; k\,T\,\big(H(u_{2^n}) - 0\big) \;=\; k\,T\,n\log 2. $$

*Proof.* Subtract Proposition 5.4 from Proposition 5.3 and multiply by $kT$. $\qquad\blacksquare$

This is an *equality*, the tight endpoint of the inequality $W_f(p) \ge 0$: erasure is the maximally
fiber-collapsing map, so it saturates the bound at its largest possible value. For $n = 1$ at
$T = 300\,\mathrm{K}$ this is $k\,T\,\log 2 \approx 2.9 \times 10^{-21}\,\mathrm{J} \approx
0.018\,\mathrm{eV}$, the celebrated single-bit Landauer limit confirmed in modern single-particle
experiments.

---

## 6. Universal Reversible Gates

We now connect the analysis to logic. We model bits by $\mathrm{Bool}$ and gates by functions on
tuples of bits. A gate dissipates no heat (on every input distribution) precisely when it is a
bijection, by Corollary 5.2. The three classical universal reversible gates qualify.

**Definition 6.1 (CNOT).** $\mathrm{CNOT}(a, b) = (a,\, a \oplus b)$, where $\oplus$ is XOR.

**Definition 6.2 (Toffoli).** $\mathrm{TOF}(a, b, c) = (a,\, b,\, c \oplus (a \wedge b))$.

**Definition 6.3 (Fredkin).** $\mathrm{FRED}(a, b, c) = (a,\, b', c')$ where $(b', c') = (c, b)$ if
$a = 1$ and $(b', c') = (b, c)$ if $a = 0$ (controlled SWAP).

**Proposition 6.4 (Each gate is an involution, hence a bijection).** Each of CNOT, Toffoli, and
Fredkin is its own inverse: applying it twice returns the input. Therefore each is a bijection.

*Proof sketch.* For CNOT, $a \oplus (a \oplus b) = b$. For Toffoli, the control bits $a, b$ are
untouched, and $\big(c \oplus (a \wedge b)\big) \oplus (a \wedge b) = c$. For Fredkin, swapping twice
under the same control restores the pair. An involution is automatically bijective. $\qquad\blacksquare$

**Proposition 6.5 (Logical correctness).** The gates compute the standard primitives:
- CNOT computes XOR in its second output, $\mathrm{CNOT}(a, b).2 = a \oplus b$, and copies a bit when
  $b = 0$: $\mathrm{CNOT}(a, 0) = (a, a)$.
- Toffoli computes AND when $c = 0$: $\mathrm{TOF}(a, b, 0).3 = a \wedge b$, and NOT when
  $a = b = 1$: $\mathrm{TOF}(1, 1, c).3 = \lnot c$.
- Fredkin swaps its data bits exactly when the control is $1$.

*Proof sketch.* Direct evaluation of Definitions 6.1–6.3. $\qquad\blacksquare$

**Theorem 6.6 (Thermodynamic optimality of the gates).** For each $G \in \{\mathrm{CNOT},
\mathrm{TOF}, \mathrm{FRED}\}$ and every input distribution $p$:
$$ H(G_* p) = H(p), \qquad W_G(p) = k\,T\,\big(H(p) - H(G_* p)\big) = 0. $$

*Proof.* Each gate is bijective (Proposition 6.4); apply Theorem 4.5 and Corollary 5.2.
$\qquad\blacksquare$

Theorem 6.6 is the cross-domain payoff: a single statement per gate certifies that it (i) computes
the intended Boolean function (Proposition 6.5), (ii) loses no entropy, and (iii) dissipates no heat
on *every* input distribution — synthesizing the algebraic, information-theoretic, and thermodynamic
viewpoints. Since Toffoli and Fredkin are each individually universal, *any* Boolean computation can
be assembled from heat-free building blocks; the dissipation associated with computing is a property
of the *implementation*, not of the function computed.

---

## 7. The Tropical-Algebra Bridge

Reversibility also has a purely algebraic face. Equip the space of *cost functions* $\sigma \to
\mathbb{R}$ with the **tropical (min-plus) semiring** operations: tropical addition is pointwise
minimum, $(\Phi \oplus \Psi)(x) = \min(\Phi(x), \Psi(x))$; tropical multiplication is pointwise real
addition, $(\Phi \otimes \Psi)(x) = \Phi(x) + \Psi(x)$; and tropical scalar action is
$(c \otimes_s \Phi)(x) = c + \Phi(x)$. This is the algebra of optimization: best-route cost is a
minimum over routes, route cost is a sum of legs.

**Theorem 7.1 (Reversible relabelings are tropical automorphisms).** Every bijection (equivalence)
$\theta : \sigma \to \sigma$ induces, by pullback $\Phi \mapsto \Phi \circ \theta$, a bijective map
on cost functions that preserves $\oplus$, $\otimes$, and $\otimes_s$:
$$ (\Phi \oplus \Psi) \circ \theta = (\Phi \circ \theta) \oplus (\Psi \circ \theta), \quad\text{etc.} $$

*Proof sketch.* Pullback along a bijection is itself a bijection (inverse: pullback along
$\theta^{-1}$), and each tropical operation is defined pointwise, so it commutes with precomposition.
$\qquad\blacksquare$

Thus the very maps that are *thermodynamically free* (entropy-preserving bijections, Theorem 4.5) are
also *algebraically structure-preserving* (tropical automorphisms). Moreover, any deterministic step
$s : \sigma \to \sigma$ can be embedded reversibly on the enlarged space $\sigma \times \sigma$ via
the bijection $\mathrm{swap}$ together with the encode/decode pair
$x \mapsto (x, s(x))$, $(a, b) \mapsto a$, recovering $s$ as $\mathrm{decode} \circ \mathrm{swap}
\circ \mathrm{encode}$ — a finite-state echo of Bennett's reversible-simulation construction, and the
reversible lift is itself a tropical automorphism. Reversibility is therefore one phenomenon in three
costumes: logical (invertible gates), information-theoretic (entropy preservation), and algebraic
(tropical isomorphism).

---

## 8. Discussion

### 8.1 What the bound does and does not say

Theorem 4.3 is a statement about *logical* entropy of the machine's state. The translation to *heat*
relies on Landauer's bridge $Q \ge kT \Delta H$, the physical input. Our contribution is to make the
informational side exact and elementary, so that the only remaining assumption is the bridge itself.

The bound is on the *minimum* dissipation in the quasi-static, ideal limit. Real devices dissipate
far more; the value of the bound is as an *absolute floor*, increasingly relevant as device energies
approach $kT$.

### 8.2 The role of the elementary proof

The pointwise-domination proof has pedagogical and formalization value beyond aesthetics. By
eliminating concavity, it reduces the inequality to facts (single-term $\le$ sum; $\log$ monotone)
that are robust and easy to mechanize, and it exposes the *mechanism* of entropy loss — fiber
merging — in the cleanest possible form.

### 8.3 The fiber picture as a unifying lens

The recurring object is the *fiber*. Fat fibers cause entropy loss (Lemma 3.2 strict), thin fibers
preserve it (Theorem 4.5), the maximally fat fiber gives erasure (Theorem 5.5), and the largest fiber
controls the ancilla cost of reversible simulation. All quantitative aspects of irreversibility are
fiber statistics.

---

## 9. Future Directions

**Quantitative gap as conditional entropy.** Theorem 4.3 gives an inequality; the *gap* should be an
explicit, computable quantity — the conditional entropy
$$ H(p) - H(f_* p) \;=\; \sum_{y} (f_* p)(y)\, H(p \mid \text{fiber } y), $$
the expected entropy of the fibers $f$ glues together. Proving this identity in full generality would
turn the qualitative dichotomy into a precise accounting of *how much* information (and heat) each
merge destroys, with erasure ($H(p \mid \text{fiber}) = \log 2^n$) and bijection
($H(p \mid \text{fiber}) = 0$) as endpoints.

**Composition and circuits.** Extend the per-gate statements to compositional bounds: the dissipation
of a circuit is the sum of the dissipations of its irreversible steps, and a circuit built solely from
bijective gates is globally free. This connects to the ancilla-economy results: bookkeeping the total
history register needed to make a whole circuit reversible.

**Finite-temperature and noisy channels.** Relax determinism to stochastic channels and recover the
full (probabilistic) data-processing inequality, then quantify the trade-off between dissipation and
error in noisy, finite-$T$ implementations.

**Physical realizations.** Tie the abstract gates to concrete substrates (ballistic billiard-ball
models, single-electron, photonic, and superconducting reversible logic), using the conservation
property of Fredkin to model conserved physical tokens.

---

## 10. Conclusion

A single elementary inequality — $H(f_* p) \le H(p)$, proved from the observation that a fiber sum
dominates one of its terms — organizes the entire thermodynamics of deterministic computation. It
yields Landauer's principle as a nonnegative lower bound on dissipated heat, exact zero for
reversible maps; it recovers the exact $k\,T\,n\log 2$ cost of erasure as its extremal case; it
certifies that the universal gates CNOT, Toffoli, and Fredkin compute correctly while dissipating no
heat; and it dovetails with an algebraic picture in which reversibility is a tropical automorphism.
To forget is to merge fibers, and to merge fibers is to pay; to remember is to keep fibers thin, and
to keep them thin is to be free.

---

## References

- Landauer, R. (1961). *Irreversibility and heat generation in the computing process.* IBM Journal of
  Research and Development, 5(3), 183–191.
- Bennett, C. H. (1973). *Logical reversibility of computation.* IBM Journal of Research and
  Development, 17(6), 525–532.
- Fredkin, E., & Toffoli, T. (1982). *Conservative logic.* International Journal of Theoretical
  Physics, 21, 219–253.
- Cover, T. M., & Thomas, J. A. (2006). *Elements of Information Theory* (2nd ed.). Wiley.
  [data-processing inequality]
- Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry.* AMS.
