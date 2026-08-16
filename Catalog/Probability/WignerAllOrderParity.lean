/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# All-order walk expansion of the trace, and the exact vanishing of every odd moment

The files `Probability.WignerRademacherEnsemble` and `Probability.WignerWalkParity`
compute the spectral moments of the symmetric Rademacher ensemble at orders `2`, `3`
and `4`, and isolate the sign-flip involution for a walk of fixed length.  This file
removes the length restriction completely:

* `RademacherWigner.trace_pow_succ_sum_walks` expands `tr (M ^ (m+1))` for an
  *arbitrary* matrix as a sum over closed `(m+1)`-walks, encoded as a starting
  vertex `i` together with the remaining vertices `v : Fin m → Fin N`; the `t`-th
  step goes from `(Fin.cons i v) t` to `(Fin.snoc v i) t`.  This is proved by
  induction from the entrywise path expansion `RademacherWigner.pow_apply_sum_walks`.

* The sign-flip calculus is then developed for an arbitrary finite family of steps
  `a b : ι → Fin N` (`edgeMult`, `prod_entry_flipEdge_family`), giving

  - `expect_prod_entry_family_eq_zero_of_card_odd`: **any** odd-size family of steps
    has vanishing ensemble average, and
  - `prod_entry_eq_one_of_even`: a loop-free family all of whose edge multiplicities
    are even has monomial identically `1`,

  hence the exact dichotomy `expect_prod_entry_family`: the ensemble average of a
  walk monomial is `1` if the walk is loop-free with all edge multiplicities even,
  and `0` otherwise.

* Consequently `expect_trace_pow_eq_sum_indicator` reduces the computation of *every*
  moment `E [tr W^m]` to a purely combinatorial count of even closed walks, and
  `expect_trace_pow_odd` proves that **all odd trace moments vanish exactly, at every
  finite dimension `N` and every odd order** — no asymptotics, no error terms.
  Normalising, `expect_normalizedMoment_odd` matches the odd moments of the
  semicircle law (`WignerUniversal`-style statement at all orders, rather than only
  at order `3`).
-/
import Probability.WignerWalkParity
import Probability.WignerSemicircleLawLowOrder

open Matrix BigOperators Finset

namespace RademacherWigner

variable {N : ℕ}

/-! ### Walk expansion of powers and traces of an arbitrary matrix -/

/-- **Path expansion of a matrix power.**  The `(i, j)` entry of `M ^ (m+1)` is the
sum, over all sequences `v` of `m` intermediate vertices, of the product of the
entries along the path `i → v 0 → ⋯ → v (m-1) → j`.  Here the `t`-th step goes from
`(Fin.cons i v) t` to `(Fin.snoc v j) t`. -/
theorem pow_apply_sum_walks (M : Matrix (Fin N) (Fin N) ℝ) :
    ∀ (m : ℕ) (i j : Fin N),
      (M ^ (m + 1)) i j = ∑ v : Fin m → Fin N, ∏ t : Fin (m + 1),
        M ((Fin.cons i v : Fin (m + 1) → Fin N) t)
          ((Fin.snoc v j : Fin (m + 1) → Fin N) t) := by
  intro m
  induction m with
  | zero =>
      intro i j
      rw [Finset.sum_congr rfl (g := fun _ => M i j) ?_]
      · simp
      · intro v _
        rw [Fin.prod_univ_one, show (0 : Fin 1) = Fin.last 0 from rfl, Fin.snoc_last]
        simp
  | succ m ih =>
      intro i j
      rw [pow_succ, Matrix.mul_apply]
      have h1 : ∀ k : Fin N, (M ^ (m + 1)) i k * M k j
          = ∑ v : Fin m → Fin N, (∏ t : Fin (m + 1),
              M ((Fin.cons i v : Fin (m + 1) → Fin N) t)
                ((Fin.snoc v k : Fin (m + 1) → Fin N) t)) * M k j := by
        intro k; rw [ih i k, Finset.sum_mul]
      rw [Finset.sum_congr rfl fun k _ => h1 k]
      rw [← (Fin.snocEquiv (fun _ : Fin (m + 1) => Fin N)).sum_comp
        (fun u : Fin (m + 1) → Fin N => ∏ t : Fin (m + 2),
          M ((Fin.cons i u : Fin (m + 2) → Fin N) t)
            ((Fin.snoc u j : Fin (m + 2) → Fin N) t))]
      rw [Fintype.sum_prod_type]
      refine Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun v _ => ?_
      have hu : (Fin.snocEquiv (fun _ : Fin (m + 1) => Fin N)) (k, v)
          = (Fin.snoc v k : Fin (m + 1) → Fin N) := rfl
      rw [hu]
      symm
      rw [Fin.prod_univ_castSucc]
      congr 1
      · refine Finset.prod_congr rfl fun s _ => ?_
        congr 1
        · refine Fin.cases ?_ ?_ s
          · simp
          · intro r
            rw [← Fin.succ_castSucc]
            simp
        · simp
      · congr 1 <;> simp

/-- **Closed-walk expansion of the trace of a power.**  `tr (M ^ (m+1))` is the sum
over closed `(m+1)`-walks: a base point `i` and `m` further vertices `v`. -/
theorem trace_pow_succ_sum_walks (M : Matrix (Fin N) (Fin N) ℝ) (m : ℕ) :
    (M ^ (m + 1)).trace = ∑ i : Fin N, ∑ v : Fin m → Fin N, ∏ t : Fin (m + 1),
      M ((Fin.cons i v : Fin (m + 1) → Fin N) t)
        ((Fin.snoc v i : Fin (m + 1) → Fin N) t) := by
  simp only [Matrix.trace, Matrix.diag]
  exact Finset.sum_congr rfl fun i _ => pow_apply_sum_walks M m i i

/-! ### The sign-flip calculus for an arbitrary finite family of steps -/

variable {ι : Type*} [Fintype ι]

/-- The number of steps of the family `(a, b)` that traverse the edge `p`. -/
def edgeMult (a b : ι → Fin N) (p : Fin N × Fin N) : ℕ :=
  (Finset.univ.filter fun t => edgeOf (a t) (b t) = p).card

/-- **Sign-flip rule for a family of steps.**  Flipping the Rademacher variable at
the edge `p` multiplies the monomial `∏ entry (a t) (b t)` by `(-1)` once for every
step traversing `p`. -/
theorem prod_entry_flipEdge_family (g : Config N) (a b : ι → Fin N)
    (p : Fin N × Fin N) :
    (∏ t, entry (flipEdge p g) (a t) (b t))
      = (-1) ^ edgeMult a b p * ∏ t, entry g (a t) (b t) := by
  have h : ∀ t : ι, entry (flipEdge p g) (a t) (b t)
      = (if edgeOf (a t) (b t) = p then (-1 : ℝ) else 1) * entry g (a t) (b t) := by
    intro t
    rw [entry_flipEdge]
    split <;> ring
  rw [Finset.prod_congr rfl fun t _ => h t, Finset.prod_mul_distrib]
  congr 1
  rw [Finset.prod_ite, Finset.prod_const, Finset.prod_const_one, mul_one, edgeMult]

/-- If some edge is traversed an odd number of times by the family of steps, the
ensemble average of the monomial vanishes. -/
theorem expect_prod_entry_family_eq_zero (a b : ι → Fin N) (p : Fin N × Fin N)
    (hodd : Odd (edgeMult a b p)) :
    expect (fun g : Config N => ∏ t, entry g (a t) (b t)) = 0 := by
  have hneg : ∀ g : Config N,
      (∏ t, entry (flipEdge p g) (a t) (b t)) = -∏ t, entry g (a t) (b t) := by
    intro g
    rw [prod_entry_flipEdge_family, hodd.neg_one_pow, neg_one_mul]
  have hsum : (∑ g : Config N, ∏ t, entry g (a t) (b t)) = 0 := by
    have h1 := Equiv.sum_comp (flipEdge (N := N) p)
      (fun g => ∏ t, entry g (a t) (b t))
    rw [Finset.sum_congr rfl fun g _ => hneg g, Finset.sum_neg_distrib] at h1
    linarith
  unfold expect
  rw [hsum, zero_div]

/-- The step count is the sum of the edge multiplicities. -/
theorem card_eq_sum_edgeMult (a b : ι → Fin N) :
    Fintype.card ι = ∑ p : Fin N × Fin N, edgeMult a b p := by
  rw [← Finset.card_univ]
  exact Finset.card_eq_sum_card_fiberwise (fun t _ => Finset.mem_univ (edgeOf (a t) (b t)))

/-- A family with an odd number of steps must traverse some edge an odd number of
times. -/
theorem exists_odd_edgeMult (a b : ι → Fin N) (h : Odd (Fintype.card ι)) :
    ∃ p : Fin N × Fin N, Odd (edgeMult a b p) := by
  by_contra hcon
  push_neg at hcon
  have heven : ∀ p : Fin N × Fin N, Even (edgeMult a b p) := by
    intro p
    rcases Nat.even_or_odd (edgeMult a b p) with h' | h'
    · exact h'
    · exact absurd h' (hcon p)
  have : Even (Fintype.card ι) := by
    rw [card_eq_sum_edgeMult a b]
    exact Finset.even_sum _ fun p _ => heven p
  exact (Nat.not_even_iff_odd.2 h) this

/-- **Odd-length families average to zero.**  If the family of steps has an odd
number of members, its ensemble average vanishes, whatever the steps are. -/
theorem expect_prod_entry_family_eq_zero_of_card_odd (a b : ι → Fin N)
    (h : Odd (Fintype.card ι)) :
    expect (fun g : Config N => ∏ t, entry g (a t) (b t)) = 0 := by
  obtain ⟨p, hp⟩ := exists_odd_edgeMult a b h
  exact expect_prod_entry_family_eq_zero a b p hp

/-- A loop-free family all of whose edge multiplicities are even has monomial
identically `1`: every Rademacher variable occurs to an even power. -/
theorem prod_entry_eq_one_of_even (g : Config N) (a b : ι → Fin N)
    (hne : ∀ t, a t ≠ b t) (heven : ∀ p, Even (edgeMult a b p)) :
    (∏ t, entry g (a t) (b t)) = 1 := by
  have h1 : (∏ t, entry g (a t) (b t)) = ∏ t, sgn (g (edgeOf (a t) (b t))) :=
    Finset.prod_congr rfl fun t _ => by rw [entry, if_neg (hne t)]
  rw [h1, ← Finset.prod_fiberwise Finset.univ (fun t => edgeOf (a t) (b t))
    (fun t => sgn (g (edgeOf (a t) (b t))))]
  refine Finset.prod_eq_one fun p _ => ?_
  have h2 : ∀ t ∈ Finset.univ.filter (fun t => edgeOf (a t) (b t) = p),
      sgn (g (edgeOf (a t) (b t))) = sgn (g p) := by
    intro t ht
    rw [(Finset.mem_filter.1 ht).2]
  rw [Finset.prod_congr rfl h2, Finset.prod_const, ← edgeMult]
  obtain ⟨k, hk⟩ := heven p
  rw [hk, pow_add, ← mul_pow, sgn_mul_self, one_pow]

/-- **The moment method reduces to counting even walks.**  The ensemble average of a
walk monomial is `1` when the walk is loop-free and every edge is traversed an even
number of times, and `0` in every other case. -/
theorem expect_prod_entry_family (a b : ι → Fin N) :
    expect (fun g : Config N => ∏ t, entry g (a t) (b t))
      = if (∀ t, a t ≠ b t) ∧ (∀ p, Even (edgeMult a b p)) then 1 else 0 := by
  by_cases hgood : (∀ t, a t ≠ b t) ∧ (∀ p, Even (edgeMult a b p))
  · rw [if_pos hgood]
    have h1 : ∀ g : Config N, (∏ t, entry g (a t) (b t)) = 1 :=
      fun g => prod_entry_eq_one_of_even g a b hgood.1 hgood.2
    simp only [h1]
    exact expect_const 1
  · rw [if_neg hgood]
    by_cases hloop : ∀ t, a t ≠ b t
    · have hodd : ∃ p, Odd (edgeMult a b p) := by
        by_contra hcon
        push_neg at hcon
        refine hgood ⟨hloop, fun p => ?_⟩
        rcases Nat.even_or_odd (edgeMult a b p) with h' | h'
        · exact h'
        · exact absurd h' (hcon p)
      obtain ⟨p, hp⟩ := hodd
      exact expect_prod_entry_family_eq_zero a b p hp
    · push_neg at hloop
      obtain ⟨t, ht⟩ := hloop
      have h0 : ∀ g : Config N, (∏ s, entry g (a s) (b s)) = 0 := by
        intro g
        refine Finset.prod_eq_zero (Finset.mem_univ t) ?_
        rw [entry, if_pos ht]
      simp only [h0]
      exact expect_zero

/-! ### Consequences for the spectral moments -/

/-- A closed `(m+1)`-walk based at `i` with intermediate vertices `v` is *even* if it
never stays put and traverses every edge an even number of times.  These are exactly
the walks that survive the ensemble average. -/
def IsEvenWalk (m : ℕ) (i : Fin N) (v : Fin m → Fin N) : Prop :=
  (∀ t : Fin (m + 1), (Fin.cons i v : Fin (m + 1) → Fin N) t
      ≠ (Fin.snoc v i : Fin (m + 1) → Fin N) t) ∧
  (∀ p, Even (edgeMult (Fin.cons i v : Fin (m + 1) → Fin N)
      (Fin.snoc v i : Fin (m + 1) → Fin N) p))

instance IsEvenWalk.decidablePred {m : ℕ} (i : Fin N) (v : Fin m → Fin N) :
    Decidable (IsEvenWalk m i v) := by
  unfold IsEvenWalk
  infer_instance

/-- **Every trace moment of the Rademacher ensemble counts even closed walks.**
`E [tr W^(m+1)]` equals the number of closed `(m+1)`-walks that are loop-free with
all edge multiplicities even. -/
theorem expect_trace_pow_eq_sum_indicator (m : ℕ) :
    expect (fun g : Config N => ((W g) ^ (m + 1)).trace)
      = ∑ i : Fin N, ∑ v : Fin m → Fin N, if IsEvenWalk m i v then (1 : ℝ) else 0 := by
  have h1 : ∀ g : Config N, ((W g) ^ (m + 1)).trace
      = ∑ i : Fin N, ∑ v : Fin m → Fin N, ∏ t : Fin (m + 1),
        entry g ((Fin.cons i v : Fin (m + 1) → Fin N) t)
          ((Fin.snoc v i : Fin (m + 1) → Fin N) t) := by
    intro g
    simpa using trace_pow_succ_sum_walks (W g) m
  simp only [h1]
  rw [expect_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [expect_sum]
  refine Finset.sum_congr rfl fun v _ => ?_
  rw [expect_prod_entry_family]
  by_cases h : IsEvenWalk m i v
  · rw [if_pos h]
    exact if_pos h
  · rw [if_neg h]
    exact if_neg h

/-- **All odd trace moments vanish exactly.**  For every odd `m` and every dimension
`N`, `E [tr (W^m)] = 0`.  This is the parity half of the semicircle law for the
Rademacher ensemble, at *every* order — the odd moments of the semicircle law are
matched exactly at finite `N`, with no error term. -/
theorem expect_trace_pow_odd (m : ℕ) (hm : Odd m) :
    expect (fun g : Config N => ((W g) ^ m).trace) = 0 := by
  obtain ⟨k, hk⟩ := hm
  subst hk
  have h1 : ∀ g : Config N, ((W g) ^ (2 * k + 1)).trace
      = ∑ i : Fin N, ∑ v : Fin (2 * k) → Fin N, ∏ t : Fin (2 * k + 1),
        entry g ((Fin.cons i v : Fin (2 * k + 1) → Fin N) t)
          ((Fin.snoc v i : Fin (2 * k + 1) → Fin N) t) := by
    intro g
    simpa using trace_pow_succ_sum_walks (W g) (2 * k)
  simp only [h1]
  rw [expect_sum]
  refine Finset.sum_eq_zero fun i _ => ?_
  rw [expect_sum]
  refine Finset.sum_eq_zero fun v _ => ?_
  refine expect_prod_entry_family_eq_zero_of_card_odd _ _ ?_
  rw [Fintype.card_fin]
  exact ⟨k, by ring⟩

/-- **The odd normalised spectral moments vanish exactly**, at every finite `N`:
the expectation of `(1/N) tr ((W/√N)^m)` is `0` for every odd `m`.  Compare
`WignerSemicircleMoments.semicircleMoment_odd`: the semicircle law has the same odd
moments, so the moment method matches at all odd orders with no asymptotics. -/
theorem expect_normalizedMoment_odd (m : ℕ) (hm : Odd m) :
    expect (fun g : Config N => WignerBridge.normalizedMoment (W g) m) = 0 := by
  have h : ∀ g : Config N, WignerBridge.normalizedMoment (W g) m
      = ((1 / (Fintype.card (Fin N) : ℝ)) * (Real.sqrt (Fintype.card (Fin N)))⁻¹ ^ m)
        * ((W g) ^ m).trace := by
    intro g
    rw [WignerBridge.normalizedMoment_eq]
  simp only [h]
  rw [expect_const_mul, expect_trace_pow_odd m hm, mul_zero]

end RademacherWigner