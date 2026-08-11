import Mathlib
import Cryptography.BerggrenStars.HypercycleStars

/-!
# The rational stars of the Berggren tree: the exact charge spectrum and the visibility law

`Cryptography.BerggrenStars.HypercycleStars` shows that over *every* rational boundary point
`p/q` of the Poincaré half-plane sits a pencil ("star") of Euclidean rays, the hypercycles at
distance `arsinh (|k|/q)` from the geodesic over `p/q`, indexed by the **star charge**

  `k = q * n - p * m`   of the Berggren node `z(m,n) = (n + i)/m`.

That file leaves open the arithmetic question that actually governs the *picture*: **which
charges `k` occur?** The answer, proved here, is a clean parity law, and it explains exactly
which rational points show a visible star.

## Main results

* `charge_odd_of_odd_odd` : if `p` and `q` are **both odd** then every Berggren node has an
  **odd** charge at `p/q`. Half of the pencil is empty.
* `exists_seed_of_charge` : conversely, for `0 < p < q` coprime, **every** nonzero integer `k`
  allowed by that parity law is the charge of infinitely many nodes. The proof is an explicit
  `SL₂(ℤ)` construction: with `q x - p y = 1` and `A = 1 + k(x+y) + 2k²j`, the pair
  `(m,n) = (qA + yk, pA + xk)` is a Euclid seed of charge `k`, because
  `gcd(m,n) = gcd(A,k) = 1` (`isCoprime_of_sl2_charge`).
* `charge_zero_iff` : the *central* ray `k = 0` (the geodesic itself) carries a node iff
  `(q,p)` is itself a seed, i.e. iff `p + q` is odd.
* `star_spectrum` : the two results combined — the realised charge set at `p/q` is exactly
  `ℤ \ {0}` intersected with the allowed parity class (plus `0` when `p+q` is odd).
* `starGapNum`, `charge_gap`, `star_gap_attained` : the **resolution law**. Two nodes lying on
  different rays of the star at `p/q` have `sinh`-distances to the central geodesic differing
  by at least `δ(p/q) = (1 or 2)/q`, and this is attained. So the star at `p/q` is a pencil
  whose angular resolution is `δ(p/q)`: the smaller `q`, and the *worse* the parity of `p+q`,
  the more visible the star.
* `visible_rationals` : the finite classification. The rationals of `[0,1]` with
  `δ ≥ 2/5` are exactly `0, 1/5, 1/3, 1/2, 3/5, 1` — precisely the boundary points at which
  radial lines are seen in a rendered star map (`0`, `0.2`, `0.33`, `0.5`, `1`), together with
  the falsifiable prediction `0.6`. Note `1/4 = 0.25` is excluded although `4 < 5`: even
  denominators are penalised by the parity law.

All statements about distances are for Mathlib's genuine hyperbolic metric on
`UpperHalfPlane`, via `BerggrenHypercycleStars.distVLine`.
-/

namespace BerggrenRationalStars

open BerggrenHypercycleStars

/-! ## Part 0. The star charge -/

/-- The **star charge** of the node `z(m,n)` at the boundary rational `p/q`:
`k = q n - p m`. The node lies on the Euclidean ray out of `p/q` of parameter `k/q`. -/
def starCharge (p q m n : ℕ) : ℤ := (q : ℤ) * n - (p : ℤ) * m

/-- Charges are constant along the lattice line: translating a node by the primitive vector
`(q,p)` keeps it on the same ray of the star at `p/q`. -/
theorem starCharge_translate (p q m n t : ℕ) :
    starCharge p q (m + t * q) (n + t * p) = starCharge p q m n := by
  simp only [starCharge]; push_cast; ring

/-! ## Part 1. Quantisation: the parity obstruction -/

/-- Parity as a statement in `ZMod 2`. -/
theorem odd_iff_cast_zmod_two (z : ℤ) : Odd z ↔ ((z : ZMod 2) = 1) := by
  rw [Int.odd_iff, show ((1 : ZMod 2)) = ((1 : ℤ) : ZMod 2) by norm_num,
    ZMod.intCast_eq_intCast_iff']
  norm_num

/-- **Quantisation of a both-odd star.** If `p` and `q` are both odd, the charge of any Euclid
seed at `p/q` is odd: only every second ray of the pencil is populated. -/
theorem charge_odd_of_odd_odd {p q m n : ℕ} (hp : p % 2 = 1) (hq : q % 2 = 1)
    (h : IsSeed m n) : Odd (starCharge p q m n) := by
  have hp2 : ((p : ℤ) : ZMod 2) = 1 :=
    (odd_iff_cast_zmod_two _).mp (by rw [Int.odd_iff]; omega)
  have hq2 : ((q : ℤ) : ZMod 2) = 1 :=
    (odd_iff_cast_zmod_two _).mp (by rw [Int.odd_iff]; omega)
  have hmn : ((m : ℤ) : ZMod 2) + ((n : ℤ) : ZMod 2) = 1 := by
    have hodd : Odd ((m : ℤ) + n) := by
      have := h.parity; rw [Int.odd_iff]; omega
    have h2 := (odd_iff_cast_zmod_two _).mp hodd
    rw [Int.cast_add] at h2
    exact h2
  rw [odd_iff_cast_zmod_two]
  have hcast : ((starCharge p q m n : ℤ) : ZMod 2)
      = ((q : ℤ) : ZMod 2) * ((n : ℤ) : ZMod 2) - ((p : ℤ) : ZMod 2) * ((m : ℤ) : ZMod 2) := by
    simp [starCharge]
  rw [hcast, hp2, hq2]
  have key : ∀ a b : ZMod 2, a + b = 1 → (1 : ZMod 2) * b - 1 * a = 1 := by decide
  exact key _ _ hmn

/-! ## Part 2. Realisation: the `SL₂(ℤ)` ray construction -/

/-- The determinant-one change of variables. If `q x - p y = 1` then the map
`(A,k) ↦ (qA + yk, pA + xk)` is in `SL₂(ℤ)`, so it preserves coprimality: the node built from
`(A,k)` is primitive as soon as `A` and `k` are. -/
theorem isCoprime_of_sl2_charge {p q x y A k : ℤ} (hdet : q * x - p * y = 1)
    (h : IsCoprime A k) : IsCoprime (q * A + y * k) (p * A + x * k) := by
  obtain ⟨u, v, huv⟩ := h
  refine ⟨u * x - v * p, v * q - u * y, ?_⟩
  have hA : x * (q * A + y * k) - y * (p * A + x * k) = A * (q * x - p * y) := by ring
  have hk : q * (p * A + x * k) - p * (q * A + y * k) = k * (q * x - p * y) := by ring
  rw [hdet, mul_one] at hA hk
  calc (u * x - v * p) * (q * A + y * k) + (v * q - u * y) * (p * A + x * k)
      = u * (x * (q * A + y * k) - y * (p * A + x * k))
        + v * (q * (p * A + x * k) - p * (q * A + y * k)) := by ring
    _ = u * A + v * k := by rw [hA, hk]
    _ = 1 := huv

/-- The parity bookkeeping of the construction, as an identity in `ZMod 2`. -/
theorem parity_zmod_two (P Q X Y K A : ZMod 2) (hdet : Q * X - P * Y = 1)
    (hA : A = 1 + K * (X + Y)) (hpar : P + Q = 1 ∨ K = 1) :
    (P + Q) * A + (X + Y) * K = 1 := by
  revert hdet hA hpar
  revert P Q X Y K A
  decide

/-- **Realisation of every allowed charge.** Let `0 < p < q` be coprime and let `k ≠ 0` be an
integer which is odd in case `p + q` is even. Then, above any bound `B`, there is a Euclid
seed `(m,n)` with `m > B` whose star charge at `p/q` is exactly `k`.

Consequently every allowed ray of every rational star carries infinitely many Berggren nodes. -/
theorem exists_seed_of_charge (p q : ℕ) (hp : 0 < p) (hlt : p < q) (hcop : Nat.Coprime p q)
    (k : ℤ) (hk : k ≠ 0) (hpar : (p + q) % 2 = 1 ∨ Odd k) (B : ℕ) :
    ∃ m n : ℕ, IsSeed m n ∧ B < m ∧ starCharge p q m n = k := by
  -- Bezout data `q x - p y = 1`
  obtain ⟨x, y, hdet⟩ : ∃ x y : ℤ, (q : ℤ) * x - (p : ℤ) * y = 1 := by
    have : IsCoprime (q : ℤ) (p : ℤ) := by
      rw [Int.isCoprime_iff_gcd_eq_one]
      simpa [Int.gcd_natCast_natCast, Nat.Coprime] using (Nat.coprime_comm.mp hcop)
    obtain ⟨a, b, hab⟩ := this
    exact ⟨a, -b, by linarith [hab]⟩
  -- the free parameter, chosen ≡ 1 (mod k), even-shifted, and large
  set T : ℤ := x + y with hT
  set A₀ : ℤ := 1 + k * T with hA₀
  set C : ℤ := |A₀| + |x * k| + |y * k| + (B : ℤ) + 1 with hC
  have hCpos : 0 ≤ C := by positivity
  set j : ℤ := C with hj
  set A : ℤ := A₀ + 2 * k ^ 2 * j with hA
  have hk2 : (1 : ℤ) ≤ k ^ 2 := by
    rcases lt_trichotomy k 0 with h | h | h
    · nlinarith
    · exact absurd h hk
    · nlinarith
  have hAbig : C + 1 ≤ A := by
    have h1 : 2 * C ≤ 2 * k ^ 2 * j := by
      rw [hj]; nlinarith
    have h2 : -|A₀| ≤ A₀ := neg_abs_le A₀
    have h3 : |A₀| + 1 ≤ C := by
      have : (0 : ℤ) ≤ |x * k| + |y * k| + (B : ℤ) := by positivity
      omega
    omega
  -- the node
  set M : ℤ := (q : ℤ) * A + y * k with hM
  set N : ℤ := (p : ℤ) * A + x * k with hN
  have hApos : (0 : ℤ) < A := by omega
  have hp1 : (1 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp
  have hqp : (1 : ℤ) ≤ (q : ℤ) - (p : ℤ) := by
    have : (p : ℤ) < (q : ℤ) := by exact_mod_cast hlt
    omega
  have hxk : -|x * k| ≤ x * k := neg_abs_le _
  have hyk : -|y * k| ≤ y * k := neg_abs_le _
  have hNpos : 0 < N := by
    have : A ≤ (p : ℤ) * A := le_mul_of_one_le_left hApos.le hp1
    have hCx : |x * k| + 1 ≤ C := by
      have : (0 : ℤ) ≤ |A₀| + |y * k| + (B : ℤ) := by positivity
      omega
    omega
  have hMN : N < M := by
    have hdiff : M - N = ((q : ℤ) - p) * A + (y - x) * k := by rw [hM, hN]; ring
    have : A ≤ ((q : ℤ) - p) * A := le_mul_of_one_le_left hApos.le hqp
    have hCxy : |x * k| + |y * k| + 1 ≤ C := by
      have : (0 : ℤ) ≤ |A₀| + (B : ℤ) := by positivity
      omega
    have hexp : (y - x) * k = y * k - x * k := by ring
    have hxk' : x * k ≤ |x * k| := le_abs_self _
    omega
  have hMB : (B : ℤ) < M := by
    have hq1 : (1 : ℤ) ≤ (q : ℤ) := by omega
    have : A ≤ (q : ℤ) * A := le_mul_of_one_le_left hApos.le hq1
    have hCy : |y * k| + (B : ℤ) + 1 ≤ C := by
      have : (0 : ℤ) ≤ |A₀| + |x * k| := by positivity
      omega
    omega
  -- coprimality
  have hcopAk : IsCoprime A k := by
    refine ⟨1, -(T + 2 * k * j), ?_⟩
    rw [hA, hA₀]; ring
  have hcopMN : IsCoprime M N := isCoprime_of_sl2_charge hdet hcopAk
  -- back to naturals
  have hMpos : 0 < M := lt_trans hNpos hMN
  refine ⟨M.toNat, N.toNat, ⟨?_, ?_, ?_, ?_⟩, ?_, ?_⟩
  · omega
  · omega
  · have hgcd : Int.gcd M N = 1 := Int.isCoprime_iff_gcd_eq_one.mp hcopMN
    have h1 : M.natAbs = M.toNat := Int.natAbs_of_nonneg hMpos.le ▸ by omega
    have h2 : N.natAbs = N.toNat := Int.natAbs_of_nonneg hNpos.le ▸ by omega
    unfold Nat.Coprime
    rw [← h1, ← h2]
    exact hgcd
  · -- parity
    have hsum : (M.toNat : ℤ) + (N.toNat : ℤ) = ((p : ℤ) + q) * A + (x + y) * k := by
      rw [show (M.toNat : ℤ) = M by omega, show (N.toNat : ℤ) = N by omega, hM, hN]; ring
    have hodd : Odd ((M.toNat : ℤ) + N.toNat) := by
      rw [odd_iff_cast_zmod_two, hsum]
      have hAeq : ((A : ℤ) : ZMod 2) = 1 + ((k : ℤ) : ZMod 2) * (((x : ℤ) : ZMod 2)
          + ((y : ℤ) : ZMod 2)) := by
        have : A = 1 + k * (x + y) + 2 * (k ^ 2 * j) := by rw [hA, hA₀, hT]; ring
        rw [this]
        push_cast
        rw [show (2 : ZMod 2) = 0 from rfl]
        ring
      have hdet2 : ((q : ℤ) : ZMod 2) * ((x : ℤ) : ZMod 2) - ((p : ℤ) : ZMod 2)
          * ((y : ℤ) : ZMod 2) = 1 := by
        have := congrArg (fun z : ℤ => ((z : ZMod 2))) hdet
        push_cast at this
        simpa using this
      have hparity2 : ((p : ℤ) : ZMod 2) + ((q : ℤ) : ZMod 2) = 1 ∨ ((k : ℤ) : ZMod 2) = 1 := by
        rcases hpar with h | h
        · left
          have : Odd ((p : ℤ) + q) := by rw [Int.odd_iff]; omega
          rw [odd_iff_cast_zmod_two] at this
          push_cast at this
          exact this
        · right; exact (odd_iff_cast_zmod_two k).mp h
      have := parity_zmod_two ((p : ℤ) : ZMod 2) ((q : ℤ) : ZMod 2) ((x : ℤ) : ZMod 2)
        ((y : ℤ) : ZMod 2) ((k : ℤ) : ZMod 2) ((A : ℤ) : ZMod 2) hdet2 hAeq hparity2
      push_cast
      push_cast at this
      linear_combination this
    rw [Int.odd_iff] at hodd
    omega
  · omega
  · rw [starCharge, show (M.toNat : ℤ) = M by omega, show (N.toNat : ℤ) = N by omega, hM, hN]
    linear_combination k * hdet

/-! ## Part 3. The exact charge spectrum of a rational star -/

/-- The central ray `k = 0` of the star at `p/q` — the vertical geodesic itself — carries a
Berggren node if and only if the pair `(q,p)` is a Euclid seed, and then that node is unique. -/
theorem charge_zero_iff {p q m n : ℕ} (hp : 0 < p) (hlt : p < q) (hcop : Nat.Coprime p q)
    (h : IsSeed m n) : starCharge p q m n = 0 ↔ (m = q ∧ n = p) := by
  constructor
  · intro h0
    have hqn : q * n = p * m := by
      have : (q : ℤ) * n = (p : ℤ) * m := by
        have := h0; rw [starCharge] at this; linarith
      exact_mod_cast this
    have hqm : q ∣ m := by
      have : q ∣ p * m := ⟨n, hqn.symm⟩
      exact (Nat.Coprime.dvd_of_dvd_mul_left (Nat.coprime_comm.mp hcop) this)
    have hmq : m ∣ q := by
      have : m ∣ q * n := ⟨p, by rw [hqn, Nat.mul_comm]⟩
      exact (Nat.Coprime.dvd_of_dvd_mul_right h.cop this)
    have hmq' : m = q := Nat.dvd_antisymm hmq hqm
    subst hmq'
    have : m * n = p * m := by omega
    have hm0 : 0 < m := lt_trans h.pos h.lt
    exact ⟨rfl, by nlinarith⟩
  · rintro ⟨rfl, rfl⟩
    simp [starCharge]
    ring

/-- **The charge spectrum of a rational star.** For `0 < p < q` coprime, an integer `k` is the
star charge of some Berggren node at the boundary point `p/q` **iff** `p + q` is odd or `k` is
odd. So: a star at a rational with `p+q` odd is *fully* populated (every ray of the pencil
carries infinitely many nodes), whereas a star with `p, q` both odd has only its odd rays. -/
theorem star_spectrum (p q : ℕ) (hp : 0 < p) (hlt : p < q) (hcop : Nat.Coprime p q) (k : ℤ) :
    (∃ m n : ℕ, IsSeed m n ∧ starCharge p q m n = k) ↔ ((p + q) % 2 = 1 ∨ Odd k) := by
  constructor
  · rintro ⟨m, n, hseed, rfl⟩
    rcases Nat.even_or_odd (p + q) with he | ho
    · right
      have hp2 : p % 2 = 1 := by
        rcases Nat.even_or_odd p with hpe | hpo
        · exfalso
          have hq2 : q % 2 = 0 := by
            rw [Nat.even_iff] at he hpe; omega
          have hp2 : p % 2 = 0 := by rw [Nat.even_iff] at hpe; omega
          have : 2 ∣ Nat.gcd p q := Nat.dvd_gcd (by omega) (by omega)
          rw [hcop] at this
          omega
        · rw [Nat.odd_iff] at hpo; exact hpo
      have hq2 : q % 2 = 1 := by rw [Nat.even_iff] at he; omega
      exact charge_odd_of_odd_odd hp2 hq2 hseed
    · left; rw [Nat.odd_iff] at ho; exact ho
  · intro hk
    by_cases hk0 : k = 0
    · subst hk0
      have hpar : (p + q) % 2 = 1 := by
        rcases hk with h | h
        · exact h
        · exact absurd h (by simp)
      refine ⟨q, p, ⟨hp, hlt, Nat.coprime_comm.mp hcop, by omega⟩, ?_⟩
      simp [starCharge]
      ring
    · obtain ⟨m, n, hs, _, hc⟩ := exists_seed_of_charge p q hp hlt hcop k hk0 hk 0
      exact ⟨m, n, hs, hc⟩

/-! ## Part 4. The resolution law and the visible rationals -/

/-- The numerator of the **angular resolution** of the star at `p/q`: adjacent populated rays
of the pencil differ by `starGapNum p q / q` in `sinh` of the distance to the central
geodesic. -/
def starGapNum (p q : ℕ) : ℕ := if (p + q) % 2 = 1 then 1 else 2

/-- The hyperbolic sine of the distance from a node to the geodesic over `p/q` is exactly
`|charge| / q`: the star charge *is* the (scaled) hypercycle radius. -/
theorem sinh_distVLine_charge (p q m n : ℕ) (hm : 0 < m) (hq : 0 < q) :
    Real.sinh (distVLine (hpoint m n hm) ((p : ℝ) / q))
      = |(starCharge p q m n : ℝ)| / q := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hQ : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  rw [sinh_distVLine, hpoint_re, hpoint_im, starCharge]
  push_cast
  rw [show (n : ℝ) / m - (p : ℝ) / q = ((q : ℝ) * n - (p : ℝ) * m) / ((q : ℝ) * m) by
      field_simp,
    abs_div, abs_of_pos (by positivity : (0 : ℝ) < (q : ℝ) * m)]
  field_simp

/-- **Resolution law (lower bound).** Two Berggren nodes lying on *different* rays of the star
at `p/q` are separated, in `sinh` of their distances to the central geodesic, by at least
`starGapNum p q / q`. For `p, q` both odd this is twice as large as otherwise: the parity
obstruction doubles the resolution of the star. -/
theorem charge_gap {p q m₁ n₁ m₂ n₂ : ℕ} (hp : p % 2 = 1 ∨ q % 2 = 1) (hq : 0 < q)
    (hm₁ : 0 < m₁) (hm₂ : 0 < m₂) (h₁ : IsSeed m₁ n₁) (h₂ : IsSeed m₂ n₂)
    (hne : |starCharge p q m₁ n₁| ≠ |starCharge p q m₂ n₂|) :
    (starGapNum p q : ℝ) / q ≤
      |Real.sinh (distVLine (hpoint m₁ n₁ hm₁) ((p : ℝ) / q))
        - Real.sinh (distVLine (hpoint m₂ n₂ hm₂) ((p : ℝ) / q))| := by
  have hQ : (0 : ℝ) < q := by exact_mod_cast hq
  set k₁ := starCharge p q m₁ n₁ with hk₁
  set k₂ := starCharge p q m₂ n₂ with hk₂
  have hsub : |k₁| - |k₂| ≠ 0 := sub_ne_zero.mpr hne
  have hgap : (starGapNum p q : ℤ) ≤ |(|k₁| - |k₂|)| := by
    unfold starGapNum
    split_ifs with hpar
    · simpa using Int.one_le_abs hsub
    · -- both `p` and `q` are odd, so both charges are odd and `||k₁| - |k₂||` is even and ≠ 0
      have hp2 : p % 2 = 1 := by
        rcases hp with h | h
        · exact h
        · omega
      have hq2 : q % 2 = 1 := by omega
      have o₁ : Odd k₁ := charge_odd_of_odd_odd hp2 hq2 h₁
      have o₂ : Odd k₂ := charge_odd_of_odd_odd hp2 hq2 h₂
      rw [Int.odd_iff] at o₁ o₂
      have a₁ : |k₁| % 2 = 1 := by rcases abs_choice k₁ with h | h <;> omega
      have a₂ : |k₂| % 2 = 1 := by rcases abs_choice k₂ with h | h <;> omega
      have hdvd : (2 : ℤ) ∣ |(|k₁| - |k₂|)| := by
        have : (2 : ℤ) ∣ (|k₁| - |k₂|) := by omega
        exact (dvd_abs _ _).mpr this
      exact Int.le_of_dvd (abs_pos.mpr hsub) hdvd
  have hcast : |(|(k₁ : ℝ)| - |(k₂ : ℝ)|)| = ((|(|k₁| - |k₂|)| : ℤ) : ℝ) := by
    push_cast
    simp
  rw [sinh_distVLine_charge p q m₁ n₁ hm₁ hq, sinh_distVLine_charge p q m₂ n₂ hm₂ hq,
    ← sub_div, abs_div, abs_of_pos hQ, ← hk₁, ← hk₂, div_le_div_iff_of_pos_right hQ]
  rw [hcast]
  exact_mod_cast hgap

/-- **Resolution law (sharpness).** The bound of `charge_gap` is attained: at every rational
`p/q` with `0 < p < q` there are two Berggren nodes whose distances to the central geodesic
have `sinh`-difference *exactly* `starGapNum p q / q`. -/
theorem star_gap_attained (p q : ℕ) (hp : 0 < p) (hlt : p < q) (hcop : Nat.Coprime p q) :
    ∃ (m₁ n₁ m₂ n₂ : ℕ) (h₁ : 0 < m₁) (h₂ : 0 < m₂), IsSeed m₁ n₁ ∧ IsSeed m₂ n₂ ∧
      |Real.sinh (distVLine (hpoint m₁ n₁ h₁) ((p : ℝ) / q))
        - Real.sinh (distVLine (hpoint m₂ n₂ h₂) ((p : ℝ) / q))| = (starGapNum p q : ℝ) / q := by
  have hq : 0 < q := lt_trans hp hlt
  have hQ : (0 : ℝ) < q := by exact_mod_cast hq
  set g : ℕ := starGapNum p q with hg
  have hgpar : (p + q) % 2 = 1 ∨ Odd (1 + (g : ℤ)) := by
    unfold starGapNum at hg
    split_ifs at hg with hpar
    · left; exact hpar
    · right; rw [hg]; decide
  obtain ⟨m₁, n₁, hs₁, _, hc₁⟩ :=
    exists_seed_of_charge p q hp hlt hcop 1 (by norm_num) (by right; decide) 0
  obtain ⟨m₂, n₂, hs₂, _, hc₂⟩ :=
    exists_seed_of_charge p q hp hlt hcop (1 + (g : ℤ)) (by omega) hgpar 0
  have hm₁ : 0 < m₁ := lt_trans hs₁.pos hs₁.lt
  have hm₂ : 0 < m₂ := lt_trans hs₂.pos hs₂.lt
  refine ⟨m₁, n₁, m₂, n₂, hm₁, hm₂, hs₁, hs₂, ?_⟩
  have e1 : |(((1 : ℤ)) : ℝ)| = 1 := by norm_num
  have e2 : |(((1 + (g : ℤ)) : ℤ) : ℝ)| = 1 + (g : ℝ) := by
    rw [abs_of_nonneg (by push_cast; positivity)]
    push_cast
    ring
  rw [sinh_distVLine_charge p q m₁ n₁ hm₁ hq, sinh_distVLine_charge p q m₂ n₂ hm₂ hq,
    hc₁, hc₂, e1, e2, ← sub_div, abs_div, abs_of_pos hQ]
  congr 1
  rw [show (1 : ℝ) - (1 + (g : ℝ)) = -(g : ℝ) by ring, abs_neg,
    abs_of_nonneg (by positivity : (0 : ℝ) ≤ (g : ℝ))]

/-- **The visible rationals.** Ranking the boundary rationals of `[0,1]` by the resolution
`δ(p/q) = starGapNum p q / q` of their star, the ones with `δ ≥ 2/5` are exactly

  `0, 1/5, 1/3, 1/2, 3/5, 1`  (numerically `0, 0.2, 0.33, 0.5, 0.6, 1`).

These are precisely the boundary points at which radial lines are visible in a rendered
Berggren star map. Note that `1/4 = 0.25` is *absent* although `4 < 5`: an even denominator
is penalised, because the parity obstruction doubles the resolution only when `p` and `q` are
both odd. -/
theorem visible_rationals (p q : ℕ) (hq : 0 < q) (hle : p ≤ q) (hcop : Nat.Coprime p q) :
    2 * q ≤ 5 * starGapNum p q ↔
      (p = 0 ∧ q = 1) ∨ (p = 1 ∧ q = 1) ∨ (p = 1 ∧ q = 2) ∨ (p = 1 ∧ q = 3) ∨
        (p = 1 ∧ q = 5) ∨ (p = 3 ∧ q = 5) := by
  unfold starGapNum
  constructor
  · intro h
    have hq5 : q ≤ 5 := by split_ifs at h <;> omega
    interval_cases q <;> interval_cases p <;> simp_all [Nat.Coprime, Nat.gcd]
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) <;> decide

end BerggrenRationalStars