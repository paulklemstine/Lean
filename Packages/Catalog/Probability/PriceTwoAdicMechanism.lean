import Cryptography.Price2Adic.Letters

/-!
# The Price tree: the exact 2-adic run mechanism, and the letter at position 2

`Cryptography/Price2Adic/Tree.lean` builds the Price tree of primitive Pythagorean triples
on Euclid parameter pairs `(m, n)` (moves `A : (m,n) ↦ (m+n, 2n)`, `B : (m,n) ↦ (2m, m-n)`,
`C : (m,n) ↦ (2m, m+n)`, root `(2,1)`), and `Cryptography/Price2Adic/Letters.lean` proves
that the last two letters of a Price address are read off the residue `N mod 8` of the odd
leg `N = m² - n²`.

This file proves the *mechanism* behind that dictionary, in the form of two exact
run laws for the descent (`parent`-iteration), and then uses them to compute the letter
at position `2` — the first position where the 2-adic reading dies
(`Probability/PriceTwoAdicSealing.lean`).

Writing `letterAt p t = letterOf (parent^[t] p)` for the letter of `p` at position `t`
counted from the leaf:

* `letterAt_even_iff` — **`A`-run law.**  If `2^t ∣ n` then
  `parent^[t] (m,n) = (m - n + n/2^t, n/2^t)` (`iterate_parent_even`) and
  `letterAt (m,n) t = A ↔ 2^(t+1) ∣ n`.  So for `n` even the address starts (from the leaf)
  with a block of exactly `v₂(n)` letters `A`, and then a non-`A`.
* `letterAt_odd_run` — **non-`A`-run law.**  If `n` is odd and `2^(t+1) ∣ m` then
  `letterAt (m,n) t ≠ A`, and if moreover `2^(t+2) ∤ m` then `letterAt (m,n) (t+1) = A`.
  So for `n` odd the address starts with exactly `v₂(m)` non-`A` letters and the first `A`
  sits at position `v₂(m)` — this is the "non-`A` runs decrement `v₂(p+q)` by one" law,
  since `p + q = 2m` in the odd-pair coordinates `p = m - n`, `q = m + n`.
* `pos2_A_iff` — the resulting closed form for position `2`, a condition on `(m,n) mod 16`.
* `letterAt_getElem?_address` — the bridge to the address word: position `t` from the leaf
  really is the `t`-th letter of `(address p).reverse`.
* `letterOf_eq_B_iff_size` — the `B` versus `C` split is the *size* rule `q < 3p`
  (never a congruence), inside the congruence class `N ≡ 3 mod 4`.

## Lab notes (round 71, exp 552)

Exhaustive check over all valid pairs with `m < 400`: the `A`-run law and the non-`A`-run
law hold with `0` exceptions, and the four-case formula `pos2_A_iff` classifies position `2`
with `0` exceptions on all `m + n > 27` (below that the address is shorter than `3`).
-/

namespace Price2Adic

/-! ## Positions counted from the leaf -/

/-- The letter of the Price address of `p` at position `t`, counted from the leaf
(`t = 0` is the last letter of `address p`). -/
def letterAt (p : ℕ × ℕ) (t : ℕ) : PriceLetter := letterOf (parent^[t] p)

@[simp] theorem letterAt_zero (p : ℕ × ℕ) : letterAt p 0 = letterOf p := rfl

theorem letterAt_succ (p : ℕ × ℕ) (t : ℕ) : letterAt p (t + 1) = letterAt (parent p) t := by
  simp [letterAt, Function.iterate_succ_apply]

theorem letterAt_one (p : ℕ × ℕ) : letterAt p 1 = letterOf (parent p) := by
  rw [letterAt_succ, letterAt_zero]

/-- **The bridge to the address word.**  Position `t` counted from the leaf is the `t`-th
entry of the reversed address. -/
theorem letterAt_getElem?_address :
    ∀ (t : ℕ) (p : ℕ × ℕ), Valid p → t < (address p).length →
      (address p).reverse[t]? = some (letterAt p t) := by
  intro t
  induction t with
  | zero =>
    intro p hp ht
    have hne : p ≠ root := by
      intro h; rw [h, address_root] at ht; simp at ht
    rw [address_of_ne_root p hp hne]
    simp [letterAt]
  | succ t ih =>
    intro p hp ht
    have hne : p ≠ root := by
      intro h; rw [h, address_root] at ht; simp at ht
    have hlen : (address p).length = (address (parent p)).length + 1 := by
      rw [address_of_ne_root p hp hne]; simp
    rw [address_of_ne_root p hp hne, letterAt_succ]
    simp only [List.reverse_append, List.reverse_cons, List.reverse_nil, List.nil_append,
      List.cons_append, List.getElem?_cons_succ]
    exact ih (parent p) (parent_valid p hp hne) (by omega)

/-- **A depth criterion.**  If the first `L` ancestors of a valid node are not the root,
the address of the node has length at least `L`; so positions `0, …, L-1` are genuine
letters of the address. -/
theorem length_address_ge :
    ∀ (L : ℕ) (p : ℕ × ℕ), Valid p → (∀ u < L, parent^[u] p ≠ root) → L ≤ (address p).length := by
  intro L
  induction L with
  | zero => intro p _ _; exact Nat.zero_le _
  | succ L ih =>
    intro p hp hne
    have h0 : p ≠ root := by simpa using hne 0 (by omega)
    have hlen : (address p).length = (address (parent p)).length + 1 := by
      rw [address_of_ne_root p hp h0]; simp
    have hrest : ∀ u < L, parent^[u] (parent p) ≠ root := by
      intro u hu
      have := hne (u + 1) (by omega)
      rwa [Function.iterate_succ_apply] at this
    have := ih (parent p) (parent_valid p hp h0) hrest
    omega

/-- A node with `m + n > 27` has depth at least `3`, so positions `0,1,2` are genuine
letters of its address. -/
theorem three_le_length_address (p : ℕ × ℕ) (hp : Valid p) (h : 27 < p.1 + p.2) :
    3 ≤ (address p).length := by
  by_contra hc
  push_neg at hc
  have h1 := sum_le_of_length (address p)
  rw [eval_address p hp] at h1
  have h2 : (3 : ℕ) ^ ((address p).length + 1) ≤ 3 ^ 3 :=
    Nat.pow_le_pow_right (by norm_num) (by omega)
  norm_num at h2
  omega

/-! ## The `A`-run law -/

/-- Descent along an `A`-run has a closed form: while `2^t ∣ n`, the `t`-th ancestor of
`(m,n)` is `(m - n + n/2^t, n/2^t)`. -/
theorem iterate_parent_even (m n : ℕ) (hmn : n ≤ m) :
    ∀ t : ℕ, 2 ^ t ∣ n → parent^[t] (m, n) = (m - n + n / 2 ^ t, n / 2 ^ t) := by
  intro t
  induction t with
  | zero =>
    intro _
    have h : (2 : ℕ) ^ 0 = 1 := pow_zero 2
    rw [Function.iterate_zero_apply, h, Nat.div_one]
    simp only [Prod.mk.injEq]
    exact ⟨by omega, trivial⟩
  | succ t ih =>
    intro hdvd
    have hdvd' : 2 ^ t ∣ n := dvd_trans (pow_dvd_pow 2 (Nat.le_succ t)) hdvd
    rw [Function.iterate_succ_apply', ih hdvd']
    obtain ⟨c, hc⟩ := hdvd
    have hpos : 0 < (2 : ℕ) ^ t := pow_pos (by norm_num) t
    have hpos' : 0 < (2 : ℕ) ^ (t + 1) := pow_pos (by norm_num) (t + 1)
    have h1 : n / 2 ^ t = 2 * c := by
      have : n = 2 ^ t * (2 * c) := by rw [hc, pow_succ]; ring
      rw [this, Nat.mul_div_cancel_left _ hpos]
    have h2 : n / 2 ^ (t + 1) = c := by rw [hc, Nat.mul_div_cancel_left _ hpos']
    rw [h1, h2]
    simp only [parent]
    rw [if_pos (by omega)]
    simp only [Prod.mk.injEq]
    omega

/-- **The `A`-run law.**  For `n ≤ m` and `2^t ∣ n`, the letter at position `t` is `A`
exactly when `n` is divisible by one more power of two.  Hence the address of a node with
`n` even begins (from the leaf) with exactly `v₂(n)` letters `A`. -/
theorem letterAt_even_iff (m n t : ℕ) (hmn : n ≤ m) (h : 2 ^ t ∣ n) :
    letterAt (m, n) t = .A ↔ 2 ^ (t + 1) ∣ n := by
  have hpos : 0 < (2 : ℕ) ^ t := pow_pos (by norm_num) t
  obtain ⟨c, hc⟩ := h
  have hdiv : n / 2 ^ t = c := by rw [hc, Nat.mul_div_cancel_left _ hpos]
  rw [letterAt, iterate_parent_even m n hmn t ⟨c, hc⟩, letterOf_pair_eq_A_iff, hdiv]
  constructor
  · intro hcc
    obtain ⟨e, he⟩ : ∃ e, c = 2 * e := ⟨c / 2, by omega⟩
    exact ⟨e, by rw [hc, he, pow_succ]; ring⟩
  · rintro ⟨e, he⟩
    have : 2 ^ t * c = 2 ^ t * (2 * e) := by rw [← hc, he, pow_succ]; ring
    have hce : c = 2 * e := Nat.eq_of_mul_eq_mul_left hpos this
    omega

/-! ## The non-`A`-run law -/

/-- One descent step at a node with odd `n`: the first coordinate is halved, and the second
becomes the distance between `m/2` and `n`. -/
theorem parent_odd_snd (m n : ℕ) (hn : n % 2 = 1) :
    ∃ d : ℕ, parent (m, n) = (m / 2, d) ∧
      ((2 * n < m ∧ d = m / 2 - n) ∨ (¬ 2 * n < m ∧ d = n - m / 2)) := by
  simp only [parent]
  rw [if_neg (by omega)]
  by_cases h : 2 * n < m
  · exact ⟨m / 2 - n, by rw [if_pos h], Or.inl ⟨h, rfl⟩⟩
  · exact ⟨n - m / 2, by rw [if_neg h], Or.inr ⟨h, rfl⟩⟩

theorem pow_dvd_half (m t : ℕ) (hm : m % 2 = 0) : 2 ^ (t + 1) ∣ m ↔ 2 ^ t ∣ m / 2 := by
  obtain ⟨c, hc⟩ : ∃ c, m = 2 * c := ⟨m / 2, by omega⟩
  subst hc
  rw [Nat.mul_div_cancel_left _ (by norm_num : 0 < 2), pow_succ']
  exact mul_dvd_mul_iff_left (by norm_num : (2 : ℕ) ≠ 0)

/-- **The non-`A`-run law.**  If `n` is odd (so `m` is even for a valid node) and
`2^(t+1) ∣ m`, then the letter at position `t` is not `A`; and if `m` is divisible by no
higher power of two, the letter at position `t+1` *is* `A`.  Equivalently: a node with `n`
odd starts with exactly `v₂(m)` non-`A` letters, and the first `A` lands at position
`v₂(m)`. -/
theorem letterAt_odd_run : ∀ (t m n : ℕ), n % 2 = 1 → 0 < n → n < m → 2 ^ (t + 1) ∣ m →
    letterAt (m, n) t ≠ .A ∧ (¬ 2 ^ (t + 2) ∣ m → letterAt (m, n) (t + 1) = .A) := by
  intro t
  induction t with
  | zero =>
    intro m n hn hpos hlt hdvd
    have hm2 : m % 2 = 0 := by
      have : (2 : ℕ) ∣ m := by simpa using hdvd
      omega
    refine ⟨?_, ?_⟩
    · rw [letterAt_zero, letterOf_pair_ne_A_iff]; exact hn
    · intro hnd
      have hm4 : m % 4 = 2 := by
        have h4 : ¬ (4 : ℕ) ∣ m := by
          intro hc; exact hnd (by simpa using hc)
        omega
      obtain ⟨d, hpar, hd⟩ := parent_odd_snd m n hn
      rw [letterAt_succ, hpar, letterAt_zero, letterOf_pair_eq_A_iff]
      rcases hd with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
  | succ t ih =>
    intro m n hn hpos hlt hdvd
    have h4 : (4 : ℕ) ∣ m := by
      have : (2 : ℕ) ^ 2 ∣ 2 ^ (t + 2) := pow_dvd_pow 2 (by omega)
      have := dvd_trans this hdvd
      simpa using this
    have hm2 : m % 2 = 0 := by omega
    have hm4 : m % 4 = 0 := by omega
    obtain ⟨d, hpar, hd⟩ := parent_odd_snd m n hn
    have hdodd : d % 2 = 1 := by rcases hd with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
    have hdpos : 0 < d := by rcases hd with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
    have hdlt : d < m / 2 := by rcases hd with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
    have hdvd' : 2 ^ (t + 1) ∣ m / 2 := (pow_dvd_half m (t + 1) hm2).mp hdvd
    obtain ⟨hne, hA⟩ := ih (m / 2) d hdodd hdpos hdlt hdvd'
    refine ⟨?_, ?_⟩
    · rw [letterAt_succ, hpar]; exact hne
    · intro hnd
      rw [letterAt_succ, hpar]
      exact hA (fun hc => hnd ((pow_dvd_half m (t + 2) hm2).mpr hc))

/-! ## The letter at position 2 -/

/-- The four-case closed form for "the letter at position `2` is `A`": a condition on
`(m, n)` modulo `16`. -/
def pos2Pred (m n : ℕ) : Prop :=
  if n % 4 = 0 then n % 8 = 0
  else if n % 2 = 0 then (m - n / 2) % 4 = 2
  else if m % 4 = 2 then (m / 2) % 4 = n % 4
  else m % 8 = 4

instance (m n : ℕ) : Decidable (pos2Pred m n) := by unfold pos2Pred; infer_instance

/-- **Position 2 in closed form.**  For a valid node other than the root, the letter at
position `2` is `A` exactly when `pos2Pred m n` holds. -/
theorem pos2_A_iff (m n : ℕ) (hv : Valid (m, n)) (hroot : (m, n) ≠ root) :
    letterAt (m, n) 2 = .A ↔ pos2Pred m n := by
  obtain ⟨hn0, hlt, hg, hpar⟩ := hv
  have hnm : 2 * n ≠ m := two_mul_ne (m, n) ⟨hn0, hlt, hg, hpar⟩ hroot
  simp only at hnm
  simp only [pos2Pred]
  by_cases h4 : n % 4 = 0
  · -- `A`-run of length ≥ 2
    rw [if_pos h4]
    have hdvd : (2 : ℕ) ^ 2 ∣ n := by norm_num; omega
    rw [letterAt_even_iff m n 2 hlt.le hdvd]
    constructor
    · intro h; obtain ⟨c, hc⟩ := h; omega
    · intro h; exact ⟨n / 8, by omega⟩
  · rw [if_neg h4]
    by_cases h2 : n % 2 = 0
    · -- `n ≡ 2 mod 4`: position 0 is `A`, position 1 is not
      rw [if_pos h2]
      have hdvd : (2 : ℕ) ^ 1 ∣ n := by norm_num; omega
      have hstep : parent (m, n) = (m - n / 2, n / 2) := by
        simp only [parent]; rw [if_pos h2]
      have hmodd : m % 2 = 1 := by omega
      have hn2 : (n / 2) % 2 = 1 := by omega
      have hm' : (m - n / 2) % 2 = 0 := by omega
      have hlt' : n / 2 < m - n / 2 := by omega
      have hpos' : 0 < n / 2 := by omega
      have hdvd' : (2 : ℕ) ^ (0 + 1) ∣ (m - n / 2) := by
        simpa using (by omega : (2 : ℕ) ∣ (m - n / 2))
      obtain ⟨hne, hA⟩ := letterAt_odd_run 0 (m - n / 2) (n / 2) hn2 hpos' hlt' hdvd'
      have h2eq : letterAt (m, n) 2 = letterAt (m - n / 2, n / 2) 1 := by
        rw [letterAt_succ, hstep]
      rw [h2eq]
      constructor
      · intro hAA
        by_contra hc
        have hd4 : (4 : ℕ) ∣ (m - n / 2) := by omega
        obtain ⟨hne2, -⟩ :=
          letterAt_odd_run 1 (m - n / 2) (n / 2) hn2 hpos' hlt'
            (by simpa using (by exact hd4 : (2:ℕ)^2 ∣ (m - n/2)))
        exact hne2 hAA
      · intro hmod
        refine hA ?_
        intro hc
        have : (4 : ℕ) ∣ (m - n / 2) := by simpa using hc
        omega
    · rw [if_neg h2]
      have hnodd : n % 2 = 1 := by omega
      have hmeven : m % 2 = 0 := by omega
      by_cases hm4 : m % 4 = 2
      · -- `m ≡ 2 mod 4`: position 0 is not `A`, position 1 is `A`
        rw [if_pos hm4]
        obtain ⟨d, hstep, hd⟩ := parent_odd_snd m n hnodd
        have hdeven : d % 2 = 0 := by rcases hd with ⟨h1, hh⟩ | ⟨h1, hh⟩ <;> omega
        have hdpos : 0 < d := by rcases hd with ⟨h1, hh⟩ | ⟨h1, hh⟩ <;> omega
        have hdle : d ≤ m / 2 := by rcases hd with ⟨h1, hh⟩ | ⟨h1, hh⟩ <;> omega
        have h2eq : letterAt (m, n) 2 = letterAt (m / 2, d) 1 := by
          rw [letterAt_succ, hstep]
        rw [h2eq, letterAt_even_iff (m / 2) d 1 hdle (by simpa using (by omega : (2:ℕ) ∣ d))]
        constructor
        · rintro ⟨c, hc⟩
          rcases hd with ⟨h1, hh⟩ | ⟨h1, hh⟩ <;> omega
        · intro hmod
          refine ⟨d / 4, ?_⟩
          rcases hd with ⟨h1, hh⟩ | ⟨h1, hh⟩ <;> omega
      · -- `m ≡ 0 mod 4`: two non-`A` letters, position 2 is `A` iff `m ≡ 4 mod 8`
        rw [if_neg hm4]
        have hm4' : m % 4 = 0 := by omega
        have hdvd : (2 : ℕ) ^ (1 + 1) ∣ m := by
          simpa using (by omega : (4 : ℕ) ∣ m)
        obtain ⟨-, hA⟩ := letterAt_odd_run 1 m n hnodd hn0 hlt hdvd
        constructor
        · intro hAA
          by_contra hc
          have h8 : (8 : ℕ) ∣ m := by omega
          obtain ⟨hne2, -⟩ := letterAt_odd_run 2 m n hnodd hn0 hlt
            (by simpa using h8)
          exact hne2 hAA
        · intro hmod
          refine hA ?_
          intro hc
          have : (8 : ℕ) ∣ m := by simpa using hc
          omega

/-! ## Positions 0 and 1, and the size rule for `B` versus `C` -/

/-- Position `0` is `A` exactly when the odd leg is `1 mod 4` (restated for `letterAt`). -/
theorem letterAt_zero_A_iff (p : ℕ × ℕ) (hp : Valid p) :
    letterAt p 0 = .A ↔ oddLeg p % 4 = 1 := by
  rw [letterAt_zero]; exact letterOf_eq_A_iff_oddLeg p hp

/-- Position `1` is `A` exactly when the odd leg lies in `{1,3} mod 8`. -/
theorem letterAt_one_A_iff (p : ℕ × ℕ) (hp : Valid p) :
    letterAt p 1 = .A ↔ (oddLeg p % 8 = 1 ∨ oddLeg p % 8 = 3) := by
  rw [letterAt_one]; exact letterOf_parent_eq_A_iff p hp

/-- **The `B`/`C` split is a size rule.**  In the odd-pair coordinates `p = m - n`,
`q = m + n` (so that the odd leg is `N = p·q`), the letter is `B` exactly when
`N ≡ 3 mod 4` — a congruence, one bit of `N mod 4` — *and* `q < 3p`, a pure size
comparison that no congruence can see (cf. `twoAdic_blind_BC`). -/
theorem letterOf_eq_B_iff_size (m n : ℕ) (hv : Valid (m, n)) :
    letterOf (m, n) = .B ↔ (oddLeg (m, n) % 4 = 3 ∧ (m + n) < 3 * (m - n)) := by
  obtain ⟨hn0, hlt, hg, hpar⟩ := hv
  have hleg := letterOf_eq_A_iff_oddLeg (m, n) ⟨hn0, hlt, hg, hpar⟩
  have hmod := oddLeg_mod_four (m, n) ⟨hn0, hlt, hg, hpar⟩
  constructor
  · intro hB
    have hnA : letterOf (m, n) ≠ .A := by rw [hB]; simp
    have hnodd : n % 2 = 1 := (letterOf_pair_ne_A_iff m n).mp hnA
    have hBC : 2 * n < m := by
      by_contra hc
      rw [show letterOf (m, n) = if n % 2 = 0 then PriceLetter.A
          else if 2 * n < m then PriceLetter.B else PriceLetter.C from rfl] at hB
      rw [if_neg (by omega), if_neg hc] at hB
      simp at hB
    refine ⟨?_, by omega⟩
    rcases hmod with ⟨h1, -⟩ | ⟨-, h2⟩
    · exact absurd h1 hnA
    · exact h2
  · rintro ⟨h3, hsize⟩
    have hnA : letterOf (m, n) ≠ .A := by
      intro hc; rw [hleg.mp hc] at h3; omega
    have hnodd : n % 2 = 1 := (letterOf_pair_ne_A_iff m n).mp hnA
    rw [show letterOf (m, n) = if n % 2 = 0 then PriceLetter.A
        else if 2 * n < m then PriceLetter.B else PriceLetter.C from rfl]
    rw [if_neg (by omega), if_pos (by omega)]

end Price2Adic