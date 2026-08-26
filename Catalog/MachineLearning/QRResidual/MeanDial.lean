import MachineLearning.QRResidual.Blindness

/-!
# The dial averages to the random model: all of its content is in the fluctuation

Paper 130 (`Shared.QSRelationPoolRandom`) proved that the quadratic-sieve relation pool is
*random-equivalent prime by prime*: averaged over the residue of `N`, each prime hits
exactly once per period.  Paper 145 (experiment 477) then found that a per-`N` dial built
from the *same* residues has real predictive power for the yield.

Those two statements are compatible, and this file proves exactly how: the footprint dial
`Σ hitCount(N,p)/p` **averages, over a full period of moduli, to the random-integer
footprint `Σ 1/p`**, so all of its predictive content sits in its fluctuation around the
random model, not in its mean.  The QR-form dial `Σ_{QR p} 2/p` has the slightly larger
mean `Σ (p+1)/p²`, the excess `Σ 1/p²` coming from the ramified residues `p ∣ N`.

Main results.

* `sum_periodic` — exact summation of a `p`-periodic function over a window of length `k·p`.
* `hitCount_periodic`, `isQR_periodic` — the dial's ingredients are periodic in `N`.
* `sum_hitCount_residues` — `Σ_{N mod p} hitCount(N,p) = p` (paper 130's cancellation,
  transported to the integer window form).
* `card_isQR_residues` — exactly `(p+1)/2` of the `p` residues are quadratic residues.
* `mean_footprintWeight_eq_random` — **the dial's mean is the random-integer footprint**
  `Σ_{p ≤ B} 1/p`.
* `mean_qrWeight` — the mean of the QR-form dial is exactly `Σ_{p ≤ B} (p+1)/p²`.
-/

namespace QRResidual

open Finset

/-! ## Periodic summation -/

/-- **Exact periodic summation.**  A `p`-periodic function sums over a window of length
`k · p` to `k` times its sum over one period. -/
theorem sum_periodic {M : Type*} [AddCommMonoid M] (f : ℕ → M) (p : ℕ)
    (hper : ∀ x, f (x + p) = f x) (k : ℕ) :
    ∑ x ∈ range (k * p), f x = k • ∑ x ∈ range p, f x := by
  have hshift : ∀ m x : ℕ, f (m * p + x) = f x := by
    intro m
    induction m with
    | zero => simp
    | succ n ih =>
      intro x
      have h : (n + 1) * p + x = (n * p + x) + p := by ring
      rw [h, hper, ih]
  induction k with
  | zero => simp
  | succ k ih =>
    have hk : (k + 1) * p = k * p + p := by ring
    rw [hk, Finset.range_add, Finset.sum_union, ih, Finset.sum_map]
    · have : ∑ x ∈ range p, f ((addLeftEmbedding (k * p)) x) = ∑ x ∈ range p, f x := by
        refine Finset.sum_congr rfl ?_
        intro x _
        simpa [addLeftEmbedding] using hshift k x
      rw [this, succ_nsmul]
    · refine Finset.disjoint_left.2 ?_
      intro a ha hb
      simp only [mem_range] at ha
      simp only [Finset.mem_map] at hb
      obtain ⟨x, hx, hxa⟩ := hb
      simp only [addLeftEmbedding, Function.Embedding.coeFn_mk] at hxa
      omega

/-! ## Periodicity of the dial in the modulus -/

/-- The hit count is `p`-periodic in `N`. -/
theorem hitCount_periodic (N : ℤ) (p : ℕ) : hitCount (N + p) p = hitCount N p := by
  unfold hitCount
  congr 1
  refine Finset.filter_congr ?_
  intro x _
  constructor
  · intro h
    have hrw : ((x : ℤ) ^ 2 - N) = ((x : ℤ) ^ 2 - (N + p)) + (p : ℤ) := by ring
    rw [hrw]
    exact dvd_add h dvd_rfl
  · intro h
    have hrw : ((x : ℤ) ^ 2 - (N + p)) = ((x : ℤ) ^ 2 - N) - (p : ℤ) := by ring
    rw [hrw]
    exact dvd_sub h dvd_rfl

/-- Quadratic residuacity is `p`-periodic in `N`. -/
theorem isQR_periodic (N : ℤ) (p : ℕ) : IsQR (N + p) p ↔ IsQR N p := by
  refine isQR_congr ?_
  simp

/-! ## Sums over one period of moduli -/

/-- **Paper 130's cancellation in window form.**  Summing the hit count over a full period
of moduli gives exactly `p`: on average one hit per period, exactly as for a random
integer sequence. -/
theorem sum_hitCount_residues (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    ∑ N ∈ range p, hitCount (N : ℤ) p = p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hbij : ∑ N ∈ range p, hitCount (N : ℤ) p
      = ∑ a : ZMod p, QSRelationPool.rootCount p a := by
    refine Finset.sum_nbij' (fun N => ((N : ℕ) : ZMod p)) (fun a => a.val) ?_ ?_ ?_ ?_ ?_
    · intro N _; exact Finset.mem_univ _
    · intro a _; exact Finset.mem_range.2 (ZMod.val_lt a)
    · intro N hN; exact ZMod.val_natCast_of_lt (Finset.mem_range.1 hN)
    · intro a _; simp [ZMod.natCast_val]
    · intro N _
      rw [hitCount_eq_rootCount]
      congr 1
      push_cast
      ring
  rw [hbij]
  exact QSRelationPool.expected_hits_eq_one hp2

/-- Exactly `(p+1)/2` of the residues of `ZMod p` are squares: the `(p-1)/2` nonzero
squares, plus `0`. -/
theorem card_squares_zmod (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    (Finset.univ.filter (fun a : ZMod p => IsSquare a)).card = (p + 1) / 2 := by
  classical
  have hp : p.Prime := Fact.out
  have hins : (Finset.univ.filter (fun a : ZMod p => IsSquare a))
      = insert (0 : ZMod p) (QSRelationPool.admissible p) := by
    ext a
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      QSRelationPool.admissible, Set.mem_toFinset, Set.mem_setOf_eq]
    constructor
    · intro h
      by_cases ha : a = 0
      · exact Or.inl ha
      · exact Or.inr ⟨ha, h⟩
    · rintro (rfl | ⟨-, h⟩)
      · exact ⟨0, by ring⟩
      · exact h
  have hnotmem : (0 : ZMod p) ∉ QSRelationPool.admissible p := by
    simp [QSRelationPool.admissible]
  have hcard := QSRelationPool.card_admissible_residues (p := p) hp2
  have hodd : p % 2 = 1 := hp.eq_two_or_odd.resolve_left hp2
  have h2 : 2 ≤ p := hp.two_le
  rw [hins, Finset.card_insert_of_notMem hnotmem, hcard]
  omega

/-- The complementary count: exactly `(p-1)/2` residues are non-squares. -/
theorem card_nonsquares_zmod (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    (Finset.univ.filter (fun a : ZMod p => ¬ IsSquare a)).card = (p - 1) / 2 := by
  classical
  have hp : p.Prime := Fact.out
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hodd : p % 2 = 1 := hp.eq_two_or_odd.resolve_left hp2
  have h2 : 2 ≤ p := hp.two_le
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := (Finset.univ : Finset (ZMod p))) (p := fun a => IsSquare a)
  have hsq := card_squares_zmod p hp2
  have hcard : (Finset.univ : Finset (ZMod p)).card = p := by
    simp [ZMod.card]
  omega

/-- Exactly `(p+1)/2` of the `p` residues mod `p` are quadratic residues (the `(p-1)/2`
nonzero squares, plus `0`). -/
theorem card_isQR_residues {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    ((range p).filter (fun N : ℕ => IsQR (N : ℤ) p)).card = (p + 1) / 2 := by
  classical
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hbij : ((range p).filter (fun N : ℕ => IsQR (N : ℤ) p)).card
      = (Finset.univ.filter (fun a : ZMod p => IsSquare a)).card := by
    apply Finset.card_bij' (fun N _ => ((N : ℕ) : ZMod p)) (fun a _ => a.val)
    · intro N hN
      simp only [Finset.mem_filter, Finset.mem_range] at hN ⊢
      refine ⟨Finset.mem_univ _, ?_⟩
      have := (isQR_iff_isSquare (p := p) ((N : ℕ) : ℤ)).1 hN.2
      simpa using this
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
      simp only [Finset.mem_filter, Finset.mem_range]
      refine ⟨ZMod.val_lt a, ?_⟩
      rw [isQR_iff_isSquare]
      simpa [ZMod.natCast_val] using ha
    · intro N hN
      exact ZMod.val_natCast_of_lt (Finset.mem_range.1 (Finset.mem_filter.1 hN).1)
    · intro a _; simp [ZMod.natCast_val]
  rw [hbij, card_squares_zmod p hp2]

/-! ## The mean of the dial -/

/-- The primorial of the factor base is a multiple of each of its primes. -/
theorem basePrimorial_eq_mul {B p : ℕ} (hp : p ∈ oddFactorBase B) :
    basePrimorial B = (∏ q ∈ (oddFactorBase B).erase p, q) * p := by
  classical
  rw [basePrimorial, ← Finset.mul_prod_erase (oddFactorBase B) _ hp]
  ring

/-- **The dial averages to the random model.**  Summed over a full period of moduli, the
footprint weight equals `P · Σ_{p ≤ B} 1/p`: its mean is exactly the expected footprint of
a *random* integer sequence.  All predictive content of the dial is therefore in its
fluctuation about the random model, not in its mean. -/
theorem mean_footprintWeight_eq_random (B : ℕ) :
    ∑ N ∈ range (basePrimorial B), footprintWeight (N : ℤ) B
      = (basePrimorial B : ℚ) * ∑ p ∈ oddFactorBase B, (1 : ℚ) / p := by
  classical
  rw [Finset.mul_sum]
  unfold footprintWeight
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl ?_
  intro p hp
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
  haveI : Fact p.Prime := ⟨hprime⟩
  have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
  set k := ∏ q ∈ (oddFactorBase B).erase p, q with hk
  have hP : basePrimorial B = k * p := basePrimorial_eq_mul hp
  have hper : ∀ x : ℕ, (hitCount ((x + p : ℕ) : ℤ) p : ℚ) / p = (hitCount (x : ℤ) p : ℚ) / p := by
    intro x
    have : ((x + p : ℕ) : ℤ) = (x : ℤ) + p := by push_cast; ring
    rw [this, hitCount_periodic]
  have hsum := sum_periodic (fun x : ℕ => (hitCount (x : ℤ) p : ℚ) / p) p hper k
  rw [hP, hsum]
  have hres : ∑ x ∈ range p, (hitCount (x : ℤ) p : ℚ) / p = 1 := by
    rw [← Finset.sum_div]
    have : ∑ x ∈ range p, (hitCount (x : ℤ) p : ℚ) = (p : ℚ) := by
      have := sum_hitCount_residues p hp2
      exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) this
    rw [this]
    field_simp
  rw [hres, nsmul_eq_mul, mul_one]
  push_cast
  field_simp

/-- **Mean of the QR-form dial.**  Summed over a full period of moduli, the QR feature
`Σ_{QR p} 2/p` equals `P · Σ_{p ≤ B} (p+1)/p²`; the excess `Σ 1/p²` over the random-model
value `Σ 1/p` is contributed by the ramified residues `p ∣ N`. -/
theorem mean_qrWeight (B : ℕ) :
    ∑ N ∈ range (basePrimorial B), qrWeight (N : ℤ) B
      = (basePrimorial B : ℚ) * ∑ p ∈ oddFactorBase B, ((p : ℚ) + 1) / (p : ℚ) ^ 2 := by
  classical
  rw [Finset.mul_sum]
  unfold qrWeight
  have hexp : ∀ N : ℕ, ∑ p ∈ (oddFactorBase B).filter (fun p => IsQR (N : ℤ) p), (2 : ℚ) / p
      = ∑ p ∈ oddFactorBase B, (if IsQR (N : ℤ) p then (2 : ℚ) / p else 0) := by
    intro N
    rw [Finset.sum_filter]
  simp_rw [hexp]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl ?_
  intro p hp
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
  have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
  set k := ∏ q ∈ (oddFactorBase B).erase p, q with hk
  have hP : basePrimorial B = k * p := basePrimorial_eq_mul hp
  have hper : ∀ x : ℕ,
      (if IsQR ((x + p : ℕ) : ℤ) p then (2 : ℚ) / p else 0)
        = (if IsQR (x : ℤ) p then (2 : ℚ) / p else 0) := by
    intro x
    have hcast : ((x + p : ℕ) : ℤ) = (x : ℤ) + p := by push_cast; ring
    by_cases h : IsQR (x : ℤ) p
    · rw [if_pos h, if_pos (by rw [hcast]; exact (isQR_periodic (x : ℤ) p).2 h)]
    · rw [if_neg h, if_neg (by rw [hcast]; exact fun hc => h ((isQR_periodic (x : ℤ) p).1 hc))]
  have hsum := sum_periodic
    (fun x : ℕ => (if IsQR (x : ℤ) p then (2 : ℚ) / p else 0)) p hper k
  rw [hP, hsum]
  -- one period: `(p+1)/2` residues are QRs
  have hcount : ∑ x ∈ range p, (if IsQR (x : ℤ) p then (2 : ℚ) / p else 0)
      = (((p + 1) / 2 : ℕ) : ℚ) * ((2 : ℚ) / p) := by
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, add_zero, nsmul_eq_mul]
    congr 2
    exact_mod_cast card_isQR_residues hprime hp2
  rw [hcount]
  obtain ⟨m, hm⟩ : ∃ m, p = 2 * m + 1 := by
    rcases hprime.eq_two_or_odd with h | h
    · exact absurd h hp2
    · exact ⟨p / 2, by omega⟩
  have hhalf : (((p + 1) / 2 : ℕ) : ℚ) = ((p : ℚ) + 1) / 2 := by
    have : (p + 1) / 2 = m + 1 := by omega
    rw [this, hm]
    push_cast
    ring
  rw [hhalf, nsmul_eq_mul]
  push_cast
  field_simp

end QRResidual