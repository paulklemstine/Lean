/-
# Round-to-nearest meshes: exact defect constants, grouping, and non-transfer of a bit floor

This file is the formal shadow of the NET-52 experimental round
(*THE-TOY-FOUR-BIT-FLOOR-DOES-NOT-TRANSFER*).  The experiment measured the cross-entropy
damage of naive per-channel round-to-nearest (RTN) quantization of a pretrained transformer
at 2–8 bits, with and without grouping.  Four qualitative facts were observed:

* the damage is strictly monotone in the mesh and already nonzero at 8 bits;
* the constant in the mesh bound behaves as if it were *sharp* (no slack to exploit);
* grouping repairs a definite fraction of the damage;
* a "4-bit floor" calibrated on small from-scratch toys fails by more than an order of
  magnitude on pretrained weights.

Here we prove the underlying arithmetic statements, in a form that makes clear *why* the last
one is not a surprise but a theorem: the worst-case defect of an absmax `b`-bit quantizer is

`K · n · A / 2 ^ (b+1)`

and this is **attained**, so it depends on the amplitude `A` and the width `n` of the tensor,
never on the bit budget alone.  A floor stated in bits only is therefore empty: for every bit
budget and every prescribed budget `c` there is a weight vector exceeding it
(`toy_floor_does_not_transfer`).

Main results:

* `abs_rtn_sub_le` / `rtn_error_at_half` / `rtn_defect_constant_sharp` — the `Δ/2` mesh bound
  and its exact attainment (Mathlib's `round` breaks ties upwards).
* `mesh_succ`, `mesh_strictAnti` — one extra bit exactly halves the mesh.
* `l1_defect_le`, `l1_defect_sharp` — aggregate bound over a width-`n` tensor, attained.
* `lipschitz_defect_le`, `lipschitz_defect_sharp` — the `defect ≤ K n Δ/2` transfer bound with
  a matching witness, i.e. the constant cannot be improved.
* `grouped_defect_le_global`, `grouped_defect_lt_global` — grouping never hurts and strictly
  helps as soon as one group has smaller amplitude.
* `toy_floor_does_not_transfer` — no bits-only defect floor exists.
-/
import Mathlib

namespace Catalog.NumberTheory.QuantMesh

open Finset

/-! ## The scalar quantizer -/

/-- Round-to-nearest quantization onto the mesh `Δ ℤ`. -/
noncomputable def rtn (Δ x : ℝ) : ℝ := Δ * round (x / Δ)

/-- The mesh of a `b`-bit absmax quantizer for a tensor of amplitude `A`. -/
noncomputable def mesh (A : ℝ) (b : ℕ) : ℝ := A / 2 ^ b

lemma mesh_pos {A : ℝ} (hA : 0 < A) (b : ℕ) : 0 < mesh A b := by
  have : (0:ℝ) < 2 ^ b := by positivity
  simpa [mesh] using div_pos hA this

/-- One extra bit halves the mesh exactly. -/
lemma mesh_succ (A : ℝ) (b : ℕ) : mesh A (b + 1) = mesh A b / 2 := by
  simp only [mesh, pow_succ]
  ring

/-- The mesh is strictly decreasing in the bit budget. -/
lemma mesh_strictAnti {A : ℝ} (hA : 0 < A) : StrictAnti (mesh A) := by
  intro b c hbc
  have h2 : (1:ℝ) < 2 := by norm_num
  have : (2:ℝ) ^ b < 2 ^ c := pow_lt_pow_right₀ h2 hbc
  have hb : (0:ℝ) < 2 ^ b := by positivity
  exact div_lt_div_of_pos_left hA hb this

/-- The mesh is monotone in the amplitude at a fixed bit budget: this is why a group's mesh is
dominated by the whole tensor's mesh. -/
lemma mesh_mono_amplitude {A B : ℝ} (h : A ≤ B) (b : ℕ) : mesh A b ≤ mesh B b := by
  unfold mesh
  gcongr

/-- **Mesh bound.**  Round-to-nearest never moves a number by more than half a mesh. -/
theorem abs_rtn_sub_le {Δ : ℝ} (hΔ : 0 < Δ) (x : ℝ) : |rtn Δ x - x| ≤ Δ / 2 := by
  have hx : rtn Δ x - x = Δ * ((round (x / Δ) : ℝ) - x / Δ) := by
    simp only [rtn]
    field_simp
  rw [hx, abs_mul, abs_of_pos hΔ]
  have h : |(round (x / Δ) : ℝ) - x / Δ| ≤ 1 / 2 := by
    rw [abs_sub_comm]; exact abs_sub_round (x / Δ)
  nlinarith [abs_nonneg ((round (x / Δ) : ℝ) - x / Δ)]

/-- The bound is attained at the midpoint of a cell: Mathlib's `round` rounds ties up. -/
theorem rtn_error_at_half {Δ : ℝ} (hΔ : 0 < Δ) : rtn Δ (Δ / 2) - Δ / 2 = Δ / 2 := by
  have h : (Δ / 2) / Δ = 1 / 2 := by field_simp
  have hr : round ((Δ / 2) / Δ) = 1 := by
    rw [h]; norm_num
  simp only [rtn, hr]
  push_cast
  ring

/-- The midpoint is pushed to the top of its cell. -/
lemma rtn_at_half {Δ : ℝ} (hΔ : 0 < Δ) : rtn Δ (Δ / 2) = Δ := by
  have := rtn_error_at_half hΔ
  linarith

/-- **Sharpness of the mesh constant.**  No constant smaller than `1/2` works. -/
theorem rtn_defect_constant_sharp {Δ c : ℝ} (hΔ : 0 < Δ)
    (h : ∀ x : ℝ, |rtn Δ x - x| ≤ c * Δ) : 1 / 2 ≤ c := by
  have hh := h (Δ / 2)
  rw [rtn_error_at_half hΔ, abs_of_pos (by linarith : (0:ℝ) < Δ / 2)] at hh
  nlinarith

/-! ## Tensors: the aggregate defect -/

private lemma sum_const_fin (n : ℕ) (c : ℝ) : ∑ _i : Fin n, c = n * c := by
  rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]

private lemma sum_const_half_fin (n : ℕ) (Δ : ℝ) : ∑ _i : Fin n, Δ / 2 = n * Δ / 2 := by
  rw [sum_const_fin]; ring

/-- Coordinatewise quantization with a (possibly coordinate-dependent) mesh. -/
noncomputable def quantVec {n : ℕ} (Δ : Fin n → ℝ) (w : Fin n → ℝ) : Fin n → ℝ :=
  fun i => rtn (Δ i) (w i)

/-- `ℓ¹` defect bound for a coordinatewise quantizer. -/
theorem l1_defect_le {n : ℕ} {Δ : Fin n → ℝ} (hΔ : ∀ i, 0 < Δ i) (w : Fin n → ℝ) :
    ∑ i, |quantVec Δ w i - w i| ≤ ∑ i, Δ i / 2 :=
  Finset.sum_le_sum fun i _ => abs_rtn_sub_le (hΔ i) (w i)

/-- With a uniform mesh the bound reads `n Δ / 2`. -/
theorem l1_defect_le_uniform {n : ℕ} {Δ : ℝ} (hΔ : 0 < Δ) (w : Fin n → ℝ) :
    ∑ i, |quantVec (fun _ => Δ) w i - w i| ≤ n * Δ / 2 :=
  (l1_defect_le (n := n) (Δ := fun _ => Δ) (fun _ => hΔ) w).trans_eq (sum_const_half_fin n Δ)

/-- **The aggregate bound is attained**: the all-midpoints tensor realizes `n Δ / 2`. -/
theorem l1_defect_sharp (n : ℕ) {Δ : ℝ} (hΔ : 0 < Δ) :
    ∑ i, |quantVec (n := n) (fun _ => Δ) (fun _ => Δ / 2) i - Δ / 2| = n * Δ / 2 := by
  have hpt : ∀ i : Fin n,
      |quantVec (n := n) (fun _ => Δ) (fun _ => Δ / 2) i - Δ / 2| = Δ / 2 := by
    intro i
    have h : quantVec (n := n) (fun _ => Δ) (fun _ => Δ / 2) i - Δ / 2 = Δ / 2 := by
      simpa [quantVec] using rtn_error_at_half hΔ
    rw [h, abs_of_pos (by linarith : (0:ℝ) < Δ / 2)]
  rw [Finset.sum_congr rfl fun i _ => hpt i, sum_const_half_fin]

/-! ## Transfer through a Lipschitz loss -/

/-- The defect a `K`-Lipschitz (for the `ℓ¹` metric) loss can suffer from quantization. -/
theorem lipschitz_defect_le {n : ℕ} {Δ K : ℝ} (hΔ : 0 < Δ) (hK : 0 ≤ K)
    (f : (Fin n → ℝ) → ℝ)
    (hf : ∀ u v : Fin n → ℝ, |f u - f v| ≤ K * ∑ i, |u i - v i|)
    (w : Fin n → ℝ) :
    |f (quantVec (fun _ => Δ) w) - f w| ≤ K * (n * Δ / 2) :=
  (hf _ w).trans (mul_le_mul_of_nonneg_left (l1_defect_le_uniform hΔ w) hK)

/-- **The transfer constant is sharp.**  For every width and mesh there is a `1`-Lipschitz loss
and a weight tensor for which the bound `n Δ / 2` holds with equality. -/
theorem lipschitz_defect_sharp (n : ℕ) {Δ : ℝ} (hΔ : 0 < Δ) :
    ∃ f : (Fin n → ℝ) → ℝ,
      (∀ u v : Fin n → ℝ, |f u - f v| ≤ 1 * ∑ i, |u i - v i|) ∧
      ∃ w : Fin n → ℝ, |f (quantVec (fun _ => Δ) w) - f w| = n * Δ / 2 := by
  refine ⟨fun u => ∑ i, u i, ?_, fun _ => Δ / 2, ?_⟩
  · intro u v
    rw [one_mul, ← Finset.sum_sub_distrib]
    exact Finset.abs_sum_le_sum_abs _ _
  · have hpt : ∀ i : Fin n, quantVec (n := n) (fun _ => Δ) (fun _ => Δ / 2) i = Δ := by
      intro i
      simpa [quantVec] using rtn_at_half hΔ
    show |∑ i, quantVec (n := n) (fun _ => Δ) (fun _ => Δ / 2) i - ∑ _i : Fin n, Δ / 2|
        = n * Δ / 2
    rw [Finset.sum_congr rfl fun i _ => hpt i, sum_const_fin, sum_const_half_fin]
    have h : (n:ℝ) * Δ - n * Δ / 2 = n * Δ / 2 := by ring
    rw [h, abs_of_nonneg (by positivity)]

/-! ## Grouping -/

/-- **Grouping never hurts.**  If the group meshes `Δ i` are all at most the global mesh `D`
(they are, by `mesh_mono_amplitude`), the aggregate bound improves. -/
theorem grouped_defect_le_global {n : ℕ} {Δ : Fin n → ℝ} {D : ℝ}
    (hle : ∀ i, Δ i ≤ D) : ∑ i, Δ i / 2 ≤ n * D / 2 := by
  refine (Finset.sum_le_sum fun i _ => ?_ : ∑ i, Δ i / 2 ≤ ∑ _i : Fin n, D / 2).trans_eq
    (sum_const_half_fin n D)
  linarith [hle i]

/-- **Grouping strictly helps** as soon as one group has strictly smaller amplitude. -/
theorem grouped_defect_lt_global {n : ℕ} {Δ : Fin n → ℝ} {D : ℝ}
    (hle : ∀ i, Δ i ≤ D) {i₀ : Fin n} (hlt : Δ i₀ < D) : ∑ i, Δ i / 2 < n * D / 2 := by
  refine (Finset.sum_lt_sum (fun i _ => by linarith [hle i])
    ⟨i₀, Finset.mem_univ _, by linarith⟩ : ∑ i, Δ i / 2 < ∑ _i : Fin n, D / 2).trans_eq
    (sum_const_half_fin n D)

/-- **Exact grouping gain.**  The damage bound repaired by grouping is exactly half the total
amplitude deficit of the groups relative to the global amplitude; equivalently the grouped
bound is the *average* group mesh where the global bound uses the maximum. -/
theorem grouping_gain_eq {n : ℕ} (Δ : Fin n → ℝ) (D : ℝ) :
    n * D / 2 - ∑ i, Δ i / 2 = (∑ i, (D - Δ i)) / 2 := by
  have h1 : ∑ i, Δ i / 2 = (∑ i, Δ i) / 2 := by rw [Finset.sum_div]
  have h2 : ∑ i, (D - Δ i) = n * D - ∑ i, Δ i := by
    rw [Finset.sum_sub_distrib, sum_const_fin]
  rw [h1, h2]
  ring

/-! ## No bits-only floor -/

/-- **THE-TOY-FOUR-BIT-FLOOR-DOES-NOT-TRANSFER (formal form).**

For *every* bit budget `b` and every prescribed damage budget `c`, there is an amplitude `A`
and a weight tensor of that amplitude on which the `b`-bit absmax RTN quantizer makes a
`1`-Lipschitz loss move by more than `c`.  Hence no statement of the form "`b` bits cost at
most `c`" can be a theorem: any such floor is a statement about the amplitude (and width) of
the particular tensors it was calibrated on, not about the bit budget. -/
theorem toy_floor_does_not_transfer (b : ℕ) (c : ℝ) :
    ∃ (A : ℝ) (w : Fin 1 → ℝ) (f : (Fin 1 → ℝ) → ℝ),
      0 < A ∧ (∀ u v : Fin 1 → ℝ, |f u - f v| ≤ 1 * ∑ i, |u i - v i|) ∧
      (∀ i, |w i| ≤ A) ∧
      c < |f (quantVec (fun _ => mesh A b) w) - f w| := by
  set A : ℝ := (|c| + 1) * 2 ^ (b + 1) with hA
  have h2 : (0:ℝ) < 2 ^ (b + 1) := by positivity
  have hApos : 0 < A := mul_pos (by positivity) h2
  have hΔ : 0 < mesh A b := mesh_pos hApos b
  have hmesh : mesh A b / 2 = |c| + 1 := by
    rw [hA, mesh, pow_succ]
    field_simp
  refine ⟨A, fun _ => mesh A b / 2, fun u => ∑ i, u i, hApos, ?_, ?_, ?_⟩
  · intro u v
    rw [one_mul, ← Finset.sum_sub_distrib]
    exact Finset.abs_sum_le_sum_abs _ _
  · intro i
    rw [abs_of_pos (by linarith : (0:ℝ) < mesh A b / 2)]
    have hle : mesh A b ≤ A := by
      have h1 : (1:ℝ) ≤ 2 ^ b := one_le_pow₀ (by norm_num)
      rw [mesh, div_le_iff₀ (by positivity)]
      nlinarith [hApos]
    linarith
  · have hpt : ∀ i : Fin 1,
        quantVec (n := 1) (fun _ => mesh A b) (fun _ => mesh A b / 2) i = mesh A b := by
      intro i
      simpa [quantVec] using rtn_at_half hΔ
    show c < |∑ i, quantVec (n := 1) (fun _ => mesh A b) (fun _ => mesh A b / 2) i
        - ∑ _i : Fin 1, mesh A b / 2|
    rw [Finset.sum_congr rfl fun i _ => hpt i, sum_const_fin, sum_const_half_fin]
    have h : ((1:ℕ):ℝ) * mesh A b - ((1:ℕ):ℝ) * mesh A b / 2 = mesh A b / 2 := by
      push_cast; ring
    rw [h, abs_of_pos (by linarith : (0:ℝ) < mesh A b / 2), hmesh]
    linarith [le_abs_self c]

end Catalog.NumberTheory.QuantMesh