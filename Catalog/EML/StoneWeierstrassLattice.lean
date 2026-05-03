/-
# Stone–Weierstrass for Vector Lattices (Kakutani–Stone Theorem)

This file proves the lattice version of the Stone–Weierstrass theorem:
if `A ⊆ C(X, ℝ)` is a set of continuous functions on a compact Hausdorff space
that is closed under real scalar multiplication, addition, constants, and
pointwise `⊔`/`⊓`, and separates points, then `A` is uniformly dense in `C(X, ℝ)`.

This is the correct functional-analytic foundation for the EML (Exponential-Max-Linear)
approximation program: EML classes are naturally stable under affine operations and
max/min, and this result upgrades those closure properties directly to universal
approximation — with no multiplication closure required.

## Main results

* `eml_exists_uniformApprox_of_separatesPoints_vectorLattice`: for every `g : C(X, ℝ)`
  and `ε > 0`, there exists `f ∈ A` with `‖f - g‖ < ε`.
* `eml_dense_of_separatesPoints_vectorLattice`: `A` is dense in `C(X, ℝ)`.

## Proof architecture

The proof follows the classical Kakutani–Stone lattice patching argument:

1. **Affine interpolation**: from point-separation, construct `f ∈ A` matching any
   prescribed values at two distinct points.
2. **Local lower approximation**: for each fixed `x`, patch via finite `⊓` to obtain
   `F_x ∈ A` with `F_x` globally below `g + ε` and `F_x x` close to `g x`.
3. **Global approximation**: patch the `F_x` via finite `⊔` to get `F ∈ A` with
   `‖F - g‖ < ε`.

## References

* Kakutani, S. (1941). Concrete representation of abstract (M)-spaces.
* Stone, M. H. (1948). The generalized Weierstrass approximation theorem.
-/
import Mathlib

noncomputable section

open Set
open scoped Topology NNReal

variable {X : Type*} [TopologicalSpace X]

/-! ### Section 1: Vector-lattice closure lemmas -/

/-
Negation closure: `-f ∈ A` whenever `f ∈ A`, using `(-1) • f = -f`.
-/
lemma eml_mem_neg
    (A : Set C(X, ℝ))
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A) :
    -f ∈ A := by
  simpa using @hsmul ( -1 ) f hf

/-- Subtraction closure: `f - g ∈ A` whenever `f, g ∈ A`. -/
lemma eml_mem_sub
    (A : Set C(X, ℝ))
    (hadd : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f + g ∈ A)
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    {f g : C(X, ℝ)} (hf : f ∈ A) (hg : g ∈ A) :
    f - g ∈ A := by
  rw [sub_eq_add_neg]
  exact hadd hf (eml_mem_neg A hsmul hg)

/-- Absolute value closure: `|f| = f ⊔ (-f) ∈ A`. -/
lemma eml_mem_abs
    (A : Set C(X, ℝ))
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    (hsup : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    {f : C(X, ℝ)} (hf : f ∈ A) :
    |f| ∈ A := by
  have : |f| = f ⊔ (-f) := by ext x; simp [abs_eq_max_neg]
  rw [this]
  exact hsup hf (eml_mem_neg A hsmul hf)

/-
Decomposition identity: `f⁺ - f⁻ = f` pointwise.
-/
lemma eml_pos_sub_neg
    (f : C(X, ℝ)) :
    f ⊔ (ContinuousMap.const X 0) - (-f) ⊔ (ContinuousMap.const X 0) = f := by
  aesop

/-! ### Section 2: Two-point interpolation -/

/-
**Two-point interpolation**: given distinct points `x ≠ y` and target values `a, b`,
there exists `f ∈ A` with `f x = a` and `f y = b`. This is the key use of
point separation combined with affine closure.
-/
lemma eml_exists_eq_at_two_points
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f + g ∈ A)
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    (hsep : ∀ x y : X, x ≠ y →
      ∃ f : C(X, ℝ), f ∈ A ∧ f x ≠ f y)
    {x y : X} (hxy : x ≠ y) (a b : ℝ) :
    ∃ f : C(X, ℝ), f ∈ A ∧ f x = a ∧ f y = b := by
  obtain ⟨ u, huA, huxy ⟩ := hsep x y hxy;
  -- Define `f = ((b - a) / d) • (u - ContinuousMap.const X (u x)) + ContinuousMap.const X a`.
  set d := u y - u x
  set f : C(X, ℝ) := ((b - a) / d) • (u - ContinuousMap.const X (u x)) + ContinuousMap.const X a;
  refine' ⟨ f, _, _, _ ⟩;
  · refine' hadd _ ( hconst a );
    exact hsmul ( eml_mem_sub _ hadd hsmul huA ( hconst _ ) );
  · aesop;
  · simp +zetaDelta at *;
    rw [ div_mul_cancel₀ _ ( sub_ne_zero_of_ne <| Ne.symm huxy ), sub_add_cancel ]

/-! ### Section 3: Finite sup/inf closure -/

/-
Finite sup closure over a list.
-/
lemma eml_mem_list_sup
    (A : Set C(X, ℝ))
    (hsup : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    {h : C(X, ℝ)} (hh : h ∈ A)
    (l : List C(X, ℝ)) (hl : ∀ f ∈ l, f ∈ A) :
    l.foldl (· ⊔ ·) h ∈ A := by
  induction' l using List.reverseRecOn with l ih;
  · exact hh;
  · aesop

/-
Finite inf closure over a list.
-/
lemma eml_mem_list_inf
    (A : Set C(X, ℝ))
    (hinf : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    {h : C(X, ℝ)} (hh : h ∈ A)
    (l : List C(X, ℝ)) (hl : ∀ f ∈ l, f ∈ A) :
    l.foldl (· ⊓ ·) h ∈ A := by
  induction' l using List.reverseRecOn with l IH <;> aesop

/-! ### Section 4: Local approximation via compactness -/

/-
**Local lower approximation**: for each `x : X`, there exists `F_x ∈ A` such that
`F_x` is globally below `g + ε` and `F_x x` equals `g x`.

This is the finite-inf step: for each `y`, use two-point interpolation to get
`u_y ∈ A` matching `g` at both `x` and `y`. By continuity, `u_y` is below `g + ε`
on a neighborhood of `y`. By compactness, finitely many neighborhoods cover `X`.
Taking the finite infimum gives a function globally below `g + ε` that equals `g x`
at `x`.
-/
lemma eml_exists_approx_below
    [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f + g ∈ A)
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    (hinf : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y →
      ∃ f : C(X, ℝ), f ∈ A ∧ f x ≠ f y)
    (g : C(X, ℝ)) (x : X) (ε : ℝ) (hε : 0 < ε) :
    ∃ F : C(X, ℝ), F ∈ A ∧ F x = g x ∧ ∀ z : X, F z < g z + ε := by
  -- For each y : X, define u_y ∈ A as follows:
  -- - If y = x, use the constant function g x (which is in A by hconst). Then u_y x = g x and u_y y = g x = g y.
  -- - If y ≠ x, use eml_exists_eq_at_two_points to get u_y ∈ A with u_y x = g x and u_y y = g y.
  have hu_y : ∀ y : X, ∃ u_y : C(X, ℝ), u_y ∈ A ∧ u_y x = g x ∧ u_y y = g y := by
    intro y
    by_cases hy : y = x;
    · exact ⟨ ContinuousMap.const X ( g x ), hconst _, rfl, by simp +decide [ hy ] ⟩;
    · exact eml_exists_eq_at_two_points A hconst hadd hsmul hsep (fun a => hy (id (Eq.symm a))) (g x) (g y);
  choose u hu using hu_y;
  -- By continuity, $u_y$ is below $g + \epsilon$ on a neighborhood of $y$. By compactness, finitely many neighborhoods cover $X$.
  obtain ⟨t, ht⟩ : ∃ t : Finset X, ∀ z : X, ∃ y ∈ t, (u y) z < g z + ε := by
    have h_open_cover : ∀ y : X, IsOpen {z : X | (u y) z < g z + ε} := by
      exact fun y => isOpen_lt ( u y |> ContinuousMap.continuous ) ( g.continuous.add continuous_const );
    have := @CompactSpace.elim_nhds_subcover X _ _ ( fun y => { z | ( u y ) z < g z + ε } );
    simp_all +decide [ Set.ext_iff ];
    exact this fun y => IsOpen.mem_nhds ( h_open_cover y ) ( by simpa [ hu y ] using hε );
  -- Take the finite infimum F = ⊓ over y ∈ t of u_y. F ∈ A by eml_mem_list_inf.
  obtain ⟨F, hF⟩ : ∃ F : C(X, ℝ), F ∈ A ∧ ∀ y ∈ t, F ≤ u y ∧ F x = g x := by
    have hF : ∀ (l : List C(X, ℝ)), (∀ f ∈ l, f ∈ A ∧ f x = g x) → ∃ F : C(X, ℝ), F ∈ A ∧ F x = g x ∧ ∀ f ∈ l, F ≤ f := by
      intro l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide ;
      · exact ⟨ u x, hu x |>.1, hu x |>.2.1 ⟩;
      · obtain ⟨ F, hF₁, hF₂, hF₃ ⟩ := ‹∃ F ∈ A, F x = g x ∧ ∀ f ∈ l, F ≤ f›; use F ⊓ ih; simp_all +decide [ ContinuousMap.le_def ] ;
        grind;
    obtain ⟨ F, hF₁, hF₂, hF₃ ⟩ := hF ( t.toList.map u ) ( by aesop ) ; use F; aesop;
  exact ⟨ F, hF.1, hF.2 _ ( Classical.choose_spec ( Finset.nonempty_of_ne_empty ( by rintro rfl; simpa using ht x ) ) ) |>.2, fun z => by obtain ⟨ y, hy, hy' ⟩ := ht z; exact lt_of_le_of_lt ( hF.2 _ hy |>.1 z ) hy' ⟩

/-
**Global ε-approximation theorem** (Kakutani–Stone).

For every `g : C(X, ℝ)` and `ε > 0`, there exists `f ∈ A` with `‖f - g‖ < ε`.
This combines the local lower approximation at each `x` with a finite-sup step.

For each `x`, `F_x` from the previous lemma satisfies `F_x z < g z + ε` for all `z`
and `F_x x = g x`. By continuity, `g z - ε < F_x z` on a neighborhood `V_x` of `x`.
By compactness, finitely many `V_x` cover `X`. Taking the finite supremum gives
`F ∈ A` with `g z - ε < F z < g z + ε` for all `z`, hence `‖F - g‖ < ε`.
-/
theorem eml_exists_uniformApprox_of_separatesPoints_vectorLattice
    [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f + g ∈ A)
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    (hsup : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y →
      ∃ f : C(X, ℝ), f ∈ A ∧ f x ≠ f y) :
    ∀ (g : C(X, ℝ)) (ε : ℝ), 0 < ε →
      ∃ f : C(X, ℝ), f ∈ A ∧ ‖f - g‖ < ε := by
  intro g ε hε;
  obtain ⟨t, ht⟩ : ∃ t : Finset X, ∀ x : X, ∃ y ∈ t, g x - ε < (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) x := by
    have h_cover : ∀ x : X, ∃ V : Set X, IsOpen V ∧ x ∈ V ∧ ∀ y ∈ V, g y - ε < (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g x (ε / 2) (half_pos hε))) y := by
      intro x
      obtain ⟨F_x, hF_x⟩ := Classical.choose_spec (eml_exists_approx_below A hconst hadd hsmul hinf hsep g x (ε / 2) (half_pos hε));
      have h_cont : Continuous (fun y => (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g x (ε / 2) (half_pos hε))) y - g y) := by
        exact Continuous.sub ( Classical.choose ( eml_exists_approx_below A hconst hadd hsmul hinf hsep g x ( ε / 2 ) ( half_pos hε ) ) |> ContinuousMap.continuous ) g.continuous;
      exact ⟨ { y | ( Classical.choose ( eml_exists_approx_below A hconst hadd hsmul hinf hsep g x ( ε / 2 ) ( half_pos hε ) ) ) y - g y > -ε }, isOpen_lt continuous_const h_cont, by norm_num; linarith, fun y hy => by linarith [ hy.out ] ⟩;
    choose V hV using h_cover;
    have := @CompactSpace.elim_nhds_subcover X _ _ ( fun x => V x ) ( fun x => ( hV x ).1.mem_nhds ( hV x ).2.1 );
    obtain ⟨ t, ht ⟩ := this;
    exact ⟨ t, fun x => by replace ht := Set.ext_iff.mp ht x; aesop ⟩;
  obtain ⟨f, hf⟩ : ∃ f : C(X, ℝ), f ∈ A ∧ ∀ x : X, g x - ε < f x ∧ f x < g x + ε := by
    have h_sup : ∀ y ∈ t, (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) ∈ A ∧ ∀ x : X, (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) x < g x + ε := by
      intro y hy
      have := Classical.choose_spec (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))
      exact ⟨this.left, fun x => by linarith [this.right.right x]⟩;
    by_cases ht_empty : t.Nonempty;
    · obtain ⟨y₀, hy₀⟩ : ∃ y₀ ∈ t, True := by
        exact ⟨ ht_empty.choose, ht_empty.choose_spec, trivial ⟩;
      use t.toList.map (fun y => Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) |>.foldl (· ⊔ ·) (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y₀ (ε / 2) (half_pos hε)));
      refine' ⟨ _, _ ⟩;
      · convert eml_mem_list_sup A hsup _ _ _;
        · exact h_sup y₀ hy₀.1 |>.1;
        · simp +zetaDelta at *;
          exact fun x hx => h_sup x hx |>.1;
      · intro x
        obtain ⟨y, hy₁, hy₂⟩ := ht x
        have hy₃ : (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) x < g x + ε := by
          exact h_sup y hy₁ |>.2 x
        have hy₄ : g x - ε < (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) x := by
          exact hy₂
        have hy₅ : (List.foldl (fun x1 x2 => x1 ⊔ x2) (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y₀ (ε / 2) (half_pos hε))) (List.map (fun y => Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) t.toList)) x ≥ (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) x := by
          have hy₅ : ∀ {l : List C(X, ℝ)}, (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) ∈ l → (List.foldl (fun x1 x2 => x1 ⊔ x2) (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y₀ (ε / 2) (half_pos hε))) l) x ≥ (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) x := by
            intros l hl; induction' l using List.reverseRecOn with l ih <;> aesop;
          exact hy₅ ( List.mem_map.mpr ⟨ y, Finset.mem_toList.mpr hy₁, rfl ⟩ )
        have hy₆ : (List.foldl (fun x1 x2 => x1 ⊔ x2) (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y₀ (ε / 2) (half_pos hε))) (List.map (fun y => Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y (ε / 2) (half_pos hε))) t.toList)) x < g x + ε := by
          have hy₆ : ∀ {l : List C(X, ℝ)}, (∀ f ∈ l, f x < g x + ε) → (List.foldl (fun x1 x2 => x1 ⊔ x2) (Classical.choose (eml_exists_approx_below A hconst hadd hsmul hinf hsep g y₀ (ε / 2) (half_pos hε))) l) x < g x + ε := by
            intro l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ List.foldl ] ;
          exact hy₆ fun f hf => by obtain ⟨ y, hy, rfl ⟩ := List.mem_map.mp hf; exact h_sup y ( Finset.mem_toList.mp hy ) |>.2 x;
        exact ⟨by linarith, by linarith⟩;
    · cases isEmpty_or_nonempty X <;> aesop;
  refine' ⟨ f, hf.1, _ ⟩;
  rw [ ContinuousMap.norm_lt_iff _ hε ];
  exact fun x => abs_lt.mpr ⟨ by norm_num; linarith [ hf.2 x ], by norm_num; linarith [ hf.2 x ] ⟩

/-
**Density form** of the lattice Stone–Weierstrass theorem: `A` is dense
in `C(X, ℝ)` with the sup norm topology.
-/
theorem eml_dense_of_separatesPoints_vectorLattice
    [CompactSpace X] [T2Space X]
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f + g ∈ A)
    (hsmul : ∀ {a : ℝ} {f : C(X, ℝ)}, f ∈ A → a • f ∈ A)
    (hsup : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hinf : ∀ {f g : C(X, ℝ)}, f ∈ A → g ∈ A → f ⊓ g ∈ A)
    (hsep : ∀ x y : X, x ≠ y →
      ∃ f : C(X, ℝ), f ∈ A ∧ f x ≠ f y) :
    Dense A := by
  refine' fun g => Metric.mem_closure_iff.2 fun ε εpos => _;
  rcases eml_exists_uniformApprox_of_separatesPoints_vectorLattice A hconst hadd hsmul hsup hinf hsep g ε εpos with ⟨ f, hfA, hfε ⟩ ; exact ⟨ f, hfA, by simpa [ dist_eq_norm' ] using hfε ⟩

end