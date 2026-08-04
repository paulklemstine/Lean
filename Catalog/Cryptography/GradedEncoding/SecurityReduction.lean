import Cryptography.GradedEncoding.Foundations
import Cryptography.LWE.OperationalSecurity

/-!
# Security reductions for multilinear graded encodings

The reduction layer is independent of any particular graded-encoding candidate.
A decisional multilinear Diffie--Hellman game is represented by its two finite
transcript distributions. A perfect reduction is an equivalence of transcript
spaces preserving both distributions pointwise. The main theorem proves exact
preservation of every deterministic distinguisher's advantage and transfers any
source hardness bound to the graded target game.
-/

open Finset

noncomputable section

namespace Cryptography.GradedEncoding

/-- A finite two-world decisional game. `false` is the random world and `true`
is the real multilinear Diffie--Hellman world. -/
structure DecisionGame (Ω : Type*) [Fintype Ω] where
  experiment : LWEOperational.EncryptionExperiment Ω

namespace DecisionGame

variable {Ω : Type*} [Fintype Ω]

/-- Acceptance probability of a deterministic distinguisher in one world. -/
def acceptance (G : DecisionGame Ω) (b : Bool) (A : Ω → Bool) : ℝ :=
  ∑ x with A x = true, (G.experiment.challenge b).mass x

/-- Absolute distinguishing advantage. -/
def advantage (G : DecisionGame Ω) (A : Ω → Bool) : ℝ :=
  |G.acceptance true A - G.acceptance false A|

/-- Advantage is unchanged when the two challenge worlds are interchanged. -/
theorem advantage_swap (G : DecisionGame Ω) (A : Ω → Bool) :
    |G.acceptance false A - G.acceptance true A| = G.advantage A := by
  exact abs_sub_comm _ _

end DecisionGame

variable {Source Target : Type*} [Fintype Source] [Fintype Target]

/-- A perfect, lossless reduction between finite decisional games. The transcript
equivalence is executable, while `mass_preserving` states exact simulation of
both challenge worlds. -/
structure PerfectReduction (source : DecisionGame Source)
    (target : DecisionGame Target) where
  transcriptEquiv : Source ≃ Target
  mass_preserving : ∀ (b : Bool) (x : Source),
    (target.experiment.challenge b).mass (transcriptEquiv x) =
      (source.experiment.challenge b).mass x

namespace PerfectReduction

variable {source : DecisionGame Source} {target : DecisionGame Target}

/-- Turn a target-game distinguisher into a source-game distinguisher. -/
def reduce (red : PerfectReduction source target) (A : Target → Bool) : Source → Bool :=
  A ∘ red.transcriptEquiv

/-- Perfect simulation preserves acceptance probability in each challenge world. -/
theorem acceptance_eq (red : PerfectReduction source target)
    (A : Target → Bool) (b : Bool) :
    source.acceptance b (red.reduce A) = target.acceptance b A := by
  rw [DecisionGame.acceptance, DecisionGame.acceptance]
  simp only [Finset.sum_filter]
  rw [← Equiv.sum_comp red.transcriptEquiv
    (fun y => if A y = true then (target.experiment.challenge b).mass y else 0)]
  apply Finset.sum_congr rfl
  intro x _
  simp only [reduce, Function.comp_apply]
  split_ifs with h
  · rw [red.mass_preserving]
  · rfl

/-- **Exact reduction theorem.** Every target distinguisher has exactly the same
advantage after reduction to the source multilinear Diffie--Hellman game. -/
theorem advantage_eq (red : PerfectReduction source target) (A : Target → Bool) :
    source.advantage (red.reduce A) = target.advantage A := by
  simp only [DecisionGame.advantage]
  rw [red.acceptance_eq A true, red.acceptance_eq A false]

/-- **Multilinear Diffie--Hellman hardness transfer.** If all source-game
adversaries have advantage at most `ε`, then all target graded-encoding
adversaries do as well. -/
theorem hardness_transfer (red : PerfectReduction source target) (ε : ℝ)
    (sourceHard : ∀ B : Source → Bool, source.advantage B ≤ ε) :
    ∀ A : Target → Bool, target.advantage A ≤ ε := by
  intro A
  rw [← red.advantage_eq A]
  exact sourceHard (red.reduce A)

/-- A strict target-game advantage yields a strict source-game advantage, the
contrapositive form used to turn an attack into an MDH solver. -/
theorem attack_to_source (red : PerfectReduction source target) (ε : ℝ)
    (A : Target → Bool) (attack : ε < target.advantage A) :
    ε < source.advantage (red.reduce A) := by
  rwa [red.advantage_eq A]

end PerfectReduction

namespace DecisionGame

/-- **Approximate game-hop theorem.** If corresponding worlds of two games are
within `δfalse` and `δtrue` in `ℓ¹` distance, then every deterministic
adversary's target advantage is at most its source advantage plus those two
simulation errors. -/
theorem advantage_le_of_world_gaps {Ω : Type*} [Fintype Ω]
    (source target : DecisionGame Ω) (A : Ω → Bool) (δfalse δtrue : ℝ)
    (hfalse : LWEOperational.l1Gap
      (target.experiment.challenge false)
      (source.experiment.challenge false) ≤ δfalse)
    (htrue : LWEOperational.l1Gap
      (target.experiment.challenge true)
      (source.experiment.challenge true) ≤ δtrue) :
    target.advantage A ≤ source.advantage A + δfalse + δtrue := by
  have hf := LWEOperational.boolean_distinguisher_advantage
    (target.experiment.challenge false)
    (source.experiment.challenge false) A
  have ht := LWEOperational.boolean_distinguisher_advantage
    (target.experiment.challenge true)
    (source.experiment.challenge true) A
  have htriangle :
      |target.acceptance true A - target.acceptance false A| ≤
        |source.acceptance true A - source.acceptance false A| +
        |target.acceptance false A - source.acceptance false A| +
        |target.acceptance true A - source.acceptance true A| := by
    calc
      |target.acceptance true A - target.acceptance false A| =
          |(source.acceptance true A - source.acceptance false A) +
            (target.acceptance true A - source.acceptance true A) +
            (source.acceptance false A - target.acceptance false A)| := by
              congr 1
              ring
      _ ≤ |source.acceptance true A - source.acceptance false A| +
            |target.acceptance true A - source.acceptance true A| +
            |source.acceptance false A - target.acceptance false A| :=
              abs_add_three _ _ _
      _ = |source.acceptance true A - source.acceptance false A| +
            |target.acceptance false A - source.acceptance false A| +
            |target.acceptance true A - source.acceptance true A| := by
              rw [abs_sub_comm (source.acceptance false A)]
              ring
  simp only [advantage, acceptance] at htriangle ⊢
  exact htriangle.trans (by linarith [hf.trans hfalse, ht.trans htrue])

/-- Hardness therefore transfers through an approximate simulator with additive
loss equal to the sum of its two world-simulation errors. -/
theorem approximate_hardness_transfer {Ω : Type*} [Fintype Ω]
    (source target : DecisionGame Ω) (ε δfalse δtrue : ℝ)
    (sourceHard : ∀ A : Ω → Bool, source.advantage A ≤ ε)
    (hfalse : LWEOperational.l1Gap
      (target.experiment.challenge false)
      (source.experiment.challenge false) ≤ δfalse)
    (htrue : LWEOperational.l1Gap
      (target.experiment.challenge true)
      (source.experiment.challenge true) ≤ δtrue) :
    ∀ A : Ω → Bool, target.advantage A ≤ ε + δfalse + δtrue := by
  intro A
  exact (advantage_le_of_world_gaps source target A δfalse δtrue hfalse htrue).trans
    (by linarith [sourceHard A])

end DecisionGame
end Cryptography.GradedEncoding

end