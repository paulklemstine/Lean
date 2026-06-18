# Future Directions — Inverse Stereographic Renormalization Group

## Synthesis

This cycle made the slogan *"the renormalization group is inverse stereographic projection"*
into a theorem on the one exactly-solvable case where every step is unambiguous: the **1D
Ising chain under decimation**. Working in the bond variable `u = tanh K`, decimation is the
quadratic map `u ↦ u²` (`isingRG`). We characterized its fixed points (`isingRG_fixed_iff`:
exactly `{0, 1}`), showed those are precisely the zeros of the discrete beta function
`β(u) = u² − u` (`isingBeta_zero_iff`), and computed the linearized RG eigenvalues
(`isingRG_deriv`: `R'(u) = 2u`, hence `0` at the disordered fixed point, `2` at the ordered
one). The eigenvalue comparison `|R'(0)| < 1 < |R'(1)|` is the entire mechanism behind the
main theorem `isingRG_no_phase_transition`: every finite-temperature coupling (`|u| < 1`)
flows to the disordered fixed point, so the 1D Ising model orders only at `T = 0`.

The structural insight is geometric. `ising_coupling_eq_stereo` proves that `u = tanh K` is
*literally* the first coordinate of inverse stereographic projection evaluated at the
half-angle variable `t = tanh(K/2)` — i.e. the stereographic chart `t ↦ 2t/(1+t²)` is the
change of variables (half-angle ↦ bond strength). RG flow on couplings is therefore motion
on the stereographic circle, not a metaphor for it. The companion identity
`stereo_angle_deriv` computes the stereographic conformal factor `2/(1+t²)` as the derivative
of the angle map `t ↦ 2·arctan t`; this is the precise object the original conjecture wants
to equate with the beta function.

What did *not* close: the headline conjecture "`β(g)` equals the derivative of the
stereographic projection map at the critical coupling `g*`" is, in 1D, *almost* a tautology
(both vanish/are governed by the same `1+t²` denominator) but is not yet a clean dimensionless
equality because the beta function and the conformal factor live on different charts
(coupling vs. half-angle). Reconciling the two charts — and finding the dimension `d ≥ 2`
where an *interior* repulsive fixed point appears — is the live frontier, recorded as
`higherDim_phase_transition_conjecture` (left as `sorry`).

## Results Summary

- `invStereo_on_circle`: proved — inverse stereographic projection lands on `S¹`; the geometric phase space of the flow (re-derives catalog `inv_stereo_on_circle`).
- `isingRG_fixed_iff`: proved — the decimation map `u ↦ u²` has exactly the fixed points `{0, 1}` (disordered / ordered).
- `isingBeta_zero_iff`: proved — the discrete beta function vanishes exactly at the RG fixed points, rigorously linking "beta zero" to "fixed point".
- `isingRG_deriv`: proved — linearized RG eigenvalue `R'(u) = 2u`.
- `isingRG_deriv_disordered` / `isingRG_deriv_ordered`: proved — eigenvalue `0` (attractive) at `u=0`, `2` (repulsive) at `u=1`.
- `isingRG_iterate`: proved — the `n`-fold decimation iterate is `u ↦ u^(2ⁿ)`.
- `isingRG_no_phase_transition`: **proved (main result)** — every subcritical coupling flows to the disordered fixed point; the 1D Ising model has no finite-temperature phase transition.
- `ising_coupling_eq_stereo`: **proved (bridge)** — the bond variable `tanh K` is the first coordinate of inverse stereographic projection at the half-angle `tanh(K/2)`.
- `stereo_angle_deriv`: proved — the stereographic conformal factor `2/(1+t²)` is the derivative of the angle map, the candidate geometric beta function.
- `inverse_stereo_rg_rosetta`: proved — the dynamical, beta-function, and eigenvalue pictures of the disordered fixed point agree.
- `higherDim_phase_transition_conjecture`: conjecture (`sorry`) — an interior repulsive fixed point with eigenvalue `> 1` produces two nonempty basins, the signature of a phase transition absent in `d = 1`.

## Research Directions

### Direction 1: Reconcile the two charts to make "β = stereographic derivative" an exact identity
**Hypothesis**: There is an explicit reparametrization `Φ` from the coupling chart (`u = tanh K`)
to the half-angle chart (`t = tanh(K/2)`) under which the 1D discrete beta function `β(u) = u² − u`
pushes forward to a scalar multiple of the stereographic conformal factor `2/(1+t²)` evaluated at
the corresponding `t`, with the proportionality fixed by the eigenvalue `R'(1) = 2`.
**Test**: Compute `(β ∘ stereo) ` and `deriv (fun t => 2*t/(1+t²))` symbolically and prove they are
equal up to the explicit Jacobian of `Φ`; a single Lean `field_simp; ring` after the right change
of variables should decide it (or refute the exact-equality claim).
**Why now**: `ising_coupling_eq_stereo` already supplies the exact map between the two charts, and
`stereo_angle_deriv` already supplies the conformal factor in closed form — both as proved Lean lemmas.
**If true**: the central conjecture becomes a theorem in 1D and gives the precise dictionary
"RG eigenvalue ↔ conformal weight".
**If false**: it pinpoints the obstruction (a genuine Jacobian mismatch), telling us the
beta/conformal-factor identity is only asymptotic near the fixed point, not exact.

### Direction 2: Iterated stereographic projection with a *moving pole* as a literal RG step
**Hypothesis**: Conjugating the squaring map `u ↦ u²` by stereographic projection yields a Möbius
(or post-Möbius) map on `S¹` whose pole position encodes the decimation block size, so that an
`m`-fold block-spin transformation is `m` stereographic projections with shifting poles.
**Test**: Define `stereoConj := stereo ∘ isingRG ∘ stereo⁻¹` on the circle, prove it is well-defined
away from the poles, and identify its fixed points with the catalog SL(2)/Möbius results
(`mobius_det_condition`, `mobius_compose_det` in `InverseStereoResearch.lean`).
**Why now**: the catalog already contains the full SL(2) Möbius group law; this cycle supplies the
exact stereographic conjugation map needed to land the RG step inside that group.
**If true**: RG flow becomes a discrete subgroup orbit on `S¹`, connecting renormalization to
modular dynamics (`modular_ST_product`).
**If false**: the squaring map is genuinely non-Möbius, quantifying how far RG is from conformal.

### Direction 3: Discharge `higherDim_phase_transition_conjecture` for a concrete `d = 2` toy map
**Hypothesis**: The Migdal–Kadanoff recursion in `d = 2`, written as an explicit rational map `R`
on `u ∈ [0,1]`, has an interior fixed point `u* ∈ (0,1)` with `R'(u*) > 1`, and the two basins are
nonempty — a provable finite-temperature transition.
**Test**: Pick the explicit `d=2` bond-moving map, locate `u*` numerically, then prove in Lean that
`R u* = u*`, `deriv R u* > 1`, and exhibit one subcritical and one supercritical seed with the
required flow, closing the `sorry`.
**Why now**: the abstract statement and the `1D` baseline (eigenvalue `< 1` everywhere interior) are
already formalized; only the explicit `d=2` map and a monotone-convergence argument are missing.
**If true**: we get the first Lean-verified RG-derived phase transition and a sharp contrast with 1D.
**If false** (no interior repulsive fixed point in the chosen approximation): it exposes the known
limitation of Migdal–Kadanoff and motivates a better real-space scheme.

### Direction 4: Continuous-time beta function as the vector field generating the discrete flow
**Hypothesis**: There is a smooth vector field `b : ℝ → ℝ` whose time-`(ln 2)` flow equals the
decimation map `u ↦ u²` on `(0,1)`, and `b` vanishes to the predicted orders at `u = 0, 1`
(matching the eigenvalues `0` and `2`).
**Test**: Solve `b(u) = ln 2 · u² · (something)` from the functional/Schröder equation
`b(R(u)) = R'(u) b(u)` and verify in Lean that this `b` reproduces `isingRG_deriv` linearizations
at both fixed points.
**Why now**: `isingRG_iterate` gives the exact closed form `u^(2ⁿ)` of the discrete orbit, which is
exactly the data Schröder's equation needs to interpolate to continuous time.
**If true**: it upgrades the discrete RG to an honest ODE beta function, the form physicists use.
**If false**: it shows the decimation flow is not smoothly embeddable, a real obstruction to a
continuous RG in this scheme.

### Direction 5: Stereographic phase space for the quantum / Bloch-sphere RG
**Hypothesis**: The catalog Bloch-sphere parametrization (`bloch_stereo_norm`) and the Ising bond
variable share the same stereographic chart, so a single-qubit decoherence channel acting as
`u ↦ u²` on the Bloch `z`-coordinate has the *same* no-transition flow theorem as 1D Ising.
**Test**: Define the channel on the Bloch sphere, prove its `z`-coordinate obeys `isingRG`, and
transport `isingRG_no_phase_transition` verbatim to conclude monotone decoherence to the maximally
mixed state.
**Why now**: this cycle proved the bond variable lives on the exact stereographic circle that
`bloch_stereo_norm` already uses, so the two domains are now provably the same geometry.
**If true**: one theorem covers both statistical-mechanics RG and qubit decoherence — a genuine
cross-domain bridge (Physics ∩ Geometry ∩ MachineLearning catalog domains).
**If false**: the quantum channel's nonlinearity differs from squaring, isolating where the classical
analogy breaks for open quantum systems.
