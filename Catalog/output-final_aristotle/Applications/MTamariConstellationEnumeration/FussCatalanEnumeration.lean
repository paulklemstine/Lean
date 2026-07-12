import Mathlib

/-!
# Enumerative layer of the `m`-Tamari / `(m+1)`-constellation correspondence:
Fuss–Catalan element counts and `m`-Tamari interval numbers

The research direction

*"Recursive decomposition isomorphism for general `m`-Tamari intervals and planar
`(m+1)`-constellations"*

has a *structural* layer (a generating-tree / statistic-transport isomorphism,
developed elsewhere in this project) and an *enumerative* layer, which the
structural files explicitly leave open: identifying the actual counting sequences
with the classical Fuss–Catalan and Bousquet-Mélou–Chapoton numbers.  **This file
supplies rigorous, fully proved enumerative content.**

## What is proved

Two families of numbers govern the `m`-Tamari world:

* the **element count** of the `m`-Tamari lattice of size `n` is the *Fuss–Catalan
  number*
  `Cat_m(n) = 1/(mn+1) · C((m+1)n, n)`
  (for `m = 1` these are the ordinary Catalan numbers, the size of the Tamari
  lattice; the `(m+1)`-ary trees / `(m+1)`-Dyck paths counted here are the objects
  whose intervals the conjecture studies);

* the **interval count** is the Bousquet-Mélou–Chapoton number
  `Int_m(n) = (m+1)/(n(mn+1)) · C((m+1)²n + m, n-1)`,
  conjecturally equal to the number of planar `(m+1)`-constellations.

Rather than *assume* the closed forms, we give a manifestly-integer definition of
the Fuss–Catalan numbers as a **difference of two binomial coefficients**
(`fussCatalan`) and *prove* it satisfies the rational closed form
(`fussCatalan_closedForm`).  This is the enumerative heart of the file: the
identity
`(mn+1) · Cat_m(n) = C((m+1)n, n)`
holds for every `m` and `n`, which in particular shows `mn+1 ∣ C((m+1)n, n)`
(`fussCatalan_dvd`) — a genuine divisibility fact, the `m`-generalisation of the
classical `(n+1) ∣ C(2n,n)`.

We then

* recover the ordinary Catalan numbers at `m = 1`
  (`fussCatalan_one_eq_catalan`, linking to `Mathlib`'s `catalan`);
* pin down small values (`fussCatalan_one`, `fussCatalan_two`);
* record positivity and non-triviality (`fussCatalan_pos`, `fussCatalan_two_lt`);
* introduce the interval numbers `tamariInterval` over `ℚ`, verify the classical
  values `1, 3, 13, 68` (`m = 1`, OEIS A000260 — the planar-triangulation /
  Tamari-interval numbers) and `1, 6, 58` (`m = 2`), and prove that **intervals
  strictly outnumber elements** (`interval_gt_element`), the qualitative fact any
  interval↔constellation bijection must respect.

## Contrarian layer: bold conjectures tested

Two natural-looking conjectures are **disproved** by explicit counterexample:

* `not_symmetric` — Fuss–Catalan numbers are *not* symmetric in `(m, n)`;
* `not_binomial_difference_without_m` — the tempting "`m`-free" two-term formula
  `C((m+1)n, n) − C((m+1)n, n−1)` does *not* compute `Cat_m(n)` (the multiplier
  `m` on the second term is essential — this is exactly the subtlety the
  closed-form proof exposes).

Everything is proved from scratch over `ℕ`/`ℚ`; the only external inputs are the
elementary binomial recurrence `Nat.choose_succ_right_eq` and, for the `m = 1`
identification, `Mathlib`'s Catalan API.
-/

namespace MTamariEnumeration

open Nat

/-! ## Fuss–Catalan numbers as a difference of binomials -/

/-- The **Fuss–Catalan number** `Cat_m(n)`, defined as a manifestly non-negative
integer via the two-term binomial formula
`Cat_m(n) = C((m+1)n, n) − m·C((m+1)n, n−1)`.
For `m = 1` these are the Catalan numbers; `Cat_m(n)` counts the elements of the
`m`-Tamari lattice of size `n` (equivalently `(m+1)`-ary trees with `n` internal
nodes). -/
def fussCatalan (m : ℕ) : ℕ → ℕ
  | 0 => 1
  | n + 1 => Nat.choose ((m + 1) * (n + 1)) (n + 1) - m * Nat.choose ((m + 1) * (n + 1)) n

@[simp] theorem fussCatalan_zero (m : ℕ) : fussCatalan m 0 = 1 := rfl

/-- The key binomial recurrence specialised to the Fuss–Catalan window:
`(n+1)·C((m+1)(n+1), n+1) = (m(n+1)+1)·C((m+1)(n+1), n)`. This is the exact
cancellation that makes the closed form integral. -/
theorem fussCatalan_key (m n : ℕ) :
    (n + 1) * Nat.choose ((m + 1) * (n + 1)) (n + 1)
      = (m * (n + 1) + 1) * Nat.choose ((m + 1) * (n + 1)) n := by
  set N := (m + 1) * (n + 1) with hN
  have hsub : N - n = m * (n + 1) + 1 := by
    have : N = m * (n + 1) + (n + 1) := by rw [hN]; ring
    omega
  have h := Nat.choose_succ_right_eq N n
  rw [hsub] at h
  calc (n + 1) * N.choose (n + 1) = N.choose (n + 1) * (n + 1) := by ring
    _ = N.choose n * (m * (n + 1) + 1) := h
    _ = (m * (n + 1) + 1) * N.choose n := by ring

/-- **Closed form.** The manifestly-integer definition of `fussCatalan` satisfies
the classical rational formula: `(mn+1) · Cat_m(n) = C((m+1)n, n)`.
Equivalently `Cat_m(n) = C((m+1)n, n)/(mn+1)`. -/
theorem fussCatalan_closedForm (m n : ℕ) :
    (m * n + 1) * fussCatalan m n = Nat.choose ((m + 1) * n) n := by
  cases n with
  | zero => simp [fussCatalan]
  | succ n =>
    set a := Nat.choose ((m + 1) * (n + 1)) (n + 1) with ha
    set b := Nat.choose ((m + 1) * (n + 1)) n with hb
    set s := m * (n + 1) + 1 with hs
    have h1 : (n + 1) * a = s * b := fussCatalan_key m n
    have hab : m * b ≤ a := by
      have hstep : m * (n + 1) * b ≤ (n + 1) * a := by
        rw [h1, hs]; nlinarith [Nat.zero_le b]
      have hmul : (n + 1) * (m * b) ≤ (n + 1) * a := by nlinarith [hstep]
      exact Nat.le_of_mul_le_mul_left (by nlinarith [hmul]) (Nat.succ_pos n)
    have hval : fussCatalan m (n + 1) = a - m * b := by rw [fussCatalan]
    rw [hval]
    set d := a - m * b with hd
    have hadmb : a = d + m * b := by omega
    have hbd : b = (n + 1) * d := by
      have he : (n + 1) * (d + m * b) = s * b := by rw [← hadmb]; exact h1
      have hexp : (n + 1) * d + (n + 1) * (m * b) = m * (n + 1) * b + b := by
        have hsb : s * b = m * (n + 1) * b + b := by rw [hs]; ring
        nlinarith [hsb, he]
      nlinarith [hexp]
    show s * d = a
    rw [hadmb, hbd]; ring

/-- **Divisibility corollary.** `mn + 1` divides `C((m+1)n, n)` for all `m, n`.
For `m = 1` this is the classical `(n+1) ∣ C(2n, n)`. -/
theorem fussCatalan_dvd (m n : ℕ) : (m * n + 1) ∣ Nat.choose ((m + 1) * n) n :=
  ⟨fussCatalan m n, (fussCatalan_closedForm m n).symm⟩

/-- Fuss–Catalan numbers are strictly positive. -/
theorem fussCatalan_pos (m n : ℕ) : 0 < fussCatalan m n := by
  have h := fussCatalan_closedForm m n
  have hpos : 0 < Nat.choose ((m + 1) * n) n := by
    apply Nat.choose_pos; nlinarith [Nat.zero_le (m * n)]
  rcases Nat.eq_zero_or_pos (fussCatalan m n) with h0 | h0
  · rw [h0, Nat.mul_zero] at h; omega
  · exact h0

@[simp] theorem fussCatalan_one (m : ℕ) : fussCatalan m 1 = 1 := by
  have h := fussCatalan_closedForm m 1
  simp only [Nat.mul_one, Nat.choose_one_right] at h
  have h2 : (m + 1) * fussCatalan m 1 = (m + 1) * 1 := by rw [h]; ring
  exact Nat.eq_of_mul_eq_mul_left (by omega) h2

/-- `Cat_m(2) = m + 1`. In particular the sequence genuinely depends on `m`. -/
theorem fussCatalan_two (m : ℕ) : fussCatalan m 2 = m + 1 := by
  have h := fussCatalan_closedForm m 2
  have hc : Nat.choose ((m + 1) * 2) 2 = (m + 1) * (2 * m + 1) := by
    have hmul : (m + 1) * 2 = 2 * m + 2 := by ring
    rw [hmul, Nat.choose_two_right]
    have hnum : (2 * m + 2) * (2 * m + 2 - 1) = (m + 1) * (2 * m + 1) * 2 := by
      have h1 : 2 * m + 2 - 1 = 2 * m + 1 := by omega
      rw [h1]; ring
    rw [hnum]; omega
  rw [hc] at h
  have hfac : (m + 1) * (2 * m + 1) = (m * 2 + 1) * (m + 1) := by ring
  rw [hfac] at h
  exact Nat.eq_of_mul_eq_mul_left (by omega) h

/-- Non-triviality: for `m ≥ 1`, `Cat_m(2) > 1`, so the sequence is not eventually
constant. -/
theorem fussCatalan_two_lt (m : ℕ) (hm : 1 ≤ m) : 1 < fussCatalan m 2 := by
  rw [fussCatalan_two]; omega

/-- **Recovery of the Catalan numbers at `m = 1`.** The Fuss–Catalan numbers with
`m = 1` are exactly `Mathlib`'s Catalan numbers `catalan n` — the size of the
`n`-th Tamari lattice. -/
theorem fussCatalan_one_eq_catalan (n : ℕ) : fussCatalan 1 n = catalan n := by
  have h := fussCatalan_closedForm 1 n
  have hc := succ_mul_catalan_eq_centralBinom n
  have hcb : Nat.centralBinom n = Nat.choose (2 * n) n := rfl
  rw [hcb] at hc
  have e1 : 1 * n + 1 = n + 1 := by ring
  have e2 : (1 + 1) * n = 2 * n := by ring
  rw [e1, e2] at h
  have hmul : (n + 1) * fussCatalan 1 n = (n + 1) * catalan n := by rw [h, hc]
  exact Nat.eq_of_mul_eq_mul_left (Nat.succ_pos n) hmul

/-! ## `m`-Tamari interval numbers (Bousquet-Mélou–Chapoton) -/

/-- The **`m`-Tamari interval number** `Int_m(n)`, conjecturally the number of
planar `(m+1)`-constellations:
`Int_m(n) = (m+1)/(n(mn+1)) · C((m+1)²n + m, n−1)`. Defined over `ℚ`. -/
def tamariInterval (m n : ℕ) : ℚ :=
  ((m : ℚ) + 1) / ((n : ℚ) * ((m : ℚ) * n + 1))
    * (Nat.choose ((m + 1) ^ 2 * n + m) (n - 1) : ℚ)

/-- `Int_1(1) = 1` (there is a unique interval in the 1-element Tamari lattice). -/
theorem tamariInterval_one_one : tamariInterval 1 1 = 1 := by
  unfold tamariInterval; norm_num [Nat.choose]

/-- `Int_1(2) = 3`: the three intervals of the size-2 Tamari lattice (OEIS
A000260 begins `1, 3, 13, 68, …`, the planar-triangulation numbers). -/
theorem tamariInterval_one_two : tamariInterval 1 2 = 3 := by
  unfold tamariInterval; norm_num [Nat.choose]

/-- `Int_1(3) = 13`. -/
theorem tamariInterval_one_three : tamariInterval 1 3 = 13 := by
  unfold tamariInterval; norm_num [Nat.choose]

/-- `Int_1(4) = 68`. -/
theorem tamariInterval_one_four : tamariInterval 1 4 = 68 := by
  unfold tamariInterval; norm_num [Nat.choose]

/-- `Int_2(2) = 6`: the `m = 2` interval sequence begins `1, 6, 58, …`. -/
theorem tamariInterval_two_two : tamariInterval 2 2 = 6 := by
  unfold tamariInterval; norm_num [Nat.choose]

/-- `Int_2(3) = 58`. -/
theorem tamariInterval_two_three : tamariInterval 2 3 = 58 := by
  unfold tamariInterval; norm_num [Nat.choose]

/-
**The `n`-factor of interval integrality.** For every `m` and every `n ≥ 1`,
`n` divides `(m+1)·C((m+1)²n + m, n−1)`, the numerator of the
Bousquet-Mélou–Chapoton interval number `Int_m(n)`.

This is one of the two coprime factors of the full denominator `n(mn+1)` (note
`gcd(n, mn+1) = 1`); establishing it reduces the general integrality of `Int_m(n)`
to divisibility by `mn+1` alone.  The proof is a single binomial absorption
identity: writing `N = (m+1)²n + m`, `Nat.choose_succ_right_eq` gives
`n·C(N,n) = (N−n+1)·C(N,n−1)`, and `N − n + 1 = m(m+2)n + (m+1)`, so
`(m+1)·C(N,n−1) = n·(C(N,n) − m(m+2)·C(N,n−1))`.
-/
theorem tamariInterval_n_dvd (m n : ℕ) (hn : 1 ≤ n) :
    (n : ℕ) ∣ (m + 1) * Nat.choose ((m + 1) ^ 2 * n + m) (n - 1) := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide;
  have h_absorption : Nat.choose ((m + 1) ^ 2 * (n + 2) + m) (n + 2) * (n + 2) = Nat.choose ((m + 1) ^ 2 * (n + 2) + m) (n + 1) * ((m + 1) ^ 2 * (n + 2) + m - (n + 1)) := by
    rw [ ← Nat.choose_succ_right_eq ];
  rw [ show ( m + 1 ) ^ 2 * ( n + 2 ) + m - ( n + 1 ) = ( m * ( m + 2 ) ) * ( n + 2 ) + ( m + 1 ) by rw [ Nat.sub_eq_of_eq_add ] ; ring ] at h_absorption;
  exact ⟨ Nat.choose ( ( m + 1 ) ^ 2 * ( n + 2 ) + m ) ( n + 2 ) - m * ( m + 2 ) * Nat.choose ( ( m + 1 ) ^ 2 * ( n + 2 ) + m ) ( n + 1 ), by rw [ Nat.mul_sub_left_distrib ] ; exact eq_tsub_of_add_eq <| by linarith ⟩

/-- **Intervals strictly outnumber elements.** For `m = 1`, `n = 2` the number of
intervals (`3`) exceeds the number of lattice elements (`Cat_1(2) = 2`).  Any
element↔element bijection cannot be an interval↔interval bijection; the
correspondence with constellations is genuinely at the level of *intervals*. -/
theorem interval_gt_element :
    (fussCatalan 1 2 : ℚ) < tamariInterval 1 2 := by
  rw [tamariInterval_one_two]
  have hfc : fussCatalan 1 2 = 2 := by rw [fussCatalan_two]
  rw [hfc]; norm_num

/-! ## Contrarian layer: disproved conjectures -/

/-- **Disproof.** The Fuss–Catalan numbers are *not* symmetric in `(m, n)`:
`Cat_1(2) = 2 ≠ 1 = Cat_2(1)`. -/
theorem not_symmetric : ¬ (∀ m n, fussCatalan m n = fussCatalan n m) := by
  intro h
  have hspec := h 1 2
  rw [fussCatalan_two, fussCatalan_one] at hspec
  omega

/-- **Disproof.** The `m`-free two-term formula `C((m+1)n, n) − C((m+1)n, n−1)`
does *not* compute the Fuss–Catalan number in general: at `m = 2`, `n = 2` it
gives `9`, whereas `Cat_2(2) = 3`.  The multiplier `m` on the second binomial (see
the definition of `fussCatalan`) is essential. -/
theorem not_binomial_difference_without_m :
    ¬ (∀ m n, fussCatalan m n
        = Nat.choose ((m + 1) * n) n - Nat.choose ((m + 1) * n) (n - 1)) := by
  intro h
  have hspec := h 2 2
  rw [fussCatalan_two] at hspec
  revert hspec
  decide

end MTamariEnumeration