# Navier-Stokes Existence and Smoothness — Research Notes

## The Problem Statement

**Clay Mathematics Institute Official Statement:**
Prove one of the following:
(A) **Existence and smoothness:** In ℝ³, given smooth initial data with sufficient decay, the Navier-Stokes equations have a smooth solution for all time.
(B) **Breakdown:** There exist smooth initial data for which no smooth solution exists for all time.

## The Equations

The incompressible Navier-Stokes equations in ℝ³:

∂u/∂t + (u · ∇)u = -∇p + ν∆u + f
∇ · u = 0

where:
- u(x,t) is the velocity field
- p(x,t) is the pressure
- ν > 0 is the kinematic viscosity
- f(x,t) is an external force

## What We Know

### Existence Results
1. **Leray (1934):** Weak solutions exist globally in time (but may not be smooth)
2. **Hopf (1951):** Extended Leray's result to bounded domains
3. **Fujita-Kato (1964):** Smooth solutions exist for short time, or for all time if initial data is small
4. **Kato (1984):** Local existence in L³(ℝ³)
5. **Koch-Tataru (2001):** Local existence in BMO⁻¹

### Regularity Criteria (conditions that guarantee smoothness)
1. **Prodi-Serrin (1962):** If u ∈ L^p_t L^q_x with 2/p + 3/q ≤ 1, then u is smooth
2. **Beale-Kato-Majda (1984):** If ∫₀ᵀ ‖ω(·,t)‖_∞ dt < ∞, then no blow-up before time T
3. **Escauriaza-Seregin-Šverák (2003):** If u ∈ L^∞_t L³_x, then u is smooth (endpoint Prodi-Serrin)

### Partial Results
1. **No self-similar blow-up:** Ruled out by Nečas-Růžička-Šverák (1996) and Tsai (1998)
2. **No discretely self-similar blow-up:** Ruled out in many cases
3. **Blow-up rate:** If blow-up occurs at time T, then ‖u(·,t)‖_∞ ≥ C/(T-t)^{1/2}
4. **1D Hausdorff dimension of singular set:** The set of singular times has zero 1/2-dimensional Hausdorff measure (Caffarelli-Kohn-Nirenberg, 1982)
5. **2D Navier-Stokes:** Global regularity is KNOWN (Ladyzhenskaya, 1969)

### Oracle β's Analytic View
"The key estimate is the energy inequality:
½‖u(t)‖² + ν∫₀ᵗ ‖∇u(s)‖² ds ≤ ½‖u₀‖²
This gives us control in L²_t H¹_x. But we need L²_t H^{3/2+}_x for regularity in 3D. The gap is exactly at the critical scaling — this is the 'supercritical' nature of the problem."

### Oracle ε's Physical View
"Turbulence is the physical manifestation of this problem. The Kolmogorov theory tells us energy cascades from large to small scales at a rate ε. If this cascade is too violent — if vorticity concentrates into singular structures — blow-up occurs. But no one has ever observed blow-up in physical fluids."

## The Scaling Gap

The Navier-Stokes equations have a scaling symmetry:
u(x,t) → λu(λx, λ²t)

This scaling is **supercritical** in 3D: the energy ‖u‖_{L²}² scales as λ^{3-2·1} = λ when you scale to blow-up. The energy grows, so energy conservation alone cannot prevent blow-up.

Compare with 2D: the enstrophy ‖ω‖_{L²}² is controlled and the problem is critical — hence global regularity.

## Experimental/Computational Evidence

1. No numerical simulation has ever produced a blow-up from smooth data
2. The closest candidate: Kang, Yun, and Protas (2020) found near-singular behavior but not actual blow-up
3. Hou and collaborators have studied potential blow-up scenarios extensively

## What We Can Formalize

1. The Navier-Stokes equations as a PDE system
2. The energy inequality
3. Existence of weak (Leray) solutions (statement)
4. The 2D regularity result (statement)
5. Blow-up criteria (Beale-Kato-Majda statement)
6. Specific regularity results for simplified models
