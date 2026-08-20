import Mathlib
import NumberTheory.MordellQuarticClassCount
import Combinatorics.MordellDenominatorBarrier

/-!
# The information barrier extends to layer 4

`Combinatorics.MordellDenominatorBarrier` proved that the denominator data of `E_N` at the
doubling and tripling layers, restricted to primes `ℓ ≤ B`, cannot distinguish a semiprime
`N = pq` (with `p, q > B`) from a suitable prime `M`: both criteria are polynomial conditions
in `N`, hence depend on `N` only modulo `ℓ`, and Dirichlet's theorem supplies a prime `M` in
the class of `N` modulo `B!`.

Conjecture **C3** of the previous cycle asserts that this persists at *every* layer.  Here we
prove the next case, `n = 4`, using the layer-4 criterion of
`NumberTheory.MordellDenominatorQuartic`: the polynomial

`Ψ₄(N, x) = (x³ + N)(x⁶ + 20Nx³ - 8N²) = x⁹ + 21Nx⁶ + 12N²x³ - 8N³`

has integer coefficients, so `Ψ₄(N, x) ≡ Ψ₄(M, x) (mod ℓ)` whenever `N ≡ M (mod ℓ)`.

## Main results

* `Psi4_sub` : the explicit factorisation `Ψ₄(N,x) - Ψ₄(M,x) = (N - M)·Q(N, M, x)`.
* `dvd_Psi4_congr` : the layer-4 criterion depends only on `N mod ℓ`.
* `V4_congr` : so does the layer-4 residue-class locus.
* `denominator_data_barrier_layer234` : **the barrier through layer 4** — for every bound `B`
  and every semiprime `N = pq` with `p, q > B` there is a prime `M > N` for which the layer-2,
  layer-3 *and* layer-4 criteria at all primes `ℓ ≤ B` agree for `E_N` and `E_M`.

-- !-- Lab Notes -- !--
Hypothesizer (C3): the barrier should persist at every layer, because the layer-`n` criterion
  is `ℓ ∣ ψ_n(x)` with `ψ_n` a polynomial in `N`.
Experimenter: proved for `n = 4` here; the only input beyond the previous cycle is the layer-4
  criterion `dvd_den_quadruple_iff`, i.e. the fact that the *correct* layer-4 polynomial is
  `Ψ₄ = (x³+N)S(x)` rather than something involving `gcd(N, ℓ^k)`.
Analyst: this settles the "falsifiable form" of C3 at layer 4 in the negative direction the
  conjecture predicts — no dependence on `N` beyond `N mod ℓ` appears.  Note the contrast with
  the counting: the *criterion* is uniform in `N mod ℓ`, but the *number of solutions* is not
  uniform in `ℓ` (`MordellQuarticCount.layer4_total_not_linear`).
Critic: the theorem is about criteria, not about realised denominators; turning it into a
  statement about actual points still needs the realisability input D3.  No `sorry` below.
-/

namespace MordellQuarticBarrier

open MordellQuartic MordellQuarticCount MordellPointCount

/-- The layer-4 polynomial in expanded form: `Ψ₄(N, x) = x⁹ + 21Nx⁶ + 12N²x³ - 8N³`. -/
lemma Psi4_expand (N x : ℤ) : Psi4 N x = x ^ 9 + 21 * N * x ^ 6 + 12 * N ^ 2 * x ^ 3 - 8 * N ^ 3 := by
  rw [Psi4, sextic]; ring

/-- The difference of two layer-4 polynomials is divisible by the difference of the parameters,
with the explicit cofactor `21x⁶ + 12x³(N + M) - 8(N² + NM + M²)`. -/
lemma Psi4_sub (N M x : ℤ) :
    Psi4 N x - Psi4 M x
      = (N - M) * (21 * x ^ 6 + 12 * x ^ 3 * (N + M) - 8 * (N ^ 2 + N * M + M ^ 2)) := by
  rw [Psi4_expand, Psi4_expand]; ring

/-- **The layer-4 criterion depends only on `N mod ℓ`.** -/
theorem dvd_Psi4_congr {N M x : ℤ} {ℓ : ℕ} (h : (ℓ : ℤ) ∣ N - M) :
    ((ℓ : ℤ) ∣ Psi4 N x ↔ (ℓ : ℤ) ∣ Psi4 M x) := by
  have hdiff : (ℓ : ℤ) ∣ Psi4 N x - Psi4 M x := by
    rw [Psi4_sub]
    exact h.mul_right _
  constructor
  · intro hd
    have hs : (ℓ : ℤ) ∣ Psi4 N x - (Psi4 N x - Psi4 M x) := dvd_sub hd hdiff
    rwa [sub_sub_cancel] at hs
  · intro hd
    have hs : (ℓ : ℤ) ∣ Psi4 M x + (Psi4 N x - Psi4 M x) := dvd_add hd hdiff
    rwa [add_sub_cancel] at hs

/-- **The layer-4 residue-class locus depends only on `N mod ℓ`.** -/
theorem V4_congr {ℓ : ℕ} [Fact ℓ.Prime] {N M : ℤ} (h : ((N : ZMod ℓ)) = ((M : ZMod ℓ))) :
    V4 ℓ ((N : ZMod ℓ)) = V4 ℓ ((M : ZMod ℓ)) := by rw [h]

/-- **The barrier through layer 4.**  Let `N = pq` be a semiprime whose prime factors both
exceed `B`.  Then there is a prime `M > N` such that for every prime `ℓ ≤ B` and every integer
`x`, the layer-2 criterion `ℓ ∣ x³ + N`, the layer-3 criterion `ℓ ∣ ψ₃(x)` and the layer-4
criterion `ℓ ∣ Ψ₄(x)` hold for `E_N` exactly when they hold for `E_M`.

So the denominator profile below `B` of the first four layers still carries no information
about the factorisation of `N`: conjecture C3 holds through `n = 4`. -/
theorem denominator_data_barrier_layer234 (B : ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpB : B < p) (hqB : B < q) :
    ∃ M : ℕ, M.Prime ∧ p * q < M ∧
      ∀ ℓ : ℕ, ℓ.Prime → ℓ ≤ B → ∀ x : ℤ,
        (((ℓ : ℤ) ∣ x ^ 3 + ((p * q : ℕ) : ℤ) ↔ (ℓ : ℤ) ∣ x ^ 3 + ((M : ℕ) : ℤ)) ∧
          ((ℓ : ℤ) ∣ psi3 ((p * q : ℕ) : ℤ) x ↔ (ℓ : ℤ) ∣ psi3 ((M : ℕ) : ℤ) x) ∧
          ((ℓ : ℤ) ∣ Psi4 ((p * q : ℕ) : ℤ) x ↔ (ℓ : ℤ) ∣ Psi4 ((M : ℕ) : ℤ) x)) := by
  obtain ⟨M, hMp, hMgt, hMmod⟩ :=
    exists_prime_congr_mod_factorial (N := p * q) (B := B) (n := p * q)
      (coprime_factorial_of_semiprime hp hq hpB hqB)
  refine ⟨M, hMp, hMgt, ?_⟩
  intro ℓ hl hlB x
  have hlfac : ℓ ∣ Nat.factorial B := Nat.dvd_factorial hl.pos hlB
  have hmod : M ≡ p * q [MOD ℓ] := hMmod.of_dvd hlfac
  have hdvd : (ℓ : ℤ) ∣ ((p * q : ℕ) : ℤ) - ((M : ℕ) : ℤ) :=
    (Nat.modEq_iff_dvd (n := ℓ) (a := M) (b := p * q)).mp hmod
  exact ⟨dvd_layer2_congr hdvd, dvd_psi3_congr hdvd, dvd_Psi4_congr hdvd⟩

end MordellQuarticBarrier