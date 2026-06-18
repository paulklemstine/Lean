# A Tropical Stone–Weierstrass Theorem: Formalized

## Abstract

We formalize a tropical analogue of the Stone–Weierstrass approximation theorem for continuous real-valued functions on compact Hausdorff spaces. The theorem establishes that a set of continuous functions closed under pointwise maximum (tropical addition), pointwise minimum, constant shifts (tropical scalar multiplication), containing all constants, and tropically separating points, is uniformly dense in the space of all continuous functions. The proof follows a direct two-pass compactness argument — first using infimum to build locally controlled approximants, then using supremum to patch them globally. The complete formalization is machine-verified in Lean 4 using the Mathlib library. We also show that the infimum closure hypothesis is necessary, providing a concrete counterexample (convex functions on [0,1]) that satisfies all other hypotheses but fails density.

**Keywords:** Stone–Weierstrass theorem, tropical algebra, max-plus semiring, formal verification, Lean 4, continuous function spaces

---

## 1. Introduction

The Stone–Weierstrass theorem is one of the foundational results of functional analysis, asserting that subalgebras of continuous functions separating points are dense in the uniform topology. Since Stone's generalization (1948) of Weierstrass's original polynomial approximation theorem (1885), numerous variants have been proved: for lattice subalgebras, for complex-valued functions, for locally compact spaces, and for various algebraic structures.

In this paper, we establish and formally verify a variant motivated by *tropical mathematics* — the study of algebraic structures where addition is replaced by maximum and multiplication by ordinary addition. This "max-plus" algebra has found deep applications in optimization, control theory, discrete event systems, and algebraic geometry.

### 1.1 The Tropical Perspective

In the max-plus semiring (ℝ ∪ {-∞}, max, +), the basic operations are:
- **Tropical addition:** a ⊕ b = max(a, b)
- **Tropical multiplication:** a ⊙ b = a + b

A natural question arises: does the Stone–Weierstrass approximation theorem survive tropicalization? That is, if we replace the ring operations on function spaces with tropical operations (pointwise max and constant shifts), do we retain universal approximation?

### 1.2 Main Result

We prove:

**Theorem (Tropical Stone–Weierstrass).** *Let X be a compact Hausdorff space and A ⊆ C(X, ℝ) a set of continuous functions satisfying:*
1. *A contains all constant functions*
2. *A is closed under pointwise max (f, g ∈ A ⟹ max(f,g) ∈ A)*
3. *A is closed under pointwise min (f, g ∈ A ⟹ min(f,g) ∈ A)*
4. *A is closed under constant shifts (f ∈ A, c ∈ ℝ ⟹ c + f ∈ A)*
5. *A tropically separates points: for any x ≠ y in X and any a, b ∈ ℝ and ε > 0, there exists f ∈ A with |f(x) - a| < ε and |f(y) - b| < ε*

*Then A is uniformly dense in C(X, ℝ): for every f ∈ C(X, ℝ) and ε > 0, there exists g ∈ A with ‖f - g‖_∞ < ε.*

### 1.3 Necessity of Infimum Closure

An important finding of this work is that hypothesis (3) — closure under pointwise min — cannot be dropped. We provide a concrete counterexample: the set of continuous convex functions on [0,1] satisfies hypotheses (1), (2), (4), and (5) but is a closed proper subset of C([0,1], ℝ), hence not dense.

This is perhaps surprising from the tropical perspective, where min does not correspond to a natural max-plus operation. It reflects a fundamental asymmetry: the supremum of functions each bounded above by f + ε still satisfies this bound, but without infimum, there is no mechanism to construct functions with controlled upper bounds from those with only pointwise control.

---

## 2. Definitions

We work with the space C(X, ℝ) of continuous real-valued functions on a topological space X, equipped with the supremum norm ‖f‖_∞ = sup_{x ∈ X} |f(x)| (which is a genuine norm when X is compact).

**Definition 2.1** (Tropical Shift Closure). A set A ⊆ C(X, ℝ) is *tropically shift-closed* if for every f ∈ A and c ∈ ℝ, the function x ↦ c + f(x) belongs to A.

**Definition 2.2** (Tropical Sup Closure). A is *tropically sup-closed* if for every f, g ∈ A, the pointwise maximum f ∨ g belongs to A.

**Definition 2.3** (Tropical Inf Closure). A is *tropically inf-closed* if for every f, g ∈ A, the pointwise minimum f ∧ g belongs to A.

**Definition 2.4** (Tropical Constants). A *contains tropical constants* if for every c ∈ ℝ, the constant function x ↦ c belongs to A.

**Definition 2.5** (Tropical Point Separation). A *tropically separates points* if for any x ≠ y in X and any a, b ∈ ℝ and ε > 0, there exists f ∈ A with |f(x) - a| < ε and |f(y) - b| < ε.

Note that tropical point separation is strictly stronger than classical point separation (which only requires f(x) ≠ f(y)). It asserts approximate *interpolation*: not just distinguishing points, but hitting prescribed values at them.

---

## 3. Proof

The proof follows a two-pass compactness argument, directly implementing the classical lattice Stone–Weierstrass strategy adapted to our tropical hypotheses.

### 3.1 First Pass: Local Upper-Bounded Approximants

**Lemma 3.1** (Local Upper Bound). *For each x ∈ X, there exists g_x ∈ A such that:*
- *g_x(z) < f(z) + ε for all z ∈ X (global upper control)*
- *g_x(x) > f(x) - ε (lower control at the anchor)*

*Proof.* For each y ∈ X, we construct a function h_y ∈ A with h_y(x) ≈ f(x) and h_y(y) ≈ f(y):

- If y = x, take h_y to be the constant function f(x).
- If y ≠ x, use tropical separation to find h_y ∈ A with |h_y(x) - f(x)| < ε/2 and |h_y(y) - f(y)| < ε/2.

For each y, the set U_y = {z : h_y(z) < f(z) + ε} is open (as the preimage of (-∞, ε) under the continuous function h_y - f) and contains y (since h_y(y) < f(y) + ε/2 < f(y) + ε).

The family {U_y}_{y ∈ X} covers X. By compactness, extract a finite subcover {U_{y₁}, ..., U_{yₙ}}.

Define g_x = inf(h_{y₁}, ..., h_{yₙ}), which belongs to A by inf closure. Then:
- For any z ∈ X, some y_j satisfies z ∈ U_{y_j}, so g_x(z) ≤ h_{y_j}(z) < f(z) + ε.
- At x: each h_{y_i}(x) > f(x) - ε/2, so g_x(x) = min_i h_{y_i}(x) > f(x) - ε/2 > f(x) - ε. □

### 3.2 Second Pass: Global Patching via Supremum

Apply Lemma 3.1 (with ε/2) to obtain, for each x ∈ X, a function g_x ∈ A with g_x ≤ f + ε/2 globally and g_x(x) > f(x) - ε/2.

The sets V_x = {z : g_x(z) > f(z) - ε/2} are open and cover X (since x ∈ V_x). By compactness, extract {V_{x₁}, ..., V_{xₘ}}.

Define g = sup(g_{x₁}, ..., g_{xₘ}), which belongs to A by sup closure. Then:

- **Upper bound:** For any z, g(z) = max_j g_{x_j}(z). Each g_{x_j}(z) < f(z) + ε/2 < f(z) + ε. So g(z) < f(z) + ε.

- **Lower bound:** For any z, some x_j satisfies z ∈ V_{x_j}, so g(z) ≥ g_{x_j}(z) > f(z) - ε/2 > f(z) - ε.

Therefore |f(z) - g(z)| < ε for all z ∈ X, giving ‖f - g‖_∞ < ε. □

---

## 4. The Counterexample

**Proposition 4.1.** *The set A of continuous convex functions on [0,1] satisfies hypotheses (1), (2), (4), and (5) of the Tropical Stone–Weierstrass theorem but is not dense in C([0,1], ℝ).*

*Proof.*
- (1) Constants are convex. ✓
- (2) The pointwise maximum of convex functions is convex. ✓
- (4) If f is convex, so is c + f. ✓
- (5) For any x ≠ y and targets a, b, the affine function interpolating (x, a) and (y, b) is convex (in fact linear) and lies in A. ✓

However, A is not dense. The function f(x) = √(x(1-x)) is concave on (0,1). Uniform limits of convex functions are convex (convexity is preserved under pointwise limits), so the closure of A equals A itself. Since f is not convex, f ∉ cl(A), so A is not dense. □

This counterexample reveals that supremum closure alone cannot build functions with global upper control. The infimum operation is essential for "capping" functions from above in the first pass of the proof.

---

## 5. Formal Verification

The complete proof is formalized in Lean 4 (version 4.28.0) using the Mathlib library. The formalization consists of approximately 250 lines in the file `Bridges/TropicalStoneWeierstrass.lean` and includes:

| Declaration | Type |
|-------------|------|
| `IsTropicallyClosedShift` | Definition |
| `IsTropicallyClosedSup` | Definition |
| `IsTropicallyClosedInf` | Definition |
| `ContainsTropicalConstants` | Definition |
| `TropicallySeparatesPoints` | Definition |
| `IsFiniteTropicalSupShift` | Definition |
| `IsTropicallyClosedInf.finset_inf'` | Lemma |
| `IsTropicallyClosedSup.finset_sup'` | Lemma |
| `tropical_local_upper_bound` | Key Lemma |
| `tropical_stone_weierstrass_eml` | **Main Theorem** |
| `tropical_stone_weierstrass_eml_dense` | Density Corollary |

The formalization depends only on the standard axioms of Lean's type theory: `propext`, `Classical.choice`, and `Quot.sound`. No additional axioms, sorry-free.

### 5.1 Key Design Decisions

1. **Approximate vs. exact separation.** Mathlib's existing lattice Stone–Weierstrass (`sublattice_closure_eq_top`) requires *exact* two-point interpolation (`SeparatesPointsStrongly`). Our tropical separation condition only requires *approximate* interpolation. This necessitates a direct proof rather than reduction to the Mathlib theorem, but yields a more natural tropical statement.

2. **Bundled continuous maps.** We use Mathlib's `ContinuousMap` (notation `C(X, ℝ)`) throughout, which provides the lattice structure (⊔ for max, ⊓ for min) and the norm `‖·‖` on compact domains.

3. **Finset-based compactness.** Both compactness arguments use `CompactSpace.elim_nhds_subcover`, which returns a `Finset` of indices. This keeps the proof constructive at the finset level.

---

## 6. Applications and Significance

### 6.1 Tropical Neural Networks

A max-plus neural network computes functions of the form:

g(x) = max_{j=1..m} min_{i=1..n_j} (a_{ij} · x + b_{ij})

This is exactly the max-min structure arising from our proof: a finite supremum (over anchor points) of finite infima (over interpolation points) of affine functions. The Tropical Stone–Weierstrass theorem therefore provides a **universal approximation guarantee** for tropical neural networks: any continuous function on a compact domain can be uniformly approximated by a max-min network of sufficient width.

### 6.2 Optimization and Dynamic Programming

In dynamic programming and optimal control, the Bellman equation has a max-plus linear structure:

V(x) = max_a [r(x, a) + γ · V(T(x, a))]

The value function V is computed as a fixed point of a max-plus linear operator. Our theorem implies that the space of max-min combinations of basis functions is dense in the continuous function space, providing a theoretical foundation for function approximation in approximate dynamic programming.

### 6.3 Tropical Geometry and Valuations

In tropical algebraic geometry, tropical polynomials are max-plus combinations of affine functions:

p(x) = max_i (c_i + ⟨a_i, x⟩)

These are exactly the functions in the max-plus closure of affine functions. While our theorem shows that max-min (not just max-plus) combinations are needed for density, it precisely characterizes what tropical polynomial approximation can and cannot achieve.

---

## 7. Discussion: A Bridge Between Worlds

*For a general audience*

Imagine you're an architect trying to design a building's roof profile. You have at your disposal only two tools: you can take the *higher* of two existing profiles (like stacking transparent sheets and looking at the skyline from above), and you can *shift* any profile up or down by a constant amount. These are the tropical operations — the mathematical equivalent of "take the max" and "add a constant."

The Stone–Weierstrass theorem, proved in the 1930s, is one of mathematics' great universality results. It says that if you have enough building-block functions that can tell different points apart, you can approximate *any* continuous shape by combining them with standard arithmetic (addition, multiplication, scaling). It's the theoretical reason why neural networks, Fourier series, and polynomial approximations work.

Our tropical Stone–Weierstrass theorem asks: what if you replace standard arithmetic with tropical operations? The answer has a twist. With max alone (our "stacking transparent sheets"), you can only build shapes that are convex — like the roofline of a series of peaked tents. You can never approximate a valley or a bowl, no matter how many tent-peaks you combine. This is our counterexample.

But if you add one more tool — the ability to take the *lower* of two profiles (like looking at the intersection of two ceilings) — then universality is restored. Any continuous shape can be approximated by a finite sequence of max-min combinations of your building blocks. This is the mathematical analogue of building complex shapes from simple peaked and valley components.

The result matters because tropical mathematics has become the language of optimization. When you solve a shortest-path problem, schedule a factory, or train a max-pooling neural network, you're working in the tropical world. Our theorem says that this world has its own version of the fundamental approximation guarantee that underlies all of classical analysis.

### 7.1 Historical Context

The journey from Weierstrass (1885) to tropical Stone–Weierstrass passes through several milestones:

- **Weierstrass (1885):** Polynomials are dense in C([a,b]).
- **Stone (1937, 1948):** Subalgebras separating points are dense; lattice variant.
- **Litvinov–Maslov (1990s–2000s):** Systematic development of idempotent analysis and tropical mathematics.
- **Zhang et al. (2018), Hertrich et al. (2021):** Tropical neural networks and their approximation properties.
- **This work (2025):** Formal machine-verified proof that tropical approximation theory is sound, with precise characterization of necessary hypotheses.

---

## 8. Conclusion

We have established and formally verified a tropical Stone–Weierstrass theorem, showing that sets of continuous functions closed under max, min, and constant shifts, containing constants and tropically separating points, are uniformly dense. The proof is direct (not reducing to the classical theorem), uses only standard compactness arguments, and is completely machine-verified in Lean 4.

The key mathematical insight is that both max and min are necessary: max alone gives only "convex-like" approximations. This reveals a fundamental asymmetry in tropical approximation that has practical implications for the design of tropical neural networks and max-plus function approximation schemes.

---

## References

1. Stone, M.H. "A generalized Weierstrass approximation theorem." *Mathematics Magazine* 21.4 (1948): 167–184.

2. Litvinov, G.L., Maslov, V.P. "Idempotent mathematics and mathematical physics." *Contemporary Mathematics* 377 (2005).

3. Hertrich, C., Bock, S., Brandenberg, R., Gritzmann, P. "Towards lower bounds on the depth of ReLU neural networks." *NeurIPS* (2021).

4. Zhang, L., Naitzat, G., Lim, L.-H. "Tropical geometry of deep neural networks." *ICML* (2018).

5. The Mathlib Community. "Mathlib: a unified library of mathematics formalized in Lean." Available at https://github.com/leanprover-community/mathlib4.
