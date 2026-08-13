import Pythagorean.FactoringBarriers.Dequant.CombSpectrum

/-!
# Barrier IV, cycle 2: counting bounds for probe algorithms, and aliasing

Two further quantitative obstructions, both provable outright.

* `Dequant.probe_query_lower_bound` — an **information-theoretic** bound: a
  deterministic extractor that reads only the `|T|` probe bits at query set `T` can
  separate at most `2^{|T|}` candidate orders.  Combined with the adversary bound of
  `Dequant.extraction_needs_query_at_least_order` (which says the *values* of the
  queries must reach `r`), the probe channel is squeezed from both sides: `Ω(log r)`
  bits, each costing a query of size `Ω(r)`.
* `Dequant.aliasing_halves_information` — the grid-mismatch obstruction: if the
  order `r` does not divide the grid size `Q`, the comb's spectrum only sees
  `gcd(r, Q)` peaks, and `gcd(r, Q) ≤ r/2`.  Sampling on a mismatched grid loses at
  least one bit of the order immediately, and for `gcd(r, Q) = 1` it loses
  everything (`Dequant.peaks_gcd_one`).
-/

namespace Dequant

open Finset

/-! ### How many candidate orders can `q` probe bits separate? -/

/-- **Probe counting bound.**  If an extractor's output depends only on the probe
answers at the finite query set `T`, and it returns the correct order for every
candidate in `C`, then `|C| ≤ 2^{|T|}`.  Identifying an order among `n` candidates
therefore needs at least `log₂ n` probe queries — and, by
`Dequant.extraction_needs_query_at_least_order`, each of them must be as large as
the order itself. -/
theorem probe_query_lower_bound {T C : Finset ℕ}
    (A : (ℕ → Bool) → ℕ)
    (hloc : ∀ f g : ℕ → Bool, (∀ t ∈ T, f t = g t) → A f = A g)
    (hcorrect : ∀ r ∈ C, A (fun t => decide (r ∣ t)) = r) :
    C.card ≤ 2 ^ T.card := by
  classical
  have hcard : Fintype.card ((↥T) → Bool) = 2 ^ T.card := by
    rw [Fintype.card_fun, Fintype.card_bool, Fintype.card_coe]
  have hinj : ∀ r ∈ C, ∀ s ∈ C,
      (fun (t : ↥T) => decide (r ∣ (t : ℕ))) = (fun (t : ↥T) => decide (s ∣ (t : ℕ))) →
      r = s := by
    intro r hr s hs hfun
    have hagree : ∀ t ∈ T, decide (r ∣ t) = decide (s ∣ t) := by
      intro t ht
      exact congrFun hfun ⟨t, ht⟩
    have := hloc _ _ hagree
    rw [hcorrect r hr, hcorrect s hs] at this
    exact this
  calc C.card
      ≤ (Finset.univ : Finset ((↥T) → Bool)).card :=
        Finset.card_le_card_of_injOn (fun r => fun (t : ↥T) => decide (r ∣ (t : ℕ)))
          (fun r _ => Finset.mem_univ _) (fun r hr s hs h => hinj r hr s hs h)
    _ = 2 ^ T.card := by rw [Finset.card_univ, hcard]

/-- Separating the `n` candidate orders `1, …, n` needs at least `log₂ n` probe
queries. -/
theorem probe_query_log_lower_bound {T : Finset ℕ} {n : ℕ}
    (A : (ℕ → Bool) → ℕ)
    (hloc : ∀ f g : ℕ → Bool, (∀ t ∈ T, f t = g t) → A f = A g)
    (hcorrect : ∀ r ∈ Finset.Icc 1 n, A (fun t => decide (r ∣ t)) = r) :
    Nat.log 2 n ≤ T.card := by
  have hle : n ≤ 2 ^ T.card := by
    have := probe_query_lower_bound (T := T) (C := Finset.Icc 1 n) A hloc hcorrect
    simpa [Nat.card_Icc] using this
  calc Nat.log 2 n ≤ Nat.log 2 (2 ^ T.card) := Nat.log_mono_right hle
  _ = T.card := Nat.log_pow (by norm_num) _

/-! ### Aliasing: a mismatched grid sees only `gcd(r, Q)` -/

/-- On a grid of size `Q` the visible peak structure is that of `gcd(r, Q)`:
there are exactly `gcd(r, Q)` informative frequencies. -/
theorem card_peaks_gcd {Q r : ℕ} (hQ : 0 < Q) (hr : 0 < r) :
    (peaks Q (Nat.gcd r Q)).card = Nat.gcd r Q :=
  card_peaks (Nat.gcd_pos_of_pos_left Q hr) hQ (Nat.gcd_dvd_right r Q)

/-- **Aliasing costs at least one bit.**  If the order does not divide the grid
size, the number of visible peaks `gcd(r, Q)` is at most `r/2`. -/
theorem aliasing_halves_information {Q r : ℕ} (hr : 0 < r) (hnd : ¬ r ∣ Q) :
    2 * Nat.gcd r Q ≤ r := by
  set d := Nat.gcd r Q with hd
  obtain ⟨c, hc⟩ : d ∣ r := Nat.gcd_dvd_left r Q
  have hdpos : 0 < d := Nat.gcd_pos_of_pos_left Q hr
  have hc0 : c ≠ 0 := by
    intro h
    rw [h, mul_zero] at hc
    omega
  have hc1 : c ≠ 1 := by
    intro h
    rw [h, mul_one] at hc
    exact hnd (hc ▸ Nat.gcd_dvd_right r Q)
  have hc2 : 2 ≤ c := by omega
  calc 2 * d ≤ c * d := Nat.mul_le_mul_right d hc2
  _ = r := by rw [hc]; ring

/-- The extreme case: a grid size coprime to the order shows a single peak at the
trivial frequency `0` — the sample carries no information about `r` at all. -/
theorem peaks_gcd_one {Q r : ℕ} (hQ : 0 < Q) (hco : Nat.gcd r Q = 1) :
    peaks Q (Nat.gcd r Q) = {0} := by
  rw [hco]
  ext y
  rw [mem_peaks]
  simp only [Nat.div_one, Finset.mem_singleton]
  constructor
  · rintro ⟨hy, hdvd⟩
    rcases Nat.eq_zero_or_pos y with h | h
    · exact h
    · exact absurd (Nat.le_of_dvd h hdvd) (by omega)
  · rintro rfl
    exact ⟨hQ, dvd_zero _⟩

end Dequant