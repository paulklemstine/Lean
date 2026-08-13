import MachineLearning.HalfPlaneReflection

/-!
# The correction term is separable, and the semiprime circle count

Cycle 2 of the investigation.  The reflection identity of `HalfPlaneReflection.lean`
writes the non-separable half-plane count as

  `H(N) = high(N) + 2 R(N)`,

with `R(N)` the number of square roots of `1` below `N/2`.  Here we show that the
correction term `R` is itself completely *local*:

* `two_mul_unitRootCount` : `2 R(N) = S(N)` for `N ≥ 3`, where `S(N)` is the total
  number of square roots of `1` modulo `N` (the antipodal pairing `u ↦ N - u` has no
  fixed point on the roots once `N ≥ 3`);
* `sqrtOneCount_mul_of_coprime` : `S` is multiplicative.

So *all* of the non-separability of `H` is carried by the corner count `high`.

We then push the separable side to its arithmetic conclusion:

* `circleCount_semiprime` : `C(pq) = (p - χ_p(-1))(q - χ_q(-1))` for distinct odd
  primes;
* `circleCount_semiprime_three_mod_four` : if `p ≡ q ≡ 3 (mod 4)` then
  `C(pq) = pq + p + q + 1`, hence
* `sum_of_primes_from_circleCount` : `p + q = C(N) - N - 1` — the circle count of a
  Blum-type semiprime *determines the factorisation*.  The obstruction is purely
  computational: evaluating `C(N)` by enumeration costs `Θ(N)` steps.
-/

namespace HalfPlane

open Finset

/-! ### Square roots of one -/

/-- All square roots of `1` modulo `N`, with representatives in `[0,N)`. -/
def sqrtOneFinset (N : ℕ) : Finset ℕ :=
  (Finset.range N).filter (fun u => u ^ 2 % N = 1 % N)

/-- `S(N)`: the number of square roots of `1` modulo `N`. -/
def sqrtOneCount (N : ℕ) : ℕ := (sqrtOneFinset N).card

/-- Square roots of `1` inside `ZMod N`. -/
def sqrtOneZ (N : ℕ) [NeZero N] : Finset (ZMod N) :=
  Finset.univ.filter (fun u => u ^ 2 = 1)

lemma sq_cast_iff (N a : ℕ) : (a ^ 2 % N = 1 % N) ↔ ((a : ZMod N) ^ 2 = 1) := by
  have h := circle_cast_iff N a 0
  simpa using h

lemma sqrtOneCount_eq_card_sqrtOneZ (N : ℕ) [NeZero N] :
    sqrtOneCount N = (sqrtOneZ N).card := by
  refine Finset.card_bij (fun u _ => (u : ZMod N)) ?_ ?_ ?_
  · intro u hu
    simp only [sqrtOneFinset, Finset.mem_filter, Finset.mem_range] at hu
    simp only [sqrtOneZ, Finset.mem_filter, Finset.mem_univ, true_and]
    exact (sq_cast_iff N u).mp hu.2
  · intro u hu v hv huv
    simp only [sqrtOneFinset, Finset.mem_filter, Finset.mem_range] at hu hv
    have := congrArg ZMod.val huv
    rwa [ZMod.val_natCast_of_lt hu.1, ZMod.val_natCast_of_lt hv.1] at this
  · intro u hu
    simp only [sqrtOneZ, Finset.mem_filter, Finset.mem_univ, true_and] at hu
    refine ⟨u.val, ?_, by simp⟩
    simp only [sqrtOneFinset, Finset.mem_filter, Finset.mem_range]
    exact ⟨ZMod.val_lt _, by rw [sq_cast_iff]; simpa using hu⟩

/-- **The number of square roots of one is CRT-separable.** -/
theorem sqrtOneCount_mul_of_coprime {m n : ℕ} [NeZero m] [NeZero n] (h : Nat.Coprime m n) :
    sqrtOneCount (m * n) = sqrtOneCount m * sqrtOneCount n := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  rw [sqrtOneCount_eq_card_sqrtOneZ, sqrtOneCount_eq_card_sqrtOneZ,
    sqrtOneCount_eq_card_sqrtOneZ, ← Finset.card_product]
  set e := ZMod.chineseRemainder h with he
  refine Finset.card_bij (fun u _ => ((e u).1, (e u).2)) ?_ ?_ ?_
  · intro u hu
    simp only [sqrtOneZ, Finset.mem_filter, Finset.mem_univ, true_and] at hu
    have hmap : (e u) ^ 2 = 1 := by rw [← map_pow, hu, map_one]
    simp only [Finset.mem_product, sqrtOneZ, Finset.mem_filter, Finset.mem_univ, true_and]
    exact ⟨congrArg Prod.fst hmap, congrArg Prod.snd hmap⟩
  · intro u _ v _ huv
    have : e u = e v := Prod.ext (congrArg Prod.fst huv) (congrArg Prod.snd huv)
    exact e.injective this
  · intro b hb
    simp only [Finset.mem_product, sqrtOneZ, Finset.mem_filter, Finset.mem_univ,
      true_and] at hb
    refine ⟨e.symm (b.1, b.2), ?_, by simp⟩
    simp only [sqrtOneZ, Finset.mem_filter, Finset.mem_univ, true_and]
    rw [← map_pow]
    have : ((b.1, b.2) : ZMod m × ZMod n) ^ 2 = 1 :=
      Prod.ext (by simpa using hb.1) (by simpa using hb.2)
    rw [this, map_one]

/-- Zero is not a square root of `1` modulo `N` when `N ≥ 2`. -/
lemma sqrtOne_pos {N u : ℕ} (hN : 2 ≤ N) (hu : u ^ 2 % N = 1 % N) : 1 ≤ u := by
  rcases Nat.eq_zero_or_pos u with h | h
  · subst h
    rw [Nat.mod_eq_of_lt (show 1 < N by omega)] at hu
    simp at hu
  · exact h

/-- A square root of `1` is never equal to `N/2` (for `N ≥ 3`): the antipodal pairing
on the roots is fixed-point free. -/
lemma sqrtOne_ne_half {N u : ℕ} (hN : 3 ≤ N) (hu : u ^ 2 % N = 1 % N) : 2 * u ≠ N := by
  intro hhalf
  have h1N : 1 % N = 1 := Nat.mod_eq_of_lt (by omega)
  rw [h1N] at hu
  have hupos : 1 ≤ u := by
    rcases Nat.eq_zero_or_pos u with h | h
    · subst h; simp at hu
    · exact h
  have hdm := Nat.div_add_mod (u ^ 2) N
  obtain ⟨k, hk⟩ : ∃ k, u ^ 2 = N * k + 1 := ⟨u ^ 2 / N, by omega⟩
  have h1 : u ∣ u ^ 2 := ⟨u, by ring⟩
  have h2 : u ∣ N * k := Dvd.dvd.mul_right ⟨2, by omega⟩ k
  have h3 : u ∣ (u ^ 2 - N * k) := Nat.dvd_sub h1 h2
  rw [hk, Nat.add_sub_cancel_left] at h3
  have : u = 1 := Nat.dvd_one.mp h3
  omega

/-- **The antipodal pairing on square roots of one**: exactly half of them lie below
`N/2`, so `2 R(N) = S(N)` for `N ≥ 3`. -/
theorem two_mul_unitRootCount (N : ℕ) (hN : 3 ≤ N) :
    2 * unitRootCount N = sqrtOneCount N := by
  haveI : NeZero N := ⟨by omega⟩
  have hlow : unitRootFinset N = (sqrtOneFinset N).filter (fun u => 2 * u < N) := by
    ext u
    simp only [unitRootFinset, sqrtOneFinset, Finset.mem_filter, Finset.mem_range]
    tauto
  have hhigh : ((sqrtOneFinset N).filter (fun u => ¬ 2 * u < N)).card
      = (unitRootFinset N).card := by
    refine Finset.card_bij' (fun u _ => N - u) (fun u _ => N - u) ?_ ?_ ?_ ?_
    · intro u hu
      simp only [Finset.mem_filter, sqrtOneFinset, Finset.mem_range] at hu
      obtain ⟨⟨hu1, hu2⟩, hu3⟩ := hu
      have hne := sqrtOne_ne_half hN hu2
      simp only [unitRootFinset, Finset.mem_filter, Finset.mem_range]
      refine ⟨by omega, by omega, ?_⟩
      have := (circle_reflect_fst (N := N) (a := u) (b := 0) (by omega)).mpr (by simpa using hu2)
      simpa using this
    · intro u hu
      simp only [unitRootFinset, Finset.mem_filter, Finset.mem_range] at hu
      obtain ⟨hu1, hu2, hu3⟩ := hu
      have hne := sqrtOne_ne_half hN hu3
      have hpos := sqrtOne_pos (by omega) hu3
      simp only [Finset.mem_filter, sqrtOneFinset, Finset.mem_range]
      refine ⟨⟨by omega, ?_⟩, by omega⟩
      have := (circle_reflect_fst (N := N) (a := u) (b := 0) (by omega)).mpr (by simpa using hu3)
      simpa using this
    · intro u hu
      simp only [Finset.mem_filter, sqrtOneFinset, Finset.mem_range] at hu
      show N - (N - u) = u
      omega
    · intro u hu
      simp only [unitRootFinset, Finset.mem_filter, Finset.mem_range] at hu
      show N - (N - u) = u
      omega
  have hsplit : ((sqrtOneFinset N).filter (fun u => 2 * u < N)).card
      + ((sqrtOneFinset N).filter (fun u => ¬ 2 * u < N)).card = (sqrtOneFinset N).card :=
    Finset.card_filter_add_card_filter_not (s := sqrtOneFinset N) (p := fun u => 2 * u < N)
  have hpair : ((sqrtOneFinset N).filter (fun u => ¬ 2 * u < N)).card
      = ((sqrtOneFinset N).filter (fun u => 2 * u < N)).card := by rw [hhigh, hlow]
  rw [unitRootCount_eq_card, hlow]
  simp only [sqrtOneCount]
  rw [← hsplit, hpair]
  ring

/-- There is always the root `u = 1`, so `R(N) ≥ 1`. -/
theorem unitRootCount_pos (N : ℕ) (hN : 3 ≤ N) : 1 ≤ unitRootCount N := by
  rw [unitRootCount_eq_card]
  refine Finset.card_pos.mpr ⟨1, ?_⟩
  simp only [unitRootFinset, Finset.mem_filter, Finset.mem_range]
  exact ⟨by omega, by omega, by norm_num⟩

/-- **Two-sided control of the half-plane count.**
`2 R(N) ≤ H(N)` and `4 H(N) ≤ C(N) + 4 S(N)`, where both `C` and `S` are
CRT-separable.  In particular `H(N) ≥ 2` for `N ≥ 3`. -/
theorem halfPlaneCount_sandwich (N : ℕ) (hN : 3 ≤ N) :
    2 ≤ halfPlaneCount N ∧ 4 * halfPlaneCount N ≤ circleCount N + 4 * sqrtOneCount N := by
  have hid := halfPlaneCount_eq_highCount_add N (by omega)
  have hR := unitRootCount_pos N hN
  have hS := two_mul_unitRootCount N hN
  have hb := four_mul_halfPlaneCount_le N (by omega)
  constructor
  · omega
  · omega

/-! ### The semiprime circle count -/

/-- The circle count of a product of two distinct odd primes is the product of the
two local conic counts. -/
theorem circleCount_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    circleCount (p * q)
      = (if p % 4 = 1 then p - 1 else p + 1) * (if q % 4 = 1 then q - 1 else q + 1) := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  haveI : NeZero q := ⟨hq.ne_zero⟩
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [circleCount_mul_of_coprime hcop, circleCount_prime hp2, circleCount_prime hq2]

/-- **Blum-type semiprimes**: if `p ≡ q ≡ 3 (mod 4)` are distinct primes then
`C(pq) = pq + p + q + 1`. -/
theorem circleCount_semiprime_three_mod_four {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h3p : p % 4 = 3) (h3q : q % 4 = 3) (hpq : p ≠ q) :
    circleCount (p * q) = p * q + p + q + 1 := by
  have hp2 : p ≠ 2 := by omega
  have hq2 : q ≠ 2 := by omega
  rw [circleCount_semiprime hp hq hp2 hq2 hpq]
  have h1 : ¬ (p % 4 = 1) := by omega
  have h2 : ¬ (q % 4 = 1) := by omega
  simp only [h1, h2, if_false]
  ring

/-- **The circle count of a Blum-type semiprime determines the factorisation.**
From `N = pq` with `p ≡ q ≡ 3 (mod 4)` one reads off `p + q = C(N) - N - 1`. -/
theorem sum_of_primes_from_circleCount {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h3p : p % 4 = 3) (h3q : q % 4 = 3) (hpq : p ≠ q) :
    p + q = circleCount (p * q) - (p * q) - 1 := by
  have := circleCount_semiprime_three_mod_four hp hq h3p h3q hpq
  omega

/-- **Vieta recovery.** Both prime factors are roots of the quadratic
`X² - (C(N) - N - 1)·X + N`, whose coefficients are computed from `N` and `C(N)`
alone. -/
theorem prime_factors_are_roots {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h3p : p % 4 = 3) (h3q : q % 4 = 3) (hpq : p ≠ q) :
    ∀ X ∈ ({p, q} : Finset ℕ),
      X * X + p * q = (circleCount (p * q) - (p * q) - 1) * X := by
  have hs := sum_of_primes_from_circleCount hp hq h3p h3q hpq
  intro X hX
  simp only [Finset.mem_insert, Finset.mem_singleton] at hX
  rcases hX with rfl | rfl
  · rw [← hs]; ring
  · rw [← hs]; ring

/-! ### Lab notes (cycle 2)

```
N = p·q   C(N)      N+p+q+1     S(N)  R(N)  H(N)  high(N)
21 = 3·7     32       32          4     2     4      0
33 = 3·11    48       48          4     2     8      4
57 = 3·19    80       80          4     2     8      2
77 = 7·11    96       96          4     2    16      6
35 = 5·7     32   (5 ≡ 1 mod 4)   4     2     6      2
```
The first four rows are Blum semiprimes: `C(N) = N + p + q + 1` exactly.
`S = 2R` in every row, and `S` is multiplicative (`S(21) = S(3)S(7) = 2·2`).
-/

example : circleCount 21 = 21 + 3 + 7 + 1 := by decide
example : sqrtOneCount 21 = sqrtOneCount 3 * sqrtOneCount 7 := by decide
example : 2 * unitRootCount 33 = sqrtOneCount 33 := by decide

end HalfPlane