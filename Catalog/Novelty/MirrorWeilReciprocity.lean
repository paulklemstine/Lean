import Mathlib
import Novelty.ZetaModularity

/-!
# Arithmetic Mirror Symmetry IV — reciprocity of the middle zeta factor

This file settles (in corrected form) *Conjecture 4* of the arithmetic mirror-symmetry
programme: the **reciprocal middle zeta factor**.

Let `X/𝔽_q` be a smooth proper Calabi–Yau `n`-fold and let
`P_X(T) = ∏_{i} (1 − α_i T)` be the middle étale-cohomology factor of its zeta function,
of degree `d = deg P_X = b_n`.  Poincaré duality on `H^n` says that the multiset of
reciprocal roots `{α_i}` is stable under `α ↦ q^n/α`; i.e. there is a permutation `σ` of
the index set with `α_i · α_{σ i} = q^n`.

The whole functional equation is a *formal consequence of that root involution*, and this
file proves it in the strongest available generality: over an arbitrary commutative ring,
division-free.

* `prod_shift_eq_of_root_duality` — the structural core:
  `∏ (q^n T − α_i) = (−1)^d (∏ α_i) ∏ (1 − α_i T)`;
* `prod_roots_sq` — `(∏ α_i)² = q^{n d}`, so `∏ α_i` is a square root of `q^{nd}`;
* `middleFactor_reciprocal` — over a domain, whenever `n·d = 2m` there is a sign
  `ε ∈ {−1, 1}` with `∏ (q^n T − α_i) = ε (−1)^d q^m ∏ (1 − α_i T)`;
* `middleFactor_functional_equation` — the same statement in the classical analytic shape
  over a field: `q^m · T^d · P_X(1/(q^n T)) = ε · P_X(T)` with `m = n·d/2`;
* `cy_threefold_middle_reciprocal` — the Calabi–Yau **threefold** specialization
  `n = 3`, `d = 2`, `P(T) = 1 − a T + q³T²`, giving `q³T²P(1/(q³T)) = P(T)`, i.e. `ε = +1`;
* `elliptic_curve_middle_reciprocal` — the `n = 1` (elliptic curve) case, recovering the
  catalog's `Novelty.ArithMirror.eulerFactor_funeq` from the general theorem;
* `prompt_exponent_is_refuted` — a **counterexample to the exponent as originally
  displayed**: the conjecture as stated (`T^d P(1/(q^nT)) = ε q^{nd/2} P(T)`) is false
  already for the supersingular elliptic curve `a = 0, q = 2`; the correct exponent is
  `q^{−nd/2}`, equivalently the power of `q` belongs on the *left* side.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  The reciprocity of the middle factor should not need
  any geometry: it should follow from the single combinatorial datum "the reciprocal root
  multiset is `α ↦ q^n/α`-stable", and the sign `ε` should be the sign of the square root
  `∏ α_i = ±q^{nd/2}` (the *determinant of Frobenius* on `H^n`) times `(−1)^d`.
* **Experiment (Experimenter).**  Realized the multiset stability as a permutation `σ`
  with `α_i α_{σ i} = q^n` and pushed everything through `Finset.prod`.  The one-line
  identity `q^n T − α_i = α_i (α_{σ i} T − 1)` converts the shifted product into
  `(∏ α_i) · ∏ (α_{σ i}T − 1)`, and `Equiv.Perm` reindexing (`Fintype.prod_equiv`)
  removes `σ`.  Pulling `(−1)` out of each of the `d` factors gives the sign.
  Numerically (see `ComputationalEvidence.md`) the exponent displayed in the conjecture
  is off: for `a = 0, q = 2, n = 1, d = 2` one has `T²P(1/(2T)) = (1/2)P(T)`, not `2P(T)`.
* **Analysis (Analyst).**  Conjecture 4 is **true but misstated**: the correct identity is
  `q^{nd/2} T^d P(1/(q^nT)) = ε P(T)`.  The failure mode is a bookkeeping one — the
  displayed exponent has the wrong sign — and the corrected version is proved here in
  full generality, together with an explicit refutation of the displayed version.
  The sign `ε` is *not* free: `ε(−1)^d = ∏α_i / q^{nd/2} = det(Frob | H^n)/q^{nd/2}`.
* **Critique (Critic).**  No `decide`, no `native_decide`: the general theorem is a
  `Finset.prod` manipulation over an arbitrary `CommRing`, and the sign extraction uses
  `mul_self_eq_mul_self_iff` in a domain.  The refutation is an evaluation at `T = 1`
  in `ℚ` closed by `norm_num`, so it is a genuine counterexample rather than a
  vacuous statement.
* **Synthesis (PI).**  Root duality ⟹ functional equation, uniformly in `(n, d, q)`.
  The catalog's elliptic-curve functional equation `eulerFactor_funeq` is the `(n,d)=(1,2)`
  corner of this theorem, and the CY-threefold weight-4 case is `(n,d)=(3,2)`.
-/

namespace Novelty.MirrorBridge

open Finset

section CommRing

variable {R : Type*} [CommRing R]

/-- The middle zeta factor `P(T) = ∏ (1 − α_i T)` attached to a list of reciprocal
Frobenius roots `α : Fin d → R`. -/
def middleFactor {d : ℕ} (α : Fin d → R) (T : R) : R := ∏ i, (1 - α i * T)

/-- **Root duality ⟹ reciprocity (structural core).**
If the reciprocal roots are permuted by `α ↦ Q/α` (Poincaré duality on `H^n`, `Q = q^n`),
then the "reflected" product `∏ (Q·T − α_i)` is the original middle factor up to the
scalar `(−1)^d ∏ α_i`.  Division-free, over an arbitrary commutative ring. -/
theorem prod_shift_eq_of_root_duality {d : ℕ} (Q T : R) (α : Fin d → R)
    (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = Q) :
    ∏ i, (Q * T - α i) = (-1) ^ d * (∏ i, α i) * middleFactor α T := by
  have step1 : ∀ i : Fin d, Q * T - α i = α i * (α (σ i) * T - 1) := by
    intro i
    rw [← hdual i]; ring
  calc ∏ i, (Q * T - α i)
      = ∏ i, (α i * (α (σ i) * T - 1)) := Finset.prod_congr rfl (fun i _ => step1 i)
    _ = (∏ i, α i) * ∏ i, (α (σ i) * T - 1) := Finset.prod_mul_distrib
    _ = (∏ i, α i) * ∏ i, (α i * T - 1) := by
          congr 1
          exact Fintype.prod_equiv σ _ _ (fun i => rfl)
    _ = (∏ i, α i) * ∏ i, ((-1) * (1 - α i * T)) := by
          congr 1; exact Finset.prod_congr rfl (fun i _ => by ring)
    _ = (-1) ^ d * (∏ i, α i) * middleFactor α T := by
          rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ,
            Fintype.card_fin]
          unfold middleFactor; ring

/-- **The Frobenius determinant is a square root of `q^{nd}`.**
Root duality forces `(∏ α_i)² = Q^d`. -/
theorem prod_roots_sq {d : ℕ} (Q : R) (α : Fin d → R) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = Q) :
    (∏ i, α i) ^ 2 = Q ^ d := by
  have hperm : (∏ i, α (σ i)) = ∏ i, α i := Fintype.prod_equiv σ _ _ (fun i => rfl)
  calc (∏ i, α i) ^ 2 = (∏ i, α i) * (∏ i, α (σ i)) := by rw [hperm]; ring
    _ = ∏ i, (α i * α (σ i)) := (Finset.prod_mul_distrib).symm
    _ = ∏ _i : Fin d, Q := Finset.prod_congr rfl (fun i _ => hdual i)
    _ = Q ^ d := by rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin]

end CommRing

section Domain

variable {R : Type*} [CommRing R] [IsDomain R]

/-- The Frobenius determinant on middle cohomology is `± q^{nd/2}` whenever the
exponent `n·d/2` is an integer. -/
theorem prod_roots_eq_sign_mul_pow {d n m : ℕ} (hm : n * d = 2 * m) (q : R)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∏ i, α i = q ^ m ∨ ∏ i, α i = -(q ^ m) := by
  have hsq : (∏ i, α i) ^ 2 = (q ^ m) ^ 2 := by
    rw [prod_roots_sq (q ^ n) α σ hdual, ← pow_mul, ← pow_mul, hm, Nat.mul_comm 2 m]
  exact sq_eq_sq_iff_eq_or_eq_neg.mp hsq

/-- **Reciprocity of the middle zeta factor (corrected form).**
Let the reciprocal roots of the middle factor `P(T) = ∏(1 − α_i T)` of a smooth proper
Calabi–Yau `n`-fold over `𝔽_q` be permuted by `α ↦ q^n/α`, and suppose `n·d = 2m`
(`m = n·deg P/2` integral).  Then there is a sign `ε ∈ {−1, 1}` with

`∏ (q^n T − α_i) = ε · (−1)^d · q^m · P(T)`.

Division-free form of the functional equation. -/
theorem middleFactor_reciprocal {d n m : ℕ} (hm : n * d = 2 * m) (q T : R)
    (α : Fin d → R) (σ : Equiv.Perm (Fin d)) (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∃ ε : R, (ε = 1 ∨ ε = -1) ∧
      ∏ i, (q ^ n * T - α i) = ε * ((-1) ^ d * q ^ m) * middleFactor α T := by
  rcases prod_roots_eq_sign_mul_pow hm q α σ hdual with h | h
  · refine ⟨1, Or.inl rfl, ?_⟩
    rw [prod_shift_eq_of_root_duality (q ^ n) T α σ hdual, h]; ring
  · refine ⟨-1, Or.inr rfl, ?_⟩
    rw [prod_shift_eq_of_root_duality (q ^ n) T α σ hdual, h]; ring

end Domain

section Field

variable {K : Type*} [Field K]

/-- **Reflection of the middle factor.**  Substituting `T ↦ 1/(q^n T)` and clearing the
`T`-power turns `P` into the shifted product `∏ (q^n T − α_i)`, divided by `q^{nd}`. -/
theorem middleFactor_reflect {d n : ℕ} (q T : K) (hq : q ≠ 0) (hT : T ≠ 0)
    (α : Fin d → K) :
    T ^ d * middleFactor α (1 / (q ^ n * T)) = (∏ i, (q ^ n * T - α i)) / (q ^ n) ^ d := by
  have hqn : (q : K) ^ n ≠ 0 := pow_ne_zero _ hq
  have hstep : ∀ i : Fin d, T * (1 - α i * (1 / (q ^ n * T))) = (q ^ n * T - α i) / q ^ n := by
    intro i; field_simp
  unfold middleFactor
  calc T ^ d * ∏ i, (1 - α i * (1 / (q ^ n * T)))
      = (∏ _i : Fin d, T) * ∏ i, (1 - α i * (1 / (q ^ n * T))) := by
        rw [Finset.prod_const, Finset.card_univ, Fintype.card_fin]
    _ = ∏ i : Fin d, (T * (1 - α i * (1 / (q ^ n * T)))) := (Finset.prod_mul_distrib).symm
    _ = ∏ i : Fin d, ((q ^ n * T - α i) / q ^ n) :=
        Finset.prod_congr rfl (fun i _ => hstep i)
    _ = (∏ i, (q ^ n * T - α i)) / (q ^ n) ^ d := by
        rw [Finset.prod_div_distrib, Finset.prod_const, Finset.card_univ, Fintype.card_fin]

/-- **Functional equation of the middle zeta factor, analytic shape.**
For `P(T) = ∏(1 − α_i T)` of degree `d`, root duality `α_i α_{σ i} = q^n` and integrality
`n·d = 2m` give a sign `ε ∈ {−1,1}` with

`q^m · T^d · P(1/(q^n T)) = ε · P(T)`.

Note the position of the power of `q`: the exponent is `q^{+nd/2}` on the **left**
(equivalently `q^{−nd/2}` on the right); see `prompt_exponent_is_refuted`. -/
theorem middleFactor_functional_equation {d n m : ℕ} (hm : n * d = 2 * m) (q T : K)
    (hq : q ≠ 0) (hT : T ≠ 0) (α : Fin d → K) (σ : Equiv.Perm (Fin d))
    (hdual : ∀ i, α i * α (σ i) = q ^ n) :
    ∃ ε : K, (ε = 1 ∨ ε = -1) ∧
      q ^ m * T ^ d * middleFactor α (1 / (q ^ n * T)) = ε * middleFactor α T := by
  obtain ⟨ε, hε, hkey⟩ := middleFactor_reciprocal hm q T α σ hdual
  refine ⟨ε * (-1) ^ d, ?_, ?_⟩
  · rcases Nat.even_or_odd d with he | ho
    · rw [he.neg_one_pow]
      rcases hε with rfl | rfl
      · exact Or.inl (by ring)
      · exact Or.inr (by ring)
    · rw [ho.neg_one_pow]
      rcases hε with rfl | rfl
      · exact Or.inr (by ring)
      · exact Or.inl (by ring)
  · have hqm : (q : K) ^ m ≠ 0 := pow_ne_zero _ hq
    have hqnd : ((q : K) ^ n) ^ d = q ^ m * q ^ m := by
      rw [← pow_mul, hm, two_mul, pow_add]
    rw [mul_assoc, middleFactor_reflect q T hq hT α, hkey, hqnd]
    field_simp

/-- **Refutation of the exponent as originally displayed.**
The conjecture as stated asks for `T^d P(1/(q^n T)) = ε q^{n d/2} P(T)`.  Already for the
supersingular elliptic curve `a = 0` over `𝔽₂` (`n = 1`, `d = 2`, `q = 2`, middle factor
`P(T) = 1 + 2T²`) no such sign exists: evaluating at `T = 1` gives `3/2` on the left and
`±6` on the right.  The correct statement is `middleFactor_functional_equation`, where the
power of `q` sits on the other side. -/
theorem prompt_exponent_is_refuted :
    ¬ ∃ ε : ℚ, (ε = 1 ∨ ε = -1) ∧
      (1 : ℚ) ^ 2 * (1 + 2 * (1 / (2 ^ 1 * (1 : ℚ))) ^ 2)
        = ε * 2 ^ 1 * (1 + 2 * (1 : ℚ) ^ 2) := by
  rintro ⟨ε, hε | hε, h⟩ <;> rw [hε] at h <;> norm_num at h

/-- The degree-two middle factor with reciprocal roots `α₀, α₁` is the familiar
quadratic `1 − (α₀+α₁) T + α₀α₁ T²`. -/
theorem middleFactor_fin_two (α₀ α₁ T : K) :
    middleFactor ![α₀, α₁] T = 1 - (α₀ + α₁) * T + (α₀ * α₁) * T ^ 2 := by
  unfold middleFactor
  rw [Fin.prod_univ_two]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- The two-element root duality `α₀ α₁ = q^n` realized by the transposition `(0 1)`. -/
theorem rootDuality_fin_two {n : ℕ} (q α₀ α₁ : K) (hprod : α₀ * α₁ = q ^ n) :
    ∀ i, (![α₀, α₁] : Fin 2 → K) i * ![α₀, α₁] (Equiv.swap 0 1 i) = q ^ n := by
  intro i
  fin_cases i
  · simpa [Equiv.swap_apply_left] using hprod
  · simpa [Equiv.swap_apply_right, mul_comm] using hprod

/-- **Calabi–Yau threefold specialization (weight four), with the sign pinned to `+1`.**
For a rigid Calabi–Yau threefold over `𝔽_q` the middle factor is the weight-`3` quadratic
`P(T) = 1 − a T + q³T²` (reciprocal roots with `α₀α₁ = q³`, `α₀+α₁ = a`).  Instantiating
the general theorem at `n = 3`, `d = 2`, `m = 3` and computing the Frobenius determinant
`∏ α_i = q³` gives the *unsigned* functional equation `q³ T² P(1/(q³T)) = P(T)`. -/
theorem cy_threefold_middle_reciprocal (q T α₀ α₁ : K) (hq : q ≠ 0) (hT : T ≠ 0)
    (hprod : α₀ * α₁ = q ^ 3) :
    q ^ 3 * T ^ 2 * middleFactor ![α₀, α₁] (1 / (q ^ 3 * T))
      = middleFactor ![α₀, α₁] T := by
  have hdual := rootDuality_fin_two (n := 3) q α₀ α₁ hprod
  have hprod2 : ∏ i, (![α₀, α₁] : Fin 2 → K) i = q ^ 3 := by
    rw [Fin.prod_univ_two]; simpa using hprod
  have hshift := prod_shift_eq_of_root_duality (R := K) (q ^ 3) T ![α₀, α₁]
    (Equiv.swap 0 1) hdual
  rw [hprod2] at hshift
  have hqne : ((q : K) ^ 3) ^ 2 ≠ 0 := pow_ne_zero _ (pow_ne_zero _ hq)
  rw [mul_assoc, middleFactor_reflect q T hq hT ![α₀, α₁], hshift]
  field_simp
  ring

/-- **Elliptic curve (`n = 1`) specialization.**  The catalog's Euler-factor functional
equation `Novelty.ArithMirror.eulerFactor_funeq` is the `(n, d) = (1, 2)` corner of the
general theorem: with `α₀α₁ = q` one gets `q T² P(1/(qT)) = P(T)`. -/
theorem elliptic_curve_middle_reciprocal (q T α₀ α₁ : K) (hq : q ≠ 0) (hT : T ≠ 0)
    (hprod : α₀ * α₁ = q ^ 1) :
    q * T ^ 2 * middleFactor ![α₀, α₁] (1 / (q ^ 1 * T)) = middleFactor ![α₀, α₁] T := by
  have hdual := rootDuality_fin_two (n := 1) q α₀ α₁ hprod
  have hprod2 : ∏ i, (![α₀, α₁] : Fin 2 → K) i = q ^ 1 := by
    rw [Fin.prod_univ_two]; simpa using hprod
  have hshift := prod_shift_eq_of_root_duality (R := K) (q ^ 1) T ![α₀, α₁]
    (Equiv.swap 0 1) hdual
  rw [hprod2] at hshift
  have hqne : ((q : K) ^ 1) ^ 2 ≠ 0 := pow_ne_zero _ (pow_ne_zero _ hq)
  rw [show (q : K) * T ^ 2 = q ^ 1 * T ^ 2 by ring, mul_assoc,
    middleFactor_reflect q T hq hT ![α₀, α₁], hshift]
  field_simp
  ring

/-- Consistency with the catalog: the quadratic `1 − a T + p T²` of
`Novelty.ArithMirror.eulerFactor` is exactly the middle factor of a pair of reciprocal
roots with `α₀ + α₁ = a`, `α₀ α₁ = p`. -/
theorem eulerFactor_eq_middleFactor (a p T α₀ α₁ : ℝ) (hsum : α₀ + α₁ = a)
    (hprod : α₀ * α₁ = p) :
    Novelty.ArithMirror.eulerFactor a p T = middleFactor ![α₀, α₁] T := by
  rw [middleFactor_fin_two, hsum, hprod]
  unfold Novelty.ArithMirror.eulerFactor
  ring

end Field

end Novelty.MirrorBridge