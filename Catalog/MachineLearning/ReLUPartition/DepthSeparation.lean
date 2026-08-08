import Mathlib
import MachineLearning.ReLUPartition.DeepBound

/-!
# Exponential depth separation for ReLU partitions

The product bound of `MachineLearning.ReLUPartition.DeepBound` is an upper
bound; this file supplies the matching *lower* bound phenomenon that makes depth
worth having.  The width-`2` sawtooth network on `ℝ` — the ReLU realization of
the tent map `t(x) = 2x - 4·relu(x - 1/2)` iterated `L` times — realizes **all**
`2^L` sign patterns of its second neuron, hence has at least `2^L` cells.

Combining with the exact single-layer formula `schlafli v 1 = v + 1` yields a
genuine width–depth separation: a *single* ReLU layer needs at least `2^L - 1`
neurons to cut the line into as many pieces as the depth-`L`, width-`2` sawtooth
network does.  All statements are about the exact region counts introduced in
this development, so the separation is unconditional.
-/

namespace ReLUPartition

open Finset AffineFamily

/-- The tent map, realized exactly by one ReLU layer of width two. -/
noncomputable def tent (x : ℝ) : ℝ := 2 * x - 4 * max 0 (x - 1 / 2)

lemma tent_of_le {x : ℝ} (h : x ≤ 1 / 2) : tent x = 2 * x := by
  unfold tent
  rw [max_eq_left (by linarith)]
  ring

lemma tent_of_ge {x : ℝ} (h : 1 / 2 ≤ x) : tent x = 2 - 2 * x := by
  unfold tent
  rw [max_eq_right (by linarith)]
  ring

lemma tent_nonneg {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) : 0 ≤ tent x := by
  rcases le_or_gt x (1 / 2) with h | h
  · rw [tent_of_le h]; linarith
  · rw [tent_of_ge (le_of_lt h)]; linarith

lemma tent_le_one (x : ℝ) : tent x ≤ 1 := by
  rcases le_or_gt x (1 / 2) with h | h
  · rw [tent_of_le h]; linarith
  · rw [tent_of_ge (le_of_lt h)]; linarith

lemma tent_iterate_mem {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) (l : ℕ) :
    0 ≤ tent^[l] x ∧ tent^[l] x ≤ 1 := by
  induction l with
  | zero => exact ⟨h0, h1⟩
  | succ l ih =>
      rw [Function.iterate_succ_apply']
      exact ⟨tent_nonneg ih.1 ih.2, tent_le_one _⟩

/-! ### The sawtooth network -/

/-- First layer of the sawtooth network: `x ↦ (x, x - 1/2)`. -/
noncomputable def sawFirst : AffineFamily 2 1 :=
  { weight := fun _ _ => 1
    bias := ![0, -(1 / 2)] }

/-- Repeated layer of the sawtooth network: `(z₀, z₁) ↦ (2z₀ - 4z₁, 2z₀ - 4z₁ - 1/2)`. -/
noncomputable def sawLayer : AffineFamily 2 2 :=
  { weight := fun _ => ![2, -4]
    bias := ![0, -(1 / 2)] }

/-- The width-two sawtooth network on the line. -/
noncomputable def sawNet : ReLUNet 1 2 := ⟨sawFirst, fun _ => sawLayer⟩

@[simp] lemma sawNet_first : sawNet.first = sawFirst := rfl

@[simp] lemma sawNet_layer (l : ℕ) : sawNet.layer l = sawLayer := rfl

lemma eval_sawFirst_zero (x : Fin 1 → ℝ) : sawFirst.eval 0 x = x 0 := by
  simp [sawFirst, AffineFamily.eval]

lemma eval_sawFirst_one (x : Fin 1 → ℝ) : sawFirst.eval 1 x = x 0 - 1 / 2 := by
  simp [sawFirst, AffineFamily.eval]
  ring

lemma eval_sawLayer_zero (z : Fin 2 → ℝ) : sawLayer.eval 0 z = 2 * z 0 - 4 * z 1 := by
  simp [sawLayer, AffineFamily.eval, Fin.sum_univ_two]
  ring

lemma eval_sawLayer_one (z : Fin 2 → ℝ) : sawLayer.eval 1 z = 2 * z 0 - 4 * z 1 - 1 / 2 := by
  simp [sawLayer, AffineFamily.eval, Fin.sum_univ_two]
  ring

/-- **State invariant.**  After `l` layers the sawtooth network holds the pair
`(t^l(x), relu (t^l(x) - 1/2))`. -/
lemma act_sawNet {x : Fin 1 → ℝ} (h0 : 0 ≤ x 0) (h1 : x 0 ≤ 1) (l : ℕ) :
    sawNet.act l x = ![tent^[l] (x 0), max 0 (tent^[l] (x 0) - 1 / 2)] := by
  induction l with
  | zero =>
      funext i
      simp only [ReLUNet.act, sawNet_first, Function.iterate_zero_apply]
      fin_cases i
      · simp [eval_sawFirst_zero, max_eq_right h0]
      · simp [eval_sawFirst_one]
  | succ l ih =>
      obtain ⟨hm0, hm1⟩ := tent_iterate_mem h0 h1 l
      have hz0 : sawNet.act l x 0 = tent^[l] (x 0) := by rw [ih]; simp
      have hz1 : sawNet.act l x 1 = max 0 (tent^[l] (x 0) - 1 / 2) := by rw [ih]; simp
      have hiter : tent^[l + 1] (x 0) = tent (tent^[l] (x 0)) :=
        Function.iterate_succ_apply' tent l (x 0)
      have hnn : 0 ≤ tent (tent^[l] (x 0)) := tent_nonneg hm0 hm1
      funext i
      simp only [ReLUNet.act, sawNet_layer, hiter]
      fin_cases i
      · show max 0 (sawLayer.eval 0 (sawNet.act l x)) = tent (tent^[l] (x 0))
        rw [eval_sawLayer_zero, hz0, hz1]
        have : 2 * tent^[l] (x 0) - 4 * max 0 (tent^[l] (x 0) - 1 / 2)
            = tent (tent^[l] (x 0)) := by unfold tent; ring
        rw [this, max_eq_right hnn]
      · show max 0 (sawLayer.eval 1 (sawNet.act l x))
            = max 0 (tent (tent^[l] (x 0)) - 1 / 2)
        rw [eval_sawLayer_one, hz0, hz1]
        have : 2 * tent^[l] (x 0) - 4 * max 0 (tent^[l] (x 0) - 1 / 2) - 1 / 2
            = tent (tent^[l] (x 0)) - 1 / 2 := by unfold tent; ring
        rw [this]

/-- The second neuron of layer `l` fires exactly when the `l`-th tent iterate
exceeds `1/2`: the network reads off the binary itinerary of its input. -/
lemma mem_layerPattern_sawNet {x : Fin 1 → ℝ} (h0 : 0 ≤ x 0) (h1 : x 0 ≤ 1) (l : ℕ) :
    (1 : Fin 2) ∈ sawNet.layerPattern l x ↔ 1 / 2 < tent^[l] (x 0) := by
  cases l with
  | zero =>
      rw [ReLUNet.layerPattern, sawNet_first, mem_pattern, eval_sawFirst_one,
        Function.iterate_zero_apply]
      constructor <;> intro h <;> linarith
  | succ l =>
      obtain ⟨hm0, hm1⟩ := tent_iterate_mem h0 h1 l
      have hz0 : sawNet.act l x 0 = tent^[l] (x 0) := by rw [act_sawNet h0 h1 l]; simp
      have hz1 : sawNet.act l x 1 = max 0 (tent^[l] (x 0) - 1 / 2) := by
        rw [act_sawNet h0 h1 l]; simp
      rw [ReLUNet.layerPattern, sawNet_layer, mem_pattern, eval_sawLayer_one, hz0, hz1,
        Function.iterate_succ_apply' tent l (x 0)]
      have hrw : 2 * tent^[l] (x 0) - 4 * max 0 (tent^[l] (x 0) - 1 / 2) - 1 / 2
          = tent (tent^[l] (x 0)) - 1 / 2 := by unfold tent; ring
      rw [hrw]
      constructor <;> intro h <;> linarith

/-! ### All `2^L` binary patterns are realized -/

/-- **Surjectivity of the itinerary map.**  Every binary string of length `L`
occurs as the itinerary of some point of `(0,1)` under the tent map. -/
theorem exists_itinerary (L : ℕ) (b : Fin L → Bool) :
    ∃ y : ℝ, 0 < y ∧ y < 1 ∧ ∀ l : Fin L, ((1 / 2 < tent^[(l : ℕ)] y) ↔ b l = true) := by
  induction L with
  | zero => exact ⟨1 / 2, by norm_num, by norm_num, fun l => absurd l.isLt (by omega)⟩
  | succ L ih =>
      obtain ⟨y, hy0, hy1, hy⟩ := ih (fun j : Fin L => b j.succ)
      by_cases hb : b 0 = true
      · refine ⟨1 - y / 2, by linarith, by linarith, ?_⟩
        have hx : (1 : ℝ) / 2 ≤ 1 - y / 2 := by linarith
        have htent : tent (1 - y / 2) = y := by rw [tent_of_ge hx]; ring
        intro l
        refine Fin.cases ?_ ?_ l
        · simp only [Fin.val_zero, Function.iterate_zero_apply, hb, iff_true]
          linarith
        · intro j
          have hval : ((j.succ : Fin (L + 1)) : ℕ) = (j : ℕ) + 1 := rfl
          rw [hval, Function.iterate_succ_apply, htent]
          exact hy j
      · have hb' : b 0 = false := by
          rcases Bool.eq_false_or_eq_true (b 0) with h | h
          · exact absurd h hb
          · exact h
        refine ⟨y / 2, by linarith, by linarith, ?_⟩
        have hx : y / 2 ≤ (1 : ℝ) / 2 := by linarith
        have htent : tent (y / 2) = y := by rw [tent_of_le hx]; ring
        intro l
        refine Fin.cases ?_ ?_ l
        · simp only [Fin.val_zero, Function.iterate_zero_apply, hb', Bool.false_eq_true, iff_false,
            not_lt]
          linarith
        · intro j
          have hval : ((j.succ : Fin (L + 1)) : ℕ) = (j : ℕ) + 1 := rfl
          rw [hval, Function.iterate_succ_apply, htent]
          exact hy j

/-- **Exponential lower bound.**  The depth-`L` sawtooth network of width two
has at least `2^L` cells. -/
theorem two_pow_le_card_netRegions_sawNet (L : ℕ) :
    2 ^ L ≤ (sawNet.netRegions L).card := by
  classical
  set Phi : (Fin L → Finset (Fin 2)) → (Fin L → Bool) :=
    fun q l => decide ((1 : Fin 2) ∈ q l) with hPhi
  have hsurj : Set.SurjOn Phi (sawNet.netRegions L) (Finset.univ : Finset (Fin L → Bool)) := by
    intro b _
    obtain ⟨y, hy0, hy1, hy⟩ := exists_itinerary L b
    have h0 : (0 : ℝ) ≤ (fun _ : Fin 1 => y) 0 := le_of_lt hy0
    have h1 : (fun _ : Fin 1 => y) 0 ≤ 1 := le_of_lt hy1
    refine ⟨sawNet.netPattern L (fun _ => y), ?_, ?_⟩
    · simp only [Finset.mem_coe, ReLUNet.mem_netRegions]
      exact ⟨fun _ => y, rfl⟩
    · funext l
      have hml := mem_layerPattern_sawNet (x := fun _ : Fin 1 => y) h0 h1 (l : ℕ)
      have hiff : ((1 : Fin 2) ∈ sawNet.netPattern L (fun _ => y) l) ↔ b l = true :=
        hml.trans (hy l)
      simp only [hPhi]
      rw [decide_eq_decide.mpr hiff, Bool.decide_coe]
  have hcard := Finset.card_le_card_of_surjOn Phi hsurj
  have huniv : (Finset.univ : Finset (Fin L → Bool)).card = 2 ^ L := by
    rw [Finset.card_univ, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
  omega

/-- **Width–depth separation.**  Any single ReLU layer on the line that matches
the cell count of the depth-`L` sawtooth network must have at least `2^L - 1`
neurons: depth buys exponentially many regions per neuron. -/
theorem shallow_width_ge_of_matching {v L : ℕ} (F : AffineFamily v 1)
    (h : (sawNet.netRegions L).card ≤ F.regionCount) : 2 ^ L - 1 ≤ v := by
  have h1 : F.regionCount ≤ schlafli v 1 := F.regionCount_le_schlafli
  have h2 : 2 ^ L ≤ (sawNet.netRegions L).card := two_pow_le_card_netRegions_sawNet L
  rw [schlafli_one_dim] at h1
  omega

/-- The sawtooth cell count is squeezed between the exact lower bound `2^L` and
the product upper bound `3^L`. -/
theorem sawNet_between (L : ℕ) :
    2 ^ L ≤ (sawNet.netRegions L).card ∧ (sawNet.netRegions L).card ≤ 3 ^ L := by
  refine ⟨two_pow_le_card_netRegions_sawNet L, ?_⟩
  have h := sawNet.card_netRegions_le L
  have hs : schlafli 2 1 = 3 := by simp
  rwa [hs] at h

end ReLUPartition