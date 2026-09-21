import Mathlib

/-!
# BATTERY-UTILITY: the labels are not filters

## Research context (FACT round-28 #4, paper 98, verdict `THE-LABELS-ARE-NOT-FILTERS`)

The 6-dial battery measures, for a semiprime `N = p*q`, a vector of *splitting labels*: for
a small auxiliary polynomial `f` and a modulus `m*`, the label records how `f` decomposes
modulo the prime factors.  The battery has a measured capacity of `12.7` bits.  The arc's
final question was **utility**: can those bits be converted into *candidate-set narrowing*
for `p`, i.e. into a filter that rules out residues `r mod m*`?

The round's experiment built its utility tables by *polynomial evaluation at the residue*
(`does f(r) ≡ 0 mod m*?`).  That is a statement about `r`, not about the primes lying in the
class `r`.  The consistency assert caught the resulting exclusions of the true `p`.  The
diagnosis is the finding: the conversion requires a map

  `residue r mod m*  ↦  splitting type of a prime ≡ r (mod m*)`

and **that map does not exist**.  Primes in the same residue class carry different splitting
types, which is exactly why every measured channel sits strictly below its label-entropy
ceiling (`S₃a : I = 1.0012` against `H(T) = 2.2982`): the gap *is* the within-class variation.

This file is the formal core of that verdict, for the smallest non-abelian test polynomial
`f = X³ - 2` (splitting field `ℚ(∛2, ω)`, Galois group `S₃`).

## Main results

* `cubeCount` — the label: the number of roots of `X³ - c` in `ℤ/p`.
* `cubeCount_eq_one_of_two_mod_three` — **the abelian part of the label is a filter.**  For
  every prime `p ≡ 2 (mod 3)` the label is `1`, for every `c`.  Proof: `x ↦ x³` is a bijection
  of `ℤ/p`, because `3k = 2(p-1)+1` is solvable and `(x³)^k = x`.
* `cubeCount_eq_zero_or_three_of_one_mod_three` — for `p ≡ 1 (mod 3)` and `p ∤ c` the label is
  `0` or `3`: the fibre of the cube map is either empty or a coset of the group `μ₃ ⊆ ℤ/p`,
  and `μ₃` has exactly three elements (Cauchy's theorem gives `≥ 3`, the degree bound `≤ 3`).
* `cubicType_eq_one_iff` — **the exact information content of the label**: for a prime `p ≥ 5`,
  `cubicType p = 1 ↔ p ≡ 2 (mod 3)`.  So the label carries exactly one *free* bit (the residue
  of `p` mod `3`, which a residue-based filter already knows) plus the `0`-versus-`3` bit.
* `no_residue_type_map` — **the payload**: for every modulus `2 ≤ m ≤ 24` there is *no* map
  `ZMod m → ℕ` computing the label of the primes `p ≡ 1 (mod 3)`, refuted by an explicit pair
  of primes in one class with labels `0` and `3`.  `HasResidueTypeMap.of_dvd` propagates any
  such refutation to all divisors of `m`.
* `sound_filter_no_narrowing`, `sound_filter_trivial_on_one_mod_three` — **no pinning**: any
  residue filter mod `9` that never excludes a true prime must accept *all three* residues
  `1, 4, 7` for the label `0` and for the label `3`.  The two labels have identical residue
  support: the narrowing factor is `1`.  The only residues a sound filter may separate are
  `{2,5,8}` versus `{1,4,7}`, i.e. the already-known value of `p mod 3`.
* `sound_filter_cannot_separate` — the same at *every* modulus `2 ≤ m ≤ 24`: some residue class
  is accepted by both the label `0` and the label `3`, so no dial reading removes it.
* `window_census`, `window_rows_mixed` — the measured window (`21` primes `p < 200`,
  `p ≡ 1 mod 3`) with its verified cell counts `(6,2 | 5,2 | 5,1)`: every residue row is mixed.
* `quadratic_label_is_filter`, `abelian_filter_exists_but_cubic_does_not` — the adversarial
  control.  For the *abelian* probe `X² - 2` the table does exist, at modulus `8`.  So the
  verdict is a statement about non-abelianness, not about the number of bits available.
-/

namespace BatteryUtility

open Finset

/-- The battery label of the prime `p` at the test polynomial `X³ - c`:
the number of roots of `X³ ≡ c` in `ℤ/p`.  Computable, hence checkable by `decide`. -/
def cubeCount (c p : ℕ) : ℕ := ((Finset.range p).filter fun x => (x ^ 3) % p = c % p).card

/-- The label of `p` in the battery's cubic channel `f = X³ - 2`. -/
def cubicType (p : ℕ) : ℕ := cubeCount 2 p

/-- The `ℕ`-level label agrees with the algebraic count of cube roots in `ℤ/p`. -/
theorem cubeCount_eq_card (c p : ℕ) [NeZero p] :
    cubeCount c p = (Finset.univ.filter fun x : ZMod p => x ^ 3 = (c : ZMod p)).card := by
  unfold cubeCount
  refine Finset.card_nbij' (fun x : ℕ => (x : ZMod p)) (fun x : ZMod p => x.val) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq] at ha
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq]
    have : ((a ^ 3 : ℕ) : ZMod p) = ((c : ℕ) : ZMod p) := by
      rw [ZMod.natCast_eq_natCast_iff']
      exact ha.2
    push_cast at this
    exact this
  · intro a ha
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at ha
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq]
    refine ⟨ZMod.val_lt a, ?_⟩
    have : ((a.val ^ 3 : ℕ) : ZMod p) = ((c : ℕ) : ZMod p) := by
      push_cast [ZMod.natCast_val, ZMod.cast_id]
      exact ha
    rw [ZMod.natCast_eq_natCast_iff'] at this
    exact this
  · intro a ha
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq] at ha
    exact ZMod.val_cast_of_lt ha.1
  · intro a _
    simp [ZMod.natCast_val, ZMod.cast_id]

section Field

variable (p : ℕ) [hp : Fact p.Prime]

/-- If `3k = 2(p-1)+1` then `k`-th powering inverts cubing on all of `ℤ/p`. -/
theorem cube_pow_inv (k : ℕ) (hk : 3 * k = 2 * (p - 1) + 1) (x : ZMod p) : (x ^ 3) ^ k = x := by
  rw [← pow_mul, hk]
  rcases eq_or_ne x 0 with rfl | hx
  · simp
  · rw [pow_add, pow_one, mul_comm 2 (p - 1), pow_mul, ZMod.pow_card_sub_one_eq_one hx, one_pow,
      one_mul]

/-- For `p ≡ 2 (mod 3)` cubing is a bijection of `ℤ/p`: the cubic channel is *abelian* there. -/
theorem cube_bijective (h3 : p % 3 = 2) : Function.Bijective (fun x : ZMod p => x ^ 3) := by
  have h2 : 2 ≤ p := hp.out.two_le
  obtain ⟨k, hk⟩ : ∃ k, 3 * k = 2 * (p - 1) + 1 := ⟨(2 * p - 1) / 3, by omega⟩
  constructor
  · intro x y hxy
    have hx := cube_pow_inv p k hk x
    rw [← hx, show (x : ZMod p) ^ 3 = y ^ 3 from hxy, cube_pow_inv p k hk y]
  · intro y
    exact ⟨y ^ k, by simpa [← pow_mul, mul_comm] using cube_pow_inv p k hk y⟩

/-- The group `μ₃ ⊆ ℤ/p` of cube roots of unity has exactly three elements when `p ≡ 1 (mod 3)`.
Lower bound: Cauchy's theorem in `(ℤ/p)ˣ`.  Upper bound: a cubic has at most three roots. -/
theorem card_cubeRootsOne (h3 : p % 3 = 1) :
    (Finset.univ.filter fun x : ZMod p => x ^ 3 = 1).card = 3 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have hdvd : 3 ∣ Fintype.card (ZMod p)ˣ := by
    rw [ZMod.card_units_eq_totient, Nat.totient_prime hp.out]
    have := hp.out.two_le
    omega
  obtain ⟨u, hu⟩ := exists_prime_orderOf_dvd_card 3 hdvd
  have hu3 : (u : ZMod p) ^ 3 = 1 := by
    have h : u ^ 3 = 1 := by rw [← hu]; exact pow_orderOf_eq_one u
    have := congrArg Units.val h
    simpa using this
  have hle : (Finset.univ.filter fun x : ZMod p => x ^ 3 = 1).card ≤ 3 := by
    have hsub : (Finset.univ.filter fun x : ZMod p => x ^ 3 = 1) ⊆
        (Polynomial.nthRoots 3 (1 : ZMod p)).toFinset := by
      intro x hx
      simp only [Finset.mem_filter] at hx
      simp [Multiset.mem_toFinset, Polynomial.mem_nthRoots, hx.2]
    calc _ ≤ (Polynomial.nthRoots 3 (1 : ZMod p)).toFinset.card := Finset.card_le_card hsub
      _ ≤ Multiset.card (Polynomial.nthRoots 3 (1 : ZMod p)) := Multiset.toFinset_card_le _
      _ ≤ 3 := Polynomial.card_nthRoots 3 1
  have hge : 3 ≤ (Finset.univ.filter fun x : ZMod p => x ^ 3 = 1).card := by
    have hsub : ({1, (u : ZMod p), ((u : ZMod p)) ^ 2} : Finset (ZMod p)) ⊆
        (Finset.univ.filter fun x : ZMod p => x ^ 3 = 1) := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl | rfl
      · simp
      · simpa using hu3
      · simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        rw [show ((u : ZMod p) ^ 2) ^ 3 = ((u : ZMod p) ^ 3) ^ 2 by ring, hu3, one_pow]
    have h1 : (u : ZMod p) ≠ 1 := by
      intro h
      have hu1 : u = 1 := Units.ext h
      rw [hu1] at hu; simp at hu
    have h2 : ((u : ZMod p)) ^ 2 ≠ 1 := by
      intro h
      have h' : u ^ 2 = 1 := Units.ext (by push_cast; exact h)
      have hdvd2 := orderOf_dvd_of_pow_eq_one h'
      rw [hu] at hdvd2
      omega
    have h3' : ((u : ZMod p)) ^ 2 ≠ (u : ZMod p) := by
      intro h
      apply h1
      have hune : (u : ZMod p) ≠ 0 := u.ne_zero
      have hcancel : (u : ZMod p) * (u : ZMod p) = (u : ZMod p) * 1 := by
        rw [mul_one, ← pow_two]; exact h
      exact mul_left_cancel₀ hune hcancel
    have hcard : ({1, (u : ZMod p), ((u : ZMod p)) ^ 2} : Finset (ZMod p)).card = 3 := by
      rw [Finset.card_insert_of_notMem (by simp [Ne.symm h1, Ne.symm h2]),
        Finset.card_insert_of_notMem (by simp [Ne.symm h3']), Finset.card_singleton]
    calc 3 = _ := hcard.symm
      _ ≤ _ := Finset.card_le_card hsub
  omega

/-- A nonempty cube fibre is a coset of `μ₃`, hence has the same cardinality. -/
theorem card_cubeFiber_eq_card_roots {c a : ZMod p} (hc : c ≠ 0) (ha : a ^ 3 = c) :
    (Finset.univ.filter fun x : ZMod p => x ^ 3 = c).card
      = (Finset.univ.filter fun x : ZMod p => x ^ 3 = 1).card := by
  have ha0 : a ≠ 0 := by rintro rfl; simp at ha; exact hc ha.symm
  refine Finset.card_nbij' (fun x : ZMod p => x * a⁻¹) (fun y : ZMod p => y * a) ?_ ?_ ?_ ?_ <;>
    intro x hx <;>
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at hx ⊢
  · field_simp [mul_pow, hx, ← ha]
    rw [hx, ha]
  · rw [mul_pow, hx, one_mul, ha]
  · field_simp
  · field_simp

end Field

/-- **The abelian half of the label is a filter.**  For a prime `p ≡ 2 (mod 3)` the cubic
channel always reads `1`, whatever the constant `c`. -/
theorem cubeCount_eq_one_of_two_mod_three (c p : ℕ) (hp : p.Prime) (h3 : p % 3 = 2) :
    cubeCount c p = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  rw [cubeCount_eq_card]
  obtain ⟨x0, hx0⟩ := (cube_bijective p h3).surjective (c : ZMod p)
  rw [Finset.card_eq_one]
  refine ⟨x0, Finset.eq_singleton_iff_unique_mem.mpr ⟨by simpa using hx0, ?_⟩⟩
  intro y hy
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hy
  exact (cube_bijective p h3).injective (by simpa [hy] using hx0.symm)

/-- **The non-abelian half.**  For a prime `p ≡ 1 (mod 3)` not dividing `c`, the label is `0`
or `3` — never anything else. -/
theorem cubeCount_eq_zero_or_three_of_one_mod_three (c p : ℕ) (hp : p.Prime) (h3 : p % 3 = 1)
    (hc : ¬ (p : ℕ) ∣ c) : cubeCount c p = 0 ∨ cubeCount c p = 3 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  rw [cubeCount_eq_card]
  have hc0 : ((c : ℕ) : ZMod p) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    exact hc
  rcases Finset.eq_empty_or_nonempty
      (Finset.univ.filter fun x : ZMod p => x ^ 3 = ((c : ℕ) : ZMod p)) with h | ⟨a, ha⟩
  · left; rw [h]; rfl
  · right
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
    rw [card_cubeFiber_eq_card_roots p hc0 ha, card_cubeRootsOne p h3]

/-- **The exact information content of the cubic label.**  For every prime `p ≥ 5`,
`cubicType p = 1` holds precisely for `p ≡ 2 (mod 3)`.  Hence the label splits into the
residue-computable bit `p mod 3` and the `0`-versus-`3` bit studied below. -/
theorem cubicType_eq_one_iff (p : ℕ) (hp : p.Prime) (hp5 : 5 ≤ p) :
    cubicType p = 1 ↔ p % 3 = 2 := by
  have hnd : ¬ (p : ℕ) ∣ 2 := fun h => by
    have := Nat.le_of_dvd (by norm_num) h; omega
  have h30 : p % 3 ≠ 0 := by
    intro h
    have : (3 : ℕ) ∣ p := Nat.dvd_of_mod_eq_zero h
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp 3 this) with h' | h' <;> omega
  constructor
  · intro h1
    have hlt : p % 3 < 3 := Nat.mod_lt p (by norm_num)
    rcases (by omega : p % 3 = 1 ∨ p % 3 = 2) with h | h
    · rcases cubeCount_eq_zero_or_three_of_one_mod_three 2 p hp h hnd with h' | h' <;>
        simp [cubicType, h'] at h1
    · exact h
  · intro h2
    exact cubeCount_eq_one_of_two_mod_three 2 p hp h2

/-- The utility hypothesis the round tried to instantiate: a *residue → type* table for the
modulus `m`, valid on the primes `p ≡ 1 (mod 3)` (the classes where the label is not already
determined by `p mod 3`). -/
def HasResidueTypeMap (m : ℕ) : Prop :=
  ∃ g : ZMod m → ℕ, ∀ p : ℕ, p.Prime → 5 ≤ p → p % 3 = 1 → g (p : ZMod m) = cubicType p

/-- If the table exists for a divisor `d` of `m`, it exists for `m` (compose with the
projection).  Equivalently: a refutation at `m` refutes every divisor of `m`. -/
theorem HasResidueTypeMap.of_dvd {d m : ℕ} [NeZero d] [NeZero m] (hdm : d ∣ m)
    (h : HasResidueTypeMap d) : HasResidueTypeMap m := by
  obtain ⟨g, hg⟩ := h
  refine ⟨fun x => g (ZMod.castHom hdm (ZMod d) x), fun p hp hp5 hp3 => ?_⟩
  have hcast : ZMod.castHom hdm (ZMod d) (p : ZMod m) = (p : ZMod d) := by simp
  show g (ZMod.castHom hdm (ZMod d) (p : ZMod m)) = cubicType p
  rw [hcast]
  exact hg p hp hp5 hp3

/-- The refutation engine: one pair of primes in the same class mod `m` with different labels
destroys the table. -/
theorem not_hasResidueTypeMap_of_witness {m : ℕ} (a b : ℕ) (ha : a.Prime) (hb : b.Prime)
    (ha5 : 5 ≤ a) (hb5 : 5 ≤ b) (ha3 : a % 3 = 1) (hb3 : b % 3 = 1) (hab : a % m = b % m)
    (hne : cubicType a ≠ cubicType b) : ¬ HasResidueTypeMap m := by
  rintro ⟨g, hg⟩
  apply hne
  have hcast : (a : ZMod m) = (b : ZMod m) := (ZMod.natCast_eq_natCast_iff' a b m).2 hab
  rw [← hg a ha ha5 ha3, ← hg b hb hb5 hb3, hcast]

/-- **THE LABELS ARE NOT FILTERS.**  For every modulus `2 ≤ m ≤ 24` there is no map
`residue mod m ↦ cubic label`, even after restricting to the primes `p ≡ 1 (mod 3)`.  Each
case is refuted by an explicit pair of primes sharing a residue class and carrying the labels
`0` and `3`. -/
theorem no_residue_type_map (m : ℕ) (hm : 2 ≤ m) (hm24 : m ≤ 24) : ¬ HasResidueTypeMap m := by
  interval_cases m
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 13 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 31 73 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 13 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 13 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 31 97 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 79 157 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 31 73 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 13 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 31 79 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 109 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 13 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 13 127 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 43 103 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 31 73 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 31 97 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 19 157 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)
  · exact not_hasResidueTypeMap_of_witness 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by decide)

/-! ### No pinning: a sound residue filter narrows nothing -/

/-- A *label filter* mod `m`: for each observed label `t`, the set of residues it permits.
Soundness means the filter never excludes a true prime. -/
def SoundFilter (m : ℕ) (F : ℕ → Finset (ZMod m)) : Prop :=
  ∀ p : ℕ, p.Prime → 5 ≤ p → (p : ZMod m) ∈ F (cubicType p)

/-- **No pinning.**  Any sound filter mod `9` must accept all of `{1,4,7}` for the label `0`
*and* for the label `3`: the two labels have identical residue support, so learning which of
them holds excludes no residue at all. -/
theorem sound_filter_no_narrowing (F : ℕ → Finset (ZMod 9)) (hF : SoundFilter 9 F) :
    ({1, 4, 7} : Finset (ZMod 9)) ⊆ F 0 ∧ ({1, 4, 7} : Finset (ZMod 9)) ⊆ F 3 := by
  have h19 := hF 19 (by norm_num) (by norm_num)
  have h13 := hF 13 (by norm_num) (by norm_num)
  have h7 := hF 7 (by norm_num) (by norm_num)
  have h127 := hF 127 (by norm_num) (by norm_num)
  have h31 := hF 31 (by norm_num) (by norm_num)
  have h43 := hF 43 (by norm_num) (by norm_num)
  rw [show cubicType 19 = 0 from by decide, show ((19 : ℕ) : ZMod 9) = 1 from by decide] at h19
  rw [show cubicType 13 = 0 from by decide, show ((13 : ℕ) : ZMod 9) = 4 from by decide] at h13
  rw [show cubicType 7 = 0 from by decide, show ((7 : ℕ) : ZMod 9) = 7 from by decide] at h7
  rw [show cubicType 127 = 3 from by decide, show ((127 : ℕ) : ZMod 9) = 1 from by decide] at h127
  rw [show cubicType 31 = 3 from by decide, show ((31 : ℕ) : ZMod 9) = 4 from by decide] at h31
  rw [show cubicType 43 = 3 from by decide, show ((43 : ℕ) : ZMod 9) = 7 from by decide] at h43
  constructor <;> intro x hx <;>
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx <;> rcases hx with rfl | rfl | rfl
  · exact h19
  · exact h13
  · exact h7
  · exact h127
  · exact h31
  · exact h43

/-- Consequence: on the `1 (mod 3)` part of the residue ring the filter has *no* narrowing
power — at least three residues survive both labels. -/
theorem sound_filter_trivial_on_one_mod_three (F : ℕ → Finset (ZMod 9))
    (hF : SoundFilter 9 F) : 3 ≤ (F 0 ∩ F 3).card := by
  obtain ⟨h0, h3⟩ := sound_filter_no_narrowing F hF
  have hsub : ({1, 4, 7} : Finset (ZMod 9)) ⊆ F 0 ∩ F 3 := fun x hx =>
    Finset.mem_inter.2 ⟨h0 hx, h3 hx⟩
  calc (3 : ℕ) = ({1, 4, 7} : Finset (ZMod 9)).card := by decide
    _ ≤ _ := Finset.card_le_card hsub

/-- The remaining, `2 (mod 3)` half is exactly the free bit: the label `1` occurs on all of
`{2,5,8}`, and by `cubicType_eq_one_iff` it occurs *only* there. -/
theorem sound_filter_label_one_support (F : ℕ → Finset (ZMod 9)) (hF : SoundFilter 9 F) :
    ({2, 5, 8} : Finset (ZMod 9)) ⊆ F 1 := by
  have h11 := hF 11 (by norm_num) (by norm_num)
  have h5 := hF 5 (by norm_num) (by norm_num)
  have h17 := hF 17 (by norm_num) (by norm_num)
  rw [show cubicType 11 = 1 from by decide, show ((11 : ℕ) : ZMod 9) = 2 from by decide] at h11
  rw [show cubicType 5 = 1 from by decide, show ((5 : ℕ) : ZMod 9) = 5 from by decide] at h5
  rw [show cubicType 17 = 1 from by decide, show ((17 : ℕ) : ZMod 9) = 8 from by decide] at h17
  intro x hx
  simp only [Finset.mem_insert, Finset.mem_singleton] at hx
  rcases hx with rfl | rfl | rfl
  · exact h11
  · exact h5
  · exact h17

/-- A sound filter must place the shared residue of a witness pair in *both* label classes. -/
theorem mem_inter_of_witness {m : ℕ} (F : ℕ → Finset (ZMod m)) (hF : SoundFilter m F)
    (a b : ℕ) (ha : a.Prime) (hb : b.Prime) (ha5 : 5 ≤ a) (hb5 : 5 ≤ b)
    (hab : a % m = b % m) (ha0 : cubicType a = 0) (hb3 : cubicType b = 3) :
    (a : ZMod m) ∈ F 0 ∩ F 3 := by
  have h1 := hF a ha ha5
  rw [ha0] at h1
  have h2 := hF b hb hb5
  rw [hb3] at h2
  have hcast : (a : ZMod m) = (b : ZMod m) := (ZMod.natCast_eq_natCast_iff' a b m).2 hab
  exact Finset.mem_inter.2 ⟨h1, hcast ▸ h2⟩

/-- **No pinning at every modulus `2 ≤ m ≤ 24`.**  A sound label filter can never separate the
labels `0` and `3`: some residue class is accepted by both.  Whatever the dial reads, that
class survives — the narrowing the utility tables claimed is impossible without first deciding
the type of the individual prime, which is the factoring problem itself. -/
theorem sound_filter_cannot_separate (m : ℕ) (hm : 2 ≤ m) (hm24 : m ≤ 24)
    (F : ℕ → Finset (ZMod m)) (hF : SoundFilter m F) : (F 0 ∩ F 3).Nonempty := by
  interval_cases m
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 13 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 73 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 13 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 13 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 97 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 79 157 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 73 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 13 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 79 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 109 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 13 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 13 127 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 103 43 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 73 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 97 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 19 157 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩
  · exact ⟨_, mem_inter_of_witness F hF 7 31 (by norm_num) (by norm_num) (by norm_num)
      (by norm_num) (by norm_num) (by decide) (by decide)⟩

/-! ### The measured window: the census behind the `(6,2 | 5,2 | 5,1)` table -/

/-- The window actually measured: the primes `5 ≤ p < 200` with `p ≡ 1 (mod 3)`, i.e. the
classes on which the cubic label is not already fixed by `p mod 3`. -/
def windowPrimes : Finset ℕ :=
  (Finset.range 200).filter fun p => Nat.Prime p ∧ 5 ≤ p ∧ p % 3 = 1

/-- The `(residue mod 9, label)` cell counts of the window. -/
def windowCell (r t : ℕ) : ℕ :=
  (windowPrimes.filter fun p => p % 9 = r ∧ cubicType p = t).card

set_option maxRecDepth 200000 in
/-- **The census.**  All `21` primes of the window, laid out by residue mod `9` and label:
`(1 ↦ 6,2), (4 ↦ 5,2), (7 ↦ 5,1)`.  Every one of the three residue rows carries *both* labels;
this is the table used as `measuredWindow` in `BatteryUtilityPosteriorGap.lean`. -/
theorem window_census :
    windowPrimes.card = 21 ∧ windowCell 1 0 = 6 ∧ windowCell 1 3 = 2 ∧ windowCell 4 0 = 5 ∧
      windowCell 4 3 = 2 ∧ windowCell 7 0 = 5 ∧ windowCell 7 3 = 1 := by
  decide

/-- Every label in the window is `0` or `3` — not by enumeration, but by the structure theorem
`cubeCount_eq_zero_or_three_of_one_mod_three`. -/
theorem window_labels_zero_or_three {p : ℕ} (hp : p ∈ windowPrimes) :
    cubicType p = 0 ∨ cubicType p = 3 := by
  simp only [windowPrimes, Finset.mem_filter, Finset.mem_range] at hp
  obtain ⟨-, hprime, hp5, hp3⟩ := hp
  have hnd : ¬ (p : ℕ) ∣ 2 := fun h => by
    have := Nat.le_of_dvd (by norm_num) h; omega
  exact cubeCount_eq_zero_or_three_of_one_mod_three 2 p hprime hp3 hnd

/-- Every residue row of the window is *mixed*: within-class variation is present in each of
the three classes `1, 4, 7 mod 9`, which is precisely the deficit `H(T) - I` measured by the
dial. -/
theorem window_rows_mixed :
    0 < windowCell 1 0 ∧ 0 < windowCell 1 3 ∧ 0 < windowCell 4 0 ∧ 0 < windowCell 4 3 ∧
      0 < windowCell 7 0 ∧ 0 < windowCell 7 3 := by
  obtain ⟨-, h10, h13, h40, h43, h70, h73⟩ := window_census
  exact ⟨by omega, by omega, by omega, by omega, by omega, by omega⟩

/-! ### Adversarial control: the *abelian* dial really is a filter

The verdict is not that labels are useless in principle — it is that *non-abelian* labels are.
The quadratic probe `X² - 2` has abelian splitting field `ℚ(√2) ⊆ ℚ(ζ₈)`, and for it the
residue → label table **does** exist, with modulus `8`.  The contrast is the content of
`abelian_filter_exists_but_cubic_does_not`. -/

/-- The quadratic label: the number of roots of `X² ≡ c` in `ℤ/p`. -/
def sqCount (c p : ℕ) : ℕ := ((Finset.range p).filter fun x => (x ^ 2) % p = c % p).card

theorem sqCount_eq_card (c p : ℕ) [NeZero p] :
    sqCount c p = (Finset.univ.filter fun x : ZMod p => x ^ 2 = (c : ZMod p)).card := by
  unfold sqCount
  refine Finset.card_nbij' (fun x : ℕ => (x : ZMod p)) (fun x : ZMod p => x.val) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq] at ha
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq]
    have : ((a ^ 2 : ℕ) : ZMod p) = ((c : ℕ) : ZMod p) := by
      rw [ZMod.natCast_eq_natCast_iff']; exact ha.2
    push_cast at this
    exact this
  · intro a ha
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at ha
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq]
    refine ⟨ZMod.val_lt a, ?_⟩
    have : ((a.val ^ 2 : ℕ) : ZMod p) = ((c : ℕ) : ZMod p) := by
      push_cast [ZMod.natCast_val, ZMod.cast_id]; exact ha
    rw [ZMod.natCast_eq_natCast_iff'] at this
    exact this
  · intro a ha
    simp only [Finset.coe_filter, Finset.mem_range, Set.mem_setOf_eq] at ha
    exact ZMod.val_cast_of_lt ha.1
  · intro a _
    simp [ZMod.natCast_val, ZMod.cast_id]

/-- A quadratic residue has exactly two square roots modulo an odd prime. -/
theorem sqCount_two_eq_two (p : ℕ) [hp : Fact p.Prime] (hp2 : p ≠ 2)
    (h : IsSquare (2 : ZMod p)) : sqCount 2 p = 2 := by
  haveI : NeZero p := ⟨hp.out.pos.ne'⟩
  obtain ⟨a, ha⟩ := h
  have ha2 : a ^ 2 = (2 : ZMod p) := by rw [pow_two]; exact ha.symm
  have hc : ((2 : ℕ) : ZMod p) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    intro hdvd
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp.out (by norm_num)).1 hdvd)
  have hc' : (2 : ZMod p) ≠ 0 := by simpa using hc
  rw [sqCount_eq_card]
  have ha0 : a ≠ 0 := by rintro rfl; simp at ha2; exact hc' ha2.symm
  have hne : a ≠ -a := by
    intro hh
    have h2 : (2 : ZMod p) * a = 0 := by linear_combination hh
    rcases mul_eq_zero.1 h2 with h3 | h3
    · exact hc' h3
    · exact ha0 h3
  have hset : (Finset.univ.filter fun x : ZMod p => x ^ 2 = ((2 : ℕ) : ZMod p)) = {a, -a} := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
      Finset.mem_singleton, Nat.cast_ofNat]
    constructor
    · intro hx
      have hfac : (x - a) * (x + a) = 0 := by linear_combination hx - ha2
      rcases mul_eq_zero.1 hfac with h' | h'
      · exact Or.inl (sub_eq_zero.1 h')
      · exact Or.inr (by linear_combination h')
    · rintro (rfl | rfl) <;> simp [ha2]
  rw [hset, Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]

theorem sqCount_two_eq_zero (p : ℕ) [hp : Fact p.Prime] (h : ¬ IsSquare (2 : ZMod p)) :
    sqCount 2 p = 0 := by
  haveI : NeZero p := ⟨hp.out.pos.ne'⟩
  rw [sqCount_eq_card, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro x _ hx
  exact h ⟨x, by rw [← pow_two]; simpa using hx.symm⟩

/-- The quadratic label is a function of `p mod 8` — the second supplement to quadratic
reciprocity, read as a *filter*. -/
theorem sqCount_two_eq (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    sqCount 2 p = if p % 8 = 1 ∨ p % 8 = 7 then 2 else 0 := by
  haveI : Fact p.Prime := ⟨hp⟩
  by_cases h : IsSquare (2 : ZMod p)
  · rw [sqCount_two_eq_two p hp2 h, if_pos ((ZMod.exists_sq_eq_two_iff hp2).1 h)]
  · rw [sqCount_two_eq_zero p h, if_neg fun hc => h ((ZMod.exists_sq_eq_two_iff hp2).2 hc)]

/-- **The abelian dial is a genuine filter**: an explicit table `ZMod 8 → ℕ` reproduces the
quadratic label of every odd prime. -/
theorem quadratic_label_is_filter :
    ∃ g : ZMod 8 → ℕ, ∀ p : ℕ, p.Prime → p ≠ 2 → g (p : ZMod 8) = sqCount 2 p := by
  refine ⟨fun r => if r = 1 ∨ r = 7 then 2 else 0, fun p hp hp2 => ?_⟩
  have hodd : p % 2 = 1 := hp.eq_two_or_odd.resolve_left hp2
  have hcast : (p : ZMod 8) = ((p % 8 : ℕ) : ZMod 8) := (ZMod.natCast_mod p 8).symm
  have h8 : p % 8 = 1 ∨ p % 8 = 3 ∨ p % 8 = 5 ∨ p % 8 = 7 := by omega
  rw [sqCount_two_eq p hp hp2]
  rcases h8 with h | h | h | h <;> rw [hcast, h] <;> norm_num <;> decide

/-- **The boundary.**  The abelian probe `X² - 2` admits a residue → label table (modulus `8`),
the non-abelian probe `X³ - 2` admits none at any modulus `2 ≤ m ≤ 24`.  Filterability is an
abelianness phenomenon, not a matter of having enough bits. -/
theorem abelian_filter_exists_but_cubic_does_not :
    (∃ g : ZMod 8 → ℕ, ∀ p : ℕ, p.Prime → p ≠ 2 → g (p : ZMod 8) = sqCount 2 p) ∧
      ∀ m : ℕ, 2 ≤ m → m ≤ 24 → ¬ HasResidueTypeMap m :=
  ⟨quadratic_label_is_filter, no_residue_type_map⟩

end BatteryUtility