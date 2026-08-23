/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.Exact

/-!
# Two-sided bounds valid for every wolf count

The two theorems of this file sandwich the wolf-win probability of the
information-free game between the *union bound* `k * surv (v+k)` and the same
quantity corrected by a term of order `1 / population`:

* `failProb_le_union` :  `failProb v k ≤ k * surv (v + k)`  (all `v`, `k`);
* `failProb_ge_union_error` :  for each `k` there is a constant `A_k ≥ 0` with
  `(v + k) * (k * surv (v + k) - failProb v k) ≤ A_k` for all `v`.

Both are proved by induction along the deterministic population ladder
`n, n-2, n-4, …`; the crucial algebraic cancellation in each step is
`k·(k-1) + v·k = k·(n-1)`, exactly the recursion satisfied by `surv`.

Since `surv n` decays like `n^(-1/2)` (see `Asymptotics.lean`), the error term
`A_k / n` is of lower order and the union bound is asymptotically exact for every
fixed `k`.  This is what upgrades the one-wolf parity analysis to all `k`.

The constant `A_k` cannot be taken to be `0` for `k ≥ 2` (see
`failProb_two_wolves_odd_ne`), and cannot be taken uniform in `k`: for `v = 0` the
left-hand side already grows like `k^{3/2}`.
-/

namespace InfoFreeWerewolf

/-! ### Elementary lower bounds on the survival products -/

/-- `n * surv n ≥ 1` for `n ≥ 1`: the expected number of surviving wolves in a
population of size `n` with `n` wolves is at least one. -/
theorem one_le_mul_surv : ∀ n : ℕ, 1 ≤ ((n : ℚ) + 1) * surv (n + 1)
  | 0 => by norm_num
  | 1 => by norm_num [surv_succ_succ]
  | (n + 2) => by
      have h := one_le_mul_surv n
      have hp : (0 : ℚ) < surv (n + 1) := surv_pos _
      rw [show n + 2 + 1 = (n + 1) + 2 from rfl, surv_succ_succ]
      push_cast
      have e : ((n : ℚ) + 2 + 1) * (surv (n + 1) * ((n : ℚ) + 1 + 1) / ((n : ℚ) + 1 + 2))
          = ((n : ℚ) + 2) * surv (n + 1) := by field_simp; ring
      rw [e]
      nlinarith

/-- The shifted variant `k * surv (k+1) ≥ 1`, needed for the case of a single
villager facing `k ≥ 2` wolves. -/
theorem one_le_mul_surv_succ : ∀ k : ℕ, 1 ≤ ((k : ℚ) + 2) * surv (k + 3)
  | 0 => by norm_num [surv_succ_succ]
  | 1 => by norm_num [surv_succ_succ]
  | (k + 2) => by
      have h := one_le_mul_surv_succ k
      have hp : (0 : ℚ) < surv (k + 3) := surv_pos _
      rw [show k + 2 + 3 = (k + 3) + 2 from rfl, surv_succ_succ]
      push_cast
      have e : ((k : ℚ) + 2 + 2) * (surv (k + 3) * ((k : ℚ) + 3 + 1) / ((k : ℚ) + 3 + 2))
          = (((k : ℚ) + 4) ^ 2 / ((k : ℚ) + 5)) * surv (k + 3) := by field_simp; ring
      rw [e]
      have h5 : (0 : ℚ) < (k : ℚ) + 5 := by positivity
      rw [div_mul_eq_mul_div, le_div_iff₀ h5]
      nlinarith

/-! ### The union bound -/

/-- **Union bound.**  The wolves win only if some wolf is never lynched, so the
wolf-win probability is at most `k` times the survival probability of a single
designated wolf.  Equality holds for `k = 1` (always) and for `k = 2` with an even
population. -/
theorem failProb_le_union : ∀ v k : ℕ, failProb v k ≤ (k : ℚ) * surv (v + k)
  | _, 0 => by simp
  | 0, (k + 1) => by simpa using one_le_mul_surv k
  | 1, (k + 1) => by
      match k with
      | 0 => norm_num [failProb, surv]
      | (k + 1) =>
        rw [failProb_step 0 (k + 1)]
        norm_num
        have h := one_le_mul_surv_succ k
        rw [show 1 + (k + 1 + 1) = k + 3 from by omega]
        calc ((k : ℚ) + 1 + 1 + 1) / ((k : ℚ) + 1 + 2) = 1 := by field_simp; ring
        _ ≤ ((k : ℚ) + 1 + 1) * surv (k + 3) := by linarith
  | (v + 2), (k + 1) => by
      rw [failProb_step' v k]
      have h1 : failProb (v + 1) k ≤ (k : ℚ) * surv (v + k + 1) := by
        have h := failProb_le_union (v + 1) k
        rwa [show v + 1 + k = v + k + 1 from by omega] at h
      have h2 : failProb v (k + 1) ≤ ((k : ℚ) + 1) * surv (v + k + 1) := by
        have h := failProb_le_union v (k + 1)
        rw [show v + (k + 1) = v + k + 1 from by omega] at h
        push_cast at h
        exact h
      have hs : surv (v + 2 + (k + 1))
          = surv (v + k + 1) * ((v : ℚ) + k + 1 + 1) / ((v : ℚ) + k + 1 + 2) := by
        rw [show v + 2 + (k + 1) = (v + k + 1) + 2 from by omega, surv_succ_succ]
        push_cast; ring
      rw [hs]
      have hpos : (0 : ℚ) < (v : ℚ) + k + 3 := by positivity
      rw [div_le_iff₀ hpos]
      have key : (((k : ℕ) + 1 : ℕ) : ℚ) *
            (surv (v + k + 1) * ((v : ℚ) + k + 1 + 1) / ((v : ℚ) + k + 1 + 2)) * ((v : ℚ) + k + 3)
          = ((k : ℚ) + 1) * surv (v + k + 1) * ((v : ℚ) + k + 2) := by
        push_cast; field_simp; ring
      rw [key]
      have hsp : (0 : ℚ) < surv (v + k + 1) := surv_pos _
      nlinarith [h1, h2]
termination_by v _ => v

/-! ### The matching lower bound -/

/-- **The union bound is sharp to first order.**  For every fixed wolf count `k`
there is a constant `A_k ≥ 0` such that the defect of the union bound, multiplied by
the population, stays bounded:
`(v + k) * (k * surv (v + k) - failProb v k) ≤ A_k`.

The proof is a double induction: on `k`, and for fixed `k` along the population
ladder.  The key algebraic fact is that the defect `D` satisfies the *same* linear
recursion `n · D(v,k) = k · D(v-1,k-1) + v · D(v-2,k)` as the probabilities
themselves, with the leading term cancelling exactly.  The propagation constant is
admissible because `k · A_{k-1} ≤ (k-2) · A_k` can always be arranged — using
crucially that `A_1 = 0`, i.e. that the one-wolf formula is *exact*. -/
theorem failProb_ge_union_error : ∀ k : ℕ, ∃ A : ℚ, 0 ≤ A ∧ (k = 1 → A = 0) ∧
    ∀ v : ℕ, ((v : ℚ) + k) * ((k : ℚ) * surv (v + k) - failProb v k) ≤ A
  | 0 => ⟨0, le_rfl, by omega, by intro v; simp⟩
  | 1 => ⟨0, le_rfl, fun _ => rfl, by
      intro v
      rw [failProb_one_wolf]
      push_cast
      ring_nf
      simp⟩
  | (j + 2) => by
      obtain ⟨A', hA'0, hA'1, hA'⟩ := failProb_ge_union_error (j + 1)
      set b0 : ℚ := ((0 : ℚ) + ((j : ℚ) + 2)) *
        (((j : ℚ) + 2) * surv (0 + (j + 2)) - failProb 0 (j + 2)) with hb0
      set b1 : ℚ := ((1 : ℚ) + ((j : ℚ) + 2)) *
        (((j : ℚ) + 2) * surv (1 + (j + 2)) - failProb 1 (j + 2)) with hb1
      set A : ℚ := max (max b0 b1) (max 0 (((j : ℚ) + 2) * A')) with hA
      have hA0 : 0 ≤ A := le_max_of_le_right (le_max_left _ _)
      have hAb0 : b0 ≤ A := le_max_of_le_left (le_max_left _ _)
      have hAb1 : b1 ≤ A := le_max_of_le_left (le_max_right _ _)
      have hAK : ((j : ℚ) + 2) * A' ≤ A := le_max_of_le_right (le_max_right _ _)
      have hkey : ((j : ℚ) + 2) * A' ≤ (j : ℚ) * A := by
        rcases Nat.eq_zero_or_pos j with hj | hj
        · subst hj; simp [hA'1 rfl]
        · have h1 : (1 : ℚ) ≤ (j : ℚ) := by exact_mod_cast hj
          nlinarith
      refine ⟨A, hA0, by omega, ?_⟩
      intro v
      induction v using Nat.strong_induction_on with
      | _ v ih =>
        match v with
        | 0 => push_cast; rw [hb0] at hAb0; convert hAb0 using 2
        | 1 => push_cast; rw [hb1] at hAb1; convert hAb1 using 2
        | (w + 2) =>
          have hQ := ih w (by omega)
          have hP := hA' (w + 1)
          have hf : failProb (w + 2) (j + 2) =
              (((j : ℚ) + 2) * failProb (w + 1) (j + 1) + ((w : ℚ) + 2) * failProb w (j + 2)) /
                ((w : ℚ) + j + 4) := by
            have h := failProb_step' w (j + 1)
            push_cast at h ⊢
            rw [h]; ring_nf
          have hs : surv (w + 2 + (j + 2)) =
              surv (w + (j + 2)) * ((w : ℚ) + j + 3) / ((w : ℚ) + j + 4) := by
            rw [show w + 2 + (j + 2) = (w + (j + 2)) + 2 from by omega, surv_succ_succ]
            push_cast; ring
          have hidx : (w + 1) + (j + 1) = w + (j + 2) := by omega
          rw [hidx] at hP
          push_cast at hP hQ ⊢
          rw [hf, hs]
          set s : ℚ := surv (w + (j + 2))
          set f1 : ℚ := failProb (w + 1) (j + 1)
          set f2 : ℚ := failProb w (j + 2)
          have hn2 : (0 : ℚ) < (w : ℚ) + j + 2 := by positivity
          have hgoal_eq : ((w : ℚ) + 2 + ((j : ℚ) + 2)) *
              (((j : ℚ) + 2) * (s * ((w : ℚ) + j + 3) / ((w : ℚ) + j + 4)) -
                (((j : ℚ) + 2) * f1 + ((w : ℚ) + 2) * f2) / ((w : ℚ) + j + 4))
              = ((j : ℚ) + 2) * ((w : ℚ) + j + 3) * s - ((j : ℚ) + 2) * f1
                - ((w : ℚ) + 2) * f2 := by
            have hn : (0 : ℚ) < (w : ℚ) + j + 4 := by positivity
            field_simp
            ring
          rw [hgoal_eq]
          have hid : ((w : ℚ) + j + 2) *
              (((j : ℚ) + 2) * ((w : ℚ) + j + 3) * s - ((j : ℚ) + 2) * f1 - ((w : ℚ) + 2) * f2)
              = ((j : ℚ) + 2) * (((w : ℚ) + 1 + ((j : ℚ) + 1)) * (((j : ℚ) + 1) * s - f1))
                + ((w : ℚ) + 2) * (((w : ℚ) + ((j : ℚ) + 2)) * (((j : ℚ) + 2) * s - f2)) := by
            ring
          have h1 : ((j : ℚ) + 2) * (((w : ℚ) + 1 + ((j : ℚ) + 1)) * (((j : ℚ) + 1) * s - f1))
              ≤ ((j : ℚ) + 2) * A' := mul_le_mul_of_nonneg_left hP (by positivity)
          have h2 : ((w : ℚ) + 2) * (((w : ℚ) + ((j : ℚ) + 2)) * (((j : ℚ) + 2) * s - f2))
              ≤ ((w : ℚ) + 2) * A := mul_le_mul_of_nonneg_left hQ (by positivity)
          have hfinal : ((w : ℚ) + j + 2) *
              (((j : ℚ) + 2) * ((w : ℚ) + j + 3) * s - ((j : ℚ) + 2) * f1 - ((w : ℚ) + 2) * f2)
              ≤ ((w : ℚ) + j + 2) * A := by
            rw [hid]; nlinarith [h1, h2, hkey]
          exact le_of_mul_le_mul_left hfinal hn2

/-- Packaged two-sided estimate: for each `k` the wolf-win probability equals
`k · surv(population)` up to an additive error `O(1/population)`. -/
theorem failProb_sandwich (k : ℕ) : ∃ A : ℚ, 0 ≤ A ∧ ∀ v : ℕ,
    (k : ℚ) * surv (v + k) - A / ((v : ℚ) + k) ≤ failProb v k ∧
      failProb v k ≤ (k : ℚ) * surv (v + k) := by
  obtain ⟨A, hA0, -, hA⟩ := failProb_ge_union_error k
  refine ⟨A, hA0, fun v => ⟨?_, failProb_le_union v k⟩⟩
  rcases Nat.eq_zero_or_pos (v + k) with h | h
  · have hv : v = 0 := by omega
    have hk : k = 0 := by omega
    subst hv; subst hk; simp
  · have hpos : (0 : ℚ) < (v : ℚ) + k := by
      have : (0 : ℚ) < ((v + k : ℕ) : ℚ) := by exact_mod_cast h
      push_cast at this; exact this
    have hdiv : (k : ℚ) * surv (v + k) - failProb v k ≤ A / ((v : ℚ) + k) := by
      rw [le_div_iff₀ hpos]
      nlinarith [hA v]
    linarith

end InfoFreeWerewolf