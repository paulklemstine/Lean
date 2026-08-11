import Mathlib
import Cryptography.BerggrenStars.RationalStarRays

/-!
# The census of a rational star ray: a totient brightness law

How *bright* is a radial line? Along the ray of charge `k` at the boundary rational `p/q` the
Berggren nodes sit at some of the lattice points `(m + tq, n + tp)`; this file computes exactly
which ones, and counts them.

The tool is the `SL₂(ℤ)` change of variables of `RationalStars`: choosing Bezout data
`q x - p y = 1`, the integer points of the ray of charge `k` are exactly

  `(m, n) = (q A + y k,  p A + x k)`,  `A = x m - y n ∈ ℤ`,

and in the coordinates `(A, k)` the two arithmetic conditions defining a Berggren node become
transparent:

  * coprimality `gcd(m,n) = 1`  ⟺  `gcd(A,k) = 1`   (`isCoprime_ray_iff`);
  * parity `m + n` odd          ⟺  `(p+q)A + (x+y)k` odd  (`sum_eq_ray`).

## Main results

* `ray_param_eq` : the `SL₂(ℤ)` parametrisation of a ray.
* `isCoprime_ray_iff` : coprimality of a node ⟺ coprimality of its ray parameter with the
  charge. **The charge is the only arithmetic obstruction along a ray.**
* `parity_free_of_both_odd`, `parity_free_of_even_charge` : the two regimes in which the parity
  condition along the ray is automatic.
* `window_coprime_card` : `#{A ∈ [a, a+2k) : gcd(k,A) = 1} = 2 φ(k)`.
* `ray_census_both_odd`, `ray_census_even_charge`, `ray_census_mixed` : the **brightness law**,
  a clean trichotomy. A window of `2k` consecutive ray parameters carries

    - `2 φ(k)` nodes if `p, q` are both odd (any odd charge `k`),
    - `2 φ(k)` nodes if `p + q` is odd and the charge `k` is even,
    - `φ(k) = φ(2k)` nodes if `p + q` is odd and the charge `k` is odd — *half brightness*.

  Together with the resolution law of `RationalStars`, this is the quantitative description of
  the star map: the star at `p/q` has angular spacing `(1 or 2)/q` in `sinh`, and each of its
  rays has linear node density `φ(k)/k` or `φ(k)/(2k)`. The brightest rays are the ones of
  smallest charge, and `k = ±1` at a both-odd star gives density `1`.
-/

namespace BerggrenRationalStars

open BerggrenHypercycleStars Finset

/-! ## Part 1. The `SL₂(ℤ)` parametrisation of a ray -/

/-- The **ray parameter** of an integer point, relative to Bezout data `q x - p y = 1`. -/
def rayParam (x y m n : ℤ) : ℤ := x * m - y * n

/-- **Parametrisation of a ray.** With `q x - p y = 1`, every integer point `(m,n)` is
recovered from its ray parameter `A = x m - y n` and its star charge `k = q n - p m` by
`(m,n) = (qA + yk, pA + xk)`. So the points of a fixed charge form a lattice line parametrised
by `A`, and the two Berggren conditions become conditions on `(A, k)`. -/
theorem ray_param_eq {p q : ℕ} {x y : ℤ} (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) (m n : ℤ) :
    m = (q : ℤ) * rayParam x y m n + y * ((q : ℤ) * n - (p : ℤ) * m) ∧
      n = (p : ℤ) * rayParam x y m n + x * ((q : ℤ) * n - (p : ℤ) * m) := by
  constructor
  · rw [rayParam]; linear_combination m * hdet.symm
  · rw [rayParam]; linear_combination n * hdet.symm

/-- The parity of a node in ray coordinates. -/
theorem sum_eq_ray {p q : ℕ} {x y : ℤ} (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) (m n : ℤ) :
    m + n = ((p : ℤ) + q) * rayParam x y m n + (x + y) * ((q : ℤ) * n - (p : ℤ) * m) := by
  rw [rayParam]; linear_combination (m + n) * hdet.symm

/-- **Coprimality along a ray.** A point of the ray is primitive exactly when its ray parameter
is coprime to the charge of the ray. Hence *the charge is the only arithmetic obstruction*: on
the rays of charge `±1` every lattice point is primitive. -/
theorem isCoprime_ray_iff {p q : ℕ} {x y : ℤ} (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) (m n : ℤ) :
    IsCoprime m n ↔ IsCoprime (rayParam x y m n) ((q : ℤ) * n - (p : ℤ) * m) := by
  obtain ⟨hm, hn⟩ := ray_param_eq hdet m n
  constructor
  · rintro ⟨u, v, huv⟩
    refine ⟨u * q + v * p, u * y + v * x, ?_⟩
    calc (u * q + v * p) * rayParam x y m n
          + (u * y + v * x) * ((q : ℤ) * n - (p : ℤ) * m)
        = u * ((q : ℤ) * rayParam x y m n + y * ((q : ℤ) * n - (p : ℤ) * m))
          + v * ((p : ℤ) * rayParam x y m n + x * ((q : ℤ) * n - (p : ℤ) * m)) := by ring
      _ = u * m + v * n := by rw [← hm, ← hn]
      _ = 1 := huv
  · rintro ⟨u, v, huv⟩
    refine ⟨u * x - v * p, v * q - u * y, ?_⟩
    have hA : x * m - y * n = rayParam x y m n := rfl
    calc (u * x - v * p) * m + (v * q - u * y) * n
        = u * (x * m - y * n) + v * ((q : ℤ) * n - (p : ℤ) * m) := by ring
      _ = u * rayParam x y m n + v * ((q : ℤ) * n - (p : ℤ) * m) := by rw [hA]
      _ = 1 := huv

/-! ## Part 2. The two parity-free regimes -/

/-- With `p, q` both odd, the Bezout cofactors satisfy `x + y` odd.  This is the arithmetic
reason why the both-odd stars have their rays *doubly* spaced: `q x - p y = 1` forces
`x - y` odd. -/
theorem odd_bezout_sum {p q : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) : Odd (x + y) := by
  obtain ⟨a, ha⟩ := Nat.odd_iff.mpr hp
  obtain ⟨b, hb⟩ := Nat.odd_iff.mpr hq
  have ha' : (p : ℤ) = 2 * a + 1 := by rw [ha]; push_cast; ring
  have hb' : (q : ℤ) = 2 * b + 1 := by rw [hb]; push_cast; ring
  rw [ha', hb'] at hdet
  exact ⟨-(b : ℤ) * x + (a : ℤ) * y + y, by linear_combination hdet⟩

/-- If `p` and `q` are both odd and the charge is odd, the parity condition along the ray holds
for *every* ray parameter: the only sieve on the ray is coprimality with the charge. -/
theorem parity_free_of_both_odd {p q : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℤ} (hk : Odd k) (A : ℤ) :
    Odd (((p : ℤ) + q) * A + (x + y) * k) := by
  have hpq : Even ((p : ℤ) + q) := by
    obtain ⟨a, ha⟩ := Nat.odd_iff.mpr hp
    obtain ⟨b, hb⟩ := Nat.odd_iff.mpr hq
    exact ⟨(a : ℤ) + b + 1, by rw [ha, hb]; push_cast; ring⟩
  exact (hpq.mul_right A).add_odd ((odd_bezout_sum hp hq hdet).mul hk)

/-- If the charge is even (and `p + q` is odd), coprimality with the charge already forces the
right parity: again the only sieve on the ray is coprimality. -/
theorem parity_free_of_even_charge {p q : ℕ} (hpq : (p + q) % 2 = 1) {x y : ℤ} {k : ℤ}
    (hk : Even k) {A : ℤ} (hA : IsCoprime A k) :
    Odd (((p : ℤ) + q) * A + (x + y) * k) := by
  -- `A` must be odd, since `gcd(A,k) = 1` and `k` is even
  have hAodd : Odd A := by
    rcases Int.even_or_odd A with hAe | hAo
    · exfalso
      obtain ⟨u, v, huv⟩ := hA
      obtain ⟨a, rfl⟩ := hAe
      obtain ⟨b, rfl⟩ := hk
      have h2 : (2 : ℤ) ∣ 1 := ⟨u * a + v * b, by linear_combination -huv⟩
      norm_num at h2
    · exact hAo
  have hpqodd : Odd ((p : ℤ) + q) := by
    obtain ⟨c, hc⟩ := Nat.odd_iff.mpr hpq
    exact ⟨(c : ℤ), by have : ((p + q : ℕ) : ℤ) = 2 * c + 1 := by rw [hc]; push_cast; ring
                       push_cast at this; linarith⟩
  exact (hpqodd.mul hAodd).add_even (hk.mul_left (x + y))

/-! ## Part 3. The brightness law -/

/-- A window of `2k` consecutive integers contains exactly `2 φ(k)` integers coprime to `k`. -/
theorem window_coprime_card (k a : ℕ) :
    #{A ∈ Finset.Ico a (a + 2 * k) | Nat.Coprime k A} = 2 * Nat.totient k := by
  have hsplit : Finset.Ico a (a + 2 * k) = Finset.Ico a (a + k) ∪ Finset.Ico (a + k) (a + 2 * k) :=
    (Finset.Ico_union_Ico_eq_Ico (by omega) (by omega)).symm
  have hdisj : Disjoint (Finset.Ico a (a + k)) (Finset.Ico (a + k) (a + 2 * k)) :=
    Finset.Ico_disjoint_Ico_consecutive _ _ _
  rw [hsplit, Finset.filter_union, Finset.card_union_of_disjoint
    (Finset.disjoint_filter_filter hdisj)]
  have h1 : #{A ∈ Finset.Ico a (a + k) | Nat.Coprime k A} = Nat.totient k :=
    Nat.filter_coprime_Ico_eq_totient k a
  have h2 : #{A ∈ Finset.Ico (a + k) (a + 2 * k) | Nat.Coprime k A} = Nat.totient k := by
    have := Nat.filter_coprime_Ico_eq_totient k (a + k)
    rwa [show a + k + k = a + 2 * k by ring] at this
  rw [h1, h2]
  ring

/-- The arithmetic heart of the census: in ray coordinates the two Berggren conditions collapse
to the single condition `gcd(k, A) = 1`, in either parity-free regime. -/
theorem node_iff_coprime_of_both_odd {p q : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℕ} (hk : k % 2 = 1) (A : ℕ) :
    (IsCoprime ((q : ℤ) * (A : ℤ) + y * k) ((p : ℤ) * (A : ℤ) + x * k) ∧
      Odd (((q : ℤ) * (A : ℤ) + y * k) + ((p : ℤ) * (A : ℤ) + x * k))) ↔ Nat.Coprime k A := by
  have hkodd : Odd (k : ℤ) := by rw [Int.odd_iff]; omega
  set m : ℤ := (q : ℤ) * (A : ℤ) + y * k with hm
  set n : ℤ := (p : ℤ) * (A : ℤ) + x * k with hn
  have hA : rayParam x y m n = (A : ℤ) := by
    simp only [rayParam, hm, hn]; linear_combination (A : ℤ) * hdet
  have hkk : (q : ℤ) * n - (p : ℤ) * m = (k : ℤ) := by
    simp only [hm, hn]; linear_combination (k : ℤ) * hdet
  have hsum : m + n = ((p : ℤ) + q) * (A : ℤ) + (x + y) * (k : ℤ) := by
    have h := sum_eq_ray hdet m n
    rwa [hA, hkk] at h
  constructor
  · rintro ⟨hc, -⟩
    have hcop := (isCoprime_ray_iff hdet m n).mp hc
    rw [hA, hkk] at hcop
    have hg : Int.gcd (A : ℤ) (k : ℤ) = 1 := Int.isCoprime_iff_gcd_eq_one.mp hcop
    have hnat : Nat.Coprime A k := by simpa [Int.gcd_natCast_natCast] using hg
    exact hnat.symm
  · intro hc
    refine ⟨?_, ?_⟩
    · rw [isCoprime_ray_iff hdet, hA, hkk, Int.isCoprime_iff_gcd_eq_one]
      simpa [Int.gcd_natCast_natCast] using hc.symm
    · rw [hsum]
      exact parity_free_of_both_odd hp hq hdet hkodd (A : ℤ)

/-- Even-charge analogue of `node_iff_coprime_of_both_odd`. -/
theorem node_iff_coprime_of_even_charge {p q : ℕ} (hpq : (p + q) % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℕ} (hk : k % 2 = 0) (A : ℕ) :
    (IsCoprime ((q : ℤ) * (A : ℤ) + y * k) ((p : ℤ) * (A : ℤ) + x * k) ∧
      Odd (((q : ℤ) * (A : ℤ) + y * k) + ((p : ℤ) * (A : ℤ) + x * k))) ↔ Nat.Coprime k A := by
  have hkeven : Even (k : ℤ) := by rw [Int.even_iff]; omega
  set m : ℤ := (q : ℤ) * (A : ℤ) + y * k with hm
  set n : ℤ := (p : ℤ) * (A : ℤ) + x * k with hn
  have hA : rayParam x y m n = (A : ℤ) := by
    simp only [rayParam, hm, hn]; linear_combination (A : ℤ) * hdet
  have hkk : (q : ℤ) * n - (p : ℤ) * m = (k : ℤ) := by
    simp only [hm, hn]; linear_combination (k : ℤ) * hdet
  have hsum : m + n = ((p : ℤ) + q) * (A : ℤ) + (x + y) * (k : ℤ) := by
    have h := sum_eq_ray hdet m n
    rwa [hA, hkk] at h
  constructor
  · rintro ⟨hc, -⟩
    have hcop := (isCoprime_ray_iff hdet m n).mp hc
    rw [hA, hkk] at hcop
    have hg : Int.gcd (A : ℤ) (k : ℤ) = 1 := Int.isCoprime_iff_gcd_eq_one.mp hcop
    have hnat : Nat.Coprime A k := by simpa [Int.gcd_natCast_natCast] using hg
    exact hnat.symm
  · intro hc
    have hcop : IsCoprime ((A : ℤ)) ((k : ℤ)) := by
      rw [Int.isCoprime_iff_gcd_eq_one]
      simpa [Int.gcd_natCast_natCast] using hc.symm
    refine ⟨?_, ?_⟩
    · rw [isCoprime_ray_iff hdet, hA, hkk]; exact hcop
    · rw [hsum]
      exact parity_free_of_even_charge (x := x) (y := y) hpq hkeven hcop

open scoped Classical in
/-- **Brightness of a ray, both-odd case.** Let `p, q` be odd and let `k` be an odd charge.
Then, in any window of `2k` consecutive ray parameters, exactly `2 φ(k)` give Berggren nodes:
the ray has linear node density `φ(k)/k`. In particular the unit rays `k = 1` are completely
full, and a ray of prime charge `r` has density `1 - 1/r`. -/
theorem ray_census_both_odd {p q : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℕ} (hk : k % 2 = 1) (a : ℕ) :
    #((Finset.Ico a (a + 2 * k)).filter (fun A : ℕ =>
        IsCoprime ((q : ℤ) * (A : ℤ) + y * k) ((p : ℤ) * (A : ℤ) + x * k) ∧
          Odd (((q : ℤ) * (A : ℤ) + y * k) + ((p : ℤ) * (A : ℤ) + x * k)))) = 2 * Nat.totient k := by
  rw [Finset.filter_congr (fun A _ => node_iff_coprime_of_both_odd hp hq hdet hk A),
    window_coprime_card]

open scoped Classical in
/-- **Brightness of a ray, even-charge case.** When `p + q` is odd and the charge `k` is even,
the same law holds: `2 φ(k)` nodes per window of `2k` ray parameters. -/
theorem ray_census_even_charge {p q : ℕ} (hpq : (p + q) % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℕ} (hk : k % 2 = 0) (a : ℕ) :
    #((Finset.Ico a (a + 2 * k)).filter (fun A : ℕ =>
        IsCoprime ((q : ℤ) * (A : ℤ) + y * k) ((p : ℤ) * (A : ℤ) + x * k) ∧
          Odd (((q : ℤ) * (A : ℤ) + y * k) + ((p : ℤ) * (A : ℤ) + x * k)))) = 2 * Nat.totient k := by
  rw [Finset.filter_congr (fun A _ => node_iff_coprime_of_even_charge hpq hdet hk A),
    window_coprime_card]

/-- **Unit rays are completely full.**  Specialising the brightness law to `k = 1`: every one of
the `2` ray parameters in a window of length `2` gives a Berggren node.  This is the sharpest
form of "the brightest radial lines are the ones of charge `±1`". -/
theorem unit_ray_full {p q : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) (a : ℕ) :
    #((Finset.Ico a (a + 2 * 1)).filter (fun A : ℕ =>
        IsCoprime ((q : ℤ) * (A : ℤ) + y * ((1 : ℕ) : ℤ)) ((p : ℤ) * (A : ℤ) + x * ((1 : ℕ) : ℤ)) ∧
          Odd (((q : ℤ) * (A : ℤ) + y * ((1 : ℕ) : ℤ))
            + ((p : ℤ) * (A : ℤ) + x * ((1 : ℕ) : ℤ))))) = 2 := by
  classical
  rw [ray_census_both_odd hp hq hdet (k := 1) (by norm_num) a]
  simp

/-! ## Part 4. The third regime: half-brightness at mixed parity

The remaining case is `p + q` odd with an **odd** charge `k`.  Here the parity condition is not
automatic: it pins the ray parameter `A` to a *single residue class mod 2*, and the brightness
drops by exactly a factor of two, from `2 φ(k)` to `φ(k) = φ(2k)` nodes per window of `2k`.
This is the arithmetic shadow of the resolution law: at a star `p/q` with `p+q` odd the rays are
spaced `1/q` apart in `sinh`, twice as finely as at a both-odd star, and correspondingly each
individual ray is only half as bright. -/

/-- Parity along a ray in the mixed regime: with `p+q` odd and `k` odd, the node condition forces
the ray parameter into one fixed residue class mod `2`, determined by the parity of the Bezout
cofactor sum `x + y`. -/
theorem parity_mixed {p q : ℕ} (hpq : (p + q) % 2 = 1) {x y : ℤ} {k : ℕ} (hk : k % 2 = 1)
    (A : ℕ) :
    Odd (((p : ℤ) + q) * A + (x + y) * k) ↔ A % 2 = (if Even (x + y) then 1 else 0) := by
  have hpqodd : Odd ((p : ℤ) + q) := by
    have : Odd ((p + q : ℕ) : ℤ) := by rw [Int.odd_iff]; omega
    simpa using this
  have hkodd : Odd (k : ℤ) := by rw [Int.odd_iff]; omega
  obtain ⟨c, hc⟩ := hpqodd.sub_odd (odd_one (α := ℤ))
  obtain ⟨d, hd⟩ := hkodd.sub_odd (odd_one (α := ℤ))
  have hdiff : Even ((((p : ℤ) + q) * A + (x + y) * k) - ((A : ℤ) + (x + y))) :=
    ⟨(A : ℤ) * c + (x + y) * d, by linear_combination (A : ℤ) * hc + (x + y) * hd⟩
  have hiff : Odd (((p : ℤ) + q) * A + (x + y) * k) ↔ Odd ((A : ℤ) + (x + y)) := by
    rw [← Int.not_even_iff_odd, ← Int.not_even_iff_odd, not_iff_not]
    exact Int.even_sub.mp hdiff
  rw [hiff]
  rcases Int.even_or_odd (x + y) with he | ho
  · rw [if_pos he]
    constructor
    · intro h
      have hAodd : Odd (A : ℤ) := by
        rcases Int.even_or_odd (A : ℤ) with h1 | h1
        · exact absurd h (by simp [Int.not_odd_iff_even, h1.add he])
        · exact h1
      have := Int.odd_iff.mp hAodd
      omega
    · intro h
      have hA : Odd (A : ℤ) := by rw [Int.odd_iff]; omega
      exact hA.add_even he
  · rw [if_neg (by simpa [Int.not_even_iff_odd] using ho)]
    constructor
    · intro h
      have hAeven : Even (A : ℤ) := by
        rcases Int.even_or_odd (A : ℤ) with h1 | h1
        · exact h1
        · exact absurd h (by simp [Int.not_odd_iff_even, h1.add_odd ho])
      have := Int.even_iff.mp hAeven
      omega
    · intro h
      have hA : Even (A : ℤ) := by rw [Int.even_iff]; omega
      exact hA.add_odd ho

/-- A window of `2k` consecutive integers (`k` odd) contains exactly `φ(k)` integers that are
coprime to `k` **and** of a prescribed parity: the parity condition halves the count. -/
theorem window_coprime_parity_card {k : ℕ} (hk : k % 2 = 1) (a e : ℕ) :
    #((Finset.Ico a (a + 2 * k)).filter (fun A : ℕ => Nat.Coprime k A ∧ A % 2 = e % 2))
      = Nat.totient k := by
  classical
  rw [← Nat.filter_coprime_Ico_eq_totient k a]
  refine (Finset.card_nbij' (i := fun B => if B % 2 = e % 2 then B else B + k)
    (j := fun A => if A < a + k then A else A - k) ?_ ?_ ?_ ?_).symm
  · intro B hB
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hB ⊢
    obtain ⟨⟨h1, h2⟩, hc⟩ := hB
    by_cases hp : B % 2 = e % 2
    · rw [if_pos hp]; exact ⟨⟨by omega, by omega⟩, hc, hp⟩
    · rw [if_neg hp]
      exact ⟨⟨by omega, by omega⟩, Nat.coprime_add_self_right.mpr hc, by omega⟩
  · intro A hA
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hA ⊢
    obtain ⟨⟨h1, h2⟩, hc, hpar⟩ := hA
    by_cases hlt : A < a + k
    · rw [if_pos hlt]; exact ⟨⟨h1, hlt⟩, hc⟩
    · rw [if_neg hlt]
      have hAk : A - k + k = A := by omega
      refine ⟨⟨by omega, by omega⟩, ?_⟩
      exact (Nat.coprime_add_self_right (m := k) (n := A - k)).mp (by rwa [hAk])
  · intro B hB
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hB
    obtain ⟨⟨h1, h2⟩, hc⟩ := hB
    by_cases hp : B % 2 = e % 2
    · simp only [if_pos hp, if_pos h2]
    · simp only [if_neg hp]
      rw [if_neg (by omega)]
      omega
  · intro A hA
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hA
    obtain ⟨⟨h1, h2⟩, hc, hpar⟩ := hA
    by_cases hlt : A < a + k
    · simp only [if_pos hlt, if_pos hpar]
    · simp only [if_neg hlt]
      rw [if_neg (by omega)]
      omega

/-- Node characterisation in the mixed regime. -/
theorem node_iff_of_mixed {p q : ℕ} (hpq : (p + q) % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℕ} (hk : k % 2 = 1) (A : ℕ) :
    (IsCoprime ((q : ℤ) * (A : ℤ) + y * k) ((p : ℤ) * (A : ℤ) + x * k) ∧
      Odd (((q : ℤ) * (A : ℤ) + y * k) + ((p : ℤ) * (A : ℤ) + x * k))) ↔
      (Nat.Coprime k A ∧ A % 2 = (if Even (x + y) then 1 else 0) % 2) := by
  have he2 : (if Even (x + y) then 1 else 0) % 2 = (if Even (x + y) then 1 else 0) := by
    split_ifs <;> rfl
  rw [he2]
  set m : ℤ := (q : ℤ) * (A : ℤ) + y * k with hm
  set n : ℤ := (p : ℤ) * (A : ℤ) + x * k with hn
  have hA : rayParam x y m n = (A : ℤ) := by
    simp only [rayParam, hm, hn]; linear_combination (A : ℤ) * hdet
  have hkk : (q : ℤ) * n - (p : ℤ) * m = (k : ℤ) := by
    simp only [hm, hn]; linear_combination (k : ℤ) * hdet
  have hsum : m + n = ((p : ℤ) + q) * (A : ℤ) + (x + y) * (k : ℤ) := by
    have h := sum_eq_ray hdet m n
    rwa [hA, hkk] at h
  have hcopiff : IsCoprime m n ↔ Nat.Coprime k A := by
    rw [isCoprime_ray_iff hdet, hA, hkk, Int.isCoprime_iff_gcd_eq_one]
    constructor
    · intro hg
      have hnat : Nat.Coprime A k := by simpa [Int.gcd_natCast_natCast] using hg
      exact hnat.symm
    · intro hc
      simpa [Int.gcd_natCast_natCast] using hc.symm
  rw [hcopiff, hsum, parity_mixed hpq hk A]

open scoped Classical in
/-- **Brightness of a ray, mixed regime (half-brightness).** When `p + q` is odd and the charge
`k` is odd, a window of `2k` ray parameters carries exactly `φ(k) = φ(2k)` Berggren nodes —
half of the `2 φ(k)` of the other two regimes.  This completes the trichotomy of the brightness
law and explains, together with the resolution law, the two visually distinct kinds of star. -/
theorem ray_census_mixed {p q : ℕ} (hpq : (p + q) % 2 = 1) {x y : ℤ}
    (hdet : (q : ℤ) * x - (p : ℤ) * y = 1) {k : ℕ} (hk : k % 2 = 1) (a : ℕ) :
    #((Finset.Ico a (a + 2 * k)).filter (fun A : ℕ =>
        IsCoprime ((q : ℤ) * (A : ℤ) + y * k) ((p : ℤ) * (A : ℤ) + x * k) ∧
          Odd (((q : ℤ) * (A : ℤ) + y * k) + ((p : ℤ) * (A : ℤ) + x * k))))
      = Nat.totient k := by
  rw [Finset.filter_congr (fun A _ => node_iff_of_mixed hpq hdet hk A),
    window_coprime_parity_card hk a]

end BerggrenRationalStars