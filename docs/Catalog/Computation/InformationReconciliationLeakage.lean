/-
# Explicit leakage accounting for the reconciliation transcript

Continuation of `Computation.InformationReconciliation`.  There we proved that
the public transcript `s = H *ᵥ a` lets Bob reconstruct Alice's key exactly.
Here we account for what that transcript costs in secrecy.

Write `r = rank H` for the rank of the syndrome map (`Scheme.rank`).

* `Scheme.card_consistent` — after seeing the transcript, exactly `2 ^ (n - r)`
  keys remain consistent with it, independently of which transcript occurred;
* `Scheme.leakage_exact` — hence `2 ^ n = 2 ^ r * 2 ^ (n - r)`: the transcript
  leaks *exactly* `r` bits;
* `Scheme.two_pow_le_two_pow_mul_card_consistent` / `Scheme.card_consistent_ge`
  — the leakage is at most the transcript length `m`;
* `Scheme.residual_min_entropy` — the same statement as a min-entropy identity
  `logb 2 |consistent| = n - r ≥ n - m`;
* `Scheme.card_guess_le_rank`, `Scheme.guess_probability_le` — *operational*
  form: any eavesdropper strategy that guesses the key from the transcript
  succeeds on at most `2 ^ r` of the `2 ^ n` keys;
* `Scheme.sphere_packing_leakage` — a converse: a scheme that repairs every
  `t`-bit discrepancy *must* publish at least `log₂ ∑_{i ≤ t} C(n,i)` bits.
  Leakage is therefore not an artefact of the syndrome construction; it is
  forced by correctness.
-/

import Mathlib
import Computation.InformationReconciliation
import Computation.HammingBallVolume

open Matrix Finset Module

namespace InformationReconciliation

variable {n m : ℕ} (S : Scheme n m)

/-- The keys still consistent with a public transcript `s`. -/
noncomputable def Scheme.consistent (s : Synd m) : Finset (Key n) :=
  Finset.univ.filter (fun x => S.syndrome x = s)

/-- The rank of the public syndrome map; the number of bits of the transcript
that are not redundant. -/
noncomputable def Scheme.rank : ℕ := finrank (ZMod 2) (LinearMap.range S.H.mulVecLin)

lemma Scheme.rank_le_length : S.rank ≤ m := by
  have h := Submodule.finrank_le (LinearMap.range S.H.mulVecLin)
  simpa [Scheme.rank] using h

lemma Scheme.rank_le_dim : S.rank ≤ n := by
  have h2 := LinearMap.finrank_range_add_finrank_ker (K := ZMod 2) S.H.mulVecLin
  have h3 : finrank (ZMod 2) (Fin n → ZMod 2) = n := by simp
  simp only [Scheme.rank]
  omega

/-! ### Counting the keys consistent with a transcript -/

/-- The kernel count: `2 ^ (n - r)` keys have the all-zero syndrome. -/
theorem Scheme.card_consistent_zero : (S.consistent 0).card = 2 ^ (n - S.rank) := by
  classical
  haveI : Fintype (LinearMap.ker S.H.mulVecLin) := Fintype.ofFinite _
  have hfil : (S.consistent 0).card = Fintype.card (LinearMap.ker S.H.mulVecLin) := by
    rw [Fintype.card_subtype]
    congr 1
    ext x
    simp [Scheme.consistent, Scheme.syndrome, LinearMap.mem_ker]
  have h1 : Fintype.card (LinearMap.ker S.H.mulVecLin)
      = 2 ^ finrank (ZMod 2) (LinearMap.ker S.H.mulVecLin) := by
    simpa using Module.card_eq_pow_finrank (K := ZMod 2) (V := LinearMap.ker S.H.mulVecLin)
  have h2 := LinearMap.finrank_range_add_finrank_ker (K := ZMod 2) S.H.mulVecLin
  have h3 : finrank (ZMod 2) (Fin n → ZMod 2) = n := by simp
  rw [hfil, h1]
  congr 1
  simp only [Scheme.rank]
  omega

/-- Every nonempty fiber of the syndrome map is a coset of the kernel, hence has
the same size. -/
theorem Scheme.card_consistent_transcript (a : Key n) :
    (S.consistent (S.transcript a)).card = (S.consistent 0).card := by
  classical
  refine Finset.card_nbij' (fun x => x - a) (fun y => y + a) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [Scheme.consistent, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ,
      true_and] at hx ⊢
    rw [Scheme.syndrome_sub, hx]
    simp [Scheme.transcript]
  · intro y hy
    simp only [Scheme.consistent, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ,
      true_and] at hy ⊢
    rw [Scheme.syndrome_add, hy]
    simp [Scheme.transcript]
  · intro x _; ring
  · intro y _; ring

/-- **Residual key space.**  Whatever the transcript, exactly `2 ^ (n - rank H)`
keys remain consistent with it. -/
theorem Scheme.card_consistent (a : Key n) :
    (S.consistent (S.transcript a)).card = 2 ^ (n - S.rank) := by
  rw [S.card_consistent_transcript a, S.card_consistent_zero]

/-- **Exact leakage accounting.**  The `2 ^ n` a-priori keys split into `2 ^ r`
transcript classes of `2 ^ (n - r)` keys each: the transcript reveals exactly
`r = rank H` bits about Alice's key. -/
theorem Scheme.leakage_exact (a : Key n) :
    2 ^ n = 2 ^ S.rank * (S.consistent (S.transcript a)).card := by
  rw [S.card_consistent a, ← pow_add]
  congr 1
  have := S.rank_le_dim
  omega

/-- The leakage never exceeds the transcript length `m`. -/
theorem Scheme.two_pow_le_two_pow_mul_card_consistent (a : Key n) :
    2 ^ n ≤ 2 ^ m * (S.consistent (S.transcript a)).card := by
  rw [S.leakage_exact a]
  exact Nat.mul_le_mul_right _ (Nat.pow_le_pow_right (by norm_num) S.rank_le_length)

/-- At least `2 ^ (n - m)` keys survive the transcript. -/
theorem Scheme.card_consistent_ge (a : Key n) :
    2 ^ (n - m) ≤ (S.consistent (S.transcript a)).card := by
  rw [S.card_consistent a]
  exact Nat.pow_le_pow_right (by norm_num) (Nat.sub_le_sub_left S.rank_le_length n)

/-! ### Min-entropy form -/

/-- **Residual min-entropy.**  Conditioned on the transcript, the key is uniform
on a set of `2 ^ (n - r)` strings, so its min-entropy is exactly `n - r` bits,
and at least `n - m`. -/
theorem Scheme.residual_min_entropy (a : Key n) :
    Real.logb 2 ((S.consistent (S.transcript a)).card : ℝ) = (n : ℝ) - S.rank := by
  have hle := S.rank_le_dim
  rw [S.card_consistent a]
  push_cast
  rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num), mul_one, Nat.cast_sub hle]

theorem Scheme.residual_min_entropy_ge (a : Key n) :
    (n : ℝ) - m ≤ Real.logb 2 ((S.consistent (S.transcript a)).card : ℝ) := by
  rw [S.residual_min_entropy a]
  have : (S.rank : ℝ) ≤ m := by exact_mod_cast S.rank_le_length
  linarith

/-! ### Operational form: guessing the key from the transcript -/

/-- The number of distinct transcripts that can actually occur is `2 ^ r`. -/
theorem Scheme.card_image_syndrome :
    (Finset.univ.image S.syndrome).card = 2 ^ S.rank := by
  classical
  haveI : Fintype (LinearMap.range S.H.mulVecLin) := Fintype.ofFinite _
  have h1 : Fintype.card (LinearMap.range S.H.mulVecLin)
      = 2 ^ finrank (ZMod 2) (LinearMap.range S.H.mulVecLin) := by
    simpa using Module.card_eq_pow_finrank (K := ZMod 2) (V := LinearMap.range S.H.mulVecLin)
  have h2 : Fintype.card (LinearMap.range S.H.mulVecLin)
      = (Finset.univ.image S.syndrome).card := by
    rw [Fintype.card_subtype]
    congr 1
    ext y
    simp [LinearMap.mem_range, Scheme.syndrome, eq_comm]
  rw [← h2, h1, Scheme.rank]

/-- **Guessing bound.**  Any eavesdropper strategy `g` that outputs a key from
the transcript alone is correct for at most `2 ^ r` of the `2 ^ n` keys. -/
theorem Scheme.card_guess_le_rank (g : Synd m → Key n) :
    (Finset.univ.filter (fun a : Key n => g (S.transcript a) = a)).card ≤ 2 ^ S.rank := by
  classical
  rw [← S.card_image_syndrome]
  refine Finset.card_le_card_of_injOn S.syndrome (fun a _ => by simp) ?_
  intro a ha b hb hab
  simp only [Finset.coe_filter, Set.mem_setOf_eq] at ha hb
  rw [← ha.2, ← hb.2]
  simp only [Scheme.transcript]
  rw [hab]

/-- The same bound with the raw transcript length. -/
theorem Scheme.card_guess_le (g : Synd m → Key n) :
    (Finset.univ.filter (fun a : Key n => g (S.transcript a) = a)).card ≤ 2 ^ m :=
  le_trans (S.card_guess_le_rank g) (Nat.pow_le_pow_right (by norm_num) S.rank_le_length)

/-- **Guessing probability.**  For a uniformly random key the eavesdropper's
success probability is at most `2 ^ r / 2 ^ n = 2 ^ (r - n)`. -/
theorem Scheme.guess_probability_le (g : Synd m → Key n) :
    ((Finset.univ.filter (fun a : Key n => g (S.transcript a) = a)).card : ℝ) / 2 ^ n
      ≤ (2 : ℝ) ^ S.rank / 2 ^ n := by
  have h : ((Finset.univ.filter (fun a : Key n => g (S.transcript a) = a)).card : ℝ)
      ≤ (2 : ℝ) ^ S.rank := by exact_mod_cast S.card_guess_le_rank g
  gcongr

/-! ### A converse: correctness forces leakage -/

/-- **Sphere-packing leakage bound.**  If the scheme repairs every discrepancy
of weight at most `t`, then the transcript must be long enough to name every
error pattern: `∑_{i ≤ t} C(n,i) ≤ 2 ^ m`.  No reconciliation protocol of this
shape can be cheaper. -/
theorem Scheme.sphere_packing_leakage (hS : S.Separating) :
    ∑ i ∈ Finset.range (S.t + 1), n.choose i ≤ 2 ^ m := by
  classical
  have hcard : (HammingBallDiscrepancy.ball S.t (0 : Key n)).card
      = ∑ i ∈ Finset.range (S.t + 1), n.choose i := by
    rw [HammingBallDiscrepancy.ball_card_formula]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    simp
  have hmem : ∀ x ∈ HammingBallDiscrepancy.ball S.t (0 : Key n), S.syndrome x ∈ (Finset.univ : Finset (Synd m)) :=
    fun _ _ => Finset.mem_univ _
  have hinj : Set.InjOn S.syndrome (HammingBallDiscrepancy.ball S.t (0 : Key n)) := by
    intro x hx y hy hxy
    simp only [Finset.mem_coe, HammingBallDiscrepancy.mem_ball, hammingDist_zero_right] at hx hy
    exact Scheme.syndrome_inj_on_ball hS hx hy hxy
  have := Finset.card_le_card_of_injOn S.syndrome hmem hinj
  rw [hcard] at this
  simpa using this

/-- With `t = 1` the bound reads `n + 1 ≤ 2 ^ m`: repairing a single bit flip in
an `n`-bit key costs at least `log₂ (n+1)` public bits. -/
theorem Scheme.single_error_leakage (hS : S.Separating) (ht : S.t = 1) :
    n + 1 ≤ 2 ^ m := by
  have h := S.sphere_packing_leakage hS
  rw [ht] at h
  simpa [Finset.sum_range_succ, add_comm] using h

end InformationReconciliation