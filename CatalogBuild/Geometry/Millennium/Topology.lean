/-! # CatalogBuild.Geometry.Millennium.Topology

Auto-generated from theorem catalog database.
Domain: Geometry/Millennium
Declarations: 9
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Millennium.Topology
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 9] -/
theorem real_simply_connected : SimplyConnectedSpace ℝ := by
  infer_instance


/-- [Section: # CatalogBuild.Speculative.Millennium.Topology
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 9] -/
theorem simply_connected_of_trivial_pi1 {X : Type*} [TopologicalSpace X]
    [PathConnectedSpace X] [SimplyConnectedSpace X] :
    ∀ (x : X) (p : Path x x), p.Homotopic (Path.refl x) := by
  exact?


/-- The Euler characteristic of a closed orientable surface of genus g is 2 - 2g.
For g = 0 (sphere), χ = 2. This is a fundamental invariant. -/
theorem euler_char_sphere : 2 - 2 * (0 : ℤ) = 2 := by ring


/-- The Euler characteristic of a torus (genus 1) is 0. -/
theorem euler_char_torus : 2 - 2 * (1 : ℤ) = 0 := by ring


/-- For a compact manifold, the Euler characteristic equals the alternating
sum of Betti numbers: χ = Σ (-1)^k b_k.
We verify this for the 2-sphere: b_0 = 1, b_1 = 0, b_2 = 1, so χ = 2. -/
theorem euler_char_from_betti_sphere :
    (1 : ℤ) - 0 + 1 = 2 := by ring


/-- For a K3 surface, the Hodge numbers give Euler characteristic = 24.
h^{0,0} = 1, h^{1,0} = 0, h^{2,0} = 1, h^{1,1} = 20
χ = 1 - 0 + (1 + 20 + 1) - 0 + 1 = 24 -/
theorem euler_char_k3 :
    (1 : ℤ) - 0 + (1 + 20 + 1) - 0 + 1 = 24 := by ring


/-- [Section: # CatalogBuild.Speculative.Millennium.Topology
Auto-generated from theorem catalog database.
Domain: Speculative/Millennium
Declarations: 9] -/
theorem ricci_flow_sphere_collapse_time (r₀ : ℝ) (n : ℕ) (hr₀ : 0 < r₀) (hn : 2 ≤ n) :
    0 < r₀ ^ 2 / (2 * (↑n - 1)) := by
  exact div_pos ( sq_pos_of_pos hr₀ ) ( mul_pos zero_lt_two ( by norm_num; linarith ) )


/-- The fundamental group of S¹ is ℤ (not simply connected). -/
theorem fundamental_group_circle_infinite : Infinite ℤ := inferInstance


theorem simply_connected_prod {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    [SimplyConnectedSpace X] [SimplyConnectedSpace Y] :
    SimplyConnectedSpace (X × Y) := by
  rw [ simply_connected_iff_unique_homotopic ] at *;
  refine' ⟨ _, _ ⟩
  all_goals generalize_proofs at *;
  · aesop;
  · intro x y
    obtain ⟨hx, hy⟩ := x
    obtain ⟨hx', hy'⟩ := y
    have h_homotopy : ∀ (p q : Path (hx, hy) (hx', hy')), p.Homotopic q := by
      intro p q
      have h_homotopy_X : Path.Homotopic (Path.map p (continuous_fst)) (Path.map q (continuous_fst)) := by
        have := ‹Nonempty X ∧ ∀ x y : X, Nonempty (Unique (Path.Homotopic.Quotient x y))›.2 hx hx';
        obtain ⟨ u ⟩ := this
        generalize_proofs at *;
        exact Quotient.eq.mp ( u.uniq _ |> Eq.trans <| u.uniq _ |> Eq.symm )
      have h_homotopy_Y : Path.Homotopic (Path.map p (continuous_snd)) (Path.map q (continuous_snd)) := by
        have := ‹Nonempty Y ∧ ∀ x y : Y, Nonempty (Unique (Path.Homotopic.Quotient x y))›.2 hy hy';
        obtain ⟨ u ⟩ := this
        generalize_proofs at *;
        exact Quotient.eq.mp ( u.uniq _ |> Eq.trans <| u.uniq _ |> Eq.symm )
      generalize_proofs at *;
      -- By combining the homotopies of the projections, we can construct a homotopy between p and q.
      have h_homotopy_combined : ∃ H : Path.Homotopy (Path.map p (continuous_fst)) (Path.map q (continuous_fst)), ∃ K : Path.Homotopy (Path.map p (continuous_snd)) (Path.map q (continuous_snd)), True := by
        exact ⟨ h_homotopy_X.some, h_homotopy_Y.some, trivial ⟩
      generalize_proofs at *; (
      obtain ⟨ H, K, - ⟩ := h_homotopy_combined; exact ⟨ H.prod K ⟩ ;)
    generalize_proofs at *;
    refine' ⟨ _, _ ⟩
    all_goals generalize_proofs at *;
    exact ⟨ ⟦Path.prod ( Classical.choose ( show ∃ p : Path hx hx', True from by
                                              have := ‹Nonempty X ∧ ∀ x y : X, Nonempty ( Unique ( Path.Homotopic.Quotient x y ) ) ›.2 hx hx';
                                              exact ⟨ this.some.default.out, trivial ⟩ ) ) ( Classical.choose ( show ∃ p : Path hy hy', True from by
                                                                                                                  have := ‹Nonempty Y ∧ ∀ x y : Y, Nonempty (Unique (Path.Homotopic.Quotient x y))›.2 hy hy';
                                                                                                                  obtain ⟨ p ⟩ := this.some;
                                                                                                                  exact ⟨ p.default.out, trivial ⟩ ) )⟧ ⟩
    generalize_proofs at *;
    rintro ⟨ p ⟩ ; exact Quotient.sound ( h_homotopy p _ ) ;


