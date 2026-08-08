/-
# The Fibonacci family behind the "six times" phenomenon

Building on `Combinatorics.SingmasterOccurrences`, this file explains *why* infinitely
many numbers occur at least six times in Pascal's triangle.

The mechanism is a bridge between three different pieces of mathematics:

* **Combinatorics.**  A value `C(n,k)` normally occupies four positions —
  `(n,k)`, `(n,n-k)`, `(t,1)`, `(t,t-1)` where `t = C(n,k)`.  Two *extra* positions
  appear exactly when the same number also occurs one row higher, i.e. when
  `C(n,k) = C(n-1,k+1)`.
* **Arithmetic.**  Clearing factorials turns that coincidence into the Diophantine
  equation `n (k+1) = (n-k)(n-k-1)` (`Singmaster.choose_cross`).
* **The Fibonacci recursion.**  That equation is a disguised Pell equation, and
  Cassini's identity `F_{2i+3}^2 = F_{2i+2} F_{2i+4} + 1` produces an infinite family
  of solutions `n = F_{2i+4} F_{2i+5}`, `k = F_{2i+2} F_{2i+5}`.

For `i = 0` this is `n = 15`, `k = 5`, giving `C(15,5) = C(14,6) = 3003`; the next
member is `n = 104`, `k = 39`, giving `C(104,39) = C(103,40)`.

Main results:
* `Singmaster.choose_cross` — the cross-row identity from the Diophantine condition;
* `Singmaster.cassini_odd` — Cassini's identity at odd index, over `ℕ`;
* `Singmaster.fib_cross` — the Fibonacci solutions of the Diophantine condition;
* `Singmaster.six_le_mult_fib` — every member of the family occurs at least six times;
* `Singmaster.infinitely_many_six` — hence there are arbitrarily large such numbers.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences

open Finset

namespace Singmaster

/-! ## The cross-row identity -/

/-- **Cross-row identity.**  Write `N = j + m`.  If `(N+1)(j+2) = m(m-1)` then the entry
`C(N+1, j+1)` repeats one row higher as `C(N, j+2)`.

This is the factorial identity `n(k+1) = (n-k)(n-k-1)` in subtraction-free form
(`n = N+1`, `k = j+1`, `m = n-k`). -/
theorem choose_cross {j m : ℕ} (hm : 2 ≤ m)
    (h : (j + m + 1) * (j + 2) = m * (m - 1)) :
    (j + m + 1).choose (j + 1) = (j + m).choose (j + 2) := by
  set N := j + m with hN
  set A := (N + 1).choose (j + 1) with hA
  set B := N.choose (j + 2) with hB
  set P := N.choose j with hP
  set Q := N.choose (j + 1) with hQ
  have e1 : (N + 1) * P = A * (j + 1) := Nat.add_one_mul_choose_eq N j
  have e2 : Q * (j + 1) = P * m := by
    rw [hQ, hP, Nat.choose_succ_right_eq]
    congr 1
    omega
  have e3 : B * (j + 2) = Q * (m - 1) := by
    rw [hB, hQ, show j + 2 = (j + 1) + 1 from rfl, Nat.choose_succ_right_eq]
    congr 1
    omega
  have key : A * ((j + 1) * (j + 2)) = B * ((j + 1) * (j + 2)) := by
    calc A * ((j + 1) * (j + 2)) = (A * (j + 1)) * (j + 2) := by ring
      _ = ((N + 1) * P) * (j + 2) := by rw [e1]
      _ = P * ((N + 1) * (j + 2)) := by ring
      _ = P * (m * (m - 1)) := by rw [h]
      _ = (P * m) * (m - 1) := by ring
      _ = (Q * (j + 1)) * (m - 1) := by rw [e2]
      _ = (Q * (m - 1)) * (j + 1) := by ring
      _ = (B * (j + 2)) * (j + 1) := by rw [e3]
      _ = B * ((j + 1) * (j + 2)) := by ring
  exact Nat.eq_of_mul_eq_mul_right (by positivity) key

/-! ## Cassini's identity at odd index -/

/-- **Cassini's identity** in the form needed here: `F_{2i+3}^2 = F_{2i+2} F_{2i+4} + 1`.
(The sign `+1` is what makes the odd-index case the useful one.) -/
theorem cassini_odd (i : ℕ) :
    Nat.fib (2 * i + 3) * Nat.fib (2 * i + 3) = Nat.fib (2 * i + 2) * Nat.fib (2 * i + 4) + 1 := by
  induction i with
  | zero => decide
  | succ p ih =>
    have h1 : Nat.fib (2 * p + 4) = Nat.fib (2 * p + 2) + Nat.fib (2 * p + 3) :=
      Nat.fib_add_two (n := 2 * p + 2)
    have h2 : Nat.fib (2 * p + 5) = Nat.fib (2 * p + 3) + Nat.fib (2 * p + 4) :=
      Nat.fib_add_two (n := 2 * p + 3)
    have h3 : Nat.fib (2 * p + 6) = Nat.fib (2 * p + 4) + Nat.fib (2 * p + 5) :=
      Nat.fib_add_two (n := 2 * p + 4)
    have e1 : 2 * (p + 1) + 3 = 2 * p + 5 := by ring
    have e2 : 2 * (p + 1) + 2 = 2 * p + 4 := by ring
    have e3 : 2 * (p + 1) + 4 = 2 * p + 6 := by ring
    rw [e1, e2, e3, h3, h2, h1]
    rw [h1] at ih
    nlinarith [ih]

/-! ## The Fibonacci solutions -/

section Family

variable (i : ℕ)

/-- The row index of the `i`-th member of the family: `F_{2i+4} · F_{2i+5}`
(`15, 104, 714, 4895, …`). -/
def famRow (i : ℕ) : ℕ := Nat.fib (2 * i + 4) * Nat.fib (2 * i + 5)

/-- The column index of the `i`-th member of the family: `F_{2i+2} · F_{2i+5}`
(`5, 39, 272, 1869, …`). -/
def famCol (i : ℕ) : ℕ := Nat.fib (2 * i + 2) * Nat.fib (2 * i + 5)

/-- The `i`-th six-fold value, `C(famRow i, famCol i)` (`3003, …`). -/
def famVal (i : ℕ) : ℕ := (famRow i).choose (famCol i)

theorem fib_two_add_two_pos (i : ℕ) : 1 ≤ Nat.fib (2 * i + 2) := by
  have h := Nat.fib_mono (show (2 : ℕ) ≤ 2 * i + 2 by omega)
  simpa using h

theorem fib_lt_fib_succ_of (i : ℕ) : Nat.fib (2 * i + 2) < Nat.fib (2 * i + 3) := by
  have h : Nat.fib (2 * i + 3) = Nat.fib (2 * i + 1) + Nat.fib (2 * i + 2) :=
    Nat.fib_add_two (n := 2 * i + 1)
  have h1 : 1 ≤ Nat.fib (2 * i + 1) := by
    have h2 := Nat.fib_mono (show (1 : ℕ) ≤ 2 * i + 1 by omega)
    simpa using h2
  omega

theorem five_le_fib (i : ℕ) : 5 ≤ Nat.fib (2 * i + 5) := by
  have h := Nat.fib_mono (show (5 : ℕ) ≤ 2 * i + 5 by omega)
  simpa using h

theorem three_le_fib (i : ℕ) : 3 ≤ Nat.fib (2 * i + 4) := by
  have h := Nat.fib_mono (show (4 : ℕ) ≤ 2 * i + 4 by omega)
  simpa using h

/-- The two Fibonacci products solve the Diophantine condition of `choose_cross`. -/
theorem fib_cross (i : ℕ) :
    famRow i * (famCol i + 1) = (famRow i - famCol i) * (famRow i - famCol i - 1) := by
  set a := Nat.fib (2 * i + 2) with ha
  set b := Nat.fib (2 * i + 3) with hb
  set c := Nat.fib (2 * i + 4) with hc
  set d := Nat.fib (2 * i + 5) with hd
  have hcab : c = a + b := Nat.fib_add_two (n := 2 * i + 2)
  have hdbc : d = b + c := Nat.fib_add_two (n := 2 * i + 3)
  have hcas : b * b = a * c + 1 := cassini_odd i
  have ha1 : 1 ≤ a := fib_two_add_two_pos i
  have hd5 : 5 ≤ d := five_le_fib i
  have hrow : famRow i = c * d := rfl
  have hcol : famCol i = a * d := rfl
  have hsub : famRow i - famCol i = b * d := by
    show c * d - a * d = b * d
    rw [hcab, Nat.add_mul]
    omega
  have hbd : 5 ≤ b * d := by
    have hb2 : 2 ≤ b := by
      have := fib_lt_fib_succ_of i
      omega
    nlinarith
  rw [hsub, hrow, hcol]
  have hstep : c * d * (a * d + 1) + b * d = (b * d) * (b * d) := by
    have expand : (b * d) * (b * d) = (a * c + 1) * (d * d) := by
      rw [← hcas]; ring
    rw [expand, hdbc, hcab]
    ring
  have hmul : (b * d) * (b * d - 1) = (b * d) * (b * d) - b * d := by
    rw [Nat.mul_sub, Nat.mul_one]
  omega

end Family

/-! ## Six occurrences -/

/-- **Every member of the Fibonacci family occurs at least six times.**

The value `t = C(F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5})` sits at the six positions
`(t,1)`, `(t,t-1)`, `(n,k)`, `(n,n-k)`, `(n-1,k+1)`, `(n-1,n-k-2)`
where `n = famRow i` and `k = famCol i`. -/
theorem six_le_mult_fib (i : ℕ) : 6 ≤ mult (famVal i) := by
  classical
  set a := Nat.fib (2 * i + 2) with ha
  set b := Nat.fib (2 * i + 3) with hb
  set c := Nat.fib (2 * i + 4) with hc
  set d := Nat.fib (2 * i + 5) with hd
  have hcab : c = a + b := Nat.fib_add_two (n := 2 * i + 2)
  have ha1 : 1 ≤ a := fib_two_add_two_pos i
  have hab : a < b := fib_lt_fib_succ_of i
  have hd5 : 5 ≤ d := five_le_fib i
  have hc3 : 3 ≤ c := three_le_fib i
  set n := famRow i with hn
  set k := famCol i with hk
  have hrow : n = c * d := rfl
  have hcol : k = a * d := rfl
  have hnk : n - k = b * d := by
    show c * d - a * d = b * d
    rw [hcab, Nat.add_mul]
    omega
  -- basic size estimates
  have hk5 : 5 ≤ k := by rw [hcol]; nlinarith
  have hbd : k + 3 < n - k := by
    rw [hnk, hcol]
    nlinarith
  have hkn : k ≤ n := by omega
  have hn15 : 15 ≤ n := by rw [hrow]; nlinarith
  -- the value and its size
  set t := famVal i with ht
  have htval : t = n.choose k := rfl
  have hn2 : n.choose 2 ≤ t := by rw [htval]; exact choose_two_le_choose (by omega) (by omega)
  have hnt : n < t := by
    have h1 : n * 4 ≤ n * (n - 1) := Nat.mul_le_mul_left n (by omega)
    have h2 : n.choose 2 = n * (n - 1) / 2 := Nat.choose_two_right n
    omega
  have ht3 : 3 ≤ t := by omega
  -- the cross-row repetition
  have hcross : n.choose k = (n - 1).choose (k + 1) := by
    obtain ⟨j, hj⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    have hjm : j + (n - k) + 1 = n := by omega
    have hjm' : j + (n - k) = n - 1 := by omega
    have hdio : (j + (n - k) + 1) * (j + 2) = (n - k) * ((n - k) - 1) := by
      have hfc := fib_cross i
      rw [← hn, ← hk] at hfc
      rw [hjm, show j + 2 = k + 1 by omega]
      exact hfc
    have := choose_cross (j := j) (m := n - k) (by omega) hdio
    rw [hjm, hjm'] at this
    rw [hj]
    exact this
  -- the six positions
  have m1 : (t, 1) ∈ occ t := mem_occ (by omega) (by omega) (Nat.choose_one_right t)
  have m2 : (t, t - 1) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have h := Nat.choose_symm (n := t) (k := 1) (by omega)
    rw [Nat.choose_one_right] at h
    exact h
  have m3 : (n, k) ∈ occ t := mem_occ (by omega) (by omega) htval.symm
  have m4 : (n, n - k) ∈ occ t :=
    mem_occ (by omega) (by omega) (by rw [Nat.choose_symm hkn]; exact htval.symm)
  have m5 : (n - 1, k + 1) ∈ occ t :=
    mem_occ (by omega) (by omega) (by rw [← hcross]; exact htval.symm)
  have m6 : (n - 1, n - k - 2) ∈ occ t := by
    refine mem_occ (by omega) (by omega) ?_
    have hs : (n - 1).choose (n - 1 - (k + 1)) = (n - 1).choose (k + 1) :=
      Nat.choose_symm (by omega)
    rw [show n - k - 2 = n - 1 - (k + 1) by omega, hs, ← hcross]
    exact htval.symm
  have hsub : ({(t, 1), (t, t - 1), (n, k), (n, n - k), (n - 1, k + 1), (n - 1, n - k - 2)} :
      Finset (ℕ × ℕ)) ⊆ occ t := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨m1, m2, m3, m4, m5, m6⟩
  have hcard : ({(t, 1), (t, t - 1), (n, k), (n, n - k), (n - 1, k + 1), (n - 1, n - k - 2)} :
      Finset (ℕ × ℕ)).card = 6 := by
    rw [Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_insert, mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_insert_of_notMem (by
        simp only [mem_singleton, Prod.mk.injEq]; omega),
      Finset.card_singleton]
  calc 6 = _ := hcard.symm
    _ ≤ mult t := card_le_card hsub

/-- **Infinitely many numbers occur at least six times in Pascal's triangle.** -/
theorem infinitely_many_six (M : ℕ) : ∃ t : ℕ, M < t ∧ 6 ≤ mult t := by
  refine ⟨famVal M, ?_, six_le_mult_fib M⟩
  have hd : 2 * M + 5 ≤ Nat.fib (2 * M + 5) := Nat.le_fib_self (by omega)
  have hd5 : 5 ≤ Nat.fib (2 * M + 5) := five_le_fib M
  have hc3 : 3 ≤ Nat.fib (2 * M + 4) := three_le_fib M
  have hrow : famRow M = Nat.fib (2 * M + 4) * Nat.fib (2 * M + 5) := rfl
  have hM : M < famRow M := by rw [hrow]; nlinarith
  have hcol : famCol M = Nat.fib (2 * M + 2) * Nat.fib (2 * M + 5) := rfl
  have ha1 : 1 ≤ Nat.fib (2 * M + 2) := fib_two_add_two_pos M
  have hab : Nat.fib (2 * M + 2) < Nat.fib (2 * M + 3) := fib_lt_fib_succ_of M
  have hcab : Nat.fib (2 * M + 4) = Nat.fib (2 * M + 2) + Nat.fib (2 * M + 3) :=
    Nat.fib_add_two (n := 2 * M + 2)
  have hk2 : 2 ≤ famCol M := by rw [hcol]; nlinarith
  have hb2 : 2 ≤ Nat.fib (2 * M + 3) := by omega
  have hk2n : famCol M + 2 ≤ famRow M := by
    rw [hcol, hrow, hcab]
    nlinarith
  have hval : famVal M = (famRow M).choose (famCol M) := rfl
  have hn2 : (famRow M).choose 2 ≤ famVal M := by
    rw [hval]; exact choose_two_le_choose hk2 hk2n
  have hrow15 : 15 ≤ famRow M := by rw [hrow]; nlinarith
  have h1 : famRow M * 4 ≤ famRow M * (famRow M - 1) :=
    Nat.mul_le_mul_left _ (by omega)
  have h2 : (famRow M).choose 2 = famRow M * (famRow M - 1) / 2 := Nat.choose_two_right _
  omega

end Singmaster