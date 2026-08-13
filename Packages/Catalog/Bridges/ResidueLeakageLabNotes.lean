/-
# Lab notes: machine-checked instances of the residue-leakage theorems

Companion to `Bridges.ResidueLeakageDirichletNoPruning` and
`Bridges.ResidueLeakagePatternSurjectivity`.  Everything below is *checked by
the kernel* through the `norm_num` extension for Jacobi symbols — no
`native_decide`, no appeal to an external computation.

Probe basis: the first `K = 5` primes `A₅ = [2,3,5,7,11]`, conductor
`4 · 2·3·5·7·11 = 9240`.

Target: `N₀ = 1591 = 37 · 43`, fingerprint `F(N₀) = [1,-1,1,-1,1]`.

* `qrLab_target` : the fingerprint of the target.
* `qrLab_periodicity` : `F(N₀ + 9240) = F(N₀)` — the conductor really is `9240`.
* `qrLab_compensators` : for each of the twelve candidate primes
  `13,17,…,59` an explicit compensating prime `q` with `F(p·q) = F(N₀)`;
  this is the finite shadow of `dirichlet_no_pruning`.
* `qrLab_all_32_patterns` : thirty-two explicit primes whose fingerprints are
  pairwise distinct, hence realise **all** `2^5 = 32` sign patterns; the finite
  shadow of `qrFingerprint_pattern_surjective`.
-/

import Mathlib
import Bridges.ResidueLeakageDirichletNoPruning
import Bridges.ResidueLeakagePatternSurjectivity
import Bridges.ResidueLeakageBoundary

namespace Bridges.ResidueLeakage.LabNotes

open Bridges.ResidueLeakage

/-- The first five primes. -/
def A₅ : List ℕ := [2, 3, 5, 7, 11]

theorem A₅_prime : ∀ a ∈ A₅, a.Prime := by
  intro a ha
  fin_cases ha <;> norm_num

theorem A₅_nodup : A₅.Nodup := by decide

theorem A₅_conductor : qrConductor A₅ = 9240 := by
  norm_num [qrConductor, A₅]

/-- The observed target: `N₀ = 1591 = 37·43`. -/
theorem qrLab_target : qrFingerprint A₅ 1591 = [1, -1, 1, -1, 1] := by
  norm_num [qrFingerprint, A₅]

theorem qrLab_target_semiprime : (1591 : ℕ) = 37 * 43 ∧ Nat.Prime 37 ∧ Nat.Prime 43 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- Periodicity with the predicted conductor `9240`. -/
theorem qrLab_periodicity : qrFingerprint A₅ (1591 + 9240) = qrFingerprint A₅ 1591 := by
  norm_num [qrFingerprint, A₅]

/-- **No pruning, concretely.**  For every candidate prime `p` between `13` and
`59` an explicit compensating prime `q` makes `p·q` fingerprint-indistinguishable
from `N₀ = 1591`; in particular no such `p` can be discarded. -/
theorem qrLab_compensators :
    qrFingerprint A₅ (13 * 197) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (17 * 47) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (19 * 181) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (23 * 103) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (29 * 61) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (31 * 71) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (37 * 43) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (41 * 311) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (47 * 17) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (53 * 107) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (59 * 101) = qrFingerprint A₅ 1591 ∧
    qrFingerprint A₅ (3607 * 167) = qrFingerprint A₅ 1591 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [qrFingerprint, A₅]

/-- Thirty-two primes, one for each sign pattern. -/
def patternWitnesses : List ℕ :=
  [53, 17, 277, 181, 67, 311, 41, 107, 71, 79, 61, 113, 101, 271, 37, 59,
   197, 47, 211, 239, 103, 127, 167, 19, 23, 131, 97, 43, 13, 31, 29, 479]

/-- Their fingerprints. -/
def patternValues : List (List ℤ) :=
  [[-1, -1, -1, 1, 1], [1, -1, -1, -1, -1], [-1, 1, -1, 1, -1], [-1, 1, 1, -1, 1],
   [-1, -1, -1, -1, -1], [1, 1, 1, 1, -1], [1, -1, 1, -1, -1], [-1, 1, -1, -1, 1],
   [1, 1, 1, -1, -1], [1, -1, 1, -1, 1], [-1, 1, 1, -1, -1], [1, -1, -1, 1, 1],
   [-1, -1, 1, -1, -1], [1, -1, 1, 1, 1], [-1, 1, -1, 1, 1], [-1, 1, 1, 1, -1],
   [-1, -1, -1, 1, -1], [1, 1, -1, 1, -1], [-1, -1, 1, -1, 1], [1, 1, 1, -1, 1],
   [1, -1, -1, 1, -1], [1, -1, -1, -1, 1], [1, 1, -1, 1, 1], [-1, -1, 1, 1, 1],
   [1, 1, -1, -1, -1], [-1, 1, 1, 1, 1], [1, 1, -1, -1, 1], [-1, -1, -1, -1, 1],
   [-1, 1, -1, -1, -1], [1, -1, 1, 1, -1], [-1, -1, 1, 1, -1], [1, 1, 1, 1, 1]]

theorem qrLab_pattern_values :
    patternWitnesses.map (qrFingerprint A₅) = patternValues := by
  norm_num [patternWitnesses, patternValues, qrFingerprint, A₅]

/-- **All `2^5 = 32` fingerprints occur among the primes.**  The thirty-two
witnesses have pairwise distinct fingerprints, and there are only `32`
`±1`-vectors of length `5`, so the fingerprint map on primes is onto. -/
theorem qrLab_all_32_patterns :
    (patternWitnesses.map (qrFingerprint A₅)).length = 32 ∧
    (patternWitnesses.map (qrFingerprint A₅)).Nodup ∧
    ∀ v ∈ patternWitnesses.map (qrFingerprint A₅),
      v.length = 5 ∧ ∀ x ∈ v, x = 1 ∨ x = -1 := by
  rw [qrLab_pattern_values]
  refine ⟨by decide, by decide, by decide⟩

/-- **The fingerprint is not a hash.**  The prime `79` and the semiprime
`1591 = 37·43` share a fingerprint although they are not even congruent modulo
the conductor `9240`: the fingerprint sees only the square class. -/
theorem qrLab_collision :
    Nat.Prime 79 ∧ qrFingerprint A₅ 79 = qrFingerprint A₅ 1591 ∧
      ¬ (79 ≡ 1591 [MOD 9240]) := by
  refine ⟨by norm_num, by norm_num [qrFingerprint, A₅], ?_⟩
  intro h
  have : (79 : ℕ) % 9240 = 1591 % 9240 := h
  norm_num at this

/-- Square-class invariance in action: multiplying the target by `13²` leaves
the fingerprint unchanged. -/
theorem qrLab_square_class :
    qrFingerprint A₅ (1591 * 13 ^ 2) = qrFingerprint A₅ 1591 :=
  qrFingerprint_mul_sq A₅_prime (by norm_num) (by norm_num)
    (by intro a ha; fin_cases ha <;> norm_num)

end Bridges.ResidueLeakage.LabNotes