import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# The usefulness condition is VACUOUS inside the operative box

`SquareDiff.lean` proved the reduction: writing `a - b = k*p` and `a + b = l*q`
for `N = p*q`, the method's output is `gcd(k*p, p*q) = p*gcd(k,q)`, so it
succeeds **iff `q ∤ k`**. RESEARCH.md §7 then advertised `q ∤ k` as "the entire
succeed/fail content of the family" — a single condition carrying all the
information, and the §8 item-7 open question was built on top of it
("a heuristic that finds a convergent but cannot check `q ∤ k` would need a
verifier").

**That reading is wrong, and this file is the correction.**

`q ∤ k` is a condition on `k` *in isolation*, but the box bounds `k` by `2*X/p`.
Whenever the box is narrower than the modulus — `2*X < p*q`, which holds for
every method in the literature by a wide margin (Fermat, Lehman, SQUFOF, Harvey,
GFHP all use `X << N`) — the box **forces** `q ∤ k` for free. It is not a filter
the search must satisfy; it is a *theorem about the box*.

So the succeed/fail content is not an arithmetic condition on `k` at all. It is
the **degeneracy** `k = 0` (i.e. `a = b`), or symmetrically `l = 0` (i.e.
`a = -b`) — the trivial Fermat-type points carrying no factor information. This
is **sharper** than the §7 claim and is a **self-correction**: §7 overstated what
its own theorem said, and §8 item 7 was aimed at a verifier that provably does
not exist.

## What is and is not formalised here

* **Formalised (0 `sorry`, 0 `axiom`):** the five theorems below.
  `useful_needs_N` and `useful_needs_N_symm` use **no primality assumption at
  all** — the obstruction is a pure size argument, which is why the statement is
  this clean and why it holds for *any* `N = p*q`, semiprime or not.
* **Not formalised:** the ℤ box arithmetic of `box_iff` (that lives in
  `SquareDiff.lean`). These are the ℕ non-negative shadow: with `|x| = x` the two
  box inequalities `|k*p ± l*q| <= 2*X` collapse to the single
  `k*p + l*q <= 2*X`.
* **Not claimed:** that this improves any method. It removes a *false* obstruction
  from the open-threads list, which is a subtraction, not an advance.
-/

namespace Crypto.FactoringBarrier.VacuousUsefulness

/-- The gcd identity of the reduction, restated locally (the `Thm_*.lean` files
in this workspace are standalone roots, so this is not imported). -/
private theorem gcd_formula (p q k : ℕ) :
    Nat.gcd (k * p) (p * q) = p * Nat.gcd k q := by
  rw [Nat.mul_comm k p, Nat.gcd_mul_left]

/-- `Nat.gcd k q = q` iff `q ∣ k`. Same reason for restating. -/
private theorem gcd_eq_q_iff (q k : ℕ) : Nat.gcd k q = q ↔ q ∣ k := by
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

/-- **A `k` divisible by `q` is too big for any box narrower than `N`.**

This is the whole file in one lemma, and it needs no primality: if `q ∣ k` and
`k > 0` then `k = q*c` with `c ≥ 1`, so `k*p = c*(p*q) ≥ p*q`. Any pair with
`k*p + l*q <= 2*X < p*q` therefore cannot have such a `k`. -/
theorem useful_needs_N (k p q : ℕ) (hk : 0 < k) (h : q ∣ k) : p * q ≤ k * p := by
  obtain ⟨c, hc⟩ := h
  have hcpos : 1 ≤ c := by
    rcases Nat.eq_zero_or_pos c with hz | hpos
    · rw [hz, mul_zero] at hc
      rw [hc] at hk
      exact (Nat.lt_irrefl 0 hk).elim
    · exact hpos
  have hstep : p * q ≤ (p * q) * c := by
    calc p * q = 1 * (p * q) := by ring
      _ ≤ c * (p * q) := Nat.mul_le_mul_right (p * q) hcpos
      _ = (p * q) * c := by ring
  calc p * q ≤ (p * q) * c := hstep
    _ = p * (q * c) := by ring
    _ = p * k := by rw [hc]
    _ = k * p := Nat.mul_comm p k

/-- **The mirror lemma: an `l` divisible by `p` is equally too big.** -/
theorem useful_needs_N_symm (l p q : ℕ) (hl : 0 < l) (h : p ∣ l) : p * q ≤ l * q := by
  obtain ⟨c, hc⟩ := h
  have hcpos : 1 ≤ c := by
    rcases Nat.eq_zero_or_pos c with hz | hpos
    · rw [hz, mul_zero] at hc
      rw [hc] at hl
      exact (Nat.lt_irrefl 0 hl).elim
    · exact hpos
  have hstep : p * q ≤ (p * q) * c := by
    calc p * q = 1 * (p * q) := by ring
      _ ≤ c * (p * q) := Nat.mul_le_mul_right (p * q) hcpos
      _ = (p * q) * c := by ring
  calc p * q ≤ (p * q) * c := hstep
    _ = q * (p * c) := by ring
    _ = q * l := by rw [hc]
    _ = l * q := Nat.mul_comm q l

/-- **★ Main theorem: inside any box narrower than `N`, `q ∤ k` is automatic.**

`2*X < p*q` is the operative-box hypothesis, satisfied by every method in the
literature by a wide margin. So the "condition" that §7 called the entire
succeed/fail content of the family **never filters anything**. -/
theorem box_nmid (k l p q X : ℕ) (hk : 0 < k)
    (hN : 2 * X < p * q) (hb : k * p + l * q ≤ 2 * X) : ¬ q ∣ k := by
  intro hd
  have hbig := useful_needs_N k p q hk hd
  have hkp : k * p ≤ 2 * X := by
    have h := Nat.le_add_right (k * p) (l * q)
    linarith
  have hlt : 2 * X < p * q := hN
  linarith

/-- **The mirror: `p ∤ l` is equally automatic.** -/
theorem box_nmid_symm (k l p q X : ℕ) (hl : 0 < l)
    (hN : 2 * X < p * q) (hb : k * p + l * q ≤ 2 * X) : ¬ p ∣ l := by
  intro hd
  have hbig := useful_needs_N_symm l p q hl hd
  have hlq : l * q ≤ 2 * X := by
    have h : l * q ≤ k * p + l * q := by
      have h2 := Nat.le_add_right (l * q) (k * p)
      rwa [add_comm] at h2
    linarith
  have hlt : 2 * X < p * q := hN
  linarith

/-- **★★ The corrected succeed/fail content: the output is `N` iff `k = 0`.**

Inside the operative box `q ∤ k` is forced, so the gcd is never `N` for a
nonzero `k`. The *only* way the family returns the trivial answer is the
degeneracy `k = 0`, i.e. `a = b`. This replaces the §7 claim "`q ∤ k` is the
entire succeed/fail content" with the strictly sharper "`k = 0` is". -/
theorem failure_iff_k_zero (k l p q X : ℕ) (hp : 0 < p) (_hq : 0 < q)
    (hN : 2 * X < p * q) (hb : k * p + l * q ≤ 2 * X) :
    Nat.gcd (k * p) (p * q) = p * q ↔ k = 0 := by
  constructor
  · intro h
    by_contra hk0
    have hk : 0 < k := Nat.pos_of_ne_zero hk0
    have hg : Nat.gcd k q = q := by
      rw [gcd_formula] at h
      exact Nat.mul_left_cancel hp h
    have hd : q ∣ k := (gcd_eq_q_iff q k).mp hg
    exact box_nmid k l p q X hk hN hb hd
  · intro h
    subst h
    simp

end Crypto.FactoringBarrier.VacuousUsefulness
