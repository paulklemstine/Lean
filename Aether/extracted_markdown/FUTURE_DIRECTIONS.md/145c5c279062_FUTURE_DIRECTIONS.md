# Future Directions: The Black Hole Information Paradox, Formalized

The file `Catalog/Physics/HawkingInformationParadox.lean` reduces the information
paradox to a clean dichotomy: on a finite-dimensional Hilbert space, an
evaporation map is unitary (norm preserving) **iff** the in-state is recoverable
from the out-state, and information loss (non-injectivity) provably forbids
unitarity. The 2-qubit SWAP toy model (`evapU`) realizes a concrete unitary
evaporation, preserves all overlaps (`evapU_preserves_overlap`), and recovers the
initial state exactly (`recover_evaporate`). The directions below sharpen this
skeleton toward the actual physics of mixed states, partial traces, and entropy.

## 1. Page curve from unitarity of a random evaporation model

Build the time-resolved version: model evaporation as a one-parameter family of
unitaries `U t : H_BH ⊗ H_rad ≃ₗᵢ[ℂ] H_BH ⊗ H_rad` and define the radiation
entropy `S(t)` as the von Neumann entropy of the partial trace over the black
hole. Conjecture: for a Haar-typical unitary family the entanglement entropy of
the emitted radiation rises then falls, peaking at the Page time `t = N/2`,
returning to `0` at full evaporation — the **Page curve** — *purely as a
consequence of global unitarity*, with no appeal to gravity.
**The key insight is** that the Page curve is a corollary of `evapU`'s overlap
preservation lifted to reduced density matrices: global purity forces
`S_rad(t) = S_BH(t)`, so the radiation entropy is pinned by the shrinking
black-hole dimension. **Why now?** The present file already supplies the unitary
and the recoverability lemma; the only missing ingredient is a Mathlib-level
`partialTrace` and `vonNeumannEntropy`, which are finite-dimensional linear
algebra well within reach.

## 2. Quantitative no-cloning as the obstruction to "copying the radiation"

Formalize that the recovery map `R` of `unitary_preserves_information` cannot be
implemented while *also* leaving a copy of the in-state behind: there is no
linear `C : H → H ⊗ H` with `C ψ = ψ ⊗ ψ` for all `ψ`. Strengthen to an
approximate, dimension-dependent bound on the best achievable cloning fidelity.
**The key insight is** that the firewall/complementarity tension is exactly the
no-cloning theorem applied to `recoverable_iff_information_preserved`: information
is recoverable from the radiation *or* from the interior, never verifiably both,
because a single linear map cannot both invert `evapU` and duplicate its input.
**Why now?** No-cloning is a two-line linearity argument once the tensor-product
state space is set up, and it converts the informal "complementarity" slogan into
a falsifiable Lean statement.

## 3. Channel form: unitarity ⇔ zero entropy defect (bridge to Landauer)

Connect to `Catalog/Physics/Landauer.lean`. For a quantum channel given by a
linear map `E`, define a quantum entropy defect generalizing the tropical
`entropyDefect`, and prove: `E` is unitary iff its entropy defect is `0` iff it
is information-preserving. This makes the non-unitary horn of the paradox
*literally* an instance of Landauer erasure.
**The key insight is** that `information_loss_violates_unitarity` and Landauer's
`tropical_landauer_noninjective` are the same theorem at two temperatures: a
non-injective map has strictly positive defect, and unitarity is the defect-zero
boundary. **Why now?** The catalog already has the tropical defect proven; lifting
it to the rank/log-dimension defect of a linear map reuses that scaffolding and
yields a cross-domain bridge theorem (thermodynamics ↔ quantum info).

## 4. Mixed-state recovery via the Knill–Laflamme conditions

Generalize `recover_evaporate` from pure states to a subspace code: given an
isometry `V : H_code → H_BH ⊗ H_rad` and an "erasure of the black hole" channel,
prove exact correctability iff the Knill–Laflamme conditions hold, and exhibit a
2-qubit code where the radiation alone suffices to decode. This is the
error-correction reading of "the interior is encoded in the radiation."
**The key insight is** that black-hole interior reconstruction is *quantum error
correction*: `evapU.symm` is the trivial decoder, and the general case replaces
"unitary on the whole space" with "isometry onto a correctable code subspace."
**Why now?** It links directly to the catalog's stabilizer/QEC files
(`Catalog/Physics/HolographicCodes.lean`, `Catalog/Physics/ToricCode.lean`),
turning the toy model into a genuine holographic-code statement.

## 5. Strict monogamy: recoverable interior forbids recoverable late radiation

State and prove the monogamy-of-entanglement obstruction quantitatively: if the
late radiation is maximally entangled with the early radiation (purity of the
total state), it *cannot* be maximally entangled with the interior modes. Cast as
a strict inequality on overlaps that fails exactly when one demands both
recoveries simultaneously.
**The key insight is** that the AMPS firewall argument is a strict inequality
forced by `evapU_preserves_overlap`: overlap preservation distributes a fixed
total correlation budget, so two incompatible recovery demands overspend it.
**Why now?** With overlap preservation already proven, monogamy becomes an
inner-product inequality (Cauchy–Schwarz on reduced states) rather than a
physical postulate — a self-contained, falsifiable capstone for the series.
