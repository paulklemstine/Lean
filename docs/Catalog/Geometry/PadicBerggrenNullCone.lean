import Catalog.Geometry.PadicBerggrenDynamics

/-!
# The size of the p-adic Berggren null cone

`Catalog/Geometry/PadicBerggrenDynamics.lean` sets up the three Berggren (Barning–Hall)
generators as a dynamical system on `(ZMod (p^k))³` preserving the Lorentz form
`q(a,b,c) = a² + b² − c²`.  Every state of that system lives on the **null cone**
`q = 0`, and the whole Berggren tree reduces into it.

This file computes the exact size of the phase space:

* `PadicBerggren.card_nullCone` : for every odd prime `p` the null cone mod `p` has
  **exactly `p²` points**.  The proof fibres the cone over the linear functional
  `w ↦ w 2 − w 0` (the "light-cone coordinate" `c − a`) and shows that *every* fibre —
  including the degenerate one over `0` — has exactly `p` points.  This is the counting
  incarnation of the fact that `q` is a nondegenerate isotropic ternary form.
* `PadicBerggren.card_nullCone_nonzero` : `p² − 1` nonzero null vectors, i.e. `p + 1`
  projective null points each carrying `p − 1` nonzero vectors.
* `PadicBerggren.tree_collision_nullCone` : since the whole depth-`d` tree lands inside the
  null cone, two distinct words already collide mod `p` as soon as `3^d > p²`.  This is a
  quadratic (in `p`) obstruction, far stronger than the naive cubic bound
  `tree_collision_mod`, and it says that the reduction of the boundary of the tree has
  "box dimension at most 2": the tree cannot inject into any single finite level.
-/

namespace PadicBerggren

open Matrix Finset

variable (p : ℕ) [Fact p.Prime]

/-- The null cone mod `p`, as a finset (the phase space of the reduced Berggren dynamics). -/
def nullConeFinset : Finset (Fin 3 → ZMod p) :=
  univ.filter (fun w => lorentz (ZMod p) w = 0)

theorem mem_nullConeFinset (w : Fin 3 → ZMod p) :
    w ∈ nullConeFinset p ↔ w ∈ nullCone (ZMod p) := by
  simp [nullConeFinset, nullCone, Set.mem_setOf_eq]

/-- `2` is invertible mod an odd prime. -/
theorem two_ne_zero_zmod (hp : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  intro h
  have h' : ((2 : ℕ) : ZMod p) = 0 := by push_cast; exact h
  rw [ZMod.natCast_eq_zero_iff] at h'
  exact hp ((Nat.prime_dvd_prime_iff_eq (Fact.out : p.Prime) Nat.prime_two).mp h')

omit [Fact p.Prime] in
/-- Eta-expansion of a vector of length three. -/
theorem eta3 (w : Fin 3 → ZMod p) : w = ![w 0, w 1, w 2] := by
  funext i; fin_cases i <;> rfl

/-- **Every light-cone fibre has exactly `p` points.**  Fibring the null cone over the
linear functional `w ↦ w 2 − w 0`, the fibre over a unit `u` is the graph
`b ↦ ((b²/u − u)/2, b, (b²/u + u)/2)` and the fibre over `0` is the isotropic line
`s ↦ (s, 0, s)`; both are parametrised bijectively by `ZMod p`. -/
theorem card_nullCone_fiber (hp : p ≠ 2) (u : ZMod p) :
    ((nullConeFinset p).filter (fun w => w 2 - w 0 = u)).card = p := by
  have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_zmod p hp
  rcases eq_or_ne u 0 with rfl | hu
  · have hinj : Function.Injective (fun s : ZMod p => (![s, 0, s] : Fin 3 → ZMod p)) := by
      intro a b hab
      have := congrFun hab 0
      simpa using this
    have himg : ((nullConeFinset p).filter (fun w => w 2 - w 0 = 0))
        = image (fun s : ZMod p => (![s, 0, s] : Fin 3 → ZMod p)) univ := by
      ext w
      simp only [mem_filter, mem_image, mem_univ, true_and, nullConeFinset, lorentz]
      constructor
      · rintro ⟨hq, hd⟩
        have hw2 : w 2 = w 0 := by linear_combination hd
        have hw1 : w 1 = 0 := by
          have hsq : (w 1) ^ 2 = 0 := by rw [hw2] at hq; linear_combination hq
          exact sq_eq_zero_iff.mp hsq
        refine ⟨w 0, ?_⟩
        funext i
        fin_cases i <;> simp [hw1, hw2]
      · rintro ⟨s, rfl⟩
        refine ⟨?_, ?_⟩ <;> simp
    rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, ZMod.card]
  · have hui : u * u⁻¹ = 1 := mul_inv_cancel₀ hu
    have hc : (2 : ZMod p) * (2 : ZMod p)⁻¹ = 1 := mul_inv_cancel₀ h2
    have hinj : Function.Injective (fun b : ZMod p =>
        (![(b ^ 2 * u⁻¹ - u) * (2 : ZMod p)⁻¹, b, (b ^ 2 * u⁻¹ + u) * (2 : ZMod p)⁻¹] :
          Fin 3 → ZMod p)) := by
      intro a b hab
      have := congrFun hab 1
      simpa using this
    have himg : ((nullConeFinset p).filter (fun w => w 2 - w 0 = u))
        = image (fun b : ZMod p =>
            (![(b ^ 2 * u⁻¹ - u) * (2 : ZMod p)⁻¹, b, (b ^ 2 * u⁻¹ + u) * (2 : ZMod p)⁻¹] :
              Fin 3 → ZMod p)) univ := by
      ext w
      simp only [mem_filter, mem_image, mem_univ, true_and, nullConeFinset, lorentz]
      constructor
      · rintro ⟨hq, hd⟩
        refine ⟨w 1, ?_⟩
        have hsum : u * (w 2 + w 0) = (w 1) ^ 2 := by
          have hw2 : w 2 = u + w 0 := by linear_combination hd
          rw [hw2] at hq ⊢
          linear_combination -hq
        have hs : w 2 + w 0 = (w 1) ^ 2 * u⁻¹ := by
          field_simp
          linear_combination hsum
        have hA : ((w 1) ^ 2 * u⁻¹ - u) * (2 : ZMod p)⁻¹ = w 0 := by
          linear_combination (-(2 : ZMod p)⁻¹) * hs + (2 : ZMod p)⁻¹ * hd + w 0 * hc
        have hC : ((w 1) ^ 2 * u⁻¹ + u) * (2 : ZMod p)⁻¹ = w 2 := by
          linear_combination (-(2 : ZMod p)⁻¹) * hs + (-(2 : ZMod p)⁻¹) * hd + w 2 * hc
        rw [hA, hC, ← eta3 p w]
      · rintro ⟨b, rfl⟩
        refine ⟨?_, ?_⟩
        · simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
            Matrix.cons_val_two, Matrix.tail_cons]
          linear_combination (-4 * ((2 : ZMod p)⁻¹) ^ 2 * b ^ 2) * hui +
            (-(b ^ 2 * (2 * (2 : ZMod p)⁻¹ + 1))) * hc
        · simp only [Matrix.cons_val_zero, Matrix.head_cons,
            Matrix.cons_val_two, Matrix.tail_cons]
          linear_combination u * hc
    rw [himg, Finset.card_image_of_injective _ hinj, Finset.card_univ, ZMod.card]

/-- **The null cone mod an odd prime has exactly `p²` points.**  This is the exact size of the
phase space of the reduced Berggren dynamical system. -/
theorem card_nullCone (hp : p ≠ 2) : (nullConeFinset p).card = p ^ 2 := by
  have hfib := Finset.card_eq_sum_card_fiberwise
    (f := fun w : Fin 3 → ZMod p => w 2 - w 0) (s := nullConeFinset p)
    (t := (univ : Finset (ZMod p))) (fun x _ => mem_univ _)
  rw [hfib, Finset.sum_congr rfl (fun u _ => card_nullCone_fiber p hp u),
    Finset.sum_const, Finset.card_univ, ZMod.card, smul_eq_mul, sq]

/-- The origin is a null vector (the fixed point of the whole dynamics). -/
theorem zero_mem_nullConeFinset : (0 : Fin 3 → ZMod p) ∈ nullConeFinset p := by
  simp [nullConeFinset, lorentz]

/-- **`p² − 1` nonzero null vectors.**  Since every Berggren move is linear and fixes `0`,
the interesting part of the phase space has exactly `p² − 1` points; as the moves commute with
scaling this is `p + 1` projective null points, each with `p − 1` representatives. -/
theorem card_nullCone_nonzero (hp : p ≠ 2) :
    ((nullConeFinset p).erase 0).card = p ^ 2 - 1 := by
  rw [Finset.card_erase_of_mem (zero_mem_nullConeFinset p), card_nullCone p hp]

/-- **A quadratic collapse bound for the boundary of the tree.**  Every vertex of the Berggren
tree lies on the null cone, which has only `p²` points mod `p`; hence as soon as `3^d > p²`
two distinct words of length `d` have the same reduction.  In particular no fixed finite level
`ZMod p` can carry the boundary of the ternary tree. -/
theorem tree_collision_nullCone (d : ℕ) (hp : p ≠ 2) (h : p ^ 2 < 3 ^ d) :
    ∃ w₁ w₂ : Fin d → Fin 3, w₁ ≠ w₂ ∧
      wordMat (ZMod p) (List.ofFn w₁) *ᵥ root (ZMod p)
        = wordMat (ZMod p) (List.ofFn w₂) *ᵥ root (ZMod p) := by
  have hcard : (nullConeFinset p).card < (univ : Finset (Fin d → Fin 3)).card := by
    rw [card_nullCone p hp, Finset.card_univ, Fintype.card_fun, Fintype.card_fin,
      Fintype.card_fin]
    exact h
  have hmaps : ∀ w : Fin d → Fin 3, w ∈ (univ : Finset (Fin d → Fin 3)) →
      wordMat (ZMod p) (List.ofFn w) *ᵥ root (ZMod p) ∈ nullConeFinset p := by
    intro w _
    simp only [nullConeFinset, Finset.mem_filter, Finset.mem_univ, true_and]
    exact lorentz_wordMat (R := ZMod p) (List.ofFn w)
  obtain ⟨w₁, -, w₂, -, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  exact ⟨w₁, w₂, hne, heq⟩

end PadicBerggren