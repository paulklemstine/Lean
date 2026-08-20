/-
# The two-parameter ±-frame: coefficients of binary cyclotomic polynomials

## Research thread

The *±-frame* of order `n` is the `n`-th cyclotomic polynomial `Φₙ ∈ ℤ[X]`, viewed
as a signed frame: the interesting question is how negative a coefficient can be.

* **One-parameter case (already a theorem).**  For a prime `p`,
  `Φ_p = 1 + X + ⋯ + X^{p-1}`, so every coefficient is `0` or `1`; in particular
  every coefficient — the head coefficient included — is `≥ -1`.  This is
  `headCoeff_pmFrame_ge_neg_one` below.

* **Two-parameter case (this file).**  For two *distinct* primes `p ≠ q` the
  closed formula

      Φ_{pq}(X) · (X^{pq} - 1) = (X - 1) · G_{p,q}(X),
      G_{p,q}(X) = (∑_{i<q} X^{ip}) · (∑_{j<p} X^{jq})

  turns the question into a statement about **integer points in a
  two-dimensional region**: the coefficient of `X^n` in `G_{p,q}` counts the
  lattice points `(i,j)` of the box `[0,q) × [0,p)` on the line `ip + jq = n`,
  and the *balance / cycle-type* constraint `i < q`, `j < p` forces that count to
  be `0` or `1`.  Consequently

      Φ_{pq}.coeff n = G.coeff n - G.coeff (n-1) ∈ {-1, 0, 1}

  for every `n`, which is Migotti's theorem.  The arithmetic core is a pure
  `omega`/`nlinarith` statement about the box (`repPair_unique`).

* **Sharpness.**  The bound `-1` is attained: `Φ₁₅.coeff 7 = -1`
  (`coeff_pmFrame_fifteen_seven`), proved from the closed formula by counting the
  (empty) set of lattice points on `3i + 5j = 7` inside `[0,5) × [0,3)`.

* **Balance.**  `Φ_{pq}(1) = 1`, so along the frame the `+1`'s outnumber the
  `-1`'s by exactly one (`pmFrame_coeff_sum_eq_one`).

Everything is proved from scratch on top of mathlib's `Polynomial.cyclotomic`.
-/
import Mathlib

namespace PMFrame

open Polynomial Finset

/-! ## 1. The ±-frame and its two-parameter geometric companion -/

/-- The **±-frame** of order `n`: the `n`-th cyclotomic polynomial over `ℤ`. -/
noncomputable def pmFrame (n : ℕ) : Polynomial ℤ := cyclotomic n ℤ

/-- The **two-parameter frame geometry** `G_{p,q}`: the product of the two
truncated geometric series with steps `p` and `q`.  Its `n`-th coefficient counts
lattice points of the box `[0,q) × [0,p)` on the line `ip + jq = n`. -/
noncomputable def frameGeom (p q : ℕ) : Polynomial ℤ :=
  (∑ i ∈ range q, X ^ (i * p)) * (∑ j ∈ range p, X ^ (j * q))

/-- The set of **lattice points of the balance box** `[0,q) × [0,p)` lying on the
line `i·p + j·q = n`. -/
def repPairs (p q n : ℕ) : Finset (ℕ × ℕ) :=
  (range q ×ˢ range p).filter (fun ij => ij.1 * p + ij.2 * q = n)

/-! ## 2. The arithmetic core: uniqueness of lattice points in the balance box -/

/-- **Two-dimensional integer-point uniqueness.**  If `p` and `q` are coprime then
the line `i·p + j·q = n` meets the box `[0,q) × [0,p)` in at most one point.  This
is the "balance + cycle-type" constraint of the research framing, and its proof is
elementary divisibility plus `omega`. -/
theorem repPair_unique {p q : ℕ} (hcop : Nat.Coprime p q) (hq : 0 < q)
    {i j i' j' : ℕ} (hi : i < q) (hi' : i' < q)
    (hE : i * p + j * q = i' * p + j' * q) : i = i' ∧ j = j' := by
  have key : ∀ a b c d : ℕ, b < q → a ≤ b → a * p + c * q = b * p + d * q → a = b := by
    intro a b c d hb hab hE
    have hcd : d ≤ c := by nlinarith [Nat.sub_add_cancel hab]
    have h1 : (b - a) * p = (c - d) * q := by
      have e1 : (b - a) * p + a * p = b * p := by rw [← Nat.add_mul, Nat.sub_add_cancel hab]
      have e2 : (c - d) * q + d * q = c * q := by rw [← Nat.add_mul, Nat.sub_add_cancel hcd]
      omega
    have hdvd : q ∣ (b - a) * p := ⟨c - d, by rw [h1]; ring⟩
    have hqa : q ∣ (b - a) := Nat.Coprime.dvd_of_dvd_mul_right (Nat.Coprime.symm hcop) hdvd
    rcases Nat.eq_zero_or_pos (b - a) with h0 | h0
    · omega
    · have := Nat.le_of_dvd h0 hqa; omega
  have hij : i = i' := by
    rcases le_total i i' with h | h
    · exact key i i' j j' hi' h hE
    · exact (key i' i j' j hi h hE.symm).symm
  subst hij
  exact ⟨rfl, Nat.eq_of_mul_eq_mul_right hq (by omega)⟩

/-- The balance box meets each line in at most one lattice point. -/
theorem card_repPairs_le_one {p q : ℕ} (hcop : Nat.Coprime p q) (hq : 0 < q) (n : ℕ) :
    (repPairs p q n).card ≤ 1 := by
  rw [Finset.card_le_one]
  rintro ⟨i, j⟩ ha ⟨i', j'⟩ hb
  simp only [repPairs, Finset.mem_filter, Finset.mem_product, Finset.mem_range] at ha hb
  obtain ⟨⟨hi, hj⟩, hE⟩ := ha
  obtain ⟨⟨hi', hj'⟩, hE'⟩ := hb
  obtain ⟨h1, h2⟩ := repPair_unique hcop hq hi hi' (hE.trans hE'.symm)
  simp [h1, h2]

/-! ## 3. Coefficients of the frame geometry count lattice points -/

theorem coeff_frameGeom (p q n : ℕ) :
    (frameGeom p q).coeff n = ((repPairs p q n).card : ℤ) := by
  unfold frameGeom repPairs
  rw [Finset.sum_mul_sum, Polynomial.finset_sum_coeff]
  simp only [Polynomial.finset_sum_coeff, ← pow_add, Polynomial.coeff_X_pow]
  rw [← Finset.sum_product', Finset.card_filter]
  push_cast
  refine Finset.sum_congr rfl (fun x _ => ?_)
  by_cases h : x.1 * p + x.2 * q = n
  · simp [h]
  · simp only [h, if_false, ite_eq_right_iff]
    omega

/-- Every coefficient of the frame geometry is `0` or `1`. -/
theorem coeff_frameGeom_le_one {p q : ℕ} (hcop : Nat.Coprime p q) (hq : 0 < q) (n : ℕ) :
    0 ≤ (frameGeom p q).coeff n ∧ (frameGeom p q).coeff n ≤ 1 := by
  rw [coeff_frameGeom]
  have := card_repPairs_le_one hcop hq n
  constructor
  · positivity
  · exact_mod_cast this

/-! ## 4. The closed formula -/

theorem frameGeom_identity (p q : ℕ) :
    ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) * frameGeom p q = (X ^ (p * q) - 1) ^ 2 := by
  have h1 : (∑ i ∈ range q, (X : Polynomial ℤ) ^ (i * p)) * (X ^ p - 1) = X ^ (p * q) - 1 := by
    rw [show (∑ i ∈ range q, (X : Polynomial ℤ) ^ (i * p))
          = ∑ i ∈ range q, ((X : Polynomial ℤ) ^ p) ^ i from
        Finset.sum_congr rfl (fun i _ => by rw [← pow_mul, mul_comm]), geom_sum_mul, ← pow_mul]
  have h2 : (∑ j ∈ range p, (X : Polynomial ℤ) ^ (j * q)) * (X ^ q - 1) = X ^ (p * q) - 1 := by
    rw [show (∑ j ∈ range p, (X : Polynomial ℤ) ^ (j * q))
          = ∑ j ∈ range p, ((X : Polynomial ℤ) ^ q) ^ j from
        Finset.sum_congr rfl (fun j _ => by rw [← pow_mul, mul_comm]), geom_sum_mul, ← pow_mul,
      mul_comm q p]
  unfold frameGeom
  calc ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) *
        ((∑ i ∈ range q, X ^ (i * p)) * (∑ j ∈ range p, X ^ (j * q)))
      = ((∑ i ∈ range q, (X : Polynomial ℤ) ^ (i * p)) * (X ^ p - 1)) *
        ((∑ j ∈ range p, (X : Polynomial ℤ) ^ (j * q)) * (X ^ q - 1)) := by ring
    _ = (X ^ (p * q) - 1) ^ 2 := by rw [h1, h2]; ring

/-- The cyclotomic factorisation of `X^{pq} - 1` for distinct primes. -/
theorem pmFrame_mul_identity {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) * pmFrame (p * q)
      = (X - 1) * (X ^ (p * q) - 1) := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hltp : p < p * q := by nlinarith
  have hltq : q < p * q := by nlinarith
  have hdiv : (p * q).divisors = {1, p, q, p * q} := by
    ext d
    simp only [Nat.mem_divisors, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hd, -⟩
      obtain ⟨a, b, ha, hb, rfl⟩ := dvd_mul.mp hd
      rcases hp.eq_one_or_self_of_dvd a ha with rfl | rfl <;>
        rcases hq.eq_one_or_self_of_dvd b hb with rfl | rfl <;> simp
    · rintro (rfl | rfl | rfl | rfl) <;> exact ⟨by simp, by omega⟩
  have hprod := Polynomial.prod_cyclotomic_eq_X_pow_sub_one (n := p * q) (by omega) ℤ
  rw [hdiv, Finset.prod_insert (by simp; omega), Finset.prod_insert (by simp; omega),
    Finset.prod_insert (by simp; omega), Finset.prod_singleton, Polynomial.cyclotomic_one] at hprod
  have hcp : cyclotomic p ℤ * (X - 1) = X ^ p - 1 := Polynomial.cyclotomic_prime_mul_X_sub_one ℤ p
  have hcq : cyclotomic q ℤ * (X - 1) = X ^ q - 1 := Polynomial.cyclotomic_prime_mul_X_sub_one ℤ q
  unfold pmFrame
  calc ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) * cyclotomic (p * q) ℤ
      = (X - 1) * ((X - 1) * (cyclotomic p ℤ * (cyclotomic q ℤ * cyclotomic (p * q) ℤ))) := by
        rw [← hcp, ← hcq]; ring
    _ = (X - 1) * (X ^ (p * q) - 1) := by rw [hprod]

private lemma X_pow_sub_one_ne_zero {k : ℕ} (hk : 0 < k) :
    ((X : Polynomial ℤ) ^ k - 1) ≠ 0 := by
  intro hcon
  have := congrArg (Polynomial.eval 0) hcon
  simp [zero_pow hk.ne'] at this

/-- **The closed formula.**  For distinct primes `p ≠ q`,
`Φ_{pq}(X)·(X^{pq}-1) = (X-1)·G_{p,q}(X)`. -/
theorem pmFrame_closed_formula {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    pmFrame (p * q) * ((X : Polynomial ℤ) ^ (p * q) - 1) = (X - 1) * frameGeom p q := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hne : ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) ≠ 0 :=
    mul_ne_zero (X_pow_sub_one_ne_zero hp0) (X_pow_sub_one_ne_zero hq0)
  refine mul_left_cancel₀ hne ?_
  calc ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) * (pmFrame (p * q) * (X ^ (p * q) - 1))
      = (((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) * pmFrame (p * q)) * (X ^ (p * q) - 1) := by
        ring
    _ = ((X : Polynomial ℤ) - 1) * (X ^ (p * q) - 1) * (X ^ (p * q) - 1) := by
        rw [pmFrame_mul_identity hp hq h]
    _ = ((X : Polynomial ℤ) - 1) * ((X ^ p - 1) * (X ^ q - 1) * frameGeom p q) := by
        rw [frameGeom_identity]; ring
    _ = ((X : Polynomial ℤ) ^ p - 1) * (X ^ q - 1) * ((X - 1) * frameGeom p q) := by ring

/-! ## 5. From the closed formula to the coefficients -/

/-- Below the exponent `pq`, the coefficients of the ±-frame are the successive
differences of the lattice-point counts. -/
theorem coeff_pmFrame_succ {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    {n : ℕ} (hn : n + 1 < p * q) :
    (pmFrame (p * q)).coeff (n + 1)
      = (frameGeom p q).coeff (n + 1) - (frameGeom p q).coeff n := by
  have hform := congrArg (fun f => Polynomial.coeff f (n + 1)) (pmFrame_closed_formula hp hq h)
  simp only [mul_sub, sub_mul, Polynomial.coeff_sub, mul_one, one_mul] at hform
  rw [Polynomial.coeff_mul_X_pow'] at hform
  rw [if_neg (by omega)] at hform
  rw [Polynomial.coeff_X_mul] at hform
  linarith [hform]

theorem coeff_pmFrame_zero {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    (hpq : 0 < p * q) :
    (pmFrame (p * q)).coeff 0 = (frameGeom p q).coeff 0 := by
  have hform := congrArg (fun f => Polynomial.coeff f 0) (pmFrame_closed_formula hp hq h)
  simp only [mul_sub, sub_mul, Polynomial.coeff_sub, mul_one, one_mul] at hform
  rw [Polynomial.coeff_mul_X_pow'] at hform
  rw [if_neg (by omega)] at hform
  simp only [Polynomial.mul_coeff_zero, Polynomial.coeff_X_zero, zero_mul] at hform
  linarith [hform]

/-! ## 6. Main theorems -/

private lemma deg_eq_frobenius_succ {p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q) :
    (p - 1) * (q - 1) = (p * q - p - q) + 1 := by
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 2 := ⟨p - 2, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 2 := ⟨q - 2, by omega⟩
  have h : (a + 2) * (b + 2) = a * b + 2 * a + 2 * b + 4 := by ring
  have h2 : (a + 2 - 1) * (b + 2 - 1) = a * b + a + b + 1 := by
    have ea : a + 2 - 1 = a + 1 := by omega
    have eb : b + 2 - 1 = b + 1 := by omega
    rw [ea, eb]; ring
  omega

/-- The degree of a semiprime ±-frame. -/
theorem natDegree_pmFrame {p q : ℕ} (hcop : Nat.Coprime p q) (hp : p.Prime) (hq : q.Prime) :
    (pmFrame (p * q)).natDegree = (p - 1) * (q - 1) := by
  unfold pmFrame
  rw [Polynomial.natDegree_cyclotomic, Nat.totient_mul hcop,
    Nat.totient_prime hp, Nat.totient_prime hq]

/-- The top coefficient of a semiprime ±-frame is `1`. -/
theorem coeff_pmFrame_natDegree {p q : ℕ} (hcop : Nat.Coprime p q) (hp : p.Prime) (hq : q.Prime) :
    (pmFrame (p * q)).coeff ((p - 1) * (q - 1)) = 1 := by
  have hmonic : (pmFrame (p * q)).Monic := Polynomial.cyclotomic.monic (p * q) ℤ
  have := hmonic.coeff_natDegree
  rwa [natDegree_pmFrame hcop hp hq] at this


/-- **One-parameter case.**  For a prime `p`, every coefficient of the ±-frame
`Φ_p` is `≥ -1` (indeed it is `0` or `1`). -/
theorem headCoeff_pmFrame_ge_neg_one (p : ℕ) (hp : p.Prime) (k : ℕ) :
    -1 ≤ (pmFrame p).coeff k := by
  haveI : Fact p.Prime := ⟨hp⟩
  unfold pmFrame
  rw [Polynomial.cyclotomic_prime ℤ p, Polynomial.finset_sum_coeff]
  have hc : ∀ i ∈ range p, ((X : Polynomial ℤ) ^ i).coeff k = if k = i then 1 else 0 := by
    intro i _; simp [Polynomial.coeff_X_pow]
  rw [Finset.sum_congr rfl hc, Finset.sum_ite_eq (range p) k (fun _ => (1 : ℤ))]
  split <;> norm_num

/-- The one-parameter case, sharp form: the coefficients of `Φ_p` are `0` or `1`. -/
theorem coeff_pmFrame_prime_mem (p : ℕ) (hp : p.Prime) (k : ℕ) :
    (pmFrame p).coeff k = 0 ∨ (pmFrame p).coeff k = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  unfold pmFrame
  rw [Polynomial.cyclotomic_prime ℤ p, Polynomial.finset_sum_coeff]
  have hc : ∀ i ∈ range p, ((X : Polynomial ℤ) ^ i).coeff k = if k = i then 1 else 0 := by
    intro i _; simp [Polynomial.coeff_X_pow]
  rw [Finset.sum_congr rfl hc, Finset.sum_ite_eq (range p) k (fun _ => (1 : ℤ))]
  split
  · exact Or.inr rfl
  · exact Or.inl rfl

/-- **Two-parameter case (Migotti's theorem).**  For distinct primes `p ≠ q`,
every coefficient of the ±-frame `Φ_{pq}` lies in `{-1, 0, 1}`. -/
theorem coeff_pmFrame_two_param_abs_le_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    (k : ℕ) : |(pmFrame (p * q)).coeff k| ≤ 1 := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 h
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hq0 : 0 < q := hq.pos
  rcases lt_or_ge k (p * q) with hk | hk
  · match k with
    | 0 =>
        rw [coeff_pmFrame_zero hp hq h (by omega)]
        obtain ⟨h0, h1⟩ := coeff_frameGeom_le_one hcop hq0 0
        rw [abs_le]; omega
    | (n + 1) =>
        rw [coeff_pmFrame_succ hp hq h hk]
        obtain ⟨h0, h1⟩ := coeff_frameGeom_le_one hcop hq0 (n + 1)
        obtain ⟨h2, h3⟩ := coeff_frameGeom_le_one hcop hq0 n
        rw [abs_le]; omega
  · have hpq : p + q ≤ p * q := by nlinarith
    have hlt : (pmFrame (p * q)).natDegree < k := by
      rw [natDegree_pmFrame hcop hp hq, deg_eq_frobenius_succ hp2 hq2]
      omega
    rw [Polynomial.coeff_eq_zero_of_natDegree_lt hlt]
    norm_num

/-- **The headline bound in the two-parameter case**: every coefficient of the
±-frame of a semiprime order is `≥ -1`. -/
theorem coeff_pmFrame_two_param_ge_neg_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    (k : ℕ) : -1 ≤ (pmFrame (p * q)).coeff k :=
  neg_le_of_abs_le (coeff_pmFrame_two_param_abs_le_one hp hq h k)

/-- The matching upper bound. -/
theorem coeff_pmFrame_two_param_le_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    (k : ℕ) : (pmFrame (p * q)).coeff k ≤ 1 :=
  le_of_abs_le (coeff_pmFrame_two_param_abs_le_one hp hq h k)

/-- Trichotomy form. -/
theorem coeff_pmFrame_two_param_mem {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    (k : ℕ) : (pmFrame (p * q)).coeff k = -1 ∨ (pmFrame (p * q)).coeff k = 0 ∨
      (pmFrame (p * q)).coeff k = 1 := by
  have h1 := coeff_pmFrame_two_param_ge_neg_one hp hq h k
  have h2 := coeff_pmFrame_two_param_le_one hp hq h k
  omega

/-! ## 7. Balance: the signs sum to one -/

/-- **Balance law.**  For distinct primes `p ≠ q`, the coefficients of `Φ_{pq}`
sum to `1`: since they lie in `{-1,0,1}`, the `+1`'s exceed the `-1`'s by exactly
one. -/
theorem pmFrame_coeff_sum_eq_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    ∑ k ∈ range ((pmFrame (p * q)).natDegree + 1), (pmFrame (p * q)).coeff k = 1 := by
  have hnpp : ∀ {r : ℕ}, r.Prime → ∀ k : ℕ, r ^ k ≠ p * q := by
    intro r hr k hrk
    have hpr : p = r := (Nat.prime_dvd_prime_iff_eq hp hr).1
      (hp.dvd_of_dvd_pow (n := k) (hrk ▸ Dvd.intro q rfl))
    have hqr : q = r := (Nat.prime_dvd_prime_iff_eq hq hr).1
      (hq.dvd_of_dvd_pow (n := k) (hrk ▸ Dvd.intro_left p rfl))
    exact h (hpr.trans hqr.symm)
  have heval : Polynomial.eval 1 (pmFrame (p * q)) = 1 := by
    unfold pmFrame
    exact Polynomial.eval_one_cyclotomic_not_prime_pow hnpp
  rw [← heval, Polynomial.eval_eq_sum_range]
  simp

/-! ## 8. Sharpness of the bound `-1` -/

/-- The bound is attained: `Φ₁₅` has a coefficient equal to `-1`.  The proof runs
through the closed formula: `7` is *not* representable as `3i + 5j` inside the
balance box `[0,5) × [0,3)`, while `6 = 3·2 + 5·0` is. -/
theorem coeff_pmFrame_fifteen_seven : (pmFrame 15).coeff 7 = -1 := by
  have h3 : Nat.Prime 3 := by norm_num
  have h5 : Nat.Prime 5 := by norm_num
  have hmul : (15 : ℕ) = 3 * 5 := by norm_num
  have hstep : (pmFrame (3 * 5)).coeff (6 + 1)
      = (frameGeom 3 5).coeff (6 + 1) - (frameGeom 3 5).coeff 6 :=
    coeff_pmFrame_succ h3 h5 (by norm_num) (by norm_num)
  rw [hmul, hstep, coeff_frameGeom, coeff_frameGeom]
  norm_num [repPairs, Finset.filter_eq', show (7 : ℕ) = 7 from rfl]
  decide

/-! ## 9. The numerical semigroup `⟨p,q⟩` and the exact sign pattern -/

/-- `n` is **frame-representable** for `(p,q)` when it lies in the numerical
semigroup generated by `p` and `q`. -/
def FrameRep (p q n : ℕ) : Prop := ∃ i j : ℕ, i * p + j * q = n

/-- Below `pq`, membership in the numerical semigroup is exactly the existence of a
lattice point inside the balance box. -/
theorem repPairs_nonempty_iff {p q n : ℕ} (hn : n < p * q) :
    (repPairs p q n).Nonempty ↔ FrameRep p q n := by
  constructor
  · rintro ⟨⟨i, j⟩, hij⟩
    simp only [repPairs, Finset.mem_filter] at hij
    exact ⟨i, j, hij.2⟩
  · rintro ⟨i, j, hij⟩
    have hi : i < q := by
      by_contra hcon
      push_neg at hcon
      have : q * p ≤ i * p := Nat.mul_le_mul_right p hcon
      nlinarith
    have hj : j < p := by
      by_contra hcon
      push_neg at hcon
      have : p * q ≤ j * q := Nat.mul_le_mul_right q hcon
      nlinarith
    exact ⟨(i, j), by simp [repPairs, hi, hj, hij]⟩

theorem repPairs_eq_empty_iff {p q n : ℕ} (hn : n < p * q) :
    repPairs p q n = ∅ ↔ ¬ FrameRep p q n := by
  rw [← Finset.not_nonempty_iff_eq_empty, repPairs_nonempty_iff hn]

/-- Below `pq`, the frame-geometry coefficient is the indicator of the numerical
semigroup. -/
theorem coeff_frameGeom_eq_indicator {p q : ℕ} (hcop : Nat.Coprime p q) (hq : 0 < q)
    {n : ℕ} (hn : n < p * q) [Decidable (FrameRep p q n)] :
    (frameGeom p q).coeff n = if FrameRep p q n then 1 else 0 := by
  rw [coeff_frameGeom]
  by_cases hR : FrameRep p q n
  · rw [if_pos hR]
    have hne : (repPairs p q n).Nonempty := (repPairs_nonempty_iff hn).2 hR
    have h1 : 1 ≤ (repPairs p q n).card := Finset.card_pos.2 hne
    have h2 := card_repPairs_le_one hcop hq n
    have : (repPairs p q n).card = 1 := by omega
    simp [this]
  · rw [if_neg hR]
    have : repPairs p q n = ∅ := (repPairs_eq_empty_iff hn).2 hR
    simp [this]

/-- **Exact sign pattern (Lam–Leung form).**  For distinct primes `p ≠ q` and
`n + 1 < pq`, the `(n+1)`-st coefficient of the ±-frame is the difference of the
indicators of the numerical semigroup at `n+1` and at `n`. -/
theorem coeff_pmFrame_succ_indicator {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    {n : ℕ} (hn : n + 1 < p * q)
    [Decidable (FrameRep p q (n + 1))] [Decidable (FrameRep p q n)] :
    (pmFrame (p * q)).coeff (n + 1)
      = (if FrameRep p q (n + 1) then 1 else 0) - (if FrameRep p q n then 1 else 0) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 h
  rw [coeff_pmFrame_succ hp hq h hn,
    coeff_frameGeom_eq_indicator hcop hq.pos hn,
    coeff_frameGeom_eq_indicator hcop hq.pos (by omega)]

/-! ## 10. Sharpness for **every** semiprime -/

theorem repPairs_zero {p q : ℕ} (hp : 0 < p) (hq : 0 < q) : repPairs p q 0 = {(0, 0)} := by
  ext ⟨i, j⟩
  simp only [repPairs, Finset.mem_filter, Finset.mem_product, Finset.mem_range,
    Finset.mem_singleton, Prod.mk.injEq, Nat.add_eq_zero_iff, Nat.mul_eq_zero]
  constructor
  · rintro ⟨⟨hi, hj⟩, h1, h2⟩; omega
  · rintro ⟨rfl, rfl⟩; simp [hp, hq]

theorem repPairs_one {p q : ℕ} (hp : 2 ≤ p) (hq : 2 ≤ q) : repPairs p q 1 = ∅ := by
  ext ⟨i, j⟩
  simp only [repPairs, Finset.mem_filter, Finset.mem_product, Finset.mem_range,
    Finset.notMem_empty, iff_false, not_and]
  rintro ⟨hi, hj⟩ h1
  rcases Nat.eq_zero_or_pos i with rfl | hi0
  · rcases Nat.eq_zero_or_pos j with rfl | hj0
    · omega
    · nlinarith
  · nlinarith

/-- The constant term of a semiprime ±-frame is `1`. -/
theorem coeff_pmFrame_zero_eq_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    (pmFrame (p * q)).coeff 0 = 1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  rw [coeff_pmFrame_zero hp hq h (by nlinarith), coeff_frameGeom,
    repPairs_zero hp.pos hq.pos]
  simp

/-- **Sharpness for every semiprime.**  The linear coefficient of `Φ_{pq}` is
exactly `-1`, because `1` is never in the numerical semigroup `⟨p,q⟩` while `0`
always is.  Hence the lower bound `-1` of
`coeff_pmFrame_two_param_ge_neg_one` is attained for *every* pair of distinct
primes. -/
theorem coeff_pmFrame_one_eq_neg_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    (pmFrame (p * q)).coeff 1 = -1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hlt : 0 + 1 < p * q := by nlinarith
  have hstep := coeff_pmFrame_succ hp hq h hlt
  simp only [zero_add] at hstep
  rw [hstep, coeff_frameGeom, coeff_frameGeom, repPairs_one hp2 hq2,
    repPairs_zero hp.pos hq.pos]
  simp

/-- The set of coefficient values of a semiprime ±-frame has least element `-1`. -/
theorem pmFrame_isLeast_neg_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q) :
    IsLeast {c : ℤ | ∃ k, (pmFrame (p * q)).coeff k = c} (-1) :=
  ⟨⟨1, coeff_pmFrame_one_eq_neg_one hp hq h⟩, by
    rintro c ⟨k, rfl⟩
    exact coeff_pmFrame_two_param_ge_neg_one hp hq h k⟩

/-! ## 11. Sylvester symmetry of the balance region -/

/-- **Half of the symmetry**: `n` and the Frobenius reflection `pq - p - q - n`
cannot both lie in the numerical semigroup `⟨p,q⟩`. -/
theorem not_frameRep_and_reflect {p q : ℕ} (hcop : Nat.Coprime p q) (hp : 2 ≤ p) (hq : 2 ≤ q)
    {n : ℕ} (hn : n ≤ p * q - p - q) (h1 : FrameRep p q n)
    (h2 : FrameRep p q (p * q - p - q - n)) : False := by
  obtain ⟨i, j, hij⟩ := h1
  obtain ⟨i', j', hij'⟩ := h2
  have hpq : p + q ≤ p * q := by nlinarith
  have key : (i + i' + 1) * p + (j + j' + 1) * q = p * q := by
    have hexp : (i + i' + 1) * p + (j + j' + 1) * q
        = (i * p + j * q) + (i' * p + j' * q) + p + q := by ring
    rw [hexp, hij, hij']
    omega
  have hle1 : i + i' + 1 ≤ q := by nlinarith
  have hle2 : j + j' + 1 ≤ p := by nlinarith
  have hdp : p ∣ (j + j' + 1) * q := ⟨q - (i + i' + 1), by
    have h5 : p * q - (i + i' + 1) * p = (j + j' + 1) * q := by omega
    rw [← h5, Nat.mul_sub]; ring_nf⟩
  have h3 := Nat.le_of_dvd (by omega) (Nat.Coprime.dvd_of_dvd_mul_right hcop hdp)
  have hdq : q ∣ (i + i' + 1) * p := ⟨p - (j + j' + 1), by
    have h6 : p * q - (j + j' + 1) * q = (i + i' + 1) * p := by omega
    rw [← h6, Nat.mul_sub]; ring_nf⟩
  have h4 := Nat.le_of_dvd (by omega) (Nat.Coprime.dvd_of_dvd_mul_right hcop.symm hdq)
  nlinarith

/-- **The other half**: if `n` is *not* in the numerical semigroup then its
Frobenius reflection is.  (The hypothesis `n ≤ pq - p - q` turned out to be
unnecessary: for larger `n` truncated subtraction makes the conclusion trivial.)
The proof produces the reflection explicitly from the modular inverse of `q`
modulo `p`. -/
theorem frameRep_reflect_of_not {p q : ℕ} (hcop : Nat.Coprime p q) (hp : 2 ≤ p) (hq : 2 ≤ q)
    (n : ℕ) (h1 : ¬ FrameRep p q n) : FrameRep p q (p * q - p - q - n) := by
  haveI : NeZero p := ⟨by omega⟩
  have hpq : p + q ≤ p * q := by nlinarith
  have hunit : IsUnit (q : ZMod p) := (ZMod.isUnit_iff_coprime q p).2 hcop.symm
  set x : ZMod p := (n : ZMod p) * (↑q)⁻¹ with hx
  set j : ℕ := x.val with hj
  have hjlt : j < p := ZMod.val_lt x
  have hmod : (j * q : ℕ) ≡ n [MOD p] := by
    have hz : ((j * q : ℕ) : ZMod p) = ((n : ℕ) : ZMod p) := by
      push_cast
      rw [hj, ZMod.natCast_val, ZMod.cast_id, hx, mul_assoc, ZMod.inv_mul_of_unit _ hunit, mul_one]
    exact (ZMod.natCast_eq_natCast_iff _ _ _).1 hz
  have hgt : n < j * q := by
    by_contra hcon
    push_neg at hcon
    obtain ⟨c, hc⟩ := (Nat.modEq_iff_dvd' hcon).1 hmod
    exact h1 ⟨c, j, by rw [mul_comm c p]; omega⟩
  obtain ⟨c, hc⟩ := (Nat.modEq_iff_dvd' hgt.le).1 hmod.symm
  have hcpos : 0 < c := by
    rcases Nat.eq_zero_or_pos c with rfl | hcp
    · simp at hc; omega
    · exact hcp
  obtain ⟨d, rfl⟩ : ∃ d, c = d + 1 := ⟨c - 1, by omega⟩
  obtain ⟨e, he⟩ : ∃ e, p = j + e + 1 := ⟨p - 1 - j, by omega⟩
  refine ⟨d, e, ?_⟩
  have hring : (j + e + 1) * q = j * q + e * q + q := by ring
  have hsum : j * q + e * q + q = p * q := by rw [← hring, ← he]
  have hexp : p * (d + 1) = d * p + p := by ring
  omega

/-- **Sylvester symmetry.**  For `0 ≤ n ≤ pq - p - q`, exactly one of `n` and its
Frobenius reflection lies in the numerical semigroup `⟨p,q⟩`. -/
theorem frameRep_reflect_iff {p q : ℕ} (hcop : Nat.Coprime p q) (hp : 2 ≤ p) (hq : 2 ≤ q)
    {n : ℕ} (hn : n ≤ p * q - p - q) :
    FrameRep p q n ↔ ¬ FrameRep p q (p * q - p - q - n) := by
  constructor
  · exact fun hR hR' => not_frameRep_and_reflect hcop hp hq hn hR hR'
  · intro hnot
    by_contra hR
    exact hnot (frameRep_reflect_of_not hcop hp hq n hR)

/-- **Reflected balance of the frame geometry.**  For `n ≤ pq - p - q` the
lattice-point counts at `n` and at the Frobenius reflection of `n` sum to `1`. -/
theorem coeff_frameGeom_add_reflect {p q : ℕ} (hcop : Nat.Coprime p q) (hp : 2 ≤ p) (hq : 2 ≤ q)
    {n : ℕ} (hn : n ≤ p * q - p - q) :
    (frameGeom p q).coeff n + (frameGeom p q).coeff (p * q - p - q - n) = 1 := by
  classical
  have hpq : p + q ≤ p * q := by nlinarith
  have hlt : n < p * q := by omega
  have hlt' : p * q - p - q - n < p * q := by omega
  rw [coeff_frameGeom_eq_indicator hcop (by omega) hlt,
    coeff_frameGeom_eq_indicator hcop (by omega) hlt']
  by_cases hR : FrameRep p q n
  · rw [if_pos hR, if_neg ((frameRep_reflect_iff hcop hp hq hn).1 hR)]; ring
  · rw [if_neg hR, if_pos (frameRep_reflect_of_not hcop hp hq n hR)]; ring

/-! ## 12. Sylvester's gap count -/

/-- The **gaps** of the balance region: the exponents `n` below `deg Φ_{pq}` that
carry no lattice point in the box, i.e. the elements missing from the numerical
semigroup `⟨p,q⟩`. -/
def frameGaps (p q : ℕ) : Finset ℕ :=
  (range ((p - 1) * (q - 1))).filter (fun n => repPairs p q n = ∅)

/-- **Sylvester's theorem, frame form.**  Exactly half of the exponents
`0, 1, …, (p-1)(q-1) - 1` are gaps of the balance region: the gap count is
`(p-1)(q-1)/2`.  Equivalently, exactly half of the coefficient slots of `Φ_{pq}`
sit over a lattice point of the box. -/
theorem card_frameGaps {p q : ℕ} (hcop : Nat.Coprime p q) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    (frameGaps p q).card * 2 = (p - 1) * (q - 1) := by
  set F := p * q - p - q with hF
  set D := (p - 1) * (q - 1) with hD
  have hpq : p + q ≤ p * q := by nlinarith
  have hDF : D = F + 1 := deg_eq_frobenius_succ hp hq
  have hlt : ∀ n < D, n < p * q := by intro n hn; omega
  have hsym : ∀ n ≤ F, (repPairs p q n = ∅ ↔ ¬ (repPairs p q (F - n) = ∅)) := by
    intro n hn
    rw [repPairs_eq_empty_iff (by omega), repPairs_eq_empty_iff (by omega),
      not_not]
    constructor
    · intro hnot
      exact frameRep_reflect_of_not hcop hp hq n hnot
    · intro hR hR'
      exact not_frameRep_and_reflect hcop hp hq hn hR' hR
  have hcard : (frameGaps p q).card
      = ((range D).filter (fun n => ¬ (repPairs p q n = ∅))).card := by
    refine Finset.card_bij' (fun n _ => F - n) (fun n _ => F - n) ?_ ?_ ?_ ?_
    · intro a ha
      simp only [frameGaps, Finset.mem_filter, Finset.mem_range] at ha ⊢
      exact ⟨by omega, (hsym a (by omega)).1 ha.2⟩
    · intro a ha
      simp only [frameGaps, Finset.mem_filter, Finset.mem_range] at ha ⊢
      refine ⟨by omega, ?_⟩
      exact (hsym (F - a) (by omega)).2
        (by simpa [show F - (F - a) = a by omega] using ha.2)
    · intro a ha
      simp only [frameGaps, Finset.mem_filter, Finset.mem_range] at ha
      show F - (F - a) = a
      omega
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_range] at ha
      show F - (F - a) = a
      omega
  have hsplit : ((range D).filter (fun n => repPairs p q n = ∅)).card
      + ((range D).filter (fun n => ¬ (repPairs p q n = ∅))).card = D := by
    have h := Finset.card_filter_add_card_filter_not (s := range D)
      (fun n => repPairs p q n = ∅)
    simpa using h
  have : (frameGaps p q).card = ((range D).filter (fun n => repPairs p q n = ∅)).card := rfl
  omega

/-! ## 13. Palindromicity from the Sylvester symmetry -/

/-- **Palindromicity.**  For distinct primes `p ≠ q` the ±-frame `Φ_{pq}` is
self-reciprocal: `coeff k = coeff (D - k)` for `k ≤ D = (p-1)(q-1)`.  The proof is
purely the Sylvester reflection of the balance region fed through the closed
formula. -/
theorem coeff_pmFrame_palindromic {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : p ≠ q)
    {k : ℕ} (hk : k ≤ (p - 1) * (q - 1)) :
    (pmFrame (p * q)).coeff k = (pmFrame (p * q)).coeff ((p - 1) * (q - 1) - k) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 h
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hpq : p + q ≤ p * q := by nlinarith
  set F := p * q - p - q with hF
  set D := (p - 1) * (q - 1) with hD
  have hDF : D = F + 1 := deg_eq_frobenius_succ hp2 hq2
  have hDlt : D < p * q := by omega
  have hzero : (pmFrame (p * q)).coeff 0 = 1 := coeff_pmFrame_zero_eq_one hp hq h
  have htop : (pmFrame (p * q)).coeff D = 1 := coeff_pmFrame_natDegree hcop hp hq
  match k, hk with
  | 0, _ => simpa [hzero] using htop.symm
  | (m + 1), hk =>
    rcases eq_or_lt_of_le hk with heq | hlt
    · rw [← heq] at htop ⊢
      simpa [hzero] using htop
    · have hm : m + 1 ≤ F := by omega
      have hsub : D - (m + 1) = (F - m - 1) + 1 := by omega
      rw [coeff_pmFrame_succ hp hq h (by omega), hsub,
        coeff_pmFrame_succ hp hq h (by omega)]
      have hr1 := coeff_frameGeom_add_reflect hcop hp2 hq2 (n := m) (by omega)
      have hr2 := coeff_frameGeom_add_reflect hcop hp2 hq2 (n := m + 1) (by omega)
      have e1 : F - m - 1 + 1 = F - m := by omega
      have e2 : F - m - 1 = F - (m + 1) := by omega
      rw [e1, e2]
      linarith [hr1, hr2]

/-! ## 14. The coprimality boundary

Adversarial check: the whole argument rests on `repPair_unique`, whose only
input is coprimality of the two steps.  Without it the balance box really does
contain two lattice points on one line and the frame geometry acquires a
coefficient `2`, so the `{-1,0,1}` conclusion genuinely fails.  This pins down
coprimality as the exact boundary of the method. -/

/-- With the non-coprime steps `2` and `4`, the line `2i + 4j = 4` carries **two**
lattice points of the box `[0,4) × [0,2)`. -/
theorem card_repPairs_two_four : (repPairs 2 4 4).card = 2 := by decide

/-- Consequently the frame geometry of `(2,4)` has a coefficient equal to `2`:
the `{-1,0,1}` phenomenon is a strictly coprime one. -/
theorem coeff_frameGeom_two_four : (frameGeom 2 4).coeff 4 = 2 := by
  rw [coeff_frameGeom, card_repPairs_two_four]
  norm_num

end PMFrame