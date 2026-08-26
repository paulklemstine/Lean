import Pythagorean.PrefixApproximation

/-!
# Computational evidence harness (no theorems)

Reproducible `#eval`s for the numbers built in this development.  These are *evidence*, not
proof: every asymptotic claim in the other files of this directory is proved as a theorem.
The data produced here is recorded in `ComputationalEvidence.md`.
-/

namespace Pyth

/-- First `M` digits of a digit sequence, as a string. -/
def digitString (d : ℕ → Fin 10) (M : ℕ) : String :=
  String.join ((List.range M).map (fun m => toString (d m : ℕ)))

/-- Number of nonzero digits among the first `M`. -/
def nonzeroCountFin (d : ℕ → Fin 10) (M : ℕ) : ℕ :=
  ((List.range M).filter (fun m => decide ((d m : ℕ) ≠ 0))).length

/-- Number of lag-`r` agreements among the first `M` positions. -/
def agreeCountFin (d : ℕ → Fin 10) (r M : ℕ) : ℕ :=
  ((List.range M).filter (fun m => decide (d m = d (m + r)))).length

-- Digit strings of the three witnesses (first 40 digits).
#eval digitString sparseSeq 40   -- 1101000100000001000000000000000100000000
#eval digitString denseSeq 40    -- 2212111211111112111111111111111211111111
#eval digitString altSeq 40      -- 2313121312121213121212121212121312121212

-- Nonzero-digit counts versus the proved bound `log₂ M + 1`.
#eval (nonzeroCountFin sparseSeq 10, nonzeroCountFin sparseSeq 100,
       nonzeroCountFin sparseSeq 1000, nonzeroCountFin sparseSeq 10000)   -- (4, 7, 10, 14)
#eval (Nat.log 2 10 + 1, Nat.log 2 100 + 1, Nat.log 2 1000 + 1, Nat.log 2 10000 + 1)

-- Autocorrelation counts: alternating witness is anticorrelated at lag 1, correlated at lag 2.
#eval (agreeCountFin altSeq 1 100, agreeCountFin altSeq 1 1000,
       agreeCountFin altSeq 2 100, agreeCountFin altSeq 2 1000)  -- (0, 0, 90, 984)
#eval (agreeCountFin denseSeq 1 1000, agreeCountFin denseSeq 3 1000,
       agreeCountFin denseSeq 7 1000)                            -- (983, 984, 985)
#eval (agreeCountFin sparseSeq 1 1000, agreeCountFin sparseSeq 2 1000)  -- (983, 984)

-- The lacunary support: positions `2^i - 1`.
#eval (List.range 12).map (fun i => 2 ^ i - 1)

end Pyth