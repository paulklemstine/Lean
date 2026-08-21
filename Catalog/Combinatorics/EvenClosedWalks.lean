/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Even closed walks: the combinatorial content of the exact ensemble dichotomy

`Probability.WignerAllOrderParity` proves an *exact dichotomy* for the symmetric
Rademacher ensemble: the ensemble average of a walk monomial is `1` when the family
of steps is loop-free with all edge multiplicities even, and `0` otherwise
(`RademacherWigner.expect_prod_entry_family`).  Consequently every trace moment is a
count of "even" closed walks (`expect_trace_pow_eq_sum_indicator`).

This file isolates that count as a purely combinatorial object.  Closed walks are
re-encoded *cyclically*: a closed walk of length `L` is simply a map
`w : Fin L → Fin N`, the `t`-th step going from `w t` to `w (t + 1)` with `t + 1`
computed in `Fin L` (so the last step returns to the start).  In this encoding

* `IsEvenClosedWalk w` says the walk never stands still and traverses every edge an
  even number of times;
* `evenClosedWalkCount N L` counts such walks.

The main results are

* `RademacherWigner.expect_trace_pow_eq_evenClosedWalkCount`: for every `N` and every
  `L ≥ 1`, `E [tr W^L]` equals `evenClosedWalkCount N L` exactly — a probabilistic
  quantity is *identically* a combinatorial count at finite `N`;
* `evenClosedWalkCount_eq_zero_of_odd`: an odd-length closed walk can never be even
  (a direct parity argument on edge multiplicities), the combinatorial shadow of
  `expect_trace_pow_odd`;
* `evenClosedWalkCount_two` and `evenClosedWalkCount_four`: the exact counts
  `N(N-1)` and `N(N-1)(2N-3)`, obtained by *transporting* the ensemble computations
  of `Probability.WignerRademacherEnsemble` back across the dictionary.
-/
import Probability.WignerAllOrderParity

open Matrix BigOperators Finset RademacherWigner

namespace EvenWalks

variable {N : ℕ}

/-! ### Cyclic encoding of closed walks -/

/-- A closed walk of length `L` in the complete graph on `Fin N` is *even* if it never
stands still and traverses every edge an even number of times.  The `t`-th step goes
from `w t` to `w (t + 1)`, the index arithmetic taking place in `Fin L`. -/
def IsEvenClosedWalk {L : ℕ} [NeZero L] (w : Fin L → Fin N) : Prop :=
  (∀ t, w t ≠ w (t + 1)) ∧ ∀ p, Even (edgeMult w (fun t => w (t + 1)) p)

instance IsEvenClosedWalk.decidablePred {L : ℕ} [NeZero L] (w : Fin L → Fin N) :
    Decidable (IsEvenClosedWalk w) := by
  unfold IsEvenClosedWalk
  infer_instance

/-- The number of even closed walks of length `L` on `N` vertices. -/
def evenClosedWalkCount (N L : ℕ) [NeZero L] : ℕ :=
  (Finset.univ.filter fun w : Fin L → Fin N => IsEvenClosedWalk w).card

/-! ### The dictionary with the `cons`/`snoc` encoding used by the ensemble files -/

/-- In the `cons`/`snoc` encoding of a closed walk, the endpoint of the `t`-th step is
the starting point of the `(t+1)`-st step, cyclically. -/
theorem snoc_eq_cons_succ {m : ℕ} (i : Fin N) (v : Fin m → Fin N) (t : Fin (m + 1)) :
    (Fin.snoc v i : Fin (m + 1) → Fin N) t
      = (Fin.cons i v : Fin (m + 1) → Fin N) (t + 1) := by
  refine Fin.lastCases ?_ ?_ t
  · rw [Fin.snoc_last, Fin.last_add_one, Fin.cons_zero]
  · intro s
    rw [Fin.snoc_castSucc, Fin.coeSucc_eq_succ, Fin.cons_succ]

/-- The two encodings of "even closed walk" agree. -/
theorem isEvenWalk_iff_isEvenClosedWalk {m : ℕ} (i : Fin N) (v : Fin m → Fin N) :
    IsEvenWalk m i v ↔ IsEvenClosedWalk (Fin.cons i v : Fin (m + 1) → Fin N) := by
  have h : (Fin.snoc v i : Fin (m + 1) → Fin N)
      = fun t => (Fin.cons i v : Fin (m + 1) → Fin N) (t + 1) :=
    funext (snoc_eq_cons_succ i v)
  unfold IsEvenWalk IsEvenClosedWalk
  rw [h]

/-- Summing an indicator over base point and interior vertices is the same as summing
over cyclically encoded closed walks. -/
theorem sum_indicator_eq_count (m : ℕ) :
    (∑ i : Fin N, ∑ v : Fin m → Fin N, if IsEvenWalk m i v then (1 : ℝ) else 0)
      = (evenClosedWalkCount N (m + 1) : ℝ) := by
  have h1 : (∑ i : Fin N, ∑ v : Fin m → Fin N, if IsEvenWalk m i v then (1 : ℝ) else 0)
      = ∑ w : Fin (m + 1) → Fin N, if IsEvenClosedWalk w then (1 : ℝ) else 0 := by
    rw [← (Fin.consEquiv (fun _ : Fin (m + 1) => Fin N)).sum_comp
      (fun w => if IsEvenClosedWalk w then (1 : ℝ) else 0), Fintype.sum_prod_type]
    refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun v _ => ?_
    simp only [Fin.consEquiv]
    exact if_congr (isEvenWalk_iff_isEvenClosedWalk i v) rfl rfl
  rw [h1, evenClosedWalkCount, Finset.sum_boole]

end EvenWalks

namespace RademacherWigner

open EvenWalks

/-- **Every trace moment is exactly a count of even closed walks.**  At every finite
dimension `N` and every length `m + 1`, the ensemble average of `tr (W^(m+1))` equals
the number of even closed walks of that length. -/
theorem expect_trace_pow_eq_evenClosedWalkCount {N : ℕ} (m : ℕ) :
    expect (fun g : Config N => ((W g) ^ (m + 1)).trace)
      = (evenClosedWalkCount N (m + 1) : ℝ) := by
  rw [expect_trace_pow_eq_sum_indicator, sum_indicator_eq_count]

end RademacherWigner

namespace EvenWalks

variable {N : ℕ}

/-! ### Parity: odd closed walks are never even -/

/-- **No odd-length closed walk is even.**  The number of steps is the sum of the edge
multiplicities, so if all multiplicities are even the length is even. -/
theorem evenClosedWalkCount_eq_zero_of_odd (N k : ℕ) :
    evenClosedWalkCount N (2 * k + 1) = 0 := by
  rw [evenClosedWalkCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro w _ hw
  have hcard := card_eq_sum_edgeMult w (fun t => w (t + 1))
  rw [Fintype.card_fin] at hcard
  have heven : Even (2 * k + 1) := by
    rw [hcard]
    exact Finset.even_sum _ fun p _ => hw.2 p
  obtain ⟨c, hc⟩ := heven
  omega

/-! ### The exact counts at lengths two and four -/

/-- A closed walk of length two is even exactly when its two vertices differ: both
steps then traverse the single edge `{w 0, w 1}`. -/
theorem isEvenClosedWalk_two_iff (w : Fin 2 → Fin N) :
    IsEvenClosedWalk w ↔ w 0 ≠ w 1 := by
  have hedge : ∀ t : Fin 2, edgeOf (w t) (w (t + 1)) = edgeOf (w 0) (w 1) := by
    intro t
    fin_cases t
    · rfl
    · simpa using edgeOf_comm (w 1) (w 0)
  constructor
  · intro hw
    simpa using hw.1 0
  · intro hne
    refine ⟨fun t => ?_, fun p => ?_⟩
    · fin_cases t
      · simpa using hne
      · simpa using hne.symm
    · by_cases hp : edgeOf (w 0) (w 1) = p
      · have h2 : edgeMult w (fun t => w (t + 1)) p = 2 := by
          rw [edgeMult, Finset.filter_true_of_mem (fun t _ => by rw [hedge t, hp])]
          simp
        rw [h2]
        exact ⟨1, rfl⟩
      · have h0 : edgeMult w (fun t => w (t + 1)) p = 0 := by
          rw [edgeMult, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
          intro t _
          rw [hedge t]
          exact hp
        rw [h0]
        exact ⟨0, rfl⟩

/-- **Exact count of even closed 2-walks**: there are `N(N-1)` of them.  Transported
across the dictionary this is the deterministic second moment
`RademacherWigner.trace_W_sq`. -/
theorem evenClosedWalkCount_two (N : ℕ) : evenClosedWalkCount N 2 = N * (N - 1) := by
  have hb : (evenClosedWalkCount N 2 : ℝ) = (N : ℝ) ^ 2 - (N : ℝ) := by
    have h := expect_trace_pow_eq_evenClosedWalkCount (N := N) 1
    norm_num at h
    rw [← h]
    have h2 : ∀ g : Config N, ((W g) ^ 2).trace = (N : ℝ) ^ 2 - (N : ℝ) := trace_W_sq
    simp only [h2]
    exact expect_const _
  have hcast : ((N * (N - 1) : ℕ) : ℝ) = (N : ℝ) ^ 2 - (N : ℝ) := by
    rcases Nat.eq_zero_or_pos N with rfl | hN
    · norm_num
    · rw [Nat.cast_mul, Nat.cast_sub hN]
      push_cast
      ring
  exact Nat.cast_injective (hb.trans hcast.symm)

/-- **Exact count of even closed 4-walks**: there are `N(N-1)(2N-3)` of them.  This is
the exact fourth trace moment `RademacherWigner.expect_trace_W_four`, read as a
combinatorial count. -/
theorem evenClosedWalkCount_four (N : ℕ) :
    evenClosedWalkCount N 4 = N * (N - 1) * (2 * N - 3) := by
  have hb : (evenClosedWalkCount N 4 : ℝ)
      = 2 * (N : ℝ) * ((N : ℝ) - 1) ^ 2 - (N : ℝ) * ((N : ℝ) - 1) := by
    have h := expect_trace_pow_eq_evenClosedWalkCount (N := N) 3
    norm_num at h
    rw [← h]
    exact expect_trace_W_four N
  have hcast : ((N * (N - 1) * (2 * N - 3) : ℕ) : ℝ)
      = 2 * (N : ℝ) * ((N : ℝ) - 1) ^ 2 - (N : ℝ) * ((N : ℝ) - 1) := by
    match N with
    | 0 => norm_num
    | 1 => norm_num
    | (n + 2) =>
        have h1 : n + 2 - 1 = n + 1 := by omega
        have h2 : 2 * (n + 2) - 3 = 2 * n + 1 := by omega
        rw [h1, h2]
        push_cast
        ring
  exact Nat.cast_injective (hb.trans hcast.symm)

end EvenWalks