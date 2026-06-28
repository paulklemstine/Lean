import Catalog.FINAL.Physics.ErdosStraus
import Catalog.FINAL.Physics.ErdosStrausObstruction

/-!
# The residual class `p ≡ 1 (mod 8)`

The four elementary families (`es_even`, `es_three_dvd`, `es_three_mod_four`,
`es_five_mod_eight`) and the prime-core reduction
(`Catalog/FINAL/Physics/ErdosStraus.lean`) settle every `n ≥ 2` whose smallest
prime factor is **not** `≡ 1 (mod 8)`.  The obstruction analysis
(`Catalog/FINAL/Physics/ErdosStrausObstruction.lean`) shows that the elementary
*halving* family fails exactly on `n ≡ 1 (mod 8)`, leaving this as the sole
residual residue class.

This file records the genuine, machine-checked progress that can be made on the
residual class.

## What is proved

* `es_two_mod_three` — **an infinite parametric family.**  For every
  `n ≡ 1 (mod 4)` with `n ≡ 2 (mod 3)` (equivalently `n ≡ 5 (mod 12)`),
  setting `x = (n+3)/4`, `y = n·(x+1)/3`, `z = x·y` gives the closed-form
  identity `4/n = 1/x + 1/y + 1/(x·y)`.  In particular this settles every prime
  `p ≡ 17 (mod 24)`, i.e. every prime in the residual class `p ≡ 1 (mod 8)` that
  is additionally `≡ 2 (mod 3)`  (`oneModEight_two_mod_three`).

* `one_mod_eight_solver` — **a verified bounded solver.**  Every prime
  `p ≡ 1 (mod 8)` with `p < 10000` is solvable, witnessed by the bounded
  Egyptian-fraction search `esWit` and certified by `native_decide`.

## What remains open

A *single* closed-form parametric solution valid for **all** primes
`p ≡ 1 (mod 8)` is **not known**: this is precisely the genuinely open core of the
Erdős–Straus conjecture.  Mordell's residue analysis shows the conjecture can fail
to be settled by elementary families only for `n` congruent to one of the squares
`{1, 121, 169, 289, 361, 529} (mod 840)`, all of which lie in `n ≡ 1 (mod 8)`.
The unconditional statement is recorded honestly below as the unproved
proposition `OneModEightConjecture`; we do **not** claim a proof of it.
-/

namespace ErdosStraus

/-
**Infinite family for `n ≡ 5 (mod 12)`.**  For `n ≡ 1 (mod 4)` and
`n ≡ 2 (mod 3)`, with `x = (n+3)/4` and `y = n·(x+1)/3`, one has the closed form
`4/n = 1/x + 1/y + 1/(x·y)`.

This is the classical Mordell family for the residue `n ≡ 2 (mod 3)`, specialised
to the odd case.  It covers an infinite subset of the residual class
`n ≡ 1 (mod 8)`, namely `n ≡ 17 (mod 24)`.
-/
theorem es_two_mod_three (n : ℕ) (h4 : n % 4 = 1) (h3 : n % 3 = 2) (hn : 2 ≤ n) :
    ErdosStrausSolution n := by
  obtain ⟨x, hx⟩ : ∃ x : ℕ, 4 * x = n + 3 ∧ 0 < x := by
    exact ⟨ ( n + 3 ) / 4, by omega, by omega ⟩;
  obtain ⟨y, hy⟩ : ∃ y : ℕ, 3 * y = n * (x + 1) ∧ 0 < y := by
    exact ⟨ n * ( x + 1 ) / 3, by rw [ Nat.mul_div_cancel' ] ; exact Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, Nat.mul_mod, h3, show x % 3 = 2 by omega ] ), Nat.div_pos ( by nlinarith ) ( by norm_num ) ⟩;
  convert ErdosStraus.es_of_nat n x y ( x * y ) hx.2 hy.2 ( Nat.mul_pos hx.2 hy.2 ) ( by linarith ) _ using 1;
  grind

/-- The infinite family applies to every prime `p ≡ 1 (mod 8)` that is `≡ 2 (mod 3)`,
i.e. `p ≡ 17 (mod 24)`. -/
theorem oneModEight_two_mod_three (p : ℕ) (hp : p.Prime) (h8 : p % 8 = 1)
    (h3 : p % 3 = 2) : ErdosStrausSolution p :=
  es_two_mod_three p (by omega) h3 hp.two_le

/-- Every prime `q ≡ 1 (mod 8)` below `10000` passes the bounded Egyptian-fraction
search `esWit`.  Verified by `native_decide`. -/
theorem es_witTable_oneModEight :
    ∀ q, q < 10000 → Nat.Prime q → q % 8 = 1 → esGood q = true := by
  native_decide

/-- **Bounded solver for the residual class.**  Every prime `p ≡ 1 (mod 8)` with
`p < 10000` admits an explicit Erdős–Straus solution, produced by the bounded
search `esWit` and certified computationally. -/
theorem one_mod_eight_solver (p : ℕ) (hp : p.Prime) (h8 : p % 8 = 1) (hlt : p < 10000) :
    ErdosStrausSolution p := by
  have hg := es_witTable_oneModEight p hlt hp h8
  unfold esGood at hg
  cases hw : esWit p with
  | none => rw [hw] at hg; simp at hg
  | some t =>
    obtain ⟨x, y, z⟩ := t
    rw [hw] at hg
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hg
    obtain ⟨⟨⟨hx, hy⟩, hz⟩, heq⟩ := hg
    exact es_of_nat p x y z hx hy hz hp.pos heq

/-- **Unconditional residual statement (OPEN).**  The assertion that *every* prime
`p ≡ 1 (mod 8)` is Erdős–Straus solvable.  This is the genuinely open core of the
conjecture; no proof is claimed here.  It is stated only to name the target
precisely.  By `one_mod_eight_solver` it holds for all such `p < 10000`, and by
`oneModEight_two_mod_three` it holds for all such `p ≡ 2 (mod 3)`. -/
def OneModEightConjecture : Prop :=
  ∀ p : ℕ, p.Prime → p % 8 = 1 → ErdosStrausSolution p

end ErdosStraus