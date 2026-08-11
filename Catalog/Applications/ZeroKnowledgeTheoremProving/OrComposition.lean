import Applications.ZeroKnowledgeTheoremProving.LargeChallengeSpace

/-!
# Cycle 4: OR-Composition — Which Theorem Do You Know How To Prove?

The slogan "I can prove Fermat's Last Theorem without revealing why" has a
sharper cousin: *I can prove that at least one of two theorems is provable
without revealing which one I can prove.* This file formalises the classical
OR-composition (Cramer–Damgård–Schoenmakers style) of the affine Σ-protocol of
`AffineDuality` and proves both of its defining properties.

The prover publishes two commitments and, on receiving the challenge `c`, two
sub-challenges `c₁, c₂` with `c₁ xor c₂ = c` together with accepting responses
for both statements. Knowing a witness for the *left* statement it runs the
honest protocol on the left and the simulator on the right; knowing a witness
for the *right* statement it does the mirror image.

* `orLeft_accepts` / `orRight_accepts` — both strategies always produce accepted
  conversations (completeness).
* `orSwitch` and `orLeft_eq_orRight_switch` — an explicit bijection of the
  randomness space `G × G × Bool` carrying the left strategy pointwise onto the
  right strategy. This is the heart of the matter: the two strategies are
  reparametrisations of each other.
* `or_witness_side_hiding` — consequently the two strategies induce *literally
  the same multiset* of transcripts. The verifier's view does not contain the
  information of which of the two statements the prover can prove.
* `or_special_soundness` — two accepted conversations with the same pair of
  commitments and different overall challenges force a witness for one of the
  two statements to exist.
* `or_provability_transfer` — the statement in the language of compiled formal
  systems: the verifier is convinced that `T₁` or `T₂` is provable, while its
  view is the same whether the prover holds a proof of `T₁` or of `T₂`.

The bridge here is between a bit-level combinatorial gadget (splitting a
challenge by `xor`) and the group-translation symmetry that gave privacy in
cycle 1: the composite bijection mixes the two, and each factor is invertible
for a different reason.
-/

namespace ZeroKnowledgeTheoremProving.AffineDuality

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H]

/-- The public conversation of the OR-composed protocol. -/
structure OrTranscript (G H : Type*) where
  commit₁ : H
  commit₂ : H
  chal₁ : Bool
  chal₂ : Bool
  resp₁ : G
  resp₂ : G

/-- The OR-verifier: the sub-challenges must `xor` to the issued challenge and
both sub-conversations must be accepted. -/
def OrAccepts (s₁ s₂ : Statement (G := G) (H := H)) (c : Bool) (t : OrTranscript G H) : Prop :=
  (xor t.chal₁ t.chal₂ = c) ∧
    Accepts s₁ ⟨t.commit₁, t.chal₁, t.resp₁⟩ ∧
    Accepts s₂ ⟨t.commit₂, t.chal₂, t.resp₂⟩

/-- Strategy of a prover who knows a witness `w₁` for the **left** statement:
honest on the left, simulated on the right. The randomness is a tape `r`, a
simulator response `z₂` and the fake right challenge `d`. -/
def orLeft (s₁ s₂ : Statement (G := G) (H := H)) (w₁ : G) (c : Bool)
    (x : G × G × Bool) : OrTranscript G H :=
  ⟨s₁.hom x.1, s₂.hom x.2.1 - challengeTerm x.2.2 s₂.target,
    xor c x.2.2, x.2.2, x.1 + challengeTerm (xor c x.2.2) w₁, x.2.1⟩

/-- Strategy of a prover who knows a witness `w₂` for the **right** statement:
simulated on the left, honest on the right. -/
def orRight (s₁ s₂ : Statement (G := G) (H := H)) (w₂ : G) (c : Bool)
    (y : G × G × Bool) : OrTranscript G H :=
  ⟨s₁.hom y.2.1 - challengeTerm y.2.2 s₁.target, s₂.hom y.1,
    y.2.2, xor c y.2.2, y.2.1, y.1 + challengeTerm (xor c y.2.2) w₂⟩

/-- Completeness of the left strategy. -/
theorem orLeft_accepts (s₁ s₂ : Statement (G := G) (H := H)) {w₁ : G}
    (hw₁ : IsWitness s₁ w₁) (c : Bool) (x : G × G × Bool) :
    OrAccepts s₁ s₂ c (orLeft s₁ s₂ w₁ c x) := by
  have hw' : s₁.hom w₁ = s₁.target := hw₁
  obtain ⟨r, z, d⟩ := x
  refine ⟨by cases c <;> cases d <;> rfl, ?_, ?_⟩
  · show s₁.hom (r + challengeTerm (xor c d) w₁) =
      s₁.hom r + challengeTerm (xor c d) s₁.target
    cases hb : xor c d <;> simp [challengeTerm, map_add, hw']
  · exact simulator_support_is_valid s₂ z d

/-- Completeness of the right strategy. -/
theorem orRight_accepts (s₁ s₂ : Statement (G := G) (H := H)) {w₂ : G}
    (hw₂ : IsWitness s₂ w₂) (c : Bool) (y : G × G × Bool) :
    OrAccepts s₁ s₂ c (orRight s₁ s₂ w₂ c y) := by
  have hw' : s₂.hom w₂ = s₂.target := hw₂
  obtain ⟨r, z, e⟩ := y
  refine ⟨by cases c <;> cases e <;> rfl, simulator_support_is_valid s₁ z e, ?_⟩
  show s₂.hom (r + challengeTerm (xor c e) w₂) =
    s₂.hom r + challengeTerm (xor c e) s₂.target
  cases hb : xor c e <;> simp [challengeTerm, map_add, hw']

/-- The reparametrisation of the randomness space that turns the left strategy
into the right strategy. It composes a `xor`-flip of the fake challenge with two
group translations, and is bijective for both reasons at once. -/
def orSwitch (w₁ w₂ : G) (c : Bool) : (G × G × Bool) ≃ (G × G × Bool) where
  toFun x := (x.2.1 - challengeTerm x.2.2 w₂,
    x.1 + challengeTerm (xor c x.2.2) w₁, xor c x.2.2)
  invFun y := (y.2.1 - challengeTerm y.2.2 w₁,
    y.1 + challengeTerm (xor c y.2.2) w₂, xor c y.2.2)
  left_inv x := by
    obtain ⟨r, z, d⟩ := x
    simp only [Prod.mk.injEq]
    refine ⟨by simp, ?_, by cases c <;> cases d <;> rfl⟩
    cases c <;> cases d <;> simp [challengeTerm]
  right_inv y := by
    obtain ⟨r, z, e⟩ := y
    simp only [Prod.mk.injEq]
    refine ⟨by simp, ?_, by cases c <;> cases e <;> rfl⟩
    cases c <;> cases e <;> simp [challengeTerm]

/-- **Pointwise equality of the two strategies after reparametrisation.** -/
theorem orLeft_eq_orRight_switch (s₁ s₂ : Statement (G := G) (H := H))
    {w₁ w₂ : G} (hw₁ : IsWitness s₁ w₁) (hw₂ : IsWitness s₂ w₂) (c : Bool)
    (x : G × G × Bool) :
    orLeft s₁ s₂ w₁ c x = orRight s₁ s₂ w₂ c (orSwitch w₁ w₂ c x) := by
  have h₁ : s₁.hom w₁ = s₁.target := hw₁
  have h₂ : s₂.hom w₂ = s₂.target := hw₂
  obtain ⟨r, z, d⟩ := x
  have e₁ : s₁.hom (r + challengeTerm (xor c d) w₁) - challengeTerm (xor c d) s₁.target
      = s₁.hom r := by
    cases hb : xor c d <;> simp [challengeTerm, map_add, h₁]
  have e₂ : s₂.hom (z - challengeTerm d w₂) = s₂.hom z - challengeTerm d s₂.target := by
    cases hb : d <;> simp [challengeTerm, map_sub, h₂]
  have e₃ : z - challengeTerm d w₂ + challengeTerm (xor c (xor c d)) w₂ = z := by
    cases c <;> cases d <;> simp [challengeTerm]
  show (⟨s₁.hom r, s₂.hom z - challengeTerm d s₂.target, xor c d, d,
      r + challengeTerm (xor c d) w₁, z⟩ : OrTranscript G H) = _
  unfold orRight orSwitch
  simp only [Equiv.coe_fn_mk]
  rw [OrTranscript.mk.injEq]
  refine ⟨e₁.symm, e₂.symm, rfl, ?_, rfl, e₃.symm⟩
  cases c <;> cases d <;> rfl

/-- **Which-witness hiding.** The prover who can prove the left statement and
the prover who can prove the right statement generate exactly the same multiset
of conversations. The verifier's view therefore carries no information about
which of the two statements the prover is able to prove. -/
theorem or_witness_side_hiding [Fintype G] (s₁ s₂ : Statement (G := G) (H := H))
    {w₁ w₂ : G} (hw₁ : IsWitness s₁ w₁) (hw₂ : IsWitness s₂ w₂) (c : Bool) :
    Finset.univ.val.map (orLeft s₁ s₂ w₁ c) =
      Finset.univ.val.map (orRight s₁ s₂ w₂ c) := by
  have hbij : Multiset.map (fun x => orSwitch w₁ w₂ c x) Finset.univ.val =
      Finset.univ.val := Multiset.map_univ_val_equiv (orSwitch w₁ w₂ c)
  simp only [orLeft_eq_orRight_switch s₁ s₂ hw₁ hw₂ c]
  conv_rhs => rw [← hbij, Multiset.map_map]
  rfl

/-- **Soundness of the OR-composition.** Two accepted conversations sharing both
commitments but answering different challenges force one of the two statements
to have a witness. -/
theorem or_special_soundness (s₁ s₂ : Statement (G := G) (H := H)) {c c' : Bool}
    {t t' : OrTranscript G H}
    (h : OrAccepts s₁ s₂ c t) (h' : OrAccepts s₁ s₂ c' t')
    (hc₁ : t.commit₁ = t'.commit₁) (hc₂ : t.commit₂ = t'.commit₂)
    (hcc : c ≠ c') :
    (∃ w : G, IsWitness s₁ w) ∨ (∃ w : G, IsWitness s₂ w) := by
  obtain ⟨hx, ha₁, ha₂⟩ := h
  obtain ⟨hx', ha₁', ha₂'⟩ := h'
  -- the sub-challenges cannot agree in both coordinates
  have hdiff : t.chal₁ ≠ t'.chal₁ ∨ t.chal₂ ≠ t'.chal₂ := by
    by_contra hcon
    push_neg at hcon
    obtain ⟨e₁, e₂⟩ := hcon
    exact hcc (by rw [← hx, ← hx', e₁, e₂])
  rcases hdiff with hne | hne
  · left
    cases hb : t.chal₁ <;> cases hb' : t'.chal₁
    · exact absurd (hb.trans hb'.symm) hne
    · rw [hb] at ha₁
      rw [hb', ← hc₁] at ha₁'
      exact ⟨_, special_soundness s₁ t.commit₁ t.resp₁ t'.resp₁ ha₁ ha₁'⟩
    · rw [hb] at ha₁
      rw [hb', ← hc₁] at ha₁'
      exact ⟨_, special_soundness s₁ t.commit₁ t'.resp₁ t.resp₁ ha₁' ha₁⟩
    · exact absurd (hb.trans hb'.symm) hne
  · right
    cases hb : t.chal₂ <;> cases hb' : t'.chal₂
    · exact absurd (hb.trans hb'.symm) hne
    · rw [hb] at ha₂
      rw [hb', ← hc₂] at ha₂'
      exact ⟨_, special_soundness s₂ t.commit₂ t.resp₂ t'.resp₂ ha₂ ha₂'⟩
    · rw [hb] at ha₂
      rw [hb', ← hc₂] at ha₂'
      exact ⟨_, special_soundness s₂ t.commit₂ t'.resp₂ t.resp₂ ha₂' ha₂⟩
    · exact absurd (hb.trans hb'.symm) hne

variable {Thm Prf : Type*}

/-- **OR-provability transfer.** For two compiled formal systems: a verifier
that sees two accepted conversations with the same commitments and different
challenges is convinced that at least one of the two theorems is provable, while
the view of a prover holding a proof of the first theorem is identical to that
of a prover holding a proof of the second. Conviction about the disjunction is
transferred; the identity of the provable disjunct is not. -/
theorem or_provability_transfer [Fintype G]
    (C₁ C₂ : ProvabilityCompilation G H Thm Prf)
    {p₁ p₂ : Prf} (h₁ : C₁.Checks C₁.thm p₁) (h₂ : C₂.Checks C₂.thm p₂)
    {c c' : Bool} {t t' : OrTranscript G H}
    (ht : OrAccepts C₁.stmt C₂.stmt c t) (ht' : OrAccepts C₁.stmt C₂.stmt c' t')
    (hc₁ : t.commit₁ = t'.commit₁) (hc₂ : t.commit₂ = t'.commit₂) (hcc : c ≠ c')
    (cc : Bool) :
    ((∃ p, C₁.Checks C₁.thm p) ∨ (∃ p, C₂.Checks C₂.thm p)) ∧
      Finset.univ.val.map (orLeft C₁.stmt C₂.stmt (C₁.encode p₁) cc) =
        Finset.univ.val.map (orRight C₁.stmt C₂.stmt (C₂.encode p₂) cc) := by
  refine ⟨?_, or_witness_side_hiding C₁.stmt C₂.stmt (C₁.encode_isWitness p₁ h₁)
    (C₂.encode_isWitness p₂ h₂) cc⟩
  rcases or_special_soundness C₁.stmt C₂.stmt ht ht' hc₁ hc₂ hcc with ⟨w, hw⟩ | ⟨w, hw⟩
  · exact Or.inl (C₁.witness_provable w hw)
  · exact Or.inr (C₂.witness_provable w hw)

end ZeroKnowledgeTheoremProving.AffineDuality