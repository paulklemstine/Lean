import Algebra.DepthLSawtoothCollapse

/-!
# One ReLU layer realises an entire sawtooth tower

`Algebra.DepthLSawtoothCollapse` showed that `tri ∘ tri` is a single ReLU layer
of width `5`.  This file proves the general statement and draws the consequences
for the depth/width trade-off.

## Main results

* `tri_iterate_affine` — on the dyadic interval `[m/2^c, (m+1)/2^c]` the tower
  `tri^[c]` is the affine zig-zag with slope `±2^c`.
* `tri_iterate_one_layer` — for `c ≥ 1`,
  `tri^[c] y = ∑_{i=0}^{2^c} a_i · relu (y - i/2^c)` with the explicit
  coefficients `a_0 = a_{2^c} = 2^c` and `a_i = (-1)^i 2^{c+1}` otherwise
  (`dyadCoef`).  A *single* hidden layer of width `2^c+1` computes the whole
  height-`c` tower.
* `dyad_tower_isNet` — stacking such layers: a ReLU network of depth `L` and
  width `2^c+1` computes `tri^[cL]` exactly.
* `sawtooth_collapse_general` — hence every witness `tri^[L+c-1]` collapses to
  depth `L` at width `2^c+1`; with `c = ⌊log₂ L⌋` the width is at most `L+1`,
  so *polynomially sized* depth-`L` networks capture towers of height
  `L + log₂ L − 1`.
* `tower_height_bracket` — combining with `relu_oscillation_bound`, the maximal
  tower height computable at depth `L` and width `2^c+1` is between `cL` and
  `(c+3)L+2`: it is `Θ(L · log w)`, linear in the depth and logarithmic in the
  width.

Together with `relu_depth_separation` (height `L^2+4` needs exponential width)
this locates the collapse/separation threshold: the tower height must grow
*superlinearly* in `L` for any exponential lower bound to be possible.
-/

noncomputable section

namespace ReluDepth

open Finset

/-! ## The affine pieces of a sawtooth tower -/

lemma tri_iterate_zero_pt (n : ℕ) : tri^[n] 0 = 0 := by
  induction n with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply, tri_of_nonpos (le_refl 0), ih]

lemma tri_iterate_of_nonpos {c : ℕ} (hc : 1 ≤ c) {y : ℝ} (h : y ≤ 0) : tri^[c] y = 0 := by
  obtain ⟨n, rfl⟩ : ∃ n, c = n + 1 := ⟨c - 1, by omega⟩
  rw [Function.iterate_succ_apply, tri_of_nonpos h, tri_iterate_zero_pt]

lemma tri_iterate_of_one_le {c : ℕ} (hc : 1 ≤ c) {y : ℝ} (h : 1 ≤ y) : tri^[c] y = 0 := by
  obtain ⟨n, rfl⟩ : ∃ n, c = n + 1 := ⟨c - 1, by omega⟩
  rw [Function.iterate_succ_apply, tri_of_one_le h, tri_iterate_zero_pt]

/-- On the dyadic interval `[m/2^c, (m+1)/2^c]` the tower `tri^[c]` is the affine
zig-zag with slope `±2^c`. -/
theorem tri_iterate_affine (c : ℕ) : ∀ (m : ℕ), m < 2^c → ∀ y : ℝ,
    (m : ℝ)/2^c ≤ y → y ≤ ((m:ℝ)+1)/2^c →
    tri^[c] y = if Even m then 2^c * y - m else ((m:ℝ)+1) - 2^c * y := by
  induction c with
  | zero =>
      intro m hm y hy1 hy2
      interval_cases m
      simp at hy1 hy2 ⊢
  | succ c ih =>
      intro m hm y hy1 hy2
      rw [Function.iterate_succ_apply]
      have hpow : (0:ℝ) < 2^c := by positivity
      have hpow1 : (0:ℝ) < 2^(c+1) := by positivity
      rcases lt_or_ge m (2^c) with hcase | hcase
      · have hy0 : 0 ≤ y := le_trans (by positivity) hy1
        have hyhalf : y ≤ 1/2 := by
          have hb : ((m:ℝ)+1)/2^(c+1) ≤ 1/2 := by
            rw [div_le_div_iff₀ hpow1 (by norm_num)]
            have hmn : (m:ℝ) + 1 ≤ 2^c := by
              have h2 : (m+1 : ℕ) ≤ 2^c := hcase
              exact_mod_cast h2
            rw [pow_succ]; linarith
          linarith
        rw [tri_left hy0 hyhalf]
        have h1 : (m:ℝ)/2^c ≤ 2*y := by
          rw [div_le_iff₀ hpow]
          rw [div_le_iff₀ hpow1, pow_succ] at hy1
          linarith
        have h2 : 2*y ≤ ((m:ℝ)+1)/2^c := by
          rw [le_div_iff₀ hpow]
          rw [le_div_iff₀ hpow1, pow_succ] at hy2
          linarith
        rw [ih m hcase (2*y) h1 h2]
        by_cases hE : Even m
        · rw [if_pos hE, if_pos hE, pow_succ]; ring
        · rw [if_neg hE, if_neg hE, pow_succ]; ring
      · have hyhalf : 1/2 ≤ y := by
          have hle : (1:ℝ)/2 ≤ (m:ℝ)/2^(c+1) := by
            rw [div_le_div_iff₀ (by norm_num) hpow1]
            have : (2:ℝ)^c ≤ m := by exact_mod_cast hcase
            rw [pow_succ]; linarith
          linarith
        have hy1' : y ≤ 1 := by
          have hb : ((m:ℝ)+1)/2^(c+1) ≤ 1 := by
            rw [div_le_one hpow1]
            have h2 : (m+1 : ℕ) ≤ 2^(c+1) := hm
            exact_mod_cast h2
          linarith
        rw [tri_right hyhalf hy1']
        set m' : ℕ := 2^(c+1) - m - 1 with hm'
        have hm'lt : m' < 2^c := by
          have h2 : 2^(c+1) = 2^c + 2^c := by ring
          omega
        have hm'cast : (m' : ℝ) = 2^(c+1) - m - 1 := by
          rw [hm']
          have h1 : (1:ℕ) ≤ 2^(c+1) - m := by omega
          push_cast [Nat.cast_sub (by omega : m ≤ 2^(c+1)), Nat.cast_sub h1]
          ring
        have h1 : (m':ℝ)/2^c ≤ 2 - 2*y := by
          rw [div_le_iff₀ hpow, hm'cast, pow_succ]
          rw [le_div_iff₀ hpow1, pow_succ] at hy2
          linarith
        have h2 : 2 - 2*y ≤ ((m':ℝ)+1)/2^c := by
          rw [le_div_iff₀ hpow, hm'cast, pow_succ]
          rw [div_le_iff₀ hpow1, pow_succ] at hy1
          linarith
        rw [ih m' hm'lt (2 - 2*y) h1 h2]
        have hpar : Even m' ↔ ¬ Even m := by
          rw [hm']
          have h2c : Even (2^(c+1)) := ⟨2^c, by ring⟩
          constructor
          · intro he hem
            obtain ⟨a, ha⟩ := he
            obtain ⟨b, hb⟩ := hem
            obtain ⟨d, hd⟩ := h2c
            omega
          · intro hno
            rcases Nat.even_or_odd (2^(c+1) - m - 1) with h | h
            · exact h
            · exfalso
              obtain ⟨a, ha⟩ := h
              obtain ⟨d, hd⟩ := h2c
              exact hno ⟨(d - a - 1), by omega⟩
        by_cases hE : Even m
        · rw [if_neg (fun hcon => (hpar.mp hcon) hE), if_pos hE, hm'cast, pow_succ]; ring
        · rw [if_pos (hpar.mpr hE), if_neg hE, hm'cast, pow_succ]; ring

/-! ## The one-layer coefficients -/

/-- Coefficients of the one-layer realisation of `tri^[c]`: the second differences of
its values on the dyadic grid. -/
def dyadCoef (c i : ℕ) : ℝ := if i = 0 ∨ i = 2^c then (2:ℝ)^c else (-1)^i * 2^(c+1)

lemma dyadCoef_zero (c : ℕ) : dyadCoef c 0 = 2^c := by simp [dyadCoef]

lemma dyadCoef_top (c : ℕ) : dyadCoef c (2^c) = 2^c := by simp [dyadCoef]

lemma dyadCoef_mid {c i : ℕ} (h0 : i ≠ 0) (hN : i ≠ 2^c) :
    dyadCoef c i = (-1)^i * 2^(c+1) := by simp [dyadCoef, h0, hN]

lemma dyadCoef_partial_sum (c : ℕ) : ∀ m : ℕ, m < 2^c →
    ∑ i ∈ Finset.range (m+1), dyadCoef c i = (-1)^m * 2^c := by
  intro m
  induction m with
  | zero => intro _; simp [dyadCoef_zero]
  | succ m ih =>
      intro hm
      rw [Finset.sum_range_succ, ih (by omega), dyadCoef_mid (by omega) (by omega),
        pow_succ (2:ℝ) c, pow_succ ((-1):ℝ) m]
      ring

lemma dyadCoef_partial_moment (c : ℕ) : ∀ m : ℕ, m < 2^c →
    ∑ i ∈ Finset.range (m+1), (i:ℝ) * dyadCoef c i
      = 2^c * (if Even m then (m:ℝ) else -((m:ℝ)+1)) := by
  intro m
  induction m with
  | zero => intro _; simp
  | succ m ih =>
      intro hm
      rw [Finset.sum_range_succ, ih (by omega), dyadCoef_mid (by omega) (by omega)]
      by_cases hE : Even m
      · rw [if_pos hE, if_neg (by simp [Nat.even_add_one, hE])]
        rw [Odd.neg_one_pow (Even.add_one hE), pow_succ (2:ℝ) c]
        push_cast
        ring
      · rw [if_neg hE, if_pos (by simpa [Nat.even_add_one] using hE)]
        rw [Even.neg_one_pow (Odd.add_one (Nat.not_even_iff_odd.mp hE)), pow_succ (2:ℝ) c]
        push_cast
        ring

lemma dyadCoef_total_sum {c : ℕ} (hc : 1 ≤ c) :
    ∑ i ∈ Finset.range (2^c+1), dyadCoef c i = 0 := by
  have h2 : 1 ≤ 2^c := Nat.one_le_two_pow
  have hsplit : 2^c + 1 = (2^c - 1) + 1 + 1 := by omega
  rw [hsplit, Finset.sum_range_succ]
  have he : 2^c - 1 + 1 = 2^c := by omega
  rw [dyadCoef_partial_sum c (2^c - 1) (by omega), he, dyadCoef_top]
  have hodd : Odd (2^c - 1) := by
    obtain ⟨k, hk⟩ : 2 ∣ 2^c := dvd_pow_self 2 (by omega)
    exact ⟨k - 1, by omega⟩
  rw [Odd.neg_one_pow hodd]
  ring

lemma dyadCoef_total_moment {c : ℕ} (hc : 1 ≤ c) :
    ∑ i ∈ Finset.range (2^c+1), (i:ℝ) * dyadCoef c i = 0 := by
  have h2 : 1 ≤ 2^c := Nat.one_le_two_pow
  have hsplit : 2^c + 1 = (2^c - 1) + 1 + 1 := by omega
  rw [hsplit, Finset.sum_range_succ]
  have he : 2^c - 1 + 1 = 2^c := by omega
  rw [dyadCoef_partial_moment c (2^c - 1) (by omega), he, dyadCoef_top]
  have hodd : Odd (2^c - 1) := by
    obtain ⟨k, hk⟩ : 2 ∣ 2^c := dvd_pow_self 2 (by omega)
    exact ⟨k - 1, by omega⟩
  rw [if_neg (Nat.not_even_iff_odd.mpr hodd)]
  have hcast : ((2^c - 1 : ℕ) : ℝ) = 2^c - 1 := by
    push_cast [Nat.cast_sub h2]; ring
  rw [hcast]
  push_cast
  ring

/-! ## One layer realises the tower -/

/-- **Dyadic one-layer realisation.**  For `c ≥ 1` the height-`c` sawtooth tower is a
single ReLU layer of width `2^c+1`. -/
theorem tri_iterate_one_layer {c : ℕ} (hc : 1 ≤ c) (y : ℝ) :
    tri^[c] y = ∑ i ∈ Finset.range (2^c+1), dyadCoef c i * relu (y - (i:ℝ)/2^c) := by
  have hpow : (0:ℝ) < 2^c := by positivity
  rcases le_or_gt y 0 with hy | hy
  · rw [tri_iterate_of_nonpos hc hy]
    refine (Finset.sum_eq_zero ?_).symm
    intro i _
    have hle : y - (i:ℝ)/2^c ≤ 0 := by
      have : (0:ℝ) ≤ (i:ℝ)/2^c := by positivity
      linarith
    simp [relu, max_eq_right hle]
  rcases le_or_gt 1 y with hy1 | hy1
  · rw [tri_iterate_of_one_le hc hy1]
    have hterm : ∀ i ∈ Finset.range (2^c+1),
        dyadCoef c i * relu (y - (i:ℝ)/2^c) = dyadCoef c i * y - (i:ℝ) * dyadCoef c i / 2^c := by
      intro i hi
      simp only [Finset.mem_range] at hi
      have hle : (i:ℝ)/2^c ≤ 1 := by
        rw [div_le_one hpow]
        have : (i:ℕ) ≤ 2^c := by omega
        exact_mod_cast this
      have hnn : 0 ≤ y - (i:ℝ)/2^c := by linarith
      rw [relu, max_eq_left hnn]
      field_simp
    rw [Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, ← Finset.sum_mul,
      ← Finset.sum_div, dyadCoef_total_sum hc, dyadCoef_total_moment hc]
    simp
  set m : ℕ := ⌊(2:ℝ)^c * y⌋₊ with hm
  have hmy : (m:ℝ) ≤ 2^c * y := Nat.floor_le (by positivity)
  have hym : (2:ℝ)^c * y < m + 1 := Nat.lt_floor_add_one _
  have hmlt : m < 2^c := by
    have : (m:ℝ) < 2^c := by nlinarith
    exact_mod_cast this
  have hy1' : (m:ℝ)/2^c ≤ y := by rw [div_le_iff₀ hpow]; linarith
  have hy2' : y ≤ ((m:ℝ)+1)/2^c := by rw [le_div_iff₀ hpow]; linarith
  rw [tri_iterate_affine c m hmlt y hy1' hy2']
  have hsub : Finset.range (m+1) ⊆ Finset.range (2^c+1) := by
    intro i hi
    simp only [Finset.mem_range] at hi ⊢
    omega
  have hzero : ∀ i ∈ Finset.range (2^c+1), i ∉ Finset.range (m+1) →
      dyadCoef c i * relu (y - (i:ℝ)/2^c) = 0 := by
    intro i _ hi
    simp only [Finset.mem_range, not_lt] at hi
    have hle : y - (i:ℝ)/2^c ≤ 0 := by
      have h1 : ((m:ℝ)+1) ≤ (i:ℝ) := by exact_mod_cast hi
      have h2 : ((m:ℝ)+1)/2^c ≤ (i:ℝ)/2^c := by gcongr
      linarith
    simp [relu, max_eq_right hle]
  rw [← Finset.sum_subset hsub hzero]
  have hterm : ∀ i ∈ Finset.range (m+1),
      dyadCoef c i * relu (y - (i:ℝ)/2^c) = dyadCoef c i * y - (i:ℝ) * dyadCoef c i / 2^c := by
    intro i hi
    simp only [Finset.mem_range] at hi
    have hle : (i:ℝ)/2^c ≤ y := by
      have h1 : (i:ℝ) ≤ m := by exact_mod_cast (by omega : i ≤ m)
      have h2 : (i:ℝ)/2^c ≤ (m:ℝ)/2^c := by gcongr
      linarith
    have hnn : 0 ≤ y - (i:ℝ)/2^c := by linarith
    rw [relu, max_eq_left hnn]
    field_simp
  rw [Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_div,
    dyadCoef_partial_sum c m hmlt, dyadCoef_partial_moment c m hmlt]
  by_cases hE : Even m
  · rw [if_pos hE, if_pos hE, Even.neg_one_pow hE]
    field_simp
  · rw [if_neg hE, if_neg hE, Odd.neg_one_pow (Nat.not_even_iff_odd.mp hE)]
    field_simp
    ring

/-! ## Networks built from fat layers -/

lemma LayerUnits.width_mono {w w' L n : ℕ} {us : Fin n → ℝ → ℝ} (h : LayerUnits w L us)
    (hw : w ≤ w') : LayerUnits w' L us := by
  induction h with
  | input => exact LayerUnits.input
  | step _ hm W b ih => exact ih.step (le_trans hm hw) W b

lemma IsNet.width_mono {w w' L : ℕ} {f : ℝ → ℝ} (h : IsNet w L f) (hw : w ≤ w') :
    IsNet w' L f := by
  obtain ⟨n, us, hus, c, d, hf⟩ := h
  exact ⟨n, us, hus.width_mono hw, c, d, hf⟩

/-- The `2^c+1` units of the fat first layer. -/
theorem dyadLayerUnits (c : ℕ) :
    LayerUnits (2^c+1) 1 (fun (j : Fin (2^c+1)) (x : ℝ) => relu (x - (j:ℕ)/2^c)) := by
  have h := (LayerUnits.input (w := 2^c+1)).step (le_refl _)
    (fun (_ : Fin (2^c+1)) (_ : Fin 1) => (1:ℝ)) (fun j => -((j:ℕ)/2^c : ℝ))
  have e : (fun (j : Fin (2^c+1)) (x : ℝ) => relu (x - (j:ℕ)/2^c))
      = fun (j : Fin (2^c+1)) (x : ℝ) =>
        relu ((∑ _i : Fin 1, (1:ℝ) * x) + (-((j:ℕ)/2^c : ℝ))) := by
    funext j x
    simp [sub_eq_add_neg]
  rw [e]; exact h

lemma dyad_as_comb {c : ℕ} (hc : 1 ≤ c) (y : ℝ) :
    (∑ j : Fin (2^c+1), dyadCoef c (j:ℕ) * relu (y - (j:ℕ)/2^c)) = tri^[c] y := by
  rw [Fin.sum_univ_eq_sum_range (fun i => dyadCoef c i * relu (y - (i:ℝ)/2^c)) (2^c+1)]
  exact (tri_iterate_one_layer hc y).symm

/-- **Fat towers.**  Stacking `l+1` layers of width `2^c+1`, each realising a whole
height-`c` tower, computes `tri^[c*l]` at the units of the last layer. -/
theorem dyad_tower_layerUnits {c : ℕ} (hc : 1 ≤ c) (l : ℕ) :
    LayerUnits (2^c+1) (l+1)
      (fun (j : Fin (2^c+1)) (x : ℝ) => relu (tri^[c*l] x - (j:ℕ)/2^c)) := by
  induction l with
  | zero => simpa using dyadLayerUnits c
  | succ l ih =>
      have h := ih.step (le_refl _) (fun (_ : Fin (2^c+1)) (i : Fin (2^c+1)) => dyadCoef c (i:ℕ))
        (fun j => -((j:ℕ)/2^c : ℝ))
      have e : (fun (j : Fin (2^c+1)) (x : ℝ) => relu (tri^[c*(l+1)] x - (j:ℕ)/2^c))
          = fun (j : Fin (2^c+1)) (x : ℝ) => relu ((∑ i : Fin (2^c+1), dyadCoef c (i:ℕ) *
              relu (tri^[c*l] x - (i:ℕ)/2^c)) + (-((j:ℕ)/2^c : ℝ))) := by
        funext j x
        rw [dyad_as_comb hc, sub_eq_add_neg]
        have hcl : c*(l+1) = c + c*l := by ring
        rw [hcl, Function.iterate_add_apply tri c (c*l) x]
      rw [e]; exact h

/-- A ReLU network of depth `l+1` and width `2^c+1` computes `tri^[c(l+1)]` exactly:
each layer multiplies the number of teeth by `2^c`. -/
theorem dyad_tower_isNet {c : ℕ} (hc : 1 ≤ c) (l : ℕ) :
    IsNet (2^c+1) (l+1) (tri^[c*(l+1)]) := by
  refine ⟨2^c+1, _, dyad_tower_layerUnits hc l, fun j => dyadCoef c (j:ℕ), 0, ?_⟩
  funext x
  rw [add_zero, dyad_as_comb hc]
  have hcl : c*(l+1) = c + c*l := by ring
  rw [hcl, Function.iterate_add_apply tri c (c*l) x]

/-- **General collapse.**  For `c ≥ 1` and `L ≥ 2` the witness `tri^[L+c-1]` — a
function of depth `L+c-1` in the width-`3` sawtooth architecture — is computed
exactly by a network of depth `L` and width `2^c+1`. -/
theorem sawtooth_collapse_general {c : ℕ} (hc : 1 ≤ c) (L : ℕ) (hL : 2 ≤ L) :
    IsNet (2^c+1) L (tri^[L+c-1]) := by
  obtain ⟨l, rfl⟩ : ∃ l, L = l + 2 := ⟨L - 2, by omega⟩
  have h3 : 3 ≤ 2^c + 1 := by
    have : 2 ≤ 2^c := by
      calc (2:ℕ) = 2^1 := by norm_num
        _ ≤ 2^c := Nat.pow_le_pow_right (by norm_num) hc
    omega
  have h := tri_tower_isNet h3 (dyadLayerUnits c) (fun j => dyadCoef c (j:ℕ)) 0 l
  have e : (fun x : ℝ => tri^[l+1] ((∑ j : Fin (2^c+1),
      dyadCoef c (j:ℕ) * relu (x - (j:ℕ)/2^c)) + 0)) = tri^[l+2+c-1] := by
    funext x
    rw [add_zero, dyad_as_comb hc]
    have he : l + 2 + c - 1 = (l+1) + c := by omega
    rw [he, Function.iterate_add_apply tri (l+1) c x]
  rw [e] at h
  have e2 : 1 + 1 + l = l + 2 := by omega
  rwa [e2] at h

/-- **Logarithmic depth gaps are free.**  If `2^c ≤ L` then the depth-`(L+c-1)`
sawtooth witness is computed exactly by a depth-`L` network of width at most `L+1`,
i.e. by a network of size `O(L^2)` — polynomial. -/
theorem log_gap_collapse {c L : ℕ} (hc : 1 ≤ c) (hL : 2 ≤ L) (hcL : 2^c ≤ L) :
    IsNet (L+1) L (tri^[L+c-1]) :=
  (sawtooth_collapse_general hc L hL).width_mono (by omega)

/-- **The tower-height trade-off.**  At depth `L` and width `2^c+1` the exactly
computable sawtooth tower height `k` satisfies `cL ≤ k` (achieved) and
`k ≤ (c+3)L+2` (forced).  So the achievable height is linear in the depth and
proportional to `log₂` of the width. -/
theorem tower_height_bracket {c : ℕ} (hc : 1 ≤ c) (L : ℕ) (hL : 1 ≤ L) :
    IsNet (2^c+1) L (tri^[c*L]) ∧
      ∀ k : ℕ, IsNet (2^c+1) L (tri^[k]) → k ≤ (c+3)*L + 2 := by
  obtain ⟨l, rfl⟩ : ∃ l, L = l + 1 := ⟨L - 1, by omega⟩
  refine ⟨dyad_tower_isNet hc l, fun k hk => ?_⟩
  have h1 : 2 ^ k ≤ 4 * (2 * (2^c+1) + 2) ^ (l+1) :=
    relu_oscillation_bound (l+1) (2^c+1) k _ hk (by intro x _; simp)
  have hbase : 2 * (2^c+1) + 2 ≤ 2 ^ (c+3) := by
    have h2 : (2:ℕ)^(c+3) = 8 * 2^c := by rw [pow_add]; ring
    have h3 : 1 ≤ 2^c := Nat.one_le_two_pow
    omega
  have h2 : (2 * (2^c+1) + 2) ^ (l+1) ≤ (2 ^ (c+3)) ^ (l+1) := Nat.pow_le_pow_left hbase _
  have h3 : ((2:ℕ) ^ (c+3)) ^ (l+1) = 2 ^ ((c+3)*(l+1)) := by rw [← pow_mul]
  have h4 : (2:ℕ) ^ k ≤ 2 ^ ((c+3)*(l+1) + 2) := by
    calc (2:ℕ) ^ k ≤ 4 * (2 * (2^c+1) + 2) ^ (l+1) := h1
      _ ≤ 4 * 2 ^ ((c+3)*(l+1)) := by rw [← h3]; exact Nat.mul_le_mul_left 4 h2
      _ = 2 ^ ((c+3)*(l+1) + 2) := by rw [pow_add]; ring
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp h4

end ReluDepth

end