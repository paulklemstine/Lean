import Mathlib

/-!
# Hypergraph Ramsey Theory: A Builder's Chain

This file develops, from first principles, the combinatorial framework of
`r`-uniform hypergraph Ramsey theory and proves a connected chain of results,
each building on the previous one.

The setting is a 2-coloring `C : Finset (Fin n) → Bool` of the subsets of an
`n`-element set (only the values on `r`-element subsets matter).  A set `S` is
*`b`-homogeneous* if every `r`-subset of `S` has color `b`; a *`b`-clique of
size `k`* is a `b`-homogeneous set of cardinality `k`.  The **Ramsey property**
`RamseyProp r k l n` says that *every* coloring of the `r`-subsets of `Fin n`
contains a red (`true`) clique of size `k` or a blue (`false`) clique of size
`l`.  This is the `r`-uniform generalization of the classical graph case
`r = 2`.

## The chain

1. `IsHomog.subset`      — homogeneity is closed under taking subsets.
2. `HasClique.mono`      — a clique contains sub-cliques (uses 1).
3. `RamseyProp.mono_left` / `RamseyProp.mono_right`
                         — the Ramsey property is monotone downward in the
                           clique sizes (uses 2).
4. `RamseyProp.symm`     — swapping colors swaps the two clique parameters.
5. `RamseyProp.mono_n`   — the Ramsey property is monotone in the ground size
                           `n` (restrict/extend the coloring).
6. `RamseyProp_of_lt_r`  — the degenerate regime `k < r`: cliques smaller than
                           the uniformity are free.
7. `RamseyProp_r_l_upper`— boundary upper bound: `R_r(r,l) ≤ l`.
8. `not_RamseyProp_r_l`  — boundary lower bound: `R_r(r,l) > l - 1`.
9. `RamseyNumber_r_l`    — **exact boundary value** `R_r(r,l) = l` (uses 7,8).
   with corollaries `RamseyNumber_diag_eq`, `R3_3_3`, `R2_2_2`, and the concrete
   witnesses `RamseyProp_3_3_3_3`, `not_RamseyProp_3_3_3_2`.

## Growth theme

A second short chain (`tower`, `tower_two_strict_mono`, `four_pow_lt_tower`)
records the tower/double-exponential function that governs the *conjectured*
growth of the diagonal `R_3(k,k)`, and shows it eventually dominates the
Erdős–Szekeres graph bound `4^k`, formalizing the sense in which 3-uniform
Ramsey numbers are believed to outgrow graph Ramsey numbers.
-/

open Finset

namespace HypergraphRamsey

/-- A 2-coloring of the subsets of `Fin n`.  Only the values on `r`-element
subsets are used by the Ramsey property below. -/
abbrev Coloring (n : ℕ) := Finset (Fin n) → Bool

/-- `S` is `b`-homogeneous for `r`-subsets under `C`: every `r`-element subset of
`S` receives color `b`. -/
def IsHomog {n : ℕ} (r : ℕ) (C : Coloring n) (b : Bool) (S : Finset (Fin n)) : Prop :=
  ∀ e ⊆ S, e.card = r → C e = b

/-- There is a `b`-monochromatic clique of size `k`: a set of cardinality `k`
all of whose `r`-subsets are colored `b`. -/
def HasClique {n : ℕ} (r : ℕ) (C : Coloring n) (b : Bool) (k : ℕ) : Prop :=
  ∃ S : Finset (Fin n), S.card = k ∧ IsHomog r C b S

/-- The `r`-uniform Ramsey property: every 2-coloring of the `r`-subsets of
`Fin n` contains a red clique of size `k` or a blue clique of size `l`. -/
def RamseyProp (r k l n : ℕ) : Prop :=
  ∀ C : Coloring n, HasClique r C true k ∨ HasClique r C false l

/-! ## 1. Homogeneity is closed under subsets -/

theorem IsHomog.subset {n r : ℕ} {C : Coloring n} {b : Bool} {S T : Finset (Fin n)}
    (h : IsHomog r C b S) (hTS : T ⊆ S) : IsHomog r C b T :=
  fun e he hcard => h e (he.trans hTS) hcard

/-! ## 2. A clique contains sub-cliques -/

theorem HasClique.mono {n r : ℕ} {C : Coloring n} {b : Bool} {k j : ℕ}
    (h : HasClique r C b k) (hj : j ≤ k) : HasClique r C b j := by
  obtain ⟨ S, hS₁, hS₂ ⟩ := h; rcases Finset.exists_subset_card_eq ( by linarith : j ≤ Finset.card S ) with ⟨ T, hT₁, hT₂ ⟩ ; exact ⟨ T, hT₂, by exact fun e he he' ↦ hS₂ e ( Finset.Subset.trans he hT₁ ) he' ⟩ ;

/-! ## 3. Monotonicity of the Ramsey property in the clique sizes -/

theorem RamseyProp.mono_left {r k l n : ℕ} (h : RamseyProp r k l n) {j : ℕ}
    (hj : j ≤ k) : RamseyProp r j l n :=
  fun C => (h C).imp (fun hc => hc.mono hj) id

theorem RamseyProp.mono_right {r k l n : ℕ} (h : RamseyProp r k l n) {j : ℕ}
    (hj : j ≤ l) : RamseyProp r k j n :=
  fun C => (h C).imp id (fun hc => hc.mono hj)

/-! ## 4. Color-swap symmetry -/

theorem RamseyProp.symm {r k l n : ℕ} (h : RamseyProp r k l n) :
    RamseyProp r l k n := by
  -- We reduce to the symmetric case by
  intro C
  specialize h (fun e => ! C e)
  cases' h with hC hC <;> [right; left] <;> rcases hC with ⟨S, hS⟩ <;> use S <;> simp_all +decide [ IsHomog ]

/-! ## 5. Monotonicity in the ground-set size -/

theorem RamseyProp.mono_n {r k l n m : ℕ} (h : RamseyProp r k l n) (hnm : n ≤ m) :
    RamseyProp r k l m := by
  intro C;
  -- Define the restricted coloring C' : Coloring n by C' e := C (e.map emb).
  set C' : Coloring n := fun e => C (e.map (Fin.castLEEmb hnm));
  cases' h C' with h h <;> [ left; right ] <;> rcases h with ⟨ S, hS₁, hS₂ ⟩ <;> use S.map ( Fin.castLEEmb hnm ) ; simp_all +decide [ IsHomog ];
  · intro e he₁ he₂; rw [ Finset.subset_map_iff ] at he₁; obtain ⟨ t, ht₁, rfl ⟩ := he₁; aesop;
  · simp_all +decide [ IsHomog ];
    intro e he₁ he₂; rw [ Finset.subset_map_iff ] at he₁; obtain ⟨ t, ht₁, ht₂ ⟩ := he₁; aesop;

/-! ## 6. The degenerate regime `k < r` -/

/-
If the clique size is smaller than the uniformity, cliques are free: a
`k`-set with `k < r` has no `r`-subsets, so it is vacuously red-homogeneous.
-/
theorem RamseyProp_of_lt_r {r k l n : ℕ} (hk : k < r) (hn : k ≤ n) :
    RamseyProp r k l n := by
  intro C
  by_contra h_contra
  push_neg at h_contra
  obtain ⟨h_red, h_blue⟩ := h_contra;
  obtain ⟨S, hS⟩ : ∃ S : Finset (Fin n), S.card = k := by
    exact Exists.imp ( by aesop ) ( Finset.exists_subset_card_eq ( show k ≤ Finset.card ( Finset.univ : Finset ( Fin n ) ) from by simpa ) );
  exact h_red ⟨ S, hS, fun e he he' => by linarith [ Finset.card_le_card he ] ⟩

/-! ## 7. Boundary upper bound `R_r(r,l) ≤ l` -/

/-
If `r ≤ l ≤ n`, then `RamseyProp r r l n` holds: either some `r`-subset is
red (a red `r`-clique), or all are blue (any `l`-set is a blue `l`-clique).
-/
theorem RamseyProp_r_l_upper {r l n : ℕ} (hrl : r ≤ l) (hln : l ≤ n) :
    RamseyProp r r l n := by
  intro C
  by_cases hred : ∃ e : Finset (Fin n), e.card = r ∧ C e = true;
  · obtain ⟨ e, he ⟩ := hred;
    exact Or.inl ⟨ e, he.1, fun f hf hf' => by have := Finset.eq_of_subset_of_card_le hf ( by aesop ) ; aesop ⟩;
  · obtain ⟨ S, hS₁, hS₂ ⟩ := Finset.exists_subset_card_eq ( show l ≤ Finset.card ( Finset.univ : Finset ( Fin n ) ) from by simpa using hln );
    exact Or.inr ⟨ S, hS₂, fun e he₁ he₂ => by_contradiction fun he₃ => hred ⟨ e, he₂, by aesop ⟩ ⟩

/-! ## 8. Boundary lower bound `R_r(r,l) > l - 1` -/

/-
If `n < l`, then `RamseyProp r r l n` fails: color everything blue; there is
no red `r`-clique and no room for a blue `l`-clique.
-/
theorem not_RamseyProp_r_l {r l n : ℕ} (hn : n < l) : ¬ RamseyProp r r l n := by
  unfold RamseyProp;
  simp +zetaDelta at *;
  use fun _ => false;
  constructor <;> intro h <;> obtain ⟨ S, hS₁, hS₂ ⟩ := h <;> have := hS₂ S ( Finset.Subset.refl _ ) <;> simp_all +decide;
  exact hn.not_ge ( hS₁ ▸ le_trans ( Finset.card_le_univ _ ) ( by norm_num ) )

/-! ## 9. The exact boundary Ramsey number -/

/-- The `r`-uniform Ramsey number `R_r(k,l)`: the least `n` for which the Ramsey
property holds (junk value `0` if it never holds). -/
noncomputable def RamseyNumber (r k l : ℕ) : ℕ := sInf {n | RamseyProp r k l n}

/-
**Exact boundary value**: `R_r(r,l) = l` for `r ≤ l`.  This pins down the
first genuinely non-trivial family of hypergraph Ramsey numbers, combining the
matching bounds (7) and (8).
-/
theorem RamseyNumber_r_l {r l : ℕ} (hrl : r ≤ l) : RamseyNumber r r l = l := by
  refine' le_antisymm ( Nat.sInf_le <| _ ) ( le_csInf _ _ );
  · exact RamseyProp_r_l_upper hrl le_rfl;
  · exact ⟨ l, RamseyProp_r_l_upper hrl le_rfl ⟩;
  · exact fun n hn => le_of_not_gt fun h => not_RamseyProp_r_l h hn

/-- Diagonal specialization: `R_r(r,r) = r`. -/
theorem RamseyNumber_diag_eq (r : ℕ) : RamseyNumber r r r = r :=
  RamseyNumber_r_l (le_refl r)

/-- `R_3(3,3) = 3`: a single 3-edge is already a monochromatic 3-clique. -/
theorem R3_3_3 : RamseyNumber 3 3 3 = 3 := RamseyNumber_diag_eq 3

/-- `R_2(2,2) = 2`: the graph edge case — two vertices force a monochromatic
edge. -/
theorem R2_2_2 : RamseyNumber 2 2 2 = 2 := RamseyNumber_diag_eq 2

/-- Concrete witness of the upper bound at `n = 3`. -/
theorem RamseyProp_3_3_3_3 : RamseyProp 3 3 3 3 :=
  RamseyProp_r_l_upper (le_refl 3) (le_refl 3)

/-- Concrete witness of the lower bound: `n = 2` is too small. -/
theorem not_RamseyProp_3_3_3_2 : ¬ RamseyProp 3 3 3 2 :=
  not_RamseyProp_r_l (by norm_num)

/-! ## Growth theme: the tower (double-exponential) function

The diagonal number `R_3(k,k)` is conjectured to grow like a tower of height 2,
i.e. double-exponentially, in contrast to the single-exponential graph bound
`R_2(k,k) ≤ 4^k`.  We record the tower function and show it eventually beats
`4^k`, formalizing the sense of the conjectured separation. -/

/-- `tower b k = b ^ b ^ ⋯ ^ b` with `k` copies of `b` (`tower b 0 = 1`). -/
def tower (b : ℕ) : ℕ → ℕ
  | 0 => 1
  | (k + 1) => b ^ (tower b k)

@[simp] theorem tower_zero (b : ℕ) : tower b 0 = 1 := rfl
@[simp] theorem tower_succ (b k : ℕ) : tower b (k + 1) = b ^ (tower b k) := rfl

theorem tower_pos {b : ℕ} (hb : 0 < b) (k : ℕ) : 0 < tower b k := by
  induction k <;> aesop

/-
The height-2 tower is strictly increasing.
-/
theorem tower_two_strict_mono (k : ℕ) : tower 2 k < tower 2 (k + 1) := by
  -- By definition of exponentiation, we know that $2^{tower 2 k} > tower 2 k$ for any $k$.
  have h_exp : ∀ k : ℕ, 2 ^ (tower 2 k) > tower 2 k := by
    exact fun k => Nat.recOn ( tower 2 k ) ( by norm_num ) fun n ih => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] ;
  exact h_exp k

/-
For `k ≥ 5`, the tower `tower 2 k` strictly dominates the Erdős–Szekeres
graph bound `4^k`, formalizing the conjectured double-exponential separation of
3-uniform from graph Ramsey numbers.
-/
theorem four_pow_lt_tower (k : ℕ) (hk : 5 ≤ k) : 4 ^ k < tower 2 k := by
  induction' hk with k hk ih;
  · native_decide;
  · rw [ pow_succ', tower_succ ];
    refine' lt_of_lt_of_le _ ( pow_le_pow_right₀ ( by decide ) ih );
    refine' Nat.le_induction _ _ _ ( show 4 ^ k ≥ 5 by exact le_trans ( by decide ) ( Nat.pow_le_pow_right ( by decide ) hk ) ) <;> norm_num [ Nat.pow_succ ];
    lia

end HypergraphRamsey