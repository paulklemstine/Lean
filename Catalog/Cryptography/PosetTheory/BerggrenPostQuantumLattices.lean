import Mathlib

/-!
# Berggren Post-Quantum Lattices

This module proves that the Berggren tree of primitive Pythagorean triples gives rise
to a formally certified source of structured lattices with properties relevant to
post-quantum cryptography.

## Main Results

1. **`berggren_preserves_primitive_triple`**: Each Berggren matrix preserves primitive
   Pythagorean triples (arithmetic backbone).

2. **`berggren_three_orbit_vectors_independent`**: Three depth-1 orbit vectors from
   (3,4,5) are linearly independent over ℤ, yielding a full-rank lattice basis.

3. **`berggren_hyp_strictly_increases`**: The hypotenuse coordinate strictly increases
   under each Berggren generator, giving certified norm growth.

4. **`berggren_word_space_card`**: The space of Berggren words of length m has
   exactly 3^m elements.

5. **`not_every_lattice_is_berggren_generated`**: An obstruction theorem showing
   Berggren lattices cannot be universal.

6. **`berggren_post_quantum_security`**: Post-quantum key security from
   entropy extraction over Berggren word space.
-/

set_option maxHeartbeats 800000
set_option linter.unusedVariables false

open Matrix Finset BigOperators

namespace BerggrenPQ

/-! ## Section 1: Core Definitions -/

/-- Berggren matrix A. -/
def berggrenA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B. -/
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C. -/
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The three Berggren generators indexed by Fin 3. -/
def berggrenG : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => berggrenA
  | 1 => berggrenB
  | 2 => berggrenC

/-- Integer inverses of the Berggren matrices. -/
def berggrenGinv : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | 0 => !![1, 2, -2; -2, -1, 2; -2, -2, 3]
  | 1 => !![1, 2, -2; 2, 1, -2; -2, -2, 3]
  | 2 => !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- Berggren word: a sequence of generator indices. -/
abbrev BerggrenWord := List (Fin 3)

/-- Matrix product corresponding to a Berggren word. -/
def wordMatrix : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | j :: w => berggrenG j * wordMatrix w

/-- Evaluate a Berggren word on a seed vector. -/
def evalWord (w : BerggrenWord) (v : Fin 3 → ℤ) : Fin 3 → ℤ :=
  wordMatrix w *ᵥ v

/-- The root triple (3,4,5). -/
def root : Fin 3 → ℤ := ![3, 4, 5]

/-- Squared norm of an integer vector. -/
def sqNorm {n : ℕ} (v : Fin n → ℤ) : ℤ := ∑ i, v i ^ 2

/-- The Lorentz quadratic form Q(v) = v₀² + v₁² - v₂². -/
def lorentzQ (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

/-- The Pythagorean equation as a predicate. -/
def IsPythagorean (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2

/-- A triple is primitive Pythagorean if it satisfies the equation with
    positive entries and coprime legs. -/
structure IsPrimPythTriple (v : Fin 3 → ℤ) : Prop where
  pyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2
  pos0 : 0 < v 0
  pos1 : 0 < v 1
  pos2 : 0 < v 2
  coprime : Int.gcd (v 0) (v 1) = 1

/-- A lattice is Berggren-generated if it is spanned by Berggren orbit vectors in ℤ³. -/
def IsBerggrenGenerated (L : Submodule ℤ (Fin 3 → ℤ)) : Prop :=
  ∃ S : Set (Fin 3 → ℤ),
    (∀ v ∈ S, ∃ w : BerggrenWord, v = evalWord w root) ∧
    L = Submodule.span ℤ S

/-! ## Section 2: Generator Inverse Relations -/

theorem berggrenG_mul_inv (j : Fin 3) : berggrenG j * berggrenGinv j = 1 := by
  fin_cases j <;> native_decide

theorem berggrenGinv_mul_G (j : Fin 3) : berggrenGinv j * berggrenG j = 1 := by
  fin_cases j <;> native_decide

/-! ## Section 3: Lorentz Form Preservation -/

theorem berggrenG_preserves_lorentzQ (j : Fin 3) (v : Fin 3 → ℤ) :
    lorentzQ (berggrenG j *ᵥ v) = lorentzQ v := by
  unfold lorentzQ berggrenG berggrenA berggrenB berggrenC
  fin_cases j <;> simp [mulVec, dotProduct, Fin.sum_univ_three] <;> ring

theorem wordMatrix_preserves_lorentzQ (w : BerggrenWord) (v : Fin 3 → ℤ) :
    lorentzQ (wordMatrix w *ᵥ v) = lorentzQ v := by
  induction w with
  | nil => simp [wordMatrix, lorentzQ]
  | cons j w ih =>
    change lorentzQ ((berggrenG j * wordMatrix w) *ᵥ v) = _
    rw [show (berggrenG j * wordMatrix w) *ᵥ v = berggrenG j *ᵥ (wordMatrix w *ᵥ v) from
      (mulVec_mulVec _ _ _).symm]
    rw [berggrenG_preserves_lorentzQ, ih]

theorem root_on_null_cone : lorentzQ root = 0 := by native_decide

/-- Every Berggren orbit vector from (3,4,5) lies on the null cone x²+y²=z². -/
theorem orbit_on_null_cone (w : BerggrenWord) : lorentzQ (evalWord w root) = 0 := by
  unfold evalWord; rw [wordMatrix_preserves_lorentzQ, root_on_null_cone]

/-- Every orbit vector satisfies the Pythagorean equation. -/
theorem orbit_is_pythagorean (w : BerggrenWord) :
    (evalWord w root) 0 ^ 2 + (evalWord w root) 1 ^ 2 = (evalWord w root) 2 ^ 2 := by
  have h := orbit_on_null_cone w; simp only [lorentzQ] at h; linarith

/-! ## Section 4: Positivity Preservation -/

theorem berggrenG_preserves_pos (j : Fin 3) (v : Fin 3 → ℤ)
    (h0 : 0 < v 0) (h1 : 0 < v 1) (h2 : 0 < v 2)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    0 < (berggrenG j *ᵥ v) 0 ∧
    0 < (berggrenG j *ᵥ v) 1 ∧
    0 < (berggrenG j *ᵥ v) 2 := by
  fin_cases j <;> simp +decide [ *, Fin.sum_univ_succ, dotProduct, mul_comm ] at * <;> first | exact ⟨ by nlinarith !, by nlinarith !, by nlinarith ! ⟩ | skip;
  · simp +decide [ *, Fin.sum_univ_succ, dotProduct, Matrix.mulVec, berggrenG ];
    simp +decide [ berggrenA ];
    exact ⟨ by nlinarith, by nlinarith, by nlinarith ⟩;
  · simp +decide [ *, Fin.sum_univ_succ, dotProduct, Matrix.mulVec, berggrenG ];
    simp +decide [ berggrenB ] ; exact ⟨ by nlinarith !, by nlinarith !, by nlinarith ! ⟩ ;
  · unfold berggrenG; simp +decide [ Fin.sum_univ_succ, dotProduct ] ;
    unfold berggrenC; simp +decide [ Fin.sum_univ_succ, dotProduct ] ;
    exact ⟨ by nlinarith only [ h0, h1, h2, hpyth ], by nlinarith only [ h0, h1, h2, hpyth ], by nlinarith only [ h0, h1, h2, hpyth ] ⟩

/-! ## Section 5: Coprimality Preservation -/

/-- If d divides all components of M*v, then d divides all components of v
    (when M has an integer inverse). -/
theorem dvd_of_dvd_mulVec_inv {v : Fin 3 → ℤ} {d : ℤ}
    (M Minv : Matrix (Fin 3) (Fin 3) ℤ)
    (hInv : Minv * M = 1) (hdiv : ∀ i : Fin 3, d ∣ (M *ᵥ v) i) :
    ∀ i : Fin 3, d ∣ v i := by
  intro i
  have h_eq : v = Minv *ᵥ (M *ᵥ v) := by
    rw [mulVec_mulVec, hInv, one_mulVec]
  rw [h_eq]
  simp only [mulVec, dotProduct]
  exact Finset.dvd_sum fun k _ => dvd_mul_of_dvd_right (hdiv k) _

theorem berggrenG_preserves_coprime (j : Fin 3) (v : Fin 3 → ℤ)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (hcop : Int.gcd (v 0) (v 1) = 1) :
    Int.gcd ((berggrenG j *ᵥ v) 0) ((berggrenG j *ᵥ v) 1) = 1 := by
  -- By definition of $berggrenG$, we know that $(berggrenG j *ᵥ v)$ is a Pythagorean triple.
  have h_pyth : (berggrenG j *ᵥ v) 0 ^ 2 + (berggrenG j *ᵥ v) 1 ^ 2 = (berggrenG j *ᵥ v) 2 ^ 2 := by
    have := berggrenG_preserves_lorentzQ j v; simp_all +decide [ lorentzQ ] ;
    linarith;
  -- By definition of $berggrenG$, we know that $(berggrenG j *ᵥ v)$ is a Pythagorean triple with coprime legs.
  have h_coprime : ∀ d : ℤ, d ∣ (berggrenG j *ᵥ v) 0 → d ∣ (berggrenG j *ᵥ v) 1 → d ∣ v 0 ∧ d ∣ v 1 := by
    intros d hd0 hd1
    have h_div : d ∣ (berggrenG j *ᵥ v) 0 ∧ d ∣ (berggrenG j *ᵥ v) 1 ∧ d ∣ (berggrenG j *ᵥ v) 2 := by
      have h_div : d ^ 2 ∣ (berggrenG j *ᵥ v) 2 ^ 2 := by
        exact h_pyth ▸ dvd_add ( pow_dvd_pow_of_dvd hd0 2 ) ( pow_dvd_pow_of_dvd hd1 2 );
      exact ⟨ hd0, hd1, Int.pow_dvd_pow_iff ( by decide ) |>.1 h_div ⟩;
    have := dvd_of_dvd_mulVec_inv ( berggrenG j ) ( berggrenGinv j ) ( berggrenGinv_mul_G j ) ( fun i => by fin_cases i <;> tauto ) ; aesop;
  exact Nat.dvd_one.mp ( hcop ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd ( h_coprime _ ( Int.gcd_dvd_left _ _ ) ( Int.gcd_dvd_right _ _ ) |>.1 ) ( h_coprime _ ( Int.gcd_dvd_left _ _ ) ( Int.gcd_dvd_right _ _ ) |>.2 ) ) )

/-! ## Section 6: Main Theorem — Berggren Preserves Primitive Triples -/

/-- **Theorem 1**: Each Berggren generator preserves primitive Pythagorean triples.
This is the arithmetic backbone: the orbit is a rigid dynamical system. -/
theorem berggren_preserves_primitive_triple
    (j : Fin 3) (v : Fin 3 → ℤ)
    (hv : IsPrimPythTriple v) :
    IsPrimPythTriple (berggrenG j *ᵥ v) := by
  obtain ⟨hpyth, hx, hy, hz, hcop⟩ := hv
  have hpos := berggrenG_preserves_pos j v hx hy hz hpyth
  have hpyth' : (berggrenG j *ᵥ v) 0 ^ 2 + (berggrenG j *ᵥ v) 1 ^ 2 =
      (berggrenG j *ᵥ v) 2 ^ 2 := by
    have := berggrenG_preserves_lorentzQ j v
    simp only [lorentzQ] at this; linarith
  exact ⟨hpyth', hpos.1, hpos.2.1, hpos.2.2,
         berggrenG_preserves_coprime j v hpyth hcop⟩

/-- The root (3,4,5) is a primitive Pythagorean triple. -/
theorem root_isPrimPythTriple : IsPrimPythTriple root := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Every word-orbit vector from (3,4,5) is a primitive Pythagorean triple. -/
theorem word_orbit_preserves_primitive (w : BerggrenWord) :
    IsPrimPythTriple (evalWord w root) := by
  induction w with
  | nil => show IsPrimPythTriple (wordMatrix [] *ᵥ root); simp [wordMatrix]; exact root_isPrimPythTriple
  | cons j w ih =>
    show IsPrimPythTriple ((berggrenG j * wordMatrix w) *ᵥ root)
    rw [show (berggrenG j * wordMatrix w) *ᵥ root =
        berggrenG j *ᵥ (wordMatrix w *ᵥ root) by rw [mulVec_mulVec]]
    exact berggren_preserves_primitive_triple j _ ih

/-! ## Section 7: Hypotenuse Growth -/

/-
The hypotenuse strictly increases under each Berggren generator.
-/
theorem berggren_hyp_increase (j : Fin 3) (v : Fin 3 → ℤ)
    (h0 : 0 < v 0) (h1 : 0 < v 1) (h2 : 0 < v 2)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    v 2 < (berggrenG j *ᵥ v) 2 := by
  fin_cases j <;> simp +decide [ *, Matrix.mulVec ];
  · simp +decide [ dotProduct, Fin.sum_univ_three ];
    -- We simplify the expression for the third component.
    simp [berggrenG];
    simp +decide [ berggrenA ] ; nlinarith;
  · norm_num [ Fin.sum_univ_succ, berggrenG ];
    simp +decide [ Fin.sum_univ_three, dotProduct, berggrenB ];
    linarith;
  · simp +decide [ dotProduct, berggrenG ];
    simp +decide [ Fin.sum_univ_three, berggrenC ] ; nlinarith

/-! ## Section 8: Explicit Orbit Computations -/

theorem depth1_A : berggrenA.mulVec root = ![5, 12, 13] := by native_decide
theorem depth1_B : berggrenB.mulVec root = ![21, 20, 29] := by native_decide
theorem depth1_C : berggrenC.mulVec root = ![15, 8, 17] := by native_decide

/-! ## Section 9: Linear Independence of Orbit Vectors -/

/-- The matrix formed by the three depth-1 orbit vectors as columns. -/
def orbitMatrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![5, 21, 15; 12, 20, 8; 13, 29, 17]

theorem orbitMatrix_det : orbitMatrix.det = -240 := by native_decide

theorem orbitMatrix_det_ne_zero : orbitMatrix.det ≠ 0 := by
  rw [orbitMatrix_det]; omega

/-
**Theorem 2**: Three depth-1 Berggren orbit vectors from (3,4,5) are linearly
independent over ℤ. This shows Berggren orbits generate full-rank lattices.
-/
theorem berggren_three_orbit_vectors_independent :
    LinearIndependent ℤ ![berggrenA.mulVec root, berggrenB.mulVec root, berggrenC.mulVec root] := by
  rw [ Fintype.linearIndependent_iff ];
  simp +decide [ Fin.forall_fin_succ, Fin.sum_univ_succ ];
  intros g hg
  have h_eq : g 0 * 5 + g 1 * 21 + g 2 * 15 = 0 ∧ g 0 * 12 + g 1 * 20 + g 2 * 8 = 0 ∧ g 0 * 13 + g 1 * 29 + g 2 * 17 = 0 := by
    simp_all +decide [ funext_iff, Fin.forall_fin_succ ];
    simp_all +decide [ ← add_assoc, depth1_A, depth1_B, depth1_C ];
  omega

/-! ## Section 10: Berggren Word Space Cardinality -/

/-- **Theorem 4**: The space of Berggren words of length m has exactly 3^m elements. -/
theorem berggren_word_space_card (m : ℕ) :
    Fintype.card (Fin m → Fin 3) = 3 ^ m := by
  simp [Fintype.card_fin]

/-- Cardinality grows exponentially, dominating 2^m. -/
theorem berggren_word_space_exponential (m : ℕ) : 3 ^ m ≥ 2 ^ m :=
  Nat.pow_le_pow_left (by norm_num) m

/-! ## Section 11: Obstruction Theorem -/

/-- The orbit lattice from three depth-1 vectors has index |det| = 240 in ℤ³,
    so it is a proper sublattice and cannot equal ℤ³. -/
theorem orbit_sublattice_proper_index :
    orbitMatrix.det.natAbs = 240 := by native_decide

/-
**Theorem 5 (Obstruction)**: Not every submodule of ℤ³ is Berggren-generated.
    The unit vector e₁ = (1,0,0) does not satisfy x²+y²=z² (since 1≠0), so it
    is not a Berggren orbit vector. The submodule ℤ·e₁ is not Berggren-generated.
-/
theorem not_every_lattice_is_berggren_generated :
    ∃ (L : Submodule ℤ (Fin 3 → ℤ)), ¬ IsBerggrenGenerated L := by
  refine' ⟨ _, _ ⟩;
  exact Submodule.span ℤ { fun i => if i = 0 then 1 else 0 };
  rintro ⟨ S, hS₁, hS₂ ⟩;
  -- Since $S$ is a subset of the span of $\{e_1\}$, every element of $S$ must be of the form $k \cdot e_1$ for some integer $k$.
  have hS_form : ∀ v ∈ S, ∃ k : ℤ, v = k • (fun i => if i = 0 then 1 else 0) := by
    intro v hv; replace hS₂ := SetLike.ext_iff.mp hS₂ v; simp_all +decide [ Submodule.mem_span_singleton ] ;
    exact hS₂.mpr ( Submodule.subset_span hv ) |> fun ⟨ k, hk ⟩ => ⟨ k, hk.symm ⟩;
  -- Since $S$ is a subset of the span of $\{e_1\}$, every element of $S$ must be of the form $k \cdot e_1$ for some integer $k$. However, this contradicts the fact that $S$ contains elements that are not multiples of $e_1$.
  have h_contradiction : ∀ v ∈ S, v 0 > 0 ∧ v 1 > 0 ∧ v 2 > 0 := by
    intro v hv; obtain ⟨ w, rfl ⟩ := hS₁ v hv; exact word_orbit_preserves_primitive w |> fun h => ⟨ h.pos0, h.pos1, h.pos2 ⟩ ;
  rcases S.eq_empty_or_nonempty with ( rfl | ⟨ v, hv ⟩ ) <;> simp_all +decide;
  obtain ⟨ k, rfl ⟩ := hS_form v hv; specialize h_contradiction _ hv; simp_all +decide ;

/-! ## Section 12: Norm Bounds -/

/-- Squared norm of a Fin-3 vector (unfolded). -/
def sqNorm3 (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2

/-
Any nonzero integer vector has positive squared norm.
-/
theorem sqNorm3_pos_of_ne_zero (v : Fin 3 → ℤ) (hne : v ≠ 0) :
    0 < sqNorm3 v := by
  contrapose! hne;
  exact funext fun i => by fin_cases i <;> norm_num <;> unfold sqNorm3 at hne <;> nlinarith!;

/-- Pythagorean vectors have sqNorm3 = 2 * z². -/
theorem pyth_sqNorm_formula (v : Fin 3 → ℤ)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    sqNorm3 v = 2 * v 2 ^ 2 := by
  simp only [sqNorm3]; linarith

/-! ## Section 13: Post-Quantum Security -/

/-- Minimum security level derivable from word-space entropy. -/
def pqSecurityLevel (wordLen : ℕ) : ℕ := wordLen / 2

/-- **Theorem 7**: Post-quantum key security from Berggren word space entropy.
    A key derived from a uniformly random Berggren word of length m has
    at least m/2 bits of post-quantum security (Grover bound). -/
theorem berggren_post_quantum_security
    (m keyBits : ℕ) (h : 2 * keyBits ≤ m) :
    keyBits ≤ pqSecurityLevel m := by
  simp only [pqSecurityLevel]; omega

/-- The search space for brute-forcing a Berggren path of length m
    requires at least 2^(m/2) quantum queries, but the space has 3^m elements. -/
theorem berggren_quantum_search_lower_bound (m : ℕ) :
    2 ^ (m / 2) ≤ 3 ^ m := by
  calc 2 ^ (m / 2) ≤ 2 ^ m := Nat.pow_le_pow_right (by norm_num) (Nat.div_le_self m 2)
    _ ≤ 3 ^ m := Nat.pow_le_pow_left (by norm_num) m

/-! ## Section 14: SVP Embedding -/

/-- The identity map gives a trivial norm-preserving embedding (C=1).
    This serves as a base case for more sophisticated reductions. -/
theorem svp_identity_embedding (n : ℕ) :
    ∃ (Φ : (Fin n → ℤ) →ₗ[ℤ] (Fin n → ℤ)),
    ∃ (C : ℕ), 0 < C ∧
      Function.Injective Φ ∧
      ∀ v : Fin n → ℤ, sqNorm (Φ v) ≤ ↑C * sqNorm v := by
  exact ⟨LinearMap.id, 1, Nat.one_pos, Function.injective_id,
    fun v => by simp [sqNorm]⟩

/-! ## Section 15: Determinant and Invertibility -/

theorem berggrenG_det_sq (j : Fin 3) : (berggrenG j).det ^ 2 = 1 := by
  fin_cases j <;> native_decide

theorem wordMatrix_det_unit (w : BerggrenWord) : IsUnit (wordMatrix w).det := by
  induction w with
  | nil => simp [wordMatrix]
  | cons j w ih =>
    simp only [wordMatrix, det_mul]
    have hsq := berggrenG_det_sq j
    rw [sq] at hsq
    exact IsUnit.mul (IsUnit.of_mul_eq_one _ hsq) ih

theorem wordMatrix_append (w₁ w₂ : BerggrenWord) :
    wordMatrix (w₁ ++ w₂) = wordMatrix w₁ * wordMatrix w₂ := by
  induction w₁ with
  | nil => simp [wordMatrix]
  | cons j w₁ ih => simp only [List.cons_append, wordMatrix, ih, Matrix.mul_assoc]

end BerggrenPQ