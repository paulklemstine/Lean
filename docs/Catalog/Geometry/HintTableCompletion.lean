/-
# HINT-TABLE-COMPLETION (paper 104): when is the hint universal?

Round-30 experiment #1 of paper 104 reports that all six dials
`C₅@11, F₂₀@5, S₃a@31, S₃b@23, D₄@8, A₄@9` show a positive hint value
`I(T ; s,d) - I(T ; N)` and names the verdict *THE-HINT-IS-UNIVERSAL*.

The catalog already knows (`SumDiffSplit.hintValue_nonneg`) that the hint value is
nonnegative over any ring in which `2` is invertible.  Five of the six moduli (`11, 5, 31, 23,
9`) are odd, so for them positivity-up-to-zero is a theorem, not a measurement.  The sixth,
`D₄@8`, is not covered: `2` is a zero divisor mod `8`.  This file decides exactly what happens
there, and in general.

* `HintTable.TorsionSelector`, `product_le_residue_add_logb`, `neg_logb_le_hintValue` — the
  **two-torsion floor**: if an `F`-valued map separates elements with the same double, then
  `hintValue ≥ -log₂ |F|`.  No invertibility of `2` is assumed.
* `hintValue_nonneg_of_two_torsion_free` — hint nonnegativity only needs `2a = 0 → a = 0`
  (so it covers `ℤ` as well as every odd modulus).
* `halfSelector` — the half-range selector of `ZMod (2k)`; with it,
  `neg_one_le_hintValue_of_even`: **at an even modulus the hint value is at least `-1` bit.**
* `hintValue_eq_neg_one_of_collision`, `exists_hintValue_eq_neg_one` — the floor is attained
  at *every* even modulus: two samples `(0,1),(k,k+1)` (`k` even) or `(0,0),(k,k)` (`k` odd) in
  `ZMod (2k)` share `(s,d)` but have different products.
* `hint_universal_iff_odd` — **THE-HINT-IS-UNIVERSAL exactly at odd moduli**: over `ZMod n`
  every battery has nonnegative hint value iff `n` is odd.
* `hintValue_le_two_logb`, `capacity_add_hintValue_le_label_entropy`,
  `neg_capacity_le_hintValue` — ceiling `2 log₂ n`, and the coupling of capacity and hint
  through the shared label-entropy budget.
* `odd_dial_window`, `D4_dial_window`, `D4_negative_hint` — the six-dial table: five dials
  are confined to `[0, 2 log₂ m]`; `D₄@8` is confined to `[-min(1, I(N)), 6]`, and `-1` is
  attained.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (H1) the hint is universal, i.e. `hintValue ≥ 0` at every modulus;
  (H2) the failure mode, if any, is controlled by the `2`-torsion of the modulus.
Experiment (Stage 2): random batteries (`20 000` per modulus, `2`–`10` samples, `2`–`5`
  labels; see `ComputationalEvidence.md`): minimum hint `0.0` at `m ∈ {5,7,9,11,23,31}` and
  exactly `-1.0` at `m ∈ {8,12,16}`.  Collision witnesses: mod `8`, pairs `(0,1),(4,5)`
  share `(s,d) = (1,1)` with products `0, 4`; mod `6`, pairs `(0,0),(3,3)`, products `0, 3`.
Analysis (Stage 3): (H1) is **false** as stated and **true** exactly at odd moduli; (H2) holds
  in the sharp form `hint ≥ -log₂ |R[2]|`, attained for every even cyclic modulus.  The
  paper-104 table does not contradict this — the `D₄@8` reading `+0.5032` lies inside
  `[-1, 6]` — but its positivity there is an empirical fact about that battery, not a law.
Critique (Stage 4): no numerics enter the theorems; all witnesses are exact.  The six-dial
  table itself is checked against these windows in `Geometry.HintTableLabData`.
-/
import Mathlib
import Algebra.SumDiffHintValue
import Bridges.HintValueMultiFieldCeiling

namespace HintTable

open TraceBattery BatterySynergy SumDiffSplit HintValueMultiField

/-! ## 1. The two-torsion floor -/

/-- A **two-torsion selector** for `R` with values in `F`: separates any two elements with the
same double. -/
structure TorsionSelector (R : Type*) [CommRing R] (F : Type*) where
  sel : R → F
  sound : ∀ a b : R, 2 * a = 2 * b → sel a = sel b → a = b

section Floor

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ : Type*} {R F : Type*} [CommRing R]
  [Fintype F]

theorem product_le_residue_add_logb (L : Ω → Λ) (P Q : Ω → R) (S : TorsionSelector R F) :
    MIb L (productView P Q) ≤ MIb L (residueView P Q) + Real.logb 2 (Fintype.card F) := by
  have h1 : MIb L (pairView P Q) ≤ MIb L (residueView P Q) + Real.logb 2 (Fintype.card F) := by
    refine MIb_le_add_logb_of_refinement L (pairView P Q) (residueView P Q)
      (fun v => S.sel v.1) ?_ ?_
    · intro x y h
      have h1 : P x = P y := congrArg Prod.fst h
      have h2 : Q x = Q y := congrArg Prod.snd h
      simp [residueView, sd, h1, h2]
    · intro x y hg he
      simp only [residueView, sd, Prod.mk.injEq] at hg
      obtain ⟨hs, hd⟩ := hg
      have hp : 2 * P x = 2 * P y := by linear_combination hs - hd
      have hpe : P x = P y := S.sound _ _ hp he
      have hq : Q x = Q y := by linear_combination hs - hpe
      simp [pairView, hpe, hq]
  have h2 : MIb L (productView P Q) ≤ MIb L (pairView P Q) := by
    have : productView P Q = (fun v : R × R => v.1 * v.2) ∘ pairView P Q := rfl
    rw [this]; exact MIb_comp_le L _ _
  linarith

theorem neg_logb_le_hintValue (L : Ω → Λ) (P Q : Ω → R) (S : TorsionSelector R F) :
    -Real.logb 2 (Fintype.card F) ≤ hintValue L P Q := by
  have := product_le_residue_add_logb L P Q S
  simp only [hintValue]; linarith

theorem hintValue_nonneg_of_two_torsion_free (L : Ω → Λ) (P Q : Ω → R)
    (h2 : ∀ a : R, 2 * a = 0 → a = 0) : 0 ≤ hintValue L P Q := by
  let S : TorsionSelector R Unit :=
    ⟨fun _ => (), fun a b h _ => sub_eq_zero.mp (h2 (a - b) (by linear_combination h))⟩
  have := neg_logb_le_hintValue L P Q S
  simpa using this

end Floor

/-! ## 2. Cyclic moduli -/

theorem zmod_two_torsion_free_of_odd {n : ℕ} (hn : Odd n) (a : ZMod n) (ha : 2 * a = 0) :
    a = 0 := by
  have hu : IsUnit (2 : ZMod n) := by
    have := (ZMod.unitOfCoprime 2 (Nat.coprime_two_left.mpr hn)).isUnit
    simpa using this
  exact hu.mul_right_eq_zero.mp ha

/-- The half-range selector of an even modulus. -/
def halfSelector (k : ℕ) [NeZero k] : TorsionSelector (ZMod (2 * k)) Bool where
  sel a := decide (a.val < k)
  sound a b h hs := by
    have hk : 0 < k := Nat.pos_of_ne_zero (NeZero.ne k)
    have ha := ZMod.val_lt a
    have hb := ZMod.val_lt b
    have hmod : 2 * a.val ≡ 2 * b.val [MOD 2 * k] := by
      rw [← ZMod.natCast_eq_natCast_iff]
      push_cast
      simpa [ZMod.natCast_zmod_val] using h
    unfold Nat.ModEq at hmod
    rw [Nat.mul_mod_mul_left, Nat.mul_mod_mul_left] at hmod
    have hm : a.val % k = b.val % k := by omega
    have hs' : (a.val < k ↔ b.val < k) := by simpa using hs
    have key : a.val = b.val := by
      by_cases hak : a.val < k
      · have hbk : b.val < k := hs'.mp hak
        rw [Nat.mod_eq_of_lt hak, Nat.mod_eq_of_lt hbk] at hm
        exact hm
      · have hbk : ¬ b.val < k := fun h => hak (hs'.mpr h)
        have e1 : a.val % k = a.val - k := by
          rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]
        have e2 : b.val % k = b.val - k := by
          rw [Nat.mod_eq_sub_mod (by omega), Nat.mod_eq_of_lt (by omega)]
        omega
    exact ZMod.val_injective _ key

/-! ## 3. Exact readings on two-sample batteries -/

section Readings

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ α : Type*}

/-- A constant reading carries no information. -/
theorem MIb_eq_zero_of_const (L : Ω → Λ) (f : Ω → α) (h : ∀ x y, f x = f y) :
    MIb L f = 0 := by
  obtain ⟨x₀⟩ := ‹Nonempty Ω›
  have hf : f = (fun _ : Unit => f x₀) ∘ (fun _ : Ω => ()) := by
    funext x; exact h x x₀
  have h1 : MIb L f ≤ MIb L (fun _ : Ω => ()) := by
    rw [hf]; exact MIb_comp_le L _ _
  have h2 : MIb L (fun _ : Ω => ()) ≤ Hb (fun _ : Ω => ()) := MIb_le_stat_entropy L _
  have h3 : Hb (fun _ : Ω => ()) ≤ Real.logb 2 (Fintype.card Unit) := Hb_le_logb_card _
  have h4 := MIb_nonneg L f
  simp at h3
  linarith

end Readings

/-- The two-sample label: sample `0` gets label `0`, sample `1` gets label `1`. -/
def twoLabels : Fin 2 → Fin 2 := ![0, 1]

theorem Hb_twoLabels : Hb twoLabels = 1 := by
  have hc : ∀ a ∈ img twoLabels, cnt twoLabels a = 1 := by
    intro a ha
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    rw [cnt, fib_eq_filter]
    fin_cases x <;> decide
  rw [Hb, H_eq_log_sub_log_of_uniform twoLabels 1 one_pos hc]
  simp [div_self (ne_of_gt log_two_pos)]

/-- **The negative-hint mechanism.**  If two samples share their sum/difference residues but
differ in their products, labelling them apart gives a hint value of exactly `-1` bit: the
product view pins the label, the joint residue view is blind. -/
theorem hintValue_eq_neg_one_of_collision {R : Type*} [CommRing R] (P Q : Fin 2 → R)
    (hres : residueView P Q 0 = residueView P Q 1)
    (hprod : productView P Q 0 ≠ productView P Q 1) :
    hintValue twoLabels P Q = -1 := by
  have h1 : MIb twoLabels (residueView P Q) = 0 := by
    refine MIb_eq_zero_of_const _ _ fun x y => ?_
    fin_cases x <;> fin_cases y <;> simp [hres]
  have h2 : MIb twoLabels (productView P Q) = 1 := by
    rw [MIb_eq_label_entropy_of_determines, Hb_twoLabels]
    intro x y hxy
    fin_cases x <;> fin_cases y <;> simp_all [eq_comm]
  rw [hintValue, h1, h2]; norm_num

/-! ## 4. The odd/even dichotomy -/

/-- **Every even cyclic modulus carries a collision battery with hint value `-1`.** -/
theorem exists_hintValue_eq_neg_one (k : ℕ) [NeZero k] :
    ∃ P Q : Fin 2 → ZMod (2 * k), hintValue twoLabels P Q = -1 := by
  have hk : 0 < k := Nat.pos_of_ne_zero (NeZero.ne k)
  have h2k : ((2 * k : ℕ) : ZMod (2 * k)) = 0 := ZMod.natCast_self _
  rcases Nat.even_or_odd k with hev | hod
  · refine ⟨![0, (k : ZMod (2 * k))], ![1, (k : ZMod (2 * k)) + 1], ?_⟩
    apply hintValue_eq_neg_one_of_collision
    · simp only [residueView, sd, Matrix.cons_val_zero, Matrix.cons_val_one, Prod.mk.injEq]
      push_cast at h2k
      constructor
      · linear_combination -h2k
      · ring
    · simp only [productView, Matrix.cons_val_zero, Matrix.cons_val_one, zero_mul]
      intro h
      have h' : ((k * (k + 1) : ℕ) : ZMod (2 * k)) = 0 := by push_cast; exact h.symm
      rw [ZMod.natCast_eq_zero_iff] at h'
      obtain ⟨c, hc⟩ := h'
      have : k + 1 = 2 * c := by
        have : k * (k + 1) = k * (2 * c) := by rw [hc]; ring
        exact Nat.eq_of_mul_eq_mul_left hk this
      obtain ⟨j, hj⟩ := hev
      omega
  · refine ⟨![0, (k : ZMod (2 * k))], ![0, (k : ZMod (2 * k))], ?_⟩
    apply hintValue_eq_neg_one_of_collision
    · simp only [residueView, sd, Matrix.cons_val_zero, Matrix.cons_val_one, Prod.mk.injEq]
      push_cast at h2k
      constructor
      · linear_combination -h2k
      · ring
    · simp only [productView, Matrix.cons_val_zero, Matrix.cons_val_one, zero_mul]
      intro h
      have h' : ((k * k : ℕ) : ZMod (2 * k)) = 0 := by push_cast; exact h.symm
      rw [ZMod.natCast_eq_zero_iff] at h'
      obtain ⟨c, hc⟩ := h'
      have : k = 2 * c := by
        have : k * k = k * (2 * c) := by rw [hc]; ring
        exact Nat.eq_of_mul_eq_mul_left hk this
      obtain ⟨j, hj⟩ := hod
      omega

/-- **The universal floor at odd moduli.** -/
theorem hintValue_nonneg_of_odd {n : ℕ} (hn : Odd n) {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    {Λ : Type*} (L : Ω → Λ) (P Q : Ω → ZMod n) : 0 ≤ hintValue L P Q :=
  hintValue_nonneg_of_two_torsion_free L P Q (zmod_two_torsion_free_of_odd hn)

/-- **The sharp floor at even moduli**: never below `-1` bit. -/
theorem neg_one_le_hintValue_of_even {n : ℕ} [NeZero n] (hn : Even n) {Ω : Type*} [Fintype Ω]
    [Nonempty Ω] {Λ : Type*} (L : Ω → Λ) (P Q : Ω → ZMod n) : -1 ≤ hintValue L P Q := by
  obtain ⟨k, rfl⟩ := hn.two_dvd
  haveI : NeZero k := ⟨by rintro rfl; exact NeZero.ne (2 * 0) rfl⟩
  have := neg_logb_le_hintValue L P Q (halfSelector k)
  simpa using this

/-- **THE-HINT-IS-UNIVERSAL exactly at odd moduli.** -/
theorem hint_universal_iff_odd (n : ℕ) [NeZero n] :
    (∀ (L : Fin 2 → Fin 2) (P Q : Fin 2 → ZMod n), 0 ≤ hintValue L P Q) ↔ Odd n := by
  constructor
  · intro h
    by_contra hodd
    have hev : Even n := Nat.not_odd_iff_even.mp hodd
    obtain ⟨k, rfl⟩ := hev.two_dvd
    haveI : NeZero k := ⟨by rintro rfl; exact NeZero.ne (2 * 0) rfl⟩
    obtain ⟨P, Q, hPQ⟩ := exists_hintValue_eq_neg_one k
    have := h twoLabels P Q
    linarith
  · intro hn L P Q
    exact hintValue_nonneg_of_odd hn L P Q

/-! ## 5. Ceiling, coupling and the six-dial window -/

section Window

variable {Ω : Type*} [Fintype Ω] {Λ : Type*}

/-- **Modulus ceiling.**  Over `ZMod n` the hint value is at most `2 log₂ n` bits. -/
theorem hintValue_le_two_logb {n : ℕ} [NeZero n] (L : Ω → Λ) (P Q : Ω → ZMod n) :
    hintValue L P Q ≤ 2 * Real.logb 2 n := by
  have h1 : MIb L (residueView P Q) ≤ Hb (residueView P Q) := MIb_le_stat_entropy L _
  have h2 : Hb (residueView P Q) ≤ Real.logb 2 (Fintype.card (ZMod n × ZMod n)) :=
    Hb_le_logb_card _
  have h5 : 0 ≤ MIb L (productView P Q) := MIb_nonneg L _
  have hn : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (NeZero.ne n)
  have h3 : Real.logb 2 (Fintype.card (ZMod n × ZMod n) : ℝ) = 2 * Real.logb 2 n := by
    rw [Fintype.card_prod, ZMod.card]; push_cast
    rw [Real.logb_mul hn hn]; ring
  simp only [hintValue]; linarith

/-- Capacity plus hint is the joint residue reading. -/
theorem capacity_add_hintValue {R : Type*} [CommRing R] (L : Ω → Λ) (P Q : Ω → R) :
    MIb L (productView P Q) + hintValue L P Q = MIb L (residueView P Q) := by
  simp only [hintValue]; ring

/-- **The coupling ceiling.**  Capacity and hint share the label-entropy budget. -/
theorem capacity_add_hintValue_le_label_entropy {R : Type*} [CommRing R] (L : Ω → Λ)
    (P Q : Ω → R) : MIb L (productView P Q) + hintValue L P Q ≤ Hb L := by
  rw [capacity_add_hintValue]; exact MIb_le_label_entropy L _

/-- **The coupling floor.**  A hint can never destroy more than the capacity. -/
theorem neg_capacity_le_hintValue {R : Type*} [CommRing R] (L : Ω → Λ) (P Q : Ω → R) :
    -MIb L (productView P Q) ≤ hintValue L P Q := by
  have := MIb_nonneg L (residueView P Q)
  simp only [hintValue]; linarith

/-- **The five odd dials** (`C₅@11`, `F₂₀@5`, `S₃a@31`, `S₃b@23`, `A₄@9`): every battery has
hint value in `[0, 2 log₂ m]`. -/
theorem odd_dial_window {m : ℕ} (hm : m ∈ ({11, 5, 31, 23, 9} : Finset ℕ)) [Nonempty Ω]
    (L : Ω → Λ) (P Q : Ω → ZMod m) :
    0 ≤ hintValue L P Q ∧ hintValue L P Q ≤ 2 * Real.logb 2 m := by
  have hodd : Odd m := by
    simp only [Finset.mem_insert, Finset.mem_singleton] at hm
    rcases hm with rfl | rfl | rfl | rfl | rfl <;> decide
  haveI : NeZero m := ⟨by rintro rfl; exact absurd hodd (by decide)⟩
  exact ⟨hintValue_nonneg_of_odd hodd L P Q, hintValue_le_two_logb L P Q⟩

/-- **The `D₄@8` dial**: the only dial whose positivity is not forced.  Every battery mod `8`
has hint value in `[-min(1, I(N)), 6]`: at least `-1` bit and at least `-I(N)`. -/
theorem D4_dial_window [Nonempty Ω] (L : Ω → Λ) (P Q : Ω → ZMod 8) :
    -1 ≤ hintValue L P Q ∧ -MIb L (productView P Q) ≤ hintValue L P Q ∧
      hintValue L P Q ≤ 6 := by
  refine ⟨neg_one_le_hintValue_of_even (by decide) L P Q, neg_capacity_le_hintValue L P Q, ?_⟩
  have h := hintValue_le_two_logb L P Q
  have h8 : Real.logb 2 ((8 : ℕ) : ℝ) = 3 := by
    rw [show ((8 : ℕ) : ℝ) = 2 ^ (3 : ℕ) by norm_num, Real.logb_pow]; simp
  rw [h8] at h; linarith

end Window

/-- **The `D₄@8` floor is attained**: a two-sample battery mod `8` with hint value `-1`. -/
theorem D4_negative_hint : ∃ P Q : Fin 2 → ZMod 8, hintValue twoLabels P Q = -1 :=
  exists_hintValue_eq_neg_one 4

end HintTable