import Mathlib

/-!
# Maximal consistent extensions and the finite character of consistency

This file deepens the study of *universal mathematics* — the theorems shared by
every consistent theory extending a base — by adding the one structural
ingredient that makes the theory of consistent extensions genuinely rich:
**compactness**.  A consequence operator is compact when every entailment
already follows from a *finite* portion of the assumptions.  This is the abstract
shadow of the fact that proofs are finite objects.

With compactness in hand we prove two results that a syntax-free intelligence
would need in order to reason about the space of consistent extensions of its
mathematics:

* `lindenbaum` — **every consistent theory extends to a maximal consistent
  one**, which is moreover deductively closed.  The proof is an order-theoretic
  Zorn's-lemma argument: the union of a chain of consistent theories is again
  consistent precisely *because* consistency has finite character.  This is the
  bridge between the lattice theory of theories and the logic of provability.

* `consistent_iff_finite` — **consistency has finite character**: a theory is
  consistent if and only if each of its finite sub-theories is.  This is the
  exact sense in which consistency, and hence membership in the universal core,
  can be certified by finite means.

An explicit compact model (`idProofSystem`) witnesses that the axioms — including
compactness — are jointly satisfiable, so none of the results are vacuous.
-/

open Set

/-- A **compact proof system**: a Tarski consequence operator `C` together with a
distinguished absurd statement `bot`, in which every consequence follows from a
*finite* set of assumptions.  Finiteness of `compact` is the abstract trace of
the finiteness of proofs. -/
structure ProofSystem (S : Type*) where
  /-- The consequence (deductive closure) operator. -/
  C : Set S → Set S
  /-- Assumptions are among their own consequences. -/
  subset_closure : ∀ Γ, Γ ⊆ C Γ
  /-- More assumptions, more consequences. -/
  mono : ∀ ⦃Γ Δ : Set S⦄, Γ ⊆ Δ → C Γ ⊆ C Δ
  /-- Consequences of consequences are consequences (cut). -/
  idem : ∀ Γ, C (C Γ) ⊆ C Γ
  /-- A distinguished absurd statement marking inconsistency. -/
  bot : S
  /-- Compactness: every consequence follows from a finite set of assumptions. -/
  compact : ∀ {Γ : Set S} {φ : S}, φ ∈ C Γ →
    ∃ Γ₀ : Set S, Γ₀ ⊆ Γ ∧ Γ₀.Finite ∧ φ ∈ C Γ₀

namespace ProofSystem

variable {S : Type*} (P : ProofSystem S)

/-- Deductive closure is idempotent. -/
theorem C_idem_eq (Γ : Set S) : P.C (P.C Γ) = P.C Γ :=
  Set.Subset.antisymm (P.idem Γ) (P.subset_closure _)

/-- A theory is **consistent** when it does not entail the absurd statement. -/
def Consistent (Γ : Set S) : Prop := P.bot ∉ P.C Γ

/-- **Consistency has finite character.**  A theory is consistent exactly when
every one of its finite sub-theories is consistent.  This is the precise sense in
which consistency is a finitely certifiable property. -/
theorem consistent_iff_finite {base : Set S} :
    P.Consistent base ↔ ∀ Γ₀ ⊆ base, Γ₀.Finite → P.Consistent Γ₀ := by
  constructor
  · intro hcon Γ₀ hsub _ hbot
    exact hcon (P.mono hsub hbot)
  · intro h hbot
    obtain ⟨Γ₀, hsub, hfin, hbot0⟩ := P.compact hbot
    exact h Γ₀ hsub hfin hbot0

/-- The union of a chain of consistent theories is consistent.  Compactness is
essential: an entailment of `bot` from the union would already be an entailment
from a finite subset, which a single member of the chain must contain. -/
theorem sUnion_chain_consistent {c : Set (Set S)}
    (hcon : ∀ Δ ∈ c, P.Consistent Δ)
    (hchain : IsChain (· ⊆ ·) c) (hne : c.Nonempty) :
    P.Consistent (⋃₀ c) := by
  intro hbot
  obtain ⟨Γ₀, hΓ₀sub, hΓ₀fin, hΓ₀bot⟩ := P.compact hbot
  obtain ⟨s, hs, hsub⟩ :=
    hchain.directedOn.exists_mem_subset_of_finite_of_subset_sUnion hne hΓ₀fin hΓ₀sub
  exact hcon s hs (P.mono hsub hΓ₀bot)

/-- **Lindenbaum's theorem.**  Every consistent theory extends to a *maximal*
consistent theory, which is automatically deductively closed.  Any intelligence
whose reasoning is compact can, in principle, complete its consistent
commitments to a maximal coherent worldview. -/
theorem lindenbaum {base : Set S} (hcon : P.Consistent base) :
    ∃ M, base ⊆ M ∧ P.Consistent M ∧ P.C M = M ∧
      ∀ Δ, M ⊆ Δ → P.Consistent Δ → Δ = M := by
  set 𝒮 : Set (Set S) := {Δ | base ⊆ Δ ∧ P.Consistent Δ} with h𝒮
  have hub : ∀ c ⊆ 𝒮, IsChain (· ⊆ ·) c → c.Nonempty →
      ∃ ub ∈ 𝒮, ∀ s ∈ c, s ⊆ ub := by
    intro c hc hchain hne
    refine ⟨⋃₀ c, ⟨?_, ?_⟩, fun s hs => Set.subset_sUnion_of_mem hs⟩
    · obtain ⟨s, hs⟩ := hne
      exact (hc hs).1.trans (Set.subset_sUnion_of_mem hs)
    · exact P.sUnion_chain_consistent (fun Δ hΔ => (hc hΔ).2) hchain hne
  obtain ⟨M, hbaseM, hM⟩ := zorn_subset_nonempty 𝒮 hub base ⟨subset_rfl, hcon⟩
  obtain ⟨⟨hbM, hMcon⟩, hMmax⟩ := hM
  have hclosed : P.C M = M := by
    apply Set.Subset.antisymm _ (P.subset_closure M)
    have hCMcon : P.Consistent (P.C M) := by
      rw [Consistent, C_idem_eq]; exact hMcon
    exact hMmax ⟨hbaseM.trans (P.subset_closure M), hCMcon⟩ (P.subset_closure M)
  refine ⟨M, hbaseM, hMcon, hclosed, fun Δ hMΔ hΔcon => ?_⟩
  exact Set.Subset.antisymm (hMmax ⟨hbaseM.trans hMΔ, hΔcon⟩ hMΔ) hMΔ

/-- A maximal consistent theory is deductively closed and consistent. -/
theorem exists_maximal_consistent {base : Set S} (hcon : P.Consistent base) :
    ∃ M, base ⊆ M ∧ P.Consistent M ∧ P.C M = M := by
  obtain ⟨M, h1, h2, h3, _⟩ := P.lindenbaum hcon
  exact ⟨M, h1, h2, h3⟩

end ProofSystem

/-!
## An explicit compact model witnessing non-vacuity

The identity consequence operator on `ℕ` is compact: any consequence `φ` of `Γ`
lies in `Γ`, hence follows from the finite subset `{φ}`.  Taking `bot := 0`, a
theory is consistent exactly when it omits `0`.
-/

/-- The identity consequence system on `ℕ`, made into a compact proof system with
absurd statement `0`. -/
def idProofSystem : ProofSystem ℕ where
  C := id
  subset_closure _ := subset_rfl
  mono := fun _ _ h => h
  idem _ := subset_rfl
  bot := 0
  compact := by
    intro Γ φ hφ
    exact ⟨{φ}, by simpa using hφ, Set.finite_singleton φ, rfl⟩

namespace idProofSystem

/-- The theory `{1}` is consistent in the identity system (it omits `0`). -/
theorem singleton_consistent : idProofSystem.Consistent {1} := by
  simp [ProofSystem.Consistent, idProofSystem]

/-- Concretely, `{1}` extends to a maximal consistent theory. -/
theorem exists_maximal : ∃ M, ({1} : Set ℕ) ⊆ M ∧ idProofSystem.Consistent M ∧
    idProofSystem.C M = M :=
  idProofSystem.exists_maximal_consistent singleton_consistent

end idProofSystem

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  If the space of consistent extensions of a base
theory is to behave well — in particular, if the "universal core" of shared
theorems is to be certifiable by finite means — then consistency must be a
*finite-character* property, and every consistent theory ought to sit inside a
maximal coherent one.  Bold claim: both facts follow from a single abstract
input, compactness, with no appeal to a specific logical syntax.

**Experiment (Experimenter).**  We axiomatised compactness directly on the
consequence operator (`ProofSystem.compact`).  The finite-character theorem
`consistent_iff_finite` then dropped out by pushing an entailment of `bot`
through `compact` and back through monotonicity.  For `lindenbaum` we ran Zorn's
lemma on the poset of consistent extensions ordered by inclusion; the only
non-formal step is that the union of a chain of consistent theories is
consistent, isolated as `sUnion_chain_consistent`.

**Analysis (Analyst).**  The chain lemma is exactly where compactness pays off:
a hypothetical derivation of `bot` from the union uses only finitely many
assumptions, which — the chain being directed — all live in a single member,
contradicting that member's consistency.  A pleasant surprise was that the
maximal element produced by Zorn is automatically deductively *closed*: its
closure is a consistent superset, so maximality forces closure to add nothing.
Thus "maximal consistent" and "maximal consistent *and closed*" coincide for
free.

**Critique (Critic).**  Is compactness doing real work, or is it decorative?
Real work: without it the chain lemma fails and Zorn cannot start.  Is the whole
development vacuous?  No: `idProofSystem` is an explicit compact model with a
consistent theory `{1}` (`singleton_consistent`) that provably extends to a
maximal consistent theory (`exists_maximal`).  Does `lindenbaum` secretly assume
`Nonempty S`?  No — the base `base` is a witness-carrying set and Zorn is applied
to a family that already contains it, so the argument runs even for exotic
carriers, needing no separate nonemptiness hypothesis.

**Synthesis (Principal Investigator).**  Compactness is the hinge on which the
theory of consistent extensions turns.  It makes consistency finitely
certifiable and guarantees maximal coherent completions.  Combined with the
extension-invariance results, the picture is: the universal core is the base
theory, consistent extensions can enrich it in many maximal ways, and every one
of those ways is reachable and finitely policed.  A non-human mathematics built
on compact reasoning would face exactly the same landscape.
-/