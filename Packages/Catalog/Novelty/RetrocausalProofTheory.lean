import Mathlib

/-!
# Retrocausal proof theory: a logical boundary theorem

This file studies the proposed rule “confirm `P` from verified consequences of `P`”
at the level of propositions.  Its central result is an exact characterization:
a proposition supports such a rule uniformly for every proposed consequence if and
only if the proposition was already provable.

The positive results identify the extra datum that makes backwards reasoning sound:
a *backward certificate* saying that the verified consequences jointly imply the
candidate proposition.
-/

namespace RetrocausalProofTheory

/-- Every member of `qs` is a logical consequence of `P`. -/
def AreConsequences (P : Prop) (qs : List Prop) : Prop :=
  ∀ Q ∈ qs, P → Q

/-- Every proposition in a finite list has been verified. -/
def JointlyVerified (qs : List Prop) : Prop :=
  ∀ Q ∈ qs, Q

/-- The listed propositions are propositionally coherent (joint truth is not absurd). -/
def Coherent (qs : List Prop) : Prop :=
  ¬ (JointlyVerified qs → False)

/-- A backward certificate is precisely the information needed to recover `P`. -/
def BackwardCertificate (P : Prop) (qs : List Prop) : Prop :=
  JointlyVerified qs → P

/-- Exact boundary theorem: uniform confirmation from arbitrary verified consequences
is possible exactly when `P` already has a proof. -/
theorem uniform_retrocausal_confirmation_iff (P : Prop) :
    (∀ Q : Prop, (P → Q) → Q → P) ↔ P := by
  constructor
  · intro h
    exact h True (fun _ => trivial) trivial
  · intro hP Q _ _
    exact hP

/-- Consequently, a universally valid consequence-confirmation rule would prove every
proposition. -/
theorem universal_retrocausal_rule_collapses
    (retro : ∀ (P Q : Prop), (P → Q) → Q → P) :
    ∀ P : Prop, P := by
  intro P
  exact retro P True (fun _ => trivial) trivial

/-- In particular there is no unrestricted rule that infers an antecedent merely from
one verified consequence. -/
theorem no_unrestricted_retrocausal_rule :
    ¬ (∀ (P Q : Prop), (P → Q) → Q → P) := by
  intro h
  exact h False True (fun _ => trivial) trivial

/-- Verification does guarantee coherence, but coherence alone is weaker than recovery
of an antecedent. -/
theorem verified_consequences_are_coherent (qs : List Prop)
    (hverified : JointlyVerified qs) : Coherent qs := by
  exact fun h => h hverified

/-- `True` is a verified, coherent consequence of every candidate proposition.  Thus
these two advertised checks alone cannot distinguish true candidates from false ones. -/
theorem true_control_passes_every_candidate (P : Prop) :
    AreConsequences P [True] ∧ JointlyVerified [True] ∧ Coherent [True] := by
  refine ⟨?_, ?_, ?_⟩
  · intro Q hQ
    simp at hQ
    simp [hQ]
  · intro Q hQ
    simp at hQ
    simp [hQ]
  · simp [Coherent, JointlyVerified]

/-- The preceding control is an explicit counterexample to recovering an antecedent:
even `False` passes all forward checks. -/
theorem false_passes_forward_checks_but_is_not_recovered :
    AreConsequences False [True] ∧ JointlyVerified [True] ∧
      Coherent [True] ∧ ¬ BackwardCertificate False [True] := by
  constructor
  · exact fun Q hQ => False.elim
  constructor
  · simp [JointlyVerified]
  constructor
  · simp [Coherent, JointlyVerified]
  · simp [BackwardCertificate, JointlyVerified]

/-- Backwards reasoning becomes sound once the consequences carry a checked backward
certificate. -/
theorem recover_of_backward_certificate (P : Prop) (qs : List Prop)
    (_hforward : AreConsequences P qs)
    (hverified : JointlyVerified qs)
    (hback : BackwardCertificate P qs) : P := by
  exact hback hverified

/-- For a single consequence, sound two-way certification is ordinary logical
equivalence. -/
theorem singleton_two_way_certificate (P Q : Prop)
    (hforward : P → Q) (hback : Q → P) : P ↔ Q := by
  exact ⟨hforward, hback⟩

/-- A family of verified consequences can recover `P` whenever one member is a
backward-complete consequence. -/
theorem recover_if_one_consequence_is_complete (P R : Prop) (qs : List Prop)
    (hR : R ∈ qs) (hverified : JointlyVerified qs) (hcomplete : R → P) : P := by
  exact hcomplete (hverified R hR)

/-- Adding more verified consequences preserves recovery once a backward certificate
for the original list is available. -/
theorem recovery_monotone_under_verified_extension
    (P : Prop) (base extra : List Prop)
    (hbase : BackwardCertificate P base)
    (hall : JointlyVerified (base ++ extra)) : P := by
  apply hbase
  intro Q hQ
  exact hall Q (List.mem_append_left _ hQ)

end RetrocausalProofTheory