/-
# Computational evidence for the Fermi–pigeonhole estimates

A rational-arithmetic mirror of the model of `Pythagorean.FermiPigeonhole.Model`,
small enough to enumerate the whole sample space `(Fin N → Option (Fin T))`
exactly.  Every `#eval` below is an exact computation in `ℚ`; the numbers are
reproduced and discussed in `ComputationalEvidence.md`.

Checks performed:
* total mass is exactly `1` (normalisation, `prb_univ`);
* exact contact probability versus the proved bound `(N ^ 2 - N) * p ^ 2 / T`
  (`prb_contact_le`) — the bound holds in every case, with the expected factor
  `2` of slack coming from counting ordered pairs;
* exact contact probability decays like `1 / T` as the number of epochs grows;
* exact probability of a lifeless cosmos equals `(1 - p) ^ N` (`prb_lifeless`) and
  exceeds `1 - N * p` (`prb_lifeless_ge`);
* exact probability that somebody exists lies between `N p - (N p) ^ 2 / 2` and
  `N p` (`prb_exists_civ_ge`, `prb_exists_civ_le`);
* exact expected number of empty epochs exceeds `T - N * p`
  (`expected_empty_epochs_ge`).
-/
import Mathlib

namespace Pythagorean.FermiPigeonhole.Evidence

open Finset

/-- Rational local weight of a single site. -/
def swQ (T : ℕ) (p : ℚ) : Option (Fin T) → ℚ
  | none => 1 - p
  | some _ => p / T

/-- Rational weight of an elementary outcome. -/
def wtQ (N T : ℕ) (p : ℚ) (f : Fin N → Option (Fin T)) : ℚ := ∏ i, swQ T p (f i)

/-- Rational probability of a decidable event. -/
def probQ (N T : ℕ) (p : ℚ) (A : (Fin N → Option (Fin T)) → Bool) : ℚ :=
  ∑ f : Fin N → Option (Fin T), if A f then wtQ N T p f else 0

def contactB (N T : ℕ) (f : Fin N → Option (Fin T)) : Bool :=
  decide (∃ i : Fin N, ∃ j : Fin N, i ≠ j ∧ f i = f j ∧ f i ≠ none)

def lifelessB (N T : ℕ) (f : Fin N → Option (Fin T)) : Bool := decide (∀ i, f i = none)

def someoneB (N T : ℕ) (f : Fin N → Option (Fin T)) : Bool := decide (∃ i, f i ≠ none)

def emptyEpochCount (N T : ℕ) (f : Fin N → Option (Fin T)) : ℕ :=
  {e ∈ (Finset.univ : Finset (Fin T)) | ∀ i, f i ≠ some e}.card

def expEmptyQ (N T : ℕ) (p : ℚ) : ℚ :=
  ∑ f : Fin N → Option (Fin T), wtQ N T p f * (emptyEpochCount N T f : ℚ)

/- Normalisation: total mass is exactly `1`.  Prints `(1, 1)`. -/
#eval (probQ 3 2 (1/5) (fun _ => true), probQ 4 3 (1/10) (fun _ => true))

/- Exact contact probability versus the proved bound `(N ^ 2 - N) * p ^ 2 / T`.
Prints `(7/125, 3/25)` and `(191/10000, 1/25)`. -/
#eval (probQ 3 2 (1/5) (contactB 3 2), ((3 ^ 2 - 3 : ℚ) * (1/5) ^ 2 / 2))
#eval (probQ 4 3 (1/10) (contactB 4 3), ((4 ^ 2 - 4 : ℚ) * (1/10) ^ 2 / 3))

/- Contact probability decays like `1 / T`: prints `(7/125, 43/1125, 29/1000)`,
i.e. `0.0560, 0.0382, 0.0290` for `T = 2, 3, 4`. -/
#eval (probQ 3 2 (1/5) (contactB 3 2), probQ 3 3 (1/5) (contactB 3 3),
  probQ 3 4 (1/5) (contactB 3 4))

/- Lifeless probability equals `(1 - p) ^ N` and exceeds `1 - N * p`.
Prints `(64/125, 64/125, 2/5)`. -/
#eval (probQ 3 2 (1/5) (lifelessB 3 2), (1 - (1:ℚ)/5) ^ 3, 1 - (3:ℚ) * (1/5))

/- Somebody exists: exact value, first-moment upper bound `N p`, Bonferroni lower
bound `N p - (N p) ^ 2 / 2`.  Prints `(3439/10000, 2/5, 8/25)`. -/
#eval (probQ 4 3 (1/10) (someoneB 4 3), (4:ℚ) * (1/10),
  (4:ℚ) * (1/10) - ((4:ℚ) * (1/10)) ^ 2 / 2)

/- Expected number of empty epochs versus the proved bound `T - N * p`.
Prints `(729/500, 7/5)` and `(707281/270000, 13/5)`. -/
#eval (expEmptyQ 3 2 (1/5), 2 - (3:ℚ) * (1/5))
#eval (expEmptyQ 4 3 (1/10), 3 - (4:ℚ) * (1/10))

/- Sharpness probe: for `N = 2` the union bound over *ordered* pairs loses exactly
a factor `2`.  Prints `(1/20, 1/10)`. -/
#eval (probQ 2 5 (1/2) (contactB 2 5), ((2 ^ 2 - 2 : ℚ) * (1/2) ^ 2 / 5))

end Pythagorean.FermiPigeonhole.Evidence