import MachineLearning.QRResidual.MeanDial

/-!
# The exact distribution of the footprint dial over a period of moduli

The dial `Σ_{QR p} 2/p` is a sum of per-prime indicators.  This file computes the *exact
joint law* of those indicators as `N` runs over one full period `P = ∏_{p ≤ B} p`: the
quadratic-residue indicators at distinct primes are **exactly independent**, with
`(p+1)/2` favourable residues out of `p` at each prime (the `(p-1)/2` nonzero squares plus
the ramified residue `0`).

Main results.

* `crt_count` — a general Chinese-remainder counting theorem: for a pairwise coprime
  family, the number of residues in one period satisfying a prescribed local condition at
  every modulus is the *product* of the local counts.
* `card_qr_pattern` — **the exact law of the dial**: for every subset `T` of the factor
  base, the number of `N < P` whose QR pattern is exactly `T` equals
  `∏_{p ∈ T} (p+1)/2 · ∏_{p ∉ T} (p-1)/2`.
* `card_qr_joint` — the marginal/joint version: `#{N < P : N is a QR mod every p ∈ T}`
  factorises as `∏_{p ∈ T} (p+1)/2 · ∏_{p ∉ T} p`.
* `card_qr_pattern_pos` — every pattern occurs, so the dial really attains all `2^{|base|}`
  values inside a single period (a quantitative refinement of `qrWeight_full_range`).
-/

namespace QRResidual

open Finset

/-! ## A general Chinese-remainder counting theorem -/

/-- **CRT counting.**  For a pairwise coprime family of moduli, the number of residues in
one period `∏ a i` obeying a prescribed local condition at *every* modulus is exactly the
product of the local counts.  Local conditions at coprime moduli are independent. -/
theorem crt_count {ι : Type*} [Fintype ι] [DecidableEq ι] (a : ι → ℕ) [∀ i, NeZero (a i)]
    (hcop : Pairwise (Function.onFun Nat.Coprime a))
    (Q : ∀ i, ZMod (a i) → Prop) [∀ i, DecidablePred (Q i)] :
    ((range (∏ i, a i)).filter (fun N : ℕ => ∀ i, Q i (N : ZMod (a i)))).card
      = ∏ i, (univ.filter (Q i)).card := by
  classical
  set M := ∏ i, a i with hM
  haveI : NeZero M := ⟨by
    have : 0 < M := Finset.prod_pos fun i _ => Nat.pos_of_ne_zero (NeZero.ne (a i))
    omega⟩
  set e := ZMod.prodEquivPi a hcop with he
  have hcomp : ∀ (N : ℕ) (i : ι), e ((N : ℕ) : ZMod M) i = ((N : ℕ) : ZMod (a i)) := by
    intro N i
    simp
  have step1 : ((range M).filter (fun N : ℕ => ∀ i, Q i (N : ZMod (a i)))).card
      = (univ.filter (fun z : ZMod M => ∀ i, Q i (e z i))).card := by
    apply Finset.card_bij' (fun N _ => ((N : ℕ) : ZMod M)) (fun z _ => z.val)
    · intro N hN
      simp only [mem_filter, mem_range] at hN ⊢
      exact ⟨mem_univ _, fun i => by rw [hcomp]; exact hN.2 i⟩
    · intro z hz
      simp only [mem_filter, mem_univ, true_and] at hz
      simp only [mem_filter, mem_range]
      refine ⟨ZMod.val_lt z, fun i => ?_⟩
      have h1 : ((z.val : ℕ) : ZMod M) = z := by simp [ZMod.natCast_val]
      have h2 := hcomp z.val i
      rw [h1] at h2
      rw [← h2]
      exact hz i
    · intro N hN
      exact ZMod.val_natCast_of_lt (mem_range.1 (mem_filter.1 hN).1)
    · intro z _; simp [ZMod.natCast_val]
  have step2 : (univ.filter (fun z : ZMod M => ∀ i, Q i (e z i))).card
      = (univ.filter (fun f : ∀ i, ZMod (a i) => ∀ i, Q i (f i))).card := by
    apply Finset.card_bij' (fun z _ => e z) (fun f _ => e.symm f)
    · intro z hz
      simp only [mem_filter, mem_univ, true_and] at hz ⊢
      exact hz
    · intro f hf
      simp only [mem_filter, mem_univ, true_and] at hf ⊢
      intro i; simpa using hf i
    · intro z _; simp
    · intro f _; simp
  have step3 : (univ.filter (fun f : ∀ i, ZMod (a i) => ∀ i, Q i (f i))).card
      = ∏ i, (univ.filter (Q i)).card := by
    rw [show (univ.filter (fun f : ∀ i, ZMod (a i) => ∀ i, Q i (f i)))
        = Fintype.piFinset (fun i => univ.filter (Q i)) by
      ext f; simp [Fintype.mem_piFinset]]
    rw [Fintype.card_piFinset]
  rw [step1, step2, step3]

/-! ## The factor base as an index type -/

/-- Decidable form of "is a square in `ZMod p`". -/
def IsSqMod (p : ℕ) [NeZero p] (x : ZMod p) : Prop := ∃ y : ZMod p, y ^ 2 = x

instance (p : ℕ) [NeZero p] : DecidablePred (IsSqMod p) := by
  unfold IsSqMod; infer_instance

theorem isSqMod_iff_isSquare {p : ℕ} [NeZero p] (x : ZMod p) : IsSqMod p x ↔ IsSquare x := by
  constructor
  · rintro ⟨y, rfl⟩; exact ⟨y, by ring⟩
  · rintro ⟨y, rfl⟩; exact ⟨y, by ring⟩

theorem isQR_iff_isSqMod {p : ℕ} [NeZero p] (N : ℕ) :
    IsQR (N : ℤ) p ↔ IsSqMod p ((N : ℕ) : ZMod p) := by
  rw [isSqMod_iff_isSquare, isQR_iff_isSquare]
  norm_cast

/-- The index type of the odd factor base. -/
def baseIdx (B : ℕ) : Type := {p : ℕ // p ∈ oddFactorBase B}

noncomputable instance (B : ℕ) : Fintype (baseIdx B) := by
  unfold baseIdx; infer_instance

instance (B : ℕ) : DecidableEq (baseIdx B) := by
  unfold baseIdx; infer_instance

/-- The modulus attached to an index of the factor base. -/
def baseMod (B : ℕ) (i : baseIdx B) : ℕ := i.1

theorem baseMod_prime {B : ℕ} (i : baseIdx B) : (baseMod B i).Prime :=
  (mem_oddFactorBase.1 i.2).2.1

theorem baseMod_ne_two {B : ℕ} (i : baseIdx B) : baseMod B i ≠ 2 :=
  (mem_oddFactorBase.1 i.2).2.2

instance (B : ℕ) (i : baseIdx B) : NeZero (baseMod B i) := ⟨(baseMod_prime i).ne_zero⟩

instance (B : ℕ) (i : baseIdx B) : Fact (baseMod B i).Prime := ⟨baseMod_prime i⟩

theorem baseMod_pairwise_coprime (B : ℕ) :
    Pairwise (Function.onFun Nat.Coprime (baseMod B)) := by
  intro i j hij
  have hne : baseMod B i ≠ baseMod B j := fun h => hij (Subtype.ext h)
  exact (Nat.coprime_primes (baseMod_prime i) (baseMod_prime j)).2 hne

theorem prod_baseMod (B : ℕ) : ∏ i : baseIdx B, baseMod B i = basePrimorial B := by
  classical
  rw [basePrimorial]
  exact Finset.prod_coe_sort (oddFactorBase B) (fun p => p)

/-! ## The exact law of the QR pattern -/

/-- **Joint (marginal) count.**  The number of moduli in one period which are quadratic
residues modulo *every* prime of a prescribed subset `T` of the factor base is exactly
`∏_{p ∈ T} (p+1)/2 · ∏_{p ∉ T} p`: the indicators are independent, each with `(p+1)/2`
favourable residues. -/
theorem card_qr_joint (B : ℕ) (T : Finset ℕ) (hT : T ⊆ oddFactorBase B) :
    ((range (basePrimorial B)).filter
        (fun N : ℕ => ∀ p ∈ T, IsQR (N : ℤ) p)).card
      = (∏ p ∈ T, (p + 1) / 2) * (∏ p ∈ (oddFactorBase B) \ T, p) := by
  classical
  set Q : ∀ i : baseIdx B, ZMod (baseMod B i) → Prop :=
    fun i x => (baseMod B i ∈ T) → IsSqMod (baseMod B i) x with hQ
  have hpred : ∀ N : ℕ, (∀ p ∈ T, IsQR (N : ℤ) p)
      ↔ ∀ i : baseIdx B, Q i ((N : ℕ) : ZMod (baseMod B i)) := by
    intro N
    constructor
    · intro h i hi
      exact (isQR_iff_isSqMod (p := baseMod B i) N).1 (h _ hi)
    · intro h p hp
      have hpB : p ∈ oddFactorBase B := hT hp
      haveI : NeZero p := ⟨(mem_oddFactorBase.1 hpB).2.1.ne_zero⟩
      have := h ⟨p, hpB⟩ (by simpa [baseMod] using hp)
      exact (isQR_iff_isSqMod (p := p) N).2 (by simpa [baseMod] using this)
  have hcount := crt_count (baseMod B) (baseMod_pairwise_coprime B) Q
  rw [prod_baseMod] at hcount
  have hleft : ((range (basePrimorial B)).filter
      (fun N : ℕ => ∀ p ∈ T, IsQR (N : ℤ) p)).card
      = ((range (basePrimorial B)).filter
          (fun N : ℕ => ∀ i : baseIdx B, Q i ((N : ℕ) : ZMod (baseMod B i)))).card := by
    congr 1
    exact Finset.filter_congr fun N _ => by simpa using hpred N
  rw [hleft, hcount]
  -- evaluate the local counts
  have hlocal : ∀ i : baseIdx B, (univ.filter (Q i)).card
      = if baseMod B i ∈ T then (baseMod B i + 1) / 2 else baseMod B i := by
    intro i
    by_cases hi : baseMod B i ∈ T
    · have : (univ.filter (Q i)) = univ.filter (fun x => IsSquare x) := by
        refine Finset.filter_congr ?_
        intro x _
        simp only [hQ, hi, forall_true_left, isSqMod_iff_isSquare]
      rw [this, if_pos hi, card_squares_zmod (baseMod B i) (baseMod_ne_two i)]
    · have : (univ.filter (Q i)) = (univ : Finset (ZMod (baseMod B i))) := by
        refine Finset.filter_true_of_mem ?_
        intro x _
        simp [hQ, hi]
      rw [this, if_neg hi, Finset.card_univ, ZMod.card]
  rw [Finset.prod_congr rfl fun i _ => hlocal i]
  -- transport the product from the index type to the factor base
  have hprod : (∏ i : baseIdx B, if baseMod B i ∈ T then (baseMod B i + 1) / 2 else baseMod B i)
      = ∏ p ∈ oddFactorBase B, (if p ∈ T then (p + 1) / 2 else p) := by
    exact Finset.prod_coe_sort (oddFactorBase B) (fun p => if p ∈ T then (p + 1) / 2 else p)
  rw [hprod, ← Finset.prod_sdiff hT]
  have h1 : ∏ p ∈ (oddFactorBase B) \ T, (if p ∈ T then (p + 1) / 2 else p)
      = ∏ p ∈ (oddFactorBase B) \ T, p := by
    refine Finset.prod_congr rfl ?_
    intro p hp
    rw [if_neg (Finset.mem_sdiff.1 hp).2]
  have h2 : ∏ p ∈ T, (if p ∈ T then (p + 1) / 2 else p) = ∏ p ∈ T, (p + 1) / 2 := by
    refine Finset.prod_congr rfl ?_
    intro p hp
    rw [if_pos hp]
  rw [h1, h2, Nat.mul_comm]

/-- **The exact law of the dial.**  For every subset `T` of the factor base, the number of
moduli in one period whose QR pattern is exactly `T` is
`∏_{p ∈ T} (p+1)/2 · ∏_{p ∉ T} (p-1)/2`. -/
theorem card_qr_pattern (B : ℕ) (T : Finset ℕ) (hT : T ⊆ oddFactorBase B) :
    ((range (basePrimorial B)).filter
        (fun N : ℕ => (oddFactorBase B).filter (fun p => IsQR (N : ℤ) p) = T)).card
      = (∏ p ∈ T, (p + 1) / 2) * (∏ p ∈ (oddFactorBase B) \ T, (p - 1) / 2) := by
  classical
  set Q : ∀ i : baseIdx B, ZMod (baseMod B i) → Prop :=
    fun i x => (IsSqMod (baseMod B i) x ↔ baseMod B i ∈ T) with hQ
  have hpred : ∀ N : ℕ,
      ((oddFactorBase B).filter (fun p => IsQR (N : ℤ) p) = T)
        ↔ ∀ i : baseIdx B, Q i ((N : ℕ) : ZMod (baseMod B i)) := by
    intro N
    constructor
    · intro h i
      have hmem : (baseMod B i ∈ (oddFactorBase B).filter (fun p => IsQR (N : ℤ) p))
          ↔ baseMod B i ∈ T := by rw [h]
      rw [Finset.mem_filter] at hmem
      have hib : baseMod B i ∈ oddFactorBase B := i.2
      constructor
      · intro hs
        exact hmem.1 ⟨hib, (isQR_iff_isSqMod (p := baseMod B i) N).2 hs⟩
      · intro ht
        exact (isQR_iff_isSqMod (p := baseMod B i) N).1 (hmem.2 ht).2
    · intro h
      ext p
      simp only [Finset.mem_filter]
      constructor
      · rintro ⟨hpB, hqr⟩
        haveI : NeZero p := ⟨(mem_oddFactorBase.1 hpB).2.1.ne_zero⟩
        have := (h ⟨p, hpB⟩).1 ((isQR_iff_isSqMod (p := p) N).1 hqr)
        simpa [baseMod] using this
      · intro hpT
        have hpB : p ∈ oddFactorBase B := hT hpT
        haveI : NeZero p := ⟨(mem_oddFactorBase.1 hpB).2.1.ne_zero⟩
        refine ⟨hpB, ?_⟩
        have := (h ⟨p, hpB⟩).2 (by simpa [baseMod] using hpT)
        exact (isQR_iff_isSqMod (p := p) N).2 (by simpa [baseMod] using this)
  have hcount := crt_count (baseMod B) (baseMod_pairwise_coprime B) Q
  rw [prod_baseMod] at hcount
  have hleft : ((range (basePrimorial B)).filter
      (fun N : ℕ => (oddFactorBase B).filter (fun p => IsQR (N : ℤ) p) = T)).card
      = ((range (basePrimorial B)).filter
          (fun N : ℕ => ∀ i : baseIdx B, Q i ((N : ℕ) : ZMod (baseMod B i)))).card := by
    congr 1
    exact Finset.filter_congr fun N _ => by simpa using hpred N
  rw [hleft, hcount]
  have hlocal : ∀ i : baseIdx B, (univ.filter (Q i)).card
      = if baseMod B i ∈ T then (baseMod B i + 1) / 2 else (baseMod B i - 1) / 2 := by
    intro i
    by_cases hi : baseMod B i ∈ T
    · have hEq : (univ.filter (Q i)) = univ.filter (fun x => IsSquare x) := by
        refine Finset.filter_congr ?_
        intro x _
        simp only [hQ, hi, iff_true, isSqMod_iff_isSquare]
      rw [hEq, if_pos hi, card_squares_zmod (baseMod B i) (baseMod_ne_two i)]
    · have hEq : (univ.filter (Q i)) = univ.filter (fun x => ¬ IsSquare x) := by
        refine Finset.filter_congr ?_
        intro x _
        simp only [hQ, hi, iff_false, isSqMod_iff_isSquare]
      rw [hEq, if_neg hi, card_nonsquares_zmod (baseMod B i) (baseMod_ne_two i)]
  rw [Finset.prod_congr rfl fun i _ => hlocal i]
  have hprod :
      (∏ i : baseIdx B, if baseMod B i ∈ T then (baseMod B i + 1) / 2 else (baseMod B i - 1) / 2)
        = ∏ p ∈ oddFactorBase B, (if p ∈ T then (p + 1) / 2 else (p - 1) / 2) :=
    Finset.prod_coe_sort (oddFactorBase B) (fun p => if p ∈ T then (p + 1) / 2 else (p - 1) / 2)
  rw [hprod, ← Finset.prod_sdiff hT]
  have h1 : ∏ p ∈ (oddFactorBase B) \ T, (if p ∈ T then (p + 1) / 2 else (p - 1) / 2)
      = ∏ p ∈ (oddFactorBase B) \ T, (p - 1) / 2 :=
    Finset.prod_congr rfl fun p hp => by rw [if_neg (Finset.mem_sdiff.1 hp).2]
  have h2 : ∏ p ∈ T, (if p ∈ T then (p + 1) / 2 else (p - 1) / 2)
      = ∏ p ∈ T, (p + 1) / 2 :=
    Finset.prod_congr rfl fun p hp => by rw [if_pos hp]
  rw [h1, h2, Nat.mul_comm]

/-- **Every pattern occurs inside one period.**  A quantitative refinement of
`qrWeight_full_range`: the count of moduli realising a prescribed QR pattern is strictly
positive. -/
theorem card_qr_pattern_pos (B : ℕ) (T : Finset ℕ) (hT : T ⊆ oddFactorBase B) :
    0 < ((range (basePrimorial B)).filter
        (fun N : ℕ => (oddFactorBase B).filter (fun p => IsQR (N : ℤ) p) = T)).card := by
  classical
  rw [card_qr_pattern B T hT]
  refine Nat.mul_pos (Finset.prod_pos ?_) (Finset.prod_pos ?_)
  · intro p hp
    have hprime : p.Prime := (mem_oddFactorBase.1 (hT hp)).2.1
    have := hprime.two_le
    omega
  · intro p hp
    have hpB : p ∈ oddFactorBase B := (Finset.mem_sdiff.1 hp).1
    have hprime : p.Prime := (mem_oddFactorBase.1 hpB).2.1
    have hne2 : p ≠ 2 := (mem_oddFactorBase.1 hpB).2.2
    have h2 : 2 ≤ p := hprime.two_le
    have hodd : p % 2 = 1 := hprime.eq_two_or_odd.resolve_left hne2
    omega

/-! ## Lab notes: the law checked by the kernel on `B = 5`

Factor base `{3, 5}`, period `P = 15`.  The law predicts `((3+1)/2)·((5+1)/2) = 6` moduli
with full pattern `{3,5}` and `((3-1)/2)·((5-1)/2) = 2` moduli with empty pattern. -/

section LabNotes

example : basePrimorial 5 = 15 := by decide

example : ((range (basePrimorial 5)).filter
    (fun N : ℕ => (oddFactorBase 5).filter (fun p => IsQR (N : ℤ) p) = {3, 5})).card = 6 := by
  decide

example : ((range (basePrimorial 5)).filter
    (fun N : ℕ => (oddFactorBase 5).filter (fun p => IsQR (N : ℤ) p) = ∅)).card = 2 := by
  decide

example : ((range (basePrimorial 5)).filter
    (fun N : ℕ => (oddFactorBase 5).filter (fun p => IsQR (N : ℤ) p) = {3})).card = 4 := by
  decide

end LabNotes

end QRResidual