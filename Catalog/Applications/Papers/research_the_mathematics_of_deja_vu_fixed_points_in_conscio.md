# Dynamical Spectrum Theory: Fixed Points, Periodic Orbits, and the Mathematics of Cognitive Return

## Abstract

We develop a formal mathematical framework — *Dynamical Spectrum Theory* — for analyzing the periodic structure of discrete dynamical systems, with applications to cognitive dynamics and the phenomenon of deja vu. Our central contribution is the **Dynamical Spectrum**, a structure that captures the complete periodic portrait of a dynamical system (α, f), together with the **Sharkovsky Classification** of periods. We prove, with machine-verified proofs in Lean 4:

1. **IVT Fixed Point Theorem**: Any continuous self-map of a closed interval [a,b] has a fixed point (Theorem 3.1).
2. **Period-3 Fixed Point Existence**: A continuous map on ℝ with a 3-cycle p₁ → p₂ → p₃ → p₁ (with p₁ < p₂ < p₃) has a fixed point in [p₁, p₃] (Theorem 3.2).
3. **Inevitability of Deja Vu**: Any cognitive dynamical system (continuous self-map of [0,1]) has at least one "deja vu state" — a periodic point (Theorem 5.1).
4. **Finite Orbit Periodicity**: If the forward orbit of a point under any map is finite, then some point in the orbit is periodic (Theorem 4.1).
5. **Logistic Map Analysis**: Complete characterization of fixed points and spectral properties of the logistic map f(x) = rx(1-x), including proof that the nontrivial fixed point (r-1)/r lies in (0,1) for r > 1 (Theorems 4.2–4.6).

All proofs are fully formalized and verified, using only the standard axioms (propext, Classical.choice, Quot.sound).

**Keywords**: dynamical systems, periodic orbits, Sharkovsky ordering, fixed point theorems, logistic map, cognitive dynamics, formal verification

---

## 1. Introduction

### 1.1 Motivation

The study of periodic behavior in discrete dynamical systems is central to ergodic theory, chaos theory, and mathematical modeling of physical and biological systems. The celebrated theorem of Sharkovsky (1964) establishes that the existence of a periodic orbit of period n in a continuous self-map of an interval forces the existence of periodic orbits of all periods m such that n ◁ m in the Sharkovsky ordering. The Li-Yorke theorem (1975) — "Period three implies chaos" — demonstrated that period-3 orbits imply uncountably many aperiodic trajectories.

We contribute to this theory in three ways:

1. **Formal framework**: We introduce the *Dynamical Spectrum* as a mathematical structure that bundles a dynamical system with its periodic portrait, enabling compositional reasoning about period sets.

2. **Machine-verified proofs**: All main theorems are proved in Lean 4 with the Mathlib library, providing the highest level of mathematical certainty.

3. **Cognitive interpretation**: We formalize the connection between dynamical periodicity and the cognitive phenomenon of deja vu, proving that periodic states are mathematically inevitable in any continuous cognitive model.

### 1.2 Related Work

The theory of periodic points for interval maps has a rich history. Sharkovsky's original theorem (1964) was independently rediscovered in the West through the Li-Yorke paper. Block and Coppel's monograph *Dynamics in One Dimension* provides a comprehensive treatment. Our contribution is not to the abstract theory but to its formalization and its novel application to cognitive modeling.

---

## 2. Definitions

### 2.1 Sharkovsky Classification

We classify positive integers into three tiers based on their 2-adic structure:

**Definition 2.1** (Sharkovsky Class). The Sharkovsky class of a positive integer n is:
- **OddLarge(n)**: if n is odd and n ≥ 3
- **Mixed(v, m)**: if n = 2^v · m where v ≥ 1 and m ≥ 3 is odd
- **PowerOfTwo(k)**: if n = 2^k (including n = 1 = 2^0)

This classification partitions ℕ\{0} into the three strata of the Sharkovsky ordering, where OddLarge numbers force the most periods (they are highest in the ordering) and PowerOfTwo numbers force the fewest.

### 2.2 Dynamical Spectrum

**Definition 2.2** (Full Period Set). For f : α → α, the full period set is:
```
fullPeriodSet(f) = {n ∈ ℕ | n > 0 ∧ ∃ x : α, f^[n](x) = x}
```

**Definition 2.3** (Dynamical Spectrum). A Dynamical Spectrum over a type α consists of:
- A map `dynamics : α → α`
- A set `periods ⊆ ℕ`
- A proof that all elements of `periods` are positive
- A proof that each period is witnessed by an actual periodic point

This structure encapsulates the periodic portrait of a dynamical system in a composable, type-safe manner.

### 2.3 Sharkovsky Closure

**Definition 2.4** (Sharkovsky Closed). A set S ⊆ ℕ is Sharkovsky-closed if:
1. 3 ∈ S implies n ∈ S for all n > 0 (period 3 forces everything)
2. S nonempty implies 1 ∈ S (existence of any period forces fixed points)
3. 2^(k+1) ∈ S implies 2^k ∈ S (power-of-2 periods form a tail)

By Sharkovsky's theorem (not fully proved here but structurally encoded), the period set of any continuous self-map of an interval is Sharkovsky-closed.

### 2.4 Cognitive Dynamics

**Definition 2.5** (Cognitive Dynamical System). A cognitive dynamical system consists of:
- A transition function `transition : ℝ → ℝ`
- A proof of continuity
- A proof that [0,1] is invariant under the transition

**Definition 2.6** (Deja Vu State). A point x ∈ [0,1] is a deja vu state if it is periodic: ∃ n > 0, transition^[n](x) = x.

### 2.5 Li-Yorke Trajectory

**Definition 2.7** (Li-Yorke Trajectory). An orbit {f^[n](x)} is a Li-Yorke trajectory if it is neither periodic (no n > 0 with f^[n](x) = x) nor convergent (no limit point p with f^[n](x) → p).

---

## 3. Main Results: Fixed Point Theorems

### Theorem 3.1 (IVT Fixed Point)

*Let a ≤ b be real numbers, f : ℝ → ℝ continuous on [a,b], with f(a) ∈ [a,b] and f(b) ∈ [a,b]. Then there exists c ∈ [a,b] with f(c) = c.*

**Proof sketch.** Define g(x) = f(x) - x. Then g is continuous on [a,b] with g(a) = f(a) - a ≥ 0 (since f(a) ≥ a) and g(b) = f(b) - b ≤ 0 (since f(b) ≤ b). By the Intermediate Value Theorem, there exists c ∈ [a,b] with g(c) = 0, i.e., f(c) = c. ∎

**PEGB Analysis:**
- **P**roof: Formalized in Lean 4, ~10 lines using `intermediate_value_Icc'`
- **E**xample: The logistic map f(x) = 2.5x(1-x) on [0,1] has fixed point 0.6
- **G**eneralization: Extends to any continuous self-map of a compact convex subset of ℝⁿ (Brouwer's theorem)
- **B**oundary: The theorem fails for discontinuous maps: f(x) = x + 0.5 mod 1 on [0,1] has no fixed point. Compactness is essential: f(x) = x + 1 on ℝ has no fixed point.

### Theorem 3.2 (Period-3 Implies Fixed Point)

*Let f : ℝ → ℝ be continuous with a 3-cycle p₁ → p₂ → p₃ → p₁ where p₁ < p₂ < p₃. Then f has a fixed point in [p₁, p₃].*

**Proof sketch.** We have f(p₁) = p₂ > p₁ and f(p₃) = p₁ < p₃, so (f - id)(p₁) > 0 and (f - id)(p₃) < 0. By IVT, there exists c ∈ [p₁, p₃] with f(c) = c. ∎

**PEGB Analysis:**
- **P**roof: Formalized in Lean 4, using `intermediate_value_Icc'` on f - id
- **E**xample: The tent map T(x) = min(2x, 2-2x) has the 3-cycle {2/7, 4/7, 6/7} and fixed points at 0 and 2/3
- **G**eneralization: By Sharkovsky's theorem, period-3 implies periods of ALL orders (not just fixed points)
- **B**oundary: For maps on the circle S¹ (as opposed to intervals), period-3 does NOT imply all periods. The rotation x ↦ x + 1/3 mod 1 has period 3 but only period 3.

---

## 4. Orbit Structure

### Theorem 4.1 (Periodicity of Multiples)

*If f^[n](x) = x, then f^[kn](x) = x for all k ≥ 1.*

**Proof.** By `Function.iterate_mul` and `Function.iterate_fixed`. ∎

### Theorem 4.2 (Finite Orbit Contains Periodic Point)

*If the forward orbit {f^[n](x) | n ∈ ℕ} is finite, then there exist m, n with n > 0 and f^[n](f^[m](x)) = f^[m](x).*

**Proof sketch.** Since ℕ is infinite and the orbit is finite, by pigeonhole there exist i < j with f^[i](x) = f^[j](x). Set m = i, n = j - i > 0. Then f^[n](f^[m](x)) = f^[i+n](x) = f^[j](x) = f^[i](x) = f^[m](x). ∎

**Remark.** The stronger statement "x itself is periodic" is FALSE. A counterexample: f : {0,1} → {0,1} with f(0) = 1, f(1) = 1. The orbit of 0 is {0, 1}, which is finite, but f^[n](0) ≠ 0 for any n > 0. This counterexample was discovered during formal verification — the proof assistant correctly rejected the false statement.

**PEGB Analysis:**
- **P**roof: Formalized using pigeonhole/injectivity argument
- **E**xample: f(x) = x² on {0, 0.5, 0.25, 0.0625, ...}: orbit of 0.5 is {0.5, 0.25, 0.0625, ...} (infinite, non-periodic). But for f : {a,b,c} → {a,b,c} with f(a)=b, f(b)=c, f(c)=b, orbit of a = {a,b,c} is finite, and b is periodic with period 2.
- **G**eneralization: For bijections (permutations) on finite sets, every point IS periodic (not just some orbit point). This is because orbits under bijections are true cycles.
- **B**oundary: For infinite orbits, no periodic point need exist (e.g., f(n) = n+1 on ℕ).

### Theorem 4.3 (Minimal Period Divides All Periods)

*If f^[n](x) = x with n > 0, then minimalPeriod(f, x) divides n.*

This follows directly from Mathlib's `Function.IsPeriodicPt.minimalPeriod_dvd`.

---

## 5. Cognitive Dynamics

### Theorem 5.1 (Inevitability of Deja Vu)

*Every cognitive dynamical system (continuous self-map of [0,1]) has a nonempty deja vu set.*

**Proof.** By Theorem 3.1 (with a = 0, b = 1), the transition map has a fixed point c ∈ [0,1]. A fixed point is a periodic point of period 1, hence c is a deja vu state. ∎

**PEGB Analysis:**
- **P**roof: Formalized, composing `spectrum_contains_one_of_self_map` with the deja vu definition
- **E**xample: The logistic map at r = 2.5 has fixed point 0.6, which is a permanent deja vu state (the mind returns to this state and stays)
- **G**eneralization: For higher-dimensional cognitive state spaces (compact convex subsets of ℝⁿ), Brouwer's fixed point theorem guarantees the same result
- **B**oundary: If the state space is not compact (e.g., all of ℝ), fixed points need not exist. If the map is not continuous (quantum jumps in neural state), the theorem fails.

---

## 6. Logistic Map Analysis

### Theorem 6.1 (Trivial Fixed Point)

*For all r, logisticMap(r, 0) = 0.* This is immediate from the definition.

### Theorem 6.2 (Nontrivial Fixed Point)

*For r ≠ 0, logisticMap(r, (r-1)/r) = (r-1)/r.*

**Proof.** Direct computation: r · ((r-1)/r) · (1 - (r-1)/r) = r · ((r-1)/r) · (1/r) = (r-1)/r. ∎

### Theorem 6.3 (Self-Map Property)

*For r ∈ (1, 4], the logistic map maps [0,1] to [0,1].*

**Proof sketch.** For x ∈ [0,1]: the lower bound follows from r > 0, x ≥ 0, 1-x ≥ 0. The upper bound uses x(1-x) ≤ 1/4 (by AM-GM or completing the square), so rx(1-x) ≤ r/4 ≤ 1. ∎

### Theorem 6.4 (Fixed Point Location)

*For r > 1, the nontrivial fixed point (r-1)/r lies in (0, 1).*

### Theorem 6.5 (Spectral Inclusion)

*For r ∈ (1, 4], period 1 is in the spectrum of the logistic map.* (Follows from the trivial fixed point at 0.)

---

## 7. Algorithms

### 7.1 Floyd's Cycle Detection

We implement Floyd's tortoise-and-hare algorithm for detecting periodicity in orbits. This runs in O(μ + λ) time and O(1) space, where μ is the pre-period and λ is the period. See `algorithms.py`.

### 7.2 IVT Fixed Point Bisection

The constructive content of Theorem 3.1 yields a bisection algorithm for finding fixed points. Given f : [a,b] → [a,b] continuous, bisect on g(x) = f(x) - x to find a zero in O(log((b-a)/ε)) iterations for tolerance ε.

### 7.3 Spectrum Estimation

Sample-based estimation of the dynamical spectrum: evaluate orbits from many initial conditions, detect periods using Floyd's algorithm, and collect into the spectrum set. See `algorithms.py`.

---

## 8. Conjectures and Future Directions

### Conjecture 8.1 (Spectrum Universality)

*For the logistic map at the Feigenbaum point r_∞ ≈ 3.5699..., the dynamical spectrum contains exactly all powers of 2: {1, 2, 4, 8, 16, ...}. At any r > r_∞ that is not in a periodic window, the spectrum contains all positive integers.*

**Testable prediction**: Compute the spectrum at r = r_∞ ± ε for small ε and verify the transition from power-of-2 spectrum to full spectrum.

### Conjecture 8.2 (Cognitive Complexity Bound)

*The topological entropy of a cognitive dynamical system (continuous self-map of [0,1]) is bounded by log(2) ≈ 0.693, with equality achieved only at r = 4 (the fully chaotic regime). This bounds the "information generation rate" of consciousness.*

---

## 9. Discussion

### 9.1 The Disproof as Discovery

During this research cycle, we discovered that the natural statement "finite orbit implies periodic" is **false**. The point can be pre-periodic: it enters a cycle but is not itself part of the cycle. This was caught by the formal verification system, which produced a concrete counterexample (a two-state system where 0 maps to 1 and 1 maps to 1). The corrected theorem (Theorem 4.2) states that some point *in the orbit* must be periodic — a weaker but true statement.

This illustrates a key principle: **disproofs are discoveries**. The failure of the naive conjecture revealed the distinction between periodic and pre-periodic orbits, which is central to the theory of Julia sets, Mandelbrot sets, and symbolic dynamics.

### 9.2 Limitations

Our formalization covers the fixed-point end of the Sharkovsky spectrum. The full theorem (period n forces all periods m ◁ n) requires substantially more machinery: detailed analysis of covering relations between intervals, which would be a significant formalization project.

The cognitive interpretation, while mathematically grounded, is necessarily metaphorical. Real neural dynamics are high-dimensional, stochastic, and not purely deterministic. The value of the framework is conceptual: it identifies structural features (fixed points, periodic orbits, chaos) that are robust across a wide class of models.

---

## 10. Conclusion

We have developed and formally verified a mathematical framework connecting discrete dynamical systems theory to the cognitive phenomenon of deja vu. The key insight is that **periodic return is a mathematical inevitability** of continuous dynamics on bounded state spaces. Our Dynamical Spectrum structure provides a principled way to reason about the periodic portrait of a system, and the Sharkovsky Classification organizes periods by their forcing strength.

The formal verification of these results — including the discovery and correction of a false conjecture — demonstrates the value of machine-checked proofs for ensuring mathematical correctness in applied settings.

---

## References

1. Li, T.-Y., & Yorke, J. A. (1975). Period three implies chaos. *The American Mathematical Monthly*, 82(10), 985-992.
2. Sharkovsky, A. N. (1964). Co-existence of cycles of a continuous mapping of the line into itself. *Ukrainian Mathematical Journal*, 16, 61-71.
3. Devaney, R. L. (2003). *An Introduction to Chaotic Dynamical Systems*. Westview Press.
4. Block, L., & Coppel, W. A. (1992). *Dynamics in One Dimension*. Springer.
5. Feigenbaum, M. J. (1978). Quantitative universality for a class of nonlinear transformations. *Journal of Statistical Physics*, 19(1), 25-52.
6. Brown, A. S. (2003). A review of the deja vu experience. *Psychological Bulletin*, 129(3), 394-413.
