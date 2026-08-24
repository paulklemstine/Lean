import Cryptography.Price2Adic.Letters

/-!
# The trailing `A`-run is a 2-adic valuation

`Letters.lean` showed that `N mod 4` and `N mod 8` read the last two letters of a Price
address and that no 2-adic residue reads more.  This file identifies what the *whole*
2-adic filtration does read: the length of the terminal block of `A`'s.

* `trailingA_eq_padicValNat` — for every Price word `w`, the number of trailing `A`'s of
  `w` equals `v₂(n)`, the 2-adic valuation of the smaller Euclid parameter of the node
  `eval w`.  The halving alphabet is literally a 2-adic valuation counter.
* `trailingA_address` — the same statement read off a node.
* `trailingA_from_triple` — the triple-level form: the trailing `A`-run of the address of
  a node with triple `(a, b, c)` is `v₂(b) - 1` when `a ≡ 1 (mod 4)`, and `0` when
  `a ≡ 3 (mod 4)`.  Everything is observable from the triple, with no reference to the
  Euclid parameters.

Combined with `twoAdic_blind_BC`, this is the exact 2-adic content of a Price address:
the terminal `A`-run, and nothing else.

## Lab notes (round 70, exp 548)

BFS to depth `8`: for all `9841` nodes the trailing-`A` count matched `v₂(n)` and
matched `v₂(b) - 1` whenever the odd leg was `1 mod 4` (`0` otherwise), with no
exceptions.  Root case: address `[]`, `n = 1`, `v₂ = 0`.
-/

namespace Price2Adic

/-- The number of trailing `A`'s of a Price word. -/
def trailingA (w : PriceWord) : ℕ :=
  (w.reverse.takeWhile (fun l => decide (l = .A))).length

@[simp] theorem trailingA_nil : trailingA [] = 0 := rfl

@[simp] theorem trailingA_append_A (w : PriceWord) :
    trailingA (w ++ [.A]) = trailingA w + 1 := by
  simp [trailingA]

@[simp] theorem trailingA_append_B (w : PriceWord) : trailingA (w ++ [.B]) = 0 := by
  simp [trailingA]

@[simp] theorem trailingA_append_C (w : PriceWord) : trailingA (w ++ [.C]) = 0 := by
  simp [trailingA]

theorem padicValNat_two_mul (n : ℕ) (hn : 0 < n) :
    padicValNat 2 (2 * n) = padicValNat 2 n + 1 := by
  rw [padicValNat.mul (by norm_num) (by omega), padicValNat.self (by norm_num)]
  omega

theorem padicValNat_odd {n : ℕ} (hn : n % 2 = 1) : padicValNat 2 n = 0 :=
  padicValNat.eq_zero_of_not_dvd (by omega)

/-- One Price move raises `v₂(n)` by one (letter `A`) or resets it to zero (`B`, `C`). -/
theorem padicValNat_step (l : PriceLetter) (p : ℕ × ℕ) (hp : Valid p) :
    padicValNat 2 (step l p).2 = if l = .A then padicValNat 2 p.2 + 1 else 0 := by
  obtain ⟨m, n⟩ := p
  obtain ⟨hn, hlt, -, hpar⟩ := hp
  cases l
  · simpa only [step, if_pos rfl] using padicValNat_two_mul n hn
  · simpa only [step, reduceIte] using padicValNat_odd (n := m - n) (by omega)
  · simpa only [step, reduceIte] using padicValNat_odd (n := m + n) (by omega)

/-- **The `A`-run law.**  The trailing `A`-run of a Price address is exactly the 2-adic
valuation of the smaller Euclid parameter of the node it addresses. -/
theorem trailingA_eq_padicValNat (w : PriceWord) :
    trailingA w = padicValNat 2 (eval w).2 := by
  induction w using List.reverseRecOn with
  | nil => simp [eval, root]
  | append_singleton t l ih =>
    have hstep := padicValNat_step l (eval t) (Valid_eval t)
    rw [eval_append_one]
    cases l
    · rw [trailingA_append_A, ih, hstep, if_pos rfl]
    · rw [trailingA_append_B, hstep]; simp
    · rw [trailingA_append_C, hstep]; simp

/-- Node form of the `A`-run law. -/
theorem trailingA_address (p : ℕ × ℕ) (hp : Valid p) :
    trailingA (address p) = padicValNat 2 p.2 := by
  have h := trailingA_eq_padicValNat (address p)
  rwa [eval_address p hp] at h

/-- **Triple-level `A`-run law.**  For a node with triple `(a, b, c)`, the trailing
`A`-run of its Price address is `v₂(b) - 1` when `a ≡ 1 (mod 4)` and `0` when
`a ≡ 3 (mod 4)`: the run is read off the even leg alone, with the mod-4 class of the odd
leg deciding whether the reading applies. -/
theorem trailingA_from_triple (p : ℕ × ℕ) (hp : Valid p) :
    trailingA (address p) =
      (if oddLeg p % 4 = 1 then padicValNat 2 (triple p).2.1 - 1 else 0) := by
  have hrun := trailingA_address p hp
  have hA := letterOf_eq_A_iff_oddLeg p hp
  have hA' := letterOf_eq_A_iff p
  obtain ⟨hn, hlt, hg, hpar⟩ := hp
  obtain ⟨m, n⟩ := p
  simp only at hA hA' hrun ⊢
  by_cases h4 : oddLeg (m, n) % 4 = 1
  · -- `n` even, `m` odd
    have hne : n % 2 = 0 := hA'.mp (hA.mpr h4)
    have hb : (triple (m, n)).2.1 = 2 * (m * n) := by simp only [triple]; ring
    have hmodd : m % 2 = 1 := by omega
    have hval : padicValNat 2 (m * n) = padicValNat 2 n := by
      rw [padicValNat.mul (p := 2) (by omega) (by omega), padicValNat_odd hmodd]
      simp
    rw [if_pos h4, hb, padicValNat_two_mul _ (Nat.mul_pos (by omega) hn), hval, hrun]
    omega
  · -- `n` odd
    have hne : n % 2 = 1 := by
      by_contra hc
      exact h4 (hA.mp (hA'.mpr (by omega)))
    rw [if_neg h4, hrun, padicValNat_odd hne]

end Price2Adic