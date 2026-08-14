import Mathlib
import Novelty.GCDMomentPairInversion

/-!
# Every moment of order `k ≥ 3` identifies the factorisation

`Novelty.GCDMomentPairInversion` showed that the third moment is strictly monotone in the
spread of a factorisation, so it separates all nontrivial factorisations of a modulus, while
the second moment does not (`N = 28`, `N = 36`).  This file proves the *general* statement:
**for every `k ≥ 3` the `k`-th moment separates factorisations**, for *every* modulus: the
main argument covers all `N > 30`, and a separate induction disposes of the seven exceptional
quadruples below that.

The mechanism is a four-parameter factorisation of the moment difference.  Two coprime-shape
factorisations of the same modulus can always be written as

`a = g·α,  b = γ·δ,  c = g·γ,  d = α·δ`,  so `ab = cd = gαγδ = N`,

and then the difference of the two predicted moments factors completely:

`pairMoment (m+2) a b − pairMoment (m+2) c d = (γ−α)(δ−g)·[N·H_m·H'_m − H_{m+1}·H'_{m+1} − 1]`,

where `H_m = ∑_{i≤m} γ^i α^{m−i}` and `H'_m = ∑_{i≤m} δ^i g^{m−i}` are complete homogeneous
symmetric polynomials (`hSum`).  Since `H_{m+1} ≤ (γ+α)H_m` and `(γ+α)(δ+g) = a+b+c+d`, the
bracket is at least `H_m H'_m (N − (a+b+c+d)) − 1 ≥ 2·1·1 − 1 > 0` as soon as `m ≥ 1`
(i.e. `k ≥ 3`) and `N > a+b+c+d`; and `N > a+b+c+d` is automatic for `N > 30`
(`sum_lt_of_thirtyone_le`).

## Main results

* `sub_mul_hSum` — `(x−y)·H_m(x,y) = x^{m+1} − y^{m+1}`.
* `pairMoment_split_identity` — the four-parameter factorisation of the moment difference.
* `pairMoment_bracket_pos` — positivity of the bracket for `k ≥ 3` under `N > a+b+c+d`.
* `pairMoment_spread_strict_param` — strict monotonicity in the spread, parametrised form.
* `pairMoment_spread_strict` — **the coordinate-free statement**: for `k ≥ 3`, if
  `2 ≤ a < c ≤ d < b` and `ab = cd` with `a+b+c+d < ab`, then
  `pairMoment k c d < pairMoment k a b`.
* `sum_lt_of_thirtyone_le` — the side condition is automatic once `N ≥ 31`.
* `pairMoment_injective_of_three_le` — **every moment of order `k ≥ 3` separates all
  nontrivial factorisations of any modulus `N ≥ 31`.**
* `exceptional_quadruple_classification` — the side condition `a+b+c+d < ab` fails for exactly
  seven quadruples, all with `a = 2`.
* `tailMoment`, `tailMoment_step`, `tailMoment_lt_pow`, `pairMoment_exceptional` — a separate
  induction that handles those seven.
* `pairMoment_spread_strict_unconditional`, `pairMoment_injective_of_three_le_unconditional` —
  **the `N ≥ 31` hypothesis is removed: for every `k ≥ 3` and every modulus, the `k`-th moment
  separates all nontrivial factorisations.**
* `factorization_from_moment_oracle`, `factorization_from_any_moment` — **the oracle form**:
  for every `k ≥ 1`, the observed `k`-th gcd moment of a distinct-prime semiprime is matched by
  exactly one candidate factorisation, the true one.

Together with the `k = 2` collision law this settles the shape of the inversion problem: the
second moment is the *only* ambiguous member of the family, and no member is cheap.
-/

namespace GCDMoment

/-! ### Complete homogeneous sums -/

/-- `hSum m x y = ∑_{i ≤ m} x^i y^{m-i}`, the complete homogeneous symmetric polynomial. -/
def hSum : ℕ → ℤ → ℤ → ℤ
  | 0, _, _ => 1
  | (m + 1), x, y => x * hSum m x y + y ^ (m + 1)

@[simp] lemma hSum_zero (x y : ℤ) : hSum 0 x y = 1 := rfl

lemma hSum_succ (m : ℕ) (x y : ℤ) : hSum (m + 1) x y = x * hSum m x y + y ^ (m + 1) := rfl

/-- The telescoping identity `(x−y)·H_m(x,y) = x^{m+1} − y^{m+1}`. -/
theorem sub_mul_hSum (m : ℕ) (x y : ℤ) : (x - y) * hSum m x y = x ^ (m + 1) - y ^ (m + 1) := by
  induction m with
  | zero => simp
  | succ m ih =>
      rw [hSum_succ]
      linear_combination x * ih

/-- `H_m` is at least `1` on nonnegative arguments. -/
theorem one_le_hSum {x y : ℤ} (hx : 0 ≤ x) (hy : 1 ≤ y) (m : ℕ) : 1 ≤ hSum m x y := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h1 : 0 ≤ x * hSum m x y := mul_nonneg hx (by linarith)
      have h2 : (1 : ℤ) ≤ y ^ (m + 1) := one_le_pow₀ hy
      rw [hSum_succ]; linarith

/-- On arguments `≥ 1` and for `m ≥ 1`, `H_m ≥ 2`: it has at least two terms. -/
theorem two_le_hSum {x y : ℤ} (hx : 1 ≤ x) (hy : 1 ≤ y) (m : ℕ) : 2 ≤ hSum (m + 1) x y := by
  have h1 : 1 ≤ hSum m x y := one_le_hSum (by linarith) hy m
  have h2 : (1 : ℤ) ≤ y ^ (m + 1) := one_le_pow₀ hy
  have h3 : 1 ≤ x * hSum m x y := by nlinarith
  rw [hSum_succ]; linarith

/-- The `m`-th power of an argument is one of the terms of `H_m`. -/
theorem pow_le_hSum {x y : ℤ} (hx : 0 ≤ x) (hy : 1 ≤ y) (m : ℕ) : y ^ m ≤ hSum m x y := by
  induction m with
  | zero => simp
  | succ m ih =>
      have h1 : 0 ≤ x * hSum m x y :=
        mul_nonneg hx (by linarith [one_le_hSum hx hy m])
      rw [hSum_succ]; linarith

/-- `H_{m+1} ≤ (x+y)·H_m`. -/
theorem hSum_succ_le {x y : ℤ} (hx : 0 ≤ x) (hy : 1 ≤ y) (m : ℕ) :
    hSum (m + 1) x y ≤ (x + y) * hSum m x y := by
  have h1 : y ^ (m + 1) ≤ y * hSum m x y := by
    have := pow_le_hSum hx hy m
    calc y ^ (m + 1) = y * y ^ m := by ring
      _ ≤ y * hSum m x y := by nlinarith
  rw [hSum_succ]; nlinarith

/-! ### The four-parameter factorisation of a moment difference -/

/-- With `a = gα`, `b = γδ`, `c = gγ`, `d = αδ` (so `ab = cd`), the difference of predicted
moments factors through complete homogeneous sums. -/
theorem pairMoment_split_identity (g al ga de : ℤ) (m : ℕ) :
    pairMoment (m + 2) (g * al) (ga * de) - pairMoment (m + 2) (g * ga) (al * de)
      = (ga - al) * (de - g)
        * ((g * al * ga * de) * hSum m ga al * hSum m de g
            - hSum (m + 1) ga al * hSum (m + 1) de g - 1) := by
  have h1 := sub_mul_hSum m ga al
  have h2 := sub_mul_hSum m de g
  have h3 := sub_mul_hSum (m + 1) ga al
  have h4 := sub_mul_hSum (m + 1) de g
  have key : pairMoment (m + 2) (g * al) (ga * de) - pairMoment (m + 2) (g * ga) (al * de)
      = (g * al * ga * de) * ((ga ^ (m + 1) - al ^ (m + 1)) * (de ^ (m + 1) - g ^ (m + 1)))
        - (ga ^ (m + 2) - al ^ (m + 2)) * (de ^ (m + 2) - g ^ (m + 2)) - (ga - al) * (de - g) := by
    simp only [pairMoment, mul_pow]; ring
  rw [key, ← h1, ← h2, ← h3, ← h4]
  ring

/-- **Positivity of the bracket.**  For `k = m + 3 ≥ 3` and a modulus exceeding the sum of the
four factors, the bracket is strictly positive. -/
theorem pairMoment_bracket_pos {g al ga de : ℤ} (hg : 1 ≤ g) (hal : 1 ≤ al) (hga : 1 ≤ ga)
    (hde : 1 ≤ de) (m : ℕ)
    (hsum : g * al + ga * de + g * ga + al * de < g * al * ga * de) :
    0 < (g * al * ga * de) * hSum (m + 1) ga al * hSum (m + 1) de g
      - hSum (m + 2) ga al * hSum (m + 2) de g - 1 := by
  set A := hSum (m + 1) ga al with hA
  set B := hSum (m + 1) de g with hB
  have hA2 : 2 ≤ A := two_le_hSum (by linarith) hal m
  have hB2 : 2 ≤ B := two_le_hSum (by linarith) hg m
  have hA0 : 0 < A := by linarith
  have hB0 : 0 < B := by linarith
  have hle1 : hSum (m + 2) ga al ≤ (ga + al) * A := hSum_succ_le (by linarith) hal (m + 1)
  have hle2 : hSum (m + 2) de g ≤ (de + g) * B := hSum_succ_le (by linarith) hg (m + 1)
  have hpos1 : 0 < ga + al := by linarith
  have hpos2 : 0 < de + g := by linarith
  have hs1 : 0 < hSum (m + 2) ga al := by
    have := one_le_hSum (x := ga) (y := al) (by linarith) hal (m + 2); linarith
  have hs2 : 0 < hSum (m + 2) de g := by
    have := one_le_hSum (x := de) (y := g) (by linarith) hg (m + 2); linarith
  have hprod : hSum (m + 2) ga al * hSum (m + 2) de g ≤ (ga + al) * A * ((de + g) * B) := by
    calc hSum (m + 2) ga al * hSum (m + 2) de g ≤ ((ga + al) * A) * hSum (m + 2) de g := by
          nlinarith
      _ ≤ ((ga + al) * A) * ((de + g) * B) := by nlinarith
  have hexp : (ga + al) * A * ((de + g) * B) = ((ga + al) * (de + g)) * (A * B) := by ring
  have hsum' : (ga + al) * (de + g) < g * al * ga * de := by nlinarith [hsum]
  have hAB : 2 ≤ A * B := by nlinarith
  nlinarith [hprod, hexp, hsum', hAB, mul_pos hA0 hB0]

/-- **Strict monotonicity in the spread (parametrised form).** -/
theorem pairMoment_spread_strict_param {g al ga de : ℤ} (hg : 1 ≤ g) (hal : 1 ≤ al)
    (hga : 1 ≤ ga) (hde : 1 ≤ de) (halga : al < ga) (hgde : g < de) (m : ℕ)
    (hsum : g * al + ga * de + g * ga + al * de < g * al * ga * de) :
    pairMoment (m + 3) (g * ga) (al * de) < pairMoment (m + 3) (g * al) (ga * de) := by
  have hid := pairMoment_split_identity g al ga de (m + 1)
  have hbr := pairMoment_bracket_pos hg hal hga hde m hsum
  have h1 : 0 < ga - al := by linarith
  have h2 : 0 < de - g := by linarith
  have hpos : 0 < (ga - al) * (de - g)
      * ((g * al * ga * de) * hSum (m + 1) ga al * hSum (m + 1) de g
        - hSum (m + 2) ga al * hSum (m + 2) de g - 1) :=
    mul_pos (mul_pos h1 h2) hbr
  have hm3 : m + 3 = (m + 1) + 2 := by ring
  rw [hm3]
  linarith [hid, hpos]

/-! ### The coordinate-free statement -/

/-- Any two factorisations of the same modulus admit the four-parameter shape. -/
theorem exists_split {a b c d : ℕ} (ha : 0 < a) (hprod : a * b = c * d) (hc : 0 < c) :
    ∃ g al ga de : ℕ, 0 < g ∧ 0 < al ∧ 0 < ga ∧ a = g * al ∧ c = g * ga ∧ d = al * de ∧
      b = ga * de := by
  set g := Nat.gcd a c with hgdef
  have hg0 : 0 < g := Nat.gcd_pos_of_pos_left _ ha
  obtain ⟨al, hal⟩ : g ∣ a := Nat.gcd_dvd_left a c
  obtain ⟨ga, hga⟩ : g ∣ c := Nat.gcd_dvd_right a c
  have hal0 : 0 < al := by
    rcases Nat.eq_zero_or_pos al with rfl | h
    · simp [hal] at ha
    · exact h
  have hga0 : 0 < ga := by
    rcases Nat.eq_zero_or_pos ga with rfl | h
    · simp [hga] at hc
    · exact h
  have hcop : Nat.Coprime al ga := by
    have : Nat.Coprime (a / g) (c / g) := Nat.coprime_div_gcd_div_gcd hg0
    rwa [hal, hga, Nat.mul_div_cancel_left _ hg0, Nat.mul_div_cancel_left _ hg0] at this
  have hkey : al * b = ga * d := by
    have : g * (al * b) = g * (ga * d) := by
      rw [← mul_assoc, ← mul_assoc, ← hal, ← hga]; exact hprod
    exact Nat.eq_of_mul_eq_mul_left hg0 this
  have hdvd : al ∣ d := by
    have : al ∣ ga * d := ⟨b, hkey.symm⟩
    exact (Nat.Coprime.dvd_of_dvd_mul_left hcop this)
  obtain ⟨de, hde⟩ := hdvd
  refine ⟨g, al, ga, de, hg0, hal0, hga0, hal, hga, hde, ?_⟩
  have : al * b = al * (ga * de) := by rw [hkey, hde]; ring
  exact Nat.eq_of_mul_eq_mul_left hal0 this

/-- **The main theorem, coordinate-free.**  For every `k ≥ 3`, among factorisations `N = ab`
of a modulus with `N > a+b+c+d`, the predicted moment strictly increases with the spread. -/
theorem pairMoment_spread_strict {a b c d : ℕ} (ha : 2 ≤ a) (hac : a < c) (hcd : c ≤ d)
    (hdb : d < b) (hprod : a * b = c * d)
    (hsum : a + b + c + d < a * b) (m : ℕ) :
    pairMoment (m + 3) (c : ℤ) (d : ℤ) < pairMoment (m + 3) (a : ℤ) (b : ℤ) := by
  obtain ⟨g, al, ga, de, hg0, hal0, hga0, hAa, hCc, hDd, hBb⟩ :=
    exists_split (a := a) (b := b) (c := c) (d := d) (by omega) hprod (by omega)
  have hde0 : 0 < de := by
    rcases Nat.eq_zero_or_pos de with rfl | h
    · simp [hDd] at hcd; omega
    · exact h
  subst hAa hCc hDd hBb
  have halga : al < ga := by
    by_contra h
    push_neg at h
    exact absurd hac (by nlinarith)
  have hgde : g < de := by
    by_contra h
    push_neg at h
    have : g * ga ≤ al * de → False := by
      intro _
      nlinarith [hac, hcd]
    exact this (by omega)
  have hgZ : (1 : ℤ) ≤ (g : ℤ) := by exact_mod_cast hg0
  have halZ : (1 : ℤ) ≤ (al : ℤ) := by exact_mod_cast hal0
  have hgaZ : (1 : ℤ) ≤ (ga : ℤ) := by exact_mod_cast hga0
  have hdeZ : (1 : ℤ) ≤ (de : ℤ) := by exact_mod_cast hde0
  have halgaZ : (al : ℤ) < (ga : ℤ) := by exact_mod_cast halga
  have hgdeZ : (g : ℤ) < (de : ℤ) := by exact_mod_cast hgde
  have hsumZ : (g : ℤ) * al + (ga : ℤ) * de + (g : ℤ) * ga + (al : ℤ) * de
      < (g : ℤ) * al * ga * de := by
    have : ((g * al + ga * de + g * ga + al * de : ℕ) : ℤ) < ((g * al * (ga * de) : ℕ) : ℤ) := by
      exact_mod_cast hsum
    push_cast at this ⊢
    linarith
  have := pairMoment_spread_strict_param hgZ halZ hgaZ hdeZ halgaZ hgdeZ m hsumZ
  push_cast
  convert this using 2

/-- For `N ≥ 31` the side condition `a+b+c+d < N` is automatic. -/
theorem sum_lt_of_thirtyone_le {a b c d : ℕ} (ha : 2 ≤ a) (hac : a < c) (hcd : c ≤ d)
    (hab : a ≤ b) (hprod : a * b = c * d) (hN : 31 ≤ a * b) : a + b + c + d < a * b := by
  have hc3 : 3 ≤ c := by omega
  have h1 : 2 * (a + b) ≤ 4 + a * b := by nlinarith [Nat.sub_add_cancel ha]
  have h2 : 3 * (c + d) ≤ 9 + c * d := by nlinarith
  have h3 : c * d = a * b := hprod.symm
  omega

/-- **Every moment of order `k ≥ 3` separates factorisations.**  For a modulus `N ≥ 31`, two
nontrivial factorisations with the same `k`-th predicted moment coincide. -/
theorem pairMoment_injective_of_three_le {a b c d : ℕ} (ha : 2 ≤ a) (hab : a ≤ b) (hc : 2 ≤ c)
    (hcd : c ≤ d) (hprod : a * b = c * d) (hN : 31 ≤ a * b) (m : ℕ)
    (hm : pairMoment (m + 3) (a : ℤ) (b : ℤ) = pairMoment (m + 3) (c : ℤ) (d : ℤ)) :
    a = c ∧ b = d := by
  have hac : a = c := by
    rcases lt_trichotomy a c with hlt | heq | hgt
    · have hdb : d < b := by nlinarith
      have hsum := sum_lt_of_thirtyone_le ha hlt hcd hab hprod hN
      exact absurd hm (by have := pairMoment_spread_strict ha hlt hcd hdb hprod hsum m; linarith)
    · exact heq
    · have hbd : b < d := by nlinarith
      have hsum := sum_lt_of_thirtyone_le hc hgt hab hcd hprod.symm (by omega)
      exact absurd hm.symm
        (by have := pairMoment_spread_strict hc hgt hab hbd hprod.symm hsum m; linarith)
  refine ⟨hac, ?_⟩
  have ha0 : 0 < a := by omega
  have : a * b = a * d := by rw [hprod, hac]
  exact Nat.eq_of_mul_eq_mul_left ha0 this

/-! ### Removing the side condition: the seven exceptional quadruples

The hypothesis `a+b+c+d < ab` used above fails for exactly seven quadruples, all of them with
`a = 2` and `b = N/2`:

`(N;a,b,c,d) = (12;2,6,3,4), (16;2,8,4,4), (18;2,9,3,6), (20;2,10,4,5), (24;2,12,3,8),`
`(24;2,12,4,6), (30;2,15,3,10)`.

For each of them the *base* inequality `tailMoment 3 c d < b ^ 3` still holds (the tightest is
`215 < 216` for `(6;3,4)`), and a crude induction `tailMoment (k+1) c d ≤ d · tailMoment k c d`
with `d < b` propagates it to every `k ≥ 3`.  This removes the side condition entirely. -/

/-- The part of `pairMoment` that does not depend on the modulus:
`tailMoment k a b = a^k(b−1) + b^k(a−1) + (a−1)(b−1)`, so that
`pairMoment k a b = tailMoment k a b + N^k`. -/
def tailMoment (k : ℕ) (a b : ℤ) : ℤ := a ^ k * (b - 1) + b ^ k * (a - 1) + (a - 1) * (b - 1)

lemma pairMoment_eq_tailMoment (k : ℕ) (a b : ℤ) :
    pairMoment k a b = tailMoment k a b + (a * b) ^ k := rfl

/-- Crude growth control: raising the order multiplies the tail by at most `d`. -/
lemma tailMoment_step {c d : ℤ} (hc : 3 ≤ c) (hcd : c ≤ d) (k : ℕ) :
    tailMoment (k + 1) c d ≤ d * tailMoment k c d := by
  have hd : (3:ℤ) ≤ d := le_trans hc hcd
  have hck : (0:ℤ) ≤ c ^ k := by positivity
  have hprod : (0:ℤ) ≤ (c - 1) * (d - 1) := by nlinarith
  have h1 : c ^ (k + 1) * (d - 1) ≤ d * (c ^ k * (d - 1)) := by
    have hcc : c ^ (k + 1) = c * c ^ k := by ring
    rw [hcc]
    have : (0:ℤ) ≤ c ^ k * (d - 1) := by nlinarith
    nlinarith
  have h2 : d ^ (k + 1) * (c - 1) = d * (d ^ k * (c - 1)) := by ring
  have h3 : (c - 1) * (d - 1) ≤ d * ((c - 1) * (d - 1)) := by nlinarith
  simp only [tailMoment]
  linarith

/-- If the base inequality `tailMoment 3 c d < b^3` holds and `d < b`, it propagates upward. -/
lemma tailMoment_lt_pow {c d b : ℤ} (hc : 3 ≤ c) (hcd : c ≤ d) (hdb : d < b)
    (hbase : tailMoment 3 c d < b ^ 3) (m : ℕ) : tailMoment (m + 3) c d < b ^ (m + 3) := by
  have hd : (3:ℤ) ≤ d := le_trans hc hcd
  have hb0 : (0:ℤ) < b := by linarith
  induction m with
  | zero => simpa using hbase
  | succ n ih =>
      have hstep := tailMoment_step (c := c) (d := d) hc hcd (n + 3)
      have hb : (0:ℤ) < b ^ (n + 3) := by positivity
      have hpos : (0:ℤ) ≤ tailMoment (n + 3) c d := by
        have h1 : (0:ℤ) ≤ c ^ (n + 3) * (d - 1) := by
          nlinarith [pow_pos (show (0:ℤ) < c by linarith) (n + 3)]
        have h2 : (0:ℤ) ≤ d ^ (n + 3) * (c - 1) := by
          nlinarith [pow_pos (show (0:ℤ) < d by linarith) (n + 3)]
        have h3 : (0:ℤ) ≤ (c - 1) * (d - 1) := by nlinarith
        simp only [tailMoment]; linarith
      calc tailMoment (n + 1 + 3) c d = tailMoment ((n + 3) + 1) c d := by ring_nf
        _ ≤ d * tailMoment (n + 3) c d := hstep
        _ < b * b ^ (n + 3) := by nlinarith [ih]
        _ = b ^ (n + 1 + 3) := by ring

/-- The exceptional case `a = 2`: the spread inequality holds for every `k ≥ 3` as soon as the
base case does, with no condition relating `N` to `a+b+c+d`. -/
theorem pairMoment_exceptional {b c d : ℤ} (hc : 3 ≤ c) (hcd : c ≤ d) (hdb : d < b)
    (hprod : 2 * b = c * d) (hbase : tailMoment 3 c d < b ^ 3) (m : ℕ) :
    pairMoment (m + 3) c d < pairMoment (m + 3) 2 b := by
  have hd : (3:ℤ) ≤ d := le_trans hc hcd
  have hb : (3:ℤ) < b := lt_of_le_of_lt hd hdb
  have key := tailMoment_lt_pow hc hcd hdb hbase m
  have hpow : ((2:ℤ) * b) ^ (m + 3) = (c * d) ^ (m + 3) := by rw [hprod]
  have hexp : tailMoment (m + 3) 2 b = 2 ^ (m + 3) * (b - 1) + b ^ (m + 3) + (b - 1) := by
    simp only [tailMoment]; ring
  have hpos : (0:ℤ) < 2 ^ (m + 3) * (b - 1) + (b - 1) := by
    have h1 : (0:ℤ) < b - 1 := by linarith
    have h2 : (0:ℤ) < (2:ℤ) ^ (m + 3) := by positivity
    nlinarith
  rw [pairMoment_eq_tailMoment, pairMoment_eq_tailMoment, hexp, hpow]
  linarith

/-- **Classification of the exceptional quadruples.**  For any two nontrivial factorisations
`ab = cd` of the same modulus with `2 ≤ a < c ≤ d < b`, either the side condition
`a+b+c+d < ab` holds, or the quadruple is one of exactly seven. -/
theorem exceptional_quadruple_classification {a b c d : ℕ} (ha : 2 ≤ a) (hac : a < c)
    (hcd : c ≤ d) (hdb : d < b) (hprod : a * b = c * d) :
    (a = 2 ∧ b = 6 ∧ c = 3 ∧ d = 4) ∨ (a = 2 ∧ b = 8 ∧ c = 4 ∧ d = 4) ∨
    (a = 2 ∧ b = 9 ∧ c = 3 ∧ d = 6) ∨ (a = 2 ∧ b = 10 ∧ c = 4 ∧ d = 5) ∨
    (a = 2 ∧ b = 12 ∧ c = 3 ∧ d = 8) ∨ (a = 2 ∧ b = 12 ∧ c = 4 ∧ d = 6) ∨
    (a = 2 ∧ b = 15 ∧ c = 3 ∧ d = 10) ∨ (a + b + c + d < a * b) := by
  by_cases h31 : 31 ≤ a * b
  · have := sum_lt_of_thirtyone_le ha hac hcd (show a ≤ b by omega) hprod h31
    exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr this))))))
  · have hle : a * b ≤ 30 := by omega
    have ha5 : a ≤ 5 := by nlinarith
    have hc5 : c ≤ 5 := by nlinarith
    have hb : b ≤ 15 := by nlinarith
    have hd : d ≤ 10 := by nlinarith
    interval_cases a <;> interval_cases c <;> omega

/-- **The side condition is unnecessary.**  For every `k ≥ 3` and every modulus, the predicted
moment is strictly increasing in the spread of the factorisation. -/
theorem pairMoment_spread_strict_unconditional {a b c d : ℕ} (ha : 2 ≤ a) (hac : a < c)
    (hcd : c ≤ d) (hdb : d < b) (hprod : a * b = c * d) (m : ℕ) :
    pairMoment (m + 3) (c : ℤ) (d : ℤ) < pairMoment (m + 3) (a : ℤ) (b : ℤ) := by
  rcases exceptional_quadruple_classification ha hac hcd hdb hprod with
    ⟨e1, e2, e3, e4⟩ | ⟨e1, e2, e3, e4⟩ | ⟨e1, e2, e3, e4⟩ | ⟨e1, e2, e3, e4⟩ |
    ⟨e1, e2, e3, e4⟩ | ⟨e1, e2, e3, e4⟩ | ⟨e1, e2, e3, e4⟩ | hsum
  all_goals try
    (subst_vars
     push_cast
     exact pairMoment_exceptional (by norm_num) (by norm_num) (by norm_num) (by norm_num)
       (by norm_num [tailMoment]) m)
  exact pairMoment_spread_strict ha hac hcd hdb hprod hsum m

/-- **Every moment of order `k ≥ 3` separates factorisations — unconditionally.**  For any
modulus whatsoever, two nontrivial factorisations with the same `k`-th predicted moment
coincide.  This removes the `N ≥ 31` hypothesis of `pairMoment_injective_of_three_le`. -/
theorem pairMoment_injective_of_three_le_unconditional {a b c d : ℕ} (ha : 2 ≤ a) (hab : a ≤ b)
    (hc : 2 ≤ c) (hcd : c ≤ d) (hprod : a * b = c * d) (m : ℕ)
    (hm : pairMoment (m + 3) (a : ℤ) (b : ℤ) = pairMoment (m + 3) (c : ℤ) (d : ℤ)) :
    a = c ∧ b = d := by
  have hac : a = c := by
    rcases lt_trichotomy a c with hlt | heq | hgt
    · have hdb : d < b := by nlinarith
      exact absurd hm
        (by have := pairMoment_spread_strict_unconditional ha hlt hcd hdb hprod m; linarith)
    · exact heq
    · have hbd : b < d := by nlinarith
      exact absurd hm.symm
        (by have := pairMoment_spread_strict_unconditional hc hgt hab hbd hprod.symm m; linarith)
  refine ⟨hac, ?_⟩
  have ha0 : 0 < a := by omega
  have : a * b = a * d := by rw [hprod, hac]
  exact Nat.eq_of_mul_eq_mul_left ha0 this

/-! ### The oracle corollary: any `k ≥ 3` moment factors the modulus -/

/-- **A single `k`-th moment value factors a semiprime, for every `k ≥ 3`.**  Given the value
`M_k(N)` of the `k`-th gcd moment of `N = pq`, the *only* factorisation `N = ab` with
`2 ≤ a ≤ b` whose predicted moment matches is the true one.  So a moment oracle plus a scan of
candidate factorisations identifies `p` and `q`; the content is that no decoy factorisation can
match, which for `k = 2` is false (`N = 28`, `N = 36`). -/
theorem factorization_from_moment_oracle {k : ℕ} (hk : 3 ≤ k) {p q : ℕ} (hp : p.Prime)
    (hq : q.Prime) (hpq : p < q) {a b : ℕ} (ha : 2 ≤ a) (hab : a ≤ b) (hprod : a * b = p * q)
    (hmatch : pairMoment k (a : ℤ) (b : ℤ) = (gcdMoment k (p * q) : ℤ)) : a = p ∧ b = q := by
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 3 := ⟨k - 3, by omega⟩
  have htrue : pairMoment (m + 3) (p : ℤ) (q : ℤ) = (gcdMoment (m + 3) (p * q) : ℤ) :=
    pairMoment_eq_gcdMoment hp hq (by omega) (m + 3)
  have hpq' : pairMoment (m + 3) (p : ℤ) (q : ℤ) = pairMoment (m + 3) (a : ℤ) (b : ℤ) := by
    rw [htrue, hmatch]
  have := pairMoment_injective_of_three_le_unconditional hp.two_le (le_of_lt hpq) ha hab
    hprod.symm m hpq'
  exact ⟨this.1.symm, this.2.symm⟩

/-- **Capstone: every moment of order `k ≥ 1` factors a distinct-prime semiprime.**  Combining
the trace argument at `k = 1`, the collision classification at `k = 2` and the spread
monotonicity at `k ≥ 3`: for every `k ≥ 1`, the true factorisation is the unique candidate
`N = ab` with `2 ≤ a ≤ b` whose predicted `k`-th moment equals the observed one.  So the
gcd-moment family carries *complete* information at every order; what separates the orders is
only the cost of obtaining the moment (`gcdVariance_theta`). -/
theorem factorization_from_any_moment {k : ℕ} (hk : 1 ≤ k) {p q : ℕ} (hp : p.Prime)
    (hq : q.Prime) (hpq : p < q) {a b : ℕ} (ha : 2 ≤ a) (hab : a ≤ b) (hprod : a * b = p * q)
    (hmatch : pairMoment k (a : ℤ) (b : ℤ) = (gcdMoment k (p * q) : ℤ)) : a = p ∧ b = q := by
  match k, hk with
  | 1, _ => exact factorization_from_first_moment hp hq hpq hab hprod hmatch
  | 2, _ => exact factorization_from_second_moment hp hq hpq ha hab hprod hmatch
  | (m + 3), _ =>
      exact factorization_from_moment_oracle (by omega) hp hq hpq ha hab hprod hmatch

/-- Sanity check on the tightest small instance, `36 = 4·9 = 6·6`. -/
example : pairMoment 3 6 6 < pairMoment 3 4 9 := by norm_num [pairMoment]
example : pairMoment 5 6 6 < pairMoment 5 4 9 := by norm_num [pairMoment]

end GCDMoment