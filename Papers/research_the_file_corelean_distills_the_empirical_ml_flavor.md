# Universal Scaling of Minimal PDE-Solver Size at a Spectral Phase Transition

## Abstract

We give a complete, elementary, and fully rigorous account of how the minimal
size of an iterative (or polynomial-depth) linear solver diverges as the spectral
gap of the underlying operator closes at a phase transition. The central object is
the **minimal iteration count** `Nmin ρ ε`, defined as the least natural number
`n` for which a contraction of factor `ρ` drives the error below tolerance `ε`,
i.e. `ρ^n ≤ ε`. Writing the contraction in terms of the spectral gap as
`ρ = 1 − g`, our headline result is a two-sided power law,
`(1 − ε)/g ≤ Nmin(1 − g, ε) ≤ log(1/ε)/g + 1`, which pins the divergence to the
universal rate `g⁻¹` with an `ε`-dependent prefactor band `[1 − ε, log(1/ε)]`. The
lower bound follows from Bernoulli's inequality (`1 − ng ≤ (1 − g)^n`) and the
upper bound from the exponential bound (`1 − g ≤ e^{−g}`); this clean separation
drives every corollary. Square-root acceleration (`g ↦ √g`, the Chebyshev /
conjugate-gradient regime) halves the exponent to `1/2`. Composing with a
gap-closing law `g = D^α` in a physical control parameter `D = |λ − λc|` yields
critical exponents `ν = α` (unaccelerated) and `ν = α/2` (accelerated), and we
prove `α/2 < α`. Finally, replacing `g` by `c·D^α` for any discretization constant
`c ∈ (0, 1]` leaves the exponent invariant — a renormalization-style universality
statement. A computable rational analogue confirms the law numerically: shrinking
the gap tenfold (`ρ = 0.9 → 0.99`) grows the count from 44 to 459. All results are
established with no unproved assumptions beyond the standard foundational axioms.

**Keywords.** spectral gap, iterative solvers, Neumann series, critical exponent,
universality, Chebyshev acceleration, neural operators, phase transition,
renormalization.

---

## 1. Introduction

### 1.1 Motivation

A vast fraction of scientific computation reduces to solving a linear system
`A x = b`, where `A` is a discretization of a differential or integral operator.
When `A` is close to the identity — after suitable preconditioning or scaling — the
canonical solver is the **Neumann series**
`A^{-1} = \sum_{k\ge 0} (I - A)^k`, truncated after enough terms. Each term shrinks
the residual by the spectral radius `ρ = ‖I - A‖`, the *contraction factor*, so the
number of terms needed to reach a target accuracy is the fundamental cost.

The same count governs more modern architectures. A truncated Neumann series of `n`
terms is a degree-`n` polynomial in the operator; realizing such a polynomial
requires depth (or width) proportional to `n`. Thus `n` is simultaneously the
classical iteration count *and* the minimal expressive size of a learned
"neural-operator" surrogate. The empirical machine-learning observation that
neural-operator size diverges as a power law near an operator-spectrum phase
transition is, at its core, a statement about this count.

### 1.2 The phenomenon

Physical systems undergo **phase transitions** as a control parameter `λ` crosses a
critical value `λc`. A universal signature of criticality is the **closing of the
spectral gap** `g` of the relevant operator, typically as a power of the distance to
criticality:
`g = D^α`, `D = |λ - λc|`, `α > 0`.
Since `ρ = 1 - g \to 1` as `g \to 0`, the solver slows catastrophically. The
quantitative question is the *rate* of divergence of the minimal solver size, and
its *universality* across discretizations and acceleration schemes.

### 1.3 Contributions

We isolate the scalar essence of the problem and prove:

1. A two-sided power law (the **sandwich**) trapping `Nmin(1 - g, ε)` between
   `(1 - ε)/g` and `log(1/ε)/g + 1`, establishing the universal rate `g⁻¹`.
2. An **accelerated sandwich** with `g ↦ √g`, halving the exponent to `1/2`.
3. **Critical-exponent transfer**: composing with `g = D^α` gives divergence
   `D^{-α}` (unaccelerated) and `D^{-α/2}` (accelerated).
4. **Class separation**: `α/2 < α`, so the two universality classes are distinct.
5. **Discretization independence**: for `g = c·D^α` with any `c ∈ (0, 1]`, the
   exponent equals `α` for every `c`.
6. A **computable rational model** numerically confirming the `g⁻¹` law.

The proofs rest on two textbook inequalities, and the modularity of that argument is
itself a contribution: every physical and algorithmic refinement enters as a change
of the scalar *effective gap*, not as a new analytic difficulty.

---

## 2. Definitions

Throughout, `ρ ∈ (0, 1)` is a contraction factor, `g ∈ (0, 1)` a spectral gap with
`ρ = 1 - g`, and `ε ∈ (0, 1)` a target tolerance.

**Definition 2.1 (Minimal iteration count).**
For `ρ ∈ (0, 1)` and `ε ∈ (0, 1)`,
```
Nmin ρ ε  :=  the least n ∈ ℕ such that ρ^n ≤ ε.
```
The set `{ n : ρ^n ≤ ε }` is nonempty because `ρ^n → 0`, so the least element
exists. Equivalently `Nmin ρ ε = ⌈ log ε / log ρ ⌉` whenever the ceiling is taken
of a non-integer, with the standard convention at integer points; we use the
order-theoretic definition to avoid floor/ceiling edge cases.

**Definition 2.2 (Effective gap and contraction).**
A *contraction model* is a map `g ↦ ρ(g)` from gaps to contraction factors. The two
models we study are:
- the **plain model** `ρ(g) = 1 - g`;
- the **accelerated model** `ρ(g) = 1 - √g` (Chebyshev / conjugate-gradient).

**Definition 2.3 (Gap-closing law).**
Given a control parameter `λ` with critical value `λc`, set `D = |λ - λc|`. A
*gap-closing law* of exponent `α > 0` and discretization constant `c ∈ (0, 1]` is
`g(D) = c·D^α`. The *bare* law is `c = 1`.

**Definition 2.4 (Critical exponent).**
A nonnegative function `f(D)` has *critical exponent* `ν` if there exist constants
`0 < a ≤ b < ∞` and a neighborhood `(0, D_0)` on which
`a·D^{-ν} ≤ f(D) ≤ b·D^{-ν}`. We then write `f(D) ≍ D^{-ν}`.

**Definition 2.5 (Computable rational analogue).**
`NminQ : ℚ → ℚ → ℕ` is `Nmin` evaluated with exact rational arithmetic: the least
`n` with `ρ^n ≤ ε` for `ρ, ε ∈ ℚ ∩ (0,1)`. It agrees with `Nmin` on rational inputs
and is fully evaluable.

---

## 3. The fundamental sandwich

### 3.1 The two elementary inequalities

**Lemma 3.1 (Bernoulli).** For `g ∈ [0, 1]` and `n ∈ ℕ`,
`1 - n·g ≤ (1 - g)^n`.

*Proof sketch.* Induction on `n`. The base case is equality. For the step,
`(1-g)^{n+1} = (1-g)^n (1-g) ≥ (1 - ng)(1 - g) = 1 - (n+1)g + n g^2 ≥ 1 - (n+1)g`,
using `(1-g) ≥ 0` and `n g^2 ≥ 0`. ∎

**Lemma 3.2 (Exponential bound).** For `g ∈ ℝ`, `1 - g ≤ e^{-g}`; consequently for
`g ∈ (0, 1)`, `(1 - g)^n ≤ e^{-n g}`.

*Proof sketch.* The function `h(g) = e^{-g} - (1 - g)` satisfies `h(0) = 0` and
`h'(g) = 1 - e^{-g}`, which has the sign of `g`; hence `h ≥ 0` everywhere. Raising
the nonnegative base inequality to the `n`-th power gives the second claim. ∎

These two lemmas are the *only* analytic inputs. Everything below is bookkeeping
around them.

### 3.2 Lower bound: divergence is forced

**Proposition 3.3 (Lower bound).** For `g, ε ∈ (0, 1)`,
`Nmin(1 - g, ε) ≥ (1 - ε)/g`.

*Proof sketch.* Let `n = Nmin(1-g, ε)`. By definition `(1-g)^n ≤ ε`. By Bernoulli
(Lemma 3.1), `1 - n g ≤ (1-g)^n ≤ ε`, hence `1 - ε ≤ n g`, i.e. `n ≥ (1-ε)/g`. ∎

The mechanism is transparent: the error cannot drop faster than the straight line
`1 - n g`, so reaching `ε` costs at least `(1-ε)/g` steps. This is what *forces* the
`g⁻¹` divergence — no scheme using the plain contraction can do better.

### 3.3 Upper bound: divergence is controlled

**Proposition 3.4 (Upper bound).** For `g, ε ∈ (0, 1)`,
`Nmin(1 - g, ε) ≤ log(1/ε)/g + 1`.

*Proof sketch.* Choose any integer `n ≥ log(1/ε)/g`. Then `n g ≥ log(1/ε)`, so by
the exponential bound (Lemma 3.2), `(1-g)^n ≤ e^{-n g} ≤ e^{-log(1/ε)} = ε`. Thus
some `n ≤ ⌈log(1/ε)/g⌉ ≤ log(1/ε)/g + 1` already satisfies the defining inequality,
and `Nmin` — the *least* such `n` — is no larger. ∎

### 3.4 The headline theorem

**Theorem 3.5 (`Nmin_sandwich`).** For `g, ε ∈ (0, 1)`,
```
(1 - ε)/g  ≤  Nmin(1 - g, ε)  ≤  log(1/ε)/g + 1.
```

*Proof.* Combine Propositions 3.3 and 3.4. ∎

**Corollary 3.6 (Universal rate).** With `ε` fixed, `Nmin(1 - g, ε) ≍ g^{-1}` as
`g \to 0^+`; the critical exponent in the gap is exactly `1`, and the prefactor lies
in the band `[1 - ε, log(1/ε)]`.

---

## 4. Acceleration halves the exponent

Polynomial acceleration of a self-adjoint, positive-definite system replaces the
plain contraction `1 - g` by the Chebyshev-optimal contraction whose leading
behavior is `1 - √g` (the well-known `\sqrt{\kappa}` speedup of conjugate
gradients, with `κ` the condition number `≈ 1/g`).

**Theorem 4.1 (`Nmin_sandwich_accelerated`).** For `g, ε ∈ (0, 1)`,
```
(1 - ε)/√g  ≤  Nmin(1 - √g, ε)  ≤  log(1/ε)/√g + 1.
```

*Proof sketch.* The accelerated contraction is `1 - g'` with effective gap
`g' = √g ∈ (0, 1)`. Apply Theorem 3.5 verbatim with `g'` in place of `g`. ∎

**Corollary 4.2 (Halved exponent).** With `ε` fixed,
`Nmin(1 - √g, ε) ≍ g^{-1/2}`; the gap-exponent is `1/2`, exactly half the
unaccelerated value.

This is the entire content of the `\sqrt{}`-speedup, recovered as a one-line
substitution: acceleration is a *change of effective gap*, and the sandwich is
indifferent to which gap it is fed.

---

## 5. Critical-exponent transfer

We now feed the physical gap-closing law into the sandwich.

**Theorem 5.1 (`power_law_control`).** Let `g(D) = D^α` with `α > 0`, and fix
`ε ∈ (0, 1)`. Then for `D` small enough that `g(D) ∈ (0, 1)`,
```
(1 - ε)·D^{-α}  ≤  Nmin(1 - D^α, ε)  ≤  log(1/ε)·D^{-α} + 1,
```
so `Nmin ≍ D^{-α}`: the critical exponent is `ν = α`.

*Proof sketch.* Substitute `g = D^α` into Theorem 3.5; both walls become constant
multiples of `D^{-α}` plus a bounded remainder. ∎

**Theorem 5.2 (`power_law_control_accelerated`).** With `g(D) = D^α` and the
accelerated model,
```
(1 - ε)·D^{-α/2}  ≤  Nmin(1 - √(D^α), ε)  ≤  log(1/ε)·D^{-α/2} + 1,
```
so `Nmin ≍ D^{-α/2}`: the critical exponent is `ν = α/2`.

*Proof sketch.* `√(D^α) = D^{α/2}`; apply Theorem 4.1 with effective gap `D^{α/2}`.
∎

**Theorem 5.3 (`accelerated_exponent_lt`).** For every `α > 0`, `α/2 < α`.

*Proof.* `α/2 < α ⟺ 0 < α/2`, which holds since `α > 0`. ∎

Theorem 5.3 certifies that the accelerated and unaccelerated power laws are genuinely
*different* universality classes for every positive exponent: acceleration always
strictly reduces the divergence rate.

---

## 6. Discretization independence (renormalization)

Real discretizations perturb the gap-closing law by a constant. We show this
constant is invisible to the exponent.

**Theorem 6.1 (`power_law_discretization_independent`).** Let `c ∈ (0, 1]` and
`g(D) = c·D^α` with `α > 0`. Fix `ε ∈ (0, 1)`. Then for `D` small enough that
`g(D) ∈ (0, 1)`,
```
((1 - ε)/c)·D^{-α}  ≤  Nmin(1 - c·D^α, ε)  ≤  (log(1/ε)/c)·D^{-α} + 1.
```
In particular `Nmin ≍ D^{-α}` with the *same* exponent `ν = α` for every `c ∈ (0,1]`;
only the prefactor scales by `1/c`.

*Proof sketch.* Substitute `g = c·D^α` into Theorem 3.5. The factor `c` enters only
through `1/g = c^{-1} D^{-α}`, rescaling both walls by `1/c` while leaving the power
of `D` untouched. ∎

**Interpretation.** The critical exponent `α` is a coordinate-free invariant of the
phase transition: it survives any change of microscopic discretization constant.
This is the precise, finite-dimensional analogue of the renormalization-group claim
that critical exponents are universal while amplitudes are not.

---

## 7. The computable model and numerical validation

**Theorem 7.1 (Agreement).** For rational `ρ, ε ∈ (0, 1)`, `NminQ ρ ε = Nmin ρ ε`.

*Proof sketch.* Both are the least `n` with `ρ^n ≤ ε`; rational arithmetic decides
the inequality exactly, so the least witnesses coincide. ∎

**Numerical experiment.** Fix `ε = 1/100` and evaluate `NminQ` at two gaps differing
by a factor of ten:

| `ρ` | `g = 1 - ρ` | `NminQ ρ (1/100)` | predicted `≈ log(100)/g` |
|---|---|---|---|
| 0.9  | 0.1  | **44**  | 46.05 |
| 0.99 | 0.01 | **459** | 460.5 |

The measured ratio `459/44 ≈ 10.4` matches the predicted factor of `10` from the
`g⁻¹` law, with the residual `+4%` accounted for by the additive `+1` and ceiling
effects in the upper wall. The computed values sit just under the `log(1/ε)/g`
prediction, exactly as Theorem 3.5 requires.

---

## 8. Algorithms

### 8.1 Exact minimal count by linear scan

**Input.** Rationals `ρ, ε ∈ (0, 1)`.
**Output.** `Nmin ρ ε`.
```
n ← 0 ; p ← 1            -- p tracks ρ^n
while p > ε:
    p ← p · ρ
    n ← n + 1
return n
```
Correctness: `p = ρ^n` is the loop invariant; the loop exits at the first `n` with
`ρ^n ≤ ε`, which is `Nmin` by definition. Complexity: `O(Nmin)` multiplications,
i.e. `O(log(1/ε)/g)` arithmetic operations.

### 8.2 Closed-form predictor

**Input.** Gap `g ∈ (0,1)`, tolerance `ε ∈ (0,1)`, mode `∈ {plain, accel}`.
**Output.** The sandwich bounds and midpoint estimate.
```
g_eff ← (mode = accel) ? sqrt(g) : g
lower ← (1 - ε) / g_eff
upper ← log(1/ε) / g_eff + 1
return (lower, upper, (lower + upper)/2)
```
This evaluates the theoretical band in `O(1)` and needs no iteration; it is the
practical engineering use of Theorem 3.5 / 4.1.

---

## 9. Applications

1. **A priori cost estimation.** Given a measured or modeled gap `g`, the sandwich
   returns rigorous lower and upper bounds on solver depth before any solve is run.
2. **Acceleration budgeting.** The exponent halving (Corollary 4.2) quantifies
   exactly when Chebyshev / CG acceleration is worth its per-iteration overhead:
   the crossover is governed by `g^{-1}` vs `g^{-1/2}`.
3. **Neural-operator sizing.** Because `Nmin` is the polynomial degree a surrogate
   must express, the law gives a principled minimal-depth (or minimal-width) target
   for learned PDE solvers as a function of how close the problem sits to a spectral
   phase transition.
4. **Criticality detection.** Measuring the empirical exponent `ν` of solver-cost
   growth and comparing to `α` vs `α/2` distinguishes accelerated from
   unaccelerated regimes, and to the bare physics exponent `α` independent of mesh.

---

## 10. Discussion

The conceptual payoff is the *separation of concerns*. All physics enters through a
single scalar — the effective gap — and all numerical analysis enters through the
contraction model that maps the gap to a contraction factor. The divergence law
itself is governed by two inequalities (Bernoulli and the exponential) that never
change. Consequently:

- New acceleration schemes are new effective gaps (`§4`).
- New phase transitions are new gap-closing laws (`§5`).
- New discretizations are new constants `c` (`§6`).

Each refinement is a substitution into the same sandwich, never a new analytic
problem. This modularity is what makes the framework extensible, and it is the
reason the empirical "neural-operator size power law" reduces to elementary
inequalities.

A subtlety worth emphasizing: the lower bound is *not* a triviality. It is the part
that rules out clever schemes from beating `g⁻¹` within the plain model, and it is
powered by Bernoulli — the statement that the error decays no faster than linearly
in the number of steps near the boundary. Without it, one could only claim the
divergence is "at most" `g⁻¹`; with it, the divergence is pinned exactly.

---

## 11. Future work

**(1) Sharp prefactor.** The sandwich leaves a constant-factor slack of width
`log(1/ε)/(1-ε)`. We conjecture a sharp asymptotic
`Nmin(1-g, ε) = (log(1/ε)/g)(1 + o(1))` as `g → 0⁺` with `ε` fixed, with a pure
logarithmic next-order correction, provable from the expansion
`-1/log(1-g) = (1/g)(1 - g/2 + o(g))`.

**(2) Optimality of `1/2`.** We conjecture that among all degree-`d` polynomial
solvers of a self-adjoint operator with gap `g`, no scheme achieves exponent below
`1/2`, i.e. `Nmin ≥ c·g^{-1/2}` uniformly — a hard floor coming from the
extremality of Chebyshev polynomials for `min_p max_{x∈[g,1]} |1 - x p(x)|`.

**(3) Composed transitions.** For two simultaneous gaps `g_i = D^{α_i}` with product
contraction `(1-g_1)(1-g_2)`, we conjecture the composed exponent is
`ν = max(α_1, α_2)` (the slowest-closing gap is rate-limiting), since
`1 - (1-g_1)(1-g_2) = g_1 + g_2 - g_1 g_2 ≍ D^{min(α_1,α_2)}`.

**(4) Width–depth tradeoff.** Modeling architectures by width `W` and depth `L`, we
conjecture a conserved product `W^a L^b ≍ |λ - λc|^{-ν}`: a degree-`n` operator
polynomial realizes either as depth-`n` or width-`n` Krylov basis, so the *product*
is what the gap forces to diverge.

**(5) Exceptional points.** For an `m`-fold defective eigenvalue approaching the
spectrum edge as `D^α`, the resolvent norm scales as `g^{-m}`, giving effective
contraction `1 - g^m` and a strictly larger exponent `α·m` — a separate universality
class from the diagonalizable (`m = 1`) case.

---

## 12. Conclusion

We have reduced a power-law conjecture about minimal solver / neural-operator size
near a spectral phase transition to a clean, two-sided, machine-checkable theorem:
the size diverges as `g⁻¹` in the spectral gap, as `D^{-α}` in the physical control
parameter, with the exponent halved by polynomial acceleration and invariant under
discretization. The entire edifice rests on Bernoulli's inequality and the
exponential bound, organized so that every physical and algorithmic refinement is a
substitution of the effective gap. The result is at once a rigorous statement in
numerical analysis, a universality theorem in the spirit of statistical physics, and
a minimal-size principle for learned PDE solvers.
