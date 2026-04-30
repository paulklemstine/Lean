import Mathlib

/-! # Knaster-Tarski Fixed Point Bridge

Proves the Knaster-Tarski theorem: every monotone function on a complete
lattice has a least fixed point (and greatest fixed point).

Complementary to Banach's metric-space fixed point theorem:

1. Banach: contraction on COMPLETE METRIC spaces → unique fixed point
2. Knaster-Tarski: monotone on COMPLETE LATTICES → least/greatest fixed points

The least fixed point is constructive: it's the infimum of all pre-fixed
points {x | f(x) ≤ x}.

Key proof insight: f(inf S) ≤ inf S because for any b ∈ S,
f(b) ≤ b and by monotonicity f(inf S) ≤ f(b) ≤ b. Conversely,
inf S ≤ f(inf S) because f(inf S) IS in S (by monotonicity:
f(inf S) ≤ inf S implies f(f(inf S)) ≤ f(inf S)).
-/

namespace KnasterTarskiBridge

universe u

variable {α : Type u} [CompleteLattice α]

/-! ## Section 1: Pre-fixed and Post-fixed Points -/

/-- The pre-fixed points of f: {x | f(x) ≤ x} -/
def preFixed (f : α → α) : Set α := {x | f x ≤ x}

/-- The post-fixed points of f: {x | x ≤ f(x)} -/
def postFixed (f : α → α) : Set α := {x | x ≤ f x}

/-- The fixed points of f: {x | f(x) = x} -/
def fixedPoints (f : α → α) : Set α := {x | f x = x}

/-! ## Section 2: Knaster-Tarski Theorem (Least Fixed Point) -/

/-- Key lemma: f(inf of pre-fixed points) ≤ inf of pre-fixed points.
    For any pre-fixed point b, inf S ≤ b, so f(inf S) ≤ f(b) ≤ b. -/
theorem sInf_prefixed_le (f : α → α) (hf : Monotone f) :
    f (sInf (preFixed f)) ≤ sInf (preFixed f) := by
  rw [le_sInf_iff]
  intro b hb
  calc f (sInf (preFixed f)) ≤ f b := hf (sInf_le hb)
  _ ≤ b := hb

/-- Conversely: inf of pre-fixed points ≤ f(inf of pre-fixed points).
    From f(inf) ≤ inf, by monotonicity f(f(inf)) ≤ f(inf),
    so f(inf) is itself a pre-fixed point, hence inf ≤ f(inf). -/
theorem sInf_le_sInf_prefixed (f : α → α) (hf : Monotone f) :
    sInf (preFixed f) ≤ f (sInf (preFixed f)) := by
  have h := sInf_prefixed_le f hf
  exact sInf_le (hf h)

/-- **Knaster-Tarski theorem**: The infimum of pre-fixed points is a fixed point.
    Every monotone function on a complete lattice has a fixed point:
    f(inf{x | f(x) ≤ x}) = inf{x | f(x) ≤ x} -/
theorem knaster_tarski (f : α → α) (hf : Monotone f) :
    f (sInf (preFixed f)) = sInf (preFixed f) :=
  le_antisymm (sInf_prefixed_le f hf) (sInf_le_sInf_prefixed f hf)

/-! ## Section 3: Least Fixed Point Properties -/

/-- The sInf of pre-fixed points is ≤ any pre-fixed point -/
theorem sInf_prefixed_le_prefixed (f : α → α) (_hf : Monotone f) (x : α) (hx : f x ≤ x) :
    sInf (preFixed f) ≤ x :=
  sInf_le hx

/-- The least fixed point is ≤ any fixed point.
    Since f(x) = x implies f(x) ≤ x (fixed → pre-fixed). -/
theorem lfp_le_fixed (f : α → α) (hf : Monotone f) (x : α) (hx : f x = x) :
    sInf (preFixed f) ≤ x :=
  sInf_prefixed_le_prefixed f hf x hx.le

/-! ## Section 4: Dual Results (Greatest Fixed Point) -/

/-- Key lemma for greatest fixed point:
    sSup of post-fixed points ≤ f(sSup of post-fixed points) -/
theorem sSup_postfixed_le (f : α → α) (hf : Monotone f) :
    sSup (postFixed f) ≤ f (sSup (postFixed f)) := by
  rw [sSup_le_iff]
  intro b hb
  calc b ≤ f b := hb
  _ ≤ f (sSup (postFixed f)) := hf (le_sSup hb)

/-- f(sSup of post-fixed) ≤ sSup of post-fixed from monotonicity -/
theorem f_sSup_postfixed_le (f : α → α) (hf : Monotone f) :
    f (sSup (postFixed f)) ≤ sSup (postFixed f) := by
  have h := sSup_postfixed_le f hf
  exact le_sSup (hf h)

/-- **Dual Knaster-Tarski**: The supremum of post-fixed points is a fixed point.
    f(sSup{x | x ≤ f(x)}) = sUp{x | x ≤ f(x)} -/
theorem knaster_tarski_dual (f : α → α) (hf : Monotone f) :
    f (sSup (postFixed f)) = sSup (postFixed f) :=
  le_antisymm (f_sSup_postfixed_le f hf) (sSup_postfixed_le f hf)

/-- The sSup of post-fixed points is ≥ any post-fixed point -/
theorem sSup_postfixed_ge_postfixed (f : α → α) (_hf : Monotone f) (x : α) (hx : x ≤ f x) :
    x ≤ sSup (postFixed f) :=
  le_sSup hx

/-- The greatest fixed point is ≥ any fixed point.
    Since f(x) = x implies x ≤ f(x) (fixed → post-fixed). -/
theorem gfp_ge_fixed (f : α → α) (hf : Monotone f) (x : α) (hx : f x = x) :
    x ≤ sSup (postFixed f) :=
  sSup_postfixed_ge_postfixed f hf x hx.ge

/-! ## Section 5: LFP ≤ GFP -/

/-- The least fixed point is ≤ the greatest fixed point.
    This follows because the greatest fixed point IS a fixed point. -/
theorem lfp_le_gfp (f : α → α) (hf : Monotone f) :
    sInf (preFixed f) ≤ sSup (postFixed f) :=
  lfp_le_fixed f hf (sSup (postFixed f)) (knaster_tarski_dual f hf)

end KnasterTarskiBridge
