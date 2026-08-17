import Cryptography.BerggrenSpectral.SpectrumAndTrace

/-!
# Cross-Domain Bridge: Lorentz Structure of the Tree and Periodicity of Triples mod `p`

Third research cycle.  The resonance theorems of the previous files are statements about the
Berggren matrices as abstract elements of `GL₃`.  Here we connect them back to the object the
Berggren tree is *about* — primitive Pythagorean triples — through the Lorentz form
`Q(a,b,c) = a² + b² - c²`.

## Main results

* `berg_isometry_one/two/three` : over **any** commutative ring, `Mᵢᵀ Q Mᵢ = Q`, i.e. the three
  Berggren generators lie in the orthogonal group `O(2,1)` of the Pythagorean form.  This is
  the structural reason the tree maps triples to triples.
* `berg_preserves_pythagorean` : consequently `Mᵢ` maps Pythagorean triples to Pythagorean
  triples, reproving (from the group-theoretic reason rather than by expansion) the catalog
  fact underlying `Shared/BerggrenTrees`.
* `berg_form_preserved_mod` : the same identity holds after reduction mod `N`, so the
  Berggren dynamics on `(ZMod N)³` preserves the conic `a² + b² = c²`.
* `berg_tree_period_mod_p` : for every odd prime `p` and **every** vector `v`, the hyperbolic
  branch is periodic mod `p` with period dividing `p² - 1`; in particular the root triple
  `(3,4,5)` returns to itself.  The "resonant energy frequency" is thus visible directly on
  the tree of triples, not only on the matrices.
* `berg_semiprime_period` : for `N = p q` the period divides `lcm (p² - 1, q² - 1)` — a
  Carmichael-type bound whose *failure to be attained simultaneously at both primes* is
  exactly what `Factorization.lean` exploits.
-/

namespace BerggrenSpectral

open Matrix

variable (R : Type*) [CommRing R]

/-- The Lorentz/Pythagorean form `diag (1, 1, -1)`. -/
def pythQ : Matrix (Fin 3) (Fin 3) R := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

variable {R}

/-- Generic versions of the generators over an arbitrary commutative ring. -/
def M1R : Matrix (Fin 3) (Fin 3) R := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Generic version of the third generator over an arbitrary commutative ring. -/
def M3R : Matrix (Fin 3) (Fin 3) R := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

theorem berg_isometry_one : (M1R : Matrix (Fin 3) (Fin 3) R)ᵀ * pythQ R * M1R = pythQ R := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [M1R, pythQ, Matrix.mul_apply, Fin.sum_univ_succ, Matrix.transpose_apply] <;> ring

theorem berg_isometry_two : (M2R R)ᵀ * pythQ R * M2R R = pythQ R := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [M2R, pythQ, Matrix.mul_apply, Fin.sum_univ_succ, Matrix.transpose_apply] <;> ring

theorem berg_isometry_three : (M3R : Matrix (Fin 3) (Fin 3) R)ᵀ * pythQ R * M3R = pythQ R := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [M3R, pythQ, Matrix.mul_apply, Fin.sum_univ_succ, Matrix.transpose_apply] <;> ring

/-! ## Preservation of the Pythagorean conic -/

/-- The quadratic form attached to a triple. -/
def pythForm (v : Fin 3 → R) : R := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- `M₂` preserves the Pythagorean form, over any commutative ring. -/
theorem berg_two_form_invariant (v : Fin 3 → R) : pythForm (M2R R *ᵥ v) = pythForm v := by
  simp [pythForm, M2R, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- `M₁` preserves the Pythagorean form. -/
theorem berg_one_form_invariant (v : Fin 3 → R) :
    pythForm ((M1R : Matrix (Fin 3) (Fin 3) R) *ᵥ v) = pythForm v := by
  simp [pythForm, M1R, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- `M₃` preserves the Pythagorean form. -/
theorem berg_three_form_invariant (v : Fin 3 → R) :
    pythForm ((M3R : Matrix (Fin 3) (Fin 3) R) *ᵥ v) = pythForm v := by
  simp [pythForm, M3R, Matrix.mulVec, dotProduct, Fin.sum_univ_succ]
  ring

/-- **Triples go to triples.**  If `a² + b² = c²` then the image under `M₂` is again a
Pythagorean triple; the same holds for `M₁` and `M₃`. -/
theorem berg_preserves_pythagorean (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    ((M2R ℤ) *ᵥ ![a, b, c]) 0 ^ 2 + ((M2R ℤ) *ᵥ ![a, b, c]) 1 ^ 2
      = ((M2R ℤ) *ᵥ ![a, b, c]) 2 ^ 2 := by
  have hinv := berg_two_form_invariant (R := ℤ) ![a, b, c]
  simp only [pythForm] at hinv
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one] at hinv
  have h2 : ((M2R ℤ) *ᵥ ![a, b, c]) 0 ^ 2 + ((M2R ℤ) *ᵥ ![a, b, c]) 1 ^ 2
      - ((M2R ℤ) *ᵥ ![a, b, c]) 2 ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
    simpa using hinv
  linarith [h2, h]

/-- Reduction mod `N` also preserves the conic. -/
theorem berg_form_preserved_mod (N : ℕ) (v : Fin 3 → ZMod N) :
    pythForm (M2R (ZMod N) *ᵥ v) = pythForm v := berg_two_form_invariant v

/-! ## Periodicity of the tree dynamics mod `p` -/

variable (p : ℕ) [Fact p.Prime]

/-- **The Berggren orbit is periodic mod `p` with period dividing `p² - 1`.** -/
theorem berg_tree_period_mod_p (hp : p ≠ 2) (v : Fin 3 → ZMod p) :
    (M2R (ZMod p)) ^ (p ^ 2 - 1) *ᵥ v = v := by
  have h : (M2R (ZMod p)) ^ (p ^ 2 - 1) = 1 := by
    rw [← redMat_M₂]; exact berg_two_resonance p hp
  rw [h, Matrix.one_mulVec]

/-- The root Pythagorean triple `(3,4,5)` returns to itself after the resonant number of
Berggren steps mod `p`. -/
theorem berg_root_triple_period (hp : p ≠ 2) :
    (M2R (ZMod p)) ^ (p ^ 2 - 1) *ᵥ ![3, 4, 5] = ![3, 4, 5] :=
  berg_tree_period_mod_p p hp _

/-- **Carmichael-type bound for a semiprime modulus.**  Modulo `N = p q` the hyperbolic
Berggren branch is periodic with period dividing `lcm (p² - 1, q² - 1)`. -/
theorem berg_semiprime_period (q : ℕ) [Fact q.Prime] (hp : p ≠ 2) (hq : q ≠ 2)
    (hcop : Nat.Coprime p q) :
    (redMat (p * q) M₂) ^ (Nat.lcm (p ^ 2 - 1) (q ^ 2 - 1)) = 1 := by
  refine (berg_resonance_crt p q _ hcop).mpr ⟨?_, ?_⟩
  · obtain ⟨t, ht⟩ := Nat.dvd_lcm_left (p ^ 2 - 1) (q ^ 2 - 1)
    rw [ht, pow_mul, berg_two_resonance p hp, one_pow]
  · obtain ⟨t, ht⟩ := Nat.dvd_lcm_right (p ^ 2 - 1) (q ^ 2 - 1)
    rw [ht, pow_mul, berg_two_resonance q hq, one_pow]

end BerggrenSpectral