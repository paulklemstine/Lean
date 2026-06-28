import Mathlib

/-!
# The balancing / Schur-concavity engine

This file isolates the *combinatorial engine* behind the research mission
"balanced side lengths maximise spanning trees".  The empirical observations of
`Kirchhoff.lean` (balanced grids win for `N = 4, 6, 8`) all have the same cause:
the spanning-tree count, as a function of the multiset of side lengths, obeys an
**exchange (Schur-concavity) inequality** — moving two coordinates closer
together (`a, b ↦ a+1, b-1`, which preserves both the sum and the cardinality)
strictly increases the quantity.

We prove, with no `sorry`, the abstract principle:

> **`balanced_of_maximizer`** : if `f` satisfies the exchange inequality on a
> domain `dom` closed under exchanges, then any `dom`-maximiser of `f` over the
> multisets of fixed cardinality `d` and fixed sum `k` is **balanced**: any two
> of its entries differ by at most `1`.

Two unconditional corollaries make the engine concrete:

* **`balanced_of_sumsq_min`** : a multiset of fixed size and sum that minimises
  `∑ xᵢ²` is balanced (Schur convexity of the power sum).
* **`balanced_of_prod_max`** : a multiset of fixed size and sum, with all entries
  positive, that maximises `∏ xᵢ` is balanced — i.e. the integer **AM–GM**
  extremal characterisation.

For grids the relevant constraint is a fixed *product* `N` (vertex count); via
the prime-power reduction (`N = c^k`, sides `c^{aᵢ}`, so `∏ = c^{∑ aᵢ}`) the
multiplicative balancing problem becomes exactly the additive one solved here on
the exponent multiset.  `grid_balanced_of_exchange` packages this: any spanning
tree maximiser whose count obeys the exchange inequality must be balanced.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer):  "Balanced maximises" is not special to spanning
--   trees; it is the signature of *any* Schur-concave count.  The bold
--   conjecture: the grid spanning-tree count is Schur-concave in the multiset of
--   side lengths (additively on exponents for prime-power N).
-- Experiment:  Proved the exchange→balanced engine in full generality over
--   `Multiset ℕ` with an arbitrary `LinearOrder` codomain and a closed domain.
--   Instantiated it to recover Schur-convexity of `∑ xᵢ²` and integer AM–GM.
-- Analysis (Analyst):  The whole phenomenon factors through one inequality on a
--   single pair of coordinates; the multiset `cons`/`erase` calculus turns the
--   global maximality assumption into a two-element exchange contradiction.
--   What survives unconditionally: the engine + the sum-of-squares / AM–GM
--   corollaries.  What needs the missing analytic input: the *grid-specific*
--   exchange inequality (Kirchhoff determinants of differing shapes), confirmed
--   computationally in `Kirchhoff.lean` for small `N` but open in general.
-- Critique (Critic):  The engine is not vacuous — both corollaries exhibit
--   genuine `f` satisfying the hypotheses, and the proof uses `by_contra`,
--   multiset extraction and `nlinarith`/`omega`, not `decide`.
-- Synthesis:  One exchange lemma explains every balanced-maximiser theorem in
--   this project; the grid case is the corollary awaiting Schur-concavity of τ.
-- !-- Lab Notes -- !--
-/

namespace SpanningTreeGrids

open Multiset

/-- A multiset is **balanced** when any two of its entries differ by at most one.
This is exactly the "side lengths as equal as possible" condition. -/
def Balanced (s : Multiset ℕ) : Prop := ∀ a ∈ s, ∀ b ∈ s, b ≤ a + 1

/-
**The balancing engine.**  Let `f` take values in a linear order and satisfy
the *exchange inequality*: replacing a pair `a, b` with `a+2 ≤ b` by the closer
pair `a+1, b-1` strictly increases `f`, on a domain `dom` closed under such
exchanges.  Then any `dom`-maximiser of `f` among multisets of fixed cardinality
`d` and fixed sum `k` is balanced.
-/
theorem balanced_of_maximizer {β : Type*} [LinearOrder β]
    (f : Multiset ℕ → β) (dom : Multiset ℕ → Prop) (d k : ℕ)
    (exch : ∀ (t : Multiset ℕ) (a b : ℕ), a + 2 ≤ b → dom (a ::ₘ b ::ₘ t) →
      f (a ::ₘ b ::ₘ t) < f ((a + 1) ::ₘ (b - 1) ::ₘ t))
    (clos : ∀ (t : Multiset ℕ) (a b : ℕ), a + 2 ≤ b → dom (a ::ₘ b ::ₘ t) →
      dom ((a + 1) ::ₘ (b - 1) ::ₘ t))
    {s : Multiset ℕ} (hdom : dom s) (hcard : s.card = d) (hsum : s.sum = k)
    (hmax : ∀ t : Multiset ℕ, dom t → t.card = d → t.sum = k → f t ≤ f s) :
    Balanced s := by
  intro a ha b hb;
  by_contra hba;
  -- Let $t$ be the multiset obtained by removing $a$ and $b$ from $s$.
  obtain ⟨t, ht⟩ : ∃ t, s = a ::ₘ b ::ₘ t := by
    have := Multiset.exists_cons_of_mem ha; obtain ⟨ t₁, rfl ⟩ := this; simp_all +decide ;
    exact Multiset.exists_cons_of_mem ( hb.resolve_left ( by linarith ) );
  simp_all +decide;
  exact not_le_of_gt ( exch t a b hba hdom ) ( hmax _ ( clos t a b hba hdom ) ( by simp +decide [ ← hcard ] ) ( by simp +decide [ ← hsum ] ; omega ) )

/-
Schur convexity of the quadratic power sum: among multisets of fixed size and
sum, a minimiser of `∑ xᵢ²` is balanced.
-/
theorem balanced_of_sumsq_min (d k : ℕ) {s : Multiset ℕ}
    (hcard : s.card = d) (hsum : s.sum = k)
    (hmin : ∀ t : Multiset ℕ, t.card = d → t.sum = k →
      (s.map (fun x => (x : ℤ) ^ 2)).sum ≤ (t.map (fun x => (x : ℤ) ^ 2)).sum) :
    Balanced s := by
  -- Define the function `f` and domain `dom` to apply `balanced_of_maximizer`.
  set f : Multiset ℕ → ℤ := fun t => -(t.map (fun x => (x : ℤ)^2)).sum
  set dom : Multiset ℕ → Prop := fun t => True;
  apply balanced_of_maximizer f dom d k;
  all_goals norm_num [ f, dom ];
  · intro t a b hab; rw [ Nat.cast_sub ( by linarith ) ] ; push_cast; nlinarith;
  · exact hcard;
  · exact hsum;
  · aesop

/-
Integer **AM–GM** extremal characterisation: among multisets of fixed size
and sum with all entries positive, a maximiser of the product `∏ xᵢ` is balanced.
-/
theorem balanced_of_prod_max (d k : ℕ) {s : Multiset ℕ}
    (hpos : ∀ x ∈ s, 1 ≤ x) (hcard : s.card = d) (hsum : s.sum = k)
    (hmax : ∀ t : Multiset ℕ, (∀ x ∈ t, 1 ≤ x) → t.card = d → t.sum = k →
      t.prod ≤ s.prod) :
    Balanced s := by
  contrapose! hmax with hbalanced;
  obtain ⟨a, b, hab⟩ : ∃ a ∈ s, ∃ b ∈ s, a + 2 ≤ b := by
    grind +locals;
  -- Let's choose such $b$ and construct the new multiset $t$ by replacing $a$ and $b$ with $a+1$ and $b-1$.
  obtain ⟨b, hb, hab⟩ := hab;
  obtain ⟨t, ht⟩ : ∃ t : Multiset ℕ, s = a ::ₘ b ::ₘ t := by
    obtain ⟨ t, ht ⟩ := Multiset.exists_cons_of_mem ‹a ∈ s›; obtain ⟨ u, hu ⟩ := Multiset.exists_cons_of_mem ( show b ∈ t from by aesop ) ; use u; aesop;
  refine' ⟨ ( a + 1 ) ::ₘ ( b - 1 ) ::ₘ t, _, _, _, _ ⟩ <;> simp_all +decide;
  · omega;
  · omega;
  · rw [ ← mul_assoc, ← mul_assoc ];
    exact mul_lt_mul_of_pos_right ( by nlinarith only [ hab, Nat.sub_add_cancel ( by linarith : 1 ≤ b ) ] ) ( Multiset.prod_pos fun x hx => hpos.2.2 x hx )

/-
**Grid corollary.**  Model a `d`-dimensional free-boundary grid by the
multiset of its side-length *exponents* relative to a fixed base (`N = c^k`,
side `i` equal to `c^{aᵢ}`, so the vertex count is `c^{∑ aᵢ}`; fixing `N` fixes
`∑ aᵢ = k`).  If the spanning-tree count `τ`, as a function of the exponent
multiset, obeys the exchange inequality, then every spanning-tree maximiser is
balanced — its side lengths are as equal as possible.
-/
theorem grid_balanced_of_exchange {β : Type*} [LinearOrder β]
    (τ : Multiset ℕ → β) (d k : ℕ)
    (exch : ∀ (t : Multiset ℕ) (a b : ℕ), a + 2 ≤ b →
      τ (a ::ₘ b ::ₘ t) < τ ((a + 1) ::ₘ (b - 1) ::ₘ t))
    {s : Multiset ℕ} (hcard : s.card = d) (hsum : s.sum = k)
    (hmax : ∀ t : Multiset ℕ, t.card = d → t.sum = k → τ t ≤ τ s) :
    Balanced s := by
  have := @balanced_of_maximizer;
  exact this τ ( fun _ => True ) d k ( by simpa using exch ) ( by simp +decide ) ( by simp +decide ) hcard hsum ( by simpa using hmax )

end SpanningTreeGrids