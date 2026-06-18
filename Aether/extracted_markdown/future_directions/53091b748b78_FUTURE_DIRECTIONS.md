# Future Directions — Hodge–Laplacian Message Passing, Third Cycle

## Synthesis

The previous cycle built the *spectral depth threshold* skeleton
(`HodgeSpectralThreshold.lean`): the combinatorial Hodge Laplacian `L = Bᵀ B`, the
message-passing layer `mpStep L α x = x − α (L x)`, the discrete Hodge theorem
`L x = 0 ↔ B x = 0`, the Dirichlet-energy identity `⟨x, L x⟩ = ‖B x‖²`, the one-layer
spectral contraction (factor `1 − α μ (2 − α λ)`), and the finite depth threshold. Those
results all live at the level of a *single trajectory's energy*.

This cycle promotes that scalar picture to the **global dynamical structure** of the
message-passing semigroup, in the new self-contained file
`HodgeMessagePassingDynamics.lean`. The pivot is the observation that `mpStep` is a
*linear* operator, not merely energy-contracting. From linearity we obtain a clean Hodge
decomposition of the *dynamics itself*: the semigroup acts as the identity on the harmonic
kernel (a homotopy/topological invariant, by the discrete Hodge theorem) and as a uniform
geometric contraction on its complement. The conceptual payoff is that **oversmoothing is
not a defect to be patched but the exact statement of a discrete Hodge decomposition for
the message-passing semigroup** — the operator's fixed set is the cohomology group and its
complement is uniformly contracted.

## Results Summary

`HodgeMessagePassingDynamics.lean` contains eight theorems, all proven `sorry`-free and
depending only on `propext`, `Classical.choice`, `Quot.sound`. The file is self-contained
(`import Mathlib` only), re-stating the catalog facts it builds on
(`mpStep`, `mpStep_iterate_fixes_harmonic`, `quadform_iterate_bound`,
`spectral_depth_threshold`) and then proving the genuinely new results:

* **Linearity of one layer** — `mpStep_add`, `mpStep_smul`, `mpStep_sub`.
* **Linearity of the depth-`k` iterate** — `mpStep_iterate_add`, `mpStep_iterate_sub`.
* **The Hodge decomposition flow** — `hodge_decomposition_dynamics`: with `h` harmonic,
  `(mpStep)^[k] (h + r) = h + (mpStep)^[k] r`; the harmonic part is transported as a frozen
  constant while the residual evolves on its own.
* **Oversmoothing as convergence to the harmonic projection** — `oversmoothing_limit`:
  under a residual contraction `ρ < 1`, every input is driven within `ε` of its harmonic
  (cohomological) component in finitely many layers.
* **Trajectory stability** — `trajectory_stability`: two inputs have trajectories whose
  energy gap decays as `ρ^k`; the dynamics is a contraction *modulo* the harmonic kernel.

## Research Directions

### 1. A quantitative, depth-explicit oversmoothing rate

`oversmoothing_limit` is currently an `∃ N` statement; it hides the dependence of `N` on
`ε`, `ρ`, and the residual energy `r ⬝ᵥ r`. The next step is to prove the *explicit*
threshold `N(ε) = ⌈log(ε / (r ⬝ᵥ r)) / log ρ⌉` makes the residual energy `≤ ε`, turning
the limit into a closed-form depth budget. **The key insight is** that
`quadform_iterate_bound` already gives the residual energy as exactly `ρ^k (r ⬝ᵥ r)`, so
the only missing piece is a clean `Nat.ceil`/`Real.log` inversion lemma — no new dynamics.
**Why now?** With the decomposition flow proven, the residual is literally `(mpStep)^[k] r`,
so the explicit rate is a one-variable real-analysis exercise rather than a statement about
the network; this is the sharpening any downstream "depth-vs-accuracy" theorem needs.

### 2. The two-sided spectral sandwich: a lower bound forbidding *over*-contraction

We bound the residual energy from above. A complementary, falsifiable claim is a *lower*
bound: with a spectral gap `μ (x ⬝ᵥ x) ≤ ⟨x, L x⟩` and admissible step, a single layer
cannot contract faster than `(1 − α λ)²`, i.e. `(1 − α λ)² (x ⬝ᵥ x) ≤ mpStep x ⬝ᵥ mpStep x`
on the energy-carrying complement. **The key insight is** that the same energy expansion
`quadform_mpStep` (catalog) that yields the upper contraction, read with the reverse
operator inequality, yields the lower one — the two bounds are the two sides of one
quadratic. **Why now?** Establishing both bounds pins the per-layer factor inside an
interval and is the precise hypothesis under which "the harmonic component is the *only*
survivor" becomes an iff rather than an implication, closing the characterization of the
limit set.

### 3. Heat-semigroup consistency: `mpStep` as an Euler step of the Hodge heat flow

Message passing `x ↦ x − α (L x)` is the explicit Euler discretization of the Hodge heat
equation `ẋ = −L x`, whose exact flow is `e^{−tL}`. Conjecture: for fixed `t = k α` and
`α → 0` (equivalently `k → ∞`), `(mpStep L α)^[k] x → e^{−tL} x`, and both share the same
fixed set (the harmonic kernel) and the same projection limit as `t → ∞`. **The key
insight is** that `hodge_decomposition_dynamics` already proves the discrete flow respects
the Hodge splitting *exactly at every step*, which is precisely the invariant the
continuous semigroup preserves — so the limit is a convergence-of-Euler argument on the
contracting complement only. **Why now?** Mathlib has the matrix exponential and its basic
semigroup laws; bridging the discrete catalog operator to `Matrix.exp (−t • L)` connects
this thread to the analytic PDE/semigroup machinery and makes the "oversmoothing = heat
death" slogan a theorem.

### 4. Residual connections provably defeat oversmoothing

Add a skip connection: `mpStepRes L α β x = (1 + β) x − α (L x)`. Conjecture: there is a
regime of `β > 0` in which the energy-carrying complement is *non-contracting* (per-layer
factor `≥ 1`) while the harmonic part is still preserved, so deep residual networks do
**not** collapse to the harmonic projection. **The key insight is** that the same energy
expansion that gave the contraction factor `1 − α μ (2 − α λ)` gives, for the residual
layer, a factor that crosses `1` exactly when `β` exceeds an explicit spectral-gap
threshold — a sign-flip in one `nlinarith`-provable inequality. **Why now?** This is the
cleanest formal explanation of why residual/initial-connection GNNs avoid oversmoothing,
and it reuses the entire existing energy-expansion toolchain verbatim; the only new object
is the one-parameter family of layers, to which `mpStep_add`/`mpStep_smul` immediately
generalize.

### 5. From the up-Laplacian to the full Hodge Laplacian and Betti-rank invariance

The catalog already has `HodgeThreeWayDecomposition.lean` (full `L = d*d + e e*`) and the
Hodge–Betti machinery (kernel dimension = Betti number). Conjecture: the decomposition flow
and oversmoothing limit lift *verbatim* to the full Hodge Laplacian, and the dimension of
the limit set equals the `k`-th Betti number — so the asymptotic output of a deep
simplicial network is a representation of the cohomology group `Hᵏ`, a topological
invariant. **The key insight is** that all four new dynamical theorems used only
`L *ᵥ h = 0` and a scalar contraction, never the *up*-specific structure `L = Bᵀ B`;
replacing `L` by the full symmetric PSD Hodge Laplacian changes nothing in the proofs but
changes the kernel's meaning from "harmonic up-cochains" to "genuine harmonic
representatives of `Hᵏ`". **Why now?** This is the cross-domain capstone: it fuses the
oversmoothing program with the topological Betti-rank results already in the catalog,
yielding the statement "deep Hodge message passing computes cohomology."
