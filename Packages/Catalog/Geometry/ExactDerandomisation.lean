/-
# Cycle 3: exact derandomisation — the best fixed codebook, exactly

Research thread *Compression Beyond the Pigeonhole Bound*, cycle v19c (third loop).

`AlmostLossless.exists_good_codebook` derandomises the random-coding argument by
averaging the *union bound*: some fixed codebook loses at most `|S|(|S|-1)/M`
typical strings.  That statement is vacuous as soon as `|S| - 1 ≥ M`, precisely
the regime where compression is interesting.  Cycles 1–2 replaced the union
bound by the **exact** failure law
`ExactFailure.card_failSet_exact`; averaging *that* instead gives a
derandomisation statement that is never vacuous.

Main results.

* `ExactDerandomisation.exists_good_codebook_exact` — some fixed codebook `H`
  satisfies `M^k · |bad(H)| ≤ |S| · (M^k - (M-1)^k)` with `k = |S| - 1`, i.e. it
  loses at most a `1-(1-1/M)^k` fraction of the typical set.  This is `< |S|`
  for every `M ≥ 2`, however large `S` is.
* `ExactDerandomisation.good_codebook_fraction` — the real-valued form
  `|bad(H)| / |S| ≤ 1 - (1-1/M)^{|S|-1}`.
* `ExactDerandomisation.pow_sub_pow_le` — `M^k - (M-1)^k ≤ k·M^{k-1}`, the
  integer inequality showing the exact bound **implies** the union-bound estimate
  of `AlmostLossless.exists_good_codebook` and is therefore never worse.
-/
import Geometry.ExactFailureMarginal

namespace ExactDerandomisation

open Finset AlmostLossless

variable {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}

/-! ## 1. The averaging step with the exact marginal -/

/-- Double counting the incidences `(H, x)` with `x` lost by `H`, weighted by the
exact failure count of each `x ∈ S`. -/
theorem sum_card_badStrings (S : Finset α) :
    ∑ H : α → Fin M, (badStrings S H).card = ∑ x ∈ S, (failSet S x M).card := by
  classical
  simp only [badStrings, failSet, Finset.card_filter]
  rw [Finset.sum_comm]

/-- **Exact derandomisation.**  With `k = |S| - 1` competitors, some fixed
codebook loses at most a `1 - (1-1/M)^k` fraction of the typical set:
`M^k · |bad(H)| ≤ |S| · (M^k - (M-1)^k)`.  Unlike
`AlmostLossless.exists_good_codebook` this is informative for every `|S|`. -/
theorem exists_good_codebook_exact (S : Finset α) (hM : 0 < M) :
    ∃ H : α → Fin M,
      M ^ (S.card - 1) * (badStrings S H).card
        ≤ S.card * (M ^ (S.card - 1) - (M - 1) ^ (S.card - 1)) := by
  classical
  set k := S.card - 1 with hk
  set N := M ^ Fintype.card α with hN
  set f : (α → Fin M) → ℕ := fun H => (badStrings S H).card with hf
  have hNpos : 0 < N := pow_pos hM _
  -- exact failure count for each `x ∈ S`
  have hx_exact : ∀ x ∈ S, M ^ k * (failSet S x M).card = N * (M ^ k - (M - 1) ^ k) := by
    intro x hx
    have hcard : (S.erase x).card = k := by
      rw [Finset.card_erase_of_mem hx, hk]
    have h := ExactFailure.card_failSet_exact (M := M) S x
    rw [hcard, ← hN] at h
    have hmono : (M - 1) ^ k ≤ M ^ k := Nat.pow_le_pow_left (by omega) k
    have h2 : N * (M ^ k - (M - 1) ^ k) = M ^ k * N - (M - 1) ^ k * N := by
      rw [Nat.mul_sub, mul_comm N (M ^ k), mul_comm N ((M - 1) ^ k)]
    rw [h2]
    omega
  -- sum over the typical set
  have hsum : M ^ k * ∑ H : α → Fin M, f H = S.card * (N * (M ^ k - (M - 1) ^ k)) := by
    rw [sum_card_badStrings S, Finset.mul_sum, Finset.sum_congr rfl hx_exact,
      Finset.sum_const, smul_eq_mul]
  -- pick the best codebook
  obtain ⟨H₀, -, hmin⟩ :=
    Finset.exists_min_image (univ : Finset (α → Fin M)) f ⟨fun _ => ⟨0, hM⟩, mem_univ _⟩
  have hbest : N * f H₀ ≤ ∑ H : α → Fin M, f H := by
    have h : ∑ _H : α → Fin M, f H₀ ≤ ∑ H : α → Fin M, f H :=
      Finset.sum_le_sum (fun H _ => hmin H (mem_univ H))
    rwa [Finset.sum_const, smul_eq_mul, Finset.card_univ, card_codebooks] at h
  refine ⟨H₀, ?_⟩
  have key : N * (M ^ k * f H₀) ≤ N * (S.card * (M ^ k - (M - 1) ^ k)) := by
    calc N * (M ^ k * f H₀) = M ^ k * (N * f H₀) := by ring
      _ ≤ M ^ k * ∑ H : α → Fin M, f H := Nat.mul_le_mul_left _ hbest
      _ = S.card * (N * (M ^ k - (M - 1) ^ k)) := hsum
      _ = N * (S.card * (M ^ k - (M - 1) ^ k)) := by ring
  exact Nat.le_of_mul_le_mul_left key hNpos

/-- Real-valued form: some fixed codebook loses at most a
`1 - (1 - 1/M)^{|S|-1}` fraction of the typical set. -/
theorem good_codebook_fraction (S : Finset α) (hM : 0 < M) (hS : S.Nonempty) :
    ∃ H : α → Fin M,
      ((badStrings S H).card : ℝ) / S.card ≤ 1 - (1 - 1 / (M : ℝ)) ^ (S.card - 1) := by
  classical
  obtain ⟨H₀, hH₀⟩ := exists_good_codebook_exact (M := M) S hM
  refine ⟨H₀, ?_⟩
  set k := S.card - 1 with hk
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hScard : (0 : ℝ) < S.card := by
    have : 0 < S.card := Finset.card_pos.2 hS
    exact_mod_cast this
  have hmono : (M - 1) ^ k ≤ M ^ k := Nat.pow_le_pow_left (by omega) k
  have hsub : ((M - 1 : ℕ) : ℝ) = (M : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ M := hM
    push_cast [Nat.cast_sub h1]; ring
  have hcast : (M : ℝ) ^ k * (badStrings S H₀).card
      ≤ (S.card : ℝ) * ((M : ℝ) ^ k - ((M : ℝ) - 1) ^ k) := by
    have h := (Nat.cast_le (α := ℝ)).2 hH₀
    push_cast [Nat.cast_sub hmono, hsub] at h
    linarith
  have hMk : (0 : ℝ) < (M : ℝ) ^ k := by positivity
  have hone : (1 : ℝ) - 1 / (M : ℝ) = ((M : ℝ) - 1) / (M : ℝ) := by field_simp
  rw [hone, div_pow, div_le_iff₀ hScard, ← sub_nonneg]
  have expand : (1 - ((M : ℝ) - 1) ^ k / (M : ℝ) ^ k) * S.card - (badStrings S H₀).card
      = ((S.card : ℝ) * ((M : ℝ) ^ k - ((M : ℝ) - 1) ^ k)
          - (M : ℝ) ^ k * (badStrings S H₀).card) / (M : ℝ) ^ k := by
    field_simp
  rw [expand]
  apply div_nonneg _ hMk.le
  linarith [hcast]

/-! ## 2. The exact bound is never worse than the union bound -/

/-- **Integer Bernoulli inequality**: `M^k ≤ (M-1)^k + k·M^{k-1}`, equivalently
`M^k - (M-1)^k ≤ k·M^{k-1}`.  Dividing by `M^k`, this says
`1 - (1-1/M)^k ≤ k/M`: the exact derandomisation bound of
`exists_good_codebook_exact` always implies the union-bound estimate of
`AlmostLossless.exists_good_codebook`. -/
theorem pow_sub_pow_le (M k : ℕ) : M ^ k ≤ (M - 1) ^ k + k * M ^ (k - 1) := by
  induction k with
  | zero => simp
  | succ n ih =>
      have hstep : M * (M - 1) ^ n + n * M ^ n
          ≤ (M - 1) ^ (n + 1) + (n + 1) * M ^ n := by
        have hle : (M - 1) ^ n ≤ M ^ n := Nat.pow_le_pow_left (by omega) n
        cases M with
        | zero =>
            simp
            exact Nat.mul_le_mul (Nat.le_succ n) (le_refl _)
        | succ m =>
            simp only [Nat.succ_sub_one, pow_succ] at *
            nlinarith
      have hMn : M * (n * M ^ (n - 1)) ≤ n * M ^ n := by
        cases n with
        | zero => simp
        | succ j =>
            simp only [Nat.succ_sub_one, pow_succ]
            nlinarith
      calc M ^ (n + 1) = M * M ^ n := by ring
        _ ≤ M * ((M - 1) ^ n + n * M ^ (n - 1)) := Nat.mul_le_mul_left _ ih
        _ = M * (M - 1) ^ n + M * (n * M ^ (n - 1)) := by ring
        _ ≤ M * (M - 1) ^ n + n * M ^ n := Nat.add_le_add_left hMn _
        _ ≤ (M - 1) ^ (n + 1) + (n + 1) * M ^ n := hstep
        _ = (M - 1) ^ (n + 1) + (n + 1) * M ^ (n + 1 - 1) := by simp

end ExactDerandomisation