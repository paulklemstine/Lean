import Catalog.NumberTheory.SixKeystoneZeroDrift

/-!
# Cycle IV: the deficit slope detector for an arbitrary pipeline

`Catalog/NumberTheory/SixKeystoneCapacityExact.lean` computed the capacity curve of the
*rotation* pipeline exactly: `#states = min (k+1) m`.  Direction 2 of
`FUTURE_DIRECTIONS.md` conjectured that the same exact shape — a strictly ramping deficit
before saturation and a deficit of slope exactly `1` afterwards — holds for *every*
deterministic pipeline with a finite state window, the modulus `m` being replaced by the
size `N` of the orbit actually visited.  This file proves that conjecture.

## Main results

* `run_eq_iterate`, `states_eq_orb` — the congruential pipeline is the iterate of its step
  map, so the audited state set is the orbit prefix `orb f s k`.
* `orb_card_eq_min` — **the exact orbit-count law**: for any `f : ℕ → ℕ` whose orbit from
  `s` stays inside a finite window there is an orbit size `N` (at most the window size)
  with `#(orb f s k) = min (k+1) N` for *every* `k`.  No periodicity hypothesis is needed;
  finiteness alone forces the shape.
* `states_card_eq_min` — the same statement for the congruential pipeline of
  cycle I, which strictly generalises `rot_states_card`.
* `deficit_slope_one_of_saturated`, `deficit_slope_lt_one_of_presaturation`,
  `deficit_saturation_index` — the detector: consecutive deficits differ by exactly `1`
  from the saturation index on, and by strictly less than `1` before it.  Hence the orbit
  size is recoverable from the deficit column alone.
-/

namespace SixKeystoneZeroDrift

open Finset

section

/-! ## Orbits of an arbitrary endofunction -/

/-- The set of states visited by `f` from seed `s` up to and including time `k`. -/
def orb (f : ℕ → ℕ) (s k : ℕ) : Finset ℕ := (range (k + 1)).image (fun i => f^[i] s)

lemma mem_orb_iff {f : ℕ → ℕ} {s k x : ℕ} : x ∈ orb f s k ↔ ∃ i ≤ k, f^[i] s = x := by
  simp only [orb, Finset.mem_image, Finset.mem_range, Nat.lt_succ_iff]

lemma orb_zero (f : ℕ → ℕ) (s : ℕ) : orb f s 0 = {s} := by simp [orb]

lemma orb_succ (f : ℕ → ℕ) (s k : ℕ) :
    orb f s (k + 1) = insert (f^[k + 1] s) (orb f s k) := by
  unfold orb
  rw [Finset.range_add_one, Finset.image_insert]

/-- Once the orbit prefix stops growing it never grows again. -/
lemma orb_stable_step {f : ℕ → ℕ} {s k : ℕ} (h : orb f s (k + 1) = orb f s k) :
    orb f s (k + 2) = orb f s (k + 1) := by
  have hmem : f^[k + 1] s ∈ orb f s k := by
    rw [← h, orb_succ]; exact Finset.mem_insert_self _ _
  obtain ⟨i, hik, hi⟩ := mem_orb_iff.1 hmem
  have hnew : f^[k + 2] s ∈ orb f s (k + 1) := by
    refine mem_orb_iff.2 ⟨i + 1, by omega, ?_⟩
    rw [Function.iterate_succ_apply', Function.iterate_succ_apply', hi]
  rw [orb_succ, Finset.insert_eq_self.2]
  exact hnew

lemma orb_stable {f : ℕ → ℕ} {s K : ℕ} (h : orb f s (K + 1) = orb f s K) :
    ∀ j : ℕ, orb f s (K + j + 1) = orb f s (K + j) ∧ orb f s (K + j) = orb f s K := by
  intro j
  induction j with
  | zero => exact ⟨h, rfl⟩
  | succ j ih =>
      have e : K + (j + 1) = K + j + 1 := by omega
      rw [e]
      exact ⟨orb_stable_step ih.1, by rw [ih.1]; exact ih.2⟩

lemma orb_eq_of_le {f : ℕ → ℕ} {s K : ℕ} (h : orb f s (K + 1) = orb f s K) {k : ℕ}
    (hk : K ≤ k) : orb f s k = orb f s K := by
  obtain ⟨j, rfl⟩ := Nat.exists_eq_add_of_le hk
  exact (orb_stable h j).2

/-- While the orbit prefix is still growing it gains exactly one state per step. -/
lemma orb_card_succ_of_ne {f : ℕ → ℕ} {s k : ℕ} (h : orb f s (k + 1) ≠ orb f s k) :
    (orb f s (k + 1)).card = (orb f s k).card + 1 := by
  rw [orb_succ]
  refine Finset.card_insert_of_notMem (fun hmem => h ?_)
  rw [orb_succ, Finset.insert_eq_self.2 hmem]

lemma orb_subset_range {f : ℕ → ℕ} {s m : ℕ} (hb : ∀ i, f^[i] s < m) (k : ℕ) :
    orb f s k ⊆ range m := by
  intro x hx
  obtain ⟨i, _, rfl⟩ := mem_orb_iff.1 hx
  exact Finset.mem_range.2 (hb i)

/-- With a finite state window the orbit prefix must stop growing. -/
lemma exists_orb_stable {f : ℕ → ℕ} {s m : ℕ} (hb : ∀ i, f^[i] s < m) :
    ∃ k, orb f s (k + 1) = orb f s k := by
  by_contra hcon
  push_neg at hcon
  have hgrow : ∀ k, (orb f s k).card = k + 1 := by
    intro k
    induction k with
    | zero => simp [orb_zero]
    | succ k ih => rw [orb_card_succ_of_ne (hcon k), ih]
  have hle : (orb f s m).card ≤ m := by
    simpa using Finset.card_le_card (orb_subset_range hb m)
  rw [hgrow m] at hle
  omega

/-- **The exact orbit-count law.**  For a pipeline with a finite state window there is an
orbit size `N`, at most the window size, such that the number of distinct states seen by
time `k` is exactly `min (k+1) N`. -/
theorem orb_card_eq_min {f : ℕ → ℕ} {s m : ℕ} (hb : ∀ i, f^[i] s < m) :
    ∃ N : ℕ, 0 < N ∧ N ≤ m ∧ ∀ k, (orb f s k).card = min (k + 1) N := by
  classical
  have hex := exists_orb_stable hb
  set K := Nat.find hex with hKdef
  have hKspec : orb f s (K + 1) = orb f s K := Nat.find_spec hex
  have hbefore : ∀ k ≤ K, (orb f s k).card = k + 1 := by
    intro k
    induction k with
    | zero => intro _; simp [orb_zero]
    | succ k ih =>
        intro hk
        have hklt : k < K := by omega
        have hne : orb f s (k + 1) ≠ orb f s k := Nat.find_min hex hklt
        rw [orb_card_succ_of_ne hne, ih (by omega)]
  refine ⟨K + 1, by omega, ?_, ?_⟩
  · have hle : (orb f s K).card ≤ m := by
      simpa using Finset.card_le_card (orb_subset_range hb K)
    rw [hbefore K le_rfl] at hle
    exact hle
  · intro k
    rcases le_total k K with hk | hk
    · rw [hbefore k hk, min_eq_left (by omega)]
    · rw [orb_eq_of_le hKspec hk, hbefore K le_rfl, min_eq_right (by omega)]

/-! ## The congruential pipeline is an orbit -/

/-- The seeded pipeline of cycle I is the iterate of its step map. -/
theorem run_eq_iterate (a c m : ℕ) (n s : ℕ) : run a c m n s = (step a c m)^[n] s := by
  induction n generalizing s with
  | zero => simp
  | succ n ih => rw [run_succ, ih, Function.iterate_succ_apply]

lemma states_eq_orb (a c m s k : ℕ) : states a c m s k = orb (step a c m) s k := by
  unfold states orb
  exact Finset.image_congr (fun i _ => run_eq_iterate a c m i s)

/-- **The audited state count is exactly `min (k+1) N`** for every congruential pipeline,
with `N` the size of the orbit it eventually fills.  This generalises `rot_states_card`,
where `N = m`. -/
theorem states_card_eq_min (a c m s : ℕ) (hm : 0 < m) (hs : s < m) :
    ∃ N : ℕ, 0 < N ∧ N ≤ m ∧ ∀ k, (states a c m s k).card = min (k + 1) N := by
  have hb : ∀ i, (step a c m)^[i] s < m := by
    intro i
    rw [← run_eq_iterate]
    exact run_lt a c m hm i s hs
  obtain ⟨N, hN0, hNm, hN⟩ := orb_card_eq_min hb
  exact ⟨N, hN0, hNm, fun k => by rw [states_eq_orb]; exact hN k⟩

/-! ## The deficit slope detector -/

/-- **After saturation the deficit has slope exactly `1`.** -/
theorem deficit_slope_one_of_saturated (a c m s N : ℕ)
    (hN : ∀ k, (states a c m s k).card = min (k + 1) N) (k : ℕ) (hk : N ≤ k + 1) :
    deficit a c m s (k + 1) - deficit a c m s k = 1 := by
  simp only [deficit, cap, hN, min_eq_right hk, min_eq_right (by omega : N ≤ k + 1 + 1)]
  push_cast
  ring

/-- **Before saturation the deficit has slope strictly below `1`**: the curve ramps. -/
theorem deficit_slope_lt_one_of_presaturation (a c m s N : ℕ)
    (hN : ∀ k, (states a c m s k).card = min (k + 1) N) (k : ℕ) (hk : k + 2 ≤ N) :
    deficit a c m s (k + 1) - deficit a c m s k < 1 := by
  have hlog : Real.logb 2 ((k : ℝ) + 1) < Real.logb 2 ((k : ℝ) + 1 + 1) :=
    Real.logb_lt_logb (by norm_num) (by positivity) (by linarith)
  simp only [deficit, cap, hN, min_eq_left (by omega : k + 1 ≤ N),
    min_eq_left (by omega : k + 1 + 1 ≤ N)]
  push_cast
  linarith

/-- **The detector.**  The first index at which consecutive deficits differ by exactly one
bit is the saturation index `N - 1`: the slope is `1` iff the orbit is already
exhausted at time `k`.  Hence the orbit size is recoverable from the deficit column. -/
theorem deficit_saturation_index (a c m s N : ℕ)
    (hN : ∀ k, (states a c m s k).card = min (k + 1) N) (k : ℕ) :
    (deficit a c m s (k + 1) - deficit a c m s k = 1) ↔ N ≤ k + 1 := by
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have := deficit_slope_lt_one_of_presaturation a c m s N hN k (by omega)
    rw [h] at this
    exact lt_irrefl _ this
  · exact deficit_slope_one_of_saturated a c m s N hN k

end

end SixKeystoneZeroDrift