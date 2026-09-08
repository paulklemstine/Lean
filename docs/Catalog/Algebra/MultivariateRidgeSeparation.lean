import Algebra.DyadicBadPointDensity

/-!
# Dimension-free depth separation for ridge witnesses

All the previous files concern ReLU networks with a single real input.  This
file shows that the whole theory transfers to `ℝ^D` *without any loss*, by the
restriction principle: a multivariate ReLU network restricted to an affine line
is a univariate ReLU network of the same depth and width.

## Main results

* `MLayerUnits`, `MIsNet` — networks with input `Fin D → ℝ`.
* `mlayer_restrict`, `MIsNet.restrict` — restriction along `t ↦ a + t·v` turns a
  depth-`L`, width-`w` multivariate network into a depth-`L`, width-`w`
  univariate one.
* `ridge_isNet` — the ridge witness `x ↦ tri^[l+1] (x i₀)` is computed exactly by
  a multivariate network of depth `l+1` and width `3`.
* `relu_depth_separation_ridge` — for `L ≥ 1`, any depth-`L`, width-`w`
  multivariate network within `1/4` of `x ↦ tri^[L^2+4] (x i₀)` on the unit cube
  satisfies `2^L ≤ 2w+2`.  The width penalty is `w`, not `w^D`: extra input
  dimensions do not help a shallow network approximate a ridge function.
-/

noncomputable section

namespace ReluDepth

open Finset

/-! ## Multivariate networks -/

/-- Unit functions of layer `L` of a ReLU network with input `Fin D → ℝ` and hidden
layers of width at most `w`. -/
inductive MLayerUnits (D w : ℕ) : ℕ → ∀ {n : ℕ}, (Fin n → (Fin D → ℝ) → ℝ) → Prop
  | input : MLayerUnits D w 0 (fun (i : Fin D) (x : Fin D → ℝ) => x i)
  | step {L n m : ℕ} {us : Fin n → (Fin D → ℝ) → ℝ} (h : MLayerUnits D w L us) (hm : m ≤ w)
      (W : Fin m → Fin n → ℝ) (b : Fin m → ℝ) :
      MLayerUnits D w (L+1) (fun (j : Fin m) (x : Fin D → ℝ) => relu ((∑ i, W j i * us i x) + b j))

/-- `MIsNet D w L F` : `F : (Fin D → ℝ) → ℝ` is computed exactly by a ReLU network with
`L` hidden layers of width at most `w`. -/
def MIsNet (D w L : ℕ) (F : (Fin D → ℝ) → ℝ) : Prop :=
  ∃ (n : ℕ) (us : Fin n → (Fin D → ℝ) → ℝ), MLayerUnits D w L us ∧
    ∃ (c : Fin n → ℝ) (d : ℝ), F = fun x => (∑ i, c i * us i x) + d

/-! ## The restriction principle -/

/-- Restricting the units of a multivariate network to the line `t ↦ a + t·v` gives the
units of a univariate network of the same depth and width (for `L = 0` the restricted
units are simply affine). -/
theorem mlayer_restrict {D w L n : ℕ} {us : Fin n → (Fin D → ℝ) → ℝ}
    (h : MLayerUnits D w L us) (a v : Fin D → ℝ) :
    ((∀ i, ∃ α β : ℝ, ∀ t : ℝ, us i (fun j => a j + t * v j) = α * t + β) ∧ L = 0)
      ∨ LayerUnits w L (fun i t => us i (fun j => a j + t * v j)) := by
  induction h with
  | input =>
      left
      exact ⟨fun i => ⟨v i, a i, fun t => by ring⟩, rfl⟩
  | @step L n m us _ hm W b ih =>
      right
      rcases ih with ⟨haff, rfl⟩ | hL
      · choose A Bc hAB using haff
        have hbase := (LayerUnits.input (w := w)).step hm
          (fun (j : Fin m) (_ : Fin 1) => ∑ i, W j i * A i)
          (fun j => (∑ i, W j i * Bc i) + b j)
        have e : (fun (j : Fin m) (t : ℝ) =>
              relu ((∑ i, W j i * us i (fun j => a j + t * v j)) + b j))
            = fun (j : Fin m) (t : ℝ) => relu ((∑ _i : Fin 1, (∑ i, W j i * A i) * t)
                + ((∑ i, W j i * Bc i) + b j)) := by
          funext j t
          congr 1
          simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, one_nsmul]
          rw [Finset.sum_mul]
          have hterm : ∀ i, W j i * us i (fun j => a j + t * v j)
              = W j i * A i * t + W j i * Bc i := by
            intro i; rw [hAB i t]; ring
          simp only [hterm]
          rw [Finset.sum_add_distrib]
          ring
        rw [e]; exact hbase
      · exact hL.step hm W b

/-- **Restriction principle.**  A depth-`L`, width-`w` multivariate ReLU network
restricted to an affine line is a depth-`L`, width-`w` univariate ReLU network. -/
theorem MIsNet.restrict {D w L : ℕ} {F : (Fin D → ℝ) → ℝ} (h : MIsNet D w L F)
    (a v : Fin D → ℝ) : IsNet w L (fun t => F (fun j => a j + t * v j)) := by
  obtain ⟨n, us, hus, c, d, rfl⟩ := h
  rcases mlayer_restrict hus a v with ⟨haff, rfl⟩ | hL
  · choose A Bc hAB using haff
    refine ⟨1, (fun (_ : Fin 1) (x : ℝ) => x), LayerUnits.input,
      (fun _ => ∑ i, c i * A i), (∑ i, c i * Bc i) + d, ?_⟩
    funext t
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, one_nsmul]
    have hterm : ∀ i, c i * us i (fun j => a j + t * v j) = c i * A i * t + c i * Bc i := by
      intro i; rw [hAB i t]; ring
    simp only [hterm]
    rw [Finset.sum_add_distrib, Finset.sum_mul]
    ring
  · exact ⟨n, _, hL, c, d, rfl⟩

/-! ## The multivariate sawtooth tower -/

/-- Sawtooth layers stacked on a multivariate sub-network. -/
theorem mtri_tower_layerUnits {D w L n : ℕ} (h3 : 3 ≤ w) {us : Fin n → (Fin D → ℝ) → ℝ}
    (hus : MLayerUnits D w L us) (c : Fin n → ℝ) (d : ℝ) (l : ℕ) :
    MLayerUnits D w (L + 1 + l)
      (fun (j : Fin 3) (x : Fin D → ℝ) =>
        relu (tri^[l] ((∑ i, c i * us i x) + d) - triShift j)) := by
  induction l with
  | zero =>
      have h := hus.step h3 (fun (_ : Fin 3) (i : Fin n) => c i) (fun j => d - triShift j)
      have e : (fun (j : Fin 3) (x : Fin D → ℝ) =>
            relu (tri^[0] ((∑ i, c i * us i x) + d) - triShift j))
          = fun (j : Fin 3) (x : Fin D → ℝ) =>
            relu ((∑ i, c i * us i x) + (d - triShift j)) := by
        funext j x; simp [Function.iterate_zero_apply]; ring_nf
      rw [e]; exact h
  | succ l ih =>
      have h := ih.step h3 (fun (_ : Fin 3) (i : Fin 3) => triCoef i) (fun j => -triShift j)
      have e : (fun (j : Fin 3) (x : Fin D → ℝ) =>
            relu (tri^[l+1] ((∑ i, c i * us i x) + d) - triShift j))
          = fun (j : Fin 3) (x : Fin D → ℝ) => relu ((∑ i : Fin 3, triCoef i *
              relu (tri^[l] ((∑ i, c i * us i x) + d) - triShift i)) + (-triShift j)) := by
        funext j x
        rw [tri_as_comb, ← Function.iterate_succ_apply' tri l, sub_eq_add_neg]
      rw [e]; exact h

/-- **The ridge witness.**  `x ↦ tri^[l+1] (x i₀)` is computed exactly by a multivariate
ReLU network of depth `l+1` and width `3`, for any coordinate `i₀`. -/
theorem ridge_isNet {D : ℕ} (i₀ : Fin D) (l : ℕ) :
    MIsNet D 3 (l+1) (fun x => tri^[l+1] (x i₀)) := by
  classical
  have h := mtri_tower_layerUnits (D := D) (w := 3) (le_refl 3) MLayerUnits.input
    (fun i => if i = i₀ then (1:ℝ) else 0) 0 l
  have e2 : 0 + 1 + l = l + 1 := by omega
  rw [e2] at h
  refine ⟨3, _, h, triCoef, 0, ?_⟩
  funext x
  have hsum : (∑ i, (if i = i₀ then (1:ℝ) else 0) * x i) + 0 = x i₀ := by simp
  rw [hsum, add_zero, tri_as_comb, ← Function.iterate_succ_apply' tri l]

/-! ## The dimension-free separation -/

/-- **Multivariate depth separation.**  For `L ≥ 1`, every ReLU network on `ℝ^D` of
depth `L` and width `w` that approximates the ridge function
`x ↦ tri^[L^2+4] (x i₀)` within `1/4` on the unit cube satisfies `2^L ≤ 2w+2`.
The bound does not depend on the dimension `D`. -/
theorem relu_depth_separation_ridge {D : ℕ} (i₀ : Fin D) (L w : ℕ) (hL : 1 ≤ L)
    (F : (Fin D → ℝ) → ℝ) (hnet : MIsNet D w L F)
    (happrox : ∀ x : Fin D → ℝ, (∀ j, x j ∈ Set.Icc (0:ℝ) 1) →
      |F x - tri^[L^2+4] (x i₀)| ≤ 1/4) :
    2 ^ L ≤ 2 * w + 2 := by
  classical
  set v : Fin D → ℝ := fun j => if j = i₀ then 1 else 0 with hv
  set a : Fin D → ℝ := fun _ => 0 with ha
  have hline : ∀ t : ℝ, (fun j => a j + t * v j) i₀ = t := by
    intro t; simp [ha, hv]
  have hcube : ∀ t : ℝ, t ∈ Set.Icc (0:ℝ) 1 → ∀ j, (a j + t * v j) ∈ Set.Icc (0:ℝ) 1 := by
    intro t ht j
    by_cases hj : j = i₀
    · simp [ha, hv, hj, ht]
    · simp [ha, hv, hj]
  refine relu_depth_separation L w hL (fun t => F (fun j => a j + t * v j))
    (hnet.restrict a v) ?_
  intro t ht
  have h := happrox (fun j => a j + t * v j) (hcube t ht)
  rwa [hline t] at h

end ReluDepth

end