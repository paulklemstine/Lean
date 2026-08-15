import Mathlib
import Logic.BasicMonotoneCircuit.Basic
-- MISSING MODULE (not present in this repository): import output-final_aristotle...Tropical.Representation
/-! # Minimality and Uniqueness of Tropical Representations

**Theorem C:** Minimal finite tropical realizations are unique up to
a canonical bijection induced by the Nerode quotient.

A representation is *minimal* if:
1. It is reachable: every state is the encoding of some trace.
2. It is observable: distinct states are separated by some context.
-/

noncomputable section

open Classical TropicalNerode

universe u

/-! ## Minimality Conditions -/

/-- A representation is *reachable* if every state is the encoding of some trace. -/
def IsReachable {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) : Prop :=
  Function.Surjective R.encode

/-- A representation is *observable* if distinct states produce different
    observables under some context. -/
def IsObservable {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) : Prop :=
  ∀ v w : R.V, v ≠ w →
    ∃ c : κ, R.readout (R.act c v) ≠ R.readout (R.act c w)

/-- A representation is *minimal* if it is both reachable and observable. -/
structure IsMinimal {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) : Prop where
  reachable : IsReachable R
  observable : IsObservable R

/-! ## The Canonical Map -/

/-- The canonical map from a reachable representation's states to the Nerode quotient. -/
def canonicalMap {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) (hreach : IsReachable R) :
    R.V → NerodeQuotient plug Obs :=
  fun v => toQuotient plug Obs (hreach v).choose

/-- Two preimages of the same state are Nerode-equivalent. -/
theorem preimages_nerode_equiv {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs)
    {x y : σ} {v : R.V} (hx : R.encode x = v) (hy : R.encode y = v) :
    TropicalNerode plug Obs x y :=
  R.kernel_refines_nerode (hx.trans hy.symm)

/-! ## Surjectivity and Injectivity -/

/-- The canonical map is surjective. -/
theorem canonicalMap_surjective {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) (hreach : IsReachable R) :
    Function.Surjective (canonicalMap R hreach) := by
  intro q
  induction q using Quotient.ind with
  | _ x =>
    use R.encode x
    show toQuotient plug Obs (hreach (R.encode x)).choose = toQuotient plug Obs x
    apply Quotient.sound
    exact preimages_nerode_equiv R (hreach (R.encode x)).choose_spec rfl

/-- In an observable representation, Nerode-equivalent traces encode to the same state. -/
theorem observable_nerode_implies_same_encode
    {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) (hobs : IsObservable R)
    {x y : σ} (h : TropicalNerode plug Obs x y) :
    R.encode x = R.encode y := by
  by_contra hne
  obtain ⟨c, hc⟩ := hobs _ _ hne
  apply hc
  -- Need: R.readout (R.act c (R.encode x)) = R.readout (R.act c (R.encode y))
  -- We have: R.act c (R.encode x) = R.encode (plug c x) by action_compat
  -- And: R.readout (R.encode z) = Obs z by readout_encode
  calc R.readout (R.act c (R.encode x))
      = R.readout (R.encode (plug c x)) := by rw [R.action_compat]
    _ = Obs (plug c x) := R.readout_encode _
    _ = Obs (plug c y) := h c
    _ = R.readout (R.encode (plug c y)) := (R.readout_encode _).symm
    _ = R.readout (R.act c (R.encode y)) := by rw [R.action_compat]

/-- The canonical map is injective for observable representations. -/
theorem canonicalMap_injective {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs)
    (hreach : IsReachable R) (hobs : IsObservable R) :
    Function.Injective (canonicalMap R hreach) := by
  intro v w hvw
  have hxv := (hreach v).choose_spec
  have hyw := (hreach w).choose_spec
  -- hvw : canonicalMap ... v = canonicalMap ... w
  -- i.e., toQuotient ... (choose v) = toQuotient ... (choose w)
  -- So (choose v) ~N (choose w)
  have hnerode : TropicalNerode plug Obs (hreach v).choose (hreach w).choose :=
    Quotient.exact hvw
  have := observable_nerode_implies_same_encode R hobs hnerode
  rw [hxv, hyw] at this
  exact this

/-! ## Theorem C: Minimality and Uniqueness -/

/-- **Theorem C:** For a minimal representation, the canonical map is a bijection. -/
theorem minimal_representation_bijective {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) (hmin : IsMinimal R) :
    Function.Bijective (canonicalMap R hmin.reachable) :=
  ⟨canonicalMap_injective R hmin.reachable hmin.observable,
   canonicalMap_surjective R hmin.reachable⟩

/-- The bijection as an `Equiv`. -/
def minimalEquiv {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R : RecognizingRep κ σ M plug Obs) (hmin : IsMinimal R) :
    R.V ≃ NerodeQuotient plug Obs :=
  Equiv.ofBijective _ (minimal_representation_bijective R hmin)

/-- **Corollary:** Two minimal representations have isomorphic state spaces. -/
theorem minimal_representations_equiv
    {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R₁ R₂ : RecognizingRep κ σ M plug Obs)
    (hmin₁ : IsMinimal R₁) (hmin₂ : IsMinimal R₂) :
    Nonempty (R₁.V ≃ R₂.V) :=
  ⟨(minimalEquiv R₁ hmin₁).trans (minimalEquiv R₂ hmin₂).symm⟩

/-- **Corollary:** Two minimal representations have the same cardinality. -/
theorem minimal_representations_card_eq
    {κ σ M : Type u} {plug : κ → σ → σ} {Obs : σ → M}
    (R₁ R₂ : RecognizingRep κ σ M plug Obs)
    (hmin₁ : IsMinimal R₁) (hmin₂ : IsMinimal R₂)
    [Fintype R₁.V] [Fintype R₂.V] :
    Fintype.card R₁.V = Fintype.card R₂.V :=
  Fintype.card_congr ((minimalEquiv R₁ hmin₁).trans (minimalEquiv R₂ hmin₂).symm)

/-- The Nerode quotient representation is itself minimal. -/
theorem quotient_representation_is_minimal
    {κ σ M : Type u} (plug : κ → σ → σ) (Obs : σ → M)
    (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x)
    (id_ctx : κ) (h_id : ∀ x, plug id_ctx x = x)
    [Fintype (NerodeQuotient plug Obs)] :
    let R := finite_quotient_gives_representation plug Obs comp plug_comp id_ctx h_id
    IsMinimal R := by
  constructor
  · -- Reachable
    intro q
    induction q using Quotient.ind with
    | _ x => exact ⟨x, rfl⟩
  · -- Observable
    intro v w hvw
    induction v using Quotient.ind with
    | _ x =>
      induction w using Quotient.ind with
      | _ y =>
        have hne : ¬TropicalNerode plug Obs x y := by
          intro h; exact hvw (Quotient.sound h)
        obtain ⟨c, hc⟩ := separator_of_not_equiv plug Obs hne
        use c
        simp only [finite_quotient_gives_representation, quotientPlug]
        exact hc

end