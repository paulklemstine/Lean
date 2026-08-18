# Computational evidence — almost-lossless / Monte-Carlo compression

All numbers below were computed **inside Lean**, by `#eval` on the very
definitions the theorems are about (`Catalog/Geometry/AlmostLosslessLabNotes.lean`,
which recomputes every entry of this file when elaborated).  Nothing here was
computed in an external script.

Experimental setup: source alphabet `A = Fin 6` (six possible strings), typical
set `S = {0,1,2}` (`|S| = 3`), transmitted string `x = 0`, codebook size `M`.
The sample space is the set of **all** `M^6` codebooks `H : A → Fin M`, so every
"probability" below is an exact rational count, not a simulation.

## 1. Failure probability of uniform random hashing

| `M` | codebooks `M^6` | failing codebooks | measured `P[failure]` | union bound `(|S|-1)/M` | Bonferroni lower bound `(|S|-1)/(2M)` |
|-----|-----------------|-------------------|-----------------------|--------------------------|----------------------------------------|
| 2   | 64              | 48                | `3/4  = 0.7500`       | `1`                      | `1/2`                                  |
| 3   | 729             | 405               | `5/9  ≈ 0.5556`       | `2/3 ≈ 0.6667`           | `1/3 ≈ 0.3333`                         |
| 4   | 4096            | 1792              | `7/16 = 0.4375`       | `1/2`                    | `1/4`                                  |
| 8   | 262144          | 61440             | `15/64 ≈ 0.2344`      | `1/4`                    | `1/8`                                  |
| 16  | 16777216        | 2031616           | `31/256 ≈ 0.1211`     | `1/8`                    | `1/16`                                 |

Observations.

* The measured value is exactly `1 - (1 - 1/M)^{|S|-1} = (2M-1)/M²` in every
  case.  This closed form was first observed in the table and is now a theorem:
  `AlmostLossless.failure_prob_exact`, proved by an explicit bijection
  `{H separating x from D ∪ {a}} × Fin M ≃ Σ_{H separating x from D} (Fin M \ {H x})`.
* It always lies between the two *proved* bounds
  (`AlmostLossless.failSet_prob_le` and `AlmostLossless.failure_prob_lower_bound`),
  and both bounds are tight to within a factor `2` in the regime `|S| ≤ M`.
  This is the quantitative content of the claim "random hashing genuinely pays
  a `Θ(1/ε)` factor": to push the measured column below `ε` one must take
  `M = Θ(|S|/ε)`.
* Success and failure sets partition the codebook space exactly
  (`324 + 405 = 729` at `M = 3`), so the inequality
  `card_goodSet_ge` is an equality in these instances.

No integer sequence lookup (OEIS or otherwise) was required: the counts are
explained in closed form by `M^6 · (2M-1)/M²`.

## 2. Counterexample hunt: silent corruption of atypical strings

The plain scheme is *provably* never wrong on typical strings
(`AlmostLossless.decode_never_wrong`, a theorem with no probabilistic content).
Adversarial testing of the **atypical** case (typical list `[1,2]`, transmitted
string `x = 0 ∉ {1,2}`, `M = 4`) found the failure mode immediately:

| scheme                        | measured `P[silent corruption]` | proved bound |
|-------------------------------|---------------------------------|--------------|
| no checksum                   | `3/8 = 0.375`                   | none — genuinely unbounded |
| checksum `K = 2`              | `3/16 = 0.1875`                 | `≤ 1/2`      |
| checksum `K = 4`              | `3/32 = 0.09375`                | `≤ 1/4`      |

So the counterexample is real (0.375 is not small), and the measured probability
is divided by exactly `K` when the random checksum is added — matching the
scaling of the proved bound `AlmostLossless.silent_corruption_prob_le`
(`P ≤ 1/K`), which the data show is loose by the constant factor `3/8` here but
has the correct `1/K` dependence.

## 3. Decoder complexity

| decoder                                   | measured cost | formula        |
|-------------------------------------------|---------------|----------------|
| flat scan of a typical set of size 3      | `3`           | `|S|`          |
| blocked, `b = 3` blocks, `|T| = 2`        | `6`           | `b·|T|`        |
| flat scan of the product typical set `T^b`| `8`           | `|T|^b`        |

The cost figures are returned by the decoders themselves (they carry their own
comparison counter), so the complexity theorems `decode_cost`,
`blockDecode_cost` are statements about the executed program, not an external
model.  The separation `b·|T| < |T|^b` was checked here at `(b,|T|) = (3,2)`
(`6 < 8`) and is proved in general for `b ≥ 3`, `|T| ≥ 2`
(`AlmostLossless.block_beats_flat`).
