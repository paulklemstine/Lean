import Tropical.SmoothSelfHintNoResidueHint

/-!
# Smoothness of `p - 1` is not a self-hint either

The `p - 1`/ECM weakness of a semiprime `N = p q` is the `B`-smoothness of `p - 1`.
Experiment 389 finds it undetectable from `N`: neither the residue `N mod 1155`
(`I = 0.006` bits, at the shuffled-null level) nor the `N`-computable smoothness of
`N ± 1` (`corr ≤ 0.014`) predicts it.  This file proves the corresponding logical
statements.

* `SmoothSelfHint.BSmooth` — `∀ prime p ∣ n, p ≤ B`.
* `SmoothSelfHint.congruent_semiprimes_with_given_smaller_factors` — for any modulus `M`
  and any `u, v` coprime to `M`, one can complete `u` and `v` to semiprimes that are
  congruent mod `M`.  (Dirichlet supplies the partners; the residue only sees the
  product, so any property of the smaller factor alone is erased.)
* `SmoothSelfHint.smoothness_no_residue_dial_1155` — the experiment's exact test:
  no function of `N mod 1155` decides whether `p - 1` is `10`-smooth.
* `SmoothSelfHint.smoothness_four_quadrants` — all four combinations of
  ("`N - 1` is `10`-smooth", "`p - 1` is `10`-smooth") occur (`253, 1081, 143, 667`),
  so the `N`-computable bit is logically independent of the secret one.
* `SmoothSelfHint.no_pm_one_smoothness_hint` — even the *pair* of `N`-computable bits
  (`N-1` smooth?, `N+1` smooth?) fails: `253 = 11·23` and `1081 = 23·47` have the same
  pair `(true, false)` and opposite secret bits.
-/

namespace SmoothSelfHint

/-- `n` is `B`-smooth: every prime factor is at most `B`. -/
def BSmooth (B n : ℕ) : Prop := ∀ p : ℕ, p.Prime → p ∣ n → p ≤ B

/-- Smoothness is inherited from a divisibility relation into a power of a fixed
`B`-smooth base. -/
theorem bsmooth_of_dvd_pow {B n P k : ℕ} (hP : BSmooth B P) (h : n ∣ P ^ k) :
    BSmooth B n := fun p hp hd => hP p hp (hp.dvd_of_dvd_pow (hd.trans h))

set_option maxRecDepth 8000 in
/-- `210 = 2·3·5·7` is `10`-smooth. -/
theorem bsmooth_ten_210 : BSmooth 10 210 := by
  intro p hp hd
  have hple : p ≤ 210 := Nat.le_of_dvd (by norm_num) hd
  have : ∀ r < 211, Nat.Prime r → r ∣ 210 → r ≤ 10 := by decide
  exact this p (by omega) hp hd

theorem bsmooth_ten_10 : BSmooth 10 10 :=
  bsmooth_of_dvd_pow (k := 1) bsmooth_ten_210 (by norm_num)

theorem bsmooth_ten_252 : BSmooth 10 252 :=
  bsmooth_of_dvd_pow (k := 3) bsmooth_ten_210 (by norm_num)

theorem bsmooth_ten_1080 : BSmooth 10 1080 :=
  bsmooth_of_dvd_pow (k := 3) bsmooth_ten_210 (by norm_num)

/-- A single large prime factor destroys smoothness. -/
theorem not_bsmooth_of_prime_dvd {B n r : ℕ} (hr : r.Prime) (hd : r ∣ n) (hB : B < r) :
    ¬ BSmooth B n := fun h => absurd (h r hr hd) (by omega)

theorem not_bsmooth_ten_22 : ¬ BSmooth 10 22 :=
  not_bsmooth_of_prime_dvd (r := 11) (by norm_num) (by norm_num) (by norm_num)

theorem not_bsmooth_ten_142 : ¬ BSmooth 10 142 :=
  not_bsmooth_of_prime_dvd (r := 71) (by norm_num) (by norm_num) (by norm_num)

theorem not_bsmooth_ten_666 : ¬ BSmooth 10 666 :=
  not_bsmooth_of_prime_dvd (r := 37) (by norm_num) (by norm_num) (by norm_num)

theorem not_bsmooth_ten_254 : ¬ BSmooth 10 254 :=
  not_bsmooth_of_prime_dvd (r := 127) (by norm_num) (by norm_num) (by norm_num)

theorem not_bsmooth_ten_1082 : ¬ BSmooth 10 1082 :=
  not_bsmooth_of_prime_dvd (r := 541) (by norm_num) (by norm_num) (by norm_num)

/-! ## No residue hint for smoothness, at any modulus -/

/-- **Partner completion.**  Fix a modulus `M` and two numbers `u, v` coprime to `M`.
Then `u` and `v` can be completed to semiprimes `u q₁`, `v q₂` (with `u < q₁`, `v < q₂`
prime) that are *congruent modulo `M`*.  Consequently no property of the smaller factor
alone can be read off from `N mod M`: Dirichlet supplies a partner that erases it. -/
theorem congruent_semiprimes_with_given_smaller_factors (M u v : ℕ) (hM : 0 < M)
    (huM : Nat.Coprime u M) (hvM : Nat.Coprime v M) :
    ∃ q₁ q₂ : ℕ, q₁.Prime ∧ q₂.Prime ∧ u < q₁ ∧ v < q₂ ∧
      (u * q₁) % M = (v * q₂) % M := by
  have hMne : M ≠ 0 := hM.ne'
  obtain ⟨q₁, hq₁gt, hq₁p, hq₁m⟩ :=
    Nat.forall_exists_prime_gt_and_modEq (q := M) (a := v) (max u v) hMne hvM
  obtain ⟨q₂, hq₂gt, hq₂p, hq₂m⟩ :=
    Nat.forall_exists_prime_gt_and_modEq (q := M) (a := u) (max u v) hMne huM
  refine ⟨q₁, q₂, hq₁p, hq₂p, lt_of_le_of_lt (le_max_left u v) hq₁gt,
    lt_of_le_of_lt (le_max_right u v) hq₂gt, ?_⟩
  have e₁ : u * q₁ ≡ u * v [MOD M] := Nat.ModEq.mul_left u hq₁m
  have e₂ : v * q₂ ≡ v * u [MOD M] := Nat.ModEq.mul_left v hq₂m
  refine e₁.trans (Nat.ModEq.symm ?_)
  simpa [Nat.mul_comm] using e₂

/-- `12 = 2²·3` is `10`-smooth. -/
theorem bsmooth_ten_12 : BSmooth 10 12 :=
  bsmooth_of_dvd_pow (k := 2) bsmooth_ten_210 (by norm_num)

/-- **The experiment's test, unconditionally.**  No function of `N mod 1155`
(`1155 = 3·5·7·11`, exactly the modulus used in Experiment 389) decides whether the
smaller prime factor `p` of a semiprime satisfies "`p - 1` is `10`-smooth". -/
theorem smoothness_no_residue_dial_1155 :
    ¬ ∃ f : ℕ → Prop, ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        (BSmooth 10 (p - 1) ↔ f ((p * q) % 1155)) := by
  rintro ⟨f, hf⟩
  obtain ⟨q₁, q₂, hq₁p, hq₂p, hlt₁, hlt₂, hmod⟩ :=
    congruent_semiprimes_with_given_smaller_factors 1155 13 23 (by norm_num) (by norm_num)
      (by norm_num)
  have e₁ := hf 13 q₁ (by norm_num) hq₁p hlt₁
  have e₂ := hf 23 q₂ (by norm_num) hq₂p hlt₂
  rw [hmod] at e₁
  have h13 : BSmooth 10 (13 - 1) := by simpa using bsmooth_ten_12
  have h23 : ¬ BSmooth 10 (23 - 1) := by simpa using not_bsmooth_ten_22
  exact h23 (e₂.mpr (e₁.mp h13))

/-! ## No `N ± 1` self-hint -/

/-- **All four quadrants occur.**  The `N`-computable bit "`N - 1` is `10`-smooth" and
the secret bit "`p - 1` is `10`-smooth" are logically independent:
`253 = 11·23`, `1081 = 23·47`, `143 = 11·13`, `667 = 23·29` realise `(T,T)`, `(T,F)`,
`(F,T)`, `(F,F)`. -/
theorem smoothness_four_quadrants :
    (BSmooth 10 (253 - 1) ∧ BSmooth 10 (11 - 1)) ∧
    (BSmooth 10 (1081 - 1) ∧ ¬ BSmooth 10 (23 - 1)) ∧
    (¬ BSmooth 10 (143 - 1) ∧ BSmooth 10 (11 - 1)) ∧
    (¬ BSmooth 10 (667 - 1) ∧ ¬ BSmooth 10 (23 - 1)) := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ?_, ?_⟩
  · simpa using bsmooth_ten_252
  · simpa using bsmooth_ten_10
  · simpa using bsmooth_ten_1080
  · simpa using not_bsmooth_ten_22
  · simpa using not_bsmooth_ten_142
  · simpa using bsmooth_ten_10
  · simpa using not_bsmooth_ten_666
  · simpa using not_bsmooth_ten_22

/-- **No `N ± 1` instance-class self-hint.**  Even the pair of `N`-computable bits
(`N-1` `10`-smooth?, `N+1` `10`-smooth?) does not determine the secret bit:
`253 = 11 · 23` and `1081 = 23 · 47` both have pair `(true, false)`, yet `11 - 1 = 10`
is `10`-smooth while `23 - 1 = 22 = 2 · 11` is not. -/
theorem no_pm_one_smoothness_hint :
    ¬ ∃ f : Prop → Prop → Prop, ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        (BSmooth 10 (p - 1) ↔ f (BSmooth 10 (p * q - 1)) (BSmooth 10 (p * q + 1))) := by
  rintro ⟨f, hf⟩
  have e₁ := hf 11 23 (by norm_num) (by norm_num) (by norm_num)
  have e₂ := hf 23 47 (by norm_num) (by norm_num) (by norm_num)
  norm_num at e₁ e₂
  have hminus : BSmooth 10 252 = BSmooth 10 1080 :=
    propext ⟨fun _ => bsmooth_ten_1080, fun _ => bsmooth_ten_252⟩
  have hplus : BSmooth 10 254 = BSmooth 10 1082 :=
    propext ⟨fun h => absurd h not_bsmooth_ten_254, fun h => absurd h not_bsmooth_ten_1082⟩
  rw [hminus, hplus] at e₁
  exact not_bsmooth_ten_22 (by simpa using e₂.mpr (e₁.mp (by simpa using bsmooth_ten_10)))

end SmoothSelfHint