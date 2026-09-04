import Applications.PrimePowerBudgetSpectrum
import Applications.BatchSmoothnessYield

/-!
# Abundance of prime-power hits, and what they contribute to the sieve

Third research cycle on experiment 505.  Cycles one and two established that a
prime-power hit is an exact budget shift
(`Catalog/Applications/PrimePowerSmoothnessBudget.lean`) and that the hit
features carry the whole budget
(`Catalog/Applications/PrimePowerBudgetSpectrum.lean`).  Two further questions:

**Q3 (is the hit sub-pool big enough to matter?).**  Yes, and quantitatively:
`smoothCount_ge_pow` gives `Ψ_B(x) ≥ (m+1)^{π(B)}` whenever `P_B^m ≤ x`, where
`P_B` is the primorial of the factor base (`BatchSmoothness.primorialUpTo`).
Applied to the rescaled bound this yields `hitCount_primeSq_ge_pow`: the
`p²`-hit sub-pool is itself exponentially large in `π(B)`.  A feature firing on
an exponentially large sub-pool is not a corner case.

**Q4 (what do hits contribute to the linear-algebra stage?).**  Nothing new.
`isSquare_prod_hit_iff` shows that a sub-family of `p²`-hits has square product
exactly when the rescaled family does: over `𝔽₂` the hit values carry the same
exponent vectors as their cofactors.  So a prime-power hit spends budget without
buying a new relation direction — the precise cost side of the mechanism, and
the reason the hit feature predicts yield rather than mimicking it.

## Main results

* `factorization_prod_pow_self` — the exponent bookkeeping for a factor-base
  product.
* `smoothCount_ge_pow` — **abundance**: `(m+1)^{π(B)} ≤ Ψ_B(x)` once
  `P_B^m ≤ x`.
* `smoothCount_le_pow`, `smoothCount_bracket` — the matching upper bound and the
  two-sided bracket: the pool is polynomial in `log x` of degree `π(B)`.
* `hitCount_primeSq_ge_pow` — abundance of the `p²`-hit sub-pool.
* `isSquare_sq_mul_iff`, `isSquare_prod_hit_iff` — **the 𝔽₂ blind spot**: prime
  powers of even order are invisible to the relation-collection stage.
-/

namespace PrimePowerBudget

open Finset BatchSmoothness

/-! ## Exponent bookkeeping for factor-base products -/

/-- The exponent of a factor-base prime `q` in `∏ p ∈ S, p ^ f p` is `f q`. -/
lemma factorization_prod_pow_self {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime)
    (f : ℕ → ℕ) {q : ℕ} (hq : q ∈ S) :
    (∏ p ∈ S, p ^ f p).factorization q = f q := by
  classical
  rw [Nat.factorization_prod (fun p hp => pow_ne_zero _ (hS p hp).ne_zero)]
  simp only [Finsupp.coe_finset_sum, Finset.sum_apply, Nat.factorization_pow,
    Finsupp.smul_apply, smul_eq_mul]
  rw [Finset.sum_eq_single q]
  · simp [Nat.Prime.factorization (hS q hq)]
  · intro r hr hrq
    rw [Nat.Prime.factorization (hS r hr)]
    simp [Ne.symm hrq]
  · intro h
    exact absurd hq h

/-! ## Abundance of the smooth pool and of its hit sub-pools -/

/-- **Abundance.**  If the factor-base primorial to the `m`-th power fits below
`x`, then the `B`-smooth pool contains at least `(m+1)^{π(B)}` values: one for
each exponent vector with entries `≤ m`.  Unique factorization makes the map
injective, so the count is exact combinatorics, not an estimate. -/
theorem smoothCount_ge_pow (B m x : ℕ) (h : (primorialUpTo B) ^ m ≤ x) :
    (m + 1) ^ (Nat.primesBelow (B + 1)).card ≤ smoothCount B x := by
  classical
  set S := Nat.primesBelow (B + 1) with hSdef
  have hSprime : ∀ p ∈ S, p.Prime := fun p hp => Nat.prime_of_mem_primesBelow hp
  -- the candidate values, indexed by exponent vectors
  set F : (S → Fin (m + 1)) → ℕ := fun f => ∏ p ∈ S.attach, (p : ℕ) ^ (f p : ℕ) with hF
  have hFprod : ∀ f : S → Fin (m + 1),
      F f = ∏ p ∈ S, p ^ (if hp : p ∈ S then ((f ⟨p, hp⟩ : ℕ)) else 0) := by
    intro f
    rw [hF]
    rw [← Finset.prod_attach S (fun p => p ^ (if hp : p ∈ S then ((f ⟨p, hp⟩ : ℕ)) else 0))]
    refine Finset.prod_congr rfl ?_
    rintro ⟨p, hp⟩ _
    simp [hp]
  have hFpos : ∀ f, 0 < F f := by
    intro f
    exact Finset.prod_pos fun p _ => pow_pos (hSprime p.1 p.2).pos _
  have hFle : ∀ f, F f ≤ (primorialUpTo B) ^ m := by
    intro f
    have : F f ≤ ∏ p ∈ S.attach, (p : ℕ) ^ m := by
      refine Finset.prod_le_prod' ?_
      intro p _
      exact Nat.pow_le_pow_right (hSprime p.1 p.2).pos (Nat.lt_succ_iff.1 (f p).isLt)
    calc F f ≤ ∏ p ∈ S.attach, (p : ℕ) ^ m := this
      _ = (∏ p ∈ S.attach, (p : ℕ)) ^ m := by rw [Finset.prod_pow]
      _ = (primorialUpTo B) ^ m := by
            rw [Finset.prod_attach S (fun p => p)]
            rfl
  have hFsmooth : ∀ f, Sm B (F f) := by
    intro f q hq
    have hqp := Nat.prime_of_mem_primeFactors hq
    have hdvd := Nat.dvd_of_mem_primeFactors hq
    rw [hF] at hdvd
    obtain ⟨p, _, hpd⟩ := (Nat.Prime.prime hqp).exists_mem_finset_dvd hdvd
    have : q = (p : ℕ) := (Nat.prime_dvd_prime_iff_eq hqp (hSprime p.1 p.2)).1
      (hqp.dvd_of_dvd_pow hpd)
    have hlt : (p : ℕ) < B + 1 := Nat.lt_of_mem_primesBelow p.2
    omega
  have hinj : Function.Injective F := by
    intro f g hfg
    funext p
    have hp : (p : ℕ) ∈ S := p.2
    have h1 := congrArg (fun n => n.factorization (p : ℕ)) hfg
    simp only [hFprod] at h1
    rw [factorization_prod_pow_self hSprime _ hp,
      factorization_prod_pow_self hSprime _ hp] at h1
    simp only [hp, dif_pos] at h1
    have : ((f p : ℕ)) = ((g p : ℕ)) := by simpa using h1
    exact Fin.ext this
  have hmaps : (Finset.univ.image F) ⊆ (Finset.Icc 1 x).filter (fun v => Sm B v) := by
    intro n hn
    simp only [Finset.mem_image, Finset.mem_univ, true_and] at hn
    obtain ⟨f, rfl⟩ := hn
    simp only [Finset.mem_filter, Finset.mem_Icc]
    exact ⟨⟨hFpos f, le_trans (hFle f) h⟩, hFsmooth f⟩
  have hcard : (Finset.univ.image F).card = (m + 1) ^ S.card := by
    rw [Finset.card_image_of_injective _ hinj, Finset.card_univ]
    simp
  unfold smoothCount
  rw [← hcard]
  exact Finset.card_le_card hmaps

/-- **Scarcity.**  Conversely the smooth pool is *at most* `(⌊log₂ x⌋+1)^{π(B)}`:
the valuation vector of a smooth value has entries bounded by `log₂ x`, and by
unique factorization it determines the value.  Together with
`smoothCount_ge_pow` this brackets `Ψ_B(x)` between two powers with the same
exponent `π(B)`. -/
theorem smoothCount_le_pow (B x : ℕ) :
    smoothCount B x ≤ (Nat.log 2 x + 1) ^ (Nat.primesBelow (B + 1)).card := by
  classical
  set S := Nat.primesBelow (B + 1) with hSdef
  set L := Nat.log 2 x with hL
  set G : ℕ → (S → Fin (L + 1)) := fun v p =>
    if h : v.factorization (p : ℕ) < L + 1 then ⟨v.factorization (p : ℕ), h⟩ else 0 with hG
  have hbound : ∀ v ∈ (Finset.Icc 1 x).filter (fun v => Sm B v), ∀ p : ℕ,
      v.factorization p < L + 1 := by
    intro v hv p
    simp only [Finset.mem_filter, Finset.mem_Icc] at hv
    obtain ⟨⟨hv1, hvx⟩, _⟩ := hv
    by_cases hp : p.Prime
    · have := factorization_le_log_two hp (show v ≠ 0 by omega)
      have := Nat.log_mono_right (b := 2) hvx
      omega
    · simp [Nat.factorization_eq_zero_of_not_prime _ hp]
  have hinj : Set.InjOn G ((Finset.Icc 1 x).filter (fun v => Sm B v)) := by
    intro v hv w hw hvw
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Icc] at hv hw
    refine Nat.eq_of_factorization_eq (by omega) (by omega) ?_
    intro p
    by_cases hp : p.Prime
    · by_cases hpB : p ≤ B
      · have hmem : p ∈ S := Nat.mem_primesBelow.2 ⟨by omega, hp⟩
        have := congrFun hvw ⟨p, hmem⟩
        simp only [hG, dif_pos (hbound v (by simp [Finset.mem_filter, Finset.mem_Icc]; omega) p),
          dif_pos (hbound w (by simp [Finset.mem_filter, Finset.mem_Icc]; omega) p)] at this
        simpa using congrArg Fin.val this
      · have h1 : v.factorization p = 0 := by
          by_contra hne
          exact hpB (hv.2 p (Nat.mem_primeFactors.2 ⟨hp,
            Nat.dvd_of_factorization_pos hne, by omega⟩))
        have h2 : w.factorization p = 0 := by
          by_contra hne
          exact hpB (hw.2 p (Nat.mem_primeFactors.2 ⟨hp,
            Nat.dvd_of_factorization_pos hne, by omega⟩))
        rw [h1, h2]
    · rw [Nat.factorization_eq_zero_of_not_prime _ hp,
        Nat.factorization_eq_zero_of_not_prime _ hp]
  have hcard : ((Finset.Icc 1 x).filter (fun v => Sm B v)).card
      ≤ (Finset.univ : Finset (S → Fin (L + 1))).card :=
    Finset.card_le_card_of_injOn G (fun _ _ => Finset.mem_univ _) hinj
  refine le_trans hcard ?_
  rw [Finset.card_univ]
  simp

/-- **The hit sub-pool is abundant too.**  Applying the abundance bound at the
rescaled bound `x / p²`: prime-power hits are exponentially many in `π(B)`. -/
theorem hitCount_primeSq_ge_pow {B p : ℕ} (m x : ℕ) (hp : p.Prime) (hpB : p ≤ B)
    (h : (primorialUpTo B) ^ m ≤ x / p ^ 2) :
    (m + 1) ^ (Nat.primesBelow (B + 1)).card ≤ hitCount B (p ^ 2) x := by
  rw [hitCount_primeSq x hp hpB]
  exact smoothCount_ge_pow B m _ h

/-- **Two-sided bracket.**  The smooth count sits between two `π(B)`-th powers:
`(m+1)^{π(B)} ≤ Ψ_B(x) ≤ (⌊log₂ x⌋+1)^{π(B)}` whenever `P_B^m ≤ x`.  The pool
is therefore polynomial in `log x` of degree exactly `π(B)`, which is what makes
the `2 log p / log B` budget shift of a prime-power hit a first-order effect. -/
theorem smoothCount_bracket (B m x : ℕ) (h : (primorialUpTo B) ^ m ≤ x) :
    (m + 1) ^ (Nat.primesBelow (B + 1)).card ≤ smoothCount B x ∧
      smoothCount B x ≤ (Nat.log 2 x + 1) ^ (Nat.primesBelow (B + 1)).card :=
  ⟨smoothCount_ge_pow B m x h, smoothCount_le_pow B x⟩

/-! ## The `𝔽₂` blind spot -/

/-- Multiplying by a nonzero square does not change squareness. -/
lemma isSquare_sq_mul_iff {a b : ℕ} (ha : a ≠ 0) : IsSquare (a ^ 2 * b) ↔ IsSquare b := by
  constructor
  · rintro ⟨d, hd⟩
    have hdvd : a ∣ d := by
      have hd2 : a ^ 2 ∣ d ^ 2 := ⟨b, by rw [pow_two, ← hd]⟩
      exact (Nat.pow_dvd_pow_iff (by norm_num)).1 hd2
    obtain ⟨e, rfl⟩ := hdvd
    refine ⟨e, ?_⟩
    have ha2 : (0 : ℕ) < a ^ 2 := Nat.pos_of_ne_zero (pow_ne_zero _ ha)
    have hmul : a ^ 2 * b = a ^ 2 * (e * e) := by rw [hd]; ring
    exact Nat.eq_of_mul_eq_mul_left ha2 hmul
  · rintro ⟨c, rfl⟩
    exact ⟨a * c, by ring⟩

/-- **Prime-power hits are invisible to the relation stage.**  A sub-family of
`p²`-hit values has a perfect-square product exactly when the family of their
cofactors does.  The `p²` part contributes an even exponent to every member, so
it never changes an `𝔽₂` exponent vector: the hit spends smoothness budget
without buying a relation. -/
theorem isSquare_prod_hit_iff {ι : Type*} (S : Finset ι) {p : ℕ}
    (hp : 0 < p) (w : ι → ℕ) :
    IsSquare (∏ i ∈ S, (p ^ 2 * w i)) ↔ IsSquare (∏ i ∈ S, w i) := by
  have hsplit : (∏ i ∈ S, (p ^ 2 * w i)) = (p ^ S.card) ^ 2 * ∏ i ∈ S, w i := by
    rw [Finset.prod_mul_distrib, Finset.prod_const, ← pow_mul, ← pow_mul,
      Nat.mul_comm S.card 2]
  rw [hsplit]
  exact isSquare_sq_mul_iff (pow_ne_zero _ hp.ne')

/-- The quantitative form for the sieve: a batch of `π(B) + 1` positive
`B`-smooth `p²`-hits yields a nonempty sub-family whose *cofactor* product is a
perfect square, and the corresponding relation is already present in the
rescaled pool.  (Combines `BatchYield.exists_square_subproduct` with the blind
spot.) -/
theorem hit_relation_comes_from_cofactors {B : ℕ} {ι : Type*} [Fintype ι] [DecidableEq ι]
    {p : ℕ} (hp : 0 < p) (w : ι → ℕ) (hwpos : ∀ i, 0 < w i)
    (hsmooth : ∀ i, IsSmooth B (p ^ 2 * w i))
    (h : (Nat.primesBelow (B + 1)).card < Fintype.card ι) :
    ∃ S : Finset ι, S.Nonempty ∧ IsSquare (∏ i ∈ S, w i) := by
  obtain ⟨S, hSne, hsq⟩ := BatchYield.exists_square_subproduct (B := B)
    (fun i => p ^ 2 * w i) (fun i => Nat.mul_pos (pow_pos hp 2) (hwpos i)) hsmooth h
  exact ⟨S, hSne, (isSquare_prod_hit_iff S hp w).1 hsq⟩

end PrimePowerBudget