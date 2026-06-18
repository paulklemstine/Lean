# Future Directions: Tropical Cryptographic Hardness Hierarchy

## 1. Tropical Matrix Power Stabilization and Effective One-Wayness

The `tropical_power_gap_diagonal` theorem establishes that negative-diagonal tropical matrices produce non-increasing diagonal sequences under powering. A natural next step is proving that these sequences eventually **stabilize** — reaching a fixed point after finitely many steps (the "critical exponent"). The key insight is that in the min-plus semiring over integers, a monotonically non-increasing sequence bounded below by the shortest-path weight must stabilize, and this stabilization exponent is precisely the matrix dimension (by the Bellman-Ford analogy). Why now? The orbit structure theorems (`tropPow_add`, `tropMul_assoc`) provide the algebraic infrastructure to reason about power sequences, and Mathlib's `WithTop ℤ` has the well-order properties needed for the descent argument.

**Conjecture**: For any n×n tropical matrix G with all entries in ℤ (no ⊤), `tropPow G n = tropPow G (n + k)` for all k ≥ 0. This is the tropical analogue of the Bellman-Ford convergence theorem and would give a concrete security parameter for tropical OWFs.

## 2. Tropical PRG Stretch Amplification via Polynomial Composition

The current `prg_stretch_composition` theorem shows multiplicative stretch but uses a trivial construction (ignoring half the outputs). A deeper result would show that tropical PRG stretch can be amplified from 1+ε to polynomial via the Nisan-Wigderson framework adapted to the min-plus setting. The key insight is that tropical polynomial composition (which corresponds to matrix powering chains) creates exponentially many distinct power indices from logarithmically many seed values, and the min-plus structure ensures that each composition step preserves computational indistinguishability. Why now? The `tropPow_add` identity provides the compositional structure, and the `orbitHash` framework gives a natural encoding of PRG outputs as power sequences.

**Conjecture**: For any tropical PRG with stretch m > 1, there exists a tropical PRG with stretch m^d for any d, where each output is a product of at most d original PRG outputs. Moreover, if the original PRG is based on k-th power computation, the amplified PRG has security reducible to (k·d)-th power inversion.

## 3. Max-Affine CPL Decomposition Depth and Network Complexity

The `max_affine_is_cpl` theorem shows that the max of two affine functions is CPL with one breakpoint. The `cpl_add` and `cpl_sub` theorems show CPL closure under arithmetic. A major open direction is formalizing the **depth-width tradeoff**: any CPL function with N breakpoints can be computed by a ReLU network of depth O(log N) and width O(N), but requires width Ω(N^{1/d}) at depth d. The key insight is that tropical polynomial evaluation (pointwise max of affine pieces) corresponds exactly to a single ReLU layer, and the depth of the tropical rational representation equals the network depth. Why now? The `max_affine_is_cpl` result provides the base case, and the CPL closure properties give the inductive structure needed for the width-depth analysis.

**Conjecture**: There exists a family of CPL functions f_n with n breakpoints such that any ReLU network computing f_n with depth d requires width at least n^{1/(d-1)}. This would formalize the folk theorem that "deep networks can represent exponentially more breakpoints."

## 4. Tropical Hybrid Arguments and Computational Indistinguishability

The hierarchy theorems (OWF→PRG→PRF→CPA) currently use type-level implications without computational indistinguishability bounds. A natural extension is formalizing **tropical hybrid arguments**: given a sequence of n tropical matrix distributions where consecutive pairs are (ε/n)-indistinguishable, the endpoints are ε-indistinguishable. The key insight is that tropical matrix addition (which is pointwise min) preserves statistical distance bounds multiplicatively, unlike classical addition which preserves them additively — this gives tighter security reductions in the tropical setting. Why now? The orbit hash structure provides a natural sequence of hybrids (G^1, G^2, ..., G^n), and the power gap theorem constrains how much information each step reveals.

**Conjecture**: If tropical k-th power inversion has advantage at most ε, then the tropical PRG with outputs (G^k, G^{k+1}) has distinguishing advantage at most ε + negl(n), where negl(n) comes from the tropical Goldreich-Levin hard-core predicate (diagonal extraction).

## 5. Tropical Canonical Forms for Multivariate ReLU Networks

The current results handle univariate ReLU networks and their tropical polynomial representations. The multivariate case — ReLU networks ℝ^d → ℝ — involves **tropical rational functions in d variables**, where evaluation is the max of d-variable affine functions. The key insight is that the canonical form theory generalizes: multivariate tropical polynomials correspond to polyhedral complexes (Newton polytopes), and canonicality reduces to the facial structure of these polytopes. Why now? Mathlib's `Convex` and polyhedral geometry infrastructure is maturing, and the univariate results provide the template for the inductive argument on dimension.

**Conjecture**: Every continuous piecewise-linear function ℝ^d → ℝ with N linear regions can be represented as a tropical rational function with at most N terms in the numerator and N terms in the denominator. Moreover, the minimal such representation is unique up to a tropical common factor, generalizing `canonical_tropical_poly_unique` from the univariate case.
