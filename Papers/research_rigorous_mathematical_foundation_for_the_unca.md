# The Epistemic Valley: Phase Transitions in Mathematical Proof Trust

## Abstract

We develop a rigorous mathematical theory of trust dynamics in mathematical proof evaluation, formalizing the "uncanny valley" phenomenon where proofs at intermediate rigor levels are trusted less than both informal sketches and complete arguments. Our model represents trust as `U(r) = r − α·S(r)`, where `r ∈ [0,1]` is the rigor level, `α ≥ 0` is the reader's suspicion sensitivity, and `S(r) = r²(1−r)` is a suspicion function capturing the heightened scrutiny triggered by almost-formal arguments. We prove a sharp phase transition at the critical sensitivity `α* = 4`: for `α ≤ 4`, trust is non-negative on `[0,1]` (subcritical regime); for `α > 4`, trust becomes negative on an interval (supercritical regime), establishing an uncanny valley. Our main result — the Epistemic Barrier Theorem — shows this valley is universal: it appears for any admissible suspicion function, not just the polynomial model. All results are formalized and verified in Lean 4 with the Mathlib library.

**Keywords**: proof evaluation, trust dynamics, phase transition, uncanny valley, epistemic barrier, formal verification

## 1. Introduction

The evaluation of mathematical proofs involves a subtle interplay between the rigor of the argument and the reader's sensitivity to potential gaps. Informally, a proof sketch may be trusted because it doesn't pretend to be rigorous, while a fully formal proof is trusted because it has no gaps. But a proof at an intermediate level — formal enough to create expectations of completeness, yet incomplete enough to trigger suspicion — can be trusted less than either extreme.

We call this the **epistemic valley**: a region in the rigor-trust landscape where increasing rigor decreases trust. This phenomenon mirrors the "uncanny valley" in robotics and computer animation, where almost-human faces trigger stronger revulsion than clearly non-human ones.

### 1.1 Contributions

1. A clean mathematical model of proof trust with a single suspicion sensitivity parameter.
2. A proof that the critical sensitivity is exactly `α* = 4`, with a sharp phase transition.
3. The **Epistemic Barrier Theorem**: the valley is universal for any admissible suspicion function.
4. The **Valley Width Theorem**: in the supercritical regime, the valley has two well-defined boundaries.
5. A multi-dimensional generalization for proofs with multiple rigor dimensions.
6. Complete formal verification of all results in Lean 4.

## 2. The Model

### 2.1 Definitions

**Definition 2.1** (Suspicion Function). The *suspicion function* `S : [0,1] → ℝ` is defined by
```
S(r) = r²(1 − r)
```
This function vanishes at `r = 0` (informal proofs create no expectation of rigor to violate) and at `r = 1` (complete proofs have no gaps), achieving its maximum at `r = 2/3` with value `S(2/3) = 4/27`.

**Definition 2.2** (Trust Function). For a reader with *suspicion sensitivity* `α ≥ 0`, the *trust function* `U : [0,1] → ℝ` is defined by
```
U(r) = r − α · S(r) = r − α · r²(1 − r)
```

**Definition 2.3** (Epistemic Landscape). An *epistemic landscape* is a pair `(α, U)` where `α ≥ 0` and `U = trust(α, ·)`.

**Definition 2.4** (Critical Sensitivity). The *critical sensitivity* is `α* = 4`.

**Definition 2.5** (Admissible Suspicion Function). A function `S : ℝ → ℝ` is *admissible* if:
- `S(0) = 0`
- `S(1) = 0`  
- There exists `c ∈ (0,1)` with `S(c) > 0`

### 2.2 Key Algebraic Identity

The trust function admits a revealing factorization:
```
U(r) = r · (α·r² − α·r + 1) = r · (α·(r − 1/2)² + (1 − α/4))
```
The completing-the-square form shows that the inner factor is a sum of a non-negative term `α·(r − 1/2)²` and a constant `1 − α/4`. When `α ≤ 4`, the constant is non-negative, making the entire inner factor non-negative, and thus `U(r) ≥ 0` for `r ≥ 0`.

## 3. Main Results

### 3.1 The Phase Transition

**Theorem 3.1** (Subcritical Regime). *For `α ∈ [0, 4]` and `r ∈ [0, 1]`, we have `U(r) ≥ 0`.*

*Proof.* By the completing-the-square factorization,
```
U(r) = r · (α·(r − 1/2)² + (1 − α/4))
```
Since `r ≥ 0`, `α ≥ 0`, `(r − 1/2)² ≥ 0`, and `1 − α/4 ≥ 0` (because `α ≤ 4`), each factor is non-negative. □

**Theorem 3.2** (Supercritical Regime). *For `α > 4`, there exists `r ∈ (0, 1)` with `U(r) < 0`.*

*Proof.* Take `r = 1/2`. Then `U(1/2) = 1/2 − α/8 < 1/2 − 4/8 = 0`. □

**Theorem 3.3** (Critical Point). *`U(4, 1/2) = 0`.*

**Theorem 3.4** (Sharp Phase Transition). *The critical sensitivity `α* = 4` is the exact boundary: for all `r ∈ [0,1]`, `trust(4, r) ≥ 0`; and for all `ε > 0`, there exists `r ∈ (0,1)` with `trust(4 + ε, r) < 0`.*

### 3.2 The Discriminant Characterization

**Theorem 3.5** (Discriminant Criterion). *Define the discriminant `Δ(α) = α² − 4α = α(α − 4)`. For `α ≥ 0`, we have `Δ(α) ≤ 0` if and only if `α ≤ 4`.*

This provides an algebraic characterization: the quadratic factor `αr² − αr + 1` has no real roots (hence is always positive) exactly when `α ∈ [0, 4]`.

### 3.3 Suspicion Peak

**Theorem 3.6** (Suspicion Maximum). *For all `r ∈ [0, 1]`, `S(r) ≤ S(2/3) = 4/27`.*

*Proof sketch.* The difference `S(2/3) − S(r)` factors as `(2 − 3r)²(1 + 3r)/27`, which is non-negative for `r ≥ 0`. □

### 3.4 Valley Width

**Theorem 3.7** (Valley Width). *For `α > 4`, there exist `a, b` with `0 < a < b < 1` such that:*
- *`U(a) = U(b) = 0`*
- *For all `r ∈ (a, b)`, `U(r) < 0`*

*Proof sketch.* We use the intermediate value theorem. First, `U(0) = 0` and for small positive `r`, `U(r) > 0` (specifically, `U(1/(α+1)) > 0`). Since `U(1/2) < 0` for `α > 4`, by IVT there exists `a ∈ (0, 1/2)` with `U(a) = 0`. Similarly, since `U(1) = 1 > 0` and `U(1/2) < 0`, there exists `b ∈ (1/2, 1)` with `U(b) = 0`. The negativity between `a` and `b` follows from the structure of the cubic polynomial. □

### 3.5 The Epistemic Barrier Theorem

**Theorem 3.8** (Epistemic Barrier — Universal Form). *For any admissible suspicion function `S`, there exists `α₀ > 0` such that for all `α > α₀`, there exists `r ∈ (0, 1)` with `r − α·S(r) < 0`.*

*Proof.* Let `c ∈ (0, 1)` with `S(c) > 0` (guaranteed by admissibility). Set `α₀ = c/S(c)`. For `α > α₀`:
```
r − α·S(c) = c − α·S(c) < c − (c/S(c))·S(c) = 0
```
□

This theorem shows that the uncanny valley is not an artifact of our specific polynomial model. It is a universal consequence of the tension between rigor and scrutiny.

### 3.6 Valley Depth

**Theorem 3.9** (Antitone Trust at Midpoint). *The function `α ↦ U(α, 1/2) = 1/2 − α/8` is antitone (decreasing).*

**Theorem 3.10** (Valley Depth Characterization). *The midpoint valley depth `max(0, α/8 − 1/2)` is zero for `α ≤ 4` and positive for `α > 4`.*

### 3.7 Energy Landscape Interpretation

**Definition 3.11** (Epistemic Energy). The *epistemic energy* at rigor level `r` is `E(r) = −U(r)`.

**Theorem 3.12** (Energy Barrier). *For `α > 4`, the energy landscape has a positive barrier: there exists `r ∈ (0, 1)` with `E(r) > 0`.*

This connects the epistemic valley to potential energy barriers in physics. The trust function has the same mathematical structure as a particle's potential energy landscape, with the valley corresponding to a barrier that must be crossed.

## 4. Multi-Dimensional Generalization

### 4.1 Definitions

**Definition 4.1** (Rigor Vector). A *rigor vector* in `n` dimensions is a function `v : Fin(n) → [0,1]`.

**Definition 4.2** (Multi-Dimensional Suspicion). For a rigor vector `v`, the *compound suspicion* is:
```
S_n(v) = ∏ᵢ S(vᵢ) = ∏ᵢ vᵢ²(1 − vᵢ)
```

**Theorem 4.3** (Non-negativity). *For valid rigor vectors, `S_n(v) ≥ 0`.*

### 4.2 Conjecture: Valley Codimension

**Conjecture 4.4** (Valley Hypersurface). *For `n` independent rigor dimensions and `α` sufficiently large, the zero set `{v ∈ [0,1]ⁿ : trust_n(α, v) = 0}` forms a codimension-1 hypersurface separating trusted and untrusted regions.*

The one-dimensional case is established by Theorem 3.7. The higher-dimensional case requires intersection theory machinery beyond current formalization capabilities.

## 5. Algorithms

### 5.1 Computing the Critical Sensitivity

For the standard model, `α* = 4` exactly. For a general admissible suspicion function `S`, the critical sensitivity can be computed as:
```
α* = inf { c / S(c) : c ∈ (0,1), S(c) > 0 }
```

### 5.2 Computing Valley Boundaries

For `α > 4` in the standard model, the valley boundaries are the roots of `αr² − αr + 1 = 0`:
```
a = (α − √(α² − 4α)) / (2α)
b = (α + √(α² − 4α)) / (2α)
```

### 5.3 Complexity

All computations are O(1) for the standard model. For general suspicion functions represented as degree-`d` polynomials, critical sensitivity computation is O(d).

## 6. Applications and Discussion

### 6.1 Mathematical Pedagogy

The model suggests that partial formalization can be counterproductive. For students with high suspicion sensitivity (e.g., advanced undergraduates who have been trained to spot errors), an informal but honest proof sketch may be more effective than a partially formalized argument. The phase transition at `α = 4` provides a quantitative threshold for when this effect kicks in.

### 6.2 Proof Presentation Strategy

The valley width theorem implies a binary strategy for proof presentation: commit to either full informality or full rigor. The worst strategy is to aim for 60-80% rigor, which places the proof squarely in the valley for any moderately skeptical reader.

### 6.3 Connection to Energy Barriers

The mathematical parallel between epistemic energy barriers and physical energy barriers suggests that tools from statistical mechanics — Kramers' escape rate theory, transition state theory — could be applied to model how mathematical communities navigate the rigor landscape over time.

## 7. Future Work

1. **Multi-dimensional valley topology**: Characterize the topology of the valley hypersurface in higher dimensions.
2. **Dynamic models**: Incorporate time evolution as proofs are refined.
3. **Social dynamics**: Model how communities of readers with different sensitivities interact.
4. **Empirical validation**: Design experiments to measure suspicion sensitivity in real proof readers.
5. **Optimal exposition**: Given a distribution of reader sensitivities, find the rigor level that maximizes expected trust.

## 8. References

1. Mori, M. (1970). *The Uncanny Valley*. Energy, 7(4), 33–35.
2. De Millo, R., Lipton, R., Perlis, A. (1979). *Social processes and proofs of theorems and programs*. Communications of the ACM, 22(5), 271–280.
3. Thurston, W. (1994). *On proof and progress in mathematics*. Bulletin of the AMS, 30(2), 161–177.
4. Hales, T. (2008). *Formal proof*. Notices of the AMS, 55(11), 1370–1380.
