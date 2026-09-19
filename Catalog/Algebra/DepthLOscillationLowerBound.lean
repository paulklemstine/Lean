import Mathlib

/-!
# ReLU networks, sawtooth towers and piecewise-affine knot sets

This module holds the base objects of the ReLU depth thread: the rectifier, the
tent map `tri`, the inductive description of the hidden-layer units of a ReLU
network (`LayerUnits`), exact computability by such a network (`IsNet`), the
piecewise-affine predicate (`PWA`) in which all knot-counting statements of the
thread are phrased, and the sawtooth-tower constructions
(`tri_tower_layerUnits`, `tri_tower_isNet`, `sawtooth_isNet`).

The file was missing from the repository while five modules of the thread
(`Algebra.DepthLSawtoothCollapse`, `Algebra.DyadicOneLayer`,
`Algebra.DyadicBadPointDensity`, `Algebra.SawtoothL1Separation`,
`Algebra.MultivariateRidgeSeparation`) import it, so none of them could be
elaborated.  It is reconstructed here, including the oscillation lower bound
itself: the knot budget of a layer (`layerUnits_pwa`), the exponential knot
requirement of the sawtooth tower (`tri_iterate_knots`) and the resulting
counting bound `relu_oscillation_bound`.  Every statement below is proved; no
axiom or unproved placeholder is introduced.

## Main definitions

* `ReluDepth.relu`, `ReluDepth.tri` — the rectifier `max x 0` and the tent map,
  the latter written as the width-`3` ReLU layer
  `2·relu y − 4·relu (y − 1/2) + 2·relu (y − 1)`.
* `ReluDepth.LayerUnits w L us` — `us` are the units of layer `L` of a ReLU
  network of width at most `w`.
* `ReluDepth.IsNet w L f` — `f` is computed *exactly* by such a network.
* `ReluDepth.AffineOn`, `ReluDepth.PWA` — affinity on an interval, and piecewise
  affinity with a finite knot set inside `[0,1]`.

## Main results

* `ReluDepth.tri_as_comb` — one hidden layer of width `3` realises `tri`.
* `ReluDepth.tri_tower_layerUnits`, `ReluDepth.tri_tower_isNet` — stacking `l+1`
  tent layers on top of any network computes `tri^[l+1]` of its output.
* `ReluDepth.sawtooth_isNet` — `tri^[L+1]` is computed exactly in depth `L+1`
  and width `3`.
* `ReluDepth.pwa_relu` — rectifying a piecewise affine function adds at most one
  knot per piece; `ReluDepth.PWA.linear_comb` — affine combinations keep the knot
  set.
* `ReluDepth.layerUnits_pwa`, `ReluDepth.IsNet.pwa` — the units of layer `L` of a
  width-`w` network share a knot set of size at most `knotBound w L`, and so does
  the function the network computes.
* `ReluDepth.tri_iterate_dyadic` — `tri^[k]` alternates between `0` and `1` at the
  points `j/2^k`; `ReluDepth.tri_iterate_knots` — hence any piecewise affine
  representation of `tri^[k]` needs `2^k ≤ 2|S| + 1`.
* `ReluDepth.relu_oscillation_bound` — **the oscillation lower bound**: a
  depth-`L`, width-`w` network computing `tri^[k]` on `[0,1]` forces
  `2^k ≤ 4 (2w+2)^L`.
-/

noncomputable section

namespace ReluDepth

open Finset

/-! ## The rectifier and the tent map -/

/-- The rectified linear unit. -/
def relu (x : ℝ) : ℝ := max x 0

theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_right _ _

/-- The tent map, written as a single ReLU layer of width `3`. -/
def tri (y : ℝ) : ℝ := 2 * relu y - 4 * relu (y - 1/2) + 2 * relu (y - 1)

theorem tri_left {y : ℝ} (h0 : 0 ≤ y) (h : y ≤ 1/2) : tri y = 2 * y := by
  unfold tri relu
  rw [max_eq_left h0, max_eq_right (by linarith), max_eq_right (by linarith)]
  ring

theorem tri_right {y : ℝ} (h : 1/2 ≤ y) (h1 : y ≤ 1) : tri y = 2 - 2 * y := by
  unfold tri relu
  rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_right (by linarith)]
  ring

/-- The three biases of the tent layer. -/
def triShift : Fin 3 → ℝ := ![0, 1/2, 1]

/-- The three read-out weights of the tent layer. -/
def triCoef : Fin 3 → ℝ := ![2, -4, 2]

theorem tri_as_comb (y : ℝ) : (∑ i : Fin 3, triCoef i * relu (y - triShift i)) = tri y := by
  simp [Fin.sum_univ_three, triCoef, triShift, tri]
  ring

/-! ## Piecewise affine functions -/

/-- `f` agrees with an affine function on `[a, b]`. -/
def AffineOn (f : ℝ → ℝ) (a b : ℝ) : Prop :=
  ∃ α β : ℝ, ∀ x ∈ Set.Icc a b, f x = α * x + β

/-- `f` is piecewise affine on `[0,1]` with knots inside the finite set `S`: on every
subinterval of `[0,1]` that meets no knot in its interior, `f` is affine. -/
def PWA (S : Finset ℝ) (f : ℝ → ℝ) : Prop :=
  ∀ a b : ℝ, 0 ≤ a → a ≤ b → b ≤ 1 → (∀ z ∈ S, z ≤ a ∨ b ≤ z) → AffineOn f a b

/-! ## ReLU networks -/

/-- Unit functions of layer `L` of a ReLU network with one real input and hidden layers
of width at most `w`. -/
inductive LayerUnits (w : ℕ) : ℕ → ∀ {n : ℕ}, (Fin n → ℝ → ℝ) → Prop
  | input : LayerUnits w 0 (fun (_ : Fin 1) (x : ℝ) => x)
  | step {L n m : ℕ} {us : Fin n → ℝ → ℝ} (h : LayerUnits w L us) (hm : m ≤ w)
      (W : Fin m → Fin n → ℝ) (b : Fin m → ℝ) :
      LayerUnits w (L+1) (fun (j : Fin m) (x : ℝ) => relu ((∑ i, W j i * us i x) + b j))

/-- `IsNet w L f` : `f` is computed exactly by a ReLU network with `L` hidden layers of
width at most `w`. -/
def IsNet (w L : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ (n : ℕ) (us : Fin n → ℝ → ℝ), LayerUnits w L us ∧
    ∃ (c : Fin n → ℝ) (d : ℝ), f = fun x => (∑ i, c i * us i x) + d

/-! ## Sawtooth towers -/

/-- Stacking `l+1` tent layers on top of a network whose last layer computes the units
`us` produces the units of `tri^[l]` of the read-out. -/
theorem tri_tower_layerUnits {w n L : ℕ} (hw : 3 ≤ w) {us : Fin n → ℝ → ℝ}
    (hus : LayerUnits w L us) (c : Fin n → ℝ) (d : ℝ) (l : ℕ) :
    LayerUnits w (L + 1 + l)
      (fun (j : Fin 3) (x : ℝ) => relu (tri^[l] ((∑ i, c i * us i x) + d) - triShift j)) := by
  induction l with
  | zero =>
      have h := hus.step hw (fun (_ : Fin 3) (i : Fin n) => c i) (fun j => d - triShift j)
      have e : (fun (j : Fin 3) (x : ℝ) =>
            relu (tri^[0] ((∑ i, c i * us i x) + d) - triShift j))
          = fun (j : Fin 3) (x : ℝ) => relu ((∑ i, c i * us i x) + (d - triShift j)) := by
        funext j x
        simp only [Function.iterate_zero, id_eq]
        ring_nf
      rw [e]
      simpa using h
  | succ l ih =>
      have h := ih.step hw (fun (_ : Fin 3) (i : Fin 3) => triCoef i) (fun j => -triShift j)
      have e : (fun (j : Fin 3) (x : ℝ) =>
            relu (tri^[l+1] ((∑ i, c i * us i x) + d) - triShift j))
          = fun (j : Fin 3) (x : ℝ) => relu ((∑ i : Fin 3, triCoef i *
              relu (tri^[l] ((∑ i, c i * us i x) + d) - triShift i)) + (-triShift j)) := by
        funext j x
        rw [tri_as_comb, ← Function.iterate_succ_apply' tri l, sub_eq_add_neg]
      rw [e]
      have e2 : L + 1 + (l + 1) = L + 1 + l + 1 := by omega
      rw [e2]
      exact h

/-- **Tent towers on top of an arbitrary network.**  If the units `us` of layer `L`
read out to `g x = (∑ i, c i · us i x) + d`, then `tri^[l+1] ∘ g` is computed exactly in
depth `L + 1 + l` and width `w ≥ 3`. -/
theorem tri_tower_isNet {w n L : ℕ} (hw : 3 ≤ w) {us : Fin n → ℝ → ℝ}
    (hus : LayerUnits w L us) (c : Fin n → ℝ) (d : ℝ) (l : ℕ) :
    IsNet w (L + 1 + l) (fun x => tri^[l+1] ((∑ i, c i * us i x) + d)) := by
  refine ⟨3, _, tri_tower_layerUnits hw hus c d l, triCoef, 0, ?_⟩
  funext x
  rw [add_zero, tri_as_comb, ← Function.iterate_succ_apply' tri l]

/-- **The sawtooth witness.**  `tri^[L+1]` is computed exactly by a ReLU network of
depth `L+1` and width `3`. -/
theorem sawtooth_isNet (L : ℕ) : IsNet 3 (L+1) (tri^[L+1]) := by
  have h := tri_tower_isNet (w := 3) (le_refl 3) (LayerUnits.input (w := 3))
    (fun _ : Fin 1 => (1:ℝ)) 0 L
  have e : (fun x : ℝ => tri^[L+1] ((∑ _i : Fin 1, (1:ℝ) * x) + 0)) = tri^[L+1] := by
    funext x
    simp
  rw [e] at h
  have e2 : 0 + 1 + L = L + 1 := by omega
  rw [e2] at h
  exact h

/-! ## Monotonicity and stability of `PWA` -/

theorem AffineOn.mono {f : ℝ → ℝ} {a b a' b' : ℝ} (h : AffineOn f a b)
    (h1 : a ≤ a') (h2 : b' ≤ b) : AffineOn f a' b' := by
  obtain ⟨α, β, hab⟩ := h
  exact ⟨α, β, fun x hx => hab x ⟨le_trans h1 hx.1, le_trans hx.2 h2⟩⟩

theorem PWA.mono {S T : Finset ℝ} {f : ℝ → ℝ} (h : PWA S f) (hST : S ⊆ T) : PWA T f := by
  intro a b ha hab hb hknot
  exact h a b ha hab hb (fun z hz => hknot z (hST hz))

/-- An affine combination of functions that are piecewise affine with the same knot set is
piecewise affine with that knot set. -/
theorem PWA.linear_comb {S : Finset ℝ} {n : ℕ} {us : Fin n → ℝ → ℝ}
    (h : ∀ i, PWA S (us i)) (c : Fin n → ℝ) (d : ℝ) :
    PWA S (fun x => (∑ i, c i * us i x) + d) := by
  intro a b ha hab hb hknot
  choose A B hAB using fun i => h i a b ha hab hb hknot
  refine ⟨∑ i, c i * A i, (∑ i, c i * B i) + d, ?_⟩
  intro x hx
  show (∑ i, c i * us i x) + d = (∑ i, c i * A i) * x + ((∑ i, c i * B i) + d)
  have hterm : ∀ i, c i * us i x = c i * A i * x + c i * B i := by
    intro i
    rw [hAB i x hx]; ring
  rw [Finset.sum_congr rfl (fun i _ => hterm i), Finset.sum_add_distrib, ← Finset.sum_mul]
  ring

/-- Two affine representations of the same function on a nondegenerate interval agree. -/
theorem affine_coeff_unique {f : ℝ → ℝ} {c d α₀ β₀ α₁ β₁ : ℝ} (hcd : c < d)
    (h0 : ∀ x ∈ Set.Icc c d, f x = α₀ * x + β₀)
    (h1 : ∀ x ∈ Set.Icc c d, f x = α₁ * x + β₁) : α₀ = α₁ ∧ β₀ = β₁ := by
  have e1 : α₀ * c + β₀ = α₁ * c + β₁ := by
    rw [← h0 c ⟨le_rfl, hcd.le⟩, ← h1 c ⟨le_rfl, hcd.le⟩]
  have e2 : α₀ * d + β₀ = α₁ * d + β₁ := by
    rw [← h0 d ⟨hcd.le, le_rfl⟩, ← h1 d ⟨hcd.le, le_rfl⟩]
  have hα : α₀ = α₁ := by
    have h : (α₀ - α₁) * (d - c) = 0 := by linarith
    rcases mul_eq_zero.1 h with h | h
    · linarith
    · linarith
  exact ⟨hα, by rw [hα] at e1; linarith⟩

/-- **Rectifying a piecewise affine function adds at most one knot per piece.** -/
theorem pwa_relu {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) :
    ∃ Z : Finset ℝ, Z.card ≤ S.card + 1 ∧ PWA (S ∪ Z) (fun x => relu (f x)) := by
  classical
  -- the next knot to the right of `a`, capped at `1`
  set nxt : ℝ → ℝ := fun a => (insert (1:ℝ) (S.filter (fun z => a < z))).min'
    (Finset.insert_nonempty _ _) with hnxt
  set cross : ℝ → ℝ := fun a =>
    if f (nxt a) = f a then a else a + (nxt a - a) * (- f a) / (f (nxt a) - f a) with hcross
  refine ⟨(insert (0:ℝ) S).image cross, ?_, ?_⟩
  · calc ((insert (0:ℝ) S).image cross).card ≤ (insert (0:ℝ) S).card :=
        Finset.card_image_le
      _ ≤ S.card + 1 := Finset.card_insert_le _ _
  intro c d hc hcd hd hknot
  -- `f` is affine on `[c,d]`
  obtain ⟨α₀, β₀, h0⟩ : AffineOn f c d :=
    hf c d hc hcd hd (fun z hz => hknot z (Finset.mem_union_left _ hz))
  by_cases hpos : ∀ x ∈ Set.Icc c d, 0 ≤ f x
  · refine ⟨α₀, β₀, fun x hx => ?_⟩
    show relu (f x) = α₀ * x + β₀
    unfold relu
    rw [max_eq_left (hpos x hx)]
    exact h0 x hx
  by_cases hneg : ∀ x ∈ Set.Icc c d, f x ≤ 0
  · refine ⟨0, 0, fun x hx => ?_⟩
    show relu (f x) = 0 * x + 0
    unfold relu
    rw [max_eq_right (hneg x hx)]
    ring
  exfalso
  push_neg at hpos hneg
  obtain ⟨x₁, hx₁, hx₁neg⟩ := hpos
  obtain ⟨x₂, hx₂, hx₂pos⟩ := hneg
  have hcltd : c < d := by
    rcases lt_or_eq_of_le hcd with h | h
    · exact h
    · exfalso
      have e1 : x₁ = c := le_antisymm (by rw [h]; exact hx₁.2) hx₁.1
      have e2 : x₂ = c := le_antisymm (by rw [h]; exact hx₂.2) hx₂.1
      rw [e1] at hx₁neg; rw [e2] at hx₂pos
      linarith
  -- the slope cannot vanish
  have hα₀ : α₀ ≠ 0 := by
    intro h
    have e1 : f x₁ = β₀ := by rw [h0 x₁ hx₁, h]; ring
    have e2 : f x₂ = β₀ := by rw [h0 x₂ hx₂, h]; ring
    rw [e1] at hx₁neg
    rw [e2] at hx₂pos
    linarith
  obtain ⟨xstar, hxdef⟩ : ∃ x : ℝ, x = -β₀ / α₀ := ⟨_, rfl⟩
  have hfstar : α₀ * xstar + β₀ = 0 := by
    rw [hxdef]; field_simp; ring
  -- `xstar` lies strictly inside `(c, d)`
  have hx1lt : α₀ * x₁ + β₀ < 0 := by rw [← h0 x₁ hx₁]; exact hx₁neg
  have hx2gt : 0 < α₀ * x₂ + β₀ := by rw [← h0 x₂ hx₂]; exact hx₂pos
  have hstar_between : (min x₁ x₂ < xstar ∧ xstar < max x₁ x₂) := by
    rcases lt_or_gt_of_ne hα₀ with hneg' | hpos'
    · -- decreasing line: x₂ < xstar < x₁
      have h21 : x₂ < x₁ := by nlinarith
      constructor
      · rw [min_eq_right h21.le]
        nlinarith [hfstar]
      · rw [max_eq_left h21.le]
        nlinarith [hfstar]
    · have h12 : x₁ < x₂ := by nlinarith
      constructor
      · rw [min_eq_left h12.le]
        nlinarith [hfstar]
      · rw [max_eq_right h12.le]
        nlinarith [hfstar]
  have hcstar : c < xstar := lt_of_le_of_lt (le_min hx₁.1 hx₂.1) hstar_between.1
  have hstard : xstar < d := lt_of_lt_of_le hstar_between.2 (max_le hx₁.2 hx₂.2)
  -- the left neighbour of `c` among the knots
  have hne : ((insert (0:ℝ) S).filter (fun z => z ≤ c)).Nonempty :=
    ⟨0, Finset.mem_filter.2 ⟨Finset.mem_insert_self _ _, hc⟩⟩
  set a : ℝ := ((insert (0:ℝ) S).filter (fun z => z ≤ c)).max' hne with ha_def
  have hamem : a ∈ (insert (0:ℝ) S).filter (fun z => z ≤ c) := Finset.max'_mem _ hne
  have hac : a ≤ c := (Finset.mem_filter.1 hamem).2
  have ha0 : 0 ≤ a := Finset.le_max' _ 0 (Finset.mem_filter.2 ⟨Finset.mem_insert_self _ _, hc⟩)
  have hains : a ∈ insert (0:ℝ) S := (Finset.mem_filter.1 hamem).1
  -- every knot to the right of `a` is at least `d`
  have hfar : ∀ z ∈ S, a < z → d ≤ z := by
    intro z hz haz
    rcases hknot z (Finset.mem_union_left _ hz) with h | h
    · exact absurd (Finset.le_max' _ z (Finset.mem_filter.2 ⟨Finset.mem_insert_of_mem hz, h⟩))
        (not_le.2 haz)
    · exact h
  have hnxt_le_one : nxt a ≤ 1 :=
    Finset.min'_le _ 1 (Finset.mem_insert_self _ _)
  have hnxt_ge : d ≤ nxt a := by
    apply Finset.le_min'
    intro z hz
    rcases Finset.mem_insert.1 hz with rfl | hz'
    · exact hd
    · obtain ⟨hzS, hlt⟩ := Finset.mem_filter.1 hz'
      exact hfar z hzS hlt
  have hanxt : a ≤ nxt a := le_trans hac (le_trans hcd hnxt_ge)
  have hknot_a : ∀ z ∈ S, z ≤ a ∨ nxt a ≤ z := by
    intro z hz
    by_cases h : a < z
    · right
      exact Finset.min'_le _ z (Finset.mem_insert_of_mem (Finset.mem_filter.2 ⟨hz, h⟩))
    · left; exact not_lt.1 h
  obtain ⟨α₁, β₁, h1⟩ : AffineOn f a (nxt a) := hf a (nxt a) ha0 hanxt hnxt_le_one hknot_a
  have hsub : ∀ x ∈ Set.Icc c d, x ∈ Set.Icc a (nxt a) :=
    fun x hx => ⟨le_trans hac hx.1, le_trans hx.2 hnxt_ge⟩
  obtain ⟨hαeq, hβeq⟩ : α₀ = α₁ ∧ β₀ = β₁ :=
    affine_coeff_unique hcltd h0 (fun x hx => h1 x (hsub x hx))
  have hanxt_lt : a < nxt a := lt_of_le_of_lt hac (lt_of_lt_of_le hcltd hnxt_ge)
  have hfa : f a = α₁ * a + β₁ := h1 a ⟨le_rfl, hanxt⟩
  have hfnxt : f (nxt a) = α₁ * (nxt a) + β₁ := h1 (nxt a) ⟨hanxt, le_rfl⟩
  have hdiff : f (nxt a) - f a = α₁ * (nxt a - a) := by rw [hfa, hfnxt]; ring
  have hα₁ : α₁ ≠ 0 := by rw [← hαeq]; exact hα₀
  have hne' : f (nxt a) ≠ f a := by
    intro h
    have : α₁ * (nxt a - a) = 0 := by rw [← hdiff, h]; ring
    rcases mul_eq_zero.1 this with h' | h'
    · exact hα₁ h'
    · linarith
  have hsub0 : nxt a - a ≠ 0 := sub_ne_zero.2 (ne_of_gt hanxt_lt)
  have hcrossa : cross a = xstar := by
    have hval : cross a = a + (nxt a - a) * (- f a) / (f (nxt a) - f a) := by
      rw [hcross]; simp only [if_neg hne']
    rw [hval, hdiff, hfa, hxdef, hαeq, hβeq]
    field_simp
    ring
  have hmemZ : xstar ∈ (insert (0:ℝ) S).image cross := by
    rw [← hcrossa]
    exact Finset.mem_image_of_mem _ hains
  rcases hknot xstar (Finset.mem_union_right _ hmemZ) with h | h
  · linarith
  · linarith

/-! ## The knot budget of a depth-`L`, width-`w` network -/

/-- The number of knots a depth-`L` network of width `w` can create: each of the at most
`w` units of a layer inherits the knots of the previous layer and adds at most one new
knot per piece. -/
def knotBound : ℕ → ℕ → ℕ
  | _, 0 => 0
  | w, (L+1) => (w+1) * knotBound w L + w

@[simp] theorem knotBound_zero (w : ℕ) : knotBound w 0 = 0 := rfl

theorem knotBound_succ (w L : ℕ) : knotBound w (L+1) = (w+1) * knotBound w L + w := rfl

/-- The knot budget is at most `2 (2w+2)^L`, with room to spare. -/
theorem two_knotBound_succ_le (w L : ℕ) : 2 * knotBound w L + 1 ≤ 4 * (2*w+2)^L := by
  induction L with
  | zero => simp
  | succ L ih =>
      have hP : 1 ≤ (2*w+2)^L := Nat.one_le_pow _ _ (by omega)
      have hpow : (2*w+2)^(L+1) = (2*w+2) * (2*w+2)^L := by rw [pow_succ]; ring
      rw [knotBound_succ, hpow]
      have h1 : 2 * ((w+1) * knotBound w L + w) + 1
          = (w+1) * (2 * knotBound w L + 1) + w := by ring
      rw [h1]
      have h2 : (w+1) * (2 * knotBound w L + 1) ≤ (w+1) * (4 * (2*w+2)^L) :=
        Nat.mul_le_mul_left _ ih
      have h3 : w ≤ 4 * (w+1) * (2*w+2)^L := by
        calc w ≤ 4 * (w+1) * 1 := by omega
          _ ≤ 4 * (w+1) * (2*w+2)^L := Nat.mul_le_mul_left _ hP
      have h4 : 4 * ((2*w+2) * (2*w+2)^L) = (w+1) * (4 * (2*w+2)^L) + 4 * (w+1) * (2*w+2)^L := by
        ring
      omega

theorem knotBound_le (w L : ℕ) : knotBound w L ≤ 2 * (2*w+2)^L := by
  have h := two_knotBound_succ_le w L
  omega

/-- **The knot budget of a ReLU layer.**  All the units of layer `L` of a width-`w`
network are piecewise affine with a common knot set of size at most `knotBound w L`. -/
theorem layerUnits_pwa {w L n : ℕ} {us : Fin n → ℝ → ℝ} (h : LayerUnits w L us) :
    ∃ S : Finset ℝ, S.card ≤ knotBound w L ∧ ∀ i, PWA S (us i) := by
  classical
  induction h with
  | input =>
      refine ⟨∅, by simp, ?_⟩
      intro i a b _ _ _ _
      exact ⟨1, 0, fun x _ => by ring⟩
  | @step L n m us hus hm W b ih =>
      obtain ⟨S, hcard, hS⟩ := ih
      choose Z hZcard hZpwa using fun j : Fin m =>
        pwa_relu (PWA.linear_comb hS (W j) (b j))
      refine ⟨S ∪ Finset.univ.biUnion Z, ?_, ?_⟩
      · have h1 : (S ∪ Finset.univ.biUnion Z).card ≤ S.card + (Finset.univ.biUnion Z).card :=
          Finset.card_union_le _ _
        have h2 : (Finset.univ.biUnion Z).card ≤ ∑ j : Fin m, (Z j).card :=
          Finset.card_biUnion_le
        have h3 : ∑ j : Fin m, (Z j).card ≤ ∑ _j : Fin m, (S.card + 1) :=
          Finset.sum_le_sum (fun j _ => hZcard j)
        have h4 : ∑ _j : Fin m, (S.card + 1) = m * (S.card + 1) := by
          simp [Finset.sum_const]
        have h5 : m * (S.card + 1) ≤ w * (knotBound w L + 1) :=
          Nat.mul_le_mul hm (by omega)
        have h6 : (w+1) * knotBound w L + w = knotBound w L + w * (knotBound w L + 1) := by
          ring
        rw [knotBound_succ]
        omega
      · intro j
        exact (hZpwa j).mono (Finset.union_subset_union_right
          (Finset.subset_biUnion_of_mem Z (Finset.mem_univ j)))

/-- **The knot budget of a network.**  A function computed exactly by a depth-`L`,
width-`w` ReLU network is piecewise affine with at most `knotBound w L` knots. -/
theorem IsNet.pwa {w L : ℕ} {f : ℝ → ℝ} (h : IsNet w L f) :
    ∃ S : Finset ℝ, S.card ≤ knotBound w L ∧ PWA S f := by
  obtain ⟨n, us, hus, c, d, rfl⟩ := h
  obtain ⟨S, hcard, hS⟩ := layerUnits_pwa hus
  exact ⟨S, hcard, PWA.linear_comb hS c d⟩

/-! ## The tower `tri^[k]` oscillates at the dyadic grid -/

/-- The value of the sawtooth tower at the dyadic points of its own grid: `tri^[k]`
alternates between `0` and `1` at the points `j / 2^k`. -/
theorem tri_iterate_dyadic (k : ℕ) : ∀ j : ℕ, j ≤ 2^k →
    tri^[k] ((j : ℝ)/2^k) = if Even j then 0 else 1 := by
  induction k with
  | zero =>
      intro j hj
      interval_cases j <;> norm_num
  | succ k ih =>
      intro j hj
      have hpow : (0:ℝ) < 2^k := by positivity
      have hpow1 : (0:ℝ) < 2^(k+1) := by positivity
      have hx0 : 0 ≤ (j : ℝ)/2^(k+1) := by positivity
      rw [Function.iterate_succ_apply]
      rcases Nat.le_total j (2^k) with hcase | hcase
      · have hle : (j : ℝ)/2^(k+1) ≤ 1/2 := by
          rw [div_le_iff₀ hpow1]
          have : (j : ℝ) ≤ 2^k := by exact_mod_cast hcase
          have he : (2:ℝ)^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
          rw [he]; linarith
        have htri : tri ((j : ℝ)/2^(k+1)) = (j : ℝ)/2^k := by
          rw [tri_left hx0 hle]
          have he : (2:ℝ)^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
          rw [he]
          field_simp
        rw [htri]
        exact ih j hcase
      · have hge : 1/2 ≤ (j : ℝ)/2^(k+1) := by
          rw [le_div_iff₀ hpow1]
          have : (2:ℝ)^k ≤ (j : ℝ) := by exact_mod_cast hcase
          have he : (2:ℝ)^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
          rw [he]; linarith
        have hle1 : (j : ℝ)/2^(k+1) ≤ 1 := by
          rw [div_le_one hpow1]
          exact_mod_cast hj
        set j' : ℕ := 2^(k+1) - j with hj'
        have hjle : j' ≤ 2^k := by
          have h2 : 2^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
          omega
        have hcast : ((j' : ℕ) : ℝ) = (2:ℝ)^(k+1) - (j : ℝ) := by
          rw [hj', Nat.cast_sub hj]
          norm_num
        have htri : tri ((j : ℝ)/2^(k+1)) = ((j' : ℕ) : ℝ)/2^k := by
          rw [tri_right hge hle1, hcast]
          have he : (2:ℝ)^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
          rw [he]
          field_simp
        rw [htri, ih j' hjle]
        have hparity : Even j' ↔ Even j := by
          have h2 : 2^(k+1) = 2 * 2^k := by rw [pow_succ]; ring
          simp only [Nat.even_iff]
          omega
        by_cases hE : Even j
        · rw [if_pos (hparity.2 hE), if_pos hE]
        · rw [if_neg (fun hc => hE (hparity.1 hc)), if_neg hE]

/-- **The tower needs exponentially many knots.**  If `tri^[k]` is piecewise affine with
knot set `S`, then `2^k ≤ 2 |S| + 1`. -/
theorem tri_iterate_knots (k : ℕ) {S : Finset ℝ} (hS : PWA S (tri^[k])) :
    2^k ≤ 2 * S.card + 1 := by
  classical
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · simp
  obtain ⟨k', rfl⟩ : ∃ k', k = k' + 1 := ⟨k - 1, by omega⟩
  set K : ℕ := k' + 1 with hK
  set p : ℕ → ℝ := fun i => (i : ℝ)/2^K with hp
  have hpowK : (0:ℝ) < 2^K := by positivity
  have hpmono : ∀ i i' : ℕ, i ≤ i' → p i ≤ p i' := by
    intro i i' h
    have : (i : ℝ) ≤ (i' : ℝ) := by exact_mod_cast h
    simp only [hp]
    gcongr
  have hval : ∀ i : ℕ, i ≤ 2^K → tri^[K] (p i) = if Even i then 0 else 1 := by
    intro i hi
    simpa [hp] using tri_iterate_dyadic K i hi
  have hbound : ∀ t : ℕ, t < 2^k' → 2*t + 2 ≤ 2^K := by
    intro t ht
    have h2 : 2^K = 2 * 2^k' := by rw [hK, pow_succ]; ring
    omega
  have key : ∀ t : ℕ, t < 2^k' → ∃ z ∈ S, p (2*t) < z ∧ z < p (2*t+2) := by
    intro t ht
    by_contra hcon
    push_neg at hcon
    have hknot : ∀ z ∈ S, z ≤ p (2*t) ∨ p (2*t+2) ≤ z := by
      intro z hz
      by_cases h1 : z ≤ p (2*t)
      · exact Or.inl h1
      · exact Or.inr (hcon z hz (not_le.1 h1))
    have hb := hbound t ht
    have h0 : 0 ≤ p (2*t) := by simp only [hp]; positivity
    have hle : p (2*t) ≤ p (2*t+2) := hpmono _ _ (by omega)
    have h1 : p (2*t+2) ≤ 1 := by
      simp only [hp]
      rw [div_le_one hpowK]
      exact_mod_cast hb
    obtain ⟨α, β, haff⟩ := hS (p (2*t)) (p (2*t+2)) h0 hle h1 hknot
    have hmid : p (2*t+1) = (p (2*t) + p (2*t+2))/2 := by
      simp only [hp]
      push_cast
      ring
    have e0 : tri^[K] (p (2*t)) = 0 := by
      rw [hval _ (by omega), if_pos ⟨t, by ring⟩]
    have e2 : tri^[K] (p (2*t+2)) = 0 := by
      rw [hval _ (by omega), if_pos ⟨t+1, by ring⟩]
    have e1 : tri^[K] (p (2*t+1)) = 1 := by
      rw [hval _ (by omega), if_neg (by simp [parity_simps])]
    have a0 : α * p (2*t) + β = 0 := by rw [← haff _ ⟨le_rfl, hle⟩]; exact e0
    have a2 : α * p (2*t+2) + β = 0 := by rw [← haff _ ⟨hle, le_rfl⟩]; exact e2
    have a1 : α * p (2*t+1) + β = 1 := by
      rw [← haff _ ⟨hpmono _ _ (by omega), hpmono _ _ (by omega)⟩]
      exact e1
    rw [hmid] at a1
    nlinarith [a0, a1, a2]
  choose! z hzS hz1 hz2 using key
  have hinj : Set.InjOn z (Finset.range (2^k')) := by
    intro t ht t' ht' heq
    simp only [Finset.coe_range, Set.mem_Iio] at ht ht'
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · have h1 : z t < p (2*t+2) := hz2 t ht
      have h2 : p (2*t') < z t' := hz1 t' ht'
      have h3 : p (2*t+2) ≤ p (2*t') := hpmono _ _ (by omega)
      rw [heq] at h1
      linarith
    · have h1 : z t' < p (2*t'+2) := hz2 t' ht'
      have h2 : p (2*t) < z t := hz1 t ht
      have h3 : p (2*t'+2) ≤ p (2*t) := hpmono _ _ (by omega)
      rw [heq] at h2
      linarith
  have hcard : (Finset.range (2^k')).card ≤ S.card :=
    Finset.card_le_card_of_injOn z (fun t ht => hzS t (Finset.mem_range.1 ht)) hinj
  rw [Finset.card_range] at hcard
  have h2 : 2^K = 2 * 2^k' := by rw [hK, pow_succ]; ring
  omega

/-- **The oscillation bound.**  A depth-`L`, width-`w` ReLU network that agrees with the
sawtooth tower `tri^[k]` on `[0,1]` forces `2^k ≤ 4 (2w+2)^L`. -/
theorem relu_oscillation_bound (L w k : ℕ) (f : ℝ → ℝ) (hnet : IsNet w L f)
    (hf : ∀ x ∈ Set.Icc (0:ℝ) 1, f x = tri^[k] x) : 2^k ≤ 4 * (2*w+2)^L := by
  obtain ⟨S, hScard, hS⟩ := hnet.pwa
  have hS' : PWA S (tri^[k]) := by
    intro a b ha hab hb hknot
    obtain ⟨α, β, haff⟩ := hS a b ha hab hb hknot
    refine ⟨α, β, fun x hx => ?_⟩
    rw [← hf x ⟨le_trans ha hx.1, le_trans hx.2 hb⟩]
    exact haff x hx
  have h1 := tri_iterate_knots k hS'
  have h2 := two_knotBound_succ_le w L
  omega

/-- **An affine function cannot go low–high–low.**  This is the local obstruction behind
every knot-counting bound: on a knot-free interval a network cannot follow one tooth of
the sawtooth. -/
theorem no_affine_oscillation {f : ℝ → ℝ} {x1 x2 x3 : ℝ} (h12 : x1 < x2) (h23 : x2 < x3)
    (haff : AffineOn f x1 x3) (hl1 : f x1 ≤ 1/4) (hh : 3/4 ≤ f x2) (hl3 : f x3 ≤ 1/4) :
    False := by
  obtain ⟨a, b, hab⟩ := haff
  have e1 : f x1 = a * x1 + b := hab x1 ⟨le_refl _, le_of_lt (lt_trans h12 h23)⟩
  have e2 : f x2 = a * x2 + b := hab x2 ⟨le_of_lt h12, le_of_lt h23⟩
  have e3 : f x3 = a * x3 + b := hab x3 ⟨le_of_lt (lt_trans h12 h23), le_refl _⟩
  rw [e1] at hl1; rw [e2] at hh; rw [e3] at hl3
  nlinarith [mul_pos (sub_pos.2 h12) (sub_pos.2 h23), sub_pos.2 h12, sub_pos.2 h23]

end ReluDepth

end