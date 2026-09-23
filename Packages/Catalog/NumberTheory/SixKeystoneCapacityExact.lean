import Catalog.NumberTheory.SixKeystoneZeroDrift

/-!
# Cycle II: the exact capacity curve of a full-period pipeline

`Catalog/NumberTheory/SixKeystoneZeroDrift.lean` proved the *qualitative* shape of the
audited capacity curve: nondecreasing capacity, deficits starting at `+0.000`,
nondecreasing and divergent.  A reproducibility audit reports *numbers*, not shapes, so the
next question is whether the numbers themselves are forced.  They are, for the full-period
(rotation) pipeline `x ↦ x + 1 mod m`:

* `rot_run` — the state after `n` steps is exactly `(s + n) % m`;
* `rot_states_card` — the number of distinct states seen by time `k` is exactly
  `min (k+1) m`;
* `rot_cap_eq`, `rot_deficit_eq` — hence `I(k) = log₂ (min (k+1) m)` and
  `d(k) = k − log₂ (min (k+1) m)`, with *no* free parameters: the whole recorded curve is a
  function of `m` alone, so two audits of the same pipeline must agree digit for digit;
* `rot_deficit_slope_one` — after saturation (`m ≤ k + 1`) consecutive deficits differ by
  exactly `1`, the asymptotic unit slope;
* `rot_deficit_strictMono_presaturation` — before saturation the deficit strictly increases
  from `k = 1` on, so the recorded curve `+0.000, …` is strictly ramping, never flat.
-/

namespace SixKeystoneZeroDrift

open Finset

section

/-- The full-period rotation pipeline: `a = 1`, `c = 1`. -/
theorem rot_run (m : ℕ) (hm : 0 < m) (n s : ℕ) (hs : s < m) :
    run 1 1 m n s = (s + n) % m := by
  induction n generalizing s with
  | zero => simpa using (Nat.mod_eq_of_lt hs).symm
  | succ n ih =>
      rw [run_succ]
      have hstep : step 1 1 m s = (s + 1) % m := by simp [step]
      rw [hstep, ih _ (Nat.mod_lt _ hm), Nat.mod_add_mod]
      congr 1
      omega

lemma rot_states (m : ℕ) (hm : 0 < m) (s : ℕ) (hs : s < m) (k : ℕ) :
    states 1 1 m s k = (range (k + 1)).image (fun i => (s + i) % m) := by
  unfold states
  refine Finset.image_congr ?_
  intro i _
  exact rot_run m hm i s hs

/-- **The exact orbit count.** A full-period pipeline has seen exactly `min (k+1) m`
distinct states by time `k`. -/
theorem rot_states_card (m : ℕ) (hm : 0 < m) (s : ℕ) (hs : s < m) (k : ℕ) :
    (states 1 1 m s k).card = min (k + 1) m := by
  classical
  rw [rot_states m hm s hs k]
  rcases le_total (k + 1) m with h | h
  · -- before saturation the map is injective
    rw [min_eq_left h]
    rw [Finset.card_image_of_injOn, Finset.card_range]
    intro i hi j hj hij
    simp only [Finset.mem_coe, Finset.mem_range] at hi hj
    have hmod : (s + i) % m = (s + j) % m := hij
    have : i % m = j % m := Nat.ModEq.add_left_cancel' s hmod
    rwa [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)] at this
  · -- after saturation the image is the whole residue window
    rw [min_eq_right h]
    have himg : (range (k + 1)).image (fun i => (s + i) % m) = range m := by
      apply Finset.Subset.antisymm
      · intro x hx
        simp only [Finset.mem_image, Finset.mem_range] at hx ⊢
        obtain ⟨i, _, rfl⟩ := hx
        exact Nat.mod_lt _ hm
      · intro x hx
        simp only [Finset.mem_range] at hx
        simp only [Finset.mem_image, Finset.mem_range]
        refine ⟨(x + m - s) % m, lt_of_lt_of_le (Nat.mod_lt _ hm) h, ?_⟩
        have h1 : (s + (x + m - s) % m) % m = (s + (x + m - s)) % m := Nat.add_mod_mod _ _ _
        have h2 : s + (x + m - s) = x + m := by omega
        rw [h1, h2, Nat.add_mod_right, Nat.mod_eq_of_lt hx]
    rw [himg, Finset.card_range]

/-- **The exact capacity curve**: `I(k) = log₂ (min (k+1) m)`. -/
theorem rot_cap_eq (m : ℕ) (hm : 0 < m) (s : ℕ) (hs : s < m) (k : ℕ) :
    cap 1 1 m s k = Real.logb 2 ((min (k + 1) m : ℕ) : ℝ) := by
  rw [cap, rot_states_card m hm s hs k]

/-- **The exact deficit curve**: `d(k) = k − log₂ (min (k+1) m)`. -/
theorem rot_deficit_eq (m : ℕ) (hm : 0 < m) (s : ℕ) (hs : s < m) (k : ℕ) :
    deficit 1 1 m s k = (k : ℝ) - Real.logb 2 ((min (k + 1) m : ℕ) : ℝ) := by
  rw [deficit, rot_cap_eq m hm s hs k]

/-- After saturation the deficit grows with slope exactly `1`. -/
theorem rot_deficit_slope_one (m : ℕ) (hm : 0 < m) (s : ℕ) (hs : s < m) (k : ℕ)
    (hk : m ≤ k + 1) :
    deficit 1 1 m s (k + 1) - deficit 1 1 m s k = 1 := by
  rw [rot_deficit_eq m hm s hs, rot_deficit_eq m hm s hs]
  rw [min_eq_right hk, min_eq_right (by omega : m ≤ k + 1 + 1)]
  push_cast
  ring

/-- Every congruential pipeline on modulus `m` has seen at most `min (k+1) m` states. -/
lemma states_card_le_envelope (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (k : ℕ) :
    (states a c m s k).card ≤ min (k + 1) m := by
  refine le_min ?_ (states_card_le_modulus a c m s hm hs k)
  calc (states a c m s k).card ≤ (Finset.range (k + 1)).card := Finset.card_image_le
    _ = k + 1 := Finset.card_range _

/-- **The full-period curve is an upper envelope.** No congruential pipeline on modulus `m`
has capacity above `log₂ (min (k+1) m)`, and the rotation pipeline attains it
(`rot_cap_eq`). -/
theorem cap_le_envelope (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (k : ℕ) :
    cap a c m s k ≤ Real.logb 2 ((min (k + 1) m : ℕ) : ℝ) := by
  have hpos : (0 : ℝ) < ((states a c m s k).card : ℝ) := by
    exact_mod_cast states_card_pos a c m s k
  refine Real.logb_le_logb_of_le (by norm_num) hpos ?_
  exact_mod_cast states_card_le_envelope a c m s hm hs k

/-- Dually: no pipeline's deficit ever falls below the full-period deficit. -/
theorem deficit_ge_envelope (a c m s : ℕ) (hm : 0 < m) (hs : s < m) (k : ℕ) :
    deficit 1 1 m s k ≤ deficit a c m s k := by
  have h1 := cap_le_envelope a c m s hm hs k
  rw [deficit, deficit, rot_cap_eq m hm s hs k]
  linarith

/-- Before saturation the deficit strictly increases from `k = 1` on: the curve ramps. -/
theorem rot_deficit_strictMono_presaturation (m : ℕ) (hm : 0 < m) (s : ℕ) (hs : s < m)
    (k : ℕ) (hk : 1 ≤ k) (hkm : k + 2 ≤ m) :
    deficit 1 1 m s k < deficit 1 1 m s (k + 1) := by
  rw [rot_deficit_eq m hm s hs, rot_deficit_eq m hm s hs]
  rw [min_eq_left (by omega : k + 1 ≤ m), min_eq_left (by omega : k + 1 + 1 ≤ m)]
  have hlt : Real.logb 2 ((k + 1 + 1 : ℕ) : ℝ) < 1 + Real.logb 2 ((k + 1 : ℕ) : ℝ) := by
    have hpos : (0 : ℝ) < ((k + 1 : ℕ) : ℝ) := by positivity
    have hstep : ((k + 1 + 1 : ℕ) : ℝ) < 2 * ((k + 1 : ℕ) : ℝ) := by
      push_cast
      have : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
      linarith
    have h2 : Real.logb 2 ((k + 1 + 1 : ℕ) : ℝ) < Real.logb 2 (2 * ((k + 1 : ℕ) : ℝ)) :=
      Real.logb_lt_logb (by norm_num) (by positivity) hstep
    rwa [Real.logb_mul (by norm_num) (ne_of_gt hpos),
      Real.logb_self_eq_one (b := 2) (by norm_num)] at h2
  push_cast at hlt ⊢
  linarith

end

end SixKeystoneZeroDrift