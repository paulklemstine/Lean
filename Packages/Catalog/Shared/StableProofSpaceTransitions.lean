import Mathlib

/-!
# Stability of Critical Indices Under Bounded Recodings

This file develops an abstract sharp-transition theorem for real-valued order
parameters.  An antitone profile converging to zero has a unique last index at
or above every positive level that is attained initially.  Two such profiles
whose shifted values bound one another have critical indices differing by at
most the shift.  Thus a finite-distortion recoding cannot move a sharp
transition by more than its distortion bound.
-/

namespace ProofSpaceTransition

open Filter Topology

/-- An antitone profile converging to zero has a unique critical index at every
positive level below its initial value.  The profile is below the level exactly
after that index. -/
theorem exists_unique_criticalIndex
    (p : ℕ → ℝ) (ε : ℝ)
    (hp : Tendsto p atTop (𝓝 0))
    (hanti : Antitone p)
    (hε : 0 < ε) (hstart : ε ≤ p 0) :
    ∃! c : ℕ, ε ≤ p c ∧ p (c + 1) < ε ∧
      ∀ n, (p n < ε ↔ c < n) := by
  obtain ⟨c, hc⟩ : ∃ c, ε ≤ p c ∧ p (c + 1) < ε := by
    obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, p n < ε := by
      simpa using hp.eventually (gt_mem_nhds hε)
    contrapose! hN
    exact ⟨N, le_rfl, Nat.recOn N hstart fun n hn => hN n hn⟩
  refine ⟨c, ⟨hc.1, hc.2, fun n => ⟨fun hn => ?_, fun hn => ?_⟩⟩,
    fun n hn => ?_⟩
  · exact not_le.mp fun h => hn.not_ge (hc.1.trans (hanti h))
  · exact lt_of_le_of_lt (hanti hn) hc.2
  · grind +qlia

/-- If two profiles have exact critical-index classifications and each shifted
profile is bounded by the other, then their critical indices differ by at most
the shift. -/
theorem criticalIndices_close
    (p q : ℕ → ℝ) (ε : ℝ) (cp cq d : ℕ)
    (hp : ∀ n, p n < ε ↔ cp < n)
    (hq : ∀ n, q n < ε ↔ cq < n)
    (hpq : ∀ n, p (n + d) ≤ q n)
    (hqp : ∀ n, q (n + d) ≤ p n) :
    cp ≤ cq + d ∧ cq ≤ cp + d := by
  have h1 : q (cq + 1) < ε := (hq (cq + 1)).mpr (Nat.lt_succ_self cq)
  have h2 : p (cq + 1 + d) < ε := lt_of_le_of_lt (hpq (cq + 1)) h1
  have h3 : cp < cq + 1 + d := (hp _).mp h2
  have hp_cp1 : p (cp + 1) < ε := (hp _).mpr (Nat.lt_succ_self cp)
  have h4 : q (cp + 1 + d) < ε := lt_of_le_of_lt (hqp (cp + 1)) hp_cp1
  have h5 : cq < cp + 1 + d := (hq _).mp h4
  exact ⟨by linarith, by linarith⟩

/-- **Stable sharp transitions.** Two antitone order parameters converging to
zero, initially at or above a positive level, have unique critical indices.
If a shift by `d` in either profile is bounded by the other profile, then the
critical indices differ by at most `d`. -/
theorem stable_criticalIndices
    (p q : ℕ → ℝ) (ε : ℝ) (d : ℕ)
    (hp : Tendsto p atTop (𝓝 0))
    (hq : Tendsto q atTop (𝓝 0))
    (hpanti : Antitone p) (hqanti : Antitone q)
    (hε : 0 < ε) (hpstart : ε ≤ p 0) (hqstart : ε ≤ q 0)
    (hpq : ∀ n, p (n + d) ≤ q n)
    (hqp : ∀ n, q (n + d) ≤ p n) :
    ∃ cp cq : ℕ,
      (ε ≤ p cp ∧ p (cp + 1) < ε ∧
        ∀ n, (p n < ε ↔ cp < n)) ∧
      (ε ≤ q cq ∧ q (cq + 1) < ε ∧
        ∀ n, (q n < ε ↔ cq < n)) ∧
      cp ≤ cq + d ∧ cq ≤ cp + d := by
  obtain ⟨cp, hcp, -⟩ := exists_unique_criticalIndex p ε hp hpanti hε hpstart
  obtain ⟨cq, hcq, -⟩ := exists_unique_criticalIndex q ε hq hqanti hε hqstart
  exact ⟨cp, cq, hcp, hcq,
    criticalIndices_close p q ε cp cq d hcp.2.2 hcq.2.2 hpq hqp⟩

/-- With zero recoding distortion, the two critical indices coincide. -/
theorem criticalIndices_eq_of_mutual_bound
    (p q : ℕ → ℝ) (ε : ℝ) (cp cq : ℕ)
    (hp : ∀ n, p n < ε ↔ cp < n)
    (hq : ∀ n, q n < ε ↔ cq < n)
    (hpq : ∀ n, p n ≤ q n)
    (hqp : ∀ n, q n ≤ p n) :
    cp = cq := by
  have hpq_eq : ∀ n, p n = q n := fun n => le_antisymm (hpq n) (hqp n)
  suffices cp ≥ cq ∧ cq ≥ cp by exact le_antisymm this.2 this.1
  constructor
  · by_contra h
    push_neg at h
    have hpcq : p cq < ε := (hp cq).mpr h
    have hqce : ¬(q cq < ε) := by
      rw [hq]
      exact lt_irrefl cq
    linarith [hpq_eq cq]
  · by_contra h
    push_neg at h
    have hqcp : q cp < ε := (hq cp).mpr h
    have hpce : ¬(p cp < ε) := by
      rw [hp]
      exact lt_irrefl cp
    linarith [hpq_eq cp]

end ProofSpaceTransition