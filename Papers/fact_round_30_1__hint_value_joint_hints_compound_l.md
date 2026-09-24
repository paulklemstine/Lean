# Computational evidence — HINT-VALUE-JOINT (round 30 #1, paper 101)

All numbers below were recomputed independently of the round-30 log (which was not available
in this workspace) with an exact plug-in entropy calculator on small populations, and every
claim that survived was then *re-derived exactly in Lean* from fibre counts — no floating
point enters the formal files.

## 1. The quantities

For a population of samples with factor residues `(p, q)` and labels `T`:

| symbol | meaning |
|---|---|
| `N = p q` | hint-free product view |
| `s = p + q`, `d = q - p` | the two dials |
| `I(T;N)` | product row |
| `sumHint = I(T;N,s) - I(T;N)` | **conditional** hint value of the sum dial |
| `gapHint = I(T;N,d) - I(T;N)` | conditional hint value of the gap dial |
| `jointHint = I(T;s,d) - I(T;N)` | joint hint value (paper 101's `+2.4291`) |
| `hintSynergy = jointHint - sumHint - gapHint` | compounding |

Paper 101 compares the joint hint value with a *per-dial hint sum*; the tables below use the
conditional reading, which is the one in which "does a second hint help?" is a well-posed
question.

## 2. Extremal batteries (exact, all entropies rational)

| battery | modulus | samples | `I(T;N)` | `sumHint` | `gapHint` | `jointHint` | **synergy** |
|---|---|---|---|---|---|---|---|
| `P=(1,2)`, `Q=(1,3)`, `T=(0,1)` | 5 | 2 | 0 | 1 | 1 | 1 | **−1** |
| `P=(2,4,3,5)`, `Q=(4,2,5,3)`, `T=(0,1,1,0)` | 7 | 4 | 0 | 0 | 0 | 1 | **+1** |
| product of two copies of the previous | `7 × 7` | 16 | 0 | 0 | 0 | 2 | **+2** |

Both extremes are formalised: `HintValueJoint.RedundantWitness` (`−1`),
`HintValueJoint.CompoundWitness` (`+1`), `HintValueMultiField.TwoFieldWitness` (`+2`).

## 3. Counterexample hunt for the ceiling

Randomised search for a single-field battery with conditional hint synergy `> 1`:

* moduli `m ∈ {5, 7, 11, 13}`, populations of `4`–`12` samples, `2`–`6` labels,
* `2 × 200 000` random batteries,
* **maximum synergy observed: `1.000000`** (attained), minimum `−1.000000`.

No violation of the one-bit law was found; the law is now a theorem
(`HintValueJoint.hintSynergy_le_one_zmod`), so no search can find one.

## 4. Discriminant cells modulo 7

For each cell `(N, s)` the number of factor pairs is `1 + χ(Δ)` with `Δ = s² − 4N`:

| cell `(N,s)` | `Δ mod 7` | residue? | factor pairs |
|---|---|---|---|
| `(1,6)` | `32 = 4 = 2²` | yes | `(2,4)`, `(4,2)` |
| `(1,1)` | `1 − 4 = −3 = 4` | yes | `(3,5)`, `(5,3)` |
| `(1,2)` | `4 − 4 = 0` | zero | `(1,1)` only |
| `(1,0)` | `−4 = 3` | no | none |

The cycle-1 compounding witness lives over the two residue cells `(1,6)` and `(1,1)`, which is
exactly why it can carry an orientation bit; the formal statements are
`HintOrientation.compound_witness_discriminant_isSquare` and
`HintOrientation.non_residue_cell_has_no_factorisation`.

## 5. What the evidence does *not* support

* The plug-in estimate of a which-factor statistic on `~508k` cells with `30k` samples is not
  reproducible at small scale and is not interpreted in any theorem here.
* The reported `+1.40` bits of "hint synergy" is compatible with a **two-field** conditional
  decomposition (ceiling `2`) and incompatible with a single-field one (ceiling `1`); which of
  the two the round-30 pipeline computed cannot be decided from the numbers alone.
