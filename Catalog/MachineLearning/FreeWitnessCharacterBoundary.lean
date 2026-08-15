import MachineLearning.FreeWitnessSigmaK

/-!
# The characters-only boundary: which weights actually split through CRT

§3 of `16_FreeWitness_Classification.md` asserts a boundary for the free-witness
mechanism: the family works because its local weights are *character-like*
(CRT-multiplicative), and other weights — the paper cites truncations and exponential
phase functions — fall outside it.  This file makes that boundary a theorem, and in the
process corrects the paper's justification for the phase case.

**Layer 1 of the classification, proved.**  A weight that splits as
`f x = A (x % m) · B (x % n)` has an aggregate that is a product:
`∑_{x < m n} f x = (∑_{a < m} A a)(∑_{b < n} B b)` for coprime `m, n`
(`sum_split`, `sum_eq_mul_of_splitsMod`).  This is the exact statement "CRT-separable
domain + CRT-multiplicative weight ⇒ the count factors".

**A necessary condition, hence a falsification tool.**  Splitting is a *rank-one*
condition on the CRT square: whenever `z` and `w` carry the crossed residues of `x` and
`y`, one must have `f x · f y = f z · f w` (`rankOne_of_splitsMod`).  This is checkable
on four points, and it is the sharpest elementary obstruction available.

Over a field the criterion is *exact*: `splitsMod_iff_rankOne` shows that for a
nowhere-vanishing weight, splitting through CRT is equivalent to the four-point rank-one
identity, the splitting being reconstructed from the two axes of the CRT square.

**The boundary, both sides.**
* `sqrtOneWeight_splits` — the square-root-of-one indicator (the CIRC/BQF-style
  character weight) does split, for every coprime pair.
* `truncWeight_not_splits` — the *truncated* (half-plane) weight
  `x ↦ [2 (x % 15) < 15]` does **not** split at `(3, 5)`: rank-one already fails on the
  quadruple `0, 1, 6, 10`.  So truncation genuinely leaves the class, which is the
  formal counterpart of the catalog's `halfPlaneCount_not_multiplicative`.
* `phase_index_splits`, `twist_depends_on_comodulus` — the honest version of the phase
  discussion.  Exponential phases `e(x / mn)` *do* split through CRT: Bézout gives
  `x = u n x + v m x`, so `e(x/(mn)) = e(u x/m) · e(v x/n)` exactly.  What fails is not
  the splitting but the *locality*: the twist `u ≡ n⁻¹ (mod m)` depends on the **other**
  modulus, so the local factor is not a function of one prime alone
  (`(3 : ZMod 7)⁻¹ = 5` but `(5 : ZMod 7)⁻¹ = 3`, and the two induced local weights
  differ).  This is why phase witnesses are not free witnesses in the sense of the
  classification, and it is a different reason from the one stated in the paper.
-/

namespace FreeWitness

open Finset

/-! ## Splitting weights and the multiplicativity of the aggregate -/

/-- A weight on `ℕ` **splits through CRT** at `(m, n)` if it is a product of a function
of the residue mod `m` and a function of the residue mod `n`.  This is the precise form
of "CRT-multiplicative local weight". -/
def SplitsMod {R : Type*} [CommRing R] (m n : ℕ) (f : ℕ → R) : Prop :=
  ∃ A B : ℕ → R, ∀ x, f x = A (x % m) * B (x % n)

/-- **Layer 1 of the classification.**  For coprime moduli the aggregate of a split
weight over a complete residue system factors as a product of local aggregates. -/
theorem sum_split {m n : ℕ} (h : Nat.Coprime m n) (hm : 0 < m) (hn : 0 < n)
    (A B : ℕ → ℤ) :
    ∑ x ∈ range (m * n), A (x % m) * B (x % n)
      = (∑ a ∈ range m, A a) * (∑ b ∈ range n, B b) := by
  rw [Finset.sum_mul_sum, ← Finset.sum_product']
  refine Finset.sum_nbij' (i := fun x => (x % m, x % n))
    (j := fun p => (Nat.chineseRemainder h p.1 p.2 : ℕ) % (m * n)) ?_ ?_ ?_ ?_ ?_
  · intro x _
    simp only [Finset.mem_product, Finset.mem_range]
    exact ⟨Nat.mod_lt _ hm, Nat.mod_lt _ hn⟩
  · intro p _
    exact Finset.mem_range.mpr (Nat.mod_lt _ (Nat.mul_pos hm hn))
  · -- `j (i x) = x`: CRT uniqueness below `m n`
    intro x hx
    have hxlt : x < m * n := Finset.mem_range.mp hx
    set k := (Nat.chineseRemainder h (x % m) (x % n) : ℕ) with hk
    have hk1 : k ≡ x % m [MOD m] := (Nat.chineseRemainder h (x % m) (x % n)).2.1
    have hk2 : k ≡ x % n [MOD n] := (Nat.chineseRemainder h (x % m) (x % n)).2.2
    have hx1 : k ≡ x [MOD m] := by
      have : x % m ≡ x [MOD m] := Nat.mod_modEq x m
      exact hk1.trans this
    have hx2 : k ≡ x [MOD n] := by
      have : x % n ≡ x [MOD n] := Nat.mod_modEq x n
      exact hk2.trans this
    have hmn : k ≡ x [MOD m * n] := (Nat.modEq_and_modEq_iff_modEq_mul h).mp ⟨hx1, hx2⟩
    show k % (m * n) = x
    calc k % (m * n) = x % (m * n) := hmn
      _ = x := Nat.mod_eq_of_lt hxlt
  · -- `i (j p) = p`
    intro p hp
    simp only [Finset.mem_product, Finset.mem_range] at hp
    set k := (Nat.chineseRemainder h p.1 p.2 : ℕ) with hk
    have hk1 : k ≡ p.1 [MOD m] := (Nat.chineseRemainder h p.1 p.2).2.1
    have hk2 : k ≡ p.2 [MOD n] := (Nat.chineseRemainder h p.1 p.2).2.2
    have e1 : k % (m * n) % m = p.1 := by
      rw [Nat.mod_mod_of_dvd _ ⟨n, rfl⟩]
      calc k % m = p.1 % m := hk1
        _ = p.1 := Nat.mod_eq_of_lt hp.1
    have e2 : k % (m * n) % n = p.2 := by
      rw [Nat.mod_mod_of_dvd _ ⟨m, mul_comm m n⟩]
      calc k % n = p.2 % n := hk2
        _ = p.2 := Nat.mod_eq_of_lt hp.2
    exact Prod.ext e1 e2
  · intro x _
    rfl

/-- The aggregate of a CRT-split weight is the product of the two local aggregates. -/
theorem sum_eq_mul_of_splitsMod {m n : ℕ} (h : Nat.Coprime m n) (hm : 0 < m) (hn : 0 < n)
    {f : ℕ → ℤ} {A B : ℕ → ℤ} (hf : ∀ x, f x = A (x % m) * B (x % n)) :
    ∑ x ∈ range (m * n), f x = (∑ a ∈ range m, A a) * (∑ b ∈ range n, B b) := by
  rw [Finset.sum_congr rfl (fun x _ => hf x)]
  exact sum_split h hm hn A B

/-! ## The rank-one obstruction -/

/-- **Splitting forces the rank-one identity.**  If `z` carries the residue of `x` mod
`m` and of `y` mod `n`, and `w` the crossed pair, then `f x · f y = f z · f w`.
A single violating quadruple therefore refutes CRT-multiplicativity of the weight. -/
theorem rankOne_of_splitsMod {R : Type*} [CommRing R] {m n : ℕ} {f : ℕ → R}
    (hf : SplitsMod m n f)
    {x y z w : ℕ} (hzx : z % m = x % m) (hzy : z % n = y % n)
    (hwy : w % m = y % m) (hwx : w % n = x % n) :
    f x * f y = f z * f w := by
  obtain ⟨A, B, hAB⟩ := hf
  rw [hAB x, hAB y, hAB z, hAB w, hzx, hzy, hwy, hwx]
  ring

/-- **The rank-one criterion is also sufficient.**  Over a field, a nowhere-vanishing
weight satisfying the rank-one identity on all crossed CRT quadruples *does* split.  The
splitting is constructed explicitly from the two "axes" of the CRT square:
`A a = f (crt a 0)` and `B b = f (crt 0 b) / f 0`.  Together with
`rankOne_of_splitsMod` this characterises CRT-multiplicative weights exactly, so the
boundary of the free-witness class is decided by a four-point test. -/
theorem splitsMod_of_rankOne {K : Type*} [Field K] {m n : ℕ} (h : Nat.Coprime m n)
    {f : ℕ → K} (h0 : f 0 ≠ 0)
    (hrank : ∀ x y z w : ℕ, z % m = x % m → z % n = y % n → w % m = y % m → w % n = x % n →
      f x * f y = f z * f w) :
    SplitsMod m n f := by
  set crt : ℕ → ℕ → ℕ := fun a b => (Nat.chineseRemainder h a b : ℕ)
  have hcrt1 : ∀ a b, crt a b % m = a % m := fun a b =>
    (Nat.chineseRemainder h a b).2.1
  have hcrt2 : ∀ a b, crt a b % n = b % n := fun a b =>
    (Nat.chineseRemainder h a b).2.2
  refine ⟨fun a => f (crt a 0), fun b => f (crt 0 b) / f 0, ?_⟩
  intro x
  have hz1 : crt (x % m) 0 % m = x % m := by rw [hcrt1, Nat.mod_mod_of_dvd _ dvd_rfl]
  have hz2 : crt (x % m) 0 % n = 0 % n := hcrt2 _ _
  have hw1 : crt 0 (x % n) % m = 0 % m := hcrt1 _ _
  have hw2 : crt 0 (x % n) % n = x % n := by rw [hcrt2, Nat.mod_mod_of_dvd _ dvd_rfl]
  have key := hrank x 0 (crt (x % m) 0) (crt 0 (x % n)) hz1 hz2 hw1 hw2
  rw [← mul_div_assoc, eq_div_iff h0]
  exact key

/-- **The four-point characterisation of CRT-multiplicative weights.**  For a
nowhere-vanishing weight over a field, splitting through CRT is *equivalent* to the
rank-one identity on crossed quadruples. -/
theorem splitsMod_iff_rankOne {K : Type*} [Field K] {m n : ℕ} (h : Nat.Coprime m n)
    {f : ℕ → K} (h0 : f 0 ≠ 0) :
    SplitsMod m n f ↔
      ∀ x y z w : ℕ, z % m = x % m → z % n = y % n → w % m = y % m → w % n = x % n →
        f x * f y = f z * f w :=
  ⟨fun hf _ _ _ _ h1 h2 h3 h4 => rankOne_of_splitsMod hf h1 h2 h3 h4,
    splitsMod_of_rankOne h h0⟩

/-! ## Inside the class: the square-root-of-one (character) weight -/

/-- The indicator weight of the equation `x² ≡ 1 (mod N)`: the CIRC/BQF-style local
weight, in one variable. -/
def sqrtOneWeight (N : ℕ) (x : ℕ) : ℤ := if x ^ 2 % N = 1 % N then 1 else 0

/-- **The character weight splits.**  For coprime `m, n` the indicator of
`x² ≡ 1 (mod m n)` is the product of the indicators mod `m` and mod `n` — a function of
`x % m` times a function of `x % n`. -/
theorem sqrtOneWeight_splits {m n : ℕ} (h : Nat.Coprime m n) :
    SplitsMod m n (sqrtOneWeight (m * n)) := by
  refine ⟨fun a => sqrtOneWeight m a, fun b => sqrtOneWeight n b, ?_⟩
  intro x
  have hm : (x % m) ^ 2 % m = x ^ 2 % m := by
    conv_rhs => rw [Nat.pow_mod]
  have hn : (x % n) ^ 2 % n = x ^ 2 % n := by
    conv_rhs => rw [Nat.pow_mod]
  have hiff : x ^ 2 % (m * n) = 1 % (m * n) ↔ (x ^ 2 % m = 1 % m ∧ x ^ 2 % n = 1 % n) := by
    constructor
    · intro hx
      have hx' : x ^ 2 ≡ 1 [MOD m * n] := hx
      exact ⟨((Nat.modEq_and_modEq_iff_modEq_mul h).mpr hx').1,
        ((Nat.modEq_and_modEq_iff_modEq_mul h).mpr hx').2⟩
    · rintro ⟨h1, h2⟩
      exact (Nat.modEq_and_modEq_iff_modEq_mul h).mp ⟨h1, h2⟩
  simp only [sqrtOneWeight, hm, hn]
  by_cases hx : x ^ 2 % (m * n) = 1 % (m * n)
  · obtain ⟨h1, h2⟩ := hiff.mp hx
    simp [hx, h1, h2]
  · have : ¬ (x ^ 2 % m = 1 % m ∧ x ^ 2 % n = 1 % n) := fun hc => hx (hiff.mpr hc)
    rcases not_and_or.mp this with h1 | h1 <;> simp [hx, h1]

/-! ## Outside the class: truncation -/

/-- The truncated ("half-plane") weight at `N = 15`: the indicator of the low half of the
residue interval.  This is the one-variable model of the non-separable cut studied in
`HalfPlaneCircleBasic.lean`. -/
def truncWeight (x : ℕ) : ℤ := if 2 * (x % 15) < 15 then 1 else 0

/-- **Truncation leaves the class.**  The weight `x ↦ [2 (x mod 15) < 15]` does not split
through the CRT decomposition `15 = 3 · 5`: rank-one fails on the quadruple
`x = 0, y = 1, z = 6, w = 10`, whose CRT coordinates are `(0,0), (1,1), (0,1), (1,0)`,
because `f 0 · f 1 = 1` while `f 6 · f 10 = 0`. -/
theorem truncWeight_not_splits : ¬ SplitsMod 3 5 truncWeight := by
  intro hf
  have h := rankOne_of_splitsMod hf (x := 0) (y := 1) (z := 6) (w := 10)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num [truncWeight] at h

/-! ## The phase boundary: splitting holds, locality fails -/

/-- **Exponential phases do split through CRT.**  With Bézout data `u n + v m = 1`, the
phase index decomposes exactly, `x = (u x) n + (v x) m`, i.e.
`x / (m n) = u x / m + v x / n` as elements of `ℚ / ℤ`; hence
`e(x / mn) = e(u x / m) · e(v x / n)`.  (The claim in §3 of the paper that phases do not
decompose through CRT is therefore false as stated; the real obstruction is the twist,
below.) -/
theorem phase_index_splits {m n : ℕ} {u v : ℤ} (huv : u * n + v * m = 1) (x : ℤ) :
    x = (u * x) * n + (v * x) * m := by
  have : x * (u * n + v * m) = x := by rw [huv]; ring
  linarith [this]

/-- **The twist depends on the co-modulus.**  The local phase weight at `m` is
`y ↦ e(u y / m)` with `u ≡ n⁻¹ (mod m)`, and this `u` is a function of the *other*
modulus: modulo `7` the inverse of `3` is `5`, while the inverse of `5` is `3`, and the
two induced local weights `y ↦ 5 y` and `y ↦ 3 y` are different functions.  So a phase
witness has no single-prime local weight, which is exactly the hypothesis the
classification needs. -/
theorem twist_depends_on_comodulus :
    ((3 : ZMod 7)⁻¹ = 5 ∧ (5 : ZMod 7)⁻¹ = 3) ∧ ∃ y : ZMod 7, (5 : ZMod 7) * y ≠ 3 * y := by
  refine ⟨⟨by decide, by decide⟩, ⟨1, by decide⟩⟩

/-- Consistency of the twist description with Bézout: `5 · 3 + (-2) · 7 = 1`, so for the
pair `(m, n) = (7, 3)` the local twist at `7` is `u = 5`; for `(m, n) = (7, 5)` it is
`u = 3` (`3 · 5 + (-2) · 7 = 1`). -/
theorem twist_bezout :
    (5 : ℤ) * 3 + (-2) * 7 = 1 ∧ (3 : ℤ) * 5 + (-2) * 7 = 1 := by
  constructor <;> norm_num

/-! ### Lab notes (cycle 3)

CRT square for `15 = 3 · 5`, entries `x` indexed by `(x mod 3, x mod 5)`:

```
        b=0  b=1  b=2  b=3  b=4
 a=0 |   0    6   12    3    9
 a=1 |  10    1    7   13    4
 a=2 |   5   11    2    8   14
```
Truncation weight `[2x < 15]` on this square:

```
        b=0  b=1  b=2  b=3  b=4
 a=0 |   1    1    0    1    0
 a=1 |   0    1    1    0    1
 a=2 |   1    0    1    0    0
```
Rank-one test on the top-left 2×2 block: `1·1 = 1` but `1·0 = 0` — fails, so the
truncated weight is not a product of local weights.  The same square for the weight
`[x² ≡ 1 mod 15]` is the outer product of `[a² ≡ 1 mod 3]` and `[b² ≡ 1 mod 5]`.
-/

example : truncWeight 0 * truncWeight 1 ≠ truncWeight 6 * truncWeight 10 := by
  norm_num [truncWeight]

example : sqrtOneWeight 15 4 = 1 ∧ sqrtOneWeight 15 7 = 0 := by
  norm_num [sqrtOneWeight]

end FreeWitness