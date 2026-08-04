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


/-! ## Consequence-stable propositions -/

/-- A finite family is consequence-stable for `P` when it is both implied by
`P` and jointly sufficient to recover `P`.  This strengthens mere coherence by
recording the missing backward direction explicitly. -/
def ConsequenceStable (P : Prop) (qs : List Prop) : Prop :=
  AreConsequences P qs ∧ BackwardCertificate P qs

/-- Consequence stability is exactly equivalence with the conjunction of the
listed consequences. -/
theorem consequenceStable_iff (P : Prop) (qs : List Prop) :
    ConsequenceStable P qs ↔ (P ↔ JointlyVerified qs) := by
  constructor
  · rintro ⟨hforward, hback⟩
    constructor
    · intro hP Q hQ
      exact hforward Q hQ hP
    · exact hback
  · intro h
    constructor
    · intro Q hQ hP
      exact h.mp hP Q hQ
    · exact h.mpr

/-- Every finite conjunction is consequence-stable with respect to its two
components.  This gives a nonempty, reusable class of stable propositions. -/
theorem conjunction_is_consequenceStable (A B : Prop) :
    ConsequenceStable (A ∧ B) [A, B] := by
  rw [consequenceStable_iff]
  constructor
  · rintro ⟨hA, hB⟩ Q hQ
    rcases List.mem_cons.mp hQ with rfl | hQ
    · exact hA
    · have : Q = B := List.mem_singleton.mp hQ
      simpa [this] using hB
  · intro h
    exact ⟨h A (by simp), h B (by simp)⟩

/-- Verified consequences establish a stable proposition. -/
theorem stable_of_verified (P : Prop) (qs : List Prop)
    (hstable : ConsequenceStable P qs) (hverified : JointlyVerified qs) : P := by
  exact hstable.2 hverified

/-! ## Finite consequence-guided search -/

/-- A candidate passes a list of semantic checks when every check holds of it. -/
def Passes {α : Type*} (checks : List (α → Prop)) (a : α) : Prop :=
  ∀ check ∈ checks, check a

/-- Candidates remaining after all verified semantic checks are imposed. -/
noncomputable def survivingCandidates {α : Type*} [DecidableEq α]
    (candidates : Finset α) (checks : List (α → Prop)) : Finset α := by
  classical
  exact candidates.filter (Passes checks)

/-- Consequence checks never enlarge a finite search space. -/
theorem survivingCandidates_subset {α : Type*} [DecidableEq α]
    (candidates : Finset α) (checks : List (α → Prop)) :
    survivingCandidates candidates checks ⊆ candidates := by
  classical
  intro a ha
  exact (Finset.mem_filter.mp (by simpa [survivingCandidates] using ha)).1

/-- Hence consequence-guided filtering cannot increase the number of candidates. -/
theorem survivingCandidates_card_le {α : Type*} [DecidableEq α]
    (candidates : Finset α) (checks : List (α → Prop)) :
    (survivingCandidates candidates checks).card ≤ candidates.card := by
  exact Finset.card_le_card (survivingCandidates_subset candidates checks)

/-- If one ambient candidate fails a check, filtering gives a strict reduction
in search-space cardinality. -/
theorem survivingCandidates_card_lt {α : Type*} [DecidableEq α]
    (candidates : Finset α) (checks : List (α → Prop)) (a : α)
    (ha : a ∈ candidates) (hfail : ¬ Passes checks a) :
    (survivingCandidates candidates checks).card < candidates.card := by
  classical
  apply Finset.card_lt_card
  rw [Finset.ssubset_iff_subset_ne]
  refine ⟨survivingCandidates_subset candidates checks, ?_⟩
  intro heq
  have ha' : a ∈ survivingCandidates candidates checks := by
    rw [heq]
    exact ha
  exact hfail (Finset.mem_filter.mp (by simpa [survivingCandidates] using ha')).2

/-- If the verified checks isolate a unique target, their propositions form a
backward certificate for candidate equality. -/
theorem unique_survivor_gives_backward_certificate
    {α : Type*} (checks : List (α → Prop)) (a target : α)
    (hunique : Passes checks a → a = target) :
    BackwardCertificate (a = target) (checks.map fun check => check a) := by
  intro hall
  apply hunique
  intro check hcheck
  apply hall (check a)
  exact List.mem_map.mpr ⟨check, hcheck, rfl⟩

/-- Search completeness: a target in the ambient candidate set that passes all
checks remains in the filtered set. -/
theorem target_mem_survivingCandidates {α : Type*} [DecidableEq α]
    (candidates : Finset α) (checks : List (α → Prop)) (target : α)
    (hmem : target ∈ candidates) (hpasses : Passes checks target) :
    target ∈ survivingCandidates candidates checks := by
  classical
  simp [survivingCandidates, hmem, hpasses]

/-! ## A small arithmetic calibration -/

/-- Three elementary arithmetic consequences used to identify `6` among the
natural numbers below `8`.  They are formulas of first-order arithmetic and so
provide a small Peano-arithmetic calibration of consequence-guided filtering. -/
def sixChecks : List (ℕ → Prop) :=
  [fun n => 0 < n, fun n => 2 ∣ n, fun n => 3 ∣ n]

/-- The three arithmetic checks isolate exactly `6` in the finite search space
`{0, ..., 7}`. -/
theorem sixChecks_unique :
    survivingCandidates (Finset.range 8) sixChecks = {6} := by
  classical
  ext n
  simp [survivingCandidates, Passes, sixChecks]
  constructor
  · rintro ⟨hn8, hn0, ⟨k, hk⟩, ⟨j, hj⟩⟩
    omega
  · intro hn
    omega

/-- In the arithmetic calibration, consequences compress eight candidates to
one; the surviving-cardinality ratio is therefore exactly `1/8`. -/
theorem sixChecks_compression_measure :
    (survivingCandidates (Finset.range 8) sixChecks).card = 1 ∧
      (Finset.range 8).card = 8 := by
  rw [sixChecks_unique]
  simp

/-- The arithmetic checks also furnish a backward certificate for equality to
`6`: any candidate satisfying all three checks and lying below `8` is `6`. -/
theorem sixChecks_backward_certificate (n : ℕ) (hn : n < 8) :
    BackwardCertificate (n = 6) (sixChecks.map fun check => check n) := by
  apply unique_survivor_gives_backward_certificate sixChecks n 6
  intro hx
  have hxmem : n ∈ survivingCandidates (Finset.range 8) sixChecks := by
    apply target_mem_survivingCandidates
    · simpa using hn
    · exact hx
  rw [sixChecks_unique] at hxmem
  simpa using hxmem

end RetrocausalProofTheory