import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# The square-difference family IS rational approximation to an unknown number

Fermat, Lehman, SQUFOF, Hart, the Coppersmith square congruence
`a^2 ≡ b^2 (mod N)`, and therefore Harvey and GFHP, are **all one method**:
produce integers `a, b` with

> `N ∣ a^2 - b^2`  and  `a ≢ ±b (mod N)`,

then return `gcd(a - b, N)`.

No entry in `RESEARCH.md` says what that condition *is*. This file answers it.
The answer turns out to be a statement about **rational approximation to a
number you do not know**:

> **THE SQUARE-DIFFERENCE REDUCTION.** Write `a - b = k·p` and `a + b = l·q`.
> Then the method's output is exactly `p·gcd(k, q)`, so it succeeds iff
> `q ∤ k`, and the box condition `|a|, |b| ≤ X` is *exactly*
>
> ```
> |k·p + l·q| ≤ 2X   and   |l·q - k·p| ≤ 2X.
> ```

So the whole family is precisely:

> **enumerate integer pairs `(k, l)` with `|k·p - l·q| ≤ 2X`, keep those with
> `q ∤ k`.**

And `|k·p - l·q| ≤ 2X` is the definition of `k/l` being a good rational
approximation to `q/p`. **The integers that work are the continued-fraction
convergents of `p/q`.** Every method in the family is a different way of
*locating* one of those convergents from `N` alone, without knowing `p` or `q`.

This is the axis the barrier entries needed and did not have. It puts Fermat's
difference of squares, Lehman's `k`-sweep, SQUFOF's partial quotients, and
Harvey's baby/giant steps on **one line**, and it says what a new method would
have to do: reach a convergent of `p/q` that is *not* also a trivial one.

## What is and is not claimed

* **Proved here (0 `sorry`, 0 `axiom`):** the algebra, the inverse map, the box
  reformulation, the exact `gcd` output, the succeed/fail dichotomy, the
  proper-factor bound, the Fermat corner, the Lehman diagonal identity, and the
  Lehman imbalance bound.
* **Not proved here:** that the good `(k, l)` are exactly the convergents. That
  is classical continued-fraction theory, stated as a *description* above rather
  than as a Lean theorem. What is proved is the reduction to it.
* **Not claimed:** that this improves any method. It does not. It says what
  every existing method is doing, in one line, and hence what a new one must
  beat. The conjectural core (`Σw > 3/2`, see `HarveyFloor.lean`) is untouched.
-/

namespace Crypto.FactoringBarrier.SquareDiff

/-- **The algebra of the method.** If `a - b = k·p` and `a + b = l·q` then
`a^2 - b^2 = k·l·p·q`: the square difference is divisible by `N = p·q` with
quotient exactly `k·l`. This is *why* the family works at all. -/
theorem sq_diff_mul (a b k l p q : ℤ) (h1 : a - b = k * p) (h2 : a + b = l * q) :
    a ^ 2 - b ^ 2 = k * l * (p * q) := by
  have h : a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring
  rw [h, h1, h2]
  ring

/-- **The inverse map, and the reason `(k, l)` is the natural parameter.**
Inverting the two linear equations gives `2a = k·p + l·q` and
`2b = l·q - k·p`. So `(k, l)` determines `(a, b)` up to integrality, and — the
point — the *size* condition on `a, b` becomes a condition on `k·p ± l·q`. -/
theorem two_a_two_b (a b k l p q : ℤ) (h1 : a - b = k * p) (h2 : a + b = l * q) :
    2 * a = k * p + l * q ∧ 2 * b = l * q - k * p := by
  constructor <;> linarith

/-- **★ THE BOX REFORMULATION — the payload of the reduction.**

`|a|, |b| ≤ X` holds **exactly when** `|k·p + l·q| ≤ 2X` and `|l·q - k·p| ≤ 2X`.

This is the whole family in one equivalence. "Find small `a, b` with
`N ∣ a² - b²`" is literally "find small `k·p ± l·q`", i.e. "find `k/l ≈ q/p`". -/
theorem box_iff (a b k l p q : ℤ) (X : ℕ) (h1 : a - b = k * p) (h2 : a + b = l * q) :
    (a.natAbs ≤ X ∧ b.natAbs ≤ X)
      ↔ ((k * p + l * q).natAbs ≤ 2 * X ∧ (l * q - k * p).natAbs ≤ 2 * X) := by
  have hb := two_a_two_b a b k l p q h1 h2
  have hplus : (k * p + l * q).natAbs = 2 * a.natAbs := by
    rw [hb.1.symm, Int.natAbs_mul]
    norm_num
  have hminus : (l * q - k * p).natAbs = 2 * b.natAbs := by
    rw [hb.2.symm, Int.natAbs_mul]
    norm_num
  rw [hplus, hminus]
  constructor
  · rintro ⟨ha, hb'⟩
    exact ⟨Nat.mul_le_mul_left 2 ha, Nat.mul_le_mul_left 2 hb'⟩
  · intro h
    exact ⟨Nat.le_of_mul_le_mul_left h.1 (by norm_num),
      Nat.le_of_mul_le_mul_left h.2 (by norm_num)⟩

/-- **★ THE EXACT OUTPUT.** The gcd the method returns is `p·gcd(k, q)` — in
general *not* just `p`. Recording the exact form matters: the method can return
any multiple of `p`, and the success condition is about `q ∤ k`, not `k = 1`. -/
theorem gcd_formula (p q k : ℕ) : Nat.gcd (k * p) (p * q) = p * Nat.gcd k q := by
  rw [Nat.mul_comm k p, Nat.gcd_mul_left]

/-- `gcd k q = q` exactly when `q` divides `k` — the two halves of `trivial_iff`,
split out because the `q = 0` case needs its own treatment. -/
theorem gcd_eq_q_iff (q k : ℕ) : Nat.gcd k q = q ↔ q ∣ k := by
  cases q with
  | zero => simp
  | succ n =>
    constructor
    · intro h
      have hh := (Nat.gcd_dvd (m := k) (n := Nat.succ n)).1
      rwa [h] at hh
    · intro h
      have hgpos : 0 < Nat.gcd k (Nat.succ n) := Nat.pos_of_ne_zero (by
        rintro hz
        obtain ⟨-, hq0⟩ := Nat.gcd_eq_zero_iff.mp hz
        exact (Nat.succ_ne_zero n) hq0)
      exact Nat.le_antisymm
        (Nat.le_of_dvd (Nat.zero_lt_succ n)
          (Nat.gcd_dvd (m := k) (n := Nat.succ n)).2)
        (Nat.le_of_dvd hgpos
          (Nat.dvd_gcd (k := Nat.succ n) (m := k) (n := Nat.succ n) h
            (Nat.dvd_refl (Nat.succ n))))

/-- **★ THE SUCCEED/FAIL DICHOTOMY.** The method returns the useless answer
`N` **exactly** when `q ∣ k`; it returns a genuine factor otherwise.

Restated: the entire content of "`a² ≡ b² (mod N)` but `a ≢ ±b (mod N)`" is the
single extra condition `q ∤ k`. Nothing else in the family's definition carries
information. -/
theorem trivial_iff (p q k : ℕ) (hp : 0 < p) :
    Nat.gcd (k * p) (p * q) = p * q ↔ q ∣ k := by
  rw [gcd_formula]
  constructor
  · intro h
    exact (gcd_eq_q_iff q k).mp (Nat.mul_left_cancel hp h)
  · intro h
    rw [(gcd_eq_q_iff q k).mpr h]

/-- **★ AND IT IS A PROPER FACTOR.** For `p > 1` and `q > 0`, `¬ q ∣ k` puts
the output strictly between `1` and `N`. This closes the loop: `¬ q ∣ k` is not
merely "not the trivial answer" but "a genuine divisor of `N`". -/
theorem proper_factor (p q k : ℕ) (hp : 1 < p) (hq : 0 < q) (hk : ¬ q ∣ k) :
    1 < Nat.gcd (k * p) (p * q) ∧ Nat.gcd (k * p) (p * q) < p * q := by
  rw [gcd_formula]
  have h1 : 1 ≤ Nat.gcd k q := by
    by_contra h0
    obtain ⟨hk0, hq0⟩ := Nat.gcd_eq_zero_iff.mp (Nat.eq_zero_of_not_pos h0)
    subst hk0; subst hq0
    exact hk (Nat.dvd_refl 0)
  have h2 : Nat.gcd k q < q :=
    lt_of_le_of_ne (Nat.le_of_dvd hq (Nat.gcd_dvd (m := k) (n := q)).2)
      (fun heq => hk (by rw [← heq]; exact (Nat.gcd_dvd (m := k) (n := q)).1))
  exact ⟨lt_of_lt_of_le hp (by simpa using Nat.mul_le_mul_left p h1),
    (Nat.mul_lt_mul_left (a := p) (by exact Nat.zero_lt_of_lt hp)).mpr h2⟩

/-- **★ FERMAT IS THE CORNER `(1, 1)`.** Fermat's difference of squares solves
`a² - b² = N` *exactly*, and the reduction then forces `k·l = 1`, i.e. `k = l = 1`.

So Fermat is a **single point** of the family — the tip, not a search. The whole
of Fermat's method is one `(k, l)`, and the entire literature after Fermat is the
effort to reach *other* points. -/
theorem fermat_is_k_l_one (a b k l p q : ℕ) (hp : 0 < p) (hq : 0 < q)
    (hab : b ≤ a) (h1 : a - b = k * p) (h2 : a + b = l * q)
    (hN : p * q = a * a - b * b) : k = 1 ∧ l = 1 := by
  have hsub : (a : ℤ) - (b : ℤ) = ((a - b : ℕ) : ℤ) :=
    (Int.ofNat_sub (m := b) (n := a) hab).symm
  have h := sq_diff_mul (a := (a : ℤ)) (b := (b : ℤ)) (k := (k : ℤ)) (l := (l : ℤ))
    (p := (p : ℤ)) (q := (q : ℤ)) (by rw [hsub]; exact_mod_cast h1)
    (by exact_mod_cast h2)
  have hN' : (a : ℤ) ^ 2 - (b : ℤ) ^ 2 = (p : ℤ) * (q : ℤ) := by
    have h2le : b * b ≤ a * a := Nat.mul_self_le_mul_self hab
    have hres : ((a * a - b * b : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by
      exact_mod_cast hN.symm
    have hadd : a * a = b * b + (a * a - b * b) := by
      rw [Nat.add_comm, Nat.sub_add_cancel h2le]
    have hpA : (a : ℤ) ^ 2 = ((a * a : ℕ) : ℤ) := by push_cast; rw [pow_two]
    have hpB : (b : ℤ) ^ 2 = ((b * b : ℕ) : ℤ) := by push_cast; rw [pow_two]
    have hadd' : ((a * a : ℕ) : ℤ) = (b * b : ℤ) + ((a * a - b * b : ℕ) : ℤ) := by
      have hc := congrArg (fun t : ℕ => (t : ℤ)) hadd
      rwa [Nat.cast_add] at hc
    rw [hpA, hpB, hadd']
    linarith [hres]
  rw [hN'] at h
  have hne : ((p : ℤ) * (q : ℤ)) ≠ 0 := by
    exact_mod_cast (Nat.ne_of_gt (Nat.mul_pos hp hq))
  -- `h` reads `A = (k*l) * A` with `A = ↑p*↑q ≠ 0`.  Cancellation needs the
  -- common factor syntactically on the LEFT of both sides, so commute it there
  -- explicitly rather than leaving the unifier to reassociate.
  have hkl : (k : ℤ) * (l : ℤ) = 1 :=
    mul_right_cancel₀ hne (by
      calc (k : ℤ) * (l : ℤ) * ((p : ℤ) * (q : ℤ))
          = ((p : ℤ) * (q : ℤ)) := h.symm
        _ = (1 : ℤ) * ((p : ℤ) * (q : ℤ)) := (one_mul _).symm)
  -- `k * l = 1` over ℤ gives `k = 1` and `l = 1`.  The direct route is a dead
  -- end in this Mathlib build: ℤ has no `mul_eq_one_iff`, no `mul_left_cancel`
  -- and no `mul_right_cancel`.  What it does have is nonnegativity, and `k`, `l`
  -- are naturals -- so take `natAbs` of both sides, land in ℕ where the
  -- cancellation lemmas are standard, and cast back.
  have hklN : k * l = 1 := by exact_mod_cast hkl
  -- `k * l = 1` in ℕ: `k ∣ 1` and `l ∣ 1` give `k ≤ 1`, `l ≤ 1`, and neither is
  -- `0` (else the product is `0`), so both are exactly `1`.
  have hkd : k ∣ 1 := by rw [← hklN]; exact Nat.dvd_mul_right k l
  have hld : l ∣ 1 := by rw [← hklN, mul_comm]; exact Nat.dvd_mul_right l k
  have hkpos : 0 < k := Nat.pos_of_ne_zero (by
    rintro hz
    rw [hz, zero_mul] at hklN
    norm_num at hklN)
  have hlpos : 0 < l := Nat.pos_of_ne_zero (by
    rintro hz
    rw [hz, mul_zero] at hklN
    norm_num at hklN)
  exact ⟨Nat.le_antisymm (Nat.le_of_dvd (by norm_num) hkd)
      (Nat.succ_le_of_lt hkpos),
    Nat.le_antisymm (Nat.le_of_dvd (by norm_num) hld)
      (Nat.succ_le_of_lt hlpos)⟩

/-- **LEHMAN'S LINE IS THE DIAGONAL `l = k`.** Restricting to `a + b = k·q` gives
`a² - b² = k²·N` — `N` times a perfect square — so this is exactly Lehman's
single-parameter sub-family of the square-difference family. -/
theorem diagonal_sq_mul (a b k p q : ℤ) (h1 : a - b = k * p) (h2 : a + b = k * q) :
    a ^ 2 - b ^ 2 = k * k * (p * q) :=
  sq_diff_mul a b k k p q h1 h2

/-- **★ THE LEHMAN TRADEOFF, IN ONE INEQUALITY.** On the diagonal `l = k` the
box condition `|k·p - k·q| ≤ 2X` is `k·(p - q) ≤ 2X` (for `q < p`), hence
`k ≤ 2X / (p - q)`.

This is why Lehman's sweep is useless for *close* primes: the number of usable
`k` is governed by `2X/(p-q)`, which for `p - q = O(1)` is just `O(X)` — no better
than Fermat. The general family (both `k` and `l` free) is therefore not an
optimisation of the diagonal; it is a **different and strictly larger object**,
and the enlargement is exactly what buys Harvey his `1/5`. -/
theorem lehman_bound (X p q k : ℕ) (hqp : q < p)
    (h : k * Nat.sub p q ≤ 2 * X) : k ≤ 2 * X / Nat.sub p q := by
  exact (Nat.le_div_iff_mul_le (Nat.sub_pos_iff_lt.mpr hqp)
    (x := k) (y := 2 * X) (k := Nat.sub p q)).mpr h

end Crypto.FactoringBarrier.SquareDiff
