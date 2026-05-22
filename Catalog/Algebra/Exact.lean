/-
# Ramsey Theory: Exact Values

This module proves exact values of small Ramsey numbers:
* R(3,3) = 6 (upper bound from Erdős–Szekeres, lower bound via pentagon coloring)
* R(3,4) = 9 (upper bound via parity improvement, lower bound via 8-vertex construction)
-/
import Mathlib
import Algebra.Ramsey.Defs
import Algebra.Ramsey.Recursion

open Finset

/-! ## Decidability instances -/

instance (C : TwoColoring n) (S : Finset (Fin n)) : Decidable (IsRedClique C S) := by
  unfold IsRedClique; exact inferInstance

instance (C : TwoColoring n) (S : Finset (Fin n)) : Decidable (IsBlueClique C S) := by
  unfold IsBlueClique; exact inferInstance

/-! ## Base case: R(2, t) = t -/

/-
`RamseyProp t 2 t` for all `t`: in any 2-coloring of Kₜ,
    either some edge is red (red K₂) or all edges are blue (blue Kₜ).
-/
theorem RamseyProp_two_left (t : ℕ) : RamseyProp t 2 t := by
  intro C
  by_cases h : ∃ i j, i ≠ j ∧ C.color i j = true;
  · obtain ⟨ i, j, hij, h ⟩ := h; refine Or.inl ⟨ { i, j }, ?_, ?_ ⟩ <;> simp_all +decide [ IsRedClique ] ;
    exact fun _ => C.symm _ _ ▸ h;
  · refine Or.inr ⟨ Finset.univ, ?_, ?_ ⟩ <;> simp_all +decide [ IsBlueClique ]

/-! ## R(3,3) = 6 -/

/-- **Upper bound**: RamseyProp 6 3 3. -/
theorem ramsey_33_upper : RamseyProp 6 3 3 := by
  have h := RamseyProp_le_choose' (s := 3) (t := 3) (by omega) (by omega)
  simp only [show 3 + 3 - 2 = 4 from by omega, show 3 - 1 = 2 from by omega] at h
  exact h

/-- The pentagon (5-cycle) coloring on `Fin 5`. -/
def pentagonColoring : TwoColoring 5 where
  color i j :=
    let d := ((i.val : Int) - j.val).natAbs % 5
    d == 1 || d == 4
  symm i j := by
    simp only; congr 1 <;> (congr 1; omega)
  irrefl i := by simp

/-- The pentagon coloring avoids both red and blue triangles. -/
theorem pentagon_no_mono_triangle :
    (¬ ∃ S : Finset (Fin 5), S.card = 3 ∧ IsRedClique pentagonColoring S) ∧
    (¬ ∃ S : Finset (Fin 5), S.card = 3 ∧ IsBlueClique pentagonColoring S) :=
  ⟨by decide, by decide⟩

/-- **Lower bound**: ¬ RamseyProp 5 3 3. -/
theorem ramsey_33_lower : ¬ RamseyProp 5 3 3 := by
  intro h
  rcases h pentagonColoring with ⟨S, hc, hr⟩ | ⟨S, hc, hb⟩
  · exact pentagon_no_mono_triangle.1 ⟨S, hc, hr⟩
  · exact pentagon_no_mono_triangle.2 ⟨S, hc, hb⟩

/-- **R(3,3) = 6**: combining upper and lower bounds. -/
theorem ramsey_33_eq : RamseyProp 6 3 3 ∧ ¬ RamseyProp 5 3 3 :=
  ⟨ramsey_33_upper, ramsey_33_lower⟩

/-! ## Parity improvement and R(3,4) = 9 -/

/-- The red degree of vertex `v` in a 2-coloring of Kₙ. -/
def redDegree (C : TwoColoring n) (v : Fin n) : ℕ :=
  (Finset.univ.filter (fun w => w ≠ v ∧ C.color v w = true)).card

/-- The blue degree of vertex `v`. -/
def blueDegree (C : TwoColoring n) (v : Fin n) : ℕ :=
  (Finset.univ.filter (fun w => w ≠ v ∧ C.color v w = false)).card

/-
Red degree + blue degree = n - 1 for any vertex.
-/
theorem redDegree_add_blueDegree (C : TwoColoring n) (v : Fin n) (hn : 1 ≤ n) :
    redDegree C v + blueDegree C v = n - 1 := by
      -- The red neighbors and blue neighbors partition the set of all vertices except v.
      have h_partition : (Finset.univ.filter (fun w => w ≠ v ∧ C.color v w = true)) ∪ (Finset.univ.filter (fun w => w ≠ v ∧ C.color v w = false)) = Finset.univ.filter (fun w => w ≠ v) := by
        grind;
      convert congr_arg Finset.card h_partition using 1;
      · rw [ Finset.card_union_of_disjoint ];
        · unfold redDegree blueDegree; aesop;
        · exact Finset.disjoint_filter.mpr ( by aesop );
      · simp +decide [ Finset.filter_ne' ]

/-
The sum of red degrees equals twice the number of red edges.
-/
set_option maxHeartbeats 800000 in
theorem sum_redDegree_even (C : TwoColoring n) :
    Even (∑ v : Fin n, redDegree C v) := by
      -- Let's denote the number of red edges in the coloring by $E_r$.
      set Er := Finset.card (Finset.filter (fun (e : Fin n × Fin n) => C.color e.1 e.2 = true) (Finset.offDiag (Finset.univ : Finset (Fin n))));
      -- By definition of $Er$, we have $\sum_{v} \text{redDegree}(v) = Er$.
      have h_sum_redDegree : ∑ v, redDegree C v = Er := by
        simp +zetaDelta at *;
        simp +decide only [redDegree, card_filter];
        rw [ Finset.sum_sigma' ];
        rw [ ← Finset.sum_filter ];
        rw [ ← Finset.sum_filter ];
        refine' Finset.sum_bij ( fun x hx => ( x.1, x.2 ) ) _ _ _ _ <;> aesop;
      -- Since $Er$ is the number of red edges, it must be even.
      have h_even_Er : ∃ S : Finset (Fin n × Fin n), S = Finset.filter (fun (e : Fin n × Fin n) => C.color e.1 e.2 = true) (Finset.offDiag (Finset.univ : Finset (Fin n))) ∧ S.card = 2 * (Finset.card (Finset.filter (fun (e : Fin n × Fin n) => C.color e.1 e.2 = true ∧ e.1 < e.2) (Finset.offDiag (Finset.univ : Finset (Fin n))))) := by
        refine' ⟨ _, rfl, _ ⟩;
        have h_even_Er : Finset.filter (fun (e : Fin n × Fin n) => C.color e.1 e.2 = true) (Finset.offDiag (Finset.univ : Finset (Fin n))) = Finset.image (fun e => (e.1, e.2)) (Finset.filter (fun (e : Fin n × Fin n) => C.color e.1 e.2 = true ∧ e.1 < e.2) (Finset.offDiag (Finset.univ : Finset (Fin n)))) ∪ Finset.image (fun e => (e.2, e.1)) (Finset.filter (fun (e : Fin n × Fin n) => C.color e.1 e.2 = true ∧ e.1 < e.2) (Finset.offDiag (Finset.univ : Finset (Fin n)))) := by
          ext ⟨i, j⟩; simp [Finset.mem_union, Finset.mem_image];
          cases lt_trichotomy i j <;> simp_all +decide [ C.symm ];
          · exact fun _ _ _ => ne_of_lt ‹_›;
          · grind;
        rw [ h_even_Er, Finset.card_union_of_disjoint ];
        · rw [ two_mul, Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
        · norm_num [ Finset.disjoint_left ];
          bv_omega;
      grind

/-
**Parity improvement for Ramsey recursion**:
    If `a` and `b` are both even, then
    `RamseyProp (a + b - 1) s t` holds (one fewer than the basic recursion).

    The proof uses the handshaking lemma: if every vertex had exactly
    a-1 red neighbors and b-1 blue neighbors, the total red degree
    sum would be (a+b-1)(a-1), which is odd when a,b are even.
    This contradicts the handshaking lemma.
-/
set_option maxHeartbeats 1600000 in
theorem RamseyProp_recursion_parity {a b s t : ℕ} (hs : 2 ≤ s) (ht : 2 ≤ t)
    (ha_even : Even a) (hb_even : Even b) (ha_pos : 1 ≤ a) (hb_pos : 1 ≤ b)
    (hred : RamseyProp a (s - 1) t) (hblue : RamseyProp b s (t - 1)) :
    RamseyProp (a + b - 1) s t := by
      intro C
      by_contra h_contra
      push_neg at h_contra
      have h_deg : ∀ v : Fin (a + b - 1), redDegree C v < a ∧ blueDegree C v < b := by
        intro v
        constructor
        ·
          by_cases h_red_deg : redDegree C v ≥ a;
          · -- Let $S$ be the set of red neighbors of $v$.
            obtain ⟨S, hS⟩ : ∃ S : Finset (Fin (a + b - 1)), S.card = a ∧ ∀ w ∈ S, w ≠ v ∧ C.color v w = true := by
              have := Finset.exists_subset_card_eq h_red_deg;
              exact ⟨ this.choose, this.choose_spec.2, fun w hw => Finset.mem_filter.mp ( this.choose_spec.1 hw ) |>.2 ⟩;
            -- Since $S$ is a set of $a$ vertices, we can apply the hypothesis $hred$ to find a red $(s-1)$-clique or a blue $t$-clique in $S$.
            obtain ⟨T, hT⟩ : ∃ T : Finset (Fin (a + b - 1)), T ⊆ S ∧ (T.card = s - 1 ∧ IsRedClique C T) ∨ (T.card = t ∧ IsBlueClique C T) := by
              have := hred ( TwoColoring.restrict C ( fun i => S.orderEmbOfFin hS.1 i ) ( by simp +decide [ Function.Injective ] ) );
              rcases this with ( ⟨ T, hT₁, hT₂ ⟩ | ⟨ T, hT₁, hT₂ ⟩ ) <;> [ refine' ⟨ T.image ( fun i => S.orderEmbOfFin hS.1 i ), Or.inl ⟨ _, _, _ ⟩ ⟩ ; refine' ⟨ T.image ( fun i => S.orderEmbOfFin hS.1 i ), Or.inr ⟨ _, _ ⟩ ⟩ ] <;> simp_all +decide [ Finset.card_image_of_injective, Function.Injective ];
              · exact Finset.image_subset_iff.mpr fun i hi => Finset.orderEmbOfFin_mem _ _ _;
              · convert IsRedClique_map hT₂ using 1;
                grind;
              · convert IsBlueClique_map hT₂ using 1;
                grind;
            rcases hT with ( ⟨ hT₁, hT₂, hT₃ ⟩ | ⟨ hT₂, hT₃ ⟩ ) <;> simp_all +decide [ Finset.subset_iff ];
            refine' False.elim ( h_contra.1 ( Insert.insert v T ) _ _ ) <;> simp_all +decide [ Finset.card_insert_of_notMem, IsRedClique ];
            · grind +revert;
            · exact fun x hx => C.symm x v ▸ hS.2 x ( hT₁ hx ) |>.2;
          · exact lt_of_not_ge h_red_deg
        ·
          by_cases h_blue_deg : blueDegree C v ≥ b;
          · -- Let $B$ be the set of blue neighbors of $v$.
            obtain ⟨B, hB⟩ : ∃ B : Finset (Fin (a + b - 1)), B.card = b ∧ ∀ w ∈ B, w ≠ v ∧ C.color v w = false := by
              obtain ⟨ B, hB ⟩ := Finset.exists_subset_card_eq h_blue_deg;
              exact ⟨ B, hB.2, fun w hw => Finset.mem_filter.mp ( hB.1 hw ) |>.2 ⟩;
            -- Consider the restriction of $C$ to $B$.
            set C' : TwoColoring b := TwoColoring.restrict C (fun i => B.orderEmbOfFin (by aesop) i) (by
            exact fun i j hij => by simpa [ Fin.ext_iff ] using hij;)
            generalize_proofs at *;
            -- By the induction hypothesis, $C'$ contains either a red $s$-clique or a blue $(t-1)$-clique.
            obtain ⟨S, hS⟩ : ∃ S : Finset (Fin b), S.card = s ∧ IsRedClique C' S ∨ ∃ S : Finset (Fin b), S.card = t - 1 ∧ IsBlueClique C' S := by
              exact hblue C' |> fun h => h.elim ( fun ⟨ S, hS₁, hS₂ ⟩ => ⟨ S, Or.inl ⟨ hS₁, hS₂ ⟩ ⟩ ) fun ⟨ S, hS₁, hS₂ ⟩ => ⟨ S, Or.inr ⟨ S, hS₁, hS₂ ⟩ ⟩;
            rcases hS with ( ⟨ hS₁, hS₂ ⟩ | ⟨ S, hS₁, hS₂ ⟩ );
            · exact False.elim <| h_contra.1 ( S.map ⟨ _, ‹_› ⟩ ) ( by simpa [ Finset.card_image_of_injective _ ‹_› ] using hS₁ ) <| IsRedClique_map hS₂;
            · -- Adding $v$ to $S$ gives a blue $t$-clique in $C$.
              have h_blue_clique : IsBlueClique C (Finset.image (fun i => B.orderEmbOfFin (by aesop) i) S ∪ {v}) := by
                intro i hi j hj hij; simp_all +decide [ IsBlueClique ] ;
                rcases hi with ( rfl | ⟨ i, hi, rfl ⟩ ) <;> rcases hj with ( rfl | ⟨ j, hj, rfl ⟩ ) <;> simp_all +decide [ TwoColoring.restrict ];
                · rw [ C.symm ] ; aesop;
                · exact hS₂ i hi j hj hij
              generalize_proofs at *;
              have h_card : (Finset.image (fun i => B.orderEmbOfFin (by aesop) i) S ∪ {v}).card = t := by
                rw [ Finset.card_union ] ; simp +decide [ *, Finset.card_image_of_injective ];
                grind +splitIndPred
              generalize_proofs at *;
              exact False.elim <| h_contra.2 _ h_card h_blue_clique;
          · exact lt_of_not_ge h_blue_deg
      have h_deg_eq : ∀ v : Fin (a + b - 1), redDegree C v = a - 1 := by
        intro v
        have h_sum : redDegree C v + blueDegree C v = a + b - 2 := by
          convert redDegree_add_blueDegree C v _ using 1;
          omega;
        grind +splitImp
      have h_sum_redDegree_odd : Odd (∑ v : Fin (a + b - 1), redDegree C v) := by
        rcases a with ( _ | _ | a ) <;> simp_all +decide [ parity_simps ]
      exact absurd h_sum_redDegree_odd (by
      exact Nat.not_odd_iff_even.mpr ( sum_redDegree_even C ))

/-- **Upper bound**: RamseyProp 9 3 4.
    Uses the parity improvement with R(2,4) = 4 (even) and R(3,3) = 6 (even).
    So R(3,4) ≤ 4 + 6 - 1 = 9. -/
theorem ramsey_34_upper : RamseyProp 9 3 4 := by
  have hparity := @RamseyProp_recursion_parity 4 6 3 4
    (by omega) (by omega) ⟨2, rfl⟩ ⟨3, rfl⟩ (by omega) (by omega)
  simp only [show 3 - 1 = 2 from rfl, show 4 - 1 = 3 from rfl,
             show 4 + 6 - 1 = 9 from rfl] at hparity
  exact hparity (RamseyProp_two_left 4) ramsey_33_upper

/-- A lookup-table coloring of K₈ avoiding red K₃ and blue K₄.
    Based on Cayley graph of ℤ/8ℤ with red differences {1, 4, 7}. -/
private def c8_table : Fin 8 → Fin 8 → Bool := fun i j =>
  -- Matrix entries for i < j, symmetrized
  let p := (min i.val j.val, max i.val j.val)
  match p with
  | (0,1) => true  | (0,2) => false | (0,3) => false
  | (0,4) => true  | (0,5) => false | (0,6) => false | (0,7) => true
  | (1,2) => true  | (1,3) => false
  | (1,4) => false | (1,5) => true  | (1,6) => false | (1,7) => false
  | (2,3) => true
  | (2,4) => false | (2,5) => false | (2,6) => true  | (2,7) => false
  | (3,4) => true  | (3,5) => false | (3,6) => false | (3,7) => true
  | (4,5) => true  | (4,6) => false | (4,7) => false
  | (5,6) => true  | (5,7) => false
  | (6,7) => true
  | _ => false

private theorem c8_symm : ∀ i j : Fin 8, c8_table i j = c8_table j i := by decide
private theorem c8_irrefl : ∀ i : Fin 8, c8_table i i = false := by decide

def coloring8 : TwoColoring 8 where
  color := c8_table
  symm := c8_symm
  irrefl := c8_irrefl

/-- The 8-vertex coloring has no red K₃. -/
theorem coloring8_no_red_triangle :
    ¬ ∃ S : Finset (Fin 8), S.card = 3 ∧ IsRedClique coloring8 S := by
  native_decide

/-- The 8-vertex coloring has no blue K₄. -/
theorem coloring8_no_blue_K4 :
    ¬ ∃ S : Finset (Fin 8), S.card = 4 ∧ IsBlueClique coloring8 S := by
  native_decide

/-- **Lower bound**: ¬ RamseyProp 8 3 4. -/
theorem ramsey_34_lower : ¬ RamseyProp 8 3 4 := by
  intro h
  rcases h coloring8 with ⟨S, hc, hr⟩ | ⟨S, hc, hb⟩
  · exact coloring8_no_red_triangle ⟨S, hc, hr⟩
  · exact coloring8_no_blue_K4 ⟨S, hc, hb⟩

/-- **R(3,4) = 9**: combining upper and lower bounds. -/
theorem ramsey_34_eq : RamseyProp 9 3 4 ∧ ¬ RamseyProp 8 3 4 :=
  ⟨ramsey_34_upper, ramsey_34_lower⟩