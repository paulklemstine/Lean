/-
# A one–parameter winnability criterion on complete graphs

On the complete graph `K_n` the Laplacian collapses to the very simple operator
`f ↦ n • f - (∑ f) • 1`.  Consequently a chip-firing move is a *single* integer
vector rather than a sequence of set firings, and the question "is `D` linearly
equivalent to an effective divisor?" collapses to a one-parameter integer
optimisation.

Main results of this file.

* `lap_top` — the Laplacian of `K_n` is `f ↦ n f - ∑ f`.
* `winnable_top_iff` — **the engine**: `D` is winnable on `K_n` iff there is a shift
  `S : ℤ` with `S ≤ ∑ v, ⌊(D v + S) / n⌋`.
* `winnable_top_of_shift`, `not_winnable_top_of_window` — the two usable directions,
  the second one only requiring a check over the *window* `S ∈ (-n, 0]`, by the
  periodicity `sum_ediv_add_period`.
* `sum_window_ediv_ge` — the arithmetic kernel used throughout:
  `-e ≤ ∑_{i < M} ⌊(i - e)/n⌋` whenever `0 ≤ e` and `M ≤ n`.

Everything is stated with Lean's integer division `/` on `ℤ`, which is floor
division for a positive divisor.
-/
import Combinatorics.TropicalRiemannRoch.CompleteGraph

namespace TropicalRR

open Finset

section Window

/-! ### The arithmetic kernel

A single-variable statement about floor division which is where all the
combinatorial content of the rank computations is concentrated. -/

/-- Floor division by `n` of `i - e` for `i` in a window of length at most `n`.
If `0 ≤ e` and the window `range M` has `M ≤ n`, the total is at least `-e`. -/
lemma sum_window_ediv_ge {n : ℤ} (hn : 0 < n) {M : ℕ} (hM : (M : ℤ) ≤ n)
    {e : ℤ} (he : 0 ≤ e) :
    -e ≤ ∑ i ∈ Finset.range M, ((i : ℤ) - e) / n := by
  obtain ⟨q, r, hq, hr0, hrn, rfl⟩ :
      ∃ q r : ℤ, 0 ≤ q ∧ 0 ≤ r ∧ r < n ∧ e = q * n + r := by
    refine ⟨e / n, e % n, Int.ediv_nonneg he (le_of_lt hn), Int.emod_nonneg _ (by omega),
      Int.emod_lt_of_pos _ hn, ?_⟩
    have hd : n * (e / n) + e % n = e := Int.mul_ediv_add_emod e n
    have hcm : (e / n) * n = n * (e / n) := mul_comm _ _
    linarith
  have key : ∀ i ∈ Finset.range M,
      ((i : ℤ) - (q * n + r)) / n = ((i : ℤ) - r) / n - q := by
    intro i _
    have : ((i : ℤ) - (q * n + r)) = ((i : ℤ) - r) + (-q) * n := by ring
    rw [this, Int.add_mul_ediv_right _ _ (by omega)]
    ring
  rw [Finset.sum_congr rfl key, Finset.sum_sub_distrib, Finset.sum_const, card_range,
    nsmul_eq_mul]
  -- each `((i:ℤ) - r)/n` is `0` or `-1`, and it is `-1` for at most `min M r` values
  have hterm : ∀ i ∈ Finset.range M, (-1 : ℤ) ≤ ((i : ℤ) - r) / n := by
    intro i hi
    rw [Finset.mem_range] at hi
    have hi' : (i : ℤ) < n := lt_of_lt_of_le (by exact_mod_cast hi) hM
    have h1 : -n ≤ (i : ℤ) - r := by omega
    have := Int.ediv_le_ediv hn h1
    calc (-1 : ℤ) = (-n) / n := by
            rw [show (-n) = (-1) * n by ring, Int.mul_ediv_cancel _ (by omega : n ≠ 0)]
      _ ≤ ((i : ℤ) - r) / n := this
  have hzero : ∀ i ∈ Finset.range M, (r : ℤ) ≤ (i : ℤ) → ((i : ℤ) - r) / n = 0 := by
    intro i hi hri
    rw [Finset.mem_range] at hi
    have hi' : (i : ℤ) < n := lt_of_lt_of_le (by exact_mod_cast hi) hM
    exact Int.ediv_eq_zero_of_lt (by omega) (by omega)
  -- split the window at `r`
  have hsplit :
      ∑ i ∈ Finset.range M, ((i : ℤ) - r) / n
        ≥ -(min (M : ℤ) r) := by
    have hbound : ∀ i ∈ Finset.range M,
        (if ((i : ℤ) < r) then (-1 : ℤ) else 0) ≤ ((i : ℤ) - r) / n := by
      intro i hi
      by_cases h : (i : ℤ) < r
      · simpa [h] using hterm i hi
      · simp only [h, if_false]
        exact le_of_eq (hzero i hi (by omega)).symm
    have := Finset.sum_le_sum hbound
    refine le_trans ?_ this
    have hcount : ∑ i ∈ Finset.range M, (if ((i : ℤ) < r) then (-1 : ℤ) else 0)
        = -((Finset.range M).filter (fun i : ℕ => ((i : ℤ) < r))).card := by
      rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
      simp
    rw [hcount, neg_le_neg_iff]
    have : ((Finset.range M).filter (fun i : ℕ => ((i : ℤ) < r))).card ≤ min M r.toNat := by
      refine Nat.le_min.2 ⟨(Finset.card_filter_le _ _).trans (by simp), ?_⟩
      have hsub : (Finset.range M).filter (fun i : ℕ => ((i : ℤ) < r))
          ⊆ Finset.range r.toNat := by
        intro i hi
        simp only [Finset.mem_filter, Finset.mem_range] at hi ⊢
        omega
      exact (Finset.card_le_card hsub).trans (by simp)
    have h2 : ((min M r.toNat : ℕ) : ℤ) ≤ min (M : ℤ) r := by
      rw [le_min_iff]
      constructor
      · exact_mod_cast Nat.cast_le.2 (min_le_left _ _)
      · have : (min M r.toNat : ℕ) ≤ r.toNat := min_le_right _ _
        omega
    exact le_trans (by exact_mod_cast Nat.cast_le.2 this) h2
  have hmin1 : min (M : ℤ) r ≤ (M : ℤ) := min_le_left _ _
  have hmin2 : min (M : ℤ) r ≤ r := min_le_right _ _
  nlinarith [hq, hM, hmin1, hmin2]

end Window

section CompleteGraph

variable {V : Type*} [Fintype V] [DecidableEq V] [Nonempty V]

local notation "N" => (Fintype.card V : ℤ)

omit [DecidableEq V] in
lemma card_pos_int : 0 < N := by exact_mod_cast Fintype.card_pos (α := V)

omit [Nonempty V] in
/-- **The Laplacian of the complete graph.**  Firing according to `f` moves
`n f v - ∑ f` chips away from `v`. -/
theorem lap_top (f : V → ℤ) (v : V) :
    lap (⊤ : SimpleGraph V) f v = N * f v - ∑ w, f w := by
  have hnb : (⊤ : SimpleGraph V).neighborFinset v = (univ : Finset V).erase v := by
    ext w
    simp [SimpleGraph.mem_neighborFinset, Finset.mem_erase, ne_comm]
  rw [lap, hnb]
  have h0 : ∑ w ∈ (univ : Finset V).erase v, (f v - f w) = ∑ w : V, (f v - f w) :=
    Finset.sum_erase _ (by simp)
  rw [h0, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-- **The winnability criterion on `K_n`.**  A divisor is linearly equivalent to an
effective divisor exactly when some integer shift `S` satisfies
`S ≤ ∑_v ⌊(D v + S)/n⌋`. -/
theorem winnable_top_iff (D : Divisor V) :
    Winnable (⊤ : SimpleGraph V) D ↔ ∃ S : ℤ, S ≤ ∑ v, (D v + S) / N := by
  have hN : 0 < N := card_pos_int (V := V)
  constructor
  · rintro ⟨D', ⟨f, hf⟩, hEff⟩
    refine ⟨∑ w, f w, ?_⟩
    refine Finset.sum_le_sum fun v _ => ?_
    have h := hEff v
    rw [hf] at h
    simp only [Pi.sub_apply, lap_top] at h
    rw [Int.le_ediv_iff_mul_le hN]
    linarith
  · rintro ⟨S, hS⟩
    obtain ⟨v₀⟩ := ‹Nonempty V›
    set b : V → ℤ := fun v => (D v + S) / N with hb
    set c : ℤ := (∑ v, b v) - S with hc
    have hc0 : 0 ≤ c := by simp only [hc, sub_nonneg]; exact hS
    set f : V → ℤ := Function.update b v₀ (b v₀ - c) with hf
    have hsum : ∑ v, f v = S := by
      rw [hf, Finset.sum_update_of_mem (Finset.mem_univ v₀)]
      have : ∑ x ∈ (univ : Finset V) \ {v₀}, b x = (∑ v, b v) - b v₀ := by
        rw [Finset.sum_sdiff_eq_sub (by simp : ({v₀} : Finset V) ⊆ univ)]
        simp
      rw [this]
      simp only [hc]
      ring
    have hle : ∀ v, N * f v ≤ D v + S := by
      intro v
      have hbv : N * b v ≤ D v + S := by
        have : b v * N ≤ D v + S := (Int.le_ediv_iff_mul_le hN).1 (le_refl (b v))
        linarith
      by_cases h : v = v₀
      · subst h
        have : f v = b v - c := by rw [hf]; simp
        rw [this]
        nlinarith
      · have : f v = b v := by rw [hf]; simp [h]
        rw [this]; exact hbv
    refine ⟨fun v => D v - lap (⊤ : SimpleGraph V) f v, ⟨f, rfl⟩, fun v => ?_⟩
    show (0 : ℤ) ≤ D v - lap (⊤ : SimpleGraph V) f v
    rw [lap_top, hsum]
    have := hle v
    linarith

/-- Sufficient form of the criterion. -/
theorem winnable_top_of_shift (D : Divisor V) (S : ℤ) (h : S ≤ ∑ v, (D v + S) / N) :
    Winnable (⊤ : SimpleGraph V) D :=
  (winnable_top_iff D).2 ⟨S, h⟩

omit [DecidableEq V] in
/-- The functional `S ↦ ∑_v ⌊(D v + S)/n⌋ - S` is invariant under `S ↦ S + n`. -/
lemma sum_ediv_add_period (D : Divisor V) (S q : ℤ) :
    ∑ v, (D v + (S + N * q)) / N = (∑ v, (D v + S) / N) + N * q := by
  have hN : (N : ℤ) ≠ 0 := ne_of_gt (card_pos_int (V := V))
  have : ∀ v : V, (D v + (S + N * q)) / N = (D v + S) / N + q := by
    intro v
    have h : D v + (S + N * q) = (D v + S) + q * N := by ring
    rw [h, Int.add_mul_ediv_right _ _ hN]
  rw [Finset.sum_congr rfl (fun v _ => this v), Finset.sum_add_distrib, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul]

/-- **Non-winnability only has to be checked on a window of length `n`.**
If for every `u` with `0 ≤ u < n` the shifted sum `∑_v ⌊(D v - u)/n⌋` is `< -u`,
then `D` is not winnable. -/
theorem not_winnable_top_of_window (D : Divisor V)
    (h : ∀ u : ℤ, 0 ≤ u → u < N → ∑ v, (D v - u) / N < -u) :
    ¬ Winnable (⊤ : SimpleGraph V) D := by
  have hN : 0 < N := card_pos_int (V := V)
  intro hw
  obtain ⟨S, hS⟩ := (winnable_top_iff D).1 hw
  obtain ⟨k, r, hr0, hrn, hSq⟩ : ∃ k r : ℤ, 0 ≤ r ∧ r < N ∧ S = -r + N * k := by
    refine ⟨-((-S) / N), (-S) % N, Int.emod_nonneg _ (by omega),
      Int.emod_lt_of_pos _ hN, ?_⟩
    have hd : N * ((-S) / N) + (-S) % N = -S := Int.mul_ediv_add_emod (-S) N
    have h2 : N * (-((-S) / N)) = -(N * ((-S) / N)) := by ring
    linarith
  have hkey := sum_ediv_add_period D (-r) k
  rw [← hSq] at hkey
  simp only [← sub_eq_add_neg] at hkey
  have hstrict := h r hr0 hrn
  linarith

end CompleteGraph

end TropicalRR