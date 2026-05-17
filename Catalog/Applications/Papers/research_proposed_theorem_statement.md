# Period Transport Under Semiconjugacy: Formalized Orbit Arithmetic for Discrete Dynamical Systems

## Abstract

We formalize the arithmetic theory of orbit transport through semiconjugacies in the setting of discrete dynamical systems. Given a semiconjugacy `h` from `(α, f)` to `(β, g)`—that is, a map satisfying `h ∘ f = g ∘ h`—we prove that (1) periodic points descend: any period of `x` under `f` is also a period of `h(x)` under `g`; (2) minimal periods satisfy a divisibility constraint: `minimalPeriod(g, h(x)) | minimalPeriod(f, x)`; (3) injective semiconjugacies preserve minimal periods exactly; and (4) finite-codomain semiconjugacies guarantee orbit collisions by the pigeonhole principle. All results are formally verified in Lean 4 using Mathlib, with proofs depending only on the standard axioms (propext, Classical.choice, Quot.sound). We discuss applications to cryptographic state analysis, abstract interpretation, symbolic dynamics, and finite-state system reduction.

## 1. Introduction

### 1.1 Motivation

Semiconjugacy is the fundamental notion of morphism in discrete dynamical systems. If `f : α → α` and `g : β → β` are endofunctions representing deterministic state transitions, a semiconjugacy from `(α, f)` to `(β, g)` is a map `h : α → β` satisfying:

$$h \circ f = g \circ h$$

This commuting-diagram condition captures the idea that `h` is a *consistent simplification*: it does not matter whether one evolves first and then observes, or observes first and then evolves. Semiconjugacies arise naturally as:

- Factor maps in symbolic dynamics (Curtis–Hedlund–Lyndon theorem)
- Abstraction functions in abstract interpretation and model checking
- Coarse-graining maps in statistical mechanics
- Homomorphisms of automata transition functions
- Simulation relations in concurrency theory

The central question we address is: **what arithmetic constraints does semiconjugacy impose on periodic orbit structure?**

### 1.2 Contributions

We provide complete formal proofs of the following results:

1. **Periodic point descent** (`isPeriodicPt_image`): If `f^n(x) = x`, then `g^n(h(x)) = h(x)`.
2. **Minimal period divisibility** (`minimalPeriod_image_dvd`): `minimalPeriod(g, h(x)) | minimalPeriod(f, x)`, with no periodicity hypothesis required.
3. **Period witness divisibility** (`minimalPeriod_image_dvd_of_isPeriodicPt`): More generally, `minimalPeriod(g, h(x)) | n` for any `n` with `f^n(x) = x`.
4. **Injective preservation** (`minimalPeriod_eq_of_injective`): If `h` is injective, `minimalPeriod(g, h(x)) = minimalPeriod(f, x)`.
5. **Conjugacy invariance** (`minimalPeriod_eq_of_equiv`): If `h` is a bijection (equivalence), minimal period is exactly preserved.
6. **Setwise transport** (`mapsTo_periodicPts_set`, `mapsTo_periodicPts_n`): Images of periodic-point sets land in periodic-point sets.
7. **Finite-state collision** (`exists_iterate_image_eq_of_finite`): For finite `β`, observed orbits must collide.

### 1.3 Related Work

The mathematical content is classical, appearing in standard texts on dynamical systems (Brin–Stuck [1], Katok–Hasselblatt [5], Devaney [3]). However, formal verification of these results in a proof assistant is, to our knowledge, new. The Mathlib library provides foundational infrastructure for `Function.Semiconj`, `Function.IsPeriodicPt`, and `Function.minimalPeriod`, but does not include the transport theorems connecting semiconjugacy to period arithmetic. Our work fills this gap.

## 2. Definitions and Notation

### 2.1 Semiconjugacy

**Definition.** Let `f : α → α` and `g : β → β`. A function `h : α → β` is a *semiconjugacy* from `f` to `g` if `h(f(x)) = g(h(x))` for all `x : α`. In Lean 4 / Mathlib notation:

```
Function.Semiconj h f g := ∀ x, h (f x) = g (h x)
```

A *conjugacy* is a semiconjugacy where `h` is bijective (an equivalence `α ≃ β`).

### 2.2 Periodic Points and Minimal Period

**Definition.** A point `x : α` is *periodic* for `f` with period `n : ℕ` if `f^[n](x) = x`, where `f^[n]` denotes the `n`-fold iterate of `f`. In Mathlib:

```
Function.IsPeriodicPt f n x := Function.IsFixedPt (f^[n]) x := f^[n] x = x
```

**Definition.** The *minimal period* of `x` under `f` is the least positive `n` such that `f^[n](x) = x`, or `0` if no such `n` exists (Mathlib convention):

```
Function.minimalPeriod f x := Nat.find (exists period) or 0
```

Key Mathlib facts we use:
- `isPeriodicPt_minimalPeriod f x`: `f^[minimalPeriod f x](x) = x` (always holds, trivially when period is 0).
- `IsPeriodicPt.minimalPeriod_dvd`: If `f^[n](x) = x`, then `minimalPeriod f x | n`.

### 2.3 Iterate Transport

The fundamental lemma connecting semiconjugacy to iterates:

```
Function.Semiconj.iterate_right (hsc : Semiconj h f g) (n : ℕ) :
    Semiconj h (f^[n]) (g^[n])
```

This says `h(f^[n](x)) = g^[n](h(x))`, and is proved by induction on `n` (already in Mathlib).

## 3. Main Results

### 3.1 Periodic Point Descent

**Theorem 1** (`isPeriodicPt_image`). *Let `h` be a semiconjugacy from `f` to `g`. If `f^[n](x) = x`, then `g^[n](h(x)) = h(x)`.*

*Proof.* We compute:
```
g^[n](h(x)) = h(f^[n](x))    [by iterate_right]
             = h(x)            [by hypothesis f^[n](x) = x]
```
∎

This is a direct consequence of the iterate transport identity. The proof is two lines in Lean:
```lean
show g^[n] (h x) = h x
rw [← hsc.iterate_right n x, hx.eq]
```

### 3.2 Minimal Period Divisibility

**Theorem 2** (`minimalPeriod_image_dvd`). *Let `h` be a semiconjugacy from `f` to `g`. Then `minimalPeriod(g, h(x)) | minimalPeriod(f, x)` for all `x`.*

*Proof.* By Mathlib, `f^[minimalPeriod(f,x)](x) = x` (this holds even when `minimalPeriod(f,x) = 0`, trivially). Apply Theorem 1 to get `g^[minimalPeriod(f,x)](h(x)) = h(x)`. Then `IsPeriodicPt.minimalPeriod_dvd` gives the divisibility.  ∎

**Remark.** No periodicity hypothesis on `x` is needed. When `x` is aperiodic, `minimalPeriod(f, x) = 0`, and every natural number divides 0.

**Theorem 3** (`minimalPeriod_image_dvd_of_isPeriodicPt`). *Let `h` be a semiconjugacy from `f` to `g`. If `f^[n](x) = x`, then `minimalPeriod(g, h(x)) | n`.*

*Proof.* Apply Theorem 1 to get `g^[n](h(x)) = h(x)`, then apply `IsPeriodicPt.minimalPeriod_dvd`.  ∎

This is the strongest form: the minimal period downstairs divides *every* period upstairs, not just the minimal one.

### 3.3 Injective Semiconjugacy Preserves Minimal Period

**Theorem 4** (`isPeriodicPt_iff_of_injective`). *If `h` is an injective semiconjugacy from `f` to `g`, then `f^[n](x) = x ↔ g^[n](h(x)) = h(x)`.*

*Proof.* The forward direction is Theorem 1. For the reverse: if `g^[n](h(x)) = h(x)`, then by iterate transport, `h(f^[n](x)) = g^[n](h(x)) = h(x)`. Since `h` is injective, `f^[n](x) = x`.  ∎

**Theorem 5** (`minimalPeriod_eq_of_injective`). *If `h` is an injective semiconjugacy, then `minimalPeriod(g, h(x)) = minimalPeriod(f, x)`.*

*Proof.* We have `minimalPeriod(g, h(x)) | minimalPeriod(f, x)` from Theorem 2. For the reverse divisibility: `g^[minimalPeriod(g, h(x))](h(x)) = h(x)`, so by Theorem 4, `f^[minimalPeriod(g, h(x))](x) = x`, hence `minimalPeriod(f, x) | minimalPeriod(g, h(x))`. By antisymmetry of divisibility on ℕ, equality holds.  ∎

**Corollary** (`minimalPeriod_eq_of_equiv`). *Conjugacy by an equivalence preserves minimal periods exactly.*

### 3.4 Setwise Transport

**Theorem 6** (`mapsTo_periodicPts_n`). *Semiconjugacy maps the set of period-`n` points of `f` into the set of period-`n` points of `g`.*

**Theorem 7** (`mapsTo_periodicPts_set`). *Semiconjugacy maps the set of all periodic points of `f` into the set of all periodic points of `g`.*

### 3.5 Finite-State Orbit Collision

**Theorem 8** (`exists_iterate_image_eq_of_finite`). *If `β` is finite, then for any `x : α`, there exist `m < n` with `h(f^[m](x)) = h(f^[n](x))`.*

*Proof.* By contradiction: if all observed iterates were distinct, the set `{h(f^[n](x)) | n ∈ ℕ}` would be infinite, contradicting finiteness of `β`.  ∎

## 4. Applications

### 4.1 Cryptographic Orbit Analysis

In stream ciphers and pseudorandom number generators, the internal state evolves by an endofunction `f` on a large state space, while the output function `h` reveals partial information. If the system forms a semiconjugacy `h ∘ f = g ∘ h` for some output dynamics `g`, Theorem 2 constrains the observable period: it must divide the internal period.

**Example.** Consider a linear feedback shift register (LFSR) with internal period 2^16 - 1 = 65535 over GF(2)^16, observed through an 8-bit output function. The observable period must divide 65535. Since 65535 = 3 × 5 × 17 × 257, the observable period must be a product of a subset of these prime factors. This eliminates most candidate periods and constrains cryptanalytic search.

### 4.2 Abstract Interpretation

In program analysis, abstract interpretation constructs a sound over-approximation of program behavior by mapping concrete states to abstract domains via an abstraction function `α`. When the concrete transition function `f` and abstract transition function `f#` satisfy `α ∘ f = f# ∘ α` (the "exact abstraction" condition), Theorem 2 applies directly.

**Consequence:** If the abstract fixpoint computation detects a cycle of length `k`, the concrete program must have a cycle whose length is a multiple of `k`. This provides a certified lower bound on loop iteration counts from abstract analysis.

### 4.3 Symbolic Dynamics

In symbolic dynamics, a factor map `π` from a subshift `(X, σ)` to a subshift `(Y, σ)` is a continuous, shift-commuting surjection. By the Curtis–Hedlund–Lyndon theorem, every such map is induced by a sliding-window block code. Theorem 2 gives:

$$\text{minimalPeriod}(\sigma, \pi(x)) \mid \text{minimalPeriod}(\sigma, x)$$

This means factor maps can only collapse periodic orbits by divisibility. The number of periodic orbits of exact period `n` in the factor is constrained by the prime factorization of periodic orbit lengths upstairs.

### 4.4 Automata Theory

A homomorphism between deterministic finite automata—a map on states that commutes with transitions for every input symbol—is a semiconjugacy for each fixed input. Theorem 2 implies that cycle lengths in quotient automata divide cycle lengths in the original. This is the arithmetic core of automata minimization: when merging states, cycles can only collapse by exact divisors.

## 5. Computational Experiments

We implemented the theorems computationally in Python to verify them on concrete examples. Key experiments:

### 5.1 Modular Arithmetic Example

Let `f(x) = x + 1 mod 12` on ℤ/12ℤ and `h(x) = x mod 4`. Then `g(y) = y + 1 mod 4` and `h ∘ f = g ∘ h`. Every point has `minimalPeriod(f, x) = 12` and `minimalPeriod(g, h(x)) = 4`. Indeed, 4 | 12.

### 5.2 Permutation Example

Let `f = (0 1 2 3 4 5)` (6-cycle) on {0,...,5} and `h(x) = x mod 3`. Then `g = (0 1 2)` and the image period 3 divides the source period 6.

### 5.3 Non-surjective Example

Let `f(x) = x + 1 mod 6` and `h(x) = x mod 2`. Regardless of whether `h` is surjective onto the image dynamics, the period of `h(x)` under `g(y) = y + 1 mod 2` is 2, dividing 6.

### 5.4 Injective Semiconjugacy

Let `f(x) = x + 1 mod 5` on ℤ/5ℤ and `h(x) = 2x mod 10` (injective). Then `g(y) = y + 2 mod 10` and `minimalPeriod(g, h(x)) = minimalPeriod(f, x) = 5` exactly, confirming Theorem 5.

See `demo.py` for executable implementations and `algorithms.py` for general-purpose period computation.

## 6. Discussion

### 6.1 Strength of the Formalization

Our formalization achieves several notable features:

1. **No periodicity hypothesis** for the main divisibility theorem: the Mathlib convention that `minimalPeriod = 0` for aperiodic points makes the statement `minimalPeriod(g, h(x)) | minimalPeriod(f, x)` universally valid.

2. **Clean API design**: The theorems are stated in the `Function.Semiconj` namespace, extending Mathlib's existing API naturally.

3. **Minimal axiom usage**: The core theorem (`isPeriodicPt_image`) depends only on `propext`. The divisibility theorems additionally use `Classical.choice` and `Quot.sound` through Mathlib's `minimalPeriod` machinery.

### 6.2 Limitations

- We do not formalize eventual periodicity (preperiodic behavior), which requires tracking both the tail length and the cycle length.
- We do not address topological or measure-theoretic semiconjugacy (continuity, measurability conditions).
- The finite-state collision theorem is existential; a constructive version with explicit bounds requires decidable equality.

### 6.3 Comparison with Group-Theoretic Analogues

The minimal period of `x` under `f` is analogous to the order of an element in a group. The semiconjugacy theorem is analogous to the fact that group homomorphisms cannot increase element orders: if `φ : G → H` is a homomorphism, then `ord(φ(g)) | ord(g)`. Our result generalizes this from groups to arbitrary endofunctions, where no inverse or identity element is required.

## 7. Future Work

See `FUTURE_DIRECTIONS.md` for detailed research directions including:
1. Full period spectrum invariance under conjugacy
2. Eventual periodicity descent
3. Cycle counting on finite types via Artin–Mazur zeta functions
4. LCM/GCD structure of periods for commuting maps
5. Symbolic dynamics: block maps as semiconjugacies

## References

[1] M. Brin and G. Stuck, *Introduction to Dynamical Systems*, Cambridge University Press, 2002.

[2] P. Cousot and R. Cousot, "Abstract interpretation: a unified lattice model for static analysis of programs," *POPL*, 1977.

[3] R. Devaney, *An Introduction to Chaotic Dynamical Systems*, 2nd ed., Westview Press, 2003.

[4] G.A. Hedlund, "Endomorphisms and automorphisms of the shift dynamical system," *Math. Systems Theory* 3 (1969), 320–375.

[5] A. Katok and B. Hasselblatt, *Introduction to the Modern Theory of Dynamical Systems*, Cambridge University Press, 1995.

[6] D. Lind and B. Marcus, *An Introduction to Symbolic Dynamics and Coding*, Cambridge University Press, 1995.
