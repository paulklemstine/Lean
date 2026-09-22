import Computation.ReproducibilityInvariance

/-!
# The converse of generator-invariance: invariant readouts are functions of the type

`Catalog.Computation.ReproducibilityInvariance` proves one half of "reproducible by
construction": the splitting type, its histogram and its entropy are unchanged when the
identification of the Galois group with `ℤ/n` is composed with the unit action
`x ↦ u · x` (a change of generator).  This file proves the **converse**, which is what turns
invariance into a *characterisation* of the auditable observables:

> a readout `t : ℤ/n → ℕ` satisfies `t (u · x) = t x` for every unit `u`
> **iff** `t` factors through the splitting type `x ↦ n / gcd (n, x)`.

The mathematical content is the orbit computation `unit_orbit_of_gcd_eq`: two residues with the
same `gcd` with `n` differ by a unit.  It is proved by writing `n = g·m`, `a = g·a₁`, `b = g·b₁`
with `a₁`, `b₁` units mod `m`, forming the unit `b₁ · a₁⁻¹` of `ℤ/m`, and lifting it to a unit of
`ℤ/n` along the surjection `(ℤ/n)ˣ → (ℤ/m)ˣ`.

Main results.

* `CyclicType.Audit.typ_eq_iff_gcd_eq` : the type separates exactly the `gcd` classes.
* `CyclicType.Audit.unit_orbit_of_gcd_eq`, `CyclicType.Audit.unit_orbit_of_typ_eq` : the orbits of
  the unit action are the fibres of the type map.
* `CyclicType.Audit.unit_invariant_iff_typ_invariant` : the characterisation above.
* `CyclicType.Audit.exists_factor_through_typ` : the resulting explicit factorisation
  `t = f ∘ typ n`.
* `CyclicType.Audit.entropyOf_eq_of_unit_invariant` : an invariant readout therefore has the same
  histogram, hence the same entropy, as the induced function of the type.
* `CyclicType.Audit.typ_universal_invariant` : the type map is the universal invariant readout.

This closes Direction 4 of the previous cycle's `FUTURE_DIRECTIONS.md`.
-/

namespace CyclicType.Audit

/-! ## 1. The type separates exactly the gcd classes -/

/-- For `n > 0` the splitting type `n / gcd (n, x)` determines, and is determined by,
`gcd (n, x)`. -/
theorem typ_eq_iff_gcd_eq {n : ℕ} (hn : 0 < n) (x y : Fin n) :
    typ n x = typ n y ↔ Nat.gcd n x.val = Nat.gcd n y.val := by
  constructor
  · intro h
    have hx : n / (n / Nat.gcd n x.val) = Nat.gcd n x.val :=
      Nat.div_div_self (Nat.gcd_dvd_left _ _) hn.ne'
    have hy : n / (n / Nat.gcd n y.val) = Nat.gcd n y.val :=
      Nat.div_div_self (Nat.gcd_dvd_left _ _) hn.ne'
    rw [← hx, ← hy]
    exact congrArg (fun d => n / d) h
  · intro h
    unfold typ
    rw [h]

/-! ## 2. The orbit computation -/

/-- Cancelling a common factor from a `gcd`: if `gcd (g*m) (g*a) = g` and `g > 0`
then `a` is coprime to `m`. -/
lemma coprime_of_gcd_mul {g m a : ℕ} (hg : 0 < g) (h : Nat.gcd (g * m) (g * a) = g) :
    Nat.Coprime a m := by
  have h1 : g * Nat.gcd m a = g * 1 := by
    rw [mul_one, ← Nat.gcd_mul_left g m a, h]
  have := Nat.eq_of_mul_eq_mul_left hg h1
  exact (Nat.coprime_comm.mp this)

/-- **The orbits of the unit action are the `gcd` classes.**  If two residues have the same `gcd`
with `n`, then one is a unit multiple of the other. -/
theorem unit_orbit_of_gcd_eq {n a b : ℕ} (hn : 0 < n) (h : Nat.gcd n a = Nat.gcd n b) :
    ∃ u : ℕ, Nat.Coprime u n ∧ u * a ≡ b [MOD n] := by
  set g := Nat.gcd n a with hgdef
  have hg : 0 < g := Nat.gcd_pos_of_pos_left a hn
  obtain ⟨m, hm⟩ : g ∣ n := Nat.gcd_dvd_left n a
  obtain ⟨a₁, ha₁⟩ : g ∣ a := Nat.gcd_dvd_right n a
  obtain ⟨b₁, hb₁⟩ : g ∣ b := h ▸ Nat.gcd_dvd_right n b
  have hmpos : 0 < m := by
    rcases Nat.eq_zero_or_pos m with hm0 | hm0
    · rw [hm0, mul_zero] at hm; omega
    · exact hm0
  have hane : Nat.Coprime a₁ m := by
    refine coprime_of_gcd_mul hg ?_
    rw [← hm, ← ha₁]
  have hbne : Nat.Coprime b₁ m := by
    refine coprime_of_gcd_mul hg ?_
    rw [← hm, ← hb₁, ← h]
  haveI : NeZero m := ⟨hmpos.ne'⟩
  haveI : NeZero n := ⟨hn.ne'⟩
  -- the target unit of `ZMod m`
  have hAunit : IsUnit ((a₁ : ZMod m)) := (ZMod.isUnit_iff_coprime a₁ m).mpr hane
  have hBunit : IsUnit ((b₁ : ZMod m)) := (ZMod.isUnit_iff_coprime b₁ m).mpr hbne
  set w : (ZMod m)ˣ := hBunit.unit * hAunit.unit⁻¹ with hw
  have hdvd : m ∣ n := ⟨g, by rw [hm, Nat.mul_comm]⟩
  obtain ⟨U, hU⟩ := ZMod.unitsMap_surjective (m := n) hdvd w
  refine ⟨(U : ZMod n).val, ZMod.val_coe_unit_coprime U, ?_⟩
  -- the congruence mod `m`
  have hcast : (((U : ZMod n).val : ℕ) : ZMod m) = (w : ZMod m) := by
    rw [← hU]
    simp [ZMod.unitsMap_def, ZMod.natCast_val]
  have hmul : (((U : ZMod n).val * a₁ : ℕ) : ZMod m) = ((b₁ : ℕ) : ZMod m) := by
    push_cast
    rw [hcast, hw]
    push_cast
    rw [mul_assoc]
    rw [hAunit.val_inv_mul]
    rw [mul_one]
    rfl
  have hmodm : (U : ZMod n).val * a₁ ≡ b₁ [MOD m] :=
    (ZMod.natCast_eq_natCast_iff _ _ _).mp hmul
  have hmodn : g * ((U : ZMod n).val * a₁) ≡ g * b₁ [MOD g * m] := hmodm.mul_left' g
  rw [← hm] at hmodn
  calc (U : ZMod n).val * a = (U : ZMod n).val * (g * a₁) := by rw [ha₁]
    _ = g * ((U : ZMod n).val * a₁) := by ring
    _ ≡ g * b₁ [MOD n] := hmodn
    _ = b := hb₁.symm

/-- The orbit statement in terms of the type map and the change-of-generator permutation. -/
theorem unit_orbit_of_typ_eq {n : ℕ} (hn : 0 < n) {x y : Fin n} (h : typ n x = typ n y) :
    ∃ (u : ℕ) (hu : Nat.Coprime u n), unitPerm n u hn hu x = y := by
  obtain ⟨u, hu, hmod⟩ := unit_orbit_of_gcd_eq hn ((typ_eq_iff_gcd_eq hn x y).mp h)
  refine ⟨u, hu, ?_⟩
  apply Fin.ext
  rw [unitPerm_val hn hu]
  have : (u * x.val) % n = y.val % n := hmod
  rwa [Nat.mod_eq_of_lt y.isLt] at this

/-! ## 3. Invariance characterises the readouts that factor through the type -/

/-- **The converse of generator-invariance.**  A readout of `ℤ/n` is invariant under every change
of generator if and only if it is a function of the splitting type alone. -/
theorem unit_invariant_iff_typ_invariant {n : ℕ} (hn : 0 < n) (t : Fin n → ℕ) :
    (∀ (u : ℕ) (hu : Nat.Coprime u n) (x : Fin n), t (unitPerm n u hn hu x) = t x)
      ↔ ∀ x y : Fin n, typ n x = typ n y → t x = t y := by
  constructor
  · intro hinv x y hxy
    obtain ⟨u, hu, huxy⟩ := unit_orbit_of_typ_eq hn hxy
    rw [← huxy, hinv u hu x]
  · intro hfac u hu x
    exact hfac _ _ (typ_unitPerm hn hu x)

/-- **Explicit factorisation.**  An invariant readout is literally the composition of a function
on types with the type map. -/
theorem exists_factor_through_typ {n : ℕ} (hn : 0 < n) (t : Fin n → ℕ)
    (hinv : ∀ (u : ℕ) (hu : Nat.Coprime u n) (x : Fin n), t (unitPerm n u hn hu x) = t x) :
    ∃ f : ℕ → ℕ, t = f ∘ typ n := by
  classical
  have hfac := (unit_invariant_iff_typ_invariant hn t).mp hinv
  refine ⟨fun d => if h : ∃ x : Fin n, typ n x = d then t h.choose else 0, ?_⟩
  funext x
  have hex : ∃ z : Fin n, typ n z = typ n x := ⟨x, rfl⟩
  simp only [Function.comp_apply, dif_pos hex]
  exact (hfac _ _ hex.choose_spec).symm

/-- An invariant readout has the same histogram, and hence the same entropy, as the induced
function of the type. -/
theorem entropyOf_eq_of_unit_invariant {n : ℕ} (hn : 0 < n) (t : Fin n → ℕ)
    (hinv : ∀ (u : ℕ) (hu : Nat.Coprime u n) (x : Fin n), t (unitPerm n u hn hu x) = t x) :
    ∃ f : ℕ → ℕ, countsOf n t = countsOf n (f ∘ typ n)
      ∧ entropyOf n t = entropyOf n (f ∘ typ n) := by
  obtain ⟨f, hf⟩ := exists_factor_through_typ hn t hinv
  exact ⟨f, by rw [hf], by rw [hf]⟩

/-- **The type is the universal invariant readout.**  The splitting type itself is invariant, and
every invariant readout factors through it; in particular the type map is, up to relabeling of
its values, the finest reproducible observable of the channel. -/
theorem typ_universal_invariant {n : ℕ} (hn : 0 < n) :
    (∀ (u : ℕ) (hu : Nat.Coprime u n) (x : Fin n), typ n (unitPerm n u hn hu x) = typ n x)
      ∧ ∀ t : Fin n → ℕ,
          (∀ (u : ℕ) (hu : Nat.Coprime u n) (x : Fin n), t (unitPerm n u hn hu x) = t x) →
          ∃ f : ℕ → ℕ, t = f ∘ typ n :=
  ⟨fun _ hu x => typ_unitPerm hn hu x, fun t ht => exists_factor_through_typ hn t ht⟩

end CyclicType.Audit