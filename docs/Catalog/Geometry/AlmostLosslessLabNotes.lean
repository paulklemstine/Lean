/-
# Lab notes: measured behaviour of the almost-lossless schemes

Every number in the comments below was produced by the `#eval` command it
annotates, using the *same* definitions that the theorems are stated about
(source alphabet `A = Fin 6`, typical set `S = {0,1,2}`, codebook size `M`).

Summary of the experiments (see `ComputationalEvidence.md` for the discussion):

| M  | measured `P[failure]` | union bound `(|S|-1)/M` | Bonferroni bound `(|S|-1)/(2M)` |
|----|-----------------------|-------------------------|---------------------------------|
| 2  | 3/4    = 0.750        | 1                       | 1/2                             |
| 3  | 5/9    ≈ 0.556        | 2/3  ≈ 0.667            | 1/3  ≈ 0.333                    |
| 4  | 7/16   = 0.438        | 1/2                     | 1/4                             |
| 8  | 15/64  ≈ 0.234        | 1/4                     | 1/8                             |
| 16 | 31/256 ≈ 0.121        | 1/8                     | 1/16                            |

The measured value is always `1 - (1 - 1/M)^{|S|-1} = (2M-1)/M²`, sandwiched
between the two proved bounds — both of them are tight up to a factor `2`.
The closed form is itself a theorem: `AlmostLossless.failure_prob_exact`.
-/
import Geometry.AlmostLosslessConverse
import Geometry.AlmostLosslessExact
import Geometry.AlmostLosslessMaster

namespace AlmostLossless

open Finset

section LabNotes

/-- Source alphabet of the experiments. -/
abbrev LabAlphabet := Fin 6

/-- Typical set of the experiments. -/
def labS : Finset LabAlphabet := {0, 1, 2}

/-- Enumeration of `labS` used by the decoder. -/
def labList : List LabAlphabet := [0, 1, 2]

-- The typical set has three elements, out of an alphabet of six.
#eval labS.card                                    -- 3
#eval Fintype.card (LabAlphabet → Fin 3)           -- 729  (number of codebooks)

-- Measured failure probability of uniform random hashing at `x = 0`.
#eval ((failSet labS (0 : LabAlphabet) 2).card : ℚ) / (2 ^ 6 : ℚ)    -- 3/4
#eval ((failSet labS (0 : LabAlphabet) 3).card : ℚ) / (3 ^ 6 : ℚ)    -- 5/9
#eval ((failSet labS (0 : LabAlphabet) 4).card : ℚ) / (4 ^ 6 : ℚ)    -- 7/16
#eval ((failSet labS (0 : LabAlphabet) 8).card : ℚ) / (8 ^ 6 : ℚ)    -- 15/64
#eval ((failSet labS (0 : LabAlphabet) 16).card : ℚ) / (16 ^ 6 : ℚ)  -- 31/256

-- The closed form proved in `AlmostLosslessExact` predicts `1 - (1 - 1/M)^(|S|-1)`;
-- these are the same numbers as the measured column above.
#eval (1 - (1 - 1/(2 : ℚ)) ^ 2)                    -- 3/4
#eval (1 - (1 - 1/(3 : ℚ)) ^ 2)                    -- 5/9
#eval (1 - (1 - 1/(4 : ℚ)) ^ 2)                    -- 7/16
#eval (1 - (1 - 1/(8 : ℚ)) ^ 2)                    -- 15/64
#eval (1 - (1 - 1/(16 : ℚ)) ^ 2)                   -- 31/256

-- Success set and failure set partition the codebook space (`card_goodSet_ge` is
-- tight here): 324 + 405 = 729.
#eval (goodSet labList (0 : LabAlphabet) 3).card   -- 324
#eval (failSet labS (0 : LabAlphabet) 3).card      -- 405

-- Decoder output and *exact* cost: three hash comparisons.
#eval decode labList (fun y : LabAlphabet => (⟨y.val % 3, by omega⟩ : Fin 3)) 0
                                                   -- (some 0, 3)

-- Silent corruption of an ATYPICAL string `x = 0` (typical list `[1,2]`),
-- without a checksum: happens for 3/8 of the codebooks.
#eval (((univ : Finset (LabAlphabet → Fin 4)).filter
        (fun H => ((decode [(1 : LabAlphabet), 2] H (H 0)).1).isSome)).card : ℚ)
      / (4 ^ 6 : ℚ)                                -- 3/8

-- With an independent random checksum the same quantity is divided by `K`,
-- in agreement with the proved bound `≤ 1/K`.
#eval ((silentSet [(1 : LabAlphabet), 2] (0 : LabAlphabet) 4 2).card : ℚ)
      / ((4 ^ 6 : ℚ) * (2 ^ 6 : ℚ))                -- 3/16
#eval ((silentSet [(1 : LabAlphabet), 2] (0 : LabAlphabet) 4 4).card : ℚ)
      / ((4 ^ 6 : ℚ) * (4 ^ 6 : ℚ))                -- 3/32

-- Blocked decoder: `b = 3` blocks over a binary block alphabet, cost `b·|T| = 6`,
-- versus `|T|^b = 8` for the flat decoder over the product typical set.
#eval (blockDecode [(0 : Fin 2), 1]
        (fun p : Fin 3 × Fin 2 => (⟨p.2.val, by omega⟩ : Fin 4)) (fun _ => 0)).2  -- 6
#eval (Fintype.piFinset (fun _ : Fin 3 => (univ : Finset (Fin 2)))).card           -- 8

-- Axiom audit of the main results.
#print axioms pigeonhole_barrier
#print axioms decode_cost
#print axioms decode_never_wrong
#print axioms success_prob_ge
#print axioms exists_good_codebook
#print axioms blockDecode_cost
#print axioms blockDecode_success_prob_ge
#print axioms block_beats_flat
#print axioms silent_corruption_prob_le
#print axioms general_checksum_bound
#print axioms converse_card_good_le
#print axioms failure_prob_lower_bound_real
#print axioms failure_prob_exact

end LabNotes

end AlmostLossless