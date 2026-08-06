/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Temporal neural codes: finite-window capacity under a refractory period

`Catalog/Novelty/NeuralCoding.lean` codes a concept by a single Boolean pattern
across neurons.  A *temporal* code instead uses the spike train of one neuron
across a window of `T` discrete time bins.  Biophysics forbids two spikes in
consecutive bins (the absolute refractory period), so the admissible spike
trains are exactly the binary words of length `T` with no two adjacent `true`s.

## Results

1. `trains` — the finset of admissible spike trains in a window of `T` bins,
   defined by the refractory recursion, and `mem_trains_iff`, which proves that
   this finset is *exactly* the set of length-`T` words with no two adjacent
   spikes.
2. `card_trains` — **finite-window capacity**: a refractory neuron has exactly
   `fib (T + 2)` distinguishable spike trains in `T` bins.
3. `card_trains_lt_two_pow` — the refractory constraint is a strict loss:
   capacity is `< 2 ^ T` for `T ≥ 2`.
4. `fib_five_step` / `card_trains_le_pow` — a quantitative rate bound:
   the capacity of a `5m`-bin window is at most `16 ^ m`, i.e. the temporal
   code carries at most `4/5` of a bit per time bin.
5. `temporal_rate_le` — the same statement in bits.
-/

namespace Catalog.Probability.NeuralCoding.Temporal

open Finset

/-- The refractory relation on consecutive bins: two spikes may not be adjacent. -/
def NoAdj (a b : Bool) : Prop := ¬(a = true ∧ b = true)

instance : DecidableRel NoAdj := fun a b => by unfold NoAdj; infer_instance

theorem isChain_tail {a : Bool} {m : List Bool} (h : List.IsChain NoAdj (a :: m)) :
    List.IsChain NoAdj m := by
  match m with
  | [] => exact List.isChain_nil
  | (b :: t) => exact (List.isChain_cons_cons.mp h).2

theorem isChain_false_cons {m : List Bool} (h : List.IsChain NoAdj m) :
    List.IsChain NoAdj (false :: m) := by
  match m with
  | [] => exact List.isChain_singleton _
  | (b :: t) => exact List.isChain_cons_cons.mpr ⟨by simp [NoAdj], h⟩

/-- The admissible spike trains of a refractory neuron in a window of `n` bins,
built by the refractory recursion: a train either starts with a silent bin
followed by any admissible train of length `n - 1`, or starts with a spike,
which must be followed by a silent bin and then any admissible train of
length `n - 2`. -/
def trains : ℕ → Finset (List Bool)
  | 0 => {[]}
  | 1 => {[false], [true]}
  | (n + 2) =>
      (trains (n + 1)).image (fun l => false :: l) ∪
        (trains n).image (fun l => true :: false :: l)

/-- **The recursion is the right one.**  `trains n` consists exactly of the
binary words of length `n` with no two adjacent spikes. -/
theorem mem_trains_iff : ∀ (n : ℕ) (l : List Bool),
    l ∈ trains n ↔ l.length = n ∧ l.IsChain NoAdj
  | 0, l => by
      constructor
      · intro h
        simp only [trains, Finset.mem_singleton] at h
        subst h
        exact ⟨rfl, List.isChain_nil⟩
      · rintro ⟨hlen, -⟩
        have hl : l = [] := List.eq_nil_of_length_eq_zero hlen
        simp [trains, hl]
  | 1, l => by
      match l with
      | [] => simp [trains]
      | [a] =>
          constructor
          · intro _; exact ⟨rfl, List.isChain_singleton a⟩
          · intro _; cases a <;> simp [trains]
      | (a :: b :: t) =>
          constructor
          · intro h; simp [trains] at h
          · rintro ⟨hlen, -⟩; simp at hlen
  | (n + 2), l => by
      constructor
      · intro h
        simp only [trains, Finset.mem_union, Finset.mem_image] at h
        rcases h with ⟨m, hm, rfl⟩ | ⟨m, hm, rfl⟩
        · have hIH := (mem_trains_iff (n + 1) m).mp hm
          exact ⟨by simp [hIH.1], isChain_false_cons hIH.2⟩
        · have hIH := (mem_trains_iff n m).mp hm
          refine ⟨by simp [hIH.1], ?_⟩
          exact List.isChain_cons_cons.mpr ⟨by simp [NoAdj], isChain_false_cons hIH.2⟩
      · rintro ⟨hlen, hch⟩
        match l with
        | [] => simp at hlen
        | [a] => simp at hlen
        | (a :: b :: t) =>
            simp only [trains, Finset.mem_union, Finset.mem_image]
            rw [List.isChain_cons_cons] at hch
            cases a with
            | false =>
                left
                exact ⟨b :: t, (mem_trains_iff (n + 1) (b :: t)).mpr
                  ⟨by simpa using hlen, hch.2⟩, rfl⟩
            | true =>
                have hb : b = false := by
                  by_contra hb
                  exact hch.1 ⟨rfl, by simpa using hb⟩
                subst hb
                right
                exact ⟨t, (mem_trains_iff n t).mpr
                  ⟨by simpa using hlen, isChain_tail hch.2⟩, rfl⟩

/-- **Finite-window capacity of a refractory neuron.**  In a window of `n` bins a
refractory neuron can produce exactly `fib (n + 2)` distinct spike trains. -/
theorem card_trains : ∀ n : ℕ, (trains n).card = Nat.fib (n + 2)
  | 0 => by simp [trains]
  | 1 => by decide
  | (n + 2) => by
      have hdisj : Disjoint ((trains (n + 1)).image (fun l => false :: l))
          ((trains n).image (fun l => true :: false :: l)) := by
        rw [Finset.disjoint_left]
        rintro x hx hy
        simp only [Finset.mem_image] at hx hy
        obtain ⟨a, -, rfl⟩ := hx
        obtain ⟨b, -, hb⟩ := hy
        simp at hb
      have h1 : ((trains (n + 1)).image (fun l => false :: l)).card = (trains (n + 1)).card :=
        Finset.card_image_of_injective _ (fun a b h => by simpa using h)
      have h2 : ((trains n).image (fun l => true :: false :: l)).card = (trains n).card :=
        Finset.card_image_of_injective _ (fun a b h => by simpa using h)
      have key : Nat.fib (n + 4) = Nat.fib (n + 2) + Nat.fib (n + 3) := Nat.fib_add_two
      rw [trains, Finset.card_union_of_disjoint hdisj, h1, h2, card_trains (n + 1),
        card_trains n]
      show Nat.fib (n + 3) + Nat.fib (n + 2) = Nat.fib (n + 4)
      omega

/-- The refractory constraint is a strict capacity loss: for windows of at least
two bins the refractory capacity is strictly below the unconstrained `2 ^ T`. -/
theorem card_trains_lt_two_pow (n : ℕ) (hn : 2 ≤ n) : (trains n).card < 2 ^ n := by
  have key : ∀ n : ℕ, Nat.fib (n + 4) < 2 ^ (n + 2) := by
    intro n
    induction n using Nat.strong_induction_on with
    | _ n ih =>
      match n with
      | 0 => decide
      | 1 => decide
      | (m + 2) =>
          have h1 : Nat.fib (m + 5) < 2 ^ (m + 3) := ih (m + 1) (by omega)
          have h2 : Nat.fib (m + 4) < 2 ^ (m + 2) := ih m (by omega)
          have hfib : Nat.fib (m + 6) = Nat.fib (m + 4) + Nat.fib (m + 5) := Nat.fib_add_two
          have hpow : (2 : ℕ) ^ (m + 4) = 2 ^ (m + 3) * 2 := pow_succ 2 (m + 3)
          have hpow2 : (2 : ℕ) ^ (m + 3) = 2 ^ (m + 2) * 2 := pow_succ 2 (m + 2)
          have hposn : 0 < (2 : ℕ) ^ (m + 2) := Nat.two_pow_pos _
          show Nat.fib (m + 6) < 2 ^ (m + 4)
          omega
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
  rw [card_trains]
  exact key m

/-- Five refractory steps multiply the capacity by at most `16`. -/
theorem fib_five_step (n : ℕ) : Nat.fib (n + 7) ≤ 16 * Nat.fib (n + 2) := by
  have h2 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
  have h3 : Nat.fib (n + 3) = Nat.fib (n + 1) + Nat.fib (n + 2) := Nat.fib_add_two
  have h4 : Nat.fib (n + 4) = Nat.fib (n + 2) + Nat.fib (n + 3) := Nat.fib_add_two
  have h5 : Nat.fib (n + 5) = Nat.fib (n + 3) + Nat.fib (n + 4) := Nat.fib_add_two
  have h6 : Nat.fib (n + 6) = Nat.fib (n + 4) + Nat.fib (n + 5) := Nat.fib_add_two
  have h7 : Nat.fib (n + 7) = Nat.fib (n + 5) + Nat.fib (n + 6) := Nat.fib_add_two
  omega

/-- **Rate bound.**  The capacity of a `5m`-bin refractory window is at most
`16 ^ m`: the temporal code carries at most `4/5` of a bit per time bin,
strictly less than the `1` bit per bin of an unconstrained binary channel. -/
theorem card_trains_le_pow : ∀ m : ℕ, (trains (5 * m)).card ≤ 16 ^ m
  | 0 => by simp [trains]
  | (m + 1) => by
      have hstep : Nat.fib (5 * m + 7) ≤ 16 * Nat.fib (5 * m + 2) := fib_five_step (5 * m)
      have hprev : Nat.fib (5 * m + 2) ≤ 16 ^ m := by
        have h := card_trains_le_pow m
        rwa [card_trains] at h
      rw [card_trains]
      have hidx : 5 * (m + 1) + 2 = 5 * m + 7 := by ring
      rw [hidx]
      calc Nat.fib (5 * m + 7) ≤ 16 * Nat.fib (5 * m + 2) := hstep
        _ ≤ 16 * 16 ^ m := Nat.mul_le_mul_left _ hprev
        _ = 16 ^ (m + 1) := by ring

/-- **Temporal information rate.**  A refractory neuron transmits at most
`0.8` bits per time bin over a window of `5m` bins. -/
theorem temporal_rate_le (m : ℕ) :
    Real.logb 2 ((trains (5 * m)).card) ≤ 0.8 * (5 * m) := by
  have h := card_trains_le_pow m
  have hcard : ((trains (5 * m)).card : ℝ) ≤ (16 : ℝ) ^ m := by exact_mod_cast h
  have hpos : (0 : ℝ) < ((trains (5 * m)).card : ℝ) := by
    have hp : 0 < (trains (5 * m)).card := by
      rw [card_trains]; exact Nat.fib_pos.mpr (by omega)
    exact_mod_cast hp
  have hlog : Real.logb 2 ((trains (5 * m)).card) ≤ Real.logb 2 ((16 : ℝ) ^ m) :=
    Real.logb_le_logb_of_le (by norm_num) hpos hcard
  have h16 : Real.logb 2 ((16 : ℝ) ^ m) = 4 * m := by
    rw [Real.logb_pow, show (16 : ℝ) = 2 ^ (4 : ℕ) by norm_num, Real.logb_pow,
      Real.logb_self_eq_one (b := (2:ℝ)) (by norm_num)]
    ring
  rw [h16] at hlog
  calc Real.logb 2 ((trains (5 * m)).card) ≤ 4 * (m : ℝ) := hlog
    _ = 0.8 * (5 * m) := by ring

end Catalog.Probability.NeuralCoding.Temporal