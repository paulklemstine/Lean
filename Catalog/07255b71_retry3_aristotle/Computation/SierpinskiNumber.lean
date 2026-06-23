import Mathlib

/-!
# 78557 is a Sierpiński number

A Sierpiński number is a natural number `k` such that `k * 2^n + 1` is composite
for every natural number `n`.  We prove that `78557` is a Sierpiński number using a
*covering system*: a finite list of primes together with a global modulus `M = 36`
such that for every `n`, one of the primes divides `78557 * 2^n + 1`.

The covering primes are `{3, 5, 7, 13, 19, 37, 73}` and the global modulus is `M = 36`
(the least common multiple of the multiplicative orders of `2` modulo each prime).

## Structure of the development

The proof is organised in strictly layered fashion to make non-circularity manifest:

* **Layer 1** (`pow_periodic`, `dvd_transfer`): purely arithmetic facts about powers of
  two modulo a prime; these never mention `IsSierpinski`.
* **Layer 2** (`CoveringCert.isSierpinski`): from an abstract covering certificate one
  derives that `cert.k` is a Sierpiński number, using *only* Layer 1.
* **Layer 3** (`cert78557`): the concrete certificate for `k = 78557`, whose data is
  checked by `decide`.
* **Layer 4** (`sierpinski_78557`): the final theorem, obtained by applying Layer 2 to
  Layer 3.

## A note on the residue table

The task statement proposed the periodic residue table
`r ↦ [3,5,7,13,19,37,73, 3,5,7,…]` (period 7).  This table does **not** satisfy the
divisibility requirement `table r ∣ 78557 * 2^r + 1` (it fails for the vast majority of
residues), so it cannot be used.  The table below is the genuine covering table for
`78557` with modulus `36`, computed so that `table r ∣ 78557 * 2^r + 1` for all
`r < 36`.  The mathematics that actually needs to hold (the `divisibility` field) forces
this choice.

## A note on the structure fields

* `dvd_transfer` as literally proposed (with no hypothesis relating `2^M` to `1` mod `p`)
  is false; transferring divisibility from residue `r` to `n ≡ r (mod M)` genuinely
  requires `2^M ≡ 1 [MOD p]`.  That hypothesis is therefore included.
* `CoveringCert` carries an extra field `Mpos : 0 < M`.  Without it the residue `n % M`
  cannot be packaged as an element of `Fin M`, and indeed the conclusion would be false
  for `M = 0`.
-/

namespace Sierpinski

/-- `k` is a Sierpiński number: `k * 2^n + 1` is never prime. -/
def IsSierpinski (k : ℕ) : Prop := ∀ n : ℕ, ¬ Nat.Prime (k * 2 ^ n + 1)

/-! ## Layer 1: arithmetic lemmas (no reference to `IsSierpinski`) -/

/-
If `2^M ≡ 1 [MOD p]`, then `2^n` depends only on `n mod M`.
-/
theorem pow_periodic (M p n : ℕ) (h : 2 ^ M ≡ 1 [MOD p]) :
    2 ^ n ≡ 2 ^ (n % M) [MOD p] := by
  rw [ ← Nat.mod_add_div n M ] ; simpa [ pow_add, pow_mul ] using Nat.ModEq.mul_left _ ( h.pow _ ) ;

/-
Divisibility transfer: if `p ∣ k * 2^r + 1`, `2^M ≡ 1 [MOD p]` and `n % M = r`,
then `p ∣ k * 2^n + 1`.
-/
theorem dvd_transfer (k M p n r : ℕ) (hper : 2 ^ M ≡ 1 [MOD p])
    (hdvd : p ∣ k * 2 ^ r + 1) (hr : n % M = r) : p ∣ k * 2 ^ n + 1 := by
  rw [ ← Nat.mod_add_div n M, hr ] ; simp_all +decide [ pow_add, pow_mul, ← ZMod.natCast_eq_natCast_iff ] ;
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff ]

/-! ## Layer 2: from a covering certificate to a Sierpiński number -/

/-- A *covering certificate* for `k`: a global modulus `M` and a table assigning to each
residue `r < M` a prime `table r` that properly divides `k * 2^r + 1` and satisfies
`2^M ≡ 1 [MOD table r]`. -/
structure CoveringCert where
  k : ℕ
  M : ℕ
  Mpos : 0 < M
  table : Fin M → ℕ
  primality : ∀ r, Nat.Prime (table r)
  periodicity : ∀ r, 2 ^ M ≡ 1 [MOD table r]
  divisibility : ∀ r, table r ∣ k * 2 ^ (r.val) + 1
  proper : ∀ r, k * 2 ^ (r.val) + 1 ≠ table r

/-- Any covering certificate witnesses that its `k` is a Sierpiński number. Uses only
Layer 1. -/
theorem CoveringCert.isSierpinski (cert : CoveringCert) : IsSierpinski cert.k := by
  intro n
  -- the relevant residue
  set r : Fin cert.M := ⟨n % cert.M, Nat.mod_lt _ cert.Mpos⟩ with hr
  have hp : Nat.Prime (cert.table r) := cert.primality r
  -- the prime divides the base value `k * 2^r + 1`
  have hbase : cert.table r ∣ cert.k * 2 ^ (r.val) + 1 := cert.divisibility r
  -- transfer divisibility to `n`
  have hn : cert.table r ∣ cert.k * 2 ^ n + 1 :=
    dvd_transfer cert.k cert.M (cert.table r) n r.val (cert.periodicity r) hbase rfl
  -- the prime is a *proper* divisor: it is strictly smaller than `k * 2^n + 1`
  have hpos : 0 < cert.k * 2 ^ (r.val) + 1 := Nat.succ_pos _
  have hle : cert.table r ≤ cert.k * 2 ^ (r.val) + 1 := Nat.le_of_dvd hpos hbase
  have hlt_base : cert.table r < cert.k * 2 ^ (r.val) + 1 :=
    lt_of_le_of_ne hle (fun h => cert.proper r h.symm)
  -- `n ≥ r.val` since `r.val = n % M ≤ n`
  have hrle : r.val ≤ n := by simp only [hr]; exact Nat.mod_le _ _
  have hmono : cert.k * 2 ^ (r.val) + 1 ≤ cert.k * 2 ^ n + 1 := by
    have h2 : (2 : ℕ) ^ (r.val) ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hrle
    have := Nat.mul_le_mul_left cert.k h2
    omega
  have hlt : cert.table r < cert.k * 2 ^ n + 1 := lt_of_lt_of_le hlt_base hmono
  -- conclude non-primality
  intro hprime
  rcases (hprime.eq_one_or_self_of_dvd _ hn) with h1 | h2
  · exact hp.ne_one h1
  · exact (Nat.ne_of_lt hlt) h2

/-! ## Layer 3: the concrete certificate for `78557` -/

/-- The covering table for `78557` with modulus `36`.
For each residue `r < 36`, `tbl78557 r` is a prime dividing `78557 * 2^r + 1`. -/
def tbl78557 : Fin 36 → ℕ :=
  ![3, 5, 3, 73, 3, 5, 3, 7, 3, 5, 3, 13, 3, 5, 3, 19, 3, 5, 3, 7,
    3, 5, 3, 13, 3, 5, 3, 37, 3, 5, 3, 7, 3, 5, 3, 13]

/-- The covering certificate establishing that `78557` is a Sierpiński number. -/
def cert78557 : CoveringCert where
  k := 78557
  M := 36
  Mpos := by norm_num
  table := tbl78557
  primality := by decide
  periodicity := by decide
  divisibility := by decide
  proper := by decide

/-! ## Layer 4: the main theorem -/

/-- **78557 is a Sierpiński number**: `78557 * 2^n + 1` is composite for every `n`. -/
theorem sierpinski_78557 : IsSierpinski 78557 := cert78557.isSierpinski

end Sierpinski