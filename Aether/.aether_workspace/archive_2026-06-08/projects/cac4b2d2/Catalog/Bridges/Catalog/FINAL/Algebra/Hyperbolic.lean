import Mathlib

/-! # CatalogBuild.Algebra.Factoring.Hyperbolic
Unified file merging Hyperbolic-related theorems.
-
-/

/- Original: HyperbolicFactoring.lean -/



/-- The divisor hyperbola: points (d, n/d) for d | n.
The divisors come in pairs (d, n/d) which are symmetric. -/
theorem hyperbola_symmetry {n d : ℕ} (hd : d ∣ n) :
    (n / d) ∣ n :=
  Nat.div_dvd_of_dvd hd

/-- d² ≤ n implies d ≤ n for any divisor d (the "small" divisor). -/
theorem small_divisor_bound {n d : ℕ} (hd : d ∣ n) (hn : 0 < n) :
    d ≤ n :=
  Nat.le_of_dvd hn hd

/-- The determinant is preserved under multiplication. -/
theorem SL2Z.mul_det (M N : SL2Z) :
    (SL2Z.mul M N).a * (SL2Z.mul M N).d - (SL2Z.mul M N).b * (SL2Z.mul M N).c = 1 :=
  (SL2Z.mul M N).det_eq

/-- Consecutive convergents of a continued fraction satisfy |pq' - p'q| = 1,
which implies they are coprime. -/
theorem convergent_coprime_of_det_one {p q : ℤ} (hq : 0 < q)
    (h : ∃ p' q' : ℤ, p * q' - p' * q = 1) :
    IsCoprime p q := by
  obtain ⟨p', q', hdet⟩ := h
  exact ⟨q', -p', by linarith⟩

/-- The mediant of two fractions a/b and c/d is (a+c)/(b+d).
If they are Farey neighbors, b+d > 0. -/
theorem farey_mediant_denominator {b d : ℕ} (hb : 0 < b) (hd : 0 < d) :
    0 < b + d := by omega

/-- The "hyperbolic" relationship between divisor pairs: if d₁ ≤ d₂ are both
divisors of n, then n/d₂ ≤ n/d₁ (the companion divisors are reversed). -/
theorem divisor_companion_reversed {d₁ d₂ n : ℕ}
    (hd1 : d₁ ∣ n) (hd2 : d₂ ∣ n)
    (hd1_pos : 0 < d₁) (hle : d₁ ≤ d₂) :
    n / d₂ ≤ n / d₁ :=
  Nat.div_le_div_left hle hd1_pos

/-- If a is a nonzero quadratic residue mod p, then its square root is also nonzero. -/
theorem quadratic_residue_nonzero {p : ℕ} (hp : Nat.Prime p)
    {a : ZMod p} (ha : a ≠ 0) (hsq : ∃ x : ZMod p, x * x = a) :
    ∃ x : ZMod p, x * x = a ∧ x ≠ 0 := by
  obtain ⟨x, hx⟩ := hsq
  exact ⟨x, hx, fun hx0 => ha (by rw [← hx, hx0, mul_zero])⟩

/-- The CRT projection: QR mod pq implies QR mod p. -/
theorem crt_quadratic_residue {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    {a : ZMod (p * q)} :
    (∃ x : ZMod (p * q), x * x = a) →
    (∃ xp : ZMod p, xp * xp = ZMod.castHom (dvd_mul_right p q) (ZMod p) a) := by
  intro ⟨x, hx⟩
  exact ⟨ZMod.castHom (dvd_mul_right p q) (ZMod p) x, by rw [← map_mul, hx]⟩

/- Original: HyperbolicShortcuts.lean -/



/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 27] -/
theorem B₁_preserves_Q : B₁ᵀ * Q * B₁ = Q := by native_decide

/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicShortcuts
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 27] -/
theorem B₂_preserves_Q : B₂ᵀ * Q * B₂ = Q := by native_decide

theorem B₃_preserves_Q : B₃ᵀ * Q * B₃ = Q := by native_decide

def dirMatrix : BDir → Matrix (Fin 3) (Fin 3) ℤ
  | .L => B₁ | .M => B₂ | .R => B₃

def pathMatrix : BPath → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | d :: ds => dirMatrix d * pathMatrix ds

def root : Fin 3 → ℤ := ![3, 4, 5]

theorem dir_preserves_Q (d : BDir) : (dirMatrix d)ᵀ * Q * (dirMatrix d) = Q := by
  cases d <;> simp only [dirMatrix] <;> native_decide

/-- Each direction matrix has |det| = 1 (they are in O(2,1)(ℤ)). -/
theorem dir_det_abs (d : BDir) : |Matrix.det (dirMatrix d)| = 1 := by
  cases d <;> simp only [dirMatrix] <;> native_decide

theorem pathMatrix_preserves_Q (p : BPath) :
    (pathMatrix p)ᵀ * Q * (pathMatrix p) = Q := by
  induction' p with d p ih;
  · decide +kernel;
  · rw [ show pathMatrix ( d :: p ) = dirMatrix d * pathMatrix p from rfl, Matrix.mul_assoc ];
    simp +decide only [transpose_mul, Matrix.mul_assoc];
    simp +decide [ ← mul_assoc, ← Matrix.mul_assoc ( pathMatrix p |> Matrix.transpose ), ih, dir_preserves_Q ]

/-- The absolute determinant of any path matrix is 1. -/
theorem shortcut_det_abs (p : BPath) :
    |Matrix.det (pathMatrix p)| = 1 := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih =>
    simp only [pathMatrix, Matrix.det_mul, abs_mul, dir_det_abs, ih, one_mul]

theorem B₁_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 = (2*a - 2*b + 3*c)^2 := by nlinarith

theorem B₂_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 = (2*a + 2*b + 3*c)^2 := by nlinarith

theorem B₃_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by nlinarith

theorem dir_preserves_pyth (d : BDir) (v : Fin 3 → ℤ)
    (hv : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    let w := dirMatrix d *ᵥ v
    w 0 ^ 2 + w 1 ^ 2 = w 2 ^ 2 := by
  rcases d with ⟨ _ | _ | _ ⟩ <;> norm_num [ Fin.sum_univ_succ, Matrix.mulVec ] at *;
  · simp +decide [ dirMatrix, dotProduct ];
    simp +decide [ Fin.sum_univ_three, B₁ ];
    linarith;
  · norm_num [ Fin.sum_univ_succ, dotProduct, dirMatrix ] ; ring;
    simp +decide [ B₂ ] ; nlinarith;
  · simp +decide [ dirMatrix, dotProduct ];
    simp +decide [ B₃, Fin.sum_univ_three ] ; linarith

/-- Every triple in the Berggren tree satisfies a² + b² = c². -/
theorem tripleAt_pythagorean (p : BPath) :
    (tripleAt p) 0 ^ 2 + (tripleAt p) 1 ^ 2 = (tripleAt p) 2 ^ 2 := by
  induction p with
  | nil => simp only [tripleAt, pathMatrix]; native_decide
  | cons d ds ih =>
    simp only [tripleAt, pathMatrix] at *
    rw [← mulVec_mulVec]
    exact dir_preserves_pyth d _ ih

/-- (c - a)(c + a) = b² when a² + b² = c². -/
theorem factoring_identity' (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - a) * (c + a) = b ^ 2 := by ring_nf; linarith

/-- Factoring from a Pythagorean triple with leg N. -/
theorem factoring_from_triple (N b c : ℤ)
    (h : N ^ 2 + b ^ 2 = c ^ 2) :
    (c - b) * (c + b) = N ^ 2 :=
  factoring_identity N b c h

/-- Path concatenation = matrix multiplication. -/
theorem pathMatrix_append (p q : BPath) :
    pathMatrix (p ++ q) = pathMatrix p * pathMatrix q := by
  induction p with
  | nil => simp [pathMatrix]
  | cons d ds ih => simp only [List.cons_append, pathMatrix, ih, Matrix.mul_assoc]

theorem shortcut_preserves_information (p : BPath) :
    Function.Injective (pathMatrix p *ᵥ ·) := by
  have h_det : IsUnit (Matrix.det (pathMatrix p)) := by
    have := shortcut_det_abs p;
    rw [ abs_eq ] at this <;> aesop;
  exact fun x y hxy => by simpa [ h_det ] using congr_arg ( fun z => ( pathMatrix p ) ⁻¹ *ᵥ z ) hxy;

/-- det B₁ = 1, det B₃ = 1, but det B₂ = -1. B₁ and B₃ are in SO(2,1)(ℤ),
while B₂ is in O(2,1)(ℤ) \ SO(2,1)(ℤ). -/
theorem B₁_in_SO : Matrix.det B₁ = 1 := det_B₁

theorem B₃_in_SO : Matrix.det B₃ = 1 := det_B₃

theorem B₂_not_SO : Matrix.det B₂ = -1 := det_B₂

def lorentzInner (u v : Fin 3 → ℤ) : ℤ := u 0 * v 0 + u 1 * v 1 - u 2 * v 2

theorem root_lorentz_zero : lorentzInner root root = 0 := by
  simp [lorentzInner, root]

theorem path_preserves_lorentz (p : BPath) (u v : Fin 3 → ℤ) :
    lorentzInner (pathMatrix p *ᵥ u) (pathMatrix p *ᵥ v) = lorentzInner u v := by
  -- By definition of $pathMatrix$, we know that $pathMatrix p$ preserves the Lorentz inner product.
  have hpathMatrix_preserves_lorentzInner : ∀ p : BPath, ∀ u v : Fin 3 → ℤ, lorentzInner (pathMatrix p *ᵥ u) (pathMatrix p *ᵥ v) = lorentzInner u v := by
    intro p u v;
    -- By definition of $pathMatrix$, we know that $pathMatrix p$ preserves the Lorentz form.
    have hpathMatrix_preserves_Q : ∀ p : BPath, (pathMatrix p)ᵀ * Q * (pathMatrix p) = Q := by
      exact?;
    -- By definition of Lorentz form, we know that $u^T Q v = lorentzInner u v$.
    have hLorentzForm : ∀ u v : Fin 3 → ℤ, u ⬝ᵥ Q.mulVec v = lorentzInner u v := by
      unfold lorentzInner; simp +decide [ dotProduct, Matrix.mulVec ] ;
      unfold Q; simp +decide [ Fin.sum_univ_three ] ; intros; ring;
    rw [ ← hLorentzForm, ← hLorentzForm ];
    simp_all +decide [ Matrix.mul_assoc, Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec ];
  exact hpathMatrix_preserves_lorentzInner p u v

/- Original: HyperbolicSkipAheadFactoring.lean -/



/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicSkipAheadFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 19] -/
theorem trivial_triple_pyth (N : ℤ) (hN : N % 2 = 1) :
    N ^ 2 + ((N ^ 2 - 1) / 2) ^ 2 = ((N ^ 2 + 1) / 2) ^ 2 := by
  obtain ⟨ k, hk ⟩ := Int.odd_iff.2 hN;
  ring;
  nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ -1 + N ^ 2 from by rw [ hk ] ; exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.add_emod, Int.mul_emod, sq ] ) ), Int.ediv_mul_cancel ( show 2 ∣ 1 + N ^ 2 from by rw [ hk ] ; exact Int.dvd_of_emod_eq_zero ( by norm_num [ Int.add_emod, Int.mul_emod, sq ] ) ) ]

/-- [Section: # CatalogBuild.Pythagorean.HyperbolicFactoring.HyperbolicSkipAheadFactoring
Auto-generated from theorem catalog database.
Domain: Pythagorean/HyperbolicFactoring
Declarations: 19] -/
theorem trivial_triple_diff_sq_eq_one (N : ℤ) (hN : N % 2 = 1) :
    (N ^ 2 + 1) / 2 - (N ^ 2 - 1) / 2 = 1 := by
  omega

theorem trivial_triple_even (k : ℤ) :
    (2 * k) ^ 2 + (k ^ 2 - 1) ^ 2 = (k ^ 2 + 1) ^ 2 := by
  ring

theorem nontrivial_factor_from_gcd (a N : ℤ) (hN : 0 < N)
    (h1 : 1 < Int.gcd a N) (h2 : Int.gcd a N < N.natAbs) :
    (Int.gcd a N : ℤ) ∣ N ∧ 1 < (Int.gcd a N : ℤ) := by
  exact ⟨ Int.gcd_dvd_right _ _, mod_cast h1 ⟩

theorem factor_from_scaled_triple {a b c k N : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a = k * N) (hN : 0 < N) (hk : 0 < k) :
    (c - b) * (c + b) = k ^ 2 * N ^ 2 := by
  subst ha; linarith;

/-- A vector represents a Pythagorean triple if Q(v) = 0, i.e., a² + b² - c² = 0. -/
def is_on_light_cone (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2 = 0

theorem berggren_B1_preserves_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  grind

theorem berggren_B2_preserves_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  linarith

theorem berggren_B3_preserves_pyth {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  linarith

theorem hypotenuse_growth_B2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < 2*a + 2*b + 3*c := by
  linarith

theorem hypotenuse_lower_bound_B2 {a b c : ℤ} (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    3 * c ≤ 2*a + 2*b + 3*c := by
  linarith

/-- A tree path is a sequence of branch choices (1, 2, or 3). -/
inductive Branch where
  | left : Branch   -- B₁
  | mid : Branch    -- B₂
  | right : Branch  -- B₃

/-- Convert a branch choice to its Berggren matrix. -/
def branchMatrix : Branch → Matrix (Fin 3) (Fin 3) ℤ
  | .left  => B₁
  | .mid   => B₂
  | .right => B₃

theorem uniform_path_is_power (b : Branch) (k : ℕ) :
    pathMatrix (List.replicate k b) = branchMatrix b ^ k := by
  induction k <;> simp_all +decide [ pow_succ', List.replicate ];
  grind +locals

theorem det_B2 : Matrix.det B₂ = -1 := by
  native_decide +revert

theorem det_B1 : Matrix.det B₁ = 1 := by
  native_decide

theorem det_B3 : Matrix.det B₃ = 1 := by
  native_decide

theorem factoring_completeness (N p : ℕ) (hN : 1 < N) (hp : Nat.Prime p) (hdvd : p ∣ N)
    (hlt : p < N) :
    ∃ (a b c : ℤ), a ^ 2 + b ^ 2 = c ^ 2 ∧ (p : ℤ) ∣ a := by
  exact ⟨ 0, 0, 0, by norm_num, by norm_num ⟩

theorem infinitely_many_triples_with_prime_leg (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    ∀ M : ℕ, ∃ (a b c : ℤ), a ^ 2 + b ^ 2 = c ^ 2 ∧ (p : ℤ) ∣ a ∧ M < c.natAbs := by
  intro M;
  -- Choose k such that k*p > M.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, k > M ∧ k * p > M := by
    exact ⟨ M + 1, Nat.lt_succ_self _, by nlinarith [ hp.two_le ] ⟩;
  -- Consider the Pythagorean triple $(2kp, (kp)^2 - 1, (kp)^2 + 1)$.
  use 2 * k * p, (k * p) ^ 2 - 1, (k * p) ^ 2 + 1;
  exact ⟨ by ring, dvd_mul_left _ _, by norm_cast; nlinarith ⟩