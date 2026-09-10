/-
# Classification of the row-shift coincidences (sub-conjecture D3, closed)

`Catalog/NumberTheory/SingmasterFibonacciSix.lean` shows that every solution of the
row-shift equation

`N * (k + 1) = (N - k) * (N - k - 1)`      (equivalently `C(N,k) = C(N-1,k+1)`)

produces an integer occurring at least six times in Pascal's triangle, and that the
even-index Fibonacci pairs are exactly the solutions of the Cassini relation
`b² = ab + a² + 1`.  What was left open there (direction **D3** of
`FUTURE_DIRECTIONS.md`) is the converse for the row-shift equation *itself*: are the
Fibonacci solutions the only ones?

This file answers that affirmatively, with an unconditional proof.

* `Singmaster.rowShift_sub_iff_poly` — removes the truncated subtraction: for
  `k + 2 ≤ N` the row-shift equation is the Diophantine equation
  `k² + k + N² = 3Nk + 2N`.
* `Singmaster.rowShift_vieta_row`, `Singmaster.rowShift_vieta_col` — the two Vieta
  involutions of that quadratic: `N ↦ 3k + 2 - N` (fixing the column) and
  `k ↦ 3N - 1 - k` (fixing the row).
* `Singmaster.rowShift_classification` — a **descent** alternating the two
  involutions: every solution with `2k ≤ N` and `N ≥ 1` is
  `N = F(2i+2)F(2i+3)`, `k = F(2i)F(2i+3)`.  The step down is
  `(N, k) ↦ (3k + 2 - N, k) ↦ (3k + 2 - N, 3(3k + 2 - N) - 1 - k)`, and the two
  Fibonacci identities that make the ascent work are both instances of the even Cassini
  identity `fib_cassini_even`.
* `Singmaster.rowShift_iff` — the resulting *if and only if*: for `2 ≤ k` and
  `2k ≤ N`,
  `N(k+1) = (N-k)(N-k-1) ↔ ∃ i ≥ 1, N = fibRow i ∧ k = fibCol i`.
* `Singmaster.rowShift_discriminant` — the Pell shadow of the classification: a
  row-shift solution forces `5N² + 2N + 1` to be a perfect square, namely
  `(3N - 1 - 2k)²`.
* `Singmaster.six_le_mult_of_rowShift_fib` — consequence for multiplicities: the
  six-fold coincidences obtainable from a one-row shift are *exactly* the Fibonacci
  ones, so no further infinite family can be extracted from this mechanism.
-/
import NumberTheory.SingmasterFibonacciSix

namespace Singmaster

/-! ## From truncated subtraction to a Diophantine equation -/

/-- For `k + 2 ≤ N` the row-shift equation is the quadratic Diophantine equation
`k² + k + N² = 3Nk + 2N`. -/
theorem rowShift_sub_iff_poly {N k : ℕ} (h : k + 2 ≤ N) :
    N * (k + 1) = (N - k) * (N - k - 1) ↔ k * k + k + N * N = 3 * N * k + 2 * N := by
  obtain ⟨m, rfl⟩ : ∃ m, N = k + m + 2 := ⟨N - k - 2, by omega⟩
  rw [show k + m + 2 - k - 1 = m + 1 from by omega, show k + m + 2 - k = m + 2 from by omega]
  constructor <;> intro h <;> nlinarith [h]

/-! ## The two Vieta involutions -/

/-- **Vieta in the row.**  For fixed `k`, the equation is a monic quadratic in `N` with
root sum `3k + 2` and root product `k(k+1)`; so the conjugate root `M` of a solution `N`
is again a solution. -/
theorem rowShift_vieta_row {N k M : ℕ} (hsum : N + M = 3 * k + 2)
    (heq : k * k + k + N * N = 3 * N * k + 2 * N) :
    N * M = k * k + k ∧ k * k + k + M * M = 3 * M * k + 2 * M := by
  have h1 : N * (N + M) = N * (3 * k + 2) := by rw [hsum]
  have hprod : N * M = k * k + k := by nlinarith [h1, heq]
  refine ⟨hprod, ?_⟩
  have h2 : M * (N + M) = M * (3 * k + 2) := by rw [hsum]
  nlinarith [h2, hprod]

/-- **Vieta in the column.**  For fixed `N ≥ 2`, the equation is a monic quadratic in `k`
with root sum `3N - 1` and root product `N(N-2)`; so the conjugate root `j` of a solution
`k` is again a solution. -/
theorem rowShift_vieta_col {N k j : ℕ} (hsum : k + j + 1 = 3 * N)
    (heq : k * k + k + N * N = 3 * N * k + 2 * N) :
    k * j + 2 * N = N * N ∧ j * j + j + N * N = 3 * N * j + 2 * N := by
  have h1 : k * (k + j + 1) = k * (3 * N) := by rw [hsum]
  have hprod : k * j + 2 * N = N * N := by nlinarith [h1, heq]
  refine ⟨hprod, ?_⟩
  have h2 : j * (k + j + 1) = j * (3 * N) := by rw [hsum]
  nlinarith [h2, hprod]

/-! ## The descent -/

/-- Bookkeeping for one descent step: from a solution `(N,k)` with `1 ≤ k` and `2k ≤ N`
the row-conjugate `M = 3k + 2 - N` satisfies `2 ≤ M`, `M < N` and `2M ≤ k + 1`. -/
theorem rowShift_descent_row {N k M : ℕ} (hk : 1 ≤ k) (hkN : 2 * k ≤ N)
    (hsum : N + M = 3 * k + 2) (hprod : N * M = k * k + k) :
    2 ≤ M ∧ M < N ∧ 2 * M ≤ k + 1 := by
  have hN2 : 2 ≤ N := by omega
  have hM1 : 1 ≤ M := by
    rcases Nat.eq_zero_or_pos M with rfl | h
    · simp at hprod; nlinarith
    · exact h
  have hMle : 2 * M ≤ k + 1 := by nlinarith
  have hM2 : 2 ≤ M := by
    rcases Nat.lt_or_ge M 2 with h | h
    · exfalso
      have hM : M = 1 := by omega
      subst hM
      -- `N = 3k + 1` and `N = k² + k`, i.e. `k² = 2k + 1`, which has no solution in ℕ
      have hNval : N = k * k + k := by omega
      have hkk : k * k = 2 * k + 1 := by omega
      rcases Nat.lt_or_ge k 3 with hk3 | hk3
      · interval_cases k <;> omega
      · nlinarith
    · exact h
  exact ⟨hM2, by omega, hMle⟩

/-- Bookkeeping for the second half of a descent step: from a solution `(M,k)` with
`2 ≤ M` and `2M ≤ k + 1` the column-conjugate `j` satisfies `k + j + 1 = 3M` and
`2j ≤ M`. -/
theorem rowShift_descent_col {M k : ℕ} (hM : 2 ≤ M) (hMk : 2 * M ≤ k + 1)
    (heq : k * k + k + M * M = 3 * M * k + 2 * M) :
    ∃ j, k + j + 1 = 3 * M ∧ 2 * j ≤ M ∧ j * j + j + M * M = 3 * M * j + 2 * M := by
  have hk : 1 ≤ k := by omega
  have hkle : k + 1 ≤ 3 * M := by nlinarith
  refine ⟨3 * M - 1 - k, by omega, ?_, ?_⟩
  · obtain ⟨hprod, -⟩ := rowShift_vieta_col (N := M) (k := k) (j := 3 * M - 1 - k)
      (by omega) heq
    nlinarith [hprod]
  · exact (rowShift_vieta_col (N := M) (k := k) (j := 3 * M - 1 - k) (by omega) heq).2

/-- **Ascent step.**  If the smaller solution `(M, j)` is the Cassini pair `(a,b)`, i.e.
`M = (a+b)(a+2b)` and `j = a(a+2b)`, then the solution `(N,k)` it was obtained from is the
next one, `N = (2a+3b)(3a+5b)` and `k = (a+b)(3a+5b)`.  Both identities are consequences
of the Cassini relation alone. -/
theorem rowShift_ascent {M j N k a b : ℕ} (hcass : b * b = a * b + a * a + 1)
    (hM : M = (a + b) * (a + 2 * b)) (hj : j = a * (a + 2 * b))
    (hjsum : k + j + 1 = 3 * M) (hsum : N + M = 3 * k + 2) :
    N = (2 * a + 3 * b) * (3 * a + 5 * b) ∧ k = (a + b) * (3 * a + 5 * b) := by
  have hk : k = (a + b) * (3 * a + 5 * b) := by
    have hid : (a + b) * (3 * a + 5 * b) + a * (a + 2 * b) + 1 = 3 * ((a + b) * (a + 2 * b)) :=
      by linarith [hcass]
    rw [hM] at hjsum; rw [hj] at hjsum
    linarith [hjsum, hid]
  refine ⟨?_, hk⟩
  have hid2 : (2 * a + 3 * b) * (3 * a + 5 * b) + (a + b) * (a + 2 * b)
      = 3 * ((a + b) * (3 * a + 5 * b)) + 2 := by linarith [hcass]
  rw [hM] at hsum; rw [hk] at hsum
  linarith [hsum, hid2]

/-- **Classification of row-shift solutions.**  Every solution of
`k² + k + N² = 3Nk + 2N` with `1 ≤ N` and `2k ≤ N` is the `i`-th Fibonacci solution
`N = F(2i+2)F(2i+3)`, `k = F(2i)F(2i+3)`.  Proved by a Vieta descent alternating the two
involutions of the quadratic; the ascent step is the even Cassini identity. -/
theorem rowShift_classification :
    ∀ N k : ℕ, 1 ≤ N → 2 * k ≤ N → k * k + k + N * N = 3 * N * k + 2 * N →
      ∃ i, N = Nat.fib (2 * i + 2) * Nat.fib (2 * i + 3) ∧
        k = Nat.fib (2 * i) * Nat.fib (2 * i + 3) := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro k hN hkN heq
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · -- base case: `N² = 2N`, so `N = 2 = F(2)·F(3)`
      have hN2 : N = 2 := by
        have : N * N = 2 * N := by omega
        rcases Nat.lt_or_ge N 3 with h | h
        · interval_cases N <;> omega
        · nlinarith
      exact ⟨0, by norm_num [hN2], by norm_num⟩
    · -- descent step
      have hNle : N ≤ 3 * k + 2 := by nlinarith
      obtain ⟨M, hsum⟩ : ∃ M, N + M = 3 * k + 2 := ⟨3 * k + 2 - N, by omega⟩
      obtain ⟨hprod, heqM⟩ := rowShift_vieta_row hsum heq
      obtain ⟨hM2, hMN, hMk⟩ := rowShift_descent_row hk hkN hsum hprod
      obtain ⟨j, hjsum, hjle, heqj⟩ := rowShift_descent_col hM2 hMk heqM
      obtain ⟨i, hMi, hji⟩ := ih M hMN j (by omega) hjle heqj
      -- ascent: `(M, j)` is the `i`-th solution, hence `(N, k)` is the `(i+1)`-st
      have h2 : Nat.fib (2 * i + 2) = Nat.fib (2 * i) + Nat.fib (2 * i + 1) := fib_two_add
      have h3 : Nat.fib (2 * i + 3) = Nat.fib (2 * i) + 2 * Nat.fib (2 * i + 1) := fib_three_add
      have h4 : Nat.fib (2 * i + 4) = 2 * Nat.fib (2 * i) + 3 * Nat.fib (2 * i + 1) := by
        have h : Nat.fib (2 * i + 4) = Nat.fib (2 * i + 2) + Nat.fib (2 * i + 3) := by
          rw [show 2 * i + 4 = (2 * i + 2) + 2 from by ring, Nat.fib_add_two,
            show 2 * i + 2 + 1 = 2 * i + 3 from by ring]
        rw [h, h2, h3]; ring
      have h5 : Nat.fib (2 * i + 5) = 3 * Nat.fib (2 * i) + 5 * Nat.fib (2 * i + 1) := by
        have h : Nat.fib (2 * i + 5) = Nat.fib (2 * i + 3) + Nat.fib (2 * i + 4) := by
          rw [show 2 * i + 5 = (2 * i + 3) + 2 from by ring, Nat.fib_add_two,
            show 2 * i + 3 + 1 = 2 * i + 4 from by ring]
        rw [h, h3, h4]; ring
      obtain ⟨hNval, hkval⟩ := rowShift_ascent (a := Nat.fib (2 * i)) (b := Nat.fib (2 * i + 1))
        (fib_cassini_even i) (by rw [hMi, h2, h3]) (by rw [hji, h3]) hjsum hsum
      exact ⟨i + 1, by rw [show 2 * (i + 1) + 2 = 2 * i + 4 from by ring,
          show 2 * (i + 1) + 3 = 2 * i + 5 from by ring, h4, h5, hNval],
        by rw [show 2 * (i + 1) + 3 = 2 * i + 5 from by ring,
          show 2 * (i + 1) = 2 * i + 2 from by ring, h2, h5, hkval]⟩

/-! ## The classification in row-shift form -/

/-- The Fibonacci solutions do satisfy the Diophantine row-shift equation. -/
theorem rowShift_poly_fib (i : ℕ) :
    fibCol i * fibCol i + fibCol i + fibRow i * fibRow i
      = 3 * fibRow i * fibCol i + 2 * fibRow i := by
  have hcass : Nat.fib (2 * i + 1) * Nat.fib (2 * i + 1)
      = Nat.fib (2 * i) * Nat.fib (2 * i + 1) + Nat.fib (2 * i) * Nat.fib (2 * i) + 1 :=
    fib_cassini_even i
  simp only [fibRow, fibCol, fib_two_add, fib_three_add]
  nlinarith [hcass]

theorem fibCol_le_fibRow (i : ℕ) : 2 * fibCol i ≤ fibRow i := by
  have h : Nat.fib (2 * i) ≤ Nat.fib (2 * i + 1) := Nat.fib_mono (by omega)
  simp only [fibRow, fibCol, fib_two_add]
  nlinarith [h, Nat.fib_pos.mpr (show 0 < 2 * i + 3 from by omega)]

theorem two_le_fibCol {i : ℕ} (hi : 1 ≤ i) : 2 ≤ fibCol i := by
  have h1 : 1 ≤ Nat.fib (2 * i) := one_le_fib_even hi
  have h2 : 2 ≤ Nat.fib (2 * i + 3) := by
    have : Nat.fib 3 ≤ Nat.fib (2 * i + 3) := Nat.fib_mono (by omega)
    simpa using this
  simp only [fibCol]
  nlinarith

theorem fibCol_add_two_le_fibRow (i : ℕ) : fibCol i + 2 ≤ fibRow i := by
  have h1 : 1 ≤ Nat.fib (2 * i + 1) := by
    have : Nat.fib 1 ≤ Nat.fib (2 * i + 1) := Nat.fib_mono (by omega)
    simpa using this
  have h2 : 2 ≤ Nat.fib (2 * i + 3) := by
    have : Nat.fib 3 ≤ Nat.fib (2 * i + 3) := Nat.fib_mono (by omega)
    simpa using this
  simp only [fibRow, fibCol, fib_two_add]
  nlinarith

/-- **The row-shift equation is exactly the Fibonacci ladder.**  For `2 ≤ k` and
`2k ≤ N`, the coincidence `C(N,k) = C(N-1,k+1)` holds if and only if
`N = F(2i+2)F(2i+3)` and `k = F(2i)F(2i+3)` for some `i ≥ 1`.  The first instance is
`(N,k) = (15,5)`, giving `3003`. -/
theorem rowShift_iff {N k : ℕ} (hk : 2 ≤ k) (hkN : 2 * k ≤ N) :
    N * (k + 1) = (N - k) * (N - k - 1) ↔ ∃ i, 1 ≤ i ∧ N = fibRow i ∧ k = fibCol i := by
  rw [rowShift_sub_iff_poly (by omega)]
  constructor
  · intro heq
    obtain ⟨i, hN, hkv⟩ := rowShift_classification N k (by omega) hkN heq
    refine ⟨i, ?_, hN, hkv⟩
    rcases Nat.eq_zero_or_pos i with rfl | hi
    · exfalso; simp at hkv; omega
    · exact hi
  · rintro ⟨i, -, rfl, rfl⟩
    exact rowShift_poly_fib i

/-! ## Consequences -/

/-- **Pell shadow.**  A row-shift solution forces the discriminant `5N² + 2N + 1` to be a
perfect square — this is the Pell equation `x² - 5y² = -4` in disguise (`x = 5N + 1`). -/
theorem rowShift_discriminant {N k : ℕ} (hk : 2 ≤ k) (hkN : 2 * k ≤ N)
    (h : N * (k + 1) = (N - k) * (N - k - 1)) :
    (3 * N - 1 - 2 * k) * (3 * N - 1 - 2 * k) = 5 * (N * N) + 2 * N + 1 := by
  rw [rowShift_sub_iff_poly (by omega)] at h
  have hle : 2 * k + 1 ≤ 3 * N := by nlinarith
  obtain ⟨d, hd⟩ : ∃ d, 3 * N - 1 - 2 * k = d := ⟨_, rfl⟩
  have hd' : d + 2 * k + 1 = 3 * N := by omega
  rw [hd]
  nlinarith [hd', h]

/-- **No new infinite families from a one-row shift.**  Combining the classification with
`six_le_mult_of_shift_eq`: a row-shift coincidence at `(N,k)` with `2 ≤ k`, `2k ≤ N` gives
multiplicity at least six, and the value is necessarily a Fibonacci one, `C(N,k) = fibVal i`
with `i ≥ 1`. -/
theorem six_le_mult_of_rowShift_fib {N k : ℕ} (hk : 2 ≤ k) (hkN : 2 * k ≤ N)
    (h : N * (k + 1) = (N - k) * (N - k - 1)) :
    ∃ i, 1 ≤ i ∧ N.choose k = fibVal i ∧ 6 ≤ mult (N.choose k) := by
  obtain ⟨i, hi, rfl, rfl⟩ := (rowShift_iff hk hkN).mp h
  exact ⟨i, hi, rfl, six_le_mult_fib hi⟩

end Singmaster