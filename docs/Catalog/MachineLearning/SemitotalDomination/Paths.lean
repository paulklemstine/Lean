import MachineLearning.SemitotalDomination.TotalBound

/-!
# Sandwiching the semitotal domination number of a path

The catalog file `Novelty/TransmissionDominationTree.lean` computes the domination number of the
path, `γ(Pₙ) = ⌈n/3⌉ = (n+2)/3` (natural division).  Combining this with the two universal
inequalities proved in this development,

* `γ ≤ γ_t2` (`dominationNumber_le_semitotalDominationNumber`) and
* `γ_t2 ≤ 2 γ` (`semitotalDominationNumber_le_two_mul_dominationNumber`),

gives explicit two-sided bounds for `γ_t2(Pₙ)`.  The conjectured exact value `max(2, ⌈2n/5⌉)`
(see `FUTURE_DIRECTIONS.md`) lies strictly inside this window for every `n ≥ 2`, and the verified
instance `γ_t2(P₇) = 3` (`Instances.lean`) is consistent with it: here the window is `[3, 6]`.
-/

namespace SemitotalDomination

open Finset SimpleGraph

/-- A path on at least two vertices has no isolated vertex. -/
theorem pathGraph_no_isolated {n : ℕ} (hn : 2 ≤ n) (v : Fin n) : ∃ u, (pathGraph n).Adj u v := by
  by_cases h0 : (v : ℕ) = 0
  · refine ⟨⟨1, by omega⟩, ?_⟩
    rw [pathGraph_adj]
    right
    simp [h0]
  · refine ⟨⟨(v : ℕ) - 1, by omega⟩, ?_⟩
    rw [pathGraph_adj]
    left
    simp
    omega

/-- Semitotal dominating sets exist in a path on at least two vertices. -/
theorem exists_semitotalDominatingSet_pathGraph {n : ℕ} (hn : 2 ≤ n) :
    ∃ S : Finset (Fin n), IsSemitotalDominatingSet (pathGraph n) S :=
  exists_semitotalDominatingSet (pathGraph_no_isolated hn)

/-- **Lower bound.**  `γ_t2(Pₙ) ≥ ⌈n/3⌉`. -/
theorem le_semitotalDominationNumber_pathGraph {n : ℕ} (hn : 2 ≤ n) :
    (n + 2) / 3 ≤ semitotalDominationNumber (pathGraph n) := by
  have h := dominationNumber_le_semitotalDominationNumber (exists_semitotalDominatingSet_pathGraph hn)
  rwa [dominationNumber_pathGraph_eq] at h

/-- **Upper bound.**  `γ_t2(Pₙ) ≤ 2⌈n/3⌉`. -/
theorem semitotalDominationNumber_pathGraph_le {n : ℕ} (hn : 2 ≤ n) :
    semitotalDominationNumber (pathGraph n) ≤ 2 * ((n + 2) / 3) := by
  classical
  have h := semitotalDominationNumber_le_two_mul_dominationNumber
    (G := pathGraph n) (pathGraph_no_isolated hn)
  rwa [dominationNumber_pathGraph_eq] at h

/-- **Two-sided bounds for the path.** -/
theorem semitotalDominationNumber_pathGraph_bounds {n : ℕ} (hn : 2 ≤ n) :
    (n + 2) / 3 ≤ semitotalDominationNumber (pathGraph n) ∧
      semitotalDominationNumber (pathGraph n) ≤ 2 * ((n + 2) / 3) :=
  ⟨le_semitotalDominationNumber_pathGraph hn, semitotalDominationNumber_pathGraph_le hn⟩

/-- The window is nontrivial: it grows linearly in `n`, and for `n = 7` it is `[3, 6]`, which
contains the verified exact value `3`. -/
example : (7 + 2) / 3 = 3 ∧ 2 * ((7 + 2) / 3) = 6 := by norm_num

end SemitotalDomination