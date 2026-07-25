import Mathlib
import Applications.ProductHiltonMilnerLarge

/-!
# Stable Kneser families: spacing, colouring, and intersecting fibres

For a finite subset of `[n]`, linear `s`-stability requires successive selected
positions to be separated by at least `s`.  Cyclic stability implies this linear
condition, so the results below apply in particular to the stable sets occurring
in stable Kneser graphs.

The central argument is the extremal spacing estimate
`1 + s (k - 1) ≤ n`.  Applied after deleting an initial segment, it shows that
every stable `k`-set has a selected point among the first `n-sk+s` positions.
Colouring by the least such point is proper for the disjointness graph.  The
colour classes are intersecting uniform families, linking stable Kneser
colouring to the Hilton–Milner framework.

-- !-- Lab Notes -- !--
-- !-- Hypothesis (ranked by expected impact; cross-domain bridge category):
--     (1) Meunier's equality holds for every `s ≥ 2` and `n ≥ sk`;
--     (2) a cyclic Hilton–Milner theorem determines every largest non-star
--         intersecting stable family;
--     (3) the chromatic lower bound admits a common combinatorial-topological
--         certificate through equivariant index;
--     (4) for `s = 3`, all equality colourings are governed by initial-segment
--         fibres once `n` is sufficiently large;
--     (5) least-element fibres satisfy a stability-sensitive EKR bound;
--     (6) the least-element construction supplies `n-sk+s` colours for every
--         linearly stable family.  The present cycle proves (6) and the upper
--         bound portion of (1), and isolates the Hilton–Milner bridge in (5). -- !--
-- !-- Experiment: The claim was reduced to a sharp one-dimensional packing
--     inequality for finite subsets of `Fin n`, then tested against the boundary
--     configuration `{a, a+s, ..., a+s(k-1)}` where equality holds. -- !--
-- !-- Analysis: Stability converts geometric separation into an arithmetic
--     cardinality bound.  Once the least element is forced into the initial
--     segment, disjoint sets cannot receive the same colour because both contain
--     their common least element. -- !--
-- !-- Critique: Linear stability is weaker than cyclic stability, hence the
--     upper-bound theorem is robust, but it does not prove the difficult matching
--     chromatic lower bound.  The degenerate case `k=0` is excluded explicitly,
--     and natural-number subtraction is controlled by `s*k ≤ n+s`. -- !--
-- !-- Synthesis: Stable-set packing yields a canonical partition into
--     intersecting uniform fibres, placing the colouring construction directly
--     inside the Hilton–Milner language. -- !--
-/

namespace StableKneser

open Finset

/-- A finite set is linearly `s`-stable if any two selected positions, in
increasing order, differ by at least `s`. -/
def IsLinearStable {n : ℕ} (s : ℕ) (A : Finset (Fin n)) : Prop :=
  ∀ ⦃x⦄, x ∈ A → ∀ ⦃y⦄, y ∈ A → x < y → x.val + s ≤ y.val

/-- Cyclic `s`-stability additionally requires the wrap-around gap to be at
least `s`. -/
def IsCyclicStable {n : ℕ} (s : ℕ) (A : Finset (Fin n)) : Prop :=
  ∀ ⦃x⦄, x ∈ A → ∀ ⦃y⦄, y ∈ A → x < y →
    x.val + s ≤ y.val ∧ y.val + s ≤ n + x.val

/-
Cyclic stability implies linear stability.
-/
theorem cyclicStable_isLinearStable {n s : ℕ} {A : Finset (Fin n)}
    (h : IsCyclicStable s A) : IsLinearStable s A := by
  grind +locals

/-- A uniform stable family. -/
def StableUniformFamily (n k s : ℕ) :=
  {A : Finset (Fin n) // A.card = k ∧ IsLinearStable s A}

/-- A family colouring is proper for the Kneser disjointness relation when
sets of the same colour always intersect. -/
def ProperFamilyColoring {n q : ℕ} (F : Finset (Finset (Fin n)))
    (c : Finset (Fin n) → Fin q) : Prop :=
  ∀ A ∈ F, ∀ B ∈ F, c A = c B → (A ∩ B).Nonempty

/-
The sharp linear packing inequality for stable finite subsets.
-/
theorem stable_cardinality_bound {n s : ℕ} {A : Finset (Fin n)}
    (hA : A.Nonempty) (hst : IsLinearStable s A) :
    s * (A.card - 1) + 1 ≤ n := by
  -- List the elements of A in increasing order.
  obtain ⟨g, hg⟩ : ∃ g : Fin A.card → Fin n, StrictMono g ∧ ∀ i, g i ∈ A := by
    exact ⟨ fun i => A.orderEmbOfFin rfl i, by simp +decide [ StrictMono ], fun i => A.orderEmbOfFin_mem rfl _ ⟩;
  -- By induction on the elements of $g$, we can show that $g i \geq i * s + 1$ for all $i$.
  have h_ind : ∀ i : Fin A.card, (g i).val ≥ i.val * s := by
    intro ⟨ i, hi ⟩ ; induction' i with i ih;
    · norm_num;
    · have := hst ( hg.2 ⟨ i, by linarith ⟩ ) ( hg.2 ⟨ i + 1, by linarith ⟩ ) ( hg.1 ( Nat.lt_succ_self _ ) ) ; norm_num at * ; linarith [ ih ( by linarith ) ] ;
  rcases k : Finset.card A with ( _ | _ | k ) <;> simp_all +decide [ mul_comm ];
  · exact Fin.pos ( Classical.choose hA );
  · exact lt_of_le_of_lt ( h_ind ⟨ _, by linarith ⟩ ) ( Fin.is_lt _ )

/-
Every stable `k`-set has its least element in the initial segment of length
`n-sk+s`.  This is the arithmetic core of the stable-Kneser upper colouring.
-/
theorem min_le_stable_cutoff {n k s : ℕ} {A : Finset (Fin n)}
    (hk : 1 ≤ k) (hA : A.card = k) (hst : IsLinearStable s A)
    (hroom : s * k ≤ n + s) :
    (A.min' (by
      rw [Finset.nonempty_iff_ne_empty]
      intro hzero
      have : A.card = 0 := by simp [hzero]
      omega)).val < n - s * k + s := by
  generalize_proofs at *;
  obtain ⟨a, ha⟩ : ∃ a : Fin n, a ∈ A ∧ ∀ b ∈ A, a ≤ b := by
    exact ⟨ Finset.min' A ‹_›, Finset.min'_mem _ _, fun b hb => Finset.min'_le _ _ hb ⟩
  generalize_proofs at *;
  obtain ⟨l, hl⟩ : ∃ l : Fin k → Fin n, (∀ i, l i ∈ A) ∧ StrictMono l := by
    exact ⟨ fun i => A.orderEmbOfFin ( by aesop ) i, fun i => by aesop, by aesop_cat ⟩
  generalize_proofs at *;
  -- By definition of $l$, we know that $l i ≥ a + s * i$ for all $i$.
  have h_l_ge : ∀ i : Fin k, (l i).val ≥ a.val + s * i.val := by
    intro i
    induction' i with i ih
    generalize_proofs at *;
    induction' i with i ih;
    · aesop;
    · have := hst ( hl.1 ⟨ i, by linarith ⟩ ) ( hl.1 ⟨ i + 1, by linarith ⟩ ) ( hl.2 ( Nat.lt_succ_self _ ) ) ; simp_all +decide [ Nat.mul_succ ] ; linarith [ ‹∀ ( ih : i < k ), ( l ⟨ i, ih ⟩ : ℕ ) ≥ a + s * i› ( by linarith ) ] ;
  generalize_proofs at *;
  rcases k with ( _ | k ) <;> simp_all +decide [ Finset.min' ];
  rw [ show A.inf' ( by aesop ) ( fun x => x ) = a from ?_ ];
  · have := h_l_ge ( Fin.last k ) ; simp_all +decide [ mul_add ] ; omega;
  · exact le_antisymm ( Finset.inf'_le _ ha.1 ) ( Finset.le_inf' _ _ fun x hx => ha.2 x hx )

/-
The least-element map is a proper colouring whenever all sets have a least
point below `q`.
-/
theorem min_coloring_proper {n q : ℕ} {F : Finset (Finset (Fin n))}
    (hq : 0 < q) (hne : ∀ A ∈ F, A.Nonempty)
    (hmin : ∀ A (hA : A ∈ F), (A.min' (hne A hA)).val < q) :
    ∃ c : Finset (Fin n) → Fin q, ProperFamilyColoring F c := by
  use fun A => if hA : A ∈ F then Fin.mk ( A.min' ( hne A hA ) |> Fin.val ) ( hmin A hA ) else ⟨ 0, hq ⟩;
  intro A hA B hB hAB; simp_all +decide [ Fin.ext_iff ] ;
  exact ⟨ _, Finset.mem_inter.mpr ⟨ Finset.min'_mem _ _, by rw [ Fin.ext hAB ] ; exact Finset.min'_mem _ _ ⟩ ⟩

/-
**Stable-Kneser upper colouring theorem.** A `k`-uniform linearly
`s`-stable family on `[n]` admits a proper colouring with `n-sk+s` colours.
Cyclically stable families satisfy the linear stability hypothesis, so this is
the standard upper-bound half of Meunier's predicted formula.
-/
theorem stableKneser_upper_coloring {n k s : ℕ}
    (hk : 1 ≤ k) (hs : 1 ≤ s) (hroom : s * k ≤ n)
    (F : Finset (Finset (Fin n)))
    (hunif : ProductHiltonMilner.IsUniform k F)
    (hstable : ∀ A ∈ F, IsLinearStable s A) :
    ∃ c : Finset (Fin n) → Fin (n - s * k + s), ProperFamilyColoring F c := by
  convert min_coloring_proper _ _ _ using 1;
  exact Nat.add_pos_right (n - s * k) hs;
  exact fun A hA => Finset.card_pos.mp ( by rw [ hunif A hA ] ; linarith );
  exact fun A hA => min_le_stable_cutoff hk ( hunif A hA ) ( hstable A hA ) ( by omega )

/-
Every colour fibre of a proper stable-Kneser colouring is an intersecting
uniform family in the Hilton–Milner sense.  This is the bridge from graph
colouring to extremal set theory used by Hilton–Milner arguments.
-/
theorem colorFiber_uniform_intersecting {n k q : ℕ}
    {F : Finset (Finset (Fin n))} (hunif : ProductHiltonMilner.IsUniform k F)
    {c : Finset (Fin n) → Fin q} (hc : ProperFamilyColoring F c) (i : Fin q) :
    ProductHiltonMilner.IsUniform k (F.filter fun A => c A = i) ∧
      (∀ A ∈ F.filter (fun A => c A = i),
        ∀ B ∈ F.filter (fun A => c A = i), (A ∩ B).Nonempty) := by
  exact ⟨ fun A hA => hunif A ( Finset.filter_subset _ _ hA ), fun A hA B hB => hc A ( Finset.filter_subset _ _ hA ) B ( Finset.filter_subset _ _ hB ) ( by aesop ) ⟩

/-
**Cyclic stable-Kneser upper colouring.** For the cyclic stability notion
used in stable Kneser graphs, every `k`-uniform family has the conjectured
`n-sk+s`-colour upper bound.
-/
theorem cyclicStableKneser_upper_coloring {n k s : ℕ}
    (hk : 1 ≤ k) (hs : 1 ≤ s) (hroom : s * k ≤ n)
    (F : Finset (Finset (Fin n)))
    (hunif : ProductHiltonMilner.IsUniform k F)
    (hstable : ∀ A ∈ F, IsCyclicStable s A) :
    ∃ c : Finset (Fin n) → Fin (n - s * k + s), ProperFamilyColoring F c := by
  convert stableKneser_upper_coloring hk hs hroom F hunif ( fun A hA => cyclicStable_isLinearStable ( hstable A hA ) )

end StableKneser