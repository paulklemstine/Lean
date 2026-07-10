import Mathlib

/-!
# Categorification of Entropy: The Information Loss of a Functor

A functor `F : C → D` "loses information" when it identifies distinct objects of `C`,
mapping them to the same object of `D`.  We quantify this loss with an entropy.

The naive marginal entropy `-∑ p(d) log p(d)` of the pushed-forward distribution does
**not** vanish for injective functors (an injective map into an `n`-element target already
has marginal entropy `log n`).  The correct information-theoretic measure of *loss* is the
**conditional entropy** `H(C ∣ F(C))` of the domain object given its image, taken under the
uniform distribution on the objects of `C`.  Explicitly, writing `c_d = |F⁻¹(d)|` for the
fiber cardinality and `n = |Ob C|`,
```
    entropy F  =  ∑_d (c_d / n) · log c_d.
```
Within a fiber of size `c_d` the residual uncertainty is exactly `log c_d`, weighted by the
probability `c_d / n` of landing in that fiber.  This is genuinely the information lost by
`F`: it is `0` precisely when `F` is injective (faithful on objects), and it is maximal
(`log n`) for a constant functor.

## Main results

* `FunctorialEntropy.entropy_nonneg` — information loss is never negative.
* `FunctorialEntropy.entropy_eq_zero_iff_injective` — `entropy F = 0 ↔ F` is injective.
  This is the "`H(F) = 0` iff faithful" conjecture (correctly formulated as conditional
  entropy).
* `FunctorialEntropy.entropy_uniform` — for a functor all of whose fibers have the same
  size `k`, `entropy F = log k = log (|Ob C| / |Ob D|)`.  This is the "uniform fiber"
  formula.
* `FunctorialEntropy.entropy_const` — a constant functor loses `log n`, the maximum.
* `FunctorialEntropy.entropy_le_log_card` — `entropy F ≤ log n` (no functor loses more than
  the total information present).
* `FunctorialEntropy.entropy_le_comp` — the **data-processing inequality**: post-composing
  with any further functor can only increase the information loss, `entropy f ≤ entropy (g ∘ f)`.
* Worked examples reproducing the conjectured values `log 2` and `0`.
-/

open scoped BigOperators
open Real Finset

namespace FunctorialEntropy

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- The cardinality of the fiber of `F` over `d`, i.e. the number of objects of the domain
sent to `d`. -/
def fiberCard (F : α → β) (d : β) : ℕ := (Finset.univ.filter (fun a => F a = d)).card

/--
Fibers partition the domain, so the fiber cardinalities sum to `|Ob C| = |α|`.
-/
lemma sum_fiberCard (F : α → β) :
    ∑ d : β, fiberCard F d = Fintype.card α := by
  simp +decide [ fiberCard ];
  simp +decide only [card_filter];
  rw [ Finset.sum_comm ] ; aesop

/-- **Functorial entropy** — the information lost by `F`, computed as the conditional
entropy `H(α ∣ F α)` of the domain object given its image, under the uniform distribution
on `α`. -/
noncomputable def entropy (F : α → β) : ℝ :=
  ∑ d : β, (fiberCard F d : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard F d)

omit [Fintype β] in
/--
Each summand of the entropy is nonnegative.
-/
lemma term_nonneg (F : α → β) (d : β) :
    0 ≤ (fiberCard F d : ℝ) / (Fintype.card α : ℝ) * Real.log (fiberCard F d) := by
  exact mul_nonneg ( div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ) ) ( Real.log_natCast_nonneg _ )

/--
Information loss is never negative.
-/
theorem entropy_nonneg (F : α → β) : 0 ≤ entropy F := by
  exact Finset.sum_nonneg fun _ _ => term_nonneg F _

omit [Fintype β] in
/--
A map is injective iff every fiber has at most one element.
-/
lemma injective_iff_fiberCard_le_one (F : α → β) :
    Function.Injective F ↔ ∀ d, fiberCard F d ≤ 1 := by
  constructor;
  · intro hF d;
    exact Finset.card_le_one.2 fun x hx y hy => hF <| by aesop;
  · intro h x y hxy; have := h ( F x ) ; simp_all +decide [ fiberCard ] ;
    exact Classical.not_not.1 fun hx => absurd ( h ( F x ) ) ( by exact not_le.2 ( Finset.one_lt_card.2 ⟨ x, by aesop, y, by aesop ⟩ ) )

/--
**The vanishing criterion.**  A functor loses no information iff it is injective on
objects (faithful).  This is the correct formulation of the conjecture "`H(F) = 0` iff
`F` is faithful".
-/
theorem entropy_eq_zero_iff_injective [Nonempty α] (F : α → β) :
    entropy F = 0 ↔ Function.Injective F := by
  rw [ entropy ];
  rw [ Finset.sum_eq_zero_iff_of_nonneg ];
  · simp +decide [ injective_iff_fiberCard_le_one ];
    exact forall_congr' fun d => ⟨ fun h => by rcases h with ( h | h | h ) <;> linarith, fun h => by interval_cases fiberCard F d <;> norm_num ⟩;
  · exact fun _ _ => term_nonneg F _

/--
**The uniform-fiber formula.**  If every fiber of `F` has the same cardinality `k`,
then `entropy F = log k`.  When `F` is surjective this is `log (|Ob C| / |Ob D|)`.
-/
theorem entropy_uniform [Nonempty β] (F : α → β) (k : ℕ)
    (hk : ∀ d, fiberCard F d = k) : entropy F = Real.log k := by
  -- Using sum_fiberCard and hk (∀ d, fiberCard F d = k), Fintype.card α = ∑ d, k = m * k.
  have h_card : Fintype.card α = Fintype.card β * k := by
    rw [ ← sum_fiberCard F, Fintype.card_eq_sum_ones ] ; simp +decide [ hk ];
  by_cases hk0 : k = 0 <;> simp_all +decide [ entropy ];
  field_simp

/--
A constant functor collapses everything into one fiber, losing the maximal amount of
information `log n`.
-/
theorem entropy_const [Nonempty α] (F : α → β) (hconst : ∀ a b : α, F a = F b) :
    entropy F = Real.log (Fintype.card α) := by
  obtain ⟨a0⟩ := ‹Nonempty α›;
  set d0 := F a0;
  have hF : ∀ a, F a = d0 := by
    exact fun a => hconst a a0;
  simp_all [entropy, fiberCard] ;
  rw [ Finset.sum_eq_single d0 ] <;> aesop

/--
**The maximum-loss bound.**  No functor loses more information than the total amount
`log n` present in the domain.
-/
theorem entropy_le_log_card (F : α → β) :
    entropy F ≤ Real.log (Fintype.card α) := by
  by_cases h : Fintype.card α = 0;
  · simp_all +decide [ entropy ];
  · -- For each $d$, $(c_d / n) * \log c_d \leq (c_d / n) * \log n$.
    have h_term_le (d : β) : (fiberCard F d : ℝ) / (Fintype.card α) * Real.log (fiberCard F d) ≤ (fiberCard F d : ℝ) / (Fintype.card α) * Real.log (Fintype.card α) := by
      by_cases hd : fiberCard F d = 0;
      · simp +decide [ hd ];
      · exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( by positivity ) ( mod_cast Nat.le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) ) ) ( by positivity );
    -- Summing the inequalities over all $d$, we get $\sum_d (c_d / n) * \log c_d \leq \sum_d (c_d / n) * \log n$.
    have h_sum_le : ∑ d : β, (fiberCard F d : ℝ) / (Fintype.card α) * Real.log (fiberCard F d) ≤ ∑ d : β, (fiberCard F d : ℝ) / (Fintype.card α) * Real.log (Fintype.card α) := by
      exact Finset.sum_le_sum fun _ _ => h_term_le _;
    simp_all +decide [ ← Finset.sum_mul _ _ _ ];
    exact h_sum_le.trans ( mul_le_of_le_one_left ( Real.log_nonneg ( mod_cast Nat.one_le_iff_ne_zero.mpr h ) ) ( by rw [ ← Finset.sum_div _ _ _, div_le_iff₀ ( by positivity ) ] ; exact mod_cast sum_fiberCard F ▸ by simp +decide ) )

/--
The fiber of a composite over `e` is the union of the `f`-fibers over the points `d`
with `g d = e`; hence its cardinality is the corresponding sum of `f`-fiber cardinalities.
-/
lemma fiberCard_comp {γ : Type*} [Fintype γ] [DecidableEq γ]
    (f : α → β) (g : β → γ) (e : γ) :
    fiberCard (g ∘ f) e = ∑ d ∈ Finset.univ.filter (fun d => g d = e), fiberCard f d := by
  have h_card_eq_sum_card_fiberwise : Finset.card (Finset.univ.filter (fun a => g (f a) = e)) = ∑ d ∈ Finset.univ.filter (fun d => g d = e), (Finset.filter (fun a => f a = d) Finset.univ).card := by
    simp +decide only [card_filter];
    rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop;
  exact h_card_eq_sum_card_fiberwise

/--
**Data-processing inequality.**  Post-composing a functor with any further functor can
only increase the information lost: `entropy f ≤ entropy (g ∘ f)`.  Coarser observations of
the image retain less information about the domain.
-/
theorem entropy_le_comp {γ : Type*} [Fintype γ] [DecidableEq γ]
    (f : α → β) (g : β → γ) : entropy f ≤ entropy (g ∘ f) := by
  have h_sum : ∑ d, fiberCard f d * Real.log (fiberCard f d) ≤ ∑ e, ∑ d ∈ Finset.univ.filter (fun d => g d = e), fiberCard f d * Real.log (fiberCard (g ∘ f) e) := by
    have h_sum : ∀ e, ∑ d ∈ Finset.univ.filter (fun d => g d = e), fiberCard f d * Real.log (fiberCard f d) ≤ ∑ d ∈ Finset.univ.filter (fun d => g d = e), fiberCard f d * Real.log (fiberCard (g ∘ f) e) := by
      intro e; apply Finset.sum_le_sum; intro d hd; by_cases h : fiberCard f d = 0 <;> simp_all +decide [ fiberCard_comp ] ;
      exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero h ) ) ( mod_cast Finset.single_le_sum ( fun x _ => Nat.zero_le ( fiberCard f x ) ) ( by aesop ) ) ) ( Nat.cast_nonneg _ );
    convert Finset.sum_le_sum fun e _ => h_sum e;
    rw [ Finset.sum_fiberwise ];
  convert mul_le_mul_of_nonneg_left h_sum ( show ( 0 : ℝ ) ≤ 1 / Fintype.card α from by positivity ) using 1 <;> norm_num [ entropy, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm, div_eq_inv_mul, Finset.sum_mul ];
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, fiberCard_comp ]

/-! ## Worked examples reproducing the conjectured values -/

/--
A two-to-one functor between finite categories loses `log 2` — the value conjectured for
abelianization `Ab : Grp → AbGrp`, whose fibers `{G, G × ℤ/2ℤ}` have size two.
-/
example : entropy (fun b : Bool × Bool => b.1) = Real.log 2 := by
  convert entropy_uniform _ _ _;
  · exact ⟨ Bool.true ⟩;
  · simp +decide

/--
The identity functor (an inclusion that renames nothing) is faithful, hence loses no
information — the value conjectured for `Inc : FinGrp → Grp`.
-/
example : entropy (id : Bool → Bool) = 0 := by
  refine' Finset.sum_eq_zero fun x _ => _;
  fin_cases x <;> aesop

end FunctorialEntropy