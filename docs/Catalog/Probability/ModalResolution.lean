/-
# Semantic resolution: what probabilistic modal truth can and cannot recover

This file settles, inside the framework of `Probability/QuantitativeCopycat.lean`,
the two halves of the "definability boundary" question for probabilistic modal
observations.

**Negative half (`resolution_gap`).** There are two probabilistic transition systems
on the same two-world state space — the identity system (two self-loops) and the
swap system (one 2-cycle) — with identical atomic valuations, such that *every*
probabilistic modal formula has the same truth probability at every world of both
systems, and yet there is **no** exact structural analogy between them (not even an
approximate one with defect `< 1`). So modal truth-probability equivalence is
strictly weaker than structural analogy: transport (`transport_le`) has no converse.

**Positive half (`nominal_depth_one_recovers`).** If the observational language is
enriched with *nominals* (one atom per world, true exactly at that world), then
agreement of the depth-`1` fragment alone already forces the candidate renaming to
be an exact structural analogy — the entire transition structure is recovered at
modal depth `1`, far below the "number of worlds" depth that a naive characteristic
formula construction would suggest.

Together these delimit exactly how much observational power is needed: the gap is
closed by world-identifying (multiplicity-sensitive) atoms, and once closed it is
closed at depth one.
-/
import Probability.QuantitativeCopycat

namespace Catalog.Probability.QuantitativeCopycat

open Finset

namespace Resolution

/-! ## Two modally indistinguishable, non-analogous systems -/

/-- Two worlds, each with a self-loop; all atoms are true. -/
def idSys (ι : Type*) : PModalStructure ι Bool where
  step s t := if s = t then 1 else 0
  step_nonneg s t := by split <;> norm_num
  step_sum s := by simp
  val _ _ := 1
  val_nonneg _ _ := by norm_num
  val_le_one _ _ := le_rfl

/-- Two worlds forming a 2-cycle; all atoms are true. -/
def swapSys (ι : Type*) : PModalStructure ι Bool where
  step s t := if s = t then 0 else 1
  step_nonneg s t := by split <;> norm_num
  step_sum s := by cases s <;> simp
  val _ _ := 1
  val_nonneg _ _ := by norm_num
  val_le_one _ _ := le_rfl

variable {ι : Type*}

@[simp] theorem idSys_step (s t : Bool) :
    (idSys ι).step s t = if s = t then 1 else 0 := rfl

@[simp] theorem swapSys_step (s t : Bool) :
    (swapSys ι).step s t = if s = t then 0 else 1 := rfl

@[simp] theorem idSys_val (p : ι) (s : Bool) : (idSys ι).val p s = 1 := rfl

@[simp] theorem swapSys_val (p : ι) (s : Bool) : (swapSys ι).val p s = 1 := rfl

/-- Every formula has one and the same truth probability at every world of both
systems: the two systems are observationally identical. -/
theorem eval_const (φ : PForm ι) :
    ∃ c : ℝ, (∀ s, (idSys ι).eval φ s = c) ∧ (∀ s, (swapSys ι).eval φ s = c) := by
  induction φ with
  | atom p => exact ⟨1, fun s => rfl, fun s => rfl⟩
  | neg φ ih =>
      obtain ⟨c, h1, h2⟩ := ih
      exact ⟨1 - c, fun s => by simp [h1 s], fun s => by simp [h2 s]⟩
  | conj φ ψ ihφ ihψ =>
      obtain ⟨c, h1, h2⟩ := ihφ
      obtain ⟨d, k1, k2⟩ := ihψ
      exact ⟨min c d, fun s => by simp [h1 s, k1 s], fun s => by simp [h2 s, k2 s]⟩
  | next φ ih =>
      obtain ⟨c, h1, h2⟩ := ih
      refine ⟨c, fun s => ?_, fun s => ?_⟩
      · simp only [PModalStructure.eval_next, h1]
        rw [← Finset.sum_mul, (idSys ι).step_sum s, one_mul]
      · simp only [PModalStructure.eval_next, h2]
        rw [← Finset.sum_mul, (swapSys ι).step_sum s, one_mul]

/-- Modal indistinguishability of the identity and swap systems. -/
theorem modal_equiv (φ : PForm ι) (s t : Bool) :
    (idSys ι).eval φ s = (swapSys ι).eval φ t := by
  obtain ⟨c, h1, h2⟩ := eval_const (ι := ι) φ
  rw [h1 s, h2 t]

/-- Yet no approximate structural analogy with defect `< 1` relates them: the two
systems are structurally different (two self-loops versus one 2-cycle). -/
theorem no_analogy {ε : ℝ} (hε : ε < 1) (A : ApproxAnalogy (idSys ι) (swapSys ι) ε) :
    False := by
  have h := A.defect true
  have hz : ∑ t, min ((idSys ι).step true t)
      ((swapSys ι).step (A.toEquiv true) (A.toEquiv t)) = 0 := by
    refine Finset.sum_eq_zero fun t _ => ?_
    rcases Bool.eq_false_or_eq_true t with rfl | rfl
    · simp
    · simp
  rw [hz] at h
  linarith

/-- **Resolution gap.** Probabilistic modal truth does not determine structure:
the identity and swap systems are modally identical but admit no structural
analogy, approximate or exact. -/
theorem resolution_gap (ι : Type*) :
    (∀ (φ : PForm ι) (s t : Bool), (idSys ι).eval φ s = (swapSys ι).eval φ t) ∧
      IsEmpty (ApproxAnalogy (idSys ι) (swapSys ι) 0) :=
  ⟨modal_equiv, ⟨fun A => no_analogy (by norm_num) A⟩⟩

/-! ## Nominals close the gap at modal depth one -/

variable {S S' : Type*} [Fintype S] [Fintype S'] [DecidableEq S] [DecidableEq S']

/-- A *nominal* structure over the atom set `S`: the atom `u` is true exactly at the
world `κ u`, for a fixed injective naming `κ`. -/
def IsNominal (M : PModalStructure S S') (κ : S ≃ S') : Prop :=
  ∀ u v, M.val u v = if v = κ u then 1 else 0

omit [Fintype S] [DecidableEq S] in
/-- Depth-one truth probabilities in a nominal structure read off the kernel. -/
theorem eval_next_atom (M : PModalStructure S S') (κ : S ≃ S')
    (hM : IsNominal M κ) (u t : S) :
    M.eval (.next (.atom t)) (κ u) = M.step (κ u) (κ t) := by
  have hv : ∀ b, M.val t b = if b = κ t then 1 else 0 := fun b => hM t b
  simp only [PModalStructure.eval_next, PModalStructure.eval_atom]
  rw [Finset.sum_eq_single (κ t)]
  · rw [hv]; simp
  · intro b _ hb; rw [hv b]; simp [hb]
  · intro h; exact absurd (Finset.mem_univ (κ t)) h

/-- **Nominals recover structure at depth one.** If two nominal structures assign
the same truth probabilities to all formulas of modal depth `1`, then the naming
bijection is an *exact* structural analogy: the whole transition structure is
determined by the depth-one fragment. -/
def nominal_depth_one_recovers (M : PModalStructure S S) (N : PModalStructure S S')
    (κ : S ≃ S') (hM : IsNominal M (Equiv.refl S)) (hN : IsNominal N κ)
    (hagree : ∀ t u : S, M.eval (.next (.atom t)) u = N.eval (.next (.atom t)) (κ u)) :
    ApproxAnalogy M N 0 where
  toEquiv := κ
  atoms p s := by
    rw [hN p (κ s), hM p s]
    simp
  defect s := by
    have hstep : ∀ t, N.step (κ s) (κ t) = M.step s t := by
      intro t
      have h1 : M.eval (.next (.atom t)) s = M.step s t := by
        have := eval_next_atom M (Equiv.refl S) hM s t
        simpa using this
      have h2 : N.eval (.next (.atom t)) (κ s) = N.step (κ s) (κ t) :=
        eval_next_atom N κ hN s t
      rw [← h2, ← hagree t s, h1]
    have : ∑ t, min (M.step s t) (N.step (κ s) (κ t)) = 1 := by
      simp only [hstep, min_self]
      exact M.step_sum s
    rw [this]
    norm_num

/-- Consequence: with nominals, depth-one agreement upgrades to agreement on *all*
formulas (exact transport), so the observational cost of recovering a finite
probabilistic structure is a single modality. -/
theorem nominal_depth_one_transport (M : PModalStructure S S) (N : PModalStructure S S')
    (κ : S ≃ S') (hM : IsNominal M (Equiv.refl S)) (hN : IsNominal N κ)
    (hagree : ∀ t u : S, M.eval (.next (.atom t)) u = N.eval (.next (.atom t)) (κ u))
    (φ : PForm S) (s : S) :
    M.eval φ s = N.eval φ (κ s) :=
  M.transport_exact N (nominal_depth_one_recovers M N κ hM hN hagree) φ s

end Resolution

end Catalog.Probability.QuantitativeCopycat