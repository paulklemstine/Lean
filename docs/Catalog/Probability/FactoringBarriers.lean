/-
# Barriers I: the polynomial barrier, rational escape, holomorphic rigidity

Three of the eight barriers of the Factoring Lab framework, proved.

* `FactoringLab.polynomial_barrier` — no polynomial with rational coefficients
  computes the smaller prime factor of a semiprime.
* `FactoringLab.rational_escape_illusory` (WWW) — the same for *rational
  functions* `A/B`: passing from polynomials to quotients buys nothing.
* `FactoringLab.algebraic_barrier` — the strongest form: *no* nonzero
  polynomial relation `F(N, p) = 0` in two variables over `ℚ` holds for all
  semiprimes.  The polynomial and rational barriers are special cases.
* `FactoringLab.polynomial_barrier_counting` — a quantitative version: for a
  fixed small factor `p`, a polynomial of degree `d` can return the correct
  factor at no more than `d` semiprimes `pq`.
* `FactoringLab.holomorphic_rigidity` / `holomorphic_rigidity_barrier` (HRB) —
  an entire function that reproduces the reciprocal of the smaller prime factor
  at the reciprocals of semiprimes is forced by the identity theorem to be
  constant, which is impossible.

The proofs share one mechanism: fixing the small factor makes the sample set
accumulate (at infinity for polynomials, at `0` for the holomorphic version),
and rigidity of the function class then forces a constant, which two different
choices of the small factor contradict.
-/
import Mathlib

namespace FactoringLab

open Polynomial Filter Set

/-! ### Arithmetic input: infinitely many primes above any bound -/

/-- There are infinitely many primes exceeding any given bound. -/
theorem infinite_primes_gt (m : ℕ) : {q : ℕ | q.Prime ∧ m < q}.Infinite := by
  have h : ({q : ℕ | q.Prime} \ {q : ℕ | q ≤ m}).Infinite :=
    Nat.infinite_setOf_prime.diff (Set.finite_Iic m)
  refine h.mono ?_
  intro q hq
  exact ⟨hq.1, lt_of_not_ge (fun hle => hq.2 hle)⟩

/-- Scaling an infinite set of naturals by a nonzero rational keeps it infinite
inside `ℚ`. -/
theorem infinite_smul_image {S : Set ℕ} (hS : S.Infinite) {c : ℚ} (hc : c ≠ 0) :
    ((fun q : ℕ => c * (q : ℚ)) '' S).Infinite := by
  refine hS.image ?_
  intro a _ b _ hab
  have : (a : ℚ) = b := mul_left_cancel₀ hc hab
  exact_mod_cast this

/-! ### The polynomial and rational barriers -/

/-- **Rational escape is illusory (WWW).**  There is no rational function
`A/B` over `ℚ` that, evaluated at a semiprime `N = p*q` with `p < q` both
prime, returns the smaller prime factor `p`.  (The hypothesis includes that the
denominator does not vanish at the sample points, so the quotient is defined
there.) -/
theorem rational_escape_illusory (A B : Polynomial ℚ) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        B.eval ((p * q : ℕ) : ℚ) ≠ 0 ∧
          A.eval ((p * q : ℕ) : ℚ) = (p : ℚ) * B.eval ((p * q : ℕ) : ℚ) := by
  intro h
  -- The polynomial `A - 3•B` vanishes at `3q` for every prime `q > 3`.
  set C : Polynomial ℚ := A - Polynomial.C 3 * B with hC
  have hroot : ∀ x ∈ (fun q : ℕ => (3 : ℚ) * (q : ℚ)) '' {q : ℕ | q.Prime ∧ 3 < q},
      C.IsRoot x := by
    rintro x ⟨q, ⟨hq, hq3⟩, rfl⟩
    have h3 : Nat.Prime 3 := by norm_num
    have := (h 3 q h3 hq hq3).2
    have hcast : (((3 * q : ℕ) : ℚ)) = (3 : ℚ) * (q : ℚ) := by push_cast; ring
    rw [hcast] at this
    simp only [hC, IsRoot, eval_sub, eval_mul, eval_C]
    rw [this]
    push_cast
    ring
  have hinf : {x : ℚ | C.IsRoot x}.Infinite := by
    refine Set.Infinite.mono hroot ?_
    exact infinite_smul_image (infinite_primes_gt 3) (by norm_num)
  have hC0 : C = 0 := Polynomial.eq_zero_of_infinite_isRoot C hinf
  -- Hence `A = 3B` identically, contradicting the value at `N = 35 = 5 * 7`.
  have hAB : ∀ x : ℚ, A.eval x = 3 * B.eval x := by
    intro x
    have : C.eval x = 0 := by rw [hC0]; simp
    simp only [hC, eval_sub, eval_mul, eval_C, sub_eq_zero] at this
    exact this
  have h5 : Nat.Prime 5 := by norm_num
  have h7 : Nat.Prime 7 := by norm_num
  obtain ⟨hne, heq⟩ := h 5 7 h5 h7 (by norm_num)
  rw [hAB] at heq
  have : (2 : ℚ) * B.eval ((5 * 7 : ℕ) : ℚ) = 0 := by push_cast at heq ⊢; linarith
  have : B.eval ((5 * 7 : ℕ) : ℚ) = 0 := by linarith
  exact hne this

/-- **The polynomial barrier.**  No polynomial with rational coefficients maps a
semiprime `N = p*q` (with `p < q` prime) to its smaller prime factor `p`.
Special case of `rational_escape_illusory` with denominator `1`. -/
theorem polynomial_barrier (P : Polynomial ℚ) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q → P.eval ((p * q : ℕ) : ℚ) = (p : ℚ) := by
  intro h
  refine rational_escape_illusory P 1 ?_
  intro p q hp hq hpq
  refine ⟨by simp, ?_⟩
  rw [eval_one, mul_one]
  exact h p q hp hq hpq


/-! ### The algebraic barrier: no algebraic relation between `N` and `p` -/

/-- **The algebraic barrier.**  Let `F` be a polynomial in two variables over
`ℚ` (written as a polynomial in `Y` with coefficients in `ℚ[X]`).  If `F`
vanishes at `(X, Y) = (N, p)` for every semiprime `N = p*q` with `p < q` prime,
then `F` is the zero polynomial.  In other words the smaller prime factor
satisfies *no* algebraic relation over `ℚ` with the modulus: not of degree one
(the polynomial barrier), not of degree two, not of any degree.

The proof is a double application of the identity "a nonzero polynomial over a
domain has finitely many roots": first in `ℚ[X]` for each fixed small factor,
then in `(ℚ[X])[Y]` across small factors. -/
theorem algebraic_barrier (F : Polynomial (Polynomial ℚ))
    (h : ∀ p q : ℕ, p.Prime → q.Prime → p < q →
      (F.eval (Polynomial.C (p : ℚ))).eval ((p * q : ℕ) : ℚ) = 0) :
    F = 0 := by
  -- Step 1: for each prime `p`, the specialization `Y := p` is the zero
  -- polynomial in `ℚ[X]`, because it vanishes at the infinitely many `pq`.
  have hspec : ∀ p : ℕ, p.Prime → F.eval (Polynomial.C (p : ℚ)) = 0 := by
    intro p hp
    set H : Polynomial ℚ := F.eval (Polynomial.C (p : ℚ)) with hH
    have hroot : ∀ x ∈ (fun q : ℕ => (p : ℚ) * (q : ℚ)) '' {q : ℕ | q.Prime ∧ p < q},
        H.IsRoot x := by
      rintro x ⟨q, ⟨hq, hpq⟩, rfl⟩
      have hx : ((p * q : ℕ) : ℚ) = (p : ℚ) * (q : ℚ) := by push_cast; ring
      have := h p q hp hq hpq
      rw [hx] at this
      exact this
    have hne : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hp.ne_zero
    exact Polynomial.eq_zero_of_infinite_isRoot H
      (Set.Infinite.mono hroot (infinite_smul_image (infinite_primes_gt p) hne))
  -- Step 2: `F`, as a polynomial over the domain `ℚ[X]`, has the infinitely
  -- many roots `C p`.
  have hinj : Set.InjOn (fun p : ℕ => Polynomial.C ((p : ℚ))) {p : ℕ | p.Prime} := by
    intro a _ b _ hab
    have : ((a : ℚ)) = (b : ℚ) := Polynomial.C_injective hab
    exact_mod_cast this
  have hinf : {x : Polynomial ℚ | F.IsRoot x}.Infinite := by
    refine Set.Infinite.mono (s := (fun p : ℕ => Polynomial.C ((p : ℚ))) ''
      {p : ℕ | p.Prime}) ?_ (Nat.infinite_setOf_prime.image hinj)
    rintro x ⟨p, hp, rfl⟩
    exact hspec p hp
  exact Polynomial.eq_zero_of_infinite_isRoot F hinf

/-- The polynomial barrier is a special case of the algebraic barrier: the
degree-one relation `Y = P(X)` is excluded. -/
theorem polynomial_barrier_of_algebraic (P : Polynomial ℚ) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q → P.eval ((p * q : ℕ) : ℚ) = (p : ℚ) := by
  intro h
  set F : Polynomial (Polynomial ℚ) := Polynomial.C P - Polynomial.X with hF
  have hzero : F = 0 := by
    refine algebraic_barrier F ?_
    intro p q hp hq hpq
    simp only [hF, Polynomial.eval_sub, Polynomial.eval_C, Polynomial.eval_X,
      Polynomial.eval_sub]
    rw [h p q hp hq hpq, sub_self]
  have hcoeff : F.coeff 1 = -1 := by
    simp [hF, Polynomial.coeff_X_one]
  rw [hzero] at hcoeff
  simp at hcoeff

/-- **Quantitative polynomial barrier.**  For a fixed polynomial `P` and a
fixed small factor `p`, the number of primes `q > p` at which `P` returns the
correct factor, `P(pq) = p`, is at most `deg P`.  A degree-`d` polynomial can
therefore succeed on at most `d` semiprimes per small factor: success is not
merely impossible in the limit, it is quantitatively rare. -/
theorem polynomial_barrier_counting (P : Polynomial ℚ) {p : ℕ} (hp : p.Prime)
    (hne : P ≠ Polynomial.C (p : ℚ)) (S : Finset ℕ)
    (hS : ∀ q ∈ S, q.Prime ∧ p < q ∧ P.eval ((p * q : ℕ) : ℚ) = (p : ℚ)) :
    S.card ≤ P.natDegree := by
  set G : Polynomial ℚ := P - Polynomial.C (p : ℚ) with hG
  have hG0 : G ≠ 0 := sub_ne_zero.2 hne
  have hpne : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hp.ne_zero
  have hmap : ∀ q ∈ S, ((p : ℚ) * (q : ℚ)) ∈ G.roots.toFinset := by
    intro q hq
    obtain ⟨-, -, hval⟩ := hS q hq
    have hx : ((p * q : ℕ) : ℚ) = (p : ℚ) * (q : ℚ) := by push_cast; ring
    rw [hx] at hval
    rw [Multiset.mem_toFinset, Polynomial.mem_roots hG0]
    simp only [hG, Polynomial.IsRoot, Polynomial.eval_sub, Polynomial.eval_C, hval,
      sub_self]
  have hinj : ∀ a ∈ S, ∀ b ∈ S, (p : ℚ) * (a : ℚ) = (p : ℚ) * (b : ℚ) → a = b := by
    intro a _ b _ hab
    have : (a : ℚ) = b := mul_left_cancel₀ hpne hab
    exact_mod_cast this
  calc S.card ≤ G.roots.toFinset.card :=
        Finset.card_le_card_of_injOn (fun q => (p : ℚ) * (q : ℚ)) hmap hinj
    _ ≤ Multiset.card G.roots := G.roots.toFinset_card_le
    _ ≤ G.natDegree := G.card_roots'
    _ = P.natDegree := by rw [hG, Polynomial.natDegree_sub_C]

/-! ### Holomorphic rigidity -/

/-- **Rigidity lemma.**  An entire function that takes the same value `c` along
a sequence of nonzero points converging to `0` is constantly `c`. -/
theorem entire_const_of_tendsto_nhdsWithin {f : ℂ → ℂ} (hf : Differentiable ℂ f)
    {u : ℕ → ℂ} (hu : Tendsto u atTop (nhdsWithin 0 {(0 : ℂ)}ᶜ)) {c : ℂ}
    (hval : ∀ n, f (u n) = c) : ∀ z, f z = c := by
  have hg : AnalyticOnNhd ℂ (fun z => f z - c) Set.univ := by
    intro z _
    exact (hf.analyticAt z).sub analyticAt_const
  have hfreq : ∃ᶠ z in nhdsWithin (0 : ℂ) {(0 : ℂ)}ᶜ, f z - c = 0 :=
    hu.frequently (Filter.Eventually.frequently
      (Filter.Eventually.of_forall (fun n => by rw [hval n]; ring)))
  have := hg.eqOn_zero_of_preconnected_of_frequently_eq_zero
    (isPreconnected_univ) (Set.mem_univ 0) hfreq
  intro z
  have hz := this (Set.mem_univ z)
  simpa [sub_eq_zero] using hz

/-- The `n`-th prime, offset so as to always exceed `3`. -/
noncomputable def bigPrime (n : ℕ) : ℕ := Nat.nth Nat.Prime (n + 2)

theorem bigPrime_prime (n : ℕ) : (bigPrime n).Prime :=
  Nat.prime_nth_prime (n + 2)

theorem bigPrime_strictMono : StrictMono bigPrime := by
  intro a b hab
  exact Nat.nth_strictMono Nat.infinite_setOf_prime (by omega)

theorem three_lt_bigPrime (n : ℕ) : 3 < bigPrime n := by
  have h0 : 2 ≤ Nat.nth Nat.Prime 0 := (Nat.prime_nth_prime 0).two_le
  have h01 : Nat.nth Nat.Prime 0 < Nat.nth Nat.Prime 1 :=
    Nat.nth_strictMono Nat.infinite_setOf_prime (by omega)
  have h12 : Nat.nth Nat.Prime 1 < Nat.nth Nat.Prime 2 :=
    Nat.nth_strictMono Nat.infinite_setOf_prime (by omega)
  have h2n : Nat.nth Nat.Prime 2 ≤ bigPrime n := by
    unfold bigPrime
    exact Nat.nth_monotone Nat.infinite_setOf_prime (by omega)
  omega

theorem bigPrime_tendsto : Tendsto bigPrime atTop atTop :=
  bigPrime_strictMono.tendsto_atTop

/-- The reciprocals of the semiprimes `3 * q` (with `q` ranging over primes
above `3`) form a sequence of nonzero points converging to `0`. -/
theorem tendsto_recip_semiprime :
    Tendsto (fun n => (((3 * bigPrime n : ℕ) : ℂ))⁻¹) atTop
      (nhdsWithin 0 {(0 : ℂ)}ᶜ) := by
  have hpos : ∀ n, 0 < (3 * bigPrime n : ℕ) := by
    intro n; have := three_lt_bigPrime n; omega
  have htop : Tendsto (fun n => ((3 * bigPrime n : ℕ) : ℝ)) atTop atTop := by
    have hm : Tendsto (fun n => (3 * bigPrime n : ℕ)) atTop atTop :=
      Filter.tendsto_atTop_mono
        (fun n => Nat.le_mul_of_pos_left (bigPrime n) (by norm_num)) bigPrime_tendsto
    exact tendsto_natCast_atTop_atTop.comp hm
  have hnorm : Tendsto (fun n => ‖(((3 * bigPrime n : ℕ) : ℂ))⁻¹‖) atTop (nhds 0) := by
    have heq : ∀ n, ‖(((3 * bigPrime n : ℕ) : ℂ))⁻¹‖ = ((3 * bigPrime n : ℕ) : ℝ)⁻¹ := by
      intro n
      rw [norm_inv, Complex.norm_natCast]
    simp only [heq]
    exact htop.inv_tendsto_atTop
  refine tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _
    (tendsto_zero_iff_norm_tendsto_zero.2 hnorm) ?_
  filter_upwards with n
  have hne : ((3 * bigPrime n : ℕ) : ℂ) ≠ 0 := by
    have h1 : (3 * bigPrime n : ℕ) ≠ 0 := by have := hpos n; omega
    exact_mod_cast h1
  simpa using inv_ne_zero hne

/-- **Holomorphic rigidity barrier (HRB).**  There is no entire function `f`
with `f (1/N) = 1/p` for every semiprime `N = p*q` with `p < q` prime.  Fixing
`p = 3` makes the sample points accumulate at `0`, so the identity theorem
pins `f` to the constant `1/3`; the choice `p = 5` then contradicts it. -/
theorem holomorphic_rigidity_barrier (f : ℂ → ℂ) (hf : Differentiable ℂ f) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        f (((p * q : ℕ) : ℂ))⁻¹ = ((p : ℕ) : ℂ)⁻¹ := by
  intro h
  have hconst : ∀ z, f z = ((3 : ℕ) : ℂ)⁻¹ := by
    refine entire_const_of_tendsto_nhdsWithin hf tendsto_recip_semiprime ?_
    intro n
    exact h 3 (bigPrime n) (by norm_num) (bigPrime_prime n) (three_lt_bigPrime n)
  have h5 := h 5 7 (by norm_num) (by norm_num) (by norm_num)
  rw [hconst] at h5
  have : ((3 : ℕ) : ℂ) = ((5 : ℕ) : ℂ) := by
    have h3 : ((3 : ℕ) : ℂ) ≠ 0 := by norm_num
    have h5' : ((5 : ℕ) : ℂ) ≠ 0 := by norm_num
    field_simp at h5
    linear_combination -h5
  norm_num at this

end FactoringLab