import Mathlib

/-!
# The QR lottery dial: a zero-fit closed form for the per-`N` sieve footprint

This file formalises the *theory dial* `T(N) = ∑ 2/p` over the primes `p` of a factor
base for which `N` is a quadratic residue.  The empirical claim under investigation is
that this expression — which contains **no fitted coefficient whatsoever** — is the
correct per-`N` yield statistic, and that the *quadratic-residue indicator bit* is a
sufficient statistic for the measured hit fraction ("H3").

Here we prove the exact arithmetic statements behind that claim.

## Main definitions

* `QRLotto.rootSet p N`, `QRLotto.rootCount p N` — the residues `x ∈ [0,p)` with
  `x² ≡ N (mod p)` and their number: the sieve positions that the prime `p` hits.
* `QRLotto.qrBit p N` — the quadratic-residue indicator bit of `N` at `p`.
* `QRLotto.hitDensity p N` — the *measured* fraction `rootCount / p` of sieve positions hit.
* `QRLotto.theoryDial S N = ∑ p ∈ S, N QR mod p, 2/p` — the zero-fit dial.
* `QRLotto.footprint S N = ∑ p ∈ S, hitDensity p N` — the expected total footprint.
* `QRLotto.chi p N = rootCount p N - 1` — the counting form of the Legendre symbol.

## Main results

* `QRLotto.rootCount_eq_legendreSym_add_one` — `#roots = χ_p(N) + 1`: the counting
  function *is* the Legendre symbol shifted, for every odd prime.
* `QRLotto.hitDensity_eq_ite` — **the lottery law / H3**: the measured fraction equals
  `2/p` when the bit is on and `0` when it is off.  The bit is a sufficient statistic:
  no extra fitted number can carry information beyond it.
* `QRLotto.theoryDial_eq_footprint` — **the zero-fit theorem**: the closed-form dial is
  *exactly* the expected footprint, with the coefficient `2/p` forced, not fitted.
* `QRLotto.theoryDial_eq_mertens_add_charSum` — the dial splits as a Mertens main term
  `∑ 1/p` plus a Legendre character fluctuation `∑ χ_p(N)/p`.
* `QRLotto.sum_rootCount_eq_self`, `QRLotto.sum_hitDensity_eq_one`,
  `QRLotto.card_winners` — **fairness of the lottery**: exactly `(p-1)/2` of the
  nonzero classes win, and the mean hit density over `N` is exactly `1/p`.
* `QRLotto.theoryDial_mono`, `QRLotto.theoryDial_truncation_deficit` — truncating the
  factor base can only *lower* the dial, by exactly the tail `∑ 2/p` over winning
  truncated primes.
-/

open Finset

namespace QRLotto

/-! ## The footprint of a single prime -/

/-- The residues `x ∈ [0, p)` with `x² ≡ N (mod p)`: the sieve positions hit by `p`. -/
def rootSet (p : ℕ) (N : ℤ) : Finset ℕ := {x ∈ Finset.range p | ((p : ℤ) ∣ (x : ℤ) ^ 2 - N)}

/-- The number of sieve positions mod `p` hit by the prime `p` for the target `N`. -/
def rootCount (p : ℕ) (N : ℤ) : ℕ := (rootSet p N).card

/-- The quadratic-residue indicator bit of `N` at `p`. -/
def qrBit (p : ℕ) (N : ℤ) : Bool := decide (0 < rootCount p N)

/-- The measured fraction of sieve positions mod `p` that the prime `p` hits. -/
noncomputable def hitDensity (p : ℕ) (N : ℤ) : ℝ := (rootCount p N : ℝ) / p

/-- The counting form of the quadratic character: `#roots - 1`. -/
def chi (p : ℕ) (N : ℤ) : ℤ := (rootCount p N : ℤ) - 1

lemma mem_rootSet_iff (p : ℕ) [NeZero p] (N : ℤ) (x : ℕ) :
    x ∈ rootSet p N ↔ x < p ∧ ((x : ZMod p) ^ 2 = (N : ZMod p)) := by
  simp only [rootSet, Finset.mem_filter, Finset.mem_range, and_congr_right_iff]
  intro _
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  constructor
  · intro h; linear_combination h
  · intro h; linear_combination h

/-- The integer count of roots agrees with the count of square roots in `ZMod p`. -/
lemma rootCount_eq_card_zmod (p : ℕ) [NeZero p] (N : ℤ) :
    rootCount p N = #{x : ZMod p | x ^ 2 = (N : ZMod p)} := by
  apply Finset.card_nbij (i := fun x : ℕ => ((x : ℕ) : ZMod p))
  · intro x hx
    simp only [Finset.mem_coe, mem_rootSet_iff] at hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
    exact hx.2
  · intro x hx y hy hxy
    simp only [Finset.mem_coe, mem_rootSet_iff] at hx hy
    have := congrArg ZMod.val hxy
    rwa [ZMod.val_natCast_of_lt hx.1, ZMod.val_natCast_of_lt hy.1] at this
  · intro y hy
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hy
    refine ⟨y.val, ?_, ?_⟩
    · simp only [Finset.mem_coe, mem_rootSet_iff]
      exact ⟨ZMod.val_lt y, by rw [ZMod.natCast_val, ZMod.cast_id]; exact hy⟩
    · simp [ZMod.natCast_val, ZMod.cast_id]

/-- **The counting function is the Legendre symbol.**  For an odd prime `p`, the number of
sieve positions hit is `χ_p(N) + 1`. -/
theorem rootCount_eq_legendreSym_add_one (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ℤ) :
    (rootCount p N : ℤ) = legendreSym p N + 1 := by
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n]; exact_mod_cast hp
  have h := quadraticChar_card_sqrts hchar ((N : ZMod p))
  rw [Set.toFinset_setOf] at h
  rw [rootCount_eq_card_zmod p N, h, legendreSym]

/-- The counting character `chi` *is* the Legendre symbol at odd primes. -/
theorem chi_eq_legendreSym (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ℤ) :
    chi p N = legendreSym p N := by
  rw [chi, rootCount_eq_legendreSym_add_one p hp N]; ring

/-- If `p ∤ N` and `N` is a square mod `p`, the prime hits exactly two positions. -/
theorem rootCount_eq_two (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hN : ¬ (p : ℤ) ∣ N) (hsq : IsSquare ((N : ZMod p))) : rootCount p N = 2 := by
  have hne : ((N : ZMod p)) ≠ 0 := by
    rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]; exact hN
  have h1 : legendreSym p N = 1 := (legendreSym.eq_one_iff p hne).2 hsq
  have := rootCount_eq_legendreSym_add_one p hp N
  rw [h1] at this
  exact_mod_cast this

/-- If `N` is not a square mod `p`, the prime hits no position at all. -/
theorem rootCount_eq_zero (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hsq : ¬ IsSquare ((N : ZMod p))) : rootCount p N = 0 := by
  have h1 : legendreSym p N = -1 := quadraticChar_neg_one_iff_not_isSquare.2 hsq
  have h2 := rootCount_eq_legendreSym_add_one p hp N
  rw [h1] at h2
  norm_num at h2
  exact_mod_cast h2

/-- The bit is on exactly when `N` is a square mod `p`. -/
theorem qrBit_iff (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (N : ℤ) :
    qrBit p N = true ↔ IsSquare ((N : ZMod p)) := by
  constructor
  · intro h
    by_contra hsq
    rw [qrBit, decide_eq_true_eq, rootCount_eq_zero p hp hsq] at h
    exact lt_irrefl 0 h
  · intro hsq
    have hp0 : (0 : ℕ) < p := (Fact.out : p.Prime).pos
    have : 0 < rootCount p N := by
      rcases hsq with ⟨r, hr⟩
      have : r.val ∈ rootSet p N := by
        rw [mem_rootSet_iff]
        refine ⟨ZMod.val_lt r, ?_⟩
        rw [ZMod.natCast_val, ZMod.cast_id, hr]; ring
      exact Finset.card_pos.2 ⟨r.val, this⟩
    simpa [qrBit] using this

/-- **The lottery law (H3).**  For an odd prime `p` not dividing `N`, the *measured*
hit fraction is a deterministic function of the single indicator bit: it is `2/p` when
`N` is a residue and exactly `0` otherwise.  Hence the bit is a sufficient statistic and
no fitted per-prime coefficient can add information. -/
theorem hitDensity_eq_ite (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hN : ¬ (p : ℤ) ∣ N) :
    hitDensity p N = if qrBit p N then (2 : ℝ) / p else 0 := by
  by_cases h : IsSquare ((N : ZMod p))
  · rw [if_pos ((qrBit_iff p hp N).2 h), hitDensity, rootCount_eq_two p hp hN h]
    norm_num
  · have hb : qrBit p N = false := by
      by_contra hb
      exact h ((qrBit_iff p hp N).1 (by simpa using hb))
    rw [hb, if_neg (by simp), hitDensity, rootCount_eq_zero p hp h]
    simp

/-! ## The dial -/

variable (S : Finset ℕ)

/-- The **zero-fit theory dial** `T(N) = ∑_{p ∈ S, N QR mod p} 2/p`. -/
noncomputable def theoryDial (S : Finset ℕ) (N : ℤ) : ℝ :=
  ∑ p ∈ S with qrBit p N = true, (2 : ℝ) / p

/-- The expected total footprint of the factor base `S` at `N`. -/
noncomputable def footprint (S : Finset ℕ) (N : ℤ) : ℝ := ∑ p ∈ S, hitDensity p N

/-- The Mertens main term `∑_{p ∈ S} 1/p`. -/
noncomputable def mertens (S : Finset ℕ) : ℝ := ∑ p ∈ S, (1 : ℝ) / p

/-- The Legendre character fluctuation `∑_{p ∈ S} χ_p(N)/p`. -/
noncomputable def charSum (S : Finset ℕ) (N : ℤ) : ℝ := ∑ p ∈ S, (chi p N : ℝ) / p

/-- A factor base of odd primes, none of which divides `N`. -/
def GoodBase (S : Finset ℕ) (N : ℤ) : Prop :=
  ∀ p ∈ S, p.Prime ∧ p ≠ 2 ∧ ¬ (p : ℤ) ∣ N

/-- **The zero-fit theorem.**  Over an admissible factor base the closed-form dial
`∑ 2/p` equals the expected footprint exactly: the coefficient `2/p` attached to each
indicator bit is *forced by first principles*, not fitted. -/
theorem theoryDial_eq_footprint {S : Finset ℕ} {N : ℤ} (h : GoodBase S N) :
    theoryDial S N = footprint S N := by
  rw [theoryDial, footprint, Finset.sum_filter]
  refine Finset.sum_congr rfl (fun p hp => ?_)
  obtain ⟨hprime, h2, hdvd⟩ := h p hp
  haveI : Fact p.Prime := ⟨hprime⟩
  rw [hitDensity_eq_ite p h2 hdvd]

/-- The per-prime density in Legendre form: `#roots/p = (1 + χ_p(N))/p`. -/
theorem hitDensity_eq_chi (p : ℕ) (N : ℤ) : hitDensity p N = (1 + (chi p N : ℝ)) / p := by
  rw [hitDensity, chi]
  push_cast
  ring_nf

/-- **Mertens term plus character fluctuation.**  The dial decomposes as a term that
does not depend on `N` at all plus a Legendre character sum. -/
theorem theoryDial_eq_mertens_add_charSum {S : Finset ℕ} {N : ℤ} (h : GoodBase S N) :
    theoryDial S N = mertens S + charSum S N := by
  rw [theoryDial_eq_footprint h, footprint, mertens, charSum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun p hp => ?_)
  rw [hitDensity_eq_chi]
  ring

/-- The dial is squeezed between `0` and twice the Mertens term. -/
theorem theoryDial_nonneg (S : Finset ℕ) (N : ℤ) (hS : ∀ p ∈ S, 0 < p) :
    0 ≤ theoryDial S N := by
  refine Finset.sum_nonneg (fun p hp => ?_)
  have := hS p (Finset.mem_filter.1 hp).1
  positivity

theorem theoryDial_le_two_mertens (S : Finset ℕ) (N : ℤ) (hS : ∀ p ∈ S, 0 < p) :
    theoryDial S N ≤ 2 * mertens S := by
  have h1 : theoryDial S N ≤ ∑ p ∈ S, (2 : ℝ) / p :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun p hp _ => by have := hS p hp; positivity)
  have h2 : ∑ p ∈ S, (2 : ℝ) / p = 2 * mertens S := by
    rw [mertens, Finset.mul_sum]
    exact Finset.sum_congr rfl (fun p _ => by ring)
  linarith

/-- **Truncation can only lower the dial**: keeping the full `p ≤ 400` support dominates
any bit truncation. -/
theorem theoryDial_mono {S S' : Finset ℕ} (hSS : S ⊆ S') (N : ℤ) (hS : ∀ p ∈ S', 0 < p) :
    theoryDial S N ≤ theoryDial S' N := by
  refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset_filter _ hSS) ?_
  intro p hp _
  have := hS p (Finset.mem_filter.1 hp).1
  positivity

/-- The exact deficit incurred by truncating the factor base from `S'` to `S ⊆ S'`. -/
theorem theoryDial_truncation_deficit {S S' : Finset ℕ} (hSS : S ⊆ S') (N : ℤ) :
    theoryDial S' N - theoryDial S N = ∑ p ∈ (S' \ S) with qrBit p N = true, (2 : ℝ) / p := by
  have hfil : {p ∈ S' \ S | qrBit p N = true}
      = {p ∈ S' | qrBit p N = true} \ {p ∈ S | qrBit p N = true} := by
    ext p
    simp only [Finset.mem_filter, Finset.mem_sdiff, not_and]
    tauto
  rw [theoryDial, theoryDial, hfil,
    Finset.sum_sdiff_eq_sub (Finset.filter_subset_filter _ hSS)]

/-! ## Fairness of the lottery -/

/-- Summed over all residue classes of `N`, a prime hits exactly `p` positions:
every `x` is the root of exactly one class. -/
theorem sum_rootCount_eq_self (p : ℕ) [NeZero p] :
    ∑ N ∈ Finset.range p, rootCount p N = p := by
  have key : ∑ a : ZMod p, #{x : ZMod p | x ^ 2 = a} = Fintype.card (ZMod p) := by
    rw [Fintype.card, eq_comm]
    exact Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_univ (x ^ 2))
  have hcast : ∑ N ∈ Finset.range p, rootCount p N
      = ∑ a : ZMod p, #{x : ZMod p | x ^ 2 = a} := by
    rw [← Finset.sum_nbij (i := fun N : ℕ => ((N : ℕ) : ZMod p))
      (t := (Finset.univ : Finset (ZMod p)))
      (g := fun a : ZMod p => #{x : ZMod p | x ^ 2 = a})]
    · exact fun N _ => Finset.mem_univ _
    · intro x hx y hy hxy
      simp only [Finset.coe_range, Set.mem_Iio] at hx hy
      have := congrArg ZMod.val hxy
      rwa [ZMod.val_natCast_of_lt hx, ZMod.val_natCast_of_lt hy] at this
    · intro a _
      refine ⟨a.val, ?_, ?_⟩
      · simpa using ZMod.val_lt a
      · simp [ZMod.natCast_val, ZMod.cast_id]
    · intro N hN
      rw [rootCount_eq_card_zmod]
      simp
  rw [hcast, key, ZMod.card]

/-- **Mean hit density.**  Averaged over the `p` classes of `N`, each prime contributes
exactly one expected hit; i.e. the mean of `hitDensity` over `N` is exactly `1/p`. -/
theorem sum_hitDensity_eq_one (p : ℕ) [NeZero p] :
    ∑ N ∈ Finset.range p, hitDensity p N = 1 := by
  have hp : (p : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  have : ∑ N ∈ Finset.range p, hitDensity p N
      = (∑ N ∈ Finset.range p, (rootCount p N : ℝ)) / p := by
    rw [Finset.sum_div]; rfl
  rw [this, ← Nat.cast_sum, sum_rootCount_eq_self p]
  field_simp

/-- The winning classes at `p`: the residues `N ∈ [0,p)` for which the prime `p`
contributes two sieve hits, i.e. the nonzero quadratic residues. -/
def winners (p : ℕ) : Finset ℕ := (Finset.range p).filter (fun N => rootCount p (N : ℤ) = 2)

lemma mem_winners_iff {p N : ℕ} : N ∈ winners p ↔ N < p ∧ rootCount p (N : ℤ) = 2 := by
  simp [winners, Finset.mem_filter, Finset.mem_range]

/-- **The lottery is fair.**  For an odd prime `p`, exactly `(p-1)/2` of the `p` residue
classes of `N` are winning tickets (nonzero quadratic residues): `2·W + 1 = p`. -/
theorem rootCount_zero (p : ℕ) [Fact p.Prime] : rootCount p 0 = 1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hset : rootSet p 0 = {0} := by
    ext x
    simp only [mem_rootSet_iff, Finset.mem_singleton, Int.cast_zero]
    constructor
    · rintro ⟨hx, hx2⟩
      rw [pow_eq_zero_iff two_ne_zero] at hx2
      have := congrArg ZMod.val hx2
      rwa [ZMod.val_natCast_of_lt hx, ZMod.val_zero] at this
    · rintro rfl
      exact ⟨(Fact.out : p.Prime).pos, by norm_num⟩
  rw [rootCount, hset, Finset.card_singleton]

/-- Away from the ramified class, a prime either hits twice or not at all: there is no
intermediate footprint.  This is the exact "lottery table" of the QR draw. -/
theorem rootCount_eq_two_or_zero (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {N : ℤ}
    (hN : ¬ (p : ℤ) ∣ N) : rootCount p N = 2 ∨ rootCount p N = 0 := by
  by_cases h : IsSquare ((N : ZMod p))
  · exact Or.inl (rootCount_eq_two p hp hN h)
  · exact Or.inr (rootCount_eq_zero p hp h)

/-- **The lottery is fair.**  For an odd prime `p`, the number `W` of winning classes
(nonzero quadratic residues) satisfies `2W + 1 = p`, i.e. `W = (p-1)/2`. -/
theorem card_winners (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    2 * (winners p).card + 1 = p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  classical
  have hsub : winners p ⊆ Finset.range p :=
    Finset.filter_subset _ _
  have hsplit : ∑ N ∈ Finset.range p \ winners p,
        rootCount p (N : ℤ)
      + ∑ N ∈ winners p, rootCount p (N : ℤ)
      = ∑ N ∈ Finset.range p, rootCount p (N : ℤ) := Finset.sum_sdiff hsub
  have hAsum : ∑ N ∈ winners p, rootCount p (N : ℤ)
      = 2 * (winners p).card := by
    rw [Finset.sum_congr rfl (fun N hN => (mem_winners_iff.1 hN).2), Finset.sum_const,
      smul_eq_mul, mul_comm]
  have h0mem : 0 ∈ Finset.range p \ winners p := by
    simp only [Finset.mem_sdiff, Finset.mem_range, mem_winners_iff, not_and]
    refine ⟨(Fact.out : p.Prime).pos, fun _ => ?_⟩
    simp [rootCount_zero]
  have hrest : ∑ N ∈ (Finset.range p \
      winners p).erase 0, rootCount p (N : ℤ) = 0 := by
    refine Finset.sum_eq_zero (fun N hN => ?_)
    have hne : N ≠ 0 := (Finset.mem_erase.1 hN).1
    have hmem := (Finset.mem_erase.1 hN).2
    have hlt : N < p := Finset.mem_range.1 (Finset.mem_sdiff.1 hmem).1
    have hnotA := (Finset.mem_sdiff.1 hmem).2
    have hdvd : ¬ (p : ℤ) ∣ (N : ℤ) := by
      intro h
      have hnd : (p : ℕ) ∣ N := by exact_mod_cast h
      exact absurd (Nat.le_of_dvd (Nat.pos_of_ne_zero hne) hnd) (not_le.2 hlt)
    rcases rootCount_eq_two_or_zero p hp hdvd with h2 | h2
    · exact absurd (mem_winners_iff.2 ⟨hlt, h2⟩) hnotA
    · exact h2
  have hcomp : ∑ N ∈ Finset.range p \ winners p,
      rootCount p (N : ℤ) = 1 := by
    rw [← Finset.add_sum_erase _ _ h0mem, hrest]
    simp [rootCount_zero]
  rw [sum_rootCount_eq_self p, hAsum, hcomp] at hsplit
  omega

/-- **Half the tickets win.**  Among the `p - 1` invertible classes of `N`, exactly half
are quadratic residues, so the mean value of the dial's `p`-th bit is `1/2` — no fitted
prior is possible. -/
theorem winners_density (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ((winners p).card : ℝ) / ((p : ℝ) - 1) = 1 / 2 := by
  have h := card_winners p hp
  have hp3 : 3 ≤ p := by
    have := (Fact.out : p.Prime).two_le
    omega
  have hR : (2 : ℝ) * ((winners p).card : ℝ) + 1 = (p : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) h
  have hne : (p : ℝ) - 1 ≠ 0 := by
    have : (3 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp3
    linarith
  field_simp
  linarith

/-- The mean of the dial over a full period of one prime: averaged over the `p` classes,
`p` contributes exactly `1/p` — the Mertens weight, with no fitted constant. -/
theorem mean_hitDensity (p : ℕ) [NeZero p] :
    (∑ N ∈ Finset.range p, hitDensity p N) / p = 1 / p := by
  rw [sum_hitDensity_eq_one p]

/-! ## The total dial: including the ramified primes -/

/-- The root count depends only on the residue class of `N`. -/
lemma rootCount_congr (p : ℕ) [NeZero p] {N N' : ℤ} (h : (N : ZMod p) = (N' : ZMod p)) :
    rootCount p N = rootCount p N' := by
  rw [rootCount_eq_card_zmod, rootCount_eq_card_zmod, h]

/-- At a prime dividing `N` the footprint is the *half* weight `1/p`: there is a single
(ramified) root. -/
theorem rootCount_of_dvd (p : ℕ) [Fact p.Prime] {N : ℤ} (h : (p : ℤ) ∣ N) :
    rootCount p N = 1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hz : ((N : ℤ) : ZMod p) = ((0 : ℤ) : ZMod p) := by
    rw [Int.cast_zero, ZMod.intCast_zmod_eq_zero_iff_dvd]
    exact h
  rw [rootCount_congr p hz]
  simpa using rootCount_zero p

/-- The **total dial**: the closed form valid for *every* `N`, with the ramified primes
carrying the half weight `1/p`. -/
noncomputable def totalDial (S : Finset ℕ) (N : ℤ) : ℝ :=
  ∑ p ∈ S, (if (p : ℤ) ∣ N then 1 / (p : ℝ) else if qrBit p N then 2 / (p : ℝ) else 0)

/-- **The total dial is exact, with no coprimality hypothesis.**  Adding the half-weight
`1/p` at the primes dividing `N` turns the zero-fit dial into a total function of `N`
that still equals the expected footprint exactly. -/
theorem totalDial_eq_footprint {S : Finset ℕ} {N : ℤ}
    (h : ∀ p ∈ S, p.Prime ∧ p ≠ 2) : totalDial S N = footprint S N := by
  refine Finset.sum_congr rfl (fun p hp => ?_)
  obtain ⟨hprime, h2⟩ := h p hp
  haveI : Fact p.Prime := ⟨hprime⟩
  by_cases hdvd : (p : ℤ) ∣ N
  · rw [if_pos hdvd, hitDensity, rootCount_of_dvd p hdvd]
    norm_num
  · rw [if_neg hdvd, hitDensity_eq_ite p h2 hdvd]

/-- On an admissible base the total dial and the zero-fit dial agree. -/
theorem totalDial_eq_theoryDial {S : Finset ℕ} {N : ℤ} (h : GoodBase S N) :
    totalDial S N = theoryDial S N := by
  rw [totalDial_eq_footprint (fun p hp => ⟨(h p hp).1, (h p hp).2.1⟩),
    theoryDial_eq_footprint h]

end QRLotto