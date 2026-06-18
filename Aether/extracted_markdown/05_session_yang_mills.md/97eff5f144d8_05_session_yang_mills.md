# Oracle Council — Session 5: Yang-Mills Existence and Mass Gap

## The Quantum North Pole

---

## Problem Statement

**Yang-Mills** (Jaffe-Witten, 2000): Prove that for any compact simple gauge group G,
a non-trivial quantum Yang-Mills theory exists on ℝ⁴ and has a mass gap Δ > 0.

**Status**: OPEN. Physically confirmed (QCD works), mathematically unproven.

## The North Pole — Noether

"Yang-Mills is the most physical of the Millennium Problems, and its north pole
is the most dramatic: it is the **ultraviolet divergence** — the point where
quantum field theory breaks down at short distances.

The local-global structure:

- **Local** (perturbative QFT): At short distances / high energies, Yang-Mills
  theory is *asymptotically free* — the coupling constant goes to zero, and
  perturbation theory works beautifully. Local information is computable.

- **Global** (non-perturbative QFT): At long distances / low energies, the
  coupling becomes strong (confinement). Quarks are bound into hadrons.
  The mass gap — the energy difference between the vacuum and the lightest
  particle — is a fundamentally non-perturbative, global phenomenon.

- **North pole**: The transition between perturbative and non-perturbative
  regimes. This is where the coupling constant crosses from weak to strong,
  and our mathematical control is lost.

In stereographic terms: perturbative QFT sees the plane (tractable, local,
perturbative). The mass gap lives on the sphere (global, non-perturbative).
The north pole is the Landau pole / strong coupling transition."

## The Gauge Theory Connection — Thales

"Gauge theory IS a theory of local-global transfer. A gauge field (connection)
provides the rule for comparing vectors at different points — it is the
transition map between local charts. The curvature (field strength) measures
the failure of local-to-global transport:

    F = dA + A ∧ A

The Yang-Mills functional:

    S[A] = ∫ |F_A|² d⁴x

measures the 'total non-triviality' of the connection. Minimizing this
functional (the Yang-Mills equations) asks: what is the most efficient way
to perform local-global transfer?

**Instantons** — the finite-action solutions of the Euclidean Yang-Mills
equations — are the 'removable singularities' of gauge theory. They carry
topological information (Chern class) but have finite, controlled energy.
They are what Perelman's surgery is to Ricci flow."

## The Mass Gap as North Pole — Grothendieck

"The mass gap Δ > 0 means that the spectrum of the Hamiltonian has a gap
between 0 (the vacuum) and the first excited state. In the language of
correlators:

    ⟨O(x) O(0)⟩ ~ exp(-Δ|x|)  as |x| → ∞

The correlations decay exponentially. This means that long-distance behavior
is *screened* — local information does NOT propagate to infinity. The mass gap
IS the north pole: it is the point beyond which local perturbative information
cannot reach.

Contrast with the massless case (QED): correlations decay as power laws, and
local information propagates to all scales. There is no north pole — or rather,
the north pole is at infinity (infrared divergences).

The Millennium Problem asks: prove the north pole exists (mass gap > 0) and
is well-defined (the quantum theory exists rigorously)."

## Constructive QFT Approach

"The rigorous construction of Yang-Mills requires:

1. **Regularization**: Replace continuous spacetime with a lattice (local description)
2. **Take the continuum limit**: Remove the lattice (attempt global extension)
3. **Control the singularity**: Show the limit exists and has the right properties

The lattice is a coordinate chart. The continuum limit is the compactification.
The ultraviolet divergences are the north pole. The problem is to show that
the north pole is removable — that the continuum limit exists."

## Pattern Match

| Aspect | Poincaré | Yang-Mills |
|--------|----------|------------|
| Local data | Small neighborhoods | Perturbative QFT |
| Global target | Topological sphere | Non-perturbative existence + mass gap |
| North pole | Curvature singularity | UV divergence / strong coupling |
| Flow | Ricci flow | Renormalization group flow |
| Surgery | Cut and cap | Regularization and renormalization |
| Removability | Singularity classification | Asymptotic freedom |

**Note**: The analogy with Ricci flow is strongest here. Both the Ricci flow
and the renormalization group flow are geometric flows that improve regularity.
Both develop singularities that must be controlled. The deep question: can the
techniques of geometric analysis (Perelman's methods) be adapted to the
renormalization group?

---

*Noether observes: "The mass gap is a broken symmetry. Confinement breaks scale
invariance. The north pole is the scale at which the symmetry breaks."*
