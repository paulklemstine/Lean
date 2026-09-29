# Computational evidence — paper 116 (consolidation of the type-channel law)

The numbers below were first explored with a short exploratory script (permutation
enumeration plus Shannon entropies). They are **not** used as evidence of correctness:
each exact value listed as "Lean" was then proved in closed form in
`Catalog/Cryptography/TypeChannelMilestone/*.lean`, with no `sorry` and no `native_decide`.
Rows marked "script only" were not formalised.

`L = log₂ 3 ≈ 1.58496`. `T` = splitting type, `c` = abelianization-coset readout.

## 1. Degree-6 nonabelian channels (open problem 4 in the milestone)

| field | G (order) | readout | H(T) | I(c;T) exact | numeric | status |
|---|---|---|---|---|---|---|
| x⁶ − 2 | D₆ (12) | faithful `cycleType6` | 1 + 3L/4 | 4/3 + L/4 | 1.72957 | Lean (`D6_channel`) |
| x⁶ − 2 | D₆ (12) | quartic `splitType` | 2/3 + 3L/4 | 1 + L/4 | 1.39624 | Lean (`D6_coarse_channel`) |
| closure of x³ − 2 | S₃ regular (6) | `cycleType6` | 2/3 + L/2 | 1 | 1.00000 | Lean (`S3reg_channel`) |
| x³ + x + 1 (reference) | S₃ (6) | `splitType` | 2/3 + L/2 | 1 | 1.00000 | catalog (`S3_channel`) |

The script's floating-point values agree with the closed forms to 1e-15:
`D6 I = 1.729573958513623` against `4/3 + L/4 = 1.7295739585136223`; `H(T) = 2.188721875540867`
against `1 + 3L/4`.

Joint cell counts for D₆ (coset label, type) out of 12, used in `D6_entropy_joint`:

| coset | elements | types (count) |
|---|---|---|
| 0: even rotations | k↦k, k↦k+2, k↦k+4 | 1⁶ (1), 3² (2) |
| 1: odd rotations | k↦k+1, k↦k+3, k↦k+5 | 6 (2), 2³ (1) |
| 2: vertex reflections | k↦a−k, a even | 1²2² (3) |
| 3: edge reflections | k↦a−k, a odd | 2³ (3) |

The type 2³ shows up in two cosets, which is why D₆ is incomplete (`D6_incomplete`). The loss is
2/3 − L/4 ≈ 0.2704 bits.

## 2. Hunting for counterexamples to the milestone's wording

* **"In between, I is exactly E[H(G^ab-class | T)]."** This fails already for S₃: I = 1 but
  H(c | T) = 0 (`S3_channel_ne_coset_uncertainty`). In general the loss log₂[G:G'] − I equals
  H(c | T) (`unified_type_channel_law`, part 2). Across the six catalog fields plus D₆, the
  loss column matches H(c|T) and the I column does not.
* **"Joint channels are super-additive."** This fails whenever the two dials are redundant
  (`battery_not_superadditive`, with T₁ = T₂ = c). What always holds is monotonicity plus the
  chain rule (`battery_chain`, `battery_capped`).

## 3. The sandwich bound max(0, H(T) − log₂|G'|) ≤ I ≤ min(H(T), log₂[G:G'])

| G | H(T) − log₂|G'| | I | min(H(T), cap) |
|---|---|---|---|
| S₃ | 1.459 − 1.585 < 0 | 1 | 1 |
| A₄ | 1.189 − 2 < 0 | 0.918 | 1.189 |
| D₄ | 1.906 − 1 = 0.906 | 1.656 | 1.906 |
| V₄, C₄ | H(T) − 0 = H(T) | H(T) | H(T) (tight) |
| D₆ | 2.189 − 1.585 = 0.604 | 1.730 | 2 |

These are script values. The D₄ lower bound is proved in Lean (`D4_sandwich_lower`), and the D₆
instance comes from the general theorem (`D6_sandwich`). The abelian rows are tight at both ends,
as the law says they should be.

## 4. OEIS

None of the objects here is an integer sequence (all channel values lie in ℚ + ℚ·log₂3), so
there was nothing to look up.
