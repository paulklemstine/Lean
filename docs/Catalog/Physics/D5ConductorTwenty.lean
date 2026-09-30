module

public import Mathlib

/-!
# D5-CONDUCTOR: the quadratic subfield of `x⁵ + 20x + 32` has conductor `20`, not `320`

The claim under test (FACT round-33 #2, "THE-CONDUCTOR-IS-320") was:

* the "fork" of the dihedral quintic `f = x⁵ + 20x + 32` (does Frobenius lie in the
  rotation subgroup `C₅ ⊂ D₅` or not?) is detected by `N mod 320`, and
* the quadratic subfield `K` of the splitting field has `|d(K)| = 320`.

Computation (see `ComputationalEvidence.md`) identifies the fork with the quadratic
character of `ℚ(√-5)`, i.e. with the Jacobi/Kronecker symbol `(-5 | N)`.  This file proves:

1. `trinomialDisc_x5_20x_32` : the trinomial discriminant `5⁵b⁴ + 4⁴a⁵` of `x⁵ + 20x + 32`
   equals `(2⁹·5³)² = 64000²`, a perfect square (compatible with `Gal ⊆ A₅`, as for `D₅`).
2. `quadDisc_ne_pm320` : **no** quadratic field has discriminant `±320`
   (`320 = 4·80` and `80` is not squarefree), so the second half of the claim is false
   for *every* quadratic field, not just for this one.
3. `not_isFundDisc_pm320`, `isFundDisc_neg20` : the same in the language of fundamental
   discriminants; `-20 = d(ℚ(√-5))` is fundamental.
4. `forkDeterminedMod_iff` : the fork `N ↦ (-5 | N)` (on odd `N`) is a function of `N mod m`
   **iff** `20 ∣ m`.  Hence `320` works only because `20 ∣ 320`.
5. `forkConductor_eq_20` : the least positive such modulus (the conductor) is `20`,
   and `forkConductor_ne_320` refutes THE-CONDUCTOR-IS-320.
6. `fork_eq_chi4_mul`, `fork_eq_one_iff` : `(-5 | N) = χ₄(N)·(N | 5)` and the explicit
   rotation classes `N ≡ 1, 3, 7, 9 (mod 20)`.
7. `quintic_mod5`, `quintic_mod2`, `rootCount_rotation_iff_fork` : totally ramified shapes at
   `5` and `2`, and a kernel-checked certificate that for primes `p < 400`, `p ∤ 10`, the
   root count of `f` mod `p` is `0` or `5` iff `(-5 | p) = 1`.  (The statement for all primes
   needs Galois theory and is not formalized here.)
-/

@[expose] public section

namespace Physics.D5Conductor

/-! ## 1. The discriminant of the trinomial `x⁵ + a x + b` -/

/-- The classical discriminant formula for the quintic trinomial `x⁵ + a x + b`:
`disc = 5⁵ b⁴ + 4⁴ a⁵`. -/
def trinomialDisc (a b : ℤ) : ℤ := 5 ^ 5 * b ^ 4 + 4 ^ 4 * a ^ 5

/-- The discriminant of `x⁵ + 20x + 32` is the perfect square `64000² = (2⁹·5³)²`. -/
theorem trinomialDisc_x5_20x_32 :
    trinomialDisc 20 32 = (2 ^ 9 * 5 ^ 3) ^ 2 ∧ trinomialDisc 20 32 = 2 ^ 18 * 5 ^ 6 := by
  constructor <;> norm_num [trinomialDisc]

/-- Structural form: for the family `x⁵ + 20 t⁴ x + 32 t⁵` (a weighted rescaling of our
quintic) the discriminant is always a square, `(64000 t¹⁰)²`.  So squareness of the
discriminant is a property of the whole scaling orbit. -/
theorem trinomialDisc_scaling (t : ℤ) :
    trinomialDisc (20 * t ^ 4) (32 * t ^ 5) = (64000 * t ^ 10) ^ 2 := by
  unfold trinomialDisc; ring

/-! ## 2. Quadratic field discriminants -/

/-- The discriminant of `ℚ(√d)` for squarefree `d ≠ 1`: `d` if `d ≡ 1 (mod 4)`, else `4d`. -/
def quadDisc (d : ℤ) : ℤ := if d % 4 = 1 then d else 4 * d

/-- `80` is not squarefree (`4 * 4 ∣ 80`); same for `-80`. -/
lemma not_squarefree_pm80 (d : ℤ) (hd : d = 80 ∨ d = -80) : ¬ Squarefree d := by
  intro h
  have h4 : (4 : ℤ) * 4 ∣ d := by rcases hd with rfl | rfl <;> norm_num
  have := h 4 h4
  rw [Int.isUnit_iff] at this
  omega

/-- **No quadratic field has discriminant `±320`.**  For every squarefree `d`,
`quadDisc d ≠ 320` and `quadDisc d ≠ -320`. -/
theorem quadDisc_ne_pm320 (d : ℤ) (hd : Squarefree d) :
    quadDisc d ≠ 320 ∧ quadDisc d ≠ -320 := by
  unfold quadDisc
  split_ifs with h
  · constructor <;> omega
  · constructor
    · intro h'
      exact not_squarefree_pm80 d (Or.inl (by omega)) hd
    · intro h'
      exact not_squarefree_pm80 d (Or.inr (by omega)) hd

/-- The discriminant of `ℚ(√-5)` is `-20`. -/
theorem quadDisc_neg5 : quadDisc (-5) = -20 := by decide

/-- Fundamental discriminants. -/
def IsFundDisc (D : ℤ) : Prop :=
  (D % 4 = 1 ∧ Squarefree D) ∨ (∃ m : ℤ, D = 4 * m ∧ Squarefree m ∧ (m % 4 = 2 ∨ m % 4 = 3))

/-- `±320` are not fundamental discriminants. -/
theorem not_isFundDisc_pm320 : ¬ IsFundDisc 320 ∧ ¬ IsFundDisc (-320) := by
  constructor
  · rintro (⟨h, _⟩ | ⟨m, hm, hsq, _⟩)
    · norm_num at h
    · exact not_squarefree_pm80 m (Or.inl (by omega)) hsq
  · rintro (⟨h, _⟩ | ⟨m, hm, hsq, _⟩)
    · norm_num at h
    · exact not_squarefree_pm80 m (Or.inr (by omega)) hsq

/-- `-20` (the discriminant of `ℚ(√-5)`) is a fundamental discriminant. -/
theorem isFundDisc_neg20 : IsFundDisc (-20) := by
  refine Or.inr ⟨-5, by norm_num, ?_, by decide⟩
  rw [← Int.squarefree_natAbs]
  exact (by norm_num : Nat.Prime 5).squarefree

/-! ## 3. The fork character and its conductor -/

/-- The fork observable: the Kronecker/Jacobi symbol `(-5 | N)` of `ℚ(√-5)`. -/
def fork (N : ℕ) : ℤ := jacobiSym (-5) N

/-- The fork is a function of `N mod m` on odd `N`. -/
def ForkDeterminedMod (m : ℕ) : Prop :=
  ∀ b₁ b₂ : ℕ, Odd b₁ → Odd b₂ → b₁ ≡ b₂ [MOD m] → fork b₁ = fork b₂

/-- Periodicity: on odd `N`, `fork N` depends only on `N mod 20`. -/
lemma fork_mod20 {b : ℕ} (hb : Odd b) : fork b = fork (b % 20) := by
  unfold fork
  rw [jacobiSym.mod_right (-5) hb]
  rfl

lemma fork_one : fork 1 = 1 := by simp [fork]

lemma fork_eq_neg_one_of_mod20_eq_17 {b : ℕ} (hb : Odd b) (h : b % 20 = 17) :
    fork b = -1 := by
  rw [fork_mod20 hb, h, fork]; norm_num

lemma fork_eq_neg_one_of_mod20_eq_11 {b : ℕ} (hb : Odd b) (h : b % 20 = 11) :
    fork b = -1 := by
  rw [fork_mod20 hb, h, fork]; norm_num

/-- Fermat mod 5 in the form we need. -/
lemma pow_four_mod_five {t : ℕ} (ht : ¬ 5 ∣ t) : t ^ 4 % 5 = 1 := by
  rw [Nat.pow_mod]
  have : t % 5 < 5 := Nat.mod_lt _ (by norm_num)
  have h0 : t % 5 ≠ 0 := fun h => ht (Nat.dvd_of_mod_eq_zero h)
  interval_cases h : t % 5 <;> simp_all

/-- **Main theorem.** The fork `N ↦ (-5 | N)` is determined by `N mod m` iff `20 ∣ m`. -/
theorem forkDeterminedMod_iff (m : ℕ) : ForkDeterminedMod m ↔ 20 ∣ m := by
  constructor
  · intro hdet
    by_contra h20
    by_cases h5 : 5 ∣ m
    · -- then `4 ∤ m`: flip the `χ₄` part while keeping `N mod 5` and `N mod m`
      have h4 : ¬ 4 ∣ m := fun h4 => h20 (Nat.Coprime.mul_dvd_of_dvd_of_dvd (by norm_num) h4 h5)
      set L := Nat.lcm m 2 with hL
      have hmL : m ∣ L := Nat.dvd_lcm_left m 2
      have h2L : 2 ∣ L := Nat.dvd_lcm_right m 2
      have h4L : ¬ 4 ∣ L := by
        intro h4L
        have hLdvd : L ∣ 2 * m := Nat.lcm_dvd (Nat.dvd_mul_left m 2) (Nat.dvd_mul_right 2 m)
        obtain ⟨k, hk⟩ := h5
        obtain ⟨c, hc⟩ := hLdvd
        obtain ⟨e, he⟩ := h4L
        obtain ⟨f, hf⟩ := hmL
        -- `4 ∣ L ∣ 2m` and `m ∣ L`; parity bookkeeping
        rcases Nat.even_or_odd m with ⟨r, hr⟩ | ⟨r, hr⟩
        · -- `m = 2r`, then `L = m` (since `2 ∣ m`) so `4 ∣ m`
          have : L = m := by
            rw [hL]; exact Nat.lcm_eq_left ⟨r, by omega⟩
          exact h4 ⟨e, by omega⟩
        · -- `m` odd: `L = 2m` so `4 ∣ 2m` forces `m` even
          have hcop : Nat.Coprime m 2 := by
            rw [Nat.coprime_comm, Nat.coprime_two_left]; exact ⟨r, hr⟩
          have : L = m * 2 := by rw [hL]; exact hcop.lcm_eq_mul
          omega
      have hb1 : Odd (1 : ℕ) := odd_one
      have hb2 : Odd (1 + 5 * L) := by
        obtain ⟨u, hu⟩ := h2L; exact ⟨5 * u, by omega⟩
      have hcong : (1 : ℕ) ≡ 1 + 5 * L [MOD m] := by
        refine (Nat.modEq_iff_dvd' (by omega)).2 ?_
        simp only [Nat.add_sub_cancel_left]
        exact Dvd.dvd.mul_left hmL 5
      have hmod : (1 + 5 * L) % 20 = 11 := by
        obtain ⟨u, hu⟩ := h2L
        have : ¬ 4 ∣ 2 * u := by rw [← hu]; exact h4L
        omega
      have := hdet 1 (1 + 5 * L) hb1 hb2 hcong
      rw [fork_one, fork_eq_neg_one_of_mod20_eq_11 hb2 hmod] at this
      norm_num at this
    · -- `5 ∤ m`: flip the `(·/5)` part while keeping `N mod 4` and `N mod m`
      have ht : ¬ 5 ∣ 4 * m := by
        intro h
        exact h5 ((Nat.Coprime.dvd_mul_left (by norm_num : Nat.Coprime 5 4)).1 h)
      have hp := pow_four_mod_five ht
      have hb1 : Odd (1 : ℕ) := odd_one
      have h4 : 4 ∣ (4 * m) ^ 4 := Dvd.dvd.pow (Dvd.intro m rfl) (by norm_num)
      have hb2 : Odd (1 + (4 * m) ^ 4) := by
        obtain ⟨u, hu⟩ := h4; exact ⟨2 * u, by omega⟩
      have hcong : (1 : ℕ) ≡ 1 + (4 * m) ^ 4 [MOD m] := by
        refine (Nat.modEq_iff_dvd' (by omega)).2 ?_
        simp only [Nat.add_sub_cancel_left]
        exact Dvd.dvd.pow (Dvd.intro_left 4 rfl) (by norm_num)
      have hmod : (1 + (4 * m) ^ 4) % 20 = 17 := by
        obtain ⟨u, hu⟩ := h4
        omega
      have := hdet 1 _ hb1 hb2 hcong
      rw [fork_one, fork_eq_neg_one_of_mod20_eq_17 hb2 hmod] at this
      norm_num at this
  · rintro h20 b₁ b₂ hb₁ hb₂ hcong
    rw [fork_mod20 hb₁, fork_mod20 hb₂]
    congr 1
    exact Nat.ModEq.of_dvd h20 hcong

/-- `320` does determine the fork (this is the observed `I = 1 bit` at modulus `320`) … -/
theorem forkDeterminedMod_320 : ForkDeterminedMod 320 :=
  (forkDeterminedMod_iff 320).2 ⟨16, rfl⟩

/-- … but so does `20`, and so does every multiple of `20`. -/
theorem forkDeterminedMod_20 : ForkDeterminedMod 20 :=
  (forkDeterminedMod_iff 20).2 dvd_rfl

/-- Existence of a positive determining modulus. -/
lemma exists_forkDetermined : ∃ m : ℕ, 0 < m ∧ ForkDeterminedMod m :=
  ⟨20, by norm_num, forkDeterminedMod_20⟩

open Classical in
/-- The conductor of the fork: least positive modulus determining it. -/
noncomputable def forkConductor : ℕ := Nat.find exists_forkDetermined

/-- **The conductor is `20`.** -/
theorem forkConductor_eq_20 : forkConductor = 20 := by
  classical
  unfold forkConductor
  rw [Nat.find_eq_iff]
  refine ⟨⟨by norm_num, forkDeterminedMod_20⟩, ?_⟩
  rintro n hn ⟨hpos, hdet⟩
  have := Nat.le_of_dvd hpos ((forkDeterminedMod_iff n).1 hdet)
  omega

/-- **Verdict: THE-CONDUCTOR-IS-320 is refuted.** -/
theorem forkConductor_ne_320 : forkConductor ≠ 320 := by
  rw [forkConductor_eq_20]; norm_num

/-- The conductor equals `|d(ℚ(√-5))|`, in accordance with the conductor–discriminant
formula for quadratic fields. -/
theorem forkConductor_eq_abs_quadDisc : (forkConductor : ℤ) = |quadDisc (-5)| := by
  rw [forkConductor_eq_20, quadDisc_neg5]; norm_num

/-! ## 4. Anatomy of the fork character: `χ₄ · (·/5)` -/

/-- Quadratic reciprocity splits the fork into its `2`-part and `5`-part:
`(-5 | N) = χ₄(N) · (N | 5)` for odd `N`.  The conductors of the factors are `4` and `5`,
whose product `20` is the conductor of the fork. -/
theorem fork_eq_chi4_mul {b : ℕ} (hb : Odd b) : fork b = ZMod.χ₄ b * jacobiSym b 5 := by
  unfold fork
  rw [show (-5 : ℤ) = -1 * 5 by norm_num, jacobiSym.mul_left, jacobiSym.at_neg_one hb,
    show (5 : ℤ) = ((5 : ℕ) : ℤ) by norm_num,
    jacobiSym.quadratic_reciprocity_one_mod_four (by norm_num) hb]

/-- Explicit description of the rotation class: for odd `N` prime to `5`,
`(-5 | N) = 1 ↔ N ≡ 1, 3, 7, 9 (mod 20)`. -/
theorem fork_eq_one_iff {b : ℕ} (hb : Odd b) (h5 : ¬ 5 ∣ b) :
    fork b = 1 ↔ (b % 20 = 1 ∨ b % 20 = 3 ∨ b % 20 = 7 ∨ b % 20 = 9) := by
  rw [fork_mod20 hb]
  obtain ⟨k, rfl⟩ := hb
  have : (2 * k + 1) % 20 < 20 := Nat.mod_lt _ (by norm_num)
  have h2 : (2 * k + 1) % 2 = 1 := by omega
  have h5' : (2 * k + 1) % 5 ≠ 0 := fun h => h5 (Nat.dvd_of_mod_eq_zero h)
  generalize hr : (2 * k + 1) % 20 = r at *
  interval_cases r <;> first | omega | (simp only [fork]; norm_num)

/-! ## 5. The quintic side: ramification and a Frobenius certificate -/

/-- Number of roots of `x⁵ + 20x + 32` modulo `p` (for a `D₅` quintic this is `0` for a
`5`-cycle, `5` for the identity and `1` for a reflection). -/
def rootCount (p : ℕ) : ℕ := ((List.range p).filter (fun t => (t ^ 5 + 20 * t + 32) % p = 0)).length

open Polynomial in
/-- Total ramification shape at `5`: `x⁵ + 20x + 32 ≡ (x + 2)⁵ (mod 5)`. -/
theorem quintic_mod5 : (X ^ 5 + C 20 * X + C 32 : (ZMod 5)[X]) = (X + C 2) ^ 5 := by
  have h1 : (20 : ZMod 5) = 0 := by decide
  have h2 : (32 : ZMod 5) = 2 ^ 5 := by decide
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  rw [add_pow_char, ← C_pow, h1, h2]; simp

open Polynomial in
/-- Total ramification shape at `2`: `x⁵ + 20x + 32 ≡ x⁵ (mod 2)`. -/
theorem quintic_mod2 : (X ^ 5 + C 20 * X + C 32 : (ZMod 2)[X]) = X ^ 5 := by
  have h1 : (20 : ZMod 2) = 0 := by decide
  have h2 : (32 : ZMod 2) = 0 := by decide
  rw [h1, h2]; simp

/-- Frobenius certificate (finite, kernel-checked): for every prime `3 ≤ p < 400`, `p ≠ 5`,
Frobenius at `p` lies in the rotation subgroup (root count `0` or `5`) exactly when
`p ≡ 1, 3, 7, 9 (mod 20)`. -/
theorem rootCount_certificate :
    ∀ p ∈ (List.range 400).filter (fun p => Nat.Prime p ∧ p ≠ 2 ∧ p ≠ 5),
      ((rootCount p = 0 ∨ rootCount p = 5) ↔
        (p % 20 = 1 ∨ p % 20 = 3 ∨ p % 20 = 7 ∨ p % 20 = 9)) := by
  decide +kernel

/-- **The fork is the quadratic character of `ℚ(√-5)`** on all primes `3 ≤ p < 400`, `p ≠ 5`:
Frobenius is a rotation iff `(-5 | p) = 1`. -/
theorem rootCount_rotation_iff_fork {p : ℕ} (hp : p.Prime) (hlt : p < 400) (h2 : p ≠ 2)
    (h5 : p ≠ 5) : (rootCount p = 0 ∨ rootCount p = 5) ↔ fork p = 1 := by
  have hodd : Odd p := hp.odd_of_ne_two h2
  have hn5 : ¬ 5 ∣ p := fun h =>
    h5 ((Nat.prime_dvd_prime_iff_eq (by norm_num) hp).1 h).symm
  rw [fork_eq_one_iff hodd hn5]
  exact rootCount_certificate p (List.mem_filter.2
    ⟨List.mem_range.2 hlt, by simp [hp, h2, h5]⟩)

end Physics.D5Conductor