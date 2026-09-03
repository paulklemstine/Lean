import Bridges.Ma1EffectiveEntropy

/-!
# Synthesis: the MA-1 effectivity package for a single modulus

The three cycles of this loop each certify one consequence of the equidistribution
certificate.  This file assembles them into the single statement that experiment 509's
readout actually licenses for a fixed modulus `m`, at the recorded relative deviation
`ε = 0.000446`:

`ma1_effective_package` — for a count vector `N : (ZMod m)ˣ → ℝ` carrying the certificate
with positive target `μ = Li(x)/φ(m)`,

1. **order**: every two class counts are within a factor `1.001`;
2. **cap**: the effective `4/3` cap holds for the max/min readout with constant `< 1.3346`,
   i.e. to three significant figures;
3. **harmonic analysis**: every nontrivial Dirichlet character mod `m` has twisted sum at
   most `φ(m)·ε·μ = ε·Li(x)`;
4. **information**: the empirical distribution of primes over the reduced classes is within
   `0.0009` nats of uniform.

Each conjunct is a theorem from the earlier files; the point of the package is that they
hold *simultaneously*, from one measured number, with no further arithmetic input.
-/

namespace Ma1Effective

open Finset

/-- **The MA-1 effectivity package.**  Everything experiment 509's `ε = 0.000446` licenses
for one modulus, in one statement. -/
theorem ma1_effective_package {m : ℕ} [NeZero m] {N : (ZMod m)ˣ → ℝ} {μ : ℝ}
    (h : EquiCert N μ 0.000446) (hμ : 0 < μ) :
    (∀ a b : (ZMod m)ˣ, N a ≤ 1.001 * N b) ∧
    (maxOf N ≤ 1.3346 * minOf N) ∧
    (∀ χ : DirichletCharacter ℂ m, χ.toUnitHom ≠ 1 →
      ‖∑ a : (ZMod m)ˣ, χ (a : ZMod m) * (N a : ℂ)‖
        ≤ (Nat.totient m : ℝ) * (0.000446 * μ)) ∧
    klFromUniform (classDist N) ≤ 0.0009 := by
  have hε1 : (0.000446 : ℝ) < 1 := by norm_num
  have hε0 : (0 : ℝ) ≤ 0.000446 := by norm_num
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro a b
    have hb : 0 < N b := h.pos hμ hε1 b
    have hratio := h.ratio_le hε1 hε0 a b
    have hcoef : (1 + (0.000446 : ℝ)) / (1 - 0.000446) ≤ 1.001 := by norm_num
    calc N a ≤ (1 + (0.000446 : ℝ)) / (1 - 0.000446) * N b := hratio
      _ ≤ 1.001 * N b := mul_le_mul_of_nonneg_right hcoef (le_of_lt hb)
  · have hmain := maxOf_le_capConst_mul_minOf h (le_of_lt hμ) hε0 hε1
    have hmin : 0 < minOf N := by
      rw [minOf, Finset.lt_inf'_iff]
      exact fun a _ => h.pos hμ hε1 a
    have hcap := le_of_lt capConst_exp509.2
    nlinarith
  · intro χ hχ
    exact dirichletCharacter_sum_bound χ hχ h
  · exact exp509_kl_le h hμ

end Ma1Effective