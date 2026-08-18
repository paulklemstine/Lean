import MachineLearning.BonferroniMarginals.SharpBonferroni

/-!
# Lab notes: measured data for the Bonferroni machinery

Every number quoted in the other files of this directory was first measured with
the evaluations below and then proved.  The `#eval`s are kept so the data can be
re-measured; the `example`s are the machine-checked versions of the readings.

## Experiment 1 — the two three-set witnesses (`MarginalIndeterminacy.lean`)

| family    | `|Aᵢ|` | `|Aᵢ∩Aⱼ|`, `i≠j` | `|⋂ᵢAᵢ|` | `|cover|` | mult profile | offDiag mass | `2·|doubleColl|` | csGap |
|-----------|--------|------------------|----------|-----------|--------------|--------------|------------------|-------|
| triangle  | 2,2,2  | 1,1,1            | 0        | 3         | (2,2,2,0)    | 6            | 6                | 0     |
| sunflower | 2,2,2  | 1,1,1            | 1        | 4         | (3,1,1,1)    | 6            | 2                | 12    |

Readings: identical first and second marginals, different unions — this is the
measurement behind `union_not_determined_by_second_order_marginals`.  The
triangle has `csGap = 0` (regular cover, Corrádi tight); the sunflower has
`csGap = 12 > 0` and its double-collision bound is slack by `4`, precisely
because it carries a point of multiplicity `3`.

## Experiment 2 — the parity construction (`HigherOrderNecessity.lean`)

For `k = 1,2,3` the measured joint marginals of `plainFam k` (one copy per
subset) and `parityFam k` (two copies of the subsets of the right parity) agree
on every `T ≠ univ` and differ at `T = univ` (`1` versus `2`), and the covers
are `2^k − 1` (odd) versus an even number.

| k | `|cover plain|` | `|cover parity|` |
|---|-----------------|------------------|
| 1 | 1               | 2                |
| 2 | 3               | 2                |
| 3 | 7               | 8                |

## Experiment 3 — a four-set family with mixed multiplicities

`quad` (four subsets of `Fin 8`) is a non-regular family used to check that the
Bonferroni defect identity, the Corrádi inequality and the stability bound all
hold simultaneously with the measured slacks.  Measured profile: multiplicities
`(3,1,3,1,3,1)`, `|cover| = 6`, `∑ᵢ|Aᵢ| = 12`, off-diagonal mass `18`,
`2·|doubleCollision| = 6`, `csGap = 36`, Bonferroni defect `12`, Corrádi
`4·3² = 36 ≤ 6·(3 + 3·2) = 54`.
-/

namespace BonferroniMarginals

open Finset

/-! ## Experiment 1 -/

section Experiment1

/-- Multiplicity profile of the triangle family. -/
example : (List.range 4).map (fun n => mult (univ : Finset (Fin 3)) triangle
    ⟨n % 4, Nat.mod_lt _ (by norm_num)⟩) = [2, 2, 2, 0] := by decide

/-- Multiplicity profile of the sunflower family. -/
example : (List.range 4).map (fun n => mult (univ : Finset (Fin 3)) sunflower
    ⟨n % 4, Nat.mod_lt _ (by norm_num)⟩) = [3, 1, 1, 1] := by decide

#eval (cover (univ : Finset (Fin 3)) triangle).card      -- 3
#eval (cover (univ : Finset (Fin 3)) sunflower).card     -- 4
#eval ∑ p ∈ (univ : Finset (Fin 3)).offDiag, (triangle p.1 ∩ triangle p.2).card   -- 6
#eval ∑ p ∈ (univ : Finset (Fin 3)).offDiag, (sunflower p.1 ∩ sunflower p.2).card -- 6
#eval 2 * (doubleCollision (univ : Finset (Fin 3)) triangle).card    -- 6
#eval 2 * (doubleCollision (univ : Finset (Fin 3)) sunflower).card   -- 2
#eval csGap (univ : Finset (Fin 3)) triangle    -- 0
#eval csGap (univ : Finset (Fin 3)) sunflower   -- 12

/-- The measured Cauchy–Schwarz gaps: `0` for the regular triangle, `12` for the
sunflower.  By `regular_of_gap_zero` the first forces regularity; by
`sq_spread_le_gap` the second allows a multiplicity spread of at most
`⌊√12⌋ = 3`, and the true spread `3 − 1 = 2` indeed satisfies `2² = 4 ≤ 12`. -/
example : csGap (univ : Finset (Fin 3)) triangle = 0 := by decide

example : csGap (univ : Finset (Fin 3)) sunflower = 12 := by decide

/-- The stability bound applied to the measured sunflower data. -/
example : ((mult (univ : Finset (Fin 3)) sunflower 0 : ℤ)
    - (mult (univ : Finset (Fin 3)) sunflower 1 : ℤ)) ^ 2
      ≤ csGap (univ : Finset (Fin 3)) sunflower := by decide

/-- The Bonferroni defect identity, measured on the sunflower:
`∑ᵢ|Aᵢ| = 6`, defect `= (3−1)² = 4`, `|cover| = 4`, off-diagonal mass `= 6`. -/
example :
    (∑ i ∈ (univ : Finset (Fin 3)), (sunflower i).card)
        + ∑ x ∈ cover (univ : Finset (Fin 3)) sunflower,
            (mult (univ : Finset (Fin 3)) sunflower x - 1) ^ 2
      = (cover (univ : Finset (Fin 3)) sunflower).card
        + ∑ p ∈ (univ : Finset (Fin 3)).offDiag, (sunflower p.1 ∩ sunflower p.2).card := by
  decide

end Experiment1

/-! ## Experiment 2 -/

section Experiment2

#eval (cover (univ : Finset (Fin 1)) (plainFam 1)).card   -- 1
#eval (cover (univ : Finset (Fin 1)) (parityFam 1)).card  -- 2
#eval (cover (univ : Finset (Fin 2)) (plainFam 2)).card   -- 3
#eval (cover (univ : Finset (Fin 2)) (parityFam 2)).card  -- 2
#eval (cover (univ : Finset (Fin 3)) (plainFam 3)).card   -- 7
#eval (cover (univ : Finset (Fin 3)) (parityFam 3)).card  -- 8

/-- Measured: for `k = 2` the two families agree on all marginals of order `< 2`
(the three sets `∅, {0}, {1}`) and differ on the union. -/
example : (jointFail (plainFam 2) {0}).card = (jointFail (parityFam 2) {0}).card := by decide

example : (jointFail (plainFam 2) {1}).card = (jointFail (parityFam 2) {1}).card := by decide

example : (jointFail (plainFam 2) univ).card ≠ (jointFail (parityFam 2) univ).card := by decide

example : (cover (univ : Finset (Fin 2)) (plainFam 2)).card
    ≠ (cover (univ : Finset (Fin 2)) (parityFam 2)).card := by decide

end Experiment2

/-! ## Experiment 3 -/

section Experiment3

/-- Four subsets of an eight-point sample space with unequal multiplicities. -/
def quad : Fin 4 → Finset (Fin 8)
  | 0 => {0, 1, 2}
  | 1 => {2, 3, 4}
  | 2 => {4, 5, 0}
  | 3 => {0, 2, 4}

#eval (cover (univ : Finset (Fin 4)) quad).card    -- 6
#eval ∑ i ∈ (univ : Finset (Fin 4)), (quad i).card  -- 12
#eval ∑ p ∈ (univ : Finset (Fin 4)).offDiag, (quad p.1 ∩ quad p.2).card -- 18
#eval 2 * (doubleCollision (univ : Finset (Fin 4)) quad).card  -- 6
#eval csGap (univ : Finset (Fin 4)) quad  -- 36

/-- Measured second Bonferroni inequality for `quad`: `12 ≤ 6 + 18`, slack `12`,
matching the measured defect `∑ₓ (mult x − 1)² = 12` (three points of
multiplicity `3` contribute `4` each). -/
example :
    (∑ i ∈ (univ : Finset (Fin 4)), (quad i).card)
        + ∑ x ∈ cover (univ : Finset (Fin 4)) quad,
            (mult (univ : Finset (Fin 4)) quad x - 1) ^ 2
      = (cover (univ : Finset (Fin 4)) quad).card
        + ∑ p ∈ (univ : Finset (Fin 4)).offDiag, (quad p.1 ∩ quad p.2).card := by
  decide

/-- Measured Corrádi inequality for `quad` with `k = 4`, `m = 3`, `t = 2`:
`4·9 = 36 ≤ 6·(3 + 3·2) = 54`. -/
example : (univ : Finset (Fin 4)).card * 3 ^ 2
    ≤ (cover (univ : Finset (Fin 4)) quad).card * (3 + ((univ : Finset (Fin 4)).card - 1) * 2) := by
  decide

/-- The hypotheses of that reading really hold for `quad`. -/
example : (∀ i ∈ (univ : Finset (Fin 4)), 3 ≤ (quad i).card) ∧
    (∀ p ∈ (univ : Finset (Fin 4)).offDiag, (quad p.1 ∩ quad p.2).card ≤ 2) := by decide

/-- `quad` is not a regular cover, and its measured gap `36` bounds the observed
multiplicity spread `(3 − 1)² = 4 ≤ 36`, as `sq_spread_le_gap` requires. -/
example : ((mult (univ : Finset (Fin 4)) quad 0 : ℤ)
    - (mult (univ : Finset (Fin 4)) quad 1 : ℤ)) ^ 2
      ≤ csGap (univ : Finset (Fin 4)) quad := by decide

/-- Measured sharp (unordered-pair) second Bonferroni inequality for `quad`:
`2·12 = 24 ≤ 2·6 + 18 = 30`, with defect `∑ₓ (mult x − 1)(mult x − 2) = 6`
coming from the three points of multiplicity `3`. -/
example :
    2 * ∑ i ∈ (univ : Finset (Fin 4)), (quad i).card
        + ∑ x ∈ cover (univ : Finset (Fin 4)) quad,
            (mult (univ : Finset (Fin 4)) quad x - 1) * (mult (univ : Finset (Fin 4)) quad x - 2)
      = 2 * (cover (univ : Finset (Fin 4)) quad).card
        + ∑ p ∈ (univ : Finset (Fin 4)).offDiag, (quad p.1 ∩ quad p.2).card := by
  decide

/-- On the triangle, whose multiplicities are all `2`, the sharp bound is an
equality: `2·6 = 2·3 + 6`. -/
example :
    2 * ∑ i ∈ (univ : Finset (Fin 3)), (triangle i).card
      = 2 * (cover (univ : Finset (Fin 3)) triangle).card
        + ∑ p ∈ (univ : Finset (Fin 3)).offDiag, (triangle p.1 ∩ triangle p.2).card := by
  decide

end Experiment3

end BonferroniMarginals