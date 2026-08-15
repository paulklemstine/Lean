/-
# TRACEPROFILE II — the trace set: exact size and one bit per prime

Phase A research file (Novelty domain), Paper 50 / Experiment 385.

For a finite commutative ring `R` and `N : R` the **trace set** is

`S_R(N) = {x + y : x * y = N}`,

the set of all residues that the trace `s = p + q` of a factorisation of `N` can
possibly take.  The experiment measured `|S_{ZMod m}(N)| = (m+1)/2` for odd primes
`m`, and the *joint law* `|S_{ZMod M#}(N)| / M# = 2^{-ω(M#)}` ("exactly one bit per
prime, additively independent").

This file proves the exact statements.

## Main results

* `mem_traceSet` — the defining membership criterion.
* `card_traceSet_ringEquiv` — the trace set is a ring-isomorphism invariant.
* `traceSet_prod` / `card_traceSet_prod` — the trace set of a product ring is the
  product of the trace sets: **CRT multiplicativity**.
* `card_traceSet_zmod_mul` — the arithmetic CRT form for coprime moduli.
* `card_traceSet_prime` — **the exact size over a prime field**:
  `2 * |S_p(N)| = p + 1` if `N` is a nonzero square mod `p`, and `p - 1` otherwise.
  (This *refines* the experimental reading `(m+1)/2`: the true value is
  `(m + χ(N))/2` with `χ` the quadratic character — a `±1` correction invisible at
  the measured precision, but it is the exact law.)
* `traceNat_primorial` — multiplicativity along a squarefree modulus.
* `traceNat_one_bit_per_prime` — **the joint law**:
  `∏ (p-1) ≤ 2^{ω} * |S_{M}(N)| ≤ ∏ (p+1)` for `M = ∏ p` squarefree odd,
  i.e. the trace set has density `2^{-ω(M)}` up to the `(1 ± 1/p)` corrections.
* `card_traceSet_lt_prime` — the trace really is constrained: over a prime field the
  trace set is a proper subset (about half the residues).
-/

import Mathlib

namespace Novelty.TraceProfile

open Finset

/-! ## The trace set of a finite commutative ring -/

variable {R S : Type*} [CommRing R] [Fintype R] [DecidableEq R]
  [CommRing S] [Fintype S] [DecidableEq S]

/-- All ordered factorisations of `N` inside `R`. -/
def factorPairs (N : R) : Finset (R × R) := univ.filter (fun z => z.1 * z.2 = N)

/-- The **trace set** `{x + y : x*y = N}` of `N` in a finite commutative ring. -/
def traceSet (N : R) : Finset R := (factorPairs N).image (fun z => z.1 + z.2)

@[simp] theorem mem_traceSet {N s : R} :
    s ∈ traceSet N ↔ ∃ x y : R, x * y = N ∧ x + y = s := by
  simp [traceSet, factorPairs, Prod.exists]

/-- The trace set is transported by any ring isomorphism. -/
theorem traceSet_ringEquiv (e : R ≃+* S) (N : R) :
    traceSet (e N) = (traceSet N).image e := by
  ext s
  simp only [mem_traceSet, mem_image]
  constructor
  · rintro ⟨x, y, hxy, rfl⟩
    refine ⟨e.symm x + e.symm y, ⟨e.symm x, e.symm y, ?_, rfl⟩, by simp⟩
    apply e.injective
    simpa using hxy
  · rintro ⟨t, ⟨x, y, hxy, rfl⟩, rfl⟩
    exact ⟨e x, e y, by rw [← map_mul, hxy], by rw [map_add]⟩

theorem card_traceSet_ringEquiv (e : R ≃+* S) (N : R) :
    (traceSet (e N)).card = (traceSet N).card := by
  rw [traceSet_ringEquiv e N, Finset.card_image_of_injective _ e.injective]

/-! ## CRT multiplicativity -/

/-- **The trace set of a product ring is the product of the trace sets.** -/
theorem traceSet_prod (N : R) (M : S) :
    traceSet ((N, M) : R × S) = (traceSet N) ×ˢ (traceSet M) := by
  ext s
  simp only [mem_traceSet, mem_product, Prod.exists, Prod.ext_iff, Prod.mk_mul_mk,
    Prod.mk_add_mk]
  constructor
  · rintro ⟨x1, x2, y1, y2, ⟨h1, h2⟩, h3, h4⟩
    exact ⟨⟨x1, y1, h1, h3⟩, ⟨x2, y2, h2, h4⟩⟩
  · rintro ⟨⟨x1, y1, h1, h3⟩, ⟨x2, y2, h2, h4⟩⟩
    exact ⟨x1, x2, y1, y2, ⟨h1, h2⟩, h3, h4⟩

theorem card_traceSet_prod (N : R) (M : S) :
    (traceSet ((N, M) : R × S)).card = (traceSet N).card * (traceSet M).card := by
  rw [traceSet_prod, Finset.card_product]

/-- **CRT form.**  For coprime moduli the trace-set size is multiplicative. -/
theorem card_traceSet_zmod_mul {m n : ℕ} [NeZero m] [NeZero n]
    (h : Nat.Coprime m n) (N : ℕ) :
    (traceSet ((N : ZMod (m * n)))).card
      = (traceSet ((N : ZMod m))).card * (traceSet ((N : ZMod n))).card := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  have he := card_traceSet_ringEquiv (ZMod.chineseRemainder h) ((N : ZMod (m * n)))
  rw [← he, map_natCast]
  have hpr : ((N : ZMod m × ZMod n)) = ((N : ZMod m), (N : ZMod n)) := by
    ext <;> simp
  rw [hpr, card_traceSet_prod]

/-! ## The exact size over a prime field -/

section Prime

variable {q : ℕ} [hq : Fact (Nat.Prime q)]

theorem two_ne_zero_zmod (hq2 : q ≠ 2) : (2 : ZMod q) ≠ 0 := by
  intro h
  have h2 : ((2 : ℕ) : ZMod q) = 0 := by exact_mod_cast h
  have hd : q ∣ 2 := (ZMod.natCast_eq_zero_iff 2 q).1 h2
  rcases (Nat.dvd_prime Nat.prime_two).1 hd with h1 | h1
  · exact hq.out.one_lt.ne' h1
  · exact hq2 h1

/-- Over a field, the trace set of a nonzero `N` is the image of `x ↦ x + N/x`. -/
theorem traceSet_eq_image_nonzero (N : ZMod q) (hN : N ≠ 0) :
    traceSet N = (univ.filter (fun x : ZMod q => x ≠ 0)).image (fun x => x + N * x⁻¹) := by
  ext s
  simp only [mem_traceSet, mem_image, mem_filter, mem_univ, true_and]
  constructor
  · rintro ⟨x, y, hxy, rfl⟩
    have hx : x ≠ 0 := by
      rintro rfl
      rw [zero_mul] at hxy
      exact hN hxy.symm
    refine ⟨x, hx, ?_⟩
    congr 1
    field_simp
    linear_combination -hxy
  · rintro ⟨x, hx, rfl⟩
    exact ⟨x, N * x⁻¹, by field_simp, rfl⟩

/-- The fibre of `x ↦ x + N/x` over a point of the trace set is `{x₀, N/x₀}`,
hence has two elements unless the discriminant `s² - 4N` vanishes. -/
theorem fiber_card (N s : ZMod q) (hN : N ≠ 0) (hs : s ∈ traceSet N) :
    ((univ.filter (fun x : ZMod q => x ≠ 0)).filter
      (fun x => x + N * x⁻¹ = s)).card = if s ^ 2 = 4 * N then 1 else 2 := by
  rw [traceSet_eq_image_nonzero N hN] at hs
  simp only [mem_image, mem_filter, mem_univ, true_and] at hs
  obtain ⟨x₀, hx₀, hs₀⟩ := hs
  set y₀ : ZMod q := N * x₀⁻¹ with hy₀def
  have hy₀ : y₀ ≠ 0 := mul_ne_zero hN (inv_ne_zero hx₀)
  have hprod : x₀ * y₀ = N := by rw [hy₀def]; field_simp
  have hsum : x₀ + y₀ = s := hs₀
  have hset : ((univ.filter (fun x : ZMod q => x ≠ 0)).filter
      (fun x => x + N * x⁻¹ = s)) = {x₀, y₀} := by
    ext x
    simp only [mem_filter, mem_univ, true_and, mem_insert, mem_singleton]
    constructor
    · rintro ⟨hx, hxs⟩
      have hquad : x * x - s * x + N = 0 := by
        have h' : (x + N * x⁻¹) * x = s * x := by rw [hxs]
        field_simp at h'
        linear_combination h'
      have hfac : (x - x₀) * (x - y₀) = 0 := by
        rw [← hsum, ← hprod] at hquad
        linear_combination hquad
      rcases mul_eq_zero.1 hfac with h | h
      · exact Or.inl (sub_eq_zero.1 h)
      · exact Or.inr (sub_eq_zero.1 h)
    · rintro (rfl | rfl)
      · exact ⟨hx₀, hs₀⟩
      · refine ⟨hy₀, ?_⟩
        have hxy : N * y₀⁻¹ = x₀ := by
          rw [hy₀def]
          field_simp
        rw [hxy, ← hsum]
        ring
  rw [hset]
  by_cases h : s ^ 2 = 4 * N
  · rw [if_pos h]
    have hxy : x₀ = y₀ := by
      have hdiff : (x₀ - y₀) ^ 2 = 0 := by
        have hd : (x₀ - y₀) ^ 2 = s ^ 2 - 4 * N := by
          rw [← hsum, ← hprod]; ring
        rw [hd, h]; ring
      have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hdiff
      exact sub_eq_zero.1 this
    simp [hxy]
  · rw [if_neg h]
    have hne : x₀ ≠ y₀ := by
      intro he
      apply h
      rw [← hsum, ← hprod, he]
      ring
    rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]

/-- The elements of the trace set with vanishing discriminant: two of them when `N`
is a nonzero square, none otherwise. -/
theorem card_degenerate_traces (hq2 : q ≠ 2) (N : ZMod q) (hN : N ≠ 0) :
    ((traceSet N).filter (fun s => s ^ 2 = 4 * N)).card = if IsSquare N then 2 else 0 := by
  have h2 : (2 : ZMod q) ≠ 0 := two_ne_zero_zmod hq2
  by_cases hsq : IsSquare N
  · rw [if_pos hsq]
    obtain ⟨r, hr⟩ := hsq
    have hr0 : r ≠ 0 := by
      rintro rfl
      rw [mul_zero] at hr
      exact hN hr
    have hset : (traceSet N).filter (fun s => s ^ 2 = 4 * N) = {2 * r, -(2 * r)} := by
      ext s
      simp only [mem_filter, mem_traceSet, mem_insert, mem_singleton]
      constructor
      · rintro ⟨-, hs2⟩
        have hfac : (s - 2 * r) * (s + 2 * r) = 0 := by
          rw [hr] at hs2
          linear_combination hs2
        rcases mul_eq_zero.1 hfac with h | h
        · exact Or.inl (sub_eq_zero.1 h)
        · right
          linear_combination h
      · rintro (rfl | rfl)
        · exact ⟨⟨r, r, hr.symm, by ring⟩, by rw [hr]; ring⟩
        · exact ⟨⟨-r, -r, by rw [hr]; ring, by ring⟩, by rw [hr]; ring⟩
    rw [hset]
    have hne : (2 * r) ≠ -(2 * r) := by
      intro h
      have : (2 : ZMod q) * (2 * r) = 0 := by linear_combination h
      rcases mul_eq_zero.1 this with h' | h'
      · exact h2 h'
      · rcases mul_eq_zero.1 h' with h'' | h''
        · exact h2 h''
        · exact hr0 h''
    rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
  · rw [if_neg hsq]
    rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    rintro s -
    intro hs2
    apply hsq
    refine ⟨s * (2 : ZMod q)⁻¹, ?_⟩
    field_simp
    linear_combination -hs2

/-- **The exact trace-set size over a prime field.**
`2 |S_q(N)| = q + 1` when `N` is a nonzero square mod `q`, and `q - 1` otherwise:
the trace is pinned to (essentially) half of the residues, one bit of information. -/
theorem card_traceSet_prime (hq2 : q ≠ 2) (N : ZMod q) (hN : N ≠ 0) :
    2 * (traceSet N).card = if IsSquare N then q + 1 else q - 1 := by
  classical
  have hq3 : 3 ≤ q := by
    have h2 := hq.out.two_le
    omega
  set A : Finset (ZMod q) := univ.filter (fun x : ZMod q => x ≠ 0) with hA
  have hAcard : A.card = q - 1 := by
    have hAe : A = univ.erase (0 : ZMod q) := by
      ext x; simp [hA, Finset.mem_erase]
    rw [hAe, Finset.card_erase_of_mem (mem_univ 0), Finset.card_univ, ZMod.card]
  have himg : traceSet N = A.image (fun x => x + N * x⁻¹) := traceSet_eq_image_nonzero N hN
  have hsum := Finset.card_eq_sum_card_image (fun x : ZMod q => x + N * x⁻¹) A
  rw [hAcard, ← himg] at hsum
  have hsum2 : q - 1 = ∑ s ∈ traceSet N, (if s ^ 2 = 4 * N then 1 else 2) := by
    rw [hsum]
    refine Finset.sum_congr rfl (fun s hs => ?_)
    exact fiber_card N s hN hs
  have hsplit : ∑ s ∈ traceSet N, (if s ^ 2 = 4 * N then 1 else 2)
      = ((traceSet N).filter (fun s => s ^ 2 = 4 * N)).card
        + 2 * ((traceSet N).filter (fun s => ¬ s ^ 2 = 4 * N)).card := by
    rw [Finset.sum_ite]
    simp [Finset.sum_const, mul_comm]
  have hcards : ((traceSet N).filter (fun s => s ^ 2 = 4 * N)).card
      + ((traceSet N).filter (fun s => ¬ s ^ 2 = 4 * N)).card = (traceSet N).card :=
    Finset.card_filter_add_card_filter_not _
  have hdeg := card_degenerate_traces hq2 N hN
  rw [hsplit] at hsum2
  by_cases hsq : IsSquare N
  · rw [if_pos hsq] at hdeg
    rw [hdeg] at hsum2
    rw [if_pos hsq]
    omega
  · rw [if_neg hsq] at hdeg
    rw [hdeg] at hsum2
    rw [if_neg hsq]
    omega

/-- The trace set is a *proper* subset of the residues: the trace is genuinely
constrained (but only by about one bit). -/
theorem card_traceSet_lt_prime (hq2 : q ≠ 2) (N : ZMod q) (hN : N ≠ 0) :
    (traceSet N).card < q := by
  have h2 := hq.out.two_le
  have h := card_traceSet_prime hq2 N hN
  by_cases hsq : IsSquare N
  · rw [if_pos hsq] at h; omega
  · rw [if_neg hsq] at h; omega

end Prime

/-! ## The joint law: one bit per prime

To speak about a varying modulus we use the `Set.ncard` version of the trace-set
size, a *total* function of the modulus (no finiteness instance required). -/

open scoped Classical in
/-- The size of the trace set of `N` modulo `m`, as a total function of `m`. -/
noncomputable def traceNat (m N : ℕ) : ℕ :=
  {s : ZMod m | ∃ x y : ZMod m, x * y = (N : ZMod m) ∧ x + y = s}.ncard

theorem traceNat_eq_card (m N : ℕ) [NeZero m] :
    traceNat m N = (traceSet ((N : ZMod m))).card := by
  classical
  have hset : {s : ZMod m | ∃ x y : ZMod m, x * y = (N : ZMod m) ∧ x + y = s}
      = ↑(traceSet ((N : ZMod m))) := by
    ext s; simp [mem_traceSet]
  rw [traceNat, hset, Set.ncard_coe_finset]

@[simp] theorem traceNat_one (N : ℕ) : traceNat 1 N = 1 := by
  rw [traceNat_eq_card, Finset.card_eq_one]
  refine ⟨0, Finset.eq_singleton_iff_unique_mem.2 ⟨?_, fun x _ => Subsingleton.elim _ _⟩⟩
  rw [mem_traceSet]
  exact ⟨0, 0, Subsingleton.elim _ _, Subsingleton.elim _ _⟩

/-- **CRT multiplicativity, modulus form.** -/
theorem traceNat_mul {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) (h : Nat.Coprime m n) (N : ℕ) :
    traceNat (m * n) N = traceNat m N * traceNat n N := by
  haveI : NeZero m := ⟨hm⟩
  haveI : NeZero n := ⟨hn⟩
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero hm hn⟩
  rw [traceNat_eq_card, traceNat_eq_card, traceNat_eq_card, card_traceSet_zmod_mul h]

open scoped Classical in
/-- **The exact size over a prime modulus**, in the `traceNat` normalisation:
`2 |S_p(N)| = p + χ_p(N)` with `χ` the quadratic character. -/
theorem two_mul_traceNat_prime {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (N : ℕ) (hdvd : ¬ p ∣ N) :
    2 * traceNat p N = if IsSquare ((N : ZMod p)) then p + 1 else p - 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  rw [traceNat_eq_card]
  have h := card_traceSet_prime hp2 ((N : ZMod p))
    (fun h => hdvd ((ZMod.natCast_eq_zero_iff N p).1 h))
  convert h using 2

/-- Multiplicativity of the trace-set size along a squarefree modulus. -/
theorem traceNat_primorial (N : ℕ) :
    ∀ (P : Finset ℕ), (∀ p ∈ P, p.Prime) →
      traceNat (∏ p ∈ P, p) N = ∏ p ∈ P, traceNat p N := by
  classical
  intro P
  induction P using Finset.induction with
  | empty => intro _; simp
  | @insert a P ha ih =>
      intro hP
      have hap : a.Prime := hP a (Finset.mem_insert_self a P)
      have hPp : ∀ p ∈ P, p.Prime := fun p hp => hP p (Finset.mem_insert_of_mem hp)
      have hcop : Nat.Coprime a (∏ p ∈ P, p) :=
        Nat.Coprime.prod_right fun p hp =>
          (Nat.coprime_primes hap (hPp p hp)).2 (by rintro rfl; exact ha hp)
      have hProd : (∏ p ∈ P, p) ≠ 0 :=
        Nat.ne_of_gt (Finset.prod_pos (fun p hp => (hPp p hp).pos))
      rw [Finset.prod_insert ha, Finset.prod_insert ha,
        traceNat_mul hap.ne_zero hProd hcop N, ih hPp]

/-- **The joint law: exactly one bit per prime.**  For a squarefree odd modulus
`M = ∏_{p ∈ P} p` with `N` coprime to `M`,
`∏ (p - 1) ≤ 2^{|P|} · |S_M(N)| ≤ ∏ (p + 1)`.
Each prime halves the trace set, up to the `1 ± 1/p` quadratic-character
correction: the information the trace reveals is additive over the primes, one bit
each, and the trace set has density `2^{-ω(M)}`. -/
theorem traceNat_one_bit_per_prime (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime)
    (h2 : ∀ p ∈ P, p ≠ 2) (N : ℕ) (hN : ∀ p ∈ P, ¬ (p ∣ N)) :
    (∏ p ∈ P, (p - 1)) ≤ 2 ^ P.card * traceNat (∏ p ∈ P, p) N ∧
      2 ^ P.card * traceNat (∏ p ∈ P, p) N ≤ ∏ p ∈ P, (p + 1) := by
  classical
  have hkey : 2 ^ P.card * traceNat (∏ p ∈ P, p) N = ∏ p ∈ P, (2 * traceNat p N) := by
    rw [traceNat_primorial N P hP, Finset.prod_mul_distrib, Finset.prod_const]
  have hbound : ∀ p ∈ P, 2 * traceNat p N
      = if IsSquare ((N : ZMod p)) then p + 1 else p - 1 :=
    fun p hp => two_mul_traceNat_prime (hP p hp) (h2 p hp) N (hN p hp)
  refine ⟨?_, ?_⟩ <;> rw [hkey] <;> refine Finset.prod_le_prod' (fun p hp => ?_) <;>
      rw [hbound p hp] <;> by_cases hs : IsSquare ((N : ZMod p)) <;> simp [hs] <;> omega

open scoped Classical in
/-- The character-free two-sided form of the prime-level law: modulo an odd prime the
trace is confined to half the residues, to within one residue either way. -/
theorem traceNat_half_bounds {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (N : ℕ)
    (hdvd : ¬ p ∣ N) : 2 * traceNat p N ≤ p + 1 ∧ p - 1 ≤ 2 * traceNat p N := by
  have h := two_mul_traceNat_prime hp hp2 N hdvd
  by_cases hs : IsSquare ((N : ZMod p)) <;> rw [h] <;> simp [hs] <;> omega

end Novelty.TraceProfile