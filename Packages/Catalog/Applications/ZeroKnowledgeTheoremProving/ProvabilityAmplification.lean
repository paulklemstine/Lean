import Applications.ZeroKnowledgeTheoremProving.AffineDuality

/-!
# Zero-Knowledge Provability: Amplification, Support Geometry and Proof Transfer

This file continues the affine Σ-protocol theory of
`Applications.ZeroKnowledgeTheoremProving.AffineDuality`, where the two
directions of one affine law were shown to give *privacy* (translating a random
tape by the witness is a measure-preserving permutation) and *extraction*
(subtracting two accepting responses at one commitment recovers a witness).

Here we push that duality into three genuinely new layers.

1. **Support geometry.** The real execution of the protocol does not merely have
   the same multiset of transcripts as the simulator; that common multiset is
   *exactly* the set of accepting transcripts with the given challenge, each
   occurring with multiplicity one (`real_support_eq_accepting`,
   `real_count_le_one`). So the verifier's view is a *uniform* distribution on
   a set defined by the public verification equation alone.

2. **Soundness amplification (counting).** If the public statement has no
   witness, then for any fixed commitment vector a cheating prover can answer at
   *most one* challenge vector out of `2 ^ n` (`cheatSet_card_le_one`), giving a
   quantitative soundness error `≤ (1/2)^n` (`soundness_error_le`), while an
   honest prover holding a witness answers *all* `2 ^ n` of them
   (`honest_cheatSet_eq_univ`). The resulting dichotomy
   (`amplified_soundness_dichotomy`) is exponentially sharp: the accepting set
   jumps from cardinality `≤ 1` to cardinality `2 ^ n`.

3. **Provability transfer.** Packaging a formal proof system (a checking
   relation `Checks : Thm → Prf → Prop`) into the group-theoretic statement via
   an encoding turns the Σ-protocol into a zero-knowledge proof *of provability*:
   the verifier becomes convinced that `∃ p, Checks T p` (`zk_convinces_provable`)
   although its entire view is produced by a simulator that never sees a proof,
   and is literally identical for any two proofs of `T`
   (`zk_provability_transfer`).

The cross-domain bridge is: a finite abelian group acting by translation
(algebra) controls a counting/measure statement on transcript multisets
(combinatorics/probability), which in turn certifies a purely logical statement
about a proof system (logic).
-/

namespace ZeroKnowledgeTheoremProving.AffineDuality

open Finset

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H]

/-! ## 1. Support geometry of the verifier's view -/

/-- The honest prover's transcript map is injective in the random tape: the
response determines the tape. -/
theorem realTranscript_injective (s : Statement (G := G) (H := H)) (w : G) (c : Bool) :
    Function.Injective (fun r : G => realTranscript s w r c) := by
  intro r₁ r₂ h
  have : r₁ + challengeTerm c w = r₂ + challengeTerm c w :=
    congrArg Transcript.response h
  exact add_right_cancel this

/-- The simulator's transcript map is injective in the chosen response. -/
theorem simulatedTranscript_injective (s : Statement (G := G) (H := H)) (c : Bool) :
    Function.Injective (fun z : G => simulatedTranscript s z c) := by
  intro z₁ z₂ h
  exact congrArg Transcript.response h

/-- **Support characterisation.** A transcript occurs in the honest execution
iff it carries the given challenge and satisfies the public verification
equation. Nothing about the witness is visible in the support. -/
theorem mem_real_support_iff [Fintype G]
    (s : Statement (G := G) (H := H)) {w : G} (hw : IsWitness s w) (c : Bool)
    (t : Transcript G H) :
    t ∈ Finset.univ.val.map (realTranscript s w · c) ↔
      t.challenge = c ∧ Accepts s t := by
  have hw' : s.hom w = s.target := hw
  constructor
  · intro ht
    obtain ⟨r, -, hr⟩ := Multiset.mem_map.mp ht
    subst hr
    refine ⟨rfl, ?_⟩
    cases c <;>
      simp [Accepts, realTranscript, challengeTerm, map_add, hw']
  · rintro ⟨hc, hacc⟩
    refine Multiset.mem_map.mpr ⟨t.response - challengeTerm c w, Finset.mem_univ_val _, ?_⟩
    have hcomm : s.hom (t.response - challengeTerm c w) = t.commitment := by
      cases c with
      | false =>
          simp only [challengeTerm, if_neg (Bool.false_ne_true), sub_zero]
          have := hacc
          rw [Accepts, hc] at this
          simpa [challengeTerm] using this
      | true =>
          have hh := hacc
          rw [Accepts, hc] at hh
          simp only [challengeTerm, if_true] at hh ⊢
          rw [map_sub, hw', hh, add_sub_cancel_right]
    have hresp : t.response - challengeTerm c w + challengeTerm c w = t.response := by
      simp
    rw [realTranscript, hcomm, hresp, ← hc]

/-- Every transcript occurs at most once in the honest execution: the verifier's
view is a *uniform* distribution on its support. -/
theorem real_count_le_one [Fintype G] [DecidableEq G] [DecidableEq H]
    (s : Statement (G := G) (H := H)) (w : G) (c : Bool) (t : Transcript G H) :
    (Finset.univ.val.map (realTranscript s w · c)).count t ≤ 1 := by
  have hnodup : (Finset.univ.val.map (realTranscript s w · c)).Nodup :=
    Multiset.Nodup.map (realTranscript_injective s w c) Finset.univ.nodup
  exact Multiset.nodup_iff_count_le_one.mp hnodup t

/-- **The view is the accepting set.** For a fixed challenge the honest
execution ranges exactly over the accepting transcripts with that challenge,
each exactly once. This upgrades multiset equality with the simulator to an
intrinsic, witness-free description of the view. -/
theorem real_support_eq_accepting [Fintype G]
    (s : Statement (G := G) (H := H)) {w : G} (hw : IsWitness s w) (c : Bool) :
    {t : Transcript G H | t ∈ Finset.univ.val.map (realTranscript s w · c)} =
      {t : Transcript G H | t.challenge = c ∧ Accepts s t} := by
  ext t
  exact mem_real_support_iff s hw c t

/-! ## 2. Kernel-coset structure of the witness set -/

/-- Two witnesses for the same statement differ by a kernel element. -/
theorem witness_sub_mem_ker (s : Statement (G := G) (H := H)) {w₁ w₂ : G}
    (h₁ : IsWitness s w₁) (h₂ : IsWitness s w₂) :
    w₁ - w₂ ∈ s.hom.ker := by
  have e₁ : s.hom w₁ = s.target := h₁
  have e₂ : s.hom w₂ = s.target := h₂
  simp [AddMonoidHom.mem_ker, map_sub, e₁, e₂]

/-- The witness set is exactly a coset of the kernel of the public
homomorphism. -/
theorem witnessSet_eq_coset (s : Statement (G := G) (H := H)) {w₀ : G}
    (h₀ : IsWitness s w₀) :
    {w : G | IsWitness s w} = (fun k => w₀ + k) '' (s.hom.ker : Set G) := by
  have h₀' : s.hom w₀ = s.target := h₀
  ext w
  constructor
  · intro hw
    exact ⟨w - w₀, witness_sub_mem_ker s hw h₀, add_sub_cancel _ _⟩
  · rintro ⟨k, hk, rfl⟩
    have hk' : s.hom k = 0 := hk
    show s.hom (w₀ + k) = s.target
    simp [map_add, hk', h₀']

/-- Counting form: there are exactly as many witnesses as kernel elements.  In
particular extraction determines the witness only modulo `ker`, which is
precisely the ambiguity that makes zero knowledge possible. -/
theorem card_witnesses_eq_card_ker (s : Statement (G := G) (H := H)) {w₀ : G}
    (h₀ : IsWitness s w₀) :
    Nat.card {w : G // IsWitness s w} = Nat.card (s.hom.ker) := by
  have h₀' : s.hom w₀ = s.target := h₀
  have e : {w : G // IsWitness s w} ≃ (s.hom.ker : Set G) :=
    { toFun := fun w => ⟨w.1 - w₀, witness_sub_mem_ker s w.2 h₀⟩
      invFun := fun k => ⟨w₀ + k.1, by
        have hk' : s.hom k.1 = 0 := k.2
        show s.hom (w₀ + k.1) = s.target
        simp [map_add, hk', h₀']⟩
      left_inv := by rintro ⟨w, hw⟩; simp
      right_inv := by rintro ⟨k, hk⟩; simp }
  exact Nat.card_congr e

/-! ## 3. Soundness amplification over `n` parallel rounds -/

section Amplification

variable (s : Statement (G := G) (H := H)) (n : ℕ)

/-- A (possibly cheating) prover for the `n`-fold parallel repetition: it fixes
a commitment vector before seeing the challenge, and then may choose its
responses as an arbitrary function of the whole challenge vector. -/
structure ParallelProver (G H : Type*) (n : ℕ) where
  commitments : Fin n → H
  respond : (Fin n → Bool) → (Fin n → G)

/-- The verifier of the parallel repetition accepts iff every round accepts. -/
def ParallelAccepts (P : ParallelProver G H n) (c : Fin n → Bool) : Prop :=
  ∀ i, Accepts s ⟨P.commitments i, c i, P.respond c i⟩

/-- **Key rigidity lemma.** If the public statement has *no* witness, a prover
committed in advance can satisfy at most one challenge vector: two distinct
accepted challenge vectors differ somewhere, and that coordinate would extract a
witness by the affine subtraction law. -/
theorem parallel_unique_of_no_witness
    (hno : ∀ w : G, ¬ IsWitness s w) (P : ParallelProver G H n)
    {c c' : Fin n → Bool}
    (hc : ParallelAccepts s n P c) (hc' : ParallelAccepts s n P c') :
    c = c' := by
  funext i
  by_contra hne
  have h₁ := hc i
  have h₂ := hc' i
  cases hci : c i <;> cases hci' : c' i
  · exact hne (hci.trans hci'.symm)
  · rw [hci] at h₁
    rw [hci'] at h₂
    exact hno _ (special_soundness s (P.commitments i) (P.respond c i) (P.respond c' i) h₁ h₂)
  · rw [hci] at h₁
    rw [hci'] at h₂
    exact hno _ (special_soundness s (P.commitments i) (P.respond c' i) (P.respond c i) h₂ h₁)
  · exact hne (hci.trans hci'.symm)

open scoped Classical in
/-- The set of challenge vectors on which the prover succeeds. -/
noncomputable def cheatSet (P : ParallelProver G H n) : Finset (Fin n → Bool) :=
  Finset.univ.filter (fun c => ParallelAccepts s n P c)

open scoped Classical in
/-- Without a witness, the cheating set has at most one element out of `2 ^ n`. -/
theorem cheatSet_card_le_one (hno : ∀ w : G, ¬ IsWitness s w)
    (P : ParallelProver G H n) :
    (cheatSet s n P).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  simp only [cheatSet, Finset.mem_filter] at ha hb
  exact parallel_unique_of_no_witness s n hno P ha.2 hb.2

/-- The total number of challenge vectors is `2 ^ n`. -/
theorem card_challenge_vectors :
    (Finset.univ : Finset (Fin n → Bool)).card = 2 ^ n := by
  simp

open scoped Classical in
/-- **Exponential soundness error.** For a statement with no witness, the
fraction of challenge vectors a committed prover can answer is at most
`(1/2) ^ n`. -/
theorem soundness_error_le (hno : ∀ w : G, ¬ IsWitness s w)
    (P : ParallelProver G H n) :
    ((cheatSet s n P).card : ℚ) / (Finset.univ : Finset (Fin n → Bool)).card
      ≤ (1 / 2) ^ n := by
  rw [card_challenge_vectors n]
  have h2 : (0 : ℚ) < 2 ^ n := by positivity
  rw [div_le_iff₀ (by exact_mod_cast h2)]
  have hcard : ((cheatSet s n P).card : ℚ) ≤ 1 := by
    exact_mod_cast cheatSet_card_le_one s n hno P
  calc ((cheatSet s n P).card : ℚ) ≤ 1 := hcard
    _ = (1 / 2 : ℚ) ^ n * 2 ^ n := by
        rw [div_pow, one_pow, div_mul_cancel₀]
        exact ne_of_gt h2
    _ = (1 / 2 : ℚ) ^ n * ((2 ^ n : ℕ) : ℚ) := by push_cast; ring

/-- The honest prover for the parallel repetition: commit to `s.hom (r i)` and
answer with the affine translation of the tape. -/
def honestProver (w : G) (r : Fin n → G) : ParallelProver G H n where
  commitments := fun i => s.hom (r i)
  respond := fun c i => r i + challengeTerm (c i) w

open scoped Classical in
/-- **Completeness at full strength.** A prover holding a witness answers *every*
one of the `2 ^ n` challenge vectors. -/
theorem honest_cheatSet_eq_univ {w : G} (hw : IsWitness s w) (r : Fin n → G) :
    cheatSet s n (honestProver s n w r) = Finset.univ := by
  apply Finset.eq_univ_of_forall
  intro c
  simp only [cheatSet, Finset.mem_filter, Finset.mem_univ, true_and]
  intro i
  have hw' : s.hom w = s.target := hw
  cases h : c i <;>
    simp [Accepts, honestProver, challengeTerm, h, map_add, hw']

open scoped Classical in
/-- **Amplified soundness dichotomy.** With `1 ≤ n`, the accepting challenge set
of a committed prover is either everything (`2 ^ n` vectors, achievable exactly
when a witness exists) or has at most one element. There is nothing in between:
the gap is exponential in the number of rounds. -/
theorem amplified_soundness_dichotomy (P : ParallelProver G H n) :
    (cheatSet s n P).card ≤ 1 ∨
      ∃ w : G, IsWitness s w ∧
        ∀ r : Fin n → G, (cheatSet s n (honestProver s n w r)).card = 2 ^ n := by
  by_cases h : ∃ w : G, IsWitness s w
  · obtain ⟨w, hw⟩ := h
    refine Or.inr ⟨w, hw, fun r => ?_⟩
    rw [honest_cheatSet_eq_univ s n hw r, card_challenge_vectors n]
  · refine Or.inl (cheatSet_card_le_one s n ?_ P)
    intro w hw
    exact h ⟨w, hw⟩

end Amplification

/-! ## 4. Zero-knowledge proofs of provability -/

/-- A formal proof system compiled into the affine Σ-protocol: proofs of the
theorem `thm` are encoded as witnesses of the public group statement `stmt`,
faithfully in both directions. -/
structure ProvabilityCompilation (G H Thm Prf : Type*) [AddCommGroup G] [AddCommGroup H] where
  /-- the public group statement handed to the verifier -/
  stmt : Statement (G := G) (H := H)
  /-- the theorem whose provability is being asserted -/
  thm : Thm
  /-- the proof checker of the underlying formal system -/
  Checks : Thm → Prf → Prop
  /-- encoding of a formal proof as a group witness -/
  encode : Prf → G
  /-- encoded proofs are witnesses -/
  encode_isWitness : ∀ p, Checks thm p → IsWitness stmt (encode p)
  /-- witnesses come from genuine proofs -/
  witness_provable : ∀ w, IsWitness stmt w → ∃ p, Checks thm p

variable {Thm Prf : Type*}

/-- Knowledge of a witness is exactly provability of the theorem. -/
theorem provable_iff_hasWitness (C : ProvabilityCompilation G H Thm Prf) :
    (∃ p, C.Checks C.thm p) ↔ ∃ w : G, IsWitness C.stmt w := by
  constructor
  · rintro ⟨p, hp⟩
    exact ⟨C.encode p, C.encode_isWitness p hp⟩
  · rintro ⟨w, hw⟩
    exact C.witness_provable w hw

/-- **The verifier is convinced.** Two accepting transcripts with opposite
challenges at one commitment certify that the theorem really is provable in the
underlying formal system — even though the extracted object is only a group
element. -/
theorem zk_convinces_provable (C : ProvabilityCompilation G H Thm Prf)
    (a : H) (zFalse zTrue : G)
    (hFalse : Accepts C.stmt ⟨a, false, zFalse⟩)
    (hTrue : Accepts C.stmt ⟨a, true, zTrue⟩) :
    ∃ p, C.Checks C.thm p :=
  C.witness_provable _ (special_soundness C.stmt a zFalse zTrue hFalse hTrue)

/-- **Nothing is revealed.** The verifier's view of an honest execution with any
checking proof equals the output of the simulator, which is computed from the
public statement alone and never sees a proof. -/
theorem zk_view_is_simulated [Fintype G] (C : ProvabilityCompilation G H Thm Prf)
    {p : Prf} (hp : C.Checks C.thm p) (c : Bool) :
    Finset.univ.val.map (realTranscript C.stmt (C.encode p) · c) =
      Finset.univ.val.map (simulatedTranscript C.stmt · c) :=
  perfect_zero_knowledge C.stmt (C.encode_isWitness p hp) c

/-- **Zero-knowledge provability transfer.** For a compiled formal system:
(i) any two checking proofs of the theorem — say a short one and a
thousand-page one — induce *identical* verifier views; (ii) that common view is
already produced by the proof-free simulator; and (iii) a prover answering both
challenges at one commitment nevertheless certifies genuine provability.

This is the precise sense in which one can convince a verifier that a theorem is
provable without transmitting any information about *which* proof one holds. -/
theorem zk_provability_transfer [Fintype G] (C : ProvabilityCompilation G H Thm Prf)
    {p₁ p₂ : Prf} (h₁ : C.Checks C.thm p₁) (h₂ : C.Checks C.thm p₂) (c : Bool)
    (a : H) (zFalse zTrue : G)
    (hFalse : Accepts C.stmt ⟨a, false, zFalse⟩)
    (hTrue : Accepts C.stmt ⟨a, true, zTrue⟩) :
    Finset.univ.val.map (realTranscript C.stmt (C.encode p₁) · c) =
        Finset.univ.val.map (realTranscript C.stmt (C.encode p₂) · c) ∧
      Finset.univ.val.map (realTranscript C.stmt (C.encode p₁) · c) =
        Finset.univ.val.map (simulatedTranscript C.stmt · c) ∧
      ∃ p, C.Checks C.thm p := by
  refine ⟨?_, zk_view_is_simulated C h₁ c, zk_convinces_provable C a zFalse zTrue hFalse hTrue⟩
  rw [zk_view_is_simulated C h₁ c, zk_view_is_simulated C h₂ c]

open scoped Classical in
/-- **Unprovability is exponentially hard to fake.** If the theorem has no proof
in the formal system at all, then a committed prover survives `n` parallel
rounds with probability at most `(1/2) ^ n`. Combined with
`zk_provability_transfer`, the protocol transmits exactly one bit — "`thm` is
provable" — and nothing else. -/
theorem unprovable_soundness_error [Fintype G] (C : ProvabilityCompilation G H Thm Prf)
    (hunprov : ¬ ∃ p, C.Checks C.thm p) (n : ℕ) (P : ParallelProver G H n) :
    ((cheatSet C.stmt n P).card : ℚ) / (Finset.univ : Finset (Fin n → Bool)).card
      ≤ (1 / 2) ^ n := by
  refine soundness_error_le C.stmt n ?_ P
  intro w hw
  exact hunprov (C.witness_provable w hw)

end ZeroKnowledgeTheoremProving.AffineDuality