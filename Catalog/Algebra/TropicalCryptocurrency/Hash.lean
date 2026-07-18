import Mathlib

/-!
# Tropical Cryptocurrency: Exact Preimages and Universal Collisions

For a nonempty finite message vector, the min-plus hash is
`min i, (m i + h i)`.  The results below test two proposed security claims.
The first hash has an explicit preimage for every output.  More strongly, adding
one coordinate while retaining a different minimizing coordinate preserves the
hash.  Applying this observation to both components proves that every two-key
hash in dimension at least three has a collision, for every pair of keys and
every starting message.

The target serves the cross-domain category: finite min-plus algebra is connected
to preimage search, collision resistance, and optimization certificates.

-- !-- Lab Notes -- !--
Hypothesis: Seven falsifiable targets were ranked by expected impact: (1) a
nonce-constrained tropical inversion problem is NP-complete (P versus NP
subtask); (2) bounded-alphabet inversion has a sharp complexity transition (P
versus NP subtask); (3) nonlinear tropical circuits yield average-case one-way
families (P versus NP subtask); (4) approximation of constrained inversion has a
hardness threshold (P versus NP subtask); (5) two independent linear tropical
keys are collision-resistant (algebra--cryptography bridge); (6) hash fibers are
polyhedral complexes (algebra--geometry bridge); and (7) tropical mining is
equivalent to shortest-path search (algebra--optimization bridge).
Experiment: The unrestricted fiber equation underlying targets (5) and (7) was
reduced to coordinate inequalities plus one active equality.  A canonical
preimage was then constructed.  For two keys, a minimizing coordinate was
selected for each component and a third coordinate was increased.
Analysis: Preimage search does not encode a shortest-path problem in this model:
`m i = y - h i` is an explicit preimage.  Two keys do not repair collisions.
Each component needs only one unchanged minimizer, so two components protect at
most two coordinates.
Critique: The collision theorem is deterministic, not probabilistic, and permits
unrestricted real messages.  Bounded alphabets or nonce-constrained message
families could behave differently and require separate analysis.  The theorem
does not assert a computational lower bound; it establishes algebraic
non-injectivity directly.
Synthesis: Tropical fibers admit exact certificates, every output is attained,
and an r-component min-plus hash remains universally collision-prone whenever
there is a coordinate outside the chosen r minimizers.  The two-component case
is proved here for all dimensions at least three.
-- !-- end Lab Notes -- !--
-/

noncomputable section

namespace TropicalCryptocurrency

/-- The min-plus hash of a finite real message under a real key. -/
def tsha {k : ℕ} [Nonempty (Fin k)] (h m : Fin k → ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (fun i => m i + h i)

/-- The two-key min-plus hash. -/
def tsha2 {k : ℕ} [Nonempty (Fin k)] (h h' m : Fin k → ℝ) : ℝ × ℝ :=
  (tsha h m, tsha h' m)

/-- Every coordinate sum bounds the hash from above. -/
lemma tsha_le_coordinate {k : ℕ} [Nonempty (Fin k)] (h m : Fin k → ℝ) (i : Fin k) :
    tsha h m ≤ m i + h i := by
  exact Finset.inf'_le _ ( Finset.mem_univ i )

/-- A finite tropical hash is attained at some coordinate. -/
lemma exists_coordinate_eq_tsha {k : ℕ} [Nonempty (Fin k)] (h m : Fin k → ℝ) :
    ∃ i, m i + h i = tsha h m := by
  exact Exists.elim ( Finset.exists_mem_eq_inf' Finset.univ_nonempty fun i => m i + h i ) fun i hi => ⟨ i, hi.2.symm ⟩

/-- Exact fiber certificate: all coordinate sums lie above the output and at
least one coordinate sum attains it. -/
theorem tsha_eq_iff {k : ℕ} [Nonempty (Fin k)] (h m : Fin k → ℝ) (y : ℝ) :
    tsha h m = y ↔ (∀ i, y ≤ m i + h i) ∧ (∃ i, m i + h i = y) := by
  refine ⟨ fun hy ↦ ⟨ fun i ↦ ?_, ?_ ⟩, fun ⟨ hy₁, hy₂ ⟩ ↦ ?_ ⟩;
  · exact hy ▸ tsha_le_coordinate h m i;
  · exact hy ▸ exists_coordinate_eq_tsha h m;
  · obtain ⟨ i, hi ⟩ := hy₂;
    exact le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ i ) |> le_trans <| by linarith ) ( Finset.le_inf' _ _ fun j hj => hy₁ j )

/-- The coordinatewise residual `y - h i` is an explicit preimage of `y`. -/
theorem tsha_canonical_preimage {k : ℕ} [Nonempty (Fin k)] (h : Fin k → ℝ) (y : ℝ) :
    tsha h (fun i => y - h i) = y := by
  unfold tsha;
  aesop

/-- Consequently, every real output has a tropical preimage. -/
theorem tsha_surjective {k : ℕ} [Nonempty (Fin k)] (h : Fin k → ℝ) :
    Function.Surjective (tsha h) := by
  intro y
  use fun i => y - h i
  simp [tsha]

/-- Increasing one coordinate preserves the hash whenever a different
coordinate is known to attain the minimum. -/
lemma tsha_update_of_other_minimizer {k : ℕ} [Nonempty (Fin k)]
    (h m : Fin k → ℝ) (p q : Fin k) (hpq : p ≠ q)
    (hp : m p + h p = tsha h m) (d : ℝ) (hd : 0 ≤ d) :
    tsha h (Function.update m q (m q + d)) = tsha h m := by
  refine' le_antisymm _ _;
  · convert tsha_le_coordinate _ _ p using 1 ; aesop;
  · refine' Finset.le_inf' _ _ _;
    intro i hi; by_cases hi' : i = q <;> simp_all +decide [ Function.update_apply ] ;
    · linarith [ tsha_le_coordinate h m q ];
    · exact Finset.inf'_le _ ( Finset.mem_univ _ )

/-- In a finite index set of cardinality at least three, one can avoid any two
specified coordinates. -/
lemma exists_fin_ne_two {k : ℕ} (hk : 3 ≤ k) (p r : Fin k) :
    ∃ q : Fin k, q ≠ p ∧ q ≠ r := by
  exact Exists.imp ( by aesop ) ( Finset.exists_mem_ne ( show 1 < Finset.card ( Finset.univ.erase p ) from by rw [ Finset.card_erase_of_mem ( Finset.mem_univ p ), Finset.card_fin ] ; exact Nat.lt_pred_iff.mpr hk ) r )

/-- **Universal two-key collision theorem.** In dimension at least three, every
message and every pair of keys has a distinct message with exactly the same
`TSHA2` value. -/
theorem tsha2_universal_collision {k : ℕ} [Nonempty (Fin k)] (hk : 3 ≤ k)
    (h h' m : Fin k → ℝ) :
    ∃ m' : Fin k → ℝ, m' ≠ m ∧ tsha2 h h' m' = tsha2 h h' m := by
  obtain ⟨ p, hp ⟩ := exists_coordinate_eq_tsha h m;
  obtain ⟨ r, hr ⟩ := exists_coordinate_eq_tsha h' m;
  obtain ⟨ q, hq ⟩ := exists_fin_ne_two hk p r;
  refine' ⟨ Function.update m q ( m q + 1 ), _, _ ⟩ <;> simp_all +decide;

  have h_tsha_update : tsha h (Function.update m q (m q + 1)) = tsha h m ∧ tsha h' (Function.update m q (m q + 1)) = tsha h' m := by
    exact ⟨ tsha_update_of_other_minimizer h m p q ( by tauto ) hp 1 ( by norm_num ), tsha_update_of_other_minimizer h' m r q ( by tauto ) hr 1 ( by norm_num ) ⟩;
  exact Prod.ext h_tsha_update.1 h_tsha_update.2

end TropicalCryptocurrency