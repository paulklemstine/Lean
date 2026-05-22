import Mathlib
import Bridges.TropicalNerode.Basic

/-! # Finite Tropical Representation Theorem

**Theorem B:** The Nerode quotient σ/~N is finite if and only if there exists a
finite recognizing representation.
-/

noncomputable section

open Classical TropicalNerode

universe u

/-! ## Recognizing Representation -/

/-- A recognizing representation: a finite-state system that faithfully
    represents the observable semantics of a compositional system. -/
structure RecognizingRep (κ σ M : Type u) (plug : κ → σ → σ) (Obs : σ → M) where
  V : Type u
  vFintype : Fintype V
  encode : σ → V
  act : κ → V → V
  readout : V → M
  readout_encode : ∀ x : σ, readout (encode x) = Obs x
  action_compat : ∀ c x, encode (plug c x) = act c (encode x)

namespace RecognizingRep

variable {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}

/-- The kernel of a recognizing representation refines the Nerode relation. -/
theorem kernel_refines_nerode (R : RecognizingRep κ σ M plug Obs)
    {x y : σ} (h : R.encode x = R.encode y) :
    TropicalNerode plug Obs x y := by
  intro c
  have h1 := R.readout_encode (plug c x)
  have h2 := R.readout_encode (plug c y)
  rw [← h1, ← h2, R.action_compat, R.action_compat, h]

end RecognizingRep

/-! ## Forward Direction: Finite Quotient → Finite Representation -/

/-- If the Nerode quotient is finite, we build a recognizing representation
    using the quotient itself as the state space. -/
def finite_quotient_gives_representation
    {κ σ M : Type u} (plug : κ → σ → σ) (Obs : σ → M)
    (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x)
    (id_ctx : κ) (h_id : ∀ x, plug id_ctx x = x)
    [hfin : Fintype (NerodeQuotient plug Obs)] :
    RecognizingRep κ σ M plug Obs where
  V := NerodeQuotient plug Obs
  vFintype := hfin
  encode := toQuotient plug Obs
  act := quotientPlug plug Obs comp plug_comp
  readout := Quotient.lift Obs (fun _ _ h => obsPreserving_of_id plug Obs h_id h)
  readout_encode _ := rfl
  action_compat _ _ := rfl

/-! ## Backward Direction: Finite Representation → Finite Quotient -/

/-- If a finite recognizing representation exists, the Nerode quotient is finite. -/
theorem finite_representation_gives_finite_quotient
    {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    [Nonempty σ]
    (R : RecognizingRep κ σ M plug Obs) :
    Finite (NerodeQuotient plug Obs) := by
  haveI := R.vFintype
  let f : R.V → NerodeQuotient plug Obs := fun v =>
    if h : ∃ x : σ, R.encode x = v then
      toQuotient plug Obs h.choose
    else
      toQuotient plug Obs (Classical.arbitrary σ)
  apply Finite.of_surjective f
  intro q
  induction q using Quotient.ind with
  | _ x =>
    refine ⟨R.encode x, ?_⟩
    show f (R.encode x) = _
    have hex : ∃ x' : σ, R.encode x' = R.encode x := ⟨x, rfl⟩
    simp only [f, dif_pos hex]
    apply Quotient.sound
    exact R.kernel_refines_nerode (Exists.choose_spec hex)

/-! ## Main Theorem -/

/-- **Theorem B (Tropical Myhill–Nerode):**
    The Nerode quotient is finite ↔ there exists a finite recognizing representation. -/
theorem finite_nerode_iff_finite_representation
    {κ σ M : Type u} [Nonempty σ]
    (plug : κ → σ → σ) (Obs : σ → M)
    (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x)
    (id_ctx : κ) (h_id : ∀ x, plug id_ctx x = x) :
    Finite (NerodeQuotient plug Obs) ↔
    ∃ (V : Type u) (_ : Fintype V) (encode : σ → V) (act : κ → V → V)
      (readout : V → M),
      (∀ x, readout (encode x) = Obs x) ∧
      (∀ c x, encode (plug c x) = act c (encode x)) := by
  constructor
  · intro hfin
    haveI := Fintype.ofFinite (NerodeQuotient plug Obs)
    let R := finite_quotient_gives_representation plug Obs comp plug_comp id_ctx h_id
    exact ⟨R.V, R.vFintype, R.encode, R.act, R.readout, R.readout_encode, R.action_compat⟩
  · rintro ⟨V, hV, encode, act, readout, hro, hac⟩
    exact finite_representation_gives_finite_quotient
      (⟨V, hV, encode, act, readout, hro, hac⟩ : RecognizingRep κ σ M plug Obs)

/-! ## Quotient Cardinality Bound -/

/-- The Nerode quotient cardinality is bounded by the representation state space. -/
theorem nerode_quotient_card_le
    {κ σ M : Type u} [Nonempty σ]
    {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs)
    [hfQ : Fintype (NerodeQuotient plug Obs)]
    [hfV : Fintype R.V] :
    Fintype.card (NerodeQuotient plug Obs) ≤ Fintype.card R.V := by
  let f : R.V → NerodeQuotient plug Obs := fun v =>
    if h : ∃ x : σ, R.encode x = v then
      toQuotient plug Obs h.choose
    else
      toQuotient plug Obs (Classical.arbitrary σ)
  have hsurj : Function.Surjective f := by
    intro q
    induction q using Quotient.ind with
    | _ x =>
      refine ⟨R.encode x, ?_⟩
      show f (R.encode x) = _
      have hex : ∃ x' : σ, R.encode x' = R.encode x := ⟨x, rfl⟩
      simp only [f, dif_pos hex]
      apply Quotient.sound
      exact R.kernel_refines_nerode (Exists.choose_spec hex)
  exact Fintype.card_le_of_surjective f hsurj

end