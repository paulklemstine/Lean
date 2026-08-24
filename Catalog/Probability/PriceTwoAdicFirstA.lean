import Probability.PriceTwoAdicMechanism

/-!
# The Price tree: exact position of the first `A`, and the leading run lengths

This file packages the two run laws of `Probability/PriceTwoAdicMechanism.lean` into the
exact statement of the *first-`A` law* announced by the 2-adic mechanism:

> every Price step halves exactly one of `U = p + q` or `V = q - p`; the letter `A` halves
> `V` and is admissible iff `v₂(U) = 1`, while `B`/`C` halve `U` and are admissible iff
> `v₂(U) ≥ 2`.  Hence a non-`A` step decrements `v₂(U)` by one, and the first `A` of the
> address (counted from the leaf) sits at position `v₂(U) - 1`.

In Euclid coordinates `(m, n)` with `p = m - n`, `q = m + n` one has `U = p + q = 2m` and
`V = q - p = 2n`, so `v₂(U) - 1 = v₂(m)` and `v₂(V) - 1 = v₂(n)`.  The two laws proved here
are:

* `first_A_of_odd_snd` — if `n` is odd (equivalently `V ≡ 2 mod 4`) and `v₂(m) = k`, then
  positions `0, …, k-1` are all non-`A` and position `k` is `A`;
* `A_run_of_even_snd` — if `n` is even and `v₂(n) = k`, then positions `0, …, k-1` are all
  `A` and position `k` is non-`A`.

Together they say that the *leading run* of a Price address is `A^{v₂(n)}` when `n` is even
and `(non-A)^{v₂(m)}` when `n` is odd, exactly one of the two being nonempty since a valid
Euclid pair has `m`, `n` of opposite parity.  `first_A_position_eq_v2` restates the first
law with `v₂` written as `Nat.factorization`, and `first_A_at_v2_U_sub_one` restates it in
the odd-pair coordinates `U = p + q` used by the mechanism.

## Lab notes (round 71, exp 552)

Exhaustive check over all valid Euclid pairs with `m < 400`: the position of the first `A`
of the address equals `v₂(m)` for every pair with `n` odd (0 exceptions), and the length of
the leading `A`-block equals `v₂(n)` for every pair with `n` even (0 exceptions).
-/

namespace Price2Adic

/-! ## The non-`A` run: the first `A` sits at position `v₂(m)` -/

/-- **First-`A` law.**  For a node with `n` odd and `m` even, if `v₂(m) = k` then the
letters at positions `0, …, k-1` (counted from the leaf) are all different from `A`, and
the letter at position `k` is `A`. -/
theorem first_A_of_odd_snd (m n k : ℕ) (hn : n % 2 = 1) (hpos : 0 < n) (hlt : n < m)
    (hm : m % 2 = 0) (hk : 2 ^ k ∣ m) (hk' : ¬ 2 ^ (k + 1) ∣ m) :
    letterAt (m, n) k = .A ∧ ∀ t < k, letterAt (m, n) t ≠ .A := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := by
    cases k with
    | zero => exact absurd (by simpa using (by omega : (2 : ℕ) ∣ m)) hk'
    | succ j => exact ⟨j, rfl⟩
  refine ⟨((letterAt_odd_run j m n hn hpos hlt hk).2 (by simpa using hk')), ?_⟩
  intro t ht
  have hdvd : 2 ^ (t + 1) ∣ m := dvd_trans (pow_dvd_pow 2 (by omega)) hk
  exact (letterAt_odd_run t m n hn hpos hlt hdvd).1

/-- **First-`A` law, `v₂` form.**  For a node with `n` odd and `m` even the first `A` of
the address sits exactly at position `m.factorization 2 = v₂(m)`. -/
theorem first_A_position_eq_v2 (m n : ℕ) (hn : n % 2 = 1) (hpos : 0 < n) (hlt : n < m)
    (hm : m % 2 = 0) :
    letterAt (m, n) (m.factorization 2) = .A ∧
      ∀ t < m.factorization 2, letterAt (m, n) t ≠ .A := by
  have hm0 : m ≠ 0 := by omega
  have hp : Nat.Prime 2 := Nat.prime_two
  have hk : 2 ^ (m.factorization 2) ∣ m :=
    (Nat.Prime.pow_dvd_iff_le_factorization hp hm0).mpr le_rfl
  have hk' : ¬ 2 ^ (m.factorization 2 + 1) ∣ m := by
    intro hc
    have := (Nat.Prime.pow_dvd_iff_le_factorization hp hm0).mp hc
    omega
  exact first_A_of_odd_snd m n _ hn hpos hlt hm hk hk'

/-- **First-`A` law in the odd-pair coordinates.**  With `U = p + q = 2m` the first `A`
lands at position `u₀ - 1`, where `u₀ = v₂(U)`. -/
theorem first_A_at_v2_U_sub_one (m n u : ℕ) (hn : n % 2 = 1) (hpos : 0 < n) (hlt : n < m)
    (hm : m % 2 = 0) (hu : 2 ≤ u)
    (hU : 2 ^ u ∣ ((m + n) + (m - n))) (hU' : ¬ 2 ^ (u + 1) ∣ ((m + n) + (m - n))) :
    letterAt (m, n) (u - 1) = .A ∧ ∀ t < u - 1, letterAt (m, n) t ≠ .A := by
  have hsum : (m + n) + (m - n) = 2 * m := by omega
  rw [hsum] at hU hU'
  obtain ⟨j, rfl⟩ : ∃ j, u = j + 1 := ⟨u - 1, by omega⟩
  have hk : 2 ^ j ∣ m := by
    obtain ⟨c, hc⟩ := hU
    refine ⟨c, ?_⟩
    have h2 : 2 * (2 ^ j * c) = 2 * m := by
      calc 2 * (2 ^ j * c) = 2 ^ (j + 1) * c := by ring
        _ = 2 * m := hc.symm
    omega
  have hk' : ¬ 2 ^ (j + 1) ∣ m := by
    rintro ⟨c, hc⟩
    refine hU' ⟨c, ?_⟩
    calc 2 * m = 2 * (2 ^ (j + 1) * c) := by rw [hc]
      _ = 2 ^ (j + 1 + 1) * c := by ring
  have := first_A_of_odd_snd m n j hn hpos hlt hm hk hk'
  simpa using this

/-! ## The `A` run: its length is exactly `v₂(n)` -/

/-- **`A`-run law.**  For a node with `n` even, if `v₂(n) = k` then the letters at
positions `0, …, k-1` are all `A` and the letter at position `k` is not `A`: the leading
`A`-block of the address has length exactly `v₂(n)`. -/
theorem A_run_of_even_snd (m n k : ℕ) (hmn : n ≤ m) (hk : 2 ^ k ∣ n)
    (hk' : ¬ 2 ^ (k + 1) ∣ n) :
    letterAt (m, n) k ≠ .A ∧ ∀ t < k, letterAt (m, n) t = .A := by
  refine ⟨fun hc => hk' ((letterAt_even_iff m n k hmn hk).mp hc), ?_⟩
  intro t ht
  have hdvd : 2 ^ t ∣ n := dvd_trans (pow_dvd_pow 2 (by omega)) hk
  have hdvd' : 2 ^ (t + 1) ∣ n := dvd_trans (pow_dvd_pow 2 (by omega)) hk
  exact (letterAt_even_iff m n t hmn hdvd).mpr hdvd'

/-- **`A`-run law, `v₂` form.**  For a node with `n` even and positive the leading
`A`-block of the address has length exactly `n.factorization 2 = v₂(n)`. -/
theorem A_run_length_eq_v2 (m n : ℕ) (hpos : 0 < n) (hmn : n ≤ m) :
    letterAt (m, n) (n.factorization 2) ≠ .A ∧
      ∀ t < n.factorization 2, letterAt (m, n) t = .A := by
  have hn0 : n ≠ 0 := by omega
  have hp : Nat.Prime 2 := Nat.prime_two
  have hk : 2 ^ (n.factorization 2) ∣ n :=
    (Nat.Prime.pow_dvd_iff_le_factorization hp hn0).mpr le_rfl
  have hk' : ¬ 2 ^ (n.factorization 2 + 1) ∣ n := by
    intro hc
    have := (Nat.Prime.pow_dvd_iff_le_factorization hp hn0).mp hc
    omega
  exact A_run_of_even_snd m n _ hmn hk hk'

/-- **The leading run of a Price address.**  For any valid node exactly one of the two
alternatives holds: `n` is even and the address ends (reading from the leaf) with a block
of exactly `v₂(n)` letters `A` followed by a non-`A`; or `n` is odd and it ends with a block
of exactly `v₂(m)` non-`A` letters followed by an `A`. -/
theorem leading_run_dichotomy (m n : ℕ) (hv : Valid (m, n)) :
    (n % 2 = 0 ∧ letterAt (m, n) (n.factorization 2) ≠ .A ∧
        ∀ t < n.factorization 2, letterAt (m, n) t = .A) ∨
    (n % 2 = 1 ∧ letterAt (m, n) (m.factorization 2) = .A ∧
        ∀ t < m.factorization 2, letterAt (m, n) t ≠ .A) := by
  obtain ⟨hn0, hlt, -, hpar⟩ := hv
  rcases Nat.even_or_odd n with he | ho
  · have hne : n % 2 = 0 := Nat.even_iff.mp he
    exact Or.inl ⟨hne, A_run_length_eq_v2 m n hn0 (le_of_lt hlt)⟩
  · have hno : n % 2 = 1 := Nat.odd_iff.mp ho
    have hm : m % 2 = 0 := by omega
    exact Or.inr ⟨hno, first_A_position_eq_v2 m n hno hn0 hlt hm⟩

end Price2Adic