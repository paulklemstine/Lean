import Novelty.SymmetryBreakingCostFactoring

/-!
# Exactly what the symmetric battery knows: the squarefree kernel

`Catalog/Novelty/SymmetryBreakingCostFactoring.lean` measured the *asymmetric* resource: an
oracle for `[(a i | p₀)]` isolates the hidden factor in exactly `⌈log₂ |S|⌉` queries, while the
*symmetric* battery `[(a i | N)]` computable from `N` alone prunes nothing.

This second cycle pins down the exact information content of the symmetric battery.  For a
modulus `n`, define its **squarefree kernel** `sqKernel n` to be the set of primes occurring in
`n` to an odd multiplicity.  Then:

* `jacobiSym_eq_prod_sqKernel` : for `a` coprime to `n`, `J(a | n) = ∏_{p ∈ sqKernel n} J(a | p)`.
* `jacobiSym_battery_eq_iff` : for odd `M, N > 0`, the two Jacobi batteries agree on **all**
  numerators coprime to `M * N` **iff** `sqKernel M = sqKernel N`.

So the public battery is a faithful invariant of the kernel and blind to everything else.  For a
semiprime `N = p q` the kernel is `{p, q}` — the battery reproduces `N` and not one bit more,
which is the sharp form of "zero pruning":

* `sqKernel_mul_sq` : `sqKernel (N * r ^ 2) = sqKernel N` for every `r > 0`;
* `zero_pruning_sharp` : hence for every candidate `r` there is a modulus divisible by `r` whose
  battery is *identical* to `N`'s on every admissible numerator — no candidate can be excluded.

Contrast with the asymmetric side: `exists_prescribed_signature` shows that the *individual*
Legendre symbols of the candidate primes are completely free, which is what makes `⌈log₂ |S|⌉`
oracle queries enough.  Aggregating them into a single Jacobi symbol destroys exactly that
freedom, and the destroyed freedom is the symmetry-breaking cost.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 2): the failure of the symmetric battery is not a quantitative
weakness (few bits) but a *structural collapse*: `J(· | N)` factors through the kernel, and
distinct kernels are always separated.  If so, "zero pruning" is an exact if-and-only-if, not an
inequality.

Experiment (Experimenter): tabulated `J(a | M)` for `a = 1 … 40` and
`M ∈ {15, 135, 375, 3375, 21}` (see `ComputationalEvidence.md`).  The first four share the
kernel `{3, 5}` and produced byte-identical rows on every `a` coprime to the modulus; `21`
(kernel `{3, 7}`) differed already at `a = 2`, where `J(2 | 15) = 1` but `J(2 | 21) = -1`.

Analysis (Analyst): the separating numerator is always produced by the same mechanism as the
oracle upper bound — prescribe a nonresidue at one kernel prime and residues everywhere else,
which the Chinese remainder theorem allows.  The same CRT freedom is therefore responsible both
for the cheapness of the oracle and for the exactness of the kernel invariant.

Critique (Critic): the equivalence genuinely needs oddness of `M` and `N`: at `p = 2` there is
no quadratic nonresidue mod `2` and the argument would have to be replaced by a mod-8 argument.
The statement is therefore guarded by `Odd M`, `Odd N`, and this boundary is explicit in
`jacobiSym_battery_eq_iff`.
-/

namespace SymmetryBreakingCost

open Finset
open scoped NumberTheorySymbols

/-! ## 1.  Multiplicativity over a finite product -/

/-- The Jacobi symbol is multiplicative in the denominator over an arbitrary finite product. -/
theorem jacobiSym_prod_right (a : ℤ) (s : Finset ℕ) (f : ℕ → ℕ) (hf : ∀ p ∈ s, f p ≠ 0) :
    J(a | ∏ p ∈ s, f p) = ∏ p ∈ s, J(a | f p) := by
  classical
  induction s using Finset.cons_induction with
  | empty => simp [jacobiSym.one_right]
  | cons p T hp ih =>
      have hfT : ∀ q ∈ T, f q ≠ 0 := fun q hq => hf q (by simp [hq])
      have hprod : (∏ q ∈ T, f q) ≠ 0 := Finset.prod_ne_zero_iff.mpr hfT
      rw [Finset.prod_cons, Finset.prod_cons,
        jacobiSym.mul_right' a (hf p (by simp)) hprod, ih hfT]

/-- Coprimality passes to divisors of the modulus. -/
theorem gcd_of_dvd {a : ℤ} {m n : ℕ} (hd : m ∣ n) (h : Int.gcd a (n : ℤ) = 1) :
    Int.gcd a (m : ℤ) = 1 := by
  have h' : Nat.Coprime a.natAbs n := by simpa [Int.gcd] using h
  simpa [Int.gcd] using Nat.Coprime.coprime_dvd_right hd h'

/-! ## 2.  The squarefree kernel -/

/-- The **squarefree kernel** of `n`: the primes dividing `n` to an odd multiplicity. -/
def sqKernel (n : ℕ) : Finset ℕ := n.primeFactors.filter fun p => Odd (n.factorization p)

theorem mem_sqKernel_iff {n p : ℕ} : p ∈ sqKernel n ↔ Odd (n.factorization p) := by
  classical
  constructor
  · intro h
    exact (Finset.mem_filter.mp h).2
  · intro h
    refine Finset.mem_filter.mpr ⟨?_, h⟩
    have hne : n.factorization p ≠ 0 := by
      rcases h with ⟨m, hm⟩; omega
    rw [← Nat.support_factorization]
    exact Finsupp.mem_support_iff.mpr hne

/-- A `±1` value raised to an exponent is itself exactly when the exponent is odd. -/
theorem pow_of_sq_eq_one {x : ℤ} (hx : x = 1 ∨ x = -1) (e : ℕ) :
    x ^ e = if Odd e then x else 1 := by
  rcases hx with rfl | rfl
  · simp
  · rcases Nat.even_or_odd e with he | he
    · simp [he.neg_one_pow, Nat.not_odd_iff_even.mpr he]
    · simp [he.neg_one_pow, he]

/-- **The symmetric battery factors through the kernel.**  For `a` coprime to `n`, the Jacobi
symbol is the product of the Legendre symbols at the kernel primes. -/
theorem jacobiSym_eq_prod_sqKernel {a : ℤ} {n : ℕ} (hn : n ≠ 0) (hcop : Int.gcd a n = 1) :
    J(a | n) = ∏ p ∈ sqKernel n, J(a | p) := by
  classical
  have hfac : ∏ p ∈ n.primeFactors, p ^ n.factorization p = n := by
    have := Nat.factorization_prod_pow_eq_self hn
    rwa [Nat.prod_factorization_eq_prod_primeFactors] at this
  have hpm : ∀ p ∈ n.primeFactors, J(a | p) = 1 ∨ J(a | p) = -1 := by
    intro p hp
    have hpp : p ∣ n := Nat.dvd_of_mem_primeFactors hp
    have hne : J(a | p) ≠ 0 := by
      intro h0
      exact (jacobiSym.eq_zero_iff.mp h0).2 (gcd_of_dvd hpp hcop)
    rcases jacobiSym.trichotomy a p with h | h | h
    · exact absurd h hne
    · exact Or.inl h
    · exact Or.inr h
  calc J(a | n) = J(a | ∏ p ∈ n.primeFactors, p ^ n.factorization p) := by rw [hfac]
    _ = ∏ p ∈ n.primeFactors, J(a | p ^ n.factorization p) := by
        refine jacobiSym_prod_right a _ _ (fun p hp => ?_)
        exact pow_ne_zero _ (Nat.Prime.ne_zero (Nat.prime_of_mem_primeFactors hp))
    _ = ∏ p ∈ n.primeFactors, (if Odd (n.factorization p) then J(a | p) else 1) := by
        refine Finset.prod_congr rfl (fun p hp => ?_)
        rw [jacobiSym.pow_right, pow_of_sq_eq_one (hpm p hp)]
    _ = ∏ p ∈ sqKernel n, J(a | p) := by
        rw [sqKernel, Finset.prod_ite, Finset.prod_const_one, mul_one]

/-! ## 3.  Faithfulness: distinct kernels are separated -/

/-- Every prime in a kernel is odd when the modulus is odd. -/
theorem sqKernel_odd {n : ℕ} (hn : Odd n) {p : ℕ} (hp : p ∈ sqKernel n) : p ≠ 2 := by
  classical
  have hmem := Finset.mem_filter.mp hp
  have hdvd : p ∣ n := Nat.dvd_of_mem_primeFactors hmem.1
  rintro rfl
  exact (Nat.not_even_iff_odd.mpr hn) (even_iff_two_dvd.mpr hdvd)

/-- **Separation.**  If some prime lies in the kernel of `M` but not in that of `N`, an explicit
numerator coprime to `M * N` tells the two batteries apart. -/
theorem exists_separating_numerator {M N : ℕ} (hM : M ≠ 0) (hN : N ≠ 0) (hMo : Odd M)
    (hNo : Odd N) {p : ℕ} (hpM : p ∈ sqKernel M) (hpN : p ∉ sqKernel N) :
    ∃ a : ℤ, Int.gcd a (M * N) = 1 ∧ J(a | M) = -1 ∧ J(a | N) = 1 := by
  classical
  set P : Finset ℕ := (M * N).primeFactors with hP
  have hMN : M * N ≠ 0 := Nat.mul_ne_zero hM hN
  have hMNo : Odd (M * N) := hMo.mul hNo
  have hPprime : ∀ q ∈ P, q.Prime ∧ q ≠ 2 := by
    intro q hq
    refine ⟨Nat.prime_of_mem_primeFactors hq, ?_⟩
    rintro rfl
    exact (Nat.not_even_iff_odd.mpr hMNo)
      (even_iff_two_dvd.mpr (Nat.dvd_of_mem_primeFactors hq))
  have hsubM : sqKernel M ⊆ P := by
    intro q hq
    have hqM : q ∣ M := Nat.dvd_of_mem_primeFactors (Finset.mem_filter.mp hq).1
    exact Nat.mem_primeFactors.mpr ⟨Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hq).1,
      hqM.trans (dvd_mul_right M N), hMN⟩
  have hsubN : sqKernel N ⊆ P := by
    intro q hq
    have hqN : q ∣ N := Nat.dvd_of_mem_primeFactors (Finset.mem_filter.mp hq).1
    exact Nat.mem_primeFactors.mpr ⟨Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hq).1,
      hqN.trans (dvd_mul_left N M), hMN⟩
  obtain ⟨a, ha⟩ := exists_prescribed_signature P hPprime (fun q => decide (q ≠ p))
  have hval : ∀ q ∈ P, J(a | q) = if q = p then -1 else 1 := by
    intro q hq
    rw [ha q hq]
    by_cases h : q = p <;> simp [h]
  have hcop : Int.gcd a (M * N) = 1 := by
    by_contra hc
    obtain ⟨q, hqp, hqa, hqMN⟩ := Nat.Prime.not_coprime_iff_dvd.mp hc
    have hqP : q ∈ P := Nat.mem_primeFactors.mpr ⟨hqp, hqMN, hMN⟩
    have h0 : J(a | q) = 0 := by
      refine jacobiSym.eq_zero_iff.mpr ⟨hqp.ne_zero, ?_⟩
      intro hgcd
      have : q ∣ Int.gcd a q := Nat.dvd_gcd hqa dvd_rfl
      rw [hgcd] at this
      exact hqp.one_lt.ne' (Nat.eq_one_of_dvd_one this ▸ rfl)
    rw [hval q hqP] at h0
    by_cases h : q = p <;> simp [h] at h0
  refine ⟨a, hcop, ?_, ?_⟩
  · have hcopM : Int.gcd a M = 1 := gcd_of_dvd (dvd_mul_right M N) (by exact_mod_cast hcop)
    rw [jacobiSym_eq_prod_sqKernel hM hcopM]
    rw [Finset.prod_eq_single_of_mem p hpM]
    · simpa using hval p (hsubM hpM)
    · intro q hq hqp
      rw [hval q (hsubM hq)]
      simp [hqp]
  · have hcopN : Int.gcd a N = 1 := gcd_of_dvd (dvd_mul_left N M) (by exact_mod_cast hcop)
    rw [jacobiSym_eq_prod_sqKernel hN hcopN]
    refine Finset.prod_eq_one (fun q hq => ?_)
    have hqp : q ≠ p := by rintro rfl; exact hpN hq
    rw [hval q (hsubN hq)]
    simp [hqp]

/-- **The exact information content of the symmetric battery.**  Two odd moduli have the same
Jacobi battery — on every numerator coprime to both — precisely when they have the same
squarefree kernel.  Nothing beyond the kernel is visible, and the kernel is fully visible. -/
theorem jacobiSym_battery_eq_iff {M N : ℕ} (hM : M ≠ 0) (hN : N ≠ 0) (hMo : Odd M) (hNo : Odd N) :
    (∀ a : ℤ, Int.gcd a (M * N) = 1 → J(a | M) = J(a | N)) ↔ sqKernel M = sqKernel N := by
  classical
  constructor
  · intro hbat
    by_contra hne
    obtain ⟨p, hp⟩ : ∃ p, ¬(p ∈ sqKernel M ↔ p ∈ sqKernel N) := by
      by_contra hc
      push_neg at hc
      exact hne (Finset.ext hc)
    rcases Classical.em (p ∈ sqKernel M) with hpM | hpM
    · have hpN : p ∉ sqKernel N := fun h => hp ⟨fun _ => h, fun _ => hpM⟩
      obtain ⟨a, hcop, h1, h2⟩ := exists_separating_numerator hM hN hMo hNo hpM hpN
      have := hbat a hcop
      rw [h1, h2] at this
      norm_num at this
    · have hpN : p ∈ sqKernel N := by
        by_contra h
        exact hp ⟨fun hx => absurd hx hpM, fun hx => absurd hx h⟩
      obtain ⟨a, hcop, h1, h2⟩ :=
        exists_separating_numerator hN hM hNo hMo hpN hpM
      have := hbat a (by rw [mul_comm]; exact hcop)
      rw [h1, h2] at this
      norm_num at this
  · intro hker a hcop
    have hcopM : Int.gcd a M = 1 := gcd_of_dvd (dvd_mul_right M N) (by exact_mod_cast hcop)
    have hcopN : Int.gcd a N = 1 := gcd_of_dvd (dvd_mul_left N M) (by exact_mod_cast hcop)
    rw [jacobiSym_eq_prod_sqKernel hM hcopM, jacobiSym_eq_prod_sqKernel hN hcopN, hker]

/-! ## 4.  Sharp zero pruning -/

/-- Square factors are invisible to the kernel. -/
theorem sqKernel_mul_sq (N r : ℕ) (hN : N ≠ 0) (hr : r ≠ 0) :
    sqKernel (N * r ^ 2) = sqKernel N := by
  classical
  ext p
  rw [mem_sqKernel_iff, mem_sqKernel_iff,
    Nat.factorization_mul hN (pow_ne_zero 2 hr), Nat.factorization_pow]
  simp only [Finsupp.coe_add, Finsupp.coe_smul, Pi.add_apply, Pi.smul_apply, smul_eq_mul]
  constructor
  · rintro ⟨m, hm⟩; exact ⟨m - r.factorization p, by omega⟩
  · rintro ⟨m, hm⟩; exact ⟨m + r.factorization p, by omega⟩

/-- **Sharp zero pruning.**  For every candidate `r` there is a modulus divisible by `r` whose
Jacobi battery is *identical* to that of `N` on all numerators coprime to it: the symmetric data
excludes no candidate at all. -/
theorem zero_pruning_sharp (N r : ℕ) (hN : N ≠ 0) (hr : r ≠ 0) (hNo : Odd N) (hro : Odd r) :
    ∃ M : ℕ, r ∣ M ∧ Odd M ∧ sqKernel M = sqKernel N ∧
      ∀ a : ℤ, Int.gcd a (M * N) = 1 → J(a | M) = J(a | N) := by
  refine ⟨N * r ^ 2, ⟨N * r, by ring⟩, hNo.mul (hro.pow), sqKernel_mul_sq N r hN hr, ?_⟩
  exact (jacobiSym_battery_eq_iff (Nat.mul_ne_zero hN (pow_ne_zero 2 hr)) hN
    (hNo.mul (hro.pow)) hNo).mpr (sqKernel_mul_sq N r hN hr)

/-- For a semiprime the kernel is exactly the factor pair: the public battery reproduces `N`
and nothing more. -/
theorem sqKernel_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    sqKernel (p * q) = {p, q} := by
  classical
  ext r
  rw [mem_sqKernel_iff, Nat.factorization_mul hp.ne_zero hq.ne_zero]
  simp only [Finsupp.coe_add, Pi.add_apply, hp.factorization, hq.factorization,
    Finsupp.single_apply, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    rw [if_neg (fun hh => hc.1 hh.symm), if_neg (fun hh => hc.2 hh.symm)] at h
    simp at h
  · rintro (rfl | rfl)
    · rw [if_pos rfl, if_neg (fun hh => hpq hh.symm)]
      exact ⟨0, by omega⟩
    · rw [if_neg (fun hh => hpq hh), if_pos rfl]
      exact ⟨0, by omega⟩

end SymmetryBreakingCost