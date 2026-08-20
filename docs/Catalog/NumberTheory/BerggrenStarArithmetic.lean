import Catalog.NumberTheory.BerggrenStarLines

/-!
# Arithmetic of the two Berggren stars: conserved charges and a totient count of arms

`NumberTheory.BerggrenStarLines` showed that the nodes of the Berggren tree, embedded in
the Poincaré half-plane by `z(m,n) = (n+i)/m`, lie on two families of Euclidean straight
lines radiating from the ideal points `1` and `0`, with *charges*

  `u = m - n`  (the `1`-star)  and  `n`  (the `0`-star),

and that a whole `B₁`-arm (resp. `B₃`-arm) lies on a single line of the `1`-star
(resp. `0`-star).  This file settles the arithmetic of those lines.

## Main results

* `chargeOne_seedL`, `chargeOne_lt_seedM`, `chargeOne_lt_seedR` and the mirror statements
  `chargeZero_seedR`, `chargeZero_lt_seedL`, `chargeZero_lt_seedM`: **exactly one of the
  three Berggren moves preserves each star line**, the other two strictly increase the
  charge.  So the star lines are precisely the `B₁`- (resp. `B₃`-) orbits, and every other
  move crosses transversally.  This is `star_lines_are_B1_and_B3_orbits`.

* `star_one_line_arm_decomposition` : the nodes of the `1`-star line of charge `u` split
  into maximal `B₁`-arms indexed by the residues `r ∈ [1,u]` coprime to `u`.

* `star_one_line_arm_count` : hence the line of charge `u` carries exactly `φ(u)` maximal
  arms, and (`star_one_line_arm_count_totient_two_mul`) `φ(u) = φ(2u)` as `u` is odd.

* `star_zero_line_arm_count` : the `0`-star line of charge `n` carries exactly `φ(2n)`
  maximal `B₃`-arms.

* `star_arm_count_unified` : **both stars obey the same law** — the line of charge `q`
  carries exactly `φ(2q)` maximal arms.  Euler's totient counts the arms of the star.
-/

namespace BerggrenStarArithmetic

open HyperbolicBerggrenGeodesics BerggrenStarLines

/-! ## Part 1. The charges and the three moves -/

/-- The `1`-star charge `u = m - n` is **invariant** under `B₁`. -/
theorem chargeOne_seedL {m n : ℕ} (h : n ≤ m) :
    (seedL (m, n)).1 - (seedL (m, n)).2 = m - n := by
  simp only [seedL]
  omega

/-- The `1`-star charge strictly **increases** under `B₂`. -/
theorem chargeOne_lt_seedM {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    m - n < (seedM (m, n)).1 - (seedM (m, n)).2 := by
  simp only [seedM]
  omega

/-- The `1`-star charge strictly **increases** under `B₃`. -/
theorem chargeOne_lt_seedR {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    m - n < (seedR (m, n)).1 - (seedR (m, n)).2 := by
  simp only [seedR]
  omega

/-- The `0`-star charge `n` is **invariant** under `B₃`. -/
theorem chargeZero_seedR (m n : ℕ) : (seedR (m, n)).2 = n := rfl

/-- The `0`-star charge strictly **increases** under `B₁`. -/
theorem chargeZero_lt_seedL {m n : ℕ} (hnm : n < m) : n < (seedL (m, n)).2 := hnm

/-- The `0`-star charge strictly **increases** under `B₂`. -/
theorem chargeZero_lt_seedM {m n : ℕ} (hnm : n < m) : n < (seedM (m, n)).2 := hnm

/-- **The star lines are exactly the `B₁`- and `B₃`-orbits.**  For every seed, `B₁` is the
unique move fixing the `1`-star line through the node and `B₃` is the unique move fixing
its `0`-star line; the two other moves increase the corresponding charge, hence move the
node to a strictly farther line of that star. -/
theorem star_lines_are_B1_and_B3_orbits {m n : ℕ} (h : IsSeed m n) :
    ((seedL (m, n)).1 - (seedL (m, n)).2 = m - n ∧
      m - n < (seedM (m, n)).1 - (seedM (m, n)).2 ∧
      m - n < (seedR (m, n)).1 - (seedR (m, n)).2) ∧
    ((seedR (m, n)).2 = n ∧ n < (seedL (m, n)).2 ∧ n < (seedM (m, n)).2) :=
  ⟨⟨chargeOne_seedL h.lt.le, chargeOne_lt_seedM h.pos h.lt, chargeOne_lt_seedR h.pos h.lt⟩,
    ⟨chargeZero_seedR m n, chargeZero_lt_seedL h.lt, chargeZero_lt_seedM h.lt⟩⟩

/-! ## Part 2. The `1`-star: arms of a line, and their totient count -/

/-- **Arm decomposition of a `1`-star line.**  For odd `u > 0`, the nodes of the line of
charge `u` are exactly the pairs `(r + ku + u, r + ku)` with `r ∈ [1,u]` coprime to `u`
and `k ≥ 0`: the line is the disjoint union of the maximal `B₁`-arms started at the
residues coprime to `u`. -/
theorem star_one_line_arm_decomposition {u : ℕ} (hu : 0 < u) (hodd : u % 2 = 1) (n : ℕ) :
    IsSeed (n + u) n ↔ ∃ r k : ℕ, r ∈ Finset.Icc 1 u ∧ Nat.Coprime u r ∧ n = r + k * u := by
  rw [isSeed_iff_grid]
  constructor
  · rintro ⟨hn, -, -, hcop⟩
    have hdm : u * ((n - 1) / u) + (n - 1) % u = n - 1 := Nat.div_add_mod _ _
    have hcomm : (n - 1) / u * u = u * ((n - 1) / u) := Nat.mul_comm _ _
    refine ⟨(n - 1) % u + 1, (n - 1) / u, ?_, ?_, ?_⟩
    · simp only [Finset.mem_Icc]
      have := Nat.mod_lt (n - 1) hu
      omega
    · have hEq : (n - 1) % u + 1 + ((n - 1) / u) * u = n := by omega
      have := (Nat.coprime_add_mul_right_right u ((n - 1) % u + 1) ((n - 1) / u))
      rw [hEq] at this
      exact this.mp hcop
    · omega
  · rintro ⟨r, k, hr, hcop, rfl⟩
    simp only [Finset.mem_Icc] at hr
    refine ⟨by omega, hu, hodd, ?_⟩
    exact (Nat.coprime_add_mul_right_right u r k).mpr hcop

/-- **Euler's totient counts the arms of a `1`-star line**: the line of charge `u` carries
exactly `φ(u)` maximal `B₁`-arms. -/
theorem star_one_line_arm_count (u : ℕ) :
    ((Finset.Icc 1 u).filter (fun r => Nat.Coprime u r)).card = Nat.totient u := by
  have hIcc : Finset.Icc 1 u = Finset.Ico 1 (1 + u) := by
    ext x; simp; omega
  rw [hIcc]
  exact Nat.filter_coprime_Ico_eq_totient u 1

/-- Since the charge of a `1`-star line is odd, its arm count is also `φ(2u)`. -/
theorem star_one_line_arm_count_totient_two_mul {u : ℕ} (hodd : u % 2 = 1) :
    ((Finset.Icc 1 u).filter (fun r => Nat.Coprime u r)).card = Nat.totient (2 * u) := by
  rw [star_one_line_arm_count u, Nat.totient_mul (by
    rw [Nat.Prime.coprime_iff_not_dvd Nat.prime_two, Nat.two_dvd_ne_zero]
    omega)]
  simp

/-! ## Part 3. The `0`-star: arms of a line, and their totient count -/

/-- Membership in a `0`-star line, in elementary terms. -/
theorem mem_star_zero_line_iff {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    IsSeed m n ↔ (Nat.Coprime m n ∧ (m + n) % 2 = 1) :=
  ⟨fun h => ⟨h.cop, h.parity⟩, fun h => ⟨hn, hnm, h.1, h.2⟩⟩

/-- The arithmetic heart of the `0`-star count: after the shift `m ↦ m + n`, the two seed
conditions on the line of charge `n` become a single coprimality condition modulo `2n`. -/
theorem coprime_two_mul_shift (n m : ℕ) :
    Nat.Coprime (2 * n) (m + n) ↔ (Nat.Coprime m n ∧ (m + n) % 2 = 1) := by
  rw [Nat.coprime_mul_iff_left]
  constructor
  · rintro ⟨h2, hn⟩
    refine ⟨?_, ?_⟩
    · have : Nat.Coprime n m := (Nat.coprime_add_self_right).mp hn
      exact this.symm
    · rw [Nat.Prime.coprime_iff_not_dvd Nat.prime_two, Nat.two_dvd_ne_zero] at h2
      exact h2
  · rintro ⟨hcop, hpar⟩
    refine ⟨?_, ?_⟩
    · rw [Nat.Prime.coprime_iff_not_dvd Nat.prime_two, Nat.two_dvd_ne_zero]
      exact hpar
    · exact (Nat.coprime_add_self_right).mpr hcop.symm

/-- **Euler's totient counts the arms of a `0`-star line**: the line of charge `n` carries
exactly `φ(2n)` maximal `B₃`-arms (one for each `m` in a fundamental window of length
`2n`, which is the period of the move `B₃ : m ↦ m + 2n`). -/
theorem star_zero_line_arm_count (n : ℕ) :
    ((Finset.Icc (n + 1) (3 * n)).filter
        (fun m => Nat.Coprime m n ∧ (m + n) % 2 = 1)).card = Nat.totient (2 * n) := by
  have hcount : ((Finset.Ico (2 * n + 1) (2 * n + 1 + 2 * n)).filter
      (fun x => Nat.Coprime (2 * n) x)).card = Nat.totient (2 * n) :=
    Nat.filter_coprime_Ico_eq_totient (2 * n) (2 * n + 1)
  rw [← hcount]
  refine Finset.card_nbij' (fun m => m + n) (fun x => x - n) ?_ ?_ ?_ ?_
  · intro m hm
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Icc, Finset.mem_Ico] at hm ⊢
    refine ⟨by omega, ?_⟩
    exact (coprime_two_mul_shift n m).mpr hm.2
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Icc, Finset.mem_Ico] at hx ⊢
    obtain ⟨hx1, hx2⟩ := hx
    have hxn : x - n + n = x := by omega
    have := (coprime_two_mul_shift n (x - n)).mp (by rw [hxn]; exact hx2)
    exact ⟨by omega, this⟩
  · intro m hm
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Icc] at hm
    show m + n - n = m
    omega
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hx
    show x - n + n = x
    omega

/-- **The unified star law.**  For every charge `q > 0` the corresponding line carries
exactly `φ(2q)` maximal arms — in the `1`-star (where the charge is necessarily odd) and
in the `0`-star alike.  The arithmetic of the two radiating stars is governed by Euler's
totient function. -/
theorem star_arm_count_unified (q : ℕ) :
    (q % 2 = 1 → ((Finset.Icc 1 q).filter (fun r => Nat.Coprime q r)).card
        = Nat.totient (2 * q)) ∧
      ((Finset.Icc (q + 1) (3 * q)).filter
        (fun m => Nat.Coprime m q ∧ (m + q) % 2 = 1)).card = Nat.totient (2 * q) :=
  ⟨fun hodd => star_one_line_arm_count_totient_two_mul hodd, star_zero_line_arm_count q⟩

/-- Sanity check of the unified law at `q = 5`: the `0`-star line of charge `5` carries
`φ(10) = 4` arms. -/
theorem star_zero_line_five :
    ((Finset.Icc 6 15).filter (fun m => Nat.Coprime m 5 ∧ (m + 5) % 2 = 1)).card = 4 := by
  decide

end BerggrenStarArithmetic