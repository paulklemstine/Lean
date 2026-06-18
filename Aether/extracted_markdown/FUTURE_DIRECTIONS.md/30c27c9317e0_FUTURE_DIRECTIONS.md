# Future Directions: Semiconjugacy Transfer Calculus

## Overview

The theorems `semiconj_iterate_eq`, `semiconj_eventually_periodic`, and `semiconj_eventually_periodic_of_fintype` establish the foundational infrastructure for transporting orbit structure through deterministic maps between dynamical systems. This document outlines five concrete next steps at breakthrough level, each building on the catalog of existing results.

---

## 1. Minimal Period Divisibility Under Factor Maps

### Proposed Theorem Statement

```lean
theorem semiconj_minimalPeriod_dvd
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    {x : α} (hx : Function.IsPeriodicPt f n x) :
    Function.minimalPeriod g (h x) ∣ Function.minimalPeriod f x
```

### Why It Matters

The current `isPeriodicPt_image` theorem tells us that if `x` is periodic with period `n`, then `h x` is periodic with period `n`. But it says nothing about the *minimal* period. In symbolic dynamics and automata theory, the minimal period is the fundamental invariant — it determines the cycle structure of the observed system. This theorem would show that the minimal period can only *decrease* (by divisibility) under semiconjugacy, never increase. This is the formal content of the intuition that "observation can only lose information, not create it."

### Proof Strategy

Use the fact that `minimalPeriod g (h x)` divides any period of `g` at `h x`. Since `minimalPeriod f x` is a period of `f` at `x`, by `isPeriodicPt_image` it is also a period of `g` at `h x`. Hence `minimalPeriod g (h x) ∣ minimalPeriod f x`.

### Builds On

- `Function.Semiconj.isPeriodicPt_image` (this work)
- `Function.IsPeriodicPt.minimalPeriod_dvd` (Mathlib)

---

## 2. Finite-State Abstraction: Lasso Witness Transfer

### Proposed Theorem Statement

```lean
/-- Every execution of a semiconjugate system whose source is finite
    has a lasso-shaped witness: a pre-period and a period. -/
theorem semiconj_lasso_witness
    {α β : Type*} [Fintype α] [DecidableEq α]
    {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) (x : α) :
    ∃ (m p : ℕ), 0 < p ∧
      (∀ k, g^[m + p + k] (h x) = g^[m + k] (h x))
```

### Why It Matters

In model checking and temporal logic verification, lasso-shaped executions (a finite prefix followed by an infinite loop) are the canonical witness form for LTL/CTL* properties. This theorem would say: every abstraction of a finite-state system produces lasso-shaped observed traces. This is the formal bridge from finite-state model checking to abstract interpretation — any deterministic abstraction of a verified finite-state system automatically inherits the lasso structure required for temporal verification.

### Proof Strategy

From `semiconj_eventually_periodic_of_fintype`, obtain `m, n` with `g^[m+n] (h x) = g^[m] (h x)`. Then prove by induction on `k` that `g^[m+n+k] (h x) = g^[m+k] (h x)`, using the periodicity and the iterate structure.

### Builds On

- `semiconj_eventually_periodic_of_fintype` (this work)
- Standard iterate arithmetic in Mathlib

---

## 3. Symbolic Dynamics: Ultimately Periodic Words Under Morphisms

### Proposed Theorem Statement

```lean
/-- A deterministic morphism on sequences preserves ultimate periodicity.
    If a sequence s is ultimately periodic (s(i+p) = s(i) for all i ≥ m)
    and φ is a 1-block map, then φ ∘ s is ultimately periodic. -/
theorem morphic_image_ultimately_periodic
    {Σ₁ Σ₂ : Type*} {φ : Σ₁ → Σ₂}
    {s : ℕ → Σ₁} {m p : ℕ} (hp : 0 < p)
    (hup : ∀ i, m ≤ i → s (i + p) = s i) :
    ∀ i, m ≤ i → (φ ∘ s) (i + p) = (φ ∘ s) i
```

### Why It Matters

Ultimately periodic sequences (equivalently, eventually periodic orbits of the shift map) are the combinatorial counterpart of regular languages in formal language theory. This theorem — that deterministic letter-to-letter morphisms preserve ultimate periodicity — is a special case of the semiconjugacy transfer principle applied to the shift dynamical system. It connects our orbit-transfer infrastructure to the theory of automatic sequences, morphic words, and Büchi automata. In cryptographic stream cipher analysis, this gives: if the internal state sequence is ultimately periodic (as it must be in any finite-state generator), then every deterministic output function produces an ultimately periodic keystream.

### Proof Strategy

The shift map σ on ℕ → Σ sends s to s(· + 1). A 1-block map φ defines a semiconjugacy from (ℕ → Σ₁, σ) to (ℕ → Σ₂, σ) via postcomposition. The result follows immediately from `semiconj_iterate_eq` applied to the shift system — but the direct proof by `congrArg φ (hup i hi)` is even simpler. The value is in explicitly connecting the symbolic dynamics viewpoint to the semiconjugacy framework.

### Builds On

- `semiconj_iterate_eq` (this work)
- Shift map formalization (to be developed)

---

## 4. Conjugacy Preserves Minimal Period Exactly

### Proposed Theorem Statement

```lean
/-- If h is a bijective semiconjugacy (i.e., a conjugacy), then
    the minimal period is preserved exactly. -/
theorem conj_minimalPeriod_eq
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g)
    (hbij : Function.Bijective h)
    (x : α) :
    Function.minimalPeriod g (h x) = Function.minimalPeriod f x
```

### Why It Matters

While semiconjugacy can only decrease the minimal period (Direction 1), full conjugacy — a bijective semiconjugacy — must preserve it exactly. This is the formal content of "topologically conjugate systems have identical orbit structure." In cryptography, this means that any invertible encoding of a finite-state system preserves cycle lengths exactly, which has direct implications for the period analysis of stream ciphers under invertible state transformations.

### Proof Strategy

Use Direction 1 in both directions: `h` semiconjugates `f` to `g`, so `minimalPeriod g (h x) ∣ minimalPeriod f x`. The inverse `h⁻¹` semiconjugates `g` to `f` (using bijectivity), so `minimalPeriod f x ∣ minimalPeriod g (h x)`. Divisibility in both directions gives equality.

### Builds On

- `semiconj_minimalPeriod_dvd` (Direction 1)
- `Function.Semiconj` inverse construction from bijectivity

---

## 5. Orbit Counting Under Semiconjugacy of Finite Systems

### Proposed Theorem Statement

```lean
/-- For finite systems, the number of periodic orbits of the target system
    (restricted to the image of h) is at most the number of periodic orbits
    of the source system. -/
theorem semiconj_periodic_orbit_count_le
    {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) :
    (Finset.univ.filter (fun y => ∃ x, h x = y ∧
      Function.minimalPeriod g y = Function.minimalPeriod f x)).card ≤
    Fintype.card α
```

### Why It Matters

This connects the semiconjugacy transfer calculus to finite combinatorics: how many distinct periodic orbits can the observed system have? In cryptographic applications, this bounds the number of distinct keystream cycles that a finite-state generator can produce. In formal verification, it bounds the number of distinct lasso classes in an abstracted system.

### Proof Strategy

Each periodic orbit of `g` in the image of `h` is the image of at least one periodic orbit of `f`. The counting follows from the surjectivity of the orbit map restricted to periodic points.

### Builds On

- `semiconj_minimalPeriod_dvd` (Direction 1)
- `semiconj_eventually_periodic_of_fintype` (this work)
- Finset counting lemmas in Mathlib

---

## Cross-Cutting Theme

All five directions share a common architecture: they take the raw orbit-collision transfer principle (`semiconj_iterate_eq`) and specialize it to increasingly refined invariants — minimal period, lasso shape, word periodicity, exact conjugacy, orbit counting. Together they form a **transfer calculus** that allows any certified recurrence theorem on a source system to be systematically pushed forward to every semiconjugate observation of that system.

The long-term vision is that this calculus becomes standard infrastructure in the Mathlib dynamics library, so that future theorems about finite dynamical systems, symbolic dynamics, and cryptographic state machines automatically inherit orbit-transport properties without re-proof.
