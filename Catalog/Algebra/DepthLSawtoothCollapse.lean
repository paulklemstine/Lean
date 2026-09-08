import Algebra.DepthLOscillationLowerBound

/-!
# The depth-`(L+1)` sawtooth witness collapses to depth `L`

`Algebra.DepthLOscillationLowerBound` proves an exponential depth separation
between depth `L` and depth `L^2+4`.  It is natural to ask for the *literal*
one-step version: are there functions computed by depth-`(L+1)` networks of
size polynomial in `L` which every depth-`L` network needs exponential size to
approximate?

This file shows that the canonical witness family — the sawtooth tower
`tri^[L+1]`, which is exactly the family used for all known depth lower bounds
— **does not** witness such a one-step separation:

* `tri_tri_eq_tri2` : the two-fold sawtooth `tri ∘ tri` is *exactly* a single
  ReLU layer of width `5`;
* `sawtooth_collapse` : consequently `tri^[L+1]` is computed *exactly* (error
  `0`, not merely approximately) by a ReLU network of depth `L` and width `5`,
  i.e. by `5L` hidden neurons — polynomial in `L`;
* `depth_plus_one_witness_collapses` : so the same function is a depth-`(L+1)`
  width-`3` network *and* a depth-`L` width-`5` network.

Combined with `ReluDepth.relu_depth_separation`, this delimits the truth
precisely: sawtooth towers give an exponential depth-`L` lower bound when the
tower height is quadratic in `L`, and give *no* lower bound at all when the
tower height is `L+1`.  Any proof of a one-step exponential separation must
therefore use a genuinely different witness family.

The mechanism is that a single hidden layer can realise *any* continuous
piecewise affine function with a bounded number of pieces; the `4`-piece
function `tri ∘ tri` needs only `5` ReLU units.
-/

noncomputable section

namespace ReluDepth

open Finset

/-- The five biases of the collapsed two-fold sawtooth layer. -/
def tri2Shift : Fin 5 → ℝ := ![0, 1/4, 1/2, 3/4, 1]

/-- The five read-out weights of the collapsed two-fold sawtooth layer. -/
def tri2Coef : Fin 5 → ℝ := ![4, -8, 8, -8, 4]

/-- The two-fold sawtooth written as one ReLU layer of width `5`. -/
def tri2 (y : ℝ) : ℝ :=
  4 * relu y - 8 * relu (y - 1/4) + 8 * relu (y - 1/2) - 8 * relu (y - 3/4) + 4 * relu (y - 1)

lemma tri2_as_comb (y : ℝ) : (∑ i : Fin 5, tri2Coef i * relu (y - tri2Shift i)) = tri2 y := by
  simp [Fin.sum_univ_five, tri2Coef, tri2Shift, tri2]
  ring

lemma tri_of_nonpos {y : ℝ} (h : y ≤ 0) : tri y = 0 := by
  unfold tri relu
  rw [max_eq_right h, max_eq_right (by linarith), max_eq_right (by linarith)]
  ring

lemma tri_of_one_le {y : ℝ} (h : 1 ≤ y) : tri y = 0 := by
  unfold tri relu
  rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_left (by linarith)]
  ring

/-- **One layer suffices for two sawtooths.**  `tri ∘ tri` equals the width-`5`
ReLU layer `tri2`. -/
theorem tri_tri_eq_tri2 (y : ℝ) : tri (tri y) = tri2 y := by
  unfold tri2 relu
  rcases le_or_gt y 0 with h0 | h0
  · rw [max_eq_right h0, max_eq_right (by linarith), max_eq_right (by linarith),
      max_eq_right (by linarith), max_eq_right (by linarith)]
    have hty : tri y = 0 := tri_of_nonpos h0
    rw [hty, tri_of_nonpos (le_refl 0)]
    ring
  rcases le_or_gt y (1/4) with h1 | h1
  · rw [max_eq_left (by linarith), max_eq_right (by linarith), max_eq_right (by linarith),
      max_eq_right (by linarith), max_eq_right (by linarith)]
    have hty : tri y = 2 * y := tri_left (by linarith) (by linarith)
    rw [hty, tri_left (by linarith) (by linarith)]
    ring
  rcases le_or_gt y (1/2) with h2 | h2
  · rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_right (by linarith),
      max_eq_right (by linarith), max_eq_right (by linarith)]
    have hty : tri y = 2 * y := tri_left (by linarith) (by linarith)
    rw [hty, tri_right (by linarith) (by linarith)]
    ring
  rcases le_or_gt y (3/4) with h3 | h3
  · rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_left (by linarith),
      max_eq_right (by linarith), max_eq_right (by linarith)]
    have hty : tri y = 2 - 2 * y := tri_right (by linarith) (by linarith)
    rw [hty, tri_right (by linarith) (by linarith)]
    ring
  rcases le_or_gt y 1 with h4 | h4
  · rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_left (by linarith),
      max_eq_left (by linarith), max_eq_right (by linarith)]
    have hty : tri y = 2 - 2 * y := tri_right (by linarith) (by linarith)
    rw [hty, tri_left (by linarith) (by linarith)]
    ring
  · rw [max_eq_left (by linarith), max_eq_left (by linarith), max_eq_left (by linarith),
      max_eq_left (by linarith), max_eq_left (by linarith)]
    have hty : tri y = 0 := tri_of_one_le (by linarith)
    rw [hty, tri_of_nonpos (le_refl 0)]
    ring

/-- The first hidden layer of the collapsed network: five ReLU units. -/
theorem tri2_layerUnits :
    LayerUnits 5 1 (fun (j : Fin 5) (x : ℝ) => relu (x - tri2Shift j)) := by
  have h := (LayerUnits.input (w := 5)).step (by norm_num)
    (fun (_ : Fin 5) (_ : Fin 1) => (1:ℝ)) (fun j => -tri2Shift j)
  have e : (fun (j : Fin 5) (x : ℝ) => relu (x - tri2Shift j))
      = fun (j : Fin 5) (x : ℝ) => relu ((∑ _i : Fin 1, (1:ℝ) * x) + (-tri2Shift j)) := by
    funext j x
    simp [sub_eq_add_neg]
  rw [e]; exact h

/-- **Collapse theorem.**  For every depth `L ≥ 2`, the sawtooth tower `tri^[L+1]`
— the canonical function of depth `L+1` — is computed *exactly* by a ReLU network
of depth `L` and width `5`, hence by `5L` hidden neurons. -/
theorem sawtooth_collapse (L : ℕ) (hL : 2 ≤ L) : IsNet 5 L (tri^[L+1]) := by
  obtain ⟨l, rfl⟩ : ∃ l, L = l + 2 := ⟨L - 2, by omega⟩
  have h := tri_tower_isNet (w := 5) (by norm_num) tri2_layerUnits tri2Coef 0 l
  have e : (fun x : ℝ => tri^[l+1] ((∑ i, tri2Coef i * relu (x - tri2Shift i)) + 0))
      = tri^[l+2+1] := by
    funext x
    rw [add_zero, tri2_as_comb, ← tri_tri_eq_tri2]
    have h2 : tri^[l+1+2] x = tri^[l+1] (tri^[2] x) := Function.iterate_add_apply tri (l+1) 2 x
    have h3 : tri^[2] x = tri (tri x) := by
      rw [Function.iterate_succ_apply, Function.iterate_one]
    have h4 : l + 2 + 1 = l + 1 + 2 := by omega
    rw [h4, h2, h3]
  rw [e] at h
  have e2 : 1 + 1 + l = l + 2 := by omega
  rwa [e2] at h

/-- **The one-step version of the conjecture fails for sawtooth witnesses.**
For `L ≥ 2` the *same* explicit function is computed by a depth-`(L+1)` network of
width `3` and by a depth-`L` network of width `5`.  In particular no
exponential-in-`L` size lower bound can hold for depth-`L` approximation of this
witness family — approximation is not even needed, the representation is exact. -/
theorem depth_plus_one_witness_collapses (L : ℕ) (hL : 2 ≤ L) :
    IsNet 3 (L+1) (tri^[L+1]) ∧ IsNet 5 L (tri^[L+1]) :=
  ⟨sawtooth_isNet L, sawtooth_collapse L hL⟩

/-! ## Two teeth per layer -/

/-- **A width-`5` layer doubles the tower twice as fast.**  Stacking `l+1` copies of
the collapsed layer produces the units of `tri^[2l]`. -/
theorem tri2_tower_layerUnits (l : ℕ) :
    LayerUnits 5 (l+1) (fun (j : Fin 5) (x : ℝ) => relu (tri^[2*l] x - tri2Shift j)) := by
  induction l with
  | zero => simpa using tri2_layerUnits
  | succ l ih =>
      have h := ih.step (le_refl 5) (fun (_ : Fin 5) (i : Fin 5) => tri2Coef i)
        (fun j => -tri2Shift j)
      have e : (fun (j : Fin 5) (x : ℝ) => relu (tri^[2*(l+1)] x - tri2Shift j))
          = fun (j : Fin 5) (x : ℝ) => relu ((∑ i : Fin 5, tri2Coef i *
              relu (tri^[2*l] x - tri2Shift i)) + (-tri2Shift j)) := by
        funext j x
        rw [tri2_as_comb, ← tri_tri_eq_tri2, sub_eq_add_neg]
        have h1 : tri^[2*(l+1)] x = tri (tri (tri^[2*l] x)) := by
          have e2 : 2*(l+1) = 2*l + 1 + 1 := by omega
          rw [e2, Function.iterate_succ_apply' tri (2*l+1),
            Function.iterate_succ_apply' tri (2*l)]
        rw [h1]
      rw [e]; exact h

/-- **Optimality of the counting bound.**  A ReLU network of depth `L` and width `5`
computes the sawtooth tower `tri^[2L]` exactly: each layer contributes a factor `4`
to the number of oscillations, matching (up to the base) the counting upper bound
`2^k ≤ 4 (2w+2)^L` of `relu_oscillation_bound`. -/
theorem tri2_tower_isNet (l : ℕ) : IsNet 5 (l+1) (tri^[2*(l+1)]) := by
  refine ⟨5, _, tri2_tower_layerUnits l, tri2Coef, 0, ?_⟩
  funext x
  rw [add_zero, tri2_as_comb, ← tri_tri_eq_tri2]
  have e2 : 2*(l+1) = 2*l + 1 + 1 := by omega
  rw [e2, Function.iterate_succ_apply' tri (2*l+1), Function.iterate_succ_apply' tri (2*l)]

/-- **Sharpness bracket at width `5`.**  Let `k(L)` be the largest tower height that a
depth-`L`, width-`5` ReLU network can compute exactly.  Then `2L ≤ k(L) ≤ 4L+2`:
the achievable tower height is *linear* in the depth, with the constant pinned
between `2` and `4`.  In particular no width-`5` network of depth `L` reaches the
quadratic height `L^2+4` once `L ≥ 7`. -/
theorem tri2_tower_bracket (L : ℕ) (hL : 1 ≤ L) :
    IsNet 5 L (tri^[2*L]) ∧ ∀ k : ℕ, IsNet 5 L (tri^[k]) → k ≤ 4 * L + 2 := by
  obtain ⟨l, rfl⟩ : ∃ l, L = l + 1 := ⟨L - 1, by omega⟩
  refine ⟨tri2_tower_isNet l, fun k hk => ?_⟩
  have h1 : 2 ^ k ≤ 4 * (2 * 5 + 2) ^ (l+1) :=
    relu_oscillation_bound (l+1) 5 k _ hk (by intro x _; simp)
  have h2 : (12:ℕ) ^ (l+1) ≤ 16 ^ (l+1) := Nat.pow_le_pow_left (by norm_num) _
  have h3 : (16:ℕ) ^ (l+1) = 2 ^ (4 * (l+1)) := by
    rw [show (16:ℕ) = 2 ^ 4 by norm_num, ← pow_mul, mul_comm]
  have h4 : (2:ℕ) ^ k ≤ 2 ^ (4 * (l+1) + 2) := by
    calc (2:ℕ) ^ k ≤ 4 * 12 ^ (l+1) := by norm_num at h1 ⊢; exact h1
      _ ≤ 4 * 2 ^ (4 * (l+1)) := by rw [← h3]; exact Nat.mul_le_mul_left 4 h2
      _ = 2 ^ (4 * (l+1) + 2) := by rw [pow_add]; ring
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp h4

/-- Quantitative consistency check: the exponential knot budget is not an artefact.
The collapsed depth-`L` width-`5` network computes `tri^[L+1]` exactly, so the knot
lower bound `tri_iterate_knots` forces `2^(L+1) ≤ 2 * knotBound 5 L + 1`; the knot
counting bound of `layerUnits_pwa` must therefore itself grow exponentially in `L`. -/
theorem collapsed_net_knot_count (L : ℕ) (hL : 2 ≤ L) :
    ∃ S : Finset ℝ, S.card ≤ knotBound 5 L ∧ 2 ^ (L+1) ≤ 2 * S.card + 1 := by
  obtain ⟨S, hScard, hS⟩ := (sawtooth_collapse L hL).pwa
  exact ⟨S, hScard, tri_iterate_knots (L+1) hS⟩

end ReluDepth

end