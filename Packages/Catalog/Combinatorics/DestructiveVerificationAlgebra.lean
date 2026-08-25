/-
# Destructive verification V: the algebra of verification batteries

`Combinatorics.DestructiveVerification` makes tests into a monoid under
sequential composition `seq` (run one test, then the other on the residue, and
conjoin the verdicts).  This file works out the algebra of that monoid and uses
it to separate the three classes of the taxonomy *by closure properties*, which
is a sharper distinction than the pointwise counterexamples of the first file.

* **Certificates form a Boolean semilattice.**
  `DestructiveVerification.seq_self_of_nondestructive` (idempotence),
  `DestructiveVerification.nondestructive_equiv_seq` (composition of
  certificates is pointwise conjunction of verdicts), and
  `DestructiveVerification.certificate_absorb_iff` (the induced order is
  inclusion of accepted dishes).  So the sub-poset of certificates is exactly
  the Boolean lattice `2^D`, with `one` on top.
* **Destructive tests break idempotence.**
  `DestructiveVerification.exists_destructive_not_idempotent`: running the same
  destructive test twice is not the same as running it once, so no destructive
  test lies in that semilattice.
* **Reversibility = restorability.**
  `DestructiveVerification.reversible_iff_restorable`: on a finite dish space, a
  test can be undone by a follow-up test (`seq t u` nondestructive) *iff* it is
  reversible.  This is the exact algebraic content of "no information lost".
* **Repeatability is not compositional.**
  `DestructiveVerification.repeatable_not_closed_under_seq`: two repeatable
  tests — one of them even a certificate — compose to a non-repeatable test.
  Repeatable verification is therefore not a submonoid, in sharp contrast with
  the certificates.
* **Certificates cannot simulate destruction.**
  `DestructiveVerification.destructive_not_simulable`: an explicit test whose
  verdict stream is produced by no nondestructive test whatsoever, because
  certificate transcripts are constant while this one is not.

Together with the depth and realisation files this completes the separation
programme: the three classes differ pointwise, in their closure properties, and
in the verdict streams they can generate — with no hardness hypothesis anywhere.
-/
import Mathlib
import Combinatorics.DestructiveVerification
import Combinatorics.DestructiveVerificationDepth

namespace DestructiveVerification

variable {D : Type*}

/-! ## 1. Certificates form a Boolean semilattice -/

/-- Certificates are idempotent: re-running a certificate changes nothing. -/
theorem seq_self_of_nondestructive {t : Test D} (h : Nondestructive t) :
    seq t t = t :=
  ext_test (fun d => by simp [h d]) (fun d => by simp [h d])

/-- Under the identification of certificates with verdict functions, sequential
composition is pointwise conjunction. -/
theorem nondestructive_equiv_seq (t₁ t₂ : {t : Test D // Nondestructive t}) (d : D) :
    verdict (seq t₁.1 t₂.1) d = (verdict t₁.1 d && verdict t₂.1 d) := by
  simp [t₁.2 d]

/-- The natural order on certificates: `seq c₁ c₂ = c₁` says exactly that every
dish accepted by `c₁` is accepted by `c₂`, i.e. `c₁` is the stronger check. -/
theorem certificate_absorb_iff {c₁ c₂ : Test D} (h₁ : Nondestructive c₁)
    (h₂ : Nondestructive c₂) :
    seq c₁ c₂ = c₁ ↔ ∀ d, verdict c₁ d = true → verdict c₂ d = true := by
  constructor
  · intro h d hd
    have := congrArg (fun t => verdict t d) h
    simp only [verdict_seq, h₁ d] at this
    rw [hd] at this
    simpa using this
  · intro h
    refine ext_test (fun d => ?_) (fun d => ?_)
    · simp only [verdict_seq, h₁ d]
      cases hc : verdict c₁ d with
      | false => simp
      | true => simp [h d hc]
    · simp [h₁ d, h₂ d]

/-- Destructive tests are never idempotent in the sense of certificates: here is
a test with `seq t t ≠ t`. -/
theorem exists_destructive_not_idempotent :
    ∃ t : Test Bool, Destructive t ∧ seq t t ≠ t := by
  refine ⟨readFlipTest, ?_, ?_⟩
  · intro h; simpa [readFlipTest, residue] using h true
  · intro h
    have := congrArg (fun t => verdict t true) h
    simp [seq, readFlipTest, verdict, residue] at this

/-! ## 2. Reversibility equals restorability -/

/-- **Restorability characterises reversibility.**  On a finite dish space a
test can be undone by a follow-up test exactly when it is reversible.  ("Undone"
means the composite battery returns the original dish, i.e. is a certificate as
a state transition.) -/
theorem reversible_iff_restorable [Finite D] (t : Test D) :
    Reversible t ↔ ∃ u : Test D, Nondestructive (seq t u) := by
  constructor
  · intro h
    let g : D ≃ D := Equiv.ofBijective (residue t) h
    refine ⟨fun d => (true, g.symm d), fun d => ?_⟩
    show g.symm (residue t d) = d
    exact g.symm_apply_apply d
  · rintro ⟨u, hu⟩
    have hleft : Function.LeftInverse (residue u) (residue t) := fun d => hu d
    have hinj : Function.Injective (residue t) := hleft.injective
    exact (Finite.injective_iff_bijective).mp hinj

/-- A certificate is its own restorer; the reversible-but-destructive `flipTest`
needs a genuine partner. -/
theorem flipTest_restorable : ∃ u : Test Bool, Nondestructive (seq flipTest u) :=
  (reversible_iff_restorable flipTest).mp flipTest_reversible

/-- The burn test cannot be undone by any follow-up test: destruction that loses
information is algebraically irreversible. -/
theorem burnTest_not_restorable : ¬ ∃ u : Test Bool, Nondestructive (seq burnTest u) := by
  intro h
  exact burnTest_not_reversible ((reversible_iff_restorable burnTest).mpr h)

/-! ## 3. Repeatability is not compositional -/

/-- The certificate that simply reports the dish. -/
def readTest : Test Bool := fun d => (d, d)

theorem readTest_nondestructive : Nondestructive readTest := fun _ => rfl

/-- **Repeatability is not closed under composition.**  `readTest` is a
certificate (hence repeatable) and `flipTest` is repeatable, but running the
first and then the second gives a test whose second run contradicts its
first. -/
theorem repeatable_not_closed_under_seq :
    ∃ t₁ t₂ : Test Bool, Repeatable t₁ ∧ Repeatable t₂ ∧ ¬ Repeatable (seq t₁ t₂) := by
  refine ⟨readTest, flipTest, readTest_nondestructive.repeatable, flipTest_repeatable, ?_⟩
  intro h
  have := h true
  simp [seq, readTest, flipTest, verdict, residue] at this

/-- By contrast, certificates *are* closed under composition and remain
repeatable — the failure above is caused entirely by the destructive partner. -/
theorem nondestructive_seq_repeatable {t₁ t₂ : Test D} (h₁ : Nondestructive t₁)
    (h₂ : Nondestructive t₂) : Repeatable (seq t₁ t₂) :=
  (nondestructive_seq h₁ h₂).repeatable

/-! ## 4. Certificates cannot simulate destruction -/

/-- **No certificate reproduces a destructive verdict stream.**  The fuse test
on two dishes accepts once and then rejects forever; every nondestructive test
has a constant transcript, so none of them produces this stream. -/
theorem destructive_not_simulable :
    ∃ (t : Test (Fin 2)) (d : Fin 2), ∀ c : Test (Fin 2), Nondestructive c →
      ∃ m, transcript t d m ≠ transcript c d m := by
  refine ⟨fuseTest 0, 0, fun c hc => ?_⟩
  by_contra hcon
  push_neg at hcon
  have h0 := hcon 0
  have h1 := hcon 1
  have hc0 : transcript c 0 1 = transcript c 0 0 := hc.transcript_const 0 1
  rw [← h0, ← h1] at hc0
  have ht0 : transcript (fuseTest 0) 0 1 ≠ transcript (fuseTest 0) 0 0 := by
    rw [fuseTest_transcript, fuseTest_transcript]
    simp
  exact ht0 hc0

end DestructiveVerification