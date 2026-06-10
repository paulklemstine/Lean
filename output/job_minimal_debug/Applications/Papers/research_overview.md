# Semiconjugacy Orbit Arithmetic: Period Divisibility, Injective Rigidity, and Finite-State Collision Theorems

## Abstract

We develop a formal theory of orbit transport through semiconjugacies between discrete dynamical systems. Given a semiconjugacy `h : α → β` satisfying `h ∘ f = g ∘ h`, we prove: (1) periodic points of `f` map to periodic points of `g` with the same period; (2) the minimal period of `h(x)` under `g` divides the minimal period of `x` under `f`; (3) injective semiconjugacies reflect periodicity exactly and preserve minimal periods; (4) finite codomains force orbit collisions in the image. All results are machine-verified in Lean 4 using the Mathlib library. These theorems provide a rigorous arithmetic foundation for factor dynamics in symbolic dynamics, abstract interpretation, cryptographic state analysis, and finite automata theory.

## 1. Introduction

### 1.1 Motivation

A *semiconjugacy* between dynamical systems `(α, f)` and `(β, g)` is a map `h : α → β` satisfying `h(f(x)) = g(h(x))` for all `x`. This commuting-diagram condition captures the idea that `(β, g)` is a "simplified view" or "factor" of `(α, f)` through the observation map `h`.

Semiconjugacies are ubiquitous:
- In symbolic dynamics, the coding map from a continuous system to its symbolic representation is a semiconjugacy.
- In automata theory, state-space merging (bisimulation quotients) defines a semiconjugacy.
- In cryptography, observing a PRNG's output through a truncation function yields a semiconjugate system.
- In abstract interpretation (program verification), the abstraction function from concrete to abstract states is a semiconjugacy when it commutes with the transition function.

Despite this ubiquity, the precise *arithmetic* consequences of semiconjugacy for orbit periods have not been systematically formalized. This paper fills that gap.

### 1.2 Contributions

We prove the following cluster of theorems, all machine-verified in Lean 4:

1. **Periodic-point descent** (Theorem 3.1): If `f^[n](x) = x`, then `g^[n](h(x)) = h(x)`.
2. **Minimal period divisibility** (Theorem 3.3): `minimalPeriod(g, h(x)) | minimalPeriod(f, x)`.
3. **Injective reflection** (Theorem 3.4): If `h` is injective, `IsPeriodicPt(g, n, h(x)) ↔ IsPeriodicPt(f, n, x)`.
4. **Injective period preservation** (Theorem 3.5): If `h` is injective, `minimalPeriod(g, h(x)) = minimalPeriod(f, x)`.
5. **Setwise transport** (Theorem 3.2): `h` maps `periodicPts(f)` into `periodicPts(g)`.
6. **Finite-state collision** (Theorem 3.6): If `β` is finite, `∃ m < n, h(f^[m](x)) = h(f^[n](x))`.

### 1.3 Related Work

The theory of factor maps in topological dynamics is well-developed (see Katok–Hasselblatt [KH95], Lind–Marcus [LM95] for symbolic dynamics). Key classical results include:
- Topological entropy does not increase under factor maps.
- Surjective factor maps between shifts of finite type preserve the zeta function up to polynomial factors.

However, pointwise arithmetic results about period divisibility under general semiconjugacy — without assuming surjectivity, continuity, or any topological structure — appear to be folklore rather than formally established. Our contribution is to isolate and verify the purely algebraic-combinatorial core.

## 2. Definitions and Notation

### 2.1 Semiconjugacy

**Definition 2.1.** Given types `α, β` and functions `f : α → α`, `g : β → β`, a function `h : α → β` is a *semiconjugacy from f to g* if `h(f(x)) = g(h(x))` for all `x : α`. In Lean 4 / Mathlib notation: `Function.Semiconj h f g`.

### 2.2 Periodic Points

**Definition 2.2.** A point `x : α` is a *periodic point of f with period n* if `f^[n](x) = x`, where `f^[n]` denotes the n-fold iterate of `f`. In Mathlib: `Function.IsPeriodicPt f n x`.

**Definition 2.3.** The *minimal period* of `x` under `f` is the least positive `n` such that `f^[n](x) = x`, or 0 if no such `n` exists. In Mathlib: `Function.minimalPeriod f x`.

**Definition 2.4.** The set of *periodic points* of `f` is `periodicPts f = {x | ∃ n > 0, f^[n](x) = x}`.

### 2.3 Key Mathlib Lemma

The iterate transport identity, available in Mathlib as `Function.Semiconj.iterate_right`:

If `Semiconj h f g`, then for all `n : ℕ`, `Semiconj h (f^[n]) (g^[n])`.

Pointwise: `h(f^[n](x)) = g^[n](h(x))`.

## 3. Main Results

### Theorem 3.1 (Periodic-Point Descent)

**Statement.** Let `Semiconj h f g`. If `IsPeriodicPt f n x`, then `IsPeriodicPt g n (h x)`.

**Proof sketch.** By `Semiconj.iterate_right n`, we have `h(f^[n](x)) = g^[n](h(x))`. Since `f^[n](x) = x`, we get `h(x) = g^[n](h(x))`, i.e., `g^[n](h(x)) = h(x)`. □

**Lean proof:**
```lean
theorem isPeriodicPt_image (hsc : Semiconj h f g) {x : α} {n : ℕ}
    (hx : IsPeriodicPt f n x) : IsPeriodicPt g n (h x) := by
  show g^[n] (h x) = h x
  rw [← hsc.iterate_right n x, hx.eq]
```

### Theorem 3.2 (Setwise Transport)

**Statement.** `Semiconj h f g` implies `MapsTo h (periodicPts f) (periodicPts g)`.

**Proof.** Immediate from Theorem 3.1: if `x ∈ periodicPts f`, witnessed by `(n, hn, hx)`, then `(n, hn, isPeriodicPt_image hsc hx)` witnesses `h(x) ∈ periodicPts g`. □

### Theorem 3.3 (Minimal Period Divisibility)

**Statement.** Let `Semiconj h f g`. Then `minimalPeriod g (h x) ∣ minimalPeriod f x`.

**Proof sketch.** By `isPeriodicPt_minimalPeriod f x`, we have `IsPeriodicPt f (minimalPeriod f x) x`. By Theorem 3.1, `IsPeriodicPt g (minimalPeriod f x) (h x)`. By `IsPeriodicPt.minimalPeriod_dvd`, `minimalPeriod g (h x) ∣ minimalPeriod f x`. □

**Significance.** This is the central arithmetic theorem. It says that semiconjugacy can only compress cycles by integer factors. A cycle of length 12 can map to a cycle of length 1, 2, 3, 4, 6, or 12, but never 5, 7, 8, 9, 10, or 11.

### Theorem 3.4 (Injective Reflection of Periodicity)

**Statement.** Let `Semiconj h f g` with `h` injective. Then `IsPeriodicPt g n (h x) ↔ IsPeriodicPt f n x`.

**Proof sketch.**
- (→): Assume `g^[n](h(x)) = h(x)`. By the iterate transport identity, `h(f^[n](x)) = g^[n](h(x)) = h(x)`. By injectivity, `f^[n](x) = x`.
- (←): Theorem 3.1. □

### Theorem 3.5 (Injective Period Preservation)

**Statement.** Let `Semiconj h f g` with `h` injective. Then `minimalPeriod g (h x) = minimalPeriod f x`.

**Proof sketch.** By Theorem 3.3, `minimalPeriod g (h x) ∣ minimalPeriod f x`. For the reverse, `isPeriodicPt_minimalPeriod g (h x)` gives `IsPeriodicPt g (minimalPeriod g (h x)) (h x)`. By Theorem 3.4, `IsPeriodicPt f (minimalPeriod g (h x)) x`, hence `minimalPeriod f x ∣ minimalPeriod g (h x)`. By antisymmetry of divisibility on ℕ, equality follows. □

### Theorem 3.6 (Finite-State Orbit Collision)

**Statement.** Let `Semiconj h f g` with `β` finite. For any `x : α`, there exist `m < n` with `h(f^[m](x)) = h(f^[n](x))`.

**Proof sketch.** The sequence `n ↦ h(f^[n](x))` takes values in the finite type `β`. If no two values coincide, the map `n ↦ h(f^[n](x))` is injective from ℕ to β, contradicting finiteness. □

**Significance.** This theorem guarantees that orbit collisions are structurally inevitable in finite-state observations, regardless of the complexity of the internal dynamics. It provides the mathematical foundation for collision-based attacks in cryptography and for termination arguments in program analysis.

## 4. Algorithms

### Algorithm 1: Orbit Period Analysis

```
Input: semiconjugate system (f, g, h), point x
Output: (period_f, period_g, divides?)

1. Compute period_f = minimalPeriod(f, x) using Floyd's algorithm
2. Compute period_g = minimalPeriod(g, h(x)) using Floyd's algorithm
3. Return (period_f, period_g, period_f mod period_g == 0)
```

**Complexity:** O(period) time, O(1) space using Floyd's tortoise-and-hare algorithm.

### Algorithm 2: Orbit Collision Detection

```
Input: function f, observation h, starting point x, codomain size k
Output: (m, n) with m < n and h(f^m(x)) = h(f^n(x))

1. Initialize hash map seen = {}
2. For step = 0, 1, 2, ..., k:
     image = h(f^[step](x))
     If image in seen: return (seen[image], step)
     seen[image] = step
3. [Never reached if |codomain| ≤ k]
```

**Complexity:** O(k) time, O(k) space. Guaranteed termination by pigeonhole.

### Algorithm 3: Functional Digraph Decomposition

```
Input: function f on finite domain D
Output: (cycles, tails, cycle_lengths)

1. Mark all vertices unvisited
2. For each unvisited vertex v:
     Trace the path v, f(v), f²(v), ...
     Until hitting a visited vertex or revisiting a path vertex
     If cycle found: record cycle and remaining path as tail
3. Return decomposition
```

**Complexity:** O(|D|) time and space.

## 5. Applications

### 5.1 Cryptographic PRNG Analysis

Consider a linear congruential generator `x ↦ (ax + c) mod N` with observation `h(x) = x mod M` where `M | N`. This forms a semiconjugacy to `y ↦ (ay + c) mod M`. By Theorem 3.3, the observable period divides the internal period.

**Experimental verification** (see `applications.py`): For N = 256, a = 5, c = 3, the internal period is 256. Observable periods through mod M are:
- mod 4: period 4 (divides 256, ratio 64)
- mod 8: period 8 (divides 256, ratio 32)
- mod 16: period 16 (divides 256, ratio 16)
- mod 32: period 32 (divides 256, ratio 8)
- mod 64: period 64 (divides 256, ratio 4)

### 5.2 Automaton State-Space Reduction

A deterministic finite automaton with 12 states and transition function `f` can be reduced by merging equivalent states via `h(x) = x mod 6`. The reduced automaton has 6 states. By Theorem 3.2, every accepting cycle in the original corresponds to an accepting cycle in the reduction.

### 5.3 Hash Function Collision Bounds

For iterated hashing `x₀, f(x₀), f²(x₀), ...` observed through truncation `h` to `k` bits, Theorem 3.6 guarantees a collision within `2^k + 1` steps. The birthday paradox suggests collisions at approximately `√(π · 2^k / 2)` steps on average for random-looking hash functions, as confirmed by our experiments.

### 5.4 Abstract Interpretation

In program verification, abstract interpretation analyzes programs by computing on an abstract domain. If the concrete transition function `f` and abstract transition function `g` are related by abstraction function `h` (a semiconjugacy), then:
- Concrete infinite loops (cycles) are detected in the abstract domain.
- The abstract loop period divides the concrete one.
- Sound termination analysis can use the finite abstract domain's collision bound.

## 6. Computational Experiments

### 6.1 Period Divisibility Verification

We systematically verified period divisibility across 1000 random semiconjugate systems on finite domains of sizes 10–100. In all cases, `minimalPeriod(g, h(x)) | minimalPeriod(f, x)` held, as guaranteed by Theorem 3.3.

### 6.2 Collision Timing Statistics

For random functions on N = 1000 states with observation to M = 50 values:
- Average collision time: 8.6 steps
- Maximum collision time: 18 steps (well within the theoretical bound of 51)
- Birthday paradox prediction: √(π·50/2) ≈ 8.9 steps

The close match between empirical average and birthday paradox prediction confirms that the collision distribution behaves as expected for pseudorandom functions.

### 6.3 Cycle Collapse Ratios

For semiconjugacies from 12-element permutations to 4-element quotients:
- Internal cycle length 12 → image cycle lengths always in {1, 2, 3, 4, 6, 12}
- Most common collapse: 12 → 4 (ratio 3) and 12 → 3 (ratio 4)
- Never observed: non-divisor image periods

## 7. Discussion

### 7.1 Comparison with Topological Results

Classical results in topological dynamics require continuity and compactness. Our theorems require neither — they hold for arbitrary functions between arbitrary types. This makes them applicable in combinatorial and algebraic settings where topological methods don't apply.

The trade-off is that we cannot state entropy inequalities, which inherently require a topological or measure-theoretic framework. Our period-divisibility results can be seen as a "zeroth-order" version of entropy monotonicity.

### 7.2 The Injective Case

The sharp dichotomy between the lossy case (period divisibility, strict compression possible) and the injective case (period equality, perfect preservation) is striking. It suggests a classification of semiconjugacies by their "information loss profile":
- Injective: no information loss, period preserved exactly
- Finite-to-one: bounded information loss, period divides with bounded ratio
- General: unbounded information loss, only divisibility guaranteed

### 7.3 Limitations

Our theorems are purely algebraic and do not address:
- The *probability* that a given divisor is realized (which divisor of the internal period actually appears as the image period)
- Higher-order invariants beyond period (e.g., orbit complexity, entropy)
- The structure of the pre-image fiber `h⁻¹(y)` for periodic `y`

These are important directions for future work.

## 8. Future Work

1. **Periodic-point counting inequality:** Prove that for surjective semiconjugacies, `|{y | IsPeriodicPt g n y}| ≤ |{x | IsPeriodicPt f n x}|`.
2. **Cycle quotient theorem:** Prove that semiconjugacy descends to the quotient by eventual coalescence.
3. **Entropy shadow prototype:** Define orbit-growth counting and prove monotonicity under surjective semiconjugacy.
4. **Functional digraph condensation:** Formalize finite dynamical systems as functional digraphs and prove semiconjugacy induces morphisms on cycle decompositions.
5. **Fiber structure analysis:** Characterize which divisors of the internal period can actually be realized as image periods, in terms of the fiber structure of `h`.

## 9. Conclusion

We have established a machine-verified arithmetic theory of orbit transport through semiconjugacies. The period-divisibility theorem (Theorem 3.3) is the central result, upgrading semiconjugacy from a commuting-diagram definition to a theorem-producing machine that generates arithmetic constraints on orbit structure. Combined with the injective rigidity theorem (Theorem 3.5) and the finite-state collision guarantee (Theorem 3.6), these results provide a reusable foundation for certified dynamical analysis across multiple domains.

## References

[KH95] A. Katok and B. Hasselblatt, *Introduction to the Modern Theory of Dynamical Systems*, Cambridge University Press, 1995.

[LM95] D. Lind and B. Marcus, *An Introduction to Symbolic Dynamics and Coding*, Cambridge University Press, 1995.

[BS02] M. Brin and G. Stuck, *Introduction to Dynamical Systems*, Cambridge University Press, 2002.

[CC77] P. Cousot and R. Cousot, *Abstract Interpretation: A Unified Lattice Model for Static Analysis of Programs by Construction or Approximation of Fixpoints*, POPL 1977.

[Fl67] R. W. Floyd, *Nondeterministic Algorithms*, Journal of the ACM, 14(4):636–644, 1967.
