import Mathlib

/-!
# Integer linear maps of the primitive Pythagorean node set

A *node* is a pair `(m, n)` of integers with `1 ≤ n < m`, `gcd (m, n) = 1` and `m + n` odd.
These are exactly the Euclid parameters of primitive Pythagorean triples
`(m² - n², 2mn, m² + n²)`, and the root node is `(2, 1)` (the triple `(3, 4, 5)`).

This file studies which integer `2 × 2` matrices `M = !![a, b; c, d]` act on the node set,
i.e. satisfy: `(m, n) ↦ (a m + b n, c m + d n)` maps nodes to nodes.

## Main results

* `TernaryTree.dvd_det_of_dvd_image` : any common divisor of the image pair divides `det M`.
* `TernaryTree.Preserves.parity` : node preservation forces `a + c` and `b + d` odd.
* `TernaryTree.Preserves.not_odd_prime_dvd_det` : **no odd prime divides `det M`**; in
  particular `det M ≠ 0` and `|det M|` is a power of two (`Preserves.det_natAbs_eq_two_pow`).
  This is the exact form of the "`±2` obstruction": the determinant of a node preserving
  map is `±1, ±2, ±4, …`, never divisible by `3, 5, 7, …`.
* `TernaryTree.preserves_iff` : a complete characterisation — `M` preserves nodes iff
  the parity condition, the no-odd-prime-divisor condition on `det M`, and the two cone
  conditions on the rows `(c, d)` and `(a - c, b - d)` hold.
-/

namespace TernaryTree

/-- A node of the Pythagorean tree: Euclid parameters of a primitive Pythagorean triple. -/
structure IsNode (m n : ℤ) : Prop where
  one_le : 1 ≤ n
  lt : n < m
  cop : IsCoprime m n
  odd : Odd (m + n)

/-- An integer `2 × 2` matrix `!![a, b; c, d]`, acting on pairs by `(m,n) ↦ (am+bn, cm+dn)`. -/
structure IntMap where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
deriving DecidableEq

namespace IntMap

/-- The action of an `IntMap` on a pair of integers. -/
def app (M : IntMap) (m n : ℤ) : ℤ × ℤ := (M.a * m + M.b * n, M.c * m + M.d * n)

/-- The determinant of an `IntMap`. -/
def det (M : IntMap) : ℤ := M.a * M.d - M.b * M.c

@[simp] lemma app_fst (M : IntMap) (m n : ℤ) : (M.app m n).1 = M.a * m + M.b * n := rfl
@[simp] lemma app_snd (M : IntMap) (m n : ℤ) : (M.app m n).2 = M.c * m + M.d * n := rfl

end IntMap

/-- `M` preserves the node set. -/
def Preserves (M : IntMap) : Prop :=
  ∀ m n : ℤ, IsNode m n → IsNode (M.app m n).1 (M.app m n).2

/-! ### Elementary nodes -/

lemma isNode_root : IsNode 2 1 :=
  ⟨le_refl 1, by norm_num, ⟨1, -1, by ring⟩, ⟨1, by ring⟩⟩

/-- `(m, 1)` is a node for every even `m ≥ 2`. -/
lemma isNode_even_one {m : ℤ} (h2 : 2 ≤ m) (he : Even m) : IsNode m 1 := by
  obtain ⟨k, hk⟩ := he
  exact ⟨le_refl 1, by omega, ⟨0, 1, by ring⟩, ⟨k, by omega⟩⟩

/-- `(m, m-1)` is a node for every `m ≥ 2`. -/
lemma isNode_spine {m : ℤ} (h2 : 2 ≤ m) : IsNode m (m - 1) :=
  ⟨by omega, by omega, ⟨1, -1, by ring⟩, ⟨m - 1, by ring⟩⟩

/-- `(3, 2)` is a node. -/
lemma isNode_three_two : IsNode 3 2 := ⟨by norm_num, by norm_num, ⟨1, -1, by ring⟩, ⟨2, by ring⟩⟩

/-- `(p+1, p)` is a node for `p ≥ 1`. -/
lemma isNode_succ_self {p : ℤ} (hp : 1 ≤ p) : IsNode (p + 1) p :=
  ⟨hp, by omega, ⟨1, -1, by ring⟩, ⟨p, by ring⟩⟩

/-! ### The determinant divisibility -/

/-- Any common divisor of the two coordinates of the image of a coprime pair divides the
determinant.  This is the source of the whole obstruction theory. -/
lemma dvd_det_of_dvd_image {M : IntMap} {m n g : ℤ} (h : IsCoprime m n)
    (h1 : g ∣ (M.app m n).1) (h2 : g ∣ (M.app m n).2) : g ∣ M.det := by
  obtain ⟨u, v, huv⟩ := h
  have key : M.det = (u * M.d - v * M.c) * (M.app m n).1 + (v * M.a - u * M.b) * (M.app m n).2 := by
    simp only [IntMap.app_fst, IntMap.app_snd, IntMap.det]
    linear_combination (M.a * M.d - M.b * M.c) * huv.symm
  rw [key]
  exact dvd_add (h1.mul_left _) (h2.mul_left _)

/-! ### Necessity of the parity condition -/

lemma Preserves.parity {M : IntMap} (hM : Preserves M) : Odd (M.a + M.c) ∧ Odd (M.b + M.d) := by
  have h1 := (hM 2 1 isNode_root).odd
  have h2 := (hM 3 2 isNode_three_two).odd
  simp only [IntMap.app_fst, IntMap.app_snd] at h1 h2
  obtain ⟨k, hk⟩ := h1
  obtain ⟨l, hl⟩ := h2
  exact ⟨⟨2 * k - l, by omega⟩, ⟨2 * l - 3 * k - 1, by omega⟩⟩

/-! ### Necessity of the cone (order) conditions -/

lemma Preserves.c_nonneg {M : IntMap} (hM : Preserves M) : 0 ≤ M.c := by
  by_contra hc
  push_neg at hc
  have habs : (0 : ℤ) ≤ |M.d| := abs_nonneg M.d
  have hd : M.d ≤ |M.d| := le_abs_self M.d
  have hm2 : (2 : ℤ) ≤ 2 * (|M.d| + 2) := by omega
  have hme : Even (2 * (|M.d| + 2)) := ⟨|M.d| + 2, by ring⟩
  have hkey := (hM (2 * (|M.d| + 2)) 1 (isNode_even_one hm2 hme)).one_le
  simp only [IntMap.app_snd] at hkey
  have hstep : M.c * (2 * (|M.d| + 2)) ≤ (-1) * (2 * (|M.d| + 2)) :=
    mul_le_mul_of_nonneg_right (by omega) (by omega)
  linarith

lemma Preserves.c_add_d_nonneg {M : IntMap} (hM : Preserves M) : 0 ≤ M.c + M.d := by
  by_contra hcd
  push_neg at hcd
  have habs : (0 : ℤ) ≤ |M.d| := abs_nonneg M.d
  have hd : M.d ≤ |M.d| := le_abs_self M.d
  have hd2 : -M.d ≤ |M.d| := neg_le_abs M.d
  have hm2 : (2 : ℤ) ≤ |M.d| + 2 := by omega
  have hkey := (hM (|M.d| + 2) (|M.d| + 2 - 1) (isNode_spine hm2)).one_le
  simp only [IntMap.app_snd] at hkey
  have hstep : (M.c + M.d) * (|M.d| + 2) ≤ (-1) * (|M.d| + 2) :=
    mul_le_mul_of_nonneg_right (by omega) (by omega)
  nlinarith [hstep, hkey, hd2]

lemma Preserves.cd_ne_zero {M : IntMap} (hM : Preserves M) : ¬(M.c = 0 ∧ M.d = 0) := by
  rintro ⟨hc, hd⟩
  have hkey := (hM 2 1 isNode_root).one_le
  simp only [IntMap.app_snd, hc, hd] at hkey
  omega

lemma Preserves.a_sub_c_nonneg {M : IntMap} (hM : Preserves M) : 0 ≤ M.a - M.c := by
  by_contra hc
  push_neg at hc
  have habs : (0 : ℤ) ≤ |M.b - M.d| := abs_nonneg _
  have hd : M.b - M.d ≤ |M.b - M.d| := le_abs_self _
  have hm2 : (2 : ℤ) ≤ 2 * (|M.b - M.d| + 2) := by omega
  have hme : Even (2 * (|M.b - M.d| + 2)) := ⟨|M.b - M.d| + 2, by ring⟩
  have hkey := (hM (2 * (|M.b - M.d| + 2)) 1 (isNode_even_one hm2 hme)).lt
  simp only [IntMap.app_fst, IntMap.app_snd] at hkey
  have hstep : (M.a - M.c) * (2 * (|M.b - M.d| + 2)) ≤ (-1) * (2 * (|M.b - M.d| + 2)) :=
    mul_le_mul_of_nonneg_right (by omega) (by omega)
  nlinarith

lemma Preserves.diff_add_nonneg {M : IntMap} (hM : Preserves M) :
    0 ≤ (M.a - M.c) + (M.b - M.d) := by
  by_contra hcd
  push_neg at hcd
  have habs : (0 : ℤ) ≤ |M.b - M.d| := abs_nonneg _
  have hd : M.b - M.d ≤ |M.b - M.d| := le_abs_self _
  have hd2 : -(M.b - M.d) ≤ |M.b - M.d| := neg_le_abs _
  have hm2 : (2 : ℤ) ≤ |M.b - M.d| + 2 := by omega
  have hkey := (hM (|M.b - M.d| + 2) (|M.b - M.d| + 2 - 1) (isNode_spine hm2)).lt
  simp only [IntMap.app_fst, IntMap.app_snd] at hkey
  have hstep : ((M.a - M.c) + (M.b - M.d)) * (|M.b - M.d| + 2) ≤ (-1) * (|M.b - M.d| + 2) :=
    mul_le_mul_of_nonneg_right (by omega) (by omega)
  nlinarith [hstep, hkey, hd2]

lemma Preserves.diff_ne_zero {M : IntMap} (hM : Preserves M) :
    ¬(M.a - M.c = 0 ∧ M.b - M.d = 0) := by
  rintro ⟨hc, hd⟩
  have hkey := (hM 2 1 isNode_root).lt
  simp only [IntMap.app_fst, IntMap.app_snd] at hkey
  omega

/-! ### The odd prime obstruction -/

/-- If `p ≥ 3` is odd and `s` is any integer, there is an even `m ≥ 2` congruent to `s` mod `p`. -/
lemma exists_even_ge_two_congr {p s : ℤ} (hp : 3 ≤ p) (hodd : Odd p) :
    ∃ m : ℤ, 2 ≤ m ∧ Even m ∧ ∃ k : ℤ, m = s + p * k := by
  obtain ⟨q, hq⟩ := hodd
  obtain ⟨A, hA⟩ : ∃ A : ℤ, A = (s.natAbs : ℤ) := ⟨_, rfl⟩
  have hA0 : 0 ≤ A := by rw [hA]; exact Int.natCast_nonneg _
  have hAs : -s ≤ A := by rw [hA]; omega
  refine ⟨s * (1 + p) + 2 * p * (A * (1 + p) + 1), ?_,
    ⟨s * (q + 1) + p * (A * (1 + p) + 1), by rw [hq]; ring⟩,
    ⟨s + 2 * (A * (1 + p) + 1), by ring⟩⟩
  have h3 : 0 ≤ A * (1 + p) * (2 * p - 1) :=
    mul_nonneg (mul_nonneg hA0 (by linarith)) (by linarith)
  have h4 : 0 ≤ (s + A) * (1 + p) := mul_nonneg (by linarith) (by linarith)
  nlinarith

/-- **The odd prime obstruction.**  If `M` preserves the node set, then no odd prime divides
`det M`.  In particular `det M ≠ 0`. -/
theorem Preserves.not_odd_prime_dvd_det {M : IntMap} (hM : Preserves M)
    {p : ℕ} (hp : p.Prime) (hodd : Odd p) : ¬ ((p : ℤ) ∣ M.det) := by
  intro hdvd
  have hp3n : 3 ≤ p := by
    have h2 := hp.two_le
    have hne : p ≠ 2 := by rintro rfl; simp [Nat.odd_iff] at hodd
    omega
  have hp3 : (3 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp3n
  have hpodd : Odd ((p : ℤ)) := by
    obtain ⟨k, hk⟩ := hodd
    exact ⟨(k : ℤ), by exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) hk⟩
  have hpp : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  -- a node whose image is divisible by `p` in both coordinates is impossible
  have main : ∀ m n : ℤ, IsNode m n → (p : ℤ) ∣ (M.app m n).1 → (p : ℤ) ∣ (M.app m n).2 →
      False := by
    intro m n hnode h1 h2
    obtain ⟨u, v, huv⟩ := (hM m n hnode).cop
    have hdvd1 : (p : ℤ) ∣ 1 := by
      rw [← huv]; exact dvd_add (h1.mul_left _) (h2.mul_left _)
    have := Int.le_of_dvd one_pos hdvd1
    omega
  -- solving a linear congruence `x * s + y ≡ 0 (mod p)` when `p ∤ x`
  have sol : ∀ x y : ℤ, ¬ (p : ℤ) ∣ x → ∃ s : ℤ, (p : ℤ) ∣ (x * s + y) := by
    intro x y hx
    obtain ⟨u, v, huv⟩ := hpp.coprime_iff_not_dvd.2 hx
    exact ⟨-y * v, y * u, by linear_combination (-y) * huv⟩
  by_cases ha : (p : ℤ) ∣ M.a
  · by_cases hc : (p : ℤ) ∣ M.c
    · -- both entries of the first column vanish mod `p`: use the node `(p+1, p)`
      refine main (p + 1) p (isNode_succ_self (by omega)) ?_ ?_
      · simp only [IntMap.app_fst]
        obtain ⟨x, hx⟩ := ha
        exact ⟨x * (p + 1) + M.b, by rw [hx]; ring⟩
      · simp only [IntMap.app_snd]
        obtain ⟨x, hx⟩ := hc
        exact ⟨x * (p + 1) + M.d, by rw [hx]; ring⟩
    · -- `p ∤ c`: kill the second coordinate first
      obtain ⟨s, hs⟩ := sol M.c M.d hc
      obtain ⟨m, hm2, hme, k, hk⟩ := exists_even_ge_two_congr (s := s) hp3 hpodd
      have h2 : (p : ℤ) ∣ (M.c * m + M.d * 1) := by
        obtain ⟨t, ht⟩ := hs
        exact ⟨t + M.c * k, by rw [hk]; linarith [ht]⟩
      refine main m 1 (isNode_even_one hm2 hme) ?_ h2
      have hkey : M.c * (M.a * m + M.b * 1) = M.a * (M.c * m + M.d * 1) - M.det := by
        simp only [IntMap.det]; ring
      have hd1 : (p : ℤ) ∣ M.c * (M.a * m + M.b * 1) := by
        rw [hkey]; exact dvd_sub (h2.mul_left _) hdvd
      rcases hpp.dvd_mul.1 hd1 with h | h
      · exact absurd h hc
      · simpa using h
  · -- `p ∤ a`: kill the first coordinate first
    obtain ⟨s, hs⟩ := sol M.a M.b ha
    obtain ⟨m, hm2, hme, k, hk⟩ := exists_even_ge_two_congr (s := s) hp3 hpodd
    have h1 : (p : ℤ) ∣ (M.a * m + M.b * 1) := by
      obtain ⟨t, ht⟩ := hs
      exact ⟨t + M.a * k, by rw [hk]; linarith [ht]⟩
    refine main m 1 (isNode_even_one hm2 hme) h1 ?_
    have hkey : M.a * (M.c * m + M.d * 1) = M.c * (M.a * m + M.b * 1) + M.det := by
      simp only [IntMap.det]; ring
    have hd1 : (p : ℤ) ∣ M.a * (M.c * m + M.d * 1) := by
      rw [hkey]; exact dvd_add (h1.mul_left _) hdvd
    rcases hpp.dvd_mul.1 hd1 with h | h
    · exact absurd h ha
    · simpa using h

lemma Preserves.det_ne_zero {M : IntMap} (hM : Preserves M) : M.det ≠ 0 := by
  intro h
  exact hM.not_odd_prime_dvd_det (p := 3) (by norm_num) (by decide) (by simp [h])

/-- **The determinant of a node preserving map is a power of two.** -/
theorem Preserves.det_natAbs_eq_two_pow {M : IntMap} (hM : Preserves M) :
    ∃ k : ℕ, M.det.natAbs = 2 ^ k := by
  have hne : M.det.natAbs ≠ 0 := Int.natAbs_ne_zero.2 hM.det_ne_zero
  refine ⟨M.det.natAbs.primeFactorsList.length, Nat.eq_prime_pow_of_unique_prime_dvd hne ?_⟩
  intro q hq hqd
  by_contra hne2
  exact hM.not_odd_prime_dvd_det hq (hq.odd_of_ne_two hne2)
    (dvd_trans (Int.natCast_dvd_natCast.2 hqd) (Int.natAbs_dvd.mpr dvd_rfl))

/-! ### Sufficiency: the characterisation -/

/-- The conditions appearing in the classification of node preserving maps. -/
structure Admissible (M : IntMap) : Prop where
  parity_ac : Odd (M.a + M.c)
  parity_bd : Odd (M.b + M.d)
  det_no_odd_prime : ∀ p : ℕ, p.Prime → Odd p → ¬ ((p : ℤ) ∣ M.det)
  c_nonneg : 0 ≤ M.c
  cd_nonneg : 0 ≤ M.c + M.d
  cd_ne : ¬(M.c = 0 ∧ M.d = 0)
  ac_nonneg : 0 ≤ M.a - M.c
  diff_nonneg : 0 ≤ (M.a - M.c) + (M.b - M.d)
  diff_ne : ¬(M.a - M.c = 0 ∧ M.b - M.d = 0)

/-- Positivity on the node cone: if `(c, d)` satisfies the cone conditions then
`c m + d n ≥ 1` on every node. -/
lemma cone_pos {c d m n : ℤ} (hc : 0 ≤ c) (hcd : 0 ≤ c + d) (hne : ¬(c = 0 ∧ d = 0))
    (h1 : 1 ≤ n) (h2 : n < m) : 1 ≤ c * m + d * n := by
  rcases eq_or_lt_of_le hc with hc0 | hc0
  · have hd : 1 ≤ d := by
      rcases lt_or_eq_of_le hcd with h | h
      · omega
      · exact absurd ⟨hc0.symm, by omega⟩ hne
    nlinarith
  · by_cases hd : 0 ≤ d
    · nlinarith
    · push_neg at hd
      nlinarith

/-- The image of a node is coprime as soon as the determinant has no odd prime factor and
the image has odd coordinate sum. -/
lemma image_isCoprime {M : IntMap} {m n : ℤ} (hcop : IsCoprime m n)
    (hoddsum : Odd ((M.app m n).1 + (M.app m n).2))
    (hdet : ∀ p : ℕ, p.Prime → Odd p → ¬ ((p : ℤ) ∣ M.det)) :
    IsCoprime (M.app m n).1 (M.app m n).2 := by
  rw [Int.isCoprime_iff_gcd_eq_one]
  by_contra hg
  obtain ⟨q, hq, hqd⟩ := Nat.exists_prime_and_dvd hg
  have hqX : (q : ℤ) ∣ (M.app m n).1 :=
    dvd_trans (Int.natCast_dvd_natCast.2 hqd) (Int.gcd_dvd_left _ _)
  have hqY : (q : ℤ) ∣ (M.app m n).2 :=
    dvd_trans (Int.natCast_dvd_natCast.2 hqd) (Int.gcd_dvd_right _ _)
  have hqdet : (q : ℤ) ∣ M.det := dvd_det_of_dvd_image hcop hqX hqY
  have hq2 : q ≠ 2 := by
    rintro rfl
    obtain ⟨x, hx⟩ := hqX
    obtain ⟨y, hy⟩ := hqY
    obtain ⟨t, ht⟩ := hoddsum
    omega
  exact hdet q hq (hq.odd_of_ne_two hq2) hqdet

/-- **Characterisation of the node preserving integer maps.** -/
theorem preserves_iff (M : IntMap) : Preserves M ↔ Admissible M := by
  constructor
  · intro hM
    exact
      { parity_ac := hM.parity.1
        parity_bd := hM.parity.2
        det_no_odd_prime := fun p hp hodd => hM.not_odd_prime_dvd_det hp hodd
        c_nonneg := hM.c_nonneg
        cd_nonneg := hM.c_add_d_nonneg
        cd_ne := hM.cd_ne_zero
        ac_nonneg := hM.a_sub_c_nonneg
        diff_nonneg := hM.diff_add_nonneg
        diff_ne := hM.diff_ne_zero }
  · intro hA m n hnode
    obtain ⟨h1, h2, hcop, hoddmn⟩ := hnode
    have hsum : Odd ((M.app m n).1 + (M.app m n).2) := by
      obtain ⟨k, hk⟩ := hA.parity_ac
      obtain ⟨l, hl⟩ := hA.parity_bd
      obtain ⟨t, ht⟩ := hoddmn
      refine ⟨k * m + l * n + t, ?_⟩
      simp only [IntMap.app_fst, IntMap.app_snd]
      linear_combination m * hk + n * hl + ht
    have hpos : 1 ≤ (M.app m n).2 :=
      cone_pos hA.c_nonneg hA.cd_nonneg hA.cd_ne h1 h2
    have hlt : (M.app m n).2 < (M.app m n).1 := by
      have hd := cone_pos (c := M.a - M.c) (d := M.b - M.d) hA.ac_nonneg hA.diff_nonneg
        hA.diff_ne h1 h2
      simp only [IntMap.app_fst, IntMap.app_snd]
      nlinarith
    exact ⟨hpos, hlt, image_isCoprime hcop hsum hA.det_no_odd_prime, hsum⟩

end TernaryTree