import Applications.MordellKernelSubgroup

/-!
# The denominator kernel as a subgroup, and the apparition index of a prime

Cycle 6 (`MordellKernelSubgroup.lean`) proved the arithmetic heart of the matter: on
`E_N : y² = x³ + N` (`N ∈ ℤ`) the set of points whose `x`-coordinate has denominator divisible
by a fixed prime `ℓ` is closed under the chord.  This file packages that fact as an honest
`AddSubgroup` of `E_N(ℚ)` and draws the structural consequence:

> for every rational point `P` and every prime `ℓ` there is a natural number `m = m(ℓ, P)`,
> the **apparition index**, such that `ℓ ∣ den x(kP)` (for the affine multiples) precisely when
> `m ∣ k`, over all integers `k`.

This is the exact analogue, for denominators of elliptic points, of the rank of apparition of a
prime in a Lucas sequence: the set of indices at which `ℓ` "appears" is a subgroup of `ℤ`, so it
is an arithmetic progression through `0`, never a sporadic set.  It also explains cleanly *why*
the "only bad primes" conjecture fails so badly: a good prime `ℓ` appears at all multiples of its
apparition index, i.e. along an infinite arithmetic progression, as soon as it appears once.

## Main results

* `xCoord_neg` : the `x`-coordinate is invariant under negation.
* `denKernel` : the subgroup `E_ℓ(ℚ) = {P : ℓ ∣ den x(P)} ∪ {O}` of `E_N(ℚ)`.
* `den_kernel_zsmul` : membership propagates to *all* integer multiples, negative ones included.
* `den_apparition_index` : the apparition index law — the set of `k ∈ ℤ` with `ℓ ∣ den x(kP)` is
  exactly the set of multiples of a fixed `m ∈ ℕ`.
* `seven_apparition_index_eq_two_55` : on `E_55` with `P = (9,28)` the good prime `7` has
  apparition index exactly `2`, so `7 ∣ den x(kP)` **iff** `k` is even.
* `thirteen_apparition_index_eq_three_55` : the good prime `13` has apparition index exactly `3`
  on the same orbit — distinct good primes have distinct indices.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 7): if the kernel is a subgroup, then the "appearance set" of a
  prime in one orbit must be an ideal of `ℤ`, i.e. governed by a single index — the elliptic
  analogue of the rank of apparition in Lucas sequences.
Experiment (Experimenter): the pullback of `denKernel` along `k ↦ k • P` is a subgroup of `ℤ`;
  `Int.subgroup_cyclic` turns it into `mℤ`.  Care is needed because the "kernel" condition is
  stated as a universally quantified implication over the (optional) `x`-coordinate, so that
  the point at infinity is silently a member — which is exactly what makes it a subgroup.
Analysis (Analyst): the observed valuation table for `E_55, P = (9,28)`
  (`v₇ = 2` at `n = 2, 4, 6, 8` and `v₇ = 0` at `n = 1, 3, 5`; `v₁₃ = 2` at `n = 3, 6`) is now
  explained: `7` has apparition index `2` and `13` has apparition index `3`.
Critique (Critic): the concrete corollary is a genuine `iff` — the odd multiples are proved to
  *fail* the divisibility, so the statement is not vacuous, and it pins the index to `2` rather
  than merely bounding it.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## Negation does not move the `x`-coordinate -/

/-- The `x`-coordinate of a point of a Weierstrass curve is invariant under negation. -/
lemma xCoord_neg {R : Type*} [CommRing R] {W : Affine R} (P : W.Point) :
    xCoord (-P) = xCoord P := by
  cases P with
  | zero => rfl
  | some h => rw [Point.neg_some]; rfl

/-! ## The kernel as a subgroup -/

/-- Closure of the denominator kernel under addition, in the form needed for the subgroup
structure: the point at infinity is a member by convention (it has no `x`-coordinate). -/
lemma mem_den_kernel_add {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime)
    {A B : (mordell ((N : ℤ) : ℚ)).toAffine.Point}
    (hA : ∀ X : ℚ, xCoord A = some X → ℓ ∣ X.den)
    (hB : ∀ X : ℚ, xCoord B = some X → ℓ ∣ X.den) :
    ∀ X : ℚ, xCoord (A + B) = some X → ℓ ∣ X.den := by
  intro X hX
  cases hAc : A with
  | zero =>
      rw [hAc, show (Point.zero : (mordell ((N : ℤ) : ℚ)).toAffine.Point) = 0 from rfl,
        zero_add] at hX
      exact hB X hX
  | @some xa ya hnsa =>
      cases hBc : B with
      | zero =>
          rw [hBc, show (Point.zero : (mordell ((N : ℤ) : ℚ)).toAffine.Point) = 0 from rfl,
            add_zero] at hX
          exact hA X hX
      | @some xb yb hnsb =>
          have hxa : xCoord A = some xa := by rw [hAc]; rfl
          have hxb : xCoord B = some xb := by rw [hBc]; rfl
          exact kernel_stable_add hl hxa hxb (hA _ hxa) (hB _ hxb) hX

/-- **The denominator kernel `E_ℓ(ℚ)`.**  For a prime `ℓ`, the points of `E_N(ℚ)` whose
`x`-coordinate has denominator divisible by `ℓ`, together with the point at infinity, form a
subgroup.  No hypothesis on the reduction type of `ℓ` is required. -/
def denKernel (N : ℤ) (ℓ : ℕ) (hl : ℓ.Prime) :
    AddSubgroup (mordell ((N : ℤ) : ℚ)).toAffine.Point where
  carrier := {P | ∀ X : ℚ, xCoord P = some X → ℓ ∣ X.den}
  zero_mem' := by
    intro X hX
    simp [xCoord] at hX
  add_mem' := fun hA hB => mem_den_kernel_add hl hA hB
  neg_mem' := by
    intro P hP X hX
    rw [xCoord_neg] at hX
    exact hP X hX

@[simp] lemma mem_denKernel_iff {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime)
    {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point} :
    P ∈ denKernel N ℓ hl ↔ ∀ X : ℚ, xCoord P = some X → ℓ ∣ X.den := Iff.rfl

/-- **All integer multiples.**  If `ℓ` divides the denominator of `x(P)`, it divides the
denominator of `x(kP)` for every integer `k`, negative multiples included. -/
theorem den_kernel_zsmul {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime)
    {P : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ}
    (hP : xCoord P = some X) (hX : ℓ ∣ X.den) (k : ℤ) :
    ∀ Y : ℚ, xCoord (k • P) = some Y → ℓ ∣ Y.den := by
  have hmem : P ∈ denKernel N ℓ hl := by
    intro Z hZ
    rw [hP] at hZ
    have : X = Z := by simpa using hZ
    rwa [← this]
  exact (denKernel N ℓ hl).zsmul_mem hmem k

/-! ## The apparition index -/

/-- **Apparition index law.**  For every prime `ℓ` and every rational point `P` of `E_N` there is
a natural number `m` such that, for all integers `k`, the prime `ℓ` divides the denominator of
`x(kP)` exactly when `m ∣ k`.  (The multiples of `P` that are the point at infinity satisfy the
condition vacuously, so they too lie in the progression.)  Thus the set of indices at which `ℓ`
appears in a denominator is an arithmetic progression through `0`, never a sporadic set. -/
theorem den_apparition_index {N : ℤ} {ℓ : ℕ} (hl : ℓ.Prime)
    (P : (mordell ((N : ℤ) : ℚ)).toAffine.Point) :
    ∃ m : ℕ, ∀ k : ℤ,
      ((∀ Y : ℚ, xCoord (k • P) = some Y → ℓ ∣ Y.den) ↔ (m : ℤ) ∣ k) := by
  set f : ℤ →+ (mordell ((N : ℤ) : ℚ)).toAffine.Point := zmultiplesHom _ P with hf
  set H : AddSubgroup ℤ := (denKernel N ℓ hl).comap f with hH
  obtain ⟨a, ha⟩ := Int.subgroup_cyclic H
  refine ⟨a.natAbs, fun k => ?_⟩
  have hfk : f k = k • P := by rw [hf]; simp
  have hmem : k ∈ H ↔ (∀ Y : ℚ, xCoord (k • P) = some Y → ℓ ∣ Y.den) := by
    rw [hH, AddSubgroup.mem_comap, hfk]
    exact Iff.rfl
  have hcl : k ∈ H ↔ a ∣ k := by
    rw [ha, AddSubgroup.mem_closure_singleton]
    constructor
    · rintro ⟨n, rfl⟩
      exact ⟨n, by simp [mul_comm]⟩
    · rintro ⟨n, rfl⟩
      exact ⟨n, by simp [mul_comm]⟩
  rw [← hmem, hcl, Int.natAbs_dvd]

/-! ## The apparition index of the good prime `7` on `E_55` -/

/-- **`7` appears in the denominators of the orbit of `P = (9,28)` on `E_55` exactly at the even
multiples.**  Since `7 ∤ Δ = -432 · 55²`, this is a good prime, and the "only bad primes"
conjecture fails along an entire arithmetic progression rather than at a single index. -/
theorem seven_apparition_index_eq_two_55 :
    ∀ k : ℤ, ((∀ Y : ℚ, xCoord (k • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some Y → 7 ∣ Y.den) ↔ (2 : ℤ) ∣ k) := by
  obtain ⟨m, hm⟩ := den_apparition_index (N := 55) (ℓ := 7) (by norm_num)
    (Point.some nonsingular_int_55_9_28)
  -- the index divides `2`, because `7` divides the denominator of `x(2P) = 2601/3136`
  have hx2 : xCoord ((2 : ℤ) • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some (2601 / 3136 : ℚ) := by
    rw [two_zsmul, mordell_double_xCoord _ _ _ nonsingular_int_55_9_28 (by norm_num)]
    norm_num
  have hm2 : (m : ℤ) ∣ 2 := by
    refine (hm 2).1 ?_
    intro Y hY
    rw [hx2] at hY
    have : (2601 / 3136 : ℚ) = Y := by simpa using hY
    rw [← this]
    norm_num
  -- the index is not `1`, because `x(P) = 9` is an integer
  have hx1 : xCoord ((1 : ℤ) • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some (9 : ℚ) := by
    rw [one_zsmul]; rfl
  have hm1 : ¬ (m : ℤ) ∣ 1 := by
    intro hdvd
    have := (hm 1).2 hdvd
    have h7 : (7 : ℕ) ∣ (9 : ℚ).den := this 9 hx1
    norm_num at h7
  have hm2n : m ∣ 2 := by exact_mod_cast hm2
  have hmle : m ≤ 2 := Nat.le_of_dvd (by norm_num) hm2n
  have hmeq : m = 2 := by
    interval_cases m
    · exact absurd hm2n (by norm_num)
    · exact absurd (by norm_num : ((1 : ℕ) : ℤ) ∣ 1) hm1
    · rfl
  subst hmeq
  exact hm

/-! ## A second index: the good prime `13` appears exactly at the multiples of `3` -/

/-- **The apparition index of `13` on `E_55` is exactly `3`.**  Together with
`seven_apparition_index_eq_two_55` this shows that different good primes have genuinely
different indices, so the failure locus of the "only bad primes" conjecture inside one orbit is
a union of arithmetic progressions with distinct moduli — not a single periodic pattern. -/
theorem thirteen_apparition_index_eq_three_55 :
    ∀ k : ℤ, ((∀ Y : ℚ, xCoord (k • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some Y → 13 ∣ Y.den) ↔ (3 : ℤ) ∣ k) := by
  obtain ⟨m, hm⟩ := den_apparition_index (N := 55) (ℓ := 13) (by norm_num)
    (Point.some nonsingular_int_55_9_28)
  have hx3 : xCoord ((3 : ℤ) • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some (-2302089191 / 656538129 : ℚ) := by
    rw [show (3 : ℤ) = 2 + 1 by norm_num, add_zsmul, two_zsmul, one_zsmul]
    exact xCoord_triple_55
  have hm3 : (m : ℤ) ∣ 3 := by
    refine (hm 3).1 ?_
    intro Y hY
    rw [hx3] at hY
    have hYv : (-2302089191 / 656538129 : ℚ) = Y := by simpa using hY
    rw [← hYv, den_triple_55]
    exact ⟨3 ^ 6 * 13 * 73 ^ 2, by ring⟩
  have hx1 : xCoord ((1 : ℤ) • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) = some (9 : ℚ) := by
    rw [one_zsmul]; rfl
  have hm1 : ¬ (m : ℤ) ∣ 1 := by
    intro hdvd
    have h13 : (13 : ℕ) ∣ (9 : ℚ).den := (hm 1).2 hdvd 9 hx1
    norm_num at h13
  have hm3n : m ∣ 3 := by exact_mod_cast hm3
  have hmle : m ≤ 3 := Nat.le_of_dvd (by norm_num) hm3n
  have hmeq : m = 3 := by
    interval_cases m
    · exact absurd hm3n (by norm_num)
    · exact absurd (by norm_num : ((1 : ℕ) : ℤ) ∣ 1) hm1
    · exact absurd hm3n (by norm_num)
    · rfl
  subst hmeq
  exact hm

end MordellDenominators