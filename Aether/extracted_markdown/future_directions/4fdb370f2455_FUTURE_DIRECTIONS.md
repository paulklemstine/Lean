# Future Directions — Arithmetic Monodromy Rigidity in Definable Neural ODE Flows

## Synthesis

The original conjecture asserted that the time-1 flow map of a polynomially
parameterized neural ODE carries a *monodromy/stability invariant* that is locally
constant on connected components of parameter space, degenerates only on a
Zariski-thin discriminant, and whose jumps coincide *exactly* with changes in the
number or type of globally attracting invariant sets.

In `Computation/MonodromyRigidity.lean` we isolated and **fully proved** the hard
arithmetic-dynamical core of this picture in dimension one, where every clause of
the conjecture can be made precise and machine-checked:

* For the **linear neural-ODE layer** `x' = a·x` (the exact, single-neuron
  continuous ResNet), the time-`t` flow is `e^{at}x` (`flow_hasDerivAt` certifies it
  solves the ODE). The origin is a global attractor **iff** `a < 0`
  (`globalAttractor_iff`), and — crucially — the discrete **time-1 map** `x ↦ e^a x`
  is a strict contraction **iff** `a < 0` (`timeOne_contraction_iff`). The
  continuous-time and discrete-layer stability criteria are *literally the same
  condition*: this is the rigorous shadow of the "stratified fibration between the
  flow and its time-1 map".
* The correct finite **monodromy invariant** is the order-theoretic Hurwitz sign
  `stabIndex : ℝ → ℤ`. Its degeneracy locus (the discriminant) is the thin set `{0}`
  (`discriminant_eq`); off it the invariant is locally constant
  (`stabIndex_locallyConstant`); and parameters in the same connected component of
  `ℝ ∖ {0}` share both the invariant and the qualitative dynamics
  (`rigidity_sameComponent`).
* The capstone `jumpSet_eq_discriminant` proves the conjecture's central claim *as a
  set equality*: the locus where the global-attractor predicate fails to be locally
  constant — the qualitative-transition locus — **equals** the discriminant.
* For the **nonlinear** prototype `g_c(x) = c·x − x³`, the equilibrium (candidate
  attractor) count jumps `1 → 3` exactly at the discriminant `c = 0`
  (`equilibria_subcritical`, `equilibria_supercritical`, and the `ncard` lemmas):
  the pitchfork bifurcation realizes "change in the number of invariant sets at a
  monodromy jump".

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `flow_hasDerivAt` | `e^{at}x` solves `x' = a·x` | ✔ no sorry |
| `globalAttractor_iff` | origin is a global attractor ⇔ `a < 0` | ✔ |
| `timeOne_contraction_iff` | time-1 map is a contraction ⇔ `a < 0` | ✔ |
| `discriminant_eq` | non-hyperbolic locus is `{0}` | ✔ |
| `stabIndex_locallyConstant` | invariant locally constant off discriminant | ✔ |
| `rigidity_sameComponent` | same sign ⇒ same invariant & dynamics | ✔ |
| `jumpSet_eq_discriminant` | transition locus = discriminant | ✔ |
| `equilibria_subcritical` / `_supercritical` | attractor count `1` vs `3` | ✔ |
| `equilibria_card_subcritical` / `_supercritical` | `ncard = 1` / `ncard = 3` | ✔ |

All depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Bold, falsifiable research directions

### 1. Multidimensional Hurwitz rigidity via the matrix exponential
Replace the scalar `a` by a rational matrix `A ∈ Mₙ(ℚ)`. Conjecture: the origin of
`x' = Ax` is a global attractor **iff** every eigenvalue of `A` has negative real part
(`A` Hurwitz), **iff** the time-1 map `exp A` has spectral radius `< 1`, and the
`ℤ`-valued invariant `(#stable, #unstable, #center)` of eigenvalue real-part signs is
locally constant on the complement of the real-part discriminant
`{A : ∃ λ ∈ spec A, Re λ = 0}`, which is a proper algebraic (hence measure-zero)
subset of `Mₙ`. **The key insight is** that the scalar equivalence
`contraction ⇔ global attractor ⇔ a < 0` we proved is exactly the `n = 1` shadow of
the Lyapunov/Hurwitz spectral dichotomy, so the multidimensional statement should
follow by simultaneously triangularizing `A` and running the scalar argument on the
diagonal. **Why now?** Mathlib now has `Matrix.exp`, eigenvalue API, and Jordan/Schur
machinery, so the spectral discriminant can be defined and the thinness proved as a
genuine algebraic-geometry statement rather than left informal.

### 2. The discriminant is the zero set of a rational resultant
For the cubic family `c·x − x³` we proved the count jumps at `c = 0`; for a general
monic real cubic `x³ + px + q` the equilibrium-count change happens exactly on the
classical discriminant `Δ = −4p³ − 27q²`. Conjecture: for any polynomial neural-ODE
field with rational coefficients, the parameter discriminant of "number of real
equilibria" is precisely the vanishing locus of the polynomial discriminant
(a single rational polynomial in the parameters), and hence Zariski-thin. **The key
insight is** that "attractor count is locally constant off a thin set" is the
real-root-counting content of the polynomial discriminant, so the topological
statement is equivalent to a purely algebraic resultant computation. **Why now?**
Mathlib has `Polynomial.discriminant` and resultant theory; pairing it with the
root-counting we already did (`equilibria_*`) gives a falsifiable bridge: exhibit one
rational cubic whose real-root count changes off `Δ = 0` to refute it.

### 3. Hyperbolic conjugacy = equality of the monodromy invariant (Hartman–Grobman shadow)
Conjecture: two scalar (or linear) hyperbolic time-1 maps are topologically conjugate
**iff** they share the `stabIndex` invariant, i.e. the invariant is a *complete*
conjugacy invariant on each component. **The key insight is** that our
`rigidity_sameComponent` already shows equal sign ⇒ equal dynamics; upgrading
"equal dynamics" from a predicate to an explicit homeomorphism conjugating the two
time-1 maps would make `stabIndex` a genuine moduli coordinate. **Why now?** The
scalar conjugacy `x ↦ e^a x ~ x ↦ e^b x` for `a,b < 0` can be built by an explicit
power-law homeomorphism `x ↦ sgn(x)|x|^{b/a}`, which is fully formalizable today and
tests whether the invariant is complete (a single non-conjugate same-sign pair
refutes it).

### 4. Definable/o-minimal finiteness of the transition set
Conjecture: for *any* o-minimal (e.g. semialgebraic, or globally subanalytic) family
of scalar neural-ODE fields with a definable parameter, the qualitative-transition
locus `jumpSet` is itself definable and has empty interior (it is "thin"), and the
number of components of constant qualitative type is finite and uniformly bounded by
the complexity of the family. **The key insight is** that `jumpSet_eq_discriminant`
identified the transition set with an algebraically defined object in the polynomial
case; o-minimality is exactly the tameness hypothesis that forces this identification,
and the resulting finiteness, in the general definable case. **Why now?** This is the
clean conjecture that connects the algebraic core we proved to genuine o-minimal
dynamics; it is falsified by any definable scalar family with a transition set of
positive measure, which is the precise adversarial target to search for.

### 5. Arithmetic ↔ continuous bifurcation correspondence with `Computation.Bifurcation`
The catalog's `Computation.Bifurcation` studies bifurcation of periodic orbits under
an **arithmetic** parameter (torus size `n`), with appearance upward-closed under
divisibility. Conjecture: there is a functor matching its "period-appearance"
discriminant in `ℕ` (the divisibility lattice) with our real discriminant in `ℝ`,
under which a continuous family `x' = f_c(x)` reduced mod arithmetic data realizes
the same monotone "spectrum-of-attractors" jumps. **The key insight is** that both
settings already prove *monotone, thin* appearance of new invariant sets across a
parameter — divisibility-monotone there, sign-monotone here — so a single
order-theoretic "appearance lattice" should unify continuous and arithmetic
bifurcation. **Why now?** Both halves now exist as formal Lean objects in this
repository, so the bridge can be stated and either built or refuted by a concrete
mismatch between the two appearance lattices.
