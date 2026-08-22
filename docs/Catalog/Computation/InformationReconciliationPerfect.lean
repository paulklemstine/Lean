/-
# Perfect reconciliation schemes: when the leakage bound is met exactly

`Computation.InformationReconciliationUniversal` shows that every correct
reconciliation protocol must publish at least `V(n,t) = ∑_{i ≤ t} C(n,i)`
distinguishable transcripts.  A syndrome scheme with `2 ^ m = V(n,t)` — i.e.
one built from a *perfect* code — meets that bound with equality.  This file
proves the structural consequences:

* `Scheme.image_syndrome_ball_eq_univ` — every transcript is explained by an
  error pattern inside the correction radius, so decoding never fails
  (`Scheme.exists_decode`, `Scheme.syndrome_decode`);
* `Scheme.rank_eq_of_perfect` — the parity checks are independent, `rank H = m`,
  so the transcript leaks exactly `m` bits and not fewer;
* `Scheme.leakage_meets_bound` — `V(n,t) * |consistent keys| = 2 ^ n`: the
  worst-case bound `Protocol.exists_residual_le` is attained *for every*
  transcript;
* `Scheme.toProtocol` — the syndrome scheme is an instance of the abstract
  protocol, so the universal bounds apply to it verbatim;
* worked examples: the `[3,1]` repetition scheme and the `[7,4]` Hamming
  scheme, both verified separating by exhaustive kernel computation, both
  leakage-optimal, leaving `1` and `4` secret bits respectively.
-/

import Mathlib
import Computation.InformationReconciliation
import Computation.InformationReconciliationLeakage
import Computation.InformationReconciliationUniversal

open Matrix Finset Module

namespace InformationReconciliation

variable {n m : ℕ} (S : Scheme n m)

/-- A scheme is *perfect* when its transcript length matches the sphere-packing
lower bound exactly: `2 ^ m = ∑_{i ≤ t} C(n,i)`. -/
def Scheme.Perfect : Prop := 2 ^ m = ∑ i ∈ Finset.range (S.t + 1), n.choose i

/-- For a perfect separating scheme every syndrome is the syndrome of an error
pattern inside the correction radius. -/
theorem Scheme.image_syndrome_ball_eq_univ (hS : S.Separating) (hP : S.Perfect) :
    (HammingBallDiscrepancy.ball S.t (0 : Key n)).image S.syndrome = Finset.univ := by
  classical
  refine Finset.eq_univ_of_card _ ?_
  have hinj : Set.InjOn S.syndrome (HammingBallDiscrepancy.ball S.t (0 : Key n)) := by
    intro x hx y hy hxy
    simp only [Finset.mem_coe, HammingBallDiscrepancy.mem_ball, hammingDist_zero_right] at hx hy
    exact Scheme.syndrome_inj_on_ball hS hx hy hxy
  rw [Finset.card_image_of_injOn hinj, HammingBallDiscrepancy.ball_card_formula]
  have : ∑ i ∈ Finset.range (S.t + 1),
      (Fintype.card (Fin n)).choose i * (Fintype.card (ZMod 2) - 1) ^ i
      = ∑ i ∈ Finset.range (S.t + 1), n.choose i :=
    Finset.sum_congr rfl (fun i _ => by simp)
  rw [this, ← hP]
  simp

/-- Decoding a perfect separating scheme never fails. -/
theorem Scheme.exists_decode (hS : S.Separating) (hP : S.Perfect) (s : Synd m) :
    ∃ e : Key n, S.syndrome e = s ∧ hammingNorm e ≤ S.t := by
  classical
  have hs : s ∈ (HammingBallDiscrepancy.ball S.t (0 : Key n)).image S.syndrome := by
    rw [S.image_syndrome_ball_eq_univ hS hP]; exact Finset.mem_univ s
  rw [Finset.mem_image] at hs
  obtain ⟨e, he, hes⟩ := hs
  refine ⟨e, hes, ?_⟩
  simpa [HammingBallDiscrepancy.mem_ball, hammingDist_zero_right] using he

/-- The decoder of a perfect separating scheme always returns a genuine
low-weight explanation of the transcript. -/
theorem Scheme.syndrome_decode (hS : S.Separating) (hP : S.Perfect) (s : Synd m) :
    S.syndrome (S.decode s) = s ∧ hammingNorm (S.decode s) ≤ S.t := by
  have hex := S.exists_decode hS hP s
  rw [Scheme.decode, dif_pos hex]
  exact hex.choose_spec

/-- **Perfect schemes have independent checks.**  If the transcript length meets
the sphere-packing bound then `rank H = m`: every published bit is used. -/
theorem Scheme.rank_eq_of_perfect (hS : S.Separating) (hP : S.Perfect) : S.rank = m := by
  classical
  have himg : (Finset.univ.image S.syndrome) = (Finset.univ : Finset (Synd m)) := by
    refine Finset.eq_univ_of_card _ ?_
    refine le_antisymm (Finset.card_le_univ _) ?_
    have hsub : (HammingBallDiscrepancy.ball S.t (0 : Key n)).image S.syndrome
        ⊆ Finset.univ.image S.syndrome :=
      Finset.image_subset_image (Finset.subset_univ _)
    have := Finset.card_le_card hsub
    rwa [S.image_syndrome_ball_eq_univ hS hP] at this
  have h1 := S.card_image_syndrome
  rw [himg] at h1
  have h2 : (2 : ℕ) ^ m = 2 ^ S.rank := by
    rw [← h1]; simp
  exact (Nat.pow_right_injective (le_refl 2) h2).symm

/-- **The leakage bound is attained.**  For a perfect separating scheme the
number of keys consistent with any transcript is exactly `2 ^ n / V(n,t)`. -/
theorem Scheme.leakage_meets_bound (hS : S.Separating) (hP : S.Perfect) (a : Key n) :
    (∑ i ∈ Finset.range (S.t + 1), n.choose i) *
      (S.consistent (S.transcript a)).card = 2 ^ n := by
  have hrank := S.rank_eq_of_perfect hS hP
  have hmn : m ≤ n := by have := S.rank_le_dim; omega
  rw [← hP, S.card_consistent a, hrank, ← pow_add]
  congr 1
  omega

/-- The residual key of a perfect scheme is exactly `n - m` bits long. -/
theorem Scheme.card_consistent_perfect (hS : S.Separating) (hP : S.Perfect) (a : Key n) :
    (S.consistent (S.transcript a)).card = 2 ^ (n - m) := by
  rw [S.card_consistent a, S.rank_eq_of_perfect hS hP]

/-! ### The syndrome scheme as an abstract protocol -/

/-- A separating syndrome scheme is an instance of the abstract (interactive)
protocol model, with transcript alphabet `Synd m`. -/
noncomputable def Scheme.toProtocol (hS : S.Separating) : Protocol n (Synd m) where
  transcript a _ := S.transcript a
  reconstruct b s := S.correct b s
  t := S.t
  correct _ _ h := Scheme.correct_transcript hS h

@[simp] lemma Scheme.toProtocol_t (hS : S.Separating) : (S.toProtocol hS).t = S.t := rfl

/-- The sphere-packing leakage bound for syndrome schemes is a special case of
the protocol-independent bound. -/
theorem Scheme.sphere_packing_of_universal (hS : S.Separating) :
    ∑ i ∈ Finset.range (S.t + 1), n.choose i ≤ 2 ^ m := by
  have h := (S.toProtocol hS).ball_card_le_card_transcript
  rw [Scheme.toProtocol_t] at h
  simpa using h

/-! ### Worked example: the `[3,1]` repetition scheme -/

/-- Parity checks `x₀ + x₁` and `x₁ + x₂` of the three-bit repetition code. -/
def repScheme : Scheme 3 2 := ⟨!![1, 1, 0; 0, 1, 1], 1⟩

theorem repScheme_separating : repScheme.Separating := by
  show ∀ c : Key 3, repScheme.syndrome c = 0 → c ≠ 0 → 2 * repScheme.t < hammingNorm c
  decide

theorem repScheme_perfect : repScheme.Perfect := by
  show (2 : ℕ) ^ 2 = ∑ i ∈ Finset.range 2, (3 : ℕ).choose i
  decide

/-- The repetition transcript leaks exactly its two bits. -/
theorem repScheme_rank : repScheme.rank = 2 :=
  repScheme.rank_eq_of_perfect repScheme_separating repScheme_perfect

/-- One secret bit survives reconciliation of a three-bit key. -/
theorem repScheme_residual (a : Key 3) :
    (repScheme.consistent (repScheme.transcript a)).card = 2 :=
  repScheme.card_consistent_perfect repScheme_separating repScheme_perfect a

/-- Concrete correctness: Bob's `(1,0,1)` is repaired to Alice's `(1,1,1)`. -/
theorem repScheme_correct_example :
    repScheme.correct ![1, 0, 1] (repScheme.transcript ![1, 1, 1]) = ![1, 1, 1] := by
  refine Scheme.correct_transcript repScheme_separating ?_
  show hammingNorm (![(1 : ZMod 2), 1, 1] - ![(1 : ZMod 2), 0, 1]) ≤ 1
  decide

/-! ### Worked example: the `[7,4]` Hamming scheme -/

set_option maxRecDepth 40000 in
/-- The classical `[7,4]` Hamming parity-check matrix, columns in binary order. -/
def hamScheme : Scheme 7 3 :=
  ⟨!![1, 0, 1, 0, 1, 0, 1; 0, 1, 1, 0, 0, 1, 1; 0, 0, 0, 1, 1, 1, 1], 1⟩

set_option maxRecDepth 100000 in
theorem hamScheme_separating : hamScheme.Separating := by
  show ∀ c : Key 7, hamScheme.syndrome c = 0 → c ≠ 0 → 2 * hamScheme.t < hammingNorm c
  decide

theorem hamScheme_perfect : hamScheme.Perfect := by
  show (2 : ℕ) ^ 3 = ∑ i ∈ Finset.range 2, (7 : ℕ).choose i
  decide

/-- Three published bits, three bits leaked: no redundancy in the transcript. -/
theorem hamScheme_rank : hamScheme.rank = 3 :=
  hamScheme.rank_eq_of_perfect hamScheme_separating hamScheme_perfect

/-- Reconciling a seven-bit key against a single error leaves exactly `16 = 2 ^ 4`
candidate keys: four secret bits survive, and this is optimal. -/
theorem hamScheme_residual (a : Key 7) :
    (hamScheme.consistent (hamScheme.transcript a)).card = 16 := by
  have := hamScheme.card_consistent_perfect hamScheme_separating hamScheme_perfect a
  simpa using this

/-- The `[7,4]` scheme attains the universal leakage bound: `8 * 16 = 2 ^ 7`. -/
theorem hamScheme_meets_bound (a : Key 7) :
    (∑ i ∈ Finset.range 2, (7 : ℕ).choose i) *
      (hamScheme.consistent (hamScheme.transcript a)).card = 2 ^ 7 :=
  hamScheme.leakage_meets_bound hamScheme_separating hamScheme_perfect a

end InformationReconciliation