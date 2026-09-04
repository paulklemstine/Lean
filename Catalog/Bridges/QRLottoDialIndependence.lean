import Mathlib
import Bridges.QRLottoDial

/-!
# Independence of the QR lottery: the exact distribution of the zero-fit dial

`Bridges.QRLottoDial` proves that the closed-form dial `T(N) = ∑ 2/p` over the
quadratic-residue primes of a factor base *is* the expected sieve footprint, with the
weight `2/p` forced by first principles.  This file computes the **exact distribution**
of that dial as `N` varies over the residues coprime to a factor base of distinct odd
primes.  The sample space is the CRT product `∏ ZMod (q i)` with invertible coordinates.

## Main results

* `QRLotto.card_bitSet` — each of the two tickets at `p` (residue / non-residue) has
  exactly `(p-1)/2` classes: `2 · #bitSet p b + 1 = p`, *independently of the bit*.
* `QRLotto.card_bitPattern` — **exact independence**: every one of the `2^k` bit patterns
  is realised by exactly `∏ (q i - 1) / 2^k` residue vectors, and
  `QRLotto.card_bitPattern_eq` records that this count is the same for all patterns.
* `QRLotto.sum_dialOf` — **mean of the dial**: `E[T] = ∑ 1/q i`, the Mertens weight.
* `QRLotto.sum_sq_dialOf` — **variance of the dial**: `Var[T] = ∑ 1/(q i)²`.  The dial is
  a sum of independent fair coins with amplitudes `2/q i`; no fitted parameter survives.
* `QRLotto.exists_prescribed_bits` — **steerability**: every bit pattern is realised by an
  actual integer `N` (Chinese remainder theorem), so the dial's range is the full
  `2^k`-point spectrum.

The marginal lemmas `QRLotto.sum_piFinset_single` and `QRLotto.sum_piFinset_pair` isolate
the probabilistic content: coordinates of a product Finset decouple exactly.
-/

open Finset

namespace QRLotto

/-! ## Marginal sums over a product sample space -/

section Marginal

variable {ι : Type*} [Fintype ι] [DecidableEq ι] {α : ι → Type*}

/-- **One-coordinate marginal.**  Summing a function of a single coordinate over a product
Finset factors as the marginal sum times the number of completions. -/
lemma sum_piFinset_single (t : ∀ i, Finset (α i)) (j : ι) (F : α j → ℝ) :
    ∑ x ∈ Fintype.piFinset t, F (x j)
      = (∏ i ∈ univ.erase j, (#(t i) : ℝ)) * ∑ y ∈ t j, F y := by
  classical
  set f : ∀ i, α i → ℝ := Function.update (fun _ _ => (1 : ℝ)) j F with hf
  have key := Finset.prod_univ_sum t f
  have hL : ∏ i, ∑ y ∈ t i, f i y = (∑ y ∈ t j, F y) * ∏ i ∈ univ.erase j, (#(t i) : ℝ) := by
    rw [← Finset.mul_prod_erase univ _ (mem_univ j)]
    congr 1
    · simp [hf]
    · refine Finset.prod_congr rfl (fun i hi => ?_)
      have hij : i ≠ j := (Finset.mem_erase.1 hi).1
      simp [hf, Function.update_of_ne hij]
  have hR : ∀ x : ∀ i, α i, ∏ i, f i (x i) = F (x j) := by
    intro x
    refine (Finset.prod_eq_single j
      (fun i _ hij => by simp [hf, Function.update_of_ne hij]) ?_).trans ?_
    · intro h; exact absurd (mem_univ j) h
    · simp [hf]
  calc ∑ x ∈ Fintype.piFinset t, F (x j)
      = ∑ x ∈ Fintype.piFinset t, ∏ i, f i (x i) :=
        Finset.sum_congr rfl (fun x _ => (hR x).symm)
    _ = ∏ i, ∑ y ∈ t i, f i y := key.symm
    _ = _ := by rw [hL, mul_comm]

/-- **Two-coordinate marginal.**  Distinct coordinates decouple: this is the exact
independence of the uniform product measure. -/
lemma sum_piFinset_pair (t : ∀ i, Finset (α i)) (j l : ι) (hjl : j ≠ l)
    (F : α j → ℝ) (G : α l → ℝ) :
    ∑ x ∈ Fintype.piFinset t, F (x j) * G (x l)
      = (∏ i ∈ (univ.erase j).erase l, (#(t i) : ℝ))
          * ((∑ y ∈ t j, F y) * ∑ z ∈ t l, G z) := by
  classical
  set f : ∀ i, α i → ℝ := Function.update (Function.update (fun _ _ => (1 : ℝ)) j F) l G with hf
  have hfj : f j = F := by rw [hf, Function.update_of_ne hjl, Function.update_self]
  have hfl : f l = G := by rw [hf, Function.update_self]
  have hfo : ∀ i, i ≠ j → i ≠ l → f i = fun _ => (1 : ℝ) := by
    intro i hij hil
    rw [hf, Function.update_of_ne hil, Function.update_of_ne hij]
  have hlmem : l ∈ univ.erase j := Finset.mem_erase.2 ⟨Ne.symm hjl, mem_univ l⟩
  have key := Finset.prod_univ_sum t f
  have hprod : ∀ x : ∀ i, α i, ∏ i, f i (x i) = F (x j) * G (x l) := by
    intro x
    rw [← Finset.mul_prod_erase univ _ (mem_univ j),
        ← Finset.mul_prod_erase (univ.erase j) _ hlmem, hfj, hfl, ← mul_assoc]
    have hone : ∏ i ∈ (univ.erase j).erase l, f i (x i) = 1 := by
      refine Finset.prod_eq_one (fun i hi => ?_)
      have hil : i ≠ l := (Finset.mem_erase.1 hi).1
      have hij : i ≠ j := (Finset.mem_erase.1 (Finset.mem_erase.1 hi).2).1
      rw [hfo i hij hil]
    rw [hone, mul_one]
  have hL : ∏ i, ∑ y ∈ t i, f i y
      = ((∑ y ∈ t j, F y) * ∑ z ∈ t l, G z) * ∏ i ∈ (univ.erase j).erase l, (#(t i) : ℝ) := by
    rw [← Finset.mul_prod_erase univ _ (mem_univ j),
        ← Finset.mul_prod_erase (univ.erase j) _ hlmem, hfj, hfl, ← mul_assoc]
    congr 1
    refine Finset.prod_congr rfl (fun i hi => ?_)
    have hil : i ≠ l := (Finset.mem_erase.1 hi).1
    have hij : i ≠ j := (Finset.mem_erase.1 (Finset.mem_erase.1 hi).2).1
    rw [hfo i hij hil]
    simp
  calc ∑ x ∈ Fintype.piFinset t, F (x j) * G (x l)
      = ∑ x ∈ Fintype.piFinset t, ∏ i, f i (x i) :=
        Finset.sum_congr rfl (fun x _ => (hprod x).symm)
    _ = ∏ i, ∑ y ∈ t i, f i y := key.symm
    _ = _ := by rw [hL, mul_comm]

end Marginal

/-! ## The two tickets at a single prime -/

/-- The losing classes at `p`: the nonzero non-residues. -/
def losers (p : ℕ) : Finset ℕ := (Finset.range p).filter (fun N => rootCount p (N : ℤ) = 0)

lemma mem_losers_iff {p N : ℕ} : N ∈ losers p ↔ N < p ∧ rootCount p (N : ℤ) = 0 := by
  simp [losers, Finset.mem_filter, Finset.mem_range]

/-- **Winners and losers are equinumerous**: there are exactly `(p-1)/2` nonzero
non-residues, just as there are `(p-1)/2` residues. -/
theorem card_losers (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    2 * (losers p).card + 1 = p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hdisj : Disjoint (winners p) (losers p) := by
    rw [Finset.disjoint_left]
    intro a ha hb
    have h2 := (mem_winners_iff.1 ha).2
    have h0 := mem_losers_iff.1 hb
    rw [h2] at h0
    exact absurd h0.2 (by norm_num)
  have hnot : 0 ∉ winners p ∪ losers p := by
    simp only [Finset.mem_union, mem_winners_iff, mem_losers_iff, not_or, not_and]
    constructor <;> · intro _; simp [rootCount_zero]
  have hrange : Finset.range p = insert 0 (winners p ∪ losers p) := by
    ext N
    simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_union, mem_winners_iff,
      mem_losers_iff]
    constructor
    · intro hN
      rcases Nat.eq_zero_or_pos N with rfl | hpos
      · exact Or.inl rfl
      · have hdvd : ¬ (p : ℤ) ∣ (N : ℤ) := by
          intro h
          have hnd : (p : ℕ) ∣ N := by exact_mod_cast h
          exact absurd (Nat.le_of_dvd hpos hnd) (not_le.2 hN)
        rcases rootCount_eq_two_or_zero p hp hdvd with h2 | h2
        · exact Or.inr (Or.inl ⟨hN, h2⟩)
        · exact Or.inr (Or.inr ⟨hN, h2⟩)
    · rintro (rfl | ⟨h, _⟩ | ⟨h, _⟩)
      · exact (Fact.out : p.Prime).pos
      · exact h
      · exact h
  have hcard := congrArg Finset.card hrange
  rw [Finset.card_range, Finset.card_insert_of_notMem hnot,
    Finset.card_union_of_disjoint hdisj] at hcard
  have hw := card_winners p hp
  omega

/-- The winning classes seen inside `ZMod p`. -/
def winZ (p : ℕ) : Finset (ZMod p) := (winners p).image (fun n : ℕ => (n : ZMod p))

/-- The losing classes seen inside `ZMod p`. -/
def loseZ (p : ℕ) : Finset (ZMod p) := (losers p).image (fun n : ℕ => (n : ZMod p))

/-- The ticket set of the bit `b` at `p`. -/
def bitSet (p : ℕ) (b : Bool) : Finset (ZMod p) := if b then winZ p else loseZ p

/-- The invertible classes mod `p`. -/
def nzZ (p : ℕ) : Finset (ZMod p) := winZ p ∪ loseZ p

lemma cast_injOn (p : ℕ) [NeZero p] (s : Finset ℕ) (hs : s ⊆ Finset.range p) :
    Set.InjOn (fun n : ℕ => (n : ZMod p)) s := by
  intro a ha b hb hab
  have ha' := Finset.mem_range.1 (hs ha)
  have hb' := Finset.mem_range.1 (hs hb)
  have := congrArg ZMod.val hab
  simpa [ZMod.val_natCast_of_lt ha', ZMod.val_natCast_of_lt hb'] using this

lemma card_winZ (p : ℕ) [NeZero p] : (winZ p).card = (winners p).card :=
  Finset.card_image_of_injOn (cast_injOn p _ (Finset.filter_subset _ _))

lemma card_loseZ (p : ℕ) [NeZero p] : (loseZ p).card = (losers p).card :=
  Finset.card_image_of_injOn (cast_injOn p _ (Finset.filter_subset _ _))

lemma disjoint_winZ_loseZ (p : ℕ) [NeZero p] : Disjoint (winZ p) (loseZ p) := by
  rw [Finset.disjoint_left]
  rintro a ha hb
  obtain ⟨n, hn, rfl⟩ := Finset.mem_image.1 ha
  obtain ⟨m, hm, hmn⟩ := Finset.mem_image.1 hb
  have hn' := mem_winners_iff.1 hn
  have hm' := mem_losers_iff.1 hm
  have hmn' : m = n := cast_injOn p (Finset.range p) (subset_refl _)
    (Finset.mem_range.2 hm'.1) (Finset.mem_range.2 hn'.1) hmn
  rw [hmn', hn'.2] at hm'
  exact absurd hm'.2 (by norm_num)

/-- **Both tickets are equally likely**: each ticket set at an odd prime `p` has exactly
`(p-1)/2` elements, regardless of the bit.  This is the exact lottery table. -/
theorem card_bitSet (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (b : Bool) :
    2 * (bitSet p b).card + 1 = p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  cases b
  · simpa [bitSet, card_loseZ] using card_losers p hp
  · simpa [bitSet, card_winZ] using card_winners p hp

theorem card_nzZ (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : (nzZ p).card + 1 = p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have h := Finset.card_union_of_disjoint (disjoint_winZ_loseZ p)
  have hw := card_winners p hp
  have hl := card_losers p hp
  rw [card_winZ, card_loseZ] at h
  rw [nzZ, h]
  omega

/-- Half of the invertible classes are winners. -/
theorem two_mul_card_winZ (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    2 * (winZ p).card = (nzZ p).card := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hw := card_winners p hp
  have hn := card_nzZ p hp
  rw [card_winZ]
  omega

theorem card_winZ_eq_card_loseZ (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (winZ p).card = (loseZ p).card := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hw := card_winners p hp
  have hl := card_losers p hp
  rw [card_winZ, card_loseZ]
  omega

lemma winZ_subset_nzZ (p : ℕ) : winZ p ⊆ nzZ p := Finset.subset_union_left

lemma loseZ_subset_nzZ (p : ℕ) : loseZ p ⊆ nzZ p := Finset.subset_union_right

/-! ## Exact independence of the bits across the factor base -/

variable {k : ℕ}

/-- **Exact independence of the QR lottery.**  For a factor base of odd primes, each of
the `2^k` bit patterns is realised by exactly `∏ (q i - 1) / 2^k` residue vectors. -/
theorem card_bitPattern (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (ε : Fin k → Bool) :
    2 ^ k * #(Fintype.piFinset (fun i => bitSet (q i) (ε i))) = ∏ i, (q i - 1) := by
  classical
  rw [Fintype.card_piFinset]
  have h : ∀ i : Fin k, 2 * (bitSet (q i) (ε i)).card = q i - 1 := by
    intro i
    haveI : Fact (q i).Prime := ⟨hq i⟩
    have := card_bitSet (q i) (h2 i) (ε i)
    omega
  calc 2 ^ k * ∏ i, #(bitSet (q i) (ε i))
      = ∏ i : Fin k, (2 * #(bitSet (q i) (ε i))) := by
        rw [Finset.prod_mul_distrib]
        simp [Finset.prod_const, Finset.card_univ]
    _ = ∏ i, (q i - 1) := Finset.prod_congr rfl (fun i _ => h i)

/-- Uniformity: two different bit patterns are realised equally often, so the bit vector
of the dial is uniformly distributed on `{0,1}^k`. -/
theorem card_bitPattern_eq (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (ε ε' : Fin k → Bool) :
    #(Fintype.piFinset (fun i => bitSet (q i) (ε i)))
      = #(Fintype.piFinset (fun i => bitSet (q i) (ε' i))) := by
  have h1 := card_bitPattern q hq h2 ε
  have h2' := card_bitPattern q hq h2 ε'
  have hpow : (0 : ℕ) < 2 ^ k := pow_pos (by norm_num) k
  exact Nat.eq_of_mul_eq_mul_left hpow (h1.trans h2'.symm)

/-! ## The moments of the dial -/

/-- A general linear read-out of the QR bit vector with per-prime weights `w`. -/
noncomputable def weightedDial (q : Fin k → ℕ) (w : Fin k → ℝ) (x : ∀ i, ZMod (q i)) : ℝ :=
  ∑ i, (if x i ∈ winZ (q i) then w i else 0)

/-- The zero-fit dial: the weighted read-out with the *theory* weights `2/p`. -/
noncomputable def dialOf (q : Fin k → ℕ) (x : ∀ i, ZMod (q i)) : ℝ :=
  weightedDial q (fun i => 2 / q i) x

/-- The sample space: residue vectors with every coordinate invertible. -/
def sampleSpace (q : Fin k → ℕ) : Finset (∀ i, ZMod (q i)) :=
  Fintype.piFinset (fun i => nzZ (q i))

lemma card_sampleSpace_erase (q : Fin k → ℕ) (i : Fin k) :
    (#(Fintype.piFinset (fun j => nzZ (q j))) : ℝ)
      = (#(nzZ (q i)) : ℝ) * ∏ j ∈ univ.erase i, (#(nzZ (q j)) : ℝ) := by
  rw [Fintype.card_piFinset, Nat.cast_prod, ← Finset.mul_prod_erase univ _ (mem_univ i)]

/-- The marginal mass of the `i`-th ticket. -/
lemma sum_indicator_nzZ (p : ℕ) (w : ℝ) :
    ∑ y ∈ nzZ p, (if y ∈ winZ p then w else 0) = (#(winZ p) : ℝ) * w := by
  classical
  rw [← Finset.sum_filter, Finset.filter_mem_eq_inter,
    Finset.inter_eq_right.2 (winZ_subset_nzZ p), Finset.sum_const, nsmul_eq_mul]

/-- **Mean of a weighted read-out.**  Each bit is a fair coin, so the mean of the linear
read-out with weights `w` is `∑ w i / 2`, with no fitted constant. -/
theorem sum_weightedDial (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (w : Fin k → ℝ) :
    ∑ x ∈ sampleSpace q, weightedDial q w x
      = (#(sampleSpace q) : ℝ) * ∑ i, w i / 2 := by
  classical
  simp only [sampleSpace]
  rw [Finset.mul_sum]
  rw [show (∑ x ∈ Fintype.piFinset (fun j => nzZ (q j)), weightedDial q w x)
      = ∑ i : Fin k, ∑ x ∈ Fintype.piFinset (fun j => nzZ (q j)),
          (if x i ∈ winZ (q i) then w i else 0) from
    Finset.sum_comm]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : Fact (q i).Prime := ⟨hq i⟩
  rw [sum_piFinset_single (fun j => nzZ (q j)) i
    (fun y => if y ∈ winZ (q i) then w i else 0), sum_indicator_nzZ (q i) (w i),
    card_sampleSpace_erase q i]
  have hhalf : (#(nzZ (q i)) : ℝ) = 2 * (#(winZ (q i)) : ℝ) := by
    exact_mod_cast (two_mul_card_winZ (q i) (h2 i)).symm
  rw [hhalf]
  ring

/-- **Mean of the dial.**  Averaged over all residue vectors coprime to the factor base,
the zero-fit dial equals the Mertens weight `∑ 1/q i` exactly. -/
theorem sum_dialOf (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2) :
    ∑ x ∈ sampleSpace q, dialOf q x
      = (#(sampleSpace q) : ℝ) * ∑ i, 1 / (q i : ℝ) := by
  rw [show (fun x => dialOf q x) = (fun x => weightedDial q (fun i => 2 / (q i : ℝ)) x) from rfl,
    sum_weightedDial q hq h2]
  congr 1
  exact Finset.sum_congr rfl (fun i _ => by ring)

/-- The centred coin at the prime `p` with amplitude `w`. -/
noncomputable def coin (p : ℕ) (w : ℝ) (y : ZMod p) : ℝ :=
  (if y ∈ winZ p then w else 0) - w / 2

lemma coin_of_win {p : ℕ} {w : ℝ} {y : ZMod p} (hy : y ∈ winZ p) : coin p w y = w / 2 := by
  simp only [coin, if_pos hy]
  ring

lemma coin_of_not_win {p : ℕ} {w : ℝ} {y : ZMod p} (hy : y ∉ winZ p) :
    coin p w y = -(w / 2) := by
  simp only [coin, if_neg hy, zero_sub]

/-- **The centred coin has mean zero**: this is the fairness of the QR lottery. -/
lemma sum_coin (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (w : ℝ) :
    ∑ y ∈ nzZ p, coin p w y = 0 := by
  classical
  have hw : ∀ y ∈ winZ p, coin p w y = w / 2 := fun y hy => coin_of_win hy
  have hl : ∀ y ∈ loseZ p, coin p w y = -(w / 2) := fun y hy =>
    coin_of_not_win ((Finset.disjoint_right.1 (disjoint_winZ_loseZ p)) hy)
  have hcards : (#(winZ p) : ℝ) = (#(loseZ p) : ℝ) := by
    exact_mod_cast card_winZ_eq_card_loseZ p hp
  rw [nzZ, Finset.sum_union (disjoint_winZ_loseZ p), Finset.sum_congr rfl hw,
    Finset.sum_congr rfl hl, Finset.sum_const, Finset.sum_const, nsmul_eq_mul, nsmul_eq_mul,
    hcards]
  ring

/-- **The centred coin has second moment `w²/4`** at every class: a fair coin of
amplitude `w`. -/
lemma coin_sq (p : ℕ) (w : ℝ) (y : ZMod p) : (coin p w y) ^ 2 = w ^ 2 / 4 := by
  by_cases h : y ∈ winZ p
  · rw [coin_of_win h]; ring
  · rw [coin_of_not_win h]; ring

lemma sum_coin_sq (p : ℕ) (w : ℝ) :
    ∑ y ∈ nzZ p, (coin p w y) ^ 2 = (#(nzZ p) : ℝ) * (w ^ 2 / 4) := by
  rw [Finset.sum_congr rfl (fun y _ => coin_sq p w y), Finset.sum_const, nsmul_eq_mul]

/-- **Variance of a weighted read-out.**  Distinct primes are exactly independent, so the
variance of `∑ w i b i` is `∑ w i ² / 4`: the sum of the variances of fair coins. -/
theorem sum_sq_weightedDial_centred (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime)
    (h2 : ∀ i, q i ≠ 2) (w : Fin k → ℝ) :
    ∑ x ∈ sampleSpace q, (weightedDial q w x - ∑ i, w i / 2) ^ 2
      = (#(sampleSpace q) : ℝ) * ∑ i, (w i) ^ 2 / 4 := by
  classical
  simp only [sampleSpace]
  have hcentre : ∀ x : ∀ i, ZMod (q i),
      weightedDial q w x - ∑ i, w i / 2 = ∑ i, coin (q i) (w i) (x i) := by
    intro x
    rw [weightedDial, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun i _ => rfl)
  have hsq : ∀ x : ∀ i, ZMod (q i),
      (weightedDial q w x - ∑ i, w i / 2) ^ 2
        = ∑ i : Fin k, ∑ j : Fin k, coin (q i) (w i) (x i) * coin (q j) (w j) (x j) := by
    intro x
    rw [hcentre x, sq, Finset.sum_mul_sum]
  rw [Finset.sum_congr rfl (fun x _ => hsq x), Finset.sum_comm]
  rw [show (∑ i : Fin k, ∑ x ∈ Fintype.piFinset (fun j => nzZ (q j)), ∑ j : Fin k,
        coin (q i) (w i) (x i) * coin (q j) (w j) (x j))
      = ∑ i : Fin k, ∑ j : Fin k, ∑ x ∈ Fintype.piFinset (fun l => nzZ (q l)),
        coin (q i) (w i) (x i) * coin (q j) (w j) (x j) from
    Finset.sum_congr rfl (fun i _ => Finset.sum_comm)]
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  haveI : Fact (q i).Prime := ⟨hq i⟩
  rw [Finset.sum_eq_single i]
  · -- the diagonal term: the variance of a single coin
    have hdiag : ∑ x ∈ Fintype.piFinset (fun l => nzZ (q l)),
          coin (q i) (w i) (x i) * coin (q i) (w i) (x i)
        = ∑ x ∈ Fintype.piFinset (fun l => nzZ (q l)),
            (fun y => (coin (q i) (w i) y) ^ 2) (x i) :=
      Finset.sum_congr rfl (fun x _ => (pow_two _).symm)
    rw [hdiag, sum_piFinset_single (fun l => nzZ (q l)) i (fun y => (coin (q i) (w i) y) ^ 2),
      sum_coin_sq (q i) (w i), card_sampleSpace_erase q i]
    ring
  · -- off-diagonal terms vanish: distinct coordinates are independent and centred
    intro j _ hji
    haveI : Fact (q j).Prime := ⟨hq j⟩
    rw [sum_piFinset_pair (fun l => nzZ (q l)) i j (Ne.symm hji)
      (fun y => coin (q i) (w i) y) (fun z => coin (q j) (w j) z), sum_coin (q i) (h2 i)]
    ring
  · intro h
    exact absurd (mem_univ i) h

/-- **Variance of the dial.**  The fluctuation of the zero-fit dial around its Mertens
mean is exactly `∑ 1/(q i)²`: the dial is a sum of independent fair coins of amplitude
`2/q i`, so its second moment is forced with no fitted parameter. -/
theorem sum_sq_dialOf (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2) :
    ∑ x ∈ sampleSpace q, (dialOf q x - ∑ i, 1 / (q i : ℝ)) ^ 2
      = (#(sampleSpace q) : ℝ) * ∑ i, 1 / (q i : ℝ) ^ 2 := by
  have hmean : ∑ i, (2 : ℝ) / (q i : ℝ) / 2 = ∑ i, 1 / (q i : ℝ) :=
    Finset.sum_congr rfl (fun i _ => by ring)
  have h := sum_sq_weightedDial_centred q hq h2 (fun i => 2 / (q i : ℝ))
  rw [hmean] at h
  simp only [dialOf]
  rw [h]
  congr 1
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [div_pow]
  ring

/-! ## Steerability: every dial reading is realised by an integer -/

/-- Chinese remainder theorem in the form needed here: any prescribed residue vector for
pairwise coprime moduli is realised by a natural number. -/
lemma exists_crt (q : Fin k → ℕ) (hpos : ∀ i, 0 < q i)
    (hcop : Pairwise (Function.onFun Nat.Coprime q)) (a : ∀ i, ZMod (q i)) :
    ∃ N : ℕ, ∀ i, (N : ZMod (q i)) = a i := by
  classical
  haveI : ∀ i, NeZero (q i) := fun i => ⟨(hpos i).ne'⟩
  set M := ∏ i, q i with hM
  haveI : NeZero M := ⟨by
    rw [hM]
    exact Finset.prod_ne_zero_iff.2 (fun i _ => (hpos i).ne')⟩
  set f : ZMod M → ∀ i, ZMod (q i) := fun x i => ((x.val : ℕ) : ZMod (q i)) with hf
  have hinj : Function.Injective f := by
    intro x y hxy
    have hmod : ∀ i, ((q i : ℤ)) ∣ ((y.val : ℤ) - (x.val : ℤ)) := by
      intro i
      have h := congrFun hxy i
      rw [hf] at h
      exact Nat.modEq_iff_dvd.1 ((ZMod.natCast_eq_natCast_iff _ _ _).1 h)
    have hdvd : ((M : ℕ) : ℤ) ∣ ((y.val : ℤ) - (x.val : ℤ)) := by
      have hprod : ∏ i, ((q i : ℤ)) ∣ ((y.val : ℤ) - (x.val : ℤ)) := by
        refine Fintype.prod_dvd_of_coprime ?_ hmod
        intro i j hij
        exact Nat.isCoprime_iff_coprime.2 (hcop hij)
      rwa [← Nat.cast_prod] at hprod
    have hlt : |((y.val : ℤ) - (x.val : ℤ))| < (M : ℤ) := by
      have hx := ZMod.val_lt x
      have hy := ZMod.val_lt y
      rw [abs_lt]
      omega
    have hzero := Int.eq_zero_of_abs_lt_dvd hdvd hlt
    have hval : x.val = y.val := by omega
    exact ZMod.val_injective M hval
  have hcard : Fintype.card (ZMod M) = Fintype.card (∀ i, ZMod (q i)) :=
    Fintype.card_congr (ZMod.prodEquivPi q hcop).toEquiv
  have hbij := (Fintype.bijective_iff_injective_and_card f).2 ⟨hinj, hcard⟩
  obtain ⟨x, hx⟩ := hbij.2 a
  exact ⟨x.val, fun i => congrFun hx i⟩

/-- Every ticket set at an odd prime is nonempty. -/
lemma bitSet_nonempty (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (b : Bool) :
    (bitSet p b).Nonempty := by
  have hc := card_bitSet p hp b
  have hp3 : 3 ≤ p := by
    have := (Fact.out : p.Prime).two_le
    omega
  refine Finset.card_pos.1 ?_
  omega

/-- **Steerability of the dial.**  For distinct odd primes `q i` and any prescribed bit
pattern there is an integer `N` whose QR footprint is exactly that pattern; the dial can
therefore be tuned to each of the `2^k` readings. -/
theorem exists_prescribed_bits (q : Fin k → ℕ) (hq : ∀ i, (q i).Prime) (h2 : ∀ i, q i ≠ 2)
    (hinj : Function.Injective q) (ε : Fin k → Bool) :
    ∃ N : ℕ, ∀ i, rootCount (q i) (N : ℤ) = if ε i then 2 else 0 := by
  classical
  haveI : ∀ i, NeZero (q i) := fun i => ⟨(hq i).ne_zero⟩
  have hcop : Pairwise (Function.onFun Nat.Coprime q) := by
    intro i j hij
    exact (Nat.coprime_primes (hq i) (hq j)).2 (fun h => hij (hinj h))
  -- pick a winning / losing class at each prime
  have hchoice : ∀ i, ∃ n : ℕ, n < q i ∧ rootCount (q i) (n : ℤ) = (if ε i then 2 else 0) := by
    intro i
    haveI : Fact (q i).Prime := ⟨hq i⟩
    obtain ⟨y, hy⟩ := bitSet_nonempty (q i) (h2 i) (ε i)
    cases hb : ε i with
    | true =>
        rw [hb, bitSet, if_pos rfl] at hy
        obtain ⟨n, hn, _⟩ := Finset.mem_image.1 hy
        exact ⟨n, (mem_winners_iff.1 hn).1, by simpa using (mem_winners_iff.1 hn).2⟩
    | false =>
        rw [hb, bitSet, if_neg (by simp)] at hy
        obtain ⟨n, hn, _⟩ := Finset.mem_image.1 hy
        exact ⟨n, (mem_losers_iff.1 hn).1, by simpa using (mem_losers_iff.1 hn).2⟩
  choose n hn hnroot using hchoice
  obtain ⟨N, hN⟩ := exists_crt q (fun i => (hq i).pos) hcop (fun i => ((n i : ℕ) : ZMod (q i)))
  refine ⟨N, fun i => ?_⟩
  have hcast : ((N : ℤ) : ZMod (q i)) = ((n i : ℤ) : ZMod (q i)) := by
    push_cast
    exact hN i
  rw [rootCount_congr (q i) hcast]
  exact hnroot i

end QRLotto