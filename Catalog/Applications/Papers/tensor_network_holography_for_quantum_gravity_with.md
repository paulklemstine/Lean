# Computational Evidence — Tensor-Network Discrete Curvature

All values below were computed in Lean with `#eval` on the literal definitions
`formanEdge`/`totalForman` (combinatorial Forman–Ricci curvature), and every
numeric fact is *also* discharged by a fully-proved theorem in the companion
`.lean` files (no `sorry`, axioms only `propext`/`Classical.choice`/`Quot.sound`).

## 1. Total Forman curvature of complete-graph networks `Kₙ`

`Kₙ` is `(n−1)`-regular, so the structural formula `totalForman = 2n(n−1)(3−n)`
applies. Direct `#eval`:

| n | network | `totalForman (⊤ : SimpleGraph (Fin n))` | sign |
|---|---------|-----------------------------------------|------|
| 2 | K₂      | `4`                                     | +    |
| 3 | K₃      | `0`                                     | flat |
| 4 | K₄      | `-24`                                   | −    |
| 5 | K₅      | `-80`                                   | −    |
| 6 | K₆      | `-180`                                  | −    |

**Curvature sign transition.** The total curvature is `> 0` only for `n ≤ 2`,
exactly `0` at `n = 3` (the flat triangle), and strictly `< 0` for all `n ≥ 4`.
The `n = 5` value `-80` is the explicit instance proved as
`completeGraph_Fin5_total`; the general strict negativity for `n ≥ 5` is
`completeGraph_neg` (the `n = 4` boundary case `-24` is also negative but is the
first member past the threshold).

## 2. Regular lattices (cycles `Cₙ`, the 2-regular case)

| graph | regularity | `totalForman` |
|-------|------------|---------------|
| C₅    | 2-regular  | `0`           |
| C₆    | 2-regular  | `0`           |

This matches `totalForman_regular` at `d = 2`: `2·n·2·(2−2) = 0`. A 2-regular
network is *flat*, the boundary between positive (`d ≤ 1`) and negative (`d ≥ 3`)
discrete curvature. The mission's **4-regular** lattices land squarely in the
negative regime: every edge has curvature `−4` (`fourRegular_edge_curvature`)
and the total over the `4·|V|` directed edges is `−16·|V|` (`fourRegular_total`).

## 3. Counterexample hunt

The claim "total Forman curvature ≤ 0 for regular graphs of degree `d`" is FALSE
for `d ≤ 1`: K₂ (`d = 1`) gives `+4`. This is why `totalForman_nonpos_of_regular`
carries the hypothesis `d ≥ 2`, and `formanEdge_neg_of_regular` carries `d ≥ 3`
for *strict* edge negativity. No counterexample exists within the stated
hypotheses (verified by the proofs themselves).

## 4. Information-metric side (no numeric table needed)

The Fisher/quantum-information metric results (`fisherMatrix_posSemidef`,
`fisherMatrix_cauchySchwarz`) are universally quantified over all finite
statistical models and score functions; they are established by structural proof
(quadratic-form rewrite + Cauchy–Schwarz), so a finite numeric sweep is neither
necessary nor sufficient. The decisive identity is
`∑ᵢⱼ xᵢ gᵢⱼ xⱼ = 𝔼_ω[(∑ᵢ xᵢ sᵢ)²] ≥ 0`.
