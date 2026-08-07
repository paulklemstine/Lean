import Mathlib

/-!
# Counting points by their minimal period

This file contains the abstract combinatorial engine behind the *full* Gauss congruence
for the adjacent-sum transfer matrices (the prime case was proved in
`Applications.AdjacentSumPolytopes.Necklace`).

Let `f : α → α` be a self-map of a finite type all of whose points are periodic (in our
application `f` is the rotation of a cyclic word, and `f^[N] = id`).  Two facts are
proved here:

* `AdjSum.dvd_card_minimalPeriod_eq`: the number of points of *exact* minimal period `n`
  is divisible by `n` — the orbits of such points all have exactly `n` elements;
* `AdjSum.card_eq_sum_divisors_card_minimalPeriod`: if `f^[N] = id` then the whole space
  decomposes as a sum over the divisors of `N` of the exact-period counts.

Together with Möbius inversion these give `n ∣ ∑_{d ∣ n} μ(n/d) tr(Mⁿ)`.

-- !-- Lab Notes -- !--
* **Hypothesis.** The set of points with a *fixed* minimal period `n` is a disjoint union
  of free orbits of size `n`, hence has cardinality divisible by `n`.
* **Experiment.** `s = 2`, rotation on cyclic words of length `4`: `tr(M⁴) = 26`, while
  `tr(M¹) = 2`, `tr(M²) = 6`, and the exact-period counts are `2` (period 1), `4`
  (period 2, `= 6 - 2`) and `20` (period 4, `= 26 - 6`); indeed `1 ∣ 2`, `2 ∣ 4`,
  `4 ∣ 20` and `2 + 4 + 20 = 26 = tr(M⁴)`.
* **Analysis.** The proof is by strong induction on the cardinality of an
  `f`-invariant finset of constant minimal period: one peels off a single orbit, which
  has exactly `n` elements because the iterates `f^[k] x`, `k < n`, are distinct.
  Injectivity of `f` is what makes the complement of an orbit invariant again.
* **Critique.** No hypothesis is vacuous: the statement is applied below to a nonempty
  space, and `n ∣ 0` would be the degenerate reading — the companion decomposition
  theorem shows the counts really do add up to the full cardinality.
-/

namespace AdjSum

open Function Finset

variable {α : Type*}

/-- If a positive iterate of `f` is the identity then `f` is injective. -/
theorem injective_of_iterate_id {f : α → α} {N : ℕ} (hN : 0 < N) (hfN : ∀ x, f^[N] x = x) :
    Function.Injective f := by
  intro a b hab
  have hN' : N - 1 + 1 = N := by omega
  have h : f^[N - 1] (f a) = f^[N - 1] (f b) := by rw [hab]
  rw [← Function.iterate_succ_apply, ← Function.iterate_succ_apply] at h
  simp only [Nat.succ_eq_add_one, hN'] at h
  rwa [hfN a, hfN b] at h

/-- Every point of a finite type is a periodic point of a map with `f^[N] = id`. -/
theorem mem_periodicPts_of_iterate_id {f : α → α} {N : ℕ} (hN : 0 < N)
    (hfN : ∀ x, f^[N] x = x) (x : α) : x ∈ Function.periodicPts f :=
  ⟨N, hN, hfN x⟩

/-- **Orbit peeling.**  An `f`-invariant finset all of whose points have minimal period
`n` has cardinality divisible by `n`. -/
theorem dvd_card_of_invariant [DecidableEq α] {f : α → α} (hf : Function.Injective f) {n : ℕ} (hn : 0 < n) :
    ∀ T : Finset α, (∀ x ∈ T, f x ∈ T) → (∀ x ∈ T, Function.minimalPeriod f x = n) →
      n ∣ T.card := by
  intro T
  induction T using Finset.strongInduction with
  | _ T ih =>
    intro hinv hper
    rcases T.eq_empty_or_nonempty with rfl | ⟨x, hx⟩
    · simp
    · have hxper : Function.minimalPeriod f x = n := hper x hx
      have hiter : ∀ k, f^[k] x ∈ T := by
        intro k
        induction k with
        | zero => exact hx
        | succ k ihk => rw [Function.iterate_succ_apply']; exact hinv _ ihk
      have hfix : f^[n] x = x := by
        have := Function.iterate_minimalPeriod (f := f) (x := x)
        rwa [hxper] at this
      set O : Finset α := (Finset.range n).image (fun k => f^[k] x) with hO
      have hOsub : O ⊆ T := by
        intro y hy
        rw [hO, Finset.mem_image] at hy
        obtain ⟨k, _, rfl⟩ := hy
        exact hiter k
      have hOcard : O.card = n := by
        rw [hO, Finset.card_image_of_injOn, Finset.card_range]
        intro a ha b hb hab
        refine Function.iterate_injOn_Iio_minimalPeriod (f := f) (x := x) ?_ ?_ hab
        · simp only [Set.mem_Iio, hxper]
          exact Finset.mem_range.mp ha
        · simp only [Set.mem_Iio, hxper]
          exact Finset.mem_range.mp hb
      have hOne : O.Nonempty := by
        refine ⟨x, ?_⟩
        rw [hO, Finset.mem_image]
        exact ⟨0, Finset.mem_range.mpr hn, rfl⟩
      have hss : T \ O ⊂ T := Finset.sdiff_ssubset hOsub hOne
      have hinv' : ∀ y ∈ T \ O, f y ∈ T \ O := by
        intro y hy
        rw [Finset.mem_sdiff] at hy ⊢
        refine ⟨hinv _ hy.1, ?_⟩
        intro hmem
        apply hy.2
        rw [hO, Finset.mem_image] at hmem
        obtain ⟨k, hk, hk2⟩ := hmem
        rw [Finset.mem_range] at hk
        rw [hO, Finset.mem_image]
        match k, hk2 with
        | 0, hk2 =>
            refine ⟨n - 1, Finset.mem_range.mpr (by omega), ?_⟩
            have hn1 : n - 1 + 1 = n := by omega
            have hstep : f^[n - 1 + 1] x = f (f^[n - 1] x) :=
              Function.iterate_succ_apply' f (n - 1) x
            rw [hn1, hfix] at hstep
            have : f (f^[n - 1] x) = f y := by rw [← hstep]; exact hk2
            exact hf this
        | (m + 1), hk2 =>
            refine ⟨m, Finset.mem_range.mpr (by omega), ?_⟩
            have hstep : f^[m + 1] x = f (f^[m] x) := Function.iterate_succ_apply' f m x
            have : f (f^[m] x) = f y := by rw [← hstep]; exact hk2
            exact hf this
      have hdvd := ih (T \ O) hss hinv' (fun y hy => hper y (Finset.mem_sdiff.mp hy).1)
      have hle : O.card ≤ T.card := Finset.card_le_card hOsub
      have hcard : T.card = (T \ O).card + n := by
        rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hOsub, hOcard]
        omega
      rw [hcard]
      exact Nat.dvd_add hdvd dvd_rfl

/-- **The exact-period count is divisible by the period.** -/
theorem dvd_card_minimalPeriod_eq [Fintype α] [DecidableEq α] {f : α → α} (hf : Function.Injective f)
    (hp : ∀ x : α, x ∈ Function.periodicPts f) {n : ℕ} (hn : 0 < n) :
    n ∣ (Finset.univ.filter (fun x : α => Function.minimalPeriod f x = n)).card := by
  refine dvd_card_of_invariant hf hn _ ?_ ?_
  · intro x hx
    rw [Finset.mem_filter] at hx ⊢
    exact ⟨Finset.mem_univ _, by rw [Function.minimalPeriod_apply (hp x)]; exact hx.2⟩
  · intro x hx
    exact (Finset.mem_filter.mp hx).2

/-- **Decomposition by exact period.**  If `f^[N] = id` with `N > 0`, the type splits
into the points of exact minimal period `d`, one class for each divisor `d` of `N`. -/
theorem card_eq_sum_divisors_card_minimalPeriod [Fintype α] [DecidableEq α] {f : α → α} {N : ℕ} (hN : 0 < N)
    (hfN : ∀ x, f^[N] x = x) :
    Fintype.card α
      = ∑ d ∈ N.divisors, (Finset.univ.filter
          (fun x : α => Function.minimalPeriod f x = d)).card := by
  have hmaps : Set.MapsTo (fun x : α => Function.minimalPeriod f x)
      (↑(Finset.univ : Finset α)) (↑N.divisors) := by
    intro x _
    simp only [Finset.mem_coe, Nat.mem_divisors]
    refine ⟨?_, by omega⟩
    exact Function.IsPeriodicPt.minimalPeriod_dvd (hfN x)
  have := Finset.card_eq_sum_card_fiberwise hmaps
  rw [Finset.card_univ] at this
  exact this

end AdjSum