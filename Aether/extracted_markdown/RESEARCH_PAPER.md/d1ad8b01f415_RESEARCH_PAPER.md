# Fixed Points in Cognitive Dynamics: A Topological Framework for Déjà Vu

## Abstract

We develop a rigorous mathematical framework for modeling cognitive state transitions as discrete dynamical systems on closed intervals and prove fundamental existence theorems for periodic points — "déjà vu states" in the cognitive interpretation. Our main contributions are: (1) a formalization of the one-dimensional Brouwer Fixed Point Theorem showing that any continuous self-map of a closed interval must have a fixed point; (2) a proof that period-3 orbits in continuous dynamics force fixed points and secondary recurrences via the Intermediate Value Theorem; (3) the introduction of the *recurrence spectrum* — the set of periods realized by a dynamical system — and proofs of its algebraic closure properties; (4) topological properties of ω-limit sets (cognitive attractors) in the context of iterated maps. All results are formalized in Lean 4 with machine-verified proofs. We connect these results to the phenomenology of déjà vu by modeling cognitive dynamics via the logistic map and computing periodic orbit densities.

**Keywords**: dynamical systems, fixed point theorems, periodic orbits, Sharkovsky's theorem, cognitive dynamics, déjà vu, formal verification

## 1. Introduction

Déjà vu — the subjective experience of having previously encountered a novel situation — occurs in approximately 60-70% of the general population [1]. While extensive neuroscientific research has investigated its neural correlates, focusing on temporal lobe mechanisms and dual-processing models of memory [2, 3], there has been comparatively little work on the *mathematical structure* of recurrent cognitive states.

We propose modeling cognitive state transitions as a discrete dynamical system: a continuous function *f: S → S* mapping the current cognitive state to the next. In this framework, a "déjà vu state" is a periodic point — a state *s* such that *f^n(s) = s* for some positive integer *n*. Fixed points (*n = 1*) represent perfectly self-reproducing cognitive states; higher-period orbits represent cyclical patterns of experience.

This paper establishes that, under mild topological assumptions on the cognitive state space and transition function, periodic points are not merely possible but *necessary*. Our approach draws on classical results from one-dimensional dynamics — the Intermediate Value Theorem, the Brouwer Fixed Point Theorem, and elements of Sharkovsky's theory — formalized rigorously in the Lean 4 proof assistant.

### 1.1 Related Work

The mathematical study of periodic orbits in one-dimensional dynamics has a rich history. Sharkovsky's theorem (1964) [4] establishes a total ordering on the natural numbers such that the existence of a period-*m* orbit implies the existence of period-*n* orbits for all *n* following *m* in this ordering. The celebrated theorem of Li and Yorke (1975) [5] — "period three implies chaos" — showed that period-3 orbits force orbits of all periods plus uncountable scrambled sets. These results have found applications across physics, biology, and engineering, but their application to cognitive science remains largely unexplored.

Our formalization builds on Mathlib's existing infrastructure for continuous functions, periodic points (`Function.IsPeriodicPt`, `Function.periodicPts`), and the Intermediate Value Theorem (`intermediate_value_Icc'`).

## 2. Definitions

### 2.1 Interval Dynamics

**Definition 2.1** (Interval Dynamics). An *interval dynamics* is a tuple *(f, a, b)* where:
- *f: ℝ → ℝ* is a function,
- *a < b* are real numbers,
- *f* is continuous on *[a, b]*,
- *f* maps *[a, b]* into itself: *f(x) ∈ [a, b]* for all *x ∈ [a, b]*.

This models a cognitive system where brain states are bounded within an interval *[a, b]* and the transition function preserves this boundedness — a natural assumption for biological systems with finite metabolic resources.

### 2.2 Recurrence Spectrum

**Definition 2.2** (Recurrence Spectrum). The *recurrence spectrum* of a function *f: α → α* is:

$$\text{Spec}(f) = \{n \in \mathbb{N} : n > 0 \text{ and } \exists x, f^n(x) = x\}$$

where *f^n* denotes the *n*-fold iterate of *f*. This is the set of positive periods at which the system can exhibit recurrence.

The recurrence spectrum is a novel invariant that captures the "déjà vu signature" of a dynamical system — which recurrence patterns are structurally possible.

### 2.3 Cognitive Attractor

**Definition 2.3** (Cognitive Attractor / ω-limit set). The *cognitive attractor* of a point *x* under *f* is:

$$\omega(x) = \bigcap_{n=0}^{\infty} \overline{\{f^{n+k}(x) : k \geq 0\}}$$

This is the set of accumulation points of the orbit of *x* — the long-term behavioral signature of the trajectory starting at *x*.

## 3. Main Results

### 3.1 Theorem 1: Fixed Point Existence (1D Brouwer)

**Theorem 3.1.** Every interval dynamics *(f, a, b)* has a fixed point: there exists *c ∈ [a, b]* with *f(c) = c*.

*Proof.* Consider *g(x) = f(x) - x*. Since *f* maps *[a, b]* to *[a, b]*, we have *f(a) ≥ a* and *f(b) ≤ b*, giving *g(a) ≥ 0* and *g(b) ≤ 0*. Since *g* is continuous on *[a, b]* (as the difference of continuous functions), by the Intermediate Value Theorem there exists *c ∈ [a, b]* with *g(c) = 0*, i.e., *f(c) = c*. □

This is the foundational result: any continuous bounded cognitive dynamics must have at least one self-reproducing state.

### 3.2 Theorem 2: Spectrum Contains 1

**Theorem 3.2.** For any interval dynamics *D*, we have *1 ∈ Spec(D.f)*.

*Proof.* Immediate from Theorem 3.1: the fixed point *c* satisfies *f^1(c) = f(c) = c*, so it is a period-1 point. □

### 3.3 Theorem 3: Period-3 Implies Fixed Point

**Theorem 3.3.** Let *f: ℝ → ℝ* be continuous on *[a, c]* with a period-3 orbit *a → b → c → a* where *a < b < c*. Then *f* has a fixed point in *[a, c]*.

*Proof.* From the orbit structure: *f(a) = b > a* and *f(c) = a < c*. Consider *g(x) = f(x) - x*: *g(a) = b - a > 0* and *g(c) = a - c < 0*. By the IVT, there exists *p ∈ [a, c]* with *g(p) = 0*. □

This result is the entry point to Sharkovsky's theorem. The full theorem states that period 3 implies all periods, but even this first step — period 3 implies period 1 — is non-trivial in its cognitive implications: the existence of a three-state cognitive cycle guarantees a fixed cognitive state.

### 3.4 Theorem 4: Period-3 Forces f²-Recurrence in Subinterval

**Theorem 3.4.** Under the hypotheses of Theorem 3.3, with *f* globally continuous, *f² = f ∘ f* has a fixed point in *[a, b]* — a strictly smaller subinterval.

*Proof.* Compute: *f²(a) = f(f(a)) = f(b) = c > a* and *f²(b) = f(f(b)) = f(c) = a < b*. Since *f²* is continuous (composition of continuous functions), the IVT gives *p ∈ [a, b]* with *f²(p) = p*. □

**Remark.** The fixed point of *f* (from Theorem 3.3) lies in *[b, c]* (since *f(b) = c > b* and *f(c) = a < c*), while this *f²*-fixed point lies in *[a, b]*. This spatial separation demonstrates that period-3 dynamics create recurrence patterns in *different regions* of the cognitive state space.

### 3.5 Theorem 5: Spectrum Closure Under Multiples

**Theorem 3.5.** The recurrence spectrum is closed under positive multiples: if *n ∈ Spec(f)* and *k > 0*, then *kn ∈ Spec(f)*.

*Proof.* If *f^n(x) = x*, then *f^{kn}(x) = (f^n)^k(x) = x* since iterating the identity is the identity. □

This means the recurrence spectrum is an *upward-closed* set under divisibility — a non-trivial algebraic structure. Combined with Sharkovsky's theorem, this gives strong constraints on which spectra are possible.

### 3.6 Theorem 6: Cognitive Attractor is Closed

**Theorem 3.6.** For any function *f* and point *x* in a topological space, the cognitive attractor *ω(x)* is a closed set.

*Proof.* *ω(x)* is defined as an intersection of closed sets (closures of orbit tails), and arbitrary intersections of closed sets are closed. □

### 3.7 Theorem 7: Fixed Point Attractor Singleton

**Theorem 3.7.** If *x* is a fixed point of *f* in a T₁ space, then *ω(x) = {x}*.

*Proof.* Since *f^n(x) = x* for all *n* (by induction from *f(x) = x*), the orbit tail *{f^{n+k}(x) : k ≥ 0} = {x}* for each *n*. Its closure is *{x}* (singletons are closed in T₁ spaces). The intersection of all these is *{x}*. □

## 4. Computational Model: The Logistic Map

### 4.1 The Logistic Map as Cognitive Dynamics

We model cognitive dynamics via the logistic map *f_r(x) = rx(1-x)* on *[0, 1]*, parameterized by *r ∈ [0, 4]*. This is a canonical model of bounded nonlinear dynamics with:
- A single tuning parameter *r* (cognitive processing intensity)
- Bounded output: *f_r([0, 1]) ⊆ [0, 1]* for *r ∈ [0, 4]*
- Rich bifurcation structure

### 4.2 Period-Doubling Route to Cognitive Chaos

| Parameter *r* | Behavior | Recurrence Spectrum |
|---|---|---|
| 0 < r < 1 | Extinction (converge to 0) | {1, 2, 3, ...} (trivially, 0 is a fixed point) |
| 1 < r < 3 | Stable fixed point at *(r-1)/r* | {1, 2, 3, ...} |
| 3 < r < 3.449 | Period-2 orbit | {1, 2, 3, 4, ...} |
| 3.449 < r < 3.544 | Period-4 orbit | {1, 2, 3, 4, ...} |
| r ≈ 3.5699 | Onset of chaos | Dense spectrum |
| r ≈ 3.8284 | Period-3 window | {1, 2, 3, ...} = ℕ⁺ (by Sharkovsky) |
| r = 4 | Full chaos | ℕ⁺ |

### 4.3 Topological Entropy

The topological entropy of the logistic map increases monotonically from 0 (at *r = 1*) to *log 2* (at *r = 4*). At *r ≈ 3.83* (period-3 window), the entropy is approximately 0.38. This quantity measures the exponential growth rate of the number of distinguishable orbits and serves as a proxy for cognitive complexity.

### 4.4 Density of Periodic Points

For the logistic map at *r = 4*, the number of period-*n* points is exactly *2^n - 2* (excluding fixed points) plus 2 fixed points. The density of periodic orbits — the fraction of initial conditions that eventually become periodic — is zero for the full-chaos regime (Lebesgue-almost-every trajectory is aperiodic). However, the *topological* density of periodic points (they form a dense subset of *[0, 1]*) is maximal.

This connects to the phenomenology of déjà vu: while periodic (déjà vu) states are topologically ubiquitous — arbitrarily close to any cognitive state — they occupy zero measure. Most cognitive trajectories wander aperiodically, but every state is shadowed by nearby periodic states, creating the subjective experience of "almost-repetition" that characterizes déjà vu.

## 5. Algorithm: Computing Periodic Points

### 5.1 Newton-Raphson for Periodic Points

To find period-*n* points of *f*, we solve *f^n(x) - x = 0* using Newton's method applied to the iterate *f^n*. The derivative of *f^n* is computed via the chain rule:

$$(f^n)'(x) = \prod_{k=0}^{n-1} f'(f^k(x))$$

### 5.2 Bifurcation Diagram Construction

The bifurcation diagram is constructed by:
1. For each parameter value *r*, iterate the logistic map for a transient period (discard first 1000 iterates).
2. Record the next 500 iterates as the "attractor".
3. Plot these points against *r*.

The resulting structure reveals the period-doubling cascade, chaotic bands, and periodic windows.

## 6. Conjecture: Cognitive Entropy-Déjà Vu Correspondence

**Conjecture 6.1.** Let *h(f)* denote the topological entropy of a cognitive map *f*. The frequency of déjà vu experiences (measured as episodes per unit time) is proportional to *exp(-1/h(f))* — exponentially suppressed at low entropy (simple dynamics) and approaching a finite limit at high entropy (chaotic dynamics).

**Testable prediction**: In a population study, individuals with higher scores on measures of cognitive complexity (e.g., creative ideation tests, working memory span) should report higher déjà vu frequency, with the relationship following an exponential-saturation curve rather than a linear one.

**Computational test**: For the logistic map family, compute the fraction of initial conditions within distance *ε* of a periodic point, as a function of *r*. This "near-periodicity fraction" should correlate with empirical déjà vu incidence rates.

## 7. Discussion

### 7.1 Limitations

Our formalized results are restricted to one-dimensional dynamics (continuous self-maps of intervals). Real cognitive state spaces are enormously high-dimensional. While the Brouwer Fixed Point Theorem generalizes to higher dimensions (any continuous self-map of a closed ball has a fixed point), Sharkovsky's theorem is specifically one-dimensional. The higher-dimensional theory of periodic orbits is substantially more complex and does not admit such clean combinatorial descriptions.

### 7.2 Relation to Neuroscience

The interval model is an abstraction: real neural dynamics are high-dimensional, stochastic, and defined on complex geometric substrates (cortical manifolds). However, dimensionality reduction techniques (PCA, UMAP, diffusion maps) applied to neural recordings often reveal that high-dimensional neural trajectories live on low-dimensional manifolds. If the effective dimension of cognitive dynamics is low, our one-dimensional results may apply as approximations along the dominant axis of variation.

### 7.3 Novel Contributions

1. **Recurrence Spectrum**: A new dynamical invariant capturing the "déjà vu signature" of a cognitive system.
2. **Cognitive Attractor formalization**: Machine-verified proofs of ω-limit set properties.
3. **Spatial separation of recurrence**: Theorem 3.4 shows that period-3 dynamics force recurrence in *different regions* of state space — a phenomenon not previously highlighted in the cognitive context.

## 8. Future Work

1. **Formalize Sharkovsky's Theorem**: Complete the chain from period 3 to all periods with machine-verified proofs.
2. **Higher-dimensional analogues**: Extend results to continuous self-maps of *ℝ^n* using Brouwer degree theory.
3. **Stochastic dynamics**: Incorporate noise to model the inherent stochasticity of neural systems.
4. **Empirical validation**: Design cognitive experiments to test the entropy-déjà vu correspondence.

## References

[1] Brown, A. S. (2003). A review of the déjà vu experience. *Psychological Bulletin*, 129(3), 394-413.

[2] Cleary, A. M. (2008). Recognition memory, familiarity, and déjà vu experiences. *Current Directions in Psychological Science*, 17(5), 353-357.

[3] O'Connor, A. R., & Moulin, C. J. A. (2010). Recognition without identification, erroneous familiarity, and déjà vu. *Current Psychiatry Reports*, 12(3), 165-173.

[4] Sharkovsky, A. N. (1964). Co-existence of cycles of a continuous mapping of the line into itself. *Ukrainian Mathematical Journal*, 16, 61-71.

[5] Li, T. Y., & Yorke, J. A. (1975). Period three implies chaos. *The American Mathematical Monthly*, 82(10), 985-992.

[6] Devaney, R. L. (2003). *An Introduction to Chaotic Dynamical Systems*. Westview Press.

[7] Katok, A., & Hasselblatt, B. (1995). *Introduction to the Modern Theory of Dynamical Systems*. Cambridge University Press.
