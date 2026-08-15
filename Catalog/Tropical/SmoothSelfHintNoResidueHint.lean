import Tropical.SmoothSelfHintDichotomyCore

/-!
# No residue self-hint at *any* modulus

`Tropical.SmoothSelfHintDichotomyCore` shows that the asymmetric divisibility event
`l ∣ p - 1` is invisible in the residue `N mod l`, and `SmoothSelfHintInformation`
computes the corresponding mutual information to be exactly zero.  Experiment 389 tests
richer residues (`N mod 1155`, i.e. `l = 3,5,7,11` jointly) and again finds nothing.

Here we prove the corresponding *unconditional* statement: for any modulus base `l > 2`
(primality of `l` is not even needed) and an
**arbitrary** modulus `M`, no function of `N mod M` computes the bit `l ∣ p - 1` for
semiprimes `N = p q` with `p < q`.  The proof is a swap construction fed by Dirichlet's
theorem on primes in arithmetic progressions: choose

* `p₁ ≡ 1`, `q₁ ≡ -1`, `p₂ ≡ -1`, `q₂ ≡ 1` (mod `l M`), with `p₁ < q₁ < p₂ < q₂`.

Then `p₁ q₁ ≡ p₂ q₂ ≡ -1 (mod l M)`, so the two semiprimes are congruent modulo `M`
(indeed modulo `l M`), while `l ∣ p₁ - 1` and `l ∤ p₂ - 1`.  The residue of `N` sees only
the *unordered* product; the ordered information — which factor is `≡ 1` — is destroyed.

* `SmoothSelfHint.asym_indistinguishable_mod` : the construction.
* `SmoothSelfHint.asym_no_residue_dial_any_modulus` : the resulting impossibility.
* `SmoothSelfHint.asym_no_residue_dial_1155` : the exact modulus tested in the
  experiment (`1155 = 3·5·7·11`), for the bit `3 ∣ p - 1`.
-/

namespace SmoothSelfHint

/-- `Q - 1` is coprime to `Q`. -/
private theorem coprime_pred_self {Q : ℕ} (hQ : 1 ≤ Q) : Nat.Coprime (Q - 1) Q := by
  have hs : Q = (Q - 1) + 1 := by omega
  rw [hs]
  simp

/-- **The swap construction.**  For every odd prime `l` and every modulus `M ≥ 1` there
are two semiprimes with the same residue mod `M` whose smaller factors disagree on the
divisibility bit `l ∣ p - 1`. -/
theorem asym_indistinguishable_mod (l M : ℕ) (hl2 : 2 < l) (hM : 0 < M) :
    ∃ p₁ q₁ p₂ q₂ : ℕ,
      p₁.Prime ∧ q₁.Prime ∧ p₂.Prime ∧ q₂.Prime ∧ p₁ < q₁ ∧ q₁ < p₂ ∧ p₂ < q₂ ∧
        (p₁ * q₁) % M = (p₂ * q₂) % M ∧ l ∣ p₁ - 1 ∧ ¬ l ∣ p₂ - 1 := by
  set Q := l * M with hQdef
  have hQpos : 0 < Q := Nat.mul_pos (by omega) hM
  have hQne : Q ≠ 0 := hQpos.ne'
  have hlQ : l ∣ Q := Dvd.intro M rfl
  have hMQ : M ∣ Q := Dvd.intro_left l rfl
  have hQl : l ≤ Q := Nat.le_mul_of_pos_right l hM
  have h1 : Nat.Coprime 1 Q := Nat.gcd_one_left Q
  have h2 : Nat.Coprime (Q - 1) Q := coprime_pred_self (by omega)
  obtain ⟨p₁, hp₁gt, hp₁p, hp₁m⟩ := Nat.forall_exists_prime_gt_and_modEq 1 hQne h1
  obtain ⟨q₁, hq₁gt, hq₁p, hq₁m⟩ := Nat.forall_exists_prime_gt_and_modEq p₁ hQne h2
  obtain ⟨p₂, hp₂gt, hp₂p, hp₂m⟩ := Nat.forall_exists_prime_gt_and_modEq q₁ hQne h2
  obtain ⟨q₂, hq₂gt, hq₂p, hq₂m⟩ := Nat.forall_exists_prime_gt_and_modEq p₂ hQne h1
  refine ⟨p₁, q₁, p₂, q₂, hp₁p, hq₁p, hp₂p, hq₂p, hq₁gt, hp₂gt, hq₂gt, ?_, ?_, ?_⟩
  · -- the two products agree modulo `Q`, hence modulo `M`
    have e₁ : p₁ * q₁ ≡ 1 * (Q - 1) [MOD Q] := Nat.ModEq.mul hp₁m hq₁m
    have e₂ : p₂ * q₂ ≡ (Q - 1) * 1 [MOD Q] := Nat.ModEq.mul hp₂m hq₂m
    have e : p₁ * q₁ ≡ p₂ * q₂ [MOD Q] := by
      refine e₁.trans (Nat.ModEq.symm ?_)
      simpa [Nat.mul_comm] using e₂
    exact Nat.ModEq.of_dvd hMQ e
  · -- `p₁ ≡ 1 (mod l)`
    have hml : p₁ ≡ 1 [MOD l] := Nat.ModEq.of_dvd hlQ hp₁m
    exact (Nat.modEq_iff_dvd' (by omega)).mp hml.symm
  · -- `p₂ ≡ -1 (mod l)`, so `l ∤ p₂ - 1` because `l > 2`
    intro hdvd
    have hml : p₂ ≡ Q - 1 [MOD l] := Nat.ModEq.of_dvd hlQ hp₂m
    have h1p : (1 : ℕ) ≡ p₂ [MOD l] := (Nat.modEq_iff_dvd' (by omega)).mpr hdvd
    have hcon : (1 : ℕ) ≡ Q - 1 [MOD l] := h1p.trans hml
    have hdvd2 : l ∣ Q - 1 - 1 := (Nat.modEq_iff_dvd' (by omega)).mp hcon
    have hQ2 : l ∣ 2 := by
      have := Nat.dvd_sub hlQ hdvd2
      have heq : Q - (Q - 1 - 1) = 2 := by omega
      rwa [heq] at this
    have := Nat.le_of_dvd (by norm_num) hQ2
    omega

/-- **No residue self-hint at any modulus.**  For an odd prime `l` and any modulus `M`,
there is no function of `N mod M` that decides whether the smaller prime factor `p` of a
semiprime `N = p q` satisfies `l ∣ p - 1`. -/
theorem asym_no_residue_dial_any_modulus (l M : ℕ) (hl2 : 2 < l) (hM : 0 < M) :
    ¬ ∃ f : ℕ → Bool, ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        (decide (l ∣ p - 1) = f ((p * q) % M)) := by
  rintro ⟨f, hf⟩
  obtain ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hlt₁, _, hlt₂, hmod, hd₁, hd₂⟩ :=
    asym_indistinguishable_mod l M hl2 hM
  have e₁ := hf p₁ q₁ hp₁ hq₁ hlt₁
  have e₂ := hf p₂ q₂ hp₂ hq₂ hlt₂
  rw [hmod] at e₁
  rw [← e₂] at e₁
  simp only [decide_eq_decide] at e₁
  exact hd₂ (e₁.mp hd₁)

/-- The experiment's actual test: even the full residue `N mod 1155` (`1155 = 3·5·7·11`)
carries no information about `3 ∣ p - 1`. -/
theorem asym_no_residue_dial_1155 :
    ¬ ∃ f : ℕ → Bool, ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        (decide (3 ∣ p - 1) = f ((p * q) % 1155)) :=
  asym_no_residue_dial_any_modulus 3 1155 (by norm_num) (by norm_num)

end SmoothSelfHint