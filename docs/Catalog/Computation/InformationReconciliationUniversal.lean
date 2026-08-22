/-
# Universal (protocol-independent) leakage bounds for information reconciliation

`Computation.InformationReconciliationLeakage` analysed the *syndrome* protocol.
One may object that its leakage is an artefact of linearity: perhaps a cleverer,
interactive, adaptive, nonlinear protocol reconciles `t` discrepancies while
publishing far less.  This file rules that out.

We model a protocol abstractly: a transcript map `τ : Key n → Key n → T`
producing the public transcript of the run on inputs `(a, b)` (it may depend on
both parties, hence covers arbitrary interaction), together with Bob's
reconstruction `R : Key n → T → Key n`, subject only to correctness on
`t`-close inputs.

* `Protocol.transcript_injOn_ball` — the transcript, with Bob's input frozen at
  `0`, is injective on the Hamming ball of radius `t`;
* `Protocol.ball_card_le_card_transcript` — hence the transcript alphabet has at
  least `∑_{i ≤ t} C(n,i)` elements: correctness *forces* leakage;
* `Protocol.exists_residual_le` — quantitatively, on some input the transcript
  cuts the adversary's candidate set down to at most `2 ^ n / V(n,t)` keys;
* `exists_large_fiber` — conversely, a transcript taking `N` values always
  leaves some candidate set of size at least `2 ^ n / N`, and this composes with
  arbitrary extra side information (`exists_large_fiber_pair`).
-/

import Mathlib
import Computation.InformationReconciliation
import Computation.HammingBallVolume

open Finset

namespace InformationReconciliation

/-- An abstract reconciliation protocol with transcript alphabet `T`: the public
transcript may depend on both parties' strings (so interaction and adaptivity
are allowed), Bob reconstructs from his own string and the transcript, and the
protocol is correct whenever the two strings differ in at most `t` places. -/
structure Protocol (n : ℕ) (T : Type*) where
  /-- The public transcript produced by a run on inputs `(a, b)`. -/
  transcript : Key n → Key n → T
  /-- Bob's reconstruction of Alice's string. -/
  reconstruct : Key n → T → Key n
  /-- The advertised correction radius. -/
  t : ℕ
  /-- Correctness on `t`-close inputs. -/
  correct : ∀ a b : Key n, hammingNorm (a - b) ≤ t → reconstruct b (transcript a b) = a

namespace Protocol

variable {n : ℕ} {T : Type*} (P : Protocol n T)

/-- Freezing Bob's string at `0`, the transcript determines Alice's string on
the ball of radius `t`; in particular it is injective there. -/
theorem transcript_injOn_ball :
    Set.InjOn (fun a => P.transcript a 0)
      (HammingBallDiscrepancy.ball P.t (0 : Key n) : Finset (Key n)) := by
  intro x hx y hy hxy
  simp only [Finset.mem_coe, HammingBallDiscrepancy.mem_ball, hammingDist_zero_right] at hx hy
  have hx' : P.reconstruct 0 (P.transcript x 0) = x := P.correct x 0 (by simpa using hx)
  have hy' : P.reconstruct 0 (P.transcript y 0) = y := P.correct y 0 (by simpa using hy)
  rw [← hx', ← hy']
  simp only at hxy
  rw [hxy]

/-- **Universal leakage bound.**  Any correct reconciliation protocol — linear
or not, one-shot or interactive — has a transcript alphabet of size at least
the Hamming ball volume `∑_{i ≤ t} C(n,i)`. -/
theorem ball_card_le_card_transcript [Fintype T] [DecidableEq T] :
    ∑ i ∈ Finset.range (P.t + 1), n.choose i ≤ Fintype.card T := by
  classical
  have hcard : (HammingBallDiscrepancy.ball P.t (0 : Key n)).card
      = ∑ i ∈ Finset.range (P.t + 1), n.choose i := by
    rw [HammingBallDiscrepancy.ball_card_formula]
    exact Finset.sum_congr rfl (fun i _ => by simp)
  have h := Finset.card_le_card_of_injOn (fun a => P.transcript a 0)
    (fun x _ => Finset.mem_univ (P.transcript x 0)) P.transcript_injOn_ball
  rw [hcard] at h
  simpa using h

/-- In bit terms: a protocol correcting a single discrepancy in an `n`-bit
string must publish at least `log₂ (n + 1)` bits. -/
theorem card_transcript_ge_of_t_eq_one [Fintype T] [DecidableEq T] (ht : P.t = 1) :
    n + 1 ≤ Fintype.card T := by
  have h := P.ball_card_le_card_transcript
  rw [ht] at h
  simpa [Finset.sum_range_succ, add_comm] using h

/-- Real-valued form: the transcript carries at least `log₂ V(n,t)` bits. -/
theorem logb_card_transcript_ge [Fintype T] [DecidableEq T] :
    Real.logb 2 (∑ i ∈ Finset.range (P.t + 1), n.choose i : ℕ)
      ≤ Real.logb 2 (Fintype.card T) := by
  have h : ((∑ i ∈ Finset.range (P.t + 1), n.choose i : ℕ) : ℝ) ≤ (Fintype.card T : ℝ) := by
    exact_mod_cast P.ball_card_le_card_transcript
  have hpos : (0 : ℝ) < ((∑ i ∈ Finset.range (P.t + 1), n.choose i : ℕ) : ℝ) := by
    have : 0 < ∑ i ∈ Finset.range (P.t + 1), n.choose i := by
      refine Finset.sum_pos' (fun i _ => Nat.zero_le _) ⟨0, by simp⟩
    exact_mod_cast this
  exact Real.logb_le_logb_of_le (by norm_num) hpos h

end Protocol

/-! ### Pigeonhole: what a short transcript cannot reveal -/

/-- **Pigeonhole privacy bound.**  If the public data is any function of the key
taking values in a finite set `F`, some value leaves at least `2 ^ n / |F|` keys
consistent with it. -/
theorem exists_large_fiber {n : ℕ} {F : Type*} [Fintype F] [DecidableEq F]
    (f : Key n → F) :
    ∃ y : F, 2 ^ n ≤ Fintype.card F * (Finset.univ.filter (fun x : Key n => f x = y)).card := by
  classical
  by_contra hcon
  push_neg at hcon
  have hne : (Finset.univ : Finset F).Nonempty := ⟨f 0, Finset.mem_univ _⟩
  have hsum : ∑ y : F, (Finset.univ.filter (fun x : Key n => f x = y)).card = 2 ^ n := by
    rw [← Finset.card_eq_sum_card_fiberwise (f := f) (fun x _ => Finset.mem_univ (f x))]
    simp
  have hlt : ∑ _y : F, Fintype.card F * (Finset.univ.filter (fun x : Key n => f x = _y)).card
      < ∑ _y : F, 2 ^ n :=
    Finset.sum_lt_sum_of_nonempty hne (fun y _ => hcon y)
  rw [← Finset.mul_sum, hsum, Finset.sum_const, Finset.card_univ, smul_eq_mul] at hlt
  omega

/-- The same bound in the presence of arbitrary extra side information: a
transcript in `F` together with side information in `G` still leaves at least
`2 ^ n / (|F| * |G|)` candidate keys for some pair of values.  Leakage from
independent public data is additive in bits. -/
theorem exists_large_fiber_pair {n : ℕ} {F G : Type*} [Fintype F] [DecidableEq F]
    [Fintype G] [DecidableEq G] (f : Key n → F) (g : Key n → G) :
    ∃ (y : F) (z : G), 2 ^ n ≤ Fintype.card F * Fintype.card G *
      (Finset.univ.filter (fun x : Key n => f x = y ∧ g x = z)).card := by
  classical
  obtain ⟨p, hp⟩ := exists_large_fiber (fun x : Key n => (f x, g x))
  refine ⟨p.1, p.2, ?_⟩
  rw [← Fintype.card_prod]
  refine le_trans hp (Nat.mul_le_mul_left _ (Finset.card_le_card ?_))
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Prod.ext_iff] at hx ⊢
  exact hx

/-! ### The worst case: correctness really costs privacy -/

/-- **Worst-case leakage.**  For every correct protocol there is an input on
which the transcript narrows the adversary's candidate set to at most
`2 ^ n / V(n,t)` keys: the leakage predicted by the sphere-packing bound is
actually incurred, for interactive protocols as well as linear ones. -/
theorem Protocol.exists_residual_le {n : ℕ} {T : Type*} [Fintype T] [DecidableEq T]
    (P : Protocol n T) :
    ∃ a : Key n, hammingNorm a ≤ P.t ∧
      (∑ i ∈ Finset.range (P.t + 1), n.choose i) *
        (Finset.univ.filter (fun x : Key n => P.transcript x 0 = P.transcript a 0)).card
        ≤ 2 ^ n := by
  classical
  set B := HammingBallDiscrepancy.ball P.t (0 : Key n) with hB
  set cnt : Key n → ℕ :=
    fun a => (Finset.univ.filter (fun x : Key n => P.transcript x 0 = P.transcript a 0)).card
      with hcnt
  have hBmem : ∀ a, a ∈ B ↔ hammingNorm a ≤ P.t := by
    intro a
    simp [hB, HammingBallDiscrepancy.mem_ball, hammingDist_zero_right]
  have hBne : B.Nonempty := ⟨0, (hBmem 0).2 (by simp)⟩
  have hBcard : B.card = ∑ i ∈ Finset.range (P.t + 1), n.choose i := by
    rw [hB, HammingBallDiscrepancy.ball_card_formula]
    exact Finset.sum_congr rfl (fun i _ => by simp)
  obtain ⟨a, haB, hmin⟩ := B.exists_min_image cnt hBne
  refine ⟨a, (hBmem a).1 haB, ?_⟩
  have hdisj : ∀ b ∈ B, ∀ b' ∈ B, b ≠ b' →
      Disjoint (Finset.univ.filter (fun x : Key n => P.transcript x 0 = P.transcript b 0))
        (Finset.univ.filter (fun x : Key n => P.transcript x 0 = P.transcript b' 0)) := by
    intro b hb b' hb' hne
    simp only [Finset.disjoint_left, Finset.mem_filter, Finset.mem_univ, true_and]
    intro x hx hx'
    exact hne (P.transcript_injOn_ball hb hb'
      (show P.transcript b 0 = P.transcript b' 0 by rw [← hx, hx']))
  have hsum : ∑ b ∈ B, cnt b ≤ 2 ^ n := by
    have hbi : ∑ b ∈ B, cnt b
        = (B.biUnion
            (fun b => Finset.univ.filter (fun x : Key n => P.transcript x 0 = P.transcript b 0))).card :=
      (Finset.card_biUnion hdisj).symm
    rw [hbi]
    calc _ ≤ (Finset.univ : Finset (Key n)).card := Finset.card_le_univ _
      _ = 2 ^ n := by simp
  have hlow : B.card * cnt a ≤ ∑ b ∈ B, cnt b := by
    have := Finset.card_nsmul_le_sum B cnt (cnt a) (fun b hb => hmin b hb)
    simpa [smul_eq_mul] using this
  rw [← hBcard]
  exact le_trans hlow hsum

end InformationReconciliation