import Mathlib
import Bridges.TropicalNerode.Basic
import Bridges.TropicalNerode.Representation
import Bridges.TropicalNerode.Minimality

/-! # Concrete Examples of Tropical Nerode Theory

We instantiate the abstract theory with concrete systems:
1. Integer traces with addition contexts and identity observable
2. Threshold observable (binary classification)
3. Modular observable (finite quotient)
4. Constant observable (trivial quotient)
5. Finite cyclic system
-/

noncomputable section

open Classical TropicalNerode

/-! ## Example 1: Integer Addition System -/

instance intAddContextAction : ContextAction ℤ ℤ where
  plug c x := c + x
  comp c₁ c₂ := c₁ + c₂
  plug_comp c₁ c₂ x := by ring

/-- For identity observable, Nerode equivalence is equality. -/
theorem int_id_nerode_eq (x y : ℤ) :
    TropicalNerode (fun c x => c + x) id x y ↔ x = y := by
  constructor
  · intro h
    have h0 := h 0
    simp [id] at h0
    exact h0
  · intro h; subst h; exact TropicalNerode.refl _ _ _

/-! ## Example 2: Threshold Observable -/

def thresholdObs : ℤ → Bool := fun x => decide (0 ≤ x)

theorem threshold_nerode_eq (x y : ℤ) :
    TropicalNerode (fun c (z : ℤ) => c + z) thresholdObs x y ↔ x = y := by
  constructor
  · intro h
    by_contra hne
    have h1 := h (-x)
    have h2 := h (-y)
    simp [thresholdObs] at h1 h2
    omega
  · intro h; subst h; exact TropicalNerode.refl _ _ _

/-! ## Example 3: Modular Observable -/

def modObs (n : ℕ) : ℤ → ZMod n := fun x => (x : ZMod n)

theorem mod_nerode_iff (n : ℕ) (x y : ℤ) :
    TropicalNerode (fun c (z : ℤ) => c + z) (modObs n) x y ↔
    (x : ZMod n) = (y : ZMod n) := by
  constructor
  · intro h
    have h0 := h 0
    simp [modObs] at h0
    exact h0
  · intro h c
    simp only [modObs]
    push_cast
    rw [h]

/-- The mod-2 quotient is finite: exactly 2 classes. -/
theorem mod2_quotient_finite :
    Finite (NerodeQuotient (fun c (z : ℤ) => c + z) (modObs 2)) := by
  apply finite_representation_gives_finite_quotient
  exact {
    V := ZMod 2
    vFintype := inferInstance
    encode := fun x => (x : ZMod 2)
    act := fun c v => (c : ZMod 2) + v
    readout := id
    readout_encode := fun _ => rfl
    action_compat := fun c x => by push_cast; ring
  }

/-! ## Example 4: Constant Observable -/

variable {M : Type*}

theorem const_obs_all_equiv {κ σ : Type*} (plug : κ → σ → σ) (m : M)
    (x y : σ) : TropicalNerode plug (fun _ => m) x y :=
  fun _ => rfl

theorem const_obs_quotient_subsingleton {κ σ : Type*} (plug : κ → σ → σ) (m : M) :
    Subsingleton (NerodeQuotient plug (fun (_ : σ) => m)) := by
  constructor
  intro a b
  induction a using Quotient.ind with
  | _ x =>
    induction b using Quotient.ind with
    | _ y => exact Quotient.sound (const_obs_all_equiv plug m x y)

/-! ## Example 5: Finite Cyclic System -/

instance zmod3ContextAction : ContextAction (ZMod 3) (ZMod 3) where
  plug c x := c + x
  comp c₁ c₂ := c₁ + c₂
  plug_comp c₁ c₂ x := by ring

theorem fin3_id_finite :
    Finite (NerodeQuotient (fun (c : ZMod 3) (x : ZMod 3) => c + x) id) := by
  apply finite_representation_gives_finite_quotient
  exact {
    V := ZMod 3
    vFintype := inferInstance
    encode := id
    act := fun c v => c + v
    readout := id
    readout_encode := fun _ => rfl
    action_compat := fun _ _ => rfl
  }

/-! ## Max-Plus / Min-Plus Algebraic Properties -/

theorem maxplus_idempotent (a : ℤ) : max a a = a := max_self a

theorem maxplus_distrib (a b c : ℤ) : a + max b c = max (a + b) (a + c) :=
  (max_add_add_left a b c).symm

theorem minplus_idempotent (a : ℤ) : min a a = a := min_self a

theorem minplus_distrib (a b c : ℤ) : a + min b c = min (a + b) (a + c) :=
  (min_add_add_left a b c).symm

/-! ## Separation Certificates -/

theorem separate_zero_one :
    Separates (fun c (x : ℤ) => c + x) id (0 : ℤ) (0 : ℤ) (1 : ℤ) := by
  simp [Separates, id]

theorem int_id_not_equiv {x y : ℤ} (hne : x ≠ y) :
    ¬TropicalNerode (fun c (z : ℤ) => c + z) id x y := by
  intro h
  exact hne ((int_id_nerode_eq x y).mp h)

end