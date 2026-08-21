import Mathlib

/-!
# The Möbius Twist Ring `ZM = ℤ[t]/(t² − 1)`

This file develops the *correct* algebraic home of the "Möbius integers" idea:
the ring obtained from `ℤ` by adjoining a formal orientation-reversing symbol
`t` with `t² = 1` (the holonomy of the Möbius band's orientation double cover).

We realise `ℤ[t]/(t²−1)` concretely as the subring

  `evenDiff = {(u, v) ∈ ℤ × ℤ | u ≡ v (mod 2)}`

via `a + b·t ↦ (a + b, a − b)` (the "characters of ℤ/2" coordinates).  This gives
the `CommRing` structure for free and makes every computation transparent.

## Main results

* `ZM.mk_mul`, `ZM.mk_add` — the twisted multiplication `(a,b)(c,d) = (ac+bd, ad+bc)`.
* `ZM.tw_sq`, `ZM.isUnit_tw`, `ZM.not_prime_tw` — the twist `t` is a unit of order 2,
  hence **not** a prime: "orientation is a unit, not a prime".
* `ZM.not_domain` — `ZM` is not an integral domain: `(1+t)(1−t) = 0`.
* `ZM.nrm_mul`, `ZM.isUnit_iff_nrm`, `ZM.isUnit_mk_iff` — the norm `N(a+bt) = a² − b²`
  is multiplicative and detects units; the unit group is `{±1, ±t} ≅ (ℤ/2)²`.
* `ZM.nrm_ne_two` — no element has norm `±2`; consequently `ZM.irreducible_two`.
* `ZM.irreducible_mk_int_iff` — a rational integer is irreducible in `ZM` **iff** it is
  `±2`: the twist ring destroys the primality of every odd prime.
* `ZM.odd_prime_splits` — every odd integer `2k+1` factors nontrivially in `ZM`,
  e.g. `3 = (2 + t)(2 − t)`; so `6 = 2·(2+t)·(2−t)` has **three** irreducible factors.
* `ZM.idempotent_eq` and `ZM.not_ringEquiv_prod` — `ZM` has no nontrivial idempotents,
  hence `ZM ≇ ℤ × ℤ`: the Möbius extension of `ℤ` by its twist does not split.
* `ZM.tw_pow_eq_one_iff` — holonomy: `t^n = 1 ↔ n` even, matching `σ² = id` for the
  deck transformation `σ(x,y) = (x+1,−y)` of the Möbius band.
-/

namespace Moebius

/-- The subring `{(u,v) : u ≡ v mod 2}` of `ℤ × ℤ`; it is the image of
`ℤ[t]/(t²−1)` under the two characters of `ℤ/2`. -/
def evenDiff : Subring (ℤ × ℤ) where
  carrier := {p | Even (p.1 - p.2)}
  mul_mem' := by
    intro p q hp hq
    simp only [Set.mem_setOf_eq, Int.even_sub, Prod.fst_mul, Prod.snd_mul,
      Int.even_mul] at *
    tauto
  one_mem' := by simp [Set.mem_setOf_eq]
  add_mem' := by
    intro p q hp hq
    simp only [Set.mem_setOf_eq] at *
    have h : p.1 + q.1 - (p.2 + q.2) = (p.1 - p.2) + (q.1 - q.2) := by ring
    simpa [Prod.fst_add, Prod.snd_add, h] using hp.add hq
  zero_mem' := by simp [Set.mem_setOf_eq]
  neg_mem' := by
    intro p hp
    simp only [Set.mem_setOf_eq] at *
    have h : -p.1 - -p.2 = -(p.1 - p.2) := by ring
    simpa [Prod.fst_neg, Prod.snd_neg, h] using hp.neg

/-- The Möbius twist ring `ZM = ℤ[t]/(t² − 1)`. -/
abbrev ZM : Type := evenDiff

namespace ZM

/-- `mk a b` is the element `a + b·t`, in character coordinates `(a+b, a−b)`. -/
def mk (a b : ℤ) : ZM := ⟨(a + b, a - b), by
  have h : a + b - (a - b) = 2 * b := by ring
  simp only [evenDiff, Set.mem_setOf_eq, Subring.mem_mk, Subsemiring.mem_mk,
    Submonoid.mem_mk, Subsemigroup.mem_mk]
  rw [h]
  exact ⟨b, by ring⟩⟩

@[simp] lemma coe_mk (a b : ℤ) : ((mk a b : ZM) : ℤ × ℤ) = (a + b, a - b) := rfl

lemma ext_coe {x y : ZM} (h : (x : ℤ × ℤ) = y) : x = y := Subtype.ext h

@[simp] lemma mk_add (a b c d : ℤ) : mk a b + mk c d = mk (a + c) (b + d) := by
  apply ext_coe; ext <;> simp <;> ring

@[simp] lemma mk_mul (a b c d : ℤ) :
    mk a b * mk c d = mk (a * c + b * d) (a * d + b * c) := by
  apply ext_coe; ext <;> simp <;> ring

@[simp] lemma mk_neg (a b : ℤ) : -mk a b = mk (-a) (-b) := by
  apply ext_coe; ext <;> simp <;> ring

@[simp] lemma mk_zero : mk 0 0 = (0 : ZM) := by apply ext_coe; ext <;> simp

@[simp] lemma mk_one : mk 1 0 = (1 : ZM) := by apply ext_coe; ext <;> simp

lemma mk_inj_iff {a b c d : ℤ} : mk a b = mk c d ↔ a = c ∧ b = d := by
  constructor
  · intro h
    have h' := congrArg (fun z : ZM => (z : ℤ × ℤ)) h
    simp only [coe_mk, Prod.mk.injEq] at h'
    omega
  · rintro ⟨rfl, rfl⟩; rfl

lemma mk_eq_zero_iff {a b : ℤ} : mk a b = 0 ↔ a = 0 ∧ b = 0 := by
  rw [← mk_zero, mk_inj_iff]

/-- The twist element `t`, i.e. the class of the orientation-reversing generator. -/
def tw : ZM := mk 0 1

/-- `t² = 1`: going around the Möbius band twice restores the orientation. -/
theorem tw_sq : tw * tw = 1 := by
  simp [tw]

theorem tw_ne_one : tw ≠ 1 := by
  rw [tw, ← mk_one, Ne, mk_inj_iff]; omega

theorem tw_ne_neg_one : tw ≠ -1 := by
  rw [tw, ← mk_one, mk_neg, Ne, mk_inj_iff]; omega

theorem isUnit_tw : IsUnit tw := IsUnit.of_mul_eq_one _ tw_sq

/-- The orientation class is a **unit**, hence not a prime: the conjecture that
"orientation is a prime" fails in the twist ring. -/
theorem not_prime_tw : ¬ Prime tw := fun h => h.not_unit isUnit_tw

/-! ### Failure of the domain property -/

/-- `(1 + t)(1 − t) = 0` with both factors nonzero. -/
theorem twist_zero_divisors : mk 1 1 * mk 1 (-1) = 0 ∧ mk 1 1 ≠ 0 ∧ mk 1 (-1) ≠ 0 := by
  refine ⟨by simp, ?_, ?_⟩ <;> rw [Ne, mk_eq_zero_iff] <;> omega

theorem not_domain : ¬ ∀ x y : ZM, x * y = 0 → x = 0 ∨ y = 0 := by
  intro h
  obtain ⟨hmul, h1, h2⟩ := twist_zero_divisors
  rcases h _ _ hmul with h' | h'
  · exact h1 h'
  · exact h2 h'

/-! ### The norm -/

/-- The norm `N(a + b t) = a² − b²`, i.e. the product of the two characters. -/
def nrm (z : ZM) : ℤ := (z : ℤ × ℤ).1 * (z : ℤ × ℤ).2

@[simp] lemma nrm_mk (a b : ℤ) : nrm (mk a b) = a ^ 2 - b ^ 2 := by
  simp [nrm]; ring

@[simp] lemma nrm_mul (x y : ZM) : nrm (x * y) = nrm x * nrm y := by
  simp only [nrm, Subring.coe_mul, Prod.fst_mul, Prod.snd_mul]
  ring

@[simp] lemma nrm_one : nrm (1 : ZM) = 1 := by simp [nrm]

/-- Units are exactly the elements of norm `±1`. -/
theorem isUnit_iff_nrm (z : ZM) : IsUnit z ↔ nrm z = 1 ∨ nrm z = -1 := by
  constructor
  · rintro ⟨u, rfl⟩
    have hmul : (u : ZM) * (↑u⁻¹ : ZM) = 1 := u.mul_inv
    have h : nrm (u : ZM) * nrm (↑u⁻¹ : ZM) = 1 := by
      rw [← nrm_mul, hmul, nrm_one]
    exact Int.isUnit_iff.mp (IsUnit.of_mul_eq_one _ h)
  · intro h
    refine IsUnit.of_mul_eq_one z ?_
    have hu : (z : ℤ × ℤ).1 * (z : ℤ × ℤ).2 = 1 ∨ (z : ℤ × ℤ).1 * (z : ℤ × ℤ).2 = -1 := h
    have h1 : (z : ℤ × ℤ).1 = 1 ∧ (z : ℤ × ℤ).2 = 1 ∨
        (z : ℤ × ℤ).1 = -1 ∧ (z : ℤ × ℤ).2 = -1 ∨
        (z : ℤ × ℤ).1 = 1 ∧ (z : ℤ × ℤ).2 = -1 ∨
        (z : ℤ × ℤ).1 = -1 ∧ (z : ℤ × ℤ).2 = 1 := by
      rcases hu with hu | hu
      · rcases Int.mul_eq_one_iff_eq_one_or_neg_one.mp hu with ⟨h1, h2⟩ | ⟨h1, h2⟩
        · exact Or.inl ⟨h1, h2⟩
        · exact Or.inr (Or.inl ⟨h1, h2⟩)
      · rcases Int.mul_eq_neg_one_iff_eq_one_or_neg_one.mp hu with ⟨h1, h2⟩ | ⟨h1, h2⟩
        · exact Or.inr (Or.inr (Or.inl ⟨h1, h2⟩))
        · exact Or.inr (Or.inr (Or.inr ⟨h1, h2⟩))
    apply ext_coe
    have : ((z * z : ZM) : ℤ × ℤ) = ((z : ℤ × ℤ).1 * (z : ℤ × ℤ).1,
        (z : ℤ × ℤ).2 * (z : ℤ × ℤ).2) := rfl
    rw [this]
    have hone : ((1 : ZM) : ℤ × ℤ) = (1, 1) := rfl
    rw [hone]
    rcases h1 with ⟨ha, hb⟩ | ⟨ha, hb⟩ | ⟨ha, hb⟩ | ⟨ha, hb⟩ <;>
      rw [ha, hb] <;> norm_num

/-- The unit group of `ZM` is `{1, −1, t, −t}`. -/
theorem isUnit_mk_iff (a b : ℤ) :
    IsUnit (mk a b) ↔ (a = 1 ∧ b = 0) ∨ (a = -1 ∧ b = 0) ∨ (a = 0 ∧ b = 1) ∨
      (a = 0 ∧ b = -1) := by
  rw [isUnit_iff_nrm]
  constructor
  · intro h
    have h' : (a + b) * (a - b) = 1 ∨ (a + b) * (a - b) = -1 := by
      simpa [nrm, mk] using h
    rcases h' with h' | h'
    · rcases Int.mul_eq_one_iff_eq_one_or_neg_one.mp h' with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
    · rcases Int.mul_eq_neg_one_iff_eq_one_or_neg_one.mp h' with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> omega
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) <;> simp

/-- No element of the twist ring has norm `±2`: the two characters of an element are
congruent mod 2, so their product is odd or divisible by 4. -/
theorem nrm_ne_two (z : ZM) : nrm z ≠ 2 ∧ nrm z ≠ -2 := by
  obtain ⟨⟨u, v⟩, hz⟩ := z
  have hz' : Even (u - v) := hz
  obtain ⟨k, hk⟩ := hz'
  have hnrm : nrm (⟨(u, v), hz⟩ : ZM) = u * v := rfl
  rw [hnrm]
  rcases Int.even_or_odd v with hv | hv
  · obtain ⟨m, hm⟩ := hv
    have hu : u = 2 * (m + k) := by omega
    have hdvd : (4 : ℤ) ∣ u * v := ⟨(m + k) * m, by rw [hu, hm]; ring⟩
    constructor <;> intro h <;> rw [h] at hdvd <;> omega
  · obtain ⟨m, hm⟩ := hv
    have hu : u = 2 * (m + k) + 1 := by omega
    have hodd : Odd (u * v) := ⟨2 * (m + k) * m + (m + k) + m, by rw [hu, hm]; ring⟩
    obtain ⟨j, hj⟩ := hodd
    constructor <;> intro h <;> rw [h] at hj <;> omega

/-- An auxiliary arithmetic fact: a factorisation of `4` in `ℕ` avoiding the
factor `2` must contain the factor `1`. -/
private lemma nat_factor_four {a b : ℕ} (h : a * b = 4) (ha : a ≠ 2) : a = 1 ∨ b = 1 := by
  have hle : a ≤ 4 := Nat.le_of_dvd (by omega) ⟨b, h.symm⟩
  interval_cases a <;> omega

/-- Prime norm forces irreducibility. -/
theorem irreducible_of_prime_natAbs {z : ZM} (h : Nat.Prime (nrm z).natAbs) :
    Irreducible z := by
  constructor
  · rw [isUnit_iff_nrm]
    rintro (hz | hz) <;> rw [hz] at h <;>
      exact Nat.not_prime_one (by simpa using h)
  · intro x y hxy
    have hn : nrm x * nrm y = nrm z := by rw [hxy, nrm_mul]
    have hnat : (nrm x).natAbs * (nrm y).natAbs = (nrm z).natAbs := by
      rw [← Int.natAbs_mul, hn]
    rcases Nat.Prime.eq_one_or_self_of_dvd h (nrm x).natAbs ⟨_, hnat.symm⟩ with h1 | h1
    · left
      rw [isUnit_iff_nrm]
      omega
    · right
      have hpos : 0 < (nrm z).natAbs := h.pos
      have hy : (nrm y).natAbs = 1 := by
        rw [h1] at hnat
        have h2 : (nrm z).natAbs * (nrm y).natAbs = (nrm z).natAbs * 1 := by
          simpa using hnat
        exact Nat.eq_of_mul_eq_mul_left hpos h2
      rw [isUnit_iff_nrm]
      omega

/-! ### Factorisation experiments: 6, −6, and the twist -/

/-- `3 = (2 + t)(2 − t)` : odd primes are *not* irreducible in the twist ring. -/
theorem three_splits : mk 3 0 = mk 2 1 * mk 2 (-1) := by
  rw [mk_mul, mk_inj_iff]; omega

theorem irreducible_two_plus_tw : Irreducible (mk 2 1) := by
  apply irreducible_of_prime_natAbs
  norm_num

theorem irreducible_two_minus_tw : Irreducible (mk 2 (-1)) := by
  apply irreducible_of_prime_natAbs
  norm_num

/-- Norm `4` forces irreducibility, because norm `±2` is impossible. -/
theorem irreducible_of_nrm_eq_four {z : ZM} (hz : nrm z = 4) : Irreducible z := by
  constructor
  · rw [isUnit_iff_nrm, hz]
    norm_num
  · intro x y hxy
    have hn : nrm x * nrm y = 4 := by
      rw [← hz, hxy, nrm_mul]
    have hx2 := nrm_ne_two x
    have hy2 := nrm_ne_two y
    have habs : (nrm x).natAbs * (nrm y).natAbs = 4 := by
      rw [← Int.natAbs_mul, hn]
      rfl
    have hxne : (nrm x).natAbs ≠ 2 := by omega
    have hyne : (nrm y).natAbs ≠ 2 := by omega
    have hx : nrm x = 1 ∨ nrm x = -1 ∨ nrm y = 1 ∨ nrm y = -1 := by
      rcases nat_factor_four habs hxne with h1 | h1 <;> omega
    rcases hx with h | h | h | h
    · exact Or.inl ((isUnit_iff_nrm x).mpr (Or.inl h))
    · exact Or.inl ((isUnit_iff_nrm x).mpr (Or.inr h))
    · exact Or.inr ((isUnit_iff_nrm y).mpr (Or.inl h))
    · exact Or.inr ((isUnit_iff_nrm y).mpr (Or.inr h))

/-- The rational integer `2` stays irreducible in the twist ring. -/
theorem irreducible_two : Irreducible (mk 2 0) :=
  irreducible_of_nrm_eq_four (by norm_num)

/-- So does `−2`. -/
theorem irreducible_neg_two : Irreducible (mk (-2) 0) :=
  irreducible_of_nrm_eq_four (by norm_num)

/-- Factoring `6` in the twist ring: three irreducible factors, not two. -/
theorem six_factorisation : mk 6 0 = mk 2 0 * (mk 2 1 * mk 2 (-1)) := by
  rw [mk_mul, mk_mul, mk_inj_iff]; omega

/-- Factoring `−6`: the sign is a *unit* `−1`, distinct from the twist `t`. -/
theorem neg_six_factorisation : mk (-6) 0 = (-1 : ZM) * (mk 2 0 * (mk 2 1 * mk 2 (-1))) := by
  rw [← mk_one, mk_neg, mk_mul, mk_mul, mk_mul, mk_inj_iff]; omega

/-- The *twisted* six `t·6 = 6t` is a genuinely new element: it is neither `6` nor `−6`.
So the twist is not the sign. -/
theorem twisted_six_ne : tw * mk 6 0 ≠ mk 6 0 ∧ tw * mk 6 0 ≠ mk (-6) 0 := by
  rw [tw, mk_mul]
  constructor <;> rw [Ne, mk_inj_iff] <;> omega

/-- Every odd integer `2k+1` splits in the twist ring. -/
theorem odd_prime_splits (k : ℤ) :
    mk (2 * k + 1) 0 = mk (k + 1) k * mk (k + 1) (-k) := by
  rw [mk_mul, mk_inj_iff]
  constructor <;> ring

/-- For `k ∉ {0, −1}` (equivalently `2k+1 ≠ ±1`) the splitting
`2k+1 = (k+1+kt)(k+1−kt)` is nontrivial: neither factor is a unit. -/
theorem odd_split_nontrivial {k : ℤ} (hk : k ≠ 0) (hk' : k ≠ -1) :
    ¬ IsUnit (mk (k + 1) k) ∧ ¬ IsUnit (mk (k + 1) (-k)) := by
  constructor <;> rw [isUnit_mk_iff] <;> omega

/-- **Classification of the irreducible rational integers of the twist ring.**
A rational integer `n` is irreducible in `ZM` if and only if `n = ±2`: every odd
`|n| ≥ 3` splits through the hyperbolic form, every `|n| ≥ 4` even integer factors
as `2·(n/2)`, `0` factors as `(1+t)(1−t)`, and `±1` are units. -/
theorem irreducible_mk_int_iff (n : ℤ) : Irreducible (mk n 0) ↔ n = 2 ∨ n = -2 := by
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    obtain ⟨hc1, hc2⟩ := hc
    rcases Int.even_or_odd n with ⟨m, hm⟩ | ⟨k, hk⟩
    · -- `n = 2m`
      rcases eq_or_ne m 0 with rfl | hm0
      · -- `n = 0` factors as `(1+t)(1−t)`
        have hn0 : n = 0 := by omega
        subst hn0
        rw [mk_zero] at h
        exact not_irreducible_zero h
      · have hm2 : m ≠ 1 ∧ m ≠ -1 := by omega
        have hfact : mk n 0 = mk 2 0 * mk m 0 := by
          rw [mk_mul, mk_inj_iff]; omega
        have h2 : ¬ IsUnit (mk 2 0) := by rw [isUnit_mk_iff]; omega
        have hmu : ¬ IsUnit (mk m 0) := by
          rw [isUnit_mk_iff]
          omega
        rcases h.isUnit_or_isUnit hfact with hu | hu
        · exact h2 hu
        · exact hmu hu
    · -- `n = 2k+1`
      rcases eq_or_ne n 1 with rfl | hn1
      · exact h.1 ((isUnit_mk_iff 1 0).mpr (by omega))
      rcases eq_or_ne n (-1) with rfl | hn2
      · exact h.1 ((isUnit_mk_iff (-1) 0).mpr (by omega))
      · have hk0 : k ≠ 0 := by omega
        have hk1 : k ≠ -1 := by omega
        have hfact : mk n 0 = mk (k + 1) k * mk (k + 1) (-k) := by
          rw [hk]; exact odd_prime_splits k
        obtain ⟨hu1, hu2⟩ := odd_split_nontrivial hk0 hk1
        rcases h.isUnit_or_isUnit hfact with hu | hu
        · exact hu1 hu
        · exact hu2 hu
  · rintro (rfl | rfl)
    · exact irreducible_two
    · exact irreducible_neg_two

/-- **The three test cases of the conjecture, answered.**
`6` factors into *three* irreducibles `2·(2+t)·(2−t)`, `−6` is the same factorisation
times the unit `−1`, and `0` itself has a nontrivial factorisation `(1+t)(1−t)`
— something impossible in `ℤ`. -/
theorem factorisation_test :
    (mk 6 0 = mk 2 0 * (mk 2 1 * mk 2 (-1)) ∧ Irreducible (mk 2 0) ∧
      Irreducible (mk 2 1) ∧ Irreducible (mk 2 (-1))) ∧
    (mk (-6) 0 = (-1 : ZM) * (mk 2 0 * (mk 2 1 * mk 2 (-1))) ∧ IsUnit (-1 : ZM)) ∧
    ((0 : ZM) = mk 1 1 * mk 1 (-1) ∧ mk 1 1 ≠ 0 ∧ mk 1 (-1) ≠ 0) := by
  refine ⟨⟨six_factorisation, irreducible_two, irreducible_two_plus_tw,
    irreducible_two_minus_tw⟩, ⟨neg_six_factorisation, isUnit_one.neg⟩, ?_⟩
  obtain ⟨h0, h1, h2⟩ := twist_zero_divisors
  exact ⟨h0.symm, h1, h2⟩

/-- A nonzero element is a zero divisor exactly when its norm vanishes, i.e. when
`a = ±b`: the zero-divisor locus is the union of the two "seam" lines `a = b` and
`a = −b`, the algebraic shadow of the Möbius seam. -/
theorem zeroDivisor_iff_nrm_eq_zero (z : ZM) :
    (∃ w : ZM, w ≠ 0 ∧ z * w = 0) ↔ nrm z = 0 := by
  constructor
  · rintro ⟨w, hw, hzw⟩
    have h1 : (z : ℤ × ℤ).1 * (w : ℤ × ℤ).1 = 0 :=
      congrArg (fun y : ZM => (y : ℤ × ℤ).1) hzw
    have h2 : (z : ℤ × ℤ).2 * (w : ℤ × ℤ).2 = 0 :=
      congrArg (fun y : ZM => (y : ℤ × ℤ).2) hzw
    have hw' : (w : ℤ × ℤ).1 ≠ 0 ∨ (w : ℤ × ℤ).2 ≠ 0 := by
      by_contra hc
      push_neg at hc
      exact hw (ext_coe (Prod.ext hc.1 hc.2))
    rcases hw' with h | h
    · have : (z : ℤ × ℤ).1 = 0 := by
        rcases mul_eq_zero.mp h1 with h' | h'
        · exact h'
        · exact absurd h' h
      simp [nrm, this]
    · have : (z : ℤ × ℤ).2 = 0 := by
        rcases mul_eq_zero.mp h2 with h' | h'
        · exact h'
        · exact absurd h' h
      simp [nrm, this]
  · intro h
    have h' : (z : ℤ × ℤ).1 * (z : ℤ × ℤ).2 = 0 := h
    rcases mul_eq_zero.mp h' with h1 | h1
    · refine ⟨mk 1 1, ?_, ?_⟩
      · rw [Ne, mk_eq_zero_iff]; omega
      · apply ext_coe
        refine Prod.ext ?_ ?_ <;>
          simp [Subring.coe_mul, h1]
    · refine ⟨mk 1 (-1), ?_, ?_⟩
      · rw [Ne, mk_eq_zero_iff]; omega
      · apply ext_coe
        refine Prod.ext ?_ ?_ <;>
          simp [Subring.coe_mul, h1]

/-! ### No nontrivial idempotents: the Möbius extension does not split -/

theorem idempotent_eq (e : ZM) (he : e * e = e) : e = 0 ∨ e = 1 := by
  obtain ⟨⟨u, v⟩, hz⟩ := e
  have hz' : Even (u - v) := hz
  have hu : u * u = u := congrArg (fun z : ZM => (z : ℤ × ℤ).1) he
  have hv : v * v = v := congrArg (fun z : ZM => (z : ℤ × ℤ).2) he
  have hu' : u = 0 ∨ u = 1 := by
    rcases mul_eq_zero.mp (show u * (u - 1) = 0 by nlinarith) with h | h
    · exact Or.inl h
    · exact Or.inr (by omega)
  have hv' : v = 0 ∨ v = 1 := by
    rcases mul_eq_zero.mp (show v * (v - 1) = 0 by nlinarith) with h | h
    · exact Or.inl h
    · exact Or.inr (by omega)
  obtain ⟨k, hk⟩ := hz'
  rcases hu' with hu' | hu' <;> rcases hv' with hv' | hv'
  · left; apply ext_coe; simp [hu', hv']
  · exfalso; omega
  · exfalso; omega
  · right; apply ext_coe; simp [hu', hv']

/-- Since `ℤ × ℤ` has the nontrivial idempotent `(1,0)` while `ZM` has none,
the twist ring is **not** isomorphic to `ℤ × ℤ`: the ℤ/2-twist is a nonsplit
extension even though `t² = 1`. -/
theorem not_ringEquiv_prod : IsEmpty (ZM ≃+* (ℤ × ℤ)) := by
  constructor
  intro f
  set e : ZM := f.symm (1, 0) with he
  have hidem : e * e = e := by
    rw [he, ← map_mul]
    norm_num
  have hfe : f e = (1, 0) := by rw [he]; exact f.apply_symm_apply _
  rcases idempotent_eq e hidem with h | h
  · rw [h, map_zero] at hfe
    exact absurd hfe (by decide)
  · rw [h, map_one] at hfe
    exact absurd hfe (by decide)

/-! ### Holonomy of the Möbius band -/

theorem tw_pow (n : ℕ) : tw ^ n = if Even n then 1 else tw := by
  induction n with
  | zero => simp
  | succ m ih =>
    rw [pow_succ, ih]
    by_cases h : Even m
    · simp [h, Nat.even_add_one]
    · simp only [h, if_false, Nat.even_add_one, not_false_iff, if_true]
      simpa using tw_sq

/-- `t^n = 1` exactly when `n` is even: the holonomy homomorphism `ℤ → ZMˣ`
of the orientation double cover has kernel `2ℤ`. -/
theorem tw_pow_eq_one_iff (n : ℕ) : tw ^ n = 1 ↔ Even n := by
  rw [tw_pow]
  by_cases h : Even n <;> simp [h, tw_ne_one]

end ZM

end Moebius