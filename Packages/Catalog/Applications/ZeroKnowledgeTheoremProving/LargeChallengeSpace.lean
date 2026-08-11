import Applications.ZeroKnowledgeTheoremProving.FiatShamir

/-!
# Cycle 3: Linear Σ-Protocols over a Prime Field and `1 / q` Soundness

The Boolean protocol of the previous files has soundness error `1/2` per round.
This file generalises the whole development to a challenge space `ZMod q` with
`q` prime, i.e. to statements `f w = target` for a `ZMod q`-linear map
`f : V →ₗ[ZMod q] W`, and proves that everything survives with `1/2` replaced by
`1/q`:

* `linPerfectZeroKnowledge` — translating the tape by `c • w` is still a
  measure-preserving bijection, so the view is exactly the simulator's;
* `lin_special_soundness` — two accepting responses at *any two distinct*
  challenges extract the witness, now by dividing by `c - c'` in the field
  `ZMod q`. Subtraction is replaced by an honest linear solve;
* `linCheatSet_card_le_one` and `lin_soundness_error_le` — with no witness a
  committed prover answers at most one of the `q ^ n` challenge vectors, so the
  soundness error is `(1/q) ^ n`, exponentially better per round than the
  Boolean protocol;
* `linHonest_cheatSet_eq_univ` and `lin_amplified_dichotomy` — the honest prover
  answers all `q ^ n` challenge vectors, so the dichotomy from cycle 1 persists
  with an even larger gap;
* `challengeTerm_eq_smul` — the Boolean protocol is exactly the case `q = 2`,
  so the earlier results are the two-element specialisation of this family.

The cross-domain content is that soundness is now a statement of linear algebra
over a finite field (invertibility of a nonzero scalar) while privacy remains a
statement about a free translation action; the prime `q` interpolates between
them, and the soundness/privacy trade-off is governed by the field size.
-/

namespace ZeroKnowledgeTheoremProving.LinearSigma

open Finset

variable {q : ℕ} [Fact (Nat.Prime q)]
variable {V W : Type*} [AddCommGroup V] [AddCommGroup W]
  [Module (ZMod q) V] [Module (ZMod q) W]

/-- A public linear statement: prove knowledge of `w` with `f w = target`. -/
structure LinStatement (q : ℕ) [Fact (Nat.Prime q)] (V W : Type*)
    [AddCommGroup V] [AddCommGroup W] [Module (ZMod q) V] [Module (ZMod q) W] where
  hom : V →ₗ[ZMod q] W
  target : W

/-- A witness is a preimage of the public target. -/
def LinIsWitness (s : LinStatement q V W) (w : V) : Prop := s.hom w = s.target

/-- The public transcript, with challenge drawn from the field `ZMod q`. -/
structure LinTranscript (q : ℕ) (V W : Type*) where
  commitment : W
  challenge : ZMod q
  response : V

/-- Honest transcript from witness `w`, tape `r` and challenge `c`. -/
def linReal (s : LinStatement q V W) (w r : V) (c : ZMod q) : LinTranscript q V W :=
  ⟨s.hom r, c, r + c • w⟩

/-- Simulated transcript from a freely chosen response. -/
def linSim (s : LinStatement q V W) (z : V) (c : ZMod q) : LinTranscript q V W :=
  ⟨s.hom z - c • s.target, c, z⟩

/-- The verifier's linear equation. -/
def LinAccepts (s : LinStatement q V W) (t : LinTranscript q V W) : Prop :=
  s.hom t.response = t.commitment + t.challenge • s.target

/-- Simulated transcripts are accepted. -/
theorem lin_simulator_valid (s : LinStatement q V W) (z : V) (c : ZMod q) :
    LinAccepts s (linSim s z c) := by
  show s.hom z = (s.hom z - c • s.target) + c • s.target
  rw [sub_add_cancel]

/-- Translation of the tape by `c • w` is a bijection of the tape space. -/
def linTapeEquiv (c : ZMod q) (w : V) : V ≃ V where
  toFun r := r + c • w
  invFun z := z - c • w
  left_inv r := by simp
  right_inv z := by simp

/-- Each honest transcript is a simulated transcript at the translated tape. -/
theorem lin_real_eq_sim (s : LinStatement q V W) {w : V} (hw : LinIsWitness s w)
    (r : V) (c : ZMod q) :
    linReal s w r c = linSim s (linTapeEquiv c w r) c := by
  have hw' : s.hom w = s.target := hw
  show (⟨s.hom r, c, r + c • w⟩ : LinTranscript q V W) =
    ⟨s.hom (r + c • w) - c • s.target, c, r + c • w⟩
  have : s.hom (r + c • w) - c • s.target = s.hom r := by
    rw [map_add, map_smul, hw', add_sub_cancel_right]
  rw [this]

/-- **Perfect zero knowledge over a prime field.** The honest execution and the
simulator produce the same multiset of transcripts. -/
theorem linPerfectZeroKnowledge [Fintype V] (s : LinStatement q V W)
    {w : V} (hw : LinIsWitness s w) (c : ZMod q) :
    Finset.univ.val.map (linReal s w · c) = Finset.univ.val.map (linSim s · c) := by
  have hbij : Multiset.map (fun x => linTapeEquiv c w x) Finset.univ.val =
      Finset.univ.val := Multiset.map_univ_val_equiv (linTapeEquiv c w)
  simp only [lin_real_eq_sim s hw]
  conv_rhs => rw [← hbij, Multiset.map_map]
  rfl

/-- **Linear special soundness.** Two accepting responses at one commitment for
*any two distinct* challenges determine the witness, by solving a linear
equation over the field `ZMod q`. -/
theorem lin_special_soundness (s : LinStatement q V W) (a : W) {c c' : ZMod q}
    (hne : c ≠ c') (z z' : V)
    (h : LinAccepts s ⟨a, c, z⟩) (h' : LinAccepts s ⟨a, c', z'⟩) :
    LinIsWitness s ((c - c')⁻¹ • (z - z')) := by
  haveI : Fact (Nat.Prime q) := ‹_›
  have hz : s.hom z = a + c • s.target := h
  have hz' : s.hom z' = a + c' • s.target := h'
  have hsub : s.hom (z - z') = (c - c') • s.target := by
    rw [map_sub, hz, hz', sub_smul]
    abel
  have hne' : c - c' ≠ 0 := sub_ne_zero_of_ne hne
  show s.hom ((c - c')⁻¹ • (z - z')) = s.target
  rw [map_smul, hsub, smul_smul, inv_mul_cancel₀ hne', one_smul]

/-! ### Amplification with challenge space of size `q` -/

section Amplification

variable (s : LinStatement q V W) (n : ℕ)

/-- A prover for the `n`-fold parallel repetition with field challenges. -/
structure LinParallelProver (q : ℕ) (V W : Type*) (n : ℕ) where
  commitments : Fin n → W
  respond : (Fin n → ZMod q) → (Fin n → V)

/-- The parallel verifier accepts iff all rounds accept. -/
def LinParallelAccepts (P : LinParallelProver q V W n) (c : Fin n → ZMod q) : Prop :=
  ∀ i, LinAccepts s ⟨P.commitments i, c i, P.respond c i⟩

/-- With no witness a committed prover can satisfy at most one challenge
vector. -/
theorem lin_parallel_unique_of_no_witness (hno : ∀ w : V, ¬ LinIsWitness s w)
    (P : LinParallelProver q V W n) {c c' : Fin n → ZMod q}
    (hc : LinParallelAccepts s n P c) (hc' : LinParallelAccepts s n P c') :
    c = c' := by
  funext i
  by_contra hne
  exact hno _ (lin_special_soundness s (P.commitments i) hne (P.respond c i) (P.respond c' i)
    (hc i) (hc' i))

open scoped Classical in
/-- The set of challenge vectors the prover can answer. -/
noncomputable def linCheatSet (P : LinParallelProver q V W n) : Finset (Fin n → ZMod q) :=
  Finset.univ.filter (fun c => LinParallelAccepts s n P c)

open scoped Classical in
/-- Without a witness the cheating set has at most one element. -/
theorem linCheatSet_card_le_one (hno : ∀ w : V, ¬ LinIsWitness s w)
    (P : LinParallelProver q V W n) :
    (linCheatSet s n P).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  simp only [linCheatSet, Finset.mem_filter] at ha hb
  exact lin_parallel_unique_of_no_witness s n hno P ha.2 hb.2

/-- There are `q ^ n` challenge vectors. -/
theorem lin_card_challenge_vectors :
    (Finset.univ : Finset (Fin n → ZMod q)).card = q ^ n := by
  haveI : NeZero q := ⟨(Fact.out : Nat.Prime q).ne_zero⟩
  simp [ZMod.card]

open scoped Classical in
/-- **Soundness error `(1/q) ^ n`.** For a statement with no witness the
fraction of answerable challenge vectors is at most `(1/q) ^ n`, an
exponentially stronger guarantee per round than the Boolean protocol whenever
`2 < q`. -/
theorem lin_soundness_error_le (hno : ∀ w : V, ¬ LinIsWitness s w)
    (P : LinParallelProver q V W n) :
    ((linCheatSet s n P).card : ℚ) / (Finset.univ : Finset (Fin n → ZMod q)).card
      ≤ (1 / q : ℚ) ^ n := by
  have hq : 0 < q := (Fact.out : Nat.Prime q).pos
  have hqQ : (0 : ℚ) < (q : ℚ) := by exact_mod_cast hq
  have h2 : (0 : ℚ) < (q : ℚ) ^ n := by positivity
  rw [lin_card_challenge_vectors n]
  rw [div_le_iff₀ (by exact_mod_cast h2)]
  have hcard : ((linCheatSet s n P).card : ℚ) ≤ 1 := by
    exact_mod_cast linCheatSet_card_le_one s n hno P
  calc ((linCheatSet s n P).card : ℚ) ≤ 1 := hcard
    _ = (1 / q : ℚ) ^ n * (q : ℚ) ^ n := by
        rw [div_pow, one_pow, div_mul_cancel₀]
        exact ne_of_gt h2
    _ = (1 / q : ℚ) ^ n * ((q ^ n : ℕ) : ℚ) := by push_cast; ring

/-- The honest parallel prover. -/
def linHonestProver (w : V) (r : Fin n → V) : LinParallelProver q V W n where
  commitments := fun i => s.hom (r i)
  respond := fun c i => r i + (c i) • w

open scoped Classical in
/-- The honest prover answers every one of the `q ^ n` challenge vectors. -/
theorem linHonest_cheatSet_eq_univ {w : V} (hw : LinIsWitness s w) (r : Fin n → V) :
    linCheatSet s n (linHonestProver s n w r) = Finset.univ := by
  have hw' : s.hom w = s.target := hw
  apply Finset.eq_univ_of_forall
  intro c
  simp only [linCheatSet, Finset.mem_filter, Finset.mem_univ, true_and]
  intro i
  show s.hom (r i + (c i) • w) = s.hom (r i) + (c i) • s.target
  rw [map_add, map_smul, hw']

open scoped Classical in
/-- **Dichotomy with a `q`-ary challenge space.** Either the accepting challenge
set of a committed prover is a single vector, or a witness exists and the honest
prover answers all `q ^ n` of them. -/
theorem lin_amplified_dichotomy (P : LinParallelProver q V W n) :
    (linCheatSet s n P).card ≤ 1 ∨
      ∃ w : V, LinIsWitness s w ∧
        ∀ r : Fin n → V, (linCheatSet s n (linHonestProver s n w r)).card = q ^ n := by
  by_cases h : ∃ w : V, LinIsWitness s w
  · obtain ⟨w, hw⟩ := h
    refine Or.inr ⟨w, hw, fun r => ?_⟩
    rw [linHonest_cheatSet_eq_univ s n hw r, lin_card_challenge_vectors n]
  · refine Or.inl (linCheatSet_card_le_one s n ?_ P)
    intro w hw
    exact h ⟨w, hw⟩

end Amplification

/-- **Unification with the Boolean protocol.** Over a `ZMod 2`-module the
Boolean witness selector of the earlier files is exactly scalar multiplication
by the challenge, so the Boolean Σ-protocol is the `q = 2` member of this
family. -/
theorem challengeTerm_eq_smul {V : Type*} [AddCommGroup V] [Module (ZMod 2) V]
    (b : Bool) (w : V) :
    ZeroKnowledgeTheoremProving.AffineDuality.challengeTerm b w =
      (if b then (1 : ZMod 2) else 0) • w := by
  cases b <;>
    simp [ZeroKnowledgeTheoremProving.AffineDuality.challengeTerm]

/-! ### A decidable instance over `ZMod 5` -/

section Example

private instance : Fact (Nat.Prime 5) := ⟨by norm_num⟩

/-- A true linear statement over the field with five elements: `w = 3`. -/
def idStatement : LinStatement 5 (ZMod 5) (ZMod 5) := ⟨LinearMap.id, 3⟩

/-- A false linear statement: the zero map cannot hit the target `1`. -/
def zeroStatement : LinStatement 5 (ZMod 5) (ZMod 5) := ⟨0, 1⟩

theorem idStatement_witness : LinIsWitness idStatement 3 := rfl

theorem zeroStatement_no_witness : ∀ w : ZMod 5, ¬ LinIsWitness zeroStatement w := by
  intro w hw
  have h : (0 : ZMod 5) = 1 := hw
  exact absurd h (by decide)

open scoped Classical in
/-- Concrete soundness: over four rounds with a five-element challenge space,
any committed prover answers at most a `1 / 625` fraction of the challenge
vectors for the false statement. -/
theorem zeroStatement_soundness_4 (P : LinParallelProver 5 (ZMod 5) (ZMod 5) 4) :
    ((linCheatSet zeroStatement 4 P).card : ℚ) /
        (Finset.univ : Finset (Fin 4 → ZMod 5)).card ≤ 1 / 625 := by
  have h := lin_soundness_error_le zeroStatement 4 zeroStatement_no_witness P
  norm_num at h ⊢
  exact h

/-- Concrete extraction over `ZMod 5`: from accepting responses at the distinct
challenges `1` and `4`, the linear solve returns the witness. -/
theorem idStatement_extraction (r : ZMod 5) :
    LinIsWitness idStatement
      (((1 : ZMod 5) - 4)⁻¹ • ((r + (1 : ZMod 5) • 3) - (r + (4 : ZMod 5) • 3))) :=
  lin_special_soundness idStatement r (by decide) _ _ rfl rfl

end Example

end ZeroKnowledgeTheoremProving.LinearSigma