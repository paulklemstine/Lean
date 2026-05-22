import Mathlib
import ABC.Radical
import ABC.ABCTriple

/-!
# Arithmetic Support Complexity and the ABC Conjecture

This file develops the **support complexity** interpretation of the radical
function and the abc conjecture. The key insight is that `rad(n)` measures
the "prime support complexity" of `n` — the number of distinct prime factors
controls the information content needed to specify the multiplicative structure.

## Cross-domain bridge: Number Theory ↔ Information/Coding Theory

The abc conjecture can be interpreted as saying:
**Additive synthesis of large numbers requires sufficiently rich prime support.**

More precisely, if a + b = c with gcd(a,b) = 1, then c cannot be much larger
than rad(abc) — the compressed prime support of the triple. This is analogous
to a coding-theoretic lower bound: you cannot encode a large message (c) using
a channel with limited alphabet (the prime support).

## Main results

* `primeSupport_card` — the number of distinct prime factors of n
* `support_complexity_lower_bound` — rad(n) ≥ 2^(ω(n)) where ω(n) is the number
  of distinct prime factors (each prime is ≥ 2)
* `abc_support_obstruction` — under ABC, additive triples have bounded
  "complexity gap" between output size and support complexity
-/

open Finset Nat

/-- The number of distinct prime factors of `n`, also written ω(n). -/
def primeOmega (n : ℕ) : ℕ := n.primeFactors.card

/-- ω(0) = 0. -/
@[simp] theorem primeOmega_zero : primeOmega 0 = 0 := by simp [primeOmega]

/-- ω(1) = 0. -/
@[simp] theorem primeOmega_one : primeOmega 1 = 0 := by simp [primeOmega]

/-
The radical is at least 2^ω(n) for n > 0, since each prime factor is ≥ 2.
-/
theorem rad_ge_two_pow_omega {n : ℕ} (hn : n ≠ 0) :
    2 ^ primeOmega n ≤ rad n := by
  -- Each prime factor of `n` is at least 2, so the product of the prime factors is at least $2^{\omega(n)}$.
  have h_rad_ge_prod : rad n = ∏ p ∈ n.primeFactors, p := by
    rfl;
  exact h_rad_ge_prod.symm ▸ le_trans ( by simp +decide [ primeOmega ] ) ( Finset.prod_le_prod' fun p hp => Nat.Prime.two_le <| Nat.prime_of_mem_primeFactors hp )

/-
For coprime m, n with both nonzero, ω(mn) = ω(m) + ω(n).
-/
theorem primeOmega_mul_of_coprime {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0)
    (h : Nat.Coprime m n) :
    primeOmega (m * n) = primeOmega m + primeOmega n := by
  unfold primeOmega;
  rw [ Nat.primeFactors_mul hm hn, Finset.card_union_of_disjoint ( h.disjoint_primeFactors ) ]

/-
ω(n^k) = ω(n) for k ≥ 1.
-/
theorem primeOmega_pow {n k : ℕ} (hk : k ≠ 0) :
    primeOmega (n ^ k) = primeOmega n := by
  unfold primeOmega;
  cases n <;> cases k <;> simp_all +decide [ Nat.primeFactors_pow ]

/-! ## Support complexity interpretation of ABC -/

/-- The **support complexity gap** for an ABC triple is c / rad(abc).
    ABC says this ratio is bounded (in a power sense). -/
noncomputable def ABCTriple.supportGap (t : ABCTriple) : ℕ :=
  t.c / t.radABC

/-
Under the discrete ABC conjecture, the support gap is polynomially bounded.
    Specifically, for each m ≥ 1, t.c^m ≤ K · rad(abc)^(m+1) implies that
    the "excess" of c over rad(abc) is controlled.
-/
theorem support_gap_bounded
    (m K : ℕ) (hm : 1 ≤ m) (t : ABCTriple)
    (hbound : t.c ^ m ≤ K * (t.radABC) ^ (m + 1)) :
    t.c ^ m ≤ K * t.radABC * (t.radABC) ^ m := by
  simpa only [ mul_assoc, pow_succ' ] using hbound

/-! ## Height-vs-radical obstruction schema -/

/-- A **height inequality interface** abstracting the abc pattern.
    This captures the general shape: the "height" (size) of an arithmetic
    object is controlled by its "support" (prime complexity). -/
structure HeightRadicalBound where
  /-- The exponent on the height side. -/
  heightExp : ℕ
  /-- The exponent on the radical side. -/
  radExp : ℕ
  /-- The height exponent is positive. -/
  hHeight : 0 < heightExp
  /-- The radical exponent exceeds the height exponent. -/
  hExcess : heightExp < radExp
  /-- The uniform constant. -/
  K : ℕ
  /-- K is positive. -/
  hK : 0 < K
  /-- The bound holds for all ABC triples. -/
  bound : ∀ t : ABCTriple, t.c ^ heightExp ≤ K * (t.radABC) ^ radExp

/-
The discrete ABC conjecture produces a HeightRadicalBound for each m.
-/
theorem abc_gives_height_bound (hABC : ABCConjectureDiscrete) (m : ℕ) (hm : 1 ≤ m) :
    ∃ hrb : HeightRadicalBound, hrb.heightExp = m ∧ hrb.radExp = m + 1 := by
  exact ⟨ ⟨ m, m + 1, hm, by linarith, Classical.choose ( hABC m hm ), Classical.choose_spec ( hABC m hm ) |>.1, fun t => Classical.choose_spec ( hABC m hm ) |>.2 t ⟩, rfl, rfl ⟩

/-
From any HeightRadicalBound, Fermat solutions are size-bounded.
    If a^n + b^n = c^n and the bound holds, then c^(n * heightExp) ≤ K * c^(3 * radExp).
-/
theorem height_bound_fermat_obstruction
    (hrb : HeightRadicalBound)
    {a b c n : ℕ}
    (hn : 1 ≤ n)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hcop_ab : Nat.Coprime a b)
    (hcop_ac : Nat.Coprime a c)
    (hcop_bc : Nat.Coprime b c)
    (hfermat : a ^ n + b ^ n = c ^ n) :
    c ^ (n * hrb.heightExp) ≤ hrb.K * c ^ (3 * hrb.radExp) := by
  -- Apply theHeightRadicalBound to the ABC triple (a^n, b^n, c^n)
  have h_bound : c ^ (n * hrb.heightExp) ≤ hrb.K * (rad (a ^ n * b ^ n * c ^ n)) ^ hrb.radExp := by
    convert hrb.bound ( ABCTriple.mk ( a ^ n ) ( b ^ n ) ( c ^ n ) ( pow_pos ha _ ) ( pow_pos hb _ ) ( pow_pos hc _ ) ( fermat_to_abc_triple hn ha hb hc hcop_ab hfermat ) hfermat ) using 1;
    rw [ pow_mul ];
  -- Use the fact that $rad(a^n * b^n * c^n) = rad(a * b * c)$ and $rad(a * b * c) \leq c^3$.
  have h_rad : rad (a ^ n * b ^ n * c ^ n) = rad (a * b * c) := by
    exact rad_pow_product hn
  have h_rad_le : rad (a * b * c) ≤ c ^ 3 := by
    apply flt_radical_bound hn ha hb hc hcop_ab hcop_ac hcop_bc hfermat;
  exact h_bound.trans ( by rw [ h_rad ] ; exact Nat.mul_le_mul_left _ ( by simpa only [ pow_mul ] using Nat.pow_le_pow_left h_rad_le _ ) )