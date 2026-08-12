import Probability.Basic

/-!
# The mod 9 congruence is the only local obstruction for sums of three cubes

The main theorem of this file, `ThreeCubes.locallySolvable_iff`, states

  `LocallySolvable n ↔ (n % 9 ≠ 4 ∧ n % 9 ≠ 5)`,

i.e. the congruence `x³ + y³ + z³ ≡ n (mod m)` is solvable for *every* modulus `m > 0`
precisely when the single classical obstruction modulo `9` is absent.  Equivalently the
affine cubic surface `x³ + y³ + z³ = n` has `ℤ_p`-points for every prime `p` exactly when
`n ≢ ±4 (mod 9)`.

The proof combines three ingredients from rather different areas:

* **Additive combinatorics.** The Cauchy–Davenport theorem applied to the set of cubes
  `C ⊆ 𝔽_p` (which satisfies `3|C| ≥ p + 2` because the cubing map is at most `3`-to-`1`
  away from `0` and exactly `1`-to-`1` at `0`) shows `C + C + C = 𝔽_p`; see
  `three_cubes_surjective_mod_prime`.
* **Hensel lifting at unramified primes.** For `p ≠ 3` a solution mod `p` with one
  coordinate a unit lifts to every `p^k`; see `cube_lift`.
* **A ramified analysis at `p = 3`.** The derivative `3x²` has valuation exactly one, so the
  naive Hensel step fails; instead one lifts a unit `u ≡ 1 (mod 9)` to a cube modulo every
  power of `3` (`cube_lift_three`), and then a small case analysis over the seven admissible
  residues mod `9` produces the required representation.

Finally the Chinese remainder theorem glues the prime powers together.
-/

namespace ThreeCubes

open Finset Pointwise Polynomial

/-! ### Step 1: sums of three cubes cover `𝔽_p` (Cauchy–Davenport) -/

/-- In a finite field the fibre of `x ↦ x³` over any value has at most three elements. -/
theorem fiber_card_le_three (F : Type*) [Field F] [Fintype F] [DecidableEq F] (c : F) :
    (Finset.univ.filter (fun x : F => x ^ 3 = c)).card ≤ 3 := by
  have hne : (X ^ 3 - C c : F[X]) ≠ 0 := by
    intro h
    have h2 := congrArg (fun q => Polynomial.natDegree q) h
    simp only [Polynomial.natDegree_X_pow_sub_C, Polynomial.natDegree_zero] at h2
    omega
  have hsub : (Finset.univ.filter (fun x : F => x ^ 3 = c)) ⊆
      (X ^ 3 - C c : F[X]).roots.toFinset := by
    intro x hx
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
    simp [Multiset.mem_toFinset, hne, hx]
  calc (Finset.univ.filter (fun x : F => x ^ 3 = c)).card
      ≤ (X ^ 3 - C c : F[X]).roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ Multiset.card (X ^ 3 - C c : F[X]).roots := Multiset.toFinset_card_le _
    _ ≤ (X ^ 3 - C c : F[X]).natDegree := Polynomial.card_roots' _
    _ = 3 := by simp

/-- The set of cubes in `ZMod p` has more than a third of all residues:
`p + 2 ≤ 3 |C|`.  The extra `+2` comes from the fibre over `0` being a single point, and it
is exactly what makes the three-fold Cauchy–Davenport bound sharp enough. -/
theorem cubes_card (p : ℕ) [hp : Fact p.Prime] :
    p + 2 ≤ 3 * (Finset.image (fun x : ZMod p => x ^ 3) Finset.univ).card := by
  classical
  set C := Finset.image (fun x : ZMod p => x ^ 3) (Finset.univ : Finset (ZMod p)) with hC
  have h0 : (0 : ZMod p) ∈ C := by
    rw [hC, Finset.mem_image]; exact ⟨0, Finset.mem_univ _, by ring⟩
  have key : ∑ c ∈ C, (Finset.univ.filter (fun x : ZMod p => x ^ 3 = c)).card = p := by
    rw [← Finset.card_eq_sum_card_image, Finset.card_univ, ZMod.card p]
  have hz : (Finset.univ.filter (fun x : ZMod p => x ^ 3 = (0 : ZMod p))).card = 1 := by
    have hset : (Finset.univ.filter (fun x : ZMod p => x ^ 3 = (0 : ZMod p))) = {0} := by
      ext x; simp [pow_eq_zero_iff]
    rw [hset]; simp
  have hsplit : ∑ c ∈ C, (Finset.univ.filter (fun x : ZMod p => x ^ 3 = c)).card
      = 1 + ∑ c ∈ C.erase 0, (Finset.univ.filter (fun x : ZMod p => x ^ 3 = c)).card := by
    rw [← Finset.sum_erase_add _ _ h0, hz]; ring
  have hbnd : ∑ c ∈ C.erase 0, (Finset.univ.filter (fun x : ZMod p => x ^ 3 = c)).card
      ≤ 3 * (C.erase 0).card := by
    calc _ ≤ ∑ _c ∈ C.erase 0, 3 := Finset.sum_le_sum (fun c _ => fiber_card_le_three _ c)
      _ = 3 * (C.erase 0).card := by rw [Finset.sum_const]; ring
  have herase : (C.erase 0).card = C.card - 1 := Finset.card_erase_of_mem h0
  have hCpos : 1 ≤ C.card := Finset.card_pos.mpr ⟨0, h0⟩
  omega

/-- **Every residue modulo a prime is a sum of three cubes.**  Proved by applying the
Cauchy–Davenport theorem twice to the set of cubes. -/
theorem three_cubes_surjective_mod_prime (p : ℕ) [hp : Fact p.Prime] (a : ZMod p) :
    ∃ x y z : ZMod p, x ^ 3 + y ^ 3 + z ^ 3 = a := by
  classical
  set C := Finset.image (fun x : ZMod p => x ^ 3) (Finset.univ : Finset (ZMod p)) with hC
  have h3 : p + 2 ≤ 3 * C.card := cubes_card p
  have hCne : C.Nonempty := ⟨0, by rw [hC, Finset.mem_image]; exact ⟨0, Finset.mem_univ _, by ring⟩⟩
  have hCp : 1 ≤ C.card := Finset.card_pos.mpr hCne
  have hCCne : (C + C).Nonempty := hCne.add hCne
  have h1 := min_le_iff.mp (ZMod.cauchy_davenport hp.out hCne hCne)
  have h2 := min_le_iff.mp (ZMod.cauchy_davenport hp.out hCCne hCne)
  have huniv : (C + C) + C = Finset.univ := by
    apply Finset.eq_univ_of_card
    have hle := Finset.card_le_univ ((C + C) + C)
    simp only [ZMod.card p] at hle ⊢
    omega
  have hmem : a ∈ (C + C) + C := huniv ▸ Finset.mem_univ a
  rw [Finset.mem_add] at hmem
  obtain ⟨w, hw, z, hz, hwz⟩ := hmem
  rw [Finset.mem_add] at hw
  obtain ⟨u, hu, v, hv, huv⟩ := hw
  rw [hC, Finset.mem_image] at hu hv hz
  obtain ⟨x, _, rfl⟩ := hu
  obtain ⟨y, _, rfl⟩ := hv
  obtain ⟨t, _, rfl⟩ := hz
  exact ⟨x, y, t, by rw [huv]; exact hwz⟩

theorem exists_intCast (p : ℕ) (a : ZMod p) : ∃ x : ℤ, (x : ZMod p) = a :=
  ⟨ZMod.cast a, ZMod.intCast_zmod_cast a⟩

/-- Refinement of `three_cubes_surjective_mod_prime`: one may always take the first summand
to be a unit.  This is what makes Hensel lifting applicable. -/
theorem three_cubes_mod_prime_unit (p : ℕ) (hp : p.Prime) (n : ℤ) :
    ∃ x y z : ℤ, (p : ℤ) ∣ x ^ 3 + y ^ 3 + z ^ 3 - n ∧ ¬ (p : ℤ) ∣ x := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hcast : ∀ w : ℤ, ((p : ℤ) ∣ w) ↔ ((w : ZMod p) = 0) :=
    fun w => (ZMod.intCast_zmod_eq_zero_iff_dvd w p).symm
  suffices h : ∃ X Y Z : ZMod p, X ^ 3 + Y ^ 3 + Z ^ 3 = (n : ZMod p) ∧ X ≠ 0 by
    obtain ⟨X, Y, Z, hsum, hX⟩ := h
    obtain ⟨x, rfl⟩ := exists_intCast p X
    obtain ⟨y, rfl⟩ := exists_intCast p Y
    obtain ⟨z, rfl⟩ := exists_intCast p Z
    refine ⟨x, y, z, ?_, ?_⟩
    · rw [hcast]; push_cast; linear_combination hsum
    · rw [hcast]; exact hX
  by_cases ha : (n : ZMod p) = 0
  · exact ⟨1, -1, 0, by rw [ha]; ring, one_ne_zero⟩
  · obtain ⟨X, Y, Z, hsum⟩ := three_cubes_surjective_mod_prime p (n : ZMod p)
    by_cases hX : X ≠ 0
    · exact ⟨X, Y, Z, hsum, hX⟩
    by_cases hY : Y ≠ 0
    · exact ⟨Y, X, Z, by rw [← hsum]; ring, hY⟩
    by_cases hZ : Z ≠ 0
    · exact ⟨Z, X, Y, by rw [← hsum]; ring, hZ⟩
    push_neg at hX hY hZ
    exact absurd (by rw [← hsum, hX, hY, hZ]; ring) ha

/-! ### Step 2: Hensel lifting away from `3` -/

/-- Linear congruences with unit leading coefficient are solvable modulo a prime. -/
theorem exists_solve_lin (p : ℕ) (hp : p.Prime) (u s : ℤ) (hu : ¬ (p : ℤ) ∣ u) :
    ∃ t : ℤ, (p : ℤ) ∣ u * t + s := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hU : (u : ZMod p) ≠ 0 := fun h => hu ((ZMod.intCast_zmod_eq_zero_iff_dvd u p).mp h)
  refine ⟨ZMod.cast (-(s : ZMod p) * (u : ZMod p)⁻¹), ?_⟩
  rw [← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  field_simp
  ring

/-- One Hensel step for the equation `x³ = a` at a prime where `3x²` is a unit. -/
theorem cube_lift_step (p : ℕ) (hp : p.Prime) (a x : ℤ) (hx : ¬ (p : ℤ) ∣ 3 * x ^ 2)
    (j : ℕ) (h : (p : ℤ) ^ (j + 1) ∣ x ^ 3 - a) :
    ∃ x' : ℤ, (p : ℤ) ^ (j + 2) ∣ x' ^ 3 - a ∧ (p : ℤ) ∣ x' - x := by
  obtain ⟨s, hs⟩ := h
  obtain ⟨t, c, hc⟩ := exists_solve_lin p hp (3 * x ^ 2) s hx
  refine ⟨x + t * (p : ℤ) ^ (j + 1), ?_, ⟨t * (p : ℤ) ^ j, by ring⟩⟩
  refine ⟨c + (p : ℤ) ^ j * (3 * x * t ^ 2 + t ^ 3 * (p : ℤ) ^ (j + 1)), ?_⟩
  have h1 : x ^ 3 = a + (p : ℤ) ^ (j + 1) * s := by linarith [hs]
  have h2 : s = (p : ℤ) * c - 3 * x ^ 2 * t := by linarith [hc]
  rw [h2] at h1
  linear_combination h1

/-- **Hensel's lemma for cubes.**  A simple root of `x³ - a` modulo `p` lifts to a root
modulo every power of `p`. -/
theorem cube_lift (p : ℕ) (hp : p.Prime) (a x₀ : ℤ) (hx₀ : ¬ (p : ℤ) ∣ 3 * x₀ ^ 2)
    (h : (p : ℤ) ∣ x₀ ^ 3 - a) (k : ℕ) :
    ∃ x : ℤ, (p : ℤ) ^ (k + 1) ∣ x ^ 3 - a ∧ ¬ (p : ℤ) ∣ 3 * x ^ 2 := by
  induction k with
  | zero => exact ⟨x₀, by simpa using h, hx₀⟩
  | succ j ih =>
      obtain ⟨x, hx1, hx2⟩ := ih
      obtain ⟨x', hx'1, hx'2⟩ := cube_lift_step p hp a x hx2 j hx1
      refine ⟨x', hx'1, fun hcon => hx2 ?_⟩
      obtain ⟨d, hd⟩ := hx'2
      obtain ⟨e, he⟩ := hcon
      exact ⟨e - 3 * d * (x' + x), by linear_combination he - 3 * (x' + x) * hd⟩

/-! ### Step 3: the ramified prime `3` -/

/-- Lifting step for cubes at `3`.  Because `v₃(3x²) = 1` the increment must be `3^(j+1)`
rather than `3^(j+2)`; this is exactly Hensel's lemma in its strong form
`|f(x)| < |f'(x)|²`. -/
theorem cube_lift_three_step (a x : ℤ) (hx : ¬ (3 : ℤ) ∣ x) (j : ℕ)
    (h : (3 : ℤ) ^ (j + 2) ∣ x ^ 3 - a) :
    ∃ x' : ℤ, (3 : ℤ) ^ (j + 3) ∣ x' ^ 3 - a ∧ (3 : ℤ) ∣ x' - x := by
  obtain ⟨s, hs⟩ := h
  have hsq : (3 : ℤ) ∣ x ^ 2 - 1 := by
    have h3 : x % 3 = 0 ∨ x % 3 = 1 ∨ x % 3 = 2 := by omega
    obtain ⟨q, hq⟩ : ∃ q, x = 3 * q + x % 3 := ⟨x / 3, by omega⟩
    rcases h3 with h3 | h3 | h3
    · exact absurd ⟨x / 3, by omega⟩ hx
    · exact ⟨3 * q ^ 2 + 2 * q, by rw [hq, h3]; ring⟩
    · exact ⟨3 * q ^ 2 + 4 * q + 1, by rw [hq, h3]; ring⟩
  obtain ⟨w, hw⟩ := hsq
  refine ⟨x + (-s) * (3 : ℤ) ^ (j + 1), ?_, ⟨(-s) * 3 ^ j, by ring⟩⟩
  refine ⟨-s * w + x * s ^ 2 * 3 ^ j - s ^ 3 * 3 ^ (2 * j), ?_⟩
  have h2 : x ^ 2 = 1 + 3 * w := by linarith [hw]
  linear_combination hs + ((3 : ℤ) ^ (j + 2) * (-s)) * h2

/-- **Cubes in `ℤ₃`.**  A `3`-adic unit congruent to `1` modulo `9` is a cube modulo every
power of `3`. -/
theorem cube_lift_three (a : ℤ) (ha : (9 : ℤ) ∣ a - 1) (k : ℕ) :
    ∃ x : ℤ, (3 : ℤ) ^ k ∣ x ^ 3 - a := by
  have key : ∀ j : ℕ, ∃ x : ℤ, ¬ (3 : ℤ) ∣ x ∧ (3 : ℤ) ^ (j + 2) ∣ x ^ 3 - a := by
    intro j
    induction j with
    | zero =>
        refine ⟨1, by decide, ?_⟩
        obtain ⟨c, hc⟩ := ha
        exact ⟨-c, by rw [show (1 : ℤ) ^ 3 - a = -(a - 1) by ring, hc]; norm_num⟩
    | succ i ih =>
        obtain ⟨x, hx, hdvd⟩ := ih
        obtain ⟨x', h1, h2⟩ := cube_lift_three_step a x hx i hdvd
        refine ⟨x', fun hcon => hx ?_, h1⟩
        obtain ⟨d, hd⟩ := h2
        obtain ⟨e, he⟩ := hcon
        exact ⟨e - d, by linarith⟩
  obtain ⟨x, _, hdvd⟩ := key k
  exact ⟨x, dvd_trans (pow_dvd_pow 3 (by omega)) hdvd⟩

/-! ### Step 4: solvability modulo prime powers -/

/-- For every prime `p ≠ 3`, every integer is a sum of three cubes modulo every power of
`p`: there is no local obstruction away from `3`. -/
theorem solvableMod_prime_pow_ne_three (p : ℕ) (hp : p.Prime) (hp3 : p ≠ 3) (n : ℤ) (k : ℕ) :
    SolvableMod (p ^ k) n := by
  obtain ⟨x₀, y, z, hdvd, hx₀⟩ := three_cubes_mod_prime_unit p hp n
  set a : ℤ := n - y ^ 3 - z ^ 3 with ha
  have hbase : (p : ℤ) ∣ x₀ ^ 3 - a := by
    obtain ⟨c, hc⟩ := hdvd
    exact ⟨c, by rw [ha]; linarith⟩
  have hderiv : ¬ (p : ℤ) ∣ 3 * x₀ ^ 2 := by
    intro hcon
    have hpp : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
    rcases hpp.dvd_mul.mp hcon with h | h
    · have hd3 : p ∣ 3 := by
        have : ((p : ℤ)) ∣ ((3 : ℕ) : ℤ) := by exact_mod_cast h
        exact_mod_cast this
      exact hp3 ((Nat.prime_dvd_prime_iff_eq hp (by norm_num)).mp hd3)
    · exact hx₀ (hpp.dvd_of_dvd_pow h)
  obtain ⟨x, hx, -⟩ := cube_lift p hp a x₀ hderiv hbase k
  refine ⟨x, y, z, ?_⟩
  have : (p : ℤ) ^ k ∣ x ^ 3 - a := dvd_trans (pow_dvd_pow _ (by omega)) hx
  obtain ⟨c, hc⟩ := this
  exact ⟨c, by push_cast; rw [ha] at hc; linarith⟩

/-- Auxiliary step for `p = 3`: if `ε (n - b³ - c³) ≡ 1 (mod 9)` with `ε = ±1`, then `n` is a
sum of three cubes modulo every power of `3`. -/
theorem solvableMod_three_pow_aux (n b c e : ℤ) (he : e = 1 ∨ e = -1)
    (h : (9 : ℤ) ∣ e * (n - b ^ 3 - c ^ 3) - 1) (k : ℕ) : SolvableMod (3 ^ k) n := by
  obtain ⟨x, hx⟩ := cube_lift_three (e * (n - b ^ 3 - c ^ 3)) h k
  refine ⟨e * x, b, c, ?_⟩
  obtain ⟨d, hd⟩ := hx
  have he3 : e ^ 3 = e := by rcases he with rfl | rfl <;> ring
  have he2 : e ^ 2 = 1 := by rcases he with rfl | rfl <;> ring
  refine ⟨e * d, ?_⟩
  have hkey : (e * x) ^ 3 + b ^ 3 + c ^ 3 - n = e * (x ^ 3 - e * (n - b ^ 3 - c ^ 3)) := by
    linear_combination x ^ 3 * he3 + (n - b ^ 3 - c ^ 3) * he2
  rw [hkey, hd]
  push_cast
  ring

/-- **No obstruction beyond `9` at the prime `3`.**  If `n ≢ ±4 (mod 9)` then `n` is a sum of
three cubes modulo every power of `3`. -/
theorem solvableMod_three_pow (n : ℤ) (h4 : n % 9 ≠ 4) (h5 : n % 9 ≠ 5) (k : ℕ) :
    SolvableMod (3 ^ k) n := by
  have h9 : n % 9 = 0 ∨ n % 9 = 1 ∨ n % 9 = 2 ∨ n % 9 = 3 ∨ n % 9 = 6 ∨ n % 9 = 7 ∨
      n % 9 = 8 := by omega
  rcases h9 with h | h | h | h | h | h | h
  · exact solvableMod_three_pow_aux n 1 0 (-1) (Or.inr rfl) (by omega) k
  · exact solvableMod_three_pow_aux n 0 0 1 (Or.inl rfl) (by omega) k
  · exact solvableMod_three_pow_aux n 1 0 1 (Or.inl rfl) (by omega) k
  · exact solvableMod_three_pow_aux n 1 1 1 (Or.inl rfl) (by omega) k
  · exact solvableMod_three_pow_aux n (-1) (-1) (-1) (Or.inr rfl) (by omega) k
  · exact solvableMod_three_pow_aux n (-1) 0 (-1) (Or.inr rfl) (by omega) k
  · exact solvableMod_three_pow_aux n 0 0 (-1) (Or.inr rfl) (by omega) k

/-! ### Step 5: the Chinese remainder theorem -/

theorem crt_int {m₁ m₂ : ℤ} (hco : IsCoprime m₁ m₂) (a b : ℤ) :
    ∃ x : ℤ, m₁ ∣ x - a ∧ m₂ ∣ x - b := by
  obtain ⟨u, v, huv⟩ := hco
  refine ⟨b * u * m₁ + a * v * m₂, ⟨u * (b - a), ?_⟩, ⟨v * (a - b), ?_⟩⟩
  · linear_combination a * huv
  · linear_combination b * huv

/-- Solvability of the congruence is multiplicative over coprime moduli. -/
theorem solvableMod_mul {m₁ m₂ : ℕ} (hco : Nat.Coprime m₁ m₂) {n : ℤ}
    (h1 : SolvableMod m₁ n) (h2 : SolvableMod m₂ n) : SolvableMod (m₁ * m₂) n := by
  obtain ⟨x₁, y₁, z₁, hd₁⟩ := h1
  obtain ⟨x₂, y₂, z₂, hd₂⟩ := h2
  have hcoZ : IsCoprime (m₁ : ℤ) (m₂ : ℤ) := Nat.isCoprime_iff_coprime.mpr hco
  obtain ⟨x, hx1, hx2⟩ := crt_int hcoZ x₁ x₂
  obtain ⟨y, hy1, hy2⟩ := crt_int hcoZ y₁ y₂
  obtain ⟨z, hz1, hz2⟩ := crt_int hcoZ z₁ z₂
  have step : ∀ (m : ℕ) (a b c a' b' c' : ℤ), (m : ℤ) ∣ a - a' → (m : ℤ) ∣ b - b' →
      (m : ℤ) ∣ c - c' → (m : ℤ) ∣ a' ^ 3 + b' ^ 3 + c' ^ 3 - n →
      (m : ℤ) ∣ a ^ 3 + b ^ 3 + c ^ 3 - n := by
    intro m a b c a' b' c' ha hb hc hn
    have da : (m : ℤ) ∣ a ^ 3 - a' ^ 3 := ha.trans (sub_dvd_pow_sub_pow a a' 3)
    have db : (m : ℤ) ∣ b ^ 3 - b' ^ 3 := hb.trans (sub_dvd_pow_sub_pow b b' 3)
    have dc : (m : ℤ) ∣ c ^ 3 - c' ^ 3 := hc.trans (sub_dvd_pow_sub_pow c c' 3)
    have := dvd_add (dvd_add (dvd_add da db) dc) hn
    exact (by linarith : a ^ 3 + b ^ 3 + c ^ 3 - n =
      (a ^ 3 - a' ^ 3) + (b ^ 3 - b' ^ 3) + (c ^ 3 - c' ^ 3) +
        (a' ^ 3 + b' ^ 3 + c' ^ 3 - n)) ▸ this
  refine ⟨x, y, z, ?_⟩
  have d1 : (m₁ : ℤ) ∣ x ^ 3 + y ^ 3 + z ^ 3 - n := step m₁ x y z x₁ y₁ z₁ hx1 hy1 hz1 hd₁
  have d2 : (m₂ : ℤ) ∣ x ^ 3 + y ^ 3 + z ^ 3 - n := step m₂ x y z x₂ y₂ z₂ hx2 hy2 hz2 hd₂
  have := hcoZ.mul_dvd d1 d2
  simpa using this

/-! ### Main theorem -/

/-- **Local solvability is governed exactly by the congruence mod 9.**
For every modulus `m > 0` the congruence `x³ + y³ + z³ ≡ n (mod m)` is solvable, provided
`n ≢ ±4 (mod 9)`. -/
theorem solvableMod_of_mod_nine (n : ℤ) (h4 : n % 9 ≠ 4) (h5 : n % 9 ≠ 5) :
    ∀ m : ℕ, 0 < m → SolvableMod m n := by
  intro m
  induction m using Nat.recOnPosPrimePosCoprime with
  | prime_pow p k hp hk =>
      intro _
      by_cases h3 : p = 3
      · subst h3; exact solvableMod_three_pow n h4 h5 k
      · exact solvableMod_prime_pow_ne_three p hp h3 n k
  | zero => intro h; exact absurd h (by omega)
  | one => intro _; exact ⟨0, 0, 0, by simp⟩
  | coprime a b ha hb hab iha ihb =>
      intro _
      exact solvableMod_mul hab (iha (by omega)) (ihb (by omega))

/-- **Main theorem.**  The affine cubic surface `x³ + y³ + z³ = n` is everywhere locally
solvable if and only if `n ≢ ±4 (mod 9)`.  In other words the single congruence obstruction
modulo `9` accounts for *all* local obstructions. -/
theorem locallySolvable_iff (n : ℤ) : LocallySolvable n ↔ (n % 9 ≠ 4 ∧ n % 9 ≠ 5) := by
  constructor
  · intro h
    refine ⟨fun hc => ?_, fun hc => ?_⟩
    · exact not_locallySolvable_of_mod_nine (Or.inl hc) h
    · exact not_locallySolvable_of_mod_nine (Or.inr hc) h
  · rintro ⟨h4, h5⟩
    exact solvableMod_of_mod_nine n h4 h5

/-- Corollary: local solvability is a decidable, purely computable condition. -/
theorem locallySolvable_of_not_mod_nine {n : ℤ} (h4 : n % 9 ≠ 4) (h5 : n % 9 ≠ 5) :
    LocallySolvable n := (locallySolvable_iff n).mpr ⟨h4, h5⟩

end ThreeCubes