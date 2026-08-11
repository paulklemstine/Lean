import Applications.ZeroKnowledgeTheoremProving.ProvabilityAmplification

/-!
# Entropy of the Verifier's View and the Boundaries of Zero-Knowledge Provability

This file is the adversarial-review layer of the affine Σ-protocol development
(`AffineDuality`, `ProvabilityAmplification`). It answers three questions that
the earlier files raised but did not settle.

## 1. How much randomness does the verifier see?

`accepting_eq_range_simulator` shows that, for a fixed challenge, the set of
accepting transcripts is *exactly* the range of the simulator — with no
assumption that the statement is even true. Combined with injectivity of the
simulator this yields `accepting_ncard_eq_card_group`: the verifier's view is
uniform on a set of size `|G|`, i.e. it carries exactly `log₂ |G|` bits, all of
them coming from the prover's tape and none from the witness. This is a
quantitative form of "zero knowledge": the *size* of the view does not depend on
the statement, the target, or the witness.

## 2. Does privacy need many witnesses?

Folklore says a Σ-protocol hides its witness because many witnesses are
consistent with the public statement. `unique_witness_still_perfect_zk` refutes
this in the sharpest possible way: when `ker s.hom` is trivial the witness is
*unique* (`card_witnesses_eq_one_of_trivial_ker`) and yet the verifier's view is
still exactly the simulator's. Privacy comes from translation symmetry of the
tape space, not from ambiguity of the witness.

## 3. Where does conviction actually come from?

`compilationOfProof` shows that any *provable* theorem can be compiled into the
affine protocol. Its mirror image, `unprovable_no_double_answer`, shows that for
an unprovable theorem no commitment ever admits accepting answers to both
challenges; together with `unprovable_soundness_error` this delimits exactly
what the verifier learns. Finally `zero_hom_compilation_is_vacuous` is a
deliberately negative result: the zero homomorphism yields a compilation whose
extraction step is content-free, so faithfulness of the encoding — not the
protocol — is the load-bearing assumption.
-/

namespace ZeroKnowledgeTheoremProving.AffineDuality

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H]

/-! ## 1. The accepting set is the simulator's range -/

/-- **Statement-independent geometry of acceptance.** For a fixed challenge the
accepting transcripts are precisely the simulator's outputs. No witness, and no
truth of the statement, is needed. -/
theorem accepting_eq_range_simulator (s : Statement (G := G) (H := H)) (c : Bool) :
    {t : Transcript G H | t.challenge = c ∧ Accepts s t} =
      Set.range (fun z : G => simulatedTranscript s z c) := by
  ext t
  constructor
  · rintro ⟨hc, hacc⟩
    refine ⟨t.response, ?_⟩
    have hh : s.hom t.response = t.commitment + challengeTerm c s.target := by
      have := hacc
      rw [Accepts, hc] at this
      exact this
    have hcomm : s.hom t.response - challengeTerm c s.target = t.commitment := by
      rw [hh, add_sub_cancel_right]
    show Transcript.mk (s.hom t.response - challengeTerm c s.target) c t.response = t
    rw [hcomm, ← hc]
  · rintro ⟨z, rfl⟩
    exact ⟨rfl, simulator_support_is_valid s z c⟩

/-- **The view has exactly `log₂ |G|` bits.** For every challenge the accepting
set is in bijection with the tape space `G`; its size is independent of the
statement, of the target, and of whether a witness exists at all. -/
theorem accepting_ncard_eq_card_group [Fintype G]
    (s : Statement (G := G) (H := H)) (c : Bool) :
    {t : Transcript G H | t.challenge = c ∧ Accepts s t}.ncard = Fintype.card G := by
  rw [accepting_eq_range_simulator s c,
    Set.ncard_range_of_injective (simulatedTranscript_injective s c),
    Nat.card_eq_fintype_card]

/-- Consequently the accepting sets for the two challenges have the same size:
the challenge bit itself leaks nothing about the statement. -/
theorem accepting_ncard_challenge_independent [Fintype G]
    (s : Statement (G := G) (H := H)) :
    {t : Transcript G H | t.challenge = false ∧ Accepts s t}.ncard =
      {t : Transcript G H | t.challenge = true ∧ Accepts s t}.ncard := by
  rw [accepting_ncard_eq_card_group s false, accepting_ncard_eq_card_group s true]

/-! ## 2. Privacy does not come from witness ambiguity -/

/-- If the public homomorphism is injective the witness is unique. -/
theorem card_witnesses_eq_one_of_trivial_ker (s : Statement (G := G) (H := H))
    (hinj : Function.Injective s.hom) {w₀ : G} (h₀ : IsWitness s w₀) :
    Nat.card {w : G // IsWitness s w} = 1 := by
  rw [card_witnesses_eq_card_ker s h₀]
  have hker : s.hom.ker = ⊥ := (AddMonoidHom.ker_eq_bot_iff s.hom).mpr hinj
  rw [hker]
  simp

/-- **Perfect privacy with a unique witness.** Even when the statement pins the
witness down completely, the verifier's view is exactly the simulator's output.
Zero knowledge is produced by the translation symmetry of the tape space, not by
the existence of alternative witnesses. -/
theorem unique_witness_still_perfect_zk [Fintype G]
    (s : Statement (G := G) (H := H)) (hinj : Function.Injective s.hom)
    {w : G} (hw : IsWitness s w) (c : Bool) :
    Nat.card {v : G // IsWitness s v} = 1 ∧
      Finset.univ.val.map (realTranscript s w · c) =
        Finset.univ.val.map (simulatedTranscript s · c) :=
  ⟨card_witnesses_eq_one_of_trivial_ker s hinj hw, perfect_zero_knowledge s hw c⟩

/-! ## 3. Where conviction comes from -/

variable {Thm Prf : Type*}

/-- Compiling a *provable* theorem: fix one checking proof `p₀`, publish the
image of its encoding, and assume the encoding sends all checking proofs to the
same public target (this is the faithfulness assumption of the compiler). -/
def compilationOfProof (hom : G →+ H) (encode : Prf → G) (T : Thm)
    (Checks : Thm → Prf → Prop) {p₀ : Prf} (hp₀ : Checks T p₀)
    (hcorr : ∀ p, Checks T p → hom (encode p) = hom (encode p₀)) :
    ProvabilityCompilation G H Thm Prf where
  stmt := ⟨hom, hom (encode p₀)⟩
  thm := T
  Checks := Checks
  encode := encode
  encode_isWitness := fun p hp => hcorr p hp
  witness_provable := fun _ _ => ⟨p₀, hp₀⟩

/-- The compiled statement is true, and the honest prover's proof is a witness
for it. -/
theorem compilationOfProof_isWitness (hom : G →+ H) (encode : Prf → G) (T : Thm)
    (Checks : Thm → Prf → Prop) {p₀ : Prf} (hp₀ : Checks T p₀)
    (hcorr : ∀ p, Checks T p → hom (encode p) = hom (encode p₀)) :
    IsWitness (compilationOfProof hom encode T Checks hp₀ hcorr).stmt (encode p₀) :=
  rfl

/-- Running the compiled protocol on a provable theorem is perfectly zero
knowledge: the whole view is reproduced by a simulator that sees only the public
statement. -/
theorem compilationOfProof_perfect_zk [Fintype G] (hom : G →+ H) (encode : Prf → G)
    (T : Thm) (Checks : Thm → Prf → Prop) {p₀ : Prf} (hp₀ : Checks T p₀)
    (hcorr : ∀ p, Checks T p → hom (encode p) = hom (encode p₀)) (c : Bool) :
    Finset.univ.val.map
        (realTranscript (compilationOfProof hom encode T Checks hp₀ hcorr).stmt
          (encode p₀) · c) =
      Finset.univ.val.map
        (simulatedTranscript (compilationOfProof hom encode T Checks hp₀ hcorr).stmt · c) :=
  perfect_zero_knowledge _ (compilationOfProof_isWitness hom encode T Checks hp₀ hcorr) c

/-- **Boundary of soundness.** If the theorem is unprovable then no commitment
admits accepting responses to both challenges: the extraction event simply never
occurs, rather than occurring and extracting garbage. -/
theorem unprovable_no_double_answer (C : ProvabilityCompilation G H Thm Prf)
    (hunprov : ¬ ∃ p, C.Checks C.thm p) (a : H) (zFalse zTrue : G) :
    ¬ (Accepts C.stmt ⟨a, false, zFalse⟩ ∧ Accepts C.stmt ⟨a, true, zTrue⟩) := by
  rintro ⟨hF, hT⟩
  exact hunprov (zk_convinces_provable C a zFalse zTrue hF hT)

/-- **Adversarial remark, formalised.** With the zero homomorphism every group
element is a witness, so extraction succeeds always and certifies nothing beyond
what the compiler already assumed. The protocol therefore transfers conviction
only as far as the encoding is faithful; the cryptography cannot manufacture
mathematical content. -/
theorem zero_hom_compilation_is_vacuous (T : Thm) (Checks : Thm → Prf → Prop)
    (encode : Prf → G) {p₀ : Prf} (hp₀ : Checks T p₀) :
    ∀ w : G,
      IsWitness (compilationOfProof (0 : G →+ H) encode T Checks hp₀
        (fun p _ => by simp)).stmt w := by
  intro w
  show (0 : G →+ H) w = (0 : G →+ H) (encode p₀)
  simp

/-- **Synthesis of the boundary analysis.** For a compiled formal system exactly
one of two things happens, and the two cases are separated by an exponential
gap: either the theorem is unprovable, in which case a committed prover survives
`n` parallel rounds with probability at most `(1/2)^n` and can never answer both
challenges at one commitment; or the theorem is provable, in which case an
honest prover answers all `2 ^ n` challenge vectors while its entire view — of
size exactly `|G|` per challenge — is generated by the proof-free simulator. -/
theorem provability_gap_synthesis [Fintype G] (C : ProvabilityCompilation G H Thm Prf)
    (n : ℕ) (c : Bool) :
    ((¬ ∃ p, C.Checks C.thm p) →
        ∀ P : ParallelProver G H n,
          ((cheatSet C.stmt n P).card : ℚ) /
              (Finset.univ : Finset (Fin n → Bool)).card ≤ (1 / 2) ^ n) ∧
      (∀ p, C.Checks C.thm p →
        (∀ r : Fin n → G,
            cheatSet C.stmt n (honestProver C.stmt n (C.encode p) r) = Finset.univ) ∧
          Finset.univ.val.map (realTranscript C.stmt (C.encode p) · c) =
            Finset.univ.val.map (simulatedTranscript C.stmt · c)) ∧
      {t : Transcript G H | t.challenge = c ∧ Accepts C.stmt t}.ncard = Fintype.card G := by
  classical
  refine ⟨fun hun P => unprovable_soundness_error C hun n P, fun p hp => ⟨fun r => ?_, ?_⟩,
    accepting_ncard_eq_card_group C.stmt c⟩
  · exact honest_cheatSet_eq_univ C.stmt n (C.encode_isWitness p hp) r
  · exact zk_view_is_simulated C hp c

end ZeroKnowledgeTheoremProving.AffineDuality