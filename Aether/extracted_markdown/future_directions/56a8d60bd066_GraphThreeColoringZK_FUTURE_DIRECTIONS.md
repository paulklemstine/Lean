# Future Directions: Zero-Knowledge for Graph 3-Colorability

The file `GraphThreeColoringZK.lean` formalizes one round of the Goldreich–Micali–Wigderson
(GMW) zero-knowledge protocol for graph 3-colorability and proves completeness
(`gmw_completeness`), soundness (`gmw_soundness`, `gmw_soundness_error`), and the
zero-knowledge / simulation property via the exact bijection `revealMap_bijective`,
its uniform-preimage corollary `gmw_zk_uniform`, the color-independence statement
`gmw_zk_indistinguishable`, and simulator soundness `gmw_simulator_sound`. The central
discovery is that the single-round verifier's view is *exactly* a uniform distinct color
pair, captured cleanly because in `Fin 3` a permutation is rigidly determined by its
action on any two distinct points. Below are five testable directions that extend this
core.

## 1. Amplified soundness over `r` independent rounds

State and prove that running `r` independent rounds drives the cheating probability of a
non-3-colorable graph below `(1 - 1/|edges|)^r`, and derive the round count needed to
reach a target soundness error `2^{-λ}`. This converts the per-round bound
`gmw_soundness_error` (at least one monochromatic edge exists) into a negligible global
error. **The key insight is** that independence makes the per-round catch events
multiplicative, so the existence of a single catchable edge per round suffices for
exponential amplification without strengthening the per-round analysis. **Why now?** The
qualitative per-round catch is already proven (`gmw_soundness_error`); only a clean
`Finset`/probability-mass induction over rounds is missing, which is squarely within
reach of the current toolchain.

## 2. Distributional zero knowledge as an exact `Multiset`/PMF equality

Lift `gmw_zk_uniform` from a per-outcome counting statement to a single equation between
the pushforward of the uniform distribution on `Equiv.Perm (Fin 3)` under `revealMap` and
the uniform `PMF` on `DistinctPair`, then prove the simulator's output distribution equals
the real transcript distribution as `PMF`s. **The key insight is** that the bijection
`revealMap_bijective` already certifies a measure-preserving map, so the distributional
equality is `Equiv`-transport of uniform mass rather than a fresh combinatorial argument.
**Why now?** Mathlib's `PMF.uniformOfFintype` and `PMF.map` give exactly the algebraic
scaffolding to express "perfect zero knowledge" as a verifiable equality of probability
mass functions, upgrading our counting lemma to the textbook definition.

## 3. Generalization to `k`-colorability and identification of the rigidity threshold

Replace `Fin 3` by `Fin k` and ask for which `(k, t)` the map `σ ↦ (σ a_1, …, σ a_t)` from
`Equiv.Perm (Fin k)` to ordered distinct `t`-tuples is a bijection. For `t = k - 1` it is
always a bijection (the last point is forced); for `t = 2 < k - 1` it is only injective up
to the stabilizer of the unqueried points. **The key insight is** that single-edge
revealing is perfectly simulatable *iff* the queried positions determine the permutation,
i.e. `t ≥ k - 1`; otherwise the simulator must marginalize over the residual symmetric
group `S_{k-t}`. **Why now?** Our `decide +revert` proof for `k = 3` is a special case of a
counting identity `|S_k| = (k)_t · (k-t)!`, and isolating the `t = k-1` regime pinpoints
exactly where "reveal two endpoints" stays zero-knowledge as the palette grows.

## 4. Hiding from a concrete commitment scheme rather than an idealized opening

Couple `revealMap` to the algebraic commitments in `Commitments.lean`
(`zmod_commitment_binding`, `hiding_divides_domain`): instantiate the prover's commitment
to the recolored coloring as a vector of `ZMod p` commitments and prove that binding plus
`gmw_zk_uniform` together yield computational zero knowledge with an explicit advantage
bound in terms of the hiding parameter. **The key insight is** that the information-theoretic
uniformity we proved is the *ideal-world* view, and binding from the catalog's cohomological
commitments is precisely the bridge that makes the real-world transcript indistinguishable
from it. **Why now?** Both halves already exist in this catalog as zero-`sorry` theorems;
the missing step is a hybrid argument wiring `hiding_divides_domain` into the simulator's
indistinguishability, a self-contained reduction.

## 5. Fiat–Shamir collapse and a non-interactive ZK certificate for 3-colorability

Model the verifier's edge challenge as the output of a random oracle applied to the
commitment, and prove that the resulting non-interactive transcript is complete and sound
in the (programmable) random-oracle model, with the simulator programming the oracle to
hit the simulated view. **The key insight is** that because each round's simulated view is
*independent of the witness* (`gmw_zk_indistinguishable`), the simulator can fix the
challenge first and back-fill a consistent opening, which is exactly what oracle
programming requires. **Why now?** The per-round simulator and its soundness
(`gmw_simulator_sound`) are already proven, so Fiat–Shamir reduces to formalizing the
oracle-programming bookkeeping — a concrete, falsifiable target that would yield the first
machine-checked NIZK certificate for an NP-complete relation in this catalog.
