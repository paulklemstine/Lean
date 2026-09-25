/-
# HINT-TABLE-COMPLETION, part II: capacity and hint are independent coordinates

Paper 104 reports a weak hint–capacity correlation (`r = 0.256`) across six dials and reads
it as "hint value and channel capacity are independent dial properties".  This file proves
the structural version of that claim, on exact batteries over `ZMod 5`:

* `HintTable.four_corners` — the pair `(I(T;N), hintValue)` attains all four points of
  `{0,1}²` with four samples and four labels;
* `hint_not_function_of_capacity`, `capacity_not_function_of_hint` — neither coordinate is a
  function of the other;
* the independence is limited only by the shared budget
  `capacity + hint ≤ H(T)` (`capacity_add_hintValue_le_label_entropy`, part I).

-- !-- Lab Notes -- !--
Hypothesis: the weak correlation is not an accident of six data points but reflects functional
  independence.  Experiment: the four corner batteries (mod `5`, samples `(1,1),(1,2),(2,3),(2,1)`
  and `(1,1),(1,1),(1,2),(1,2)`) read exactly `(0,0), (0,1), (1,0), (1,1)` bits.  Analysis:
  capacity sees the product partition, hint sees how much finer the `(s,d)` partition is
  relative to it — two independent partition features.  Critique: "independent" here means
  functional independence plus a joint budget; it does not mean statistical independence
  over any distribution on dials.
-/
import Mathlib
import Geometry.HintTableCompletion

namespace HintTable

open TraceBattery BatterySynergy SumDiffSplit HintValueMultiField

/-! ## 6. Capacity and hint are functionally independent -/

section Calculus

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {Λ α : Type*}

/-- If the label determines the statistic, the reading is the whole entropy of the
statistic. -/
theorem MIb_eq_stat_entropy_of_label_determines (L : Ω → Λ) (f : Ω → α)
    (h : ∀ x y, L x = L y → f x = f y) : MIb L f = Hb f := by
  have hpr : H (pr L f) = H L := by
    refine H_eq_of_same_fibers (pr L f) L fun x y => ?_
    simp only [pr, Prod.mk.injEq]
    exact ⟨fun h' => h'.1, fun h' => ⟨h', h x y h'⟩⟩
  rw [MIb, Hb, MI_eq, hpr]
  ring_nf

end Calculus

namespace Corners

theorem log_four : Real.log 4 = 2 * Real.log 2 := by
  rw [show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.log_pow]; push_cast; ring

/-- Entropy of a uniform statistic on four samples. -/
theorem H_four {α : Type*} (f : Fin 4 → α) (k : ℕ) (hk : 0 < k)
    (hc : ∀ x : Fin 4, cnt f (f x) = k) : H f = Real.log 4 - Real.log (k : ℝ) := by
  have h : ∀ a ∈ img f, cnt f a = k := by
    intro a ha
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    exact hc x
  have := H_eq_log_sub_log_of_uniform f k hk h
  simpa using this

theorem cnt_filter {α : Type*} [DecidableEq α] (f : Fin 4 → α) (a : α) :
    cnt f a = (Finset.univ.filter fun x => f x = a).card := by
  rw [cnt, fib_eq_filter]

/-- Constant labels. -/
def Lzero : Fin 4 → Fin 4 := fun _ => 0
/-- Two label classes of size two. -/
def Lhalf : Fin 4 → Fin 4 := ![0, 0, 1, 1]
/-- Four distinct labels. -/
def Lid : Fin 4 → Fin 4 := ![0, 1, 2, 3]
/-- A battery whose pairs and products both split as `{0,1} | {2,3}`. -/
def Pc : Fin 4 → ZMod 5 := ![1, 1, 1, 1]
def Qc : Fin 4 → ZMod 5 := ![1, 1, 2, 2]

theorem Hb_Lzero : Hb Lzero = 0 := by
  rw [Hb, H_four Lzero 4 (by norm_num) (fun x => by rw [cnt_filter]; fin_cases x <;> decide)]
  simp

theorem Hb_Lhalf : Hb Lhalf = 1 := by
  rw [Hb, H_four Lhalf 2 (by norm_num) (fun x => by rw [cnt_filter]; fin_cases x <;> decide),
    log_four]
  have := log_two_pos
  field_simp
  push_cast; ring

theorem Hb_Lid : Hb Lid = 2 := by
  rw [Hb, H_four Lid 1 (by norm_num) (fun x => by rw [cnt_filter]; fin_cases x <;> decide),
    log_four]
  have := log_two_pos
  field_simp
  simp

/-- The witness battery's product view takes two values, each twice. -/
theorem Hb_product_witness : Hb (productView Witness.P Witness.Q) = 1 := by
  rw [Hb, H_four _ 2 (by norm_num) Witness.cnt_prod, log_four]
  have := log_two_pos
  field_simp
  push_cast; ring

theorem MIb_zero_labels {α : Type*} (f : Fin 4 → α) : MIb Lzero f = 0 := by
  have h1 := MIb_le_label_entropy Lzero f
  have h2 := MIb_nonneg Lzero f
  rw [Hb_Lzero] at h1
  linarith

/-- Corner `(0,0)`: constant labels. -/
theorem corner00 : MIb Lzero (productView Witness.P Witness.Q) = 0 ∧
    hintValue Lzero Witness.P Witness.Q = 0 := by
  refine ⟨MIb_zero_labels _, ?_⟩
  rw [hintValue, MIb_zero_labels, MIb_zero_labels, sub_zero]

/-- Corner `(0,1)`: the round-29 witness, re-labelled into `Fin 4`. -/
theorem corner01 : MIb Lhalf (productView Witness.P Witness.Q) = 0 ∧
    hintValue Lhalf Witness.P Witness.Q = 1 := by
  have hprod : MIb Lhalf (productView Witness.P Witness.Q) = 0 := by
    have hf : H (productView Witness.P Witness.Q) = Real.log 4 - Real.log 2 := by
      have := H_four _ 2 (by norm_num) Witness.cnt_prod
      simpa using this
    have hL : H Lhalf = Real.log 4 - Real.log 2 := by
      have := H_four Lhalf 2 (by norm_num)
        (fun x => by rw [cnt_filter]; fin_cases x <;> decide)
      simpa using this
    have hpr : H (pr Lhalf (productView Witness.P Witness.Q)) = Real.log 4 := by
      have := H_four (pr Lhalf (productView Witness.P Witness.Q)) 1 (by norm_num)
        (fun x => by rw [cnt_filter]; fin_cases x <;> decide)
      simpa using this
    rw [MIb, MI_eq, hL, hf, hpr, log_four]; ring
  have hres : MIb Lhalf (residueView Witness.P Witness.Q) = 1 := by
    rw [MIb_eq_label_entropy_of_determines, Hb_Lhalf]
    intro x y
    fin_cases x <;> fin_cases y <;> decide
  exact ⟨hprod, by rw [hintValue, hres, hprod, sub_zero]⟩

/-- Corner `(1,0)`: product-measurable labels. -/
theorem corner10 : MIb Lhalf (productView Pc Qc) = 1 ∧ hintValue Lhalf Pc Qc = 0 := by
  have hprod : MIb Lhalf (productView Pc Qc) = 1 := by
    rw [MIb_eq_label_entropy_of_determines, Hb_Lhalf]
    intro x y
    fin_cases x <;> fin_cases y <;> decide
  have hres : MIb Lhalf (residueView Pc Qc) = 1 := by
    rw [MIb_eq_label_entropy_of_determines, Hb_Lhalf]
    intro x y
    fin_cases x <;> fin_cases y <;> decide
  exact ⟨hprod, by rw [hintValue, hres, hprod, sub_self]⟩

/-- Corner `(1,1)`: distinct labels on the witness battery. -/
theorem corner11 : MIb Lid (productView Witness.P Witness.Q) = 1 ∧
    hintValue Lid Witness.P Witness.Q = 1 := by
  have hprod : MIb Lid (productView Witness.P Witness.Q) = 1 := by
    rw [MIb_eq_stat_entropy_of_label_determines, Hb_product_witness]
    intro x y
    fin_cases x <;> fin_cases y <;> decide
  have hres : MIb Lid (residueView Witness.P Witness.Q) = 2 := by
    rw [MIb_eq_label_entropy_of_determines, Hb_Lid]
    intro x y
    fin_cases x <;> fin_cases y <;> decide
  refine ⟨hprod, ?_⟩
  rw [hintValue, hres, hprod]; norm_num

end Corners

open Corners

/-- **The four corners.**  Over `ZMod 5` with four samples and four labels, the pair
(capacity, hint value) attains all four points of `{0,1}²`. -/
theorem four_corners :
    (∃ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5),
        MIb L (productView P Q) = 0 ∧ hintValue L P Q = 0) ∧
    (∃ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5),
        MIb L (productView P Q) = 0 ∧ hintValue L P Q = 1) ∧
    (∃ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5),
        MIb L (productView P Q) = 1 ∧ hintValue L P Q = 0) ∧
    (∃ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5),
        MIb L (productView P Q) = 1 ∧ hintValue L P Q = 1) :=
  ⟨⟨_, _, _, corner00⟩, ⟨_, _, _, corner01⟩, ⟨_, _, _, corner10⟩, ⟨_, _, _, corner11⟩⟩

/-- **Hint value is not a function of capacity.** -/
theorem hint_not_function_of_capacity :
    ¬ ∃ φ : ℝ → ℝ, ∀ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5),
        hintValue L P Q = φ (MIb L (productView P Q)) := by
  rintro ⟨φ, hφ⟩
  have h1 := hφ Lzero Witness.P Witness.Q
  have h2 := hφ Lhalf Witness.P Witness.Q
  rw [corner00.1, corner00.2] at h1
  rw [corner01.1, corner01.2] at h2
  linarith

/-- **Capacity is not a function of hint value.** -/
theorem capacity_not_function_of_hint :
    ¬ ∃ ψ : ℝ → ℝ, ∀ (L : Fin 4 → Fin 4) (P Q : Fin 4 → ZMod 5),
        MIb L (productView P Q) = ψ (hintValue L P Q) := by
  rintro ⟨ψ, hψ⟩
  have h1 := hψ Lhalf Witness.P Witness.Q
  have h2 := hψ Lid Witness.P Witness.Q
  rw [corner01.1, corner01.2] at h1
  rw [corner11.1, corner11.2] at h2
  linarith

end HintTable