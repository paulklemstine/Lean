# Computational Evidence — 2D Enstrophy Control vs. 3D Stretching

The theorems proved this cycle are *abstract structural identities* (a derivative
computation + a sign argument), so the decisive evidence is small concrete
instances confirming (i) the structural axioms are jointly satisfiable, and
(ii) the dissipation conclusions hold on genuine trajectories. These are encoded
directly in Lean (`Examples.lean`), so the "evidence" below is machine-checked,
not ad hoc.

## 1. Concrete inhabiting model and solution (verified in `Examples.lean`)

Model on `V = ℝ`: `ν = 1`, `A = id`, `B = 0`.
- All five structural axioms (`hA`, `hB`, `hA_symm`, `hB2`) discharged by `simp`.
- Solution `u(t) = e^{−t}` solves `u'(t) = −u(t)` (chain rule), verified.
- Enstrophy `Ω(t) = ⟪A u, u⟫ = (e^{−t})² = e^{−2t}` is strictly decreasing.

| t   | u(t)=e^{−t} | Ω(t)=e^{−2t} | Ω decreasing? |
|-----|-------------|--------------|---------------|
| 0.0 | 1.000       | 1.000        | —             |
| 0.5 | 0.6065      | 0.3679       | yes           |
| 1.0 | 0.3679      | 0.1353       | yes           |
| 2.0 | 0.1353      | 0.0183       | yes           |

This confirms `trivialModel2D_enstrophy_bound` is non-vacuous: a non-constant
trajectory with strictly dissipated enstrophy.

## 2. The 2D vs 3D dichotomy, scalarized

The general enstrophy identity is `Ω'(t) = −2ν‖A u‖² − 2⟨B(u,u), A u⟩`.
Writing `S = ⟨B(u,u), A u⟩` (the stretching pairing) and `D = ν‖A u‖² ≥ 0`:

- **2D** (`hB2`): `S = 0` ⇒ `Ω' = −2D ≤ 0` always. Enstrophy decays.
- **3D conditional** (`hctrl`): `−S ≤ D` ⇒ `Ω' = −2D − 2S ≤ −2D + 2D = 0`.
- **3D unconditional**: `S` free ⇒ `Ω'` sign indeterminate (possible growth).

Sanity check of the sign algebra used in
`Model3D.enstrophy_antitone_of_stretching_controlled` (here `D = 1`):

| S (stretching) | −S ≤ D? | Ω' = −2D−2S | ≤ 0? |
|----------------|---------|-------------|------|
| 0.0            | yes     | −2.0        | yes  |
| −0.5           | yes     | −1.0        | yes  |
| −1.0           | yes (=) | 0.0         | yes  |
| −1.5           | no      | +1.0        | no   |

The control hypothesis `−S ≤ D` is exactly the threshold `S ≥ −D` separating
guaranteed decay from possible growth — matching the proved theorem.

## 3. Counterexample hunt (against over-claiming)

We deliberately checked that the **3D unconditional** enstrophy bound is *false*
in general (otherwise the work would be vacuous or wrong): the row `S = −1.5`
above gives `Ω' > 0`, so without `hctrl` the enstrophy can increase. This is why
`Partial3D.lean` only states a *conditional* result, and why the genuine 3D
global regularity problem remains open. No false universal claim is made.

## 4. OEIS

No integer sequence arises (the objects are continuous dissipation identities),
so no OEIS lookup applies.

## Scope note

This stage is intentionally brief: the mathematical content is an exact identity
plus a sign inequality, both fully verified in Lean with only the standard
axioms `{propext, Classical.choice, Quot.sound}`. The tables above are
illustrative restatements of the machine-checked algebra, not the primary
evidence.
