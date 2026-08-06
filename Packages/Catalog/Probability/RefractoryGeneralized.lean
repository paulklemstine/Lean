/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Temporal codes with an `r`-bin refractory period

`RefractorySpikeTrains.lean` (in this directory) treats the case of an absolute refractory period of
one time bin: no two spikes in *adjacent* bins, giving the Fibonacci capacity
`fib (T + 2)`.  Real neurons have a refractory period spanning several bins.
This file develops the general case: a spike must be followed by at least `r`
silent bins (a spike in one of the last `r` bins of the window is allowed, the
window simply ends).

## Results

1. `okB` — the admissibility predicate for an `r`-bin refractory period, and
   `trainsR`, an explicit finset of admissible spike trains defined by the
   refractory recursion.
2. `mem_trainsR_iff` — the recursion is correct: `trainsR r n` is *exactly* the
   set of length-`n` binary words in which every spike is followed by `r`
   silent bins (or by the end of the window).
3. `card_trainsR_succ`, `card_trainsR_recursion` — the capacity recursion
   `c_r(n + r + 1) = c_r(n + r) + c_r(n)`, whose characteristic equation is
   `x ^ (r + 1) = x ^ r + 1`.
4. `card_trainsR_one` — for `r = 1` the capacity is `fib (n + 2)`, recovering
   the theorem of `RefractorySpikeTrains.lean` from the general recursion.
5. `card_trainsR_two_succ3` — for `r = 2` the capacity obeys
   `c(n + 3) = c(n + 2) + c(n)` (Narayana's cows, OEIS A000930).
6. `trainsR_antitone`, `card_trainsR_antitone` — a longer refractory period can
   only lose capacity.
7. `card_trainsR_le_pow`, `temporal_rate_le_general` — a general rate bound:
   over a window of `(r + 1) * m` bins the capacity is at most `(2 ^ r + 1) ^ m`.
8. `card_trainsR_two_le_pow`, `temporal_rate_two_le` — the sharper `r = 2` bound
   `c(3m) ≤ 4 ^ m`, i.e. at most `2/3` of a bit per time bin (against `4/5` for
   `r = 1` and `1` for the unconstrained channel): refractoriness strictly
   decreases the information rate.
9. `card_trainsR_ge` — a matching lower bound `n + 1 ≤ c_r(n)`, so the capacity
   is never trivial.
-/

namespace Catalog.Probability.NeuralCoding.Temporal

open Finset

/-- Admissibility of a spike train under an `r`-bin refractory period: after each
spike the next `r` bins (or all remaining bins, if fewer) must be silent. -/
def okB (r : ℕ) : List Bool → Bool
  | [] => true
  | (false :: l) => okB r l
  | (true :: l) => (l.take r).all (fun b => !b) && okB r l

@[simp] theorem okB_nil (r : ℕ) : okB r [] = true := rfl

@[simp] theorem okB_false_cons (r : ℕ) (l : List Bool) :
    okB r (false :: l) = okB r l := rfl

theorem okB_true_cons (r : ℕ) (l : List Bool) :
    okB r (true :: l) = ((l.take r).all (fun b => !b) && okB r l) := rfl

/-- Prefixing silent bins does not affect admissibility. -/
theorem okB_replicate_false_append (r k : ℕ) (l : List Bool) :
    okB r (List.replicate k false ++ l) = okB r l := by
  induction k with
  | zero => simp
  | succ k ih => simpa [List.replicate_succ] using ih

@[simp] theorem okB_replicate_false (r k : ℕ) : okB r (List.replicate k false) = true := by
  have := okB_replicate_false_append r k []
  simpa using this

/-- The admissible spike trains of a neuron with an `r`-bin refractory period in a
window of `n` bins.  A train either starts with a silent bin, or starts with a
spike, which must be followed by `r` silent bins (unless the window ends first). -/
def trainsR (r : ℕ) : ℕ → Finset (List Bool)
  | 0 => {[]}
  | (n + 1) =>
      (trainsR r n).image (fun l => false :: l) ∪
        (if r ≤ n then
            (trainsR r (n - r)).image (fun l => true :: (List.replicate r false ++ l))
          else {true :: List.replicate n false})

theorem trainsR_zero (r : ℕ) : trainsR r 0 = {[]} := by rw [trainsR]

theorem trainsR_succ (r n : ℕ) :
    trainsR r (n + 1) =
      (trainsR r n).image (fun l => false :: l) ∪
        (if r ≤ n then
            (trainsR r (n - r)).image (fun l => true :: (List.replicate r false ++ l))
          else {true :: List.replicate n false}) := by rw [trainsR]

/-- **The recursion is the right one.**  `trainsR r n` consists exactly of the
binary words of length `n` that are admissible for an `r`-bin refractory period. -/
theorem mem_trainsR_iff (r : ℕ) : ∀ (n : ℕ) (l : List Bool),
    l ∈ trainsR r n ↔ l.length = n ∧ okB r l = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 =>
        intro l
        constructor
        · intro h
          rw [trainsR_zero, Finset.mem_singleton] at h
          subst h; simp
        · rintro ⟨hlen, -⟩
          have : l = [] := List.eq_nil_of_length_eq_zero hlen
          simp [trainsR_zero, this]
    | (n + 1) =>
        intro l
        rw [trainsR_succ]
        constructor
        · intro h
          simp only [Finset.mem_union, Finset.mem_image] at h
          rcases h with ⟨m, hm, rfl⟩ | h
          · obtain ⟨hlen, hok⟩ := (ih n (by omega) m).mp hm
            exact ⟨by simp [hlen], by simpa using hok⟩
          · by_cases hr : r ≤ n
            · rw [if_pos hr] at h
              simp only [Finset.mem_image] at h
              obtain ⟨m, hm, rfl⟩ := h
              obtain ⟨hlen, hok⟩ := (ih (n - r) (by omega) m).mp hm
              refine ⟨by simp [hlen]; omega, ?_⟩
              rw [okB_true_cons]
              have htake : (List.replicate r false ++ m).take r = List.replicate r false := by
                simp
              rw [htake, okB_replicate_false_append]
              simp [hok]
            · rw [if_neg hr, Finset.mem_singleton] at h
              subst h
              refine ⟨by simp, ?_⟩
              rw [okB_true_cons]
              simp
        · rintro ⟨hlen, hok⟩
          match l with
          | [] => simp at hlen
          | (false :: m) =>
              refine Finset.mem_union_left _ ?_
              simp only [Finset.mem_image]
              refine ⟨m, (ih n (by omega) m).mpr ⟨by simpa using hlen, by simpa using hok⟩, rfl⟩
          | (true :: m) =>
              have hmlen : m.length = n := by simpa using hlen
              rw [okB_true_cons, Bool.and_eq_true] at hok
              obtain ⟨htake, hokm⟩ := hok
              refine Finset.mem_union_right _ ?_
              have htake' : m.take r = List.replicate (min r n) false := by
                rw [List.eq_replicate_iff]
                constructor
                · simp [hmlen]
                · intro b hb
                  have := List.all_eq_true.mp htake b hb
                  simpa using this
              by_cases hr : r ≤ n
              · rw [if_pos hr]
                simp only [Finset.mem_image]
                refine ⟨m.drop r, ?_, ?_⟩
                · refine (ih (n - r) (by omega) (m.drop r)).mpr ⟨by simp [hmlen], ?_⟩
                  have : okB r m = okB r (m.take r ++ m.drop r) := by
                    rw [List.take_append_drop]
                  rw [this, htake', min_eq_left hr, okB_replicate_false_append] at hokm
                  exact hokm
                · have : List.replicate r false ++ m.drop r = m := by
                    conv_rhs => rw [← List.take_append_drop r m]
                    rw [htake', min_eq_left hr]
                  rw [this]
              · rw [if_neg hr, Finset.mem_singleton]
                have hm : m = List.replicate n false := by
                  have hmt : m.take r = m := List.take_of_length_le (by omega)
                  rw [hmt, min_eq_right (by omega)] at htake'
                  exact htake'
                rw [hm]

/-- Head-based disjointness of the two branches of the refractory recursion. -/
theorem trainsR_disjoint (r n : ℕ) :
    Disjoint ((trainsR r n).image (fun l => false :: l))
      (if r ≤ n then
          (trainsR r (n - r)).image (fun l => true :: (List.replicate r false ++ l))
        else ({true :: List.replicate n false} : Finset (List Bool))) := by
  rw [Finset.disjoint_left]
  intro x hx hy
  simp only [Finset.mem_image] at hx
  obtain ⟨a, -, rfl⟩ := hx
  by_cases hr : r ≤ n
  · rw [if_pos hr] at hy
    simp only [Finset.mem_image] at hy
    obtain ⟨b, -, hb⟩ := hy
    simp at hb
  · rw [if_neg hr, Finset.mem_singleton] at hy
    simp at hy

/-- **Capacity recursion.**  The number of admissible trains in `n + 1` bins is the
number in `n` bins (silent first bin) plus the number in `n - r` bins (a spike
followed by `r` forced silent bins), the second term degenerating to `1` when the
window is shorter than the refractory period. -/
theorem card_trainsR_succ (r n : ℕ) :
    (trainsR r (n + 1)).card =
      (trainsR r n).card + (if r ≤ n then (trainsR r (n - r)).card else 1) := by
  rw [trainsR_succ, Finset.card_union_of_disjoint (trainsR_disjoint r n),
    Finset.card_image_of_injective _ (fun a b h => by simpa using h)]
  by_cases hr : r ≤ n
  · rw [if_pos hr, if_pos hr,
      Finset.card_image_of_injective _ (fun a b h => by simpa using h)]
  · rw [if_neg hr, if_neg hr, Finset.card_singleton]

/-- For windows shorter than the refractory period, only the silent train and the
`n` single-spike trains are admissible. -/
theorem card_trainsR_small (r : ℕ) : ∀ n : ℕ, n ≤ r → (trainsR r n).card = n + 1 := by
  intro n
  induction n with
  | zero => simp [trainsR_zero]
  | succ n ih =>
      intro hn
      have hr : ¬ r ≤ n := by omega
      rw [card_trainsR_succ, if_neg hr, ih (by omega)]

/-- The clean form of the capacity recursion once the window exceeds the refractory
period: `c_r(n + r + 1) = c_r(n + r) + c_r(n)`, with characteristic equation
`x ^ (r + 1) = x ^ r + 1`. -/
theorem card_trainsR_recursion (r n : ℕ) :
    (trainsR r (n + r + 1)).card = (trainsR r (n + r)).card + (trainsR r n).card := by
  have h := card_trainsR_succ r (n + r)
  rw [if_pos (by omega : r ≤ n + r)] at h
  simpa using h

/-- **Refractory period `1` recovers the Fibonacci capacity** of
`RefractorySpikeTrains.card_trains`. -/
theorem card_trainsR_one : ∀ n : ℕ, (trainsR 1 n).card = Nat.fib (n + 2) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp [trainsR_zero]
    | 1 => rw [card_trainsR_small 1 1 (le_refl 1)]; rfl
    | (m + 2) =>
        have h := card_trainsR_recursion 1 m
        rw [show m + 1 + 1 = m + 2 from by omega] at h
        have h1 : (trainsR 1 (m + 1)).card = Nat.fib (m + 3) := by
          have := ih (m + 1) (by omega)
          rwa [show m + 1 + 2 = m + 3 from by omega] at this
        have h2 : (trainsR 1 m).card = Nat.fib (m + 2) := ih m (by omega)
        have hf : Nat.fib (m + 4) = Nat.fib (m + 2) + Nat.fib (m + 3) := Nat.fib_add_two
        rw [show m + 2 + 2 = m + 4 from by omega, h, h1, h2]
        omega

/-- **Refractory period `2`: Narayana's cows recursion** `c(n + 3) = c(n + 2) + c(n)`
(OEIS A000930), the `r = 2` instance of the general capacity recursion. -/
theorem card_trainsR_two_succ3 (n : ℕ) :
    (trainsR 2 (n + 3)).card = (trainsR 2 (n + 2)).card + (trainsR 2 n).card :=
  card_trainsR_recursion 2 n

/-- Capacity is monotone in the window length. -/
theorem card_trainsR_mono (r : ℕ) : ∀ n : ℕ, (trainsR r n).card ≤ (trainsR r (n + 1)).card := by
  intro n
  rw [card_trainsR_succ]
  omega

theorem card_trainsR_mono' (r : ℕ) {m n : ℕ} (h : m ≤ n) :
    (trainsR r m).card ≤ (trainsR r n).card := by
  induction n with
  | zero => simp_all
  | succ n ih =>
      rcases Nat.lt_or_ge m (n + 1) with hlt | hge
      · exact le_trans (ih (by omega)) (card_trainsR_mono r n)
      · have : m = n + 1 := by omega
        subst this; exact le_rfl

/-- A one-bin extension of the window at most doubles the capacity. -/
theorem card_trainsR_succ_le (r n : ℕ) :
    (trainsR r (n + 1)).card ≤ 2 * (trainsR r n).card := by
  rw [card_trainsR_succ]
  by_cases hr : r ≤ n
  · rw [if_pos hr]
    have := card_trainsR_mono' r (show n - r ≤ n by omega)
    omega
  · rw [if_neg hr]
    have : 1 ≤ (trainsR r n).card := by
      have := card_trainsR_small r n (by omega)
      omega
    omega

theorem card_trainsR_add_le (r : ℕ) : ∀ (k n : ℕ),
    (trainsR r (n + k)).card ≤ 2 ^ k * (trainsR r n).card := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
      intro n
      calc (trainsR r (n + (k + 1))).card
          = (trainsR r ((n + k) + 1)).card := by ring_nf
        _ ≤ 2 * (trainsR r (n + k)).card := card_trainsR_succ_le r (n + k)
        _ ≤ 2 * (2 ^ k * (trainsR r n).card) := by
            exact Nat.mul_le_mul_left _ (ih n)
        _ = 2 ^ (k + 1) * (trainsR r n).card := by ring

/-- **Block bound.**  Over `r + 1` extra bins the capacity grows by a factor of at
most `2 ^ r + 1`. -/
theorem card_trainsR_block (r n : ℕ) :
    (trainsR r (n + (r + 1))).card ≤ (2 ^ r + 1) * (trainsR r n).card := by
  have h : (trainsR r (n + r + 1)).card = (trainsR r (n + r)).card + (trainsR r n).card :=
    card_trainsR_recursion r n
  have h2 : (trainsR r (n + r)).card ≤ 2 ^ r * (trainsR r n).card :=
    card_trainsR_add_le r r n
  have e : n + (r + 1) = n + r + 1 := by ring
  rw [e, h]
  calc (trainsR r (n + r)).card + (trainsR r n).card
      ≤ 2 ^ r * (trainsR r n).card + (trainsR r n).card := by omega
    _ = (2 ^ r + 1) * (trainsR r n).card := by ring

/-- **General rate bound.**  In a window of `(r + 1) * m` bins a neuron with an
`r`-bin refractory period has at most `(2 ^ r + 1) ^ m` distinguishable spike
trains. -/
theorem card_trainsR_le_pow (r : ℕ) : ∀ m : ℕ,
    (trainsR r ((r + 1) * m)).card ≤ (2 ^ r + 1) ^ m := by
  intro m
  induction m with
  | zero => simp [trainsR_zero]
  | succ m ih =>
      have e : (r + 1) * (m + 1) = (r + 1) * m + (r + 1) := by ring
      rw [e]
      calc (trainsR r ((r + 1) * m + (r + 1))).card
          ≤ (2 ^ r + 1) * (trainsR r ((r + 1) * m)).card := card_trainsR_block r _
        _ ≤ (2 ^ r + 1) * (2 ^ r + 1) ^ m := Nat.mul_le_mul_left _ ih
        _ = (2 ^ r + 1) ^ (m + 1) := by ring

theorem card_trainsR_two_zero : (trainsR 2 0).card = 1 := card_trainsR_small 2 0 (by omega)

theorem card_trainsR_two_one : (trainsR 2 1).card = 2 := card_trainsR_small 2 1 (by omega)

theorem card_trainsR_two_two : (trainsR 2 2).card = 3 := card_trainsR_small 2 2 (by omega)

theorem card_trainsR_two_three : (trainsR 2 3).card = 4 := by
  have := card_trainsR_two_succ3 0
  rw [card_trainsR_two_zero, card_trainsR_two_two] at this
  simpa using this

theorem card_trainsR_two_four : (trainsR 2 4).card = 6 := by
  have := card_trainsR_two_succ3 1
  rw [card_trainsR_two_one, card_trainsR_two_three] at this
  simpa using this

theorem card_trainsR_two_five : (trainsR 2 5).card = 9 := by
  have := card_trainsR_two_succ3 2
  rw [card_trainsR_two_two, card_trainsR_two_four] at this
  simpa using this

/-- **Sharper bound for a two-bin refractory period:** three extra bins multiply the
capacity by at most `4`. -/
theorem card_trainsR_two_step : ∀ n : ℕ, (trainsR 2 (n + 3)).card ≤ 4 * (trainsR 2 n).card := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => rw [card_trainsR_two_zero, card_trainsR_two_three]
    | 1 => rw [card_trainsR_two_one, card_trainsR_two_four]; omega
    | 2 => rw [card_trainsR_two_two, card_trainsR_two_five]; omega
    | (m + 3) =>
        have h1 : (trainsR 2 (m + 2 + 3)).card ≤ 4 * (trainsR 2 (m + 2)).card :=
          ih (m + 2) (by omega)
        have h2 : (trainsR 2 (m + 3)).card ≤ 4 * (trainsR 2 m).card := ih m (by omega)
        have hrec : (trainsR 2 (m + 3 + 3)).card
            = (trainsR 2 (m + 3 + 2)).card + (trainsR 2 (m + 3)).card :=
          card_trainsR_two_succ3 (m + 3)
        have hrec2 : (trainsR 2 (m + 3)).card
            = (trainsR 2 (m + 2)).card + (trainsR 2 m).card := card_trainsR_two_succ3 m
        have e : m + 2 + 3 = m + 3 + 2 := by ring
        rw [e] at h1
        omega

/-- **Two-bin refractory rate bound.**  In a window of `3m` bins a neuron with a
two-bin refractory period has at most `4 ^ m` spike trains: at most `2/3` of a bit
per time bin, strictly below the `4/5` available at `r = 1`. -/
theorem card_trainsR_two_le_pow : ∀ m : ℕ, (trainsR 2 (3 * m)).card ≤ 4 ^ m := by
  intro m
  induction m with
  | zero => simp [trainsR_zero]
  | succ m ih =>
      have e : 3 * (m + 1) = 3 * m + 3 := by ring
      rw [e]
      calc (trainsR 2 (3 * m + 3)).card ≤ 4 * (trainsR 2 (3 * m)).card :=
            card_trainsR_two_step (3 * m)
        _ ≤ 4 * 4 ^ m := Nat.mul_le_mul_left _ ih
        _ = 4 ^ (m + 1) := by ring

/-- A longer refractory period is a stronger constraint. -/
theorem okB_antitone {r s : ℕ} (h : r ≤ s) : ∀ l : List Bool, okB s l = true → okB r l = true := by
  intro l
  induction l with
  | nil => simp
  | cons a t ih =>
      cases a with
      | false => simpa using ih
      | true =>
          rw [okB_true_cons, okB_true_cons, Bool.and_eq_true, Bool.and_eq_true]
          rintro ⟨hall, hok⟩
          refine ⟨?_, ih hok⟩
          rw [List.all_eq_true] at hall ⊢
          intro b hb
          refine hall b ?_
          have hbt : b ∈ (t.take s).take r := by
            rwa [List.take_take, min_eq_left h]
          exact List.mem_of_mem_take hbt

theorem trainsR_antitone {r s : ℕ} (h : r ≤ s) (n : ℕ) : trainsR s n ⊆ trainsR r n := by
  intro l hl
  obtain ⟨hlen, hok⟩ := (mem_trainsR_iff s n l).mp hl
  exact (mem_trainsR_iff r n l).mpr ⟨hlen, okB_antitone h l hok⟩

theorem card_trainsR_antitone {r s : ℕ} (h : r ≤ s) (n : ℕ) :
    (trainsR s n).card ≤ (trainsR r n).card :=
  Finset.card_le_card (trainsR_antitone h n)

/-- Every window admits at least the all-silent train. -/
theorem card_trainsR_pos (r n : ℕ) : 0 < (trainsR r n).card := by
  refine Finset.card_pos.mpr ⟨List.replicate n false, ?_⟩
  exact (mem_trainsR_iff r n _).mpr ⟨by simp, by simp⟩

/-- **Nontrivial capacity.**  Every window admits at least the silent train and the
`n` trains with a single spike. -/
theorem card_trainsR_ge (r : ℕ) : ∀ n : ℕ, n + 1 ≤ (trainsR r n).card := by
  intro n
  induction n with
  | zero => simp [trainsR_zero]
  | succ n ih =>
      rw [card_trainsR_succ]
      by_cases hr : r ≤ n
      · rw [if_pos hr]
        have := card_trainsR_pos r (n - r)
        omega
      · rw [if_neg hr]; omega

/-- **General temporal information rate.**  Over a window of `(r + 1) * m` bins the
code carries at most `m * log₂ (2 ^ r + 1)` bits. -/
theorem temporal_rate_le_general (r m : ℕ) :
    Real.logb 2 ((trainsR r ((r + 1) * m)).card) ≤ m * Real.logb 2 (2 ^ r + 1) := by
  have h := card_trainsR_le_pow r m
  have hcard : ((trainsR r ((r + 1) * m)).card : ℝ) ≤ ((2 ^ r + 1 : ℕ) : ℝ) ^ m := by
    exact_mod_cast h
  have hpos : (0 : ℝ) < ((trainsR r ((r + 1) * m)).card : ℝ) := by
    exact_mod_cast card_trainsR_pos r ((r + 1) * m)
  have hlog := Real.logb_le_logb_of_le (b := 2) (by norm_num) hpos hcard
  rw [Real.logb_pow] at hlog
  have hcast : (((2 : ℕ) ^ r + 1 : ℕ) : ℝ) = 2 ^ r + 1 := by push_cast; ring
  rw [hcast] at hlog
  simpa [mul_comm] using hlog

/-- **Two-bin refractory rate.**  A neuron with a two-bin refractory period transmits
at most `2/3` of a bit per time bin over a window of `3m` bins. -/
theorem temporal_rate_two_le (m : ℕ) :
    Real.logb 2 ((trainsR 2 (3 * m)).card) ≤ (2 / 3 : ℝ) * (3 * m) := by
  have h := card_trainsR_two_le_pow m
  have hcard : ((trainsR 2 (3 * m)).card : ℝ) ≤ (4 : ℝ) ^ m := by exact_mod_cast h
  have hpos : (0 : ℝ) < ((trainsR 2 (3 * m)).card : ℝ) := by
    exact_mod_cast card_trainsR_pos 2 (3 * m)
  have hlog := Real.logb_le_logb_of_le (b := 2) (by norm_num) hpos hcard
  have h4 : Real.logb 2 ((4 : ℝ) ^ m) = 2 * m := by
    rw [Real.logb_pow, show (4 : ℝ) = 2 ^ (2 : ℕ) by norm_num, Real.logb_pow,
      Real.logb_self_eq_one (b := (2 : ℝ)) (by norm_num)]
    ring
  rw [h4] at hlog
  calc Real.logb 2 ((trainsR 2 (3 * m)).card) ≤ 2 * (m : ℝ) := hlog
    _ = (2 / 3 : ℝ) * (3 * m) := by ring

end Catalog.Probability.NeuralCoding.Temporal