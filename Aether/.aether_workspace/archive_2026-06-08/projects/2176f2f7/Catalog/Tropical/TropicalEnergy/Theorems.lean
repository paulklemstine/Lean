import Tropical.TropicalEnergy.Defs

/-!
# Tropical Energy Semantics: Main Theorems

## Theorem Overview

1. **Lifting Invariance**: The tropical potential is invariant under de Bruijn
   lifting — renaming free variables does not change energy.

2. **Compositional Substitution**: Substitution decomposes algebraically:
   `tropicalPotential (substN n s t) = potentialWith (tropicalPotential s) n t`.

3. **Substitution Energy Bound**: For affine terms (variable occurs ≤ 1 time),
   `tropicalPotential (substN n s t) ≤ tropicalPotential t * tropicalPotential s`.

4. **β-Dissipation**: Every affine β-step strictly decreases the tropical potential.

5. **Congruence Monotonicity**: Potential decrease in subterms propagates.

6. **Lyapunov Well-Foundedness**: Strict ℕ-decrease implies well-foundedness.
-/

namespace TropicalEnergy

/-! ## Potential Lower Bound -/

/-
Every term has tropical potential at least 2.
-/
theorem tropicalPotential_ge_two (t : Tm) : tropicalPotential t ≥ 2 := by
  induction' t using Tm.recOn with t ih;
  · rfl;
  · exact Nat.le_trans ( by decide ) ( Nat.add_le_add_right ‹2 ≤ tropicalPotential ih› 1 );
  · exact le_trans ‹_› ( Nat.le_mul_of_pos_right _ ( by positivity ) )

/-! ## Lifting Invariance -/

/-
Lifting (renaming) does not change the tropical potential.
-/
theorem tropicalPotential_lift (c : ℕ) (t : Tm) :
    tropicalPotential (Tm.lift c t) = tropicalPotential t := by
  induction' t with n t ih generalizing c;
  · aesop;
  · exact Nat.succ_inj.mpr (ih (c + 1));
  · rename_i t₁ t₂ ht₁ ht₂;
    convert congr_arg₂ ( · * · ) ( ht₁ c ) ( ht₂ c ) using 1

/-! ## Parameterized Potential Properties -/

/-
The parameterized potential at v = 2 equals the standard potential.
-/
theorem potentialWith_eq_tropicalPotential (n : ℕ) (t : Tm) :
    potentialWith 2 n t = tropicalPotential t := by
  induction' t with m t ih generalizing n;
  · cases eq_or_ne m n <;> simp +decide [ *, potentialWith ];
    · rfl;
    · rfl;
  · exact congr_arg ( · + 1 ) ( ih _ );
  · rename_i t₁ t₂ ih₁ ih₂;
    convert congr_arg₂ ( · * · ) ( ih₁ n ) ( ih₂ n ) using 1

/-
When variable n does not occur, the parameterized potential
    is independent of v.
-/
theorem potentialWith_occN_zero (t : Tm) (n : ℕ) (v w : ℕ)
    (h : Tm.occN n t = 0) :
    potentialWith v n t = potentialWith w n t := by
  induction' t with m t ih generalizing n v w;
  · simp_all +decide [ Tm.occN, potentialWith ];
  · convert congr_arg ( · + 1 ) ( ih ( n + 1 ) v w h ) using 1;
  · simp_all +decide [ Tm.occN ];
    rename_i k hk hk₂;
    exact congr_arg₂ _ ( hk _ _ _ h.1 ) ( hk₂ _ _ _ h.2 )

/-
The parameterized potential is at least 2 when v ≥ 2.
-/
theorem potentialWith_ge_two (v : ℕ) (hv : v ≥ 2) (n : ℕ) (t : Tm) :
    potentialWith v n t ≥ 2 := by
  induction' t with t ih generalizing n;
  · unfold potentialWith; aesop;
  · exact Nat.le_trans ( by linarith ) ( Nat.add_le_add_right ( ‹∀ n, potentialWith v n ih ≥ 2› ( n + 1 ) ) 1 );
  · exact le_trans ( by nlinarith [ ‹∀ n, potentialWith v n _ ≥ 2› n, ‹∀ n, potentialWith v n _ ≥ 2› n ] ) ( Nat.mul_le_mul ( ‹∀ n, potentialWith v n _ ≥ 2› n ) ( ‹∀ n, potentialWith v n _ ≥ 2› n ) )

/-! ## Compositional Substitution Theorem -/

/-
**Compositional Substitution Theorem.**
    The tropical potential of a substituted term equals the parameterized
    potential evaluated at the substituent's energy.
-/
theorem tropicalPotential_substN (n : ℕ) (s t : Tm) :
    tropicalPotential (Tm.substN n s t) =
    potentialWith (tropicalPotential s) n t := by
  have h_subst : ∀ (n : ℕ) (s t : Tm), potentialWith (tropicalPotential s) n t = tropicalPotential (Tm.substN n s t) := by
    intros n s t
    induction' t with t ih generalizing n s;
    · by_cases h : t = n <;> simp +decide [ h, Tm.substN ];
      · exact if_pos rfl;
      · split_ifs <;> simp_all +decide [ potentialWith ];
        · rfl;
        · rfl;
    · convert congr_arg ( · + 1 ) ( ‹∀ ( n : ℕ ) ( s : Tm ), potentialWith ( tropicalPotential s ) n ih = tropicalPotential ( Tm.substN n s ih ) › ( n + 1 ) ( Tm.lift 0 s ) ) using 1;
      rw [ tropicalPotential_lift ];
      rfl;
    · rename_i a b ha hb aesop;
      convert congr_arg₂ ( · * · ) ( hb n s ) ( aesop n s ) using 1;
  rw [ h_subst ]

/-- Specialization to top-level substitution. -/
theorem tropicalPotential_substTop (s t : Tm) :
    tropicalPotential (Tm.substTop s t) =
    potentialWith (tropicalPotential s) 0 t :=
  tropicalPotential_substN 0 s t

/-! ## Substitution Energy Bound -/

/-
**Substitution Energy Bound** (affine case).
    When variable n occurs at most once, substitution energy is bounded
    by the product of the original and substituent energies.
-/
theorem tropicalPotential_substN_le_mul (n : ℕ) (s t : Tm)
    (h : Tm.occN n t ≤ 1) :
    tropicalPotential (Tm.substN n s t) ≤
    tropicalPotential t * tropicalPotential s := by
  rw [ tropicalPotential_substN ];
  induction' t with t ih generalizing n s;
  · simp +decide [ potentialWith ];
    split_ifs <;> nlinarith [ tropicalPotential_ge_two s, show tropicalPotential ( Tm.var t ) = 2 from by rfl ];
  · rename_i h';
    specialize h' ( n + 1 ) s ; simp_all +decide [ Tm.occN ];
    rw [ show potentialWith ( tropicalPotential s ) n ih.lam = potentialWith ( tropicalPotential s ) ( n + 1 ) ih + 1 from rfl, show tropicalPotential ih.lam = tropicalPotential ih + 1 from rfl ] ; nlinarith [ tropicalPotential_ge_two s ];
  · rename_i a b ih_a ih_b;
    -- By definition of `occN`, we know that `occN n (a.app b) = occN n a + occN n b`.
    have h_occN : Tm.occN n (a.app b) = Tm.occN n a + Tm.occN n b := by
      rfl;
    by_cases ha : Tm.occN n a = 0 <;> by_cases hb : Tm.occN n b = 0 <;> simp_all +decide [ potentialWith ];
    · -- By definition of `potentialWith`, we know that `potentialWith (tropicalPotential s) n a = tropicalPotential a` and `potentialWith (tropicalPotential s) n b = tropicalPotential b`.
      have h_potentialWith_a : potentialWith (tropicalPotential s) n a = tropicalPotential a := by
        convert potentialWith_occN_zero a n ( tropicalPotential s ) 2 ha using 1;
        exact potentialWith_eq_tropicalPotential n a ▸ rfl
      have h_potentialWith_b : potentialWith (tropicalPotential s) n b = tropicalPotential b := by
        rw [ ← potentialWith_eq_tropicalPotential ];
        rw [ potentialWith_occN_zero ];
        convert potentialWith_eq_tropicalPotential n b using 1;
        · exact hb;
        · exact n;
      rw [ h_potentialWith_a, h_potentialWith_b, show tropicalPotential ( a.app b ) = tropicalPotential a * tropicalPotential b from rfl ];
      exact le_mul_of_one_le_right ( Nat.zero_le _ ) ( by linarith [ tropicalPotential_ge_two s ] );
    · -- Since `occN n a = 0`, we have `potentialWith (tropicalPotential s) n a = tropicalPotential a`.
      have h_pot_a : potentialWith (tropicalPotential s) n a = tropicalPotential a := by
        convert potentialWith_occN_zero a n ( tropicalPotential s ) 2 ha using 1;
        exact potentialWith_eq_tropicalPotential n a ▸ rfl;
      -- By definition of `tropicalPotential`, we know that `tropicalPotential (a.app b) = tropicalPotential a * tropicalPotential b`.
      have h_pot_app : tropicalPotential (a.app b) = tropicalPotential a * tropicalPotential b := by
        rfl;
      nlinarith [ ih_b n s h, tropicalPotential_ge_two a, tropicalPotential_ge_two b, tropicalPotential_ge_two s ];
    · -- Since `occN n b = 0`, we have `potentialWith (tropicalPotential s) n b = tropicalPotential b`.
      have h_pot_b : potentialWith (tropicalPotential s) n b = tropicalPotential b := by
        convert potentialWith_occN_zero b n ( tropicalPotential s ) 2 hb using 1;
        exact potentialWith_eq_tropicalPotential n b ▸ rfl;
      rw [ show tropicalPotential ( a.app b ) = tropicalPotential a * tropicalPotential b from rfl ];
      rw [ h_pot_b, mul_right_comm ];
      exact Nat.mul_le_mul_right _ ( ih_a n s h );
    · omega

/-! ## β-Dissipation Theorem -/

/-
**β-Dissipation Theorem.**
    Every affine β-step strictly decreases the tropical potential.
    The dissipated energy equals `tropicalPotential s` (the binding energy).
-/
theorem tropicalPotential_beta_decrease (t s : Tm)
    (h : Tm.occN 0 t ≤ 1) :
    tropicalPotential (Tm.substTop s t) <
    tropicalPotential (.app (.lam t) s) := by
  -- By the properties of the tropical potential, we can expand both sides.
  have h_expand : tropicalPotential (Tm.substTop s t) ≤ tropicalPotential t * tropicalPotential s ∧ tropicalPotential (Tm.app (Tm.lam t) s) = (tropicalPotential t + 1) * tropicalPotential s := by
    exact ⟨ tropicalPotential_substN_le_mul 0 s t h, rfl ⟩;
  nlinarith [ tropicalPotential_ge_two t, tropicalPotential_ge_two s ]

/-! ## Congruence Monotonicity -/

/-
Application is strictly monotone in the function position.
-/
theorem tropicalPotential_app_mono_left (f f' a : Tm)
    (h : tropicalPotential f' < tropicalPotential f) :
    tropicalPotential (.app f' a) < tropicalPotential (.app f a) := by
  convert mul_lt_mul_of_pos_right h _ using 1;
  exact lt_of_lt_of_le ( by decide ) ( TropicalEnergy.tropicalPotential_ge_two a )

/-
Application is strictly monotone in the argument position.
-/
theorem tropicalPotential_app_mono_right (f a a' : Tm)
    (h : tropicalPotential a' < tropicalPotential a) :
    tropicalPotential (.app f a') < tropicalPotential (.app f a) := by
  exact mul_lt_mul_of_pos_left h ( by linarith [ TropicalEnergy.tropicalPotential_ge_two f ] )

/-
Lambda is strictly monotone.
-/
theorem tropicalPotential_lam_mono (t t' : Tm)
    (h : tropicalPotential t' < tropicalPotential t) :
    tropicalPotential (.lam t') < tropicalPotential (.lam t) := by
  exact Nat.add_lt_add_right h 1

/-! ## Lyapunov Well-Foundedness -/

/-
**Lyapunov Well-Foundedness Principle.**
    If `f` strictly decreases along the relation `r`, then `r` is well-founded.
    Here `r x y` means x is "below" y (f x < f y).
-/
theorem lyapunov_wellFounded {α : Type*} {r : α → α → Prop}
    (f : α → ℕ) (hf : ∀ x y, r x y → f x < f y) :
    WellFounded r := by
  refine' ⟨ fun x => _ ⟩;
  induction' n : f x using Nat.strong_induction_on with n ih generalizing x;
  refine' ⟨ _, fun y hy => _ ⟩;
  exact ih _ ( by linarith [ hf _ _ hy ] ) _ rfl

/-! ## Affine Step Relation and Energy Model -/

/-- Affine one-step reduction: β-reduction where the bound variable
    occurs at most once, with full contextual closure. -/
inductive AffineStep : Tm → Tm → Prop where
  | beta : Tm.occN 0 t ≤ 1 → AffineStep (.app (.lam t) s) (Tm.substTop s t)
  | appL : AffineStep f f' → AffineStep (.app f a) (.app f' a)
  | appR : AffineStep a a' → AffineStep (.app f a) (.app f a')
  | xi   : AffineStep t t' → AffineStep (.lam t) (.lam t')

/-
Every affine reduction step strictly decreases the tropical potential.
-/
theorem affineStep_decrease {t u : Tm} (h : AffineStep t u) :
    tropicalPotential u < tropicalPotential t := by
  induction h with
  | beta h => exact tropicalPotential_beta_decrease _ _ h
  | appL _ ih => exact tropicalPotential_app_mono_left _ _ _ ih
  | appR _ ih => exact tropicalPotential_app_mono_right _ _ _ ih
  | xi _ ih => exact tropicalPotential_lam_mono _ _ ih

/-- The inverse of the affine step relation is well-founded:
    there are no infinite affine reduction sequences. -/
theorem affineStep_wellFounded :
    WellFounded (fun u t => AffineStep t u) :=
  lyapunov_wellFounded tropicalPotential (fun _ _ h => affineStep_decrease h)

/-- **Tropical Energy Model for Affine β-Reduction.** -/
noncomputable def affineTropicalModel : TropicalEnergyModel AffineStep :=
  { potential := tropicalPotential,
    dissipative := affineStep_decrease }

/-! ## Type Depth Properties -/

/-
Type depth of an arrow type exceeds the depth of its domain.
-/
theorem typeDepth_arr_left (A B : Ty) :
    typeDepth A < typeDepth (.arr A B) := by
  exact lt_max_of_lt_left ( Nat.lt_succ_self _ )

/-
Type depth of an arrow is at least the depth of its codomain.
-/
theorem typeDepth_arr_right (A B : Ty) :
    typeDepth B ≤ typeDepth (.arr A B) := by
  exact le_max_right _ _

/-
Type weight is always positive.
-/
theorem typeWeight_pos (A : Ty) : typeWeight A ≥ 1 := by
  induction A <;> simp +arith +decide [ * ];
  exact Nat.le_add_left _ _

/-! ## Reduction Length Bound -/

/-
Transitive affine reduction strictly decreases potential.
-/
theorem affine_transGen_decrease {t u : Tm}
    (h : Relation.TransGen AffineStep t u) :
    tropicalPotential u < tropicalPotential t := by
  induction' h with v hv ih;
  · exact affineStep_decrease hv;
  · exact lt_trans (affineStep_decrease ‹_›) ‹_›

/-- Potential difference bounded by initial potential minus 2. -/
theorem affine_reduction_length_bound {t u : Tm}
    (_h : Relation.ReflTransGen AffineStep t u) :
    tropicalPotential t - tropicalPotential u ≤ tropicalPotential t - 2 :=
  Nat.sub_le_sub_left (tropicalPotential_ge_two u) _

end TropicalEnergy