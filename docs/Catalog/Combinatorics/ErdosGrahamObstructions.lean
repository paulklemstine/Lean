import Mathlib
import Combinatorics.ErdosGrahamEgyptian

/-!
# Erdős–Graham: local obstructions to exact unit-fraction coverings

Companion file to `Combinatorics.ErdosGrahamEgyptian`.  Here we isolate the *arithmetic*
half of the Erdős–Graham problem: which sets of integers can **never** contain a finite
subset of reciprocal sum `1`?

The central result is a purely local (`p`-adic) obstruction:

> `Egyptian.exists_other_ge_padicValNat` : if `S` is Egyptian, `p` is a prime and
> `m ∈ S` has `v_p(m) > 0`, then some **other** element of `S` has `p`-adic valuation
> at least `v_p(m)`.

Equivalently: the maximal `p`-power occurring in an exact Egyptian decomposition is never
attained by a single denominator.  Consequences:

* every set of pairwise coprime integers `≥ 2` is Egyptian-free (`egyptianFree_of_pairwise_coprime`);
* the primes and, more generally, the prime powers are Egyptian-free;
* since `∑ 1/p` diverges, **divergence of the reciprocal sum does not imply the existence
  of an exact Egyptian subsum** (`divergence_not_sufficient`).  This is the precise reason
  the Erdős–Graham conjecture cannot be proved by the pigeonhole step alone
  (`exists_divergent_colorClass`) and needs genuinely arithmetic input.

Finally we show the obstruction is not an obstruction to the *complement*: there is an
explicit 21-element Egyptian set consisting entirely of non-prime-powers
(`egyptian_avoiding_primePowers`) and an explicit 23-element one with all denominators
`≥ 10` (`exists_egyptian_min_ge_ten`).  Each yields an unconditional two-colour theorem
(`erdosGraham_two_of_primePow_class`, `erdosGraham_two_of_small_class`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Reciprocally large ⟹ contains an exact cover" — a natural
strengthening of Erdős–Graham that would immediately imply the conjecture.

Experiment (Experimenter): FALSIFIED.  The set of primes has divergent reciprocal sum
(Mathlib's `not_summable_one_div_on_primes`) yet contains no exact cover, by the p-adic
argument above (for the largest prime `p` in a candidate set, `v_p` is attained once).

Analysis (Analyst): The failure is *local*: for a fixed prime `p`, the ultrametric
inequality forces the minimal `p`-adic valuation among the terms `1/n` to be attained at
least twice, otherwise `v_p(∑ 1/n) < 0 = v_p(1)`.  So Egyptian-freeness is implied by a
"unique maximal p-power" condition, satisfied by pairwise coprime sets and prime powers.

Critique (Critic): Is the obstruction vacuous, i.e. could *every* Egyptian-free set be
this thin?  No: computation shows the non-prime-powers do contain an exact cover, which we
verified formally (21 terms, denominators dividing `27720`).  Hence the class of
Egyptian-free sets is genuinely intermediate, and the two-colour instance where one class
is contained in the prime powers is settled unconditionally.
-- !-- Lab Notes -- !--
-/

namespace ErdosGraham

open Finset

section LocalObstruction

variable {p : ℕ} [hp : Fact p.Prime]

private lemma padicValRat_inv_nat (n : ℕ) :
    padicValRat p ((n : ℚ))⁻¹ = -(padicValNat p n : ℤ) := by
  rw [padicValRat.inv, padicValRat.of_nat]

/-- **Local `p`-adic obstruction to Egyptian decompositions.**
If `S` has reciprocal sum `1` and some `m ∈ S` is divisible by the prime `p`, then the
maximal power of `p` dividing a member of `S` is attained at least twice: some other
element of `S` has `p`-adic valuation at least that of `m`.

The mechanism is the ultrametric inequality: were the minimum of `v_p(1/n)` attained
once, the whole sum would have negative valuation, whereas `v_p(1) = 0`. -/
theorem Egyptian.exists_other_ge_padicValNat {S : Finset ℕ} (h : Egyptian S)
    (p : ℕ) [Fact p.Prime] {m : ℕ} (hm : m ∈ S) (hpos : 0 < padicValNat p m) :
    ∃ n ∈ S, n ≠ m ∧ padicValNat p m ≤ padicValNat p n := by
  by_contra hcon
  push_neg at hcon
  -- a globally positive extension of `n ↦ 1/n`
  set F : ℕ → ℚ := fun n => ((max n 1 : ℕ) : ℚ)⁻¹ with hFdef
  have hFpos : ∀ n : ℕ, 0 < F n := by
    intro n
    have : (0 : ℚ) < ((max n 1 : ℕ) : ℚ) := by
      have : 1 ≤ max n 1 := le_max_right _ _
      exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one this
    simp only [hFdef]
    exact inv_pos.mpr this
  have hFeq : ∀ n ∈ S, F n = (1 : ℚ) / n := by
    intro n hn
    have hn2 : 2 ≤ n := h.1 n hn
    have hmax : max n 1 = n := max_eq_left (by omega)
    simp only [hFdef, hmax, one_div]
  have hFval : ∀ n ∈ S, padicValRat p (F n) = -(padicValNat p n : ℤ) := by
    intro n hn
    have hn2 : 2 ≤ n := h.1 n hn
    have hmax : max n 1 = n := max_eq_left (by omega)
    rw [hFdef]
    simp only [hmax]
    exact padicValRat_inv_nat n
  -- `S` is not the singleton `{m}`
  have hne : (S.erase m).Nonempty := by
    rcases Finset.eq_empty_or_nonempty (S.erase m) with hE | hne
    · exfalso
      have hS : S = {m} := by
        apply Finset.eq_singleton_iff_unique_mem.mpr
        refine ⟨hm, fun x hx => ?_⟩
        by_contra hxm
        exact absurd (Finset.mem_erase.mpr ⟨hxm, hx⟩) (by simp [hE])
      have hm2 : 2 ≤ m := h.1 m hm
      have := h.2
      rw [hS, Finset.sum_singleton] at this
      have hmpos : (0 : ℚ) < m := by exact_mod_cast Nat.lt_of_lt_of_le two_pos hm2
      have : (m : ℚ) = 1 := by field_simp at this; linarith
      have h2 : (2 : ℚ) ≤ m := by exact_mod_cast hm2
      linarith
    · exact hne
  -- the term at `m` has strictly the smallest valuation
  have hlt : padicValRat p (F m) < padicValRat p (∑ n ∈ S.erase m, F n) := by
    refine padicValRat.lt_sum_of_lt hne (fun i hi => ?_) hFpos
    have hiS : i ∈ S := Finset.mem_of_mem_erase hi
    have hine : i ≠ m := (Finset.mem_erase.mp hi).1
    rw [hFval m hm, hFval i hiS]
    have := hcon i hiS hine
    omega
  have hsplit : F m + ∑ n ∈ S.erase m, F n = 1 := by
    rw [Finset.add_sum_erase S F hm, Finset.sum_congr rfl hFeq]
    exact h.2
  have hRpos : (0 : ℚ) < ∑ n ∈ S.erase m, F n :=
    Finset.sum_pos (fun i _ => hFpos i) hne
  have hkey : padicValRat p (F m + ∑ n ∈ S.erase m, F n) = padicValRat p (F m) :=
    padicValRat.add_eq_of_lt (by rw [hsplit]; norm_num) (ne_of_gt (hFpos m))
      (ne_of_gt hRpos) hlt
  rw [hsplit, padicValRat.one, hFval m hm] at hkey
  omega

/-- **Pairing corollary.**  For every prime `p`, an Egyptian set never contains exactly
one element divisible by `p`: divisibility by a prime always comes in company. -/
theorem Egyptian.card_filter_dvd_ne_one {S : Finset ℕ} (h : Egyptian S) {p : ℕ}
    (hp : p.Prime) : (S.filter (fun n => p ∣ n)).card ≠ 1 := by
  intro hcard
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨m, hm⟩ := Finset.card_eq_one.mp hcard
  have hmem : m ∈ S ∧ p ∣ m := by
    have hmm : m ∈ S.filter (fun n => p ∣ n) := by rw [hm]; simp
    simpa using hmm
  have hm0 : m ≠ 0 := by have := h.1 m hmem.1; omega
  have hpos : 0 < padicValNat p m := one_le_padicValNat_of_dvd hm0 hmem.2
  obtain ⟨n, hnS, hnm, hle⟩ := h.exists_other_ge_padicValNat p hmem.1 hpos
  have hpn : p ∣ n := by
    by_contra hdvd
    have : padicValNat p n = 0 := padicValNat.eq_zero_of_not_dvd hdvd
    omega
  have hnmem : n ∈ S.filter (fun n => p ∣ n) := Finset.mem_filter.mpr ⟨hnS, hpn⟩
  rw [hm, Finset.mem_singleton] at hnmem
  exact hnm hnmem

/-- An Egyptian set never contains exactly one even element. -/
theorem Egyptian.card_filter_even_ne_one {S : Finset ℕ} (h : Egyptian S) :
    (S.filter (fun n => Even n)).card ≠ 1 := by
  have hkey := h.card_filter_dvd_ne_one Nat.prime_two
  simpa [Nat.even_iff, Nat.dvd_iff_mod_eq_zero] using hkey

end LocalObstruction

section EgyptianFree

/-- A set of naturals is **`p`-adically separated** if, for every prime `p`, two distinct
elements never share one and the same *positive* `p`-adic valuation. -/
def PadicSeparated (A : Set ℕ) : Prop :=
  ∀ p : ℕ, p.Prime → ∀ m ∈ A, ∀ n ∈ A, m ≠ n →
    padicValNat p m = padicValNat p n → padicValNat p m = 0

/-- **Master Egyptian-freeness criterion.**  A `p`-adically separated set contains no
finite subset of reciprocal sum `1`.  Indeed, taking a prime `p` dividing some member and
the member of maximal `p`-adic valuation, the local obstruction produces a *second*
member with the same (positive) valuation, contradicting separation. -/
theorem egyptianFree_of_padicSeparated {A : Set ℕ} (hA : PadicSeparated A) :
    EgyptianFree A := by
  intro S hSA hS
  obtain ⟨x, hx⟩ := hS.nonempty
  have hx2 : 2 ≤ x := hS.1 x hx
  obtain ⟨p, hpp, hpx⟩ := Nat.exists_prime_and_dvd (n := x) (by omega)
  haveI : Fact p.Prime := ⟨hpp⟩
  obtain ⟨m, hm, hmax⟩ := S.exists_max_image (fun n => padicValNat p n) hS.nonempty
  have hxpos : 0 < padicValNat p x := one_le_padicValNat_of_dvd (by omega) hpx
  have hmpos : 0 < padicValNat p m := lt_of_lt_of_le hxpos (hmax x hx)
  obtain ⟨n, hnS, hnm, hle⟩ := hS.exists_other_ge_padicValNat p hm hmpos
  have heq : padicValNat p m = padicValNat p n := le_antisymm hle (hmax n hnS)
  have := hA p hpp m (hSA hm) n (hSA hnS) (Ne.symm hnm) heq
  omega

/-- A set of **pairwise coprime** integers is `p`-adically separated. -/
theorem padicSeparated_of_pairwise_coprime {A : Set ℕ}
    (hcop : ∀ m ∈ A, ∀ n ∈ A, m ≠ n → Nat.Coprime m n) : PadicSeparated A := by
  intro p hpp m hmA n hnA hmn heq
  by_contra hpos
  have hpm : p ∣ m := by
    by_contra hdvd
    exact hpos (padicValNat.eq_zero_of_not_dvd hdvd)
  have hpn : p ∣ n := by
    by_contra hdvd
    have : padicValNat p n = 0 := padicValNat.eq_zero_of_not_dvd hdvd
    omega
  have hdvd : p ∣ Nat.gcd m n := Nat.dvd_gcd hpm hpn
  rw [hcop m hmA n hnA hmn] at hdvd
  exact hpp.one_lt.ne' (Nat.dvd_one.mp hdvd)

/-- A set of **pairwise coprime** integers is Egyptian-free: no finite subset has
reciprocal sum `1`. -/
theorem egyptianFree_of_pairwise_coprime {A : Set ℕ}
    (hcop : ∀ m ∈ A, ∀ n ∈ A, m ≠ n → Nat.Coprime m n) : EgyptianFree A :=
  egyptianFree_of_padicSeparated (padicSeparated_of_pairwise_coprime hcop)

/-- The set of primes is Egyptian-free. -/
theorem egyptianFree_primes : EgyptianFree {p : ℕ | p.Prime} := by
  refine egyptianFree_of_pairwise_coprime ?_
  intro m hm n hn hmn
  exact (Nat.coprime_primes hm hn).mpr hmn

/-- If two distinct primes divide `n`, then `n` is not a prime power. -/
private lemma not_isPrimePow_of_two_primes {n p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hpn : p ∣ n) (hqn : q ∣ n) : ¬ IsPrimePow n := by
  rintro ⟨r, k, hr, hk, rfl⟩
  have hr' : r.Prime := Nat.prime_iff.mpr hr
  have h1 : p = r := (Nat.prime_dvd_prime_iff_eq hp hr').mp (hp.dvd_of_dvd_pow hpn)
  have h2 : q = r := (Nat.prime_dvd_prime_iff_eq hq hr').mp (hq.dvd_of_dvd_pow hqn)
  exact hpq (h1.trans h2.symm)

/-- If `p ∣ x` for a prime `p` and `x` is a prime power, then `x` is a power of `p`,
namely `p ^ v_p(x)`. -/
private lemma isPrimePow_eq_pow_padicValNat {p x : ℕ} (hp : p.Prime) (hx : IsPrimePow x)
    (hpx : p ∣ x) : x = p ^ padicValNat p x := by
  obtain ⟨q, k, hq, hk, rfl⟩ := hx
  have hq' : q.Prime := Nat.prime_iff.mpr hq
  have hpq : p = q := (Nat.prime_dvd_prime_iff_eq hp hq').mp (hp.dvd_of_dvd_pow hpx)
  subst hpq
  haveI : Fact p.Prime := ⟨hp⟩
  rw [padicValNat.prime_pow]

/-- The set of **prime powers** is `p`-adically separated: a prime power with positive
`p`-adic valuation is determined by that valuation. -/
theorem padicSeparated_primePowers : PadicSeparated {n : ℕ | IsPrimePow n} := by
  intro p hpp m hmA n hnA hmn heq
  by_contra hpos
  have hpm : p ∣ m := by
    by_contra hdvd
    exact hpos (padicValNat.eq_zero_of_not_dvd hdvd)
  have hpn : p ∣ n := by
    by_contra hdvd
    have : padicValNat p n = 0 := padicValNat.eq_zero_of_not_dvd hdvd
    omega
  have h1 : m = p ^ padicValNat p m := isPrimePow_eq_pow_padicValNat hpp hmA hpm
  have h2 : n = p ^ padicValNat p n := isPrimePow_eq_pow_padicValNat hpp hnA hpn
  exact hmn (by rw [h1, h2, heq])

/-- The set of **prime powers** is Egyptian-free: no finite set of prime powers has
reciprocal sum `1`.  (This strictly extends `egyptianFree_primes`: distinct powers of the
same prime are not coprime.) -/
theorem egyptianFree_primePowers : EgyptianFree {n : ℕ | IsPrimePow n} :=
  egyptianFree_of_padicSeparated padicSeparated_primePowers

end EgyptianFree

section DivergenceInsufficient

/-- The primes have divergent reciprocal sum, in the finite–partial–sum form used here.
(Deduced from Mathlib's `not_summable_one_div_on_primes`.) -/
theorem primes_divergentReciprocals : DivergentReciprocals {p : ℕ | p.Prime} := by
  by_contra hcon
  unfold DivergentReciprocals at hcon
  push_neg at hcon
  obtain ⟨M, hM⟩ := hcon
  refine not_summable_one_div_on_primes ?_
  refine summable_of_sum_le (c := (M : ℝ)) (fun n => ?_) (fun s => ?_)
  · by_cases hn : n ∈ {p : ℕ | p.Prime}
    · simp only [Set.indicator_of_mem hn]
      positivity
    · simp [Set.indicator_of_notMem hn]
  · have hfil : ∑ n ∈ s, Set.indicator {p : ℕ | p.Prime} (fun n : ℕ => 1 / (n : ℝ)) n
        = ∑ n ∈ s with n.Prime, (1 : ℝ) / n := by
      rw [Finset.sum_indicator_eq_sum_filter]
      rfl
    rw [hfil]
    have hsub : ↑(s.filter (fun n => n.Prime)) ⊆ {p : ℕ | p.Prime} := by
      intro n hn
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hn
      exact hn.2
    have := hM _ hsub
    have hcast : ∑ n ∈ s with n.Prime, (1 : ℝ) / n
        = ((∑ n ∈ s with n.Prime, (1 : ℚ) / n : ℚ) : ℝ) := by push_cast; ring
    rw [hcast]
    exact_mod_cast this

/-- **Divergence is not sufficient.**  There is a set of integers `≥ 2` whose reciprocal
sum diverges but which contains no finite subset of reciprocal sum `1`.  Consequently the
pigeonhole step `exists_divergent_colorClass` can never, by itself, prove the
Erdős–Graham conjecture. -/
theorem divergence_not_sufficient :
    ∃ A : Set ℕ, (∀ n ∈ A, 2 ≤ n) ∧ DivergentReciprocals A ∧ EgyptianFree A :=
  ⟨{p : ℕ | p.Prime}, fun _ hn => hn.two_le, primes_divergentReciprocals,
    egyptianFree_primes⟩

end DivergenceInsufficient

section ExplicitWitnesses

/-- An explicit Egyptian set all of whose 21 denominators are **not** prime powers
(all of them divide `27720 = 2^3·3^2·5·7·11`).  Hence the prime-power obstruction is
sharp: its complement is not Egyptian-free. -/
theorem egyptian_avoiding_primePowers :
    ∃ S : Finset ℕ, Egyptian S ∧ (∀ n ∈ S, ¬ IsPrimePow n) ∧ S.card = 21 := by
  refine ⟨{6, 10, 12, 14, 15, 18, 20, 21, 22, 24, 28, 30, 33, 36, 40, 42, 44, 45, 55, 60, 63},
    ⟨by decide, ?_⟩, ?_, by decide⟩
  · repeat rw [Finset.sum_insert (by decide)]
    rw [Finset.sum_singleton]
    norm_num
  · intro n hn
    fin_cases hn <;>
      first
        | exact not_isPrimePow_of_two_primes (p := 2) (q := 3) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 2) (q := 5) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 2) (q := 7) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 2) (q := 11) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 3) (q := 5) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 3) (q := 7) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 3) (q := 11) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)
        | exact not_isPrimePow_of_two_primes (p := 5) (q := 11) (by norm_num) (by norm_num)
            (by norm_num) (by decide) (by decide)

/-- **An unconditional two-colour instance.**  If a two-colouring of the integers `≥ 2`
gives colour `0` only to prime powers, then colour `1` contains an exact Egyptian
decomposition; in particular the colouring has a monochromatic set of reciprocal sum `1`. -/
theorem erdosGraham_two_of_primePow_class (c : ℕ → Fin 2)
    (h : ∀ n, 2 ≤ n → c n = 0 → IsPrimePow n) :
    ∃ (S : Finset ℕ) (i : Fin 2), Egyptian S ∧ ∀ n ∈ S, c n = i := by
  obtain ⟨S, hS, hnpp, -⟩ := egyptian_avoiding_primePowers
  refine ⟨S, 1, hS, fun n hn => ?_⟩
  have h2 : 2 ≤ n := hS.1 n hn
  have : c n ≠ 0 := fun h0 => hnpp n hn (h n h2 h0)
  omega

/-- An explicit Egyptian covering whose 23 denominators are all `≥ 10`: exact coverings can
avoid every small denominator, so no finite set of "cheap" denominators is indispensable. -/
theorem exists_egyptian_min_ge_ten :
    ∃ S : Finset ℕ, Egyptian S ∧ (∀ n ∈ S, 10 ≤ n) ∧ S.card = 23 := by
  refine ⟨{10, 11, 12, 14, 15, 16, 18, 20, 21, 22, 24, 28, 30, 33, 36, 40, 42, 45, 48, 55,
    60, 63, 66}, ⟨by decide, ?_⟩, by decide, by decide⟩
  repeat rw [Finset.sum_insert (by decide)]
  rw [Finset.sum_singleton]
  norm_num

/-- **A second unconditional two-colour instance.**  If a two-colouring uses colour `0`
only on denominators `< 10`, the other colour class carries an exact Egyptian covering. -/
theorem erdosGraham_two_of_small_class (c : ℕ → Fin 2)
    (h : ∀ n, 2 ≤ n → c n = 0 → n < 10) :
    ∃ (S : Finset ℕ) (i : Fin 2), Egyptian S ∧ ∀ n ∈ S, c n = i := by
  obtain ⟨S, hS, hmin, -⟩ := exists_egyptian_min_ge_ten
  refine ⟨S, 1, hS, fun n hn => ?_⟩
  have h2 : 2 ≤ n := hS.1 n hn
  have hne : c n ≠ 0 := fun h0 => absurd (h n h2 h0) (by have := hmin n hn; omega)
  omega

end ExplicitWitnesses

end ErdosGraham