# Oracle Council — Session 6: Navier-Stokes Existence and Smoothness

## The Analytic North Pole

---

## Problem Statement

**Navier-Stokes** (Fefferman, 2000): Prove (or disprove) that smooth, globally
defined solutions exist for the 3D incompressible Navier-Stokes equations for
all time, given smooth initial data with sufficient decay.

**Status**: OPEN. Solutions are known to exist for short times, and weak solutions
exist globally, but uniqueness and regularity are unresolved.

## The Equations

    ∂u/∂t + (u · ∇)u = -∇p + ν∆u + f
    ∇ · u = 0

where u is velocity, p is pressure, ν is viscosity, f is external force.

## The North Pole — Ramanujan

"The north pole of Navier-Stokes is **blowup** — the possibility that the
velocity field develops infinite values in finite time. If this happens, the
smooth solution ceases to exist, and the PDE loses its predictive power.

The local-global structure:

- **Local** (short time): Smooth solutions exist for short times. This is
  standard PDE theory — the local existence theorem.
- **Global** (all time): Do solutions remain smooth forever?
- **North pole**: Potential singularity formation — the point where the velocity
  concentrates to infinity.

The energy inequality gives partial information:

    ½ d/dt ∫|u|² dx + ν ∫|∇u|² dx = ∫ f·u dx

Energy is globally controlled. But energy is an L² quantity, and controlling L²
does not control L^∞ in three dimensions. The north pole is in the gap between
L² (energy) and L^∞ (pointwise regularity)."

## The Scaling Analysis — Thales

"Navier-Stokes has a critical scaling. If u(x,t) is a solution, then so is:

    u_λ(x,t) = λ u(λx, λ²t)

The energy scales as:

    ∫|u_λ|² dx = λ^(2-d) ∫|u|² dx

In d = 3 dimensions, energy scales as λ^{-1} — it is *supercritical*. This means
that energy control becomes weaker at small scales. The potential blowup occurs
because energy can concentrate at smaller and smaller scales without being
controlled by the energy bound.

This is exactly the stereographic scaling: near the north pole, the conformal
factor of stereographic projection blows up, magnifying small regions of the
sphere into large regions of the plane. The supercritical scaling of Navier-Stokes
is the conformal factor of its 'stereographic projection'."

## Vortex Stretching — The Mechanism

"The nonlinear term (u · ∇)u contains the vortex stretching mechanism. In terms
of vorticity ω = ∇ × u:

    ∂ω/∂t + (u · ∇)ω = (ω · ∇)u + ν∆ω

The term (ω · ∇)u stretches vortex tubes, potentially concentrating vorticity
into singular structures. This is the mechanism that could create the north pole.

In 2D, this term vanishes (vorticity is scalar, there's no stretching). This is
why 2D Navier-Stokes is solved — there's no north pole in 2D. The north pole is
a fundamentally 3-dimensional phenomenon.

The stereographic analogy: in 2D, the sphere S² minus the north pole is
conformally equivalent to the plane, and the conformal factor is integrable.
In 3D, the scaling becomes critical/supercritical, and integrability fails."

## Connection to Perelman — Noether

"There is a direct analogy with Ricci flow:

- Ricci flow: ∂g/∂t = -2 Ric(g) — curvature drives the evolution
- Navier-Stokes: ∂ω/∂t = ... + ν∆ω — vorticity drives the evolution

Both are parabolic equations that can develop singularities in finite time.
Perelman's key tool was the **entropy functional** — a monotone quantity that
controls the singularity formation. The Navier-Stokes analogue would be a
monotone quantity that controls vorticity concentration.

The Caffarelli-Kohn-Nirenberg theorem (1982) shows that the set of singular
points has zero one-dimensional Hausdorff measure. This is a partial
'singularity classification' — it says the north pole, if it exists, is very
small. But it doesn't say it's empty."

## Pattern Match

| Aspect | Poincaré | Navier-Stokes |
|--------|----------|---------------|
| Local data | Short-time neighborhoods | Short-time smooth existence |
| Global target | Topological sphere | Global smooth existence |
| North pole | Curvature singularity | Velocity blowup |
| Flow | Ricci flow | Navier-Stokes flow itself |
| Scaling | Critical (3D Ricci) | Supercritical (3D NS) |
| Partial result | Singularity classification | CKN theorem |
| Resolution | Surgery removes singularities | ??? |

## The Deep Question

Can the Navier-Stokes north pole be removed by surgery? This would mean:
when a singularity forms, we can continue the solution past it in a canonical
way. This is the program of *suitable weak solutions* — solutions that satisfy
an energy inequality and may have singularities, but are unique and physically
meaningful.

---

*Ramanujan: "In 2D, the fluid is like a plane — flat, tractable, no north pole.
In 3D, the fluid is like a sphere — curved, singular, with a point at infinity
where all our estimates fail."*
