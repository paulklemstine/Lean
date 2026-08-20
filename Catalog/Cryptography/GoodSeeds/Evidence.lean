import Cryptography.GoodSeeds.SampledMonitoring
import Cryptography.GoodSeeds.BoundedSearch
import Cryptography.GoodSeeds.Rewinding

open Cryptography.GoodSeeds
open Cryptography.GoodSeeds.SampledMonitoring

def compFrac (k N : ℕ) : ℚ := ((N : ℚ) - ((N / k : ℕ) : ℚ)) / (N : ℚ)

-- compromised fractions for k = 2, 3, 4 and N = 1..9
#eval (List.range 9).map fun N => (N + 1, (N + 1) / 3, compFrac 3 (N + 1))
#eval (List.range 9).map fun N => (N + 1, compFrac 2 (N + 1))
#eval (List.range 9).map fun N => (N + 1, compFrac 4 (N + 1))

-- amplification 1 - (1-e)^k for e = 1/4
#eval (List.range 8).map fun k => (k, 1 - (1 - (1/4 : ℚ)) ^ k)

-- level-set fractions of the residue stratification, N = 10, k = 3
#eval (List.range 3).map fun i =>
  (i, (((Finset.Ioc 0 10).filter (fun n => n % 3 = i)).card : ℚ) / 10)

-- heavy-row lemma: exhaustive check on all 512 accepting sets of a 3 x 3 grid
#eval
  ((Finset.univ : Finset (Fin 3 → Fin 3 → Bool)).filter (fun A =>
    decide (¬ (((Finset.univ.filter (fun p : Fin 3 × Fin 3 => A p.1 p.2 = true)).card : ℚ) / 9) / 2
      ≤ ((Finset.univ.filter (fun r : Fin 3 =>
            (((Finset.univ.filter (fun p : Fin 3 × Fin 3 => A p.1 p.2 = true)).card : ℚ) / 9) / 2
              ≤ ((Finset.univ.filter (fun c : Fin 3 => A r c = true)).card : ℚ) / 3)).card : ℚ)
          / 3))).card

-- rewinding threshold: accepting sets with fraction > 1/3 and no row containing
-- two accepting challenges
#eval
  ((Finset.univ : Finset (Fin 3 → Fin 3 → Bool)).filter (fun A =>
    decide ((1/3 : ℚ) < ((Finset.univ.filter (fun p : Fin 3 × Fin 3 => A p.1 p.2 = true)).card : ℚ) / 9
      ∧ (∀ r : Fin 3, (Finset.univ.filter (fun c : Fin 3 => A r c = true)).card ≤ 1)))).card

-- configurations attaining exactly 1/3 with no rewinding pair
#eval
  ((Finset.univ : Finset (Fin 3 → Fin 3 → Bool)).filter (fun A =>
    decide (((Finset.univ.filter (fun p : Fin 3 × Fin 3 => A p.1 p.2 = true)).card : ℚ) / 9 = (1/3 : ℚ)
      ∧ (∀ r : Fin 3, (Finset.univ.filter (fun c : Fin 3 => A r c = true)).card ≤ 1)))).card