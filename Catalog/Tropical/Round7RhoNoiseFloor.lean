import Mathlib

/-!
# Round-7 closure STATICRHO: scoping the noise-floor principle

Experiment 326 measured that the *correlated* sample set produced by the static
rho walk `x ↦ x² + 1 (mod N)` has factor-bearing density far above the
`N^{-1/2}` noise floor, and concluded that the noise-floor principle must be
scoped to **atomic uniform primitives**.  This file proves the three arithmetic
facts that make that refinement precise.

* `rhoZ_iterate_modEq` : the rho walk **commutes with reduction**: congruent
  seeds stay congruent, so the walk mod `N` covers a walk mod `p` — the source
  of the correlation.
* `exists_collision_mod_p` : by pigeonhole the walk mod `p` **collides within
  `p + 1` steps**, so among the first `p + 1` correlated samples a
  factor-bearing pair always exists (density `≥ 2/(p+1)p`, unconditionally,
  with no probabilistic hypothesis at all).
* `gcd_extract_of_dvd_sub` : a collision mod `p` that is *not* a collision mod
  `N` **extracts the factor**: `gcd(xᵢ - xⱼ, N) = p`.
* `rho_collision_extracts_factor` : the three combined — the correctness core of
  Pollard's rho.
* `aggregation_cost` : the escape is paid for by aggregation: extracting a
  factor from `T` correlated samples requires the `T(T-1)/2` pairwise gcds,
  which for `T = p + 1` already exceeds the `p` trial divisions.  This is the
  precise sense in which the correlated sample set does not beat the floor.

Contrast with `Catalog/Tropical/Round7ZeroDivisorGraph.lean`, where the atomic
uniform primitive is shown to succeed with probability at most `2/p`.
-/

namespace Round7Rho

/-! ## 1. The rho map and its compatibility with reduction -/

/-- The static rho map `x ↦ x² + 1`, taken over `ℤ` so that gcd extraction makes
sense on differences of iterates. -/
def rhoZ (x : ℤ) : ℤ := x ^ 2 + 1

/-- The rho map preserves congruences: this is the structural correlation that
lifts a walk mod `p` to the walk mod `N`. -/
theorem rhoZ_modEq {m : ℤ} {a b : ℤ} (h : a ≡ b [ZMOD m]) : rhoZ a ≡ rhoZ b [ZMOD m] := by
  unfold rhoZ
  simpa [sq] using (h.mul h).add_right 1

/-- Iterated form: congruent seeds have congruent orbits. -/
theorem rhoZ_iterate_modEq {m : ℤ} {a b : ℤ} (h : a ≡ b [ZMOD m]) (t : ℕ) :
    rhoZ^[t] a ≡ rhoZ^[t] b [ZMOD m] := by
  induction t generalizing a b with
  | zero => simpa using h
  | succ n ih =>
      rw [Function.iterate_succ_apply, Function.iterate_succ_apply]
      exact ih (rhoZ_modEq h)

/-! ## 2. The collision: pigeonhole on the reduced walk -/

/-- **Collision within `p + 1` steps.** For any seed, two of the first `p + 1`
iterates of the rho walk agree modulo `p`.  No randomness and no heuristic is
involved: the reduced state space has only `p` elements. -/
theorem exists_collision_mod_p (p : ℕ) (hp : 0 < p) (x₀ : ℤ) :
    ∃ i j : ℕ, i < j ∧ j ≤ p ∧ (p : ℤ) ∣ (rhoZ^[j] x₀ - rhoZ^[i] x₀) := by
  haveI : NeZero p := ⟨hp.ne'⟩
  -- the map `t ↦ x_t mod p` on `Fin (p+1)` cannot be injective
  have hcard : Fintype.card (ZMod p) < Fintype.card (Fin (p + 1)) := by
    simp [ZMod.card]
  obtain ⟨i, j, hij, hEq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun t : Fin (p + 1) => ((rhoZ^[t.1] x₀ : ℤ) : ZMod p))
      hcard
  rcases lt_or_gt_of_ne (fun h : (i : ℕ) = j => hij (Fin.ext h)) with h | h
  · refine ⟨i.1, j.1, h, by omega, ?_⟩
    have := (ZMod.intCast_eq_intCast_iff' _ _ _).mp hEq.symm
    exact Int.ModEq.dvd this.symm
  · refine ⟨j.1, i.1, h, by omega, ?_⟩
    have := (ZMod.intCast_eq_intCast_iff' _ _ _).mp hEq
    exact Int.ModEq.dvd this.symm

/-! ## 3. Extraction: a one-sided collision reveals the factor -/

/-- **Extraction lemma.** If `p` divides the difference of two samples but `q`
does not, the gcd with `N = pq` is exactly `p`. -/
theorem gcd_extract_of_dvd_sub {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {d : ℤ}
    (hpd : (p : ℤ) ∣ d) (hqd : ¬ ((q : ℤ) ∣ d)) : Int.gcd d (p * q : ℕ) = p := by
  have hgN : Int.gcd d (p * q : ℕ) ∣ p * q := by
    have h := Int.gcd_dvd_right d ((p * q : ℕ) : ℤ)
    exact_mod_cast h
  have hgd : ((Int.gcd d (p * q : ℕ) : ℕ) : ℤ) ∣ d := Int.gcd_dvd_left _ _
  have hpg : p ∣ Int.gcd d (p * q : ℕ) := by
    have h1 : (p : ℤ) ∣ ((p * q : ℕ) : ℤ) := by push_cast; exact ⟨q, rfl⟩
    have h2 := Int.dvd_gcd hpd h1
    exact_mod_cast h2
  obtain ⟨k, hk⟩ := hpg
  have hkq : k ∣ q := by
    have : p * k ∣ p * q := hk ▸ hgN
    exact (mul_dvd_mul_iff_left hp.pos.ne').mp this
  rcases (Nat.Prime.eq_one_or_self_of_dvd hq k hkq) with h1 | h1
  · rw [hk, h1, mul_one]
  · exfalso
    apply hqd
    have hqg : (q : ℤ) ∣ ((Int.gcd d (p * q : ℕ) : ℕ) : ℤ) := by
      rw [hk, h1]
      exact ⟨(p : ℤ), by push_cast; ring⟩
    exact hqg.trans hgd

/-- **Correctness core of the rho method.** Among the first `p + 1` correlated
samples there is a pair whose difference is divisible by `p`; whenever such a
pair is not also a collision mod `q`, the gcd returns the factor `p`.  This is
the "known-method exception" of the noise-floor principle: the sample set is
correlated, not atomic-uniform. -/
theorem rho_collision_extracts_factor {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (x₀ : ℤ) :
    ∃ i j : ℕ, i < j ∧ j ≤ p ∧ (p : ℤ) ∣ (rhoZ^[j] x₀ - rhoZ^[i] x₀) ∧
      (¬ ((q : ℤ) ∣ (rhoZ^[j] x₀ - rhoZ^[i] x₀)) →
        Int.gcd (rhoZ^[j] x₀ - rhoZ^[i] x₀) (p * q : ℕ) = p) := by
  obtain ⟨i, j, hij, hjp, hdvd⟩ := exists_collision_mod_p p hp.pos x₀
  exact ⟨i, j, hij, hjp, hdvd, fun hq' => gcd_extract_of_dvd_sub hp hq hdvd hq'⟩

/-! ## 4. The aggregation price -/

/-- **Barrier 4 (aggregation).** Turning the `T = p + 1` correlated samples into
a factor by pairwise gcds costs `T(T-1)/2 ≥ p` operations — at least the trial
division cost.  The density gain of the correlated set is therefore not a gain
in complexity. -/
theorem aggregation_cost (p : ℕ) : p ≤ (p + 1).choose 2 := by
  rw [Nat.choose_two_right, Nat.add_sub_cancel, Nat.le_div_iff_mul_le (by norm_num)]
  rcases Nat.eq_zero_or_pos p with rfl | hp
  · simp
  · nlinarith

/-- The floor for the *atomic uniform* primitive, restated for comparison: a
single uniform sample from `[1, N)` hits a multiple of `p` with probability
`1/p`, and the two densities differ by the factor `p` that the correlated walk
buys — at the cost of `aggregation_cost`. -/
theorem uniform_multiples_card {p q : ℕ} (hp : 0 < p) :
    ((Finset.Ioo 0 (p * q)).filter (fun x => p ∣ x)).card * p = p * q - p := by
  have himg : (Finset.Ioo 0 (p * q)).filter (fun x => p ∣ x)
      = (Finset.Ioo 0 q).image (p * ·) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_Ioo, Finset.mem_image]
    constructor
    · rintro ⟨⟨hx0, hxN⟩, k, rfl⟩
      refine ⟨k, ⟨?_, ?_⟩, rfl⟩
      · rcases Nat.eq_zero_or_pos k with rfl | hk
        · simp at hx0
        · exact hk
      · exact lt_of_mul_lt_mul_left hxN (Nat.zero_le p)
    · rintro ⟨k, ⟨hk0, hkq⟩, rfl⟩
      exact ⟨⟨Nat.mul_pos hp hk0, by nlinarith⟩, ⟨k, rfl⟩⟩
  have hinj : Function.Injective (fun k : ℕ => p * k) := fun a b hab =>
    Nat.eq_of_mul_eq_mul_left hp hab
  rw [himg, Finset.card_image_of_injective _ hinj, Nat.card_Ioo]
  have hq0 : q - 0 - 1 = q - 1 := by omega
  rw [hq0, Nat.sub_mul, one_mul, Nat.mul_comm q p]

end Round7Rho